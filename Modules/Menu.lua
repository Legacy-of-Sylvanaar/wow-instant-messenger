--import
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local ipairs = ipairs;
local table = table;
local type = type;
local unpack = unpack;
local string = string;

-- Defined before the setfenv. C_Texture.GetAtlasInfo looks up
-- Vector2DMixin in the calling function's environment, so namespaced
-- code must not call it directly.
local function getAtlasInfo(name)
    if (C_Texture and C_Texture.GetAtlasInfo) then
        return C_Texture.GetAtlasInfo(name);
    end
end

--set namespace
setfenv(1, WIM);

local Menu = CreateModule("Menu", true);

local groupCount = 0;
local buttonCount = 0;

local AUTO_CLOSE_TIMEOUT = 3;
local AUTO_CLOSE_TIMEOUT_INTERACTED = 1;

local lists = {
    whisper = {},
    chat = {}
}
local maxButtons = {
    whisper = 20,
    chat = 10
};

db_defaults.menuSortActivity = true;

local function sortWindows(a, b)
    if(db and db.menuSortActivity) then
        return a.lastActivity > b.lastActivity;
    else
        return string.lower(a.theUser) < string.lower(b.theUser);
    end
end

local function isMouseOver()
	-- can optionaly exclude an object
	local x,y = _G.GetCursorPosition();
	local menu = WIM.Menu;
        if(not menu) then
            return false;
        else
            local x1, y1 = (menu:GetLeft() or 0)*menu:GetEffectiveScale(), (menu:GetTop() or 0)*menu:GetEffectiveScale();
            local x2, y2 = x1 + menu:GetWidth()*menu:GetEffectiveScale(), y1 - menu:GetHeight()*menu:GetEffectiveScale();
            if(x >= x1 and x <= x2 and y <= y1 and y >= y2) then
                return true;
            end
            return false;
        end
end

local function createCloseButton(parent)
    local button = CreateFrame("Button", nil, parent);
    button:SetNormalTexture("Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\xNormal");
    button:SetPushedTexture("Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\xPressed");
    button:SetWidth(16);
    button:SetHeight(16);
    button:SetScript("OnClick", function(self)
            self:GetParent().win.widgets.close.forceShift = true;
            self:GetParent().win.widgets.close:Click();
        end);

    return button;
end

local function createStatusIcon(parent)
    local icon = parent:CreateTexture(nil, "OVERLAY");
    icon:SetWidth(14); icon:SetHeight(14);
    icon:SetAlpha(.85);
    icon:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
    return icon;
end

