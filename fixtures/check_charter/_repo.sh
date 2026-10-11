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

# ── строитель merge-входа ленда дверью 094 (контракт 094, И-10: миграция
# пяти land-кейсов семьи с удалённого scripts/land_agent.sh; предмет кейсов —
# суд устава барьером check_charter над ПОСТРОЕННЫМ merge — не меняется) ──

# door_policy <repo> — предпосылки двери в toy-репо: политика toy-мира
# harness/policy (repoId/mandatory/targetBranches) + доверенное определение
# единственной обязательной проверки. Зовётся ДО commit_all основания: дверь
# читает политику по base SHA (И-6), не из рабочего дерева.
door_policy() {
  local r="$1"
  mkdir -p "$r/harness/checks"
  printf 'repoId=toy-065\nmandatory=ci-065\ntargetBranches=main\n' > "$r/harness/policy"
  printf 'run toy-065 ci-065\n' > "$r/harness/checks/ci-065.cmd"
}

# land_door <repo> <ветка> <журнал> — ленд через дверь: prepare строит
# merge-коммит (перенос строк-санкций из тел коммитов диапазона base..cand
# дословно, дедуп точных повторов — именно его судит барьер), publish двигает
# main. Toy-журнал пишет КЕЙС — паттерн семьи accept_publish_094: вердикт
# accept объекта + зелёные строки check (wfsha доверенного определения на
# base ∧ дерево подготовленного merge). Вывод двери — в stdout вызывающему
# (успех публикует «PUBLISHED target=main merge=<sha>»), rc функции = rc
# последнего шага двери.
land_door() {
  local r="$1" br="$2" j="$3" base cand m oid name wfs mt out
  base="$(g "$r" rev-parse refs/heads/main)"
  cand="$(g "$r" rev-parse "refs/heads/$br")"
  out="$(bash "$REPO/scripts/accept_publish.sh" prepare --repo "$r" --task "$br" --base "$base" --candidate "$cand" 2>&1)" || {
    printf '%s\n' "$out"; return 1; }
  m="$(printf '%s\n' "$out" | tail -n1)"
  out="$(bash "$REPO/scripts/accept_publish.sh" object --repo "$r" --task "$br" --target main --base "$base" --candidate "$cand" --merge "$m" 2>&1)" || {
    printf '%s\n' "$out"; return 1; }
  oid="$(printf '%s\n' "$out" | tail -n1)"
  : > "$j"
  printf 'verdict\t%s\t%s\taccept\t1\n' "$br" "$oid" >> "$j"
  mt="$(g "$r" rev-parse "$m^{tree}")"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    wfs="$(g "$r" show "$base:harness/checks/$name.cmd" | sha256sum | cut -d' ' -f1)"
    printf 'check\t%s\t%s\tok\t1\t%s\t%s\n' "$oid" "$name" "$wfs" "$mt" >> "$j"
  done < <(g "$r" show "$base:harness/policy" | sed -n 's/^mandatory=//p' | tr ',' '\n')
  out="$(bash "$REPO/scripts/accept_publish.sh" publish --repo "$r" --task "$br" --target main --base "$base" --candidate "$cand" --merge "$m" --candidate-ref "$br" --journal "$j" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] && g "$r" checkout -q -f main   # дверь двигает ТОЛЬКО ref
  # (атомарный update-ref, И-8): рабочее дерево toy-репо синхронизируется с
  # опубликованным main — дальнейшие шаги кейса (красные слияния, барьер)
  # судят дерево опубликованного merge, а не отставший checkout.
  printf '%s\n' "$out"
  return "$rc"
}
