--imports
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local tostring = tostring;
local string = string;
local table = table;
local type = type;
local math = math;
local select = select;
local pcall = pcall;
local unpack = unpack;

-- Defined before the setfenv: C_Texture.GetAtlasInfo resolves the
-- mixin of its returned struct against the calling function's
-- environment, and WIM's namespace cannot see Vector2DMixin (the same
-- constraint Modules/Menu.lua works around).
local C_Texture = C_Texture;
local function getAtlasInfo(name)
    if (C_Texture and C_Texture.GetAtlasInfo) then
        return C_Texture.GetAtlasInfo(name);
    end
end

--set namespace
setfenv(1, WIM);

-- ---------------------------------------------------------------------------
-- Native Settings integration (Options > AddOns > WIM).
--
-- WIM's options live entirely inside the game's native Settings panel.
-- ---------------------------------------------------------------------------

options.creditsText = {
    "Pazza <Bronzebeard-US>\n\n",
    "MysticalOS\nHumfras\nSylvaanar\n\nStewarta <Emerald Dream - EU>\n\nAvraelore <Moon Guard - US> - Modern skin & options\n\nAstaldo <Bronzebeard - EU>\nZeke <Coilfang - US>\nMorphieus <Spinebreaker>\nNachonut <Bronzebeard - US>\n\nChiaki <Frostwolf - EU> - deDE\n"..
    "BlueNyx <bluenyx@gmail.com> - koKR\nStingerSoft <stingersoft@iti.lt> - ruRU\nJunxian <junxian1121@hotmail.com> - zhCN & zhTW\nWoopy <Woopy#1685 - NA> - esES & esMX\n\n\nAstrosloth and Zezerat are noobs! ;-p"
};

-- Verbose trace of option writes ("/wim debug 2"): every committed
-- setting change is reported to the on-disk debug log, so a capture
-- shows what was changed and when.
function options.DebugSetting(source, key, value)
    if ((debugLevel or 0) >= 2) then
        tPrint("SETTING ["..source.."] "..tostring(key).." = "..tostring(value));
    end
end

-- The whole file is inert on clients without the modern Settings API (the
-- TOC also targets older interfaces).
if (not _G.Settings
    or not _G.Settings.RegisterVerticalLayoutCategory
    or not _G.Settings.RegisterProxySetting
    or not _G.Settings.RegisterAddOnCategory) then
    return;
end

local Settings = _G.Settings;

-- The search results list titles each hit with its category's qualified
-- name, formatted through this global string. Older clients ship the
-- panel code without the string, so every hit inside a subcategory
-- errors and the results never appear; the retail wording fills in.
if (_G.SETTINGS_SUBCATEGORY_FMT == nil) then
    _G.SETTINGS_SUBCATEGORY_FMT = "%s (%s)";
end

-- ---------------------------------------------------------------------------
-- Modern page registry + adapter widgets.
--
-- Pages (Sources/Options/ModernOptions.lua) register builder functions
-- here at file load; registerCategory runs them once saved variables are
-- loaded. The adapters follow the classic toolkit's binding contract: a
-- (dbTree, varName) pair written directly, then an optional valChanged
-- refresh hook. This keeps both UIs interchangeable over the same
-- settings. dbTree may be a function that returns the table; the
-- pop-rules pages bind to the currently selected state that way.
-- ---------------------------------------------------------------------------

local pageBuilders = {};
function options.RegisterModernPage(builder)
    table.insert(pageBuilders, builder);
end

local ui = {};
options.ModernUI = ui;

-- Every proxy setting ever created, so external db writes can update
-- whatever the panel currently displays. Native controls only re-read
-- their getter when a page is displayed; NotifyUpdate makes each visible
-- control re-read immediately. Non-UI writers (the filter editor's
-- OnHide, the color picker) call this after their own writes.
local allSettings = {};
local extraRefreshers = {};

-- Custom element rows (previews, swatches, browsers) register a refresh
-- function here so they follow external changes like proxy settings do.
function options.RegisterModernRefresh(fn)
    table.insert(extraRefreshers, fn);
end

function options.NotifyModernSettings()
    for i = 1, #allSettings do
        local setting = allSettings[i];
        if (setting.NotifyUpdate) then
            setting:NotifyUpdate();
        end
    end
    for i = 1, #extraRefreshers do
        extraRefreshers[i]();
    end
end

-- Mixin for WIM's custom settings-list element templates (see
-- ModernSettings.xml). It must live in _G because XML mixin resolution
-- cannot see the WIM namespace. Init forwards to the initializer data's
-- onInit, so each row kind defines its own content. The settings list
-- pools the rows, so onInit must rebind data on every call and build
-- widgets only once.
_G.WIM3SettingsElementMixin = {};
function _G.WIM3SettingsElementMixin:OnLoad()
end
function _G.WIM3SettingsElementMixin:Init(initializer)
    local data = (initializer.GetData and initializer:GetData()) or initializer.data;
    self.data = data;
    if (data and data.onInit) then
        data.onInit(self, data);
    end
end
function _G.WIM3SettingsElementMixin:Release()
    -- Only the holder's CURRENT row may hide it: this frame's pointer
    -- goes stale when its old holder is re-attached to another row of
    -- the same template, and hiding through the stale pointer blanks
    -- a panel still on screen.
    if (self.wimHolder and self.wimHolder.wimRow == self) then
        self.wimHolder:Hide();
    end
end

-- Attach a persistent holder to a pooled element row. Rows that share a
-- template share a frame pool. When a row scrolls out, its frame is
-- released with the old holder still parented. If that frame is reused
-- for a different row of the same template, two holders end up anchored
-- to one frame and render on top of each other. Detaching the previous
-- holder before attaching prevents that. The ownership check (wimRow)
-- stops a stale pointer from detaching a holder that has since moved to
-- another visible row.
function options.AttachRowHolder(row, holder)
    local previous = row.wimHolder;
    if (previous and previous ~= holder and previous.wimRow == row) then
        previous:Hide();
        previous:ClearAllPoints();
        previous:SetParent(nil);
        previous.wimRow = nil;
    end
    row.wimHolder = holder;
    holder.wimRow = row;
    holder:SetParent(row);
    holder:ClearAllPoints();
    holder:SetAllPoints(row);
    holder:Show();
end

-- Proxy-setting variables just need to be unique; they are never persisted
-- (the value lives in WIM's own db), so a counter is sufficient.
local settingCount = 0;
local function nextVariable()
    settingCount = settingCount + 1;
    return "WIM_SETTING_"..settingCount;
end

local function resolveTree(dbTree)
    if (type(dbTree) == "function") then
        return dbTree();
    end
    return dbTree;
end

-- Every registered page, so folder pages can mirror their children's
-- rows as collapsible sections (see mirrorFolderSections).
local subcategoryRecords = {};

function ui.Subcategory(parentCategory, name, description)
    local category, layout = Settings.RegisterVerticalLayoutSubcategory(parentCategory, name);
    table.insert(subcategoryRecords, {
        parent = parentCategory,
        category = category,
        layout = layout,
        name = name,
        description = description,
    });
    if (description and Settings.AssignTutorialToCategory) then
        Settings.AssignTutorialToCategory(category, description);
    end
    return category, layout;
end

function ui.Header(layout, name, tooltip)
    layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(name, tooltip));
