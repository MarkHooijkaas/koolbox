#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"

tool_name=helm
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/helm

init_install_helm() {
    : ${KOOLBOX_INSTALL_HELM_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    if [[ -z ${KOOLBOX_INSTALL_HELM_VERSION} ]]; then
        echo helm version not specified using -V option or KOOLBOX_INSTALL_HELM_VERSION var
        exit 1
    fi
    tool_version=${KOOLBOX_INSTALL_HELM_VERSION}
    download_filename=helm-${tool_version}-${OS}-${ARCH}.tar.gz
    download_url=https://get.helm.sh/${download_filename}
    init_download_dir
    download_result_path=${download_dir}/${tool_name}
}

download_helm() {
    dry-run curl --silent -O $download_url
    dry-run tar xfz  $download_filename
    dry-run rm $download_filename
    dry-run mv ${OS}-${ARCH}/* .
    dry-run rmdir ${OS}-${ARCH}
}

install_helm() {
    install_with_link
}

install_helm_completions() {
    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/helm
}

main_install "${@}"
