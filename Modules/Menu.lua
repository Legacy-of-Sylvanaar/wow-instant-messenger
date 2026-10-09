--import
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local ipairs = ipairs;
local pairs = pairs;
local table = table;
local type = type;
local unpack = unpack;
local string = string;

--set namespace
setfenv(1, WIM);

local Menu = CreateModule("Menu", true);

local groupCount = 0;
local buttonCount = 0;

local AUTO_CLOSE_TIMEOUT = 3;
local AUTO_CLOSE_TIMEOUT_INTERACTED = 1;
-- opened by hovering a launcher: close this soon after the cursor leaves both the
-- launcher and the menu, the way a tooltip would, with time to cross between them.
local HOVER_CLOSE_DELAY = 0.4;

local initialSkinLoaded = false;

local lists = {
    whisper = {},
    chat = {}
}
local maxButtons = {
    whisper = 30, -- live windows plus recent whispers from history
    chat = 10
};

db_defaults.menuSortActivity = true;
db_defaults.menuShowFooter = true;

-- Recent whispers (db.minimap.recentWhispers): entries built from saved whisper
-- history for people who have no window open right now. Each entry is
-- { theUser = display name, target = name to whisper, time = last message time,
--   sources = { {tbl, realm, character, convo}, ... }, isBN, color }.
local recentWhispers = {};
-- the open whisper windows that pass the list rules (see applyListRules).
local visibleWindows = {};

local BLIP_CLEAR = "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear";

-- strip the realm from a name so it compares the same written either way.
local function realmKey(realm)
    return string.lower((string.gsub(realm, "[%s%-]", "")));
end

local function safeName(user)
    -- mirror WhisperEngine: strip a same-realm suffix and lowercase.
    if(type(user) ~= "string") then
        return "";
    end
    local player, realm = string.match(user, "^(.-)%-(.-)$");
    if(player and realm and env and env.realm and realmKey(realm) == realmKey(env.realm)) then
        user = player;
    end
    return string.lower(user);
end

