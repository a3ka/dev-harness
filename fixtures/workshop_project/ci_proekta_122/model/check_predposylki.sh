#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ гейта предпосылок — контракт 122 «CI проекта» (Г3).
# Субъект-интерфейс: check_predposylki.sh <корень-проекта R> <контракт C> [--freeze].
# Контракт, текст которого заявляет CI-пути (.github/workflows/ или .harness/ci.json),
# обязан нести поле ПРЕДПОСЫЛКИ: (до первой пустой строки) с пунктами замкнутой грамматики:
#   - secret NAME | - variable NAME | - environment NAME | - setting <текст>
# --freeze: каждый secret/variable обязан существовать в репозитории (gh … list -R <origin>);
# недоступный/сломанный gh — отказ gh-nedostupen (fail-closed), не молчаливое зелёное.
set -u
R=; C=; FREEZE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --freeze) FREEZE=1 ;;
    -*) printf 'predposylki ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
    *) if [ -z "$R" ]; then R=$1; elif [ -z "$C" ]; then C=$1; else
         printf 'predposylki ОТКАЗ: лишний аргумент: %s\n' "$1" >&2; exit 2; fi ;;
  esac
  shift
done
if [ -z "$R" ] || [ -z "$C" ]; then
  printf 'predposylki ОТКАЗ: usage: check_predposylki.sh <R> <контракт> [--freeze]\n' >&2
  exit 2
fi
[ -f "$C" ] || { printf 'predposylki ОТКАЗ: контракт не найден: %s\n' "$C" >&2; exit 2; }

FIELD=$(awk '/^ПРЕДПОСЫЛКИ:/{f=1;next} f{if($0=="")exit; print}' "$C")
if grep -Fq '.github/workflows/' "$C" || grep -Fq '.harness/ci.json' "$C"; then
  if [ -z "$FIELD" ]; then
    printf 'predposylki ОТКАЗ: predposylki-otsutstvuyut\n' >&2
    exit 1
  fi
fi
NSE=0; NVA=0; NEN=0; NST=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in
    '- secret '[A-Z]*)  NSE=$((NSE+1)) ;;
    '- variable '[A-Z]*) NVA=$((NVA+1)) ;;
    '- environment '*)   NEN=$((NEN+1)) ;;
    '- setting '*)       NST=$((NST+1)) ;;
    *)
      printf 'predposylki ОТКАЗ: predposylki-nevaliden: %s\n' "$line" >&2
      exit 1 ;;
  esac
done <<EOF
$FIELD
EOF

if [ "$FREEZE" = 1 ] && [ $((NSE + NVA)) -gt 0 ]; then
  REMOTE=$(git -C "$R" remote get-url origin 2>/dev/null) || REMOTE=""
  command -v gh >/dev/null 2>&1 || { printf 'predposylki ОТКАЗ: gh-nedostupen\n' >&2; exit 1; }
  check_kind() { # $1=secret|variable $2=NAME
    local out
    out=$(gh "$1" list -R "$REMOTE" 2>/dev/null) || { printf 'predposylki ОТКАЗ: gh-nedostupen\n' >&2; exit 1; }
    printf '%s\n' "$out" | awk -v n="$2" '$1==n{ok=1} END{exit !ok}' || {
      printf 'predposylki ОТКАЗ: sekrety-ne-zavedeny: %s\n' "$2" >&2
      exit 1
    }
  }
  while IFS= read -r line; do
    case "$line" in
      '- secret '*)    check_kind secret "${line#- secret }" ;;
      '- variable '*)  check_kind variable "${line#- variable }" ;;  # МУТАЦИЯ-122:freeze-variable
    esac
  done <<EOF
$FIELD
EOF
fi
printf 'PREDPOSYLKI_OK secrets=%d variables=%d environments=%d settings=%d\n' "$NSE" "$NVA" "$NEN" "$NST"
exit 0
