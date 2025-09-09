#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc

# install completions
if ${KOOLBOX_INSTALL_AS_ROOT}; then
    $KOOLBOX_INSTALL_BIN_DIR/kubectl completion bash | $KOOLBOX_SUDO_CMD tee /etc/bash_completion.d/kubectl > /dev/null
    $KOOLBOX_SUDO_CMD chmod a+r /etc/bash_completion.d/kubectl
else
    $KOOLBOX_INSTALL_BIN_DIR/kubectl completion bash >$(koolbox_install_completions_dir)/kubectl
fi
