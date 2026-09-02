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

# make_repo_koltso: make_repo_ustav + замороженный план plans/001-p.md (тег первой
# заморозки frozen/plans/001/1). Кольцо уставного класса (019 v2, блокер 2 критика
# :123) требует входов на ОБЕИХ классах артефактов: contracts/001-x.md уже заморожен
# в make_repo (тег frozen/contracts/001/1), plans/ замораживается здесь — правка
# замороженного плана после тега есть уставной класс, путь БЕЗ тега — черновик под
# прежним зонным судом. Коммит плана идёт ПОСЛЕ ustav/1: добавление (A) свободно,
# точка уставности — только тег.
make_repo_koltso() {  # <корень>
  local r="$1"
  make_repo_ustav "$r"
  mkdir -p "$r/plans"
  printf 'предмет плана, критерий готовности\n' > "$r/plans/001-p.md"
  g "$r" add -- plans/001-p.md
  g "$r" commit -q -m 'план 001 написан и утверждён'
  g "$r" tag -a frozen/plans/001/1 -m 'план утверждён'
}

# make_repo_busy019 <корень> [доп-зона architect]...: как make_repo_archzone
# (зоны implementer: scripts/ и architect: plans/), но в HEAD закоммичен
# contracts/<занятый>-base.md — номер ЗАНЯТ по источнику 3 кода next_id_peek
# (файлы артефактов на HEAD, git ls-tree -r HEAD; Н-39 — занятость по коду peek,
# не по прозе контракта). Занятый номер — параметр ZANJATYJ_NOMER фикстуры
# (М-1 арбитража ebc57db; дефолт 019, допустимые 002…998), следующий свободный —
# max+1 от него. Тег выдачи
# id/CONTRACT/* НЕ ставится: занятость файлом достаточна, а живой id/*-тег
# конфликтовал бы с охраной «судья не создаёт тег id/*» фикстур draft-пуска.
# Доп-зоны architect передаются аргументами: пину значения нужна зона, ПОКРЫВАЮЩАЯ
# draft-путь (contracts/ — тогда пропуск по зоне даёт rc 0, и стаб-константа
# различается СТРОКОЙ draft-пропуска, а не кодом возврата — красный от стаба не
# становится законным красным кандидатом раннера, А-73); серийному отрицательному
# входу доп-зона НЕ даётся — соседний номер обязан краснеть «вне зоны».
make_repo_busy019() {  # <корень> [доп-зона architect]...
  local r="$1"; shift
  local nom="${ZANJATYJ_NOMER:-019}"  # М-1: занятый номер — параметр (точка подстановки построителя)
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/plans"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА architect: plans/\n'
    local z
    for z in "$@"; do printf 'ЗОНА architect: %s\n' "$z"; done
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  printf '# контракт %s (занятость номера — файл на HEAD)\n' "$nom" > "$r/contracts/$nom-base.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m "основание: контракт, зоны и занятый номер $nom"
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}

# ── помощники правки 2 по FAIL адверсария 019 круг 2: серийные входы «один
# источник max+1» (А-32 — серийные входы одного case) ──────────────────────────
#
# Три построителя ниже заселяют занятый номер (ZANJATYJ_NOMER, дефолт 019 — М-1
# арбитража ebc57db) РОВНО В ОДИН источник кода
# next_id_max_for_class (Н-39 — по коду, не по прозе): источник 1 —
# for-each-ref refs/tags/id/<КЛАСС>/; источник 2 — for-each-ref refs/heads
# refs/remotes (первая цепочка цифр короткого имени); источник 4 —
# git log --all --diff-filter=A. Источник 3 (файлы на HEAD) закрывает
# make_repo_busy019 выше. Остальные источники в каждом построителе чисты:
# на HEAD только contracts/001-x.md, тегов id/* нет (кроме «тег»-построителя),
# история без номеров больше 001. Доп-зоны architect — как у make_repo_busy019:
# пину значения нужна зона, ПОКРЫВАЮЩАЯ draft-путь, чтобы head-only стаб падал
# СТРОКОЙ draft-пропуска (ассертом фикстуры), а не кодом возврата — красный от
# стаба не становится законным красным кандидатом раннера (А-73).

# make_repo_busy019_teg <корень> [доп-зона architect]...: занятость — тег
# выдачи id/CONTRACT/<занятый> (источник 1), аннотированный, как ставит выдача
# next_id.sh (git tag -m). Единственный построитель, где id-тег существует
# С САМОГО НАЧАЛА: охрана фикстур draft-пуска судит такие репо отсутствием
# НОВЫХ тегов после прогона, а не отсутствием вообще.
make_repo_busy019_teg() {  # <корень> [доп-зона architect]...
  local r="$1"; shift
  local nom="${ZANJATYJ_NOMER:-019}"  # М-1: занятый номер — параметр (точка подстановки построителя)
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/plans"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА architect: plans/\n'
    local z
    for z in "$@"; do printf 'ЗОНА architect: %s\n' "$z"; done
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны — номер занят тегом, не файлом'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
  g "$r" tag -a "id/CONTRACT/$nom" -m 'выдача механизмом (фикстура: занятость источником-тегом)'
}

# make_repo_busy019_vetka <корень> [доп-зона architect]...: занятость — имя
# ссылки refs/heads/wip/<занятый>/istochnik (источник 2: первая цепочка цифр
# короткого имени даёт занятый номер). Хвост ветки — НЕ architect: страж
# «ветка, не main» (018) включается только на живой wip/<*>/<author>, и
# wip/<занятый>/architect затемнил бы предмет отказом «вне своей ветки» ДО
# draft-ветви. Файла с занятым номером нигде нет, тегов id/* нет.
make_repo_busy019_vetka() {  # <корень> [доп-зона architect]...
  local r="$1"; shift
  local nom="${ZANJATYJ_NOMER:-019}"  # М-1: занятый номер — параметр (точка подстановки построителя)
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/plans"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА architect: plans/\n'
    local z
    for z in "$@"; do printf 'ЗОНА architect: %s\n' "$z"; done
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны — номер занят именем ссылки'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
  g "$r" branch "wip/$nom/istochnik" main
}

# make_repo_busy019_istorija <корень> [доп-зона architect]...: занятость —
# достижимая история (источник 4): contracts/<занятый>-udaljon.md закоммичен ПОСЛЕ
# заморозки и затем удалён, HEAD чист, добавление видит git log --all
# --diff-filter=A. Моделирует границу из шапки next_id.sh: удалённый с HEAD файл
# не освобождает номер. Тегов id/* нет, веток с цифрами нет.
make_repo_busy019_istorija() {  # <корень> [доп-зона architect]...
  local r="$1"; shift
  local nom="${ZANJATYJ_NOMER:-019}"  # М-1: занятый номер — параметр (точка подстановки построителя)
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/plans"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА architect: plans/\n'
    local z
    for z in "$@"; do printf 'ЗОНА architect: %s\n' "$z"; done
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name implementer
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email implementer@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание: контракт и зоны'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
  printf '# контракт %s (удалён с HEAD — номер держит история)\n' "$nom" > "$r/contracts/$nom-udaljon.md"
  g "$r" add "contracts/$nom-udaljon.md"
  g "$r" commit -q -m "контракт $nom написан"
  g "$r" rm -q "contracts/$nom-udaljon.md"
  g "$r" commit -q -m "контракт $nom удалён с HEAD — номер занят историей"
}
