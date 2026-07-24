#!/bin/sh
# ensure-shell-scripts.sh - guarantee that shell-scripts.git is available
# at SHELL_SCRIPTS_PATH and run the Minikube installer plus the start
# helper from minikube/. Idempotent.
#
# Reads SHELL_SCRIPTS_REPO_URL and SHELL_SCRIPTS_PATH from the parent config.ini.

set -eu

scriptDir="$(cd "$(dirname "$0")" && pwd)"
wslDir="$(cd "$scriptDir/.." && pwd)"
. "$scriptDir/common.sh"

configFile="$wslDir/../config.ini"
[ -f "$configFile" ] || { print_error "config.ini not found at $configFile"; exit 1; }

cfg_value() { awk -F= -v key="$1" '$1 == key { sub(/^[ \t]+/, "", $2); sub(/[ \t]+$/, "", $2); print $2; exit }' "$configFile"; }

repoUrl="$(cfg_value SHELL_SCRIPTS_REPO_URL)"
repoPath="$(cfg_value SHELL_SCRIPTS_PATH)"
case "$repoPath" in
    '\$HOME/'*) repoPath="$HOME/${repoPath#\$HOME/}" ;;
    '~/'*) repoPath="$HOME/${repoPath#\~/}" ;;
esac

[ -n "$repoUrl" ]  || { print_error "SHELL_SCRIPTS_REPO_URL is empty in config.ini"; exit 1; }
[ -n "$repoPath" ] || { print_error "SHELL_SCRIPTS_PATH is empty in config.ini"; exit 1; }

if [ ! -d "$repoPath/.git" ]; then
    print_info "Cloning shell-scripts.git into $repoPath ..."
    mkdir -p "$(dirname "$repoPath")"
    git clone "$repoUrl" "$repoPath"
else
    print_info "shell-scripts.git already present at $repoPath, fetching updates ..."
    git -C "$repoPath" fetch --quiet || print_warning "git fetch failed - continuing with local copy"
fi

minikubeDir="$repoPath/minikube"
[ -d "$minikubeDir" ] || { print_error "minikube/ not found in $repoPath - check the cloned branch"; exit 1; }

installer="$minikubeDir/debian/install-minikube.sh"
starter="$minikubeDir/common/start-minikube.sh"

if [ -f "$installer" ]; then
    print_info "Running $installer ..."
    sh "$installer"
else
    print_warning "$installer not found - skipping Minikube install"
fi

if [ -f "$starter" ]; then
    print_info "Running $starter ..."
    sh "$starter"
else
    print_warning "$starter not found - skipping Minikube start"
fi

print_success "shell-scripts.git is ready"
