#!/bin/bash

# get sudo and gosu to make root actions easier for the new user we will create below
apt update && apt install sudo gosu tmux gettext

# guard against the possibility that $GID may be unset in the host environment
HOST_USER=adener
HOST_UID=100341
HOST_GROUP=dip
HOST_GID=30
echo "Starting with USER: $HOST_USER with UID: $HOST_UID and GID: $HOST_GID"

# create usergroup manually
if [ ! $(getent group dip) ]; then
  groupadd -g $HOST_GID $HOST_GROUP
fi

# create new container user to match host user's name, UID and primary GID
# -o : non-unique
# -M : no-create-home
# -N : no-user-group
useradd -o -M -N -u $HOST_UID -g $HOST_GID -d /home/$HOST_USER $HOST_USER
if [[ "$(groups $HOST_USER)" != *"$HOST_GROUP"* ]]; then
  usermod -aG $HOST_GROUP $HOST_USER
fi
usermod -aG sudo $HOST_USER
usermod -aG root $HOST_USER
chown -R $HOST_UID:$HOST_GID /home/$HOST_USER

# disable sudo password
echo "$HOST_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/99_sudo_include_file
visudo -cf /etc/sudoers.d/99_sudo_include_file

# install neovim
mkdir -p /opt
git clone https://github.com/neovim/neovim /opt/neovim
cd /opt/neovim && git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
cd build && cpack -G DEB && dpkg -i nvim-linux64.deb
cd /opt && rm -rf neovim

# execute remaining container commands as the new user
if [[ $# -eq 0 ]]; then
  exec sudo /usr/sbin/gosu $HOST_USER "/bin/bash"
else
  exec sudo /usr/sbin/gosu $HOST_USER "$@"
fi
