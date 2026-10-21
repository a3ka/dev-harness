#!/usr/bin/env bash
# Красная батарея контракта 120 (спецификация mobility consumer v1).
#
#   red_mobility_spec_120.sh [<клон Complior-back>]  — живой: оракул на клоне с реальным пином
#   red_mobility_spec_120.sh --model                 — все клетки на мирах модели (mktemp)
#   red_mobility_spec_120.sh --cell <имя>            — одна клетка
#   red_mobility_spec_120.sh --stabs                 — привязка обманных оракулов к клеткам (таблица STABS)
#
# Вердикт — код возврата: 0 все клетки сошлись / клон зелёный; 1 красное; 2 нечем
# судить (нет клетки, нет python3/git/PyYAML, пустая выборка). Скрипт PASS не печатает.
# MOBILITY120_ORACLE=<исполняемый> подменяет оракул (проверка двунаправленной ловли стабов).
#
# Н-39: клетка ↔ ожидаемая причина — литералы таблицы CELLS ниже (не проза контракта);
# каждая клетка d* — честная спецификация модели + ОДНА мутация model_mobility_120.py,
# красная СВОЕЙ причиной (сверка строкой целиком, grep -Fxq); клетка «нечем судить: …» —
# rc 2 оракула с этой строкой (клон без base_commit пина).
# Н-39 для стабов: строка STABS «стаб|клетка|rc батареи на клетке» — стаб d* выключает
# РОВНО одну функцию оракула (импорт + подмена), поэтому красен на своей клетке и зелен
# на соседней клетке той же причины; привязка исполняется, а не описывается.
set -u
export PYTHONDONTWRITEBYTECODE=1
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORACLE="${MOBILITY120_ORACLE:-$HERE/mobility_spec_oracle.py}"
MODEL="$HERE/model_mobility_120.py"
PIN="$HERE/pin_120.json"
DEFAULT_PRODUCT="/tmp/dev-harness-verify/Impl119/back"

command -v python3 >/dev/null 2>&1 || { echo "нечем судить: нет python3" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "нечем судить: нет git" >&2; exit 2; }
python3 -c 'import yaml' 2>/dev/null || { echo "нечем судить: нет PyYAML" >&2; exit 2; }

