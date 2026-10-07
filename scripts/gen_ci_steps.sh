#!/usr/bin/env bash
# scripts/gen_ci_steps.sh — генератор блоков JOBS и SHARDS в
# `.github/workflows/ci.yml` из реестра `registry/ci-steps.tsv` (контракт 083,
# инвариант 1). Маркеры НЕ генерируются, тело блоков — генерируется
# побайтово, файлы не трогаются при отказе.
#
# Коды возврата:
# CLI (грамматика зафиксирована контрактом):
#   bash scripts/gen_ci_steps.sh --check [--root <dir>]
#     rc 0 — блоки в ci.yml совпали с генерацией (конформный вход);
#     rc 1 — именованное расхождение (правка человеком или дрейф);
#   bash scripts/gen_ci_steps.sh --write [--root <dir>]
#     rc 0 — блоки записаны (ЗАПИСАНО, не сверка);
#     rc 1 — нерезолв И-3 (npm/bash цель не найдена) ИЛИ нарушение баланса
#             И-4: файлы НЕ трогаются.
#
# LPT-распределение ключей по lane (инвариант 4): сортировка по убыванию веса,
# в наименее загруженную lane; граница `max(load) ≤ ceil(total/K) + max(вес
# одного шага)` — НЕ ослабляется; нарушение — rc 1.
set -uo pipefail
# Детерминизм сортировки: без явной локали `sort` опирается на системную
# локаль (LANG/LC_* из окружения), и убывающая сортировка весов lane
# (ключ `-k1,1nr`) + лексикографическая по имени (`-k2,2`) даёт
# РАЗНЫЙ байтовый порядок на разных машинах (живой укус: локальная машина
# = C-порядок → rc 0, GitHub Actions runner = UTF-8-порядок → `check:scope-select`
# vs `check:scoped-run` меняются местами в lane l7 → блок JOBS дрейфует →
# `gen_ci_steps --check` красен в живом CI; локально всегда зелёный).
# `LC_ALL=C` фиксирует POSIX-порядок для КАЖДОГО вызова `sort` в этом
# процессе (включая будущие/скрытые вызовы в функциях и подоболочках),
# не зависит от LANG/LC_* из CI-окружения.
export LC_ALL=C

MODE=""; ROOT="."
while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)  MODE="check" ;;
    --write)  MODE="write" ;;
    --root)   ROOT="$2"; shift ;;
    --root=*) ROOT="${1#--root=}" ;;
    *) printf 'gen_ci_steps: неизвестный аргумент: %s\n' "$1" >&2; exit 1 ;;
  esac
  shift
done
[ -n "$MODE" ] || { printf 'gen_ci_steps: укажи --check или --write\n' >&2; exit 1; }

REG="$ROOT/registry/ci-steps.tsv"
CIYML="$ROOT/.github/workflows/ci.yml"
[ -f "$REG" ]   || { printf 'gen_ci_steps: предмет отсутствует: нет реестра %s\n' "$REG" >&2; exit 1; }
[ -f "$CIYML" ] || { printf 'gen_ci_steps: нет %s\n' "$CIYML" >&2; exit 1; }

JOBS_B="# BEGIN GENERATED CI JOBS (083)"
JOBS_E="# END GENERATED CI JOBS (083)"
SHARDS_B="# BEGIN GENERATED CI SHARDS (083)"
SHARDS_E="# END GENERATED CI SHARDS (083)"
# CACHE SAVE (Б-1 фикс, ревьюер 083 круг 2 + A-372 архитектора): save-шаги кеша
# 4 инкрементальных чеков (charter/zones/ids/protected) перенесены в
# генерируемый блок, и каждый save-шаг получает условие
# `contains(format(' {0} ', matrix.keys), ' check:X ')` — точная токенная форма
# (пробелы-якоря по краям), ТОЛЬКО lane, несущая ключ X, сохраняет свой кеш.
# Раньше save-шаги стояли в КАЖДОЙ из 7 lane без разбора: ключ actions/cache
# неизменяем (побеждает lane, закончившая первой), часто это lane, которая чек
# НЕ гоняла — она сохраняла восстановленную старую базу, и зелёный чек своей
# lane кеш не продвигал (живой PR#49: окно 2→3 не продвинулось для zones).
# Предыдущая форма `contains(matrix.keys, 'check:X')` была подстроковым
# матчингом (живая находка A-372): lane l6 несёт ключи
# `check:zones-call-budget check:protected-call-budget` — строка содержит
# подстроки `check:zones` и `check:protected`, и save-условие для zones/protected
# истинно на l6, хотя l6 эти чеки НЕ гоняет. `format(' {0} ', matrix.keys)`
# обёртывает строку пробелами, и contains ищет точный токен `' check:X '` —
# подстроковый матч исключён.
CACHE_B="# BEGIN GENERATED CACHE SAVE (083)"
CACHE_E="# END GENERATED CACHE SAVE (083)"

