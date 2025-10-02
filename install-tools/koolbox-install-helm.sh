#!/usr/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc

tool_name=helm

init_vars() {
    calc_transformed_os_arch
    download_filename=helm-${tool_version}-${OS}-${ARCH}.tar.gz
    download_url=https://get.helm.sh/${download_filename}
    skip_tar_topdir=true
}

install_extras() {
    dry-run ${download_result_path} completion bash >${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/helm
}

run_all "${@}"
