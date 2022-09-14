{ config, pkgs, ... }:

{
  # Docker
  virtualisation.docker = {
    enable = true;
    extraOptions = " -g /srv/nas/docker";
    enableOnBoot = true;
    listenOptions = [
      "/run/docker.sock"
      "0.0.0.0:2375"
    ];
  };

  # Transmission
  services.transmission = {
    enable = true;
    openFirewall = true;
    home = "/srv/nas/config/transmission";
    settings.rpc-port = 9091;
    openRPCPort = true;
    credentialsFile = "/srv/nas/config/transmission.json";
    downloadDirPermissions = "777";
    settings = {
      rpc-whitelist-enabled = false;
      rpc-bind-address = "0.0.0.0";
      download-dir = "/srv/nas/storage/Torrents/Transmission";
      incomplete-dir-enabled = false;
      umask = 0;
      ratio-limit-enabled = true;
      ratio-limit = 1;
      download-queue-enabled = false;
      utp-enabled = true;
      port-forwarding-enabled = true;
    };
  };
  services.nzbget = {
    enable = true;
    settings = { MainDir = "/srv/nas/storage/Usenet"; };
  };

  # Samba
  services.samba-wsdd.enable =
    true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = cappynas
      netbios name = cappynas
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0 192.168.1 127.0.0.1 localhost 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      nas = {
        path = "/srv/nas/storage/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        writeable = "yes";
        "create mask" = "0777";
        "directory mask" = "0777";
      };
    };
  };

  # Avahi
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.caddy = {
    enable = true;
    # file server at /srv/nas/storage/public
    extraConfig = ''
      :80 {
        root * /srv/nas/storage/public
        file_server browse
      }
    '';
  };
}
