# ПРИЧИНА: ОТКАЗ: дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «удаление строки»: подготовка та же, что у
# case_dver_minta_zamena_na_frozen (живой frozen/contracts/040/1 есть), но строка 040
# ВЫЧЁРКИВАЕТСЯ без замены: add=0 del=1. Стаб «del_count ≤ 1 без требования ровно
# одной +строки того же NNN» здесь зеленеет.
# Зелёный контроль: честный минт 040 (тег жив локально и на origin, строка staged) —
# дверь пропускает ДО порчи, то есть каркас не вечно-красный.
# Красный: удаление строки 040 — отказ двери, как до контракта 049.
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (одинаков в трёх клетках семьи) ──────────────────────────────────
# Основа: как make_repo из _repo.sh, но замороженный контракт 001 зонирует и
# orchestrator — иначе его staged-путь «не судится» раньше двери и клетка не
# упражняет предмет (прецедент case_dver_minta_legitimnyj.sh).
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
# Файл контракта с объявлением: без него барьер краснеет на «зон нет» раньше двери.
contract_file() {  # <корень> <NNN>
  printf '# контракт %s\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА implementer: scripts/\n' \
    "$2" > "$1/contracts/$2-y.md"
}
# Заморозка NNN, как freeze_contract.sh шаг 7: аннотированный frozen/contracts/NNN/1
# на коммите с файлом контракта; тег и main — на origin.
freeze_toy() {  # <корень> <NNN>
  local r="$1" n="$2"
  contract_file "$r" "$n"
  g "$r" add -A
  g "$r" commit -q -m "контракт $n"
  g "$r" tag -a "frozen/contracts/$n/1" -m "контракт $n утверждён"
  g "$r" push -q origin main "refs/tags/frozen/contracts/$n/1"
}
# Перепись строки NNN формой freeze_contract.sh шаги 8-9 (grep -v + дописать в конец).
# Пустой <новый sha> — удаление строки без замены.
perepis() {  # <корень> <NNN> <новый sha | пусто>
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  [ -z "$sha" ] || printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  g "$r" add registry/contracts.tsv
}

R="$WORK/repo"
make_repo_orchzone "$R"
toy_origin "$R" >/dev/null
set_author "$R" orchestrator
g "$R" push -q origin "refs/tags/frozen/contracts/001/1"

# ── зелёный контроль: честный минт 040 staged ────────────────────────────────────
g "$R" tag -a id/CONTRACT/040 -m 'выдача механизмом (фикстура)'
push_id_tag "$R" 040
mkdir -p "$R/registry"
printf '040 → %s\n' "$(git -C "$R" rev-parse refs/tags/id/CONTRACT/040)" >> "$R/registry/contracts.tsv"
g "$R" add registry/contracts.tsv
"$BARRIER" "$R" || true

# ── та же подготовка, что у клетки «замена на frozen» ───────────────────────────
g "$R" commit -q -m 'реестр: резерв 040 (строка манифеста)'
g "$R" push -q origin main
mint_rezerv "$R" 041
freeze_toy "$R" 040

# ── красный: строка 040 вычёркнута без замены ────────────────────────────────────
perepis "$R" 040 ""
"$BARRIER" "$R" || true
