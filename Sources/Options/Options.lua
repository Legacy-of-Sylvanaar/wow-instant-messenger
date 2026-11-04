-- imports
local WIM = WIM;
local _G = _G;

-- set namespace
setfenv(1, WIM);

options = {}; -- reference to the options interface

-- Hairline backdrop shared by the History Viewer, the filter editor and
-- the options plates.
function options.AddFramedBackdrop(obj)
    obj.backdrop = {};
    obj.backdrop.top = obj:CreateTexture(nil, "BACKGROUND");
    obj.backdrop.top:SetColorTexture(1, 1, 1, .25);
    obj.backdrop.top:SetPoint("TOPLEFT",-1 , 1);
    obj.backdrop.top:SetPoint("TOPRIGHT",1 , 1);
    obj.backdrop.top:SetHeight(1);
    obj.backdrop.bottom = obj:CreateTexture(nil, "BACKGROUND");
    obj.backdrop.bottom:SetColorTexture(1, 1, 1, .25);
    obj.backdrop.bottom:SetPoint("BOTTOMLEFT",-1 , -1);
    obj.backdrop.bottom:SetPoint("BOTTOMRIGHT",1 , -1);
    obj.backdrop.bottom:SetHeight(1);
    obj.backdrop.left = obj:CreateTexture(nil, "BACKGROUND");
    obj.backdrop.left:SetColorTexture(1, 1, 1, .25);
    obj.backdrop.left:SetPoint("TOPLEFT", obj.backdrop.top, "BOTTOMLEFT" ,0 , 0);
    obj.backdrop.left:SetPoint("BOTTOMLEFT", obj.backdrop.bottom, "TOPLEFT" ,0 , 0);
    obj.backdrop.left:SetWidth(1);
    obj.backdrop.right = obj:CreateTexture(nil, "BACKGROUND");
    obj.backdrop.right:SetColorTexture(1, 1, 1, .25);
    obj.backdrop.right:SetPoint("TOPRIGHT", obj.backdrop.top, "BOTTOMRIGHT" ,0 , 0);
    obj.backdrop.right:SetPoint("BOTTOMRIGHT", obj.backdrop.bottom, "TOPRIGHT" ,0 , 0);
    obj.backdrop.right:SetWidth(1);
    obj.backdrop.bg = obj:CreateTexture(nil, "BACKGROUND");
    obj.backdrop.bg:SetColorTexture(0, 0, 0, .25);
    obj.backdrop.bg:SetAllPoints();
end

-- WIM.ShowOptions()
-- Single entry point used by /wim, the key binding and the minimap menu:
-- opens WIM's category in the native Settings panel (Options > AddOns).
function ShowOptions()
    if(not options.modernCategoryID) then
        _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: the options UI is not available on this client."]);
        return;
    end
    if(_G.InCombatLockdown()) then
        -- Settings.OpenToCategory reaches the protected OpenSettingsPanel(),
        -- which the client blocks for addon code during combat (the panel
        -- itself may be open in combat -- only the addon-initiated open is
        -- protected). Queue the open for end of combat; asking again while
        -- queued cancels, so a stray click doesn't ambush the user with a
        -- fullscreen panel after the fight.
        if(options._pendingModernOpen) then
            options._pendingModernOpen = nil;
            _G.DEFAULT_CHAT_FRAME:AddMessage(L["WIM: queued options open canceled."]);
            return;
        end
        options._pendingModernOpen = true;
        if(not options._modernOpenWaiter) then
            local waiter = _G.CreateFrame("Frame");
            options._modernOpenWaiter = waiter;
            waiter:SetScript("OnEvent", function(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED");
                if(options._pendingModernOpen) then
                    options._pendingModernOpen = nil;
                    _G.Settings.OpenToCategory(options.modernCategoryID);
                end
            end);
        end
        options._modernOpenWaiter:RegisterEvent("PLAYER_REGEN_ENABLED");
        _G.DEFAULT_CHAT_FRAME:AddMessage(
            "WIM: the game's Settings panel cannot be opened during combat - it will open when combat ends.");
        return;
    end
    options._pendingModernOpen = nil;
    _G.Settings.OpenToCategory(options.modernCategoryID);
end

RegisterSlashCommand("options", ShowOptions, L["Display WIM's options."]);
RegisterSlashCommand("reset", function()
                _G.StaticPopupDialogs["WIM_RESET_DEFAULTS"] = {
                	preferredIndex = _G.STATICPOPUP_NUMDIALOGS,
                    text = L["Resetting WIM will clear all of your settings!"].."\n"..L["A reset will reload your user interface."].."\n"..L["Do you want to continue?"],
                    button1 = _G.YES,
                    button2 = _G.NO,
                    OnAccept = function()
                        _G.WIM3_Data = nil;
                        _G.ReloadUI();
                    end,
                    timeout = 0,
                    whileDead = 1,
                    hideOnEscape = 1
                };
                _G.StaticPopup_Show ("WIM_RESET_DEFAULTS");
            end, L["Reset all options to default."]);
