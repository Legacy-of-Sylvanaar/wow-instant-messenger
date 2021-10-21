--imports
local WIM = WIM;
local _G = _G;
local string = string;
local tostring = tostring;
local getn = getn;


-- needed for tutorials
local MAX_TUTORIAL_VERTICAL_TILE = 30;
local MAX_TUTORIAL_IMAGES = 3;
local MAX_TUTORIAL_KEYS = 4;

local TUTORIALFRAME_TOP_HEIGHT = 80;
local TUTORIALFRAME_MIDDLE_HEIGHT = 10;
local TUTORIALFRAME_BOTTOM_HEIGHT = 30;
local TUTORIALFRAME_WIDTH = 364;

--set namespace
setfenv(1, WIM);

db_defaults.shownTutorials = {};

local Tutorials = CreateModule("Tutorials", true);

local function varFriendly(var)
    var = string.gsub(var, "[^%w_]", "_");
    return var;
end

local theButton;

local _FlagTutorial = _G.FlagTutorial;
function _G.FlagTutorial(id)
    local tut = string.match(tostring(id), "^WIM(.+)");
    if(tut) then
        if(tut ~= varFriendly(L["WIM Update Available!"])) then
            db.shownTutorials[tut] = true;
        end
    else
        _FlagTutorial(id);
    end
end


local function setWIMorBlizzard(wim)
    local alert = _G.TutorialFrameAlertButton;
    if(wim) then
        _G.TutorialFrameTop:SetTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Modules\\Textures\\UI-TUTORIAL-FRAME");
        _G.TutorialFrameBottom:SetTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Modules\\Textures\\UI-TUTORIAL-FRAME");
        alert:SetNormalTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Modules\\Textures\\UI-TUTORIAL-FRAME");
        alert:SetHighlightTexture("Interface\\AddOns\\"..WIM.addonTocName.."\\Modules\\Textures\\UI-TUTORIAL-FRAME");
    else
        _G.TutorialFrameTop:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
        _G.TutorialFrameBottom:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
        alert:SetNormalTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
        alert:SetHighlightTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
    end
end

local function createChangelogButton()
    local button = _G.CreateFrame("Button", "WIM_TutorialButtonChangeLog", _G.TutorialFrame, "UIPanelButtonTemplate");
    local ok = _G.TutorialFrameOkayButton;
    button:SetPoint("BOTTOM", 0, 40);
    button:SetHeight(22);
    button:SetNormalTexture("DialogButtonNormalTexture");
    button:SetPushedTexture("DialogButtonPushedTexture");
    button:SetHighlightTexture("DialogButtonHighlightTexture");
    button:SetDisabledTexture("DialogButtonDisabledTexture");
    _G.WIM_TutorialButtonChangeLogText:SetText(L["View Updates"]);
    button:SetNormalFontObject("GameFontNormalSmall");
    button:SetHighlightFontObject("GameFontNormalSmall");
    button:SetDisabledFontObject("GameFontNormalSmall");
    button:SetWidth(_G.WIM_TutorialButtonChangeLogText:GetStringWidth()+30)
    button:Hide();
    button:SetScript("OnClick", ShowChangeLog);

    return button;
end

local function displayTutorial(title, tutorial)
    local var = varFriendly(title);
    if(not db.shownTutorials[var] or L["WIM Update Available!"] == title) then
        db.shownTutorials[var] = true;
        theButton = theButton or createChangelogButton();
        _G["TUTORIAL_TITLEWIM"..var] = title;
        _G["TUTORIALWIM"..var] = tutorial;
        _G.TutorialFrame_NewTutorial("WIM"..var);
    end
end

function Tutorials:OnEnable()
    DisplayTutorial = displayTutorial;
end

function Tutorials:OnDisable()
    -- to decrease table lookups, we can just define the function as such.
    DisplayTutorial = function() end;
end



local _IsTutorialFlagged = _G.IsTutorialFlagged;
function _G.IsTutorialFlagged(id)
    if(string.match(id, "^[0-9]+$")) then
        --Blizzard Tutorial, resume...
        return _IsTutorialFlagged(id);
    else
        -- WIM Tutorial
        return false;
    end
