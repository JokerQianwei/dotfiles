return {
  {
    'nordtheme/vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nord_uniform_diff_background = 1
      vim.cmd.colorscheme('nord')

      for _, group in ipairs({ 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer' }) do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end

      vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#D8DEE9', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#4C566A', bg = '#2E3440' })
      vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#88C0D0', bg = '#2E3440', bold = true })
    end,
  },
}
