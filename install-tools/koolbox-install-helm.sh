#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"

tool_name=helm
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/helm

function init_install_helm() {
    : ${KOOLBOX_INSTALL_HELM_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    if [[ -z ${KOOLBOX_INSTALL_HELM_VERSION} ]]; then
        echo helm version not specified using -V option or KOOLBOX_INSTALL_HELM_VERSION var
        exit 1
    fi
    helm_dir=$KOOLBOX_INSTALL_OPT_DIR/helm/${KOOLBOX_INSTALL_HELM_VERSION}
    download_result_path=$helm_dir/linux-amd64/helm
}

function download_helm() {
    mkdir -p ${helm_dir}/bin/
    wget -qO- "https://get.helm.sh/helm-${KOOLBOX_INSTALL_HELM_VERSION}-linux-amd64.tar.gz" | tar xvz -C $helm_dir
}

function install_helm() {
    install_with_link
}

function install_helm_completions() {
    ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/helm
}

main_install "${@}"
