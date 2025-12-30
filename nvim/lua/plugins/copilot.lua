return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- ai.copilot(lua) を使ってるならこれ
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      language = "Japanese",
      window = { layout = "vertical", width = 0.4 },
    },
    keys = {
      { "<leader>ac", "<cmd>CopilotChat<cr>",        desc = "AI Chat" },
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", mode = "v",      desc = "AI Explain" },
      { "<leader>af", "<cmd>CopilotChatFix<cr>",     mode = "v",      desc = "AI Fix" },
    },
  },
}
