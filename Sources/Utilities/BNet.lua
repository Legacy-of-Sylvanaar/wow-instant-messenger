local WIM = WIM;
local utils = WIM.utils;
local IsSecretValue = WIM.IsSecretValue;

local bnet = {};
utils.bnet = bnet;

--------------------------------------
--    BattleNet Related Functions   --
--------------------------------------

--Retail and Classic bnet apis are now mostly in sync, but i'm keeping wrappers so if they ever get out of sync again, it's easy to fix in these wrappers
function bnet.GetBNGetFriendInfo(friendIndex)
	if friendIndex == 0 then
		return bnet.GetBNGetFriendInfoByID(select(3, _G.BNGetInfo()));
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

-- returns: bnetAccountID, accountName, battleTag, isBattleTagFriend, characterName, gameAccountID, clientProgram, isOnline, lastOnlineTime, isAFK, isDND, customMessage, note, isFriend, customMessageTime, wowProjectID, isRecruit, canSummon, isFavorite, isWowMobile
function bnet.GetBNGetFriendInfoByID(id)
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

-- Character whisper target of a Battle.net friend, where the client has one (WoW Forever).
function bnet.GetBNTitleFriendTarget(id)
	if type(id) == "table" then id = id[1] end
	if IsSecretValue(id) or type(id) ~= "number" then
		return
	end
	local getTarget = _G.C_BattleNet and _G.C_BattleNet.GetDefaultTitleWhisperTarget;
	if not getTarget then
		return
	end
	local ok, target = _G.pcall(getTarget, id);
	if not ok or IsSecretValue(target) or type(target) ~= "string" or target == "" or string.find(target, "|K", 1, true) then
		return
	end
	return target;
end

-- True for a friend whose account name already is a character name:
-- no BattleTag shared and no custom name set.
function bnet.IsBNCharacterNamedFriend(id)
	if type(id) == "table" then id = id[1] end
	if IsSecretValue(id) or type(id) ~= "number" then
		return false
	end
	local titleLevel = _G.Enum and _G.Enum.BattleNetFriendLevel and _G.Enum.BattleNetFriendLevel.Title;
	if not titleLevel or not _G.C_BattleNet or not _G.C_BattleNet.GetAccountInfoByID then
		return false
	end
	local accountInfo = _G.C_BattleNet.GetAccountInfoByID(id);
	if type(accountInfo) ~= "table" or IsSecretValue(accountInfo.friendLevel) or accountInfo.friendLevel ~= titleLevel then
		return false
	end
	local getCustomName = _G.C_BattleNet.GetCustomTitleFriendName;
	if getCustomName then
		local ok, customName = _G.pcall(getCustomName, id);
		if ok and not IsSecretValue(customName) and type(customName) == "string" and customName ~= "" then
			return false
		end
	end
	return true
end

function bnet.GetBNGetGameAccountInfoByKName(kName)
	for i=1, _G.BNGetNumFriends() do
		local info = {utils.bnet.GetBNGetFriendInfo(i)};
		if info[2] and info[2] == kName then
			return info;
		end
	end
	return nil;
end

function bnet.GetBNGetGameAccountInfo(toonId)
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

