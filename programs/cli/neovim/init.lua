local set = vim.opt
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.wildmode = "longest,list,full"
set.backspace = "indent,eol,start"
set.number = true
set.showcmd = true
set.ignorecase = true
set.smartcase = true
set.incsearch = true
set.splitright = true
-- Soft wrap at the edge of screen.
-- No break in the middle of word.
set.wrap = true
set.linebreak = true
set.scrolloff = 8
-- set.sidescroll = 1
-- set.sidescrolloff = 8
set.cmdwinheight = 1
set.clipboard:append("unnamedplus")

local g = vim.g
g.tex_flavor = "latex"

-- Put your favorite colorscheme here
set.termguicolors = true

-- Fold
set.foldcolumn = "1" -- '0' is not bad
set.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
set.foldlevelstart = 99
set.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

-- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
-- require('ufo').setup({
-- provider_selector = function(bufnr, filetype, buftype)
-- return {'lsp', 'treesitter'}
-- end
-- })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- Cancel luasnip session when changing mode.
-- More at https://github.com/L3MON4D3/LuaSnip/issues/258
vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function()
		if
			((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
			and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
			and not require("luasnip").session.jump_active
		then
			require("luasnip").unlink_current()
		end
	end,
})

-- Vimtex
g.vimtex_view_method = "zathura"
g.vimtex_compiler_latexmk_engines = {
	_ = "-xelatex",
}

--  have a fixed column for the diagnostics to appear in
--  this removes the jitter when warnings/errors flow in
set.signcolumn = "yes"

--  Set updatetime for CursorHold
--  300ms of no cursor movement to trigger CursorHold
set.updatetime = 300
--  Show diagnostic popup on cursor hover
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	command = "lua vim.diagnostic.open_float(nil, { focusable = false })",
})

-- Custom mappings
g.mapleader = ";"
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ":", "q:i")
vim.keymap.set("n", "/", "q/i")
vim.keymap.set("n", "?", "q?i")
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a")
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")
vim.keymap.set("n", "<F6>", "<cmd>source ~/.config/nvim/init.vim<CR>")
vim.keymap.set("n", "<Leader>en", vim.diagnostic.goto_next)
vim.keymap.set("n", "<Leader>eN", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<Leader>ef", vim.lsp.buf.code_action)
vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename)

-- Completion by nvim-cmp
set.completeopt = "menu,menuone,noselect"

