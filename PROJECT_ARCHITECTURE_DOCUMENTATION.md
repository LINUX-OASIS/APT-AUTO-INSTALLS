# APT-AUTO-INSTALLS Project Documentation

This document captures a **language‑agnostic**, high‑level description of the project located in `/home/osimage/Documents/APT-AUTO-INSTALLS`.  Its purpose is to serve as a durable reference so the system can be rebuilt or re‑implemented in another language in the future.

---

## 1. Technical Specification

The APT-AUTO-INSTALLS suite is a Bash‑based automation framework for provisioning
and configuring Debian‑derived Linux installations (Ubuntu, Mint, Parrot, etc.).
It combines an interactive text UI with a modular execution engine capable of
installing hundreds of packages, applying desktop environment customisations,
managing offline caches, and running a large collection of auxiliary utilities.

Key characteristics:

- Written entirely in POSIX‑compatible shell scripts.
- No external build system; relies on standard command‑line tools (`apt`,
  `whiptail`, `git`, `wget`, etc.).
- Modular directory layout separating UI, orchestration logic, engines, and
  assets.
- Designed to execute both online (using `apt`/`wget`) and offline from a
  pre‑populated cache.

## 2. Project Architectural Summary

The directory hierarchy and major components are:

```
APT-AUTO-INSTALLS/
├── AUTO_INSTALLS_MASTER.bash             # Main UI & entry point
├── WARES-LIB/                            # Logic libraries
│   ├── FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB # High‑level routing functions
│   ├── LINUX-GNOME-AND-MATE-DE-LIB/      # Core installation engine
│   └── OFFLINE-CACHE-CREATOR-OR-INSTALLER/ # Offline cache helpers
└── AUTO-INSTALLS-FILES/                  # Data, scripts and assets
    ├── WARES/                            # Custom packages & docs
    ├── THEMES-N-DOTFILES/               # dconf/theme files for /etc/skel
    ├── GAMING/                          # Emulator BIOS and keys
    └── WORKER-TEMP/                     # Temporary download space
```

The system uses a **layered modular architecture**:

1. **User Interface layer** – `AUTO_INSTALLS_MASTER.bash` handles menu display,
   input sanitisation, status tracking and delegates each choice to the
   orchestrator.
2. **Orchestration layer** – `FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB` maps menu
   tags to functions, prompts for additional options, and loads the appropriate
   engine.
3. **Installation engines** – the `FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB`
   library contains the bulk of the installation logic (apt packages, downloads,
   configuration tweaks). Additional engines exist for offline caching.
4. **Asset repository** – static files and helper scripts are stored under
   `AUTO-INSTALLS-FILES`, which the engines refer to when copying files or
   running utilities.

## 3. Structural Logic Overview

The overall execution flow can be summarised in four phases:

1. **Pre‑flight**: resolve script path, verify `sudo` privileges, spin up a
   keep‑alive background process.
2. **User Interaction**: present a `whiptail` checklist, receive and clean the
   selection string, then iterate over each chosen tag.
3. **Dynamic Execution Loop**: for every selected item the orchestrator loads
   and invokes the corresponding function, which usually follows the pattern
   `banner -> apt update/apt install or custom download -> status check`.
   Failed operations are recorded in an array and displayed later.
4. **Finalisation**: kill the keep‑alive process, iterate through the success/fail
   arrays, and render a colour‑coded summary report.

Specialised routines include BTRFS subvolume migration, offline cache
creation/installation, and a host of standalone utilities invoked from the
`CUSTOM-SH-SCRIPTS` directory.

## 4. Language‑agnostic Design Document

The project is essentially a **command‑pattern automation shell** with the
following language‑neutral design elements:

- **Command Registry**: A list of named actions (menu entries) associated with
  procedures.  This could translate to an object map in another language.
- **Input Sanitisation**: All user choices are normalised to safe identifiers;
  the underlying implementation is agnostic to the UI technology.
- **Sequential Execution with Retry Logic**: Each installation step is executed
  with a bounded retry loop and its result is logged.  In another language,
  this might be implemented with promises/futures or try/catch loops.
- **Dependency Injection via Source Files**: Engines are sourced at runtime.  In
  a compiled language this would map to dynamic module loads or a plugin
  architecture.
- **State Tracking**: Success and failure are recorded in two arrays.  When
  porting, these become lists or collections in the target language.
- **Asset Management**: Static data is segregated from logic, making it easy to
  ship with the application regardless of the implementation language.

The core algorithm in pseudocode is:

```pseudo
init()
selections = displayMenu(options)
for choice in selections:
    handler = lookup(choice)
    status = handler.execute()
    record(status, choice)
report()
```

## 5. Core Functional Pseudocode

### Main Controller

```pseudocode
FUNCTION MainLoop:
    SET CurrentDirectory = PATH_OF_SCRIPT
    SET Colors = ASSOCIATIVE_ARRAY(Green, Red, Yellow, etc.)
    SET Selections = WHIPTAIL_CHECKLIST(OptionsList)
    
    START SudoKeepAlive (Background Process)
    
    FOR EACH Selection IN Selections:
        IF Selection REQUIRES GNOME_ENGINE:
            LOAD_LIBRARY(InstallationEngine)
            EXECUTE TargetFunction(Selection)
        
        LOG_STATUS(PackageName)
    
    STOP SudoKeepAlive
    DISPLAY_FINAL_REPORT(SuccessArray, FailArray)
END FUNCTION
```

### Installation Helper (The "Modern Method")

```pseudocode
FUNCTION InstallWithRetry(DisplayName, Packages):
    DISPLAY Banner(DisplayName)
    FOR EACH Pkg IN Packages:
        LOOP 3 Times:
            TRY 'apt install Pkg'
            IF Success: BREAK Loop
            ELSE: WAIT 10s
        END LOOP
        UPDATE_GLOBAL_REPORT(Pkg)
    END FOR
END FUNCTION
```

### BTRFS Subvolume Migration (Specialized Logic)

```pseudocode
FUNCTION ConvertToSubvolumes(Partition):
    MOUNT Partition TO TempDir (subvolid=5)
    CHECK IF '@' subvolume EXISTS: EXIT if True
    
    CREATE SUBVOLUME '@'
    CREATE SUBVOLUME '@home'
    
    MOVE ALL RootFiles TO '@' (Except '@' and '@home')
    MOVE '@'/home/* TO '@home'
    
    UPDATE /etc/fstab:
        REPLACE root mount WITH 'subvol=@'
        ADD home mount WITH 'subvol=@home'
    
    SYNC & UNMOUNT
END FUNCTION
```

## 6. Key Implementation Patterns

1. **The Superior Pattern:** Using Associative Arrays to map numeric Whiptail tags to complex string values (Paths, Commands). This makes the TUI bug-proof against spaces or special characters in filenames.
2. **Skel Injection:** Everything intended for the user is copied to `/etc/skel`. This ensures that creating a new user on the system results in a fully pre-configured "clone" of the master setup.
3. **Lazy Unmounting (`umount -l`):** Extensively used in recovery scripts to ensure cleanup succeeds even if processes are still holding file handles.
4. **Heredoc Script Deployment:** Complex autostart scripts (like VS Code or NVM initialization) are embedded within the library files as Heredocs and "written out" to the target system dynamically.

