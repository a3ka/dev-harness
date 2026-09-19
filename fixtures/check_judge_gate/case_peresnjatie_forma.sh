# ПРИЧИНА: переснятие не доказано
#
# Контракт 031, ветвь ii, условия 3-4 (дельта непуста / ровно один путь):
# пустая дельта и дельта из ДВУХ путей. Зелёный — snapshot/check 024 живы.
# Красный — пустая дельта (snapshot без коммита, --retake отказывает) и
# дельта из двух путей (--retake отказывает «не ровно-один-файл»). Имена
# причин различны: «дельта пуста — нечего переснимать» vs «дельта не
# ровно-один-файл»; префикс «переснятие не доказано» общий.
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

# ── зелёный: snapshot/check на чистом дереве ─────────────────────────────────
GREEN="$WORK/v0"
mk_sud_root "$GREEN"
"$BARRIER" --snapshot "$GREEN" >/dev/null 2>&1 || true
"$BARRIER" --check    "$GREEN" || true   # rc 0

# ── в6 красный: пустая дельта (snapshot без коммита) ──────────────────────────
EMPTY="$WORK/v6"
mk_sud_root "$EMPTY"
"$BARRIER" --snapshot "$EMPTY" >/dev/null 2>&1 || true
"$BARRIER" --retake   "$EMPTY" || true   # rc 1 «дельта пуста»

# ── в2 красный: дельта из ДВУХ путей (вердикт + закоммиченный мусор) ───────────
TWO="$WORK/v2"
mk_sud_root "$TWO"
"$BARRIER" --snapshot "$TWO" >/dev/null 2>&1 || true
commit_kak "$TWO" reviewer "verdicts/review/contracts-001-k2.md" 'accept'
commit_kak "$TWO" reviewer "scripts/musor-${RANDOM}.sh" 'утечка-кандидат'
"$BARRIER" --retake   "$TWO" || true   # rc 1 «не ровно-один-файл»