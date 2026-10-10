#!/usr/bin/env bash
# Обманный стаб-пак 094 (контракт 094, Н-39): девятнадцать порч честной модели
# model/dover.sh, каждая ОДНИМ-ДВУМЯ якорными sed-по-маркеру, каждая привязана
# к клетке, на чьём входе её дефект НАБЛЮДАЕМ (привязка живёт В ЭТОМ КОДЕ,
# не в прозе контракта). Стаб строится из ТЕКУЩЕЙ модели (копия + порча с
# проверкой якоря: маркер встречается ровно один раз, порча применилась).
# Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО). Все девятнадцать
#
# # стаб | ослабляемая защита | порча (маркер → строка) | ловящая клетка
# s1 чужой accept годится        m1a+m1b  красная_staryj_accept_drugoj_zadachi
# s2 новый отказ игнорируется    m2       красная_novyi_otkaz_perekryvaet
# s3 чужой отказ топит всех      m1a      красная_nahodka_v_kandidate (половина б)
# s4 любое зелёное закрывает     m4       красная_postoronnij_zelenyj_workflow
# s5 сверки базы сняты + CAS     m5a+m5c  красная_baza_ili_kandidat_izmenilsya
# s6 политика из кандидата       m6       красная_oslablenie_politiki_kandidatom
# s7 ветка любая                 m7       красная_nedopustimaja_celevaja_vetka
# s8 stale accept публикует      m1b      красная_otkaz_ne_menjaet_celevuju
# s9 повтор ломает частичный     m9b      красная_povtor_ne_sozdaet_vtoroj_merge
# s10 id без поля merge         m10      красная_obekt_drugoj_sostav (Б1: «семь полей минус merge» — nomerge Замера 1 арбитража)
# s11 скан дерева кандидата снят m11      красная_nahodka_tolko_v_dereve_kandidata (Б2)
# s12 wfsha не сверяется         m12      красная_odnoimennoj_nedoverennyj_workflow (Б3)
# s13 санкция перехода не нужна  m13      красная_perehod_politiki_bez_sankcii (Б4)
# s14 candidate-ref опционален   m5d      красная_baza_ili_kandidat_izmenilsya (Б5)
# s15 сверка дерева снята       m15      красная_proverka_ne_togo_dereva (Б3: «проверили C, записали для M»)
# s16 allowlist зашит литералом    m16       красная_razreshennaja_celevaja_vetka (И-7+: положительная сторона allowlist — политика как данные, не константа)
# s17 пустой mandatory допущен     m17a+m17b красная_pustoj_mandatory (И-0/И-4: вакуумный перечень не публикует)
# s18 пустые CSV-компоненты допущены  m18a+m18b красная_pustoj_csv_element (И-0 verdict v2: хвостая/ведущая/двойная запятая не сокращает перечень молча)
# s19 carrier-симметрия снята       m19c+m19d красная_perehod_nositelja_bez_sankcii (Б6-R6/арбитраж 094-carrier-krug6: асимметрия registry/ci-steps.tsv — переход носителя без санкции policy)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/model/dover.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/accept-publish-094-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'NOT_IMPLEMENTED: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# build_stub <имя> <sed-выражение>… — копия модели, порча с проверкой якоря
build_stub() {
  local name="$1"; shift
  local f="$WORK/$name.sh"
  cp "$MODEL" "$f" || return 2
  local e
  for e in "$@"; do
    local marker="${e%% *}"            # первое слово sed-выражения — не маркер;
    :                                   # якорь проверяется меткой «порча» ниже
    sed -i "$e" "$f" || return 2
  done
  grep -Fq 'порча' "$f" || return 2     # порча применилась (метка в замене)
  chmod +x "$f"
  printf '%s' "$f"
}

itog=0
zapest() {  # <стаб-имя> <клетка-файл> <sed-выражение>…
  local name="$1" cell="$2"; shift 2
  local f rc
  f="$(build_stub "$name" "$@")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  AP094_SUBJECT="$f" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 1 ]; then
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s)\n' "$name" "$cell" "$rc" >&2
    itog=1
  fi
}

