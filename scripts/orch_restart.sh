#!/usr/bin/env bash
# ДВЕРЬ ПЕРЕЗАПУСКА СЕССИИ (контракт 072, расширен контрактом 080, 088).
# ЕДИНСТВЕННАЯ постановка маркера /tmp/dev-harness-verify/orch-restart
# (до реализационной пачки — прежний touch по чеклисту; с этой пачкой
# маркер — ТОЛЬКО этой дверью; см. roles/orchestrator.md §Автоперезапуск).
#
# Гейт (контракт 072 + расширения 080, 088):
#   (0) identity — env `GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME`, `--as <имя>`,
#       за неимением обоих — именованный отказ rc 1 «identity двери
#       не определена» (предмет (а) 080). `.git/config user.name` НЕ
#       читается (весь предмет 080 исключает file-config как источник
#       identity; Н-56). Совместимость с 072 обеспечивается тем, что
#       (в1) использует IDENTITY (env/--as) как эталон для сравнения
#       с автором HANDOFF.md (см. инв. 2 контракта 080), а не file-config.
#       Приоритет: env GIT_AUTHOR_NAME > env GIT_COMMITTER_NAME > --as >
#       отказ «identity двери не определена».
#   (1) живые субагенты — свежие `.jsonl` в каталоге текущей сессии →
#       «живые субагенты: <имена>» (предмет (б) 080, инв. 3;
#       контракт 088, инв. И-1/И-2/И-3 — дом из passwd, не из $HOME,
#       и `current_session_dir` в подоболочке без pipefail)
#   (а) HEAD == origin/main                                → «HEAD расходится с origin/main»
#   (б) porcelain пуст                                     → «porcelain непуст»
#   (в) HANDOFF.md изменён коммитом ЭТОЙ сессии:
#       (в1) автор ПОСЛЕДНЕГО коммита HANDOFF.md == identity (0)
#                                                            → «HANDOFF.md изменён не этой сессией»
#       (в2) committer-дата этого коммита > стартового следа сессии
#                                                            → «HANDOFF.md изменён до стартового следа сессии»
#   (г) check_no_leak.sh --check rc 0                      → «детектор …»
#   (д) нет мусорных worktree ПОСЛЕ делегирования GC       → «мусорный worktree: <путь>»
#
# Маркер атомарен: ставится ПОСЛЕ всех зелёных проверок; при любом отказе
# маркер отсутствует. Уже стоящий маркер дверь НЕ удаляет — не её
# состояние (инвариант 3).
#
# Стартовый след сессии (инвариант 11): файл ВНЕ дерева, путь — шов
# ORCH_SESSION_START (умолчание /tmp/dev-harness-verify/orch-session-start).
# Содержимое — РОВНО ОДНА строка ISO-8601: момент последнего зелёного
# завершения двери (= граница текущей сессии). Отсутствие следа →
# инициализация «сейчас» + отказ (в2); пустой/нечитаемый → fail-closed rc 2.
#
# Коды возврата:
#   0 — маркер поставлен (stdout несёт строку «ПЕРЕЗАПУСК»)
#   1 — именованный отказ (причина в stderr, маркер не ставится)
#   2 — нечем проверить (NOT_IMPLEMENTED: …; маркер не ставится)

set -uo pipefail

# Гигиена Н-85: снять GIT_DIR/GIT_WORK_TREE и пр. — иначе дверь судит
# чужой репозиторий (прецедент check_no_leak.sh:217-225).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM

# Тест-швы (инвариант 6): переопределение — дверь НЕ читает и НЕ пишет
# умолчательный путь того же шва.
MARKER="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
TRACE="${ORCH_SESSION_START:-/tmp/dev-harness-verify/orch-session-start}"
# Тест-шов ORCH_SESS_DIR (контракт 080, инв. 3/4) — каталог текущей
# orch-сессии для ноги (1) живых субагентов. По умолчанию — вычисляется
# `current_session_dir` из scripts/lib_session.sh; под швом — прямой путь.
if [ -n "${ORCH_SESS_DIR:-}" ]; then
  SESS_DIR="$ORCH_SESS_DIR"
else
  SESS_DIR=""
fi

# ROOT резолвится по месту скрипта (Н-85).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }

