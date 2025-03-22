# Important Notes

**DONT RUN AS SUDO; RUN AS NORMAL USER AND IT WILL PROMPT YOU FOR SUDO PASSWORD**

**DONT RUN AS SUDO; RUN AS NORMAL USER** because it messes up the `$HOME` directory. It makes `$HOME` always point to root. So, **DONT RUN AS SUDO**.

---

## Project Overview

This project provides a set of scripts to install and configure programs on a Linux system automatically/unattended. It allows users to create a Linux system with custom configurations and installed programs easily. It can also be used to create a custom ISO with such configurations and programs.

---

## Project Structure

### Main Directories (Essential/Indispensable)

- **APT-AUTO-INSTALLS**
  - **AUTO-INSTALLS-FILES**: Contains directories & files to support this entire app
    - **THEMES-N-DOT-FILES**: Holds files to customize UI/DE/theme settings, e.g., `/etc/skel`
  - **WARES-LIB**: Contains library files to source into the main app for each target distro/DE
    - **LINUX-GNOME-AND-MATE-DE-LIB**: A library directory for GNOME/MATE DE, Ubuntu/Debian-based OS
    - **FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB**: Code called by the entry-point app
  - **AUTO_INSTALLS_MASTER.bash**: Entry point of the application
  - **README.md**: Documentation for the project

---

### Application Flow

1. `AUTO_INSTALLS_MASTER.bash`  
   ⇓  
2. Calls `FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB`  
   ⇓  
3. Executes the rest of the scripts

**That's it for now!**

---

## Complete Directory Tree (For Documentation Purposes)

```plaintext
APT-AUTO-INSTALLS
├── BACKGROUND-IMAGES-VIDEOS
│   ├── BACKGROUND-IMAGE-UBUNTU
│   ├── default
│   ├── desktop-background
│   └── VIDEOS
├── GAMING
│   └── RETROARCH-CORES
├── HARDWARE-FIXES
├── THEMES-N-DOTFILES            # Holds files to customize UI/DE/theme settings, e.g., /etc/skel
├── WARES
│   ├── CUSTOM-WARES-BY-ME
│   │   ├── CUSTOM-AIRGEDDON-FILES  # Not used, just for documentation
│   │   ├── CUSTOM-LINUX-KERNEL     # Currently not used, placeholder
│   │   └── CUSTOM-SH-SCRIPTS       # Used, location of custom Bash scripts
│   ├── MANUAL-INSTALL-WARES
│   │   ├── DEB-FILES               # Holds .deb files to manually install wares to target OS
│   │   │   ├── UBUNTU_VERSION_CHOICE_1
│   │   │   └── UBUNTU_VERSION_CHOICE_2
│   │   ├── HASHCATS
│   │   └── INTEL-OPENCL-NEO
│   └── WARES-INCLUDED              # Documentation folder to be copied to target $HOME
│       ├── BASH-SCRIPTING
│       └── BTRFS
└── WORKER-TEMP

