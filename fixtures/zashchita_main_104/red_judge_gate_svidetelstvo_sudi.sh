#!/usr/bin/env bash
# Клетка red_judge_gate_svidetelstvo_sudi — инвариант И-6 контракта 104:
# потребитель двери — писатель verdict-строки scripts/judge_gate.sh
# `<sha> --verdict-row <задача> <object_id> <вердикт-файл> --sud <роль> <трасса> <session>`:
# ДО записи строки зовёт соседний check_sud_model.sh
# `--verdict <роль> --trace <трасса> --object <sha> --session <session>`; rc≠0
# двери → строка НЕ пишется, rc 1 с причиной двери; без тройки --sud → rc 1
# «свидетельство судьи не передано» (не bootstrap-пропуск). Мир: toy-корень
# <мир>/root со scripts/judge_gate.sh (субъект, копия) и scripts/check_sud_model.sh
# — СТЕНД клетки, пишущий свой argv в файл и возвращающий код из Z104_STEND_RC
# (оракул поведения двери — у клетки в памяти; судится ПРОВОДКА потребителя, не дверь).
# Входы:
#   (1) 5-арг форма 098 (без --sud) → rc 1 «свидетельство судьи не передано», журнал без строки;
#   (2) стенд rc 1 → judge_gate rc 1, журнал без строки, stderr несёт причину стенда;
#   (3) стенд rc 0 → rc 0, строка verdict в журнале, argv стенда ТОЧНО
#       «--verdict critic --trace <T> --object <sha> --session <S>» (порядок/значения литерально);
#   (4) стенд rc 2 → judge_gate rc 2, журнал без строки.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-jg-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SUBJ="$(z104_subject judge_gate.sh)"; then
  printf 'КРАСНО: red_judge_gate_svidetelstvo_sudi: предмет отсутствует: scripts/judge_gate.sh\n' >&2; exit 1
fi
R="$W/root"; mkdir -p "$R/scripts" "$R/registry"
cp "$SUBJ" "$R/scripts/judge_gate.sh"
cat > "$R/scripts/check_sud_model.sh" <<'EOF'
#!/usr/bin/env bash
# стенд двери: argv → файл, код — из окружения
printf '%s\n' "$*" > "$Z104_STEND_ARGV"
if [ "${Z104_STEND_RC}" != 0 ]; then printf 'ОТКАЗ: стенд: вердикт не материализуется (toy)\n' >&2; fi
exit "${Z104_STEND_RC}"
EOF
chmod +x "$R/scripts/"*.sh
J="$R/registry/candidates.tsv"; : > "$J"
VF="$W/verdict.md"; printf 'accept\nтело\n' > "$VF"
T="$W/trace.tsv"; printf 'critic\topenai-codex/gpt-6-astra\tallowed\tS1\tO1\n' > "$T"
SHA='22cb801bb0ede34ee992a76bac5aa7eb72d99112'
OID='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
S='01a13b69-2bf2-7147-9f08-2d06d3b11bd0'
export Z104_STEND_ARGV="$W/argv.txt"

# Оракул в памяти ДО вызова (правило 8)
w1='свидетельство судьи не передано'
w2='вердикт не материализуется'
want_argv="--verdict critic --trace $T --object $SHA --session $S"
fail() { printf 'КРАСНО: red_judge_gate_svidetelstvo_sudi: вход %s: %s; факт rc=%s, вывод: %s\n' "$1" "$2" "$3" "$(printf '%s' "$4" | head -c 220)" >&2; exit 1; }
rows() { grep -c '^verdict' "$J"; }

: > "$Z104_STEND_ARGV"
out="$(Z104_STEND_RC=0 bash "$R/scripts/judge_gate.sh" "$SHA" --verdict-row t104 "$OID" "$VF" 2>&1)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w1" && [ "$(rows)" -eq 0 ]; } || fail 1 "ожидался rc 1 «$w1», журнал пуст" "$rc" "$out"

out="$(Z104_STEND_RC=1 bash "$R/scripts/judge_gate.sh" "$SHA" --verdict-row t104 "$OID" "$VF" --sud critic "$T" "$S" 2>&1)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w2" && [ "$(rows)" -eq 0 ]; } || fail 2 "ожидался rc 1 с причиной двери, журнал пуст" "$rc" "$out"

: > "$Z104_STEND_ARGV"
out="$(Z104_STEND_RC=0 bash "$R/scripts/judge_gate.sh" "$SHA" --verdict-row t104 "$OID" "$VF" --sud critic "$T" "$S" 2>&1)"; rc=$?
{ [ "$rc" -eq 0 ] && [ "$(rows)" -eq 1 ]; } || fail 3 'ожидался rc 0 и одна verdict-строка' "$rc" "$out"
got_argv="$(cat "$Z104_STEND_ARGV")"
[ "$got_argv" = "$want_argv" ] || fail 3 "argv двери ≠ «$want_argv»" "$rc" "$got_argv"

out="$(Z104_STEND_RC=2 bash "$R/scripts/judge_gate.sh" "$SHA" --verdict-row t104 "$OID" "$VF" --sud critic "$T" "$S" 2>&1)"; rc=$?
{ [ "$rc" -eq 2 ] && [ "$(rows)" -eq 1 ]; } || fail 4 'ожидался rc 2 без новой строки' "$rc" "$out"

printf 'ЗЕЛЕНО: red_judge_gate_svidetelstvo_sudi\n'
exit 0
