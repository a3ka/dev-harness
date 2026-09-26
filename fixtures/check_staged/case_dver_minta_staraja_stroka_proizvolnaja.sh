# ПРИЧИНА: ОТКАЗ: дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «старая строка произвольная» (§Инварианты п.2):
# вычёркиваемая строка NNN обязана быть sha минта id/CONTRACT/<NNN> либо tag-object
# frozen/contracts/<NNN>/<vmax-1>. Иначе замена — отказ, даже при валидной новой стороне:
# без этого строку можно сперва испортить любым sha, затем «заменить» на легитимный.
# Зелёный (после фикса): строка 040 — sha минта, замена на tag-object frozen/contracts/040/1.
# Красный: строка 040 заранее испорчена (закоммичена мимо двери — хуки toy выключены) на
# tag-object ЖИВОГО frozen-тега ЧУЖОГО номера frozen/contracts/001/1; новая сторона та же,
# валидная. Стаб «старая сторона не сверяется» и стаб «старая — tag-object любого живого
# тега» здесь зеленеют и различимы именно на этом входе.
# На нечиненном коде зелёного нет — клетка красна «нет положительного контроля».
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (одинаков в клетках семьи) ───────────────────────────────────────
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
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  set_author "$r" orchestrator
  g "$r" add -A
  g "$r" commit -q -m 'основание'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}
contract_file() {  # <корень> <NNN>
  printf '# контракт %s\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА implementer: scripts/\n' \
    "$2" > "$1/contracts/$2-y.md"
}
freeze_toy() {  # <корень> <NNN>
  local r="$1" n="$2"
  contract_file "$r" "$n"
  g "$r" add -A
  g "$r" commit -q -m "контракт $n"
  g "$r" tag -a "frozen/contracts/$n/1" -m "контракт $n утверждён"
  g "$r" push -q origin main "refs/tags/frozen/contracts/$n/1"
}
perepis() {  # <корень> <NNN> <новый sha>
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  g "$r" add registry/contracts.tsv
}

R="$WORK/repo"
make_repo_orchzone "$R"
toy_origin "$R" >/dev/null
set_author "$R" orchestrator
g "$R" push -q origin "refs/tags/frozen/contracts/001/1"
mint_rezerv "$R" 040
mint_rezerv "$R" 041
freeze_toy "$R" 040
NEW="$(git -C "$R" rev-parse "refs/tags/frozen/contracts/040/1")"

# ── зелёный (после фикса): минт → tag-object frozen/contracts/040/1 ────────────────
perepis "$R" 040 "$NEW"
"$BARRIER" "$R" || true

# ── красный: испорченная старая строка → тот же валидный tag-object ─────────────────
g "$R" checkout -q HEAD -- registry/contracts.tsv
perepis "$R" 040 "$(git -C "$R" rev-parse "refs/tags/frozen/contracts/001/1")"
g "$R" commit -q -m 'порча строки 040 мимо двери'
g "$R" push -q origin main
perepis "$R" 040 "$NEW"
"$BARRIER" "$R" || true