command -v git >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# Подключение общей библиотеки сессии (контракт 080, инв. 13): источник
# `current_session_dir` / `live_subagents_in`. Bootstrap-защита — прецедент
# freeze_contract.sh / mint_line.sh. Библиотека лежит рядом с субъектом
# (`scripts/lib_session.sh`).
#
# Контракт 088, инв. И-1: дом журналов — поле 6 `getent passwd "$(id -un)"`,
# НЕ `$HOME` сессии. Под omp `HOME` перенаправлен в каталог зоны
# (`/home/harness/.local/state/dev-harness-sessions/<zone>/zones/dev`), и
# `ORCH_SESS_GLOB` по умолчанию (от `$HOME` в lib_session.sh) указывает в
# пустой каталог → дверь видит «нет сессий». Решение — подключить
# lib_session.sh при `HOME` = дом из passwd (тот же источник, что и
# `UHOME` в ops/server/root/orch-peak:18) — тогда умолчание
# `ORCH_SESS_GLOB` строится от правильного корня. Швы 080
# (`ORCH_SESS_DIR`, `ORCH_SESS_GLOB`) — заданные переменные окружения
# имеют приоритет (контракт 080, инв. 4): если оба пусты, берём дом
# из passwd. Пустой ответ `getent` (нет записи пользователя) →
# `NOT_IMPLEMENTED`, маркер НЕ ставится (fail-closed rc 2).
if [ -z "${ORCH_SESS_GLOB:-}" ] && [ -z "${ORCH_SESS_DIR:-}" ]; then
  _orch_uh="$(getent passwd "$(id -un)" | cut -d: -f6)"
  if [ -z "$_orch_uh" ]; then
    printf 'NOT_IMPLEMENTED: getent passwd не дал дома\n' >&2
    exit 2
  fi
  # Контракт 088, круг 5, Б-3/D1-general: экранируем glob-метасимволы
  # `[][\*?\\` в ДОМЕ из passwd ПЕРЕД подстановкой в `ORCH_SESS_GLOB` —
  # иначе bash трактует их как glob-метасимволы (D7: `[*` в имени каталога
  # развернёт все файлы). Подстановка bash `${var//pattern/\\&}` префикс-
  # экранирует каждый символ `\` обратным слэшем (буквальный `\` →
  # `\\`, остальные → `\<символ>`). Слово/TAB в ДОМЕ не трогаем здесь —
  # они гасятся `IFS=$'\n'` вокруг вызова `current_session_dir` ниже.
  # Граница конформности: `[x]`-каталог в САМОМ шве `ORCH_SESS_GLOB`
  # (явно задан пользователем без экранирования) — неконформный ввод,
  # экранировать его не обязаны (только путь из `getent passwd`).
  _orch_uh_glob="${_orch_uh//[][\*?\\]/\\&}"
  if [ -f "$ROOT/scripts/lib_session.sh" ]; then
    # shellcheck disable=SC1091
    HOME="$_orch_uh_glob" . "$ROOT/scripts/lib_session.sh"
  fi
  unset _orch_uh_glob
else
  if [ -f "$ROOT/scripts/lib_session.sh" ]; then
    # shellcheck disable=SC1091
    . "$ROOT/scripts/lib_session.sh"
  fi
fi
# Фолбэк (ЗОНА 080 — implementer, не architect): если scripts/lib_session.sh
# не подгружен (исторический toy-мир 072, неполный sandbox), дверь НЕ
# должна падать с «command not found». Минимальная заглушка возвращает
# «нет субагентов» (rc 0, пусто) — никаких гарантий безопасности, это
# совместимость с тестовой инфраструктурой, а не защита. На станции
# scripts/lib_session.sh всегда рядом (lib_session.sh — ЕДИНСТВЕННЫЙ
# источник `current_session_dir` / `live_subagents_in`, инв. 13).
if ! declare -F current_session_dir >/dev/null 2>&1; then
  current_session_dir() { return 0; }
fi
if ! declare -F live_subagents_in >/dev/null 2>&1; then
  live_subagents_in() { return 0; }
fi
unset _orch_uh

