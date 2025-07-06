local wezterm = require 'wezterm';

local mykeys = {}
for i = 1, 9 do
  -- CTRL+ALT + number to activate that tab
  table.insert(mykeys, {
    key=tostring(i),
    mods="ALT",
    action=wezterm.action{ActivateTab=i-1},
  })
end

table.insert(mykeys, {
  key="t",
  mods="CTRL|SHIFT",
  action=wezterm.action{SpawnTab="CurrentPaneDomain"}
})

table.insert(mykeys, {
  key="c",
  mods="CTRL|SHIFT",
  action=wezterm.action{CopyTo="Clipboard"}
})

table.insert(mykeys, {
  key="v",
  mods="CTRL|SHIFT",
  action=wezterm.action{PasteFrom="Clipboard"}
})

table.insert(mykeys, {
  key="f",
  mods="CTRL|SHIFT",
  action=wezterm.action{Search={Regex=""}}
})

table.insert(mykeys, {
  key="r",
  mods="CTRL|SHIFT",
  action="ReloadConfiguration"
})

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
  keys = mykeys
}
