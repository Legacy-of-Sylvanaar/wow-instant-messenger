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
-- WIM offers two options styles: the classic standalone window
-- (Sources/Options/Options.lua) and a modern presentation inside the
-- game's native Settings panel. db.modernOptions selects which style the
-- Options entry points open (ShowOptions routes on it). The native
-- category is always registered, so users in classic mode still find WIM
-- under Options > AddOns with, at minimum, the style toggle and a button
-- that opens the classic window.
--
-- Both UIs bind to the same db keys, so they can run side by side. No
-- reload is needed to switch, and a setting changed in one appears in the
-- other on its next refresh.
-- ---------------------------------------------------------------------------

db_defaults.modernOptions = false;

-- Verbose trace of option writes ("/wim debug 2"). Both options UIs
-- report every committed setting change to the on-disk debug log, so a
-- capture shows what was changed and when. Defined before the
-- Settings-API guard below so the classic UI also logs on old clients.
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

-- The proxy setting behind the style checkbox. SetOptionsStyle routes
-- through it so the native panel stays current no matter where the flag
-- is changed.
local styleSetting;

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
-- control re-read immediately. The classic toolkit calls this after each
-- of its own writes (see notifyModern in OptionsTookKit.lua), which keeps
-- the two UIs in step while both are on screen.
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

-- The reverse direction: a modern setter re-shows the classic window's
-- visible page (classic widgets re-read db on OnShow), so a change made
-- in the native panel appears in an open classic window immediately.
local refreshOpenClassicPage;   -- forward declaration; exported below

function refreshOpenClassicPage()
    if (not options.frame or not options.frame:IsShown()) then
        return;
    end
    local container = options.frame.container;
    if (not container) then
        return;
    end
    for i = 1, select("#", container:GetChildren()) do
        local child = select(i, container:GetChildren());
        if (child.IsShown and child:IsShown()) then
            child:Hide();
            child:Show();
        end
    end
end
-- Canvas pages (which bypass the proxy adapters) call this after writing
-- db values, mirroring what the adapters do internally.
options.RefreshClassicPages = refreshOpenClassicPage;

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

function ui.Subcategory(parentCategory, name)
    return Settings.RegisterVerticalLayoutSubcategory(parentCategory, name);
end

function ui.Header(layout, name, tooltip)
    layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(name, tooltip));
end

function ui.Button(layout, name, buttonText, onClick, tooltip, enabledPredicate)
    if (_G.CreateSettingsButtonInitializer) then
        local init = _G.CreateSettingsButtonInitializer(
            name, buttonText, onClick, tooltip, true);
        if (enabledPredicate) then
            if (init.AddModifyPredicate) then
                init:AddModifyPredicate(enabledPredicate);
            end
            -- Some clients' settings code ignores modify predicates on
            -- button rows; enforcing the state as the row initializes
            -- covers them all.
            local origInitFrame = init.InitFrame;
            init.InitFrame = function(self, frame)
                origInitFrame(self, frame);
                local button = frame and frame.Button;
                if (button and button.SetEnabled) then
                    button:SetEnabled(enabledPredicate() and true or false);
                end
            end;
        end
        layout:AddInitializer(init);
    end
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
            refreshOpenClassicPage();
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

function ui.Slider(category, name, default, minValue, maxValue, step, dbTree, varName, tooltip, valChanged, label)
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Number, name, default,
        function() return resolveTree(dbTree)[varName] or default; end,
        function(value)
            resolveTree(dbTree)[varName] = value;
            options.DebugSetting("modern", varName, value);
            if (valChanged) then valChanged(value); end
            refreshOpenClassicPage();
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
            refreshOpenClassicPage();
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

