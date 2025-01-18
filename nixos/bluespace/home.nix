{ pkgs, lib, config, ...}:
{
  home.packages = with pkgs; [
    mailutils
    bat
    gh
    tmux
    # headscale
    killall
    tailscale
    # black
    socat
    htop
    lsof
    tree
    ripgrep
    fd
    xh
    file
    trash-cli
    nix-prefetch-github
    # nodePackages.pyright
    # nil
    # ccls
    # gopls
    # delve
    tealdeer
    # rust-bin.stable.latest.default
    # poetry
    # fortran-language-server
    eza
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true; 
    };
    git = {
      enable = true;
      userName  = "Adwin White";
      userEmail = "adwinw01@gmail.com";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
    fish = {
      enable = true;
      shellInit = ''
        fish_vi_key_bindings
        bind -M insert -m default jj backward-char force-repaint
        bind -M insert \cf forward-char
        bind -M insert \cg forward-word
	set -g -x EDITOR nvim
        alias ls="eza"
        alias ll="eza -1la"
        bind -e \cl
        eval (direnv hook fish)
      '';
      plugins = [
        {
          name = "theme-budspencer";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            "repo" = "theme-budspencer";
            "rev" = "835335af8e58dac22894fdd271d3b37789710be2";
            "sha256" = "kzg1RMj2s2HPWqz9FX/fWQUCiWI65q6U8TcA0QajaX4=";
            "fetchSubmodules" = true;
          };
        }
      ];
    };
    neovim.enable = true;
  };

  systemd.user = {
    services = {
      "hugo" = {
        Unit = {
          Description = "hugo for yjy blog";
        };
        Service = {
          Type = "simple";
          WorkingDirectory = "/home/adwin/yjy-blog";
          ExecStart = "${pkgs.hugo}/bin/hugo server -p 1313";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
      "yjy-blog-sync" = {
        Unit = {
          Description = "yjy blog sync service";
        };
        Service = {
          Type = "simple";
          WorkingDirectory = "/home/adwin/yjy-blog";
          ExecStart = let push_handler = pkgs.writeShellApplication {
            name = "push_handler";

            runtimeInputs = with pkgs; [ 
              git
              openssh
              (python3.withPackages (ps: with ps; [ fastapi uvicorn ]))
            ];

            text = ''
              python sync_repo.py
            '';
          }; in 
              "${push_handler}/bin/push_handler";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
      "status_email_user@" = {
        Unit = {
          Description = "status email for %i to user";
        };
        Service = {
          Type = "oneshot";
          ExecStart = let systemd-email = pkgs.writeShellApplication {
            name = "systemd-email";

            runtimeInputs = with pkgs; [ mailutils  ];

            text = ''
              mail -s "Service $2 failed" -r bluespace@adwin.win "$1" <<ERRMAIL
              Hi Adwin, 
              There is something wrong with your logseq backup service. 
              Would you like to have a check?

              This is the log:

              $(systemctl --user status --full "$2")

              Best regards,
              Bluespace
              ERRMAIL
            '';
          }; in
              "${systemd-email}/bin/systemd-email i@adwin.win %i";
        };
      };
      logseq-backup = {
        Unit = {
          Description = "Backup logseq notes to github";
          OnFailure = "status_email_user@%n.service";
        };
        Service = {
          Type = "oneshot";
          ExecStart = let git-backup = pkgs.writeShellApplication {
            name = "git-backup";

            runtimeInputs = with pkgs; [ git openssh ];

            text = ''
              cd "$1"
              git add ./* 
              if output=$(git status --porcelain) && [ -z "$output" ]; then
                # Working directory clean
                :
              else 
                # Uncommitted changes
                git commit -m "backup" && git push
              fi
              '';
            }; in
              "${git-backup}/bin/git-backup /home/adwin/Documents/TheNotes";
        };
      };
    };

    timers = {
      logseq-backup = {
        Unit = {
          Description = "Backup logseq notes to github";
        };
        Timer = {
          OnCalendar = "*-*-* 20:00:00 UTC";
          Persistent = true;
        };
        Install = {
          WantedBy= [ "timers.target" ];
        };
      };
    };
  };


  home.stateVersion = "22.05";
}