end

-- shownPredicate hides the row (and keeps it out of search) while it
-- returns false. The button widens to fit a translation longer than
-- the template's fixed width.
function ui.Button(layout, name, buttonText, onClick, tooltip, enabledPredicate, shownPredicate)
    if (not _G.CreateSettingsButtonInitializer) then
        return nil;
    end
    local init = _G.CreateSettingsButtonInitializer(
        name, buttonText, onClick, tooltip, true);
    if (enabledPredicate and init.AddModifyPredicate) then
        init:AddModifyPredicate(enabledPredicate);
    end
    if (shownPredicate and init.AddShownPredicate) then
        init:AddShownPredicate(shownPredicate);
    end
    local origInitFrame = init.InitFrame;
    init.InitFrame = function(self, frame)
        origInitFrame(self, frame);
        local button = frame and frame.Button;
        if (not button) then
            return;
        end
        -- Some clients' settings code ignores modify predicates on
        -- button rows; enforcing the state as the row initializes
        -- covers them all.
        if (enabledPredicate and button.SetEnabled) then
            button:SetEnabled(enabledPredicate() and true or false);
        end
        local text = button.GetFontString and button:GetFontString();
        local textWidth = text and text:GetStringWidth() or 0;
        if (not button.wimStockWidth) then
            button.wimStockWidth = button:GetWidth();
        end
        button:SetWidth(math.max(button.wimStockWidth, textWidth + 40));
    end;
    layout:AddInitializer(init);
    return { init = init };
end

function ui.Checkbox(category, name, default, dbTree, varName, tooltip, valChanged)
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Boolean, name, default and true or false,
        function() return resolveTree(dbTree)[varName] and true or false; end,
        function(value)
            value = value and true or false;
            resolveTree(dbTree)[varName] = value;
            options.DebugSetting("modern", varName, value);
            if (valChanged) then valChanged(value); end
        end);
    table.insert(allSettings, setting);
    local init = Settings.CreateCheckbox(category, setting, tooltip);
    return { setting = setting, init = init };
end

-- Greys a control out while its parent checkbox is off. This is the
-- native version of the classic toolkit's nested checkboxes. An optional
-- predicate overrides the default rule, "enabled while parent is
-- checked".
function ui.DependsOn(child, parent, predicate)
    if (child and parent and child.init and child.init.SetParentInitializer) then
        child.init:SetParentInitializer(parent.init, predicate or function()
            return parent.setting:GetValue();
        end);
    end
end

-- A custom element row inside a vertical layout page, created from one
-- of the templates in ModernSettings.xml. The template's fixed height is
-- the row's extent in the list, unless data.extent overrides it: the
-- settings list asks the initializer first, so one template can serve
-- panels of different sizes. data.panel registers through
-- CreatePanelInitializer, the factory the game's own preview and color
-- panels use. If the client lacks the element-initializer API, the row is
-- skipped and the page omits the custom content.
function ui.Custom(layout, template, data)
    if (not Settings.CreateElementInitializer) then
        return;
    end
    local init;
    if (data and data.panel and Settings.CreatePanelInitializer) then
        init = Settings.CreatePanelInitializer(template, data);
    else
        init = Settings.CreateElementInitializer(template, data);
    end
    if (data and data.getExtent) then
        -- Measured at display time, so rows sized by localized text ask
        -- for the height that text actually needs.
        init.GetExtent = data.getExtent;
    elseif (data and data.extent) then
        init.GetExtent = function() return data.extent; end;
    end
    -- Custom rows have no setting name for the search to index, so
    -- they name their contents (the grid's chat types, a list's
    -- column labels) in data.searchTags.
    if (data and data.searchTags and init.AddSearchTags) then
        init:AddSearchTags(unpack(data.searchTags));
    end
    layout:AddInitializer(init);
    return init;
end

-- The child plate the game's own preview areas use (the nameplate
-- preview's construction): the options_frame_child atlas, with the
-- standard PREVIEW tag when requested. The framed backdrop is the
-- fallback for clients without the atlas. Returns whether the atlas was
-- used.
function options.AddOptionsPlate(frame, previewTag)
    local hasAtlas = getAtlasInfo("options_frame_child");
    if (hasAtlas) then
        if (not frame.wimPlate) then
            frame.wimPlate = frame:CreateTexture(nil, "BACKGROUND");
            frame.wimPlate:SetAtlas("options_frame_child");
            frame.wimPlate:SetAllPoints();
        end
        if (previewTag and not frame.wimPlateTag) then
            frame.wimPlateTag = frame:CreateFontString(nil, "OVERLAY",
                "GameFontHighlightSmall");
            frame.wimPlateTag:SetPoint("TOPLEFT", 10, -10);
            frame.wimPlateTag:SetText(_G.PREVIEW or L["Preview"]);
        end
    else
        options.AddFramedBackdrop(frame);
    end
    return hasAtlas and true or false;
end

-- ---------------------------------------------------------------------------
-- Shared plumbing for the custom rows (lists, grids, panels).
-- ---------------------------------------------------------------------------

-- Tooltips on custom-row widgets go through the panel's own tooltip,
-- gated like WIM's other tooltips. A nil title makes the body the
-- whole tooltip.
function options.RowTooltip(owner, title, body)
    if (db.showToolTips ~= true) then
        return;
    end
    local tip = _G.SettingsTooltip or _G.GameTooltip;
    tip:SetOwner(owner, "ANCHOR_RIGHT");
    if (title) then
        tip:SetText(title, nil, nil, nil, nil, false);
        if (body) then
            tip:AddLine(body, 1, 1, 1, true);
        end
    else
        tip:SetText(body, nil, nil, nil, nil, true);
    end
    tip:Show();
end

function options.HideRowTooltip()
    (_G.SettingsTooltip or _G.GameTooltip):Hide();
end

-- The bordered panel the game's Graphics Quality block uses: the
-- OptionsFrame nine-slice, with the hairline backdrop as the fallback
-- where the nine-slice utility is missing. Returns whether the
-- nine-slice was applied.
-- The OptionsFrame kit draws its border line this far inside the
-- frame's own rect (the corner art carries a transparent margin), so
-- anything meant to sit inside the visible border measures from here.
options.FRAME_INSET = 16;

function options.AddBorderedPanel(frame, fill)
    local bordered = false;
    if (_G.NineSliceUtil and _G.NineSliceUtil.ApplyUniqueCornersLayout) then
        bordered = pcall(_G.NineSliceUtil.ApplyUniqueCornersLayout, frame, "OptionsFrame") and true or false;
    end
    if (not bordered) then
        options.AddFramedBackdrop(frame);
    elseif (fill) then
        -- The nine-slice draws only the border; callouts that hold
        -- text want a dark ground behind it. The ground reaches just
        -- under the border line (drawn above it), so no gap shows
        -- between the two.
        local inset = options.FRAME_INSET - 2;
        local ground = frame:CreateTexture(nil, "BACKGROUND", nil, -8);
        ground:SetColorTexture(0.07, 0.07, 0.09, 0.9);
        ground:SetPoint("TOPLEFT", inset, -inset);
        ground:SetPoint("BOTTOMRIGHT", -inset, inset);
    end
    return bordered;
