#!/bin/bash

# SECTION - Pre-flight Checks and Setup

# Enforce root privileges, as `apt download` requires them.
# If not run as root, the script attempts to re-execute itself with sudo.
if [ "$EUID" -ne 0 ]; then
	echo "This script needs to be run with root privileges."
	echo "Attempting to re-run with sudo..."
	exec sudo "$0" "$@"
	exit 1 # Should not be reached if exec is successful
fi

# Check for essential command-line utilities and install them if they are missing.
# - whiptail: Used for creating the interactive user interface (menus, input boxes).
# - jq: A command-line JSON processor, used for parsing API responses from GitHub to find the latest release versions.
# - unzip: Used for extracting .zip archives, particularly for downloaded source code or assets.
if ! command -v whiptail &>/dev/null; then
	echo "whiptail is not installed. Please install it to run this script."
	echo "On Debian/Ubuntu: sudo apt-get install whiptail"
	exit 1
fi

# !SECTION - Pre-flight Checks and Setup - END OF THE SECTION

# SECTION - Core Function Definitions

# SECTION - FUN_SHOW_HELP
# Displays a detailed help page explaining the script's purpose, prerequisites,
# and menu options.
FUN_SHOW_HELP() {
	clear
	cat <<EOF
================================================================================
          Offline APT Package and Source Cache Creator - Detailed Help
================================================================================

[ 1. OVERVIEW ]

This script is an advanced utility designed to create a comprehensive, portable
offline software cache. Its primary purpose is to support the APT-AUTO-INSTALLS
project by downloading all software assets needed for a complete installation
on a machine that has NO internet connection.

It must be run on a Debian-based system (like Ubuntu) with a stable internet
connection. It will meticulously download packages, binaries, source code, and
other assets into a structured directory, which can then be transferred to
an offline machine.

--------------------------------------------------------------------------------

[ 2. PREREQUISITES ]

The script checks for these tools on the host machine before running.

  - sudo: Required for all APT operations, including adding repositories
    and downloading packages. The script will auto-elevate if not run as root.
  - whiptail: Provides the interactive menus and input boxes for the UI.
  - jq: A command-line JSON processor crucial for parsing version info from
    web APIs (e.g., getting the latest release from GitHub).
  - unzip: Used for extracting .zip archives, particularly for RetroArch cores
    and some GNOME Shell extensions.
  - software-properties-common: Provides the 'add-apt-repository' command,
    which is essential for adding the PPAs needed by this script.

The following tools are installed and removed automatically by the script if
they are needed for your selected task:
  - git: For cloning source code from repositories like GitHub and GitLab.
  - curl: The primary tool for downloading files and interacting with web APIs.
  - flatpak: Required on the host machine to build the offline Flatpak bundles.

--------------------------------------------------------------------------------

[ 3. USAGE ]

  - To view this help page:
    bash $0 --help

  - To run in interactive mode:
    bash $0

--------------------------------------------------------------------------------

[ 4. MENU OPTIONS IN DETAIL ]

  - APT_PKGS: Downloads a curated list of over 100 Debian packages (.deb)
    and, critically, all of their dependencies. It temporarily adds five
    Personal Package Archives (PPAs) for software like 'mkusb' and 'cubic'.

  - OTHER_SOURCES: Downloads a wide variety of assets that are not in the
    standard APT repositories. This includes:
    * VirtualBox: Fetches the latest 7.x version, its Extension Pack, and
      Guest Additions ISO directly from Oracle's repository.
    * Binaries: Downloads tools like scrcpy, fastfetch, and Google Chrome.
    * Source Code: Clones Git repositories for several GNOME extensions.

  - GAMING_SOURCES: Creates a comprehensive offline gaming environment.
    * Clones the full source code for the Dolphin Emulator.
    * Builds offline-installable Flatpak bundles for Ryujinx, PPSSPP, and
      RetroArch. This includes bundling the required Freedesktop runtimes,
      making the bundles truly self-contained.
    * Downloads and extracts specific RetroArch cores (e.g., mGBA, Mupen64Plus)
      from the Libretro buildbot.

  - VSCODE_BUNDLE: Creates a complete offline installation for VSCode.
    * Downloads the official VSCode .deb package.
    * Downloads over 20 popular extensions (like GitLens, Prettier, etc.) as
      individual .vsix files for easy offline installation.
    * Fetches key binaries required by extensions, such as 'shfmt'.

  - ANTIGRAVITY_BUNDLE: Creates an offline-ready bundle for the Google Antigravity CLI.
    * Downloads the official install.sh script.
    * Downloads the native Go binary for offline installation.

  - COPY_LOCAL: Copies files from your local APT-AUTO-INSTALLS project
    directory into the cache. This is for project-specific assets like custom
    scripts, themes, configs, and videos.

  - ALL_NO_ARCHIVE / ALL_AND_ARCHIVE: Convenience options to run all of the
    above tasks sequentially. 'ALL_AND_ARCHIVE' will additionally prompt you
    to create a single, compressed .tar file of the entire cache.

  - HELP: Displays this detailed help page.

  - EXIT: Exits the script without performing any actions.

--------------------------------------------------------------------------------

[ 5. CACHE DIRECTORY STRUCTURE ]

The final output directory you choose will be organized as follows:

  DEST_DIR/
  ├── deb_packages/         # Contains all .deb files and their dependencies.
  ├── other_sources/
  │   ├── virtualbox_deb/   # VirtualBox .deb, Extension Pack, Guest Additions.
  │   ├── vscode_extensions/ # All .vsix extension files.
  │   ├── shfmt/            # Binaries for VSCode dependencies.
  │   └── ...               # scrcpy, Google Chrome .deb, etc.
  ├── gaming_sources/
  │   ├── flatpaks/         # All .flatpak offline bundle files.
  │   ├── RETROARCH-CORES/  # All .so emulator core files.
  │   └── dolphin-emu/      # Cloned source code for Dolphin.
  ├── antigravity_cli_bundle/    # Antigravity CLI installer and native binary.
  ├── theme_configs/        # Copied local theme files.
  ├── custom_scripts/       # Copied local script files.
  └── ...                   # Other copied local directories.

--------------------------------------------------------------------------------

[ 6. HOW TO USE THE CACHE OFFLINE ]

Once you transfer the cache to the target machine, you can install software:

  - For APT Packages:
    sudo apt install -y /path/to/cache/deb_packages/*.deb

  - For VSCode Extensions:
    code --install-extension /path/to/cache/other_sources/vscode_extensions/*.vsix

  - For Flatpak Bundles:
    flatpak install --bundle /path/to/cache/gaming_sources/flatpaks/*.flatpak

--------------------------------------------------------------------------------

[ 7. IMPORTANT CONSIDERATIONS ]

  - NETWORK DEPENDENCY: The script's success is 100% dependent on a stable
    internet connection and the availability of dozens of external services
    (GitHub, PPAs, Flathub, etc.). A failure in any one of these can interrupt
    the script.

  - VSCODE EXTENSION FRAGILITY: The VSCode extension downloader relies on
    scraping the marketplace website. This is inherently fragile and MAY
    BREAK without warning if the website's design is updated. The script has
    been updated to provide detailed debug logs to help identify such failures.

================================================================================
EOF
	read -r -s -p "press ENTER to Continue...."
}
# !SECTION - FUN_SHOW_HELP - END OF THE SECTION

# SECTION - FUN_GET_DESTINATION_DIR
# Prompts the user to specify the absolute path where the offline cache will be stored.
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")
# $_SCRIPT_DIR_ROOT/.. means "go N... levels up from $_SCRIPT_DIR_ROOT"
_SCRIPT_DIR_ROOT=$(realpath "$SCRIPT_DIR/../../..")

FUN_GET_DESTINATION_DIR() {
	# Use whiptail to get user input, providing the current directory as a default.
	DEST_DIR=$(whiptail --inputbox "Enter the absolute path for the offline cache directory:" 0 0 "$_SCRIPT_DIR_ROOT/APT_OFFLINE_CACHE" --title "Cache Destination" 3>&1 1>&2 2>&3)
	# Exit if the user cancels.
	if [ -z "$DEST_DIR" ]; then
		echo "Operation cancelled."
		exit 0
	fi
	# Create the offline cache Directory.
	sudo mkdir -p "$DEST_DIR"
	sudo chmod -R 777 "$DEST_DIR"

	# # Create the necessary subdirectories within the cache.
	# mkdir -p "$DEST_DIR/other_sources"
	# sudo chmod -R 777 "$DEST_DIR/other_sources"
	echo "Cache will be created in: $DEST_DIR"
}
# !SECTION - FUN_GET_DESTINATION_DIR - END OF THE SECTION

# !SECTION - Core Function Definitions - END OF THE SECTION

# SECTION - Main Execution Logic
# Display the main menu to the user in a loop.
while true; do
	CHOICE_CACHE=$(
		whiptail --title "Cache Creation" --menu "What would you like to do?" 0 0 12 \
			"APT_PKGS" "Download APT packages only" \
			"OTHER_SOURCES" "Download other sources only (NO VSCODE)" \
			"GAMING_SOURCES" "Download Gaming sources only" \
			"VSCODE_BUNDLE" "Create VSCode offline bundle only" \
			"ANTIGRAVITY_BUNDLE" "Create Antigravity CLI offline bundle" \
			"OLLAMA_BUNDLE" "Create Ollama offline bundle (installer + binary)" \
			"LLAMA_CPP_BUNDLE" "Create Llama.cpp offline bundle" \
			"COPY_LOCAL" "Copy local project files only" \
			"ALL_NO_ARCHIVE" "Download EVERYTHING (no archive)" \
			"ALL_AND_ARCHIVE" "Download EVERYTHING & tar archive" \
			"HELP" "Display Help" \
			"EXIT" "Exit" 3>&1 1>&2 2>&3
	)

	# Exit if the user presses Esc or Cancel
	if [ -z "$CHOICE_CACHE" ] || [ "$CHOICE_CACHE" == "EXIT" ]; then
		echo "Operation cancelled."
		exit 0
	elif [ "$CHOICE_CACHE" == "COPY_LOCAL" ]; then
		FUN_GET_DESTINATION_DIR
		bash -c "$SCRIPT_DIR/CREATE_OFFLINE_CACHE_LIB.bash \"$CHOICE_CACHE\" \"$DEST_DIR\" \"$_DEBOOTSTRAP_MODE\""
		exit
	elif [ "$CHOICE_CACHE" == "HELP" ]; then
		FUN_SHOW_HELP
		continue
	elif [ "$CHOICE_CACHE" != "HELP" ] && [ "$CHOICE_CACHE" != "EXIT" ]; then
		break
	fi

done

# get cache directory to download to
FUN_GET_DESTINATION_DIR

# Ask user if [Running inside debootstrap / minimal chroot] OR [Running on a normally installed and booted Ubuntu host]
_DEBOOTSRAP_OR_BARE_METAL=$(whiptail --title "Execution Environment" --menu "run INSIDE a debootstrap/chroot environment?\n\n(Choose \"No\" if you are running it directly on a fully installed Ubuntu system)" 0 0 3 \
	YES "DEEBOTSTRAP MODE ●─● run INSIDE a debootstrap/chroot environment" \
	NO "HOST BARE-METAL ●─● run DIRECTLY under HOST Ubuntu system" \
	EXIT "EXIT" 3>&1 1>&2 2>&3)
case $_DEBOOTSRAP_OR_BARE_METAL in
YES)
	_DEBOOTSTRAP_MODE=1
	;;
NO)
	_DEBOOTSTRAP_MODE=0
	;;
EXIT | *)
	exit
	;;
esac

_UBUNTU_CODENAME=$(grep ^UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '[:space:]')

# handle deebotrap / chroot envoronment or if running directly bare metal under HOST OS
if [ $_DEBOOTSTRAP_MODE -eq 1 ]; then
	# check if debootstrap is installed & try to install if not already
	if ! command -v debootstrap >/dev/null; then
		echo "debootsrap not installed!! will attempt to install."
		sudo apt update
		sudo apt install -y debootstrap
		if ! command -v debootstrap; then
			echo "debootstrap not installed. Aborting !"
			exit 1
		fi
	fi

	# execute commands that can only be run under host OS here before continuing [when debootstra=1 (will enter chroot)]
	bash -c "$SCRIPT_DIR/CREATE_OFFLINE_CACHE_HOST_OS_COMMANDS_LIB.bash \"$CHOICE_CACHE\" \"$DEST_DIR\" \"$_DEBOOTSTRAP_MODE\""

	# continue preparing debootstrap environment
	if [ ! -d "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}" ]; then
		sudo mkdir -p "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}"
		sudo chmod -R 777 "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}"
		sudo debootstrap "${_UBUNTU_CODENAME}" "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}" http://archive.ubuntu.com/ubuntu/
	fi
	if [ -d "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}" ]; then
		_DEBOOTSTRAP_DIR_COPY=/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}-$(date +"%Y-%m-%d_TIME_%H_%M_%S")
		sudo nice -n 10 ionice -c 2 -n 7 cp -avr "/bin/CUSTOM-DEBOOTSTRAP/DEEBOTSTRAP-DIR-ENV-${_UBUNTU_CODENAME}" "$_DEBOOTSTRAP_DIR_COPY" >/dev/null
		sync

		# Prep chroot environment  -- Mount essential pseudo-filesystems & bind mount the dir of CACHE DOWNLOAD to special location in the chroot
		sudo mount --bind /dev "${_DEBOOTSTRAP_DIR_COPY}/dev"
		sudo mount --bind /dev/pts "${_DEBOOTSTRAP_DIR_COPY}/dev/pts"
		sudo mount --bind /proc "${_DEBOOTSTRAP_DIR_COPY}/proc"
		sudo mount --bind /sys "${_DEBOOTSTRAP_DIR_COPY}/sys"

		_CACHE_DOWNLOAD_TEMP_DIR_BIND_MNT=$(sudo mktemp -d "${_DEBOOTSTRAP_DIR_COPY}/tmp/CACHE_DOWNLOAD.XXXXXX")
		_CACHE_DOWNLOAD_TEMP_DIR_IN_CHROOT=$(basename "$_CACHE_DOWNLOAD_TEMP_DIR_BIND_MNT" | sed 's+^+/tmp/+g')
		sudo mount --bind "$DEST_DIR" "$_CACHE_DOWNLOAD_TEMP_DIR_BIND_MNT"

		# Copy DNS resolution so apt works: usually unecessary, but its canonical correct way
		sudo cp /etc/resolv.conf "${_DEBOOTSTRAP_DIR_COPY}/etc/"

		# Copy executable cahce_downloader to /tmp dir in chroot target
		if command -v install >/dev/null; then
			sudo install -m 777 $SCRIPT_DIR/CREATE_OFFLINE_CACHE_LIB.bash ${_DEBOOTSTRAP_DIR_COPY}/tmp
		else
			sudo cp -vr $SCRIPT_DIR/CREATE_OFFLINE_CACHE_LIB.bash ${_DEBOOTSTRAP_DIR_COPY}/tmp
		fi
		# Enter the CHROOT
		sudo chroot "${_DEBOOTSTRAP_DIR_COPY}" /bin/bash -c "/tmp/CREATE_OFFLINE_CACHE_LIB.bash \"$CHOICE_CACHE\" \"$_CACHE_DOWNLOAD_TEMP_DIR_IN_CHROOT\" \"$_DEBOOTSTRAP_MODE\""

		# UNMOUNT CHROOT RESOURCES SAFELY
		# SECTION - FUN_SAFE_UNMOUNT
		# 🎀 safe_umount() — Ultra-reliable unmount helper (kawaii + robust)
		# ---------------------------------------------------------------
		# Ensures a target mount point is fully unmounted.
		# Features:
		#   • Skips cleanly if the path is not a mountpoint.
		#   • Retries normal unmount several times (for slow or busy releases).
		#   • Falls back to lazy unmount (-l) after repeated failures.
		#   • Final verification ensures the mount is gone.
		#
		# Notes:
		#   • Designed for chroot tear-down: bind mounts, /proc, /sys, /dev, /dev/pts.
		#   • Uses mountpoint(1) for accurate detection.
		#   • MAX_TRIES determines strictness vs. patience.
		# ---------------------------------------------------------------
		FUN_SAFE_UNMOUNT() {
			local TARGET="$1"
			local MAX_TRIES=10
			local i=0
			# 🎀 Skip if it's not mounted (avoids redundant umount errors)
			mountpoint -q "$TARGET" || return 0
			echo "Attempting secure unmount of: $TARGET"
			# 🎀 Retry loop — gives services/processes time to release handles
			while mountpoint -q "$TARGET"; do
				if [ "$i" -ge "$MAX_TRIES" ]; then
					# 🎀 Emergency fallback: lazy unmount ensures detachment
					echo "⚠️ $TARGET still mounted after $MAX_TRIES tries — applying lazy umount"
					sudo umount -l "$TARGET" 2>/dev/null
					break
				fi
				# 🎀 Primary unmount attempt
				sudo umount "$TARGET" 2>/dev/null
				sleep 0.3 # Small delay helps with cleanup timing
				i=$((i + 1))
			done
			# 🎀 Final verification — confirms success or alerts failure
			if mountpoint -q "$TARGET"; then
				echo "❌ ERROR: Failed to unmount $TARGET (even after fallback)"
				return 1
			else
				echo "✔️ Unmounted: $TARGET"
				return 0
			fi
		}
		# !SECTION - FUN_SAFE_UNMOUNT - END OF THE SECTION
		sync
		FUN_SAFE_UNMOUNT "${_CACHE_DOWNLOAD_TEMP_DIR_BIND_MNT}"
		FUN_SAFE_UNMOUNT "${_DEBOOTSTRAP_DIR_COPY}"/dev/pts
		FUN_SAFE_UNMOUNT "${_DEBOOTSTRAP_DIR_COPY}"/dev
		FUN_SAFE_UNMOUNT "${_DEBOOTSTRAP_DIR_COPY}"/proc
		FUN_SAFE_UNMOUNT "${_DEBOOTSTRAP_DIR_COPY}"/sys
		sync

		# remove the copy of the bootstrap dir only if theres nothing mounted to it
		mountpoint "$_DEBOOTSTRAP_DIR_COPY" || {
			echo "Safely (nothing mounted to it) Deleting $_DEBOOTSTRAP_DIR_COPY "
			sudo rm -rf "$_DEBOOTSTRAP_DIR_COPY"
		}

		# sudo umount ${_CACHE_DOWNLOAD_TEMP_DIR_BIND_MNT}
		# sudo umount ${_DEBOOTSTRAP_DIR_COPY}/dev/pts
		# sudo umount ${_DEBOOTSTRAP_DIR_COPY}/dev
		# sudo umount ${_DEBOOTSTRAP_DIR_COPY}/proc
		# sudo umount ${_DEBOOTSTRAP_DIR_COPY}/sys

		exit
	fi
elif [ $_DEBOOTSTRAP_MODE -eq 0 ]; then

	bash -c "$SCRIPT_DIR/CREATE_OFFLINE_CACHE_LIB.bash $CHOICE_CACHE $DEST_DIR"

fi
# !SECTION - Main Execution Logic - END OF THE SECTION
