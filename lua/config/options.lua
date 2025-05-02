
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- vim.opt.clipboard = "unnamedplus"

vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "


vim.keymap.set("n", "<A-n>", "<cmd>cnext<CR>", {desc = "Goto Next in quickfix"})
vim.keymap.set("n", "<A-p>", "<cmd>cprev<CR>", {desc = "Goto Prev in quickfix"})
vim.keymap.set("n", "<leader><Tab>", "<cmd>tabn<CR>", {desc = "Next Tab"})
vim.keymap.set("n", "<s-leader><Tab>", "<cmd>tabp<CR>", {desc = "Prev Tab"})
vim.keymap.set("n", "<leader>n", "<cmd>bn<CR>", {desc = "Change to nex buffer"})
vim.keymap.set("n", "<leader>p", "<cmd>bp<CR>", {desc = "Change to prev buffer"})

vim.keymap.set("v", "<leader>c", '"+y', {desc = "Copy to clipboard"})
vim.keymap.set("n", "<leader>c", '"+p', {desc = "Paste from clipboard"})
