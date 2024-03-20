#!/usr/bin/env bash

IFS='' read -r -d '' USAGE <<EOT
Usage: bash setup.sh [OPTION]

Can be remotely invoked with:
    curl -s https://github.com/denera/userenv/setup.sh | bash -s [-- <OPTIONS>]

Options:
    -h, --help            Show this help text.
    -s, --stage <path>    Path for staging the user environment (default: ${HOME}/.config/${USER}).
    -c, --copy            Copy the environment files to ${HOME} instead of using symbolic links.
    -o, --overwrite       Overwrite existing environment. >> WARNING: DESTRUCTIVE <<
    -d, --devroot         Path to the primary dev workspace.

EOT

# helper functions
env_backup() {
    if [ -L $1 ]; then
        echo "    Removing sym-link: ~/$1 -> $(readlink -f "${HOME}/$1")";
        rm "${HOME}/$1";
    else
        echo "    Creating backup: ~/$1 -> ~/env_backup/$1";
        mkdir -p "${HOME}/env_backup";
        mv "${HOME}/$1" "${HOME}/env_backup/$1";
    fi;
}

git_origin() {
    (cd "$1" > /dev/null 2>&1 && git remote get-url origin && cd - > /dev/null 2>&1) || return 1;
}

# parse options
STAGE="${HOME}/.config/${USER}";
DEVROOT="${HOME}/devroot";
CMD='ln -s'
OVERWRITE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "${USAGE}";
            exit 0;
            ;;
        -s|--stage*)
            if [[ "$1" == *"="* ]]; then
                STAGE=$(cut -d'=' -f2 <<< "$1");
            else
                shift; STAGE="$1";
            fi;
            shift;
            ;;
        -c|--copy)
            CMD='cp -R';
            shift;
            ;;
        -o|--overwrite)
            OVERWRITE=true;
            shift;
            ;;
        -d|--devroot*)
            if [[ "$1" == *"="* ]]; then
                DEVROOT=$(cut -d'=' -f2 <<< "$1");
            else
                shift; DEVROOT="$1";
            fi;
            shift;
            ;;
        *)
            echo "ERROR: Unrecognized argument: $1";
            echo "${USAGE}";
            exit 1;
            ;;
    esac;
done;

# symlink devroot
[ ! -d "${DEVROOT}" ] && echo "ERROR: Invalid devroot path: ${DEVROOT}" && exit 1;
if [[ "${DEVROOT}" != "${HOME}/devroot" ]]; then
    echo "Preparing ~/devroot ...";
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/devroot" ] && env_backup "devroot";
    [ ! -e "${HOME}/devroot" ] && eval "$CMD ${DEVROOT} ${HOME}/devroot";
fi;

# clone user environment config
echo "Staging github.com/denera/userenv in ${STAGE} ...";
if [ ! -d "${STAGE}" ]; then
    git clone https://github.com/denera/userenv.git "${STAGE}";
elif [[ $(git_origin "${STAGE}") != "git@github.com:denera/userenv.git" ]]; then
    echo "    ERROR: Invalid staging path: ${STAGE}";
    exit 1;
fi;

# link dotfiles
echo 'Preparing ~/.dotfiles ...'
shopt -s dotglob
for item in "${STAGE}/dotfiles/"*; do
    dotfile=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/${dotfile}" ] && env_backup "${dotfile}";
    [ ! -e "${HOME}/${dotfile}" ] && eval "${CMD} ${STAGE}/dotfiles/${dotfile} ${HOME}/${dotfile}";
done;

# link configs
echo 'Preparing ~/.config ...'
mkdir -p "${HOME}/.config";
shopt -s dotglob
for item in "${STAGE}/configs/"*; do
    config=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/.config/${config}" ] && env_backup "${config}";
    [ ! -e "${HOME}/.config/${config}" ] && eval "${CMD} ${STAGE}/configs/${config} ${HOME}/.config/${config}";
done;

# link binaries
echo 'Preparing ~/.local/bin ...'
mkdir -p "${HOME}/.local/bin";
shopt -s dotglob
for item in "${STAGE}/bins/"*; do
    bin=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/.local/bin/${bin}" ] && env_backup "${bin}";
    [ ! -e "${HOME}/.local/bin/${bin}" ] && eval "${CMD} ${STAGE}/bins/${bin} ${HOME}/.local/bin/${bin}";
done

echo "DONE -- reload your bash environment with 'exec /bin/bash'"

