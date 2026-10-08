-- Markdown rendering in the buffer

---@module 'lazy'
---@type LazySpec
return {
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
}