local has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local lspkind = require("lspkind")
local luasnip = require("luasnip")
local cmp = require("cmp")
cmp.setup({
	enabled = function()
		-- disable completion in comments
		local context = require("cmp.config.context")
		-- keep command mode completion enabled when cursor is in a comment
		if vim.api.nvim_get_mode().mode == "c" then
			return true
		else
			return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
		end
	end,
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	-- Cycle through completions with tab
	mapping = {
		["<C-x>"] = cmp.mapping.complete({
			config = {
				sources = {
					{ name = "copilot" },
				},
			},
		}),
		["<C-c>"] = cmp.mapping.abort(),
		["<C-Space>"] = cmp.mapping.confirm({
			select = true,
			behavior = cmp.ConfirmBehavior.Replace,
		}),
		["<Tab>"] = vim.schedule_wrap(function(fallback)
			-- if cmp.visible() and has_words_before() then
			if cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end),
		["<S-Tab>"] = vim.schedule_wrap(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end),
	},
	sources = cmp.config.sources({
		{ name = "copilot" },
		{ name = "nvim_lsp",
			option = {
				markdown_oxide = {
					keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
				}
			}
		},
		-- { name = "vsnip" }, -- For vsnip users.
		{ name = "luasnip" }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol", -- show only symbol annotations
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

			symbol_map = { Copilot = "" },
			-- The function below will be called before any actual modifications from lspkind
			-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			before = function(entry, vim_item)
				return vim_item
			end,
		}),
	},
	sorting = {
		priority_weight = 2,
		comparators = {
			require("copilot_cmp.comparators").prioritize,

			-- Below is the default comparitor list and order for nvim-cmp
			cmp.config.compare.offset,
			-- cmp.config.compare.scopes, --this is commented in nvim-cmp too
			cmp.config.compare.exact,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			cmp.config.compare.locality,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
	preselect = cmp.PreselectMode.None,
})

-- Set configuration for specific filetype.
-- cmp.setup.filetype("gitcommit", {
-- sources = cmp.config.sources({
-- { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
-- }, {
-- { name = "buffer" },
-- }),
-- })

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- Set up lspconfig.
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require("lspconfig")["<YOUR_LSP_SERVER>"].setup({
-- capabilities = capabilities,
-- })
set.shortmess:append("c")

-- Nerd commenter
-- Use compact syntax for prettified multi-line comments
g.NERDCompactSexyComs = 1
-- Add spaces after comment delimiters by default
g.NERDSpaceDelims = 1
-- Enable trimming of trailing whitespace when uncommenting
g.NERDTrimTrailingWhitespace = 1
-- Telescope
local telescope_builtin = require('telescope.builtin')
vim.keymap.set("n", "<C-f>", telescope_builtin.live_grep, {})
vim.keymap.set("n", "<C-b>", function ()
	telescope_builtin.buffers({ path_display = { "truncate" } })
end, {})
vim.keymap.set("n", "<C-p>", telescope_builtin.builtin, {})
vim.keymap.set("n", "<C-d>", function() 
	telescope_builtin.lsp_definitions({ jump_type = "never" })
end, {})
vim.keymap.set("n", "<C-e>", telescope_builtin.find_files, {})
vim.keymap.set("n", "<leader>fr", telescope_builtin.lsp_references, {})
vim.keymap.set("n", "<leader>ic", telescope_builtin.lsp_incoming_calls, {})
vim.keymap.set("n", "<leader>oc", telescope_builtin.lsp_outgoing_calls, {})
vim.keymap.set("n", "<leader>el", function()
	telescope_builtin.diagnostics({ bufnr = 0 })
end, {})

-- Formatter
vim.keymap.set("n", "<leader><Space>f", ":Format<CR>")

require("neoconf").setup({
	-- override any of the default settings here
})

g.rustaceanvim = {
  -- LSP configuration
  server = {
		auto_attach = not vim.env.NVIM_NO_RA,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
				cargo = {
					features = "all",
				},
      },
    },
  },
}


local nvim_lsp = require("lspconfig")
nvim_lsp.volar.setup({})
nvim_lsp.racket_langserver.setup({
	autostart = false,
})
nvim_lsp.fortls.setup({})
nvim_lsp.buf_ls.setup({})
nvim_lsp.pyright.setup({})
nvim_lsp.nixd.setup{}
nvim_lsp.gopls.setup({})
-- nvim_lsp.rust_analyzer.setup({})
nvim_lsp.texlab.setup({
	settings = {
		texlab = {
			auxDirectory = ".",
			bibtexFormatter = "texlab",
			build = {
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
				executable = "xelatex",
				forwardSearchAfter = false,
				onSave = false,
			},
			chktex = {
				onEdit = false,
				onOpenAndSave = false,
			},
			diagnosticsDelay = 300,
			formatterLineLength = 80,
			forwardSearch = {
				args = {},
			},
			latexFormatter = "latexindent",
			latexindent = {
				modifyLineBreaks = false,
			},
		},
	},
})
-- use command_compiles.json generated by build tools like cmake, ninja, meson
nvim_lsp.ccls.setup({
	init_options = {
		cache = {
			directory = ".ccls-cache",
		},
	},
})
-- Option 2: nvim lsp as LSP client
-- Tell the server the capability of foldingRange,
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}
local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
for _, ls in ipairs(language_servers) do
	if ls ~= "markdown_oxide" then
		require("lspconfig")[ls].setup({
			capabilities = capabilities,
			-- you can add other fields for setting up lsp server in this table
		})
	end