local function createButton(parent)
    buttonCount = buttonCount + 1;
    local button = CreateFrame("Button", "WIM3MenuButton"..buttonCount, parent, "UIPanelButtonTemplate");

	button:DisableDrawLayer("BACKGROUND");

	-- button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD");
    -- button:GetHighlightTexture():SetVertexColor(.196, .388, .8);

    button.text = _G[button:GetName().."Text"];
    button.text:ClearAllPoints();
	button.text._allowCustomFont = false; -- flag that this frame allows custom fonts.

    button.status = createStatusIcon(button);
    button.close = createCloseButton(button);

	button.ApplySkin = function(self, skin)
		SetWidgetFont(self.text, skin.menu.item.text);

		-- item text
		button.text:SetWordWrap(false);
		button.text:SetJustifyH(skin.menu.item.text.align or "LEFT");
		button.text:SetJustifyV(skin.menu.item.text.justify or "MIDDLE");
		button.text:SetVertexColor(unpack(skin.menu.item.text.font_color or {1, 1, 1}));
		button.text:ClearAllPoints();
		local points = skin.menu.item.text.points or {};
		for _, point in ipairs(points) do
			button.text:SetPoint(unpack(point));
		end

		-- close button
		button.close:SetWidth(skin.menu.item.close.width or skin.menu.item.height or 14);
		button.close:SetHeight(skin.menu.item.close.height or skin.menu.item.height or 14);
		button.close:ClearAllPoints();
		points = skin.menu.item.close.points or {};
		for _, point in ipairs(points) do
			button.close:SetPoint(unpack(point));
		end

		-- status icon
		button.status:ClearAllPoints();
		button.status:SetWidth(skin.menu.item.status.width or skin.menu.item.height or 14);
		button.status:SetHeight(skin.menu.item.status.height or skin.menu.item.height or 14);
		points = skin.menu.item.status.points or {};
		for _, point in ipairs(points) do
			button.status:SetPoint(unpack(point));
		end

		-- other adjustments
		button:SetHeight(skin.menu.item.height or 14);

		utils.skin.applyHighlightTexture(button, skin.menu.item.highlight.texture);
		local highlight = self:GetHighlightTexture();
		if(highlight) then
			if (utils.skin.getAtlasInfo(skin.menu.item.highlight.texture)) then
				highlight:SetTexCoord(0, 1, 0, 1);
			end;
			highlight:SetBlendMode(skin.menu.item.highlight.blendMode or "BLEND");
			highlight:SetVertexColor(unpack(skin.menu.item.highlight.color or {1, 1, 1, 1}));
			highlight:ClearAllPoints();
			highlight:SetHeight(button:GetHeight());
			points = skin.menu.item.highlight.points or {};
			if (#points > 0) then
				for _, point in ipairs(points) do
					highlight:SetPoint(unpack(point));
				end
			else
				highlight:SetAllPoints(button);
			end
		end
	end

    button:SetScript("OnClick", function(self, b)
			local forceShow = true
			if db.pop_rules[self.win.type].obeyAutoFocusRules then
				forceShow = self.win:GetRuleSet().autofocus
			end
            self.win:Pop(true, forceShow);
            WIM.Menu:Hide();
        end);
    button:SetScript("OnUpdate", function(self, elapsed)
            if(self.win) then
                -- The native look uses the friends list's status icons;
                -- the classic look keeps WIM's blips. WIM only tracks
                -- online/offline for whisper targets, so away/busy have
                -- no source here; non-whisper rows go iconless when
                -- native (a channel has no presence).
                local native = self.wimNativeStatus;
                if(self.win.online ~= nil and not self.win.online and self.win.type == "whisper") then
                    self.text:SetTextColor(.5, .5, .5);
                    self.status:SetTexture(native
                        and "Interface\\FriendsFrame\\StatusIcon-Offline"
                        or "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipRed");
                    self.canFade = true;
                elseif(self.win.unreadCount and self.win.unreadCount > 0) then
                    self.text:SetTextColor(1, 1, 1);
                    self.status:SetTexture(native
                        and "Interface\\FriendsFrame\\StatusIcon-Online"
                        or "Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipBlue");
                    self.canFade = false;
                else
                    self.text:SetTextColor(1, 1, 1);
                    if(native) then
                        if(self.win.type == "whisper") then
                            self.status:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online");
                        else
                            self.status:SetTexture(nil);
                        end
                    else
                        self.status:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Sources\\Options\\Textures\\blipClear");
                    end
                    self.canFade = true;
                end
                -- set opacity of button text.
                if(self.win and not self.win:IsShown() and self.canFade) then
                    self.text:SetAlpha(.65);
                    self.status:SetAlpha(.65);
                else
                    self.text:SetAlpha(1);
                    self.status:SetAlpha(1);
                end
            end
        end);
    button.GetMinimumWidth = function(self)
            return self.text:GetStringWidth() + (GetSelectedSkin().menu.item.text.margin or 0);
        end
    return button;
end

local function createGroup(title, list, maxButtons, showNone)
    groupCount = groupCount + 1;
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local group = CreateFrame("Frame", "WIM3MenuGroup"..groupCount, _G.WIM3Menu, "BackdropTemplate");

    -- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    -- group.backdropInfo = {bgFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg",
    --     edgeFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu",
    --     tile = true, tileSize = 32, edgeSize = 32,
    --     insets = { left = 32, right = 32, top = 32, bottom = 32 }};

	-- group:ApplyBackdrop();

    group.list = list;
    group.title = CreateFrame("Frame", group:GetName().."Title", group);
	group.title:SetPoint("TOPLEFT", group, "TOPLEFT", 0, 0);
	group.title:SetPoint("TOPRIGHT", group, "TOPRIGHT", 0, 0);
    group.title.text = group.title:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
    group.title.text:SetText(title.." ");
	group.title.text:SetAllPoints();
	group.title.text._allowCustomFont = true;

	-- debugging visuals
	-- group.bg = group:CreateTexture(nil, "BACKGROUND");
	-- group.bg:SetAllPoints();
	-- group.bg:SetColorTexture(0, 1, 0, 0.5);
	-- group.title.bg = group.title:CreateTexture(nil, "BACKGROUND");
	-- group.title.bg:SetAllPoints();
	-- group.title.bg:SetColorTexture(1, 0, 0, 0.5);

    group.buttons = {};
    local lastButton = group.title;
    for i=1, maxButtons do
        local button = createButton(group);
        button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0);
        button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0);
        button.shown = false;
        lastButton = button;
        table.insert(group.buttons, button);
    end
    group.showNone = showNone;
    group.GetButtonCount = function(self)
        local count = 0;
        for i=1, #self.buttons do
            count = self.buttons[i].shown and count+1 or count;
        end
        return count;
    end
    group.UpdateHeight = function(self)
        if(#self.list == 0 and not self.showNone) then
            group:SetHeight(0);
        else
			local skin = GetSelectedSkin();
			local btnCount = group:GetButtonCount()
			local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
			local padding = skin and skin.menu.padding or {0, 0, 0, 0};
			local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
			local offsetTop = groupMode and offsets[3] or 0;
			local offsetBottom = groupMode and offsets[4] or 0;
			local paddingTop = groupMode and padding[3] or 0;
			local paddingBottom = groupMode and padding[4] or 0;
			local totalVerticalPadding = groupMode and (paddingTop + paddingBottom + offsetTop + offsetBottom) or 0;
			local minHeight = skin and skin.menu.minHeight or 64;
			local marginTop = groupMode and skin and skin.menu.item.marginTop or 0;
			local marginBottom = groupMode and skin and skin.menu.item.marginBottom or 0;

            group:SetHeight(_G.math.max(group.title:GetHeight() + group.buttons[1]:GetHeight()*btnCount + totalVerticalPadding + marginTop + marginBottom, minHeight ));
        end
    end

	group.ApplySkin = function(self, skin)
		skin = skin or GetSelectedSkin();
		local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
		local padding = skin and skin.menu.padding or {0, 0, 0, 0};
		local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
		local paddingLeft = padding[1] or 0;
		local paddingRight = padding[2] or 0;
		local paddingTop = groupMode and padding[3] or 0;
		local paddingBottom = groupMode and padding[4] or 0;
		local offsetLeft = offsets[1] or 0;
		local offsetRight = offsets[2] or 0;
		local offsetTop = groupMode and offsets[3] or 0;
		local gap = not groupMode and skin.menu.gap or 0;

		-- if in group mode
		if (groupMode) then
			local atlas = skin.menu.texture;
			local backdropInfo = skin.menu.backdropInfo;

			-- init atlas textureObject
			if (not self._atlasTexture) then
				self._atlasTexture = self:CreateTexture(nil, "BACKGROUND");
				self._atlasTexture:SetAllPoints();
			end;

			-- use backdrop
			if (type(backdropInfo) == "table") then
				self:SetBackdrop(backdropInfo);
				self:SetBackdropColor(unpack(backdropInfo.bgColor or {1, 1, 1, 1}));
				self:SetBackdropBorderColor(unpack(backdropInfo.edgeColor or {1, 1, 1, 1}));

				self._atlasTexture:Hide();

				dPrint("Menu.group:ApplySkin: Using backdrop for group");

			-- use atlas
			else
				self:ClearBackdrop();

				utils.skin.applyTexture(self._atlasTexture, atlas);
				self._atlasTexture:SetAlpha(skin.menu.textureAlpha or 1);
				self._atlasTexture:Show();

				dPrint("Menu.group:ApplySkin: Using atlas for group");
			end

			if (self._dividerTexture) then
				self._dividerTexture:Hide();
			end;

		-- non-group mode: clear atlas and backdropInfo
		else
			dPrint("Menu.group:ApplySkin: Non-group mode, clearing atlas and backdrop");

			self:ClearBackdrop();
			if (self._atlasTexture) then
				self._atlasTexture:Hide();
			end;

			-- divider texture
			self._dividerTexture = self._dividerTexture or self:CreateTexture(nil, "ARTWORK");

			self._dividerTexture:Hide();
			self._dividerTexture:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent");
			self._dividerTexture:ClearAllPoints();
			self._dividerTexture:SetPoint("TOPLEFT", self.title, "TOPLEFT", 0, 7.5 + gap * .5);
			self._dividerTexture:SetPoint("TOPRIGHT", self.title, "TOPRIGHT", 0, 7.5 + gap * .5);
			self._dividerTexture:SetTexCoord(0, 1, 0, 1);
			self._dividerTexture:SetHeight(13);
			if (not groupMode and self.wimWantsDivider) then
				self._dividerTexture:Show();
			end
		end

		-- title skinning
		local titleHeight = skin.menu.title.height or skin.menu.title.font_height or 12;
		SetWidgetFont(self.title.text, skin.menu.title);
		self.title.text:SetJustifyH(skin.menu.title.align or "LEFT");
		self.title.text:SetJustifyV(skin.menu.title.justify or "TOP");
		self.title:ClearAllPoints();
		self.title:SetPoint("TOPLEFT", self, "TOPLEFT", paddingLeft + offsetLeft, -(offsetTop + paddingTop));
		self.title:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -(paddingRight + offsetRight), -(offsetTop + paddingTop + titleHeight));


		-- title font + color. SetWidgetFont resolves every form a skin may
		-- declare (font object name, LibSharedMedia name, or file path); a
		-- raw SetFont here would silently no-op on anything but a path.
		SetWidgetFont(self.title.text, skin.menu.title);
		self.title.text:SetWordWrap(false);

		-- buttons
		local marginTop = skin and skin.menu.item.marginTop or 0;
		local prev = self.title;
		for i=1, #self.buttons do
			local button = self.buttons[i];
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, i == 1 and (-marginTop) or 0);
			button:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, i == 1 and (-marginTop) or 0);
			button:ApplySkin(skin);
			prev = button;
		end
	end
    group.width = 0;
    group.Refresh = function(self)
        local maxWidth = 150;
        table.sort(self.list, sortWindows);
        for i=1, #self.buttons do
            local button = self.buttons[i];
            if(i > #self.list) then
                button.win = nil;
                button:Hide();
                button.shown = false;
            else
                button.win = self.list[i];
                button.close:Show();
                button.status:Show();
                button.text:SetText(button.win.theUser);
                button:Show();
                button:Enable();
                button.text:SetJustifyH("LEFT");
                button.shown = true;
                maxWidth = _G.math.max(maxWidth, button:GetMinimumWidth());
                self:Show();
            end
        end
        self.title:Show();
        if(#self.list == 0) then
            if(self.showNone) then
                self.buttons[1].win = nil;
                self.buttons[1].close:Hide();
                self.buttons[1].status:Hide();
                self.buttons[1]:Show();
                self.buttons[1].shown = true;
                self.buttons[1]:Disable();
                self.buttons[1].text:SetJustifyH("LEFT");
                self.buttons[1].text:SetText(L["None"]);
                self.buttons[1].text:SetTextColor(.5, .5, .5);
            else
                self.title:Hide();
                self:Hide();
            end
        end

        self.width = maxWidth
        self:UpdateHeight();
    end
    return group;
end


local function createMenu()
    local menu = CreateFrame("Frame", "WIM3Menu", _G.UIParent, "BackdropTemplate");
    menu:Hide(); -- testing only.
    menu:SetClampedToScreen(true);
    menu:SetFrameStrata("FULLSCREEN_DIALOG");
    menu:SetToplevel(true);
    menu:SetWidth(180);
    menu:SetHeight(200);
    menu.groups = {};
    --create whisper group
    menu.groups[1] = createGroup(L["Whispers"], lists.whisper, maxButtons.whisper, true);
    menu.groups[1]:SetPoint("TOPLEFT");
    menu.groups[1]:SetPoint("TOPRIGHT");
    --create chat group
    menu.groups[2] = createGroup(L["Chat"], lists.chat, maxButtons.chat, false);
    menu.groups[2]:SetPoint("TOPLEFT", menu.groups[1], "BOTTOMLEFT", 0, 0);
    menu.groups[2]:SetPoint("TOPRIGHT", menu.groups[1], "BOTTOMRIGHT", 0, 0);
    -- Sections after the first show the native divider above their
    -- header while the context style is active.
    menu.groups[2].wimWantsDivider = true;

    menu.Refresh = function(self)
			local skin = GetSelectedSkin();
			local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
            local groupHeight = 0;
            local groupWidth = 0;
			local maxTop = 0;
			local minBottom = _G.math.huge;
            for i=1, #self.groups do
                self.groups[i]:Refresh();
                groupHeight = groupHeight + self.groups[i]:GetHeight();
                groupWidth = _G.math.max(groupWidth, self.groups[i].width);
				local top = self.groups[i]:GetTop() or 0;
				local bottom = self.groups[i]:GetBottom() or 0;

				if (top ~= 0 or bottom ~= 0) then
					maxTop = _G.math.max(maxTop, top);
					minBottom = _G.math.min(minBottom, bottom);
				end;
            end
			minBottom = _G.math.min(minBottom, maxTop);

			groupHeight = maxTop - minBottom;
			local calculatedHeight = groupHeight -- + (db and not db.modernTheme.menuGroups and verticalPadding or 0);

			local padding = not groupMode and skin and skin.menu.padding or {0, 0, 0, 0};
			local offsets = not groupMode and skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
			local paddingLeft = not groupMode and padding[1] or 0;
			local paddingRight = not groupMode and padding[2] or 0;
			local offsetLeft = offsets[1] or 0;
			local offsetRight = offsets[2] or 0;
			local paddingTop = not groupMode and padding[3] or 0;
			local paddingBottom = not groupMode and padding[4] or 0;
			local offsetTop = offsets[3] or 0;
			local offsetBottom = offsets[4] or 0;
			local marginBottom = not groupMode and skin and skin.menu.item.marginBottom or 0;

            self:SetWidth(groupWidth + offsetLeft + offsetRight + paddingLeft + paddingRight);
			if (calculatedHeight > 0) then
				local height = calculatedHeight + offsetTop + offsetBottom + marginBottom + paddingTop + paddingBottom
				self:SetHeight(height);
			end;
        end

	menu.ApplySkin = function(self, skin)
		skin = skin or GetSelectedSkin();
		local groupMode = db and db.modernTheme and db.modernTheme.menuGroups;
		local padding = skin and skin.menu.padding or {0, 0, 0, 0};
		local offsets = skin and skin.menu.edgeOffsets or {0, 0, 0, 0};
		local offsetLeft = offsets[1] or 0;
		local offsetRight = offsets[2] or 0;
		local offsetTop = offsets[3] or 0;
		local offsetBottom = offsets[4] or 0;
		local paddingLeft = padding[1] or 0;
		local paddingRight = padding[2] or 0;
		local paddingTop = padding[3] or 0;
		local paddingBottom = padding[4] or 0;

		-- if not in group mode
		if (not groupMode) then
			local atlas = skin.menu.texture;
			local backdropInfo = skin.menu.backdropInfo;

			-- init atlas textureObject
			if (not self._atlasTexture) then
				self._atlasTexture = self:CreateTexture(nil, "BACKGROUND");
				self._atlasTexture:SetAllPoints();
			end;

			-- use backdrop
			if (type(backdropInfo) == "table") then
				self:SetBackdrop(backdropInfo);
				self:SetBackdropColor(unpack(backdropInfo.bgColor or {1, 1, 1, 1}));
				self:SetBackdropBorderColor(unpack(backdropInfo.edgeColor or {1, 1, 1, 1}));

				self._atlasTexture:Hide();

				dPrint("Menu:ApplySkin: Using backdrop for menu");

			-- use atlas
			else
				self:ClearBackdrop();

				utils.skin.applyTexture(self._atlasTexture, atlas);
				self._atlasTexture:SetAlpha(skin.menu.textureAlpha or 1);
				self._atlasTexture:SetAllPoints();
				self._atlasTexture:Show();

				dPrint("Menu:ApplySkin: Using atlas for menu");
			end

		-- group mode: clear atlas and backdropInfo
		else
			dPrint("Menu.ApplySkin: Using group mode, clearing atlas and backdrop");
			self:ClearBackdrop();
			if (self._atlasTexture) then
				self._atlasTexture:Hide();
			end;
		end

		local verticalPadding = groupMode and (offsetTop + offsetBottom) or 0;
		local gap = (skin and skin.menu.gap or 0) - verticalPadding;
		for i=1, #self.groups do
			local group = self.groups[i];
			if (i == 1) then
				group:ClearAllPoints();
				group:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(not groupMode and (offsetTop + paddingTop) or 0));
				group:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -(not groupMode and (offsetTop + paddingTop) or 0));
			else
				group:ClearAllPoints();
				group:SetPoint("TOPLEFT", self.groups[i-1], "BOTTOMLEFT", 0, -gap);
				group:SetPoint("TOPRIGHT", self.groups[i-1], "BOTTOMRIGHT", 0, -gap);
			end
			group:ApplySkin(skin);
		end

		self:Refresh();
	end

    menu:SetScript("OnUpdate", function(self)
            if(isMouseOver()) then
				self.AUTO_CLOSE_TIMEOUT = AUTO_CLOSE_TIMEOUT_INTERACTED;
                self.mouseStamp = _G.time();
            else
                if((_G.time() - self.mouseStamp) > self.AUTO_CLOSE_TIMEOUT) then
                    self:Hide();
                end
            end
        end);
    menu:SetScript("OnShow", function(self)
			self.AUTO_CLOSE_TIMEOUT = AUTO_CLOSE_TIMEOUT;
            self.mouseStamp = _G.time();
            -- Labels can change after a window is created. A community
            -- window is renamed from its clubId:streamId key to the real
            -- community name one line after OnWindowCreated refreshed this
            -- menu, so rebuild the labels every time the menu opens.
            self:Refresh();
            libs.DropDownMenu.CloseDropDownMenus();
        end);

    return menu;
