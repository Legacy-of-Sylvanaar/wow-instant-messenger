--[[
    UISnapshot.lua

    Development aid: /wim snap serializes the live widget state of the frames
    being styled -- every region's resolved rectangle, anchors, texture/atlas,
    texcoords, colors and fonts -- into a SavedVariable, and captures a
    screenshot of the same moment. Comparing the dump of a WIM frame against
    the dump of the native frame it is modeled on turns skin work into a
    numeric diff instead of a visual guess.

    /wim snap                 - print the available arguments.
    /wim snap all             - snapshot everything WIM styles: every
                                message window (shown or hidden), the
                                History Viewer, the options windows,
                                the menu, the minimap button and the
                                native reference widgets, so nothing
                                is missing from the captured state.
    /wim snap <Dot.Path>      - snapshot one frame by global dot-path,
                                e.g. /wim snap SettingsPanel.Bg

    The data lands in WIM3_Snapshots (per character) and is written to disk
    on /reload or logout, like any SavedVariable. The screenshot is written
    immediately to the game's Screenshots folder.
]]

local _G = getfenv(0);
local pairs, ipairs = pairs, ipairs;
local type, tostring = type, tostring;
local pcall = pcall;
local table, string, math = table, string, math;

-- Defined before the setfenv: C_Texture.GetAtlasInfo resolves helper
-- mixins (Vector2DMixin) through the caller's environment, so calling
-- it from inside the WIM environment throws. Same pattern as
-- Modules/History.lua.
local C_Texture = C_Texture;
local function getAtlasInfoRaw(name)
    if (C_Texture and C_Texture.GetAtlasInfo) then
        return C_Texture.GetAtlasInfo(name);
    end
    return nil;
end

setfenv(1, WIM);

-- The fixed targets of /wim snap all: the styled panels, plus the
-- native widgets the styles are modeled on (the Settings panel's list
-- scrollbar, corner close button, and search box).
local fixedTargets = {
    "WIM3_HistoryFrame",
    "WIM3_Options",
    "WIM3Menu",
    "WIM_LastModernMenu",
    "LibDBIcon10_WIM",
    "SettingsPanel.Container.SettingsList.ScrollBar",
    "SettingsPanel.ClosePanelButton",
    "SettingsPanel.SearchBox",
};

-- Everything /wim snap all captures: every live message window of
-- every type, shown or hidden, with its whole widget tree, then the
-- fixed list above.
local function collectAllTargets()
    local list = {};
    for _, winType in ipairs({ "whisper", "chat", "w2w" }) do
        local set = windows.active[winType];
        if(type(set) == "table") then
            for _, win in pairs(set) do
                if(type(win) == "table" and win.GetName and win:GetName()) then
                    table.insert(list, win:GetName());
                end
            end
        end
    end
    for i=1, #fixedTargets do
        table.insert(list, fixedTargets[i]);
    end
    return list;
end

local MAX_DEPTH = 15;
local MAX_NODES = 4000;
local KEPT_SNAPSHOTS = 3;

local function rnd(v)
    if (type(v) ~= "number") then return v; end
    return math.floor(v * 100 + 0.5) / 100;
end

-- Resolves "SettingsPanel.Container.SettingsList.ScrollBar" from _G.
local function resolvePath(path)
    local obj = _G;
    for key in string.gmatch(path, "[^%.]+") do
        local ok, value = pcall(function() return obj[key]; end);
        if (not ok or value == nil) then
            return nil;
        end
        obj = value;
    end
    return obj;
end

-- Best available identifier for a region: global name, or the field name it
-- occupies on its parent (its parentKey), or just its type.
local function describeRegion(obj, parent)
    local ok, name = pcall(obj.GetName, obj);
    if (ok and name) then return name; end
    if (parent) then
        local found;
        pcall(function()
            for k, v in pairs(parent) do
                if (v == obj and type(k) == "string") then
                    found = "."..k;
                    return;
                end
            end
        end);
        if (found) then return found; end
    end
    local okT, objType = pcall(obj.GetObjectType, obj);
    return "<"..(okT and objType or "?")..">";
end

