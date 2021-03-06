{ pkgs } : {
  enable = true;
  package = pkgs.neovim-nightly;
  vimAlias = true;
  viAlias = true;
  extraConfig = ''
    set wildmode=longest,list,full
    " syntax on
    " set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab
    set backspace=indent,eol,start
    set number
    set showcmd
    set ignorecase
    set smartcase
    " set autoindent
    set incsearch
    set nowrap
    set scrolloff=8
    set sidescroll=1
    set sidescrolloff=8
    set cmdwinheight=1
    set clipboard+=unnamedplus
    
    filetype plugin indent on
    let g:tex_flavor = "latex"

    " Airline
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1

    " Color scheme
    let g:onedark_hide_endofbuffer = 1
    let g:onedark_terminal_italics = 1
    let g:onedark_termcolors = 256
    let g:airline_theme='onedark'
    if !exists('g:loaded_color')
      let g:loaded_color = 1
      " Put your favorite colorscheme here
      colorscheme onedark
      set termguicolors
    endif
    " Fold
    " set foldmethod=syntax
    set foldlevel=2
    set foldnestmax=2
    " set foldclose=all
    " hi Folded ctermbg=242
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()

    " Filetype-based configuration
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab

    " Vimtex
    let g:vimtex_view_method = 'zathura'
    let g:vimtex_compiler_latexmk_engines = {
        \ '_'                : '-xelatex',
        \}

    " Or with a generic interface:
    " let g:vimtex_view_general_viewer = 'okular'
    " let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

    " VimTeX uses latexmk as the default compiler backend. If you use it, which is
    " strongly recommended, you probably don't need to configure anything. If you
    " want another compiler backend, you can change it as follows. The list of
    " supported backends and further explanation is provided in the documentation,
    " see ":help vimtex-compiler".
    " let g:vimtex_compiler_method = 'latexrun'

    " Most VimTeX mappings rely on localleader and this can be changed with the
    " following line. The default is usually fine and is the symbol "\".
    " let maplocalleader = ","
    
    
    " Custom mappings
    let mapleader=";"
    inoremap jj <Esc>
    nnoremap : q:i
    inoremap <C-s> <Esc>:w<CR>a
    nnoremap <C-s> :w<CR>
    nnoremap <F6> :source ~/.config/nvim/init.vim<cr>
    nnoremap <Leader>en :lua vim.lsp.diagnostic.goto_next()<cr>
    nnoremap <Leader>eN :lua vim.lsp.diagnostic.goto_prev()<cr>
    " Completion-nvim
    " Use completion-nvim in every buffer
    autocmd BufEnter * lua require'completion'.on_attach()
     " Cycle through completions with tab
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    set completeopt=menuone,noinsert,noselect
    set shortmess+=c
    let g:completion_enable_snippet = 'vim-vsnip'
    let g:completion_chain_complete_list = {
        \ 'default': [
        \    {'complete_items': ['lsp', 'path']},
        \    {'mode': '<c-p>'},
        \    {'mode': '<c-n>'}
        \],
        \ 'TelescopePrompt' : [ ],
        \ 'latex': [
        \    {'complete_items': ['lsp', 'path', 'snippet']},
        \    {'mode': '<c-p>'},
        \    {'mode': '<c-n>'}
        \],
    \}
    let g:completion_auto_change_source = 1
    let g:completion_matching_ignore_case = 1
    " Nerd commenter
    " Use compact syntax for prettified multi-line comments
    let g:NERDCompactSexyComs = 1
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Enable trimming of trailing whitespace when uncommenting
    let g:NERDTrimTrailingWhitespace = 1
    " Telescope
    nnoremap <C-f> :lua require'telescope.builtin'.live_grep()<cr>
    nnoremap <C-b> :lua require'telescope.builtin'.buffers()<cr>
    nnoremap <C-p> :lua require'telescope.builtin'.builtin()<cr>
    nnoremap <C-d> :lua require'telescope.builtin'.lsp_definitions()<cr>
    " Formatter
    nnoremap <silent> <leader><Space>f :Format<CR>
    lua << EOF
    local nvim_lsp = require'lspconfig'
    nvim_lsp.fortls.setup {}
    nvim_lsp.pyright.setup {}
    nvim_lsp.rnix.setup {}
    nvim_lsp.rust_analyzer.setup {}
    nvim_lsp.gopls.setup {}
    nvim_lsp.texlab.setup{
      settings = {
        texlab = {
          auxDirectory = ".",
          bibtexFormatter = "texlab",
          build = {
            args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
            executable = "xelatex",
            forwardSearchAfter = false,
            onSave = false
          },
          chktex = {
            onEdit = false,
            onOpenAndSave = false
          },
          diagnosticsDelay = 300,
          formatterLineLength = 80,
          forwardSearch = {
            args = {}
          },
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = false
          }
        }
      }
    }
    -- use command_compiles.json generated by build tools like cmake, ninja, meson
    nvim_lsp.ccls.setup {
      init_options = {
        cache = {
          directory = ".ccls-cache";
        };
      }
    }
    require'nvim-treesitter.configs'.setup {
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
      }
    }
    local actions = require('telescope.actions')
    require('telescope').setup{
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
      }
    }
    require("telescope").load_extension "file_browser"
    vim.api.nvim_set_keymap(
      "n",
      "<C-t>",
      ":Telescope file_browser<cr>",
      { noremap = true }
    )
    require('formatter').setup({
      filetype = {
        c = {
           function()
              return {
                exe = "clang-format",
                args = {"--assume-filename", vim.api.nvim_buf_get_name(0), "--sort-includes=0"},
                stdin = true,
                cwd = vim.fn.expand('%:p:h')  -- Run clang-format in cwd of the file.
              }
            end
        },
        cpp = {
           function()
              return {
                exe = "clang-format",
                args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
                stdin = true,
                cwd = vim.fn.expand('%:p:h')  -- Run clang-format in cwd of the file.
              }
            end
        },
        rust = {
          function()
            return {
              exe = "rustfmt",
              args = {"--emit=stdout"},
              stdin = true
            }
          end
        },
        go = {
          function()
            return {
              exe = "gofmt",
              args = { vim.api.nvim_buf_get_name(0)},
              stdin = true
            }
          end
        },
        json = {
          function()
            return {
              exe = "jq",
              stdin = true
            }
          end
        },
        python = {
          -- Configuration for psf/black
          function()
            return {
              exe = "black", -- this should be available on your $PATH
              args = { '-' },
              stdin = true,
            }
          end
        },
      }
    })
    vim.opt.listchars = {
      space = "???",
      eol = "???",
    }
    require("indent_blankline").setup {
        space_char_blankline = " ",
        show_current_context = true,
    }
    require('which-key').setup {
    }
    EOF
  '';
  plugins = with pkgs.vimPlugins; [
    onedark-vim
    vim-airline
    vim-airline-themes
    nvim-lspconfig
    # nvim-treesitter
    (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-python
          tree-sitter-rust
          tree-sitter-go
          tree-sitter-nix
          tree-sitter-lua
          tree-sitter-json
        ]
      ))
    completion-nvim
    telescope-nvim
    telescope-file-browser-nvim
    completion-buffers
    vim-vsnip
    friendly-snippets
    vim-nix
    nerdcommenter
    formatter-nvim
    indent-blankline-nvim
    vim-sleuth
    vimtex
    which-key-nvim
  ];
}
