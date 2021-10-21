std = "lua51"
max_line_length = false
exclude_files = {
	"**/Libs/**/*.lua",
	".luacheckrc"
}
ignore = {
	"11", -- Setting, Mutating or Accessing an undefined global variable (mutes all global warnings for WIMs private global space)
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"231", -- Local variable is set but never accessed (in some cases in WIM, it's practical to set variable name thats not used to remember chat args)
	"311", -- Value assigned to a local variable is unused (maybe something to cleanup later)
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
--    "431", -- shadowing upvalue
	"542", -- An empty if branch
	"621", -- Inconsistent indentation (SPACE followed by TAB) (This should be fixed at some point, but not today)
	"631", -- Line is too long
}
globals = {
	-- Saved Variables

	-- WIM
	"WIM",

	-- Lua
	"bit.band",
	"string.split",
	"table.wipe",
	"time",

	-- Utility functions
	"geterrorhandler",
	"fastrandom",
	"format",
	"hooksecurefunc",
	"strjoin",
	"strsplit",
	"tContains",
	"tDeleteItem",
	"tIndexOf",
	"tinsert",
	"tostringall",
	"tremove",

	-- WoW
	"CreateFrame",
	"ChatFontNormal",
	"GetRealmName",
	"UISpecialFrames",
	"LOCALIZED_CLASS_NAMES_MALE",
	"LOCALIZED_CLASS_NAMES_FEMALE",
}
