local WIM = WIM;

local DDM = WIM.libs.DropDownMenu;
DDM.SOUNDKIT = SOUNDKIT -- temporary fix until LibDropDownMenu is patched

-- imports
local _G = _G;
local table = table;
local string = string;
local pairs = pairs;
local type = type;
local pcall = pcall;
local UIDropDownMenu_AddButton = DDM.UIDropDownMenu_AddButton;
local UIDropDownMenu_CreateInfo = DDM.UIDropDownMenu_CreateInfo
local UIDropDownMenu_Initialize = DDM.UIDropDownMenu_Initialize;
local ToggleDropDownMenu = DDM.ToggleDropDownMenu;

-- set namespace
setfenv(1, WIM);

local menuFrame = DDM.Create_DropDownMenu("WIM3_ContextMenu", _G.UIParent)
menuFrame:SetParent(_G.UIParent);
menuFrame:SetPoint("TOP", -80, -200);
menuFrame:Hide();

 ctxMenu = {};

local MENU_ID = 0;

local CurMenu;

local function getMenuByTitle(text)
    for key, val in pairs(ctxMenu) do
        if(val.text == text) then
            return key;
        end
    end
    return;
end

local function addMenuItem(tag, info)
    -- required checks
    if(type(info) ~= "table" and not info.text) then
        if(type(tag) == "table" and tag.text) then
            MENU_ID = MENU_ID + 1;
            return addMenuItem("MENU_ITEM"..MENU_ID, tag);
        else
            return;
        end
    end
    if(type(tag) ~= "string") then
        return;
    end
    if(tag == "") then
        MENU_ID = MENU_ID + 1;
        return addMenuItem("MENU_ITEM"..MENU_ID, info);
    end
    if(ctxMenu[string.upper(tag)]) then
        return ctxMenu[string.upper(tag)];
    end

    -- propper formatting
    tag = string.upper(tag);

    -- load data into its own table. we will send this back to the user later.
    local item = {};
    for key, val in pairs(info) do
        item[key] = val;
    end

    ctxMenu[tag] = item;
    item.MENU_ID = tag;

    item.AddSubItem = function(self, menuItem, insertAt)
        if(type(menuItem) == "string") then
            menuItem = ctxMenu[string.upper(menuItem)];
            if(not menuItem) then
                return;
            end
        end
        if(not (type(menuItem) == "table" and menuItem.MENU_ID)) then
            return;
        end

        if(not self.menuTable) then
            self.menuTable = {};
        end
        if(insertAt) then
            table.insert(self.menuTable, insertAt, menuItem.MENU_ID);
        else
            table.insert(self.menuTable, menuItem.MENU_ID);
        end
        self.hasArrow = true;
        self.value = self.MENU_ID;
        return true;
    end
    return item;
end

local function initializeMenu(frame, level, menuTable)
    level = level or DDM.UIDROPDOWNMENU_MENU_LEVEL;
    if(level > 1 and DDM.UIDROPDOWNMENU_MENU_VALUE) then
        CurMenu = ctxMenu[DDM.UIDROPDOWNMENU_MENU_VALUE];
    end
    if(not CurMenu) then
        dPrint("ContextMenu Error - Menu not set.");
        return; -- menu not set
    end
    dPrint("Initializing Menu - level "..level);
    local items = CurMenu.menuTable;
    if(not items) then
        return;
    end
    for i=1, #items do
        local info = {};
        for key, val in pairs(ctxMenu[items[i]]) do
            info[key] = val;
        end
        -- hidden may be a function, so visibility can depend on live
        -- state (the options-style toggle hides while a modern-only
        -- skin is active).
        local hidden = ctxMenu[items[i]].hidden;
        if(type(hidden) == "function") then hidden = hidden(); end
        if(not hidden) then
            if(type(info.hidden) == "function") then info.hidden = nil; end
            UIDropDownMenu_AddButton(info, level);
        end
    end
end

-- Renders a registered menu tree through the game's Menu API instead
-- of LibDropDownMenu, drawing the chamfered context-menu frame current
-- right-click menus use. Chosen by PopContextMenu when the selected
-- skin asks for it (skin.menu.style == "context").
local function describeItems(menu, description)
    local items = menu.menuTable;
    if(not items) then return; end
    for i=1, #items do
        local item = ctxMenu[items[i]];
        local hidden = item.hidden;
        if(type(hidden) == "function") then hidden = hidden(); end
        if(not hidden) then
            if(item.isTitle) then
                if(item.text == nil or item.text == "") then
                    description:CreateDivider();
                else
                    description:CreateTitle(item.text);
                end
            elseif(item.menuTable) then
                local sub = description:CreateButton(item.text,
                    item.func or function() end);
                describeItems(item, sub);
            elseif(item.checked ~= nil and not item.notCheckable) then
                description:CreateCheckbox(item.text,
                    function()
                        if(type(item.checked) == "function") then
                            return item.checked() and true or false;
                        end
                        return item.checked and true or false;
                    end,
                    function()
                        if(item.func) then item.func(); end
                    end);
            else
                description:CreateButton(item.text, function()
                    if(item.func) then item.func(); end
                end);
            end
        end
    end
