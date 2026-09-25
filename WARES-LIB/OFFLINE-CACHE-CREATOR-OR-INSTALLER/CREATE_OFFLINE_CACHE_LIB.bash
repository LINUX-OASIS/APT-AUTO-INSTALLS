#!/bin/bash

# ==============================================================================
#
#         Offline APT Package and Source Cache Creator
#
#  This script automates the process of downloading all necessary software
#  packages and source files used by the APT-AUTO-INSTALLS project to create
#  a comprehensive offline cache.
#
#  Features:
#    - Asks the user for a destination directory to store the cache.
#    - Downloads all APT packages (.deb files) without installing them.
#    - Downloads all other resources from GitHub, websites, and PPAs.
#    - Organizes the downloaded files into a clean directory structure.
#
# ==============================================================================

#TODO - COLOR OUTPUT FOR BETTER READABILITY WITH ANSI/ECHO ESCAPE CODES - ONCE ALL IS PRODUCTION READY
# TODO - FOR BUNDLES DIRECTORIES NAMES (FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA) \
# give directories more CLEAR NAMES  e.g. kaka BUNDLE -> have BUNLDE WORD IN IT !!!

# TODO - implement bundle downloads for: ollama, llama-cpp

# ==============================================================================

# SECTION - FUN_CREATE_TAR_ARCHIVE
# Asks the user if they want to create a compressed tarball of the entire cache
# directory upon completion. This is useful for easy distribution.
FUN_CREATE_TAR_ARCHIVE() {
	# Prompt the user with a Yes/No dialog.
	if (whiptail --title "Create Archive" --yesno "Do you want to create a compressed tar archive of the entire offline cache? This may take some time." 10 78); then
		# Display an informational box while the archive is being created.
		echo "Creating tar archive of the offline cache... This may take a while."

		# Generate a unique archive name with a timestamp.
		ARCHIVE_NAME="offline_cache_$(date +%Y%m%d_%H%M%S).tar"
		# Create the tar archive.
		# -c: create, -v: verbose, -f: file.
		# -C "$DEST_DIR" .: Changes to the destination directory before archiving, which prevents the archive from containing the full path.
		if tar -cvf "$DEST_DIR/$ARCHIVE_NAME" -C "$DEST_DIR" .; then
			echo "Offline cache successfully archived to: $DEST_DIR/$ARCHIVE_NAME"
		else
			echo "Failed to create tar archive. Check the console for errors."
		fi
	else
		echo "Tar archiving skipped."
	fi
}
# !SECTION - FUN_CREATE_TAR_ARCHIVE - END OF THE SECTION

# SECTION - FUN_DOWNLOAD_APT_PACKAGES
# Downloads all required .deb packages and their entire dependency trees from
# the APT repositories, including from several PPAs.
#
# The resulting structure in the cache is:
#
#   $DEST_DIR/
#   └── apt_packages_bundle/
#       ├── package1.deb
#       ├── dependencyA.deb
#       └── ...
#
FUN_DOWNLOAD_APT_PACKAGES() {
	echo "=============================================================================="
	echo "--- Starting APT Package Download ---"
	echo "=============================================================================="
	local APT_PKGS_BUNDLE_DIR="$DEST_DIR/apt_packages_bundle/"
	sudo mkdir -p "$APT_PKGS_BUNDLE_DIR"
	sudo chmod -R 777 "$APT_PKGS_BUNDLE_DIR"

	if ! command -v software-properties-common &>/dev/null; then
		echo "Error: software-properties-common is not installed. Cannot add PPAs."
		exit 1
	fi

	echo "--> Adding required PPAs..."
	echo -ne "\n" | sudo add-apt-repository universe
	# ppa repo for deb mkusb
	sudo add-apt-repository -y ppa:mkusb/ppa || { echo -ne "\n" | sudo add-apt-repository -y ppa:mkusb/ppa; }
	# ppa repo for deb for cubic
	sudo add-apt-repository -y ppa:cubic-wizard/release || { echo -ne "\n" | sudo add-apt-repository -y ppa:cubic-wizard/release; }
	# ppa repo for .deb MAINLINE kernel installer (mainline)
	sudo add-apt-repository -y ppa:cappelikan/ppa || { echo -ne "\n" | sudo add-apt-repository -y ppa:cappelikan/ppa; }
	# ppa repo for .deb linux wifi hotspot
	sudo add-apt-repository -y ppa:lakinduakash/lwh || { echo -ne "\n" | sudo add-apt-repository -y ppa:lakinduakash/lwh; }
	# ppa repo for xemu   (xbox emulator)
	sudo add-apt-repository -y ppa:mborgerson/xemu || { echo -ne "\n" | sudo add-apt-repository -y ppa:mborgerson/xemu; }
	sudo apt update

	local APT_PACKAGES=(
		7zip
		7zip-rar
		adb
		aircrack-ng
		alsa-utils
		antimicro
		ardour
		audacity
		bc
		bison
		bleachbit
		blueman
		breeze
		bridge-utils
		btop
		btrfs-progs
		build-essential
		caja-eiciel
		caja-gtkhash
		caja-image-converter
		caja-rename
		caja-seahorse
		cmake
		color-picker
		cool-retro-term
		cpufrequtils
		cpulimit
		cpupower-gui
		crunch
		cubic
		curl
		darktable
		dconf-editor
		debconf-utils
		debhelper
		debootstrap
		diodon
		dkms
		docker.io
		dosfstools
		dsniff
		dwarves
		easytag
		efibootmgr
		esptool
		etherwake
		ethtool
		exfatprogs
		fakeroot
		ffmpeg
		figlet
		fim
		flashrom
		flatpak
		flex
		g++
		geany
		gedit
		gettext
		gimp
		git
		glslang-tools
		glslc
		gnome-clocks
		gnome-disk-utility
		gnome-menus
		gnome-session-flashback
		gnome-shell-extension-gpaste
		gnome-shell-extension-manager
		gnome-shell-extensions
		gnome-software-plugin-flatpak
		gnome-system-tools
		gnome-tweaks
		gnome-user-share
		gparted
		grub-efi-amd64-bin
		grub-efi-amd64-signed
		gtkhash
		handbrake
		hashcat
		hcxtools
		hostapd
		htop
		hwinfo
		i7z
		intel-gpu-tools
		intel-opencl-icd
		inxi
		iproute2
		jq
		jstest-gtk
		kdenlive
		kdialog
		ktouch
		kwrite
		libelf-dev
		libgtk-3-dev
		libncurses-dev
		libpng-dev
		libqrencode-dev
		libqrencode4
		libqt6core5compat6-dev
		libssl-dev
		libvirt-clients
		libvirt-daemon-system
		libvulkan-dev
		linux-wifi-hotspot
		live-boot
		lm-sensors
		lolcat
		macchanger
		mainline
		make
		makeself
		maskprocessor
		mat2
		mate-desktop-environment
		mate-desktop-environment-extras
		mate-dock-applet
		mate-menu
		mate-tweak
		mate-user-share
		mdadm
		mdk4
		meson
		mkisofs
		mkusb
		mmc-utils
		mpv
		mtools
		nautilus-admin
		nbd-client
		nbd-server
		nbtscan
		ncurses-dev
		net-tools
		netdiscover
		nmap
		nvme-cli
		obs-studio
		okular
		openssh-server
		p7zip-full
		pandoc
		parted
		pi
		pipx
		plocate
		python3-full
		python3-pip
		python3-pyftpdlib
		python3-venv
		q4wine
		qbittorrent
		qemu-kvm
		qemu-system
		qemu-system-x86
		qemu-utils
		qrencode
		qt6-base-dev
		qt6-tools-dev-tools
		refind
		remmina
		remmina-plugin-rdp
		remmina-plugin-secret
		remmina-plugin-vnc
		samba
		screenfetch
		secure-delete
		shc
		shfmt
		smartmontools
		smbclient
		snapd
		software-properties-common
		spice-vdagent
		spirv-headers
		sshfs
		stress
		texlive
		texlive-fonts-recommended
		texlive-latex-extra
		texlive-xetex
		thinkfan
		timeshift
		tmux
		trash-cli
		tree
		ttyd
		unrar
		uptimed
		usb-pack-efi
		util-linux-extra
		v4l2loopback-dkms
		virt-manager
		virt-viewer
		virtinst
		virtualbox
		virtualbox-ext-pack
		virtualbox-guest-additions-iso
		vlc
		vokoscreen-ng
		vulkan-tools
		wakeonlan
		wavemon
		weasyprint
		wget
		wine64
		wkhtmltopdf
		xboxdrv
		xemu
		xorriso
		xz-utils
		zbar-tools
		zstd
	)

	echo "--> Downloading all required APT packages and dependencies..."
	if ! sudo apt reinstall --download-only -y -o Dir::Cache::archives="$APT_PKGS_BUNDLE_DIR" "${APT_PACKAGES[@]}"; then
		echo "Warning: The primary download command failed. Attempting to download packages individually."
		for pkg in "${APT_PACKAGES[@]}"; do
			sudo apt reinstall --download-only -y -o Dir::Cache::archives="$APT_PKGS_BUNDLE_DIR" "$pkg" || echo "Failed to download $pkg"
		done
	fi

	sudo chmod -R 777 "$APT_PKGS_BUNDLE_DIR"
	echo "--- APT packages bundle created successfully ---"
}
# !SECTION - FUN_DOWNLOAD_APT_PACKAGES - END OF THE SECTION

