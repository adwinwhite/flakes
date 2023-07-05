{
  description = "A basic project devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShell = mkShell {
          buildInputs = [
            pkgs.hello
          ];

          # shellHook = ''
            # alias ls=exa
            # alias find=fd
          # '';
        };
      }
    );
}
