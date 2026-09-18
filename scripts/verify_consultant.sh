#!/usr/bin/env bash
# Барьер анти-плацебо для ответов консультанта (контракт 029, Q2/Н-104).
#
# Грамматика ответа (инв. 8) + переисполнение команд с белым списком + граница Г1–Г4
# арбитража. Реализует инварианты 8–10 контракта; инварианты 1–7 живут в
# check_fork_route.sh.
#
# Коды возврата: 0 — порядок, 1 — нарушение (поимённое), 2 — нечем проверить
# (нет git/sha256sum/date -d).

set -uo pipefail

# ── аргументы ────────────────────────────────────────────────────────────────
ROOT=""
OTVET=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)  ROOT="$2"; shift 2 ;;
    --otvet) OTVET="$2"; shift 2 ;;
    -h|--help)
      printf 'usage: verify_consultant.sh --root <корень> --otvet <файл ответа>\n' >&2
      exit 2 ;;
    *) printf 'verify_consultant.sh: неизвестный аргумент «%s»\n' "$1" >&2; exit 2 ;;
  esac
done

[ -n "$ROOT" ] || { printf 'verify_consultant.sh: --root обязателен\n' >&2; exit 2; }
[ -n "$OTVET" ] || { printf 'verify_consultant.sh: --otvet обязателен\n' >&2; exit 2; }
[ -d "$ROOT" ] || { printf 'verify_consultant.sh: --root %s не каталог\n' "$ROOT" >&2; exit 2; }
[ -r "$OTVET" ] || { printf 'verify_consultant.sh: --otvet %s не читается\n' "$OTVET" >&2; exit 2; }

# ── инструменты ──────────────────────────────────────────────────────────────
for tool in git sha256sum date; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'verify_consultant.sh: нет инструмента %s\n' "$tool" >&2
    exit 2
  fi
done
date -d @0 >/dev/null 2>&1 || { printf 'verify_consultant.sh: date -d не работает\n' >&2; exit 2; }

# ── нормализация вывода (единая с каркасом проб) ─────────────────────────────
# Захват `$( )` отбрасывает завершающие LF; `printf '%s' | sha256sum`.
sha_vyvoda() {  # <stdout+stderr многострочно>
  printf '%s' "$1" | sha256sum | cut -d' ' -f1
}

# ── разбор ответа ────────────────────────────────────────────────────────────
# Шапка: ПРЕДМЕТ / МОДЕЛЬ / ВОПРОС / РЕКОМЕНДАЦИЯ.
# Блок: ОСНОВАНИЕ-ДЕРЕВО с тройками КОМАНДА / RC / ВЫВОД-SHA256.
RESP="$(cat "$OTVET")"

resp_field() {  # <имя поля>
  printf '%s\n' "$RESP" | sed -n "s/^${1}:[[:space:]]*//p" | head -n 1
}

PREDMET="$(resp_field ПРЕДМЕТ)"
MODEL="$(resp_field МОДЕЛЬ)"
VOOPROS="$(resp_field ВОПРОС)"
REKOM="$(resp_field РЕКОМЕНДАЦИЯ)"

if [ -z "$MODEL" ]; then
  printf 'ответ без строки МОДЕЛЬ — запрет двойной роли ненаблюдаем\n' >&2
  exit 1
fi

# Блок ОСНОВАНИЕ-ДЕРЕВО.
if ! printf '%s\n' "$RESP" | grep -q '^ОСНОВАНИЕ-ДЕРЕВО:'; then
  printf 'нет блока ОСНОВАНИЕ-ДЕРЕВО в ответе — утверждение о дереве с нулевой выборкой, просмотрено 0 команд\n' >&2
  exit 1
fi

# Извлекаем содержимое блока (все строки после «ОСНОВАНИЕ-ДЕРЕВО:» до конца файла).
BLOCK="$(printf '%s\n' "$RESP" | sed -n '/^ОСНОВАНИЕ-ДЕРЕВО:/,$p' | sed '1d')"

