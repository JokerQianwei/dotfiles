local o = vim.opt
vim.g.mapleader = ' '          -- space is the leader key
o.expandtab = true             -- spaces, not tabs
o.shiftwidth = 2               -- 2 spaces per indent level
o.number = true                -- absolute line numbers
o.relativenumber = false       -- no relative line numbers
o.ignorecase = true            -- search is case-insensitive by default
o.smartcase = true             -- case-sensitive only if i type a capital
o.clipboard = 'unnamedplus'    -- share the system clipboard
o.scrolloff = 16               -- keep cursor away from the screen edge
o.undofile = true              -- persistent undo across sessions
o.mouse = 'a'                  -- 所有模式启用鼠标
o.smoothscroll = true          -- 长行换行时按屏幕行滚动

local remote_copy

-- OSC 52 不能通过 Herdr 远程连接读取本机剪贴板，因此只同步 yank。
if vim.env.SSH_CONNECTION then
  o.clipboard = ''
  remote_copy = require('vim.ui.clipboard.osc52').copy('+')
  if vim.env.TMUX then
    local command = vim.fn.expand('~/.local/bin/tmux-osc52-copy')
    remote_copy = function(lines)
      vim.fn.system({ command, vim.env.TMUX_PANE }, lines)
    end
  end
  local no_remote_paste = function() return 0 end
  vim.g.clipboard = {
    name = 'OSC 52 write-only',
    copy = { ['+'] = remote_copy, ['*'] = remote_copy },
    paste = { ['+'] = no_remote_paste, ['*'] = no_remote_paste },
  }
end

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
    if remote_copy and vim.v.event.operator == 'y' then
      remote_copy(vim.v.event.regcontents)
    end
  end,
})

vim.api.nvim_create_user_command('Nonu', function()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
end, { desc = 'Hide absolute and relative line numbers' })

vim.cmd([[cnoreabbrev <expr> nonu getcmdtype() ==# ':' && getcmdline() ==# 'nonu' ? 'Nonu' : 'nonu']])
