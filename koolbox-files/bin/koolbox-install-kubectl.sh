#!/usr/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc


if [[ -z ${KOOLBOX_KUBECTL_VERSION:-} ]]; then
    # install latest stable
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod 755 kubectl
    KOOLBOX_KUBECTL_VERSION=$(./kubectl version --client|grep ^Client| sed 's/Client Version: v//')
    echo installed kubectl version $KOOLBOX_KUBECTL_VERSION
else
    # install specific version
    curl -LO "https://dl.k8s.io/release/${KOOLBOX_KUBECTL_VERSION}/bin/linux/amd64/kubectl"
fi
koolbox_install_file_version kubectl ${KOOLBOX_KUBECTL_VERSION}

# install completions
if ! KOOLBOX_BUILD_INTERACTIVE; then
    echo skipping kubectl bash completions
elif ${koolbox_install_as_root}; then
    $KOOLBOX_INSTALL_DIR/kubectl completion bash | $KOOLBOX_SUDO_CMD tee /etc/bash_completion.d/kubectl > /dev/null
    $KOOLBOX_SUDO_CMD chmod a+r /etc/bash_completion.d/kubectl
else
    $KOOLBOX_INSTALL_DIR/kubectl completion bash >$(koolbox_install_completions_dir)/kubectl
fi

# Old Ubuntu way
#export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
#apt-get update
#apt-get -y install --no-install-recommends kubectl
#rm -rf /var/lib/apt/lists/*
