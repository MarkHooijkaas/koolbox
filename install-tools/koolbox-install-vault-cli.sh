#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc

# see https://developer.hashicorp.com/vault/install for download links
#
# see https://developer.hashicorp.com/well-architected-framework/verify-hashicorp-binary for signing


tool_name=vault
install_result_path=${KOOLBOX_INSTALL_BIN_DIR}/vault

init_install_vault() {
    : ${KOOLBOX_INSTALL_VAULT_VERSION:=${KOOLBOX_TOOL_VERSION:-}}
    if [[ -z ${KOOLBOX_INSTALL_VAULT_VERSION} ]]; then
        echo vault-cli version not specified using -V option or KOOLBOX_INSTALL_VAULT_VERSION var
        exit 1
    fi
    tool_version=${KOOLBOX_INSTALL_VAULT_VERSION}
    download_filename=vault_${KOOLBOX_INSTALL_VAULT_VERSION}_${OS_ARCH}.zip
    download_url=https://releases.hashicorp.com/vault/${KOOLBOX_INSTALL_VAULT_VERSION}/${download_filename}
    init_download_dir
    download_result_path=${download_dir}/vault
}

download_vault() {
    koolbox_verbose downloading ${download_filename}
    dry-run curl -fsSLO ${download_url} || true

    koolbox_verbose extracting ${download_filename}
    dry-run unzip "${download_filename}"
    dry-run rm "${download_filename}"
}

install_vault() {
    install_with_link
    #append_to_file ${KOOLBOX_INSTALL_PROFILE_FILE} "export vault_ROOT=$vault_ROOT"
    #append_to_file ${KOOLBOX_INSTALL_PROFILE_FILE} "PATH=\$PATH:$vault_ROOT/bin"
    #source ${KOOLBOX_INSTALL_PROFILE_FILE}
}

main_install "${@}"
