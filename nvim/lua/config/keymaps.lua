-- =========================================
-- Keymaps
-- =========================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- -----------------------------------------
-- 基本操作
-- -----------------------------------------

-- Insertモードで jj → Normalモード
map("i", "jj", "<Esc>", opts)

-- クリップボードにコピー
map("n", "<Leader>y", '"+y', opts)
map("v", "<Leader>y", '"+y', opts)

-- -----------------------------------------
-- Copilot / AI Context
-- -----------------------------------------

local ctx = require("config.copilot_context")

-- プロジェクトルート（docs参照先）を設定
vim.api.nvim_create_user_command("CopilotContextSet", function()
  ctx.set_root()
end, {})

-- docs/PROJECT_CONTEXT.md + CODE_INDEX.md を読み込んで質問
vim.api.nvim_create_user_command("CopilotAskDocs", function()
  ctx.ask_with_context()
end, {})

-- Visual選択 + docs を読み込んで質問
vim.api.nvim_create_user_command("CopilotAskDocsSel", function()
  ctx.ask_with_context_and_selection()
end, { range = true })


vim.api.nvim_create_user_command("CopilotProjectContextWizard", function()
  require("config.project_context_wizard").run()
end, {})

vim.keymap.set("n", "<leader>aP", "<cmd>CopilotProjectContextWizard<cr>", {
  desc = "AI: Project Context 作成ウィザード",
})

-- -----------------------------------------
-- CODE_INDEX 自動生成（段階 + 一括）
-- -----------------------------------------

vim.api.nvim_create_user_command("CodeIndexScan", function()
  require("config.code_index_builder").scan({ max_files = 250 })
end, {})

vim.api.nvim_create_user_command("CodeIndexBuild", function()
  require("config.code_index_builder").build_materials()
end, {})

vim.api.nvim_create_user_command("CodeIndexAsk", function()
  require("config.code_index_builder").ask()
end, {})

vim.api.nvim_create_user_command("CodeIndexApply", function()
  require("config.code_index_builder").apply()
end, {})

-- これ一発：材料生成 → Copilotへ投げる（回答後に Apply）
vim.api.nvim_create_user_command("CodeIndexAutoAll", function()
  require("config.code_index_builder").auto_all({ max_files = 250 })
end, {})

-- キー（好みで変更OK）
-- -----------------------------------------
-- Copilot / AI Keybindings
-- -----------------------------------------

-- Context root 設定
map("n", "<leader>aR", "<cmd>CopilotContextSet<cr>", {
  desc = "AI: Set Context Root",
})

-- docs を前提に質問（Normal）
map("n", "<leader>aQ", "<cmd>CopilotAskDocs<cr>", {
  desc = "AI: Ask with Docs Context",
})

-- docs + 選択コードを前提に質問（Visual）
map("v", "<leader>aQ", "<cmd>CopilotAskDocsSel<cr>", {

})

vim.keymap.set("n", "<leader>aS", "<cmd>CodeIndexScan<cr>", { desc = "AI: CodeIndex scan (cache)" })
vim.keymap.set("n", "<leader>aM", "<cmd>CodeIndexBuild<cr>", { desc = "AI: CodeIndex materials" })
vim.keymap.set("n", "<leader>aK", "<cmd>CodeIndexAsk<cr>", { desc = "AI: CodeIndex ask Copilot" })
vim.keymap.set("n", "<leader>aA", "<cmd>CodeIndexAutoAll<cr>", { desc = "AI: CodeIndex auto all" })
vim.keymap.set("n", "<leader>aB", "<cmd>CodeIndexApply<cr>", { desc = "AI: CodeIndex apply" })
