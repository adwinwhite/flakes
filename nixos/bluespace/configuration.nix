# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, modulesPath, home-manager, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXwWJH+vsxzntGdP0Cn4piSp1Tocg98YIrvzQIaHbL9wW/1Jj5w9bOYtFP5XbWQSQjbHqH04ISB6boV08Pb41Fs3iCwVXMdUa6qkRh9z0UmXq74Vp58AJ3ONQFOQM/IYkbMFVWE1TjbrXlA/dpPhXKBdCj2ZA7gParqXEfk6KAVNKnFED02YvqoVotOzcfH9nlsMzMRVpfm6he0aP04RZE/Bs/UXzuQXZEwnOBYpuDSLW+CQcoxGhEKgTxgDnfdLNqYyp6rVHWy0+b46fbx1JVU02xMH8YplrIC/b/ysBVboCPf79gZPnw7jQNf+EX9sAm2bNuje1DSSGqivpLe199 adwin@Tardis" 
  ];

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
        "https://nix-community.cachix.org"
      ];
      builders-use-substitutes = true;
      auto-optimise-store = true;
      trusted-users = [ "root" "adwin" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
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
    hostName = "bluespace";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ 41641 3478 ];
      checkReversePath = "loose";
    };

    # useDHCP = false;
    # interfaces.enp0s3.useDHCP = true;

    # nat = {
      # enable = true;
      # externalInterface = "wlp0s20u11";
      # internalInterfaces = [ "wg0" ];
    # };

    # wireguard.interfaces = {
      # # "wg0" is the network interface name. You can name the interface arbitrarily.
      # wg0 = {
        # # Determines the IP address and subnet of the server's end of the tunnel interface.
        # ips = [ "10.100.0.3/24" ];

        # # The port that WireGuard listens to. Must be accessible by the client.
        # listenPort = 11454;

        # # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        # postSetup = ''
          # ${pkgs.iptables}/bin/iptables -A FORWARD -o ${nat.externalInterface} -j ACCEPT
          # ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
        # '';

        # # This undoes the above command
        # postShutdown = ''
          # ${pkgs.iptables}/bin/iptables -D FORWARD -o ${nat.externalInterface} -j ACCEPT
          # ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
        # '';

        # # Path to the private key file.
        # #
        # # Note: The private key can also be included inline via the privateKey option,
        # # but this makes the private key world-readable; thus, using privateKeyFile is
        # # recommended.
        # privateKeyFile = "/home/adwin/.wireguard/prikey";

        # peers = [
          # # List of allowed peers.
          # { # Feel free to give a meaning full name
            # # Public key of the peer (not a file path).
            # publicKey = "6uNLTaYV8Y3H5O9ZZsxH6Xxf+6KzG6n8NYN538df1zI=";
            # # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            # allowedIPs = [ "10.100.0.0/24" ];
            # endpoint = "175.24.187.39:11454";
            # persistentKeepalive = 15;
          # }
          # {
            # publicKey = "9ihTi1vqN0ei8FSYw88AcuxyV+JraiUE7/Wf/XLiuDI=";
            # allowedIPs = [ "10.100.0.2/32" ];
          # }
        # ];
      # };
    # };
  };


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adwin = {
    isNormalUser = true;
    initialHashedPassword = "$6$IJuzB39ajEELQigc$BurZefRiK/Sehk9UQDdVOljc7ccmKQ9iHxcNdU7klUP4ECwWQKKccX7H7ArlJ8Lov.rmwtNg3H3DGBNSnd95A0";
    home = "/home/adwin";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXwWJH+vsxzntGdP0Cn4piSp1Tocg98YIrvzQIaHbL9wW/1Jj5w9bOYtFP5XbWQSQjbHqH04ISB6boV08Pb41Fs3iCwVXMdUa6qkRh9z0UmXq74Vp58AJ3ONQFOQM/IYkbMFVWE1TjbrXlA/dpPhXKBdCj2ZA7gParqXEfk6KAVNKnFED02YvqoVotOzcfH9nlsMzMRVpfm6he0aP04RZE/Bs/UXzuQXZEwnOBYpuDSLW+CQcoxGhEKgTxgDnfdLNqYyp6rVHWy0+b46fbx1JVU02xMH8YplrIC/b/ysBVboCPf79gZPnw7jQNf+EX9sAm2bNuje1DSSGqivpLe199 adwin@Tardis" 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVot4JY8t81DTWEe3St37AAY1htXmHsQb7K0NVtz5pU adwinw01@gmail.com"
    ];
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
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8085;
      dns = {
        magicDns = false;
        baseDomain = "hs.adwin.win";
        domains = [];
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
          "223.5.5.5"
          "114.114.114.114"
        ];
      };
      serverUrl = "https://headscale.adwin.win";
      logLevel = "warn";
      settings = {
        logtail.enabled = false;
        dns_config.override_local_dns = false;
      };
    };

    traefik = {
      enable = true;
      staticConfigOptions = {
        experimental.http3 = true;
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = false;
            };
          };
          websecure = {
            address = ":443";
            http.tls.certResolver = "le";
            http3 = { };
          };
        };
        certificatesResolvers.le.acme = {
          email = "adwinw01@gmail.com";
          storage = config.services.traefik.dataDir + "/acme.json";
          keyType = "EC256";
          tlsChallenge = { };
        };
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            headscale = {
              rule = "Host(`headscale.adwin.win`)";
              service = "headscale";
            };
          };
          services = {
            headscale.loadBalancer.servers = [{ url = "http://localhost:8085"; }];
          };
        };
      };
    };

    fail2ban.enable = true;
    openssh = {
      enable = true;
      passwordAuthentication = false;
      extraConfig = ''
        ClientAliveInterval 240
        ClientAliveCountMax 120
      '';
    };
    syncthing = {
      enable = true;
      user = "adwin";
      dataDir = "/home/adwin/Sync";
      configDir = "/home/adwin/Sync/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      openDefaultPorts = true;
      devices = {
        "MI10" = { id = "QSR37KC-3TAUX2H-H7X4YVI-VBQR4VT-WXEGXYK-6AR2PZI-XGHL3W6-ASGNQAO"; };
        "natsel" = { id = "GE4RPI2-QKV3G5A-MZ7BFT3-VJRS3RI-6S3NM6Q-3UL6FH7-QG67AKK-KEELIAO"; };
        "Tardis" = { id = "CETAQ3H-PQQTRPB-KO37QXB-GLGXLR7-OP5CDYU-D2TUFM2-3TZWWOI-YHIZZAK"; };
      };
      folders = {
        "Logseq" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/Documents/TheNotes";    # Which folder to add to Syncthing
          devices = [ "MI10" "natsel" "Tardis" ];      # Which devices to share the folder with
        };
        "flakes" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/flakes";    # Which folder to add to Syncthing
          devices = [ "MI10" "natsel" "Tardis" ];      # Which devices to share the folder with
        };
      };
    };
  };

  environment.etc = {
    # frp.source = /home/adwin/.config/frp;
  };

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



  systemd.services.NetworkManager-wait-online.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

