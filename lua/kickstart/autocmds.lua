-- Basic autocommands
-- Loaded from init.lua after kickstart.keymaps.

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Auto-reload files when changed outside of Neovim
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Auto-reload file if changed outside of Neovim',
  group = vim.api.nvim_create_augroup('auto-reload', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'c' then vim.cmd 'checktime' end
  end,
})

-- Notification after file change
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  desc = 'Notify when file changed outside of Neovim',
  group = vim.api.nvim_create_augroup('auto-reload-notify', { clear = true }),
  callback = function() vim.notify('File changed on disk. Buffer reloaded.', vim.log.levels.WARN) end,
})
