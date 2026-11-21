#!/usr/bin/env bash
# Б-10: публичная дверь и управляемый rc её CI-сотрудника; остальные ноги настоящие.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$HERE/_toy.sh"
CELL="${1:?cell}"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/pg_b10.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
WORK="$TMP/root"
mkdir -p "$WORK" "$TMP/scripts"
mk_toy_repo "$WORK"
put_draft "$WORK/contracts/043-toy-draft.md" 'ЗОНА architect: contracts/043-toy-draft.md'
SOURCE="${BARRIER:-$SUBJ}"
# Снимок субъекта: подмена только внешнего verify_ci_parity, не тела двери.
cp "$SOURCE" "$TMP/scripts/check_precision_gate.sh"
for f in "$REPO"/scripts/*; do
  case "${f##*/}" in check_precision_gate.sh|verify_ci_parity.sh) continue ;; esac
  ln -s "$f" "$TMP/scripts/${f##*/}"
done
FIRST='  FAIL parity fixture: first reason'
SECOND="  FAIL $WORK/.github/workflows/toy.yml:9: synthetic parity mismatch"
EXPECTED_WARNING="ПРЕДУПРЕЖДЕНИЕ: паритет CI красен (verify_ci_parity.sh rc 1): $FIRST"
PARITY_RC=1
write_parity() {
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" %q %q\nexit %s\n' "$FIRST" "$SECOND" "$PARITY_RC" > "$TMP/scripts/verify_ci_parity.sh"
}
write_debt() {
  mkdir -p "$WORK/.harness/registry"
  printf '%s\n' "$@" > "$WORK/.harness/registry/ci_parity_debt.txt"
}
ERR=''; OUT=''; RC=0; BAD=0
run() {
  RC=0
  OUT="$(bash "$TMP/scripts/check_precision_gate.sh" "$WORK" contracts/043-toy-draft.md 2>"$TMP/stderr")" || RC=$?
  ERR="$(cat "$TMP/stderr")"
  printf 'OBS %s gate_rc=%s\n' "$CELL" "$RC" >&2
}
fail() { printf 'ОТКАЗ Б-10 %s: %s; rc=%s stdout=<%s> stderr=<%s>\n' "$CELL" "$*" "$RC" "$OUT" "$ERR" >&2; BAD=1; }
warning_accept() {
  [ "$RC" -eq 0 ] || fail 'ожидался rc 0'
  [ "$OUT" = OK ] || fail 'stdout должен быть ровно OK'
  [ "$ERR" = "$EXPECTED_WARNING" ] || fail 'stderr должен быть ровно одной строкой предупреждения с первой причиной'
}
write_parity
case "$CELL" in
  a)
    run; warning_accept
    # Дополнительно настоящий verify_ci_parity на осиротевшем npm-скрипте.
    printf '{"name":"toy","scripts":{"orphan-b10":"true"}}\n' > "$WORK/package.json"
    ORACLE_RC=0
    ORACLE="$(bash "$REPO/scripts/verify_ci_parity.sh" "$WORK" 2>&1)" || ORACLE_RC=$?
    [ "$ORACLE_RC" -eq 1 ] || { fail "невалидный живой вход parity rc=$ORACLE_RC"; exit 1; }
    FIRST="${ORACLE%%$'\n'*}"
    EXPECTED_WARNING="ПРЕДУПРЕЖДЕНИЕ: паритет CI красен (verify_ci_parity.sh rc 1): $FIRST"
    cp "$REPO/scripts/verify_ci_parity.sh" "$TMP/scripts/verify_ci_parity.sh"
    run; warning_accept
    # Явные ошибки инструмента тоже не превращаются в предупреждение.
    # База здесь rc 1 (не заявленный в задании «прежний rc 2»); цель — rc 2.
    for PARITY_RC in 2 3; do
      write_parity
      run
      [ "$RC" -eq 2 ] && [ -z "$OUT" ] || fail "parity rc $PARITY_RC должен дать skip rc 2"
      case "$ERR" in NOT_IMPLEMENTED:*) ;; *) fail "parity rc $PARITY_RC: нет именованного skip" ;; esac
      case "$ERR" in *ПРЕДУПРЕЖДЕНИЕ*) fail "parity rc $PARITY_RC не предупреждение" ;; esac
    done
    ;;
  b)
    write_debt "ДО: $(date -u -d yesterday +%F)" '.github/workflows/toy.yml:9: synthetic parity mismatch'
    run; warning_accept
    ;;
  c)
    write_debt "ДО: $(date -u -d tomorrow +%F)" '.github/workflows/toy.yml:9: synthetic parity mismatch'
    run; warning_accept
    ;;
  g)
    # Каждый вариант предъявляется независимо: первый отказ не скрывает остальные.
    for variant in no-date garbage new-mismatch; do
      case "$variant" in
        no-date) write_debt '.github/workflows/toy.yml:9: synthetic parity mismatch' ;;
        garbage) write_debt 'ДО: not-a-date' 'garbage' ;;
        new-mismatch) write_debt "ДО: $(date -u -d tomorrow +%F)" '.github/workflows/other.yml:9: unrelated mismatch' ;;
      esac
      run; warning_accept
    done
    ;;
  d)
    PARITY_RC=0; write_parity
    run
    [ "$RC" -eq 0 ] && [ "$OUT" = OK ] && [ -z "$ERR" ] || fail 'зелёный паритет: rc 0, OK, пустой stderr'
    ;;
  e)
    rm "$TMP/scripts/verify_ci_parity.sh"
    run
    [ "$RC" -eq 2 ] && [ -z "$OUT" ] && [ "$ERR" = 'NOT_IMPLEMENTED: precision-гейт 043: scripts/verify_ci_parity.sh не существует' ] || fail 'отсутствующий parity обязан дать именованный skip rc 2'
    ;;
  zh)
    mk_foreign_frozen "$WORK" 999 otherauthor shared/thing.txt
    put_draft "$WORK/contracts/043-toy-draft.md" 'ЗОНА architect: contracts/043-toy-draft.md shared/thing.txt'
    run
    EXPECTED='precision-гейт 043: зона-коллизия: shared/thing.txt заявлен architect (этот контракт, NNN 043), уже в union под NNN 999 для otherauthor — нужна строка ПЕРЕСЕЧЕНИЕ architect: shared/thing.txt — 999 <причина>'
    [ "$RC" -eq 1 ] && [ -z "$OUT" ] && [ "$ERR" = "$EXPECTED" ] || fail 'паритет не маскирует первую красную ногу (а)'
    ;;
  z)
    write_debt 'ДО: 2026-11-25' '.github/workflows/toy.yml:9: synthetic parity mismatch'
    # PATH двери фиксирован. BASH_ENV подставляет только date, не изменяя дверь.
    printf 'date() { if [ "$*" = "-u +%%F" ]; then printf "2026-11-27\\n"; else /usr/bin/date "$@"; fi; }\n' > "$TMP/calendar.sh"
    export BASH_ENV="$TMP/calendar.sh"
    [ "$(bash -c 'date -u +%F')" = 2026-11-27 ] || { fail 'календарь не установлен'; exit 1; }
    run; warning_accept
    ;;
  i)
    # Дословная Fable-проба; судит выбранного субъекта, а не всегда исходный файл.
    if grep -n 'долг паритета просрочен' "$SOURCE"; then fail 'в субъекте осталась просрочка долга'; fi
    ;;
  *) fail 'неизвестная клетка' ;;
esac
exit "$BAD"
