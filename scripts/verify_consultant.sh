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

# ── инструменты (код 2 «нечем проверить») ───────────────────────────────────
# Проверка РЕАЛЬНЫМ вызовом, а не `command -v` — обёртка с тем же именем в PATH
# проходит `command -v` и не проходит фактический запуск (находка 2 адверсария:
# fake_sha_rc127 rc=0 при sha256sum-обёртке, печатающей "deadbeef  -" и выходящей
# в 127). sha256sum сверяется на ИЗВЕСТНОМ пустом вводе: выходной хеш обязан
# совпасть, иначе обёртка-плацебо тоже не пройдёт.
# ИНВ. 10 (арбитраж tcb-granica-put-029.md §3, замер 3c): rc привязывается
# НЕЗАВИСИМО от текста — обёртка, печатающая корректный empty-hash и выходящая
# ненулём (1 или 127), иначе проходит текстовую сверку. Успех = верный ТЕКСТ И
# нулевой rc; отказ — rc=2 «нечем проверить». Семантика инв. 10:
# сломанный ИНСТРУМЕНТ не вменяется консультанту как ложь (замер M4 арбитража).
EXPECTED_EMPTY_SHA='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
GOT_EMPTY_SHA="$(printf '' | sha256sum | cut -d' ' -f1)"
SHA_RC=$?
if [ "$SHA_RC" -ne 0 ]; then
  printf 'verify_consultant.sh: sha256sum непригоден — нечем проверить (rc=%s)\n' "$SHA_RC" >&2
  exit 2
fi
if [ "$GOT_EMPTY_SHA" != "$EXPECTED_EMPTY_SHA" ]; then
  printf 'verify_consultant.sh: sha256sum не работает (ожидался %s, получен %s)\n' \
         "$EXPECTED_EMPTY_SHA" "$GOT_EMPTY_SHA" >&2
  exit 2
fi
command -v git >/dev/null 2>&1 || { printf 'verify_consultant.sh: нет инструмента git\n' >&2; exit 2; }
command -v date >/dev/null 2>&1 || { printf 'verify_consultant.sh: нет инструмента date\n' >&2; exit 2; }
date -d @0 >/dev/null 2>&1 || { printf 'verify_consultant.sh: date -d не работает\n' >&2; exit 2; }

# ── TRUSTED_PATH для `env -i` (Г1 арбитража, находка 2 адверсария круга 2) ───
# ЗАКРЫТЫЙ env-allowlist требует, чтобы PATH внутри `env -i` НЕ зависел от
# PATH вызывающего: иначе PATH-обёртка для git/sha256sum/cat/ls проходит
# проверку, консультант выдаёт «честные» числа, а обёртка исполняется
# (`path-git-wrapper rc=0; path-git-marker=yes`). Проверяем каждую утилиту
# по АБСОЛЮТНОМУ пути в фиксированном списке системных каталогов — `/usr/bin`
# и `/bin` (на этом дистрибутиве). Если утилиты нет ни в одном из них,
# отказываем rc=2 «нечем проверить» — это та же семантика, что у command -v.
TRUSTED_PATH=''
for tool in git sha256sum cat ls; do
  if [ -x "/usr/bin/$tool" ]; then
    case ":$TRUSTED_PATH:" in *:/usr/bin:*) ;; *) TRUSTED_PATH="${TRUSTED_PATH:+$TRUSTED_PATH:}/usr/bin" ;; esac
  elif [ -x "/bin/$tool" ]; then
    case ":$TRUSTED_PATH:" in *:/bin:*) ;; *) TRUSTED_PATH="${TRUSTED_PATH:+$TRUSTED_PATH:}/bin" ;; esac
  else
    printf 'verify_consultant.sh: нет инструмента %s в /usr/bin или /bin\n' "$tool" >&2
    exit 2
  fi
done

