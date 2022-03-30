#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

curl -Ss "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
cd /tmp && unzip -q /tmp/awscliv2.zip
/tmp/aws/install
rm -f /tmp/awscliv2.zip
rm -rf /tmp/aws/
/usr/local/bin/aws --version
echo "AWSCLI Installation is Done!"