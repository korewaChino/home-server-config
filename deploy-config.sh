#!/bin/bash

# This script remotely deploys the nix config to the target machine using SSH.


SSH_HOST="cappy@192.168.1.38"

# scp the nix/ folder to a temporary location on the target machine
scp -r nix/. $SSH_HOST:/tmp/nixcfg


# copy it to the actual location with sudo
ssh $SSH_HOST "sudo cp -rv /tmp/nixcfg/* /etc/nixos/"
ssh $SSH_HOST "rm -rf /tmp/nixcfg"

# Execute the nixos-rebuild command
ssh $SSH_HOST "sudo nixos-rebuild switch $*"

# scp grafana-agent.yaml $SSH_HOST:/srv/nas/config/grafana-agent.yaml