end

local ARROW_TYPES = {
	"ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight",
	"ArrowCurveUpRight", "ArrowCurveUpLeft", "ArrowCurveDownRight", "ArrowCurveDownLeft",
	"ArrowCurveRightDown", "ArrowCurveRightUp", "ArrowCurveLeftDown", "ArrowCurveLeftUp",
}

local ARROW_SIZES = {
	["ArrowUp"] = {x = 68, y = 89},
	["ArrowDown"] = {x = 68, y = 89},
	["ArrowLeft"] = {x = 89, y = 68},
	["ArrowRight"] = {x = 89, y = 68},
	["ArrowCurveUpRight"] = {x = 66, y = 81},
	["ArrowCurveUpLeft"] = {x = 66, y = 81},
	["ArrowCurveDownRight"] = {x = 66, y = 81},
	["ArrowCurveDownLeft"] = {x = 66, y = 81},
	["ArrowCurveRightDown"] = {x = 82, y = 66},
	["ArrowCurveRightUp"] = {x = 82, y = 66},
	["ArrowCurveLeftDown"] = {x = 82, y = 66},
	["ArrowCurveLeftUp"] = {x = 82, y = 66},
}

local MOUSE_SIZE = { x = 76, y = 101}

local TUTORIAL_QUEST_ARRAY = {
	["HUMAN"] = {questID = 7, displayNPC = 197},
	["DWARF"] = {questID = 7},
	["NIGHTELF"] = {questID = 7},
	["GNOME"] = {questID = 7},
	["DRAENEI"] = {questID = 7},
	["WORGEN"] = {questID = 7},
	["ORC"] = {questID = 7},
	["SCOURGE"] = {questID = 7},
	["TAUREN"] = {questID = 7},
	["TROLL"] = {questID = 7},
	["BLOODELF"] = {questID = 7},
	["GOBLIN"] = {questID = 7},
};

local DISPLAY_DATA = {
    ["Base"] = {
		tileHeight = 10,
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
    },
};

local TUTORIAL_HISTORY = {};

