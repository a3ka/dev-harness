# ПРИЧИНА: коммит вне зоны
#
# Контракт 021, ветвь В — мера параллельности §10 (усиление 1 владельца).
# Анти-плацебо адресовано ПРЕДМЕТУ меры — scripts/measure_parallel_windows.sh:
# ниже «ворота» — прямые вызовы меры с договорёнными исходами на трёх toy-парах
# окон. Ворота стоят ДО протокола раннера (зелёный контроль + красное
# предъявление check_zones): слабая реализация меры умирает до первого rc 0, и
# scoped-прогон красен поимённо («не вызвала барьер через $BARRIER» / «нет
# положительного контроля»). Файл лежит в семействе check_zones, потому что
# fixtures/check_zones/ — активная зона architect на момент пачки; канал
# размещения не меняет предмет проверки.
#
# Договор меры (ветвь В контракта 021): вход <корень> <A> <B>; окна перекрылись
# ⟺ frozen/contracts/A/1 раньше done/contracts/B/1 И frozen/contracts/B/1 раньше
# done/contracts/A/1 по времени коммиттера коммита тега; rc 0 — перекрытие
# доказано; rc 1 — «не параллельно» с именами и временами ЛИБО недостающий тег
# с именем тега. Времена в toy пинуются GIT_COMMITTER_DATE — порядок не зависит
# от скорости машины.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"

MER="$REPO/scripts/measure_parallel_windows.sh"
[ -f "$MER" ] || {
  printf 'ОТКАЗ: меры нет — scripts/measure_parallel_windows.sh (реализация за implementer после заморозки 021)\n' >&2
  exit 1
}

# Лёгкий тег на пустом коммите с ПИНОВАННЫМ временем коммиттера: мера читает
# время коммита тега, история toy не зависит от часов.
mk_window_repo() {  # <каталог>
  mkdir -p "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$1"
}
tag_at() {  # <каталог> <время> <тег>
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  GIT_COMMITTER_DATE="$2" GIT_AUTHOR_DATE="$2" \
  git -C "$1" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit -q --allow-empty -m "окно $3"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$1" -c user.name=Фикстура -c user.email=fixture@local tag "$3"
}

# ── ворота 1: перекрывшаяся пара → rc 0 ────────────────────────────────────────
P="$WORK/toyp_perekrytie"
mk_window_repo "$P"
tag_at "$P" '2026-01-01T00:00:01 +0000' frozen/contracts/001/1
tag_at "$P" '2026-01-01T00:00:02 +0000' frozen/contracts/002/1
tag_at "$P" '2026-01-01T00:00:03 +0000' done/contracts/001/1
tag_at "$P" '2026-01-01T00:00:04 +0000' done/contracts/002/1
out="$("$MER" "$P" 001 002 2>&1)" && rc=0 || rc=$?
[ "$rc" -eq 0 ] || {
  printf 'ОТКАЗ: перекрывшаяся пара окон не признана параллельной: rc=%s\n%s\n' "$rc" "$out" >&2
  exit 1
}

# ── ворота 2: последовательная пара → rc 1 «не параллельно» ───────────────────
S="$WORK/toys_posledovatelnoe"
mk_window_repo "$S"
tag_at "$S" '2026-02-01T00:00:01 +0000' frozen/contracts/001/1
tag_at "$S" '2026-02-01T00:00:02 +0000' done/contracts/001/1
tag_at "$S" '2026-02-01T00:00:03 +0000' frozen/contracts/002/1
tag_at "$S" '2026-02-01T00:00:04 +0000' done/contracts/002/1
out="$("$MER" "$S" 001 002 2>&1)" && rc=0 || rc=$?
[ "$rc" -eq 1 ] || {
  printf 'ОТКАЗ: последовательная пара принята за параллельную: rc=%s\n%s\n' "$rc" "$out" >&2
  exit 1
}
if ! printf '%s\n' "$out" | grep -qF 'не параллельно'; then
  printf 'ОТКАЗ: последовательная пара красна, но причина «не параллельно» не названа:\n%s\n' "$out" >&2
  exit 1
fi

# ── ворота 3: недостающий done-тег → rc 1 с именем тега ──────────────────────
X="$WORK/toyx_net_tega"
mk_window_repo "$X"
tag_at "$X" '2026-03-01T00:00:01 +0000' frozen/contracts/001/1
tag_at "$X" '2026-03-01T00:00:02 +0000' frozen/contracts/002/1
tag_at "$X" '2026-03-01T00:00:03 +0000' done/contracts/001/1
out="$("$MER" "$X" 001 002 2>&1)" && rc=0 || rc=$?
[ "$rc" -eq 1 ] || {
  printf 'ОТКАЗ: недостающий тег дал rc=%s (пустая выборка обязана быть красной):\n%s\n' "$rc" "$out" >&2
  exit 1
}
if ! printf '%s\n' "$out" | grep -qF 'done/contracts/002/1'; then
  printf 'ОТКАЗ: недостающий тег не назван по имени done/contracts/002/1:\n%s\n' "$out" >&2
  exit 1
fi

# ── протокол раннера: зелёный контроль и красное предъявление check_zones ─────
G="$WORK/toy_green"
make_repo "$G" 'ЗОНА agent-x: scripts/'
printf 'правка в зоне\n' >> "$G/scripts/a.sh"
commit_as "$G" agent-x 'в зоне'
"$BARRIER" "$G"

K="$WORK/toy_krasnoe"
make_repo "$K" 'ЗОНА agent-x: scripts/'
printf 'правка вне зоны\n' > "$K/plans/vne.md"
commit_as "$K" agent-x 'вне зоны'
"$BARRIER" "$K"
