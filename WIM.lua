-- imports
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local select = select;
local type = type;
local table = table;
local unpack = unpack;
local pairs = pairs;
local string = string;
local next = next;
local Ambiguate = Ambiguate;

-- set name space
setfenv(1, WIM);

-- Core information
addonTocName = "WIM";
version = "@project-version@";
beta = false; -- flags current version as beta.
debug = false; -- turn debugging on and off.
useProtocol2 = true; -- test switch for new W2W Protocol. (Dev use only)
local buildNumber = select(4, _G.GetBuildInfo());
isModernApi = buildNumber >= 90001; -- Still needed for non synced invite API and for classID checks

constants = {}; -- constants such as class colors will be stored here. (includes female class names).
modules = {}; -- module table. consists of all registerd WIM modules/plugins/skins. (treated the same).
windows = {active = {whisper = {}, chat = {}, w2w = {}}}; -- table of WIM windows.
libs = {}; -- table of loaded library references.
stats = {};

-- default options. live data is found in WIM.db
-- modules may insert fields into this table to
-- respect their option contributions.
db_defaults = {
    enabled = true,
    showToolTips = true,
    modules = {},
    alertedPrivateServer = false,
};

-- WIM.env is an evironmental reference for the current instance of WIM.
-- Information is stored here such as .realm and .character.
-- View table dump for more available information.
env = {};

-- default lists - This will store lists such as friends, guildies, raid members etc.
lists = {};

-- list of all the events registered from attached modules.
local Events = {};

-- create a frame to moderate events and frame updates.
    local workerFrame = CreateFrame("Frame", "WIM_workerFrame");
    workerFrame:SetScript("OnEvent", function(self, event, ...) WIM:CoreEventHandler(event, ...); end);

    -- some events we always want to listen to so data is ready upon WIM being enabled.
    workerFrame:RegisterEvent("VARIABLES_LOADED");
    workerFrame:RegisterEvent("ADDON_LOADED");

-- import libraries.
libs.SML = _G.LibStub:GetLibrary("LibSharedMedia-3.0");
libs.DropDownMenu = _G.LibStub:GetLibrary("LibDropDownMenu");

-- called when WIM is first loaded into memory but after variables are loaded.
local function initialize()
    --load cached information from the WIM_Cache saved variable.
	env.cache[env.realm] = env.cache[env.realm] or {};
    env.cache[env.realm][env.character] = env.cache[env.realm][env.character] or {};
	lists.friends = env.cache[env.realm][env.character].friendList;
	lists.guild = env.cache[env.realm][env.character].guildList;

	if(type(lists.friends) ~= "table") then lists.friends = {}; end
	if(type(lists.guild) ~= "table") then lists.guild = {}; end

	workerFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	workerFrame:RegisterEvent("FRIENDLIST_UPDATE");
	workerFrame:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
	workerFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED");

	--querie guild roster
	if( _G.IsInGuild() ) then
		-- H.Sch. - ReglohPri - this is deprecated -> GuildRoster() - changed to C_GuildInfo.GuildRoster()
		_G.C_GuildInfo.GuildRoster();
	end

    isInitialized = true;

    RegisterPrematureSkins();

    --enableModules
    for moduleName, tData in pairs(modules) do
        modules[moduleName].db = db;
        if(modules[moduleName].canDisable ~= false) then
            local modDB = db.modules[moduleName];
            if(modDB) then
                if(modDB.enabled == nil) then
                    modDB.enabled = modules[moduleName].enableByDefault;
                end
                EnableModule(moduleName, modDB.enabled);
            else
                if(modules[moduleName].enableByDefault) then
                    EnableModule(moduleName, true);
                end
            end
        else
                EnableModule(moduleName, true);
        end
    end

        for mName, module in pairs(modules) do
                if(db.enabled) then
                        if(type(module.OnEnableWIM) == "function") then
                            module:OnEnableWIM();
                        end
                else
                        if(type(module.OnDisableWIM) == "function") then
                            module:OnDisableWIM();
                        end
                end
        end

    -- notify all modules of current state.
    CallModuleFunction("OnStateChange", WIM.curState);
    RegisterSlashCommand("enable", function() SetEnabled(not db.enabled) end, L["Toggle WIM 'On' and 'Off'."]);
    RegisterSlashCommand("debug", function() debug = not debug; end, L["Toggle Debugging Mode 'On' and 'Off'."]);
    FRIENDLIST_UPDATE(); -- pretend event has been fired in order to get cache loaded.
    CallModuleFunction("OnInitialized");
    WindowParent:Show();
    dPrint("WIM initialized...");
