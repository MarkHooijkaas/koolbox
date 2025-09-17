#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc

export KREW_ROOT=${KOOLBOX_INSTALL_OPT_DIR}/krew

tool_name=krew
download_result_path=${KREW_ROOT}/bin/kubectl-krew
install_result_path=${KREW_ROOT}/bin/kubectl-krew

function download_krew() {
    local os="$(uname | tr '[:upper:]' '[:lower:]')"
    local arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    download_file="krew-${os}_${arch}"

    koolbox_verbose downloading ${download_file}
    mkdir -p ${KREW_ROOT}
    cd ${KREW_ROOT}
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${download_file}.tar.gz" || true

    koolbox_verbose extracting ${download_file}
    # tar gives errors, because it has some MacOS specific values
    tar zxf "${download_file}.tar.gz" 2>/dev/null || true

}

function install_krew() {
    append_to_file ${KOOLBOX_INSTALL_PROFILE_FILE} "export KREW_ROOT=$KREW_ROOT"
    append_to_file ${KOOLBOX_INSTALL_PROFILE_FILE} "PATH=\$PATH:$KREW_ROOT/bin"
    source ${KOOLBOX_INSTALL_PROFILE_FILE}

    if [[ -f ${download_file-} ]]; then
        cmd=./${download_file}
    else
        cmd=$install_result_path
    fi
    koolbox_verbose running ${cmd} install krew
    ${cmd} install krew

    koolbox_verbose cleaning up remaining files
    rm -f ${KREW_ROOT}/.??* ${KREW_ROOT}/krew-*
}

main_install "${@}"
