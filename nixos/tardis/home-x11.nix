{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    poetry
    traceroute
    headscale
    tailscale
    nil
    fzf
    py3
    logseq
    bottom
    stylua
    xclip           # x11 clipboard cli program
    xournalpp
    xdotool         # simulate keyboard and mouse input
    gebaar-libinput # touchpad gestures 
    firefox
    bat
    sshfs
    feh
    xdg-utils    # to use xdg-open
    zathura
    texlab       # latex lsp
    firejail     # sandbox untrusted executable
    black        # code formatter for python
    alsa-utils
    blueberry
    ffmpeg
    mpv
    # nmap
    # mach-nix
    wezterm    
    bind         # dnsutils like dig
    # appimage-run
    cmake
    gnumake
    gh           # github cli
    unzip
    zip
    light        # brightness control
    helix        # modal terminal editor in rust
    socat
    htop
    lsof
    tree
    ripgrep
    ripgrep-all
    xh        # xh: curl in rust
    chromium
    file
    trash-cli
    usbutils
    pciutils
    nix-prefetch-github
    nodePackages.pyright # python lsp
    rnix-lsp
    ccls            # c/c++ lsp
    # clang
    # rust-analyzer # use rustup's one to sync rustc and RA.
    gopls           # go lsp
    delve           # go debugger
    tealdeer        # tldr: brief command help
    graphviz
    v2t
    fortran-language-server
    exa
    zellij
    powerline-fonts
    killall
    fd              # find in rust
    rage            # age in rust
    sops
    tdesktop
    qv2ray
  ];

  xdg = {
    enable = true;
    configFile = {
      # "zellij/config.yaml".text = builtins.readFile ./../../programs/cli/zellij.yaml;
      "gebaar/gebaard.toml".text = builtins.readFile ./gebaard.toml;
      "wezterm/wezterm.lua".text = builtins.readFile ./wezterm.lua;
      "git/gitignore_global".text = builtins.readFile ./gitignore_global;
      # "electron-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland";
      # No use since wrapped chromium does not read flags.conf.
      # "chromium-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland\n--enable-webrtc-pipewire-capturer=enabled\n--gtk-version=4";
      "zathura/zathurarc".text = "set selection-clipboard clipboard";
    };
  };

  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          savePathFixed = true;
        };
      };
    };
  };

  systemd.user = {
    services = {
      gebaar = {
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.gebaar-libinput}/bin/gebaard";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical.target" ];
      };
    };
  };

  programs = {
    ssh = {
      enable = true;
      serverAliveInterval = 240;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_rsa";
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
        "github.com-adwingray" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/adwinking_rsa";
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };
    texlive = {
      enable = true;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full collection-langchinese ; };
    };
    nix-index ={
      enable = true;
      enableFishIntegration = true;
    };
    broot = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        modal = true;
      };
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
    neovim = import ../../programs/cli/neovim/neovim.nix { 
      inherit pkgs;
    };  
  };

  home.stateVersion = "22.05";
}
