#!/usr/bin/env bash
# Барьер GC (контракт 016, срез 4): снос СЛИТЫХ wip/*; зависшие — СОХРАННЫ, поимённый СПИСОК.
# Расширение TMP-РЕАП (контракт 026): реап ./tmp по done-тегу / возрасту / активному-выживает.
#
# Зачем: без явного GC ветки wip/* накапливаются вместе с worktree; каждая несбитая — потенциальный
# «потерянный заказ» с двумя интерпретациями (молчание vs разрешение). Симметрия Н-59: молчание
# не равно разрешению, поэтому зависшие ВЫГОВАРИВАЮТСЯ владельцу списком, а не удаляются по
# умолчанию. Удаление зависшей — отдельное слово владельца; вход с флагом силы в GC отсутствует
# по построению.
#
# ЧТО СНОСИТСЯ: wip/* ветки, у которых tip СЛИТ в main (merge-commit с HEAD, ИЛИ fast-forward —
# оба варианта равны: ref wip/* достижим из HEAD). Снос = удаление ref + удаление связанного
# worktree (если есть).
#
# ЧТО НЕ СНОСИТСЯ: wip/* с tip, не достижимым из HEAD. Такие остаются В РЕЕСТРЕ и печатаются
# поимённо в stderr (СПИСОК) с их OID. Цель OID ДОЛЖНА ОСТАТЬСЯ НЕИЗМЕННОЙ после GC —
# любая смена цели ref равносильна сносу и красна одной сверкой. Мера проверки — `oid_before`,
# зафиксированный ДО GC; rev-parse после возвращает ТОТ ЖЕ OID (И-6).
#
# SWEEP ОСТАТКОВ: python3 lstat (Н-60: GNU `find -type p` слеп систематически к fifo и
# симлинкам). Пустая выборка на заявленное наличие — красное, не зелёное: ЗАЯВЛЕННОЕ
# НАЛИЧИЕ приезжает входом `--expect-kept <ref>[=<oid>]` (повторяемый). Без объявленного
# входа сверять нечего — GC сравнивал бы два своих же снимка, а они по построению не
# расходятся (снимаются одним процессом, между ними мутирует только сам GC и только
# удалением слитых): такая самосверка красной не бывает и барьером не является.
#
# TMP-РЕАП (контракт 026, слой 1 Н-97): реап скратча in-tree `./tmp` при close-out.
# Источник кандидатов — только untracked: `git ls-files --others -z -- tmp/` БЕЗ
# `--exclude-standard` (тот же, что нога-2 детектора 024; tmp/ в .gitignore делает источник
# с --exclude-standard слепым по построению). Кандидат — ВЕРХНЕУРОВНЕВАЯ запись: путь
# сворачивается до первого компонента после `tmp/`. Само `tmp/` никогда не удаляется.
# tracked не кандидат НИКОГДА (двумя мерами: источник не перечисляет tracked; перед каждым
# удалением контроль `git ls-files -- tmp/<запись>` — непустой под untracked-кандидатом =
# «смешанный вход» rc 1, запись ЦЕЛА, fail-closed). Критерий реапа кандидата:
#   (а) done-тег — имя содержит NNN (`0[0-9][0-9]`) И в репозитории есть тег
#       `done/contracts/NNN/*` → реап, С ГРАЦИЕЙ Н-107 (контракт 030, детали — блок TMP-РЕАП);
#   (б) возраст — имя без распознанного NNN И mtime записи старше N дней (по умолчанию 7;
#       флаг `--tmp-reap-age N`). mtime — lstat САМОЙ записи через python3 (Н-60).
#       Возраст — ВЕЩЕСТВЕННОЕ сравнение секунд `(now - mtime) > N*86400` (вердикт к1: int-усечение
#       суток теряло кандидатов на границе `(N, N+1)`; порог передаётся в python, не зашит).
# NNN-извлечение ПЕРЕКРЫВАЮЩЕЕСЯ (python re.finditer с lookahead `(?=(0[0-9][0-9]))`): `x0026`
# даёт И `002`, И `026` — иначе активный `026` терялся за неперекрывающимся `grep -oE`.
# Кандидат-лист NUL-РАЗДЕЛЁННЫЙ от `git ls-files --others -z` до конца обработки: newline-конверсия
# `tr '\0' '\n'` ломала LF-имена (`tmp/$'old\n021'/` распадалось на ложные строки, исходная запись
# переживала реап). Поле `rel` передаётся NUL-разделёнными raw-байтами между python и bash
# (`read -d ''` дважды: путь и метаданные), без command substitution: `$()` сжимает хвостовые LF,
# и допустимые имена `tmp/done021` и `tmp/$'done021\n'` коллизировали в одном транспортном
# значении (вердикт к2). Base64 в bash-части снят: инструмент не оправдан, а его отказ (rc=127)
# не нормализуется к объявленному rc 2 «NOT_IMPLEMENTED» (вердикт к2). Отказ
# источника done-тегов (`git for-each-ref refs/tags/done/contracts/`) — fail-closed rc 2
# «NOT_IMPLEMENTED» (вердикт к2: `if g for-each-ref …; then … fi` без `else` маскировал отказ
# под пустой done-набор).
# Отказ `git ls-files --others -z -- tmp/` — fail-closed rc 2 «NOT_IMPLEMENTED: git ls-files
# отказал» (вердикт к1: хвостовой `|| :` маскировал отказ под пустой успешный список).
# --tmp-reap-age валидируется ВСЕГДА, СРАЗУ при разборе флага в argv-цикле, ДО любого
# обращения к ROOT/tmp (вердикт к4 FAIL 1: валидация лежала внутри `if [ -d "$ROOT/tmp" ]`
# — отсутствующий каталог пропускал невалидное значение с rc 0 независимо от построения
# списка кандидатов). Строго ПОЛОЖИТЕЛЬНОЕ конечное число — `math.isfinite(v) and v > 0.0`
# (вердикт к4 FAIL 1: прежнее условие `v < 0` принимало 0/0.0/-0.0 — нулевой порог не
# положителен: возраст не может квалифицировать запись быстрее, чем она создана).
# Перед КАЖДЫМ удалением контроль tracked (`git ls-files -- <entry>`) fail-closed на
# отказе git: rc 2 «NOT_IMPLEMENTED», НЕ молчаливое «tracked нет» (вердикт к3: `$()`
# глушил ненулевой rc второго `ls-files` в пустой stdout, неотличимый от честного ответа
# «tracked-файлов нет» — tracked удалялся вместе с untracked без единого отказа).
# TOCTOU (вердикт к4 FAIL 2): повторный `git ls-files` НЕМЕДЛЕННО перед удалением не
# закрывает гонку — тот же check-then-act шов между отдельными внешними вызовами.
# Правильный примитив — python3 lstat ДО контроля (идентичность dev:ino записи-кандидата)
# и ВТОРОЙ lstat СЛИТО с самим актом удаления в ОДНОМ python3-процессе без exec внешнего
# `rm` (устраняет класс атаки «подставной rm подменяет запись после своего запуска, перед
# настоящим удалением» — удаляющий вызов И ЕСТЬ процесс, взявший второй lstat).
# Расхождение dev:ino между первым и вторым lstat → именованный TOCTOU rc 2, запись НЕ
# ТРОГАЕТСЯ. Остаточное окно — между os.lstat() и os.remove()/shutil.rmtree() внутри
# ОДНОГО процесса без промежуточного fork/exec: выиграть эту гонку значит подменить
# запись между двумя системными вызовами одного процесса — точность, практически
# требующая контроля планировщика ядра уровня root, а не обычного параллельного
# мутатора. Полное закрытие (эксклюзивная блокировка ./tmp поперёк ВСЕХ процессов) —
# отдельное архитектурное решение вне слоя 1 механизма, не точечный фикс.
# Распознанный NNN = есть `contracts/NNN-*.md` в дереве. NNN без файла контракта и без
# done-тега — аноним, правило возраста. NNN распознан БЕЗ done-тега = АКТИВНЫЙ контекст
# (скратч живого майлстоуна) → запись ВЫЖИВАЕТ независимо от возраста. При коллизии
# (активный и done в одном имени) — приоритет активного номера. Dry-run по умолчанию
# (каждый прогон печатает TMP-РЕАП список в stderr); удаление — ТОЛЬКО `--tmp-reap-apply`.
#
# ГРАЦИЯ Н-107 (контракт 030, симметрия ветковой грации инв. 5): чистая проверка
# «done ⇒ реап независимо от возраста» сносит СВЕЖИЙ rework-скратч, спавненный ПОСЛЕ
# close-out уже done-контракта (rework/v2/v3 по тому же NNN) — жертва гонки, не хвост
# уборки. Различитель — момент закрытия: `mtime ≤ creatordate(последнего
# done/contracts/NNN/*)` — запись ДО закрытия, остаток уборки, реапится СРАЗУ, hygiene
# 026 не тормозится; `mtime > creatordate` — запись ПОСЛЕ закрытия, кандидат rework:
# `now - mtime > --wip-grace-hours` (та же ручка, что грация пустых веток — одна
# семантика «свежесть артефакта спавна») → брошенный rework, реап; иначе — СВЕЖИЙ
# rework, ВЫЖИВАЕТ, stderr несёт строку-связку «свежий rework — ВЫЖИВАЕТ (грация
# Н-107)». Источник даты закрытия — `%(creatordate:unix)` for-each-ref (карта
# NNN → max по всем done/contracts/NNN/*): tagger date для аннотированных тегов,
# committer date подлежащего коммита для лёгких (замер: лёгкий тег даёт ПУСТОЙ
# `%(taggerdate:unix)`, но непустой `%(creatordate:unix)`; done-теги фикстур
# `_zhnets.sh` — ЛЁГКИЕ (`git tag done/contracts/NNN/1` без `-a`) — taggerdate дал бы
# фальшивый fail-closed на каждом их прогоне). Дата закрытия/mtime недоступны →
# fail-closed: запись ВЫЖИВАЕТ (симметрия reflog-ветки, инв. 3 выше).
#
# Коды возврата: 0 — слитые снесены и всё заявленное наблюдается, 1 — заявленная зависшая
# не наблюдается либо её цель сменена (наблюдаемое отклонение И-6), либо смешанный вход
# TMP-РЕАП, либо не удалось удалить TMP-РЕАП-кандидата, 2 — нечем проверить (нет git /
# не репозиторий / нет python3 для TMP-РЕАП).
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

