{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nix.registry.nixpkgs.flake = nixpkgs;
      devShells.default = pkgs.mkShell {
        buildInputs = [];
      };
    }
    )
  // {
    templates = {
      rust = {
        path = ./templates/rust;
        description = "A simple Rust project";
        welcomeText = ''
          # Simple Rust Template
        '';
      };
      rust-global = {
        path = ./templates/rust-global;
        description = "A simple Rust project with shared rust toolchain";
        welcomeText = ''
          # Simple Rust Template with shared rust toolchain 
        '';
      };
      racket = {
        path = ./templates/racket;
        description = "A simple Racket project";
        welcomeText = ''
          # Simple Racket Template
        '';
      };
      cpp = {
        path = ./templates/cpp;
        description = "A simple C++ project";
        welcomeText = ''
          # Simple C++ Template
        '';
      };
      python = {
        path = ./templates/python;
        description = "A simple Python project";
        welcomeText = ''
          # Simple Python Template
        '';
      };
      coq = {
        path = ./templates/coq;
        description = "A simple Coq project";
        welcomeText = ''
          # Simple Coq Template
        '';
      };
      node = {
        path = ./templates/node;
        description = "A simple NodeJS project";
        welcomeText = ''
          # Simple NodeJS Template
        '';
      };
      basic = {
        path = ./templates/basic;
        description = "A simple project";
        welcomeText = ''
          # Simple Template
        '';
      };
    };
    nixosConfigurations = {
      natsel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/natsel/configuration.nix
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (import ./overlays/static/overlay.nix)
              (import ./overlays/misc.nix)
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      bluespace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/bluespace/configuration.nix
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.mailserver.nixosModules.mailserver
          {
            nixpkgs.overlays = [
              (import ./overlays/misc.nix)
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      sunny = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/sunny/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/vm/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (import ./overlays/misc.nix)
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      tardis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/tardis/configuration.nix
          inputs.impermanence.nixosModules.impermanence
          inputs.nix-index-database.nixosModules.nix-index
          # optional to also wrap and install comma
          { programs.nix-index-database.comma.enable = true; 
            programs.command-not-found.enable = false;
          }
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
      black = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/black/configuration.nix
          inputs.impermanence.nixosModules.impermanence
          inputs.nix-index-database.nixosModules.nix-index
          # optional to also wrap and install comma
          { programs.nix-index-database.comma.enable = true; 
            programs.command-not-found.enable = false;
          }
          inputs.home-manager.nixosModules.home-manager
          {
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.os.flake = self;
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };
    };
  };
}
