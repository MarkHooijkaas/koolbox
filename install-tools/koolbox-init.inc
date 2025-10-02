# This file is meant to be sourced by the koolbox-install scripts
set -ue

: ${KOOLBOX_ROOT_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"}

: ${XDG_DATA_HOME:=~/.local/share}
: ${XDG_STATE_HOME:=~/.local/state}
: ${XDG_CONFIG_HOME:=~/.config}


if [[ $(id -u) == 0 ]] ;then
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=/etc/koolbox}
    : ${KOOLBOX_INSTALL_OPT_DIR:=/opt}
    : ${KOOLBOX_INSTALL_BIN_DIR:=/usr/local/bin}
    : ${KOOLBOX_INSTALL_CACHE_DIR:=/var/cache/koolbox}
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=/etc/bash_completion.d}
    : ${KOOLBOX_INSTALL_PROFILE_FILE:=/etc/profile}
else
    : ${KOOLBOX_INSTALL_CONFIG_DIR:=${XDG_CONFIG_HOME}/koolbox}
    : ${KOOLBOX_INSTALL_OPT_DIR:=~/opt}
    : ${KOOLBOX_INSTALL_BIN_DIR:=~/.local/bin}
    : ${KOOLBOX_INSTALL_CACHE_DIR:=~/.cache/koolbox}
    : ${KOOLBOX_INSTALL_BASH_COMPLETE_DIR:=${XDG_DATA_HOME}/bash-completion/completions}
    : ${KOOLBOX_INSTALL_PROFILE_FILE:=~/.profile}
fi

koolbox_use_apt() {
    type -t apt >/dev/null
}
koolbox_use_dnf() {
    type -t dnf >/dev/null
}


: ${KOOLBOX_VERBOSE:=false}
: ${KOOLBOX_INFO:=true}

koolbox_verbose() {
    if ${KOOLBOX_VERBOSE:-true}; then
        echo "${@}"
    fi
}

koolbox_info() {
    if ${KOOLBOX_INFO:-true}; then
        echo "${@}"
    fi
}

#####################################################################
dry-run() {
    if $KOOLBOX_DRY_RUN; then
        printf "   "; echo "${@}"
    else
        cmd=$1
        shift
        if ${KOOLBOX_VERBOSE:-true}; then
            printf "   "; echo $cmd "${@}"
        fi
        $cmd "${@}"
    fi
}

koolbox_parse_options() {
    KOOLBOX_DRY_RUN=false
    while [ ! $# -eq 0 ]; do
        case $1 in
            -h|--help)    koolbox_help; exit 0;;
            -v|--verbose) KOOLBOX_VERBOSE=true; KOOLBOX_INFO=true;;
            -q|--quiet)   KOOLBOX_VERBOSE=false; KOOLBOX_INFO=false;;
            -f|--force)   KOOLBOX_INSTALL_FORCE=true;;
            -F|--force-all)  KOOLBOX_INSTALL_FORCE_DOWNLOAD=true; KOOLBOX_INSTALL_FORCE=true;;
            -V|--version)  KOOLBOX_TOOL_VERSION=$2; shift;;
            -t|--tool)     tool_name=$2; shift;;
            -d|--dry-run) KOOLBOX_DRY_RUN=true;;
            -N|--no-cleanup) KOOLBOX_INSTALL_CLEANUP=false;;
            -x)           set -x;;
            *)  # Default case: No more options, so break out of the loop.
                echo Unknown option $1
                koolbox_help
                exit 1
        esac
        shift
    done
}

