# Каркас подставного репозитория для фикстур `land_agent` (контракт 016, срез 3).
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <корень>` собирает минимальное дерево, на котором `land_agent.sh` зелен:
#   * замороженный контракт `contracts/900-fake.md` под тегом `frozen/contracts/900/1`.
#     ИМЯ НЕСУЩЕЕ: `zones_load` берёт NNN пятым полем refname тега и ищет в блобе
#     заморозки файл с префиксом `contracts/<NNN>-`; при теге `frozen/contracts/016-fake/1`
#     и файле `contracts/016-fake.md` префикс `contracts/016-fake-` не совпадает, реестр
#     ролей выходит ПУСТЫМ и любой committer читается «вне реестра» (замер предшественника:
#     зелёный контроль краснел «имя вне реестра ролей: … committer implementer»).
#     Номер 900 не пересекается с реальными заморозками dev-harness;
#   * ЗОНА-строка объявляет `implementer` — он и есть committer зелёного диапазона.
#
# Зелёная основа обязательна: положительный контроль каждой фикстуры предъявляет барьер
# ЗЕЛЁНЫМ до порчи. Без неё вечно-красный барьер неотличим от работающего.
#
# Герметичность обязательна (прецедент fixtures/check_zones/_repo.sh): глобальная
# `commit.gpgsign` без ключа роняет построение кодом 128, `core.hooksPath` — кодом 1 без текста.
#
# СПАВН ЗДЕСЬ НЕ УЧАСТВУЕТ. Ветку и worktree строит `mk_wip` голым git'ом: барьер этого
# каталога — land_agent.sh, и `$BARRIER --author …` для него неизвестный аргумент (замер
# предшественника: usage, rc 1, зелёного контроля нет вовсе). Предмет спавна судит
# fixtures/spawn_agent/.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

# commit_in — пустой коммит в указанном рабочем дереве (worktree или основной checkout)
# с ЯВНОЙ парой author/committer через env. Расщепление identity задаётся отдельно, в
# самих фикстурах, где оно и есть предмет.
commit_in() {  # <рабочее дерево> <user.name> <user.email> <сообщение>
  local r="$1" who="$2" mail="$3" msg="$4"
  GIT_AUTHOR_NAME="$who" GIT_AUTHOR_EMAIL="$mail" \
  GIT_COMMITTER_NAME="$who" GIT_COMMITTER_EMAIL="$mail" \
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit --allow-empty -q -m "$msg"
}

make_repo() {  # <корень>
  local r="$1"
  mkdir -p "$r" "$r/contracts" "$r/verdicts/critic"
  {
    printf '# контракт 900 (подставной, для зелёной основы фикстур land_agent)\n'
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
  g "$r" commit -q -m 'основание: подставной контракт с implementer в реестре'
  g "$r" tag -a frozen/contracts/900/1 -m 'подставная заморозка для фикстур land_agent'
}

# mk_wip — ветка wip/<NNN>/<автор> от main + worktree ВНЕ стерегомого дерева ($WORK, не $R:
# каталог внутри $R сделал бы главный чекаут грязным и покрасил бы И-7 посторонним).
mk_wip() {  # <корень> <ветка> <путь worktree>
  local r="$1" br="$2" wt="$3"
  g "$r" branch "$br" main
  g "$r" worktree add -q "$wt" "$br"
}

# assert_landed — сверки И-1 и И-4 ПО ПЕРЕХОДУ, а не по состоянию журнала: заранее
# построенного merge в фикстуре нет, создать его может только сам вызов барьера.
# Аргументы — снятые ДО вызова main_before и tip.
assert_landed() {  # <корень> <main_before> <tip> <ветка>
  local r="$1" mb="$2" tip="$3" br="$4" now p1 p2 cn
  now="$(git -C "$r" rev-parse main)"
  if [ "$now" = "$mb" ]; then
    printf 'ОТКАЗ: main не сдвинут вызовом (%s) — приземление не наблюдается (И-1)\n' "${mb:0:8}" >&2
    exit 1
  fi
  p1="$(git -C "$r" rev-parse 'main^1' 2>/dev/null || true)"
  p2="$(git -C "$r" rev-parse 'main^2' 2>/dev/null || true)"
  if [ "$p1" != "$mb" ]; then
    printf 'ОТКАЗ: main^1=%s != main_before=%s — первый родитель не main (И-1)\n' "${p1:0:8}" "${mb:0:8}" >&2
    exit 1
  fi
  if [ "$p2" != "$tip" ]; then
    printf 'ОТКАЗ: main^2=%s != tip=%s — второй родитель не приземляемая ветка (И-1)\n' "${p2:0:8}" "${tip:0:8}" >&2
    exit 1
  fi
  cn="$(git -C "$r" log -1 --format='%cn' main)"
  if [ "$cn" != "orchestrator" ]; then
    printf 'ОТКАЗ: committer merge-коммита %s, ожидался orchestrator (И-1/И-9)\n' "$cn" >&2
    exit 1
  fi
  if git -C "$r" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q "^refs/heads/${br}\$"; then
    printf 'ОТКАЗ: ветка %s пережила успешное приземление — И-4 не держится\n' "$br" >&2
    exit 1
  fi
}
