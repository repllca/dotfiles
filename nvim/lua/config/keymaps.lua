-- ~/dotfiles/nvim/lua/config/keymaps.lua の末尾に追記

local map = vim.keymap.set

-- インサートモード中に jj でノーマルモードに戻る
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