# ── 1. Парсер реестра ────────────────────────────────────────────────────────
K=""
declare -A STEP_WEIGHT=()
declare -A STEP_CMD=()
declare -A SHARD_KEYS=()
while IFS=$'\t' read -r kind k1 k2 k3; do
  case "$kind" in
    lanes)
      K="$k1"
      ;;
    step)
      key="$k1"; weight="$k2"; command="$k3"
      STEP_WEIGHT["$key"]="$weight"
      STEP_CMD["$key"]="$command"
      ;;
    shard)
      name="$k1"; keys="$k2"
      SHARD_KEYS["$name"]="$keys"
      ;;
  esac
done < <(awk -F'\t' '
  /^[[:space:]]*#/ {next}
  $1=="lanes" || $1=="step" || $1=="shard" {print}
' "$REG")

[ -n "$K" ] || { printf 'gen_ci_steps: реестр вне грамматики: нет строки lanes <K>\n' >&2; exit 1; }
case "$K" in
  6|7|8) ;;
  *) printf 'gen_ci_steps: lanes K=%s вне 6..8\n' "$K" >&2; exit 1 ;;
esac

[ "${#STEP_WEIGHT[@]}" -gt 0 ] || { printf 'gen_ci_steps: реестр без step-строк\n' >&2; exit 1; }

# ── 2. Резолв И-3 ───────────────────────────────────────────────────────────
pkg="$ROOT/package.json"
[ -f "$pkg" ] || { printf 'gen_ci_steps: нет %s\n' "$pkg" >&2; exit 1; }
for key in "${!STEP_CMD[@]}"; do
  cmd="${STEP_CMD[$key]}"
  case "$cmd" in
    "npm run "*)
      npmkey="$(printf '%s' "$cmd" | awk '{print $3}')"
      if ! jq -e --arg k "$npmkey" '.scripts[$k] != null' "$pkg" >/dev/null 2>&1; then
        printf 'gen_ci_steps: нерезолв: step %s: %s — npm-ключ %s не в package.json\n' "$key" "$cmd" "$npmkey" >&2
        exit 1
      fi
      ;;
    "bash "*)
      p="$(printf '%s' "$cmd" | awk '{print $2}')"
      [ -f "$ROOT/$p" ] || { printf 'gen_ci_steps: нерезолв: step %s: bash-путь %s не найден в дереве\n' "$key" "$p" >&2; exit 1; }
      ;;
    *)
      printf 'gen_ci_steps: нерезолв: step %s: команда вне грамматики: %s\n' "$key" "$cmd" >&2
      exit 1
      ;;
  esac
done

# ── 3. Резолв шардов И-5 ────────────────────────────────────────────────────
# Проверка существования scripts/<key>.sh для ключей шардов НЕ выполняется здесь:
# она возложена на `verify_ci_parity.sh` (Г6 — сумма-инвариант шардов и
# `scripts/<key>.sh` существует). Генератор работает на ВНЕШНИХ входах
# (toy-копия в Г8), где полного scripts/ нет; проверка на полноту — в самом
# ci.yml (батарея 083, клетка Г6). Граница контракта: generator ВИДИТ shard
# в реестре, СУДИТ поключево равенство блока и shard-строки (выше и ниже),
# но НЕ требует, чтобы scripts/ был полным в момент генерации.

# ── 4. LPT-распределение (инвариант 4) ─────────────────────────────────────
total=0; maxw=0
for k in "${!STEP_WEIGHT[@]}"; do
  w="${STEP_WEIGHT[$k]}"; total=$((total+w)); [ "$w" -gt "$maxw" ] && maxw="$w"
done
bound=$(( (total + K - 1) / K + maxw ))

# Список ключей в порядке (убывание веса, лексикография).
SORTED_KEYS=""
while IFS=$'\t' read -r _w k; do
  [ -n "$k" ] || continue
  SORTED_KEYS="$SORTED_KEYS $k"
