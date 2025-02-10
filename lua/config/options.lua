
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


vim.keymap.set("n", "<A-n>", ":cnext<CR>")
vim.keymap.set("n", "<A-p>", ":cprev<CR>")
vim.keymap.set("n", "<leader><Tab>", ":tabn<CR>")
vim.keymap.set("n", "<s-leader><Tab>", ":tabp<CR>")
vim.keymap.set("n", "<leader>n", ":bn<CR>")
vim.keymap.set("n", "<leader>p", ":bp<CR>")
vim.keymap.set("n", "<leader>q", ":bdelete<CR>")
