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
    hostName = "sunny";
    # to use fail2ban I have to enable firewall though I dont' really need it
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
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
    fail2ban.enable = true;
    openssh = {
      enable = true;
      passwordAuthentication = false;
      extraConfig = ''
        ClientAliveInterval 240
        ClientAliveCountMax 120
      '';
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

