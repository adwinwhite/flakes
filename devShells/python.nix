pkgs: let 
  # overrides = { toolchain = { channel = "nightly"; }; };
  libPath = with pkgs; lib.makeLibraryPath [
    # load external libraries that you need in your rust project here
  ];
    in
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    basedpyright
  ];
  shellHook = ''
    export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
    export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
    '';
  LD_LIBRARY_PATH = libPath;
}
