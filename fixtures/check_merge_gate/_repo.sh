# Каркас подставного репозитория для семьи `fixtures/check_merge_gate/`
# (контракт 063, ветвь (б) — `scripts/check_merge_gate.sh`: accept-вердикт
# в HEAD ∧ нет блокирующих `.review/`-находок).
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон verify_antiplacebo
# не попадает (прецедент fixtures/check_decisions/_repo.sh, 002).
#
# `make_repo <каталог>` собирает двухслойный профиль (репо + слой проекта в
# скретче через $HARNESS_PROJECT_LAYER_ROOT) И минимальное дерево под вердикт
# ревьюера в `.harness/verdicts/`. Зелёная основа ОБЯЗАТЕЛЬНА: её предъявляет
# положительный контроль каждой фикстуры, иначе вечно-красный барьер неотличим
# от работающего (правило 3 нормы).
#
# ГЕРМЕТИЧНОСТЬ: глобальная `commit.gpgsign` без ключа роняет построение истории
# кодом 128, а `core.hooksPath` — кодом 1 без текста. Тогда фикстура краснела бы
# от чужого конфига, а не от внесённой поломки (прецедент check_decisions/_repo.sh,
# 002).
#
# ЛИЦЕНЗИЯ ПОДСТАВНОГО ДЕРЕВА: единственный пользователь резолвера — барьер, и
# других семей фикстура не подразумевает. Контракт 063 не предъявляет тегов
# заморозки на дерево проекта (заморозка — артефакт самого харнесса), и
# посторонний артефакт запрещён.

g() {  # <корень> <git-argv...>
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

# Слой проекта игрушки: пишется ОДИН РАЗ на семью (verify_antiplacebo пере-
# запускает клетки в общем прогоне против общего скратча $WORK; сам `$WORK`
# принадлежит прогонщику, поэтому общий `harness-project.json` живёт в
# `$WORK/layer/registry/`). Репо-слой каждая клетка пишет СВОЙ через
# `write_repo_profile`, чтобы различаться по ВЕТВИ предмета.
ensure_project_layer() {
  LAYER="$WORK/layer"; mkdir -p "$LAYER/registry"
  if [ ! -s "$LAYER/registry/harness-project.json" ]; then
    printf '{"schemaVersion":1,"version":"t1","projectId":"toy63","workspaceId":"ws1"}\n' \
      > "$LAYER/registry/harness-project.json"
  fi
  export HARNESS_PROJECT_LAYER_ROOT="$LAYER"
}

# Репо-слой: gate-вариант (workflowPaths, без commands/ci/barriers). Профиль
# обязан объявить `workflowPaths.verdicts` — иначе резолвер И-8 не вернёт
# путь, барьер сразу откажет «вердикты негде искать», и фикстура не увидит
# своего предмета.
write_repo_profile() {  # <каталог>
  cat > "$1/harness.project.json" <<JSON
{
  "schemaVersion": 1,
  "repoId": "toy63",
  "language": "typescript",
  "projectLayer": {"version": "t1", "profilePath": "registry/harness-project.json"},
  "workflowPaths": {
    "contracts": ".harness/contracts",
    "verdicts": ".harness/verdicts",
    "registry": ".harness/registry",
    "fixtures": ".harness/fixtures"
  }
}
JSON
}

# make_repo <каталог>: подставное репо с зелёной основой гейта.
#   — профиль записан и закоммичен;
#   — `.harness/verdicts/` создан (пустой каталог — валидно для резолвера,
#     гейт по пустому каталогу даст «нет закоммиченного accept-вердикта» —
#     это ЗЕЛЁНАЯ ОСНОВА ровно тогда, когда фикстура кладёт accept сама).
make_repo() {
  local r="$1"
  ensure_project_layer
  mkdir -p "$r/.harness/verdicts" "$r/.harness/registry" "$r/.harness/fixtures" "$r/.harness/contracts"
  write_repo_profile "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  g "$r" config user.name Фикстура
  g "$r" config user.email fixture@local
  commit_all "$r" 'основание: профиль и каталог вердиктов'
}

# put_accept <каталог> <имя-файла>: положить закоммиченный accept-вердикт.
# Барьер судит первую строку блоба `HEAD:<путь>` — литерал `accept` (И-2).
put_accept() {  # <корень> <имя-файла-в-verdicts>
  printf 'accept\n\n# Суд фикстуры 063\n\nвердикт честного ревьюера\n' \
    > "$1/.harness/verdicts/$2"
  commit_all "$1" 'вердикт accept'
}

# put_fail <каталог> <имя-файла>: положить закоммиченный FAIL-вердикт.
# Первая строка `FAIL` — НЕ `accept`, барьер И-2 на ней НЕ открывает ворота.
put_fail() {  # <корень> <имя-файла-в-verdicts>
  printf 'FAIL\n\n# Суд фикстуры 063\n\nотказ по предмету\n' \
    > "$1/.harness/verdicts/$2"
  commit_all "$1" 'вердикт FAIL'
}

# review_file <корень> <имя> <status>: закоммиченный `.review/<имя>.md` с
# frontmatter `status: <status>`. Алфавит И-3 замкнут: ready | partial | done.
review_file() {  # <корень> <имя-файла-в-.review> <status>
  mkdir -p "$1/.review"
  printf -- '---\nstatus: %s\n---\n\n- [ ] находка фикстуры 063\n' "$3" > "$1/.review/$2"
  commit_all "$1" "review $2 ($3)"
}
