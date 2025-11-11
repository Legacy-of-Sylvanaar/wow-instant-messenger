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
	return string.lower(user or "")
end

local function getWhisperWindowByUser(user, isBN, bnID, fromEvent)
	if isBN then
		if bnID and not string.find(user, "^|K") then
			local _
			_, user = GetBNGetFriendInfoByID(bnID) -- fix window handler when using the chat hyperlink
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
        Windows[safeName(user)] = CreateWhisperWindow(user);
		Windows[safeName(user)].isBN = isBN;
		Windows[safeName(user)].bn = Windows[safeName(user)].bn or {};
        if(db.whoLookups or lists.gm[safeName(user)] or Windows[safeName(user)].isBN) then
            Windows[safeName(user)]:SendWho(); -- send who request
        end
        Windows[safeName(user)].online = true;
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
                _G.SendChatMessage(chunk, CHANNEL, EXTRA, to)
				-- _G.ChatThrottleLib:SendChatMessage(PRIORITY, HEADER, chunk, CHANNEL, EXTRA, to);
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
		local messageLength = obj.isBN and 800 or 255;
        local msgCount = math.ceil(string.len(msg)/messageLength);
        if(msgCount == 1) then
            Windows[safeName(obj.theUser)].msgSent = true;
			if(obj.isBN) then
				(_G.C_BattleNet and _G.C_BattleNet.SendWhisper or _G.BNSendWhisper)(obj.bn.id, msg);
			else
				_G.SendChatMessage(msg, "WHISPER", nil, obj.theUser);
				-- _G.ChatThrottleLib:SendChatMessage("ALERT", "WIM", msg, "WHISPER", nil, obj.theUser);
			end
        elseif(msgCount > 1) then
            Windows[safeName(obj.theUser)].msgSent = true;
            SendSplitMessage("ALERT", "WIM", msg, "WHISPER", nil, obj.theUser);
        end
        self:SetText("");
    end);


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

	return false, ...
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
				arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
			end
		end
	end

	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17;
end
WhisperEngine.processMessageEventFilters = processMessageEventFilters; -- make accessible to other modules

