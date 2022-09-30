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
    # rust-tools-nvim
  ];
}