# SECTION - FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA
# Downloads all non-APT sources such as binaries from GitHub releases,
# Git repositories, and other direct downloads. Each component is placed in its
# own clear subdirectory within the 'other_sources_bundle'.
#
# The resulting structure in the cache is:
#
#   $DEST_DIR/
#   └── other_sources_bundle/
#       ├── scrcpy/
#       ├── vscode/
#       ├── antigravity_cli/
#       ├── fastfetch/
#       ├── gnome_extensions/
#       ├── virtualbox/
#       ├── genymotion/
#       └── google_chrome/
#
FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA() {

	_BUNDLE=$1

	echo "=============================================================================="
	echo "--- Starting Download of Other Sources (Binaries, Repos) ---"
	echo "=============================================================================="
	local OTHER_SOURCES_BUNDLE_DIR="$DEST_DIR/other_sources_bundle"
	sudo mkdir -p "$OTHER_SOURCES_BUNDLE_DIR"
	sudo chmod -R 777 "$OTHER_SOURCES_BUNDLE_DIR"

	echo "Downloading other sources to: $OTHER_SOURCES_BUNDLE_DIR"

	case $_BUNDLE in

	#SECTION - SCRCPY BUNDLE DOWNLOAD
	_SCRCPY_BUNDLE_DOWNLOAD)
		echo "--> Downloading scrcpy..."
		local SCRCPY_DIR="$OTHER_SOURCES_BUNDLE_DIR/scrcpy"
		mkdir -p "$SCRCPY_DIR"
		LATEST_RELEASE_JSON=$(curl -s https://api.github.com/repos/Genymobile/scrcpy/releases/latest)
		DOWNLOAD_URL=$(echo "$LATEST_RELEASE_JSON" | jq -r ".assets[] | select(.name | test(\"scrcpy-linux-x86_64-v.*.tar.gz$\")) | .browser_download_url")
		if [ -z "$DOWNLOAD_URL" ]; then
			echo "Could not find scrcpy download URL for linux-x86_64. Skipping."
		else
			wget -P "$SCRCPY_DIR" "$DOWNLOAD_URL" || echo "Warning: Failed to download scrcpy."
		fi
		sudo chmod -R 777 "$SCRCPY_DIR"
		;;
		#!SECTION - SCRCPY BUNDLE DOWNLOAD END

		#SECTION - VSCODE BUNDLE DOWNLOAD
	_VSCODE_BUNDLE_DOWNLOAD)
		echo "--> Creating VSCode offline bundle..."
		local VSCODE_DIR="$OTHER_SOURCES_BUNDLE_DIR/vscode"
		sudo mkdir -p "$VSCODE_DIR"

		# Download the .deb package
		wget -O "$VSCODE_DIR/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" || {
			echo "ERROR: COULDN'T DOWNLOAD VSCODE DEB PACKAGE"
			exit 1
		}

		# Helper function to download extensions
		FUN_DOWNLOAD_VSCODE_VSIX() {
			local ext_id="$1"
			local out_dir="$2"
			local retries=3
			local delay=5
			local count=0
			local file_name="${out_dir}/${ext_id}.vsix"
			while [ $count -lt $retries ]; do
				echo "Fetching VSIX info for $ext_id..."
				local json_data
				json_data=$(curl -s "https://marketplace.visualstudio.com/items?itemName=$ext_id" | grep '<script class="jiContent"' | sed 's/<[^>]*>//g')
				if [ -z "$json_data" ]; then
					echo "ERROR: Could not fetch page for $ext_id"
					((count++))
					sleep $delay
					continue
				fi
				local publisher
				publisher=$(echo "$json_data" | jq -r '.Resources.PublisherName')
				local extension
				extension=$(echo "$json_data" | jq -r '.Resources.ExtensionName')
				local version
				version=$(echo "$json_data" | jq -r '.Resources.Version')
				if [ -z "$publisher" ] || [ -z "$extension" ] || [ -z "$version" ]; then
					echo "ERROR: Could not parse JSON for $ext_id"
					((count++))
					sleep $delay
					continue
				fi
				local vsix_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${publisher}/vsextensions/${extension}/${version}/vspackage"
				echo "Downloading from $vsix_url..."
				if curl -L -o "$file_name" "$vsix_url" && [ -s "$file_name" ]; then
					echo "✅ Successfully downloaded $file_name"
					return 0
				fi
				echo "ERROR: Download failed or file is empty. Retrying..."
				((count++))
				sleep $delay
			done
			echo "❌ ERROR: Could not download $ext_id after $retries attempts."
			return 1
		}

		# Download extensions
		local EXTENSIONS_DIR="$VSCODE_DIR/extensions"
		mkdir -p "$EXTENSIONS_DIR"
		local EXT_LIST=(
			rogalmic.bash-debug
			mads-hartmann.bash-ide-vscode
			timonwong.shellcheck
			Remisa.shellman
			oderwat.indent-rainbow
			vscode-icons-team.vscode-icons
			lkrms.inifmt
			github.copilot
			github.copilot-chat
			exodiusstudios.comment-anchors
			tomoki1207.pdf
			donjayamanne.githistory
			davidanson.vscode-markdownlint
			google.geminicodeassist
			tal7aouy.theme
			github.github-vscode-theme
			eamodio.gitlens
			zhuangtongfa.material-theme
			lumirelle.shell-format-rev
			foxundermoon.shell-format
			google.gemini-cli-vscode-ide-companion
			huangyaojun.toggle-readonly
			ms-windows-ai-studio.windows-ai-studio
		)
		for ext in "${EXT_LIST[@]}"; do FUN_DOWNLOAD_VSCODE_VSIX "$ext" "$EXTENSIONS_DIR"; done

		# Download extension dependencies
		local DEPS_DIR="$VSCODE_DIR/dependencies"
		mkdir -p "$DEPS_DIR"
		LATEST_SHFMT_TAG=$(curl -s "https://api.github.com/repos/mvdan/sh/releases/latest" | jq -r ".tag_name")
		wget -P "$DEPS_DIR" "https://github.com/mvdan/sh/releases/download/${LATEST_SHFMT_TAG}/shfmt_${LATEST_SHFMT_TAG}_linux_amd64"
		LATEST_SHELLCHECK_RELEASE_TAG=$(curl -sL "https://api.github.com/repos/koalaman/shellcheck/releases/latest" | jq -r '.tag_name')
		wget -P "$DEPS_DIR" "https://github.com/koalaman/shellcheck/releases/download/${LATEST_SHELLCHECK_RELEASE_TAG}/shellcheck-${LATEST_SHELLCHECK_RELEASE_TAG}.linux.x86_64.tar.xz"
		wget -P "$DEPS_DIR" "https://unpkg.com/@one-ini/wasm@0.1.1/one_ini_bg.wasm"

		sudo chmod -R 777 "$VSCODE_DIR"
		echo "VSCode offline bundle created in: $VSCODE_DIR"
		;;
		#!SECTION - VSCODE BUNDLE DOWNLOAD END

		#SECTION - ANTIGRAVITY CLI BUNDLE DOWNLOAD
	_ANTIGRAVITY_CLI_BUNDLE_DOWNLOAD)
		echo "--> Creating Antigravity CLI offline bundle..."
		local ANTIGRAVITY_DIR="$OTHER_SOURCES_BUNDLE_DIR/antigravity_cli"
		mkdir -p "$ANTIGRAVITY_DIR"

		echo "Downloading Antigravity CLI install script..."
		curl -fsSL "https://antigravity.google/cli/install.sh" -o "$ANTIGRAVITY_DIR/install.sh" || {
			echo "ERROR: Could not download antigravity install.sh"
		}

		echo "Downloading Antigravity CLI native binary..."
		local ARCH=$(uname -m)
		case "$ARCH" in
		x86_64) ARCH="amd64" ;;
		aarch64 | arm64) ARCH="arm64" ;;
		esac

		# Assuming it's distributed as a binary
		curl -fL --progress-bar -o "$ANTIGRAVITY_DIR/antigravity-linux-${ARCH}" \
			"https://antigravity.google/cli/download/linux-${ARCH}/antigravity" || {
			echo "Warning: Could not download native binary."
		}

		sudo chmod -R 777 "$ANTIGRAVITY_DIR"
		echo "Antigravity CLI offline bundle created in: $ANTIGRAVITY_DIR"
		;;
		#!SECTION - ANTIGRAVITY CLI BUNDLE DOWNLOAD END

		#SECTION - OLLAMA BUNDLE DOWNLOAD
	_OLLAMA_BUNDLE_DOWNLOAD)
		echo "--> Creating Ollama offline bundle..."
		local OLLAMA_DIR="$OTHER_SOURCES_BUNDLE_DIR/ollama_bundle"
		mkdir -p "$OLLAMA_DIR"

		echo "Downloading ollama install.sh script..."
		curl -fsSL "https://ollama.com/install.sh" -o "$OLLAMA_DIR/install.sh" || {
			echo "ERROR: Could not download ollama install.sh"
			return 1
		}

		local ARCH=$(uname -m)
		case "$ARCH" in
		x86_64) ARCH="amd64" ;;
		aarch64 | arm64) ARCH="arm64" ;;
		*)
			echo "ERROR: Unsupported architecture: $ARCH for Ollama binary download."
			return 1
			;;
		esac

		echo "Downloading ollama-linux-${ARCH}.tgz binary..."
		curl -fL --progress-bar -o "$OLLAMA_DIR/ollama-linux-${ARCH}.tgz" \
			"https://ollama.com/download/ollama-linux-${ARCH}.tgz" || {
			echo "ERROR: Could not download ollama-linux-${ARCH}.tgz"
			return 1
		}

		sudo chmod -R 777 "$OLLAMA_DIR"
		echo "Ollama offline bundle created in: $OLLAMA_DIR"
		;;
		#!SECTION - OLLAMA BUNDLE DOWNLOAD END

		#SECTION - LLAMA_CPP BUNDLE DOWNLOAD
	_LLAMA_CPP_BUNDLE_DOWNLOAD)
		echo "--> Creating Llama.cpp offline bundle..."
		local LLAMA_CPP_DIR="$OTHER_SOURCES_BUNDLE_DIR/llama_cpp_bundle"
		mkdir -p "$LLAMA_CPP_DIR"

		LATEST_LLAMA_CPP=$(curl -s "https://api.github.com/repos/ggerganov/llama.cpp/releases/latest" | jq -r ".tag_name")
		wget -P "$LLAMA_CPP_DIR" "https://github.com/ggerganov/llama.cpp/releases/download/${LATEST_LLAMA_CPP}/llama-${LATEST_LLAMA_CPP}-bin-ubuntu-x64.zip" || {
			echo "ERROR: Could not download llama.cpp release."
		}

		sudo chmod -R 777 "$LLAMA_CPP_DIR"
		echo "Llama.cpp offline bundle created in: $LLAMA_CPP_DIR"
		;;
		#!SECTION - LLAMA_CPP BUNDLE DOWNLOAD END

		#SECTION - FASTFETCH BUNDLE DOWNLOAD
	_FASTFETCH_BUNDLE_DOWNLOAD)
		echo "--> Downloading fastfetch..."
		local FASTFETCH_DIR="$OTHER_SOURCES_BUNDLE_DIR/fastfetch"
		mkdir -p "$FASTFETCH_DIR"
		LATEST_FASTFETCH=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" | jq -r ".tag_name")
		wget -P "$FASTFETCH_DIR" "https://github.com/fastfetch-cli/fastfetch/releases/download/${LATEST_FASTFETCH}/fastfetch-linux-amd64.deb"
		sudo chmod -R 777 "$FASTFETCH_DIR"
		;;
		#!SECTION - FASTFETCH BUNDLE DOWNLOAD

		#SECTION - GNOME SHELL EXTENSIONS BUNDLE DOWNLOADS
	_GNOME_SHELL_EXTENSIONS_BUNDLE_DOWNLOAD)
		echo "--> Downloading GNOME Shell Extensions..."
		local GNOME_EXT_DIR="$OTHER_SOURCES_BUNDLE_DIR/gnome_extensions"
		mkdir -p "$GNOME_EXT_DIR"
		sudo apt install -y gnome-shell-extensions

		# Clone extensions from Git
		git clone https://github.com/eonpatapon/gnome-shell-extension-caffeine.git "$GNOME_EXT_DIR/caffeine"
		git clone https://gitlab.com/marcosdalvarez/thinkpad-battery-threshold-extension.git "$GNOME_EXT_DIR/thinkpad-battery-threshold"
		wget -P "$GNOME_EXT_DIR/thinkpad-battery-threshold" "https://gitlab.com/marcosdalvarez/thinkpad-battery-threshold-extension/-/raw/main/others/99-thinkpad-thresholds-udev.rules"
		git clone https://github.com/jeffshee/gnome-ext-hanabi.git "$GNOME_EXT_DIR/hanabi"

		# Download extensions from extensions.gnome.org
		GNOME_VERSION_CHECK_NUM=$(gnome-shell --version | tr -d -c '[:digit:]' | head -c2)
		EXTENSIONS_TO_DOWNLOAD=(
			"tophat@fflewddur.github.io"
			"thinkpadthermal@moonlight.drive.vk.gmail.com"
			"transparent-top-bar@ftpix.com"
		)
		for ext_uuid in "${EXTENSIONS_TO_DOWNLOAD[@]}"; do
			EXT_INFO=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=${ext_uuid}&shell_version=${GNOME_VERSION_CHECK_NUM}")
			LATEST_VERSION=$(echo "$EXT_INFO" | jq -r '.version')
			if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "null" ]; then
				DOWNLOAD_URL="https://extensions.gnome.org/api/v1/extensions/${ext_uuid}/versions/${LATEST_VERSION}/?format=zip"
				wget -P "$GNOME_EXT_DIR" "$DOWNLOAD_URL"
			fi
		done

		# flatpak gnome extensions (directly under HOST OS)
		if [ "$_DEBOOTSTRAP_MODE" == "0" ]; then

			FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR="$GNOME_EXT_DIR/flatpaks_gnome_shell_extension_bundles" # For offline Flatpak sideload repo
			sudo mkdir -p "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR"
			sudo chmod -R 777 "$FLATPAK_GNOME_SHELL_EXTENSIONS_BUNDLE_DIR"
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
		sudo chmod -R 777 "$GNOME_EXT_DIR"
		;;
		#!SECTION - GNOME SHELL EXTENSIONS BUNDLE DOWNLOADS END

		#SECTION - VIRTUALBOX BUNDLE DOWNLOAD
	_VIRTUALBOX_BUNDLE_DOWNLOAD)
		echo "--> Creating VirtualBox offline bundle..."
		local VIRTUALBOX_DIR="$OTHER_SOURCES_BUNDLE_DIR/virtualbox"
		mkdir -p "$VIRTUALBOX_DIR"
		(
			sudo apt update &&
				sudo mkdir -p /etc/apt/keyrings &&
				wget -q -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /etc/apt/keyrings/oracle-virtualbox-2016.gpg &&
				echo "Types: deb
URIs: https://download.virtualbox.org/virtualbox/debian
Suites: $(cat /etc/os-release | grep UBUNTU_CODENAME= | cut -d = -f2 | tr -d '[:space:]')
Components: contrib
Architectures: amd64
Signed-By: /etc/apt/keyrings/oracle-virtualbox-2016.gpg" | sudo tee /etc/apt/sources.list.d/virtualbox.sources >/dev/null &&
				sudo apt update
			LATEST_VBOX_PACKAGE_NAME=$(apt-cache search virtualbox | grep -o "^virtualbox-7.*" | sort -V | tail -n1)
			LATEST_VERSION=$(apt-cache show "$LATEST_VBOX_PACKAGE_NAME" | grep -oP 'Version: \K[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

			if [ -n "$LATEST_VERSION" ]; then
				sudo apt install --download-only -y -o Dir::Cache::archives="$VIRTUALBOX_DIR" "$LATEST_VBOX_PACKAGE_NAME"
				wget -P "$VIRTUALBOX_DIR" "https://download.virtualbox.org/virtualbox/$LATEST_VERSION/Oracle_VirtualBox_Extension_Pack-${LATEST_VERSION}.vbox-extpack"
				wget -P "$VIRTUALBOX_DIR" "https://download.virtualbox.org/virtualbox/$LATEST_VERSION/VBoxGuestAdditions_${LATEST_VERSION}.iso"
			else
				# Fallback to default repo version
				sudo apt install --download-only -y -o Dir::Cache::archives="$VIRTUALBOX_DIR" virtualbox virtualbox-ext-pack virtualbox-guest-additions-iso
			fi
		) || sudo apt install --download-only -y -o Dir::Cache::archives="$VIRTUALBOX_DIR" virtualbox virtualbox-ext-pack virtualbox-guest-additions-iso
		sudo chmod -R 777 "$VIRTUALBOX_DIR"
		;;
		#!SECTION - VIRTUALBOX BUNDLE DOWNLOAD END

		#SECTION - GENYMOTION BUNDLE DOWNLOAD
	_GENYMOTION_BUNDLE_DOWNLOAD)
		echo "--> Downloading Genymotion..."
		local GENYMOTION_DIR="$OTHER_SOURCES_BUNDLE_DIR/genymotion"
		mkdir -p "$GENYMOTION_DIR"
		# Informational banners
		echo "🔎 Probing latest Genymotion version (fast mode)..."
		echo "⚡ Ultra-fast Genymotion version probe..."
		echo "⚡ Probing latest Genymotion version (ultra-fast mode)..."

		# This complex logic is to find the latest version URL dynamically (COMPACT SYNTAX)
		DL_BASE="https://dl.genymotion.com/releases"
		OS_FILE_SUFFIX="linux_x64.run"
		VERSION_LIST=$(for major in 5 4 3; do for minor in $(seq 30 -1 0); do for patch in $(seq 30 -1 0); do echo "${major}.${minor}.${patch}"; done; done; done)
		check_url() { if curl -fsI "${DL_BASE}/genymotion-$1/genymotion-$1-${OS_FILE_SUFFIX}" >/dev/null 2>&1; then echo "$1"; fi; }
		export -f check_url
		export DL_BASE OS_FILE_SUFFIX
		FOUND_VERSIONS=$(echo "$VERSION_LIST" | xargs -P8 -I{} bash -c 'check_url "$@"' _ {})
		LATEST_FOUND=$(echo "$FOUND_VERSIONS" | sort -V | tail -n1)
		if [ -n "$LATEST_FOUND" ]; then
			echo "✅ Latest version: $LATEST_FOUND"
			FINAL_URL_GENYMOTION="${DL_BASE}/genymotion-${LATEST_FOUND}/genymotion-${LATEST_FOUND}-${OS_FILE_SUFFIX}"
			echo "📦 $FINAL_URL_GENYMOTION"
			wget -P "$GENYMOTION_DIR" "$FINAL_URL_GENYMOTION"
		fi
		sudo chmod -R 777 "$GENYMOTION_DIR"
		;;
		#!SECTION - GENYMOTION BUNDLE DOWNLOAD END

		#SECTION - GOOGLE CHROME BUNDLE DOWNLOAD
	_GOOGLE_CHROME_BUNDLE_DOWNLOAD)
		echo "--> Downloading Google Chrome..."
		local CHROME_DIR="$OTHER_SOURCES_BUNDLE_DIR/google_chrome"
		mkdir -p "$CHROME_DIR"
		wget -O "$CHROME_DIR/google-chrome-stable_current_amd64.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

		local POLICY_FILE="$CHROME_DIR/auto_extensions.json"
		sudo tee "$POLICY_FILE" <<-'EOF'
			{
				"ExtensionInstallForcelist": [
				"lgblnfidahcdcjddiepkckcfdhpknnjh;https://clients2.google.com/service/update2/crx",
				"cmedhionkhpnakcndndgjdbohmhepckk;https://clients2.google.com/service/update2/crx",
				"lmjnegcaeklhafolokijcfjliaokphfk;https://clients2.google.com/service/update2/crx"
				]
			}
		EOF
		# lgblnfidahcdcjddiepkckcfdhpknnjh = Ad Blocker (stands adblock)
		# cmedhionkhpnakcndndgjdbohmhepckk = Adblock for Youtube
		# lmjnegcaeklhafolokijcfjliaokphfk = Video Download Helper
		sudo chmod -R 777 "$CHROME_DIR"
		;;
		#!SECTION - GOOGLE CHROME BUNDLE DOWNLOAD END

		#SECTION - CHARMBRACELETS BUNDLE DOWNLOAD
	_CHARMBRACELETS_BUNDLE_DOWNLOAD)
		echo "--> Downloading Charmbracelet tools (gum, vhs)..."
		local CHARM_DIR="$OTHER_SOURCES_BUNDLE_DIR/charmbracelets"
		mkdir -p "$CHARM_DIR"

		# Download gum
		LATEST_VERSION_GUM=$(wget -qO- https://github.com/charmbracelet/gum/releases/latest | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
		if [ -n "$LATEST_VERSION_GUM" ]; then
			FILE_NAME_GUM="gum_${LATEST_VERSION_GUM#v}_Linux_x86_64.tar.gz"
			DOWNLOAD_URL_GUM="https://github.com/charmbracelet/gum/releases/download/${LATEST_VERSION_GUM}/${FILE_NAME_GUM}"
			echo "Downloading gum: $DOWNLOAD_URL_GUM"
			wget -P "$CHARM_DIR" "$DOWNLOAD_URL_GUM" || echo "Warning: Failed to download gum."
		else
			echo "Warning: Could not determine the latest version of gum."
		fi

		# Download vhs
		LATEST_VERSION_VHS=$(wget -qO- https://github.com/charmbracelet/vhs/releases/latest | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
		if [ -n "$LATEST_VERSION_VHS" ]; then
			FILE_NAME_VHS="vhs_${LATEST_VERSION_VHS#v}_Linux_x86_64.tar.gz"
			DOWNLOAD_URL_VHS="https://github.com/charmbracelet/vhs/releases/download/${LATEST_VERSION_VHS}/${FILE_NAME_VHS}"
			echo "Downloading vhs: $DOWNLOAD_URL_VHS"
			wget -P "$CHARM_DIR" "$DOWNLOAD_URL_VHS" || echo "Warning: Failed to download vhs."
		else
			echo "Warning: Could not determine the latest version of vhs."
		fi

		sudo chmod -R 777 "$CHARM_DIR"
		;;
		#!SECTION - CHARMBRACELETS BUNDLE DOWNLOAD END

	*)
		echo "ERROR: Unknown bundle type '$_BUNDLE' passed to FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA"
		;;
	esac
}
# !SECTION - FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA - END OF THE SECTION