end

--Retail and Classic bnet apis are now mostly in sync, but i'm keeping wrappers so if they ever get out of sync again, it's easy to fix in these wrappers
function GetBNGetFriendInfo(friendIndex)
	if friendIndex == 0 then
		return GetBNGetFriendInfoByID(select(3, _G.BNGetInfo()));
	end
	local accountInfo = _G.C_BattleNet.GetFriendAccountInfo(friendIndex);
	if accountInfo then
		local wowProjectID = accountInfo.gameAccountInfo.wowProjectID or 0;
		local clientProgram = accountInfo.gameAccountInfo.clientProgram ~= "" and accountInfo.gameAccountInfo.clientProgram or nil;

		return	accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.isBattleTagFriend,
			accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, clientProgram,
			accountInfo.gameAccountInfo.isOnline, accountInfo.lastOnlineTime, accountInfo.isAFK, accountInfo.isDND, accountInfo.customMessage, accountInfo.note, accountInfo.isFriend,
			accountInfo.customMessageTime, wowProjectID, accountInfo.rafLinkType == _G.Enum.RafLinkType.Recruit, accountInfo.gameAccountInfo.canSummon, accountInfo.isFavorite, accountInfo.gameAccountInfo.isWowMobile;
	end
end

function GetBNGetFriendInfoByID(id)
	local accountInfo = _G.C_BattleNet.GetAccountInfoByID(id) or {};
	if accountInfo and accountInfo.gameAccountInfo then
		local wowProjectID = accountInfo.gameAccountInfo.wowProjectID or 0;
		local clientProgram = accountInfo.gameAccountInfo.clientProgram ~= "" and accountInfo.gameAccountInfo.clientProgram or nil;

		return	accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.isBattleTagFriend,
			accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, clientProgram,
			accountInfo.gameAccountInfo.isOnline, accountInfo.lastOnlineTime, accountInfo.isAFK, accountInfo.isDND, accountInfo.customMessage, accountInfo.note, accountInfo.isFriend,
			accountInfo.customMessageTime, wowProjectID, accountInfo.rafLinkType == _G.Enum.RafLinkType.Recruit, accountInfo.gameAccountInfo.canSummon, accountInfo.isFavorite, accountInfo.gameAccountInfo.isWowMobile;
	end
end

function GetBNGetGameAccountInfoByKName(kName)
	for i=1, _G.BNGetNumFriends() do
		local info = {GetBNGetFriendInfo(i)};
		if info[2] and info[2] == kName then
			return info;
		end
	end
	return nil;
end

function GetBNGetGameAccountInfo(toonId)
	local gameAccountInfo = _G.C_BattleNet.GetGameAccountInfoByID(toonId)
	if gameAccountInfo then
		local wowProjectID = gameAccountInfo.wowProjectID or 0;
		local characterName = gameAccountInfo.characterName or "";
		local realmName = gameAccountInfo.realmName or "";
		local realmID = gameAccountInfo.realmID or 0;
		local factionName = gameAccountInfo.factionName or "";
		local raceName = gameAccountInfo.raceName or "";
		local className = gameAccountInfo.className or "";
		local areaName = gameAccountInfo.areaName or "";
		local characterLevel = gameAccountInfo.characterLevel or "";
		local richPresence = gameAccountInfo.richPresence or "";
		local gameAccountID = gameAccountInfo.gameAccountID or 0;
		local playerGuid = gameAccountInfo.playerGuid or 0;
		return	gameAccountInfo.hasFocus, characterName, gameAccountInfo.clientProgram,
			realmName, realmID, factionName, raceName, className, "", areaName, characterLevel,
			richPresence, nil, nil,
			gameAccountInfo.isOnline, gameAccountID, nil, gameAccountInfo.isGameAFK, gameAccountInfo.isGameBusy,
			playerGuid, wowProjectID, gameAccountInfo.isWowMobile
	end
