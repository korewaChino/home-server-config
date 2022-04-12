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
    port = 9091;
    openRPCPort = true;
    settings.rpc-whitelist-enabled = false;
    settings.rpc-bind-address = "0.0.0.0";
    credentialsFile = "/srv/nas/config/transmission.json";
    settings.download-dir = "/srv/nas/storage/Torrents/Transmission"
  };
}