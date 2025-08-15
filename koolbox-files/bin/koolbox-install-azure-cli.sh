#!/usr/bin/bash

script=/tmp/install-azure-cli.bash

curl -L https://aka.ms/InstallAzureCli >$script

sed -i 's/< $_TTY//' $script
bash $script
rm $script
