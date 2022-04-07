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

  networking = rec {
    hostName = "natsel";
    firewall.enable = true;
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

    wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "10.100.0.5/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 11454;

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
        # privateKeyFile = config.sops.secrets.wireguard_private.path;
        privateKeyFile = "/home/adwin/.config/privatekey";

        peers = [
          # List of allowed peers.
          { # Feel free to give a meaning full name
            # Public key of the peer (not a file path).
            publicKey = "hvUQpR5dg//+leGepXJ7an5+GR3znpolBNEPNxDmUgQ=";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.100.0.1/32" ];
            endpoint = "47.100.1.192:11454";
            persistentKeepalive = 15;
          }
          {
            publicKey = "z6PC2Yg6fJezEOnyv14hVLRanhP0DNSBUzdYfLdZ+V0=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
          {
            publicKey = "wgSlNdIqrMxlzNfZiNYWmHdbhqtvqlKJf2uI+srKYhk=";
            allowedIPs = [ "10.100.0.3/32" ];
          }
          {
            publicKey = "EQUXNOSDvMjV42cF+WXZYM+6+rMAkswgponGvSQMzgI=";
            allowedIPs = [ "10.100.0.4/32" ];
          }
        ];
      };
    };
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
    frp
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
    fail2ban.enable = true;
    openssh.enable = true;
  };

  environment.etc = {
    "frp/frps.ini".source = ./frps.ini;
    "v2ray/config.json".text = builtins.readFile ./v2ray.json;
  };

  systemd.services.frps = {
    enable = true;
    description = "Frp server to expose ssh";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.frp}/bin/frps -c /etc/frp/frps.ini";
    };
    wantedBy = [ "multi-user.target" ];
    after = ["network.target"];
  };

  systemd.services.v2ray = {
    description = "a platform for building proxies to bypass network restrictions";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.v2ray}/bin/v2ray -c /etc/v2ray/config.json";
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

