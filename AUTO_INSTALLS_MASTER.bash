#!/bin/bash

### Do not run this script as `sudo`. Run it as a normal user; it will prompt for the sudo password when required.
### Always execute this script by its absolute path to avoid unexpected behavior.
### For consistency, try to be in the script's directory when running it.

# Get the absolute directory path of this script and change to that directory.
# Exits the script if the directory change fails.
CD_DIRNAME=$(dirname "$(realpath $0)")
cd "$CD_DIRNAME" || exit

# Function: Display a verbose installation message and update packages.
FUN_VERBOSE_INSTALLING() {
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
FUN_VERBOSE_INSTALLING_NO_APT_UPDATE() {
    echo ""
    tput setab 7
    tput setaf 18
    echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
    tput sgr0
}

# Function: Display a block-style indicator for the current choice.
FUN_CHOICE_BLOCK_INDICATOR() {
    echo ""
    tput setab 112
    tput setaf 234
    tput bold
    echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."

    echo -e "\n-_-_-_-_-_-_-_-_-_-_-_ Installing $CHOICE_BLOCK_INDICATOR _-_-_-_-_-_-_-_-_-_-_- \n"

    echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."
    tput sgr0
}

# Function: Check the installation status of packages and store the results in arrays.
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER() {
    _ARRAY_ALL_PACKAGES[$_array_counter]+="$PKG_NAME"
    _array_counter=$((_array_counter + 1))
}

# Function: Display the final installation status (successful and failed packages).
FUN_FINAL_INSTALLED_STATUS() {
    _array_counter=0
    for LOOP_PKG in "${_ARRAY_ALL_PACKAGES[@]}"; do
        if apt list --installed "$LOOP_PKG" 2>&1 | grep -o -w -q "$LOOP_PKG"; then
            _ARRAY_SUCESS[$_array_counter]+="$LOOP_PKG"
            _array_counter=$((_array_counter + 1))
        else
            _ARRAY_FAIL[$_array_counter]+="$LOOP_PKG"
            _array_counter=$((_array_counter + 1))
        fi
    done

    tput setab 7
    tput setaf 18
    echo "-_-_-_-_-_-_-_-_-_-_-_ :-D FINALIZED :-D _-_-_-_-_-_-_-_-_-_-_-"
    tput sgr0

    echo -e ":: SUCCESSFULLY INSTALLED PACKAGES ::\n"
    echo -e '\033[0;32m' "${_ARRAY_SUCESS[@]}" '\033[0m' | sort -u | paste - - - -

    echo -e ":: ERRONEOUSLY INSTALLED PACKAGES ::\n"
    echo -e '\033[0;31m' "${_ARRAY_FAIL[@]}" '\033[0m' | sort -u | paste - - - -
}

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

# Menu: Present the user with options via a checklist.
MAIN_CHOICE=$(whiptail --title "AUTO-INSTALLS-MASTER!" \
    --backtitle "RUN SCRIPT BY ITS ABSOLUTE PATH!" \
    --checklist "Choice" 0 0 14 \
    0 "COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]" off \
    1 "MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU] (Wares for all [MATE DE] Desktops" off \
    2 "[MATE Desktops ! FULL SEND] Executes options 1, 3, 4" off \
    3 "Manually installed Wares Only [.DEB Files]" off \
    4 "[MATE Desktops] COPY MATE PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
    5 "[UBUNTU SPECIFIC] Wares for Ubuntu Vanilla [GNOME DE]" off \
    6 "[UBUNTU SPECIFIC !!! Full Send !!!] Executes options 5, 3, 7" off \
    7 "[UBUNTU SPECIFIC] COPY GNOME PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
    8 "[DEBIAN] Wares for Debian [GNOME DE]" off \
    9 "INSTALL ALL GAMING CONSOLES ONLY" off \
    10 "INSTALL [INTEL OPENCL runtime]" off \
    11 "[UBUNTU SPECIFIC] COPY APT SOURCES ONLY" off \
    12 "[UBUNTU SPECIFIC] INSTALL GAMING CONSOLES INDIVIDUALLY" off \
    13 "Reinstall custom shell scripts to /bin and add user permissions" off \
    3>&1 1>&2 2>&3)

echo "Chosen options: $MAIN_CHOICE"

# Process the chosen options from the checklist.
MAIN_CHOICE_SANITIZED=$(echo "$MAIN_CHOICE" | sed 's/"//g')

for CHOOSER in $MAIN_CHOICE_SANITIZED; do
    case $CHOOSER in
    0)
        echo "0. COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_0
        echo "All DONE with Choice 0 :-)"
        ;;
    1)
        echo "1. MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU]"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_1
        echo "	All DONE  with Choice 1 :-)"
        ;;
    2)
        echo "2. [MATE Desktops ! FULL SEND] Executes options 1 3 4"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_2
        echo "	All DONE  with Choice  2	:D  :-)"
        ;;
    3)
        echo " 3.  Manually installed Wares Only  [.DEB Files Only] "
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_3
        echo "	All DONE  with Choice  3	:D  :-)"
        ;;
    4)
        #NOTE: this is done using dconf [if you want it done via terminal] (but only works if access to GUI)...[cubic doesn't have gui] in cubic we copy the ~/.config/dconf/User file
        echo "4. [MATE Desktops] COPY MATE PANEL SETTING & APP CONFIGS TO /ETC/SKEL {Depending On Chosen MATE DE Distro}"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_4
        echo "All DONE  with Choice  4	:D  :-)"
        ;;
    5)
        echo "5. [UBUNTU'S SPECIFIC] (Wares for Ubuntu Vanilla [GNOME DE]) "
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_5
        echo "	All DONE  with Choice  5	:D  :-)"
        ;;
    6)
        echo "6. [UBUNTU'S SPECIFIC !!! Full  Send !!!] Executes options 5, 3, 7"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_6
        echo "	All DONE  with Choice  6	:D  :-)"
        ;;
    7)
        echo "7. [UBUNTU'S SPECIFIC] COPY GNOME PANEL SETTING & APP CONFIGS TO /ETC/SKEL"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_7
        echo "	All DONE  with Choice  7	:D  :-)"
        ;;
    8)
        echo "8. [ DEBIAN ] (Wares for DEBIAN [GNOME DE])"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_8
        echo "	All DONE  with Choice  8	:D  :-)"
        ;;
    9)
        echo "9. INSTALL ALL GAMING CONSOLES ONLY"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_9
        echo "	All DONE  with Choice  9	:D  :-)"
        ;;
    10)
        echo "10 INSTALL [INTEL OPENCL runtime]"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_10
        echo "    All DONE  with Choice 10    :D  :-)"
        ;;
    11)
        echo "11. [UBUNTU'S SPECIFIC]_COPY_APT_SOURCES ONLY"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_11
        echo "    All DONE  with Choice 11    :D  :-)"
        ;;
    12)
        echo "12. [UBUNTU'S SPECIFIC] INSTALL GAMING CONSOLES INDIVIDUALLY"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_12
        echo "    All DONE  with Choice 12    :D  :-)"
        ;;
    13)
        echo "(RE)Install CUSTOM-SH-SCRIPTS to /bin/CUSTOM-SH-SCRIPTS & /bin And add user permissions to Them [chmod 777]"
        source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
        FUN_MAIN_CHOICE_13
        echo "    All DONE  with Choice 13    :D  :-)"
        ;;
    *)
        echo "Unknown"
        ;;
    esac
