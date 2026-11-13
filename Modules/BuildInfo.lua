--imports
local _G = _G;
local WIM = WIM;
local string = string;
local tonumber = tonumber;

--set namespace
setfenv(1, WIM);

-- Build identifier, used to verify which copy is installed. The
-- packager replaces the keyword below with the source commit's short
-- hash at release time, so diagnostics (the snapshot tool, bug
-- reports) can state which build produced them. A copy run straight
-- from the source tree keeps the keyword and reports as "dev".
local hash = "@project-abbreviated-hash@";

-- test build types
-- hash = "3.19.6" -- release
-- hash = "3.19.5-beta" -- beta #.#.#-beta(-#|#)?
-- hash = "3.19.5-1-abcdefgh" -- alpha #.#.#-#-<commit>

-- returns type, version, identifier(beta:# or alpha:commit)
local function parseBuildId (buildId)
	if not buildId or buildId == "dev" then
		return "dev", "dev", nil;
	end

	do -- beta
		local version, iteration = string.match(buildId, "^(%d+%.%d+%.?%d*)%-beta%-?(%d*)");
		if version then
			return "beta", version, tonumber(iteration) or 1;
		end
	end

	do -- alpha
		local version, commit = string.match(buildId, "^(%d+%.%d+%.?%d*)%-%d+%-(%w%w%w%w+)");
		if commit then
			return "alpha", version, commit;
		end
	end

	return "release", buildId, nil;
end

local buildType, buildVersion, buildIdentifier = parseBuildId(hash);

BUILD_ID = buildType == "dev" and "dev" or hash;
BUILD_TYPE = buildType;


local BuildInfo = CreateModule("BuildInfo", true);

db_defaults.buildInfo = {
	id = BUILD_ID,
	type = BUILD_TYPE,

	alphaUsed = false, -- was alpha being used since last release?

	disableAlphaReminder = false, -- never remind the user about the alpha channel
	snoozeAlphaReminder = false, -- snooze alerts until the next release
}

local previousBuildInfo = {
	id = BUILD_ID,
	type = BUILD_TYPE,
	version = buildVersion,
	beta = buildType == "beta" and buildIdentifier or nil,
	alpha = buildType == "alpha" and buildIdentifier or nil,
}


local function showAlphaReminder ()
	_G.StaticPopupDialogs["WIM_ALPHA_BUILD_REMINDER"] = {
		text = "|cffff8800WIM Alpha Build|r\n\n"
			.. "You are running an |cffffd200alpha|r build of WIM (%s).\n\n"
			.. "If the issue you were testing has been fixed, consider switching back to the "
			.. "|cff00ff00Release|r or |cff00ccffBeta|r channel for a more stable experience.",
		button1 = "Snooze until next release",
		button2 = "Remind me later",
		button3 = "Never remind me",
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,   -- Esc -> OnCancel (safe dismiss)
		preferredIndex = 3,    -- avoid taint with Blizzard popups

		OnAccept = function()  -- snooze
			-- db.buildInfo.snoozeAlphaReminder = WIM.GetCurrentBuildInfo().version;
			utils.debug.dump('Snoozing alpha reminder')
		end,
		OnCancel = function()  -- dismiss; shows again next load
			utils.debug.dump('Dismissing alpha reminder')
		end,
		OnAlt = function()     -- never
			-- db.buildInfo.disableAlphaReminder = true;
			utils.debug.dump('Disabling alpha reminder')
		end,
	};

	-- C_Timer.After(5, function() -- let the UI settle after login
		utils.dialog.create("WIM_ALPHA_BUILD_REMINDER", BUILD_ID);
    -- end);
end

local function ShouldShowAlphaReminder()
    local info = db.buildInfo;
    if BUILD_TYPE ~= "alpha" or info.disableAlphaReminder then return false; end
    return info.snoozeAlphaReminder ~= WIM.GetCurrentBuildInfo().version;
end



-- not sure if we want to compare version numbers or just or just keep track if an alpha was loaded at some earlier point prior to a release.
function BuildInfo:OnInitialized()
	local prevId = db.buildInfo.id;
	local prevType = db.buildInfo.type;

	-- rebuild for parsing continuity
	local _, prevVersion, prevIdentifier = parseBuildId(prevId);

	previousBuildInfo.id = prevId;
	previousBuildInfo.type = prevType;
	previousBuildInfo.version = prevVersion;
	previousBuildInfo.beta = prevType == "beta" and prevIdentifier or nil;
	previousBuildInfo.alpha = prevType == "alpha" and prevIdentifier or nil;

	-- update the build info in the database
	db.buildInfo.id = BUILD_ID;
	db.buildInfo.type = BUILD_TYPE;

	db.buildInfo.alphaUsed = BUILD_TYPE == "alpha" or db.buildInfo.alphaUsed;

	local isNewBuild = (prevId ~= BUILD_ID);

	-- perform logic determining whether or not to show dialog using utils.dialog.(create|confirm).
	-- I need to look at the default template and see if it has a check box for disabling reminders.
	if isNewBuild and ShouldShowAlphaReminder() or true then
		showAlphaReminder();
	end

end

-- Expose build information to other modules
function WIM.GetCurrentBuildInfo()
	return {
		id = BUILD_ID,
		type = BUILD_TYPE,
		version = buildVersion,
		beta = buildType == "beta" and buildIdentifier or nil,
		alpha = buildType == "alpha" and buildIdentifier or nil,
	}
end

function WIM.GetPreviousBuildInfo()
	return {
		id = previousBuildInfo.id,
		type = previousBuildInfo.type,
		version = previousBuildInfo.version,
		beta = previousBuildInfo.beta,
		alpha = previousBuildInfo.alpha,
	}
end

-- This is a core module and must always be loaded...
BuildInfo.canDisable = false;
BuildInfo:Enable();
