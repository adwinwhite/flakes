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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        # fcitx5-rime
        fcitx5-chinese-addons
        # fcitx5-pinyin-zhwiki
      ];
    };
  };

  virtualisation.virtualbox.host.enable = true;

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      # (nerdfonts.override { fonts = [ "FiraCode" ]; })
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
      "v2ray_subscriptions/v2spacex" = {};
      "v2ray_subscriptions/tomlink" = {};
    };
  };

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
  networking = {
    hostName = "tardis";
    firewall.enable = false;
    useDHCP = false;
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp2s0";
    };
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      unmanaged = [ "interface-name:ve-*" ];
    };
    proxy.default = "http://127.0.0.1:10809";
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # enable NAT
  # networking.nat.enable = true;
  # networking.nat.externalInterface = "wlp0s20u11";
  # networking.nat.internalInterfaces = [ "wg0" ];
  # networking.firewall = {
    # allowedUDPPorts = [ 51820 ];
  # };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.2/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      # listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wlp2s0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wlp2s0 -j ACCEPT
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
          publicKey = "hvUQpR5dg//+leGepXJ7an5+GR3znpolBNEPNxDmUgQ=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.0/24" ];
          endpoint = "47.100.1.192:11454";
          persistentKeepalive = 15;
        }
      ];
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services = {
    logind.lidSwitch = "ignore";
    # logind = {
        # extraConfig = ''
          # HandleLidSwitch=ignore
        # '';
    # };
    xserver = {
      enable = true;
      layout = "us";
      displayManager = {
        defaultSession = "sway";
        sddm.enable = true;
      };
    };

    tlp = {
      enable = true;
      extraConfig = ''
        CPU_SCALING_GOVERNOR_ON_AC=performance
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
      '';
    };
  };

  xdg = {
    portal = {
      enable = true;
      wlr = {
        enable = true;
      };
    };
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
  sound.mediaKeys.enable = true;
  # rtkit is optional but recommended
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
      media-session.enable = false;
    };
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.enable = true;
    media-session.enable = false;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


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
   users.adwin = import ./home.nix;
  };
   

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wireguard
    wireguard-tools
    v2ray
    v2t
    # (pkgs.callPackage ./pkgs/cgproxy {})
  ];
 
  programs = {
    sway.enable = true;
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # environment.etc = {
    # frp.source = /home/adwin/.config/frp;
  # };
  environment.etc = {
    "v2ray/conf.d".source = "${pkgs.v2t}/conf.d";
    "v2t.conf".source = "/home/adwin/.config/v2t/v2t.conf";
  };


  systemd.services.v2ray = {
    enable = false;
    description = "V2Ray Service";
    serviceConfig = {
      Type = "exec";
      DynamicUser = "yes";
      Slice = "noproxy.slice";
      MemoryMax = "1G";
      CPUQuota = "200%";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      NoNewPrivileges = "true";
      Restart = "on-failure";
      RestartPreventExitStatus = "23";
      ExecStart = "${pkgs.v2ray}/bin/v2ray -c /etc/v2ray/06_outbounds.json -confdir /etc/v2ray/conf.d";
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "nss-lookup.target" ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  
  # systemd.services.frpc = {
    # enable = true;
    # description = "Frp client to expose ssh";
    # unitConfig = {
      # Type = "simple";
    # };
    # serviceConfig = {
      # ExecStart = "${pkgs.frp}/bin/frpc -c /etc/frp/frpc.ini";
    # };
    # wantedBy = [ "multi-user.target" ];
    # after = ["network.target"];
  # };

  # systemd.services.netadapter = {
    # enable = true;
    # description = "rtl8188gu adapter usb mode switch";
    # unitConfig = {
      # Type = "oneshot";
    # };
    # serviceConfig = {
      # ExecStart = "${pkgs.usb-modeswitch}/bin/usb_modeswitch -KW -v 0bda -p 1a2b && ${pkgs.usb-modeswitch}/bin/usb_modeswitch -KW -v 0bda -p 1a2b";
    # };
    # wantedBy = [ "multi-user.target" ];
    # after = ["network.target"];
  # };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

