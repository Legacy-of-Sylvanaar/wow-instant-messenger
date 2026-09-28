-- WIM Modern: a dark, minimal skin that follows the look of the game's
-- current UI panels. It is registered as a delta over WIM Classic, so
-- widget layout, class icons, emoticons, and anything else not defined
-- here is inherited unchanged.
--
-- The textures are script-generated flat geometry, with no hand-drawn
-- art.

local path = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Modern\\";

-- Standard gold UI label color, for the panel title and section headers.
local goldR, goldG, goldB = GameFontNormal:GetTextColor();

local function getNineSliceLayout (usePortrait)
	return {
		BottomEdge = {
			atlas = "_UI-Frame-Metal-EdgeBottom",
			layer = "OVERLAY",
			x = 0,	x1 = 0,	y = 0,	y1 = 0,
		},
		BottomLeftCorner = {
			atlas = "UI-Frame-Metal-CornerBottomLeft",
			layer = "OVERLAY",
			x = -13, y = -3,
		},
		BottomRightCorner = {
			atlas = "UI-Frame-Metal-CornerBottomRight",
			layer = "OVERLAY",
			x = 4,	y = -3,
		},
		LeftEdge = {
			atlas = "!UI-Frame-Metal-EdgeLeft",
			layer = "OVERLAY",
			x = 0,	x1 = 0,	y = 0,	y1 = 0,
		},
		RightEdge = {
			atlas = "!UI-Frame-Metal-EdgeRight",
			layer = "OVERLAY",
			x = 0,	x1 = 0,	y = 0,	y1 = 0,
		},
		TopEdge = {
			atlas = "_UI-Frame-Metal-EdgeTop",
			layer = "OVERLAY",
			x = 0,	x1 = 0,	y = 0,	y1 = 0,
		},
		TopLeftCorner = {
			atlas = usePortrait and "UI-Frame-PortraitMetal-CornerTopLeft" or "UI-Frame-Metal-CornerTopLeft",
			layer = "OVERLAY",
			x = -13, y = 16,
		},
		TopRightCorner = {
			atlas = "UI-Frame-Metal-CornerTopRight",
			layer = "OVERLAY",
			x = 4,	y = 16,
		},
		disableSharpening = true,

		-- Need to reference SetupPieceVisualsUsingPath in order to use a texture path over an atlas.
		setupPieceVisualsFunction = WIM.utils.skin.nineSlice.SetupPieceVisualsUsingPath
	}
end

-- Define an adaptive 9-slice layout for the modern skin.
NineSliceUtil.AddLayout(
	-- layout name
	"WIMModernSkinMessageWindow",

	-- layout data
	NineSliceLayouts["PortraitFrameTemplate"] or
	NineSliceLayouts["ButtonFrameTemplate"] or
	-- fallback layout if the others are not available ie: Era
	getNineSliceLayout(true)
);

NineSliceUtil.AddLayout(
	-- layout name
	"WIMModernSkinStandardFrame",

	-- layout data
	NineSliceLayouts["PortraitFrameTemplate"] and
		NineSliceLayouts["ButtonFrameTemplateNoPortrait"] or
		getNineSliceLayout()
);

local WIM_ModernSkin = {
	title = "WIM Modern",
    version = "1.0.0",
	schema_version = 2,
    author = "Avraelore (Moon Guard)",
    website = "https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger",
    message_window = {
        texture = path.."message_window.png",
        -- The themed construction needs this much height for the header
        -- band, some message well, and the input row. Below it, the
        -- in-well scrollbar and the side column overflow the frame.
        min_height = 225,
        -- The texture is a 64px nine-slice on the classic .25 coordinate
        -- grid; only the rendered corner size changes.
        backdrop = {
            top_left = { width = 16, height = 16 },
            top_right = { width = 16, height = 16 },
            bottom_left = { width = 16, height = 16 },
            bottom_right = { width = 16, height = 16 }
        },
		chrome = {
			layout = "WIMModernSkinMessageWindow"
		},
        widgets = {
			from = {
				points = {
                    {"LEFT", "window", "TOPLEFT", 56, -11.5},
                    {"RIGHT", "window", "TOPRIGHT", -27, -11.5}
                },
				font = "GameFontNormal",
				font_height = 14,
				-- the following properties are only applied if more than one points define a binding box.
				-- otherwise the string just runs on in a straight line.
				align = "CENTER", -- horizontal alignment
				justify = "MIDDLE", -- vertical alignment
				wrap = false, -- disable word wrap
				fit = true, -- enable automatic fitting of the text to the available space
			},
			char_info = {
				points = {
                    {"TOPLEFT", "window", "TOPLEFT", 56, -24},
                    {"BOTTOMRIGHT", "window", "TOPRIGHT", -27, -54}
                },
				-- the following properties are only applied if more than one points define a binding box.
				-- otherwise the string just runs on in a straight line.
				align = "CENTER", -- horizontal alignment
				justify = "MIDDLE", -- vertical alignment
				non_space_wrap = true, -- enable non-space wrapped
				wrap = true, -- enable word wrap,
				line_spacing = 3,
				fit = true, -- enable automatic fitting of the text to the available space
			},
			chat_display = {
                points = {
					{"TOP", "char_info", "BOTTOM", 0, -8},
                    {"LEFT", "window", "LEFT", 24, 0},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -38, 39}
                }
            },
			history = {
				points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -28, -2}
                }
			},
            -- The themed right-side column stacks down from its top;
            -- the classic layout stacks up from the window bottom.
            shortcuts = {
                stack = "DOWN",
				points = {
                    {"TOPLEFT", "chat_display", "TOPRIGHT", 28, 4},
                    {"BOTTOMRIGHT", "chat_display", "BOTTOMRIGHT", 28 + 22, 0}
                },
            },
			close = {
				state_hide = {
                    NormalTexture = "RedButton-Condense2x",
                    PushedTexture = "RedButton-Condense-Pressed2x",
                    HighlightTexture = "RedButton-Highlight2x",
                    HighlightAlphaMode = "ADD"
                },
                state_close = {
                    NormalTexture = "RedButton-Exit2x",
                    PushedTexture = "RedButton-Exit-Pressed2x",
                    HighlightTexture = "RedButton-Highlight2x",
                    HighlightAlphaMode = "ADD"
                },
				width = 23,
                height = 23 * (38/36),
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", 1, 0}
                }
			}
        }
    },
    tab_strip = {
        textures = {
            tab = {
                NormalTexture = path.."tab_normal.png",
                PushedTexture = path.."tab_selected.png",
                HighlightTexture = path.."tab_flash.png",
                HighlightAlphaMode = "ADD"
            }
        },
		points = {
            {"BOTTOMLEFT", "window", "TOPLEFT", 50, -2},
            {"BOTTOMRIGHT", "window", "TOPRIGHT", -20, -2}
        },
    },
};

