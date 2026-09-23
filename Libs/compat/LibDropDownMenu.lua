-- LibDropDownMenu is not compatible with classic.
-- This file will act as a slug to polyfill using WoW globals.

local buildNumber = select(4, _G.GetBuildInfo())
-- WoW Forever reports interface 16001 (1.60.x) but runs on the modern client,
-- so it needs the modern path as well. Otherwise the minimap right-click menu
-- silently fails to open.
local isForever = buildNumber >= 16000 and buildNumber < 20000
local isModernApi = buildNumber >= 30401

if (not isModernApi and not isForever) then
	local DDM = LibStub:GetLibrary("LibDropDownMenu");

	local k, v
	for k,v in pairs (DDM) do
		if (_G[k]) then
			DDM[k] = _G[k]
		end
	end

	function DDM.Create_DropDownMenuButton (name, parent, options)
		return CreateFrame("Frame", name, parent, "UIDropDownMenuButtonTemplate");
	end

	function DDM.Create_DropDownMenuList (name, parent, options)
		return CreateFrame("Frame", name, parent, "UIDropDownListTemplate ");
	end

	function DDM.Create_DropDownMenu (name, parent, options)
		return CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate");
	end
end
