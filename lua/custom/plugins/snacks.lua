-- Snacks.nvim: pickers, lazygit, UI input

---@module 'lazy'
---@type LazySpec
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    input = {
      enabled = true,
      win = {
        relative = 'cursor',
        row = 1,
        col = 0,
        border = 'rounded',
      },
    },
    picker = {
      enabled = true,
      -- This handles vim.ui.select() for code actions
      ui_select = true,
    },
    lazygit = {
      config = {
        os = { editPreset = 'nvim' },
      },
    },
  },
  keys = {
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Open Lazygit' },
    { '<leader>gf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit file history' },
    { '<leader>gL', function() Snacks.lazygit.log() end, desc = 'Lazygit log' },

    -- Find
    { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[S]earch [S]elect Picker' },
    { '<leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
    { '<leader>sc', function() Snacks.picker.commands() end, desc = '[S]earch [C]ommands' },
    { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
    { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    { '<leader><leader>', function() Snacks.picker.buffers() end, desc = '[ ] Find existing buffers' },

    -- Search
    { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, mode = { 'n', 'v' }, desc = '[S]earch current [W]ord' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
    {
      '<leader>s/',
      function()
        -- Restrict grep to currently open (loaded, named) buffers
        local bufs = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buf)
          if vim.api.nvim_buf_is_loaded(buf) and name ~= '' then bufs[#bufs + 1] = name end
        end
        Snacks.picker.grep { dirs = bufs, live = true }
      end,
      desc = '[S]earch [/] in Open Files',
    },
  },
  config = function(_, opts)
    require('snacks').setup(opts)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

        map('grr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
        map('gri', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
        map('grd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
        map('grt', function() Snacks.picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')
        map('gO', function() Snacks.picker.lsp_symbols() end, 'Open Document Symbols')
        map('gW', function() Snacks.picker.lsp_workspace_symbols() end, 'Open Workspace Symbols')
      end,
    })
  end,
}
