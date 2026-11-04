-- Test harness for WIM's HistorySerializer under real Lua 5.1.
-- Emulates just enough of the WIM namespace/WoW environment to load the file.

WIM = {}
local realsetfenv = setfenv

-- Load the module the same way WoW would: as its own chunk, with the globals
-- it expects present.
-- Resolve the source relative to this script, so the suite runs from
-- any working directory.
local here = ((arg and arg[0]) or ""):match("^(.*)[/\\]") or "."
local f = assert(loadfile(here.."/Sources/HistorySerializer.lua"))
f()

local S  = WIM.SerializeHistoryTable
local D  = WIM.DeserializeHistoryBlob
local SM = WIM.SummarizeHistoryTable

assert(type(S) == "function", "SerializeHistoryTable missing")
assert(type(D) == "function", "DeserializeHistoryBlob missing")
assert(type(SM) == "function", "SummarizeHistoryTable missing")

local pass, fail = 0, 0
local function check(name, cond, extra)
  if cond then pass = pass + 1; print("  PASS  "..name)
  else fail = fail + 1; print("  FAIL  "..name..(extra and ("  -> "..tostring(extra)) or "")) end
end

-- deep compare
local function deepEq(a, b, path)
  path = path or "root"
  if type(a) ~= type(b) then return false, path.." type "..type(a).."~="..type(b) end
  if type(a) ~= "table" then
    if a ~= b then return false, path.." value "..tostring(a).."~="..tostring(b) end
    return true
  end
  for k, v in pairs(a) do
    local ok, why = deepEq(v, b[k], path.."."..tostring(k))
    if not ok then return false, why end
  end
  for k in pairs(b) do
    if a[k] == nil then return false, path.."."..tostring(k).." only in second" end
  end
  return true
end

print("=== 1. Basic round-trip with realistic WIM records ===")
local hist = {
  ["Alice"] = {
    info = { gm = false },
    { convo="Alice", type=1, inbound=true,  from="Alice", msg="Hey there!", time=1714000000 },
    { convo="Alice", type=1, inbound=false, from="Bob",   msg="Hi Alice",   time=1714000010 },
  },
  ["Trade"] = {
    info = { chat = true, channelNumber = 2 },
    { event="CHAT_MSG_CHANNEL", channelName="Trade", type=2, from="Rando-Realm",
      msg="WTS [Thunderfury]", time=1714000100 },
  },
  ["Friend#1234"] = {
    info = {},
    { convo="Friend#1234", type=1, inbound=true, from="Friend#1234",
      msg="yo", time=1714005000 },
  },
}
local blob = S(hist)
local back, err = D(blob)
check("deserialize returns a table", back ~= nil, err)
local ok, why = deepEq(hist, back)
check("round-trip is lossless", ok, why)

print("")
print("=== 2. Nasty strings (the real risk) ===")
local nasty = {
  ["Quote\"Guy"] = {
    info = {},
    { msg = 'he said "hello" and left',                       time=1, type=1 },
    { msg = "back\\slash and \\\\double",                     time=2, type=1 },
    { msg = "line1\nline2\r\nline3",                          time=3, type=1 },
    { msg = "tab\there",                                      time=4, type=1 },
    { msg = "|cff00ff00|Hitem:19019::::::::60:::::|h[Thunderfury]|h|r", time=5, type=1 },
    { msg = "unicode: äöü 中文 emoji ✔",                      time=6, type=1 },
    { msg = "nul\0byte",                                      time=7, type=1 },
    { msg = "percent %s %d %q formats",                       time=8, type=1 },
    { msg = "]]==] long bracket attempt",                     time=9, type=1 },
    { msg = "",                                               time=10, type=1 },
  },
}
local blob2 = S(nasty)
local back2, err2 = D(blob2)
check("nasty strings deserialize", back2 ~= nil, err2)
if back2 then
  local ok2, why2 = deepEq(nasty, back2)
  check("nasty strings round-trip losslessly", ok2, why2)
end

print("")
print("=== 3. Numbers ===")
local nums = { c = { info={},
  { time = 1714000000, type = 1, n1 = 0, n2 = -5, n3 = 3.14159, n4 = 1e15,
    n5 = 0.1, n6 = 2147483647, n7 = -2147483648 } } }
local back3, err3 = D(S(nums))
check("numbers deserialize", back3 ~= nil, err3)
if back3 then
  local ok3, why3 = deepEq(nums, back3)
  check("numbers round-trip exactly", ok3, why3)
end

print("")
print("=== 4. Edge cases ===")
check("empty table -> 'return {}'", S({}) == "return {}", S({}))
local e = D(S({}))
check("empty blob deserializes to empty table", type(e)=="table" and next(e)==nil)
check("nil input is tolerated", S(nil) == "return {}")
local bad, badErr = D("this is not lua {{{")
check("garbage blob returns nil + error", bad == nil and badErr ~= nil, badErr)
local bad2, badErr2 = D("return 42")
check("non-table blob returns nil + error", bad2 == nil and badErr2 ~= nil, badErr2)
local bad3, badErr3 = D(nil)
check("nil blob returns nil + error", bad3 == nil and badErr3 ~= nil)

print("")
print("=== 5. Sandbox: blob cannot touch globals ===")
_G.CANARY = "untouched"
local evil = D('return (function() CANARY = "PWNED"; return {} end)()')
check("blob executed in empty env cannot write globals", _G.CANARY == "untouched", _G.CANARY)

print("")
print("=== 6. Summarize ===")
local c, r = SM(hist)
check("SummarizeHistoryTable counts convos", c == 3, c)
check("SummarizeHistoryTable counts records", r == 4, r)

print("")
print("=== 7. Booleans / mixed array+hash ===")
local mixed = { k = { info = { a=true, b=false }, "one", "two", "three", extra="x" } }
local back7, err7 = D(S(mixed))
check("mixed array+hash deserializes", back7 ~= nil, err7)
if back7 then
  local ok7, why7 = deepEq(mixed, back7)
  check("mixed array+hash round-trips", ok7, why7)
end

print("")
print(string.format("RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(1) end