zapest s1 red_staryj_accept_drugoj_zadachi.sh \
  's@.*# t94-m1a.*@  [ "$k" = "verdict" ] \|\| continue # t94-m1a порча@' \
  's@.*# t94-m1b.*@best_obj="$oid" # t94-m1b порча@'
zapest s2 red_novyi_otkaz_perekryvaet.sh \
  's@.*# t94-m2.*@: # t94-m2 порча@'
zapest s3 red_nahodka_v_kandidate.sh \
  's@.*# t94-m1a.*@  [ "$k" = "verdict" ] \|\| continue # t94-m1a порча@'
zapest s4 red_postoronnij_zelenyj_workflow.sh \
  's@.*# t94-m4.*@    [ "$k" = "check" ] \|\| continue # t94-m4 порча@'
zapest s5 red_baza_ili_kandidat_izmenilsya.sh \
  's@.*# t94-m5a.*@: # t94-m5a порча@' \
  's@.*# t94-m5c.*@git -C "$REPO" update-ref "refs/heads/$TARGET" "$MERGE" # t94-m5c порча@'
zapest s6 red_oslablenie_politiki_kandidatom.sh \
  's@.*# t94-m6.*@policy_bytes="$(git -C "$REPO" show "$CAND:$POLICY_PATH" 2>/dev/null)" # t94-m6 порча@'
zapest s7 red_nedopustimaja_celevaja_vetka.sh \
  's@.*# t94-m7.*@: # t94-m7 порча@'
zapest s8 red_otkaz_ne_menjaet_celevuju.sh \
  's@.*# t94-m1b.*@best_obj="$oid" # t94-m1b порча@'
zapest s9 red_povtor_ne_sozdaet_vtoroj_merge.sh \
  's@.*# t94-m9b.*@if false; then # t94-m9b порча@'
zapest s10 red_obekt_drugoj_sostav.sh \
  's@.*# t94-m10.*@  printf '"'"'%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n'"'"' "$repoId" "$TASK" "$TARGET" "$BASE" "$CAND" "$policyVersion" | sha256sum | cut -d" " -f1 # t94-m10 порча@'
zapest s11 red_nahodka_tolko_v_dereve_kandidata.sh \
  's@.*# t94-m11.*@  : # t94-m11 порча@'
zapest s12 red_odnoimennoj_nedoverennyj_workflow.sh \
  's@.*# t94-m12.*@  : # t94-m12 порча@'
zapest s13 red_perehod_politiki_bez_sankcii.sh \
  's@.*# t94-m13.*@  grep -Fq "$pol_pat" "$JOURNAL" # t94-m13 порча@'
zapest s14 red_baza_ili_kandidat_izmenilsya.sh \
  's@.*# t94-m5d.*@: # t94-m5d порча@'
zapest s15 red_proverka_ne_togo_dereva.sh \
  's@.*# t94-m15.*@  : # t94-m15 порча@'
zapest s16 red_razreshennaja_celevaja_vetka.sh \
  's@.*# t94-m16.*@    targetBranches=*) v="${line#targetBranches=}"; case "$v" in *[!A-Za-z0-9._/,:-]*) die "политика: грамматика" ;; esac; branches="main" ;; # t94-m16 порча@'
zapest s17 red_pustoj_mandatory.sh \
  's@.*# t94-m17a.*@    mandatory=*) v="${line#mandatory=}"; case "$v" in *[!A-Za-z0-9._,:-]*) die "политика: грамматика" ;; esac; mandatory="$v" ;; # t94-m17a порча@' \
  's@.*# t94-m17b.*@[ -n "$repoId" ] \&\& [ -n "$branches" ] || die "политика: грамматика" # t94-m17b порча@'
zapest s18 red_pustoj_csv_element.sh \
  's@.*# t94-m18a.*@: # t94-m18a порча@' \
  's@.*# t94-m18b.*@: # t94-m18b порча@'
zapest s19 red_perehod_nositelja_bez_sankcii.sh \
  's@.*# t94-m19c.*@  : # t94-m19c порча@' \
  's@.*# t94-m19d.*@  : # t94-m19d порча@'

printf 'ИТОГ стаб-пак 094: rc=%s\n' "$itog"
exit "$itog"
