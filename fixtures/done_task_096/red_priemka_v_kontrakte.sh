#!/usr/bin/env bash
# Клетка И-1 «связь критериев issue с приёмкой — контракт обязан иметь секцию
# ## Приёмка, иначе нет связи критериев с приёмкой» (контракт 096, П-1).
# Половина (а): контракт на диске и на HEAD без `## Приёмка` → отказ «нет
# приёмки в контракте». Половина (б): контракта вообще нет на диске → отказ
# «нет контракта на диске». Обман: m1 «контракт не закоммичен» закрыт
# поведением helper'а; стуб s1 ловит «## Приёмка» как свободный заголовок.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: priemka-v-kontrakte: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): контракт без `## Приёмка` → отказ ──────────────────────────
W1="$(_t96_world i1a)" || exit 2
trap '_t96_cleanup "$W1"' EXIT
R1="$W1/repo"
git -C "$R1" checkout -q cand
# Зачищаем секцию ## Приёмка
sed -i '/^## Приёмка$/d' "$R1/contracts/096-toy.md"
git -C "$R1" add -A && git -C "$R1" commit -qm 'no priemka'
HEAD1="$(git -C "$R1" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R1" --task 96 --class code --project-id toy \
  --object-id "$(printf '%064d' 1)" --commit-sha "$HEAD1" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Eq 'нет приёмки|приёмки в контракте'; then
  printf 'КРАСНО: i1a: нет приёмки не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W1"

# ── половина (б): контракта нет на диске → отказ ─────────────────────────────
W2="$(_t96_world i1b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
rm -f "$R2/contracts/096-toy.md"
git -C "$R2" add -A && git -C "$R2" commit -qm 'no contract file' 2>/dev/null || true
HEAD2="$(git -C "$R2" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --object-id "$(printf '%064d' 1)" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Eq 'нет контракта|нет приёмки|контракта на'; then
  printf 'КРАСНО: i1b: нет контракта не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
