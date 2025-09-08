#!/usr/bin/env bash

if type dnf ; then
    echo installing dnf packages '['$KOOLBOX_INSTALL_DNF_PACKAGES']'
    dnf --yes install $KOOLBOX_INSTALL_DNF_PACKAGES
else
    echo installing apt packages '['$KOOLBOX_INSTALL_APT_PACKAGES']'

    export DEBIAN_FRONTEND=noninteractive
    #apt-get update
    #apt-get install -y apt-utils
    apt-get update
    apt-get -y install --no-install-recommends ${KOOLBOX_INSTALL_APT_PACKAGES}
    apt-get clean

    # The next command gets things like manpages, but this add 200M to the image, and usually --help is just fine
    # RUN yes | unminimize
fi
