{ pkgs, osConfig, ...}: 
let
  chromium = let
    wrapped = pkgs.writeShellScriptBin "chromium" ''
      export GOOGLE_API_KEY=`cat ${osConfig.sops.secrets.google_api_key.path}`
      export GOOGLE_DEFAULT_CLIENT_ID=`cat ${osConfig.sops.secrets.google_default_client_id.path}`
      export GOOGLE_DEFAULT_CLIENT_SECRET=`cat ${osConfig.sops.secrets.google_default_client_secret.path}`
      exec ${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --gtk-version=4 "$@"
    '';
    in
    pkgs.symlinkJoin {
      name = "chromium";
      paths = [
        wrapped
        pkgs.chromium
      ];
    };
  ydotool = let
    wrapped = pkgs.writeShellScriptBin "ydotool" ''
      export YDOTOOL_SOCKET=/tmp/ydotools
      exec ${pkgs.ydotool}/bin/ydotool "$@"
    '';
    in
    pkgs.symlinkJoin {
      name = "ydotool";
      paths = [
        wrapped
        pkgs.ydotool
      ];
    };
in
{
  home.packages = with pkgs; [
    libnotify
    btrfs-progs
    dogdns
    tmux
    jetbrains.idea-community
    ssh-tools
    poetry
    traceroute
    # headscale
    tailscale
    nil
    fzf
    py3
    logseq
    bottom
    stylua
    xclip           # x11 clipboard cli program
    wl-clipboard    # wayland clipboard cli program
    # xournalpp
    # xdotool         # simulate keyboard and mouse input
    # ydotool
    ydotool
    firefox
    bat
    sshfs
    feh
    xdg-utils    # to use xdg-open
    zathura
    # texlab       # latex lsp
    firejail     # sandbox untrusted executable
    black        # code formatter for python
    alsa-utils
    blueberry
    ffmpeg
    mpv
    # nmap
    # mach-nix
    # wezterm
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
    # ripgrep-all
    xh        # xh: curl in rust
    chromium
    file
    trash-cli
    usbutils
    pciutils
    nix-prefetch-github
    nodePackages.pyright # python lsp
    ccls            # c/c++ lsp
    # clang
    # rust-analyzer # use rustup's one to sync rustc and RA.
    gopls           # go lsp
    delve           # go debugger
    tealdeer        # tldr: brief command help
    graphviz
    # fortran-language-server
    eza
    zellij
    powerline-fonts
    killall
    fd              # find in rust
    rage            # age in rust
    sops
    tdesktop
  ];

  xdg = {
    enable = true;
    configFile = {
      # "zellij/config.yaml".text = builtins.readFile ./../../programs/cli/zellij.yaml;
      "wezterm/wezterm.lua".text = builtins.readFile ./wezterm.lua;
      "git/gitignore_global".text = builtins.readFile ./gitignore_global;
      # "electron-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland";
      # No use since wrapped chromium does not read flags.conf.
      # "chromium-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland\n--enable-webrtc-pipewire-capturer=enabled\n--gtk-version=4";
      "zathura/zathurarc".text = "set selection-clipboard clipboard";
    };
  };

  services = {
    fusuma = {
      enable = true;
      extraPackages = with pkgs; [ coreutils ydotool xorg.xprop ];
      settings = {
        threshold = {
          swipe = 0.3;
        };
        interval = {
          swipe = 0.5;
        };
        swipe = {
          "3" = {
            left = {
              # command = "xdotool key ctrl+shift+Tab";
              command = "ydotool key 29:1 42:1 15:1 15:0 42:0 29:0";
              # command = "dotool key ctrl+shift+Tab";
            };
            right = {
              # command = "xdotool key ctrl+Tab";
              command = "ydotool key 29:1 15:1 15:0 29:0";
              # command = "dotool key ctrl+Tab";
            };
            up = {
              # command = "xdotool key Super_L+w";
              command = "ydotool key 125:1 17:1 17:1 125:0";
              # command = "dotool key super+w";
            };
          };
        };
      };
    };
    flameshot = {
      enable = true;
      settings = {
        General = {
          savePathFixed = true;
        };
      };
    };
    kdeconnect = {
      enable = true;
      indicator = true;
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
        "icecream.adwin.win" = {
          forwardAgent = true;
        };
        "natsel.adwin.win" = {
          forwardAgent = true;
        };
      };
    };
    texlive = {
      enable = false;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full collection-langchinese ; };
    };
    nix-index ={
      enable = false;
      enableFishIntegration = true;
      enableZshIntegration = false;
      enableBashIntegration = false;
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
      shellAliases = {
        rm = "trash";
      };
      shellInit = ''
        fish_vi_key_bindings
        bind -M insert -m default jj backward-char force-repaint
        bind -M insert \cf forward-char
        bind -M insert \cg forward-word
	set -g -x EDITOR nvim
        alias ls="eza"
        alias ll="eza -1la"
        bind -e \cl
        eval (direnv hook fish)
      '';
      # plugins = [
        # { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
        # {
          # name = "theme-budspencer";
          # src = pkgs.fetchFromGitHub {
            # owner = "oh-my-fish";
            # "repo" = "theme-budspencer";
            # "rev" = "835335af8e58dac22894fdd271d3b37789710be2";
            # "sha256" = "kzg1RMj2s2HPWqz9FX/fWQUCiWI65q6U8TcA0QajaX4=";
            # "fetchSubmodules" = true;
          # };
        # }
      # ];
    };
    neovim = import ../../programs/cli/neovim/neovim.nix { 
      inherit pkgs;
    };  
  };


  home.stateVersion = "22.05";
}
