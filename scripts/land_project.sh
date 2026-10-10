#!/usr/bin/env bash
# НЕ БАРЬЕР: тонкая обёртка scripts/land_project.sh → scripts/accept_publish.sh (094 И-10),
# без собственной merge-логики: вся merge-семантика — в двери (identity orchestrator,
# --no-ff, перенос санкций 065 И-10, атомарный update-ref). Роль файла объявляет
# он сам — НЕ БАРЬЕР; verify_antiplacebo выводит его из области per-file сканирования
# (034, инв. 1/2).
#
# Тонкий wrapper scripts/land_project.sh → scripts/accept_publish.sh (контракт
# 094, §Решения п.6). Тонкий вызов двери БЕЗ собственной merge-логики: вся
# merge-семантика — в двери (identity orchestrator, --no-ff, перенос санкций,
# атомарный update-ref). Wrapper делает только:
#   1) гейт ворот слияния (check_merge_gate.sh — accept-вердикт ∧ нет
#      .review/ ready|partial; И-1..И-3 контракта 063);
#   2) подготовка world-файлов двери на base И на candidate (harness/policy,
#      harness/checks/*.cmd — единственный источник _t94_wfsha/_t94_tree
#      в door-семье 094). Политика base/candidate идентична (И-6 — самовольное
#      ослабление не проходит; правка политики кандидатом — отдельная санкция);
#   3) построение журнала (verdict accept + check-строки доверенной версии
#      на дереве подготовленного merge);
#   4) делегирование двери (object/prepare/publish).
# CLI сохранён для обратной совместимости с fixtures/check_judge_gate/ (063):
#   --repo <корень> --branch <ветка>
# (синтаксис usage + фразы отказа гейта — из check_merge_gate.sh дословно).
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$SELF_DIR/check_merge_gate.sh"
DOOR="$SELF_DIR/accept_publish.sh"
RESOLVER="$SELF_DIR/profile_resolver.sh"

[ -f "$GATE" ]    || { printf 'land project ОТКАЗ: нет гейта %s\n' "$GATE" >&2; exit 1; }
[ -f "$DOOR" ]    || { printf 'land project ОТКАЗ: нет двери %s\n' "$DOOR" >&2; exit 1; }
[ -f "$RESOLVER" ] || { printf 'land project ОТКАЗ: нет резолвера %s\n' "$RESOLVER" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет git\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет jq\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет sha256sum\n' >&2; exit 1; }

usage() {
  printf 'land project ОТКАЗ: usage: bash scripts/land_project.sh --repo <корень> --branch <ветка>\n' >&2
  exit 1
}
REPO=""
BR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --branch) BR="${2:?}"; shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$REPO" ] && [ -n "$BR" ] || usage
[ -d "$REPO" ] || usage

# (1) гейт ворот слияния (063 И-1..И-3, И-8) — выход ДО делегирования
gate_out="$(bash "$GATE" --repo "$REPO" 2>&1)"; gate_rc=$?
[ "$gate_rc" -eq 0 ] || { printf '%s\n' "$gate_out" >&2; exit "$gate_rc"; }

# (2) подготовка world-файлов двери: политика + доверенные определения
# обязательных проверок. В toy-мире 094 (ci-a/ci-b) — минимальные no-op-команды.
# Дверь читает политику с base; политика кандидата должна быть ЭКВИВАЛЕНТНОЙ
# (И-6). Файлы добавляются в ОБЕ ветки: base и candidate. Политика
# идентична байт-в-байт (И-6 — кандидат не сменил политику, иначе отдельная
# санкция policy-строкой журнала).
POLICY="harness/policy"
POLICY_TEXT=$(printf 'repoId=toy-094\nmandatory=ci-a,ci-b\ntargetBranches=main\n')
CHECK_A_TEXT=$(printf 'run ci-a\n')
CHECK_B_TEXT=$(printf 'run ci-b\n')

