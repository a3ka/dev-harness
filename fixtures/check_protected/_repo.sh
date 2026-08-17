# Каркас подставного репозитория для фикстур `check_protected`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает репозиторий, на котором барьер обязан быть ЗЕЛЁНЫМ: одна
# роль с объявленным каталогом вердиктов, один вердикт, один план, один коммит. Зелёная
# основа обязательна — её предъявляет положительный контроль каждой фикстуры, иначе
# вечно-красный барьер неотличим от работающего.
#
# История строится в `$WORK`, а не в репозитории инструмента: фикстура, трогающая настоящую
# историю, оставляет за собой поломку, которую потом ищут не там.
# ГЕРМЕТИЧНОСТЬ обязательна: адверсарий предъявил измерением, что глобальная `commit.gpgsign`
# без ключа роняет построение истории кодом 128, а `core.hooksPath` — кодом 1 без текста. Тогда
# фикстура краснела бы от чужого конфига, а не от внесённой поломки, и мера врала бы о предмете.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

make_repo() {
  local r="$1"
  mkdir -p "$r/roles" "$r/plans" "$r/verdicts/adversary" "$r/tmp"
  printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\nадверсарий\n' > "$r/roles/adversary.md"
  printf 'подставной план\n'    > "$r/plans/001-p.md"
  printf 'подставной вердикт\n' > "$r/verdicts/adversary/v-a.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  commit_all "$r" 'основание'
}
