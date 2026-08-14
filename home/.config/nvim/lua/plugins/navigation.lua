local function copy_oil_path(relative)
  local oil = require('oil')
  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()
  if not entry or not dir then return end

  local path = dir .. entry.name .. (entry.type == 'directory' and '/' or '')
  if relative then path = vim.fn.fnamemodify(path, ':.') end

  -- 显式写入系统剪贴板；SSH 下由 OSC 52 转发到本机。
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end

return {
  {
    'stevearc/oil.nvim',
    opts = {
      win_options = { signcolumn = 'yes:2' },
      view_options = { show_hidden = true },
      keymaps = {
        ['ya'] = { function() copy_oil_path(false) end, desc = 'Copy absolute path' },
        ['yr'] = { function() copy_oil_path(true) end, desc = 'Copy relative path' },
      },
    },
    keys = { { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' } },
  },
  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    opts = {
      symbols = {
        index = { ['!'] = ' ' },
        working_tree = { ['!'] = '' },
      },
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}
