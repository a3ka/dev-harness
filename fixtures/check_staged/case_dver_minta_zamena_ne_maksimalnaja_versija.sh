# ПРИЧИНА: ОТКАЗ: дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «не максимальная версия» (§Инварианты п.1): новый
# sha замены годится ТОЛЬКО как tag-object frozen/contracts/<NNN>/<vmax>, где vmax —
# наибольшая живая версия этого NNN. Два toy, в обоих живы frozen/contracts/040/1 И /2.
# Зелёный (после фикса) — toy GREEN: строка 040 уже переписана на tag-object v1 (прошлая
# заморозка), замена v1 → tag-object v2: новая сторона — vmax, старая — v-1 (п.2 (б)).
# Стаб «старая сторона — только sha минта» здесь краснеет и различим именно на этом входе.
# Красный — toy RED: строка 040 — sha минта (валидна по п.2 (а)), замена на tag-object v1
# при живом v2 — отказ по новой стороне. Стаб «tag-object ЛЮБОЙ живой версии того же NNN»
# здесь зеленеет и различим именно на этом входе.
# На нечиненном коде зелёного нет (замена отвергается условием формы) — клетка красна
# «нет положительного контроля».
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (одинаков в клетках семьи) ───────────────────────────────────────
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
# Заморозка версии <v> контракта NNN, как freeze_contract.sh шаг 7: правка файла
# контракта, коммит, аннотированный frozen/contracts/NNN/<v>; тег и main — на origin.
freeze_ver() {  # <корень> <NNN> <v>
  local r="$1" n="$2" v="$3"
  printf '# контракт %s v%s\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА implementer: scripts/\n' \
    "$n" "$v" > "$r/contracts/$n-y.md"
  g "$r" add -A
  g "$r" commit -q -m "контракт $n v$v"
  g "$r" tag -a "frozen/contracts/$n/$v" -m "контракт $n v$v утверждён"
  g "$r" push -q origin main "refs/tags/frozen/contracts/$n/$v"
}
# Перепись строки NNN формой freeze_contract.sh шаги 8-9 (grep -v + дописать в конец).
perepis() {  # <корень> <NNN> <новый sha>
  local r="$1" n="$2" sha="$3" tmp
  tmp="$(mktemp "$WORK/reg.XXXXXX")"
  grep -v "^$n → " "$r/registry/contracts.tsv" > "$tmp" || true
  printf '%s → %s\n' "$n" "$sha" >> "$tmp"
  mv "$tmp" "$r/registry/contracts.tsv"
  g "$r" add registry/contracts.tsv
}
osnova() {  # <корень>
  local r="$1"
  make_repo_orchzone "$r"
  toy_origin "$r" >/dev/null
  set_author "$r" orchestrator
  g "$r" push -q origin "refs/tags/frozen/contracts/001/1"
  mint_rezerv "$r" 040
  mint_rezerv "$r" 041
  freeze_ver "$r" 040 1
}
tagobj() { git -C "$1" rev-parse "refs/tags/frozen/contracts/$2/$3"; }  # <корень> <NNN> <v>

# ── зелёный (после фикса): v1 → v2 при живых v1, v2 ───────────────────────────────
GREEN="$WORK/repo_green"
osnova "$GREEN"
perepis "$GREEN" 040 "$(tagobj "$GREEN" 040 1)"
g "$GREEN" commit -q -m 'freeze: registry 040 → v1 (прошлая заморозка)'
g "$GREEN" push -q origin main
freeze_ver "$GREEN" 040 2
perepis "$GREEN" 040 "$(tagobj "$GREEN" 040 2)"
"$BARRIER" "$GREEN" || true

# ── красный: минт → tag-object v1 при живом v2 ────────────────────────────────────
RED="$WORK/repo_red"
osnova "$RED"
freeze_ver "$RED" 040 2
perepis "$RED" 040 "$(tagobj "$RED" 040 1)"
"$BARRIER" "$RED" || true
