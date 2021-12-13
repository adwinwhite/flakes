{ lib, stdenv, fetchFromGitHub, kernel, bc }:

stdenv.mkDerivation {
  pname = "rtl8821cu";
  version = "${kernel.version}-unstable-2021-12-13";

  src = fetchFromGitHub {
    owner = "brektrou";
    repo = "rtl8821CU";
    rev = "ef3ff12118a75ea9ca1db8f4806bb0861e4fffef";
    sha256 = "Ty0dZhX5Kk+fEpuBDN/PEXrFRUR0p07QJeybciW2at0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ bc ];

  buildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace '$(shell uname -r)' "${kernel.modDirVersion}" \
      --replace /sbin/depmod \# \
      --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "RealTek rtl8821cu WiFi driver ";
    homepage = "https://github.com/brektrou/rtl8821CU";
    # broken = kernel.kernelAtLeast "5.15" || kernel.isHardened;
  };
}
