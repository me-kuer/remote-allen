#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/go.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./go-debian.sh [Go version] [GOROOT] [GOPATH] [non-root user] [Add GOPATH, GOROOT to rc files flag] [Install tools flag]

TARGET_GO_VERSION=${1:-"1.17.2"}
TARGET_GOROOT=${2:-"/usr/local/go"}
TARGET_GOPATH=${3:-"/go"}
USERNAME=${4:-"automatic"}
UPDATE_RC=${5:-"true"}
INSTALL_GO_TOOLS=${6:-"true"}

set -e

echo "===========> TARGET_GO_VERSION: ${TARGET_GO_VERSION}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        echo -e "$1" >> /etc/bash.bashrc
        if [ -f "/etc/zsh/zshrc" ]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}    
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

echo "go-debial ssssssssssssss 0"

# Function to run apt-get if needed
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "go-debial ssssssssssssss 0 1"
        echo "Running apt-get update..."
        apt-get update
    else
        echo "go-debial ssssssssssssss 0 2"
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

echo "go-debial ssssssssssssss 1"

# Install curl, tar, git, other dependencies if missing
check_packages curl ca-certificates tar g++ gcc libc6-dev make pkg-config
if ! type git > /dev/null 2>&1; then
    echo "go-debial ssssssssssssss 2"
    apt_get_update_if_needed
    apt-get -y install --no-install-recommends git
fi

echo "go-debial ssssssssssssss 3"

# Get closest match for version number specified
# find_version_from_git_tags TARGET_GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"
# TARGET_GO_VERSION = "1.17.2"
# TARGET_GO_VERSION = ${"1.17.2"}
# ${TARGET_GO_VERSION} = "1.17.2"

echo "go-debial ssssssssssssss 4"

architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="armv6l";;
    i?86) architecture="386";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

echo "go-debial ssssssssssssss 5"

# https://golang.google.cn/dl/go1.17.2.linux-amd64.tar.gz
# https://golang.org/dl/go${TARGET_GO_VERSION}.linux-${architecture}.tar.gz
# https://dl.google.com/go/go1.17.2.linux-amd64.tar.gz

# Install Go
GO_INSTALL_SCRIPT="$(cat <<EOF
    set -e
    echo "Downloading Go ${TARGET_GO_VERSION}..."
    curl -sSL -o /tmp/go.tar.gz "https://golang.google.cn/dl/go1.17.2.linux-amd64.tar.gz"
    echo "Extracting Go ${TARGET_GO_VERSION}..."
    tar -xzf /tmp/go.tar.gz -C "${TARGET_GOROOT}" --strip-components=1
    rm -f /tmp/go.tar.gz
EOF
)"

echo "go-debial ssssssssssssss 6"
if [ "${TARGET_GO_VERSION}" != "none" ] && ! type go > /dev/null 2>&1; then
    echo "go-debial ssssssssssssss 7"
    mkdir -p "${TARGET_GOROOT}" "${TARGET_GOPATH}" 
    chown -R ${USERNAME} "${TARGET_GOROOT}" "${TARGET_GOPATH}"
    su ${USERNAME} -c "${GO_INSTALL_SCRIPT}"
else
    echo "go-debial ssssssssssssss 8"
    echo "Go already installed. Skipping."
fi



echo "go-debial ssssssssssssss 9"
# Install Go tools that are isImportant && !replacedByGopls based on
# https://github.com/golang/vscode-go/blob/0ff533d408e4eb8ea54ce84d6efa8b2524d62873/src/goToolsInformation.ts
# Exception `dlv-dap` is a copy of github.com/go-delve/delve/cmd/dlv built from the master.
GO_TOOLS="\
    golang.org/x/tools/gopls@latest \
    honnef.co/go/tools/cmd/staticcheck@latest \
    golang.org/x/lint/golint@latest \
    github.com/mgechev/revive@latest \
    github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest \
    github.com/ramya-rao-a/go-outline@latest \
    github.com/go-delve/delve/cmd/dlv@latest \
    github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
echo "go-debial ssssssssssssss 10"
if [ "${INSTALL_GO_TOOLS}" = "true" ]; then
    echo "Installing common Go tools..."
    export PATH=${TARGET_GOROOT}/bin:${PATH}
    mkdir -p /tmp/gotools /usr/local/etc/vscode-dev-containers ${TARGET_GOPATH}/bin
    cd /tmp/gotools
    export GOPATH=/tmp/gotools
    export GOCACHE=/tmp/gotools/cache

    # Use go get for versions of go under 1.16
    go_install_command=install
    if [[ "1.16" > "$(go version | grep -oP 'go\K[0-9]+\.[0-9]+(\.[0-9]+)?')" ]]; then
        echo "go-debial ssssssssssssss 11"
        export GO111MODULE=on
        go_install_command=get
        echo "Go version < 1.16, using go get."
    fi 
    echo "go-debial ssssssssssssss 12"
    go env -w GOPROXY=https://goproxy.cn,direct
    go env -w GOPRIVATE=*.applysquare.*

    (echo "${GO_TOOLS}" | xargs -n 1 go ${go_install_command} -v )2>&1 | tee -a /usr/local/etc/vscode-dev-containers/go.log

    # Move Go tools into path and clean up
    mv /tmp/gotools/bin/* ${TARGET_GOPATH}/bin/
    echo "go-debial ssssssssssssss 13"
    # install dlv-dap (dlv@master)
    go ${go_install_command} -v github.com/go-delve/delve/cmd/dlv@master 2>&1 | tee -a /usr/local/etc/vscode-dev-containers/go.log
    mv /tmp/gotools/bin/dlv ${TARGET_GOPATH}/bin/dlv-dap
    echo "go-debial ssssssssssssss 14"   
    rm -rf /tmp/gotools
    chown -R ${USERNAME} "${TARGET_GOPATH}"
fi
echo "go-debial ssssssssssssss 15"
# Add GOPATH variable and bin directory into PATH in bashrc/zshrc files (unless disabled)
updaterc "$(cat << EOF
export GOPATH="${TARGET_GOPATH}"
if [[ "\${PATH}" != *"\${GOPATH}/bin"* ]]; then export PATH="\${PATH}:\${GOPATH}/bin"; fi
export GOROOT="${TARGET_GOROOT}"
if [[ "\${PATH}" != *"\${GOROOT}/bin"* ]]; then export PATH="\${PATH}:\${GOROOT}/bin"; fi
EOF
)"

echo "Done!"

