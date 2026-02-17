-- File: WhisperEngine.lua
-- Author: John Langone (Pazza - Bronzebeard)
-- Description: This module handles whisper behaviors as well as their respective window actions.

--[[
    Extends Modules by adding:
        Module:PostEvent_Whisper(args[...])
        Module:PostEvent_WhisperInform(args[...])
]]


-- imports
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local hooksecurefunc = hooksecurefunc;
local table = table;
local pairs = pairs;
local strupper = strupper;
local gsub = gsub;
local strlen = strlen;
local strsub = strsub;
local string = string;
local IsShiftKeyDown = IsShiftKeyDown;
local select = select;
local unpack = unpack;
local math = math;
local time = time;
local playerRealm = GetRealmName();
local GetPlayerInfoByGUID = GetPlayerInfoByGUID;
local FlashClientIcon = FlashClientIcon;
local ChatFrameUtil = ChatFrameUtil;

-- set name space
setfenv(1, WIM);

-- create WIM Module
local WhisperEngine = CreateModule("WhisperEngine", true);

-- declare default settings for whispers.
-- if new global env wasn't set to WIM's namespace, then your module would call as follows:
--      WhisperEngine.db_defaults... or WIM.db_defaults...
db_defaults.pop_rules.whisper = {
        --pop-up rule sets based off of your location
        resting = {
            onSend = true,
            onReceive = true,
            supress = true,
            autofocus = true,
            keepfocus = true,
        },
        combat = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        pvp = {
            onSend = true,
            onReceive = true,
            supress = true,
            autofocus = false,
            keepfocus = false,
        },
        arena = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        party = {
            onSend = true,
            onReceive = true,
            supress = true,
            autofocus = false,
            keepfocus = false,
        },
        raid = {
            onSend = true,
            onReceive = true,
            supress = true,
            autofocus = false,
            keepfocus = false,
        },
        other = {
            onSend = true,
            onReceive = true,
            supress = true,
            autofocus = false,
            keepfocus = false,
        },
        alwaysOther = false,
        intercept = true,
		obeyAutoFocusRules = false,
}

db_defaults.displayColors.wispIn = {
	r=0.5607843137254902,
	g=0.03137254901960784,
	b=0.7607843137254902
    }
db_defaults.displayColors.wispOut = {
        r=1,
	g=0.07843137254901961,
	b=0.9882352941176471
    }
db_defaults.displayColors.BNwispIn = {
	r=0,
	g=0.4862745098039216,
	b=0.6549019607843137,
    }
db_defaults.displayColors.BNwispOut = {
        r=0.1725490196078431,
	g=0.6352941176470588,
	b=1,
    }

local Windows = windows.active.whisper;

local WhisperQueue_Bowl = {}; -- used to recycle tables for queue
local WhisperQueue = {}; -- active event queue
local WhisperQueue_Index = {}; -- a quick reference to an active index

local CF_MessageEventHandler_orig; -- used for a hook of the chat frame. Messaage filter handlers aren't sufficient.

local addToTableUnique = addToTableUnique;
local removeFromTable = removeFromTable;

local recentSent = {};
local maxRecent = 10;

local alertPushed = false;

local function updateMinimapAlerts()
    local count = 0;
    for _, win in pairs(Windows) do
        if(not win:IsVisible()) then
            count = count + (win.unreadCount or 0);
        end
    end
    if(count == 0 and alertPushed) then
        alertPushed = false;
        MinimapPopAlert(L["Whispers"]);
    elseif(count > 0) then
        alertPushed = true;
        local color = db.displayColors.wispIn;
        MinimapPushAlert(L["Whispers"], RGBPercentToHex(color.r, color.g, color.b), count);
--        DisplayTutorial(L["Whisper Received!"], L["You received a whisper which was hidden due to your current activity. You can change how whispers behave in WIM's options by typing"].." |cff69ccf0/wim|r");
    end
end

local CHAT_EVENTS = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_ALERT"
};

function WhisperEngine:OnEnableWIM()
	for i = 1, #CHAT_EVENTS do
		WhisperEngine:RegisterEvent(CHAT_EVENTS[i]);
	end
end

