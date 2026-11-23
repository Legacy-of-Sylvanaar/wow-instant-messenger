local WIM = WIM;
local utils = WIM.utils;

utils.color = {};

----------------------------------------------
--              Gradient Tools              --
----------------------------------------------
-- the following bits of code is a result of boredom
-- and determination to get it done. The gradient pattern
-- which I was aiming for could not be manipulated in RGB,
-- however by converting RGB to HSV, the pattern now becomes
-- linear and as such, can now be given any color and
-- have the same gradient effect applied.

function utils.color.RGBPercentToHex(r, g, b)
	return string.format("%.2x%.2x%.2x", r * 255, g * 255, b * 255);
end

function utils.color.RGBHexToPercent(rgbStr)
	local R, G, B = string.sub(rgbStr, 1, 2), string.sub(rgbStr, 3, 4), string.sub(rgbStr, 5, 6);
	return tonumber(R, 16) / 255, tonumber(G, 16) / 255, tonumber(B, 16) / 255;
end

function utils.color.RGBHextoHSVPerc(rgbStr)
	local R, G, B = utils.color.RGBHexToPercent(rgbStr);
	local i, x, v, f;
	x = math.min(R, G);
	x = math.min(x, B);
	v = math.max(R, G);
	v = math.max(v, B);
	if (v == x) then
		return nil, 0, v;
	else
		if (R == x) then
			f = G - B;
		elseif (G == x) then
			f = B - R;
		else
			f = R - G;
		end
		if (R == x) then
			i = 3;
		elseif (G == x) then
			i = 5;
		else
			i = 1;
		end
		return ((i - f / (v - x)) / 6), (v - x) / v, v;
	end
end

function utils.color.HSVPerctoRGBPerc(H, S, V)
	local m, n, f, i;
	if (H == nil) then
		return V, V, V;
	else
		H = H * 6;
		if (H == 0) then
			H = .01;
		end
		i = math.floor(H);
		f = H - i;
		if ((i % 2) == 0) then
			f = 1 - f; -- if i is even
		end
		m = V * (1 - S);
		n = V * (1 - S * f);
		if (i == 6 or i == 0) then
			return V, n, m;
		elseif (i == 1) then
			return n, V, m;
		elseif (i == 2) then
			return m, V, n;
		elseif (i == 3) then
			return m, n, V;
		elseif (i == 4) then
			return n, m, V;
		elseif (i == 5) then
			return V, m, n;
		else
			return 0, 0, 0;
		end
	end
end

-- pass rgb as single arg hex, or triple arg rgb percent.
-- entering ! before a hex, will return a solid color.
function utils.color.getGradientFromColor_Legacy(...)
	local h, s, v, s1, v1, s2, v2;
	if (select("#", ...) == 0) then
		return 0, 0, 0, 0, 0, 0;
	elseif (select("#", ...) == 1) then
		if (string.sub(select(1, ...), 1, 1) == "!") then
			local rgbStr = string.sub(select(1, ...), 2, 7);
			local R, G, B = string.sub(rgbStr, 1, 2), string.sub(rgbStr, 3, 4), string.sub(rgbStr, 5, 6);
			return tonumber(R, 16) / 255, tonumber(G, 16) / 255, tonumber(B, 16) / 255, tonumber(R, 16) / 255,
				tonumber(G, 16) / 255, tonumber(B, 16) / 255;
		else
			h, s, v = utils.color.RGBHextoHSVPerc(select(1, ...));
		end
	else
		h, s, v = utils.color.RGBHextoHSVPerc(string.format("%.2x%.2x%.2x", select(1, ...), select(2, ...),
			select(3, ...)));
	end

	s1 = math.min(1, s + .29 / 2);
	v1 = math.max(0, v - .57 / 2);
	s2 = math.max(0, s - .29 / 2);
	v2 = math.min(1, s + .57 / 2);

	local r1, g1, b1 = utils.color.HSVPerctoRGBPerc(h, s1, v1);
	local r2, g2, b2 = utils.color.HSVPerctoRGBPerc(h, s2, v2);

	return r1, g1, b1, r2, g2, b2;
end

function utils.color.getGradientFromColor(...)
	local r1, g1, b1, r2, g2, b2 = utils.color.getGradientFromColor_Legacy(...)

	return { r = r1, g = g1, b = b1, a = 1 }, { r = r2, g = g2, b = b2, a = 1 }
end
