# This file is meant to be sourced by the koolbox-install scripts
set -ue

KOOLBOX_HOME_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

: ${XDG_DATA_HOME:=~/.local/share/}
: ${KOOLBOX_CONFIG_DIR:=~/.config/koolbox}

: ${koolbox_install_as_root:=false}

#if [[ -f $KOOLBOX_CONFIG_DIR/config ]]; then
#    source $KOOLBOX_CONFIG_DIR/koolbox.config
#else
#    source $KOOLBOX_HOME_DIR/koolbox.config
#fi

: ${KOOLBOX_INSTALL_DIR:=~/.local/bin}
: ${koolbox_install_as_root:=false}

function koolbox_install_file_version() {
    file=$1
    version=$2
    if ${koolbox_install_as_root}; then
        sudo install -o root -g root -m 0755 $file ${KOOLBOX_INSTALL_DIR}/$file-$version
        sudo ln -s ${KOOLBOX_INSTALL_DIR}/$file-$version ${KOOLBOX_INSTALL_DIR}/$file
    else
        mkdir -p ${KOOLBOX_INSTALL_DIR}
        install -m 0755 $file ${KOOLBOX_INSTALL_DIR}/$file-$version
        ln -sf ${KOOLBOX_INSTALL_DIR}/$file-$version ${KOOLBOX_INSTALL_DIR}/$file
    fi
}

function koolbox_install_completions_dir() {
    if ${koolbox_install_as_root}; then
        echo /etc/bash_completion.d
    else
        mkdir -p ${XDG_DATA_HOME}/bash-completion/completions
        echo ${XDG_DATA_HOME}/bash-completion/completions
    fi
}
