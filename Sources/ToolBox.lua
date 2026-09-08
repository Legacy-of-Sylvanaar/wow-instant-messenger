local WIM = WIM;

--------------------------------------
--     Compatibility Functions      --
--------------------------------------

function WIM.GetMouseTopFocus()
	-- Interface 11.0+
	if (GetMouseFoci) then
		return GetMouseFoci()[1]

	-- Legacy method
	else
		return GetMouseFocus()
	end
end


--------------------------------------
--          Table Functions         --
--------------------------------------

-- Simple shallow copy for copying defaults
function copyTable(src, dest)
        if type(dest) ~= type(src) and type(src) == "table" then dest = {} end
        if type(src) == "table" then
    		for k,v in pairs(src) do
    			if type(v) == "table" then
    				-- try to index the key first so that the metatable creates the defaults, if set, and use that table
    				v = copyTable(v, dest[k])
    			end
    			dest[k] = v
    		end
    	end
    	return dest or src
end
WIM.copyTable = copyTable;

function WIM.inherritTable(src, dest, ...)
        if(type(src) == "table") then
                if(type(dest) ~= "table") then dest = {}; end
                for k, v in pairs(src) do
                        local ignoredKey = false;
                        for i=1, select("#", ...) do
                                if(tostring(k) == tostring(select(i, ...))) then
                                        ignoredKey = true;
                                        break;
                                end
                        end
                        if(not ignoredKey) then
                                if(type(v) == "table") then
                                        dest[k] = WIM.inherritTable(v, dest[k], ...);
                                else
                                        if(dest[k] == nil) then
                                                dest[k] = v
                                        end
                                end
                        end
                end
                return dest;
        else
                if(dest == nil) then
                        return src;
                else
                        return dest;
                end
        end
end

-- a simple function to add an item to a table checking for duplicates.
-- this is ok, since the table is never too large to slow things down.
function WIM.addToTableUnique(tbl, item, prioritize)
    for i=1,table.getn(tbl) do
        if(tbl[i] == item) then
            return false;
        end
    end
    if(prioritize) then
        table.insert(tbl, 1, item);
    else
        table.insert(tbl, item);
    end
    return true;
end

-- remove item from table. Return true if removed, false otherwise.
function WIM.removeFromTable(tbl, item)
    for i=1,table.getn(tbl) do
        if(tbl[i] == item) then
            table.remove(tbl, i);
            return true;
        end
    end
    return false;
end

function WIM.isInTable(tbl, val)
        for i=1, #tbl do
                if(tbl[i] == val) then
                        return true;
                end
        end
        return false;
end

function WIM.packTable (...)
	local tbl = { ... };
	tbl.n = select('#', ...);
	return tbl;
end

function WIM.unpackTable (tbl)
	return unpack(tbl, tbl.n);
end
----------------------------------------------
--              Text Formatting             --
----------------------------------------------


function WIM.FormatUserName(user)
	if(user ~= nil and not string.find(user, "^|K")) then
		if (not string.find(user, "-")) then
			user = string.gsub(user, "[A-Z]", string.lower);
			user = string.gsub(user, " [a-z]", string.upper); -- accomodate second name (BN)
		end
	    user = string.gsub(user, "^[a-z]", string.upper);
	    user = string.gsub(user, "-[a-z]", string.upper); -- accomodate for cross server...
	end
	return user;
end

function WIM.GetNameAndServer(user)
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

function WIM.GetReadableName(user)
	local name, realm = WIM.GetNameAndServer(user)
	return name..(realm and " - "..realm or "")
end

----------------------------------------------
--              Gradient Tools              --
----------------------------------------------
-- the following bits of code is a result of boredom
-- and determination to get it done. The gradient pattern
-- which I was aiming for could not be manipulated in RGB,
-- however by converting RGB to HSV, the pattern now becomes
-- linear and as such, can now be given any color and
-- have the same gradient effect applied.

function WIM.RGBPercentToHex(r, g, b)
        return string.format ("%.2x%.2x%.2x",r*255,g*255,b*255);
end

function WIM.RGBHexToPercent(rgbStr)
        local R, G, B = string.sub(rgbStr, 1, 2), string.sub(rgbStr, 3, 4), string.sub(rgbStr, 5, 6);
        return tonumber(R, 16)/255, tonumber(G, 16)/255, tonumber(B, 16)/255;
end

function WIM.RGBHextoHSVPerc(rgbStr)
    local R, G, B = WIM.RGBHexToPercent(rgbStr);
    local i, x, v, f;
    x = math.min(R, G);
    x = math.min(x, B);
    v = math.max(R, G);
    v = math.max(v, B);
    if(v == x) then
        return nil, 0, v;
    else
        if(R == x) then
            f = G - B;
        elseif(G == x) then
            f = B - R;
        else
            f = R - G;
        end
        if(R == x) then
            i = 3;
        elseif(G == x) then
            i = 5;
        else
            i = 1;
        end
        return ((i - f /(v - x))/6), (v - x)/v, v;
    end
end

