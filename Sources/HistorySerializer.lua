--imports
local WIM = WIM;
local _G = _G;
local type = type;
local pairs = pairs;
local table = table;
local string = string;
local tostring = tostring;
local tonumber = tonumber;
local pcall = pcall;
local next = next;
local loadstring = loadstring or load;   -- `load` is the 5.2+ name; WoW keeps both
local setfenv = setfenv;
local format = string.format;
local find = string.find;
local gsub = string.gsub;
local concat = table.concat;
local floor = math.floor;

--set namespace
setfenv(1, WIM);

-- ---------------------------------------------------------------------------
-- History blob serializer
--
-- WHY THIS EXISTS
--
-- (For reference: WoW only loads the SavedVariablesPerCharacter file of the character
-- you are currently logged into. There is no API to read another character's
-- per-character file. That means a pure per-character history store makes
-- cross-character history viewing impossible -- which is exactly the
-- regression this module exists to undo.
--
-- Anything that must be visible from every character has to live in an
-- ACCOUNT-WIDE SavedVariables file. But account-wide storage is what blew up
-- in the first place: Lua 5.1's per-chunk constant table caps at
-- MAXARG_Bx == 2^18 - 1 == 262,143 unique constants, and a full account's
-- history of native Lua tables sails past that at around 25MB.
--
-- The approach this module implements: the constant-table limit counts the
-- NUMBER of unique constants, not their SIZE. A single 10MB string literal
-- is exactly ONE constant. So instead of storing each character's history
-- as a native nested table (hundreds of thousands of constants), it is
-- stored as a single serialized string:
--
--     WIM3_HistoryArchive["Moon Guard"]["Bob"] = {
--         blob = "return {[\"Alice\"]={...}}",   -- ONE constant
--         updated = 1714000000,
--     }
--
-- An account with 200 characters then costs roughly 250 constants in
-- total, well below the limit. The account-wide file can grow to any size
-- the filesystem tolerates without tripping the parser.
--
-- Reading a blob back uses loadstring(), which compiles the blob as its own
-- chunk. Each character therefore keeps a full, independent 262,143
-- constant budget, exactly like the per-character file did.
--
-- FORMAT NOTES
--
-- The blob is plain Lua source of the form `return { ... }`. It is not
-- pretty-printed: no newlines and no indentation, because WoW writes the
-- blob into a SavedVariables file and escapes the string again. Every byte
-- added here is paid for twice.
--
-- String escaping uses string.format("%q", s). In Lua 5.1 that escapes exactly
-- the characters that matter for a double-quoted literal -- '"', '\', newline,
-- carriage return and NUL -- and passes everything else through untouched,
-- including UTF-8 and WoW's own |c / |H / |T markup. It is implemented in C, so
-- it is dramatically faster than escaping by hand in Lua.
-- ---------------------------------------------------------------------------


-- Chunked string builder.
--
-- Appending several million fragments to one table and calling
-- table.concat once at the end works, but holds every fragment in memory
-- at the same time. Collapsing the buffer every N appends is O(n^2). This
-- two-level buffer keeps it O(n): small fragments accumulate in `chunk`,
-- and every FLUSH_AT fragments the chunk is collapsed into a single string
-- appended to `parts`.
local FLUSH_AT = 4096;

local function newBuffer()
    return { parts = {}, chunk = {}, n = 0 };
end

local function bufAdd(buf, s)
    local n = buf.n + 1;
    buf.chunk[n] = s;
    buf.n = n;
    if (n >= FLUSH_AT) then
        buf.parts[#buf.parts + 1] = concat(buf.chunk);
        buf.chunk = {};
        buf.n = 0;
    end
end

local function bufFinish(buf)
    if (buf.n > 0) then
        -- concat only the populated prefix of the chunk table
        local tail = {};
        for i = 1, buf.n do tail[i] = buf.chunk[i]; end
        buf.parts[#buf.parts + 1] = concat(tail);
    end
    return concat(buf.parts);
end


-- Quote a string as a Lua short-string literal.
--
-- string.format("%q") does most of the work in C, but Lua 5.1's
-- implementation has two problems that need patching:
--
--   1. It does not escape carriage returns. The 5.1 lexer treats a raw \r
--      inside a short string literal as a line break, so the literal never
--      closes and the whole blob fails to compile with "unfinished string
--      near ...". One stray \r in one chat message would make an entire
--      character's archived history unreadable. (Lua 5.2 fixed this; WoW
--      is still on 5.1.)
--
--   2. It escapes a newline as a backslash followed by a real newline.
--      That is valid Lua, but it makes the blob multi-line for no benefit
--      and costs an extra byte per newline, paid twice because WoW escapes
--      the blob again when writing the SavedVariables file.
--
-- Both fix-ups are guarded by a plain-text find(), so the common case (no
-- \r, no \n) costs nothing beyond the C-level %q call.
local function quoteString(s)
    local q = format("%q", s);
    if (find(s, "\r", 1, true)) then
        q = gsub(q, "\r", "\\r");
    end
    if (find(s, "\n", 1, true)) then
        -- collapse  backslash + real newline  ->  \n
        q = gsub(q, "\\\n", "\\n");
    end
    return q;
end


-- Serialize a single value into the buffer.
--
-- Only the value types WIM's history actually contains are supported:
-- string, number, boolean, and table. Anything else (function, userdata)
-- is written as nil instead of aborting the whole serialization. Losing
-- one stray field is far better than losing a character's entire history.
local function serializeValue(v, buf)
    local t = type(v);
    if (t == "string") then
        bufAdd(buf, quoteString(v));
    elseif (t == "number") then
        -- tostring() round-trips both integers and floats through the Lua
        -- lexer correctly. Integers come out without a decimal point, which
        -- keeps the blob compact.
        bufAdd(buf, tostring(v));
    elseif (t == "boolean") then
        bufAdd(buf, v and "true" or "false");
    elseif (t == "table") then
        bufAdd(buf, "{");

        -- Array part first, without explicit keys. This is both smaller and
        -- faster to compile than [1]=..,[2]=..
        local arrayLen = #v;
        for i = 1, arrayLen do
            serializeValue(v[i], buf);
            bufAdd(buf, ",");
        end

        -- Hash part: everything that is not part of the contiguous 1..#v run.
        for k, val in pairs(v) do
            local skip = false;
            if (type(k) == "number" and k >= 1 and k <= arrayLen and floor(k) == k) then
                skip = true;    -- already emitted in the array part above
            end
            if (not skip) then
                local kt = type(k);
                if (kt == "string") then
                    bufAdd(buf, "[");
                    bufAdd(buf, quoteString(k));
                    bufAdd(buf, "]=");
                    serializeValue(val, buf);
                    bufAdd(buf, ",");
                elseif (kt == "number") then
                    bufAdd(buf, "[");
                    bufAdd(buf, tostring(k));
                    bufAdd(buf, "]=");
                    serializeValue(val, buf);
                    bufAdd(buf, ",");
                end
                -- boolean/table keys are silently dropped; WIM never uses them
            end
        end

        bufAdd(buf, "}");
    else
        bufAdd(buf, "nil");
    end
end


-- Serialize a character's history table (the {convoName = {info=..,records..}}
-- tree) into a self-contained Lua chunk.
--
-- Returns the blob string. A nil or empty input serializes to
-- "return {}" instead of failing, so callers never have to special-case
-- brand-new characters.
function SerializeHistoryTable(tbl)
    if (type(tbl) ~= "table") then
        return "return {}";
    end
    local buf = newBuffer();
    bufAdd(buf, "return ");
    serializeValue(tbl, buf);
    return bufFinish(buf);
end


-- Decode a blob produced by SerializeHistoryTable back into a table.
--
-- Returns (table, nil) on success or (nil, errorMessage) on failure. Every
-- failure mode is caught:
--   * loadstring() can fail to compile the blob, most importantly with
--     "constant table overflow" if one character somehow exceeded 262,143
--     unique constants, the error this architecture exists to avoid.
--   * the compiled chunk can fail when run (unlikely for data-only source,
--     but possible for a blob truncated by a partial disk write).
--   * the chunk can return a non-table.
--
-- Callers should treat a nil return as "this character's archive copy is
-- unusable" and fall back to what else they have. For the active
-- character that is the per-character SavedVariables file, which is why it
-- is kept as a redundant backup.
function DeserializeHistoryBlob(blob)
    if (type(blob) ~= "string" or blob == "") then
        return nil, "blob is empty or not a string";
    end

    local chunk, compileErr = loadstring(blob, "WIM-history-blob");
    if (not chunk) then
        return nil, "compile failed: " .. tostring(compileErr);
    end

    -- Run the chunk in an empty environment. The blob is data-only, but
    -- this is the one place in WIM that executes a string, so the chunk
    -- must not reach any global even if a file was edited by hand.
    if (setfenv) then
        setfenv(chunk, {});
    end

    local ok, result = pcall(chunk);
    if (not ok) then
        return nil, "execution failed: " .. tostring(result);
    end
    if (type(result) ~= "table") then
        return nil, "blob did not return a table";
    end
    return result, nil;
end


-- Count conversations and records in a history table. The result fills
-- the small metadata stored next to each blob, so the History Viewer can
-- describe a character without decoding it.
function SummarizeHistoryTable(tbl)
    local convos, records = 0, 0;
    if (type(tbl) ~= "table") then
        return 0, 0;
    end
    for _, msgs in pairs(tbl) do
        if (type(msgs) == "table") then
            convos = convos + 1;
            records = records + #msgs;
        end
    end
    return convos, records;
end
