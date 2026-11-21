#!/usr/bin/env bash
# Обманный стаб-пак 095: порчи честных моделей (dover.sh — сборщик,
# dver_spawn.sh — дверь), каждая одной якорной правкой,
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
# s17 авторский след судьи снят      m17  red_revjer_poluchaet_vydannoe.sh
# s18 содержание брифа вынуто        m18  red_orch_brief_starter.sh
# s19 отказ активным снят            m19  red_orch_brief_karta_legacy.sh
# Дополнительные привязки ниже — CLI-клетки bounded/legacy/GLM/draft.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/model/dover.sh"
DOOR_MODEL="$HERE/model/dver_spawn.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
[ -f "$DOOR_MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$DOOR_MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="${TMPDIR:-/tmp/dev-harness-verify}/context-pack-095-stubs-$$-${RANDOM}"
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
caught=0
live=0
zapest() {  # <стаб-имя> <маркер> <клетка-файл> <sed-выражение> [<источник>]
  local name="$1" marker="$2" cell="$3" expr="$4" src="${5:-$MODEL}" f rc reason="${6:-}"
  f="$(build_stub "$src" "$name" "$marker" "$expr")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  # Новые Б-4 предъявления: синтаксис и адресная причина, не смерть за компанию.
  if [ -n "$reason" ]; then bash -n "$f" || { itog=2; return; }; fi
  if [ "$src" = "$DOOR_MODEL" ]; then
    CP095_SPAWN="$f" CP095_SUBJECT="$MODEL" bash "$HERE/$cell" >"$WORK/result" 2>&1; rc=$?
  else
    CP095_SUBJECT="$f" bash "$HERE/$cell" >"$WORK/result" 2>&1; rc=$?
  fi
  if [ "$rc" -eq 1 ] && { [ -z "$reason" ] || grep -Fq "$reason" "$WORK/result"; }; then
    caught=$((caught + 1))
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s)\n' "$name" "$cell" "$rc" >&2
    live=$((live + 1))
    cat "$WORK/result" >&2
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
zapest s19 t95-m19 red_orch_brief_karta_legacy.sh \
  's@.*# t95-m19.*@  : # t95-m19 порча@'
# Критерийный срез пакета А: каждая порча наблюдаема на СВОЁМ входе.
zapest s20 t95-m20 red_orch_brief_bounded_work.sh \
  's@.*# t95-m20.*@    : # t95-m20 порча: закрытые не опускаются@'
zapest s21 t95-m21 red_orch_brief_bounded_work.sh \
  's@.*# t95-m21.*@  : # t95-m21 порча: хвост скрыт без счётчика@'
zapest s29 t95-m29 red_orch_brief_bounded_work.sh \
  's@.*# t95-m29.*@    if true; then # t95-m29 порча: кап WORK снят@'
zapest s30 t95-x1 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-x1.*@    if ! grep -Fxq -- "$cnum" <<<"$_plan_ids"; then # t95-x1 порча: без плана всё скрыто@'
zapest s31 t95-m31 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-m31.*@        s=subject!="" ? subject : title # t95-m31 порча: обещание/inline потеряны@'
zapest s32 t95-m32 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-m32.*@        s=s # t95-m32 порча: метка черновика потеряна@'
zapest s40 t95-m40 red_naznachennaja_specializacija.sh \
  's@.*# t95-m40.*@case "$ROLE" in implementer-glm) die "роль вне алфавита: $ROLE" ;; esac # t95-m40 порча@'
zapest s41 t95-m41 red_naznachennaja_specializacija.sh \
  's@.*# t95-m41.*@: # t95-m41 порча: нет семейной роли@'
zapest s42 t95-m42 red_naznachennaja_specializacija.sh \
  's@.*# t95-m42.*@ROLE_TRACE="$LOGICAL_ROLE" # t95-m42 порча: физическая трасса подменена@'
zapest s43 t95-m6 red_rezhim_do_zamorozki.sh \
  's@.*# t95-m6.*@    case "$LOGICAL_ROLE" in architect|critic) ;; *) die "контракт не заморожен: $CONTRACT" ;; esac # t95-m6 порча: arbiter отказан@'
zapest s44 t95-m40 red_naznachennaja_specializacija.sh \
  's@.*# t95-m40.*@: # t95-m40 порча: открыт любой алфавит включая vision@'
zapest s45 t95-m3 red_orch_brief_bounded_work.sh \
  's@.*# t95-m3.*@    : # t95-m3 порча: mandatory потеря проглочена в brief@'
# Б-4: отдельные порчи и различающие входы. Н-39: привязки только здесь.
# S1: большой пак проходит, но тот же мир БЕЗ ключа обязан отказать.
zapest B4-S1 t95-b4-cap red_pack_maxbytes.sh \
  's@.*# t95-b4-cap.*@MAX=130000 # t95-b4-cap порча@' "$MODEL" 'pack-maxbytes/raised: отказ rc=0'
# S2: pack распознан, но большой пак всё ещё режется по 40000.
zapest B4-S2 t95-b4-cap red_pack_maxbytes.sh \
  's@.*# t95-b4-cap.*@MAX=40000 # t95-b4-cap порча@' "$MODEL" 'pack-maxbytes/raised: успех rc=1: ОТКАЗ: режь задачу:'
# S3: WORK >39800 и <129800 при MAX=130000 не должен усекаться.
zapest B4-S3 t95-b4-work red_pack_maxbytes_brief.sh \
  's@.*# t95-b4-work.*@WORK_MAX=39800 # t95-b4-work порча@' "$MODEL" 'pack-maxbytes/brief: WORK преждевременно усечён'
# S4: maxBytes=30000 не должен приниматься.
zapest B4-S4 t95-b4-min red_pack_maxbytes_values.sh \
  's@.*# t95-b4-min.*@minimum = 30000  # t95-b4-min порча@' "$MODEL" 'pack-maxbytes/values: отказ rc=0'
# S5: JSON-строка "130000" не должна молча стать умолчанием.
zapest B4-S5 t95-b4-invalid red_pack_maxbytes_values.sh \
  's@.*# t95-b4-invalid.*@    value = 40000  # t95-b4-invalid порча@' "$MODEL" 'pack-maxbytes/values: отказ rc=0'
# S6: успешный большой пак обязан назвать профильный знаменатель.
zapest B4-S6 t95-b4-budget red_pack_maxbytes.sh \
  's@"\$VK" "\$MAX" # t95-b4-budget@"$VK" 40000 # t95-b4-budget порча@' "$MODEL" 'pack-maxbytes/raised: BUDGET'
# S7: ровно MAX байт — допустимый вход, в отличие от MAX+1.
zapest B4-S7 t95-m9 red_pack_maxbytes_boundary.sh \
  's@-le "\$MAX"@-lt "$MAX"@; s@# t95-m9@# t95-m9 порча@' "$MODEL" 'pack-maxbytes/boundary: успех rc=1: ОТКАЗ: режь задачу: 40000 > 40000'
printf 'STABS 095: CAUGHT=%s LIVE=%s\n' "$caught" "$live"
printf 'ИТОГ стаб-пак 095: rc=%s\n' "$itog"
exit "$itog"
