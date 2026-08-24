--import
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local table = table;
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

function isMouseOver()
	-- can optionaly exclude an object
	local x,y = _G.GetCursorPosition();
	local menu = WIM.Menu;
        if(not menu) then
            return false;
        else
            local x1, y1 = menu:GetLeft()*menu:GetEffectiveScale(), menu:GetTop()*menu:GetEffectiveScale();
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
    local bgtex = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg"
    button:SetNormalTexture(bgtex); button:SetPushedTexture(bgtex); button:SetDisabledTexture(bgtex); button:SetHighlightTexture(bgtex);
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD");
    button:GetHighlightTexture():SetVertexColor(.196, .388, .8);
    button:SetHeight(20);
    button:GetHighlightTexture():SetAllPoints();
    button.text = _G[button:GetName().."Text"];
    button.text:ClearAllPoints();
    button.text:SetPoint("LEFT"); button.text:SetPoint("RIGHT");
	button.text._allowCustomFont = true; -- flag that this frame allows custom fonts.
    button:GetHighlightTexture():ClearAllPoints();
    button:GetHighlightTexture():SetAllPoints();

    button.status = createStatusIcon(button);
    button.status:SetPoint("LEFT", button, "RIGHT", 0, -1);
    button.close = createCloseButton(button);
    button.close:SetPoint("LEFT", button.status, "RIGHT", 2, 0);

	button.ApplySkin = function(self, skin)
		SetWidgetFont(self.text, skin.menu.button);
		-- Native context-menu rows are bare text over the panel with
		-- only the hover wash; the plate pieces and button fill stay
		-- for skins without the context style.
		local native = (skin.menu.style == "context");
		if(self.Left) then self.Left:SetShown(not native); end
		if(self.Middle) then self.Middle:SetShown(not native); end
		if(self.Right) then self.Right:SetShown(not native); end
		-- Native rows hover with the gold end-fading wash the Settings
		-- category list draws on its selected row: gold, fading at both
		-- ends. The classic quest-log art has no gold and fades on one
		-- side only, cutting hard at the other. The classic look keeps
		-- that art with its blue additive tint.
		local highlight = self:GetHighlightTexture();
		if(highlight) then
			if(native and getAtlasInfo("Options_List_Active")) then
				highlight:SetAtlas("Options_List_Active");
				highlight:SetTexCoord(0, 1, 0, 1);
				highlight:SetVertexColor(1, 1, 1);
				highlight:SetBlendMode("BLEND");
				-- The status and close icons hang off the button's
				-- right edge; the wash covers the whole visual row.
				highlight:ClearAllPoints();
				highlight:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
				highlight:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0);
				highlight:SetPoint("RIGHT", self.close, "RIGHT", 2, 0);
			else
				highlight:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
				highlight:SetTexCoord(0, 1, 0, 1);
				highlight:SetVertexColor(.196, .388, .8);
				highlight:SetBlendMode("ADD");
				highlight:ClearAllPoints();
				highlight:SetAllPoints(self);
			end
		end
		-- Status blips follow the friends list's icons in the native
		-- look (see OnUpdate).
		self.wimNativeStatus = native;
		local alpha = native and 0 or 1;
		local normal = self:GetNormalTexture();
		if(normal) then normal:SetAlpha(alpha); end
		local pushed = self:GetPushedTexture();
		if(pushed) then pushed:SetAlpha(alpha); end
		local disabled = self:GetDisabledTexture();
		if(disabled) then disabled:SetAlpha(alpha); end
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
            return self.text:GetStringWidth()+40;
        end
    return button;
end

