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
            printf "   "; echo "${@}"
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
    download_dir=${KOOLBOX_INSTALL_OPT_DIR}/${tool_name}/${tool_version:-latest}
    opt_dir=${KOOLBOX_INSTALL_OPT_DIR}/${tool_name}/${tool_version:-latest}
    dry-run mkdir -p ${cache_dir}
    dry-run mkdir -p ${opt_dir}
}


run_all() {
    init_func=init_install
    download_func=download_file
    install_func=install_links
    cleanup_func=cleanup_files
    install_result_path=$KOOLBOX_INSTALL_BIN_DIR/${tool_name}

    source ${KOOLBOX_ROOT_DIR}/install-tools/koolbox-tool-versions.inc
    koolbox_parse_options "${@}"

    calc_tool_version
    init_vars
    init_dirs
    download_result_path=${cache_dir}/${download_filename}
    run_download_file
    run_install_links
    run_install_extras
    run_cleanup_files
}

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

download_file() {
    dry-run curl -L -o ${download_result_path} ${download_url}
    dry-run cd ${opt_dir}
    if ${skip_tar_topdir:-false}; then
        dry-run tar xfz ${download_result_path} --strip-components=1
    else
        dry-run tar xfz ${download_result_path}
    fi
}
install_links() {
    install_with_link
}
cleanup_files() {
    dry-run rm ${download_result_path}
}

main_install() {
    init_func=init_install_${tool_name}
    download_func=download_${tool_name}
    install_func=install_${tool_name}
    cleanup_func=cleanup_${tool_name}
    source ${KOOLBOX_ROOT_DIR}/install-tools/koolbox-tool-versions.inc
    koolbox_parse_options "${@}"
    $init_func
    run_download_file
    run_install_links
    run_install_extras
    #run_cleanup_files
}

run_download_file() {
    if already_downloaded; then
        koolbox_info ${tool_name} already dowloaded in ${download_result_path}
        if ${KOOLBOX_INSTALL_FORCE_DOWNLOAD:-false}; then
            koolbox_info force downloading ${download_result_path} anyway
            $download_func
        fi
    else
        koolbox_info downloading ${download_result_path}
        $download_func
    fi
}

run_install_links() {
    if already_installed; then
        koolbox_info ${tool_name} already installed
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_info force installing ${install_result_path} anyway
            $install_func
        fi
    else
        koolbox_info installing ${tool_name}
        $install_func
    fi
}

run_install_extras() {
    if ${KOOLBOX_INSTALL_COMPLETIONS:-true}; then
        if [[ $(type -t install_${tool_name}_completions) == function ]]; then
            koolbox_info installing bash completions for ${tool_name}
            install_extras
        fi
    fi
}

run_cleanup_files() {
    if ${KOOLBOX_INSTALL_CLEANUP:-false}; then
        koolbox_info cleanup install files for ${tool_name}
        $cleanup_func
    else
        koolbox_info skipping cleanup install files for ${tool_name}
    fi
}

already_downloaded() {
    if [[ -f ${download_result_path} ]]; then
        return 0
    else
        return 1
    fi
}

already_installed() {
    if [[ -f ${install_result_path} ]]; then
        return 0
    else
        return 1
    fi
}

install_with_link() {
    if [[ -L ${install_result_path} ]]; then
        if ${KOOLBOX_INSTALL_FORCE:-false}; then
            koolbox_verbose force linking  ${install_result_path} to ${download_result_path}
            dry-run ln -sf ${download_result_path} ${install_result_path}
        else
            koolbox_info already a version of ${tool_name} installed ${install_result_path}
            if $KOOLBOX_VERBOSE; then
                ls -l ${install_result_path}
            fi
        fi
    elif [[ -f ${install_result_path} ]]; then
        koolbox_info already a file installed at ${install_result_path}
        koolbox_info please remove this before continuing
    else
        koolbox_verbose linking  ${install_result_path} to ${download_result_path}
        dry-run ln -s ${download_result_path} ${install_result_path}
    fi
}


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


#############################################
# Old deprecated
init_download_dir() {
    init_dirs
}