local function grabAnchors(obj)
    local anchors = {};
    local ok, count = pcall(obj.GetNumPoints, obj);
    if (not ok or not count) then return anchors; end
    for i = 1, count do
        local okP, point, relativeTo, relativePoint, x, y = pcall(obj.GetPoint, obj, i);
        if (okP and point) then
            local relName;
            if (relativeTo) then
                local okN, n = pcall(relativeTo.GetName, relativeTo);
                relName = (okN and n) or describeRegion(relativeTo);
            end
            table.insert(anchors, {
                point = point, relTo = relName, relPoint = relativePoint,
                x = rnd(x), y = rnd(y),
            });
        end
    end
    return anchors;
end

local function grabRect(obj, node)
    local ok, left, bottom, width, height = pcall(obj.GetRect, obj);
    if (ok and left) then
        node.rect = { left = rnd(left), bottom = rnd(bottom), w = rnd(width), h = rnd(height) };
    end
    -- GetScaledRect resolves to screen coordinates (UIParent space), which is
    -- what makes rects from differently-scaled frames directly comparable.
    local okS, sLeft, sBottom, sWidth, sHeight = pcall(obj.GetScaledRect, obj);
    if (okS and sLeft) then
        node.scaledRect = { left = rnd(sLeft), bottom = rnd(sBottom), w = rnd(sWidth), h = rnd(sHeight) };
    end
    local okE, scale = pcall(obj.GetEffectiveScale, obj);
    if (okE and scale) then node.effScale = rnd(scale); end
end

local function grabTexture(obj, node)
    local ok, atlas = pcall(obj.GetAtlas, obj);
    if (ok and atlas) then node.atlas = atlas; end
    local okT, tex = pcall(obj.GetTexture, obj);
    if (okT and tex ~= nil) then node.texture = tostring(tex); end
    local okC, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = pcall(obj.GetTexCoord, obj);
    if (okC and ULx) then
        node.texCoord = { rnd(ULx), rnd(ULy), rnd(LLx), rnd(LLy), rnd(URx), rnd(URy), rnd(LRx), rnd(LRy) };
    end
    local okV, r, g, b, a = pcall(obj.GetVertexColor, obj);
    if (okV and r) then node.vertexColor = { rnd(r), rnd(g), rnd(b), rnd(a) }; end
    local okB, blend = pcall(obj.GetBlendMode, obj);
    if (okB and blend and blend ~= "BLEND") then node.blendMode = blend; end
    local okD, desat = pcall(obj.GetDesaturation, obj);
    if (okD and desat and desat > 0) then node.desaturation = rnd(desat); end
    local okL, layer, subLevel = pcall(obj.GetDrawLayer, obj);
    if (okL and layer) then node.drawLayer = layer.."/"..tostring(subLevel); end
    if (obj.GetNumMaskTextures) then
        local okM, masks = pcall(obj.GetNumMaskTextures, obj);
        if (okM and masks and masks > 0) then node.maskTextures = masks; end
    end
end

local function grabFontString(obj, node)
    local ok, fontPath, fontHeight, fontFlags = pcall(obj.GetFont, obj);
    if (ok and fontPath) then
        node.font = { path = tostring(fontPath), height = rnd(fontHeight), flags = fontFlags or "" };
    end
    local okT, text = pcall(obj.GetText, obj);
    if (okT and text and text ~= "") then node.text = string.sub(text, 1, 60); end
    local okC, r, g, b, a = pcall(obj.GetTextColor, obj);
    if (okC and r) then node.textColor = { rnd(r), rnd(g), rnd(b), rnd(a) }; end
end

local function grabSlider(obj, node)
    local ok, minVal, maxVal = pcall(obj.GetMinMaxValues, obj);
    if (ok and minVal) then node.sliderRange = { rnd(minVal), rnd(maxVal) }; end
    local okV, value = pcall(obj.GetValue, obj);
    if (okV and value) then node.sliderValue = rnd(value); end
end

