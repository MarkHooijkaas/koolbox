#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"


tool_name=mark
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/mark

function init_install_mark() {
    : ${KOOLBOX_INSTALL_MARK_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    tool_version=${KOOLBOX_INSTALL_MARK_VERSION}
    OS_ARCH=Linux_x86_64 # TODO work for other architectures
    download_filename=${tool_name}_${OS_ARCH}.tar.gz
    # see https://github.com/kovetskiy/mark?tab=readme-ov-file#releases
    # https://github.com/kovetskiy/mark/releases/download/v15.0.0/mark_Linux_x86_64.tar.gz
    download_url=https://github.com/kovetskiy/mark/releases/download/v${tool_version}/${download_filename}
    init_download_dir
    download_result_path=${download_dir}/${tool_name}
}

function download_mark() {
    dry-run curl -L -O ${download_url}
    dry-run tar xfz ${download_filename}
    dry-run rm $download_filename
}

function install_mark() {
    install_with_link
}

#function install_mark_completions() {
#    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-github_cli
#}

main_install "${@}"
