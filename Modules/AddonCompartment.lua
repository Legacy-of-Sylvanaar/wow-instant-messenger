--imports
local WIM = WIM;
local _G = _G;
local Notes = WIM.Notifications;
local NoteIndex = 1;
local AddonCompartmentFrame = AddonCompartmentFrame;
local table = table;

--set namespace
setfenv(1, WIM);


local AddonCompartment = CreateModule("AddonCompartment");

local updateFrame;

local icon = "Interface\\Addons\\"..addonTocName.."\\Skins\\Default\\minimap";
local iconNew = "Interface\\Addons\\"..addonTocName.."\\Skins\\Default\\minimap_new";
local data = {
    text = "WIM",
    icon = icon,
	notCheckable = true,
    func = function (data, menuInputData, menu)
        LauncherClick(menuInputData.buttonName);
    end,

	funcOnEnter = function(self)
		ShowMenuOnHover(self, "beside");
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
