--imports
local WIM = WIM;
local _G = _G;
local table = table;
local string = string;
local pairs = pairs;
local tostring = tostring;
local tonumber = tonumber;
local pcall = pcall;
local CreateFrame = CreateFrame;

--set namespace
setfenv(1, WIM);

-- ---------------------------------------------------------------------------
-- Modern option pages (Options > AddOns > WIM).
--
-- Native rebuilds of the classic pages. Every control binds to the same
-- db key and fires the same refresh hook as its classic counterpart, so
-- the two UIs are interchangeable. The classic builders in
-- CoreOptions.lua and ChatEngine.lua are the authoritative list of
-- bindings; when adding a setting there, mirror it here.
--
-- Every page is a native vertical-layout page, with the same rows,
-- dropdowns, sliders, and headers the rest of the Settings panel uses.
-- Content without a native control (the live formatting preview, the
-- font browser, the color swatches) sits inside custom element rows
-- registered through templates in ModernSettings.xml; the settings list
-- pools and scrolls them like any other row.
--
-- Proxy-setting defaults are read from the live db at build time, after
-- the defaults merge has run, so a missing defaults path can never error.
-- The only cost: the panel's "reset to default" restores the login-time
-- value.
-- ---------------------------------------------------------------------------

-- Inert without the registry (old clients: ModernSettings bailed out early).
if (not options or not options.RegisterModernPage) then
    return;
end

local RegisterModernPage = options.RegisterModernPage;

-- ------------------------------------------------------------ shared pieces

-- Window Behavior section; the whisper and chat variants share the
-- shape. The classic page's 7-state tab strip becomes a state dropdown.
-- The five rule checkboxes bind through a function dbTree that closes
-- over the selected state, and a state change broadcasts
-- NotifyModernSettings so the visible checkboxes re-read the new state
-- immediately.
local popStates = {"arena", "combat", "pvp", "raid", "party", "resting", "other"};

local function addPopRulesSection(cat, layout, ui, winType)
    ui.Header(layout, L["Window Behavior"]);
    local rules = db.pop_rules[winType];
    -- The selected state is local to this view, except that "use the
    -- same rules for all states" pins it to Other. Putting that rule in
    -- the accessor, not in the checkbox's click handler, means the pin
    -- also applies when the flag changes from the classic UI: every
    -- re-read lands on Other, whatever caused it.
    local stateTbl = { state = "other" };
    local function stateHolder()
        if (rules.alwaysOther) then
            stateTbl.state = "other";
        end
        return stateTbl;
    end
    local function stateDB()
        return db.pop_rules[winType][stateHolder().state];
    end

    local intercept = ui.Checkbox(cat, L["Intercept Slash Commands"],
        rules.intercept, rules, "intercept");
    if (winType == "whisper") then
        local reply = ui.Checkbox(cat, L["Include sent messages in /REPLY."],
            rules.replyIncludesSent, rules, "replyIncludesSent");
        ui.DependsOn(reply, intercept);
    end

    ui.Checkbox(cat, L["Obey autofocus rules when opening frames via the menu. (autofocus if unchecked)"],
        rules.obeyAutoFocusRules, rules, "obeyAutoFocusRules");

    local alwaysOther = ui.Checkbox(cat, L["Use the same rules for all states."],
        rules.alwaysOther, rules, "alwaysOther", nil,
        function() options.NotifyModernSettings(); end);

    local stateItems = {};
    for i = 1, #popStates do
        table.insert(stateItems, {
            text = _G[string.upper(popStates[i])] or L["state_resting"],
            value = popStates[i],
        });
    end
    local stateDrop = ui.Dropdown(cat, L["Behaviors for state:"], "other",
        stateItems, stateHolder, "state", nil,
        function() options.NotifyModernSettings(); end);
    ui.DependsOn(stateDrop, alwaysOther, function()
        return not alwaysOther.setting:GetValue();
    end);

    ui.Checkbox(cat, L["Pop-Up window when message is sent."],
        stateDB().onSend, stateDB, "onSend");
    ui.Checkbox(cat, L["Pop-Up window when message is received."],
        stateDB().onReceive, stateDB, "onReceive");
    ui.Checkbox(cat, L["Auto focus a window when it is shown."],
        stateDB().autofocus, stateDB, "autofocus");
    ui.Checkbox(cat, L["Keep focus on window after sending a message."],
        stateDB().keepfocus, stateDB, "keepfocus");
    ui.Checkbox(cat, L["Suppress messages from the default chat frame."],
        stateDB().supress, stateDB, "supress");

    if (winType == "whisper" and _G.GetCVar and _G.GetCVar("whisperMode")) then
        ui.Button(layout,
            L["Message suppression requires whispers to be set to 'In-line'."],
            L["Set whispers to In-line"],
            function(self)
                _G.SetCVar("whisperMode", "inline");
                -- The row only re-initializes on redisplay; grey the
                -- clicked button right away.
                if (self and self.SetEnabled) then
                    self:SetEnabled(false);
                end
            end,
            L["Sets the game's Social > Whisper Mode setting to In-line. Without it, suppressed whispers would vanish into a popout chat tab."],
            function() return _G.GetCVar("whisperMode") ~= "inline"; end);
    end
end

