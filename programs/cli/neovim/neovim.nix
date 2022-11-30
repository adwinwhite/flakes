{ pkgs } : {
  enable = true;
  package = pkgs.neovim-nightly;
  vimAlias = true;
  viAlias = true;
  extraConfig = builtins.concatStringsSep "\n" [
      ''
      luafile ${builtins.toString ./init.lua}
      ''
    ];
  plugins = with pkgs.vimPlugins; [
    onedark-nvim
    lualine-nvim
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
        ] ++ (if builtins.hasAttr "tree-sitter-proto" pkgs 
            then [ plugins.tree-sitter-markdown pkgs.tree-sitter-proto ]
            else [ plugins.tree-sitter-markdown ]
          )
      ))
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
    rust-tools-nvim
  ];
}
