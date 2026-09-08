--imports
local WIM = WIM;
local _G = _G;
local table = table;
local string = string;
local pairs = pairs;
local tostring = tostring;
local tonumber = tonumber;
local type = type;
local math = math;
local pcall = pcall;
local CreateFrame = CreateFrame;

--set namespace
setfenv(1, WIM);

-- ---------------------------------------------------------------------------
-- Option pages (Options > AddOns > WIM).
--
-- The page tree groups settings by what users look for, not by engine:
-- Conversations (what WIM captures), Windows (when and where windows
-- appear), Appearance, Notifications, Privacy & Filtering, History.
--
-- Every page is a native vertical-layout page. Content without a native
-- control (grids, browsers, previews, swatches) sits inside custom
-- element rows registered through templates in ModernSettings.xml; the
-- settings list pools and scrolls them like any other row, and search
-- reaches everything.
--
-- Proxy-setting defaults are sourced from db_defaults, so the panel's
-- "Defaults" button restores shipped defaults.
-- ---------------------------------------------------------------------------

-- Inert without the registry (clients without the modern Settings API).
if (not options or not options.RegisterModernPage) then
    return;
end

local RegisterModernPage = options.RegisterModernPage;

-- ------------------------------------------------------------ shared pieces

local function props() UpdateAllWindowProps(); end
local function px(value) return tostring(value); end
local function pct(value) return value.."%"; end

-- Pop-up rules section; the whisper and chat variants share the shape.
-- The 7 game states render as a Situation dropdown; the five rule
-- checkboxes bind through a function dbTree that closes over the
-- selected state, and a state change broadcasts NotifyModernSettings so
-- the visible checkboxes re-read the new state immediately.
local popStates = {"arena", "combat", "pvp", "raid", "party", "resting", "other"};

-- Situation rules panel (the Graphics Quality construction): a
-- bordered panel holding the per-situation rules, with native tabs
-- (MinimalTabTemplate, the template behind the panel's own Game and
-- AddOns tabs) seated right-aligned on its top edge. Switching tabs
-- rebinds the rows inside to the selected situation's rule set.
local situationTips = {
    arena = L["While in an arena match."],
    combat = L["While in combat."],
    pvp = L["While in a battleground."],
    raid = L["While in a raid instance."],
    party = L["While in a dungeon."],
    resting = L["While resting in an inn or city."],
    other = L["The base rules. Situations without custom rules follow these."],
};

local situationRules = {
    { key = "onSend", label = L["Pop Up on Send"],
      tip = L["Opens the window when you send a message in this situation."] },
    { key = "onReceive", label = L["Pop Up on Receive"],
      tip = L["Opens the window when a message arrives in this situation."] },
    { key = "autofocus", label = L["Auto Focus"],
      tip = L["Puts the keyboard focus in the input box when a window pops up."] },
    { key = "keepfocus", label = L["Keep Focus"],
      tip = L["Keeps the keyboard focus in the input box after sending a message."] },
    { key = "supress", label = L["Show Only in WIM"],
      tip = L["Hides these messages from the game's chat frame so they appear only in WIM. Per-type and per-channel 'Never Suppress' exceptions on the Conversations pages win. A message is not hidden when no WIM window would show it."] },
};

