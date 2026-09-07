#!/usr/bin/env bash
#
# setup-headless-service.sh
# A non-interactive script to install the one-shot WiFi import systemd service.
#
# DESCRIPTION:
# This script is designed for use in automated setups. It creates and enables a
# systemd service that runs on each boot. The service waits for a WiFi adapter
# to become available, imports all network profiles from a specified file,
# and then disables itself to ensure it only runs once successfully.
# HEADLESS WIFI NETWORK IMPORTING
# USAGE:
# The script must be run with root privileges and requires one argument:
# sudo ./setup-headless-service.sh (or the function name if made into a function) /path/to/your/wifi_networks.txt
#

# Stop script execution immediately if any command fails.
set -e

# --- Section 1: Pre-flight Checks ---
# Verifies that the script is being run in a valid environment.

# 1. Check for root privileges.
# The script needs to write to /usr/local/bin and /etc/systemd/system,
# and needs to run systemctl commands, all of which require root.
if [[ $EUID -ne 0 ]]; then
	echo "Error: This script must be run as root. Please use sudo." >&2
	exit 1
fi

# 2. Check for the command-line argument.
# The first argument ($1) must be the path to the import file.
if [[ -z "$1" ]]; then
	echo "Usage: sudo $0 /path/to/your/wifi_networks.txt" >&2
	exit 1
fi

# --- Section 2: Variable Declarations ---
# Defines the key variables used throughout the script.

# The path to the file containing WiFi profiles, provided as a command-line argument.
IMPORT_FILE_PATH="$1"
# The official name of the systemd service.
SERVICE_NAME="wifi-import-once.service"
# The full path where the generated helper executable will be stored.
SCRIPT_PATH="/usr/local/bin/wifi-import-once.sh"
# The full path where the systemd service unit file will be stored.
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

echo "--- WiFi Headless Import Service Setup ---"
echo "Import file specified: $IMPORT_FILE_PATH"

# --- Section 3: Configuration Validation ---
# Ensures the provided import file path is valid before proceeding.

