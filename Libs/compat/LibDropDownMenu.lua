-- LibDropDownMenu is not compatible with classic.
-- This file will act as a slug to polyfill using WoW globals.

WIM.libs.compat.DropDownMenu = {};

local DDM = LibStub:GetLibrary("LibDropDownMenu");
local lib = WIM.libs.compat.DropDownMenu;


function lib.Create_DropDownMenuButton (name, parent, options)
	return CreateFrame("Frame", name, parent, "UIDropDownMenuButtonTemplate");
end

function lib.Create_DropDownMenuList (name, parent, options)
	return CreateFrame("Frame", name, parent, "UIDropDownListTemplate ");
end

function lib.Create_DropDownMenu (name, parent, options)
	return CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate");
end

-- lib.CloseDropDownMenus = _G.CloseDropDownMenus;
-- lib.CloseMenus = _G.CloseMenus;
-- lib.OpenColorPicker = _G.OpenColorPicker;
-- lib.ColorPicker_GetPreviousValues = _G.ColorPicker_GetPreviousValues;

local k, v
for k,v in pairs (DDM) do
	lib[k] = _G[k]
end
