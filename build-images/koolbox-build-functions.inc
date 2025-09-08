set -eu

source $(dirname ${BASH_SOURCE[0]})/versions.inc

: ${KOOLBOX_BUILD_OPTIONS:=""}


#: ${KOOLBOX_FILE:=config/all.kool}
#: ${KOOLBOX_BUILD_FROM:=debian:trixie}



function koolbox_build_main() {
    cmd=view-container-file
    koolbox_parse_options "$@"
    $cmd
}

function koolbox_parse_options() {
    while [ ! $# -eq 0 ]; do
        case $1 in
            -h|--help)
                koolbox_help
                exit 0
                ;;
            -b|--build)
                cmd=build-image
                ;;
            -v|--view)
                cmd=view-container-file
                ;;
            -n|--no-cache)
                KOOLBOX_PODMAN_BUILD_OPTIONS+=" --no-cache"
                ;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
}


function view-container-file() {
    create-container-file
}


build-image() {
    : ${KOOLBOX_BUILD_IMAGE_TAGS:=${KOOLBOX_VERSION}-${KOOLBOX_BUILD_IMAGE_SUBTAG}}

    options=${KOOLBOX_PODMAN_BUILD_OPTIONS:-}
    for tag in ${KOOLBOX_BUILD_IMAGE_TAGS:-latest}; do
        options+=" --tag orgkisst/$KOOLBOX_BUILD_IMAGE_NAME:${tag}"
    done

    #export KOOLBOX_INSTALL_APT_PACKAGES
    #export KOOLBOX_INSTALL_SCRIPTS
    create-container-file | podman build --progress=plain -f - $options . && \
    echo finished building;  podman images | grep  "${KOOLBOX_BUILD_IMAGE_NAME}"
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
EOF
}

koolbox_install_commands() {
    for app in ${KOOLBOX_INSTALL_SCRIPTS}; do
        if [[ ! $app==os-packages ]]; then
            echo /opt/koolbox/bin/koolbox-install-${app}.sh
        fi
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
    elif [[ $count==1 ]]; then
        # copy just one file to exact filename
        echo "COPY $files /opt/koolbox/bin/koolbox-install-$app.sh"
    else
        # copy just multiple file to directory
        echo "COPY $files /opt/koolbox/bin/"
    fi
}

function create-container-file() {
cat <<EOF
FROM ${KOOLBOX_BUILD_FROM_IMAGE_NAME}:${KOOLBOX_BUILD_FROM_IMAGE_TAG}
$(koolbox_create_build_env_file)
$(koolbox_copy_install_files)

RUN <<EOT bash
source $(koolbox_build_env_filename)
/opt/koolbox/bin/koolbox-install-os-packages.sh"
$(koolbox_install_commands)
EOT

CMD ["/bin/bash"]
EOF
}
