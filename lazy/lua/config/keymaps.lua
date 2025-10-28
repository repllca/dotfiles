local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Insertモードでjjを押したらノーマルモードに戻る
map("i", "jj", "<Esc>", opts)

-- ノーマルモードとビジュアルモードでクリップボードにコピー
map("n", "<Leader>y", '"+y', opts)
map("v", "<Leader>y", '"+y', opts)
