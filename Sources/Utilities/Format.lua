local WIM = WIM;
local utils = WIM.utils;
local string = string;

utils.format = {}

----------------------------------------------
--              Text Formatting             --
----------------------------------------------

function utils.FormatUserName(user)
	if (user ~= nil and not string.find(user, "^|K")) then
		if (not string.find(user, "-")) then
			user = string.gsub(user, "[A-Z]", string.lower);
			user = string.gsub(user, " [a-z]", string.upper); -- accomodate second name (BN)
		end
		user = string.gsub(user, "^[a-z]", string.upper);
		user = string.gsub(user, "-[a-z]", string.upper); -- accomodate for cross server...
	end
	return user;
end

function utils.GetNameAndServer(user)
	local name, realm = string.split("-", user)
	if realm then
		realm = string.gsub(realm, "^[A-Z]", string.lower)
		realm = string.gsub(realm, "[A-Z]", " %1")
		realm = string.gsub(realm, "' ", "'")
		realm = string.gsub(realm, "^[a-z]", string.upper)
	else
		name = user
	end

	return name, realm
end

function utils.GetReadableName(user)
	local name, realm = utils.GetNameAndServer(user)
	return name .. (realm and " - " .. realm or "")
end

function utils.GetPrivateBNetName(user)
	local isId = type(user) == "number";
	local id = isId and user or (user and _G.BNet_GetBNetIDAccount(user) or nil);

	-- if we don't have an id, just return user
	if not id then return user end

	local _, _, toonName, privateBattleTag = utils.bnet.GetBNFriendNames(id)

	return privateBattleTag or toonName or '???';
end
