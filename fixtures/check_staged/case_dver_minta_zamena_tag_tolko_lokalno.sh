# ПРИЧИНА: ОТКАЗ: дверь минта 031:
#
# Контракт 049 (корень Н-153), клетка «frozen-тег только локально» (§Инварианты п.3,
# §Риски 1, решение владельца (а)): провенанс формы замены в check_staged.sh — ТОЛЬКО
# локальный, `ls-remote origin` форма замены не зовёт. Вход повторяет живой порядок
# freeze_contract.sh: тег `git tag -a` (шаг 7) и сразу самокоммит реестра (шаги 8-9),
# пуша тега между ними НЕТ.
# Зелёный (после фикса): минт 040 честный (строка и id-тег на origin), контракт 040 на
# origin/main, затем frozen/contracts/040/1 создан ЛОКАЛЬНО и НЕ запушен; 040 → его
# tag-object. Дверь, спрашивающая origin о frozen-теге (мутант «origin-проверка как у
# id/CONTRACT сохранена»), здесь отказывает → rc 1 → «нет положительного контроля».
# Прочие клетки семьи пушат frozen-тег и этот мутант не различают.
# Красный: тот же тег удалён локально (на origin его не было), строка та же — tag-object
# остался в базе объектов, но живого тега нет, отказ. Стаб «провенанс по объекту в базе
# (cat-file -t/-p), без живости ссылки (show-ref --verify)» здесь зеленеет.
# На нечиненном коде зелёного нет (замена отвергается условием формы) — клетка красна
# «нет положительного контроля»: красное предъявление контракта 049.
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

# ── каркас 049 (как в прочих клетках семьи; freeze_toy не берётся — он пушит тег) ──
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
contract_file "$R" 040
g "$R" add -A
g "$R" commit -q -m 'контракт 040'
g "$R" push -q origin main
# freeze_contract.sh шаг 7: тег ТОЛЬКО локально — на origin его нет.
g "$R" tag -a frozen/contracts/040/1 -m 'контракт 040 утверждён'
if [ -n "$(git -C "$R" ls-remote origin 'refs/tags/frozen/contracts/040/*')" ]; then
  printf 'каркас: frozen/contracts/040/1 оказался на origin — вход не построен\n' >&2
  exit 3
fi

# ── зелёный (после фикса): замена на tag-object НЕзапушенного frozen-тега ─────────
perepis "$R" 040 "$(git -C "$R" rev-parse "refs/tags/frozen/contracts/040/1")"
"$BARRIER" "$R" || true

# ── красный: тег удалён локально (на origin его нет), объект в базе, строка та же ──
g "$R" tag -d frozen/contracts/040/1 >/dev/null
"$BARRIER" "$R" || true