end

-- One scroll pane construction for the list holders. The retail
-- template ships its own scrollbar whose default anchors do not line
-- up with the holder borders; re-anchoring it against the border keeps
-- the arrows the same distance from the top and bottom edges.
function options.MakeScrollPane(border, fallbackName, framed, extraTop)
    local ok, scroll = pcall(CreateFrame, "ScrollFrame", nil, border, "ScrollFrameTemplate");
    if (not ok or not scroll) then
        scroll = CreateFrame("ScrollFrame", fallbackName, border, "UIPanelScrollFrameTemplate");
    end
    -- Inside the nine-slice, clearances measure from the visible border
    -- line, not the frame rect; the flat plate needs far less.
    local pad = framed and (options.FRAME_INSET + 10) or 8;
    local left = framed and (options.FRAME_INSET + 8) or 4;
    local top = pad + (extraTop or 0);
    -- The bar lives in its own gutter frame inside the border, clear of
    -- the frame art on both scrollbar paths (the retail template's bar
    -- and the slim bar the older clients get).
    local gutterRight = framed and (options.FRAME_INSET + 8) or 6;
    local gutter = CreateFrame("Frame", nil, border);
    gutter:SetWidth(22);
    gutter:SetPoint("TOPRIGHT", border, "TOPRIGHT", -gutterRight, -top);
    gutter:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -gutterRight, pad);
    if (not HasPortraitPanelArt()) then
        AttachMinimalScrollBar(scroll, gutter);
    elseif (scroll.ScrollBar) then
        scroll.ScrollBar:ClearAllPoints();
        scroll.ScrollBar:SetPoint("TOPRIGHT", gutter, "TOPRIGHT", 0, 0);
        scroll.ScrollBar:SetPoint("BOTTOMRIGHT", gutter, "BOTTOMRIGHT", 0, 0);
    end
    scroll.wimLeftInset = left;
    scroll:SetPoint("TOPLEFT", left, -top);
    scroll:SetPoint("BOTTOMRIGHT", gutter, "BOTTOMLEFT", -4, 0);
    local content = CreateFrame("Frame", nil, scroll);
    content:SetSize(540, 1);
    scroll:SetScrollChild(content);
    scroll:SetScript("OnSizeChanged", function(self, w)
        if (w and w > 0) then
            content:SetWidth(w);
        end
    end);
    return scroll, content;
end

-- A persistent list holder: the hidden frame that is re-parented into a
-- pooled row, its bordered panel (holder.border, the same nine-slice
-- the situation rules use, or the flat plate with spec.plate), and a
-- scroll pane inside it (holder.scroll, holder.content) unless
-- spec.noScroll. The caller assigns holder.RefreshList; it re-runs on
-- external changes while the holder is on screen.
-- spec.anchorBorder(border, holder) replaces the standard 20px side
-- insets.
function options.MakeListHolder(spec)
    spec = spec or {};
    local holder = CreateFrame("Frame");
    holder:Hide();
    local border = CreateFrame("Frame", nil, holder);
    if (spec.anchorBorder) then
        spec.anchorBorder(border, holder);
    else
        border:SetPoint("TOPLEFT", 20, -4);
        border:SetPoint("BOTTOMRIGHT", -20, 4);
    end
    local framed = false;
    if (spec.plate or spec.previewTag) then
        options.AddOptionsPlate(border, spec.previewTag);
    else
        framed = options.AddBorderedPanel(border);
    end
    holder.border = border;
    holder.framed = framed;
    if (not spec.noScroll) then
        holder.scroll, holder.content = options.MakeScrollPane(border, spec.scrollName, framed, spec.scrollTop);
    end
    options.RegisterModernRefresh(function()
        if (holder.RefreshList and holder:IsVisible()) then
            holder:RefreshList();
        end
    end);
    return holder;
end

-- Fixed-height rows stacked in a holder's content frame, created on
-- demand by build(row, index) and reused across refreshes. Row(index)
-- returns the row; Fit(count) sizes the content to the pane and the
-- row count and hides the rows beyond it.
function options.MakeRowStack(holder, rowHeight, frameType, build)
    local content = holder.content;
    local rows = {};
    local stack = { rows = rows };
    function stack.Row(index)
        local row = rows[index];
        if (row) then
            return row;
        end
        row = CreateFrame(frameType or "Frame", nil, content);
        row:SetHeight(rowHeight);
        row:SetPoint("TOPLEFT", 0, -(index - 1) * rowHeight);
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0);
        build(row, index);
        rows[index] = row;
        return row;
    end
    function stack.Fit(count)
        local w = holder.scroll:GetWidth();
        if (w and w > 0) then
            content:SetWidth(w);
        end
        content:SetHeight(count * rowHeight);
        for i = count + 1, #rows do
            rows[i]:Hide();
        end
    end
    return stack;
end

-- The init shared by holder-backed rows: find or build the holder for
-- the row's data, seat it in the pooled row, and refresh it.
function options.HolderRowInit(getHolder)
    return function(row, data)
        local holder = getHolder(data);
        options.AttachRowHolder(row, holder);
        if (holder.RefreshList) then
            holder:RefreshList();
        end
    end;
end

-- The wrapped height of a font string at a given width, with the
-- string's own width restored afterwards. Extents measured at display
-- time use it so localized text gets the room it needs.
function options.WrappedHeight(fontString, width)
    fontString:SetWidth(width);
    local height = fontString:GetStringHeight() or 0;
    fontString:SetWidth(0);
    return height;
end

-- Selectable list rows drawn the way the Settings category list draws
-- them: the grey fading wash on hover, and the gold wash with white
-- text while selected. Selection keeps going through LockHighlight and
-- UnlockHighlight, so callers are unchanged. Where the atlases are
-- missing the quest-title highlight serves both roles, as before.
function options.SkinListRow(button, text)
    if (GetAtlasInfo("Options_List_Hover")) then
        button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8");
        local highlight = button:GetHighlightTexture();
        highlight:SetAtlas("Options_List_Hover");
        highlight:SetTexCoord(0, 1, 0, 1);
        highlight:SetBlendMode("BLEND");
        highlight:SetVertexColor(1, 1, 1);
    else
        button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
    end
    if (not GetAtlasInfo("Options_List_Active")) then
        return;
    end
    local selected = button:CreateTexture(nil, "ARTWORK");
    selected:SetAllPoints();
    selected:SetAtlas("Options_List_Active");
    selected:SetTexCoord(0, 1, 0, 1);
    selected:Hide();
    local restColor = text and { text:GetTextColor() };
    button.LockHighlight = function()
        selected:Show();
        if (text) then
            text:SetTextColor(1, 1, 1);
        end
    end;
    button.UnlockHighlight = function()
        selected:Hide();
        if (text and restColor) then
            text:SetTextColor(restColor[1], restColor[2], restColor[3]);
        end
    end;
end

