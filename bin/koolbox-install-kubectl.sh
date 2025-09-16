#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"


tool_name=kubectl
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/kubectl

function init_install_kubectl() {
    : ${KOOLBOX_INSTALL_KUBECTL_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    if [[ -z ${KOOLBOX_INSTALL_KUBECTL_VERSION} ]]; then
        KOOLBOX_INSTALL_KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    fi
    download_result_path=$KOOLBOX_INSTALL_OPT_DIR/kubectl/$KOOLBOX_INSTALL_KUBECTL_VERSION/bin/kubectl
}

function download_kubectl() {
    koolbox_info downloading ${download_result_path}
    mkdir -p $KOOLBOX_INSTALL_OPT_DIR/kubectl/$KOOLBOX_INSTALL_KUBECTL_VERSION/bin/
    curl -L -o ${download_result_path}  "https://dl.k8s.io/release/${KOOLBOX_INSTALL_KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod 755 ${download_result_path}
}

function install_kubectl() {
    install_with_link
}

function install_kubectl_completions() {
    ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-kubectl
}




main_install "${@}"
