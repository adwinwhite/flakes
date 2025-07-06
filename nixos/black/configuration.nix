# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    resumeDevice = "/dev/disk/by-uuid/150c8c92-b9f1-41f3-9126-0a77387de6f6";
    enableContainers = true;
    kernel.sysctl."vm.swappiness" = 10;
  };

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      CacheDirectory = "nix";
    };
  };
  environment.variables.NIX_REMOTE = "daemon";

  environment.persistence."/nix/persistent" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections"
      "/home"
      "/root"
      "/var"
      "/lost+found"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Enable flakes and gc
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixVersions.latest;
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
    settings = {
      substituters = pkgs.lib.mkBefore [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=39"
        "https://mirrors.ustc.edu.cn/nix-channels/store?priority=39"
        "https://nix-community.cachix.org"
      ];
      builders-use-substitutes = true;
      auto-optimise-store = true;
      trusted-users = [ "root" "adwin" ];
      trusted-public-keys = [ 
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" 
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "black";
    firewall.enable = false;
    useDHCP = true;
  };

  services = {
    openssh = {
      enable = true;
      extraConfig = ''
        ClientAliveInterval 60
        ClientAliveCountMax 120
      '';
    };
  };

  xdg = {
    portal = {
      enable = false;
    };
  };


  hardware.bluetooth.enable = false;
  # sound.mediaKeys.enable = true;
  # rtkit is optional but recommended
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.uinput = {};
  users.mutableUsers = false;
  users.users = {
    adwin = {
      isNormalUser = true;
      hashedPassword = "$2b$05$zI/d/JA0xiDu88Gyp60rwuYm6vGWgfj3UKyJNMh76MWMRB6XYrbDG";
      home = "/home/adwin";
      extraGroups = [ "wheel" "input" "uinput" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.fish;
    };
  };

  # Enable home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      adwin = import ./home.nix;
    };
  };

  programs = {
    fish.enable = true;
    nix-ld.enable = true;
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}

