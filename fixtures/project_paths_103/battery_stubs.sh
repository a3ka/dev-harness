#!/usr/bin/env bash
# Обманный стаб-пак 103 (Н-39): двадцать один стаб на шестнадцати маркерах честных моделей, каждый ОДНОЙ
# sed-по-маркеру `# t103-mN`, привязана к клетке, на чьём входе дефект
# НАБЛЮДАЕМ (привязка — В ЭТОМ КОДЕ). Пойман = клетка против стаба rc 1.
#
# # стаб | ослабляемая защита                          | маркер | модель                 | ловящая клетка
# s1  путь контрактов зашит «contracts» (harness-layout) m1  kontrakt_po_profilju   red_kontrakt_iz_profilnogo_puti.sh
# s2  тот же стаб s1 на негативном входе                 m1  kontrakt_po_profilju   red_koren_harnesa_ne_istochnik.sh
# s3  канонизация workflowPaths снята (make_task)         m2  kontrakt_po_profilju   red_puti_vne_repo.sh
# s4  канонизация workflowPaths снята (стандарт)          m3  check_project_standard red_puti_vne_repo.sh
# s5  проверка commands≠true снята                        m4  check_project_standard red_standart_narushenija.sh
# s6  проверка env-ignore снята                           m5  check_project_standard red_standart_narushenija.sh
# s7  проверка ключей профиля снята                       m6  check_project_standard red_standart_narushenija.sh
# s8  контракт от cwd, не от --repo                       m7  pre_critic_proekta     red_pre_critic_cwd.sh
# s9  реестр зашит «registry/contracts.tsv»               m8  dver_reestra           red_spawn_reestr_proekta.sh
# s10 ls-tree заморозки по корневому «contracts/»           m9  kontrakt_po_profilju   red_frozen_iz_profilnogo_puti.sh
# s11 тот же стаб s10 на негативном входе                   m9  kontrakt_po_profilju   red_frozen_koren_ne_istochnik.sh
# s12 стаб s1 (contracts зашит) на входе брифа              m1  kontrakt_po_profilju   red_brief_iz_profilnogo_puti.sh
# s13 путь реестра зашит «registry» (план брифа)            m10 kontrakt_po_profilju   red_brief_iz_profilnogo_puti.sh
# s14 exit после первой красной строки стандарта            m4  check_project_standard red_standart_polnyj_nabor.sh
# s15 приоритет слоя env > CLI (--layer-root игнорируется) m11 check_project_standard red_standart_etalon.sh   (prioritet)
# s16 слой всегда R (игнор --layer-root и env)           m11 check_project_standard red_standart_etalon.sh   (sloj-vne)
# s17 komandy-true проверяет только test                 m12 check_project_standard red_standart_narushenija.sh (lint)
# s18 проверка «.env не в индексе» снята                  m13 check_project_standard red_standart_narushenija.sh (indeks)
# s19 проверка schemaVersion = 1 снята                    m14 check_project_standard red_standart_narushenija.sh (schemaVersion)
# s20 второй резолвер: registry своим jq по R, не resolver m15 dver_reestra           red_spawn_reestr_proekta.sh (i3в/i3г)
# s21 второй резолвер в ноге (г): registry своим jq по R  m16 pre_critic_proekta     red_pre_critic_cwd.sh (i2в)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
M_MT="$HERE/model/kontrakt_po_profilju.sh"
M_ST="$HERE/model/check_project_standard.sh"
M_PC="$HERE/model/pre_critic_proekta.sh"
M_SP="$HERE/model/dver_reestra.sh"
for m in "$M_MT" "$M_ST" "$M_PC" "$M_SP"; do
  [ -f "$m" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$m" >&2; exit 2; }
done
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/project-paths-103-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT
export PP103_ROOT="${PP103_ROOT:-$(cd "$HERE/../.." && pwd)}"

build_stub() {  # <источник> <имя> <маркер> <sed> → путь стаба
  local src="$1" name="$2" marker="$3" expr="$4" n out
  out="$WORK/$name.sh"
  n="$(grep -c -- "# $marker\b" "$src")"
  [ "$n" -eq 1 ] || { printf 'ОТКАЗ: маркер %s в %s встречается %s раз\n' "$marker" "$src" "$n" >&2; return 1; }
  sed -e "$expr" "$src" >"$out" || return 1
  grep -q -- "# $marker порча" "$out" || { printf 'ОТКАЗ: порча %s не применилась\n' "$name" >&2; return 1; }
  printf '%s' "$out"
}

itog=0
zapest() {  # <стаб> <маркер> <клетка> <sed> <модель> <ПЕРЕМЕННАЯ субъекта>
  local stub rc
  stub="$(build_stub "$5" "$1" "$2" "$4")" || { itog=2; return; }
  # честные модели на остальные субъекты, стаб — на свой
  rc=0
  env PP103_MAKE_TASK="$M_MT" PP103_STANDARD="$M_ST" PP103_PRE_CRITIC="$M_PC" PP103_SPAWN="$M_SP" \
      "$6=$stub" bash "$HERE/$3" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -eq 1 ]; then
    printf -- '— %s (%s → %s): пойман\n' "$1" "$2" "$3"
  else
    printf -- '— %s (%s → %s): НЕ ПОЙМАН (rc=%s)\n' "$1" "$2" "$3" "$rc"; itog=1
  fi
}

