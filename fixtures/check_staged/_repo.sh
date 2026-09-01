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

# ── помощники среза 1 контракта 018 (страж «ветка, не main») ────────────────────
#
# make_repo_multizone: как make_repo, но замороженный контракт несёт НЕСКОЛЬКО зон —
# implementer (scripts/) И critic (verdicts/). Нужен, чтобы предъявить СУДЬЮ автором С
# зонами (critic зонирован verdicts/*), который на main всё равно ОБЯЗАН пройти: премиса
# (Q4) «судья — автор без зон» ложна по коду, исключение судьи — спавн-состоянием (нет
# своей wip/*-ветки), а не отсутствием зон.
make_repo_multizone() {  # <корень>
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА critic: verdicts/\n'
  } > "$r/contracts/001-x.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  printf 'основание вердиктов\n' > "$r/verdicts/critic/.keep"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны implementer+critic'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}

# set_author <корень> <имя> — сменить коммитящего автора репо (локальный конфиг). Судья
# среза 1 различает авторов по effective identity (git var GIT_AUTHOR_IDENT), а она читает
# локальный user.name/user.email.
set_author() {  # <корень> <имя>
  local r="$1" name="$2"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name "$name"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email "$name@local"
}

# mk_wip <корень> <ветка> — создать wip-ветку ОТ main, НЕ переключаясь (репо остаётся на
# main). Моделирует «агента спавнили в worktree (ветка жива), а коммитит он в основной
# чекаут» — ровно cwd-промах, наблюдаемый стражем среза 1.
mk_wip() {  # <корень> <ветка>
  g "$1" branch "$2" main
}

# co_wip <корень> <ветка> — создать wip-ветку ОТ main И переключиться на неё. Моделирует
# «агент в своём worktree на своей ветке» — страж молчит, коммит легитимен.
co_wip() {  # <корень> <ветка>
  g "$1" checkout -q -b "$2" main
}

# detach_head <корень> — отвязать HEAD от ветки в detached-состоянии (symbolic-ref --short
# HEAD откажет: ветки нет вовсе). Моделирует чекаут вне какой-либо ветки — ОТДЕЛЬНЫЙ путь
# кода стража, не покрываемый ни main, ни «чужая wip» (Р3 арбитража 018).
detach_head() {  # <корень>
  g "$1" checkout -q --detach main
}

# ── помощники контракта 019 (Н-72: делегирование устава → check_charter) ────────
#
# make_repo_ustav: как make_repo, но устав ВВЕДЁН — тег ustav/1 стоит на коммите,
# который вносит AGENTS.md/ROADMAP.md. С этого тега живёт область check_charter:
# правки уставных файлов позже тега судятся строкой РАЗРЕШИЛ-ВЛАДЕЛЕЦ, а не зонами.
make_repo_ustav() {  # <корень>
  local r="$1"
  make_repo "$r"
  printf '# норма системы\n' > "$r/AGENTS.md"
  printf '# роадмап\n' > "$r/ROADMAP.md"
  g "$r" add -- AGENTS.md ROADMAP.md
  g "$r" commit -q -m 'введение уставных документов'
  g "$r" tag -a ustav/1 -m 'устав введён'
}

# ustav_change <корень> <файл> <сообщение>: закоммитить правку уставного файла ПОСЛЕ
# тега ustav/1 (хуки репо выключены — историю строит фикстура, судит её $BARRIER).
# Сообщение передаётся ДОСЛОВНО: со строкой РАЗРЕШИЛ-ВЛАДЕЛЕЦ в грамматике
# check_charter правка разрешена, без неё — нарушение; грамматика строки — единый
# источник check_charter, фикстура её не переизобретает.
ustav_change() {  # <корень> <файл> <сообщение>
  local r="$1" f="$2"
  printf 'строка правки устава\n' >> "$r/$f"
  g "$r" add -- "$f"
  g "$r" commit -q -m "$3"
}

# make_repo_archzone: как make_repo, но замороженный контракт несёт и зону architect
# (plans/) — автор architect в этом репо ЗОНДИРОВАН, суд путей доходит до ветки
# draft-пуска контракта 019. Без зоны автор прошёл бы «не судится» ДО суда путей, и
# зелёный контроль не упражнял бы предмет (плацебо-зелёное, урок ЗЗ контракта 018).
make_repo_archzone() {  # <корень>
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/plans"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА architect: plans/\n'
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны исполнителя с архитектором'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}
