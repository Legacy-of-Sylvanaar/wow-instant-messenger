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

		return
			accountInfo.bnetAccountID, -- 1
			accountInfo.accountName, -- 2
			accountInfo.battleTag, -- 3
			accountInfo.isBattleTagFriend, -- 4
			accountInfo.gameAccountInfo.characterName, -- 5
			accountInfo.gameAccountInfo.gameAccountID, -- 6
			clientProgram, -- 7
			accountInfo.gameAccountInfo.isOnline, -- 8
			accountInfo.lastOnlineTime, -- 9
			accountInfo.isAFK, -- 10
			accountInfo.isDND, -- 11
			accountInfo.customMessage, -- 12
			accountInfo.note, -- 13
			accountInfo.isFriend, -- 14
			accountInfo.customMessageTime, -- 15
			wowProjectID, -- 16
			accountInfo.rafLinkType == _G.Enum.RafLinkType.Recruit, -- 17
			accountInfo.gameAccountInfo.canSummon, -- 18
			accountInfo.isFavorite, -- 19
			accountInfo.gameAccountInfo.isWowMobile; -- 20
	end
end

-- returns: bnetAccountID, accountName, battleTag, isBattleTagFriend, characterName, gameAccountID, clientProgram, isOnline, lastOnlineTime, isAFK, isDND, customMessage, note, isFriend, customMessageTime, wowProjectID, isRecruit, canSummon, isFavorite, isWowMobile
function bnet.GetBNGetFriendInfoByID(id)
	-- if id is 0, return the current player's Battle.net info.
	if not id or id == 0 then
		id = select(3, _G.BNGetInfo());
	end
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

		return
			accountInfo.bnetAccountID, -- 1
			accountInfo.accountName, -- 2
			accountInfo.battleTag, -- 3
			accountInfo.isBattleTagFriend, -- 4
			accountInfo.gameAccountInfo.characterName, -- 5
			accountInfo.gameAccountInfo.gameAccountID, -- 6
			clientProgram, -- 7
			accountInfo.gameAccountInfo.isOnline, -- 8
			accountInfo.lastOnlineTime, -- 9
			accountInfo.isAFK, -- 10
			accountInfo.isDND, -- 11
			accountInfo.customMessage, -- 12
			accountInfo.note, -- 13
			accountInfo.isFriend, -- 14
			accountInfo.customMessageTime, -- 15
			wowProjectID, -- 16
			accountInfo.rafLinkType == _G.Enum.RafLinkType.Recruit, -- 17
			accountInfo.gameAccountInfo.canSummon, -- 18
			accountInfo.isFavorite, -- 19
			accountInfo.gameAccountInfo.isWowMobile; -- 20
	end
end

function bnet.GetBNFriendNames(id)
	local _, accountName, battleTag, _, characterName = bnet.GetBNGetFriendInfoByID(id);
	local privateBattleTag = (string.split("#", battleTag or ""));

	return accountName, battleTag, characterName, privateBattleTag; -- 2, 3, 4
end

-- find the Battle.net account id for a name.
-- BNet_GetBNetIDAccount only knows online friends, so fall back to scanning the
-- whole friend list when the name is a BattleTag.
function bnet.GetBNetIDFromName(name)
	if(type(name) ~= "string" or name == "") then
        return nil;
    end

	local bnID = _G.BNet_GetBNetIDAccount and _G.BNet_GetBNetIDAccount(name);
    if(bnID) then
        return bnID;
    end

	if((name:find("#") or name:find("@")) and _G.BNGetNumFriends) then
        local total = _G.BNGetNumFriends() or 0;
        for i=1, total do
            local id, accountName, battleTag = utils.bnet.GetBNGetFriendInfo(i);
            if(id and (battleTag == name or accountName == name)) then
                return id;
            end
        end
    end

    return nil;
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
		return
			gameAccountInfo.hasFocus,	-- 1
			characterName, -- 2
			gameAccountInfo.clientProgram, -- 3
			realmName, -- 4
			realmID, -- 5
			factionName, -- 6
			raceName, -- 7
			className, -- 8
			"", -- 9
			areaName, -- 10
			characterLevel, -- 11
			richPresence, -- 12
			nil, -- 13
			nil, -- 14
			gameAccountInfo.isOnline, -- 15
			gameAccountID, -- 16
			nil, -- 17
			gameAccountInfo.isGameAFK, -- 18
			gameAccountInfo.isGameBusy, -- 19
			playerGuid, -- 20
			wowProjectID, -- 21
			gameAccountInfo.isWowMobile -- 22
	end
end
--End Compat wrappers for retail and classic to access same functions and expect same returns

