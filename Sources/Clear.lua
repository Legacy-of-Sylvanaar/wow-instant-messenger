-- handles slash commands for clearing various data such as history and filters.

local L = WIM.L;
local CommandListRaw = {"history", "filters"};

-- The dialog's button and edit box, across the client generations
-- (accessor methods on current clients, keyed fields or named children
-- on older ones).
local function popupButton1(dialog)
    if (dialog.GetButton1) then return dialog:GetButton1(); end
    return dialog.button1 or _G[dialog:GetName().."Button1"];
end

local function popupEditBox(dialog)
    if (dialog.GetEditBox) then return dialog:GetEditBox(); end
    return dialog.EditBox or dialog.editBox or _G[dialog:GetName().."EditBox"];
end

-- Wiping history is account-wide and irreversible, so the dialog
-- follows the game's own pattern for destroying a valuable item: the
-- confirm button stays disabled until the word DELETE is typed.
function WIM.ShowClearHistoryPopup()
    local confirmWord = DELETE_ITEM_CONFIRM_STRING or "DELETE";
    local function typedConfirm(editBox)
        return string.upper(editBox:GetText() or "") == confirmWord;
    end
    StaticPopupDialogs["WIM_CLEAR_HISTORY"] = {
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        text = L["You are about to permanently delete WIM's message history for every character on this account."]
            .."\n\n"..L["This action will reload your user interface."]
            .."\n\n"..string.format(L["Type %s to confirm."], confirmWord),
        button1 = DELETE or L["Delete"],
        button2 = CANCEL,
        hasEditBox = 1,
        maxLetters = 32,
        showAlert = 1,
        OnShow = function(self)
            local button = popupButton1(self);
            if (button) then button:Disable(); end
            local editBox = popupEditBox(self);
            if (editBox) then
                editBox:SetText("");
                editBox:SetFocus();
            end
        end,
        OnHide = function(self)
            local editBox = popupEditBox(self);
            if (editBox) then editBox:SetText(""); end
        end,
        EditBoxOnTextChanged = function(self)
            local button = popupButton1(self:GetParent());
            if (button) then
                button:SetEnabled(typedConfirm(self));
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local dialog = self:GetParent();
            if (typedConfirm(self)) then
                if (StaticPopup_OnClick) then
                    StaticPopup_OnClick(dialog, 1);
                else
                    local button = popupButton1(dialog);
                    if (button) then button:Click(); end
                end
            end
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
        OnAccept = function()
            -- History now lives in several places -- the account-wide
            -- blob archive, this character's own per-character file, and the
            -- legacy holding pen. All of them must go, or the archive (or a
            -- leftover legacy table) would repopulate the viewer on reload.
            WIM3_History = nil;
            WIM3_HistoryArchive = nil;
            WIM3_HistorySchema = nil;
            ReloadUI();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    };
    StaticPopup_Show ("WIM_CLEAR_HISTORY");
end

local function clearFun(sub)
    sub = string.trim(string.lower(sub));
    if(sub == "history") then
        WIM.ShowClearHistoryPopup();
    elseif(sub == "filters") then
        StaticPopupDialogs["WIM_CLEAR_FILTERS"] = {
        	preferredIndex = STATICPOPUP_NUMDIALOGS,
            text = L["You are about to restore WIM's filters to it's default settings!"].."\n"..L["This action will reload your user interface."].."\n"..L["Do you want to continue?"],
            button1 = _G.YES,
            button2 = _G.NO,
            OnAccept = function()
                WIM3_Filters = nil;
                WIM3_ChatFilters = nil;
                ReloadUI();
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        };
        StaticPopup_Show ("WIM_CLEAR_FILTERS");
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0"..L["Usage"]..":|r  ".."/wim clear {"..string.lower(table.concat(CommandListRaw, " | ")).."}");
    end
end

WIM.RegisterSlashCommand("clear", clearFun, L["Clear various WIM data."])