# ── Разбор аргументов двери (контракт 080, инв. 1) ────────────────────────
# Приоритет: (а1) GIT_AUTHOR_NAME → (а2) GIT_COMMITTER_NAME → (а3) --as <имя>.
# Грамматика `--as` (контракт 080, инв. 1, дословно): ровно один
# позиционный аргумент после `--as`; значение — непустая строка
# печатных символов без whitespace/control; значение НЕ должно
# само начинаться с `--` (иначе это второй флаг, а не значение);
# после `--as` в argv не должно быть других позиционных аргументов.
# Отказы (именованные, rc 1, маркер НЕ ставится):
#   * `--as` без значения или со значением из whitespace/control →
#     «identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as»
#     (тот же маркер, что и при пустых env/--as);
#   * `--as --as` (явный или замаскированный значением-флагом) или
#     `--as foo --as bar` → «ОТКАЗ: --as задан дважды»;
#   * посторонние позиционные аргументы в argv → тот же маркер
#     «identity двери не определена» ДО выбора IDENTITY.
AS_COUNT=0
AS_VAL=""
ARGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --as)
      # Случай «--as задан дважды» (адверсарий 080-v2 I1): явный повтор
      # (`--as foo --as`, `--as --as`) И замаскированный (значение после
      # `--as` само начинается с `--`) сводятся в одну ветвь — оба
      # означают, что синтаксический разбор встретил второй `--as` до
      # завершения первого.
      if [ "$AS_COUNT" -ge 1 ] || [ "${2:-}" = "--as" ]; then
        printf 'ОТКАЗ: --as задан дважды\n' >&2
        exit 1
      fi
      AS_COUNT=1
      shift
      # После shift: $1 — кандидат на значение.
      # * $1 пуст (argv закончился) → значение отсутствует.
      # * $1 само начинается с `--` (например `--as --as`, `--as -x`) →
      #   это второй флаг, не значение — общий случай «--as задан дважды».
      if [ -z "${1:-}" ]; then
        printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
        exit 1
      fi
      if [ "${1#--}" != "$1" ]; then
        printf 'ОТКАЗ: --as задан дважды\n' >&2
        exit 1
      fi
      AS_VAL="$1"
      # Грамматика значения: только печатные символы без
      # whitespace/control (контракт 080, инв. 1: «содержит ошибку
      # грамматики — пробелы, непечатные символы, пустая строка
      # после --as → именованный отказ»). В argv пробелов быть не
      # может (bash разбивает), но \t / \r / управляющие могут
      # прийти через нестандартные источники (env, eval), плюс
      # Unicode-whitespace в обход C-локальных POSIX-классов
      # ([[:space:]] в bash 5.2 ловит ТОЛЬКО ASCII whitespace;
      # NBSP U+00A0 и ZWSP U+200B проходят — адверсарий 080-v3 I2).
      # Проверка через PCRE: `\p{Z}` (Unicode space separators — ASCII
      # space и NBSP) + `\p{Cc}` (Unicode control — ASCII C0/C1 плюс
      # Unicode control code points, покрывает NBSP-окружение и
      # шим-класс). `\s` НЕ годится: PCRE2 по умолчанию НЕ Unicode-
      # аварен и матчит только ASCII whitespace; `\p{Z}|\p{Cc}`
      # покрывает ASCII whitespace, ASCII control, NBSP, ZWSP и любые
      # Unicode whitespace/control code points (адверсарий 080-v3 I2,
      # круг 4 — замена `\p{Cf}|[\x00-\x1f\x7f]` на `\p{Cc}` без
      # потери покрытия: \p{Cc} ⊇ [\x00-\x1f\x7f] + Unicode Cc).
      #
      # ДЕТЕРМИНИРОВАННАЯ канарейка grep -P (адверсарий 080-v4 I1):
      # отказ инструмента (rc 127 — `grep -P` сломан/недоступен, или
      # rc 1/пустой вывод — частичная заглушка вроде pi-uu-grep)
      # НЕ должен выглядеть «запрещённых code point нет». Перед
      # проверкой значения двери убеждаемся, что grep -P корректно
      # различает «есть запрещённый code point» (rc 0) и «нет» (rc 1)
      # на детерминированных входах. Если любой запуск дал не
      # ожидаемый rc — fail-closed отказ «identity двери не определена»
      # БЕЗ передачи AS_VAL дальше (маркер не ставится).
      # Канарейка проверяет ТОТ ЖЕ предикат, что и разбор значения,
      # на каждом его классе: Z (space), Cc (control) и Cf (format).
      # Иначе shim мог бы честно ответить на старый `\p{Z}`-контроль,
      # но превратить рабочий составной предикат в ложное «не найдено».
      grammar_re='\p{Z}|\p{Cc}|\p{Cf}'
      printf 'a b' | grep -P -q "$grammar_re" 2>/dev/null; rc_z=$?
      printf 'a\001b' | grep -P -q "$grammar_re" 2>/dev/null; rc_cc=$?
      printf 'a\u200Bb' | grep -P -q "$grammar_re" 2>/dev/null; rc_cf=$?
      printf 'ok' | grep -P -q "$grammar_re" 2>/dev/null; rc_neg=$?
      if [ "$rc_z" -ne 0 ] || [ "$rc_cc" -ne 0 ] || [ "$rc_cf" -ne 0 ] || [ "$rc_neg" -ne 1 ]; then
        printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
        exit 1
      fi
      printf '%s' "$AS_VAL" | grep -P -q "$grammar_re" 2>/dev/null; rc_value=$?
      case "$rc_value" in
        0)
          printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
          exit 1
          ;;
        1) ;;
        *)
          printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
          exit 1
          ;;
      esac
      shift
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done
# После цикла: оставшиеся нераспознанные позиционные аргументы —
# та же грамматическая ошибка формы (контракт 080, инв. 1: ровно
# один позиционный аргумент после `--as`). Например, `--as
# architect ignored` разбирается как `--as architect` + лишний
# позиционный `ignored`; argv не пуст → именованный отказ тем же
# маркером «identity двери не определена» ДО выбора IDENTITY.
if [ "${#ARGS[@]}" -ne 0 ]; then
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
fi