usage() {
  cat >&2 <<USAGE
использование: gc_agent_branches.sh [--root <каталог>] [--expect-kept <ref>[=<oid>]]…
                    [--tmp-reap-apply] [--tmp-reap-age <дней>]
                    [--wip-grace-hours <часов>]

Поведение:
  * wip/* слитые в main → авто-снос (ref + worktree);
  * wip/* зависшие (tip не достижим из HEAD) → СОХРАННЫ, печатаются поимённо в stderr
    СПИСКОМ владельцу; входа с флагом силы на снос зависшей нет по построению;
  * --expect-kept <ref>[=<oid>] — ЗАЯВЛЕННОЕ НАЛИЧИЕ зависшей: после прогона ref обязан
    наблюдаться в refs/heads/wip/, а при объявленном OID — указывать на него же (И-6:
    любая смена цели равносильна сносу). Не наблюдается → rc 1;
  * TMP-РЕАП (контракт 026): dry-run по умолчанию — каждый прогон печатает в stderr
    TMP-РЕАП список кандидатов на снос из ./tmp (untracked, источник
    «git ls-files --others -z -- tmp/» без --exclude-standard, свёртка до верхнеуровневой
    записи). Удаление — ТОЛЬКО явным флагом --tmp-reap-apply; без него ничего не удаляется.
    tracked не кандидат НИКОГДА (источник не перечисляет; перед каждым удалением контроль
    «git ls-files -- tmp/<запись>» — непустой контроль под untracked-кандидатом = «смешанный
    вход» rc 1, запись ЦЕЛА, fail-closed). Критерий реапа: done-тег NNN в имени, либо имя
    без распознанного NNN и mtime записи старше N дней (по умолчанию 7; --tmp-reap-age).
    NNN распознан, если есть contracts/NNN-*.md в дереве; NNN с done-тегом — done, С
    ГРАЦИЕЙ Н-107 (контракт 030): запись ДО закрытия (mtime ≤ creatordate последнего
    done/contracts/NNN/*) реапится сразу; ПОСЛЕ закрытия — реапится, если старше
    --wip-grace-hours (брошенный rework), иначе ВЫЖИВАЕТ (свежий rework, stderr несёт
    «грация Н-107»); дата закрытия/mtime недоступны → fail-closed, запись ВЫЖИВАЕТ. NNN
    распознан без done-тега — АКТИВНЫЙ контекст → запись ВЫЖИВАЕТ независимо от возраста
    (приоритет активного номера над done в одном имени). --tmp-reap-age N — порог возраста
    в днях для правила (б); валидируется СРАЗУ при разборе флага (до обращения к tmp/) как
    СТРОГО ПОЛОЖИТЕЛЬНОЕ конечное число: NaN/inf/0/отрицательное → rc 2 «NOT_IMPLEMENTED»
    (вердикт к4). Подмена untracked→tracked записи между контролем и удалением — именованный
    TOCTOU rc 2 (вердикт к4, lstat dev:ino до/после контроля, см. коды возврата).
  * --wip-grace-hours <часов> — ОБЩАЯ ручка (контракт 030 Н-107, одна семантика «свежесть
    артефакта спавна») для грации пустых слитых wip/* И для done-NNN TMP-РЕАП: ветка
    переживает реап, если её reflog содержит ровно одно событие (создание) И возраст
    (mtime reflog-файла) меньше N часов. Дефолт 24. Строго положительное конечное число,
    валидируется при разборе argv (как --tmp-reap-age). НЕпустые (≥2 события reflog)
    достижимые сносятся безусловно — грация их не задерживает. Reflog-файл недоступен →
    fail-closed (ветка выживает, stderr называет «reflog»). Ветка + причина выживания
    печатаются в stderr одной связкой.
  * sweep остатков worktrees — python3-lstat (Н-60), fifo/сломанные симлинки подсвечиваются.

Коды возврата: 0 — порядок; 1 — заявленная зависшая не наблюдается или сменена (И-6),
либо смешанный вход TMP-РЕАП, либо не удалось удалить TMP-РЕАП-кандидата;
2 — нечем проверить (нет git / не репозиторий / нет python3 для TMP-РЕАП).
USAGE
  exit 1
}

root_arg=""
expect_kept=()
tmp_reap_apply=0
tmp_reap_age=7
tmp_reap_age_given=0
wip_grace_hours=24
wip_grace_hours_given=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root) root_arg="${2:?}"; shift 2 ;;
    --expect-kept) expect_kept+=("${2:?}"); shift 2 ;;
    --tmp-reap-apply) tmp_reap_apply=1; shift ;;
    --tmp-reap-age) tmp_reap_age="${2:?}"; tmp_reap_age_given=1; shift 2 ;;
    --wip-grace-hours) wip_grace_hours="${2:?}"; wip_grace_hours_given=1; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'gc_agent_branches: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

# --tmp-reap-age валидируется ВСЕГДА, СРАЗУ при разборе флага — ДО обращения к ROOT/tmp
# (вердикт к4 FAIL 1: прежняя валидация лежала внутри `if [ -d "$ROOT/tmp" ]`, отсутствующий
# каталог пропускал невалидное значение с rc 0). Значение по умолчанию (7) — доверенный
# литерал, python3 не требуется, если флаг не передан явно. Строго ПОЛОЖИТЕЛЬНОЕ конечное
# число (вердикт к4 FAIL 1: `v < 0` принимало 0/0.0/-0.0 — нулевой порог не положителен).
if [ "$tmp_reap_age_given" -eq 1 ]; then
  command -v python3 >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: нет python3 для валидации --tmp-reap-age (Н-60)\n' >&2; exit 2; }
  # Runtime-проверка python3 (вердикт к5): PATH-резолв (`command -v`) НЕ гарантирует
  # что бинарь реально запускается — отравленный PATH-python3 печатает мусор и
  # выходит rc 127, и под `set -e` это пробрасывается СЫРЫМ rc 127 вместо
  # объявленного rc 2 «NOT_IMPLEMENTED». Прецедент к2 (base64): инструмент без
  # runtime-проверки маскирует отказ под «не найдено/пусто». Здесь — ДО
  # python3-вызова валидации ниже.
  if ! python3 -c 'import sys; sys.exit(0)' >/dev/null 2>&1; then
    printf 'NOT_IMPLEMENTED: python3 найден, но не запускается (Н-60, вердикт к5)\n' >&2
    exit 2
  fi
  if ! python3 -c '
import sys, math
try:
    v = float(sys.argv[1])
except ValueError:
    sys.exit(2)
sys.exit(0 if (math.isfinite(v) and v > 0.0) else 2)
' "$tmp_reap_age" 2>/dev/null; then
    printf 'NOT_IMPLEMENTED: --tmp-reap-age не положительное конечное число: %s\n' "$tmp_reap_age" >&2
    exit 2
  fi
fi

# --wip-grace-hours валидируется СРАЗУ при разборе флага — ДО обращения к ROOT (симметрия
# --tmp-reap-age, вердикт 026 к4). Дефолт (24) — доверенный литерал; валидация только при
# явной передаче. Строго положительное конечное число: 0 / NaN / inf / отрицательное → rc 1
# «положительное» (вердикт 030 Н-107; контракт называет 0/NaN/inf неположительными).
if [ "$wip_grace_hours_given" -eq 1 ]; then
  command -v python3 >/dev/null 2>&1     || { printf 'NOT_IMPLEMENTED: нет python3 для валидации --wip-grace-hours (Н-60)
' >&2; exit 2; }
  if ! python3 -c '
import sys, math
try:
    v = float(sys.argv[1])
except ValueError:
    sys.exit(1)
sys.exit(0 if (math.isfinite(v) and v > 0.0) else 1)
' "$wip_grace_hours" 2>/dev/null; then
    printf 'ОТКАЗ: --wip-grace-hours должно быть положительное конечное число: %s
' "$wip_grace_hours" >&2
    exit 1
  fi
fi

if [ -z "$root_arg" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

TMPDIR_WORK="${TMPDIR:-/tmp}"
TMP="$(mktemp -d "$TMPDIR_WORK/gc-agent-branches.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Снимок refs/heads/wip/ ДО GC.
g for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | sort > "$TMP/wip_before" || : > "$TMP/wip_before"

# Карта oid_before ДЛЯ КАЖДОЙ wip/* ветки (И-6). Если ветка сменит цель после GC —
# rev-parse даст ДРУГОЙ OID → отказ rc 1. Если ветка пропала — нормально (слитая).
declare -A oid_before=()
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  oid="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  [ -n "$oid" ] && oid_before["$ref"]="$oid"
done < "$TMP/wip_before"

# СЛИТЫЕ wip/* → удаление ref + worktree С ГРАЦИЕЙ ДЛЯ ПУСТЫХ (контракт 030 Н-107).
# Слитой считается wip/*, чей tip ДОСТИЖИМ из HEAD (merge- или fast-forward). Реестр
# refs/heads/wip/* — единственный источник истины о СЛИТОСТИ.
# Источник истины о РАБОТЕ на ветке — reflog (топология не различает слитую с работой от
# пустой: merge-base(tip,HEAD)==tip для обеих; инв. 5 контракта 026, совет круга 1 :79).
# Меры:
#   * «пуста» := reflog содержит РОВНО одно событие (создание). ≥2 событий — с работой.
#   * возраст пустой := mtime .git/logs/refs/heads/<ветка> через python3 lstat (та же мера,
#     что инв. 5 контракта 026; touch-управляемый фикстурой).
#   * reflog недоступен → fail-closed: ветка НЕ классифицируема → выживает, stderr «reflog».
#   * НЕпустые достижимые сносятся НЕЗАВИСИМО от возраста (как раньше; грация их не тормозит).
#   * stderr-канал связывает ветку и причину одной строкой с ключевым словом «граци» или
#     «reflog». Пиннуты: имя ветки, слово-маркер, КАНАЛ stderr, однострочная связь. Полная
#     фраза — свобода реализации (потеря канала и связи «эта ветка — эта причина» красна).
removed=0
kept=0
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  tip="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  [ -n "$tip" ] || continue
  if ! g merge-base --is-ancestor "$tip" HEAD 2>/dev/null; then
    kept=$((kept + 1))
    continue
  fi
  branch="${ref#refs/heads/}"
  reflog_file="$ROOT/.git/logs/refs/heads/$branch"
  if [ ! -f "$reflog_file" ] || [ ! -r "$reflog_file" ]; then
    # reflog недоступен — fail-closed (инв. 3).
    kept=$((kept + 1))
    printf 'wip/%s — reflog недоступен, выживает (грация не применима, fail-closed)\n' "$branch" >&2
    continue
  fi
  reflog_events="$(wc -l < "$reflog_file" 2>/dev/null || printf 0)"
  if [ "$reflog_events" -lt 2 ]; then
    # ПУСТАЯ: ≥ грации → снести; < грации → выживает с причиной «граци».
    age_secs="$(python3 -c '
import os, sys, time
try:
    st = os.lstat(sys.argv[1])
    print(int(time.time() - st.st_mtime))
except OSError:
    print(-1)
' "$reflog_file" 2>/dev/null || printf -- -1)"
    if [ "$age_secs" -lt 0 ]; then
      # lstat отказал — fail-closed (источник возраста пропал между reflog-существованием и lstat).
      kept=$((kept + 1))
      printf 'wip/%s — reflog возраст недоступен, выживает (грация не применима)\n' "$branch" >&2
      continue
    fi
    threshold_secs="$(python3 -c "print(int(float('$wip_grace_hours') * 3600))")"
    if [ "$age_secs" -lt "$threshold_secs" ]; then
      kept=$((kept + 1))
      printf 'wip/%s — пустая, %s < грации %sч, выживает (грация Н-107)\n' "$branch" "${age_secs}s" "$wip_grace_hours" >&2
      continue
    fi
    # старше грации — снести как падающую.
    wt="$(g worktree list --porcelain 2>/dev/null \
          | awk -v br="$ref" '
              /^worktree / { wt = $2; next }
              /^branch /   { if ($2 == br) { print wt; exit } }
            ')"
    if [ -n "$wt" ] && [ "$wt" != "$ROOT" ] && [ -d "$wt" ]; then
      g worktree remove --force "$wt" 2>/dev/null || true
    fi
    g branch -D "$branch" 2>/dev/null && removed=$((removed + 1)) || true
    continue
  fi
  # НЕпустая (≥2 событий) — снести как раньше (close-out без тормозов, инв. 5).
  wt="$(g worktree list --porcelain 2>/dev/null \
        | awk -v br="$ref" '
            /^worktree / { wt = $2; next }
            /^branch /   { if ($2 == br) { print wt; exit } }
          ')"
  if [ -n "$wt" ] && [ "$wt" != "$ROOT" ] && [ -d "$wt" ]; then
    g worktree remove --force "$wt" 2>/dev/null || true
  fi
  g branch -D "$branch" 2>/dev/null && removed=$((removed + 1)) || true
done < "$TMP/wip_before"

# Снимок refs/heads/wip/ ПОСЛЕ GC.
g for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | sort > "$TMP/wip_after" || : > "$TMP/wip_after"

# СВЕРКА OID (И-6): каждая wip/*, что БЫЛА и ОСТАЛАСЬ, даёт тот же OID. Смена цели — красное.
fails=0
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  oid_now="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  oid_was="${oid_before[$ref]:-}"
  if [ -z "$oid_was" ]; then
    printf 'FAIL: %s — OID нечитаем до GC, читаем после (oid=%s) — расхождение наблюдения\n' \
      "$ref" "$oid_now" >&2
    fails=$((fails + 1))
    continue
  fi
  if [ -z "$oid_now" ]; then
    printf 'FAIL: %s — ветка исчезла из refs/heads/wip/ после GC (oid_before=%s)\n' \
      "$ref" "$oid_was" >&2
    fails=$((fails + 1))
    continue
  fi
  if [ "$oid_now" != "$oid_was" ]; then
    printf 'FAIL: %s — цель сменена (oid_before=%s, oid_after=%s) — перевод ref красный\n' \
      "$ref" "$oid_was" "$oid_now" >&2
    fails=$((fails + 1))
  fi
done < "$TMP/wip_after"

# СПИСОК зависших — печатается ВЛАДЕЛЬЦУ поимённо (Н-59: молчание ≠ разрешение).
if [ -s "$TMP/wip_after" ]; then
  printf 'ЗАВИСШИЕ ВЕТКИ (требуется слово владельца для сноса):\n' >&2
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    oid_now="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || echo "?")"
    printf '  %s  %s\n' "$ref" "$oid_now" >&2
  done < "$TMP/wip_after"
else
  printf 'ЗАВИСШИХ ВЕТОК НЕТ\n' >&2
fi

# ЗАЯВЛЕННОЕ НАЛИЧИЕ (контракт, срез 4: «пустая выборка на заявленное наличие — красное,
# не зелёное»). Сверка идёт ПОСЛЕ печати СПИСКА: владелец обязан увидеть, что именно
# наблюдается, прежде чем читать отказ. Заявка — результат-форма: ref обязан наблюдаться,
# а при объявленном OID — указывать на него же; способ, которым цель сменилась, не
# перечисляется (любая смена равносильна сносу, И-6).
for e in "${expect_kept[@]:-}"; do
  [ -n "$e" ] || continue
  want_ref="${e%%=*}"
  want_oid=""
  case "$e" in *=*) want_oid="${e#*=}" ;; esac
  case "$want_ref" in refs/heads/*) ;; *) want_ref="refs/heads/$want_ref" ;; esac
  if ! grep -qxF -- "$want_ref" "$TMP/wip_after"; then
    printf 'ОТКАЗ: заявленная зависшая ветка не наблюдается после GC: %s — пустая выборка на заявленное наличие\n' \
      "$want_ref" >&2
    fails=$((fails + 1))
    continue
  fi
  oid_now="$(g rev-parse --verify --quiet "$want_ref" 2>/dev/null || true)"
  if [ -n "$want_oid" ] && [ "$oid_now" != "$want_oid" ]; then
    printf 'ОТКАЗ: цель заявленной зависшей сменена: %s (заявлено %s, наблюдается %s) — смена цели равносильна сносу (И-6)\n' \
      "$want_ref" "$want_oid" "$oid_now" >&2
    fails=$((fails + 1))
  fi
done

# SWEEP остатков worktrees — python3 lstat (Н-60). Ищем забытые fifo / битые симлинки /
# каталоги в префиксе worktrees — ${TMPDIR:-/tmp}/dev-harness-worktrees/<hash8>.
hash8="$(printf '%s' "$ROOT" | sha256sum | cut -c1-8)"
WORKTREE_BASE="${TMPDIR:-/tmp}/dev-harness-worktrees/$hash8"
export WORKTREE_BASE

if [ -d "$WORKTREE_BASE" ]; then
  python3 - "$WORKTREE_BASE" <<'PYEOF' >&2 || true
import os, sys, stat
base = sys.argv[1]
for entry in os.scandir(base):
    try:
        st = entry.stat(follow_symlinks=False)
    except OSError:
        continue
    if stat.S_ISLNK(st.st_mode):
        target = os.readlink(entry.path)
        if not os.path.exists(entry.path):
            print(f"gc: остаток — битая символическая ссылка: {entry.path} → {target}")
        else:
            print(f"gc: остаток — символическая ссылка: {entry.path} → {target}")
    elif stat.S_ISFIFO(st.st_mode):
        print(f"gc: остаток — fifo: {entry.path}")
    elif stat.S_ISREG(st.st_mode):
        print(f"gc: остаток — обычный файл: {entry.path}")
    elif stat.S_ISDIR(st.st_mode):
        # Подсчёт вложенных .git — worktree ли это?
        if os.path.isdir(os.path.join(entry.path, '.git')):
            print(f"gc: остаток — worktree-каталог: {entry.path}")
PYEOF
fi

# ─── TMP-РЕАП (контракт 026, слой 1 Н-97) ────────────────────────────────────
# Реап скратча in-tree ./tmp при close-out. Источник — untracked (не перечисляет tracked);
# свёртка до верхнеуровневой записи (первый компонент после tmp/). tracked не кандидат
# НИКОГДА (мера (а) — источник; мера (б) — контроль перед удалением). Dry-run по умолчанию
# (каждый прогон печатает список в stderr); удаление ТОЛЬКО --tmp-reap-apply.
reap_total=0
if [ -d "$ROOT/tmp" ]; then
  command -v python3 >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: нет python3 для TMP-РЕАП (Н-60)\n' >&2; exit 2; }
  # Runtime-проверка python3 (вердикт к5): голые вызовы ниже (candidate-folding
  # строки 345+, lstat 410+) сидят под `set -e`, и отравленный PATH-python3
  # (rc 127) пробрасывается СЫРЫМ вместо объявленного rc 2 «NOT_IMPLEMENTED».
  # Прецедент к2 (base64): инструмент без runtime-проверки — обход. Проверка
  # ДО основного пути, не внутри.
  if ! python3 -c 'import sys; sys.exit(0)' >/dev/null 2>&1; then
    printf 'NOT_IMPLEMENTED: python3 найден, но не запускается (Н-60, вердикт к5)\n' >&2
    exit 2
  fi

  # 0. --tmp-reap-age уже провалидирован СРАЗУ при разборе флага (вердикт к4 FAIL 1) —
  #    ДО этой точки и НЕЗАВИСИМО от существования $ROOT/tmp. Повторной валидации здесь
  #    не требуется.
  # 1. Источник кандидатов: untracked в tmp/, свёртка до верхнеуровневой записи.
  #    Без --exclude-standard — tmp/ в .gitignore не должен делать источник слепым (024 нога-2).
  #    awk сворачивает tmp/X/Y/Z → tmp/X; файлы на верхнем уровне tmp/X → tmp/X (НЕ в tmp,
  #    иначе риск удалить сам tmp/).
  if ! g ls-files --others -z -- 'tmp/' > "$TMP/reap_ls_raw" 2>/dev/null; then
    ls_rc=$?
    printf 'NOT_IMPLEMENTED: git ls-files отказал (rc=%d)\n' "$ls_rc" >&2
    exit 2
  fi

  # Сводка кандидатов в NUL-разделённый файл: untracked-источник → свёртка до
  # верхнеуровневой записи (tmp/X/Y/Z → tmp/X). Python читает NUL-байты и
  # кладёт NUL-байты между записями — никакой newline-конверсии.
  python3 - "$TMP/reap_ls_raw" > "$TMP/reap_candidates" <<'PYEOF'
import sys
try:
    with open(sys.argv[1], 'rb') as fh:
        data = fh.read()
except OSError as ex:
    print(f"NOT_IMPLEMENTED: ls-files-сырьё не читается: {ex}", file=sys.stderr)
    sys.exit(2)

parts = data.split(b'\x00')
cands = set()
for raw in parts:
    if not raw:
        continue
    s = raw.decode('utf-8', errors='surrogateescape')
    pp = s.split('/')
    if len(pp) >= 3 and pp[1]:
        cands.add(pp[0] + '/' + pp[1])
    elif len(pp) == 2 and pp[1]:
        cands.add(s)

if cands:
    sys.stdout.buffer.write(b'\x00'.join(
        c.encode('utf-8', errors='surrogateescape') for c in sorted(cands)
    ) + b'\x00')
PYEOF
  py_rc=$?
  if [ "$py_rc" -ne 0 ]; then
    printf 'NOT_IMPLEMENTED: свёртка кандидатов отказала (rc=%d)\n' "$py_rc" >&2
    exit 2
  fi

  if [ -s "$TMP/reap_candidates" ]; then
    # 2. Распознанные NNN: contracts/NNN-*.md в дереве.
    : > "$TMP/reap_recognized_nnns"
    if [ -d "$ROOT/contracts" ]; then
      for f in "$ROOT/contracts"/0[0-9][0-9]-*.md; do
        [ -f "$f" ] || continue
        nnn="$(printf '%s' "${f##*/}" | sed -nE 's|^(0[0-9][0-9])-.*\.md$|\1|p')"
        [ -n "$nnn" ] && printf '%s\n' "$nnn" >> "$TMP/reap_recognized_nnns"
      done
      sort -u "$TMP/reap_recognized_nnns" -o "$TMP/reap_recognized_nnns"
    fi

    # 3. NNN с done-тегом: refs/tags/done/contracts/NNN/*. Отказ источника — fail-closed
    #    rc 2 «NOT_IMPLEMENTED» (вердикт к2: отсутствие fail-closed `else` маскировало отказ
    #    под пустой done-набор, и свежий done-кандидат переживал apply с rc=0).
    : > "$TMP/reap_done_nnns"
    if g for-each-ref --format='%(refname:short) %(creatordate:unix)' 'refs/tags/done/contracts/' \
         > "$TMP/reap_done_nnns.raw" 2>/dev/null; then
      sed -nE 's|^done/contracts/(0[0-9][0-9])/.*|\1|p' "$TMP/reap_done_nnns.raw" \
        | sort -u > "$TMP/reap_done_nnns" || : > "$TMP/reap_done_nnns"
      # Карта NNN -> ПОСЛЕДНЯЯ дата закрытия (max creatordate по всем done/contracts/NNN/*).
      # `%(creatordate:unix)`, НЕ `%(taggerdate:unix)`: лёгкие теги (без `-a`) не имеют
      # tagger-а — taggerdate у них ПУСТ, а фикстуры `_zhnets.sh` кладут done-теги именно
      # лёгкими (замер) — taggerdate дал бы фальшивый fail-closed на каждом их прогоне.
      # creatordate = tagger date для аннотированных, committer date подлежащего коммита
      # для лёгких — надёжен в обоих случаях.
      awk '$1 ~ /^done\/contracts\// { n=split($1,p,"/"); nnn=p[3]; if ($2+0>ts[nnn]) ts[nnn]=$2+0 }
           END { for (n in ts) print n, ts[n] }' "$TMP/reap_done_nnns.raw" | sort > "$TMP/reap_done_ts"
    else
      ref_rc=$?
      printf 'NOT_IMPLEMENTED: git for-each-ref (done-теги) отказал (rc=%d)\n' "$ref_rc" >&2
      exit 2
    fi

    # 4. mtime каждой записи-кандидата — python3 lstat (Н-60: GNU find слеп к fifo/симлинкам).
    #    На входе — NUL-разделённый список путей относительно ROOT. На выходе — пары
    #    NUL-разделённых raw-полей: <path>\x00<cand_age>\t<age_str>\t<nnns_str>\x00.
    #    Транспорт пути — raw-байты (НЕ base64): command substitution `$()` сжимает хвостовые
    #    LF, и `tmp/done021` ≡ `tmp/$'done021\n'` для башевой декодировки (вердикт к2).
    #    `--tmp-reap-age` валидируется: NaN/inf/отрицательное → rc 2 «NOT_IMPLEMENTED»
    #    (вердикт к2: без проверки --tmp-reap-age NaN/inf/-1 принимались).
    python3 - "$ROOT" "$TMP/reap_candidates" "$tmp_reap_age" \
        > "$TMP/reap_ages" <<'PYEOF'
