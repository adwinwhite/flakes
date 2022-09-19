{ lib, stdenv, fetchFromGitHub, clang, libbpf, nlohmann_json, cmake, libelf, zlib, util-linux, makeWrapper, procps, iproute2, iptables }:

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
    wrapProgram $out/bin/cgproxy --prefix PATH : ${lib.makeBinPath [
      util-linux
      procps
      iproute2
      iptables
    ]}
    echo '${builtins.readFile ./../../programs/cli/cgproxy.json}' > $out/etc/cgproxy/config.json  
    sed -i '252i ip6tables -w 60 -t mangle -A TPROXY_OUT -m mark --mark 0xff -j RETURN' $out/share/cgproxy/scripts/cgroup-tproxy.sh
    sed -i '208i iptables -w 60 -t mangle -A TPROXY_OUT -m mark --mark 0xff -j RETURN' $out/share/cgproxy/scripts/cgroup-tproxy.sh
  '';

  meta = with lib; {
    description = "Transparent Proxy with cgroup v2";
    homepage = "https://github.com/springzfx/cgproxy";
    license = licenses.gpl2;
  };
}