-- Small up/down buttons in the minimal scrollbar's stepper art, with
-- the addon's own arrows where the atlases are missing.
function options.StyleStepper(button, direction)
    local atlas = (direction == "up") and "minimal-scrollbar-arrow-top" or "minimal-scrollbar-arrow-bottom";
    if (GetAtlasInfo(atlas)) then
        button:SetNormalAtlas(atlas);
        button:SetPushedAtlas(GetAtlasInfo(atlas.."-down") and (atlas.."-down") or atlas);
        button:SetHighlightAtlas(GetAtlasInfo(atlas.."-over") and (atlas.."-over") or atlas, "BLEND");
    else
        local file = "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\"..direction;
        button:SetNormalTexture(file);
        button:SetHighlightTexture(file, "ADD");
    end
end

function ui.Slider(category, name, default, minValue, maxValue, step, dbTree, varName, tooltip, valChanged, label)
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Number, name, default,
        function() return resolveTree(dbTree)[varName] or default; end,
        function(value)
            resolveTree(dbTree)[varName] = value;
            options.DebugSetting("modern", varName, value);
            if (valChanged) then valChanged(value); end
        end);
    table.insert(allSettings, setting);
    local sliderOptions = Settings.CreateSliderOptions(minValue, maxValue, step);
    sliderOptions:SetLabelFormatter(_G.MinimalSliderWithSteppersMixin.Label.Right,
        label or function(value) return tostring(value); end);
    local init = Settings.CreateSlider(category, setting, sliderOptions, tooltip);
    return { setting = setting, init = init };
end

-- items: array of { text=..., value=..., tooltip=... }, or a function
-- returning one (evaluated on every open, for dynamic lists like
-- LibSharedMedia sounds).
function ui.Dropdown(category, name, default, items, dbTree, varName, tooltip, valChanged)
    local varType = (type(default) == "number")
                    and Settings.VarType.Number or Settings.VarType.String;
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        varType, name, default,
        function()
            local value = resolveTree(dbTree)[varName];
            if (value == nil) then value = default; end
            return value;
        end,
        function(value)
            resolveTree(dbTree)[varName] = value;
            options.DebugSetting("modern", varName, value);
            if (valChanged) then valChanged(value); end
        end);
    table.insert(allSettings, setting);
    local function getOptions()
        local container = Settings.CreateControlTextContainer();
        local list = items;
        if (type(list) == "function") then list = list(); end
        for i = 1, #list do
            container:Add(list[i].value, list[i].text, list[i].tooltip);
        end
        return container:GetData();
    end
    local init = Settings.CreateDropdown(category, setting, getOptions, tooltip);
    return { setting = setting, init = init };
end

-- The sound dropdown row's frame mixin: the stock dropdown control plus
-- a speaker button that previews the selected sound. Art prefers the
-- voice-preview speaker from character customization, then the chat
-- frame's speaker glyph, then a plain native text button on clients
-- with neither atlas. The mixin must live in _G for XML resolution.
_G.WIM3SettingsSoundDropdownControlMixin = {};

function _G.WIM3SettingsSoundDropdownControlMixin:WIMCreatePreview()
    -- No highlight texture: an additive copy of the icon layered over
    -- the pushed art doubles the image while the button is held. The
    -- pushed atlas carries the click feedback; hovering brightens the
    -- icon instead.
    local btn;
    local atlasIcon = false;
    if (getAtlasInfo("charactercreate-customize-speakeronbutton")) then
        btn = CreateFrame("Button", nil, self);
        btn:SetSize(28, 28);
        btn:SetNormalAtlas("charactercreate-customize-speakeronbutton");
        btn:SetPushedAtlas("charactercreate-customize-speakeronbutton-down");
        atlasIcon = true;
        options.DebugSetting("sound-row", "preview-art", "charcreate-atlas");
    elseif (getAtlasInfo("chatframe-button-icon-speaker-on")) then
        btn = CreateFrame("Button", nil, self);
        btn:SetSize(24, 24);
        btn:SetNormalAtlas("chatframe-button-icon-speaker-on");
        btn:SetPushedAtlas("chatframe-button-icon-speaker-on");
        atlasIcon = true;
        options.DebugSetting("sound-row", "preview-art", "chatframe-atlas");
    else
        btn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
        btn:SetText(_G.PREVIEW or L["Preview"]);
        btn:SetSize((btn.GetTextWidth and btn:GetTextWidth() or 50) + 24, 22);
        options.DebugSetting("sound-row", "preview-art", "text-button");
    end
    btn.wimAtlasIcon = atlasIcon;
    if (atlasIcon) then
        btn:GetNormalTexture():SetVertexColor(.85, .85, .85);
    end
    btn:SetScript("OnEnter", function(b)
        if (atlasIcon) then
            b:GetNormalTexture():SetVertexColor(1, 1, 1);
        end
        local tip = _G.SettingsTooltip or _G.GameTooltip;
        tip:SetOwner(b, "ANCHOR_RIGHT");
        tip:SetText(_G.PREVIEW or L["Preview"]);
        tip:Show();
    end);
    btn:SetScript("OnLeave", function(b)
        if (atlasIcon) then
            b:GetNormalTexture():SetVertexColor(.85, .85, .85);
        end
        (_G.SettingsTooltip or _G.GameTooltip):Hide();
    end);
    return btn;
end

local function setPreviewEnabled(btn, enabled)
    enabled = enabled and true or false;
    btn:SetEnabled(enabled);
    btn:SetAlpha(enabled and 1 or .5);
    if (btn.wimAtlasIcon) then
        local tex = btn:GetNormalTexture();
        if (tex and tex.SetDesaturated) then
            tex:SetDesaturated(not enabled);
        end
    end
end

-- Seats the preview button after the dropdown's stepper arrow, which
-- hangs outside the Control frame's own width (the dropdown is
-- centered inside it), so the frame's RIGHT edge lands under the arrow.
local function seatPreviewButton(row, initializer)
    if (not row.WIMPreview) then
        row.WIMPreview = row:WIMCreatePreview();
    end
    local btn = row.WIMPreview;
    btn:ClearAllPoints();
    local anchorTo = row.Control.IncrementButton or row.Control.Dropdown or row.Control;
    btn:SetPoint("LEFT", anchorTo, "RIGHT", 4, 0);
    btn:SetFrameLevel(row.Control:GetFrameLevel() + 2);
    local data = initializer.data;
    btn:SetScript("OnClick", function()
        if (data and data.wimPreview) then
            data.wimPreview();
        end
    end);
    btn:SetShown(data and data.wimPreview and true or false);
end

function _G.WIM3SettingsSoundDropdownControlMixin:Init(initializer)
    _G.SettingsDropdownControlMixin.Init(self, initializer);
    -- Seat the control on the checkbox column: stock dropdown rows
    -- start 32px right of checkbox rows (CENTER -48 vs -80, the game's
    -- own geometry on retail and era alike), which reads as
    -- misalignment beside the paired enable checkboxes here.
    self.Control:ClearAllPoints();
    self.Control:SetPoint("LEFT", self, "CENTER", -80, 3);
    seatPreviewButton(self, initializer);
    -- The base Init runs EvaluateState before the button exists on a
    -- frame's first acquisition, so sync the enabled state again here.
    self:WIMUpdatePreviewState();
end

function _G.WIM3SettingsSoundDropdownControlMixin:WIMUpdatePreviewState()
    if (self.WIMPreview) then
        setPreviewEnabled(self.WIMPreview, self:IsEnabled());
    end
