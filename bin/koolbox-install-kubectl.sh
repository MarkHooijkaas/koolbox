#!/usr/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc


# install latest stable
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# install specific version
#curl -LO "https://dl.k8s.io/release/${koolbox_kubectl_version}/bin/linux/amd64/kubectl"

koolbox_install_file_version kubectl ${koolbox_kubectl_version}
if ${koolbox_install_as_root}; then
    $KOOLBOX_INSTALL_DIR/kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
    sudo chmod a+r /etc/bash_completion.d/kubectl
else
    $KOOLBOX_INSTALL_DIR/kubectl completion bash >$(koolbox_install_completions_dir)/kubectl
fi
#rm kubectl

# Old Ubuntu way
#export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
#apt-get update
#apt-get -y install --no-install-recommends kubectl
#rm -rf /var/lib/apt/lists/*