echo "Validating configuration..."
# The file path must be absolute, as systemd services do not run from a user's
# working directory and need explicit paths to locate files.
if [[ "$IMPORT_FILE_PATH" != /* ]]; then
	echo "Error: The import file path must be absolute (start with '/')." >&2
	exit 1
fi
# The file must exist and contain data.
if [[ ! -f "$IMPORT_FILE_PATH" ]] || [[ ! -s "$IMPORT_FILE_PATH" ]]; then
	echo "Error: The specified import file does not exist or is empty: $IMPORT_FILE_PATH" >&2
	exit 1
fi
echo "Configuration validated successfully."

# --- Section 4: Content Generation for Service Files ---

# 4a. Define Helper Script Content using a HEREDOC.
# The 'EOF' is quoted ('cat <<'EOF'') to prevent the shell from expanding
# variables like $SSID within this block. Instead, placeholders like __IMPORT_FILE__
# are used and safely replaced later.
HELPER_SCRIPT_CONTENT=$(
	cat <<'EOF'
#!/bin/bash
# Corrected version of the wifi-import-once.sh script.
# This script will run on boot, import networks, and disable itself.

# NOTE: 'set -e' is intentionally left out to ensure the script attempts
# to import all networks, even if one fails.

IMPORT_FILE="__IMPORT_FILE__"
SERVICE_NAME="__SERVICE_NAME__"

logger "$SERVICE_NAME: Starting corrected one-time WiFi import."

logger "$SERVICE_NAME: Checking for available WiFi interfaces..."
INTERFACE_TO_USE=$(nmcli -t -f DEVICE,TYPE dev | grep ':wifi$' | cut -d: -f1 | head -n1)

if [[ -z "$INTERFACE_TO_USE" ]]; then
    logger "$SERVICE_NAME: No WiFi interface found. Will check again on next boot."
    exit 0
fi

logger "$SERVICE_NAME: Found WiFi interface '$INTERFACE_TO_USE'. Proceeding with import."

if [[ ! -f "$IMPORT_FILE" ]]; then
    logger "$SERVICE_NAME: FATAL ERROR - Import file '$IMPORT_FILE' not found! Disabling service."
    systemctl disable "$SERVICE_NAME"
    exit 1
fi

import_count=0
error_count=0

# Use a temporary file to sanitize the input file, removing any '\r' characters.
TEMP_INPUT_FILE=$(mktemp)
tr -d '\r' < "$IMPORT_FILE" > "$TEMP_INPUT_FILE"


while IFS='|' read -r -a F; do
    # Skip empty or malformed lines
    [[ ${#F[@]} -lt 2 ]] && continue

    SSID="${F[0]}"
    PASSWORD="${F[1]}"
    # Set defaults
    SECURITY="WPA"
    BSSID=""
    HIDDEN="no"
    PRIORITY="0"

    # Override defaults based on the number of fields
    case ${#F[@]} in
        5) SECURITY="${F[2]}"; BSSID="${F[3]}";;
        6) SECURITY="${F[2]}"; BSSID="${F[3]}"; HIDDEN="${F[5]}";;
        7) SECURITY="${F[2]}"; BSSID="${F[3]}"; HIDDEN="${F[5]}"; PRIORITY="${F[6]}";;
    esac

    # --- Sanity Checks ---
    if [[ -z "$SSID" ]]; then
        logger "$SERVICE_NAME: Skipping line with empty SSID."
        ((error_count++))
        continue
    fi

    if [[ "$SECURITY" != "OPEN" && -z "$PASSWORD" ]]; then
        logger "$SERVICE_NAME: Skipping '$SSID' due to missing password for a secured network."
        ((error_count++))
        continue
    fi

    logger "$SERVICE_NAME: Processing network: '$SSID'..."

    # Check if a connection with the same name already exists and delete it.
    if nmcli -t -f NAME connection show | grep -q "^${SSID}$"; then
        logger "$SERVICE_NAME: Deleting existing connection for '$SSID' to ensure a clean import."
        nmcli connection delete "$SSID" >/dev/null 2>&1 || true
    fi

    # Build nmcli command in a safe array to handle special characters.
    cmd_array=(nmcli connection add type wifi con-name "$SSID" ifname "$INTERFACE_TO_USE" ssid "$SSID")

    case "$SECURITY" in
        WPA)  cmd_array+=("wifi-sec.key-mgmt" "wpa-psk" "wifi-sec.psk" "$PASSWORD");;
        WEP)  cmd_array+=("wifi-sec.key-mgmt" "wep" "wifi-sec.wep-key-type" "passphrase" "wifi-sec.wep-key0" "$PASSWORD");;
        OPEN) cmd_array+=("wifi-sec.key-mgmt" "none");;
        *)    cmd_array+=("wifi-sec.key-mgmt" "wpa-psk" "wifi-sec.psk" "$PASSWORD");;
    esac

    if [[ "$HIDDEN" == "yes" ]]; then
        cmd_array+=("802-11-wireless.hidden" "yes")
    fi

    # Execute the 'add' command and check its exit status
    if "${cmd_array[@]}"; then
        logger "$SERVICE_NAME: Successfully added connection '$SSID'."
        
        # On success, apply optional modifications
        if [[ -n "$BSSID" ]]; then
            nmcli connection modify "$SSID" 802-11-wireless.bssid "$BSSID" || logger "$SERVICE_NAME: Warning - Failed to set BSSID for '$SSID'."
        fi
        if [[ -n "$PRIORITY" && "$PRIORITY" != "0" ]]; then
            nmcli connection modify "$SSID" connection.autoconnect-priority "$PRIORITY" || logger "$SERVICE_NAME: Warning - Failed to set priority for '$SSID'."
        fi
        ((import_count++))
    else
        logger "$SERVICE_NAME: ERROR - Failed to import '$SSID'."
        ((error_count++))
        continue
    fi
done < "$TEMP_INPUT_FILE"

rm "$TEMP_INPUT_FILE"

logger "$SERVICE_NAME: Import task finished. Success: $import_count, Failed: $error_count."

# Only disable the service if it actually processed something.
if [[ $import_count -gt 0 || $error_count -gt 0 ]]; then
    logger "$SERVICE_NAME: Disabling service after execution."
    systemctl disable "$SERVICE_NAME"
fi

exit 0
EOF
)

# 4b. Safely inject dynamic values into the script content by replacing placeholders.
# This uses shell parameter expansion to find and replace all occurrences of the placeholder.
HELPER_SCRIPT_CONTENT=${HELPER_SCRIPT_CONTENT//__IMPORT_FILE__/$IMPORT_FILE_PATH}
HELPER_SCRIPT_CONTENT=${HELPER_SCRIPT_CONTENT//__SERVICE_NAME__/$SERVICE_NAME}

# 4c. Define Service Unit Content.
# The double quotes around the main string allow for shell expansion of $SCRIPT_PATH.
SERVICE_UNIT_CONTENT=$(
	printf '%s' \
		"[Unit]
# A human-readable description of the service.
Description=One-shot WiFi Network Importer for Headless Setup
# Specifies that this service should only start after the network stack is ready.
After=network.target network-online.target
Wants=network-online.target

[Service]
# 'oneshot' means the service starts, runs a single task, and then terminates.
Type=oneshot
# The full path to the command that will be executed.
ExecStart=$SCRIPT_PATH
# Ensures that systemd considers the service active even after the script exits.
RemainAfterExit=true

[Install]
# Tells systemd to hook this service into the multi-user boot target.
WantedBy=multi-user.target
"
)

# --- Section 5: Installation Process ---

# 5a. Clean up any existing version of the service.
# This makes the script idempotent (re-runnable).
if [[ -f "$SERVICE_PATH" ]]; then
	echo "Existing service found. Stopping and removing it before re-installation..."
	# Stop the service if it's currently running.
	systemctl stop "$SERVICE_NAME" >/dev/null 2>&1 || true
	# Disable the service from starting automatically on boot.
	systemctl disable "$SERVICE_NAME" >/dev/null 2>&1 || true
	# Delete the old script and service files.
	rm -f "$SERVICE_PATH" "$SCRIPT_PATH"
	echo "Old service removed."
fi

# 5b. Write the new helper script and service files.
echo "Writing helper script to $SCRIPT_PATH..."
echo "$HELPER_SCRIPT_CONTENT" >"$SCRIPT_PATH"

echo "Writing systemd service to $SERVICE_PATH..."
echo "$SERVICE_UNIT_CONTENT" >"$SERVICE_PATH"

# 5c. Set permissions and enable the new service.
echo "Setting script permissions..."
# The helper script must be marked as executable to run.
chmod +x "$SCRIPT_PATH"

echo "Reloading systemd daemon and enabling service..."
# Tell systemd to re-read its configuration files from disk.
systemctl daemon-reload
# Enable the service to start automatically on the next boot.
systemctl enable "$SERVICE_NAME"

echo "---"
echo "Installation Complete!"
echo "Service '$SERVICE_NAME' has been installed and enabled."
echo "It will run on the next boot to import networks from '$IMPORT_FILE_PATH'."
echo "---"

exit 0
