-- Colorize color codes in buffers

---@module 'lazy'
---@type LazySpec
return {
  'catgoose/nvim-colorizer.lua',
  event = 'BufReadPre',
  opts = {},
}
