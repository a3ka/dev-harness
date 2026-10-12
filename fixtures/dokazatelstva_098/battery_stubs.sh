#!/usr/bin/env bash
# Обманный стаб-пак 098 (контракт 098, Н-39/А-398): четырнадцать порч честных
# моделей model/{judge_gate,check_ci_gate,accept_publish}.sh, каждая ОДНИМ
# якорным sed-по-маркеру (# t98-mN), каждая привязана к клетке, на чьём входе
# её дефект НАБЛЮДАЕМ (привязка живёт В ЭТОМ КОДЕ, не в прозе контракта).
# Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО) — ТОЛЬКО rc 1
# (А-398: rc 0 и rc 2 — НЕ пойман, rc 2 помечается «поимка пустая»); порча
# режет МЕХАНИЗМ свойства, не условие ветвления; якорь обязан встречаться в
# модели РОВНО один раз (стаб против несуществующего якоря не строится).
#
# # стаб | ослабляемая защита | маркер | ловящая клетка
# s1 verdict-off (строку не пишет)      mV1  red_polnyj_zhurnal_shtatno
# s2 check-off (строку не пишет)         mC1  red_polnyj_zhurnal_shtatno
# s3 policy-off (строку не пишет)        mP1  red_polnyj_zhurnal_shtatno
# s4 подстрочное имя закрывает ключ      mC2  red_postoronnij_zelenyj_ne_zakryvaet
# s5 «M на origin/main» вернулось        mC3  red_polnyj_zhurnal_shtatno
# s6 зелёный CI = accept (событие игн.)  mV2  red_pozdnij_fail
# s7 запись журнала без флага            mV3  red_semantika_008_bez_flaga
# s8 prepare двигает main кандидата      mD5  red_zhurnal_vne_vetvi
# s9 publish ставит ветку на CAND        mD1  red_dver_publikuet_rovno_M
# s10 сверка дерева снята                mD2  red_chuzhoe_derevo_opredelenie
# s11 сверка версии определения снята    mD3  red_chuzhoe_derevo_opredelenie
# s12 любое имя закрывает любой ключ     mD4  red_otstutvujushaja_objazatelnaja
# s13 wfsha из локальной доски (обход
#    критика круга 2: происхождение не
#    сверяется с ответом CI)             mC4  red_odnoimennoj_chuzhoj_workflow
# s14 сверка исполнителя (ciApp) снята   mC5  red_odnoimennoj_chuzhoj_workflow
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELDIR="$HERE/model"
[ -d "$MODELDIR" ] || { printf 'NOT_IMPLEMENTED: нет моделей %s\n' "$MODELDIR" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v grep >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет grep\n' >&2; exit 2; }
command -v sed >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sed\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/dokazatelstva-098-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# build_stub <маркер> <sed-выражение>… — копия модели-носителя маркера, порча
# с двойной проверкой: якорь встречается в источнике РОВНО один раз (А-398),
# порча применилась (метка «порча» в файле)
build_stub() {
  local marker="$1"; shift
  local src="" f n e
  for f in judge_gate.sh check_ci_gate.sh accept_publish.sh; do
    n="$(grep -cF "# $marker" "$MODELDIR/$f" 2>/dev/null)" || n=0
    if [ "${n:-0}" -ge 1 ]; then src="$MODELDIR/$f"; break; fi
  done
  [ -n "$src" ] || { printf 'ОТКАЗ: якорь %s не найден ни в одной модели\n' "$marker" >&2; return 2; }
  local total=0 m g
  for g in judge_gate.sh check_ci_gate.sh accept_publish.sh; do
    m="$(grep -cF "# $marker" "$MODELDIR/$g" 2>/dev/null)" || m=0
    total=$(( total + m ))
  done
  [ "$total" -eq 1 ] || { printf 'ОТКАЗ: якорь %s встречается %s раз(а) по всем моделям (не 1)\n' "$marker" "$total" >&2; return 2; }
  local out="$WORK/$marker.sh"
  cp "$src" "$out" || return 2
  for e in "$@"; do sed -i "$e" "$out" || return 2; done
  grep -Fq 'порча' "$out" || return 2
  chmod +x "$out"
  printf '%s %s' "$out" "${src##*/}"
}

itog=0
zapest() {  # <стаб-имя> <клетка-файл> <маркер> <sed-выражение>…
  local name="$1" cell="$2" marker="$3"; shift 3
  local res f stub carrier sd rc
  res="$(build_stub "$marker" "$@")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  stub="${res%% *}"; carrier="${res##* }"
  sd="$WORK/sd-$name"; mkdir -p "$sd"
  cp "$MODELDIR"/judge_gate.sh "$MODELDIR"/check_ci_gate.sh "$MODELDIR"/accept_publish.sh "$sd"/
  cp "$stub" "$sd/$carrier"
  D98_SUBJECTS_DIR="$sd" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 1 ]; then
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s%s)\n' "$name" "$cell" "$rc" \
      "$([ "$rc" -eq 2 ] && printf ' — поимка пустая, не засчитана (А-398)')" >&2
    itog=1
  fi
}

