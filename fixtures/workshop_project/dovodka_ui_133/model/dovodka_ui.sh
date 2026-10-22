#!/usr/bin/env bash
# dovodka_ui.sh — шаг визуальной доводки UI после implementer (контракт 133, честная модель).
#
# Трое ворот оркестратору (шаг dovodka-ui: слово владельца 2026-10-21,
# docs/owner/2026-10-21-ekrany-bystree.md §Порядок п.2):
#   zadanie — построить задание доводчику: ТОЛЬКО при красном кадре сверки 123; модель —
#             тир vision (способность — через overlay, не хардкод); задание несёт кадры,
#             макеты, числа сверки ДОСЛОВНО и UI-зону (подмножество ЗОНА implementer
#             контракта экрана);
#   zona    — принять работу доводчика: дифф репозитория (--no-renames, оба пути
#             переименования) ⊆ UI-зона ⊆ ЗОНА implementer контракта экрана;
#   sudjam  — выдать судьям артефакт с числами похожести ДО/ПОСЛЕ на каждый кадр; кадр
#             ниже порога в ПОСЛЕ — именованный отказ ПОСЛЕ записи артефакта (числа
#             предъявлены и красному исходу).
#
# Сосед overlay.sh — механизм способностей (npm run overlay ≡ bash scripts/overlay.sh,
# package.json:18-19); сверка 123 — единственный источник чисел (KADR-строки, инвариант 4
# контракта 123): мера не переизобретается, строки читаются дословно.
#
# Коды: 0 — сделано; 1 — «ОТКАЗ dovodka: …»; 2 — «НЕЧЕМ СУДИТЬ dovodka: …».
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
OVERLAY="$SELF_DIR/overlay.sh"
CFG="$ROOT/.omp/config.yml"

otkaz()  { printf 'ОТКАЗ dovodka: %s\n' "$1" >&2; exit 1; }
nechem() { printf 'НЕЧЕМ СУДИТЬ dovodka: %s\n' "$1" >&2; exit 2; }

TMP_DIAG="$(mktemp)" || nechem 'скратч не создаётся'
trap 'rm -f "$TMP_DIAG"' EXIT

# ── сверка 123: KADR<TAB>id<TAB>score<TAB>porog<TAB>hudshij<TAB>OK|NIZHE_POROGA ──
# TAB — разделитель вне алфавитов полей (инвариант 4 контракта 123). Пустая сверка — не
# «нечего проверять», а нечем судить; вердикт пересчитывается из чисел: score<porog при
# OK — фальсификация, а не вход. Дубли кадра — то же, что KADR_NEODNOZNACHEN у 123.
parse_sverka() {
  awk -F'\t' '
    $1 == "KADR" {
      if (NF != 6 || $2 == "" || $3 !~ /^[0-9]+\.[0-9]+$/ || $4 !~ /^[0-9]+\.[0-9]+$/ || ($6 != "OK" && $6 != "NIZHE_POROGA")) {
        diag = "строка сверки вне грамматики: " $0; bad = 4; exit }
      if (($3 + 0 >= $4 + 0) != ($6 == "OK")) {
        diag = "сверка сфальсифицирована: " $2 " score=" $3 " porog=" $4 " verdikt=" $6; bad = 6; exit }
      if ($2 in seen) { diag = "кадр дважды в сверке: " $2; bad = 5; exit }
      seen[$2] = 1
      print
      k++
    }
    END {
      if (!bad && k == 0) { diag = "пустая сверка — строк KADR нет"; bad = 3 }
      if (diag != "") printf "%s\n", diag > "/dev/stderr"
      if (bad) exit bad
    }
  ' "$1"
}

SV=""
sverka_read() {  # $1 файл сверки → SV (дословные строки KADR); отказ — именованный
  SV="$(parse_sverka "$1" 2>"$TMP_DIAG")"
  local rc=$?
  case "$rc" in
    0) ;;
    3) nechem "$(cat "$TMP_DIAG")" ;;
    *) nechem "$(cat "$TMP_DIAG")" ;;
  esac
}

# ── UI-зона: файл с путями (каталог с завершающей / либо точный файл), грамматика
# ЗОНА-путей check_zones: относительно, без .., без / в начале, без glob-символов ──
ZONY=()
zona_read() {  # $1 файл UI-зоны → ZONY; пустая/вне грамматики — отказ
  [ -s "$1" ] || otkaz 'UI-зона пуста — доводчику не объявлено, где править'
  local z
  while IFS= read -r z; do
    [ -n "$z" ] || continue
    case "$z" in
      /*) otkaz "UI-зона вне грамматики (абсолютный путь): $z" ;;
      *..*) otkaz "UI-зона вне грамматики (..): $z" ;;
      *'*'*|*'?'*|*'['*) otkaz "UI-зона вне грамматики (glob-символ): $z" ;;
    esac
    ZONY+=("$z")
  done < "$1"
  [ "${#ZONY[@]}" -gt 0 ] || otkaz 'UI-зона пуста — доводчику не объявлено, где править'
}

covered() {  # $1 путь; остальные аргументы — зоны (каталог с / либо точный файл): префиксное покрытие
  local p="$1" z
  shift
  for z in "$@"; do
    case "$z" in
      */) case "$p" in "$z"*) return 0 ;; esac ;;
      *)  if [ "$p" = "$z" ]; then return 0; fi ;;
    esac
  done
  return 1
}

