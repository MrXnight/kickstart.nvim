-- Catppuccin colorscheme

---@module 'lazy'
---@type LazySpec
return {
  -- Catppuccin theme (matches your WezTerm config)
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    transparent_background = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = true,
      dashboard = true,
      mini = {
        enabled = true,
        indentscope_color = '',
      },
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin'
  end,
}