-- History section (whisper/chat variants). The CHAT variant's maintenance
-- settings bind to db.history.chat (what the recorder actually reads).
local function addHistorySection(cat, layout, ui, isChat)
    ui.Header(layout, L["History"]);
    local moduleName = isChat and "HistoryChat" or "History";
    local historyDB = isChat and db.history.chat or db.history;

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

    local enable = ui.Checkbox(cat, L["Enable History"],
        modules[moduleName].enabled, modules[moduleName], "enabled", nil,
        function(value) EnableModule(moduleName, value); end);

    local preview = ui.Checkbox(cat, L["Preview history inside message windows."],
        historyDB.preview, historyDB, "preview");
    ui.DependsOn(preview, enable);
    local previewCount = ui.Dropdown(cat, L["Messages"],
        historyDB.previewCount, previewList, historyDB, "previewCount");
    ui.DependsOn(previewCount, preview);

    if (not isChat) then
        ui.Checkbox(cat, L["Record Friends"], historyDB.whispers.friends,
            historyDB.whispers, "friends");
        ui.Checkbox(cat, L["Record Guild"], historyDB.whispers.guild,
            historyDB.whispers, "guild");
        ui.Checkbox(cat, L["Record Everyone"], historyDB.whispers.all,
            historyDB.whispers, "all");
    else
        local recordTypes = {
            { name = _G.GUILD,            key = "guild" },
            { name = _G.GUILD_RANK1_DESC, key = "officer" },
            { name = _G.PARTY,            key = "party" },
            { name = _G.RAID,             key = "raid" },
            { name = _G.SAY,              key = "say" },
            { name = _G.INSTANCE_CHAT,    key = "battleground" },
            { name = L["World Chat"],     key = "world" },
            { name = L["Custom Chat"],    key = "custom" },
        };
        for j = 1, #recordTypes do
            ui.Checkbox(cat, L["Record"].." "..recordTypes[j].name,
                historyDB[recordTypes[j].key], historyDB, recordTypes[j].key);
        end
    end

    local maxPer = ui.Checkbox(cat, L["Save a maximum number of messages per person."],
        historyDB.maxPer, historyDB, "maxPer");
    local maxCount = ui.Dropdown(cat, L["Messages"],
        historyDB.maxCount, countList, historyDB, "maxCount");
    ui.DependsOn(maxCount, maxPer);

    local ageLimit = ui.Checkbox(cat, L["Automatically delete old messages."],
        historyDB.ageLimit, historyDB, "ageLimit");
    local maxAge = ui.Dropdown(cat, L["Age"],
        historyDB.maxAge, ageList, historyDB, "maxAge");
    ui.DependsOn(maxAge, ageLimit);
end

-- Sounds section pieces. The item list is rebuilt on every dropdown
-- open, so late LibSharedMedia registrations appear. Selecting a sound
-- plays it, matching the classic list's play-on-hover behavior.
local function soundItems()
    local list = {};
    for sound in pairs(libs.SML.MediaTable.sound) do
        table.insert(list, { text = sound, value = sound });
    end
    table.sort(list, function(a, b) return a.text < b.text; end);
    return list;
end

local function soundPreview(value)
    _G.PlaySoundFile(libs.SML:Fetch(libs.SML.MediaType.SOUND, value));
end

local function addSoundPair(cat, ui, name, dbTree, flagKey, soundKey)
    local flag = ui.Checkbox(cat, name, dbTree[flagKey], dbTree, flagKey);
    local sound = ui.Dropdown(cat, L["Sound"], dbTree[soundKey] or "",
        soundItems, dbTree, soundKey, nil, soundPreview);
    ui.DependsOn(sound, flag);
end

-- ----------------------------------------------- custom settings-list rows
-- Layout constants matching the native rows: labels indented like row
-- titles, controls in the settings control column.
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
        if (options.RefreshClassicPages) then
            options.RefreshClassicPages();
        end
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

-- Grouped color panel, built like the Accessibility > Colors page: a
-- header with the swatch rows beneath it, each label tinted in its
-- current color, each swatch the game's own ColorSwatchTemplate. The
-- panel frame is pooled per template, so the row set rebinds on every
-- Init; the two pages carry different color lists.
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
    -- The game's own row template first; a hand-built equivalent only
    -- for clients without it (same shape, same offsets).
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
    prev:SetFont(font, 14, db.skin.font_outline);
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
        -- The nameplate preview's construction: a child plate inset
        -- 20px from the row's edges, with the PREVIEW tag inside.
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

-- Font browser row: every LibSharedMedia font rendered in its own
-- face. Persistent for the same reason as the preview.
local browserHolder;
local FONT_ROW_HEIGHT = 24;
-- The client loads a font file asynchronously on first use: SetFont
-- returns false on the session's first attempt and succeeds later. A
-- failed face therefore schedules one retry pass, and only a face that
-- fails repeatedly is reported to the debug log.
local fontFaceAttempts = {};

local function refreshFontBrowser()
    if (browserHolder and browserHolder:IsVisible()) then
        browserHolder:RefreshList();
    end
end
options.RegisterModernRefresh(refreshFontBrowser);