# SECTION - GAMING SOURCES DOWNLOAD
# Downloads a comprehensive collection of gaming-related sources to create a
# full offline gaming bundle. This includes emulators, dependencies, source
# code for building, and essential assets like emulator cores.
#
# The resulting structure in the cache is:
#
#   $DEST_DIR/
#   └── gaming_bundle/
#       ├── flatpak_bundles/
#       │   └── OSTREE_FLATPAK_BUNDLES/
#       ├── emulator_assets/
#       │   ├── retroarch_cores/
#       │   └── dolphin_source/
#       │       └── DOLPHIN_APT_DEPS/
#       └── dependencies/
#           └── flatpak_installer_debs/
#
FUN_DOWNLOAD_GAMING_SOURCES() {
	echo "=============================================================================="
	echo "--- Starting Download of Gaming Sources ---"
	echo "=============================================================================="

	# --- 1. Define and Create Directory Structure ---
	# A single parent directory is used to neatly bundle all gaming-related assets.
	local GAMING_BUNDLE_DIR="$DEST_DIR/gaming_bundle"
	local FLATPAK_BUNDLE_DIR="$GAMING_BUNDLE_DIR/flatpak_gaming_bundles"
	local EMULATOR_ASSETS_DIR="$GAMING_BUNDLE_DIR/emulator_assets"
	local RETROARCH_CORES_DIR="$EMULATOR_ASSETS_DIR/retroarch_cores"
	local DOLPHIN_SOURCE_DIR="$EMULATOR_ASSETS_DIR/dolphin_source"
	local DEPENDENCIES_DIR="$GAMING_BUNDLE_DIR/dependencies"
	local FLATPAK_DEB_DIR="$DEPENDENCIES_DIR/flatpak_installer_debs"
	local DOLPHIN_DEPS_DIR="$DEPENDENCIES_DIR/dolphin_build_deps"

	sudo mkdir -p "$GAMING_BUNDLE_DIR" "$FLATPAK_BUNDLE_DIR" "$RETROARCH_CORES_DIR" "$DOLPHIN_SOURCE_DIR" "$FLATPAK_DEB_DIR" "$DOLPHIN_DEPS_DIR"
	sudo chmod -R 777 "$GAMING_BUNDLE_DIR"

	echo "All gaming sources will be saved to: $GAMING_BUNDLE_DIR"

	# --- 2. Download Flatpak Installer & Dependencies ---
	# Fetches the 'flatpak' .deb package, required for offline systems that don't have it pre-installed.
	echo "--> Downloading Flatpak installer DEBs..."
	sudo apt install --download-only -y -o Dir::Cache::archives="$FLATPAK_DEB_DIR" flatpak
	echo "Flatpak .debs saved to: $FLATPAK_DEB_DIR"

	# --- 3. Download Emulator Source Code & Build Dependencies ---
	# (a) Dolphin Emulator: Clones the full source and downloads its APT dependencies.
	echo "--> Downloading Dolphin Emulator source and build dependencies..."
	sudo apt install --download-only -y -o Dir::Cache::archives="$DOLPHIN_DEPS_DIR" \
		ca-certificates qt6-base-dev qt6-base-private-dev libqt6svg6-dev git cmake make gcc g++ pkg-config \
		libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev \
		libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev \
		libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext

	if [ ! -d "$DOLPHIN_SOURCE_DIR/.git" ]; then
		git clone https://github.com/dolphin-emu/dolphin.git "$DOLPHIN_SOURCE_DIR"
		git -C "$DOLPHIN_SOURCE_DIR" submodule update --init --recursive
		echo "Dolphin source cloned to: $DOLPHIN_SOURCE_DIR"
	else
		echo "Dolphin source already exists. Skipping clone."
	fi
	sudo chmod -R 777 "$DOLPHIN_SOURCE_DIR"

	# --- 4. Build Offline Flatpak Bundles ---
	# This step can only run on a full host OS, not in a minimal chroot, as Flatpak requires it.
	if [ "$_DEBOOTSTRAP_MODE" == "0" ]; then
		echo "--> Building offline Flatpak bundles..."
		sudo apt install -y flatpak
		if ! command -v flatpak &>/dev/null; then
			echo "ERROR: 'flatpak' command not found. Cannot build bundles."
			return 1
		fi
		sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

		local APPS_TO_BUNDLE=(io.github.ryubing.Ryujinx org.DolphinEmu.dolphin-emu org.ppsspp.PPSSPP org.libretro.RetroArch)
		echo "Temporarily installing Flatpak apps to create bundles..."
		for app_id in "${APPS_TO_BUNDLE[@]}"; do
			flatpak install --reinstall -y flathub "$app_id" || echo "Warning: Failed to install $app_id for bundling."
		done

		echo "Creating single-file bundles..."
		for app_id in "${APPS_TO_BUNDLE[@]}"; do
			if nice -n 10 flatpak create-usb "$FLATPAK_BUNDLE_DIR" "$app_id"; then
				echo "Successfully created bundle for $app_id."
			else
				echo "ERROR: Failed to create bundle for $app_id."
			fi
		done

		if [ -d "$FLATPAK_BUNDLE_DIR/.ostree" ]; then
			sudo mv "$FLATPAK_BUNDLE_DIR/.ostree" "$FLATPAK_BUNDLE_DIR/OSTREE_FLATPAK_BUNDLES"
			echo "Offline Flatpak repository created successfully."
		fi
		sudo chmod -R 777 "$FLATPAK_BUNDLE_DIR"
	else
		echo "--> Skipping Flatpak bundle creation (requires host OS, not chroot)."
	fi

	# --- 5. Download RetroArch Libretro Cores ---
	echo "--> Downloading RetroArch Libretro cores..."
	declare -A CORES=(
		["bsnes2014_balanced_libretro.so"]="bsnes2014_balanced_libretro.so.zip"
		["fbalpha2012_libretro.so"]="fbalpha2012_libretro.so.zip"
		["fbneo_libretro.so"]="fbneo_libretro.so.zip"
		["mgba_libretro.so"]="mgba_libretro.so.zip"
		["mupen64plus_next_libretro.so"]="mupen64plus_next_libretro.so.zip"
		["nestopia_libretro.so"]="nestopia_libretro.so.zip"
	)
	local base_url="https://buildbot.libretro.com/nightly/linux/x86_64/latest"
	for core_name in "${!CORES[@]}"; do
		local zip_name="${CORES[$core_name]}"
		local zip_url="$base_url/$zip_name"
		local temp_dl_file
		temp_dl_file=$(mktemp)
		echo "Downloading core: $core_name ..."
		if wget -q --show-progress -O "$temp_dl_file" "$zip_url"; then
			local temp_extract_dir
			temp_extract_dir=$(mktemp -d)
			unzip -o "$temp_dl_file" -d "$temp_extract_dir"
			local extracted_so
			extracted_so=$(find "$temp_extract_dir" -name "*.so" -type f | head -n1)
			if [ -n "$extracted_so" ]; then
				mv "$extracted_so" "$RETROARCH_CORES_DIR/$core_name"
				echo "Extracted $core_name successfully."
			else
				echo "Warning: No .so file found in $zip_name"
			fi
			rm -rf "$temp_extract_dir"
		else
			echo "Warning: Failed to download $zip_url"
		fi
		rm -f "$temp_dl_file"
	done
	sudo chmod -R 777 "$RETROARCH_CORES_DIR"
	echo "RetroArch cores saved to: $RETROARCH_CORES_DIR"

	# --- Completion ---
	echo "=============================================================================="
	echo "--- Gaming sources bundle created successfully ---"
	echo "=============================================================================="
}
# !SECTION - GAMING SOURCES DOWNLOAD - END OF THE SECTION

