local WIM = WIM;
local utils = WIM.utils;

utils.debug = {
	DEBUG_LOG_MAX = 6000, -- ring buffer length; level 2 fills this quickly
	DEBUG_LINE_MAX = 500, -- per-line truncation
}

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


local debug = utils.debug;

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
			self:SetScript("OnUpdate", nil); -- one-shot; costs a frame or two
		end
	end);
end

function debug.LogStamp()
	if (not alignEpoch) then
		-- Alignment has not completed yet (the first frame or two after load).
		-- Print no fraction rather than a misleading one.
		return date("%m/%d %H:%M:%S") .. ".---";
	end

	local now = alignEpoch + (hiResClock() - alignClock);
	local whole = math.floor(now);
	local ms = math.floor((now - whole) * 1000 + 0.5);
	if (ms > 999) then ms = 999; end
	return date("%m/%d %H:%M:%S", whole) .. "." .. string.format("%03d", ms);
end

-- Shared by dPrint and tPrint. Appends one timestamped line to the on-disk ring
-- buffer, bounded at both ends so a long trace session cannot grow without limit.
function debug.LogLine(line)
	local log = WIM3_DebugLog;
	if (type(log) ~= "table" or type(log.lines) ~= "table") then
		return;
	end

	if (#line > debug.DEBUG_LINE_MAX) then
		line = string.sub(line, 1, debug.DEBUG_LINE_MAX) .. "...[truncated]";
	end
	log.lines[#log.lines + 1] = debug.LogStamp() .. "  " .. line;

	-- Drop the oldest half in one pass when full, rather than shifting the whole
	-- table on every append.
	if (#log.lines > debug.DEBUG_LOG_MAX) then
		local keep = {};
		for i = math.floor(debug.DEBUG_LOG_MAX / 2) + 1, #log.lines do
			keep[#keep + 1] = log.lines[i];
		end
		log.lines = keep;
	end
end

function debug.dPrint(t)
	if not WIM.debug then
		return;
	end
	local line = tostring(t);
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[WIM Debug]:|r " .. line);
	debug.LogLine(line);
end

WIM.dPrint = debug.dPrint;  -- Expose debug.dPrint through the WIM namespace for convenience.

-- Trace output. Log only, never the chat frame: level 2 is far too
-- noisy to read live, and the on-disk log is the useful artifact.
function debug.tPrint(t)
	if ((WIM.debugLevel or 0) < 2) then
		return;
	end
	debug.LogLine(tostring(t));
end

function debug.SetDebugLevel(level)
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
		debug.LogSessionHeader(level);
	end

	return level;
end

-- One-line context header for the on-disk log: addon version, client build,
-- locale and character. GetRealmName() can legitimately be nil this early in
-- VARIABLES_LOADED; the per-character SavedVariables path identifies the
-- character regardless, so "?" placeholders are acceptable there.
function debug.LogSessionHeader(level)
	local gameVersion, build, _, interface = GetBuildInfo();
	debug.LogLine(("=== WIM %s | level %d | WoW %s (build %s, interface %s) | %s | %s-%s ==="):format(
		tostring(WIM.version), level or WIM.debugLevel or 0,
		tostring(gameVersion), tostring(build), tostring(interface),
		tostring(GetLocale()),
		tostring(UnitName and UnitName("player") or "?"),
		tostring(GetRealmName and GetRealmName() or "?")));
end

function utils.dumpGlobals()
	local tmp = {};
	for var, _ in pairs(_G) do
		table.insert(tmp, var);
	end
	table.sort(tmp);
	return tmp;
end

function utils.debug.dump(...)
	if (select('#', ...) > 1) then
		_G.DevTools_Dump({ ... })
	else
		_G.DevTools_Dump(...);
	end
end
