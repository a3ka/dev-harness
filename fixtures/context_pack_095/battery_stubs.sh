#!/usr/bin/env bash
# Обманный стаб-пак 095 (контракт 095, круг 2 + sol-1112 bounded + followup-1112,
# Н-39): двадцать девять порч честных моделей (dover.sh — сборщик, dver_spawn.sh —
# дверь), каждая ОДНОЙ якорной sed-по-маркеру, каждая привязана к клетке, на чьём
# входе её дефект НАБЛЮДАЕМ (привязка живёт В ЭТОМ КОДЕ, не в прозе контракта).
# Стаб строится из ТЕКУЩЕЙ модели (копия + порча с проверкой якоря: маркер
# встречается в модели ровно один раз, порча применилась). Пойман = связанная
# клетка против стаба даёт rc 1 (КРАСНО).
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
# s26 статус по датам тегов (не DAG)   m26  red_orch_brief_vozobnovlenie.sh [ветви (а)/(б), мир с лживыми датами]
# s27 терминальный done показан        m27  red_orch_brief_vozobnovlenie.sh [ветвь (б), только 333]
# s29 кап брифа снят                   m29  red_orch_brief_bounded_work.sh [ветвь (в), только мир-толстяк]
# s31 без plan.tsv всё «вне плана»     x1   red_orch_brief_rabota_bez_plana.sh [ветвь (а), только мир без плана]
# s32 обещание/inline выпали из цепочки x2  red_orch_brief_rabota_bez_plana.sh [ветвь (а), только 710/720/731]
# s33 отказ источника проглочен        x3   red_orch_brief_rabota_bez_plana.sh [ветвь (в), только бриф]
# s34 placeholder вместо отказа        x5   red_orch_brief_rabota_bez_plana.sh [ветвь (г), только пустой контракт]
# s35 TMPDIR-граница (случай) снята    t95-m35 red_dver_spawn_manifest.sh [ветвь (е5), дверь — TMPDIR внутри фактического корня, worktree-list его не покрывает; на е1–е4 ненаблюдаемо]
# s36 worktree-перечисление умерло     t95-m36 red_dver_spawn_manifest.sh [ветвь (е3), дверь]
# s37 TMPDIR-граница (случай) снята    t95-m37 red_dver_spawn_manifest.sh [ветвь (е5), сборщик — TMPDIR внутри фактического корня, worktree-list его не покрывает; на е1–е4 ненаблюдаемо]
# s38 worktree-перечисление умерло     t95-m38 red_dver_spawn_manifest.sh [ветвь (е3), сборщик]
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
  's@.*# t95-m3.*@    if false; then # t95-m3 порча@'
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
zapest s26 t95-m26 red_orch_brief_vozobnovlenie.sh \
  's@.*# t95-m26.*@      if [ -z "$fref" ] || [ "$(git -C "$REPO" for-each-ref --format="%(creatordate:unix)" "$fref" 2>/dev/null | sort -n | tail -n 1)" -lt "$(git -C "$REPO" for-each-ref --format="%(creatordate:unix)" "$dref" 2>/dev/null | sort -n | tail -n 1)" ]; then # t95-m26 порча@'
zapest s27 t95-m27 red_orch_brief_vozobnovlenie.sh \
  's@.*# t95-m27.*@        st=""; continue # t95-m27 порча@'
zapest s29 t95-m29 red_orch_brief_bounded_work.sh \
  's@.*# t95-m29.*@    if [ "$_brk" = "0" ]; then # t95-m29 порча@'
zapest s31 t95-x1 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-x1.*@    if ! printf "%s\\n" "$_plan_ids" | grep -Fxq -- "$cnum"; then # t95-x1 порча@'
zapest s32 t95-x2 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-x2.*@        s = subject != "" ? subject : title # t95-x2 порча@'
zapest s33 t95-x3 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-x3.*@      : # t95-x3 порча@'
zapest s34 t95-x5 red_orch_brief_rabota_bez_plana.sh \
  's@.*# t95-x5.*@    csubj="предмет не найден" # t95-x5 порча@'
zapest s35 t95-m35 red_dver_spawn_manifest.sh \
  's@.*# t95-m35.*@    "t95-e-none"|"t95-e-none"/*) # t95-m35 порча@' "$DOOR_MODEL"
zapest s36 t95-m36 red_dver_spawn_manifest.sh \
  's@.*# t95-m36.*@  while false; do # t95-m36 порча@' "$DOOR_MODEL"
zapest s37 t95-m37 red_dver_spawn_manifest.sh \
  's@.*# t95-m37.*@    "t95-e-none"|"t95-e-none"/*) # t95-m37 порча@'
zapest s38 t95-m38 red_dver_spawn_manifest.sh \
  's@.*# t95-m38.*@  while false; do # t95-m38 порча@'
printf 'ИТОГ стаб-пак 095: rc=%s\n' "$itog"
exit "$itog"
