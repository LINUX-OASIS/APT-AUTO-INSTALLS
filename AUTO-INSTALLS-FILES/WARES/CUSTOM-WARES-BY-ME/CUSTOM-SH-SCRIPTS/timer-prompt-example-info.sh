#!/bin/bash

read -t 10 -p "Please Input Your Choice  [1..3]" CHOICE

CHOICE=(${CHOICE^^})
if [ -z $CHOICE_CAP ]
	then
	echo "[ EMPTY ! ]    Exiting"
	exit
	elif [ $CHOICE_CAP != "Y" ]
	then
	echo "Not a valid Choice !! exiting !!"
	exit
	elif [ $CHOICE_CAP = "Y" ]
	then
	echo "Yout chose Y continuing !!"
	fi
