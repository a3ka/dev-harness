#!/usr/bin/env bash
# Клетка А-1 «кандидат не выбирает собственную политику на подготовке»
# (контракт 097, сценарий 6 нарезки 094 на этапе подготовки). Профиль харнеса:
# кандидат УДАЛИЛ step-строку из registry/ci-steps.tsv и РАСШИРИЛ
# targetBranches в СВОЁМ дереве (оба значения конформны И-0) — честная
# подготовка судит по ПРИНЯТОЙ версии base: перечень mandatory и allowlist
# объекта берутся из base; prepare этого конформного входа — rc 0 (сверен ДО
# приёма stdout: подмена rc успешной подготовки при РАЗНЫХ политиках base и
# кандидата — вердикт адверсария v3 А-1, стаб t97-m20). Обман t97-m1
# (политика читается из кандидата) даёт id по кандидатной версии — клетка
# красна.
# Real-режим дополнительно требует именованный отказ на УДАЛЕНИЕ носителя
# политики кандидатом («carrier: registry/ci-steps.tsv удалён кандидатом…»);
# модель dover.sh — грамматика CLI, этой семантики не несёт — проба
# исполняется ТОЛЬКО против реального субъекта (AP097_MODE=real).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: kandidat-ne-vybiraet-politiku: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }
MODE="$(_t97_mode)"

W="$(_t97_world_harness a1)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"
BASE="$(git -C "$R" rev-parse main)"
MAIN_BEFORE="$(git -C "$R" rev-parse refs/heads/main)"

# кандидат: сужает реестр (удаляет step ci-b) и расширяет allowlist в СВОЁМ дереве
git -C "$R" checkout -q cand
printf '# toy-реестр шагов (семья 097)\nstep ci-a 1 bash true\n' >"$R/registry/ci-steps.tsv"
printf '{\n  "repoId": "toy-harness-097",\n  "targetBranches": ["main", "cand"]\n}\n' >"$R/harness.project.json"
_t97_regen "$R"
git -C "$R" add -A && git -C "$R" commit -qm 'candidate narrows registry and widens branches'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"

# оракул в памяти ДО вызова субъекта (правило 8): id по base и по кандидату
MERGE="$(_t97_merge "$R" "$BASE" "$CAND" a1)" || { printf 'КРАСНО: a1: оракул merge не строится\n' >&2; exit 1; }
OID_BASE="$(_t97_expected_id "$R" "$BASE" T-97 main "$BASE" "$CAND" "$MERGE")"
OID_CAND="$(_t97_expected_id "$R" "$CAND" T-97 main "$BASE" "$CAND" "$MERGE")"
[ "$OID_BASE" != "$OID_CAND" ] || { printf 'КРАСНО: a1: мир не различает политики base и кандидата\n' >&2; exit 1; }

_t97_refs_arm "$R" || exit 2
refs_before="$(_t97_refs_snap "$R")" || exit 2
out="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
_t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
[ "$rc" -eq 0 ] || { printf 'КРАСНО: a1: успешный prepare конформного входа (политики base и кандидата различны) вернул rc=%s — rc-подмена подготовки (стаб m20; вывод=%s)\n' "$rc" "$out" >&2; exit 1; }
case "$out" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a1: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$out" >&2; exit 1 ;; esac
[ "${#out}" -eq 40 ] || { printf 'КРАСНО: a1: prepare напечатал не 40 hex: %s\n' "$out" >&2; exit 1; }

oid="$(bash "$SUBJ" object --repo "$R" --task T-97 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
[ "$oid" = "$OID_BASE" ] || {
  printf 'КРАСНО: a1: кандидат сам выбрал политику — id по кандидатной версии (oid=%s, ждали по base=%s)\n' "$oid" "$OID_BASE" >&2; exit 1; }

[ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || { printf 'КРАСНО: a1: prepare сдвинул main\n' >&2; exit 1; }

# real-режим: носитель политики, удалённый кандидатом, — именованный отказ
if [ "$MODE" = real ]; then
  git -C "$R" checkout -q cand
  git -C "$R" rm -q registry/ci-steps.tsv
  git -C "$R" commit -qm 'candidate deletes policy carrier'
  CAND2="$(git -C "$R" rev-parse cand)"
  git -C "$R" checkout -q main
  _t97_refs_arm "$R" || exit 2
  refs_before="$(_t97_refs_snap "$R")" || exit 2
  o="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND2" 2>&1)"; rc=$?
  _t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
  { [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'carrier: registry/ci-steps.tsv удалён кандидатом'; } || {
    printf 'КРАСНО: a1: удаление носителя политики кандидатом не отказано именованно (rc=%s, вывод=%s)\n' "$rc" "$o" >&2; exit 1; }
  [ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || { printf 'КРАСНО: a1: отказ сдвинул main\n' >&2; exit 1; }
fi
exit 0
