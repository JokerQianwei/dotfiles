vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
vim.keymap.set('n', '<leader>n', '<cmd>set number!<CR>', { desc = 'Toggle Line Numbers' })
vim.keymap.set('n', '<leader><leader>', '<C-^>', { desc = 'Switch to Previous Buffer' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- 使用主行键跳到行首和行尾。
vim.keymap.set({ 'n', 'x', 'o' }, '<C-h>', '^', { desc = 'Jump to First Non-blank Character' })
vim.keymap.set({ 'n', 'x', 'o' }, '<C-l>', '$', { desc = 'Jump to End of Line' })

-- 使用易触及的组合键退出当前编辑模式。
for _, key in ipairs({ '<C-j>', '<C-k>' }) do
  vim.keymap.set({ 'n', 'i', 'x', 's', 'o', 'c', 't' }, key, '<Esc>')
end

-- 跳转搜索结果后保持当前匹配位于屏幕中央。
vim.keymap.set('n', 'n', 'nzz', { desc = 'Next Search Result' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Previous Search Result' })
vim.keymap.set('n', '*', '*zz', { desc = 'Search Word Forward' })
vim.keymap.set('n', '#', '#zz', { desc = 'Search Word Backward' })
vim.keymap.set('n', 'g*', 'g*zz', { desc = 'Search Partial Word Forward' })

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
