{ lib, stdenv, fetchFromGitHub, clang, libbpf, nlohmann_json, cmake, libelf, zlib, util-linux, makeWrapper, procps, iproute2, iptables, coreutils-full, which }:

stdenv.mkDerivation {
  pname = "cgproxy";
  version = "0.19";

  src = fetchFromGitHub {
    owner = "springzfx";
    repo = "cgproxy";
    rev = "aaa628a76b2911018fc93b2e3276c177e85e0861";
    sha256 = "j3GIO4CWujH/Do6fkIe3ulRnzQyrmZXf9bWFp4KOdFg=";
    fetchSubmodules = true;
  };

  patches = [ ./env_config_file.patch ];

  postPatch = "patchShebangs *.sh";

  buildInputs = [ 
    nlohmann_json
    libbpf
    libelf
    zlib
    makeWrapper
  ];

  nativeBuildInputs = [
    clang
    cmake
  ];

  configurePhase = ''
    cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -Dbuild_execsnoop_dl=ON \
      -Dbuild_static=OFF \
      -DCMAKE_INSTALL_PREFIX=$out \
      .
  '';

  buildPhase = ''
    make
  '';

  postFixup = ''
    wrapProgram $out/bin/cgproxy --prefix PATH : ${lib.concatStringsSep ":"  [
      "/run/current-system/sw/bin"
      (lib.makeBinPath [
        util-linux
        procps
        coreutils-full
        iproute2
        iptables
        which
      ])
    ]}
  '';

  meta = with lib; {
    description = "Transparent Proxy with cgroup v2";
    homepage = "https://github.com/springzfx/cgproxy";
    license = licenses.gpl2;
  };
}

