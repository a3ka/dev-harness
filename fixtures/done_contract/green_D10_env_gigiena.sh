#!/usr/bin/env bash
# D10 (зелёный вход) — env-гигиена: GIT_DIR/GIT_WORK_TREE отравлены чужим
# деревом с FAIL-вердиктом; писатель обязан СБРОСИТЬ наследованные git-переменные
# (шаг 1, как freeze_contract.sh:37-42) и судить СВОЁ дерево (accept) → тег ставится.
# Стаб-привязка (Н-39): стаб «git без env-гигиены» ловится только здесь —
# на всех остальных входах среды чисты и стаб честен.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d10_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT

# Чужое дерево: FAIL-вердикт по тому же пути.
F="$WORK/foreign"; mkdir -p "$F/contracts" "$F/verdicts/review"
printf '# chuzhoj kontrakt\n' > "$F/contracts/001-x.md"
printf 'FAIL\ntelo\n' > "$F/verdicts/review/contracts-001-v1.md"
git -C "$F" init -q
g "$F" config user.name Fixture
g "$F" config user.email fixture@local
commit_all "$F" 'chuzhoe derevo s fail'

# Своё честное дерево + отравленная среда.
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
LAST_OUT="$(cd "$T" && GIT_DIR="$F/.git" GIT_WORK_TREE="$F" GIT_INDEX_FILE="$F/.git/index" \
  bash "$SUBJ" contracts/001-x.md 'prizemlenie' 2>&1)"; LAST_RC=$?
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: D10: отравленная среда уронила писателя (rc %s):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
g "$T" rev-parse -q --verify 'refs/tags/done/contracts/001/1' >/dev/null || { printf 'ОТКАЗ: D10: тег не поставлен в СВОЁМ дереве\n' >&2; exit 1; }
g "$F" rev-parse -q --verify 'refs/tags/done/contracts/001/1' >/dev/null 2>&1 && { printf 'ОТКАЗ: D10: тег поставлен в ЧУЖОМ дереве\n' >&2; exit 1; }
printf 'D10: среда отравлена, тег поставлен в своём дереве\n' >&2
exit 0
