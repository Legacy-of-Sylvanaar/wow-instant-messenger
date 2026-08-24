local WIM = WIM;

-- imports
local _G = _G;
local table = table;
local pairs = pairs;
local ipairs = ipairs;
local tostring = tostring;
local string = string;
local math = math;
local debugstack = debugstack;
local type = type;
local unpack = unpack;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local rawget = rawget;
local CreateFrame = CreateFrame;
local pcall = pcall;

-- Defined before the setfenv. C_Texture.GetAtlasInfo looks up
-- Vector2DMixin in the calling function's environment, so namespaced
-- code must not call it directly.
local function getAtlasInfo(name)
    if (C_Texture and C_Texture.GetAtlasInfo) then
        return C_Texture.GetAtlasInfo(name);
    end
end

-- set namespace
setfenv(1, WIM);

db_defaults.skin = {
    selected = "WIM Classic",
    font = "ChatFontNormal",
    font_outline = "",
    suggest = true,
};

-- Modern skin settings: backgrounds and cut-out behavior for the
-- surfaces that modern-only skins draw with the game's own panel art
-- (the History Viewer frame and the message windows).
db_defaults.modernTheme = {
    frame = "rock",
    panels = "darkmarble",
    content = "darkmarble",
    cutout = false,
    chatFrame = "rock",
    chatPanel = "darkmarble",
    chatCutout = false,
    filterFrame = "rock",
    filterPanel = "darkmarble",
    filterCutout = false,
    -- The typed message can wrap onto multiple lines. The row grows
    -- with the message. A line limit is optional.
    inputWrap = false,
    inputWrapLimit = false,
    inputWrapLines = 2,
    -- Roleplay profile integration. rpEnabled is the master switch and
    -- also controls the Open Profile shortcut. rpFields selects which
    -- profile fields replace the default display on whisper windows.
    -- When rpFields is empty, the default display stays unchanged.
    rpEnabled = false,
    rpFields = {},
};

-- The panel art the modern skin background pickers offer: the game's
-- own backgrounds, plus flat translucent fills.
local CHROME_BACKGROUNDS = {
    { key = "none", label = "None (fully clear)", color = {0, 0, 0, 0} },
    { key = "transparent", label = "Transparent", color = {0, 0, 0, .55} },
    { key = "rock", label = "Rock",
      file = "Interface\\FrameGeneral\\UI-Background-Rock", tile = true },
    { key = "marble", label = "Marble",
      file = "Interface\\FrameGeneral\\UI-Background-Marble", tile = true },
    { key = "darkmarble", label = "Dark Marble",
      file = "Interface\\FrameGeneral\\UI-Background-Marble", tile = true, tint = .45 },
    { key = "dialog", label = "Dialog",
      file = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true },
    { key = "bank", label = "Bank",
      file = "Interface\\BankFrame\\Bank-Background", tile = true },
    { key = "vault", label = "Guild Vault",
      file = "Interface\\GuildBankFrame\\GuildVaultBG", tile = true },
    { key = "sandstone", label = "Dark Sandstone",
      file = "Interface\\HELPFRAME\\DarkSandstone-Tile", tile = true },
    { key = "parchmenttile", label = "Parchment (Tileable)",
      file = "Interface\\HELPFRAME\\Tileable-Parchment", tile = true },
    { key = "question", label = "Quest Parchment",
      file = "Interface\\QuestionFrame\\question-background", tile = true },
    { key = "raidgroup", label = "Raid Frame",
      file = "Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg", tile = false },
    { key = "endscreen", label = "Destiny",
      file = "Interface\\Destiny\\EndscreenBG", tile = false },
    { key = "stationeryauction", label = "Stationery (Auction)",
      file = "Interface\\Stationery\\AuctionStationery1", tile = false },
    { key = "stationeryill", label = "Stationery (Illustrated)",
      file = "Interface\\Stationery\\Stationery_ill1", tile = false },
    { key = "stationeryog", label = "Stationery (Orgrimmar)",
      file = "Interface\\Stationery\\Stationery_OG1", tile = false },
    { key = "stationerytb", label = "Stationery (Thunder Bluff)",
      file = "Interface\\Stationery\\Stationery_TB1", tile = false },
    { key = "stationeryuc", label = "Stationery (Undercity)",
      file = "Interface\\Stationery\\Stationery_UC1", tile = false },
    { key = "stationeryplain", label = "Stationery (Plain)",
      file = "Interface\\Stationery\\StationeryTest1", tile = false },
    { key = "worldmap1", label = "World Map 1",
      file = "Interface\\WorldMap\\UI-WorldMap-Middle1", tile = false },
    { key = "worldmap2", label = "World Map 2",
      file = "Interface\\WorldMap\\UI-WorldMap-Middle2", tile = false },
    { key = "achievement", label = "Achievement Stats",
      file = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-StatsBackground", tile = false },
    { key = "adventuremap", label = "Adventure Map Parchment",
      file = "Interface\\AdventureMap\\AdventureMapParchmentTile", tile = true },
    { key = "collections", label = "Collections",
      file = "Interface\\Collections\\CollectionsBackgroundTile", tile = true },
    { key = "framealliance", label = "Frame: Alliance",
      file = "Interface\\FrameGeneral\\UIFrameAllianceBackground", tile = true },
    { key = "framehorde", label = "Frame: Horde",
      file = "Interface\\FrameGeneral\\UIFrameHordeBackground", tile = true },
    { key = "frameneutral", label = "Frame: Neutral",
      file = "Interface\\FrameGeneral\\UIFrameNeutralBackground", tile = true },
    { key = "framemarine", label = "Frame: Marine",
      file = "Interface\\FrameGeneral\\UIFrameMarineBackground", tile = true },
    { key = "framemechagon", label = "Frame: Mechagon",
      file = "Interface\\FrameGeneral\\UIFrameMechagonBackground", tile = true },
    { key = "framekyrian", label = "Frame: Kyrian",
      file = "Interface\\FrameGeneral\\UIFrameKyrianBackground", tile = true },
    { key = "framenecrolord", label = "Frame: Necrolord",
      file = "Interface\\FrameGeneral\\UIFrameNecrolordBackground", tile = true },
    { key = "framenightfae", label = "Frame: Night Fae",
      file = "Interface\\FrameGeneral\\UIFrameNightFaeBackground", tile = true },
    { key = "frameventhyr", label = "Frame: Venthyr",
      file = "Interface\\FrameGeneral\\UIFrameVenthyrBackground", tile = true },
    { key = "frameoribos", label = "Frame: Oribos",
      file = "Interface\\FrameGeneral\\UIFrameOribosBackground", tile = true },
    { key = "framedragonflight", label = "Frame: Dragonflight",
      file = "Interface\\FrameGeneral\\UIFrameDragonflightBackground", tile = true },
    { key = "framewarwithin", label = "Frame: The War Within",
      file = "Interface\\FrameGeneral\\UIFrameTheWarWithinBackground", tile = true },
    { key = "classhall", label = "Class Hall",
      file = "Interface\\Garrison\\ClassHallBackground", tile = true },
    { key = "classhallinternal", label = "Class Hall (Internal)",
      file = "Interface\\Garrison\\ClassHallInternalBackground", tile = true },
    { key = "garrisonlanding", label = "Garrison Landing Page",
      file = "Interface\\Garrison\\GarrisonLandingPageMiddleTile", tile = true },
    { key = "garrisonmission", label = "Garrison Mission",
      file = "Interface\\Garrison\\GarrisonMissionUIInfoBoxBackgroundTile", tile = true },
    { key = "garrisonship", label = "Ship Mission Parchment",
      file = "Interface\\Garrison\\GarrisonShipMissionParchment", tile = true },
    { key = "garrisonui", label = "Garrison UI",
      file = "Interface\\Garrison\\GarrisonUIBackground", tile = true },
    { key = "garrisonui2", label = "Garrison UI 2",
      file = "Interface\\Garrison\\GarrisonUIBackground2", tile = true },
    { key = "creditsclassic", label = "Credits: Classic",
      file = "Interface\\Credits\\CreditsScreenBackground0WoW", tile = true },
    { key = "creditsbc", label = "Credits: Burning Crusade",
      file = "Interface\\Credits\\CreditsScreenBackground1BC", tile = true },
    { key = "creditswotlk", label = "Credits: Wrath",
      file = "Interface\\Credits\\CreditsScreenBackground2WotLK", tile = true },
    { key = "creditscata", label = "Credits: Cataclysm",
      file = "Interface\\Credits\\CreditsScreenBackground3Cataclysm", tile = true },
    { key = "creditsmop", label = "Credits: Mists of Pandaria",
      file = "Interface\\Credits\\CreditsScreenBackground4MoP", tile = true },
    { key = "creditswod", label = "Credits: Warlords",
      file = "Interface\\Credits\\CreditsScreenBackground5WoD", tile = true },
    { key = "creditslegion", label = "Credits: Legion",
      file = "Interface\\Credits\\CreditsScreenBackground6Legion", tile = true },
    { key = "creditsbfa", label = "Credits: Battle for Azeroth",
      file = "Interface\\Credits\\CreditsScreenBackground7BfA", tile = true },
};

-- A choice is offered only when its texture exists on this client.
-- Classic flavors lack much of the retail panel art, and a picker
-- entry whose file is missing draws nothing. Flat fills always exist.
-- Checked once per entry; without GetFileIDFromPath everything is
-- offered, which is the old behavior.
local function chromeBackgroundAvailable(entry)
    if(entry.color) then
        return true;
    end
    if(entry.wimAvailable == nil) then
        entry.wimAvailable = (not _G.GetFileIDFromPath)
            or (_G.GetFileIDFromPath(entry.file) ~= nil);
    end
    return entry.wimAvailable;
end

function GetChromeBackgrounds()
    local list = {};
    for i=1, #CHROME_BACKGROUNDS do
        if(chromeBackgroundAvailable(CHROME_BACKGROUNDS[i])) then
            table.insert(list, CHROME_BACKGROUNDS[i]);
        end
    end
    return list;
end

-- Paints one catalog choice onto a texture. Unknown keys and keys whose
-- art this client lacks fall back to Rock, then to the clear fill.
function ApplyChromeBackgroundChoice(texture, key)
    local entry, fallback;
    for i=1, #CHROME_BACKGROUNDS do
        if(CHROME_BACKGROUNDS[i].key == key) then
            entry = CHROME_BACKGROUNDS[i];
            break;
        end
        if(CHROME_BACKGROUNDS[i].key == "rock") then
            fallback = CHROME_BACKGROUNDS[i];
        end
    end
    if(entry and not chromeBackgroundAvailable(entry)) then
        entry = nil;
    end
    if(fallback and not chromeBackgroundAvailable(fallback)) then
        fallback = nil;
    end
    entry = entry or fallback or CHROME_BACKGROUNDS[1];
    if(entry.color) then
        texture:SetColorTexture(entry.color[1], entry.color[2],
            entry.color[3], entry.color[4]);
        return entry;
    end
    local tile = entry.tile and true or false;
    texture:SetTexture(entry.file, tile, tile);
    texture:SetHorizTile(tile);
    texture:SetVertTile(tile);
    texture:SetTexCoord(0, 1, 0, 1);
    local tint = entry.tint or 1;
    texture:SetVertexColor(tint, tint, tint, 1);
    return entry;
end

-- Paints a catalog choice across cut-out strips. Tiling materials keep
-- their own repeat, but a picture (a stretch entry) must read as ONE
-- image with the well cut out of it, so each strip is windowed to the
-- part of the picture that falls under it. The area texture's
-- rectangle defines the full picture; rects unresolved on the first
-- pass are picked up by the callers' size hooks.
function ApplyChromeBackgroundToStrips(strips, area, key)
    local entry;
    for i=1, #strips do
        entry = ApplyChromeBackgroundChoice(strips[i], key);
    end
    if(not entry or entry.color or entry.tile) then
        return;
    end
    local areaLeft, areaBottom, areaWidth, areaHeight = area:GetRect();
    if(not areaLeft or not areaWidth
            or areaWidth <= 0 or areaHeight <= 0) then
        return;
    end
    for i=1, #strips do
        local left, bottom, width, height = strips[i]:GetRect();
        if(left and width and width > 0 and height > 0) then
            strips[i]:SetTexCoord(
                (left - areaLeft) / areaWidth,
                (left + width - areaLeft) / areaWidth,
                1 - ((bottom + height - areaBottom) / areaHeight),
                1 - ((bottom - areaBottom) / areaHeight));
        end
    end
end

local SelectedSkin;

local SKIN_DEBUG = "";

local SkinTable = {};
local fontTable = {};

local prematureRegisters = {};

local WindowSoupBowl = WIM:GetWindowSoupBowl();

local function normalizeFont(font)
	if (type(font) == "table" and font.GetFont) then
		local fontPath, fontHeight, fontFlags = font:GetFont();
		return fontPath;

	elseif (type(font) == "string") then

		if (type(_G[font]) == "table") then
			return normalizeFont(_G[font]);
		end
		-- The string is not the name of a global font object. Keep it
		-- unchanged so SetWidgetFont's other branches can resolve
		-- LibSharedMedia names and font file paths.
		return font;
	end

	return font
end

local fontPaths = {
	"root.message_window.widgets.from.font",
	"root.message_window.widgets.char_info.font",
	"root.message_window.widgets.chat_display.font",
	"root.message_window.widgets.msg_box.font",
	"root.menu.title.font",
	"root.menu.button.font",
};

local function linkSkinTable(src, dest)
        if(type(src) == "table") then
                if(type(dest) ~= "table") then dest = {}; end
                --clear current meta table if there is one.
                setmetatable(dest, nil);
                for k, v in pairs(src) do
                        if(not (k == "points" and type(dest[k]) == "table") and type(v) == "table") then
                            linkSkinTable(v, dest[k]);
                        end
                end
                --setmetatable
                setmetatable(dest, {__index = src});
        end
end


local function setPointsToObj(obj, pointsTable)
    obj:ClearAllPoints();
    for i=1, #pointsTable do
        local point, relativeTo, relativePoint, offx, offy = unpack(pointsTable[i]);
        -- first we need to convert the string representation of objects into actual objects.
        if(relativeTo and type(relativeTo) == "string") then
            if(string.lower(relativeTo) == "window") then
                relativeTo = obj.parentWindow;
            else
                relativeTo = obj.parentWindow.widgets[relativeTo];
            end
            relativeTo = relativeTo or UIPanel;
        end
        -- set the actual points
        obj:SetPoint(point, relativeTo, relativePoint, offx, offy);
    end
end

-- load selected skin
function ApplySkinToWindow(obj)
    local fName = obj:GetName();

    local SelectedSkin = WIM:GetSelectedSkin();

	if obj.SetResizeBounds then -- WoW 10.0
		obj:SetResizeBounds(SelectedSkin.message_window.min_width, SelectedSkin.message_window.min_height);
	else
    	obj:SetMinResize(SelectedSkin.message_window.min_width, SelectedSkin.message_window.min_height);
    end

    --set backdrop edges and background textures.
    local tl = obj.widgets.Backdrop.tl;
    tl:SetTexture(SelectedSkin.message_window.texture);
    tl:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.top_left.texture_coord));
    tl:ClearAllPoints();
    tl:SetPoint("TOPLEFT", fName.."Backdrop", "TOPLEFT", unpack(SelectedSkin.message_window.backdrop.top_left.offset));
    tl:SetWidth(SelectedSkin.message_window.backdrop.top_left.width);
    tl:SetHeight(SelectedSkin.message_window.backdrop.top_left.height);
    local tr = obj.widgets.Backdrop.tr;
    tr:SetTexture(SelectedSkin.message_window.texture);
    tr:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.top_right.texture_coord));
    tr:ClearAllPoints();
    tr:SetPoint("TOPRIGHT", fName.."Backdrop", "TOPRIGHT", unpack(SelectedSkin.message_window.backdrop.top_right.offset));
    tr:SetWidth(SelectedSkin.message_window.backdrop.top_right.width);
    tr:SetHeight(SelectedSkin.message_window.backdrop.top_right.height);
    local bl = obj.widgets.Backdrop.bl;
    bl:SetTexture(SelectedSkin.message_window.texture);
    bl:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.bottom_left.texture_coord));
    bl:ClearAllPoints();
    bl:SetPoint("BOTTOMLEFT", fName.."Backdrop", "BOTTOMLEFT", unpack(SelectedSkin.message_window.backdrop.bottom_left.offset));
    bl:SetWidth(SelectedSkin.message_window.backdrop.bottom_left.width);
    bl:SetHeight(SelectedSkin.message_window.backdrop.bottom_left.height);
    local br = obj.widgets.Backdrop.br;
    br:SetTexture(SelectedSkin.message_window.texture);
    br:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.bottom_right.texture_coord));
    br:ClearAllPoints();
    br:SetPoint("BOTTOMRIGHT", fName.."Backdrop", "BOTTOMRIGHT", unpack(SelectedSkin.message_window.backdrop.bottom_right.offset));
    br:SetWidth(SelectedSkin.message_window.backdrop.bottom_right.width);
    br:SetHeight(SelectedSkin.message_window.backdrop.bottom_right.height);
    local t = obj.widgets.Backdrop.t;
    t:SetTexture(SelectedSkin.message_window.texture, SelectedSkin.message_window.backdrop.top.tile or nil);
    t:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.top.texture_coord));
    t:ClearAllPoints();
    t:SetPoint("TOPLEFT", fName.."Backdrop_TL", "TOPRIGHT", 0, 0);
    t:SetPoint("BOTTOMRIGHT", fName.."Backdrop_TR", "BOTTOMLEFT", 0, 0);
    local b = obj.widgets.Backdrop.b;
    b:SetTexture(SelectedSkin.message_window.texture, SelectedSkin.message_window.backdrop.bottom.tile or nil);
    b:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.bottom.texture_coord));
    b:ClearAllPoints();
    b:SetPoint("TOPLEFT", fName.."Backdrop_BL", "TOPRIGHT", 0, 0);
    b:SetPoint("BOTTOMRIGHT", fName.."Backdrop_BR", "BOTTOMLEFT", 0, 0);
    local l = obj.widgets.Backdrop.l;
    l:SetTexture(SelectedSkin.message_window.texture, SelectedSkin.message_window.backdrop.left.tile or nil);
    l:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.left.texture_coord));
    l:ClearAllPoints();
    l:SetPoint("TOPLEFT", fName.."Backdrop_TL", "BOTTOMLEFT", 0, 0);
    l:SetPoint("BOTTOMRIGHT", fName.."Backdrop_BL", "TOPRIGHT", 0, 0);
    local r = obj.widgets.Backdrop.r;
    r:SetTexture(SelectedSkin.message_window.texture, SelectedSkin.message_window.backdrop.right.tile or nil);
    r:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.right.texture_coord));
    r:ClearAllPoints();
    r:SetPoint("TOPLEFT", fName.."Backdrop_TR", "BOTTOMLEFT", 0, 0);
    r:SetPoint("BOTTOMRIGHT", fName.."Backdrop_BR", "TOPRIGHT", 0, 0);
    local bg = obj.widgets.Backdrop.bg;
    bg:SetTexture(SelectedSkin.message_window.texture, SelectedSkin.message_window.backdrop.background.tile or nil);
    bg:SetTexCoord(unpack(SelectedSkin.message_window.backdrop.background.texture_coord));
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT", fName.."Backdrop_TL", "BOTTOMRIGHT", 0, 0);
    bg:SetPoint("BOTTOMRIGHT", fName.."Backdrop_BR", "TOPLEFT", 0, 0);

    --set class icon
    local class_icon = obj.widgets.class_icon;
    ApplySkinToWidget(class_icon);
    class_icon:SetTexture(SelectedSkin.message_window.widgets.class_icon.texture);
    --WIM_UpdateMessageWindowClassIcon(obj);

    --set from font
    local from = obj.widgets.from;
    ApplySkinToWidget(from);

    --set character details font
    local char_info = obj.widgets.char_info;
    ApplySkinToWidget(char_info);

    --close button
    local close = obj.widgets.close;
    ApplySkinToWidget(close);
    -- close button is a special case... so do the following extra work.
    if(close.curTextureIndex == 1) then
        close:SetNormalTexture(SelectedSkin.message_window.widgets.close.state_hide.NormalTexture);
        close:SetPushedTexture(SelectedSkin.message_window.widgets.close.state_hide.PushedTexture);
        close:SetHighlightTexture(SelectedSkin.message_window.widgets.close.state_hide.HighlightTexture, SelectedSkin.message_window.widgets.close.state_hide.HighlightAlphaMode);
    else
        close:SetNormalTexture(SelectedSkin.message_window.widgets.close.state_close.NormalTexture);
        close:SetPushedTexture(SelectedSkin.message_window.widgets.close.state_close.PushedTexture);
        close:SetHighlightTexture(SelectedSkin.message_window.widgets.close.state_close.HighlightTexture, SelectedSkin.message_window.widgets.close.state_close.HighlightAlphaMode);
    end
    -- Setting a state texture file does not reset texture coordinates,
    -- and the themed corner button windows its states into padded art
    -- (ApplyRedButtonArt); without the reset the classic art draws
    -- cropped and off-center after a switch back.
    local closeStates = { close:GetNormalTexture(), close:GetPushedTexture(),
        close:GetHighlightTexture() };
    for i = 1, #closeStates do
        if(closeStates[i]) then
            closeStates[i]:SetTexCoord(0, 1, 0, 1);
        end
    end

    --scroll_up button
    local scroll_up = obj.widgets.scroll_up;
    ApplySkinToWidget(scroll_up);

    --scroll_down button
    local scroll_down = obj.widgets.scroll_down;
    ApplySkinToWidget(scroll_down);

    --chat display
    local chat_display = obj.widgets.chat_display;
	chat_display._font_flags = db.skin.font_outline;
    ApplySkinToWidget(chat_display);

    --msg_box
    local msg_box = obj.widgets.msg_box;
	msg_box._font_flags = db.skin.font_outline;
    ApplySkinToWidget(msg_box);

    --apply skin to registered widgets
    for widget, _ in pairs(windows.widgets) do
        if(obj.widgets[widget] and SelectedSkin.message_window.widgets[widget]) then
            dPrint("Applying skin to '"..widget.."'.");
            ApplySkinToWidget(obj.widgets[widget]);
        end
    end

    obj:UpdateProps();
    obj:UpdateIcon();
    obj:UpdateCharDetails();

    -- Runs last so nothing above it (UpdateIcon re-showing the class
    -- icon, property refreshes) undoes the theme's visibility choices.
    ApplyModernThemeToWindow(obj);
