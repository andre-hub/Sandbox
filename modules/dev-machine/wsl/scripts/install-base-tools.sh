#!/bin/sh
# install-base-tools.sh - install a small, non-opinionated set of CLI tools
# inside the WSL distribution. Idempotent.

set -eu

scriptDir="$(cd "$(dirname "$0")" && pwd)"
. "$scriptDir/common.sh"

print_header "Installing base tools"

apt_install_missing \
    git \
    curl \
    ca-certificates \
    build-essential \
    jq \
    unzip \
    less

print_success "Base tools installed"
