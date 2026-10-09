#!/usr/bin/env bash
# Обманный стаб-пак 095 (контракт 095, Н-39): двенадцать порч честной модели
# model/dover.sh, каждая ОДНОЙ якорной sed-по-маркеру, каждая привязана к
# клетке, на чьём входе её дефект НАБЛЮДАЕМ (привязка живёт В ЭТОМ КОДЕ,
# не в прозе контракта). Стаб строится из ТЕКУЩЕЙ модели (копия + порча с
# проверкой якоря: маркер встречается в модели ровно один раз, порча
# применилась). Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО).
#
# # стаб | ослабляемая защита | порча (маркер) | ловящая клетка
# s1 харнесовские правила вклеены  m1   красная_pravila_proekta_ne_harsa
# s2 манифест не строится          m2   красная_manifest_razreshaetsja
# s3 mandatory-проверка снята      m3   красная_poteryannaja_ssylka_tochna
# s4 матрица скилов не по роли     m4   красная_roli_menjajut_vydachu
# s5 зоны из черновика            m5   красная_zony_iz_frozen_blobs
# s6 implementer без заморозки     m6   красная_rezhim_do_zamorozki
# s7 задание пересобрано           m7   красная_revjer_poluchaet_vydannoe
# s8 свидетельство подменено       m8   красная_svidetelstvo_modeli
# s9 бюджет не считается           m9   красная_bjudzhet_vklejki
# s10 фильтр области уроков снят   m10  красная_uroki_po_oblasti
# s11 происхождение всегда frozen  m11  красная_proishozhdenie_fragmentov
# s12 брифинг = задачный пак       m12  красная_orch_brief_starter
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/model/dover.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/context-pack-095-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# build_stub <имя> <маркер> <sed-выражение> — копия модели, порча с проверкой:
# маркер в модели ровно один раз, порча применилась (метка «порча» в файле).
build_stub() {
  local name="$1" marker="$2" expr="$3" f n
  n="$(grep -Ec "# ${marker}([^0-9]|$)" "$MODEL")" || n=0
  [ "$n" -eq 1 ] || { printf 'ОТКАЗ: маркер %s встречается %s раз\n' "$marker" "$n" >&2; return 2; }
  f="$WORK/$name.sh"
  cp "$MODEL" "$f" || return 2
  sed -i "$expr" "$f" || return 2
  grep -Fq 'порча' "$f" || return 2
  chmod +x "$f"
  printf '%s' "$f"
}

itog=0
zapest() {  # <стаб-имя> <маркер> <клетка-файл> <sed-выражение>
  local name="$1" marker="$2" cell="$3" expr="$4" f rc
  f="$(build_stub "$name" "$marker" "$expr")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча)\n' "$name" >&2; itog=2; return; }
  CP095_SUBJECT="$f" bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
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
  's@.*# t95-m8.*@TRACE_LINE="TRACE: role=$ROLE model=fake-model fallback=allowed" # t95-m8 порча@'
zapest s9 t95-m9 red_bjudzhet_vklejki.sh \
  's@.*# t95-m9.*@: # t95-m9 порча@'
zapest s10 t95-m10 red_uroki_po_oblasti.sh \
  's@.*# t95-m10.*@        case "$zp" in *) m=1 ;; esac # t95-m10 порча@'
zapest s11 t95-m11 red_proishozhdenie_fragmentov.sh \
  's@.*# t95-m11.*@" CTX_MAN="$(printf "context\\t%s\\tmandatory\\tfrozen\\nzones\\t%s\\tmandatory\\tfrozen\\n" "$CPATH" "$CPATH")" # t95-m11 порча@'
zapest s12 t95-m12 red_orch_brief_starter.sh \
  's@.*# t95-m12.*@SKIP_TASK=0 # t95-m12 порча@'

printf 'ИТОГ стаб-пак 095: rc=%s\n' "$itog"
exit "$itog"
