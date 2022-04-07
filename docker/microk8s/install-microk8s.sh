#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# microk8s
# https://microk8s.io/docs/getting-started
# https://gist.github.com/JonTheNiceGuy/6ea77cb3e04eed48c4038ca06de3d0ae
snap install microk8s --classic
snap install docker
microk8s.status --wait-ready
usermod -a -G microk8s vagrant
echo "alias kubectl='microk8s.kubectl'" > /home/vagrant/.bash_aliases
chown vagrant:vagrant /home/vagrant/.bash_aliases
echo "alias kubectl='microk8s.kubectl'" > /root/.bash_aliases
chown root:root /root/.bash_aliases
# https://askubuntu.com/questions/941816/permission-denied-when-running-docker-after-installing-it-as-a-snap
sudo addgroup --system docker
sudo adduser vagrant docker
newgrp docker
sudo snap disable docker && sudo snap enable docker