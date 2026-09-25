#!/bin/bash

# this script [ RUNS DIRECTLY UNDER HOST OS / BARE METAL ] handles the creation of offline cache bundles
# this script is called from CACHE_ORCHESTRATOR.bash
# this LIB exists to separate out the host OS specific commands that will only run under full linux OS and not under chroot

CHOICE_CACHE=$1
DEST_DIR=$2
_DEBOOTSTRAP_MODE=$3

for bundle_id in $CHOICE_CACHE; do
	echo "Selected Cache Bundle ID: $bundle_id"
	case $bundle_id in

	GAMING_SOURCES)
		# --- Download Gaming Sources for Offline Installation ---
		echo "=============================================================================="
		echo "--- Starting Download of FLATPAK Gaming Sources DIRECTLY UNDER HOST OS ---"
		echo "=============================================================================="

		# --- Validate Destination Directory ---
		# Ensure DEST_DIR is set to prevent accidental downloads to unsafe locations (e.g., root).
		if [ -n "$DEST_DIR" ]; then
			effective_dest_dir="$DEST_DIR"
		else
			echo "WARNING: DEST_DIR is not set. Exiting to prevent accidental downloads to root directory."
			exit 1
		fi
		GAMING_SOURCES_DIR="$effective_dest_dir/gaming_bundle"
		FLATPAK_GAMING_BUNDLE_DIR="$GAMING_SOURCES_DIR/flatpak_gaming_bundles" # For offline Flatpak sideload repo

		# flatpak wont run everything correctly in a chroot environment due to its design,
		#  it just symply has to run directly under a full linux system (not a minimal chroot)
		if [ "$_DEBOOTSTRAP_MODE" == "1" ]; then
			# --- 3. Build Offline Flatpak Sideload Repository ---
			# Downloads selected apps + ALL dependencies and creates offline bundles.
			# This method temporarily installs apps to the user's local Flatpak installation,
			# creates a bundle, and then cleans up. The 'create-usb' command previously
			# used for this has been deprecated.

			sudo mkdir -p "$FLATPAK_GAMING_BUNDLE_DIR"
			sudo chmod -R 777 "$FLATPAK_GAMING_BUNDLE_DIR"
			echo "=== Building offline Flatpak bundles (true offline install) ==="

			sudo apt update
			sudo apt install -y flatpak

			if ! command -v flatpak &>/dev/null; then
				echo "ERROR: 'flatpak' command not found on host. Install Flatpak first to build bundles."
				echo "       On Debian/Ubuntu: sudo apt install flatpak"
				exit 1
			fi

			# Configure Flathub remote if not already present
			sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
			sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

			# List of gaming-related Flatpaks to include (add more as needed)
			APPS_TO_BUNDLE=(
				io.github.ryubing.Ryujinx
				org.DolphinEmu.dolphin-emu
				org.ppsspp.PPSSPP
				org.libretro.RetroArch
			)

			# Step 1: Install all required applications to the user's local repository
			echo "--- Temporarily installing applications to create bundles... ---"
			for app_id in "${APPS_TO_BUNDLE[@]}"; do
				echo "Installing/Updating $app_id..."
				# We use --user to avoid needing sudo and to keep the system installation clean.
				# --reinstall ensures we have the latest version from the remote.
				# if ! flatpak install --user --noninteractive --reinstall flathub "$app_id"; then
				if ! flatpak install --reinstall -y flathub "$app_id"; then
					echo "ERROR: Failed to install $app_id. Bundle creation for this app will be skipped."
				fi
			done

			# Step 2: Create a single-file bundle for each application
			echo "--- Creating offline bundles... ---"
			for app_id in "${APPS_TO_BUNDLE[@]}"; do
				echo "Creating bundle for $app_id at $FLATPAK_GAMING_BUNDLE_DIR..."
				# build-bundle packages the app and its required dependencies into a single file.
				# Making errors visible for chroot environments by removing output redirection.
				if nice -n 10 ionice -c 2 -n 7 flatpak create-usb "$FLATPAK_GAMING_BUNDLE_DIR" "$app_id"; then
					# if flatpak build-bundle --user "$FLATPAK_GAMING_BUNDLE_DIR" "$app_id" >/dev/null 2>&1; then
					echo "Successfully created bundle for $app_id."
				else
					echo "ERROR: Failed to create bundle for $app_id. It might not have been installed correctly in the previous step."
				fi
			done

			# rename the hidden .ostree directory to a more descriptive name
			if [ -d "$FLATPAK_GAMING_BUNDLE_DIR/.ostree" ]; then
				sudo mv "$FLATPAK_GAMING_BUNDLE_DIR/.ostree" "$FLATPAK_GAMING_BUNDLE_DIR/OSTREE_FLATPAK_BUNDLES"
				sudo chmod -R 777 "$FLATPAK_GAMING_BUNDLE_DIR/OSTREE_FLATPAK_BUNDLES"
				echo "=== Offline Flatpak bundles created successfully in $FLATPAK_GAMING_BUNDLE_DIR ==="
			else
				echo "ERROR: No bundles were created. Please check for errors above."
			fi

			# # Step 3: Clean up by uninstalling the applications and any unused runtimes
			# echo "--- Cleaning up temporary Flatpak installations... ---"
			# for app_id in "${APPS_TO_BUNDLE[@]}"; do
			# 	echo "Uninstalling $app_id..."
			# 	flatpak remove -y flathub "$app_id" >/dev/null 2>&1
			# done

			echo "Offline Flatpak bundles ready in: $FLATPAK_GAMING_BUNDLE_DIR"
			echo "Transfer the .flatpak files to the offline machine and install with:"
			echo "   flatpak install <app_id>.flatpak"
		fi
		;;

	OTHER_SOURCES | ALL_NO_ARCHIVE | ALL_AND_ARCHIVE)
		# --- Download Other Sources for Offline Installation ---
		echo "=============================================================================="
		echo "--- Starting Download of OTHER Sources DIRECTLY UNDER HOST OS ---"
		echo "=============================================================================="

		FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR="$DEST_DIR/flatpaks_gnome_shell_extension_bundles" # For offline Flatpak sideload repo

		sudo mkdir -p "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR"
		sudo chmod -R 777 "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR"
		# flatpak wont run everything correctly in a chroot environment due to its design,
		#  it just symply has to run directly under a full linux system (not a minimal chroot)
		if [ "$_DEBOOTSTRAP_MODE" == "1" ]; then
			# --- Build Offline Flatpak Sideload Repository for GNOME Shell Extensions ---
			# Downloads selected apps + ALL dependencies and creates offline bundles.
			# This method temporarily installs apps to the user's local Flatpak installation,
			# creates a bundle, and then cleans up. The 'create-usb' command previously
			echo "=== Downloading GNOME Shell Extensions via Flatpak Directly under HOST OS ---"
			sudo apt install flatpak -y
			sudo apt install gnome-software-plugin-flatpak -y                                            # Integrates Flatpak with the GNOME Software center.
			sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo # Add the Flathub repository.

			FLATPAK_GNOME_EXTENSION_APPS_TO_BUNDLE=(
				io.github.jeffshee.Hidamari
			)

			for app_id in "${FLATPAK_GNOME_EXTENSION_APPS_TO_BUNDLE[@]}"; do
				echo "Installing/Updating $app_id..."
				# --reinstall ensures we have the latest version from the remote.
				if ! flatpak install --reinstall -y flathub "$app_id"; then
					echo "ERROR: Failed to install $app_id. Bundle creation for this app will be skipped."
				fi
			done

			# creating offline flatpak gnome extensions bundles
			for app_id in "${FLATPAK_GNOME_EXTENSION_APPS_TO_BUNDLE[@]}"; do
				echo "Creating bundle for $app_id at $FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR..."
				# build-bundle packages the app and its required dependencies into a single file.
				# Making errors visible for chroot environments by removing output redirection.
				if nice -n 10 ionice -c 2 -n 7 flatpak create-usb "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR" "$app_id"; then
					echo "Successfully created bundle for $app_id."
				else
					echo "ERROR: Failed to create bundle for $app_id. It might not have been installed correctly in the previous step."
				fi
			done

			# rename the hidden .ostree directory to a more descriptive name
			if [ -d "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR/.ostree" ]; then
				sudo mv "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR/.ostree" "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR/OSTREE_FLATPAK_BUNDLES"
				sudo chmod -R 777 "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR/OSTREE_FLATPAK_BUNDLES"
				echo "=== Offline Flatpak GNOME Shell Extension bundles created successfully in $FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR ==="
			else
				echo "ERROR: No bundles were created. Please check for errors above."
			fi

			echo "Offline Flatpak GNOME Shell Extension bundles ready in: $FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR"
			echo "Transfer the .flatpak files to the offline machine and install with:"
			echo "   flatpak install <app_id>.flatpak"
		else
			echo "Skipping Flatpak GNOME Shell Extensions bundle creation since not running under full Host OS."
		fi
		;;
	esac
done
