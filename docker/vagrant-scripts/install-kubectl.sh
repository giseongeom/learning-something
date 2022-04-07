#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# kubectl
curl --silent --output /tmp/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv /tmp/kubectl /usr/local/bin \
    && sudo chmod 755 /usr/local/bin/kubectl

# https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/#enable-kubectl-autocompletion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~vagrant/.bashrc