local function snapRegion(obj, parent, depth, budget)
    if (depth > MAX_DEPTH or budget.nodes <= 0) then
        budget.truncated = true;
        return nil;
    end
    budget.nodes = budget.nodes - 1;

    local okF, forbidden = pcall(obj.IsForbidden, obj);
    if (okF and forbidden) then
        return { id = "<forbidden>" };
    end

    local node = { id = describeRegion(obj, parent) };
    local okT, objType = pcall(obj.GetObjectType, obj);
    if (okT) then node.type = objType; end

    local okS, shown = pcall(obj.IsShown, obj);
    if (okS) then node.shown = shown and true or false; end
    local okV, visible = pcall(obj.IsVisible, obj);
    if (okV and shown and not visible) then node.hiddenByParent = true; end
    local okA, alpha = pcall(obj.GetAlpha, obj);
    if (okA and alpha and alpha < 1) then node.alpha = rnd(alpha); end

    grabRect(obj, node);
    node.anchors = grabAnchors(obj);

    if (objType == "Texture" or objType == "MaskTexture" or objType == "Line") then
        grabTexture(obj, node);
    elseif (objType == "FontString") then
        grabFontString(obj, node);
    elseif (objType == "Slider") then
        grabSlider(obj, node);
    end

    if (obj.DoesClipChildren) then
        local okCC, clips = pcall(obj.DoesClipChildren, obj);
        if (okCC and clips) then node.clipsChildren = true; end
    end
    if (obj.GetFrameLevel) then
        local okL, level = pcall(obj.GetFrameLevel, obj);
        if (okL) then node.frameLevel = level; end
    end

    -- Layered regions (textures, fontstrings), then child frames.
    if (obj.GetRegions) then
        local okR, regions = pcall(function() return { obj:GetRegions() }; end);
        if (okR) then
            for _, region in ipairs(regions) do
                local child = snapRegion(region, obj, depth + 1, budget);
                if (child) then
                    node.regions = node.regions or {};
                    table.insert(node.regions, child);
                end
            end
        end
    end
    if (obj.GetChildren) then
        local okC, children = pcall(function() return { obj:GetChildren() }; end);
        if (okC) then
            for _, childFrame in ipairs(children) do
                local child = snapRegion(childFrame, obj, depth + 1, budget);
                if (child) then
                    node.children = node.children or {};
                    table.insert(node.children, child);
                end
            end
        end
    end

    return node;
end

-- ---------------------------------------------------------------------------
-- Client capability probes. Classic-flavored clients (era, TBC, wrath,
-- MoP and their successors) share atlas and layout NAMES with retail
-- while the art, geometry, and API behavior differ, so every dump
-- records what this client actually has. Diffing the client block of
-- two dumps isolates flavor problems without guesswork.
-- ---------------------------------------------------------------------------
local PROBE_ATLASES = {
    "RedButton-Exit", "redbutton-condense", "RedButton-Highlight",
    "minimal-scrollbar-small-thumb-middle", "minimal-scrollbar-arrow-top",
    "minimal-scrollbar-track-top", "common-search-border-left",
    "common-search-border-middle", "options_frame_child",
    "CircleMaskScalable", "common-dropdown-bg", "Options_List_Active",
    "Options_CategoryHeader_1", "UI-Frame-TopLeftCornerNoPortrait",
    "_UI-Frame-TitleTile", "UI-Frame-InnerTopLeft",
};
local PROBE_FILES = {
    "Interface\\Icons\\ClassIcon_WARRIOR",
    "Interface\\FrameGeneral\\UI-Background-Rock",
    "Interface\\FrameGeneral\\UI-Background-Marble",
    "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
    "Interface\\Tooltips\\UI-Tooltip-Border",
};
local PROBE_LAYOUTS = {
    "PortraitFrameTemplate", "ButtonFrameTemplate",
    "ButtonFrameTemplateNoPortrait", "InsetFrameTemplate",
};

