#!/usr/bin/env bash
# Н-127: детерминированное репро НА TOY-РЕПОЗИТОРИИ (не временная метрика) топологии, из-за
# которой `excuse_for()` теряет ALLOW-ARTIFACT-DELETE.
#
# Топология буквально повторяет то, что произошло на реальном дереве dev-harness
# (verdicts/critic/contracts-040-v2.md, удаляющий коммит 4b3666f, мерж b2240a4 — см.
# NABLIUDENIA.md Н-127):
#   1. ветка A создаёт защищённый файл;
#   2. ветка B ответвляется от A ДО удаления и живёт независимо (свой коммит, файл не трогает);
#   3. на A файл удаляется коммитом с корректной строкой ALLOW-ARTIFACT-DELETE;
#   4. B сливается в A `git merge --no-ff` — тело мерж-коммита БЕЗ ALLOW-строки (повторять её
#      незачем: разрешение уже сказано в настоящем удаляющем коммите шага 3).
#
# `git log HEAD --full-history --no-renames -m --diff-filter=D --format=%H -- <путь>`
# (буквальная мера excuse_for) относительно ВТОРОГО, отставшего родителя (B, ещё не видевшего
# удаления) показывает мерж-коммит как D — он новее настоящего удаляющего коммита, и
# `sed -n 1p` прежней редакции брал именно его, теряя тело коммита шага 3.
#
# ДО фикса (Н-127) это репро обязано дать ТОЧНО ту же ошибку, что на реальном дереве: rc=1,
# FAIL «защищённый артефакт существовал и на HEAD его нет: <путь>» — легитимно удалённый путь
# читается как нарушение. ПОСЛЕ точечного фикса excuse_for() (is_lagging_merge_artifact
# пропускает мерж-артефакт и находит настоящий удаляющий коммит дальше в истории) — rc=0,
# ok-строка «исчез с явного разрешения: <путь>».
#
# Барьер берётся РЯДОМ С ЭТИМ ДЕРЕВОМ (`$ROOT/scripts/check_protected.sh`, ROOT вычислен от
# расположения ЭТОГО файла) — тот же приём, что `scripts/drill_protected_exception.sh` и
# `scripts/drill_protected_rename.sh`: проверяется барьер, который лежит в этом же дереве, а
# не случайно найденный в PATH.
#
#   bash fixtures/check_protected/repro_n127_otstavshij_roditel.sh
#
# Коды возврата: 0 — легитимное удаление признано (фикс на месте), 1 — Н-127 воспроизведено
# (или иное расхождение с ожиданием), 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные меняют построение подставной истории ДО запуска проверяемого
# барьера (прецедент дриллов исключения/переноса) — снимаются, а не обходятся.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
BARRIER="$ROOT/scripts/check_protected.sh"

[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет scripts/check_protected.sh — нечего прогонять\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

mkdir -p "$ROOT/tmp"
W="$(mktemp -d "$ROOT/tmp/repro-n127.XXXXXX")"
trap 'rm -rf "$W"' EXIT

# ГЕРМЕТИЧНОСТЬ, а не аккуратность (прецедент дриллов): внешняя `commit.gpgsign`/`core.hooksPath`
# меняла бы исход ДО запуска проверяемого барьера, и репро было бы ложно-красным на другой машине.
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" \
      -c user.name=Репро -c user.email=repro@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
base_or_skip() {
  "$@" && return 0
  printf 'NOT_IMPLEMENTED: не удалось построить подставную историю (%s) — окружение git мешает\n' "$1" >&2
  exit 2
}

mkdir -p "$W/roles" "$W/verdicts/adversary"
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\n' > "$W/roles/adversary.md"
printf 'вердикт\n' > "$W/verdicts/adversary/v-1.md"

# (1) ветка A (main) создаёт защищённый файл.
base_or_skip env GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$W"
base_or_skip g add -A
base_or_skip g commit -q -m 'A: основание, защищённый файл создан'

# (2) ветка B ответвляется от A ДО удаления (форк из единственного пока коммита A) и живёт
# независимо: свой коммит, защищённый файл не трогает.
base_or_skip g checkout -q -b B
printf 'независимая правка ветки B\n' > "$W/notes-B.md"
base_or_skip g add -A
base_or_skip g commit -q -m 'B: независимая правка, защищённый файл не трогает'

# (3) на A файл удаляется коммитом с корректной ALLOW-ARTIFACT-DELETE строкой.
base_or_skip g checkout -q main
base_or_skip g rm -q verdicts/adversary/v-1.md
base_or_skip g commit -q -F - <<'MSG'
A: защищённый файл снят легитимно

ALLOW-ARTIFACT-DELETE: verdicts/adversary/v-1.md решение владельца, репро топологии Н-127
MSG

# (4) B сливается в A --no-ff; ВТОРОЙ родитель мержа (B) — отставший, ещё не видел удаления.
# Тело мерж-коммита НЕ несёт ALLOW-строку.
base_or_skip g merge -q --no-ff B -m 'слияние независимой ветки B в A (разрешение уже сказано на A)'

out="$W/out.txt"
set +e
bash "$BARRIER" "$W" > "$out" 2>&1
rc=$?
set -e

ok_line='исчез с явного разрешения: verdicts/adversary/v-1.md'
if [ "$rc" -ne 0 ] || ! grep -qF -e "$ok_line" "$out"; then
  printf 'ОТКАЗ: Н-127 воспроизведено — легитимное удаление на toy-репозитории с ЗАЯВЛЕННОЙ\n' >&2
  printf 'топологией (A удаляет с ALLOW, B форкнут раньше и слит --no-ff БЕЗ ALLOW в мерже) не\n' >&2
  printf 'признано барьером (rc=%d, ожидался 0 и строка «%s»):\n' "$rc" "$ok_line" >&2
  sed 's/^/  | /' "$out" >&2
  exit 1
fi
printf '  ok   Н-127: легитимное удаление за отставшим родителем мержа распознано (rc=0, «%s»)\n' "$ok_line" >&2
