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
local tostring = tostring;
local Ambiguate = Ambiguate;

-- set name space
setfenv(1, WIM);

-- Core information
addonTocName = "WIM";
version = "3.18.0";
beta = false; -- flags current version as beta.
debug = false; -- turn debugging on and off. True whenever debugLevel >= 1.
debugLevel = 0; -- 0 off, 1 normal, 2 verbose event tracing (Sources/DebugTrace.lua).
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

-- import libraries. Checked before any event registration: the Libs
-- folder is not in the repository (the packager pulls it in through
-- .pkgmeta), so a plain source checkout used to die here with nothing
-- but "attempt to call a nil value" errors to explain it.
local SML = _G.LibStub and _G.LibStub:GetLibrary("LibSharedMedia-3.0", true);
local DropDownMenu = _G.LibStub and _G.LibStub:GetLibrary("LibDropDownMenu", true);
if(not SML or not DropDownMenu) then
    _G.DEFAULT_CHAT_FRAME:AddMessage("|cffff2020WIM could not load:|r the packaged libraries are missing. Install a packaged release; a plain source checkout does not include the Libs folder.");
    do return end;
end
libs.SML = SML;
libs.DropDownMenu = DropDownMenu;

-- create a frame to moderate events and frame updates.
    local workerFrame = CreateFrame("Frame", "WIM_workerFrame");
    workerFrame:SetScript("OnEvent", function(self, event, ...) WIM:CoreEventHandler(event, ...); end);

    -- some events we always want to listen to so data is ready upon WIM being enabled.
    workerFrame:RegisterEvent("VARIABLES_LOADED");
    workerFrame:RegisterEvent("ADDON_LOADED");

-- called when WIM is first loaded into memory but after variables are loaded.
local function initialize()
    --load cached information from the WIM3_Cache saved variable.
	env.cache[env.realm] = env.cache[env.realm] or {};
    env.cache[env.realm][env.character] = env.cache[env.realm][env.character] or {};
	lists.friends = env.cache[env.realm][env.character].friendList;
	lists.guild = env.cache[env.realm][env.character].guildList;

	if(type(lists.friends) ~= "table") then lists.friends = {}; end
	if(type(lists.guild) ~= "table") then lists.guild = {}; end

	workerFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	workerFrame:RegisterEvent("FRIENDLIST_UPDATE");
	workerFrame:RegisterEvent("IGNORELIST_UPDATE");
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
    RegisterSlashCommand("debug", function(args)
            -- "/wim debug" keeps its long-standing toggle behaviour;
            -- "/wim debug <0|1|2>" sets a level explicitly. The level is
            -- persisted, so capture survives the logout/login cycle that the
            -- interesting messages happen during.
            local level = _G.tonumber(args);
            if(not level) then
                level = (debugLevel or 0) > 0 and 0 or 1;
            end
            level = SetDebugLevel(level);

            local desc = (level == 0 and "OFF")
                      or (level == 1 and "ON (level 1, normal)")
                      or "ON (level 2, verbose event tracing)";
            _G.DEFAULT_CHAT_FRAME:AddMessage("WIM debug "..desc
                ..(level > 0 and " - captured to SavedVariablesPerCharacter (WIM3_DebugLog), written on logout or /reload." or "."));
        end, L["Set debugging level: /wim debug [0|1|2]. 2 adds verbose chat event tracing."]);
    RegisterSlashCommand("focusstreams", function()
            -- Diagnostic A/B switch. With this off WIM leaves community stream
            -- focusing entirely to the client, which lets the client's own
            -- focusing be compared against WIM's (see
            -- Channel:FocusCommunityStreams in Modules/ChatEngine.lua).
            local c = db and db.chat and db.chat.community;
            if(not c) then
                _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: community chat settings unavailable."]);
                return;
            end
            c.autoFocusStreams = not (c.autoFocusStreams ~= false);
            _G.DEFAULT_CHAT_FRAME:AddMessage(c.autoFocusStreams
                and L["WIM community stream auto-focus ON. Takes effect at next login."]
                or L["WIM community stream auto-focus OFF - the client may refuse sends to community channels. Takes effect at next login."]);
        end, L["Toggle whether WIM focuses community streams at login."]);
    RegisterSlashCommand("channelrepair", function()
            -- Opt-in. This is the only thing in WIM that mutates the user's chat
            -- window channel configuration, which is saved and survives logout,
            -- so it is never enabled without an explicit request.
            local c = db and db.chat and db.chat.community;
            if(not c) then
                _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: community chat settings unavailable."]);
                return;
            end
            c.repairChannelReAdd = not (c.repairChannelReAdd == true);
            if(c.repairChannelReAdd) then
                _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM channel re-add repair ON (experimental). On logins where the community stream is focused late, WIM removes and re-adds community channels to ChatFrame1 about 8s after login. If a re-add fails the channel must be restored from the chat settings UI."]);
                -- Run one now. The flag is read when the timer fires rather than
                -- when it is scheduled, so enabling mid-session could already
                -- trigger a run -- better to make that explicit than surprising,
                -- and it lets the call signature be probed on demand.
                if(TryCommunityChannelReAdd) then
                    _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: attempting a repair now (see /wim debug output)."]);
                    TryCommunityChannelReAdd();
                end
            else
                _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM channel re-add repair OFF. No further attempts this session."]);
            end
        end, L["Toggle the experimental community channel re-add repair (mutates chat window channels)."]);
    RegisterSlashCommand("debugclear", function()
            if(_G.WIM3_DebugLog) then
                _G.WIM3_DebugLog.lines = {};
            end
            _G.DEFAULT_CHAT_FRAME:AddMessage("WIM debug log cleared.");
        end, L["Clear the captured debug log."]);
    FRIENDLIST_UPDATE(); -- pretend event has been fired in order to get cache loaded.

	if (GetSelectedSkin().title ~= db.skin.selected) then
		LoadSkin(GetSelectedSkin().title, true);
	end

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
	-- if id is a table, refactor to used the first value (the expected id).
	if type(id) == "table" then id = id[1] end

	-- if unexpected value is passed, return nothing preventing possible errors.
	if type(id) ~= "number" or id < -2147483648 or id > 2147483647 then
		return
	end

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
ChatLineHasSecrets = {};

