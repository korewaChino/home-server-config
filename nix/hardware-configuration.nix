# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  #tmpfsOpts = [ "nosuid" "nodev" "relatime" "size=4G" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/srv/nas" = {
    device = "/dev/disk/by-label/NAS";
    fsType = "btrfs";
    options = [ "rw" "auto" "defaults" "autodefrag" "compress=zstd" ];
  };

  #fileSystems."/tmp" =
  #  { device = "tmpfs";
  #    fsType = "tmpfs";
  #    options = [ "nosuid" "nodev" "relatime" "size=4G" ];
  #  };
  fileSystems."/export/nas" = {
    device = "/srv/nas/storage";
    options = [ "bind" ];
    depends = [ "/srv/nas" ];
  };

  # fileSystems."/srv/b2" = {
  #   device = "b2:cappy-storage";
  #   fsType = "fuse.rclone";
  #   options = [ "allow_other" "default_permissions" "uid=1001" "gid=1001" "cache_dir=/srv/nas/cache/b2" "nofail" ];
  #   # add wrappers

  # };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