end


-- global API

-- Chooses which way a menu should grow so it opens toward the screen
-- center: returns the menu's own corner and the owner corner to attach
-- it to, based on the owner's screen quadrant.
function GetMenuGrowthAnchor(region)
    if(not region or not region.GetCenter) then
        return "TOPLEFT", "BOTTOMRIGHT";
    end
    local x, y = region:GetCenter();
    if(not x) then
        return "TOPLEFT", "BOTTOMRIGHT";
    end
    local scale = region:GetEffectiveScale() / _G.UIParent:GetEffectiveScale();
    x, y = x * scale, y * scale;
    local vert = (y > _G.UIParent:GetHeight() / 2) and "TOP" or "BOTTOM";
    local horiz = (x > _G.UIParent:GetWidth() / 2) and "RIGHT" or "LEFT";
    local oppVert = (vert == "TOP") and "BOTTOM" or "TOP";
    local oppHoriz = (horiz == "RIGHT") and "LEFT" or "RIGHT";
    return vert..horiz, oppVert..oppHoriz;
end

function PopContextMenu(tag, parent)
    if(type(tag) ~= "string") then
        return;
    end
    tag = string.upper(tag);

    local id = ctxMenu[tag];
    if(id) then
        dPrint("Popping menu ["..tag.."]");
        if(WIM.Menu) then
            WIM.Menu:Hide();
        end
        local skin = GetSelectedSkin and GetSelectedSkin();
        if(skin and skin.menu and skin.menu.style == "context"
                and _G.MenuUtil and _G.MenuUtil.CreateContextMenu) then
            DDM.CloseDropDownMenus();
            local owner = parent;
            if(type(owner) == "string") then owner = _G[owner]; end
            if(PadModernMenus and owner) then
                PadModernMenus(owner);
            end
            -- The returned frame is kept reachable for /wim snap, as
            -- the styling reference for WIM's own menus (the pooled
            -- frame persists, configured, after the menu closes).
            _G.WIM_LastModernMenu = _G.MenuUtil.CreateContextMenu(
                owner or _G.UIParent,
                function(_, rootDescription)
                    if(DarkenModernMenusOnAcquire) then
                        DarkenModernMenusOnAcquire(rootDescription);
                    end
                    describeItems(id, rootDescription);
                end);
            -- The menu compositor strips its visual art when a menu is
            -- released to the pool, so a useful capture must run while
            -- the menu is open (/wim snapmenu arms this).
            if(snapNextMenu) then
                snapNextMenu = nil;
                _G.C_Timer.After(0.2, function()
                    if(SnapshotTarget) then
                        SnapshotTarget("WIM_LastModernMenu");
                    end
                end);
            end
            -- Reattach so the menu grows toward the screen center
            -- instead of the manager's default direction.
            local menu = _G.WIM_LastModernMenu;
            if(menu and menu.ClearAllPoints and owner) then
                local point, relPoint = GetMenuGrowthAnchor(owner);
                pcall(function()
                    menu:ClearAllPoints();
                    menu:SetPoint(point, owner, relPoint);
                end);
            end
            -- Clients that paint the classic-styled menu variants
            -- remap to the retail art where they have it.
            if(DarkenModernMenus) then
                DarkenModernMenus(menu);
            end
            _G.PlaySound(1115);
            return;
        end
        DDM.CloseDropDownMenus();
        CurMenu = id;
        DDM.UIDROPDOWNMENU_MENU_VALUE = nil;
        UIDropDownMenu_Initialize(menuFrame, initializeMenu);
        ToggleDropDownMenu(1, 1, menuFrame, parent, 0, 0);
        DDM.UIDropDownMenu_SetButtonWidth(menuFrame, 25);
		DDM.UIDropDownMenu_SetWidth(menuFrame, 25, 5);
        _G.PlaySound(1115);
    else
        dPrint("Menu ["..tag.."] not found!")
    end
end

function AddContextMenu(tag, info)
    local item = addMenuItem(tag, info)
    if(item) then
        dPrint("Menu ["..item.MENU_ID.."] registered with ContextMenu.");
    else
        dPrint("Menu failed to register with ContextMenu.")
    end
    return item;
end

function GetContextMenu(tag)
    return ctxMenu[tag or "<NIL>"];
end