end

function _G.WIM3SettingsSoundDropdownControlMixin:EvaluateState()
    _G.SettingsDropdownControlMixin.EvaluateState(self);
    self:WIMUpdatePreviewState();
end

-- The one-line sound row: the enable checkbox and the sound dropdown
-- share the row, the way the game's Lock Action Bars row pairs a
-- checkbox with a dropdown, and the speaker button follows the
-- dropdown. The stock checkbox-dropdown mixin does the work; this
-- derived mixin only adds the button.
_G.WIM3SettingsSoundRowMixin = {};
_G.WIM3SettingsSoundRowMixin.WIMCreatePreview = _G.WIM3SettingsSoundDropdownControlMixin.WIMCreatePreview;

function _G.WIM3SettingsSoundRowMixin:Init(initializer)
    _G.SettingsCheckboxDropdownControlMixin.Init(self, initializer);
    seatPreviewButton(self, initializer);
    self:WIMUpdatePreviewState();
end

function _G.WIM3SettingsSoundRowMixin:WIMUpdatePreviewState()
    if (self.WIMPreview) then
        setPreviewEnabled(self.WIMPreview,
            self:IsEnabled() and self.Checkbox and self.Checkbox:GetChecked());
    end
end

function _G.WIM3SettingsSoundRowMixin:EvaluateState()
    _G.SettingsCheckboxDropdownControlMixin.EvaluateState(self);
    self:WIMUpdatePreviewState();
end

-- Layout lookup for a category this file registered (fallback: the
-- panel's own category-to-layout map).
local function layoutForCategory(category)
    for i = 1, #subcategoryRecords do
        if (subcategoryRecords[i].category == category) then
            return subcategoryRecords[i].layout;
        end
    end
    local panel = _G.SettingsPanel;
    return panel and panel.GetLayout and panel:GetLayout(category);
end

-- A dropdown whose row carries the speaker preview button. Built as an
-- element initializer on the derived template: the data table carries
-- the same setting/options/tooltip fields the stock dropdown row reads,
-- so the frame machinery is untouched, while the initializer is a plain
-- object this file fully owns. Setting-row initializers instead cross
-- the secure Settings boundary as private-mixin objects, and template
-- patches on those proved unreliable; element initializers are the path
-- every working custom row here already uses.
function ui.SoundDropdown(category, name, default, items, dbTree, varName, tooltip, previewFunc)
    if (not Settings.CreateElementInitializer
        or not Settings.CreateSettingInitializerData) then
        return ui.Dropdown(category, name, default, items, dbTree, varName, tooltip);
    end
    local varType = (type(default) == "number")
                    and Settings.VarType.Number or Settings.VarType.String;
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        varType, name, default,
        function()
            local value = resolveTree(dbTree)[varName];
            if (value == nil) then value = default; end
            return value;
        end,
        function(value)
            resolveTree(dbTree)[varName] = value;
            options.DebugSetting("modern", varName, value);
        end);
    table.insert(allSettings, setting);
    local function getOptions()
        local container = Settings.CreateControlTextContainer();
        local list = items;
        if (type(list) == "function") then list = list(); end
        for i = 1, #list do
            container:Add(list[i].value, list[i].text, list[i].tooltip);
        end
        return container:GetData();
    end
    local data = Settings.CreateSettingInitializerData(setting, getOptions, tooltip);
    data.wimPreview = previewFunc and function()
        previewFunc(setting:GetValue());
    end or nil;
    local init = Settings.CreateElementInitializer(
        "WIM3SettingsSoundDropdownControlTemplate", data);
    if (init.AddSearchTags) then
        init:AddSearchTags(name);
    end
    local layout = layoutForCategory(category);
    if (layout) then
        layout:AddInitializer(init);
    end
    options.DebugSetting("sound-row", varName, layout and "added" or "no-layout");
    return { setting = setting, init = init };
end

-- A sound on one row: enable checkbox, sound dropdown, preview button.
-- Returns nil where the client lacks the checkbox-dropdown row, so the
-- caller can fall back to the two-row form. The returned control's
-- setting is the enable flag, so DependsOn and the expandable sections
-- treat the row like a checkbox.
function ui.SoundRow(category, name, tooltip, dbTree, flagKey, flagDefault, soundKey, soundDefault, items, previewFunc)
    if (not _G.SettingsCheckboxDropdownControlMixin
        or not Settings.CreateElementInitializer) then
        return nil;
    end
    local flagSetting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Boolean, name, flagDefault and true or false,
        function() return resolveTree(dbTree)[flagKey] and true or false; end,
        function(value)
            value = value and true or false;
            resolveTree(dbTree)[flagKey] = value;
            options.DebugSetting("modern", flagKey, value);
        end);
    table.insert(allSettings, flagSetting);
    soundDefault = soundDefault or "";
    local soundSetting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.String, name, soundDefault,
        function()
            local value = resolveTree(dbTree)[soundKey];
            if (value == nil) then value = soundDefault; end
            return value;
        end,
        function(value)
            resolveTree(dbTree)[soundKey] = value;
            options.DebugSetting("modern", soundKey, value);
        end);
    table.insert(allSettings, soundSetting);
    local function getOptions()
        local container = Settings.CreateControlTextContainer();
        local list = items;
        if (type(list) == "function") then list = list(); end
        for i = 1, #list do
            container:Add(list[i].value, list[i].text, list[i].tooltip);
        end
        return container:GetData();
    end
    -- The same fields the stock checkbox-dropdown initializer carries.
    -- The row's one tooltip serves the checkbox and the picker alike,
    -- so it names both.
    local picker = L["The sound to play. The speaker button plays a preview."];
    local rowTooltip = tooltip and (tooltip.."\n\n"..picker) or picker;
    local data = {
        name = name,
        tooltip = rowTooltip,
        cbSetting = flagSetting,
        cbLabel = name,
        cbTooltip = rowTooltip,
        dropdownSetting = soundSetting,
        dropdownOptions = getOptions,
        dropDownLabel = L["Sound"],
        dropDownTooltip = rowTooltip,
    };
    data.wimPreview = previewFunc and function()
        previewFunc(soundSetting:GetValue());
    end or nil;
    local init = Settings.CreateElementInitializer("WIM3SettingsSoundRowTemplate", data);
    if (init.AddSearchTags) then
        init:AddSearchTags(name, L["Sound"]);
    end
    local layout = layoutForCategory(category);
    if (layout) then
        layout:AddInitializer(init);
    end
    return { setting = flagSetting, soundSetting = soundSetting, init = init };
end

