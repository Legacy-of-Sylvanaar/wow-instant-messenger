local WIM = WIM;

-- imports
local _G = _G;
local table = table;
local type = type;
local string = string;
local pairs = pairs;

-- set namespace
setfenv(1, WIM);


constants.classes = {};
local classes = constants.classes;

local classList = {
     "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue",
     "Shaman", "Warlock", "Warrior",  "Death Knight", "Monk", "Demon Hunter"
};

constants.classListEng = classList;

local GetNumSpecializationsForClassID, GetSpecializationInfoForClassID = _G.GetNumSpecializationsForClassID, _G.GetSpecializationInfoForClassID
local function createSpecNameTable(classID)
	local t = {}
	if not isShadowlands then return t end
	for spec = 1, GetNumSpecializationsForClassID(classID) do
		local specID, name = GetSpecializationInfoForClassID(classID,spec)
		t[spec] = name
	end
	return t
end
--Male Classes - this doesn't apply to every locale
classes[L["Druid"]]	= {
                              color = "ff7d0a",
                              tag = "DRUID",
                              talent = createSpecNameTable(11)
                         };
classes[L["Hunter"]]	= {
                              color = "abd473",
                              tag = "HUNTER",
                              talent = createSpecNameTable(3)
                         };
classes[L["Mage"]]	= {
                              color = "69ccf0",
                              tag = "MAGE",
                              talent = createSpecNameTable(8)
                         };
classes[L["Paladin"]]	= {
                              color = "f58cba",
                              tag = "PALADIN",
                              talent = createSpecNameTable(2)
                         };
classes[L["Priest"]]	= {
                              color = "ffffff",
                              tag = "PRIEST",
                              talent = createSpecNameTable(5)
                         };
classes[L["Rogue"]]	= {
                              color = "fff569",
                              tag = "ROGUE",
                              talent = createSpecNameTable(4)
                         };
classes[L["Shaman"]]	= {
                              color = "2459FF",
                              tag = "SHAMAN",
                              talent = createSpecNameTable(7)
                         };
classes[L["Warlock"]]	= {
                              color = "9482ca",
                              tag = "WARLOCK",
                              talent = createSpecNameTable(9)
                         };
classes[L["Warrior"]]	= {
                              color = "c79c6e",
                              tag = "WARRIOR",
                              talent = createSpecNameTable(1)
                         };
classes[L["Death Knight"]] = {
                              color = "c41f3b",
                              tag = "DEATHKNIGHT",
                              talent = createSpecNameTable(6)
                         };
classes[L["Monk"]]		= {
                              color = "00ff96",
                              tag = "MONK",
                              talent = createSpecNameTable(10)
                         };
classes[L["Demon Hunter"]]	= {
                              color = "a330c9",
                              tag = "DEMONHUNTER",
                              talent = createSpecNameTable(12)
                         };
classes[L["Game Master"]] = {
                              color = "00c0ff",
                              tag = "GM",
                              talent = {"", "", ""} -- talent place holder
                         };

-- propigate female class types and update tags appropriately
for i=1, table.getn(classList) do
     if(L[classList[i]] ~= L[classList[i].."F"]) then
          classes[L[classList[i].."F"]] = {
               color = classes[L[classList[i]]].color,
               tag = classes[L[classList[i]]].tag.."F"
          };
     end
end


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
     local classColorTable = _G.RAID_CLASS_COLORS[englishClass];
     return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..name.."\124r"
end

function classes.GetColoredNameByChatEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
     if(arg12 and arg12 ~= "") then
	    	 local type = _G.strsplit("-", arg12 or "")
	    	 if type ~= "Player" then return arg2 end--Blizzard didn't return a valid guid, so abort class colors
          local localizedClass, englishClass, localizedRace, englishRace, sex = _G.GetPlayerInfoByGUID(arg12)
          if ( englishClass ) then
               local classColorTable = _G.RAID_CLASS_COLORS[englishClass];
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