end

-- Whether this client has the portrait-capable panel layouts (the
-- modern metal frame with its opaque title band). Era clients answer
-- no: they ship only the older thin frame art, whose band region is
-- transparent. Probed once on a throwaway frame; both the message
-- windows and the History Viewer key their fallbacks off this.
local portraitPanelArt;
function HasPortraitPanelArt()
    if(portraitPanelArt == nil) then
        local apply = _G.NineSliceUtil and _G.NineSliceUtil.ApplyLayoutByName;
        if(not apply) then
            portraitPanelArt = false;
        else
            local probe = CreateFrame("Frame");
            probe:Hide();
            portraitPanelArt = pcall(apply, probe, "PortraitFrameTemplate")
                and true or false;
        end
    end
    return portraitPanelArt;
end

-- The Modern frame from the addon's own copies of the retail pieces,
-- for clients whose nine-slice layouts lack the art (see
-- HasPortraitPanelArt). Geometry comes from a retail widget dump and
-- the pieces anchor corner to corner, so the frame follows any window
-- size, exactly like the layout it stands in for. The edge files are
-- pre-tiled power-of-two sheets; the texcoord windows trim their
-- padding. Pieces draw at OVERLAY like the retail layout's, above the
-- fills and below the portrait's frame.
function BuildLiteMetalFrame(frame, portraitCorner)
    local path = "Interface\\AddOns\\"..addonTocName.."\\Skins\\Modern\\";
    local ART = 150 / 256;   -- art region inside the padded canvases
    local function piece(file, l, r, t, b)
        local tex = frame:CreateTexture(nil, "OVERLAY");
        tex:SetTexture(path..file..".png");
        tex:SetTexCoord(l, r, t, b);
        return tex;
    end
    -- The portrait corner's left pieces sit 5px further out than the
    -- plain corner's (-13 against -8), same as the retail layouts.
    local leftInset = portraitCorner and -13 or -8;
    local tl = piece(portraitCorner and "metal_corner_topleft_portrait"
        or "metal_corner_topleft", 0, ART, 0, ART);
    tl:SetSize(75, 75);
    tl:SetPoint("TOPLEFT", leftInset, 16);
    local tr = piece("metal_corner_topright", 0, ART, 0, ART);
    tr:SetSize(75, 75);
    tr:SetPoint("TOPRIGHT", 4, 16);
    local bl = piece("metal_corner_bottomleft", 0, 1, 0, 1);
    bl:SetSize(32, 32);
    bl:SetPoint("BOTTOMLEFT", leftInset, -3);
    local br = piece("metal_corner_bottomright", 0, 1, 0, 1);
    br:SetSize(32, 32);
    br:SetPoint("BOTTOMRIGHT", 4, -3);
    local top = piece("metal_edge_top", 0, 1, 0, ART);
    top:SetPoint("TOPLEFT", tl, "TOPRIGHT");
    top:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT");
    local bottom = piece("metal_edge_bottom", 0, 1, 0, 1);
    bottom:SetPoint("TOPLEFT", bl, "TOPRIGHT");
    bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT");
    local left = piece("metal_edge_left", 0, ART, 0, 1);
    left:SetPoint("TOPLEFT", tl, "BOTTOMLEFT");
    left:SetPoint("TOPRIGHT", tl, "BOTTOMRIGHT");
    left:SetPoint("BOTTOM", bl, "TOP");
    local right = piece("metal_edge_right", 0, ART, 0, 1);
    right:SetPoint("TOPLEFT", tr, "BOTTOMLEFT");
    right:SetPoint("TOPRIGHT", tr, "BOTTOMRIGHT");
    right:SetPoint("BOTTOM", br, "TOP");
    return { tl, tr, bl, br, top, bottom, left, right };
end

