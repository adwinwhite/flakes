{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    v2t = {
      url = "github:adwingray/v2ray-tools";
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
      inputs.flake-utils.follows = "flake-utils";
    };

    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nix.registry.nixpkgs.flake = nixpkgs;
    nixosConfigurations.natsel = nixpkgs.lib.nixosSystem {
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
    nixosConfigurations.bluespace = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./nixos/bluespace/configuration.nix
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
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
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
    nixosConfigurations.tardis = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./nixos/tardis/configuration.nix
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.neovim.overlay
            inputs.nixpkgs-wayland.overlay
            inputs.v2t.overlay
            inputs.rust-overlay.overlays.default
            inputs.berberman.overlay
            (import ./overlays/sway/overlay.nix)
            (import ./overlays/cgproxy/overlay.nix)
          ];
          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
          nix.registry.p.flake = self;
        }
      ];
      specialArgs = { inherit nixpkgs inputs; };
    };
  };
}
