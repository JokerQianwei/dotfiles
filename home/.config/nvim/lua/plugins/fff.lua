return {
  {
    'dmtrKovalenko/fff',
    build = function()
      -- 优先下载预编译库，不可用时再通过 Cargo 构建。
      require('fff.download').download_or_build_binary()
    end,
    lazy = false,
    opts = {},
    keys = {
      { '<leader>f', function() require('fff').find_files() end, desc = 'Find Files' },
      { '<leader>s', function() require('fff').live_grep() end, desc = 'Search Text' },
    },
  },
}
