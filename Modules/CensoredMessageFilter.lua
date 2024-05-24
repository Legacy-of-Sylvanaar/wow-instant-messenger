--imports
local WIM = WIM;
local _G = _G;
local find = string.find;

--set namespace
setfenv(1, WIM);

local Filter = CreateModule("CensoredMessageFilter", true);

-- This module requires LibChatHandler-1.0
_G.LibStub:GetLibrary("LibChatHandler-1.0"):Embed(Filter);

function Filter:OnEnable()
	Filter:RegisterChatEvent("CHAT_MSG_WHISPER", 1);
	Filter:RegisterChatEvent("CHAT_MSG_GUILD", 1);
	Filter:RegisterChatEvent("CHAT_MSG_OFFICER", 1);
	Filter:RegisterChatEvent("CHAT_MSG_PARTY", 1);
	Filter:RegisterChatEvent("CHAT_MSG_RAID", 1);
	Filter:RegisterChatEvent("CHAT_MSG_RAID_LEADER", 1);
	Filter:RegisterChatEvent("CHAT_MSG_SAY", 1);
	Filter:RegisterChatEvent("CHAT_MSG_CHANNEL", 1);
	Filter:RegisterChatEvent("CHAT_MSG_INSTANCE_CHAT", 1);
	Filter:RegisterChatEvent("CHAT_MSG_INSTANCE_CHAT_LEADER", 1);
end

function Filter:OnDisable()
    Filter:UnregisterChatEvent("CHAT_MSG_WHISPER");
	Filter:UnregisterChatEvent("CHAT_MSG_GUILD");
    Filter:UnregisterChatEvent("CHAT_MSG_OFFICER");
    Filter:UnregisterChatEvent("CHAT_MSG_PARTY");
    Filter:UnregisterChatEvent("CHAT_MSG_RAID");
    Filter:UnregisterChatEvent("CHAT_MSG_RAID_LEADER");
    Filter:UnregisterChatEvent("CHAT_MSG_SAY");
    Filter:UnregisterChatEvent("CHAT_MSG_CHANNEL");
    Filter:UnregisterChatEvent("CHAT_MSG_INSTANCE_CHAT");
    Filter:UnregisterChatEvent("CHAT_MSG_INSTANCE_CHAT_LEADER");
end

local controller = function (self, eventItem, msg)
	if (find(msg, "|Hcensoredmessage:[0-9]+|h")) then
		eventItem.ignoredByWIM = true;
		eventItem:BlockFromDelegate(modules.WhisperEngine);
		eventItem:BlockFromDelegate(modules.ChatEngine);
	end
end

Filter.CHAT_MSG_WHISPER_CONTROLLER = controller;
Filter.CHAT_MSG_GUILD_CONTROLLER = controller;
Filter.CHAT_MSG_OFFICER_CONTROLLER = controller;
Filter.CHAT_MSG_PARTY_CONTROLLER = controller;
Filter.CHAT_MSG_RAID_CONTROLLER = controller;
Filter.CHAT_MSG_RAID_LEADER_CONTROLLER = controller;
Filter.CHAT_MSG_SAY_CONTROLLER = controller;
Filter.CHAT_MSG_CHANNEL_CONTROLLER = controller;
Filter.CHAT_MSG_INSTANCE_CHAT_CONTROLLER = controller;
Filter.CHAT_MSG_INSTANCE_CHAT_LEADER_CONTROLLER = controller;
