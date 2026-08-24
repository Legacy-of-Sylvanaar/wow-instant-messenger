--imports
local WIM = WIM;
local _G = _G;
local table = table;
local string = string;
local pairs = pairs;
local CreateFrame = CreateFrame;
local type = type;
local tonumber = tonumber;
local unpack = unpack;
local time = time;
local select = select;

-- Defined before the setfenv: C_Texture.GetAtlasInfo resolves helper
-- mixins (Vector2DMixin) through the caller's environment, so calling
-- it from inside the WIM environment throws. Same pattern as
-- Modules/UISnapshot.lua.
local C_Texture = C_Texture;
local function getAtlasInfoRaw(name)
    if (C_Texture and C_Texture.GetAtlasInfo) then
        return C_Texture.GetAtlasInfo(name);
    end
    return nil;
end

local DDM = WIM.libs.DropDownMenu;

--set namespace
setfenv(1, WIM);

--[[
    type:   1 - Pattern
            2 - User Type
            3 - Level -- no longer possible since removal of who.

    action: 1 - Allow
            2 - Ignore
            3 - Block
]]

--Default Filters
local DefaultFilters = {
    {
        name = L["Whispers Sent by Addons"],
        type = 1,
        tag = "addons",
        pattern = "^<T>PartyQuests[^A-Z]+\n"..
                    "^<M_N>\n"..
                    "^ItemDB-Request:\n"..
                    "^LVBM\n"..
                    "^YOU ARE BEING WATCHED!\n"..
                    "^YOU ARE MARKED!\n"..
                    "^YOU ARE CURSED!\n"..
                    "^YOU HAVE THE PLAGUE!\n"..
                    "^YOU ARE BURNING!\n"..
                    "^YOU ARE THE BOMB!\n"..
                    "VOLATILE INFECTION\n"..
                    "^/"..
                    "^GA[^A-Z]+\n"..
                    "^<METAMAP\n"..
                    "^<CT",
                    "^OQ[,S]",
        action = 2,
        stats = 0,
        protected = true,
        enabled = true,
        received = true,
        sent = true
    },
    {
        name = L["WhisperSelect Part 1"],
        enabled = false;
        type = 2,
        action = 1,
        friend = true,
        party = true,
        raid = true,
        guild = true,
        received = true,
        stats = 0
    },
    -- Who lookups are no longer possible. this filter is no longer possible.
    -- {
    --     name = L["Example Spam Blocker"],
    --     enabled = false;
    --     type = 3,
    --     action = 3,
    --     level = 2,
    --     received = true,
    --     notify = true,
    --     stats = 0
    -- },
    {
        name = L["WhisperSelect Part 2"],
        enabled = false;
        type = 2,
        action = 2,
        all = true,
        received = true,
        stats = 0
    }
};


local filterFrame;

local maxLevel = 80;

local Filters = CreateModule("Filters", true);

-- Whisper Filters
function Filters:OnEnable()
	-- filter out filters using Who lookups.
	for i = #filters, 1, -1 do
		if (filters[i].type == 3) then
			table.remove(filters, i);
		end
	end
end

--Chat Filters
local ChatFilters = CreateModule("ChatFilters");

function ChatFilters:OnEnable()
    -- filter out filters using Who lookups.
    for i = #chatFilters, 1, -1 do
        if (chatFilters[i].type == 3) then
            table.remove(chatFilters, i);
        end
    end
end

-- filtering

local blockedEvents = {};

local EVENT_CACHE_SECONDS = 10;
local EVENT_CACHE_PRUNE_FREQUENCY = EVENT_CACHE_SECONDS / 4;
local eventCache = {};
local eventResultCache = {};
local eventCacheLastRun = time();
local whitelistedMessages = {};

local function logBlockedEvent(event, ...)
    -- only blocked events whishing a notification will be logged.
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;
    if(event == "CHAT_MSG_WHISPER_INFORM") then
        arg2 = _G.UnitName("player");
    end
    if(arg11 and blockedEvents[arg11] == nil) then
        blockedEvents[arg11] = {event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11};
        arg2 = _G.Ambiguate(arg2, "none")
        local msg = "|cffff7d0a"..L["WIM has blocked a message from %s."].." |r|cffff0000[|HWIMBLOCKED:"..arg11.."|h"..L["View Blocked Message"].."|h]|r"
        _G.DEFAULT_CHAT_FRAME:AddMessage(msg:gsub("%%s", "|r[|Hplayer:"..arg2.."|h"..arg2.."|h]|cffff7d0a"));
    end
end

-- run filter against chat event using caching
local function runFilter(filter, event, ...)
	local message, from, _, _, _, _, _, _, _, _, messageId = ...

	-- prune cache
	local now = time();
	if (eventCacheLastRun + EVENT_CACHE_PRUNE_FREQUENCY) < now then
		for key, val in pairs(eventCache) do
			if (val + EVENT_CACHE_SECONDS) < now then
				eventCache[key] = nil;
				eventResultCache[key] = nil;
			end
		end
		eventCacheLastRun = now;
	end

	-- if in cache, return cached result
	if (messageId and eventCache[messageId]) then
		local result = eventResultCache[messageId];

		return result
	else
		local result;

		from = _G.Ambiguate(from, "none");

		-- pattern
		if(filter.type == 1) then
			local patterns = filter.pattern.."\n";
			local start, stop, pattern = string.find(patterns, "([^\n]+)\n", 1);
			while(pattern) do
				pattern = string.trim(pattern);
				if(pattern ~= "" and string.find(message, pattern)) then
					filter.stats = filter.stats + 1;
					result = filter.action;
					break;
				end
				start, stop, pattern = string.find(patterns, "([^\n]+)\n", stop + 1);
			end

		-- user
		elseif(filter.type == 2) then
			if(filter.all or (filter.friend and (lists.friends[from] or _G.UnitName("player") == from)) or (filter.guild and (lists.guild[from] or _G.UnitName("player") == from)) or
				(filter.party and (IsInParty(from) or _G.UnitName("player") == from)) or (filter.raid and (IsInRaid(from) or _G.UnitName("player") == from)) or
				(filter.xrealm and string.find(from, "%-"))) then
					filter.stats = filter.stats + 1;
					result = filter.action;
			end
		end

		-- cache result
		if (messageId) then
			eventCache[messageId] = now;
			eventResultCache[messageId] = result;

			if result == 3 and filter.notify then
				logBlockedEvent(event, ...)
			end
		end

		return result
	end
end

