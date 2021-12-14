{ lib, stdenv, fetchFromGitHub, kernel, bc }:

stdenv.mkDerivation {
  pname = "rtl8188egu";
  version = "${kernel.version}-unstable-2021-12-13";

  src = fetchFromGitHub {
    owner = "McMCCRU";
    repo = "rtl8188gu";
    rev = "94e8f154ddac8de9d8a82c479f1c4bcdb733894d";
    sha256 = "W3WrGsl8GTchipZc2fIwioUGYkTQvZDTvs6MSEp1QgU=";
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
    description = "RealTek RTL8188gu WiFi driver ";
    homepage = "https://github.com/McMCCRU/rtl8188gu";
    # broken = kernel.kernelAtLeast "5.15" || kernel.isHardened;
  };
}