# ── Identity: env > --as (инв. 1, ПИННУТ порядок) ──────────────────────────
# Источник identity — ТОЛЬКО env (GIT_AUTHOR_NAME / GIT_COMMITTER_NAME)
# или явный --as; `.git/config user.name` НЕ читается (предмет (а) 080:
# весь предмет 080 исключает file-config как источник identity; Н-56).
# Пустая IDENTITY при пустых env/--as остаётся пустой и падает в
# существующий ниже `if [ -z "$IDENTITY" ]` именованный отказ.
IDENTITY=""
if [ -n "${GIT_AUTHOR_NAME:-}" ]; then
  IDENTITY="${GIT_AUTHOR_NAME}"
elif [ -n "${GIT_COMMITTER_NAME:-}" ]; then
  IDENTITY="${GIT_COMMITTER_NAME}"
elif [ -n "$AS_VAL" ]; then
  IDENTITY="$AS_VAL"
fi
if [ -z "$IDENTITY" ]; then
  printf 'identity двери не определена: ни env GIT_AUTHOR_NAME/GIT_COMMITTER_NAME, ни --as\n' >&2
  exit 1
fi

# ── санитизация репозитория ──────────────────────────────────────────────────
g rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
g rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }
g rev-parse --verify origin/main >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет origin/main\n' >&2; exit 2; }
[ -f "$ROOT/HANDOFF.md" ] \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }

# ВСЕ git-вызовы — с -C; GIT_CONFIG снят; sanity-gate выше.

# ── (1) живые субагенты — отказ при свежем .jsonl (контракт 080, инв. 3) ──
# Шов ORCH_SESS_DIR переопределяет каталог сессии (умолчание — вычисленный
# через current_session_dir). При переопределении шва дверь не читает
# умолчательный путь.
#
# Контракт 088, инв. И-2: pipefail-слепота закрывается В ДВЕРИ (lib_session.sh
# остаётся байт-в-байт, инв. И-4). Вызов `current_session_dir` — в
# подоболочке без pipefail: `set +o pipefail` гасит pipefail только в
# дочерней оболочке, родительский `set -uo pipefail` двери сохраняется.
# Без этого при листинге больше буфера канала SIGPIPE rc 141 в
# `ls -t … | head -1` обнуляет current_session_dir (измерено живьём:
# 40 файлов, 7880 байт листинга — пусто 5/5; с set +o pipefail —
# каталог найден).
#
# Контракт 088, инв. И-2′ (круг 5): `IFS=$'\n'` гасит word-split на пробелах/TAB
# в ДОМЕ из passwd внутри библиотечной `current_session_dir` (D1-general):
# её строка `f="$(ls -t $ORCH_SESS_GLOB | head -1)"` падает обратно на `$IFS`
# родителя; с дефолтной `IFS` (пробел/TAB/LF) — word-split, и каталог не находится.
# `IFS=$'\n'` ограничивает разделители только переводом строки. glob-метасимволы
# в ДОМЕ уже экранированы на этапе подключения lib_session.sh (см. выше), здесь —
# только пробелы/TAB.
if [ -z "$SESS_DIR" ]; then
  SESS_DIR="$(
    IFS=$'\n'
    set +o pipefail
    current_session_dir 2>/dev/null || true
  )"
