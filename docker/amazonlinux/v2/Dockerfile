# Base Image
FROM amazonlinux:2

# Maintainer
LABEL maintainer "GiSeong Eom"
LABEL email "jurist@kldp.org"

# Update
RUN yum update -y -q

# Install packages
RUN yum install -y -q cowsay wget jq net-tools vim-enhanced shadow-utils passwd sudo system-lsb

# Install Dev-related packages
RUN yum groupinstall -y -q 'Development Tools'

# chmod permission
RUN chmod 0744 /etc/shadow && chmod 0744 /etc/gshadow

# Update /etc/sudoers
# See http://www.theunixschool.com/2011/02/sed-replace-or-substitute-file-contents.html
RUN sed -i -e '$ a\\n\%wheel  ALL=(ALL)       NOPASSWD: ALL'  /etc/sudoers

# Add user
RUN useradd -m -G wheel -s /bin/bash giseongeom

# Update /etc/motd
ADD motd /etc/motd
RUN chmod 644 /etc/motd
