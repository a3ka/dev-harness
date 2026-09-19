# ПРИЧИНА: ОТКАЗ: дверь минта 031
#
# Контракт 031, ветвь i: легитимный минт оркестратора (полная авторитетная
# церемония: тег аннотирован и запушен на origin, main запушен, строка по
# грамматике манифеста staged, автор orchestrator, ветка main) проходит
# БЕЗ суда зон, rc 0 + «judged: registry/contracts.tsv (дверь минта 031: ...».
# Зелёный контроль — легитимный минт: door проходит, «ОТКАЗ:» не печатается.
# Красный — провал авторитетной половины церемонии (нет тега выдачи id/CONTRACT):
# дверь отказывает с «ОТКАЗ: дверь минта 031: тег id/CONTRACT/<N> не жив локально».
# Назначение case-файла: дверь минта пропускает полную церемонию, и отвергает
# обман (mint церемонией БЕЗ тега выдачи) — оба класса именованной причиной.
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── локальный каркас минта (inlined; исходник — red_dver_minta_orkestratora.sh) ──
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
toy_origin() {  # <каталог>
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main
}
make_repo_orchzone() {  # <корень>
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
mint_tag_avtoritet() {  # <корень> <NNN>
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача (фикстура)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}
stage_row() {  # <корень> <NNN> <sha>
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}
set_author() {  # <корень> <имя>
  local r="$1" name="$2"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name "$name"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email "$name@local"
}

# ── в1 зелёный: полный минт — дверь проходит ────────────────────────────────
GREEN="$WORK/repo_green"
make_repo_orchzone "$GREEN"
toy_origin "$GREEN"
NNN_G="020"
mint_tag_avtoritet "$GREEN" "$NNN_G"
set_author "$GREEN" orchestrator
sha="$(git -C "$GREEN" rev-parse "refs/tags/id/CONTRACT/$NNN_G")"
stage_row "$GREEN" "$NNN_G" "$sha"
"$BARRIER" "$GREEN" || true

# ── в5 красный: нет тега выдачи — дверь отказывает именем ─────────────────────
RED="$WORK/repo_red"
make_repo_orchzone "$RED"
toy_origin "$RED"
set_author "$RED" orchestrator
stage_row "$RED" "021" "0000000000000000000000000000000000000000"   # тег НЕ создан
"$BARRIER" "$RED" || true