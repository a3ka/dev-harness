#!/usr/bin/env bash
# Обманный стаб-пак 095 (контракт 095, круг 2, Н-39): восемнадцать порч честных
# моделей (dover.sh — сборщик, dver_spawn.sh — дверь), каждая ОДНОЙ якорной
# sed-по-маркеру, каждая привязана к клетке, на чьём входе её дефект НАБЛЮДАЕМ
# (привязка живёт В ЭТОМ КОДЕ, не в прозе контракта). Стаб строится из ТЕКУЩЕЙ
# модели (копия + порча с проверкой якоря: маркер встречается в модели ровно
# один раз, порча применилась). Пойман = связанная клетка против стаба даёт
# rc 1 (КРАСНО).
#
# # стаб | ослабляемая защита | маркер | ловящая клетка
# s1  харнесовские правила вклеены   m1   red_pravila_proekta_ne_harsa.sh
# s2  манифест не строится           m2   red_manifest_razreshaetsja.sh
# s3  mandatory-проверка снята       m3   red_poteryannaja_ssylka_tochna.sh
# s4  матрица скилов не по роли      m4   red_roli_menjajut_vydachu.sh
# s5  зоны из черновика              m5   red_zony_iz_frozen_blobs.sh
# s6  implementer без заморозки      m6   red_rezhim_do_zamorozki.sh
# s7  задание пересобрано            m7   red_revjer_poluchaet_vydannoe.sh
# s8  свидетельство подменено        m8   red_svidetelstvo_modeli.sh
# s9  бюджет не считается            m9   red_bjudzhet_vklejki.sh
# s10 фильтр области уроков снят     m10  red_uroki_po_oblasti.sh
# s11 происхождение всегда frozen    m11  red_proishozhdenie_fragmentov.sh
# s12 брифинг = задачный пак         m12  red_orch_brief_starter.sh
# s13 §Существующее не доставлено    m13  red_kontekst_doslovno.sh
# s14 слой проекта игнорируется      m14  red_profil_dva_sloja.sh
# s15 нога манифеста снята с двери   m15  red_dver_spawn_manifest.sh
# s16 статус-фильтр ADR снят         m16  red_uroki_po_oblasti.sh
# s17 семейство судьи не сверяется   m17  red_revjer_poluchaet_vydannoe.sh
# s18 содержание брифа вынуто        m18  red_orch_brief_starter.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/model/dover.sh"
DOOR_MODEL="$HERE/model/dver_spawn.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
[ -f "$DOOR_MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$DOOR_MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/context-pack-095-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# build_stub <источник> <имя> <маркер> <sed-выражение> — копия модели, порча с
# проверкой: маркер в источнике ровно один раз, порча применилась (метка «порча»).
build_stub() {
  local src="$1" name="$2" marker="$3" expr="$4" f n
  n="$(grep -Ec "# ${marker}([^0-9]|$)" "$src")" || n=0
  [ "$n" -eq 1 ] || { printf 'ОТКАЗ: маркер %s встречается %s раз в %s\n' "$marker" "$n" "$src" >&2; return 2; }
  f="$WORK/$name.sh"
  cp "$src" "$f" || return 2
  sed -i "$expr" "$f" || return 2
  grep -Fq 'порча' "$f" || return 2
  chmod +x "$f"
  printf '%s' "$f"
}

itog=0
zapest() {  # <стаб-имя> <маркер> <клетка-файл> <sed-выражение> [<источник>]
  local name="$1" marker="$2" cell="$3" expr="$4" src="${5:-$MODEL}" f rc
  f="$(build_stub "$src" "$name" "$marker" "$expr")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  if [ "$src" = "$DOOR_MODEL" ]; then
    CP095_SPAWN="$f" CP095_SUBJECT="$MODEL" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  else
    CP095_SUBJECT="$f" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  fi
  if [ "$rc" -eq 1 ]; then
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s)\n' "$name" "$cell" "$rc" >&2
    itog=1
  fi
}

