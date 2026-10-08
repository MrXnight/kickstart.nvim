-- Rust development (rust-analyzer, rustfmt)

---@module 'lazy'
---@type LazySpec
return {
  'mrcjkb/rustaceanvim',
  version = '^8', -- Recommended
  lazy = false, -- This plugin is already lazy
  enable_clippy = true,
  config = function()
    vim.g.rustaceanvim = {
      server = {
        ['rust-analyzer'] = {
          cargo = {
            buildScripts = {
              enable = true,
            },
            extraArgs = { '-Z', 'bindeps' },
            extraEnv = { RUSTC_BOOTSTRAP = '1' },
          },
          procMacro = {
            enable = true,
          },
          rustfmt = {
            extraArgs = { '--config', 'max_width=120' },
          },
        },
      },
    }
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.rs',
      callback = function() vim.lsp.buf.format { async = false } end,
    })
  end,
}
