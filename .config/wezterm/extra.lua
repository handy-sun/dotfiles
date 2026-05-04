local wezterm = require 'wezterm'
local act = wezterm.action
local nf = wezterm.nerdfonts

local platform = (function()
   local triple = wezterm.target_triple
   if triple:find("windows") then
      return { os = "windows", is_win = true, is_linux = false, is_mac = false }
   elseif triple:find("apple") then
      return { os = "mac", is_win = false, is_linux = false, is_mac = true }
   else
      return { os = "linux", is_win = false, is_linux = true, is_mac = false }
   end
end)()

local SUPER     = platform.is_mac and "SUPER" or "ALT"
local SUPER_REV = platform.is_mac and "SUPER|CTRL" or "ALT|CTRL"

local backdrops = (function()
   local bd = { files = {}, current_idx = 1 }
   function bd:set_files()
      local config_dir = wezterm.config_dir
      self.files = {}
      local ok, iter, dir_obj = pcall(wezterm.read_dir, config_dir .. "/backdrops")
      if ok then
         for _, f in ipairs(iter or {}) do
            if f:match("%.jpe?g$") or f:match("%.png$") or f:match("%.gif$") then
               table.insert(self.files, f)
            end
         end
      end
      table.sort(self.files)
      if #self.files > 0 then
         wezterm.GLOBAL.background = self.files[1]
      end
      return self
   end
   function bd:_set_opt(window)
      if #self.files == 0 then return end
      window:set_config_overrides({
         background = {
            { source = { File = wezterm.GLOBAL.background }, horizontal_align = "Center" },
            { source = { Color = "#1f1f28" }, height = "100%", width = "100%", opacity = 0.96 },
         },
      })
   end
   function bd:choices()
      local choices = {}
      for idx, file in ipairs(self.files) do
         local name = file:match("([^/]+)$") or file
         table.insert(choices, { id = tostring(idx), label = name })
      end
      return choices
   end
   function bd:random(window)
      if #self.files == 0 then return end
      self.current_idx = math.random(#self.files)
      wezterm.GLOBAL.background = self.files[self.current_idx]
      self:_set_opt(window)
   end
   function bd:cycle_forward(window)
      if #self.files == 0 then return end
      self.current_idx = (self.current_idx % #self.files) + 1
      wezterm.GLOBAL.background = self.files[self.current_idx]
      self:_set_opt(window)
   end
   function bd:cycle_back(window)
      if #self.files == 0 then return end
      self.current_idx = ((self.current_idx - 2) % #self.files) + 1
      wezterm.GLOBAL.background = self.files[self.current_idx]
      self:_set_opt(window)
   end
   function bd:set_img(window, idx)
      if idx >= 1 and idx <= #self.files then
         self.current_idx = idx
         wezterm.GLOBAL.background = self.files[idx]
         self:_set_opt(window)
      end
   end
   return bd
end)()

backdrops:set_files():random(nil)

-- ═══════════════════════════════════════════════
-- Tab title 格式化
-- ═══════════════════════════════════════════════
local GLYPH_CIRCLE                = nf.fa_circle
local GLYPH_ADMIN                 = nf.md_shield_half_full
local GLYPH_LINUX                 = nf.cod_terminal_linux
local GLYPH_SCIRCLE_LEFT          = nf.ple_left_half_circle_thick
local GLYPH_SCIRCLE_RIGHT         = nf.ple_right_half_circle_thick
local GLYPH_SEMI_CIRCLE_LEFT      = nf.ple_left_half_circle_thick
local GLYPH_SEMI_CIRCLE_RIGHT     = nf.ple_right_half_circle_thick
local GLYPH_KEY_TABLE             = nf.md_table_key
local GLYPH_KEY                   = nf.md_key
local GLYPH_DEBUG                 = nf.fa_bug
local GLYPH_SEARCH                = "🔭"
local GLYPH_UNSEEN_NUMBERED_BOX   = {
   [1]  = nf.md_numeric_1_box_multiple,  [2]  = nf.md_numeric_2_box_multiple,
   [3]  = nf.md_numeric_3_box_multiple,  [4]  = nf.md_numeric_4_box_multiple,
   [5]  = nf.md_numeric_5_box_multiple,  [6]  = nf.md_numeric_6_box_multiple,
   [7]  = nf.md_numeric_7_box_multiple,  [8]  = nf.md_numeric_8_box_multiple,
   [9]  = nf.md_numeric_9_box_multiple,  [10] = nf.md_numeric_9_plus_box_multiple,
}
local GLYPH_UNSEEN_NUMBERED_CIRCLE = {
   [1]  = nf.md_numeric_1_circle,  [2]  = nf.md_numeric_2_circle,
   [3]  = nf.md_numeric_3_circle,  [4]  = nf.md_numeric_4_circle,
   [5]  = nf.md_numeric_5_circle,  [6]  = nf.md_numeric_6_circle,
   [7]  = nf.md_numeric_7_circle,  [8]  = nf.md_numeric_8_circle,
   [9]  = nf.md_numeric_9_circle,  [10] = nf.md_numeric_9_plus_circle,
}
local DEFAULT_INSET = 6
local ICON_INSET    = 8

local TITLE_COLORS = {
   text_default             = { fg = "#1C1B19", bg = "#45475A" },
   text_hover               = { fg = "#1C1B19", bg = "#5D87A3" },
   text_active              = { fg = "#11111B", bg = "#74c7ec" },
   unseen_output_default    = { fg = "#FFA066", bg = "#45475A" },
   unseen_output_hover      = { fg = "#FFA066", bg = "#5D87A3" },
   unseen_output_active     = { fg = "#FFA066", bg = "#74c7ec" },
   scircle_default          = { fg = "#45475A", bg = "rgba(0, 0, 0, 0.4)" },
   scircle_hover            = { fg = "#5D87A3", bg = "rgba(0, 0, 0, 0.4)" },
   scircle_active           = { fg = "#74C7EC", bg = "rgba(0, 0, 0, 0.4)" },
}

local function color_for_tab(tab, hover, unseen)
   local state = tab.is_active and "active" or (hover and "hover" or "default")
   local prefix = unseen and "unseen_output_" or "text_"
   return TITLE_COLORS[prefix .. state]
end
local function scircle_color_for_tab(tab, hover)
   local state = tab.is_active and "active" or (hover and "hover" or "default")
   return TITLE_COLORS["scircle_" .. state]
end

local function clean_process_name(proc)
   return proc:match("([^/\\]+)$") or proc
end

local function create_title(process_name, base_title, max_width, inset)
   local title
   if base_title:find("InputSelector") or base_title:find("Debug") then
      local prefix = base_title:find("InputSelector") and GLYPH_SEARCH or GLYPH_DEBUG
      title = prefix .. " " .. clean_process_name(process_name)
   elseif base_title == process_name then
      title = " " .. base_title
   else
      title = base_title
   end
   if #title > (max_width - inset) then
      title = title:sub(1, max_width - inset - 3) .. "..."
   end
   return title
end

local function check_unseen_output(panes)
   local unseen = 0
   for _, pane in ipairs(panes) do
      if pane.has_unseen_output then
         unseen = unseen + 1
      end
   end
   return unseen > 0 and unseen or false
end

local tab_id_to_tab = {}
local tab_id_to_title = {}
local manual_title = {}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
   local unseen = check_unseen_output(panes)
   local tab_obj = tab_id_to_tab[tab.tab_id]
   if not tab_obj then
      tab_obj = { tab_id = tab.tab_id, tab_idx = tab.tab_index }
      tab_id_to_tab[tab.tab_id] = tab_obj
   end
   if tab.is_active then
      tab_obj.tab_idx = tab.tab_index
   end
   tab_obj.is_active = tab.is_active

   local process_name = tab.active_pane.foreground_process_name
   local base_title = tab.tab_title
   if manual_title[tab.tab_id] then
      base_title = manual_title[tab.tab_id]
   elseif #base_title > 0 then
      -- 使用自定义标题
   else
      base_title = create_title(process_name, base_title, max_width, unseen and ICON_INSET or DEFAULT_INSET)
   end
   tab_id_to_title[tab.tab_id] = base_title

   local text_color = color_for_tab(tab, hover, unseen)
   local scircle_color = scircle_color_for_tab(tab, hover)

   local cells = wezterm.format({
      -- scircle_left
      { Background = { Color = scircle_color.bg } },
      { Foreground = { Color = scircle_color.fg } },
      { Text = GLYPH_SCIRCLE_LEFT },
      -- title
      { Background = { Color = text_color.bg } },
      { Foreground = { Color = text_color.fg } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. base_title .. " " },
      "ResetAttributes",
   })

   -- unseen indicator
   if unseen and (not tab.is_active or not true) then
      local unseen_color = color_for_tab(tab, hover, true)
      local icon = GLYPH_CIRCLE
      cells = cells .. wezterm.format({
         { Background = { Color = scircle_color.bg } },
         { Foreground = { Color = unseen_color.fg } },
         { Text = " " .. icon .. " " },
      })
   end

   -- admin / WSL indicator
   if tab.active_pane.user_vars.IS_ADMIN == "true" then
      cells = cells .. wezterm.format({
         { Background = { Color = scircle_color.bg } },
         { Foreground = { Color = text_color.fg } },
         { Text = " " .. GLYPH_ADMIN .. " " },
      })
   elseif platform.is_win and tab.active_pane.user_vars.IS_WSL == "true" then
      cells = cells .. wezterm.format({
         { Background = { Color = scircle_color.bg } },
         { Foreground = { Color = text_color.fg } },
         { Text = " " .. GLYPH_LINUX .. " " },
      })
   end

   -- padding + scircle_right
   cells = cells .. wezterm.format({
      { Background = { Color = scircle_color.bg } },
      { Foreground = { Color = scircle_color.fg } },
      { Text = " " },
      { Text = GLYPH_SCIRCLE_RIGHT },
   })

   return cells
end)

wezterm.on("tabs.manual-update-tab-title", function(window, pane)
   window:perform_action(
      act.PromptInputLine({
         description = wezterm.format({
            { Attribute = { Intensity = "Bold" } },
            { Foreground = { Color = "#fab387" } },
            { Text = "Enter new name for tab" },
         }),
         action = wezterm.action_callback(function(inner_window, _, line)
            if line then
               manual_title[window:active_tab().tab_id] = line
            end
         end),
      }),
      pane
   )
end)

wezterm.on("tabs.reset-tab-title", function(window, pane)
   manual_title[window:active_tab().tab_id] = nil
end)

wezterm.on("tabs.toggle-tab-bar", function(window, pane)
   local overrides = window:get_config_overrides() or {}
   overrides.enable_tab_bar = not (overrides.enable_tab_bar ~= false)
   window:set_config_overrides(overrides)
end)

-- ═══════════════════════════════════════════════
-- Right status: 日期 + 电量
-- ═══════════════════════════════════════════════
local function push(cells, text, icon, fg, bg, separate)
   table.insert(cells, { Background = { Color = bg } })
   table.insert(cells, { Foreground = { Color = fg } })
   table.insert(cells, { Attribute = { Intensity = "Bold" } })
   table.insert(cells, { Text = " " .. icon .. " " .. text .. " " })
   if separate then
      table.insert(cells, { Foreground = { Color = "#786D22" } })
      table.insert(cells, { Background = { Color = "#0F2536" } })
      table.insert(cells, { Text = " ~ " })
   end
end

local function set_date(cells)
   push(cells, os.date(" %a %H:%M"), "", "#7F82BB", "#0F2536", true)
end

local function set_battery(cells)
   local discharging_icons = {
      "󰂃", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹",
   }
   local charging_icons = {
      "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅",
   }
   local info = wezterm.battery_info()[1]
   if not info then return end
   local pct = math.floor(info.state_of_charge * 100)
   local idx = math.max(1, math.ceil(info.state_of_charge * 10))
   local icon
   if info.state == "Charging" then
      icon = charging_icons[idx]
   else
      icon = discharging_icons[idx]
   end
   push(cells, pct .. "%", icon, "#BB49B3", "#0F2536", false)
end

wezterm.on("update-right-status", function(window, pane)
   local cells = {}
   set_date(cells)
   set_battery(cells)
   window:set_right_status(wezterm.format(cells))
end)

-- ═══════════════════════════════════════════════
-- Left status: key table / leader 指示
-- ═══════════════════════════════════════════════
wezterm.on("update-left-status", function(window, pane)
   local left_cells = {}
   local active_key_table = window:active_key_table()
   local leader = window:leader_is_active()
   if active_key_table then
      table.insert(left_cells, { Background = { Color = "rgba(0, 0, 0, 0.4)" } })
      table.insert(left_cells, { Foreground = { Color = "#fab387" } })
      table.insert(left_cells, { Text = GLYPH_SEMI_CIRCLE_LEFT })
      table.insert(left_cells, { Background = { Color = "#fab387" } })
      table.insert(left_cells, { Foreground = { Color = "#1c1b19" } })
      table.insert(left_cells, { Attribute = { Intensity = "Bold" } })
      table.insert(left_cells, { Text = " " .. GLYPH_KEY_TABLE .. " " .. string.upper(active_key_table) .. " " })
      table.insert(left_cells, "ResetAttributes")
      table.insert(left_cells, { Background = { Color = "rgba(0, 0, 0, 0.4)" } })
      table.insert(left_cells, { Foreground = { Color = "#fab387" } })
      table.insert(left_cells, { Text = GLYPH_SEMI_CIRCLE_RIGHT .. " " })
   elseif leader then
      table.insert(left_cells, { Background = { Color = "rgba(0, 0, 0, 0.4)" } })
      table.insert(left_cells, { Foreground = { Color = "#fab387" } })
      table.insert(left_cells, { Text = GLYPH_SEMI_CIRCLE_LEFT })
      table.insert(left_cells, { Background = { Color = "#fab387" } })
      table.insert(left_cells, { Foreground = { Color = "#1c1b19" } })
      table.insert(left_cells, { Attribute = { Intensity = "Bold" } })
      table.insert(left_cells, { Text = " " .. GLYPH_KEY .. " LEADER " })
      table.insert(left_cells, "ResetAttributes")
      table.insert(left_cells, { Background = { Color = "rgba(0, 0, 0, 0.4)" } })
      table.insert(left_cells, { Foreground = { Color = "#fab387" } })
      table.insert(left_cells, { Text = GLYPH_SEMI_CIRCLE_RIGHT .. " " })
   end
   window:set_left_status(wezterm.format(left_cells))
end)

-- ═══════════════════════════════════════════════
-- New tab button: 右键打开 launcher
-- ═══════════════════════════════════════════════
wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
   if button == "Right" then
      window:perform_action(
         act.ShowLauncherArgs({
            title = wezterm.nerdfonts.fa_rocket .. "  Select/Search:",
            flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
         }),
         pane
      )
      return false
   end
end)

-- ═══════════════════════════════════════════════
-- 背景图片事件
-- ═══════════════════════════════════════════════
wezterm.on("window-config-reloaded", function(window)
   backdrops:set_files()
end)

-- ═══════════════════════════════════════════════
-- 返回动态配置（静态配置在 Nix settings 中）
-- ═══════════════════════════════════════════════
return {
   background = {
      { source = { File = wezterm.GLOBAL.background }, horizontal_align = "Center" },
      { source = { Color = "#1f1f28" }, height = "100%", width = "100%", opacity = 0.96 },
   },

   mouse_bindings = {
      { event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
      { event = { Down = { streak = 1, button = "Right" } }, mods = "NONE", action = act.PasteFrom("Clipboard") },
   },

   leader = { key = "Space", mods = SUPER_REV },

   keys = {
      -- F-keys
      { key = "F1",  mods = "CTRL",       action = act.ActivateCopyMode },
      { key = "F2",  mods = "CTRL",       action = act.ActivateCommandPalette },
      { key = "F3",  mods = "CTRL",       action = act.ShowLauncher },
      { key = "F4",  mods = "CTRL",       action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
      { key = "F5",  mods = "CTRL",       action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
      { key = "F10", mods = SUPER,         action = act.Search({ CaseInSensitiveString = "" }) },
      { key = "F11", mods = "CTRL",       action = act.ToggleFullScreen },
      { key = "F12", mods = "CTRL",       action = act.ShowDebugOverlay },
      -- QuickSelect URL
      { key = "u", mods = SUPER, action = act.QuickSelectArgs({
         patterns = {
            "\\((\\w+://\\S+)\\)", "\\[(\\w+://\\S+)\\]",
            "\\{(\\w+://\\S+)\\}", "<(\\w+://\\S+)>",
            "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            if url then
               wezterm.open_with(url)
            end
         end),
      }) },
      -- Ctrl+Shift+Arrow
      { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.SendString("\x1bOH") },
      { key = "RightArrow", mods = "CTRL|SHIFT", action = act.SendString("\x1bOF") },
      -- SUPER+Backspace → 删行
      { key = "Backspace", mods = SUPER, action = act.SendString("\x15") },
      -- 剪贴板
      { key = "c",      mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
      { key = "Insert", mods = "CTRL",       action = act.CopyTo("Clipboard") },
      { key = "v",      mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
      { key = "v",      mods = SUPER,         action = act.PasteFrom("Clipboard") },
      { key = "Insert", mods = "SHIFT",       action = act.PasteFrom("Clipboard") },
      -- Tab 管理
      { key = "t", mods = SUPER,     action = act.SpawnTab("DefaultDomain") },
      { key = "w", mods = SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },
      { key = "[", mods = SUPER,     action = act.ActivateTabRelative(-1) },
      { key = "]", mods = SUPER,     action = act.ActivateTabRelative(1) },
      { key = "[", mods = SUPER_REV, action = act.MoveTabRelative(-1) },
      { key = "]", mods = SUPER_REV, action = act.MoveTabRelative(1) },
      -- 新窗口
      { key = "n", mods = SUPER, action = act.SpawnWindow },
      -- 背景轮播
      { key = "/", mods = SUPER, action = wezterm.action_callback(function(window, _)
         backdrops:random(window)
      end) },
      { key = ",", mods = SUPER, action = wezterm.action_callback(function(window, _)
         backdrops:cycle_back(window)
      end) },
      { key = ".", mods = SUPER, action = wezterm.action_callback(function(window, _)
         backdrops:cycle_forward(window)
      end) },
      { key = "/", mods = SUPER_REV, action = act.InputSelector({
         title = "Select Background",
         choices = backdrops:choices(),
         action = wezterm.action_callback(function(window, _, idx)
            if idx then
               backdrops:set_img(window, tonumber(idx))
            end
         end),
      }) },
      -- Pane 管理
      { key = "\\",  mods = SUPER,     action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
      { key = "\\",  mods = SUPER_REV, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
      { key = "Enter", mods = SUPER,   action = act.TogglePaneZoomState },
      { key = "w", mods = SUPER, action = act.CloseCurrentPane({ confirm = false }) },
      -- Pane 导航 (vim-style)
      { key = "k", mods = SUPER_REV, action = act.ActivatePaneDirection("Up") },
      { key = "j", mods = SUPER_REV, action = act.ActivatePaneDirection("Down") },
      { key = "h", mods = SUPER_REV, action = act.ActivatePaneDirection("Left") },
      { key = "l", mods = SUPER_REV, action = act.ActivatePaneDirection("Right") },
      { key = "p", mods = SUPER_REV, action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }) },
      -- Leader key tables
      { key = "f", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_font", one_shot = false, timeout_milliseconds = 1000 }) },
      { key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 1000 }) },
   },

   key_tables = {
      resize_font = {
         { key = "k",     action = act.IncreaseFontSize },
         { key = "j",     action = act.DecreaseFontSize },
         { key = "r",     action = act.ResetFontSize },
         { key = "Escape", action = act.PopKeyTable },
         { key = "q",     action = act.PopKeyTable },
      },
      resize_pane = {
         { key = "k",     action = act.AdjustPaneSize({ "Up", 1 }) },
         { key = "j",     action = act.AdjustPaneSize({ "Down", 1 }) },
         { key = "h",     action = act.AdjustPaneSize({ "Left", 1 }) },
         { key = "l",     action = act.AdjustPaneSize({ "Right", 1 }) },
         { key = "Escape", action = act.PopKeyTable },
         { key = "q",     action = act.PopKeyTable },
      },
   },
}