import os, sys, time, re, math
root = sys.argv[1]
candidates_path = sys.argv[2]
try:
    threshold_days = float(sys.argv[3])
except ValueError as ex:
    print(f"NOT_IMPLEMENTED: --tmp-reap-age не float: {ex}", file=sys.stderr)
    sys.exit(2)
if not (math.isfinite(threshold_days) and threshold_days > 0.0):
    print(f"NOT_IMPLEMENTED: --tmp-reap-age не положительное конечное число: {sys.argv[3]!r}", file=sys.stderr)
    sys.exit(2)
threshold_seconds = threshold_days * 86400.0

try:
    with open(candidates_path, 'rb') as fh:
        data = fh.read()
except OSError as ex:
    print(f"NOT_IMPLEMENTED: candidates не читается: {ex}", file=sys.stderr)
    sys.exit(2)

now = time.time()
out = bytearray()
for raw in data.split(b'\x00'):
    if not raw:
        continue
    rel = raw.decode('utf-8', errors='surrogateescape')
    full = os.path.join(root, rel)
    try:
        st = os.lstat(full)
    except OSError:
        continue
    age_sec = now - st.st_mtime
    cand_age = 1 if age_sec > threshold_seconds else 0
    age_str = f"{age_sec / 86400.0:.1f}"

    base = rel[4:] if rel.startswith('tmp/') else rel
    nnns = sorted(set(m.group(1) for m in re.finditer(r'(?=(0[0-9][0-9]))', base)))
    nnns_str = ' '.join(nnns)

    # Транспорт: <path>\x00<cand_age>\t<age_str>\t<nnns_str>\x00.
    # Хвостовой LF в `path` (например `tmp/$'done021\n'`) сохраняется: bash читает
    # raw-байты двумя `read -d ''`, без `$()`.
    out.extend(rel.encode('utf-8', errors='surrogateescape'))
    out.extend(b'\x00')
    out.extend(f"{cand_age}\t{age_str}\t{nnns_str}".encode('utf-8'))
    out.extend(b'\x00')