function WIM.IgnoreOrBlockEvent(event, ...)
	-- check for secret values
	if (IsSecretValue(select(1, ...)) or IsSecretValue(select(2, ...))) then
		return false, false;
	end

	-- ignore non-chat events
	if event:sub(0, 9) ~= 'CHAT_MSG_' then
		return false, false
	end

	-- first check if message is whitelisted
	local msgId = select(11, ...)
	if (msgId and whitelistedMessages[msgId]) then
		return false, false
	end

	local message, from = ...
	from = _G.Ambiguate(from, "none")

	local _filters, sent = {}, false;

	-- whisper filters
	if event:sub(0, 16) == 'CHAT_MSG_WHISPER' or event:sub(0,19) == 'CHAT_MSG_BN_WHISPER' then
		if (not Filters.enabled) then
			return false, false
		end

		_filters = filters;
		sent = event == 'CHAT_MSG_WHISPER_INFORM' or event == 'CHAT_MSG_BN_WHISPER_INFORM';

	-- chat filters
	else
		if (not ChatFilters.enabled) then
			return false, false
		end

		_filters = chatFilters;
		sent = from == _G.UnitName("player");
	end

	-- run through filters
	for i=1, #_filters do
		local filter = _filters[i];

		if filter.enabled and (filter.received and not sent or filter.sent and sent) then
			local result = runFilter(filter, event, ...);
			if result then
				-- allow
				if (result == 1) then
					return false, false

				-- ignore
				elseif result == 2 then
					return true, false

				-- block
				elseif result == 3 then
					return false, true
				end
			end
		end
	end

	return false, false
end

-- Globals
function GetDefaultFilters()
    return DefaultFilters;
end



-- Options UI

