#!/usr/bin/bash

# pip3 install awscli --break-system-packages
#apt-get -y install --no-install-recommends awscli

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.17.37.zip" -o "awscliv2.zip"
# latest
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip
ls -la *.zip aws
./aws/install
rm -rf awscliv2.zip aws