zapest s1 t103-m1 red_kontrakt_iz_profilnogo_puti.sh  's@.*# t103-m1$@WP_C="contracts" # t103-m1 порча@'                   "$M_MT" PP103_MAKE_TASK
zapest s2 t103-m1 red_koren_harnesa_ne_istochnik.sh   's@.*# t103-m1$@WP_C="contracts" # t103-m1 порча@'                   "$M_MT" PP103_MAKE_TASK
zapest s3 t103-m2 red_puti_vne_repo.sh                's@.*# t103-m2.*@  : # t103-m2 порча@'                                "$M_MT" PP103_MAKE_TASK
zapest s4 t103-m3 red_puti_vne_repo.sh                's@.*# t103-m3.*@  : # t103-m3 порча@'                                "$M_ST" PP103_STANDARD
zapest s5 t103-m4 red_standart_narushenija.sh         's@.*# t103-m4.*@  : # t103-m4 порча@'                                "$M_ST" PP103_STANDARD
zapest s6 t103-m5 red_standart_narushenija.sh         's@.*# t103-m5.*@: # t103-m5 порча@'                                  "$M_ST" PP103_STANDARD
zapest s7 t103-m6 red_standart_narushenija.sh         's@.*# t103-m6.*@    : # t103-m6 порча@'                              "$M_ST" PP103_STANDARD
zapest s8 t103-m7 red_pre_critic_cwd.sh               's@.*# t103-m7.*@BASE="$(pwd)" # t103-m7 порча@'                     "$M_PC" PP103_PRE_CRITIC
zapest s9 t103-m8 red_spawn_reestr_proekta.sh         's@.*# t103-m8.*@MANIFEST_PATH="registry/contracts.tsv" # t103-m8 порча@' "$M_SP" PP103_SPAWN
zapest s10 t103-m9  red_frozen_iz_profilnogo_puti.sh     's@.*# t103-m9.*@  FROZEN_DIR="contracts" # t103-m9 порча@'                 "$M_MT" PP103_MAKE_TASK
zapest s11 t103-m9  red_frozen_koren_ne_istochnik.sh     's@.*# t103-m9.*@  FROZEN_DIR="contracts" # t103-m9 порча@'                 "$M_MT" PP103_MAKE_TASK
zapest s12 t103-m1  red_brief_iz_profilnogo_puti.sh      's@.*# t103-m1$@WP_C="contracts" # t103-m1 порча@'                         "$M_MT" PP103_MAKE_TASK
zapest s13 t103-m10 red_brief_iz_profilnogo_puti.sh      's@.*# t103-m10.*@WP_G="registry" # t103-m10 порча@'                        "$M_MT" PP103_MAKE_TASK
zapest s14 t103-m4  red_standart_polnyj_nabor.sh         's@.*# t103-m4.*@  [ "$v" != "true" ] || { fail komandy-true "commands.$k замаскирована true"; exit 1; } # t103-m4 порча@' "$M_ST" PP103_STANDARD
zapest s15 t103-m11 red_standart_etalon.sh               's@.*# t103-m11.*@LAYER="${HARNESS_PROJECT_LAYER_ROOT:-${LAYER:-$R}}" # t103-m11 порча@' "$M_ST" PP103_STANDARD
zapest s16 t103-m11 red_standart_etalon.sh               's@.*# t103-m11.*@LAYER="$R" # t103-m11 порча@'                                      "$M_ST" PP103_STANDARD
zapest s17 t103-m12 red_standart_narushenija.sh          's@.*# t103-m12.*@for k in test; do # t103-m12 порча@'                                "$M_ST" PP103_STANDARD
zapest s18 t103-m13 red_standart_narushenija.sh          's@.*# t103-m13.*@: # t103-m13 порча@'                                                "$M_ST" PP103_STANDARD
zapest s19 t103-m14 red_standart_narushenija.sh          's@.*# t103-m14.*@  : # t103-m14 порча@'                                              "$M_ST" PP103_STANDARD
zapest s20 t103-m15 red_spawn_reestr_proekta.sh          's@.*# t103-m15.*@REG="$(jq -r '"'"'.workflowPaths.registry // empty'"'"' "$ROOT/harness.project.json" 2>/dev/null)"; [ -n "$REG" ] || REG="$(jq -r '"'"'.defaults.workflowPaths.registry // empty'"'"' "$ROOT/$(jq -r '"'"'.projectLayer.profilePath // empty'"'"' "$ROOT/harness.project.json")" 2>/dev/null)" # t103-m15 порча@' "$M_SP" PP103_SPAWN
zapest s21 t103-m16 red_pre_critic_cwd.sh                's@.*# t103-m16.*@REG="$(jq -r '"'"'.workflowPaths.registry // empty'"'"' "$BASE/harness.project.json" 2>/dev/null)"; [ -n "$REG" ] || REG="registry" # t103-m16 порча@' "$M_PC" PP103_PRE_CRITIC
printf 'ИТОГ стаб-пак 103: rc=%s\n' "$itog"
exit "$itog"