zona_podmnozhestvo() {  # $1 контракт экрана: каждая зона UI ⊆ ЗОНА implementer (префиксы)
  local f="$1" z
  [ -f "$f" ] || nechem "контракт экрана не читается: $f"
  local EKZ=()
  mapfile -t EKZ < <(awk '/^ЗОНА implementer:/ { for (i = 3; i <= NF; i++) print $i }' "$f")
  [ "${#EKZ[@]}" -gt 0 ] || nechem "в контракте экрана нет строк ЗОНА implementer: $f"
  for z in "${ZONY[@]}"; do
    covered "$z" "${EKZ[@]}" || otkaz "UI-зона шире зоны implementer контракта экрана: $z"
  done
}

# ── модель доводчика: тир vision из .omp/config.yml; способность — только через overlay ──
vision_model() {  # → stdout: короткое имя модели тира vision
  local ov ovrc vm
  [ -f "$OVERLAY" ] || nechem "нет механизма способностей $OVERLAY (npm run overlay)"
  ov="$(bash "$OVERLAY" --check 2>&1 >/dev/null)"; ovrc=$?
  case "$ovrc" in
    0) ;;
    1) otkaz "слой не прошёл сверку способностей (overlay rc 1): $ov" ;;
    *) nechem "способности не проверены (overlay rc $ovrc): $ov" ;;
  esac
  # строка грамматики тира — overlay.sh:126, несётся побайтово (единый источник)
  vm="$(grep -oE '^\s+vision:\s*"[^"]+"' "$CFG" | sed 's/.*"\(.*\)"/\1/' | sed 's|.*/||')"
  [ -n "$vm" ] || otkaz 'тир vision не объявлен в .omp/config.yml — некому смотреть кадры (Н-20)'
  printf '%s\n' "$vm"
}

cmd_zadanie() {  # $1 сверка $2 репо $3 ui-зона $4 контракт экрана $5 кадры $6 макеты $7 задание
  local sverka="$1" repo="$2" uiz="$3" ekran="$4" kadry="$5" makety="$6" out="$7"
  local red n vm
  sverka_read "$sverka"
  red="$(printf '%s\n' "$SV" | awk -F'\t' '$6=="NIZHE_POROGA"')"
  if [ -z "$red" ]; then otkaz 'все кадры не ниже порога — шаг не зовётся (dovodka-ui только по красному кадру)'; fi
  n="$(printf '%s\n' "$red" | grep -c .)"
  zona_read "$uiz"
  zona_podmnozhestvo "$ekran"
  vm="$(vision_model)"; vrc=$?
  # отказ/нечем из vision_model умирают в подстановке: rc проносится вручную
  # (диагностика уже напечатана в stderr самой функцией)
  if [ "$vrc" -ne 0 ]; then exit "$vrc"; fi
  {
    printf '# Задание доводки UI (шаг dovodka-ui, контракт 133)\n'
    printf 'МОДЕЛЬ: %s (тир vision, overlay rc 0)\n' "$vm"
    printf 'РЕПОЗИТОРИЙ: %s\n' "$repo"
    printf 'КАДРЫ: %s\n' "$kadry"
    printf 'МАКЕТЫ: %s\n' "$makety"
    printf 'UI-ЗОНА:\n'
    printf '%s\n' "${ZONY[@]}"
    printf 'СВЕРКА (дословно, числа похожести на каждый кадр):\n'
    printf '%s\n' "$SV"
    printf 'ЗАДАЧА: править только пути UI-ЗОНА; цикл правка → e2e → сверка 123; все кадры не ниже порога; судьям — результат с числами.\n'
  } > "$out"
  printf 'DOVODKA: задание %s; красных кадров %s\n' "$out" "$n"
}

cmd_zona() {  # $1 репо $2 база $3 ui-зона $4 контракт экрана (может быть пуст)
  local repo="$1" base="$2" uiz="$3" ekran="${4:-}"
  local changed p n=0
  command -v git >/dev/null 2>&1 || nechem 'нет git'
  zona_read "$uiz"
  if [ -n "$ekran" ]; then zona_podmnozhestvo "$ekran"; fi
  git -C "$repo" cat-file -e "${base}^{commit}" 2>/dev/null || nechem "база диффа не читается: $base"
  changed="$(git -C "$repo" diff --no-renames --name-only "$base" HEAD)" || nechem 'дифф репозитория не читается'
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    n=$((n + 1))
    covered "$p" "${ZONY[@]}" || otkaz "правка вне UI-зоны: $p"
  done <<<"$changed"
  printf 'ЗОНА: чисто (путей %s)\n' "$n"
}

