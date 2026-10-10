#!/usr/bin/env bash
# Клетка И-6б «переход НОСИТЕЛЯ политики — отдельная санкция» (контракт 094,
# арбитраж 094-carrier-krug6 п.5а, Б-5-R5/Б6-R6): toy-база (harness/policy),
# кандидат ДОБАВЛЯЕТ непустой production-носитель registry/ci-steps.tsv (есть
# step-строка). Журнал честен по ДОВЕРЕННОЙ toy-политике (verdict accept,
# check ci-a/ci-b доверенной версии base на дереве merge), строки policy НЕТ —
# разрешению на переход carrier'а взяться неоткуда. Честная дверь отказывает
# именованной фразой ДО движения refs (на prepare — как у субъекта e289d7a5;
# если проверка живёт позже — на publish), main остаётся на base. Дверь БЕЗ
# carrier-симметрии (предшественник e6009c5d, стаб s19) этот сценарий
# публикует — клетка красна: регресс симметрии ловится (Б6-R6).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: perehod-nositelja-bez-sankcii: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world nositelja)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
# оракул в памяти ДО вызова субъекта (правило 8): base/main снимаются заранее
BASE="$(git -C "$R" rev-parse main)"
git -C "$R" checkout -q cand
mkdir -p "$R/registry"
printf 'step\tweak\t-\t:\n' >"$R/registry/ci-steps.tsv"
git -C "$R" add -A && git -C "$R" commit -qm 'add production carrier'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
# кандидат действительно добавил непустой production-носитель (мир не сломан)
[ -n "$(git -C "$R" show "$CAND:registry/ci-steps.tsv" 2>/dev/null)" ] || { printf 'КРАСНО: nositelja: мир сломан — registry/ci-steps.tsv нет в кандидате\n' >&2; exit 1; }
[ -z "$(git -C "$R" show "$BASE:registry/ci-steps.tsv" 2>/dev/null)" ] || { printf 'КРАСНО: nositelja: мир сломан — registry/ci-steps.tsv есть на base\n' >&2; exit 1; }
PHRASE='carrier: registry/ci-steps.tsv добавлен кандидатом к toy-base (требуется отдельная санкция)'

# ── отказ на prepare (честный субъект e289d7a5 отказывает здесь) ─────────────
out="$(bash "$SUBJ" prepare --repo "$R" --task T-9 --base "$BASE" --candidate "$CAND" 2>&1)"; prc=$?
if [ "$prc" -eq 1 ]; then
  printf '%s' "$out" | grep -Fq "$PHRASE" || { printf 'КРАСНО: nositelja: отказ prepare без именованной фразы carrier (rc=1, вывод: %s)\n' "$out" >&2; exit 1; }
  [ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: nositelja: отказ prepare сдвинул main\n' >&2; exit 1; }
  exit 0
fi
[ "$prc" -eq 0 ] || { printf 'КРАСНО: nositelja: prepare rc=%s (вывод: %s)\n' "$prc" "$out" >&2; exit 1; }
M="$out"

# ── prepare прошёл (симметрии нет: e6009c5d / стаб s19) — полный честный ─────
# журнал по toy-политике, строки policy НЕТ: publish обязан отказать той же
# фразой ДО движения refs; публикация = необъявленный переход носителя.
O="$(bash "$SUBJ" object --repo "$R" --task T-9 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J" 1 T-9 "$O" accept
_t94_green "$R" "$BASE" "$J" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R" --task T-9 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf 'КРАСНО: nositelja: переход носителя без санкции опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: nositelja: publish-отказ сдвинул main\n' >&2; exit 1; }
exit 0