local layoutProbeFrame;
local function collectClientInfo()
    -- Every probe is isolated: one API behaving differently on some
    -- flavor must not cost the whole block, and a failed section
    -- records its error instead of disappearing.
    local info = { atlases = {}, files = {}, layouts = {}, api = {},
        errors = {} };
    local function try(section, fun)
        local ok, err = pcall(fun);
        if (not ok) then
            info.errors[section] = tostring(err);
        end
    end
    try("build", function()
        local version, build, _, interface = _G.GetBuildInfo();
        info.version = version;
        info.buildNumber = build;
        info.interface = interface;
    end);
    info.project = _G.WOW_PROJECT_ID;
    info.isModernApi = isModernApi and true or false;
    try("atlases", function()
        info.api.GetAtlasInfo = (_G.C_Texture and _G.C_Texture.GetAtlasInfo)
            and true or false;
        for _, name in ipairs(PROBE_ATLASES) do
            local ok, result = pcall(getAtlasInfoRaw, name);
            info.atlases[name] = (ok and result ~= nil) and true or false;
        end
    end);
    try("files", function()
        info.api.GetFileIDFromPath = _G.GetFileIDFromPath and true or false;
        for _, file in ipairs(PROBE_FILES) do
            local ok, id = pcall(_G.GetFileIDFromPath, file);
            info.files[file] = (ok and id ~= nil) and true or false;
        end
    end);
    try("layouts", function()
        local apply = _G.NineSliceUtil and _G.NineSliceUtil.ApplyLayoutByName;
        info.api.NineSliceUtil = apply and true or false;
        for _, layout in ipairs(PROBE_LAYOUTS) do
            if (apply) then
                layoutProbeFrame = layoutProbeFrame or _G.CreateFrame("Frame");
                layoutProbeFrame:Hide();
                info.layouts[layout] = pcall(apply, layoutProbeFrame, layout)
                    and true or false;
            else
                info.layouts[layout] = false;
            end
        end
    end);
    try("api", function()
        info.api.SettingsVertical = (_G.Settings
            and _G.Settings.RegisterVerticalLayoutCategory) and true or false;
        info.api.SettingsElementInit = (_G.Settings
            and _G.Settings.CreateElementInitializer) and true or false;
        info.api.SettingsPanelInit = (_G.Settings
            and _G.Settings.CreatePanelInitializer) and true or false;
        info.api.SettingsButtonInit = _G.CreateSettingsButtonInitializer
            and true or false;
        info.api.ScrollFrameTemplate = pcall(_G.CreateFrame, "ScrollFrame",
            nil, nil, "ScrollFrameTemplate") and true or false;
    end);
    return info;
end

-- The skin and theme state the paint paths key off.
local function collectWimInfo()
    local info = {};
    info.skinSelected = db and db.skin and db.skin.selected;
    pcall(function()
        local skin = GetSelectedSkin();
        info.skinLoaded = skin and skin.title;
        info.modernOnly = (skin and skin.modernOnly) and true or false;
    end);
    info.modernOptions = (db and db.modernOptions) and true or false;
    if(db and db.modernTheme) then
        local theme = {};
        for k, v in pairs(db.modernTheme) do
            if(type(v) ~= "table") then
                theme[k] = v;
            end
        end
        info.theme = theme;
    end
    return info;
end

-- WIM-side bookkeeping for a captured window: the flags that decide
-- which paint path runs. Widget trees alone cannot show these.
local function collectWindowState(obj)
    local state = {};
    state.class = obj.class;
    state.type = obj.type;
    state.chromeFailed = obj.wimChromeFailed and true or nil;
    local chrome = obj.wimChrome;
    if(chrome) then
        state.chrome = chrome.lite and "lite" or "layout";
        state.chromeShown = chrome:IsShown() and true or false;
        state.hasPortrait = chrome.hasPortrait and true or false;
    end
    state.litePainted = obj.wimLitePainted and true or nil;
    state.portraitMasked = obj.wimPortraitMasked and true or nil;
    state.boxThemed = obj.wimBoxThemed and true or nil;
    state.rpIcon = obj.wimRPIcon and true or nil;
    state.themeWasActive = obj.wimThemeWasActive;
    if(obj.wimIconBaseSize) then
        state.iconBaseSize = tostring(obj.wimIconBaseSize[1])..","
            ..tostring(obj.wimIconBaseSize[2]);
    end
    if(obj.wimIconBaseLayer) then
        state.iconBaseLayer = tostring(obj.wimIconBaseLayer[1]).."/"
            ..tostring(obj.wimIconBaseLayer[2]);
    end
    local icon = obj.widgets and obj.widgets.class_icon;
    if(icon) then
        local w, h = icon:GetSize();
        state.iconSize = string.format("%.0fx%.0f", w or 0, h or 0);
    end
    return state;
end

