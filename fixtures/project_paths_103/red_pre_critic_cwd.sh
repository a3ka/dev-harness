#!/usr/bin/env bash
# Клетка И-2 «pre_critic на проектном репо не зависит от cwd» (контракт 103).
# Вход: `pre_critic.sh --repo <R> tasks/h/777-toy.md` (путь контракта — от
# корня ПРОЕКТА по workflowPaths.contracts, не от корня харнеса). Три cwd:
# корень проекта, подкаталог проекта, посторонний каталог /tmp/dev-harness-verify.
# Тогда: (а) полный контракт — rc 0 из всех трёх cwd; (б) контракт без
# КОНТЕКСТ:-строк — rc 1 из всех трёх cwd и первая строка stderr побайтово
# одинакова. Обман (путь от cwd) → из постороннего cwd «не найден» (rc 2) → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_pre_critic)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pre-critic-cwd: предмет отсутствует: scripts/pre_critic.sh\n' >&2; exit 1; }
W="$(_t103_world i2)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
mkdir -p "$W/vne"
_t103_contract "$R/tasks/h/778-bez.md" 778
sed -i '/^КОНТЕКСТ:/d' "$R/tasks/h/778-bez.md"
git -C "$R" add -A; git -C "$R" commit -qm 'контракт без формы'

run() {  # <cwd> <контракт> → печатает "rc<TAB>первая строка stderr"
  local rc err
  err="$(cd "$1" && bash "$SUBJ" --repo "$R" "$2" 2>&1 >/dev/null)"; rc=$?
  printf '%s\t%s' "$rc" "$(printf '%s\n' "$err" | head -n 1)"
}
for cwd in "$R" "$R/tasks" "$W/vne"; do
  res="$(run "$cwd" tasks/h/777-toy.md)"; rc="${res%%	*}"
  if [ "$rc" -ne 0 ]; then
    printf 'КРАСНО: i2: полный контракт из cwd=%s: rc=%s (ждали 0): %s\n' "$cwd" "$rc" "${res#*	}" >&2; exit 1
  fi
done
ref="$(run "$R" tasks/h/778-bez.md)"
[ "${ref%%	*}" = "1" ] || { printf 'КРАСНО: i2: контракт без КОНТЕКСТ: из корня проекта rc=%s (ждали 1): %s\n' "${ref%%	*}" "${ref#*	}" >&2; exit 1; }
printf '%s\n' "${ref#*	}" | grep -Fq 'форма' || { printf 'КРАСНО: i2: отказ формы без слова «форма»: %s\n' "${ref#*	}" >&2; exit 1; }
for cwd in "$R/tasks" "$W/vne"; do
  res="$(run "$cwd" tasks/h/778-bez.md)"
  if [ "$res" != "$ref" ]; then
    printf 'КРАСНО: i2: вердикт зависит от cwd=%s\n--- корень: %s\n--- здесь:  %s\n' "$cwd" "$ref" "$res" >&2; exit 1
  fi
done
exit 0