# Сколько троек КОМАНДА / RC / ВЫВОД-SHA256.
KOMAND_COUNT="$(printf '%s\n' "$BLOCK" | grep -c '^КОМАНДА:')"
if [ "${KOMAND_COUNT:-0}" -eq 0 ]; then
  printf 'блок ОСНОВАНИЕ-ДЕРЕВО без единой тройки КОМАНДА/RC/ВЫВОД-SHA256 — просмотрено 0 команд\n' >&2
  exit 1
fi

# ── БЕЛЫЙ СПИСОК readonly-глаголов и опций (закрытый) ────────────────────────
ALLOWED_VERBS='git sha256sum cat ls'
ALLOWED_GIT_SUBS='status log diff ls-files rev-parse cat-file show'
ALLOWED_OPTS='--porcelain --short --stat --name-only --name-status --cached --verify --quiet -1 -n -p -s -t'

# Метасимволы, запрещённые ВСЕГДЕ.
FORBIDDEN_META=';|&$><`'"'"''

# ── проверка строки команды: метасимволы ─────────────────────────────────────
contains_forbidden() {  # <строка>  → 0 если нашёлся метасимвол
  case "$1" in *"$FORBIDDEN_META"*) return 0 ;; *) return 1 ;; esac
}

# Сбор троек из блока. Каждая тройка — последовательные КОМАНДА / RC / ВЫВОД-SHA256.
TRIPLE_NUM=0
CURRENT_KOMANDA=""
CURRENT_RC=""
CURRENT_SHA=""
TRIPLES=()  # строки «команда\trc\tsha»

emit_triple() {
  if [ -n "$CURRENT_KOMANDA" ] && [ -n "$CURRENT_RC" ] && [ -n "$CURRENT_SHA" ]; then
    TRIPLES+=("$CURRENT_KOMANDA"$'\t'"$CURRENT_RC"$'\t'"$CURRENT_SHA")
    TRIPLE_NUM=$((TRIPLE_NUM + 1))
  fi
  CURRENT_KOMANDA=""; CURRENT_RC=""; CURRENT_SHA=""
}

while IFS= read -r line; do
  case "$line" in
    'КОМАНДА:'*)   emit_triple; CURRENT_KOMANDA="${line#КОМАНДА: }" ;;
    'RC:'*)        CURRENT_RC="${line#RC: }" ;;
    'ВЫВОД-SHA256:'*) CURRENT_SHA="${line#ВЫВОД-SHA256: }" ;;
    *)             emit_triple ;;
  esac
done <<< "$BLOCK"
emit_triple

if [ "$TRIPLE_NUM" -eq 0 ]; then
  printf 'ни одной полной тройки КОМАНДА/RC/ВЫВОД-SHA256 — просмотрено 0 команд\n' >&2
  exit 1
fi

# ── Г2 (конфиг-гейт, ДО первого переисполнения) ─────────────────────────────
# Сканируем локальный конфиг проверяемого корня под Г1: env-скраб +
# `git config --list --local`. Судятся КЛЮЧИ закрытым перечнем.
EMPTY_HOOKS_DIR="$(mktemp -d "${TMPDIR:-/tmp}/v029-empty-hooks.XXXXXX")"

env -i PATH="$PATH" LC_ALL=C.UTF-8 \
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
  git -C "$ROOT" config --list --local > "$ROOT/.v029-config-scan" 2> "$ROOT/.v029-config-scan.err"
SCAN_RC=$?
if [ "$SCAN_RC" -ne 0 ]; then
  printf 'конфиг вне белого списка — скан git config --list --local упал с rc %s\n' "$SCAN_RC" >&2
  rm -f "$ROOT/.v029-config-scan" "$ROOT/.v029-config-scan.err"
  rm -rf "$EMPTY_HOOKS_DIR"
  exit 1
fi

ALLOWED_KEYS='core.repositoryformatversion core.filemode core.bare core.logallrefupdates core.ignorecase core.precomposeunicode core.symlinks'

