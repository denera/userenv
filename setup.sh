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
        --neovim          Install neovim.

EOT

# helper functions
env_backup() {
    if [ -e "$1" ]; then
        if [ -L "$1" ]; then
            echo "    Removing sym-link: $1 --> $(readlink -f "$1")";
            rm "$1";
        else
            item=$(echo "$1" | rev | cut -d'/' -f1 | rev)
            echo "    Creating backup: $1 --> ${HOME}/env_backup/${item}";
            mkdir -p "${HOME}/env_backup";
            [ -e "${HOME}/env_backup/${item}" ] && rm -r "${HOME}/env_backup/${item}";
            mv "$1" "${HOME}/env_backup/${item}";
        fi
    fi;
}

git_origin() {
    (cd "$1" > /dev/null 2>&1 && git remote get-url origin && cd - > /dev/null 2>&1) || return 1;
}

# parse options
STAGE="${HOME}/.config/${USER}";
DEVROOT="${HOME}/devroot";
CMD='ln -s';
OVERWRITE=false;
GET_NEOVIM=false;
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
        --neovim)
            GET_NEOVIM=true;
            shift;
            ;;
        *)
            echo "ERROR: Unrecognized argument: $1";
            echo "${USAGE}";
            exit 1;
            ;;
    esac;
done;
[ ! -d "${DEVROOT}" ] && echo "ERROR: Invalid devroot path: ${DEVROOT}" && exit 1;

# clone user environment config
echo "Staging github.com/denera/userenv in ${STAGE} ...";
if [ ! -d "${STAGE}" ]; then
    git clone https://github.com/denera/userenv.git "${STAGE}";
elif [[ $(git_origin "${STAGE}") != "git@github.com:denera/userenv.git" ]]; then
    echo "    ERROR: Invalid staging path: ${STAGE}";
    exit 1;
fi;

# prep dotfiles
echo 'Preparing ~/.dotfiles ...'
shopt -s dotglob
for item in "${STAGE}/dotfiles/"*; do
    dotfile=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${dotfile} == ".vimrc" ] && continue;  # skip copying .vimrc
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/${dotfile}" ] && env_backup "${HOME}/${dotfile}";
    [ ! -e "${HOME}/${dotfile}" ] && eval "${CMD} ${STAGE}/dotfiles/${dotfile} ${HOME}/${dotfile}";
    [[ "${CMD}" == "cp"* ]] && chmod 755 -R "${HOME}/${dotfile}";
    if [[ ${dotfile} ==  ".bashrc"  ]]; then
        echo "Setting DEVROOT=${DEVROOT} ...";
        sed -i -e "s@export DEVROOT=.*@export DEVROOT=${DEVROOT}@" ${HOME}/${dotfile};
    fi;
done;

# prep configs
echo 'Preparing ~/.config ...'
mkdir -p "${HOME}/.config";
shopt -s dotglob
for item in "${STAGE}/configs/"*; do
    config=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [[ ${config} == "nvim" ]] && continue;
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/.config/${config}" ] && env_backup "${HOME}/.config/${config}";
    [ ! -e "${HOME}/.config/${config}" ] && eval "${CMD} ${STAGE}/configs/${config} ${HOME}/.config/${config}";
    [[ "${CMD}" == "cp"* ]] && chmod 755 -R "${HOME}/.config/${config}";
done;
[ ${OVERWRITE} == true ] && [ -e "${HOME}/.config/containers" ] && env_backup "${HOME}/.config/containers";
[ ! -e "${HOME}/.config/containers" ] && eval "${CMD} ${STAGE}/containers ${HOME}/.config/containers";
[[ "${CMD}" == "cp"* ]] && chmod 755 -R "${HOME}/.config/containers" && chmod +x "${HOME}/.config/containers/entrypoint.sh";

# prep binaries
echo 'Preparing ~/.local/bin ...'
mkdir -p "${HOME}/.local/bin";
shopt -s dotglob
for item in "${STAGE}/bins/"*; do
    bin=$(echo "${item}" | rev | cut -d'/' -f1 | rev);
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/.local/bin/${bin}" ] && env_backup "${HOME}/.local/bin/${bin}";
    [ ! -e "${HOME}/.local/bin/${bin}" ] && eval "${CMD} ${STAGE}/bins/${bin} ${HOME}/.local/bin/${bin}";
    [[ "${CMD}" == "cp"* ]] && chmod 755 -R "${HOME}/.local/bin/${bin}";
done

# install vim plugins
if [ ${GET_NEOVIM} == true ]; then
    echo 'Preparing neovim ...';
    if [ ! -x $(command -v node) ]; then
        echo '    Installing Node.js ...';
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash;
        export NVM_DIR="$HOME/.nvm";
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh";
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion";
        nvm install 17 && nvm use 17;
    fi;
    if [ ! -x $(command -v nvim) ]; then
        echo '    Installing pre-built neovim binaries ...';
        mkdir -p "${HOME}/.local/src";
        curl -o "${HOME}/.local/src/nvim-linux64.tar.gz" -L https://github.com/neovim/neovim-releases/releases/download/v0.10.0/nvim-linux64.tar.gz;
        tar -C ${HOME}/.local/src -xzf ${HOME}/.local/src/nvim-linux64.tar.gz;
        rm ${HOME}/.local/src/nvim-linux64.tar.gz;
        for item in "${HOME}/.local/src/nvim-linux64/"*; do
            folder=$(echo ${item} | rev | cut -d'/' -f1 | rev);
            [ ! -d "${HOME}/.local/${folder}" ] && mkdir -p ${HOME}/.local/${folder};
            mv -f ${HOME}/.local/src/nvim-linux64/${folder}/* ${HOME}/.local/${folder}/;
        done;
        rm -r ${HOME}/.local/src/nvim-linux64;
    fi;
    NVIM_PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim;
    if [ ! -d "${NVIM_PLUG_PATH}" ]; then
        echo "    Installing nvim-plug ...";
        curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim;
    fi;
    NVIM_CONFIG_HOME="${XDF_CONFIG_HOME:-$HOME/.config}"/nvim;
    [ ${OVERWRITE} == true ] && [ -e "${NVIM_CONFIG_HOME}" ] && env_backup "${NVIM_CONFIG_HOME}";
    [ ! -e "${NVIM_CONFIG_HOME}" ] && eval "${CMD} ${STAGE}/configs/nvim ${NVIM_CONFIG_HOME}";
    [[ "${CMD}" == "cp"* ]] && chmod 755 -R "${NVIM_CONFIG_HOME}";
    echo "    Installing plugins ...";
    nvim --headless -c 'silent' -c 'PlugInstall' -c 'qall';
elif [ -x $(command -v vim) ]; then
    echo 'Preparing vim ...';
    [ ${OVERWRITE} == true ] && [ -e "${HOME}/.vimrc" ] && env_backup "${HOME}/.vimrc";
    [ ! -e "${HOME}/.vimrc" ] && eval "${CMD} ${STAGE}/dotfiles/.vimrc ${HOME}/.vimrc";
    [[ "${CMD}" == "cp"* ]] && chmod 755 "${HOME}/.vimrc";
    # Install vim-plug
    if [ ! -e "${HOME}/.vim/autoload/plug.vim" ]; then
        echo '    Installing vim-plug ...';
        VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
        curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs ${VIM_PLUG_URL};
    fi;
    echo "    Installing plugins ...";
    vim +slient +VimEnter +PlugInstall +qall;
fi;

echo "DONE -- reload your bash environment with 'exec /bin/bash'"

