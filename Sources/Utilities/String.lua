local WIM = WIM;
local utils = WIM.utils;
local tostring = tostring;
local tonumber = tonumber;
local select = select;
local string_split = string.split;
local string_find = string.find;
local string_sub = string.sub;

utils.string = {};

--------------------------------------
--         String Functions         --
--------------------------------------

function utils.paddString(str, paddingChar, minLength, paddRight)
	str = tostring(str or "");
	paddingChar = tostring(paddingChar or " ");
	minLength = tonumber(minLength or 0);
	while (str:len() < minLength) do
		if (paddRight) then
			str = str .. paddingChar;
		else
			str = paddingChar .. str;
		end
	end
	return str;
end

function utils.gSplit(splitBy, str)
	local index = 0
	return function()
		index = index + 1;
		return select(index, string_split(splitBy, str));
	end
end

function utils.SplitToTable(str, inSplitPattern, outResults)
	if not outResults then
		return;
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string_find(str, inSplitPattern, theStart)
	while theSplitStart do
		table.insert(outResults, string_sub(str, theStart, theSplitStart - 1))
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string_find(str, inSplitPattern, theStart)
	end
	table.insert(outResults, string_sub(str, theStart))
	--if(#outResults > 0) then
	--  table.remove(outResults, 1);
	--end
end
