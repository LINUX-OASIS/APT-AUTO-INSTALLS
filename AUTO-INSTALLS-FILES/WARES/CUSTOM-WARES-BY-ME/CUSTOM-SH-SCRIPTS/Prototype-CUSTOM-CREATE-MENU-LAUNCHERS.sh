#!/bin/bash

# depends on breeze icon theme: breeze-icon-theme / breeze
# Checks for package/dependencies installed status and installs them if not already installed
for PACKAGE in "breeze-icon-theme"; do                                                 # the dependencies needed
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

# Function to create a desktop launcher
FUN_CREATE_LAUNCHER() {
    local LAUNCHER_FILE="${_DESKTOP_PATH}/${_LAUNCHER_NAME}.desktop"

    # Check if script exists
    if [[ ! -f "$_SCRIPT_PATH" ]]; then
        echo "Error: Script not found at $_SCRIPT_PATH"
        exit 1
    fi

    # icon path DIR is : /usr/share/icons/breeze/apps/48
    # Check if icon exists
    if [[ ! -f "$_ICON_PATH" ]]; then
        echo "Error: Icon not found at $_ICON_PATH"
        exit 1
    fi

    # Create the launcher file
    cat <<EOF >"$LAUNCHER_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=$_LAUNCHER_NAME
Exec=bash -c '$_SCRIPT_PATH'
Icon=$_ICON_PATH
Terminal=true
Categories=Utility;
EOF

    # Make the launcher executable
    sudo chmod +x "$LAUNCHER_FILE"

    echo "Launcher created: $LAUNCHER_FILE"
}

while true; do

    # Main script
    echo "Welcome to the Launcher Creator!"

    # Prompt for script path
    if whiptail --fullbuttons --backtitle "DESKTOP [LAUNCHER] CREATOR" --yesno "Do you want to create a launcher for a script?" 0 0; then
        echo "You chose Yes. Let's create a launcher!"

        read -p "Enter the full path to the script you want to launch:" _SCRIPT_PATH

        # Prompt for launcher name
        read -p "Enter the name of the launcher: " _LAUNCHER_NAME

        # Prompt for icon path
        read -p "Enter the full path to the icon (e.g., PNG or SVG): " _ICON_PATH

        # Set desktop path
        _DESKTOP_PATH=~/Desktop

        # Call the function to create the launcher
        FUN_CREATE_LAUNCHER

        read -p "Done with MENU Launcher creator :: PRESS ENTER TO CONTINUE"

    else
        echo "You chose No. Exiting..."
        exit
    fi

done
