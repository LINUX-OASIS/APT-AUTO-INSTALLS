# # #!/bin/bash

###DONT RUN AS SUDO; RUN AS NORMAL USER AND IT WILL PROMPT YOU FOR SUDO PASSWORD
CD_DIRNAME=$(dirname $0)
cd $CD_DIRNAME


FUN_VERBOSE_INSTALLING () {
	echo "";
	tput setab 7;tput setaf 18;
	echo "-_-_-_-_-_-_-_-_-_-_-_installing  $PKG_NAME _-_-_-_-_-_-_-_-_-_-_";tput sgr0;
	sudo apt update;sleep 1
	sudo apt --fix-broken install -y
}


FUN_VERBOSE_INSTALLING_NO_APT_UPDATE () {
	echo "";
	tput setab 7;tput setaf 18;
	echo "-_-_-_-_-_-_-_-_-_-_-_installing  $PKG_NAME _-_-_-_-_-_-_-_-_-_-_";tput sgr0;
}



function FUN_WARES_FOR_ALL {


	
	PKG_NAME="wavemon"
	FUN_VERBOSE_INSTALLING
	sudo apt install wavemon -y

	PKG_NAME="gimp"
	FUN_VERBOSE_INSTALLING
	sudo apt install gimp -y
	
	PKG_NAME="mat2 metadate anonimyzer"
	FUN_VERBOSE_INSTALLING
	sudo apt install mat2 -y

	PKG_NAME="trash-cli  :: to use trash-empty command"
	FUN_VERBOSE_INSTALLING
	sudo apt install trash-cli -y
	
	PKG_NAME="nmap"
	FUN_VERBOSE_INSTALLING
	sudo apt install nmap -y
	
	PKG_NAME="gparted"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y gparted
	
	PKG_NAME="neofetch"
	FUN_VERBOSE_INSTALLING
	sudo apt install neofetch -y
	
	PKG_NAME="screenfetch"
	FUN_VERBOSE_INSTALLING
	sudo apt install screenfetch -y
	
	PKG_NAME="bulky"
	FUN_VERBOSE_INSTALLING
	sudo apt install bulky -y
	
	PKG_NAME="qbittorrent"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y qbittorrent
	
	PKG_NAME=" tree "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y tree
	
	PKG_NAME="  g++  "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y g++
	
	PKG_NAME=" crunch  "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y crunch
	
	PKG_NAME=" htop "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y htop
	
	PKG_NAME=" git "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y git
	
	#PKG_NAME="grub-efi-amd64"
	#FUN_VERBOSE_INSTALLING
	#sudo apt install grub-efi-amd64 -y
	
	PKG_NAME="isomaster"
	FUN_VERBOSE_INSTALLING
	sudo apt install isomaster -y
	
	PKG_NAME="barrier"
	FUN_VERBOSE_INSTALLING
	sudo apt install barrier -y
	
	PKG_NAME="kwrite"
	FUN_VERBOSE_INSTALLING
	sudo apt install kwrite -y
	
	PKG_NAME="kate"
	FUN_VERBOSE_INSTALLING
	sudo apt install kate -y

	PKG_NAME="ktouch"
	FUN_VERBOSE_INSTALLING
	sudo apt install ktouch -y
	
	PKG_NAME="kdialog"
	FUN_VERBOSE_INSTALLING
	sudo apt install kdialog -y
	
	PKG_NAME="gnome-disk-utility"
	FUN_VERBOSE_INSTALLING
	sudo apt install gnome-disk-utility -y
	
	
	PKG_NAME="breeze"
	FUN_VERBOSE_INSTALLING
	sudo apt install breeze -y
	
	PKG_NAME="kdenlive"
	FUN_VERBOSE_INSTALLING
	sudo apt install kdenlive -y
	
	
	PKG_NAME="audacity"
	FUN_VERBOSE_INSTALLING
	sudo apt install audacity -y
	
	
	PKG_NAME="ardour"
	FUN_VERBOSE_INSTALLING
	sudo apt install ardour -y
	
	
	PKG_NAME="handbrake"
	FUN_VERBOSE_INSTALLING
	sudo apt install handbrake -y
	
	
	PKG_NAME="unrar"
	FUN_VERBOSE_INSTALLING
	sudo apt install unrar -y
	
	
	PKG_NAME="winff"
	FUN_VERBOSE_INSTALLING
	sudo apt install winff -y
	
	
	PKG_NAME="caja-admin"
	FUN_VERBOSE_INSTALLING
	sudo apt install caja-admin -y
	
	
	PKG_NAME="timeshift"
	FUN_VERBOSE_INSTALLING
	sudo apt install timeshift -y
	
	
	PKG_NAME="diodon"
	FUN_VERBOSE_INSTALLING
	sudo apt install diodon -y
	
	
	PKG_NAME="compton"
	FUN_VERBOSE_INSTALLING
	sudo apt install compton -y
	
	
	PKG_NAME="picom"
	FUN_VERBOSE_INSTALLING
	sudo apt install picom -y
	
	
	PKG_NAME="v4l2loopback-dkms"
	FUN_VERBOSE_INSTALLING
	sudo apt install v4l2loopback-dkms -y
	
	
	PKG_NAME="obs-studio"
	FUN_VERBOSE_INSTALLING
	sudo apt install obs-studio -y
	
	
	PKG_NAME="vokoscreen-ng"
	FUN_VERBOSE_INSTALLING
	sudo apt install vokoscreen-ng -y
	
	
	PKG_NAME="lolcat"
	FUN_VERBOSE_INSTALLING
	sudo apt install lolcat -y
	
	
	PKG_NAME="gnome-clocks"
	FUN_VERBOSE_INSTALLING
	sudo apt install gnome-clocks -y
	
	
	PKG_NAME="snapd"
	FUN_VERBOSE_INSTALLING
	sudo apt install snapd -y
	
	
	PKG_NAME="zstd"
	FUN_VERBOSE_INSTALLING
	sudo apt install zstd -y
	
	
	PKG_NAME="secure-delete"
	FUN_VERBOSE_INSTALLING
	sudo apt install secure-delete -y
	
	
	PKG_NAME="cool-retro-term"
	FUN_VERBOSE_INSTALLING
	sudo apt install cool-retro-term -y
	
	
	
	PKG_NAME="intel-gpu-tools"
	FUN_VERBOSE_INSTALLING
	sudo apt install intel-gpu-tools -y
	
	
	PKG_NAME=" linux-cpupower "
	FUN_VERBOSE_INSTALLING
	sudo apt install linux-cpupower -y
	
	
	PKG_NAME="wine64"
	FUN_VERBOSE_INSTALLING
	sudo apt install wine64 -y
	
	
	PKG_NAME="q4wine"
	FUN_VERBOSE_INSTALLING
	sudo apt install q4wine -y
	
	
	PKG_NAME="uptimed"
	FUN_VERBOSE_INSTALLING
	sudo apt install uptimed -y
	
	
	PKG_NAME="software-properties-common"
	FUN_VERBOSE_INSTALLING
	sudo apt install software-properties-common -y
	
	
	PKG_NAME="spice-vdagent"
	FUN_VERBOSE_INSTALLING
	sudo apt install spice-vdagent -y
	
	
	PKG_NAME="jstest-gtk"
	FUN_VERBOSE_INSTALLING
	sudo apt install jstest-gtk -y
	
	
	PKG_NAME="shc"
	FUN_VERBOSE_INSTALLING
	sudo apt install shc -y # Compile Bash sh scripts to Binary
	
	PKG_NAME="macchanger"
	FUN_VERBOSE_INSTALLING
	sudo apt install macchanger -y
	
	
	## install libqrencode4 
	PKG_NAME=" Install  libqrencode4"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y libqrencode4
	
	## install pip3
	PKG_NAME=" pip3 ..... python3-pip"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y python3-pip

	## install debhelper
	PKG_NAME=" debhelper "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y debhelper

	
	###······································································································
	###······································································································
	## Install flatpak
	PKG_NAME="Flatpak"
	FUN_VERBOSE_INSTALLING
	sudo apt install flatpak -y
	sudo apt install gnome-software-plugin-flatpak -y
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	## and Restart the System to complete flatpak intall
	flatpak install flathub org.freedesktop.Platform.openh264/x86_64/19.08 -y
	flatpak install flathub org.freedesktop.Platform.openh264/x86_64/2.0 -y
	###······································································································
	###······································································································
	
	
	
	###······································································································
	###······································································································
	## Install retroarch via flatpak
	PKG_NAME=" Retroarch Via Flatpak "
	FUN_VERBOSE_INSTALLING
	flatpak install flathub org.libretro.RetroArch -y
	flatpak install flathub runtime/org.freedesktop.Platform.openh264/x86_64/2.0 -y
	###······································································································
	###······································································································
	
	
	
	#netbeans is installed via flatpak now
	#PKG_NAME=" netbeans via snapd"
	#FUN_VERBOSE_INSTALLING
	#snap install netbeans --classic
	
	
	###······································································································
	###······································································································
	PKG_NAME=" netbeans via FLATPAK "
	FUN_VERBOSE_INSTALLING
	flatpak install flathub org.apache.netbeans -y
	###······································································································
	###······································································································
	
	
	
	
	### change fan speed ####
	sudo apt install -y lm-sensors
	#detect sensors (run sudo sensors-detect)
	#install fancontrol (can control with sudo pwmconfig command afterwards)
	sudo apt install -y fancontrol
	
	
	
	
	
	###······································································································
	###······································································································
	PKG_NAME=" FANSPEED_ALWAYS_X "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	### Install fanspeed_always_x (My Own Home-Brew Software :D)
	sudo apt update
	sudo apt install -y i8kutils 
	sudo chmod 777 /usr/bin/i8kmon
	sudo chown $USER:$USER /etc/i8kmon.conf
	
	sudo cp auto-installs-files/CUSTOM_FANSPEED_FILES/* /usr/bin/
	sudo chown $USER:$USER /usr/bin/fanspeed_status_config.file
	sudo chmod 777 /usr/bin/fanspeed_always*
	sudo chmod 777 /etc/i8kmon.conf
	
	sudo cp /usr/bin/FANSPEED_ALWAYS_MAX.service /etc/systemd/system
	sudo cp /usr/bin/FANSPEED_ALWAYS_MAX.timer /etc/systemd/system
	
	sudo mkdir -p /etc/systemd/system/CUST-SYSD
	sudo cp /usr/bin/FANSPEED_ALWAYS_MAX_TIMER.sh /etc/systemd/system/CUST-SYSD
	sudo chmod 777 /etc/systemd/system/CUST-SYSD/FANSPEED_ALWAYS_MAX_TIMER.sh
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	## ive been having weird issues due to this so im commenting it out, further testing needed
	#PKG_NAME=" copy custom DOT-FILES .config to /usr/bin AND to /etc/skel "
	#FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	## copy custom-dotfiles .config to /usr/bin
	#sudo cp -av auto-installs-files/CUSTOM-DOT-FILES /usr/bin
	#PKG_NAME=" copy custom DOT-FILES .config to /etc/skel"
	#sudo cp -av auto-installs-files/CUSTOM-DOT-FILES/.config /etc/skel
	##
	###······································································································
	###······································································································
	
	
	
	
	
	###······································································································
	###······································································································
	PKG_NAME=" copy CUSTOM-POWER-CONSUMPTION to /usr/bin "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	## copy custom power CONSUMPTION to /usr/bin
	sudo cp -av auto-installs-files/CUSTOM-POWER-CONSUMPTION /usr/bin
	sudo chmod -R 777 /usr/bin/CUSTOM-POWER-CONSUMPTION
	##
	###······································································································
	###······································································································
	
	
	

	
	
	
	
	###······································································································
	###······································································································
	PKG_NAME=" Dependencies for compiling linux kernel "
	FUN_VERBOSE_INSTALLING
	###
	# Dependencies for compiling linux kernel
	sudo apt install -y git
	sudo apt install -y fakeroot
	sudo apt install -y build-essential
	sudo apt install -y ncurses-dev
	sudo apt install -y xz-utils
	sudo apt install -y libssl-dev
	sudo apt install -y bc
	sudo apt install -y flex
	sudo apt install -y libelf-dev
	sudo apt install -y bison
	sudo apt install -y devscripts
	sudo apt install -y libncurses5
	sudo apt install -y linux-source
	sudo apt install -y kmod
	sudo apt install -y cpio
	sudo apt install -y dwarves
	sudo apt install -y libncurses5-dev
	#sudo apt install build‐dep -y
	#####
	###······································································································
	###······································································································
	
	
	
	
	
	PKG_NAME=" copy to /usr/bin everything in auto-installs-files/TO-USR-BIN "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	#####
	# copy to /usr/bin everything in auto-installs-files/TO-USR-BIN
	sudo cp auto-installs-files/TO-USR-BIN/* /usr/bin
	sudo chmod 777 /usr/bin/cwls
	#####
	
	
	
	
	PKG_NAME=" fix  permisions custom*  in /usr/bin  chmod 777"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	## chmod 777 all custom* in /usr/bin
	sudo chmod 777 /usr/bin/custom*
	
	
	
	
	PKG_NAME="  Set alias cwls=\"/usr/bin/custom-wares-ls\" >> $HOME/.bashrc "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	###### 
	## create alias in .bashrc file .... alias cwls=/usr/bin/custom-wares-ls
	echo "alias cwls=\"/usr/bin/custom-wares-ls\"" >> $HOME/.bashrc
	##
	

	
	
	PKG_NAME="   BTOP"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	## Install btop 
	sudo apt install -y coreutils sed git build-essential
	cd auto-installs-files
	mkdir BTOP-WORKER
	7z x btop++-x86_64-linux-musl.7z -oBTOP-WORKER
	cd BTOP-WORKER/btop++-x86_64-linux-musl
	make && sudo make install
	cd ../../../
	sudo rm -r auto-installs-files/BTOP-WORKER
	
	
	
	
	PKG_NAME="COPY itself (APT-AUTO-INSTALLS) to  $HOME/INTERNAL-WARES"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	##	COPY itself (APT-AUTO-INSTALLS) to  $HOME/INTERNAL-WARES ## so must be in a dir with a parent dir (below /)
	cd ..
	mkdir -p $HOME/INTERNAL-WARES/
	cp -av APT-AUTO-INSTALLS $HOME/INTERNAL-WARES/APT-AUTO-INSTALLS
	cd APT-AUTO-INSTALLS
	## 
	
	
	PKG_NAME=" create INTERNAL-WARES dir in $HOME and copy some .sh files to it "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	##### create INTERNAL-WARES dir in $HOME and copy some .sh files to it
	mkdir $HOME/INTERNAL-WARES
	cp -r auto-installs-files/CUSTOM-SH-SCRIPTS/* $HOME/INTERNAL-WARES
	#####
	
	
	
	
	###······································································································
	###······································································································
	## install kvm qemu virtmanager, adduser to kvm  & autoload modules for pcie passthrough ##############
	PKG_NAME="KVM QEMU VIRT-MANAGER"
	FUN_VERBOSE_INSTALLING
	sudo apt update;sleep 1
	sudo apt install -y qemu-kvm 
	sudo apt install -y qemu-system-x86 
	sudo apt install -y qemu-system
	sudo apt install -y libvirt-daemon-system 
	sudo apt install -y libvirt-clients 
	sudo apt install -y bridge-utils 
	sudo apt install -y virtinst 
	sudo apt install -y virt-manager
	sudo usermod -aG libvirt $USER
	sudo usermod -aG libvirt-qemu $USER
	sudo usermod -aG kvm $USER
	
	cat auto-installs-files/kvm-modules.conf | sudo tee /etc/modules-load.d/kvm-modules.conf
	
	#fix audio qemu kvm virtmanager using sed
	sudo sed -i 's|user = "root"||g' /etc/libvirt/qemu.conf
	sudo sed -i 's|user = "'${USER}'"||g' /etc/libvirt/qemu.conf
	echo "user = \"$USER\"" | sudo tee -a /etc/libvirt/qemu.conf
	###······································································································
	###······································································································
	
	
	
	
	#kwrite is installed by apt
	## Install kwrite via flatpak
	#PKG_NAME="Install kwrite via flatpak"
	#FUN_VERBOSE_INSTALLING
	#flatpak install flathub org.kde.kwrite -y
	##
	
	
	
	
	
	###······································································································
	###······································································································
	##### CUSTOM SYSTEMD UNIT FILE ##############################
	PKG_NAME="CUSTOM SYSTEMD UNIT FILE"
	FUN_VERBOSE_INSTALLING
	sudo mkdir -m 777 /etc/systemd/system/CUST-SYSD
	sudo touch /etc/systemd/system/CUST-SYSD/CUSTOM-STARTUP.sh
	sudo chown $USER /etc/systemd/system/CUST-SYSD/CUSTOM-STARTUP.sh
	sudo chgrp $USER /etc/systemd/system/CUST-SYSD/CUSTOM-STARTUP.sh
	sudo chmod +777 /etc/systemd/system/CUST-SYSD/CUSTOM-STARTUP.sh
	
	cat auto-installs-files/CUSTOM-STARTUP.sh > /etc/systemd/system/CUST-SYSD/CUSTOM-STARTUP.sh
	
	sudo touch /etc/systemd/system/CUSTOM-STARTUP.service
	sudo chown $USER /etc/systemd/system/CUSTOM-STARTUP.service
	sudo chgrp $USER /etc/systemd/system/CUSTOM-STARTUP.service
	sudo chmod +777 /etc/systemd/system/CUSTOM-STARTUP.service
	
	cat auto-installs-files/CUSTOM-STARTUP.service > /etc/systemd/system/CUSTOM-STARTUP.service
	sudo systemctl enable CUSTOM-STARTUP
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	### INSTALL INTEL OPENCL RUNTIME  ######
	PKG_NAME="INTEL OPENCL RUNTIME"
	FUN_VERBOSE_INSTALLING
	cd auto-installs-files
	sudo rm -r intel-opencl-runtime
	mkdir intel-opencl-runtime
	7z x intel-opencl-neo.7z -ointel-opencl-runtime
	cd intel-opencl-runtime
	sudo dpkg -i *.deb
	cd ../../
	sudo rm -r auto-installs-files/intel-opencl-runtime
	###······································································································
	###······································································································
	
	
	
	
	
	###······································································································
	###······································································································
	### INSTALL 8188eu driver for TP-Link TL-WN722N v2/v3 #Latest commit-mar-2022######################
	###############
	#PKG_NAME="8188eu driver for TP-Link TL-WN722N v2/v3"
	#FUN_VERBOSE_INSTALLING
	#echo 'blacklist r8188eu'|sudo tee '/etc/modprobe.d/realtek.conf'
	#cd auto-installs-files
	#sudo rm -r aircrack-ng8188eus
	#mkdir aircrack-ng8188eus
	#7z x 'rtl8188eus.7z' -oaircrack-ng8188eus
	#cd aircrack-ng8188eus
	#cd rtl8188eus
	#make all
	#sudo make install
	#cd ../../../
	#sudo rm -r auto-installs-files/aircrack-ng8188eus
	##############
	###······································································································
	###······································································································
	
	

	
	
	
	

	



	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565
	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565
	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565
	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565
	###······································································································
	###······································································································


	### INSTALL .DEB FILES IN auto-installs-files/DEB-FILES DIR  #######
	PKG_NAME=".DEB FILES IN AUTO-INSTALLS-FILES DIR"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo apt install ./auto-installs-files/DEB-FILES/*deb -y

	###······································································································
	###······································································································
	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565
	##-*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+5652++9+52235233+6+*--*-*--9+3352*+565








	
	
	
	###······································································································
	###······································································································
	### INSTALL LINUX-WIFI-HOTSPOT Build From Source ##################################
			#######
	#PKG_NAME="LINUX-WIFI-HOTSPOT"
	#FUN_VERBOSE_INSTALLING
	#sudo cp /usr/sbin/iw /bin
	#sudo chmod +777 /bin/iw
	#sudo chown $USER /bin/iw
	#sudo chgrp $USER /bin/iw
	#sudo apt update;sleep 1
	#sudo apt install -y bash util-linux procps hostapd iproute2 iw haveged dnsmasq iptables
	#sudo apt install -y libgtk-3-dev build-essential gcc g++ pkg-config make hostapd libqrencode4 libqrencode-dev libpng-dev
	#cd auto-installs-files
	#sudo rm -r linux-wifi-HOTSPOT
	#mkdir linux-wifi-HOTSPOT
	#7z x linux-wifi-hotspot-v4.4.0.7z -olinux-wifi-HOTSPOT
	#cd linux-wifi-HOTSPOT/linux-wifi-hotspot-v4.4.0-master/
	#make
	#sudo make install
	#cd ../../../
	#sudo rm -r auto-installs-files/linux-wifi-HOTSPOT
			#########
    ###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
			### INSTALL LINUX-WIFI-HOTSPOT  DEBIAN PACKAGE i made using debuild command ###########################
					########################
			PKG_NAME="LINUX-WIFI-HOTSPOT  deb package "
			FUN_VERBOSE_INSTALLING
			sudo apt install -y bash util-linux procps hostapd iproute2 iw haveged dnsmasq iptables
			sudo apt install -y libgtk-3-dev build-essential gcc g++ pkg-config make hostapd libqrencode4 libqrencode-dev libpng-dev

			sudo apt install ./auto-installs-files/LINUX-WIFI-HOTSPOT-deb/*deb -y
					############################
	###······································································································
	###······································································································
	
	
	
	
	
	###·····································································································
	## Dolphin-EMU (gamecube & wii emulator) Gaming emulator !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	####################
	PKG_NAME="DOLPHIN-EMULATOR"
	FUN_VERBOSE_INSTALLING
	sudo apt update;sleep 1
	sudo apt install --no-install-recommends ca-certificates qtbase5-dev qtbase5-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext -y
	
	cd auto-installs-files
	sudo rm -r DOLPHIN-EMU-worker
	mkdir DOLPHIN-EMU-worker
	7z x dolphin.7z -oDOLPHIN-EMU-worker
	cd DOLPHIN-EMU-worker
	cd dolphin
	git submodule update --init 
	mkdir Build && cd Build
	cmake .. 
	make -j$(nproc) 
	sudo make install
	cd ../../../../
	sudo rm -r auto-installs-files/DOLPHIN-EMU-worker
	###############################
	###······································································································
	###······································································································		
	
	
	

			
			
			
			
	###······································································································
	###······································································································
	## Antimicrox install from source (map gamepad keys to keyboard) ####
			###############
	#PKG_NAME="ANTIMICROX"
	#FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	#sudo apt install -y extra-cmake-modules qtbase5-dev qttools5-dev qttools5-dev-tools libsdl2-dev libxi-dev libxtst-dev libx11-dev itstool
	
	#cd auto-installs-files
	#sudo rm -r mkdir ANTIMICROX-worker
	#mkdir ANTIMICROX-worker
	#7z x antimicrox.7z -oANTIMICROX-worker
	#cd ANTIMICROX-worker/antimicrox
	#mkdir build && cd build
	#cmake ..
	#cmake --build .
	#sudo cmake --install .
	#cd ../../../../
	#sudo rm -r auto-installs-files/ANTIMICROX-worker
			##################
	###······································································································
	###······································································································		
			
			
	
	
	###······································································································
	###······································································································
	# ANTIMICROX deb package
			######################
	PKG_NAME="ANTIMICROX  deb package"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y extra-cmake-modules qtbase5-dev qttools5-dev qttools5-dev-tools libsdl2-dev libxi-dev libxtst-dev libx11-dev itstool
	sudo apt install ./auto-installs-files/ANTIMICROX-deb/*.deb -y
			#####################
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
			### Antimicrox install via flatpak
			#PKG_NAME="ANTIMICROX  via flatpak"
			#FUN_VERBOSE_INSTALLING
			#flatpak install flathub io.github.antimicrox.antimicrox -y
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	## Copy antimicrox Profile settings file
	PKG_NAME="Copy antimicrox Profile settings file to $HOME  & $HOME/INTERNAL-WARES"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sleep 3
	cp -av auto-installs-files/Antimicrox-profile-NACEB.amgp $HOME/INTERNAL-WARES
	cp -av auto-installs-files/Antimicrox-profile-NACEB.amgp $HOME
	sudo cp -av auto-installs-files/Antimicrox-profile-NACEB.amgp /home
	##
	###······································································································
	###······································································································
	
	
	
	
	
	
	
	###······································································································
	###······································································································
	#install mupen64plus-qt [nintendo 64 emulator] & configure gamepad & video flickering fix
	#config files are the result of jostick fix + flickering fix + running it with the following commands:
	# mupen64plus --resolution 1024x600 --saveoptions --gfx mupen64plus-video-glide64mk2 <n64 game ROM>
	#alternatively# mupen64plus --resolution 1024x600 --fullscreen --saveoptions --gfx mupen64plus-video-glide64mk2 <n64 game ROM>
	PKG_NAME="mupen64plus-qt"
	FUN_VERBOSE_INSTALLING
	sudo rm -r $HOME/.config/mupen64plus
	sudo apt install mupen64plus-qt -y
	mate-terminal --window -e 'mate-terminal -e mupen64plus-qt'
	
	sleep 2
	killall mupen64plus-qt
	###······································································································
	###······································································································
	
	
	
	###······································································································
	###······································································································
	#copy mupen64 conf's to /usr/bin
	sudo cp auto-installs-files/mupen64plus-qt.conf /usr/bin
	sudo cp auto-installs-files/mupen64plus.cfg /usr/bin
	###······································································································
	###······································································································
	
	
	
	###······································································································
	###······································································································
	####mupen64 config files in CUSTOM-WARES FOLDER
	cp auto-installs-files/mupen64plus* $HOME/INTERNAL-WARES
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	##### install wifiphisher & copy to INTERNAL-WARES dir in $HOME ##
	PKG_NAME="WIFIPHISHER"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y libnl-3-dev libnl-genl-3-dev libssl-dev
	cd auto-installs-files
	sudo rm -r WIFIPHISHER-WORKER
	mkdir WIFIPHISHER-WORKER
	7z x wifiphisher.7z -oWIFIPHISHER-WORKER
	cd WIFIPHISHER-WORKER/wifiphisher
	sudo python setup.py install
	cd ../../../
	sudo cp -r auto-installs-files/WIFIPHISHER-WORKER/wifiphisher $HOME/INTERNAL-WARES
	sudo rm -r auto-installs-files/WIFIPHISHER-WORKER
	###······································································································
	###······································································································
	
	
	
	
	
	###······································································································
	###······································································································
	##### install fluxion and copy to INTERNAL-WARES dir in $HOME##
	PKG_NAME="FLUXION"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y php-cgi
	cd auto-installs-files
	sudo rm -r FLUXION-WORKER
	mkdir FLUXION-WORKER
	7z x fluxion.7z -oFLUXION-WORKER
	cd FLUXION-WORKER/fluxion
	
	echo "sudo ./fluxion.sh -i" | tee fluxion-installer-tmp.sh
	chmod 777 fluxion-installer-tmp.sh
	mate-terminal --window -e 'mate-terminal --workdir $PWD -e 'fluxion-installer-tmp.sh''
	rm fluxion-installer-tmp.sh
	cd .. && sudo cp -r fluxion $HOME/INTERNAL-WARES
	cd ../../
	sudo rm -r auto-installs-files/FLUXION-WORKER
	###······································································································
	###······································································································
	
	

	
	
				## I think Virtualbox installation specifically should be handled individuly in the case statement, for each seperate distro ... so as to not cause issues.. so im commenting it out here
	###······································································································
	###······································································································
	######################################################################################
	##### install VIRTUALBOX & add users to vboxusers from repository ######################
	##################(commented b/c having problems ,bit outdated vbox version and mostly no virtualbox-ext-pack existence, virtualbox extensions pack..which is necessary so will install manually....for now? )
	#######################################################################
	#sudo apt update;sleep 1
	#sudo apt install -y virtualbox
	#sudo apt install -y virtualbox-dkms
	#sudo apt install -y virtualbox-ext-pack
	#sudo apt install -y virtualbox-guest-utils
	#sudo apt install -y virtualbox-guest-x11
	#sudo apt install -y virtualbox-guest-additions-iso
	#sudo apt install -y virtualbox-guest-dkms
	#sudo usermod -aG vboxusers $USER
	# enable VIRTUALBOX raw disk access without root
	#sudo usermod -aG disk $USER
	######################################################################
	######################################################################
	###······································································································
	###······································································································
	
	
	
	
	

	
	###······································································································
	###······································································································
	## Install  GENYMOTION 
	PKG_NAME=" Install  GENYMOTION "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo chmod 777 auto-installs-files/genymotion*.bin
	sudo auto-installs-files/genymotion*.bin -y
	###······································································································
	###······································································································
	
	
	




	##install security tools
	PKG_NAME=" Install MDK4"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y mdk4

	PKG_NAME=" AIRCRACK-NG "
	FUN_VERBOSE_INSTALLING
	sudo apt install -y aircrack-ng



	#install hashcat 
	PKG_NAME=" HASHCAT "
	FUN_VERBOSE_INSTALLING
	cd auto-installs-files/HASHCATS
	sudo rm -r HASHCAT-WORKER
	mkdir HASHCAT-WORKER
	7z x hashcat.7z -oHASHCAT-WORKER
	cd HASHCAT-WORKER/hashcat
	sudo make install
	cd ../../../../
	sudo rm -r auto-installs-files/HASHCATS/HASHCAT-WORKER

	
	
	# install hashcat-utils.. specifically just cap2hccapx
	PKG_NAME=" HASHCAT -UTILS"
	FUN_VERBOSE_INSTALLING
	cd auto-installs-files/HASHCATS
	sudo rm -r hashcats-WORKER
	mkdir hashcats-WORKER
	7z x hashcat-utils.7z -ohashcats-WORKER
	sudo cp hashcats-WORKER/hashcat-utils/bin/cap2hccapx /usr/bin
	cd ../../
	sudo rm -r auto-installs-files/HASHCATS/hashcats-WORKER
    
    
	# install hashcat hcxdumptool: https://github.com/ZerBea/hcxdumptool
  		####################
   PKG_NAME=" HASHCAT  HCXDUMPTOOL"
   FUN_VERBOSE_INSTALLING
   cd auto-installs-files/HASHCATS
   sudo rm -r hcxdumptool-WORKER
   mkdir  hcxdumptool-WORKER
   7z x hcxdumptool.7z -ohcxdumptool-WORKER
   cd hcxdumptool-WORKER/hcxdumptool
   sudo make install
   cd ../../../../
   sudo rm -r auto-installs-files/HASHCATS/hcxdumptool-WORKER
   		#####################
   
   
	#install hashcat hcxtools: https://github.com/ZerBea/hcxtools
 		######################
 	PKG_NAME=" HASHCAT  HCXTOOLS"
	FUN_VERBOSE_INSTALLING
    cd auto-installs-files/HASHCATS
    sudo rm -r hcxtools-WORKER
    mkdir hcxtools-WORKER
    7z x hcxtools.7z -ohcxtools-WORKER
    cd hcxtools-WORKER/hcxtools
    sudo make install
    cd ../../../../
    sudo rm -r auto-installs-files/HASHCATS/hcxtools-WORKER
			#######################
			
	
	
	
	
	


	
	## ENDING OF MAIN FUNCTION
}











function FUN_SPECIFIC_FOR_PARROT_4x {
	
	PKG_NAME="mate-desktop-environment-extras"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y mate-desktop-environment
	sudo apt install -y caja-eiciel
    sudo apt install -y caja-gtkhash
	sudo apt install -y caja-image-converter
	sudo apt install -y caja-rename
	sudo apt install -y caja-seahorse
	sudo apt install -y dconf-editor
	sudo apt install -y mate-dock-applet
	sudo apt install -y mate-menu
	sudo apt install -y mate-user-share
	sudo apt install -y mate-tweak
	sudo apt install -y blueman
	sudo apt install mate-desktop-environment-extras -y
	
	
	PKG_NAME="caja-gtkhash"
	FUN_VERBOSE_INSTALLING
	sudo apt install caja-gtkhash -y
		
	
	
	PKG_NAME="CUBIC manually adding ppa CUBIC"
	FUN_VERBOSE_INSTALLING
	####
	###  Add CUBIC (Custom Ubuntu ISO Creator) Manually PPA
	#remove the ppa if already exists in file
	sudo sed -i 's|deb http://ppa.launchpad.net/cubic-wizard/release/ubuntu focal main||' /etc/apt/sources.list.d/parrot.list
	sudo sed -i 's|deb-src http://ppa.launchpad.net/cubic-wizard/release/ubuntu focal main||' /etc/apt/sources.list.d/parrot.list
	echo "deb http://ppa.launchpad.net/cubic-wizard/release/ubuntu focal main" | sudo tee -a /etc/apt/sources.list.d/parrot.list
	echo "deb-src http://ppa.launchpad.net/cubic-wizard/release/ubuntu focal main " | sudo tee -a /etc/apt/sources.list.d/parrot.list
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7579F80E494ED3406A59DF9081525E2B4F1283B
	sudo apt update
	sudo apt install --no-install-recommends cubic -y
	###
	####
	
	
	
	
	###······································································································
	###······································································································
	### INSTALL   VIRTUALBOX  MANUALLY  #####
	PKG_NAME="VIRTUALBOX MANUALLY"
	FUN_VERBOSE_INSTALLING
	
	#dependecies 
	apt install -y acpica-tools chrpath doxygen g++-multilib libasound2-dev libcap-dev libcurl4-openssl-dev libdevmapper-dev libidl-dev libopus-dev libpam0g-dev libpulse-dev libqt5opengl5-dev libqt5x11extras5-dev qttools5-dev libsdl1.2-dev libsdl-ttf2.0-dev libssl-dev libvpx-dev libxcursor-dev libxinerama-dev libxml2-dev libxml2-utils libxmu-dev libxrandr-dev make nasm python3-dev python-dev qttools5-dev-tools texlive texlive-fonts-extra texlive-latex-extra unzip xsltproc default-jdk libstdc++5 libxslt1-dev linux-kernel-headers makeself mesa-common-dev subversion yasm zlib1g-dev
	
	apt install -y ia32-libs libc6-dev-i386 lib32gcc1 lib32stdc++6
	
	cd auto-installs-files/VIRTUALBOX-FILES
	sudo apt install ./virtualbox*.deb -y
	sudo usermod -aG vboxusers $USER
	
	# enable VIRTUALBOX raw disk access without root
	sudo usermod -aG disk $USER
	cd ../../
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	PKG_NAME="Virtualbox's Ext Pack - VBoxGuestAdditions.iso manually "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	#VBoxGuestAdditions.iso located in /usr/share/virtualbox/VBoxGuestAdditions.iso
	
	###################
	cd auto-installs-files/VIRTUALBOX-FILES
	sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
	echo ""
	VBoxManage list extpacks
	###copy this version of virtualbox-guest-additions-iso 
	###(guest-addition-iso-is-correctly-created once virtualbox is installed)
	sudo cp VBoxGuestAdditions*.iso /usr/share/virtualbox/VBoxGuestAdditions.iso
	cd ../../
	###################
	##############################################################################################
	##############################################################################################
	###······································································································
	###······································································································
	
	
	
	
	###······································································································
	###······································································································
	PKG_NAME=" Install Virtualbox Guest Additions *ISO manually "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	#Install Virtualbox Guest Additions *ISO
	sudo chmod 777 auto-installs-files/VIRTUALBOX-FILES/VBoxGuestAdditions/VBoxLinuxAdditions.run
	sudo auto-installs-files/VIRTUALBOX-FILES/VBoxGuestAdditions/VBoxLinuxAdditions.run
	###······································································································
	###······································································································
	
	
	
	###······································································································
	###······································································································
	### INSTALL 8188eu driver for TP-Link TL-WN722N v2/v3 #Latest commit-mar-2022######################
	###############
	PKG_NAME="8188eu driver for TP-Link TL-WN722N v2/v3"
	FUN_VERBOSE_INSTALLING
	echo 'blacklist r8188eu'|sudo tee '/etc/modprobe.d/realtek.conf'
	cd auto-installs-files
	sudo rm -r aircrack-ng8188eus
	mkdir aircrack-ng8188eus
	7z x 'rtl8188eus.7z' -oaircrack-ng8188eus
	cd aircrack-ng8188eus
	cd rtl8188eus
	make all
	sudo make install
	cd ../../../
	sudo rm -r auto-installs-files/aircrack-ng8188eus
	##############
	###······································································································
	###······································································································
	
	
	
	###······································································································
	###······································································································
	## Install  GENYMOTION 
	PKG_NAME=" Install  GENYMOTION "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo chmod 777 auto-installs-files/genymotion*.bin
	sudo auto-installs-files/genymotion*.bin -y
	###······································································································
	###······································································································
	
	
	###······································································································
	###······································································································
	#PKG_NAME=" PARROT Background wallpapapers to /usr/share/images/desktop-base/ & /usr/share/backgrounds "
	#FUN_VERBOSE_INSTALLING
	#####
	#Background wallpapaer  parrot fly darker copy to /usr/share/backgrounds
	#sudo cp auto-installs-files/BACKGROUND-IMAGES/* /usr/share/images/desktop-base
	#sudo cp auto-installs-files/BACKGROUND-IMAGES/parrot-fly-grey.jpg /usr/share/backgrounds
	#####
	###······································································································
	###······································································································
	
	
	## Disable password prompt to mount Partitions Parrot Sec Os
	PKG_NAME=" PARROT Disable password prompt to mount Partitions Parrot Sec Os "
	FUN_VERBOSE_INSTALLING
	sudo cp -v auto-installs-files/org.freedesktop.UDisks2.policy /usr/share/polkit-1/actions/
	
		
}



function FUN_SPECIFIC_FOR_UBUNTU_MATE {
	
	#INSTALL CUBIC with ppa (normal method)
	PKG_NAME=" CUBIC  via ppa "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo apt-add-repository ppa:cubic-wizard/release
	sudo apt update
	sudo apt install cubic -y
	
	
	
	PKG_NAME="mate-desktop-environment-extras"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y mate-desktop-environment
	sudo apt install -y caja-eiciel
    sudo apt install -y caja-gtkhash
	sudo apt install -y caja-image-converter
	sudo apt install -y caja-rename
	sudo apt install -y caja-seahorse
	sudo apt install -y dconf-editor
	sudo apt install -y mate-dock-applet
	sudo apt install -y mate-menu
	sudo apt install -y mate-user-share
	sudo apt install -y mate-tweak
	sudo apt install -y blueman
	sudo apt install mate-desktop-environment-extras -y
	
	PKG_NAME="caja-gtkhash"
	FUN_VERBOSE_INSTALLING
	sudo apt install caja-gtkhash -y
	
	
	
	
	
	
	###······································································································
	###······································································································
	### INSTALL 8188eu driver for TP-Link TL-WN722N v2/v3 #Latest commit-mar-2022######################
	###############
	PKG_NAME="8188eu driver for TP-Link TL-WN722N v2/v3"
	FUN_VERBOSE_INSTALLING
	echo 'blacklist r8188eu'|sudo tee '/etc/modprobe.d/realtek.conf'
	cd auto-installs-files
	sudo rm -r aircrack-ng8188eus
	mkdir aircrack-ng8188eus
	7z x 'rtl8188eus.7z' -oaircrack-ng8188eus
	cd aircrack-ng8188eus
	cd rtl8188eus
	make all
	sudo make install
	cd ../../../
	sudo rm -r auto-installs-files/aircrack-ng8188eus
	##############
	###······································································································
	###······································································································
	
	
	#install virtualbox
	PKG_NAME=" Install  VIRTUALBOX"
	FUN_VERBOSE_INSTALLING
	sudo apt install -y virtualbox
    sudo apt install -y virtualbox-dkms
	sudo apt install -y virtualbox-ext-pack
	
	
	######################################################################################
	##### install VIRTUALBOX & add users to vboxusers from repository ######################
	##################
	#######################################################################
	PKG_NAME=" Install  VIRTUALBOX"
	FUN_VERBOSE_INSTALLING
	sudo apt update;sleep 1
	sudo apt install -y virtualbox
	sudo apt install -y virtualbox-dkms
	sudo apt install -y virtualbox-ext-pack
	sudo apt install -y virtualbox-guest-utils
	sudo apt install -y virtualbox-guest-x11
	sudo apt install -y virtualbox-guest-additions-iso
	sudo apt install -y virtualbox-guest-dkms
	sudo usermod -aG vboxusers $USER
	# enable VIRTUALBOX raw disk access without root
	sudo usermod -aG disk $USER
	######################################################################
	######################################################################
	###······································································································
	###······································································································
	
	
	###······································································································
	PKG_NAME="Virtualbox's Ext Pack - VBoxGuestAdditions.iso manually "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	#VBoxGuestAdditions.iso located in /usr/share/virtualbox/VBoxGuestAdditions.iso

	###################
	cd auto-installs-files/VIRTUALBOX-FILES
	sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
	echo ""
	VBoxManage list extpacks
	###copy this version of virtualbox-guest-additions-iso
	###(guest-addition-iso-is-correctly-created once virtualbox is installed)
	#sudo cp VBoxGuestAdditions*.iso /usr/share/virtualbox/VBoxGuestAdditions.iso
	cd ../../
	###################
	
	
	###······································································································
	###······································································································
	## Install  GENYMOTION 
	PKG_NAME=" Install  GENYMOTION "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo chmod 777 auto-installs-files/genymotion*.bin
	sudo auto-installs-files/genymotion*.bin -y
	###······································································································
	###······································································································
	
	
	## Antimicrox install from source (map gamepad keys to keyboard) ####
	###############··················
	PKG_NAME="ANTIMICROX"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo apt install -y extra-cmake-modules qtbase5-dev qttools5-dev qttools5-dev-tools libsdl2-dev libxi-dev libxtst-dev libx11-dev itstool
	
	cd auto-installs-files
	sudo rm -r mkdir ANTIMICROX-worker
	mkdir ANTIMICROX-worker
	7z x antimicrox.7z -oANTIMICROX-worker
	cd ANTIMICROX-worker/antimicrox
	mkdir build && cd build
	cmake ..
	cmake --build .
	sudo cmake --install .
	cd ../../../../
	sudo rm -r auto-installs-files/ANTIMICROX-worker
	###########################········································
	
	#########·········································································································
	PKG_NAME="  INSTALLL AIRGEDDON AND ITS DEPENDENCIES "
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo sed -i 's|deb http://http.kali.org/kali kali-rolling main contrib non-free||g' /etc/apt/sources.list
	sudo apt update
	
	echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | sudo tee -a /etc/apt/sources.list
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6
	sudo apt update
	sleep 3
	
	sudo apt install -y airgeddon
	#airgeddon essential tools
	sudo apt install -y aircrack-ng 
	sudo apt install -y iproute2 
	sudo apt install -y procps 
	sudo apt install -y hostapd 
	sudo apt install -y asleap
	sudo apt install -y ettercap 
	sudo apt install -y ettercap-graphical
	sudo apt install -y etterlog 
	sudo apt install -y tshark 
	sudo apt install -y john 
	sudo apt install -y bully 
	sudo apt install -y mdk4 
	sudo apt install -y beef-xss 
	sudo apt install -y pixiewps 
	sudo apt install -y reaver 
	sudo apt install -y isc-dhcp-server 
	sudo apt install -y crunch
	#airgeddon optional tools
	sudo apt install -y bettercap
	sudo apt install -y hostapd
	sudo apt install -y hostapd-wpe
	sudo apt install -y aircrack-ng
	sudo apt install -y crunch
	sudo apt install -y mdk4
	sudo apt install -y lighttpd
	sudo apt install -y nftables
	sudo apt install -y iptables
	sudo apt install -y beef-xss
	sudo apt install -y hostapd-wpe
	
	sudo sed -i 's|deb http://http.kali.org/kali kali-rolling main contrib non-free||g' /etc/apt/sources.list
	sudo apt update

		#·Copy custom airgeddon files from auto-installs-files/CUSTOM-AIRGEDDON-FILES, to its corresponding locations
			#to killall dnsmasq
		sudo cp auto-installs-files/CUSTOM-AIRGEDDON-FILES/airgeddon /usr/bin/
			#to free up port 53 used by systemd-resolved
		sudo cp auto-installs-files/CUSTOM-AIRGEDDON-FILES/resolved.conf /etc/systemd

	#########·········································································································
	
	

}








function FUN_KERNEL_PARAMETERS_FOR_ALL {
	#################################### KERNEL PARAMETERS FOR ALL GENERAL HARDWARE
	
	#custom KERNEL PARAMETERS (KERNEL BOOT PARAMETERS)
	PKG_NAME="CUSTOM (KERNEL PARAMETERS) GENERIC Hardware"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo touch /etc/default/grub.d/custom-kernel-parameters.cfg
	
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off intel_iommu=on amd_iommu=on"' \
	| sudo tee /etc/default/grub.d/custom-kernel-parameters.cfg
	
	sudo update-grub
}






function FUN_KERNEL_PARAMETERS_SPECIFIC_TO_DELL_5558_CARD_READER_ON {
	
	#custom KERNEL PARAMETERS (KERNEL BOOT PARAMETERS) SPECIFIC FOR DELL-INSPIRON-5558
	
	PKG_NAME=" (KERNEL PARAMETERS) SPECIFIC FOR DELL-INSPIRON-5558"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo touch /etc/default/grub.d/custom-kernel-parameters.cfg
	
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off intel_iommu=on amd_iommu=on"' \
	| sudo tee /etc/default/grub.d/custom-kernel-parameters.cfg
	
	sudo update-grub  
	sudo update-initramfs -u
}



function FUN_KERNEL_PARAMETERS_SPECIFIC_TO_DELL_5558_CARD_READER_OFF {
			#apparently not needed since kernel 5.15+
	#custom KERNEL PARAMETERS (KERNEL BOOT PARAMETERS) SPECIFIC FOR DELL-INSPIRON-5558 Disable card reader
	
	PKG_NAME=" (KERNEL PARAMETERS) SPECIFIC FOR DELL-INSPIRON-5558"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	sudo touch /etc/default/grub.d/custom-kernel-parameters.cfg
	
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off intel_iommu=on amd_iommu=on module_blacklist=rtsx_usb_sdmmc,rtsx_usb_ms,rtsx_usb"' \
	| sudo tee /etc/default/grub.d/custom-kernel-parameters.cfg
	
	sudo update-grub  
	sudo update-initramfs -u
}





function FUN_WARES_SPECIFIC_TO_DELL_5558_CARD_READER_OFF {
	
	########################### WARES SPECIFIC FOR DELL INSPIRON 5558
	### RTS5129 card reder works out of the box in parrot os 5.0 so im not going to run it
	#fix-card-reader-RTS5129-linux; Fix for RTS5129 USB MMC card reader on Linux
	PKG_NAME="FIX RTS5129 USB MMC CARD READER"
	FUN_VERBOSE_INSTALLING_NO_APT_UPDATE
	cat auto-installs-files/'blacklist-rtsx_usb_sdmmc-rtsx_usb_ms-rtsx_usb(fix-card-reader-RTS5129).conf' \
	| sudo tee /etc/modprobe.d/'custom-blacklist-(fix-card-reader-RTS5129)'.conf
	cd auto-installs-files
	mkdir FIX-CARD-READER-RTS5129
	7z x fix-card-reader-RTS5129-linux.7z -oFIX-CARD-READER-RTS5129
	cd FIX-CARD-READER-RTS5129/fix-card-reader-RTS5129-linux
	7z x rts5139-master.7z
	cd rts5139-master
	make
	sudo make install
	sudo depmod -a
	cd ../../../../
	sudo rm -r auto-installs-files/FIX-CARD-READER-RTS5129
}




function COPY_PARROT_THEMES {

echo " COPYING PARROT THEMES & ICONS TO /usr/share ---- may take a while "

sudo rm -r auto-installs-files/PARROT-THEMES/icons
sudo rm -r auto-installs-files/PARROT-THEMES/themes

cd auto-installs-files/PARROT-THEMES
tar xvf parrot-themes-n-icons.tar
sudo cp -Rv themes/* /usr/share/themes/
sudo cp -Rv icons/maia /usr/share/icons/


sudo rm -r themes
sudo rm -r icons
cd ../../

echo " "
echo "DONE "

}


##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)
##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)##%$)(*\/*)


tput setab 82;tput setaf 52;tput bold
echo -e " WELCOME TO APT-AUTO-INSTALLS...\v INPUT YOUR CHOICE :: [1 .... 4]"
echo -e "\n 1.- APT-AUTO-INSTALLS  [For general Hardware (Permanent Instalations (Non-Persistent installs)]"
echo -e "\n 2.- apt-auto installs-Dell-Inspiron-5558 [PARROT 4X]   [Specific For Dell Inspiron 5558 Hardware] PARROT OS 4x SPECIFIC"
echo -e "\n 3.- apt-auto installs-Dell-Inspiron-5558  UBUNTU MATE / LINUX_MINT"
echo -e "\n 4.- COPY PARROT THEMES & ICONS "
echo -e "\n\n"

read -t 20 -p "Please Input Your Choice  [1 .. 2 .. 3 .. 4] :: " CHOICE
tput sgr0



case $CHOICE in

1)
echo "You Have Chosen  1- APT-AUTO-INSTALLS  [For general Hardware]"
FUN_WARES_FOR_ALL
FUN_KERNEL_PARAMETERS_FOR_ALL
echo "	All DONE	:D  :-)"
;;


2)
echo "You Have Chosen  2.- apt-auto installs-Dell-Inspiron-5558 [PARROT 4X]   [Specific For Dell Inspiron 5558 Hardware] PARROT OS 4x SPECIFIC"
FUN_WARES_FOR_ALL
FUN_SPECIFIC_FOR_PARROT_4x
FUN_KERNEL_PARAMETERS_SPECIFIC_TO_DELL_5558_CARD_READER_OFF

# the fix to the rts5129 card reader, it works out of the box for parrot os 5.0
FUN_WARES_SPECIFIC_TO_DELL_5558_CARD_READER_OFF

# set keyboard locale to spanish latin america
sudo cp auto-installs-files/keyboard /etc/default

echo "	All DONE	:D  :-)"
;;


3)
echo "You Have Chosen  3.- apt-auto installs-Dell-Inspiron-5558  LINUX_UBUNTU_MATE / LINUX_MINT"
FUN_WARES_FOR_ALL
FUN_SPECIFIC_FOR_UBUNTU_MATE
FUN_KERNEL_PARAMETERS_SPECIFIC_TO_DELL_5558_CARD_READER_ON

sudo cp auto-installs-files/keyboard /etc/default

;;

4)
echo "You have chosen 4. - COPY PARROT THEMES & ICONS"
COPY_PARROT_THEMES

echo "	All DONE	:D  :-)"
;;




*)
echo "Not a valid Choice !  Must be  [1 .. 2 ..  3 .. 4]    Exiting"
exit
esac
