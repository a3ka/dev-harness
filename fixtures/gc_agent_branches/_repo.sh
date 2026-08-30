# Каркас подставного репозитория для фикстур `gc_agent_branches` (контракт 016, срез 4).
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <корень>` собирает минимальное дерево с HEAD=main и двумя коммитами; зон и
# заморозок GC не читает (он ходит только по refs/heads/wip/), но контракт и вердикт
# положены для однородности с соседними каркасами.
#
# Герметичность обязательна (прецедент fixtures/check_zones/_repo.sh): глобальная
# `commit.gpgsign` без ключа роняет построение кодом 128, `core.hooksPath` — кодом 1.
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
  mkdir -p "$r" "$r/contracts" "$r/verdicts/critic"
  {
    printf '# контракт 900 (подставной, для каркаса фикстур gc_agent_branches)\n'
    printf '\n## Предмет\nподставной предмет\n'
    printf '\n## Критерий готовности\nкоманда с кодом возврата\n'
    printf '\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
  } > "$r/contracts/900-fake.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-900-v1.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config user.email implementer@dev-harness.local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" config core.hooksPath /dev/null
  g "$r" add -- contracts/900-fake.md verdicts/critic/contracts-900-v1.md
  g "$r" commit -q -m 'основание'
}

# mk_merged — ветка wip/*, ДОСТИЖИМАЯ из HEAD: ровно та, которую GC обязан снести.
mk_merged() {  # <корень> <ветка>
  local r="$1" br="$2"
  g "$r" branch "$br" main
}

# mk_hung — ветка wip/* с собственным коммитом, НЕ достижимым из HEAD: зависшая.
# Коммит делается в отдельном worktree, чтобы главный чекаут остался на main.
mk_hung() {  # <корень> <ветка> <путь worktree>
  local r="$1" br="$2" wt="$3"
  g "$r" branch "$br" main
  g "$r" worktree add -q "$wt" "$br"
  GIT_AUTHOR_NAME=leftover GIT_AUTHOR_EMAIL=leftover@local \
  GIT_COMMITTER_NAME=leftover GIT_COMMITTER_EMAIL=leftover@local \
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$wt" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit --allow-empty -q -m "предмет зависшей $br"
}