local function takeSnapshot(args)
    local targets;
    args = args and string.trim(args) or "";
    if (args == "") then
        local msg = _G.DEFAULT_CHAT_FRAME;
        msg:AddMessage("|cff69ccf0WIM:|r /wim snap arguments:");
        msg:AddMessage("  |cffffffffall|r - capture everything WIM styles:"
            .." every message window (shown or hidden), the History Viewer,"
            .." the classic options window, the last modern menu, the"
            .." minimap button and the native reference widgets.");
        msg:AddMessage("  |cffffffff<Frame.Dot.Path>|r - capture one frame"
            .." by global path, e.g. /wim snap WIM3_msgFrame1");
        msg:AddMessage("  |cffffffffdelay <seconds>|r - capture everything"
            .." after a delay, to dump a transient state while your hands"
            .." are busy reproducing it.");
        msg:AddMessage("  Also: |cffffffff/wim snapmenu|r - capture the"
            .." next modern context menu while it is open.");
        return;
    end
    -- Delayed capture: arm now, reproduce the transient, the snapshot
    -- fires by itself.
    local delay = string.match(string.lower(args), "^delay%s+(%d+)$");
    if (delay) then
        delay = tonumber(delay);
        if (delay < 1) then delay = 1; end
        if (delay > 60) then delay = 60; end
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0WIM:|r snapshot armed:"
            .." capturing everything in "..delay.."s.");
        _G.C_Timer.After(delay, function()
            takeSnapshot("all");
        end);
        return;
    end
    if (string.lower(args) == "all") then
        targets = collectAllTargets();
    else
        targets = { args };
    end

    local snap = {
        taken = _G.date("%Y-%m-%d %H:%M:%S"),
        targets = {},
    };
    pcall(function()
        local version, build = _G.GetBuildInfo();
        snap.build = version.." ("..build..")";
    end);
    snap.addonBuild = BUILD_ID or "unknown";
    pcall(function()
        local w, h = _G.GetPhysicalScreenSize();
        snap.screen = { w = w, h = h };
    end);
    pcall(function() snap.uiScale = rnd(_G.UIParent:GetEffectiveScale()); end);
    pcall(function() snap.client = collectClientInfo(); end);
    pcall(function() snap.wim = collectWimInfo(); end);

    local found = 0;
    for _, path in ipairs(targets) do
        local obj = resolvePath(path);
        if (obj and type(obj) == "table" and obj.GetObjectType) then
            local budget = { nodes = MAX_NODES };
            local tree = snapRegion(obj, nil, 1, budget);
            if (budget.truncated) then tree.truncated = true; end
            if (obj.wimChrome ~= nil or obj.wimChromeFailed ~= nil
                    or obj.widgets) then
                pcall(function() tree.wimState = collectWindowState(obj); end);
            end
            snap.targets[path] = tree;
            found = found + 1;
        else
            snap.targets[path] = "not found";
        end
    end

    _G.WIM3_Snapshots = _G.WIM3_Snapshots or { snaps = {} };
    local snaps = _G.WIM3_Snapshots.snaps;
    table.insert(snaps, snap);
    while (#snaps > KEPT_SNAPSHOTS) do
        table.remove(snaps, 1);
    end

    -- Capture the frame before the confirmation text can appear in it.
    pcall(_G.Screenshot);
    local resolved = found;
    _G.C_Timer.After(0.25, function()
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0WIM:|r snapshot captured ("
            ..resolved.."/"..#targets.." targets resolved) + screenshot."
            .." Build "..(BUILD_ID or "unknown")..";"
            .." data flushes to WIM3_Snapshots on /reload or logout.");
    end);
end

-- Callable from elsewhere in the addon, for example to capture a
-- frame that only exists in full while something is open.
SnapshotTarget = takeSnapshot;

RegisterSlashCommand("snap", takeSnapshot,
    L["Snapshot UI widget state for skin development: /wim snap all | <Frame.Dot.Path> (bare /wim snap lists the arguments)."]);
RegisterSlashCommand("snapmenu", function()
        snapNextMenu = true;
        _G.DEFAULT_CHAT_FRAME:AddMessage(
            "|cff69ccf0WIM:|r the next modern context menu will be"
            .." snapshotted while open (open the minimap right-click menu).");
    end,
    L["Snapshot the next modern context menu while it is open."]);