zapest s1 red_polnyj_zhurnal_shtatno.sh t98-mV1 \
  's@.*# t98-mV1.*@: # t98-mV1 порча@'
zapest s2 red_polnyj_zhurnal_shtatno.sh t98-mC1 \
  's@.*# t98-mC1.*@: # t98-mC1 порча@'
zapest s3 red_polnyj_zhurnal_shtatno.sh t98-mP1 \
  's@.*# t98-mP1.*@: # t98-mP1 порча@'
zapest s4 red_postoronnij_zelenyj_ne_zakryvaet.sh t98-mC2 \
  's@.*# t98-mC2.*@best="$(printf '"'"'%s'"'"' "$body" | jq -c --arg k "$KEY" '"'"'[.check_runs[] | select(.name | contains($k))] | sort_by(.id) | last'"'"' 2>/dev/null)" # t98-mC2 порча@'
zapest s5 red_polnyj_zhurnal_shtatno.sh t98-mC3 \
  's@.*# t98-mC3.*@mtree="$(git -C "$ROOT" rev-parse --verify --quiet "$MSHA^{tree}")"; git -C "$ROOT" merge-base --is-ancestor "$MSHA" refs/remotes/origin/main || { printf '"'"'ОТКАЗ: коммит не на origin/main\n'"'"' >&2; exit 1; } # t98-mC3 порча@'
zapest s6 red_pozdnij_fail.sh t98-mV2 \
  's@.*# t98-mV2.*@sod="accept" # t98-mV2 порча@'
zapest s7 red_semantika_008_bez_flaga.sh t98-mV3 \
  's@.*# t98-mV3.*@printf '"'"'verdict\tT-098\t%s\taccept\t999\n'"'"' "$(printf poddelka | sha256sum | cut -d" " -f1)" >>"$JOURNAL"; rc=0 # t98-mV3 порча@'
zapest s8 red_zhurnal_vne_vetvi.sh t98-mD5 \
  's@.*# t98-mD5.*@printf '"'"'%s\n'"'"' "$m"; git -C "$REPO" update-ref refs/heads/main "$m" # t98-mD5 порча@'
zapest s9 red_dver_publikuet_rovno_M.sh t98-mD1 \
  's@.*# t98-mD1.*@git -C "$REPO" update-ref "refs/heads/$TARGET" "$CAND" "$BASE" # t98-mD1 порча@'
zapest s10 red_chuzhoe_derevo_opredelenie.sh t98-mD2 \
  's@.*# t98-mD2.*@: # t98-mD2 порча@'
zapest s11 red_chuzhoe_derevo_opredelenie.sh t98-mD3 \
  's@.*# t98-mD3.*@: # t98-mD3 порча@'
zapest s12 red_otstutvujushaja_objazatelnaja.sh t98-mD4 \
  's@.*# t98-mD4.*@: # t98-mD4 порча@'
zapest s13 red_odnoimennoj_chuzhoj_workflow.sh t98-mC4 \
  's@.*# t98-mC4.*@wfr="$wfsha" # t98-mC4 порча@'
zapest s14 red_odnoimennoj_chuzhoj_workflow.sh t98-mC5 \
  's@.*# t98-mC5.*@: # t98-mC5 порча@'

printf 'ИТОГ стаб-пак 098: rc=%s\n' "$itog"
exit "$itog"