end
--End Compat wrappers for retail and classic to access same functions and expect same returns

-- called when WIM is enabled.
-- WIM will not be enabled until WIM is initialized event is fired.
local function onEnable()
    db.enabled = true;

    for tEvent, _ in pairs(Events) do
        workerFrame:RegisterEvent(tEvent);
    end

        if(isInitialized) then
            for mName, module in pairs(modules) do
                if(type(module.OnEnableWIM) == "function") then
                    module:OnEnableWIM();
                end
                if(db.modules[mName] and db.modules[mName].enabled and type(module.OnEnable) == "function") then
                    module:OnEnable();
                end
            end
        end
	-- DisplayTutorial(L["WIM (WoW Instant Messenger)"], L["WIM is currently running. To access WIM's wide array of options type:"].." |cff69ccf0/wim|r");
    -- check if WhisperEngine is enabled, if not enable it.
	if not modules["WhisperEngine"].enabled then
		modules["WhisperEngine"]:Enable();
	end
	dPrint("WIM is now enabled.");
end

-- called when WIM is disabled.
local function onDisable()
    db.enabled = false;

    for tEvent, _ in pairs(Events) do
        workerFrame:UnregisterEvent(tEvent);
    end

    if(isInitialized) then
        for _, module in pairs(modules) do
            if(type(module.OnDisableWIM) == "function") then
                module:OnDisableWIM();
            end
            if(type(module.OnDisable) == "function") then
                module:OnDisable();
            end
        end
    end

    dPrint("WIM is now disabled.");
end


function SetEnabled(enabled)
    if( enabled ) then
        onEnable();
    else
        onDisable();
    end
end

-- events are passed to modules. Events do not need to be
-- unregistered. A disabled module will not receive events.
local function RegisterEvent(event)
    Events[event] = true;
    if( db and db.enabled ) then
        workerFrame:RegisterEvent(event);
    end
end






-- defer an event to be called on a next cycle. This is used to defer events that may cause taint if called during combat or during certain protected function calls.
local deferredEvents = {};

local function sanitizeDeferredEventArgs (...)
	local args = {...};
	for i = 1, 29 do
		if IsSecretValue(args[i]) then
			args[i] = "";
		else
			if type(args[i]) == "nil" then
				args[i] = "";
			end
		end
	end

	return args;
end

local function enqueueDeferredEvent(module, event, ...)
	-- queue the event
	dPrint("  +-- Deferring Event: "..event);
	table.insert(deferredEvents, {module = module, event = event, args = sanitizeDeferredEventArgs(...), time = _G.time()});
end

local function dequeueDeferredEvent ()
	if InChatMessagingLockdown() or #deferredEvents == 0 then
		return false;
	end

	local event = table.remove(deferredEvents, 1);
	if event then
		if string.match(event.event, "^CHAT_MSG") then
			local lineID = event.args[11];
			event.args[1] = _G.C_ChatInfo.GetChatLineText(lineID) or "";
			event.args[2] = _G.C_ChatInfo.GetChatLineSenderName(lineID) or "";
			event.args[12] = _G.C_ChatInfo.GetChatLineSenderGUID(lineID) or "";

			-- if Bnet, add BnetAccountId
			if event.event == "CHAT_MSG_BN_WHISPER_INFORM" then
				event.args[13] = GetBNGetFriendInfo(0) or 0;
			elseif event.event == "CHAT_MSG_BN_WHISPER" then
				event.args[13] = GetBNGetGameAccountInfoByKName(event.args[2]) or 0;
			end

			event.args[29] = event.time; -- add original event time as arg29 for modules to use if they want.
		end

		if event.module.enabled then
			dPrint("Processing Deferred Event: "..event.event);
			local handler = event.module[event.event];
			if type(handler) == "function" then
				dPrint("  +-- "..event.module.title..":"..event.event);
				handler(event.module, unpack(event.args));
			end
		end

		return true;
	end

	return false;