local function sanitizeDeferredEventArgs (...)
	local args = {...};
	for i = 1, 29 do
		if IsSecretValue(args[i]) then
			args[i] = "";

			if args[11] then
				ChatLineHasSecrets[args[11]] = true; -- mark which chatLines have secrets.
			end
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
			elseif event.event == "CHAT_MSG_BN_WHISPER" or event.event == "CHAT_MSG_BN_INLINE_TOAST_ALERT" then
				local bnInfo = GetBNGetGameAccountInfoByKName(event.args[2]);
				event.args[13] = (bnInfo and bnInfo[1]) or 0;
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

-- ---------------------------------------------------------------------------
-- History blob archive plumbing
--
-- See Sources/HistorySerializer.lua for why history is stored as strings in the
-- account-wide file. These helpers own the runtime side of it: tracking which
-- characters have unsaved changes, pulling a character out of the archive into
-- the live `history` tree, and writing everything back at logout.
-- ---------------------------------------------------------------------------

-- Dirty set, keyed by "realm\0character", each holding the set of conversation
-- names whose in-memory contents differ from the blob currently in the archive.
--
--     historyDirty["Moon Guard\0Bob"] = {
--         realm = "Moon Guard", character = "Bob",
--         convos = { ["Alice"] = true, ["Trade"] = true },
--         all = false,   -- true means "re-serialize every conversation"
--     }
--
-- Tracking at CONVERSATION granularity rather than character granularity is
-- what keeps logout cheap. Re-serializing an entire heavy character measures in
-- seconds; re-serializing the two conversations you actually talked in during a
-- session measures in milliseconds.
historyDirty = {};

-- Flat queue of {realm, character, convo, blob} still waiting to be rehydrated
-- by the staged background loader.
historyLoadQueue = {};

-- Flat queue of {realm, character, convo, tbl} of LEGACY (original native-table)
-- conversations still waiting to be serialized into the archive.
historyDrainQueue = {};

local function historyKey(realm, character)
    return (realm or "?").."\0"..(character or "?");
end

