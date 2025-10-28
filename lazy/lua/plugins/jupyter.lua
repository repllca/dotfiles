return {
  {
    "hkupty/iron.nvim",
    config = function()
      require("iron.core").setup({
        config = {
          repl_definition = {
            python = {
              command = { "ipython" },
            },
          },
          repl_open_cmd = "botright split 40vnew",
        },
        -- キーマップは自分で設定可能
      })
    end,
  },
}
