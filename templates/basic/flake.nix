{
  description = "A basic project devShell";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
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
            # alias ls=eza
            # alias find=fd
          # '';
        };
      }
    );
}