-- A multiselect dropdown, the way the game's own options render
-- bitfield settings: a standard dropdown whose menu rows are checkboxes
-- and whose button text lists the selection. items is an ordered array
-- of { key=..., text=..., tooltip=... }. The selection is stored as
-- named booleans in resolveTree(dbTree)[varName]. The proxy setting's
-- Number value is the items' bitmask (bit i for the i-th item), the
-- encoding the stock dropdown checkbox rows toggle.
function ui.MultiDropdown(category, name, items, dbTree, varName, tooltip, noneText, valChanged, defaultFields)
    local function fieldTable()
        local tree = resolveTree(dbTree);
        local fields = tree[varName];
        if (type(fields) ~= "table") then
            fields = {};
            tree[varName] = fields;
        end
        return fields;
    end
    local function maskOf(fields)
        local mask = 0;
        for i = 1, #items do
            if (fields[items[i].key]) then
                mask = mask + 2^(i - 1);
            end
        end
        return mask;
    end
    local function getMask()
        return maskOf(fieldTable());
    end
    local function setMask(mask)
        local fields = fieldTable();
        local remainder = mask;
        for i = 1, #items do
            local selected = (remainder % 2) == 1;
            fields[items[i].key] = selected or nil;
            remainder = (remainder - (remainder % 2)) / 2;
        end
        options.DebugSetting("modern", varName, mask);
        if (valChanged) then valChanged(); end
    end
    -- The registered default is what the panel's Defaults button
    -- restores, so it is the shipped field set, not an empty one.
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Number, name, maskOf(defaultFields or {}), getMask, setMask);
    table.insert(allSettings, setting);
    local function getOptions()
        local container = Settings.CreateControlTextContainer();
        for i = 1, #items do
            container:AddCheckbox(i, items[i].text, items[i].tooltip);
        end
        return container:GetData();
    end
    local init = Settings.CreateDropdown(category, setting, getOptions, tooltip);
    -- Nothing selected reads as its own state; otherwise nil defers
    -- to the control's standard selection-listing text.
    init.getSelectionTextFunc = function(selections)
        if (#selections == 0) then
            return noneText;
        end
        return nil;
    end;
    return { setting = setting, init = init };
end

-- A checkbox backed by arbitrary get/set closures instead of a db key,
-- for derived states such as the known-senders filter switch.
function ui.CustomCheckbox(category, name, default, getFunc, setFunc, tooltip)
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Boolean, name, default and true or false,
        function() return getFunc() and true or false; end,
        function(value)
            value = value and true or false;
            setFunc(value);
            options.DebugSetting("modern", name, value);
        end);
    table.insert(allSettings, setting);
    local init = Settings.CreateCheckbox(category, setting, tooltip);
    return { setting = setting, init = init };
end

-- A registered setting with no list row of its own, for values rendered
-- by custom panel widgets (the situation rules). Registration is what
-- lets the panel's Defaults button reach them, the way the game's own
-- Graphics Quality controls stay registered behind their custom widgets.
function ui.HiddenSetting(category, name, default, getFunc, setFunc)
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Boolean, name, default and true or false,
        function() return getFunc() and true or false; end,
        function(value)
            setFunc(value and true or false);
        end);
    table.insert(allSettings, setting);
    return setting;
end

-- A dropdown backed by arbitrary get/set closures, for derived states
-- such as the history recording scope.
function ui.CustomDropdown(category, name, default, items, getFunc, setFunc, tooltip)
    local varType = (type(default) == "number")
                    and Settings.VarType.Number or Settings.VarType.String;
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        varType, name, default,
        function() return getFunc(); end,
        function(value)
            setFunc(value);
            options.DebugSetting("modern", name, value);
        end);
    table.insert(allSettings, setting);
    local function getOptions()
        local container = Settings.CreateControlTextContainer();
        local list = items;
        if (type(list) == "function") then list = list(); end
        for i = 1, #list do
            container:Add(list[i].value, list[i].text, list[i].tooltip);
        end
        return container:GetData();
    end
    local init = Settings.CreateDropdown(category, setting, getOptions, tooltip);
    return { setting = setting, init = init };
end

-- Synonym search tags on any adapter-made control.
function ui.Tags(control, ...)
    if (control and control.init and control.init.AddSearchTags) then
        control.init:AddSearchTags(...);
    end
    return control;
end

-- A collapsible section (the Accessibility-page construction): a header
-- row with an expander arrow; child rows are shown only while expanded.
-- The game's base template requires a derived mixin: it errors on click
-- unless CalculateHeight and OnExpandedChanged are supplied. The mixin
-- must live in _G for XML resolution. Falls back to a plain always-open
-- header when the client lacks the initializer.
local function updateExpandableArrow(frame, expanded)
    local button = frame and frame.Button;
    if (button and button.Right and button.Right.SetAtlas
        and getAtlasInfo("Options_ListExpand_Right_Expanded")) then
        if (expanded) then
            button.Right:SetAtlas("Options_ListExpand_Right_Expanded", true);
        else
            button.Right:SetAtlas("Options_ListExpand_Right", true);
        end
    end
end

_G.WIM3SettingsExpandableSectionMixin = {};
function _G.WIM3SettingsExpandableSectionMixin:Init(initializer)
    if (_G.SettingsExpandableSectionMixin and _G.SettingsExpandableSectionMixin.Init) then
        _G.SettingsExpandableSectionMixin.Init(self, initializer);
    end
    updateExpandableArrow(self, initializer.data and initializer.data.expanded);
    local data = initializer.data;
    local indented = data and data.wimNested;
    if (indented and data.wimHomeID) then
        local panel = _G.SettingsPanel;
        local current = panel and panel.GetCurrentCategory and panel:GetCurrentCategory();
        if (current and current.GetID and current:GetID() == data.wimHomeID) then
            indented = false;
        end
    end
    local button = self.Button;
    button:ClearAllPoints();
    if (indented) then
        button:SetPoint("TOPLEFT", 40, 0);
        button:SetPoint("TOPRIGHT", -60, 0);
    else
        button:SetPoint("TOPLEFT", 0, 0);
        button:SetPoint("TOPRIGHT", -20, 0);
    end
    local tooltip = initializer.data and initializer.data.wimTooltip;
    if (tooltip) then
        self.Button:SetScript("OnEnter", function(button)
            if (db.showToolTips == true) then
                local tip = _G.SettingsTooltip or _G.GameTooltip;
                tip:SetOwner(button, "ANCHOR_RIGHT");
                tip:SetText(tooltip, nil, nil, nil, nil, true);
                tip:Show();
            end
        end);
        self.Button:SetScript("OnLeave", function()
            (_G.SettingsTooltip or _G.GameTooltip):Hide();
        end);
    else
        self.Button:SetScript("OnEnter", nil);
        self.Button:SetScript("OnLeave", nil);
    end
end
function _G.WIM3SettingsExpandableSectionMixin:CalculateHeight()
    -- The base template's click handler sets the frame to this height.
    -- Blizzard's sections hold their children inside the frame, so their
    -- height tracks content; ours are bare headers whose children are
    -- separate rows, so the height must always equal the row's layout
    -- extent or the pooled frame shrinks inside its slot and carries the
    -- wrong height to whatever row acquires it next.
    local initializer = self.GetElementData and self:GetElementData();
    if (initializer and initializer.GetExtent) then
        return initializer:GetExtent();
    end
    return 32;
end
function _G.WIM3SettingsExpandableSectionMixin:OnExpandedChanged(expanded)
    updateExpandableArrow(self, expanded);
    if (_G.SettingsInbound and _G.SettingsInbound.RepairDisplay) then
        _G.SettingsInbound.RepairDisplay();
    end
end

