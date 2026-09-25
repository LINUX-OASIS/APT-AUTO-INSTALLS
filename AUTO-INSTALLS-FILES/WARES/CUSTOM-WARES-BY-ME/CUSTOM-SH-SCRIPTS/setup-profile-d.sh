#!/bin/bash
# Script 2: For /etc/profile.d/
# This script is designed to be moved to /etc/profile.d/custom-paths.sh
# It uses an idempotent function to keep the PATH clean.

add_to_path() {
	if [ -d "$1" ]; then
		case ":${PATH}:" in
		*":$1:"*) ;; # Already in PATH
		*) export PATH="${PATH:+"$PATH:"}$1" ;;
		esac
	fi
}

# Add desired directories
add_to_path "/usr/local/go/bin"
add_to_path "/bin/CUSTOM-SH-SCRIPTS"

# Clean up the function to keep the shell environment tidy
unset -f add_to_path
