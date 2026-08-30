#!/usr/bin/env bash
# Барьер add-A (контракт 016, срез 1): staged-множество коммитящего судится ДО коммита.
#
# Зачем: правка зоны агентом через `git add -A` прорывалась молча — обход проверки зон,
# не достигшей коммита. Контроль при `commit` не помогал: staged-объекты к моменту суда
# check_zones уже были в истории и недоступны для отката без force-push. Прецедент — 0171f1b
# (файл с именем-обрывком «открытые с адресами:\n» ушёл в коммит, чистка стоила force-push'а
# и 2 красных CI-циклов).
#
# ЧТО СУДИТСЯ. Два входа (документация Q1):
#   * staged-путь вне зон КОММЯЩЕГО АВТОРА → «вне зоны: <путь>»;
#   * control-символ (U+0000–U+001F, U+007F) в ИМЕНИ staged-пути → «имя с control-символом» —
#     ВКЛЮЧАЯ случай внутри зоны: префикс-матч зон пропускает обрывок, грамматика имени ловит.
#
# ЧТО НЕ СУДИТСЯ (документация Q1, явно). staged пуст → «нечего судить». Автор не объявлен ни
# в одной заморозке → «не судится» (та же семантика, что у check_zones: владелец и прошлые
# сессии не проверяются). Маски корневого скратча (`/out*.txt` у корня) — слой `.gitignore`,
# не ветвь этого судьи: различимого входа нет, и Н-39 запрещает заводить ветвь без собственного
# входа.
#
# ИСТОЧНИК ЗОН — блоб высшей заморозки, не рабочее дерево (иначе правка файла расширяла бы зону
# без заморозки). Чтение — через ЕДИНСТВЕННУЮ реализацию `scripts/lib_zones.sh`; второй
# читатель ЗОНА-строк запрещён (прецедент lib_roles/lib_registry). Зона автора —
# объединение путей из ВСЕХ замороженных контрактов (пересечение бессмысленно: две работы,
# а не одна).
#
# ИДЕНТИЧНОСТЬ. Автор берётся из ЛОКАЛЬНОГО `user.name` репозитория (Q3): общий .git/config
# не должен нести дефолтного user.name (И-9/Н-56), а worktree шарит общий конфиг. Если дефолта
# нет — коммит упадёт «empty ident» ещё до этой проверки, и предмет «вне зоны» не закрыт.
#
#   bash scripts/check_staged.sh            проверить это дерево
#   bash scripts/check_staged.sh <корень>   проверить другое
#
# Коды возврата: 0 — staged в зоне автора либо staged пуст либо автор не объявлен,
# 1 — вне зоны, control-символ в имени, либо судья не может исполнить проверку control-символов
# (нет python3, канарейка не подтверждена); 2 — нечем проверить (нет git, нет контрактов).
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"

