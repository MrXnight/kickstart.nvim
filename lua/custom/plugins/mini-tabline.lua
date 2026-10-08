-- Tabline (mini.tabline) with catppuccin colors

---@module 'lazy'
---@type LazySpec
return {
  'echasnovski/mini.tabline',
  version = '*',
  config = function()
    require('mini.tabline').setup {
      show_icons = true,
      set_vim_settings = true,
      format = function(buf_id, label)
        -- Add subtle padding around the tab names so they aren't cramped
        return ' ' .. label .. ' '
      end,
    }
    vim.o.showtabline = 2 -- Always show tabline

    -- Dynamically apply Catppuccin colors to the tabline
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        local C = require('catppuccin.palettes').get_palette()

        -- Active tab uses the editor background so it "connects" to the buffer below it
        vim.api.nvim_set_hl(0, 'MiniTablineCurrent', { fg = C.text, bg = C.base, bold = true })
        vim.api.nvim_set_hl(0, 'MiniTablineVisible', { fg = C.text, bg = C.mantle })

        -- Inactive tabs use darker backgrounds to push them back visually
        vim.api.nvim_set_hl(0, 'MiniTablineHidden', { fg = C.surface2, bg = C.crust })

        -- Modified tabs get peach text to indicate unsaved changes
        vim.api.nvim_set_hl(0, 'MiniTablineModifiedCurrent', { fg = C.peach, bg = C.base, bold = true })
        vim.api.nvim_set_hl(0, 'MiniTablineModifiedVisible', { fg = C.peach, bg = C.mantle })
        vim.api.nvim_set_hl(0, 'MiniTablineModifiedHidden', { fg = C.peach, bg = C.crust })

        -- The empty space after the tabs
        vim.api.nvim_set_hl(0, 'MiniTablineFill', { bg = C.crust })
      end,
    })
    vim.cmd 'doautocmd ColorScheme'
  end,
}
