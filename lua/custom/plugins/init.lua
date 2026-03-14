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
    'https://codeberg.org/ggandent/leap.nvim',
    -- "ggandent/leap.nvim" is also fine as long as the 'url' key is present below
    url = 'https://codeberg.org/andyg/leap.nvim.git',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
      vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Colors for custom components (catppuccin mocha palette)
      local colors = {
        blue = '#89b4fa',
        green = '#a6e3a1',
        yellow = '#f9e2af',
        red = '#f38ba8',
        mauve = '#cba6f7',
        peach = '#fab387',
        teal = '#94e2d5',
        subtext = '#a6adc8',
        surface = '#313244',
      }

      -- Detect OS
      local is_windows = vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1

      -- Function to get RAM usage
      local function get_ram_usage()
        local ram_used = 0
        local ram_total = 0

        if is_windows then
          -- Windows: Use wmic command
          local handle = io.popen 'wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value 2>nul'
          if handle then
            local result = handle:read '*a'
            handle:close()

            local free_mem = result:match 'FreePhysicalMemory=(%d+)'
            local total_mem = result:match 'TotalVisibleMemorySize=(%d+)'

            if free_mem and total_mem then
              ram_total = tonumber(total_mem) / 1024 / 1024 -- Convert KB to GB
              local ram_free = tonumber(free_mem) / 1024 / 1024
              ram_used = ram_total - ram_free
            end
          end
        else
          -- Linux: Use /proc/meminfo
          local meminfo = io.open('/proc/meminfo', 'r')
          if meminfo then
            local content = meminfo:read '*a'
            meminfo:close()

            local mem_total = content:match 'MemTotal:%s+(%d+)'
            local mem_available = content:match 'MemAvailable:%s+(%d+)'

            if mem_total and mem_available then
              ram_total = tonumber(mem_total) / 1024 / 1024 -- Convert KB to GB
              ram_used = ram_total - (tonumber(mem_available) / 1024 / 1024)
            end
          end
        end

        if ram_total > 0 then
          local percentage = (ram_used / ram_total) * 100
          return string.format('%.1fG', ram_used), percentage
        end

        return 'N/A', 0
      end

      -- Cache RAM usage to avoid frequent system calls
      local ram_cache = { value = '', percentage = 0, last_update = 0 }
      local function get_cached_ram()
        local now = os.time()
        if now - ram_cache.last_update >= 10 then -- Update every 10 seconds
          ram_cache.value, ram_cache.percentage = get_ram_usage()
          ram_cache.last_update = now
        end
        return ram_cache.value, ram_cache.percentage
      end

      -- Function to get time icon based on hour
      local function get_time_icon()
        local hour = tonumber(os.date '%H')
        if hour >= 6 and hour < 18 then
          return '󰖨' -- Day sun
        else
          return '󰖔' -- Night moon
        end
      end

      -- Function to get time icon color
      local function get_time_color()
        local hour = tonumber(os.date '%H')
        if hour >= 6 and hour < 18 then
          return { fg = colors.yellow }
        else
          return { fg = colors.blue }
        end
      end

      -- Helper function for buffer switching
      _G.lualine_buffer_switch = function(index)
        local buffers = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then table.insert(buffers, buf) end
        end
        if buffers[index] then vim.api.nvim_set_current_buf(buffers[index]) end
      end

      require('lualine').setup {
        options = {
          theme = 'catppuccin',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
          disabled_filetypes = {
            tabline = { 'NvimTree', 'neo-tree', 'dashboard' },
          },
        },

        -- Statusline (bottom)
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },

        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },

        -- Tabline (top) - buffers + diagnostics + RAM + time
        tabline = {
          lualine_a = {
            {
              'buffers',
              show_filename_only = true,
              hide_filename_extension = false,
              show_modified_status = true,
              mode = 4,
              max_length = vim.o.columns * 2 / 3,
              filetype_names = {
                Oil = 'Explorer',
                TelescopePrompt = 'Telescope',
                lazy = 'Lazy',
                mason = 'Mason',
                dashboard = 'Dashboard',
              },
              symbols = {
                modified = ' ●',
                alternate_file = '',
                directory = '',
              },
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {
            -- LSP diagnostics summary
            {
              'diagnostics',
              sources = { 'nvim_workspace_diagnostic' },
              sections = { 'error', 'warn', 'hint', 'info' },
              symbols = {
                error = ' ',
                warn = ' ',
                hint = '󰌵 ',
                info = ' ',
              },
              colored = true,
              update_in_insert = false,
              always_visible = false,
            },
            -- Separator
            {
              function() return '│' end,
              color = { fg = colors.surface },
              padding = { left = 1, right = 1 },
            },
            -- RAM Usage
            {
              function()
                local ram, percentage = get_cached_ram()
                local icon = '󰍛'
                if percentage > 80 then
                  icon = '󰀪'
                elseif percentage > 60 then
                  icon = '󰍛'
                end
                return icon .. ' ' .. ram
              end,
              color = function()
                local _, percentage = get_cached_ram()
                if percentage > 80 then
                  return { fg = colors.red }
                elseif percentage > 60 then
                  return { fg = colors.yellow }
                else
                  return { fg = colors.subtext }
                end
              end,
              padding = { left = 0, right = 1 },
            },
          },
          lualine_y = {
            -- Active LSP client
            {
              function()
                local clients = vim.lsp.get_clients { bufnr = 0 }
                if #clients == 0 then return '' end
                local client_names = {}
                for _, client in ipairs(clients) do
                  table.insert(client_names, client.name)
                end
                return ' ' .. table.concat(client_names, ', ')
              end,
              color = { fg = colors.blue },
              padding = { left = 1, right = 1 },
            },
            -- Separator
            {
              function() return '│' end,
              color = { fg = colors.surface },
              padding = { left = 0, right = 0 },
            },
            -- Time (HH:MM 24-hour format with day/night icon)
            {
              function() return get_time_icon() .. ' ' .. os.date '%H:%M' end,
              color = get_time_color,
              padding = { left = 1, right = 1 },
            },
          },
          lualine_z = {
            {
              'tabs',
              mode = 0,
              show_modified_status = false,
            },
          },
        },
      }

      -- Auto-refresh tabline every minute for time update
      local timer = vim.loop.new_timer()
      if timer then timer:start(60000, 60000, vim.schedule_wrap(function() vim.cmd 'redrawtabline' end)) end
    end,
  },
}
