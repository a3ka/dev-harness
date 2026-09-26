# ПРИЧИНА: registry/contracts.tsv — дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «замена на произвольный sha», близнец в
# check_zones.sh: подготовка та же, что у case_dver_minta_zamena_na_frozen (живой
# frozen/contracts/040/1 есть), но коммит orchestrator заменяет строку 040 на
# СЛУЧАЙНЫЙ 40-hex — не tag-object никакого живого тега. Форма дельты та же (два хунка,
# add=1 del=1 на одном NNN), отличается ТОЛЬКО значение sha. Стаб «признавать любую
# замену 1+1 на том же NNN» здесь зеленеет.
# Зелёный контроль: история из честных минтов и заморозки — барьер зелёный ДО порчи.
# Красный: тот же toy + коммит замены 040 → случайный 40-hex — «коммит вне зоны»
# с причиной двери, как до контракта 049.
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (одинаков в трёх клетках семьи) ──────────────────────────────────
toy_origin() {  # <корень>
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main "refs/tags/frozen/contracts/001/1"
}
# Минт по церемонии: аннотированный id/CONTRACT/NNN на origin + строка «NNN → sha»
# коммитом orchestrator (честная только-добавляющая дельта — признание 031 её выводит).
mint_toy() {  # <корень> <NNN>
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача механизмом (фикстура)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$(git -C "$r" rev-parse "refs/tags/id/CONTRACT/$n")" >> "$r/registry/contracts.tsv"
  commit_as "$r" orchestrator "реестр: резерв $n"
  g "$r" push -q origin main
}
# Основа: контракт 001 зонирует orchestrator (иначе его коммиты «не судятся» и клетка
# не упражняет дверь), минты 040 и 041, заморозка 040 (файл + frozen-тег на origin;
# коммит основания — Фикстура, необъявленный автор).
osnova() {  # <корень>
  local r="$1"
  make_repo "$r" "$(printf 'ЗОНА implementer: scripts/\nЗОНА orchestrator: HANDOFF.md')"
  toy_origin "$r"
  mint_toy "$r" 040
  mint_toy "$r" 041
  add_contract "$r" 040 'ЗОНА implementer: scripts/'
  g "$r" push -q origin main "refs/tags/frozen/contracts/040/1"
}
# Перепись строки NNN формой freeze_contract.sh шаги 8-9 (grep -v + дописать в конец)
# коммитом orchestrator. Пустой <новый sha> — удаление строки без замены.
perepis() {  # <корень> <NNN> <новый sha | пусто>
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  [ -z "$sha" ] || printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  commit_as "$r" orchestrator "freeze: registry $n → ${sha:-<удалено>}"
}

R="$WORK/repo"
osnova "$R"

# ── зелёный контроль: честные минты и заморозка ──────────────────────────────────
"$BARRIER" "$R" || true

# ── красный: коммит замены 040 на случайный 40-hex ──────────────────────────────
sluchajnyj="$(od -An -N20 -tx1 /dev/urandom | tr -d ' \n')"
perepis "$R" 040 "$sluchajnyj"
"$BARRIER" "$R" || true
