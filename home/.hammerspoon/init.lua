hs.autoLaunch(true)

local windows = hs.window.filter.defaultCurrentSpace
local hyper = { 'cmd', 'ctrl', 'alt', 'shift' }

local function cycle_window(step)
  local focused = hs.window.focusedWindow()
  if not focused then return end

  local screen_id = focused:screen():id()
  local visible = {}
  for _, window in ipairs(windows:getWindows(hs.window.filter.sortByCreated)) do
    if window:screen():id() == screen_id then
      visible[#visible + 1] = window
    end
  end
  if #visible < 2 then return end

  local target = 1

  for index, window in ipairs(visible) do
    if window:id() == focused:id() then
      target = ((index - 1 + step) % #visible) + 1
      break
    end
  end

  visible[target]:focus()
end

local function focus_last_window()
  local recent = windows:getWindows(hs.window.filter.sortByFocusedLast)
  if #recent > 1 then recent[2]:focus() end
end

local function focus_screen(direction)
  local focused = hs.window.focusedWindow()
  if not focused then return end

  local current = focused:screen()
  local target = direction == 'west' and current:toWest() or current:toEast()
  if not target then return end

  for _, window in ipairs(windows:getWindows(hs.window.filter.sortByFocusedLast)) do
    if window:screen():id() == target:id() then
      window:focus()
      return
    end
  end
end

-- Karabiner 将 Caps 组合转换为 Hyper，避免占用应用快捷键。
hs.hotkey.bind(hyper, '[', function() cycle_window(-1) end)
hs.hotkey.bind(hyper, ']', function() cycle_window(1) end)
hs.hotkey.bind(hyper, '\\', focus_last_window)
hs.hotkey.bind({}, 'f18', function() focus_screen('west') end)
hs.hotkey.bind({}, 'f19', function() focus_screen('east') end)
