#!/bin/bash

# ==================================================================================================
#
#                    Total Offline GNOME/MATE Cache Installer (Overhauled)
#
# This script provides a comprehensive, menu-driven interface for installing a complete system
# configuration from a pre-created offline cache. It is a direct port of the online installer's
# functionality, adapted to work in a fully offline environment.
#
# ==================================================================================================

# --- SCRIPT INITIALIZATION ---

# Enforce root privileges. The script will attempt to re-run itself with sudo if not already root.
if [ "$EUID" -ne 0 ]; then
	echo "This script needs to be run with root privileges. Re-running with sudo..."
	exec sudo "$0" "$@"
	exit 1
fi

# Check for essential commands required for the installer to function.
# If a command is missing, it attempts to install it from the cached .deb packages
# before exiting, ensuring a self-sufficient installation process.
for cmd in whiptail dpkg apt 7z tar; do
	if ! command -v "$cmd" &>/dev/null; then
		echo "Error: Required command '$cmd' is not installed. The base system may be missing essential tools."
		# Attempt to install critical tools from the cache itself if available.
		# This uses dpkg directly to install individual .deb packages for core utilities.
		if [ -d "$CACHE_DIR/apt_packages_bundle" ]; then
			echo "Attempting to install missing tool '$cmd' from apt_packages_bundle..."
			# The '|| true' prevents the script from exiting if a specific .deb isn't found/installed.
			dpkg -i "$CACHE_DIR/apt_packages_bundle/whiptail*.deb" 2>/dev/null || true
			dpkg -i "$CACHE_DIR/apt_packages_bundle/p7zip*.deb" 2>/dev/null || true
			dpkg -i "$CACHE_DIR/apt_packages_bundle/tar*.deb" 2>/dev/null || true
		fi
		# Re-check if the command is now available after the attempted installation from cache.
		if ! command -v "$cmd" &>/dev/null; then
			echo "Fatal Error: '$cmd' is still not found after attempting installation from cache. Aborting."
			exit 1
		fi
	fi
done

# --- GLOBAL VARIABLES & HELPER FUNCTIONS ---

# Determine the target user and their home directory.
# This ensures installations are correctly configured for the user who initiated the script.
if [ -n "$SUDO_USER" ]; then
	TARGET_USER="$SUDO_USER" # User who invoked sudo.
else
	TARGET_USER="$(logname)" # Current logged-in user if not using sudo.
fi
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6) # Get the home directory for the target user.
CD_DIRNAME=$(dirname "$(realpath "$0")")                  # Absolute path to the directory where this script resides.

# Define ANSI color codes for enhanced terminal output.
declare -A COLORS=(
	[RESET]="\033[0m"   # Reset all attributes to default.
	[BOLD]="\033[1m"    # Bold text.
	[GREEN]="\033[32m"  # Green foreground.
	[YELLOW]="\033[93m" # Yellow foreground.
)

# Function: FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
# Description: Displays a verbose installation message using specific colors.
# Parameters:
#   $1 - The message to display (e.g., "Package Name").
FUN_VERBOSE_INSTALLING_NO_APT_UPDATE() {
	echo "" >&2
	tput setab 7 >&2  # Set background color to white.
	tput setaf 18 >&2 # Set foreground color to black.
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $1 _-_-_-_-_-_-_-_-_-_-_-" >&2
	tput sgr0 >&2 # Reset text attributes.
}

# Function: FUN_CHOICE_BLOCK_INDICATOR
# Description: Displays a prominent, block-style indicator for major installation steps.
# Parameters:
#   $1 - The message to display (e.g., "Configuring System Settings").
FUN_CHOICE_BLOCK_INDICATOR() {
	echo "" >&2
	tput setab 112 >&2 # Set background color to a specific shade.
	tput setaf 234 >&2 # Set foreground color to a specific shade.
	tput bold >&2      # Set bold text.
	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_." >&2
	echo -e "\n-_-_-_-_-_-_-_-_-_-_-_ Installing $1 _-_-_-_-_-_-_-_-_-_-_- \n" >&2
	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_." >&2
	tput sgr0 >&2 # Reset text attributes.
}

# Function: get_cache_dir
# Description: Prompts the user to provide the absolute path to the offline cache directory.
# This directory is crucial as all subsequent installations rely on its content.
get_cache_dir() {
	_SCRIPT_DIR_ROOT=$(realpath "$CD_DIRNAME/../../..") # Determine the project root dynamically.
	CACHE_DIR=$(whiptail --inputbox "Enter the absolute path of the offline cache directory:" 10 78 "$_SCRIPT_DIR_ROOT/APT_OFFLINE_CACHE" --title "Cache Location" 3>&1 1>&2 2>&3)
	# Exit if the user cancels the input or provides an invalid/non-existent directory.
	if [ -z "$CACHE_DIR" ] || [ ! -d "$CACHE_DIR" ]; then
		whiptail --title "Error" --msgbox "Operation cancelled or cache directory not found. Please ensure the path is correct." 8 78
		exit 0
	fi
}