done < <(
  for k in "${!STEP_WEIGHT[@]}"; do printf '%s\t%s\n' "${STEP_WEIGHT[$k]}" "$k"; done \
    | sort -k1,1nr -k2,2
)

declare -A LANE_LOAD=()
declare -A LANE_KEYS=()
for i in $(seq 1 "$K"); do LANE_LOAD[$i]=0; LANE_KEYS[$i]=""; done

for k in $SORTED_KEYS; do
  w="${STEP_WEIGHT[$k]:-0}"
  best=1; best_load="${LANE_LOAD[1]:-0}"
  for i in $(seq 2 "$K"); do
    l="${LANE_LOAD[$i]:-0}"
    if [ "$l" -lt "$best_load" ]; then best="$i"; best_load="$l"; fi
  done
  LANE_LOAD[$best]=$(( LANE_LOAD[$best] + w ))
  if [ -z "${LANE_KEYS[$best]}" ]; then LANE_KEYS[$best]="$k"
  else LANE_KEYS[$best]="${LANE_KEYS[$best]} $k"
  fi
done

for i in $(seq 1 "$K"); do
  if [ "${LANE_LOAD[$i]}" -gt "$bound" ]; then
    printf 'gen_ci_steps: баланс нарушен: lane %s load=%s > границы %s (total=%s, K=%s, maxw=%s)\n' \
      "$i" "${LANE_LOAD[$i]}" "$bound" "$total" "$K" "$maxw" >&2
    exit 1
  fi
done

# ── 5. Генерация тел блоков во временные файлы ─────────────────────────────
GEN_RUN="$(mktemp -d "${TMPDIR:-/tmp}/gen_ci_steps.XXXXXX")" || { printf 'gen_ci_steps: mktemp отказал\n' >&2; exit 1; }
trap 'rm -rf "$GEN_RUN"' EXIT
JOBS_GEN="$GEN_RUN/jobs.txt"
SHARDS_GEN="$GEN_RUN/shards.txt"

{
  for i in $(seq 1 "$K"); do
    printf '          - lane: l%s\n' "$i"
    printf '            keys: %s\n' "${LANE_KEYS[$i]}"
  done
} > "$JOBS_GEN"
# Маркеры ВЫНУЖДЕНЫ быть в колонке 1: оракул батареи (block_body) ищет
# index($0,marker)==1. Внутри include-списка они остаются валидными YAML-комментариями
# (YAML трактует комментарии одинаково на любой колонке, разница — только визуальная).

{
  for name in $(printf '%s\n' "${!SHARD_KEYS[@]}" | sort); do
    printf '          - shard: %s\n' "$name"
    printf '            keys: %s\n' "${SHARD_KEYS[$name]}"
  done
} > "$SHARDS_GEN"

# ── 5b. Генерация CACHE SAVE блока (Б-1 фикс) ─────────────────────────────
# Обратное отображение: какой lane несёт какой check:X (X ∈ {charter, zones,
# ids, protected}). Источник — LANE_KEYS, побайтово та же картина, что в JOBS
# блоке; сумма-инвариант (каждый step-ключ ровно в одной lane) сохраняется.
declare -A CHECK_LANE=()
for i in $(seq 1 "$K"); do
  for key in ${LANE_KEYS[$i]}; do
    case "$key" in
      check:charter|check:zones|check:ids|check:protected)
        CHECK_LANE["$key"]="$i"
        ;;
    esac
  done
done

CACHE_GEN="$GEN_RUN/cache.txt"
{
  for c in charter zones ids protected; do
    full="check:$c"
    lane_i="${CHECK_LANE[$full]:-}"
    if [ -z "$lane_i" ]; then
      printf 'gen_ci_steps: check %s не найден ни в одной lane реестра — save-шаг некуда привязать\n' "$c" >&2
      exit 1
    fi
    # push save — ключ `ci-incr-<c>-<sha>` (общая запись main)
    printf '      - if: contains(format('\'' {0} '\'', matrix.keys), '\'' check:%s '\'') && github.event_name == '\''push'\''\n' "$c"
    printf '        uses: actions/cache/save@v4\n'
    printf '        with:\n'
    printf '          path: tmp/ci-incr/%s.sha\n' "$c"
    printf '          key: ci-incr-%s-${{ github.sha }}\n' "$c"
    # pr save — PR-scoped ключ `ci-incr-<c>-pr-<N>-<sha>` (N = PR number)
    printf '      - if: contains(format('\'' {0} '\'', matrix.keys), '\'' check:%s '\'') && github.event_name == '\''pull_request'\''\n' "$c"
    printf '        uses: actions/cache/save@v4\n'
    printf '        with:\n'
    printf '          path: tmp/ci-incr/%s.sha\n' "$c"
    printf '          key: ci-incr-%s-pr-${{ github.event.pull_request.number }}-${{ github.sha }}\n' "$c"
  done
} > "$CACHE_GEN"

