-- Statusline (mini.statusline) with catppuccin colors

---@module 'lazy'
---@type LazySpec
return {
  'echasnovski/mini.statusline',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local statusline = require 'mini.statusline'

    statusline.setup {
      use_icons = true,
      set_vim_settings = true,
      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
          local git = statusline.section_git { trunc_width = 75 }
          local diag = statusline.section_diagnostics { trunc_width = 75 }
          local filename = statusline.section_filename { trunc_width = 140 }
          local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
          local location = statusline.section_location { trunc_width = 75 }
          local search = statusline.section_searchcount { trunc_width = 75 }

          -- combine_groups automatically inserts block separators when
          -- adjacent groups have different background colors.
          return statusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diag } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } }, -- Symmetrical mode color on the right
          }
        end,
        inactive = function()
          local filename = statusline.section_filename { trunc_width = 140 }
          return statusline.combine_groups {
            { hl = 'MiniStatuslineInactive', strings = { filename } },
          }
        end,
      },
    }

    -- Dynamically apply Catppuccin colors to the statusline
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        local C = require('catppuccin.palettes').get_palette()

        -- Mode colors (Left and Right blocks)
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', { fg = C.crust, bg = C.lavender, bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', { fg = C.crust, bg = C.green, bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', { fg = C.crust, bg = C.mauve, bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', { fg = C.crust, bg = C.red, bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { fg = C.crust, bg = C.peach, bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther', { fg = C.crust, bg = C.teal, bold = true })

        -- Middle sections
        vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { fg = C.subtext1, bg = C.surface0 })
        vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = C.subtext0, bg = C.mantle })
        vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { fg = C.subtext1, bg = C.surface0 })
        vim.api.nvim_set_hl(0, 'MiniStatuslineInactive', { fg = C.surface2, bg = C.crust })
      end,
    })
    vim.cmd 'doautocmd ColorScheme'
  end,
}
