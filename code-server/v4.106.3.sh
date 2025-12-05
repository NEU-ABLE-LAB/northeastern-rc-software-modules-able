#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=/projects/able/logs/code-server_v4.106.3_install_%j.out
#SBATCH --error=/projects/able/logs/code-server_v4.106.3_install_%j.err
#SBATCH --time=01:00:00

# Setting up environmental variables for the installation
# Only SOFTWARE_DIRECTORY will need to be changed on future updates
# If a user wants to clone and install a local copy for themselves/groups
# CLUSTER_DIRECTORY needs to be modified
export CLUSTER_DIRECTORY=/projects/able/
export SOFTWARE_NAME=code-server
export SOFTWARE_VERSION=4.106.3
export SOFTWARE_ARCH=linux-amd64

export SOFTWARE_DIRECTORY=$CLUSTER_DIRECTORY/opt/$SOFTWARE_NAME/$SOFTWARE_VERSION

export MODULEFILE_PREFIX=$CLUSTER_DIRECTORY/modulefiles/
export MODULEFILE_DIRECTORY=$MODULEFILE_PREFIX/$SOFTWARE_NAME/
export GITHUB_URL=https://github.com/NEU-ABLE-LAB/northeastern-rc-software-modules-able/$SOFTWARE_NAME/v$SOFTWARE_VERSION/install.sh

# Creating the src directory for the installed application
mkdir -p $SOFTWARE_DIRECTORY/src

# Installing $SOFTWARE_NAME/$SOFTWARE_VERSION
cd $SOFTWARE_DIRECTORY/src
wget "https://github.com/coder/code-server/releases/download/v${SOFTWARE_VERSION}/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
tar -xvzf "code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
mv code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}/ ../

# Set permissions
chown -R "mbkane":"kanegroup" "/projects/able/opt/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"
chmod -R go-w "/projects/able/opt/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"

# Creating modulefile
MODULEFILE=$SOFTWARE_VERSION
touch $MODULEFILE
echo "#%Module" >> $MODULEFILE
echo "module-whatis	 \"Loads $SOFTWARE_NAME/$SOFTWARE_VERSION module." >> $MODULEFILE
echo "" >> $MODULEFILE
echo "This module was build on $(date)" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "Code Server (https://github.com/coder/code-server) provides VSCode in a browser environment" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "The script used to build this module can be found here: $GITHUB_URL" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "To load the module, type:" >> $MODULEFILE
echo "module use $MODULEFILE_PREFIX" >> $MODULEFILE
echo "module load $SOFTWARE_NAME/$SOFTWARE_VERSION" >> $MODULEFILE
echo "\"" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "conflict	 $SOFTWARE_NAME" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "prepend-path	 PATH $SOFTWARE_DIRECTORY/bin" >> $MODULEFILE
echo "prepend-path	 LD_LIBRARY_PATH $SOFTWARE_DIRECTORY/lib" >> $MODULEFILE
echo "prepend-path	 LIBRARY_PATH $SOFTWARE_DIRECTORY/lib" >> $MODULEFILE
echo "" >> $MODULEFILE
echo "set-alias code \"code-server -r \"" >> $MODULEFILE

# Moving modulefile
mkdir -p $MODULEFILE_DIRECTORY
cp $MODULEFILE $MODULEFILE_DIRECTORY/$SOFTWARE_VERSION