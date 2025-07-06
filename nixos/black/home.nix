{ pkgs, ...}: 
{
  home.packages = with pkgs; [
    delta
    tmux
    nixd
    fzf
    bat
    bind         # dnsutils like dig
    unzip
    zip
    socat
    htop
    lsof
    tree
    ripgrep
    xh        # xh: curl in rust
    file
    trash-cli
    usbutils
    pciutils
    eza
    killall
    fd              # find in rust
  ];

  xdg = {
    enable = true;
    configFile = {
      "git/gitignore_global".text = builtins.readFile ./gitignore_global;
    };
  };

  programs = {
    zoxide = {
      enable = true;
      options = [ "--cmd" "cd" ];
    };
    starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ../../programs/cli/starship.toml);
    };
    ssh = {
      enable = true;
      serverAliveInterval = 30;
      serverAliveCountMax = 600;
      extraConfig = ''
        TCPKeepAlive yes
      '';
      matchBlocks = {
        "icecream.adwin.win" = {
          forwardAgent = true;
        };
        "natsel.adwin.win" = {
          forwardAgent = true;
        };
      };
    };
    nix-index ={
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true; 
    };
    git = {
      enable = true;
      userName  = "Adwin White";
      userEmail = "adwinw01@gmail.com";
      aliases = {
        co = "checkout";
        tree = "log --all --graph --format=format:'%C(dim yellow)%h%C(reset) -%C(auto)%d%Creset %C(white)%s%C(reset)%C(dim white) - %an%C(reset) %C(bold cyan)- (%ar)%C(reset)'";
      };
      extraConfig = {
        core = {
          editor = "nvim";
          excludeFile = "/home/adwin/.config/git/gitignore_global";
          pager = "delta";
        };
        interactive = {
          diffFilter = "delta --color-only";
        };
        delta = {
          navigate = true;
          dark = true;
          minus-style = "normal \"#423200\"";
          plus-style = "syntax \"#330022\"";
        };
        merge = {
          conflictStyle = "zdiff3";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
    fish = {
      enable = true;
      shellAliases = {
        rm = "trash";
      };
      shellInit = ''
        fish_vi_key_bindings
        bind -M visual y fish_clipboard_copy
        bind -M normal yy fish_clipboard_copy
        bind p fish_clipboard_paste
        bind -M insert -m default jj backward-char force-repaint
        bind -M insert \cf forward-char
        bind -M insert \cg forward-word
	set -g -x EDITOR nvim
        alias ls="eza"
        alias ll="eza -1la"
        alias lg="lazygit"
        alias done="notify-send 'command is done'"
        bind -e \cl
        eval (direnv hook fish)
      '';
    };
    neovim.enable = true;
  };

  home.stateVersion = "25.05";
}
