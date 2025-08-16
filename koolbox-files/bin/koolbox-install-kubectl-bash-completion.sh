#!/usr/bin/env bash

# install completions
elif ${koolbox_install_asoot}; then
    $KOOLBOX_INSTALL_BIN_DIR/kubectl completion bash | $KOOLBOX_SUDO_CMD tee /etc/bash_completion.d/kubectl > /dev/null
    $KOOLBOX_SUDO_CMD chmod a+r /etc/bash_completion.d/kubectl
else
    $KOOLBOX_INSTALL_BIN_DIR/kubectl completion bash >$(koolbox_install_completions_dir)/kubectl
fi
