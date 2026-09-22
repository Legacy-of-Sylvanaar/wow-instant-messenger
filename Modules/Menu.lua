--import
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local table = table;
local type = type;
local string = string;
local unpack = unpack;
local pairs = pairs;

--set namespace
setfenv(1, WIM);

local Menu = CreateModule("Menu", true);

local groupCount = 0;
local buttonCount = 0;

local lists = {
    whisper = {},
    chat = {}
}
local maxButtons = {
    whisper = 30, -- live windows plus persistent-history entries
    chat = 10
};

db_defaults.menuSortActivity = true;

-- Persistent History (db.minimap.recent): entries built from saved whisper
-- history for people who have no window open right now. Each entry is
-- { theUser = display name, target = name to whisper, time = last message time }.
local recentWhispers = {};

local function safeName(user)
    -- mirror WhisperEngine: strip a same-realm suffix and lowercase.
    if(type(user) ~= "string") then
        return "";
    end
    local player, realm = string.match(user, "^(.-)%-(.-)$");
    if(player and realm and env and env.realm and string.lower(realm) == string.lower(env.realm)) then
        user = player;
    end
    return string.lower(user);
end

local function sortRecent(a, b)
    return a.time > b.time;
end

-- find the BattleNet account id for a saved conversation name.
-- BNet_GetBNetIDAccount only knows online friends, so fall back to scanning the
-- whole friend list when the name is a BattleTag (Name#1234).
local function resolveBNetID(name)
    if(type(name) ~= "string" or name == "") then
        return nil;
    end
    local bnID = _G.BNet_GetBNetIDAccount and _G.BNet_GetBNetIDAccount(name);
    if(bnID) then
        return bnID;
    end
    if(string.find(name, "#", 1, true) and _G.BNGetNumFriends and GetBNGetFriendInfo) then
        local total = _G.BNGetNumFriends() or 0;
        for i=1, total do
            local id, accountName, battleTag = GetBNGetFriendInfo(i);
            if(id and (battleTag == name or accountName == name)) then
                return id;
            end
        end
    end
    return nil;
end

----------------------------------------------
--            Name colouring                --
----------------------------------------------
-- Rows follow the "Colorize names." option: Battle.net friends in the Battle.net blue the
-- default chat uses for them, characters in their class colour when the class is known.
-- Battle.net rows also carry the Battle.net icon the friends list uses, since the blue on its
-- own is easily mistaken for a mage.
local WHITE = {r = 1, g = 1, b = 1};
local BN_NAME_COLOR = {r = 0.51, g = 0.77, b = 1};
local BN_ICON_SIZE = 16; -- a little larger than the 12px row font so the logo reads clearly

local function bnNameColor()
    local c = _G.FRIENDS_BN_NAME_COLOR;
    if(type(c) == "table" and c.r and c.g and c.b) then
        return c;
    end
    return BN_NAME_COLOR;
end

-- inline markup for the Battle.net app icon; the game resolves the path for the client version.
local function bnIconMarkup()
    local path;
    if(_G.BNet_GetClientTexture and _G.BNET_CLIENT_APP) then
        path = _G.BNet_GetClientTexture(_G.BNET_CLIENT_APP);
    end
    if(type(path) ~= "string" or path == "") then
        path = "Interface\\FriendsFrame\\Battlenet-Battleneticon";
    end
    return "|T"..path..":"..BN_ICON_SIZE..":"..BN_ICON_SIZE.."|t ";
end

-- english class token (WARRIOR, MAGE, ...) from a localized class name, using WIM's own table.
local function classTokenByLocalized(localizedClass)
    local info = type(localizedClass) == "string" and localizedClass ~= "" and constants.classes[localizedClass];
    if(type(info) == "table" and info.tag) then
        return (string.gsub(info.tag, "F$", ""));
    end
    return nil;
end

-- {r,g,b} for an english class token; honours class colour addons, falls back to WIM's table
-- which also covers Game Masters.
local function classColorByToken(token)
    if(type(token) ~= "string" or token == "") then
        return nil;
    end
    local colors = _G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS;
    local c = colors and colors[token];
    if(type(c) == "table" and c.r) then
        return c;
    end
    local localized = constants.classes.GetClassByTag(token);
    local info = localized and localized ~= "" and constants.classes[localized];
    if(type(info) == "table" and info.color) then
        local r, g, b = RGBHexToPercent(info.color);
        return {r = r, g = g, b = b};
    end
    return nil;
end

-- colour for a live window row; cheap enough to call from OnUpdate as the class can arrive
-- later from the /who lookup.
local function windowNameColor(win)
    if(not db or not db.coloredNames) then
        return WHITE;
    end
    if(win.isBN) then
        return bnNameColor();
    end
    return classColorByToken(classTokenByLocalized(win.class)) or WHITE;
end

-- class token for a persistent-history entry: saved with the conversation by History, or for
-- older history, looked up live from the guild roster and the friends list.
local function recentClassToken(entry)
    for i=1, #entry.sources do
        local info = entry.sources[i].info;
        if(type(info) == "table" and type(info.class) == "string" and info.class ~= "") then
            return info.class;
        end
    end
    local name = entry.target;
    local guild = WIM.lists and WIM.lists.guild;
    local index = guild and guild[name];
    if(index and _G.GetGuildRosterInfo) then
        local rosterName, _, _, _, localizedClass, _, _, _, _, _, token = _G.GetGuildRosterInfo(index);
        if(type(rosterName) == "string") then
            rosterName = _G.Ambiguate and _G.Ambiguate(rosterName, "none") or rosterName;
            if(safeName(rosterName) == safeName(name)) then
                return (type(token) == "string" and token ~= "" and token) or classTokenByLocalized(localizedClass);
            end
        end
    end
    if(_G.C_FriendList and _G.C_FriendList.GetFriendInfo) then
        local friend = _G.C_FriendList.GetFriendInfo(name);
        if(type(friend) == "table" and friend.className) then
            return classTokenByLocalized(friend.className);
        end
    end
    return nil;
end

local function recentNameColor(entry)
    if(not db or not db.coloredNames) then
        return nil;
    end
    if(entry.isBN) then
        return bnNameColor();
    end
    return classColorByToken(recentClassToken(entry));
end

-- call fn(convoTable, target) for every whisper conversation saved for one character.
-- target is the name to whisper: history from another realm is qualified as Name-Realm so the
-- whisper reaches the right person; BattleTags (Name#1234) are realm independent and left alone.
local function forEachWhisperConvo(realm, convos, fn)
    local sameRealm = (realm == env.realm);
    local realmSuffix = "-"..string.gsub(realm, "%s", "");
    for convo, tbl in pairs(convos) do
        local last = type(tbl) == "table" and tbl[#tbl];
        if(last and last.type == 1 and not (tbl.info and tbl.info.chat) and type(convo) == "string" and convo ~= "") then
            local target = convo;
            if(not sameRealm and not string.find(convo, "#", 1, true) and not string.find(convo, "-", 1, true)) then
                target = convo..realmSuffix;
            end
            fn(tbl, target, last);
        end
    end
end

-- call fn(convoTable, target, lastMessage) for every saved whisper conversation in the
-- configured scope: this character only, or every character on the account.
local function forEachScopedConvo(settings, fn)
    if(settings.accountWide) then
        for realm, characters in pairs(history) do
            if(type(characters) == "table") then
                for _, convos in pairs(characters) do
                    if(type(convos) == "table") then
                        forEachWhisperConvo(realm, convos, fn);
                    end
                end
            end
        end
    else
        local convos = history[env.realm] and history[env.realm][env.character];
        if(convos) then
            forEachWhisperConvo(env.realm, convos, fn);
        end
    end
end

-- collect one conversation into recentWhispers.
-- open: set of names that already have a window; seen: name -> entry for de-duplication.
-- Conversations closed from the menu carry info.menuHidden and are skipped; History clears
-- that flag the next time a whisper is exchanged with that person.
local function collectRecent(tbl, target, last, open, seen)
    if(tbl.info and tbl.info.menuHidden) then
        return;
    end
    local key = safeName(target);
    if(open[key]) then
        return;
    end
    local entry = seen[key];
    if(entry) then
        if(last.time and last.time > entry.time) then
            entry.time = last.time;
        end
    else
        entry = {theUser = target, target = target, time = last.time or 0, sources = {},
                 isBN = string.find(target, "#", 1, true) and true or false};
        seen[key] = entry;
        table.insert(recentWhispers, entry);
    end
    -- remember every history table behind this entry so closing it hides all of them.
    table.insert(entry.sources, tbl);
end

-- mark every saved conversation with this person as closed from the menu.
local function hideConvosFor(target)
    local settings = db and db.minimap and db.minimap.recent;
    if(not settings or not settings.enabled or not history or not env or not env.realm) then
        return;
    end
    local key = safeName(target);
    forEachScopedConvo(settings, function(tbl, convoTarget)
        if(safeName(convoTarget) == key) then
            tbl.info = tbl.info or {};
            tbl.info.menuHidden = true;
        end
    end);
end

-- closing a persistent-history entry: flag its history tables, nothing is deleted.
local function hideRecentEntry(entry)
    if(not entry or not entry.sources) then
        return;
    end
    for i=1, #entry.sources do
        local tbl = entry.sources[i];
        tbl.info = tbl.info or {};
        tbl.info.menuHidden = true;
    end
end

-- closing a live window from the menu: also keep it out of the persistent-history list so it
-- does not pop straight back in as a history entry. Battle.net history is saved under the
-- BattleTag (or toon name) rather than the account name shown on the window.
local function hideRecentForWindow(win)
    if(not win or win.type ~= "whisper") then
        return;
    end
    hideConvosFor(win.theUser);
    if(win.isBN and win.bn and win.bn.id) then
        local _, _, btag, _, toonName = GetBNGetFriendInfoByID(win.bn.id);
        if(btag) then hideConvosFor(btag); end
        if(toonName and toonName ~= "") then hideConvosFor(toonName); end
    end
end

-- rebuild recentWhispers from saved history, skipping anyone who already has a window.
local function buildRecentWhispers()
    for i=#recentWhispers, 1, -1 do
        recentWhispers[i] = nil;
    end
    local settings = db and db.minimap and db.minimap.recent;
    if(not settings or not settings.enabled or not history or not env or not env.realm) then
        return;
    end
    local open, seen = {}, {};
    -- people with an open window are already listed by the menu.
    for i=1, #lists.whisper do
        local win = lists.whisper[i];
        if(win.theUser) then
            open[safeName(win.theUser)] = true;
            if(win.isBN and win.bn and win.bn.id) then
                -- BattleNet history is saved under the BattleTag (or toon name), not the account name.
                local _, _, btag, _, toonName = GetBNGetFriendInfoByID(win.bn.id);
                if(btag) then open[safeName(btag)] = true; end
                if(toonName) then open[safeName(toonName)] = true; end
            end
        end
    end
    forEachScopedConvo(settings, function(tbl, target, last)
        collectRecent(tbl, target, last, open, seen);
    end);
    table.sort(recentWhispers, sortRecent);
    local count = _G.tonumber(settings.count) or 10;
    count = _G.math.max(0, _G.math.min(count, maxButtons.whisper - #lists.whisper));
    for i=#recentWhispers, count+1, -1 do
        recentWhispers[i] = nil;
    end
    -- colour the rows, and show the friend's account name for BattleTag entries when the friend is known.
    for i=1, #recentWhispers do
        local entry = recentWhispers[i];
        entry.color = recentNameColor(entry);
        if(string.find(entry.target, "#", 1, true)) then
            local bnID = resolveBNetID(entry.target);
            local accountName;
            if(bnID) then
                local _, name = GetBNGetFriendInfoByID(bnID);
                accountName = name;
            end
            if(accountName and accountName ~= "") then
                entry.theUser = accountName;
            end
        end
    end
end

-- open (or create) the whisper window for a persistent-history entry.
local function openRecentWindow(entry)
    if(not entry or not entry.target or not GetWhisperWindowByUser) then
        return nil;
    end
    local bnID = resolveBNetID(entry.target);
    if(bnID) then
        return GetWhisperWindowByUser(entry.target, true, bnID);
    end
    return GetWhisperWindowByUser(entry.target);
end

local function sortWindows(a, b)
    if(db and db.menuSortActivity) then
        return a.lastActivity > b.lastActivity;
    else
        return string.lower(a.theUser) < string.lower(b.theUser);
    end
end

function isMouseOver()
	-- can optionaly exclude an object
	local x,y = _G.GetCursorPosition();
	local menu = WIM.Menu;
        if(not menu) then
            return false;
        else
            local x1, y1 = menu:GetLeft()*menu:GetEffectiveScale(), menu:GetTop()*menu:GetEffectiveScale();
            local x2, y2 = x1 + menu:GetWidth()*menu:GetEffectiveScale(), y1 - menu:GetHeight()*menu:GetEffectiveScale();
            if(x >= x1 and x <= x2 and y <= y1 and y >= y2) then
                return true;
            end
            return false;
        end
end

local function createCloseButton(parent)
    local button = CreateFrame("Button", nil, parent);
    button:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\xNormal");
    button:SetPushedTexture("Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\xPressed");
    button:SetWidth(16);
    button:SetHeight(16);
    button:SetScript("OnClick", function(self)
            local row = self:GetParent();
            if(row.win) then
                hideRecentForWindow(row.win);
                row.win.widgets.close.forceShift = true;
                row.win.widgets.close:Click();
            elseif(row.recent) then
                -- persistent-history entry: hide it from the menu, the conversation itself is kept.
                hideRecentEntry(row.recent);
                WIM.Menu:Refresh();
            end
        end);

    return button;
end

local function createStatusIcon(parent)
    local icon = parent:CreateTexture(nil, "OVERLAY");
    icon:SetWidth(14); icon:SetHeight(14);
    icon:SetAlpha(.85);
    icon:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
    return icon;
end

local function createButton(parent)
    buttonCount = buttonCount + 1;
    local button = CreateFrame("Button", "WIM3MenuButton"..buttonCount, parent, "UIPanelButtonTemplate");
    local bgtex = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg"
    button:SetNormalTexture(bgtex); button:SetPushedTexture(bgtex); button:SetDisabledTexture(bgtex); button:SetHighlightTexture(bgtex);
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD");
    button:GetHighlightTexture():SetVertexColor(.196, .388, .8);
    button:SetHeight(20);
    button:GetHighlightTexture():SetAllPoints();
    button.text = _G[button:GetName().."Text"];
    button.text:ClearAllPoints();
    button.text:SetPoint("LEFT"); button.text:SetPoint("RIGHT");
	button.text._allowCustomFont = true; -- flag that this frame allows custom fonts.
    button:GetHighlightTexture():ClearAllPoints();
    button:GetHighlightTexture():SetAllPoints();

    button.status = createStatusIcon(button);
    button.status:SetPoint("LEFT", button, "RIGHT", 0, -1);
    button.close = createCloseButton(button);
    button.close:SetPoint("LEFT", button.status, "RIGHT", 2, 0);

	button.ApplySkin = function(self, skin)
		SetWidgetFont(self.text, skin.menu.button);
	end

    button:SetScript("OnClick", function(self, b)
            local win = self.win;
            if(not win and self.recent) then
                -- persistent-history entry: open a window for that person first.
                win = openRecentWindow(self.recent);
            end
            if(not win) then
                return;
            end
			local forceShow = true
			if db.pop_rules[win.type].obeyAutoFocusRules then
				forceShow = win:GetRuleSet().autofocus
			end
            win:Pop(true, forceShow);
            WIM.Menu:Hide();
        end);
    button:SetScript("OnUpdate", function(self, elapsed)
            if(self.recent) then
                -- no window open for this person yet; draw it dimmed like a hidden window.
                local color = self.recent.color or WHITE;
                self.text:SetTextColor(color.r, color.g, color.b);
                self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
                self.text:SetAlpha(.65);
                self.status:SetAlpha(.65);
            elseif(self.win) then
                if(self.win.online ~= nil and not self.win.online and self.win.type == "whisper") then
                    self.text:SetTextColor(.5, .5, .5);
                    self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
                    self.canFade = true;
                elseif(self.win.unreadCount and self.win.unreadCount > 0) then
                    local color = windowNameColor(self.win);
                    self.text:SetTextColor(color.r, color.g, color.b);
                    self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipBlue");
                    self.canFade = false;
                else
                    local color = windowNameColor(self.win);
                    self.text:SetTextColor(color.r, color.g, color.b);
                    self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
                    self.canFade = true;
                end
                -- set opacity of button text.
                if(self.win and not self.win:IsShown() and self.canFade) then
                    self.text:SetAlpha(.65);
                    self.status:SetAlpha(.65);
                else
                    self.text:SetAlpha(1);
                    self.status:SetAlpha(1);
                end
            end
        end);
    button.GetMinimumWidth = function(self)
            return self.text:GetStringWidth()+40;
        end
    return button;
end

local function createGroup(title, list, maxButtons, showNone)
    groupCount = groupCount + 1;
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local group = CreateFrame("Frame", "WIM3MenuGroup"..groupCount, _G.WIM3Menu, "BackdropTemplate");

    group.list = list;
    group.title = CreateFrame("Frame", group:GetName().."Title", group);
    group.title:SetHeight(17);
    group.title:SetPoint("TOPLEFT", 20, -18); group.title:SetPoint("TOPRIGHT", -20, -18);
    group.title.bg = group.title:CreateTexture(nil, "BACKGROUND");
    group.title.bg:SetAllPoints();
    group.title.text = group.title:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
    -- local font = group.title.text:GetFont();
    -- group.title.text:SetFont(font, 11, "");
    group.title.text:SetAllPoints();
    group.title.text:SetText(title.." ");
    group.title.text:SetJustifyV("TOP");
    group.title.text:SetJustifyH("RIGHT");
    group.buttons = {};
    local lastButton = group.title;
    local offSet = -32;
    for i=1, maxButtons do
        local button = createButton(group);
        button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT");
        button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", offSet, 0);
        offSet= 0;
        button.shown = false;
        lastButton = button;
        table.insert(group.buttons, button);
    end
    group.showNone = showNone;
    group.GetButtonCount = function(self)
        local count = 0;
        for i=1, #self.buttons do
            count = self.buttons[i].shown and count+1 or count;
        end
        return count;
    end
    group.UpdateHeight = function(self)
        if(self:GetButtonCount() == 0 and not self.showNone) then
            group:SetHeight(0);
        else
            group:SetHeight(_G.math.max(group.title:GetHeight() + group.buttons[1]:GetHeight()*self:GetButtonCount() + 18*2, 64));
        end
    end

	group.ApplySkin = function(self, skin)

		-- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    	self.backdropInfo = {
			bgFile = skin.menu.background,
        	edgeFile = skin.menu.edge,
        	tile = skin.menu.tile,
			tileSize = skin.menu.tile_size,
			edgeSize = skin.menu.edge_size,
        	insets = {
				left = skin.menu.insets.left,
				right = skin.menu.insets.right,
				top = skin.menu.insets.top,
				bottom = skin.menu.insets.bottom
			}
		};

		self:ApplyBackdrop();

		-- title font
		self.title.text:SetFont(
			skin.menu.title.font,
			skin.menu.title.font_height,
			skin.menu.title.font_flags
		);

		-- title color
		if(type(skin.menu.title.font_color) == "table") then
            self.title.text:SetTextColor(unpack(skin.menu.title.font_color));
        else
            self.title.text:SetTextColor(RGBHexToPercent(skin.menu.title.font_color));
        end

		-- buttons
		for i=1, #self.buttons do
			local button = self.buttons[i];
			button:ApplySkin(skin);
		end
	end

    group.width = 0;
    group.extra = nil; -- optional second list of persistent-history entries (whisper group only)
    group.Refresh = function(self)
        local maxWidth = 150-18*2;
        table.sort(self.list, sortWindows);
        local extra = self.extra;
        local extraCount = extra and #extra or 0;
        local total = #self.list + extraCount;
        local bnIcon = bnIconMarkup();
        for i=1, #self.buttons do
            local button = self.buttons[i];
            if(i > total) then
                button.win = nil;
                button.recent = nil;
                button:Hide();
                button.shown = false;
            else
                if(i <= #self.list) then
                    button.win = self.list[i];
                    button.recent = nil;
                    button.close:Show();
                    button.status:Show();
                    button.text:SetText((button.win.isBN and bnIcon or "")..button.win.theUser);
                else
                    -- persistent-history entry: same dot and close button as a live row.
                    button.win = nil;
                    button.recent = extra[i - #self.list];
                    button.close:Show();
                    button.status:Show();
                    button.text:SetText((button.recent.isBN and bnIcon or "")..button.recent.theUser);
                end
                button:Show();
                button:Enable();
                button.text:SetJustifyH("LEFT");
                button.shown = true;
                maxWidth = _G.math.max(maxWidth, button:GetMinimumWidth());
                self:Show();
            end
        end
        self.title:Show();
        if(total == 0) then
            if(self.showNone) then
                self.buttons[1].win = nil;
                self.buttons[1].recent = nil;
                self.buttons[1].close:Hide();
                self.buttons[1].status:Hide();
                self.buttons[1]:Show();
                self.buttons[1].shown = true;
                self.buttons[1]:Disable();
                self.buttons[1].text:SetJustifyH("LEFT");
                self.buttons[1].text:SetText(L["None"]);
                self.buttons[1].text:SetTextColor(.5, .5, .5);
            else
                self.title:Hide();
                self:Hide();
            end
        end
        self.width = maxWidth+18*2;
        self:UpdateHeight();
    end
    return group;
end


local function createMenu()
    local menu = CreateFrame("Frame", "WIM3Menu", _G.UIParent);
    menu:Hide(); -- testing only.
    menu:SetClampedToScreen(true);
    menu:SetFrameStrata("DIALOG");
    menu:SetToplevel(true);
    menu:SetWidth(180);
    menu:SetHeight(200);
    menu.groups = {};
    --create whisper group
    menu.groups[1] = createGroup(L["Whispers"], lists.whisper, maxButtons.whisper, true);
    menu.groups[1].extra = recentWhispers;
    menu.groups[1]:SetPoint("TOPLEFT");
    menu.groups[1]:SetPoint("TOPRIGHT");
    --create chat group
    menu.groups[2] = createGroup(L["Chat"], lists.chat, maxButtons.chat, false);
    menu.groups[2]:SetPoint("TOPLEFT", menu.groups[1], "BOTTOMLEFT", 0, 25);
    menu.groups[2]:SetPoint("TOPRIGHT", menu.groups[1], "BOTTOMRIGHT", 0, 25);

    menu.Refresh = function(self)
            local groupHeight = 0;
            local groupWidth = 0;
            buildRecentWhispers();
            for i=1, #self.groups do
                self.groups[i]:Refresh();
                groupHeight = groupHeight + self.groups[i]:GetHeight();
                groupWidth = _G.math.max(groupWidth, self.groups[i].width);
            end
            self:SetHeight(groupHeight);
            self:SetWidth(groupWidth);
        end

	menu.ApplySkin = function(self, skin)

		for i=1, #self.groups do
			local group = self.groups[i];
			group:ApplySkin(skin or GetSelectedSkin());
		end

		self:Refresh();
	end

    menu:SetScript("OnUpdate", function(self)
            if(isMouseOver()) then
                self.mouseStamp = _G.time();
            else
                if((_G.time() - self.mouseStamp) > 1) then
                    self:Hide();
                end
            end
        end);
    menu:SetScript("OnShow", function(self)
            self.mouseStamp = _G.time();
            libs.DropDownMenu.CloseDropDownMenus();
            self:Refresh(); -- pick up new history / setting changes each time the menu opens.
        end);

    return menu;
end


function Menu:OnWindowCreated(obj)
    -- add obj to specified list & Update
    if(obj.type == "whisper" or obj.type == "chat") then
        addToTableUnique(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowDestroyed(obj)
    -- remove obj to specified list & Update
    obj.widgets.close.forceShift = nil;
    if(obj.type == "whisper" or obj.type == "chat") then
        removeFromTable(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowPopped(obj)
    -- check status of obj to specified list & Update
    if(obj.type == "whisper" or obj.type == "chat") then
        WIM.Menu:Refresh();
    end
end


-- for convention, we will load the module as normal.
function Menu:OnEnable()
    if(not WIM.Menu) then
        WIM.Menu = createMenu();
        WIM.Menu:Refresh();
    end
end

function Menu:OnSkinLoaded(skin)
	if (WIM.Menu) then
		WIM.Menu:ApplySkin(skin);
	end
end


-- This is a core module and must always be loaded...
Menu.canDisable = false;
Menu:Enable();
