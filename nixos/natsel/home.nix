{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    sops
    rage
    htop
    lsof
    tree
    ripgrep-all
    ripgrep
    ht-rust
    file
    trash-cli
    tealdeer
    exa
    zellij
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true; 
    };
    git = {
      enable = true;
      userName  = "Adwin White";
      userEmail = "adwinw01@gmail.com";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
    fish = {
      enable = true;
      shellInit = ''
        fish_vi_key_bindings
        bind -M insert -m default jj backward-char force-repaint
        bind -M insert \cf forward-char
        bind -M insert \cg forward-word
	set -g -x EDITOR nvim
        alias ls="exa"
        alias ll="exa -1la"
        bind -e \cl
        eval (direnv hook fish)
      '';
      plugins = [
        {
          name = "theme-budspencer";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            "repo" = "theme-budspencer";
            "rev" = "835335af8e58dac22894fdd271d3b37789710be2";
            "sha256" = "kzg1RMj2s2HPWqz9FX/fWQUCiWI65q6U8TcA0QajaX4=";
            "fetchSubmodules" = true;
          };
        }
      ];
    };
    neovim = {
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
        set autoindent
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
        nnoremap <C-t> :lua require'telescope.builtin'.file_browser()<cr>
        nnoremap <C-f> :lua require'telescope.builtin'.live_grep()<cr>
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
          }
        })
        vim.opt.listchars = {
          space = "⋅",
          eol = "↴",
        }
        require("indent_blankline").setup {
            space_char_blankline = " ",
            show_current_context = true,
        }
        EOF
      '';
      plugins = with pkgs.vimPlugins; [
        onedark-vim
        vim-airline
        vim-airline-themes
        nvim-lspconfig
        nvim-treesitter
        completion-nvim
        telescope-nvim
        completion-buffers
        vim-vsnip
        friendly-snippets
        vim-nix
        nerdcommenter
        formatter-nvim
        indent-blankline-nvim
        vim-sleuth
      ];
    };
  };
}
