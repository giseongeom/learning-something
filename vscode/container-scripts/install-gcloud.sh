#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && \
    # Install specific version
    # https://cloud.google.com/sdk/docs/install#installation_instructions
    #sudo apt-get install -y google-cloud-cli=378.0.0-0 && \
    # Install latest version
    sudo apt-get install -y google-cloud-cli && \
    gcloud version && \
    echo "gcloud Installation is done!" && \
    echo ''