-- Modern skin styling for the message windows. While such a skin is
-- selected, each window uses the History Viewer's construction at a
-- smaller size: the standard metal nine-slice frame, a title band with
-- the conversation name in gold, the message area as a recessed inset
-- well, the input box inside the native search-box border, and the
-- standard red corner X. The well's fill follows the message-area
-- setting. In cut-out mode the frame fill is drawn only around the
-- message well, so a clear well shows the game world through it.
local function buildWindowChrome(obj)
    local apply = _G.NineSliceUtil and _G.NineSliceUtil.ApplyLayoutByName;
    local display = obj.widgets.chat_display;
    local msg_box = obj.widgets.msg_box;

    local chrome = CreateFrame("Frame", nil, obj);
    chrome:SetAllPoints();
    chrome:SetFrameLevel(obj:GetFrameLevel());

    -- Apply the layout first. The portrait variant's left pieces sit
    -- 13px outside the frame, 5px further than the plain layout's, which
    -- puts the left rail at about -1..+4. The fill's left inset must
    -- follow the applied layout or a gap opens against the rail.
    chrome.hasPortrait = (apply and (pcall(apply, chrome, "PortraitFrameTemplate")
        or pcall(apply, chrome, "ButtonFrameTemplate"))) and true or false;
    if(not chrome.hasPortrait) then
        -- Lite chrome, for clients whose nine-slice layouts lack this
        -- art (classic era): the same frame, built from the shipped
        -- copies of the retail pieces at the retail geometry. Only the
        -- portrait paint path stays era-specific (LiteRepaintPortrait).
        chrome.lite = true;
        chrome.hasPortrait = true;
        chrome.metal = BuildLiteMetalFrame(chrome, true);
    end
    local bgLeft = chrome.hasPortrait and 2 or 7;
    local bgRight = 0;
    local bgBottom = 3;

    -- Otherwise the fill matches the History Viewer: native panel
    -- insets at top and bottom, and it runs under the asymmetric right
    -- rail to the frame edge.
    chrome.bg = chrome:CreateTexture(nil, "BACKGROUND", nil, -8);
    chrome.bg:SetPoint("TOPLEFT", bgLeft, -18);
    chrome.bg:SetPoint("BOTTOMRIGHT", bgRight, bgBottom);

    -- Cut-out strips: the fill drawn only around the message well.
    local function strip()
        local tex = chrome:CreateTexture(nil, "BACKGROUND", nil, -8);
        tex:Hide();
        return tex;
    end
    local stripTop = strip();
    stripTop:SetPoint("TOPLEFT", chrome, "TOPLEFT", bgLeft, -18);
    stripTop:SetPoint("RIGHT", chrome, "RIGHT", bgRight, 0);
    stripTop:SetPoint("BOTTOM", display, "TOP", 0, 6);
    local stripBottom = strip();
    stripBottom:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", bgLeft, bgBottom);
    stripBottom:SetPoint("RIGHT", chrome, "RIGHT", bgRight, 0);
    stripBottom:SetPoint("TOP", display, "BOTTOM", 0, -6);
    local stripLeft = strip();
    stripLeft:SetPoint("LEFT", chrome, "LEFT", bgLeft, 0);
    stripLeft:SetPoint("RIGHT", display, "LEFT", -6, 0);
    stripLeft:SetPoint("TOP", display, "TOP", 0, 6);
    stripLeft:SetPoint("BOTTOM", display, "BOTTOM", 0, -6);
    local stripRight = strip();
    stripRight:SetPoint("RIGHT", chrome, "RIGHT", bgRight, 0);
    stripRight:SetPoint("LEFT", display, "RIGHT", 24, 0);
    stripRight:SetPoint("TOP", display, "TOP", 0, 6);
    stripRight:SetPoint("BOTTOM", display, "BOTTOM", 0, -6);
    chrome.strips = { stripTop, stripBottom, stripLeft, stripRight };

    -- Cut the frame fill out behind the circled portrait. An inverse
    -- circular mask (white field, clear circle) covers the portrait's
    -- footprint on the fill and on the cut-out strips. Without it, a
    -- translucent window shows the fill's edge crossing the circle
    -- behind the icon.
    if(chrome.hasPortrait and chrome.bg.AddMaskTexture) then
        local hole = chrome:CreateMaskTexture();
        -- PNG textures resolve only with their extension spelled out.
        hole:SetTexture("Interface\\AddOns\\"..addonTocName.."\\Skins\\Modern\\portrait_hole_mask.png",
            "CLAMPTOWHITE", "CLAMPTOWHITE");
        hole:SetPoint("CENTER", obj, "TOPLEFT", 25.5, -22);
        hole:SetSize(56, 56);
        chrome.bg:AddMaskTexture(hole);
        for i = 1, #chrome.strips do
            chrome.strips[i]:AddMaskTexture(hole);
        end
        chrome.portraitHole = hole;
    end

    -- Message well: a recessed inset around the display area. The well
    -- extends 24px past the display on the right. The theme pulls the
    -- display's right edge in by 18px; the well keeps its original
    -- footprint, and the scrollbar sits in the freed gutter.
    local well = CreateFrame("Frame", nil, obj);
    well:SetPoint("TOPLEFT", display, "TOPLEFT", -6, 6);
    well:SetPoint("BOTTOMRIGHT", display, "BOTTOMRIGHT", 24, -6);
    well:SetFrameLevel(obj:GetFrameLevel());
    well.bg = well:CreateTexture(nil, "BACKGROUND", nil, -7);
    well.bg:SetPoint("TOPLEFT", 2, -2);
    well.bg:SetPoint("BOTTOMRIGHT", -2, 2);
    chrome.well = well;

    -- Input border: the native search box's end caps and middle piece
    -- around the message box.
    if(msg_box) then
        local input = CreateFrame("Frame", nil, obj);
        input:SetPoint("TOPLEFT", msg_box, "TOPLEFT", 0, 0);
        input:SetPoint("BOTTOMRIGHT", msg_box, "BOTTOMRIGHT", 0, 0);
        input:SetFrameLevel(obj:GetFrameLevel());
        -- The search-border art is applied only where the atlases
        -- exist; without them the row keeps the counter and the wrap
        -- machinery but no border decor.
        local hasSearchArt = getAtlasInfo("common-search-border-left")
            and getAtlasInfo("common-search-border-middle")
            and getAtlasInfo("common-search-border-right") and true or false;
        if(hasSearchArt) then
            input.capLeft = input:CreateTexture(nil, "BACKGROUND");
            input.capLeft:SetAtlas("common-search-border-left");
            input.capLeft:SetSize(8, 20);
            input.capLeft:SetPoint("LEFT", -5, 0);
            input.capRight = input:CreateTexture(nil, "BACKGROUND");
            input.capRight:SetAtlas("common-search-border-right");
            input.capRight:SetSize(8, 20);
            input.capRight:SetPoint("RIGHT", 5, 0);
            input.capMiddle = input:CreateTexture(nil, "BACKGROUND");
            input.capMiddle:SetAtlas("common-search-border-middle");
            input.capMiddle:SetPoint("TOPLEFT", input.capLeft, "TOPRIGHT");
            input.capMiddle:SetPoint("BOTTOMRIGHT", input.capRight, "BOTTOMLEFT");
            -- Wrap-mode border: the same search-border art, cut into a
            -- nine-piece grid so it also stretches vertically. Texture
            -- coordinates apply within an atlas member, so the pieces can
            -- be sampled directly: the caps' top and bottom 40% become the
            -- corners, their middle band becomes the side edges, and the
            -- tube's bands become the top edge, bottom edge, and fill.
            local grid = {};
            local function slice(atlas, top, bottom)
                local tex = input:CreateTexture(nil, "BACKGROUND");
                tex:SetAtlas(atlas);
                tex:SetTexCoord(0, 1, top, bottom);
                table.insert(grid, tex);
                return tex;
            end
            -- On the single-line border the caps sit 3px inside the row's
            -- vertical extent. The grid keeps the same inset so the art
            -- does not move when the mode changes.
            local tl = slice("common-search-border-left", 0, 0.4);
            tl:SetSize(8, 8);
            tl:SetPoint("TOPLEFT", -5, -3);
            local bl = slice("common-search-border-left", 0.6, 1);
            bl:SetSize(8, 8);
            bl:SetPoint("BOTTOMLEFT", -5, 3);
            local edgeL = slice("common-search-border-left", 0.45, 0.55);
            edgeL:SetPoint("TOPLEFT", tl, "BOTTOMLEFT");
            edgeL:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT");
            local tr = slice("common-search-border-right", 0, 0.4);
            tr:SetSize(8, 8);
            tr:SetPoint("TOPRIGHT", 5, -3);
            local br = slice("common-search-border-right", 0.6, 1);
            br:SetSize(8, 8);
            br:SetPoint("BOTTOMRIGHT", 5, 3);
            local edgeR = slice("common-search-border-right", 0.45, 0.55);
            edgeR:SetPoint("TOPLEFT", tr, "BOTTOMLEFT");
            edgeR:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT");
            local edgeT = slice("common-search-border-middle", 0, 0.4);
            edgeT:SetPoint("TOPLEFT", tl, "TOPRIGHT");
            edgeT:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT");
            local edgeB = slice("common-search-border-middle", 0.6, 1);
            edgeB:SetPoint("TOPLEFT", bl, "TOPRIGHT");
            edgeB:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT");
            local center = slice("common-search-border-middle", 0.45, 0.55);
            center:SetPoint("TOPLEFT", edgeT, "BOTTOMLEFT");
            center:SetPoint("BOTTOMRIGHT", edgeB, "TOPRIGHT");
            for i=1, #grid do grid[i]:Hide(); end
            input.multi = grid;
        end
        input.multi = input.multi or {};
        -- Character counter, on its own strip above the row. The game
        -- limits chat messages to 255 characters.
        input.counter = input:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
        -- Centered vertically in the strip between the row and the
        -- message area (strip height 15, counter height about 10).
        input.counter:SetPoint("BOTTOMRIGHT", input, "TOPRIGHT", 2, 0);
        chrome.input = input;
    end

    -- The well's recessed inset art, where the layout exists; a plain
    -- dark outline stands in on clients without it. Probed on its own:
    -- classic era lacks the frame layouts above but has this one.
    local inset = apply and pcall(apply, well, "InsetFrameTemplate");
    if(not inset) then
        local function edge()
            local tex = well:CreateTexture(nil, "BORDER");
            tex:SetColorTexture(0, 0, 0, 0.9);
            return tex;
        end
        local top, bottom, left, right = edge(), edge(), edge(), edge();
        top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(1);
        bottom:SetPoint("BOTTOMLEFT"); bottom:SetPoint("BOTTOMRIGHT"); bottom:SetHeight(1);
        left:SetPoint("TOPLEFT", 0, -1); left:SetPoint("BOTTOMLEFT", 0, 1); left:SetWidth(1);
        right:SetPoint("TOPRIGHT", 0, -1); right:SetPoint("BOTTOMRIGHT", 0, 1); right:SetWidth(1);
    end

    -- Minimal scrollbar inside the message well, in the gutter that the
    -- display's pulled-in right edge leaves free. This matches the
    -- History Viewer. The window's scroll buttons act as its steppers.
    -- Skipped without the minimal-scrollbar art; the default scroll
    -- controls stay.
    if(display.GetMaxScrollRange and display.GetScrollOffset
            and getAtlasInfo("minimal-scrollbar-small-thumb-middle")) then
        local bar = CreateFrame("Slider", nil, obj);
        bar:SetOrientation("VERTICAL");
        bar:SetWidth(16);
        bar:SetFrameLevel(obj:GetFrameLevel() + 2);
        bar:SetPoint("TOPRIGHT", display, "TOPRIGHT", 18, -19);
        bar:SetPoint("BOTTOMRIGHT", display, "BOTTOMRIGHT", 18, 19);
        bar:SetMinMaxValues(0, 0);
        bar:SetValueStep(1);
        bar:SetValue(0);
        local thumb = bar:CreateTexture(nil, "OVERLAY");
        bar:SetThumbTexture(thumb);
        thumb:SetAlpha(0);
        local capTop = bar:CreateTexture(nil, "ARTWORK");
        capTop:SetAtlas("minimal-scrollbar-small-thumb-top", true);
        capTop:SetPoint("TOP", thumb, "TOP");
        local capBottom = bar:CreateTexture(nil, "ARTWORK");
        capBottom:SetAtlas("minimal-scrollbar-small-thumb-bottom", true);
        capBottom:SetPoint("BOTTOM", thumb, "BOTTOM");
        local body = bar:CreateTexture(nil, "ARTWORK");
        body:SetAtlas("minimal-scrollbar-small-thumb-middle");
        body:SetPoint("TOPLEFT", capTop, "BOTTOMLEFT");
        body:SetPoint("BOTTOMRIGHT", capBottom, "TOPRIGHT");
        local trackTop = bar:CreateTexture(nil, "BACKGROUND");
        trackTop:SetAtlas("minimal-scrollbar-track-top", true);
        trackTop:SetPoint("TOP");
        local trackBottom = bar:CreateTexture(nil, "BACKGROUND");
        trackBottom:SetAtlas("minimal-scrollbar-track-bottom", true);
        trackBottom:SetPoint("BOTTOM");
        local trackMiddle = bar:CreateTexture(nil, "BACKGROUND");
        trackMiddle:SetAtlas("!minimal-scrollbar-track-middle");
        trackMiddle:SetPoint("TOPLEFT", trackTop, "BOTTOMLEFT");
        trackMiddle:SetPoint("BOTTOMRIGHT", trackBottom, "TOPRIGHT");
        -- Size the thumb after the track has settled. A thumb almost as
        -- long as the track leaves almost no drag travel.
        local function sizeThumb()
            local info = getAtlasInfo("minimal-scrollbar-small-thumb-middle");
            local trackHeight = bar:GetHeight() or 0;
            local thumbHeight = 56;
            if(trackHeight > 0) then
                local cap = _G.math.floor(trackHeight * 0.6);
                if(cap < 20) then cap = 20; end
                if(thumbHeight > cap) then thumbHeight = cap; end
            end
            thumb:SetSize(8, thumbHeight);
            if(info and info.height and info.height > 0) then
                local extent = (thumbHeight - 16) / info.height;
                if(extent > 1) then extent = 1; end
                body:SetTexCoord(0, 1, 0, extent);
            end
        end
        bar:HookScript("OnSizeChanged", sizeThumb);
        sizeThumb();
        bar.wimMaxRange = 0;
        bar:SetScript("OnValueChanged", function(self, value)
            if(self.wimSyncing) then return; end
            display:SetScrollOffset(self.wimMaxRange - _G.math.floor(value + 0.5));
        end);
        bar.wimElapsed = 1;
        bar:SetScript("OnUpdate", function(self, elapsed)
            self.wimElapsed = self.wimElapsed + elapsed;
            if(self.wimElapsed < 0.1) then return; end
            self.wimElapsed = 0;
            local maxRange = display:GetMaxScrollRange();
            self.wimSyncing = true;
            if(maxRange ~= self.wimMaxRange) then
                self.wimMaxRange = maxRange;
                self:SetMinMaxValues(0, maxRange);
            end
            self:SetValue(maxRange - display:GetScrollOffset());
            self.wimSyncing = false;
        end);
        bar:Hide();
        chrome.scrollBar = bar;
    end

    -- The fade logic keeps a window solid only while the mouse-focus
    -- frame is the window or is tagged with it. The slider receives
    -- mouse input, so every chrome piece carries the tag.
    chrome.parentWindow = obj;
    well.parentWindow = obj;
    if(chrome.input) then chrome.input.parentWindow = obj; end
    if(chrome.scrollBar) then chrome.scrollBar.parentWindow = obj; end

    -- Resizing moves the strips; picture backgrounds re-window so the
    -- image stays continuous (see ApplyChromeBackgroundToStrips). The
    -- show hook covers windows whose theme applied while they were
    -- hidden with no rect yet (chat windows build at login, hidden),
    -- one frame later so the rects have settled.
    local function rewindowStrips()
        local liveTheme = db and db.modernTheme;
        if(liveTheme and liveTheme.chatCutout and chrome:IsShown()) then
            ApplyChromeBackgroundToStrips(chrome.strips, chrome.bg,
                liveTheme.chatFrame);
        end
    end
    obj:HookScript("OnSizeChanged", rewindowStrips);
    obj:HookScript("OnShow", function()
        _G.C_Timer.After(0, rewindowStrips);
    end);

    obj.wimChrome = chrome;
    return true;
end

-- Steppers use the minimal arrow atlases, 16px wide to align with the
-- 8px tube. SetTexCoord applies within an atlas member, so the
-- coordinates are reset on every state change.
local function styleWindowStepper(button, up)
    local prefix = up and "minimal-scrollbar-arrow-top"
                   or "minimal-scrollbar-arrow-bottom";
    if(not getAtlasInfo(prefix)) then return; end
    local states = {
        button:GetNormalTexture(), button:GetPushedTexture(),
        button:GetDisabledTexture(), button:GetHighlightTexture(),
    };
    local atlases = { prefix, prefix.."-down", prefix, prefix.."-over" };
    for i=1, #states do
        if(states[i]) then
            states[i]:SetAtlas(atlases[i]);
            states[i]:SetTexCoord(0, 1, 0, 1);
        end
    end
    local highlight = button:GetHighlightTexture();
    if(highlight) then highlight:SetBlendMode("BLEND"); end
    button:SetSize(16, 11);
end

