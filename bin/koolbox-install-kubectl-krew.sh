#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc



set -x
tmpdir="$(mktemp -d)"
cd $tmpdir
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
KREW="krew-${OS}_${ARCH}"
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" || true

# tar gives errors, because it has some MacOS specific values
tar zxvf "${KREW}.tar.gz" || true
chmod 755 ${KREW}
./${KREW} install krew

if ${KOOLBOX_INSTALL_AS_ROOT}; then
    export KREW_ROOT=/var/opt/krew
    $KOOLBOX_SUDO_CMD ./"${KREW}" install krew
else
    export KREW_ROOT=~/.local/krew
    ./"${KREW}" install krew
fi

# install completions
#if ${KOOLBOX_INSTALL_AS_ROOT}; then
#    #$KOOLBOX_INSTALL_BIN_DIR/kubectl completion bash | $KOOLBOX_SUDO_CMD tee /etc/bash_completion.d/kubectl > /dev/null
#    $KOOLBOX_SUDO_CMD ./"${KREW}" install krew
#else
#    ./"${KREW}" install krew
#fi