local function buildFontBrowser()
    local holder = CreateFrame("Frame");
    holder:Hide();

    local border = CreateFrame("Frame", nil, holder);
    border:SetPoint("TOPLEFT", 20, -4);
    border:SetPoint("BOTTOMRIGHT", -20, 4);
    options.AddOptionsPlate(border);

    -- Prefer the modern generic scroll frame (thin minimal scrollbar).
    local ok, scroll = pcall(CreateFrame, "ScrollFrame", nil, border, "ScrollFrameTemplate");
    if (not ok or not scroll) then
        scroll = CreateFrame("ScrollFrame", "WIM3_ModernFontScrollFrame", border, "UIPanelScrollFrameTemplate");
    end
    -- Classic-flavor clients ship both templates with the old wide
    -- scrollbar; swap it for the slim one either way.
    if (not HasPortraitPanelArt()) then
        AttachMinimalScrollBar(scroll, border);
    end
    scroll:SetPoint("TOPLEFT", 4, -4);
    scroll:SetPoint("BOTTOMRIGHT", -24, 4);
    local content = CreateFrame("Frame", nil, scroll);
    content:SetSize(560, 1);
    scroll:SetScrollChild(content);
    scroll:SetScript("OnSizeChanged", function(self, w)
        if (w and w > 0) then
            content:SetWidth(w);
        end
    end);

    local rows = {};
    local function ensureRow(index)
        local row = rows[index];
        if (row) then
            return row;
        end
        row = CreateFrame("Button", nil, content);
        row:SetHeight(FONT_ROW_HEIGHT);
        row:SetPoint("TOPLEFT", 0, -(index - 1) * FONT_ROW_HEIGHT);
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0);
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
        -- The name renders in the default UI font, so it is always
        -- readable even when the face itself cannot render. A sample
        -- string in the font's own face sits beside it.
        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        row.title:SetPoint("TOPLEFT", 8, 0);
        row.title:SetPoint("BOTTOM");
        row.title:SetPoint("RIGHT", row, "LEFT", 260, 0);
        row.title:SetJustifyH("LEFT");
        row.sample = row:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
        row.sample:SetPoint("TOPLEFT", row, "TOPLEFT", 270, 0);
        row.sample:SetPoint("BOTTOMRIGHT", -4, 0);
        row.sample:SetJustifyH("LEFT");
        row:SetScript("OnClick", function(self)
            _G.PlaySound(856);
            db.skin.font = self.font;
            options.DebugSetting("modern", "skin.font", self.font);
            LoadSkin(db.skin.selected);
            holder:RefreshList();
            if (options.RefreshClassicPages) then
                options.RefreshClassicPages();
            end
        end);
        rows[index] = row;
        return row;
    end

    local fontList = {};
    holder.RefreshList = function()
        for key in pairs(fontList) do fontList[key] = nil; end
        for font in pairs(libs.SML.MediaTable.font) do
            table.insert(fontList, font);
        end
        table.sort(fontList);
        local w = scroll:GetWidth();
        if (w and w > 0) then
            content:SetWidth(w);
        end
        content:SetHeight(#fontList * FONT_ROW_HEIGHT);
        local anyFailed = false;
        for i = 1, #fontList do
            local row = ensureRow(i);
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
            if (db.skin.font == fontList[i]) then
                row:LockHighlight();
            else
                row:UnlockHighlight();
            end
            row:Show();
        end
        for i = #fontList + 1, #rows do
            rows[i]:Hide();
        end

        -- Self-heal: give first-touch faces one more pass after the async
        -- load has had a moment.
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

local function addColorPanel(ui, layout, colors)
    ui.Custom(layout, "WIM3SettingsColorPanelTemplate", {
        panel = true,
        -- header (20) + gap (10) + rows at 20 spaced 10 + bottom pad.
        extent = 30 + #colors * 30,
        colors = colors,
        onInit = colorPanelInit,
    });
end

local function fontBrowserRowInit(row)
    if (not browserHolder) then
        browserHolder = buildFontBrowser();
    end
    options.AttachRowHolder(row, browserHolder);
    browserHolder:RefreshList();
    -- Second pass on the next frame. The list sizes the row after Init,
    -- and a font file used for the first time this session may not
    -- render on the same frame it is set. One deferred re-render settles
    -- both.
    if (_G.C_Timer and _G.C_Timer.After) then
        _G.C_Timer.After(0, function()
            if (browserHolder and browserHolder:IsVisible()) then
                browserHolder:RefreshList();
            end
        end);
    end
end

-- Filter list row (whisper and chat variants). One persistent holder
-- per variant, reparented into its pooled element row on display, like
-- the font browser. The classic modal editor (Modules/Filters.lua) is
-- shared; its OnHide broadcasts NotifyModernSettings, so these lists
-- follow saves from either UI.
local FILTER_ROW_HEIGHT = 32;
local FILTER_VISIBLE_ROWS = 6;
local filterHolders = {};

local function makeFilterHolder(isChat)
    local holder = CreateFrame("Frame");
    holder:Hide();
    local function ftab()
        return isChat and chatFilters or filters;
    end
    local filterTypes = {L["Pattern"], L["User Type"], L["User Level"]};
    local filterActions = {L["Allow"], L["Ignore"], L["Block"]};

    local border = CreateFrame("Frame", nil, holder);
    border:SetPoint("TOPLEFT", 20, -4);
    border:SetPoint("BOTTOMRIGHT", -20, 34);
    options.AddOptionsPlate(border);

    local ok, scroll = pcall(CreateFrame, "ScrollFrame", nil, border, "ScrollFrameTemplate");
    if (not ok or not scroll) then
        scroll = CreateFrame("ScrollFrame", "WIM3_ModernFilterScroll"..(isChat and "Chat" or "Whisper"),
            border, "UIPanelScrollFrameTemplate");
    end
    if (not HasPortraitPanelArt()) then
        AttachMinimalScrollBar(scroll, border);
    end
    scroll:SetPoint("TOPLEFT", 4, -4);
    scroll:SetPoint("BOTTOMRIGHT", -24, 4);
    local content = CreateFrame("Frame", nil, scroll);
    content:SetSize(540, 1);
    scroll:SetScrollChild(content);
    scroll:SetScript("OnSizeChanged", function(self, w)
        if (w and w > 0) then
            content:SetWidth(w);
        end
    end);

    local rows = {};
    local function ensureRow(index)
        local row = rows[index];
        if (row) then
            return row;
        end
        row = CreateFrame("Button", nil, content);
        row:SetHeight(FILTER_ROW_HEIGHT);
        row:SetPoint("TOPLEFT", 0, -(index - 1) * FILTER_ROW_HEIGHT);
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0);
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");

        row.cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
        row.cb:SetPoint("TOPLEFT");
        row.cb:SetScale(.75);
        row.cb:SetScript("OnClick", function(self)
            row.filter.enabled = self:GetChecked() and true or false;
            options.DebugSetting("modern", "filter."..(row.filter.name or "?")..".enabled",
                row.filter.enabled);
            holder:RefreshList();
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

        row.down = CreateFrame("Button", nil, row);
        row.down:SetSize(14, 14);
        row.down:SetPoint("TOPRIGHT", -2, -2);
        row.down:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\down");
        row.down:SetHighlightTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\down", "ADD");
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
        row.up:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\up");
        row.up:SetHighlightTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\up", "ADD");
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
        rows[index] = row;
        return row;
    end

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
        if (options.RefreshClassicPages) then
            options.RefreshClassicPages();
        end
    end);

    holder.RefreshList = function()
        local list = ftab();
        local w = scroll:GetWidth();
        if (w and w > 0) then
            content:SetWidth(w);
        end
        content:SetHeight(#list * FILTER_ROW_HEIGHT);
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
        for i = #list + 1, #rows do
            rows[i]:Hide();
        end
        holder.edit:SetEnabled(holder.selected ~= nil);
        holder.delete:SetEnabled(holder.selected ~= nil
            and list[holder.selected] ~= nil
            and not list[holder.selected].protected);
    end

    options.RegisterModernRefresh(function()
        if (holder:IsVisible()) then
            holder:RefreshList();
        end
    end);
    return holder;
end

local function filterRowInit(row, data)
    local key = data.isChat and "chat" or "whisper";
    if (not filterHolders[key]) then
        filterHolders[key] = makeFilterHolder(data.isChat);
    end
    local holder = filterHolders[key];
    options.AttachRowHolder(row, holder);
    holder:RefreshList();
end

-- Channel list row (world, custom, community). Same persistent-holder
-- pattern. Each row carries the six per-channel toggles with native
-- tooltips instead of the classic page's shared help line.
local CHANNEL_ROW_HEIGHT = 64;
local channelHolders = {};

local channelToggles = {
    { key = "monitor",       label = L["Monitor"],             help = L["Have WIM monitor this channel."] },
    { key = "neverPop",      label = L["Never Pop"],           help = L["Never have this window pop-up on my screen."] },
    { key = "neverSuppress", label = L["Never Suppress"],      help = L["Never suppress messages from the default chat frame."] },
    { key = "showAlerts",    label = L["Minimap Alerts"],      help = L["Show unread message alert on minimap."] },
    { key = "noHistory",     label = L["No History"],          help = L["Do not record history for this channel."] },
    { key = "noSound",       label = L["No Sound"],            help = L["Do not play sounds for this channel."] },
};

local function makeChannelHolder(channelType, listFun)
    local holder = CreateFrame("Frame");
    holder:Hide();

    local border = CreateFrame("Frame", nil, holder);
    border:SetPoint("TOPLEFT", 20, -4);
    border:SetPoint("BOTTOMRIGHT", -20, 4);
    options.AddOptionsPlate(border);

    local ok, scroll = pcall(CreateFrame, "ScrollFrame", nil, border, "ScrollFrameTemplate");
    if (not ok or not scroll) then
        scroll = CreateFrame("ScrollFrame", "WIM3_ModernChannelScroll"..channelType,
            border, "UIPanelScrollFrameTemplate");
    end
    if (not HasPortraitPanelArt()) then
        AttachMinimalScrollBar(scroll, border);
    end
    scroll:SetPoint("TOPLEFT", 4, -4);
    scroll:SetPoint("BOTTOMRIGHT", -24, 4);
    local content = CreateFrame("Frame", nil, scroll);
    content:SetSize(540, 1);
    scroll:SetScrollChild(content);
    scroll:SetScript("OnSizeChanged", function(self, w)
        if (w and w > 0) then
            content:SetWidth(w);
        end
    end);

    local rows = {};
    local function ensureRow(index)
        local row = rows[index];
        if (row) then
            return row;
        end
        row = CreateFrame("Frame", nil, content);
        row:SetHeight(CHANNEL_ROW_HEIGHT);
        row:SetPoint("TOPLEFT", 0, -(index - 1) * CHANNEL_ROW_HEIGHT);
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0);
        row.bg = row:CreateTexture(nil, "BACKGROUND");
        row.bg:SetAllPoints();
        row.bg:SetColorTexture(1, 1, 1, (index % 2) * .06);

        row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        row.title:SetPoint("TOPLEFT", 8, -4);
        row.title:SetPoint("RIGHT");
        row.title:SetJustifyH("LEFT");

        row.toggles = {};
        for t = 1, #channelToggles do
            local toggle = channelToggles[t];
            local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
            cb:SetScale(.7);
            local col = (t - 1) % 3;
            local line = (t - 1 - col) / 3;
            cb:SetPoint("TOPLEFT", 8 + col * 240, -(20 + line * 22));
            cb.text = cb:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            cb.text:SetPoint("LEFT", cb, "RIGHT", 2, 0);
            cb.text:SetText(toggle.label);
            cb.key = toggle.key;
            cb.help = toggle.help;
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
                if (db.showToolTips == true) then
                    _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    _G.GameTooltip:SetText(self.help, nil, nil, nil, nil, true);
                end
            end);
            cb:SetScript("OnLeave", function()
                _G.GameTooltip:Hide();
            end);
            row.toggles[toggle.key] = cb;
        end
        rows[index] = row;
        return row;
    end

    holder.RefreshList = function()
        local channelList = listFun();
        local w = scroll:GetWidth();
        if (w and w > 0) then
            content:SetWidth(w);
        end
        content:SetHeight(#channelList * CHANNEL_ROW_HEIGHT);
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

            for key, cb in pairs(row.toggles) do
                cb:SetChecked(settings[key] and true or false);
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
        for i = #channelList + 1, #rows do
            rows[i]:Hide();
        end
    end

    options.RegisterModernRefresh(function()
        if (holder:IsVisible()) then
            holder:RefreshList();
        end
    end);
    return holder;
end

local function channelRowInit(row, data)
    if (not channelHolders[data.channelType]) then
        channelHolders[data.channelType] = makeChannelHolder(data.channelType, data.list);
    end
    local holder = channelHolders[data.channelType];
    options.AttachRowHolder(row, holder);
    holder:RefreshList();
end

-- ------------------------------------------------------------------ General
RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, L["General"]);

    -- Main -----------------------------------------------------------------
    ui.Header(layout, L["Main"]);

    ui.Checkbox(cat, L["Enable WIM"], db.enabled, db, "enabled", nil,
        function(value) SetEnabled(value); end);

    local minimap = ui.Checkbox(cat, L["Display Minimap Icon"],
        modules.MinimapIcon.enabled, modules.MinimapIcon, "enabled", nil,
        function(value) EnableModule("MinimapIcon", value); end);
    local minimapFree = ui.Checkbox(cat, L["Unlock from Minimap"],
        db.minimap.free, db.minimap, "free", nil,
        function() modules.MinimapIcon:OnEnable(); end);
    ui.DependsOn(minimapFree, minimap);
    local minimapRight = ui.Checkbox(cat, L["<Right-Click> to show unread messages."],
        db.minimap.rightClickNew, db.minimap, "rightClickNew");
    ui.DependsOn(minimapRight, minimap);

    if (_G.AddonCompartmentFrame) then
        ui.Checkbox(cat, L["Display Addon Compartment Icon"],
            modules.AddonCompartment.enabled, modules.AddonCompartment, "enabled", nil,
            function(value) EnableModule("AddonCompartment", value); end);
    end

    ui.Checkbox(cat, L["Press <Tab> to advance to next tell target."],
        db.tabAdvance, db, "tabAdvance");

    local click = ui.Checkbox(cat, L["Enable WorldFrame Click Detection."],
        modules.ClickControl.enabled, modules.ClickControl, "enabled", nil,
        function(value) EnableModule("ClickControl", value); end);
    local sensitivity = {};
    for i = 1, 10 do
        table.insert(sensitivity, { text = tostring(i), value = i * .05 });
    end
    local sens = ui.Dropdown(cat, L["Sensitivity"],
        db.ClickControl.clickSensitivity, sensitivity,
        db.ClickControl, "clickSensitivity");
    ui.DependsOn(sens, click);

    ui.Checkbox(cat, L["Force sounds when game sound is disabled."],
        db.sounds.force_game_sound, db.sounds, "force_game_sound");

    -- Window Settings --------------------------------------------------
    ui.Header(layout, L["Window Settings"]);

    local function props() UpdateAllWindowProps(); end
    local function px(value) return tostring(value); end
    local function pct(value) return value.."%"; end

    ui.Slider(cat, L["Default Width"], db.winSize.width, 150, 800, 1,
        db.winSize, "width", nil, props, px);
    ui.Slider(cat, L["Default Height"], db.winSize.height, 80, 600, 1,
        db.winSize, "height", nil, props, px);
    ui.Slider(cat, L["Window Scale"], db.winSize.scale, 10, 400, 1,
        db.winSize, "scale", nil, props, pct);

    local stratas = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"};
    local strataNames = {L["Background"], L["Low"], L["Medium"], L["High"], L["Dialog"], L["Tooltip"]};
    local strataList = {};
    for i = 1, #stratas do
        table.insert(strataList, { text = strataNames[i], value = stratas[i] });
    end
    ui.Dropdown(cat, L["Window Strata:"], db.winSize.strata, strataList,
        db.winSize, "strata", nil, props);

    ui.Checkbox(cat, L["Clamp window to screen."], db.clampToScreen,
        db, "clampToScreen", nil, props);

    ui.Button(layout, L["Set Window Spawn Location"], L["Set Window Spawn Location"],
        function() ShowDemoWindow(); end);

    local cascadeNames = {L["Up"], L["Down"], L["Left"], L["Right"],
        L["Up"].." & "..L["Left"], L["Up"].." & "..L["Right"],
        L["Down"].." & "..L["Left"], L["Down"].." & "..L["Right"]};
    local cascadeList = {};
    for i = 1, #cascadeNames do
        table.insert(cascadeList, { text = cascadeNames[i], value = i });
    end
    local cascade = ui.Checkbox(cat, L["Cascade overlapping windows."],
        db.winCascade.enabled, db.winCascade, "enabled");
    local cascadeDir = ui.Dropdown(cat, L["Animation Direction:"],
        db.winCascade.direction, cascadeList, db.winCascade, "direction");
    ui.DependsOn(cascadeDir, cascade);

    ui.Checkbox(cat, L["Ignore arrow keys in message box."],
        db.ignoreArrowKeys, db, "ignoreArrowKeys", nil, props);
    ui.Checkbox(cat, L["Allow <ESC> to hide windows."],
        db.escapeToHide, db, "escapeToHide",
        L["Windows will also be hidden when frames such as the world map are shown."], props);

    -- Display Settings ---------------------------------------------------
    ui.Header(layout, L["Display Settings"]);

    -- Rebuilt on every open, so skins registered after login (and
    -- modern-only skins, which the classic dropdown hides) appear.
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
    ui.Dropdown(cat, L["Window Skin:"], db.skin.selected, skinItems,
        db.skin, "selected", nil, function(value) LoadSkin(value); end);

    ui.Slider(cat, L["Window Alpha"], db.windowAlpha, 1, 100, 1,
        db, "windowAlpha", nil, props, pct);
    ui.Checkbox(cat, L["Enable window fading effects."], db.winFade, db, "winFade");
    ui.Checkbox(cat, L["Enable window animation effects."], db.winAnimation, db, "winAnimation");
    ui.Checkbox(cat, L["Display item links when hovering over them."],
        db.hoverLinks, db, "hoverLinks");

    addColorPanel(ui, layout, {
        { label = L["Color: System Messages"], key = "sysMsg" },
        { label = L["Color: Error Messages"], key = "errorMsg" },
        { label = L["Color: URL - Web Addresses"], key = "webAddress" },
        { label = L["Color: History Messages Sent"], key = "historyOut" },
        { label = L["Color: History Messages Received"], key = "historyIn" },
    });

    -- Fonts ------------------------------------------------------------
    ui.Header(layout, L["Fonts"]);

    ui.Custom(layout, "WIM3SettingsFontBrowserTemplate", { onInit = fontBrowserRowInit });

    local function reskin() LoadSkin(db.skin.selected); end
    local outlineList = {
        { text = L["None"],  value = "" },
        { text = L["Thin"],  value = "OUTLINE" },
        { text = L["Thick"], value = "THICKOUTLINE" },
    };
    ui.Dropdown(cat, L["Font Outline"], db.skin.font_outline, outlineList,
        db.skin, "font_outline", nil, reskin);
    ui.Checkbox(cat, L["Use font suggested by skin."], db.skin.suggest,
        db.skin, "suggest", nil, reskin);
    ui.Slider(cat, L["Chat Font Size"], tonumber(db.fontSize) or 12, 8, 50, 1,
        db, "fontSize", nil, props, px);

    -- Message Formatting -------------------------------------------------
    ui.Header(layout, L["Message Formatting"]);

    local formats = GetMessageFormattingList();
    db.messageFormat = isInTable(formats, db.messageFormat) and db.messageFormat or formats[1];
    local formatItems = {};
    for i = 1, #formats do
        table.insert(formatItems, { text = formats[i], value = formats[i] });
    end
    local formatRow = ui.Dropdown(cat, L["Message Formatting"],
        db.messageFormat, formatItems, db, "messageFormat", nil, refreshPreview);

    ui.Custom(layout, "WIM3SettingsPreviewTemplate", { onInit = previewRowInit });

    local ts = ui.Checkbox(cat, L["Display Time Stamps"],
        modules.TimeStamps.enabled, modules.TimeStamps, "enabled", nil,
        function(value) EnableModule("TimeStamps", value); refreshPreview(); end);
    local tsItems = {};
    local tsFormats = GetTimeStampFormats();
    for i = 1, #tsFormats do
        table.insert(tsItems, { text = _G.date(tsFormats[i]), value = tsFormats[i] });
    end
    local tsFormat = ui.Dropdown(cat, L["Timestamp Format"],
        db.timeStampFormat, tsItems, db, "timeStampFormat", nil, refreshPreview);
    ui.DependsOn(tsFormat, ts);

    ui.Checkbox(cat, L["Display Emoticons"],
        modules.Emoticons.enabled, modules.Emoticons, "enabled", nil,
        function(value) EnableModule("Emoticons", value); refreshPreview(); end);
    ui.Checkbox(cat, L["Display URLs as Links"],
        modules.URLHandler.enabled, modules.URLHandler, "enabled", nil,
        function(value) EnableModule("URLHandler", value); refreshPreview(); end);
    ui.Checkbox(cat, L["Indent long messages."],
        db.wordwrap_indent, db, "wordwrap_indent", nil,
        function() UpdateAllWindowProps(); refreshPreview(); end);

    -- WIM-format-specific rows: only meaningful while the Default format
    -- is selected (matches the classic page's behavior).
    local function defaultFormat()
        return db.messageFormat == L["Default"];
    end
    local colorize = ui.Checkbox(cat, L["Colorize names."],
        db.coloredNames, db, "coloredNames", nil,
        function() UpdateAllWindowProps(); refreshPreview(); end);
    ui.DependsOn(colorize, formatRow, defaultFormat);
    local bracket = ui.Checkbox(cat, L["Bracket names."],
        db.formatting.bracketing.enabled, db.formatting.bracketing, "enabled", nil,
        refreshPreview);
    ui.DependsOn(bracket, formatRow, defaultFormat);
    local bracketItems = {};
    for i = 1, #lists.bracketing do
        table.insert(bracketItems, {
            text = lists.bracketing[i][1].." "..lists.bracketing[i][2],
            value = i,
        });
    end
    local bracketType = ui.Dropdown(cat, L["Bracket Style"],
        db.formatting.bracketing.type, bracketItems,
        db.formatting.bracketing, "type", nil, refreshPreview);
    ui.DependsOn(bracketType, bracket, function()
        return defaultFormat() and bracket.setting:GetValue();
    end);

    -- Tab Management -----------------------------------------------------
    ui.Header(layout, L["Tab Management"]);

    local sorts = {L["Window Created"], L["Last Activity"], L["Alphabetical"]};
    local sortList = {};
    for i = 1, #sorts do
        table.insert(sortList, { text = sorts[i], value = i });
    end
    ui.Dropdown(cat, L["Sort tabs by:"], db.tabs.sortBy, sortList,
        db.tabs, "sortBy", nil, function() UpdateAllTabs(); end);

    local whispers = ui.Checkbox(cat, L["Automatically group whispers."],
        db.tabs.whispers.enabled, db.tabs.whispers, "enabled",
        L["Does not apply to windows already opened."]);
    local friends = ui.Checkbox(cat, L["Place friends in their own group."],
        db.tabs.whispers.friends, db.tabs.whispers, "friends",
        L["Does not apply to windows already opened."]);
    ui.DependsOn(friends, whispers);
    local guild = ui.Checkbox(cat, L["Place guild members in their own group."],
        db.tabs.whispers.guild, db.tabs.whispers, "guild",
        L["Does not apply to windows already opened."]);
    ui.DependsOn(guild, whispers);

    local chat = ui.Checkbox(cat, L["Automatically group chat windows."],
        db.tabs.chat.enabled, db.tabs.chat, "enabled",
        L["Does not apply to windows already opened."]);
    local aswhisper = ui.Checkbox(cat, L["Group with whisper windows."],
        db.tabs.chat.aswhisper, db.tabs.chat, "aswhisper",
        L["Does not apply to windows already opened."]);
    ui.DependsOn(aswhisper, chat);

    -- Expose ---------------------------------------------------------------
    ui.Header(layout, L["Expose"]);

    local combat = ui.Checkbox(cat, L["Auto hide/restore windows during combat."],
        db.expose.combat, db.expose, "combat");
    local protect = ui.Checkbox(cat, L["Delay if I am typing a message."],
        db.expose.protect, db.expose, "protect");
    ui.DependsOn(protect, combat);
    local groupOnly = ui.Checkbox(cat, L["Only while in an instance."],
        db.expose.groupOnly, db.expose, "groupOnly");
    ui.DependsOn(groupOnly, combat);

    local direction = {L["Up"], L["Down"], L["Left"], L["Right"]};
    local dirList = {};
    for i = 1, #direction do
        table.insert(dirList, { text = direction[i], value = i });
    end
    ui.Dropdown(cat, L["Animation Direction:"], db.expose.direction, dirList,
        db.expose, "direction");

    local border = ui.Checkbox(cat, L["Show Border"], db.expose.border,
        db.expose, "border");
    local borderSize = ui.Slider(cat, L["Border Size"], db.expose.borderSize,
        1, 200, 1, db.expose, "borderSize");
    ui.DependsOn(borderSize, border);
end);

