// ABLE Lab / Northeastern RC helper bookmarklet
// This script is intended to be loaded via a bookmarklet. It:
//   - Sets the conda module to "able"
//   - Sets the VSCode (code-server) module to "code-server/4.105.1"

(function () {
  function ensureOption(id, val, text) {
    var s = document.getElementById(id);
    if (!s) {
      return null;
    }

    var opt = s.querySelector('option[value="' + val + '"]');

    if (!opt) {
      opt = document.createElement('option');
      opt.value = val;
      opt.textContent = text;
      s.appendChild(opt);
    } else {
      opt.textContent = text;
    }

    return opt;
  }

  function setSelect(id, val, text) {
    var s = document.getElementById(id);
    if (!s) {
      return;
    }

    var opt = ensureOption(s, val, text);
    if (!opt) {
      return;
    }

    opt.selected = true;
    s.value = val;
    s.dispatchEvent(new Event('change', { bubbles: true }));
  }

  // Add options to desired modules
  ensureOption(
    'batch_connect_session_context_conda_module',
    'miniforge3/25.9.1-0',
    'miniforge3/25.9.1-0 (able)'
  );

  ensureOption(
    'batch_connect_session_context_vscode_module',
    'code-server/4.105.1',
    'vscode/1.105.1 (able)'
  );

  ensureOption(
    'batch_connect_session_context_vscode_module',
    'code-server/4.106.3',
    'vscode/1.106.3 (able)'
  );

  // Set the desired modules on the RC form
  setSelect(
    'batch_connect_session_context_conda_module',
    'miniforge3/25.9.1-0',
    'miniforge3/25.9.1-0 (able)'
  );

  setSelect(
    'batch_connect_session_context_vscode_module',
    'code-server/4.106.3',
    'vscode/1.106.3 (able)'
  );
})();