function WhisperEngine:OnEnable ()
	for i = 1, #CHAT_EVENTS do
		if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
			ChatFrameUtil.AddMessageEventFilter(CHAT_EVENTS[i], WhisperEngine.ChatMessageEventFilter);
		else
			_G.ChatFrame_AddMessageEventFilter(CHAT_EVENTS[i], WhisperEngine.ChatMessageEventFilter);
		end
	end

	-- check if whisperMode is set to inline, if not, display a warning in the options.
	if _G.GetCVar and _G.GetCVar("whisperMode") ~= "inline" and db.whisperModeChecked ~= true then
		_G.StaticPopupDialogs["WIM_WHISPER_MODE"] = {
			preferredIndex = _G.STATICPOPUP_NUMDIALOGS,
			text = "WIM: "..L["It is recommended for whispers to be set to in-line in order to handle their behavior properly."],
			button1 = L["Set whispers to In-line"],
			button2 = _G.LATER,
			OnAccept = function()
				_G.SetCVar("whisperMode", "inline");
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1
		};
		_G.StaticPopup_Show ("WIM_WHISPER_MODE");
		db.whisperModeChecked = true;
	end
end

function WhisperEngine:OnDisable()
	for i = 1, #CHAT_EVENTS do
		if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
			ChatFrameUtil.RemoveMessageEventFilter(CHAT_EVENTS[i], WhisperEngine.ChatMessageEventFilter);
		else
			_G.ChatFrame_RemoveMessageEventFilter(CHAT_EVENTS[i], WhisperEngine.ChatMessageEventFilter);
		end
	end
end

local function safeName(user)
	-- nil check. For some reason, events get modified by other addons and return nil for user.
	if _G.type(user) ~= "string" or user == "" then
        return ""
    end

	-- check if cross realm or if realm is included and the same as player, then strip realm
	if string.find(user or "", "-") then
		local player, realm = user:match("^(.-)-(.-)$");
		if string.lower(realm) == string.lower(env.realm) then
			user = player;
		end
	end

	return string.lower(user or "");
end

local function findWhisperWindowByBNetID(bnID)
	for _, win in pairs(Windows) do
		if(win.isBN and win.bn.id == bnID) then
			return win;
		end
	end
	return nil;
end

local function getWhisperWindowByUser(user, isBN, bnID, fromEvent)
	if isBN then
		local _;
		local bnWin = findWhisperWindowByBNetID(bnID);
		local _user = user;

		_, user = GetBNGetFriendInfoByID(bnID) -- fix window handler when using the chat hyperlink

		user = user and user ~= "" and user or _user;

		-- if window already exists for bnID but name has changed, update it.
		if (bnWin and safeName(bnWin.theUser) ~= safeName(user)) then
			-- swap the indexed name to the new name
			Windows[safeName(user)] = bnWin;
			Windows[safeName(bnWin.theUser)] = nil;

			bnWin:Rename(user);

			return bnWin;
		end
	else
		user = string.gsub(user," ","") -- Drii: WoW build15050 whisper bug for x-realm server with space
	    user = fromEvent and user or FormatUserName(user);
	end

    if(not user or user == "") then
        -- if invalid user, then return nil;
        return nil;
    end

    local obj = Windows[safeName(user)];
    if(obj and obj.type == "whisper") then
        -- if the whisper window exists, return the object
		-- update name if from event
		obj.user = user
		obj.theUser = user
        return obj;
    else
        -- otherwise, create a new one.
        Windows[safeName(user)] = CreateWhisperWindow(user, function(win)
			win.isBN = isBN;
			win.bn = win.bn or {};
			if(db.whoLookups or lists.gm[safeName(user)] or win.isBN) then
				win:SendWho(); -- send who request
			end
			win.online = true;
		end);
		return Windows[safeName(user)], true;
    end
end

local function windowDestroyed(self)
    if(IsShiftKeyDown() or self.forceShift) then
        local user = self:GetParent().theUser;
        Windows[safeName(user)].online = nil;
        Windows[safeName(user)].msgSent = nil;
	for k in pairs(Windows[safeName(user)].bn) do
		Windows[safeName(user)].bn[k] = nil;
	end
	Windows[safeName(user)].isBN = nil;
        Windows[safeName(user)] = nil;
    end
end

function WhisperEngine:OnWindowDestroyed(win)
    if(win.type == "whisper") then
        local user = win.theUser;
        Windows[safeName(user)] = nil;
    end
end


function WhisperEngine:OnWindowShow(win)
    updateMinimapAlerts();
