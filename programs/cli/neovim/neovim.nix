{ pkgs } : {
  enable = true;
  vimAlias = true;
  viAlias = true;
  extraConfig = builtins.concatStringsSep "\n" [
      ''
      luafile ~/.config/nvim/out_of_store_symlink.lua
      ''
    ];
  extraPackages = with pkgs; [
    nodejs
  ];
  plugins = with pkgs.vimPlugins; [
    lspsaga-nvim
    neoconf-nvim
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
    bamboo-nvim
    rustaceanvim
  ];
}
