local WIM = WIM;

-- imports
local _G = _G;
local type = type;
local string = string;
local pairs = pairs;

-- set namespace
setfenv(1, WIM);


constants.classes = {};
local classes = constants.classes;

-- Class data keyed by the game's class tag. The colors are WIM's
-- traditional class colors and stay independent of RAID_CLASS_COLORS.
local classData = {
     { eng = "Druid",        tag = "DRUID",       id = 11, color = "ff7d0a" },
     { eng = "Hunter",       tag = "HUNTER",      id = 3,  color = "abd473" },
     { eng = "Mage",         tag = "MAGE",        id = 8,  color = "69ccf0" },
     { eng = "Paladin",      tag = "PALADIN",     id = 2,  color = "f58cba" },
     { eng = "Priest",       tag = "PRIEST",      id = 5,  color = "ffffff" },
     { eng = "Rogue",        tag = "ROGUE",       id = 4,  color = "fff569" },
     { eng = "Shaman",       tag = "SHAMAN",      id = 7,  color = "2459FF" },
     { eng = "Warlock",      tag = "WARLOCK",     id = 9,  color = "9482ca" },
     { eng = "Warrior",      tag = "WARRIOR",     id = 1,  color = "c79c6e" },
     { eng = "Death Knight", tag = "DEATHKNIGHT", id = 6,  color = "c41f3b" },
     { eng = "Monk",         tag = "MONK",        id = 10, color = "00ff96" },
     { eng = "Demon Hunter", tag = "DEMONHUNTER", id = 12, color = "a330c9" },
     { eng = "Evoker",       tag = "EVOKER",      id = 13, color = "33937f" },
};

local classList = {};
for i = 1, #classData do
     classList[i] = classData[i].eng;
end
constants.classListEng = classList;

local GetNumSpecializationsForClassID, GetSpecializationInfoForClassID = _G.GetNumSpecializationsForClassID, _G.GetSpecializationInfoForClassID
local function createSpecNameTable(classID)
	local t = {}
	if not isModernApi then return t end
	for spec = 1, GetNumSpecializationsForClassID(classID) do
		local specID, name = GetSpecializationInfoForClassID(classID,spec)
		t[spec] = name
	end
	return t
end
-- The table is keyed by localized class names because that is what the
-- friends, guild, who, and Battle.net APIs hand back. The names come
-- from the client's own LOCALIZED_CLASS_NAMES tables, so every locale
-- resolves without addon translations. Hand-translated L entries are
-- kept as extra keys so older saved data still matches.
local maleNames = _G.LOCALIZED_CLASS_NAMES_MALE or {};
local femaleNames = _G.LOCALIZED_CLASS_NAMES_FEMALE or {};

for i = 1, #classData do
     local c = classData[i];
     local entry = {
          color = c.color,
          tag = c.tag,
          talent = createSpecNameTable(c.id)
     };
     local male = maleNames[c.tag] or L[c.eng];
     classes[male] = entry;
     if(not classes[L[c.eng]]) then
          classes[L[c.eng]] = entry;
     end

     local female = femaleNames[c.tag];
     if(female and female ~= male and not classes[female]) then
          classes[female] = {
               color = c.color,
               tag = c.tag.."F",
               talent = entry.talent
          };
     end
     -- locales that translated the female form by hand keep that key.
     local lFemale = L[c.eng.."F"];
     if(lFemale ~= c.eng.."F" and lFemale ~= male and not classes[lFemale]) then
          classes[lFemale] = {
               color = c.color,
               tag = c.tag.."F",
               talent = entry.talent
          };
     end
end

classes[L["Game Master"]] = {
                              color = "00c0ff",
                              tag = "GM",
                              talent = {"", "", ""} -- talent place holder
                         };


classes.GetClassByTag = function(t)
     for class, tbl in pairs(classes) do
          if(type(tbl) == "table") then
               if(tbl.tag == t) then
                    return class;
               end
          end
     end
     -- can't find tag, before returning blank, see we're being asked for a female class, then try again.
     local ft = string.gsub(t, "(F)$", "");
     if( ft == t) then
          return ""
     else
          return classes.GetClassByTag(ft);
     end
end

function classes.GetMyColoredName()
     local name = _G.UnitName("player");
     local class, englishClass = _G.UnitClass("player");
     local classColorTable = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[englishClass];
     return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..name.."\124r"
end

function classes.GetColoredNameByChatEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
     if HasAnySecretValues(arg2, arg12) then
          return arg2;
     end
     if(arg12 and arg12 ~= "") then
	    	 local type = _G.strsplit("-", arg12 or "")
	    	 if type ~= "Player" then return arg2 end--Blizzard didn't return a valid guid, so abort class colors
          local localizedClass, englishClass, localizedRace, englishRace, sex = _G.GetPlayerInfoByGUID(arg12)
          if ( englishClass ) then
               local classColorTable = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[englishClass];
               if ( not classColorTable ) then
                    return arg2;
               end
               return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r"
          else
               return arg2;
          end
    else
          return arg2;
    end
end
