// ABLE Lab / Northeastern RC helper bookmarklet
// This script is intended to be loaded via a bookmarklet.
// - Adds/updates module options for ABLE
// - Selects ABLE defaults for conda and VSCode

(function () {
  function ensureOption(selectId, value, label) {
    var select = document.getElementById(selectId);
    if (!select) {
      return null;
    }

    var opt = select.querySelector('option[value="' + value + '"]');

    if (!opt) {
      opt = document.createElement('option');
      opt.value = value;
      opt.textContent = label;
      select.appendChild(opt);
    } else {
      opt.textContent = label;
    }

    return opt;
  }

  function setSelect(selectId, value, label) {
    var select = document.getElementById(selectId);
    if (!select) {
      return;
    }

    var opt = ensureOption(selectId, value, label);
    if (!opt) {
      return;
    }

    opt.selected = true;
    select.value = value;
    select.dispatchEvent(new Event('change', { bubbles: true }));
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

  ensureOption(
    'batch_connect_session_context_vscode_module',
    'code-server/4.108.2',
    'vscode/1.108.2 (able)'
  );

  // Set the desired modules on the RC form
  setSelect(
    'batch_connect_session_context_conda_module',
    'miniforge3/25.9.1-0',
    'miniforge3/25.9.1-0 (able)'
  );

  setSelect(
    'batch_connect_session_context_vscode_module',
    'code-server/4.108.2',
    'vscode/1.108.2 (able)'
  );
})();