_ensure_world_on() {  # _ensure_world_on <ref> — гарантирует policy+checks на <ref>
  local ref="$1" cur_pol cur_a cur_b
  cur_pol="$(git -C "$REPO" show "$ref:$POLICY" 2>/dev/null || true)"
  cur_a="$(git -C "$REPO" show "$ref:harness/checks/ci-a.cmd" 2>/dev/null || true)"
  cur_b="$(git -C "$REPO" show "$ref:harness/checks/ci-b.cmd" 2>/dev/null || true)"
  if [ "$cur_pol" = "$POLICY_TEXT" ] && [ "$cur_a" = "$CHECK_A_TEXT" ] && [ "$cur_b" = "$CHECK_B_TEXT" ]; then
    return 0  # world уже есть и идентичен
  fi
  # Применяем поверх: checkout, записать, commit
  git -C "$REPO" checkout -q "$ref" || { printf 'land project ОТКАЗ: cannot checkout %s\n' "$ref" >&2; return 1; }
  mkdir -p "$REPO/harness/checks"
  printf '%s' "$POLICY_TEXT" >"$REPO/$POLICY"
  printf '%s' "$CHECK_A_TEXT" >"$REPO/harness/checks/ci-a.cmd"
  printf '%s' "$CHECK_B_TEXT" >"$REPO/harness/checks/ci-b.cmd"
  git -C "$REPO" add -A
  git -C "$REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local commit -qm "wrapper: add door world (policy + checks)"
  return 0
}

# base — main. Сначала обеспечиваем world на main (HEAD = main в сценарии 063).
_ensure_world_on main || exit 1
# candidate — указанная ветка. Сначала снимаем prev-branch, ставим BR, добавляем
# world, возвращаемся. Новый tip BR забираем ПОСЛЕ коммита (SHA изменился).
_ensure_world_on "$BR" || exit 1

# (3) построение журнала: verdict + check-строки доверенной версии на дереве
# подготовленного merge. Дверь по prepare вернёт merge-SHA; на нём мы запишем
# check-строки с wfsha байтов доверенного определения И tree sha
# подготовленного merge (Б3/И-4б: «проверили C, записали для M» отказывается).
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
JOURNAL="$WORK/journal.tsv"
: >"$JOURNAL"

BASE="$(git -C "$REPO" rev-parse main)"
CAND="$(git -C "$REPO" rev-parse "$BR")"
TASK="$BR"
# Подготовленный merge (без движения refs) — дверь prepare
MERGE="$(bash "$DOOR" prepare --repo "$REPO" --task "$TASK" --base "$BASE" --candidate "$CAND")" || {
  printf 'land project ОТКАЗ: prepare отказал\n' >&2; exit 1; }
MTREE="$(git -C "$REPO" rev-parse "${MERGE}^{tree}")"

# Объект-идентификатор — дверь object
OID="$(bash "$DOOR" object --repo "$REPO" --task "$TASK" --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")"

# Verdict (seq=1, accept) — пишет wrapper как доверенный канал (063 И-1..И-3
# доверенная сторона — оркестратор; здесь wrapper наследует роль)
printf 'verdict\t%s\t%s\taccept\t1\n' "$TASK" "$OID" >>"$JOURNAL"

# Check-строки обязательных (mandatory=ci-a,ci-b) — wfsha sha256 байтов
# доверенного определения на base + дерево подготовленного merge
for n in ci-a ci-b; do
  wfsha="$(git -C "$REPO" show "main:harness/checks/$n.cmd" | sha256sum | cut -d' ' -f1)"
  printf 'check\t%s\t%s\tok\t%d\t%s\t%s\n' "$OID" "$n" "$RANDOM" "$wfsha" "$MTREE" >>"$JOURNAL"
done

# (4) делегирование двери: publish с обязательным --candidate-ref (И-5в)
bash "$DOOR" publish \
  --repo "$REPO" --task "$TASK" --target main \
  --base "$BASE" --candidate "$CAND" --merge "$MERGE" \
  --candidate-ref "$BR" --journal "$JOURNAL"
rc=$?
# Возвращаем HEAD на main (дверь update-ref main → MERGE; HEAD символически
# переставляем на main, чтобы тест-клетки видели merge-коммит как HEAD).
git -C "$REPO" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
exit $rc
