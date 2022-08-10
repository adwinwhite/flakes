final: prev: {
  cgproxy = prev.symlinkJoin {
    name = "cgproxy";
    paths = [ (prev.callPackage ./../../pkgs/cgproxy {}) ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cgproxy \
        --set PATH ${prev.lib.makeBinPath [
          prev.util-linux
          prev.coreutils-full
          prev.iproute2
          prev.iptables
          prev.which
          prev.v2ray
        ]}
      wrapProgram $out/bin/cgproxyd \
        --set PATH ${prev.lib.makeBinPath [
          prev.util-linux
          prev.coreutils-full
          prev.iproute2
          prev.iptables
          prev.which
          prev.v2ray
        ]}
      wrapProgram $out/bin/cgnoproxy \
        --set PATH ${prev.lib.makeBinPath [
          prev.util-linux
          prev.coreutils-full
          prev.iproute2
          prev.iptables
          prev.which
          prev.v2ray
        ]}
    '';
  };
}
