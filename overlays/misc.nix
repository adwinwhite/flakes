final: prev: {
  v2ray = prev.symlinkJoin {
    name = "v2ray";
    paths = [ prev.v2ray ];
    postBuild = ''
      sed -i '7i LimitNOFILE=102400' $out/lib/systemd/system/v2ray.service
    '';
  };
  rust-tools-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
    name = "rust-tools-nvim";
    src = prev.fetchFromGitHub {
      owner = "simrat39";
      repo = "rust-tools.nvim";
      rev = "df584e84393ef255f5b8cbd709677d6a3a5bf42f";
      hash = "sha256-+/kK6MU2EiSBFbfqQJwLkJICXZpf8oiShbcvsls3V8A=";
    };
  };
}
