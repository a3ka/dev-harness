# Каркас подставного репозитория для фикстур `land_agent` (контракт 016, срез 3).
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается.
#
# Зелёная основа ОБЯЗАТЕЛЬНА: положительный контроль каждой фикстуры предъявляет барьер
# ЗЕЛЁНЫМ до порчи. Без неё вечно-красный барьер неотличим от работающего.
#
# Герметичность обязательна (прецедент fixtures/check_zones/_repo.sh): глобальная `commit.gpgsign`
# без ключа роняет построение кодом 128, `core.hooksPath` — кодом 1 без текста.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

commit_as() {  # <корень> <имя автора> <сообщение>
  local r="$1" who="$2" msg="$3"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name="$who" -c user.email="${who}@local" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit --allow-empty -q -m "$msg" 2>/dev/null \
    || GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
       git -C "$r" -c user.name="$who" -c user.email="${who}@local" \
           -c commit.gpgsign=false -c core.hooksPath=/dev/null \
           commit --allow-empty -q --author="$who <$who@local>" -m "$msg"
}

make_repo() {  # <корень>
  local r="$1"
  mkdir -p "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.email implementer@local
  g "$r" commit --allow-empty -q -m 'основание'
}
