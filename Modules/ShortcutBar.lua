--imports
local WIM = WIM;
local _G = _G;
local table = table;
local pairs = pairs;
local CreateFrame = CreateFrame;
local string = string;
local select = select;
local tonumber = tonumber

--set namespace
setfenv(1, WIM);

local buttons = {};

-- create WIM Module
local ShortcutBar = CreateModule("ShortcutBar", true);

local buttonCount = 1;
local function createButton(parent)
	local button = CreateFrame("Button", "WIM_ShortcutBarButton"..buttonCount, parent);
	button.icon = button:CreateTexture(nil, "BACKGROUND");
	button.icon:SetAllPoints();
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button.Enable = function(self)
			self:Show();
			self.isEnabled = true;
			parent:UpdateButtons();
		end
	button.Disable = function(self)
			self:Hide();
			self.isEnabled = false;
			parent:UpdateButtons();
		end
	button:SetScript("OnEnter", function(self)
			if(buttons[self.index].scripts and buttons[self.index].scripts.OnEnter) then
				buttons[self.index].scripts.OnEnter(self);
			else
				if(db.showToolTips) then
					_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
					_G.GameTooltip:SetText(buttons[self.index].title);
				end
			end
		end);
	button:SetScript("OnLeave", function(self)
			_G.GameTooltip:Hide();
			if(buttons[self.index].scripts and buttons[self.index].scripts.OnLeave) then
				buttons[self.index].scripts.OnLeave(self, button);
			end
		end);
	button:SetScript("OnClick", function(self, button)
			if(buttons[self.index].scripts and buttons[self.index].scripts.OnClick) then
				buttons[self.index].scripts.OnClick(self, button);
			end
		end);
	button.SetDefaults = function(self)
			if(buttons[self.index].scripts and buttons[self.index].scripts.SetDefaults) then
				buttons[self.index].scripts.SetDefaults(self);
			end
		end


	button:Enable();
	buttonCount = buttonCount + 1;
	return button;
end