-- Flag history as changed so that logout re-serializes it.
--
-- `convo` is the conversation name that changed. Omitting it marks the whole
-- character dirty, which is the correct (if more expensive) thing to do when a
-- change isn't scoped to one conversation.
--
-- Called from Modules/History.lua on every append and every deletion.
function MarkHistoryDirty(realm, character, convo)
    if (not realm or not character) then
        realm, character = env.realm, env.character;
    end
    local key = historyKey(realm, character);
    local entry = historyDirty[key];
    if (not entry) then
        entry = { realm = realm, character = character, convos = {}, all = false };
        historyDirty[key] = entry;
    end
    if (convo == nil) then
        entry.all = true;
    else
        entry.convos[convo] = true;
    end
end

-- Returns true if the character's history is present in the live `history`
-- tree (either because it is the active character or because it has already
-- been rehydrated from the archive).
function IsHistoryCharacterLoaded(realm, character)
    return history and history[realm] and history[realm][character] ~= nil;
end

-- ---------------------------------------------------------------------------
-- History storage schema version.
--
-- This is a FORMAT version, deliberately decoupled from the addon version. It
-- increments only when the on-disk layout of the history file changes, so a run
-- of releases that don't touch storage all share one schema number. Comparing
-- addon versions instead would mean parsing version strings and treating every
-- release as a possible migration.
--
--   0 (or absent) -- original format: history is a tree of native Lua
--                    tables under WIM3_History. This is the format that trips
--                    Lua's 262,143-constant chunk limit and corrupts the file.
--   1             -- blob archive: history lives in WIM3_HistoryArchive with each
--                    conversation stored as a serialized string blob.
--
-- The version is stored in WIM3_HistorySchema, a saved variable alongside the
-- data it describes, so the two are always backed up and restored together.
--
-- Absent is defined as 0 rather than "unknown", which is what lets us tell
-- original-format data apart from data written by a future version.
-- ---------------------------------------------------------------------------
HISTORY_SCHEMA = 1;

-- The schema the data had when this session started, captured before any
-- conversion runs. Drives the one-shot upgrade notice.
historySchemaAtLogin = 0;

-- Stamp the history file as being in the current format. Called only when no
-- legacy data remains to convert.
function FinalizeHistorySchema()
    if (next(_G.WIM3_History) == nil and GetHistorySchema() < HISTORY_SCHEMA) then
        _G.WIM3_HistorySchema = HISTORY_SCHEMA;
        dPrint("History: storage format stamped as schema "..HISTORY_SCHEMA..".");
    end
end

function GetHistorySchema()
    local v = _G.WIM3_HistorySchema;
    if (type(v) ~= "number") then
        return 0;
    end
    return v;
end

-- Characters whose archive entry has been fully walked this session, keyed by
-- "realm\0character". Once a character is in here we never walk its archive
-- entry again, which is what stops a second call from re-adding conversations
-- the player deleted after the first one.
historyLoadedChars = {};

-- Pull one character out of the archive and splice it into the live tree.
-- Safe to call repeatedly.
--
-- NOTE: we deliberately do NOT key off history[realm][character] existing. The
-- staged background loader pre-creates that table for every archived character
-- so the dropdown is complete immediately, which means its presence says
-- nothing about whether the conversations inside it have been rehydrated yet.
function EnsureHistoryCharacterLoaded(realm, character)
    local key = (realm or "?").."\0"..(character or "?");
    if (historyLoadedChars[key]) then
        return true;
    end
    local entry = _G.WIM3_HistoryArchive
                  and _G.WIM3_HistoryArchive[realm]
                  and _G.WIM3_HistoryArchive[realm][character];
    if (not entry or type(entry.convos) ~= "table") then
        return IsHistoryCharacterLoaded(realm, character);
    end
    history[realm] = history[realm] or {};
    history[realm][character] = history[realm][character] or {};
    for convo, blob in pairs(entry.convos) do
        RehydrateHistoryConvo(realm, character, convo, blob);
    end
    historyLoadedChars[key] = true;
    return true;
end

