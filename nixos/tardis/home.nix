{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    firejail
    black
    alsa-utils
    blueberry
    firefox-wayland
    wob          # bar for lightness and volumn
    ffmpeg
    mpv
    # nmap
    # mach-nix
    wezterm    
    bind         # dnsutils like dig
    # appimage-run
    cmake
    gnumake
    gh
    unzip
    zip
    light        # brightness control
    helix
    socat
    htop
    lsof
    wlroots
    wofi
    wl-clipboard
    clipman
    # i3status-rust
    mako           # notification daemon
    tree
    ripgrep
    ripgrep-all
    ht-rust        # xh: curl in rust
    # chromium
    file
    trash-cli
    usbutils
    pciutils
    nix-prefetch-github
    nodePackages.pyright
    rnix-lsp
    ccls
    rust-analyzer
    # clang
    gopls
    delve           # go debugger
    tealdeer        # tldr: brief command help
    graphviz
    # rust-bin.stable.latest.default
    poetry
    v2t
    fortran-language-server
    exa
    zellij
    powerline-fonts
    wtype           # simulate key events
    gebaar-libinput # touchpad gestures on wayland
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
      "gebaar/gebaard.toml".text = builtins.readFile ./gebaard.toml;
      "wezterm/wezterm.lua".text = builtins.readFile ./wezterm.lua;
      "nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
      "nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
      "nvim/parser/lua.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-lua}/parser";
      "nvim/parser/rust.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-rust}/parser";
      "nvim/parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";
      "nvim/parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";
      "nvim/parser/json.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-json}/parser";
      "nvim/parser/latex.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-latex}/parser";
      "nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
      "nvim/parser/markdown.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-markdown}/parser";
      "nvim/parser/julia.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-julia}/parser";
      "electron-flags.conf".text = "--enable-features=UseOzonePlatform\n--ozone-platform=wayland";
      "chromium-flags.conf".text = "--ozone-platform-hint=auto\nenable-webrtc-pipewire-capturer=enabled";

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
    swayidle = {
      enable = true;
      timeouts = [
        { timeout = 1; command = ''if pgrep -x swaylock; then swaymsg "output * dpms off"; fi''; resumeCommand = ''swaymsg "output * dpms on"''; }
      ];
      events = [
        { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock; playerctl pause"; }
      ];
    };
    kanshi = {
      enable = true;
      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        };
        docked = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL U2719DS G67VLS2";
              scale = 1.5;
              status = "enable";
              mode = "2560x1440@59.951Hz";
              position = "0,0";
              transform = "normal";
            }
          ];
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
        Install.WantedBy = [ "sway-session.target" ];
      };

      # wob = {
        # Unit = {
          # Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
          # Documentation = [ "man:wob(1)" ];
          # PartOf = [ "graphical-session.target" ];
          # After = [ "graphical-session.target" ];
          # ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
        # };
        # Service = {
          # StandardInput = "socket";
          # ExecStart = "${pkgs.wob}/bin/wob";
        # };
        # Install.WantedBy = [ "graphical-session.target" ];
      # };
    };

    # sockets = {
      # wob = {
        # Socket = {
          # ListenFIFO = "%t/wob.sock";
          # SocketMode = "0600";
        # };
        # Install.WantedBy = [ "sockets.target" ];
      # };
    # };
  };

  programs = {
    nix-index ={
      enable = true;
      enableFishIntegration = true;
    };
    # firefox = {
      # enable = true;
      # package = pkgs.firefox-wayland;
      # # package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        # # forceWayland = true;
        # # extraPolicies = {
          # # # PasswordManagerEnabled = false;
          # # # DisableFirefoxAccounts = true;
          # # # DisablePocket = true;
          # # EnableTrackingProtection = {
            # # Value = true;
            # # Locked = true;
            # # Cryptomining = true;
            # # Fingerprinting = true;
          # # };
        # # };
      # # };
    # };
    vscode = {
      enable = true;
      package = pkgs.vscodium;    # You can skip this if you want to use the unfree version
      # extensions = with pkgs.vscode-extensions; [
        # # Some example extensions...
        # # vscodevim.vim
      # ];
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
    alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "Source Code Pro for Powerline";
            style = "Regular";
          };
          bold = {
            family = "Source Code Pro for Powerline";
            style = "Bold";
          };
          italic = {
            family = "Source Code Pro for Powerline";
            style = "Italic";
          };
          bold_italic = {
            family = "Source Code Pro for Powerline";
            style = "Bold Italic";
          };
        };
      };
    };
    neovim = import ./neovim.nix { 
      inherit pkgs;
    };  
    # i3status-rust = {
      # enable = true;
      # package = pkgs.i3status-rust;
      # bars.bottom.settings = {
        # theme = {
          # name = "solarized-dark";
        # };
        # icons = {
          # name = "awesome";
        # };
      # };
    # };
  };

  home.sessionVariables = {
    GOOGLE_DEFAULT_CLIENT_ID = "77185425430.apps.googleusercontent.com";
    GOOGLE_DEFAULT_CLIENT_SECRET = "OTJgUOQcT7lO7GsGZq2G4IlT";
  };


  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    wrapperFeatures = {
      gtk = true;
    };
    extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORM=wayland
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export WOBSOCK=$XDG_RUNTIME_DIR/wob.sock
    '';
    config = {
      gaps = {
        smartBorders = "on";
      };
      modifier = "Mod4";
      menu = "${pkgs.wofi}/bin/wofi";
      terminal = "${pkgs.wezterm}/bin/wezterm";
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          cfg = config.wayland.windowManager.sway.config;
        in
        lib.mkOptionDefault {
          "${mod}+Shift+q" = "exit";
          "${mod}+Shift+r" = "exec systemctl --user restart kanshi.service";
          "${mod}+Return" = "exec ${cfg.terminal}";
          "${mod}+m" = "exec ${cfg.menu} -S drun";
          "${mod}+b" = "exec ${pkgs.chromium}/bin/chromium";
          "${mod}+t" = "layout tabbed";
          "${mod}+g" = "splith";
          "${mod}+h" = "focus left";
          "Ctrl+F1"  = "workspace number 1";
          "Ctrl+F2"  = "workspace number 2";
          "Ctrl+F3"  = "workspace number 3";
          "Ctrl+F4"  = "workspace number 4";
          "Ctrl+F5"  = "workspace number 5";
          "Ctrl+F6"  = "workspace number 6";
          "Ctrl+F7"  = "workspace number 7";
          "Ctrl+F8"  = "workspace number 8";
          "Ctrl+F9"  = "workspace number 9";
          "${mod}+1" = ''exec "swaymsg [app_id=\"org.wezfurlong.wezterm\" workspace=\"__focused__\"] focus || swaymsg exec wezterm; swaymsg fullscreen enable"'';
          # "${mod}+2" = ''exec "swaymsg [class=\"Chromium-browser\" workspace=\"__focused__\"] focus || swaymsg exec chromium; swaymsg fullscreen enable"'';
          # "${mod}+2" = ''exec "swaymsg [app_id=\"chromium-browser\" workspace=\"__focused__\"] focus || swaymsg exec chromium; swaymsg fullscreen enable"'';
          "${mod}+2" = ''exec "swaymsg [app_id=\"firefox\" workspace=\"__focused__\"] focus || swaymsg exec firefox; swaymsg fullscreen enable"'';
          "${mod}+3" = ''exec "swaymsg [class=\"VSCodium\" workspace=\"__focused__\"] focus || swaymsg exec codium; swaymsg fullscreen enable"'';
          "${mod}+0" = "exec swaylock";
          "${mod}+Shift+0" = "exec systemctl suspend";
          "Print" = "exec flameshot gui";
          "Shift+Print" = "exec flameshot full";
          "XF86AudioRaiseVolume" = "exec amixer sset Master 5%+ | sed -En 's/.*\\[([0-9]+)%\\].*/\\1/p' | head -1 > $WOBSOCK";
          "XF86AudioLowerVolume" = "exec amixer sset Master 5%- | sed -En 's/.*\\[([0-9]+)%\\].*/\\1/p' | head -1 > $WOBSOCK";
          "XF86AudioMute" = "exec amixer sset Master toggle | sed -En '/\\[on\\]/ s/.*\\[([0-9]+)%\\].*/\\1/ p; /\\[off\\]/ s/.*/0/p' | head -1 > $WOBSOCK";
          "XF86MonBrightnessUp" = "exec light -A 5 && light -G | cut -d'.' -f1 > $WOBSOCK";
          "XF86MonBrightnessDown" = "exec light -U 5 && light -G | cut -d'.' -f1 > $WOBSOCK";
        };
        colors = {
          focused = {
            background = "#b16286";
            border = "#b16286";
            childBorder = "#b16286";
            indicator = "#b16286";
            text = "#ebdbb2";
          };
          focusedInactive = {
            background = "#689d6a";
            border = "#689d6a";
            childBorder = "#689d6a";
            indicator = "#689d6a";
            text = "#ebdbb2";
          };
          unfocused = {
            background = "#3c3836";
            border = "#3c3836";
            childBorder = "#3c3836";
            indicator = "#3c3836";
            text = "#ebdbb2";
          };
          urgent = {
            background = "#cc241d";
            border = "#cc241d";
            childBorder = "#cc241d";
            indicator = "#cc241d";
            text = "#ebdbb2";
          };
          placeholder = {
            background = "#000000";
            border = "#000000";
            childBorder = "#000000";
            indicator = "#000000";
            text = "#ebdbb2 ";
          };
        };
      input = {
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "20";
        };
        "type:touchpad" = {
          dwt = "enabled";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      output = {
        eDP-1 = {
          scale = "3";
        };
      };
      window = {
        titlebar = false;
        hideEdgeBorders = "smart";
      };
      startup = [
        { command = "${pkgs.wl-clipboard}/bin/wl-paste -p -t test --watch clipman store -P -- histpath=\"/tmp/clipman-primary.json\""; }
        { command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
        { command = "hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
        { command = "mkfifo $WOBSOCK && tail -f $WOBSOCK | wob"; }
        # { command = "${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP"; } #workaround
      ];
    };
  };
}
