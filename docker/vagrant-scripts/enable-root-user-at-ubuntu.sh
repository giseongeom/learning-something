#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo -e "vagrant\nvagrant" | passwd root
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sed -in 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cp -av /home/vagrant/.ssh/ /root
chown -R root.root /root/.ssh
