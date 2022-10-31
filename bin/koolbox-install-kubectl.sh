#!/usr/bin/bash


export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get -y install --no-install-recommends kubectl
rm -rf /var/lib/apt/lists/*
