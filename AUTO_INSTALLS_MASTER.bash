#!/bin/bash

### Do not run this script as `sudo`. Run it as a normal user; it will prompt for the sudo password when required.
### Always execute this script by its absolute path to avoid unexpected behavior.
### For consistency, try to be in the script's directory when running it.

# Get the absolute directory path of this script and change to that directory.
# Exits the script if the directory change fails.
CD_DIRNAME=$(dirname "$(realpath $0)")
cd "$CD_DIRNAME" || exit

# Define colors using an associative array for better organization (works in 99.9% of terminals)
declare -A COLORS=(
	[RESET]=$'\033[0m'
	[BOLD]=$'\033[1m'
	[DIM]=$'\033[2m'
	[GREEN]=$'\033[32m'
	[CYAN]=$'\033[96m'
	[YELLOW]=$'\033[93m'
	[RED]=$'\033[31m'
)
CHECK="${COLORS[GREEN]}✓${COLORS[RESET]}"
CROSS="${COLORS[DIM]}✗${COLORS[RESET]}"

# Initialize global tracking arrays
_ARRAY_ALL_PACKAGES=()
_ARRAY_NON_APT_SUCCESS=()
_ARRAY_NON_APT_FAIL=()
_array_counter=0

# SECTION - HELPER FUNCTIONS
# Function: Track non-APT installations (Flatpaks, AppImages, manual builds, etc.)
# usage: FUN_TRACK_CUSTOM_INSTALL "Package/Software Name" "success" or "fail"
FUN_TRACK_CUSTOM_INSTALL() {
	local item_name="$1"
	local status="$2" # "success" or "fail"
	if [[ "$status" == "success" ]]; then
		_ARRAY_NON_APT_SUCCESS+=("$item_name")
	else
		_ARRAY_NON_APT_FAIL+=("$item_name")
	fi
}

# Function: Display a verbose installation message and update packages.
# This function prints a banner with the package name, updates the package lists,
# fixes any broken dependencies, and then prints the banner again.
FUN_VERBOSE_INSTALLING() {
	BANNER_PKG_NAME_MSG=$1
	echo ""
	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0
	sudo apt update
	sleep 1
	sudo apt --fix-broken install -y
	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0
}

# Function: Display a verbose installation message without updating packages.
# This function is similar to FUN_VERBOSE_INSTALLING but skips the `apt update`
# and `apt --fix-broken install` steps.
FUN_VERBOSE_INSTALLING_NO_APT_UPDATE() {
	BANNER_PKG_NAME_MSG=$1
	echo ""
	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0
}

# Function: Display a block-style indicator for the current choice.
# This function prints a decorative block with the name of the currently
# selected installation choice.
FUN_CHOICE_BLOCK_INDICATOR() {
	CHOICE_BLOCK_INDICATOR=$1
	echo ""
	tput setab 112
	tput setaf 234
	tput bold
	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."

	echo -e "\n-_-_-_-_-_-_-_-_-_-_-_ Installing $CHOICE_BLOCK_INDICATOR _-_-_-_-_-_-_-_-_-_-_- \n"

	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."
	tput sgr0
}

# Function: Check the installation status of packages and store the results in arrays.
# This function adds the package name to a global array for tracking.
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER() {
	PKG_NAME=$1
	for _FLATTENED_PKG in $PKG_NAME; do
		[[ -z "$_FLATTENED_PKG" ]] && continue
		_ARRAY_ALL_PACKAGES[$_array_counter]="$_FLATTENED_PKG"
		_array_counter=$((_array_counter + 1))
	done
}