if out:
    sys.stdout.buffer.write(bytes(out))
PYEOF
    py_rc=$?
    if [ "$py_rc" -ne 0 ]; then
      printf 'NOT_IMPLEMENTED: TMP-РЕАП lstat отказал (rc=%d)\n' "$py_rc" >&2
      exit 2
    fi

    # 5. Квалификация + действие. Критерий (инвариант 3, ГРАЦИЯ Н-107 в done-ветке):
    #    * NNN распознан (contracts/NNN-*.md) БЕЗ done-тега → АКТИВНЫЙ, ВЫЖИВАЕТ всегда;
    #    * иначе любой NNN в имени с done-тегом → done: mtime ≤ creatordate последнего
    #      done/contracts/NNN/* → запись ДО закрытия, реап немедленно; mtime > creatordate
    #      И старше --wip-grace-hours → брошенный rework, реап; иначе → СВЕЖИЙ rework,
    #      ВЫЖИВАЕТ (stderr несёт «грация Н-107»); дата закрытия/mtime недоступны →
    #      fail-closed, ВЫЖИВАЕТ (симметрия reflog-ветки);
    #    * иначе (аноним, без распознанного NNN) → возраст: mtime > tmp_reap_age → реап.
    #    `entry` приходит raw-байтами из python — хвостовой LF сохраняется, идентичность
    #    пути не теряется (вердикт к2).
    while :; do
      IFS= read -r -d '' entry || break
      IFS= read -r -d '' metadata || break
      [ -n "$entry" ] || continue
      cand_age="${metadata%%$'\t'*}"
      tmp1="${metadata#*$'\t'}"
      age_str="${tmp1%%$'\t'*}"
      nnns_str="${tmp1#*$'\t'}"

      has_active=0
      has_done=0
      done_nnn=""
      for n in $nnns_str; do
        [ -n "$n" ] || continue
        if grep -qxF -- "$n" "$TMP/reap_done_nnns" 2>/dev/null; then
          has_done=1
          done_nnn="$n"
        elif grep -qxF -- "$n" "$TMP/reap_recognized_nnns" 2>/dev/null; then
          # NNN распознан, done-тега нет → АКТИВНЫЙ. Запоминаем, но done-номер в имени
          # не перевешивает — активный выигрывает.
          has_active=1
        fi
      done

      if [ "$has_active" -eq 1 ]; then
        # Приоритет активного номера — выживает даже при наличии done-номера в имени.
        continue
      fi

      reason=""
      if [ "$has_done" -eq 1 ]; then
        # Мера (б) инварианта 2, ПЕРЕД грацией: смешанный tracked+untracked вход под
        # done-именованной записью — структурная порча независимо от того, реапится ли
        # запись сейчас или переживает грацию Н-107. Проверка ДО решения о грации —
        # иначе свежий (грация-защищённый) смешанный вход тихо переживал бы прогон,
        # ни разу не насторожив владельца (находка анти-плацебо: без этого
        # `case_zhnets_aktiv_vyzhivaet.sh` зеленел на обманном дереве).
        if [ "$tmp_reap_apply" -eq 1 ]; then
          tracked_out=""; tracked_rc=0
          tracked_out="$(g ls-files -- "$entry" 2>/dev/null)" || tracked_rc=$?
          if [ "$tracked_rc" -ne 0 ]; then
            printf 'NOT_IMPLEMENTED: git ls-files (tracked-контроль) отказал для %s (rc=%d)\n' \
              "$entry" "$tracked_rc" >&2
            exit 2
          fi
          if [ -n "$tracked_out" ]; then
            printf 'ОТКАЗ: смешанный вход %s: tracked+untracked — владельцу\n' "$entry" >&2
            exit 1
          fi
        fi
        # ГРАЦИЯ Н-107 (контракт 030): свежий rework-вход, спавненный ПОСЛЕ close-out уже
        # done-контракта, не обязан сноситься вместе с остатком закрытия. Различитель —
        # момент закрытия: mtime ≤ creatordate(последнего done/contracts/NNN/*) — запись
        # ДО закрытия, реап сразу; иначе — ПОСЛЕ закрытия, кандидат rework: старше
        # --wip-grace-hours → брошенный, реап; иначе → свежий, ВЫЖИВАЕТ.
        done_ts="$(awk -v n="$done_nnn" '$1 == n { print $2; exit }' "$TMP/reap_done_ts" 2>/dev/null)"
        entry_mtime="$(python3 -c '
