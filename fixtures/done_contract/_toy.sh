# Каркас игрушечных деревьев семьи done_contract (красная пачка 038, Н-116).
#
# Имя НЕ case_*.sh: в прогон раннера не попадает (А-82); прямой запуск.
# REPO — корень харнеса: пин скратча (пост-фриз приземление правит ТОЛЬКО эту
# строку, остальное байт-в-байт; прецедент 034/5ac1478).
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/done_contract.sh"
PROVODKA_BARRIER="$REPO/scripts/check_provodka.sh"

g() {  # <корень> <git-аргументы>
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Fixture -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# make_drepo <каталог> <блок-ПРОВОДКА> — честная основа писателя: контракт с
# полем, зелёная role-провока (guard-каналы несут R-семья, здесь минимум),
# вердикт ревьюера v1 «accept», всё закоммичено. v3 (Б2, шаг 6а): сеем маппинг
# файл-на-пару — 3 писателя-минимума, НИ один не тронут окном; шаг 6а
# (check_consumers) в честных входах D-семьи проходит vacuous. v4 (арбитраж
# 038-Б3 / b0e4beb, к3-Б1): сеем НАСТОЯЩИЕ пути писателей-минимум стабами по
# коду реальных — предикат п1 судит поимённо именно эти три имени; toy-имена
# делали честный зелёный D/G недостижимым.
make_drepo() {
  local r="$1" block="$2"
  mkdir -p "$r/contracts" "$r/roles" "$r/verdicts/review" "$r/scripts/consumers.d" "$r/fixtures"
  printf 'scripts/freeze_contract.sh\tfixtures/reader.sh\n' > "$r/scripts/consumers.d/freeze_contract.sh__reader_sh.tsv"
  printf 'scripts/lib_registry.sh\tscripts/spawner.sh\n'    > "$r/scripts/consumers.d/lib_registry.sh__spawner_sh.tsv"
  printf 'scripts/done_contract.sh\tscripts/speccer.sh\n'   > "$r/scripts/consumers.d/done_contract.sh__speccer_sh.tsv"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/freeze_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/lib_registry.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/done_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/spawner.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/speccer.sh"
  printf '# consumer fixture\n' > "$r/fixtures/reader.sh"
  printf '# role fixture\n\nNorma stroki roli v igrushke D.\n' > "$r/roles/fixer.md"
  printf '# kontrakt 001\n\n## Predmet\npodstavnoj predmet\n\n## Norma-provodka\n%s\n' "$block" > "$r/contracts/001-x.md"
  printf 'accept\ntelo verdikta\n' > "$r/verdicts/review/contracts-001-v1.md"
  git -C "$r" init -q
  g "$r" config user.name Fixture
  g "$r" config user.email fixture@local
  commit_all "$r" 'osnovanie'
}

GREEN_PROVODKA='ПРОВОДКА:
- role=roles/fixer.md «Norma stroki roli v igrushke D.»'
GHOST_PROVODKA='ПРОВОДКА:
- guard=scripts/ghost.sh
- role=roles/fixer.md «Norma stroki roli v igrushke D.»'

put_verdict() {  # <корень> <базовое-имя-файла> <первая строка>
  local r="$1" name="$2" first="$3"
  mkdir -p "$r/verdicts/review"
  printf '%s\ntelo verdikta\n' "$first" > "$r/verdicts/review/$name"
}

done_tags() { g "$1" tag -l 'done/contracts/*' | sort; }

# run_writer <каталог> <причина> — НАСТОЯЩИЙ писатель в cwd игрушки; rc/вывод в LAST_*
run_writer() {
  LAST_OUT="$(cd "$1" && bash "$SUBJ" contracts/001-x.md "$2" "$1" 2>&1)"; LAST_RC=$?
}

# refuse <имя-входа> <фраза>: писатель обязан дать rc 1 и назвать причину дословно.
refuse() {
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s, ожидался 1\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: отказ не назвал причину дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

require_absent_subject() {
  [ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 038 НЕ РЕАЛИЗОВАН: писатель done-тега %s отсутствует на дереве — отсутствие барьера и есть честный красный (034-паттерн)\n' "$SUBJ" >&2; exit 1; }
}