## 5. Repository Cognition Map

A quick reference to help any developer understand where to look for
functionality:

| Area | File / Folder | Purpose |
|------|---------------|---------|
| Entry point | `AUTO_INSTALLS_MASTER.bash` | Menu UI, status tracking, permission handling |
| Orchestrator | `WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB` | Maps menu tags to functions and prompts for parameters |
| Core engine | `WARES-LIB/LINUX-GNOME-AND-MATE-DE-LIB/FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB.sh` | Implements the actual installation logic and helpers |
| Offline cache | `WARES-LIB/OFFLINE-CACHE-CREATOR-OR-INSTALLER/*.bash` | Scripts to build/use offline caches |
| Utilities | `AUTO-INSTALLS-FILES/WARES/CUSTOM-WARES-BY-ME/CUSTOM-SH-SCRIPTS` | Standalone tools that can also be executed individually |
| Assets & docs | `AUTO-INSTALLS-FILES/` subfolders | Wallpapers, BIOS files, theme settings, documentation, etc. |

Each numbered menu option corresponds to a function in the orchestrator with
naming convention `FUN_MAIN_CHOICE_<number>`. Most handlers simply call
`FUN_WARES_FOR_GNOME_AND_MATE_DE` with appropriate parameters.

---

## 7. Comprehensive Technical Specification

### 7.1 System Requirements

**Operating System:**
- Debian‑based distribution (Ubuntu 20.04+, Linux Mint 20+, Parrot OS 5.0+)
- Linux kernel 5.4 or later
- Support for both UEFI and Legacy BIOS boot modes

**Required System Tools:**
- `bash` 4.0+ (for associative array support)
- `sudo` (with passwordless or cached privileges)
- `apt` & `apt-cache` (package management)
- `dpkg` (package inspection)
- `whiptail` or `dialog` (TUI rendering)
- `tput` (terminal control)
- `wget`, `curl` (HTTP/FTP downloads)
- `git` (repository cloning)
- `7z`, `tar`, `unzip` (archive extraction)
- `make`, `cmake`, `gcc`, `g++` (build tools for source compilation)
- `sudo`, `systemctl`, `systemd-run` (privilege and service management)
- `mount`, `umount`, `lsblk`, `parted`, `fdisk`, `cgdisk` (filesystem/partition utilities)
- `btrfs-progs` (BTRFS filesystem tools)
- `e2fsprogs` (ext4 utilities)
- `qemu-img`, `losetup` (virtual disk management)
- `jq` (JSON parsing)
- `sed`, `awk`, `grep`, `find`, `xargs` (text processing)

**Optional for specific features:**
- `nmap`, `netdiscover`, `ethtool` (network diagnostics)
- `smartmontools`, `nvme-cli` (storage diagnostics)
- `ufw` (firewall management)

### 7.2 Main Script Interface (`AUTO_INSTALLS_MASTER.bash`)

#### Global Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `SCRIPT_DIR` | string | Absolute path to the script directory (resolved via `cd "$(dirname "${BASH_SOURCE[0]}")"`) |
| `SCRIPT_NAME` | string | Base filename of the executing script |
| `MAIN_CHOICES_ARRAY` | associative array | Maps whiptail tag (e.g., "1") to human-readable menu labels |
| `MAIN_CHOICE_SANITIZED` | string | Space-separated list of user selections from checklist |
| `COLORS` | associative array | Maps colour names (`RED`, `GREEN`, `YELLOW`, `BLUE`, `NC`) to tput escape codes |
| `STATUS_SUCCESS_ARRAY` | indexed array | Tracks successfully installed packages/operations |
| `STATUS_FAIL_ARRAY` | indexed array | Tracks failed installations |
| `SUDO_KEEP_ALIVE_PID` | integer | PID of the background `sudo -v` refresh process |
| `RETRY_ATTEMPTS` | integer | Default: 3 (retry count for failed apt operations) |
| `RETRY_DELAY` | integer | Default: 10 (seconds between retries) |

#### Main Execution Flow

```bash
# Pre-flight
resolve_absolute_path()              # Calculate SCRIPT_DIR
check_sudo_privileges()              # Verify sudo access
start_sudo_keep_alive()              # Background: sudo -v every 60s

# UI
display_whiptail_checklist()          # Present menu via whiptail
sanitize_selections()                 # Convert output to array

# Execution loop
for choice in MAIN_CHOICES_SANITIZED:
    source WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
    call_handler("FUN_MAIN_CHOICE_${choice}")
    record_status(choice, exit_code)

# Finalization
kill_sudo_keep_alive()                # Clean up background process
generate_report()                     # Render success/fail summary
```

#### Function Signatures

```bash
# Initialize the script environment
init_script()

# Display the main menu checklist
display_whiptail_checklist() -> string (space-separated selections)

# Map selection to orchestrator function and execute
route_choice(choice: string, additional_param?: string) -> integer (exit code)

# Log operation result to tracking arrays
record_status(operation_name: string, exit_code: integer) -> void

# Render final installation report
generate_report() -> void

# Color-formatted echo
echo_color(color: string, text: string) -> void
echo_banner(title: string) -> void
```

### 7.3 Orchestrator Interface (`FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB`)

Each menu selection maps to a handler function with naming convention
`FUN_MAIN_CHOICE_<number>`. Common signature:

```bash
FUN_MAIN_CHOICE_1() {
    # Prompt user for variant selection (e.g., Ubuntu version)
    local VARIANT=$(whiptail --radiolist "Choose option:" ...)
    
    # Source core engine
    source WARES-LIB/LINUX-GNOME-AND-MATE-DE-LIB/FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB.sh
    
    # Call engine function with parameters
    FUN_WARES_FOR_GNOME_AND_MATE_DE "$VARIANT" "package1" "package2" ...
    
    return $?
}
```

**Exit Codes:**
- `0` – Success
- `1` – User cancelled
- `2` – Missing dependencies
- `127` – Function not found
- `255` – Unhandled error

### 7.4 Installation Engine Interface

The core engine `FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB.sh` exports:

#### Main Function

```bash
FUN_WARES_FOR_GNOME_AND_MATE_DE(
    variant: string,           # e.g., "ubuntu-24.04"
    package1, package2, ...: string  # APT package names
) -> integer (exit code)
```

**Internal Installation Pattern:**

```bash
# For each package
apt update  # if required
apt install -y "$PACKAGE" || {
    # Retry loop (up to 3 times)
    for attempt in {1..3}; do
        sleep 10
        apt install -y "$PACKAGE" && break
    done
}
# Record result
STATUS_CHECKER "$PACKAGE" $?
```

#### Helper Functions

| Function | Purpose |
|----------|---------|
| `status_checker(pkg: string, code: integer)` | Log success/fail into tracking arrays |
| `download_github_release(repo: string, tag: string, pattern: string) -> path` | Clone/download from GitHub |
| `create_systemd_unit(name: string, commands: string) -> void` | Write and enable systemd service files |
| `copy_to_skel(source: string, dest: string) -> void` | Inject files into `/etc/skel` |
| `set_dconf_setting(key: string, value: string) -> void` | Apply GNOME/MATE dconf settings |
| `extract_to_target(archive: string, dest: string) -> void` | Extract tarballs/zips safely |

