#!/usr/bin/env bash
# Семья 088, часть А: нога (1) двери scripts/orch_restart.sh «живые субагенты» в
# окружении сессии omp (HOME перенаправлен в каталог зоны, журналы сессий — под домом
# из passwd). Субъект — scripts/orch_restart.sh + scripts/lib_session.sh судимого корня,
# копией в тоу-корень (дверь не трогает основной чекаут; маркер и след — швы в скратче).
#
# Использование: bash red_dver_088.sh <корень> [L1 D0 … D11] [--dver <файл>]
#   --dver <файл> — подменить дверь тоу-корня (стаб-пак/диффпроба); L1 судит только субъект.
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки (ожидания — константы, оракул в памяти; на fb08e98 красны D8 D9 D10, D11 — пара):
#   L1 ЖИВАЯ среда: без шимов и швов, настоящие HOME/PATH/getent. Внутри сессии omp
#      (есть $PI_CODING_AGENT_DIR/sessions) ДРУГАЯ мера — omp-указатель — находит
#      самый свежий session-журнал и его субагентов моложе 60 с; если такие есть, дверь
#      обязана отказать «живые субагенты: …» со списком ⊇ этих имён. Вне omp (CI) или без
#      живых субагентов — ПРОПУСК с пометкой, не зелёное.
#   D0 дом из passwd: сессия только со старым (час) журналом → дверь проходит ногу (1)
#      и останавливается на (а).
#   D1 HOME сессии без журналов, дом из passwd — два свежих и один старый журнал →
#      «ОТКАЗ: живые субагенты: ZhivojA,ZhivojB». ДО 088 — красная (измерено 17:53).
#   D2 шов ORCH_SESS_GLOB над 500 session-журналами (листинг `ls -t` > 64 КиБ — больше
#      ёмкости канала), самый свежий несёт свежий ZhivojMnogo → «ОТКАЗ: живые субагенты:
#      ZhivojMnogo». ДО 088 — красная: под `set -o pipefail` двери SIGPIPE в
#      `ls -t … | head -1` обнуляет current_session_dir (измерено живьём: 40 файлов,
#      7880 байт листинга — пусто 5/5; без pipefail — каталог найден).
#   D3 как D1, но USER/LOGNAME подменены на чужое имя → тот же отказ (имя — `id -un`).
#   D4 шов ORCH_SESS_GLOB задан (каталог шва со свежим SeamAgent), под домом из passwd
#      сессий нет → «ОТКАЗ: живые субагенты: SeamAgent» (швы 080 прежние).
#   D5 как D1, но единственный свежий журнал — basename с ведущей точкой `.Skrytyj.jsonl`
#      (конформное имя по §Демаркации) → «ОТКАЗ: живые субагенты: .Skrytyj». Дверь,
#      отбрасывающая имена `.*`, проходит ногу (1) до (а) (adversary 088).
#   D6 как D1, но дом из passwd несёт пробелы (`…/d6 dom s probelom`; поле 6 passwd —
#      любые байты, кроме `:` и LF) → тот же отказ. Глоб сессий, разбитый по IFS на
#      слова, пуст — дверь доходит до (а) (adversary 088-v2 §2).
#   D7 как D1, но дом из passwd несёт глоб-метасимволы `[x]*?\` (каталог существует
#      буквально) → тот же отказ. Неэкранированный дом в глобе — шаблон, а не путь:
#      каталог сессии под ним не находится (тот же нецитированный `ls -t $ORCH_SESS_GLOB`).
#   D8 как D1, но дом из passwd — `…/d8_uh/x/.local/state/y z` (подстрока
#      `/.local/state/` и пробел в самом доме; ревьюер 088 круг 4, Б-3) → тот же отказ.
#      Вторая грамматика пути в двери (свой current_session_dir, режущий «дом» по
#      первой `/.local/state/`) находит пусто — дверь доходит до (а).
#   D9 шов ORCH_SESS_GLOB, путь шва с двумя пробелами подряд (D4-тип; adversary 088
#      круг 4) → «ОТКАЗ: живые субагенты: SeamAgent». Глоб, разбитый по IFS, пуст.
#   D10 как D9, но в пути шва TAB вместо пробелов → тот же отказ.
#   D11 шов ORCH_SESS_GLOB с литеральными `[x]` в пути, записанными экранированно
#      (`…/d11\[x\]/sessions/*.jsonl`) → тот же отказ. Пара к границе ниже.
# Граница конформности шва (арбитраж 088 круг 5): ORCH_SESS_GLOB — ГЛОБ (имя, умолчание
# и документация 080); литеральные `[ ] * ? \` в пути шва записываются экранированными
# (`\[x\]` — конформно, D11). Неэкранированный `literal[x]` в шве — неконформная запись,
# не контрпример: глоб трактует его как класс символов. Пробел и TAB глоб не трактует —
# их пропуск дверью дефект (D9, D10). Дом из passwd экранирует сама дверь (D7).
# Привязка стабов к клеткам — red_stuby_088.sh (Н-39: по коду, не прозой).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
DVER="$ROOT/scripts/orch_restart.sh"
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dver) DVER="${2:-}"; [ -f "$DVER" ] || { printf 'NOT_IMPLEMENTED: нет двери-подмены %s\n' "$DVER" >&2; exit 2; }; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
for subj in scripts/orch_restart.sh scripts/lib_session.sh; do
  [ -f "$ROOT/$subj" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$subj" >&2; exit 2; }
done
# shellcheck disable=SC1091
. "$HERE/_toy.sh" "${kletki[@]}"

# ── L1: живая среда (первой — свежесть журнала вызывающего субагента) ─────────
if nado L1; then
  if [ -z "${PI_CODING_AGENT_DIR:-}" ] || [ ! -d "$PI_CODING_AGENT_DIR/sessions" ]; then
    propusk 'L1: вне сессии omp (нет $PI_CODING_AGENT_DIR/sessions — CI или терминал)'
  else
    sf="$(ls -t "$PI_CODING_AGENT_DIR"/sessions/*/*.jsonl 2>/dev/null | head -n 1)"
    if [ -z "$sf" ] || [ ! -d "${sf%.jsonl}" ]; then
      propusk 'L1: у текущей сессии omp нет каталога субагентов'
    else
      mapfile -t ozh_imena < <(find "${sf%.jsonl}" -maxdepth 1 -name '*.jsonl' -newermt '-60 seconds' -printf '%f\n' | sed 's/\.jsonl$//' | LC_ALL=C sort)
      if [ "${#ozh_imena[@]}" -eq 0 ]; then
        propusk 'L1: в сессии omp нет субагента моложе 60 с (батарея запущена не из субагента)'
      else
        dver_mir "$SCR/l1"
        env -u ORCH_SESS_DIR -u ORCH_SESS_GLOB \
            ORCH_RESTART_MARKER="$SCR/marker" ORCH_SESSION_START="$SCR/start" \
            bash "$SCR/l1/scripts/orch_restart.sh" --as orchestrator >/dev/null 2>"$SCR/dver.err"; rc=$?
        stroka="$(grep -m1 '^ОТКАЗ: живые субагенты: ' "$SCR/dver.err" || true)"
        spisok=",${stroka#ОТКАЗ: живые субагенты: },"
        nedostaet=""
        for n in "${ozh_imena[@]}"; do
          case "$spisok" in *",$n,"*) ;; *) nedostaet="$nedostaet $n" ;; esac
        done
        if [ -e "$SCR/marker" ]; then
          krasno "L1: живая среда — маркер поставлен при живых:${ozh_imena[*]/#/ }"; rm -f -- "$SCR/marker"
        elif [ "$rc" -eq 1 ] && [ -n "$stroka" ] && [ -z "$nedostaet" ]; then
          zeleno "L1 (живая среда, omp-мера: ${ozh_imena[*]})"
        else
          krasno "L1: живая среда — omp видит живых (${ozh_imena[*]}), дверь rc=$rc, не названы:${nedostaet:- —}: $(head -c 300 "$SCR/dver.err" | tr '\n' ' ')"
        fi
      fi
    fi
  fi