-- Rehydrate a single conversation into the live tree. Split out from
-- EnsureHistoryCharacterLoaded so the staged background loader can do a few
-- conversations per frame instead of a whole character at once -- a heavy
-- character can take seconds to rebuild, which would be a visible freeze.
function RehydrateHistoryConvo(realm, character, convo, blob)
    local target = history[realm] and history[realm][character];
    if (not target or target[convo] ~= nil) then
        return false;   -- already present, don't clobber live data
    end
    -- If the player has changed this conversation THIS SESSION, the in-memory
    -- state is authoritative and the archived blob is stale. The important case
    -- is deletion: the conversation is absent from the live tree precisely
    -- because it was deleted, and rehydrating it would bring it back.
    local dirtyEntry = historyDirty[(realm or "?").."\0"..(character or "?")];
    if (dirtyEntry and (dirtyEntry.all or dirtyEntry.convos[convo])) then
        return false;
    end
    local tbl, err = DeserializeHistoryBlob(blob);
    if (not tbl) then
        -- One unreadable conversation must not take the character (or the rest
        -- of the archive) down with it. Report once, then skip it.
        local entry = _G.WIM3_HistoryArchive[realm]
                      and _G.WIM3_HistoryArchive[realm][character];
        if (entry and not entry.reportedFailure) then
            entry.reportedFailure = true;
            _G.DEFAULT_CHAT_FRAME:AddMessage(_G.format(
                "|cffff4040[WIM]|r Could not read archived history for %s on %s "
                .."(conversation %s: %s). Other conversations are unaffected, and "
                .."that character's own saved file will restore the archive next "
                .."time you log into them.",
                tostring(character), tostring(realm), tostring(convo), tostring(err)
            ));
        end
        return false;
    end
    target[convo] = tbl;
    return true;
end

-- Rehydrate every character that belongs to `realm`. Used by the History
-- Viewer's realm-wide view so it can aggregate across characters even if the
-- staged background loader hasn't reached them yet.
function EnsureHistoryRealmLoaded(realm)
    local chars = _G.WIM3_HistoryArchive and _G.WIM3_HistoryArchive[realm];
    if (type(chars) ~= "table") then
        return;
    end
    for character, _ in pairs(chars) do
        EnsureHistoryCharacterLoaded(realm, character);
    end
end

-- Rehydrate absolutely everything still pending. Used before operations that
-- must see the whole account, such as the Battle.net friend consolidation.
function EnsureAllHistoryLoaded()
    if (type(_G.WIM3_HistoryArchive) ~= "table") then
        return;
    end
    for realm, chars in pairs(_G.WIM3_HistoryArchive) do
        if (type(chars) == "table") then
            for character, _ in pairs(chars) do
                EnsureHistoryCharacterLoaded(realm, character);
            end
        end
    end
end

-- Write one character's live history table back into the archive as a blob.
function ArchiveHistoryCharacter(realm, character, dirtyEntry)
    local tbl = history and history[realm] and history[realm][character];
    if (type(tbl) ~= "table") then
        -- The character was marked dirty and then removed from the tree
        -- entirely (its last conversation was deleted). Drop the archive entry
        -- too, otherwise the deleted history would reappear on next login.
        if (_G.WIM3_HistoryArchive[realm]) then
            _G.WIM3_HistoryArchive[realm][character] = nil;
            if (next(_G.WIM3_HistoryArchive[realm]) == nil) then
                _G.WIM3_HistoryArchive[realm] = nil;
            end
        end
        return true;
    end
    local stamp = _G.time();

    if (next(tbl) == nil) then
        -- Nothing left for this character: drop the entry entirely rather than
        -- keeping empty blobs around.
        if (_G.WIM3_HistoryArchive[realm]) then
            _G.WIM3_HistoryArchive[realm][character] = nil;
            if (next(_G.WIM3_HistoryArchive[realm]) == nil) then
                _G.WIM3_HistoryArchive[realm] = nil;
            end
        end
        return true;
    end

    _G.WIM3_HistoryArchive[realm] = _G.WIM3_HistoryArchive[realm] or {};
    local entry = _G.WIM3_HistoryArchive[realm][character];
    if (type(entry) ~= "table" or type(entry.convos) ~= "table") then
        entry = { convos = {} };
        _G.WIM3_HistoryArchive[realm][character] = entry;
        -- No usable previous entry, so everything has to be written.
        dirtyEntry = nil;
    end

    -- Decide which conversations actually need re-serializing. Normally this is
    -- just the one or two you chatted in this session; a nil/`all` dirty entry
    -- means rewrite the lot.
    local rewriteAll = (dirtyEntry == nil) or dirtyEntry.all;
    if (rewriteAll) then
        for convo, convoTbl in pairs(tbl) do
            if (type(convoTbl) == "table") then
                entry.convos[convo] = SerializeHistoryTable(convoTbl);
            end
        end
        -- Drop archived conversations that no longer exist in memory.
        for convo in pairs(entry.convos) do
            if (type(tbl[convo]) ~= "table") then
                entry.convos[convo] = nil;
            end
        end
    else
        for convo in pairs(dirtyEntry.convos) do
            local convoTbl = tbl[convo];
            if (type(convoTbl) == "table" and next(convoTbl) ~= nil) then
                entry.convos[convo] = SerializeHistoryTable(convoTbl);
            else
                -- Conversation was deleted outright.
                entry.convos[convo] = nil;
            end
        end
    end

    local convoCount, recordCount = SummarizeHistoryTable(tbl);
    entry.updated = stamp;
    entry.convoCount = convoCount;
    entry.records = recordCount;
    entry.reportedFailure = nil;
    return true;
