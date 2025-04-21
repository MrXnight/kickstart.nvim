vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
    enable_clippy = true,
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      vim.cmd.RustLsp 'flyCheck'
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {},
    },
  },
  -- DAP configuration
  dap = {},
}

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set('n', '<leader>a', function()
  vim.cmd.RustLsp 'codeAction'
end, { silent = true, buffer = bufnr })
vim.keymap.set('n', 'K', function()
  vim.cmd.RustLsp { 'hover', 'actions' }
end, { silent = true, buffer = bufnr })

for _, method in ipairs { 'textDocument/diagnostic', 'workspace/diagnostic' } do
  local default_diagnostic_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, result, context, config)
    if err ~= nil and err.code == -32802 then
      return
    end
    return default_diagnostic_handler(err, result, context, config)
  end
end
