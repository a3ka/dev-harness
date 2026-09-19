# ПРИЧИНА: дверь минта 031: строка не по грамматике манифеста
#
# Контракт 031, ветвь i, условие 2 (грамматика): staged-дельта манифеста содержит
# строку НЕ по грамматике «^[0-9]{3} → [0-9a-f]{40}$» (ASCII-стрелка «->» вместо
# U+2192, не-40-hex, не-%03d). Зелёный контроль — полный минт авторитетной
# церемонией (rc 0). Красный — ASCII-стрелка «->» вместо U+2192: «дверь минта
# 031: строка не по грамматике манифеста». Другие классы грамматики (не-40-hex,
# не-%03d) тем же именем; один вход — один класс.
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

# ── зелёный: полный минт ────────────────────────────────────────────────────
GREEN="$WORK/repo_green"
make_repo_orchzone "$GREEN"
toy_origin "$GREEN"
mint_tag_avtoritet "$GREEN" "022"
set_author "$GREEN" orchestrator
sha="$(git -C "$GREEN" rev-parse "refs/tags/id/CONTRACT/022")"
stage_row "$GREEN" "022" "$sha"
"$BARRIER" "$GREEN" || true

# ── красный: ASCII-стрелка «->» вместо U+2192 ────────────────────────────────
RED="$WORK/repo_red"
make_repo_orchzone "$RED"
toy_origin "$RED"
mint_tag_avtoritet "$RED" "023"
set_author "$RED" orchestrator
sha="$(git -C "$RED" rev-parse "refs/tags/id/CONTRACT/023")"
# ASCII-стрелка вместо U+2192 — НЕ по грамматике « → »
mkdir -p "$RED/registry"
printf '%s -> %s\n' "023" "$sha" >> "$RED/registry/contracts.tsv"
g "$RED" add -A
"$BARRIER" "$RED" || true