# ── нормализация вывода (единая с каркасом проб) ─────────────────────────────
# Захват `$( )` отбрасывает завершающие LF; `printf '%s' | sha256sum`.
# ПОШАГОВЫЙ вызов конвейера с проверкой КАЖДОГО rc: обёртка-sha256sum, печатающая
# «deadbeef  -» и выходящая в 127, в однострочном конвейере молча возвращает
# «deadbeef» через `cut` (находка 2 адверсария, fake_sha_rc127 rc=0). Здесь
# `${PIPESTATUS[@]}` проверяется ДО возврата значения — фейковая обёртка роняет
# rc 2, и вызывающий код видит расхождение rc/вывода.
sha_vyvoda() {  # <stdout+stderr многострочно>
  local out rc_sum
  out="$(printf '%s' "$1" | sha256sum)"
  rc_sum=$?
  [ "$rc_sum" -eq 0 ] || {
    printf 'sha_vyvoda: sha256sum провалился rc=%s\n' "$rc_sum" >&2
    return 2; }
  out="${out%% *}"
  if [ -z "$out" ]; then
    printf 'sha_vyvoda: sha256sum дал пустой вывод\n' >&2
    return 2
  fi
  printf '%s' "$out"
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

# ЧЕТЫРЕ поля обязательны (инв. 8): ПРЕДМЕТ / МОДЕЛЬ / ВОПРОС / РЕКОМЕНДАЦИЯ.
# Без любого из них ответ есть декой — например, отсутствие ВОПРОСА лишает
# рекомендацию предмета суждения (находка 3 адверсария, absent_header_fields rc=0).
missing=""
[ -n "$PREDMET"  ] || missing="${missing:+$missing }ПРЕДМЕТ"
[ -n "$MODEL"    ] || missing="${missing:+$missing }МОДЕЛЬ"
[ -n "$VOOPROS"  ] || missing="${missing:+$missing }ВОПРОС"
[ -n "$REKOM"    ] || missing="${missing:+$missing }РЕКОМЕНДАЦИЯ"
if [ -n "$missing" ]; then
  printf 'ответ без обязательных полей шапки — отсутствует: %s\n' "$missing" >&2
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

# Метасимволы, запрещённые ВСЕГДЕ. Старая редакция матчила ОДНУ ЦЕЛУЮ строку из 8
# символов через `case *"$FORBIDDEN_META"*` — так ни один символ в отдельности не
# ловился, и `ls $(touch ...)` проходило, потому что `$` сам по себе не был
# подстрокой из 8 символов (находка 1 адверсария, command injection). Теперь —
# посимвольный перебор закрытого множества `; | & $ > < \` ( )`. `'` (одиночная
# кавычка) намеренно НЕ входит: внутри `'...'` пользовательская команда может
# упомянуть «it's», и отказ по апострофу ронял бы честные ответы; кавычки
# балансируются аргументным разбором после.
FORBIDDEN_META_CHARS='; | & $ > < \` ( )'

# ── проверка строки команды: метасимволы ─────────────────────────────────────
contains_forbidden() {  # <строка>  → 0 если нашёлся ЛЮБОЙ метасимвол
  local c
  for c in $FORBIDDEN_META_CHARS; do
    [[ "$1" == *"$c"* ]] && return 0
  done
  return 1
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

env -i PATH="$TRUSTED_PATH" LC_ALL=C.UTF-8 \
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
env -i PATH="$TRUSTED_PATH" LC_ALL=C.UTF-8 \
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

# ── Г5 (alternates, ДО первого переисполнения) ────────────────────────────────
# `.git/objects/info/alternates` указывает на ЧУЖОЙ object store: `git show <sha>`
# из внешнего репозитория возвращает rc 0, и sha его payload совпадает с
# заявленным в ответе — корневое дерево при этом может не иметь HEAD вовсе
# (находка 4 адверсария, alternates rc=0 no_root_head=yes external_output=yes).
# Г1/G2/Г4 этот канал не закрывают: Г1 чистит ENV, Г2 сканит КЛЮЧИ конфига,
# Г4 смотрит гитлинки. Проверяем РЕЗОЛВНУТЫЙ gitdir (через `git rev-parse`, иначе
# файл-указатель `.git` при `--separate-git-dir` теряется) и его `objects/info/alternates`.
ALT_GITDIR="$(env -i PATH="$TRUSTED_PATH" LC_ALL=C.UTF-8 \
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
  git -C "$ROOT" rev-parse --git-dir 2>/dev/null)"
if [ -n "$ALT_GITDIR" ]; then
  case "$ALT_GITDIR" in
    /*) ALT_ABS="$ALT_GITDIR" ;;
    *)  ALT_ABS="$ROOT/$ALT_GITDIR" ;;
  esac
  if [ -f "$ALT_ABS/objects/info/alternates" ]; then
    printf 'alternates вне границы: %s/objects/info/alternates ссылается на чужой object store — корень может оказаться подменён\n' \
           "$ALT_ABS" >&2
    rm -rf "$EMPTY_HOOKS_DIR"
    exit 1
  fi
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
    git_cmd=( env -i PATH="$TRUSTED_PATH" LC_ALL=C.UTF-8 \
              GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
              git -c "core.hooksPath=$EMPTY_HOOKS_DIR" -C "$ROOT" )
    for a in "${argv[@]:1}"; do git_cmd+=("$a"); done
    out="$("${git_cmd[@]}" 2>&1)"; rc=$?
  else
    # sha256sum / cat / ls — прямой вызов разобранного argv в `$ROOT` через
    # `env -i` (Г1). `bash -c "... $cmd"` ронял `$(...)` через двойную
    # shell-интерпретацию (находка 1 адверсария); здесь argv уже разобран и
    # передаётся массивом — никакой повторной интерпретации нет.
    out="$( cd "$ROOT" && env -i PATH="$TRUSTED_PATH" LC_ALL=C.UTF-8 \
            GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 \
            "${argv[@]}" 2>&1 )"
    rc=$?
  fi

  ORACLE_RC+=("$rc")
  # ИНВ. 10: провал sha_vyvoda (return 2) обязан давать итоговый rc=2, а не
  # rc=1 «расхождение вывода» (арбитраж tcb-granica-put-029.md §3, замер M4).
  # Сломанный ИНСТРУМЕНТ не вменяется консультанту как ложь.
  got_sha="$(sha_vyvoda "$out")"; sha_rc=$?
  ORACLE_SHA+=("$got_sha")
  if [ "$sha_rc" -ne 0 ]; then
    printf 'verify_consultant.sh: sha256sum непригоден — нечем проверить (sha_vyvoda rc=%s)\n' "$sha_rc" >&2
    rm -rf "$EMPTY_HOOKS_DIR"
    exit 2
  fi
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