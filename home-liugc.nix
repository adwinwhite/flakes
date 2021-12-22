{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    dig
    drill
    socat
    htop
    lsof
    tree
    ripgrep-all
    file
    trash-cli
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
      extraConfig = {
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
    bash = {
      enable = true;
      bashrcExtra = ''eval "$(direnv hook bash)"'';
    };
    neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      vimAlias = true;
      viAlias = true;
    };
  };
}
