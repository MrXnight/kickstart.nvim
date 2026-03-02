-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      lsp_file_methods = { enabled = true },
      keymaps = {
        ['g?'] = 'actions.show_help',
      },
    },
    -- Optional dependencies
    -- dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  { 'mrjones2014/smart-splits.nvim', lazy = false },
  {
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      -- log_level = 'debug',
    },
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        -- config
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
  {
    'https://codeberg.org/ggandent/leap.nvim',
    -- "ggandent/leap.nvim" is also fine as long as the 'url' key is present below
    url = 'https://codeberg.org/andyg/leap.nvim.git',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      -- This line is required to enable the default mappings (s, S, gs)
      require('leap').add_default_mappings()
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
        if now - ram_cache.last_update >= 5 then -- Update every 5 seconds
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
              max_length = vim.o.columns * 1 / 2,
              filetype_names = {
                NvimTree = 'Explorer',
                TelescopePrompt = 'Telescope',
                lazy = 'Lazy',
                mason = 'Mason',
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
