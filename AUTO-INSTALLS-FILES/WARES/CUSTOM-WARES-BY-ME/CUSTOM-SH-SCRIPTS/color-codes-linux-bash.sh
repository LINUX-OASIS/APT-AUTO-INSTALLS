#!/bin/bash

# To use colors in Bash, you can utilize escape sequences with the syntax,
# echo -e "\e[{colorCode}mSample Text\e[0m".
# The -e enables backslash escapes interpretation,
# the \e (or sometimes \033) denotes the start of color modifications,
# {colorCode}m is where you will place the desired color code,
# and \e[0m marks the end of color modifications. These sequences allow you to change the color of your text output in the terminal.

#NOTE: in some cases (in many cases actually) If you have a custom .bashrc/ bash .profile ,,, you may want to set the color codes as a variable first before using
# or else you can get weird output/ extra text.... things like that

# https://www.shellhacks.com/bash-colors/

# Color codes, "f" means "font"
declare -r fLightRed="\e[91m"
declare -r fLightGreen="\e[92m"
declare -r fLightYellow="\e[93m"
declare -r fLightBlue="\e[94m"
declare -r fLightMagenta="\e[95m"
declare -r fLightCyan="\e[96m"
declare -r fRed="\e[31m"
declare -r fGreen="\e[32m"
declare -r fYellow="\e[33m"
declare -r fBlue="\e[34m"
declare -r fMagenta="\e[35m"
declare -r fCyan="\e[36m"
declare -r fOrange="\e[38;5;214m"

# Style codes
declare -r fB="\e[1m" # bold
declare -r fI="\e[3m" # italic

# ENDING: Reset all attributes
declare -r fEND="\e[0m"

### !!!!  THE WAY THE COLOR CODES ARE ACTUALLY USED!! ::: append the color code to the end of the line you wish to change color to :

echo -e "${fLightRed}This is a light red text${fEND}"
echo -e "${fLightGreen}This is a light green text${fEND}"
echo -e "${fLightYellow}This is a light yellow text${fEND}"

### MANUALLY ::::

echo -e "\e[35m; Some colored text \e[0m"
####################################################
####################################################
for var in {1..254}; do

    echo -e "\e[38;5;${var}m  this is text [[ COLOR:: \\\e[38;5;${var}m ]] \e[0m"

done
################################################
################################################
for var in {1..254}; do

    echo -e "\e[0;${var}m  this is text [[ COLOR:: \\\e[0;${var}m ]] \e[0m"

done

######################################################
#for styles in color escape sequences 0-4
for var0styles in {0..4}; do

    for var1 in {0..254}; do

        echo -e "\e[${var0styles};${var1}m  this is text [[ COLOR:: \\\e[${var0styles};${var1}m ]] \e[0m"

    done
done
######################################################

# A list of color codes
# Color	Code
# Black	0;30
# Blue	0;34
# Green	0;32
# Cyan	0;36
# Red	0;31
# Purple	0;35
# Brown	0;33
# Blue	0;34
# Green	0;32
# Cyan	0;36
# Red	0;31
# Purple	0;35
# Brown	0;33

#####################################################################################
#####################################################################################

# Color	Foreground Code	Background Code
# Black	        30	40
# Red	        31	41
# Green	        32	42
# Yellow	    33	43
# Blue	        34	44
# Magenta	    35	45
# Cyan	        36	46
# Light Gray	37	47
# Gray	        90	100
# Light Red	    91	101
# Light Green	92	102
# Light Yellow	93	103
# Light Blue	94	104
# Light Magenta	95	105
# Light Cyan	96	106
# White	        97	107

# To change the color of the text, what we want is the foreground code. There are also a few other non-color special codes that are relevant to us:

# Code	Description
# 0	Reset/Normal
# 1	Bold text
# 2	Faint text
# 3	Italics
# 4	Underlined text
