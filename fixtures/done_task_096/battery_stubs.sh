#!/usr/bin/env bash
# Обманный стаб-пак 096 (контракт 096, круг 1, Н-39): пятнадцать порч честной
# модели model/dover.sh, каждая ОДНИМ якорным sed-по-маркеру, каждая привязана
# к клетке, на чьём входе её дефект НАБЛЮДАЕМ (привязка живёт В ЭТОМ КОДЕ,
# не в прозе контракта).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/model/dover.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/done-task-096-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

build_stub() {
  local name="$1"; shift
  local f="$WORK/$name.sh"
  cp "$MODEL" "$f" || return 2
  local e
  for e in "$@"; do
    sed -i "$e" "$f" || return 2
  done
  grep -Fq 'порча' "$f" || return 2
  chmod +x "$f"
  printf '%s' "$f"
}

itog=0
zapest() {
  local name="$1" cell="$2"; shift 2
  local f rc
  f="$(build_stub "$name" "$@")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  DT096_SUBJECT="$f" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 1 ]; then
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s)\n' "$name" "$cell" "$rc" >&2
    itog=1
  fi
}

# Якорь каждого стаба (`# t96-mN$`) указывает на ЖИВУЮ строку проверки той
# инварианты, которую наблюдает парная клетка; порча делает строку no-op (`:`),
# не ломая синтаксис остальной модели. Маркеры m1/m2 исторически стоят на
# нескольких строках (порча группы проверок), m2a обслуживает s7 и s13.
zapest s1 red_priemka_v_kontrakte.sh \
  's@\(.*\)# t96-m1$@: # t96-m1 порча@'
zapest s2 red_zhivoj_izmenjonnyj_put.sh \
  's@\(.*\)# t96-m2$@: # t96-m2 порча@'
zapest s3 red_zony_iz_kontragta.sh \
  's@\(.*\)# t96-m3$@: # t96-m3 порча@'
zapest s4 red_klass_komandy.sh \
  's@\(.*\)# t96-m4$@: # t96-m4 порча@'
zapest s5 red_dokumenty_po_klassu.sh \
  's@\(.*\)# t96-m5$@: # t96-m5 порча@'
zapest s6 red_nahodki_lish_po_predmetu.sh \
  's@\(.*\)# t96-m6 (findings)$@: # t96-m6 findings порча@'
zapest s7 red_realizacija_opublikovana.sh \
  's@\(.*\)# t96-m2a$@: # t96-m2a порча@'
zapest s8 red_issue_i_proektnaya_polya.sh \
  's@\(.*\)# t96-m8$@: # t96-m8 порча@'
zapest s9 red_uchet_raskhoda.sh \
  's@\(.*\)# t96-m9$@: # t96-m9 spend порча@'
zapest s10 red_done_tegi.sh \
  's@\(.*\)# t96-m10$@: # t96-m10 порча@'
zapest s11 red_chistaja_sreda_realnye_komandy.sh \
  's@\(.*\)# t96-m11$@: # t96-m11 порча@'
zapest s12 red_otsutstvujushhaja_komanda_imenovannyj.sh \
  's@\(.*\)# t96-m12$@: # t96-m12 порча@'
zapest s13 red_kodovaya_zadacha_ne_batareja.sh \
  's@\(.*\)# t96-m2a$@: # t96-m13 code-only порча@'
zapest s14 red_teg_bez_issue_ne_polnyj.sh \
  's@\(.*\)# t96-m14$@: # t96-m14 порча@'
zapest s15 red_povtor_dopisyvaet_ostatki.sh \
  's@\(.*\)# t96-m15$@: # t96-m15 порча@'

if [ "$itog" -eq 0 ]; then
  printf -- '— итого: стаб-пак 096 ПОЙМАН целиком (15/15)\n'
fi
exit "$itog"
