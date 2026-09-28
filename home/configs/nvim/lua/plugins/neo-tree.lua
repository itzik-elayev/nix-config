return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = false,
      filesystem = { follow_current_file = { enabled = true } },
    },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("neo-tree.command").execute({ action = "show", position = "left" })
        end,
      })
    end,
  },
}
