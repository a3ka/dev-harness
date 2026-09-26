# ПРИЧИНА: registry/contracts.tsv — дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «не максимальная версия», близнец в check_zones.sh
# (минт-признание 031 ветвь ii, пост-хок суд истории). §Инварианты п.1: новый sha замены
# — tag-object frozen/contracts/<NNN>/<vmax>, где vmax для суда истории — наибольшая
# версия, чей коммит — предок судимого коммита (существовавшая к моменту коммита).
# Зелёный (после фикса) — toy GREEN, штатная история двух заморозок: минт → v1 (коммит
# C1), заморозка v2, v1 → v2 (коммит C2). Признаны обязаны быть ОБА коммита. Прочтение
# «vmax — высшая из живых СЕЙЧАС» красит C1 задним числом (сейчас жив v2) — это класс
# Н-156, и здесь оно различимо: зелёного нет. Стаб «старая сторона — только sha минта»
# красит C2 и различим на этом же входе.
# Красный — toy RED: заморозки v1 и v2 обе в предках, затем минт → tag-object v1 — отказ
# по новой стороне. Стаб «tag-object ЛЮБОЙ живой версии того же NNN» зеленеет здесь.
# На нечиненном коде зелёного нет — клетка красна «нет положительного контроля».
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (одинаков в клетках семьи) ───────────────────────────────────────
toy_origin() {  # <корень>
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main "refs/tags/frozen/contracts/001/1"
}
mint_toy() {  # <корень> <NNN>
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача механизмом (фикстура)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$(git -C "$r" rev-parse "refs/tags/id/CONTRACT/$n")" >> "$r/registry/contracts.tsv"
  commit_as "$r" orchestrator "реестр: резерв $n"
  g "$r" push -q origin main
}
osnova() {  # <корень>
  local r="$1"
  make_repo "$r" "$(printf 'ЗОНА implementer: scripts/\nЗОНА orchestrator: HANDOFF.md')"
  toy_origin "$r"
  mint_toy "$r" 040
  mint_toy "$r" 041
  add_contract "$r" 040 'ЗОНА implementer: scripts/'
  g "$r" push -q origin main "refs/tags/frozen/contracts/040/1"
}
# Заморозка версии <v> контракта 040 (правка файла коммитом Фикстура — необъявленный
# автор, не судится; аннотированный frozen-тег на origin).
freeze_ver040() {  # <корень> <v>
  local r="$1" v="$2"
  printf '# контракт 040 v%s\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА implementer: scripts/\n' \
    "$v" > "$r/contracts/040-y.md"
  commit_all "$r" "контракт 040 v$v"
  g "$r" tag -a "frozen/contracts/040/$v" -m "контракт 040 v$v утверждён"
  g "$r" push -q origin main "refs/tags/frozen/contracts/040/$v"
}
perepis() {  # <корень> <NNN> <новый sha>
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  commit_as "$r" orchestrator "freeze: registry $n → $sha"
}
tagobj() { git -C "$1" rev-parse "refs/tags/frozen/contracts/040/$2"; }  # <корень> <v>

# ── зелёный (после фикса): минт → v1, заморозка v2, v1 → v2 ───────────────────────
GREEN="$WORK/repo_green"
osnova "$GREEN"
perepis "$GREEN" 040 "$(tagobj "$GREEN" 1)"
freeze_ver040 "$GREEN" 2
perepis "$GREEN" 040 "$(tagobj "$GREEN" 2)"
"$BARRIER" "$GREEN" || true

# ── красный: v1, v2 в предках; минт → tag-object v1 ───────────────────────────────
RED="$WORK/repo_red"
osnova "$RED"
freeze_ver040 "$RED" 2
perepis "$RED" 040 "$(tagobj "$RED" 1)"
"$BARRIER" "$RED" || true