-- A multiselect dropdown, the way the game's own options render
-- bitfield settings: a standard dropdown whose menu rows are checkboxes
-- and whose button text lists the selection. items is an ordered array
-- of { key=..., text=..., tooltip=... }. The selection is stored as
-- named booleans in resolveTree(dbTree)[varName]. The proxy setting's
-- Number value is the items' bitmask (bit i for the i-th item), the
-- encoding the stock dropdown checkbox rows toggle.
function ui.MultiDropdown(category, name, items, dbTree, varName, tooltip, noneText, valChanged)
    local function fieldTable()
        local tree = resolveTree(dbTree);
        local fields = tree[varName];
        if (type(fields) ~= "table") then
            fields = {};
            tree[varName] = fields;
        end
        return fields;
    end
    local function getMask()
        local fields = fieldTable();
        local mask = 0;
        for i = 1, #items do
            if (fields[items[i].key]) then
                mask = mask + 2^(i - 1);
            end
        end
        return mask;
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
        refreshOpenClassicPage();
    end
    local setting = Settings.RegisterProxySetting(category, nextVariable(),
        Settings.VarType.Number, name, 0, getMask, setMask);
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

local bugReportHolder;
local function ensureBugReportHolder()
    if (not bugReportHolder) then
        local holder = CreateFrame("Frame");
        holder:Hide();
        -- Rounded tooltip-style panel with a gold border, so the callout
        -- stands apart from the plain settings rows around it.
        local panel = CreateFrame("Frame", nil, holder, "BackdropTemplate");
        panel:SetPoint("TOPLEFT", 37, -4);
        panel:SetPoint("BOTTOMRIGHT", -37, 4);
        panel:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        });
        panel:SetBackdropColor(0.07, 0.07, 0.09, 0.92);
        panel:SetBackdropBorderColor(1, 0.82, 0.2);

        local icon = panel:CreateTexture(nil, "ARTWORK");
        icon:SetSize(34, 34);
        icon:SetPoint("TOPLEFT", 12, -12);
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
        body:SetPoint("RIGHT", -12, 0);
        body:SetJustifyH("LEFT");
        body:SetText(L["Reports are welcome! Click below and follow the instructions in the bug report template."]);

        -- WoW cannot open a browser or write to the clipboard. The
        -- button opens the standard copy dialog with the URL
        -- pre-selected.
        local link = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate");
        link:SetSize(180, 24);
        link:SetPoint("BOTTOM", 0, 10);
        link:SetText(L["Visit us on GitHub"]);
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
            _G.GameTooltip:AddLine(L["Click to copy the link."], 1, 1, 1);
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
-- terms mirror the anchors above: 37px panel insets, a 12+34+10 icon
-- column, and a 12px right pad.
local function bugReportExtent()
    local holder = ensureBugReportHolder();
    holder.wimBody:SetWidth(settingsListWidth() - 74 - 56 - 12);
    local height = 16 + holder.wimTitle:GetStringHeight() + 4
        + holder.wimBody:GetStringHeight() + 8 + 24 + 10 + 8;
    holder.wimBody:SetWidth(0);
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
        created:SetText("|cff69ccf0"..L["Created By:"].."|r");
        local createdText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        createdText:SetPoint("TOPLEFT", created, "BOTTOMLEFT", 0, -4);
        createdText:SetPoint("RIGHT", -37, 0);
        createdText:SetJustifyH("LEFT");
        createdText:SetText(creditsText[1] or "");

        local thanks = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        thanks:SetPoint("TOPLEFT", createdText, "BOTTOMLEFT", 0, -8);
        thanks:SetText("|cff69ccf0"..L["Special Thanks:"].."|r");
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
    holder.wimCreatedText:SetWidth(width);
    holder.wimThanksText:SetWidth(width);
    local height = 6 + holder.wimCreated:GetStringHeight() + 4
        + holder.wimCreatedText:GetStringHeight() + 8
        + holder.wimThanks:GetStringHeight() + 4
        + holder.wimThanksText:GetStringHeight() + 16;
    holder.wimCreatedText:SetWidth(0);
    holder.wimThanksText:SetWidth(0);
    return math.max(120, math.ceil(height));
end