# имя клетки | ожидаемая строка вердикта (префикс до « (» деталей) | вид мира
CELLS=(
  "m-baza|ОТКАЗ: mobility120: spec-otsutstvuet|bez-spec"
  "k-model|MOBILITY120_OK|spec"
  "d01-artefakt-udalen|ОТКАЗ: mobility120: spec-otsutstvuet|spec"
  "d02-json-bityj|ОТКАЗ: mobility120: json-nevalidno|spec"
  "d03-published-izmenen|ОТКАЗ: mobility120: import119-izmenen|spec"
  "d04-plan-119-perepisan|ОТКАЗ: mobility120: import119-izmenen|spec"
  "d05-server-tronut|ОТКАЗ: mobility120: vne-zony|spec"
  "d06-app-izmenen|ОТКАЗ: mobility120: vne-zony|spec"
  "d07-chetyre-processa|ОТКАЗ: mobility120: processy-nepolny|spec"
  "d08-kod-ne-tot|ОТКАЗ: mobility120: processy-nepolny|spec"
  "d09-kod-vydumannyj|ОТКАЗ: mobility120: service-code-neizvesten|spec"
  "d10-realnyj-adapter|ОТКАЗ: mobility120: adapter-ne-sintetika|spec"
  "d11-bez-blokera-kanala|ОТКАЗ: mobility120: adapter-ne-sintetika|spec"
  "d12-vydumannaya-kak-sushchestvuyushchaya|ОТКАЗ: mobility120: operaciya-neizvestna|spec"
  "d13-deprecated-route|ОТКАЗ: mobility120: operaciya-deprecated|spec"
  "d14-novaya-kollizija|ОТКАЗ: mobility120: novaya-operaciya-kollizija|spec"
  "d15-terminal-bez-evidence|ОТКАЗ: mobility120: terminal-bez-dokazatelstv|spec"
  "d16-termination-net-v-consumer|ОТКАЗ: mobility120: termination-consumer-net|spec"
  "d17-termination-vytesnyaet-kody|ОТКАЗ: mobility120: termination-ne-additivno|spec"
  "d18-cancel-kak-kuendigung|ОТКАЗ: mobility120: termination-consumer-net|spec"
  "d19-terminal-unverified|ОТКАЗ: mobility120: termination-terminal-slab|spec"
  "d20-receipts-nol|ОТКАЗ: mobility120: termination-terminal-slab|spec"
  "d21-wunsch-odna-ssylka|ОТКАЗ: mobility120: wunsch-lifecycle-nepolny|spec"
  "d22-wunsch-bez-otmeny|ОТКАЗ: mobility120: wunsch-lifecycle-nepolny|spec"
  "d23-wunsch-iz-terminala|ОТКАЗ: mobility120: wunsch-avtomat-nekorrekten|spec"
  "d24-wunsch-nedostizhimo|ОТКАЗ: mobility120: wunsch-avtomat-nekorrekten|spec"
  "d25-wunsch-op-vne-processa|ОТКАЗ: mobility120: operaciya-neizvestna|spec"
  "d26-oshibka-propushena|ОТКАЗ: mobility120: oshibki-nepolny|spec"
  "d27-id-119-pereimenovan|ОТКАЗ: mobility120: oshibki-nepolny|spec"
  "d28-kod-dubl|ОТКАЗ: mobility120: oshibki-grammatika|spec"
  "d29-zakryto-119-po-tekstu|ОТКАЗ: mobility120: oshibki-protivorechat-119|spec"
  "d30-kfz-otlozheno|ОТКАЗ: mobility120: oshibki-ne-zakryty-specifikaciej|spec"
  "d31-graf-cikl|ОТКАЗ: mobility120: graf-ciklichen|spec"
  "d32-graf-partner-first|ОТКАЗ: mobility120: graf-ne-consumer-first|spec"
  "d33-graf-tranzitivno-partner|ОТКАЗ: mobility120: graf-ne-consumer-first|spec"
  "d34-graf-v1-zhdet-kanal|ОТКАЗ: mobility120: graf-ne-consumer-first|spec"
  "d35-graf-bez-processa|ОТКАЗ: mobility120: graf-nepolny|spec"
  "d36-graf-broker-bez-yadra|ОТКАЗ: mobility120: graf-nepolny|spec"
  "d37-graf-prizrak|ОТКАЗ: mobility120: graf-nevaliden|spec"
  "d38-readme-bez-ssylki|ОТКАЗ: mobility120: readme-bez-ssylok|spec"
  "d39-readme-v-proze|ОТКАЗ: mobility120: readme-bez-ssylok|spec"
  "d40-graf-partner-poteryan|ОТКАЗ: mobility120: graf-nepolny|spec"
  "d41-graf-kanal-pod-vidom-shared|ОТКАЗ: mobility120: graf-kind-protiv-pina|spec"
  "d42-graf-kanal-pod-aliasom|ОТКАЗ: mobility120: graf-ne-consumer-first|spec"
  "d43-tests-tronuty|ОТКАЗ: mobility120: vne-zony|spec"
  "d44-baza-pina-otsutstvuet|нечем судить: base_commit пина отсутствует в клоне|spec"
  "d45-indeks-assume-unchanged|ОТКАЗ: mobility120: vne-zony|spec"
  "d46-indeks-skip-worktree-udalen|ОТКАЗ: mobility120: vne-zony|spec"
  "d47-wunsch-obshchie-operacii|ОТКАЗ: mobility120: wunsch-lifecycle-nepolny|spec"
  "d48-wunsch-chtenie-pod-proverkoj|ОТКАЗ: mobility120: wunsch-lifecycle-nepolny|spec"
  "d49-graf-bez-vneshnej|ОТКАЗ: mobility120: graf-nepolny|spec"
)

# стаб | клетка | ожидаемый rc батареи на этой клетке под стабом (1 — поймала, 0 — стаб там честен)
STABS=(
  "stab_vsegda_zelenyj.sh|d05-server-tronut|1"
  "stab_vsegda_krasnyj.sh|k-model|1"
  "stab_indeks_doveryaet.py|d45-indeks-assume-unchanged|1"
  "stab_indeks_doveryaet.py|d46-indeks-skip-worktree-udalen|1"
  "stab_indeks_doveryaet.py|d05-server-tronut|0"
  "stab_indeks_doveryaet.py|k-model|0"
  "stab_wunsch_lyubye_operacii.py|d47-wunsch-obshchie-operacii|1"
  "stab_wunsch_lyubye_operacii.py|d48-wunsch-chtenie-pod-proverkoj|1"
  "stab_wunsch_lyubye_operacii.py|d22-wunsch-bez-otmeny|0"
  "stab_wunsch_lyubye_operacii.py|k-model|0"
  "stab_graf_vneshnie_podmnozhestvo.py|d49-graf-bez-vneshnej|1"
  "stab_graf_vneshnie_podmnozhestvo.py|d40-graf-partner-poteryan|0"
  "stab_graf_vneshnie_podmnozhestvo.py|k-model|0"
)

