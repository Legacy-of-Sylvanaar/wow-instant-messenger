--[[
This file contains hooks which are required by WIM's core.
Module specific hooks are found within it's own files.
]]


-------------------------------------------------------------------------------------------
-- The following hooks will account for anything that is being inserted into default chat frame and
-- spoofs other callers into thinking that they are actually linking into the chat frame.
--DEFAULT_CHAT_FRAME.editBox

local Hooked_ChatFrameEditBoxes = {};

-- may no longer be needed.... not sure of other addons depend on it...
local function hookChatFrameEditBox(editBox)
    if(editBox and not Hooked_ChatFrameEditBoxes[editBox:GetName()]) then
        hooksecurefunc(editBox, "Insert", function(self,theText)
				if(WIM.EditBoxInFocus) then
					WIM.EditBoxInFocus:Insert(theText);
				end
			end )


        editBox.wimIsVisible = editBox.IsVisible;
        editBox.IsVisible = function(self)
				if(WIM.EditBoxInFocus) then
					return true;
				else
					return self:wimIsVisible();
				end
			end
        editBox.wimIsShown = editBox.IsShown;
        editBox.IsShown = function(self)
				if(WIM.EditBoxInFocus) then
					return true;
				else
					return self:wimIsShown();
				end
			end

        -- can not hook GetText() because it taints the chat bar. Breaks /tar
        hooksecurefunc(editBox, "SetText", function(self,theText)
				local firstChar = "";
				--if a slash command is being set, ignore it. Let WoW take control of it.
				if(string.len(theText) > 0) then firstChar = string.sub(theText, 1, 1); end
				if(WIM.EditBoxInFocus and firstChar ~= "/") then
					WIM.EditBoxInFocus:SetText(theText);
				end
			end );
        editBox.wimHighlightText = editBox.HighlightText;
        editBox.HighlightText = function(self, theStart, theEnd)
				if(WIM.EditBoxInFocus) then
					WIM.EditBoxInFocus:HighlightText(theStart, theEnd);
				else
					self:wimHighlightText(theStart, theEnd);
				end
			end
        Hooked_ChatFrameEditBoxes[editBox:GetName()] = true;
    end
end

if ChatFrameUtil and ChatFrameUtil.ActivateChat then
	hooksecurefunc(ChatFrameUtil, "ActivateChat", function(editBox)
		hookChatFrameEditBox(editBox);
	end);
else
	hooksecurefunc("ChatEdit_ActivateChat", function(editBox)
        hookChatFrameEditBox(editBox);
    end);
end


function WIM.getVisibleChatFrameEditBox()
    for eb in pairs(Hooked_ChatFrameEditBoxes) do
        if _G[eb]:wimIsVisible() then
            return _G[eb];
        end
    end
end


-------------------------------------------------------------------------------------------

-- linking hooks
if ChatFrameUtil and ChatFrameUtil.GetActiveWindow then
	ChatFrameUtil.GetActiveWindow_orig = ChatFrameUtil.GetActiveWindow
	ChatFrameUtil.GetActiveWindow = function()
		return WIM.EditBoxInFocus or ChatFrameUtil.GetActiveWindow_orig();
	end
else
	local ChatEdit_GetActiveWindow_orig = ChatEdit_GetActiveWindow;
	function ChatEdit_GetActiveWindow()
		return WIM.EditBoxInFocus or ChatEdit_GetActiveWindow_orig();
	end
end


-- --ItemRef Definitions
-- local registeredItemRef = {};
-- function WIM.RegisterItemRefHandler(cmd, fun)
--     registeredItemRef[cmd] = fun;
-- end

-- if (ItemRefTooltipMixin and ItemRefTooltipMixin.SetHyperlink) then
-- 	local ItemRefTooltipMixin_SetHyperlink_orig = ItemRefTooltipMixin.SetHyperlink;
-- 	ItemRefTooltipMixin.SetHyperlink = function (self, ...)
-- 		for cmd, fun in pairs(registeredItemRef) do
-- 			if(string.match(link, "^"..cmd..":")) then
-- 				fun(link);
-- 				return;
-- 			end
-- 		end
-- 		ItemRefTooltipMixin_SetHyperlink_orig(self, ...);
-- 	end
-- else
-- 	local ItemRefTooltip_SetHyperlink = ItemRefTooltip.SetHyperlink;
-- 	ItemRefTooltip.SetHyperlink = function(self, link)
-- 		for cmd, fun in pairs(registeredItemRef) do
-- 			if(string.match(link, "^"..cmd..":")) then
-- 				fun(link);
-- 				return;
-- 			end
-- 		end
-- 		ItemRefTooltip_SetHyperlink(self, link);
-- 	end
-- end


-- Dri: workaround for WoW build15050 whisper bug when x-realm server name contains a space.
if ChatFrameUtil.SendTell then
	local origSendTell = ChatFrameUtil.SendTell
	ChatFrameUtil.SendTell = function(name, chatFrame, ...)
		name = gsub(name," ","")
		origSendTell(name, chatFrame, ...)
	end
else
	local origChatFrame_SendTell = _G.ChatFrame_SendTell
	_G.ChatFrame_SendTell = function(name, chatframe, ...)
		name = gsub(name," ","")
		origChatFrame_SendTell(name, chatframe, ...)
	end
end