while IFS='=' read -r key value; do
  # Пустые строки и комментарии.
  [ -z "$key" ] && continue
  case "$key" in '['*) continue ;; '#'*) continue ;; esac
  ok=0
  for ak in $ALLOWED_KEYS; do [ "$ak" = "$key" ] && ok=1; done
  if [ "$ok" != "1" ]; then
    printf 'конфиг вне белого списка: ключ «%s» не входит в закрытый перечень\n' "$key" >&2
    rm -f "$ROOT/.v029-config-scan" "$ROOT/.v029-config-scan.err"
    rm -rf "$EMPTY_HOOKS_DIR"
    exit 1
  fi
done < "$ROOT/.v029-config-scan"
rm -f "$ROOT/.v029-config-scan" "$ROOT/.v029-config-scan.err"

# ── Г4 (субмодули, ДО первого переисполнения) ────────────────────────────────
env -i PATH="$PATH" LC_ALL=C.UTF-8 \
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
  git -C "$ROOT" ls-files -s > "$ROOT/.v029-ls-files-scan" 2> "$ROOT/.v029-ls-files-scan.err"
SCAN_RC=$?
if [ "$SCAN_RC" -ne 0 ]; then
  printf 'субмодуль вне границы — скан git ls-files -s упал с rc %s\n' "$SCAN_RC" >&2
  rm -f "$ROOT/.v029-ls-files-scan" "$ROOT/.v029-ls-files-scan.err"
  rm -rf "$EMPTY_HOOKS_DIR"
  exit 1
fi

SUBMODULE_PATH=""
# Формат `git ls-files -s`: «mode SP hash SP stage TAB path». Нас интересует path — ПОСЛЕДНЕЕ поле.
# Используем awk, чтобы не возиться с пробельными границами.
SUBMODULE_PATH="$(awk '$1 == "160000" { print $NF; exit }' "$ROOT/.v029-ls-files-scan")"
rm -f "$ROOT/.v029-ls-files-scan" "$ROOT/.v029-ls-files-scan.err"

if [ -n "$SUBMODULE_PATH" ]; then
  printf 'субмодуль вне границы: гитлинк «%s» (mode 160000) — конфиг субмодуля недостижим для скана корня\n' "$SUBMODULE_PATH" >&2
  rm -rf "$EMPTY_HOOKS_DIR"
  exit 1
fi

# ── ПЕРЕИСПОЛНЕНИЕ КАЖДОЙ ТРОЙКИ (Г1 + Г3) ──────────────────────────────────
declare -a ORACLE_RC=()
declare -a ORACLE_SHA=()
declare -a TRIPLE_RC=()
declare -a TRIPLE_SHA=()
declare -a TRIPLE_CMD=()

