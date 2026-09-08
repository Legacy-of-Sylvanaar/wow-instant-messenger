--imports
local WIM = WIM;
local _G = _G;
local pairs = pairs;
local type = type;
local string = string;
local table = table;
local pcall = pcall;
local rawget = rawget;
local CreateFrame = CreateFrame;

--set namespace
setfenv(1, WIM);

-- Roleplay profile integration. Whisper windows show the partner's
-- roleplay identity: name, title, race, class, name color, and
-- portrait. Each field is enabled separately in
-- db.modernTheme.rpFields; when no field is selected, the window keeps
-- the game's default display. Total RP 3 is read through its public
-- Player API. Other Mary Sue Protocol addons are read through the
-- shared msp library. A field without data, or a character without a
-- profile, falls back to the default value.
local RPProfiles = CreateModule("RPProfiles", true);

local EMPTY_FIELDS = {};
local function selectedFields()
    local theme = db and db.modernTheme;
    return theme and theme.rpFields or EMPTY_FIELDS;
end

local function anyFieldSelected()
    for _, selected in pairs(selectedFields()) do
        if(selected) then
            return true;
        end
    end
    return false;
end

local function integrationEnabled()
    local theme = db and db.modernTheme;
    if(not (theme and theme.rpEnabled)) then return false; end
    -- The integration is part of the modern skin. Classic skins keep
    -- WIM's default identity, details, and class icons.
    local skin = GetSelectedSkin and GetSelectedSkin();
    return (skin and skin.modernOnly) and true or false;
end

-- Returns the installed profile viewer, if any: Total RP 3's register
-- page, or the XRP or MRP viewer.
local function profileViewer()
    if(_G.TRP3_API and _G.TRP3_API.register
            and _G.TRP3_API.register.openPageByUnitID) then
        return "trp3";
    end
    if(_G.XRPViewer and _G.XRPViewer.View) then
        return "xrp";
    end
    if(_G.mrp and _G.mrp.Show) then
        return "mrp";
    end
end

-- Roleplay addons key characters as "Name-NormalizedRealm".
local function characterID(user)
    if(type(user) ~= "string" or user == "") then
        return nil;
    end
    if(string.find(user, "-", 1, true)) then
        return user;
    end
    local realm = _G.GetNormalizedRealmName and _G.GetNormalizedRealmName();
    if(not realm) then
        return nil;
    end
    return user.."-"..realm;
end

local function collectTRP3(id)
    local Player = _G.AddOn_TotalRP3 and _G.AddOn_TotalRP3.Player;
    if(not (Player and Player.CreateFromCharacterID)) then
        return nil;
    end
    local loaded, info = pcall(function()
        local player = Player.CreateFromCharacterID(id);
        if(not (player and player:GetProfileID())) then
            return nil;
        end
        local info = {
            name = player:GetRoleplayingName(),
            firstName = player:GetFirstName(),
            lastName = player:GetLastName(),
            title = player:GetTitle(),
            fullTitle = player:GetFullTitle(),
            race = player:GetCustomRace(),
            class = player:GetCustomClass(),
            icon = player:GetCustomIcon(),
        };
        local color = player.GetCustomColorForDisplay
            and player:GetCustomColorForDisplay();
        if(color and color.GetRGB) then
            info.colorR, info.colorG, info.colorB = color:GetRGB();
        end
        return info;
    end);
    if(loaded) then
        return info;
    end
end

local function collectMSP(id)
    local msp = _G.msp;
    if(not (msp and msp.char)) then
        return nil;
    end
    -- Use rawget: plain indexing creates a new entry in the library's
    -- char table, and a read must not create phantom characters.
    local char = rawget(msp.char, id);
    local fields = char and rawget(char, "field");
    if(not fields) then
        return nil;
    end
    local function value(key)
        local v = fields[key];
        if(type(v) == "string" and v ~= "") then
            return v;
        end
    end
    if(not (value("NA") or value("IC"))) then
        return nil;
    end
    return {
        name = value("NA"),
        title = value("NT"),
        race = value("RA"),
        class = value("RC"),
        icon = value("IC"),
    };
end

-- Returns the character's roleplay identity. Returns nil when no
-- field is selected, no roleplay addon is running, or the character
-- has no profile; callers then show the game defaults.
function GetRPProfile(user)
    if(not (RPProfiles.enabled and integrationEnabled() and anyFieldSelected())) then
        return nil;
    end
    local id = characterID(user);
    if(not id) then
        return nil;
    end
    return collectTRP3(id) or collectMSP(id);
end

