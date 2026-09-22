#!/usr/bin/env bash
# Красное 040 (Н-126 доп. + поправка 1 владельца) — check_protected.sh: (А)
# СТРУКТУРНЫЙ (без wall-clock) предел git-вызовов на toy-дереве с M фоновыми
# коммитами ПОСЛЕ merge `-s ours`, что защищённый путь introduce-нул и
# discard-нул одновременно; (Б) КОРРЕКТНОСТЬ на этом же дереве — РЕАЛЬНЫЙ
# барьер обязан ловить пропажу И до, И после батчинга (гарантия Н-39, тот же
# приём, что red_predel_git_vyzovov.sh для check_zones); (В) КРАСНОЕ
# ПОДТВЕРЖДЕНИЕ конкретного риска — наивная `rev-list --objects -- pathspec`
# (БЕЗ --full-history) МОЛЧА теряет путь на этом же дереве (поправка 1), и
# ДВЕ корректные альтернативные формы его находят.
#
# СЧЁТЧИК ВЫЗОВОВ — НЕ PATH-шим. `check_protected.sh:81` сам делает
# `export PATH=/usr/bin:/bin` (доверенный PATH против адверсария 039) — любой
# шим, подложенный ПЕРЕД вызовом, стирается ЭТОЙ строкой субъекта ДО первой
# внешней команды, и PATH-шпион в стиле red_predel_git_vyzovov.sh даёт ЛОЖНЫЙ
# нуль (проверено живьём при разработке — план Б). Вместо этого — приём
# `check_spec_ready.sh:246-253` (уже в дереве): `SHELLOPTS=xtrace
# BASH_XTRACEFD=9` заставляет ДОЧЕРНИЙ bash включить трассировку СРАЗУ на
# старте, ДО собственного `set -euo pipefail` субъекта, независимо от того,
# что субъект потом делает с PATH — трассировка логирует КОМАНДУ КАК НАПИСАНО
# (`git ...`), не резолвнутый бинарник. Каждая строка `+…+ git …` — один
# вызов.
#
# git-упрощение истории (поправка 1 контракта 040): pathspec-ограниченный
# обход ревизий по умолчанию отсекает ветку, TREESAME первому родителю на
# merge `-s ours`, — коммит, где путь появился, никогда не посещается.
#
# Коды возврата: 0 — предел держится И корректность не потеряна И риск/лечение
#                подтверждены; 1 — именованный отказ (сегодня: предел
#                превышен — п.А); 2 — NOT_IMPLEMENTED (субъект/git отсутствует).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CP="$REPO/scripts/check_protected.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red040-protected.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
[ -f "$CP" ] || { printf 'NOT_IMPLEMENTED: субъект не найден: %s\n' "$CP" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

# ── toy-дерево: база + ветка `vetka` (добавляет plans/002-vetka.md) + merge
# -s ours (путь исчезает без единого diff'а с удалением) + M фоновых коммитов
# ПОСЛЕ мержа (раздувают ОБА per-commit-цикла check_protected — roleblobs
# :130-132 и existed.raw :172-177 — БЕЗ добавления новых защищённых путей) ──
R="$WORK/repo"
M=60
mkdir -p "$R/roles" "$R/plans" "$R/verdicts/adversary"
g() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
commit_all() { g add -A; g commit -q -m "$1"; }

printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\nадверсарий\n' > "$R/roles/adversary.md"
printf 'подставной план\n'    > "$R/plans/001-p.md"
printf 'подставной вердикт\n' > "$R/verdicts/adversary/v-a.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
commit_all 'основание'

g checkout -q -b vetka
printf 'план из ветки\n' > "$R/plans/002-vetka.md"
commit_all 'план добавлен в ветке'
BLOB="$(g rev-parse HEAD:plans/002-vetka.md)"
g checkout -q main
g merge -q -s ours vetka -m 'ветка влита стратегией ours'

j=1
while [ "$j" -le "$M" ]; do
  g commit -q --allow-empty -m "фон $j"
  j=$((j + 1))
done

# ── прогон check_protected.sh под внешней трассировкой (иммунна к PATH) ────
TRACE="$WORK/trace.log"
: > "$TRACE"
out="$(env SHELLOPTS=xtrace BASH_XTRACEFD=9 bash "$CP" "$R" 2>&1 9>"$TRACE")"; rc=$?
calls="$(grep -cE '^\+{1,} git ' "$TRACE")"

# ── п.Б (Н-39, гарантия от быстрой-неверной): пропажа ОБЯЗАНА быть поймана,
# И сегодня (по-коммитная техника), И после батчинга (разрешённые формы п.1) ──
[ "$rc" -eq 1 ] || fail "п.Б: check_protected.sh rc=$rc на toy с M=$M фоновыми коммитами, ожидался 1
$out"
printf '%s\n' "$out" | grep -qF 'существовал и на HEAD его нет: plans/002-vetka.md' \
  || fail "п.Б: причина не названа дословно
$out"
printf 'п.Б держится: check_protected.sh (rc=1) ловит -s ours-пропажу И на дереве с M=%d фоновыми коммитами\n' "$M" >&2

# ── п.А (СТРУКТУРНЫЙ ПРЕДЕЛ, без wall-clock): малая константа, а не O(M) ────
BOUND=30
printf 'git-подпроцессов на прогон check_protected.sh (трассировка SHELLOPTS=xtrace): %d - граница: %d\n' "$calls" "$BOUND" >&2
[ "$calls" -le "$BOUND" ] \
  || fail "git-вызовов $calls > границы $BOUND — O(коммитов) пере-скан (roleblobs :130-132 + existed.raw :172-177): каждый фоновый коммит получает git ls-tree НА ОБА цикла вместо ДВУХ вызовов git rev-list --objects"

# ── п.В (КРАСНОЕ подтверждено — поправка 1): наивная форма ТЕРЯЕТ путь ──────
naive_paths="$(g rev-list HEAD --objects -- ':(literal)plans/' | awk 'NF>1{print $2}')"
if printf '%s\n' "$naive_paths" | grep -qF 'plans/002-vetka.md'; then
  fail "п.В: наивная git rev-list --objects -- pathspec НАШЛА путь — риск не воспроизведён на этом git, вход не работает"
fi
printf 'п.В (КРАСНОЕ подтверждено): наивная `rev-list --objects -- pathspec` (без --full-history) НЕ видит plans/002-vetka.md — запрещённая техника (поправка 1)\n' >&2

fh_paths="$(g rev-list HEAD --objects --full-history -- ':(literal)plans/' | awk 'NF>1{print $2}')"
printf '%s\n' "$fh_paths" | grep -qF 'plans/002-vetka.md' \
  || fail "форма 1 (--full-history) НЕ нашла путь — ожидаемая корректная форма не работает на этом git"
printf 'форма 1 корректна: `rev-list --objects --full-history -- pathspec` видит путь\n' >&2

np_paths="$(g rev-list HEAD --objects | awk 'NF>1{print $2}' | grep '^plans/' || true)"
printf '%s\n' "$np_paths" | grep -qF 'plans/002-vetka.md' \
  || fail "форма 2 (без pathspec + фильтр) НЕ нашла путь"
printf 'форма 2 корректна: `rev-list --objects` без pathspec + awk-фильтр видит путь\n' >&2

printf 'блоб vetka:plans/002-vetka.md = %s (для справки)\n' "$BLOB" >&2
exit 0