function WIM.HSVPerctoRGBPerc(H, S, V)
    local m, n, f, i;
    if(H == nil) then
        return V, V, V;
    else
        H = H * 6;
        if (H == 0) then
            H=.01;
        end
        i = math.floor(H);
        f = H - i;
        if((i % 2) == 0) then
            f = 1 - f; -- if i is even
        end
        m = V * (1 - S);
        n = V * (1 - S * f);
        if(i == 6 or i == 0) then
            return V, n, m;
        elseif(i == 1) then
            return n, V, m;
        elseif(i == 2) then
            return m, V, n;
        elseif(i == 3) then
            return m, n, V;
        elseif(i == 4) then
            return n, m, V;
        elseif(i == 5) then
            return V, m, n;
        else
            return 0, 0, 0;
        end
    end
end

-- pass rgb as signle arg hex, or triple arg rgb percent.
-- entering ! before a hex, will return a solid color.
function WIM.getGradientFromColor_Legacy(...)
    local h, s, v, s1, v1, s2, v2;
    if(select("#", ...) == 0) then
        return 0, 0, 0, 0, 0, 0;
    elseif(select("#", ...) == 1) then
        if(string.sub(select(1, ...),1, 1) == "!") then
            local rgbStr = string.sub(select(1, ...), 2, 7);
            local R, G, B = string.sub(rgbStr, 1, 2), string.sub(rgbStr, 3, 4), string.sub(rgbStr, 5, 6);
            return tonumber(R, 16)/255, tonumber(G, 16)/255, tonumber(B, 16)/255, tonumber(R, 16)/255, tonumber(G, 16)/255, tonumber(B, 16)/255;
        else
            h, s, v = WIM.RGBHextoHSVPerc(select(1, ...));
        end
    else
        h, s, v = WIM.RGBHextoHSVPerc(string.format ("%.2x%.2x%.2x",select(1, ...), select(2, ...), select(3, ...)));
    end

    s1 = math.min(1, s+.29/2);
    v1 = math.max(0, v-.57/2);
    s2 = math.max(0, s-.29/2);
    v2 = math.min(1, s+.57/2);

    local r1, g1, b1 = WIM.HSVPerctoRGBPerc(h, s1, v1);
    local r2, g2, b2 = WIM.HSVPerctoRGBPerc(h, s2, v2);

    return r1, g1, b1, r2, g2, b2;
end

function WIM.getGradientFromColor(...)
	local r1, g1, b1, r2, g2, b2 = WIM.getGradientFromColor_Legacy(...)

	return { r = r1, g = g1, b = b1, a = 1 }, { r = r2, g = g2, b = b2, a = 1 }
end


--------------------------------------
--         String Functions         --
--------------------------------------
function WIM.paddString(str, paddingChar, minLength, paddRight)
    str = tostring(str or "");
    paddingChar = tostring(paddingChar or " ");
    minLength = tonumber(minLength or 0);
    while(string.len(str) < minLength) do
        if(paddRight) then
            str = str..paddingChar;
        else
            str = paddingChar..str;
        end
    end
    return str;
end

function WIM.gSplit(splitBy, str)
	local index = 0
    return function()
        index = index + 1;
        return select(index, string.split(splitBy, str));
    end
end

