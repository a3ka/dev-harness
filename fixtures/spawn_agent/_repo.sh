# Каркас подставного репозитория для фикстур `spawn_agent` (контракт 016, срез 2).
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает минимальное дерево с HEAD=main и одним коммитом. Локальная
# identity — явная через -c, чтобы глобальный конфиг машины (если есть) не подменил
# автора при инициализации.
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
  mkdir -p "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.email implementer@local
  g "$r" commit --allow-empty -q -m 'основание'
}


# ── помощники контракта 023 (провенанс тега: toy-origin, прецедент 022 red_push_*) ─
#
# Авторитет выдачи — origin (слово владельца 2026-09-08): на origin теги оказываются
# только пушем оркестратора/владельца. Ворота провенанса гейта спавна строят toy с
# НАСТОЯЩИМ remote (bare рядом, main запушен); ls-remote по file-пути — без сети.
toy_origin() {  # <корень> → путь bare на stdout
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main
  printf '%s\n' "$orig"
}

# push_id_tag <корень> <NNN>: пуш тега выдачи на origin — авторитетная половина
# церемонии (i); ровно то, чего спавнящийся агент не контролирует.
push_id_tag() {  # <корень> <NNN>
  g "$1" push -q origin "refs/tags/id/CONTRACT/$2"
}