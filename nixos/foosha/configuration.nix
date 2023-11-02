# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, home-manager, ... }:

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
    hostName = "foosha";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 8056 10001 ];
      allowedUDPPorts = [ 41641 3478 ];
      checkReversePath = "loose";
    };
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
    bind
    lsof
  ];

  programs.fish.enable = true;


  # Enable the OpenSSH daemon.
  services = {
    traefik = {
      enable = true;
      staticConfigOptions = {
        experimental.http3 = true;
        log = {
          level = "WARNING";
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
            v2ray = {
              rule = "Host(`foosha.adwin.win`) && Path(`/ray`)";
              service = "v2ray";
              middlewares = [ "sslheader" ];
            };
            tgbot = {
              rule = "Host(`tgbot.adwin.win`)";
              service = "tgbot";
            };
          };
          services = {
            v2ray.loadBalancer.servers = [ { url = "http://localhost:10001"; }];
            tgbot.loadBalancer.servers = [ { url = "http://localhost:3000"; }];
          };
          middlewares = {
            rewriteToRoot = {
              replacePath = {
                path = "/";
              };
            };
            sslheader = {
              headers = {
                customRequestHeaders.X-Forwarded-Proto = "https";
              };
            };
          };
        };
      };
    };

    v2ray = {
      enable = true;
      config = builtins.fromJSON (builtins.readFile ./v2ray.json);
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
        "bluespace" = { id = "2OOOY2Y-CIGAZR7-WRODB57-KCBQE7J-6BK6Z4Y-S44HSEF-SIPWY6U-VM3RKAG"; };
      };
      folders = {
        "flakes" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/adwin/flakes";    # Which folder to add to Syncthing
          devices = [ "MI10" "natsel" "Tardis" "bluespace" ];      # Which devices to share the folder with
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
  system.stateVersion = "23.05"; # Did you read the comment?

}