done

#for loop iterates over whiptails menu tags and check which were selected...to assign checkmark to final report to which options were selected
for VAL_CHOICE in {0..13}; do

    if echo "$MAIN_CHOICE_SANITIZED" | sed 's/"//g' | grep -o -w $VAL_CHOICE >/dev/null; then
        declare "CHOICE_VAL_REPORT_$VAL_CHOICE=*"
    else
        declare "CHOICE_VAL_REPORT_$VAL_CHOICE= "

    fi

done

#prints final installed status of packages
echo "_______________________________________________________________________________________________________"
echo "|                                                                                                      |"
FUN_FINAL_INSTALLED_STATUS

###^^^^^^^^^^^^^selected AUTO-INSTALLS-MASTER OPTIONS REPORTING ***** START
cat <<EOF

_______________________________________________________________________________________________________
|                                                                                                      |
|                    AUTO-INSTALLS-MASTER! FINAL RESULTS                                               |
|______________________________________________________________________________________________________|
                                                                                                    
[$CHOICE_VAL_REPORT_0] 0 COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]
[$CHOICE_VAL_REPORT_1] 1 MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU] (Wares for all [MATE DE] Desktops
[$CHOICE_VAL_REPORT_2] 2 [MATE Desktops ! FULL SEND] Executes options 1 3 4
[$CHOICE_VAL_REPORT_3] 3 Manually installed Wares Only [.DEB Files]
[$CHOICE_VAL_REPORT_4] 4 [MATE Desktops] COPY MATE PANEL SETTING & APP CONFIGS TO /ETC/SKEL {Depending On Chosen MATE DE Distro}
[$CHOICE_VAL_REPORT_5] 5 [UBUNTU'S SPECIFIC] (Wares for Ubuntu Vanilla [GNOME DE])
[$CHOICE_VAL_REPORT_6] 6 [UBUNTU'S SPECIFIC !!! Full  Send !!!] Executes options 5, 3, 7
[$CHOICE_VAL_REPORT_7] 7 [UBUNTU'S SPECIFIC] COPY GNOME PANEL SETTING & APP CONFIGS TO /ETC/SKEL
[$CHOICE_VAL_REPORT_8] 8[ DEBIAN ] (Wares for DEBIAN [GNOME DE]
[$CHOICE_VAL_REPORT_9] 9 INSTALL ALL GAMING CONSOLES ONLY
[$CHOICE_VAL_REPORT_10] 10 INSTALL [INTEL OPENCL runtime]
[$CHOICE_VAL_REPORT_11] 11 [UBUNTU'S SPECIFIC]_COPY_APT_SOURCES ONLY
[$CHOICE_VAL_REPORT_12] 12 [UBUNTU'S SPECIFIC] INSTALL GAMING CONSOLES INDIVIDUALLY
[$CHOICE_VAL_REPORT_13] 13 (RE)Install CUSTOM-SH-SCRIPTS to /bin/CUSTOM-SH-SCRIPTS & /bin And add user permissions to Them [chmod 777]
__________________________________________________________________________________________________________
                                    ALL  DONE   ;-)   (｡◕‿‿◕｡)  (▼・ᴥ・▼)  ALL DONE
                                    ALL  DONE   ;-)   ฅ^•ﻌ•^ฅ    (▰˘◡˘▰)   ALL DONE


EOF
