-- imports
local WIM = WIM;
local _G = _G;
local hooksecurefunc = hooksecurefunc;
local tostring = tostring;
local type = type;
local pcall = pcall;
local table = table;
local pairs = pairs;
local string = string;
local select = select;
local math = math;
local tonumber = tonumber;
local playerRealm = GetRealmName()
local ChatFrameUtil = ChatFrameUtil;

-- set name space
setfenv(1, WIM);

local Windows = windows.active.chat;

db_defaults.pop_rules.chat = {
        --pop-up rule sets based off of your location
        resting = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        combat = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        pvp = {
            onSend = false,
            onReceive = false,
            supress = false,
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
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        raid = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        bn = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        other = {
            onSend = false,
            onReceive = false,
            supress = false,
            autofocus = false,
            keepfocus = false,
        },
        alwaysOther = true,
        intercept = false,
		obeyAutoFocusRules = false,
}

db_defaults.chat = {
    world = {
        enabled = false,
        channelSettings = {}
    },
    custom = {
        enabled = false,
        channelSettings = {}
    },
	community = {
        enabled = false,
        -- Whether WIM focuses community streams itself at login. On by
        -- default: without it the client refuses sends to community-backed
        -- channel numbers (see Channel:FocusCommunityStreams). Exposed as a
        -- setting only so the pass can be compared against the client's own
        -- focusing. Why the client skips its own focusing while WIM is
        -- loaded is unknown.
        autoFocusStreams = true,
        -- Opt-in only: see reAddCommunityChannels. Mutates saved chat window
        -- configuration, so it stays off unless explicitly enabled.
        repairChannelReAdd = false,
        channelSettings = {}
    },
    guild = {
        showAlerts = true,
    },
    officer = {
        showAlerts = true,
    },
    raid = {
        showAlerts = true,
    },
    party = {
        showAlerts = true,
    },
    battleground = {

    },
    say = {
        outputType = "SAY",
    },
    bn = {
        showAlerts = true,
    },
};


local USERLIST_BUTTON_COUNT = 5;

local function getRuleSet()
    local curState = db.pop_rules.chat.alwaysOther and "other" or curState
    return db.pop_rules.chat[curState];
end


-- The say window's outgoing chat type. The toggle button itself lives
-- on the shortcut bar (ShortcutBar module).
local SAY_OUTPUT_ORDER = { SAY = "YELL", YELL = "EMOTE", EMOTE = "SAY" };

function GetSayOutputType()
    local mode = db and db.chat and db.chat.say and db.chat.say.outputType;
    return SAY_OUTPUT_ORDER[mode] and mode or "SAY";
end

function CycleSayOutputType()
    db.chat.say.outputType = SAY_OUTPUT_ORDER[GetSayOutputType()];
    if(UpdateAllInputColors) then UpdateAllInputColors(); end
    return GetSayOutputType();
end

function SetSayOutputType(mode)
    if(SAY_OUTPUT_ORDER[mode]) then
        db.chat.say.outputType = mode;
        if(UpdateAllInputColors) then UpdateAllInputColors(); end
    end
end

local function createWidget_Chat()
    local button = _G.CreateFrame("Button");
    button.text = button:CreateFontString(nil, "BACKGROUND");
    button.text:SetFont("Fonts\\SKURRI.ttf", 16);
    button.text:SetAllPoints();
    button.text:SetText("");
    button.SetText = function(self, text)
            self.text:SetText(text);
            --adjust font size to match widget
        end
    button.SetActive = function(self, active)
            self.active = active;
            if(active) then
                self:Show();
            else
                self:Hide();
            end
        end
    button.SetDefaults = function(self)
            self:SetActive(false);
        end
    button.UpdateSkin = function(self)
            --self.flash.bg:SetTexture(GetSelectedSkin().message_window.widgets.w2w.HighlightTexture);
        end
    button:SetScript("OnClick", function(self)
            if(self.active) then
                ChatUserList.listCount = self.parentWindow.CHAT_listCount;
                ChatUserList.listFun = self.parentWindow.CHAT_listFun;
                ChatUserList:PopUp(self, "TOPRIGHT", "TOPLEFT")
                ChatUserList:SetChannel(self.parentWindow.widgets.from:GetText());
            end
        end);
    button:SetScript("OnLeave", function(self)
                --ChatUserList:Hide();
        end);

    return button;
end

local function getChatWindow(ChatName, chatType)
    if(not ChatName or ChatName == "") then
        -- if invalid user, then return nil;
        return nil;
    end
    local obj = Windows[ChatName];
    if(obj and obj.type == "chat") then
        -- if the whisper window exists, return the object
        return obj;
    else
        -- otherwise, create a new one.
        Windows[ChatName] = CreateChatWindow(ChatName);
        Windows[ChatName].chatType = chatType;
        Windows[ChatName]:UpdateIcon();
        Windows[ChatName].widgets.chat_info:SetActive(true);
        Windows[ChatName].chatList = Windows[ChatName].chatList or {};

        if(chatType == "guild" or chatType == "officer" or chatType == "party" or chatType == "raid") then
            Windows[ChatName].CHAT_listCount = function () return #Windows[ChatName].chatList end
            Windows[ChatName].CHAT_listFun = function (index) return Windows[ChatName].chatList[index] end
		elseif(chatType == "community") then
			Windows[ChatName].CHAT_listCount = function () return #GetClubStreamMembers(Windows[ChatName].clubId, Windows[ChatName].streamId); end
			Windows[ChatName].CHAT_listFun = function (index) return GetClubStreamMembers(Windows[ChatName].clubId, Windows[ChatName].streamId)[index]; end
		else
            Windows[ChatName].CHAT_listCount = nil;
            Windows[ChatName].CHAT_listFun = nil;
        end

        return Windows[ChatName], true;
    end
end


local function cleanChatList(win)
    if(win.chatList) then
        for k, _ in pairs(win.chatList) do
            win.chatList[k] = nil;
        end
    end
end


RegisterWidgetTrigger("msg_box", "chat", "OnEnterPressed", function(self)
    local obj, msg, TARGET, NUMBER = self:GetParent(), self:GetText();
	msg = PreSendFilterText(msg);

	-- do not send if in chat messaging lockdown (12.0.0+)
	if InChatMessagingLockdown() then
		return;
	end

	if(obj.chatType == "guild") then
		TARGET = "GUILD";
	elseif(obj.chatType == "officer") then
		TARGET = "OFFICER";
	elseif(obj.chatType == "party") then
		TARGET = "PARTY";
	elseif(obj.chatType == "raid") then
		TARGET = "RAID";
	elseif(obj.chatType == "battleground") then
		TARGET = "INSTANCE_CHAT";
	elseif(obj.chatType == "say") then
		TARGET = GetSayOutputType();
	elseif(obj.chatType == "channel") then
		TARGET = "CHANNEL";
		NUMBER = obj.channelNumber;
	elseif(obj.chatType == "community" and obj.clubId and obj.streamId) then
		_G.C_Club.SendMessage(obj.clubId, obj.streamId, msg);
		self:SetText("");
		return;
	else
		return;
	end

	if(msg ~= "") then
		SendSplitMessage("ALERT", "WIM", msg, TARGET, nil, NUMBER);
	end

	self:SetText("");
end);

-- Typing a /s, /y, or /e prefix (or any of the client's variants,
-- /say, /yell, /em, /me ...) in the say window is consumed on the
-- space: the prefix leaves the box and the output toggle flips to
-- that chat type. Whisper and other commands stay in the box and
-- keep their normal slash handling.
RegisterWidgetTrigger("msg_box", "chat", "OnTextChanged", function(self, isUser)
	if(not isUser) then return; end
	local obj = self:GetParent();
	if(obj.chatType ~= "say") then return; end
	local command, rest = string.match(self:GetText() or "", "^(/%S+)%s(.*)$");
	local chatType = command and _G.hash_ChatTypeInfoList
		and _G.hash_ChatTypeInfoList[string.upper(command)];
	if(chatType == "SAY" or chatType == "YELL" or chatType == "EMOTE") then
		SetSayOutputType(chatType);
		if(UpdateSayOutputShortcut) then
			UpdateSayOutputShortcut(obj);
		end
		self:SetText(rest);
	end
end);


local processMessageEventFilters = modules.WhisperEngine.processMessageEventFilters;

--------------------------------------
--              Guild Chat          --
--------------------------------------

-- create GuildChat Module
local Guild = CreateModule("GuildChat");

function Guild:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_GUILD");
    self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT");
    self:RegisterEvent("GUILD_ROSTER_UPDATE");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_GUILD', Guild.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', Guild.ChatMessageEventFilter);
	end
end

function Guild:OnDisable()
	if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_GUILD', Guild.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_GUILD', Guild.ChatMessageEventFilter);
	end
end

function Guild:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "guild") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        cleanChatList(Windows[chatName]);
        Windows[chatName] = nil;
        Guild.guildWindow = nil;
    end
end

function Guild:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "guild") then
		-- H.Sch. - ReglohPri - this is deprecated -> GuildRoster() - changed to C_GuildInfo.GuildRoster()
		_G.C_GuildInfo.GuildRoster();
    end
end

function Guild:GUILD_ROSTER_UPDATE()
    if(self.guildWindow) then
        -- update guild count
        cleanChatList(self.guildWindow);
        local count = 0;
        for i=1, _G.GetNumGuildMembers() do
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = _G.GetGuildRosterInfo(i);
			if(online) then
				--_G.GuildControlSetRank(rankIndex);
				local guildchat_listen, guildchat_speak, officerchat_listen, officerchat_speak, promote, demote,
						invite_member, remove_member, set_motd, edit_public_note, view_officer_note, edit_officer_note,
						modify_guild_info, _, withdraw_repair, withdraw_gold, create_guild_event = _G.C_GuildInfo.GuildControlGetRankFlags(rankIndex);
				if(guildchat_listen) then
					name = _G.Ambiguate(name, "none")
					count = count + 1;
					table.insert(self.guildWindow.chatList, name);
				end
			end
		end

        self.guildWindow.widgets.chat_info:SetText(count);
    end
end

function Guild.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.guild.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Guild:CHAT_MSG_GUILD(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_GUILD", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.GUILD, "guild");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_GUILD', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["GUILD"] or _G.NORMAL_FONT_COLOR;

    self.guildWindow = win;

    if(not self.chatLoaded) then
        Guild:GUILD_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_GUILD", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.guild.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.guild.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_GUILD", arg1, arg2, select(3, ...));
end





--------------------------------------
--            Officer Chat          --
--------------------------------------

-- create OfficerChat Module
local Officer = CreateModule("OfficerChat");

function Officer:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_OFFICER");
    self:RegisterEvent("GUILD_ROSTER_UPDATE");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_OFFICER', Officer.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_OFFICER', Officer.ChatMessageEventFilter);
	end
end

function Officer:OnDisable()
	if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_OFFICER', Officer.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_OFFICER', Officer.ChatMessageEventFilter);
	end
