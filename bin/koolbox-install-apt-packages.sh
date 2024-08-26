#!/usr/bin/bash


KOOLBOX_APT_PACKAGES=""
koolbox_add_package() {
    if ${2:-true} ; then
        KOOLBOX_APT_PACKAGES="${KOOLBOX_APT_PACKAGES} $1"
    fi
}

koolbox_add_package apt-transport-https
koolbox_add_package bash-completion
koolbox_add_package ca-certificates
koolbox_add_package curl
koolbox_add_package git
koolbox_add_package gnupg
koolbox_add_package iputils-ping
koolbox_add_package iproute2
koolbox_add_package htop
koolbox_add_package jed
koolbox_add_package jq
koolbox_add_package less
koolbox_add_package nano
koolbox_add_package netcat-openbsd
koolbox_add_package net-tools
koolbox_add_package openssh-client
koolbox_add_package python3
koolbox_add_package python3-pip
koolbox_add_package rsync
koolbox_add_package telnet
koolbox_add_package tcptraceroute
koolbox_add_package traceroute
koolbox_add_package unzip
koolbox_add_package vim
koolbox_add_package wget
koolbox_add_package zip


export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y apt-utils
apt-get update
apt-get -y install --no-install-recommends ${KOOLBOX_APT_PACKAGES}
apt-get clean
# rm -rf /var/lib/apt/lists/*

# The next command gets things like manpages, but this add 200M to the image, and usually --help is just fine
# RUN yes | unminimize
