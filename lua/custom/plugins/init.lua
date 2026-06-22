-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
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
  },
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      require('smart-splits').setup {
        set_environment_variables = true,
        multiplexer_integration = 'wezterm',
        default_amount = 3,
        at_edge = 'stop',
      }
      -- recommended mappings
      -- resizing splits
      -- these keymaps will also accept a range,
      -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
      vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
      vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
      vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
      vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
      -- moving between splits
      vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
      vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
      vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
      vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
      vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
      -- swapping buffers between windows
      vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
      vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
      vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
      vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
    end,
  },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    config = function()
      require('persistence').setup {
        dir = vim.fn.stdpath 'state' .. '/sessions/',
        need = 1,
        branch = true,
      }

      -- Close all terminals before saving session
      local function close_terminals()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local buftype = vim.bo[buf].buftype
            if buftype == 'terminal' then vim.api.nvim_buf_delete(buf, { force = true }) end
          end
        end
      end

      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = vim.api.nvim_create_augroup('PersistenceAutoSave', { clear = true }),
        callback = function()
          --close terminals
          close_terminals()

          local dominated_by_special_buf = false
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local ft = vim.bo[buf].filetype
              local bt = vim.bo[buf].buftype
              if ft == 'dashboard' or ft == 'gitcommit' or ft == 'gitrebase' or ft == 'lazy' or ft == 'mason' or bt == 'nofile' then
                dominated_by_special_buf = true
              else
                dominated_by_special_buf = false
                break
              end
            end
          end

          if not dominated_by_special_buf then require('persistence').save() end
        end,
      })
    end,
    keys = {
      { '<leader>Sr', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>Sl', function() require('persistence').load { last = true } end, desc = 'Restore last session' },
      { '<leader>Ss', function() require('persistence').select() end, desc = 'Select session' },
      { '<leader>SS', function() require('persistence').save() end, desc = 'Save session' },
      { '<leader>Sd', function() require('persistence').stop() end, desc = 'Disable auto-save' },
      {
        '<leader>SD',
        function()
          local session_dir = vim.fn.stdpath 'state' .. '/sessions/'
          local cwd = vim.fn.getcwd():gsub('/', '%%'):gsub(':', '%%')
          local branch = ''

          local handle = io.popen 'git branch --show-current 2>/dev/null'
          if handle then
            branch = handle:read('*a'):gsub('%s+', '')
            handle:close()
          end

          local session_file = session_dir .. cwd
          if branch ~= '' then session_file = session_file .. '@@' .. branch end
          session_file = session_file .. '.vim'

          if vim.fn.filereadable(session_file) == 1 then
            vim.fn.delete(session_file)
            vim.notify('Session deleted', vim.log.levels.INFO)
          else
            vim.notify('No session file found', vim.log.levels.WARN)
          end
        end,
        desc = 'Delete session',
      },
    },
  },
  {
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
              action = 'Telescope find_files',
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
              action = 'Telescope oldfiles',
              desc = ' Recent Files',
              icon = '󰷊 ',
              key = 'r',
              icon_hl = 'DashboardRecent',
              key_hl = 'DashboardKey',
            },
            {
              action = 'Telescope live_grep',
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
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#89b4fa' }) -- Blue
          vim.api.nvim_set_hl(0, 'DashboardCenter', { fg = '#cdd6f4' }) -- Text
          vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#6c7086' }) -- Overlay
          vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#fab387', bold = true }) -- Peach
          vim.api.nvim_set_hl(0, 'DashboardFind', { fg = '#89b4fa' }) -- Blue
          vim.api.nvim_set_hl(0, 'DashboardNew', { fg = '#a6e3a1' }) -- Green
          vim.api.nvim_set_hl(0, 'DashboardRecent', { fg = '#f9e2af' }) -- Yellow
          vim.api.nvim_set_hl(0, 'DashboardGrep', { fg = '#cba6f7' }) -- Mauve
          vim.api.nvim_set_hl(0, 'DashboardProjects', { fg = '#94e2d5' }) -- Teal
          vim.api.nvim_set_hl(0, 'DashboardSession', { fg = '#f5c2e7' }) -- Pink
          vim.api.nvim_set_hl(0, 'DashboardLazy', { fg = '#74c7ec' }) -- Sapphire
          vim.api.nvim_set_hl(0, 'DashboardConfig', { fg = '#fab387' }) -- Peach
          vim.api.nvim_set_hl(0, 'DashboardQuit', { fg = '#f38ba8' }) -- Red
        end,
      })

      -- Trigger highlights on startup
      vim.cmd 'doautocmd ColorScheme'
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
      { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
    },
  },
  {
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

            return statusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diag } },
              '%<',
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=',
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = 'MiniStatuslineLocation', strings = { search, location } },
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
    end,
  },
  {
    'echasnovski/mini.tabline',
    version = '*',
    config = function()
      local function get_time_icon()
        local hour = tonumber(os.date '%H')
        return hour >= 6 and hour < 18 and '󰖨' or '󰖔'
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        if #clients == 0 then return '' end
        local names = {}
        for _, c in ipairs(clients) do
          table.insert(names, c.name)
        end
        return ' ' .. table.concat(names, ', ')
      end

      local function workspace_diagnostics()
        local counts = { error = 0, warn = 0, hint = 0, info = 0 }
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            counts.error = counts.error + #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
            counts.warn = counts.warn + #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN })
            counts.hint = counts.hint + #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.HINT })
            counts.info = counts.info + #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.INFO })
          end
        end
        local parts = {}
        if counts.error > 0 then table.insert(parts, '%#TablineDiagError# ' .. counts.error) end
        if counts.warn > 0 then table.insert(parts, '%#TablineDiagWarn# ' .. counts.warn) end
        if counts.hint > 0 then table.insert(parts, '%#TablineDiagHint#󰌵 ' .. counts.hint) end
        if counts.info > 0 then table.insert(parts, '%#TablineDiagInfo# ' .. counts.info) end
        return table.concat(parts, ' ')
      end

      local function get_tabpages()
        local tabs = vim.api.nvim_list_tabpages()
        local current = vim.api.nvim_get_current_tabpage()
        local parts = {}

        for i, tab in ipairs(tabs) do
          local win = vim.api.nvim_tabpage_get_win(tab)
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
          if name == '' then name = '[No Name]' end

          local hl = tab == current and '%#TablineCurrent#' or '%#TablineHidden#'
          table.insert(parts, hl .. ' ' .. i .. ':' .. name .. ' ')
        end

        return table.concat(parts, '')
      end

      -- Define highlight groups
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'TabLineFill', { bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineCurrent', { fg = '#cdd6f4', bg = '#45475a', bold = true })
          vim.api.nvim_set_hl(0, 'TablineHidden', { fg = '#6c7086', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineDiagError', { fg = '#f38ba8', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineDiagWarn', { fg = '#f9e2af', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineDiagHint', { fg = '#94e2d5', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineDiagInfo', { fg = '#89b4fa', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineLsp', { fg = '#89b4fa', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineTime', { fg = '#f9e2af', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineTimeNight', { fg = '#89b4fa', bg = '#181825' })
          vim.api.nvim_set_hl(0, 'TablineSep', { fg = '#6c7086', bg = '#181825' })
        end,
      })
      vim.cmd 'doautocmd ColorScheme'

      _G.MyTabline = function()
        local left_section = get_tabpages()

        local right_parts = {}

        local diag = workspace_diagnostics()
        if diag ~= '' then table.insert(right_parts, diag) end

        local lsp = lsp_clients()
        if lsp ~= '' then table.insert(right_parts, '%#TablineLsp#' .. lsp) end

        local hour = tonumber(os.date '%H')
        local time_hl = hour >= 6 and hour < 18 and '%#TablineTime#' or '%#TablineTimeNight#'
        local time = get_time_icon() .. ' ' .. os.date '%H:%M'
        table.insert(right_parts, time_hl .. time)

        local sep = '%#TablineSep# │ '
        local right_section = table.concat(right_parts, sep) .. ' '

        return left_section .. '%T%#TabLineFill#%=' .. right_section
      end

      vim.o.tabline = '%!v:lua.MyTabline()'
      vim.o.showtabline = 2

      vim.api.nvim_create_autocmd({ 'TabEnter', 'BufEnter', 'BufWritePost', 'DiagnosticChanged', 'LspAttach', 'LspDetach' }, {
        callback = function() vim.cmd 'redrawtabline' end,
      })

      local timer = vim.loop.new_timer()
      if timer then timer:start(60000, 60000, vim.schedule_wrap(function() vim.cmd 'redrawtabline' end)) end
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      file_types = { 'markdown' },
      render_modes = { 'n', 'i', 'c' },
      anti_conceal = { enabled = false },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)

      -- Attach to blink.cmp documentation windows
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'blink-cmp-documentation',
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          if win ~= -1 then
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = 'niv'
          end
          require('render-markdown.api').enable(args.buf)
        end,
      })
    end,
  },
  {
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
    },
  },
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^8', -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
      vim.g.rustaceanvim = {
        server = {
          ['rust-analyzer'] = {
            check = { command = 'clippy' },
          },
        },
      }
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rs',
        callback = function() vim.lsp.buf.format { async = false } end,
      })
    end,
  },
  {
    's3rvac/vim-syntax-yara',
  },
}
