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
    resumeDevice = "/dev/nvme0n1p2";
    enableContainers = true;
    kernel.sysctl."vm.swappiness" = 10;
  };

  virtualisation = {
    virtualbox.host.enable = true;
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
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

  # systemd.targets.machines.enable = true;
  # systemd.nspawn."archlinux" = {
    # enable = true;
    # execConfig = {
      # Boot = true;
    # };
  # };
  # systemd.services."systemd-nspawn@archlinux" = {
    # enable = true;
    # wantedBy = [ "machines.target" ];
  # };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-pinyin-zhwiki
          fcitx5-pinyin-moegirl
        ];
        waylandFrontend = true;
        plasma6Support = true;
      };
    };
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };


  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      source-han-sans
      source-han-serif
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      allowBitmaps = false;
      antialias = true;
      hinting = {
        enable = true;
        autohint = false;
      };
      subpixel.rgba = "rgb";
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "/var/lib/sops.key";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
    secrets = {
      wireguard_private = {};
      google_api_key = {
        mode = "0440";
        owner = config.users.users.adwin.name;
        group = config.users.users.adwin.group;
      };
      google_default_client_id = {
        mode = "0440";
        owner = config.users.users.adwin.name;
        group = config.users.users.adwin.group;
      };
      google_default_client_secret = {
        mode = "0440";
        owner = config.users.users.adwin.name;
        group = config.users.users.adwin.group;
      };
      # "v2ray_subscriptions/v2spacex" = {
        # sopsFile = ../secrets.yaml;
        # owner = "adwin";
      # };
      # "v2ray_subscriptions/tomlink" = {
        # sopsFile = ../secrets.yaml;
        # owner = "adwin";
      # };
      # "v2ray_subscriptions/feiniaoyun" = {
        # sopsFile = ../secrets.yaml;
        # owner = "adwin";
      # };
      "config.dae" = {
        sopsFile = ./config.dae;
        format = "binary";
      };
      adwin_login_password = {
        neededForUsers = true;
      };
    };
  };
  nixpkgs.overlays = [ 
    (self: super: {
      py3 = let
        python-with-my-packages = super.python3.withPackages (p: with p; [
          pandas
          requests
          numpy
          matplotlib
          scipy
          cryptography
          # other python packages you want
        ]);
        in
        super.runCommand "py3" {} ''
          mkdir $out
          # Link every top-level folder from pkgs.hello to our new target
          ln -s ${python-with-my-packages}/* $out
          # Except the bin folder
          rm $out/bin
          mkdir $out/bin
          # We create the bin folder ourselves and link every binary in it
          ln -s ${python-with-my-packages}/bin/python $out/bin/py3
        '';
      }) 
    (import ../../overlays/misc.nix)
    (import ../../overlays/kde/overlay.nix)
  ];

  # Enable flakes and gc
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
                "electron-27.3.11"
              ];
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

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking = {
    hostName = "tardis";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall.enable = false;
    useDHCP = false;
    networkmanager = {
      enable = true;
      dns = "none";
      unmanaged = [ "interface-name:ve-*" ];
    };
    # Need to be a external address so that it will be forwarded to v2ray by cgproxy.
    nameservers = [
      "223.5.5.5"
    ];
  };


  services = {
    tailscale.enable = false;
    udev = {
      enable = true;
      extraRules = ''
        SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="uinput"
      '';
    };
    dae = {
      enable = true;
      configFile = config.sops.secrets."config.dae".path;
    };
    syncthing = {
      enable = true;
      user = "adwin";
      dataDir = "/home/adwin/Sync";
      configDir = "/home/adwin/Sync/.config/syncthing";
      extraFlags = [ "--allow-newer-config" ];
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "MI10" = { id = "QSR37KC-3TAUX2H-H7X4YVI-VBQR4VT-WXEGXYK-6AR2PZI-XGHL3W6-ASGNQAO"; };
          "bluespace" = { id = "2OOOY2Y-CIGAZR7-WRODB57-KCBQE7J-6BK6Z4Y-S44HSEF-SIPWY6U-VM3RKAG"; };
        };
        folders = {
          "Logseq" = {        # Name of folder in Syncthing, also the folder ID
            path = "/home/adwin/Documents/TheNotes";    # Which folder to add to Syncthing
            devices = [ "MI10" "bluespace" ];      # Which devices to share the folder with
          };
          "flakes" = {        # Name of folder in Syncthing, also the folder ID
            path = "/home/adwin/flakes";    # Which folder to add to Syncthing
            devices = [ "MI10" "bluespace" ];      # Which devices to share the folder with
          };
        };
      };
    };
    # Cause DNS resolution failure.
    smartdns = {
      enable = false;
      settings = {
        bind = "[::]:53";
        cache-size = 4096;
        speed-check-mode = "none";
        server = "223.5.5.5:53";
      };
    };
    resolved.enable = false;
    fail2ban.enable = false;
    openssh = {
      enable = true;
      extraConfig = ''
        ClientAliveInterval 60
        ClientAliveCountMax 120
      '';
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      wireplumber.enable = true;
    };


    logind = {
      lidSwitch = "lock";
      lidSwitchDocked = "ignore";
    };

    # To use Plasma6
    xserver = {
      enable = true;
      xkb.layout = "us";
      xautolock.time = 60;
    };
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      wlr = {
        enable = true;
      };
    };
  };


  hardware.bluetooth.enable = true;
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
      hashedPasswordFile = config.sops.secrets.adwin_login_password.path;
      home = "/home/adwin";
      extraGroups = [ "wheel" "networkmanager" "input" "uinput" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.fish;
    };
    qq = {
      isNormalUser = true;
      hashedPassword = "$2b$05$zI/d/JA0xiDu88Gyp60rwuYm6vGWgfj3UKyJNMh76MWMRB6XYrbDG";
      home = "/home/qq";
      extraGroups = [ "networkmanager" "input" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.fish;
    };
  };

  users.extraGroups.vboxusers.members = [ "adwin" ];


  # Enable home manager
  home-manager = {
   useGlobalPkgs = true;
   useUserPackages = true;
   users = {
    adwin = import ./home.nix;
    qq = import ./home-qq.nix;
  };
  };
   

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wireguard-tools
    pavucontrol
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    kdeconnect.enable = true;
    fish.enable = true;
    firejail.enable = true;
    nix-ld.enable = true;
    extra-container.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  systemd.services = {
    ydotoold = {
      unitConfig = {
        Description = "An auto-input utility for wayland";
        Documentation = [ "man:ydotool(1)" "man:ydotoold(8)" ];
      };

      serviceConfig = {
        ExecStart = "${pkgs.ydotool}/bin/ydotoold --socket-path=/tmp/ydotools --socket-own=1000:100";
      };

      wantedBy = ["default.target"];
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

