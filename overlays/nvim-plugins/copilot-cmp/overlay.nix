final: prev: {
  final.vimPlugins = prev.vimPlugins // {
    copilot-cmp = prev.vimPlugins.copilot-cmp.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./avoid-rate-limit.patch
      ];
    });
  };
}
