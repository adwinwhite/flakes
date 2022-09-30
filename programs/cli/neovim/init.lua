local set = vim.opt
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
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	command = "setlocal tabstop=4 shiftwidth=4 expandtab",
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

-- Completion-nvim
-- Use completion-nvim in every buffer
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	command = "lua require'completion'.on_attach()",
})
-- Cycle through completions with tab
vim.cmd([[
	inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]])
set.completeopt = "menuone,noinsert,noselect"
set.shortmess:append("c")
g.completion_enable_snippet = "vim-vsnip"
g.completion_chain_complete_list = {
	TelescopePrompt = {},
	default = {
		{
			complete_items = { "lsp", "path" },
		},
		{
			mode = "<c-p>",
		},
		{
			mode = "<c-n>",
		},
	},
	latex = {
		{
			complete_items = { "lsp", "path", "snippet" },
		},
		{
			mode = "<c-p>",
		},
		{
			mode = "<c-n>",
		},
	},
}
g.completion_auto_change_source = 1
g.completion_matching_ignore_case = 1
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
nvim_lsp.fortls.setup({})
nvim_lsp.pyright.setup({})
nvim_lsp.rnix.setup({})
nvim_lsp.gopls.setup({})
nvim_lsp.rust_analyzer.setup({})
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
					cwd = vim.fn.expand("%:p:h"),  -- Run clang-format in cwd of the file.
				}
			end,
		},
		cpp = {
			function()
				return {
					exe = "clang-format",
					args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
					stdin = true,
					cwd = vim.fn.expand("%:p:h"),  -- Run clang-format in cwd of the file.
				}
			end,
		},
		rust = {
			function()
				return {
					exe = "rustfmt",
					args = { "--emit=stdout" },
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
-- require('rust-tools').setup({
-- tools = {
-- runnables = {
-- use_telescope = true
-- },
-- inlay_hints = {
-- auto = true,
-- },
-- },

-- -- all the opts to send to nvim-lspconfig
-- -- these override the defaults set by rust-tools.nvim
-- -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
-- server = {
-- -- on_attach is a callback called when the language server attachs to the buffer
-- -- on_attach = on_attach,
-- settings = {
-- -- to enable rust-analyzer settings visit:
-- -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
-- ["rust-analyzer"] = {
-- -- enable clippy on save
-- checkOnSave = {
-- command = "clippy"
-- },
-- }
-- }
-- },
-- })

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
