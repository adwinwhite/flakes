final: prev: {
  sway-unwrapped = prev.sway-unwrapped.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./ime_popup.patch
    ];
  });
}
