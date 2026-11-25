"""Mutation-to-input bindings live here, not in the contract prose (Н-39).

Each binding names the one cell whose conforming input makes this single
defect observable; the registry carries executable old→new replacements
against the materialized etalon, never against production files.
"""
from model import once

# name: (cell, file, old, new)
STABS = {
    'deps-cmp-inverted': ('deps-lock-differs', 'check_architecture_contract.sh',
        'if ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"; then',
        'if false; then'),
    'deps-size-only': ('deps-lock-same-size', 'check_architecture_contract.sh',
        'cmp -s "$tmp/package-lock.json" "$root/package-lock.json"',
        '[ "$(wc -c < "$tmp/package-lock.json")" -eq "$(wc -c < "$root/package-lock.json")" ]'),
    'deps-modules-optional': ('deps-donor-modules-missing', 'check_architecture_contract.sh',
        'if [ ! -d "$root/node_modules" ]; then',
        'if false; then'),
    'deps-pin-lock-optional': ('deps-pin-lock-missing', 'check_architecture_contract.sh',
        "&& jq -e '(.dependencies // {}) | length > 0' \"$tmp/package.json\" >/dev/null 2>&1; then",
        '&& false; then'),
    'deps-no-symlink': ('deps-linked', 'check_architecture_contract.sh',
        '''    ln -s "$(cd "$root/node_modules" && pwd -P)" "$tmp/node_modules" \\
      || { rm -rf "$tmp"
           ARCH187_REFUSAL="ARCH_BRIEF_DEPS: node_modules выгрузки не подключить"
           return 1; }''',
        '    :'),
    'deps-pin-from-head': ('deps-linked', 'check_architecture_contract.sh',
        'if ! git -C "$root" archive "$pin" 2>/dev/null | tar -x -C "$tmp" 2>/dev/null; then',
        'if ! git -C "$root" archive HEAD 2>/dev/null | tar -x -C "$tmp" 2>/dev/null; then'),
    # ── (2) причина отказа — код + сообщение модели ───────────────────────
    'reason-json-ignored': ('reason-json', 'check_architecture_contract.sh',
        'if (type == "object") and ((.findings[0].code | length) > 0)',
        'if false'),
    'reason-code-dropped': ('reason-json', 'check_architecture_contract.sh',
        'then (.findings[0].code) + (if ((.findings[0].message | length) > 0) then ": " + .findings[0].message else "" end)',
        'then "" + (if ((.findings[0].message | length) > 0) then .findings[0].message else "" end)'),
    'reason-message-dropped': ('reason-json', 'check_architecture_contract.sh',
        'then ": " + .findings[0].message else "" end)',
        'then "" else "" end)'),
    'flag-stderr-swallowed': ('element-flag-unknown', 'make_task.sh',
        '_arch_text="$(arch187_brief "$_arch_id" "$_arch_rules_flag")" || _arch_rc=$?',
        '_arch_text="$(arch187_brief "$_arch_id" "$_arch_rules_flag" 2>/dev/null)" || _arch_rc=$?'),
    # ── (3) id строки — элементы модели по пину ───────────────────────────
    'element-membership-removed': ('element-line-unknown', 'check_architecture_contract.sh',
        '''  if ! arch187_element_ids; then
    arch187_snapshot_drop
    return 1
  fi''',
        '  :'),
    'element-code-renamed': ('element-line-unknown', 'check_architecture_contract.sh',
        'ARCH187_REFUSAL="UNKNOWN_ARCHITECTURE_ELEMENT: $id"',
        'ARCH187_REFUSAL="ARCH_ELEMENT: $id"'),
    'element-head-not-pin': ('element-pin-not-head', 'check_architecture_contract.sh',
        '(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$id") >/dev/null 2>"$errf" || rc=$?',
        '(cd "${ARCHITECTURE_ROOT:-$ARCH187_MODEL_DIR}" && node tooling/checks/cli.js brief --compact --component "$id") >/dev/null 2>"$errf" || rc=$?'),
    # ── (4) кап — pack.maxBytes, не 40000 ─────────────────────────────────
    'cap-profile-ignored': ('cap-within', 'make_task.sh',
        "'.pack.value.maxBytes // 40000'",
        "'40000 // 40000'"),
    'cap-arch-budget-branch': ('cap-within', 'make_task.sh',
        '[ "$VK" -le "$MAX" ] || die "режь задачу: $VK > $MAX"',
        '''if [ "$VK" -gt 40000 ] && [ "${_arch187_scope:-0}" = "1" ] && [ -n "$ARCH_SEC" ]; then
  die "ARCH_BRIEF_BUDGET: $VK > 40000; сузьте --arch-component или разделите задание"
fi
[ "$VK" -le "$MAX" ] || die "режь задачу: $VK > $MAX"'''),
    'cap-limit-dropped': ('cap-over-profile', 'make_task.sh',
        '[ "$VK" -le "$MAX" ] || die "режь задачу: $VK > $MAX"',
        ': # кап снят'),
}


def mutate(root, name):
    _, filename, old, new = STABS[name]
    file = root / 'scripts' / filename
    file.write_text(once(file.read_text(), old, new))
