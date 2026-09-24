#!/usr/bin/env bash
# ПРИЧИНА: scripts/freeze_contract.sh должен отказать (rc 1) с именованной
# причиной «precision-гейт 043 красен: …» когда ЧЕРНОВИК имеет необъявленные
# коллизии — НЕ записывая freeze-тег frozen/contracts/<NNN>/<v> (Б4 fix).
# Этот сценарий доказывает freeze-time backstop (Вариант Б владельца) —
# freeze_contract.sh ВЫЗЫВАЕТ check_precision_gate.sh и СТОПИТ запись тега
# при красном прогоне. Тест запускает freeze_contract.sh в отдельном клоне
# репозитория, копирует ИЗ worktree УЖЕ ОБНОВЛЁННЫЕ scripts/freeze_contract.sh
# и scripts/check_precision_gate.sh, чтобы хук был в обеих копиях
# (иначе clone имеет старую версию из HEAD коммита, без хука).
set -uo pipefail
export GIT_AUTHOR_NAME=toy GIT_AUTHOR_EMAIL=toy@dev-harness.local
export GIT_COMMITTER_NAME=toy GIT_COMMITTER_EMAIL=toy@dev-harness.local
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_freeze043.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

# Клон репозитория — freeze_contract.sh НЕ должен трогать основную историю.
REPO_CLONE="$(mktemp -d "${TMPDIR:-/tmp}/pg_freeze043_clone.XXXXXX")"
git clone --quiet "$REPO" "$REPO_CLONE" || { printf 'ОТКАЗ: clone не удался\n' >&2; exit 1; }

# Копируем ОБНОВЛЁННЫЕ файлы гейта и freeze-time хука ИЗ worktree (они ещё
# не закоммичены — implementer-патч, который коммитится отдельно).
cp "$REPO/scripts/check_precision_gate.sh" "$REPO_CLONE/scripts/check_precision_gate.sh"
cp "$REPO/scripts/freeze_contract.sh" "$REPO_CLONE/scripts/freeze_contract.sh"
chmod +x "$REPO_CLONE/scripts/check_precision_gate.sh" "$REPO_CLONE/scripts/freeze_contract.sh"

# Заминчиваем 446 в клоне (неиспользованный toy-номер: захардкоженный реальный NNN ломается первым же реальным минтом этого номера — 044 заминчен 96dcb44, тег приезжает в clone и git tag отказывает на дубле).
( cd "$REPO_CLONE" && git tag "id/CONTRACT/446" )

# Регистрируем frozen/contracts/999/1 с alice ЗОНА для shared/thing.txt.
mkdir -p "$REPO_CLONE/contracts" "$REPO_CLONE/shared"
cat > "$REPO_CLONE/contracts/999-foreign.md" <<EOF
# Контракт 999 — чужой (toy)

## Predmet
p

## Зоны

ЗОНА alice: shared/thing.txt
EOF
touch "$REPO_CLONE/shared/thing.txt"
( cd "$REPO_CLONE" && git add -A && git commit -q -m "alice 999 foreign" && git tag -a "frozen/contracts/999/1" -m "alice 999" )

# Вердикт критика (иначе freeze споткнётся об отсутствие вердикта, а не о precision-гейте).
mkdir -p "$REPO_CLONE/verdicts/critic"
cat > "$REPO_CLONE/verdicts/critic/contracts-446-v1.md" <<EOF
accept

# Verdict for 446
EOF

# Черновик с НЕОБЪЯВЛЕННОЙ коллизией — precision-гейт должен красить, freeze отказать.
DRAFT_FILE="contracts/446-toy-draft.md"
cat > "$REPO_CLONE/$DRAFT_FILE" <<EOF
# kontrakt 446 — toy

## Predmet
тестовый контракт для проверки freeze-time backstop.

## Зоны

ЗОНА architect: contracts/446-toy-draft.md shared/thing.txt

(Нет строки ПЕРЕСЕЧЕНИЕ — коллизия с shared/thing.txt (NNN 999 alice) НЕ объявлена.)
EOF
( cd "$REPO_CLONE" && git add -A && git commit -q -m "test draft 446 + verdict" )

# Прогон freeze. Ожидаем rc 1 + именованную причину.
FREEZE_OUT=""
FREEZE_RC=0
FREEZE_OUT="$(cd "$REPO_CLONE" && bash scripts/freeze_contract.sh "$DRAFT_FILE" "тест freeze-time backstop" "$REPO_CLONE" 2>&1)" || FREEZE_RC=$?

if [ "$FREEZE_RC" -eq 0 ]; then
  printf 'ОТКАЗ: freeze_time_hook: rc 0 (ожидался 1): %s\n' "$FREEZE_OUT" >&2
  exit 1
fi

if ! printf '%s' "$FREEZE_OUT" | grep -Fq 'precision-гейт 043 красен:'; then
  printf 'ОТКАЗ: freeze_time_hook: именованная причина не названа: %s\n' "$FREEZE_OUT" >&2
  exit 1
fi

# Тег frozen/contracts/446/1 НЕ должен существовать.
if ( cd "$REPO_CLONE" && git tag -l 'frozen/contracts/446/*' | grep -q . ); then
  printf 'ОТКАЗ: freeze_time_hook: тег frozen/contracts/446/* всё-таки записан\n' >&2
  exit 1
fi

rm -rf "$REPO_CLONE"
printf 'case_14: freeze-time backstop refuses (rc 1, именованная причина, тег НЕ записан)\n' >&2
exit 0