end

local deferredEventQueueProcessor = CreateFrame("Frame", "WIM_DeferredEventQueueProcessor");
deferredEventQueueProcessor:SetScript("OnUpdate", function(self)
	if #deferredEvents > 0 then
		if not dequeueDeferredEvent() then
			self:Hide();
			return;
		end

		return;
	end

	self:Hide();
end);

local deferredEventTime = _G.C_Timer.NewTicker(1, function ()
	if #deferredEvents > 0 then
		deferredEventQueueProcessor:Show();
	end
end);




-- create a new WIM module. Will return module object.
function CreateModule(moduleName, enableByDefault)
    if(type(moduleName) == "string") then
        modules[moduleName] = {
            title = moduleName,
            enabled = false,
            enableByDefault = enableByDefault or false,
            canDisable = true,
            resources = {
                lists = lists,
                windows = windows,
                env = env,
                constants = constants,
                libs = libs,
            },
            db = db,
            db_defaults = db_defaults,
            RegisterEvent = function(self, event) RegisterEvent(event); end,
            Enable = function() EnableModule(moduleName, true) end,
            Disable = function() EnableModule(moduleName, false) end,
            dPrint = function(self, t) dPrint(t); end,
            hasWidget = false,
            RegisterWidget = function(widgetName, createFunction) RegisterWidget(widgetName, createFunction, moduleName); end,
			DeferEvent = function(self, event, ...) enqueueDeferredEvent(self, event, ...); end
		}
        return modules[moduleName];
    else
        return nil;
    end
end

function EnableModule(moduleName, enabled)
    if(enabled == nil) then enabled = false; end
    local module = modules[moduleName];
    if(module) then
        if(module.canDisable == false and enabled == false) then
            dPrint("Module '"..moduleName.."' can not be disabled!");
            return;
        end
        if(db) then
            db.modules[moduleName] = WIM.db.modules[moduleName] or {};
            db.modules[moduleName].enabled = enabled;
        end
        if(enabled) then
            module.enabled = enabled;
            if(enabled and type(module.OnEnable) == "function") then
                module:OnEnable();
            elseif(not enabled and type(module.OnDisable) == "function") then
                module:OnDisable();
            end
            dPrint("Module '"..moduleName.."' Enabled");
        else
            if(module.hasWidget) then
                dPrint("Module '"..moduleName.."' will be disabled after restart.");
            else
                module.enabled = enabled;
                if(enabled and type(module.OnEnable) == "function") then
                    module:OnEnable();
                elseif(not enabled and type(module.OnDisable) == "function") then
                    module:OnDisable();
                end
                dPrint("Module '"..moduleName.."' Disabled");
            end
        end
    end
end

function CallModuleFunction(funName, ...)
    -- notify all enabled modules.
    dPrint("Calling Module Function: "..funName);
    for module, tData in pairs(WIM.modules) do
        local fun = tData[funName];
        if(type(fun) == "function" and tData.enabled) then
                dPrint(" +--"..module);
                fun(tData, ...);
        end
    end
end
--------------------------------------
--          Event Handlers          --
--------------------------------------

function WIM:EventHandler(event,...)
        -- depricated - here for compatibility only
end

-- This is WIM's core event controler.
function WIM:CoreEventHandler(event, ...)

    -- Core WIM Event Handlers.
    dPrint("Event '"..event.."' received.");

    local fun = WIM[event];
    if(type(fun) == "function") then
        dPrint("  +-- WIM:"..event);
        fun(WIM, ...);
    end

    -- Module Event Handlers
    if(db and db.enabled) then
        for module, tData in pairs(modules) do
            fun = tData[event];
            if(type(fun) == "function" and tData.enabled) then
                dPrint("  +-- "..module..":"..event);
                fun(modules[module], ...);
            end
        end
    end
end

