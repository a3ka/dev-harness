#!/usr/bin/env bash
# ТОНКАЯ ОБЁРТКА scripts/land_project.sh → scripts/accept_publish.sh (094 §Решения п.6).
# Wrapper НЕ пишет мир, НЕ пишет журнал, НЕ коммитит — он только вызывает дверь
# (object/prepare/publish) и пробрасывает её код возврата. Вся merge-семантика
# (identity orchestrator, --no-ff, перенос санкций 065 И-10, атомарный update-ref)
# перенесена в ДВЕРЬ (контракт 094 ПЕРЕСЕЧЕНИЕ implementer scripts/land_project.sh).
#
# Коды возврата (НЕ БАРЬЕР — verify_antiplacebo выводит из per-file сканирования):
#   0 — приземлено (дверь publish rc 0)
#   1 — отказ: «land project ОТКАЗ: <причина>» (дверь publish rc 1, либо собственная пред-проверка)
#   2 — NOT_IMPLEMENTED: нет инструмента или предмет отсутствует
#
# CLI сохранён для обратной совместимости с fixtures/check_judge_gate/ (063):
#   --repo <корень> --branch <ветка>.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOR="$SELF_DIR/accept_publish.sh"

[ -f "$DOOR" ] || { printf 'land project ОТКАЗ: нет двери %s\n' "$DOOR" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет git\n' >&2; exit 2; }

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

# Делегирование двери. wrapper НЕ пишет политику (И-6: политика только из base),
# НЕ пишет журнал (И-1/И-4: verdict/check — дело судей и CI-обвязки), НЕ делает
# merge (Решение 6: всё — в двери). Дверь читает harness/policy из base и при
# отсутствии/неконформности отказывает ИМЕНОВАННО; журнал дверь НЕ читает без
# --journal (--journal ОБЯЗАН быть пустой, иначе wrapper подделывал бы доказательства).
BASE="$(git -C "$REPO" rev-parse main)"
CAND="$(git -C "$REPO" rev-parse "$BR")"
TASK="$BR"

MERGE="$(bash "$DOOR" prepare --repo "$REPO" --task "$TASK" --base "$BASE" --candidate "$CAND")" || {
  printf 'land project ОТКАЗ: prepare отказал\n' >&2; exit 1; }

# Делегирование publish с пустым --journal (без строк verdict/check) — дверь
# честно откажет на И-1 «нет применимого accept для задачи», и merge не состоится.
# Это и есть контрактная защита от Б-1: дверь САМА судит доказательства, wrapper
# их не фабрикует.
EMPTY_J="$(mktemp)"
trap 'rm -f "$EMPTY_J"' EXIT
bash "$DOOR" publish \
  --repo "$REPO" --task "$TASK" --target main \
  --base "$BASE" --candidate "$CAND" --merge "$MERGE" \
  --candidate-ref "$BR" --journal "$EMPTY_J"
rc=$?
exit $rc