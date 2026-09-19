# ПРИЧИНА: дверь минта 031: номер
#
# Контракт 031, ветвь i, условие 3 (реестр): NNN уже в манифесте HEAD (повторный
# минт запрещён). Зелёный — полный минт нового NNN (rc 0). Красный — NNN уже в HEAD
# (mint_row_commit); «дверь минта 031: номер <N> уже в манифесте — повторный минт».
# Фикстура держит ОБЕ половины условия 3 одним классом — origin-половина тем же
# именем, отказ сети — отдельный класс «авторитет недоступен» (НЕ этот case).
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
toy_origin() {
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main
}
make_repo_orchzone() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name orchestrator
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email orchestrator@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}
mint_tag_avtoritet() {
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача (фикстура)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}
mint_row_commit() {  # <корень> <NNN>: авторитет коммитит строку манифеста + пушит main
  local r="$1" n="$2" sha
  sha="$(git -C "$r" rev-parse "refs/tags/id/CONTRACT/$n")"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
  g "$r" commit -q -m "реестр: резерв $n"
  g "$r" push -q origin main
}
stage_row() {
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}
set_author() {
  local r="$1" name="$2"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name "$name"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email "$name@local"
}

# ── зелёный: новый NNN ───────────────────────────────────────────────────────
GREEN="$WORK/repo_green"
make_repo_orchzone "$GREEN"
toy_origin "$GREEN"
mint_tag_avtoritet "$GREEN" "024"
set_author "$GREEN" orchestrator
sha="$(git -C "$GREEN" rev-parse "refs/tags/id/CONTRACT/024")"
stage_row "$GREEN" "024" "$sha"
"$BARRIER" "$GREEN" || true

# ── красный: NNN уже в HEAD (повторный минт) ─────────────────────────────────
RED="$WORK/repo_red"
make_repo_orchzone "$RED"
toy_origin "$RED"
mint_tag_avtoritet "$RED" "025"
mint_row_commit "$RED" "025"      # HEAD уже содержит NNN
# Переминт тега (свежий sha) и попытка stage'ить вторую строку того же NNN:
g "$RED" tag -d "id/CONTRACT/025" >/dev/null
mint_tag_avtoritet "$RED" "025"   # теперь refs/tags/id/CONTRACT/025 указывает на новый sha
set_author "$RED" orchestrator
sha="$(git -C "$RED" rev-parse "refs/tags/id/CONTRACT/025")"
stage_row "$RED" "025" "$sha"
"$BARRIER" "$RED" || true