#!/usr/bin/env bash
# Барьер add-A (контракт 016, срез 1): staged-множество коммитящего судится ДО коммита.
#
# Зачем: правка зоны агентом через `git add -A` прорывалась молча — обход проверки зон,
# не достигшей коммита. Контроль при `commit` не помогал: staged-объекты к моменту суда
# check_zones уже были в истории и недоступны для отката без force-push. Прецедент — 0171f1b
# (файл с именем-обрывком «открытые с адресами:\n» ушёл в коммит, чистка стоила force-push'а
# и 2 красных CI-циклов).
#
# ЧТО СУДИТСЯ. Три входа (документация Q1 + контракт 019):
#   * staged-путь вне зон КОММЯЩЕГО АВТОРА → «вне зоны: <путь>»;
#   * control-символ (U+0000–U+001F, U+007F) в ИМЕНИ staged-пути → «имя с control-символом» —
#     ВКЛЮЧАЯ случай внутри зоны: префикс-матч зон пропускает обрывок, грамматика имени ловит.
#   * контракт 019 (Н-72): staged-путь УСТАВНОГО класса у зонированного автора —
#     ДЕЛЕГИРОВАНИЕ check_charter: rc и текст вердикта наследуются (грамматика razreshil —
#     единый источник). Предикат — `is_charter_path` из check_charter.sh (CHARTER_LIB=1);
#     вторая реализация кольца запрещена.
#   * контракт 023 (ветвь iii, дверь стража): staged `contracts/<NNN>-*.md` под автором
#     `architect`, где NNN — номер из basename (три цифры из parse_artifact_basename) —
#     пропускается без суда зон, ЕСЛИ выполнены ПЯТЬ условий ВМЕСТЕ (грамматика + реестр
#     + dual-control на origin + ветка wip/<NNN>/<author> + файл не в main). См. реализацию
#     двери ниже в главном цикле. Зоны нового контракта живут в его собственном файле и
#     неактивны до заморозки.
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

# ИДЕНТИЧНОСТЬ. Автор берётся из ЭФФЕКТИВНОЙ identity контекста хука (контракт 016, пост-доне
# фикс-пакет 016): каскад `git var GIT_AUTHOR_IDENT` (видит env `GIT_AUTHOR_*` + config
# `user.*`; при `git -c user.name=… -c user.email=… commit` родительский `git` пробрасывает
# фактические значения в hook-окружение, измерено) с fallback на `$GIT_AUTHOR_NAME` напрямую.
# Правило Н-56 о пустом локальном `user.name` сохранено: дефолта НЕТ, общий .git/config
# не несёт `user.name`, и прежний обход `git config --local user.name` (что при пустоте
# давало «не судится» на КАЖДОМ санкционированном коммите — две живые пробы оркестратора
# прорвались) закрыт. Автор ВИДЕН, пока его коммит несёт валидную identity хотя бы в
# одном из двух каналов; оба канала пусты — fail-closed (rc=1, именованная причина).