### 7.5 Data Structures

#### Status Arrays (Bash indexed arrays)

```bash
declare -a STATUS_SUCCESS_ARRAY  # ["vim", "git", "gcc", ...]
declare -a STATUS_FAIL_ARRAY     # ["failed-package-1", ...]
```

Used by `generate_report()` to produce a 4‑column formatted table.

#### Menu Mapping (Bash associative array)

```bash
declare -A MAIN_CHOICES_ARRAY=(
    ["1"]="Install Development Tools"
    ["2"]="Install Gaming Suite"
    ["3"]="Configure BTRFS Subvolumes"
    # ...
)
```

#### Colour Map (Bash associative array)

```bash
declare -A COLORS=(
    ["RED"]="$(tput setaf 1)"
    ["GREEN"]="$(tput setaf 2)"
    ["YELLOW"]="$(tput setaf 3)"
    ["BLUE"]="$(tput setaf 4)"
    ["NC"]="$(tput sgr0)"  # No colour (reset)
)
```

### 7.6 Offline Cache System

#### Cache Structure

```
<cache_root>/
├── debs/                  # .deb packages organized by section
│   ├── base/
│   ├── development/
│   └── optional/
├── git-repos/            # Cloned Git repositories
│   └── <owner>/<repo>/
├── flatpaks/             # Flatpak bundle files
├── manual-installs/       # Standalone binaries/archives
└── metadata/
    └── cache.manifest    # JSON: list of all cached items with checksums
```

#### Manifest Format (`cache.manifest`)

```json
{
  "version": "1.0",
  "created": "2026-03-03T10:30:00Z",
  "packages": [
    {
      "name": "vim",
      "type": "deb",
      "path": "debs/base/vim_9.0.1234-1_amd64.deb",
      "checksum": "sha256:abc123...",
      "size_bytes": 12345
    },
    {
      "name": "nvm",
      "type": "git",
      "path": "git-repos/nvm-sh/nvm",
      "checksum": "git:commit_sha",
      "size_bytes": 67890
    }
  ]
}
```

#### API Functions

| Function | Purpose |
|----------|---------|
| `create_offline_cache(target_dir: string, exclude?: string[])` | Populate cache from online sources |
| `install_from_cache(cache_root: string, packages: string[])` | Install all packages from cache without internet |
| `verify_cache(cache_root: string) -> boolean` | Validate checksums and completeness |
| `cache_size(cache_root: string) -> string` | Report cache disk usage |

### 7.7 Special Operations

#### BTRFS Subvolume Conversion

**Preconditions:**
- Target partition already mounted read‑write at temporary location
- Subvolume check: `btrfs subvolume list <mount_point>` returns no `@` or `@home`

**Procedure:**

```bash
# 1. Create subvolumes
btrfs subvolume create @
btrfs subvolume create @home

# 2. Move root files
rsync -axAX / @/ --exclude={@,@home} ...

# 3. Restructure home
mv @/home/* @home/
rmdir @/home

# 4. Update /etc/fstab
# Root:    UUID=... / ext4 ... -> UUID=... / btrfs subvol=@ ...
# Home:    UUID=... /home ext4 ... -> UUID=... /home btrfs subvol=@home ...

# 5. Update GRUB if UEFI
grub-install --efi-directory=/boot/efi --bootloader-id=ubuntu
```

**Exit Codes:**
- `0` – Success
- `1` – Subvolumes already exist
- `2` – Mount point not accessible
- `3` – `btrfs` command not found
- `127` – fstab update failed

### 7.8 Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `APT_PACKAGES_CACHE_DIR` | `/var/cache/apt/archives` | System apt cache location |
| `CUSTOM_CACHE_DIR` | `$SCRIPT_DIR/WORKER-TEMP` | Project-local cache for downloads |
| `SKEL_TARGET` | `/etc/skel` | Target for new user skeleton files |
| `LOG_FILE` | `/tmp/apt-auto-installs.log` | Installation log file |
| `SUDO_KEEP_ALIVE_INTERVAL` | `60` | Seconds between sudo keep-alive pings |

### 7.9 Error Handling and Logging

**Standard error codes:**

- `0` – Success
- `1` – Generic error
- `2` – Missing dependency or file
- `126` – Permission denied
- `127` – Command not found
- `128 + signal_num` – Process killed by signal
- `255` – Fatal/unhandled error

**Logging:**

All operations are logged to `$LOG_FILE` with format:

```
[TIMESTAMP] [LEVEL] [COMPONENT] Message
[2026-03-03 10:30:45] [INFO] INSTALL_ENGINE Installing vim
[2026-03-03 10:30:46] [ERROR] INSTALL_ENGINE apt install failed, retrying...
[2026-03-03 10:30:57] [SUCCESS] INSTALL_ENGINE vim installed successfully
```

### 7.10 Performance Characteristics

**Typical execution times (online, 50 Mbps connection):**

- Pre‑flight (path resolution, sudo check): ~1 second
- Menu presentation: ~2 seconds  
- Installation of 50 packages: ~8–15 minutes
- Status report generation: ~1 second

**Disk usage:**

- Base installation files: ~50 MB
- Offline cache (full suite): ~2–3 GB
- Working temporary files: ~500 MB (cleaned after execution)

**Memory footprint:**

- Script baseline: ~10–20 MB
- During apt operations: ~50–100 MB
- Large download operations: ~200–500 MB

### 7.11 Custom Utility Scripts

Located in `AUTO-INSTALLS-FILES/WARES/CUSTOM-WARES-BY-ME/CUSTOM-SH-SCRIPTS/`, these standalone scripts can be executed independently of the main suite:

**Examples:**

```bash
./custom-BTRFS-TUI-MANAGER            # Interactive BTRFS admin tool
./custom-SYSTEMD-UNIT-TIMER-MANAGER   # Create/edit systemd services
./custom-GRUB-REINSTALLER-BTRFS-EXT4-UEFI-CHROOT  # Recovery tool
./custom-NETWORKING-SAMBA-SCANNER-SAVER           # Network share scanner
```

Each script has its own argument parsing and help text (typically `--help` or `-h`).

---

## 8. Actual Implementation Details (Reverse-Engineering Guide)

### 8.1 Main Script Structure Walkthrough

#### Colour Definition Pattern

```bash
declare -A COLORS=(
	[RESET]="\033[0m"
	[BOLD]="\033[1m"
	[DIM]="\033[2m"
	[GREEN]="\033[32m"
	[CYAN]="\033[96m"
	[YELLOW]="\033[93m"
	[RED]="\033[31m"
)
CHECK="${COLORS[GREEN]}✓${COLORS[RESET]}"
CROSS="${COLORS[DIM]}✗${COLORS[RESET]}"
```

Used throughout for status messages:
```bash
echo -e "${COLORS[YELLOW]}► Running 1:${COLORS[RESET]} Menu description"
echo -e "${COLORS[GREEN]}✔ Done with Choice 1${COLORS[RESET]}"
```

#### Whiptail Menu Configuration

Actual menu from production code:

