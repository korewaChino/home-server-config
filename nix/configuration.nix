# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Allow non-free packages, becasue I do not care lol
  nixpkgs.config.allowUnfree = true;
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services.nix
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/raspberry-pi/4"
    (fetchTarball
      "https://github.com/msteen/nixos-vscode-server/tarball/master")
  ];
  # system.autoUpgrade.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  #boot.loader.raspberryPi = {
  #  enable = true;
  #  version = 4;
  #};
  # For convenience's sake. Actually not secure
  security.sudo.wheelNeedsPassword = false;

  services.logind.extraConfig = ''
    RuntimeDirectorySize=4G
    RuntimeDirectoryInodesMax=1048576
  '';
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  # Don't spam logs about missing SD cards
  # boot.loader.raspberryPi.firmwareConfig = ''
  #   dtparam=sd_poll_once=on
  #     arm_boost=1'';

  boot.loader.raspberryPi.firmwareConfig =
    lib.strings.concatLines [ "dtparam=sd_poll_once=on" "arm_boost=1" ];

  # === Network configuration. ===
  networking.hostName = "cappynas"; # Define your hostname.
  networking.wireless.enable =
    false; # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # == Services ==
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # == Hardware configuration ==

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # == User accounts ==

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cappy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # == Stuff ==

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    docker
    docker-compose
    gnumake
    arion
    btrfs-progs
    libraspberrypi
    ncdu_2
    htop
    nano
    glances
    rclone
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # zram
  zramSwap.enable = true;

  nix = {
    settings.auto-optimise-store = true;
    settings.trusted-users = [ "root" "@wheel" "cappy" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # VSCode SSH Fix
  services.vscode-server.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.nfs.server.enable = true;
  services.nfs.server.exports = lib.strings.concatLines [
    "/srv/nas/storage         *(rw,nohide,insecure,no_subtree_check,crossmnt,async)"
    "/srv/nas          *(rw,nohide,insecure,no_subtree_check,crossmnt,async)"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
