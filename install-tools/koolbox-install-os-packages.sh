#!/usr/bin/env bash

if type dnf 2>/dev/null; then
    if [[ -z ${KOOLBOX_INSTALL_DNF_PACKAGES:-} ]]; then
        echo "No dnf package to install"
        exit 0
    fi
    echo installing dnf packages '['$KOOLBOX_INSTALL_DNF_PACKAGES']'
    dnf install -y $KOOLBOX_INSTALL_DNF_PACKAGES
    #rm -rf /var/cache/dnf
    dnf clean all
elif type microdnf 2>/dev/null; then
    if [[ -z ${KOOLBOX_INSTALL_DNF_PACKAGES:-} ]]; then
        echo "No dnf package to install"
        exit 0
    fi
    echo installing microdnf packages '['$KOOLBOX_INSTALL_DNF_PACKAGES']'
    microdnf install -y $KOOLBOX_INSTALL_DNF_PACKAGES
    microdnf clean all
else
    if [[ -z ${KOOLBOX_INSTALL_APT_PACKAGES:-} ]]; then
        echo "No apt package to install"
        exit 0
    fi
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