# ── 6. Извлечение текущих блоков из ci.yml ──────────────────────────────────
if ! grep -qF "$JOBS_B" "$CIYML"; then
  printf 'gen_ci_steps: предмет отсутствует: нет маркера %s в %s\n' "$JOBS_B" "$CIYML" >&2
  exit 1
fi
if ! grep -qF "$SHARDS_B" "$CIYML"; then
  printf 'gen_ci_steps: предмет отсутствует: нет маркера %s в %s\n' "$SHARDS_B" "$CIYML" >&2
  exit 1
fi
# CACHE SAVE маркеры могут отсутствовать в старом ci.yml (до фикса Б-1) —
# в этом случае extraction пропускается, --check упадёт (старая статика
# не равна новой генерации), --write выполнит вставку.
CACHE_MARKERS_PRESENT=0
if grep -qF "$CACHE_B" "$CIYML" && grep -qF "$CACHE_E" "$CIYML"; then
  CACHE_MARKERS_PRESENT=1
fi

# extract_block читает строки между маркерами (исключая сами маркеры).
# Используем awk-скрипт, не модифицирующий ci.yml; текущее содержимое — во временный файл.
CUR_RUN="$(mktemp -d "${TMPDIR:-/tmp}/gen_ci_cur.XXXXXX")" || { printf 'gen_ci_steps: mktemp отказал\n' >&2; exit 1; }
trap 'rm -rf "$GEN_RUN" "$CUR_RUN"' EXIT
JOBS_CUR="$CUR_RUN/jobs.txt"
SHARDS_CUR="$CUR_RUN/shards.txt"
CACHE_CUR="$CUR_RUN/cache.txt"
awk -v b="$JOBS_B" -v e="$JOBS_E" 'index($0,b)>0 && !f {f=1; next} index($0,e)>0 && f {f=0; next} f' "$CIYML" > "$JOBS_CUR"
awk -v b="$SHARDS_B" -v e="$SHARDS_E" 'index($0,b)>0 && !f {f=1; next} index($0,e)>0 && f {f=0; next} f' "$CIYML" > "$SHARDS_CUR"
if [ "$CACHE_MARKERS_PRESENT" -eq 1 ]; then
  awk -v b="$CACHE_B" -v e="$CACHE_E" 'index($0,b)>0 && !f {f=1; next} index($0,e)>0 && f {f=0; next} f' "$CIYML" > "$CACHE_CUR"
fi

if [ "$MODE" = "check" ]; then
  bad=0
  if ! cmp -s "$JOBS_CUR" "$JOBS_GEN"; then
    diff "$JOBS_CUR" "$JOBS_GEN" >&2 || true
    printf 'gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра\n' >&2
    bad=1
  fi
  if ! cmp -s "$SHARDS_CUR" "$SHARDS_GEN"; then
    diff "$SHARDS_CUR" "$SHARDS_GEN" >&2 || true
    printf 'gen_ci_steps: дрейф блока SHARDS — побайтовое расхождение с генерацией из реестра\n' >&2
    bad=1
  fi
  if [ "$CACHE_MARKERS_PRESENT" -eq 1 ]; then
    if ! cmp -s "$CACHE_CUR" "$CACHE_GEN"; then
      diff "$CACHE_CUR" "$CACHE_GEN" >&2 || true
      printf 'gen_ci_steps: дрейф блока CACHE SAVE — побайтовое расхождение с генерацией из реестра\n' >&2
      bad=1
    fi
  else
    printf 'gen_ci_steps: блок CACHE SAVE отсутствует в %s (Б-1 фикс: маркеры %s / %s должны быть)\n' "$CIYML" "$CACHE_B" "$CACHE_E" >&2
    bad=1
  fi
  [ "$bad" -eq 0 ] || exit 1
  exit 0
fi

