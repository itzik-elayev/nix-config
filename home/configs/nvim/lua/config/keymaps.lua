-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- q starts macro recording by default; disable to avoid accidental triggers.
-- Record with Q instead.
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "q")
