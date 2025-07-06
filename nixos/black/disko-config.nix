# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/sda";
# }
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            NIXBOOT = {
              label = "NIXBOOT";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            NIXSWAP = {
              label = "NIXSWAP";
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            NIXROOT = {
              label = "NIXROOT";
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
