--imports
local WIM = WIM;
local _G = _G;
local table = table;
local pairs = pairs;
local CreateFrame = CreateFrame;
local string = string;
local select = select;
local tonumber = tonumber
local type = type;

--set namespace
setfenv(1, WIM);

local buttons = {};

local function getButtonTable (winType)
	local _buttons = buttons[winType] or {};
	buttons[winType] = _buttons;

	return buttons[winType];
end

-- create WIM Module
local ShortcutBar = CreateModule("ShortcutBar", true);

-- local buttonCount = 1;
local function createButton(parent)
	local buttonCount = #parent.buttons + 1;

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
			local buttons = getButtonTable(parent.type);

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
			local buttons = getButtonTable(parent.type);

			_G.GameTooltip:Hide();
			if(buttons[self.index].scripts and buttons[self.index].scripts.OnLeave) then
				buttons[self.index].scripts.OnLeave(self, button);
			end
		end);
	button:SetScript("OnClick", function(self, button)
			local buttons = getButtonTable(parent.type);

			if(buttons[self.index].scripts and buttons[self.index].scripts.OnClick) then
				buttons[self.index].scripts.OnClick(self, button);
			end
		end);
	button.SetDefaults = function(self)
			local buttons = getButtonTable(parent.type);

			if(buttons[self.index].scripts and buttons[self.index].scripts.SetDefaults) then
				buttons[self.index].scripts.SetDefaults(self);
			end
		end


	button:Enable();
	buttonCount = buttonCount + 1;
	return button;
end



local function createShortCutBar(win)
	local frame = CreateFrame("Frame");

	--widget info
	frame.type = win.type or '-unknown-'; -- will only show on whisper windows.

	-- init reference to buttons table.
	local buttons = getButtonTable(frame.type);

	-- test texture so you can see the frame to be placed.
	--frame.test = frame:CreateTexture(nil, "BACKGROUND");
	--frame.test:SetColorTexture(1,1,1,.5);
	--frame.test:SetAllPoints();
	frame.visibleCount = 0;
	frame.buttons = {};
	frame.UpdateSkin = function(self)
			local buttons = getButtonTable(frame.type);

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
				self.buttons[i].parentWindow = self.parentWindow;
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

local function isIgnored(name)
	if(not name) then return end
	if _G.C_FriendList and _G.C_FriendList.IsIgnored then
		return _G.C_FriendList.IsIgnored(name);
	else
		return _G.IsIgnored(name);
	end
end

local function addIgnore(name)
	if _G.C_FriendList and _G.C_FriendList.AddIgnore then
		_G.C_FriendList.AddIgnore(name);
	else
		_G.AddIgnore(name);
	end
end

function ShortcutBar:OnWindowShow(obj)
	local buttons = getButtonTable(obj.type);

	if (obj.widgets.shortcuts) then
		for i=1, #buttons do
			if (buttons[i].id == "invite") then
				if (obj.isBN and not canInviteBN(obj.bn.id)) then	--if(obj.isBN and obj.bn.realmName ~= env.realm) then
					obj.widgets.shortcuts.buttons[i]:Disable();
				else
					obj.widgets.shortcuts.buttons[i]:Enable();
				end
		elseif buttons[i].id == "ignore" then
			local btn = obj.widgets.shortcuts.buttons[i];
			if obj.isBN or (obj.theUser and isIgnored(obj.theUser)) then
				btn:Disable();
			else
				btn:Enable();
			end
		elseif buttons[i].id == "guild" then
				if obj.isBN or not _G.IsInGuild() or not _G.CanGuildInvite() or (obj.theUser and lists.guild[obj.theUser]) then
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
	local buttons = getButtonTable("whisper");

	local friend = nil;
	for i=1, #buttons do
		if(buttons[i].id == "friend") then
			friend = i;
		end
	end
	if(not friend) then
		return;
	end
	for widget in Widgets("shortcuts") do
		-- friend index is from the whisper button table; other window types (chat) have their own button sets.
		local button = widget.type == "whisper" and widget.buttons[friend];
		if(button and widget.parentWindow) then
			if(_G.UnitName("player") == widget.parentWindow.theUser or lists.friends[widget.parentWindow.theUser]) then
				button:Disable();
			else
				button:Enable();
			end
		end
	end
end

function ShortcutBar:IGNORELIST_UPDATE()
	local buttons = getButtonTable("whisper");

	local ignore = nil;
	for i=1, #buttons do
		if(buttons[i].id == "ignore") then
			ignore = i;
		end
	end
	if(not ignore) then
		return;
	end
	for widget in Widgets("shortcuts") do
		local button = widget.type == "whisper" and widget.buttons[ignore];
		if(button and widget.parentWindow) then
			if(widget.parentWindow.isBN or isIgnored(widget.parentWindow.theUser)) then
				button:Disable();
			else
				button:Enable();
			end
		end
	end
end

