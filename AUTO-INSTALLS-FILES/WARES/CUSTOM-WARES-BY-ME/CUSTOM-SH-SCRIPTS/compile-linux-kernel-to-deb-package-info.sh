##### For compiling linux kernels
##### cd into the decompressed linux kernel dir

# this file is for documentation/instructions

# dependencies

sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison devscripts libncurses5 linux-source bc kmod cpio dwarves -y
sudo apt install libncurses5‐dev -y
sudo apt install build‐dep -y



#copy current system's  configuration 
cp -v /boot/config-$(uname -r) .config

# the ncruses menu ...or another option '''caution''' make oldconfig
make menuconfig


####### If you do this, ensure that you modify the configuration to set:
####### CONFIG_SYSTEM_TRUSTED_KEYS = ""
#######  otherwise the build may fail: 


#now compile the kernel

make -j$(nproc) deb-pkg



## still testing ''''