# SECTION - FUN_COPY_LOCAL_FILES
# Copies all necessary local project files from the current APT-AUTO-INSTALLS
# repository into the offline cache directory ($DEST_DIR). This function bundles
# assets that are part of the repository itself, rather than being downloaded
# from external sources.
#
# The resulting structure in the cache is:
#
#   $DEST_DIR/
#   └── local_files_bundle/
#       ├── themes_and_configs/
#       ├── gaming_assets/
#       ├── custom_scripts/
#       ├── supplementary_docs/
#       └── media/
#           └── videos/
#
FUN_COPY_LOCAL_FILES() {

	echo "=============================================================================="
	echo "--- Starting Copy of Local Project Files ---"
	echo "=============================================================================="

	# --- 1. Define Project and Destination Paths ---

	# Determine the script's own directory to reliably find the project root.
	local SCRIPT_DIR
	SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")

	# Dynamically find the project root by searching upwards for the .git directory.
	# This is more robust than a fixed relative path, especially when run from a chroot.
	local current_dir="$SCRIPT_DIR"
	local LOCAL_PROJECT_DIR=""
	while [ "$current_dir" != "/" ]; do
		if [ -d "$current_dir/APT-AUTO-INSTALLS" ]; then
			LOCAL_PROJECT_DIR="$current_dir/APT-AUTO-INSTALLS"
			break
		fi
		current_dir=$(dirname "$current_dir")
	done

	## DEBUG ECHOS
	echo "Script directory: $SCRIPT_DIR"
	echo "Determined project root directory: $LOCAL_PROJECT_DIR"

	# Define a single, clearly-named parent directory for all local files in the cache.
	local LOCAL_FILES_BUNDLE_DIR="$DEST_DIR/local_files_bundle"
	sudo mkdir -p "$LOCAL_FILES_BUNDLE_DIR"
	sudo chmod -R 777 "$LOCAL_FILES_BUNDLE_DIR"

	echo "Source project directory: $LOCAL_PROJECT_DIR"
	echo "Copying local project files to: $LOCAL_FILES_BUNDLE_DIR"

	# Safety check: ensure the determined project directory exists before proceeding.
	if [ -z "$LOCAL_PROJECT_DIR" ] || [ ! -d "$LOCAL_PROJECT_DIR" ]; then
		echo "Error: Could not find project root directory. Looked for APT-AUTO-INSTALLS folder upwards from $SCRIPT_DIR."
		echo "Cannot copy local files. Skipping this step."
		return 1
	fi

	# --- 2. Copy Asset Categories into Structured Bundles ---

	# (a) Copy Themes and Configs
	# These are .7z archives containing desktop environment settings, panel layouts, etc.
	echo "--> Copying themes and configs..."
	local THEMES_BUNDLE_DIR="$LOCAL_FILES_BUNDLE_DIR/themes_and_configs"
	mkdir -p "$THEMES_BUNDLE_DIR"
	sudo chmod -R 777 "$THEMES_BUNDLE_DIR"
	find "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/THEMES-N-DOTFILES/" -name "*.7z" -exec cp {} "$THEMES_BUNDLE_DIR/" \; || {
		echo "Error: Failed to copy theme and config files."
		exit 1
	}

	# (b) Copy Local Gaming Assets
	# Includes firmware, BIOS files, and product keys needed for emulators.
	echo "--> Copying local gaming assets..."
	local GAMING_ASSETS_BUNDLE_DIR="$LOCAL_FILES_BUNDLE_DIR/gaming_assets"
	mkdir -p "$GAMING_ASSETS_BUNDLE_DIR"
	sudo chmod -R 777 "$GAMING_ASSETS_BUNDLE_DIR"
	find "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/GAMING/" -name "*.zip" -exec cp {} "$GAMING_ASSETS_BUNDLE_DIR/" \; || {
		echo "Error: Failed to copy gaming .zip assets."
		exit 1
	}
	find "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/GAMING/" -name "*.7z" -exec cp {} "$GAMING_ASSETS_BUNDLE_DIR/" \; || {
		echo "Error: Failed to copy gaming .7z assets."
		exit 1
	}

	# (c) Copy Custom Shell Scripts
	# All custom helper scripts from the 'CUSTOM-SH-SCRIPTS' directory.
	echo "--> Copying custom shell scripts..."
	local SCRIPTS_BUNDLE_DIR="$LOCAL_FILES_BUNDLE_DIR/custom_scripts"
	mkdir -p "$SCRIPTS_BUNDLE_DIR"
	sudo chmod -R 777 "$SCRIPTS_BUNDLE_DIR"
	cp -r "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/WARES/CUSTOM-WARES-BY-ME/CUSTOM-SH-SCRIPTS/." "$SCRIPTS_BUNDLE_DIR/" || {
		echo "Error: Failed to copy custom scripts."
		exit 1
	}

	# (d) Copy Supplementary Documentation
	# This includes guides, PDFs, and other resources from the 'WARES-INCLUDED' directory.
	echo "--> Copying supplementary documentation..."
	local DOCS_BUNDLE_DIR="$LOCAL_FILES_BUNDLE_DIR/supplementary_docs"
	mkdir -p "$DOCS_BUNDLE_DIR"
	sudo chmod -R 777 "$DOCS_BUNDLE_DIR"
	cp -r "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/WARES/WARES-INCLUDED/." "$DOCS_BUNDLE_DIR/" || {
		echo "Error: Failed to copy supplementary documentation."
		exit 1
	}

	# (e) Copy Media Assets (Videos)
	# Copies video files used for live wallpapers.
	echo "--> Copying media assets (videos)..."
	local MEDIA_BUNDLE_DIR="$LOCAL_FILES_BUNDLE_DIR/media/videos"
	mkdir -p "$MEDIA_BUNDLE_DIR"
	sudo chmod -R 777 "$MEDIA_BUNDLE_DIR"
	cp -r "$LOCAL_PROJECT_DIR/AUTO-INSTALLS-FILES/BACKGROUND-IMAGES-VIDEOS/VIDEOS/." "$MEDIA_BUNDLE_DIR/" || {
		echo "Error: Failed to copy video files."
		exit 1
	}
	sudo chmod -R 777 "$LOCAL_FILES_BUNDLE_DIR"
	echo "Local project files successfully copied to the cache."
}
# !SECTION - FUN_COPY_LOCAL_FILES - END OF THE SECTION

