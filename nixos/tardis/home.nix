{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    drill
    socat
    htop
    lsof
    wlroots
    kanshi
    wofi
    wl-clipboard
    clipman
    # i3status-rust
    mako
    tree
    ripgrep
    ripgrep-all
    ht-rust
    chromium 
    file
    trash-cli
    usbutils
    pciutils
    nix-prefetch-github
    nodePackages.pyright
    rnix-lsp
    ccls
    rust-analyzer
    clang
    gopls
    delve
    tealdeer
    graphviz
    rust-bin.stable.latest.default
    poetry
    v2t
    fortran-language-server
    exa
    zellij
    powerline-fonts
    wtype
    gebaar-libinput
    killall
    fd
    rage
    sops
    tdesktop
  ];

  xdg = {
    enable = true;
    configFile = {
      "gebaar/gebaar.toml".text = builtins.readFile ./gebaar.toml;
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
    };
  };

  systemd.user = {
    services = {
      gebaar = {
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.gebaar-libinput}/bin/gebaard -b";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };


  programs = {
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
    '';
    config = {
      gaps = {
        smartBorders = "on";
      };
      modifier = "Mod4";
      menu = "${pkgs.wofi}/bin/wofi";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          cfg = config.wayland.windowManager.sway.config;
        in
        lib.mkOptionDefault {
          "${mod}+Shift+q" = "exit";
          "${mod}+Return" = "exec ${cfg.terminal}";
          "${mod}+m" = "exec ${cfg.menu} -S drun";
          "${mod}+b" = "exec ${pkgs.chromium}/bin/chromium";
          "${mod}+t" = "exec ${pkgs.tdesktop}/bin/telegram-desktop";
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
          "${mod}+1" = ''exec "swaymsg [app_id=\"Alacritty\" workspace=\"__focused__\"] focus || swaymsg exec alacritty"'';
          "${mod}+2" = ''exec "swaymsg [class=\"Chromium-browser\" workspace=\"__focused__\"] focus || swaymsg exec chromium"'';
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
        { command = "exec ${pkgs.wl-clipboard}/bin/wl-paste -p -t test --watch clipman store -P -- histpath=\"/tmp/clipman-primary.json\""; }
        # { command = "${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP"; } #workaround
        # { command = "${pkgs.alacritty}/bin/alacritty"; }
      ];
    };
  };
}