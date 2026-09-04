#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=./logs/install_%j.out
#SBATCH --error=./logs/install_%j.err
#SBATCH --time=01:00:00

set -euo pipefail

echo "[INFO] Starting install of code-server 4.134.0 on $(hostname) at $(date)"

# Setting up variables for the installation
# Only SOFTWARE_DIRECTORY will need to be changed on future updates
# If a user wants to clone and install a local copy for themselves/groups
# GROUP_DIRECTORY needs to be modified
SOFTWARE_NAME="code-server"
SOFTWARE_VERSION="4.134.0"
SOFTWARE_ARCH="linux-amd64"

GROUP_DIRECTORY="/projects/able"
GROUP_NAME="kanegroup"
GROUP_ADMIN="mbkane"

SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"
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
echo "[STEP] Creating download directory and fetching tarball"
mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"

TARBALL="code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
if [[ -f "$TARBALL" ]]; then
    echo "[INFO] Found existing tarball $TARBALL - reusing"
else
    echo "[INFO] Downloading code-server v${SOFTWARE_VERSION} (${SOFTWARE_ARCH})"
    wget "https://github.com/coder/code-server/releases/download/v${SOFTWARE_VERSION}/${TARBALL}"
fi

echo "[STEP] Extracting tarball"

EXTRACTED_DIRECTORY="$SOFTWARE_DOWNLOADS_DIRECTORY/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"

rm -rf "$EXTRACTED_DIRECTORY"
tar -xzf "$TARBALL"

echo "[STEP] Installing unpacked directory"

rm -rf "$SOFTWARE_PACKAGE_DIRECTORY"
mv "$EXTRACTED_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"

echo "[STEP] Moving unpacked directory into final location"
mkdir -p "$SOFTWARE_DIRECTORY"
mv "code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}" "$SOFTWARE_PACKAGE_DIRECTORY"

# Set shared group and ACL permissions
echo "[STEP] Setting group and ACL permissions"

# Change the group where permitted.
# This does not require root if the current user owns the files
# and is a member of $GROUP_NAME.
chgrp -R "${GROUP_NAME}" "$SOFTWARE_PACKAGE_DIRECTORY"

# Keep new files/directories in the shared group.
find "$SOFTWARE_PACKAGE_DIRECTORY" -type d -exec chmod g+s {} +

# Give the group admin full access and the group read/execute access.
# X preserves execute permission only where it is already needed.
DIR_ACL="u::rwx,u:${GROUP_ADMIN}:rwx,g::r-X,g:${GROUP_NAME}:r-X,m::rwx,o::---"
FILE_ACL="u::rwX,u:${GROUP_ADMIN}:rwX,g::r-X,g:${GROUP_NAME}:r-X,m::rwx,o::---"

find "$SOFTWARE_PACKAGE_DIRECTORY" -type d \
  -exec setfacl -m "$DIR_ACL" {} +

find "$SOFTWARE_PACKAGE_DIRECTORY" -type f \
  -exec setfacl -m "$FILE_ACL" {} +

# Creating modulefile
echo "[STEP] Creating modulefile in $SOFTWARE_MODULEFILES_DIRECTORY"
mkdir -p "$SOFTWARE_MODULEFILES_DIRECTORY"
cd "$SOFTWARE_MODULEFILES_DIRECTORY"
MODULEFILE=$SOFTWARE_VERSION
cat > "$MODULEFILE" <<EOF
#%Module
module-whatis "Loads $SOFTWARE_NAME/$SOFTWARE_VERSION module.

This module was built on $(date)

Code Server (https://github.com/coder/code-server) provides VSCode in a browser environment

The script used to build this module can be found here: $GITHUB_URL

To load the module, type:
module use $MODULEFILE_PREFIX
module load $SOFTWARE_NAME/$SOFTWARE_VERSION
"

conflict  $SOFTWARE_NAME

prepend-path  PATH            $SOFTWARE_PACKAGE_DIRECTORY/bin
prepend-path  LD_LIBRARY_PATH $SOFTWARE_PACKAGE_DIRECTORY/lib
prepend-path  LIBRARY_PATH    $SOFTWARE_PACKAGE_DIRECTORY/lib

# Set an alias for opening files in the vscode window from the terminal
set-alias code "code-server -r "

# Configure VS Code extensions marketplace
setenv EXTENSIONS_GALLERY "{\"serviceUrl\": \"https://marketplace.visualstudio.com/_apis/public/gallery\"}"
EOF

# Moving modulefile
echo "[STEP] Installing modulefile into $MODULEFILE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cp "$MODULEFILE" "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION"

echo "[SUCCESS] code-server ${SOFTWARE_VERSION} install completed at $(date)"
