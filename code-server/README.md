# Code Server

These scripts create software modules that load the specified version of VSCode for running within the
[OnDemand](https://ood.explorer.northeastern.edu/)
web graphical interface.

## Bookmarklet

This bookmarklet helps you quickly configure the
[OnDemand / code-server](https://ood.explorer.northeastern.edu/pun/sys/dashboard/batch_connect/sys/vscode/session_contexts/new)
form for the NEU ABLE Lab environment. When you click the bookmarklet on the
appropriate page, it:

- Sets the **Conda module** to `able`
- Sets the **VSCode module** to the specified version (e.g., `code-server/4.105.1`, displayed as `vscode/1.105.1`)

The actual logic lives in [`bookmarklet.js`](./bookmarklet.js) in this
repository. The bookmarklet itself just loads that file from GitHub, so whenever
`bookmarklet.js` is updated, everyone using the bookmarklet will automatically
get the latest version.

### The bookmarklet code (what you paste into your browser)

Use **this** as the bookmark “URL”:

```javascript
javascript:(function(){var url='https://raw.githubusercontent.com/NEU-ABLE-LAB/northeastern-rc-software-modules-able/refs/heads/main/code-server/bookmarklet.js?ts='+Date.now();fetch(url).then(function(r){return r.text();}).then(function(code){(new Function(code))();}).catch(function(err){console.error('Error loading bookmarklet.js',err);alert('Error loading NEU RC bookmarklet.js. See console for details.');});})();
```

## Contributing

Follow the steps below to add a module for a [new version of code-server](https://github.com/coder/code-server/releases)

1. Create a copy of the `install-v*.sh` script with a filename that matches the desired version.
2. Update the `SOFTWARE_VERSION` variable to the desired version. (Use `CTRL+F` for the old version to catch other references.)
3. Run the install script with `sbatch`.
4. Modify `bookmarklet.js`, adding an `ensureOption` statement and modifying the `setSelect` with the desired version.
5. Merge changes into the `main` branch to make `bookmarklet.js` available from the internet for the bookmarklet snippet to pull from.

### Removing a version

You should remove old unused versions with the following process:

1. Ensure no running jobs or active OnDemand sessions are using the target version.
2. Remove the published modulefile so new sessions cannot load it.
3. Remove the staged modulefile and software tree for that version.
4. Remove the downloaded tarball for that version.
5. Remove the install script in this repo for that version.
6. Remove that version's `ensureOption` statement (and modify the `setSelect` if necessary) from `code-server/bookmarklet.js`.

Example commands for version `4.111.0`:

```bash
VERSION=4.111.0
ARCH=linux-amd64
rm -f /projects/able/modulefiles/code-server/$VERSION
rm -f /projects/able/software/code-server/$VERSION/modulefiles/$VERSION
rm -rf /projects/able/software/code-server/$VERSION/code-server-$VERSION-$ARCH
rm -f /projects/able/software/code-server/$VERSION/downloads/code-server-$VERSION-$ARCH.tar.gz
rmdir /projects/able/software/code-server/$VERSION 2>/dev/null || true
```
