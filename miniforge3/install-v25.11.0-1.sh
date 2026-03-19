#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=./logs/install_%j.out
#SBATCH --error=./logs/install_%j.err
#SBATCH --time=01:00:00

set -euo pipefail

echo "[INFO] Starting install of miniforge3 25.11.0-1 on $(hostname) at $(date)"

# Setting up variables for the installation
# Only SOFTWARE_DIRECTORY will need to be changed on future updates
# If a user wants to clone and install a local copy for themselves/groups
# GROUP_DIRECTORY needs to be modified
SOFTWARE_NAME="miniforge3"
SOFTWARE_VERSION="25.11.0-1"
SOFTWARE_ARCH="Linux-x86_64"

GROUP_DIRECTORY="/projects/able"
GROUP_NAME="kanegroup"
GROUP_ADMIN="mbkane"
GROUP_DOTCONDA_DIRECTORY="$GROUP_DIRECTORY/.conda"
GROUP_USERS_DIRECTORY="$GROUP_DIRECTORY/users"

SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/Miniforge3-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
SOFTWARE_MODULEFILES_DIRECTORY="$SOFTWARE_DIRECTORY/modulefiles"

MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

GITHUB_URL="https://github.com/NEU-ABLE-LAB/northeastern-rc-software-modules-able/$SOFTWARE_NAME/install-v$SOFTWARE_VERSION.sh"

echo "[INFO] Using install directories:"
echo "       SOFTWARE_DIRECTORY         = $SOFTWARE_DIRECTORY"
echo "       SOFTWARE_DOWNLOADS_DIR     = $SOFTWARE_DOWNLOADS_DIRECTORY"
echo "       SOFTWARE_PACKAGE_DIRECTORY = $SOFTWARE_PACKAGE_DIRECTORY"
echo "       MODULEFILE_DIRECTORY       = $MODULEFILE_DIRECTORY"

# Download and unzip
echo "[STEP] Creating download directory and fetching install script"
mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"

INSTALL_SCRIPT="Miniforge3-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.sh"
if [[ -f "$INSTALL_SCRIPT" ]]; then
	echo "[INFO] Found existing install script $INSTALL_SCRIPT - reusing"
else
	echo "[INFO] Downloading miniforge3 v${SOFTWARE_VERSION} (${SOFTWARE_ARCH})"
	wget "https://github.com/conda-forge/miniforge/releases/download/${SOFTWARE_VERSION}/${INSTALL_SCRIPT}"
fi

echo "[STEP] Make install script executable"
chmod u+x "${INSTALL_SCRIPT}"

echo "[STEP] Install into the shared location"
if [[ -d "$SOFTWARE_PACKAGE_DIRECTORY" ]]; then
  echo "[ERROR] Install prefix already exists: $SOFTWARE_PACKAGE_DIRECTORY"
  echo "        Refusing to overwrite. Remove it manually if you intend to reinstall."
  exit 1
fi
mkdir -p "$SOFTWARE_DIRECTORY"
bash "${INSTALL_SCRIPT}" -b -p "${SOFTWARE_PACKAGE_DIRECTORY}"

# Set permissions
echo "[STEP] Setting ownership and permissions"
chown -R "${GROUP_ADMIN}":"${GROUP_NAME}" "$SOFTWARE_PACKAGE_DIRECTORY"
chmod -R go-w "$SOFTWARE_PACKAGE_DIRECTORY"

# Create group .conda directories if they don't exist
mkdir -p $GROUP_DOTCONDA_DIRECTORY/envs
mkdir -p $GROUP_DOTCONDA_DIRECTORY/pkgs
chown "${GROUP_ADMIN}":"${GROUP_NAME}" $GROUP_DOTCONDA_DIRECTORY -R
chmod 750 $GROUP_DOTCONDA_DIRECTORY
chmod 750 $GROUP_DOTCONDA_DIRECTORY/envs
chmod 750 $GROUP_DOTCONDA_DIRECTORY/pkgs

# Creating modulefile
echo "[STEP] Creating modulefile in $SOFTWARE_MODULEFILES_DIRECTORY"
mkdir -p "$SOFTWARE_MODULEFILES_DIRECTORY"
cd "$SOFTWARE_MODULEFILES_DIRECTORY"
MODULEFILE=$SOFTWARE_VERSION
cat > "$MODULEFILE" <<EOF
#%Module
module-whatis {Loads $SOFTWARE_NAME/$SOFTWARE_VERSION module.

This module was built on $(date)

Miniforge (https://github.com/conda-forge/miniforge) installs Conda (https://conda.io/) and Mamba (https://github.com/mamba-org/mamba) specific to [conda-forge](https://conda-forge.org/).

The script used to build this module can be found here: $GITHUB_URL

To load the module, type:
module use $MODULEFILE_PREFIX
module load $SOFTWARE_NAME/$SOFTWARE_VERSION
}

# miniforge3 conflicts with itself and anaconda3 modules
conflict anaconda3 $SOFTWARE_NAME

prepend-path PATH            "$SOFTWARE_PACKAGE_DIRECTORY/bin"
prepend-path MANPATH         "$SOFTWARE_PACKAGE_DIRECTORY/share/man"

# Per-user conda env/pkgs directories on the project filesystem
set user     \$env(USER)
set user_dotconda_dir "$GROUP_USERS_DIRECTORY/\$user/.conda"

setenv MINIFORGE_HOME "$SOFTWARE_PACKAGE_DIRECTORY"

# Shared base
set group_dotconda_dir "$GROUP_DOTCONDA_DIRECTORY"

# User first, then shared
setenv CONDA_ENVS_PATH  "\$user_dotconda_dir/envs:\$group_dotconda_dir/envs"
setenv CONDA_PKGS_DIRS  "\$user_dotconda_dir/pkgs,\$group_dotconda_dir/pkgs"

# Set the user's XDG cache to the project directory if not already set
if { ![info exists env(XDG_CACHE_HOME)] } {
    setenv XDG_CACHE_HOME "$GROUP_USERS_DIRECTORY/\$user/.cache"
}

# --- Safety check for old conda init blocks in ~/.bashrc ---

set home   \$env(HOME)
set bashrc [file join \$home ".bashrc"]

if { [file readable \$bashrc] } {
    # Read the whole file once
    set fh [open \$bashrc r]
    set content [read \$fh]
    close \$fh

    # Is there a conda initialize block at all?
    if { [string match "*# >>> conda initialize >>>*" \$content] } {
        # Does that block mention *this* Miniforge install?
        if { ! [string match "*$SOFTWARE_PACKAGE_DIRECTORY/bin/conda*" \$content] } {
            puts stderr \
"WARNING: Detected a 'conda initialize' block in \$bashrc that does not point to:
    $SOFTWARE_PACKAGE_DIRECTORY/bin/conda

This may cause your shell to use a different conda install than the one
provided by this module. Consider commenting out that block or updating it."
        }
    }
}
EOF

# Moving modulefile
echo "[STEP] Installing modulefile into $MODULEFILE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cp "$MODULEFILE" "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION"

echo "[SUCCESS] miniforge3 ${SOFTWARE_VERSION} install completed at $(date)"
