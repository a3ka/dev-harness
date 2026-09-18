# Каркас красных проб анти-плацебо на КОНСУЛЬТАНТЕ (контракт 029, решение владельца Q2:
# механизм ПРОТИВ ВРУЩЕГО консультанта, а не дисциплина в прозе).
#
# Имя НЕ case_*.sh и НЕ red_*.sh намеренно (прецедент _repo.sh, _zhnets.sh).
#
# Контракт вызова: «$BARRIER --root <корень> --otvet <файл ответа>».
#
# ОРАКУЛ ЖИВЁТ В ПАМЯТИ ПРОВЕРЯЮЩЕГО (правило 8 анти-плацебо): честные rc и sha снимает
# САМ каркас ДО построения ответа, командой в игрушечном дереве; диск проверяемого как
# источник истины не перечитывается. Нормализация вывода — ЕДИНЫЙ примитив `sha_vyvoda`:
# захват `$( )` (завершающие LF отброшены) + sha256 от `printf '%s'`. Барьер обязан
# нормализовать ТАК ЖЕ; переизобретение нормализации в теле пробы запрещено.
if [ -z "${WORK:-}" ]; then
  REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/konsult029.XXXXXX")"
  BARRIER="$REPO/scripts/verify_consultant.sh"
  trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT
fi
export LC_ALL=C.UTF-8

kgi() {  # герметичный git в игрушке
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Игрушечное дерево: git-репозиторий с одним коммитом и каталогом вердиктов.
igrushka() {  # <корень>
  local r="$1"
  mkdir -p "$r/verdicts/consultant" "$r/forks"
  printf 'основание игрушки консультанта\n' > "$r/README.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  kgi "$r" add -- README.md
  kgi "$r" commit -q -m 'основание'
}

# ЧЕСТНЫЙ оракул: rc команды в корне игрушки (в память проверяющего).
rc_komandy() {  # <корень> <команда>
  local r="$1" c="$2" rc=0
  ( cd "$r" && eval "$c" ) >/dev/null 2>&1 || rc=$?
  printf '%s' "$rc"
}

# ЧЕСТНЫЙ оракул: sha256 нормализованного вывода (stdout+stderr) команды в корне игрушки.
sha_vyvoda() {  # <корень> <команда>
  local r="$1" c="$2" o
  o="$( cd "$r" && eval "$c" 2>&1 )" || true
  printf '%s' "$o" | sha256sum | cut -d' ' -f1
}

# Ответ консультанта. Шапка обязательна; тройки ОСНОВАНИЕ-ДЕРЕВО добавляются `osnovanie`.
otvet_shapka() {  # <файл> <предмет> <модель> <рекомендация>
  {
    printf 'ПРЕДМЕТ: %s\n' "$2"
    printf 'МОДЕЛЬ: %s\n' "$3"
    printf 'ВОПРОС: подставной инженерный форк\n'
    printf 'РЕКОМЕНДАЦИЯ: %s\n' "$4"
  } > "$1"
}

# Тройка блока основания — ЕДИНЫЙ источник грамматики блока.
osnovanie() {  # <файл> <команда> <rc> <sha>
  {
    printf 'ОСНОВАНИЕ-ДЕРЕВО:\n'
    printf 'КОМАНДА: %s\n' "$2"
    printf 'RC: %s\n' "$3"
    printf 'ВЫВОД-SHA256: %s\n' "$4"
  } >> "$1"
}

# Честное основание: оракул снимается каркасом сам.
osnovanie_chestnoe() {  # <файл> <корень> <команда>
  osnovanie "$1" "$3" "$(rc_komandy "$2" "$3")" "$(sha_vyvoda "$2" "$3")"
}

zapusk() {  # <аргументы барьера…>
  rc=0
  out="$("$BARRIER" "$@" 2>&1)" || rc=$?
}

zhdu_rc() {  # <ожидаемый rc> <что предъявляется>
  [ "$rc" -eq "$1" ] || {
    printf 'ОТКАЗ: %s — барьер вернул rc %s, ожидался %s. Вывод:\n%s\n' "$2" "$rc" "$1" "$out" >&2
    exit 1; }
}

zhdu_text() {  # <подстрока> <что предъявляется>
  printf '%s\n' "$out" | grep -Fq -- "$1" || {
    printf 'ОТКАЗ: %s — в выводе нет «%s». Вывод:\n%s\n' "$2" "$1" "$out" >&2
    exit 1; }
}
