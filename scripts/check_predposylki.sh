#!/usr/bin/env bash
# ГЕЙТ ПРЕДПОСЫЛОК контракта — контракт 122 «CI проекта» (Г3).
#
#   bash scripts/check_predposylki.sh <корень-проекта R> <контракт> [--freeze]
#
# Контракт, ТЕКСТ которого заявляет CI-пути (литералы `.github/workflows/` или
# `.harness/ci.json`), обязан нести поле `ПРЕДПОСЫЛКИ:` — маркер в первой колонке,
# тело до первой пустой строки, — с пунктами замкнутой грамматики:
#     - secret NAME | - variable NAME | - environment NAME | - setting <текст>
# Имя secret/variable — [A-Z][A-Z0-9_]* (тот же алфавит, что и ссылки secrets.X /
# vars.X в workflow: иначе объявление нечего сверять).
# Контракт без CI-путей поля не требует (rc 0 без запуска gh).
#
# --freeze: каждый объявленный secret/variable обязан существовать в репозитории
# проекта (`gh secret|variable list -R <origin>`); отсутствует — sekrety-ne-zavedeny:
# NAME; gh недоступен или сломан — gh-nedostupen (fail-closed, не молчание).
#
# Коды возврата: 0 — поле есть и грамматично (PREDPOSYLKI_OK …); 1 — именованный
# отказ из алфавита 122 (`predposylki ОТКАЗ: <причина>[: детали]` на stderr); 2 —
# ошибка вызова (неизвестный ключ, нет аргумента, контракт не читается). Отказ с
# rc 0 — дефект: pre_critic и freeze_contract судят КОД возврата этого гейта.
set -u

R=""
C=""
FREEZE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --freeze) FREEZE=1 ;;
    -h|--help)
      printf 'usage: check_predposylki.sh <R> <контракт> [--freeze]\n'
      exit 0 ;;
    -*) printf 'predposylki ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
    *)  if [ -z "$R" ]; then R=$1
        elif [ -z "$C" ]; then C=$1
        else printf 'predposylki ОТКАЗ: лишний аргумент: %s\n' "$1" >&2; exit 2
        fi ;;
  esac
  shift
done
[ -n "$R" ] && [ -n "$C" ] || {
  printf 'predposylki ОТКАЗ: usage: check_predposylki.sh <R> <контракт> [--freeze]\n' >&2
  exit 2
}
[ -f "$C" ] && [ -r "$C" ] || {
  printf 'predposylki ОТКАЗ: контракт не читается: %s\n' "$C" >&2
  exit 2
}

# Поле: маркер в первой колонке, тело — до первой пустой строки.
FIELD="$(awk '/^ПРЕДПОСЫЛКИ:/{inside=1; next} inside { if ($0 == "") exit; print }' "$C")"

# CI-пути заявлены текстом контракта (буквально) — тогда поле обязано быть.
if grep -Fq '.github/workflows/' "$C" || grep -Fq '.harness/ci.json' "$C"; then
  [ -n "$FIELD" ] || {
    printf 'predposylki ОТКАЗ: predposylki-otsutstvuyut\n' >&2
    exit 1
  }
fi

# Грамматика пункта: один из четырёх видов, ничего постороннего.
count_secrets=0; count_variables=0; count_environments=0; count_settings=0
list_names() { # вид — $1; печатает NAME по строке вида
  printf '%s\n' "$FIELD" | while IFS= read -r line; do
    case "$line" in
      "- $1 "*) printf '%s\n' "${line#"- $1 "}" ;;
    esac
  done
}
while IFS= read -r line; do
  [ -n "$line" ] || continue
  name=${line#- }
  case "$name" in
    "secret "*|"variable "*)
      kind=${name%% *}; value=${name#* }
      case "$value" in
        [A-Z]*)
          case "$value" in
            *[!A-Z0-9_]*) ;;
            *) [ "$kind" = secret ] && count_secrets=$((count_secrets+1)) \
                 || count_variables=$((count_variables+1)); continue ;;
          esac ;;
      esac
      printf 'predposylki ОТКАЗ: predposylki-nevaliden: %s\n' "$line" >&2
      exit 1 ;;
    "environment "*)
      value=${name#* }
      [ -n "$value" ] || {
        printf 'predposylki ОТКАЗ: predposylki-nevaliden: %s\n' "$line" >&2
        exit 1
      }
      count_environments=$((count_environments+1)) ;;
    "setting "*)
      value=${name#* }
      [ -n "$value" ] || {
        printf 'predposylki ОТКАЗ: predposylki-nevaliden: %s\n' "$line" >&2
        exit 1
      }
      count_settings=$((count_settings+1)) ;;
    *)
      printf 'predposylki ОТКАЗ: predposylki-nevaliden: %s\n' "$line" >&2
      exit 1 ;;
  esac
done <<EOF
$FIELD
EOF

if [ "$FREEZE" = 1 ] && [ $((count_secrets + count_variables)) -gt 0 ]; then
  command -v gh >/dev/null 2>&1 || {
    printf 'predposylki ОТКАЗ: gh-nedostupen: нет gh в PATH\n' >&2
    exit 1
  }
  REMOTE="$(git -C "$R" remote get-url origin 2>/dev/null || true)"
  # Сверка fail-closed: пустой origin у репозитория без remote — не «всё заведено».
  if [ -z "$REMOTE" ]; then
    printf 'predposylki ОТКАЗ: gh-nedostupen: у %s нет origin\n' "$R" >&2
    exit 1
  fi
  # Инвентарь спрашивается по тому виду, который контракт ОБЪЯВИЛ: не объявлено —
  # нечего и спрашивать (лишний вызов gh был бы отказом без предмета проверки).
  check_kind() { # вид — $1
    local kind=$1 out gh_rc=0 name
    out="$(gh "$kind" list -R "$REMOTE" 2>/dev/null)" || gh_rc=$?
    [ "$gh_rc" -eq 0 ] || {
      printf 'predposylki ОТКАЗ: gh-nedostupen: gh %s list rc=%d\n' "$kind" "$gh_rc" >&2
      exit 1
    }
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      printf '%s\n' "$out" | awk -v n="$name" '$1 == n { found = 1 } END { exit !found }' || {
        printf 'predposylki ОТКАЗ: sekrety-ne-zavedeny: %s\n' "$name" >&2
        exit 1
      }
    done <<EOF
$(list_names "$kind")
EOF
  }
  [ "$count_secrets" -gt 0 ] && check_kind secret
  [ "$count_variables" -gt 0 ] && check_kind variable
fi

printf 'PREDPOSYLKI_OK secrets=%d variables=%d environments=%d settings=%d\n' \
  "$count_secrets" "$count_variables" "$count_environments" "$count_settings"
exit 0