-- WIM Global API for Shortcut buttons.
function RegisterShortcut(id, title, options)
	options = options or {};

	-- defaults
	options.type = options.type or "whisper"; -- default to whisper windows.

	local scripts = {};
	local info = {
		id = id,
		title = title,
		scripts = scripts
	}

	-- load info table
	for k, v in pairs(options) do
		if(type(v) == "function") then
			scripts[k] = v;
		else
			info[k] = v;
		end
	end

	for winType in info.type:gmatch("[^,%s]+") do
		local buttons = getButtonTable(winType);
		table.insert(buttons, info);
	end
end



-- Register default buttons.
RegisterShortcut("location", L["Player Location"], {
		type = "whisper",
		OnClick = function(self, button)
			libs.DropDownMenu.CloseDropDownMenus();
			if(button == "LeftButton") then
				local currentSelf = self;
				self.parentWindow:SendWho(function()
					-- #271: the file-scope `buttons` is the TYPE-KEYED registry,
				-- not a button list -- indexing it with a number returned
				-- nil and the callback errored. Look up the window type's
				-- list like every other handler does.
				getButtonTable(currentSelf.parentWindow.type or "whisper")[currentSelf.index].scripts.OnEnter(currentSelf);
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
				if _G.C_PartyInfo and _G.C_PartyInfo.InviteUnit then
					_G.C_PartyInfo.InviteUnit(win.theUser)
				else
					_G.InviteUnit(win.theUser)
				end
			end
		end
	});
RegisterShortcut("guild", L["Invite to Guild"], {
	OnClick = function(self)
		local win = self.parentWindow;
		_G.GuildInvite(win.theUser);
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
RegisterShortcut("ignore", L["Ignore Player"], {
	OnClick = function(self)
		local win = self.parentWindow;
		_G.StaticPopupDialogs["WIM_IGNORE"] = {
		preferredIndex = STATICPOPUP_NUMDIALOGS,
		text = _G.format(L["Are you sure you want to\nignore %s?"], (win.isBN and win.toonName or win.theUser)),
		button1 = L["Yes"],
		button2 = L["No"],
		OnAccept = function()
			addIgnore(win.isBN and win.toonName or win.theUser);
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
		};
		_G.StaticPopup_Show("WIM_IGNORE");
	end
});

-- Say output toggle: a letter in the outgoing chat type's color,
-- shown on the say window while the Modern skin is active.
local SAY_LABELS = { SAY = "S", YELL = "Y", EMOTE = "E" };
local SAY_NAMES = { SAY = _G.SAY, YELL = _G.YELL, EMOTE = _G.EMOTE };

local function sayOutputAllowed(obj)
	local skin = GetSelectedSkin();
	return (obj and obj.chatType == "say" and skin and skin.modernOnly)
		and true or false;
end

local function paintSayOutput(button)
	if(not button.wimText) then
		button.icon:Hide();
		button.wimText = button:CreateFontString(nil, "OVERLAY",
			"GameFontNormalLarge");
		button.wimText:SetPoint("CENTER");
	end
	local mode = GetSayOutputType();
	button.wimText:SetText(SAY_LABELS[mode]);
	local info = _G.ChatTypeInfo[mode];
	if(info) then
		button.wimText:SetTextColor(info.r, info.g, info.b);
	end
end

local function sayOutputTooltip(self)
	local mode = GetSayOutputType();
	_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	_G.GameTooltip:SetText(SAY_NAMES[mode] or mode);
	_G.GameTooltip:AddLine(L["Click to switch between Say, Yell, and Emote."],
		1, 1, 1, true);
	_G.GameTooltip:Show();
end

RegisterShortcut("sayOutput", L["Say, Yell, or Emote"], {
	type = "chat",
	OnClick = function(self)
		CycleSayOutputType();
		paintSayOutput(self);
		if(_G.GameTooltip:IsOwned(self)) then
			sayOutputTooltip(self);
		end
	end,
	OnEnter = function(self)
		sayOutputTooltip(self);
	end,
	SetDefaults = function(self)
		if(sayOutputAllowed(self.parentWindow)) then
			paintSayOutput(self);
			self:Enable();
		else
			self:Disable();
		end
	end
});

local function updateSayOutputButton(obj)
	local bar = obj and obj.widgets and obj.widgets.shortcuts;
	if(not bar) then return; end
	local buttons = getButtonTable(bar.type);
	for i=1, #buttons do
		if(buttons[i].id == "sayOutput" and bar.buttons[i]) then
			if(sayOutputAllowed(obj)) then
				paintSayOutput(bar.buttons[i]);
				bar.buttons[i]:Enable();
			else
				bar.buttons[i]:Disable();
			end
			return;
		end
	end
end

function UpdateSayOutputShortcut(obj)
	updateSayOutputButton(obj);
end

local ShortcutBar_OnWindowShow = ShortcutBar.OnWindowShow;
function ShortcutBar:OnWindowShow(obj)
	ShortcutBar_OnWindowShow(self, obj);
	if(obj.type == "chat") then
		updateSayOutputButton(obj);
	end
end

function ShortcutBar:OnSkinLoaded()
	for widget in Widgets("shortcuts") do
		local obj = widget.parentWindow;
		if(obj and obj.type == "chat") then
			updateSayOutputButton(obj);
		end
	end
end
