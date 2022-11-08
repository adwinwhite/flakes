{ config, lib, pkgs, ... }:

with lib;

let
  pkg = pkgs.cgproxy;
  format = pkgs.formats.json {};
  cfg = config.services.cgproxy;
in
{
  options = {
    services.cgproxy = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to run cgproxyd.
        '';
      };

      configFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/etc/cgproxy/config.json";
        description = lib.mdDoc ''
          The absolute path to the configuration file.
          `configFile` will override `settings`.
        '';
      };

      settings = mkOption {
        type = format.type;
        default = {};
        example = { 
          cgroup_noproxy = [ "/system.slice/v2ray.service" ]; 
          cgroup_proxy = [ "/" ]; 
          enable_dns = true; 
          enable_gateway = false; 
          enable_ipv4 = true; 
          enable_ipv6 = true; 
          enable_tcp = true; 
          enable_udp = true; 
          fwmark = 39283; 
          port = 12345; 
          program_noproxy = [ "v2ray" "qv2ray" ]; 
          program_proxy = [ ]; 
          table = 10007; 
        };
        description = lib.mdDoc ''
          The configuration.
          See <https://github.com/springzfx/cgproxy#configuration>.
        '';
      };
    };
  };

  config = mkIf (cfg.enable) {
    services.cgproxy = {
      settings = {
        port = mkDefault 12345;
        program_noproxy = mkDefault [ "v2ray" "qv2ray" ];
        program_proxy = mkDefault [];
        cgroup_noproxy = mkDefault [ "/system.slice/v2ray.service" ]; 
        cgroup_proxy = mkDefault [ "/" ]; 
        enable_dns = mkDefault true; 
        enable_gateway = mkDefault false; 
        enable_ipv4 = mkDefault true; 
        enable_ipv6 = mkDefault true; 
        enable_tcp = mkDefault true; 
        enable_udp = mkDefault true; 
        fwmark = mkDefault 39283; 
        table = mkDefault 10007;
      };
    };
    environment.etc."cgproxy/config.json".source = if cfg.configFile != null
      then cfg.configFile
      else pkgs.writeTextFile {
        name = "cgproxy.json";
        text = builtins.toJSON cfg.settings;
      };

    systemd.packages = [ pkg ];

    systemd.services.cgproxy = {
      environment = {
        CGPROXY_CONFIG_FILE_PATH = "/etc/cgproxy/config.json";
      };
      restartTriggers = [ config.environment.etc."cgproxy/config.json".source ];

      # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
      wantedBy = [ "multi-user.target" ];
    };
  };
}
