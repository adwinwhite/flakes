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
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and gc
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15";
    };
  };
  nix = {
    settings = {
      substituters = pkgs.lib.mkBefore [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
        "https://mirrors.ustc.edu.cn/nix-channels/store" 
        "https://nix-community.cachix.org"
      ];
      builders-use-substitutes = true;
      auto-optimise-store = true;
      trusted-users = [ "root" "adwin" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };

  # sops = {
    # defaultSopsFile = ./secrets.yaml;
    # age = {
      # # keyFile = "/var/lib/sops.key";
      # sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # };
    # secrets = {
      # wireguard_private = {};
    # };
  # };

  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "natsel";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 11454 ];
      checkReversePath = "loose";
    };

    useDHCP = false;
    nat = {
      enable = true;
      internalInterfaces = ["wg0"];
      externalInterface = "ens5";
    };
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      unmanaged = [ "interface-name:wg0" ];
    };
    # proxy.default = "http://127.0.0.1:10809";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };


  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adwin = {
    isNormalUser = true;
    initialHashedPassword = "$6$8ODVs5SZBDvJNrfk$D/AnD9aJeC.yFgPGpTx40gc/8jA8a8ix3F7OSQt/xEynAsCea./H0OCpT.rr.ZfAqtY0WqCVA0plaLLv.PKtq1";
    home = "/home/adwin";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
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
    wireguard-tools
    v2ray
    bind
    lsof
  ];
 

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    tailscale.enable = true;
    fail2ban.enable = true;
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    syncthing = {
      enable = true;
      user = "adwin";
      dataDir = "/home/adwin/Sync";
      configDir = "/home/adwin/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      openDefaultPorts = true;
      devices = {
        "MI10" = { id = "QSR37KC-3TAUX2H-H7X4YVI-VBQR4VT-WXEGXYK-6AR2PZI-XGHL3W6-ASGNQAO"; };
        "Tardis" = { id = "CETAQ3H-PQQTRPB-KO37QXB-GLGXLR7-OP5CDYU-D2TUFM2-3TZWWOI-YHIZZAK"; };
        "bluespace" = { id = "2OOOY2Y-CIGAZR7-WRODB57-KCBQE7J-6BK6Z4Y-S44HSEF-SIPWY6U-VM3RKAG"; };
      };
      folders = {
        "Logseq" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/Documents/TheNotes";    # Which folder to add to Syncthing
          devices = [ "MI10" "Tardis" "bluespace" ];      # Which devices to share the folder with
        };
        "flakes" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/flakes";    # Which folder to add to Syncthing
          devices = [ "MI10" "Tardis" "bluespace" ];      # Which devices to share the folder with
        };
      };
    };

  };

  systemd.services.NetworkManager-wait-online.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

