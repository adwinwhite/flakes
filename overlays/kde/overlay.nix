final: prev: {
  kdePackages = prev.kdePackages // {
    kwin = prev.kdePackages.kwin.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./disable_three_fingers_gestures.patch
      ];
    });
  };
}
