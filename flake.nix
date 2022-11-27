{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    v2t = {
      url = "github:adwingray/v2ray-tools";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    aggv2sub = {
      url = "github:adwingray/aggv2sub";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nix.registry.nixpkgs.flake = nixpkgs;
    templates = {
      rust = {
        path = ./templates/rust;
        description = "A simple Rust project";
        welcomeText = ''
          # Simple Rust Template
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
              inputs.neovim.overlay
              inputs.rust-overlay.overlays.default
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.p.flake = self;
          }
        ];
        specialArgs = { inherit nixpkgs inputs; };
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
              inputs.neovim.overlay
              inputs.aggv2sub.overlay
              inputs.rust-overlay.overlays.default
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.p.flake = self;
          }
        ];
        specialArgs = { inherit nixpkgs inputs; };
      };
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/vm/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.neovim.overlay
              inputs.nixpkgs-wayland.overlay
              inputs.v2t.overlay
              inputs.rust-overlay.overlays.default
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.p.flake = self;
          }
        ];
        specialArgs = { inherit nixpkgs inputs; };
      };
      tardis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./nixos/tardis/configuration.nix
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.neovim.overlay
              # inputs.nixpkgs-wayland.overlay
              inputs.v2t.overlay
              inputs.rust-overlay.overlays.default
              inputs.berberman.overlay
              (import ./overlays/sway/overlay.nix)
              (import ./overlays/cgproxy/overlay.nix)
              (import ./overlays/tree-sitter/gen-overlay.nix nixpkgs)
            ];
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.p.flake = self;
          }
        ];
        specialArgs = { inherit nixpkgs inputs; };
      };
    };
  };
}
