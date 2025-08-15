#!/usr/bin/bash

# Install rancher cli
wget -qO- https://github.com/rancher/cli/releases/download/v2.4.10/rancher-linux-amd64-v2.4.10.tar.gz \
  | tar xvz -C /tmp
mv /tmp/rancher-*/rancher /usr/local/bin/
rmdir /tmp/rancher-*
