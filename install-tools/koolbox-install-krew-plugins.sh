#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]}")/koolbox-init.inc

export KREW_ROOT=${KREW_ROOT:-${KOOLBOX_INSTALL_OPT_DIR}/krew}

if [[ -f $KOOLBOX_INSTALL_PROFILE_FILE ]]; then
    source $KOOLBOX_INSTALL_PROFILE_FILE
fi

if [[ ! -f ${KREW_ROOT}/bin/kubectl-krew ]]; then
    echo KREW_ROOT not set correctly or krew not installed
    exit 1
fi

if [[ -z ${KOOLBOX_INSTALL_KREW_PLUGINS:-} ]]; then
    echo no plugins specified in KOOLBOX_INSTALL_KREW_PLUGINS
    exit 1
else
    kubectl krew install ${KOOLBOX_INSTALL_KREW_PLUGINS}
fi