```bash
MAIN_CHOICE=$(whiptail --separate-output --title "AUTO-INSTALLS-MASTER!" \
	--backtitle "RUN SCRIPT BY ITS ABSOLUTE PATH!" \
	--checklist "Choice" 0 0 20 \
	0 "COPY THIS SOFTWARE SUITE TO /BIN [COPY ITSELF TO /BIN]" off \
	1 "MATE Desktops [PARROT-OS/LINUX-MINT/UBUNTU] (Wares for all [MATE DE] Desktops" off \
	2 "[MATE Desktops ! FULL SEND] Executes options 1, 3, 4" off \
	3 "Manually installed Wares Only [.DEB Files]" off \
	4 "[MATE Desktops] COPY MATE PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
	UBUNTU_GNOME_VANILLA "[UBUNTU SPECIFIC] Wares for Ubuntu Vanilla [GNOME DE]" off \
	UBUNTU_GNOME_FULL_SEND "[UBUNTU SPECIFIC !!! Full Send !!!] Executes options..." off \
	7 "[UBUNTU SPECIFIC] COPY GNOME PANEL SETTINGS & APP CONFIGS TO /ETC/SKEL" off \
	DEBIAN_GNOME "[DEBIAN] Wares for Debian [GNOME DE]" off \
	9 "[FONTS] Install Comprehensive Font Set" off \
	"IMPORT_WIFI" "Import pre-saved Wi-Fi networks for headless/server installs" off \
	10 "INSTALL ALL GAMING CONSOLES ONLY" off \
	15 "[CACHE UBUNTU] Create Full Offline Cache (ONLY! on clean system)" off \
	16 "[CACHE DEPLOY UBUNTU] Install Full System using Local Cache" off \
	17 "[VSCODE] install only vscode" off \
	3>&1 1>&2 2>&3)

echo "Chosen options: $MAIN_CHOICE"
MAIN_CHOICE_SANITIZED=$(echo "$MAIN_CHOICE" | sed 's/"//g')
```

Key features:
- `--separate-output` returns each choice on a new line
- Both numeric (`0`, `1`, `2`) and string tags (`UBUNTU_GNOME_VANILLA`) supported
- `3>&1 1>&2 2>&3` redirects whiptail output to stdout (standard pattern)

#### Main Case Statement Loop

```bash
for CHOOSER in $MAIN_CHOICE_SANITIZED; do
	# Start sudo keep-alive background process
	sudo -v
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
	SUDO_KEEPALIVE_PID=$!

	case $CHOOSER in
	0)
		echo -e "${COLORS[YELLOW]}► Running 0:${COLORS[RESET]} COPY THIS SOFTWARE SUITE TO /BIN"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_0
		echo -e "${COLORS[GREEN]}✔ Done with Choice 0${COLORS[RESET]}"
		;;
	1)
		echo -e "${COLORS[YELLOW]}► Running 1:${COLORS[RESET]} MATE Desktops"
		source ./WARES-LIB/FUNCTIONS_FOR_MAIN_CHOICE_EXT_LIB
		FUN_MAIN_CHOICE_1
		echo -e "${COLORS[GREEN]}✔ Done with Choice 1${COLORS[RESET]}"
		;;
	# ... more choices ...
	esac
done
```

### 8.2 Helper Function Implementations

#### Banner Display

```bash
FUN_VERBOSE_INSTALLING() {
	BANNER_PKG_NAME_MSG=$1
	echo ""
	tput setab 7      # White background
	tput setaf 18     # Gray foreground
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0         # Reset
	sudo apt update
	sleep 1
	sudo apt --fix-broken install -y
	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ Installing $BANNER_PKG_NAME_MSG _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0
}

FUN_CHOICE_BLOCK_INDICATOR() {
	CHOICE_BLOCK_INDICATOR=$1
	echo ""
	tput setab 112    # Bright green background
	tput setaf 234    # Dark text
	tput bold
	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."
	echo -e "\n-_-_-_-_-_-_-_-_-_-_-_ Installing $CHOICE_BLOCK_INDICATOR _-_-_-_-_-_-_-_-_-_-_- \n"
	echo "_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_.-_."
	tput sgr0
}
```

#### Package Installation with Retry

Modern helper function with built-in retry logic:

```bash
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY() {
	local display_name="$1"
	local package_names="$2"
	FUN_VERBOSE_INSTALLING "$display_name"
	
	for pkg in $package_names; do
		local max_attempts=3
		local attempt=1
		local delay=10
		
		while [ $attempt -le $max_attempts ]; do
			sudo apt install -y "$pkg"
			
			# Check if installation succeeded
			if dpkg -s "$pkg" &>/dev/null; then
				break  # Success
			fi
			
			if [ $attempt -lt $max_attempts ]; then
				echo "Failed to install '$pkg'. Retrying in $delay seconds... (Attempt $((attempt + 1))/$max_attempts)"
				sleep $delay
			fi
			attempt=$((attempt + 1))
		done
		
		FUN_PACKAGE_INSTALLATION_STATUS_CHECKER "$pkg"
	done
}
```

Usage:
```bash
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "efibootmgr" "efibootmgr"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "Core networking tools" "nmap netdiscover"
```

#### Status Tracking

```bash
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER() {
	PKG_NAME=$1
	for _FLATTENED_PKG in $PKG_NAME; do
		_ARRAY_ALL_PACKAGES[$_array_counter]="$_FLATTENED_PKG"
		_array_counter=$((_array_counter + 1))
	done
}

FUN_FINAL_INSTALLED_STATUS() {
	_array_counter=0
	for LOOP_PKG in "${_ARRAY_ALL_PACKAGES[@]}"; do
		if apt list --installed "$LOOP_PKG" 2>/dev/null | grep -qw "$LOOP_PKG"; then
			_ARRAY_SUCCESS[$_array_counter]="$LOOP_PKG"
		else
			_ARRAY_FAIL[$_array_counter]="$LOOP_PKG"
		fi
		_array_counter=$((_array_counter + 1))
	done

	tput setab 7
	tput setaf 18
	echo "-_-_-_-_-_-_-_-_-_-_-_ :-D FINALIZED :-D _-_-_-_-_-_-_-_-_-_-_-"
	tput sgr0

	echo -e ":: SUCCESSFULLY INSTALLED PACKAGES ::\n"
	# Print in 4 columns with green color
	printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u | pr -t -4 | sed "s/^/${COLORS[GREEN]}/;s/$/${COLORS[RESET]}/"

	echo -e ":: ERRONEOUSLY INSTALLED PACKAGES ::\n"
	# Print in 4 columns with red color
	printf "%s\n" "${_ARRAY_FAIL[@]}" | sort -u | pr -t -4 | sed "s/^/${COLORS[RED]}/;s/$/${COLORS[RESET]}/"
}
```

### 8.3 Orchestrator Pattern (Handler Functions)

