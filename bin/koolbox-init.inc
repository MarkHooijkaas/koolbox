# This file is meant to be sourced by the koolbox-install scripts
set -ue

: ${KOOLBOX_ROOT_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"}

: ${XDG_DATA_HOME:=~/.local/share}
: ${XDG_STATE_HOME:=~/.local/state}
: ${XDG_CONFIG_HOME:=~/.config}


if [[ $(id -u) == 0 ]] ;then
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=/etc/koolbox}
    : ${KOOLBOX_INSTALL_OPT_DIR:=/opt}
    : ${KOOLBOX_INSTALL_BIN_DIR:=/usr/local/bin}
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=/etc/bash_completion.d}
    : ${KOOLBOX_INSTALL_PROFILE_FILE:=/etc/profile}
else
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=${XDG_CONFIG_HOME}/koolbox}
    : ${KOOLBOX_INSTALL_OPT_DIR:=~/opt}
    : ${KOOLBOX_INSTALL_BIN_DIR:=~/.local/bin}
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=${XDG_DATA_HOME}/bash-completion/completions}
    : ${KOOLBOX_INSTALL_PROFILE_FILE:=~/.profile}
fi

function koolbox_use_apt() {
    type -t apt >/dev/null
}
function koolbox_use_dnf() {
    type -t dnf >/dev/null
}


: ${KOOLBOX_VERBOSE:=false}
: ${KOOLBOX_INFO:=true}

function koolbox_verbose() {
    if ${KOOLBOX_VERBOSE:-true}; then
        echo "${@}"
    fi
}

function koolbox_info() {
    if ${KOOLBOX_INFO:-true}; then
        echo "${@}"
    fi
}

#####################################################################

function koolbox_parse_options() {
    while [ ! $# -eq 0 ]; do
        case $1 in
            -h|--help)    koolbox_help; exit 0;;
            -v|--verbose) KOOLBOX_VERBOSE=true; KOOLBOX_INFO=true;;
            -q|--quiet)   KOOLBOX_VERBOSE=false; KOOLBOX_INFO=false;;
            -f|--force)   KOOLBOX_INSTALL_FORCE=true;;
            -F|--force-all)  KOOLBOX_INSTALL_FORCE_DOWNLOAD=true; KOOLBOX_INSTALL_FORCE=true;;
            -V|--version)  KOOLBOX_TOOL_VERSION=$2; shift;;
            -x)           set -x;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
}

koolbox_help() {
    cat << EOF
Usage: ${0##*/} [options]

Options can be:
    -h|--help     display this help and exit
    -v|--verbose  show extra information during installation
    -q|--quiet    don't show any information
    -f|--force    force re-install (but not re download)
    -F|--force-all force re-download and re-install
    -V|--version  install a specific version
    -x            bash set -x for further debugging
EOF
}

#####################################################################
function init_download_dir() {
    download_dir=${KOOLBOX_INSTALL_OPT_DIR}/${tool_name}/${tool_version:-latest}
    mkdir -p ${download_dir}
    cd ${download_dir}
}

function main_install() {
    koolbox_parse_options "${@}"

    local os="$(uname | tr '[:upper:]' '[:lower:]')"
    local arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    OS_ARCH=${os}_${arch}

    if [[ $(type -t init_install_${tool_name}) == function ]]; then
        init_install_${tool_name}
    fi

    if already_downloaded; then
        koolbox_info ${tool_name} already dowloaded
        if ${KOOLBOX_INSTALL_FORCE_DOWNLOAD:-false}; then
            koolbox_info force downloading ${download_result_path} anyway
            download_${tool_name}
        fi
    else
        koolbox_info downloading ${download_result_path}
        download_${tool_name}
    fi

    if already_installed; then
        koolbox_info ${tool_name} already installed
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_info force installing ${install_result_path} anyway
            install_${tool_name}
        fi
    else
        koolbox_info installing ${tool_name}
        install_${tool_name}
    fi

    if ${KOOLBOX_INSTALL_COMPLETIONS:-true}; then
        if [[ $(type -t install_${tool_name}_completions) == function ]]; then
            koolbox_info installing bash completions for ${tool_name}
            install_${tool_name}_completions
        fi
    fi
}

function already_downloaded() {
    if [[ -f ${download_result_path} ]]; then
        return 0
    else
        return 1
    fi
}

function already_installed() {
    if [[ -f ${install_result_path} ]]; then
        return 0
    else
        return 1
    fi
}

function install_with_link() {
    if [[ -f ${install_result_path} ]]; then
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_verbose force linking  ${install_result_path} to ${download_result_path}
            ln -sf ${download_result_path} ${install_result_path}
        else
            koolbox_info already a version of ${tool_name} installed ${install_result_path}
            if $KOOLBOX_VERBOSE; then
                ls -l ${install_result_path}
            fi
        fi
    else
        koolbox_verbose linking  ${install_result_path} to ${download_result_path}
        ln -s ${download_result_path} ${install_result_path}
    fi
}


function append_to_file() {
    local file=$1
    shift
    local cmd="${@}"
    if [[ -f $file ]]; then
        pattern="^${cmd/\$/\\\$}$"
        #echo $pattern
        found=$(grep -E "^$pattern" $file) || true
        if [ -z "$found" ] ; then
            koolbox_info modifying $file by appending command: $cmd
            echo $cmd >>$file
        else
            koolbox_info $file already includes $cmd
        fi
    else
        koolbox_info creating new $file with command: $cmd
        echo $cmd >>$file
    fi
}
