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
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=/etc/bash_completions.d}
else
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=${XDG_CONFIG_HOME}/koolbox}
    : ${KOOLBOX_INSTALL_OPT_DIR:=~/opt}
    : ${KOOLBOX_INSTALL_BIN_DIR:=~/.local/bin}
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=${XDG_DATA_HOME}/bash-completion/completions}
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
    -x            bash set -x for further debugging
EOF
}

#####################################################################

function main_install() {
    koolbox_parse_options "${@}"
    if already_installed; then
        koolbox_info ${package_name} already installed
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_info force installing package anyway
            install_${package_name}
        fi
    else
        koolbox_info installing ${package_name}
        install_${package_name}
    fi
}

function already_installed() {
    if [[ -f ${package_file} ]]; then
        return 0
    else
        return 1
    fi
}
