local _G = _G;
local defaults = _G.WIM.db_defaults;
local Settings = _G.Settings;
local type = type;
local WIM = WIM;

--set namespace
setfenv(1, WIM);

function BuildOptions ()
	local addon, layout = Settings.RegisterVerticalLayoutCategory("WIM");

	-- Main Settings
	do
		-- Enable/Disable WIM
		do
			local setting = Settings.RegisterAddOnSetting(addon, "WIM_ENABLED",
				"enabled", db, Settings.VarType.Boolean,
				L["Enable WIM"], defaults.enabled);

			setting:SetValueChangedCallback(function (setting, value)
				SetEnabled(value);
			end);

			Settings.CreateCheckbox(addon, setting);
		end

		-- Minimap Icon
		layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(_G.MINIMAP_LABEL));
		do
			local setting = Settings.RegisterAddOnSetting(addon, "WIM_MINIMAP_ENABLED",
				"enabled", modules.MinimapIcon, Settings.VarType.Boolean,
				L["Display Minimap Icon"], Settings.Default.True);

			setting:SetValueChangedCallback(function (setting, value)
				EnableModule("MinimapIcon", value);
			end);

			local minimapInitializer = Settings.CreateCheckbox(addon, setting, L["<Shift-Click> + Drag to move."]);

			-- unlock from minimap
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_MINIMAP_UNLOCK",
					"free", db.minimap, Settings.VarType.Boolean,
					L["Unlock from Minimap"], Settings.Default.False);

				setting:SetValueChangedCallback(function (setting, value)
					modules.MinimapIcon:OnEnable()
				end);

				local unlockInitializer = Settings.CreateCheckbox(addon, setting, L["Move icon freely around the screen."]);

				local function IsModifiable ()
					return modules.MinimapIcon.enabled;
				end

				unlockInitializer:SetParentInitializer(minimapInitializer, IsModifiable);
			end

			-- Right click to show unread.
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_MINIMAP_RIGHT_CLICK_UNREAD",
					"rightClickNew", db.minimap, Settings.VarType.Boolean,
					L["<Right-Click> to show unread messages."], Settings.Default.False);

				local unlockInitializer = Settings.CreateCheckbox(addon, setting);

				local function IsModifiable ()
					return modules.MinimapIcon.enabled;
				end

				unlockInitializer:SetParentInitializer(minimapInitializer, IsModifiable);
			end
		end

		-- Accessibility
		layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(_G.ACCESSIBILITY_LABEL));
		do
			-- Addon Compartment Frame
			if _G.AddonCompartmentFrame then
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_ADDON_COMPARTMENT_ENABLED",
					"enabled", modules.AddonCompartment, Settings.VarType.Boolean,
					L["Display Addon Compartment Icon"], Settings.Default.False);

				setting:SetValueChangedCallback(function (setting, value)
					EnableModule("AddonCompartment", value);
				end);

				Settings.CreateCheckbox(addon, setting);
			end
			-- tab to advance
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_TAB_TO_ADVANCE",
					"tabAdvance", db, Settings.VarType.Boolean,
					L["Press <Tab> to advance to next tell target."], defaults.tabAdvance);

				Settings.CreateCheckbox(addon, setting);
			end

			-- tab to advance
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_FORCE_GAME_SOUND",
					"force_game_sound", db, Settings.VarType.Boolean,
					L["Force sounds when game sound is disabled."], defaults.force_game_sound);

				Settings.CreateCheckbox(addon, setting);
			end

			-- Ignore arrow keys in message box
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_WINDOW_IGNORE_ARROW_KEYS",
					"ignoreArrowKeys", db, Settings.VarType.Boolean,
					L["Ignore Arrow Keys in Message Box"], defaults.ignoreArrowKeys);

				Settings.CreateCheckbox(addon, setting);
			end

			-- Allow <ESC> to hide windows
			do
				local setting = Settings.RegisterAddOnSetting(addon, "WIM_WINDOW_ESC_HIDES",
					"escapeToHide", db, Settings.VarType.Boolean,
					L["Allow <ESC> to hide windows"], defaults.escapeToHide);

				Settings.CreateCheckbox(addon, setting);
			end
		end
	end

	-- Window Settings
	do
		local windowSettings, layout = Settings.RegisterVerticalLayoutSubcategory(addon, L["Window Settings"]);

		-- Window size
		layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(L["Default Size"], L["Some settings may be limited by certain skins."]));
		do
			-- Width
			do
				local max = 800;
				local setting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_DEFAULT_WIDTH",
					"width", db.winSize, Settings.VarType.Number,
					_G.HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH, defaults.winSize.width);

				setting:SetValueChangedCallback(function (setting, value)
					UpdateAllWindowProps();
				end);

				local minValue, maxValue, step = 150, max, 1;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(_G.MinimalSliderWithSteppersMixin.Label.Right, _G.FormatNumber);

				Settings.CreateSlider(windowSettings, setting, options);
			end

			-- Height
			do
				local max = 600;
				local setting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_DEFAULT_HEIGHT",
					"height", db.winSize, Settings.VarType.Number,
					_G.HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT, defaults.winSize.height);

				setting:SetValueChangedCallback(function (setting, value)
					UpdateAllWindowProps();
				end);

				local minValue, maxValue, step = 80, max, 1;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(_G.MinimalSliderWithSteppersMixin.Label.Right, _G.FormatNumber);

				Settings.CreateSlider(windowSettings, setting, options);
			end

			-- Scale
			do
				local max = 400;
				local setting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_DEFAULT_SCALE",
					"scale", db.winSize, Settings.VarType.Number,
					_G.UI_SCALE, defaults.winSize.scale);

				setting:SetValueChangedCallback(function (setting, value)
					UpdateAllWindowProps();
				end);

				local minValue, maxValue, step = 10, max, 1;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(_G.MinimalSliderWithSteppersMixin.Label.Right, function (percent, nearest)
					return _G.FormatPercentage(percent / 100, nearest);
				end);

				Settings.CreateSlider(windowSettings, setting, options);
			end
		end

		-- Window Position
		layout:AddInitializer(_G.CreateSettingsListSectionHeaderInitializer(L["Positioning"]));
		do
			-- Window Strata
			do
				local setting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_DEFAULT_STRATA",
					"strata", db.winSize, Settings.VarType.String,
					L["Window Strata"], defaults.winSize.strata);

				setting:SetValueChangedCallback(function (setting, value)
					UpdateAllWindowProps();
				end);

				local function GetOptions ()
					local container = Settings.CreateControlTextContainer();
					container:Add("BACKGROUND", L["Background"]);
					container:Add("LOW", L["Low"]);
					container:Add("MEDIUM", L["Medium"]);
					container:Add("HIGH", L["High"]);
					container:Add("DIALOG", L["Dialog"]);
					container:Add("TOOLTIP", L["Tooltip"]);
					return container:GetData();
				end

				Settings.CreateDropdown(windowSettings, setting, GetOptions);
			end

			-- Clamp to screen
			do
				local setting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_CLAMP_TO_SCREEN",
					"clampToScreen", db, Settings.VarType.Boolean,
					L["Clamp to Screen"], defaults.clampToScreen);

				setting:SetValueChangedCallback(function (setting, value)
					UpdateAllWindowProps();
				end);

				Settings.CreateCheckbox(windowSettings, setting);
			end

			-- Cascade windows
			do
				local enabledSetting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_CASCADE",
					"enabled", db.winCascade, Settings.VarType.Boolean,
					L["Cascade Windows"], defaults.winCascade.enabled);
				local directionSetting = Settings.RegisterAddOnSetting(windowSettings, "WIM_WINDOW_CASCADE_DIRECTION",
					"direction", db.winCascade, Settings.VarType.Number,
					L["Cascade Direction"], defaults.winCascade.direction);

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(1, L["Up"]);
					container:Add(2, L["Down"]);
					container:Add(3, L["Left"]);
					container:Add(4, L["Right"]);
					container:Add(5, L["Up"] .. " & " .. L["Left"]);
					container:Add(6, L["Up"] .. " & " .. L["Right"]);
					container:Add(7, L["Down"] .. " & " .. L["Left"]);
					container:Add(8, L["Down"] .. " & " .. L["Right"]);
					return container:GetData();
				end

				local data =
				{
					name = L["Cascade Windows"],
					tooltip = nil,
					cbSetting = enabledSetting,
					cbLabel = L["Cascade Windows"],
					cbTooltip = nil,
					dropdownSetting = directionSetting,
					dropdownOptions = GetOptions,
					dropDownLabel = L["Cascade Direction"],
					dropDownTooltip = nil,
				};
				local initializer = Settings.CreateSettingInitializer("SettingsCheckboxDropdownControlTemplate", data);
				initializer:AddSearchTags(L["Cascade Windows"], L["Cascade Direction"]);
				layout:AddInitializer(initializer);

			end
		end
	end

	-- Settings.RegisterCanvasLayoutSubcategory(addon, General_VisualSettings(), L["Display Settings"]);
	-- -- Settings.RegisterCanvasLayoutSubcategory(addon, General_Fonts(), L["Fonts"]);
	-- Settings.RegisterCanvasLayoutSubcategory(addon, General_MessageFormatting(), L["Message Formatting"]);
	-- Settings.RegisterCanvasLayoutSubcategory(addon, General_Tabs(), L["Tab Management"]);
	-- Settings.RegisterCanvasLayoutSubcategory(addon, General_Expose(), L["Expose"]);

	-- local whispers, _ = Settings.RegisterVerticalLayoutSubcategory(addon, L["Whispers"]);
	-- Settings.RegisterCanvasLayoutSubcategory(whispers, Whispers_DisplaySettings(), L["Display Settings"]);
	-- Settings.RegisterCanvasLayoutSubcategory(whispers, General_History(), L["History"]);
	-- -- Settings.RegisterCanvasLayoutSubcategory(whispers, Whispers_Filters(), L["Filtering"]);
	-- Settings.RegisterCanvasLayoutSubcategory(whispers, General_Sounds(), L["Sounds"]);
	-- Settings.RegisterCanvasLayoutSubcategory(whispers, WhisperPopRules(), L["Window Behavior"]);

	-- local chat, _ = Settings.RegisterVerticalLayoutSubcategory(addon, L["Chat"]);
	-- Settings.RegisterCanvasLayoutSubcategory(chat, General_History(true), L["History"]);
	-- -- Settings.RegisterCanvasLayoutSubcategory(chat, Whispers_Filters(true), L["Filtering"]);
	-- Settings.RegisterCanvasLayoutSubcategory(chat, General_Sounds(true), L["Sounds"]);
	-- Settings.RegisterCanvasLayoutSubcategory(chat, ChatPopRules(), L["Window Behavior"]);

	-- Settings.RegisterCanvasLayoutSubcategory(addon, General_Credits(), L["Credits"]);

	Settings.RegisterAddOnCategory(addon);

	_G.DEFAULT_CHAT_FRAME:AddMessage("WIM Options Loaded");
end

-- build options
_G.EventUtil.ContinueOnVariablesLoaded(function ()
	_G.C_Timer.After(0, function ()
		BuildOptions();
	end);
end);
