-- ~/.config/nvim/lua/lualine/themes/darcula.lua
local colors = {
  bg = "#2B2B2B",
  fg = "#A9B7C6",
  yellow = "#FFC66D",
  cyan = "#A5C261",
  darkblue = "#287BDE",
  green = "#A5C261",
  orange = "#FF8647",
  violet = "#9876AA",
  magenta = "#D484FF",
  blue = "#6897BB",
  red = "#FF5370",
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
    b = { fg = colors.fg, bg = "#3C3F41" },
    c = { fg = colors.fg, bg = colors.bg },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.green, gui = "bold" },
    b = { fg = colors.fg, bg = "#3C3F41" },
    c = { fg = colors.fg, bg = colors.bg },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.magenta, gui = "bold" },
    b = { fg = colors.fg, bg = "#3C3F41" },
    c = { fg = colors.fg, bg = colors.bg },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.red, gui = "bold" },
    b = { fg = colors.fg, bg = "#3C3F41" },
    c = { fg = colors.fg, bg = colors.bg },
  },
  inactive = {
    a = { fg = colors.fg, bg = colors.bg, gui = "bold" },
    b = { fg = colors.fg, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.bg },
  },
}
