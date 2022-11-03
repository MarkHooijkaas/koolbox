#!/usr/bin/bash

KOOLBOX_BUILD_CMD=less
: ${KOOLBOX_LAYERS:=true}

koolbox_main() {
    koolbox_parse_options "$@"
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
    KOOLBOX_IMAGE_CMDS="RUN  groupadd --gid 1000 toolbox &&  useradd --system --create-home --home-dir /home/toolbox --shell /bin/bash --uid 1000 --gid 1000 toolbox"
    #KOOLBOX_IMAGE_CMDS="RUN mkdir -p ${KOOLBOX_HOME}"
    add_command() {
        if ${KOOLBOX_LAYERS:-true} ; then
            KOOLBOX_IMAGE_CMDS="${KOOLBOX_IMAGE_CMDS}
RUN $1"
        else
            KOOLBOX_IMAGE_CMDS="${KOOLBOX_IMAGE_CMDS} && \\
    $1"
        fi
    }

    add_command ${KOOLBOX_HOME}/bin/koolbox-install-apt-packages.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-kubectl.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-kustomize.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-rancher-cli.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-aws-cli.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-helm.sh
    add_command ${KOOLBOX_HOME}/bin/koolbox-install-yq.sh
}

koolbox_create_dockerfile() {
    cat <<EOF | $KOOLBOX_BUILD_CMD
# syntax = docker/dockerfile:1.2
#########################################################
FROM ubuntu:20.04

RUN mkdir ${KOOLBOX_HOME}/
COPY . ${KOOLBOX_HOME}/
RUN ls -la ${KOOLBOX_HOME}/*


$KOOLBOX_IMAGE_CMDS

# This should be at end, when root is not needed anymore
USER 1000
WORKDIR /home/toolbox

ENTRYPOINT ["/bin/bash"]
EOF
}

koolbox_main "${@}"
