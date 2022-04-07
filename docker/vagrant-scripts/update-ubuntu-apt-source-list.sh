#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

sed -i -e 's/us.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