-- Tutorial Frame Hook used to implement WIM custom Tutorials.
local _TutorialFrame_Update = _G.TutorialFrame_Update;
function _G.TutorialFrame_Update(currentTutorial)
    if(theButton) then
        theButton:Hide();
    end
    WIM.addToTableUnique(TUTORIAL_HISTORY, currentTutorial);
    if(string.match(currentTutorial, "^[0-9]+$")) then
        --Blizzard Tutorial, resume...
        dPrint("Blizzard Tutorial ID: "..currentTutorial);
        setWIMorBlizzard(false);
        _TutorialFrame_Update(currentTutorial);
    else
        -- WIM Tutorial
        dPrint("WIM Tutorial ID: "..currentTutorial);
        setWIMorBlizzard(true);
        _G.FlagTutorial(currentTutorial);
	_G.TutorialFrame.id = currentTutorial;

	local displayData = DISPLAY_DATA[ currentTutorial ];
	if ( not displayData ) then
		displayData = DISPLAY_DATA["Base"];
	end

	-- setup the frame
	_G.TutorialFrame_ClearTextures();
	if (displayData.anchorData) then
		local anchorData = displayData.anchorData;
		_G.TutorialFrame:SetPoint( anchorData.align, _G.UIParent, anchorData.align, anchorData.xOff, anchorData.yOff );
	end

	if (displayData.tileHeight == 0) then
		_G.TutorialFrameTop:Hide();
		_G.TutorialFrameLeft1:Hide();
		_G.TutorialFrameRight1:Hide();
		_G.TutorialFrameBottom:Hide();
		_G.TutorialFrameBackground:Hide();
		_G.TutorialFrameCloseButton:Hide();
		_G.TutorialFrameOkayButton:Hide();
		_G.TutorialFramePrevButton:Hide();
		_G.TutorialFrameNextButton:Hide();
		_G.TutorialFrame:SetSize(1024, 768);
	else
		_G.TutorialFrameTop:Show();
		_G.TutorialFrameLeft1:Show();
		_G.TutorialFrameRight1:Show();
		_G.TutorialFrameBottom:Show();
		_G.TutorialFrameBackground:Show();
		_G.TutorialFrameCloseButton:Show();
		_G.TutorialFrameOkayButton:Show();
		_G.TutorialFramePrevButton:Show();
		_G.TutorialFrameNextButton:Show();
		local anchorParentLeft = _G.TutorialFrameLeft1;
		local anchorParentRight = _G.TutorialFrameRight1;
		for i = 2, displayData.tileHeight do
			local leftTexture = _G["TutorialFrameLeft"..i];
			local rightTexture = _G["TutorialFrameRight"..i];
			leftTexture:SetPoint("TOPLEFT", anchorParentLeft, "BOTTOMLEFT", 0, 0);
			rightTexture:SetPoint("TOPRIGHT", anchorParentRight, "BOTTOMRIGHT", 0, 0);
			leftTexture:Show();
			rightTexture:Show();
			anchorParentLeft = leftTexture;
			anchorParentRight = rightTexture;
		end
		_G.TutorialFrameBottom:SetPoint("TOPLEFT", anchorParentLeft, "BOTTOMLEFT", 0, 0);
		_G.TutorialFrameBottom:SetPoint("TOPRIGHT", anchorParentRight, "TOPRIGHT", 0, 0);

		local height = TUTORIALFRAME_TOP_HEIGHT + (displayData.tileHeight * TUTORIALFRAME_MIDDLE_HEIGHT) + TUTORIALFRAME_BOTTOM_HEIGHT;
		_G.TutorialFrame:SetSize(TUTORIALFRAME_WIDTH, height);
	end

	local _, className = _G.UnitClass("player");
	local _, raceName  = _G.UnitRace("player");
	className = _G.strupper(className);
	raceName = _G.strupper(raceName);

	if (displayData.displayNPC) then
		_G.TutorialNPCModel:SetCreature(TUTORIAL_QUEST_ARRAY[raceName].displayNPC);
		_G.TutorialNPCModel:Show();
	end

	-- setup the text
	-- check for class specific first, then race specific, then normal
	local title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..className];
	if ( not title ) then
		title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..raceName];
		if ( not title ) then
			title = _G["TUTORIAL_TITLE"..currentTutorial];
		end
	end
	local text = _G["TUTORIAL"..currentTutorial.."_"..className];
	if ( not text ) then
		text = _G["TUTORIAL"..currentTutorial.."_"..raceName];
		if ( not text ) then
			text = _G["TUTORIAL"..currentTutorial];
		end
	end

	if (displayData.raidwarning) then
		_G.RaidNotice_AddMessage(_G.RaidWarningFrame, text, _G.ChatTypeInfo["RAID_WARNING"]);
		return;
	end

	if ( title and text) then
		_G.TutorialFrameTitle:SetText(title);
		_G.TutorialFrameText:SetText(text);
	end
	if ( displayData.textBox) then
		_G.TutorialFrameTextScrollFrame:SetPoint("TOPLEFT", _G.TutorialFrame, "TOPLEFT", displayData.textBox.topLeft_xOff, displayData.textBox.topLeft_yOff);
		_G.TutorialFrameTextScrollFrame:SetPoint("BOTTOMRIGHT", _G.TutorialFrame, "BOTTOMRIGHT", displayData.textBox.bottomRight_xOff, displayData.textBox.bottomRight_yOff);
	end

	-- setup the callout
	local callOut = displayData.callOut;
	if(callOut) then
		_G.TutorialFrameCallOut:SetSize(callOut.width, callOut.height);
		_G.TutorialFrameCallOut:SetPoint( callOut.align, callOut.parent, callOut.align, callOut.xOff, callOut.yOff );
		_G.TutorialFrameCallOut:Show();
		_G.TutorialFrameCallOutPulser:Play();
	end

	-- setup images
	for i = 1, MAX_TUTORIAL_IMAGES do
		local imageTexture = _G["TutorialFrameImage"..i];
		local imageData = displayData["imageData"..i];
		if(imageData and imageTexture) then
			imageTexture:SetTexture(imageData.file);
			imageTexture:SetPoint( imageData.align, _G.TutorialFrame, imageData.align, imageData.xOff, imageData.yOff );
			if ( imageData.layer ) then
				imageTexture:SetDrawLayer(imageData.layer);
			end
			imageTexture:Show();
		elseif( imageTexture ) then
			imageTexture:ClearAllPoints();
			imageTexture:SetTexture("");
			imageTexture:Hide();
		end
	end

	-- setup mouse
	local mouseData = displayData.mouseData;
	if(mouseData) then
		local mouseTexture = _G["TutorialFrameMouse"..mouseData.image];
		mouseTexture:SetPoint( mouseData.align, TutorialFrame, mouseData.align, mouseData.xOff, mouseData.yOff );

		local scale = 1.0;
		if ( mouseData.scale ) then
			scale = mouseData.scale;
		end
		mouseTexture:SetWidth( MOUSE_SIZE.x * scale );
		mouseTexture:SetHeight( MOUSE_SIZE.y * scale );

		if ( mouseData.layer ) then
			mouseTexture:SetDrawLayer(mouseData.layer);
		end
		mouseTexture:Show();
	end

	-- setup keys
	for i = 1, MAX_TUTORIAL_KEYS do
		local keyTexture = _G["TutorialFrameKey"..i];
		local keyString = _G["TutorialFrameKeyString"..i];
		local keyData = displayData["keyData"..i];
		if(keyTexture and keyString and keyData) then
			keyTexture:SetPoint( keyData.align, TutorialFrame, keyData.align, keyData.xOff, keyData.yOff );
			keyString:SetText( GetBindingText(GetBindingKey(keyData.command), "KEY_") );
			if ( keyData.layer ) then
				keyTexture:SetDrawLayer(keyData.layer);
				keyString:SetDrawLayer(keyData.layer);
			end
			keyTexture:Show();
			keyString:Show();
		elseif ( keyTexture ) then
			keyTexture:ClearAllPoints();
			keyTexture:Hide();
			keyString:Hide();
		end
	end

	-- setup arrows
	for i = 1, getn(ARROW_TYPES) do
		local arrowData = displayData[ ARROW_TYPES[i] ];
		local arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		if ( arrowData and arrowTexture ) then
			arrowTexture:SetPoint( arrowData.align, TutorialFrame, arrowData.align, arrowData.xOff, arrowData.yOff );
			if ( arrowData.layer ) then
				arrowTexture:SetDrawLayer(arrowData.layer);
			end
			local scale = arrowData.scale;
			if ( not scale ) then
				scale = 1.0;
			end
			arrowTexture:SetWidth( ARROW_SIZES[ARROW_TYPES[i]].x * scale );
			arrowTexture:SetHeight( ARROW_SIZES[ARROW_TYPES[i]].y * scale );
			arrowTexture:Show();
		elseif ( arrowTexture ) then
			arrowTexture:ClearAllPoints();
			arrowTexture:Hide();
		end
	end

	-- show
	_G.TutorialFrame:Show();
	_G.TutorialFrame_CheckNextPrevButtons();
    end
end


local function getHistoryIndex(id)
    for i=1, #TUTORIAL_HISTORY do
        if(TUTORIAL_HISTORY[i] == id) then
            return i;
        end
    end
    return;
end

local _GetNextCompleatedTutorial = _G.GetNextCompleatedTutorial;
function _G.GetNextCompleatedTutorial(id)
    if(string.match(id, "^[0-9]+$")) then
        return _GetNextCompleatedTutorial(id);
    else
        local i = getHistoryIndex(id);
        return i and TUTORIAL_HISTORY[i+1];
    end
end

local _GetPrevCompleatedTutorial = _G.GetPrevCompleatedTutorial;
function _G.GetPrevCompleatedTutorial(id)
    if(string.match(id, "^[0-9]+$")) then
        return _GetPrevCompleatedTutorial(id);
    else
        local i = getHistoryIndex(id);
        return i and TUTORIAL_HISTORY[i-1];
    end
end


--Global to add tutorial
function DisplayTutorial(title, tutorial)
    -- this function is defined when the module is enabled.
end

-- this is used to show tutorial even if Tutorials are disabled.
DisplayTutorialForce = displayTutorial;
