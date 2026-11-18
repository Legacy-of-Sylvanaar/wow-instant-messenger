local WIM = WIM;
local utils = WIM.utils;

local skin = {};
utils.skin = skin;

--------------------------------------
--        Skinning Functions        --
--------------------------------------

-- helper to check if atlas exists
skin.getAtlasInfo = function(name)
	if (type(name) ~= "string") then
		return nil;
	end

	setfenv(1, _G); -- required by getAtlasInfo
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) or nil;
end;

-- Atlas Fallbacks
do
	local fallbackAtlasDefinitions = {};

	-- allow a skin to register a fallback if atlas does not exist.
	skin.registerAtlasFallback = function(name, fallback)
		-- required
		if (not name or type(name) ~= "string" or not fallback or type(fallback) ~= "table") then
			return;
		end

		if type(fallback) == "string" then
			fallback = { path = fallback };
		elseif type(fallback) == "table" then
			-- path is required
			if not fallback.path then
				return;
			end

			if (not fallback.texture_coord) then
				fallback.texture_coord = {
					fallback.leftTexCoord or 0,
					fallback.rightTexCoord or 1,
					fallback.topTexCoord or 0,
					fallback.bottomTexCoord or 1
				};
			end

			-- add texture coordinates if missing
			-- if not fallback.texture_coord then
			-- 	fallback.texture_coord = {0, 1, 0, 1};
			-- end
		end

		fallbackAtlasDefinitions[name:lower()] = fallback;
	end

	skin.getAtlasFallbackInfo = function(name)
		return fallbackAtlasDefinitions[name:lower()];
	end
end


-- funType can be "Normal", "Pressed", "Highlight", etc.
-- frame is the UI element to which the texture will be applied.
-- texture can be an atlas reference or a backup atlas definition a path (string) or a table containing texture information.
--	example: { path="Interface\\Buttons\\UI-Panel-Button-Up", texture_coord={0,1,0,1} }
-- Additional arguments (...) for example: "SetHighlight*" takes a second AlphaMode argument.
local function applyTexture(funType, frame, texture, ...)
	-- requirements
	if not frame or not texture then return; end
	if type(texture) ~= "string" and type(texture) ~= "table" then return; end

	-- if string then it is an atlas, check if it exists, if it doesn't,
	-- check fallback atlas definitions and use as table.
	local isAtlas = false;
	if type(texture) == "string" then
		local atlasInfo = skin.getAtlasInfo(texture);
		if atlasInfo then
			isAtlas = true;
		else
			local fallbackInfo = skin.getAtlasFallbackInfo(texture);
			if fallbackInfo then
				texture = fallbackInfo;
				texture._atlas = true;
			else
				texture = { path = texture, --[[texture_coord = {0, 1, 0, 1}]] };
			end
		end
	end

	-- at this point, isAtlas indicates the type of the texture
	-- if it's a table, it is assumed to be a path with additional info parameters.

	local setFun = frame["Set" .. (funType or "") .. (isAtlas and "Atlas" or "Texture")];
	local getFun = frame["Get" .. (funType or "") .. (isAtlas and "Atlas" or "Texture")];

	-- trap to make sure the function we're trying to call actually exists
	if not setFun then return; end

	-- apply the texture using the appropriate function based on its type
	if isAtlas then
		setFun(frame, texture, ...);
		return getFun and getFun(frame) or nil;
	else
		setFun(frame, texture.path, ...);
		if (getFun) then
			local tex = getFun(frame);
			local target = funType and funType ~= "" and tex or frame;
			if tex then
				if (texture.texture_coord) then
					target:SetTexCoord(unpack(texture.texture_coord));
				end

				if texture.size then
					target:SetWidth(texture.size[1]);
					target:SetHeight(texture.size[2]);
				else
					if texture.width then target:SetWidth(texture.width); end
					if texture.height then target:SetHeight(texture.height); end
				end

				if (texture._atlas and target.SetTextureSliceMargins) then
					if (type(texture.sliceData) == "table") then
						target:SetTextureSliceMargins(
							texture.sliceData.marginLeft or 0,
							texture.sliceData.marginTop or 0,
							texture.sliceData.marginRight or 0,
							texture.sliceData.marginBottom or 0
						)
						target:SetTextureSliceMode(texture.sliceData.sliceMode or 0);
					else
						target:ClearTextureSlice();
					end
				end

				target:SetHorizTile(texture.tilesHorizontally or false)
				target:SetVertTile(texture.tilesVertically or false)

				return tex
			end
		end
		return nil
	end
end

function skin.applyTexture(...) return applyTexture(nil, ...); end

function skin.applyNormalTexture(...) return applyTexture("Normal", ...); end

function skin.applyPushedTexture(...) return applyTexture("Pushed", ...); end

function skin.applyDisabledTexture(...) return applyTexture("Disabled", ...); end

function skin.applyHighlightTexture(...) return applyTexture("Highlight", ...); end

skin.nineSlice = {}
-- a SetTexCoord wrapper that stacks transformations on top of the original coordinates
local nsSetTexCoord = function(self, left, right, top, bottom)
	local w = right - left;
	local h = bottom - top;

	local tLeft, tRight, tTop, tBottom = unpack(self._transform or { 0, 1, 0, 1 });

	self:_SetTexCoord(
		left + (tLeft * w),
		left + (tRight * w),
		top + (tTop * h),
		top + (tBottom * h)
	);
end

-- a custom version of SetupPieceVisual used to draw using texture path instead of an atlas.
skin.nineSlice.SetupPieceVisualsUsingPath = function(container, piece, setupInfo, pieceLayout, textureKit, userLayout)
	-- SetupTextureCoordinates
	local left, right, top, bottom = 0, 1, 0, 1;

	local pieceMirrored = pieceLayout.mirrorLayout;
	if pieceMirrored == nil then
		pieceMirrored = userLayout and userLayout.mirrorLayout;
	end

	if pieceMirrored then
		if setupInfo.mirrorVertical then
			top, bottom = bottom, top;
		end

		if setupInfo.mirrorHorizontal then
			left, right = right, left;
		end
	end

	-- hook SetTexCoord to preserve the original coordinates before any modifications
	piece._SetTexCoord = piece.SetTexCoord;
	piece.SetTexCoord = nsSetTexCoord;
	piece._transform = { left, right, top, bottom };

	skin.applyTexture(piece, pieceLayout.atlas or pieceLayout.texture, true);

	piece:SetHorizTile(setupInfo and setupInfo.tileHorizontal or false);
	piece:SetVertTile(setupInfo and setupInfo.tileVertical or false);

	-- cleanup hooks
	piece.SetTexCoord = piece._SetTexCoord;
	piece._transform = nil
end

function skin.isAtlas2x(atlas)
	local info = C_Texture.GetAtlasInfo(atlas);
	return info and info.rawSize and info.width <= info.rawSize.x / 2 and info.height <= info.rawSize.y / 2;
end
