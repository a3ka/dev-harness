# Каркас подставного репозитория для фикстур `check_charter`.
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# `make_repo <каталог>` собирает дерево, на котором барьер обязан быть ЗЕЛЁНЫМ: устав введён тегом
# `ustav/1` на последнем коммите, `AGENTS.md` и `ROADMAP.md` на месте, один план заморожен по
# процедуре (тег + вердикт критика `accept`). Зелёная основа обязательна: её предъявляет
# положительный контроль каждой фикстуры, иначе вечно-красный барьер неотличим от работающего.
#
# ГЕРМЕТИЧНОСТЬ обязательна: глобальная `commit.gpgsign` без ключа роняет построение истории кодом
# 128, а `core.hooksPath` — кодом 1 без текста. Тогда фикстура краснела бы от чужого конфига, а не
# от внесённой поломки.
#
# Тег `ustav/1` ставится на ПОСЛЕДНИЙ коммит основания намеренно: так его подхватывает и
# `--depth 1`-клон (фикстура про недоступный реестр), и порядок совпадает с настоящим — тег после
# всех документных правок, иначе свои же правки станут красными.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Коммит с телом из stdin: строка разрешения обязана лежать в ПЕРВОЙ КОЛОНКЕ, а `-m` с отступом её
# бы обесценил — ровно тот дефект замера, от которого барьер и защищает.
commit_body() { g "$1" add -A; g "$1" commit -q -F -; }

make_repo() {
  local r="$1"
  mkdir -p "$r/plans" "$r/contracts" "$r/verdicts/critic" "$r/tmp"
  printf '# норма системы\nправило 1: правило без механизма не существует\n' > "$r/AGENTS.md"
  printf '# роадмап\nшаг 5 сделан\n'                                        > "$r/ROADMAP.md"
  printf 'предмет плана, критерий готовности, исполнители\n'                > "$r/plans/001-p.md"
  printf 'accept\nвердикт критика по плану 001\n'                           > "$r/verdicts/critic/plans-001-v1.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  commit_all "$r" 'основание: норма, роадмап, план и вердикт критика'
  g "$r" tag -a frozen/plans/001/1 -m 'план утверждён'
  g "$r" tag -a ustav/1 -m 'устав действует'
}
