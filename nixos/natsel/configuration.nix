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
      options = "--delete-older-than 15d";
    };
  };
  nix = {
    settings = {
      substituters = pkgs.lib.mkBefore [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=38" 
        "https://mirrors.ustc.edu.cn/nix-channels/store?priority=39" 
        "https://nix-community.cachix.org"
      ];
      substitute = true;
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
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
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
          {
            publicKey = "9ihTi1vqN0ei8FSYw88AcuxyV+JraiUE7/Wf/XLiuDI=";
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

    nginx = {
      enable = true;
      virtualHosts = {
        "www.adwin.icu" = {
          root = "/var/www/blog";
          listen = [
            {
              addr = "0.0.0.0";
              port = 8081;
            }
          ];
        };
      };
    };
    traefik = {
      enable = true;
      staticConfigOptions = {
        experimental.http3 = true;
        log = {
          level = "DEBUG";
        };
        accessLog = {};
        api = {
          dashboard = true;
        };
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
            blog = {
              rule = "Host(`www.adwin.icu`)";
              service = "blog";
            };
            artplace-ws = {
              rule = "Host(`www.adwin.icu`) && (Path(`/ws`) || Path(`/echo`) || PathPrefix(`/artplace`))";
              service = "artplace-ws";
              middlewares = [ "sslheader" ];
            };
            dashboard = {
              rule = "Host(`www.adwin.icu`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
              service = "api@internal";
              middlewares = [ "auth" ];
            };
          };
          services = {
            blog.loadBalancer.servers = [{ url = "http://localhost:8081"; }];
            artplace-ws.loadBalancer.servers = [{ url = "http://10.100.0.2:8080"; }];
          };
          middlewares = {
            sslheader = {
              headers = {
                customRequestHeaders.X-Forwarded-Proto = "https";
              };
            };
            auth = {
              basicAuth = {
                users = [ "adwin:$2b$05$L9UmPVXiO5GnhXwYTcnF9.kiqAcqnyFUKT5eWCl5ZHKdAWDSsOq7a" ];
              };
            };
          };
        };
      };
    };

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

