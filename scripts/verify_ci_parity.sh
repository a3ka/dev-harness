#!/usr/bin/env bash
# Паритет с CI: гейт, который зеленее CI, — не гейт.
#
# Заведено потому, что «у нас всё проверено» до этого было утверждением сессии, а правило
# AGENTS.md «каждая команда из `run:` обязана иметь пункт в приёмке» механизма не имело.
# Без сверки в ОБЕ стороны расхождение немедленно находилось: в `package.json` лежала
# `check:foo`, в CI её не было, и обе стороны были «зелёные» — локальный прогон шёл, CI
# проходил, а правило нарушалось.
#
# ЧТО ИМЕННО ПРОВЕРЯЕТСЯ. В обе стороны:
#   1. каждая команда из `run:` в `.github/workflows/**` обязана иметь пункт в приёмке
#      (scripts в `package.json`): либо это `npm run <NAME>` и `<NAME>` есть ключом, либо
#      текст команды целиком равен значению какого-то скрипта;
#   2. приёмка НЕ имеет права быть богаче CI молча — каждый скрипт, не используемый в CI,
#      обязан быть объявлен в `config/ci_parity_exceptions.txt` с записанной
#      причиной. Файл читает САМ барьер, поэтому выйти из правила молча нельзя. Лежит он в
#      `config/`, а не в `fixtures/`: это ОБЪЯВЛЕНИЕ, по которому барьер работает в бою, а в
#      `fixtures/` лежит только материал обманных заглушек. Смешение этих двух вещей в одном
#      каталоге — первый шаг к «проверка читает свою же фикстуру».
#
# МНОГОСТРОЧНЫЙ `run:`. Каждая строка внутри `run: |` — отдельная команда, и каждая
# проверяется. Прежняя редакция видела только первую строку блока и пропускала лишние
# команды, спрятанные ниже; это дефект замера, а не упрощение.
#
# ОБЛАСТЬ ВЫВЕДЕНА ИЗ ПРЕДМЕТА, а не задана списком имён: каждый файл `*.yml` и `*.yaml`
# в `.github/workflows/` обходится, каждый ключ `scripts` сверяется. Новый workflow без
# `run:` паритета не нарушает; workflow С `run:` — нарушает, пока команды не покрыты.
#
# ЗАПИСЬ vs ПРОВЕРКА. `gen:harness` и `overlay` — команды записи, не проверки: они
# меняют файлы, а не сверяют дерево. Включение их в CI было бы прогоном записи на чистом
# чекауте — побочный эффект на каждом push'е. Эти скрипты ОБЪЯВЛЕНЫ исключениями, причина
# записана в `config/ci_parity_exceptions.txt` — молчаливого выбора быть не
# должно. `check:overlay` отдельно: его предмет — местное основание контура (omp 185 МБ),
# в CI он бы и был, и возвращал бы 2 NOT_IMPLEMENTED. Это тоже объявленное исключение:
# исключение, которое в CI возвращает 2, ничем не отличается от необъявленной дыры, и
# записать причину обязательно. `models:actual` отдельно: требует трейс сессии, в CI его
# нет — прогон вернул бы NOT_IMPLEMENTED и дал ложное ощущение проверенности.
#
#   bash scripts/verify_ci_parity.sh             проверить это дерево
#   bash scripts/verify_ci_parity.sh <корень>    проверить подставное дерево (так
#                                                 барьер предъявляется красным сам)
#
# Коды возврата: 0 — паритет, 1 — расхождение, 2 — нечем проверить.
set -euo pipefail

# ── корневой каталог проверяемого дерева ──────────────────────────────────────
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
WORKFLOWS="$ROOT/.github/workflows"
PKG="$ROOT/package.json"
EXCEPTIONS="$ROOT/config/ci_parity_exceptions.txt"

