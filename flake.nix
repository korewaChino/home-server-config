{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, ... }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
    packages.x86_64-linux.colmena = nixpkgs.legacyPackages.x86_64-linux.colmena;

    # enable aarch64-linux
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # install packages

    # colmena
    colmena = {
      meta = {
        description = "Cappy's Homelab";
        nixpkgs = import nixpkgs { system = "aarch64-linux"; };
      };
      cappynas = { name, nodes, pkgs, ... }: {
        # import nix/configuration.nix
        imports = [ ./nix/configuration.nix ];

        # deployment.keys."rclone.conf" = {
        #   keyCommand = [ "cat" "./rclone.conf" ];
        #   permissions = "0644";
        #   uploadAt = "pre-activation";
        #   user = "root";
        #   group = "users";
        #   destDir = "/etc/rclone";
        # };

        environment.etc = {
          "rclone/rclone.conf" = {
            source = ./rclone.conf;
            mode = "0644";
          };
        };

        deployment = {
          targetHost = "192.168.1.38";
          targetPort = 22;
          targetUser = "cappy";
          privilegeEscalationCommand = [ "sudo" "-i" ];
        };
      };
    };

  };
}
