local WIM = WIM;
local _G = _G;
local type = type;
local table = table;
local math = math;
local string = string;
local tonumber = tonumber;

setfenv(1, WIM);

local OPTIONS_SCHEMA = 1;

local function fixValues()
    if (db.expose and type(db.expose.protect) == "number") then
        db.expose.protect = (db.expose.protect ~= 0);
    end
    if (type(db.messageFormat) ~= "string") then
        db.messageFormat = "Default";
    end
end

local function mergeHistoryCaps()
    local h = db.history;
    local hc = h and h.chat;
    if (not hc) then
        return;
    end
    if (hc.maxPer ~= nil or hc.maxCount ~= nil) then
        local wOn, cOn = h.maxPer and true or false, hc.maxPer and true or false;
        if (wOn and cOn) then
            h.maxCount = math.min(tonumber(h.maxCount) or 500, tonumber(hc.maxCount) or 500);
        elseif (cOn and not wOn) then
            h.maxCount = tonumber(hc.maxCount) or 500;
        end
        h.maxPer = wOn or cOn;
    end
    if (hc.ageLimit ~= nil or hc.maxAge ~= nil) then
        local wOn, cOn = h.ageLimit and true or false, hc.ageLimit and true or false;
        local TWO_WEEKS = 60*60*24*14;
        if (wOn and cOn) then
            h.maxAge = math.min(tonumber(h.maxAge) or TWO_WEEKS, tonumber(hc.maxAge) or TWO_WEEKS);
        elseif (cOn and not wOn) then
            h.maxAge = tonumber(hc.maxAge) or TWO_WEEKS;
        end
        h.ageLimit = wOn or cOn;
    end
    hc.maxPer, hc.maxCount, hc.ageLimit, hc.maxAge = nil, nil, nil, nil;
    hc.preview, hc.previewCount = nil, nil;
end

local function adoptModernSkin()
    local selected = db.skin and db.skin.selected;
    if (selected ~= nil and selected ~= "WIM Classic"
        and not string.match(selected, "^WIM Classic %- ")) then
        return;
    end
    if (db.skin and GetSkinTable and GetSkinTable("WIM Modern")) then
        db.skin.selected = "WIM Modern";
    end
end

local POP_STATES = {"arena", "combat", "pvp", "raid", "party", "resting"};
local POP_KEYS = {"onSend", "onReceive", "autofocus", "keepfocus", "supress"};
local POP_WINDOW_TYPES = {"whisper", "chat"};

local function derivePopRuleInheritance()
    for w = 1, #POP_WINDOW_TYPES do
        local rules = db.pop_rules and db.pop_rules[POP_WINDOW_TYPES[w]];
        if (rules and rules.alwaysOther ~= nil) then
            local base = rules.other or {};
            for s = 1, #POP_STATES do
                local set = rules[POP_STATES[s]];
                if (set) then
                    if (rules.alwaysOther) then
                        set.custom = false;
                    else
                        local differs = false;
                        for k = 1, #POP_KEYS do
                            local key = POP_KEYS[k];
                            if ((set[key] and true or false) ~= (base[key] and true or false)) then
                                differs = true;
                                break;
                            end
                        end
                        set.custom = differs;
                    end
                end
            end
            rules.alwaysOther = nil;
        end
    end
end

local function scrubDeadKeys()
    db.windowOnTop = nil;
    db.keepFocus = nil;
    db.keepFocusRested = nil;
    db.autoFocus = nil;
    db.lastState = nil;
    db.alertedPrivateServer = nil;
    db.stats = nil;
    db.alias = nil;
    if (db.displayColors) then
        db.displayColors.useSkin = nil;
    end
    if (db.chat and db.chat.say) then
        db.chat.say.showEmotes = nil;
    end
    if (db.chat) then
        db.chat.bn = nil;
    end
    if (db.pop_rules and db.pop_rules.chat) then
        db.pop_rules.chat.intercept = nil;
        db.pop_rules.chat.bn = nil;
        db.pop_rules.chat.alwaysOther = nil;
    end
    if (db.pop_rules and db.pop_rules.whisper) then
        db.pop_rules.whisper.alwaysOther = nil;
    end
    if (db.history and db.history.chat) then
        db.history.chat.preview = nil;
        db.history.chat.previewCount = nil;
    end
end

local function repairFilterPatterns()
    local filters = _G.WIM3_Filters;
    if (type(filters) ~= "table") then
        return;
    end
    for i = 1, #filters do
        local f = filters[i];
        if (type(f) == "table" and f.protected and f.tag == "addons" and type(f.pattern) == "string") then
            if (f.pattern:find("^/^GA", 1, true)) then
                f.pattern = f.pattern:gsub("%^/%^GA", "^/\n^GA");
            end
            if (f[1] == "^OQ[,S]") then
                table.remove(f, 1);
                if (not f.pattern:find("^OQ[,S]", 1, true)) then
                    f.pattern = f.pattern.."\n^OQ[,S]";
                end
            end
        end
    end
end

function MigrateOptions()
    if (not db) then
        return;
    end
    if ((db.optionsSchema or 0) < OPTIONS_SCHEMA) then
        fixValues();
        mergeHistoryCaps();
        adoptModernSkin();
        derivePopRuleInheritance();
        db.optionsSchema = OPTIONS_SCHEMA;
    end
    scrubDeadKeys();
    repairFilterPatterns();
end
