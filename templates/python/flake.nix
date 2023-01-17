{
  description = "A poetry based Python development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          aggv2sub = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
            preferWheels = true;
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
        packageName = "ChangeYourPackageName";
      in
      {
        apps.${packageName} = pkgs.${packageName};

        defaultApp = pkgs.${packageName};

        packages.${packageName} = pkgs.${packageName};

        defaultPackage = pkgs.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (ps: with ps; [ poetry ]))
          ];
          # shellHook = ''
            # poetry shell
          # '';
        };
      }));
}