TMP="$(mktemp -d "${TMPDIR:-/tmp}/red120.XXXXXX")" || exit 2
trap 'rm -rf "$TMP"' EXIT

run_cell() {  # <строка таблицы>  → 0 сошлась, 1 нет
  local row="$1" name want kind w out first rc
  name="${row%%|*}"; row="${row#*|}"; want="${row%%|*}"; kind="${row#*|}"
  w="$TMP/$name"
  local flag=""; [ "$kind" = "spec" ] && flag="--spec"
  python3 "$MODEL" build "$w/repo" "$PIN" "$w/pin.json" $flag >"$w.build" 2>&1 \
    || { echo "КЛЕТКА $name: мир не построен"; cat "$w.build"; return 1; }
  case "$name" in
    d*) python3 "$MODEL" mutate "$w/repo" "$name" || { echo "КЛЕТКА $name: мутация не применена"; return 1; } ;;
  esac
  out="$("$ORACLE" "$w/repo" --pin "$w/pin.json" 2>&1)"; rc=$?
  first="$(printf '%s\n' "$out" | sed -n '1p')"
  first="${first%% (*}"
  case "$want" in
    MOBILITY120_OK) [ "$rc" -eq 0 ] && printf '%s\n' "$first" | grep -Eq '^MOBILITY120_OK( |$)' ;;
    "нечем судить: "*) [ "$rc" -eq 2 ] && printf '%s\n' "$first" | grep -Fxq -- "$want" ;;
    *) [ "$rc" -eq 1 ] && printf '%s\n' "$first" | grep -Fxq -- "$want" ;;
  esac
  local ok=$?
  if [ "$ok" -eq 0 ]; then echo "клетка $name: сошлась (rc=$rc) $out"; else echo "КЛЕТКА $name: ждали «$want», факт rc=$rc «$out»"; fi
  return "$ok"
}

case "${1:-}" in
  --stabs)
    [ "${#STABS[@]}" -gt 0 ] || { echo "пустая выборка" >&2; exit 2; }
    bad=0
    for r in "${STABS[@]}"; do
      st="${r%%|*}"; r="${r#*|}"; cell="${r%%|*}"; want="${r#*|}"
      [ -x "$HERE/$st" ] || { echo "СТАБ $st: нет исполняемого файла"; bad=$((bad+1)); continue; }
      MOBILITY120_ORACLE="$HERE/$st" bash "$HERE/red_mobility_spec_120.sh" --cell "$cell" >"$TMP/stab.out" 2>&1
      got=$?
      if [ "$got" -eq "$want" ]; then
        echo "стаб $st × $cell: rc=$got как ждали"
      else
        echo "СТАБ $st × $cell: ждали rc=$want, факт rc=$got"; sed -n '1p' "$TMP/stab.out"; bad=$((bad+1))
      fi
    done
    echo "ИТОГ 120 стабы: строк ${#STABS[@]}, расхождений $bad"
    [ "$bad" -eq 0 ] && exit 0
    exit 1
    ;;
  --model|--cell)
    sel=()
    if [ "$1" = "--cell" ]; then
      [ -n "${2:-}" ] || { echo "нет имени клетки" >&2; exit 2; }
      for r in "${CELLS[@]}"; do [ "${r%%|*}" = "$2" ] && sel+=("$r"); done
      [ "${#sel[@]}" -eq 1 ] || { echo "нет такой клетки: $2" >&2; exit 2; }
    else
      sel=("${CELLS[@]}")
    fi
    [ "${#sel[@]}" -gt 0 ] || { echo "пустая выборка" >&2; exit 2; }
    green=0; redc=0
    for r in "${sel[@]}"; do
      if run_cell "$r"; then green=$((green+1)); else redc=$((redc+1)); fi
    done
    echo "ИТОГ 120: клеток ${#sel[@]}, зелёных $green, красных $redc"
    [ "$redc" -eq 0 ] && exit 0
    exit 1
    ;;
  -*) echo "неизвестный ключ: $1" >&2; exit 2 ;;
  *)
    prod="${1:-$DEFAULT_PRODUCT}"
    [ -d "$prod/.git" ] || { echo "нечем судить: нет клона $prod" >&2; exit 2; }
    out="$("$ORACLE" "$prod" --pin "$PIN" 2>&1)"; rc=$?
    echo "ПРОДУКТ $prod: $out"
    echo "ИТОГ 120 (продукт): rc=$rc"
    exit "$rc"
    ;;
esac