import os, sys
try:
    print(int(os.lstat(sys.argv[1]).st_mtime))
except OSError:
    print(0)
' "$ROOT/$entry" 2>/dev/null || printf 0)"
        if [ -z "$done_ts" ] || [ "$entry_mtime" -eq 0 ]; then
          # дата закрытия / mtime записи недоступны — fail-closed: выживает (симметрия
          # reflog-ветки).
          printf 'TMP-РЕАП: %s  done %s дата закрытия недоступна — ВЫЖИВАЕТ (fail-closed)\n' \
            "$entry" "$done_nnn" >&2
          continue
        elif [ "$entry_mtime" -le "$done_ts" ]; then
          reason="done ${done_nnn} (запись до закрытия)"
        else
          now_ts="$(date +%s)"
          done_grace_secs="$(python3 -c "print(int(float('$wip_grace_hours') * 3600))")"
          if [ "$((now_ts - entry_mtime))" -gt "$done_grace_secs" ]; then
            reason="done ${done_nnn} (после закрытия, старше грации)"
          else
            printf 'TMP-РЕАП: %s  done %s свежий rework — ВЫЖИВАЕТ (грация Н-107)\n' \
              "$entry" "$done_nnn" >&2
            continue
          fi
        fi
      elif [ "$cand_age" = "1" ]; then
        reason="возраст ${age_str}d"
      fi

      [ -n "$reason" ] || continue

      if [ "$tmp_reap_apply" -eq 1 ]; then
        # lstat_1 — идентичность (dev:ino) записи ДО контроля tracked: закрывает подмену,
        # случившуюся МЕЖДУ построением кандидат-листа и запуском контроля (вердикт к4
        # FAIL 2). Пустая строка — запись уже не lstat-ится (ENOENT/др.) в этой точке.
        id_before="$(python3 -c '
