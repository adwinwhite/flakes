local wezterm = require("wezterm")
local act = wezterm.action

local mykeys = {
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search({ Regex = "" }) },
	{ key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
	{ key = "k", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
}

for i = 1, 9 do
	-- ALT + number to activate that tab
	table.insert(mykeys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action({ ActivateTab = i - 1 }),
	})
end

for i = 1, 9 do
	-- CTRL+ALT + number to move tab to that position
	table.insert(mykeys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

return {
	check_for_updates = false,
	enable_wayland = true,
	enable_scroll_bar = false,
	color_scheme = "Afterglow",
	window_padding = {
		left = 0,
		right = "1px",
		top = 0,
		bottom = 0,
	},
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 11.0,
	enable_tab_bar = false,
	disable_default_key_bindings = true,
	keys = mykeys,
}
