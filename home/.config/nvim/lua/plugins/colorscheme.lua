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

      vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#E5E9F0', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#475165', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#88C0D0', bg = '#2E3440', bold = true })

      -- Tinted8 Nord 的普通灰用于弱化 Git ignored 条目。
      vim.api.nvim_set_hl(0, 'OilGitStatusIndexIgnored', { fg = '#616E88' })
      vim.api.nvim_set_hl(0, 'OilGitStatusWorkingTreeIgnored', { fg = '#616E88' })

      -- Diff 只叠加低对比度背景，保留源代码的语法前景色。
      vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#424A51' })
      vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#46404D' })
      vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#434C5E' })
      vim.api.nvim_set_hl(0, 'DiffText', { bg = '#475165', bold = true })
      vim.api.nvim_set_hl(0, 'DiffviewPlusLine', { bg = '#424A51' })
      vim.api.nvim_set_hl(0, 'DiffviewPlusText', { bg = '#4C594B', bold = true })
      vim.api.nvim_set_hl(0, 'DiffviewMinusLine', { bg = '#46404D' })
      vim.api.nvim_set_hl(0, 'DiffviewMinusText', { bg = '#5A434A', bold = true })

      vim.api.nvim_set_hl(0, 'NeogitDiffAdditions', { fg = '#A3BE8C' })
      vim.api.nvim_set_hl(0, 'NeogitDiffAdd', { fg = '#C2D4B3', bg = '#424A51' })
      vim.api.nvim_set_hl(0, 'NeogitDiffAddHighlight', { fg = '#A3BE8C', bg = '#424A51' })
      vim.api.nvim_set_hl(0, 'NeogitDiffAddInline', { fg = '#C2D4B3', bg = '#4C594B', bold = true })
      vim.api.nvim_set_hl(0, 'NeogitDiffDeletions', { fg = '#BF616A' })
      vim.api.nvim_set_hl(0, 'NeogitDiffDelete', { fg = '#D18D93', bg = '#46404D' })
      vim.api.nvim_set_hl(0, 'NeogitDiffDeleteHighlight', { fg = '#BF616A', bg = '#46404D' })
      vim.api.nvim_set_hl(0, 'NeogitDiffDeleteInline', { fg = '#D18D93', bg = '#5A434A', bold = true })
    end,
  },
}
