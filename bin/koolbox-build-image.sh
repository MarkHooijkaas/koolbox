#!/usr/bin/bash

: ${KOOLBOX_LAYERS:=true}
: ${KOOLBOX_BUILD_CMD:=less}

koolbox_main() {
    koolbox_parse_options "$@"
    koolbox_parse_defaults
    koolbox_add_commands
    koolbox_create_dockerfile
}

koolbox_parse_options() {
    while [ ! $# -eq 0 ]; do
        case $1 in
            -h|--help)
                koolbox_help
                exit 0
                ;;
            -i|--image)
                export DOCKER_BUILDKIT=1 docker build .  \
                KOOLBOX_BUILD_CMD='docker build . --progress=plain -f - --tag koolbox:latest'
                ;;
            -v|--view)
                KOOLBOX_BUILD_CMD='less'
                ;;
            -l|--lean)
                KOOLBOX_LAYERS=false
                ;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
}

koolbox_parse_defaults() {
    : ${KOOLBOX_BASE_IMAGE:=ubuntu:22.04}
    : ${KOOLBOX_USER_NAME:=kooluser}
    : ${KOOLBOX_USER_UID:=1000}
    : ${KOOLBOX_USER_GROUP:=${KOOLBOX_USER_NAME}}
    : ${KOOLBOX_USER_GID:=1000}
    : ${KOOLBOX_USER_HOME:=/home/${KOOLBOX_USER_NAME}}
    : ${KOOLBOX_HOME:=/opt/koolbox}
}

#####################################################################

koolbox_help() {
    cat << EOF
Usage: ${0##*/} [options]

The purpose of kreate is calling kreate.sh to create files
and then optionally execute a command like git or kustomize
Options can be:
    -h|--help      display this help and exit
    -i|--image     build the docker image
    -v|--view      view the Dockerfile without building it (default)
    -l|--lean      remove as much layers as possible
EOF
}

koolbox_add_commands() {
    # Add a toolbox user, to not run as root

    KOOLBOX_PRE_CMDS="groupadd --gid ${KOOLBOX_USER_GID} ${KOOLBOX_USER_GROUP};useradd --system --create-home --home-dir ${KOOLBOX_USER_HOME} --shell /bin/bash --uid ${KOOLBOX_USER_UID} --gid ${KOOLBOX_USER_GID} ${KOOLBOX_USER_NAME}"

    KOOLBOX_CMDS="RUN true"
    add_command() {
        if ${KOOLBOX_LAYERS:-true} ; then
            KOOLBOX_CMDS="${KOOLBOX_CMDS}
RUN $1"
        else
            KOOLBOX_CMDS="${KOOLBOX_CMDS} && \\
    $1"
        fi
    }

    IFS=';' read -ra CMDS <<< "$KOOLBOX_PRE_CMDS"
    for cmd in "${CMDS[@]}"; do
        add_command "$cmd"
    done


    add_command ${KOOLBOX_HOME}/bin/koolbox-install-apt-packages.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-kubectl.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-kustomize.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-rancher-cli.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-aws-cli.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-helm.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-yq.sh

    KOOLBOX_POST_CMDS="pip install kreate-kube"

    IFS=';' read -ra CMDS <<< "$KOOLBOX_POST_CMDS"
    for cmd in "${CMDS[@]}"; do
        add_command "$cmd"
    done

}


koolbox_create_dockerfile() {
    : ${KOOLBOX_BASE_IMAGE:=ubuntu:22.04}
    : ${KOOLBOX_USER_NAME:=kooluser}
    : ${KOOLBOX_USER_UID:=1000}
    : ${KOOLBOX_USER_GROUP:=${KOOLBOX_USER_NAME}}
    : ${KOOLBOX_USER_GID:=1000}
    : ${KOOLBOX_USER_HOME:=/home/${KOOLBOX_USER_NAME}}
    cat <<EOF | $KOOLBOX_BUILD_CMD
# syntax = docker/dockerfile:1.2
#########################################################
FROM ${KOOLBOX_BASE_IMAGE}

RUN mkdir -p ${KOOLBOX_HOME}/bin
COPY bin ${KOOLBOX_HOME}/bin
RUN ls -la ${KOOLBOX_HOME}/*

$KOOLBOX_CMDS

# This should be at end, when root is not needed anymore
USER ${KOOLBOX_USER_UID}
WORKDIR ${KOOLBOX_USER_HOME}

ENTRYPOINT ["/bin/bash"]
EOF
}

koolbox_main "${@}"
