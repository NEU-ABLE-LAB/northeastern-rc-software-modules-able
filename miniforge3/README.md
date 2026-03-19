# Miniforge3

These scripts create software modules that load `conda` (`miniforge3`) to be used by the group.

## [OnDemand](https://ood.explorer.northeastern.edu/) with VSCode

This version of `conda` can be used by the OnDemand VScode instance by using a bookmarklet to modify the OOD interactive session. See the [VSCode script README](../code-server/README.md) for details.

## Contributing

Follow the steps below to add a module for a [new version of miniforge](https://github.com/conda-forge/miniforge/releases)

1. Create a copy of the `install-v*.sh` script with a filename that matches the desired version.
2. Update the `SOFTWARE_VERSION` variable to the desired version. (Use `CTRL+F` for the old version to catch other references.)
3. Run the install script with `sbatch`
4. Modify `bookmarklet.js`, adding an `ensureOption` statement and modifying the `setSelect` with the desired version.
5. Merge changes into the `main` branch to make `bookmarklet.js` available from the internet for the bookmarklet snippet to pull from.

### Removing a version

You should remove old unused versions with the following process:

1. Ensure no running jobs are using the target version.
2. Remove the published modulefile so new sessions cannot load it.
3. Remove the staged modulefile and software tree for that version.
4. Remove the install script in this repo for that version.
5. Remove that version's `setSelect` statement from `code-server/bookmarklet.js`
6. Keep `/projects/able/.conda`.

Example commands for version 25.11.0-1:

```bash
VERSION=25.11.0-1
ARCH=Linux-x86_64
rm -f /projects/able/modulefiles/miniforge3/$VERSION
rm -f /projects/able/software/miniforge3/$VERSION/modulefiles/$VERSION
rm -rf /projects/able/software/miniforge3/$VERSION/Miniforge3-$VERSION-$ARCH
rm -f /projects/able/software/miniforge3/$VERSION/downloads/Miniforge3-$VERSION-$ARCH.sh
rmdir /projects/able/software/miniforge3/$VERSION 2>/dev/null || true
```
