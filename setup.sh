#!/usr/bin/env bash

IFS='' read -r -d '' usage <<EOT
Usage: bash setup.sh [OPTION]

Can be remotely invoked with:
    curl -s https://github.com/denera/userenv/setup.sh | bash -s [-- <OPTIONS>]

Options:
    -h, --help            Show this help text.
    -s, --stage <path>    Path for staging the user environment (default: ${HOME}/.config/${USER}).
    -c, --copy            Copy the environment files to ${HOME} instead of using symbolic links.
    -p, --preserve        Keep existing environment files instead of overwriting them.

EOT

# parse options
STAGE=${HOME}/.config/${USER};
CMD='ln -s'
PRESERVE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo $usage;
            return 0;
            ;;
        -s|--stage)
            shift;
            STAGE=$1;
            shift;
            ;;
        -c|--copy)
            CMD='cp -R'
            shift;
            ;;
        -p|--preserve)
            PRESERVE=true;
            shift;
            ;;
        *)
            echo "ERROR: Unrecognized argument: $1";
            echo $usage;
            return 1;
            ;;
    esac;
done;

# clone user environment config
[ ! ${PRESERVE} ] && rm -rf "${STAGE}";
if [ ! -d "${STAGE}" ]; then
    git clone https://github.com/denera/userenv.git "${STAGE}";
elif [ ! -d "${STAGE}/.git" ] || [[ $(cd ${STAGE} && git remote get-url origin && cd - >/dev/null) != "git@github.com:denera/userenv.git" ]]; then
    echo "ERROR: Invalid staging path: ${STAGE}";
    return 1;
fi;

# link dotfiles
echo 'Preparing ~/.dotfiles ...'
shopt -s dotglob
for item in "${STAGE}/dotfiles/"*; do
    dotfile=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    if ${PRESERVE} && [ ! -f "${HOME}/${dotfile}" ] && [ ! -d "${HOME}/${dotfile}" ]; then
         eval "${CMD} ${STAGE}/dotfiles/${dotfile} ${HOME}/${dotfile}";
    else
        rm -rf "${HOME}/${dotfile:?}";
        eval "${CMD} ${STAGE}/dotfiles/${dotfile} ${HOME}/${dotfile}";
    fi
done;

# link configs
echo 'Preparing ~/.config ...'
mkdir -p "${HOME}/.config";
shopt -s dotglob
for item in "${STAGE}/configs/"*; do
    config=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    if ${PRESERVE} && [ ! -f "${HOME}/.config/${config}" ] && [ ! -d "${HOME}/.config/${config}" ]; then
        eval "${CMD} ${STAGE}/configs/${config} ${HOME}/.config/${config}";
    else
        rm -rf "${HOME}/.config/${config}";
        eval "${CMD} ${STAGE}/configs/${config} ${HOME}/.config/${config}";
    fi
done;

# link binaries
echo 'Preparing ~/.local/bin ...'
mkdir -p "${HOME}/.local/bin";
shopt -s dotglob
for item in "${STAGE}/bins/"*; do
    bin=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    if ${PRESERVE} && [ ! -f "${HOME}/.local/bin/${bin}" ] && [ ! -d "${HOME}/.local/bin/${bin}" ]; then
        eval "${CMD} ${STAGE}/bins/${bin} ${HOME}/.local/bin/${bin}";
    else
        rm -rf "${HOME}/.local/bin/${bin}";
        eval "${CMD} ${STAGE}/bins/${bin} ${HOME}/.local/bin/${bin}";
    fi
done

echo "DONE -- reload your bash environment with 'exec /bin/bash'"

