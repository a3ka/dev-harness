# Каркас подставного репозитория для фикстур `freeze_contract`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает дерево, на котором барьер обязан быть ЗЕЛЁНЫМ: контракт на HEAD,
# вердикт критика v1 с первой строкой `accept`, реестр заморозок пуст (законное начальное
# состояние). Зелёная основа обязательна — её предъявляет положительный контроль каждой фикстуры,
# иначе вечно-красный барьер неотличим от работающего.
#
# ГЕРМЕТИЧНОСТЬ обязательна: адверсарий предъявил измерением, что глобальная `commit.gpgsign` без
# ключа роняет построение истории кодом 128, а `core.hooksPath` — кодом 1 без текста. Тогда
# фикстура краснела бы от чужого конфига, а не от внесённой поломки, и мера врала бы о предмете.
#
# Локальная идентичность задаётся ФАЙЛОМ конфига дерева, а не только `-c`: сам барьер зовёт
# `git tag -a` без `-c`, и в герметичном окружении без локального `user.name` он падает с
# `empty ident name` — тогда проба валит барьер своим дефектом, а не предметом (запись Н-12).
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Вердикт критика с заданной первой строкой: три исхода грамматики разводятся отдельными
# фикстурами, потому что у барьера у них РАЗНЫЕ диагнозы.
put_verdict() {  # <корень> <версия> <первая строка>
  local r="$1" v="$2" first="$3"
  mkdir -p "$r/verdicts/critic"
  printf '%s\nтело вердикта\n' "$first" > "$r/verdicts/critic/contracts-001-v${v}.md"
}

make_repo() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/tmp"
  printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$r/contracts/001-x.md"
  put_verdict "$r" 1 accept
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  commit_all "$r" 'основание'
}
