
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

local has_words_before = function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == 0 then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  return line:sub(col, col):match("%s") == nil
end

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
                {"grr", "<cmd>lua vim.lsp.buf.references()<CR>",  desc = "Show References"},
                {"grn", "<cmd>lua vim.lsp.buf.rename()<CR>",  desc = "Rename Symbol"},
            },
        },
        {
            "mason-org/mason.nvim",
            cmd = "Mason",
            config = function ()
                require("mason").setup()
            end
        },
        {
            "mason-org/mason-lspconfig.nvim",
            dependencies = {"nvim-lspconfig", "saghen/blink.cmp"},
            config = function()

                local capabilities = vim.lsp.protocol.make_client_capabilities()

                -- for text auto completion
                capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))

                -- for folding capabilities
                capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true
                }

                vim.lsp.config("*", {capabilities = capabilities})

                vim.lsp.config(
                    "pylsp", {
                        capabilities = capabilities,
                        settings = {
                            pylsp = {
                                plugins = {
                                    pycodestyle = {
                                        enabled = false,
                                    },
                                    rope_autoimport = {
                                        enabled = true,
                                        completions = {
                                            enabled = false
                                        }
                                    }
                                }
                            }
                        }
                    })
                vim.lsp.config(
                    "clangd" , {
                        capabilities = capabilities,
                        -- do not auto include files
                        cmd = { "clangd", "-header-insertion=never" }
                    })
                vim.lsp.config(
                    "lua_ls" , {
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
                    })

                require("mason-lspconfig").setup()
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
                    preset ="super-tab",
                },
                sources = {
                    default = { "lsp", "path", "snippets", "buffer" },
                    providers = {
                        cmdline = {
                            -- ignores cmdline completions when executing shell commands
                            enabled = function()
                                return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
                            end
                        }
                    }
                },
                completion = {
                    menu = { enabled = true},
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
            config = function()
                require('render-markdown').setup({
                    completions = { blink = { enabled = true } },
                })
            end,
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
        },
        {
            'linux-cultist/venv-selector.nvim',
            dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim'},
            opts = {
                -- Your options go here
                name = {"venv", ".venv"},
                auto_refresh = false
            },
            event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping

            keys = {
                -- Keymap to open VenvSelector to pick a venv.
                { '<leader>vv', '<cmd>VenvSelect<cr>', desc = "Select venv" },
                -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
                { '<leader>vc', '<cmd>VenvSelectCached<cr>', desc = "Select venv cached" },
            }
        },
        {
            "3rd/image.nvim",
            opts = {
                backend = "kitty",
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        filetypes = { "markdown"}, -- markdown extensions (ie. quarto) can go here
                    },
                },
                max_width = nil,
                max_height = nil,
                max_width_window_percentage = nil,
                max_height_window_percentage = 50,
                kitty_method = "normal",
            },
            ft = "markdown"
        },
        {
            "aznhe21/actions-preview.nvim",
            config = function()
                vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)
            end,
        },
        {
            "kevinhwang91/nvim-ufo",
            dependencies = "kevinhwang91/promise-async",
            config = function ()
                vim.o.foldcolumn = '1' -- '0' is not bad
                vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
                vim.o.foldlevelstart = 99
                vim.o.foldenable = true

                -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
                vim.keymap.set('n', 'zR', require('ufo').openAllFolds,  { desc = "Open all folds"})
                vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = "Close all folds"})


                local fold_formater = function(virtText, lnum, endLnum, width, truncate)
                    local newVirtText = {}
                    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
                    local sufWidth = vim.fn.strdisplaywidth(suffix)
                    local targetWidth = width - sufWidth
                    local curWidth = 0
                    for _, chunk in ipairs(virtText) do
                        local chunkText = chunk[1]
                        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if targetWidth > curWidth + chunkWidth then
                            table.insert(newVirtText, chunk)
                        else
                            chunkText = truncate(chunkText, targetWidth - curWidth)
                            local hlGroup = chunk[2]
                            table.insert(newVirtText, {chunkText, hlGroup})
                            chunkWidth = vim.fn.strdisplaywidth(chunkText)
                            -- str width returned from truncate() may less than 2nd argument, need padding
                            if curWidth + chunkWidth < targetWidth then
                                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                            end
                            break
                        end
                        curWidth = curWidth + chunkWidth
                    end
                    table.insert(newVirtText, {suffix, 'MoreMsg'})
                    return newVirtText
                end


                require("ufo").setup({
                    fold_virt_text_handler = fold_formater,
                    provider_selector = function (bufnr, filetype, buftype)
                        return { "lsp", "indent" }
                    end
                })
            end
        },
        {
            "mfussenegger/nvim-dap",
            keys = {
                {"<leader>b"},
            },
            config = function ()
                local dap = require("dap")
                vim.keymap.set('n', '<F4>', function()  dap.run_to_cursor() end, {desc = "Debug run to"})
                vim.keymap.set('n', '<F5>', function()  dap.continue() end, {desc = "Debug continue"})
                vim.keymap.set('n', '<F10>', function() dap.step_over() end, {desc = "Debug step over"})
                vim.keymap.set('n', '<F11>', function() dap.step_into() end, {desc = "Debug step into"})
                vim.keymap.set('n', '<F12>', function() dap.step_out() end, {desc = "Debug step out"})
                vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint"})
                vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = "Debug Evaluate expression"})
                vim.keymap.set({'n', 'v'}, '<leader>dh', function()  require('dap.ui.widgets').hover() end, { desc = "Debug show value"})

            end
        },
        {
            "rcarriga/nvim-dap-ui",
            dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
            keys = {
                {"<leader>b"},
            },
            config = function ()
                local dap, dapui = require("dap"), require("dapui")
                dap.listeners.before.attach.dapui_config = function()
                    dapui.open()
                end
                dap.listeners.before.launch.dapui_config = function()
                    dapui.open()
                end
                dap.listeners.before.event_terminated.dapui_config = function()
                    dapui.close()
                end
                dap.listeners.before.event_exited.dapui_config = function()
                    dapui.close()
                end
                vim.fn.sign_define("DapBreakpoint", {text = "🔴", texthl = "", linehl="", numhl=""})
                vim.fn.sign_define("DapStopped", {text = "🟢", texthl = "", linehl="", numhl=""})
                dapui.setup()
            end
        },
        {
            "jay-babu/mason-nvim-dap.nvim",
            dependencies = {
                "mfussenegger/nvim-dap",
                "mason-org/mason.nvim",
            },
            keys = {
                {"<leader>b"},
            },
            config = function ()
                require("mason-nvim-dap").setup({
                    ensure_installed = {},
                    automatic_installation = false,
                    handlers = {},
                })
            end
        }
    },
    -- automatically check for plugin updates
    checker = { enabled = false },
})


