local WIM = WIM;
local utils = WIM.utils;
local type = type;
local tostring = tostring;
local select = select;
local pairs = pairs;
local unpack = unpack;
local table_insert = table.insert;
local table_remove = table.remove;

--------------------------------------
--          Table Functions         --
--------------------------------------

utils.table = {}

-- Simple shallow copy for copying defaults
function utils.table.copyTable(src, dest)
	if type(dest) ~= type(src) and type(src) == "table" then dest = {} end
	if type(src) == "table" then
		for k, v in pairs(src) do
			if type(v) == "table" then
				-- try to index the key first so that the metatable creates the defaults, if set, and use that table
				v = utils.table.copyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest or src
end

function utils.table.inheritTable(src, dest, ...)
	if (type(src) == "table") then
		if (type(dest) ~= "table") then dest = {}; end
		for k, v in pairs(src) do
			local ignoredKey = false;
			for i = 1, select("#", ...) do
				if (tostring(k) == tostring(select(i, ...))) then
					ignoredKey = true;
					break;
				end
			end
			if (not ignoredKey) then
				if (type(v) == "table") then
					dest[k] = utils.table.inheritTable(v, dest[k], ...);
				else
					if (dest[k] == nil) then
						dest[k] = v
					end
				end
			end
		end
		return dest;
	else
		if (dest == nil) then
			return src;
		else
			return dest;
		end
	end
end

-- a simple function to add an item to a table checking for duplicates.
-- this is ok, since the table is never too large to slow things down.
function utils.table.addToTableUnique(tbl, item, prioritize)
	for i = 1, #tbl do
		if (tbl[i] == item) then
			return false;
		end
	end
	if (prioritize) then
		table_insert(tbl, 1, item);
	else
		table_insert(tbl, item);
	end
	return true;
end

-- remove item from table. Return true if removed, false otherwise.
function utils.table.removeFromTable(tbl, item)
	for i = 1, #tbl do
		if (tbl[i] == item) then
			table_remove(tbl, i);
			return true;
		end
	end
	return false;
end

function utils.table.isInTable(tbl, val)
	for i = 1, #tbl do
		if (tbl[i] == val) then
			return true;
		end
	end
	return false;
end

function utils.table.packTable(...)
	local tbl = { ... };
	tbl.n = select('#', ...);
	return tbl;
end

function utils.table.spread(...)
	local result = {};
	for i = 1, select("#", ...) do
		local tbl = select(i, ...);
		if (type(tbl) == "table") then
			for k, v in pairs(tbl) do
				result[k] = v;
			end
		end
	end
	return result;
end