-- The profile tooltip sits on a hover frame over the class icon. The
-- frame ignores clicks, so the full identity (including the full
-- title, which is too long for the window) stays readable without
-- blocking window drags.
local function ensureTooltip(win)
    if(win.wimRPTip) then
        return win.wimRPTip;
    end
    local icon = win.widgets and win.widgets.class_icon;
    if(not icon) then
        return nil;
    end
    local tip = CreateFrame("Frame", nil, win);
    tip:SetAllPoints(icon);
    tip:SetFrameLevel(win:GetFrameLevel() + 5);
    tip.parentWindow = win;
    tip:EnableMouse(true);
    tip:SetMouseClickEnabled(false);
    tip:SetScript("OnEnter", function(self)
        local rp = win.wimRPProfile;
        if(not rp) then return; end
        local fields = selectedFields();
        local tooltip = _G.GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(rp.name or GetReadableName(win.theUser), 1, 0.82, 0);
        if(fields.title and rp.title and rp.title ~= "") then
            tooltip:AddLine(rp.title, 1, 1, 1);
        end
        if(fields.fullTitle and rp.fullTitle and rp.fullTitle ~= "") then
            tooltip:AddLine(rp.fullTitle, 0.8, 0.8, 0.8, true);
        end
        local race = (fields.race and rp.race) or win.race;
        local class = (fields.class and rp.class) or win.class;
        local line = {};
        if(race and race ~= "") then table.insert(line, race); end
        if(class and class ~= "") then table.insert(line, class); end
        if(#line > 0) then
            tooltip:AddLine(table.concat(line, " "), 1, 1, 1);
        end
        tooltip:AddLine(GetReadableName(win.theUser), 0.5, 0.5, 0.5);
        tooltip:Show();
    end);
    tip:SetScript("OnLeave", function()
        _G.GameTooltip:Hide();
    end);
    win.wimRPTip = tip;
    return tip;
end

local function applyToWindow(win)
    if(win.type ~= "whisper" or not win.widgets) then
        return;
    end
    local rp;
    if(not (win.isBN or win.isGM)) then
        rp = GetRPProfile(win.theUser);
    end
    win.wimRPProfile = rp;
    local fields = selectedFields();
    -- The portrait. Profile icons are full-frame images under
    -- Interface\Icons, unlike the class emblem cells.
    win.wimRPIcon = rp and fields.portrait and rp.icon and rp.icon ~= ""
        and "Interface\\ICONS\\"..rp.icon or nil;

    -- The title text: the selected name parts, with the short title in
    -- front (in front of the character name when no name part is
    -- selected). The msp library stores the roleplay name as one
    -- string, so selecting either name part uses the whole name when
    -- no split is available.
    local from = win.widgets.from;
    if(from) then
        local name;
        if(rp and (fields.firstName or fields.lastName)) then
            local parts = {};
            if(fields.firstName and rp.firstName and rp.firstName ~= "") then
                table.insert(parts, rp.firstName);
            end
            if(fields.lastName and rp.lastName and rp.lastName ~= "") then
                table.insert(parts, rp.lastName);
            end
            if(#parts > 0) then
                name = table.concat(parts, " ");
            elseif(rp.name and rp.name ~= "") then
                name = rp.name;
            end
        end
        local title = rp and fields.title and rp.title and rp.title ~= ""
            and rp.title or nil;
        local text;
        if(name or title) then
            -- Short titles read as prefixes ("Warlord Grommash").
            text = (title and (title.." ") or "")
                ..(name or GetReadableName(win.theUser));
        end
        if(text) then
            from:SetText(text);
            win.wimRPNameShown = true;
        elseif(win.wimRPNameShown) then
            from:SetText(GetReadableName(win.theUser));
            win.wimRPNameShown = nil;
        end
    end

    win:UpdateIcon();
    win:UpdateCharDetails();

    local tip = ensureTooltip(win);
    if(tip) then
        tip:SetShown(rp and true or false);
    end
    if(LayoutThemedHeader) then
        LayoutThemedHeader(win);
    end
end

local function hookWindow(win)
    if(win.wimRPHooked) then
        return;
    end
    win.wimRPHooked = true;
    local origUpdateIcon = win.UpdateIcon;
    win.UpdateIcon = function(self, ...)
        origUpdateIcon(self, ...);
        local icon = self.widgets and self.widgets.class_icon;
        if(icon and self.wimRPIcon) then
            icon:SetTexture(self.wimRPIcon);
            -- Crop the border the icon files bake into their edges.
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
            icon:SetGradient("VERTICAL",
                { r = 1, g = 1, b = 1, a = 1 },
                { r = 1, g = 1, b = 1, a = 1 }
            );
        end
        -- Apply the profile's custom name color after the default pass,
        -- which repaints the class color here.
        local rp = self.wimRPProfile;
        local from = self.widgets and self.widgets.from;
        if(from and rp and rp.colorR and selectedFields().color) then
            from:SetTextColor(rp.colorR, rp.colorG, rp.colorB);
        end
    end;
    local origUpdateCharDetails = win.UpdateCharDetails;
    win.UpdateCharDetails = function(self, ...)
        local rp = self.wimRPProfile;
        local fields = selectedFields();
        -- Only a selected detail field with data replaces the default
        -- line. Unreplaced race and class keep their default values
        -- next to the replaced ones. The short title shows in the
        -- title text, not here.
        local replacing = rp and (
            (fields.fullTitle and rp.fullTitle and rp.fullTitle ~= "")
            or (fields.race and rp.race and rp.race ~= "")
            or (fields.class and rp.class and rp.class ~= ""));
        if(not replacing) then
            origUpdateCharDetails(self, ...);
            return;
        end
        local lines = {};
        -- The full title is long-form text. It always gets its own line
        -- above the race/class line, in the orange that roleplay
        -- tooltips use for titles.
        if(fields.fullTitle and rp.fullTitle and rp.fullTitle ~= "") then
            table.insert(lines, "|cffff8000"..rp.fullTitle.."|r");
        end
        local race = (fields.race and rp.race and rp.race ~= "" and rp.race) or self.race;
        local class = (fields.class and rp.class and rp.class ~= "" and rp.class) or self.class;
        if(class and class ~= "" and fields.color and rp.colorR) then
            class = "|cff"..RGBPercentToHex(rp.colorR, rp.colorG, rp.colorB)..class.."|r";
        end
        local line = {};
        if(race and race ~= "") then table.insert(line, race); end
        if(class and class ~= "") then table.insert(line, class); end
        if(#line > 0) then
            table.insert(lines, "|cffffffff"..table.concat(line, " ").."|r");
        end
        self.widgets.char_info:SetText(table.concat(lines, "\n"));
    end;
end

function RefreshRPProfiles()
    for _, win in pairs(windows.active.whisper) do
        hookWindow(win);
        applyToWindow(win);
        -- Re-evaluate the shortcut bar's buttons. The Open Profile
        -- shortcut follows the integration switch.
        local shortcuts = win.widgets and win.widgets.shortcuts;
        if(shortcuts and shortcuts.buttons) then
            for i=1, #shortcuts.buttons do
                if(shortcuts.buttons[i].SetDefaults) then
                    shortcuts.buttons[i]:SetDefaults();
                end
            end
        end
    end
end

-- Profile data arrives asynchronously, but registering WIM functions
-- in the roleplay addons' callback registries is not safe. A stored
-- function is tainted; calling it taints the rest of the owning
-- addon's dispatch, and the error surfaces later inside protected code
-- (nameplate health text, with these addons). Instead, a short ticker
-- owned by this addon repaints open windows. Every write is
-- idempotent, so an unchanged profile repaints to the same pixels.
local refreshTicker;

local function startRefreshTicker()
    if(refreshTicker or not (_G.C_Timer and _G.C_Timer.NewTicker)) then
        return;
    end
    refreshTicker = _G.C_Timer.NewTicker(3, function()
        if(RPProfiles.enabled and anyFieldSelected()) then
            RefreshRPProfiles();
        end
    end);
end

function RPProfiles:OnEnable()
    startRefreshTicker();
    RefreshRPProfiles();
end

function RPProfiles:OnDisable()
    if(refreshTicker) then
        refreshTicker:Cancel();
        refreshTicker = nil;
    end
    RefreshRPProfiles();
end

-- A skin switch changes the integration's gate (a modern skin must be
-- active), so every window applies or removes its profile identity
-- when the skin changes.
function RPProfiles:OnSkinLoaded()
    RefreshRPProfiles();
end

function RPProfiles:OnWindowCreated(win)
    if(win.type ~= "whisper") then
        return;
    end
    hookWindow(win);
    applyToWindow(win);
end

-- The Open Profile shortcut opens the whisper partner's roleplay
-- profile in the installed viewer. It appears only while the roleplay
-- integration is enabled and a viewer is available.
RegisterShortcut("rpprofile", L["Open RP Profile"], {
    type = "whisper",
    OnClick = function(self)
        local win = self.parentWindow;
        if(not win or win.isBN or win.isGM) then return; end
        local id = characterID(win.theUser);
        if(not id) then return; end
        local viewer = profileViewer();
        if(viewer == "trp3") then
            pcall(function()
                _G.TRP3_API.navigation.openMainFrame();
                _G.TRP3_API.register.openPageByUnitID(id);
            end);
        elseif(viewer == "xrp") then
            pcall(_G.XRPViewer.View, _G.XRPViewer, id);
        elseif(viewer == "mrp") then
            pcall(_G.mrp.Show, _G.mrp, id);
        end
    end,
    SetDefaults = function(self)
        local win = self.parentWindow;
        local usable = integrationEnabled() and profileViewer()
            and win and win.type == "whisper"
            and not (win.isBN or win.isGM);
        if(usable) then
            self:Enable();
        else
            self:Disable();
        end
    end,
});

function RPProfiles:OnWindowShow(win)
    if(win.type ~= "whisper") then
        return;
    end
    hookWindow(win);
    applyToWindow(win);
    -- Query addons that only answer on request; the reply repaints the
    -- window through the ticker. Total RP 3 exchanges data on its own.
    local msp = _G.msp;
    if(msp and msp.Request and not (_G.AddOn_TotalRP3 and _G.AddOn_TotalRP3.Player)) then
        local id = characterID(win.theUser);
        if(id and anyFieldSelected()) then
            pcall(msp.Request, msp, id, { "NA", "NT", "RA", "RC", "IC" });
        end
    end
end
