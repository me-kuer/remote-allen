# Note: You can use any Debian/Ubuntu based image you want. 
# FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye
# FROM vsc-remote15-23-ea61d8489168b3bccb370c94bc9c1890:latest
FROM ma.applysquare.net:4567/eng/docker/remote/wbq-remote:1.1

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID


USER root

RUN cat /etc/apt/sources.list
RUN echo -n "" > /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian-security/ bullseye-security main" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.aliyun.com/debian-security/ bullseye-security main" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list
RUN cat /etc/apt/sources.list


# USER vscode


COPY library-scripts/*.sh /tmp/library-scripts/

# ENV DOCKER_HOST=unix:///var/run/docker.sock
# RUN apt-get update \
#     && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
#     # Use Docker script from script library to set things up
#     && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" \
#     # Clean up
#     && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


# Install Go tools
# ENV GO111MODULE=auto
# RUN bash /tmp/library-scripts/go-debian.sh "" "/usr/local/go" "${GOPATH}" "${USERNAME}" "false" \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*


# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
# ARG NODE_VERSION=""
# ENV NVM_DIR=/usr/local/share/nvm
# ENV NVM_SYMLINK_CURRENT=true \
#     PATH=${NVM_DIR}/current/bin:${PATH}
# RUN bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# RUN apt-get update \
#     && /bin/bash /tmp/library-scripts/a2-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
#     # Clean up
#     && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Remove library scripts for final image
RUN rm -rf /tmp/library-scripts

USER vscode

# ENV DOCKER_HOST=unix:///var/run/user/1000/docker.sock

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>