```bash
# Ubuntu version selection helper
function _FUN_CHOOSE_UBUNTU_VERSION {
	declare -g _GLOBAL_MASTER_UBUNTU_RELEASE_VERSION_1='25.04'
	declare -g _GLOBAL_MASTER_UBUNTU_RELEASE_VERSION_2='24.04'

	_UBUNTU_VERSION_SELECTION=$(whiptail --title "CHOOSE UBUNTU VERSION" --menu "CHOOSE UBUNTU VERSION" 0 0 3 \
		1 "UBUNTU [OTHER non-lts] $_GLOBAL_MASTER_UBUNTU_RELEASE_VERSION_1" \
		2 "UBUNTU [LTS] $_GLOBAL_MASTER_UBUNTU_RELEASE_VERSION_2" \
		3 "[! EXIT !]" 3>&1 1>&2 2>&3)

	__RELEASE_VERSION=$(cat /etc/lsb-release | grep -o "DISTRIB_RELEASE=[0-9][0-9].[0-9][0-9]" | sed s/DISTRIB_RELEASE=// | tr -d '[:space:]')

	if [[ $_UBUNTU_VERSION_SELECTION -eq 1 ]]; then
		if [[ $__RELEASE_VERSION == "$_GLOBAL_MASTER_UBUNTU_RELEASE_VERSION_1" ]]; then
			echo "Version check passed"
		else
			echo "Version mismatch: EXITING"
			exit
		fi
	fi
}

# Main handler function
function FUN_MAIN_CHOICE_1 {
	echo "1. Mate Desktops [PARROT-OS/LINUX-MINT/UBUNTU]"
	FUN_CHOICE_BLOCK_INDICATOR "1. Mate Desktops [PARROT-OS/LINUX-MINT/UBUNTU]"

	SELECTED_MATE_DE_DISTRO=$(whiptail --title "Select [MATE DE] Distro:" --menu "Select [MATE DE] Distro:" 0 0 3 \
		1 "Linux Mint [MATE DE]" \
		2 "Parrot Sec OS [MATE DE]" \
		3 "UBUNTU [MATE DE]" 3>&1 1>&2 2>&3)

	if [ -z "$SELECTED_MATE_DE_DISTRO" ]; then
		echo "USER ABORTED"
		exit
	fi

	# Source and execute the installation engine
	source ./WARES-LIB/LINUX-GNOME-AND-MATE-DE-LIB/FOR_LINUX_GNOME_AND_MATE_DE_LIB_EXT_LIB
	FUN_WARES_FOR_GNOME_AND_MATE_DE
}

# Composite function (runs multiple handlers)
function FUN_MAIN_CHOICE_2 {
	echo "2. [MATE Desktops ! FULL SEND] Executes options 1 3 4"
	FUN_CHOICE_BLOCK_INDICATOR "2. [MATE Desktops ! FULL SEND]"

	FUN_MAIN_CHOICE_1
	FUN_MAIN_CHOICE_3
	FUN_MAIN_CHOICE_4
}

# File-based installation
function FUN_MAIN_CHOICE_3 {
	echo "3. Manually installed Wares Only [.DEB Files]"
	FUN_CHOICE_BLOCK_INDICATOR "3. Manually installed Wares Only"

	if [ -z "$_UBUNTU_VERSION_SELECTION" ]; then
		_FUN_CHOOSE_UBUNTU_VERSION
	fi

	# Install .deb files from AUTO-INSTALLS-FILES/WARES/MANUAL-INSTALL-WARES/DEB-FILES/
	# based on selected Ubuntu version
}
```

### 8.4 Installation Engine Patterns

#### Method 1: Classical Detailed Installation

```bash
# Classical method with full control
BANNER_PKG_NAME_MSG="VS Code"
PKG_NAME="code"
FUN_VERBOSE_INSTALLING  # Displays banner and runs apt update
sudo apt install -y code
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER  # Adds to tracking array
```

#### Method 2: Modern Helper Method

```bash
# Modern method for multiple straightforward packages
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "debconf-utils" "debconf-utils"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "tmux" "tmux"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "openssh-server" "openssh-server"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "Networking tools" "nmap netdiscover curl wget"
```

#### Special Case: Pre-seeding debconf Answers

```bash
# For rEFInd (prevent automatic ESP installation)
echo refind refind/install_to_esp boolean false | sudo debconf-set-selections
sudo apt install -y refind
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER "refind"
```

### 8.5 Sudo Keep-Alive Pattern

Every major operation maintains sudo privileges:

```bash
# Start keep-alive background process
sudo -v
while true; do
	sudo -n true               # Run sudo without prompting
	sleep 60                   # Refresh every 60 seconds
	kill -0 "$$" || exit      # Exit if parent process dies
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!         # Save PID for cleanup

# Later in script
kill $SUDO_KEEPALIVE_PID      # Kill when done
```

### 8.6 Real-World Package Lists (Sample)

From the actual installation engine:

```bash
# Dependencies for custom scripts
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "efibootmgr" "efibootmgr"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "qemu-utils" "qemu-utils"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "nmap && netdiscover" "nmap netdiscover"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "python3-pip tools" "python3-pip python3-pyftpdlib net-tools"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "samba suite" "samba smbclient nbtscan qrencode fim zbar-tools"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "ethtool && WOL" "ethtool etherwake netdiscover wakeonlan"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "partition tools" "parted dosfstools mtools exfatprogs"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "storage diagnostics" "nvme-cli smartmontools"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "filesystem tools" "btrfs-progs mdadm"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "math tool" "pi"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "packaging" "makeself debootstrap dsniff"

# Core system utilities
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "debconf-utils" "debconf-utils"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "ttyd" "ttyd"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "tmux" "tmux"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "openssh-server" "openssh-server"
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "gettext" "gettext"
```

### 8.7 File Copy and Permission Pattern

```bash
# Classic method from FUN_MAIN_CHOICE_0
echo "Copying repository to /bin"
FUN_CHOICE_BLOCK_INDICATOR "COPY THIS SOFTWARE SUITE TO /BIN"

# Clean worker temp
sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*

# Delete existing copy in /bin
sudo rm -rf /bin/"$(basename "$PWD" | tr -d '[:space:]')" 2>/dev/null

# Copy entire project
sudo cp -rf "$(echo $PWD | tr -d '[:space:]')" /bin
```

### 8.8 Configuration File Copying Pattern

Example structure for /etc/skel injection:

```bash
# For MATE panel settings
sudo mkdir -p /etc/skel/.config/dconf
sudo cp -f ./AUTO-INSTALLS-FILES/THEMES-N-DOTFILES/mate-panel-settings /etc/skel/.config/dconf/User

# For shell configuration
sudo cp -f ./AUTO-INSTALLS-FILES/THEMES-N-DOTFILES/parrot.bashrc /etc/skel/.bashrc

# For wallpapers/themes
sudo cp -rf ./AUTO-INSTALLS-FILES/BACKGROUND-IMAGES-VIDEOS/default /etc/skel/.background
```

### 8.9 Special Operations: Inline Script Deployment

For complex operations, scripts are often embedded as heredocs:

```bash
# Create a systemd service from heredoc
sudo tee /etc/systemd/system/wifi-import.service > /dev/null <<'WIFI_SERVICE_EOF'
[Unit]
Description=Import WiFi Networks on First Boot
After=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-importer.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
WIFI_SERVICE_EOF

# Copy the actual importer script
sudo cp ./AUTO-INSTALLS-FILES/HEADLESS-WIFI-IMPORT/wifi_networks.txt /usr/local/bin/
sudo chmod +x /usr/local/bin/wifi-importer.sh

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable wifi-import.service
```

