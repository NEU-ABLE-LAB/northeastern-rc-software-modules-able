# Code Server

This software module load the specified version of VSCode for running within the
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
javascript:(function(){var url='https://raw.githubusercontent.com/NEU-ABLE-LAB/northeastern-rc-software-modules-able/main/code-server/bookmarklet.js?ts='+Date.now();fetch(url).then(function(r){return r.text();}).then(function(code){(new Function(code))();}).catch(function(err){console.error('Error loading bookmarklet.js',err);alert('Error loading NEU RC bookmarklet.js. See console for details.');});})();
```
