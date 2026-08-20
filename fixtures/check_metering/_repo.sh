# Каркас фикстур scripts/check_metering.sh.
#
# Подключается ВСЕМИ фикстурами этого каталога: make_repo собирает в $WORK/repo дерево
# (прокси, барьер, config/), stub_proxy подменяет прокси заглушкой, rnd порождает имя
# при каждом прогоне.
#
# Имя НЕ case_*.sh: сам каркас фикстурой не считается и verify_antiplacebo.sh его не
# перечисляет.
#
# Каркас падает с понятным отказом, если источника нет. $REPO — корень с прокси и
# барьером; путь берётся из verify_antiplacebo.sh ($REPO=$ROOT).

# rnd <префикс> — порождаемое при каждом прогоне имя. Префикс остаётся, хвост случаен.
# Двойной RANDOM — замер арбитража: один RANDOM коллизит с тем же тиком процесса,
# два — расходятся надёжно. Подключающий проверяющий тоже использует rnd (verify_antiplacebo
# гоняет фикстуру дважды для подтверждения красноты), поэтому rnd должен быть случаен при
# каждом вызове, а не только при первом.
rnd() { printf '%s-%s%s' "$1" "$RANDOM" "$RANDOM"; }

# make_repo — собрать в $WORK/repo дерево с прокси и барьером.
#
# $WORK/repo/scripts/proxy/metering_proxy.ts — копия из $REPO/scripts/proxy/, чтобы
# stub_proxy мог подменить этот файл заглушкой.
# $WORK/repo/scripts/check_metering.sh — копия барьера из $REPO.
# $WORK/repo/config/metering.json — копия из $REPO/config/.
#
# Без источника — die с именем пути, а не молчаливый выход (правило 7 нормы: отказ
# называет ИМЯ и ФАКТ).
make_repo() {
  local repo="${1:-$WORK/repo}"
  mkdir -p "$repo/scripts/proxy" "$repo/config"
  [ -f "$REPO/scripts/proxy/metering_proxy.ts" ] \
    || die "источника нет: \$REPO/scripts/proxy/metering_proxy.ts — прокси не закоммичен"
  [ -f "$REPO/scripts/check_metering.sh" ] \
    || die "источника нет: \$REPO/scripts/check_metering.sh"
  [ -f "$REPO/config/metering.json" ] \
    || die "источника нет: \$REPO/config/metering.json"
  cp "$REPO/scripts/proxy/metering_proxy.ts" "$repo/scripts/proxy/metering_proxy.ts"
  cp "$REPO/scripts/check_metering.sh" "$repo/scripts/check_metering.sh"
  cp "$REPO/config/metering.json" "$repo/config/metering.json"
  printf '%s\n' "$repo"
}

# stub_proxy <файл> — подменить файл прокси заглушкой из переданного файла.
#
# Используется для красного предъявления: фикстура пишет стаб, который нарушает ОДНУ
# грань контракта, делает make_repo, потом подменяет metering_proxy.ts этим стабом —
# и барьер видит «честный» барьер вокруг сломанной реализации прокси.
#
# Путь к прокси в собранном make_repo дереве захардкожен: всякая фикстура собирает
# через make_repo, и относительный путь scripts/proxy/metering_proxy.ts — это
# конвенция каркаса, а не то, что фикстура может переписать.
stub_proxy() {
  local stub="$1"
  local repo="${WORK_REPO:-$WORK/repo}"
  [ -f "$stub" ] || die "файла стаба нет: $stub"
  cp "$stub" "$repo/scripts/proxy/metering_proxy.ts"
}

# die — локальная обёртка, фикстуры анти-плацебо работают без set -e в начале и не
# имеют общей die; verify_antiplacebo ловит код 1, и причина ОБЯЗАНА быть на stderr,
# а не на stdout (анти-плацебо читает вывод фикстуры иначе).
die() { printf 'ОТКАЗ ФИКСТУРЫ: %s\n' "$*" >&2; exit 1; }
