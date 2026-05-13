pkgs: let 
  overrides = { toolchain = { channel = "nightly"; }; };
  libPath = with pkgs; lib.makeLibraryPath [
    openssl
    # load external libraries that you need in your rust project here
  ];
    in
pkgs.mkShell {
  buildInputs = with pkgs; [
    pkg-config
    alsa-lib
    openssl
    mold
    clang
    # Replace llvmPackages with llvmPackages_X, where X is the latest LLVM version (at the time of writing, 16)
    llvmPackages.bintools
    rustup
    cmake
    fontconfig
    systemdLibs
    glib
    dbus
    libepoxy
    nettle
    ffmpeg-headless
    xorg.libX11
    fuse
    fuse3
    zstd
    chafa
    mpich
    kdePackages.wayland
    zfs
    zfs.dev
    libgpg-error
    cyrus_sasl
    protobuf
    nasm
    gpgme
    gst_all_1.gstreamer
    cairo
    python3
    llvmPackages_18.libllvm
    gtk3
    libpq
    libxkbcommon
    gdk-pixbuf
    libmysqlclient
    mate.mate-settings-daemon
    capnproto
    speechd-minimal
    libjack2
    webkitgtk_4_1
    gnum4
    libsoup_3
    openssl
    pcsclite.lib
    pcsclite.dev
    libelf
    libbpf
    cyrus_sasl
    graphene.dev
    gtk4.dev
    xorg.libXtst
    zfs.dev
    libxml2.dev
    wxGTK31
    libadwaita.dev
    libadwaita
    curl.dev
  ];
  RUSTC_VERSION = overrides.toolchain.channel;
  # https://github.com/rust-lang/rust-bindgen#environment-variables
  LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
  shellHook = ''
    export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
    export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
    '';
  # Add precompiled library to rustc search path
  RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
    # add libraries here (e.g. pkgs.libvmi)
  ]);
  LLVM_SYS_181_PREFIX = pkgs.llvmPackages_18.libllvm;
  # K8S_OPENAPI_ENABLED_VERSION = "1.50";
  PYO3_USE_ABI3_FORWARD_COMPATIBILITY = "1";
  LD_LIBRARY_PATH = libPath;
  # Add glibc, clang, glib, and other headers to bindgen search path
  BINDGEN_EXTRA_CLANG_ARGS =
  # Includes normal include path
  (builtins.map (a: ''-I"${a}/include"'') [
    # add dev libraries here (e.g. pkgs.libvmi.dev)
    pkgs.glibc.dev
  ])
  # Includes with special directory paths
  ++ [
    ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
    ''-I"${pkgs.glib.dev}/include/glib-2.0"''
    ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
  ];
}
