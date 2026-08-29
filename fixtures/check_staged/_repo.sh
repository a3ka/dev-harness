# Каркас подставного репозитория для фикстур `check_staged` (срез 1 контракта 016).
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает репо, где подставной контракт заморожен ПО ПРОЦЕДУРЕ
# (тег `frozen/contracts/001/1`) и несёт зону исполнителя — ту же грамматику ЗОНА-строк,
# что читает check_zones. Коммитящий автор — `implementer` из ЛОКАЛЬНОГО конфига репо:
# судья среза 1 различает авторов по `user.name` (решение Q3).
#
# Зелёная основа обязательна: её предъявляет положительный контроль каждой фикстуры,
# иначе вечно-красный барьер неотличим от работающего.
#
# ГЕРМЕТИЧНОСТЬ обязательна (прецедент check_zones/_repo.sh): глобальная `commit.gpgsign`
# без ключа роняет построение кодом 128, а `core.hooksPath` — кодом 1 без текста.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

make_repo() {  # <корень>
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  # Автор коммитов судьи: локальный конфиг репо, БЕЗ дефолта в общем конфиге (инвариант
  # identity Q3/Н-56: без явной identity git откажет «empty ident»).
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зона исполнителя'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}

# stage <корень> <отн-путь> <содержимое> — положить файл в индекс (судимого объекта
# ещё нет в HEAD — именно staged-множество и есть предмет судьи).
stage() {  # <корень> <отн-путь> <содержимое>
  local r="$1" p="$2"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$3" > "$r/$p"
  g "$r" add -- "$p"
}