end

-- Logout hook. The active character is always re-archived when it has new
-- messages; other characters are only re-archived if something was deleted
-- from them this session (their own per-character file cannot be updated from
-- here, which is exactly why the archive carries a timestamp).
function SerializeDirtyHistory()
    if (type(_G.WIM3_HistoryArchive) ~= "table") then
        return;
    end
    for _, who in pairs(historyDirty) do
        ArchiveHistoryCharacter(who.realm, who.character, who);
    end
    historyDirty = {};
end

function WIM:VARIABLES_LOADED()
    -- Debug capture. Restored before anything else so that the login-time
    -- dPrint calls -- module OnEnable, PLAYER_ENTERING_WORLD, the first chat
    -- message -- are recorded on a session where debugging was left on, instead
    -- of being lost before a slash command could be typed. See WIM.dPrint in
    -- Sources/ToolBox.lua for why this is per-character.
    _G.WIM3_DebugLog = _G.WIM3_DebugLog or {};
    _G.WIM3_DebugLog.lines = _G.WIM3_DebugLog.lines or {};
    SetDebugLevel(_G.WIM3_DebugLog.level or 0);

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

    -- Bug fix (issue #251):
    --   Once WIM.lua approaches ~25MB the WoW client fails to parse it on the
    --   next login with "constant table overflow", resetting the ENTIRE file --
    --   settings and history together. The limit is Lua 5.1's cap on unique
    --   constants per chunk (MAXARG_Bx == 2^18 - 1 == 262,143), and WoW reads
    --   each SavedVariables file as a single chunk.
    --
    --   Moving history into its own file does not fix this: any one file is
    --   bounded by the same ceiling, and a single character with enough history
    --   can exhaust it alone. That was tried and #251 stayed open.
    --
    --   Splitting the live history table across per-character SavedVariables
    --   files does give each character its own chunk and its own constant
    --   budget, but WoW only ever loads the file belonging to the character you
    --   are logged in as, so every other character's history becomes invisible.
    --   That is a dead end and is not used here.
    --
    --   The fix keeps history ACCOUNT-WIDE in WIM3_HistoryArchive, storing each
    --   conversation as a serialized string. The constant limit counts the
    --   NUMBER of constants, not their size, so one conversation costs one
    --   constant no matter how long it is, and loadstring() gives each blob
    --   its own chunk (and its own budget) when it is rehydrated. Every
    --   character is therefore readable from everywhere.
    --
    --   There is no per-character storage of any kind: it made cross-character
    --   history impossible and has been removed entirely.
    --   History shares WIM.lua with the addon's settings, as it always has
    --   upstream. 3.16.13 moved it into a companion sub-addon so it would get
    --   its own SavedVariables file and its own constant budget; that was only
    --   ever a partial mitigation -- a single character with enough history
    --   still overflowed the separate file, and #251 stayed open. Serializing
    --   conversations is what actually fixes it, and it works regardless of
    --   which file the data lives in, so the extra addon has been dropped.
    --
    --   For scale: an account with 5,000 conversations spends roughly 12,000
    --   constants on history. Settings are a few thousand more. The ceiling is
    --   262,143.

    -- load some environment data EARLIER than before; the history assembly
    -- below needs env.realm and env.character.
    env.realm = _G.GetRealmName();
    env.character = _G.UnitName("player");

    -- History storage. WIM3_History is the legacy holding pen: earlier versions
    -- wrote the whole history tree here as native Lua tables, and it is
    -- drained into the archive in the background further down. WIM3_HistoryArchive
    -- is the current format -- one serialized string per conversation.
    -- WIM3_HistorySchema is deliberately NOT defaulted; absent means 0.
    _G.WIM3_History = _G.WIM3_History or {};
    _G.WIM3_HistoryArchive = _G.WIM3_HistoryArchive or {};

    -- Snapshot the on-disk schema BEFORE we convert anything, so the rest of
    -- this function can tell what state the data arrived in.
    historySchemaAtLogin = GetHistorySchema();
    if (historySchemaAtLogin > HISTORY_SCHEMA) then
        -- Data written by a NEWER version of WIM than the one running. We can
        -- still read what we understand, but we must not claim the file is ours
        -- to rewrite silently: a downgrade that quietly drops fields it doesn't
        -- recognise is how history gets lost.
        _G.DEFAULT_CHAT_FRAME:AddMessage(_G.format(
            "|cffff4040[WIM]|r Your saved history was written by a newer version "
            .."of WIM (storage format %d, this version understands %d). Some of "
            .."it may not be readable, and saving may discard what this version "
            .."does not recognise. Update WIM, or restore a backup.",
            historySchemaAtLogin, HISTORY_SCHEMA
        ));
    end

    -- `history` is the unified in-memory tree that the whole addon reads and
    -- writes through: history[realm][character][convoName][records...].
    --
    -- IMPORTANT (changed in the blob-archive rework): `history` is now a plain
    -- RUNTIME table, NOT a saved variable. Previously it aliased
    -- _G.WIM3_History directly, which meant everything the History Viewer had
    -- in memory got serialized back into the account-wide file as native Lua
    -- tables -- the exact thing that trips the 262,143-constant chunk limit.
    --
    -- Now the tree is assembled at login by rehydrating blobs out of
    -- _G.WIM3_HistoryArchive -- every character the same way, including the one
    -- you are logged into -- and thrown away at logout. Persistence back to the
    -- archive happens explicitly, blob by blob, in SerializeDirtyHistory().
    history = {};

    -- ---------------------------------------------------------------------
    -- Load the ACTIVE character.
    --
    -- There is nothing special about the character you happen to be logged into
    -- any more: its history comes out of the account-wide archive exactly like
    -- every other character's. Writes from recordWhisper / recordChannelChat go
    -- into this table via history[realm][character], are flagged with
    -- MarkHistoryDirty, and are serialized back into the archive at logout.
    --
    -- We create the table up front (rather than leaving it to
    -- getPlayerHistoryTable's lazy path) so that a brand-new character with no
    -- history still appears in the History Viewer's character list.
    -- ---------------------------------------------------------------------
    history[env.realm] = history[env.realm] or {};
    history[env.realm][env.character] = history[env.realm][env.character] or {};
    EnsureHistoryCharacterLoaded(env.realm, env.character);

    -- ---------------------------------------------------------------------
    -- Drain LEGACY per-account history (original native-table format) into the
    -- blob archive. This is what converts an upgrading user's entire account
    -- in one login.
    --
    -- Three properties the drain guarantees:
    --
    --  * MERGE-AWARE. If the archive already has a conversation, the archive
    --    wins (it is newer -- written by a session where that character was
    --    active or edited) and the legacy copy is dropped. If the archive
    --    lacks it, the legacy copy is converted. A pre-existing archive entry
    --    no longer causes the whole character's legacy data to be discarded
    --    unexamined.
    --
    --  * STAGED. Serialization is the expensive half (a 20MB account measures
    --    in seconds), so it happens on the shared budgeted loader below, not
    --    inside VARIABLES_LOADED. The SPLICE half is free -- legacy tables are
    --    moved into the live `history` tree by reference right here -- so the
    --    History Viewer is complete instantly even while conversion runs.
    --
    --  * RESUMABLE. A legacy conversation is removed from WIM3_History only
    --    AFTER its blob lands in the archive (both happen in the same frame,
    --    so there is no window where it exists in neither). Logging out
    --    mid-drain leaves the unconverted remainder in WIM3_History, which is
    --    still a declared SavedVariable precisely so that it persists; the
    --    next login re-splices and re-queues it.
    -- ---------------------------------------------------------------------
    historyDrainQueue = {};
    local drainChars = {};
    for realm, chars in pairs(_G.WIM3_History) do
        if (type(chars) == "table") then
            for character, convos in pairs(chars) do
                if (type(convos) == "table") then
                    local archEntry = _G.WIM3_HistoryArchive[realm]
                                      and _G.WIM3_HistoryArchive[realm][character];
                    local archConvos = archEntry and archEntry.convos;
                    for convo, convoTbl in pairs(convos) do
                        if (type(convoTbl) == "table") then
                            if (archConvos and archConvos[convo] ~= nil) then
                                -- Archive already has this conversation; it is
                                -- authoritative. Drop the legacy copy now.
                                convos[convo] = nil;
                            else
                                -- Splice the native table into the live tree
                                -- (unless something newer is already there),
                                -- and queue the serialize work.
                                history[realm] = history[realm] or {};
                                history[realm][character] = history[realm][character] or {};
                                if (history[realm][character][convo] == nil) then
                                    history[realm][character][convo] = convoTbl;
                                end
                                table.insert(historyDrainQueue, {
                                    realm = realm, character = character,
                                    convo = convo, tbl = convoTbl,
                                });
                                drainChars[realm.."\0"..character] = true;
                            end
                        end
                    end
                    -- Clean up entries emptied by the archive-wins branch.
                    if (next(convos) == nil) then
                        chars[character] = nil;
                    end
                end
            end
            if (next(chars) == nil) then
                _G.WIM3_History[realm] = nil;
            end
        end
    end
    local drainCharCount = 0;
    for _ in pairs(drainChars) do drainCharCount = drainCharCount + 1; end
    if (drainCharCount > 0) then
        _G.DEFAULT_CHAT_FRAME:AddMessage(_G.format(
            "|cff69ccf0[WIM]|r Converting history for %d character|4:s; into the "
            .."account-wide archive in the background. Everything is already "
            .."viewable; conversion finishes in a few seconds.",
            drainCharCount
        ));
    end

    -- Processes one drain item: serialize the conversation into the archive,
    -- then (and only then) remove it from the legacy tree.
    local function processDrainItem(item)
        -- If the user deleted this conversation from the History Viewer while
        -- it was still waiting in the queue, the live tree no longer maps this
        -- convo to our table. Serializing the stale reference would resurrect
        -- deleted history, so skip the archive write -- but still fall through
        -- to the legacy-tree removal below, which is what makes the deletion
        -- permanent.
        local live = history[item.realm] and history[item.realm][item.character];
        local deleted = (not live) or (live[item.convo] ~= item.tbl);
        if (not deleted) then
        _G.WIM3_HistoryArchive[item.realm] = _G.WIM3_HistoryArchive[item.realm] or {};
        local entry = _G.WIM3_HistoryArchive[item.realm][item.character];
        if (type(entry) ~= "table" or type(entry.convos) ~= "table") then
            entry = { convos = {} };
            _G.WIM3_HistoryArchive[item.realm][item.character] = entry;
        end
        entry.convos[item.convo] = SerializeHistoryTable(item.tbl);
        entry.updated = _G.time();
        local liveTbl = history[item.realm] and history[item.realm][item.character];
        if (liveTbl) then
            entry.convoCount, entry.records = SummarizeHistoryTable(liveTbl);
        end
        end -- not deleted
        -- Safe to forget the legacy copy now (or, in the deleted case, this is
        -- what makes the deletion stick).
        local lr = _G.WIM3_History[item.realm];
        if (lr and lr[item.character]) then
            lr[item.character][item.convo] = nil;
            if (next(lr[item.character]) == nil) then
                lr[item.character] = nil;
                if (next(lr) == nil) then
                    _G.WIM3_History[item.realm] = nil;
                end
            end
        end
    end

    -- ---------------------------------------------------------------------
    -- Rehydrate every OTHER character from the archive.
    --
    -- This is done EAGERLY (all characters, not on demand) so the History
    -- Viewer's realm and character dropdowns are complete and instant. It is
    -- however STAGED across frames rather than done in one blocking loop: a
    -- large account can hold tens of megabytes of blobs, and compiling all of
    -- them inside VARIABLES_LOADED would freeze the client on login.
    --
    -- Anything that needs a specific character before the queue reaches it can
    -- call EnsureHistoryCharacterLoaded(realm, character) to jump the queue.
    -- ---------------------------------------------------------------------
    historyLoadQueue = {};
    for realm, chars in pairs(_G.WIM3_HistoryArchive) do
        if (type(chars) == "table") then
            for character, entry in pairs(chars) do
                local isActive = (realm == env.realm and character == env.character);
                if (not isActive and type(entry) == "table"
                    and type(entry.convos) == "table")
                then
                    history[realm] = history[realm] or {};
                    history[realm][character] = history[realm][character] or {};
                    for convo, blob in pairs(entry.convos) do
                        table.insert(historyLoadQueue, {
                            realm = realm, character = character,
                            convo = convo, blob = blob,
                        });
                    end
                end
            end
        end
    end

    if (#historyDrainQueue == 0) then
        -- Nothing legacy to convert, so the file is already in the current
        -- format (this covers both an up-to-date install and a fresh one).
        FinalizeHistorySchema();
    end

    if (#historyDrainQueue > 0 or #historyLoadQueue > 0) then
        dPrint("History: "..#historyDrainQueue.." conversations to convert, "
               ..#historyLoadQueue.." to rehydrate.");
        local loader = _G.CreateFrame("Frame");
        -- Budget in seconds of work per frame. Both queues are eager (we want
        -- the viewer complete and the conversion finished without the user
        -- asking), but neither may cost a visible stutter, so we do as much as
        -- fits in the budget and then yield back to the client. Drain items
        -- can individually exceed the budget (one big conversation must be
        -- serialized atomically); we accept the occasional long frame rather
        -- than splitting a conversation across frames.
        local BUDGET = 0.008;
        loader:SetScript("OnUpdate", function(self)
            local deadline = _G.debugprofilestop and (_G.debugprofilestop() + BUDGET * 1000);
            local processed = 0;
            while (true) do
                -- Drain first: converting legacy data is the only work that,
                -- if interrupted, has to be redone next login.
                local item = table.remove(historyDrainQueue, 1);
                if (item) then
                    processDrainItem(item);
                else
                    item = table.remove(historyLoadQueue, 1);
                    if (not item) then
                        self:SetScript("OnUpdate", nil);
                        self:Hide();
                        -- Both queues are empty, so every legacy conversation
                        -- has been converted. Only NOW is it true that the file
                        -- is in the new format, so only now do we stamp it.
                        -- Logging out part-way through leaves the stamp at its
                        -- old value and the unconverted remainder in
                        -- WIM3_History, and the next login resumes.
                        FinalizeHistorySchema();
                        dPrint("History: background conversion/rehydration complete.");
                        return;
                    end
                    RehydrateHistoryConvo(item.realm, item.character, item.convo, item.blob);
                end
                processed = processed + 1;
                if (deadline) then
                    if (_G.debugprofilestop() >= deadline) then return; end
                elseif (processed >= 10) then
                    -- No high-resolution timer available; fall back to a fixed
                    -- number of items per frame.
                    return;
                end
            end
        end);
    end

    -- One-shot informational notice the first time we run after converting
    -- history to the blob-archive format.
    if (historySchemaAtLogin < HISTORY_SCHEMA) then
        _G.DEFAULT_CHAT_FRAME:AddMessage(
            "|cff69ccf0[WIM]|r WIM history is now kept in an "
            .."account-wide archive that stores each conversation as a single "
            .."string, so it can no longer trip Lua's constant-table limit. "
            .."Existing history has been preserved and is being converted in "
            .."the background."
        );
    end

    -- On logout, write the active character (and any other character whose
    -- history was edited this session) back into the account-wide archive as
    -- blobs. `history` itself is a runtime table and is simply discarded.
    if (not WIM._historyArchiveHooked) then
        WIM._historyArchiveHooked = true;
        local archiveFrame = _G.CreateFrame("Frame");
        archiveFrame:RegisterEvent("PLAYER_LOGOUT");
        archiveFrame:SetScript("OnEvent", function()
            SerializeDirtyHistory();
        end);
    end

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