cmd_sudjam() {  # $1 сверка ДО $2 сверка ПОСЛЕ $3 артефакт судьям
  local fdo="$1" fposle="$2" out="$3"
  local _ id sc po hu vd
  sverka_read "$fdo"
  local DO="$SV"
  sverka_read "$fposle"
  local PO="$SV"
  local -A POSLE=()
  local -A DO_IDS=()
  local rest pres psc ppo phu pvd
  local fk_id="" fk_sc="" fk_po=""
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    POSLE["$id"]="$sc|$po|$hu|$vd"
  done <<<"$PO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    DO_IDS["$id"]=1
  done <<<"$DO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    if [ -z "${DO_IDS[$id]+x}" ]; then otkaz "кадр появился в сверке ПОСЛЕ: $id"; fi
  done <<<"$PO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    if [ -z "${POSLE[$id]+x}" ]; then otkaz "кадр пропал из сверки ПОСЛЕ: $id"; fi
    pres="${POSLE[$id]}"
    psc="${pres%%|*}"; rest="${pres#*|}"; ppo="${rest%%|*}"; rest="${rest#*|}"; phu="${rest%%|*}"; pvd="${rest#*|}"
    if [ "$po" != "$ppo" ]; then nechem "порог кадра разошёлся между прогонами: $id ($po ≠ $ppo)"; fi
    printf 'SUD\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$sc" "$psc" "$po" "$phu" "$pvd"
    if [ "$pvd" != "OK" ]; then fk_id="$id"; fk_sc="$psc"; fk_po="$ppo"; fi
  done <<<"$DO" > "$out"
  if [ -n "$fk_id" ]; then
    otkaz "не завершена: кадр $fk_id score=$fk_sc ниже порога $fk_po — числа предъявлены в $out, шаг продолжается"
  fi
  printf 'СУДЬЯМ: числа предъявлены (кадров %s)\n' "${#DO_IDS[@]}"
}

case "${1:-}" in
  zadanie)
    shift
    A_SVERKA=""; A_REPO=""; A_UIZ=""; A_EKRAN=""; A_KADRY=""; A_MAKETY=""; A_OUT=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --sverka) A_SVERKA="$2"; shift 2 ;;
        --repo) A_REPO="$2"; shift 2 ;;
        --ui-zona) A_UIZ="$2"; shift 2 ;;
        --kontrakt-ekrana) A_EKRAN="$2"; shift 2 ;;
        --kadry) A_KADRY="$2"; shift 2 ;;
        --makety) A_MAKETY="$2"; shift 2 ;;
        --out) A_OUT="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент zadanie: $1" ;;
      esac
    done
    if [ -z "$A_SVERKA" ] || [ -z "$A_REPO" ] || [ -z "$A_UIZ" ] || [ -z "$A_EKRAN" ] || [ -z "$A_KADRY" ] || [ -z "$A_MAKETY" ] || [ -z "$A_OUT" ]; then
      nechem 'zadanie: нужны --sverka --repo --ui-zona --kontrakt-ekrana --kadry --makety --out'
    fi
    cmd_zadanie "$A_SVERKA" "$A_REPO" "$A_UIZ" "$A_EKRAN" "$A_KADRY" "$A_MAKETY" "$A_OUT"
    ;;
  zona)
    shift
    A_REPO=""; A_BASE=""; A_UIZ=""; A_EKRAN=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --repo) A_REPO="$2"; shift 2 ;;
        --base) A_BASE="$2"; shift 2 ;;
        --ui-zona) A_UIZ="$2"; shift 2 ;;
        --kontrakt-ekrana) A_EKRAN="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент zona: $1" ;;
      esac
    done
    if [ -z "$A_REPO" ] || [ -z "$A_BASE" ] || [ -z "$A_UIZ" ]; then
      nechem 'zona: нужны --repo --base --ui-zona [--kontrakt-ekrana]'
    fi
    cmd_zona "$A_REPO" "$A_BASE" "$A_UIZ" "$A_EKRAN"
    ;;
  sudjam)
    shift
    A_DO=""; A_POSLE=""; A_OUT=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --do) A_DO="$2"; shift 2 ;;
        --posle) A_POSLE="$2"; shift 2 ;;
        --out) A_OUT="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент sudjam: $1" ;;
      esac
    done
    if [ -z "$A_DO" ] || [ -z "$A_POSLE" ] || [ -z "$A_OUT" ]; then
      nechem 'sudjam: нужны --do --posle --out'
    fi
    cmd_sudjam "$A_DO" "$A_POSLE" "$A_OUT"
    ;;
  *)
    nechem "неизвестный режим: ${1:-} (zadanie|zona|sudjam)"
    ;;
esac
