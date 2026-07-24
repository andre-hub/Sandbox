#!/bin/sh
# wsl-bootstrap.sh - runs inside the freshly installed WSL distribution.
# Idempotent: safe to re-run.
#
# Argument 1 (optional): absolute path to this directory as seen from WSL,
# e.g. /mnt/c/projects/sandbox.git/wsl. setup.bat passes it explicitly so
# the script does not need to guess its own location.

set -eu

setupDir="${1:-}"
if [ -z "$setupDir" ]; then
    setupDir="$(cd "$(dirname "$0")" && pwd)"
fi

. "$setupDir/scripts/common.sh"

print_header "WSL bootstrap"

# 1. Wait for apt to be free (some Ubuntu images run unattended-upgrades on first boot).
print_info "Waiting for apt locks to clear ..."
i=0
while sudo -n fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    i=$((i + 1))
    [ $i -gt 60 ] && { print_warning "apt still busy after 60s, continuing anyway"; break; }
    sleep 1
done

# 2. Update package index once.
print_info "Updating apt package index ..."
sudo apt-get update -qq

# 3. Install base tools.
sh "$setupDir/scripts/install-base-tools.sh"

# 4. Source config to know whether to chain into the Minikube installer.
configFile="$setupDir/../config.ini"
installMinikube=1
if [ -f "$configFile" ]; then
    cfg_value() { awk -F= -v key="$1" '$1 == key { sub(/^[ \t]+/, "", $2); sub(/[ \t]+$/, "", $2); print $2; exit }' "$configFile"; }
    val="$(cfg_value INSTALL_MINIKUBE)"
    [ -n "$val" ] && installMinikube="$val"
fi

if [ "$installMinikube" = "1" ]; then
    print_info "Chaining into Minikube installer (shell-scripts.git/minikube) ..."
    sh "$setupDir/scripts/ensure-shell-scripts.sh"
else
    print_info "INSTALL_MINIKUBE=0, skipping Minikube step."
fi

print_success "wsl-bootstrap finished"
