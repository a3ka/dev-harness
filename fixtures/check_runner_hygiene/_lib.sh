# НЕ ФИКСТУРА (нет case_-префикса): общая библиотека зелёных корней для фикстур
# барьера check_runner_hygiene (контракт 011). Подключается строкой
#   . "$(dirname "$0")/_lib.sh"
# в каждом case_*.sh. Зелёный корень = эталонный раннер (_ref_runner.sh) + ПОЛНАЯ норма
# (маркер приёмки судьи v2 + carve-out правила 16 + аннотированный 010). Красный корень
# каждая фикстура делает сама, ломая в нём ровно одну вещь — дефект обманки наблюдаем
# ровно на той ветви, куда её подают (Н-39).
HYG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mk_norm_agents() {  # <корень> — AGENTS.md с полной зелёной нормой
  cat > "$1/AGENTS.md" <<'EOF'
# Устав (игрушечный — материал фикстур check_runner_hygiene, контракт 011)

## Воркфлоу майлстоуна

ПРИЁМКА-СУДЬИ (v2, Н-48): судья (критик/адверсарий/ревьюер) гоняет ТОЛЬКО scoped-регресс
затронутых барьеров (`verify_antiplacebo --scope <ключ>`) и git-diff неизменности
frozen-барьеров; полный прогон — только CI, от судьи он не требуется.

16. Всё по-русски. Временное — в `./tmp`, не в системном `/tmp`.
    ИСКЛЮЧЕНИЕ (carve-out, РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-08-24): scratch раннера
    `scripts/verify_antiplacebo.sh` живёт вне стерегомого дерева (в системном `/tmp`
    или под `$VERIFY_ANTIPLACEBO_SCRATCH`).
EOF
}

mk_010_annotated() {  # <корень> — contracts/010 с пометкой v+1 у п.8
  mkdir -p "$1/contracts"
  cat > "$1/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный — материал фикстур check_runner_hygiene, контракт 011)

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0
   (отменено грилингом 2026-08-24, см. contracts/011: судье — scoped-регресс затронутых
   барьеров, полный прогон — CI, Н-48).
EOF
}

mk_norm_isol() {  # <корень> — нормы изоляции шага А/В контракта 012 (игрушечные)
  mkdir -p "$1/.omp" "$1/roles"
  cat > "$1/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — материал фикстур check_runner_hygiene, контракт 012)
tools:
  approvalMode: always-ask

# Изоляция спавна субагентов (решение владельца 2026-08-26, шаг А): параллельные
# пачки не контендятся за живое дерево — каждое дерево процесса в своём сабволюме.
task:
  isolation:
    mode: btrfs
EOF
  cat > "$1/roles/architect.md" <<'EOF'
# Роль architect (игрушечная — материал фикстур, контракт 012)

Клон роли живёт вне стерегомого дерева: `${TMPDIR}/dev-harness-architect/repo`,
НЕ `./tmp/<имя>/repo` — клон внутри дерева сам является мутацией стерегомого.
EOF
  cat > "$1/roles/orchestrator.md" <<'EOF'
# Роль orchestrator (игрушечная — материал фикстур, контракт 012)

Параллельные пачки architect/implementer спавнятся с `isolated: true`.
Длинные прогоны verify_antiplacebo — только в disposable-клоне:
`git clone <дерево> ${TMPDIR}/dev-harness-verify/repo` и раннер по копии.
EOF
}

mk_green_root() {  # <каталог> — эталонный раннер + полная норма (011 + 012)
  mkdir -p "$1/scripts"
  cp "$HYG/_ref_runner.sh" "$1/scripts/verify_antiplacebo.sh"
  chmod +x "$1/scripts/verify_antiplacebo.sh"
  mk_norm_agents "$1"
  mk_010_annotated "$1"
  mk_norm_isol "$1"
}

# ── подставные git-репозитории для ветви porjadok (прецедент — _repo.sh у check_zones) ──
# ГЕРМЕТИЧНОСТЬ обязательна: глобальная commit.gpgsign без ключа роняет построение
# истории, а core.hooksPath — кодом 1 без текста.
pgit() {  # <корень> <аргументы git>
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "${@:2}"
}

pgit_commit_as() {  # <корень> <автор> <сообщение>
  local r="$1" who="$2" msg="$3"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name="$who" -c user.email="$who@local" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name="$who" -c user.email="$who@local" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$msg"
}

mk_porjadok_green() {  # <каталог> — зелёный порядок актов 010-v2:
  # (i) implementer коммитит раннер+норму+аннотацию, (ii) critic ОТДЕЛЬНЫМ коммитом —
  # вердикт accept. Перезаморозка (iii) — тег, истории коммитов не касается.
  mk_green_root "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git init -q -b main "$1"
  pgit_commit_as "$1" implementer 'раннер + маркер AGENTS.md + аннотация 010 (акт i)

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md норма приёмки судьи v2 (слово владельца на грилинге 2026-08-24)'
  mkdir -p "$1/verdicts/critic"
  printf 'accept\nотдельный круг критика по закоммиченному блобу 010 (акт ii)\n' \
    > "$1/verdicts/critic/contracts-010-v2.md"
  pgit_commit_as "$1" critic 'вердикт 010-v2: accept (акт ii)'
}