-- A minimal-art scrollbar for a plain ScrollFrame, for clients whose
-- generic scroll template still carries the old wide scrollbar
-- (classic era; probed via HasPortraitPanelArt at the call sites).
-- Whatever scrollbar the template attached is hidden and a slim
-- slider takes its place, built from the same pieces as the themed
-- chat-window scrollbar. No-op without the atlases.
function AttachMinimalScrollBar(scroll, host)
    if(not getAtlasInfo("minimal-scrollbar-small-thumb-middle")
            or not getAtlasInfo("minimal-scrollbar-track-top")) then
        return false;
    end
    local name = scroll.GetName and scroll:GetName();
    local old = scroll.ScrollBar or (name and _G[name.."ScrollBar"]);
    if(old and old.Hide) then
        old:Hide();
        if(old.HookScript) then
            -- wimClassicBar hands the template's own bar back (the
            -- filter editor's classic dress); without it the old bar
            -- stays retired.
            pcall(old.HookScript, old, "OnShow", function(self)
                if(not scroll.wimClassicBar) then self:Hide(); end
            end);
        end
    end

    local bar = CreateFrame("Slider", nil, host);
    bar:SetOrientation("VERTICAL");
    bar:SetWidth(16);
    bar:SetFrameLevel(scroll:GetFrameLevel() + 2);
    bar:SetPoint("TOPRIGHT", host, "TOPRIGHT", -6, -12);
    bar:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -6, 12);
    bar:SetMinMaxValues(0, 0);
    bar:SetValueStep(1);
    bar:SetValue(0);
    local thumb = bar:CreateTexture(nil, "OVERLAY");
    bar:SetThumbTexture(thumb);
    thumb:SetAlpha(0);
    local capTop = bar:CreateTexture(nil, "ARTWORK");
    capTop:SetAtlas("minimal-scrollbar-small-thumb-top", true);
    capTop:SetPoint("TOP", thumb, "TOP");
    local capBottom = bar:CreateTexture(nil, "ARTWORK");
    capBottom:SetAtlas("minimal-scrollbar-small-thumb-bottom", true);
    capBottom:SetPoint("BOTTOM", thumb, "BOTTOM");
    local body = bar:CreateTexture(nil, "ARTWORK");
    body:SetAtlas("minimal-scrollbar-small-thumb-middle");
    body:SetPoint("TOPLEFT", capTop, "BOTTOMLEFT");
    body:SetPoint("BOTTOMRIGHT", capBottom, "TOPRIGHT");
    local trackTop = bar:CreateTexture(nil, "BACKGROUND");
    trackTop:SetAtlas("minimal-scrollbar-track-top", true);
    trackTop:SetPoint("TOP");
    local trackBottom = bar:CreateTexture(nil, "BACKGROUND");
    trackBottom:SetAtlas("minimal-scrollbar-track-bottom", true);
    trackBottom:SetPoint("BOTTOM");
    local trackMiddle = bar:CreateTexture(nil, "BACKGROUND");
    trackMiddle:SetAtlas("!minimal-scrollbar-track-middle");
    trackMiddle:SetPoint("TOPLEFT", trackTop, "BOTTOMLEFT");
    trackMiddle:SetPoint("BOTTOMRIGHT", trackBottom, "TOPRIGHT");

    local function sizeThumb()
        local trackHeight = bar:GetHeight() or 0;
        local thumbHeight = 40;
        if(trackHeight > 0) then
            local cap = _G.math.floor(trackHeight * 0.6);
            if(cap < 20) then cap = 20; end
            if(thumbHeight > cap) then thumbHeight = cap; end
        end
        thumb:SetSize(8, thumbHeight);
        local info = getAtlasInfo("minimal-scrollbar-small-thumb-middle");
        if(info and info.height and info.height > 0) then
            local extent = (thumbHeight - 16) / info.height;
            if(extent > 1) then extent = 1; end
            body:SetTexCoord(0, 1, 0, extent);
        end
    end
    bar:HookScript("OnSizeChanged", sizeThumb);
    sizeThumb();

    bar:SetScript("OnValueChanged", function(self, value)
        if(not self.wimSyncing) then
            scroll:SetVerticalScroll(value);
        end
    end);
    scroll:HookScript("OnScrollRangeChanged", function(_, _, yrange)
        yrange = yrange or 0;
        if(yrange < 0) then yrange = 0; end
        bar.wimSyncing = true;
        bar:SetMinMaxValues(0, yrange);
        local offset = scroll:GetVerticalScroll() or 0;
        bar:SetValue(offset < yrange and offset or yrange);
        bar.wimSyncing = false;
        bar:SetShown(yrange > 1 and not scroll.wimClassicBar
            and scroll:IsShown());
        sizeThumb();
    end);
    scroll:HookScript("OnVerticalScroll", function(_, offset)
        bar.wimSyncing = true;
        bar:SetValue(offset or 0);
        bar.wimSyncing = false;
    end);
    bar:Hide();
    return bar;
end

-- Swaps a scroll frame between its template scrollbar and the slim
-- one AttachMinimalScrollBar built for it.
function SetMinimalScrollBarShown(scroll, bar, useSlim)
    scroll.wimClassicBar = (not useSlim) or nil;
    local name = scroll.GetName and scroll:GetName();
    local old = scroll.ScrollBar or (name and _G[name.."ScrollBar"]);
    if(old and old.SetShown) then
        old:SetShown(not useSlim);
    end
    if(bar and bar.SetShown) then
        if(useSlim) then
            local _, maxValue = bar:GetMinMaxValues();
            bar:SetShown((maxValue or 0) > 1);
        else
            bar:Hide();
        end
    end
end

-- The class-icon cells contain transparent padding, which makes the
-- emblem look small inside the portrait ring. Zoom the current cell's
-- texture coordinates inward so the emblem fills the circle. This runs
-- after every UpdateIcon (which resets the cell), so repeated runs are
-- safe.
function ZoomPortraitIcon(obj)
    local icon = obj.widgets and obj.widgets.class_icon;
    if(not icon) then return; end
    -- Roleplay profile portraits are full-frame images, not emblem
    -- cells. Their crop is applied where they are painted.
    if(obj.wimRPIcon) then return; end
    local ulx, uly, _, lly, urx = icon:GetTexCoord();
    local left, right, top, bottom = ulx, urx, uly, lly;
    local w, h = right - left, bottom - top;
    if(w <= 0 or h <= 0) then return; end
    -- Measured from the class-icon sheet: the emblem fills only the
    -- middle ~58% of its cell, with a ~20% transparent inset on each
    -- side. The zoom inset is slightly larger than that margin so the
    -- emblem spans the full circle instead of floating inside it. The
    -- circular mask hides the small overshoot at the edges.
    local ix, iy = w * 0.22, h * 0.22;
    icon:SetTexCoord(left + ix, right - ix, top + iy, bottom - iy);
end

-- The lite portrait's paint pass. Era clients sample a mask texture
-- through the masked texture's own texture coordinates, so a
-- sprite-sheet cell defeats the circle mask: the sampled patch of the
-- mask is all white and the square cell renders uncut. Textures at
-- full coordinates clip fine. So the icon is repainted from the
-- per-class icon file at full coordinates, filling the circle; the
-- roleplay icon just drops its baked-border crop. Windows with
-- neither (Game Master tags) keep the sheet cell, inscribed small
-- enough to sit inside the circular field.
function LiteRepaintPortrait(obj)
    local icon = obj.widgets and obj.widgets.class_icon;
    if(not icon) then return; end
    obj.wimLitePainted = true;
    if(obj.wimRPIcon) then
        icon:SetTexCoord(0, 1, 0, 1);
        icon:SetSize(56, 56);
        dPrint("LitePortrait "..(obj:GetName() or "?")..": rp, 56");
        return;
    end
    if(obj.type == "chat") then
        -- The chat-type icon is a soft alpha blob with wide transparent
        -- margins; it shapes itself, so it takes retail's zoom crop at
        -- the full portrait size and the blob spans the circle.
        ZoomPortraitIcon(obj);
        icon:SetSize(56, 56);
        dPrint("LitePortrait "..(obj:GetName() or "?")..": chat, 56 zoomed");
        return;
    end
    local entry = obj.class and constants.classes[obj.class];
    local tag = entry and entry.tag and string.gsub(entry.tag, "F$", "");
    local file = tag and tag ~= "GM" and "Interface\\Icons\\ClassIcon_"..tag;
    if(file and (not _G.GetFileIDFromPath or _G.GetFileIDFromPath(file))) then
        icon:SetTexture(file);
        icon:SetTexCoord(0, 1, 0, 1);
        icon:SetSize(56, 56);
        dPrint("LitePortrait "..(obj:GetName() or "?")..": file "
            ..tostring(tag)..", 56");
    else
        -- Unknown class so far (a window opened before any class data,
        -- like an intercepted /w): the sheet's blank emblem is circular
        -- with a ~20% transparent inset, so cropping exactly to the
        -- inset inscribes it in the field at full size with nothing
        -- left for the missing mask to clip. Square cells (Battle.net
        -- client logos, GM tags) keep the small inscribed cell.
        if(not tag and not obj.isBN) then
            local ulx, uly, _, lly, urx = icon:GetTexCoord();
            local left, right, top, bottom = ulx, urx, uly, lly;
            local w, h = right - left, bottom - top;
            if(w > 0 and h > 0) then
                local ix, iy = w * 0.19, h * 0.19;
                icon:SetTexCoord(left + ix, right - ix, top + iy, bottom - iy);
                icon:SetSize(56, 56);
                dPrint("LitePortrait "..(obj:GetName() or "?")..": blank, 56");
                return;
            end
        end
        ZoomPortraitIcon(obj);
        icon:SetSize(36, 36);
        dPrint("LitePortrait "..(obj:GetName() or "?")..": fallback, 36"
            ..", class="..tostring(obj.class));
    end
end

-- Themed header layout. The title text runs between the circled
-- portrait and the corner button. The details text runs between the
-- portrait and the frame edge. The message well starts below whichever
-- needs more room. Text keeps its skin font size and shrinks to fit
-- long content, down to a minimum size. Past that minimum, a
-- single-line string truncates, and the details text word-wraps
-- (centered) and pushes the well down instead of overflowing into it.
-- The layout reruns on resize and on text changes, always from the
-- skin baseline the theme pass captured.
local HEADER_MIN_FONT = 10;

local INPUT_LEFT_PULL = 12;
-- The character counter sits on its own strip between the input row
-- and the message area; text never shares the row with it. The window
-- height increases by the strip height plus any wrap-mode growth, so
-- the message area size never changes with the theme or the mode. The
-- input row keeps the skin's bottom offset; with the art's inset this
-- gives the same margin below the row as beside it.
local WRAP_HEADROOM = 12;

-- The rendered line height. The font's nominal height is slightly
-- smaller than the rendered height. Budgeting with the nominal value
-- makes the view fractionally smaller than its content, which causes
-- endless sub-pixel scroll corrections that look like jitter while
-- typing.
local function boxLineHeight(obj, box)
    local inner = obj.wimBoxInnerText;
    if(not inner) then
        local regions = { box:GetRegions() };
        for i=1, #regions do
            if(regions[i].GetObjectType
                    and regions[i]:GetObjectType() == "FontString") then
                obj.wimBoxInnerText = regions[i];
                inner = regions[i];
                break;
            end
        end
    end
    if(inner and inner.GetLineHeight) then
        local h = inner:GetLineHeight();
        if(h and h > 0) then return h; end
    end
    local _, fontHeight = box:GetFont();
    return fontHeight or 14;
end

local function setInputScroll(obj, offset)
    local input = obj.wimChrome and obj.wimChrome.input;
    local viewport = input and input.scroll;
    local box = obj.widgets and obj.widgets.msg_box;
    if(not (viewport and box)) then return; end
    local range = (box:GetHeight() or 0) - (viewport:GetHeight() or 0);
    if(range < 0) then range = 0; end
    if(not offset or offset < 0) then offset = 0; end
    if(offset > range) then offset = range; end
    local current = obj.wimInputScrollOfs;
    obj.wimInputScrollOfs = offset;
    if(current ~= nil and math.abs(current - offset) < 0.25) then
        return;
    end
    viewport:SetVerticalScroll(offset);
end

local function settleBorrow(obj, target)
    obj.wimBoxExtra = target;
    local shown = obj.wimBorrowShown or 0;
    if(target ~= shown) then
        obj.wimBorrowShown = target;
        obj:SetHeight((obj:GetHeight() or 0) + (target - shown));
    end
end

-- The skin's own widget point data is the layout baseline. Reading it
-- fresh for every adjustment, instead of capturing live points, means
-- repeated layouts can never drift. relativeTo "window" resolves to
-- the window itself; anything else resolves to a sibling widget.
local function skinWidgetPoints(name)
    local widgetSkin = GetSelectedSkin().message_window.widgets[name];
    return widgetSkin and widgetSkin.points;
end

local function resolveRelativeTo(obj, relativeTo)
    if(type(relativeTo) == "string") then
        if(string.lower(relativeTo) == "window") then
            return obj;
        end
        return obj.widgets[relativeTo] or obj;
    end
    return relativeTo or obj;
end

local function fitHeaderLine(fs, base, avail, wraps)
    if(not (fs and base) or not avail or avail <= 0) then return; end
    fs:SetFont(base.path, base.size, base.flags);
    local width = fs.GetUnboundedStringWidth
        and fs:GetUnboundedStringWidth() or fs:GetStringWidth();
    if(width and width > avail) then
        local size = math.floor(base.size * avail / width);
        if(size >= HEADER_MIN_FONT) then
            fs:SetFont(base.path, size, base.flags);
        elseif(not wraps) then
            fs:SetFont(base.path, HEADER_MIN_FONT, base.flags);
        end
        -- A wrapping string keeps the skin font size and wraps when
        -- even the minimum size cannot fit its longest line.
    end
end