local function registerCategory()
    local category, layout = Settings.RegisterVerticalLayoutCategory("WIM");
    options.modernCategory = category;
    options.modernCategoryID = category:GetID();

    -- Style toggle: the same flag the minimap menu item and /wim style flip.
    styleSetting = Settings.RegisterProxySetting(category,
        "WIM_MODERN_OPTIONS", Settings.VarType.Boolean,
        L["Use modern options UI"], Settings.Default.False,
        function() return db.modernOptions == true; end,
        function(value)
            value = value and true or false;
            if (not value and SkinLocksOptionsStyle()) then
                return;
            end
            db.modernOptions = value;
            options.DebugSetting("modern", "modernOptions", db.modernOptions);
        end);
    local styleInitializer = Settings.CreateCheckbox(category, styleSetting,
        L["When enabled, WIM's Options entry points (minimap menu, key binding, /wim) open this panel instead of the classic WIM options window."]
        .."\n\n"..L["While a modern-only skin (such as WIM Modern) is selected, this option is enforced: those skins are configured through this panel only."]);
    -- Greyed out while a modern-only skin is selected. Those skins are
    -- offered only here, so the classic window must not take over.
    if (styleInitializer and styleInitializer.AddModifyPredicate) then
        styleInitializer:AddModifyPredicate(function()
            return not SkinLocksOptionsStyle();
        end);
    end
    table.insert(allSettings, styleSetting);

    -- The classic window stays reachable from here in either mode.
    if (_G.CreateSettingsButtonInitializer and layout) then
        local classicButton = _G.CreateSettingsButtonInitializer(
            L["Classic Options"], L["Open"],
            function() ShowClassicOptions(); end,
            L["Open the classic WIM options window."]
            .."\n\n"..L["Disabled while a modern-only skin (such as WIM Modern) is selected: those skins carry settings the classic window has no controls for."], true);
        -- Greyed out while a modern-only skin enforces the modern UI.
        if (classicButton.AddModifyPredicate) then
            classicButton:AddModifyPredicate(function()
                return not SkinLocksOptionsStyle();
            end);
        end
        -- Some clients' settings code ignores modify predicates on
        -- button rows; enforcing the state as the row initializes
        -- covers them all.
        local origInitFrame = classicButton.InitFrame;
        classicButton.InitFrame = function(self, frame)
            origInitFrame(self, frame);
            local button = frame and frame.Button;
            if (button and button.SetEnabled) then
                button:SetEnabled(not SkinLocksOptionsStyle());
            end
        end;
        layout:AddInitializer(classicButton);
    end

    -- Bug-report callout and credits on the root page.
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

    Settings.RegisterAddOnCategory(category);

    -- The minimap menu's style toggle is declared hidden and appears
    -- only once the category exists (see Modules/MinimapIcon.lua). It
    -- hides again while a modern-only skin is active, because the modern
    -- options UI is then required.
    local menuItem = GetContextMenu("OPTIONS_STYLE");
    if (menuItem) then
        menuItem.hidden = function() return SkinLocksOptionsStyle(); end;
    end

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

-- Central style switch, used by every surface that changes the flag
-- outside the native panel (the minimap menu item, /wim style). Routing
-- the write through the proxy setting keeps the panel's checkbox current
-- if the panel is open; a direct db write would leave it stale until
-- reopened.
function SetOptionsStyle(enabled)
    enabled = enabled and true or false;
    if (not enabled and SkinLocksOptionsStyle()) then
        _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: the selected skin (%s) requires the modern options UI; switch to another skin first."]
            :format(db.skin and db.skin.selected or ""));
        return;
    end
    if (styleSetting) then
        styleSetting:SetValue(enabled);
    else
        db.modernOptions = enabled;
    end
    -- LibDropDownMenu evaluates `checked` only while it builds a menu; it
    -- has no refresh API, so an open dropdown would keep showing the old
    -- state. Close any open menu instead of leaving a stale checkmark.
    libs.DropDownMenu.CloseDropDownMenus();
    _G.DEFAULT_CHAT_FRAME:AddMessage(enabled
        and L["WIM options style: Modern (native Options > AddOns)."]
        or L["WIM options style: Classic (WIM window)."]);
end

RegisterSlashCommand("style", function(args)
        args = string.trim(string.lower(args or ""));
        local target;
        if (args == "classic") then
            target = false;
        elseif (args == "modern") then
            target = true;
        elseif (args == "") then
            target = not db.modernOptions;
        else
            _G.DEFAULT_CHAT_FRAME:AddMessage(L["Usage: /wim style [classic|modern]"]);
            return;
        end
        if (target and not options.modernCategoryID) then
            _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: the modern options UI is not available on this client."]);
            return;
        end
        SetOptionsStyle(target);
    end, L["Choose the options style: /wim style [classic|modern]."]);
