final: prev: {
  filetype-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
    name = "filetype-nvim";
    src = prev.fetchFromGitHub {
      owner = "nathom";
      repo = "filetype-nvim";
      rev = "b522628a45a17d58fc0073ffd64f9dc9530a8027";
      hash = "sha256-B+VvgQj8akiKe+MX/dV2/mdaaqF8s2INW3phdPJ5TFA=";
    };
  };
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
