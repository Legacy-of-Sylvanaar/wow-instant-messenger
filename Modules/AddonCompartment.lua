--imports
local WIM = WIM;
local _G = _G;
local Notes = WIM.Notifications;
local NoteIndex = 1;
local AddonCompartmentFrame = AddonCompartmentFrame;
local UIParent = UIParent;
local table = table;

--set namespace
setfenv(1, WIM);


local AddonCompartment = CreateModule("AddonCompartment");

local updateFrame, tooltip;

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local icon = "Interface\\Addons\\"..addonTocName.."\\Skins\\Default\\minimap";
local iconNew = "Interface\\Addons\\"..addonTocName.."\\Skins\\Default\\minimap_new";
local data = {
    text = "WIM",
    icon = icon,
	notCheckable = true,
    func = function (data, menuInputData, menu)
		local frame = _G.AddonCompartmentFrame;
		if(menuInputData.buttonName == "LeftButton") then
            Menu:ClearAllPoints();
            if(Menu:IsShown()) then
                Menu:Hide();
            else
                Menu:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0);
                Menu:Show();
            end
        else
            if(db.minimap.rightClickNew) then
                if(_G.IsShiftKeyDown()) then
                    -- display tools menu
                    PopContextMenu("MENU_MINIMAP", frame:GetName());
                else
                    ShowAllUnreadWindows();
                end
            else
                if(_G.IsShiftKeyDown()) then
                    ShowAllUnreadWindows();
                else
                    -- display tools menu
                    PopContextMenu("MENU_MINIMAP", frame:GetName());
                end
            end
        end
    end,

	funcOnEnter = function(self)
		tooltip = tooltip or _G.CreateFrame("GameTooltip", "WIMCompartmentTooltip", UIParent, "GameTooltipTemplate")
		tooltip:SetOwner(self, "ANCHOR_NONE")
		tooltip:SetPoint(getAnchors(self))
		tooltip:AddLine("WIM |cff00ff00(v"..version..")|r");
		for i=1, #Notes do
			tooltip:AddDoubleLine("|cff"..Notes[i].color..Notes[i].tag..":|r", "|cffffffff"..Notes[i].text.."|r");
		end
		tooltip:Show();
	end,

	funcOnLeave = function()
		if tooltip then
			tooltip:Hide();
		end
	end,
};

local function setText(text)
    if(data.text ~= text) then
        data.text = text;
        return true;
    end
end


function AddonCompartment:OnEnable()
	-- if not compatible, disable module and return
	if not AddonCompartmentFrame then
		self:Disable();
		return;
	end

	if updateFrame then
		updateFrame:Show();
	else
		updateFrame = updateFrame or _G.CreateFrame("Frame");
		updateFrame:Show();
		updateFrame.timer = 0;
		updateFrame.icon = true;

		updateFrame:SetScript("OnUpdate", function(self, elapsed)
			self.timer = self.timer + elapsed;
			while(self.timer >= 1) do
				if(#Notes > 0) then
					if(Notes[NoteIndex]) then
						setText(Notes[NoteIndex].tag..": "..Notes[NoteIndex].text);
					else
						NoteIndex = 0;
					end
					self.icon = not self.icon;
					if(self.icon) then
						-- show icon
						data.icon = icon;
					else
						-- show variant
						data.icon = iconNew;
					end
					_G.AddonCompartmentFrame:UpdateDisplay();
				else
					self.icon = true;
					if(setText(L["No New Messages"])) then
						-- set normal icon
						data.icon = icon;
					end
					NoteIndex = 0;
				end
				NoteIndex = NoteIndex + 1;
				self.timer = 0;
			end
		end);
	end

	-- don't re-register if already registered
	for i = #AddonCompartmentFrame.registeredAddons, 1, -1 do
		if AddonCompartmentFrame.registeredAddons[i] == data then
			return
		end
	end

	-- register with the compartment frame
	AddonCompartmentFrame:RegisterAddon(data);
end

function AddonCompartment:OnDisable()
	-- keep running unless physically disabled
	if self.enabled then
		return;
	end

	if updateFrame then
		updateFrame:Hide();
	end
	if (AddonCompartmentFrame) then
		for i = #AddonCompartmentFrame.registeredAddons, 1, -1 do
			if AddonCompartmentFrame.registeredAddons[i] == data then
				table.remove(AddonCompartmentFrame.registeredAddons, i);
				break;
			end
		end
		AddonCompartmentFrame:UpdateDisplay();
	end
end