zapest s1 t95-m1 red_pravila_proekta_ne_harsa.sh \
  's@.*# t95-m1.*@RULES_LINES="$(printf "RULES: AGENTS.md\\nRULES: CODING-STANDARDS.md\\n")$RULES_LINES" # t95-m1 порча@'
zapest s2 t95-m2 red_manifest_razreshaetsja.sh \
  's@.*# t95-m2.*@: # t95-m2 порча@'
zapest s3 t95-m3 red_poteryannaja_ssylka_tochna.sh \
  's@.*# t95-m3.*@  : # t95-m3 порча@'
zapest s4 t95-m4 red_roli_menjajut_vydachu.sh \
  's@.*# t95-m4.*@" ;; SKILLS="$SKILLS$(printf "SKILL: grilling\\n")" # t95-m4 порча@'
zapest s5 t95-m5 red_zony_iz_frozen_blobs.sh \
  "s@.*# t95-m5.*@ZONES_SEC=\"\$(grep \"^ЗОНА \" \"\$REPO/\$CPATH\" 2>/dev/null || true)\" # t95-m5 порча@"
zapest s6 t95-m6 red_rezhim_do_zamorozki.sh \
  's@.*# t95-m6.*@  : # t95-m6 порча@'
zapest s7 t95-m7 red_revjer_poluchaet_vydannoe.sh \
  's@.*# t95-m7.*@TASK_BYTES="$(printf "Задание toy: сделай очень хорошо.\\n")" # t95-m7 порча@'
zapest s8 t95-m8 red_svidetelstvo_modeli.sh \
  's@.*# t95-m8.*@  if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=fake-model fallback=allowed"; fi # t95-m8 порча@'
zapest s9 t95-m9 red_bjudzhet_vklejki.sh \
  's@.*# t95-m9.*@: # t95-m9 порча@'
zapest s10 t95-m10 red_uroki_po_oblasti.sh \
  's@.*# t95-m10.*@      for zp in $ZONE_PATHS; do case "$zp" in *) m=1 ;; esac; done # t95-m10 порча@'
zapest s11 t95-m11 red_proishozhdenie_fragmentov.sh \
  's@.*# t95-m11.*@" CTX_MAN="$(printf "context\\t%s\\tmandatory\\tfrozen\\nzones\\t%s\\tmandatory\\tfrozen\\n" "$CPATH" "$CPATH")" # t95-m11 порча@'
zapest s12 t95-m12 red_orch_brief_starter.sh \
  's@.*# t95-m12.*@SKIP_TASK=0 # t95-m12 порча@'
zapest s13 t95-m13 red_kontekst_doslovno.sh \
  's@.*# t95-m13.*@CONTEXT_SEC="${CONTEXT_SEC}Существующее не доставлено" # t95-m13 порча@'
zapest s14 t95-m14 red_profil_dva_sloja.sh \
  's@.*# t95-m14.*@CP="$(jq -s "\(.[0].contextPack // {})" "$RJ" "$PJ")" # t95-m14 порча@'
zapest s15 t95-m15 red_dver_spawn_manifest.sh \
  's@.*# t95-m15.*@  : # t95-m15 порча@' "$DOOR_MODEL"
zapest s16 t95-m16 red_uroki_po_oblasti.sh \
  's@.*# t95-m16.*@  : # t95-m16 порча@'
zapest s17 t95-m17 red_revjer_poluchaet_vydannoe.sh \
  's@.*# t95-m17.*@  : # t95-m17 порча@'
zapest s18 t95-m18 red_orch_brief_starter.sh \
  's@.*# t95-m18.*@HEALTH_SEC="HEALTH: branch=? dirty=?" GOAL_SEC="" WORK_SEC="" DEC_SEC="" # t95-m18 порча@'

printf 'ИТОГ стаб-пак 095: rc=%s\n' "$itog"
exit "$itog"
