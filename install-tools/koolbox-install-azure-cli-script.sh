#!/usr/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/koolbox-init-install.inc


# Based on https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=script
# but needs fixing, and does not work yet
script=/tmp/install-azure-cli.bash
curl -L https://aka.ms/InstallAzureCli >$script
sed -i 's/< $_TTY//' $script
bash $script
rm $script
