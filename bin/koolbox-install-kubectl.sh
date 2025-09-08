#!/usr/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/koolbox-install-init.sh



if [[ -z ${KOOLBOX_INSTALL_KUBECTL_VERSION:-} ]]; then
    # install latest stable
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod 755 kubectl
    KOOLBOX_INSTALL_KUBECTL_VERSION=$(./kubectl version --client|grep ^Client| sed 's/Client Version: v//')
    echo installed kubectl version $KOOLBOX_INSTALL_KUBECTL_VERSION
else
    # install specific version
    curl -LO "https://dl.k8s.io/release/${KOOLBOX_INSTALL_KUBECTL_VERSION}/bin/linux/amd64/kubectl"
fi
koolbox_install_file_version kubectl ${KOOLBOX_INSTALL_KUBECTL_VERSION}
rm kubectl

# Old Ubuntu way
#export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
#apt-get update
#apt-get -y install --no-install-recommends kubectl
#rm -rf /var/lib/apt/lists/*
