# Каркас игрушечных деревьев семьи check_consumers (красная пачка 038 v3, Н-116).
#
# Имя НЕ case_*.sh: в прогон раннера не попадает (А-82); прямой запуск.
# REPO — корень харнеса: пин скратча (пост-фриз приземление правит ТОЛЬКО эту
# строку, остальное байт-в-байт; прецедент 034/5ac1478).
# v3 (Б3): маппинг — ФАЙЛ-НА-ПАРУ scripts/consumers.d/*.tsv (одна пара = один
# файл = одна строка; census-глоб считает файлы, замер-команда — строки);
# писатели-минимум ТРИ (п1 судит наличие всех трёх — отсюда сеем трёх, вход
# ломает СВОЮ ветвь поверх честной основы).
# v4 (арбитраж 038-Б3 / b0e4beb, к3-Б1): сеем НАСТОЯЩИЕ пути писателей-
# минимума стабами по коду реальных — scripts/freeze_contract.sh (под тестом),
# scripts/lib_registry.sh, scripts/done_contract.sh; toy-имена делали честный
# зелёный C/G1 недостижимым (п1 краснел бы «писатели-минимум не
# зарегистрированы» на каждой игрушке) — путь писателя есть идентификатор
# предиката (правило 5 норм) и несётся каркасом дословно.
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_consumers.sh"

g() {  # <корень> <git-аргументы>
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Fixture -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# seed_mapping <каталог> <consumer-писателя-под-тестом> — ТРИ писателя-минимума
# НАСТОЯЩИМИ путями (арбитраж 038-Б3), ТРИ пары ТРЕМЯ файлами (грамматика п1:
# имя файла = базовые имена сторон — писатель с .sh, потребитель с точками в
# подчёркиваниях; имя файла пары ВЫВОДИТСЯ из consumer-аргумента, чтобы призрак
# C4 получил согласованное с парой имя и красил именно свою ветвь).
# Писатель под тестом — scripts/freeze_contract.sh, его потребитель — аргумент
# (обычно fixtures/reader.sh; вход C4 подставляет призрак). Два остальных
# писателя-минимума (lib_registry, done_contract) сидят парами к живым
# читателям — не тронуты окном, проб для них не нужно (п3 судит только
# тронутых).
seed_mapping() {
  local r="$1" consumer="$2" cbase
  cbase="$(basename "$consumer")"; cbase="${cbase//./_}"
  mkdir -p "$r/scripts/consumers.d" "$r/fixtures"
  printf 'scripts/freeze_contract.sh\t%s\n' "$consumer" > "$r/scripts/consumers.d/freeze_contract.sh__${cbase}.tsv"
  printf 'scripts/lib_registry.sh\tscripts/spawner.sh\n'    > "$r/scripts/consumers.d/lib_registry.sh__spawner_sh.tsv"
  printf 'scripts/done_contract.sh\tscripts/speccer.sh\n'   > "$r/scripts/consumers.d/done_contract.sh__speccer_sh.tsv"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/freeze_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/lib_registry.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/done_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/spawner.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/speccer.sh"
  printf '# consumer fixture\n' > "$r/fixtures/reader.sh"
}

# make_crepo <каталог> <consumer-писателя-под-тестом> — честная основа гейта:
# маппинг файл-на-пару (3 писателя), base-коммит, живой тег frozen/contracts/001/1
# (граница окна; тег руками — законный локальный минимум читателя, п4: строку
# реестра пишет только писатель freeze 036-г5б). Окно = тег..HEAD: правки
# писателя делает вход поверх основы.
make_crepo() {
  local r="$1" consumer="$2"
  mkdir -p "$r/scripts" "$r/contracts" "$r/fixtures"
  seed_mapping "$r" "$consumer"
  printf '# kontrakt 001 v2 draft\n\n## Predmet\nprava pisatelja\n' > "$r/contracts/001-x.md"
  git -C "$r" init -q
  g "$r" config user.name Fixture
  g "$r" config user.email fixture@local
  commit_all "$r" 'osnovanie s mappingom'
  g "$r" tag -a frozen/contracts/001/1 -m 'granica okna'
}

touch_writer() {  # правка зарегистрированного писателя В ОКНЕ
  local r="$1"
  printf '#!/usr/bin/env bash\n# pravka pisatelja v okne\nexit 0\n' > "$r/scripts/freeze_contract.sh"
}

# Замер-строка v3 (Б3): census считает ФАЙЛЫ (3 пары = 3 файла), команда —
# строки; единый источник формы, индентно здесь — с начала строки в ЧЕРНОВИКЕ
# игрушки (её судит п1 наличием; исполнение — 036-В2 на заморозке носителя).
CENSUS='замер: `cat scripts/consumers.d/*.tsv | wc -l` = 3 census scripts/consumers.d/*.tsv'

# put_draft <каталог> <тело-черновика> — черновик v2 закоммичен В ОКНЕ.
put_draft() {
  local r="$1" body="$2"
  printf '# kontrakt 001 v2 draft\n\n## Predmet\nprava pisatelja\n\n%s\n' "$body" > "$r/contracts/001-x.md"
  commit_all "$r" 'chernovik v2'
}

LAST_OUT=''; LAST_RC=0
run_gate() {  # НАСТОЯЩИЙ гейт: <корень> <отн-путь-контракта>
  LAST_OUT="$(bash "$SUBJ" "$1" "$2" 2>&1)"; LAST_RC=$?
}

refuse() {
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s, ожидался 1\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: отказ не назвал причину дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

require_absent_subject() {
  [ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 038 НЕ РЕАЛИЗОВАН: гейт потребителей %s отсутствует на дереве — отсутствие барьера и есть честный красный (034-паттерн)\n' "$SUBJ" >&2; exit 1; }
}
