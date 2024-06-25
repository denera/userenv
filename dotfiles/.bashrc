#!/bin/bash

test -s "${HOME}/.bash_utils" && . "${HOME}/.bash_utils"

# set the user group ID if it's not already done by the system
if [[ -z "${GID}" ]]; then
  export GID=$(id -g)
fi

# launch or re-attach to the SSH agent
if [[ ! -f "/.dockerenv" ]]; then
    # this is NOT a container so we launch the SSH agent if it's not already running
    ssh-add -l &>/dev/null
    if [[ "$?" == 2 ]]; then
        # couldn't open connection to agent so let's try loading stored agent info
        test -r "${HOME}/.ssh-agent" && eval "$(<${HOME}/.ssh-agent)" >/dev/null
        ssh-add -l &>/dev/null
        if [ "$?" == 2 ]; then
            # that didn't work either so we start a new agent and store its info
            (umask 066; ssh-agent > ${HOME}/.ssh-agent)
            eval "$(<${HOME}/.ssh-agent)" >/dev/null
        fi
    fi
    # check agent again
    ssh-add -l &>/dev/null
    if [ "$?" == 1 ]; then
        # agent has no identities so add them here
        if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
            ssh-add "${HOME}/.ssh/id_ed25519"
        fi
        if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
            ssh-add "${HOME}/.ssh/id_rsa"
        fi
    fi
else
    export SSH_AUTH_SOCK="/ssh-agent"
fi
ssh-add -l

export DEVROOT="/mnt/nvdl/usr/adener"

# make sure CUDA bin is in path
export CUDA_HOME="/usr/local/cuda"
prepend PATH "${CUDA_HOME}/bin"
append LD_LIBRARY_PATH "${CUDA_HOME}/lib64"

# activate NVM
if [ -d "${HOME}/.nvm" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${HOME}/.nvm/nvm.sh" ] && . "${HOME}/.nvm/nvm.sh"
    [ -s "${HOME}/.nvm/bash_completion" ] && . "${HOME}/.nvm/bash_completion"
    nvm use 17
fi;

# starship prompt
prepend PATH "${HOME}/.local/bin"
eval "$(starship init bash)"
