#!/bin/bash

##EXAMPLE CHECK FOR DEPENDENCIES

# Checks if a single package/dependeny is not already installed
# A better way to automate checking for dependencies and install them if not already
if ! apt list --installed virtualbox 2>/dev/null | grep -w virtualbox >/dev/null; then # the precursor condition to begin checking and installing dependencies .for a single package/dependeny
	for PACKAGE in virtualbox virtualbox-dkms debconf-utils virtualbox-ext-pack virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-additions-iso virtualbox-guest-dkms; do
		if ! apt list --installed $PACKAGE 2>/dev/null | grep -w $PACKAGE >/dev/null; then
			echo "dependency $PACKAGE is NOT installed .. installing"
			sudo apt update
			sudo apt install -y $PACKAGE
		fi
		if ! apt list --installed $PACKAGE 2>/dev/null | grep -w $PACKAGE >/dev/null; then
			echo "Posibly didn't install dependency $PACKAGE .. exiting"
			exit
		fi
		if [[ $PACKAGE == "virtualbox-ext-pack" ]]; then
			echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
			sudo apt install -y virtualbox-ext-pack
		fi
	done
	sudo usermod -aG vboxusers $USER
	# enable VIRTUALBOX raw disk access without root
	sudo usermod -aG disk $USER
fi
# you can go on with your day automating the heck out of things :-) :-]

#
#
#
#
#
#
#
#
#

# Checks for multiple package/dependencies installed status ;;;another example
for PACKAGE in samba qrencode fim zbar-tools; do
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

#example of break ..... use break to break out of loops....or use continue to contine execution
while true; do
	echo caca

	break
done