local function createFilterFrame()
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local win = CreateFrame("Frame", "WIM3_FilterFrame", _G.UIParent, "BackdropTemplate");

    win:Hide();
    win.filter = {};
    -- set size and position
    win:SetWidth(475);
    win:SetHeight(390);
    win:SetPoint("CENTER");

    -- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    win.backdropInfo = {bgFile = "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\Frame_Background",
        edgeFile = "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\Frame",
        tile = true, tileSize = 64, edgeSize = 64,
        insets = { left = 64, right = 64, top = 64, bottom = 64 }};

	win:ApplyBackdrop();

    -- set basic frame properties
    win:SetClampedToScreen(true);
    win:SetFrameStrata("DIALOG");
    win:SetMovable(true);
    win:SetToplevel(true);
    win:EnableMouse(true);
    win:RegisterForDrag("LeftButton");

    -- set script events
    win:SetScript("OnDragStart", function(self) self:StartMoving(); end);
    win:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end);

    -- create and set title bar text
    win.title = win:CreateFontString(win:GetName().."Title", "OVERLAY", "ChatFontNormal");
    win.title:SetPoint("TOPLEFT", 50 , -20);
    local font = win.title:GetFont();
    win.title:SetFont(font, 16, "");

    -- create close button
    win.close = CreateFrame("Button", win:GetName().."Close", win);
    win.close:SetWidth(18); win.close:SetHeight(18);
    win.close:SetPoint("TOPRIGHT", -24, -20);
    win.close:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
    win.close:SetHighlightTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\close", "BLEND");
    win.close:SetScript("OnClick", function(self)
            self:GetParent():Hide();
        end);

    -- create filter name
    win.nameText = win:CreateFontString(win:GetName().."NameText", "OVERLAY", "ChatFontNormal");
    win.nameText:SetText(L["Filter Name"]..":");
    win.nameText:SetTextColor(_G.GameFontNormal:GetTextColor());
    win.nameText:SetPoint("TOPLEFT", 30, -60);
    win.name = CreateFrame("EditBox", win:GetName().."Name", win);
    win.name:SetFontObject(_G.ChatFontNormal);
    win.name:SetPoint("TOPLEFT", win.nameText, "TOPLEFT", win.nameText:GetStringWidth()+10, 2);
    win.name:SetPoint("BOTTOMLEFT", win.nameText, "BOTTOMLEFT", win.nameText:GetStringWidth()+10, 0);
    win.name:SetPoint("RIGHT", -30, 0);
    win.name:SetAutoFocus(false);
    win.name:SetScript("OnTextChanged", function(self)
            win.filter.name = self:GetText();
        end);
    win.name:SetScript("OnShow", function(self)
            win.filter.name = win.filter.name or "";
            self:SetText(win.filter.name);
        end);
    win.name:SetScript("OnEscapePressed", function(self) self:ClearFocus() end);
    options.AddFramedBackdrop(win.name);

    --create filter by
    win.byText = win:CreateFontString(win:GetName().."By_Text", "OVERLAY", "ChatFontNormal");
    win.byText:SetText(L["Filter By"]..":");
    win.byText:SetTextColor(_G.GameFontNormal:GetTextColor());
    win.byText:SetPoint("TOPLEFT", win.nameText, "BOTTOMLEFT", 0, -20);
	win.by = DDM.Create_DropDownMenu(win:GetName().."By", win)
	win.by:SetParent(win);
    win.by:SetPoint("TOPLEFT", win.byText, "TOPLEFT", win.byText:GetStringWidth()+8, 8);
    win.by.click = function(self)
            self = self or _G.this;
            win.filter.type = self.value;
            DDM.UIDropDownMenu_SetSelectedValue(win.by, self.value);
            win.by:Hide();
            win.by:Show();
        end
    win.by.init = function(self)
            local info = {};
            info.text = L["Pattern"];
            info.value = 1;
            info.func = win.by.click;
            DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
            info = {};
            info.text = L["User Type"];
            info.value = 2;
            info.func = win.by.click;
            DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
            -- if(not win.isChat) then
            --     local info = {};
            --     info.text = L["Level"];
            --     info.value = 3;
            --     info.func = win.by.click;
            --     DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
            -- end
        end
    win.by:SetScript("OnShow", function(self)
            win.filter.type = win.filter.type or 1;
            DDM.UIDropDownMenu_Initialize(self, self.init);
            DDM.UIDropDownMenu_SetSelectedValue(self, win.filter.type);
            if(win.filter.type == 1) then
                win.patternContainer:Show();
                win.user:Hide();
                win.level:Hide();
            elseif(win.filter.type == 2) then
                win.patternContainer:Hide();
                win.user:Show();
                win.level:Hide();
            else
                win.patternContainer:Hide();
                win.user:Hide();
                win.level:Show();
            end
        end);

    -- create patterns box
    win.patternContainer = CreateFrame("ScrollFrame", win:GetName().."PatternContainer", win, "UIPanelScrollFrameTemplate");
    win.patternContainer:SetPoint("TOPLEFT", win.byText, "BOTTOMLEFT", 0, -25);
    win.patternContainer:SetPoint("RIGHT", -50, 0);
    win.patternContainer:SetHeight(95);
    options.AddFramedBackdrop(win.patternContainer);
    win.pattern = CreateFrame("EditBox", win:GetName().."Pattern", win.patternContainer);
    win.pattern:SetFontObject(_G.ChatFontNormal);
    win.patternContainer:SetScrollChild(win.pattern);
    win.pattern:SetWidth(win.patternContainer:GetWidth());
    win.pattern:SetHeight(200);
    win.pattern:SetMultiLine(true);
    win.pattern:SetAutoFocus(false);
    win.pattern:SetScript("OnTextChanged", function(self)
            win.filter.pattern = self:GetText();
            win.patternContainer:UpdateScrollChildRect();
        end);
    win.pattern:SetScript("OnShow", function(self)
            win.filter.pattern = win.filter.pattern or "";
            self:SetText(win.filter.pattern);
        end);
    win.pattern:SetScript("OnEscapePressed", function(self) self:ClearFocus() end);

    --create user options
    win.user = CreateFrame("Frame", win:GetName().."UserFrame", win);
    win.user:SetPoint("TOPLEFT", win.patternContainer, "TOPLEFT");
    win.user:SetPoint("BOTTOMLEFT", win.patternContainer, "BOTTOMLEFT");
    win.user:SetPoint("RIGHT", -30, 0)
    win.user:Hide();
    options.AddFramedBackdrop(win.user);
    win.user.friend = CreateFrame("CheckButton", win.user:GetName().."Friend", win.user, "UICheckButtonTemplate");
    win.user.friend:SetPoint("TOPLEFT", 0, 0);
    _G.getglobal(win.user.friend:GetName().."Text"):SetText(L["Friends"]);
    win.user.friend:SetScript("OnShow", function(self) self:SetChecked(win.filter.friend); end);
    win.user.friend:SetScript("OnClick", function(self) win.filter.friend = self:GetChecked(); end);
    win.user.guild = CreateFrame("CheckButton", win.user:GetName().."Guild", win.user, "UICheckButtonTemplate");
    win.user.guild:SetPoint("TOPLEFT", win.user.friend, "BOTTOMLEFT");
    _G.getglobal(win.user.guild:GetName().."Text"):SetText(L["Guild Members"]);
    win.user.guild:SetScript("OnShow", function(self) self:SetChecked(win.filter.guild); end);
    win.user.guild:SetScript("OnClick", function(self) win.filter.guild = self:GetChecked(); end);
    win.user.party = CreateFrame("CheckButton", win.user:GetName().."Party", win.user, "UICheckButtonTemplate");
    win.user.party:SetPoint("TOPLEFT", win.user.guild, "BOTTOMLEFT");
    _G.getglobal(win.user.party:GetName().."Text"):SetText(L["Party Members"]);
    win.user.party:SetScript("OnShow", function(self) self:SetChecked(win.filter.party); end);
    win.user.party:SetScript("OnClick", function(self) win.filter.party = self:GetChecked(); end);

    win.user.raid = CreateFrame("CheckButton", win.user:GetName().."Raid", win.user, "UICheckButtonTemplate");
    win.user.raid:SetPoint("TOPLEFT", win.user:GetWidth()/2, 0);
    _G.getglobal(win.user.raid:GetName().."Text"):SetText(L["Raid Members"]);
    win.user.raid:SetScript("OnShow", function(self) self:SetChecked(win.filter.raid); end);
    win.user.raid:SetScript("OnClick", function(self) win.filter.raid = self:GetChecked(); end);
    win.user.xrealm = CreateFrame("CheckButton", win.user:GetName().."XRealm", win.user, "UICheckButtonTemplate");
    win.user.xrealm:SetPoint("TOPLEFT", win.user.raid, "BOTTOMLEFT");
    _G.getglobal(win.user.xrealm:GetName().."Text"):SetText(L["Cross-Realm"]);
    win.user.xrealm:SetScript("OnShow", function(self) self:SetChecked(win.filter.xrealm); end);
    win.user.xrealm:SetScript("OnClick", function(self) win.filter.xrealm = self:GetChecked(); end);
    win.user.all = CreateFrame("CheckButton", win.user:GetName().."All", win.user, "UICheckButtonTemplate");
    win.user.all:SetPoint("TOPLEFT", win.user.xrealm, "BOTTOMLEFT");
    _G.getglobal(win.user.all:GetName().."Text"):SetText(L["Everyone"]);
    win.user.all:SetScript("OnShow", function(self)
            self:SetChecked(win.filter.all);
            if(not win.filter.all) then
                win.user.friend:Enable();   win.user.friend:SetAlpha(1);
                win.user.guild:Enable();    win.user.guild:SetAlpha(1);
                win.user.party:Enable();    win.user.party:SetAlpha(1);
                win.user.raid:Enable();     win.user.raid:SetAlpha(1);
                win.user.xrealm:Enable();   win.user.xrealm:SetAlpha(1);
            else
                win.user.friend:Disable();  win.user.friend:SetAlpha(.5);
                win.user.guild:Disable();   win.user.guild:SetAlpha(.5);
                win.user.party:Disable();   win.user.party:SetAlpha(.5);
                win.user.raid:Disable();    win.user.raid:SetAlpha(.5);
                win.user.xrealm:Disable();  win.user.xrealm:SetAlpha(.5);
            end
        end);
    win.user.all:SetScript("OnClick", function(self) win.filter.all = self:GetChecked(); self:Hide(); self:Show(); end);

    --create level options
    win.level = CreateFrame("Frame", win:GetName().."LevelFrame", win);
    win.level:SetPoint("TOPLEFT", win.patternContainer, "TOPLEFT");
    win.level:SetPoint("BOTTOMLEFT", win.patternContainer, "BOTTOMLEFT");
    win.level:SetPoint("RIGHT", -30, 0)
    win.level:Hide();
    options.AddFramedBackdrop(win.level);

	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	win.level.slider = CreateFrame("Slider", win.level:GetName().."Slider", win.level, "BackdropTemplate");

    -- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    win.level.slider.backdropInfo = {bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 }};

	win.level.slider:ApplyBackdrop();

    win.level.slider:SetHeight(17);
    --win.level.slider:SetPoint("CENTER");
    win.level.slider:SetPoint("TOPLEFT", 20, -30);
    win.level.slider:SetPoint("RIGHT", -65, 0);
    win.level.slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal");
    win.level.slider:SetOrientation("HORIZONTAL");
    win.level.slider:SetMinMaxValues(2, maxLevel);
    win.level.slider.title = win.level.slider:CreateFontString(win.level.slider:GetName().."Title", "OVERLAY", "ChatFontNormal");
    win.level.slider.title:SetPoint("BOTTOMLEFT", win.level.slider, "TOPLEFT", 0, 5);
    win.level.slider.title:SetText(L["User must be at least level:"]);
    win.level.slider.title:SetTextColor(_G.GameFontNormal:GetTextColor());
    win.level.slider.minText = win.level.slider:CreateFontString(win.level.slider:GetName().."Min", "OVERLAY", "ChatFontSmall");
    win.level.slider.minText:SetPoint("TOPLEFT", win.level.slider, "BOTTOMLEFT", 5, 0);
    win.level.slider.minText:SetText("2");
    win.level.slider.maxText = win.level.slider:CreateFontString(win.level.slider:GetName().."Max", "OVERLAY", "ChatFontSmall");
    win.level.slider.maxText:SetPoint("TOPRIGHT", win.level.slider, "BOTTOMRIGHT", -5, 0);
    win.level.slider.maxText:SetText(maxLevel);
    win.level.slider.valText = win.level.slider:CreateFontString(win.level.slider:GetName().."Val", "OVERLAY", "ChatFontSmall");
    win.level.slider.valText:SetPoint("LEFT", win.level.slider, "RIGHT", 15, 2);
    win.level.slider.valText:SetTextColor(_G.GameFontNormal:GetTextColor());
    win.level.slider.valText:SetText("");
    win.level.slider:SetValueStep(1);
    win.level.slider:SetScript("OnValueChanged", function(self)
            self.valText:SetText(self:GetValue());
            win.filter.level = self:GetValue();
        end);
    win.level.slider:SetScript("OnShow", function(self)
            win.filter.level = win.filter.level or 2;
            self:SetValue(tonumber(win.filter.level));
        end);
    win.level.classText = win.level:CreateFontString(win:GetName().."ClassSpecific", "OVERLAY", "ChatFontSmall");
    win.level.classText:SetText(L["Apply to:"]);
    win.level.classText:SetPoint("TOPLEFT", 20, -70);
    win.level.classText:SetTextColor(_G.GameFontNormal:GetTextColor());
	win.level.class = DDM.Create_DropDownMenu(win:GetName().."ClassList", win.level)
	win.level.class:SetParent(win.level);
    win.level.class:SetPoint("TOPLEFT", win.level.classText, "TOPLEFT", win.level.classText:GetStringWidth()+8, 8);
    win.level.class.click = function(self)
            self = self or _G.this;
            win.filter.classSpecific = self.value;
            DDM.UIDropDownMenu_SetSelectedValue(win.level.class, self.value);
            win.level.class:Hide();
            win.level.class:Show();
        end
    win.level.class.init = function(self)
		local info = {};
		info.text = L["All Classes"];
		info.value = 0;
		info.func = win.level.class.click;
	    local classes = constants.classListEng;
	    DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
	    for i=1, #classes do
			info = {};
			info.text = L[classes[i]];
			info.value = constants.classes[L[classes[i]]].tag;
			info.func = win.level.class.click;
			DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
	    end
    end
    win.level.class:SetScript("OnShow", function(self)
            win.filter.classSpecific = win.filter.classSpecific or 0;
            DDM.UIDropDownMenu_Initialize(self, self.init);
            DDM.UIDropDownMenu_SetSelectedValue(self, win.filter.classSpecific);
        end);




    --create incoming out going
    win.received = CreateFrame("CheckButton", win:GetName().."In", win, "UICheckButtonTemplate");
    win.received:SetPoint("TOPLEFT", win.patternContainer, "BOTTOMLEFT", 0, -10);
    win.received.text = _G.getglobal(win.received:GetName().."Text");
    win.received.text:SetText(L["Apply to messages received."]);
    win.received:SetScript("OnShow", function(self)
            win.filter.received = win.filter.received;
            self:SetChecked(win.filter.received);
        end);
    win.received:SetScript("OnClick", function(self)
            win.filter.received = self:GetChecked() and true or nil;
        end);
    win.sent = CreateFrame("CheckButton", win:GetName().."Out", win, "UICheckButtonTemplate");
    win.sent:SetPoint("TOPLEFT", win.received, "TOPRIGHT", win.received.text:GetStringWidth() + 10, 0);
    _G.getglobal(win.sent:GetName().."Text"):SetText(L["Apply to messages sent."]);
    win.sent:SetScript("OnShow", function(self)
            win.filter.sent = win.filter.sent;
            self:SetChecked(win.filter.sent);
        end);
    win.sent:SetScript("OnClick", function(self)
            win.filter.sent = self:GetChecked() and true or nil;
        end);


    --create action
    win.actionText = win:CreateFontString(win:GetName().."Action_Text", "OVERLAY", "ChatFontNormal");
    win.actionText:SetText(L["Action to Perform:"]);
    win.actionText:SetTextColor(_G.GameFontNormal:GetTextColor());
    win.actionText:SetPoint("TOPLEFT", win.received, "BOTTOMLEFT", 0, -20);
	win.action = DDM.Create_DropDownMenu(win:GetName().."Action", win);
	win.action:SetParent(win);
    win.action:SetPoint("TOPLEFT", win.actionText, "TOPLEFT", win.actionText:GetStringWidth()+8, 8);
    win.action.click = function(self)
            self = self or _G.this;
            win.filter.action = self.value;
            DDM.UIDropDownMenu_SetSelectedValue(win.action, self.value);
            win.action:Hide();
            win.action:Show();
        end
    win.action.init = function(self)
            local info = {};
            info.text = L["Allow"];
            info.value = 1;
            info.func = win.action.click;
            DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
            info = {};
            info.text = L["Ignore"];
            info.value = 2;
            info.func = win.action.click;
            DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
            info = {};
            info.text = L["Blocked"];
            info.value = 3;
            info.func = win.action.click;
            DDM.UIDropDownMenu_AddButton(info, DDM.UIDropDownMenu_MENU_LEVEL);
        end
    win.actionNotify = CreateFrame("CheckButton", win:GetName().."Notify", win, "UICheckButtonTemplate");
    win.actionNotify:SetPoint("LEFT", win.action, "RIGHT", 130, 2);
    win.actionNotify.text = _G.getglobal(win.actionNotify:GetName().."Text");
    win.actionNotify.text:SetText(L["Show Alert"]);
    win.actionNotify:SetScript("OnShow", function(self)
            win.filter.notify = win.filter.notify;
            self:SetChecked(win.filter.notify);
        end);
    win.actionNotify:SetScript("OnClick", function(self)
            win.filter.notify = self:GetChecked() and true or nil;
        end);

    win.action:SetScript("OnShow", function(self)
            win.filter.action = win.filter.action or 2;
            DDM.UIDropDownMenu_Initialize(self, self.init);
            DDM.UIDropDownMenu_SetSelectedValue(self, win.filter.action);
            if(win.filter.action ~= 3) then
                win.actionNotify:Hide();
            else
                win.actionNotify:Show();
            end
        end);


    -- cancel / save
    win.border = win:CreateTexture(nil, "OVERLAY");
    win.border:SetHeight(1);
    win.border:SetWidth(win:GetWidth() - 60);
    win.border:SetPoint("BOTTOM", 0, 55);
    win.border:SetColorTexture(1, 1, 1, .25);
    win.save = CreateFrame("Button", win:GetName().."Save", win, "UIPanelButtonTemplate");
    win.save:SetPoint("TOPRIGHT", win.border, "BOTTOMRIGHT", 0, -5);
    win.save.text = _G[win.save:GetName().."Text"];
    win.save.text:SetText(L["Save"]);
    win.save:SetWidth(win.save.text:GetStringWidth()+60);
    win.save:SetScript("OnClick", function(self)
	    if win.filter.classSpecific == 0 then
		win.filter.classSpecific = nil;
	    end
            if(win.saveIndex) then
                -- save edited filter
                local filters = win.isChat and chatFilters or filters;
                filters[win.saveIndex] = win.filter;
            else
                -- add new filter
                local filters = win.isChat and chatFilters or filters;
                win.filter.enabled = true;
                win.filter.stats = 0;
                table.insert(filters, 1, win.filter);
                -- The classic lists exist only once the classic window has
                -- been built; the editor also serves the modern options.
                if(win.isChat) then
                    if(options.frame and options.frame.chatFilterList) then
                        options.frame.chatFilterList.selected = 1;
                    end
                else
                    if(options.frame and options.frame.filterList) then
                        options.frame.filterList.selected = 1;
                    end
                end
            end
            win:Hide();
        end);
    win.cancel = CreateFrame("Button", win:GetName().."Cancel", win, "UIPanelButtonTemplate");
    win.cancel:SetPoint("TOPRIGHT", win.save, "TOPLEFT", -10, 0);
    win.cancel.text = _G[win.cancel:GetName().."Text"];
    win.cancel.text:SetText(L["Cancel"]);
    win.cancel:SetWidth(win.cancel.text:GetStringWidth()+60);
    win.cancel:SetScript("OnClick", function(self) win:Hide(); end);

    -- window actions
    win:SetScript("OnShow", function(self)
            _G.PlaySound(850);
            if(options.frame) then
                options.frame:Disable();
            end
        end);
    win:SetScript("OnHide", function(self)
            self.saveIndex = nil;
            _G.PlaySound(851);
            if(options.frame) then
                options.frame:Enable();
                local list = self.isChat and options.frame.chatFilterList
                             or options.frame.filterList;
                if(list) then
                    list:Hide();
                    list:Show();
                end
            end
            -- Keep the modern filter lists in step too.
            if(options.NotifyModernSettings) then
                options.NotifyModernSettings();
            end
        end);

    table.insert(_G.UISpecialFrames,win:GetName());

    return win;
