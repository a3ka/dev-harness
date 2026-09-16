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
#       `done/contracts/NNN/*` → реап независимо от возраста;
#   (б) возраст — имя без распознанного NNN И mtime записи старше N дней (по умолчанию 7;
#       флаг `--tmp-reap-age N`). mtime — lstat САМОЙ записи через python3 (Н-60).
# Распознанный NNN = есть `contracts/NNN-*.md` в дереве. NNN без файла контракта и без
# done-тега — аноним, правило возраста. NNN распознан БЕЗ done-тега = АКТИВНЫЙ контекст
# (скратч живого майлстоуна) → запись ВЫЖИВАЕТ независимо от возраста. При коллизии
# (активный и done в одном имени) — приоритет активного номера. Dry-run по умолчанию
# (каждый прогон печатает TMP-РЕАП список в stderr); удаление — ТОЛЬКО `--tmp-reap-apply`.
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
    NNN распознан, если есть contracts/NNN-*.md в дереве; NNN с done-тегом — done; NNN
    распознан без done-тега — АКТИВНЫЙ контекст → запись ВЫЖИВАЕТ независимо от возраста
    (приоритет активного номера над done в одном имени). --tmp-reap-age N — порог возраста
    в днях для правила (б).
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
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root) root_arg="${2:?}"; shift 2 ;;
    --expect-kept) expect_kept+=("${2:?}"); shift 2 ;;
    --tmp-reap-apply) tmp_reap_apply=1; shift ;;
    --tmp-reap-age) tmp_reap_age="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'gc_agent_branches: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

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

# СЛИТЫЕ wip/* → удаление ref + worktree. Слитой считается wip/*, чей tip ДОСТИЖИМ из HEAD
# (merge- или fast-forward). Реестр refs/heads/wip/* — единственный источник истины.
removed=0
kept=0
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  tip="$(g rev-parse --verify --quiet "$ref" 2>/dev/null || true)"
  [ -n "$tip" ] || continue
  if g merge-base --is-ancestor "$tip" HEAD 2>/dev/null; then
    # Удалить worktree, если он жив (отдельная операция; ref удаляется ПОСЛЕ).
    wt="$(g worktree list --porcelain 2>/dev/null \
          | awk -v br="$ref" '
              /^worktree / { wt = $2; next }
              /^branch /   { if ($2 == br) { print wt; exit } }
            ')"
    if [ -n "$wt" ] && [ "$wt" != "$ROOT" ] && [ -d "$wt" ]; then
      g worktree remove --force "$wt" 2>/dev/null || true
    fi
    g branch -D "${ref#refs/heads/}" 2>/dev/null && removed=$((removed + 1)) || true
  else
    kept=$((kept + 1))
  fi
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

  # 1. Источник кандидатов: untracked в tmp/, свёртка до верхнеуровневой записи.
  #    Без --exclude-standard — tmp/ в .gitignore не должен делать источник слепым (024 нога-2).
  #    awk сворачивает tmp/X/Y/Z → tmp/X; файлы на верхнем уровне tmp/X → tmp/X (НЕ в tmp,
  #    иначе риск удалить сам tmp/).
  g ls-files --others -z -- 'tmp/' 2>/dev/null \
    | tr '\0' '\n' \
    | awk -F/ 'NF>=2 && $2!="" {print $1"/"$2}' \
    | sort -u > "$TMP/reap_candidates" || : > "$TMP/reap_candidates"

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

    # 3. NNN с done-тегом: refs/tags/done/contracts/NNN/*.
    : > "$TMP/reap_done_nnns"
    if g for-each-ref --format='%(refname:short)' 'refs/tags/done/contracts/' \
         > "$TMP/reap_done_nnns.raw" 2>/dev/null; then
      sed -nE 's|^done/contracts/(0[0-9][0-9])/.*|\1|p' "$TMP/reap_done_nnns.raw" \
        | sort -u > "$TMP/reap_done_nnns" || : > "$TMP/reap_done_nnns"
    fi

    # 4. mtime каждой записи-кандидата — python3 lstat (Н-60: GNU find слеп к fifo/симлинкам).
    #    На входе — NL-разделённый список путей относительно ROOT. На выходе — строки
    #    «path<TAB>days» (days — целое число дней; -1 при ошибке lstat).
    # stdin в python3 — тело скрипта (heredoc); данные о кандидатах идут через argv[2],
    # чтобы не конфликтовать с stdin-источником скрипта. Файл `reap_candidates` уже
    # newline-terminated; lstat делаем по абсолютному пути os.path.join(ROOT, rel).
    python3 - "$ROOT" "$TMP/reap_candidates" > "$TMP/reap_ages" <<'PYEOF'
import os, sys, time
root = sys.argv[1]
candidates = sys.argv[2]
now = time.time()
try:
    with open(candidates, 'r', encoding='utf-8') as fh:
        for raw in fh:
            rel = raw.rstrip('\n')
            if not rel:
                continue
            full = os.path.join(root, rel)
            try:
                st = os.lstat(full)
            except OSError:
                print(f"{rel}\t-1")
                continue
            days = int((now - st.st_mtime) / 86400)
            print(f"{rel}\t{days}")
except OSError as ex:
    print(f"NOT_IMPLEMENTED: candidates не читается: {ex}", file=sys.stderr)
    sys.exit(2)
PYEOF
    py_rc=$?
    if [ "$py_rc" -ne 0 ]; then
      printf 'NOT_IMPLEMENTED: TMP-РЕАП lstat отказал (rc=%d)\n' "$py_rc" >&2
      exit 2
    fi

    # 5. Квалификация + действие. Критерий (инвариант 3):
    #    * NNN распознан (contracts/NNN-*.md) БЕЗ done-тега → АКТИВНЫЙ, ВЫЖИВАЕТ всегда;
    #    * иначе любой NNN в имени с done-тегом → done, реап;
    #    * иначе (аноним, без распознанного NNN) → возраст: mtime > tmp_reap_age → реап.
    while IFS=$'\t' read -r entry age_days; do
      [ -n "$entry" ] || continue
      base="${entry#tmp/}"
      nnns="$(printf '%s' "$base" | grep -oE '0[0-9][0-9]' | sort -u || true)"

      has_active=0
      has_done=0
      done_nnn=""
      for n in $nnns; do
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
        reason="done ${done_nnn}"
      elif [ -n "$age_days" ] && [ "$age_days" -gt "$tmp_reap_age" ] 2>/dev/null; then
        reason="возраст ${age_days}d"
      fi

      [ -n "$reason" ] || continue

      if [ "$tmp_reap_apply" -eq 1 ]; then
        # Мера (б) инварианта 2: перед каждым удалением — контроль tracked. Непустой контроль
        # под untracked-кандидатом = «смешанный вход»: реап останавливается, запись ЦЕЛА.
        if [ -n "$(g ls-files -- "$entry" 2>/dev/null)" ]; then
          printf 'ОТКАЗ: смешанный вход %s: tracked+untracked — владельцу\n' "$entry" >&2
          exit 1
        fi
        if ! rm -rf -- "$ROOT/$entry" 2>/dev/null; then
          # Снимаем chmod, если он блокирует — НЕ ТРОГАЕМ chmod (fail-closed: владелец
          # видит именованный отказ и решает). Очищаем trap перед аварийным выходом.
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
