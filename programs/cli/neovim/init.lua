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
g.colors_name = "onedark"
set.termguicolors = true

-- Fold
set.foldlevel = 2
set.foldnestmax = 2
set.foldmethod = "expr"
set.foldexpr = "nvim_treesitter#foldexpr()"

-- Filetype-based configuration
-- vim.api.nvim_create_autocmd("FileType", {
	-- pattern = "proto",
	-- command = "setlocal tabstop=4 shiftwidth=4 expandtab",
-- })

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

-- Completion by nvim-cmp
set.completeopt = "menu,menuone,noselect"
local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		-- { name = "vsnip" }, -- For vsnip users.
		{ name = "luasnip" }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer" },
	}),
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
vim.keymap.set("n", "<C-f>", ":lua require'telescope.builtin'.live_grep()<cr>")
vim.keymap.set("n", "<C-b>", ":lua require'telescope.builtin'.buffers()<cr>")
vim.keymap.set("n", "<C-p>", ":lua require'telescope.builtin'.builtin()<cr>")
vim.keymap.set("n", "<C-d>", ":lua require'telescope.builtin'.lsp_definitions()<cr>")
-- Formatter
vim.keymap.set("n", "<leader><Space>f", ":Format<CR>")

local nvim_lsp = require("lspconfig")
nvim_lsp.volar.setup({})
nvim_lsp.racket_langserver.setup({
	autostart = false,
})
nvim_lsp.fortls.setup({})
nvim_lsp.pyright.setup({})
nvim_lsp.nil_ls.setup({})
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
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
	},
	indent = {
		enable = true,
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
require("indent_blankline").setup({
	space_char_blankline = " ",
	show_current_context = true,
})
require("which-key").setup({})

local rt = require("rust-tools")
rt.setup({
	tools = {
		runnables = {
			use_telescope = true,
		},
		inlay_hints = {
			auto = true,
		},
	},

	-- all the opts to send to nvim-lspconfig
	-- these override the defaults set by rust-tools.nvim
	-- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
	server = {
		on_attach = function(_, bufnr)
			-- Hover actions
			vim.keymap.set("n", "<Leader>rh", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			vim.keymap.set("n", "<Leader>rc", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
		-- on_attach is a callback called when the language server attachs to the buffer
		-- on_attach = on_attach,
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
			["rust-analyzer"] = {
				-- enable clippy on save
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	},
})

require("onedark").load()

require("lualine").setup({
	options = {
		theme = "onedark",
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