end

local markdown_capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspconfig").markdown_oxide.setup({
    -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
    -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
    capabilities = vim.tbl_deep_extend(
        'force',
        markdown_capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true,
                },
            },
        }
    ),
    on_attach = function () 
			local function check_codelens_support()
			local clients = vim.lsp.get_active_clients({ bufnr = 0 })
			for _, c in ipairs(clients) do
				if c.server_capabilities.codeLensProvider then
					return true
				end
				if c.name == "markdown_oxide" then
					vim.api.nvim_create_user_command(
						"Daily",
						function(args)
							local input = args.args

							vim.lsp.buf.execute_command({command="jump", arguments={input}})

						end,
						{desc = 'Open daily note', nargs = "*"}
					)
				end
			end
			return false
			end

			vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' }, {
			buffer = bufnr,
			callback = function ()
				if check_codelens_support() then
					vim.lsp.codelens.refresh({bufnr = 0})
				end
			end
			})
			-- trigger codelens refresh
			vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
		end
})

require("ufo").setup()

require("nvim-treesitter.configs").setup({
	highlight = {
		enable = false,
	},
	incremental_selection = {
		enable = false,
	},
	indent = {
		enable = false,
	},
})
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<Tab>"] = false,
			},
			n = {
				["<Tab>"] = false,
				["<C-c>"] = actions.close,
			},
		},
	},
})
require("telescope").load_extension("file_browser")
vim.api.nvim_set_keymap("n", "<C-t>", ":Telescope file_browser<cr>", { noremap = true })

-- Utilities for creating configurations
local util = require("formatter.util")
require("formatter").setup({
	filetype = {
		c = {
			function()
				return {
					exe = "clang-format",
					args = { "--assume-filename", vim.api.nvim_buf_get_name(0), "--sort-includes=0" },
					stdin = true,
					cwd = vim.fn.expand("%:p:h"), -- Run clang-format in cwd of the file.
				}
			end,
		},
		cpp = {
			function()
				return {
					exe = "clang-format",
					args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
					stdin = true,
					cwd = vim.fn.expand("%:p:h"), -- Run clang-format in cwd of the file.
				}
			end,
		},
		rust = {
			function()
				return {
					exe = "rustfmt",
					args = { "--emit=stdout", "--edition 2021" },
					stdin = true,
				}
			end,
		},
		go = {
			function()
				return {
					exe = "gofmt",
					args = { vim.api.nvim_buf_get_name(0) },
					stdin = true,
				}
			end,
		},
		json = {
			function()
				return {
					exe = "jq",
					stdin = true,
				}
			end,
		},
		python = {
			-- Configuration for psf/black
			function()
				return {
					exe = "black", -- this should be available on your $PATH
					args = { "-" },
					stdin = true,
				}
			end,
		},
		lua = {
			function()
				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						vim.api.nvim_buf_get_name(0),
						-- util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
		},
		racket = {
			function()
				return {
					exe = "raco",
					args = {
						"fmt",
					},
					stdin = true,
				}
			end,
		},
		scheme = {
			function()
				return {
					exe = "raco",
					args = {
						"fmt",
					},
					stdin = true,
				}
			end,
		},
	},
})
vim.opt.listchars = {
	space = "⋅",
	eol = "↴",
}
require("ibl").setup()
require("which-key").setup({})
require('bamboo').setup({
	style = 'light',
	toggle_style_key = "<leader>ts", -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
	toggle_style_list = { 'vulgaris', 'multiplex', 'light' },
})
require("bamboo").load()
require("lualine").setup({
	options = {
		theme = "bamboo",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	tabline = {
		lualine_a = { "buffers" },
	},
})

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	server_opts_overrides = {
		settings = {
			advanced = {
				inlineSuggestCount = 3, -- #completions for getCompletions
			},
		},
	},
})

require("copilot_cmp").setup()

-- Set up lsp inlay hint
vim.lsp.inlay_hint.enable(true)