# MODE=write: заменить тела блоков в ci.yml. Делаем это простым python-парсером —
# гарантированно побайтовая замена, без awk-проблем с multiline-args.
[ -f "$CUR_RUN" ] && rm -rf "$CUR_RUN"
python3 - "$CIYML" "$JOBS_B" "$JOBS_E" "$JOBS_GEN" "$SHARDS_B" "$SHARDS_E" "$SHARDS_GEN" "$CACHE_B" "$CACHE_E" "$CACHE_GEN" "$CACHE_MARKERS_PRESENT" <<'PY'
import sys, re
ciyml, jb, je, jg, sb, se, sg, cb, ce, cg, cache_present = sys.argv[1:12]
cache_present = int(cache_present)
with open(ciyml, 'r', encoding='utf-8') as f:
    text = f.read()
with open(jg, 'r', encoding='utf-8') as f:
    jgen = f.read().rstrip('\n')
with open(sg, 'r', encoding='utf-8') as f:
    sgen = f.read().rstrip('\n')
with open(cg, 'r', encoding='utf-8') as f:
    cgen = f.read().rstrip('\n')

# Маркеры в YAML — комментарии, на отдельной строке. Найдём начало строки,
# где лежит маркер, и конец строки (включая \n). Заменяем ТОЛЬКО тело между
# строками маркеров, сохраняя сами строки маркеров ПОБАЙТОВО.
def replace_block(text, begin, end, new_body):
    # Каждый маркер — самостоятельная строка. Найдём строку, где он лежит.
    # Используем regex с re.MULTILINE: ^...begin...$ и ^...end...$
    # ищем именно такой паттерн.
    pat_begin = re.compile(r'^([^\n]*' + re.escape(begin) + r'[^\n]*)\n', re.MULTILINE)
    pat_end   = re.compile(r'^([^\n]*' + re.escape(end)   + r'[^\n]*)\n', re.MULTILINE)
    m_b = pat_begin.search(text)
    m_e = pat_end.search(text, m_b.end() if m_b else 0)
    if not m_b or not m_e:
        sys.exit(f'нет маркера {begin} или {end}')
    begin_line = m_b.group(0)   # вся строка begin с \n
    end_line   = m_e.group(0)   # вся строка end с \n
    # Заменяем содержимое между begin_line и end_line на new_body + \n
    return text[:m_b.end()] + new_body + '\n' + text[m_e.start():]

text = replace_block(text, jb, je, jgen)
text = replace_block(text, sb, se, sgen)

# CACHE SAVE: два сценария.
# 1) Маркеры есть в ci.yml — заменяем тело блока (побайтово, как JOBS/SHARDS).
# 2) Маркеров нет (первый прогон после фикса Б-1) — удаляем 8 старых
#    статических save-шагов (4 чека × push/pull_request) и вставляем блок
#    CACHE SAVE с маркерами СРАЗУ после lane-шага `bash scripts/run_ci_lane.sh`.
#    Старая статика имела `if: github.event_name == 'push'/'pull_request'` без
#    per-lane условия — её сохранение вернуло бы баг (race всех 7 lane на
#    один ключ actions/cache).
if cache_present == 1:
    text = replace_block(text, cb, ce, cgen)
else:
    # Удаляем 8 старых статических save-шагов. Паттерн покрывает ОБЕ формы
    # (push и pull_request) и ОБЕ формы ключа (без -pr-<N>- и с ним).
    old_save_re = re.compile(
        r'      - if: github\.event_name == .(push|pull_request).\n'
        r'        uses: actions/cache/save@v4\n'
        r'        with:\n'
        r'          path: tmp/ci-incr/\w+\.sha\n'
        r'          key: ci-incr-\w+(?:-pr-\${{ github\.event\.pull_request\.number }})?-\${{ github\.sha }}\n'
    )
    text = old_save_re.sub('', text)
    # Вставляем блок CACHE SAVE с маркерами после lane-шага. Между `name:`
    # и `run:` в ci.yml лежит многострочный комментарий — regex пропускает
    # любые строки между ними (не жадно).
    lane_re = re.compile(
        r'(      - name: Lane \$\{\{ matrix\.lane \}\}\n'
        r'(?:[^\n]*\n)*?'
        r'        run: bash scripts/run_ci_lane\.sh \$\{\{ matrix\.keys \}\}\n)'
    )
    cache_block = cb + '\n' + cgen + '\n' + ce
    new_text, n_sub = lane_re.subn(r'\1' + cache_block + '\n', text, count=1)
    if n_sub != 1:
        sys.exit('не найден lane-шаг `bash scripts/run_ci_lane.sh` для вставки CACHE SAVE')
    text = new_text

with open(ciyml, 'w', encoding='utf-8') as f:
    f.write(text)
PY
exit 0
