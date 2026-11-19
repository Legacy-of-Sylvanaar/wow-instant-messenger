local WIM = WIM;
local utils = WIM.utils;

utils.compat = {}

--------------------------------------
--     Compatibility Functions      --
--------------------------------------

function utils.compat.GetMouseTopFocus()
	-- Interface 11.0+
	if (GetMouseFoci) then
		return GetMouseFoci()[1]

		-- Legacy method
	else
		return GetMouseFocus()
	end
end
