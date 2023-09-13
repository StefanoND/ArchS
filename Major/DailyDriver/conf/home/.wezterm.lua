local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Begin

config.automatically_reload_config = true
config.check_for_updates = false

config.keys = {
    {
      key = '(',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = ')',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'T',
      mods = 'CTRL|SHIFT',
      action = act { SpawnTab = "CurrentPaneDomain" },
    },
}

config.default_prog = { 'bash' }
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font("Fira Code")
config.font_size = 12.0
config.window_background_opacity = 0.95
config.disable_default_key_bindings = false
config.enable_wayland = false

return config
