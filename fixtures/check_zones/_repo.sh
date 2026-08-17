# Каркас подставного репозитория для фикстур `check_zones`.
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог> <тело объявления>` собирает дерево, где контракт заморожен ПО ПРОЦЕДУРЕ (тег
# + вердикт критика `accept`) и несёт переданное объявление о раздаче. Зелёная основа обязательна:
# её предъявляет положительный контроль каждой фикстуры, иначе вечно-красный барьер неотличим от
# работающего.
#
# ГЕРМЕТИЧНОСТЬ обязательна: глобальная `commit.gpgsign` без ключа роняет построение истории кодом
# 128, а `core.hooksPath` — кодом 1 без текста.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Коммит от ИМЕНИ ОБЪЯВЛЕННОГО ИСПОЛНИТЕЛЯ: барьер различает авторов по `user.name`, и подставной
# исполнитель обязан коммитить своим именем, иначе фикстура проверяла бы не тот предмет.
commit_as() {  # <корень> <имя автора> <сообщение>
  local r="$1" who="$2" msg="$3"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name="$who" -c user.email="${who}@local" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name="$who" -c user.email="${who}@local" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$msg"
}

make_repo() {  # <корень> <строка объявления о раздаче>
  local r="$1" declaration="${2:-}"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/fixtures/a" "$r/plans" "$r/tmp"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    [ -n "$declaration" ] && printf '%s\n' "$declaration"
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n'    > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  commit_all "$r" 'основание: контракт и вердикт критика'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}
