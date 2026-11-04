#!/usr/bin/env bash
# check-coding-standards-context.sh — приёмка contextPack для docs/CODING-STANDARDS.md
# (контракт харнесса 162): стандарт кода обязан попадать в пакет КАЖДОЙ из ролей
# architect, implementer, reviewer, adversary как самостоятельная точная строка
# секции RULES, не вытесняя прочие профильные правила.
#
# Запуск из корня продукта:
#   bash mobile/scripts/check-coding-standards-context.sh \
#     --repo . --contract <NNN замороженного контракта проекта> \
#     --make-task <корень-харнесса>/scripts/make_task.sh
#
# Для каждой роли R скрипт:
#   1. читает harness.project.json и требует строку contextPack kind=rules,
#      path=docs/CODING-STANDARDS.md, mandatory=true, в roles которой есть R;
#   2. запускает `make_task.sh --repo <repo> --role R --contract <NNN>` и берёт пакет
#      (rc make_task ≠ 0 — отказ роли с причиной make_task, а не молчаливый пропуск);
#   3. сверяет СЕКЦИЮ `=== RULES ===` пакета: точная самостоятельная строка
#      `RULES: docs/CODING-STANDARDS.md` и точные строки `RULES: <path>` каждой
#      прочей применимой к R строки kind=rules профиля (потеря любой — отказ);
#      совпадение подстроки или строки вне секции RULES не засчитывается;
#   4. сверяет строку манифеста `rules<TAB>docs/CODING-STANDARDS.md<TAB>mandatory<TAB>profile`.
# Для роли reviewer дверь make_task требует выданного задания (--task-file); скрипт
# подаёт ей служебный временный файл — состав секции RULES от него не зависит.
#
# Коды возврата: 0 — все четыре роли подтверждены; 1 — именованный отказ (роль и
# отсутствующее правило названы); 2 — нечем проверить (аргументы, jq, make_task,
# harness.project.json).

set -uo pipefail
export LC_ALL=C.UTF-8

RULE_PATH="docs/CODING-STANDARDS.md"
ROLES=(architect implementer reviewer adversary)
TAB=$'\t'

nope() { printf 'ОШИБКА (нечем проверить): %s\n' "$*" >&2; exit 2; }
usage() {
  printf 'usage: check-coding-standards-context.sh --repo R --contract NNN --make-task <путь>/make_task.sh\n' >&2
  exit 2
}

REPO=""; CONTRACT=""; MAKE_TASK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)      [ $# -ge 2 ] || usage; REPO="$2"; shift 2 ;;
    --contract)  [ $# -ge 2 ] || usage; CONTRACT="$2"; shift 2 ;;
    --make-task) [ $# -ge 2 ] || usage; MAKE_TASK="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$CONTRACT" ] && [ -n "$MAKE_TASK" ] || usage

command -v jq >/dev/null 2>&1 || nope "нет jq"
case "$CONTRACT" in ''|*[!0-9]*) nope "номер контракта вне алфавита цифр: $CONTRACT" ;; esac
[ -d "$REPO" ] || nope "репозитория нет: $REPO"
PROFILE="$REPO/harness.project.json"
[ -f "$PROFILE" ] || nope "нет профиля: $PROFILE"
[ -f "$MAKE_TASK" ] || nope "нет make_task: $MAKE_TASK"
jq -e '.contextPack.rows | type == "array"' "$PROFILE" >/dev/null 2>&1 \
  || nope "профиль без массива contextPack.rows или не JSON: $PROFILE"

WORK="$(mktemp -d)" || nope "mktemp"
trap 'rm -rf "$WORK"' EXIT
TASKF="$WORK/task.txt"
printf 'check-coding-standards-context: служебное задание для сборки пакета роли reviewer\n' > "$TASKF"