end

function Officer:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "officer") then
		Officer.officerWindow = win
		_G.C_GuildInfo.GuildRoster();
    end
end

function Officer:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "officer") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        cleanChatList(Windows[chatName]);
        Windows[chatName] = nil;
        Officer.officerWin = nil;
    end
end

function Officer:GUILD_ROSTER_UPDATE()
    if(self.officerWindow) then
        -- update guild count
        cleanChatList(self.officerWindow);
        local count = 0;
        for i=1, _G.GetNumGuildMembers() do
	    local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = _G.GetGuildRosterInfo(i);
            if(online) then
                --_G.GuildControlSetRank(rankIndex);
                local guildchat_listen, guildchat_speak, officerchat_listen, officerchat_speak, promote, demote,
                        invite_member, remove_member, set_motd, edit_public_note, view_officer_note, edit_officer_note,
                        modify_guild_info, _, withdraw_repair, withdraw_gold, create_guild_event = _G.C_GuildInfo.GuildControlGetRankFlags(rankIndex);
        	if(officerchat_listen) then
					name = _G.Ambiguate(name, "none")
                    count = count + 1;
                    table.insert(self.officerWindow.chatList, name);
                end
            end
	end
        self.officerWindow.widgets.chat_info:SetText(count);
    end
end

function Officer.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.officer.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Officer:CHAT_MSG_OFFICER(...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_OFFICER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.GUILD_RANK1_DESC, "officer");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_OFFICER', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["OFFICER"] or _G.NORMAL_FONT_COLOR;

    Officer.officerWindow = win;
    if(not self.chatLoaded) then
        Officer:GUILD_ROSTER_UPDATE();
    end

	self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_OFFICER", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.officer.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.officer.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_OFFICER", arg1, arg2, select(3, ...));
end




--------------------------------------
--            Party Chat            --
--------------------------------------

-- create PartyChat Module
local Party = CreateModule("PartyChat");

function Party:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_PARTY");
    self:RegisterEvent("CHAT_MSG_PARTY_LEADER");
    self:RegisterEvent("GROUP_ROSTER_UPDATE");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_PARTY', Party.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_PARTY_LEADER', Party.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY', Party.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY_LEADER', Party.ChatMessageEventFilter);
	end
end

function Party:OnDisable()
    if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_PARTY', Party.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_PARTY_LEADER', Party.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_PARTY', Party.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_PARTY_LEADER', Party.ChatMessageEventFilter);
	end
end

function Party:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "party") then
		Party.partyWindow = win;
		Party:GROUP_ROSTER_UPDATE();
    end
end

function Party:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "party") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        cleanChatList(Windows[chatName]);
        Windows[chatName] = nil;
        Party.partyWindow = nil;
    end
end

function Party:GROUP_ROSTER_UPDATE()
    if(Party.partyWindow) then
        cleanChatList(self.partyWindow);
        local myName = _G.UnitName("player");
        table.insert(self.partyWindow.chatList, myName);
        local count = 0;
        for i=1, 4 do
            if _G.UnitExists("party"..i) then
                count = count + 1;
                local name = _G.GetUnitName("party"..i, true);
                table.insert(self.partyWindow.chatList, name);
            end
        end
        Party.partyWindow.widgets.chat_info:SetText(count + 1);
    end
end

function Party.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.party.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Party:CHAT_MSG_PARTY(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_PARTY", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.PARTY, "party");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_PARTY', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["PARTY"] or _G.NORMAL_FONT_COLOR;

    Party.partyWindow = win;
    if(not self.chatLoaded) then
        Party:GROUP_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_PARTY", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.party.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.party.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_PARTY", arg1, arg2, select(3, ...));
end

function Party:CHAT_MSG_PARTY_LEADER(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_PARTY_LEADER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.PARTY, "party");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_PARTY_LEADER', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["PARTY_LEADER"] or _G.NORMAL_FONT_COLOR;

    Party.partyWindow = win;
    if(not self.chatLoaded) then
        Party:GROUP_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_PARTY_LEADER", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.party.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.party.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_PARTY_LEADER", arg1, arg2, select(3, ...));
end


--------------------------------------
--            Raid Chat             --
--------------------------------------

-- create RaidChat Module
local Raid = CreateModule("RaidChat");

function Raid:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_RAID");
    self:RegisterEvent("CHAT_MSG_RAID_LEADER");
    self:RegisterEvent("CHAT_MSG_RAID_WARNING");
    self:RegisterEvent("GROUP_ROSTER_UPDATE");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_RAID', Raid.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_RAID_LEADER', Raid.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_RAID_WARNING', Raid.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID', Raid.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_LEADER', Raid.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_WARNING', Raid.ChatMessageEventFilter);
	end
end
function Raid:OnDisable()
	if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_RAID', Raid.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_RAID_LEADER', Raid.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_RAID_WARNING', Raid.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_RAID', Raid.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_RAID_LEADER', Raid.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_RAID_WARNING', Raid.ChatMessageEventFilter);
	end
end

function Raid:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "raid") then
		win.raidWindow = win;
		Raid:GROUP_ROSTER_UPDATE();
    end
end

function Raid:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "raid") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        cleanChatList(Windows[chatName]);
        Windows[chatName] = nil;
    end
end

function Raid:GROUP_ROSTER_UPDATE()
    if(Raid.raidWindow) then
        cleanChatList(self.raidWindow);
        local count = 0;
        for i=1,40 do
            local name = _G.GetRaidRosterInfo(i);
            if(name) then
                count = count + 1;
                table.insert(self.raidWindow.chatList, name);
            end
        end
        self.raidWindow.widgets.chat_info:SetText(count);
    end
end

function Raid.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.raid.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Raid:CHAT_MSG_RAID(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_RAID", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.RAID, "raid");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_RAID', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["RAID"] or _G.NORMAL_FONT_COLOR;

    self.raidWindow = win;
    if(not self.chatLoaded) then
        Raid:GROUP_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_RAID", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.raid.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.raid.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_RAID", arg1, arg2, select(3, ...));
end

function Raid:CHAT_MSG_RAID_LEADER(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_RAID_LEADER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.RAID, "raid");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_RAID_LEADER', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["RAID_LEADER"] or _G.NORMAL_FONT_COLOR;

    self.raidWindow = win;
    if(not self.chatLoaded) then
        Raid:GROUP_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_RAID_LEADER", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.raid.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.raid.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_RAID_LEADER", arg1, arg2, select(3, ...));
end

function Raid:CHAT_MSG_RAID_WARNING(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_RAID_WARNING", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.RAID, "raid");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_RAID_WARNING', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["RAID_WARNING"] or _G.NORMAL_FONT_COLOR;

    self.raidWindow = win;
    if(not self.chatLoaded) then
        Raid:GROUP_ROSTER_UPDATE();
    end

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_RAID_WARNING", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.raid.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.raid.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_RAID_WARNING", arg1, arg2, select(3, ...));
end


--------------------------------------
--            Battleground Chat             --
--------------------------------------

-- create RaidChat Module
local Battleground = CreateModule("BattlegroundChat");

function Battleground:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT");
    self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT', Battleground.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT_LEADER', Battleground.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT', Battleground.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT_LEADER', Battleground.ChatMessageEventFilter);
	end
end

function Battleground:OnDisable()
    if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_INSTANCE_CHAT', Battleground.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_INSTANCE_CHAT_LEADER', Battleground.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_INSTANCE_CHAT', Battleground.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_INSTANCE_CHAT_LEADER', Battleground.ChatMessageEventFilter);
	end
end

function Battleground:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "battleground") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        Windows[chatName].battlegroundWindow = nil;
        Windows[chatName] = nil;
    end
end

local function getBattlegroundCount()
    for i=1, 20 do
        local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = _G.GetChannelDisplayInfo(i);
        if(name == _G.INSTANCE_CHAT) then
            return count;
        end
    end
    return 0;
end

function Battleground:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "battleground") then
        win.widgets.chat_info:SetText(getBattlegroundCount());
    end
end

function Battleground.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.battleground.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Battleground:CHAT_MSG_INSTANCE_CHAT(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_INSTANCE_CHAT", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.INSTANCE_CHAT, "battleground");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_INSTANCE_CHAT', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    win.widgets.chat_info:SetText(getBattlegroundCount());

    local color = _G.ChatTypeInfo["INSTANCE_CHAT"] or _G.NORMAL_FONT_COLOR;

	self.battlegroundWindow = win;
    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_INSTANCE_CHAT", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.battleground.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.battleground.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_INSTANCE_CHAT", arg1, arg2, select(3, ...));
end

function Battleground:CHAT_MSG_INSTANCE_CHAT_LEADER(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_INSTANCE_CHAT_LEADER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.INSTANCE_CHAT, "battleground");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_INSTANCE_CHAT_LEADER', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    win.widgets.chat_info:SetText(getBattlegroundCount());

    local color = _G.ChatTypeInfo["INSTANCE_CHAT_LEADER"] or _G.NORMAL_FONT_COLOR;

    self.battlegroundWindow = win;
    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_INSTANCE_CHAT_LEADER", arg1, arg2, arg3, select(4, ...));

	if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.battleground.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.battleground.neverPop) then
            win:Pop("out");
        end
    end

    CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_INSTANCE_CHAT_LEADER", arg1, arg2, select(3, ...));
end

--------------------------------------
--            Say Chat            --
--------------------------------------

-- create SayChat Module
local Say = CreateModule("SayChat");

function Say:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

	self:RegisterEvent("CHAT_MSG_SAY");
	self:RegisterEvent("CHAT_MSG_EMOTE");
	self:RegisterEvent("CHAT_MSG_TEXT_EMOTE");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_SAY', Say.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_EMOTE', Say.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_TEXT_EMOTE', Say.ChatMessageEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_SAY', Say.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_EMOTE', Say.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_TEXT_EMOTE', Say.ChatMessageEventFilter);
	end
end
function Say:OnDisable()
	if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_SAY', Say.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_EMOTE', Say.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_TEXT_EMOTE', Say.ChatMessageEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_SAY', Say.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_EMOTE', Say.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_TEXT_EMOTE', Say.ChatMessageEventFilter);
	end
end

function Say:OnWindowDestroyed(win)
    if(win.type == "chat" and win.chatType == "say") then
        local chatName = win.theUser;
        Windows[chatName].chatType = nil;
        Windows[chatName].unreadCount = nil;
        Windows[chatName].chatLoaded = nil;
        cleanChatList(Windows[chatName]);
        Windows[chatName] = nil;
    end
end

function Say.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)

	if (not frame._isWIM and not ignore and not block) then
		if(not db.chat.say.neverSuppress and getRuleSet().supress) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