function WhisperEngine:CHAT_MSG_WHISPER(...)
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
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_WHISPER", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    win:Pop("in");
	(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(arg2, "WHISPER");
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

    CallModuleFunction("PostEvent_Whisper", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
end

function WhisperEngine:CHAT_MSG_WHISPER_INFORM(...)
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

    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_WHISPER_INFORM", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    win.unreadCount = 0; -- having replied  to conversation implies the messages have been read.
    win:Pop("out");
	(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(arg2, "WHISPER");
    win.online = true;
    win.msgSent = false;
    updateMinimapAlerts();
    CallModuleFunction("PostEvent_WhisperInform", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    addToTableUnique(recentSent, arg1);
	if(#recentSent > maxRecent) then
		table.remove(recentSent, 1);
	end
end

function WhisperEngine:CHAT_MSG_BN_WHISPER_INFORM(...)
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
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_BN_WHISPER_INFORM", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    win.unreadCount = 0; -- having replied  to conversation implies the messages have been read.
    win:Pop("out");
	(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(arg2, "BN_WHISPER");
    win.online = true;
    win.msgSent = false;
    updateMinimapAlerts();

	-- emulate blizzards flash client icon behavior.
	if FlashClientIcon then
		FlashClientIcon();
	end

    CallModuleFunction("PostEvent_WhisperInform", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);

	addToTableUnique(recentSent, arg1);
	if(#recentSent > maxRecent) then
		table.remove(recentSent, 1);
	end
end

function WhisperEngine:CHAT_MSG_BN_WHISPER(...)
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
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_BN_WHISPER", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    win:Pop("in");
	(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(arg2, "BN_WHISPER");
    win.online = true;
    updateMinimapAlerts();
    CallModuleFunction("PostEvent_Whisper", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
end

function WhisperEngine:CHAT_MSG_AFK(...)
    local color = db.displayColors.wispIn; -- color contains .r, .g & .b
    local win = Windows[safeName(select(2, ...))];
    if(win) then
        win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_AFK", ...);
        win:Pop("out");
   		(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(select(2, ...), "AFK");
        win.online = true;
    end
end

function WhisperEngine:CHAT_MSG_DND(...)
    local color = db.displayColors.wispIn; -- color contains .r, .g & .b
    local win = Windows[safeName(select(2, ...))];
    if(win) then
        win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_AFK", ...);
        win:Pop("out");
   		(ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatFrame_SetLastTellTarget)(select(2, ...), "AFK");
        win.online = true;
    end
end

local CMS_SLUG = {};
function WhisperEngine:CHAT_MSG_SYSTEM(...)
	-- the proccessing of the actual message is taking place within the ChatMessageFilter
	CMS_SLUG._isWIM = true;
	processMessageEventFilters(CMS_SLUG, 'CHAT_MSG_SYSTEM', ...);
end

function WhisperEngine:CHAT_MSG_BN_INLINE_TOAST_ALERT(process, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)

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
local function replyTellTarget(TellNotTold)
	if (db.enabled) then
		local curState = curState;
		curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
		local lastTell;
		if (TellNotTold) then
		lastTell = ChatFrameUtil and ChatFrameUtil.GetLastTellTarget and ChatFrameUtil.GetLastTellTarget() or _G.ChatEdit_GetLastTellTarget();
		else
		lastTell = ChatFrameUtil and ChatFrameUtil.GetLastToldTarget and ChatFrameUtil.GetLastToldTarget() or _G.ChatEdit_GetLastToldTarget();
		end

		-- Grab the string after the slash command
		if not lastTell then return end--because if you fat finger R or try to re ply before someone sent a tell, it generates a lua error without this
		local bNetID;
		if (lastTell:find("^|K")) then
		lastTell = _G.BNTokenFindName(lastTell) or lastTell;
		bNetID = _G.BNet_GetBNetIDAccount(lastTell);
		end

		if (lastTell ~= "" and db.pop_rules.whisper.intercept) then
		lastTell = _G.Ambiguate(lastTell, "none")
		local win = getWhisperWindowByUser(lastTell, bNetID and true, bNetID);

		if (win:IsVisible() or db.pop_rules.whisper[curState].onSend) then
			win.widgets.msg_box.setText = 1;
			win:Pop(true); -- force popup
			win.widgets.msg_box:SetFocus();
			local eb = getVisibleChatFrameEditBox();
			if _G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed then
				_G.ChatFrameEditBoxMixin.OnEscapePressed(getVisibleChatFrameEditBox() or _G.ChatFrame1EditBox)
			else
				_G.ChatEdit_OnEscapePressed(getVisibleChatFrameEditBox() or _G.ChatFrame1EditBox);
			end
		end
		end
	end
end

-- "/w |Kf287|k0000000000000|k "
local tellTargetExtractionAutoComplete = _G.AUTOCOMPLETE_LIST.ALL;
function CF_ExtractTellTarget(editBox, msg, chatType)
	-- Grab the string after the slash command
	local target = string.match(msg, "%s*(.*)");
	local bNetID;
	-- _G.DEFAULT_CHAT_FRAME:AddMessage("Raw: "..msg:gsub("|", ":")); -- debugging
	if (target:find("^|K")) then
		local old_target, old_msg = target, msg
		target, msg = _G.BNTokenFindName(target)
		target = target or old_target
		msg = msg or old_msg
		bNetID = _G.BNet_GetBNetIDAccount(target);
	else
		--If we haven't even finished one word, we aren't done.
		if (not target or not string.find(target, "%s") or (string.sub(target, 1, 1) == "|")) then
			return false;
		end

		--Keep pulling off everything after the last space until we either have something on the AutoComplete list or
		-- -- only a single word is left.
		while (string.find(target, "%s")) do
			--Pull off everything after the last space.
			target = string.match(target, "(%S+)%s+[^%s]*");
			target = _G.Ambiguate(target, "none")
			if (_G.GetAutoCompleteResults(target, 1, 0, tellTargetExtractionAutoComplete.include,
				tellTargetExtractionAutoComplete.exclude, 1, nil, true)) then
				break;
			end
		end
		msg = string.sub(msg, string.len(target) + 2);
	end

	if (db and db.enabled) then
		local curState = curState;
		curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
		if (db.pop_rules.whisper.intercept and db.pop_rules.whisper[curState].onSend) then
			target = _G.Ambiguate(target, "none")--For good measure, ambiguate again cause it seems some mods interfere with this process
			local win = getWhisperWindowByUser(target, bNetID and true, bNetID);
			if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing
			win.widgets.msg_box.setText = 1;
			win:Pop(true); -- force popup
			win.widgets.msg_box:SetFocus();

			if _G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed then
				_G.ChatFrameEditBoxMixin.OnEscapePressed(getVisibleChatFrameEditBox() or _G.ChatFrame1EditBox)
			else
				_G.ChatEdit_OnEscapePressed(getVisibleChatFrameEditBox() or _G.ChatFrame1EditBox);
			end
		end
	end
end

function CF_SentBNetTell(target)
	if (db and db.enabled) then
		local curState = curState;
		curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
		if (db.pop_rules.whisper.intercept and db.pop_rules.whisper[curState].onSend) then
			local bNetID = _G.BNet_GetBNetIDAccount(target);
			target = _G.Ambiguate(target, "none")--For good measure, ambiguate again cause it seems some mods interfere with this process
			local win = getWhisperWindowByUser(target, true, bNetID);
			if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing
			win.widgets.msg_box.setText = 1;
			win:Pop(true); -- force popup
			win.widgets.msg_box:SetFocus();

			local editBox = _G.LAST_ACTIVE_CHAT_EDIT_BOX;
			if (editBox) then
				if _G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed then
					_G.ChatFrameEditBoxMixin.OnEscapePressed(editBox)
				else
					_G.ChatEdit_OnEscapePressed(editBox);
				end
				return;
			end
		end
	end
end

function CF_OpenChat(text, chatFrame, desiredCursorPosition)
	local editBox = _G.ChatEdit_ChooseBoxForSend(chatFrame)

	local chatType = editBox:GetAttribute("chatType")
    local target = editBox:GetAttribute("tellTarget")
	local sticky = editBox:GetAttribute("stickyType")

	if chatType == "WHISPER" then
		if not string.find(target, "^|K") then
			return
		end
	elseif chatType ~= "BN_WHISPER" or not target then
		return
	end

	if not editBox:IsVisible() then return end

	if (db and db.enabled) then
		local curState = curState;
		curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
		if (db.pop_rules.whisper.intercept and db.pop_rules.whisper[curState].onSend) then
			local bNetID = _G.BNet_GetBNetIDAccount(target);
			target = _G.Ambiguate(target, "none")--For good measure, ambiguate again cause it seems some mods interfere with this process
			local win = getWhisperWindowByUser(target, bNetID and true, bNetID);
			if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing
			win.widgets.msg_box.setText = 1;
			win:Pop(true); -- force popup
			if not (sticky == "WHISPER" or sticky == "BN_WHISPER") then
				win.widgets.msg_box:SetFocus();
				_G.ChatEdit_OnEscapePressed(editBox);
			end
		end
	end
end

if ChatFrameUtil and ChatFrameUtil.SendBNetTell then
	hooksecurefunc(ChatFrameUtil, "SendBNetTell", CF_SentBNetTell);
else
	hooksecurefunc("ChatFrame_SendBNetTell", CF_SentBNetTell);
end

--Hook ChatFrame_ReplyTell & ChatFrame_ReplyTell2
if ChatFrameUtil and ChatFrameUtil.ReplyTell then
	hooksecurefunc(ChatFrameUtil, "ReplyTell", function() replyTellTarget(true) end);
	hooksecurefunc(ChatFrameUtil, "ReplyTell2", function() replyTellTarget(false) end);
else
	hooksecurefunc("ChatFrame_ReplyTell", function() replyTellTarget(true) end);
	hooksecurefunc("ChatFrame_ReplyTell2", function() replyTellTarget(false) end);
end

local hookedSendChatMessage = _G.SendChatMessage;
function _G.SendChatMessage(...)
    if(select(2, ...) == "WHISPER") then
        local win = Windows[safeName(FormatUserName(select(4, ...))) or "NIL"];
        if(win) then
            win.msgSent = true;
        end
    end
    hookedSendChatMessage(...);
end


-- ChatEditBoxMixin hooking
if ChatFrameUtil and ChatFrameUtil.ActivateChat then
	-- each time a chat edit box is activated, check if it is hooked accordingly.
	hooksecurefunc(ChatFrameUtil, "ActivateChat", function(editBox)
		-- first check that the editBox is not WIM's msg_box, if it is, then do nothing.
		if(editBox._WIM_WhisperEngine_Hooked or editBox.widgetName == "msg_box") then
			return;
		end

		-- ExtractTellTarget
		-- hooksecurefunc(editBox, "ExtractTellTarget", CF_ExtractTellTarget);

		-- UpdateHeader -- appears to be a better place to hook into for our purposes
		hooksecurefunc(editBox, "UpdateHeader", function (editBox)
			local type = editBox:GetAttribute("chatType");
			local target  = editBox:GetAttribute("tellTarget");

			if (type ~= "WHISPER" and type ~= "BN_WHISPER") then
				return;
			end

			if (target and db and db.enabled) then
				local curState = curState;
				curState = db.pop_rules.whisper.alwaysOther and "other" or curState;
				if (db.pop_rules.whisper.intercept and db.pop_rules.whisper[curState].onSend) then
					target = _G.Ambiguate(target, "none")--For good measure, ambiguate again cause it seems some mods interfere with this process
					local win = getWhisperWindowByUser(target, bNetID and true, bNetID);
					if not win then return end	--due to a client bug, we can not receive the other player's name, so do nothing
					win.widgets.msg_box.setText = 1;
					win:Pop(true); -- force popup
					win.widgets.msg_box:SetFocus();

					if _G.ChatFrameEditBoxMixin and _G.ChatFrameEditBoxMixin.OnEscapePressed then
						_G.ChatFrameEditBoxMixin.OnEscapePressed(editBox)
					else
						_G.ChatEdit_OnEscapePressed(editBox);
					end
				end
			end
		end);

		-- mark it as hooked
		editBox._WIM_WhisperEngine_Hooked = true;
	end);
end

-- Legacy hooks
if not _G.ChatFrameEditBoxBaseMixin or not _G.ChatFrameEditBoxBaseMixin.ExtractTellTarget then
	hooksecurefunc("ChatEdit_ExtractTellTarget", CF_ExtractTellTarget);
	hooksecurefunc("ChatFrame_OpenChat", CF_OpenChat);
end

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
WhisperEngine:Enable();
