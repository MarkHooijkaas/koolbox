#!/usr/bin/bash

# pip3 install awscli --break-system-packages
#apt-get -y install --no-install-recommends awscli

if [[ -z ${KOOLBOX_INSTALL_AWS_CLI_VERSION:-} ]]; then
    # latest
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_${KOOLBOX_INSTALL_AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
fi

unzip -q awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
