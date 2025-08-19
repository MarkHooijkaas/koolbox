#!/usr/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc

# Installs azure-cli using apt
# After this operation, 630 MB of additional disk space will be used.
# It seems to install a entire own python including full test suite etc
# See open ticket from 2018 https://github.com/Azure/azure-cli/issues/7387
#

# Based on https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt

${KOOLBOX_SUDO_CMD} apt-get install --yes apt-transport-https ca-certificates curl gnupg lsb-release
${KOOLBOX_SUDO_CMD} mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor | ${KOOLBOX_SUDO_CMD} tee /etc/apt/keyrings/microsoft.gpg > /dev/null
${KOOLBOX_SUDO_CMD} chmod go+r /etc/apt/keyrings/microsoft.gpg


AZ_DIST=bookworm #$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | ${KOOLBOX_SUDO_CMD} tee /etc/apt/sources.list.d/azure-cli.sources

${KOOLBOX_SUDO_CMD} apt-get update
${KOOLBOX_SUDO_CMD} apt-get install azure-cli
${KOOLBOX_SUDO_CMD} apt-get clean
