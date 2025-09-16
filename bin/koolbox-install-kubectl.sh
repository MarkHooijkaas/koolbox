#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"

if [[ -z ${KOOLBOX_INSTALL_KUBECTL_VERSION:-} ]]; then
    KOOLBOX_INSTALL_KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
fi

install_file=$KOOLBOX_INSTALL_OPT_DIR/kubectl/$KOOLBOX_INSTALL_KUBECTL_VERSION/bin/kubectl
bin_file=$KOOLBOX_INSTALL_BIN_DIR/kubectl

if [[ -f $install_file ]]; then
    koolbox_info Existing file $install_file, not downloading again
else
    koolbox_info downloading $install_file
    mkdir -p $KOOLBOX_INSTALL_OPT_DIR/kubectl/$KOOLBOX_INSTALL_KUBECTL_VERSION/bin/
    curl -L -o $install_file  "https://dl.k8s.io/release/${KOOLBOX_INSTALL_KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod 755 $install_file
fi

if [[ -f $bin_file ]]; then
    koolbox_info already a version of kubectl installed $bin_file
    if $KOOLBOX_VERBOSE; then
        ls -l $bin_file
    fi
else
    koolbox_info linking $install_file $bin_file
    ln -s $install_file $bin_file
fi

if ${KOOLBOX_INSTALL_COMPLETIONS:-true}; then
    koolbox_info installing bash completions in ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-kubectl
    $install_file completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-kubectl
fi
