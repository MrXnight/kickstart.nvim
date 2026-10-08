-- File explorer that edits the filesystem like a buffer

---@module 'lazy'
---@type LazySpec
return {
  'stevearc/oil.nvim',
  lazy = false,
  config = function()
    require('oil').setup {
      default_file_explorer = true,
      lsp_file_methods = { enabled = true },
      view_options = { show_hidden = true },
      keymaps = {
        ['g?'] = 'actions.show_help',
      },
    }
    vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open file explorer' })
  end,
  -- Optional dependencies
  -- dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
}
