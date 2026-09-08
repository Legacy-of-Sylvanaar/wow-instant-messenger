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
    author = "Avraelore (Moon Guard)",
    website = "https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger",
    -- Offered only where the caller asks for modern-only skins (the
    -- modern options UI). See GetRegisteredSkins.
    modernOnly = true,
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
            -- The themed right-side column stacks down from its top;
            -- the classic layout stacks up from the window bottom.
            shortcuts = {
                stack = "DOWN"
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
        }
    },
    -- The menus use the game's own context-menu panel: the chamfered
    -- frame that current right-click menus draw. `style` routes WIM's
    -- context menus through the Menu API. `background_atlas` gives the
    -- whispers/chats menu the same art. The toast pair below is the
    -- fallback for clients without either.
    menu = {
        style = "context",
        background_atlas = "common-dropdown-bg",
        edge = "Interface\\FriendsFrame\\UI-Toast-Border",
        edge_size = 12,
        background = "Interface\\FriendsFrame\\UI-Toast-Background",
        tile = false,
        tile_size = 0,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
        -- Section headers use the native menus' gold, like the unit
        -- menu's "Loot Options" header.
        title = {
            font = "GameFontNormal",
            font_color = {goldR, goldG, goldB},
            font_height = 13,
            font_flags = ""
        }
    },
    history_viewer = {
        -- The full standard-panel construction: metal nine-slice frame,
        -- rock background, recessed inset wells, as used by frames like
        -- Guild & Communities. The backdrop below is only the fallback
        -- for clients without the nine-slice layouts.
        frame_style = "panel",
        backdrop = {
            bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
            edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
            tile = false, tileSize = 0, edgeSize = 12,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        },
        title = {
            -- Native panels title their band in the standard 12px gold.
            -- The height must be set here, or the classic skin's 16
            -- inherits through.
            font = "GameFontNormal",
            font_height = 12,
            font_color = {goldR, goldG, goldB},
            -- The text's CENTER pins to the band's center (the band
            -- spans the window's top 20.5px), moved 1.5px down. The
            -- string rectangle includes descender space, so
            -- rect-centered text sits high; this centers the capital
            -- height instead (measured against a screenshot's pixel
            -- rows).
            points = {
                {"CENTER", "window", "TOP", 0, -11.5}
            }
        },
        -- Native widget styles: the standard red corner X (the
        -- RedButton atlas family current panels use), the Settings
        -- panel's minimal scrollbars, and the stock search box. Bare
        -- names are atlases.
        close = {
            NormalTexture = "RedButton-Exit",
            PushedTexture = "RedButton-exit-pressed",
            HighlightTexture = "RedButton-Highlight",
            HighlightAlphaMode = "ADD",
            -- The Settings panel renders this same button at 24x24 on
            -- its frame corner at TOPRIGHT (1, 0), filling the title
            -- band.
            width = 24, height = 24,
            points = {
                {"TOPRIGHT", "window", "TOPRIGHT", 1, 0}
            }
        },
        scrollbar_style = "minimal",
        search_style = "native",
        dropdown_style = "modern",
        -- The loading indicator as the game's standard casting bar.
        loader_style = "native",
        -- The Settings panel's arrangement: view tabs at the top left,
        -- the search box at the top right of the band under the title
        -- bar, panes flush at top and bottom, resize grip in the frame
        -- corner.
        layout = "flush",
        -- View tabs in the Settings panel's own tab plates.
        tab_style = "native",
        -- The filters strip as a Settings-style section header: the
        -- category header fade behind a white medium-size label.
        header = {
            font = "GameFontHighlightMedium",
            font_color = {1, 1, 1},
            atlas = "Options_CategoryHeader_1"
        },
        divider_color = {0, 0, 0, 0},
        strip_color = {0, 0, 0, .35},
        -- Rows drawn the way the Settings category list draws them:
        -- gold text at rest, a grey fading wash on hover, and the gold
        -- wash with white text when selected.
        row = {
            font_color = {goldR, goldG, goldB},
            highlight = {
                atlas = "Options_List_Hover"
            },
            selected = {
                atlas = "Options_List_Active",
                font_color = {1, 1, 1}
            }
        }
    }
};

WIM.RegisterSkin(WIM_ModernSkin);
