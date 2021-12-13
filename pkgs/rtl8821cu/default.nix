{ lib, stdenv, fetchFromGitHub, kernel, bc }:

stdenv.mkDerivation {
  pname = "rtl8821cu";
  version = "${kernel.version}-unstable-2021-12-13";

  src = fetchFromGitHub {
    owner = "alteman";
    repo = "rtl8821cu";
    rev = "61c9f0290fe8f79b5257efb2d9875e27658ff919";
    sha256 = "i20zWyqqPSSIdsF7V2vn0njcenkyrt40+OH1EEkQ0sU=";
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
    homepage = "https://github.com/alteman/rtl8821cu";
    # broken = kernel.kernelAtLeast "5.15" || kernel.isHardened;
  };
}