local situationHolders = {};
local TAB_HEIGHT = 37;
local TAB_SEAT = 13;
local TAB_STACK = 26;
local TAB_INDENT = 37;
local RULE_ROW_HEIGHT = 30;
local RULE_PANEL_HEIGHT = 36 + (#situationRules + 1) * RULE_ROW_HEIGHT;
local situationTabOrder = {"other", "arena", "combat", "pvp", "raid", "party", "resting"};

local function layoutSituationTabs(holder, width)
    local usable = width - TAB_INDENT * 2 - 24;
    local lines = {{}};
    local lineWidth = 0;
    for i = 1, #holder.tabs do
        local tab = holder.tabs[i];
        local w = tab:GetWidth() + 2;
        if (lineWidth + w > usable and #lines[#lines] > 0) then
            table.insert(lines, {});
            lineWidth = 0;
        end
        table.insert(lines[#lines], tab);
        lineWidth = lineWidth + w;
    end
    for lineIndex = 1, #lines do
        local yOff = (#lines - lineIndex) * TAB_STACK - TAB_SEAT;
        local x = -24;
        local line = lines[lineIndex];
        for j = #line, 1, -1 do
            local tab = line[j];
            tab:ClearAllPoints();
            tab:SetPoint("BOTTOMRIGHT", holder.panel, "TOPRIGHT", x, yOff);
            x = x - tab:GetWidth() - 2;
        end
    end
    holder.panel:SetPoint("TOPLEFT", TAB_INDENT,
        -((TAB_HEIGHT - TAB_SEAT) + (#lines - 1) * TAB_STACK));
    return #lines;
end

local function makeSituationHolder(winType)
    local holder = CreateFrame("Frame");
    holder:Hide();
    holder.tabs = {};

    local panel = CreateFrame("Frame", nil, holder);
    holder.panel = panel;
    panel:SetPoint("TOPLEFT", TAB_INDENT, -TAB_HEIGHT);
    panel:SetPoint("BOTTOMRIGHT", -TAB_INDENT, 2);
    options.AddBorderedPanel(panel);

    local slot = CreateFrame("Frame", nil, panel);
    slot:SetHeight(RULE_ROW_HEIGHT);
    slot:SetPoint("TOPLEFT", 16, -18);
    slot:SetPoint("RIGHT", -16, 0);
    slot:EnableMouse(true);
    slot.label = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    slot.label:SetPoint("LEFT", 6, 0);
    slot.note = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    slot.note:SetPoint("LEFT", 6, 0);
    slot.note:SetTextColor(.7, .7, .7);
    slot.note:SetText(L["Situations without custom rules follow these base rules."]);
    slot.cb = CreateFrame("CheckButton", nil, slot, "UICheckButtonTemplate");
    slot.cb:SetPoint("LEFT", slot, "CENTER", -10, 0);
    StyleMinimalCheckbox(slot.cb, 26, .8);
    slot.cb:SetScript("OnClick", function(self)
        local data = holder.data;
        if (not data) then
            return;
        end
        local state = data.stateTbl.state;
        if (state == "other") then
            return;
        end
        local checked = self:GetChecked() and true or false;
        db.pop_rules[winType][state].custom = checked;
        options.DebugSetting("modern", winType.."."..state..".custom", checked);
        options.NotifyModernSettings();
    end);
    local function slotEnter()
        local data = holder.data;
        local state = data and data.stateTbl.state;
        if (state and state ~= "other") then
            options.RowTooltip(slot.cb, slot.label:GetText() or "",
                L["Check to use alternate pop-up rules for this situation. Unchecked, the Base rules apply."]);
        end
    end
    slot:SetScript("OnEnter", slotEnter);
    slot:SetScript("OnLeave", options.HideRowTooltip);
    slot.cb:SetScript("OnEnter", slotEnter);
    slot.cb:SetScript("OnLeave", options.HideRowTooltip);
    holder.slot = slot;

    holder.rules = {};
    for r = 1, #situationRules do
        local rule = situationRules[r];
        local rowF = CreateFrame("Frame", nil, panel);
        rowF:SetHeight(RULE_ROW_HEIGHT);
        rowF:SetPoint("TOPLEFT", 16, -(18 + r * RULE_ROW_HEIGHT));
        rowF:SetPoint("RIGHT", -16, 0);
        rowF:EnableMouse(true);
        rowF.label = rowF:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        rowF.label:SetPoint("LEFT", 6, 0);
        rowF.label:SetText(rule.label);
        rowF.cb = CreateFrame("CheckButton", nil, rowF, "UICheckButtonTemplate");
        rowF.cb:SetPoint("LEFT", rowF, "CENTER", -10, 0);
        StyleMinimalCheckbox(rowF.cb, 26, .8);
        rowF.cb:SetScript("OnClick", function(self)
            local data = holder.data;
            if (not data) then
                return;
            end
            local checked = self:GetChecked() and true or false;
            data.stateDB()[rule.key] = checked;
            options.DebugSetting("modern",
                winType.."."..data.stateTbl.state.."."..rule.key, checked);
        end);
        local function onEnter(self)
            options.RowTooltip(rowF.cb, rule.label, rule.tip);
        end
        rowF:SetScript("OnEnter", onEnter);
        rowF:SetScript("OnLeave", options.HideRowTooltip);
        rowF.cb:SetScript("OnEnter", onEnter);
        rowF.cb:SetScript("OnLeave", options.HideRowTooltip);
        holder.rules[r] = rowF;
    end

    local native = (_G.CreateRadioButtonGroup and _G.ButtonGroupBaseMixin) and true or false;
    for i = 1, #situationTabOrder do
        local state = situationTabOrder[i];
        local name;
        if (state == "other") then
            name = _G.BASE_SETTINGS_TAB or L["Base"];
        elseif (state == "party" or state == "raid") then
            -- These situations mean the instance, not the group.
            name = L["state_"..state];
        else
            name = _G[string.upper(state)] or L["state_"..state];
        end
        local tab;
        if (native) then
            local ok, made = pcall(CreateFrame, "Button", nil, holder, "MinimalTabTemplate");
            if (ok and made and made.Text) then
                tab = made;
                tab.tabText = name;
                tab.Text:SetText(name);
                tab:SetWidth(tab.Text:GetStringWidth() + 24);
                tab:SetHeight(TAB_HEIGHT);
            else
                native = false;
            end
        end
        if (not tab) then
            tab = CreateFrame("Button", nil, holder);
            tab:SetHeight(26);
            tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            tab.text:SetPoint("BOTTOM", 0, 6);
            tab.text:SetText(name);
            tab:SetWidth(tab.text:GetStringWidth() + 16);
            tab.underline = tab:CreateTexture(nil, "OVERLAY");
            tab.underline:SetColorTexture(1, .82, 0);
            tab.underline:SetHeight(2);
            tab.underline:SetPoint("BOTTOMLEFT", 4, 0);
            tab.underline:SetPoint("BOTTOMRIGHT", -4, 0);
            tab:SetScript("OnClick", function(self)
                local data = holder.data;
                if (not data) then
                    return;
                end
                _G.PlaySound(856);
                data.stateTbl.state = self.state;
                options.DebugSetting("modern", winType..".situation", self.state);
                options.NotifyModernSettings();
            end);
        end
        tab.state = state;
        tab:HookScript("OnEnter", function(self)
            options.RowTooltip(self,
                (self.Text and self.Text:GetText()) or self.text:GetText(),
                situationTips[self.state]);
        end);
        tab:HookScript("OnLeave", options.HideRowTooltip);
        holder.tabs[i] = tab;
    end
    holder.native = native;

    if (native) then
        holder.group = _G.CreateRadioButtonGroup();
        holder.group:AddButtons(holder.tabs);
        holder.group:RegisterCallback(_G.ButtonGroupBaseMixin.Event.Selected, function(_, tab)
            if (holder.updating) then
                return;
            end
            local data = holder.data;
            if (not data) then
                return;
            end
            _G.PlaySound(856);
            data.stateTbl.state = tab.state;
            options.DebugSetting("modern", winType..".situation", tab.state);
            options.NotifyModernSettings();
        end, holder);
    end

    holder.RefreshTabs = function()
        local data = holder.data;
        if (data) then
            local active = data.stateTbl.state;
            holder.updating = true;
            for i = 1, #holder.tabs do
                local tab = holder.tabs[i];
                if (holder.native) then
                    if (tab.state == active and holder.group and not tab:IsSelected()) then
                        holder.group:SelectAtIndex(i);
                    end
                else
                    if (tab.state == active) then
                        tab.text:SetTextColor(1, 1, 1);
                        tab.underline:Show();
                    else
                        tab.text:SetTextColor(.62, .62, .62);
                        tab.underline:Hide();
                    end
                end
            end
            holder.updating = nil;

            local editable = true;
            if (active == "other") then
                holder.slot.label:Hide();
                holder.slot.cb:Hide();
                holder.slot.note:Show();
            else
                local stateSet = db.pop_rules[winType][active];
                local tabName;
                for i = 1, #holder.tabs do
                    if (holder.tabs[i].state == active) then
                        tabName = (holder.tabs[i].Text and holder.tabs[i].Text:GetText())
                            or holder.tabs[i].text:GetText();
                        break;
                    end
                end
                holder.slot.note:Hide();
                holder.slot.label:SetText(L["Custom %s Rules"]:format(tabName or ""));
                holder.slot.label:Show();
                holder.slot.cb:SetChecked(stateSet.custom and true or false);
                holder.slot.cb:Show();
                editable = stateSet.custom and true or false;
            end

            local ruleSet = data.stateDB();
            for r = 1, #situationRules do
                local rowF = holder.rules[r];
                rowF.cb:SetChecked(ruleSet[situationRules[r].key] and true or false);
                rowF.cb:SetEnabled(editable);
                rowF.cb:SetAlpha(editable and 1 or .5);
                rowF.label:SetAlpha(editable and 1 or .5);
            end
        end
        layoutSituationTabs(holder,
            options.SettingsListWidth and options.SettingsListWidth() or 600);
    end
    options.RegisterModernRefresh(function()
        if (holder:IsVisible()) then
            holder:RefreshTabs();
        end
    end);
    return holder;
end

local function situationRowInit(row, data)
    local holder = situationHolders[data.winType];
    if (not holder) then
        holder = makeSituationHolder(data.winType);
        situationHolders[data.winType] = holder;
    end
    holder.data = data;
    options.AttachRowHolder(row, holder);
    holder:RefreshTabs();
end

local function situationExtent(winType)
    return function()
        local holder = situationHolders[winType];
        if (not holder) then
            holder = makeSituationHolder(winType);
            situationHolders[winType] = holder;
        end
        local lines = layoutSituationTabs(holder,
            options.SettingsListWidth and options.SettingsListWidth() or 600);
        return (TAB_HEIGHT - TAB_SEAT) + (lines - 1) * TAB_STACK
            + RULE_PANEL_HEIGHT + 8;
    end
end

local function addPopRulesSection(cat, layout, ui, winType, headerName)
    if (headerName) then
        ui.Header(layout, headerName);
    end
    local defaults = db_defaults.pop_rules[winType];
    -- The selected situation is local to this view. Rules resolve the
    -- way the runtime does: a situation without custom rules reads Base.
    local stateTbl = { state = "other" };
    local function stateDB()
        local state = stateTbl.state;
        local set = db.pop_rules[winType][state];
        if (state ~= "other" and not (set and set.custom)) then
            return db.pop_rules[winType].other;
        end
        return set;
    end

    local init = ui.Custom(layout, "WIM3SettingsTabStripTemplate", {
        winType = winType,
        stateTbl = stateTbl,
        stateDB = stateDB,
        onInit = situationRowInit,
        getExtent = situationExtent(winType),
    });
    if (init and init.AddSearchTags) then
        init:AddSearchTags(L["Pop Up on Send"], L["Pop Up on Receive"],
            L["Auto Focus"], L["Keep Focus"], L["Show Only in WIM"],
            "popup", "pop-up", "suppress", "hide", "base", "inherit");
    end
    -- One registered setting per situation and rule, plus each
    -- situation's custom flag, each carrying that situation's own
    -- default: the panel's Defaults button then restores the shipped
    -- rule sets instead of stamping the Base values over every tab.
    for s = 1, #popStates do
        local state = popStates[s];
        local function ruleSet()
            return db.pop_rules[winType][state];
        end
        for r = 1, #situationRules do
            local rule = situationRules[r];
            ui.HiddenSetting(cat, rule.label, defaults[state][rule.key],
                function() return ruleSet()[rule.key]; end,
                function(value)
                    ruleSet()[rule.key] = value;
                    options.DebugSetting("modern", winType.."."..state.."."..rule.key, value);
                    options.NotifyModernSettings();
                end);
        end
        if (state ~= "other") then
            ui.HiddenSetting(cat, L["Custom Rules"], defaults[state].custom,
                function() return ruleSet().custom; end,
                function(value)
                    ruleSet().custom = value;
                    options.DebugSetting("modern", winType.."."..state..".custom", value);
                    options.NotifyModernSettings();
                end);
        end
    end

    if (winType == "whisper" and _G.GetCVar and _G.GetCVar("whisperMode")) then
        -- Only on screen (and only found by search) while the game's
        -- whisper mode has drifted from in-line.
        local function drifted()
            return _G.GetCVar("whisperMode") ~= "inline";
        end
        ui.Button(layout,
            L["In-Line Whisper Mode"],
            L["Set to In-line"],
            function(self)
                _G.SetCVar("whisperMode", "inline");
                if (self and self.SetEnabled) then
                    self:SetEnabled(false);
                end
                if (_G.SettingsInbound and _G.SettingsInbound.RepairDisplay) then
                    _G.SettingsInbound.RepairDisplay();
                end
            end,
            L["Message suppression requires the game's Social > Whisper Mode setting to be In-line; without it, suppressed whispers would vanish into a popout chat tab."],
            drifted, drifted);
    end
end

-- Sound rows: a checkbox with a dependent picker. The item list is
-- rebuilt on every dropdown open, so late LibSharedMedia registrations
-- appear. Selecting stays silent; the speaker button beside the
-- dropdown plays the current pick through the engine's own path, so
-- the preview honors the channel settings on the Advanced page.
local function soundItems()
    local list = {};
    for sound in pairs(libs.SML.MediaTable.sound) do
        table.insert(list, { text = sound, value = sound });
    end
    table.sort(list, function(a, b) return a.text < b.text; end);
    return list;
end

local function soundPreview(value)
    if (PlayNotificationSound) then
        PlayNotificationSound(value);
    else
        _G.PlaySoundFile(libs.SML:Fetch(libs.SML.MediaType.SOUND, value));
    end
end

local function addSoundPair(cat, ui, name, dbTree, defaultsTree, flagKey, soundKey, tooltip)
    -- One row where the client has the checkbox-dropdown control; the
    -- two-row form otherwise.
    local row = ui.SoundRow(cat, name, tooltip, dbTree,
        flagKey, defaultsTree[flagKey], soundKey, defaultsTree[soundKey],
        soundItems, soundPreview);
    if (row) then
        return ui.Tags(row, "sound", "ding", "beep");
    end
    local flag = ui.Tags(ui.Checkbox(cat, name, defaultsTree[flagKey],
        dbTree, flagKey, tooltip), "sound", "ding", "beep");
    local sound = ui.SoundDropdown(cat, L["Sound"], defaultsTree[soundKey] or "",
        soundItems, dbTree, soundKey,
        L["The sound to play. The speaker button plays a preview."],
        soundPreview);
    ui.DependsOn(sound, flag);
    return flag, sound;
end

-- ----------------------------------------------- custom settings-list rows
local ROW_LABEL_X = 37;

-- Color picker plumbing shared by the swatch rows.
local function pickerWidget()
    return (_G.ColorPickerFrame.Content and _G.ColorPickerFrame.Content.ColorPicker)
           or _G.ColorPickerFrame;
end

local function openColorPicker(key, onChanged)
    local c = db.displayColors[key];
    local previous = { c.r, c.g, c.b };
    local function commit(r, g, b)
        c.r, c.g, c.b = r, g, b;
        options.DebugSetting("modern", "displayColors."..key,
            tostring(r)..", "..tostring(g)..", "..tostring(b));
        if (onChanged) then onChanged(); end
    end
    local info = {
        r = c.r, g = c.g, b = c.b, hasOpacity = false,
        swatchFunc = function() commit(pickerWidget():GetColorRGB()); end,
        cancelFunc = function() commit(previous[1], previous[2], previous[3]); end,
    };
    if (_G.ColorPickerFrame.SetupColorPickerAndShow) then
        _G.ColorPickerFrame:SetupColorPickerAndShow(info);
    else
        _G.ColorPickerFrame.func = info.swatchFunc;
        _G.ColorPickerFrame.swatchFunc = info.swatchFunc;
        _G.ColorPickerFrame.cancelFunc = info.cancelFunc;
        _G.ColorPickerFrame.hasOpacity = false;
        pickerWidget():SetColorRGB(c.r, c.g, c.b);
        _G.ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG");
        _G.ColorPickerFrame:Show();
    end
end

-- Grouped color panel, built like the Accessibility > Colors page.
local colorPanels = {};

local function colorRowUpdate(row)
    local c = row.colorKey and db.displayColors[row.colorKey];
    if (not c) then
        return;
    end
    row.Text:SetTextColor(c.r, c.g, c.b);
    if (row.ColorSwatch.Color) then
        row.ColorSwatch.Color:SetVertexColor(c.r, c.g, c.b);
    elseif (row.ColorSwatch.GetNormalTexture) then
        row.ColorSwatch:GetNormalTexture():SetVertexColor(c.r, c.g, c.b);
    end
end

local function acquireColorRow(panel, index)
    local row = panel.rows[index];
    if (row) then
        return row;
    end
    local ok;
    ok, row = pcall(CreateFrame, "Frame", nil, panel, "ColorOverrideTemplate");
    if (not (ok and row and row.Text and row.ColorSwatch)) then
        row = CreateFrame("Frame", nil, panel);
        row:SetSize(300, 20);
        row.Text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
        row.Text:SetPoint("TOPLEFT", 0, -5);
        row.Text:SetJustifyH("LEFT");
        local okSwatch, swatch = pcall(CreateFrame, "Button", nil, row,
            "ColorSwatchTemplate");
        if (not (okSwatch and swatch)) then
            swatch = CreateFrame("Button", nil, row);
            swatch:SetSize(20, 20);
            swatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
        end
        swatch:SetPoint("TOPLEFT", row.Text, "TOPLEFT", 192, 3);
        row.ColorSwatch = swatch;
    end
    row:SetPoint("TOPLEFT", panel.header, "BOTTOMLEFT", 15, -10 - (index - 1) * 30);
    row.ColorSwatch:SetScript("OnClick", function()
        openColorPicker(row.colorKey, function() colorRowUpdate(row); end);
    end);
    panel.rows[index] = row;
    return row;
end

local function colorPanelInit(panel, data)
    if (not panel.rows) then
        panel.rows = {};
        panel.header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        panel.header:SetHeight(20);
        panel.header:SetPoint("TOPLEFT", ROW_LABEL_X, 0);
        panel.header:SetJustifyH("LEFT");
        table.insert(colorPanels, panel);
    end
    panel.header:SetText(_G.COLORS or L["Colors"]);
    for i = 1, #data.colors do
        local row = acquireColorRow(panel, i);
        row.colorKey = data.colors[i].key;
        row.Text:SetText(data.colors[i].label);
        colorRowUpdate(row);
        row:Show();
    end
    for i = #data.colors + 1, #panel.rows do
        panel.rows[i]:Hide();
        panel.rows[i].colorKey = nil;
    end
end

options.RegisterModernRefresh(function()
    for i = 1, #colorPanels do
        local panel = colorPanels[i];
        if (panel:IsVisible() and panel.rows) then
            for j = 1, #panel.rows do
                colorRowUpdate(panel.rows[j]);
            end
        end
    end
end);

local function addColorPanel(ui, layout, colors)
    local tags = { _G.COLORS or L["Colors"] };
    for i = 1, #colors do
        table.insert(tags, colors[i].label);
    end
    ui.Custom(layout, "WIM3SettingsColorPanelTemplate", {
        panel = true,
        extent = 30 + #colors * 30,
        colors = colors,
        onInit = colorPanelInit,
        searchTags = tags,
    });
end

-- Live formatting preview row. The ScrollingMessageFrame is built once
-- and reparented into the pooled row on Init, so its content survives
-- scrolling.
local previewHolder;
local function refreshPreview()
    if (not previewHolder or not previewHolder:IsVisible()) then
        return;
    end
    local prev = previewHolder.prev;
    local color = db.displayColors.wispIn;
    local font;
    if (_G[db.skin.font]) then
        font = _G[db.skin.font]:GetFont();
    else
        font = libs.SML.MediaTable.font[db.skin.font] or _G["ChatFontNormal"]:GetFont();
    end
    -- The message area renders two points above the chosen size.
    prev:SetFont(font, (db.fontSize or 12) + 2, db.skin.font_outline);
    -- TimeStamps prints its "[date]" line above a message only when the
    -- frame's lastDate changed. The preview is cleared and redrawn, so
    -- reset that memory or the date line disappears on every render.
    prev.lastDate = nil;
    prev:Clear();
    prev:AddMessage(applyStringModifiers(applyMessageFormatting(prev,
            "CHAT_MSG_WHISPER_INFORM",
            L["This is a long message which contains both emoticons and urls 8). WIM's home is www.WIMAddon.com."],
            _G.UnitName("player")), prev),
        color.r, color.g, color.b);
    prev:SetIndentedWordWrap(db.wordwrap_indent);
end
options.RegisterModernRefresh(refreshPreview);

local function previewRowInit(row)
    if (not previewHolder) then
        previewHolder = CreateFrame("Frame");
        previewHolder:Hide();
        local border = CreateFrame("Frame", nil, previewHolder);
        border:SetPoint("TOPLEFT", 20, 0);
        border:SetPoint("BOTTOMRIGHT", -20, 0);
        local native = options.AddOptionsPlate(border, true);
        local prev = CreateFrame("ScrollingMessageFrame", nil, border);
        prev:SetPoint("TOPLEFT", 10, native and -26 or -10);
        prev:SetPoint("BOTTOMRIGHT", -10, 8);
        prev:SetFading(false);
        prev:SetMaxLines(5);
        prev:SetJustifyH("LEFT");
        previewHolder.prev = prev;
    end
    options.AttachRowHolder(row, previewHolder);
    refreshPreview();
end

-- Font browser row: a pinned "Skin default" first row (writes
-- db.skin.suggest), then every LibSharedMedia font rendered in its own
-- face. Picking a face turns the skin suggestion off and applies the
-- face; picking the pinned row hands font choice back to the skin.
local browserHolder;
local FONT_ROW_HEIGHT = 24;
-- The client loads a font file asynchronously on first use: SetFont
-- returns false on the session's first attempt and succeeds later. A
-- failed face therefore schedules one retry pass, and only a face that
-- fails repeatedly is reported to the debug log.
local fontFaceAttempts = {};

local function buildFontBrowser()
    local holder = options.MakeListHolder({ scrollName = "WIM3_ModernFontScrollFrame" });
    local stack = options.MakeRowStack(holder, FONT_ROW_HEIGHT, "Button", function(row)
        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        row.title:SetPoint("TOPLEFT", 8, 0);
        row.title:SetPoint("BOTTOM");
        row.title:SetPoint("RIGHT", row, "LEFT", 260, 0);
        row.title:SetJustifyH("LEFT");
        row.sample = row:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
        row.sample:SetPoint("TOPLEFT", row, "TOPLEFT", 270, 0);
        row.sample:SetPoint("BOTTOMRIGHT", -4, 0);
        row.sample:SetJustifyH("LEFT");
        options.SkinListRow(row, row.title);
        row:SetScript("OnClick", function(self)
            _G.PlaySound(856);
            if (self.isSuggestRow) then
                db.skin.suggest = true;
                options.DebugSetting("modern", "skin.suggest", true);
            else
                db.skin.suggest = false;
                db.skin.font = self.font;
                options.DebugSetting("modern", "skin.font", self.font);
            end
            LoadSkin(db.skin.selected);
            holder:RefreshList();
        end);
    end);
    local ensureRow = stack.Row;

    local fontList = {};
    holder.RefreshList = function()
        for key in pairs(fontList) do fontList[key] = nil; end
        for font in pairs(libs.SML.MediaTable.font) do
            table.insert(fontList, font);
        end
        table.sort(fontList);
        stack.Fit(#fontList + 1);

        local suggestRow = ensureRow(1);
        suggestRow.isSuggestRow = true;
        suggestRow.font = nil;
        suggestRow.title:SetText(L["Skin default"]);
        suggestRow.sample:SetText(L["The skin picks the font."]);
        local sampleFont = _G.ChatFontNormal:GetFont();
        suggestRow.sample:SetFont(sampleFont, 16, "");
        if (db.skin.suggest) then
            suggestRow:LockHighlight();
        else
            suggestRow:UnlockHighlight();
        end
        suggestRow:Show();

        local anyFailed = false;
        for i = 1, #fontList do
            local row = ensureRow(i + 1);
            row.isSuggestRow = nil;
            row.font = fontList[i];
            row.title:SetText(fontList[i]);
            local path = libs.SML.MediaTable.font[fontList[i]];
            local okFont = row.sample:SetFont(path, 16, "");
            if (okFont == false or not row.sample:GetFont()) then
                row.sample:SetText("");
                anyFailed = true;
                local attempts = (fontFaceAttempts[fontList[i]] or 0) + 1;
                fontFaceAttempts[fontList[i]] = attempts;
                if (attempts == 2) then
                    dPrint("Font browser: face persistently failing for '"
                        ..fontList[i].."' -> "..tostring(path));
                end
            else
                fontFaceAttempts[fontList[i]] = nil;
                row.sample:SetText(L["AaBbYyZz 123"]);
            end
            if (not db.skin.suggest and db.skin.font == fontList[i]) then
                row:LockHighlight();
            else
                row:UnlockHighlight();
            end
            row:Show();
        end

        if (anyFailed and not holder.retryScheduled and _G.C_Timer and _G.C_Timer.After) then
            holder.retryScheduled = true;
            _G.C_Timer.After(0.1, function()
                holder.retryScheduled = nil;
                if (holder:IsVisible()) then
                    holder:RefreshList();
                end
            end);
        end
    end

    return holder;
end

local function fontBrowserRowInit(row)
    if (not browserHolder) then
        browserHolder = buildFontBrowser();
    end
    options.AttachRowHolder(row, browserHolder);
    browserHolder:RefreshList();
    if (_G.C_Timer and _G.C_Timer.After) then
        _G.C_Timer.After(0, function()
            if (browserHolder and browserHolder:IsVisible()) then
                browserHolder:RefreshList();
            end
        end);
    end
end

-- Filter list row (whisper and chat variants). One persistent holder
-- per variant. The modal editor (Modules/Filters.lua) is shared; its
-- OnHide broadcasts NotifyModernSettings, so these lists follow saves.
local FILTER_ROW_HEIGHT = 32;
local filterHolders = {};

local function makeFilterHolder(isChat)
    local function ftab()
        return isChat and chatFilters or filters;
    end
    local filterTypes = {L["Pattern"], L["User Type"], L["User Level"]};
    local filterActions = {L["Allow"], L["Ignore"], L["Block"]};

    local holder = options.MakeListHolder({
        scrollName = "WIM3_ModernFilterScroll"..(isChat and "Chat" or "Whisper"),
        -- A caption above the list, and room for the buttons below it.
        anchorBorder = function(border, holder)
            holder.headerText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
            holder.headerText:SetPoint("TOPLEFT", 20, -2);
            holder.headerText:SetPoint("TOPRIGHT", -20, -2);
            holder.headerText:SetJustifyH("LEFT");
            holder.headerText:SetText(L["Filters run top to bottom; the first match wins. Allow lets a message through, Ignore hides it silently, Block hides it and, with Show Alert, tells you in the chat frame with a link to view it."]);
            border:SetPoint("TOPLEFT", holder.headerText, "BOTTOMLEFT", 0, -6);
            border:SetPoint("RIGHT", -20, 0);
            border:SetPoint("BOTTOM", 0, 34);
        end,
    });
    local border = holder.border;

    local stack = options.MakeRowStack(holder, FILTER_ROW_HEIGHT, "Button", function(row)
        row.cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
        row.cb:SetPoint("TOPLEFT", 2, -2);
        StyleMinimalCheckbox(row.cb, 24, .75);
        row.cb:SetScript("OnClick", function(self)
            row.filter.enabled = self:GetChecked() and true or false;
            options.DebugSetting("modern", "filter."..(row.filter.name or "?")..".enabled",
                row.filter.enabled);
            options.NotifyModernSettings();
        end);

        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        row.title:SetPoint("TOPLEFT", 28, -3);
        row.title:SetPoint("RIGHT", -40, 0);
        row.title:SetJustifyH("LEFT");
        row.action = row:CreateFontString(nil, "OVERLAY", "ChatFontSmall");
        row.action:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -1);
        row.stats = row:CreateFontString(nil, "OVERLAY", "ChatFontSmall");
        row.stats:SetPoint("TOPLEFT", row.action, "TOPRIGHT");
        row.stats:SetPoint("RIGHT", -40, 0);
        row.stats:SetJustifyH("RIGHT");
        options.SkinListRow(row, row.title);

        row.down = CreateFrame("Button", nil, row);
        row.down:SetSize(14, 14);
        row.down:SetPoint("TOPRIGHT", -2, -2);
        options.StyleStepper(row.down, "down");
        row.down:SetScript("OnClick", function()
            local index = row.index;
            local list = ftab();
            list[index], list[index+1] = list[index+1], list[index];
            if (holder.selected == index) then holder.selected = index + 1; end
            holder:RefreshList();
        end);
        row.up = CreateFrame("Button", nil, row);
        row.up:SetSize(14, 14);
        row.up:SetPoint("RIGHT", row.down, "LEFT", -5, 0);
        options.StyleStepper(row.up, "up");
        row.up:SetScript("OnClick", function()
            local index = row.index;
            local list = ftab();
            list[index], list[index-1] = list[index-1], list[index];
            if (holder.selected == index) then holder.selected = index - 1; end
            holder:RefreshList();
        end);

        row:SetScript("OnClick", function()
            _G.PlaySound(856);
            holder.selected = row.index;
            holder:RefreshList();
        end);
    end);
    local ensureRow = stack.Row;

    holder.add = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate");
    holder.add:SetSize(110, 24);
    holder.add:SetPoint("TOPLEFT", border, "BOTTOMLEFT", 0, -4);
    holder.add:SetText(L["Add Filter"]);
    holder.add:SetScript("OnClick", function()
        ShowFilterFrame(nil, nil, isChat);
    end);
    holder.edit = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate");
    holder.edit:SetSize(110, 24);
    holder.edit:SetPoint("LEFT", holder.add, "RIGHT", 4, 0);
    holder.edit:SetText(L["Edit Filter"]);
    holder.edit:SetScript("OnClick", function()
        if (holder.selected) then
            ShowFilterFrame(ftab()[holder.selected], holder.selected, isChat);
        end
    end);
    holder.delete = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate");
    holder.delete:SetSize(110, 24);
    holder.delete:SetPoint("TOPRIGHT", border, "BOTTOMRIGHT", 0, -4);
    holder.delete:SetText(L["Delete Filter"]);
    holder.delete:SetScript("OnClick", function()
        local list = ftab();
        if (not holder.selected or not list[holder.selected]) then
            return;
        end
        table.remove(list, holder.selected);
        if (holder.selected == 1) then
            holder.selected = (#list > 0) and 1 or nil;
        else
            holder.selected = holder.selected - 1;
        end
        holder:RefreshList();
        options.NotifyModernSettings();
    end);

    holder.RefreshList = function()
        local list = ftab();
        stack.Fit(#list);
        for i = 1, #list do
            local row = ensureRow(i);
            local filter = list[i];
            row.index = i;
            row.filter = filter;
            local alpha = filter.enabled and 1 or .65;
            row.cb:SetChecked(filter.enabled);
            row.title:SetText((filter.name or "").."|cffffffff - "
                ..(filterTypes[filter.type] or "?")
                ..(filter.protected and " ("..L["Protected"]..")" or "").."|r");
            row.title:SetAlpha(alpha);
            row.action:SetText(L["Action:"].." "..(filterActions[filter.action] or "?"));
            row.action:SetAlpha(alpha);
            row.stats:SetText(L["Occurrences:"].." "..(filter.stats or "0"));
            row.stats:SetAlpha(alpha);
            if (i == 1) then row.up:Hide(); else row.up:Show(); end
            if (i == #list) then row.down:Hide(); else row.down:Show(); end
            if (holder.selected == i) then
                row:LockHighlight();
            else
                row:UnlockHighlight();
            end
            row:Show();
        end
        holder.edit:SetEnabled(holder.selected ~= nil);
        holder.delete:SetEnabled(holder.selected ~= nil
            and list[holder.selected] ~= nil
            and not list[holder.selected].protected);
    end
    return holder;
end

local function ensureFilterHolder(isChat)
    local key = isChat and "chat" or "whisper";
    if (not filterHolders[key]) then
        filterHolders[key] = makeFilterHolder(isChat);
    end
    return filterHolders[key];
end

local filterRowInit = options.HolderRowInit(function(data)
    return ensureFilterHolder(data.isChat);
end);

local function filterExtent(isChat)
    return function()
        local holder = ensureFilterHolder(isChat);
        local width = (options.SettingsListWidth and options.SettingsListWidth() or 600) - 40;
        return 252 + math.ceil(options.WrappedHeight(holder.headerText, width));
    end
end

-- Channel lists (world, custom, community), laid out like the chat
-- type grid: one 30px row per channel, a column per flag with its
-- header on the panel's first line, the column pitch following the
-- panel width so every header and toggle stays inside the frame.
local CHANNEL_ROW_HEIGHT = 30;
local CHANNEL_TOP = options.FRAME_INSET + 12;
local CHANNEL_HEADER = 30;
local CHANNEL_NAME_WIDTH = 150;
local CHANNEL_VISIBLE_ROWS = 6;
local CHANNEL_EXTENT = CHANNEL_TOP + CHANNEL_HEADER
    + CHANNEL_VISIBLE_ROWS * CHANNEL_ROW_HEIGHT + CHANNEL_TOP + 8;
local channelHolders = {};

local channelToggles = {
    { key = "monitor",       label = L["Capture"],             help = L["Have WIM monitor this channel."] },
    { key = "neverPop",      label = L["Never Pop Up"],        help = L["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] },
    { key = "neverSuppress", label = L["Never Suppress"],      help = L["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] },
    { key = "showAlerts",    label = L["Launcher Alerts"],     help = L["Show an unread message badge on the WIM launcher icons. Off by default for channels."] },
    { key = "noHistory",     label = L["No History"],          help = L["Do not record history for this channel, whatever History > Recording records."] },
    { key = "noSound",       label = L["No Sound"],            help = L["Do not play sounds for this channel, whatever the Notifications page plays."] },
};

local function layoutChannelColumns(holder, width)
    local pitch = (width - CHANNEL_NAME_WIDTH) / #channelToggles;
    if (pitch < 40) then
        pitch = 40;
    end
    holder.columnPitch = pitch;
    local left = holder.scroll.wimLeftInset or 4;
    for c = 1, #channelToggles do
        local head = holder.headers[c];
        head:ClearAllPoints();
        head:SetPoint("TOP", holder.border, "TOPLEFT",
            left + CHANNEL_NAME_WIDTH + (c - .5) * pitch, -CHANNEL_TOP);
        head:SetWidth(pitch - 4);
    end
end

local function makeChannelHolder(channelType, listFun)
    local holder = options.MakeListHolder({
        scrollName = "WIM3_ModernChannelScroll"..channelType,
        -- The pane starts under the header line; its own top clearance
        -- is FRAME_INSET + 10.
        scrollTop = CHANNEL_TOP + CHANNEL_HEADER - (options.FRAME_INSET + 10),
    });
    holder.headers = {};
    for c = 1, #channelToggles do
        local head = holder.border:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
        head:SetJustifyH("CENTER");
        head:SetJustifyV("BOTTOM");
        head:SetHeight(CHANNEL_HEADER - 4);
        head:SetText(channelToggles[c].label);
        holder.headers[c] = head;
    end

    local stack = options.MakeRowStack(holder, CHANNEL_ROW_HEIGHT, "Frame", function(row)
        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        row.title:SetPoint("LEFT", 6, 0);
        row.title:SetWidth(CHANNEL_NAME_WIDTH - 10);
        row.title:SetJustifyH("LEFT");
        row.title:SetWordWrap(false);

        row.toggles = {};
        row.toggleList = {};
        for t = 1, #channelToggles do
            local toggle = channelToggles[t];
            local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
            StyleMinimalCheckbox(cb, 26, .8);
            cb.key = toggle.key;
            cb:SetScript("OnClick", function(self)
                local settings = db.chat[channelType].channelSettings[row.channelName];
                if (settings) then
                    settings[self.key] = self:GetChecked() and true or false;
                    options.DebugSetting("modern",
                        "chat."..channelType..".channelSettings."..tostring(row.channelName).."."..self.key,
                        settings[self.key]);
                end
            end);
            cb:SetScript("OnEnter", function(self)
                local help = toggle.help;
                if (channelType == "community" and toggle.key == "noHistory") then
                    help = L["Community chat cannot be recorded, so this is always on for community channels."];
                end
                options.RowTooltip(self, (row.title:GetText() or "").." - "..toggle.label, help);
            end);
            cb:SetScript("OnLeave", options.HideRowTooltip);
            row.toggles[toggle.key] = cb;
            row.toggleList[t] = cb;
        end
    end);
    local ensureRow = stack.Row;

    holder.RefreshList = function()
        local channelList = listFun();
        stack.Fit(#channelList);
        local width = holder.scroll:GetWidth();
        if (not width or width <= 0) then
            width = 500;
        end
        layoutChannelColumns(holder, width);
        for i = 1, #channelList do
            local row = ensureRow(i);
            local name, active, channelNumber = string.split("*", channelList[i]);
            active = active == "1";
            row.channelName = name;
            if (not db.chat[channelType].channelSettings[name]) then
                db.chat[channelType].channelSettings[name] = {};
            end
            local settings = db.chat[channelType].channelSettings[name];

            local nameText = name;
            local isCommunityChannel = name:find("%d+:%d+");
            if (isCommunityChannel and _G.ChatFrameUtil and _G.ChatFrameUtil.ResolveChannelName) then
                nameText = _G.ChatFrameUtil.ResolveChannelName(name);
            end
            local channelNumberText = "";
            if (channelNumber and channelNumber ~= "0") then
                channelNumberText = "|cffffffff"..channelNumber..". |r";
            end
            row.title:SetText(channelNumberText..nameText);

            local color = _G.ChatTypeInfo["CHANNEL"..(channelNumber or "")] or _G.NORMAL_FONT_COLOR;
            if (isCommunityChannel and _G.ChatFrameUtil
                and _G.ChatFrameUtil.GetCommunityAndStreamFromChannel) then
                local clubId, streamId = _G.ChatFrameUtil.GetCommunityAndStreamFromChannel(name);
                local r, g, b = _G.ChatFrameUtil.GetCommunitiesChannelColor(clubId, streamId);
                color = { r = r, g = g, b = b };
            end
            row.title:SetTextColor(color.r, color.g, color.b);
            row.title:SetAlpha(active and 1 or .4);

            for t = 1, #channelToggles do
                local cb = row.toggleList[t];
                cb:ClearAllPoints();
                cb:SetPoint("CENTER", row, "LEFT",
                    CHANNEL_NAME_WIDTH + (t - .5) * holder.columnPitch, 0);
                cb:SetChecked(settings[cb.key] and true or false);
                cb:SetEnabled(true);
                cb:SetAlpha(1);
            end
            -- "No History" is force-ticked and greyed for community
            -- channels: Community chat cannot be recorded (see the
            -- CLUB_MESSAGE_ADDED branch in Modules/History.lua).
            if (channelType == "community") then
                row.toggles.noHistory:SetChecked(true);
                row.toggles.noHistory:SetEnabled(false);
                row.toggles.noHistory:SetAlpha(.5);
            end
            row:Show();
        end
    end
    return holder;
end

local channelRowInit = options.HolderRowInit(function(data)
    if (not channelHolders[data.channelType]) then
        channelHolders[data.channelType] = makeChannelHolder(data.channelType, data.list);
    end
    return channelHolders[data.channelType];
end);

-- What the search finds a channel list under: its title plus every
-- flag column.
local function channelSearchTags(title)
    local tags = { title, _G.CHANNELS or "channel" };
    for t = 1, #channelToggles do
        table.insert(tags, channelToggles[t].label);
    end
    return tags;
end

-- Chat type grid: one row per chat type, its whole contract in four
-- columns (Enable / Launcher alerts / Never pop up / Never suppress).
-- Columns 2-4 grey out while the type's module is disabled. Same
-- geometry as the situation rules panel: 30px rows inset 16px inside
-- the bordered panel, column headers on the first line.
local GRID_ROW_HEIGHT = 30;
local GRID_TOP = options.FRAME_INSET + 12;
local GRID_HEADER = 30;
local GRID_INSET = options.FRAME_INSET + 8;
local gridHolder;

local chatTypeRows = {
    { name = _G.GUILD,            module = "GuildChat",        key = "guild" },
    { name = _G.GUILD_RANK1_DESC, module = "OfficerChat",      key = "officer" },
    { name = _G.PARTY,            module = "PartyChat",        key = "party" },
    { name = _G.RAID,             module = "RaidChat",         key = "raid" },
    { name = _G.INSTANCE_CHAT,    module = "BattlegroundChat", key = "battleground" },
    { name = _G.SAY,              module = "SayChat",          key = "say",
      help = L["Also captures emotes."] },
};

local gridColumns = {
    { key = "enabled",       label = L["Enable"],
      help = L["WIM manages this chat type in its own message windows. Turning a type off stops capture now; its window button stays until the next reload."] },
    { key = "showAlerts",    label = L["Launcher Alerts"],
      help = L["Show an unread message badge on the WIM launcher icons."] },
    { key = "neverPop",      label = L["Never Pop Up"],
      help = L["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] },
    { key = "neverSuppress", label = L["Never Suppress"],
      help = L["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] },
};

local function buildChatTypeGrid()
    local holder = options.MakeListHolder({ noScroll = true });
    local border = holder.border;

    local colX = { 170, 280, 390, 500 };
    holder.headers = {};
    for c = 1, #gridColumns do
        -- Headers wrap onto a second line for longer translations.
        local head = border:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
        head:SetJustifyH("CENTER");
        head:SetJustifyV("BOTTOM");
        head:SetWidth(104);
        head:SetHeight(GRID_HEADER - 4);
        head:SetPoint("TOP", border, "TOPLEFT", colX[c], -GRID_TOP);
        head:SetText(gridColumns[c].label);
        holder.headers[c] = head;
    end

    holder.rows = {};
    for i = 1, #chatTypeRows do
        local info = chatTypeRows[i];
        local row = CreateFrame("Frame", nil, border);
        row:SetHeight(GRID_ROW_HEIGHT);
        row:SetPoint("TOPLEFT", GRID_INSET, -(GRID_TOP + GRID_HEADER + (i - 1) * GRID_ROW_HEIGHT));
        row:SetPoint("RIGHT", -GRID_INSET, 0);
        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        row.title:SetPoint("LEFT", 6, 0);
        row.title:SetWidth(140);
        row.title:SetJustifyH("LEFT");
        row.title:SetText(info.name);
        row.info = info;

        row.toggles = {};
        for c = 1, #gridColumns do
            local column = gridColumns[c];
            local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
            StyleMinimalCheckbox(cb, 26, .8);
            cb:SetPoint("CENTER", row, "LEFT", colX[c] - GRID_INSET, 0);
            cb.column = column;
            cb:SetScript("OnClick", function(self)
                local checked = self:GetChecked() and true or false;
                if (column.key == "enabled") then
                    -- Chat modules own a window widget, so EnableModule
                    -- alone defers turning them off to the next reload
                    -- and the box would snap back. Stop the module now:
                    -- event dispatch honors the flag, and OnDisable
                    -- lifts the chat frame filter so messages are not
                    -- hidden while nothing captures them. Only the
                    -- window button lingers.
                    local module = modules[info.module];
                    if (not checked and module and module.enabled) then
                        module.enabled = false;
                        if (type(module.OnDisable) == "function") then
                            module:OnDisable();
                        end
                    end
                    EnableModule(info.module, checked);
                    options.DebugSetting("modern", "modules."..info.module..".enabled", checked);
                else
                    db.chat[info.key][column.key] = checked;
                    options.DebugSetting("modern", "chat."..info.key.."."..column.key, checked);
                end
                holder:RefreshList();
            end);
            cb:SetScript("OnEnter", function(self)
                local body = column.help;
                if (info.help) then
                    body = body.."\n|cffcccccc"..info.help.."|r";
                end
                options.RowTooltip(self, info.name.." - "..column.label, body);
            end);
            cb:SetScript("OnLeave", options.HideRowTooltip);
            row.toggles[column.key] = cb;
        end
        holder.rows[i] = row;
    end

    holder.RefreshList = function()
        for i = 1, #holder.rows do
            local row = holder.rows[i];
            local info = row.info;
            local enabled = modules[info.module] and modules[info.module].enabled and true or false;
            row.toggles.enabled:SetChecked(enabled);
            for c = 2, #gridColumns do
                local column = gridColumns[c];
                local cb = row.toggles[column.key];
                cb:SetChecked(db.chat[info.key][column.key] and true or false);
                cb:SetEnabled(enabled);
                cb:SetAlpha(enabled and 1 or .4);
            end
            row.title:SetAlpha(enabled and 1 or .6);
        end
    end

    return holder;
end

local chatTypeGridInit = options.HolderRowInit(function()
    if (not gridHolder) then
        gridHolder = buildChatTypeGrid();
    end
    return gridHolder;
end);

-- Panel top, header line, the rows, the same margin at the bottom, and
-- the holder's 4px clearances above and below the panel.
local GRID_EXTENT = GRID_TOP + GRID_HEADER + #chatTypeRows * GRID_ROW_HEIGHT + GRID_TOP + 8;

-- The known-senders switch: derived live from the paired WhisperSelect
-- filters, never stored. Enabling recreates a missing entry from the
-- shipped template.
local whisperSelectNames = { L["WhisperSelect Part 1"], L["WhisperSelect Part 2"] };

local function whisperFilterList()
    if (type(filters) == "table") then
        return filters;
    end
    return _G.WIM3_Filters;
end

local function findFilterByName(list, name)
    for i = 1, #list do
        if (list[i].name == name) then
            return list[i];
        end
    end
end

local function knownSendersGet()
    local list = whisperFilterList();
    if (type(list) ~= "table") then
        return false;
    end
    for i = 1, #whisperSelectNames do
        local entry = findFilterByName(list, whisperSelectNames[i]);
        if (not entry or not entry.enabled) then
            return false;
        end
    end
    return true;
end

local function knownSendersSet(value)
    local list = whisperFilterList();
    if (type(list) ~= "table") then
        return;
    end
    for i = 1, #whisperSelectNames do
        local entry = findFilterByName(list, whisperSelectNames[i]);
        if (value and not entry) then
            local template = findFilterByName(GetDefaultFilters(), whisperSelectNames[i]);
            if (template) then
                entry = {};
                for k, v in pairs(template) do
                    entry[k] = v;
                end
                table.insert(list, math.min(i + 1, #list + 1), entry);
            end
        end
        if (entry) then
            entry.enabled = value and true or false;
        end
    end
    options.NotifyModernSettings();
end

-- ------------------------------------------------------------ Conversations
RegisterModernPage(function(category, ui)
    local folder = ui.Subcategory(category, L["Conversations"],
        L["Choose what WIM captures: whispers, chat types, and channels."]);
    do
        local cat, layout = ui.Subcategory(folder, L["Sources"],
        L["What WIM takes over: whispers, and the chat types that get their own windows."]);
        ui.Header(layout, L["Whispers"]);
        local intercept = ui.Checkbox(cat, L["Redirect /w and /r to WIM"],
            true, db.pop_rules.whisper, "intercept",
            L["Incoming whispers always open in WIM while it is enabled; this additionally redirects typing /w and /r in the game's chat box into a WIM window. Not while in combat."]);
        local reply = ui.Checkbox(cat, L["/reply Counts Sent Whispers"],
            false, db.pop_rules.whisper, "replyIncludesSent",
            L["When choosing the /reply target, your most recent sent whisper counts as well as the last one received."]);
        ui.DependsOn(reply, intercept);
        ui.Checkbox(cat, L["Sender Details"], true,
            db, "whoLookups",
            L["Shows the sender's class, level, and guild on their window. Sends one /who lookup when the window opens. Applies to windows opened after the change."]);

        -- The Say window's output mode (say, yell, emote) is not offered
        -- here: its shortcut bar button cycles it in place.
        ui.Header(layout, L["Chat Types"]);
        local gridTags = { L["Chat Types"] };
        for i = 1, #chatTypeRows do
            table.insert(gridTags, chatTypeRows[i].name);
        end
        for c = 1, #gridColumns do
            table.insert(gridTags, gridColumns[c].label);
        end
        ui.Custom(layout, "WIM3SettingsChatTypeListTemplate",
            { onInit = chatTypeGridInit, extent = GRID_EXTENT, searchTags = gridTags });
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Channels"],
        L["Capture world and custom channels and set per-channel exceptions."]);
        ui.Header(layout, L["World Channels"]);
        ui.Checkbox(cat, L["Capture World Channels"], false,
            db.chat.world, "enabled",
            L["Master switch for this channel type; individual channels are captured with the Capture flag below."],
            function() modules.ChannelChat:SettingsChanged(); end);
        ui.Custom(layout, "WIM3SettingsChannelListTemplate", {
            extent = CHANNEL_EXTENT,
            searchTags = channelSearchTags(L["World Channels"]),
            channelType = "world",
            list = function() return (GetOptionsChannelList and GetOptionsChannelList(true)) or {}; end,
            onInit = channelRowInit,
        });

        ui.Header(layout, L["Custom Channels"]);
        ui.Checkbox(cat, L["Capture Custom Channels"], false,
            db.chat.custom, "enabled",
            L["Master switch for this channel type; individual channels are captured with the Capture flag below."],
            function() modules.ChannelChat:SettingsChanged(); end);
        ui.Custom(layout, "WIM3SettingsChannelListTemplate", {
            extent = CHANNEL_EXTENT,
            searchTags = channelSearchTags(L["Custom Channels"]),
            channelType = "custom",
            list = function() return (GetOptionsChannelList and GetOptionsChannelList(false)) or {}; end,
            onInit = channelRowInit,
        });
    end

    if (_G.C_Club and _G.C_Club.GetSubscribedClubs) then
        local cat, layout = ui.Subcategory(folder, L["Communities"],
        L["Capture community channels, set per-channel exceptions, and keep their chat channels working."]);
        ui.Checkbox(cat, L["Capture Community Channels"], false,
            db.chat.community, "enabled",
            L["Master switch for this channel type; individual channels are captured with the Capture flag below."],
            function() modules.ChannelChat:SettingsChanged(); end);
        ui.Custom(layout, "WIM3SettingsChannelListTemplate", {
            extent = CHANNEL_EXTENT,
            searchTags = channelSearchTags(L["Communities"]),
            channelType = "community",
            list = function() return (GetOptionsCommunityList and GetOptionsCommunityList()) or {}; end,
            onInit = channelRowInit,
        });

        ui.Header(layout, L["Maintenance"]);
        ui.Checkbox(cat, L["Focus Streams at Login"], true,
            db.chat.community, "autoFocusStreams",
            L["At login WIM focuses your community chat streams so the client accepts sends to their channel numbers. Takes effect at the next login and needs at least one channel type captured."]);
        ui.Checkbox(cat, L["Repair Dropped Channels"],
            false, db.chat.community, "repairChannelReAdd",
            L["Re-adds community channels to your chat frames when the client drops them, once per login after a late stream focus; /wim channelrepair runs it now. Opt-in: this mutates saved chat window configuration."]);
    end
end);

-- ------------------------------------------------------------------ Windows
RegisterModernPage(function(category, ui)
    local folder = ui.Subcategory(category, L["Windows"],
        L["When windows appear, where they sit, and what has keyboard focus."]);
    do
        local cat, layout = ui.Subcategory(folder, L["Pop-up Rules"],
        L["When windows pop up and when messages leave the chat frame, per situation."]);
        addPopRulesSection(cat, layout, ui, "whisper", L["Whispers"]);
        addPopRulesSection(cat, layout, ui, "chat", _G.CHAT or L["Chat"]);
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Placement & Size"],
        L["Where new windows spawn and how big they are, their layer, cascading, and screen clamping."]);
        -- Spawn point, default size and scale live in the game's Edit
        -- Mode where the client has one; the sliders and placement
        -- window only remain for clients without it.
        local editMode = ShowEditMode and _G.EditModeManagerFrame;
        if (editMode) then
            ui.Button(layout, _G.HUD_EDIT_MODE_MENU or L["Edit Mode"],
                _G.HUD_EDIT_MODE_MENU or L["Edit Mode"],
                function() ShowEditMode(); end,
                L["Where new windows appear, their default size and scale, and the placement of the History Viewer and filter editor are set in the game's Edit Mode."],
                function() return not _G.InCombatLockdown(); end);
        else
            ui.Button(layout, L["Set Window Spawn Location"], L["Set Window Spawn Location"],
                function() ShowDemoWindow(); end,
                L["Opens a placement window; drag it to where new windows should appear, then close it to save the spot."]);
            ui.Slider(cat, L["Default Width"], 333, 150, 800, 1,
                db.winSize, "width", nil, props, px);
            ui.Slider(cat, L["Default Height"], 245, 80, 600, 1,
                db.winSize, "height", nil, props, px);
            ui.Slider(cat, L["Window Scale"], 100, 10, 400, 1,
                db.winSize, "scale", nil, props, pct);
        end

        local stratas = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"};
        local strataNames = {L["Background"], L["Low"], L["Medium"], L["High"], L["Dialog"], L["Tooltip"]};
        local strataTips = {
            L["Behind the standard interface."],
            L["Above the background layer."],
            L["Level with most interface frames."],
            L["Above most interface frames."],
            L["Level with dialog windows."],
            L["Above everything, at tooltip level."],
        };
        local strataList = {};
        for i = 1, #stratas do
            table.insert(strataList, { text = strataNames[i], value = stratas[i], tooltip = strataTips[i] });
        end
        ui.Dropdown(cat, L["Window Layer"], "DIALOG", strataList,
            db.winSize, "strata",
            L["The interface layer WIM windows draw on; higher layers cover lower ones."], props);

        local cascadeNames = {L["Up"], L["Down"], L["Left"], L["Right"],
            L["Up"].." & "..L["Left"], L["Up"].." & "..L["Right"],
            L["Down"].." & "..L["Left"], L["Down"].." & "..L["Right"]};
        local cascadeList = {};
        for i = 1, #cascadeNames do
            table.insert(cascadeList, { text = cascadeNames[i], value = i });
        end
        local cascade = ui.Checkbox(cat, L["Cascade Windows"],
            true, db.winCascade, "enabled",
            L["New windows that would overlap are offset in the chosen direction. Whisper windows do not cascade while Group Whispers is on, nor chat windows while Group Chat Windows is on. Applies to windows opened after the change."]);
        if (cascade.init and cascade.init.AddModifyPredicate) then
            cascade.init:AddModifyPredicate(function()
                return not (db.tabs.whispers.enabled and db.tabs.chat.enabled);
            end);
        end
        local cascadeDir = ui.Dropdown(cat, L["Cascade Direction"],
            8, cascadeList, db.winCascade, "direction");
        ui.DependsOn(cascadeDir, cascade);

        ui.Checkbox(cat, L["Clamp to Screen"], true,
            db, "clampToScreen",
            L["Windows cannot be dragged past the screen edges."], props);
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Focus & Input"],
        L["Keyboard focus and input behavior."]);
        ui.Checkbox(cat, L["Escape Hides Windows"], true,
            db, "escapeToHide",
            L["Pressing Escape hides all open WIM windows."], props);
        ui.Checkbox(cat, L["Ignore Arrow Keys"], true,
            db, "ignoreArrowKeys",
            L["Arrow keys keep controlling the game while the input box has focus; hold Alt to move the text cursor instead."], props);
        ui.Checkbox(cat, L["Tab to Next Whisper"], false,
            db, "tabAdvance",
            L["Pressing Tab in a whisper window jumps to the next person you whispered. While enabled, forward Tab no longer cycles through window tabs."]);
        local click = ui.Checkbox(cat, L["Click to Release Focus"],
            true, modules.ClickControl, "enabled",
            L["Clicking the game world releases WIM's keyboard focus so movement keys control your character again. Not while in combat."],
            function(value) EnableModule("ClickControl", value); end);
        local durations = {};
        for i = 1, 10 do
            local value = i * .05;
            local text = string.format("%.2f s", value);
            if (i == 1) then
                text = text.." ("..L["instant"]..")";
            elseif (i == 10) then
                text = text.." ("..L["slow"]..")";
            end
            table.insert(durations, { text = text, value = value });
        end
        local duration = ui.Dropdown(cat, L["Click Hold Limit"], .2,
            durations, db.ClickControl, "clickSensitivity",
            L["Clicks held longer than this are treated as camera turns and keep WIM's focus."]);
        ui.DependsOn(duration, click);

        ui.Header(layout, L["Windows Opened from Menus"]);
        ui.Checkbox(cat, L["Whispers Follow Focus Rules"],
            false, db.pop_rules.whisper, "obeyAutoFocusRules",
            L["Whisper windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."]);
        ui.Checkbox(cat, L["Chat Follows Focus Rules"],
            false, db.pop_rules.chat, "obeyAutoFocusRules",
            L["Chat windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."]);
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Tab Groups"],
        L["Group windows into shared tab strips."]);
        local sorts = {L["Window Created"], L["Last Activity"], L["Alphabetical"]};
        local sortTips = {L["Oldest conversation first."], L["Most recently active conversation first."], L["By conversation name."]};
        local sortList = {};
        for i = 1, #sorts do
            table.insert(sortList, { text = sorts[i], value = i, tooltip = sortTips[i] });
        end
        ui.Dropdown(cat, L["Sort Tabs By"], 2, sortList,
            db.tabs, "sortBy", nil, function() UpdateAllTabs(); end);

        ui.Header(layout, L["Whispers"]);
        local whispers = ui.Checkbox(cat, L["Group Whispers"],
            false, db.tabs.whispers, "enabled",
            L["Whisper windows share one tabbed window. Does not apply to windows already opened."]);
        local friends = ui.Checkbox(cat, L["Separate Friends Group"],
            false, db.tabs.whispers, "friends",
            L["Whispers from friends group into their own tabbed window."]);
        ui.DependsOn(friends, whispers);
        local guild = ui.Checkbox(cat, L["Separate Guild Group"],
            false, db.tabs.whispers, "guild",
            L["Whispers from guild members group into their own tabbed window. A friend who is also a guild member goes to the friends group."]);
        ui.DependsOn(guild, whispers);

        ui.Header(layout, _G.CHAT or L["Chat"]);
        local chatTabs = ui.Checkbox(cat, L["Group Chat Windows"],
            false, db.tabs.chat, "enabled",
            L["Chat windows share one tabbed window. Does not apply to windows already opened."]);
        local aswhisper = ui.Checkbox(cat, L["Share Tab Group with Whispers"],
            false, db.tabs.chat, "aswhisper",
            L["Chat windows join the whisper tab group instead of their own, even while Group Whispers is off."]);
        ui.DependsOn(aswhisper, chatTabs);
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Combat Auto-Hide"],
        L["Hide windows during combat and restore them after."]);
        ui.Header(layout, L["Hiding"]);
        local combat = ui.Checkbox(cat, L["Hide During Combat"],
            true, db.expose, "combat",
            L["All windows hide when combat starts and are restored when it ends."],
            function()
                if (modules.Expose and modules.Expose.UpdateMenuText) then
                    modules.Expose:UpdateMenuText();
                end
            end);
        local protect = ui.Checkbox(cat, L["Wait While Typing"],
            true, db.expose, "protect",
            L["Hiding waits until you finish typing your message."]);
        ui.DependsOn(protect, combat);
        local groupOnly = ui.Checkbox(cat, L["Only While in an Instance"],
            false, db.expose, "groupOnly",
            L["Combat hiding only happens inside dungeons, raids, battlegrounds, and arenas."]);
        ui.DependsOn(groupOnly, combat);

        ui.Header(layout, L["Animation"]);
        local direction = {L["Up"], L["Down"], L["Left"], L["Right"]};
        local dirList = {};
        for i = 1, #direction do
            table.insert(dirList, { text = direction[i], value = i });
        end
        local dirDrop = ui.Dropdown(cat, L["Animation Direction"], 1, dirList,
            db.expose, "direction",
            L["The direction windows slide out when they hide. Also used by the show/hide key binding. Only applies while Window Animations is on under Appearance > Skin."]);
        if (dirDrop.init and dirDrop.init.AddModifyPredicate) then
            dirDrop.init:AddModifyPredicate(function()
                return db.winAnimation and true or false;
            end);
        end

        ui.Header(layout, L["Indicator"]);
        local exposeBorder = ui.Checkbox(cat, L["Hidden-Windows Indicator"],
            false, db.expose, "border",
            L["A thin border along the screen edge signals that windows are hidden."]);
        local borderSize = ui.Slider(cat, L["Indicator Thickness"], 20, 1, 200, 1,
            db.expose, "borderSize", nil, nil, px);
        ui.DependsOn(borderSize, exposeBorder);
    end
end);

-- --------------------------------------------------------------- Appearance
RegisterModernPage(function(category, ui)
    local folder = ui.Subcategory(category, L["Appearance"],
        L["Skin, fonts, message look, and colors."]);
    local function reskin() LoadSkin(db.skin.selected); end
    local modernActive = function() return SkinLocksOptionsStyle(); end;

    do
        local cat = ui.Subcategory(folder, L["Skin"],
        L["The skin and window chrome."]);
        local function skinItems()
            local skins = GetRegisteredSkins(true);
            local items = {};
            for i = 1, #skins do
                local skin = GetSkinTable(skins[i]);
                local tip = {};
                if (skin.version) then table.insert(tip, L["Version"]..": "..skin.version); end
                if (skin.author) then table.insert(tip, skin.author); end
                if (skin.website) then table.insert(tip, skin.website); end
                table.insert(items, { text = skins[i], value = skins[i],
                    tooltip = table.concat(tip, "\n") });
            end
            return items;
        end
        ui.Dropdown(cat, L["Window Skin"], "WIM Modern", skinItems,
            db.skin, "selected", nil, function(value) LoadSkin(value); end);
        ui.Slider(cat, L["Window Opacity"], 80, 1, 100, 1,
            db, "windowAlpha",
            L["Fades the window frame, header, and buttons; message and input text stay opaque. Modern skins keep their frame art opaque."], props, pct);
        ui.Checkbox(cat, L["Fade When Inactive"], true, db, "winFade",
            L["Windows fade to half opacity after two seconds without the mouse over them."]);
        ui.Checkbox(cat, L["Window Animations"], true, db, "winAnimation",
            L["Animates closing windows toward the minimap, and the slide used by combat auto-hide and the show/hide key binding."]);
        ui.Checkbox(cat, L["Shortcut Bar"], true,
            modules.ShortcutBar, "enabled",
            L["Shows the row of shortcut buttons on message windows. Turning this off takes effect after the next interface reload."],
            function(value) EnableModule("ShortcutBar", value); end);
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Font"],
        L["Message font, outline, and size."]);
        ui.Custom(layout, "WIM3SettingsFontBrowserTemplate",
            { onInit = fontBrowserRowInit, searchTags = { L["Font"], L["Skin default"], "font" } });
        local outlineList = {
            { text = L["None"],  value = "" },
            { text = L["Thin"],  value = "OUTLINE" },
            { text = L["Thick"], value = "THICKOUTLINE" },
        };
        ui.Dropdown(cat, L["Font Outline"], "", outlineList,
            db.skin, "font_outline",
            L["Outline for the message area and input box text."], reskin);
        ui.Tags(ui.Slider(cat, L["Font Size"], 12, 8, 50, 1,
            db, "fontSize",
            L["The message area renders two points larger than the chosen size; the input box and header follow the skin."],
            function() props(); refreshPreview(); end, px),
            "font", "text size");
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Messages"],
        L["How messages are formatted and displayed."]);
        ui.Custom(layout, "WIM3SettingsPreviewTemplate",
            { onInit = previewRowInit, searchTags = { _G.PREVIEW or L["Preview"], L["Messages"] } });

        ui.Header(layout, L["Formatting"]);
        local function formatList()
            local formats = GetMessageFormattingList();
            local items = {};
            for i = 1, #formats do
                table.insert(items, { text = formats[i], value = formats[i] });
            end
            return items;
        end
        local function normalizedFormat()
            local formats = GetMessageFormattingList();
            if (isInTable(formats, db.messageFormat)) then
                return db.messageFormat;
            end
            return formats[1];
        end
        local formatRow = ui.CustomDropdown(cat, L["Message Format"], "Default",
            formatList, normalizedFormat,
            function(value)
                db.messageFormat = value;
                refreshPreview();
            end);
        if (formatRow.init and formatRow.init.AddShownPredicate) then
            formatRow.init:AddShownPredicate(function()
                return #GetMessageFormattingList() > 1;
            end);
        end
        local function defaultFormat()
            return normalizedFormat() == GetMessageFormattingList()[1];
        end

        local colorize = ui.Checkbox(cat, L["Class-Colored Names"], true,
            db, "coloredNames",
            L["Player names take their class color. Applies to new messages."],
            function() UpdateAllWindowProps(); refreshPreview(); end);
        if (colorize.init and colorize.init.AddModifyPredicate) then
            colorize.init:AddModifyPredicate(defaultFormat);
        end
        local bracket = ui.Checkbox(cat, L["Bracket Names"], true,
            db.formatting.bracketing, "enabled",
            L["Wraps player names in brackets."], refreshPreview);
        if (bracket.init and bracket.init.AddModifyPredicate) then
            bracket.init:AddModifyPredicate(defaultFormat);
        end
        local bracketItems = {};
        for i = 1, #lists.bracketing do
            table.insert(bracketItems, {
                text = lists.bracketing[i][1].." "..lists.bracketing[i][2],
                value = i,
            });
        end
        local bracketType = ui.Dropdown(cat, L["Bracket Style"], 1, bracketItems,
            db.formatting.bracketing, "type", nil, refreshPreview);
        ui.DependsOn(bracketType, bracket, function()
            return defaultFormat() and bracket.setting:GetValue();
        end);
        ui.Checkbox(cat, L["Indent Wrapped Lines"], false,
            db, "wordwrap_indent",
            L["Continuation lines of wrapped messages are indented."],
            function() UpdateAllWindowProps(); refreshPreview(); end);

        ui.Header(layout, L["Timestamps"]);
        local ts = ui.Checkbox(cat, L["Show Timestamps"], true,
            modules.TimeStamps, "enabled",
            L["Each message is prefixed with the time it arrived."],
            function(value) EnableModule("TimeStamps", value); refreshPreview(); end);
        local tsItems = {};
        local tsFormats = GetTimeStampFormats();
        for i = 1, #tsFormats do
            table.insert(tsItems, { text = _G.date(tsFormats[i]), value = tsFormats[i] });
        end
        local tsFormat = ui.Dropdown(cat, L["Timestamp Format"], "%H:%M",
            tsItems, db, "timeStampFormat", nil, refreshPreview);
        ui.DependsOn(tsFormat, ts);

        ui.Header(layout, L["Links & Emoticons"]);
        ui.Checkbox(cat, L["Emoticons"], true,
            modules.Emoticons, "enabled",
            L["Text smileys render as icons."],
            function(value) EnableModule("Emoticons", value); refreshPreview(); end);
        ui.Checkbox(cat, L["Clickable Links"], true,
            modules.URLHandler, "enabled",
            L["Web addresses in messages become clickable links."],
            function(value) EnableModule("URLHandler", value); refreshPreview(); end);
        ui.Checkbox(cat, L["Hover Item Tooltips"], false,
            db, "hoverLinks",
            L["Hovering an item link in a message shows its tooltip without clicking."]);
    end

    do
        local _, layout = ui.Subcategory(folder, _G.COLORS or L["Colors"],
        L["Message colors."]);
        addColorPanel(ui, layout, {
            { label = L["Messages Received"], key = "wispIn" },
            { label = L["Messages Sent"], key = "wispOut" },
            { label = L["Battle.net Received"], key = "BNwispIn" },
            { label = L["Battle.net Sent"], key = "BNwispOut" },
            { label = L["System Messages & Timestamps"], key = "sysMsg" },
            { label = L["Error Messages"], key = "errorMsg" },
            { label = L["Web Addresses"], key = "webAddress" },
            { label = L["History Preview Received"], key = "historyIn" },
            { label = L["History Preview Sent"], key = "historyOut" },
        });
    end

    -- Everything the WIM Modern skin exposes, one section per surface;
    -- the roleplay integration is part of that skin too.
    do
        local cat, layout = ui.Subcategory(folder, L["WIM Modern Skin"],
        L["Backgrounds, input field, and roleplay profile options for the WIM Modern skin."]);

        local themingNoteHolder;
        local function ensureThemingNote()
            if (not themingNoteHolder) then
                local noteHolder = CreateFrame("Frame");
                noteHolder:Hide();
                local text = noteHolder:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
                text:SetPoint("TOPLEFT", 37, -8);
                text:SetPoint("TOPRIGHT", -37, -8);
                text:SetJustifyH("LEFT");
                text:SetSpacing(3);
                text:SetTextColor(.8, .8, .8);
                text:SetText(L["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They are available while a modern-only skin is selected on the Skin page; with a classic skin active they are greyed out."]);
                noteHolder.text = text;
                themingNoteHolder = noteHolder;
            end
            return themingNoteHolder;
        end
        ui.Custom(layout, "WIM3SettingsNoteTemplate", {
            onInit = options.HolderRowInit(ensureThemingNote),
            -- Measured from the localized text; the template height
            -- clipped longer translations.
            getExtent = function()
                local width = (options.SettingsListWidth and options.SettingsListWidth() or 600) - 74;
                return 16 + math.ceil(options.WrappedHeight(ensureThemingNote().text, width));
            end,
        });

        local function backgroundItems()
            local items = {};
            local list = GetChromeBackgrounds and GetChromeBackgrounds() or {};
            for i = 1, #list do
                table.insert(items, { value = list[i].key, text = L[list[i].label] });
            end
            return items;
        end
        local reapplyFilter = function()
            if (RestyleFilterFrame) then RestyleFilterFrame(); end
        end;
        local modernControls = {};
        local function modern(control, ...)
            table.insert(modernControls, control);
            return ui.Tags(control, ...);
        end

        ui.Header(layout, L["Message Windows"], L["The whisper and chat windows."]);
        modern(ui.Dropdown(cat, L["Frame Background"], "rock",
            backgroundItems, db.modernTheme, "chatFrame", nil, reskin), "message window");
        modern(ui.Dropdown(cat, L["Message Area Background"], "darkmarble",
            backgroundItems, db.modernTheme, "chatPanel", nil, reskin), "message window");
        modern(ui.Checkbox(cat, L["See-Through Frame"],
            false, db.modernTheme, "chatCutout",
            L["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."],
            reskin), "message window", "cut-out");

        ui.Header(layout, L["Input Field"], L["The message box at the bottom of each window."]);
        local wrapControl = modern(ui.Checkbox(cat, L["Multi-Line Input"],
            true, db.modernTheme, "inputWrap",
            L["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."],
            reskin), "wrap");
        local wrapLimit = modern(ui.Checkbox(cat, L["Limit Height"],
            true, db.modernTheme, "inputWrapLimit",
            L["Caps how far the input field grows; past the limit the message scrolls inside it."],
            reskin), "wrap");
        ui.DependsOn(wrapLimit, wrapControl);
        local wrapLines = modern(ui.Slider(cat, L["Maximum Lines"], 4, 1, 20, 1,
            db.modernTheme, "inputWrapLines",
            L["The most lines the input field grows to before the message scrolls inside it."],
            reskin), "wrap");
        ui.DependsOn(wrapLines, wrapLimit);
        local refreshInput = function()
            if (UpdateAllInputColors) then UpdateAllInputColors(); end
        end;
        local nativeMaster = modern(ui.Checkbox(cat, L["Native Input Colors"],
            true, db.displayColors.useNative, "enabled",
            L["The message being typed takes the color of the chat type it will send as, like the game's own chat box."],
            refreshInput), "color", "input");
        local nativeApply = modern(ui.MultiDropdown(cat, L["Apply To"], {
            { key = "whisper", text = L["Whispers"] },
            { key = "bnet",    text = L["Battle.net Whispers"] },
            { key = "say",     text = _G.SAY },
            { key = "guild",   text = _G.GUILD },
            { key = "officer", text = _G.GUILD_RANK1_DESC },
            { key = "party",   text = _G.PARTY },
            { key = "raid",    text = _G.RAID },
            { key = "instance", text = _G.INSTANCE_CHAT },
            { key = "channel", text = _G.CHANNELS },
        }, db.displayColors, "useNative", nil, L["None"], refreshInput,
            db_defaults.displayColors.useNative), "color", "input");
        ui.DependsOn(nativeApply, nativeMaster);

        ui.Header(layout, L["History Viewer"], L["The message history window."]);
        modern(ui.Dropdown(cat, L["Frame Background"], "rock",
            backgroundItems, db.modernTheme, "frame", nil, reskin), "history viewer");
        modern(ui.Dropdown(cat, L["Navigation List Background"], "darkmarble",
            backgroundItems, db.modernTheme, "panels", nil, reskin), "history viewer");
        modern(ui.Dropdown(cat, L["Content Background"], "darkmarble",
            backgroundItems, db.modernTheme, "content", nil, reskin), "history viewer");
        modern(ui.Checkbox(cat, L["See-Through Frame"],
            false, db.modernTheme, "cutout",
            L["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer."],
            reskin), "history viewer", "cut-out");

        ui.Header(layout, L["Filter Editor"], L["The window for adding and editing whisper and chat filters."]);
        modern(ui.Dropdown(cat, L["Frame Background"], "rock",
            backgroundItems, db.modernTheme, "filterFrame", nil, reapplyFilter), "filter editor");
        modern(ui.Dropdown(cat, L["Filter Panel Background"], "darkmarble",
            backgroundItems, db.modernTheme, "filterPanel", nil, reapplyFilter), "filter editor");
        modern(ui.Checkbox(cat, L["See-Through Frame"],
            false, db.modernTheme, "filterCutout",
            L["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."],
            reapplyFilter), "filter editor", "cut-out");

        ui.Header(layout, L["Roleplay Profiles"],
            L["Total RP 3 and Mary Sue Protocol profile display on whisper windows."]);
        local rpEnable = modern(ui.Checkbox(cat, L["Show Roleplay Profiles"],
            false, db.modernTheme, "rpEnabled",
            L["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer. Requires the WIM Modern skin."],
            function()
                if (RefreshRPProfiles) then
                    RefreshRPProfiles();
                end
            end), "roleplay", "rp", "trp");
        local rpFieldsControl = modern(ui.MultiDropdown(cat, L["Profile Fields"], {
            { key = "firstName", text = L["First Name"],
              tooltip = L["The profile's first name, shown as the window's name text."] },
            { key = "lastName", text = L["Last Name"],
              tooltip = L["The profile's last name, shown as the window's name text."] },
            { key = "title", text = L["Title"],
              tooltip = L["The short title, shown on the window's details line."] },
            { key = "fullTitle", text = L["Full Title"],
              tooltip = L["The long title, shown on the window's details line and portrait tooltip."] },
            { key = "race", text = L["Race"],
              tooltip = L["The custom race, replacing the character's race on the details line."] },
            { key = "class", text = L["Class"],
              tooltip = L["The custom class, replacing the character's class on the details line."] },
            { key = "portrait", text = L["Portrait"],
              tooltip = L["The profile's icon, replacing the class icon."] },
            { key = "color", text = L["Name & Class Color"],
              tooltip = L["The profile's custom color, applied to the window's name text and to the class on the details line."] },
        }, db.modernTheme, "rpFields",
            L["Whisper windows show the selected fields from the partner's Total RP 3 or Mary Sue Protocol profile. Fields left unselected -- or without profile data -- keep the standard display."],
            L["None (game default)"],
            function()
                if (RefreshRPProfiles) then
                    RefreshRPProfiles();
                end
            end,
            db_defaults.modernTheme.rpFields), "roleplay", "rp", "trp");
        ui.DependsOn(rpFieldsControl, rpEnable);

        for i = 1, #modernControls do
            local control = modernControls[i];
            if (control and control.init and control.init.AddModifyPredicate) then
                control.init:AddModifyPredicate(modernActive);
            end
        end
    end
end);

-- ------------------------------------------------------------ Notifications
RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, L["Notifications"],
        L["Sounds for whispers and chat, and how they are played."]);

    ui.Header(layout, L["Whisper Sounds"]);
    local wIn = addSoundPair(cat, ui, L["Incoming Whispers"],
        db.sounds.whispers, db_defaults.sounds.whispers, "msgin", "msgin_sml",
        L["Plays a sound when a whisper arrives."]);
    addSoundPair(cat, ui, L["Sent Whispers"],
        db.sounds.whispers, db_defaults.sounds.whispers, "msgout", "msgout_sml",
        L["Plays a sound when you send a whisper."]);

    local wDistinct = ui.Expandable(layout, L["Distinct Whisper Sounds"],
        L["Optional different sounds for whispers from particular senders."], true, cat);
    local bnetPair = { addSoundPair(cat, ui, L["Battle.net Friends"],
        db.sounds.whispers, db_defaults.sounds.whispers, "bnet", "bnet_sml",
        L["Plays this sound instead of the standard incoming whisper sound when a Battle.net friend whispers. When several match, Battle.net friend wins over friend and guild member."]) };
    local friendPair = { addSoundPair(cat, ui, L["Friends"],
        db.sounds.whispers, db_defaults.sounds.whispers, "friend", "friend_sml",
        L["Plays this sound instead of the standard incoming whisper sound."]) };
    local guildPair = { addSoundPair(cat, ui, L["Guild Members"],
        db.sounds.whispers, db_defaults.sounds.whispers, "guild", "guild_sml",
        L["Plays this sound instead of the standard incoming whisper sound."]) };
    for _, pair in pairs({ bnetPair, friendPair, guildPair }) do
        wDistinct.Add(pair[1]);
        wDistinct.Add(pair[2]);
        ui.DependsOn(pair[1], wIn);
    end

    ui.Header(layout, L["Chat Sounds"]);
    local cIn = addSoundPair(cat, ui, L["Incoming Chat"],
        db.sounds.chat, db_defaults.sounds.chat, "msgin", "msgin_sml",
        L["Plays a sound when a captured chat message arrives. Per-channel No Sound flags on the channel lists mute individual channels."]);
    addSoundPair(cat, ui, L["Sent Chat"],
        db.sounds.chat, db_defaults.sounds.chat, "msgout", "msgout_sml",
        L["Plays a sound when you send a message in a captured chat type, from WIM or the game's chat box."]);

    local cDistinct = ui.Expandable(layout, L["Distinct Chat Sounds"],
        L["Optional different sounds per chat type."], true, cat);
    local chatSoundRows = {
        { name = _G.GUILD,                  key = "guild" },
        { name = _G.GUILD_RANK1_DESC,       key = "officer" },
        { name = _G.PARTY,                  key = "party" },
        { name = _G.RAID,                   key = "raid",
          tooltip = L["Plays a distinct sound for raid chat instead of the standard incoming sound; raid warnings keep the standard sound. It never mutes."] },
        { name = _G.RAID_LEADER,            key = "raidleader" },
        { name = _G.INSTANCE_CHAT,          key = "battleground" },
        { name = _G.INSTANCE_CHAT_LEADER,   key = "battlegroundleader" },
        { name = _G.SAY,                    key = "say" },
        { name = L["World Chat"],           key = "world" },
        { name = L["Custom Chat"],          key = "custom" },
        { name = L["Community Chat"],       key = "community" },
    };
    for i = 1, #chatSoundRows do
        local rowInfo = chatSoundRows[i];
        local flag, sound = addSoundPair(cat, ui,
            rowInfo.name,
            db.sounds.chat, db_defaults.sounds.chat,
            rowInfo.key, rowInfo.key.."_sml",
            rowInfo.tooltip or L["Plays a distinct sound for this chat type instead of the standard incoming sound; it never mutes. Use a channel's No Sound flag or turn off incoming chat sounds to silence."]);
        cDistinct.Add(flag);
        cDistinct.Add(sound);
        ui.DependsOn(flag, cIn);
    end

    ui.Header(layout, L["Playback"]);
    ui.Checkbox(cat, L["Use Master Sound Channel"],
        true, db.sounds, "use_master",
        L["Plays notification sounds on the Master channel so they are heard even when sound effects are turned off."]);
    ui.Checkbox(cat, L["Override Muted Audio"],
        false, db.sounds, "force_game_sound",
        L["Briefly turns game audio back on so a notification can be heard while all sound is disabled. The Master channel alone cannot get past that setting."]);
end);

-- ------------------------------------------------------ Privacy & Filtering
RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, L["Privacy & Filtering"],
        L["Who gets through."]);

    ui.Header(layout, L["Whispers"]);
    local filterWhispers = ui.Tags(ui.Checkbox(cat, L["Filter Whispers"], true,
        modules.Filters, "enabled",
        L["Runs the whisper filter list below. While off, addon-spam whispers open windows like any other whisper."],
        function(value) EnableModule("Filters", value); end),
        "block", "ignore", "filter", "spam");
    -- The known-senders switch drives two entries of that list, so it is
    -- inert while the list is not running.
    local knownSenders = ui.Tags(ui.CustomCheckbox(cat, L["Known Senders Only"],
        false, knownSendersGet, knownSendersSet,
        L["Friends, Battle.net friends, guild members, and your current party and raid get through; whispers from anyone else are ignored. This drives the two WhisperSelect entries in the filter list below."]),
        "block", "ignore", "privacy", "spam");
    ui.DependsOn(knownSenders, filterWhispers);
    ui.Custom(layout, "WIM3SettingsFilterListTemplate",
        { isChat = false, onInit = filterRowInit, getExtent = filterExtent(false),
          searchTags = { L["Filters"], L["Whispers"], L["Add Filter"], L["Edit Filter"], L["Delete Filter"], "block", "ignore", "spam" } });

    ui.Header(layout, _G.CHAT or L["Chat"]);
    ui.Checkbox(cat, L["Filter Chat"], false,
        modules.ChatFilters, "enabled",
        L["Applies the filter list below to captured chat messages. Community chat is not filtered."],
        function(value) EnableModule("ChatFilters", value); end);
    ui.Custom(layout, "WIM3SettingsFilterListTemplate",
        { isChat = true, onInit = filterRowInit, getExtent = filterExtent(true),
          searchTags = { L["Filters"], _G.CHAT or L["Chat"], L["Add Filter"], L["Edit Filter"], L["Delete Filter"], "block", "ignore", "spam" } });
end);

-- ------------------------------------------------------------------ History
RegisterModernPage(function(category, ui)
    local folder = ui.Subcategory(category, L["History"],
        L["What is kept, and for how long."]);
    do
        local cat, layout = ui.Subcategory(folder, L["Recording"],
        L["Which whispers and chat types are recorded."]);
        ui.Header(layout, L["Whispers"]);
        local wEnable = ui.Checkbox(cat, L["Record Whispers"], true,
            modules.History, "enabled",
            L["Recording stops as soon as this is off; the history button stays on open windows until the next reload."],
            function(value) EnableModule("History", value); end);

        local scopeItems = {
            { text = L["Everyone"], value = "everyone",
              tooltip = L["Every whisper is recorded."] },
            { text = L["Friends & guild"], value = "fg",
              tooltip = L["Friends, Battle.net friends, and guild members."] },
            { text = L["Friends only"], value = "friends",
              tooltip = L["Friends and Battle.net friends."] },
            { text = L["Guild only"], value = "guild",
              tooltip = L["Guild members."] },
            { text = L["No one (GM whispers only)"], value = "none",
              tooltip = L["Nothing is recorded except game master whispers."] },
        };
        local w = db.history.whispers;
        local scope = ui.CustomDropdown(cat, L["Record From"], "everyone",
            scopeItems,
            function()
                if (w.all) then return "everyone"; end
                if (w.friends and w.guild) then return "fg"; end
                if (w.friends) then return "friends"; end
                if (w.guild) then return "guild"; end
                return "none";
            end,
            function(value)
                w.all = value == "everyone";
                w.friends = value == "everyone" or value == "fg" or value == "friends";
                w.guild = value == "everyone" or value == "fg" or value == "guild";
            end,
            L["Whispers from game masters are always recorded. Battle.net whispers count as friends."]);
        ui.DependsOn(scope, wEnable);

        ui.Header(layout, _G.CHAT or L["Chat"]);
        local cEnable = ui.Checkbox(cat, L["Record Chat"], false,
            modules.HistoryChat, "enabled",
            L["Recording stops as soon as this is off; the history button stays on open windows until the next reload."],
            function(value) EnableModule("HistoryChat", value); end);
        local recordTypes = {
            { name = _G.GUILD,            key = "guild" },
            { name = _G.GUILD_RANK1_DESC, key = "officer" },
            { name = _G.PARTY,            key = "party" },
            { name = _G.RAID,             key = "raid",
              tooltip = L["Includes raid warnings."] },
            { name = _G.INSTANCE_CHAT,    key = "battleground" },
            { name = _G.SAY,              key = "say",
              tooltip = L["Includes emotes."] },
            { name = L["World Chat"],     key = "world" },
            { name = L["Custom Chat"],    key = "custom" },
        };
        for j = 1, #recordTypes do
            local row = ui.Checkbox(cat, L["Record"].." "..recordTypes[j].name,
                false, db.history.chat, recordTypes[j].key, recordTypes[j].tooltip);
            ui.DependsOn(row, cEnable);
        end
    end

    do
        local cat, layout = ui.Subcategory(folder, L["Storage"],
        L["Retention caps, preview, and deletion."]);
        local previewList = {};
        for i = 1, 10 do
            table.insert(previewList, { text = (i*5).." "..L["Messages"], value = i*5 });
        end
        local countList = {};
        for _, count in pairs({100, 200, 500, 1000}) do
            table.insert(countList, { text = count.." "..L["Messages"], value = count });
        end
        local ageList = {};
        for i = 1, 5 do
            table.insert(ageList, { text = string.format(L["%d |4Week:Weeks;"], i),
                                    value = 60*60*24*7*i });
        end

        ui.Header(layout, _G.PREVIEW or L["Preview"]);
        local preview = ui.Checkbox(cat, L["Preview Recent Messages"],
            true, db.history, "preview",
            L["Shows the most recent messages when a window opens. Applies to whisper and chat history alike, and requires Record Whispers."]);
        if (preview.init and preview.init.AddModifyPredicate) then
            -- The preview is drawn by the whisper history module for
            -- both window kinds.
            preview.init:AddModifyPredicate(function()
                return modules.History and modules.History.enabled and true or false;
            end);
        end
        local previewCount = ui.Dropdown(cat, L["Preview Count"], 25,
            previewList, db.history, "previewCount");
        ui.DependsOn(previewCount, preview);

        ui.Header(layout, L["Retention"]);
        local maxPer = ui.Checkbox(cat, L["Cap Stored Messages"],
            true, db.history, "maxPer",
            L["Keeps at most this many messages per conversation. Applies to whisper and chat history alike."]);
        local maxCount = ui.Dropdown(cat, L["Messages per Conversation"], 500,
            countList, db.history, "maxCount");
        ui.DependsOn(maxCount, maxPer);

        local ageLimit = ui.Checkbox(cat, L["Delete Old Messages"],
            true, db.history, "ageLimit",
            L["Applies to whisper and chat history alike. Pruning runs at login."]);
        local maxAge = ui.Dropdown(cat, L["Older Than"], 60*60*24*7*2,
            ageList, db.history, "maxAge");
        ui.DependsOn(maxAge, ageLimit);

        ui.Header(layout, L["Actions"]);
        ui.Button(layout, L["History Viewer"], L["Open History Viewer"],
            function() ShowHistoryViewer(); end);
        ui.Button(layout, L["Delete All History"], L["Delete All History"],
            function()
                if (ShowClearHistoryPopup) then
                    ShowClearHistoryPopup();
                end
            end,
            L["Erases every recorded conversation and the archive for every character on this account, then reloads the interface."]);
    end
end);