local function createGroup(title, list, maxButtons, showNone)
    groupCount = groupCount + 1;
	-- Changes for Patch 9.0.1 - Shadowlands, retail and classic
	local group = CreateFrame("Frame", "WIM3MenuGroup"..groupCount, _G.WIM3Menu, "BackdropTemplate");

    -- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
    group.backdropInfo = {bgFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu_bg",
        edgeFile = "Interface\\AddOns\\"..addonTocName.."\\Modules\\Textures\\Menu",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 32, right = 32, top = 32, bottom = 32 }};

	group:ApplyBackdrop();

    group.list = list;
    group.title = CreateFrame("Frame", group:GetName().."Title", group);
    group.title:SetHeight(17);
    group.title:SetPoint("TOPLEFT", 20, -18); group.title:SetPoint("TOPRIGHT", -20, -18);
    group.title.bg = group.title:CreateTexture(nil, "BACKGROUND");
    group.title.bg:SetAllPoints();
    group.title.text = group.title:CreateFontString(nil, "OVERLAY", "ChatFontNormal");
    local font = group.title.text:GetFont();
    group.title.text:SetFont(font, 11, "");
    group.title.text:SetAllPoints();
    group.title.text:SetText(title.." ");
    group.title.text:SetJustifyV("TOP");
    group.title.text:SetJustifyH("RIGHT");
    group.buttons = {};
    local lastButton = group.title;
    local offSet = -32;
    for i=1, maxButtons do
        local button = createButton(group);
        button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT");
        button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", offSet, 0);
        offSet= 0;
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
            group:SetHeight(_G.math.max(group.title:GetHeight() + group.buttons[1]:GetHeight()*self:GetButtonCount() + 18*2, 64));
        end
    end

	group.ApplySkin = function(self, skin)

		-- A skin may dress the menu in the game's own context-menu
		-- panel (skin.menu.background_atlas, the chamfered-corner art
		-- current right-click menus draw), rendered as a single sliced
		-- texture; the backdrop pair below is the fallback for skins
		-- without it and clients without slicing or the atlas.
		-- One stretched texture, as the game's menu compositor draws
		-- it: a single piece over the whole frame -- the chamfer
		-- scales with the menu -- extended 10px past the frame
		-- horizontally and 3px vertically (the baked shadow pad),
		-- at 0.93 alpha.
		-- The plate itself is drawn ONCE, on the parent menu frame
		-- spanning every visible group (the groups overlap where they
		-- meet, so per-group plates doubled the border there); each
		-- group only retires its own backdrop and styles its header.
		local atlas = skin.menu.background_atlas;
		if(atlas and getAtlasInfo(atlas)) then
			if(self.wimAtlasBg) then
				self.wimAtlasBg:Hide();
			end
			-- Retire the template backdrop. ClearBackdrop runs first,
			-- while backdropInfo is still set (it is a no-op once the
			-- field is nil) -- but the mixin can leave the pieces
			-- shown regardless, so they are also hidden directly by
			-- parentKey; the fallback path below re-shows them for
			-- skins without the atlas.
			if(self.ClearBackdrop) then
				self:ClearBackdrop();
			else
				self:SetBackdrop(nil);
			end
			self.backdropInfo = nil;
			local backdropPieces = { "TopLeftCorner", "TopRightCorner",
				"BottomLeftCorner", "BottomRightCorner", "TopEdge",
				"BottomEdge", "LeftEdge", "RightEdge", "Center" };
			for i=1, #backdropPieces do
				local piece = self[backdropPieces[i]];
				if(piece and piece.Hide) then
					piece:Hide();
				end
			end
			-- Native menus carry no strip behind their section titles;
			-- their headers read left-aligned gold (the unit menu's
			-- "Loot Options" style), with the standard divider above
			-- sections after the first.
			self.title.bg:Hide();
			self.title.text:SetJustifyH("LEFT");
			if(self.wimWantsDivider and not self.wimDivider) then
				local divider = self:CreateTexture(nil, "ARTWORK");
				-- The divider native menus draw between sections.
				divider:SetTexture(918860);
				divider:SetHeight(13);
				divider:SetPoint("BOTTOMLEFT", self.title, "TOPLEFT", -6, 2);
				divider:SetPoint("BOTTOMRIGHT", self.title, "TOPRIGHT", 6, 2);
				self.wimDivider = divider;
			end
			if(self.wimDivider) then
				self.wimDivider:Show();
			end
			dPrint("Menu: chamfered atlas background applied to "..(self:GetName() or "group")..".");
		else
			if(self.wimAtlasBg) then
				self.wimAtlasBg:Hide();
			end
			-- set backdrop - changes for Patch 9.0.1 - Shadowlands, retail and classic
			self.backdropInfo = {
				bgFile = skin.menu.background,
				edgeFile = skin.menu.edge,
				tile = skin.menu.tile,
				tileSize = skin.menu.tile_size,
				edgeSize = skin.menu.edge_size,
				insets = {
					left = skin.menu.insets.left,
					right = skin.menu.insets.right,
					top = skin.menu.insets.top,
					bottom = skin.menu.insets.bottom
				}
			};

			self:ApplyBackdrop();
			-- ApplyBackdrop does not undo an explicit Hide on the
			-- pieces (the mixin manages only its own visibility), so a
			-- return from an atlas-dressed skin re-shows them directly
			-- -- the mirror of the atlas path hiding them above.
			local backdropPieces = { "TopLeftCorner", "TopRightCorner",
				"BottomLeftCorner", "BottomRightCorner", "TopEdge",
				"BottomEdge", "LeftEdge", "RightEdge", "Center" };
			for i=1, #backdropPieces do
				local piece = self[backdropPieces[i]];
				if(piece and piece.Show) then
					piece:Show();
				end
			end
			self.title.bg:Show();
			self.title.text:SetJustifyH("RIGHT");
			if(self.wimDivider) then
				self.wimDivider:Hide();
			end
		end

		-- title font + color. SetWidgetFont resolves every form a skin may
		-- declare (font object name, LibSharedMedia name, or file path); a
		-- raw SetFont here would silently no-op on anything but a path.
		SetWidgetFont(self.title.text, skin.menu.title);

		-- buttons
		for i=1, #self.buttons do
			local button = self.buttons[i];
			button:ApplySkin(skin);
		end
	end
    group.width = 0;
    group.Refresh = function(self)
        local maxWidth = 150-18*2;
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
        self.width = maxWidth+18*2;
        self:UpdateHeight();
    end
    return group;
