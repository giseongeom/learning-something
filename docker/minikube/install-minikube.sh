#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# minikube
export MINIKUBE_IN_STYLE=0
sudo -u vagrant minikube start --driver docker --cpus 4 --memory 4g --wait=all --v=0  > /dev/null 2>&1
sudo -u vagrant minikube kubectl cluster-info