fi
# rc 2 из live_subagents_in (stat отказал — review 080 Б-1) — честный
# «нечем проверить» НЕ молчаливый проход: пробрасываем как rc 2
# NOT_IMPLEMENTED, stderr сохраняется (НЕ 2>/dev/null) — причина
# видна вызывающему (оркестратору/человеку), и двери НЕ ставит маркер.
LIVE_NAMES="$(live_subagents_in "${SESS_DIR:-}")"; live_rc=$?
if [ "$live_rc" -eq 2 ]; then
  exit 2
fi
if [ "$live_rc" -ne 0 ]; then
  printf 'NOT_IMPLEMENTED: live_subagents_in rc=%d\n' "$live_rc" >&2
  exit 2
fi
if [ -n "$LIVE_NAMES" ]; then
  printf 'ОТКАЗ: живые субагенты: %s\n' "$LIVE_NAMES" >&2
  exit 1
fi

# ── (а) HEAD == origin/main ─────────────────────────────────────────────────
h="$(g rev-parse HEAD 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HEAD\n' >&2; exit 2; }
o="$(g rev-parse origin/main 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет origin/main\n' >&2; exit 2; }
[ "$h" = "$o" ] \
  || { printf 'ОТКАЗ: HEAD расходится с origin/main\n' >&2; exit 1; }

# ── (б) porcelain пуст ──────────────────────────────────────────────────────
[ -z "$(g status --porcelain)" ] \
  || { printf 'ОТКАЗ: porcelain непуст\n' >&2; exit 1; }

# ── (в) HANDOFF.md изменён коммитом ЭТОЙ сессии ─────────────────────────────
la="$(g log -1 --format=%an -- HANDOFF.md 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }
me="$IDENTITY"
# (в1) identity — author последнего коммита HANDOFF.md == self-identity
{ [ -n "$la" ] && [ -n "$me" ] && [ "$la" = "$me" ]; } \
  || { printf 'ОТКАЗ: HANDOFF.md изменён не этой сессией\n' >&2; exit 1; }

# Стартовый след (инвариант 11): файла нет → инициализация «сейчас»
# (инициализация НЕ вакуумна); пустой/нечитаемый → fail-closed rc 2.
if [ ! -f "$TRACE" ]; then
  mkdir -p "$(dirname "$TRACE")"
  printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" \
    && mv -f "$TRACE.tmp.$$" "$TRACE"
fi
# Инвариант 11 (адверсарий 072-r1 Б2): след обязан нести РОВНО ОДНУ
# непустую строку — лишняя строка до/после валидного ISO-8601-хвоста не
# должна судиться `tail -n 1` вместо границы сессии (мусор\n<ISO> не
# имеет права пройти как «ISO в прошлом»). Считаем непустые строки
# ВСЕГО файла; ровно одна → она и есть t_line, иначе fail-closed rc 2
# ДО `date -d` — испорченный формат не читается частично.
nonblank_n=0; t_line=""
while IFS= read -r _tl || [ -n "$_tl" ]; do
  [ -n "$_tl" ] || continue
  nonblank_n=$((nonblank_n + 1))
  t_line="$_tl"
done < "$TRACE" 2>/dev/null \
  || { printf 'NOT_IMPLEMENTED: стартовый след нечитаем\n' >&2; exit 2; }
[ "$nonblank_n" -eq 1 ] \
  || { printf 'NOT_IMPLEMENTED: стартовый след не ровно одна строка\n' >&2; exit 2; }
