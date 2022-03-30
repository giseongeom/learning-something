#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

curl -L -Ss "https://github.com/cloverstd/tcping/releases/download/v0.1.1/tcping-linux-amd64-v0.1.1.tar.gz" -o "/tmp/tcping-linux.tgz"
tar zxf /tmp/tcping-linux.tgz -C /usr/local/bin && cd /usr/local/bin/ && chown root.root tcping && chmod 755 tcping
/usr/local/bin/tcping -v
echo "tcping for Linux Installation is Done!"