-- ----------------------------------------------------------------- Whispers
RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, L["Whispers"]);

    ui.Header(layout, L["Display Settings"]);
    ui.Checkbox(cat, L["Display user class icons and details."],
        db.whoLookups, db, "whoLookups", L["Requires who lookups."]);
    ui.Checkbox(cat, L["Display Shortcut Bar"],
        modules.ShortcutBar.enabled, modules.ShortcutBar, "enabled", nil,
        function(value) EnableModule("ShortcutBar", value); end);

    addColorPanel(ui, layout, {
        { label = L["Color: Messages Sent"], key = "wispOut" },
        { label = L["Color: Messages Received"], key = "wispIn" },
        { label = L["Color: BNet Messages Sent"], key = "BNwispOut" },
        { label = L["Color: BNet Messages Received"], key = "BNwispIn" },
    });

    addPopRulesSection(cat, layout, ui, "whisper");
    addHistorySection(cat, layout, ui, false);

    ui.Header(layout, L["Filtering"]);
    ui.Checkbox(cat, L["Enable Filtering"], modules.Filters.enabled,
        modules.Filters, "enabled", nil,
        function(value) EnableModule("Filters", value); end);
    ui.Custom(layout, "WIM3SettingsFilterListTemplate",
        { isChat = false, onInit = filterRowInit });

    ui.Header(layout, L["Sounds"]);
    addSoundPair(cat, ui, L["Play sound when a whisper is received."], db.sounds.whispers, "msgin", "msgin_sml");
    addSoundPair(cat, ui, L["Play special sound for battle.net friends."], db.sounds.whispers, "bnet", "bnet_sml");
    addSoundPair(cat, ui, L["Play special sound for friends."], db.sounds.whispers, "friend", "friend_sml");
    addSoundPair(cat, ui, L["Play special sound for guild members."], db.sounds.whispers, "guild", "guild_sml");
    addSoundPair(cat, ui, L["Play sound when a whisper is sent."], db.sounds.whispers, "msgout", "msgout_sml");