for triple in "${TRIPLES[@]}"; do
  # Triple: «cmd\trc\tsha». Разделяем по ПЕРВОМУ табу, потом — по второму в остатке.
  cmd="${triple%%$'\t'*}"
  rest="${triple#*$'\t'}"
  claimed_rc="${rest%%$'\t'*}"
  claimed_sha="${rest#*$'\t'}"
  TRIPLE_CMD+=("$cmd")
  TRIPLE_RC+=("$claimed_rc")
  TRIPLE_SHA+=("$claimed_sha")

  # 1) Метасимволы в команде.
  if contains_forbidden "$cmd"; then
    printf 'вне белого списка: метасимвол в команде — исполнение чужого кода запрещено: %s\n' \
           "$cmd" >&2
    exit 1
  fi

  # 2) Разбор в argv. Команда НЕ префикс — это argv[0].
  # shellcheck disable=SC2206
  argv=( $cmd )
  if [ "${#argv[@]}" -eq 0 ]; then
    printf 'вне белого списка: пустая команда\n' >&2
    exit 1
  fi
  verb="${argv[0]}"

  # 3) Глагол из перечня?
  verb_ok=0
  for v in $ALLOWED_VERBS; do [ "$v" = "$verb" ] && verb_ok=1; done
  if [ "$verb_ok" != "1" ]; then
    printf 'вне белого списка: глагол «%s» не входит в перечень readonly: %s\n' "$verb" "$cmd" >&2
    exit 1
  fi

  # 4) Для git — argv[1] из подперечня.
  if [ "$verb" = "git" ]; then
    if [ "${#argv[@]}" -lt 2 ]; then
      printf 'вне белого списка: «git» без подкоманды: %s\n' "$cmd" >&2
      exit 1
    fi
    sub="${argv[1]}"
    sub_ok=0
    for s in $ALLOWED_GIT_SUBS; do [ "$s" = "$sub" ] && sub_ok=1; done
    if [ "$sub_ok" != "1" ]; then
      printf 'вне белого списка: «git %s» не входит в подперечень: %s\n' "$sub" "$cmd" >&2
      exit 1
    fi
  fi

  # 5) Каждый аргумент, начинающийся с «-», обязан ТОЧНО совпасть с белым списком
  #    опций либо иметь форму --format=<…>.
  for arg in "${argv[@]:1}"; do
    case "$arg" in
      --) ;;   # конец опций — после него всё аргументы, не опции
      -)
        printf 'опция вне белого списка: «%s» в команде %s\n' "$arg" "$cmd" >&2
        exit 1 ;;
      --format=*) ;;  # разрешённая форма
      -*)
        arg_ok=0
        for o in $ALLOWED_OPTS; do [ "$o" = "$arg" ] && arg_ok=1; done
        if [ "$arg_ok" != "1" ]; then
          printf 'опция вне белого списка: «%s» в команде %s\n' "$arg" "$cmd" >&2
          exit 1
        fi
        ;;
      *) ;;  # позиционные аргументы — пока пропускаем (для git-подкоманд без путей
             # их нет, для cat/ls/sha256sum — допустимо; канал записи ими не открывается)
    esac
  done

  # 6) Переисполнение под Г1 + Г3. Для git подставляем `-c core.hooksPath=<empty>` и
  #    `-C <root>`. Исполнение — в каталоге ROOT, как требует проверяющий.
  if [ "$verb" = "git" ]; then
    # собираем команду с `-c core.hooksPath=<пусто> -C <root>`, далее сама команда.
    # Исходный argv[1..] подставляется без изменений.
    git_cmd=( env -i PATH="$PATH" LC_ALL=C.UTF-8 \
              GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
              git -c "core.hooksPath=$EMPTY_HOOKS_DIR" -C "$ROOT" )
    for a in "${argv[@]:1}"; do git_cmd+=("$a"); done
    out="$("${git_cmd[@]}" 2>&1)"; rc=$?
  else
    # sha256sum / cat / ls
    out="$( env -i PATH="$PATH" LC_ALL=C.UTF-8 \
            GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
            bash -c "cd '$ROOT' && $cmd" 2>&1 )"
    rc=$?
  fi

  ORACLE_RC+=("$rc")
  ORACLE_SHA+=("$(sha_vyvoda "$out")")
done

# ── СВЕРКА заявленных rc/sha со своими ──────────────────────────────────────
for i in "${!TRIPLES[@]}"; do
  cmd="${TRIPLE_CMD[$i]}"
  claimed_rc="${TRIPLE_RC[$i]}"
  claimed_sha="${TRIPLE_SHA[$i]}"
  got_rc="${ORACLE_RC[$i]}"
  got_sha="${ORACLE_SHA[$i]}"

  if [ "$claimed_rc" != "$got_rc" ]; then
    printf 'расхождение rc: заявлено %s, получено %s — %s\n' \
           "$claimed_rc" "$got_rc" "$cmd" >&2
    rm -rf "$EMPTY_HOOKS_DIR"
    exit 1
  fi

  if [ "$claimed_sha" != "$got_sha" ]; then
    printf 'расхождение вывода: заявлено %s, получено %s — %s\n' \
           "$claimed_sha" "$got_sha" "$cmd" >&2
    rm -rf "$EMPTY_HOOKS_DIR"
    exit 1
  fi
done

rm -rf "$EMPTY_HOOKS_DIR"
exit 0