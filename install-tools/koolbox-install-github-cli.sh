#!/usr/bin/bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
koolbox_parse_options "${@}"


tool_name=github-cli
install_result_path=$KOOLBOX_INSTALL_BIN_DIR/gh

function init_install_github-cli() {
    : ${KOOLBOX_INSTALL_GITHUB_CLI_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    tool_version=${KOOLBOX_INSTALL_GITHUB_CLI_VERSION}
    download_filename=gh_${tool_version}_${OS_ARCH}.tar.gz
    # note: the dir version has a v, but the file version does not
    # https://github.com/cli/cli/releases/download/v2.79.0/gh_2.79.0_linux_amd64.tar.gz
    download_url=https://github.com/cli/cli/releases/download/v${tool_version}/${download_filename}
    init_download_dir
    download_result_path=${download_dir}/gh
}

function download_github-cli() {
    dry-run curl -L -O ${download_url}
    dry-run tar xfz ${download_filename}
    dirname=gh_${tool_version}_${OS_ARCH}

    dry-run mv $dirname/bin/gh .
    # TODO: install man pages somewhere
    dry-run rm -rf $dirname
    dry-run rm $download_filename
}

function install_github-cli() {
    install_with_link
}

function install_github-cli_completions() {
    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-github_cli
}

main_install "${@}"
