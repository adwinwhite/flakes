{ pkgs, osConfig, config, ...}: 
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
    brightnessctl
    swayidle
    swaylock
    fuzzel
    wezterm
    delta
    # aider-chat
    libnotify
    btrfs-progs
    # dogdns
    # tmux
    # jetbrains.idea-community
    # ssh-tools
    # poetry
    # traceroute
    # headscale
    # tailscale
    # nil
    nixd
    fzf
    py3
    logseq
    bottom
    stylua
    # xclip           # x11 clipboard cli program
    wl-clipboard    # wayland clipboard cli program
    # xournalpp
    # xdotool         # simulate keyboard and mouse input
    # ydotool
    ydotool
    # firefox
    # bat
    # sshfs
    feh
    xdg-utils    # to use xdg-open
    # zathura
    # texlab       # latex lsp
    # firejail     # sandbox untrusted executable
    # black        # code formatter for python
    # alsa-utils
    # blueberry
    # ffmpeg
    # mpv
    # nmap
    # mach-nix
    # wezterm
    bind         # dnsutils like dig
    # appimage-run
    # cmake
    # gnumake
    gh           # github cli
    unzip
    zip
    # light        # brightness control
    # helix        # modal terminal editor in rust
    # socat
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
    # ccls            # c/c++ lsp
    # clang
    # rust-analyzer # use rustup's one to sync rustc and RA.
    # gopls           # go lsp
    # delve           # go debugger
    tealdeer        # tldr: brief command help
    # graphviz
    # fortran-language-server
    eza
    # zellij
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
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/adwin/flakes/nixos/tardis/niri.kdl";
      "wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/adwin/flakes/nixos/tardis/wezterm.lua";
      "git/gitignore_global".text = builtins.readFile ./gitignore_global;
      # "electron-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland";
      # No use since wrapped chromium does not read flags.conf.
      # "chromium-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland\n--enable-webrtc-pipewire-capturer=enabled\n--gtk-version=4";
      # "zathura/zathurarc".text = "set selection-clipboard clipboard";
    };
  };

  services = {
    swayidle = {
      enable = true;
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      ];
    };
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
          "4" = {
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
    waybar = {
      enable = true;
      settings = [ (import ./waybar.nix {inherit pkgs; }) ];
      style = builtins.readFile ./waybar.css;
      systemd.enable = true;
    };
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
          hostname = "ssh.github.com";
          port = 443;
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
    lazygit = {
      enable = true;
      settings = {
        git.paging = {
          colorArg = "always";
          pager = "delta --light --paging=never";
        };
      };
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
        diff = {
          tool = "delta";
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

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };


  home.stateVersion = "22.05";
}