# SECTION - Main Execution Logic
# Display the main menu to the user in a loop.
while true; do

	CHOICE_CACHE=$1
	DEST_DIR=$2
	_DEBOOTSTRAP_MODE=$3

	#  TODO : ^^^^^ validate arguments / positional parameters

	# skip all the sources list modifications / dependency package downloads ..etc.
	# when the $CHOICE_CACHE doesnt require it (just exec and exit)
	if [ "$CHOICE_CACHE" == "COPY_LOCAL" ]; then
		FUN_COPY_LOCAL_FILES
		exit 0
	fi

	# TODO - put some colorized ECHOS HERE ... INFORM : CHOICE_CACHE, DEST_DIR

	# SECTION - Pre-flight Checks and Setup

	# Determine which temporary dependencies are needed for the chosen action
	NEEDS_SOFTWARE_PROPERTIES_COMMON=0
	NEEDS_WGET=0
	NEEDS_JQ=0
	NEEDS_UNZIP=0
	NEEDS_GIT=0
	NEEDS_CURL=0
	case $CHOICE_CACHE in
	"APT_PKGS") # APT packages only
		NEEDS_SOFTWARE_PROPERTIES_COMMON=1
		;;
	"OTHER_SOURCES") # Other sources
		NEEDS_WGET=1
		NEEDS_GIT=1
		NEEDS_CURL=1
		NEEDS_JQ=1
		;;
	"GAMING_SOURCES") # Gaming
		NEEDS_GIT=1
		NEEDS_UNZIP=1
		NEEDS_WGET=1
		;;
	"VSCODE_BUNDLE") # VSCode
		NEEDS_WGET=1
		NEEDS_CURL=1
		NEEDS_JQ=1
		;;
	"ANTIGRAVITY_BUNDLE") # Antigravity
		NEEDS_CURL=1
		NEEDS_JQ=1
		;;
	"OLLAMA_BUNDLE") # Ollama
		NEEDS_CURL=1
		;;
	"LLAMA_CPP_BUNDLE") # Llama.cpp
		NEEDS_CURL=1
		NEEDS_JQ=1
		;;
	"ALL_NO_ARCHIVE" | "ALL_AND_ARCHIVE") # EVERYTHING
		NEEDS_GIT=1
		NEEDS_CURL=1
		;;
	esac

	# ensure needed repo sources are enabled ::::

	# # first create a backup of /etc/apt/sources.list
	# [ ! -f /etc/apt/sources.list.bak ] && sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

	# # Extract codename (e.g., noble, jammy, focal)
	# _UBUNTU_CODENAME=$(grep ^UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '[:space:]')
	# # Ensure main exist only once
	# if ! grep -q "^deb .* ${_UBUNTU_CODENAME} main" /etc/apt/sources.list; then
	# 	echo "Adding default Ubuntu repositories for ${_UBUNTU_CODENAME}..."
	# 	echo "deb http://archive.ubuntu.com/ubuntu ${_UBUNTU_CODENAME} main" |
	# 		sudo tee -a /etc/apt/sources.list
	# fi
	# # Ensure universe/multiverse/restricted exist only once
	# if ! grep -q "^deb .* ${_UBUNTU_CODENAME} universe restricted multiverse" /etc/apt/sources.list; then
	# 	echo "Adding extended Ubuntu repositories for ${_UBUNTU_CODENAME}..."
	# 	echo "deb http://archive.ubuntu.com/ubuntu ${_UBUNTU_CODENAME} universe restricted multiverse" |
	# 		sudo tee -a /etc/apt/sources.list
	# fi
	# sudo apt update

	# comented out the modern way [touches /etc/apt/sources.list.d/ubuntu.sources] -
	# for when legacy method goes bust ^^^ above !! EDIT !! LEGACY METHOD HAS GONE BUST ! - IT CREATES CONFLICTS - USING MODERN METHOD
	sudo apt update
	sudo apt install -y software-properties-common
	sudo add-apt-repository -y universe restricted multiverse || { echo -ne "\n" | sudo add-apt-repository universe restricted multiverse; }
	sudo apt update
	#

	# Install needed dependencies only if they are missing
	DEPS_TO_INSTALL=()
	if [ "$NEEDS_SOFTWARE_PROPERTIES_COMMON" -eq 1 ] && ! dpkg -s software-properties-common &>/dev/null; then DEPS_TO_INSTALL+=("software-properties-common"); fi
	if [ "$NEEDS_WGET" -eq 1 ] && ! command -v wget &>/dev/null; then DEPS_TO_INSTALL+=("wget"); fi
	if [ "$NEEDS_JQ" -eq 1 ] && ! command -v jq &>/dev/null; then DEPS_TO_INSTALL+=("jq"); fi
	if [ "$NEEDS_UNZIP" -eq 1 ] && ! command -v unzip &>/dev/null; then DEPS_TO_INSTALL+=("unzip"); fi
	if [ "$NEEDS_GIT" -eq 1 ] && ! command -v git &>/dev/null; then DEPS_TO_INSTALL+=("git"); fi
	if [ "$NEEDS_CURL" -eq 1 ] && ! command -v curl &>/dev/null; then DEPS_TO_INSTALL+=("curl"); fi

	if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
		echo -e "\n""\e[1;48;5;166m" "Installing temporary dependencies: ${DEPS_TO_INSTALL[*]}..." "\e[0m"
		for _PKG in "${DEPS_TO_INSTALL[@]}"; do
			sudo apt update
			sudo apt install -y "${DEPS_TO_INSTALL[@]}"
		done
		echo -e "\n""\e[1;48;5;166m" "INSTALLED: ${DEPS_TO_INSTALL[*]}" "\e[0m"
	fi
	# !SECTION - Pre-flight Checks and Setup - END OF THE SECTION

	# define all args for the function to use
	# then we can go over them in a for loop
	_OTHER_SOURCES_BUNDLES_ARRAY=(
		_SCRCPY_BUNDLE_DOWNLOAD
		_VSCODE_BUNDLE_DOWNLOAD
		_ANTIGRAVITY_CLI_BUNDLE_DOWNLOAD
		_OLLAMA_BUNDLE_DOWNLOAD
		_LLAMA_CPP_BUNDLE_DOWNLOAD
		_FASTFETCH_BUNDLE_DOWNLOAD
		_GNOME_SHELL_EXTENSIONS_BUNDLE_DOWNLOAD
		_VIRTUALBOX_BUNDLE_DOWNLOAD
		_GENYMOTION_BUNDLE_DOWNLOAD
		_GOOGLE_CHROME_BUNDLE_DOWNLOAD
		_CHARMBRACELETS_BUNDLE_DOWNLOAD
	)

	# Process the user's choice using a case statement.
	case $CHOICE_CACHE in
	"APT_PKGS")
		FUN_DOWNLOAD_APT_PACKAGES
		break
		;;
	"OTHER_SOURCES")
		# we exclude vscode, ollama & llama.cpp bundle here since they have their own dedicated option
		for bundle_name in "${_OTHER_SOURCES_BUNDLES_ARRAY[@]}"; do
			if [ "$bundle_name" != "_VSCODE_BUNDLE_DOWNLOAD" ] && [ "$bundle_name" != "_OLLAMA_BUNDLE_DOWNLOAD" ] && [ "$bundle_name" != "_LLAMA_CPP_BUNDLE_DOWNLOAD" ]; then # Exclude VSCode, Ollama, Llama.cpp as they have dedicated options
				FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "$bundle_name"
			fi
		done
		break
		;;
	"GAMING_SOURCES")
		FUN_DOWNLOAD_GAMING_SOURCES
		break
		;;
	"VSCODE_BUNDLE")
		FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "_VSCODE_BUNDLE_DOWNLOAD"
		break
		;;
	"ANTIGRAVITY_BUNDLE")
		FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "_ANTIGRAVITY_CLI_BUNDLE_DOWNLOAD"
		break
		;;
	"OLLAMA_BUNDLE")
		FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "_OLLAMA_BUNDLE_DOWNLOAD"
		break
		;;
	"LLAMA_CPP_BUNDLE")
		FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "_LLAMA_CPP_BUNDLE_DOWNLOAD"
		break
		;;
	"COPY_LOCAL")
		FUN_COPY_LOCAL_FILES
		break
		;;
	"ALL_NO_ARCHIVE")
		# download all apt packages from repo to cache
		FUN_DOWNLOAD_APT_PACKAGES
		# download all non repo/ppa bundles to cache
		for bundle_name in "${_OTHER_SOURCES_BUNDLES_ARRAY[@]}"; do
			FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "$bundle_name"
		done
		# download gaming bundles to cache
		FUN_DOWNLOAD_GAMING_SOURCES
		# copy necessary local files from the project directory into the cache
		FUN_COPY_LOCAL_FILES
		break
		;;
	"ALL_AND_ARCHIVE")
		# download all apt packages from repo to cache
		FUN_DOWNLOAD_APT_PACKAGES
		# download all non repo/ppa bundles to cache
		for bundle_name in "${_OTHER_SOURCES_BUNDLES_ARRAY[@]}"; do
			FUN_DOWNLOAD_COMPLEX_LOGIC_APTS_AND_FROM_OTHER_SOURCES_NON_APTS_NOR_PPA "$bundle_name"
		done
		# download gaming bundles to cache
		FUN_DOWNLOAD_GAMING_SOURCES
		# copy necessary local files from the project directory into the cache
		FUN_COPY_LOCAL_FILES
		# create a compressed tarball of the entire cache
		FUN_CREATE_TAR_ARCHIVE
		break
		;;
	"EXIT")
		echo "Exiting."
		exit 0
		;;
	*)
		echo "Invalid choice."
		exit 1
		;;
	esac
done
# !SECTION - Main Execution Logic - END OF THE SECTION

#### # Purge dependencies that were installed by this script run
#### if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
#### 	echo "Removing temporary dependencies..."
#### 	sudo apt-get purge -y "${DEPS_TO_INSTALL[@]}"
#### 	sudo apt-get autoremove -y
#### 	sudo apt-get clean -y
#### fi

# Display a final completion message.
echo "Offline cache creation process finished. Files are located in: $DEST_DIR"
