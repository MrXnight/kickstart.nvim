---@module 'lazy'
---@type LazySpec
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  config = function()
    require('ibl').setup {
      indent = { char = '│' },
      scope = { enabled = true },
      exclude = {
        filetypes = {
          'dashboard',
          'help',
          'lazy',
          'mason',
          'notify',
          'NvimTree',
          'neo-tree',
          'Trouble',
          'toggleterm',
        },
        buftypes = {
          'terminal',
          'nofile',
          'quickfix',
          'prompt',
        },
      },
    }
  end,
}
