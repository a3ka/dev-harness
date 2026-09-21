# Каркас игрушечных деревьев семьи check_provodka (красная пачка 038, Н-116).
#
# Имя НЕ case_*.sh: в прогон раннера не попадает (А-82); прямой запуск.
# REPO — корень харнеса: пин скратча (пост-фриз приземление правит ТОЛЬКО эту
# строку на вычисление от $HERE/../.., остальное байт-в-байт; прецедент 034/5ac1478).
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_provodka.sh"

g() {  # <корень> <git-аргументы>
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Fixture -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# make_toy <каталог> <role:0|1> <charter:0|1> — ЧЕСТНАЯ основа: guard существует
# и подключён (.githooks/pre-commit, некомментированная строка вызова), role-файл
# с норма-строкой отдельной строкой, устав с секцией «Воркфлоу майлстоуна» и
# норма-строкой в её теле. Флаг 0 заглушает свою сторону; вход-файл ЛОМАЕТ свою
# ветвь поверх честной основы, чтобы красное пришло именем СВОЕЙ причины.
make_toy() {
  local r="$1" with_role="$2" with_charter="$3"
  mkdir -p "$r/contracts" "$r/scripts" "$r/.githooks" "$r/roles"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/check_ok.sh"
  printf 'bash scripts/check_ok.sh\n' > "$r/.githooks/pre-commit"
  if [ "$with_role" = 1 ]; then
    printf '# role fixture\n\nNorma stroki roli v igrushke R.\n' > "$r/roles/fixer.md"
  else
    printf '# role fixture\n\ntelo bez normy\n' > "$r/roles/fixer.md"
  fi
  if [ "$with_charter" = 1 ]; then
    printf '# Ustav\n\n## Воркфлоу майлстоуна\n\nNorma stroki ustava v igrushke R.\n\n## Drugaja sekcija\n\ntelo\n' > "$r/AGENTS.md"
  else
    printf '# Ustav\n\n## Drugaja sekcija\n\nNorma stroki ustava v igrushke R.\ntelo\n' > "$r/AGENTS.md"
  fi
  git -C "$r" init -q
  g "$r" config user.name Fixture
  g "$r" config user.email fixture@local
  commit_all "$r" 'osnovanie'
}

# put_contract <каталог> <блок-ПРОВОДКА|пусто=поля нет вовсе>
put_contract() {
  local r="$1" block="$2"
  if [ -n "$block" ]; then
    printf '# kontrakt 001\n\n## Predmet\npodstavnoj predmet\n\n## Norma-provodka\n%s\n' "$block" > "$r/contracts/001-x.md"
  else
    printf '# kontrakt 001\n\n## Predmet\npodstavnoj predmet\n' > "$r/contracts/001-x.md"
  fi
}

# run_barrier <каталог> — НАСТОЯЩИЙ барьер против игрушки; rc/вывод в LAST_*
LAST_OUT=''; LAST_RC=0
run_barrier() {
  LAST_OUT="$(cd "$1" && bash "$SUBJ" "$1" contracts/001-x.md 2>&1)"; LAST_RC=$?
}

# refuse <имя-входа> <фраза>: барьер обязан дать rc 1 и назвать причину ДОСЛОВНО.
refuse() {
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s, ожидался 1\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: отказ не назвал причину дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

# require_absent_subject — красный 034-паттерна: до реализации сам прогон красен
# отсутствием барьера (живой красный, не пропуск).
require_absent_subject() {
  [ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 038 НЕ РЕАЛИЗОВАН: барьер проводки %s отсутствует на дереве — отсутствие барьера и есть честный красный (034-паттерн)\n' "$SUBJ" >&2; exit 1; }
}