# Function: Display the final installation status and perform a comprehensive system audit.
# This function iterates through the tracked packages, checks their installation
# status, and prints a summary. It also performs a system-wide audit of all installed
# software (including source-built binaries and custom scripts) and saves it to a file.
FUN_FINAL_INSTALLED_STATUS() {
	if [[ ${#_ARRAY_ALL_PACKAGES[@]} -eq 0 && ${#_ARRAY_NON_APT_SUCCESS[@]} -eq 0 && ${#_ARRAY_NON_APT_FAIL[@]} -eq 0 ]]; then
		return
	fi

	_ARRAY_SUCCESS=()
	_ARRAY_FAIL=()

	for LOOP_PKG in "${_ARRAY_ALL_PACKAGES[@]}"; do
		[[ -z "$LOOP_PKG" ]] && continue
		if dpkg-query -W -f='${db:Status-Status}' "$LOOP_PKG" 2>/dev/null | grep -q '^installed$'; then
			_ARRAY_SUCCESS+=("$LOOP_PKG")
		else
			_ARRAY_FAIL+=("$LOOP_PKG")
		fi
	done

	# --- Comprehensive System Audit (Source-Built Binaries, Snaps, Flatpaks, etc.) ---
	local AUDIT_REPORT="$HOME/SYSTEM_SOFTWARE_AUDIT_$(date +%Y-%m-%d_%H-%M-%S).txt"
	local USER_NAME="${SUDO_USER:-$(logname)}"
	local USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)

	{
		echo "=========================================================================="
		echo "          COMPREHENSIVE SYSTEM SOFTWARE AUDIT REPORT"
		echo "          Date: $(date)"
		echo "          Machine: $(hostname)"
		echo "=========================================================================="

		echo -e "\n[1] --- CURRENT SESSION: SUCCESSFULLY INSTALLED (APT) ---"
		if [[ ${#_ARRAY_SUCCESS[@]} -gt 0 ]]; then
			printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u
		else
			echo "None"
		fi

		if [[ ${#_ARRAY_NON_APT_SUCCESS[@]} -gt 0 ]]; then
			echo -e "\n[1.1] --- CURRENT SESSION: SUCCESSFULLY INSTALLED (CUSTOM/MANUAL) ---"
			printf "%s\n" "${_ARRAY_NON_APT_SUCCESS[@]}" | sort -u
		fi

		if [[ ${#_ARRAY_FAIL[@]} -gt 0 ]]; then
			echo -e "\n[!] --- CURRENT SESSION: FAILED INSTALLATIONS (APT) ---"
			printf "%s\n" "${_ARRAY_FAIL[@]}" | sort -u
		fi

		if [[ ${#_ARRAY_NON_APT_FAIL[@]} -gt 0 ]]; then
			echo -e "\n[!] --- CURRENT SESSION: FAILED INSTALLATIONS (CUSTOM/MANUAL) ---"
			printf "%s\n" "${_ARRAY_NON_APT_FAIL[@]}" | sort -u
		fi

		echo -e "\n[2] --- SYSTEM-WIDE: APT / DPKG PACKAGES ---"
		dpkg-query -W -f='${Package} (${Version})\n' | sort

		if command -v snap &>/dev/null; then
			echo -e "\n[3] --- SYSTEM-WIDE: SNAP PACKAGES ---"
			snap list | awk 'NR>1 {print $1 " (" $2 ")"}' | sort
		fi

		if command -v flatpak &>/dev/null; then
			echo -e "\n[4] --- SYSTEM-WIDE: FLATPAK PACKAGES ---"
			flatpak list --columns=application,version,origin | awk 'NR>1 {print $1 " (" $2 ") [" $3 "]"}' | sort
		fi

		echo -e "\n[5] --- SYSTEM-WIDE: LOCAL BINARIES, OPT & APPIMAGES (/usr/local, /opt, ~/.local/bin, ~/.Applications) ---"
		echo "(Includes software built from source, manual installs, and AppImages)"
		{
			ls -1 /usr/local/bin /usr/local/sbin 2>/dev/null
			ls -1 /usr/local/go/bin 2>/dev/null
			ls -1 /usr/local/games /usr/games 2>/dev/null
			ls -1 /opt 2>/dev/null
			ls -1 "$USER_HOME/.local/bin" 2>/dev/null
			ls -1 "$USER_HOME/.Applications" 2>/dev/null
		} | sort -u

		echo -e "\n[6] --- SYSTEM-WIDE: DEVELOPMENT ENVIRONMENTS (Go, Node, Python, Rust) ---"
		if command -v go &>/dev/null; then echo "Go Version: $(go version)"; fi
		if command -v tinygo &>/dev/null; then echo "TinyGo Version: $(tinygo version)"; fi
		if [ -d "$USER_HOME/.nvm" ]; then
			export NVM_DIR="$USER_HOME/.nvm"
			[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
			echo "Node.js (nvm) Version: $(node -v 2>/dev/null || echo 'Not active')"
			echo "npm Version: $(npm -v 2>/dev/null || echo 'Not active')"
		fi
		if command -v gemini &>/dev/null; then echo "Gemini CLI Version: $(gemini -v 2>/dev/null || echo 'Found but version check failed')"; fi
		if command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
			local pip_cmd="pip"
			command -v pip3 &>/dev/null && pip_cmd="pip3"
			echo -e "\n--- Python Packages ($pip_cmd list) ---"
			$pip_cmd list --format=freeze 2>/dev/null | head -n 200
			echo "[... first 200 packages listed ...]"
		fi
		if command -v cargo &>/dev/null; then
			echo -e "\n--- Rust / Cargo Binaries (ls ~/.cargo/bin) ---"
			ls -1 "$USER_HOME/.cargo/bin" 2>/dev/null
		fi

		echo -e "\n[7] --- SYSTEM-WIDE: CUSTOM SCRIPTS (/bin) ---"
		{
			ls -1 /bin/CUSTOM-SH-SCRIPTS 2>/dev/null
			ls -1 /bin/custom-* 2>/dev/null | xargs -n1 basename 2>/dev/null
		} | sort -u

		echo -e "\n[8] --- SYSTEM-WIDE: DESKTOP APPLICATIONS ---"
		grep -rhE "^Name=" /usr/share/applications/ "$USER_HOME/.local/share/applications/" 2>/dev/null | sed 's/Name=//' | sort -u

		echo -e "\n[9] --- SYSTEM-WIDE: GNOME SHELL EXTENSIONS (/usr/share & ~/.local/share) ---"
		{
			ls -1 /usr/share/gnome-shell/extensions/ 2>/dev/null
			ls -1 "$USER_HOME/.local/share/gnome-shell/extensions/" 2>/dev/null
		} | sort -u

		echo -e "\n[10] --- SYSTEM-WIDE: VSCODE EXTENSIONS (~/.vscode/extensions) ---"
		if [ -d "$USER_HOME/.vscode/extensions" ]; then
			ls -1 "$USER_HOME/.vscode/extensions" | grep -v "DEPENDENCY-BINARIES" | sort -u
		else
			echo "None"
		fi

		echo -e "\n[11] --- SYSTEM-WIDE: PPA REPOSITORIES ---"
		grep -rhE "^deb" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null | grep "ppa.launchpad" | awk '{print $2}' | sort -u

		echo -e "\n[12] --- SYSTEM-WIDE: ALL EXECUTABLES IN PATH ---"
		local IFS=:
		for dir in $PATH; do
			ls -1 "$dir" 2>/dev/null
		done | sort -u

	} >"$AUDIT_REPORT"

	# --- Terminal Display ---
	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ :-D FINALIZED :-D _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0

	if [[ ${#_ARRAY_SUCCESS[@]} -gt 0 ]]; then
		echo -e ":: SUCCESSFULLY INSTALLED PACKAGES (Current Session - APT) ::\n"
		printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u | cat | sed "s/^/${COLORS[GREEN]}/;s/$/${COLORS[RESET]}/"
		echo ""
	fi

	if [[ ${#_ARRAY_NON_APT_SUCCESS[@]} -gt 0 ]]; then
		echo -e ":: SUCCESSFULLY INSTALLED (Current Session - CUSTOM/MANUAL) ::\n"
		printf "%s\n" "${_ARRAY_NON_APT_SUCCESS[@]}" | sort -u | cat | sed "s/^/${COLORS[GREEN]}/;s/$/${COLORS[RESET]}/"
		echo ""
	fi

	if [[ ${#_ARRAY_FAIL[@]} -gt 0 ]]; then
		echo -e ":: ERRONEOUSLY INSTALLED PACKAGES (Current Session - APT) ::\n"
		printf "%s\n" "${_ARRAY_FAIL[@]}" | sort -u | cat | sed "s/^/${COLORS[RED]}/;s/$/${COLORS[RESET]}/"
		echo ""
	fi

	if [[ ${#_ARRAY_NON_APT_FAIL[@]} -gt 0 ]]; then
		echo -e ":: ERRONEOUSLY INSTALLED (Current Session - CUSTOM/MANUAL) ::\n"
		printf "%s\n" "${_ARRAY_NON_APT_FAIL[@]}" | sort -u | cat | sed "s/^/${COLORS[RED]}/;s/$/${COLORS[RESET]}/"
		echo ""
	fi

	echo -e "${COLORS[CYAN]}╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗${COLORS[RESET]}"
	echo -e "${COLORS[CYAN]}║${COLORS[RESET]}${COLORS[BOLD]} COMPREHENSIVE SOFTWARE AUDIT REPORT GENERATED:${COLORS[RESET]}${COLORS[CYAN]} ${COLORS[RESET]}"
	echo -e "${COLORS[CYAN]}║${COLORS[RESET]} $AUDIT_REPORT ${COLORS[CYAN]} ${COLORS[RESET]}"
	echo -e "${COLORS[CYAN]}╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}"
}
# !SECTION - HELPER FUNCTIONS - END OF THE SECTION

##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##        for running a command as root  one liner :: sudo su -c ' command to run'

############# file descriptors 0, 1 and 2 also known as
#############  # 0 standard input (stdin),
#############  # 1 standard output (stdout)
#############  # 2 and standard error (stderr).
#############  #or ?
#############  # 1 stdin
#############  # 2 stdout
#############  # 3 error
#############  foobar=$(whiptail --inputbox "REDIRECT TEST Enter some text" 10 30  3>&1 1>&2 2>&3)
#############  ( 3>&1 1>&2 2>&3 )
#############  # error to input
#############  # input to output
#############  # output to error

##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)

# SECTION - MAIN MENU
# Menu: Present the user with options via a checklist.
# This is the main menu of the script, displayed to the user using `whiptail`.
# The user can select one or more options to perform various installation and
# configuration tasks.
MAIN_CHOICE=$(whiptail --separate-output --title "AUTO-INSTALLS-MASTER!" \
	--backtitle "RUN SCRIPT BY ITS ABSOLUTE PATH!" \
	--checklist "Choice" 0 0 21 \
	0 "COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]" off \
	1 "MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU] (Wares for all [MATE DE] Desktops" off \
	2 "[MATE Desktops ! FULL SEND] Executes options 1, 3, 4" off \
	3 "Manually installed Wares Only [.DEB Files]" off \
	4 "[MATE Desktops] COPY MATE PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
	UBUNTU_GNOME_VANILLA "[UBUNTU SPECIFIC] Wares for Ubuntu Vanilla [GNOME DE]" off \
	UBUNTU_GNOME_FULL_SEND "[UBUNTU SPECIFIC !!! Full Send !!!] Executes options UBUNTU_GNOME_VANILLA+3+7+13+14+WOL" off \
	7 "[UBUNTU SPECIFIC] COPY GNOME PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
	DEBIAN_GNOME "[DEBIAN] Wares for Debian [GNOME DE]" off \
	9 "[FONTS] Install Comprehensive Font Set" off \
	"IMPORT_WIFI" "Import pre-saved Wi-Fi networks for headless/server installs" off \
	10 "INSTALL ALL GAMING CONSOLES ONLY" off \
	11 "INSTALL [INTEL OPENCL RUNTIME]" off \
	12 "[UBUNTU SPECIFIC] INSTALL GAMING CONSOLES INDIVIDUALLY" off \
	13 "Reinstall custom shell scripts to /bin and add user permissions" off \
	14 "Reinstall WARES-INCLUDED to \$HOME and to /etc/skel" off \
	15 "[CACHE UBUNTU] Create Full Offline Cache (ONLY! on clean system)" off \
	16 "[CACHE DEPLOY UBUNTU] Install Full System using Local Cache" off \
	"WOL" "Wake On LAN Copy WOL Targets to /bin" off \
	17 "[VSCODE] install only vscode" off \
	POST_INSTALL_WORKFLOW_UBUNTU "Run Post Install Workflow" off \
	3>&1 1>&2 2>&3)

echo "Chosen options: $MAIN_CHOICE"

# Process the chosen options from the checklist.
# The output from whiptail is a string of selected numbers, which is sanitized
# and then looped through to execute the corresponding functions.
MAIN_CHOICE_SANITIZED=$(echo "$MAIN_CHOICE" | sed 's/"//g')
# !SECTION - MAIN MENU - END OF THE SECTION

# SECTION - MAIN CASE STATEMENT
for CHOOSER in $MAIN_CHOICE_SANITIZED; do

	# Ask for the sudo password upfront and keep the session alive.
	# This starts a background process that periodically runs `sudo -v`
	# to refresh the sudo timestamp, preventing it from expiring during the build.
	sudo -v
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
	MASTER_SUDO_KEEPALIVE_PID=$!

	case $CHOOSER in
	0)
		echo -e "${COLORS[YELLOW]}► Running 0:${COLORS[RESET]} COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_0
		echo -e "${COLORS[GREEN]}✔ Done with Choice 0${COLORS[RESET]}"
		;;
	1)
		echo -e "${COLORS[YELLOW]}► Running 1:${COLORS[RESET]} MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU]"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_1
		echo -e "${COLORS[GREEN]}✔ Done with Choice 1${COLORS[RESET]}"
		;;
	2)
		echo -e "${COLORS[YELLOW]}► Running 2:${COLORS[RESET]} [MATE Desktops ! FULL SEND] Executes options 1 3 4"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_2
		echo -e "${COLORS[GREEN]}✔ Done with Choice 2${COLORS[RESET]}"
		;;
	3)
		echo -e "${COLORS[YELLOW]}► Running 3:${COLORS[RESET]} Manually installed Wares Only [.DEB Files Only]"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_3
		echo -e "${COLORS[GREEN]}✔ Done with Choice 3${COLORS[RESET]}"
		;;
	4)
		#NOTED: this is done using dconf [if you want it done via terminal] (but only works if access to GUI)...[cubic doesn't have gui] in cubic we copy the ~/.config/dconf/User file
		echo -e "${COLORS[YELLOW]}► Running 4:${COLORS[RESET]} [MATE Desktops] COPY MATE PANEL SETTING & APP CONFIGS TO /ETC/SKEL {Depending On Chosen MATE DE Distro}"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_4
		echo -e "${COLORS[GREEN]}✔ Done with Choice 4${COLORS[RESET]}"
		;;
	UBUNTU_GNOME_VANILLA)
		echo -e "${COLORS[YELLOW]}► Running UBUNTU_GNOME_VANILLA:${COLORS[RESET]} [UBUNTU'S SPECIFIC] (Wares for Ubuntu Vanilla [GNOME DE])"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_UBUNTU_GNOME_VANILLA
		echo -e "${COLORS[GREEN]}✔ Done with Choice 5${COLORS[RESET]}"
		;;
	UBUNTU_GNOME_FULL_SEND)
		echo -e "${COLORS[YELLOW]}► Running UBUNTU_GNOME_FULL_SEND:${COLORS[RESET]} [UBUNTU'S SPECIFIC !!! Full Send !!!] Executes options: UBUNTU_GNOME_VANILLA, 3, 7, 13, 14"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_UBUNTU_GNOME_FULL_SEND
		echo -e "${COLORS[GREEN]}✔ Done with Choice 6${COLORS[RESET]}"
		;;
	7)
		echo -e "${COLORS[YELLOW]}► Running 7:${COLORS[RESET]} [UBUNTU'S SPECIFIC] COPY GNOME PANEL SETTING & APP CONFIGS TO /ETC/SKEL"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_7
		echo -e "${COLORS[GREEN]}✔ Done with Choice 7${COLORS[RESET]}"
		;;
	DEBIAN_GNOME)
		echo -e "${COLORS[YELLOW]}► Running DEBIAN_GNOME:${COLORS[RESET]} [ DEBIAN ] (Wares for DEBIAN [GNOME DE])"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_DEBIAN_GNOME
		echo -e "${COLORS[GREEN]}✔ Done with Choice 8${COLORS[RESET]}"
		;;
	9)
		echo -e "${COLORS[YELLOW]}► Running 9:${COLORS[RESET]} [FONTS] Install Comprehensive Font Set"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_9
		echo -e "${COLORS[GREEN]}✔ Done with Choice 9${COLORS[RESET]}"
		;;

	IMPORT_WIFI)
		echo -e "${COLORS[YELLOW]}► Running IMPORT_WIFI:${COLORS[RESET]} Installs a one-shot service to import WiFi networks on first boot for headless systems"

		sudo mkdir -p /bin/CUSTOM-WIFI-MIGRATOR/HEADLESS-WIFI-IMPORT
		sudo chmod -R 777 /bin/CUSTOM-WIFI-MIGRATOR/HEADLESS-WIFI-IMPORT
		sudo cp -f ./AUTO-INSTALLS-FILES/HEADLESS-WIFI-IMPORT/wifi_networks.txt /bin/CUSTOM-WIFI-MIGRATOR/HEADLESS-WIFI-IMPORT/

		# must run as sudo , requieres root. and must be sourced as sudo / root
		sudo bash -c "source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB ; FUN_MAIN_CHOICE_IMPORT_WIFI /bin/CUSTOM-WIFI-MIGRATOR/HEADLESS-WIFI-IMPORT/wifi_networks.txt"
		echo -e "${COLORS[GREEN]}✔ Done with Choice IMPORT_WIFI${COLORS[RESET]}"
		;;

	10)
		echo -e "${COLORS[YELLOW]}► Running 10:${COLORS[RESET]} INSTALL ALL GAMING CONSOLES ONLY"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_10
		echo -e "${COLORS[GREEN]}✔ Done with Choice 10${COLORS[RESET]}"
		;;
	11)
		echo -e "${COLORS[YELLOW]}► Running 11:${COLORS[RESET]} INSTALL [INTEL OPENCL RUNTIME]"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_11
		echo -e "${COLORS[GREEN]}✔ Done with Choice 11${COLORS[RESET]}"
		;;
	12)
		echo -e "${COLORS[YELLOW]}► Running 12:${COLORS[RESET]} [UBUNTU'S SPECIFIC] INSTALL GAMING CONSOLES INDIVIDUALLY"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_12
		echo -e "${COLORS[GREEN]}✔ Done with Choice 12${COLORS[RESET]}"
		;;
	13)
		echo -e "${COLORS[YELLOW]}► Running 13:${COLORS[RESET]} (RE)Install CUSTOM-SH-SCRIPTS to /bin/CUSTOM-SH-SCRIPTS & /bin And add user permissions to Them [chmod 777]"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_13
		echo -e "${COLORS[GREEN]}✔ Done with Choice 13${COLORS[RESET]}"
		;;
	14)
		echo -e "${COLORS[YELLOW]}► Running 14:${COLORS[RESET]} Reinstall WARES-INCLUDED to \$HOME and to /etc/skel"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_14
		echo -e "${COLORS[GREEN]}✔ Done with Choice 14${COLORS[RESET]}"
		;;
	15)
		echo -e "${COLORS[YELLOW]}► Running 15:${COLORS[RESET]} [UBUNTU] OFFLINE CACHE CREATOR -> run on system w/o the target pkgs installed"
		# sudo ./WARES-LIB/OFFLINE-CACHE-CREATOR-OR-INSTALLER/CREATE_OFFLINE_CACHE_LIB.bash
		sudo ./WARES-LIB/OFFLINE-CACHE-CREATOR-OR-INSTALLER/CACHE_ORCHESTRATOR.bash
		echo -e "${COLORS[GREEN]}✔ Done with Choice 15${COLORS[RESET]}"
		;;
	16)
		echo -e "${COLORS[YELLOW]}► Running 16:${COLORS[RESET]} [UBUNTU] OFFLINE CACHE INSTALLER"
		sudo ./WARES-LIB/OFFLINE-CACHE-CREATOR-OR-INSTALLER/INSTALL_FROM_CACHE_LIB.bash
		echo -e "${COLORS[GREEN]}✔ Done with Choice 16${COLORS[RESET]}"
		;;

	WOL)
		echo -e "${COLORS[YELLOW]}► Running [WOL]:${COLORS[RESET]} Copy Wake On Lan Targets Directory & its contents to /bin"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_WOL
		echo -e "${COLORS[GREEN]}✔ Done with Choice [WOL]${COLORS[RESET]}"
		;;

	17)
		echo -e "${COLORS[YELLOW]}► Running 17:${COLORS[RESET]} [VSCODE] fully install only vscode"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_17
		echo -e "${COLORS[GREEN]}✔ Done with Choice 17${COLORS[RESET]}"
		;;

	POST_INSTALL_WORKFLOW_UBUNTU)
		echo -e "${COLORS[YELLOW]}► Running POST_INSTALL_WORKFLOW_UBUNTU:${COLORS[RESET]} run post install workflow"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_POST_INSTALL_WORKFLOW_UBUNTU

		echo -e "${COLORS[GREEN]}✔ Done with Choice POST_INSTALL_WORKFLOW_UBUNTU${COLORS[RESET]}"
		;;

	*)
		echo -e "${COLORS[RED]}Unknown option: $CHOOSER${COLORS[RESET]}"
		;;
	esac

	# Stop the sudo keep-alive process
	echo "Stopping sudo keep-alive process..."
	kill "$MASTER_SUDO_KEEPALIVE_PID"

done
# !SECTION - MAIN CASE STATEMENT - END OF THE SECTION

# SECTION - FINAL REPORT
# This loop generates the report of selected options for the final summary.
# It iterates through all possible choices (0-17). In each iteration, it uses 'grep'
# to check if the choice number exists in the '$MAIN_CHOICE_SANITIZED' string.
#
# Improved markers: green checkmark if selected, dim cross if not

_MENU_CHOICES_REPORT_ARRAY=(
	0
	1
	2
	3
	4
	UBUNTU_GNOME_VANILLA
	UBUNTU_GNOME_FULL_SEND
	7
	DEBIAN_GNOME
	9
	IMPORT_WIFI
	10
	11
	12
	13
	14
	15
	16
	WOL
	17
	POST_INSTALL_WORKFLOW_UBUNTU
)
for VAL_CHOICE in "${_MENU_CHOICES_REPORT_ARRAY[@]}"; do
	if echo "$MAIN_CHOICE_SANITIZED" | grep -q -w "$VAL_CHOICE"; then
		declare "CHOICE_VAL_REPORT_$VAL_CHOICE=${COLORS[BOLD]}${COLORS[GREEN]}✓${COLORS[RESET]}"
	else
		declare "CHOICE_VAL_REPORT_$VAL_CHOICE=${COLORS[DIM]}✗${COLORS[RESET]}"
	fi
done

FUN_FINAL_INSTALLED_STATUS

# Final beautiful colored report
echo -e "
	

${COLORS[CYAN]}╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
${COLORS[CYAN]}║                                                                                                   ${COLORS[CYAN]}║
${COLORS[CYAN]}║${COLORS[RESET]}${COLORS[BOLD]}                         AUTO-INSTALLS-MASTER! ─ FINAL SELECTION REPORT${COLORS[RESET]}${COLORS[CYAN]}                            ║
${COLORS[CYAN]}╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}

${COLORS[YELLOW]}Legend:${COLORS[RESET]}  ${COLORS[GREEN]}Selected${COLORS[RESET]}     ${COLORS[DIM]}Not selected${COLORS[RESET]}

[${CHOICE_VAL_REPORT_0}]  ${COLORS[BOLD]}0  Copy this software suite to /bin${COLORS[RESET]}
[${CHOICE_VAL_REPORT_1}]  ${COLORS[BOLD]}1  MATE Desktop packages (Parrot/Mint/Ubuntu)${COLORS[RESET]}
[${CHOICE_VAL_REPORT_2}]  ${COLORS[BOLD]}2  MATE FULL SEND → runs 1 + 3 + 4${COLORS[RESET]}
[${CHOICE_VAL_REPORT_3}]  ${COLORS[BOLD]}3  Install manually downloaded .DEB wares only${COLORS[RESET]}
[${CHOICE_VAL_REPORT_4}]  ${COLORS[BOLD]}4  Copy MATE panel & configs to /etc/skel${COLORS[RESET]}
[${CHOICE_VAL_REPORT_UBUNTU_GNOME_VANILLA}]  ${COLORS[BOLD]}UBUNTU_GNOME_VANILLA  Ubuntu Vanilla GNOME specific packages${COLORS[RESET]}
[${CHOICE_VAL_REPORT_UBUNTU_GNOME_FULL_SEND}]  ${COLORS[BOLD]}UBUNTU_GNOME_FULL_SEND → runs UBUNTU_GNOME_VANILLA + 3 + 7 + 13 + 14 + [WOL]${COLORS[RESET]}
[${CHOICE_VAL_REPORT_7}]  ${COLORS[BOLD]}7  Copy GNOME panel & configs to /etc/skel${COLORS[RESET]}
[${CHOICE_VAL_REPORT_DEBIAN_GNOME}]  ${COLORS[BOLD]}DEBIAN_GNOME  Debian GNOME specific packages${COLORS[RESET]}
[${CHOICE_VAL_REPORT_9}]  ${COLORS[BOLD]}9  Install comprehensive font set${COLORS[RESET]}
[${CHOICE_VAL_REPORT_IMPORT_WIFI}]  ${COLORS[BOLD]}   HEADLESS-WIFI-IMPORT → Auto-connect Wi-Fi on first boot (no monitor needed)${COLORS[RESET]}
[${CHOICE_VAL_REPORT_10}] ${COLORS[BOLD]}10 Install ALL gaming console emulators${COLORS[RESET]}
[${CHOICE_VAL_REPORT_11}] ${COLORS[BOLD]}11 Install Intel OpenCL Runtime${COLORS[RESET]}
[${CHOICE_VAL_REPORT_12}] ${COLORS[BOLD]}12 Ubuntu: Install gaming emulators individually${COLORS[RESET]}
[${CHOICE_VAL_REPORT_13}] ${COLORS[BOLD]}13 Reinstall custom scripts to /bin + fix perms${COLORS[RESET]}
[${CHOICE_VAL_REPORT_14}] ${COLORS[BOLD]}14 Reinstall WARES-INCLUDED to \$HOME and /etc/skel${COLORS[RESET]}
[${CHOICE_VAL_REPORT_15}] ${COLORS[BOLD]}15 Create full offline apt cache (clean system only)${COLORS[RESET]}
[${CHOICE_VAL_REPORT_16}] ${COLORS[BOLD]}16 Deploy full system from local cache${COLORS[RESET]}
[${CHOICE_VAL_REPORT_WOL}] ${COLORS[BOLD]}WOL Copy Wake On Lan Targets to /bin${COLORS[RESET]}
[${CHOICE_VAL_REPORT_17}] ${COLORS[BOLD]}17 Install only Visual Studio Code${COLORS[RESET]}
[${CHOICE_VAL_REPORT_POST_INSTALL_WORKFLOW_UBUNTU}] ${COLORS[BOLD]}POST_INSTALL_WORKFLOW_UBUNTU run post install workflow${COLORS[RESET]}

${COLORS[CYAN]}╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
${COLORS[CYAN]}║${COLORS[RESET]}  ${COLORS[BOLD]}${COLORS[GREEN]}ALL DONE! Your system is now customized exactly how you wanted it!  ${COLORS[RESET]}
${COLORS[CYAN]}║${COLORS[RESET]} [◉_◉] 🔥🐧🔥 ⊂(◉‿◉)つ ⮞☆*: .｡. o(≧▽≦)o .｡.:*☆ ✨  ϞϞ(๑⚈ ․̫ ⚈๑)∩  🐧💻  ⟆⟆⟆  💫 
${COLORS[CYAN]}║${COLORS[RESET]} ${COLORS[BOLD]}${COLORS[GREEN]}Enjoy your customized system! 🐧💻🔥					  
${COLORS[CYAN]}║${COLORS[RESET]} ●─────────────────────────────────────●  ●─────────────────────────────────────●  
${COLORS[CYAN]}╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝${COLORS[RESET]}
"
# !SECTION - FINAL REPORT - END OF THE SECTION