fails=0
ok()    { printf '  ok   %s\n' "$*" >&2; }
bad()   { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
skip()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

# ── временное в ./tmp дерева, не в системном /tmp ─────────────────────────────
RUN="$ROOT/tmp/ci_parity/run-$$"
mkdir -p "$RUN"
trap 'rm -rf "$RUN"' EXIT

[ -d "$WORKFLOWS" ]   || skip "нет $WORKFLOWS — сверять не с чем"
[ -f "$PKG" ]         || skip "нет $PKG — приёмка не объявлена"
[ -f "$EXCEPTIONS" ]  || skip "нет $EXCEPTIONS — выйти из правила молча нельзя; положите файл и запишите в нём причины"

# ── 1. разбор скриптов приёмки из package.json ─────────────────────────────────
# Разбор через Python: `scripts` в `package.json` может содержать управляющие символы и
# обратные слэши, и класть в репозиторий sed/awk-парсер JSON — это тот случай, когда
# ложная мера дешевле правильной. Python stdlib всегда есть, и `json.loads` здесь ровно
# то, что нужно: прочитать объект и достать из него `scripts`.
#
# Вывод — TSV `name<TAB>value` построчно, по одной записи на скрипт.
SCRIPTS_TSV="$RUN/scripts.tsv"
python3 - "$PKG" "$SCRIPTS_TSV" <<'PY'
import json, sys
pkg_path, out_path = sys.argv[1], sys.argv[2]
with open(pkg_path) as f:
    data = json.load(f)
scripts = data.get('scripts') or {}
with open(out_path, 'w') as out:
    for name, value in scripts.items():
        # TSV — табуляция как разделитель, без неё в именах/значениях скриптов быть не может.
        assert '\t' not in name and '\t' not in value, 'TSV-разделитель встретился в имени или значении'
        out.write(f'{name}\t{value}\n')
PY

declare -A SCRIPT_NAME  # name -> 1
declare -A SCRIPT_VALUE # value -> name
while IFS=$'\t' read -r name value; do
  [ -n "$name" ] || continue
  SCRIPT_NAME["$name"]=1
  SCRIPT_VALUE["$value"]="$name"
done < "$SCRIPTS_TSV"

# ── 2. разбор команд из workflows ──────────────────────────────────────────────
# Каждый `run:` — отдельная команда, в том числе КАЖДАЯ строка внутри `run: |` блока.
# YAML разбирается тем же Python без зависимостей: репозиторий не держит PyYAML намеренно,
# и тащить его ради парсера одного формата неправильно. Поддерживается `run: <value>`
# (однострочный) и `run: |` / `run: >` (многострочный literal/folded).
#
# Вывод — TSV `path<TAB>lineno<TAB>command` построчно.
WF_CMDS_TSV="$RUN/wf_commands.tsv"
python3 - "$WORKFLOWS" "$WF_CMDS_TSV" <<'PY'
import sys, re, os
wf_dir, out_path = sys.argv[1], sys.argv[2]

def extract(path):
    with open(path) as f:
        lines = f.readlines()
    out = []
    i = 0
    # Совпадение со строкой вида `... run: ...`. Префикс — пробелы/дефис шага списка.
    run_re = re.compile(r'^(\s*-\s*|\s*)run:\s*(.*)$')
    while i < len(lines):
        m = run_re.match(lines[i])
        if not m:
            i += 1
            continue
        rest = m.group(2).strip()
        # Многострочный literal/folded: `run: |`, `run: >`, с возможным `+`/`-` (chomping).
        if rest in ('|', '>', '|+', '|-', '>+', '>-'):
            i += 1
            # Определяем базовый отступ по первой непустой строке блока.
            block_indent = None
            while i < len(lines):
                bline = lines[i]
                stripped = bline.rstrip('\n')
                if stripped.strip() == '':
                    i += 1
                    continue
                bindent = len(stripped) - len(stripped.lstrip(' '))
                if block_indent is None:
                    block_indent = bindent
                if bindent < block_indent:
                    break
                cmd = stripped[block_indent:]
                if cmd.strip():
                    out.append((path, i + 1, cmd))
                i += 1
            continue
        # Однострочный `run: <value>`.
        if rest:
            out.append((path, i + 1, rest))
        i += 1
    return out

all_cmds = []
if os.path.isdir(wf_dir):
    for name in sorted(os.listdir(wf_dir)):
        if not (name.endswith('.yml') or name.endswith('.yaml')):
            continue
        full = os.path.join(wf_dir, name)
        if os.path.isfile(full):
            all_cmds.extend(extract(full))

with open(out_path, 'w') as f:
    for path, ln, cmd in all_cmds:
        assert '\t' not in cmd, 'TSV-разделитель встретился в команде'
        f.write(f'{path}\t{ln}\t{cmd}\n')
PY

# ── 3. разбор файла исключений ────────────────────────────────────────────────
# Формат строки: `<name> = <reason>` (вокруг `=` произвольные пробелы).
# Строка без `=` — отказ: причина обязана быть записана, иначе «объявленное исключение»
# превращается в молчаливую дыру.
# Комментарии — `#` в начале строки или после команды с пробелом перед `#`.
EXC_TSV="$RUN/exceptions.tsv"
EXC_REASON="$RUN/exc_reason.tsv"
declare -A EXC_NAME   # name -> 1
declare -A EXC_REASON # name -> reason
EXC_BAD=0
: > "$EXC_TSV"
: > "$EXC_REASON"
while IFS= read -r raw || [ -n "$raw" ]; do
  line="${raw%$'\r'}"
  case "$line" in
    ''|\#*) continue ;;
  esac
  if [[ "$line" =~ ^([^=]+)=(.+)$ ]]; then
    name="$(printf '%s' "${BASH_REMATCH[1]}" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')"
    reason="$(printf '%s' "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -z "$name" ] || [ -z "$reason" ]; then
      EXC_BAD=1
      printf '  FAIL исключение без причины: %s\n' "$line" >&2
      continue
    fi
    if [ -n "${EXC_NAME[$name]:-}" ]; then
      EXC_BAD=1
      printf '  FAIL исключение объявлено дважды: %s\n' "$name" >&2
      continue
    fi
    EXC_NAME["$name"]=1
    EXC_REASON["$name"]="$reason"
    printf '%s\t%s\n' "$name" "$reason" >> "$EXC_REASON"
  else
    EXC_BAD=1
    printf '  FAIL строка исключения без «=»: %s\n' "$line" >&2
  fi
