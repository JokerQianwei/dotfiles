vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
vim.keymap.set('n', '<leader>n', '<cmd>set number!<CR>', { desc = 'Toggle Line Numbers' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

local function leetgo(command)
  local question_dir = vim.fn.expand('%:p:h:t')
  local id = question_dir:match('^(%d+)%.')
  if not id then
    vim.notify('当前文件不在 LeetCode 题目目录中', vim.log.levels.ERROR)
    return
  end

  -- 使用当前题号，避免 last 指向另一道刚生成的题目。
  vim.cmd('botright split | terminal leetgo ' .. command .. ' ' .. tonumber(id))
end

vim.keymap.set('n', '<leader>lt', function() leetgo('test -L') end, { desc = 'LeetCode: Test Locally' })
vim.keymap.set('n', '<leader>ls', function() leetgo('submit') end, { desc = 'LeetCode: Submit' })