local function createShortCutBar()
	local frame = CreateFrame("Frame");

	--widget info
	frame.type = "whisper"; -- will only show on whisper windows.

	-- test texture so you can see the frame to be placed.
	--frame.test = frame:CreateTexture(nil, "BACKGROUND");
	--frame.test:SetColorTexture(1,1,1,.5);
	--frame.test:SetAllPoints();
	frame.visibleCount = 0;
	frame.buttons = {};
	frame.UpdateSkin = function(self)
			-- make sure all the button objects needed are available.
			local buttonsToCreate = #buttons - #frame.buttons;
			for i=1, buttonsToCreate do
				table.insert(frame.buttons, createButton(self));
			end
			local skin = GetSelectedSkin().message_window.widgets.shortcuts;
			-- set points for all buttons.
			local stack = string.upper(skin.stack);
			local spacing = skin.spacing;
			if(stack == "UP") then
				for i=#buttons, 1, -1 do
					self.buttons[i]:ClearAllPoints();
					if(i==#buttons) then
						self.buttons[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0);
						self.buttons[i]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
					else
						self.buttons[i]:SetPoint("BOTTOMLEFT", self.buttons[i+1], "TOPLEFT", 0, spacing);
						self.buttons[i]:SetPoint("BOTTOMRIGHT", self.buttons[i+1], "TOPRIGHT", 0, spacing);
					end
				end
			end
			if(stack == "DOWN") then
				for i=1, #buttons do
					self.buttons[i]:ClearAllPoints();
					if(i==1) then
						self.buttons[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
						self.buttons[i]:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
					else
						self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i-1], "BOTTOMLEFT", 0, -spacing);
						self.buttons[i]:SetPoint("TOPRIGHT", self.buttons[i-1], "BOTTOMRIGHT", 0, -spacing);
					end
				end
			end
			if(stack == "RIGHT") then
				for i=1, #buttons do
					self.buttons[i]:ClearAllPoints();
					if(i==1) then
						self.buttons[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
						self.buttons[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, 0);
					else
						self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i-1], "TOPRIGHT", spacing, 0);
						self.buttons[i]:SetPoint("BOTTOMLEFT", self.buttons[i-1], "BOTTOMRIGHT", spacing, 0);
					end
				end
			end
			if(stack == "LEFT") then
				for i=#buttons, 1, -1 do
					self.buttons[i]:ClearAllPoints();
					if(i==#buttons) then
						self.buttons[i]:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
						self.buttons[i]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
					else
						self.buttons[i]:SetPoint("TOPRIGHT", self.buttons[i+1], "TOPLEFT", -spacing, 0);
						self.buttons[i]:SetPoint("BOTTOMRIGHT", self.buttons[i+1], "BOTTOMLEFT", -spacing, 0);
					end
				end
			end
			for i=1,#buttons do
				self.buttons[i].index = i;
				self.buttons[i]:SetNormalTexture(skin.buttons.NormalTexture);
				self.buttons[i]:SetPushedTexture(skin.buttons.PushedTexture);
				self.buttons[i]:SetHighlightTexture(skin.buttons.HighlightTexture, skin.buttons.HighlightAlphaMode);
				self.buttons[i].icon:SetTexture(skin.buttons.icons[buttons[i].id] or "Interface\\Icons\\INV_Misc_QuestionMark");
			end
			self:UpdateButtons();
		end
	frame.UpdateButtons = function(self)
			local skin = GetSelectedSkin().message_window.widgets.shortcuts;
			local stack = string.upper(skin.stack) == "UP" or string.upper(skin.stack) == "DOWN";
			self.visibleCount = 0;
			for i=1,  #self.buttons do
				if(stack) then
					if(self.buttons[i].isEnabled) then
						self.visibleCount = self.visibleCount + 1;
						self.buttons[i]:SetHeight(self:GetWidth());
					else
						self.buttons[i]:SetHeight(.001 - skin.spacing);
					end
				else
					if(self.buttons[i].isEnabled) then
						self.visibleCount = self.visibleCount + 1;
						self.buttons[i]:SetWidth(self:GetHeight());
					else
						self.buttons[i]:SetWidth(.001 - skin.spacing);
					end
				end
			end
			-- must update window props to account for size restrictions
			if(self.parentWindow and self.parentWindow.initialized) then
				self.parentWindow:UpdateProps();
			end
		end
	frame.SetDefaults = function(self)
			for i=1, #self.buttons do
				self.buttons[i]:SetDefaults();
			end
		end
	frame.GetButtonCount = function(self)
			return self.visibleCount;
		end
	frame._GetWidth = frame.GetWidth;
	frame.GetWidth = function(self)
			local skin = GetSelectedSkin().message_window.widgets.shortcuts;
			if(string.upper(skin.stack) == "UP" or string.upper(skin.stack) == "DOWN") then
				return self:_GetWidth();
			else
				return self:GetButtonCount()*self:GetHeight() + _G.math.max(self:GetButtonCount()-1, 0)*skin.spacing;
			end
		end
	frame._GetHeight = frame.GetHeight;
	frame.GetHeight = function(self)
			local skin = GetSelectedSkin().message_window.widgets.shortcuts;
			if(string.upper(skin.stack) == "UP" or string.upper(skin.stack) == "DOWN") then
				return self:GetButtonCount()*self:GetWidth() + _G.math.max(self:GetButtonCount()-1, 0)*skin.spacing;
			else
				return self:_GetHeight();
			end
		end
	frame:UpdateSkin();
	return frame;
end


function ShortcutBar:OnEnable()
	RegisterWidget("shortcuts", createShortCutBar);
	for widget in Widgets("shortcuts") do
		widget:Enable();
	end
end

function ShortcutBar:OnDisable()
	if(db.modules.ShortcutBar.enabled) then
		return;
	end
	-- WIM.Widgets(widgetName) is an iterator of all loaded widgets.
	-- Since this widget can be disabled, we will hide the widgets already loaded.
	for widget in Widgets("shortcuts") do
		widget:Disable();
	end
end

local BNinviteTypes = {
	["BN_INVITE"] = true,
	["BN_SUGGEST_INVITE"] = true,
	["BN_REQUEST_INVITE"] = true,
}
local function canInviteBN(id)
	if not tonumber(id) then return end
	local show = true
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount = GetBNGetFriendInfoByID(id);
	if not bnetIDGameAccount then
		show = false;
	else
		local guid = select(20, GetBNGetGameAccountInfo(bnetIDGameAccount));
		local inviteType = _G.GetDisplayedInviteType(guid);
		if not BNinviteTypes["BN_"..inviteType] then
			show = false;
		elseif not _G.CanGroupWithAccount(id) then
			show = false
		elseif ( not _G.BNFeaturesEnabledAndConnected() ) then
			show = false;
		elseif ( _G.UnitInParty(characterName) or _G.UnitInRaid(characterName) ) then
			show = false;
		end
	end
	return show
end

function ShortcutBar:OnWindowShow(obj)
	if (obj.widgets.shortcuts) then
		for i=1, #buttons do
			if (buttons[i].id == "invite") then
				if (obj.isBN and not canInviteBN(obj.bn.id)) then	--if(obj.isBN and obj.bn.realmName ~= env.realm) then
					obj.widgets.shortcuts.buttons[i]:Disable();
				else
					obj.widgets.shortcuts.buttons[i]:Enable();
				end
			elseif buttons[i].id == "ignore" then
				if obj.isBN then
					obj.widgets.shortcuts.buttons[i]:Disable();
				else
					obj.widgets.shortcuts.buttons[i]:Enable();
				end
			end
		end
		obj.widgets.shortcuts:UpdateButtons();
	end
end

function ShortcutBar:FRIENDLIST_UPDATE()
	local friend = nil;
	for i=1, #buttons do
		if(buttons[i].id == "friend") then
			friend = i;
		end
	end
	for widget in Widgets("shortcuts") do
		if(lists.friends[widget.parentWindow.theUser] or _G.UnitName("player") == widget.parentWindow.theUser) then
			if(friend) then
				widget.buttons[friend]:Disable();
			end
		else
			if(friend) then
				widget.buttons[friend]:Enable();
			end
		end
	end
end

-- WIM Global API for Shortcut buttons.
function RegisterShortcut(id, title, scripts)
	table.insert(buttons, {
		id = id,
		title = title,
		scripts = scripts
	});
end



-- Register default buttons.
RegisterShortcut("location", L["Player Location"], {
		OnClick = function(self, button)
			libs.DropDownMenu.CloseDropDownMenus();
			if(button == "LeftButton") then
				local currentSelf = self;
				self.parentWindow:SendWho(function()
					buttons[currentSelf.index].scripts.OnEnter(currentSelf);
					end, true)
			else
				WIM.MENU_ARMORY_USER = self.parentWindow.theUser;
				WIM.MENU_ARMORY_REALM = env.realm;
				if(self.parentWindow.isBN) then
					WIM.MENU_ARMORY_USER = self.parentWindow.bn.toonName;
					WIM.MENU_ARMORY_REALM = self.parentWindow.bn.realmName;
				end
				PopContextMenu("MENU_ARMORY", self:GetName());
			end
		end,
		OnEnter = function(self)
			local location = self.parentWindow.location ~= "" and self.parentWindow.location or L["Unknown"];
			local guild = self.parentWindow.guild ~= "" and self.parentWindow.guild or L["Unknown"];
			local tbl = self.parentWindow.w2w;
			if(not tbl or not tbl.services) then
				_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				_G.GameTooltip:AddLine("|cff"..self.parentWindow.classColor..self.parentWindow.theUser.."|r");
				if(self.parentWindow.isBN) then
					local bn = self.parentWindow.bn;
					if bn.toonName and bn.toonName ~= "" then _G.GameTooltip:AddDoubleLine(L["Character"]..":", "|cffffffff"..bn.toonName.."|r"); end
					if bn.client and bn.client ~= "" then _G.GameTooltip:AddDoubleLine(L["Game"]..":", "|cffffffff"..bn.client.."|r"); end
					if bn.realmName and bn.realmName ~= "" then _G.GameTooltip:AddDoubleLine(L["Realm"]..":", "|cffffffff"..bn.realmName.."|r"); end
				end
				_G.GameTooltip:AddDoubleLine(L["Location"]..":", "|cffffffff"..location.."|r");
				_G.GameTooltip:AddLine("|cff69ccf0"..L["Click to update..."].."|r");
				_G.GameTooltip:AddLine("|cff69ccf0"..L["Right-Click for profile links..."].."|r");
				_G.GameTooltip:Show(txt);
			else
				--w2w tooltip
				ShowW2WTip(self.parentWindow, self, "ANCHOR_RIGHT");
			end
		end
	});
RegisterShortcut("invite", L["Invite to Party"], {
		OnClick = function(self)
			local win = self.parentWindow;
			if win.isBN then
				if _G.C_BattleNet then
					--Tested working on Retail
					local accountInfo = _G.C_BattleNet.GetAccountInfoByID(win.bn.id)
					local gameAccountID = accountInfo.gameAccountInfo.gameAccountID
					if gameAccountID then
						_G.BNInviteFriend(gameAccountID)
					end
				else
					--No idea if this actually works on classic, or if BNInviteFriend shouldb e used instead with gameID
					_G.FriendsFrame_BattlenetInvite(nil, win.bn.id)
				end
			else
				if isModernApi then
					_G.C_PartyInfo.InviteUnit(win.theUser)
				else
					_G.InviteUnit(win.theUser)
				end
			end
		end
	});
RegisterShortcut("friend", L["Add Friend"], {
		OnClick = function(self)
			_G.C_FriendList.AddFriend(self.parentWindow.theUser);
		end,
		SetDefaults = function(self)
			ShortcutBar:FRIENDLIST_UPDATE();
		end
	});
RegisterShortcut("ignore", L["Ignore User"], {
		OnClick = function(self)
		local win = self.parentWindow;
		_G.StaticPopupDialogs["WIM_IGNORE"] = {
		preferredIndex = STATICPOPUP_NUMDIALOGS,
		text = _G.format(L["Are you sure you want to\nignore %s?"], "|cff69ccf0"..(win.isBN and win.toonName or win.theUser).."|r"),
		button1 = L["Yes"],
		button2 = L["No"],
		OnAccept = function()
			_G.C_FriendList.AddIgnore(win.isBN and win.toonName or win.theUser);
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
		};
		_G.StaticPopup_Show("WIM_IGNORE");
		end
	});