import sys, os
try:
    st = os.lstat(sys.argv[1])
    sys.stdout.write(f"{st.st_dev}:{st.st_ino}")
except OSError:
    pass
' "$ROOT/$entry" 2>/dev/null)" || id_before=""

        # Мера (б) инварианта 2: перед каждым удалением — контроль tracked, fail-closed
        # на ЛЮБОМ отказе git (вердикт к3: `$()` глушил rc второго `ls-files`; отказ git
        # давал пустой stdout, неотличимый от честного «tracked нет» — tracked удалялся
        # вместе с untracked, БЕЗ отказа). Отказ здесь — «нечем проверить» rc 2, НЕ
        # молчаливое «tracked нет»: пустой stdout принимается ТОЛЬКО при rc 0.
        tracked_out=""; tracked_rc=0
        tracked_out="$(g ls-files -- "$entry" 2>/dev/null)" || tracked_rc=$?
        if [ "$tracked_rc" -ne 0 ]; then
          printf 'NOT_IMPLEMENTED: git ls-files (tracked-контроль) отказал для %s (rc=%d)\n' \
            "$entry" "$tracked_rc" >&2
          exit 2
        fi
        if [ -n "$tracked_out" ]; then
          printf 'ОТКАЗ: смешанный вход %s: tracked+untracked — владельцу\n' "$entry" >&2
          exit 1
        fi

        # TOCTOU (вердикт к4 FAIL 2): повторный git ls-files НЕМЕДЛЕННО перед rm НЕ
        # закрывает гонку — тот же check-then-act шов между отдельными внешними вызовами
        # (подставной rm может подменить запись ПОСЛЕ своего запуска, ДО настоящего
        # удаления). Правильный примитив — ВТОРОЙ lstat СЛИТ с самим актом удаления в
        # ОДНОМ python3-процессе, без exec внешнего `rm`: удаляющий вызов И ЕСТЬ процесс,
        # взявший второй lstat — подмена цели через PATH-хайджекинг внешнего `rm` больше
        # не имеет точки приложения. Расхождение dev:ino между первым и вторым lstat →
        # именованный TOCTOU rc 2, запись НЕ ТРОГАЕТСЯ.
        # ОСТАТОЧНЫЙ РИСК: окно между os.lstat() и os.remove()/shutil.rmtree() ВНУТРИ
        # одного и того же процесса, без промежуточного fork/exec, — несколько машинных
        # инструкций. Выиграть эту гонку значит подменить запись НА ЭТОМ ИМЕНИ строго
        # между двумя системными вызовами одного процесса; такая точность практически
        # требует контроля планировщика ядра уровня root, а не обычной параллельной
        # мутации соседним процессом. Полное закрытие требует эксклюзивной блокировки
        # ./tmp поперёк ВСЕХ процессов — отдельное архитектурное решение вне слоя 1
        # механизма, не точечный фикс.
        del_rc=0; del_err=""
        del_err="$(python3 -c '
