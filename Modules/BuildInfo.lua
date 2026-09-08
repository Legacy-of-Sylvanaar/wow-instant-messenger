--imports
local WIM = WIM;
local string = string;

--set namespace
setfenv(1, WIM);

-- Build identifier, used to verify which copy is installed. The
-- packager replaces the keyword below with the source commit's short
-- hash at release time, so diagnostics (the snapshot tool, bug
-- reports) can state which build produced them. A copy run straight
-- from the source tree keeps the keyword and reports as "dev".
local hash = "@project-abbreviated-hash@";
BUILD_ID = string.find(hash, "^@") and "dev" or hash;
