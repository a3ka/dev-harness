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

# mint_rezerv <корень> <NNN>: церемония ветви (i) в toy — авторитетная половина
# dual-control (слово владельца 2026-09-08, вердикт 57c8141 блокер 1): тег +
# строка манифеста «<NNN> → <tag-object-sha>» в registry/contracts.tsv НА main +
# оба пуша. Тело — ПОБАЙТОВЫЙ дубликат каркаса check_staged/_repo.sh (семьи
# изолированы — прецедент g/make_repo между семьями). Грамматика строки —
# ДОСЛОВНО из контракта 023 (единый источник).
mint_rezerv() {  # <корень> <NNN>
  local r="$1" n="$2" sha
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача механизмом (фикстура: резерв до спавна)'
  sha="$(git -C "$r" rev-parse "refs/tags/id/CONTRACT/$n")"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
  g "$r" commit -q -m "реестр: резерв $n (строка манифеста)"
  g "$r" push -q origin main
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}