end


function Menu:OnWindowCreated(obj)
    -- add obj to specified list & Update
    if(obj.type == "whisper" or obj.type == "chat") then
        utils.table.addToTableUnique(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowDestroyed(obj)
    -- remove obj to specified list & Update
    obj.widgets.close.forceShift = nil;
    if(obj.type == "whisper" or obj.type == "chat") then
        utils.table.removeFromTable(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowPopped(obj)
    -- check status of obj to specified list & Update
    if(obj.type == "whisper" or obj.type == "chat") then
        WIM.Menu:Refresh();
    end
end


-- for convention, we will load the module as normal.
function Menu:OnEnable()
    if(not WIM.Menu) then
        WIM.Menu = createMenu();
        -- Enable runs from this file's main chunk, before any skin has
        -- registered. In that case the construction-time backdrop stays
        -- until the login LoadSkin dispatches OnSkinLoaded. If the menu
        -- is created later than that, apply the active skin now;
        -- ApplySkin ends with a Refresh.
        local skin = GetSelectedSkin();
        if(skin) then
            WIM.Menu:ApplySkin(skin);
        else
            WIM.Menu:Refresh();
        end
    end
end

function Menu:OnSkinLoaded(skin)
	if (WIM.Menu) then
		WIM.Menu:ApplySkin(skin);
	end
end


-- This is a core module and must always be loaded...
Menu.canDisable = false;
Menu:Enable();
