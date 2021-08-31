# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, modulesPath, home-manager, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and gc
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15";
    };
    allowedUsers = [ "root" "adwin" ];
    binaryCaches = [ 
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
      "https://mirrors.ustc.edu.cn/nix-channels/store" 
      "https://cache.nixos.org/" 
      # "https://nixpkgs-wayland.cachix.org"
    ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      layout = "us";
      displayManager = {
        defaultSession = "sway";
        sddm.enable = true;
      };
    };
  };
  xdg = {
    portal.wlr.enable = true;
  };


  # Enable the Plasma 5 Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.defaultSession = "sway";
  # services.xserver.desktopManager.plasma5.enable = true;
  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adwin = {
    isNormalUser = true;
    initialHashedPassword = "emmm";
    home = "/home/adwin";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  # Enable home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.adwin = import ./home.nix;
  };
   

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tree
    git
    v2ray
    qv2ray
    chromium 
    ripgrep-all
    ht-rust
  ];
 
  programs = {
    sway.enable = true;
      # sway = {
        # enable = true;
        # wrapperFeatures = { base = true; gtk = true; };
        # extraPackages = with pkgs; [
          # xwayland
          # swaylock
          # swayidle
          # wl-clipboard
          # mako # notification daemon
          # alacritty # Alacritty is the default terminal in the config
          # wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
        # ];
        # extraSessionCommands = ''
          # export LIBSEAT_BACKEND=logind
          # export XDG_SESSION_TYPE=wayland
          # export XDG_SESSION_DESKTOP=sway
          # export XDG_CURRENT_DESKTOP=sway
          # export XKB_DEFAULT_LAYOUT=us
          # export WLR_NO_HARDWARE_CURSORS=1
          # export SDL_VIDEODRIVER=wayland
          # export QT_QPA_PLATFORM=wayland
          # export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # export _JAVA_AWT_WM_NONREPARENTING=1
          # export MOZ_ENABLE_WAYLAND=1
        # '';
      # };
      neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        viAlias = true;
        defaultEditor = true;
        configure = {
          customRC = ''
            set wildmode=longest,list,full
            syntax on
            set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
            set backspace=indent,eol,start
            set number
            set showcmd
            set ignorecase
            set autoindent
            set incsearch
            set nowrap
            set scrolloff=8
            set sidescroll=1
            set sidescrolloff=8
            set cmdwinheight=1
            set clipboard+=unnamedplus
            
            filetype plugin indent on
            let g:tex_flavor = "latex"
            
            
            " Custom mappings
            let mapleader=";"
            inoremap jj <Esc>
            nnoremap : q:i
            inoremap <C-s> <Esc>:w<CR>a
            nnoremap <C-s> :w<CR>

             " Cycle through completions with tab
            inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
            inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
            set completeopt=menuone,noinsert,noselect
            set shortmess+=c

            " Nerd commenter
            "
            " Use compact syntax for prettified multi-line comments
            let g:NERDCompactSexyComs = 1
            " Add spaces after comment delimiters by default
            let g:NERDSpaceDelims = 1
            " Enable trimming of trailing whitespace when uncommenting
            let g:NERDTrimTrailingWhitespace = 1

            '';
            packages.vim = {
            start = with pkgs.vimPlugins; [
              onedark-nvim
              vim-airline
              vim-airline-themes
              nvim-lspconfig
              completion-nvim
              vim-nix
              nerdcommenter
            ];
          };
        };
      };
    };

#   systemd.user.targets.sway-session = {
#     description = "Sway compositor session";
#     documentation = [ "man:systemd.special(7)" ];
#     bindsTo = [ "graphical-session.target" ];
#     wants = [ "graphical-session-pre.target" ];
#     after = [ "graphical-session-pre.target" ];
#   };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking = {
    hostName = "tardis";
    firewall.enable = false;
    networkmanager.dns = "dnsmasq";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

}