# Строки kind=rules профиля, применимые к роли: «путь TAB mandatory».
rules_for_role() {
  jq -r --arg r "$1" '
    .contextPack.rows[]?
    | select(.kind == "rules")
    | select(((.roles // "") | split(",") | map(gsub("^\\s+|\\s+$"; "")) | index($r)) != null)
    | [.path, (.mandatory | tostring)] | @tsv' "$PROFILE"
}

# Все строки с путём стандарта (для диагностики роли/обязательности).
standard_rows() {
  jq -r --arg p "$RULE_PATH" '
    .contextPack.rows[]?
    | select(.path == $p)
    | [.kind, (.roles // ""), (.mandatory | tostring)] | @tsv' "$PROFILE"
}

failed_roles=()
ok_roles=0

for role in "${ROLES[@]}"; do
  declare -a fails=()
  fails=()

  # 1. Профиль: строка kind=rules path=стандарт mandatory=true с этой ролью.
  std_row_ok=0
  other_rules=()
  while IFS="$TAB" read -r path mnd; do
    [ -n "${path:-}" ] || continue
    if [ "$path" = "$RULE_PATH" ]; then
      [ "$mnd" = "true" ] && std_row_ok=1
    else
      # Необязательная строка с отсутствующим файлом make_task молча пропускает.
      if [ "$mnd" != "true" ] && [ ! -f "$REPO/$path" ]; then continue; fi
      other_rules+=("$path")
    fi
  done < <(rules_for_role "$role")
  if [ "$std_row_ok" -ne 1 ]; then
    detail="$(standard_rows | tr '\t' '|' | paste -sd';' -)"
    fails+=("в harness.project.json нет строки kind=rules path=$RULE_PATH mandatory=true с ролью $role${detail:+ (строки с этим путём: $detail)}")
  fi

  # 2. Пакет роли.
  extra=()
  [ "$role" = "reviewer" ] && extra=(--task-file "$TASKF")
  pack="$(bash "$MAKE_TASK" --repo "$REPO" --role "$role" --contract "$CONTRACT" "${extra[@]}" 2>"$WORK/err.txt")"
  mt_rc=$?
  if [ "$mt_rc" -ne 0 ]; then
    fails+=("make_task отказал rc=$mt_rc: $(head -n 1 "$WORK/err.txt")")
  else
    # 3. Секция RULES: самостоятельные точные строки.
    mapfile -t rules_sec < <(printf '%s\n' "$pack" | awk '/^=== RULES ===$/{f=1; next} /^=== /{f=0} f')
    has_line() { local want="$1" l; for l in "${rules_sec[@]}"; do [ "$l" = "$want" ] && return 0; done; return 1; }
    has_line "RULES: $RULE_PATH" || fails+=("в секции RULES пакета нет самостоятельной строки «RULES: $RULE_PATH»")
    for p in "${other_rules[@]}"; do
      has_line "RULES: $p" || fails+=("в секции RULES пакета потеряно прочее правило профиля: нет строки «RULES: $p»")
    done
    # 4. Манифест: правило обязательно и профильного происхождения.
    mapfile -t man_sec < <(printf '%s\n' "$pack" | awk '/^=== MANIFEST ===$/{f=1; next} /^=== /{f=0} f')
    man_ok=0
    for l in "${man_sec[@]}"; do
      [ "$l" = "rules${TAB}${RULE_PATH}${TAB}mandatory${TAB}profile" ] && man_ok=1
    done
    [ "$man_ok" -eq 1 ] || fails+=("в манифесте пакета нет строки rules/$RULE_PATH/mandatory/profile")
  fi

  if [ "${#fails[@]}" -eq 0 ]; then
    ok_roles=$((ok_roles + 1))
    printf 'OK роль %s: «RULES: %s» + %d прочих правил профиля в секции RULES; манифест mandatory\n' "$role" "$RULE_PATH" "${#other_rules[@]}"
  else
    failed_roles+=("$role")
    for f in "${fails[@]}"; do printf 'FAIL роль %s: %s\n' "$role" "$f"; done
  fi
done

if [ "$ok_roles" -eq "${#ROLES[@]}" ]; then
  printf 'РЕЗУЛЬТАТ: OK (%d из %d ролей: %s)\n' "$ok_roles" "${#ROLES[@]}" "${ROLES[*]}"
  exit 0
fi
printf 'РЕЗУЛЬТАТ: FAIL (роли без подтверждения: %s)\n' "${failed_roles[*]}"
exit 1
