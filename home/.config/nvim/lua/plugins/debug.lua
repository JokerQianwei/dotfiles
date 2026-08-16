return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
      },
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Debug: Start / Continue' },
      { '<leader>dn', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<leader>do', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>dg', function() require('dap').run_to_cursor() end, desc = 'Debug: Run to Cursor' },
      { '<leader>dR', function() require('dap').restart() end, desc = 'Debug: Restart' },
      { '<leader>dx', function() require('dap').clear_breakpoints() end, desc = 'Debug: Clear Breakpoints' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug UI' },
      { '<leader>dt', function() require('dap-go').debug_test() end, desc = 'Debug Nearest Go Test' },
      { '<leader>dl', function() require('dap-go').debug_last_test() end, desc = 'Debug Last Go Test' },
      { '<leader>dq', function() require('dap').terminate() end, desc = 'Debug: Terminate' },
      {
        '<leader>dr',
        function() require('dapui').float_element('repl', { enter = true, width = 100, height = 20 }) end,
        desc = 'Debug: Open REPL',
      },
      { '<leader>de', function() require('dapui').eval() end, mode = { 'n', 'v' }, desc = 'Debug: Evaluate' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dapgo = require('dap-go')

      dapgo.setup({
        dap_configurations = {
          {
            type = 'go',
            name = 'Debug Package (Arguments)',
            request = 'launch',
            program = '${fileDirname}',
            args = dapgo.get_arguments,
          },
        },
      })
      dapui.setup({
        layouts = {
          {
            elements = { 'scopes', 'breakpoints', 'stacks', 'watches' },
            size = 40,
            position = 'left',
          },
          {
            -- Vim 从右向左创建底部窗口，反向声明后 REPL 会落在左侧。
            elements = { 'console', 'repl' },
            size = 10,
            position = 'bottom',
          },
        },
      })

      -- UI 由用户按需打开；调试结束时自动收起，避免残留无效状态。
      dap.listeners.before.event_terminated.dapui = function() dapui.close() end
      dap.listeners.before.event_exited.dapui = function() dapui.close() end
    end,
  },
}
