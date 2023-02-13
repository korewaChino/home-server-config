{ config, pkgs, ... }:

{
  # Docker
  virtualisation.docker = {
    enable = true;
    extraOptions = " -g /srv/nas/docker";
    enableOnBoot = true;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };
  # imports = [
  #   ./secret.nix
  # ];

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

  # free game claimer
  systemd.timers."fgc" = {
    wantedBy = [ "timers.target" ];
    # every 24 hours
    timerConfig = {
      OnCalendar = "daily";
      Unit = "fgc.service";
    };
  };

  systemd.services."fgc" = {
    script = ''
      ${pkgs.docker}/bin/docker run --rm -i -p 6080:6080 -p 5900:5900 -v fgc:/fgc/data -e TIMEOUT=60 --pull=always ghcr.io/vogler/free-games-claimer
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";

    };

  };

  systemd.services."glances" = {
    description = "Glances System Monitor";
    restartIfChanged = true;
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 1;
      ExecStart = "${pkgs.glances}/bin/glances -w";
    };
  };

  systemd.services.b2-storage = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = true;
    # restartTriggers = [ config.environment.etc."rclone/rclone.conf".source ];
    script = ''
      ${pkgs.rclone}/bin/rclone mount 'b2:cappy-storage/' /srv/b2 \
        --config=/etc/rclone/rclone.conf \
        --allow-other \
        --allow-non-empty \
        --log-level=INFO \
        --buffer-size=50M \
        --use-server-modtime \
        --drive-acknowledge-abuse=true \
        --async-read \
        --cache-dir /srv/nas/cache/rclone \
        --vfs-cache-mode full \
        --vfs-cache-max-size 20G \
        --vfs-read-chunk-size=32M \
        --vfs-read-chunk-size-limit=256M
    '';
    serviceConfig = {
      User = "root";
      ExecStop = "/run/wrappers/bin/fusermount -uz /srv/b2";
      Restart = "always";
      RestartSec = "10s";
      Environment = [ "PATH=${pkgs.fuse}/bin:$PATH" ];
    };
  };

  systemd.services.r2-storage = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = true;
    # restartTriggers = [ config.environment.etc."rclone/rclone.conf".source ];
    script = ''
      ${pkgs.rclone}/bin/rclone mount 'r2:storage/' /srv/r2 \
        --config=/etc/rclone/rclone.conf \
        --allow-other \
        --allow-non-empty \
        --log-level=INFO \
        --buffer-size=50M \
        --use-server-modtime \
        --drive-acknowledge-abuse=true \
        --async-read \
        --cache-dir /srv/nas/cache/rclone \
        --vfs-cache-mode full \
        --vfs-cache-max-size 20G \
        --vfs-read-chunk-size=32M \
        --vfs-read-chunk-size-limit=256M
    '';
    serviceConfig = {
      User = "root";
      ExecStop = "/run/wrappers/bin/fusermount -uz /srv/r2";
      Restart = "always";
      RestartSec = "10s";
      Environment = [ "PATH=${pkgs.fuse}/bin:$PATH" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/nas/cache/rclone 0777 cappy users - -"
    "d /srv/b2 0777 cappy users - -"
    "d /srv/r2 0777 cappy users - -"
  ];

}