function LayoutThemedHeader(obj)
    local chrome = obj.wimChrome;
    local widgets = obj.widgets;
    if(not (chrome and chrome:IsShown() and widgets)) then return; end
    local from, info = widgets.from, widgets.char_info;

    -- Center the title text in the band. The band's optical center is
    -- y -11.5 (the History Viewer's measurement). The usable span runs
    -- from the portrait circle (x 53.5) to the corner button (left
    -- edge -23).
    if(from and obj.wimFromBaseFont) then
        from:ClearAllPoints();
        from:SetPoint("LEFT", obj, "TOPLEFT", 56, -11.5);
        from:SetPoint("RIGHT", obj, "TOPRIGHT", -27, -11.5);
        from:SetJustifyH("CENTER");
        from:SetWordWrap(false);
        fitHeaderLine(from, obj.wimFromBaseFont, from:GetWidth(), false);
    end

    local infoBottom = -28;
    if(info and obj.wimInfoBaseFont) then
        info:ClearAllPoints();
        -- Use the same span as the title above, so both center on the
        -- same axis.
        info:SetPoint("TOPLEFT", obj, "TOPLEFT", 56, -28);
        info:SetPoint("TOPRIGHT", obj, "TOPRIGHT", -27, -28);
        info:SetJustifyH("CENTER");
        info:SetWordWrap(true);
        info:SetNonSpaceWrap(true);
        -- Spacing between the full-title row and the race/class row.
        -- Without it, descenders and apostrophes of adjacent rows
        -- touch.
        info:SetSpacing(3);
        fitHeaderLine(info, obj.wimInfoBaseFont, info:GetWidth(), true);
        infoBottom = -28 - (info:GetStringHeight() or 0);
    end

    -- The well (display top +6) starts below the circle or below the
    -- details text, whichever reaches lower. It never rises above the
    -- skin's own baseline.
    local basePoints = skinWidgetPoints("chat_display");
    local display = widgets.chat_display;
    local headerHeight = 54;
    if(display and basePoints) then
        local wellTop = infoBottom - 4;
        if(chrome.hasPortrait and wellTop > -54) then wellTop = -54; end
        local baseTop;
        for i=1, #basePoints do
            if(string.find(basePoints[i][1], "TOP")) then
                baseTop = basePoints[i][5] or 0;
            end
        end
        local deltaY = 0;
        local desiredTop = wellTop - 6;
        if(baseTop) then
            if(desiredTop > baseTop) then desiredTop = baseTop; end
            deltaY = desiredTop - baseTop;
        end
        headerHeight = -desiredTop;
        display:ClearAllPoints();
        for i=1, #basePoints do
            local p = basePoints[i];
            local x = p[4] or 0;
            local y = p[5] or 0;
            -- The right edge pulls in for the in-well scrollbar. The
            -- left edge moves toward the frame rail with the input
            -- row. The bottom rises by the extra height the wrap mode
            -- gave the input box.
            if(string.find(p[1], "RIGHT")) then x = x - 18; end
            if(string.find(p[1], "LEFT")) then x = x - 12; end
            if(string.find(p[1], "TOP")) then y = y + deltaY;
            elseif(string.find(p[1], "BOTTOM")) then y = y + (obj.wimBoxExtra or 0); end
            display:SetPoint(p[1], resolveRelativeTo(obj, p[2]), p[3], x, y);
        end
    end

    -- Dynamic minimum height: the header, the current right-side
    -- column (its buttons hang from the well's top), and the input row
    -- must all fit inside the frame.
    local column = 0;
    local history = widgets.history;
    if(history and history:IsShown()) then
        column = column + (history:GetHeight() or 0) + 4;
    end
    local shortcuts = widgets.shortcuts;
    if(shortcuts and shortcuts:IsShown()) then
        local buttons = { shortcuts:GetChildren() };
        for i=1, #buttons do
            if(buttons[i]:IsShown()) then
                column = column + (buttons[i]:GetHeight() or 0) + 2;
            end
        end
    end
    local skinWindow = GetSelectedSkin().message_window;
    -- In wrap mode the box's content height has no limit. The
    -- scroller's view height is the row's real footprint.
    local inputRow = 26;
    if(obj.wimBoxInScroll) then
        inputRow = obj.wimInputRowH or inputRow;
    elseif(widgets.msg_box) then
        inputRow = widgets.msg_box:GetHeight() or inputRow;
    end
    local inputHeight = inputRow + 30;
    local minHeight = headerHeight + math.max(column, 60) + inputHeight;
    if(skinWindow.min_height and minHeight < skinWindow.min_height) then
        minHeight = skinWindow.min_height;
    end
    local minWidth = skinWindow.min_width or 256;
    if(obj.SetResizeBounds) then
        obj:SetResizeBounds(minWidth, minHeight);
    elseif(obj.SetMinResize) then
        obj:SetMinResize(minWidth, minHeight);
    end
end

-- Themed input row. The row is pulled toward the frame's left edge
-- together with the message well and carries a character counter (the
-- game limits chat messages to 255 characters). An optional wrap mode
-- turns the box multi-line.
-- This mirrors the whisper engine's word-boundary splitter, including
-- its at-the-limit break for words longer than the limit. A message
-- over the limit is not an error; it is sent as this many messages.
local function estimateMessageCount(text, limit)
    local count, current = 0, 0;
    for word in string.gmatch(text, "%S+") do
        local length = #word;
        while(length > limit) do
            if(current > 0) then
                count = count + 1;
                current = 0;
            end
            count = count + 1;
            length = length - limit;
        end
        if(length > 0) then
            -- current carries a trailing space per word, mirroring the
            -- splitter's chunk, so equality still fits after the trim.
            if(current + length <= limit) then
                current = current + length + 1;
            else
                count = count + 1;
                current = length + 1;
            end
        end
    end
    if(current > 0) then count = count + 1; end
    return count;
end

-- What the send path will really do with this text: a chat-type slash
-- command's body goes through the splitter without its prefix, other
-- slash commands go to the default edit box whole and never split.
local function counterSendPlan(text)
    if(string.sub(text, 1, 1) ~= "/") then
        return text, true;
    end
    local command, body = string.match(text, "^(/%S+)%s+(.-)%s*$");
    local chatType = command and body and _G.hash_ChatTypeInfoList
        and _G.hash_ChatTypeInfoList[string.upper(command)];
    if(chatType and chatType ~= "WHISPER" and chatType ~= "BN_WHISPER"
            and chatType ~= "REPLY" and chatType ~= "CHANNEL") then
        return body, true;
    end
    return text, false;
end

function UpdateThemedInputDecor(obj)
    local chrome = obj.wimChrome;
    local widgets = obj.widgets;
    if(not (chrome and chrome:IsShown() and chrome.input and widgets)) then return; end
    local input = chrome.input;
    local box = widgets.msg_box;
    if(not (box and input.counter)) then return; end

    local raw = box:GetText() or "";
    local text, splits = counterSendPlan(raw);
    local count = #text;
    -- OnCursorChanged can fire every frame while the box has focus;
    -- skip the repaint when nothing it depends on has changed.
    local stamp = count.."|"..tostring(splits).."|"
        ..tostring(obj.wimInputScrollOfs).."|"
        ..tostring(box.IsMultiLine and box:IsMultiLine());
    if(obj.wimDecorStamp == stamp) then
        return;
    end
    obj.wimDecorStamp = stamp;
    -- The limits the whisper engine splits against: 255 characters
    -- for regular whispers, 800 for Battle.net. A slash command's body
    -- always goes out as a plain chat type at the 255 cap.
    local limit = (obj.isBN and text == raw) and 800 or 255;
    if(count == 0) then
        input.counter:SetText("-/"..limit);
        input.counter:SetTextColor(0.6, 0.6, 0.6);
    elseif(not splits) then
        -- The default edit box sends this whole; past the cap it cuts.
        input.counter:SetText(count.."/"..limit);
        if(count > limit) then
            input.counter:SetTextColor(1, 0.35, 0.25);
        else
            input.counter:SetTextColor(0.6, 0.6, 0.6);
        end
    else
        local messages = estimateMessageCount(text, limit);
        input.counter:SetText(count.."/"..limit.." ("..messages..")");
        if(messages > 1) then
            input.counter:SetTextColor(1, 0.65, 0.25);
        else
            input.counter:SetTextColor(0.6, 0.6, 0.6);
        end
    end

    -- Wrap mode grows the row with its content. The scroller's height
    -- follows the number of rendered text lines, not the box's content
    -- height: the caret moves to the next line a character or two
    -- before the text wraps, so the content height oscillates at the
    -- wrap point while the line count stays stable. The window grows
    -- or shrinks by the same amount below the message area, whose size
    -- never changes. Past the optional line cap, the row stops growing
    -- and the scroller keeps the cursor's line in view.
    if(obj.wimBoxInScroll and input.scroll) then
        -- Self-healing. If code outside the theme re-anchored the box
        -- away from its scroller, the box becomes unclipped and
        -- unscrollable and its text overflows the row. Re-run the
        -- layout before measuring; it re-seats the anchors.
        local _, anchoredTo = box:GetPoint(1);
        if(anchoredTo ~= input.scroll) then
            LayoutThemedInput(obj);
            return;
        end
        local lineHeight = boxLineHeight(obj, box);
        local inner = obj.wimBoxInnerText;
        local lines;
        if(inner and inner.GetNumLines) then
            lines = inner:GetNumLines() or 1;
        else
            lines = math.floor(((box:GetHeight() or lineHeight) + 2) / lineHeight);
        end
        if(lines < 1) then lines = 1; end
        local theme = db.modernTheme or {};
        if(theme.inputWrapLimit) then
            local capLines = theme.inputWrapLines or 2;
            if(capLines < 1) then capLines = 1; end
            if(capLines > 20) then capLines = 20; end
            if(lines > capLines) then lines = capLines; end
        end
        -- One rendered line height per line, plus the viewport margins
        -- (6px each side). One line equals the single-line row's 26.
        local rowHeight = lines * lineHeight + 12;
        if(rowHeight < 26) then rowHeight = 26; end
        if(rowHeight ~= obj.wimInputRowH) then
            obj.wimInputRowH = rowHeight;
            input:SetHeight(rowHeight);
        end
        -- wimBorrowShown records how much extra height the window
        -- currently holds for the themed input. Every function that
        -- changes this height (the growth here, the UpdateProps reset,
        -- the mode exit) reads and updates the same record. One value
        -- controls the height, so the writers cannot disagree.
        local target = (rowHeight - 26) + WRAP_HEADROOM;
        if(target ~= (obj.wimBorrowShown or 0)) then
            settleBorrow(obj, target);
            LayoutThemedHeader(obj);
        else
            obj.wimBoxExtra = target;
        end
    end
end

-- Undoes the wrap mode. The box leaves the scroller, becomes
-- single-line again, and takes the skin's own anchors (pulled left
-- while the theme stays active). This is also the restore path for
-- classic skins.
function RestoreThemedInput(obj, keepLeftPull)
    local box = obj.widgets and obj.widgets.msg_box;
    if(not box) then return; end
    local chrome = obj.wimChrome;
    local scroll = chrome and chrome.input and chrome.input.scroll;
    if(obj.wimBoxInScroll) then
        obj.wimBoxInScroll = nil;
        obj.wimInputScrollOfs = 0;
        box.GetParent = nil;
        if(scroll) then
            scroll:Hide();
        end
        box:SetParent(obj);
        -- After SetParent, the box can draw below the Backdrop because
        -- reparenting resets the draw order between frames on the same
        -- level. Set the box one level above the Backdrop so its text
        -- always draws on top of the border art.
        local host = obj.widgets and obj.widgets.Backdrop;
        box:SetFrameLevel(((host and host:GetFrameLevel())
            or obj:GetFrameLevel()) + 1);
    end
    box:SetMultiLine(false);
    obj.wimInputRowH = nil;
    obj.wimCursorStamp = nil;
    local points = skinWidgetPoints("msg_box");
    if(points) then
        -- Themed (keepLeftPull): symmetric side offsets from the frame
        -- edges. Classic: the skin's own points, unchanged.
        box:ClearAllPoints();
        for i=1, #points do
            local p = points[i];
            local x = p[4] or 0;
            if(keepLeftPull) then
                if(string.find(p[1], "LEFT")) then x = x - INPUT_LEFT_PULL; end
                if(string.find(p[1], "RIGHT")) then x = x - 2; end
            end
            box:SetPoint(p[1], resolveRelativeTo(obj, p[2]), p[3], x, p[5]);
        end
    end
    if(keepLeftPull) then
        settleBorrow(obj, WRAP_HEADROOM);
    else
        settleBorrow(obj, 0);
        obj.wimBoxThemed = nil;
        if(obj.wimBoxBaseInsets) then
            local insets = obj.wimBoxBaseInsets;
            box:SetTextInsets(insets[1], insets[2], insets[3], insets[4]);
        end
    end
end

function LayoutThemedInput(obj)
    local chrome = obj.wimChrome;
    local widgets = obj.widgets;
    if(not (chrome and chrome:IsShown() and chrome.input and widgets)) then return; end
    local box = widgets.msg_box;
    local points = skinWidgetPoints("msg_box");
    if(not (box and points)) then return; end
    local input = chrome.input;
    local theme = db.modernTheme or {};
    local wraps = theme.inputWrap and true or false;

    obj.wimBoxThemed = true;
    -- No border decor on clients without the search-border art.
    if(input.capLeft) then
        input.capLeft:SetShown(not wraps);
        input.capRight:SetShown(not wraps);
        input.capMiddle:SetShown(not wraps);
    end
    for i=1, #input.multi do
        input.multi[i]:SetShown(wraps);
    end

    if(wraps) then
        -- A multi-line box must live in a scroller. Anchored on both
        -- edges it fights its own content-driven height, and only a
        -- scroller can keep the cursor's line in view.
        if(not input.scroll) then
            local viewport = CreateFrame("ScrollFrame", nil, obj);
            viewport:SetFrameLevel(obj:GetFrameLevel() + 1);
            viewport.parentWindow = obj;
            if(viewport.SetClipsChildren) then
                viewport:SetClipsChildren(true);
            end
            viewport:EnableMouse(true);
            viewport:SetScript("OnMouseDown", function()
                local target = obj.widgets and obj.widgets.msg_box;
                if(target) then
                    target:SetFocus();
                    target:SetCursorPosition(#(target:GetText() or ""));
                end
            end);
            viewport:EnableMouseWheel(true);
            viewport:SetScript("OnMouseWheel", function(self, delta)
                local target = obj.widgets and obj.widgets.msg_box;
                local step = target and boxLineHeight(obj, target) or 14;
                setInputScroll(obj, (obj.wimInputScrollOfs or 0) - delta * step);
            end);
            viewport:SetScript("OnSizeChanged", function(self, width)
                local target = obj.widgets and obj.widgets.msg_box;
                if(target and width and obj.wimBoxInScroll) then
                    target:SetWidth(width);
                end
                -- A shrunk view or content re-clamps the offset.
                setInputScroll(obj, obj.wimInputScrollOfs or 0);
            end);
            input.scroll = viewport;
        end
        local scroll = input.scroll;
        -- The scroller hangs from the skin's bottom offsets and has an
        -- explicit height. UpdateThemedInputDecor raises that height as
        -- the content grows, and grows the window with it.
        local _, fontHeight = box:GetFont();
        fontHeight = fontHeight or 14;
        local leftX, rightX, bottomY = 24, -10, 4;
        for i=1, #points do
            local p = points[i];
            if(string.find(p[1], "LEFT")) then leftX = p[4] or leftX; end
            if(string.find(p[1], "RIGHT")) then rightX = p[4] or rightX; end
            if(string.find(p[1], "BOTTOM")) then bottomY = p[5] or bottomY; end
        end
        -- The art host (input) takes the row's footprint. The clip
        -- viewport sits 6px inside it vertically, which is 3px inside
        -- the border lines (the art draws them 3px in), so scrolled-out
        -- text is clipped before it reaches the border. The viewport
        -- margins provide all of the vertical spacing; the box itself
        -- keeps zero vertical text insets (see the inset block below).
        input:ClearAllPoints();
        input:SetPoint("BOTTOMLEFT", obj, "BOTTOMLEFT",
            leftX - INPUT_LEFT_PULL, bottomY);
        input:SetPoint("BOTTOMRIGHT", obj, "BOTTOMRIGHT",
            rightX - 2, bottomY);
        obj.wimInputRowH = obj.wimInputRowH or 26;
        input:SetHeight(obj.wimInputRowH);
        scroll:ClearAllPoints();
        scroll:SetPoint("TOPLEFT", input, "TOPLEFT", 0, -6);
        scroll:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 0, 6);
        obj.wimBoxExtra = (obj.wimInputRowH - 26) + WRAP_HEADROOM;
        scroll:Show();

        -- Reparenting an EditBox or toggling multi-line resets its
        -- focus and caret, so both apply only on a real change.
        if(scroll:GetScrollChild() ~= box) then
            scroll:SetScrollChild(box);
            box:SetFrameLevel(scroll:GetFrameLevel() + 1);
        end
        obj.wimBoxInScroll = true;
        -- WIM reads the owning window from GetParent(). The shim keeps
        -- that contract while the box lives in the viewport.
        box.GetParent = function() return obj; end;
        if(box:IsMultiLine()) then
            -- already multi-line; nothing to toggle
        elseif(not pcall(box.SetMultiLine, box, true)) then
            -- If the client refuses the runtime toggle, fall back to
            -- the single-line row rather than a half-configured one.
            RestoreThemedInput(obj, true);
            input:ClearAllPoints();
            input:SetPoint("TOPLEFT", box, "TOPLEFT", 0, 0);
            input:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0);
            return;
        end
        box:ClearAllPoints();
        box:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0);
        obj.wimInputScrollOfs = nil;
        setInputScroll(obj, scroll:GetVerticalScroll() or 0);
        box:SetWidth(scroll:GetWidth() and scroll:GetWidth() > 0
            and scroll:GetWidth() or ((obj:GetWidth() or 300) - 24));
        -- Only a starting height. A multi-line box sizes its own height
        -- to its content, and that content height is the scroller's
        -- range. Pinning it to the view height would leave nothing to
        -- scroll.
        if((box:GetHeight() or 0) < 1) then
            box:SetHeight(fontHeight + 6);
        end
        if(not obj.wimBoxWheelHooked) then
            obj.wimBoxWheelHooked = true;
            -- The box receives mouse input over the text area, so wheel
            -- events arrive here, not on the viewport beneath it.
            box:EnableMouseWheel(true);
            box:HookScript("OnMouseWheel", function(self, delta)
                if(obj.wimBoxInScroll) then
                    local step = boxLineHeight(obj, self);
                    setInputScroll(obj, (obj.wimInputScrollOfs or 0) - delta * step);
                    UpdateThemedInputDecor(obj);
                end
            end);
        end
        if(not obj.wimCursorHooked) then
            obj.wimCursorHooked = true;
            box:HookScript("OnCursorChanged", function(self, x, y, _, height)
                local s = chrome.input and chrome.input.scroll;
                if(not (s and obj.wimBoxInScroll and y)) then return; end
                -- The box can recalculate its text layout without a
                -- real caret move; the event then fires every frame
                -- with the same values. Follow only actual movement,
                -- or every wheel scroll snaps back to the caret's line
                -- one frame later.
                local stamp = tostring(x).."|"..y.."|"..(height or 0);
                if(obj.wimCursorStamp == stamp) then return; end
                obj.wimCursorStamp = stamp;
                -- Keep the cursor's line inside the viewport, with a
                -- 2px margin so the line never touches the border art.
                -- The reported cursor offset excludes the text insets
                -- while the text renders below them, so add the inset
                -- to the cursor coordinates.
                local _, _, insetTop = self:GetTextInsets();
                local view = s:GetHeight() or 0;
                local offset = obj.wimInputScrollOfs or 0;
                local top = -y + (insetTop or 0);
                local bottom = top + (height or 0);
                -- Half-pixel tolerance. Without it, rounding between
                -- the rendered line height and the row budget
                -- re-triggers the follow on every keystroke.
                if(top + 0.5 < offset + 2) then
                    setInputScroll(obj, top - 2);
                elseif(bottom - 0.5 > offset + view - 2) then
                    setInputScroll(obj, bottom - view + 2);
                end
                UpdateThemedInputDecor(obj);
            end);
        end
    else
        RestoreThemedInput(obj, true);
        if(input.scroll) then
            input.scroll:Hide();
        end
        input:ClearAllPoints();
        input:SetPoint("TOPLEFT", box, "TOPLEFT", 0, 0);
        input:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0);
    end

    if(obj.wimBoxBaseInsets == nil) then
        local l, r, t, b = box:GetTextInsets();
        obj.wimBoxBaseInsets = { l or 0, r or 0, t or 0, b or 0 };
    end
    -- The text uses the full row in both modes; the counter has its
    -- own strip. Keep the vertical text insets at their base values in
    -- wrap mode. Extra vertical insets on a multi-line box make the
    -- client recalculate the text layout every frame: OnCursorChanged
    -- fires continuously and the caret never renders. The viewport
    -- margins provide the vertical spacing instead.
    local insets = obj.wimBoxBaseInsets;
    box:SetTextInsets(insets[1], insets[2], insets[3], insets[4]);

    -- Changing wrap modes re-feeds the text. The box only lays its
    -- content out again on a text change, and setting the same string
    -- does nothing, so clear the draft first or it keeps the other
    -- mode's layout. The state starts unset, so the first entry into
    -- either mode counts as a change too.
    local wasWrapped = obj.wimBoxWrapState;
    obj.wimBoxWrapState = wraps;
    if(wasWrapped ~= wraps) then
        local text = box:GetText() or "";
        box:SetText("");
        box:SetText(text);
        box:SetCursorPosition(#text);
    end

    UpdateThemedInputDecor(obj);
end

-- The themed close button shows the minimize glyph at rest (click
-- hides the window) and swaps to the X while SHIFT is held, because
-- SHIFT-click closes the conversation. The art always shows what the
-- click will do. curTextureIndex 2 is the always-close state.
-- The corner-button art. Retail resolves these atlas names to 2x art,
-- but classic flavors ship only the 1x sheet, which upscales blurry at
-- the 24px button size; clients without the portrait panel art paint
-- the addon's shipped copies of the retail 2x pieces instead. The art
-- occupies 36x38 of each padded 64x64 file. Returns true when the name
-- is one of the corner-button pieces.
local SHIPPED_RED_BUTTONS = {
    ["RedButton-Exit"] = "redbutton_exit",
    ["RedButton-exit-pressed"] = "redbutton_exit_pressed",
    ["redbutton-condense"] = "redbutton_condense",
    ["redbutton-condense-pressed"] = "redbutton_condense_pressed",
    ["RedButton-Highlight"] = "redbutton_highlight",
};
function ApplyRedButtonArt(texture, atlasName)
    local shipped = texture and SHIPPED_RED_BUTTONS[atlasName];
    if(not shipped) then
        return false;
    end
    if(HasPortraitPanelArt()) then
        texture:SetAtlas(atlasName);
        texture:SetTexCoord(0, 1, 0, 1);
    else
        texture:SetTexture("Interface\\AddOns\\"..addonTocName
            .."\\Skins\\Modern\\"..shipped..".png");
        texture:SetTexCoord(0, 36 / 64, 0, 38 / 64);
    end
    return true;
end

-- Era's build of the modern menus and dropdowns paints classic-styled
-- atlas variants whose names differ from the retail ones only by a
-- "-classic-" infix. Where this client also carries the retail member,
-- a rename hook keeps every state repaint on it; where it does not,
-- the art is left alone. Retail names never match the pattern, and the
-- helpers are inert on clients with the portrait panel art anyway.
-- The client's own copies of some dark members render with opaque
-- padding (the era textholder bleeds black past its chamfered
-- corners), so those paint from the addon's shipped copies of the
-- retail pixels instead of the client's atlas member. Each entry
-- names the padded file and the art window inside it.
local SHIPPED_MENU_ART = {
    ["common-dropdown-textholder"] = {
        file = "dropdown_textholder", right = 108 / 128, bottom = 82 / 128 },
    ["common-dropdown-a-button"] = {
        file = "dropdown_arrow", right = 54 / 64, bottom = 54 / 64 },
    ["common-dropdown-a-button-open"] = {
        file = "dropdown_arrow_open", right = 54 / 64, bottom = 54 / 64 },
    ["common-dropdown-a-button-hover"] = {
        file = "dropdown_arrow_hover", right = 54 / 64, bottom = 54 / 64 },
    ["common-dropdown-a-button-pressed"] = {
        file = "dropdown_arrow_pressed", right = 54 / 64, bottom = 54 / 64 },
    ["common-dropdown-a-button-pressedhover"] = {
        file = "dropdown_arrow_pressedhover", right = 54 / 64, bottom = 54 / 64 },
    ["common-dropdown-a-button-disabled"] = {
        file = "dropdown_arrow_disabled", right = 54 / 64, bottom = 54 / 64 },
};

-- The client camel-cases the arrow states (buttonDown, buttonHover)
-- where retail dashes them (button, button-hover); the map bridges
-- the two conventions.
local ARROW_STATE_MAP = {
    Down = "", Up = "-open", Open = "-open",
    Hover = "-hover", DownHover = "-hover", HoverDown = "-hover",
    UpHover = "-open", HoverUp = "-open",
    Pressed = "-pressed", PressedHover = "-pressedhover",
    Disabled = "-disabled",
};

local function darkenTexture(tex)
    if(tex.wimDarkHook or not tex.SetAtlas) then return; end
    tex.wimDarkHook = true;
    _G.hooksecurefunc(tex, "SetAtlas", function(self, name)
        if(self.wimDarkGuard or type(name) ~= "string") then return; end
        local dark = string.gsub(name, "%-classic%-", "-", 1);
        if(dark ~= name and not SHIPPED_MENU_ART[dark]
                and not getAtlasInfo(dark)) then
            -- The client names arrow states in a mix of conventions:
            -- camel cores (buttonDown, buttonUp), camel tails
            -- (buttonHover), and dashed suffixes on camel cores
            -- (buttonDown-hover). Normalize toward the retail dashed
            -- names, then fall back through progressively plainer
            -- states.
            local base = string.gsub(dark, "buttonDown", "button", 1);
            if(base == dark) then
                base = string.gsub(dark, "buttonUp", "button-open", 1);
            end
            if(base == dark) then
                local state = string.match(dark, "button(%u%a*)$");
                local mapped = state and ARROW_STATE_MAP[state];
                if(mapped) then
                    base = string.gsub(dark, "button%u%a*$",
                        "button"..mapped);
                end
            end
            local candidates = {
                base,
                string.gsub(base, "%-hover$", ""),
                string.gsub(base, "(button)[%w%-]*$", "%1"),
            };
            for i = 1, #candidates do
                local candidate = candidates[i];
                if(candidate ~= dark and (SHIPPED_MENU_ART[candidate]
                        or getAtlasInfo(candidate))) then
                    dark = candidate;
                    break;
                end
            end
        end
        if(dark == name) then return; end
        local shipped = SHIPPED_MENU_ART[dark];
        if(shipped) then
            self.wimDarkGuard = true;
            self:SetTexture("Interface\\AddOns\\"..addonTocName
                .."\\Skins\\Modern\\"..shipped.file..".png");
            self:SetTexCoord(0, shipped.right, 0, shipped.bottom);
            -- Arrows draw at the retail size and seat: the client
            -- rests them smaller and anchored differently (RIGHT -1,0
            -- against retail's RIGHT +1,-3), which reads misaligned
            -- with the retail art.
            if(string.find(shipped.file, "dropdown_arrow", 1, true)) then
                self:SetSize(27, 27);
                local parent = self:GetParent();
                if(parent) then
                    self:ClearAllPoints();
                    self:SetPoint("RIGHT", parent, "RIGHT", 1, -3);
                end
            end
            self.wimDarkGuard = nil;
        elseif(getAtlasInfo(dark)) then
            self.wimDarkGuard = true;
            self:SetAtlas(dark);
            self.wimDarkGuard = nil;
        end
    end);
    local current = tex.GetAtlas and tex:GetAtlas();
    if(current and string.find(current, "-classic-", 1, true)) then
        tex:SetAtlas(current);
    end
end

-- The menu plate itself: the client's pixels for common-dropdown-bg
-- are the square-cornered panel, so the plate is rebuilt from the
-- shipped retail pixels as a nine-slice (the art is a fixed-size
-- octagon; sliced corners keep the chamfer and shadow unscaled at any
-- menu size) and the client's own plate textures hide. The 136px art
-- sits in a 256px canvas; the 44px margin covers shadow and chamfer.
local menuPlates = setmetatable({}, { __mode = "k" });
local function replaceMenuPlate(frame, plateBg, plateFill)
    plateBg:Hide();
    if(plateFill) then plateFill:Hide(); end
    local existing = menuPlates[frame];
    if(existing) then existing:Show(); return; end
    local plate = CreateFrame("Frame", nil, frame);
    plate:SetPoint("TOPLEFT", -3, 3);
    plate:SetPoint("BOTTOMRIGHT", 3, -3);
    plate:SetFrameLevel(frame:GetFrameLevel());
    local path = "Interface\\AddOns\\"..addonTocName
        .."\\Skins\\Modern\\dropdown_menu_bg.png";
    local ART = 136 / 256;
    local MARGIN = 44 / 256;
    local drawn = 22;
    local function piece(l, r, t, b)
        local tex = plate:CreateTexture(nil, "BACKGROUND");
        tex:SetTexture(path);
        tex:SetTexCoord(l, r, t, b);
        return tex;
    end
    local tl = piece(0, MARGIN, 0, MARGIN);
    tl:SetSize(drawn, drawn); tl:SetPoint("TOPLEFT");
    local tr = piece(ART - MARGIN, ART, 0, MARGIN);
    tr:SetSize(drawn, drawn); tr:SetPoint("TOPRIGHT");
    local bl = piece(0, MARGIN, ART - MARGIN, ART);
    bl:SetSize(drawn, drawn); bl:SetPoint("BOTTOMLEFT");
    local br = piece(ART - MARGIN, ART, ART - MARGIN, ART);
    br:SetSize(drawn, drawn); br:SetPoint("BOTTOMRIGHT");
    local top = piece(MARGIN, ART - MARGIN, 0, MARGIN);
    top:SetPoint("TOPLEFT", tl, "TOPRIGHT");
    top:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT");
    local bottom = piece(MARGIN, ART - MARGIN, ART - MARGIN, ART);
    bottom:SetPoint("TOPLEFT", bl, "TOPRIGHT");
    bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT");
    local left = piece(0, MARGIN, MARGIN, ART - MARGIN);
    left:SetPoint("TOPLEFT", tl, "BOTTOMLEFT");
    left:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT");
    local right = piece(ART - MARGIN, ART, MARGIN, ART - MARGIN);
    right:SetPoint("TOPLEFT", tr, "BOTTOMLEFT");
    right:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT");
    local center = piece(MARGIN, ART - MARGIN, MARGIN, ART - MARGIN);
    center:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT");
    center:SetPoint("BOTTOMRIGHT", br, "TOPLEFT");
    menuPlates[frame] = plate;
end

-- The retail art's bottom chamfer and shadow eat into the interior,
-- so retail lays this menu out with 7px more inset at the bottom than
-- the top (8/15); the classic clients use symmetric insets, which
-- reads bottom-tight under the same art. The pass grows the menu
-- until the bottom gap is topGap+7, measured around the rows only
-- (the plate hangs past the frame rect), so it is a no-op once the
-- gaps match and survives the client re-laying the menu out.
local MENU_BOTTOM_EXTRA = 7;
local paddedMenus = setmetatable({}, { __mode = "k" });
local function equalizeMenuPadding(frame)
    local plate = menuPlates[frame];
    if(not plate or not plate:IsShown() or not frame:IsShown()) then
        return;
    end
    local frameTop, frameBottom = frame:GetTop(), frame:GetBottom();
    if(not frameTop or not frameBottom) then return; end
    local highest, lowest;
    local children = { frame:GetChildren() };
    for i = 1, #children do
        local child = children[i];
        if(child ~= plate and child:IsShown()) then
            local top, bottom = child:GetTop(), child:GetBottom();
            if(top and (not highest or top > highest)) then
                highest = top;
            end
            if(bottom and (not lowest or bottom < lowest)) then
                lowest = bottom;
            end
        end
    end
    if(not highest or not lowest) then return; end
    local delta = (frameTop - highest) + MENU_BOTTOM_EXTRA
        - (lowest - frameBottom);
    if(delta > 0.5) then
        local target = frame:GetHeight() + delta;
        local state = paddedMenus[frame];
        if(state) then state.applied = target; end
        frame:SetHeight(target);
        dPrint(string.format("MenuPad: %+.1f (top %.1f, bottom %.1f)",
            delta, frameTop - highest, lowest - frameBottom));
    end
end

-- The flicker-free path: menus lay themselves out from their style
-- mixin's insets, and both dropdown buttons (self.menuMixin) and
-- context menu owners (ownerRegion.menuMixin) accept an override.
-- A padded copy of the client's default style bakes the extra bottom
-- inset into every layout pass, first paint and refreshes alike, so
-- the equalizer below is only a backstop.
-- Keyed by the base mixin: templates preset owner.menuMixin (era's
-- WowStyle1DropdownTemplate carries MenuStyle1Mixin), so the base is
-- whatever the owner already uses, wrapped rather than replaced.
local paddedMenuMixins = setmetatable({}, { __mode = "k" });
local function paddedMenuMixin(base)
    if(not base or base.wimPadded) then return base; end
    local cached = paddedMenuMixins[base];
    if(cached) then return cached; end
    local baseInset = base.GetInset and base:GetInset();
    if(not baseInset) then return nil; end
    local mixin = _G.CreateFromMixins(base);
    local inset = {
        left = baseInset.left, top = baseInset.top,
        right = baseInset.right,
        bottom = baseInset.bottom + MENU_BOTTOM_EXTRA,
    };
    mixin.GetInset = function() return inset; end;
    mixin.wimPadded = true;
    paddedMenuMixins[base] = mixin;
    return mixin;
end

function PadModernMenus(owner)
    if(HasPortraitPanelArt() or not owner) then return; end
    local variants = _G.MenuVariants;
    local base = owner.menuMixin;
    if(not base and variants) then
        if(owner.SetupMenu and variants.GetDefaultMenuMixin) then
            base = variants.GetDefaultMenuMixin();
        elseif(variants.GetDefaultContextMenuMixin) then
            base = variants.GetDefaultContextMenuMixin();
        end
    end
    owner.menuMixin = paddedMenuMixin(base) or owner.menuMixin;
end

local function hookMenuPadding(menu)
    if(paddedMenus[menu]) then return; end
    paddedMenus[menu] = {};
    menu:HookScript("OnSizeChanged", function(self)
        -- Only a resize from the client's own layout re-runs the
        -- pass; the pass's resize firing this hook must not loop.
        local state = paddedMenus[self];
        if(state and state.applied
                and math.abs(self:GetHeight() - state.applied) < 0.5) then
            return;
        end
        _G.C_Timer.After(0, function()
            equalizeMenuPadding(self);
        end);
    end);
end

local function walkMenus(frame, depth)
    if(depth > 8) then return; end
    if(frame.GetRegions) then
        local regions = { frame:GetRegions() };
        local plateBg;
        for i = 1, #regions do
            darkenTexture(regions[i]);
            local r = regions[i];
            if(r.GetAtlas and r:GetAtlas() == "common-dropdown-bg") then
                plateBg = r;
            end
        end
        if(plateBg) then
            -- The color-fill sibling has neither atlas nor file.
            local plateFill;
            for i = 1, #regions do
                local r = regions[i];
                if(r ~= plateBg and r.GetObjectType
                        and r:GetObjectType() == "Texture"
                        and r.GetAtlas and not r:GetAtlas()
                        and r.GetTexture and not r:GetTexture()) then
                    plateFill = r;
                    break;
                end
            end
            replaceMenuPlate(frame, plateBg, plateFill);
        end
    end
    if(frame.GetChildren) then
        local children = { frame:GetChildren() };
        for i = 1, #children do
            walkMenus(children[i], depth + 1);
        end
    end
end

function DarkenModernMenus(frame, depth)
    if(HasPortraitPanelArt() or not frame) then return; end
    walkMenus(frame, depth or 1);
end

function DarkenModernMenusOnAcquire(rootDescription)
    if(HasPortraitPanelArt() or not rootDescription
            or not rootDescription.AddMenuAcquiredCallback) then return; end
    rootDescription:AddMenuAcquiredCallback(function(menu)
        walkMenus(menu, 1);
        hookMenuPadding(menu);
        _G.C_Timer.After(0, function()
            if(menu:IsShown()) then
                walkMenus(menu, 1);
                equalizeMenuPadding(menu);
            end
        end);
    end);
    if(rootDescription.AddMenuReleasedCallback) then
        rootDescription:AddMenuReleasedCallback(function(menu)
            local plate = menuPlates[menu];
            if(plate) then plate:Hide(); end
        end);
    end
    -- A refresh response re-lays the menu out at its natural height;
    -- the callbacks fire after that, so the padding re-applies here.
    if(rootDescription.AddMenuResponseCallback) then
        rootDescription:AddMenuResponseCallback(function()
            _G.C_Timer.After(0, function()
                for frame in pairs(paddedMenus) do
                    equalizeMenuPadding(frame);
                end
            end);
        end);
    end
end

-- Dropdown buttons repaint their art per state, and their menus build
-- fresh rows on every open; both route through the rename hook. The
-- open-menu lookup is best effort: without it the menu keeps the
-- client's own style but works the same.
function DarkenModernDropdown(dropdown)
    if(HasPortraitPanelArt() or not dropdown) then return; end
    DarkenModernMenus(dropdown);
    -- The classic template right-aligns the control's text; retail's
    -- aligns left.
    local text = dropdown.Text;
    if(text and text.GetJustifyH and text:GetJustifyH() == "RIGHT") then
        text:SetJustifyH("LEFT");
    end
    dropdown:HookScript("OnMouseDown", function()
        _G.C_Timer.After(0, function()
            local manager = _G.Menu and _G.Menu.GetManager
                and _G.Menu.GetManager();
            local open = manager and manager.GetOpenMenu
                and manager:GetOpenMenu();
            if(open) then
                DarkenModernMenus(open);
                -- Keep the frame reachable for /wim snap, and honor a
                -- pending /wim snapmenu arm for dropdown menus too.
                _G.WIM_LastModernMenu = open;
                if(snapNextMenu) then
                    snapNextMenu = nil;
                    if(SnapshotTarget) then
                        _G.C_Timer.After(0.2, function()
                            SnapshotTarget("WIM_LastModernMenu");
                        end);
                    end
                end
            end
        end);
    end);
end

function UpdateThemedCloseArt(obj)
    local close = obj.widgets and obj.widgets.close;
    if(not (close and close.GetNormalTexture)) then return; end
    local closes = _G.IsShiftKeyDown() or close.curTextureIndex == 2;
    local normal = close:GetNormalTexture();
    local pushed = close:GetPushedTexture();
    local highlight = close:GetHighlightTexture();
    if(normal) then
        ApplyRedButtonArt(normal, closes and "RedButton-Exit" or "redbutton-condense");
    end
    if(pushed) then
        ApplyRedButtonArt(pushed, closes and "RedButton-exit-pressed" or "redbutton-condense-pressed");
    end
    if(highlight) then
        ApplyRedButtonArt(highlight, "RedButton-Highlight");
        highlight:SetBlendMode("ADD");
    end
    close:SetSize(24, 24);
    close:ClearAllPoints();
    close:SetPoint("TOPRIGHT", obj, "TOPRIGHT", 1, 0);
end

-- Live art swap while SHIFT is pressed or released over themed windows.
local shiftWatcher = CreateFrame("Frame");
shiftWatcher:RegisterEvent("MODIFIER_STATE_CHANGED");
shiftWatcher:SetScript("OnEvent", function(_, _, key)
    if(key ~= "LSHIFT" and key ~= "RSHIFT") then return; end
    local windowList = WindowSoupBowl.windows;
    for i=1, #windowList do
        local win = windowList[i].obj;
        if(win and win.wimChrome and win.wimChrome:IsShown()) then
            UpdateThemedCloseArt(win);
        end
    end
end);

function ApplyModernThemeToWindow(obj)
    local theme = db and db.modernTheme;
    local skin = GetSelectedSkin();
    local active = (theme and skin and skin.modernOnly) and true or false;
    local widgets = obj.widgets;
    local bd = widgets and widgets.Backdrop;
    if(not (bd and bd.bg and widgets.chat_display)) then return; end

    if(active and not obj.wimChrome and not obj.wimChromeFailed) then
        obj.wimChromeFailed = not buildWindowChrome(obj);
    end
    local chrome = active and obj.wimChrome or nil;

    -- One debug-log line per apply/teardown transition; steady-state
    -- passes stay quiet.
    if(obj.wimThemeWasActive ~= active) then
        obj.wimThemeWasActive = active;
        dPrint("ModernTheme "..(obj:GetName() or "?")..": "
            ..(active and "apply" or "teardown")..", chrome="
            ..(obj.wimChrome and (obj.wimChrome.lite and "lite" or "layout")
               or (obj.wimChromeFailed and "failed" or "none")));
    end

    -- The skin's own backdrop pieces hide while the chrome is shown.
    -- They return when the chrome goes: ApplySkinToWindow reapplies
    -- their art on each pass before this code runs. This includes the
    -- lite chrome, which draws its own hairline edge: the skin's
    -- border pieces carry the panel fill baked in and would read as a
    -- fat black ring around the lite fills.
    local skinShown = (chrome == nil);
    bd.tl:SetShown(skinShown); bd.tr:SetShown(skinShown);
    bd.bl:SetShown(skinShown); bd.br:SetShown(skinShown);
    bd.t:SetShown(skinShown); bd.b:SetShown(skinShown);
    bd.l:SetShown(skinShown); bd.r:SetShown(skinShown);
    bd.bg:SetShown(skinShown);
    -- Themed windows show the class icon only as the circled portrait
    -- (below). Without the portrait layout the icon would extend past
    -- the window's top-left corner, over the chrome.
    --
    -- The chrome's visibility flips BEFORE the class-icon teardown on
    -- purpose: the UpdateIcon wrapper routes through the themed paint
    -- pass whenever the chrome is still shown, so a teardown repaint
    -- issued while the chrome was up re-applied the themed size and
    -- art it was trying to remove.
    if(obj.wimChrome) then
        obj.wimChrome:SetShown(chrome ~= nil);
        obj.wimChrome.well:SetShown(chrome ~= nil);
        if(obj.wimChrome.input) then
            obj.wimChrome.input:SetShown(chrome ~= nil);
        end
        if(obj.wimChrome.scrollBar) then
            obj.wimChrome.scrollBar:SetShown(chrome ~= nil);
        end
    end
    if(widgets.class_icon) then
        local hasPortrait = obj.wimChrome and obj.wimChrome.hasPortrait;
        widgets.class_icon:SetShown(skinShown or (chrome ~= nil and hasPortrait and true or false));
        if(skinShown and obj.wimPortraitMasked) then
            widgets.class_icon:RemoveMaskTexture(obj.wimPortraitMask);
            obj.wimPortraitMasked = nil;
        end
        -- Restore the construction-time size unless the classic skin
        -- sizes the widget itself; the skin pass reapplies points but
        -- SetWidgetRect only sizes widgets the skin table sizes, so
        -- the themed 56px would survive the switch back.
        if(skinShown and obj.wimIconBaseSize) then
            local widgetSkin = skin and skin.message_window
                and skin.message_window.widgets
                and skin.message_window.widgets.class_icon;
            if(not (widgetSkin and type(widgetSkin.width) == "number")) then
                widgets.class_icon:SetWidth(obj.wimIconBaseSize[1]);
            end
            if(not (widgetSkin and type(widgetSkin.height) == "number")) then
                widgets.class_icon:SetHeight(obj.wimIconBaseSize[2]);
            end
        end
        -- The lite paint pass leaves a per-class icon file at full
        -- texture coordinates on the widget. The classic skin pass
        -- restores the sheet texture but not the cell coordinates, so
        -- without a repaint the icon shows the whole sheet. The chrome
        -- is hidden above, so this repaint stays on the classic path.
        if(skinShown and obj.wimLitePainted) then
            obj.wimLitePainted = nil;
            obj:UpdateIcon();
        end
    end
    if(not chrome) then
        if(obj.wimBackdropLevel) then
            bd.bg:GetParent():SetFrameLevel(obj.wimBackdropLevel);
        end
        -- Classic skins take the input box back: out of the wrap-mode
        -- scroller, single-line again, with skin anchors and insets.
        if(obj.wimBoxInScroll or obj.wimBoxBaseInsets) then
            RestoreThemedInput(obj, false);
        end
        -- The skin pass resets these widgets, and this teardown runs
        -- last by design. UpdateCharDetails runs between the two, and
        -- its themed wrapper lays the header out again while the
        -- chrome is still shown. Return the header widgets to the
        -- skin's own geometry here.
        if(obj.wimFromBaseFont) then
            ApplySkinToWidget(widgets.chat_display);
            if(widgets.from) then
                ApplySkinToWidget(widgets.from);
            end
            if(widgets.char_info) then
                ApplySkinToWidget(widgets.char_info);
                widgets.char_info:SetSpacing(0);
            end
        end
        return;
    end

    -- The class icon, name, and details live on the Backdrop host
    -- frame, which shares a level with the chrome and would draw under
    -- its rock fill. Raise it while themed; the classic path above
    -- restores it.
    local backdropHost = bd.bg:GetParent();
    if(obj.wimBackdropLevel == nil) then
        obj.wimBackdropLevel = backdropHost:GetFrameLevel();
    end
    backdropHost:SetFrameLevel(obj:GetFrameLevel() + 2);

    -- Header layout baselines. The layouts derive geometry from the
    -- skin's own point data on every run, so repeated runs cannot
    -- drift. Only the fonts need to be captured.
    if(widgets.from) then
        -- The title band text uses the History Viewer's gold 12px
        -- style. This is the baseline size the fit shrinks from.
        local fontPath = _G.GameFontNormal:GetFont();
        widgets.from:SetTextColor(_G.GameFontNormal:GetTextColor());
        obj.wimFromBaseFont = { path = fontPath, size = 12, flags = "" };
    end
    if(widgets.char_info) then
        local path, size, flags = widgets.char_info:GetFont();
        if(path) then obj.wimInfoBaseFont = { path = path, size = size, flags = flags }; end
    end
    if(widgets.msg_box) then
        -- UpdateProps re-applies the saved window height. While the
        -- wrapped row holds borrowed height, that reset would leave
        -- the display lifted over a shorter window and shrink the
        -- message area. Add the borrowed height back after every
        -- reset.
        if(not obj.wimPropsWrapped) then
            obj.wimPropsWrapped = true;
            local origUpdateProps = obj.UpdateProps;
            obj.UpdateProps = function(self, ...)
                origUpdateProps(self, ...);
                -- The reset re-applied the saved height (custom-sized
                -- windows are left alone), which removed the borrowed
                -- height.
                if(not self.customSize) then
                    self.wimBorrowShown = 0;
                end
                local target = 0;
                if(self.wimBoxThemed and self.wimChrome
                        and self.wimChrome:IsShown()) then
                    target = ((self.wimInputRowH or 26) - 26) + WRAP_HEADROOM;
                end
                settleBorrow(self, target);
            end;
        end
        if(not obj.wimInputHooked) then
            obj.wimInputHooked = true;
            local function decor()
                UpdateThemedInputDecor(obj);
            end
            widgets.msg_box:HookScript("OnTextChanged", decor);
            widgets.msg_box:HookScript("OnEditFocusGained", decor);
            widgets.msg_box:HookScript("OnEditFocusLost", decor);
            -- Arrow keys scroll the box without a text change.
            widgets.msg_box:HookScript("OnCursorChanged", decor);
        end
    end
    if(not obj.wimHeaderSizeHooked) then
        obj.wimHeaderSizeHooked = true;
        obj:HookScript("OnSizeChanged", function(self)
            if(self.wimChrome and self.wimChrome:IsShown()) then
                LayoutThemedHeader(self);
                UpdateThemedInputDecor(self);
            end
        end);
    end
    if(not obj.wimCharDetailsWrapped) then
        obj.wimCharDetailsWrapped = true;
        local origUpdateCharDetails = obj.UpdateCharDetails;
        obj.UpdateCharDetails = function(self, ...)
            origUpdateCharDetails(self, ...);
            if(self.wimChrome and self.wimChrome:IsShown()) then
                LayoutThemedHeader(self);
            end
        end;
    end
    if(chrome.scrollBar) then
        local up, down = widgets.scroll_up, widgets.scroll_down;
        if(up and down) then
            styleWindowStepper(up, true);
            styleWindowStepper(down, false);
            up:ClearAllPoints();
            up:SetPoint("BOTTOM", chrome.scrollBar, "TOP", 0, 8);
            down:ClearAllPoints();
            down:SetPoint("TOP", chrome.scrollBar, "BOTTOM", 0, -8);
        end
    end

    -- The right-side column: the history shortcut at the top, the
    -- shortcut buttons stacked beneath it, all centered on one axis
    -- level with the message well's top. The shortcut container needs
    -- an explicit size; without one it collapses to zero width (its
    -- buttons span its edges) and the icons disappear.
    local history = widgets.history;
    local columnAnchor = chrome.well;
    if(history) then
        history:ClearAllPoints();
        history:SetPoint("TOP", chrome.well, "TOPRIGHT", 15, 0);
        columnAnchor = history;
    end
    if(widgets.shortcuts) then
        widgets.shortcuts:SetSize(22, 150);
        widgets.shortcuts:ClearAllPoints();
        if(columnAnchor == history) then
            widgets.shortcuts:SetPoint("TOP", history, "BOTTOM", 0, -4);
        else
            widgets.shortcuts:SetPoint("TOP", chrome.well, "TOPRIGHT", 15, 0);
        end
    end

    -- The class icon becomes the circled portrait in the carved
    -- corner, like the community icon on the Guild & Communities
    -- panel. The ring's opening is 49px across, centered at
    -- (26, -25.5) in window coordinates (measured from the corner
    -- piece's pixels). The icon draws slightly larger so it meets the
    -- ring's inner lip, and its texture cell zooms in past the cell's
    -- transparent padding so the emblem fills the circle.
    if(widgets.class_icon and chrome.hasPortrait) then
        local icon = widgets.class_icon;
        icon:ClearAllPoints();
        -- The ring's gold band has an inner diameter of about 53px,
        -- centered at (25.5, -22) in window coordinates (measured from
        -- the opaque runs along the corner piece's center row and
        -- column). The icon slightly overlaps the lip's anti-aliasing.
        icon:SetPoint("CENTER", obj, "TOPLEFT", 25.5, -22);
        -- The construction-time size comes from the window template,
        -- not the skin table, so the teardown must put it back itself
        -- (SetWidgetRect only sizes widgets the skin table sizes).
        if(not obj.wimIconBaseSize) then
            local baseWidth, baseHeight = icon:GetSize();
            obj.wimIconBaseSize = { baseWidth or 64, baseHeight or 64 };
        end
        -- The lite portrait may re-size the icon per paint (see
        -- LiteRepaintPortrait); this is the retail size and the lite
        -- starting point.
        icon:SetSize(56, 56);
        dPrint("ThemedPortrait "..(obj:GetName() or "?")
            ..": block sized 56, lite="..tostring(chrome.lite and true or false));
        if(not obj.wimPortraitMask) then
            local mask = icon:GetParent():CreateMaskTexture();
            -- CircleMaskScalable's circle reaches the mask's edges,
            -- while the portrait alpha-mask file has built-in padding
            -- that leaves the visible circle short of the ring. The
            -- atlas path is also the reliable one: a mask given the
            -- file id directly can report as attached yet fail to
            -- clip. The file id stays as the fallback.
            local usedAtlas = mask.SetAtlas
                and pcall(mask.SetAtlas, mask, "CircleMaskScalable")
                and mask:GetAtlas() ~= nil;
            if(not usedAtlas) then
                mask:SetTexture(3605349,
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
            end
            mask:SetAllPoints(icon);
            obj.wimPortraitMask = mask;
        end
        if(not obj.wimPortraitMasked) then
            icon:AddMaskTexture(obj.wimPortraitMask);
            obj.wimPortraitMasked = true;
        end
        if(not obj.wimUpdateIconWrapped) then
            obj.wimUpdateIconWrapped = true;
            local origUpdateIcon = obj.UpdateIcon;
            obj.UpdateIcon = function(self, ...)
                origUpdateIcon(self, ...);
                -- The selected-skin check keeps this off the themed
                -- path during a skin switch regardless of teardown
                -- ordering; the chrome's visibility alone lags it.
                if(self.wimChrome and self.wimChrome:IsShown()
                        and self.wimChrome.hasPortrait
                        and GetSelectedSkin().modernOnly) then
                    if(self.wimChrome.lite) then
                        LiteRepaintPortrait(self);
                    else
                        ZoomPortraitIcon(self);
                    end
                end
            end;
        end
        -- A full repaint, not just a zoom. The zoom multiplies the
        -- icon's current coordinates, so zooming an already-zoomed
        -- icon shrinks the emblem one step further on every settings
        -- change that reapplies the skin. The repaint resets the
        -- coordinates before the wrapper above zooms them once.
        obj:UpdateIcon();
    end


    local cutout = theme.chatCutout and true or false;
    chrome.bg:SetShown(not cutout);
    if(not cutout) then
        ApplyChromeBackgroundChoice(chrome.bg, theme.chatFrame);
    end
    for i=1, #chrome.strips do
        chrome.strips[i]:SetShown(cutout);
    end
    ApplyChromeBackgroundChoice(chrome.well.bg, theme.chatPanel);

    LayoutThemedInput(obj);
    LayoutThemedHeader(obj);

    -- Strips paint after the layout passes above settle their rects.
    if(cutout) then
        ApplyChromeBackgroundToStrips(chrome.strips, chrome.bg, theme.chatFrame);
    end

    -- The corner button: minimize glyph at rest, the X while SHIFT
    -- is held (see UpdateThemedCloseArt).
    UpdateThemedCloseArt(obj);
end

local function deleteStyleFileEntries(theTable)
    if(type(theTable) == "table") then
        for key, _ in pairs(theTable) do
            theTable[key] = nil;
        end
    end
end

function RegisterPrematureSkins()
    for i=1,#prematureRegisters do
        RegisterSkin(prematureRegisters[i]);
    end
end

function GetSelectedSkin()
    return SelectedSkin or SkinTable["WIM Classic"];
end

-- Only the modern options UI offers modern-only skins. While one is
-- selected, the options style must not switch back to classic, because
-- the classic window could never offer the skin again. Code that
-- changes the style checks this function.
function SkinLocksOptionsStyle()
    local skin = GetSelectedSkin();
    return (skin and skin.modernOnly) and true or false;
end

-- A skin's `title` doubles as its identity: RegisterSkin stores skins as
-- SkinTable[skinTable.title], and db.skin.selected persists that same string.
-- Upstream 3.17.2 localized the four classic colour variants
-- ("WIM Classic - Blue" -> "WIM Classic - "..L["Blue"]), which silently changes
-- the key on every non-English client: the saved selection no longer matches
-- anything in SkinTable and LoadSkin falls back to the base skin, quietly
-- discarding the user's choice. (English clients are unaffected, because
-- L["Blue"] returns "Blue", which is presumably why it went unnoticed.)
--
-- Map the pre-3.17.2 English titles onto whatever those skins are called now.
-- Keyed by colour so it stays correct whatever the active locale is.
local legacySkinTitles = {
    ["WIM Classic - Blue"]   = "Blue",
    ["WIM Classic - Green"]  = "Green",
    ["WIM Classic - Red"]    = "Red",
    ["WIM Classic - Yellow"] = "Yellow",
};

local function resolveSkinName(skinName)
    if(skinName == nil) then
        return nil;
    end
    if(SkinTable[skinName]) then
        return skinName;
    end
    local colour = legacySkinTitles[skinName];
    if(colour) then
        local localized = "WIM Classic - "..L[colour];
        if(SkinTable[localized]) then
            return localized;
        end
    end
    return nil;
end

function LoadSkin(skinName, immutableDB)
    skinName = resolveSkinName(skinName) or "WIM Classic";

    SelectedSkin = SkinTable[skinName];

    if not immutableDB then
        db.skin.selected = skinName;
    end;

    SKIN_DEBUG = SKIN_DEBUG..skinName.." loaded..\n";
    -- apply skin to window objects
    local window_objects = WindowSoupBowl.windows;
    for i=1, table.getn(window_objects) do
        ApplySkinToWindow(window_objects[i].obj);
    end

    ApplySkinToTabs();

	CallModuleFunction("OnSkinLoaded", SelectedSkin);

    -- The filter editor re-dresses with the skin regardless of whether
    -- the filtering modules are enabled (module dispatch above only
    -- reaches enabled modules).
    if(RestyleFilterFrame) then
        RestyleFilterFrame();
    end

    -- A modern-only skin requires the modern options UI (see
    -- SkinLocksOptionsStyle). Selecting one turns that UI on.
    if(SelectedSkin and SelectedSkin.modernOnly and db and not db.modernOptions
            and SetOptionsStyle) then
        SetOptionsStyle(true);
    end
end

function RegisterFont(objName, title)
    if(objName == nil or objName == "") then
        return;
    end
    if(title == nil or title == "") then
        title = objName
    end
    if(getglobal(objName)) then
        fontTable[objName] = title;
    else
        DEFAULT_CHAT_FRAME:AddMessage("WIM SKIN ERROR: Registered font object does not exist!");
    end
end


function RegisterSkin(skinTable)
    if(not isInitialized) then
        table.insert(prematureRegisters, skinTable);
        return;
    end
    local required = {"title", "author", "version"};
    local error_list = "";
    local addonName;

    local stack = {string.split("\n", debugstack())};
    if(table.getn(stack) >= 2) then
        local paths = {string.split("\\", stack[2])};
        addonName = paths[3];
    else
        addonName = "Unknown";
    end

    for i=1,table.getn(required) do
        if(skinTable[required[i]] == nil or skinTable[required[i]] == "") then error_list = error_list.."- Required field '"..required[i].."' was not defined.\n"; end
    end


    if(error_list ~= "") then
        SKIN_DEBUG = SKIN_DEBUG.."\n\n---------------------------------------------------------\nSKIN ERROR FROM: "..addonName.."\n---------------------------------------------------------\n";
        SKIN_DEBUG = SKIN_DEBUG.."Skin was not loaded for the following reason(s):\n\n"..error_list.."\n\n";
        return;
    end

	-- normalize all fonts
	for _, path in pairs(fontPaths) do
		local tbl = skinTable;
		for key in string.gmatch(path, "[^.]+") do
			if (key ~= "root") then
				if (tbl[key] == nil) then
					break;
				elseif (type(tbl[key]) == "table") then
					tbl = tbl[key];
				else
					tbl[key] = normalizeFont(tbl[key]);
					break;
				end
			end
		end
	end

    if(skinTable.title == "WIM Classic") then
        SkinTable[skinTable.title] = skinTable;
        if(skinTable.title == resolveSkinName(db.skin.selected)) then
            LoadSkin(WIM.db.skin.selected);
        end
        return; -- this is the main skin, we don't need to do anything further...
    end

    -- inherrit missing data from default skin.
    linkSkinTable(SkinTable["WIM Classic"], skinTable);

    -- finalize registration
    SkinTable[skinTable.title] = skinTable;

    -- if this is the selected skin, load it now
    if(skinTable.title == resolveSkinName(WIM.db.skin.selected)) then
        LoadSkin(WIM.db.skin.selected);
    end
end

function GetFontKeyByName(fontName)
	for key, val in pairs(fontTable) do
		if(val == fontName) then
			return key;
		end
	end
	return nil;
end


function SetWidgetFont(obj, widgetSkinTable)
    -- first check what font is being requested, height is applied here.
    if(widgetSkinTable.font) then
		local _font = (db.skin.suggest or not obj._allowCustomFont) and widgetSkinTable.font or db.skin.font or widgetSkinTable.font;

        if(_G[_font] and _G[_font].GetFont) then
            -- font is to be inherrited. The RESOLVED font must be used for
            -- both calls: taking the object from the skin and the family
            -- from ChatFontNormal would mean a custom font object never
            -- actually changes the rendered family.
            obj:SetFontObject(_G[_font]);
            local font, height, flags = _G[_font]:GetFont();
            obj:SetFont(font, widgetSkinTable.font_height or height, obj._font_flags or widgetSkinTable.font_flags or flags);
        elseif(libs.SML.MediaTable.font[_font]) then
			-- _G.DevTools_Dump({obj.widgetName ,_font, widgetSkinTable.font_height, obj._font_flags or widgetSkinTable.font_flags or ""});
            obj:SetFont(libs.SML.MediaTable.font[_font], widgetSkinTable.font_height or 12, obj._font_flags or widgetSkinTable.font_flags or "");
		elseif (type(_font) == "string" and _font:match("\\")) then
			-- font is a path to a font file
			obj:SetFont(_font, widgetSkinTable.font_height or 12, obj._font_flags or widgetSkinTable.font_flags or "");
		else
            -- can't find font, load a default font.
            local font, height, flags = _G["ChatFontNormal"]:GetFont();
            obj:SetFont(font, widgetSkinTable.font_height or 12, obj._font_flags or widgetSkinTable.font_flags or "");
        end
    end
    -- next, lets add the extra properties to it.
    if(widgetSkinTable.font_color) then
        if(type(widgetSkinTable.font_color) == "table") then
            obj:SetTextColor(unpack(widgetSkinTable.font_color));
        else
            obj:SetTextColor(RGBHexToPercent(widgetSkinTable.font_color));
        end
    end
end

function SetWidgetRect(obj, widgetSkinTable)
    if(type(widgetSkinTable) == "table") then
        if(type(widgetSkinTable.width) == "number") then
            obj:SetWidth(widgetSkinTable.width);
        end
        if(type(widgetSkinTable.height) == "number") then
            obj:SetHeight(widgetSkinTable.height);
        end
        if(widgetSkinTable.points) then
            setPointsToObj(obj, widgetSkinTable.points);
        end
    end
end

function ApplySkinToWidget(obj)
    if(obj.GetObjectType) then
        local SelectedSkin = GetSelectedSkin();
        local widgetSkin = SelectedSkin.message_window.widgets[obj.widgetName] or obj.defaultSkin;
        local oType = obj:GetObjectType();
        SetWidgetRect(obj, widgetSkin);
        if(oType == "Button" or oType == "CheckButton") then
            if(widgetSkin.NormalTexture) then obj:SetNormalTexture(widgetSkin.NormalTexture); end
            if(widgetSkin.PushedTexture) then obj:SetPushedTexture(widgetSkin.PushedTexture); end
            if(widgetSkin.DisabledTexture) then obj:SetDisabledTexture(widgetSkin.DisabledTexture); end
            if(widgetSkin.HighlightTexture) then obj:SetHighlightTexture(widgetSkin.HighlightTexture, widgetSkin.HighlightAlphaMode); end
        end
        if(oType == "FontString" or oType == "ScrollingMessageFrame" or oType == "EditBox" or (oType == "Frame" and obj.AddMessage)) then
            SetWidgetFont(obj, widgetSkin);
        end
    else
        dPrint("Invalid widget trying to be skinned.");
    end
    if(obj.UpdateSkin) then
        obj:UpdateSkin();
    end
end

function GetSkinTable(skinName)
    return SkinTable[skinName];
end

function GetRegisteredSkins(includeModernOnly)
    -- this function isn't called much so its ok to create a little garbage.
    local list = {};
    local selected = GetSelectedSkin().title;
    for skin, skinTable in pairs(SkinTable) do
        -- Skins flagged modernOnly appear only when the caller asks for
        -- them (the modern options UI). Other callers still see such a
        -- skin while it is the active selection, so their dropdown
        -- always shows the current state correctly.
        if(includeModernOnly or not skinTable.modernOnly or skin == selected) then
            table.insert(list, skin);
        end
    end
    table.sort(list);
    return list;
end
