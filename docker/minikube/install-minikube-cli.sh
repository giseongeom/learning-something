#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# minikube
curl --silent -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm -f minikube-linux-amd64

# https://minikube.sigs.k8s.io/docs/commands/completion/#minikube-completion
echo 'source <(minikube completion bash)' >> ~/.bashrc
echo 'source <(minikube completion bash)' >> ~vagrant/.bashrc