ROOT="${1:-$SELF_DIR/..}"
case "$ROOT" in
  /*) ;;
  *)  ROOT="$PWD/$ROOT" ;;
esac
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT" >&2; exit 2; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }

# Чтение зон через ЕДИНСТВЕННУЮ реализацию. На пустом реестре — функция возвращает пустой
# каталог и 0; зон нет → «не судится» (см. ниже).
out="$(zones_load "$ROOT" 2>/dev/null)"; rc=$?
case "$rc" in
  0) ;;
  *) printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2 ;;
esac
trap 'rm -rf "$out"' EXIT

# Автор — из ЛОКАЛЬНОГО конфига. Дефолта нет (И-9/Н-56): пустая строка означает «не судится»,
# но и коммит без явной identity упал бы «empty ident».
author="$(git -C "$ROOT" config --local --get user.name 2>/dev/null || true)"

# staged-пути читаются NULL-разделённым списком из git diff --cached. Пустая выборка — законное
# «нечего судить».
mapfile -d '' staged < <(git -C "$ROOT" diff --cached --name-only -z 2>/dev/null)
if [ "${#staged[@]}" -eq 0 ]; then
  printf 'нечего судить: staged пуст\n'
  exit 0
fi

# Автор не объявлен ни в одной заморозке — не судится. Семантика check_zones: владелец и
# прошлые сессии не проверяются. Здесь же — то же, чтобы коммит без дефолта, попавший в зону
# «запрещённой ветви», не краснел «вне зоны» от пустоты user.name.
if [ -z "$author" ]; then
  printf 'не судится: автор не объявлен (user.name пуст)\n'
  exit 0
fi

# Автор есть, но ни одной ЗОНА-строки ему не принадлежит — то же «не судится»: либо владелец,
# либо прошлая сессия, у которых зон не заведено.
my_count="$(awk -F'\t' -v a="$author" '$1 == a { c++ } END { print c+0 }' "$out/zones_scoped")"
if [ "$my_count" -eq 0 ]; then
  printf 'не судится: автор «%s» не объявлен ни в одной заморозке\n' "$author"
  exit 0
fi

# Главный цикл. Каждый staged-путь судится ДВУМЯ входами: грамматика имени И зона автора.
# Порядок — грамматика ВПЕРЕДИ: control-символ ловится и ВНУТРИ зоны (Н-39: ветвь зон не
# покрывает вход обрывка имени, грамматика покрывает).
#
# ДЕТЕКТ CONTROL-СИМВОЛОВ — через python3. GNU grep с диапазоном \x00-\x1f нестабилен в разных
# локалях (измерено: «grep: Invalid regular expression» на некоторых платформах); python
# детерминирован и по §Зоны уже задействован в gc_agent_branches для Н-60.

#
# Находка 2 адверсария (первый круг): `if … | python3 …` трактовал rc=127 от ненайденного
# python3 как «нет control-символа» — staged с переносом ВНУТРИ зоны проходил зелёным.
# Закрыто проверкой `command -v python3` ДО цикла и отказом с названной причиной.
#
# Находка 1 раунда 2 адверсария (`fake-python3-exit-1`, вердикт e344421): подменённый
# python3 (exit 0, exit 1, обрезка вывода) проходил `command -v` и давал судье
# ЛОЖНО-чистое имя. Закрыто само-канарейкой: тот же python3-конвейер обязан подтвердить
# поведение на заведомо содержащем control-символ stdin И на чистом — И по exit code,
# И по маркеру stdout. Stub `exit 0` печатает пустоту — расхождение маркера ловит; stub
# `exit 1` ловится расхождением exit code; обрезка вывода ловится пустым stdout. Любая
# неисправность python3 → канарейка красная → fail-closed rc=1 «судья не может исполнить
# проверку».
if ! command -v python3 >/dev/null 2>&1; then
  printf 'ОТКАЗ: невозможно проверить control-символ в имени — python3 отсутствует в PATH (судья не может исполнить проверку control-символов, fail-closed)\n' >&2
  exit 1
fi
_py_check() {
  python3 -c '
import sys
s = sys.stdin.read()
r = any((ord(c) < 0x20) or (ord(c) == 0x7f) for c in s)
sys.stdout.write("1" if r else "0")
sys.exit(0 if r else 1)'
}
# Канарейка: тот же конвейер на заведомо с control-символом stdin И на чистом. Оба
# прогона обязаны вернуть ожидаемый exit code И маркер stdout; любое расхождение —
# подменённый/битый python3, fail-closed.
cc_out="$(printf 'a\nb' | _py_check)"
cc_rc=$?
cl_out="$(printf 'clean' | _py_check)"
cl_rc=$?
if [ "$cc_rc" -ne 0 ] || [ "$cc_out" != "1" ] || [ "$cl_rc" -ne 1 ] || [ "$cl_out" != "0" ]; then
  printf 'ОТКАЗ: судья не может исполнить проверку control-символов — канарейка не подтверждена (python3 подменён, exit≠0, 0-rc заглушка или обрезка вывода)\n' >&2
  exit 1
fi
rc=0
for f in "${staged[@]}"; do
  m="$(printf '%s' "$f" | _py_check)"
  if [ "$m" = "1" ]; then
    printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2
    rc=1
    continue
  fi
  # Зона автора. Каталог-префикс совпадает матчем префикса; точный файл — равенством.
  if ! zones_match_path "$out" "$author" "$f"; then
    printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2
    rc=1
  fi
done

if [ "$rc" -eq 0 ]; then
  printf 'ok: staged в зоне автора %s (%d путь/путей)\n' "$author" "${#staged[@]}"
fi
exit "$rc"