WIM.RegisterSkin(WIM_ModernSkin);

-- Classic Era doesn't have the following Atlases defined,
-- so we are defining our own backups.
do
	local add = WIM.utils.skin.registerAtlasFallback;

	add("_UI-Frame-Metal-EdgeBottom", {
		path = path.."uiframemetalhorizontal2x.png",
		texture_coord = {0, .5, 0.59765625, 0.84765625},
		size = {16, 32},
		tilesHorizontally = true,
	});

	add("UI-Frame-Metal-CornerBottomLeft", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.298828125, 0.423828125, 0.298828125, 0.423828125},
		size = {32, 32},
	});

	add("UI-Frame-Metal-CornerBottomRight", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.427734375, 0.552734375, 0.298828125, 0.423828125},
		size = {32, 32},
	});

	add("!UI-Frame-Metal-EdgeLeft", {
		path = path.."uiframemetalvertical2x.png",
		texture_coord = {0.001953125, 0.294921875, 0, 1},
		size = {75, 16},
		tilesVertically = true,
	});

	add("!UI-Frame-Metal-EdgeRight", {
		path = path.."uiframemetalvertical2x.png",
		texture_coord = {0.298828125, 0.591796875, 0, 1},
		size = {75, 16},
		tilesVertically = true,
	});

	add("_UI-Frame-Metal-EdgeTop", {
		path = path.."uiframemetalhorizontal2x.png",
		texture_coord = {0, 1, 0.00390625, 0.58984375},
		size = {32, 75},
		tilesHorizontally = true,
	});

	add("UI-Frame-PortraitMetal-CornerTopLeft", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.001953125, 0.294921875, 0.298828125, 0.591796875},
		size = {75, 75},
	});

	add("UI-Frame-PortraitMetal-CornerTopLeftSmall", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.001953125, 0.294921875, 0.595703125, 0.888671875},
		size = {75, 75},
	});

	add("UI-Frame-Metal-CornerTopLeft", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.001953125, 0.294921875, 0.001953125, 0.294921875},
		size = {75, 75},
	});

	add("UI-Frame-Metal-CornerTopRight", {
		path = path.."uiframemetal2x.png",
		texture_coord = {0.298828125, 0.591796875, 0.001953125, 0.294921875},
		size = {75, 75},
	});

	-- high rez buttons - era clients are using too low of a resolution.
	add("RedButton-Exit2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.15234375, 0.29296875, 0.0078125, 0.3046875},
		size = {36, 38},
	});

	add("RedButton-Exit-Disabled2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.15234375, 0.29296875, 0.0078125, 0.6171875},
		size = {36, 38},
	});

	add("RedButton-Exit-Pressed2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.15234375, 0.29296875, 0.6328125, 0.9296875},
		size = {36, 38},
	});

	add("RedButton-Condense2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.00390625, 0.14453125, 0.0078125, 0.3046875},
		size = {36, 38},
	});

	add("RedButton-Condense-Disabled2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.00390625, 0.14453125, 0.3203125, 0.6171875},
		size = {36, 38},
	});

	add("RedButton-Condense-Pressed2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.00390625, 0.14453125, 0.6328125, 0.9296875},
		size = {36, 38},
	});

	add("RedButton-Highlight2x", {
		path = path.."redbutton2x.png",
		texture_coord = {0.44921875, 0.58984375, 0.0078125, 0.3046875},
		size = {36, 38},
	});

end
