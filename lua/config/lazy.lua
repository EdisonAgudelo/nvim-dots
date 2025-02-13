
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0


-- Setup lazy.nvim
require("lazy").setup({
    defaults = {
        version = "*"
    },
    spec = {
        -- import plugins
        {
            -- Color scheme 
            -- -- get rid of vim symbol not defined
            "folke/tokyonight.nvim",
            lazy = false, -- make sure we load this during startup if it is your main colorscheme
            priority = 1000, -- make sure to load this before all the other start plugins
            config = function()
                -- load the colorscheme here
                vim.cmd([[colorscheme tokyonight]])
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",

            config = function()
                require("nvim-treesitter.install").compilers = { "clang", "gcc" }
                require("nvim-treesitter.configs").setup({
                    modules = {},
                    ignore_install = {},

                    ensure_installed = {"c", "lua", "vim", "vimdoc", "query", "python", "markdown"},
                    sync_install = false,
                    auto_install = true,

                    indent = {
                        enable = true
                    },
                    highlight = {
                        enable = true
                    },


                    -- Make vim visual mode aware of incremental scopes
                    -- As keymaps suggest, should be started with init, and then increment/decrement

                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "<Leader>ss",
                            node_incremental = "<Leader>si",
                            scope_incremental = "<Leader>sc",
                            node_decremental = "<Leader>sd",
                        },
                    },

                    -- This extend vim to make it aware of more selection objects
                    -- Before, there was only word, "" {} [] ()
                    -- Now, functions, clases and scopes

                    textobjects = {
                        select = {
                            enable = true,

                            -- Automatically jump forward to textobj, similar to targets.vim
                            lookahead = true,

                            keymaps = {
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                ["ac"] = "@class.outer",
                                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                                ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                            },
                            selection_modes = {
                                ["@parameter.outer"] = "v", -- charwise
                                ["@function.outer"] = "v", -- linewise
                                ["@class.outer"] = "<c-v>", -- blockwise
                            },
                            -- If you set this to `true` (default is `false`) then any textobject is
                            -- extended to include preceding or succeeding whitespace. Succeeding
                            -- whitespace has priority in order to act similarly to eg the built-in
                            -- `ap`.
                            include_surrounding_whitespace = true,
                        },
                    },
                })

            end,
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects"
        },
        {
            "neovim/nvim-lspconfig",
            keys = {
                {"gD", "<cmd>lua vim.lsp.buf.declaration()<CR>",  desc = "Goto Declaration"},
                {"gd", "<cmd>lua vim.lsp.buf.definition()<CR>",  desc = "Goto Definition"},
                {"gr", "<cmd>lua vim.lsp.buf.references()<CR>",  desc = "Show References"},
            },
        },
        {
            "williamboman/mason.nvim",
            cmd = "Mason",
            config = function ()
                require("mason").setup()
            end
        },
        {
            "williamboman/mason-lspconfig.nvim",
            dependecies = {"nvim-lspconfig", "saghen/blink.cmp"},
            config = function()
                local capabilities = require("blink.cmp").get_lsp_capabilities()
                local custom_settings = {
                    ["clangd"] = {
                        capabilities = capabilities,
                        -- do not auto include files
                        cmd = { "clangd", "-header-insertion=never" }
                    },
                    ["lua_ls"] = {
                        capabilities = capabilities,
                        -- get rid of vim symbol not defined
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                diagnostics = {
                                    -- Get the language server to recognize the `vim` global
                                    globals = { "vim" },
                                },
                                workspace = {
                                    -- Make the server aware of Neovim runtime files
                                    library = vim.api.nvim_get_runtime_file("", true),
                                },
                                telemetry = {
                                    enable = false,
                                },
                            },
                        },
                    }
                }
                require("mason-lspconfig").setup()
                require("mason-lspconfig").setup_handlers({
                    function(server_name)
                        local settings = custom_settings[server_name]
                        if not settings then
                            settings = {
                                capabilities = capabilities,
                            }
                        end
                        require("lspconfig")[server_name].setup(
                            settings
                        )
                    end,
                })
            end,
        },
        {
            "saghen/blink.cmp",
            -- optional: provides snippets for the snippet source
            dependencies = "rafamadriz/friendly-snippets",

            -- use a release tag to download pre-built binaries
            version = "*",
            ---@module "blink.cmp"
            ---@type blink.cmp.Config
            opts = {
                keymap = {
                    preset = "default",
                    ["<Tab>"] = {
                        function(cmp)
                            if cmp.snippet_active() then return cmp.accept()
                            else return cmp.select_and_accept() end
                        end,
                        "snippet_forward",
                        "fallback"
                    },
                },
                sources = {
                    default = { "lsp", "path", "snippets", "buffer" , "markdown" },
                    providers = {
                        markdown = {
                            name = "RenderMarkdown",
                            module = "render-markdown.integ.blink",
                            fallbacks = { "lsp" },
                        },
                    },
                },
                completion = {
                    menu = {
                        auto_show = function(ctx)
                            return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
                        end,
                    },
                    list = {
                        selection = {auto_insert = true, preselect = false}
                    },
                    trigger = {
                        show_on_keyword = true
                    },
                    documentation = { auto_show = true, auto_show_delay_ms = 500 },
                    ghost_text = { enabled = true },

                },
                signature = { enabled = true }

            },

            opts_extend = { "sources.default" }
        },
        {
            "normen/vim-pio",
            lazy = true,
            cmd = {
                "PIO",
                "PIOInit"
            },
            keys = {
                { "<leader>ii", "<cmd>PIOInit<cr>", desc = "Init or update build information PIO project" },
                { "<leader>iu", "<cmd>make upload<cr>", desc = "Build and upload PIO project" },
                { "<leader>ic", "<cmd>make clean<cr>", desc = "Clean build PIO project" }
            }

        },
        {
            "nvim-telescope/telescope.nvim",  branch = "0.1.x",
            dependencies = { "nvim-lua/plenary.nvim" },
            keys = {
                {"<leader>ff", desc = "Find file"},
                {"<leader>fg", desc = "Find in files"},
                {"<leader>fb", desc = "Find in buffer"},
                {"<leader>fh", desc = "Find help"},
            },
            cmd = "Telescope",
            config = function ()
                local builtin = require("telescope.builtin")
                vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
                vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
                vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
                vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
            end,
        },
        {
            "nvim-tree/nvim-tree.lua",
            version = "*",
            lazy = false,
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
            config = function()
                require("nvim-tree").setup {}
                local api = require("nvim-tree.api")

                vim.keymap.set("n", "<leader>ee", function ()
                    api.tree.toggle({find_file = true})
                end, { desc = "Toggle file explorer" })
            end,
        },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            lazy = true,
            ft = "markdown",
            dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
            ---@module "render-markdown"
            ---@type render.md.UserConfig
            opts = {},
        },
        {
            "jghauser/follow-md-links.nvim",
            config = function()
                vim.keymap.set("n", "<bs>", ":edit #<cr>", { silent = true })
            end,
        },
        {
            -- colored statuls line, quyte simple
            "echasnovski/mini.statusline",
            version = "*" ,
            config = function ()
                require("mini.statusline").setup({
                    set_vim_settings = true
                })
            end
        },
        {
            -- for buffer "tabs"
            "akinsho/bufferline.nvim",
            version = "*",
            dependencies = "nvim-tree/nvim-web-devicons",
            config = function ()
                require("bufferline").setup({
                    options={
                        numbers = "buffer_id",
                        offsets = {
                            {
                                filetype = "NvimTree",
                                separator = true
                            }
                        },
                        close_command = "silent! bdelete %d",       -- can be a string | function, | false see "Mouse actions"
                    }
                })
                vim.keymap.set("n", "<leader>qo", "<cmd>BufferLineCloseOthers<CR>", {desc = "Close all but buffer"})
                vim.keymap.set("n", "<leader>qq", "<cmd>bdelete<CR>", {desc = "Close current buffer"})
            end
        },
        -- {
        --     already in nvim core
        --     "echasnovski/mini.comment",
        --     version = "*",
        --     config = function ()
        --         require("mini.comment").setup()
        --     end,
        -- },
        {
            "tpope/vim-surround"
        },
        {
            "kdheepak/lazygit.nvim",
            lazy = true,
            cmd = {
                "LazyGit",
                "LazyGitConfig",
                "LazyGitCurrentFile",
                "LazyGitFilter",
                "LazyGitFilterCurrentFile",
            },
            -- optional for floating window border decoration
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            keys = {
                { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
            }
        },
        {
            "lewis6991/gitsigns.nvim",
            config = function ()
                require("gitsigns").setup()
            end,
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {
                preset = "modern",
                delay = 500
            },
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
        },
        {
            "folke/trouble.nvim",
            opts = {},
            cmd = "Trouble",
            keys = {
                {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
            },
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = ":call mkdp#util#install()",
        }
    },
    -- automatically check for plugin updates
    checker = { enabled = false },
})