# ГРАНИЦА КАНАРЕЙКИ (РЕШЕНИЕ 67fb3b1, §(а) стандарт-А). Канарейка закрывает FAIL-CLOSED
# против БИТОЙ среды (нет python3, exit-стаб, обрезка вывода) и НЕ защищает от
# адверсариального интерпретатора-двойника в PATH, воспроизводящего канарейки и лгущего
# на цели — класс вне досягаемости метода по построению, эквивалент по мощности --no-verify
# (Q1 cognitive-only). Ловец двойника — доверенность среды прогона (герметичный PATH CI,
# пиновка интерпретатора), вне 016. Канарейку НЕ рандомизировать: угроза — поломка,
# поломка не адаптивна, а закрытия против адверсарии рандомизация не покупает.
#
#   bash scripts/check_staged.sh            проверить это дерево
#   bash scripts/check_staged.sh <корень>   проверить другое
# Коды возврата: 0 — staged в зоне автора, либо staged пуст, либо автор ВИДЕН но не объявлен
# ни в одной заморозке (владелец, прошлые сессии); 1 — вне зоны, control-символ в имени,
# судья не может исполнить проверку control-символов (нет python3, канарейка не подтверждена)
# ЛИБО identity автора пуста (fail-closed на пустоте); 2 — нечем проверить (нет git,
# нет контрактов).
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"
# Контракт 023, ветвь iii: дверь draft-пуска ПО ТЕГУ ВЫДАЧИ. Дверь читает тег
# `id/CONTRACT/<NNN>` локально (show-ref --verify) и провенанс на origin (dual-control —
# ls-remote + cat-file манифеста registry/contracts.tsv с ЖИВОЙ шапки refs/heads/main НА
# origin). peek удалён — резервация тега теперь явная (next_id issue + строка манифеста).
NEXT_ID_LIB=1
CHARTER_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/check_charter.sh"
# Снимаем `set -e`, который попал из check_charter.sh через `set -euo pipefail` ПЕРЕД
# import-gate. Без `set -e` последующие ветвления и `|| true` работают как прежде.
set +e

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
ident="$(git -C "$ROOT" var GIT_AUTHOR_IDENT 2>/dev/null || true)"
# Формат: "Name <email> timestamp tz"; имя = всё до '<'.
author=""
# Разбор: имя = всё до первого '<'; var печатает "Name <email> timestamp tz".
# Снимаем trailing whitespace (var сохраняет пробел между именем и '<').
if [ "$ident" != "${ident#*<}" ]; then
  name_piece="${ident%%<*}"
  # `${var##*[![:space:]]}` оставляет trailing-whitespace-сегмент (если он есть);
  # удаляем его хвостом `%` — одной подстановкой. На «всё-пробелы» и пустой строке
  # подстановка снимает всю строку до пустоты.
  name_piece="${name_piece%"${name_piece##*[![:space:]]}"}"
  author="$name_piece"
fi
# Fallback: прямая проба $GIT_AUTHOR_NAME — на случай, когда var отказывает (нет email,
# битая среда, прочая аномалия каскада). Тот же приём снятия хвостового whitespace.
if [ -z "$author" ] && [ -n "${GIT_AUTHOR_NAME:-}" ]; then
  fallback="${GIT_AUTHOR_NAME%%<*}"
  fallback="${fallback%"${fallback##*[![:space:]]}"}"
  author="$fallback"
fi
# Fail-closed: оба канала пусты — коммит попал бы «empty ident» дальше по конвейеру
# (правило Н-56), а здесь судья ОБЯЗАН зафиксировать факт пустой identity именованной
# причиной. Ветка «не судится» ниже срабатывает ТОЛЬКО когда автор ВИДЕН и не объявлен
# ни в одной заморозке (владелец, прошлые сессии); пустая identity — другое, не маскируем.
if [ -z "$author" ]; then
  printf 'ОТКАЗ: identity автора пуста (GIT_AUTHOR_IDENT и GIT_AUTHOR_NAME оба пусты) — судья не может определить автора, fail-closed\n' >&2
  exit 1
fi

# staged-пути читаются NULL-разделённым списком из git diff --cached. Пустая выборка — законное
# «нечего судить». Отказ git diff (rc≠0) маскировался пустым stdout в подстановке (находка F-1
# адверсария, verdicts/adversary/contracts-018.md): пустой массив mapfile неотличим от успешного
# пустого входа, и зонированный автор с чужой wip-веткой получал rc 0 на непрочитанном staged.
# Теперь rc процесса фиксируется ДО ветви «staged пуст» — fail-closed с литералом «staged не
# прочитан» (Н-39, единый источник — шапка fixtures/check_staged/case_staged_ne_prochitan.sh).
# stderr git приглушён: rc обязан быть наблюдён, а текст диагностики свой.
staged_tmp="$(mktemp)" || { printf 'NOT_IMPLEMENTED: mktemp не сработал\n' >&2; exit 2; }
trap 'rm -f "$staged_tmp"' EXIT
git -C "$ROOT" diff --cached --name-only -z 2>/dev/null > "$staged_tmp"; diff_rc=$?
if [ "$diff_rc" -ne 0 ]; then
  printf 'ОТКАЗ: staged не прочитан (git diff --cached --name-only -z завершился кодом %d)\n' "$diff_rc" >&2
  exit 1
fi
mapfile -d '' staged < "$staged_tmp"
if [ "${#staged[@]}" -eq 0 ]; then
  printf 'нечего судить: staged пуст\n'
  exit 0
fi

# Защитная ветка: пустой `author` — недостижимо в норме (выше fail-closed на пустоте),
# оставлено как страховка от регресса детектора identity. Старая семантика check_zones
# (владелец и прошлые сессии не проверяются) уже закрыта «не судится».
if [ -z "$author" ]; then
  printf 'не судится: identity автора пуста (барьер ВЫШЕ fail-closed в норме)\n'
  exit 0
fi

# Автор есть, но ни одной ЗОНА-строки ему не принадлежит — то же «не судится»: владелец
# или прошлая сессия, у которых зон не заведено. Семантика check_zones.
my_count="$(awk -F'\t' -v a="$author" '$1 == a { c++ } END { print c+0 }' "$out/zones_scoped")"
if [ "$my_count" -eq 0 ]; then
  printf 'не судится: автор «%s» не объявлен ни в одной заморозке\n' "$author"
  exit 0
fi

# Страж «ветка, не main» (срез 1 контракта 018). ПОСЛЕ «не судится» и ДО суда путей.
# Если автора спавнили в worktree (жива wip/<NNN>/<author>) И текущий чекаут — НЕ его
# СОБСТВЕННАЯ wip/<*>/<author> (main, чужая wip, detached), именованный отказ rc 1.
# «Своя» ⟺ префикс wip/ И последний компонент (после последнего /) == author (замер 4
# арбитража contracts-018-krasnyj-kontur-vetki.md: подстрочное/глоб-срезание ловит Р4).
# Судья (нет своей wip-ветки) и владелец (не зонирован, fail-open выше) — main-direct
# легитимен; защита коллизии (Q4) премисы. Канарейка И-5 016 не судит (чтение, не commit/merge).
has_own_wip=0
while IFS= read -r ref; do
  bname="${ref#refs/heads/}"
  last="${bname##*/}"
  if [ "$last" = "$author" ]; then
    has_own_wip=1
    break
  fi
done < <(git -C "$ROOT" for-each-ref --format='%(refname)' refs/heads/wip/ 2>/dev/null)
if [ "$has_own_wip" -eq 1 ]; then
  cur_branch="$(git -C "$ROOT" symbolic-ref --short HEAD 2>/dev/null || true)"
  is_own_wip=0
  if [ -n "$cur_branch" ]; then
    case "$cur_branch" in
      wip/*) [ "${cur_branch##*/}" = "$author" ] && is_own_wip=1 ;;
    esac
  fi
  if [ "$is_own_wip" -ne 1 ]; then
    cur_descr="${cur_branch:-detached HEAD}"
    printf 'ОТКАЗ: вне своей ветки wip/ — автор «%s» спавнен в worktree (жива wip/<NNN>/%s), но коммитит в «%s» (коммит-в-main / чужой worktree / detached) — это и есть «коммит мимо своего worktree»\n' \
      "$author" "$author" "$cur_descr" >&2
    exit 1
  fi
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

  # ── Контракт 019, ветвь 1: уставной класс → делегирование check_charter ─────
  # Предикат is_charter_path (CHARTER_LIB=1) проверяет живой тег ustav/1 или
  # frozen/<dir>/<NNN>/1. Делегирование: запускаем check_charter.sh на корне, наследуем
  # rc и ВЫВОД — именованные причины «изменён без разрешения владельца», «не назвала путь»,
  # «без причины» (грамматика razreshil — единый источник в check_charter.sh, фикстура
  # грамматику не переизобретает). rc 0 → путь пропущен; ненулевой → отказ с наследованным
  # текстом. ok-строка check_charter с числом просмотренных коммитов проходит наверх.
  charter_rc=0
  if is_charter_path "$f" "$ROOT"; then
    printf 'judged: %s (делегировано check_charter)\n' "$f"
    charter_out="$(bash "$SELF_DIR/check_charter.sh" "$ROOT" 2>&1)" || charter_rc=$?
    printf '%s' "$charter_out"
    if [ "$charter_rc" -ne 0 ]; then
      rc=1
    fi
    continue
  fi

  # ── Контракт 023, ветвь iii: дверь draft-пуска по тегу выдачи (Н-77(г)) ──────
  # ПЯТЬ условий ВМЕСТЕ для пропуска staged-пути contracts/<NNN>-<slug>.md под architect:
  #   1. грамматика пути contracts/[0-9][0-9][0-9]-* (case выше уже отфильтровал);
  #   2. тег id/CONTRACT/<NNN> жив локально (show-ref --verify);
  #   3. ПРОВЕНАНС = DUAL-CONTROL (вердикт 57c8141 блокер 1): три якоря ВМЕСТЕ —
  #      (3а) тег достижим на origin (ls-remote точного имени);
  #      (3б) манифест registry/contracts.tsv по ЖИВОЙ шапке refs/heads/main НА origin
  #           несёт строку «<NNN> → <tag-object-sha>»;
  #      (3в) sha-origin == sha-манифеста;
  #   4. текущая ветка wip/<NNN>/<автор>;
  #   5. contracts/<NNN>-* отсутствует в refs/heads/main.
  # Порядок проверки (контракт 023): грамматика → реестр (2) → провенанс (3) → ветка (4) →
  # приземление (5). Мёртвый тег отвергает ДО разбора ветки (реестр первичен, отказ «номер
  # <NNN> не выдан» не маскируется отказом по ветке). Self-mint и агентский origin-push
  # без манифеста → «не выдан авторитетом» прежде ветки (гейминг реестра глубже дисциплины
  # ветки). Недоступный origin → «авторитет недоступен» (fail-closed, сетевой сбой не
  # открывает дверь; имя ОТДЕЛЬНОЕ от «не выдан авторитетом»).
  if [ "$author" = "architect" ]; then
    case "$f" in
      contracts/[0-9][0-9][0-9]-*)
        base="${f##*/}"
        path_nnn="${base%%-*}"
        # 2. тег жив локально
        if ! git -C "$ROOT" show-ref --verify --quiet "refs/tags/id/CONTRACT/$path_nnn"; then
          printf 'ОТКАЗ: номер %s не выдан — спавн мимо реестра (тег id/CONTRACT/%s отсутствует)\n' "$path_nnn" "$path_nnn" >&2
          rc=1
          continue
        fi
        # 3. dual-control
        dual_rc=0
        dual_msg=""
        # 3а. ls-remote origin tag
        sha_origin=""
        ls_tag_err="$(git -C "$ROOT" ls-remote "origin" "refs/tags/id/CONTRACT/$path_nnn" 2>&1 >"$ROOT/.staged_ls_tag.$$")"
        ls_tag_rc=$?
        if [ "$ls_tag_rc" -ne 0 ]; then
          dual_rc=1; dual_msg="авторитет недоступен: ls-remote origin refs/tags/id/CONTRACT/$path_nnn завершился кодом $ls_tag_rc"
        else
          sha_origin="$(awk '{print $1}' "$ROOT/.staged_ls_tag.$$" 2>/dev/null | head -1)"
          rm -f "$ROOT/.staged_ls_tag.$$"
          if [ -z "$sha_origin" ]; then
            dual_rc=1; dual_msg="тег $path_nnn не выдан авторитетом: тег не достижим на origin (достижимости мало — авторитет санкционирует СТРОКОЙ манифеста)"
          else
            # 3б. живая шапка origin/main + манифест
            origin_main_sha=""
            ls_main_err="$(git -C "$ROOT" ls-remote "origin" "refs/heads/main" 2>&1 >"$ROOT/.staged_ls_main.$$")"
            ls_main_rc=$?
            if [ "$ls_main_rc" -ne 0 ]; then
              dual_rc=1; dual_msg="авторитет недоступен: ls-remote origin refs/heads/main завершился кодом $ls_main_rc"
            else
              origin_main_sha="$(awk '{print $1}' "$ROOT/.staged_ls_main.$$" 2>/dev/null | head -1)"
              rm -f "$ROOT/.staged_ls_main.$$"
              if [ -z "$origin_main_sha" ]; then
                dual_rc=1; dual_msg="авторитет недоступен: пустая шапка origin/main"
              else
                # git cat-file -p <sha>:registry/contracts.tsv — читает объект прямо из локального
                # .git/objects (если origin — bare рядом, объекты уже там; для URL — придётся
                # fetch'нуть). Чтобы не делать fetch здесь, полагаемся на то, что origin в toy —
                # bare рядом (BARRIER_ROOT-паттерн), и объекты доступны.
                manifest_text="$(git -C "$ROOT" cat-file -p "${origin_main_sha}:registry/contracts.tsv" 2>/dev/null || true)"
                if [ -z "$manifest_text" ]; then
                  dual_rc=1; dual_msg="тег $path_nnn не выдан авторитетом: манифест registry/contracts.tsv отсутствует на origin/main (3б)"
                else
                  # Грамматика строки: «<NNN> → <40-hex>» — NNN ровно %03d, разделитель
                  # U+2192, 40-hex ША ОБЪЕКТА аннотированного тега.
                  manifest_sha="$(printf '%s\n' "$manifest_text" | grep -F "${path_nnn} → " | head -1 | awk '{print $3}')"
                  if [ -z "$manifest_sha" ]; then
                    dual_rc=1; dual_msg="тег $path_nnn не выдан авторитетом: строка «$path_nnn → <sha>» отсутствует в манифесте origin/main (3б)"
                  elif [ "$manifest_sha" != "$sha_origin" ]; then
                    dual_rc=1; dual_msg="тег $path_nnn не выдан авторитетом: sha манифеста ($manifest_sha) ≠ sha тега на origin ($sha_origin) (3в)"
                  fi
                fi
              fi
            fi
          fi
        fi
        if [ "$dual_rc" -ne 0 ]; then
          printf 'ОТКАЗ: %s\n' "$dual_msg" >&2
          rc=1
          continue
        fi
        # 4. текущая ветка wip/<NNN>/<автор>
        current_branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
        expected_branch="wip/$path_nnn/architect"
        if [ "$current_branch" != "$expected_branch" ]; then
          printf 'ОТКАЗ: дверь не на своей ветке: путь %s требует ветку %s, текущая %s\n' "$f" "$expected_branch" "$current_branch" >&2
          rc=1
          continue
        fi
        # 5. contracts/<NNN>-* отсутствует в refs/heads/main
        if git -C "$ROOT" ls-tree -r --name-only refs/heads/main 2>/dev/null | grep -qE "^contracts/${path_nnn}-"; then
          printf 'ОТКАЗ: контракт %s уже приземлён в main (путь contracts/%s-* есть в refs/heads/main)\n' "$path_nnn" "$path_nnn" >&2
          rc=1
          continue
        fi
        printf 'judged: %s (дверь по тегу id/CONTRACT/%s пропущена под architect)\n' "$f" "$path_nnn"
        continue
        ;;
    esac
  fi

  # Зона автора. Каталог-префикс совпадает матчем префикса; точный файл — равенством.
  # Со-локализованная печать «напечатано ⟺ судимо» (контракт 018, класс-замыкающее усиление
  # F-4): строка `judged: <путь>` идёт НЕПОСРЕДСТВЕННО ПЕРЕД zones_match_path, в той же итерации;
  # путь, отказанный грамматикой имени, сюда не доходит — дублей в judging-loop грамматики нет.
  printf 'judged: %s\n' "$f"
  if ! zones_match_path "$out" "$author" "$f"; then
    printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2
    rc=1
  fi
done

if [ "$rc" -eq 0 ]; then
  printf 'ok: staged в зоне автора %s (%d путь/путей)\n' "$author" "${#staged[@]}"
fi
exit "$rc"