end);

-- --------------------------------------------------------------------- Chat
RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, _G.CHAT);

    local chatTypes = {
        { name = _G.GUILD,            module = "GuildChat",        chatType = "guild" },
        { name = _G.GUILD_RANK1_DESC, module = "OfficerChat",      chatType = "officer" },
        { name = _G.PARTY,            module = "PartyChat",        chatType = "party" },
        { name = _G.RAID,             module = "RaidChat",         chatType = "raid" },
        { name = _G.INSTANCE_CHAT,    module = "BattlegroundChat", chatType = "battleground" },
        { name = _G.SAY,              module = "SayChat",          chatType = "say" },
    };
    for i = 1, #chatTypes do
        local entry = chatTypes[i];
        local chatDB = db.chat[entry.chatType];
        ui.Header(layout, entry.name);
        local enable = ui.Checkbox(cat, L["Enable"],
            modules[entry.module].enabled, modules[entry.module], "enabled", nil,
            function(value) EnableModule(entry.module, value); end);
        local alerts = ui.Checkbox(cat, L["Show Minimap Alerts"],
            chatDB.showAlerts, chatDB, "showAlerts");
        ui.DependsOn(alerts, enable);
        if (entry.chatType == "say") then
            local emotes = ui.Checkbox(cat, L["Include emotes."],
                chatDB.showEmotes, chatDB, "showEmotes");
            ui.DependsOn(emotes, enable);
        end
        local neverPop = ui.Checkbox(cat, L["Never pop-up on my screen."],
            chatDB.neverPop, chatDB, "neverPop");
        ui.DependsOn(neverPop, enable);
        local neverSuppress = ui.Checkbox(cat, L["Never suppress messages."],
            chatDB.neverSuppress, chatDB, "neverSuppress");
        ui.DependsOn(neverSuppress, enable);
    end

    -- Channel monitoring (world / custom / community). The enumerators
    -- are exported by ChatEngine's options scope; empty until it loads.
    local channelSections = {
        { name = L["World Chat"],  channelType = "world",
          list = function() return (GetOptionsChannelList and GetOptionsChannelList(true)) or {}; end },
        { name = L["Custom Chat"], channelType = "custom",
          list = function() return (GetOptionsChannelList and GetOptionsChannelList(false)) or {}; end },
    };
    if (_G.C_Club) then
        table.insert(channelSections, {
            name = L["Community Chat"], channelType = "community",
            list = function() return (GetOptionsCommunityList and GetOptionsCommunityList()) or {}; end,
        });
    end
    for i = 1, #channelSections do
        local section = channelSections[i];
        ui.Header(layout, section.name);
        ui.Checkbox(cat, L["Enable"], db.chat[section.channelType].enabled,
            db.chat[section.channelType], "enabled", nil,
            function() modules.ChannelChat:SettingsChanged(); end);
        ui.Custom(layout, "WIM3SettingsChannelListTemplate", {
            channelType = section.channelType,
            list = section.list,
            onInit = channelRowInit,
        });
    end

    addPopRulesSection(cat, layout, ui, "chat");
    addHistorySection(cat, layout, ui, true);

    ui.Header(layout, L["Filtering"]);
    ui.Checkbox(cat, L["Enable Filtering"], modules.ChatFilters.enabled,
        modules.ChatFilters, "enabled", nil,
        function(value) EnableModule("ChatFilters", value); end);
    ui.Custom(layout, "WIM3SettingsFilterListTemplate",
        { isChat = true, onInit = filterRowInit });

    ui.Header(layout, L["Sounds"]);
    addSoundPair(cat, ui, L["Play sound when a message is received."], db.sounds.chat, "msgin", "msgin_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.GUILD), db.sounds.chat, "guild", "guild_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.GUILD_RANK1_DESC), db.sounds.chat, "officer", "officer_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.PARTY), db.sounds.chat, "party", "party_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.RAID), db.sounds.chat, "raid", "raid_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.RAID_LEADER), db.sounds.chat, "raidleader", "raidleader_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.INSTANCE_CHAT), db.sounds.chat, "battleground", "battleground_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.INSTANCE_CHAT_LEADER), db.sounds.chat, "battlegroundleader", "battlegroundleader_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(_G.SAY), db.sounds.chat, "say", "say_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(L["World Chat"]), db.sounds.chat, "world", "world_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(L["Custom Chat"]), db.sounds.chat, "custom", "custom_sml");
    addSoundPair(cat, ui, L["Play special sound for %s."]:format(L["Community Chat"]), db.sounds.chat, "community", "community_sml");
    addSoundPair(cat, ui, L["Play sound when a message is sent."], db.sounds.chat, "msgout", "msgout_sml");