function Say:CHAT_MSG_SAY(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_SAY", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.SAY, "say");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_SAY', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["SAY"] or _G.NORMAL_FONT_COLOR;

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    --Don't handle say messages during encounters, when boss mods are handling them
    local fightingBoss = (_G.C_InstanceEncounter and _G.C_InstanceEncounter.IsEncounterInProgress and _G.C_InstanceEncounter.IsEncounterInProgress()) or (_G.IsEncounterInProgress and _G.IsEncounterInProgress()) or (DBM and DBM:InCombat()) or false
    if not fightingBoss then
    	win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_SAY", arg1, arg2, arg3, select(4, ...));
    end

    if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.say.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.say.neverPop) then
            win:Pop("out");
        end
    end

    if not fightingBoss then
   		CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_SAY", arg1, arg2, select(3, ...));
   	end
end

function Say:CHAT_MSG_EMOTE(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_EMOTE", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.SAY, "say");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_EMOTE', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

	local color = _G.ChatTypeInfo["EMOTE"] or _G.NORMAL_FONT_COLOR;

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    --Don't handle say messages during encounters, when boss mods are handling them
    local fightingBoss = (_G.C_InstanceEncounter and _G.C_InstanceEncounter.IsEncounterInProgress and _G.C_InstanceEncounter.IsEncounterInProgress()) or (_G.IsEncounterInProgress and _G.IsEncounterInProgress()) or (DBM and DBM:InCombat()) or false
    if not fightingBoss then
    	win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_EMOTE", arg1, arg2, arg3, select(4, ...));
    end

    if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.say.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.say.neverPop) then
            win:Pop("out");
        end
    end

    if not fightingBoss then
   		CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_EMOTE", arg1, arg2, select(3, ...));
   	end
end