####################################################################################################
#
# `FUN_WARES_FOR_GNOME_AND_MATE_DE_FROM_CACHE` - Core Offline Installation Function
#
# Description: This is the main function that orchestrates the entire offline installation process.
#              It adapts the logic of the online installer (`FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB`)
#              by ensuring all commands use local files exclusively from the provided offline cache.
#
####################################################################################################
function FUN_WARES_FOR_GNOME_AND_MATE_DE_FROM_CACHE {
	# Keep the sudo session alive during potentially long installation processes.
	# A background process runs `sudo -n true` periodically to refresh the sudo timestamp,
	# preventing it from expiring and prompting the user multiple times.
	sudo -v
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$ " || exit # Exit if the parent script (this one) is no longer running.
	done 2>/dev/null &
	SUDO_KEEPALIVE_PID=$! # Store the PID of the background sudo keep-alive process.

	local WORKER_TEMP
	WORKER_TEMP=$(mktemp -d)    # Create a unique temporary directory for intermediate files and extractions.
	chmod -R 777 "$WORKER_TEMP" # Ensure full permissions for the worker directory.

	# --- 1. Install ALL cached APT packages at once ---

	FUN_CHOICE_BLOCK_INDICATOR "Installing All Cached APT Packages"

	# Pre-seed debconf selections to avoid interactive prompts during installation.

	# These settings are critical for headless or automated installations.

	echo refind refind/install_to_esp boolean false | sudo debconf-set-selections

	echo macchanger macchanger/automatically_run boolean false | sudo debconf-set-selections

	echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

	echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections

	# Attempt to install all .deb packages found across various cache subdirectories.

	# `--force-depends` is used to allow `dpkg` to proceed even if dependencies are not

	# perfectly ordered in the command, as `apt-get -f install` will resolve them later.

	# This consolidates installation of .deb files from:

	# - `apt_packages_bundle`: Standard APT packages.

	# - `other_sources_bundle/fastfetch`: Fastfetch .deb.

	# - `other_sources_bundle/virtualbox`: VirtualBox .deb.

	# - `other_sources_bundle/vscode`: VSCode .deb.

	# - `other_sources_bundle/google_chrome`: Google Chrome .deb.

	# - `gaming_bundle/dependencies/flatpak_installer_debs`: Flatpak installer .deb.

	# - `gaming_bundle/dependencies/dolphin_build_deps`: Dolphin build dependencies .debs.

	sudo dpkg -i --force-depends "$CACHE_DIR/apt_packages_bundle/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/other_sources_bundle/fastfetch/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/other_sources_bundle/virtualbox/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/other_sources_bundle/vscode/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/other_sources_bundle/google_chrome/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/gaming_bundle/dependencies/flatpak_installer_debs/"*.deb

	sudo dpkg -i --force-depends "$CACHE_DIR/gaming_bundle/dependencies/dolphin_build_deps/"*.deb || sudo apt-get -f install -y

	# Run `apt-get -f install` again to ensure all dependencies are met and fix any broken packages

	# that might have resulted from the `--force-depends` or package order.

	sudo apt-get -f install -y # Fix any remaining dependency issues

	# --- 2. Install Binaries, Installers, and Other Sources from Cache ---
	# Define paths to various bundle directories within the main cache for easier access.
	local OTHER_SOURCES_DIR="$CACHE_DIR/other_sources_bundle"
	local GAMING_BUNDLE_DIR="$CACHE_DIR/gaming_bundle"
	local LOCAL_FILES_BUNDLE_DIR="$CACHE_DIR/local_files_bundle"

	# Install Charmbracelet Tools (gum, vhs) - extracted from tar.gz archives.
	FUN_CHOICE_BLOCK_INDICATOR "Installing Charmbracelet Tools (gum, vhs)"
	for archive in "$OTHER_SOURCES_DIR/charmbracelets/"*.tar.gz; do
		tar -xvf "$archive" -C "$WORKER_TEMP" # Extract the tar.gz archive to the temporary worker directory.
		# Find the extracted 'gum' or 'vhs' binary and copy it to a system-wide PATH location (/usr/local/bin).
		find "$WORKER_TEMP" -type f \( -name "gum" -o -name "vhs" \) -exec sudo cp {} /usr/local/bin/ \;
		rm -rf "$WORKER_TEMP"/* # Clean up temporary files after processing.
	done

	# Install scrcpy - extracts from a cached tar.gz archive and copies binaries.
	FUN_CHOICE_BLOCK_INDICATOR "Installing scrcpy"
	local SCRCPY_ARCHIVE
	SCRCPY_ARCHIVE=$(find "$OTHER_SOURCES_DIR/scrcpy/" -name "scrcpy-linux-x86_64-*.tar.gz" 2>/dev/null | head -n1)
	if [ -f "$SCRCPY_ARCHIVE" ]; then
		# Extract the scrcpy archive to the temporary worker directory.
		tar xf "$SCRCPY_ARCHIVE" -C "$WORKER_TEMP"
		local EXTRACTED_DIR
		EXTRACTED_DIR=$(find "$WORKER_TEMP" -mindepth 1 -maxdepth 1 -type d) # Find the extracted version-specific directory.
		# Copy scrcpy binaries to a system-wide PATH location.
		sudo cp -f "$EXTRACTED_DIR/scrcpy" /usr/local/bin/
		sudo cp -f "$EXTRACTED_DIR/scrcpy-server" /usr/local/bin/
		sudo chmod 755 /usr/local/bin/scrcpy /usr/local/bin/scrcpy-server # Ensure executables have correct permissions.
		rm -rf "$WORKER_TEMP"/*                                           # Clean up temporary files.
	fi

	# Install Genymotion - runs the cached .run installer.
	FUN_CHOICE_BLOCK_INDICATOR "Installing Genymotion"
	local GENYMOTION_INSTALLER
	GENYMOTION_INSTALLER=$(find "$OTHER_SOURCES_DIR/genymotion/" -name "genymotion-*-linux_x64.run" 2>/dev/null | head -n1)
	if [ -f "$GENYMOTION_INSTALLER" ]; then
		chmod +x "$GENYMOTION_INSTALLER" # Make the installer executable.
		sudo "$GENYMOTION_INSTALLER" -y  # Run the installer in non-interactive mode (`-y` for yes to prompts).
	fi

	# Configure Google Chrome Policies - copies the policy file and patches the executable.
	FUN_CHOICE_BLOCK_INDICATOR "Configuring Google Chrome Policies"
	sudo mkdir -p /etc/opt/chrome/policies/managed # Create policy directory if it doesn't exist.
	# Copy the cached extension policy JSON file (`auto_extensions.json`) to the Chrome managed policies directory.
	sudo cp "$OTHER_SOURCES_DIR/google_chrome/auto_extensions.json" /etc/opt/chrome/policies/managed/
	# Patch the Google Chrome executable. This `sed` command modifies the `Exec` line in the Chrome launcher
	# to include `--user-data-dir`, `--test-type`, and `--no-sandbox` flags. This is often necessary for
	# Chrome to run correctly in specialized environments or when invoked by root.
	sudo sed -i 's+exec -a "$0" "$HERE/chrome" "$@"+exec -a "$0" "$HERE/chrome" "$@" --user-data-dir --test-type --no-sandbox+g' /opt/google/chrome/google-chrome

	# Install Ollama - deploys the cached binary and sets up a systemd service.
	FUN_CHOICE_BLOCK_INDICATOR "Installing Ollama"
	# Checks for the presence of the cached install script (as a marker that Ollama was bundled).
	if [ -f "$OTHER_SOURCES_DIR/ollama_bundle/install.sh" ]; then
		# The cached install.sh from ollama.com is usually for online installation.
		# For offline, we adapt by directly installing the binary and setting up the systemd service.
		local OLLAMA_ARCHIVE="$OTHER_SOURCES_DIR/ollama_bundle/ollama-linux-amd64.tgz" # Path to the cached Ollama binary archive.
		if [ -f "$OLLAMA_ARCHIVE" ]; then
			tar -xvf "$OLLAMA_ARCHIVE" -C "$WORKER_TEMP"        # Extract the binary from the tarball.
			sudo cp "$WORKER_TEMP/ollama" /usr/local/bin/ollama # Copy binary to a system-wide PATH location.
			# Create a dedicated system user for Ollama for security and service management.
			sudo useradd -r -s /bin/false -m -d /usr/share/ollama ollama
			# Create and enable the systemd service for Ollama to run at boot.
			echo "[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/ollama.service # Write the systemd unit file.
			sudo systemctl daemon-reload                                        # Reload systemd to recognize the new service.
			sudo systemctl enable ollama                                        # Enable the service to start on boot.
			sudo systemctl start ollama                                         # Start the Ollama service immediately.
		fi
	fi

	# Install Llama.cpp - deploys the cached binary.
	FUN_CHOICE_BLOCK_INDICATOR "Installing Llama.cpp"
	local LLAMA_CPP_ARCHIVE
	LLAMA_CPP_ARCHIVE=$(find "$OTHER_SOURCES_DIR/llama_cpp_bundle/" -name "llama-*-bin-ubuntu-x64.zip" 2>/dev/null | head -n1)
	if [ -f "$LLAMA_CPP_ARCHIVE" ]; then
		# Extract the llama.cpp archive to the temporary worker directory.
		unzip -q "$LLAMA_CPP_ARCHIVE" -d "$WORKER_TEMP/llama_cpp"
		# Copy llama.cpp binaries to a system-wide PATH location.
		sudo cp -f "$WORKER_TEMP/llama_cpp/"* /usr/local/bin/ 2>/dev/null || true
		sudo chmod 755 /usr/local/bin/llama-* /usr/local/bin/server 2>/dev/null || true # Ensure executables have correct permissions.
		rm -rf "$WORKER_TEMP"/*                                                         # Clean up temporary files.
	fi

	# Install VirtualBox Extras (Extension Pack and Guest Additions)
	FUN_CHOICE_BLOCK_INDICATOR "Installing VirtualBox Extras"
	local VBOX_EXTPACK
	VBOX_EXTPACK=$(find "$OTHER_SOURCES_DIR/virtualbox/" -name "*.vbox-extpack" 2>/dev/null | head -n1)
	if [ -f "$VBOX_EXTPACK" ] && command -v VBoxManage &>/dev/null; then
		# Install the VirtualBox Extension Pack from the cached file. Requires `VBoxManage` to be available.
		yes | sudo VBoxManage extpack install "$VBOX_EXTPACK"
	fi
	local VBOX_GUEST_ISO
	VBOX_GUEST_ISO=$(find "$OTHER_SOURCES_DIR/virtualbox/" -name "VBoxGuestAdditions_*.iso" 2>/dev/null | head -n1)
	if [ -f "$VBOX_GUEST_ISO" ]; then
		# Ensure the VirtualBox share directory exists and copy the Guest Additions ISO.
		sudo mkdir -p /usr/share/virtualbox/
		sudo cp "$VBOX_GUEST_ISO" /usr/share/virtualbox/VBoxGuestAdditions.iso
	fi
	# Add the current target user to the 'vboxusers' group for VirtualBox access.
	sudo usermod -aG vboxusers "$TARGET_USER"

	# Configure VSCode - installs extensions, backend tools, and sets up autostart configurations.
	FUN_CHOICE_BLOCK_INDICATOR "Configuring VSCode"
	# Proceed only if 'code' command is available (meaning VSCode .deb was successfully installed earlier).
	if command -v code &>/dev/null; then
		# Install all cached .vsix extensions for the target user.
		for ext_vsix in "$OTHER_SOURCES_DIR/vscode/extensions/"*.vsix; do
			# `--no-sandbox` and `--user-data-dir` are used for robust installation, especially in root contexts.
			sudo -u "$TARGET_USER" code --no-sandbox --user-data-dir "$TARGET_HOME/.config/Code" --install-extension "$ext_vsix"
		done

		# Copy VSCode backend binaries (shfmt, shellcheck) to their respective extension directories.
		local SHFMT_BIN
		SHFMT_BIN=$(find "$OTHER_SOURCES_DIR/vscode/dependencies/" -name "shfmt_*_linux_amd64" | head -n1)
		if [ -f "$SHFMT_BIN" ]; then
			# Find the installed 'lumirelle.shell-format-rev' extension directory for the target user.
			LUMIRELL_DIR=$(find "$TARGET_HOME/.vscode/extensions" -type d -name "lumirelle.shell-format-rev-*" | head -n 1)
			if [ -d "$LUMIRELL_DIR" ]; then
				sudo -u "$TARGET_USER" mkdir -p "$LUMIRELL_DIR/bin"
				sudo -u "$TARGET_USER" cp "$SHFMT_BIN" "$LUMIRELL_DIR/bin/"
				sudo -u "$TARGET_USER" chmod +x "$LUMIRELL_DIR/bin/"* # Make the copied binary executable.
			fi
		fi
		local SHELLCHECK_ARCHIVE
		SHELLCHECK_ARCHIVE=$(find "$OTHER_SOURCES_DIR/vscode/dependencies/" -name "shellcheck-*.tar.xz" | head -n1)
		if [ -f "$SHELLCHECK_ARCHIVE" ]; then
			# Extract shellcheck binary from its archive to the temporary worker directory.
			tar -xf "$SHELLCHECK_ARCHIVE" -C "$WORKER_TEMP"
			# Find the installed 'timonwong.shellcheck' extension directory for the target user.
			TIMONWONG_DIR=$(find "$TARGET_HOME/.vscode/extensions" -type d -name "timonwong.shellcheck-*" | head -n 1)
			if [ -d "$TIMONWONG_DIR" ]; then
				sudo -u "$TARGET_USER" mkdir -p "$TIMONWONG_DIR/bin"
				# Copy the extracted shellcheck binary to the extension's bin directory.
				sudo -u "$TARGET_USER" cp "$WORKER_TEMP/shellcheck-"*/shellcheck "$TIMONWONG_DIR/bin/"
				sudo -u "$TARGET_USER" chmod +x "$TIMONWONG_DIR/bin/shellcheck" # Make the copied binary executable.
			fi
			rm -rf "$WORKER_TEMP"/* # Clean up temporary files.
		fi

		# Setup VSCode autostart scripts for settings and keybindings.
		# This section extracts predefined script contents from the `VSCODE_ONLINE_INSTALLATION_LIB`
		# file (which contains heredocs for these scripts) and deploys them for offline configuration.
		sudo mkdir -p "$TARGET_HOME/.local/bin"
		# Temporarily copy the VSCode online installation library to extract script content.
		# This is a robust way to extract the embedded script definitions from the sourced library.
		sudo cp -f "$CD_DIRNAME/../VSCODE_ONLINE_INSTALLATION_LIB" "$WORKER_TEMP/vscodelib"
		# Extract the `vscode-setup.sh` script content using `sed` from the temporary library file.
		# This script configures editor settings and formatter paths for the user.
		sed -n '/cat <<'"'EOF'"' >"'$HOME'/.local/bin/vscode-setup.sh"/,/'EOF'/p' "$WORKER_TEMP/vscodelib" | sed '1d;$d' >"$WORKER_TEMP/vscode-setup.sh"
		# Extract the `vscode-setup-keyboard-shortcuts.sh` script content.
		# This script configures custom keyboard shortcuts for the user.
		sed -n '/cat <<'"'EOF'"' >"'$HOME'/.local/bin/vscode-setup-keyboard-shortcuts.sh"/,/'EOF'/p' "$WORKER_TEMP/vscodelib" | sed '1d;$d' >"$WORKER_TEMP/vscode-setup-keyboard-shortcuts.sh"

		# Copy these extracted scripts to the target user's local bin directory and /etc/skel for new users.
		sudo cp "$WORKER_TEMP/vscode-setup.sh" "$TARGET_HOME/.local/bin/" && sudo chmod +x "$TARGET_HOME/.local/bin/vscode-setup.sh"
		sudo cp "$WORKER_TEMP/vscode-setup-keyboard-shortcuts.sh" "$TARGET_HOME/.local/bin/" && sudo chmod +x "$TARGET_HOME/.local/bin/vscode-setup-keyboard-shortcuts.sh"
		sudo mkdir -p /etc/skel/.local/bin
		sudo cp "$WORKER_TEMP/vscode-setup.sh" /etc/skel/.local/bin/
		sudo cp "$WORKER_TEMP/vscode-setup-keyboard-shortcuts.sh" /etc/skel/.local/bin/

		# Create corresponding .desktop files for autostart in GNOME/MATE for the target user and /etc/skel.
		# These files ensure the setup scripts run automatically upon graphical login.
		sudo mkdir -p "$TARGET_HOME/.config/autostart"
		sudo mkdir -p /etc/skel/.config/autostart
		echo '[Desktop Entry]
Type=Application
Exec=bash -c "'"$TARGET_HOME"'/.local/bin/vscode-setup.sh"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=VSCode Setup Script
Comment=Runs the VSCode setup script to configure shell-formatter' | sudo tee "$TARGET_HOME/.config/autostart/vscode-setup.desktop"
		echo '[Desktop Entry]
Type=Application
Exec=bash -c "'"$TARGET_HOME"'/.local/bin/vscode-setup-keyboard-shortcuts.sh"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=VSCode Keyboard Setup
Comment=Configures VSCode keyboard shortcuts' | sudo tee "$TARGET_HOME/.config/autostart/vscode-setup-keyboard-shortcuts.desktop"
		sudo cp "$TARGET_HOME/.config/autostart/vscode-setup.desktop" /etc/skel/.config/autostart/
		sudo cp "$TARGET_HOME/.config/autostart/vscode-setup-keyboard-shortcuts.desktop" /etc/skel/.config/autostart/

		# Execute the setup scripts once for the current user to apply settings immediately.
		sudo -u "$TARGET_USER" bash "$TARGET_HOME/.local/bin/vscode-setup.sh"
		sudo -u "$TARGET_USER" bash "$TARGET_HOME/.local/bin/vscode-setup-keyboard-shortcuts.sh"
	fi

	# Install Google Antigravity CLI - copies the native binary from cached bundles.
	FUN_CHOICE_BLOCK_INDICATOR "Installing Google Antigravity CLI"
	local ANTIGRAVITY_DIR="$OTHER_SOURCES_DIR/antigravity_cli"
	if [ -d "$ANTIGRAVITY_DIR" ]; then
		local BINARY=$(find "$ANTIGRAVITY_DIR" -name "antigravity-linux-*" 2>/dev/null | head -n1)
		if [ -f "$BINARY" ]; then
			# Copy the native binary to a system-wide PATH location.
			sudo cp -f "$BINARY" /usr/local/bin/antigravity
			sudo chmod 755 /usr/local/bin/antigravity
		elif [ -f "$ANTIGRAVITY_DIR/install.sh" ]; then
			# Fallback: attempt to use the install.sh if binary was not found
			chmod +x "$ANTIGRAVITY_DIR/install.sh"
			bash "$ANTIGRAVITY_DIR/install.sh"
		fi
	fi

	# --- 3. Install Gaming Sources ---
	FUN_CHOICE_BLOCK_INDICATOR "Installing Gaming Environment"
	# Install Flatpak Bundles (Ryujinx, Dolphin, PPSSPP, RetroArch) from the cached repository.
	if [ -d "$GAMING_BUNDLE_DIR/flatpak_gaming_bundles/OSTREE_FLATPAK_BUNDLES" ]; then
		# Add the cached Flatpak repository as a local remote to the user's Flatpak installation.
		sudo flatpak remote-add --if-not-exists --user offline-gaming-repo "$GAMING_BUNDLE_DIR/flatpak_gaming_bundles"
		# Install each bundled Flatpak application from the local repository.
		for app in io.github.ryubing.Ryujinx org.DolphinEmu.dolphin-emu org.ppsspp.PPSSPP org.libretro.RetroArch; do
			sudo flatpak install -y --user offline-gaming-repo "$app"
		done
	fi
	# Install RetroArch Cores - copies .so files to the RetroArch configuration directories.
	if [ -d "$GAMING_BUNDLE_DIR/emulator_assets/retroarch_cores" ]; then
		# Ensure target directories exist for the current user.
		mkdir -p "$TARGET_HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
		# Copy core files for the current user.
		cp "$GAMING_BUNDLE_DIR/emulator_assets/retroarch_cores/"*.so "$TARGET_HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/"
		# Copy core files for new users via /etc/skel.
		mkdir -p "/etc/skel/.var/app/org.libretro.RetroArch/config/retroarch/cores"
		cp "$GAMING_BUNDLE_DIR/emulator_assets/retroarch_cores/"*.so "/etc/skel/.var/app/org.libretro.RetroArch/config/retroarch/cores/"
	fi
	# Build Dolphin from source - compiles and installs the emulator from the cached source code.
	if [ -d "$GAMING_BUNDLE_DIR/emulator_assets/dolphin_source" ]; then
		(
			cd "$GAMING_BUNDLE_DIR/emulator_assets/dolphin_source" || exit 1 # Navigate to Dolphin source directory.
			mkdir -p Build && cd Build || exit 1                             # Create and enter a build directory.
			cmake ..                                                         # Configure the build system using CMake.
			make -j"$(nproc)"                                                # Compile using all available CPU cores (`nproc` gets number of processors).
			sudo make install                                                # Install the compiled binaries to the system.
		)
	fi
	# Deploy gaming assets (Xemu BIOS/HDD, Ryujinx Prodkeys/Firmware) from local files bundle.
	if [ -d "$LOCAL_FILES_BUNDLE_DIR/gaming_assets" ]; then
		# Xemu assets: Extract and copy BIOS/HDD files.
		7z x "$LOCAL_FILES_BUNDLE_DIR/gaming_assets/XEMU_XBOX_FILES.zip" -o"$WORKER_TEMP"
		# Ensure target directories exist for current user and /etc/skel.
		mkdir -p "$TARGET_HOME/.local/share/xemu/xemu/" /etc/skel/.local/share/xemu/xemu/
		# Copy Xemu files for current user.
		cp "$WORKER_TEMP/BIOS/Complex_4627v1.03.bin" "$TARGET_HOME/.local/share/xemu/xemu/"
		cp "$WORKER_TEMP/Boot_ROM_image/mcpx_1.0.bin" "$TARGET_HOME/.local/share/xemu/xemu/"
		cp "$WORKER_TEMP/Pre_built_Xbox_HDD_image/xbox_hdd.qcow2" "$TARGET_HOME/.local/share/xemu/xemu/"
		# Copy Xemu files for new users via /etc/skel.
		cp "$WORKER_TEMP/BIOS/Complex_4627v1.03.bin" /etc/skel/.local/share/xemu/xemu/
		cp "$WORKER_TEMP/Boot_ROM_image/mcpx_1.0.bin" /etc/skel/.local/share/xemu/xemu/
		cp "$WORKER_TEMP/Pre_built_Xbox_HDD_image/xbox_hdd.qcow2" /etc/skel/.local/share/xemu/xemu/
		rm -rf "$WORKER_TEMP"/* # Clean up temporary files.

		# Ryujinx Prodkeys/Firmware: Extract and copy these essential files.
		7z x "$LOCAL_FILES_BUNDLE_DIR/gaming_assets/NINTENDO-SWITCH-PRODKEYS-*.7z" -o"$WORKER_TEMP"
		7z x "$LOCAL_FILES_BUNDLE_DIR/gaming_assets/NINTENDO-SWITCH-FIRMWARE-*.7z" -o"$WORKER_TEMP"
		# Ensure target directories exist for current user and /etc/skel.
		mkdir -p "$TARGET_HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system" /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
		# Copy Ryujinx files for current user.
		cp -r "$WORKER_TEMP/NINTENDO-SWITCH-PRODKEYS-"*/* "$TARGET_HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system/"
		cp -r "$WORKER_TEMP/NINTENDO-SWITCH-FIRMWARE-"* "$TARGET_HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system/"
		# Copy Ryujinx files for new users via /etc/skel.
		cp -r "$WORKER_TEMP/NINTENDO-SWITCH-PRODKEYS-"*/* /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system/
		cp -r "$WORKER_TEMP/NINTENDO-SWITCH-FIRMWARE-"* /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system/
		rm -rf "$WORKER_TEMP"/* # Clean up temporary files.
	fi
	# --- 4. Install Local Project Files & Configurations ---
	FUN_CHOICE_BLOCK_INDICATOR "Installing Local Project Files & Configurations"
	# Custom Scripts: Copy to /bin and a dedicated custom scripts directory, then add to PATH.
	# These are scripts developed as part of the APT-AUTO-INSTALLS project.
	sudo cp -r "$LOCAL_FILES_BUNDLE_DIR/custom_scripts/." /bin/                   # Copy directly to /bin for system-wide access.
	sudo mkdir -p /bin/CUSTOM-SH-SCRIPTS                                          # Create a dedicated directory for custom scripts.
	sudo cp -r "$LOCAL_FILES_BUNDLE_DIR/custom_scripts/." /bin/CUSTOM-SH-SCRIPTS/ # Copy to the dedicated directory.
	sudo chmod -R 755 /bin/custom* /bin/CUSTOM-SH-SCRIPTS                         # Set executable permissions for all custom scripts.
	# Add the custom scripts directory to the system-wide PATH if not already present in /etc/profile.
	if ! grep -q "/bin/CUSTOM-SH-SCRIPTS" /etc/profile; then
		echo 'export PATH=$PATH:/bin/CUSTOM-SH-SCRIPTS' | sudo tee -a /etc/profile
	fi

	# Documentation and Videos: Copy supplementary resources to user's home and /etc/skel.
	cp -r "$LOCAL_FILES_BUNDLE_DIR/supplementary_docs/." "$TARGET_HOME/WARES-INCLUDED"
	cp -r "$LOCAL_FILES_BUNDLE_DIR/supplementary_docs/." "/etc/skel/WARES-INCLUDED"
	# Setup directories for Hidamari live wallpapers and copy cached video files.
	mkdir -p "$TARGET_HOME/Videos/Hidamari" /etc/skel/Videos/Hidamari
	cp -r "$LOCAL_FILES_BUNDLE_DIR/media/videos/." "$TARGET_HOME/Videos/Hidamari/"
	cp -r "$LOCAL_FILES_BUNDLE_DIR/media/videos/." "/etc/skel/Videos/Hidamari/"
	# Themes and Configs: Extract and deploy various theme and configuration files.
	for theme_archive in "$LOCAL_FILES_BUNDLE_DIR/themes_and_configs/"*.7z; do
		7z x "$theme_archive" -o"$WORKER_TEMP" # Extract the 7z archive to the worker directory.
		# Copy 'Templates' directory (e.g., for desktop themes, user templates).
		if [ -d "$WORKER_TEMP/Templates" ]; then
			cp -r "$WORKER_TEMP/Templates" "$TARGET_HOME/"
			cp -r "$WORKER_TEMP/Templates" /etc/skel/
		fi
		# Copy dconf user settings (GNOME/MATE desktop configurations).
		if [ -f "$WORKER_TEMP/user" ]; then # dconf binary user file.
			mkdir -p "$TARGET_HOME/.config/dconf" /etc/skel/.config/dconf
			cp "$WORKER_TEMP/user" "$TARGET_HOME/.config/dconf/"
			cp "$WORKER_TEMP/user" /etc/skel/.config/dconf/
			# Load dconf settings from a text file if present (for immediate application).
			if [ -f "$WORKER_TEMP/my-dconf-settings.txt" ]; then
				sudo -u "$TARGET_USER" dconf load / <"$WORKER_TEMP/my-dconf-settings.txt"
			fi
		fi
		# Copy custom .bashrc configuration.
		if [ -f "$WORKER_TEMP/kawaii-parrot.bashrc" ]; then
			cp "$WORKER_TEMP/kawaii-parrot.bashrc" "$TARGET_HOME/.bashrc"
			cp "$WORKER_TEMP/kawaii-parrot.bashrc" "/etc/skel/.bashrc"
			cp "$WORKER_TEMP/kawaii-parrot.bashrc" "/root/.bashrc" # Also copy to root's bashrc.
		fi
		rm -rf "$WORKER_TEMP"/* # Clean up temporary files.
	done

	# --- 5. Final System-Wide Configurations ---
	FUN_CHOICE_BLOCK_INDICATOR "Applying Final System Configurations"
	# Add target user to KVM/QEMU related groups for virtualization access.
	sudo usermod -aG libvirt "$TARGET_USER"
	sudo usermod -aG libvirt-qemu "$TARGET_USER"
	sudo usermod -aG kvm "$TARGET_USER"
	# Configure /etc/adduser.conf to automatically add new users to virtualization groups.
	# This ensures any new user created on the system will inherit these group memberships.
	sudo sed -i 's/#EXTRA_GROUPS=.*/EXTRA_GROUPS="vboxusers disk libvirt libvirt-qemu kvm"/' /etc/adduser.conf
	sudo sed -i 's/#ADD_EXTRA_GROUPS=.*/ADD_EXTRA_GROUPS=1/' /etc/adduser.conf
	# Disable automatic APT updates and unattended upgrades to give full user control.
	# This prevents the system from automatically applying updates in the background.
	sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/g' /etc/apt/apt.conf.d/20auto-upgrades
	sudo sed -i 's/APT::Periodic::Unattended-Upgrade "1";/APT::Periodic::Unattended-Upgrade "0";/g' /etc/apt/apt.conf.d/20auto-upgrades
	# Setup a custom systemd service to run essential commands at boot.
	sudo mkdir -p /etc/systemd/system/CUST-SYSD
	# Define the boot-up script content using a heredoc. This script performs
	# post-boot tasks like fixing package configurations, starting libvirt,
	# refreshing icons, restarting Samba, and ensuring the first non-root
	# user is added to virtualization groups (runs only once).
	cat <<'EOF' | sudo tee /etc/systemd/system/CUST-SYSD/C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.bash
#!/bin/bash
# Script executed at boot by the custom systemd service.
# Performs post-boot setup and configuration.

sudo dpkg --configure -a # Fix any pending package configurations.
sudo systemctl start libvirtd # Ensure libvirt daemon is running for KVM/QEMU.
sudo update-icon-caches /usr/share/icons/* # Refresh icon caches.
sudo systemctl restart smbd nmbd # Restart Samba services for updated network shares.

# Logic to add the first non-root user to virtualization groups (runs only once).
FLAG_FILE="/var/lib/add_user_to_kvm_groups_done"
if [ ! -f "$FLAG_FILE" ]; then
    PRIMARY_USER=$(awk -F: '$3 >= 1000 && $6 ~ /^\/home\// {print $1; exit}' /etc/passwd)
    if [ -n "$PRIMARY_USER" ]; then
        usermod -aG libvirt "$PRIMARY_USER"
        usermod -aG libvirt-qemu "$PRIMARY_USER"
        usermod -aG kvm "$PRIMARY_USER"
        touch "$FLAG_FILE" # Create flag file to prevent re-execution.
    fi
fi
EOF
	# Define the systemd service unit file content using a heredoc.
	cat <<EOF | sudo tee /etc/systemd/system/CUST-SYSD/C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.service
[Unit]
Description=Run script at startup after all systemd services are loaded
After=multi-user.target

[Service]
ExecStart=/etc/systemd/system/CUST-SYSD/C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.bash
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
	sudo chmod +x /etc/systemd/system/CUST-SYSD/C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.bash # Make the boot-up script executable.
	sudo systemctl daemon-reload                                                             # Reload systemd to pick up new service definitions.
	sudo systemctl enable C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.service                    # Enable service to start automatically at boot.
	sudo systemctl start C-CO-OM-MA-AN-ND-DS-S-TO-RUN-AT-BOOT-UP.service                     # Start the service immediately for current session.

	# --- Final Cleanup ---
	# Remove the temporary worker directory and kill the sudo keep-alive process.
	rm -rf "$WORKER_TEMP"
	kill "$SUDO_KEEPALIVE_PID"
}

# --- MAIN EXECUTION FLOW ---
# Prompt the user for the cache directory location.
get_cache_dir

# Display the main interactive menu for the offline installer.
CHOICE=$(whiptail --title "Total Offline Installer" --menu "Select an installation task:" 15 78 5 \
	"INSTALL_ALL" "Perform Full System Installation from Cache" \
	"EXIT" "Exit" 3>&1 1>&2 2>&3)

# Process the user's choice.
case $CHOICE in
"INSTALL_ALL")
	FUN_WARES_FOR_GNOME_AND_MATE_DE_FROM_CACHE # Execute the core offline installation function.
	;;
"EXIT" | *)
	echo "Exiting installation."
	exit 0
	;;
esac

# Display a final completion message and recommendation for reboot.
whiptail --title "Complete" --msgbox "Offline installation process finished. A reboot is recommended to apply all changes." 8 78
