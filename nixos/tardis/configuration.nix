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
  boot.resumeDevice = "/dev/nvme0n1p2";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-pinyin-zhwiki
        fcitx5-pinyin-moegirl
      ];
    };
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  virtualisation.virtualbox.host.enable = true;

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
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
    };
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
      "v2ray_subscriptions/v2spacex" = {};
      "v2ray_subscriptions/tomlink" = {};
    };
  };
  nixpkgs.overlays = [ (self: super: {
    chromium = let
      wrapped = super.writeShellScriptBin "chromium" ''
        export GOOGLE_API_KEY=`cat ${config.sops.secrets.google_api_key.path}`
        export GOOGLE_DEFAULT_CLIENT_ID=`cat ${config.sops.secrets.google_default_client_id.path}`
        export GOOGLE_DEFAULT_CLIENT_SECRET=`cat ${config.sops.secrets.google_default_client_secret.path}`
        exec ${super.chromium}/bin/chromium 
      '';
      in
      pkgs.symlinkJoin {
        name = "chromium";
        paths = [
          wrapped
          super.chromium
        ];
      };
  }) ];

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
        "https://nixpkgs-wayland.cachix.org"
        "https://berberman.cachix.org"
      ];
      builders-use-substitutes = true;
      auto-optimise-store = true;
      trusted-users = [ "root" "adwin" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" "berberman.cachix.org-1:UHGhodNXVruGzWrwJ12B1grPK/6Qnrx2c3TjKueQPds=" ];
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
  networking = rec {
    hostName = "tardis";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall.enable = false;
    # firewall = {
      # enable = true;
      # allowedTCPPortRanges = [
        # { from = 1; to = 65535; }
      # ];
      # allowedUDPPortRanges = [
        # { from = 1; to = 65535; }
      # ];
    # };
    # nameservers = [
      # "1.1.1.1"
      # "8.8.8.8"
      # "223.5.5.5"
    # ];
    useDHCP = false;
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp2s0";
    };
    networkmanager = {
      enable = true;
      dns = "none";
      unmanaged = [ "interface-name:ve-*" ];
    };

    wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "10.100.0.2/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        # listenPort = 51820;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -o ${nat.externalInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -o ${nat.externalInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
        '';

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = config.sops.secrets.wireguard_private.path;

        peers = [
          # List of allowed peers.
          { # Feel free to give a meaning full name
            # Public key of the peer (not a file path).
            publicKey = "6uNLTaYV8Y3H5O9ZZsxH6Xxf+6KzG6n8NYN538df1zI=";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.100.0.0/24" ];
            endpoint = "175.24.187.39:11454";
            persistentKeepalive = 15;
          }
          {
            publicKey = "wgSlNdIqrMxlzNfZiNYWmHdbhqtvqlKJf2uI+srKYhk=";
            allowedIPs = [ "10.100.0.3/32" ];
            endpoint = "192.168.123.131:11454";
            persistentKeepalive = 15;
          }
        ];
      };
    };
  };

  services = {
    v2ray = {
      enable = true;
      configFile = "/etc/v2ray/config.json";
    };
    syncthing = {
      enable = true;
      user = "adwin";
      dataDir = "/home/adwin/Sync";
      configDir = "/home/adwin/Sync/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      devices = {
        "MI10" = { id = "QSR37KC-3TAUX2H-H7X4YVI-VBQR4VT-WXEGXYK-6AR2PZI-XGHL3W6-ASGNQAO"; };
      };
      folders = {
        "Logseq" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/Documents/TheNotes";    # Which folder to add to Syncthing
          devices = [ "MI10" ];      # Which devices to share the folder with
        };
      };
    };
    smartdns = {
      enable = true;
      settings = {
        bind = "[::]:53";
        cache-size = 4096;
        speed-check-mode = "none";
        server = "8.8.8.8:53";
      };
    };
    resolved.enable = false;
    fail2ban.enable = false;
    openssh.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      wireplumber.enable = true;
      media-session.enable = false;
    };


    logind.lidSwitch = "ignore";

    # To use Plasma5
    xserver = {
      enable = true;
      layout = "us";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };

    # tlp = {
      # enable = true;
      # settings = {
        # CPU_SCALING_GOVERNOR_ON_AC = "performance";
        # CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # };
    # };
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
  users.users.adwin = {
    isNormalUser = true;
    initialHashedPassword = "JbreyM/pvSAzM";
    home = "/home/adwin";
    extraGroups = [ "wheel" "networkmanager" "input" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  users.extraGroups.vboxusers.members = [ "adwin" ];


  # Enable home manager
  home-manager = {
   useGlobalPkgs = true;
   useUserPackages = true;
   users.adwin = import ./home-x11.nix;
  };
   

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # wireguard
    wireguard-tools
    v2ray
    v2t
    cgproxy
    pavucontrol
  ];


  # programs = {
    # sway.enable = true;
  # };

  environment.etc = {
    "v2t.conf".source = "/home/adwin/.config/v2t/v2t.conf";
    # "cgproxy/config.json".text = builtins.readFile ./../../programs/cli/cgproxy.json;
  };


  systemd.services = {
    cgproxy = {
      enable = true;
      after = [
        "network.target"
        "network-online.target"
      ];
      description = "cgproxy service wrapped";
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.cgproxy}/bin/cgproxyd --execsnoop";
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