function WIM:VARIABLES_LOADED()
    _G.WIM3_Data = _G.WIM3_Data or {};
    db = _G.WIM3_Data;
    _G.WIM3_Cache = _G.WIM3_Cache or {};
    env.cache = _G.WIM3_Cache;
    _G.WIM3_Filters = _G.WIM3_Filters or GetDefaultFilters();
    _G.WIM3_ChatFilters = _G.WIM3_ChatFilters or {};
    if(#_G.WIM3_Filters == 0) then
        _G.WIM3_Filters = GetDefaultFilters();
    end
    filters = _G.WIM3_Filters;
    chatFilters = _G.WIM3_ChatFilters;

    _G.WIM3_History = _G.WIM3_History or {};
    history = _G.WIM3_History;

    -- load some environment data.
    env.realm = _G.GetRealmName();
    env.character = _G.UnitName("player");

    -- inherrit any new default options which wheren't shown in previous releases.
    inherritTable(db_defaults, db);
    lists.gm = {};

    -- load previous state into memory
    curState = db.lastState;

    SetEnabled(db.enabled);
    initialize();
end

function WIM:FRIENDLIST_UPDATE()
    env.cache[env.realm][env.character].friendList = env.cache[env.realm][env.character].friendList or {};
    for key, d in pairs(env.cache[env.realm][env.character].friendList) do
		if(d == 1) then
	    	env.cache[env.realm][env.character].friendList[key] = nil;
		end
    end
    if _G.C_FriendList then
		for i=1, _G.C_FriendList.GetNumFriends() do
			local name = _G.C_FriendList.GetFriendInfoByIndex(i).name;
			if(name) then
				env.cache[env.realm][env.character].friendList[name] = 1; --[set place holder for quick lookup
			end
		end
    else
		for i=1, _G.GetNumFriends() do
			local name = _G.GetFriendInfo(i);
			if(name) then
				env.cache[env.realm][env.character].friendList[name] = 1; --[set place holder for quick lookup
			end
		end
	end
    lists.friends = env.cache[env.realm][env.character].friendList;
    dPrint("Friends list updated...");
end

local function safeName(user)
	return string.lower(user or "")
end

function WIM:BN_FRIEND_LIST_SIZE_CHANGED()
    env.cache[env.realm][env.character].friendList = env.cache[env.realm][env.character].friendList or {};
    for key, d in pairs(env.cache[env.realm][env.character].friendList) do
	if(d == 2) then
            env.cache[env.realm][env.character].friendList[key] = nil;
	end
    end
	for i=1, _G.BNGetNumFriends() do
	    local id, name = GetBNGetFriendInfo(i);
	    if(name) then
		env.cache[env.realm][env.character].friendList[name] = 2; --[set place holder for quick lookup
			if(windows.active.whisper[safeName(name)]) then
			    windows.active.whisper[safeName(name)]:SendWho();
			end
	    end
	end
    lists.friends = env.cache[env.realm][env.character].friendList;
    dPrint("RealID list updated...");
end
WIM.BN_FRIEND_INFO_CHANGED = WIM.BN_FRIEND_LIST_SIZE_CHANGED;


function WIM:GUILD_ROSTER_UPDATE()
	env.cache[env.realm][env.character].guildList = env.cache[env.realm][env.character].guildList or {};
        for key, _ in pairs(env.cache[env.realm][env.character].guildList) do
            env.cache[env.realm][env.character].guildList[key] = nil;
        end
	if(_G.IsInGuild()) then
		for i=1, _G.GetNumGuildMembers(true) do
			local name = _G.GetGuildRosterInfo(i);
			if(name) then
				name = Ambiguate(name, "none")
				env.cache[env.realm][env.character].guildList[name] = i; --[set place holder for quick lookup
			end
		end
	end
	lists.guild = env.cache[env.realm][env.character].guildList;
        dPrint("Guild list updated...");
end

function IsGM(name)
        if(name == nil or name == "") then
		return false;
	end

        -- Blizz gave us a new tool. Lets use it.
        if(_G.GMChatFrame_IsGM and _G.GMChatFrame_IsGM(name)) then
                lists.gm[name] = 1;
                return true;
        end

	if(lists.gm[name]) then
		return true;
	else
		return false;
	end
end

function IsInParty(user)
    for i=1, 4 do
        if(_G.GetUnitName("party"..i, true) == user) then
            return true;
        end
    end
    return false;
end

function IsInRaid(user)
    for i=1, _G.GetNumGroupMembers() do
        if(_G.GetUnitName("raid"..i, true) == user) then
            return true;
        end
    end
    return false;
end

function CompareVersion(v, withV)
    withV = withV or version;
    local M, m, r = string.match(v, "(%d+).(%d+).(%d+)");
    local cM, cm, cr = string.match(withV, "(%d+).(%d+).(%d+)");
    M, m = M*100000, m*1000;
    cM, cm = cM*100000, cm*1000;
    local this, that = cM+cm+cr, M+m+r;
    return that - this;
end

local talentOrder = {};
function TalentsToString(talents, class)
	--passed talents in format of "#/#/#";
        -- first check that all required information is passed.
	local t1, t2, t3 = string.match(talents or "", "(%d+)/(%d+)/(%d+)");
	if(not t1 or not t2 or not t3 or not class) then
                return talents;
        end

        -- next check if we even have information to show.
        if(talents == "0/0/0") then return L["None"]; end

        local classTbl = constants.classes[class];
	if(not classTbl) then
                return talents;
        end

        -- clear talentOrder
        for k, _ in pairs(talentOrder) do
                talentOrder[k] = nil;
        end

	--calculate which order the tabs should be in; in relation to spec.
	table.insert(talentOrder, t1.."1");
        table.insert(talentOrder, t2.."2");
        table.insert(talentOrder, t3.."3");
	table.sort(talentOrder);

	local fVal, f = string.match(_G.tostring(talentOrder[3]), "^(%d+)(%d)$");
        local sVal, s = string.match(_G.tostring(talentOrder[2]), "^(%d+)(%d)$");
        local tVal, t = string.match(_G.tostring(talentOrder[1]), "^(%d+)(%d)$");

	if(_G.tonumber(fVal)*.75 <= _G.tonumber(sVal)) then
		if(_G.tonumber(fVal)*.75 <= _G.tonumber(tVal)) then
			return L["Hybrid"]..": "..talents;
		else
			return classTbl.talent[_G.tonumber(f)].."/"..classTbl.talent[_G.tonumber(s)]..": "..talents;
		end
	else
		return classTbl.talent[_G.tonumber(f)]..": "..talents;
	end
end

function GetTalentSpec()
        local talents, tabs = "", _G.GetNumTalentTabs();
        for i=1, tabs do
                local name, _, _, _, pointsSpent = _G.GetTalentTabInfo(i);
                talents = i==tabs and talents..pointsSpent or talents..pointsSpent.."/";
        end
        return talents ~= "" and talents or "0/0/0";
end


-- 12.00.00 + Secret Tools
local _issecretvalue = _G.issecretvalue;
function IsSecretValue(...)
	if _issecretvalue then
		return _issecretvalue(...);
	else
		return false;
	end
end

local _hasanysecretvalues = _G.hasanysecretvalues;
function HasAnySecretValues(...)
	if _hasanysecretvalues then
		return _hasanysecretvalues(...);
	else
		return false;
	end
end

local _inchatmessaginglockdown = _G.C_ChatInfo and _G.C_ChatInfo.InChatMessagingLockdown;
function InChatMessagingLockdown()
	if _inchatmessaginglockdown then
		return _inchatmessaginglockdown();
	else
		return false;
	end
end



-- list of PreSendFilterText(text)
local preSendFilterTextFunctions = {};
function PreSendFilterText(text)
    for i=1, #preSendFilterTextFunctions do
	text = preSendFilterTextFunctions[i](text);
    end
    return text;
end

function RegisterPreSendFilterText(func)
    if(type(func) == "function") then
        table.insert(preSendFilterTextFunctions, func);
    end
end

--[[ Example usage
RegisterPreSendFilterText(
function(text)
    return "john";
end
);
]]

function NextTick(func)
	if(type(func) == "function") then
		if _G.C_Timer and _G.C_Timer.After then
			_G.C_Timer.After(0, func);
		else
			func();
		end
	end
end
