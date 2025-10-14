return {
  {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("obsidian").setup({
        workspaces = {
          {
            name = "nitani22",
            path = "~/research/",
          },
        },
        daily_notes = {
          folder = "daily",
          date_format = "%Y-%m-%d",
        },
        completion = {
          nvim_cmp = true,
        },
      })
    end,
  },
}
