
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = "unnamedplus"

vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "


vim.keymap.set("n", "<A-n>", ":cnext<CR>", {desc = "Goto Next in quickfix"})
vim.keymap.set("n", "<A-p>", ":cprev<CR>", {desc = "Goto Prev in quickfix"})
vim.keymap.set("n", "<leader><Tab>", ":tabn<CR>", {desc = "Next Tab"})
vim.keymap.set("n", "<s-leader><Tab>", ":tabp<CR>", {desc = "Prev Tab"})
vim.keymap.set("n", "<leader>n", ":bn<CR>", {desc = "Change to nex buffer"})
vim.keymap.set("n", "<leader>p", ":bp<CR>", {desc = "Change to prev buffer"})
vim.keymap.set("n", "<leader>qo", ":BufferLineCloseOthers<CR>", {desc = "Close all but buffer"})
vim.keymap.set("n", "<leader>qq", ":bdelete<CR>", {desc = "Close current buffer"})
