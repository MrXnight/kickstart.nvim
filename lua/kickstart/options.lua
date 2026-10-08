-- Options and global settings
-- Loaded from init.lua before any plugin is set up.

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- space for tab
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Don't auto-wrap text while typing, and don't wrap long lines on display;
-- they continue off-screen to the right
vim.opt.textwidth = 0
vim.opt.wrap = false
vim.opt.formatoptions:remove 't'
-- Filetype plugins can re-add the auto-wrap flag, so strip it per buffer
vim.api.nvim_create_autocmd('FileType', {
  callback = function() vim.opt_local.formatoptions:remove 't' end,
})

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
-- Function to set OSC 52 clipboard
local function set_osc52_clipboard()
  local function my_paste()
    local content = vim.fn.getreg '"'
    return vim.split(content, '\n')
  end

  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = my_paste,
      ['*'] = my_paste,
    },
  }
end

-- Check if the current session is a remote WezTerm session based on the WezTerm executable
local function check_wezterm_remote_clipboard(callback)
  local wezterm_executable = vim.uv.os_getenv 'WEZTERM_EXECUTABLE'

  if wezterm_executable and wezterm_executable:find('wezterm-mux-server', 1, true) then
    callback(true) -- Remote WezTerm session found
  else
    callback(false) -- No remote WezTerm session
  end
end

-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard:append 'unnamedplus'

  -- Standard SSH session handling
  if vim.uv.os_getenv 'SSH_CLIENT' ~= nil or vim.uv.os_getenv 'SSH_TTY' ~= nil then
    set_osc52_clipboard()
  else
    check_wezterm_remote_clipboard(function(is_remote_wezterm)
      if is_remote_wezterm then set_osc52_clipboard() end
    end)
  end
end)
-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- UI Additions
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Shell to use for :terminal and shell commands
if vim.fn.has 'win32' == 1 then
  vim.o.shell = 'pwsh.exe'
  vim.o.shellcmdflag = '-NoLogo'
  vim.o.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF* %s; exit $LastExitCode'
  vim.o.shellquote = ''
  vim.o.shellxquote = ''
else
  vim.o.shell = '/usr/bin/fish'
end

if vim.g.neovide then
  vim.g.neovide_cursor_trail_size = 0.0
  vim.g.neovide_opacity = 0.8
end
