nixpkgs: final: prev: {
  tree-sitter-proto = prev.callPackage
    (nixpkgs + /pkgs/development/tools/parsing/tree-sitter/grammar.nix) { } {
      language = "proto";
      version  = "0.1.0";
      src   = prev.fetchFromGitHub {
        owner = "mitchellh";
        repo = "tree-sitter-proto";
        rev = "42d82fa18f8afe59b5fc0b16c207ee4f84cb185f";
        sha256 = "001y2z2683fagryqj5f0gs3rcgx2nbw3x3r9afydhss80ihb8zvi";
        fetchSubmodules = true;
      };
    };
}
