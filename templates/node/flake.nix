{
  description = "A Node project devShell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    node2nix = {
      url = "github:svanderburg/node2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, node2nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShell = mkShell {
          buildInputs = with pkgs;[
            nodejs
            # nodePackages.prettier
          ];

          # shellHook = ''
            # alias ls=exa
            # alias find=fd
          # '';
        };
      }
    );
}