import sys, os, shutil
before, path = sys.argv[1], sys.argv[2]
try:
    st = os.lstat(path)
    after = f"{st.st_dev}:{st.st_ino}"
except OSError:
    after = ""
if not before or before != after:
    sys.stderr.write(f"запись подменена между контролем и удалением (dev:ino {before!r} -> {after!r})")
    sys.exit(3)
try:
    if os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path)
    else:
        os.remove(path)
except OSError as ex:
    sys.stderr.write(str(ex))
    sys.exit(4)
except Exception as ex:
    sys.stderr.write(str(ex))
    sys.exit(4)
' "$id_before" "$ROOT/$entry" 2>&1)" || del_rc=$?
        if [ "$del_rc" -eq 3 ]; then
          printf 'NOT_IMPLEMENTED: TOCTOU %s: %s\n' "$entry" "$del_err" >&2
          exit 2
        fi
        if [ "$del_rc" -ne 0 ]; then
          # Снимаем chmod, если он блокирует — НЕ ТРОГАЕМ chmod (fail-closed: владелец
          # видит именованный отказ и решает).
          printf 'ОТКАЗ: не удалось удалить %s\n' "$entry" >&2
          exit 1
        fi
      fi

      printf 'TMP-РЕАП: %s  %s\n' "$entry" "$reason" >&2
      reap_total=$((reap_total + 1))
    done < "$TMP/reap_ages"
  fi
fi

printf 'GC: слито и снесено %d · зависших %d · отказов OID %d · TMP-РЕАП кандидатов %d\n' \
  "$removed" "$kept" "$fails" "$reap_total" >&2

[ "$fails" -eq 0 ] || exit 1