function Say:CHAT_MSG_TEXT_EMOTE(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_TEXT_EMOTE", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(_G.SAY, "say");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_TEXT_EMOTE', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["EMOTE"] or _G.NORMAL_FONT_COLOR;

    self.chatLoaded = true;
    arg3 = CleanLanguageArg(arg3);
    --Don't handle say messages during encounters, when boss mods are handling them
    local fightingBoss = (_G.C_InstanceEncounter and _G.C_InstanceEncounter.IsEncounterInProgress and _G.C_InstanceEncounter.IsEncounterInProgress()) or (_G.IsEncounterInProgress and _G.IsEncounterInProgress()) or (DBM and DBM:InCombat()) or false
    if not fightingBoss then
    	win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_TEXT_EMOTE", arg1, arg2, arg3, select(4, ...));
    end

    if(arg2 ~= _G.UnitName("player")) then
        win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
        if(not db.chat.say.neverPop) then
            win:Pop("in");
        end
    else
        if(not db.chat.say.neverPop) then
            win:Pop("out");
        end
    end

    if not fightingBoss then
   		CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_TEXT_EMOTE", arg1, arg2, select(3, ...));
   	end
end

--------------------------------------
--            Channel Chat          --
--------------------------------------

-- create ChannelChat Module
local Channel = CreateModule("ChannelChat");

function Channel:OnEnable()
    RegisterWidget("chat_info", createWidget_Chat);

    self:RegisterEvent("CHAT_MSG_CHANNEL");
    self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN");
    self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE");
    self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
    self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE_USER");
	self:RegisterEvent("CLUB_MESSAGE_ADDED");

	if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_CHANNEL', Channel.ChatMessageEventFilter);
		ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_COMMUNITIES_CHANNEL', Channel.ChatMessageCommunitiesEventFilter);
	else
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', Channel.ChatMessageEventFilter);
		_G.ChatFrame_AddMessageEventFilter('CHAT_MSG_COMMUNITIES_CHANNEL', Channel.ChatMessageCommunitiesEventFilter);
	end

	-- See FocusCommunityStreams below. The channel list is not complete at
	-- login; streams keep arriving for several seconds. The focus pass
	-- therefore runs again on every channel list update, not just once.
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHANNEL_UI_UPDATE");
	-- Ownership signals: CLUB_STREAMS_LOADED opens the grace period,
	-- CLUB_STREAM_SUBSCRIBED tells the pass it has nothing left to do.
	pcall(self.RegisterEvent, self, "CLUB_STREAMS_LOADED");
	pcall(self.RegisterEvent, self, "CLUB_STREAM_SUBSCRIBED");
	self:FocusCommunityStreams();
end

function Channel:OnDisable()
	if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_CHANNEL', Channel.ChatMessageEventFilter);
		ChatFrameUtil.RemoveMessageEventFilter('CHAT_MSG_COMMUNITIES_CHANNEL', Channel.ChatMessageCommunitiesEventFilter);
	else
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_CHANNEL', Channel.ChatMessageEventFilter);
		_G.ChatFrame_RemoveMessageEventFilter('CHAT_MSG_COMMUNITIES_CHANNEL', Channel.ChatMessageCommunitiesEventFilter);
	end
end

-- While WIM is loaded, the client does not focus community streams at
-- login, and an unfocused stream cannot be sent to. Why WIM's presence
-- changes the client's behavior is unknown: WIM never calls FocusStream,
-- never loads Blizzard_Communities, and declares no dependency on it. So
-- this pass is remediation, not a root-cause fix.
--
-- Verified with controlled logins: with WIM disabled, community sends
-- work immediately after login. With WIM enabled, sends are refused with
-- "Couldn't send message.", including a direct C_Club.SendMessage from a
-- macro, which rules out the send path and WIM's edit-box replacement.
-- With WIM enabled and C_Club.FocusStream called before the first send,
-- the send succeeds and the message also reaches the default chat frame.
--
-- The pass is safe: focusing a stream the client already lists as a
-- numbered chat channel is what the unmodified client does, so this
-- restores the no-addon baseline. It deliberately covers streams WIM
-- does not monitor too, because the client refuses their sends just the
-- same and WIM should not change which channels work.
--
-- Timing matters. Focusing after the club's stream data has loaded makes
-- the send work but stops the client from routing the stream's messages
-- to CHAT_MSG_COMMUNITIES_CHANNEL, so they never reach the default chat
-- frame; repeated captures put the boundary at CLUB_STREAMS_LOADED, with
-- margins of milliseconds deciding the outcome. Waiting for the client's
-- own subscription does not work either: it rarely arrives, and sends
-- issued while waiting are refused. So the rule is: focus as soon as the
-- stream appears in the channel list, and accept losing the default
-- chat frame copy on logins where the channel list populates late. A
-- failed send is worse than a missing copy in a frame this addon exists
-- to replace, and the message always reaches WIM's own window.
local clubStreamsLoaded = {};
local subscribedStreams = {};
local focusedStreams = {};

-- Capability probe, logged once. Recording which functions this client
-- build offers beats guessing at API names; whether a late focus can be
-- repaired depends on what exists here.
local probed = false;
local channelsLogged = false;
local function probeClubCapabilities()
	if (probed) then
		return;
	end
	probed = true;

	local names = {
		"C_Club.FocusStream", "C_Club.UnfocusStream", "C_Club.IsSubscribedToStream",
		"C_Club.GetStreamInfo", "C_Club.GetSubscribedClubs", "C_Club.GetStreams",
		"ChatFrame_AddChannel", "ChatFrame_RemoveChannel",
		"ChatFrame_AddCommunitiesChannel", "ChatFrame_RemoveCommunitiesChannel",
		"ChatFrame_AddNewCommunitiesChannel",
		"ChatFrameUtil.AddChannel", "ChatFrameUtil.RemoveChannel",
		"ChatFrameUtil.AddCommunitiesChannel", "ChatFrameUtil.AddNewCommunitiesChannel",
	};

	local have, missing = {}, {};
	for i = 1, #names do
		local path = names[i];
		local owner, member = string.match(path, "^(.-)%.(.*)$");
		local fn;
		if (owner) then
			local t = _G[owner];
			fn = (type(t) == "table") and t[member] or nil;
		else
			fn = _G[path];
		end
		table.insert((type(fn) == "function") and have or missing, path);
	end

	dPrint("Club API probe -- present: "..(#have > 0 and table.concat(have, ", ") or "(none)"));
	dPrint("Club API probe -- absent:  "..(#missing > 0 and table.concat(missing, ", ") or "(none)"));
end

-- Tested and disproven: unfocus plus re-focus does not recover chat
-- routing. Three late logins ran that repair, every stream reported
-- success, and CHAT_MSG_COMMUNITIES_CHANNEL still never fired. A late
-- focus is not a recoverable state, so that repair was removed.
--
-- The capability probe showed a stronger option on this client:
-- ChatFrame_RemoveCommunitiesChannel and ChatFrame_AddCommunitiesChannel
-- both exist. They mutate the user's chat window configuration, which
-- this addon has never done, so logChatFrameChannels below first checks
-- whether the chat frames' channel lists differ between a late and an
-- early login. If the lists are identical, re-adding the channel cannot
-- be the fix, and the mutation would be pointless risk.
local function logChatFrameChannels(tag)
	for i = 1, (_G.NUM_CHAT_WINDOWS or 10) do
		local frame = _G["ChatFrame"..i];
		local list = frame and frame.channelList;
		if (type(list) == "table" and #list > 0) then
			local parts = {};
			for j = 1, #list do
				parts[#parts + 1] = tostring(list[j]);
			end
			tPrint("ChannelList ["..tag.."] ChatFrame"..i..": "..table.concat(parts, ", "));
		elseif (frame and list == nil and i == 1) then
			tPrint("ChannelList ["..tag.."] ChatFrame1: channelList is nil");
		end
	end
end

-- Opt-in experiment: re-add the community channel to the chat frames.
--
-- The channel-list dumps were byte-identical on late and early logins,
-- so the channel is registered in ChatFrame1 either way and a missing
-- registration is not the explanation. What re-running the add tests is
-- whether it re-wires routing now that the stream is subscribed: the
-- client wires routing when a community channel is added to a frame, and
-- on a late login that add happened while the stream was still
-- unsubscribed.
--
-- Off by default, and it stays off unless the user runs
-- /wim channelrepair. This is the only code in the addon that mutates
-- the user's chat window configuration, that configuration survives
-- logout, and a failed re-add loses the channel from the frame until the
-- user adds it back through the chat settings. That is a real cost, and
-- not one to impose by default.
--
-- Safety: the list is captured before and after, the add is verified,
-- and a fallback implementation is tried before giving up loudly.
local lateFocusHappened = false;
local channelReAddAttempted = false;

local function frameHasChannel(frame, name)
	local list = frame and frame.channelList;
	if (type(list) ~= "table") then
		return false;
	end
	for i = 1, #list do
		if (list[i] == name) then
			return true;
		end
	end
	return false;
end

local function reAddCommunityChannels(force)
	if (channelReAddAttempted or (not lateFocusHappened and not force)) then
		return;
	end
	if (not db or db.chat.community.repairChannelReAdd ~= true) then
		return;
	end

	local add = _G.ChatFrame_AddCommunitiesChannel
	            or (_G.ChatFrameUtil and _G.ChatFrameUtil.AddCommunitiesChannel);
	if (not add) then
		dPrint("Channel re-add: unavailable on this client.");
		channelReAddAttempted = true;
		return;
	end

	local frame = _G.ChatFrame1;
	local list = frame and frame.channelList;
	if (type(list) ~= "table" or #list == 0) then
		return;   -- not populated yet; a later pass will catch it
	end
	channelReAddAttempted = true;

	-- Snapshot the names first: the list is mutated as we go.
	local targets = {};
	for i = 1, #list do
		if (type(list[i]) == "string" and string.match(list[i], "^Community:")) then
			targets[#targets + 1] = list[i];
		end
	end
	if (#targets == 0) then
		return;
	end

	logChatFrameChannels("before re-add");

	-- Signature notes, each learned from a capture:
	--   add(frame, name)                  -> :905 index nil 'channelColor'
	--   add(frame, clubId, streamId)      -> :57  index number 'communityChannel'
	--   add(frame, name, {r=,g=,b=})      -> :905 attempt to call a nil value
	-- The third shows channelColor is a color object with methods, not a
	-- plain table, so it needs CreateColor.
	--
	-- The remove stays. With the remove present, one late login recovered
	-- display; with the add alone, three consecutive late logins did not.
	-- The remove changes nothing in channelList, so its effect is
	-- internal, but the evidence says the remove, not the add, re-wires
	-- routing.
	local remove = _G.ChatFrame_RemoveCommunitiesChannel;

	local function makeColor()
		local info = _G.ChatTypeInfo
		             and (_G.ChatTypeInfo["COMMUNITIES_CHANNEL"] or _G.ChatTypeInfo["CHANNEL"]);
		local r, g, b = 0.75, 0.75, 0.75;
		if (info) then
			r, g, b = info.r or r, info.g or g, info.b or b;
		end
		if (_G.CreateColor) then
			return _G.CreateColor(r, g, b);
		end
		return {r = r, g = g, b = b};
	end
	local color = makeColor();

	for i = 1, #targets do
		local name = targets[i];
		local clubId, streamId = string.match(name, "^Community:(%d+):(%d+)$");
		local cid, sid = tonumber(clubId) or clubId, tonumber(streamId) or streamId;

		if (remove) then
			-- 12.1 note: the (frame, name) form now returns cleanly but
			-- removes nothing, so pcall success proves nothing. Judge each
			-- attempt by whether the channel actually left channelList.
			-- FrameXML declares (chatFrame, clubId, streamId), so that
			-- form goes first.
			local okIds, errIds = pcall(remove, frame, cid, sid);
			local removed = not frameHasChannel(frame, name);
			local report = "(frame, clubId, streamId) "
			               ..(okIds and "OK" or ("failed: "..tostring(errIds)))
			               ..(removed and " -- removed" or " -- still listed");
			if (not removed) then
				local okName, errName = pcall(remove, frame, name);
				removed = not frameHasChannel(frame, name);
				report = report.." | (frame, name) "
				         ..(okName and "OK" or ("failed: "..tostring(errName)))
				         ..(removed and " -- removed" or " -- still listed");
			end
			dPrint("Channel re-add: remove "..name..": "..report);
		end

		-- Add back only if the remove actually took the channel out.
		-- Adding unconditionally duplicates the entry, and the add does
		-- nothing for routing anyway; three late logins with the add alone
		-- all failed to display. This is a safety net, not the mechanism.
		if (not frameHasChannel(frame, name)) then
			-- The name+colour form is the one verified to restore the entry under
			-- 12.1. The ids form is a last resort only: despite matching FrameXML's
			-- declared add signature, in practice it registers a junk channel
			-- literally named "<clubId>".
			local okAdd, errAdd = pcall(add, frame, name, color);
			if (not frameHasChannel(frame, name)) then
				local okIds, errIds = pcall(add, frame, cid, sid);
				errAdd = "(frame, name, color) "
				         ..(okAdd and "OK but not listed" or ("failed: "..tostring(errAdd)))
				         .." | (frame, clubId, streamId) "
				         ..(okIds and "OK but not listed" or ("failed: "..tostring(errIds)));
			end
			-- Strip the junk numeric entry if either attempt left one behind.
			if (_G.ChatFrame_RemoveChannel and frameHasChannel(frame, tostring(cid))) then
				pcall(_G.ChatFrame_RemoveChannel, frame, tostring(cid));
				dPrint("Channel re-add: stripped junk channel entry '"..tostring(cid).."'.");
			end
			if (frameHasChannel(frame, name)) then
				dPrint("Channel re-add: "..name.." was removed and has been restored.");
			else
				dPrint("Channel re-add: "..name.." was removed and could NOT be restored: "
				       ..tostring(errAdd).." -- re-add it from the chat settings UI and run "
				       .."/wim channelrepair to disable this.");
			end
		else
			dPrint("Channel re-add: "..name.." still listed after remove; nothing to restore.");
		end
	end
	logChatFrameChannels("after re-add");
end

-- CLUB_STREAM_SUBSCRIBED can fire before WIM loads, so the event table
-- alone is not authoritative. Ask the client first where the query API
-- exists.
local function isStreamSubscribed(clubId, streamId)
	if (subscribedStreams[clubId..":"..streamId]) then
		return true;
	end
	if (_G.C_Club and _G.C_Club.IsSubscribedToStream) then
		local ok, subscribed = pcall(_G.C_Club.IsSubscribedToStream,
		                             tonumber(clubId) or clubId,
		                             tonumber(streamId) or streamId);
		return ok and subscribed or false;
	end
	return false;
end

-- Polls for the chat frames' channel lists becoming readable, then runs the
-- repair once. Falls back to a single delayed attempt where NewTicker is absent.
local reAddTicker;
local function startReAddPolling()
	if (not _G.C_Timer) then
		return;
	end
	if (not _G.C_Timer.NewTicker) then
		if (_G.C_Timer.After) then
			_G.C_Timer.After(8, function() reAddCommunityChannels(); end);
		end
		return;
	end
	if (reAddTicker) then
		return;
	end

	-- 0.25s for up to 15s. The list has populated within ~10s in every capture.
	local ticks = 0;
	reAddTicker = _G.C_Timer.NewTicker(0.25, function(self)
		ticks = ticks + 1;
		reAddCommunityChannels();
		if (channelReAddAttempted or ticks >= 60) then
			if (not channelReAddAttempted) then
				dPrint("Channel re-add: gave up waiting for the channel list to populate.");
			end
			self:Cancel();
			reAddTicker = nil;
		end
	end);
end

-- Manual trigger for /wim channelrepair, so the call signature can be
-- tested without waiting for a late-focus login. Safe on a healthy login
-- too: the add only runs after a successful remove, so a rejected call
-- changes nothing.
function TryCommunityChannelReAdd()
	channelReAddAttempted = false;
	reAddCommunityChannels(true);
end

function Channel:FocusCommunityStreams()
	if (not _G.C_Club or not _G.C_Club.FocusStream or not _G.GetChannelList) then
		return;
	end
	if (db and db.chat.community.autoFocusStreams == false) then
		return;
	end

	probeClubCapabilities();

	-- Snapshot now and again once login has settled, so a late login and an early
	-- one can be compared directly.
	if ((debugLevel or 0) >= 2 and not channelsLogged) then
		channelsLogged = true;
		logChatFrameChannels("focus pass");
		if (_G.C_Timer and _G.C_Timer.After) then
			_G.C_Timer.After(10, function() logChatFrameChannels("+10s"); end);
		end
	end

	local channels = {_G.GetChannelList()};
	for i = 1, #channels, 3 do
		local name, disabled = channels[i+1], channels[i+2];
		if (not disabled and type(name) == "string" and not focusedStreams[name]) then
			local clubId, streamId = string.match(name, "^Community:(%d+):(%d+)$");
			if (clubId and isStreamSubscribed(clubId, streamId)) then
				-- Already subscribed, so sending works. Marked so later passes do
				-- not reconsider it.
				focusedStreams[name] = true;
				dPrint("Left "..name.." to the client - already subscribed.");
			elseif (clubId) then
				-- pcall: FocusStream errors if the club or stream is not
				-- subscribed yet, which is normal while the club list is still
				-- syncing. Leaving the entry unmarked lets a later pass retry.
				local ok = pcall(_G.C_Club.FocusStream,
				                 tonumber(clubId) or clubId,
				                 tonumber(streamId) or streamId);
				if (ok) then
					focusedStreams[name] = true;
					if (clubStreamsLoaded[clubId]) then
						dPrint("Focused community stream "..name.." (late - stream data already "
						       .."loaded, so the default chat frame may not show it)");
						lateFocusHappened = true;
						-- Run the repair as soon as the channel list is readable rather
						-- than on a fixed delay. The lists are still empty during the
						-- focus pass, but every second spent waiting is a second of
						-- community traffic missing from the default chat frame, which
						-- matters on a busy community. A ticker polls until the list
						-- populates; reAddCommunityChannels is a no-op until then and
						-- marks itself done once it runs.
						startReAddPolling();
					else
						dPrint("Focused community stream "..name);
					end
				end
			end
		end
	end
end

-- Recorded even when auto-focus is off, so a capture still shows the client's
-- own subscription sequence for comparison.
function Channel:CLUB_STREAMS_LOADED(clubId)
	if (clubId == nil) then
		return;
	end
	clubStreamsLoaded[tostring(clubId)] = true;
end

function Channel:CLUB_STREAM_SUBSCRIBED(clubId, streamId)
	if (clubId ~= nil and streamId ~= nil) then
		subscribedStreams[tostring(clubId)..":"..tostring(streamId)] = true;
	end
end

function Channel:PLAYER_ENTERING_WORLD()
	self:FocusCommunityStreams();
end

function Channel:CHANNEL_UI_UPDATE()
	self:FocusCommunityStreams();
end

-- NOTE: this must remain Channel's ONLY OnWindowDestroyed. A second
-- definition later in the file would silently replace this one, and then
-- Windows[] entries would never be cleared: a closed channel/community
-- window's corpse would stay in the table, getChatWindow would keep
-- returning it, and the next message would go into an invisible pooled
-- frame instead of a fresh window.
function Channel:OnWindowDestroyed(win)
    if(win.type == "chat" and (win.chatType == "channel" or win.chatType == "community")) then
        win.chatType = nil;
        win.unreadCount = nil;
        win.chatLoaded = nil;
        win.channelNumber = nil;
        win.channelSpecial = nil;
        win.clubId = nil;
        win.streamId = nil;
        cleanChatList(win);
        -- Community windows are keyed by win.user (the clubId:streamId key)
        -- while theUser holds the renamed display name, so remove by object
        -- identity rather than trusting either field.
        for key, obj in pairs(Windows) do
            if (obj == win) then
                Windows[key] = nil;
            end
        end
    end
end


Channel.waitingList = {};
--GetChannelRosterInfo(id, rosterIndex)

local function loadChatList(win, ...)
    cleanChatList(win);
    for i=1, select("#", ...) do
        table.insert(win.chatList, string.trim(select(i, ...)));
    end
end

local function updateJoinLeave(event, ...)
    local arg1, who, arg3, channelIdentifier, arg5, arg6, arg7, channelNumber, arg9 = ...;
    for _, win in pairs(Windows) do
        if(win.channelIdentifier == channelIdentifier) then
            win.widgets.chat_info:SetText(GetChannelCount(win.channelNumber));
            local color = _G.ChatTypeInfo["CHANNEL"..channelNumber] or _G.NORMAL_FONT_COLOR;
            win:AddEventMessage(color.r, color.g, color.b, event, ...);
            return;
        end
    end
end

function Channel:CHAT_MSG_CHANNEL_JOIN(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_CHANNEL_JOIN", ...);
		return;
	end

    local arg1, who, arg3, channelIdentifier, arg5, arg6, arg7, channelNumber, arg9 = ...;

    updateJoinLeave("CHAT_MSG_CHANNEL_JOIN", ...)
end

function Channel:CHAT_MSG_CHANNEL_LEAVE(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_CHANNEL_LEAVE", ...);
		return;
	end

    local arg1, who, arg3, channelIdentifier, arg5, arg6, arg7, channelNumber, arg9 = ...;

    updateJoinLeave("CHAT_MSG_CHANNEL_LEAVE", ...)
end

-- True when `name` refers to a Community (Club) stream rather than an ordinary
-- numbered channel, in any of the forms the client uses for it.
local function isCommunityChannelName(name)
	if (type(name) ~= "string" or name == "") then
		return false;
	end
	if (string.find(name, "^Community:") or string.find(name, "^%d+:%d+$")) then
		return true;
	end
	if (_G.ChatFrameUtil and _G.ChatFrameUtil.GetCommunityAndStreamFromChannel) then
		local ok, foundClubId = pcall(_G.ChatFrameUtil.GetCommunityAndStreamFromChannel, name);
		if (ok and foundClubId) then
			return true;
		end
	end
	return false;
end

function Channel:CHAT_MSG_CHANNEL_NOTICE(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_CHANNEL_NOTICE", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;

    for _, win in pairs(Windows) do
        if(win.channelIdentifier == arg4) then
            local color = _G.ChatTypeInfo["CHANNEL"..arg8] or _G.NORMAL_FONT_COLOR;
            win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_CHANNEL_NOTICE", ...);
            return;
        end
    end
    -- create new window if arg1 is YOU_JOINED
    if(arg1 == "YOU_JOINED") then
        -- ...but NOT for community streams.
        --
        -- WARNING: this guard does NOT fix the "Couldn't send message" bug, and
        -- an earlier version of this comment wrongly claimed it did. Keep that
        -- straight, because the wrong story here has already cost one round of
        -- investigation.
        --
        -- The theory was: community channels also announce themselves with
        -- YOU_JOINED, and only at LOGIN (on /reload you are already joined and
        -- no notice fires), so synthesizing a CHAT_MSG_CHANNEL here would claim
        -- the stream as a plain "channel" window with no clubId/streamId, and
        -- sending with /<number> would then take the channel route instead of
        -- C_Club.SendMessage. It fit the login-only symptom exactly.
        --
        -- It is WRONG. Channel:CHAT_MSG_CHANNEL returns early unless the channel
        -- is monitored under db.chat.world or db.chat.custom, and a community
        -- lives in db.chat.community -- so the synthesized call bailed before
        -- claiming anything. Confirmed empirically: with this guard in place the
        -- send still failed. The guard is a NO-OP for that bug.
        --
        -- It is kept only because misclassifying a community stream as a
        -- numbered channel would be wrong regardless. Community streams are
        -- handled by CLUB_MESSAGE_ADDED and the "community" chat type, which
        -- carry the club and stream IDs, so skipping them here loses nothing.
        --
        -- Note that disabling community chat can disable this whole module
        -- via Channel:SettingsChanged(), which takes CHAT_MSG_CHANNEL_NOTICE
        -- with it -- so a test that "fixes" a community symptom by turning
        -- community off does not implicate community code.
        -- The exact shape of the channel name here is not documented and
        -- differs between the internal name ("Community:<club>:<stream>"), the
        -- settings key ("<club>:<stream>") and the display name
        -- ("hotjh - epic people"), so test all three forms and finally ask
        -- Blizzard directly. dPrint the values so a miss can be diagnosed from
        -- a debug log rather than guessed at.
        dPrint("YOU_JOINED: arg4='"..tostring(arg4).."' arg9='"..tostring(arg9).."'");
        local isCommunityStream = isCommunityChannelName(arg4)
                                  or isCommunityChannelName(arg9);
        if (not isCommunityStream) then
            -- open window.
            Channel:CHAT_MSG_CHANNEL("", "", nil, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
        end
    end
end

function Channel:CHAT_MSG_CHANNEL_NOTICE_USER(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_CHANNEL_NOTICE_USER", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;

    for _, win in pairs(Windows) do
        if(win.channelIdentifier == arg4) then
            local color = _G.ChatTypeInfo["CHANNEL"..arg8] or _G.NORMAL_FONT_COLOR;
            win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_CHANNEL_NOTICE_USER", ...);
            return;
        end
    end
end

function Channel:OnWindowShow(win)
    if(win.type == "chat" and win.chatType == "channel") then
        win.widgets.chat_info:SetText(GetChannelCount(win.channelNumber));
	elseif (win.type == "chat" and win.chatType == "community") then
		win.widgets.chat_info:SetText(#GetClubStreamMembers(win.clubId, win.streamId));
    end
end

-- (Channel:OnWindowDestroyed lives next to the other window callbacks above;
-- do not re-declare it here -- a second declaration replaces the first.)

-- manage suppression
function Channel.ChatMessageEventFilter (frame, event, ...)
	-- check if message or sender is secret, if so, do not process
	if HasAnySecretValues(...) or not db or not db.enabled then
		return false
	end

	local ignore, block = (IgnoreOrBlockEvent or function () end)(event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = ...

	-- arg7 Generic Channels (1 for General, 2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 26 for LFG)
    -- arg8 Channel Number
    -- arg9 Channel Name

	if (not frame._isWIM and not ignore and not block) then
		local isWorld = arg7 and arg7 > 0;
		local channelName = string.split("-", arg9:gsub(' ', ''));
		local neverSuppress = db.chat[isWorld and "world" or "custom"].channelSettings[channelName] and db.chat[isWorld and "world" or "custom"].channelSettings[channelName].neverSuppress;

		--check options. do we want the specified channels.
		if(isWorld and not db.chat.world.enabled) then
			-- deliver normally
		elseif(not isWorld and not db.chat.custom.enabled) then
			-- deliver normally
		elseif(not neverSuppress and getRuleSet().supress and db.chat[isWorld and "world" or "custom"].channelSettings[channelName] and db.chat[isWorld and "world" or "custom"].channelSettings[channelName].monitor) then
			return true
		end
	elseif (frame._isWIM and ignore or block) then
		return true
	end

	return false
end

-- Community messages are handled a little bit different so we will have a separate filter for them.
function Channel.ChatMessageCommunitiesEventFilter (frame, event, ...)
	-- Announced before the enabled check so a debug capture can tell "the filter
	-- never ran at all" apart from "the filter ran and bailed here" -- two
	-- states that are otherwise indistinguishable from the chat frame alone.
	if (not db or not db.chat.community.enabled) then
		dPrint("CommunitiesFilter: entered, community chat disabled -> delivered");
		return
	end

	local name = select(9, ...):gsub('Community:', '');

	local settings = db.chat.community.channelSettings[name];
	local neverSuppress = settings and settings.neverSuppress;

	local suppress = (not neverSuppress and getRuleSet().supress
	                  and settings and settings.monitor) and true or false;

	-- Whether a community message reaches the default chat frame has been
	-- reported as intermittent across logins. Two inputs can vary and this
	-- announces both, because neither has ever been captured:
	--
	--   * arg9's real shape. The settings table is keyed "<clubId>:<streamId>"
	--     (see getCommunityGroupList) and this filter derives its key by
	--     stripping "Community:" from arg9. If arg9 is ever anything else --
	--     a friendly name, say -- the lookup misses, `settings` is nil, and the
	--     user's per-channel "never suppress" tick is read from a key that does
	--     not exist. "settings=nil" below is that failure, and it is silent.
	--   * getRuleSet().supress is per player state (resting/combat/pvp/arena),
	--     so the same message can be suppressed in an inn and delivered in the
	--     open world. That alone can look like a race.
	--
	-- A filter runs once per registered chat frame, which on a default UI means
	-- ten identical lines for one message. At level 1 only an actual suppression
	-- is announced, that being the interesting case; level 2 records every
	-- frame's decision and names the frame, so it is visible which frames are
	-- consuming the event at all.
	if (suppress or (debugLevel or 0) >= 2) then
		dPrint("CommunitiesFilter["..tostring(frame and frame.GetName and frame:GetName() or "?")
		       .."]: arg9='"..tostring(select(9, ...)).."' key='"..tostring(name)
		       .."' settings="..(settings and "found" or "nil")
		       .." neverSuppress="..tostring(neverSuppress)
		       .." monitor="..tostring(settings and settings.monitor)
		       .." state="..tostring(curState)
		       .." ruleSupress="..tostring(getRuleSet().supress)
		       .." -> "..(suppress and "SUPPRESSED" or "delivered"));
	end

	if (suppress) then
		return true
	end

	return
end

function Channel:CLUB_MESSAGE_ADDED(clubId, streamId, messageId)
	-- if not enabled, do nothing
	local name = clubId .. ":" .. streamId;
	if (not db or not db.chat.community.enabled or not db.chat.community.channelSettings[name] or not db.chat.community.channelSettings[name].monitor) then
		return
	end

	local message = _G.C_Club.GetMessageInfo(clubId, streamId, messageId);
	local author = message and message.author or {};
	local fromSelf = author.isSelf;

	-- Ambiguate() errors on a nil argument, and a club message's author name is
	-- not always present: the client withholds it the same way it withholds the
	-- message body (see the protected-string handling in Modules/History.lua),
	-- and message.author is then a table with no `name` at all. Without this
	-- guard the whole handler dies, which is why no WIM window appeared for the
	-- message even though the send itself had succeeded.
	-- Tested with type() rather than truthiness: Ambiguate errors on ANY
	-- non-string, and on a 12.x client a withheld name can arrive as a truthy
	-- non-string (the same withholding that turns content into a |K..|k token).
	local from;
	if (type(author.name) == "string") then
		from = _G.Ambiguate(author.name, "none");
	elseif (fromSelf) then
		from = _G.UnitName("player");
	else
		from = _G.UNKNOWN or "Unknown";
	end
	local fromBNetID = author.bnetAccountId;
	local content = message and message.content;

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = content, from, fromSelf, name, nil, nil, nil, nil, name, nil, nil;

	local win, isNew = getChatWindow(name, "community");

	if (isNew) then
		win.user = name;
		win.clubId = clubId;
		win.streamId = streamId;

		win:UpdateIcon();

		-- UpdateIcon resolves theUser to "Community - Stream", but at window
		-- creation the client often has no name to give yet, and nothing else
		-- re-runs the resolution until the window is first opened (the skin
		-- pass) -- so the shortcut list shows the raw clubId:streamId key.
		-- Retry until it resolves or we give up.
		if (win.theUser == name and _G.C_Timer and _G.C_Timer.NewTicker) then
			local tries = 0;
			_G.C_Timer.NewTicker(1, function(self)
				tries = tries + 1;
				local stillOurs = (Windows[name] == win and win.chatType == "community");
				if (stillOurs and win.theUser == name) then
					win:UpdateIcon();
				end
				if (not stillOurs or win.theUser ~= name or tries >= 15) then
					self:Cancel();
				end
			end);
		end
	end

	local r, g, b = ChatFrameUtil.GetCommunitiesChannelColor(clubId, streamId)
	local color = { r = r, g = g, b = b };

	local neverPop = db.chat.community.channelSettings[name] and db.chat.community.channelSettings[name].neverPop;

	win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_CHANNEL", arg1, arg2, arg3);

	if(not fromSelf) then
		win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
		if(not neverPop) then
			win:Pop("in");
		end
	else
		if(not neverPop) then
			win:Pop("out");
		end
	end

	CallModuleFunction("PostEvent_ChatMessage", "CLUB_MESSAGE_ADDED", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
end

function Channel:CHAT_MSG_CHANNEL(...)
	if HasAnySecretValues(...) then
		self:DeferEvent("CHAT_MSG_CHANNEL", ...);
		return;
	end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;

	-- arg7 Generic Channels (1 for General, 2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 26 for LFG)
    -- arg8 Channel Number
    -- arg9 Channel Name

    local isWorld = arg7 and arg7 > 0;
    local channelName = string.split("-", arg9:gsub(' ', ''));

    --check options. do we want the specified channels.
    if(isWorld and not db.chat.world.enabled) then
        return;
    elseif(not isWorld and not db.chat.custom.enabled) then
        return;
    elseif(not db.chat[isWorld and "world" or "custom"].channelSettings[channelName] or not db.chat[isWorld and "world" or "custom"].channelSettings[channelName].monitor) then
		return;
    end

	arg2 = _G.Ambiguate(arg2, "none")

	local win, isNew = getChatWindow(channelName, "channel");

	local filter, _;
	filter, arg1, _, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = processMessageEventFilters(win, 'CHAT_MSG_CHANNEL', ...);
	if (filter) then
		if (isNew) then
			win:close();
		end
		return true;
	end

    local color = _G.ChatTypeInfo["CHANNEL"..arg8] or _G.NORMAL_FONT_COLOR;

    if(arg7 == 1 or arg7 == 2 or arg7 == 22 or arg7 == 23 or arg7 == 26) then
        win.widgets.char_info:SetText(arg9);
        win.channelSpecial = _G.time();
    else
        win.widgets.char_info:SetText("");
    end

    win.channelNumber = arg8;
    win.channelIdentifier = arg4;
    if(win:IsVisible()) then
        win.widgets.chat_info:SetText(GetChannelCount(win.channelNumber));
    end

    self.chatLoaded = true;
    if(arg1 and _G.strlen(arg1) > 0) then
        arg3 = CleanLanguageArg(arg3);
        win:AddEventMessage(color.r, color.g, color.b, "CHAT_MSG_CHANNEL", arg1, arg2, arg3, select(4, ...));
        local neverPop = db.chat[isWorld and "world" or "custom"].channelSettings[channelName] and db.chat[isWorld and "world" or "custom"].channelSettings[channelName].neverPop;
        if(arg2 ~= _G.UnitName("player")) then
            win.unreadCount = win.unreadCount and (win.unreadCount + 1) or 1;
            if(not neverPop) then
                win:Pop("in");
            end
        else
            if(not neverPop) then
                win:Pop("out");
            end
        end

        CallModuleFunction("PostEvent_ChatMessage", "CHAT_MSG_CHANNEL", ...);
    end
end

function Channel:SettingsChanged()
    if(db.chat.world.enabled or db.chat.custom.enabled or db.chat.community.enabled) then
        self:Enable();
    else
        self:Disable();
    end
end





-- alert management
local ChatAlerts = CreateModule("ChatAlerts");
function ChatAlerts:OnWindowShow(win)
    if(win.type == "chat") then
        MinimapPopAlert(win.theUser);
    end
end
ChatAlerts.OnWindowDestroyed = ChatAlerts.OnWindowShow;


function ChatAlerts:PostEvent_ChatMessage(event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;
    if(arg2 == _G.UnitName("player")) then
        return; -- we don't count our own messages as new.
    end
    event = event:gsub("CHAT_MSG_", "");
    if(event == "CHANNEL") then
        local isWorld = arg7 and arg7 > 0;
        local channelName = string.split("-", arg9:gsub(' ', ''));
        local win = getChatWindow(channelName, "channel");
        local showAlert = db.chat[isWorld and "world" or "custom"].channelSettings[channelName] and db.chat[isWorld and "world" or "custom"].channelSettings[channelName].showAlerts;
        if(showAlert and win and not win:IsVisible() and win.unreadCount) then
            local color = _G.ChatTypeInfo["CHANNEL"..arg8] or _G.NORMAL_FONT_COLOR;
            MinimapPushAlert(win.theUser, RGBPercentToHex(color.r, color.g, color.b), win.unreadCount);
        end
	elseif(event == "CLUB_MESSAGE_ADDED") then
		if (arg3) then
			return; -- we don't count our own messages as new.
		end
		-- alert support
		local name = arg9;
		local showAlert = db.chat.community.channelSettings[name] and db.chat.community.channelSettings[name].showAlerts;
		local win = getChatWindow(name, "community");

		if (not win) then
			return;
		end

		local r, g, b = _G.ChatFrameUtil.GetCommunitiesChannelColor(win.clubId, win.streamId)
		local color = { r = r, g = g, b = b };

		if(showAlert and not win:IsVisible() and win.unreadCount) then
			MinimapPushAlert(win.theUser, RGBPercentToHex(color.r, color.g, color.b), win.unreadCount);
		end
    else
        local win;
        if(event == "GUILD" and db.chat.guild.showAlerts) then
            win = getChatWindow(_G.GUILD, "guild");
        elseif(event == "OFFICER" and db.chat.officer.showAlerts) then
            win = getChatWindow(_G.GUILD_RANK1_DESC, "officer");
        elseif(event == "PARTY" and db.chat.party.showAlerts) then
            win = getChatWindow(_G.PARTY, "party");
        elseif((event == "RAID" or event == "RAID_LEADER") and db.chat.raid.showAlerts) then
            win = getChatWindow(_G.RAID, "raid");
        elseif((event == "INSTANCE_CHAT" or event == "INSTANCE_CHAT_LEADER") and db.chat.battleground.showAlerts) then
            win = getChatWindow(_G.INSTANCE_CHAT, "battleground");
        elseif(event == "SAY" and db.chat.say.showAlerts) then
            win = getChatWindow(_G.SAY, "say");
        end

        if(win and not win:IsVisible() and win.unreadCount and win.unreadCount > 0) then
            local chat_type = win.chatType == "battleground" and "INSTANCE_CHAT" or string.upper(win.chatType);
            local color = _G.ChatTypeInfo[chat_type] or _G.NORMAL_FONT_COLOR; -- Drii: ticket 344 color error if party/instance chat handled by WIM
            MinimapPushAlert(win.theUser, RGBPercentToHex(color.r, color.g, color.b), win.unreadCount);
        end
    end
end

-- should never be disabled.
ChatAlerts.canDisable = false;
ChatAlerts:Enable();



-- Options
-- create ChatOptions Module
local ChatOptions = CreateModule("ChatOptions");
local function loadChatOptions()

    local desc = L["WIM will manage this chat type within its own message windows."];

    -- standard chat template
    local function createChatTemplate(chatName, moduleName, chatType)
        local chatDB = db.chat[chatType];
        local f = options.CreateOptionsFrame();
        f.sub = f:CreateSection(chatName, desc);
        f.sub.nextOffSetY = -10;
        f.sub:CreateCheckButton(L["Enable"], WIM.modules[moduleName], "enabled", nil, function(self, button) EnableModule(moduleName, self:GetChecked()); end);
		f.sub.nextOffSetY = -30;
        f.sub:CreateCheckButton(L["Show Minimap Alerts"], chatDB, "showAlerts");
		f.sub.nextOffSetY = -25;
		if chatType == 'say' then
			f.sub.nextOffSetY = -25;
			f.sub:CreateCheckButton(L["Include emotes."], chatDB, "showEmotes");
		end
        f.sub:CreateCheckButton(L["Never pop-up on my screen."], chatDB, "neverPop");
        f.sub:CreateCheckButton(L["Never suppress messages."], chatDB, "neverSuppress");
        return f;
    end

    local channelList = {};
    local function getChannelList(world)
        --clear list
        for k, _ in pairs (channelList) do
            channelList[k] = nil;
        end
        for i=1, 20 do
            local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = _G.GetChannelDisplayInfo(i);
            if((world and category == "CHANNEL_CATEGORY_WORLD") or (not world and category == "CHANNEL_CATEGORY_CUSTOM")) then
                if (not header) then
                    table.insert(channelList, name.."*"..(active and "1" or "0").."*"..(channelNumber or "0"));
                end
            end
        end
        return channelList;
    end

	local function getCommunityGroupList()
		--clear list
        for k, _ in pairs (channelList) do
            channelList[k] = nil;
        end

		-- create a map to get channel numbers for community channels
		local channels = {_G.GetChannelList()}
		local channelMap = {};
		for i = 1, #channels, 3 do
			local id, name, disabled = channels[i], channels[i+1], channels[i+2]
			if not disabled then
				channelMap[name] = id
			end
		end

		local clubs = _G.C_Club.GetSubscribedClubs();

		for _, clubInfo in pairs(clubs) do
			local clubId = clubInfo.clubId;
			local clubName = clubInfo.name;
			local streams = _G.C_Club.GetStreams(clubInfo.clubId);
			for _, streamInfo in pairs(streams) do
				local streamId = streamInfo.streamId;
				local streamName = streamInfo.name;
				local channelNumber = nil;
				-- Include General as well as Other. Filtering to Other alone
				-- excluded every community's MAIN channel -- General is the
				-- default stream every community is created with, and many have
				-- no other -- so the settings list came up empty and there was
				-- no way to enable monitoring for them.
				--
				-- Guild and Officer streams stay excluded: WIM handles guild and
				-- officer chat through its own modules, and listing them here
				-- would give two competing sets of settings for one channel.
				local streamType = streamInfo.streamType;
				local clubStream = _G.Enum and _G.Enum.ClubStreamType;
				local isGuildStream = clubStream
				                      and (streamType == clubStream.Guild
				                           or streamType == clubStream.Officer);
				if (not isGuildStream) then
					channelNumber = channelMap["Community:"..clubId..":"..streamId];
					local active = "1";
					table.insert(channelList, clubId..":"..streamId.."*"..active.."*"..(channelNumber or "0"));
				end
			end
		end

		return channelList;
	end


    local channelScrollCount = 1;
    local function createChannelChatTemplate(chatName, channelType, channelListFun)
        local f = options.CreateOptionsFrame();
        f.sub = f:CreateSection(chatName, desc);
        f.sub.nextOffSetY = -10;
        f.sub.enabled = f.sub:CreateCheckButton(L["Enable"], db.chat[channelType], "enabled", nil, function(self, button) Channel:SettingsChanged(); end);
        f.sub.nextOffSetY = -10;

        --list
        f.sub.list = f.sub:ImportCustomObject(_G.CreateFrame("Frame"));
        options.AddFramedBackdrop(f.sub.list);
        f.sub.list:SetFullSize();
        f.sub.list.buttonHeight = 80;
        f.sub.list:SetHeight(4 * f.sub.list.buttonHeight);
        f.sub.list.scroll = _G.CreateFrame("ScrollFrame", f.sub:GetName().."ChannelScroll"..channelScrollCount, f.sub.list, "FauxScrollFrameTemplate");
        channelScrollCount = channelScrollCount + 1;
        f.sub.list.scroll:SetPoint("TOPLEFT", 0, -1);
        f.sub.list.scroll:SetPoint("BOTTOMRIGHT", -23, 0);
        f.sub.list.scroll.update = function(self)
            local channelList = channelListFun();
            local offset = _G.FauxScrollFrame_GetOffset(self);
            for i=1, #f.sub.list.buttons do
                local index = i+offset;
                if(index <= #channelList) then
                    local name, active, channelNumber = string.split("*", channelList[index]);
					local nameText = name;
					local isCommunityChannel = name:find("%d+:%d+");

					-- format if stream or community channel
					if (isCommunityChannel and _G.ChatFrameUtil and _G.ChatFrameUtil.ResolveChannelName) then
						nameText = _G.ChatFrameUtil.ResolveChannelName(name);
					end

                    active = active == "1";
                    f.sub.list.buttons[i]:Show();
                    f.sub.list.buttons[i].channelName = name;
                    if(not db.chat[channelType].channelSettings[name]) then
                        db.chat[channelType].channelSettings[name] = {};
                    end

					local channelNumberText = "";
					if (channelNumber and channelNumber ~= "0") then
						channelNumberText = "|cffffffff"..channelNumber..". |r"
					end

                    f.sub.list.buttons[i].title:SetText(channelNumberText..nameText);
                    f.sub.list.buttons[i].cb1:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].monitor);
                    f.sub.list.buttons[i].neverPop:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].neverPop);
                    f.sub.list.buttons[i].neverSuppress:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].neverSuppress);
                    f.sub.list.buttons[i].showAlerts:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].showAlerts);
                    f.sub.list.buttons[i].noHistory:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].noHistory);
                    f.sub.list.buttons[i].noSound:SetChecked(db.chat[channelType].channelSettings[name] and db.chat[channelType].channelSettings[name].noSound);
                    local color = _G.ChatTypeInfo["CHANNEL"..channelNumber] or _G.NORMAL_FONT_COLOR;

					if (isCommunityChannel) then
						local clubId, streamId = ChatFrameUtil.GetCommunityAndStreamFromChannel(name);
						local r, g, b = ChatFrameUtil.GetCommunitiesChannelColor(clubId, streamId)
						color = { r = r, g = g, b = b };
					end
					-- "No History" is force-ticked and greyed out for community
					-- channels: Community chat cannot be recorded (the client
					-- only ever hands addons a protected-string token, never the
					-- text -- see the CLUB_MESSAGE_ADDED branch in
					-- Modules/History.lua), so a live control would be a lie.
					if (channelType == "community") then
						f.sub.list.buttons[i].noHistory:SetChecked(true);
						f.sub.list.buttons[i].noHistory:Disable();
						f.sub.list.buttons[i].noHistory:SetAlpha(.5);
					else
						f.sub.list.buttons[i].noHistory:Enable();
						f.sub.list.buttons[i].noHistory:SetAlpha(1);
					end

                    f.sub.list.buttons[i].title:SetTextColor(color.r, color.g, color.b);
                    if(active) then
                        f.sub.list.buttons[i].title:SetAlpha(1);
                    else
                        f.sub.list.buttons[i].title:SetAlpha(.4);
                    end
                else
                    f.sub.list.buttons[i]:Hide();
                end
            end
            _G.FauxScrollFrame_Update(self, #channelList, #f.sub.list.buttons, f.sub.list.buttonHeight);
        end
        f.sub.list.scroll:SetScript("OnVerticalScroll", function(self, offset)
            _G.FauxScrollFrame_OnVerticalScroll(self, offset, f.sub.list.buttonHeight, f.sub.list.scroll.update);
        end);
        f.sub.list:SetScript("OnShow", function(self)
            self.scroll:update();
        end);
        f.sub.list.createButton = function(self)
            self.buttons = self.buttons or {};
            local button = _G.CreateFrame("Button", nil, self);
            button:SetHeight(self.buttonHeight);
            --button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
            button.bg = button:CreateTexture(nil, "BACKGROUND");
            button.bg:SetAllPoints();
            button.bg:SetColorTexture(1,1,1, ((#self.buttons+1) % 2)*.1);
			button.bg:SetGradient("HORIZONTAL",
				{ r = 1, g = 1, b = 1, a = 1 },
				{ r = 0, g = 0, b = 0, a = 0 }
			);
            button.border = {};

            button.border.left = button:CreateTexture(nil, "OVERLAY");
            button.border.left:SetPoint("TOPLEFT");
            button.border.left:SetPoint("BOTTOMLEFT");
            button.border.left:SetWidth(4);
            button.border.left:SetColorTexture(1,1,1,.5);

            button.title = button:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.title:SetPoint("TOPLEFT", 35, -8);
            button.title:SetPoint("TOPRIGHT");
            button.title:SetJustifyH("LEFT")
            local font, height, flags = button.title:GetFont();
            button.title:SetFont(font, 14, flags);
            button.title:SetTextColor(_G.GameFontNormal:GetTextColor());
            button.title:SetText("Test");
            --monitor checkbox
            button.cb1 = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.cb1:SetPoint("RIGHT", button.title, "LEFT", -5, 0);
            button.cb1:SetScale(.75);
            button.cb1:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Have WIM monitor this channel."]);
            end);
            button.cb1:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);
            button.cb1:SetScript("OnClick", function(self)
                local name = self:GetParent().channelName;
                db.chat[channelType].channelSettings[name].monitor = self:GetChecked();
            end);

            -- Never Pop
            button.neverPop = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.neverPop:SetPoint("TOPLEFT", button.cb1, "BOTTOMRIGHT", 20, 0);
            button.neverPop:SetScale(.75);
            button.neverPop.text = button.neverPop:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.neverPop.text:SetPoint("LEFT", button.neverPop, "RIGHT", 0, 0);
            button.neverPop.text:SetText(L["Never Pop"]);
            button.neverPop:SetScript("OnClick", function(self)
                    local name = self:GetParent().channelName;
                    db.chat[channelType].channelSettings[name].neverPop = self:GetChecked();
            end)
            button.neverPop:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Never have this window pop-up on my screen."]);
            end);
            button.neverPop:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);

            -- Never Suppress
            button.neverSuppress = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.neverSuppress:SetPoint("TOPLEFT", button.neverPop, "BOTTOMLEFT", 0, 0);
            button.neverSuppress:SetScale(.75);
            button.neverSuppress.text = button.neverSuppress:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.neverSuppress.text:SetPoint("LEFT", button.neverSuppress, "RIGHT", 0, 0);
            button.neverSuppress.text:SetText(L["Never Suppress"]);
            button.neverSuppress:SetScript("OnClick", function(self)
                    local name = self:GetParent().channelName;
                    db.chat[channelType].channelSettings[name].neverSuppress = self:GetChecked();
            end)
            button.neverSuppress:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Never suppress messages from the default chat frame."]);
            end);
            button.neverSuppress:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);


            -- Show Minimap Alerts
            button.showAlerts = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.showAlerts:SetPoint("TOPLEFT", button.neverPop, "TOPRIGHT", 150, 0);
            button.showAlerts:SetScale(.75);
            button.showAlerts.text = button.showAlerts:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.showAlerts.text:SetPoint("LEFT", button.showAlerts, "RIGHT", 0, 0);
            button.showAlerts.text:SetText(L["Show Minimap Alerts"]);
            button.showAlerts:SetScript("OnClick", function(self)
                    local name = self:GetParent().channelName;
                    db.chat[channelType].channelSettings[name].showAlerts = self:GetChecked();
            end)
            button.showAlerts:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Show unread message alert on minimap."]);
            end);
            button.showAlerts:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);

            -- Don't record history
            button.noHistory = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.noHistory:SetPoint("TOPLEFT", button.showAlerts, "BOTTOMLEFT", 0, 0);
            button.noHistory:SetScale(.75);
            button.noHistory.text = button.noHistory:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.noHistory.text:SetPoint("LEFT", button.noHistory, "RIGHT", 0, 0);
            button.noHistory.text:SetText(L["No History"]);
            button.noHistory:SetScript("OnClick", function(self)
                    local name = self:GetParent().channelName;
                    db.chat[channelType].channelSettings[name].noHistory = self:GetChecked();
            end)
            button.noHistory:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Do not record history for this channel."]);
            end);
            button.noHistory:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);


	    -- Don't play sounds
            button.noSound = _G.CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate");
            button.noSound:SetPoint("TOPLEFT", button.noHistory, "TOPRIGHT", 100, 0);
            button.noSound:SetScale(.75);
            button.noSound.text = button.noSound:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
            button.noSound.text:SetPoint("LEFT", button.noSound, "RIGHT", 0, 0);
            button.noSound.text:SetText(L["No Sound"]);
            button.noSound:SetScript("OnClick", function(self)
                    local name = self:GetParent().channelName;
                    db.chat[channelType].channelSettings[name].noSound = self:GetChecked();
            end)
            button.noSound:SetScript("OnEnter", function(self)
                self:GetParent():GetParent().help:SetJustifyH("LEFT");
                self:GetParent():GetParent().help:SetText(L["Do not play sounds for this channel."]);
            end);
            button.noSound:SetScript("OnLeave", function(self)
                self:GetParent():GetParent().help:SetText("");
            end);



            if(#self.buttons == 0) then
                button:SetPoint("TOPLEFT");
                button:SetPoint("TOPRIGHT", -25, 0);
            else
                button:SetPoint("TOPLEFT", self.buttons[#self.buttons], "BOTTOMLEFT");
                button:SetPoint("TOPRIGHT", self.buttons[#self.buttons], "BOTTOMRIGHT");
            end

            button:SetScript("OnUpdate", function(self, elapsed)
                    -- 12.1 removed the MouseIsOver global; the widget method replaces it.
                    for _, border in pairs(self.border) do
                        if(self:IsMouseOver()) then
                            border:Show();
                        else
                            border:Hide();
                        end
                    end
            end);

            table.insert(self.buttons, button);
        end
        for i=1, 4 do
            f.sub.list:createButton();
        end
        f.sub.list.help = f.sub.list:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
        f.sub.list.help:SetPoint("TOPLEFT", f.sub.list, "BOTTOMLEFT", 0, -2);
        f.sub.list.help:SetPoint("BOTTOMRIGHT", f.sub.list, "BOTTOMRIGHT", 0, -12);
        f.sub.list.help:SetText("");
        f.sub.list.help:SetJustifyH("LEFT");
        local font, height, flags = f.sub.list.help:GetFont();
        f.sub.list.help:SetFont(font, 12, flags);


        return f;
    end

    local function createGuildChat()
        local f = createChatTemplate(_G.GUILD, "GuildChat", "guild");
        return f;
    end

    local function createOfficerChat()
        local f = createChatTemplate(_G.GUILD_RANK1_DESC, "OfficerChat", "officer");
        return f;
    end

    local function createPartyChat()
        local f = createChatTemplate(_G.PARTY, "PartyChat", "party");
        return f;
    end

    local function createRaidChat()
        local f = createChatTemplate(_G.RAID, "RaidChat", "raid");
        return f;
    end

    local function createBattlegroundChat()
        local f = createChatTemplate(_G.INSTANCE_CHAT, "BattlegroundChat", "battleground");
        return f;
    end

    local function createSayChat()
        local f = createChatTemplate(_G.SAY, "SayChat", "say");
        return f;
    end

    local function createWorldChat()
        local f = createChannelChatTemplate(L["World Chat"], "world", function() return getChannelList(true); end);
        return f;
    end

    local function createCustomChat()
        local f = createChannelChatTemplate(L["Custom Chat"], "custom", getChannelList);
        return f;
    end

	local function createCommunityChat()
        local f = createChannelChatTemplate(L["Community Chat"], "community", getCommunityGroupList);
        return f;
    end

    -- Exposed for the modern options UI (Sources/Options/ModernOptions.lua):
    -- the channel enumerations live in this scope.
    GetOptionsChannelList = getChannelList;
    GetOptionsCommunityList = getCommunityGroupList;

    RegisterOptionFrame(L["Chat"], _G.GUILD, createGuildChat);
    RegisterOptionFrame(L["Chat"], _G.GUILD_RANK1_DESC, createOfficerChat);
    RegisterOptionFrame(L["Chat"], _G.PARTY, createPartyChat);
    RegisterOptionFrame(L["Chat"], _G.RAID, createRaidChat);
    RegisterOptionFrame(L["Chat"], _G.INSTANCE_CHAT, createBattlegroundChat);
    RegisterOptionFrame(L["Chat"], _G.SAY, createSayChat);
    RegisterOptionFrame(L["Chat"], L["World Chat"], createWorldChat);
    RegisterOptionFrame(L["Chat"], L["Custom Chat"], createCustomChat);

	if (_G.C_Club and _G.C_Club.GetSubscribedClubs) then
    	RegisterOptionFrame(L["Chat"], L["Community Chat"], createCommunityChat);
	end

    dPrint("Chat Options Initialized...");
    ChatOptions.optionsLoaded = true;
end


local function createUserList()
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local win = _G.CreateFrame("Frame", "WIM3_ChatUserList", WIM.WindowParent, "BackdropTemplate");

    win:EnableMouse(true);
    win:Hide();
    win:SetPoint("CENTER");
    -- set backdrop - Changes for Patch 9.0.1 - Shadowlands, retail and classic
    win.backdropInfo = {bgFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg",
        edgeFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 32, right = 32, top = 32, bottom = 32 }};

	win:ApplyBackdrop();

    win:SetWidth(200);
    win.title = _G.CreateFrame("Frame", win:GetName().."Title", win);
    win.title:SetHeight(17);
    win.title:SetPoint("TOPLEFT", 20, -18); win.title:SetPoint("TOPRIGHT", -20, -18);
    win.title.bg = win.title:CreateTexture(nil, "BACKGROUND");
    win.title.bg:SetAllPoints();
    win.title.text = win.title:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
    local font = win.title.text:GetFont();
    win.title.text:SetFont(font, 11, "");
    win.title.text:SetAllPoints();
    win.title.text:SetJustifyV("TOP");
    win.title.text:SetJustifyH("RIGHT");
    win.title.text:SetText("Testing...");
    win.buttons = {};

    for i = 1, USERLIST_BUTTON_COUNT do
        local button = _G.CreateFrame("Button", win:GetName().."Button1", win);
        button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD");
        button:GetHighlightTexture():SetVertexColor(.196, .388, .8);
        button:SetHeight(20);
        button.text = button:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
        button.text:SetText("  Button "..i);
        button.text:SetJustifyH("LEFT");
        button.text:SetAllPoints();
		button.text._allowCustomFont = true;
        button.SetUser = function(self, user)
            self.user = user;
            self.text:SetText("  "..user);
        end

        button:SetScript("OnClick", function(self, button)
            --if(button == "RightButton") then
                --_G.ChannelRosterFrame_ShowDropdown(self.user);
            --end
        end);


        if(i == 1) then
            button:SetPoint("TOPLEFT", 20, -35);
            button:SetPoint("RIGHT", -30, 0);
        else
            button:SetPoint("TOPLEFT", win.buttons[i-1], "BOTTOMLEFT");
            button:SetPoint("TOPRIGHT", win.buttons[i-1], "BOTTOMRIGHT");
        end

       table.insert(win.buttons, button);
    end
    win:SetHeight(#win.buttons*win.buttons[1]:GetHeight() + 35 + 20);
    win.scroll = _G.CreateFrame("ScrollFrame", win:GetName().."Scroll", win, "FauxScrollFrameTemplate");
    win.scroll:SetPoint("TOPLEFT", win.buttons[1], "TOPLEFT", 0, 0);
    win.scroll:SetPoint("BOTTOMRIGHT", win.buttons[#win.buttons], "BOTTOMRIGHT", -10, 0);

    win.scroll:SetScript("OnVerticalScroll", function(self, offset)
        _G.FauxScrollFrame_OnVerticalScroll(self, offset, win.buttons[1]:GetHeight(), win.updateList);
    end);

	win.ApplySkin = function(self, skin)
		skin = skin or GetSelectedSkin();

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

		-- title font + color. SetWidgetFont resolves every form a skin may
		-- declare (font object name, LibSharedMedia name, or file path); a
		-- raw SetFont here would silently no-op on anything but a path.
		SetWidgetFont(self.title.text, skin.menu.title);

		-- buttons
		for i=1, #self.buttons do
			local button = self.buttons[i];

			SetWidgetFont(button.text, skin.menu.button);
		end
	end

    win:SetScript("OnHide", function(self)
        self:Hide();
        self.attachedTo = nil;
        self.listCount = nil;
        self.listFun = nil;
        self:SetParent(_G.UIParent);
    end);

    win:SetScript("OnUpdate", function(self, elapsed)
        if(self:IsMouseOver() or (self.attachedTo and self.attachedTo:IsMouseOver())) then
            self.idleTime = 0;
        else
            self.idleTime = self.idleTime + elapsed;
            if(self.idleTime > 1) then
                self:Hide();
            end
        end
    end);


    win.SetChannel = function(self, title)
        self.title.text:SetText(string.format(L["Users in %s"], title or _G.CHAT).."  ");
    end

    win.PopUp = function(self, attachTo, point, point2, offsetX, offsetY)
        if(self.attachedTo == attachTo) then
            self:Hide();
            return;
        end
        self:SetParent(attachTo);
        self:SetParentWindow(attachTo.parentWindow);
        self.attachedTo = attachTo;
		self:ClearAllPoints();
        self:SetPoint(point, attachTo, point2, offsetX, offsetY);
        self:Show();
        win:updateList();
    end

    win.updateList = function(self)
        self = win;
        if(self.listCount and self.listFun and self.listCount() > 0) then
            local count = self.listCount();
            local offset = _G.FauxScrollFrame_GetOffset(win.scroll);
            for i=1, USERLIST_BUTTON_COUNT do
                self.buttons[i]:Show();
                local index = i + offset;
                if(index <= count) then
                    self.buttons[i]:SetUser(self.listFun(index));
                    self.buttons[i]:Show();
                else
                    self.buttons[i]:Hide();
                end
            end

            _G.FauxScrollFrame_Update(win.scroll, count, USERLIST_BUTTON_COUNT, self.buttons[1]:GetHeight());
        else
            self:Hide();
        end
    end

    win.SetParentWindow = function(self, parent, start)
        start = start or self;
        start.parentWindow = parent;
        if(start.GetChildren) then
            for i=1, select("#", start:GetChildren()) do
                self:SetParentWindow(parent, select(i, start:GetChildren()));
            end
        end
    end

    return win;
end






function ChatOptions:OnEnableWIM()
    loadChatOptions();
    --load joined channels.

    --create user List
    if(not ChatUserList) then
        ChatUserList = createUserList();
		ChatUserList:ApplySkin();
    end
end

function ChatOptions:OnSkinLoaded(skin)
	if(ChatUserList) then
		ChatUserList:ApplySkin(skin);
	end
end

ChatOptions.canDisable = false;
ChatOptions:Enable();


-- global reference
GetChatWindow = getChatWindow;

function CleanLanguageArg(arg)
    if(arg and arg ~= "Universal" and arg ~= _G.DEFAULT_CHAT_FRAME.defaultLanguage) then
        return arg;
    else
        return nil;
    end
end

local channelCountCache = {};
function GetChannelCount(id)
    if(ChatUserList:IsVisible()) then
        return channelCountCache[id] or "...";
    end
    for i=1, 20 do
        local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = _G.GetChannelDisplayInfo(i);
        if(header and collapsed) then
            _G.ExpandChannelHeader(i);
            return GetChannelCount(id);
        end
        if(id == channelNumber) then
            if(_G.GetSelectedDisplayChannel() ~= i) then
                _G.SetSelectedDisplayChannel(i);
                name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = _G.GetChannelDisplayInfo(i);
            end
            channelCountCache[id] = channelCountCache[id] or "...";
            channelCountCache[id] = count or channelCountCache[id];
            return channelCountCache[id];
        end
    end
    return 0;
end

function GetClubStreamMembers(clubId, streamId)
	if (not clubId or not streamId) then
		return {};
	end

	local name = clubId..":"..streamId;

	local members = _G.C_Club.GetClubMembers(clubId, streamId);

	if (members) then
		for i, member in pairs(members) do
			local memberInfo = _G.C_Club.GetMemberInfo(clubId, member);
			if (memberInfo) then
				members[i] = memberInfo.name or member;
			end
		end

		return members;
	end

	return {};
end