done < "$EXCEPTIONS"
[ "$EXC_BAD" -eq 0 ] || fails=$((fails + 1))

# ── 4. сверка в обе стороны ───────────────────────────────────────────────────
# Проход 1: каждая команда из `run:` обязана быть покрыта.
covered_keys=()
while IFS=$'\t' read -r path ln cmd; do
  [ -n "$cmd" ] || continue
  rel="${path#"$ROOT"/}"
  covered=0
  # `npm run <NAME>` — покрыто, если NAME есть ключом в scripts.
  if [[ "$cmd" =~ ^npm[[:space:]]+run[[:space:]]+([^[:space:]]+)([[:space:]].*)?$ ]]; then
    nm="${BASH_REMATCH[1]}"
    if [ -n "${SCRIPT_NAME[$nm]:-}" ]; then
      covered=1
      covered_keys+=("$nm")
    fi
  fi
  # Иначе — команда должна равняться значению какого-то скрипта целиком.
  if [ "$covered" -eq 0 ] && [ -n "${SCRIPT_VALUE[$cmd]:-}" ]; then
    covered=1
    covered_keys+=("${SCRIPT_VALUE[$cmd]}")
  fi
  if [ "$covered" -eq 0 ]; then
    bad "$rel:$ln: команда «$cmd» есть в CI, но нет пункта в приёмке"
  fi
done < "$WF_CMDS_TSV"

# Проход 2: каждый скрипт либо покрыт, либо объявлен исключением с причиной.
while IFS=$'\t' read -r name value; do
  [ -n "$name" ] || continue
  used=0
  for k in "${covered_keys[@]:-}"; do
    [ "$k" = "$name" ] && used=1
  done
  if [ "$used" -eq 0 ]; then
    if [ -n "${EXC_NAME[$name]:-}" ]; then
      ok "скрипт «$name» не в CI — объявленное исключение: ${EXC_REASON[$name]}"
    else
      bad "скрипт «$name» есть в приёмке, но отсутствует в CI и не объявлен исключением"
    fi
  fi
done < "$SCRIPTS_TSV"

# ── 5. итог ───────────────────────────────────────────────────────────────────
total_wf=$(wc -l < "$WF_CMDS_TSV" | tr -d ' ')
total_scripts=$(wc -l < "$SCRIPTS_TSV" | tr -d ' ')
total_exc=$(wc -l < "$EXC_REASON" | tr -d ' ')
printf '\nworkflow-команд: %d · скриптов в приёмке: %d · объявленных исключений: %d · расхождений: %d\n' \
  "$total_wf" "$total_scripts" "$total_exc" "$fails" >&2
if [ "$fails" -gt 0 ]; then
  exit 1
fi
