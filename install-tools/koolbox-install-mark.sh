#!/usr/bin/bash
#set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc
#koolbox_parse_options "${@}"

tool_name=mark


function init_install_mark() {
    # see https://github.com/kovetskiy/mark?tab=readme-ov-file#releases
    # example url https://github.com/kovetskiy/mark/releases/download/v15.0.0/mark_Linux_x86_64.tar.gz
    OS_ARCH=$(uname)_$(uname -m)
    download_filename=${tool_name}_${OS_ARCH}.tar.gz
    download_url=https://github.com/kovetskiy/mark/releases/download/v${tool_version}/${download_filename}
    download_result_path=${download_dir}/${tool_name}
}

#function install_mark_completions() {
#    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-github_cli
#}

run_install "${@}"