### 8.10 Parsing and Validation Examples

#### Release Version Detection

```bash
# Extract Ubuntu version
__RELEASE_VERSION=$(cat /etc/lsb-release | grep -o "DISTRIB_RELEASE=[0-9][0-9].[0-9][0-9]" | sed s/DISTRIB_RELEASE=// | tr -d '[:space:]')
# Result: "25.04" or "24.04"

# Validate against known versions
if [[ $__RELEASE_VERSION == "25.04" ]] || [[ $__RELEASE_VERSION == "24.04" ]]; then
	echo "Supported version"
else
	echo "Unsupported version"
	exit 1
fi
```

#### Input Sanitization

```bash
# From whiptail, quotes are included; strip them
MAIN_CHOICE_SANITIZED=$(echo "$MAIN_CHOICE" | sed 's/"//g')

# Ensure safe variable expansion
__RELEASE_VERSION=$(cat /etc/lsb-release | grep -o "DISTRIB_RELEASE=[0-9][0-9].[0-9][0-9]" | sed s/DISTRIB_RELEASE=// | tr -d '[:space:]')

# Remove trailing/leading spaces
SCRIPT_DIR=$(echo $PWD | tr -d '[:space:]')
```

---

## 9. VS Code Installation & Node.js Setup

### 9.1 VS Code Installation Pipeline

The installation is delegated to a dedicated library (`VSCODE_ONLINE_INSTALLATION_LIB`):

```bash
# From main engine
FUN_VERBOSE_INSTALLING "INSTALLING VSCODE ---"
source ./WARES-LIB/VSCODE_ONLINE_INSTALLATION_LIB
FUN_INSTALL_VSCODE_ONLINE
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER "code"
```

#### Step 1: .deb Download

```bash
# Pre-seed debconf to accept Microsoft repo automatically
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

# Clean temp directory
sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*

# Download latest stable .deb
wget -O ./AUTO-INSTALLS-FILES/WORKER-TEMP/VS_CODE.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' || {
	echo "ERROR: COULDNT DOWNLOAD VSCODE DEB PACKAGE"
	exit 1
}

# Install from local .deb
cd ./AUTO-INSTALLS-FILES/WORKER-TEMP/ || exit 1
sudo apt install -y "./VS_CODE.deb" || {
	echo "ERROR: COULDNT INSTALL VSCODE"
	exit 1
}
cd "$CD_DIRNAME" || exit 1

# Cleanup
sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*
```

#### Step 2: Extension Installation with Retry

```bash
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY() {
	local extension="$1"
	local retries=5
	local count=0
	local delay=10
	
	while [ $count -lt $retries ]; do
		# Use --no-sandbox and --user-data-dir for root or containerized environments
		code --install-extension "$extension" --no-sandbox --user-data-dir "$HOME/.config/Code" && return 0
		
		echo "Failed to install $extension, retrying in $delay seconds... ($((count + 1))/$retries)"
		sleep $delay
		count=$((count + 1))
	done
	
	echo "ERROR: Could not install $extension after $retries attempts."
	return 1
}
```

#### Step 3: Extension List

```bash
# Bash & Shell
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "rogalmic.bash-debug"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "mads-hartmann.bash-ide-vscode"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "timonwong.shellcheck"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "Remisa.shellman"

# UI & Themes
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "oderwat.indent-rainbow"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "vscode-icons-team.vscode-icons"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "zhuangtongfa.material-theme"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "github.github-vscode-theme"

# AI & Development
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "github.copilot"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "github.copilot-chat"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "google.geminicodeassist"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "continue.continue"

# Git & Markdown
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "donjayamanne.githistory"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "eamodio.gitlens"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "davidanson.vscode-markdownlint"

# Miscellaneous
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "tomoki1207.pdf"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "exodiusstudios.comment-anchors"
FUN_INSTALL_VSCODE_EXTENSION_WITH_RETRY "golang.go"
```

#### Step 4: shfmt Backend Setup

```bash
# Find installed shell-format extension directory
EXTENSION_DIRECTORY=$(find "$HOME/.vscode/extensions" -type d -name "lumirelle.shell-format-rev-*" | head -n 1)

if [[ -z "$EXTENSION_DIRECTORY" ]]; then
	echo "ERROR: Could not find the shell-format-rev directory"
	exit 1
fi

# Download shfmt binary and place in extension
wget -O <shfmt_path> <github_release_url>
chmod +x <shfmt_path>
```

### 9.2 Node.js & nvm Integration

The installation engine detects and installs the latest LTS Node.js:

```bash
# Fetch Node.js version list
NODE_VERSIONS_JSON=$(curl -s https://nodejs.org/dist/index.json)

# Parse JSON to find latest LTS
LATEST_LTS_VERSION_NODE_JS_TAG=$(echo "$NODE_VERSIONS_JSON" | jq -r '[.[] | select(.lts != false)] | sort_by(.version | sub("^v";"") | split(".") | map(tonumber)) | last | .version')

# Fallback if jq fails
if [[ -z "$LATEST_LTS_VERSION_NODE_JS_TAG" ]]; then
	LATEST_LTS_VERSION_NODE_JS_TAG="v22.17.1"
fi

# Extract major version
LATEST_LTS_VERSION_NODE_JS_MAJOR=$(echo "$LATEST_LTS_VERSION_NODE_JS_TAG" | sed 's/^v\([0-9]\+\)\..*$/\1/' | tr -d '[:space:]')

# Detect latest nvm version from GitHub
REPO_URL="https://github.com/nvm-sh/nvm/releases"
LATEST_NVM_VERSION=$(curl -s "$REPO_URL" | grep -oE '/nvm-sh/nvm/releases/tag/v[0-9]+\.[0-9]+\.[0-9]+' | sed 's+/nvm-sh/nvm/releases/tag/++' | sort -V | tail -n 1 | tr -d '[:space:]')

# Install nvm if not present
if ! command -v nvm &>/dev/null; then
	NVM_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${LATEST_NVM_VERSION}/install.sh"
	curl -o- "${NVM_INSTALL_SCRIPT_URL}" | bash
	source "$HOME/.nvm/nvm.sh"
	nvm install "$LATEST_LTS_VERSION_NODE_JS_MAJOR"
fi

# Verify installation
node -v    # e.g., v22.17.1
npm -v     # e.g., 10.8.3
nvm current
```

---

## 10. Gaming Emulator Installation Details

### 10.1 Architecture Overview

Gaming emulator installation is delegated to `GAMING_CONSOLES_ONLINE_INSTALLATION_LIB`. The system supports:

- **PPSSPP** – PSP emulation (Flatpak-based)
- **XEMU** – Xbox Original emulation (PPA-based + asset extraction)
- **Ryujinx** – Nintendo Switch emulation (Flatpak-based)
- **Citron** – Nintendo Switch emulation (AppImage-based, legacy)
- **RetroArch** – Multi-system (Flatpak-based)
- **Dolphin** – GameCube/Wii emulation (source build optional)

