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

config.leader = { key='b', mods='CTRL' }
config.keys = {
    { key = '(',          mods = 'CTRL|SHIFT',   action=wezterm.action{SplitHorizontal={domain='CurrentPaneDomain'}}},
    { key = ')',          mods = 'CTRL|SHIFT',   action=wezterm.action{SplitVertical={domain='CurrentPaneDomain'}}},
    { key = '"',          mods = 'LEADER|SHIFT', action=wezterm.action{SplitVertical={domain='CurrentPaneDomain'}}},
    { key = '%',          mods = 'LEADER|SHIFT', action=wezterm.action{SplitHorizontal={domain='CurrentPaneDomain'}}},
    { key = 'T',          mods = 'CTRL|SHIFT',   action=wezterm.action{SpawnTab='CurrentPaneDomain'}},
    { key = 'h',          mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Left'}},
    { key = 'j',          mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Down'}},
    { key = 'k',          mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Up'}},
    { key = 'l',          mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Right'}},
    { key = 'LeftArrow',  mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Left'}},
    { key = 'RightArrow', mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Down'}},
    { key = 'UpArrow',    mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Up'}},
    { key = 'DownArrow',  mods = 'LEADER',       action=wezterm.action{ActivatePaneDirection='Right'}},
    { key = 'a',          mods = 'LEADER|CTRL',  action=wezterm.action{SendString='\x01'}},
    { key = 'o',          mods = 'LEADER',       action='TogglePaneZoomState' },
    { key = 'z',          mods = 'LEADER',       action='TogglePaneZoomState' },
    { key = 'c',          mods = 'LEADER',       action=wezterm.action{SpawnTab='CurrentPaneDomain'}},
    { key = 'H',          mods = 'LEADER|SHIFT', action=wezterm.action{AdjustPaneSize={'Left', 5}}},
    { key = 'J',          mods = 'LEADER|SHIFT', action=wezterm.action{AdjustPaneSize={'Down', 5}}},
    { key = 'K',          mods = 'LEADER|SHIFT', action=wezterm.action{AdjustPaneSize={'Up', 5}}},
    { key = 'L',          mods = 'LEADER|SHIFT', action=wezterm.action{AdjustPaneSize={'Right', 5}}},
    { key = 'x',          mods = 'LEADER',       action=wezterm.action{CloseCurrentTab={confirm=true}}},
    { key = 'w',          mods = 'LEADER',       action=wezterm.action{CloseCurrentPane={confirm=true}}},
}

for i = 1, 8 do
  -- LEADER (Default: CTRL + b) + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
  -- F1 through F8 to activate that tab
  table.insert(config.keys, {
    key = 'F' .. tostring(i),
    action = act.ActivateTab(i - 1),
  })
end

config.default_prog = { 'bash' }
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font('Fira Code')
config.font_size = 12.0
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'HorizontalLcd'
config.freetype_load_flags = 'FORCE_AUTOHINT'
config.window_background_opacity = 0.90
config.disable_default_key_bindings = false
config.enable_wayland = true
config.hide_tab_bar_if_only_one_tab = true
config.front_end = 'OpenGL'

return config
