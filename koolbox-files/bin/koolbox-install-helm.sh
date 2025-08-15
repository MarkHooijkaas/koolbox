#!/usr/bin/bash


# Install helm3

mkdir /tmp/helm
wget -qO- "https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz" | tar xvz -C /tmp/helm/
mv /tmp/helm/linux-amd64/helm /usr/local/bin/
rm -rf /tmp/helm