fi

# ── D0..D7: тоу-миры ───────────────────────────────────────────────────────────
ZONE_HOME="$SCR/zona_home"      # HOME сессии omp (перенаправленный, журналов нет)
mkdir -p "$ZONE_HOME" || exit 2

kat() {  # <дом> → k=каталог session-уровня (rc 2 файла при отказе единого источника)
  k="$(sess_kat "$1")" && [ -n "$k" ] || { printf 'NOT_IMPLEMENTED: нет каталога сессий для %s\n' "$1" >&2; exit 2; }
}

if nado D0; then
  export TOY_UH="$SCR/d0_uh"
  kat "$TOY_UH"; sessija "$k" -- Staryj
  dver_mir "$SCR/d0" "$DVER"
  dver "$SCR/d0" "$ZONE_HOME"; ozhidaj_a D0 $? proshla
fi

if nado D1; then
  export TOY_UH="$SCR/d1_uh"
  kat "$TOY_UH"; sessija "$k" ZhivojB ZhivojA -- Staryj
  dver_mir "$SCR/d1" "$DVER"
  dver "$SCR/d1" "$ZONE_HOME"; ozhidaj_a D1 $? zhivye 'ZhivojA,ZhivojB'
fi

if nado D2; then
  export TOY_UH="$SCR/d2_uh"
  mkdir -p "$TOY_UH" || exit 2
  mnogo="$SCR/d2_shov_s_dlinnym_imenem_kataloga_dlja_bolshogo_listinga_ls/sessions"
  mkdir -p "$mnogo" || exit 2
  for i in $(seq -w 1 499); do
    : > "$mnogo/2026-10-0${i:0:1}T00-00-00-${i}Z_starajasessijadlinnoeimja.jsonl"
  done
  touch -d '-2 hours' "$mnogo"/*.jsonl
  sessija "$mnogo" ZhivojMnogo -- Staryj
  lb="$(ls -t "$mnogo"/*.jsonl | wc -c)"
  [ "$lb" -gt 65536 ] || { printf 'NOT_IMPLEMENTED: листинг D2 %s байт ≤ 64 КиБ — SIGPIPE не гарантирован\n' "$lb" >&2; exit 2; }
  dver_mir "$SCR/d2" "$DVER"
  dver "$SCR/d2" "$ZONE_HOME" ORCH_SESS_GLOB="$mnogo/*.jsonl"; ozhidaj_a D2 $? zhivye 'ZhivojMnogo'
fi

if nado D3; then
  export TOY_UH="$SCR/d3_uh"
  kat "$TOY_UH"; sessija "$k" ZhivojA ZhivojB -- Staryj
  dver_mir "$SCR/d3" "$DVER"
  dver "$SCR/d3" "$ZONE_HOME" USER=chuzhoj088 LOGNAME=chuzhoj088; ozhidaj_a D3 $? zhivye 'ZhivojA,ZhivojB'
fi

if nado D4; then
  export TOY_UH="$SCR/d4_uh"
  mkdir -p "$TOY_UH" || exit 2
  shov="$SCR/d4_shov/sessions"
  sessija "$shov" SeamAgent -- Staryj
  dver_mir "$SCR/d4" "$DVER"
  dver "$SCR/d4" "$ZONE_HOME" ORCH_SESS_GLOB="$shov/*.jsonl"; ozhidaj_a D4 $? zhivye 'SeamAgent'
fi

if nado D5; then
  export TOY_UH="$SCR/d5_uh"
  kat "$TOY_UH"; sessija "$k" .Skrytyj -- Staryj
  dver_mir "$SCR/d5" "$DVER"
  dver "$SCR/d5" "$ZONE_HOME"; ozhidaj_a D5 $? zhivye '.Skrytyj'
fi

if nado D6; then
  export TOY_UH="$SCR/d6 dom s probelom"
  kat "$TOY_UH"; sessija "$k" ZhivojB ZhivojA -- Staryj
  dver_mir "$SCR/d6" "$DVER"
  dver "$SCR/d6" "$ZONE_HOME"; ozhidaj_a D6 $? zhivye 'ZhivojA,ZhivojB'
fi

if nado D7; then
  export TOY_UH="$SCR/d7[x]*?\\y"
  kat "$TOY_UH"; sessija "$k" ZhivojB ZhivojA -- Staryj
  dver_mir "$SCR/d7" "$DVER"
  dver "$SCR/d7" "$ZONE_HOME"; ozhidaj_a D7 $? zhivye 'ZhivojA,ZhivojB'
fi

if nado D8; then
  export TOY_UH="$SCR/d8_uh/x/.local/state/y z"
  kat "$TOY_UH"; sessija "$k" ZhivojB ZhivojA -- Staryj
  dver_mir "$SCR/d8" "$DVER"
  dver "$SCR/d8" "$ZONE_HOME"; ozhidaj_a D8 $? zhivye 'ZhivojA,ZhivojB'
fi

# shov_kletka <клетка> <каталог шва> <глоб шва> — D4-тип: под домом из passwd сессий
# нет, шов указывает на каталог со свежим SeamAgent.
shov_kletka() {
  export TOY_UH="$SCR/${1}_uh"
  mkdir -p "$TOY_UH" || exit 2
  sessija "$2" SeamAgent -- Staryj
  dver_mir "$SCR/$1" "$DVER"
  dver "$SCR/$1" "$ZONE_HOME" ORCH_SESS_GLOB="$3"; ozhidaj_a "$1" $? zhivye 'SeamAgent'
}
nado D9 && shov_kletka D9 "$SCR/d9 shov  s probelami/sessions" "$SCR/d9 shov  s probelami/sessions/*.jsonl"
nado D10 && shov_kletka D10 "$SCR/d10"$'\t'"shov/sessions" "$SCR/d10"$'\t'"shov/sessions/*.jsonl"
nado D11 && shov_kletka D11 "$SCR/d11[x]/sessions" "$SCR"'/d11\[x\]/sessions/*.jsonl'

itog_semji red_dver_088.sh