function ui.Expandable(layout, name, tooltip, nested, homeCategory)
    local section = {};
    if (_G.CreateSettingsExpandableSectionInitializer) then
        local init = _G.CreateSettingsExpandableSectionInitializer(name);
        init.frameTemplate = "WIM3SettingsExpandableSectionTemplate";
        init.data.expanded = false;
        init.data.wimTooltip = tooltip;
        init.data.wimNested = nested and true or nil;
        init.data.wimHomeID = homeCategory and homeCategory.GetID and homeCategory:GetID() or nil;
        init.GetExtent = function() return 32; end;
        layout:AddInitializer(init);
        section.IsExpanded = function() return init.data.expanded and true or false; end;
        section.SetExpanded = function(expanded) init.data.expanded = expanded and true or false; end;
    else
        ui.Header(layout, name);
        section.IsExpanded = function() return true; end;
        section.SetExpanded = function() end;
    end
    section.Add = function(control)
        local init = control and (control.init or control);
        if (init and init.AddShownPredicate) then
            init:AddShownPredicate(section.IsExpanded);
        end
        return control;
    end;
    return section;
end

-- Root-page extras: the bug-report callout and the credits. Both are
-- custom element rows with persistent holders reparented on display,
-- like every other custom row.
local BUG_REPORT_URL = "https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/issues";

-- The usable row width in the settings list, for sizing wrapped text.
-- Falls back to the panel's usual width when the list is not built yet.
local function settingsListWidth()
    local panel = _G.SettingsPanel;
    local list = panel and panel.Container and panel.Container.SettingsList;
    local box = list and list.ScrollBox;
    local width = box and box:GetWidth() or 0;
    if (width <= 0) then
        width = 600;
    end
    return width;
end
options.SettingsListWidth = settingsListWidth;

local bugReportHolder;
local function ensureBugReportHolder()
    if (not bugReportHolder) then
        local holder = CreateFrame("Frame");
        holder:Hide();
        -- The same bordered panel the option lists use, seated on the
        -- native label column, with a dark ground behind the text and
        -- the contents kept clear of the frame art.
        local panel = CreateFrame("Frame", nil, holder);
        panel:SetPoint("TOPLEFT", 37, -4);
        panel:SetPoint("BOTTOMRIGHT", -37, 4);
        options.AddBorderedPanel(panel, true);

        local inset = options.FRAME_INSET + 14;
        local icon = panel:CreateTexture(nil, "ARTWORK");
        icon:SetSize(34, 34);
        icon:SetPoint("TOPLEFT", inset, -inset);
        -- The new-style alert icon is retail art; clients without the
        -- file keep the standard dialog alert icon instead of showing a
        -- missing texture.
        local alertIcon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew";
        if (_G.GetFileIDFromPath and not _G.GetFileIDFromPath(alertIcon)) then
            alertIcon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertIcon";
        end
        icon:SetTexture(alertIcon);

        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
        title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2);
        title:SetText(L["Found a bug?"]);

        local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4);
        body:SetPoint("RIGHT", -inset, 0);
        body:SetJustifyH("LEFT");
        body:SetText(L["Reports are welcome! Click below and follow the instructions in the bug report template."]);

        -- WoW cannot open a browser or write to the clipboard. The
        -- button opens the standard copy dialog with the URL
        -- pre-selected.
        local link = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate");
        link:SetSize(180, 24);
        link:SetPoint("BOTTOM", 0, inset - 4);
        link:SetText(L["Show GitHub Link"]);
        link:SetScript("OnClick", function()
            _G.StaticPopupDialogs["WIM_BUGREPORT_URL"] = {
                preferredIndex = _G.STATICPOPUP_NUMDIALOGS,
                text = L["Press Ctrl+C to copy the link, then open it in your browser."],
                button1 = _G.CLOSE,
                hasEditBox = 1,
                -- 260 is the classic GameDialog's edit box cap; a wider
                -- request makes that client widen the dialog from its
                -- stale pooled width and the box overflows the frame.
                editBoxWidth = 260,
                OnShow = function(self)
                    local name = self:GetName();
                    local editBox = self.EditBox or self.editBox
                        or (name and _G[name.."EditBox"]);
                    if (editBox) then
                        editBox:SetText(BUG_REPORT_URL);
                        editBox:HighlightText();
                        editBox:SetFocus();
                    end
                end,
                EditBoxOnTextChanged = function(self)
                    if (self:GetText() ~= BUG_REPORT_URL) then
                        self:SetText(BUG_REPORT_URL);
                        self:HighlightText();
                    end
                end,
                EditBoxOnEscapePressed = function(self) self:GetParent():Hide(); end,
                EditBoxOnEnterPressed = function(self) self:GetParent():Hide(); end,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1,
            };
            _G.StaticPopup_Show("WIM_BUGREPORT_URL");
        end);
        link:SetScript("OnEnter", function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            _G.GameTooltip:SetText(BUG_REPORT_URL, nil, nil, nil, nil, true);
            _G.GameTooltip:AddLine(L["Click to show the link for copying."], 1, 1, 1);
            _G.GameTooltip:Show();
        end);
        link:SetScript("OnLeave", function()
            _G.GameTooltip:Hide();
        end);

        holder.wimTitle = title;
        holder.wimBody = body;
        bugReportHolder = holder;
    end
    return bugReportHolder;
end

local function bugReportRowInit(row)
    options.AttachRowHolder(row, ensureBugReportHolder());
end

-- Measured from the localized text, never smaller than the template
-- height, so verbose translations get the room they need. The width
-- terms mirror the anchors above: 37px panel insets, the inset plus a
-- 34+10 icon column, and the inset again on the right.
local function bugReportExtent()
    local holder = ensureBugReportHolder();
    local inset = options.FRAME_INSET + 14;
    local body = options.WrappedHeight(holder.wimBody,
        settingsListWidth() - 74 - (inset + 44) - inset);
    local height = (inset + 4) + holder.wimTitle:GetStringHeight() + 4 + body
        + 8 + 24 + (inset - 4) + 8;
    return math.max(104, math.ceil(height));
end

local creditsHolder;
local function ensureCreditsHolder()
    if (not creditsHolder) then
        local holder = CreateFrame("Frame");
        holder:Hide();
        local creditsText = options.creditsText or {};

        local created = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        created:SetPoint("TOPLEFT", 37, -6);
        created:SetText(L["Created By:"]);
        local createdText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        createdText:SetPoint("TOPLEFT", created, "BOTTOMLEFT", 0, -4);
        createdText:SetPoint("RIGHT", -37, 0);
        createdText:SetJustifyH("LEFT");
        createdText:SetText(creditsText[1] or "");

        local thanks = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        thanks:SetPoint("TOPLEFT", createdText, "BOTTOMLEFT", 0, -8);
        thanks:SetText(L["Special Thanks:"]);
        local thanksText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        thanksText:SetPoint("TOPLEFT", thanks, "BOTTOMLEFT", 0, -4);
        thanksText:SetPoint("RIGHT", -37, 0);
        thanksText:SetJustifyH("LEFT");
        thanksText:SetText(creditsText[2] or "");

        holder.wimCreated = created;
        holder.wimCreatedText = createdText;
        holder.wimThanks = thanks;
        holder.wimThanksText = thanksText;
        creditsHolder = holder;
    end
    return creditsHolder;
end

local function creditsRowInit(row)
    options.AttachRowHolder(row, ensureCreditsHolder());
