# ПРИЧИНА: переснятие не доказано
#
# Контракт 031, ветвь ii (--retake): легитимное переснятие — вердиктная дельта
# судьи (один файл verdicts/review/, автор — владелец зоны reviewer), porcelain
# чист, тег закоммичен → rc 0 + «базлайн переснят: вердиктная дельта …» + --check
# rc 0 «основной чекаут чист». Зелёный контроль — snapshot/--check 024 живы
# (rc 0 «основной чекаут чист»). Красный — невердиктный путь (scripts/inzhenernoe-*);
# «переснятие не доказано: путь не вердиктный (зона судьи не объявлена)». Контракт
# 031 §Инварианты-2: «именованной причиной, СНИМОК НЕ ТРОНУТ» — деталь проверяется
# тем же набором в зоне, что и сама дверь (zones_load rc-контракт не меняется).
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

gtoy() {  # герметичный git (прецедент red_peresnjatie_bazlajna.sh)
  local d="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$d" -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
mk_sud_root() {  # toy с frozen-контрактом 001, зонирующим reviewer: verdicts/review/
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
commit_kak() {  # коммит АВТОРОМ из аргумента (модель main-direct вердикта)
  local r="$1" avtor="$2" p="$3" content="$4"
  mkdir -p "$r/$(dirname "$p")"
  printf '%s\n' "$content" > "$r/$p"
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" add -A
  gtoy "$r" -c user.name="$avtor" -c user.email="$avtor@local" commit -q -m "посадка $p ($avtor)"
}

# ── зелёный: snapshot + check на чистом дереве ──────────────────────────────
GREEN="$WORK/v0"
mk_sud_root "$GREEN"
"$BARRIER" --snapshot "$GREEN" >/dev/null 2>&1 || true
"$BARRIER" --check    "$GREEN" || true   # rc 0 «основной чекаут чист»

# ── в1 зелёный+: вердиктная дельта + --retake (rc 0 + стенограмма) + --check (rc 0) ──
LEGIT="$WORK/v1"
mk_sud_root "$LEGIT"
"$BARRIER" --snapshot "$LEGIT" >/dev/null 2>&1 || true
commit_kak "$LEGIT" reviewer "verdicts/review/contracts-001-k1.md" 'accept — вердикт k1'
"$BARRIER" --check    "$LEGIT" || true   # rc 1 (детектор прав)
"$BARRIER" --retake   "$LEGIT" || true   # rc 0 + стенограмма
"$BARRIER" --check    "$LEGIT" || true   # rc 0 «основной чекаут чист»

# ── в3 красный: невердиктный путь (scripts/inzhenernoe-*) ─────────────────────
RED="$WORK/v3"
mk_sud_root "$RED"
"$BARRIER" --snapshot "$RED" >/dev/null 2>&1 || true
commit_kak "$RED" reviewer "scripts/inzhenernoe-${RANDOM}.md" 'инженерный файл'
"$BARRIER" --retake   "$RED" || true