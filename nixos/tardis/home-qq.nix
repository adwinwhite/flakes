{ pkgs, osConfig, ...}: 
{
  home.packages = with pkgs; [
    qq
    rustdesk
    tdesktop
  ];

  xdg = {
    enable = true;
  };


  programs = {
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
        bind -e \cl
      '';
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };


  home.stateVersion = "24.05";
}
