{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nix.registry.nixpkgs.flake = nixpkgs;
    nixosConfigurations.tardis = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.neovim.overlay
            inputs.nixpkgs-wayland.overlay
          ];
          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
          nix.registry.p.flake = self;
        }
      ];
      specialArgs = { inherit nixpkgs inputs; };
    };
  };
}
