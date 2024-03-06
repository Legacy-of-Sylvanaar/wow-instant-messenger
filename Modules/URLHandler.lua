--imports
local WIM = WIM;
local _G = _G;
local strsub = strsub;
local string = string;
local format = format;
local table = table;
local type = type;
local pairs = pairs;

--set namespace
setfenv(1, WIM);

db_defaults.displayColors.webAddress = {
    r = 1,
    g = 1,
    b = 1
};

local URL = CreateModule("URLHandler", true);

armoryLinks = {
    {
		title = "Wowhead Profiler",
		url = "http://www.wowhead.com/profile={eu/us}.{realm-}.{user}",
    },
    {
        title = "WoWProgress",
        url = "http://www.wowprogress.com/character/{eu/us}/{realm}/{user}"
    },
		{
        title = "Raider io",
        url = "https://raider.io/characters/{eu/us}/{realm}/{user}"
    },
    {
        title = "Warcraft Logs",
        url = "https://www.warcraftlogs.com/character/{eu/us}/{realm}/{user}"
    },
    {
        title = "Warcraft Logs Vanilla",
        url = "https://vanilla.warcraftlogs.com/character/{eu/us}/{realm}/{user}"
    },
	{
		title = "Warcraft Logs Season of Mastery",
		url = "https://sod.warcraftlogs.com/character/{us/eu}/{realm}/{user}"
	}
};

-- patterns created by Sylvanaar & used in Prat
local patterns = {
      -- X://Y url
      "^(%a[%w+.-]+://%S+)",
      "%f[%S](%a[%w+.-]+://%S+)",
      -- www.X.Y url
      "^(www%.[-%w_%%]+%.(%a%a+))",
      "%f[%S](www%.[-%w_%%]+%.(%a%a+))",
      -- "W X"@Y.Z email (this is seriously a valid email)
      '^(%"[^%"]+%"@[%w_.-%%]+%.(%a%a+))',
      '%f[%S](%"[^%"]+%"@[%w_.-%%]+%.(%a%a+))',
      -- X@Y.Z email
      "(%S+@[%w_.-%%]+%.(%a%a+))",
      -- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
      "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
      "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
      -- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
      "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
      "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
      -- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
      "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
      "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
      -- XXX.YYY.ZZZ.WWW IPv4 address
      "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
      "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
      -- X.Y.Z:WWWW/VVVVV url with port and path
      "^([%w_.-%%]+[%w_-%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
      "%f[%S]([%w_.-%%]+[%w_-%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
      -- X.Y.Z:WWWW url with port (ts server for example)
      "^([%w_.-%%]+[%w_-%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
      "%f[%S]([%w_.-%%]+[%w_-%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
      -- X.Y.Z/WWWWW url with path
      "^([%w_.-%%]+[%w_-%%]%.(%a%a+)/%S+)",
      "%f[%S]([%w_.-%%]+[%w_-%%]%.(%a%a+)/%S+)",
      -- X.Y.Z url
      "^([-%w_%%]+%.[-%w_%%]+%.(%a%a+))",
      "%f[%S]([-%w_%%]+%.[-%w_%%]+%.(%a%a+))",
      "^([-%w_%%]+%.(%a%a+))",
      "%f[%S]([-%w_%%]+%.(%a%a+))",
};


local LinkRepository = {};

local function formatRawURL(theURL)
    if(type(theURL) ~= "string" or theURL == "") then
        return "";
    else
        theURL = theURL:gsub('%%', '%%%%'); --make sure any %'s are escaped in order to preserve them.
        return " |cff"..RGBPercentToHex(db.displayColors.webAddress.r, db.displayColors.webAddress.g, db.displayColors.webAddress.b).."|Hwim_url:"..theURL.."|h".."["..theURL.."]".."|h|r";
    end
end

local decodeURI
do
   local char, gsub, tonumber = string.char, string.gsub, _G.tonumber
   local function decode(hex) return char(tonumber(hex, 16)) end

   function decodeURI(s)
      s = gsub(s, '%%(%x%x)', decode)
      return s
   end
end

local function encodeColors(theMsg)
    theMsg = string.gsub(theMsg, "|c", "\001\002");
    theMsg = string.gsub(theMsg, "|r", "\001\003");
    return theMsg;
end

local function decodeColors(theMsg)
    theMsg = string.gsub(theMsg, "\001\002", "|c");
    theMsg = string.gsub(theMsg, "\001\003", "|r");
    return theMsg;
end

