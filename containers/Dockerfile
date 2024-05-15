ARG base
FROM $base
SHELL ["/bin/bash", "-c"]

# make sure the setup is done with the root user
USER root

# install apt packages
RUN apt-get update --allow-insecure-repositories --allow-unauthenticated
RUN apt-get install -y sudo gosu

# clone GDRcopy for IDE symbol search
RUN git clone https://github.com/NVIDIA/gdrcopy.git /opt/gdrcopy

# install Python dependencies
ARG pydeps
RUN <<EOT
pip3 install --upgrade pip wheel setuptools flake8 pytest pybind11;
IFS=',' read -ra pythondeps <<< $pydeps;
for dep in ${pythondeps[@]}; do
    if [[ $dep == *"jax["* ]]; then
        pip3 install --upgrade $dep -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html;
    else
        pip3 install --upgrade $dep;
    fi;
done;
EOT

# create container user that mirrors the host user
ENV HOST_USER=adener
ENV HOST_UID=100341
ENV HOST_GROUP=dip
ENV HOST_GID=30
RUN useradd -o -m -N -u $HOST_UID -g $HOST_GID -s /bin/bash $HOST_USER
RUN usermod -aG $HOST_GROUP $HOST_USER
RUN usermod -aG sudo $HOST_USER
RUN usermod -aG root $HOST_USER

# give superuser permissions to the new container user
RUN echo "$HOST_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/99_sudo_include_file
RUN visudo -cf /etc/sudoers.d/99_sudo_include_file
