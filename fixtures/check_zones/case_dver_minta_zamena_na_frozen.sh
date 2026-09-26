# ПРИЧИНА: registry/contracts.tsv — дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «замена на frozen», близнец в check_zones.sh
# (минт-признание 031 ветвь ii, пост-хок суд истории): коммит orchestrator, заменяющий
# строку NNN манифеста на tag-object живого аннотированного frozen/contracts/NNN/<v>,
# признаётся и выводится из суда зон этого пути.
# Каркас повторяет живого производителя замены — freeze_contract.sh шаги 8-9 (строка
# вычёркивается и дописывается В КОНЕЦ; 041 стоит после 040 — два хунка, add=1 del=1).
# Зелёный (после фикса) — toy GREEN: 040 → tag-object frozen/contracts/040/1.
# Красный — toy RED, та же подготовка: 040 → tag-object ЧУЖОГО живого frozen-тега
# frozen/contracts/001/1. Признаётся только frozen-тег ТОГО ЖЕ номера; стаб «sha любого
# живого frozen-тега» здесь зеленеет и различим именно на этом входе.
# Два toy, а не один: суд — по истории, красный коммит в истории GREEN не отменить.
# На нечиненном коде зелёного нет — клетка красна «нет положительного контроля».
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

# ── зелёный (после фикса): замена на tag-object frozen-тега того же номера ────────
GREEN="$WORK/repo_green"
osnova "$GREEN"
perepis "$GREEN" 040 "$(git -C "$GREEN" rev-parse "refs/tags/frozen/contracts/040/1")"
"$BARRIER" "$GREEN" || true

# ── красный: замена на tag-object живого frozen-тега ЧУЖОГО номера ────────────────
RED="$WORK/repo_red"
osnova "$RED"
perepis "$RED" 040 "$(git -C "$RED" rev-parse "refs/tags/frozen/contracts/001/1")"
"$BARRIER" "$RED" || true
