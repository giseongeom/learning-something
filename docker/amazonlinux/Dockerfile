# Base Image
FROM amazonlinux:2

# Maintainer
LABEL maintainer "GiSeong Eom"
LABEL email "jurist@kldp.org"

# Update
RUN yum -y -q update

# Install packages
RUN yum -y -q install vim-enhanced shadow-utils passwd sudo system-lsb

# chmod permission
RUN chmod 0744 /etc/shadow && chmod 0744 /etc/gshadow
