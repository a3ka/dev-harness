"""Executable reference overlay; production files are never modified.

Only model copies receive these deltas. It exercises the real make_task pipeline,
Git archive and Node resolution instead of returning precomputed probe answers.
"""
from pathlib import Path
import shutil
import subprocess

BASE = '1a0b859c8b609825a00e484251f4f8f59ed2b0f4'


def baseline(source, name):
    return subprocess.run(['git', '-C', str(source), 'show', BASE + ':scripts/' + name],
                          check=True, capture_output=True, text=True).stdout


DEPENDENCIES = '''  if [ -f "$tmp/package-lock.json" ]; then
    if [ ! -f "$root/package-lock.json" ] || ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"; then
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: package-lock.json differs; npm ci at exact pin"
      rm -rf "$tmp"
      return 1
    fi
    if [ ! -d "$root/node_modules" ]; then
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: node_modules missing; npm ci at exact pin"
      rm -rf "$tmp"
      return 1
    fi
    ln -s "$(cd "$root/node_modules" && pwd -P)" "$tmp/node_modules" || return 1
  elif [ -f "$tmp/package.json" ] && jq -e '(.dependencies // {}) | length > 0' "$tmp/package.json" >/dev/null; then
    ARCH187_REFUSAL="ARCH_BRIEF_DEPS: pinned package-lock.json missing; npm ci at exact pin"
    rm -rf "$tmp"
    return 1
  fi
'''

BRIEF = '''arch187_brief() {
  local comp="${1:-}" rules="${2:-0}" out err rc=0 errf
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 1
  errf="$(mktemp)" || return 2
  if [ "$rules" = "1" ]; then
    out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --with-rules --component "$comp" 2>"$errf")" || rc=$?
  else
    out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$comp" 2>"$errf")" || rc=$?
  fi
  err="$(python3 -c 'import sys; print(sys.stdin.readline().rstrip("\\r\\n").replace("\\t", " ")[:200])' < "$errf")"
  rm -f "$errf"
  if [ "$rc" -ne 0 ]; then
    printf 'ARCH_BRIEF_OTKAZ: %s (rc=%s): %s\\n' "$comp" "$rc" "$err" >&2
    return 1
  fi
  [ -n "$out" ] || return 1
  printf '%s\\n' "$out"
  return 0
}
'''


def once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f'MODEL_ANCHOR: expected one occurrence: {old[:90]!r}')
    return text.replace(old, new, 1)


def materialize(source: Path, target: Path):
    target.mkdir()
    shutil.copytree(source / 'scripts', target / 'scripts')
    # Other repository resources stay read-only and are shared with the source.
    for name in ('config', 'registry', 'roles', 'schemas', 'package.json'):
        if (source / name).exists():
            (target / name).symlink_to(source / name)
    archfile = target / 'scripts/check_architecture_contract.sh'
    arch = baseline(source, 'check_architecture_contract.sh')
    arch = once(arch, '  ARCH187_MODEL_DIR="$tmp"\n', DEPENDENCIES + '  ARCH187_MODEL_DIR="$tmp"\n')
    start = arch.index('arch187_brief() {\n')
    end = arch.index('\n# arch187_model_check', start)
    arch = arch[:start] + BRIEF + arch[end:]
    archfile.write_text(arch)
    taskfile = target / 'scripts/make_task.sh'
    task = baseline(source, 'make_task.sh')
    task = once(task, '_arch_text="$(arch187_brief "$_arch_id" "$_arch_rules_flag")"',
                '_arch_text="$(arch187_brief "$_arch_id" "$_arch_rules_flag" 2>"$_NPM_ERR_REDIR")"')
    task = once(task, 'die "ARCH_BRIEF_OTKAZ: $_arch_id (закреплённая модель не отдала бриф)"',
                '''_arch_hint="$(cat "$_NPM_ERR_REDIR")"
          die "${_arch_hint:-ARCH_BRIEF_OTKAZ: $_arch_id (пустая диагностика)}"''')
    task = once(task, '[ "$VK" -le 40000 ] || die "режь задачу: $VK > 40000"', '''if [ "$VK" -gt 40000 ]; then
  if [ "${_arch187_scope:-0}" = "1" ] && [ -n "$ARCH_SEC" ]; then
    die "ARCH_BRIEF_BUDGET: $ARCH_COMPONENT $VK > 40000; сузьте --arch-component или разделите задание"
  fi
  die "режь задачу: $VK > 40000"
fi''')
    taskfile.write_text(task)
    return target
