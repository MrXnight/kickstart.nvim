-- Session saving and restoring

---@module 'lazy'
---@type LazySpec
return {
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
}
