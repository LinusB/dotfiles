-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- basic ones
vim.keymap.set("i", "jj", "<Esc>")

-- pasting better
vim.keymap.set("x", "<leader>p", '"_dP')

-- call File Explorer (Snacks)
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Toggle Explorer" })

-- changing Tabs easier
vim.keymap.set("n", "<leader><Left>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "<leader><Right>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Tab" })
