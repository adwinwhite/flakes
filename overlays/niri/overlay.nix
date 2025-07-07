final: prev: {
  niri = prev.niri.overrideAttrs (finalAttrs: prevAttrs: {
    cargoHash = "sha256-fT0L/OTlQ9BnKHnckKsLi+tN+oevEU+eJWrh1INqQhA="; # build and replace this
    src = prev.fetchFromGitHub {
      owner = "adwinwhite";
      repo = "niri";
      rev = "3850cb029cedb96905645109f067f77e881536b9";
      hash = "sha256-tiUNiKM9kzDmXWe+hrrbCDVrnEkBB2b5im00k0cDrEE=";
    };
    version = "25.05.2"; # change this
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src version;
      hash = finalAttrs.cargoHash;
    };
    nativeInstallCheckInputs = [];
  });
}
