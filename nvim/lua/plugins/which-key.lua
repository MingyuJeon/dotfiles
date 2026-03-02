return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({})

    wk.add({
      mode = "n",
      prefix = "<leader>",
      f = {
        name = "File",
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
      },
      b = {
        name = "Buffer",
        b = { "<cmd>Telescope buffers<cr>", "List Buffers" },
      },
    })
  end,
}