koolbox_help() {
    cat << EOF
Usage: ${0##*/} [options]

Options can be:
    -h|--help     display this help and exit
    -v|--verbose  show extra information during installation
    -q|--quiet    don't show any information
    -f|--force    force re-install (but not re download)
    -F|--force-all force re-download and re-install
    -V|--version  install a specific version
    -d|--dry-run  dry-run, do not make changes (not yet supported for all tools)
    -C|--clear    clear cache of temporary (downloaded and other) files
    -x            bash set -x for further debugging
EOF
}

#####################################################################
init_dirs() {
    cache_dir=${KOOLBOX_INSTALL_CACHE_DIR}/${tool_name}/${tool_version:-latest}
    extract_dir=${KOOLBOX_INSTALL_OPT_DIR}/${tool_name}/${tool_version:-latest}
    bin_dir=${KOOLBOX_INSTALL_BIN_DIR}
    dry-run mkdir -p ${cache_dir}
    dry-run mkdir -p ${extract_dir}
    dry-run mkdir -p ${bin_dir}

    : ${extract_path:=${extract_dir}/${tool_name}}
    : ${install_path:=${KOOLBOX_INSTALL_BIN_DIR}/${bin_name:-$tool_name}}
    : ${completion_path:=${KOOLBOX_INSTALL_BASH_COMPLETE_DIR}/koolbox-${tool_name}}
}

run_all() {
    source ${KOOLBOX_ROOT_DIR}/install-tools/koolbox-tool-versions.inc
    koolbox_parse_options "${@}"
    source ${KOOLBOX_ROOT_DIR}/kooltools/${tool_name}.def
    calc_tool_version
    init_vars
    init_dirs
    download_path=${cache_dir}/${download_filename}
    #install_path=$KOOLBOX_INSTALL_BIN_DIR/${tool_name}
    #download_path=${cache_dir}/${download_filename}
    run_download_file
    run_install
    run_install_extras
    run_cleanup_files
}

#####################################################################
# helper functions
calc_tool_version() {
    # see https://stackoverflow.com/questions/16553089/dynamic-variable-names-in-bash
    version_varname=KOOLBOX_INSTALL_${tool_name^^}_VERSION
    if [[ ! -z ${KOOLBOX_TOOL_VERSION:-} ]]; then
        eval $version_varname=$KOOLBOX_TOOL_VERSION
    fi
    tool_version="${!version_varname}"

}

calc_transformed_os_arch() {
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    OS_ARCH=${OS}_${ARCH}
}

# append a line to a file if it is not there, e.g. to change .bashrc
append_to_file() {
    local file=$1
    shift
    local cmd="${@}"
    if [[ -f $file ]]; then
        pattern="^${cmd/\$/\\\$}$"
        #echo $pattern
        found=$(grep -E "^$pattern" $file) || true
        if [ -z "$found" ] ; then
            koolbox_info modifying $file by appending command: $cmd
            echo $cmd >>$file
        else
            koolbox_info $file already includes $cmd
        fi
    else
        koolbox_info creating new $file with command: $cmd
        echo $cmd >>$file
    fi
}


#####################################################################
# download step
run_download_file() {
    if [[  -f ${download_path} ]]; then
        koolbox_verbose ${tool_name} already downloaded in ${download_path}
        if ${KOOLBOX_INSTALL_FORCE_DOWNLOAD:-false}; then
            koolbox_verbose force downloading ${download_path} anyway
            download_file
        fi
    else
        koolbox_verbose downloading ${download_path}
        download_file
    fi
}

# default function, can be overridden
download_file() {
    dry-run curl -L -o ${download_path} ${download_url}
}



#####################################################################
# install step
run_install() {
    if [[ -f ${install_path} ]]; then
        koolbox_verbose ${tool_name} already installed
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_verbose force extracting ${download_path} to ${extract_path}
            extract_downloaded_file
            install_links
        fi
    else
        koolbox_verbose extracting ${download_path} to ${extract_path}
        extract_downloaded_file
        koolbox_verbose installing ${tool_name}
        install_links
    fi
}

# default function, can be overridden
extract_downloaded_file() {
    #dry-run cd ${extract_dir}
    if ${skip_tar_topdir:-true}; then
        local options="--strip-components=1"
    fi
    dry-run tar xfz ${download_path} --directory ${extract_dir} ${options:-}
}

# default function, can be overridden
install_links() {
    if [[ -L ${install_path} ]]; then
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_verbose force linking  ${install_path} to ${extract_path}
            dry-run ln -sf ${extract_path} ${install_path}
        else
            koolbox_info already a version of ${tool_name} installed ${install_path}
            if $KOOLBOX_VERBOSE; then
                ls -l ${install_path}
            fi
        fi
    elif [[ -f ${install_path} ]]; then
        koolbox_info already a file installed at ${install_path}
        koolbox_info please remove this before continuing
    else
        koolbox_verbose linking  ${install_path} to ${extract_path}
        dry-run ln -s ${extract_path} ${install_path}
    fi
}


run_install_extras() {
    if ${KOOLBOX_INSTALL_COMPLETIONS:-true}; then
        if [[ $(type -t install_${tool_name}_completions) == function ]]; then
            koolbox_verbose installing bash completions for ${tool_name}
            install_extras
        fi
    fi
}




#####################################################################
# cleanup step
cleanup_files() {
    dry-run rm ${download_path}
}

run_cleanup_files() {
    if ${KOOLBOX_INSTALL_CLEANUP:-false}; then
        koolbox_verbose cleanup install files for ${tool_name}
        $cleanup_func
    else
        koolbox_verbose skipping cleanup install files for ${tool_name}
    fi
}
