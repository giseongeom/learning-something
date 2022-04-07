#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ubuntu packages
export DEBIAN_FRONTEND=noninteractive
apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1

apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl jq net-tools ca-certificates
    #&& apt-get -y install --no-install-recommends git build-essential htop time p7zip-full unzip
