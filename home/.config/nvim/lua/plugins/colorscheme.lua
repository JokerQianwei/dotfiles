return {
  {
    'nordtheme/vim',
    lazy = false,
    priority = 1000,
    config = function()
      -- 官方的统一背景模式避免 reverse 与 Neogit 语法高亮叠加后文字不可见。
      vim.g.nord_uniform_diff_background = 1
      vim.cmd.colorscheme('nord')

      for _, group in ipairs({ 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer' }) do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end

      vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#D8DEE9', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#4C566A', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#88C0D0', bg = '#2E3440', bold = true })

      -- Git ignored 条目使用低对比度 Nord 灰，避免压过真实改动。
      vim.api.nvim_set_hl(0, 'OilGitStatusIndexIgnored', { fg = '#4C566A' })
      vim.api.nvim_set_hl(0, 'OilGitStatusWorkingTreeIgnored', { fg = '#4C566A' })

      -- 与 delta 当前主题一致；行内强调色由 Diffview 按左右窗口设置。
      vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#002800' })
      vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3F0001' })
      vim.api.nvim_set_hl(0, 'DiffviewPlusLine', { bg = '#002800' })
      vim.api.nvim_set_hl(0, 'DiffviewPlusText', { bg = '#006000' })
      vim.api.nvim_set_hl(0, 'DiffviewMinusLine', { bg = '#3F0001' })
      vim.api.nvim_set_hl(0, 'DiffviewMinusText', { bg = '#901011' })
    end,
  },
}
