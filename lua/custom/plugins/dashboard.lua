-- Startup dashboard

---@module 'lazy'
---@type LazySpec
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local logo = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡾⠛⠛⠛⠳⢦⣤⣀⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣷⢿⠀⠀⠀⠿⠇⠀⠈⠹⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠋⠙⠛⠛⠀⠀⠀⠀⠀⣶⣶⡶⠏
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠁⠀⠀⠀⠀⠀⠀⢀⣴⠟⠋⠉⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡟⠀⠀⠀⠀⠀⠀⠀⠀⣾⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⠃⢠⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠃⢀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡟⠁⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣧⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡶⠋⠁⠀⠀⠀⠀⣸⡄⠀⠀⠀⠀⠈⡇⠀⠀⠀⠀⣼⢻⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠾⠛⠁⠀⠀⠀⠀⠀⠀⣰⡏⠉⠀⠀⠀⠀⢠⡇⠀⠀⢀⣼⠏⢸⠃⠀⠀⠀⠀⠀⠀⠀
    ]]

    logo = string.rep('\n', 2) .. logo .. '\n\n'

    local function get_footer()
      local version = vim.version()
      local nvim_version = 'v' .. version.major .. '.' .. version.minor .. '.' .. version.patch
      local datetime = os.date ' %Y-%m-%d   %H:%M'

      -- Safely get lazy stats
      local lazy_ok, lazy = pcall(require, 'lazy')
      if lazy_ok and lazy.stats then
        local stats = lazy.stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return {
          '',
          '',
          '⚡ Neovim ' .. nvim_version .. '   |   ' .. stats.loaded .. '/' .. stats.count .. ' plugins   |   ' .. ms .. 'ms',
          datetime,
        }
      else
        return {
          '',
          '',
          '⚡ Neovim ' .. nvim_version,
          datetime,
        }
      end
    end

    require('dashboard').setup {
      theme = 'doom',
      hide = {
        statusline = true,
        tabline = true,
        winbar = true,
      },
      config = {
        header = vim.split(logo, '\n'),
        center = {
          {
            action = 'lua Snacks.picker.files()',
            desc = ' Find File',
            icon = '󰈞 ',
            key = 'f',
            icon_hl = 'DashboardFind',
            key_hl = 'DashboardKey',
          },
          {
            action = 'ene | startinsert',
            desc = ' New File',
            icon = '󰈔 ',
            key = 'n',
            icon_hl = 'DashboardNew',
            key_hl = 'DashboardKey',
          },
          {
            action = 'lua Snacks.picker.recent()',
            desc = ' Recent Files',
            icon = '󰷊 ',
            key = 'r',
            icon_hl = 'DashboardRecent',
            key_hl = 'DashboardKey',
          },
          {
            action = 'lua Snacks.picker.grep()',
            desc = ' Find Word',
            icon = '󰺮 ',
            key = 'g',
            icon_hl = 'DashboardGrep',
            key_hl = 'DashboardKey',
          },
          {
            action = function() require('persistence').load { last = true } end,
            desc = ' Restore Session',
            icon = '󰦛 ',
            key = 's',
            icon_hl = 'DashboardSession',
            key_hl = 'DashboardKey',
          },
          {
            action = function()
              vim.cmd 'bd'
              require('oil').open()
            end,
            desc = ' File Explorer',
            icon = '󰉓 ',
            key = 'e',
            icon_hl = 'DashboardExplorer',
            key_hl = 'DashboardKey',
          },
          {
            action = 'e $MYVIMRC',
            desc = ' Config',
            icon = '󰈞 ',
            key = 'c',
            icon_hl = 'DashboardConfig',
            key_hl = 'DashboardKey',
          },
          {
            action = 'qa',
            desc = ' Quit',
            icon = '󰈆 ',
            key = 'q',
            icon_hl = 'DashboardQuit',
            key_hl = 'DashboardKey',
          },
        },
        footer = get_footer,
      },
    }

    -- Custom highlight groups (catppuccin colors)
    -- Custom highlight groups (catppuccin colors)
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        -- Fetch the current Catppuccin palette dynamically
        local C = require('catppuccin.palettes').get_palette()

        vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = C.blue })
        vim.api.nvim_set_hl(0, 'DashboardCenter', { fg = C.text })
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = C.overlay0 })
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = C.peach, bold = true })
        vim.api.nvim_set_hl(0, 'DashboardFind', { fg = C.blue })
        vim.api.nvim_set_hl(0, 'DashboardNew', { fg = C.green })
        vim.api.nvim_set_hl(0, 'DashboardRecent', { fg = C.yellow })
        vim.api.nvim_set_hl(0, 'DashboardGrep', { fg = C.mauve })
        vim.api.nvim_set_hl(0, 'DashboardProjects', { fg = C.teal })
        vim.api.nvim_set_hl(0, 'DashboardSession', { fg = C.pink })
        vim.api.nvim_set_hl(0, 'DashboardLazy', { fg = C.sapphire })
        vim.api.nvim_set_hl(0, 'DashboardConfig', { fg = C.peach })
        vim.api.nvim_set_hl(0, 'DashboardQuit', { fg = C.red })
      end,
    })
    -- Trigger highlights on startup
    vim.cmd 'doautocmd ColorScheme'
  end,
}
