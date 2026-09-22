#!/usr/bin/env bash
# Красное 040 (Н-126, вариант A2) — СТРУКТУРНЫЙ (без wall-clock) предел числа
# git-подпроцессов, порождаемых check_zones.sh на toy-дереве с K перекрывающихся
# окон поверх M общих фоновых коммитов.
#
# Конструкция (frontier agent://Arch126Frontier, variant_a_odnoprohodnyj, п.1-6):
#  1. K контрактов, у каждого СВОЙ автор agentNN и НЕПЕРЕСЕКАЮЩАЯСЯ зона
#     zones/agentNN/; ВСЕ K заморожены РАНО (до фоновых коммитов) — их окна
#     frozen_NNN..HEAD ВСЕ покрывают одни и те же M фоновых коммитов, то есть
#     Σ(размер окна) = K×M на M физически различных коммитах.
#  2. M фоновых коммитов --allow-empty от НЕОБЪЯВЛЕННОГО автора «Фон»: каждый
#     входит в судимое множество (не merge), но не матчит ни одного заявленного
#     автора — check_zones безусловно печатает `git log -1 --format=%an` на
#     КАЖДЫЙ (:333), затем `continue` (без diff-tree). Линейный по M вызов на
#     каждое ИЗ K окон — Θ(K×M) подпроцессов на этом одном узком месте.
#  3. git-шпион (приём fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh:
#     `exec РЕАЛЬНЫЙ_git "$@"`) считает КАЖДЫЙ git-подпроцесс, порождённый ЛЮБЫМ
#     местом check_zones.sh/lib_zones.sh/lib_registry.sh за весь прогон.
#  4. Граница a·(K+M)+b — ЛИНЕЙНАЯ по (K+M), а не по K×M: честная batched-
#     реализация тратит O(1) git-вызовов НА ОКНО (авторы одним `--stdin`-вызовом,
#     diff-tree — тоже одним), то есть Θ(K), не Θ(K×M). a=6 выбрана заведомо
#     щедрой (батчинг реалистично укладывается в 4-6 вызовов/окно: 2 rev-list +
#     1 batched-log + 1 batched-diff-tree, редкие ветви draft/минт/СПАСЕНО не
#     линейны по M); при K > a разделение растёт вместе с M и не подогнано под
#     сегодняшнее число (проверено живым прогоном на этом файле: 916 > 452).
#  5. Гарантия от «быстрой, но неправильной» заглушки (Н-39): ОДИН коммит —
#     agent03 пишет в zones/agent07/ (чужая зона) — check_zones ОБЯЗАН дать rc=1
#     с «коммит вне зоны» И на сегодняшней (медленной) версии, И на будущей
#     (быстрой): тест ловит производительность, а не потерю проверки.
#  6. Регресс-гарантия (не-ослабление) — ОТДЕЛЬНО от этого файла: все
#     существующие fixtures/check_zones/*.sh (33 файла минус 2 хелпера
#     _repo.sh/_schet_fixtur.sh) обязаны остаться зелёными БЕЗ правки их текста
#     — предъявляется отдельной командой (см. контракт §Приёмка).
#
# Коды возврата: 0 — вызовов ≤ границы И нарушение поймано; 1 — граница
#                превышена ЛИБО нарушение не поймано (сегодня: превышена).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CZ="$REPO/scripts/check_zones.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red040-predel.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
[ -f "$CZ" ] || { printf 'NOT_IMPLEMENTED: субъект не найден: %s\n' "$CZ" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

# ── git-шпион: PATH-шим, инкремент счётчика ДО передачи управления git ────────
GITREAL="$(command -v git)"
SPY="$WORK/spy"; mkdir -p "$SPY"
COUNTFILE="$WORK/git_calls.count"
: > "$COUNTFILE"
cat > "$SPY/git" <<EOF
#!/bin/sh
printf 'x' >> "$COUNTFILE"
exec "$GITREAL" "\$@"
EOF
chmod 755 "$SPY/git"

# ── toy-дерево: K контрактов / M фоновых коммитов / 1 нарушение ───────────────
R="$WORK/repo"
K=12
M=60
mkdir -p "$R"
g() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"

mkdir -p "$R/contracts" "$R/verdicts/critic"
{
  printf '# контракт 001\n\n## Предмет\nподставной предмет KxM\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
  printf 'ЗОНА agent01: zones/agent01/\n'
} > "$R/contracts/001-x.md"
printf 'accept\nвердикт критика\n' > "$R/verdicts/critic/contracts-001-v1.md"
mkdir -p "$R/zones/agent01"
printf 'исходный\n' > "$R/zones/agent01/seed.md"
g -c user.name=Фикстура -c user.email=fixture@local add -A
g -c user.name=Фикстура -c user.email=fixture@local commit -q -m 'основание'
g -c user.name=Фикстура -c user.email=fixture@local tag -a frozen/contracts/001/1 -m 'контракт 001 утверждён'

i=2
while [ "$i" -le "$K" ]; do
  nnn=$(printf '%03d' "$i")
  an=$(printf 'agent%02d' "$i")
  printf '# контракт %s\n\n## Предмет\nподставной предмет KxM\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\nЗОНА %s: zones/%s/\n' \
    "$nnn" "$an" "$an" > "$R/contracts/$nnn-y.md"
  mkdir -p "$R/zones/$an"
  printf 'исходный\n' > "$R/zones/$an/seed.md"
  g -c user.name=Фикстура -c user.email=fixture@local add -A
  g -c user.name=Фикстура -c user.email=fixture@local commit -q -m "основание: контракт $nnn"
  g -c user.name=Фикстура -c user.email=fixture@local tag -a "frozen/contracts/$nnn/1" -m "контракт $nnn утверждён"
  i=$((i + 1))
done

j=1
while [ "$j" -le "$M" ]; do
  g -c user.name=Фон -c user.email=fon@local commit -q --allow-empty -m "фон $j"
  j=$((j + 1))
done

# Нарушение (гарантия Н-39, п.5): agent03 коммитит в ЧУЖУЮ зону (agent07) —
# ОБЯЗАН остаться пойман И сегодня, И после батчинга.
mkdir -p "$R/zones/agent07"
printf 'вторжение\n' > "$R/zones/agent07/x.md"
g -c user.name=agent03 -c user.email=agent03@local add -A
g -c user.name=agent03 -c user.email=agent03@local commit -q -m 'agent03 пишет в чужую зону'

# ── прогон check_zones.sh через git-шпиона ─────────────────────────────────────
out="$(PATH="$SPY:$PATH" bash "$CZ" "$R" 2>&1)"; rc=$?
calls="$(wc -c < "$COUNTFILE" | tr -d ' ')"

# ── ассерт 1: нарушение ОБЯЗАНО быть поймано (Н-39, гарантия от быстрой-неверной) ──
printf '%s\n' "$out" | grep -qF 'коммит вне зоны: agent03' \
  || fail "нарушение agent03->zones/agent07/ НЕ поймано (rc=$rc) — тест ловил бы потерю проверки, не производительность:
$out"
[ "$rc" -eq 1 ] || fail "check_zones rc=$rc, ожидался 1 (нарушение объявлено выше поймано, общий rc обязан быть 1)"

# ── ассерт 2 (СТРУКТУРНЫЙ ПРЕДЕЛ, без wall-clock): a·(K+M)+b ─────────────────
A=6; B=20
bound=$((A * (K + M) + B))
printf 'toy: K=%d контрактов, M=%d фоновых коммитов, нарушение поймано (rc=1)\n' "$K" "$M" >&2
printf 'git-подпроцессов на прогон: %d - граница a*(K+M)+b = %d*(%d+%d)+%d = %d\n' \
  "$calls" "$A" "$K" "$M" "$B" "$bound" >&2
[ "$calls" -le "$bound" ] \
  || fail "git-вызовов $calls > границы $bound — O(контракты×коммиты) пере-скан (Н-126): каждый фоновый коммит получает git log -1 НА КАЖДОЕ из $K окон вместо batched-запроса на окно"

printf 'ПРЕДЕЛ ДЕРЖИТСЯ: %d <= %d\n' "$calls" "$bound" >&2
exit 0