function WIM.SplitToTable(str, inSplitPattern, outResults )
  if not outResults then
    return;
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( str, theStart ) )
  --if(#outResults > 0) then
  --  table.remove(outResults, 1);
  --end
end


--------------------------------------
--         Macro Functions          --
--------------------------------------
function WIM.SendToFocused (msg, typeFilter) -- typeFilter: whiser | chat | null
	local focus = (WIM.EditBoxInFocus or WIM._EditBoxInFocus)
	local win = focus and focus:GetParent()

	if (focus and (not typeFilter or typeFilter == win.type)) then
		focus:SetText(msg)
		focus:GetScript("OnEnterPressed")(focus)
		focus:SetFocus()
	end
end

--------------------------------------
--      Debugging Functions         --
--------------------------------------
-- Debug output is also captured to disk, because the messages that
-- matter most for diagnosing login-time behavior (module OnEnable,
-- PLAYER_ENTERING_WORLD, the first chat message) all fire before a slash
-- command could be typed. WIM.debug is restored from WIM3_DebugLog.level
-- in VARIABLES_LOADED, so capture is already running by then.
--
-- The buffer lives in a per-character SavedVariable on purpose: it is
-- written to WTF/Account/<acct>/<realm>/<char>/SavedVariables/WIM.lua
-- and so can never add to the account-wide WIM.lua, which has a hard Lua
-- 5.1 constant-table limit (see the issue #251 note in WIM.lua). Both
-- caps below keep it bounded; 2000 lines is a few tens of KB.
-- Debug levels:
--   0  off
--   1  normal: the dPrint messages WIM has always emitted, chat + log
--   2  verbose: adds raw chat event tracing, log only
--      (Sources/DebugTrace.lua)
WIM.DEBUG_LOG_MAX = 6000;   -- ring buffer length; level 2 fills this quickly
WIM.DEBUG_LINE_MAX = 500;   -- per-line truncation

-- Millisecond timestamps.
--
-- date() wraps strftime, which has no sub-second field, so it can only ever give
-- whole seconds. The client's high-resolution clocks (GetTimePreciseSec, and
-- GetTime as a fallback) do have the precision but count from client start
-- rather than the epoch, so neither source alone produces a wall-clock stamp
-- with milliseconds.
--
-- Aligning them once fixes that: poll until time() ticks over to a new
-- second, and record the high-resolution reading at that instant. From
-- then on
--   epoch = alignEpoch + (clock() - alignClock)
-- is a wall clock with the resolution of the high-resolution source.
-- Sampling at the tick keeps it accurate; taking both readings at an
-- arbitrary moment would build in a constant error of up to a full
-- second, the ambiguity this exists to remove.
--
-- GetTimePreciseSec is preferred where present because GetTime is frame-locked
-- and would collapse everything dispatched in one frame to an identical stamp.
local hiResClock = GetTimePreciseSec or GetTime;
local alignEpoch, alignClock;

do
    local startEpoch = time();
    local aligner = CreateFrame("Frame");
    aligner:SetScript("OnUpdate", function(self)
        local now = time();
        if (now ~= startEpoch) then
            alignEpoch, alignClock = now, hiResClock();
            self:SetScript("OnUpdate", nil);   -- one-shot; costs a frame or two
        end
    end);
end

function WIM.LogStamp()
    if (not alignEpoch) then
        -- Alignment has not completed yet (the first frame or two after load).
        -- Print no fraction rather than a misleading one.
        return date("%m/%d %H:%M:%S")..".---";
    end

    local now = alignEpoch + (hiResClock() - alignClock);
    local whole = math.floor(now);
    local ms = math.floor((now - whole) * 1000 + 0.5);
    if (ms > 999) then ms = 999; end
    return date("%m/%d %H:%M:%S", whole).."."..string.format("%03d", ms);
end

-- Shared by dPrint and tPrint. Appends one timestamped line to the on-disk ring
-- buffer, bounded at both ends so a long trace session cannot grow without limit.
function WIM.LogLine(line)
    local log = WIM3_DebugLog;
    if (type(log) ~= "table" or type(log.lines) ~= "table") then
        return;
    end

    if (#line > WIM.DEBUG_LINE_MAX) then
        line = string.sub(line, 1, WIM.DEBUG_LINE_MAX).."...[truncated]";
    end
    log.lines[#log.lines + 1] = WIM.LogStamp().."  "..line;

    -- Drop the oldest half in one pass when full, rather than shifting the whole
    -- table on every append.
    if (#log.lines > WIM.DEBUG_LOG_MAX) then
        local keep = {};
        for i = math.floor(WIM.DEBUG_LOG_MAX / 2) + 1, #log.lines do
            keep[#keep + 1] = log.lines[i];
        end
        log.lines = keep;
    end
end

function WIM.dPrint(t)
    if not WIM.debug then
        return;
    end
    local line = tostring(t);
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[WIM Debug]:|r "..line);
    WIM.LogLine(line);
end

-- Trace output. Log only, never the chat frame: level 2 is far too
-- noisy to read live, and the on-disk log is the useful artifact.
function WIM.tPrint(t)
    if ((WIM.debugLevel or 0) < 2) then
        return;
    end
    WIM.LogLine(tostring(t));
end

function WIM.SetDebugLevel(level)
    level = tonumber(level) or 0;
    if (level < 0) then level = 0; end
    if (level > 2) then level = 2; end

    WIM.debugLevel = level;
    WIM.debug = level >= 1;

    if (type(WIM3_DebugLog) == "table") then
        WIM3_DebugLog.level = level;
    end

    -- Guarded because ToolBox loads before DebugTrace.
    if (level >= 2) then
        if (WIM.StartEventTrace) then WIM.StartEventTrace(); end
    elseif (WIM.StopEventTrace) then
        WIM.StopEventTrace();
    end

    -- Every capture (re)start writes a header line, so any excerpt a user
    -- pastes into a bug report carries the version context with it.
    if (level >= 1) then
        WIM.LogSessionHeader(level);
    end

    return level;
end

-- One-line context header for the on-disk log: addon version, client build,
-- locale and character. GetRealmName() can legitimately be nil this early in
-- VARIABLES_LOADED; the per-character SavedVariables path identifies the
-- character regardless, so "?" placeholders are acceptable there.
function WIM.LogSessionHeader(level)
    local gameVersion, build, _, interface = GetBuildInfo();
    WIM.LogLine(("=== WIM %s | level %d | WoW %s (build %s, interface %s) | %s | %s-%s ==="):format(
        tostring(WIM.version), level or WIM.debugLevel or 0,
        tostring(gameVersion), tostring(build), tostring(interface),
        tostring(GetLocale()),
        tostring(UnitName and UnitName("player") or "?"),
        tostring(GetRealmName and GetRealmName() or "?")));
end


function dumpGlobals()
    local tmp = {};
    for var, _ in pairs(_G) do
        table.insert(tmp, var);
    end
    table.sort(tmp);
    return tmp;
end
