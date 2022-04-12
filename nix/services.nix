{ config, pkgs, ... }:

{
  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = " -g /srv/nas/docker";

  # Transmission
  services.transmission = {
    enable = true;
    openFirewall = true;
    home = "/srv/nas/config/transmission";
    settings = {
        rpc-whitelist-enabled = false;
        rpc-bind-address = "0.0.0.0";
        download-dir = "/srv/nas/storage/Torrents/Transmission"
    };
  };
}