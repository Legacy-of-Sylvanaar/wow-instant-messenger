--[[
This file contains hooks which are required by WIM's core.
Module specific hooks are found within it's own files.
]]



function WIM.getVisibleChatFrameEditBox()
    -- for eb in pairs(Hooked_ChatFrameEditBoxes) do
    --     if _G[eb]:wimIsVisible() then
    --         return _G[eb];
    --     end
    -- end
end


-------------------------------------------------------------------------------------------

-- -- Dri: workaround for WoW build15050 whisper bug when x-realm server name contains a space.
-- if ChatFrameUtil.SendTell then
-- 	local origSendTell = ChatFrameUtil.SendTell
-- 	-- ChatFrameUtil.SendTell = function(name, chatFrame, ...)
-- 	-- 	name = gsub(name," ","")
-- 	-- 	origSendTell(name, chatFrame, ...)
-- 	-- end
-- else
-- 	local origChatFrame_SendTell = _G.ChatFrame_SendTell
-- 	_G.ChatFrame_SendTell = function(name, chatframe, ...)
-- 		name = gsub(name," ","")
-- 		origChatFrame_SendTell(name, chatframe, ...)
-- 	end
-- end


if _G.ChatFrameUtil and _G.ChatFrameUtil.InsertLink then
	hooksecurefunc(
		_G.ChatFrameUtil and _G.ChatFrameUtil.InsertLink and _G.ChatFrameUtil or _G,
		_G.ChatFrameUtil and _G.ChatFrameUtil.InsertLink and "InsertLink" or "ChatEdit_InsertLink",
		function(text)
			if not WIM.EditBoxInFocus or not text then return end

			WIM.EditBoxInFocus:Insert(text);
		end
	);
end