local function convertURLtoLinks(text)
	-- clean text first
	local theMsg = text;
	local results;

	-- sanitize string of any % characters
	theMsg = string.gsub(theMsg, "%%", "%%%%");

	theMsg = decodeURI(theMsg)
	theMsg = encodeColors(theMsg);
	repeat
		theMsg, results = string.gsub(theMsg, "(|H[^|]+|h.-|h)", function(theLink)
			table.insert(LinkRepository, theLink);
			return "\001\004"..#LinkRepository;
		end, 1);
	until results == 0;

	-- create urls
	for i=1, table.getn(patterns) do
		theMsg = string.gsub(theMsg, patterns[i], formatRawURL);
	end

	--restore links
	for i=1, #LinkRepository do
		theMsg = string.gsub(theMsg, "\001\004"..i.."", LinkRepository[i]);
	end

	-- clear table to be recycled by next process
	for key, _ in pairs(LinkRepository) do
		LinkRepository[key] = nil;
	end

	-- desanitize string of any % characters
	theMsg = string.gsub(theMsg, "%%%%", "%%");

	return decodeColors(theMsg);
end

local function modifyURLs(str)
    return convertURLtoLinks(str);
end


function URL:OnEnable()
    RegisterStringModifier(modifyURLs, true);
end

function URL:OnDisable()
    UnregisterStringModifier(modifyURLs);
end


local function isLinkTypeURL(link)
	if (strsub(link, 1, 7) == "wim_url") then
		return true;
	else
		return false;
	end
end

local function displayURL(link)
    local theLink = "";
    if (string.len(link) > 4) and (string.sub(link,1,8) == "wim_url:") then
			theLink = string.sub(link,9, string.len(link));
    end
    -- The following code was written by Sylvannar.
    _G.StaticPopupDialogs["WIM_SHOW_URL"] = {
    	preferredIndex = STATICPOPUP_NUMDIALOGS,
        text = "URL : %s",
        button2 = _G.ACCEPT,
        hasEditBox = 1,
        hasWideEditBox = 1,
		editBoxWidth = 350,
        showAlert = 1, -- HACK : it"s the only way I found to make de StaticPopup have sufficient width to show WideEditBox :(
        OnShow = function(self)
                self = self or _G.this; -- tbc hack
                local editBox = _G.getglobal(self:GetName().."WideEditBox") or _G.getglobal(self:GetName().."EditBox");
                editBox:SetText(theLink); --removed "format" becasue it cause errors on some character names it seems!
                editBox:SetFocus();
                editBox:HighlightText(0);

                local button = _G.getglobal(self:GetName().."Button2");
                button:ClearAllPoints();
                button:SetWidth(100);
                button:SetPoint("CENTER", editBox, "CENTER", 0, -30);

                _G.getglobal(self:GetName().."AlertIcon"):Hide();  -- HACK : we hide the false AlertIcon
            end,
        OnHide = function() end,
        OnAccept = function() end,
        OnCancel = function() end,
        EditBoxOnEscapePressed = function(self)
                self = self or _G.this; -- tbc hack
                self:GetParent():Hide();
            end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    };
    _G.StaticPopup_Show ("WIM_SHOW_URL", theLink);
end

WIM.RegisterItemRefHandler("wim_url", displayURL);

--context menu
local isUS = false
if _G.GetCurrentRegion() == 1 then
	isUS = true
end
local function MENU_ARMORY_CLICKED(self)
    local eu_www = isUS and "www" or "eu";
    local eu_us = isUS and "us" or "eu";
    local armory_eu_us = isUS and "en-us" or "en-gb";
    local user, realm;
    if(MENU_ARMORY_USER:find("-")) then
        --user, realm = string.split("-", MENU_ARMORY_USER);
		user, realm = GetNameAndServer(MENU_ARMORY_USER)
    else
        user = MENU_ARMORY_USER;
		local _
		_, realm = GetNameAndServer("-"..MENU_ARMORY_REALM)
    end
    realm = realm or MENU_ARMORY_REALM;
    local link = self.value;
    link = link:gsub("{eu/www}", eu_www);
	realm = string.gsub(realm, "'", "")
    --link = link:gsub("{realm}", realm);
    link = link:gsub("{realm}", (string.gsub(realm,"  ","-")));
    link = link:gsub("{realm%-}", (string.gsub(realm," ","-")));
    link = link:gsub("{user}", user);
    link = link:gsub("{eu/us}", eu_us);
    link = link:gsub("{armeu/armus}", armory_eu_us);
    link = link:gsub("{EU/US}", string.upper(eu_us));
    displayURL("wim_url:"..link);
end

-- this menu is not available for private servers.. der..
if(not isPrivateServer) then
    local info = {};
    info.text = "MENU_ARMORY";
    local armoryMenu = AddContextMenu(info.text, info);
        info.text = L["Profile Links"];
        info.notCheckable = true;
        info.isTitle = true;
        armoryMenu:AddSubItem(AddContextMenu("MENU_ARMORY_TITLE", info));
        for i=1, #armoryLinks do
            info = {};
            info.text = armoryLinks[i].title;
            info.value = armoryLinks[i].url;
            info.notCheckable = true;
            info.func = MENU_ARMORY_CLICKED;
            armoryMenu:AddSubItem(AddContextMenu("MENU_ARMORY"..i, info));
        end
        --armoryMenu:AddSubItem(GetContextMenu("MENU_CANCEL"));
end
