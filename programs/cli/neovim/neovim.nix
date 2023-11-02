{ pkgs } : let html5-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
                pname = "html5.vim";
                version = "2020-08-22";
                src = pkgs.fetchFromGitHub {
                  owner = "othree";
                  repo = "html5.vim";
                  rev = "7c9f6f38ce4f9d35db7eeedb764035b6b63922c6";
                  sha256 = "1hgbvdpmn3yffk5ahz7hz36a7f5zjc1k3pan5ybgncmdq9f4rzq6";
                };
                meta.homepage = "https://github.com/othree/html5.vim/";
              };
  in
  {
  enable = true;
  package = pkgs.neovim-nightly;
  vimAlias = true;
  viAlias = true;
  extraConfig = builtins.concatStringsSep "\n" [
      ''
      luafile ${builtins.toString ./init.lua}
      ''
    ];
  extraPackages = with pkgs; [
    nodejs
  ];
  plugins = with pkgs.vimPlugins; [
    lspkind-nvim
    copilot-lua
    copilot-cmp
    html5-vim
    vim-javascript
    vim-svelte
    lualine-nvim
    nvim-lspconfig
    # nvim-treesitter
    nvim-ufo
    (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-python
          tree-sitter-rust
          tree-sitter-go
          tree-sitter-nix
          tree-sitter-lua
          tree-sitter-scheme
          tree-sitter-bash
          # tree-sitter-vue
          tree-sitter-javascript
          tree-sitter-typescript
          tree-sitter-json
          tree-sitter-toml
          tree-sitter-yaml
          tree-sitter-html
          tree-sitter-css
          tree-sitter-markdown
        ])
      )
    nvim-cmp
    cmp-nvim-lsp
    cmp-cmdline
    cmp-cmdline-history
    cmp-buffer
    friendly-snippets
    luasnip
    cmp_luasnip
    telescope-nvim
    telescope-file-browser-nvim
    vim-nix
    nerdcommenter
    formatter-nvim
    indent-blankline-nvim
    vim-sleuth
    vimtex
    which-key-nvim
    onedark-nvim
    pkgs.rust-tools-nvim
  ];
}
