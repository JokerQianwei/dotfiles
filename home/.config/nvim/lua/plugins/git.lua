-- Mark untracked files with intent-to-add so diffview can show them.
local function mark_untracked()
  -- systemlist 会把 NUL 转成换行，必须保留原始输出才能安全处理多个文件。
  local result = vim.system(
    { 'git', 'ls-files', '--others', '--exclude-standard', '-z' },
    { text = false }
  ):wait()
  if result.code ~= 0 or result.stdout == '' then return end

  local files = {}
  local start = 1
  while true do
    local stop = result.stdout:find('\0', start, true)
    if not stop then break end
    files[#files + 1] = result.stdout:sub(start, stop - 1)
    start = stop + 1
  end
  if #files > 0 then
    vim.system(vim.list_extend({ 'git', 'add', '-N', '--' }, files)):wait()
  end
end

return {
  {
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    keys = { { '<leader>g', function() mark_untracked(); require('neogit').open() end, desc = 'Neogit' } },
    -- 默认展示最近提交，避免每次进入状态页后手动展开。
    opts = { sections = { recent = { folded = false } } },
  },
  {
    'sindrets/diffview.nvim',
    opts = {
      enhanced_diff_hl = true,
      -- 为树状路径保留足够空间，减少文件名截断。
      file_panel = { win_config = { width = 50 } },
      hooks = {
        diff_buf_win_enter = function(_, winid, ctx)
          local minus = 'DiffChange:DiffviewMinusLine,DiffText:DiffviewMinusText'
          local plus = 'DiffChange:DiffviewPlusLine,DiffText:DiffviewPlusText'
          local side = ctx.symbol == 'a' and minus or plus
          local winhl = vim.wo[winid].winhl
          vim.wo[winid].winhl = winhl == '' and side or winhl .. ',' .. side
        end,
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufWinEnter',
    opts = { current_line_blame = true },  -- who last touched this line
  },
}
