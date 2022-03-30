#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export CURL_DOWNLOAD_URL="https://github.com/moparisthebest/static-curl/releases/download/v7.81.0/curl-amd64"
curl -Ss -L -o /usr/local/bin/curl ${CURL_DOWNLOAD_URL} \
    && chmod 755 /usr/local/bin/curl \
    && /usr/local/bin/curl --version \
    && echo "curl Installation is Done!"