end);

-- -------------------------------------------------------- Modern Skin
-- Settings that only affect modern-only skins. Every control can be
-- changed only while one is selected (SkinLocksOptionsStyle).
local modernThemeNoteHolder;
local function modernThemeNoteInit(row)
    if (not modernThemeNoteHolder) then
        local holder = CreateFrame("Frame");
        holder:Hide();
        local text = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
        text:SetPoint("TOPLEFT", 37, -8);
        text:SetPoint("TOPRIGHT", -37, -8);
        text:SetJustifyH("LEFT");
        text:SetSpacing(3);
        text:SetTextColor(.8, .8, .8);
        text:SetText(L["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They shape the History Viewer and the chat windows, and are available only while a modern-only skin is selected under General > Display Settings; with a classic skin active they are greyed out."]);
        modernThemeNoteHolder = holder;
    end
    options.AttachRowHolder(row, modernThemeNoteHolder);
end

RegisterModernPage(function(category, ui)
    local cat, layout = ui.Subcategory(category, L["Modern Skin"]);

    local modernActive = function() return SkinLocksOptionsStyle(); end;

    ui.Custom(layout, "WIM3SettingsNoteTemplate", { onInit = modernThemeNoteInit });

    ui.Header(layout, L["History Viewer"]);

    local function backgroundItems()
        local items = {};
        local list = GetChromeBackgrounds and GetChromeBackgrounds() or {};
        for i = 1, #list do
            table.insert(items, { value = list[i].key, text = L[list[i].label] });
        end
        return items;
    end
    -- Reapplying the skin repaints the History Viewer chrome live.
    local function reapply()
        LoadSkin(db.skin.selected);
    end
    local backgroundControls = {
        ui.Dropdown(cat, L["Frame background"], db.modernTheme.frame,
            backgroundItems, db.modernTheme, "frame", nil, reapply),
        ui.Dropdown(cat, L["Selection panels background"], db.modernTheme.panels,
            backgroundItems, db.modernTheme, "panels", nil, reapply),
        ui.Dropdown(cat, L["Chat history background"], db.modernTheme.content,
            backgroundItems, db.modernTheme, "content", nil, reapply),
        ui.Checkbox(cat, L["Panels see through to the game world"],
            db.modernTheme.cutout, db.modernTheme, "cutout",
            L["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer instead of the frame fill."],
            reapply),
    };

    -- Message windows work like the History Viewer: separate frame and
    -- message-area backgrounds, plus their own cut-out.
    ui.Header(layout, L["Chat Windows"]);
    table.insert(backgroundControls,
        ui.Dropdown(cat, L["Window frame background"], db.modernTheme.chatFrame,
            backgroundItems, db.modernTheme, "chatFrame", nil, reapply));
    table.insert(backgroundControls,
        ui.Dropdown(cat, L["Message area background"], db.modernTheme.chatPanel,
            backgroundItems, db.modernTheme, "chatPanel", nil, reapply));
    table.insert(backgroundControls,
        ui.Checkbox(cat, L["Window sees through to the game world"],
            db.modernTheme.chatCutout, db.modernTheme, "chatCutout",
            L["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."],
            reapply));
    local wrapControl = ui.Checkbox(cat, L["Wrap the message being typed"],
        db.modernTheme.inputWrap, db.modernTheme, "inputWrap",
        L["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."],
        reapply);
    table.insert(backgroundControls, wrapControl);
    local wrapLimit = ui.Checkbox(cat, L["Limit wrapped lines"],
        db.modernTheme.inputWrapLimit, db.modernTheme, "inputWrapLimit",
        L["Caps how far the input field grows; past the limit the message scrolls inside it."],
        reapply);
    table.insert(backgroundControls, wrapLimit);
    ui.DependsOn(wrapLimit, wrapControl);
    local wrapLines = ui.Slider(cat, L["Visible input lines"],
        db.modernTheme.inputWrapLines, 1, 20, 1, db.modernTheme, "inputWrapLines",
        L["The most lines the input field grows to before the message scrolls inside it."],
        reapply);
    table.insert(backgroundControls, wrapLines);
    ui.DependsOn(wrapLines, wrapLimit);

    ui.Header(layout, L["Filter Editor"]);
    local reapplyFilter = function()
        if (RestyleFilterFrame) then RestyleFilterFrame(); end
    end;
    table.insert(backgroundControls,
        ui.Dropdown(cat, L["Frame background"], db.modernTheme.filterFrame,
            backgroundItems, db.modernTheme, "filterFrame", nil, reapplyFilter));
    table.insert(backgroundControls,
        ui.Dropdown(cat, L["Filter area background"], db.modernTheme.filterPanel,
            backgroundItems, db.modernTheme, "filterPanel", nil, reapplyFilter));
    table.insert(backgroundControls,
        ui.Checkbox(cat, L["Filter area sees through to the game world"],
            db.modernTheme.filterCutout, db.modernTheme, "filterCutout",
            L["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."],
            reapplyFilter));

    ui.Header(layout, L["Chat Colors"]);
    local nativeColors = db.displayColors.useNative;
    local refreshInput = function()
        if (UpdateAllInputColors) then UpdateAllInputColors(); end
    end;
    local nativeMaster = ui.Checkbox(cat, L["Match the game's chat colors."],
        nativeColors.enabled, nativeColors, "enabled",
        L["The message being typed takes the color of the chat type it will send as, like the game's own chat box."],
        refreshInput);
    table.insert(backgroundControls, nativeMaster);
    local nativeRows = {
        { label = L["Whispers"], key = "whisper" },
        { label = L["Battle.net Whispers"], key = "bnet" },
        { label = _G.SAY, key = "say" },
        { label = _G.GUILD, key = "guild" },
        { label = _G.GUILD_RANK1_DESC, key = "officer" },
        { label = _G.PARTY, key = "party" },
        { label = _G.RAID, key = "raid" },
        { label = _G.INSTANCE_CHAT, key = "instance" },
        { label = _G.CHANNELS, key = "channel" },
    };
    for i = 1, #nativeRows do
        local row = ui.Checkbox(cat, nativeRows[i].label,
            nativeColors[nativeRows[i].key], nativeColors, nativeRows[i].key,
            nil, refreshInput);
        table.insert(backgroundControls, row);
        ui.DependsOn(row, nativeMaster);
    end

    ui.Header(layout, L["Roleplay Profiles"]);
    local rpEnable = ui.Checkbox(cat, L["Enable roleplay profile integration"],
        db.modernTheme.rpEnabled, db.modernTheme, "rpEnabled",
        L["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer."],
        function()
            if(RefreshRPProfiles) then
                RefreshRPProfiles();
            end
        end);
    table.insert(backgroundControls, rpEnable);
    -- One entry per profile field the whisper windows can display.
    -- Nothing selected means the default display.
    local rpFieldsControl =
        ui.MultiDropdown(cat, L["Displayed profile fields"], {
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
        end);
    table.insert(backgroundControls, rpFieldsControl);
    ui.DependsOn(rpFieldsControl, rpEnable);

    for i = 1, #backgroundControls do
        local control = backgroundControls[i];
        if (control and control.init and control.init.AddModifyPredicate) then
            control.init:AddModifyPredicate(modernActive);
        end
    end
end);
