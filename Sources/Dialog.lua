-- imports
local WIM = WIM;
local _G = _G;
local CreateFrame = CreateFrame;
local GameDialogMixin = GameDialogMixin;
local BaseLayoutMixin = BaseLayoutMixin;
local Mixin = Mixin;
local ipairs = ipairs;
local PlaySound = PlaySound;
local StaticPopupDialogs = StaticPopupDialogs;
local SOUNDKIT = SOUNDKIT;
local table = table;
local UIParent = UIParent;

-- set WIM Namespace
setfenv(1, WIM);

local dialog = {};
utils.dialog = dialog;

local pool = {};

WIMDialogMixin = Mixin({}, GameDialogMixin)

do
	function WIMDialogMixin:OnLoad()
		self.reserved = true;
		GameDialogMixin.OnLoad(self);
	end

	function WIMDialogMixin:OnShow()
		if (not self.which) then
			return;
		end

		GameDialogMixin.OnShow(self);
		_G.C_Timer.After(0, function()
			AddEscapeWindow(self);
		end);
	end

	function WIMDialogMixin:OnHide()
		if (not self.which) then
			return;
		end

		GameDialogMixin.OnHide(self);
		RemoveEscapeWindow(self);
	end

	function WIMDialogMixin:OnUpdate()
		if (not self.which) then
			return;
		end

		GameDialogMixin.OnUpdate(self);
	end
end

local function setupPosition (dialog)
	dialog:SetPoint("TOP", _G.GetAppropriateTopLevelParent(), "TOP", 0, dialog.topOffset or -135);
end

local createDialog = function ()
	local dialog = CreateFrame("Frame", "WIMStaticPopup"..(#pool + 1), UIParent, "WIMStaticPopupTemplate");
	dialog:SetFrameStrata("DIALOG");
	dialog:Hide();
	table.insert(pool, dialog);

	return dialog;
end

function dialog.create(which, text_arg1, text_arg2, data, insertedFrame, customOnHideScript)
	-- if classic, fall back to the standard StaticPopup_Show
	if not (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE or isForever) then
		_G.StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame, customOnHideScript);
		return;
	end

	local dialog;

	-- check pool for non-visible dialogs
	for _, d in ipairs(pool) do
		if not d:IsVisible() then
			dialog = d;
			break;
		end
	end

	-- if none available, create a new one
	if not dialog then
		dialog = createDialog();
	end

	dialogInfo =  StaticPopupDialogs[which];

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.dialogInfo = dialogInfo;
	dialog.data = data;
	dialog.timeleft = dialogInfo.timeout or 0;
	dialog.hideOnEscape = dialogInfo.hideOnEscape;
	dialog.exclusive = dialogInfo.exclusive;
	dialog.enterClicksFirstButton = dialogInfo.enterClicksFirstButton;
	dialog.insertedFrame = insertedFrame;
	dialog.customOnHideScript = customOnHideScript;
	dialog.progressBarDuration = nil;

	dialog:SetParent(_G.GetAppropriateTopLevelParent());
	dialog:Init(which, text_arg1, text_arg2, data, insertedFrame);
	dialog:SetWindow(nil);

	-- Finally size and show the dialog
	setupPosition(dialog);
	dialog:Show();
	dialog:Resize();

	if dialogInfo.sound then
		PlaySound(dialogInfo.sound);
	end

	return dialog;
end

function dialog.confirm(text, callback, acceptText, cancelText)
	return dialog.create("GENERIC_CONFIRMATION", nil, nil, {
		text = text or "",
		acceptText = acceptText,
		cancelText = cancelText,
		callback = callback or function() end
	});
end

-- Copy Dialog
do
	StaticPopupDialogs["WIM_COPY_DIALOG"] = {
		text = "",
		button1 = _G.CLOSE,
		hasEditBox = 1,
		hasWideEditBox = 1,
		editBoxWidth = 350,
		showAlert = true,
		OnShow = function(self, data)
			self:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
			local name = self:GetName();
			local _self = self;
			local editBox = self.EditBox or self.editBox
				or (name and _G[name.."EditBox"]);
			if (editBox) then
				editBox:SetScript("OnKeyDown", function(self, key)
					if key == "C" and _G.IsControlKeyDown() then
						_G.C_Timer.After(0, function()
							_self:Hide();
						end);
					end
				end)

				editBox:SetScript("OnUpdate", function (self)
					self:HighlightText();
				end)

				editBox:SetText(data.value or "");
				editBox:HighlightText();
				editBox:SetFocus();
			end

			local alertIcon = _G.getglobal(self:GetName().."AlertIcon") or self.AlertIcon;
			alertIcon:Hide();  -- HACK : we hide the false AlertIcon
		end,
		OnHide = function (self)
			local name = self:GetName();
			local _self = self;
			local editBox = self.EditBox or self.editBox
				or (name and _G[name.."EditBox"]);
			editBox:SetScript("OnKeyDown", nil);
			editBox:SetScript("OnUpdate", nil);
		end,
		EditBoxOnTextChanged = function(self, data)
			if (self:GetText() ~= (data.value or "")) then
				self:SetText(data.value or "");
				self:HighlightText();
			end
		end,
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide(); end,
		EditBoxOnEnterPressed = function(self) self:GetParent():Hide(); end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	};
end

function dialog.copy(value, text)
	return dialog.create("WIM_COPY_DIALOG", nil, nil, {
		value = value,
		text = text or L["Press Ctrl+C to copy to clipboard."]
	});
end