end







-- The editor opens from both option styles; its chrome follows the
-- style in use. Modern dress is the chat window and History Viewer's
-- frame: the metal nine-slice (or the shipped copy of its pieces), a
-- title band, and the themed backgrounds with the optional cut-out.
-- The chrome sits BELOW the dialog's own frame level so the labels,
-- which are regions of the dialog, stay above every chrome texture.
local function hasAtlas(name)
    local ok, info = _G.pcall(getAtlasInfoRaw, name);
    return ok and info ~= nil;
end

local function applyModernChromeTheme(win)
    local m = win.wimModernChrome;
    if(not m) then return; end
    local theme = db.modernTheme or {};
    -- The well hosts whichever filter-type panel is active, so the
    -- filter-area background and cut-out apply to all of them. Each
    -- surface repaints only when its own choice changed, so changing
    -- one background never redraws the other.
    local cutout = theme.filterCutout and true or false;
    local frameChanged = (m.wimFrameKey ~= theme.filterFrame)
        or (m.wimCutout ~= cutout);
    m.wimFrameKey, m.wimCutout = theme.filterFrame, cutout;
    m.bg:SetShown(not cutout);
    if(not cutout and frameChanged) then
        ApplyChromeBackgroundChoice(m.bg, theme.filterFrame);
    end
    for i=1, #m.strips do
        m.strips[i]:SetShown(cutout);
    end
    m.well.bg:Show();
    if(m.wimPanelKey ~= theme.filterPanel) then
        m.wimPanelKey = theme.filterPanel;
        ApplyChromeBackgroundChoice(m.well.bg, theme.filterPanel);
    end
    if(cutout) then
        ApplyChromeBackgroundToStrips(m.strips, m.bg, theme.filterFrame);
    end
