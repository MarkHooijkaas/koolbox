#!/usr/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc


# Based on https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=script
${KOOLBOX_SUDO_CMD} rpm --import https://packages.microsoft.com/keys/microsoft.asc
${KOOLBOX_SUDO_CMD} dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
${KOOLBOX_SUDO_CMD} dnf install -y azure-cli
