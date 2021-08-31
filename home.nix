{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    drill
    socat
    htop
    lsof
    foot
    wlroots-eglstreams
    kanshi
    wofi
    wl-clipboard
    clipman
    i3status-rust
    mako
  ];
  programs = {
    git = {
      enable = true;
      userName  = "Adwin White";
      userEmail = "adwinw01@gmail.com";
    };
    fish = {
      enable = true;
      shellInit = ''
        fish_vi_key_bindings
        bind -M insert -m default jj backward-char force-repaint
        bind -M insert \cf forward-char
        bind -M insert \cg forward-word
      '';
    };
    alacritty = {
      enable = true;
    };
  };

  systemd.user.sessionVariables = {
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
          "${mod}+t" = "exec ${cfg.terminal}";
          "${mod}+m" = "exec ${cfg.menu} -S drun";
          "${mod}+b" = "exec ${pkgs.chromium}/bin/chromium";
          "${mod}+Return" = "exec ${pkgs.foot}/bin/foot";
          "${mod}+h" = "splith";
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