end

local splitMessage, splitMessageLinks = {}, {};
function SendSplitMessage(PRIORITY, HEADER, theMsg, CHANNEL, EXTRA, to)
	-- ignore completely empty messages
    if _G.type(theMsg) ~= "string" or theMsg == "" then
        return
    end

    -- for whisper-style channels we *must* have a target
    if (CHANNEL == "WHISPER" or CHANNEL == "BN_WHISPER")
       and (_G.type(to) ~= "string" or to == "") then
        -- no valid target, don't try to send or open windows
        return
    end

    -- determine isBNET
    local isBN, messageLimit = false, 255;
    if(Windows[safeName(to)] and Windows[safeName(to)].isBN) then
        isBN = true;
        messageLimit = 800;
    end
	-- seperate escape sequences when chained without spaces
	theMsg = string.gsub(theMsg, "|r|c", "|r |c");
	theMsg = string.gsub(theMsg, "|t|T", "|t |T");
	theMsg = string.gsub(theMsg, "|h|H", "|h |H");

	-- parse out links as to not split them incorrectly.
	theMsg, results = string.gsub(theMsg, "(|H[^|]+|h.-|h|r)", function(theLink)
		table.insert(splitMessageLinks, theLink);
		return "\001\002"..paddString(#splitMessageLinks, "0", string.len(theLink)-4).."\003\004";
	end);

	-- split up each word.
	SplitToTable(theMsg, "%s", splitMessage);

	--reconstruct message into chunks of no more than 255 characters.
	local chunk = "";
	for i=1, #splitMessage + 1 do
		if(splitMessage[i] and string.len(chunk) + string.len(splitMessage[i]) < messageLimit) then
			chunk = chunk..splitMessage[i].." ";
		else
			-- reinsert links of necessary
			chunk = string.gsub(chunk, "\001\002%d+\003\004", function(link)
				local index = _G.tonumber(string.match(link, "(%d+)"));
				return splitMessageLinks[index] or link;
			end);

			if(isBN) then
				(_G.C_BattleNet and _G.C_BattleNet.SendWhisper or _G.BNSendWhisper)(Windows[safeName(to)].bn.id, chunk);
			else
                (_G.C_ChatInfo and _G.C_ChatInfo.SendChatMessage or _G.SendChatMessage)(chunk, CHANNEL, EXTRA, to)
			end
			chunk = (splitMessage[i] or "").." ";
		end
	end

	-- clean up
	for k, _ in pairs(splitMessage) do
		splitMessage[k] = nil;
	end
	for k, _ in pairs(splitMessageLinks) do
		splitMessageLinks[k] = nil;
	end
end


RegisterWidgetTrigger("msg_box", "whisper", "OnEnterPressed", function(self)
        local obj = self:GetParent();
        local msg = PreSendFilterText(self:GetText());

		-- do not send if in chat messaging lockdown (12.0.0+)
		if InChatMessagingLockdown() then
			return;
		end

		if(msg ~= "") then
            Windows[safeName(obj.theUser)].msgSent = true;
            SendSplitMessage("ALERT", "WIM", msg, "WHISPER", nil, obj.theUser);
        end

        self:SetText("");
    end);

--------------------------------------
--		  Tell & Told Targets       --
--------------------------------------
local lastTellTarget = nil;
local lastToldTarget = nil;

local function setLastTellTarget(name, chatType, ...)
	if (lastTellTarget ~= nil) then
		if lastTellTarget[1] == name and lastTellTarget[2] == chatType then
			return;
		end
	end

	lastTellTarget = { name, chatType, ... };
end

local function setLastToldTarget(name, chatType, ...)
	if (lastToldTarget ~= nil) then
		if lastToldTarget[1] == name and lastToldTarget[2] == chatType then
			return;
		end
	end

	lastToldTarget = { name, chatType, ... };
end

function GetLastWhisperWindow (sent)
	local target, chatType, extra = unpack(sent and lastToldTarget or lastTellTarget or {});
	if target and chatType and (chatType == "WHISPER" or chatType == "BN_WHISPER") then
		local win = getWhisperWindowByUser(target, chatType:find("BN_"), extra);
		if win then
			win.widgets.msg_box.setText = 1;
			win:Pop(true); -- force popup
			win.widgets.msg_box:SetFocus();
		end
		return win;
	end
	return nil;
end

--------------------------------------
--          Event Handlers          --
--------------------------------------

local CMS_PATTERNS = {
	PLAYER_NOT_FOUND 	= _G.ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s", "(.+)"),
	CHAT_IGNORED 		= _G.CHAT_IGNORED:gsub("%%s", "(.+)"),
	FRIEND_ONLINE 		= _G.ERR_FRIEND_ONLINE_SS:gsub("%[", "%%["):gsub("%]", "%%]"):gsub("%%s", "(.+)"),
	FRIEND_OFFLINE 		= _G.ERR_FRIEND_OFFLINE_S:gsub("%%s", "(.+)")
};

function WhisperEngine.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	-- Process all events except for CHAT_MSG_SYSTEM
	if (event ~= "CHAT_MSG_SYSTEM") then
		local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

		if (not frame._isWIM and not ignore and not block) then
			-- execute appropriate supression rules
			local curState = curState;
			curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
			if(WIM.db.pop_rules.whisper[curState].supress) then
				return true
			end
		elseif (frame._isWIM and ignore or block) then
			return true
		end

	-- Processes CHAT_MSG_SYSTEM events
	elseif (event == "CHAT_MSG_SYSTEM") then
		local msg = ...;

		local curState = db.pop_rules.whisper.alwaysOther and "other" or curState;

		for check, pattern in pairs(CMS_PATTERNS) do
			local user = FormatUserName(string.match(msg, pattern));
			if (user) then
				local win = Windows[safeName(user)];

				if (win) then
					-- error message
					if 'PLAYER_NOT_FOUND' == check or 'CHAT_IGNORED' == check then
						if (not frame._isWIM) then
							if(win:IsShown() and db.pop_rules.whisper[curState].supress or not win.msgSent) then
								return true;
							end
						else
							if win.online then
								win:AddMessage(msg, db.displayColors.errorMsg.r, db.displayColors.errorMsg.g, db.displayColors.errorMsg.b);
								win.online = false;
							end
						end

					-- system message
					elseif 'FRIEND_ONLINE' == check or 'FRIEND_OFFLINE' == check then
						if (not frame._isWIM) then
							if(win:IsShown() and db.pop_rules.whisper[curState].supress) then
								return true;
							end
						else
							if 'FRIEND_ONLINE' == check then
								msg = user.." ".._G.BN_TOAST_ONLINE
								win.online = true;
							else
								msg = user.." ".._G.BN_TOAST_OFFLINE
								win.online = false;
							end
							win:AddMessage(msg, db.displayColors.sysMsg.r, db.displayColors.sysMsg.g, db.displayColors.sysMsg.b);
						end
					end
				end
				-- no need to check remaining patterns
				break;
			end
		end
	end

	return false
end

-- compatibility function for processing message event filters
local function processMessageEventFilters(win, event, ...)
	local frame = win;

	-- if win is a WIM window, get its chat display frame
	if win and win.widgets and win.widgets.chat_display then
		-- ensure the chat display frame is the correct one
		frame = win.widgets.chat_display
	end
	-- if ChatFrameUtil is available, use its method for processing message event filters
	if (ChatFrameUtil and ChatFrameUtil.ProcessMessageEventFilters) then
		return ChatFrameUtil.ProcessMessageEventFilters(frame, event, ...);
	end

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;
	local chatFilters = _G.ChatFrame_GetMessageEventFilters(event);
	local filter = false;

	if ( chatFilters ) then
		local newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
		for _, filterFunc in pairs(chatFilters) do
			filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14 = filterFunc(frame, event, ...);
			if ( filter ) then
				return true;
			elseif ( newarg1 ) then
				local _;
				arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
			end
		end
	end

	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17;
end
WhisperEngine.processMessageEventFilters = processMessageEventFilters; -- make accessible to other modules

function WhisperEngine:CHAT_MSG_WHISPER(...)
	-- check if sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_WHISPER", ...);
		return;
	end

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getWhisperWindowByUser(arg2, nil, nil, true);

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_WHISPER', ...);
	if (filter and isNew) then
		win:close();
		return true;
	end

    local color = WIM.db.displayColors.wispIn; -- color contains .r, .g & .b

    win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_WHISPER", arg1, arg2, select(3, ...));
    win:Pop("in");

	setLastTellTarget(arg2, "WHISPER");

    win.online = true;
    updateMinimapAlerts();

    -- get missing data available from C_PlayerInfo
    if (arg12 and (not win.race or win.class)) then
        local class, _, race = GetPlayerInfoByGUID(arg12);

        win.WhoCallback({
            Name = win.theUser,
            Online = true,
            Guild = win.guild,
            Class = class or win.class,
            Level = win.level,
            Race = race or win.race,
            Zone = win.location
        });
    end

	-- emulate blizzards flash client icon behavior.
	if FlashClientIcon then
		FlashClientIcon();
	end

    CallModuleFunction("PostEvent_Whisper", arg1, arg2, select(3, ...));
end

function WhisperEngine:CHAT_MSG_WHISPER_INFORM(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_WHISPER_INFORM", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getWhisperWindowByUser(arg2, nil, nil, true);

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_WHISPER_INFORM', ...);
	if (filter and isNew) then
		win:close();
		return true;
	end

    local color = db.displayColors.wispOut; -- color contains .r, .g & .b

    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_WHISPER_INFORM", arg1, arg2, select(3, ...));
    win.unreadCount = 0; -- having replied  to conversation implies the messages have been read.
    win:Pop("out");

	setLastToldTarget(arg2, "WHISPER");

    win.online = true;
    win.msgSent = false;
    updateMinimapAlerts();
    CallModuleFunction("PostEvent_WhisperInform", arg1, arg2, select(3, ...));
    addToTableUnique(recentSent, arg1);
	if(#recentSent > maxRecent) then
		table.remove(recentSent, 1);
	end
end

function WhisperEngine:CHAT_MSG_BN_WHISPER_INFORM(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_BN_WHISPER_INFORM", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	local win, isNew = getWhisperWindowByUser(arg2, true, arg13, true);
	if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_BN_WHISPER_INFORM', ...);
	if (filter and isNew) then
		win:close();
		return true;
	end

    local color = db.displayColors.BNwispOut; -- color contains .r, .g & .b

	if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_BN_WHISPER_INFORM", arg1, arg2, select(3, ...));

	win.unreadCount = 0; -- having replied  to conversation implies the messages have been read.
    win:Pop("out");

	setLastToldTarget(arg2, "BN_WHISPER", arg13);

    win.online = true;
    win.msgSent = false;
    updateMinimapAlerts();

	-- emulate blizzards flash client icon behavior.
	if FlashClientIcon then
		FlashClientIcon();
	end

    CallModuleFunction("PostEvent_WhisperInform", arg1, arg2, select(3, ...));

	addToTableUnique(recentSent, arg1);
	if(#recentSent > maxRecent) then
		table.remove(recentSent, 1);
	end
end

function WhisperEngine:CHAT_MSG_BN_WHISPER(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_BN_WHISPER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	local win, isNew = getWhisperWindowByUser(arg2, true, arg13, true);
	if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_BN_WHISPER', ...);
	if (filter and isNew) then
		win:close();
		return true;
	end

    local color = WIM.db.displayColors.BNwispIn; -- color contains .r, .g & .b

    win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_BN_WHISPER", arg1, arg2, select(3, ...));
    win:Pop("in");

	setLastTellTarget(arg2, "BN_WHISPER", arg13);

    win.online = true;
    updateMinimapAlerts();
    CallModuleFunction("PostEvent_Whisper", arg1, arg2, select(3, ...));
end

function WhisperEngine:CHAT_MSG_AFK(...)
	-- check if sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_AFK", ...);
		return;
	end

    local color = db.displayColors.wispIn; -- color contains .r, .g & .b
    local win = Windows[safeName(select(2, ...))];

    if(win) then

        win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_AFK", ...);
        win:Pop("out");
        win.online = true;

		setLastTellTarget(select(2, ...), "WHISPER");
    end
end

function WhisperEngine:CHAT_MSG_DND(...)
	-- check if sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_DND", ...);
		return;
	end

    local color = db.displayColors.wispIn; -- color contains .r, .g & .b
    local win = Windows[safeName(select(2, ...))];
    if(win) then
        win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_DND", ...);
        win:Pop("out");
        win.online = true;

		setLastTellTarget(select(2, ...), "WHISPER");
    end
end

local CMS_SLUG = {};
function WhisperEngine:CHAT_MSG_SYSTEM(...)
	-- check if sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_SYSTEM", ...);
		return;
	end

	-- the proccessing of the actual message is taking place within the ChatMessageFilter
	CMS_SLUG._isWIM = true;
	processMessageEventFilters(CMS_SLUG, 'CHAT_MSG_SYSTEM', ...);
end

function WhisperEngine:CHAT_MSG_BN_INLINE_TOAST_ALERT(...)
	-- check if sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_BN_INLINE_TOAST_ALERT", ...);
		return;
	end

	local process, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons = ...;

	local online = process == "FRIEND_ONLINE"
	local offline = process == "FRIEND_OFFLINE"

	local curState = db.pop_rules.whisper.alwaysOther and "other" or curState;

	local _, accName = GetBNGetFriendInfoByID(bnSenderID)
	local win = Windows[safeName(accName)]
	if win then
		local msg = accName.." "..(online and _G.BN_TOAST_ONLINE or offline and _G.BN_TOAST_OFFLINE or "")
		win:AddMessage(msg, db.displayColors.sysMsg.r, db.displayColors.sysMsg.g, db.displayColors.sysMsg.b);
        win.online = online;
        return;
	end
end

--------------------------------------
--          Whisper Related Hooks   --
--------------------------------------

-- hook SendChatMessage to track sent messages
hooksecurefunc(_G.C_ChatInfo or _G, "SendChatMessage", function(...)
	if HasAnySecretValues(...) then
		return;
	end

	if(select(2, ...) == "WHISPER") then
		local win = Windows[safeName(FormatUserName(select(4, ...))) or "NIL"];
		if(win) then
			win.msgSent = true;
		end
	end
end);

local stickyTypes = {};
local function setSticky (sticky)
	for i = 1, #stickyTypes do
		local chatTypeInfo = _G.ChatTypeInfo[stickyTypes[i]] or {};
		chatTypeInfo.sticky = sticky and 1 or 0;
	end
end

local prevChatType, prevTellTarget;
local function editBoxUpdateHeader(self, internalCall)
	local chatType, tellTarget = self:GetAttribute("chatType"),  self:GetAttribute("tellTarget");

	if HasAnySecretValues(chatType, tellTarget) or not db or not db.enabled then
		prevChatType, prevTellTarget = nil, nil;
		setSticky(true);
		return;
	end

	-- prevent duplicates
	if internalCall or (prevChatType == chatType and prevTellTarget == tellTarget) then
		return;
	end
	prevChatType, prevTellTarget = chatType, tellTarget;

	if (chatType == "WHISPER" or chatType == "BN_WHISPER") then
		local target = tellTarget;

		-- handle the whisper interception
		if (not InChatMessagingLockdown() and target and db and db.enabled) then
			local curState = curState;
			curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
			if (db.pop_rules.whisper.intercept and db.pop_rules.whisper[curState].onSend) then

				local bNetID;
				if (chatType == "BN_WHISPER" or target:find("^|K")) then
					bNetID = _G.BNet_GetBNetIDAccount(target);
				end

				local win = getWhisperWindowByUser(target, bNetID and true, bNetID);
				if win then
					win.widgets.msg_box.setText = 1;
					win:Pop(true); -- force popup
					win.widgets.msg_box:SetFocus();

					if (_G.ChatTypeInfo[chatType] and _G.ChatTypeInfo[chatType].sticky) then
						table.insert(stickyTypes, chatType);
						setSticky(false);
					end

					_G.C_Timer.After(0, function()
						if self:GetAttribute("chatType"):find("WHISPER") then
							self:SetAttribute("chatType", "SAY");
							self:SetAttribute("tellTarget", nil);
							(self.UpdateHeader or ChatEdit_UpdateHeader)( self, true );
						end

						if _G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed then
							_G.ChatFrameEditBoxMixin.OnEscapePressed(self)
						else
							_G.ChatEdit_OnEscapePressed(self);
						end

					end);
				end
			else
				setSticky(true);
			end
		else
			setSticky(true);
		end
	end

end

-- ChatEditBoxMixin hooking
if ChatFrameUtil and ChatFrameUtil.ActivateChat then
	-- each time a chat edit box is activated, check if it is hooked accordingly.
	hooksecurefunc(ChatFrameUtil, "ActivateChat", function(editBox)

		-- first check that the editBox is not WIM's msg_box, if it is, then do nothing.
		if(editBox._WIM_WhisperEngine_Hooked or editBox.widgetName == "msg_box") then
			return;
		end

		hooksecurefunc(editBox, "UpdateHeader", editBoxUpdateHeader);

		-- mark it as hooked
		editBox._WIM_WhisperEngine_Hooked = true;
	end);
else
	-- fallback to hooking all edit boxes on update header, this is less efficient but ensures compatibility with older clients.
	hooksecurefunc("ChatEdit_UpdateHeader", editBoxUpdateHeader);
end

-- ReplyTell: LastTellTarget
hooksecurefunc((ChatFrameUtil and ChatFrameUtil.ReplyTell) and ChatFrameUtil or _G, (ChatFrameUtil and ChatFrameUtil.ReplyTell) and "ReplyTell" or "ChatFrame_ReplyTell", function()
	if (not InChatMessagingLockdown() and db and db.enabled) then
		local tellTarget, chatType = unpack(lastTellTarget or {});

		if (HasAnySecretValues(tellTarget, chatType)) then
			return;
		end

		if GetLastWhisperWindow() and _G.LAST_ACTIVE_CHAT_EDIT_BOX then
			(_G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed or _G.ChatEdit_OnEscapePressed)(_G.LAST_ACTIVE_CHAT_EDIT_BOX)
		end
	end
end);

-- ReplyTell2: LastToldTarget
hooksecurefunc((ChatFrameUtil and ChatFrameUtil.ReplyTell2) and ChatFrameUtil or _G, (ChatFrameUtil and ChatFrameUtil.ReplyTell2) and "ReplyTell2" or "ChatFrame_ReplyTell2", function()
	if (not InChatMessagingLockdown() and db and db.enabled) then
		local tellTarget, chatType = unpack(lastToldTarget or {});

		if (HasAnySecretValues(tellTarget, chatType)) then
			return;
		end

		if GetLastWhisperWindow(true) and _G.LAST_ACTIVE_CHAT_EDIT_BOX then
			(_G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed or _G.ChatEdit_OnEscapePressed)(_G.LAST_ACTIVE_CHAT_EDIT_BOX)
		end
	end
end);


-- global reference
GetWhisperWindowByUser = getWhisperWindowByUser;





-- define context menu
local info = {};
info.text = "MENU_MSGBOX";
local msgBoxMenu = AddContextMenu(info.text, info);
        info = {};
        info.text = WIM.L["Recently Sent Messages"];
        info.notCheckable = true;
        msgBoxMenu:AddSubItem(AddContextMenu("RECENT_LIST", info), 1);
        local recentMenu = GetContextMenu("RECENT_LIST");
        if(recentMenu.menuTable) then
                for k, _ in pairs(recentMenu.menuTable) do
                        recentMenu.menuTable[k] = nil;
                end
        end
        for i=1, maxRecent do
            info = GetContextMenu("RECENT_LIST"..i) or {};
            info.txt = " ";
            info.hidden = true;
            info.notCheckable = true;
            recentMenu:AddSubItem(AddContextMenu("RECENT_LIST"..i, info));
        end

local function recentMenuClick(self)
        libs.DropDownMenu.CloseDropDownMenus();
        if(MSG_CONTEXT_MENU_EDITBOX) then
                if(_G.IsShiftKeyDown()) then
                        MSG_CONTEXT_MENU_EDITBOX:Insert(self.value);
                else
                        MSG_CONTEXT_MENU_EDITBOX:SetText(self.value);
                end
        end
end

RegisterWidgetTrigger("msg_box", "whisper,chat,w2w", "OnMouseDown", function(self)
                if(#recentSent == 0) then
                        local item = GetContextMenu("RECENT_LIST1");
                        item.text = "|cff808080 - "..L["None"].." - |r";
                        item.notClickable = true;
                        item.hidden = nil;
                        return;
                end
                for i=maxRecent, 1, -1 do
                        local item = GetContextMenu("RECENT_LIST"..(10-i+1));
                        item.notClickable = nil;
                        if(recentSent[i]) then
                                item.text = recentSent[i];
                                item.value = recentSent[i];
                                item.func = recentMenuClick;
                                item.hidden = nil;
                        else
                                item.hidden = true;
                        end
                end
        end);




-- This is a core module and must always be loaded...
WhisperEngine.canDisable = false;
