#!/usr/bin/bash

: ${KOOLBOX_LAYERS:=true}
: ${KOOLBOX_BUILD_CMD:=less}
: ${KOOLBOX_BUILD_INTERACTIVE:=true}
: ${KOOLBOX_FILE:=config/all.kool}

koolbox_main() {
    koolbox_parse_options "$@"
    source $KOOLBOX_FILE
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
            -b|--build)
                KOOLBOX_BUILD_CMD=koolbox_build_from_stdin
                ;;
            -v|--view)
                KOOLBOX_BUILD_CMD='less'
                ;;
            -l|--lean)
                KOOLBOX_LAYERS=false
                ;;
            -n|--no-cache)
                KOOLBOX_BUILD_USE_CACHE="--no-cache"
                ;;
            -i|--interactive)
                KOOLBOX_BUILD_INTERACTIVE=true
                ;;
            -s|--script)
                KOOLBOX_BUILD_INTERACTIVE=false
                ;;
            -f|--file)
                shift
                KOOLBOX_FILE=$1
                ;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
}

koolbox_build_from_stdin() {
    : ${KOOLBOX_IMAGE_NAME:=koolbox}
    if [[ -z ${KOOLBOX_BUILD_TAGS} ]]; then
        KOOLBOX_BUILD_TAGS="--tag orgkisst/$KOOLBOX_IMAGE_NAME:latest"
    fi
    cat <<EOF
*** Building image $KOOLBOX_IMAGE_NAME
***    apt install: $KOOLBOX_APT_PACKAGES
***    install-scripts for: $KOOLBOX_INSTALL_SCRIPTS
EOF
    export KOOLBOX_APT_PACKAGES="${KOOLBOX_APT_PACKAGES}"
    podman build koolbox-files --progress=plain -f - \
      $KOOLBOX_BUILD_TAGS \
      ${KOOLBOX_BUILD_USE_CACHE:-} \
      ${KOOLBOX_PODMAN_BUILD_OPTIONS:-}
      #--env KOOLBOX_APT_PACKAGES

    podman images | grep -E "koolbox|${KOOLBOX_IMAGE_NAME}"
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
    -h|--help        display this help and exit
    -b|--build       build the docker image
    -n|--no-cache    don't use the cache of previous builds
    -v|--view        view the Dockerfile without building it (default)
    -l|--lean        remove as much layers as possible
    -i|--interactive make interactive image with extra tools (default)
    -s|--script      make non-interactive image for use in scripts
    -f|--file <file> file with list of packages (default all.kooL)
EOF
}

koolbox_add_commands() {
    # Add a toolbox user, to not run as root

    #KOOLBOX_PRE_CMDS="groupadd --gid ${KOOLBOX_USER_GID} ${KOOLBOX_USER_GROUP};useradd --system --create-home --home-dir ${KOOLBOX_USER_HOME} --shell /bin/bash --uid ${KOOLBOX_USER_UID} --gid ${KOOLBOX_USER_GID} ${KOOLBOX_USER_NAME}"

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


    #add_command /opt/koolbox/bin/koolbox-install-apt-packages.sh
    for app in ${KOOLBOX_INSTALL_SCRIPTS}; do
        add_command /opt/koolbox/bin/koolbox-install-${app}.sh
    done

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
FROM ubuntu:24.04

COPY bin /opt/koolbox/bin
ENV KOOLBOX_APT_PACKAGES="$KOOLBOX_APT_PACKAGES"
$KOOLBOX_CMDS

CMD ["/bin/bash"]
EOF
}

koolbox_main "${@}"