end

-- The template's fixed height clipped the credits once the translator
-- list grew. Measure the wrapped text instead; the width term mirrors
-- the 37px insets above.
local function creditsExtent()
    local holder = ensureCreditsHolder();
    local width = settingsListWidth() - 74;
    local height = 6 + holder.wimCreated:GetStringHeight() + 4
        + options.WrappedHeight(holder.wimCreatedText, width) + 8
        + holder.wimThanks:GetStringHeight() + 4
        + options.WrappedHeight(holder.wimThanksText, width) + 16;
    return math.max(120, math.ceil(height));
end

-- Folder pages re-render their child pages' rows as collapsible
-- sections, so a folder is a working overview instead of a blank page.
-- AddMirroredInitializer shares the SAME initializer (and setting) with
-- the child page - nothing to keep in lockstep - and marks the mirror
-- search-ignored, so search returns one result that navigates to the
-- child page. The collapse state applies only while the folder page
-- itself is displayed (and never while a search is being typed, so
-- collapsed sections stay searchable).
local folderSections = {};

local function mirrorSectionInto(parentRec, rec)
    if (not parentRec.layout or not rec.layout or not rec.layout.GetInitializers) then
        return;
    end
    local inits = rec.layout:GetInitializers();
    if (#inits == 0) then
        return;
    end
    local section = ui.Expandable(parentRec.layout, rec.name, rec.description);
    local folderID = parentRec.category and parentRec.category.GetID
        and parentRec.category:GetID();
    local function shouldShow()
        local panel = _G.SettingsPanel;
        local box = panel and panel.SearchBox;
        local text = box and box.GetText and box:GetText();
        if (type(text) == "string" and text ~= "") then
            return true;
        end
        local current = panel and panel.GetCurrentCategory and panel:GetCurrentCategory();
        if (current and current.GetID and folderID and current:GetID() == folderID) then
            return section.IsExpanded();
        end
        return true;
    end
    -- The panel's search walks only the root and its direct children,
    -- so a page under a folder is never searched itself; its rows are
    -- found through these mirrored copies, which therefore stay
    -- searchable (a hit reads "Folder (WIM)" and opens the folder).
    for i = 1, #inits do
        local init = inits[i];
        parentRec.layout:AddInitializer(init);
        if (init.AddShownPredicate) then
            init:AddShownPredicate(shouldShow);
        end
    end
    if (folderID) then
        folderSections[folderID] = folderSections[folderID] or {};
        table.insert(folderSections[folderID], section);
    end
end

-- Choosing a search result lands on the folder page with the search
-- box cleared; expanding the folder's sections right then keeps the
-- found row on screen instead of behind a collapsed header.
local searchClearedAt = 0;
local function watchSearchNavigation()
    local panel = _G.SettingsPanel;
    if (panel and panel.SearchBox and panel.SearchBox.HookScript) then
        local previous = "";
        panel.SearchBox:HookScript("OnTextChanged", function(box)
            local text = box:GetText() or "";
            if (text == "" and previous ~= "") then
                searchClearedAt = _G.GetTime();
            end
            previous = text;
        end);
    end
    if (_G.EventRegistry and _G.EventRegistry.RegisterCallback) then
        _G.EventRegistry:RegisterCallback("Settings.CategoryChanged", function(_, category)
            local id = category and category.GetID and category:GetID();
            local sections = id and folderSections[id];
            if (not sections or (_G.GetTime() - searchClearedAt) > 1) then
                return;
            end
            for i = 1, #sections do
                sections[i].SetExpanded(true);
            end
            if (_G.SettingsInbound and _G.SettingsInbound.RepairDisplay) then
                _G.SettingsInbound.RepairDisplay();
            end
        end, options);
    end
end

local function mirrorFolderSections(rootCategory)
    for i = 1, #subcategoryRecords do
        local rec = subcategoryRecords[i];
        if (rec.parent ~= rootCategory) then
            for j = 1, #subcategoryRecords do
                if (subcategoryRecords[j].category == rec.parent) then
                    mirrorSectionInto(subcategoryRecords[j], rec);
                    break;
                end
            end
        end
    end
end

local function registerCategory()
    MigrateOptions();

    local category, layout = Settings.RegisterVerticalLayoutCategory("WIM");
    options.modernCategory = category;
    options.modernCategoryID = category:GetID();

    ui.Checkbox(category, L["Enable WIM"], true, db, "enabled", nil,
        function(value) SetEnabled(value); end);

    ui.Header(layout, L["Launcher"]);
    local minimap = ui.Checkbox(category, L["Minimap Button"],
        true, modules.MinimapIcon, "enabled", nil,
        function(value) EnableModule("MinimapIcon", value); end);
    local minimapFree = ui.Checkbox(category, L["Unlock Minimap Button"],
        false, db.minimap, "free",
        L["The button can then be dragged anywhere on the screen."],
        function() modules.MinimapIcon:OnEnable(); end);
    ui.DependsOn(minimapFree, minimap);
    ui.Checkbox(category, L["Right-Click Opens Unread"],
        false, db.minimap, "rightClickNew",
        L["Applies to the minimap button, the addon compartment entry, and data broker launchers."]);
    if (_G.AddonCompartmentFrame) then
        ui.Checkbox(category, L["Addon Compartment Entry"],
            false, modules.AddonCompartment, "enabled", nil,
            function(value) EnableModule("AddonCompartment", value); end);
    end

    ui.Header(layout, L["Menus & Tooltips"]);
    ui.Checkbox(category, L["Show WIM Tooltips"], true,
        db, "showToolTips",
        L["Shows help tooltips on WIM's windows, lists, and the custom rows of these options."]);
    ui.Checkbox(category, L["Sort Menu by Activity"], true,
        db, "menuSortActivity",
        L["WIM's launcher menus list the most recently active conversations first."]);

    ui.Header(layout, L["Report a Bug"]);
    ui.Custom(layout, "WIM3SettingsBugReportTemplate",
        { onInit = bugReportRowInit, getExtent = bugReportExtent });
    ui.Header(layout, L["Credits"]);
    ui.Custom(layout, "WIM3SettingsCreditsTemplate",
        { onInit = creditsRowInit, getExtent = creditsExtent });

    -- Build the option pages (Sources/Options/ModernOptions.lua).
    for i = 1, #pageBuilders do
        pageBuilders[i](category, ui);
    end

    mirrorFolderSections(category);
    watchSearchNavigation();

    Settings.RegisterAddOnCategory(category);

    dPrint("Modern Settings category registered (id "..tostring(options.modernCategoryID)..").");
end

-- Register once saved variables are loaded. Registration itself does not
-- read db (the proxy getter and setter run on interaction, after login),
-- but waiting for VARIABLES_LOADED keeps the category from appearing
-- before WIM works. WIM's own worker frame registered the event first
-- (TOC order), so db is already assigned when this fires. PLAYER_LOGIN
-- stays as a second fallback.
local frame = CreateFrame("Frame");
frame:RegisterEvent("VARIABLES_LOADED");
frame:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event);
    if (event == "VARIABLES_LOADED" and not db) then
        self:RegisterEvent("PLAYER_LOGIN");
        return;
    end
    registerCategory();
end);