end

local function applyFilterTypePanels(win)
    local filterType = win.filter.type or 1;
    win.patternContainer:SetShown(filterType == 1);
    win.user:SetShown(filterType == 2);
    win.level:SetShown(filterType == 3);
    if(win.wimModernStyled) then
        applyModernChromeTheme(win);
        -- The slim bar sits beside the well, not inside the pattern
        -- box, so it follows the pattern panel's visibility itself.
        local bar = win.wimSlimBar;
        if(bar and bar ~= "unavailable" and bar.SetShown) then
            if(filterType == 1) then
                local _, maxValue = bar:GetMinMaxValues();
                bar:SetShown((maxValue or 0) > 1);
            else
                bar:Hide();
            end
        end
    end
end

local function buildModernChrome(win)
    if(win.wimModernChrome ~= nil) then return win.wimModernChrome; end
    local chrome = CreateFrame("Frame", nil, win);
    chrome:SetAllPoints();
    chrome:SetFrameLevel(_G.math.max(win:GetFrameLevel() - 2, 0));
    local built;
    if(HasPortraitPanelArt()) then
        local apply = _G.NineSliceUtil and _G.NineSliceUtil.ApplyLayoutByName;
        built = apply and _G.pcall(apply, chrome, "ButtonFrameTemplateNoPortrait");
    else
        chrome.metal = BuildLiteMetalFrame(chrome, false);
        built = chrome.metal and true or false;
    end
    if(not built) then
        chrome:Hide();
        win.wimModernChrome = false;
        return false;
    end
    -- The same fill geometry the History Viewer measured for this art.
    chrome.bg = chrome:CreateTexture(nil, "BACKGROUND", nil, -8);
    chrome.bg:SetPoint("TOPLEFT", 7, -18);
    chrome.bg:SetPoint("BOTTOMRIGHT", 0, 3);

    -- The pattern well: even margins to the frame edges, dressed in
    -- the recessed inset the History Viewer's panes wear. The pattern
    -- box re-anchors inside it while the modern dress is on.
    local well = CreateFrame("Frame", nil, win);
    well:SetPoint("TOPLEFT", win.byText, "BOTTOMLEFT", -16, -17);
    well:SetPoint("RIGHT", win, "RIGHT", -14, 0);
    well:SetHeight(111);
    well:SetFrameLevel(chrome:GetFrameLevel());
    well.bg = well:CreateTexture(nil, "BACKGROUND", nil, -7);
    well.bg:SetPoint("TOPLEFT", 2, -2);
    well.bg:SetPoint("BOTTOMRIGHT", -2, 2);
    local applyLayout = _G.NineSliceUtil and _G.NineSliceUtil.ApplyLayoutByName;
    if(applyLayout) then
        _G.pcall(applyLayout, well, "InsetFrameTemplate");
    end
    chrome.well = well;

    -- The name field wears the search-band art the History Viewer's
    -- search bar and the themed input use.
    if(hasAtlas("common-search-border-left")
            and hasAtlas("common-search-border-middle")
            and hasAtlas("common-search-border-right")) then
        -- Explicit sizes, the History Viewer search bar's rendered
        -- rects: the atlases are authored larger.
        local bandL = win:CreateTexture(nil, "BACKGROUND");
        bandL:SetAtlas("common-search-border-left");
        bandL:SetSize(8, 20);
        bandL:SetPoint("LEFT", win.name, "LEFT", -8, 0);
        local bandR = win:CreateTexture(nil, "BACKGROUND");
        bandR:SetAtlas("common-search-border-right");
        bandR:SetSize(8, 20);
        bandR:SetPoint("RIGHT", win.name, "RIGHT", 8, 0);
        local bandM = win:CreateTexture(nil, "BACKGROUND");
        bandM:SetAtlas("common-search-border-middle");
        bandM:SetPoint("TOPLEFT", bandL, "TOPRIGHT");
        bandM:SetPoint("BOTTOMRIGHT", bandR, "BOTTOMLEFT");
        chrome.nameBand = { bandL, bandM, bandR };
    end

    local function strip()
        return chrome:CreateTexture(nil, "BACKGROUND");
    end
    local top, left, right, bottom = strip(), strip(), strip(), strip();
    top:SetPoint("TOPLEFT", chrome.bg, "TOPLEFT");
    top:SetPoint("RIGHT", chrome.bg, "RIGHT");
    top:SetPoint("BOTTOM", well, "TOP");
    bottom:SetPoint("BOTTOMLEFT", chrome.bg, "BOTTOMLEFT");
    bottom:SetPoint("RIGHT", chrome.bg, "RIGHT");
    bottom:SetPoint("TOP", well, "BOTTOM");
    left:SetPoint("TOPLEFT", top, "BOTTOMLEFT");
    left:SetPoint("BOTTOMLEFT", bottom, "TOPLEFT");
    left:SetPoint("RIGHT", well, "LEFT");
    right:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT");
    right:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT");
    right:SetPoint("LEFT", well, "RIGHT");
    chrome.strips = { top, left, right, bottom };

    -- Cut-out strips window their picture from the settled rects, and
    -- the pattern text re-wraps to the re-anchored box.
    local function settleModern()
        if(not (win:IsShown() and win.wimModernStyled)) then return; end
        applyModernChromeTheme(win);
        local width = win.patternContainer:GetWidth() or 0;
        if(width > 0) then
            win.pattern:SetWidth(width);
        end
    end
    win:HookScript("OnShow", function()
        _G.C_Timer.After(0, settleModern);
    end);
    win:HookScript("OnSizeChanged", settleModern);

    win.wimModernChrome = chrome;
    return chrome;
