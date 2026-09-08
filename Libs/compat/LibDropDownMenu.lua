-- LibDropDownMenu is not compatible with classic.
-- This file will act as a slug to polyfill using WoW globals.

local buildNumber = select(4, _G.GetBuildInfo())
local isModernApi = buildNumber >= 30401--This needs review

if (not isModernApi) then
	local DDM = _G.LibStub and _G.LibStub:GetLibrary("LibDropDownMenu", true);

	if (not DDM) then
		-- Packaged external is unavailable (dev checkout or no other addon embedding it);
		-- register a stub whose unresolved lookups fall back to the WoW global api.
		DDM = _G.LibStub and _G.LibStub:NewLibrary("LibDropDownMenu", 1) or {};
		setmetatable(DDM, { __index = function(_, key) return _G[key]; end });
	end

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
		return CreateFrame("Frame", name, parent, "UIDropDownListTemplate");
	end

	function DDM.Create_DropDownMenu (name, parent, options)
		return CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate");
	end
end
