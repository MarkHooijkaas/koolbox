#!/usr/bin/bash

echo installing apt packages '['$KOOLBOX_APT_PACKAGES']'

export DEBIAN_FRONTEND=noninteractive
#apt-get update
#apt-get install -y apt-utils
apt-get update
apt-get -y install --no-install-recommends ${KOOLBOX_APT_PACKAGES}
apt-get clean

# The next command gets things like manpages, but this add 200M to the image, and usually --help is just fine
# RUN yes | unminimize