end

local ACTION_ITEMS = {
    { value = 1, label = function() return L["Allow"]; end },
    { value = 2, label = function() return L["Ignore"]; end },
    { value = 3, label = function() return L["Blocked"]; end },
};

local BY_ITEMS = {
    { value = 1, label = function() return L["Pattern"]; end },
    { value = 2, label = function() return L["User Type"]; end },
};

local function buildModernDropdowns(win)
    if(win.wimModernDrops ~= nil) then return win.wimModernDrops; end
    local ok1, action = _G.pcall(CreateFrame, "DropdownButton", nil, win,
        "WowStyle1DropdownTemplate");
    local ok2, class = _G.pcall(CreateFrame, "DropdownButton", nil, win.level,
        "WowStyle1DropdownTemplate");
    local ok3, by = _G.pcall(CreateFrame, "DropdownButton", nil, win,
        "WowStyle1DropdownTemplate");
    if(not (ok1 and action and ok2 and class and ok3 and by)) then
        win.wimModernDrops = false;
        return false;
    end

    by:SetPoint("LEFT", win.byText, "RIGHT", 12, 0);
    by:SetSize(140, 24);
    DarkenModernDropdown(by);
    PadModernMenus(by);
    by:SetupMenu(function(_, rootDescription)
        DarkenModernMenusOnAcquire(rootDescription);
        for i=1, #BY_ITEMS do
            local value, text = BY_ITEMS[i].value, BY_ITEMS[i].label();
            rootDescription:CreateRadio(text,
                function() return (win.filter.type or 1) == value; end,
                function()
                    win.filter.type = value;
                    by:OverrideText(text);
                    applyFilterTypePanels(win);
                end);
        end
    end);
    win.byModern = by;

    action:SetPoint("LEFT", win.actionText, "RIGHT", 12, 0);
    action:SetSize(130, 24);
    DarkenModernDropdown(action);
    PadModernMenus(action);
    action:SetupMenu(function(_, rootDescription)
        DarkenModernMenusOnAcquire(rootDescription);
        for i=1, #ACTION_ITEMS do
            local value, text = ACTION_ITEMS[i].value, ACTION_ITEMS[i].label();
            rootDescription:CreateRadio(text,
                function() return (win.filter.action or 2) == value; end,
                function()
                    win.filter.action = value;
                    action:OverrideText(text);
                    win.actionNotify:SetShown(value == 3);
                end);
        end
    end);
    win.actionModern = action;

    local function classEntries()
        local list = { { value = 0, text = L["All Classes"] } };
        local classes = constants.classListEng;
        for i=1, #classes do
            table.insert(list, { value = constants.classes[L[classes[i]]].tag,
                text = L[classes[i]] });
        end
        return list;
    end
    class:SetPoint("LEFT", win.level.classText, "RIGHT", 12, 0);
    class:SetSize(160, 24);
    DarkenModernDropdown(class);
    PadModernMenus(class);
    class:SetupMenu(function(_, rootDescription)
        DarkenModernMenusOnAcquire(rootDescription);
        local list = classEntries();
        for i=1, #list do
            local value, text = list[i].value, list[i].text;
            rootDescription:CreateRadio(text,
                function() return (win.filter.classSpecific or 0) == value; end,
                function()
                    win.filter.classSpecific = value;
                    class:OverrideText(text);
                end);
        end
    end);
    win.classModern = class;

    win.RefreshModernDropdowns = function()
        win.filter.type = win.filter.type or 1;
        for i=1, #BY_ITEMS do
            if(BY_ITEMS[i].value == win.filter.type) then
                by:OverrideText(BY_ITEMS[i].label());
            end
        end
        applyFilterTypePanels(win);
        win.filter.action = win.filter.action or 2;
        for i=1, #ACTION_ITEMS do
            if(ACTION_ITEMS[i].value == win.filter.action) then
                action:OverrideText(ACTION_ITEMS[i].label());
            end
        end
        win.actionNotify:SetShown(win.filter.action == 3);
        local cur = win.filter.classSpecific or 0;
        local list = classEntries();
        for i=1, #list do
            if(list[i].value == cur) then
                class:OverrideText(list[i].text);
            end
        end
    end;
    win.wimModernDrops = true;
    return true;
