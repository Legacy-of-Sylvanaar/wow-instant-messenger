-- Custom Skin handlers (In this situation, this must be declared before the skin table. If loaded after, it would not have a chance to load and an error would be thrown.)
local function formatDetails(window, guild, level, race, class)
    if(guild ~= "") then
	guild = "<"..guild.."> ";
    end

	local details = {};
	if (guild ~= "") then table.insert(details, guild); end
	if (level ~= "") then table.insert(details, level); end
	if (race ~= "") then table.insert(details, race); end
	if (class ~= "") then table.insert(details, class); end

    return "|cffffffff"..table.concat(details, ' ').."|r";
end

-- Standard gold UI label color, for the panel title and section headers.
local goldR, goldG, goldB = GameFontNormal:GetTextColor();

--Default window skin
local WIM_ClassicSkin = {
	title = "WIM Classic",
    version = "1.0.0",
	schema_version = 1,
    author = "Pazza <Bronzebeard>",
    website = "http://www.wimaddon.com",
    message_window = {
        texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\message_window",
        min_width = 256,
        min_height = 80,
        backdrop = {
            top_left = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {0, 0, 0, .25, .25, 0, .25, .25}
            },
            top_right = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {.75, 0, .75, .25, 1, 0, 1, .25}
            },
            bottom_left = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {0, .75, 0, 1, .25, .75, .25, 1}
            },
            bottom_right = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {.75, .75, .75, 1, 1, .75, 1, 1}
            },
            top = {
                tile = false,
                texture_coord = {.25, 0, .25, .25, .75, 0, .75, .25}
            },
            bottom = {
                tile = false,
                texture_coord = {.25, .75, .25, 1, .75, .75, .75, 1}
            },
            left = {
                tile = false,
                texture_coord = {0, .25, 0, .75, .25, .25, .25, .75}
            },
            right = {
                tile = false,
                texture_coord = {.75, .25, .75, .75, 1, .25, 1, .75}
            },
            background = {
                tile = false,
                texture_coord = {.25, .25, .25, .75, .75, .25, .75, .75}
            }
        },
        widgets = {
            class_icon = {
                texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\class_icons",
                chatAlphaMask = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\chatAlphaMask",
                width = 64,
                height = 64,
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", -10, 12}
                },
                is_round = true,
                blank = {.5, .5, .5, .75, .75, .5, .75, .75},
                druid = {0, 0, 0, .25, .25, 0, .25, .25},
                hunter = {.25, 0, .25, .25, .5, 0, .5, .25},
                mage = {.5, 0, .5, .25, .75, 0, .75, .25},
                paladin = {.75, 0, .75, .25, 1, 0, 1, .25},
                priest = {0, .25, 0, .5, .25, .25, .25, .5},
                rogue = {.25, .25, .25, .5, .5, .25, .5, .5},
                shaman = {.5, .25, .5, .5, .75, .25, .75, .5},
                warlock = {.75, .25, .75, .5, 1, .25, 1, .5},
                warrior = {0, .5, 0, .75, .25, .5, .25, .75},
                deathknight = {.75, .5, .75, .75, 1, .5, 1, .75},
                monk = {0, .75, 0, 1, .25, .75, .25, 1},
                gm = {.25, .5, .25, .75, .5, .5, .5, .75},
                demonhunter = {.75, .75, .75, 1, 1, .75, 1, 1},
				evoker = {.5, .75, .5, 1, .75, .75, .75, 1},
            },
            client_icon = {
                texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\client_icons",
                chatAlphaMask = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\chatAlphaMask",
                width = 64,
                height = 64,
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", -10, 12}
                },
                is_round = true,
                hots = {.5, .5, .5, .75, .75, .5, .75, .75},
                vipr = {.75, .25, .75, .5, 1, .25, 1, .5},
                dsty2 = {0, .5, 0, .75, .25, .5, .25, .75},
                ow = {.75, .5, .75, .75, 1, .5, 1, .75},
                hs = {0, .75, 0, 1, .25, .75, .25, 1},
                sc1 = {.25, .5, .25, .75, .5, .5, .5, .75},
                sc2 = {.75, .75, .75, 1, 1, .75, 1, 1},
                d3 = {.5, .75, .5, 1, .75, .75, .75, 1},
                bnd = {.25, .75, .25, 1, .5, .75, .5, 1}
            },
            from = {
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 50, -8}
                },
                font = "FriendsFont_Normal", --GameFontNormalLarge
                font_color = "ffffff",
                font_height = 16,
                font_flags = "",
                use_class_color = true
            },
            char_info = {
                format = formatDetails,
                points = {
                    {"TOP", "window", "TOP", 0, -30}
                },
                font = "GameFontNormal",
                font_color = "ffffff"
            },
            close = {
                state_hide = {
                    NormalTexture = "Interface\\Minimap\\UI-Minimap-MinimizeButtonDown-Up",
                    PushedTexture = "Interface\\Minimap\\UI-Minimap-MinimizeButtonDown-Down",
                    HighlightTexture = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight",
                    HighlightAlphaMode = "ADD"
                },
                state_close = {
                    NormalTexture = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up",
                    PushedTexture = "Interface\\Buttons\\UI-Panel-MinimizeButton-Down",
                    HighlightTexture = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight",
                    HighlightAlphaMode = "ADD"
                },
                width = 32,
                height = 32,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", 4, 1}
                }
            },
            history = {
                NormalTexture = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up",
                PushedTexture = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up",
                HighlightTexture = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up",
                HighlightAlphaMode = "ADD",
                width = 18,
                height = 18,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -28, -6}
                }
            },
            w2w = {
                NormalTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\w2w",
                PushedTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\w2w",
                HighlightTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\w2w",
                HighlightAlphaMode = "ADD",
                points = {
                    {"TOPLEFT", "class_icon", 14, -14},
                    {"BOTTOMRIGHT", "class_icon", -14, 14}
                }
            },
            chat_info = {
                NormalTexture = nil, -- by default we don't want a texture, but your skin is welcome to have one.
                PushedTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\w2w",
                HighlightTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\w2w",
                HighlightAlphaMode = "ADD",
                points = {
                    {"TOPLEFT", "class_icon", 14, -14},
                    {"BOTTOMRIGHT", "class_icon", -14, 14}
                }
            },
            chatting = {
                NormalTexture = "Interface\\GossipFrame\\PetitionGossipIcon",
                PushedTexture = "Interface\\GossipFrame\\PetitionGossipIcon",
                width = 16,
                height = 16,
                points = {
                    {"TOPLEFT", "window", 45, -28}
                }
            },
            scroll_up = {
                NormalTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
                PushedTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down",
                HighlightTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight",
                DisabledTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled",
                HighlightAlphaMode = "ADD",
                width = 32,
                height = 32,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -4, -39}
                }
            },
            scroll_down = {
                NormalTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
                PushedTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down",
                HighlightTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight",
                DisabledTexture = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled",
                HighlightAlphaMode = "ADD",
                width = 32,
                height = 32,
                points = {
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -4, 24}
                }
            },
            chat_display = {
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 24, -50},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -38, 39}
                },
                font = "ChatFontNormal"
            },
            msg_box = {
                font = "ChatFontNormal",
                font_height = 14,
                font_color = {1,1,1},
                points = {
                    {"TOPLEFT", "window", "BOTTOMLEFT", 24, 30},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -10, 4}
                },
            },
            resize = {
                NormalTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\resize",
                width = 25,
                height = 25,
                points = {
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", 5, -5}
                }
            },
            shortcuts = {
                stack = "DOWN",
                spacing = 2,
                points = {
                    {"TOPLEFT", "window", "TOPRIGHT", -30, -70},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -8, 55}
                },
                buttons = {
                    NormalTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\shortcuts_frame",
                    PushedTexture = "Interface\\Buttons\\UI-Quickslot-Depress",
                    HighlightTexture = "Interface\\Buttons\\ButtonHilight-Square",
                    HighlightAlphaMode = "ADD",
                    icons = {
                        location = "Interface\\Icons\\Ability_TownWatch",
                        invite = "Interface\\Icons\\INV_Misc_GroupNeedMore",
                        guild = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
                        friend = "Interface\\Icons\\ACHIEVEMENT_REPUTATION_01",
                        ignore = "Interface\\Icons\\Spell_Holy_Silence",
                        rpprofile = "Interface\\Icons\\INV_Misc_Book_09",
                    }
                }
            }
        },
    },
    tab_strip = {
        textures = {
            tab = {
                NormalTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\tab_normal",
                PushedTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\tab_selected",
                HighlightTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\tab_flash",
                --HighlightTexture = "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight",
                HighlightAlphaMode = "ADD"
            },
            prev = {
                NormalTexture = "Interface\\MoneyFrame\\Arrow-Left-Up",
                PushedTexture = "Interface\\MoneyFrame\\Arrow-Left-Down",
                DisabledTexture = "Interface\\MoneyFrame\\Arrow-Left-Disabled",
                HighlightTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\tab_left_arrow",
                HighlightAlphaMode = "ADD",
                height = 20,
                width = 20,
            },
            next = {
                NormalTexture = "Interface\\MoneyFrame\\Arrow-Right-Up",
                PushedTexture = "Interface\\MoneyFrame\\Arrow-Right-Down",
                DisabledTexture = "Interface\\MoneyFrame\\Arrow-Right-Disabled",
                HighlightTexture = "Interface\\AddOns\\"..WIM.addonTocName.."\\Skins\\Default\\tab_right_arrow",
                HighlightAlphaMode = "ADD",
                height = 20,
                width = 20,
            },
        },
        height = 26,
        points = {
            {"BOTTOMLEFT", "window", "TOPLEFT", 38, -4},
            {"BOTTOMRIGHT", "window", "TOPRIGHT", -20, -4}
        },
        -- Tab labels track the font object exactly (size and flags
        -- included), matching the FontString template they are created
        -- from; skins may override any of the font properties here.
        text = {
            font = "ChatFontNormal",
        },
        vertical = false,
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
            font = "ChatFontNormal",
			font_color = {1, 1, 1},
			font_height = 11,
			font_flags = ""
        },
		button = {
			font = "FriendsFont_Normal",
			font_height = 12,
			font_flags = ""
		},
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
			font_flags = "",
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
		-- Filters header and search label.
		header = {
			font = "GameFontHighlightMedium",
            font_color = {1, 1, 1},
            atlas = "Options_CategoryHeader_1"
		},
		-- Thin separator lines between the panes.
		divider_color = {0, 0, 0, 0},
		-- Wider bands: filters header strip, search bar, view tabs.
        strip_color = {0, 0, 0, .35},
		-- Conversation and date list rows.
		row = {
			font = "ChatFontNormal",
			font_color = {goldR, goldG, goldB},
            highlight = {
                atlas = "Options_List_Hover"
            },
            selected = {
                atlas = "Options_List_Active",
                font_color = {1, 1, 1}
            }
		},
		-- Message display area, text export box and search input.
		content = {
			font = "ChatFontNormal"
		},
		tab = {
			font = "ChatFontSmall"
		}
	},
    emoticons = {
        width = 0,
        height = 0,
        offset = {0, 0},
        definitions = {
            [":)"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\smile.blp",
            [":-)"] = ":)",
            [":("] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\sad.blp",
            [":-("] = ":(",
            ["{beer}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\beer.blp",
            ["{drink}"] = "{beer}",
            [":D"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\biggrin.blp",
            [":-D"] = ":D",
            ["=D"] = ":D",
            ["=-D"] = ":D",
            [":]"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\blush.blp",
            [":-]"] = ":]",
            ["(u)"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\brokenheart.blp",
            ["</3"] = "(u)",
            ["{broken}"] = "(u)",
            ["{brokenheart}"] = "{broken}",
            ["':."] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\brow.blp",
            ["{brow}"] = "':.",
            ["':-."] = "':.",
            ["{coffee}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\coffee.blp",
            ["8)"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\cool.blp",
            ["8-)"] = "8)",
            [":'("] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\cry.blp",
            [":'-("] = ":'(",
            ["{ouch}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\doh.blp",
            [">:."] = "{ouch}",
            [">:-."] = "{ouch}",
            ["{dull}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\dull.blp",
            [":p"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\dumb.blp",
            [":P"] = ":p",
            [":-p"] = ":p",
            [":P"] = ":p",
            [":-P"] = ":p",
            [";p"] = ":p",
            [";P"] = ":p",
            [";-p"] = ":p",
            [";-P"] = ":p",
            ["O.o"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\speechless.blp",
            ["0.o"] = "O.o",
            ["o.O"] = "O.o",
            ["o.0"] = "O.o",
            [">:("] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\envy.blp",
            [">:-("] = ">:(",
            ["{flip}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\finger.blp",
            ["{finger}"] = "{flip}",
            ["nlm"] = "{flip}",
            ["{rose}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\flower.blp",
            ["{flower}"] = "{rose}",
            ["<-@"] = "{rose}",
            ["8|"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\glass.blp",
            ["8-|"] = "8|",
            ["{hi}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\hihi.blp",
            [":*"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\kiss.blp",
            [":-*"] = ":*",
            ["{kiss}"] = ":*",
            ["{martini}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\martini.blp",
            ["{mmm}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\mmm.blp",
            ["{butt}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\mooning.blp",
            ["{no}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\no.blp",
            ["O.O"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\ohh.blp",
            ["0.0"] = "O.O",
            ["=-o"] = "O.O",
            [":("] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\sad.blp",
            [":-("] = ":(",
            [":$"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\sealed.blp",
            [":-$"] = ":$",
            ["{smoke}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\smoke.blp",
            ["o_o"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\speechless.blp",
            ["0_o"] = "o_o",
            ["O_o"] = "o_o",
            ["O_O"] = "o_o",
            ["0_0"] = "o_o",
            ["{tired}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\tired.blp",
            ["{wasntme}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\wasntme.blp",
            ["{yes}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\yes.blp",
            ["{rock}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\rock.blp",
            ["lml"] = "{rock}",
            ["{drunk}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\drunk.blp",
            ["{ninja}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\ninja.blp",
            ["{angry}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\angry.blp",
            [">:o"] = "{angry}",
            [">:-o"] = "{angry}",
            [">:O"] = "{angry}",
            [">:-O"] = "{angry}",
            ["{heart}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\heart.blp",
            ["<3"] = "{heart}",
            ["{wink}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\wink.blp",
            [";)"] = "{wink}",
            [";-)"] = "{wink}",
            ["{eat}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\eat.blp",
            ["{pizza}"] = "{eat}",
            ["{drunk}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\drunk.blp",
            ["{devil}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\devil.blp",
            ["{callme}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\callme.blp",
            ["{boom}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\boom.blp",
            ["{explode}"] = "{boom}",
            ["{money}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\money.blp",
            ["$"] = "{money}",
            ["{evil}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\evil.blp",
            ["{flex}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\flex.blp",
            ["{strong}"] = "{flex}",
            ["{phone}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\phone.blp",
            ["{cell}"] = "{phone}",
            ["{puke}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\puke.blp",
            ["{barf}"] = "{puke}",
            ["{wait}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\wait.blp",
            ["{rain}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\rain.blp",
            ["{badday}"] = "{rain}",
            ["{zipper}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\zipper.blp",
            ["{zipped}"] = "{zipper}",
            ["{zip}"] = "{zipper}",
            ["{hi}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\hi.blp",
            ["{tired}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\tired.blp",
            ["{nervous}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\nervous.blp",
            ["{scared}"] = "{nervous}",
            ["{smoke}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\smoke.blp",
            ["{cig}"] = "{smoke}",
            ["{angel}"] = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\Emoticons\\angel.blp",
            ["O:)"] = "{angel}",
        }
    }
};

local WIM_ClassicSkin_Blue = {
    title = "WIM Classic - " .. WIM.L["Blue"],
    author = WIM_ClassicSkin.author,
    version = WIM_ClassicSkin.version,
    message_window = {
        texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\message_window_blue"
    }
};

local WIM_ClassicSkin_Green = {
    title = "WIM Classic - " .. WIM.L["Green"],
    author = WIM_ClassicSkin.author,
    version = WIM_ClassicSkin.version,
    message_window = {
        texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\message_window_green"
    }
};

local WIM_ClassicSkin_Red = {
    title = "WIM Classic - " .. WIM.L["Red"],
    author = WIM_ClassicSkin.author,
    version = WIM_ClassicSkin.version,
    message_window = {
        texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\message_window_red"
    }
};

local WIM_ClassicSkin_Yellow = {
    title = "WIM Classic - " .. WIM.L["Yellow"],
    author = WIM_ClassicSkin.author,
    version = WIM_ClassicSkin.version,
    message_window = {
        texture = "Interface\\AddOns\\"..WIM.addonTocName.."\\skins\\default\\message_window_yellow"
    }
};


----------------------------------------------------------
--                  Register Skin                       --
----------------------------------------------------------

WIM.RegisterSkin(WIM_ClassicSkin);
WIM.RegisterSkin(WIM_ClassicSkin_Blue);
WIM.RegisterSkin(WIM_ClassicSkin_Green);
WIM.RegisterSkin(WIM_ClassicSkin_Red);
WIM.RegisterSkin(WIM_ClassicSkin_Yellow);
