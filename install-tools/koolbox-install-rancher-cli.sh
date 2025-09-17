#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"

tool_name=rancher
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/rancher

function init_install_rancher() {
    : ${KOOLBOX_INSTALL_RANCHER_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    if [[ -z ${KOOLBOX_INSTALL_RANCHER_VERSION} ]]; then
        echo rancher version not specified using -V option or KOOLBOX_INSTALL_RANCHER_VERSION var
        exit 1
    fi
    tool_version=${KOOLBOX_INSTALL_RANCHER_VERSION}
    download_filename=rancher-${OS}-${ARCH}-${tool_version}.tar.gz
    download_url=https://github.com/rancher/cli/releases/download/${tool_version}/${download_filename}
    #https://github.com/rancher/cli/releases/download/v2.12.1/rancher-linux-amd64-v2.12.1.tar.gz

    init_download_dir
    download_result_path=${download_dir}/${tool_name}
}

function download_rancher() {
    dry-run curl -L --silent -O $download_url
    dry-run tar xfz  $download_filename
    dry-run rm $download_filename
    dry-run mv rancher-${tool_version}/* .
    dry-run rmdir rancher-${tool_version}
}

function install_rancher() {
    install_with_link
}

function install_rancher_completions() {
    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/rancher
}

main_install "${@}"
