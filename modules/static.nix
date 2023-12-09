{ config, lib, pkgs, ... }:

with lib;

let
  pkg = pkgs.static-host;
  cfg = config.services.static-host;
in
{
  options = {
    services.static-host = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to run static.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 2345;
        example = 2345;
        description = lib.mdDoc ''
          The port to listen on.
        '';
      };

      directory = mkOption {
        type = types.str;
        default = "/tmp/files";
        example = "/tmp/files";
        description = lib.mdDoc ''
          The directory to save files and serve.
        '';
      };
    };
  };

  config = mkIf (cfg.enable) {
    systemd.packages = [ pkg ];

    systemd.services.static-host = {
      serviceConfig.ExecStart = "${pkg}/bin/static-host";
      environment = {
        PORT = builtins.toString cfg.port;
        STATIC_DIR = cfg.directory;
      };

      # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
      wantedBy = [ "multi-user.target" ];
    };
  };
}