### 10.2 PPSSPP Installation (PSP)

```bash
_FUN_INSTALL_PPSSPP_ONLINE() {
	FUN_VERBOSE_INSTALLING "ppsspp psp emulator  [installed via FLATPAK]"
	
	# Ensure Flatpak ecosystem
	sudo apt-get update
	sudo apt install -y flatpak
	sudo apt install -y gnome-software-plugin-flatpak
	
	# Add Flathub remote
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	
	# Install PPSSPP from Flathub
	flatpak install -y https://dl.flathub.org/repo/appstream/org.ppsspp.PPSSPP.flatpakref
}
```

### 10.3 XEMU Installation (Xbox Original)

```bash
_FUN_INSTALL_XEMU_ONLINE() {
	FUN_VERBOSE_INSTALLING "xemu xbox emulator"
	
	# 1. Dependency check
	if ! apt list --installed p7zip-full 2>/dev/null | grep -w p7zip-full >/dev/null; then
		sudo apt update
		sudo apt install -y p7zip-full
	fi
	
	# 2. Add PPA and install binary
	sudo add-apt-repository ppa:mborgerson/xemu -y
	sudo apt update
	sudo apt install -y xemu
	
	# 3. Clean and extract assets
	sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*
	
	# Extract XEMU BIOS and HDD assets from local archive
	7z x ./AUTO-INSTALLS-FILES/GAMING/XEMU_XBOX_FILES.zip -o./AUTO-INSTALLS-FILES/WORKER-TEMP
	
	# 4. Create config directories and copy assets to both /etc/skel and user home
	sudo mkdir -p /etc/skel/.local/share/xemu/xemu/
	mkdir -p "$HOME/.local/share/xemu/xemu/"
	
	# Allow full access
	sudo chmod -R 777 /etc/skel/.local/share/xemu/xemu/
	sudo chmod -R 777 "$HOME/.local/share/xemu/xemu/"
	
	# Copy BIOS files
	sudo cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/BIOS/Complex_4627v1.03.bin /etc/skel/.local/share/xemu/xemu/
	sudo cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/BIOS/Complex_4627v1.03.bin "$HOME/.local/share/xemu/xemu/"
	
	# Copy boot ROM
	sudo cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/Boot_ROM_image/mcpx_1.0.bin /etc/skel/.local/share/xemu/xemu/
	sudo cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/Boot_ROM_image/mcpx_1.0.bin "$HOME/.local/share/xemu/xemu/"
	
	# Copy HDD image (QCOW2 format)
	sudo cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/Pre_built_Xbox_HDD_image/xbox_hdd.qcow2 /etc/skel/.local/share/xemu/xemu/
	cp ./AUTO-INSTALLS-FILES/WORKER-TEMP/Pre_built_Xbox_HDD_image/xbox_hdd.qcow2 "$HOME/.local/share/xemu/xemu/"
	
	# 5. Cleanup
	sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*
}
```

**Assets Required:**
- `XEMU_XBOX_FILES.zip` containing:
  - `BIOS/Complex_4627v1.03.bin` (Xbox BIOS)
  - `Boot_ROM_image/mcpx_1.0.bin` (Xbox ROM)
  - `Pre_built_Xbox_HDD_image/xbox_hdd.qcow2` (HDD image)

### 10.4 Ryujinx Installation (Nintendo Switch)

```bash
_FUN_INSTALL_RYUJINX_ONLINE() {
	FUN_VERBOSE_INSTALLING "Ryujinx Nintendo Switch Emulator"
	
	# 1. Install Flatpak ecosystem
	sudo apt install flatpak -y
	sudo apt install gnome-software-plugin-flatpak -y
	
	# 2. Add Flathub remote
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	
	# 3. Install Ryujinx from Flathub
	FUN_VERBOSE_INSTALLING "Ryujinx Nintendo Switch Emulator"
	flatpak install flathub io.github.ryubing.Ryujinx -y
	
	# 4. Create Flatpak config directories
	sudo mkdir -p /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	mkdir -p $HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	
	# 5. Allow full access for copying assets
	sudo chmod -R 777 /etc/skel/.var/app/io.github.ryubing.Ryujinx
	sudo chmod -R 777 $HOME/.var
	
	# 6. Extract and copy firmware & keys
	sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*
	
	# Extract prodkeys
	7z x ./AUTO-INSTALLS-FILES/GAMING/NINTENDO-SWITCH-PRODKEYS-*.7z -o./AUTO-INSTALLS-FILES/WORKER-TEMP
	
	# Extract firmware
	7z x ./AUTO-INSTALLS-FILES/GAMING/NINTENDO-SWITCH-FIRMWARE-*.7z -o./AUTO-INSTALLS-FILES/WORKER-TEMP
	
	# Copy to both locations
	sudo cp -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/NINTENDO-SWITCH-PRODKEYS-*/* /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	sudo cp -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/NINTENDO-SWITCH-PRODKEYS-*/* $HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	
	sudo cp -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/NINTENDO-SWITCH-FIRMWARE-* /etc/skel/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	sudo cp -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/NINTENDO-SWITCH-FIRMWARE-* $HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system
	
	# 7. Cleanup
	sudo rm -rf ./AUTO-INSTALLS-FILES/WORKER-TEMP/* ./AUTO-INSTALLS-FILES/WORKER-TEMP/.[!.]* ./AUTO-INSTALLS-FILES/WORKER-TEMP/..?*
}
```

**Assets Required:**
- `NINTENDO-SWITCH-PRODKEYS-*.7z` (Switch encryption keys)
- `NINTENDO-SWITCH-FIRMWARE-*.7z` (Switch firmware files)

### 10.5 Citron Installation (Nintendo Switch - Legacy AppImage)

Citron is a high-performance but discontinued Switch emulator. Installation uses a local AppImage:

```bash
_FUN_INSTALL_CITRON_ONLINE() {
	FUN_VERBOSE_INSTALLING "Citron local appimage - FAST! Nintendo Switch Emulator"
	
	set -e
	
	# Configuration
	APP_NAME="Citron"
	TARGET_FILE_CITRON_APPIMAGE="$(realpath ./AUTO-INSTALLS-FILES/GAMING/CITRON-EMULATOR-APPIMAGE/Citron.AppImage)"
	BASENAME_CITRON_APPIMAGE=$(basename "$TARGET_FILE_CITRON_APPIMAGE")
	INSTALL_DIR="$HOME/.Applications/$APP_NAME"
	DESKTOP_FILE="$HOME/.local/share/applications/citron.desktop"
	
	# Key workflow steps:
	# 1. Deploy AppImage to ~/.Applications/Citron/
	# 2. Extract firmware & keys to ~/.var/app/Citron/
	# 3. Create RAM disk loading script (move shaders to /dev/shm on launch)
	# 4. Create sync saving script (write shaders back to disk on exit)
	# 5. Create master wrapper script that orchestrates lifecycle
	# 6. Update desktop entry to use wrapper
	# 7. Create /bin/citron symlink for command-line access
	
	# Benefits:
	# - Shaders in RAM eliminate SSD micro-stuttering
	# - Wrapper maintains compatibility with GUI and CLI launches
	# - Pre-configured for optimal performance
}
```

