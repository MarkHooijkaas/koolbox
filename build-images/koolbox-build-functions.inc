set -eu

source $(dirname ${BASH_SOURCE[0]})/versions.inc

: ${KOOLBOX_BUILD_OPTIONS:=""}


#: ${KOOLBOX_FILE:=config/all.kool}
#: ${KOOLBOX_BUILD_FROM:=debian:trixie}



function koolbox_build_init() {
    koolbox_parse_options "$@"
}

function koolbox_parse_options() {
    build_cmd=view-container-file
    KOOLBOX_BUILD_FULL=false
    while [ ! $# -eq 0 ]; do
        case $1 in
            -h|--help)
                koolbox_help
                exit 0
                ;;
            -b|--build)
                build_cmd=build-image
                ;;
            -v|--view)
                build_cmd=view-container-file
                ;;
            -n|--no-cache)
                KOOLBOX_PODMAN_BUILD_OPTIONS+=" --no-cache"
                ;;
            -f|--full)
                KOOLBOX_BUILD_FULL=true
                ;;
            -t|--tag)
                KOOLBOX_BUILD_IMAGE_SUBTAG=$2
                shift
                ;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
    if [[ ${KOOLBOX_BUILD_IMAGE_SUBTAG:-} == *-full ]]; then
        KOOLBOX_BUILD_FULL=true
    fi
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
    -t|--tag <tag>   the type of image like deb13-slim or alma9-full
    -f|--full        build a full image (automatically set if tag ends with "-full")
EOF
}

koolbox_install_commands() {
    for app in ${KOOLBOX_INSTALL_SCRIPTS:-}; do
        echo /opt/koolbox/bin/koolbox-install-${app}.sh
    done
}

koolbox_build_env_filename() {
    echo /etc/koolbox/build.env.$KOOLBOX_BUILD_IMAGE_NAME-${KOOLBOX_VERSION}-${KOOLBOX_BUILD_IMAGE_SUBTAG}
}

koolbox_create_build_env_file() {
cat <<EOF
COPY <<EOT $(koolbox_build_env_filename)
$(set | grep -E '^KOOLBOX_INSTALL|^KOOLBOX_BUILD' | sed 's/^/export /')
EOT
EOF
}

function koolbox_copy_install_files() {
    files=""
    count=0
    for app in ${KOOLBOX_COPY_SCRIPTS:-${KOOLBOX_INSTALL_SCRIPTS}}; do
        files+=" bin/koolbox-install-${app}.sh"
        count=$((count+1))
    done
    if [[ $count == 0 ]]; then
        echo "# NO install scripts to copy"
    elif [[ $count == 1 ]]; then
        # copy just one file to exact filename
        echo "COPY $files /opt/koolbox/bin/koolbox-install-$app.sh"
    else
        # copy just multiple file to directory
        echo "COPY $files /opt/koolbox/bin/"
    fi
}

function koolbox_build_image() {
    $build_cmd
}

function view-container-file() {
    calc-build-options
    create-container-file
}

function build-image() {
    calc-build-options
    create-container-file | podman build --progress=plain -f - $KOOLBOX_BUILD_OPTIONS .
    #echo finished building;  podman images | grep  "${KOOLBOX_BUILD_IMAGE_NAME}"
}

function calc-build-options() {
    : ${KOOLBOX_BUILD_FROM_IMAGE_TAG:=${KOOLBOX_VERSION}-${KOOLBOX_BUILD_IMAGE_SUBTAG}}
    : ${KOOLBOX_BUILD_FROM_IMAGE:=${KOOLBOX_BUILD_FROM_IMAGE_NAME}:${KOOLBOX_BUILD_FROM_IMAGE_TAG}}

    : ${KOOLBOX_BUILD_IMAGE_TAGS:=${KOOLBOX_VERSION}-${KOOLBOX_BUILD_IMAGE_SUBTAG}}
    KOOLBOX_BUILD_OPTIONS=${KOOLBOX_PODMAN_BUILD_OPTIONS:-}
    for tag in ${KOOLBOX_BUILD_IMAGE_TAGS:-latest}; do
        KOOLBOX_BUILD_OPTIONS+=" --tag orgkisst/$KOOLBOX_BUILD_IMAGE_NAME:${tag}"
    done
}

function create-container-file() {
    cat <<EOF
FROM ${KOOLBOX_BUILD_FROM_IMAGE}
LABEL \
  koolbox.version="${KOOLBOX_VERSION}" \
  koolbox.subtag="${KOOLBOX_BUILD_IMAGE_SUBTAG}"

$(koolbox_create_build_env_file)
$(koolbox_copy_install_files)

RUN <<EOT bash
source $(koolbox_build_env_filename)
/opt/koolbox/bin/koolbox-install-os-packages.sh
$(koolbox_install_commands)
EOT

CMD ["/bin/bash"]
EOF
}
