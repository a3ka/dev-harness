# ПРИЧИНА: registry/contracts.tsv — дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «старая строка произвольная», близнец в
# check_zones.sh (минт-признание 031 ветвь ii). §Инварианты п.2: вычёркиваемая строка NNN
# обязана быть sha минта id/CONTRACT/<NNN> либо tag-object frozen/contracts/<NNN>/<vmax-1>.
# Зелёный (после фикса) — toy GREEN: минт → tag-object frozen/contracts/040/1.
# Красный — toy RED: строка 040 сперва испорчена коммитом Фикстура (необъявленный автор,
# не судится — порча прошла мимо суда) на tag-object ЖИВОГО frozen-тега ЧУЖОГО номера
# frozen/contracts/001/1; затем orchestrator «заменяет» её на валидный tag-object
# frozen/contracts/040/1. Отказ по старой стороне. Стаб «старая сторона не сверяется» и
# стаб «старая — tag-object любого живого тега» здесь зеленеют и различимы на этом входе.
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
# Перепись строки NNN формой freeze_contract.sh шаги 8-9 (grep -v + дописать в конец)
# коммитом <автор>.
perepis() {  # <корень> <NNN> <новый sha> <автор>
  local r="$1" n="$2" sha="$3" who="$4" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  commit_as "$r" "$who" "freeze: registry $n → $sha"
}

# ── зелёный (после фикса): минт → tag-object frozen/contracts/040/1 ────────────────
GREEN="$WORK/repo_green"
osnova "$GREEN"
perepis "$GREEN" 040 "$(git -C "$GREEN" rev-parse "refs/tags/frozen/contracts/040/1")" orchestrator
"$BARRIER" "$GREEN" || true

# ── красный: порча старой строки (Фикстура), затем замена на валидный tag-object ─────
RED="$WORK/repo_red"
osnova "$RED"
perepis "$RED" 040 "$(git -C "$RED" rev-parse "refs/tags/frozen/contracts/001/1")" Фикстура
perepis "$RED" 040 "$(git -C "$RED" rev-parse "refs/tags/frozen/contracts/040/1")" orchestrator
"$BARRIER" "$RED" || true