end

local function filterCheckboxes(win)
    return { win.received, win.sent, win.actionNotify,
        win.user.friend, win.user.guild, win.user.party,
        win.user.raid, win.user.xrealm, win.user.all };
end

-- The native settings checkbox art; the classic template art comes
-- back when the classic options style is active.
local function styleFilterCheckbox(check, modern)
    if(modern) then
        check:SetSize(26, 26);
        check:SetNormalAtlas("checkbox-minimal");
        check:SetPushedAtlas("checkbox-minimal");
        check:SetHighlightAtlas("checkbox-minimal", "ADD");
        check:GetCheckedTexture():SetAtlas("checkmark-minimal");
        local disabled = check.GetDisabledCheckedTexture
            and check:GetDisabledCheckedTexture();
        if(disabled) then
            disabled:SetAtlas("checkmark-minimal-disabled");
        end
    else
        check:SetSize(32, 32);
        check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
        check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
        check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD");
        check:GetCheckedTexture():SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
        local disabled = check.GetDisabledCheckedTexture
            and check:GetDisabledCheckedTexture();
        if(disabled) then
            disabled:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
        end
    end
end

local function styleFilterFrame(win)
    -- Modern dress follows the Modern skin, like the chat windows and
    -- the History Viewer, so a skin swap re-dresses a shown editor.
    local skin = GetSelectedSkin();
    local modern = (db.modernOptions and skin and skin.modernOnly)
        and true or false;
    if(win.wimModernStyled == modern) then return; end
    win.wimModernStyled = modern;
    local close = win.close;
    local chrome = modern and buildModernChrome(win);
    local drops = modern and buildModernDropdowns(win);
    if(hasAtlas("checkbox-minimal") and hasAtlas("checkmark-minimal")) then
        local checks = filterCheckboxes(win);
        for i=1, #checks do
            styleFilterCheckbox(checks[i], modern);
        end
    end
    if(modern) then
        -- ClearBackdrop discards backdropInfo; keep it for the swap
        -- back to the classic dress.
        win.wimSavedBackdropInfo = win.wimSavedBackdropInfo or win.backdropInfo;
        if(win.ClearBackdrop) then win:ClearBackdrop(); else win:SetBackdrop(nil); end
        if(chrome) then
            chrome:Show();
            chrome.well:Show();
            win.patternContainer:ClearAllPoints();
            win.patternContainer:SetPoint("TOPLEFT", chrome.well, "TOPLEFT", 8, -8);
            win.patternContainer:SetPoint("BOTTOMRIGHT", chrome.well, "BOTTOMRIGHT", -28, 8);
            win.user:ClearAllPoints();
            win.user:SetPoint("TOPLEFT", chrome.well, "TOPLEFT", 8, -8);
            win.user:SetPoint("BOTTOMRIGHT", chrome.well, "BOTTOMRIGHT", -8, 8);
            win.level:ClearAllPoints();
            win.level:SetPoint("TOPLEFT", chrome.well, "TOPLEFT", 8, -8);
            win.level:SetPoint("BOTTOMRIGHT", chrome.well, "BOTTOMRIGHT", -8, 8);
            -- One panel: the well's own border and background carry the
            -- area, so the hairline boxes inside it hide.
            for _, holder in pairs({ win.patternContainer, win.user, win.level }) do
                if(holder.backdrop) then
                    for _, tex in pairs(holder.backdrop) do tex:Hide(); end
                end
            end
            if(chrome.nameBand) then
                for i=1, #chrome.nameBand do chrome.nameBand[i]:Show(); end
                if(win.name.backdrop) then
                    for _, tex in pairs(win.name.backdrop) do tex:Hide(); end
                end
                win.name:SetTextInsets(6, 6, 0, 0);
            end
            win.save:ClearAllPoints();
            win.save:SetPoint("TOPRIGHT", win.border, "BOTTOMRIGHT", 0, -14);
            applyModernChromeTheme(win);
        else
            -- No nine-slice on this client: the modern option panels'
            -- flat plate instead.
            if(not win.wimModernFill) then
                win.wimModernFill = win:CreateTexture(nil, "BACKGROUND", nil, -8);
                win.wimModernFill:SetColorTexture(0.035, 0.035, 0.05, 0.95);
                win.wimModernFill:SetAllPoints();
            end
            win.wimModernFill:Show();
            options.AddOptionsPlate(win);
            if(win.wimPlate) then win.wimPlate:Show(); end
        end
        if(not win.wimSlimBar) then
            -- The slim scrollbar, inset on the inside of the pattern
            -- well where the template's wide one sat outside.
            local barHost = CreateFrame("Frame", nil, win);
            if(chrome) then
                barHost:SetPoint("TOPRIGHT", chrome.well, "TOPRIGHT", -4, -6);
                barHost:SetPoint("BOTTOMRIGHT", chrome.well, "BOTTOMRIGHT", -4, 6);
            else
                barHost:SetPoint("TOPLEFT", win.patternContainer, "TOPRIGHT", 0, 12);
                barHost:SetPoint("BOTTOMLEFT", win.patternContainer, "BOTTOMRIGHT", 0, -12);
            end
            barHost:SetWidth(22);
            win.wimSlimBar = AttachMinimalScrollBar(win.patternContainer, barHost)
                or "unavailable";
        end
        if(win.wimSlimBar ~= "unavailable") then
            SetMinimalScrollBarShown(win.patternContainer, win.wimSlimBar, true);
        end
        close:SetSize(24, 24);
        close:ClearAllPoints();
        close:SetPoint("TOPRIGHT", 1, 0);
        close:SetNormalAtlas("RedButton-Exit");
        close:SetPushedAtlas("RedButton-exit-pressed");
        close:SetHighlightAtlas("RedButton-Highlight", "ADD");
        ApplyRedButtonArt(close:GetNormalTexture(), "RedButton-Exit");
        ApplyRedButtonArt(close:GetPushedTexture(), "RedButton-exit-pressed");
        ApplyRedButtonArt(close:GetHighlightTexture(), "RedButton-Highlight");
        close:GetHighlightTexture():SetBlendMode("ADD");
        win.title:ClearAllPoints();
        win.title:SetPoint("TOP", 0, -4);
        win.title:SetTextColor(_G.GameFontNormal:GetTextColor());
        if(drops) then
            win.action:Hide();
            win.level.class:Hide();
            win.by:Hide();
            win.actionModern:Show();
            win.classModern:Show();
            win.byModern:Show();
        end
    else
        if(win.wimModernChrome) then
            win.wimModernChrome:Hide();
            win.wimModernChrome.well:Hide();
            local band = win.wimModernChrome.nameBand;
            if(band) then
                for i=1, #band do band[i]:Hide(); end
            end
            if(win.name.backdrop) then
                for _, tex in pairs(win.name.backdrop) do tex:Show(); end
            end
            win.name:SetTextInsets(0, 0, 0, 0);
            win.patternContainer:ClearAllPoints();
            win.patternContainer:SetPoint("TOPLEFT", win.byText, "BOTTOMLEFT", 0, -25);
            win.patternContainer:SetPoint("RIGHT", -50, 0);
            win.patternContainer:SetHeight(95);
            win.user:ClearAllPoints();
            win.user:SetPoint("TOPLEFT", win.patternContainer, "TOPLEFT");
            win.user:SetPoint("BOTTOMLEFT", win.patternContainer, "BOTTOMLEFT");
            win.user:SetPoint("RIGHT", -30, 0);
            win.level:ClearAllPoints();
            win.level:SetPoint("TOPLEFT", win.patternContainer, "TOPLEFT");
            win.level:SetPoint("BOTTOMLEFT", win.patternContainer, "BOTTOMLEFT");
            win.level:SetPoint("RIGHT", -30, 0);
            for _, holder in pairs({ win.patternContainer, win.user, win.level }) do
                if(holder.backdrop) then
                    for _, tex in pairs(holder.backdrop) do tex:Show(); end
                end
            end
            win.save:ClearAllPoints();
            win.save:SetPoint("TOPRIGHT", win.border, "BOTTOMRIGHT", 0, -5);
        end
        if(win.wimModernFill) then win.wimModernFill:Hide(); end
        if(win.wimPlate) then win.wimPlate:Hide(); end
        win.backdropInfo = win.backdropInfo or win.wimSavedBackdropInfo;
        if(win.backdropInfo) then
            win:ApplyBackdrop();
        end
        if(win.wimSlimBar and win.wimSlimBar ~= "unavailable") then
            SetMinimalScrollBarShown(win.patternContainer, win.wimSlimBar, false);
        end
        close:SetSize(18, 18);
        close:ClearAllPoints();
        close:SetPoint("TOPRIGHT", -24, -20);
        close:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
        close:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
        -- This client rejects a nil asset; the classic button never had
        -- a pushed state, so it reuses the blip.
        close:SetPushedTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
        close:GetPushedTexture():SetTexCoord(0, 1, 0, 1);
        close:SetHighlightTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\close", "BLEND");
        close:GetHighlightTexture():SetTexCoord(0, 1, 0, 1);
        close:GetHighlightTexture():SetBlendMode("BLEND");
        win.title:ClearAllPoints();
        win.title:SetPoint("TOPLEFT", 50, -20);
        win.title:SetTextColor(1, 1, 1);
        if(win.actionModern) then
            win.actionModern:Hide();
            win.classModern:Hide();
            win.byModern:Hide();
            win.action:Show();
            win.level.class:Show();
            win.by:Show();
        end
    end
