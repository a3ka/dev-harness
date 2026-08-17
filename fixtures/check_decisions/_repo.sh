# Каркас подставного репозитория для фикстур `check_decisions`.
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает дерево с замороженным контрактом 002 и ровно
# семью записями 001-007 из его таблицы. Контракт заморожен ПО ПРОЦЕДУРЕ: тег
# `frozen/contracts/002/1` и вердикт критика `accept` на HEAD. Зелёная основа
# обязательна: её предъявляет положительный контроль каждой фикстуры, иначе
# вечно-красный барьер неотличим от работающего (правило 3 нормы).
#
# ГЕРМЕТИЧНОСТЬ: глобальная `commit.gpgsign` без ключа роняет построение истории
# кодом 128, а `core.hooksPath` — кодом 1 без текста. Тогда фикстура краснела бы
# от чужого конфига, а не от внесённой поломки.
#
# ИМПОРТ НУЖНЫХ КОММИТОВ. Барьер проверяет основания записей через
# `git cat-file -e`, и хеши 93fc601, fa4457a, 8ed63e6, cd7f1c9, cca7090,
# ca29f7e, d2d5d3a обязаны существовать в проверяемом дереве. Пустая история
# подставного репо дала бы «основание не разрешается» на зелёной основе, и
# фикстура видела бы только этот дефект, а не внесённый. Поэтому история
# основного репозитория переносится в подставное через `git fetch` от его
# `.git` (не рабочего дерева — `cat-file` берёт объекты из `objects/`).

g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Запись решения — дословно по грамматике барьера (шесть полей, основание —
# единственный токен-хеш в одной строке).
write_decision() {
  local f="$1" date="$2" q="$3" d="$4" base="$5" scope="$6" rev="$7"
  {
    printf '# %s — %s\n\n' "$(basename "$f" .md | cut -c1-3)" "$q"
    printf 'дата: %s\n' "$date"
    printf 'вопрос: %s\n' "$q"
    printf 'решение: %s\n' "$d"
    printf 'основание: %s\n' "$base"
    printf 'область: %s\n' "$scope"
    printf 'условие пересмотра: %s\n' "$rev"
  } > "$f"
}

# Минимальный контракт-источник с тремя записями, чьи хеши пришпилены барьером.
# Таблица — ровно в формате `| NNN | решение | хеш |`, который ждёт барьер.
write_contract() {
  local f="$1"
  {
    printf '# Контракт 002 — режим подтверждений и роль steward\n\n'
    printf '## Перечень решений\n\n'
    printf '| № | решение | источник |\n'
    printf '|---|---|---|\n'
    printf '| 003 | Модель сессии читается из ТРЕЙСА | `cd7f1c9` |\n'
    printf '| 004 | План и контракт не утверждаются без вердикта критика | `cca7090` |\n'
    printf '| 005 | Критик — на ВЕРХНЕМ уровне чужого семейства | `93fc601` |\n'
    printf '| 006 | У критика ПОРОГ: блокирует только находка с названным ОБХОДОМ | `fa4457a` (слово владельца) |\n'
    printf '| 007 | Остаточные риски cognitive-only плана 005 приняты | `8ed63e6` |\n'
  } > "$f"
}

# Импорт объектов основного репозитория в подставное дерево. Проверяющий задаёт
# `$REPO` — это каталог, где лежит барьер и где живут нужные хеши. Без `$REPO`
# фикстура не знает, где основное `.git`, и `cat-file -e` красит «основание не
# разрешается» на зелёной основе, перебивая внесённый отказ.
import_main_objects() {
  local r="$1"
  local main_gitdir="${REPO:-}/.git"
  [ -d "$main_gitdir" ] || return 0
  # `git fetch` не принимает хеш как refspec, и одиночные объекты он не вытягивает.
  # Копируем `objects/` основного репозитория в подставное: `cat-file -e` потом
  # видит хеш через локальный `objects/`. `.git/objects/pack` не копируется
  # отдельно — `objects/` уже включает и pack-файлы основного репо.
  local r_gitdir
  r_gitdir="$(git -C "$r" rev-parse --absolute-git-dir)"
  cp -rn "$main_gitdir/objects/." "$r_gitdir/objects/"
}

make_repo() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/decisions" "$r/tmp"
  # Контракт-источник для `check_decisions.sh`. Не требует вердикта критика —
  # барьер реестра сверяет ТОЛЬКО хеши из его таблицы.
  write_contract "$r/contracts/002-approval-mode-steward.md"
  # Вердикт-обёртка нужна другим барьерам, не `check_decisions`. Создаём, чтобы
  # `check_contract_frozen.sh` не краснел на фикстурах, использующих его же
  # подставное дерево в одном прогоне.
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-002-v1.md"
  # Семь записей по таблице контракта. Хеши 005-007 совпадают с таблицей, иначе
  # барьер красит «основание не совпадает» на зелёной основе и фикстура не видит
  # внесённого отказа. Для 001-004 таблица хеша не требует, и любой существующий
  # коммит годится — берём известные из основного дерева.
  write_decision "$r/decisions/001-sessiyu-vedet-rol.md" "2026-08-16" \
    "кто ведёт сессию" "роль с явным --model" "ca29f7e" "вход" "потеря записи"
  write_decision "$r/decisions/002-raskladka-modelej.md" "2026-08-16" \
    "распределение расхода" "дорогое точечно" "d2d5d3a" "modelRoles" "новое семейство"
  write_decision "$r/decisions/003-model-iz-trejsa.md" "2026-08-16" \
    "чему верить" "из трейса" "cd7f1c9" "запуск сессии" "исчезновение трейса"
  write_decision "$r/decisions/004-bez-verdikta-kritika.md" "2026-08-17" \
    "что утверждает план" "вердикт критика обязателен" "cca7090" "заморозка" "новый гейт"
  write_decision "$r/decisions/005-kritik-na-top.md" "2026-08-17" \
    "каким семейством" "верхний уровень чужого" "93fc601" "роль critic" "смена семейства"
  write_decision "$r/decisions/006-porog-kritika.md" "2026-08-17" \
    "когда блокировать" "только с названным обходом" "fa4457a" "текст роли critic" "слово владельца"
  write_decision "$r/decisions/007-riski-prinjaty.md" "2026-08-17" \
    "остаются ли риски" "приняты владельцем" "8ed63e6" "плана 005" "новое измерение"

  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  import_main_objects "$r"
  commit_all "$r" 'основание: контракт, вердикт, семь записей'
  g "$r" tag -a frozen/contracts/002/1 -m 'контракт заморожен'
}
