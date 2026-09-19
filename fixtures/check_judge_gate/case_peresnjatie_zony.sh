# ПРИЧИНА: переснятие не доказано
#
# Контракт 031, ветвь ii, условия 5-6: путь вердиктный + автор — судья зоны.
# Конкретно здесь — путь вне verdicts/* (scripts/inzhenernoe-*) и вердикт
# внутри verdicts/konsul/ (подкаталог без ЗОНА-строки; зона объявлена только
# на verdicts/review/). Зелёный — snapshot/check 024 живы. Красный — оба
# сценария отказывают «переснятие не доказано: путь не вердиктный (зона
# судьи не объявлена)»: разные причины, один класс (зонная неполнота).
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

gtoy() {
  local d="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$d" -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
mk_sud_root() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/review" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА reviewer: verdicts/review/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'база\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local add -A
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
  gtoy "$r" -c user.name=Фикстура -c user.email=fixture@local tag -a frozen/contracts/001/1 -m 'утверждён'
}
commit_kak() {
  local r="$1" avtor="$2" p="$3" content="$4"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$content" > "$r/$p"
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" add -A
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" commit -q -m "посадка $p ($avtor)"
}

# ── зелёный: snapshot/check 024 ────────────────────────────────────────────────
GREEN="$WORK/v0"
mk_sud_root "$GREEN"
"$BARRIER" --snapshot "$GREEN" >/dev/null 2>&1 || true
"$BARRIER" --check    "$GREEN" || true   # rc 0

# ── в3 красный: единственный путь ВНЕ verdicts/ ──────────────────────────────
OFFZONE="$WORK/v3"
mk_sud_root "$OFFZONE"
"$BARRIER" --snapshot "$OFFZONE" >/dev/null 2>&1 || true
commit_kak "$OFFZONE" reviewer "scripts/inzhenernoe-${RANDOM}.md" 'инженерный файл'
"$BARRIER" --retake   "$OFFZONE" || true

# ── в4 красный: вердиктный путь, автор — НЕ судья зоны (orchestrator) ───────
WRONG_AUTH="$WORK/v4"
mk_sud_root "$WRONG_AUTH"
"$BARRIER" --snapshot "$WRONG_AUTH" >/dev/null 2>&1 || true
commit_kak "$WRONG_AUTH" orchestrator "verdicts/review/contracts-001-orch.md" 'подделка канала'
"$BARRIER" --retake   "$WRONG_AUTH" || true

# ── в7 красный: verdicts/подкаталог без ЗОНА-строки ──────────────────────────
SUBDIR="$WORK/v7"
mk_sud_root "$SUBDIR"
"$BARRIER" --snapshot "$SUBDIR" >/dev/null 2>&1 || true
commit_kak "$SUBDIR" reviewer "verdicts/konsul/svidetelstvo-${RANDOM}.md" 'свидетельство вне зоны'
"$BARRIER" --retake   "$SUBDIR" || true