end

-- The Modern Skin options and skin swaps re-dress the editor live.
function RestyleFilterFrame()
    local win = filterFrame;
    if(not win) then return; end
    styleFilterFrame(win);
    if(win.wimModernStyled) then
        applyModernChromeTheme(win);
    end
end


function ShowFilterFrame(filter, index, isChat)
    if(not filterFrame) then
        filterFrame = createFilterFrame();
    end
    styleFilterFrame(filterFrame);
    filterFrame.filter = {};
    if(type(filter) == "table" and type(index) == "number") then
        filterFrame.saveIndex = index;
	for key, val in pairs(filter) do
	    filterFrame.filter[key] = val;
	end
    end
    filterFrame.title:SetText(filterFrame.saveIndex and L["Edit Filter"] or L["Add Filter"]);
    filterFrame.isChat = isChat;
    if(filterFrame.wimModernStyled and filterFrame.RefreshModernDropdowns) then
        filterFrame.RefreshModernDropdowns();
    end
    filterFrame:Show();
end


WIM.RegisterItemRefHandler("WIMBLOCKED", function (link)
    local msgId = _G.tonumber(link:match("(%d+)"));
    if(msgId and blockedEvents[msgId]) then
        local event = blockedEvents[msgId][1];
        local args = {"\009\002"..blockedEvents[msgId][2],
            blockedEvents[msgId][3], blockedEvents[msgId][4], blockedEvents[msgId][5], blockedEvents[msgId][6],
            blockedEvents[msgId][7], blockedEvents[msgId][8], blockedEvents[msgId][9], blockedEvents[msgId][10],
            blockedEvents[msgId][11], blockedEvents[msgId][12], blockedEvents[msgId][13], blockedEvents[msgId][14]};

		-- whitelist so message isn't blocked again.
		whitelistedMessages[msgId] = true

		if(event:find("WHISPER")) then
			modules.WhisperEngine[event](modules.WhisperEngine, _G.unpack(args));
        elseif(event:find("RAID_LEADER")) then
            modules.RaidChat:CHAT_MSG_RAID_LEADER(_G.unpack(args));
        elseif(event:find("RAID")) then
            modules.RaidChat:CHAT_MSG_RAID(_G.unpack(args));
        elseif(event:find("GUILD")) then
            modules.GuildChat:CHAT_MSG_GUILD(_G.unpack(args));
        elseif(event:find("OFFICER")) then
            modules.OfficerChat:CHAT_MSG_OFFICER(_G.unpack(args));
        elseif(event:find("PARTY")) then
            modules.PartyChat:CHAT_MSG_PARTY(_G.unpack(args));
		elseif(event:find("PARTY_LEADER")) then
            modules.PartyChat:CHAT_MSG_PARTY_LEADER(_G.unpack(args));
        elseif(event:find("SAY")) then
            modules.SayChat:CHAT_MSG_SAY(_G.unpack(args));
        elseif(event:find("CHANNEL")) then
            modules.ChannelChat:CHAT_MSG_CHANNEL(_G.unpack(args));
        end
    end
end);


local function blockCatcher(msg, smf)
    if(msg and msg:match("\009\002")) then
        smf:AddMessage("    ");
        smf:AddMessage("|cffff0000"..L["Blocked Message"]..":|r");
	if(smf.parentWindow) then
            smf.parentWindow:Pop(true);
	end
        msg = msg:gsub("\009\002", "");
    end
    return msg;
end
RegisterStringModifier(blockCatcher, true);
