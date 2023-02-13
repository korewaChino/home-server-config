# Configuration files for my Raspberry Pi 4B home server

These are the configuration files for my Raspberry Pi 4B home server running NixOS.

You can see the live version of the server at <https://home.cappuchino.xyz>. It has a private Jellyfin instance, and a partially-public Komga server.

Note: These configs cannot be used as-is, as they contain system-specific information that is only relevant to my setup.

## Hardware

- Raspberry Pi 4B 4GB
- [ORICO 2-bay USB 3.0 HDD Docking Station (6629US3-C)](https://www.orico.cc/us/product/detail/3551.html)
  
  Notes: I actually do not recommend anyone this dock, as it is very unreliable.
  The dock is powered by a 12V 3A power supply, and sometimes crashes when I use more than 1 drive at a time. I recommend you buy a dock that is properly designed to handle multiple drives instead.
- 2TB Seagate IronWolf NAS HDD

## Setup

I will add a config for storage setup later for even quicker setup, but for now, you will have to do it manually.

### Setting up the storage

1. Plug in the HDD to your dock/enclosure of choice.
2. Format the HDD as BTRFS using the following command:
  
  ```bash
  sudo mkfs.btrfs -L NAS -f /dev/<device>
  ```
The disk label will be formatted as `NAS` as we will be using it with the NixOS config later.

You can also add in multiple drives if you want to use a RAID setup, using BTRFS volume groups.

### Setting up the Raspberry Pi (From the base NixOS image)

Disclaimer: This section of the guide expects you to have a basic understanding of Nix, NixOS, and how the Raspberry Pi hardware works. It is also recommended you use a Raspberry Pi 4B 4GB or higher, as the 2GB model is not powerful enough to run NixOS.

You can also deploy the NixOS configs from the comfort of your own machine using [Colmena](https://colmena.cli.rs/unstable/)

Reference this article <https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi> if you would like more information about installing up NixOS on the Raspberry Pi.

1. Download the latest NixOS image for aarch64 from <https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux>

2. Flash the image to your SD card (or any USB drive) using dd, Etcher, or the Raspberry Pi Imager.

The next steps may require you to use a keyboard and monitor to set up the Raspberry Pi, or you can also SSH into the Raspberry Pi using the `nixos` user. The default password is `nixos`.

#### Deploying the NixOS configs (manually on hardware)

Once you get access to the console, you can deploy the NixOS configs by following these steps:

1. Install Git and clone this repository:
  
  ```bash
  sudo nix-env -iA nixos.git
  git clone https://github.com/korewaChino/home-server-config.git
  # enter the directory
  cd home-server-config
  ```

2. Copy the contents of the `nix` directory to `/etc/nixos` on the Raspberry Pi.

```bash
sudo cp -rv nix/ /etc/nixos
```

3. Edit any of the files in `/etc/nixos` as you see fit.

4. Run `nixos-install --root /` to install NixOS with the configs.

You may have to also set your own password for your account after the first boot, or right after the switch

#### Deploying the NixOS configs (using Colmena)

1. Install Colmena and clone this repository:
  
  ```bash
  nix-env -if https://github.com/zhaofengli/colmena/tarball/main
  git clone https://github.com/korewaChino/home-server-config.git
  # enter the directory
  cd home-server-config
  ```

2. Edit the Nix flake file (`flake.nix`) to use the `nixos` user, and change the IP addresses to your own.

3. Run `colmena apply` to deploy the configs to the Raspberry Pi.

---
After the first boot, you should be able to access the Raspberry Pi using SSH.

Docker will also be installed, with a TCP socket exposed on port 2375. This will prove useful later. (or you can also just use SSH docker remotes)

## Deploying the Docker services

You need:

- Docker w/ Docker Compose v2 installed

    the latter is available on most Docker distrbutions from the official Docker repositories, if you're using Fedora or Ultramarine, you can install the `moby-compose` package from [Terra](https://terra.fyralabs.com) if you're using the open-source Moby Engine (`moby-engine`). Docker Compose v1 can also be used, but it is not recommended.

- Configured environment variables for the services (see `.env.example` for an example)

- Configured config files in the `config` directory

To deploy the Docker services, run the just task `docker-setup`

```bash
just docker-setup
```

To update your configs, you can run the `docker-config` task

```bash
just docker-config
```

This will copy your config files to the respective directories.

## TODO

- Ansible playbook for setting up various services, or even the entire server
- Add a script to automatically set up the storage
- Move the config folders to actual Docker volumes
- NixOS configs to build a pre-configured Raspberry Pi image
- Branding (possibly? xd)
- (possibly) Move to Fedora/Ultramarine CoreOS or tauOS Core (when Fyra Labs finally builds a proper system management tool for it)
- Reverse proxy setup for easier access to all services
- Custom web interface to replace organizr and homepage, probably written in Rust and TypeScript (maybe Node.js or Deno)
- Templating system to keep secrets out of the repo
- Migrate to Docker Swarm for secrets and config management
- Add back config folders to the repo, and figure out a way to keep secrets out of the source


## Software list

- NixOS Unstable
  - NFS server
  - Samba
  - OpenSSH Server
  - htop
  - glances
  - rclone
  - BTRFS
  - ncdu
  - Docker w/ Docker Compose v2
  - Caddy

### Services

- NFS server
- Samba
- OpenSSH Server
- glances web interface
- Caddy web server (<https://files.cappuchino.xyz>)
- Jellyfin (<https://jellyfin.cappuchino.xyz>)
  - jfa-go (<https://jellyfin-accounts.cappuchino.xyz>)
- Ombi (<https://ombi.cappuchino.xyz>)
- Grafana Agent
- Tanoshi (to be replaced by Komga and Kaizoku)
- Komga (<https://komga.cappuchino.xyz>)
- Kaizoku
- Cloudflare Tunnel
- Syncthing
- The *arr suite
  - Sonarr
  - Radarr
  - Prowlarr
  - Lidarr
- Recyclarr (for applying TRaSH rules to *arrs to increase torrent quality)
- Watchtower
- Transmission
  - [Transmission auto tracker script](https://github.com/AndrewMarchukov/tracker-add)
- Organizr (<https://dashboard.cappuchino.xyz>) (deprecated)
- Homepage (<https://home.cappuchino.xyz>)
- [Free Games Claimer script](https://github.com/vogler/free-games-claimer) Automatically claims free games from Epic Games Store, Amazon Prime Gaming, and GOG. You might not want to use this if you really value your ban status.

## External services

I use Cloudflare Tunnel to expose (some) of my services to the internet, since my network is behind a NAT (thanks, TRUE).

You can also set up your own reverse proxy using Caddy or Traefik, if you have a public IP address.

### External Cloud storage

External cloud storage is set up using rclone. I use the following remotes:

- Cloudflare R2 for hot storage (unused for now because it's expensive)
- Backblaze B2 for long-term storage (used in Komga)
- Fyra Labs MinIO for other storage (private cloud example)