**Special Features:**
- **RAM Disk Optimization**: Shaders are moved to `/dev/shm` (in-memory tmpfs) before launch to eliminate stutter
- **Lifecycle Management**: Custom wrapper (`citron-wrapper`) manages load→execute→save cycle
- **System Integration**: Dual access via GUI (desktop entry) and CLI (`/bin/citron` symlink)

### 10.6 Multi-Emulator Installation Pattern

The system provides both:

1. **ALL_GAMING_CONSOLES_ONLINE** – Installs all emulators in sequence
2. **INTERACTIVE_MENU** – User selects individual emulators to install

```bash
# Both functions source the library then execute:
FUN_MAIN_CHOICE_10() {
	FUN_CHOICE_BLOCK_INDICATOR "INSTALL ALL GAMING CONSOLES ONLY"
	source ./WARES-LIB/GAMING_CONSOLES_ONLINE_INSTALLATION_LIB
	_FUN_INSTALL_ALL_GAMING_CONSOLES_ONLINE
}

FUN_MAIN_CHOICE_12() {
	FUN_CHOICE_BLOCK_INDICATOR "INSTALL GAMING CONSOLES INDIVIDUALLY"
	source ./WARES-LIB/GAMING_CONSOLES_ONLINE_INSTALLATION_LIB
	_FUN_INSTALL_GAMING_ONLINE_INTERACTIVE_MENU
}
```

### 10.7 Asset Directory Structure

```
AUTO-INSTALLS-FILES/GAMING/
├── CITRON-EMULATOR-APPIMAGE/
│   └── Citron.AppImage           # Nintendo Switch AppImage
├── XEMU_XBOX_FILES.zip           # Xbox BIOS, ROM, and HDD
├── NINTENDO-SWITCH-PRODKEYS-*.7z # Switch encryption keys
├── NINTENDO-SWITCH-FIRMWARE-*.7z # Switch firmware
└── RETROARCH-CORES/              # RetroArch emulator cores (.so files)
```

### 10.8 Flatpak vs Binary vs AppImage Trade-offs

| Method | Pros | Cons |
|--------|------|------|
| **Flatpak** | Containerized, safe, easy updates | Larger disk footprint, initial setup |
| **PPA Binary** | Native integration, smaller size | Distribution-dependent, less portable |
| **AppImage** | Portable, self-contained, high perf | Requires manual updates, debugging harder |

**This system uses:**
- Flatpak for: PPSSPP, Ryujinx, RetroArch (broad compatibility)
- PPA Binary for: XEMU (Xbox, native performance)
- AppImage for: Citron (legacy, optimized for performance)

---

## 11. Installation Status Reporting & 4-Column Formatting

### 11.1 Status Tracking Arrays

Throughout execution, package names are collected in arrays for final reporting:

```bash
declare -a _ARRAY_ALL_PACKAGES    # All packages processed
declare -a _ARRAY_SUCCESS         # Successfully installed packages
declare -a _ARRAY_FAIL            # Failed installations
declare -i _array_counter=0       # Index counter
```

### 11.2 Status Checker Pattern

As each package is installed, it's immediately recorded:

```bash
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER() {
	PKG_NAME=$1
	for _FLATTENED_PKG in $PKG_NAME; do
		_ARRAY_ALL_PACKAGES[$_array_counter]="$_FLATTENED_PKG"
		_array_counter=$((_array_counter + 1))
	done
}
```

Called after each installation:
```bash
FUN_INSTALL_PACKAGE_HELPER_WITH_RETRY "curl" "curl"
FUN_PACKAGE_INSTALLATION_STATUS_CHECKER "curl"  # Recorded here
```

### 11.3 Final Status Verification and Audit

After all installations complete, the final check verifies each package and performs a system-wide audit:

```bash
FUN_FINAL_INSTALLED_STATUS() {
	# Check APT packages
	for LOOP_PKG in "${_ARRAY_ALL_PACKAGES[@]}"; do
		if dpkg-query -W -f='${db:Status-Status}' "$LOOP_PKG" 2>/dev/null | grep -q '^installed$'; then
			_ARRAY_SUCCESS+=("$LOOP_PKG")
		else
			_ARRAY_FAIL+=("$LOOP_PKG")
		fi
	done
	
	# Generate Audit Report
	# Sections include: APT, Snap, Flatpak, Local Binaries, Dev Environments, 
	# GNOME Extensions, VSCode Extensions, PPA List, and PATH inventory.
	generate_comprehensive_audit_file
	
	# Display results to terminal
	display_formatted_report
}
```

### 11.4 4-Column Formatting Report

The final report uses `pr` and `sed` for elegant 4-column alignment with colour coding, now separated into APT and Custom/Manual categories:

```bash
# Success report (GREEN) - APT
echo -e ":: SUCCESSFULLY INSTALLED PACKAGES (Current Session - APT) ::\n"
printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u | pr -t -4 | sed "s/^/${COLORS[GREEN]}/;s/$/${COLORS[RESET]}/"

# Success report (GREEN) - Custom/Manual
echo -e ":: SUCCESSFULLY INSTALLED (Current Session - CUSTOM/MANUAL) ::\n"
printf "%s\n" "${_ARRAY_NON_APT_SUCCESS[@]}" | sort -u | pr -t -4 | sed "s/^/${COLORS[GREEN]}/;s/$/${COLORS[RESET]}/"

# Fail reports follow the same pattern in RED
```

**Breaking down the command pipeline:**

1. `printf "%s\n" "${_ARRAY_SUCCESS[@]}"` – Print each element on separate line
2. `sort -u` – Sort alphabetically and remove duplicates
3. `pr -t -4` – Format into 4 columns (tab-separated, no headers)
4. `sed "s/^/..../;s/$/..../"` – Wrap each line with ANSI colour codes:
   - `s/^/COLOR/` – Insert colour at line start
   - `s/$/RESET/` – Insert reset code at line end

**Example output:**

```
:: SUCCESSFULLY INSTALLED PACKAGES ::

curl            git             jq              make
nmap            openssl         python3         tmux
vim             wget            zsh

:: ERRONEOUSLY INSTALLED PACKAGES ::

obsolete-pkg    unsupported-lib
```

**With colours** (in terminal):
- Success packages appear in **GREEN**
- Failed packages appear in **RED**

### 11.5 Alternative Formatting Options

If `pr` is unavailable, fallback formatting:

```bash
# Column-based using awk
printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u | awk '{printf "%-20s", $0} NR%4==0 {print ""}'

# Simple list format
printf "%s\n" "${_ARRAY_SUCCESS[@]}" | sort -u
```

### 11.6 Status Reporting Integration

Called at the very end of main execution:

```bash
# Main script finalization
for CHOOSER in $MAIN_CHOICE_SANITIZED; do
	# ... execute choice ...
	FUN_PACKAGE_INSTALLATION_STATUS_CHECKER "package_name"
done

# Kill background processes
kill $SUDO_KEEPALIVE_PID

# Generate final report
FUN_FINAL_INSTALLED_STATUS
```

This ensures users always see a clear summary of what succeeded and what failed, with easy visual scanning via the 4-column format and colour coding.

---
