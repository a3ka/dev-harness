# ПРИЧИНА: реестр зон
#
# Контракт 031, ветвь ii, условие 5, ветвь Б4 (читатель зон ослеплён / отказал):
# zones_load rc ≠ 0 → «реестр зон недоступен»; zones_load rc 0, но в реестре
# НЕТ НИ ОДНОЙ зоны с префиксом `verdicts/` → «реестр зон не несёт ни одной
# судейской зоны — читатель ослеплён». Два сценария — два разных имени
# причины; общий префикс «реестр зон» (имя ОБЪЕДИНЯЕТ оба). Стаб запасного
# пути (префикс/кэш при rc≠0) умирает на «реестр зон недоступен» (НЕ на
# ослеплённом — стаб, честно отказывающий на пустом, проходит р0-р9).
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

# ── в9 красный: ослеплённый читатель (zones_load rc 0, но пустой zones_scoped) ──
# Реализуется через chmod 000 на .git/refs/tags: zones_load (через
# for-each-ref refs/tags/frozen/...) не находит ничего, но rc 0 (это поведение
# измерено пробой круга 2 фикстуры red_peresnjatie_bazlajna.sh).
BLIND="$WORK/v9"
mk_sud_root "$BLIND"
"$BARRIER" --snapshot "$BLIND" >/dev/null 2>&1 || true
commit_kak "$BLIND" reviewer "verdicts/review/contracts-001-k9.md" 'accept — честный вердикт'
chmod 000 "$BLIND/.git/refs/tags"
"$BARRIER" --retake   "$BLIND" || true   # rc 1 «реестр зон не несёт ни одной судейской зоны — читатель ослеплён»
chmod 755 "$BLIND/.git/refs/tags"

# ── в10 красный: отказ читателя (zones_load rc ≠ 0) ──────────────────────────
# frozen-тег запушен на origin, удалён локально → registry_state даёт состояние
# НЕ full/unknown-remote (вероятно missing-remote), zones_load выходит с
# rc 2 → «реестр зон недоступен». Стаб запасного пути (префикс/кэш при
# ненулевом zones_load) умирает ЗДЕСЬ.
RC2="$WORK/v10"
mk_sud_root "$RC2"
# Создаём bare-origin и пушим main + frozen-тег туда.
RC2_ORIG="$RC2-origin.git"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$RC2_ORIG"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RC2" remote add origin "$RC2_ORIG"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RC2" push -q origin main
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RC2" push -q origin refs/tags/frozen/contracts/001/1
"$BARRIER" --snapshot "$RC2" >/dev/null 2>&1 || true
commit_kak "$RC2" reviewer "verdicts/review/contracts-001-k10.md" 'accept — честный вердикт'
# Удаляем локальный frozen-тег → registry_state не full → zones_load rc 2.
gtoy "$RC2" tag -d frozen/contracts/001/1 >/dev/null
"$BARRIER" --retake   "$RC2" || true   # rc 1 «реестр зон недоступен»