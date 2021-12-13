{ lib, stdenv, fetchFromGitHub, kernel, bc }:

stdenv.mkDerivation {
  pname = "rtl8821cu";
  version = "${kernel.version}-unstable-2021-12-13";

  src = fetchFromGitHub {
    owner = "McMCCRU";
    repo = "rtl8821cu";
    rev = "bf385ce656f74f25a146998cc7173b5cd9188f1e";
    sha256 = "Zm5iP8IrKe3ux0YhcWx4uyWvFQXnMZyd6UfPBuH8ul4=";
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
    homepage = "https://github.com/McMCCRU/rtl8188gu";
    # broken = kernel.kernelAtLeast "5.15" || kernel.isHardened;
  };
}
