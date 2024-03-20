#!/usr/bin/env bash

IFS='' read -r -d '' usage <<EOT
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
    cd $1 2>/dev/null || return 1;
    local origin=$(git remote get-url origin);
    cd - 2>/dev/null || return 1;
    echo "${origin}";
}

# parse options
STAGE=${HOME}/.config/${USER};
DEVROOT=${HOME}/devroot;
CMD='ln -s'
OVERWRITE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo $usage;
            exit 0;
            ;;
        -s|--stage)
            shift; STAGE=$1 shift;
            ;;
        -c|--copy)
            CMD='cp -R' shift;
            ;;
        -o|--overwrite)
            OVERWRITE=true; shift;
            ;;
        -d|--devroot)
            shift; DEVROOT=$1; shift;
            shift;
            ;;
        *)
            echo "ERROR: Unrecognized argument: $1";
            echo $usage;
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
if [ ! -d "${STAGE}" ]; then
    echo "Pulling userenv repo to ${STAGE} ...";
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
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/${config}" ] && env_backup "${config}";
    [ ! -e "${HOME}/${config}" ] && eval "${CMD} ${STAGE}/configs/${config} ${HOME}/${config}";
done;

# link binaries
echo 'Preparing ~/.local/bin ...'
mkdir -p "${HOME}/.local/bin";
shopt -s dotglob
for item in "${STAGE}/bins/"*; do
    bin=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/${bin}" ] && env_backup "${bin}";
    [ ! -e "${HOME}/${bin}" ] && eval "${CMD} ${STAGE}/bins/${bin} ${HOME}/${bin}";
done

echo "DONE -- reload your bash environment with 'exec /bin/bash'"

