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
        min_height = 150,
        -- The texture is a 64px nine-slice on the classic .25 coordinate
        -- grid; only the rendered corner size changes.
        backdrop = {
            top_left = { width = 16, height = 16 },
            top_right = { width = 16, height = 16 },
            bottom_left = { width = 16, height = 16 },
            bottom_right = { width = 16, height = 16 }
        },
        widgets = {
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
