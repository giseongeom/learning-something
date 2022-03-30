#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export GOLANG_DOWNLOAD_URL="https://go.dev/dl/go1.18.linux-amd64.tar.gz"

curl -Ss -L -o /tmp/golang.tgz ${GOLANG_DOWNLOAD_URL} \
    && tar zxf /tmp/golang.tgz -C /usr/local \
    && /usr/local/go/bin/go version \
    && echo "golang Installation is Done!" && echo ''