t_ep="$(date -d "$t_line" +%s 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: стартовый след нечитаем\n' >&2; exit 2; }
c_ep="$(g log -1 --format=%ct -- HANDOFF.md 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет HANDOFF.md\n' >&2; exit 2; }
# (в2) committer-дата > стартового следа
[ "$c_ep" -gt "$t_ep" ] \
  || { printf 'ОТКАЗ: HANDOFF.md изменён до стартового следа сессии\n' >&2; exit 1; }

# ── (г) check_no_leak --check rc 0 ──────────────────────────────────────────
dout="$(bash "$ROOT/scripts/check_no_leak.sh" --check "$ROOT" 2>&1)"; drc=$?
[ "$drc" -eq 0 ] \
  || { printf 'ОТКАЗ: детектор красен: %s\n' "$dout" >&2; exit 1; }

# ── (д) нет мусорных worktree ПОСЛЕ делегирования GC ───────────────────────
# Мусорный worktree (инвариант 4): запись git worktree list --porcelain
# НЕ основного чекаута, чья ветка НЕ refs/heads/wip/[0-9]{3}/<автор>
# (включая detached/bare). GC СВОЕГО корня расширением удаляет чистые
# приземлённые мусорные; грязные/неприземлённые — называются GC.
gc_rc=0
bash "$ROOT/scripts/gc_agent_branches.sh" --root "$ROOT" >/dev/null 2>&1 || gc_rc=$?
# rc GC нас не интересует — список worktree ПЕРЕСНИМАЕТСЯ после GC;
# грязные/неприземлённые GC мог назвать, наш гейт — список ПОСЛЕ GC.

found_garbage=0
while IFS='|' read -r wt_path wt_head wt_branch; do
  [ -n "$wt_path" ] || continue
  [ "$wt_path" = "$ROOT" ] && continue
  case "$wt_branch" in
    refs/heads/wip/[0-9][0-9][0-9]/*) continue ;;
  esac
  if [ "$found_garbage" -eq 0 ]; then
    printf 'ОТКАЗ: мусорный worktree: %s\n' "$wt_path" >&2
    found_garbage=1
  fi
done < <(g worktree list --porcelain | awk '
  /^worktree / { if (p != "") print p "|" h "|" b; p=substr($0,10); h=""; b="detached" }
  /^HEAD /     { h=substr($0,6) }
  /^branch /   { b=substr($0,8) }
  /^bare$/     { b="bare" }
  END { if (p != "") print p "|" h "|" b; }
')
[ "$found_garbage" -eq 0 ] || exit 1

# ── ВСЁ ЗЕЛЁНОЕ: атомарная перезапись следа + постановка маркера ────────────
# Инвариант 3, фраза 2 (072-r2 Б5): уже стоящий (чужой) маркер дверь НЕ
# удаляет — не её состояние. Запоминаем существование и байты ДО своей
# постановки, чтобы при отказе записи следа вернуть ровно то, что было.
prev_marker_existed=0
prev_marker_bytes=""
if [ -e "$MARKER" ]; then
  prev_marker_existed=1
  prev_marker_bytes="$(cat "$MARKER" 2>/dev/null || printf '')"
fi
mkdir -p "$(dirname "$MARKER")"
: > "$MARKER.tmp.$$" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }
mv -f "$MARKER.tmp.$$" "$MARKER" \
  || { printf 'ОТКАЗ: запись маркера не удалась: %s\n' "$MARKER" >&2; exit 1; }

mkdir -p "$(dirname "$TRACE")"
if ! ( printf '%s\n' "$(date -Is)" > "$TRACE.tmp.$$" \
       && mv -f "$TRACE.tmp.$$" "$TRACE" ); then
  # Откат ТОЛЬКО маркера этого прогона: чужой стоявший — байт-в-байт.
  if [ "$prev_marker_existed" -eq 0 ]; then
    rm -f "$MARKER" 2>/dev/null || true
  else
    printf '%s' "$prev_marker_bytes" > "$MARKER" 2>/dev/null || :
  fi
  printf 'ОТКАЗ: запись следа не удалась: %s\n' "$TRACE" >&2
  exit 1
fi

printf 'ПЕРЕЗАПУСК: маркер поставлен\n'
exit 0