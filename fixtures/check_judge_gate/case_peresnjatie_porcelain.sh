# ПРИЧИНА: переснятие не доказано
#
# Контракт 031, ветвь ii, условие 2 (закоммиченность БАЙТАМИ): porcelain чист ∧
# байты рабочего файла == байты `git cat-file HEAD:<path>` (мимо assume-unchanged/
# skip-worktree). Зелёный — snapshot/check 024 живы. Красный — porcelain грязный
# (staged-правка БЕЗ коммита) И байты не закоммичены под assume-unchanged (Б3,
# porcelain лжёт «чисто», но cat-file HEAD показывает другие байты). Два отказа
# разных причин, один общий префикс «переснятие не доказано».
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

# ── в5 красный: porcelain грязный (staged-правка поверх закоммиченной вердиктной) ─
DIRTY="$WORK/v5"
mk_sud_root "$DIRTY"
"$BARRIER" --snapshot "$DIRTY" >/dev/null 2>&1 || true
commit_kak "$DIRTY" reviewer "verdicts/review/contracts-001-k3.md" 'accept'
printf '\nнезакоммиченная правка\n' >> "$DIRTY/HANDOFF.md"
gtoy "$DIRTY" add -A   # porcelain теперь грязный (staged HANDOFF.md)
"$BARRIER" --retake   "$DIRTY" || true   # rc 1 «porcelain не чист»

# ── в8 красный: незакоммиченные байты под assume-unchanged (Б3) ───────────────
AUNCH="$WORK/v8"
mk_sud_root "$AUNCH"
"$BARRIER" --snapshot "$AUNCH" >/dev/null 2>&1 || true
commit_kak "$AUNCH" reviewer "verdicts/review/contracts-001-k8.md" 'accept — честный вердикт'
# Меняем байты файла БЕЗ коммита, прячем от porcelain через assume-unchanged.
printf 'ПОДМЕНА: незакоммиченные байты\n' > "$AUNCH/verdicts/review/contracts-001-k8.md"
gtoy "$AUNCH" update-index --assume-unchanged "verdicts/review/contracts-001-k8.md"
# Контроль воспроизведения: porcelain должен лгать «чисто» — иначе это не вход Б3.
gtoy "$AUNCH" status --porcelain | grep -q . && { echo "Б3 НЕ воспроизведён: porcelain видит правку"; exit 1; }
"$BARRIER" --retake   "$AUNCH" || true   # rc 1 «байты не закоммичены»
gtoy "$AUNCH" update-index --no-assume-unchanged "verdicts/review/contracts-001-k8.md" 2>/dev/null || true