-- Battle.net history is saved under the BattleTag (Name#1234) or, for old
-- RealID friends, the e-mail address. Neither can appear in a character name.
local function isBNName(name)
    return string.find(name, "#", 1, true) ~= nil or string.find(name, "@", 1, true) ~= nil;
end

local function sortRecent(a, b)
    return a.time > b.time;
end

-- find the Battle.net account id for a saved conversation name.
-- BNet_GetBNetIDAccount only knows online friends, so fall back to scanning the
-- whole friend list when the name is a BattleTag.
local function resolveBNetID(name)
    if(type(name) ~= "string" or name == "") then
        return nil;
    end
    local bnID = _G.BNet_GetBNetIDAccount and _G.BNet_GetBNetIDAccount(name);
    if(bnID) then
        return bnID;
    end
    if(isBNName(name) and _G.BNGetNumFriends) then
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
local BN_ICON_SIZE = 16; -- a little larger than the row font so the logo reads clearly

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
        local r, g, b = utils.color.RGBHexToPercent(info.color);
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
    local token = classTokenByLocalized(win.class) or win.wimSavedClass;
    if(not token and ForEachWhisperConvoWith) then
        -- not learnt this session yet (a window reopened after a reload, or a conversation
        -- from another character): use the class History saved with any of them.
        ForEachWhisperConvoWith(win.theUser, function(convoTbl)
            local info = convoTbl.info;
            if(not token and type(info) == "table" and type(info.class) == "string" and info.class ~= "") then
                token = info.class;
            end
        end);
        win.wimSavedClass = token; -- found once, kept for the window's lifetime
    end
    return classColorByToken(token) or WHITE;
end

-- class token for a recent-whisper entry: saved with the conversation by History, or for
-- older history, looked up live from the guild roster and the friends list.
local function recentClassToken(entry)
    for i=1, #entry.sources do
        local info = entry.sources[i].tbl.info;
        if(type(info) == "table" and type(info.class) == "string" and info.class ~= "") then
            return info.class;
        end
    end
    local name = entry.target;
    -- WIM.lists, not this file's own window lists.
    local guild = WIM.lists and WIM.lists.guild;
    local index = guild and guild[name];
    if(index and _G.GetGuildRosterInfo) then
        local rosterName, _, _, _, localizedClass, _, _, _, _, _, token = _G.GetGuildRosterInfo(index);
        if(type(rosterName) == "string") then
            rosterName = _G.Ambiguate and _G.Ambiguate(rosterName, "none") or rosterName;
            -- the cached roster index can go stale; only trust it if the name still matches.
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

-- call fn(convoTable, target, lastMessage, realm, character, convo) for every whisper
-- conversation saved for one character. target is the name to whisper: history from another
-- realm is qualified as Name-Realm so the whisper reaches the right person. Battle.net names
-- are realm independent, and WoW Forever keys history by ruleset rather than by realm, so
-- both are left alone.
local function forEachWhisperConvo(realm, character, convos, fn)
    local qualify = not isForever and realm ~= env.realm;
    local realmSuffix = "-"..string.gsub(realm, "[%s%-]", "");
    for convo, tbl in pairs(convos) do
        local last = type(tbl) == "table" and tbl[#tbl];
        if(type(last) == "table" and last.type == 1 and not (tbl.info and tbl.info.chat)
            and type(convo) == "string" and convo ~= "") then
            local target = convo;
            if(qualify and not isBNName(convo) and not string.find(convo, "-", 1, true)) then
                target = convo..realmSuffix;
            end
            fn(tbl, target, last, realm, character, convo);
        end
    end
end

-- call fn(...) as above for every saved whisper conversation in the configured scope: this
-- character only, or every character on the account. Other characters' history is rehydrated
-- in the background after login, so for the first few seconds the account-wide list can be
-- short; it fills in on its own the next time the menu opens.
local function forEachScopedConvo(settings, fn)
    if(settings.accountWide) then
        -- other characters normally finish loading a few seconds after login; if any are
        -- still queued, load them now so the list is complete (cheap once they are in).
        if(historyLoadQueue and #historyLoadQueue > 0 and EnsureAllHistoryLoaded) then
            EnsureAllHistoryLoaded();
        end
        for realm, characters in pairs(history) do
            if(realm ~= BN_PSEUDO_REALM and type(characters) == "table") then
                for character, convos in pairs(characters) do
                    if(type(convos) == "table") then
                        forEachWhisperConvo(realm, character, convos, fn);
                    end
                end
            end
        end
    else
        local convos = history[env.realm] and history[env.realm][env.character];
        if(convos) then
            forEachWhisperConvo(env.realm, env.character, convos, fn);
        end
    end
end

-- flag one saved conversation as closed from the menu. Nothing is deleted. The history
-- archive only re-saves conversations marked dirty, so mark it or the flag is lost at logout.
local function hideSource(tbl, realm, character, convo)
    tbl.info = tbl.info or {};
    tbl.info.menuHidden = true;
    MarkHistoryDirty(realm, character, convo);
end

-- collect one conversation into recentWhispers.
-- open: set of names that already have a window; seen: name -> entry for de-duplication.
-- Conversations closed from the menu carry info.menuHidden and are skipped; History clears
-- that flag the next time a whisper is exchanged with that person.
local function collectRecent(tbl, target, last, realm, character, convo, open, seen)
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
                 isBN = isBNName(target)};
        seen[key] = entry;
        table.insert(recentWhispers, entry);
    end
    -- remember every history table behind this entry so closing it hides all of them.
    table.insert(entry.sources, {tbl = tbl, realm = realm, character = character, convo = convo});
end

-- mark every saved conversation with this person as closed from the menu.
local function hideConvosFor(target)
    local settings = db and db.minimap and db.minimap.recentWhispers;
    if(not settings or not settings.enabled or not history or not env or not env.realm) then
        return;
    end
    local key = safeName(target);
    forEachScopedConvo(settings, function(tbl, convoTarget, _, realm, character, convo)
        if(safeName(convoTarget) == key) then
            hideSource(tbl, realm, character, convo);
        end
    end);
end

-- closing a recent-whisper entry: flag its history tables, nothing is deleted.
local function hideRecentEntry(entry)
    if(not entry or not entry.sources) then
        return;
    end
    for i=1, #entry.sources do
        local src = entry.sources[i];
        hideSource(src.tbl, src.realm, src.character, src.convo);
    end
end

-- the names a Battle.net window's history is saved under: the BattleTag (or toon name)
-- rather than the account name shown on the window.
local function bnHistoryNames(win)
    if(win.isBN and win.bn and win.bn.id) then
        local _, _, btag, _, toonName = GetBNGetFriendInfoByID(win.bn.id);
        return btag, (toonName ~= "" and toonName or nil);
    end
end

-- closing a live window from the menu: also keep it out of the recent list so it
-- does not pop straight back in as a history entry.
local function hideRecentForWindow(win)
    if(not win or win.type ~= "whisper") then
        return;
    end
    hideConvosFor(win.theUser);
    local btag, toonName = bnHistoryNames(win);
    if(btag) then hideConvosFor(btag); end
    if(toonName) then hideConvosFor(toonName); end
end

-- when you last chatted with an open window's person, either direction: this session's
-- last whisper, or the newest message in their saved history on any character.
local function lastChatTime(win)
    local t = win.wimLastChat or 0;
    if(ForEachWhisperConvoWith) then
        local btag, toonName = bnHistoryNames(win);
        for _, name in ipairs({win.theUser, btag, toonName}) do
            ForEachWhisperConvoWith(name, function(convoTbl)
                local last = convoTbl[#convoTbl];
                if(type(last) == "table" and last.time and last.time > t) then
                    t = last.time;
                end
            end);
        end
    end
    return t;
end

local function sortRanked(a, b)
    return a.time > b.time;
end

-- The Whispers list rules. Open windows and history entries are ranked together by when
-- you last chatted. The first settings.count are always listed; anyone further down only
-- while the last chat is within settings.keepMinutes, or while their window has unread
-- messages or is on screen. maxButtons.whisper rows at most. Hiding a row never closes the
-- window: it comes back with the next message.
local function applyListRules(settings)
    for i=#visibleWindows, 1, -1 do
        visibleWindows[i] = nil;
    end
    local now = _G.time();
    local always = _G.tonumber(settings.count) or 5;
    local keepFor = (_G.tonumber(settings.keepMinutes) or 10) * 60;
    local ranked = {};
    for i=1, #lists.whisper do
        local win = lists.whisper[i];
        table.insert(ranked, {win = win, time = lastChatTime(win),
            pinned = (win.unreadCount or 0) > 0 or win:IsShown()});
    end
    for i=1, #recentWhispers do
        table.insert(ranked, {entry = recentWhispers[i], time = recentWhispers[i].time});
    end
    table.sort(ranked, sortRanked);
    for i=#recentWhispers, 1, -1 do
        recentWhispers[i] = nil;
    end
    local kept = 0;
    for i=1, #ranked do
        local item = ranked[i];
        if(kept < maxButtons.whisper and (i <= always or now - item.time <= keepFor or item.pinned)) then
            kept = kept + 1;
            table.insert(item.win and visibleWindows or recentWhispers, item.win or item.entry);
        end
    end
end

-- rebuild recentWhispers from saved history, skipping anyone who already has a window,
-- then apply the list rules to both.
local function buildRecentWhispers()
    for i=#recentWhispers, 1, -1 do
        recentWhispers[i] = nil;
    end
    local settings = db and db.minimap and db.minimap.recentWhispers;
    if(not settings or not settings.enabled or not history or not env or not env.realm) then
        return;
    end
    local open, seen = {}, {};
    -- people with an open window are already listed by the menu.
    for i=1, #lists.whisper do
        local win = lists.whisper[i];
        if(win.theUser) then
            open[safeName(win.theUser)] = true;
            local btag, toonName = bnHistoryNames(win);
            if(btag) then open[safeName(btag)] = true; end
            if(toonName) then open[safeName(toonName)] = true; end
        end
    end
    local scanned = 0;
    forEachScopedConvo(settings, function(tbl, target, last, realm, character, convo)
        scanned = scanned + 1;
        collectRecent(tbl, target, last, realm, character, convo, open, seen);
    end);
    table.sort(recentWhispers, sortRecent);
    dPrint("Menu: recent whispers ("..(settings.accountWide and "all characters" or env.realm.."/"..env.character)
        .."): "..scanned.." whisper conversations scanned, "..#recentWhispers.." listed before the cap.");
    applyListRules(settings);
    -- colour the rows, and show the friend's account name for BattleTag entries when the friend is known.
    for i=1, #recentWhispers do
        local entry = recentWhispers[i];
        entry.color = recentNameColor(entry);
        if(entry.isBN) then
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

-- open (or create) the whisper window for a recent-whisper entry.
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

-- true while the cursor is inside `frame` (the menu by default).
local function isMouseOver(frame)
	local x,y = _G.GetCursorPosition();
	local menu = frame or WIM.Menu;
        if(not menu or not menu:IsVisible()) then
            return false;
        else
            local x1, y1 = (menu:GetLeft() or 0)*menu:GetEffectiveScale(), (menu:GetTop() or 0)*menu:GetEffectiveScale();
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
                -- recent-whisper entry: hide it from the menu, the conversation itself is kept.
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

	button:DisableDrawLayer("BACKGROUND");

	-- button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD");
    -- button:GetHighlightTexture():SetVertexColor(.196, .388, .8);

    button.text = _G[button:GetName().."Text"];
    button.text:ClearAllPoints();
	button.text._allowCustomFont = false; -- flag that this frame allows custom fonts.

    button.status = createStatusIcon(button);
    button.close = createCloseButton(button);

	button.ApplySkin = function(self, skin)
		SetWidgetFont(self.text, skin.menu.item.text);

		-- item text
		button.text:SetWordWrap(false);
		button.text:SetJustifyH(skin.menu.item.text.align or "LEFT");
		button.text:SetJustifyV(skin.menu.item.text.justify or "MIDDLE");
		button.text:SetVertexColor(unpack(skin.menu.item.text.font_color or {1, 1, 1}));
		button.text:ClearAllPoints();
		local points = skin.menu.item.text.points or {};
		for _, point in ipairs(points) do
			button.text:SetPoint(unpack(point));
		end

		-- close button
		button.close:SetWidth(skin.menu.item.close.width or skin.menu.item.height or 14);
		button.close:SetHeight(skin.menu.item.close.height or skin.menu.item.height or 14);
		button.close:ClearAllPoints();
		points = skin.menu.item.close.points or {};
		for _, point in ipairs(points) do
			button.close:SetPoint(unpack(point));
		end

		-- status icon
		button.status:ClearAllPoints();
		button.status:SetWidth(skin.menu.item.status.width or skin.menu.item.height or 14);
		button.status:SetHeight(skin.menu.item.status.height or skin.menu.item.height or 14);
		points = skin.menu.item.status.points or {};
		for _, point in ipairs(points) do
			button.status:SetPoint(unpack(point));
		end

		-- other adjustments
		button:SetHeight(skin.menu.item.height or 14);

		utils.skin.applyHighlightTexture(button, skin.menu.item.highlight.texture);
		local highlight = self:GetHighlightTexture();
		if(highlight) then
			if (utils.skin.getAtlasInfo(skin.menu.item.highlight.texture)) then
				highlight:SetTexCoord(0, 1, 0, 1);
			end;
			highlight:SetBlendMode(skin.menu.item.highlight.blendMode or "BLEND");
			highlight:SetVertexColor(unpack(skin.menu.item.highlight.color or {1, 1, 1, 1}));
			highlight:ClearAllPoints();
			highlight:SetHeight(button:GetHeight());
			points = skin.menu.item.highlight.points or {};
			if (#points > 0) then
				for _, point in ipairs(points) do
					highlight:SetPoint(unpack(point));
				end
			else
				highlight:SetAllPoints(button);
			end
		end
	end

    button:SetScript("OnClick", function(self, b)
            local win = self.win;
            if(not win and self.recent) then
                -- recent-whisper entry: open a window for that person first.
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
                -- WIM has no presence for history entries, so the native look shows no icon.
                local color = self.recent.color or WHITE;
                self.text:SetTextColor(color.r, color.g, color.b);
                self.status:SetTexture((not self.wimNativeStatus) and BLIP_CLEAR or nil);
                -- names stay at full strength so class colours read true; the dot is dimmed.
                self.text:SetAlpha(1);
                self.status:SetAlpha(.65);
            elseif(self.win) then
                -- The native look uses the friends list's status icons;
                -- the classic look keeps WIM's blips. WIM only tracks
                -- online/offline for whisper targets, so away/busy have
                -- no source here; non-whisper rows go iconless when
                -- native (a channel has no presence).
                local native = self.wimNativeStatus;
                if(self.win.online ~= nil and not self.win.online and self.win.type == "whisper") then
                    self.text:SetTextColor(.5, .5, .5);
                    self.status:SetTexture(native
                        and "Interface\\FriendsFrame\\StatusIcon-Offline"
                        or "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
                    self.canFade = true;
                elseif(self.win.unreadCount and self.win.unreadCount > 0) then
                    local color = windowNameColor(self.win);
                    self.text:SetTextColor(color.r, color.g, color.b);
                    self.status:SetTexture(native
                        and "Interface\\FriendsFrame\\StatusIcon-Online"
                        or "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipBlue");
                    self.canFade = false;
                else
                    local color = windowNameColor(self.win);
                    self.text:SetTextColor(color.r, color.g, color.b);
                    if(native) then
                        if(self.win.type == "whisper") then
                            self.status:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online");
                        else
                            self.status:SetTexture(nil);
                        end
                    else
                        self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
                    end
                    self.canFade = true;
                end
                -- set opacity of button text.
                if(self.win and not self.win:IsShown() and self.canFade) then
                    -- a hidden window dims its dot only; dimming the name muddies class colours.
                    self.text:SetAlpha(1);
                    self.status:SetAlpha(.65);
                else
                    self.text:SetAlpha(1);
                    self.status:SetAlpha(1);
                end
            end
        end);
    button.GetMinimumWidth = function(self)
            return self.text:GetStringWidth() + (GetSelectedMenuSkin().menu.item.text.margin or 0);
        end
    return button;
end

-- launcher hints in the footer: what it does on the left in white, matching the names
-- above, and the mouse click that does it on the right in blue, with the row controls.
local HINT_ACTION_COLOR = {1, 1, 1};
local HINT_CLICK_COLOR = {0.25, 0.65, 1};

-- The hint lines. Right-click and Shift + Right-Click swap when "Right-Click Opens
-- Unread" is on.
local function getFooterHints()
    local unreadFirst = db and db.minimap and db.minimap.rightClickNew;
    local hints = {
        {L["Right-Click"], unreadFirst and L["Show Unread"] or L["Tools"]},
        {L["Shift + Right-Click"], unreadFirst and L["Tools"] or L["Show Unread"]},
        {L["Shift + Middle-Click"], L["Options"]},
    };
    return hints;
end

-- The footer is one frame that the menu hands to whichever section is last, so it sits
-- inside that section's box in either menu style.
local function createFooter(parent)
    local footer = CreateFrame("Frame", "WIM3MenuFooter", parent);
    footer.rows = {};
    footer.rowHeight = 14;
    footer.SetHints = function(self, hints, skin)
        for i=1, _G.math.max(#hints, #self.rows) do
            local row = self.rows[i];
            if(not row and hints[i]) then
                row = {};
                row.action = self:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
                row.action:SetJustifyH("LEFT");
                row.key = self:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
                row.key:SetJustifyH("RIGHT");
                self.rows[i] = row;
            end
            if(row) then
                if(hints[i]) then
                    if(skin) then
                        SetWidgetFont(row.key, skin.menu.item.text);
                        SetWidgetFont(row.action, skin.menu.item.text);
                    end
                    row.action:SetTextColor(unpack(HINT_ACTION_COLOR));
                    row.key:SetTextColor(unpack(HINT_CLICK_COLOR));
                    row.key:SetText(hints[i][1]);
                    row.action:SetText(hints[i][2]);
                    row.action:ClearAllPoints();
                    row.action:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(i-1)*self.rowHeight);
                    row.key:ClearAllPoints();
                    row.key:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -(i-1)*self.rowHeight);
                    row.key:Show(); row.action:Show();
                else
                    row.key:Hide(); row.action:Hide();
                end
            end
        end
        self.count = #hints;
        self:SetHeight(self.rowHeight * #hints);
    end
    footer.GetMinimumWidth = function(self)
        local width = 0;
        for i=1, (self.count or 0) do
            local row = self.rows[i];
            width = _G.math.max(width, row.key:GetStringWidth() + row.action:GetStringWidth() + 24);
			        end
        return width;
    end
    return footer;
end

local function createGroup(title, list, maxButtons, showNone, showHeader)
    groupCount = groupCount + 1;
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local group = CreateFrame("Frame", "WIM3MenuGroup"..groupCount, _G.WIM3Menu, "BackdropTemplate");

    -- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    -- group.backdropInfo = {bgFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg",
    --     edgeFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu",
    --     tile = true, tileSize = 32, edgeSize = 32,
    --     insets = { left = 32, right = 32, top = 32, bottom = 32 }};

	-- group:ApplyBackdrop();

    group.list = list;
    group.title = CreateFrame("Frame", group:GetName().."Title", group);
	group.title:SetPoint("TOPLEFT", group, "TOPLEFT", 0, 0);
	group.title:SetPoint("TOPRIGHT", group, "TOPRIGHT", 0, 0);
    group.title.text = group.title:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
    group.title.text:SetText(title.." ");
	group.title.text:SetAllPoints();
	group.title.text._allowCustomFont = true;

	-- add-on name and version above the first section, like a tooltip header.
	if (showHeader) then
		group.header = CreateFrame("Frame", group:GetName().."Header", group);
		group.header.name = group.header:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
		group.header.name:SetPoint("LEFT");
		group.header.name:SetJustifyH("LEFT");
		group.header.name:SetText("WIM");
		group.header.version = group.header:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
		group.header.version:SetPoint("RIGHT");
		group.header.version:SetJustifyH("RIGHT");
		group.header.version:SetText(GetDisplayVersion());
	end

	-- debugging visuals
	-- group.bg = group:CreateTexture(nil, "BACKGROUND");
	-- group.bg:SetAllPoints();
	-- group.bg:SetColorTexture(0, 1, 0, 0.5);
	-- group.title.bg = group.title:CreateTexture(nil, "BACKGROUND");
	-- group.title.bg:SetAllPoints();
	-- group.title.bg:SetColorTexture(1, 0, 0, 0.5);

    group.buttons = {};
    local lastButton = group.title;
    for i=1, maxButtons do
        local button = createButton(group);
        button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0);
        button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0);
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
			local skin = GetSelectedMenuSkin();
			local btnCount = group:GetButtonCount()
			local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
			local padding = skin and skin.menu.padding or {0, 0, 0, 0};
			local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
			local offsetTop = groupMode and offsets[3] or 0;
			local offsetBottom = groupMode and offsets[4] or 0;
			local paddingTop = groupMode and padding[3] or 0;
			local paddingBottom = groupMode and padding[4] or 0;
			local totalVerticalPadding = groupMode and (paddingTop + paddingBottom + offsetTop + offsetBottom) or 0;
			local minHeight = skin and skin.menu.minHeight or 64;
			local marginTop = groupMode and skin and skin.menu.item.marginTop or 0;
			local marginBottom = groupMode and skin and skin.menu.item.marginBottom or 0;

			local headerHeight = group.header and (group.header:GetHeight() + (group.headerGap or 0)) or 0;
			-- the launcher hints, when this is the last section: a blank line, then the rows.
			local footerHeight = group.footer and (group.footer:GetHeight() + group.footer.rowHeight) or 0;

            group:SetHeight(_G.math.max(headerHeight + footerHeight + group.title:GetHeight() + group.buttons[1]:GetHeight()*btnCount + totalVerticalPadding + marginTop + marginBottom, minHeight ));
        end
    end

	group.ApplySkin = function(self, skin)
		skin = skin or GetSelectedMenuSkin();
		local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
		local padding = skin and skin.menu.padding or {0, 0, 0, 0};
		local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
		local paddingLeft = padding[1] or 0;
		local paddingRight = padding[2] or 0;
		local paddingTop = groupMode and padding[3] or 0;
		local paddingBottom = groupMode and padding[4] or 0;
		local offsetLeft = offsets[1] or 0;
		local offsetRight = offsets[2] or 0;
		local offsetTop = groupMode and offsets[3] or 0;
		local gap = not groupMode and skin.menu.gap or 0;

		-- if in group mode
		if (groupMode) then
			local atlas = skin.menu.texture;
			local backdropInfo = skin.menu.backdropInfo;

			-- init atlas textureObject
			if (not self._atlasTexture) then
				self._atlasTexture = self:CreateTexture(nil, "BACKGROUND");
				self._atlasTexture:SetAllPoints();
			end;

			-- use backdrop
			if (type(backdropInfo) == "table") then
				self:SetBackdrop(backdropInfo);
				self:SetBackdropColor(unpack(backdropInfo.bgColor or {1, 1, 1, 1}));
				self:SetBackdropBorderColor(unpack(backdropInfo.edgeColor or {1, 1, 1, 1}));

				self._atlasTexture:Hide();

				dPrint("Menu.group:ApplySkin: Using backdrop for group");

			-- use atlas
			else
				self:ClearBackdrop();

				utils.skin.applyTexture(self._atlasTexture, atlas);
				self._atlasTexture:SetAlpha(skin.menu.textureAlpha or 1);
				self._atlasTexture:Show();

				dPrint("Menu.group:ApplySkin: Using atlas for group");
			end

			if (self._dividerTexture) then
				self._dividerTexture:Hide();
			end;

		-- non-group mode: clear atlas and backdropInfo
		else
			dPrint("Menu.group:ApplySkin: Non-group mode, clearing atlas and backdrop");

			self:ClearBackdrop();
			if (self._atlasTexture) then
				self._atlasTexture:Hide();
			end;

			-- divider texture
			self._dividerTexture = self._dividerTexture or self:CreateTexture(nil, "ARTWORK");

			self._dividerTexture:Hide();
			self._dividerTexture:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent");
			self._dividerTexture:ClearAllPoints();
			self._dividerTexture:SetPoint("TOPLEFT", self.title, "TOPLEFT", 0, 7.5 + gap * .5);
			self._dividerTexture:SetPoint("TOPRIGHT", self.title, "TOPRIGHT", 0, 7.5 + gap * .5);
			self._dividerTexture:SetTexCoord(0, 1, 0, 1);
			self._dividerTexture:SetHeight(13);
			if (not groupMode and self.wimWantsDivider) then
				self._dividerTexture:Show();
			end
		end

		-- title skinning
		local titleHeight = skin.menu.title.height or skin.menu.title.font_height or 12;
		SetWidgetFont(self.title.text, skin.menu.title);
		self.title.text:SetJustifyH(skin.menu.title.align or "LEFT");
		self.title.text:SetJustifyV(skin.menu.title.justify or "TOP");
		local titleTop = offsetTop + paddingTop;
		if (self.header) then
			-- header in the title font: name in the title colour, version greyed on the right.
			self.header:ClearAllPoints();
			self.header:SetPoint("TOPLEFT", self, "TOPLEFT", paddingLeft + offsetLeft, -titleTop);
			self.header:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -(paddingRight + offsetRight), -(titleTop + titleHeight));
			SetWidgetFont(self.header.name, skin.menu.title);
			SetWidgetFont(self.header.version, skin.menu.title);
			self.header.version:SetTextColor(.5, .5, .5);
			-- two blank lines between the name and the first section.
			self.headerGap = titleHeight * 2;
			titleTop = titleTop + titleHeight + self.headerGap;
		end
		self.title:ClearAllPoints();
		self.title:SetPoint("TOPLEFT", self, "TOPLEFT", paddingLeft + offsetLeft, -titleTop);
		self.title:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -(paddingRight + offsetRight), -(titleTop + titleHeight));


		-- title font + color. SetWidgetFont resolves every form a skin may
		-- declare (font object name, LibSharedMedia name, or file path); a
		-- raw SetFont here would silently no-op on anything but a path.
		SetWidgetFont(self.title.text, skin.menu.title);
		self.title.text:SetWordWrap(false);

		-- buttons
		local marginTop = skin and skin.menu.item.marginTop or 0;
		local prev = self.title;
		for i=1, #self.buttons do
			local button = self.buttons[i];
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, i == 1 and (-marginTop) or 0);
			button:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, i == 1 and (-marginTop) or 0);
			button:ApplySkin(skin);
			prev = button;
		end
	end
    group.width = 0;
    group.extra = nil; -- optional second list of recent-whisper entries (whisper group only)
    group.Refresh = function(self)
        local maxWidth = 150;
        if (self.header) then
            maxWidth = _G.math.max(maxWidth, self.header.name:GetStringWidth() + self.header.version:GetStringWidth() + 24);
        end
        -- the Whispers section shows only the windows that pass the list rules.
        local list = self.displayList or self.list;
        table.sort(list, sortWindows);
        local extra = self.extra;
        local total = #list + (extra and #extra or 0);
        local bnIcon = bnIconMarkup();
        for i=1, #self.buttons do
            local button = self.buttons[i];
            if(i > total) then
                button.win = nil;
                button.recent = nil;
                button:Hide();
                button.shown = false;
            else
                if(i <= #list) then
                    button.win = list[i];
                    button.recent = nil;
                    button.text:SetText((button.win.isBN and bnIcon or "")..button.win.theUser);
                else
                    -- recent-whisper entry: same dot and close button as a live row.
                    button.win = nil;
                    button.recent = extra[i - #list];
                    button.text:SetText((button.recent.isBN and bnIcon or "")..button.recent.theUser);
                end
                button.close:Show();
                button.status:Show();
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

        if(self.footer) then
            local last = self.buttons[_G.math.max(1, self:GetButtonCount())];
            self.footer:SetParent(self);
            self.footer:ClearAllPoints();
            self.footer:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -self.footer.rowHeight);
            self.footer:SetPoint("TOPRIGHT", last, "BOTTOMRIGHT", 0, -self.footer.rowHeight);
            self.footer:Show();
            maxWidth = _G.math.max(maxWidth, self.footer:GetMinimumWidth());
        end

        self.width = maxWidth
        self:UpdateHeight();
    end
    return group;
end


local function createMenu()
    local menu = CreateFrame("Frame", "WIM3Menu", _G.UIParent, "BackdropTemplate");
    menu:Hide(); -- testing only.
    menu:SetClampedToScreen(true);
    menu:SetFrameStrata("FULLSCREEN_DIALOG");
    menu:SetToplevel(true);
    menu:SetWidth(180);
    menu:SetHeight(200);
    menu.groups = {};
    --create whisper group
    menu.groups[1] = createGroup(L["Whispers"], lists.whisper, maxButtons.whisper, true, true);
    menu.groups[1].extra = recentWhispers;
    menu.groups[1]:SetPoint("TOPLEFT");
    menu.groups[1]:SetPoint("TOPRIGHT");
    --create chat group
    menu.groups[2] = createGroup(L["Chat"], lists.chat, maxButtons.chat, false);
    menu.groups[2]:SetPoint("TOPLEFT", menu.groups[1], "BOTTOMLEFT", 0, 0);
    menu.groups[2]:SetPoint("TOPRIGHT", menu.groups[1], "BOTTOMRIGHT", 0, 0);
    -- Sections after the first show the native divider above their
    -- header while the context style is active.
    menu.groups[2].wimWantsDivider = true;

    menu.Refresh = function(self)
			local skin = GetSelectedMenuSkin();
			local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
            local groupHeight = 0;
            local groupWidth = 0;
			local maxTop = 0;
			local minBottom = _G.math.huge;
            -- Refresh also runs on every window pop while the menu is closed. Walking the
            -- saved history is only worth it when the menu is visible; OnShow refreshes again.
            if(self:IsShown()) then
                buildRecentWhispers();
                local settings = db and db.minimap and db.minimap.recentWhispers;
                self.groups[1].displayList = (settings and settings.enabled) and visibleWindows or nil;
            end

			-- conditionally create/delete footer depending on options
			if (db and db.menuShowFooter) then
				if (not self.footer) then
					self._footer = self._footer or createFooter(self);
					self.footer = self._footer;
					self.footer:Show();
				end
			else
				if (self.footer) then
					self.footer:Hide()
					self.footer = nil;
				end
			end;

            -- the footer goes in the last section that is showing: Chat when there are chat
            -- windows, otherwise Whispers (which always shows).
            local footerOwner = (#lists.chat > 0) and self.groups[2] or self.groups[1];
            for i=1, #self.groups do
                self.groups[i].footer = (self.groups[i] == footerOwner) and self.footer or nil;
            end

			if (self.footer) then
				self.footer.rowHeight = self.groups[1].buttons[1]:GetHeight();
				self.footer:SetHints(getFooterHints(), skin);
			end;

            for i=1, #self.groups do
                self.groups[i]:Refresh();
                groupHeight = groupHeight + self.groups[i]:GetHeight();
                groupWidth = _G.math.max(groupWidth, self.groups[i].width);
				local top = self.groups[i]:GetTop() or 0;
				local bottom = self.groups[i]:GetBottom() or 0;

				if (top ~= 0 or bottom ~= 0) then
					maxTop = _G.math.max(maxTop, top);
					minBottom = _G.math.min(minBottom, bottom);
				end;
            end
			minBottom = _G.math.min(minBottom, maxTop);

			groupHeight = maxTop - minBottom;
			local calculatedHeight = groupHeight -- + (db and not db.modernTheme.menuGroups and verticalPadding or 0);

			local padding = skin and skin.menu.padding or {0, 0, 0, 0};
			local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
			local paddingLeft = padding[1] or 0;
			local paddingRight = padding[2] or 0;
			local offsetLeft = offsets[1] or 0;
			local offsetRight = offsets[2] or 0;
			local paddingTop = not groupMode and padding[3] or 0;
			local paddingBottom = not groupMode and padding[4] or 0;
			local offsetTop = offsets[3] or 0;
			local offsetBottom = offsets[4] or 0;
			local marginBottom = not groupMode and skin and skin.menu.item.marginBottom or 0;

            self:SetWidth(groupWidth + offsetLeft + offsetRight + paddingLeft + paddingRight);
			if (calculatedHeight > 0) then
				local height = calculatedHeight + offsetTop + offsetBottom + marginBottom + paddingTop + paddingBottom
				self:SetHeight(height);
			end;
        end

	menu.ApplySkin = function(self, skin)
		skin = skin or GetSelectedMenuSkin();
		local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
		local padding = skin and skin.menu.padding or {0, 0, 0, 0};
		local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
		local offsetLeft = offsets[1] or 0;
		local offsetRight = offsets[2] or 0;
		local offsetTop = offsets[3] or 0;
		local offsetBottom = offsets[4] or 0;
		local paddingLeft = padding[1] or 0;
		local paddingRight = padding[2] or 0;
		local paddingTop = padding[3] or 0;
		local paddingBottom = padding[4] or 0;

		-- if not in group mode
		if (not groupMode) then
			local atlas = skin.menu.texture;
			local backdropInfo = skin.menu.backdropInfo;

			-- init atlas textureObject
			if (not self._atlasTexture) then
				self._atlasTexture = self:CreateTexture(nil, "BACKGROUND");
				self._atlasTexture:SetAllPoints();
			end;

			-- use backdrop
			if (type(backdropInfo) == "table") then
				self:SetBackdrop(backdropInfo);
				self:SetBackdropColor(unpack(backdropInfo.bgColor or {1, 1, 1, 1}));
				self:SetBackdropBorderColor(unpack(backdropInfo.edgeColor or {1, 1, 1, 1}));

				self._atlasTexture:Hide();

				dPrint("Menu:ApplySkin: Using backdrop for menu");

			-- use atlas
			else
				self:ClearBackdrop();

				utils.skin.applyTexture(self._atlasTexture, atlas);
				self._atlasTexture:SetAlpha(skin.menu.textureAlpha or 1);
				self._atlasTexture:SetAllPoints();
				self._atlasTexture:Show();

				dPrint("Menu:ApplySkin: Using atlas for menu");
			end

		-- group mode: clear atlas and backdropInfo
		else
			dPrint("Menu.ApplySkin: Using group mode, clearing atlas and backdrop");
			self:ClearBackdrop();
			if (self._atlasTexture) then
				self._atlasTexture:Hide();
			end;
		end

		local verticalPadding = groupMode and (offsetTop + offsetBottom) or 0;
		local gap = (skin and skin.menu.gap or 0) - verticalPadding;
		for i=1, #self.groups do
			local group = self.groups[i];
			if (i == 1) then
				group:ClearAllPoints();
				group:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(not groupMode and (offsetTop + paddingTop) or 0));
				group:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -(not groupMode and (offsetTop + paddingTop) or 0));
			else
				group:ClearAllPoints();
				group:SetPoint("TOPLEFT", self.groups[i-1], "BOTTOMLEFT", 0, -gap);
				group:SetPoint("TOPRIGHT", self.groups[i-1], "BOTTOMRIGHT", 0, -gap);
			end
			group:ApplySkin(skin);
		end

		self:Refresh();
		initialSkinLoaded = true;
	end

    menu:SetScript("OnUpdate", function(self)
            if(self.hoverOwner) then
                if(isMouseOver() or isMouseOver(self.hoverOwner)) then
                    self.hoverStamp = _G.GetTime();
                elseif((_G.GetTime() - (self.hoverStamp or 0)) > HOVER_CLOSE_DELAY) then
                    self:Hide();
                end
                return;
            end
            if(isMouseOver()) then
				self.AUTO_CLOSE_TIMEOUT = AUTO_CLOSE_TIMEOUT_INTERACTED;
                self.mouseStamp = _G.time();
            else
                if((_G.time() - self.mouseStamp) > self.AUTO_CLOSE_TIMEOUT) then
                    self:Hide();
                end
            end
        end);
    -- Show the menu at a launcher. hover = true when it was opened by mousing over the
    -- launcher: it then closes like a tooltip once the cursor leaves both. A click
    -- (hover = false) pins it the old way, closing a moment after the cursor leaves.
    menu.ShowFor = function(self, owner, hover)
        self.hoverOwner = hover and owner or nil;
        self.hoverStamp = _G.GetTime();
        self.mouseStamp = _G.time();
        self:Show();
    end
    menu:SetScript("OnHide", function(self)
        self.hoverOwner = nil;
    end);
    menu:SetScript("OnShow", function(self)
		if (not initialSkinLoaded) then
			local skin = GetSelectedMenuSkin();
			if(skin) then
				self:ApplySkin(skin);
			end
		end

		self.AUTO_CLOSE_TIMEOUT = AUTO_CLOSE_TIMEOUT;
        self.mouseStamp = _G.time();
        -- Labels can change after a window is created. A community
        -- window is renamed from its clubId:streamId key to the real
        -- community name one line after OnWindowCreated refreshed this
        -- menu, so rebuild the labels every time the menu opens.
        self:Refresh();
        libs.DropDownMenu.CloseDropDownMenus();
    end);

    return menu;
end


function Menu:OnWindowCreated(obj)
    -- add obj to specified list & Update
    if(obj.type == "whisper" or obj.type == "chat") then
        utils.table.addToTableUnique(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowDestroyed(obj)
    -- remove obj to specified list & Update
    obj.widgets.close.forceShift = nil;
    if(obj.type == "whisper" or obj.type == "chat") then
        utils.table.removeFromTable(lists[obj.type], obj);
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
        -- Enable runs from this file's main chunk, before any skin has
        -- registered. In that case the construction-time backdrop stays
        -- until the login LoadSkin dispatches OnSkinLoaded. If the menu
        -- is created later than that, apply the active skin now;
        -- ApplySkin ends with a Refresh.
        local skin = GetSelectedMenuSkin();
        if(skin) then
            WIM.Menu:ApplySkin(skin);
        else
            WIM.Menu:Refresh();
        end
    end
end

function Menu:OnMenuSkinLoaded(skin)
	if (WIM.Menu) then
		WIM.Menu:ApplySkin(skin);
	end
end


-- This is a core module and must always be loaded...
Menu.canDisable = false;
Menu:Enable();
