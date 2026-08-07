return {
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true,  -- popup that shows what my leader keys do
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
      },
      'nvim-tree/nvim-web-devicons',
    },
    opts = {},
  },
}
