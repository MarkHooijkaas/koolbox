# This file is meant to be sourced by the koolbox-install scripts
set -ue

#KOOLBOX_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

if [[ $(id -u) == 0 ]] ;then
    KOOLBOX_SUDO_CMD=""
    KOOLBOX_INSTALL_AS_ROOT=true
else
    KOOLBOX_SUDO_CMD="sudo"
fi

: ${KOOLBOX_INSTALL_AS_ROOT:=false}
if $KOOLBOX_INSTALL_AS_ROOT; then
    : ${KOOLBOX_INSTALL_BIN_DIR:=/usr/local/bin}
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=/etc/koolbox}
else
    : ${XDG_DATA_HOME:=~/.local/share/}
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=~/.config/koolbox}
    : ${KOOLBOX_INSTALL_BIN_DIR:=~/.local/bin}
fi


function koolbox_install_file_version() {
    file=$1
    version=$2
    if ${KOOLBOX_INSTALL_AS_ROOT}; then
        $KOOLBOX_SUDO_CMD install -o root -g root -m 0755 $file ${KOOLBOX_INSTALL_BIN_DIR}/$file-$version
        $KOOLBOX_SUDO_CMD ln -s ${KOOLBOX_INSTALL_BIN_DIR}/$file-$version ${KOOLBOX_INSTALL_BIN_DIR}/$file
    else
        #mkdir -p ${KOOLBOX_INSTALL_BIN_DIR}
        install -m 0755 $file ${KOOLBOX_INSTALL_BIN_DIR}/$file-$version
        ln -sf ${KOOLBOX_INSTALL_BIN_DIR}/$file-$version ${KOOLBOX_INSTALL_BIN_DIR}/$file
    fi
}

function koolbox_install_completions_dir() {
    if ${KOOLBOX_INSTALL_AS_ROOT}; then
        echo /etc/bash_completion.d
    else
        mkdir -p ${XDG_DATA_HOME}/bash-completion/completions
        echo ${XDG_DATA_HOME}/bash-completion/completions
    fi
}
