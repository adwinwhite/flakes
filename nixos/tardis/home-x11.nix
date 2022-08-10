{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    xdotool         # simulate keyboard and mouse input
    gebaar-libinput # touchpad gestures 
    firefox
    bat
    sshfs
    feh
    xdg_utils    # to use xdg-open
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
    ht-rust        # xh: curl in rust
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
    gopls           # go lsp
    delve           # go debugger
    tealdeer        # tldr: brief command help
    graphviz
    # rust-bin.stable.latest.default
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
      modal = true;
    };
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
    neovim = import ../../programs/cli/neovim.nix { 
      inherit pkgs;
    };  
  };

  home.sessionVariables = {
    GOOGLE_DEFAULT_CLIENT_ID = "77185425430.apps.googleusercontent.com";
    GOOGLE_DEFAULT_CLIENT_SECRET = "OTJgUOQcT7lO7GsGZq2G4IlT";
  };
}
