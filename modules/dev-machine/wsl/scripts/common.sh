#!/bin/sh
# common.sh - colored output helpers and small utilities shared by the
# wsl bootstrap scripts. POSIX sh, no bashisms.

# Colors. Disabled when stdout is not a terminal so log files stay clean.
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

print_info()    { printf '%b[INFO]%b %s\n' "$BLUE"   "$NC" "$1"; }
print_success() { printf '%b[OK]%b   %s\n' "$GREEN"  "$NC" "$1"; }
print_warning() { printf '%b[!]%b    %s\n' "$YELLOW" "$NC" "$1"; }
print_error()   { printf '%b[ERROR]%b %s\n' "$RED"   "$NC" "$1" >&2; }
print_header()  { printf '\n%b== %s ==%b\n\n' "$GREEN" "$1" "$NC"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Run an apt-get install only for packages not already present.
apt_install_missing() {
    missing=""
    for pkg in "$@"; do
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
            missing="$missing $pkg"
        fi
    done
    if [ -n "$missing" ]; then
        # shellcheck disable=SC2086
        sudo apt-get install -y -q $missing
    fi
}
