#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=./logs/install_%j.out
#SBATCH --error=./logs/install_%j.err
#SBATCH --time=01:00:00

# Setting up variables for the installation
# Only SOFTWARE_DIRECTORY will need to be changed on future updates
# If a user wants to clone and install a local copy for themselves/groups
# GROUP_DIRECTORY needs to be modified
SOFTWARE_NAME="code-server"
SOFTWARE_VERSION="4.106.3"
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

# Download and unzip
mkdir -p $SOFTWARE_DOWNLOADS_DIRECTORY
cd $SOFTWARE_DOWNLOADS_DIRECTORY
wget "https://github.com/coder/code-server/releases/download/v${SOFTWARE_VERSION}/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
tar -xvzf "code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
mv "code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}" "$SOFTWARE_PACKAGE_DIRECTORY"

# Set permissions
chown -R "${GROUP_ADMIN}":"${GROUP_NAME}" "$SOFTWARE_PACKAGE_DIRECTORY"
chmod -R go-w "$SOFTWARE_PACKAGE_DIRECTORY"

# Creating modulefile
mkdir -p "$SOFTWARE_MODULEFILES_DIRECTORY"
cd "$SOFTWARE_MODULEFILES_DIRECTORY"
MODULEFILE=$SOFTWARE_VERSION
cat > "$MODULEFILE" <<EOF
#%Module
module-whatis "Loads $SOFTWARE_NAME/$SOFTWARE_VERSION module."

This module was built on $(date)

Code Server (https://github.com/coder/code-server) provides VSCode in a browser environment

The script used to build this module can be found here: $GITHUB_URL

To load the module, type:
module use $MODULEFILE_PREFIX
module load $SOFTWARE_NAME/$SOFTWARE_VERSION

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
mkdir -p $MODULEFILE_DIRECTORY
cp $MODULEFILE $MODULEFILE_DIRECTORY/$SOFTWARE_VERSION