end


local function createMenu()
    local menu = CreateFrame("Frame", "WIM3Menu", _G.UIParent);
    menu:Hide(); -- testing only.
    menu:SetClampedToScreen(true);
    menu:SetFrameStrata("DIALOG");
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
    menu.groups[2]:SetPoint("TOPLEFT", menu.groups[1], "BOTTOMLEFT", 0, 25);
    menu.groups[2]:SetPoint("TOPRIGHT", menu.groups[1], "BOTTOMRIGHT", 0, 25);
    -- Sections after the first show the native divider above their
    -- header while the context style is active.
    menu.groups[2].wimWantsDivider = true;

    menu.Refresh = function(self)
            local groupHeight = 0;
            local groupWidth = 0;
            for i=1, #self.groups do
                self.groups[i]:Refresh();
                groupHeight = groupHeight + self.groups[i]:GetHeight();
                groupWidth = _G.math.max(groupWidth, self.groups[i].width);
            end
            self:SetHeight(groupHeight);
            self:SetWidth(groupWidth);
            -- The single plate spans from the first group to the
            -- lowest visible one; the menu frame's own rect overstates
            -- the content (group anchors overlap), so the plate
            -- anchors to the groups.
            if(self.wimAtlasBg) then
                local lowest = self.groups[1];
                for i=1, #self.groups do
                    if(self.groups[i]:IsShown()) then
                        lowest = self.groups[i];
                    end
                end
                self.wimAtlasBg:ClearAllPoints();
                self.wimAtlasBg:SetPoint("TOPLEFT", self.groups[1],
                    "TOPLEFT", -10, 3);
                self.wimAtlasBg:SetPoint("BOTTOMRIGHT", lowest,
                    "BOTTOMRIGHT", 10, -3);
            end
        end

	menu.ApplySkin = function(self, skin)
		skin = skin or GetSelectedSkin();

		local atlas = skin.menu.background_atlas;
		local useAtlas = atlas and getAtlasInfo(atlas);
		if(useAtlas and not self.wimAtlasBg) then
			self.wimAtlasBg = self:CreateTexture(nil, "BACKGROUND");
		end
		if(self.wimAtlasBg) then
			if(useAtlas) then
				self.wimAtlasBg:SetAtlas(atlas);
				self.wimAtlasBg:SetTexCoord(0, 1, 0, 1);
				self.wimAtlasBg:SetAlpha(0.93);
				self.wimAtlasBg:Show();
			else
				self.wimAtlasBg:Hide();
			end
		end

		for i=1, #self.groups do
			local group = self.groups[i];
			group:ApplySkin(skin);
		end

		self:Refresh();
	end

    menu:SetScript("OnUpdate", function(self)
            if(isMouseOver()) then
                self.mouseStamp = _G.time();
            else
                if((_G.time() - self.mouseStamp) > 1) then
                    self:Hide();
                end
            end
        end);
    menu:SetScript("OnShow", function(self)
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
        addToTableUnique(lists[obj.type], obj);
        WIM.Menu:Refresh();
    end
end

function Menu:OnWindowDestroyed(obj)
    -- remove obj to specified list & Update
    obj.widgets.close.forceShift = nil;
    if(obj.type == "whisper" or obj.type == "chat") then
        removeFromTable(lists[obj.type], obj);
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
