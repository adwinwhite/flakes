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

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

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

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "mail_hashed_passwords/i" = {};
      "mail_hashed_passwords/bluespace" = {};
      "mail_hashed_passwords/1" = {};
      "aggv2sub_token" = {};
      "traefik_dashboard_password" = {};
      "v2ray_subscriptions/v2spacex" = {
        sopsFile = ../secrets.yaml;
      };
      "v2ray_subscriptions/tomlink" = {
        sopsFile = ../secrets.yaml;
      };
      "v2ray_subscriptions/feiniaoyun" = {
        sopsFile = ../secrets.yaml;
      };
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
      allowedTCPPorts = [ 22 80 443 8056 ];
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
    wireguard-tools
    bind
    lsof
    traefik-certs-dumper
    watchexec
  ];

  programs.fish.enable = true;

  mailserver = {
    enable = true;
    fqdn = "mail.adwin.win";
    domains = [ "adwin.win" ];

    loginAccounts = {
      "i@adwin.win" = {
        hashedPasswordFile = "/run/secrets/mail_hashed_passwords/i";
        aliases = [ "adwin@adwin.win" ];
        quota = "2G";
      };
      "bluespace@adwin.win" = {
        hashedPasswordFile = "/run/secrets/mail_hashed_passwords/bluespace";
        quota = "2G";
      };
      "1@adwin.win" = {
        hashedPasswordFile = "/run/secrets/mail_hashed_passwords/1";
        quota = "2G";
      };
      "yjyzlib@adwin.win" = {
        hashedPassword = "$2b$05$bq6w.Gsi3.T2603ZfLw/8usws6C/bvs48hIK5JpgmWCG25acVneFm";
        quota = "512M";
      };
    };

    indexDir = "/var/lib/dovecot/indices";
    fullTextSearch.enable = false;
    # forwards = {
      # "i@adwin.win" = "adwinw01@gmail.com";
    # };
    useFsLayout = true;
    hierarchySeparator = "/";

    certificateScheme = "manual";
    certificateFile = "/root/acme/certs/mail.adwin.win.crt";
    keyFile = "/root/acme/private/mail.adwin.win.key";

    # Enable IMAP and POP3
    enableImap = true;
    enablePop3 = true;
    enableImapSsl = true;
    enablePop3Ssl = true;
  };

  # Enable the OpenSSH daemon.
  services = {
    # redis.servers = {
      # "niltalk" = {
        # enable = true;
        # bind = "0.0.0.0";
        # port = 6379;
        # settings = {
          # protected-mode = "no";
        # };
      # };
    # };
    tailscale.enable = false;
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

    nginx = {
      enable = true;
      virtualHosts = {
        "mail.adwin.win" = {
          root = "/var/www/mail";
          listen = [
            {
              addr = "0.0.0.0";
              port = 8099;
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
          level = "INFO";
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
            chat = {
              rule = "Host(`chat.adwin.win`)";
              service = "chat";
            };
            headscale = {
              rule = "Host(`headscale.adwin.win`)";
              service = "headscale";
            };
            mail = {
              rule = "Host(`mail.adwin.win`)";
              service = "mail";
            };
            aggv2sub = {
              rule = "Host(`icecream.adwin.win`) && Path(`/aggv2sub`) && Query(`token=${builtins.readFile /run/secrets/aggv2sub_token}`)";
              service = "aggv2sub";
              middlewares = [ "rewriteToRoot" ];
            };
            dashboard = {
              rule = "Host(`icecream.adwin.win`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
              service = "api@internal";
              middlewares = [ "auth" ];
            };
            v2ray = {
              rule = "Host(`v2ray.adwin.win`) && Path(`/ray`)";
              service = "v2ray";
              middlewares = [ "sslheader" ];
            };
          };
          services = {
            chat.loadBalancer.servers = [{ url = "http://localhost:9000"; }];
            headscale.loadBalancer.servers = [{ url = "http://localhost:8085"; }];
            mail.loadBalancer.servers = [{ url = "http://localhost:8099"; }];
            aggv2sub.loadBalancer.servers = [ { url = "http://localhost:8056"; }];
            v2ray.loadBalancer.servers = [ { url = "http://localhost:10001"; }];
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
            auth = {
              basicAuth = {
                users = [ "adwin:${builtins.readFile /run/secrets/traefik_dashboard_password}" ];
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


  systemd.services = {
    actix-chat = {
      enable = true;
      after = [
        "network.target"
        "network-online.target"
      ];
      description = "simple web chat example with actix";
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory= "/home/adwin/examples/websockets/chat";
        ExecStart = "/home/adwin/examples/target/release/websocket-chat-server";
      };
    };
    traefik-certs-dumper = {
      enable = true;
      after = [
        "network.target"
        "network-online.target"
      ];
      description = "Dump traefik certs to files automatically";
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.watchexec}/bin/watchexec -w ${config.services.traefik.dataDir + "/acme.json"} --delay-run=10 '${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --version v2 --source ${config.services.traefik.dataDir + "/acme.json"} --dest /root/acme || ${pkgs.coreutils}/bin/echo \"Traefik cert dumper went wrong\" | ${pkgs.mailutils}/bin/mail -s \"Service Failure\" -r bluespace@adwin.win i@adwin.win'";
      };
    };
    aggv2sub = {
      enable = true;
      after = [
        "network.target"
        "network-online.target"
      ];
      description = "Aggregate all my subscriptions";
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.aggv2sub}/bin/aggv2sub";
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
  system.stateVersion = "22.05"; # Did you read the comment?

}

