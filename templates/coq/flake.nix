{
  description = "A Coq project devShell";

  inputs = {
    # using pinned nixpkgs, change it if needed.
    nixpkgs.url      = "nixpkgs/nixos-unstable";
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
            coq
          ];

          # shellHook = ''
            # alias ls=exa
            # alias find=fd
          # '';
        };
      }
    );
}
