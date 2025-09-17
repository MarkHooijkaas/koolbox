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
    tool_version=${KOOLBOX_INSTALL_KUBECTL_VERSION}
    download_filename=vault_${tool_version}_${OS_ARCH}.zip
    download_url="https://dl.k8s.io/release/${KOOLBOX_INSTALL_KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl"
    init_download_dir
    download_result_path=${download_dir}/kubectl
}

function download_kubectl() {
    dry-run curl -L -o ${download_result_path} "https://dl.k8s.io/release/${KOOLBOX_INSTALL_KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl"
    dry-run chmod 755 ${download_result_path}
}

function install_kubectl() {
    install_with_link
}

function install_kubectl_completions() {
    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-kubectl
}

main_install "${@}"
