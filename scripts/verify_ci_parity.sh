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
#   * каждая КОМАНДА из `run:` шага в `.github/**` обязана иметь пункт в приёмке
#     (`scripts` в `package.json`): либо это `npm run <NAME>` и `<NAME>` есть ключом, либо
#     текст команды целиком равен значению какого-то скрипта;
#   * приёмка НЕ имеет права быть богаче CI молча — каждый скрипт, не используемый в CI,
#     обязан быть объявлен в `config/ci_parity_exceptions.txt` с записанной причиной.
#     Файл читает САМ барьер, поэтому выйти из правила молча нельзя. Лежит он в `config/`,
#     а не в `fixtures/`: это ОБЪЯВЛЕНИЕ, по которому барьер работает в бою, а в `fixtures/`
#     лежит только материал обманных заглушек. Смешение этих двух вещей в одном каталоге —
#     первый шаг к «проверка читает свою же фикстуру».
#
# `run:` — ЭТО SHELL-СЦЕНАРИЙ, А НЕ ОДНА КОМАНДА. Прежняя редакция сверяла значение `run:`
# целиком, и `npm run check:existing && npm run check:missing` считалось ОДНОЙ покрытой
# командой: хвост после первого имени принимался за аргументы. CI при этом исполнял пункт,
# которого в приёмке нет, — ровно то расхождение, ради которого барьер и заведён (находка
# адверсария). Поэтому сценарий разбирается на команды по `&&`, `||`, `;`, `|`, `&` и
# переводу строки, с уважением к кавычкам и переносу `\`; `2>&1` и `&>` разделителями не
# считаются, иначе перенаправление резало бы команду пополам. Ведущие служебные слова
# (`if`, `then`, `do`, `!`, `time`, …) снимаются: `then npm run x` — это ЗАПУСК `npm run x`,
# и паритет не имеет права зависеть от того, обёрнут ли запуск в условие.
#
# ПОЧЕМУ НЕТ СПИСКА ИГНОРИРУЕМЫХ КОМАНД. Соблазн был: `cd`, `echo`, `printf`, `set`,
# `export` приёмкой не являются, и их хочется просто не сверять. Такой список набирается
# руками и отстаёт МОЛЧА: первый же `mkdir` или `bash -c …` в workflow выпадет из области
# правила, ничего об этом не сообщив, — а барьер, из области которого можно выйти молча,
# ровно тот гейт, который зеленее CI. Поэтому правило обратное и полное: ВСЁ, что не
# является пунктом приёмки и не объявлено исключением, — ОТКАЗ с текстом команды. Для
# вспомогательных команд есть тот же канал объявления, что и для скриптов:
# `команда: <текст> = <причина>` в `config/ci_parity_exceptions.txt`. Цена — надо один раз
# записать, зачем в CI стоит `cd`; выигрыш — из области нельзя выйти, не написав причину.
#
# ОБЛАСТЬ — ВЕСЬ `.github/**`, а не один каталог. Прежняя редакция читала
# `os.listdir(.github/workflows)`: подкаталог `.github/workflows/release/hidden.yaml` и
# локальный composite action `.github/actions/*/action.yml` в область не попадали, хотя
# GitHub Actions ИСПОЛНЯЕТ и их (обе заглушки адверсария прошли зелёными). Область выведена
# из предмета: исполняется всё, что лежит в `.github` и является YAML, значит обходится
# рекурсивно каждый `*.yml`/`*.yaml`. Файл без шагов паритета не нарушает и просто не даёт
# команд, поэтому исключать по именам нечего.
#
# YAML РАЗБИРАЕТСЯ КАК YAML, А НЕ ГРЕПОМ ПО СТРОКАМ. Построчное регулярное выражение
# засчитывало за шаг ЛЮБОЙ ключ `run` на любой глубине — в том числе `env: { run: … }`,
# и приёмка, богаче CI, считалась покрытой значением переменной окружения. Значение поля
# окружения запуском не является: командой считается только `run:` ЭЛЕМЕНТА `steps`
# (у workflow — `jobs.*.steps`, у composite action — `runs.steps`). Тот же построчный
# разбор давал и ЛОЖНОЕ КРАСНОЕ: не снимал кавычки, а folded scalar (`run: >`) резал на
# строки вместо склейки в одну команду. Ложное красное опаснее скучного: ему перестают
# верить, и следующий отказ читают как шум. Поэтому здесь лежит разбор подмножества YAML,
# на котором пишут Actions: блочные отображения и последовательности, плоские и кавычечные
# скаляры, блочные скаляры `|`, `|-`, `|+`, `>`, `>-`, `>+`, потоковые `[a, b]`.
# Разбор на Python, потому что зависимостей у репозитория нет намеренно и PyYAML в нём нет;
# тащить пакет ради одного формата неправильно, а sed/awk-парсер YAML — ложная мера.
#
# `npm run-script` — ТА ЖЕ КОМАНДА, что `npm run`: это не «похожая форма», а официальный
# псевдоним npm. Признаётся именно он; `npx npm run x` покрытием НЕ считается, потому что
# это запуск другого исполнителя, и совпадение с ним было бы совпадением по подстроке.
#
# ИСКЛЮЧЕНИЕ ОБЯЗАНО БЫТЬ ДОСТИЖИМЫМ. Три порока, каждый — отказ с названной записью, потому
# что каждый создаёт ВИД объявленной работы:
#   * мёртвая запись — исключение для скрипта, которого в приёмке нет вовсе. Она маскирует
#     изменение состава приёмки: скрипт переименовали или удалили, а строка осталась, и
#     читатель верит, что решение про него принято;
#   * недостижимая запись — исключение для скрипта, который CI и так запускает. Оно ничего
#     не разрешает и держит в файле выбор, которого не делали;
#   * отписка вместо причины — `= .` и подобное.
#
# ОТСЕЧКА ОТМЕТКИ, А НЕ ПОРОГ ОСМЫСЛЕННОСТИ. Предмет переименован по решению арбитража
# `verdicts/arbitration/oblast-i-porog.md` (вопрос 2) и по вердикту ревьюера
# `verdicts/review/shag-5.md` (находка 4): прежняя шапка обещала «осмысленность», которой
# механизм не измеряет. Мера различает ОТМЕТКУ и ПРЕДЛОЖЕНИЕ и этим исчерпывается: причина
# обязана содержать не менее ЧЕТЫРЁХ слов (последовательностей от двух буквенно-цифровых
# знаков) и не менее ДВАДЦАТИ ЧЕТЫРЁХ буквенно-цифровых знаков. Порог выведен измерением:
# самая короткая настоящая запись в `config/ci_parity_exceptions.txt` — четырнадцать слов,
# предъявленная адверсарием заглушка «.» — ноль; отсечка поставлена между ними и намеренно
# ближе к заглушке.
#
# `cognitive-only`, ОСТАТОЧНЫЙ РИСК ЗАПИСАН ПРЯМО: шесть греческих имён подряд отсечку
# ПРОЙДУТ. Ни длина, ни счёт слов, ни энтропия не отличают предложение от салата, а подгонка
# следующей статистической меры под очередной салат — та самая гонка порога за результатом,
# которую норма запрещает. Ловит это только ЧТЕНИЕ файла исключений ревьюером и адверсарием;
# файл мал и закоммичен, поверхность обозрима. Фикстуры на салат не заводятся намеренно:
# такая фикстура означала бы, что механизм снова притязает на смысл.
#
# ЗАПИСЬ vs ПРОВЕРКА. `gen:harness` и `overlay` — команды записи, не проверки: они меняют
# файлы, а не сверяют дерево. Включение их в CI было бы прогоном записи на чистом чекауте —
# побочный эффект на каждом push'е. Эти скрипты ОБЪЯВЛЕНЫ исключениями, причина записана в
# `config/ci_parity_exceptions.txt`. `check:overlay` отдельно: его предмет — местное
# основание контура (omp 185 МБ), в CI он бы и был, и возвращал бы NOT_IMPLEMENTED. Это
# тоже объявленное исключение: исключение, которое в CI ничего не проверяет, ничем не
#
# ПОДСТАНОВКА КОМАНД И ВЛОЖЕННЫЕ ЗАПУСКИ. `echo "$(npm run x)"`, `eval 'npm run x'`,
# `sh -c 'npm run x'`, `` `npm run x` `` запускают `npm run x` через синтаксис, и
# барьер не имеет права видеть только внешнюю команду — иначе её разрешение
# (исключением или приёмкой) маскирует вложенный запуск непокрытого пункта. Здесь
# барьер РАЗБИРАЕТ вложенные запуски: из `$(...)`, обратных кавычек, `eval`/`exec`,
# `bash -c`/`sh -c` извлекается внутренний скрипт и проверяется теми же правилами,
# что и видимая команда. `xargs <что-то>` РАЗОБРАТЬ нельзя — то, что `xargs` исполнит,
# зависит от stdin, и не увидеть его в принципе; такие команды отказываются с
# названной причиной, потому что молчаливый пропуск здесь был бы ровно тем гейтом,
# что зеленее CI, против которого барьер и заведён.
#
# ОБЛАСТЬ ОБХОДА ПОПОЛНЯЕТСЯ ЧЕРЕЗ `uses: <ОТН.ПУТЬ>`. Прежняя редакция жёстко
# обходила `.github/**`, и `uses: ../../tools/act` оставался за бортом — Actions по
# указанному относительному пути исполняет локальный composite action, где бы он
# ни лежал. Здесь к обходу добавляется каждый `uses:` с путём, начинающимся на `.`
# (`./X`, `../X`), разрешённый ОТНОСИТЕЛЬНО КАТАЛОГА ФАЙЛА WORKFLOW (так работает
# сам `uses:`); неразрешимый путь даёт отказ с названной причиной, а не молчаливый
# пропуск — ровно по той же логике, что и `xargs` выше.
#
# HEREDOC — ДАННЫЕ, А НЕ КОМАНДЫ. Строки внутри `<<EOF ... EOF` оболочка НЕ
# исполняет, и разборщик не должен считать их командами: тело heredoc («это просто
# текст, не запускай меня») проходит как пункт приёмки и зеленеет, а тело heredoc
# как команда даёт ЛОЖНОЕ КРАСНОЕ. Ложное красное здесь опаснее скучного: ему
# перестают верить, и следующий отказ читают как шум. Здесь `<<MARKER` (с
# необязательными `-`, `'`, `"`) переводит разбор в режим «до маркера на отдельной
# строке», и тело вместе с маркером не разбивается на команды.
#
# УСЛОВИЕ ШАГА `if:` НЕ ЧИТАЕТСЯ ВОВСЕ, и каждый шаг сверх-приближается как исполняемый.
# Арбитраж `verdicts/arbitration/oblast-i-porog.md` отклонил находку «`if: false` даёт
# красное»: вычисление выражений `if:` — толкование чужого языка, которого механизм не обязан
# знать. Мёртвый текст в проводке обязан быть удалён либо объявлен исключением с причиной, а не
# молча вычтен из области; сверх-приближение — корректное направление ошибки для паритета,
# потому что ошибка в другую сторону делает гейт зеленее CI.
#
# ОТСУТСТВИЕ ИНСТРУМЕНТА НАЗЫВАЕТСЯ ВСЛУХ. Без `python3` разбирать нечем, и барьер выходит
# кодом «нечем проверить» с названной причиной, а не падает необъявленным кодом от
# ненайденной команды: неудача запуска и вердикт по предмету — разные вещи, и смешивать их
# в одном коде значит врать о предмете.
#
#   bash scripts/verify_ci_parity.sh             проверить это дерево
#   bash scripts/verify_ci_parity.sh <корень>    проверить подставное дерево (так
#                                                 барьер предъявляется красным сам)
#
# Коды возврата: 0 — паритет, 1 — расхождение, 2 — нечем проверить.
set -euo pipefail

# ── корневой каталог проверяемого дерева ──────────────────────────────────────
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GH="$ROOT/.github"
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

command -v python3 >/dev/null 2>&1 || skip "нет python3 — разбирать package.json и YAML нечем"
[ -d "$GH" ]          || skip "нет $GH — сверять не с чем"
[ -f "$PKG" ]         || skip "нет $PKG — приёмка не объявлена"
[ -f "$EXCEPTIONS" ]  || skip "нет $EXCEPTIONS — выйти из правила молча нельзя; положите файл и запишите в нём причины"

# Отказы, найденные разборщиками, копятся сюда и печатаются одним местом: счёт расхождений
# обязан вестись в одной точке, иначе два счётчика разойдутся молча.
PARSE_FAILS="$RUN/parse_fails.txt"
: > "$PARSE_FAILS"

# ── 1. разбор скриптов приёмки из package.json ─────────────────────────────────
# Разбор через Python: `scripts` в `package.json` может содержать управляющие символы и
# обратные слэши, и класть в репозиторий sed/awk-парсер JSON — это тот случай, когда
# ложная мера дешевле правильной. `json.loads` здесь ровно то, что нужно.
#
# Вывод — TSV `name<TAB>value<TAB>value-в-схлопнутых-пробелах`. Схлопнутая форма нужна для
# сверки с текстом команды: YAML-склейка folded scalar даёт другое расстояние между
# словами, а команда от этого другой не становится.
SCRIPTS_TSV="$RUN/scripts.tsv"
python3 - "$PKG" "$SCRIPTS_TSV" "$PARSE_FAILS" <<'PY'
import json, sys

pkg_path, out_path, fails_path = sys.argv[1], sys.argv[2], sys.argv[3]
fails = open(fails_path, 'a', encoding='utf-8')
out = open(out_path, 'w', encoding='utf-8')

try:
    with open(pkg_path, encoding='utf-8') as f:
        data = json.load(f)
except (ValueError, OSError) as e:
    fails.write(f'{pkg_path} не разобран как JSON ({e}) — приёмка не читается\n')
    data = {}

scripts = data.get('scripts') or {}
for name, value in scripts.items():
    # TSV — табуляция как разделитель; запись с табуляцией не различима в учёте, и
    # промолчать о ней значит потерять пункт приёмки без единого слова.
    if '\t' in name or '\t' in str(value):
        fails.write(f'скрипт «{name}» содержит табуляцию — учёт по TSV её не различает\n')
        continue
    out.write(f'{name}\t{value}\t{" ".join(str(value).split())}\n')
out.close()
fails.close()
PY

declare -A SCRIPT_NAME  # name -> 1
declare -A SCRIPT_VALUE # схлопнутое значение -> name
while IFS=$'\t' read -r name value vnorm; do
  [ -n "$name" ] || continue
  SCRIPT_NAME["$name"]=1
  SCRIPT_VALUE["$vnorm"]="$name"
done < "$SCRIPTS_TSV"

# ── 2. разбор команд из .github/** ─────────────────────────────────────────────
# Разбор в два шага: YAML → структура, `run:` шага → список shell-команд. Оба шага
# объяснены в шапке файла; здесь только то, что нужно читателю кода.
#
# Вывод — TSV `path<TAB>lineno<TAB>команда<TAB>команда-в-схлопнутых-пробелах`, где lineno —
# строка ключа `run:`, то есть место, куда смотреть в workflow.
WF_CMDS_TSV="$RUN/wf_commands.tsv"
python3 - "$GH" "$WF_CMDS_TSV" "$PARSE_FAILS" <<'PY'
import os, re, sys

gh_dir, out_path, fails_path = sys.argv[1], sys.argv[2], sys.argv[3]
fails = []

# ── подмножество YAML ──────────────────────────────────────────────────────────
# Разбираются блочные отображения и последовательности, плоские и кавычечные скаляры,
# блочные скаляры и потоковые коллекции. Якоря, теги и многострочные кавычечные скаляры
# GitHub Actions не использует; встретив непонятную строку, разборщик её ПРОПУСКАЕТ, а не
# падает: упасть на форме, которой не ждали, значит потерять весь файл вместо одной строки.

ESC = {'n': '\n', 't': '\t', 'r': '\r', '"': '"', '\\': '\\', '/': '/', '0': '\0', ' ': ' '}


def decode_scalar(s):
    s = s.strip()
    if not s:
        return ''
    if len(s) >= 2 and s[0] == "'" and s[-1] == "'":
        return s[1:-1].replace("''", "'")
    if len(s) >= 2 and s[0] == '"' and s[-1] == '"':
        body, out, i = s[1:-1], [], 0
        while i < len(body):
            c = body[i]
            if c == '\\' and i + 1 < len(body):
                out.append(ESC.get(body[i + 1], body[i + 1]))
                i += 2
                continue
            out.append(c)
            i += 1
        return ''.join(out)
    if s[0] in '[{':
        # Потоковая коллекция: для паритета её содержимое не нужно, важно лишь не принять
        # её за скаляр с двоеточиями.
        return [decode_scalar(p) for p in s[1:-1].split(',') if p.strip()]
    cut = s.find(' #')  # комментарий в плоском скаляре начинается только после пробела
    if cut >= 0:
        s = s[:cut]
    return s.strip()


def split_key(text):
    """`key: value` → (key, value); не отображение → None. Двоеточие в кавычках не режет."""
    q, i = None, 0
    while i < len(text):
        c = text[i]
        if q:
            if q == "'" and c == "'":
                q = None
            elif q == '"':
                if c == '\\':
                    i += 1
                elif c == '"':
                    q = None
        elif c in '"\'':
            q = c
        elif c == '#' and (i == 0 or text[i - 1].isspace()):
            return None
        elif c == ':' and (i + 1 == len(text) or text[i + 1] in ' \t'):
            return text[:i].strip(), text[i + 1:].strip()
        i += 1
    return None


def significant(lines, i):
    while i < len(lines):
        text = lines[i][1]
        if text == '' or text.startswith('#') or text in ('---', '...'):
            i += 1
            continue
        return i
    return i


def read_block_scalar(lines, i, parent_indent, style):
    body = []
    base = None
    while i < len(lines):
        ind, text, _lineno, raw = lines[i]
        stripped = raw.rstrip('\n')
        if stripped.strip() == '':
            body.append('')
            i += 1
            continue
        if ind <= parent_indent:
            break
        if base is None:
            base = ind
        if ind < base:
            break
        body.append(stripped[base:])
        i += 1
    while body and body[-1].strip() == '':
        body.pop()
    if style == '|':
        return '\n'.join(body), i
    # Folded: строки одного уровня СКЛЕИВАЮТСЯ пробелом — это одна команда, а не список.
    parts = []
    for content in body:
        if content.strip() == '':
            parts.append('\n')
        elif content[:1] in (' ', '\t'):
            parts.append('\n' + content)
        else:
            if parts and not parts[-1].endswith('\n'):
                parts.append(' ')
            parts.append(content)
    return ''.join(parts), i


BLOCK_RE = re.compile(r'^([|>])([0-9]*)([+-]?)\s*(?:#.*)?$')


def parse_block(lines, i, indent):
    i = significant(lines, i)
    if i >= len(lines) or lines[i][0] < indent:
        return None, i
    cur, text = lines[i][0], lines[i][1]
    if text == '-' or text.startswith('- '):
        return parse_seq(lines, i, cur)
    if split_key(text) is None:
        return decode_scalar(text), i + 1
    return parse_map(lines, i, cur)


def parse_map(lines, i, indent):
    m = {}
    while True:
        i = significant(lines, i)
        if i >= len(lines):
            break
        ind, text, lineno, _raw = lines[i]
        if ind < indent:
            break
        if ind > indent:
            i += 1  # неожиданный отступ: пропускаем строку, а не файл
            continue
        if text == '-' or text.startswith('- '):
            break
        kv = split_key(text)
        if kv is None:
            i += 1
            continue
        key, rest = kv
        key = decode_scalar(key)
        i += 1
        bm = BLOCK_RE.match(rest)
        if bm:
            val, i = read_block_scalar(lines, i, indent, bm.group(1))
        elif rest == '' or rest.startswith('#'):
            val, i = parse_block(lines, i, indent + 1)
        else:
            val = decode_scalar(rest)
        m[key] = (val, lineno)
    return m, i


def parse_seq(lines, i, indent):
    seq = []
    while True:
        i = significant(lines, i)
        if i >= len(lines):
            break
        ind, text, lineno, raw = lines[i]
        if ind < indent:
            break
        if ind > indent:
            i += 1
            continue
        if not (text == '-' or text.startswith('- ')):
            break
        if text == '-':
            val, i = parse_block(lines, i + 1, indent + 1)
            seq.append(val)
            continue
        # Содержимое элемента начинается в своей колонке; переписываем строку так, будто
        # дефиса не было, — дальше элемент разбирается обычным блоком с этим отступом.
        content = text[1:]
        col = ind + 1 + (len(content) - len(content.lstrip(' ')))
        lines[i] = [col, content.lstrip(' '), lineno, raw]
        val, i = parse_block(lines, i, col)
        seq.append(val)
    return seq, i


def parse_yaml(path):
    with open(path, encoding='utf-8', errors='replace') as f:
        raw_lines = f.readlines()
    lines = []
    for n, raw in enumerate(raw_lines, 1):
        body = raw.rstrip('\n').rstrip()
        stripped = body.lstrip(' ')
        lines.append([len(body) - len(stripped), stripped, n, raw])
    doc, _ = parse_block(lines, 0, 0)
    return doc


# ── условие шага НЕ ЧИТАЕТСЯ ВОВСЕ ────────────────────────────────────────────
# Прежняя редакция фильтровала шаги с константно-ложным `if:`, и это ОТКЛОНЕНО арбитражем
# `verdicts/arbitration/oblast-i-porog.md` (вопрос 1, граница отказа): вычисление выражений
# `if:` — толкование ЧУЖОГО языка, которого механизм не обязан знать. Каждый шаг
# СВЕРХ-ПРИБЛИЖАЕТСЯ как исполняемый, и это КОРРЕКТНОЕ направление ошибки для паритета:
# приёмка обязана покрывать всё, что в проводке написано, а мёртвый текст в CI обязан быть
# удалён либо объявлен исключением с причиной — а не молча вычтен из области.
#
# Ошибка в другую сторону была бы хуже: механизм, который САМ решает, какой шаг исполнится,
# начинает спорить с Actions о семантике `${{ }}`, и первая же незнакомая форма даёт ложное
# зелёное — то есть гейт становится зеленее CI, ровно против чего он и написан.
def collect_runs(node, out):
    """`run:` ЭЛЕМЕНТА `steps` — и только он: значение `env.run` запуском не является."""
    if isinstance(node, dict):
        for key, (val, _lineno) in node.items():
            if key == 'steps' and isinstance(val, list):
                for item in val:
                    if isinstance(item, dict) and 'run' in item:
                        rv, rl = item['run']
                        if isinstance(rv, str) and rv.strip():
                            out.append((rl, rv))
            collect_runs(val, out)
    elif isinstance(node, list):
        for item in node:
            collect_runs(item, out)


def collect_uses_refs(node, out):
    """Собирает `uses: <путь>` ссылки на локальные composite actions. Локальные пути
    начинаются с `.` (`./X` или `../X`); внешние (`owner/repo@ref`) и `docker://…`
    пропускаются — их исходный код не принадлежит этому дереву, и сверять его с
    `package.json` было бы ложной мерой."""
    if isinstance(node, dict):
        for key, (val, _lineno) in node.items():
            if key == 'uses' and isinstance(val, str) and val.startswith('.'):
                out.append(val)
            collect_uses_refs(val, out)
    elif isinstance(node, list):
        for item in node:
            collect_uses_refs(item, out)

# ── shell-сценарий → команды ───────────────────────────────────────────────────
# Служебные слова снимаются с начала команды: `then npm run x` — запуск `npm run x`.
KEYWORDS = {'if', 'then', 'else', 'elif', 'fi', 'while', 'until', 'do', 'done', 'case',
            'esac', 'for', 'select', 'in', 'time', '!', '{', '}'}


def split_commands(script):
    """Разбивает shell-сценарий на отдельные команды.

    Тело heredoc (`<<MARKER ... MARKER`) — данные, а не команды: оболочка его НЕ
    исполняет, и разборщик не должен считать строки тела командами. Признак
    входа в режим heredoc — `<<MARKER` (с необязательными `-`, `'`, `"`) на границе
    слова. Выход — строка, в которой после зачистки пробелов/табов стоит ровно
    маркер. Тело и маркер пропускаются, не разбиваясь на команды.
    """
    cmds, cur, quote, heredoc, i, n = [], [], None, None, 0, len(script)

    def flush():
        text = ''.join(cur).strip()
        cur.clear()
        if text:
            cmds.append(text)

    while i < n:
        # Режим heredoc: ищем маркер на отдельной строке, тело пропускаем.
        if heredoc is not None:
            nl = script.find('\n', i)
            if nl == -1:
                nl = n
            if script[i:nl].strip() == heredoc:
                heredoc = None
            i = nl + 1 if nl < n else n
            continue

        c = script[i]
        if quote:
            cur.append(c)
            if quote == "'":
                if c == "'":
                    quote = None
            elif c == '\\' and i + 1 < n:
                cur.append(script[i + 1])
                i += 1
            elif c == '"':
                quote = None
            i += 1
            continue
        if c == '\\':
            if i + 1 < n and script[i + 1] == '\n':
                cur.append(' ')  # перенос строки — команда продолжается, а не кончается
                i += 2
                continue
            cur.append(c)
            if i + 1 < n:
                cur.append(script[i + 1])
                i += 2
            continue
            i += 1
            continue
        if c in '"\'':
            quote = c
            cur.append(c)
            i += 1
            continue
        if c == '#' and (not cur or cur[-1].isspace()):
            while i < n and script[i] != '\n':
                i += 1
            continue
        if c == '&' and i + 1 < n and script[i + 1] == '>':
            cur.append(c)  # `&>file` — перенаправление
            i += 1
            continue
        if c == '&' and ''.join(cur).rstrip()[-1:] in ('>', '<'):
            cur.append(c)  # `2>&1` — тоже перенаправление
            i += 1
            continue

        # Heredoc: `<<MARKER`, `<<-MARKER`, `<<'MARKER'`, `<<"MARKER">>`.
        # Только на границе слова — иначе `a<<EOF` это не оператор перенаправления.
        if c == '<' and i + 1 < n and script[i + 1] == '<' and (not cur or cur[-1].isspace()):
            j = i + 2
            if j < n and script[j] == '-':
                j += 1
            qc = None
            if j < n and script[j] in '"\'':
                qc = script[j]
                j += 1
            m_start = j
            while j < n and (script[j].isalnum() or script[j] in '_-'):
                j += 1
            if j > m_start:
                marker = script[m_start:j]
                if qc and j < n and script[j] == qc:
                    j += 1
                # Маркер — часть команды: `cat <<EOF`, `tee <<-'EOF'`. Тело и финальный
                # маркер НЕ добавляются в cur — они не команды.
                cur.append(script[i:j])
                i = j
                heredoc = marker
                continue

        if c in '\n;&|':
            flush()
            if c in '&|;' and i + 1 < n and script[i + 1] == c:
                i += 1
            i += 1
            continue
        cur.append(c)
        i += 1
    flush()

    out = []
    for cmd in cmds:
        words = cmd.split()
        while words and words[0] in KEYWORDS:
            words.pop(0)
        if words:
            out.append(cmd[cmd.index(words[0]):].strip())
    return out


# ── формы ВНЕ разбираемого подмножества ────────────────────────────────────────
# `echo "$(npm run x)"`, `eval 'npm run x'`, `sh -c 'npm run x'`, `` `npm run x` ``, heredoc,
# `xargs`, конвейер в интерпретатор — всё это скрывает запуск за синтаксисом оболочки.
# Прежняя редакция пыталась извлечь внутренний скрипт и проверить его; арбитраж это отверг, и
# ревьюер предъявил почему: когда внутренний скрипт покрыт, а внешняя команда объявлена
# исключением, проверка молча соглашалась. Разбирать чужую оболочку до конца — не наш предмет;
# наш предмет — сказать правду о том, что мы не разбираем.
#
# Возвращает НАЗВАНИЕ конструкции (для сообщения) либо пустую строку.
HEREDOC_RE = re.compile(r'<<-?\s*[\'"]?[A-Za-z_][A-Za-z0-9_]*')
INTERP_RE = re.compile(r'(?:^|\s)(?:eval|exec)(?:\s|$)|(?:^|\s)(?:ba|da|z|k|)sh\s+-[a-z]*c(?:\s|$)')
XARGS_RE = re.compile(r'(?:^|\s)xargs(?:\s|$)')


def form_outside_subset(script):
    if '$(' in script:
        return 'подстановка команды $(...)'
    if '`' in script:
        return 'обратные кавычки'
    if HEREDOC_RE.search(script):
        return 'heredoc'
    if XARGS_RE.search(script):
        return 'xargs — что исполняется, приходит из stdin и барьеру не видно'
    if INTERP_RE.search(script):
        return 'запуск интерпретатора со скриптом в аргументе'
    return ''

# ── обход дерева и сбор команд ──────────────────────────────────────────────────
# Шаг 1: пройти `.github/**` и собрать все workflow-файлы (YAML).
# Шаг 2: для каждого workflow собрать `uses: ./<путь>` и разрешить их ОТНОСИТЕЛЬНО
#   каталога workflow (так работает сам `uses:`). Полученные локальные composite
#   actions добавляются в обход. Неразрешимый путь — отказ с названной причиной.
# Шаг 3: для каждого файла (workflow + локальные actions) разобрать YAML, собрать
#   `run:` шагов (условие `if:` не читается — каждый шаг считается исполняемым), разбить на команды
#   (с обработкой heredoc), развернуть непрозрачные обёртки (`$(...)`, обратные
#   кавычки, `eval`/`exec`, `bash -c`/`sh -c`), отказать на `xargs`.
all_files = []
for dirpath, _dirnames, filenames in os.walk(gh_dir):
    for name in sorted(filenames):
        if not (name.endswith('.yml') or name.endswith('.yaml')):
            continue
        path = os.path.join(dirpath, name)
        if not os.path.isfile(path):
            continue
        all_files.append(os.path.abspath(path))

local_action_files = set()
for wf_path in all_files:
    try:
        wf_doc = parse_yaml(wf_path)
    except Exception:
        continue
    uses_refs = []
    collect_uses_refs(wf_doc, uses_refs)
    wf_dir = os.path.dirname(wf_path)
    for uses_ref in uses_refs:
        candidate = os.path.normpath(os.path.join(wf_dir, uses_ref))
        action_file = None
        for aname in ('action.yml', 'action.yaml'):
            apath = os.path.join(candidate, aname)
            if os.path.isfile(apath):
                action_file = os.path.abspath(apath)
                break
        if action_file:
            local_action_files.add(action_file)
        else:
            fails.append(
                f'{wf_path}: uses {uses_ref} → {candidate} не содержит '
                f'action.yml/action.yaml — локальный composite action не обходится'
            )

for apath in sorted(local_action_files):
    if apath not in all_files:
        all_files.append(apath)

all_cmds = []
for path in all_files:
    try:
        doc = parse_yaml(path)
    except Exception as e:                                    # noqa: BLE001
        fails.append(f'{path} не разобран как YAML ({e}) — паритет по нему не сверить')
        continue
    runs = []
    collect_runs(doc, runs)
    for lineno, script in runs:
        # ФОРМА ВНЕ ПОДМНОЖЕСТВА — ОТКАЗ, а не разворачивание. Так предписал арбитраж
        # `verdicts/arbitration/oblast-i-porog.md` (вопрос 1, механизм 2), и ревьюер
        # (`verdicts/review/shag-5.md`, находка 2) предъявил, чем была прежняя редакция:
        # она извлекала вложенный скрипт и проверяла его — и когда вложенный скрипт был
        # ПОКРЫТ, а внешняя команда объявлена исключением, шаг проходил молча. То есть
        # `$(...)` работал выключателем сверки.
        #
        # Механизм объявляет РАЗБИРАЕМОЕ ПОДМНОЖЕСТВО shell: последовательности простых
        # команд, разделённых `&&`, `;`, `|`, переводами строк. Всё остальное барьер честно
        # не разбирает и говорит об этом правдой, а не выдуманным диагнозом: выход у автора
        # всегда есть — переписать шаг простыми командами (своему CI это доступно всегда)
        # либо оформить исключение на шаг с причиной.
        outside = form_outside_subset(script)
        if outside:
            fails.append(
                f'{path}:{lineno}: шаг вне разбираемого подмножества: {outside} — '
                f'перепишите простыми командами либо объявите исключение с причиной'
            )
            continue
        for cmd in split_commands(script):
            all_cmds.append((path, lineno, cmd))

with open(out_path, 'w', encoding='utf-8') as f:
    for path, lineno, cmd in all_cmds:
        if '\t' in cmd:
            fails.append(f'{path}:{lineno}: команда содержит табуляцию — учёт по TSV её не различает')
            continue
        f.write(f'{path}\t{lineno}\t{cmd}\t{" ".join(cmd.split())}\n')

with open(fails_path, 'a', encoding='utf-8') as f:
    for line in fails:
        f.write(line + '\n')
PY

# ── 3. разбор файла исключений ────────────────────────────────────────────────
# Формат строки: `<имя скрипта> = <причина>` или `команда: <текст> = <причина>`.
# Разделитель — первое ` = `; если его нет, первое `=` (текст команды сам может содержать
# `=`, например `export FOO=1`). Строка без `=` — отказ: причина обязана быть записана,
# иначе «объявленное исключение» превращается в молчаливую дыру. Комментарий — строка,
# начинающаяся с `#`.
#
# Отсечку отметки считает Python, а не bash с `tr`: `tr` работает по байтам, и
# в локали без UTF-8 кириллическая причина насчитала бы ноль букв — мера, зависящая от
# локали, врёт о предмете тем чаще, чем чище среда.
#
# Вывод — TSV `вид<TAB>ключ<TAB>причина`.
EXC_TSV="$RUN/exceptions.tsv"
python3 - "$EXCEPTIONS" "$EXC_TSV" "$PARSE_FAILS" <<'PY'
import re, sys

src, out_path, fails_path = sys.argv[1], sys.argv[2], sys.argv[3]
fails, recs, seen = [], [], set()

WORD_RE = re.compile(r'\w', re.UNICODE)
CMD_PREFIX = 'команда:'


def reason_weak(reason):
    """Порог обоснован в шапке барьера: причина — предложение, а не отметка о наличии."""
    words = [w for w in reason.split() if len([c for c in w if WORD_RE.match(c)]) >= 2]
    letters = sum(1 for c in reason if c.isalnum())
    return len(words) < 4 or letters < 24


with open(src, encoding='utf-8') as f:
    for raw in f:
        line = raw.rstrip('\n').rstrip('\r').strip()
        if not line or line.startswith('#'):
            continue
        if ' = ' in line:
            key, reason = line.split(' = ', 1)
        elif '=' in line:
            key, reason = line.split('=', 1)
        else:
            fails.append(f'строка исключения без «=»: {line}')
            continue
        key, reason = key.strip(), reason.strip()
        if key.startswith(CMD_PREFIX):
            kind, key = 'команда', ' '.join(key[len(CMD_PREFIX):].split())
        else:
            kind = 'скрипт'
        if not key:
            fails.append(f'исключение без имени: {line}')
            continue
        if not reason:
            fails.append(f'исключение без причины: {line}')
            continue
        if (kind, key) in seen:
            fails.append(f'исключение объявлено дважды: {key}')
            continue
        if reason_weak(reason):
            fails.append(f'псевдопричина у исключения «{key}»: «{reason}» — причина обязана '
                         f'называть, что мешает исполнять пункт в CI')
            continue
        seen.add((kind, key))
        recs.append((kind, key, reason))

with open(out_path, 'w', encoding='utf-8') as f:
    for kind, key, reason in recs:
        f.write(f'{kind}\t{key}\t{reason}\n')

with open(fails_path, 'a', encoding='utf-8') as f:
    for line in fails:
        f.write(line + '\n')
PY

declare -A EXC_SCRIPT      # имя скрипта -> причина
declare -A EXC_CMD         # схлопнутая команда -> причина
declare -A EXC_CMD_USED    # схлопнутая команда -> 1, если исключение сработало
while IFS=$'\t' read -r kind key reason; do
  [ -n "$key" ] || continue
  case "$kind" in
    команда) EXC_CMD["$key"]="$reason" ;;
    *)       EXC_SCRIPT["$key"]="$reason" ;;
  esac
done < "$EXC_TSV"

# Отказы разборщиков — сюда, в общий счёт.
while IFS= read -r msg; do
  [ -n "$msg" ] || continue
  bad "$msg"
done < "$PARSE_FAILS"

# ── 4. сверка в обе стороны ───────────────────────────────────────────────────
# Проход 1: каждая команда из `run:` либо пункт приёмки, либо объявленное исключение.
covered_keys=()
declare -A CI_COVERED_CMD  # схлопнутая команда -> 1, если она пункт приёмки
while IFS=$'\t' read -r path ln cmd norm; do
  [ -n "$cmd" ] || continue
  rel="${path#"$ROOT"/}"
  covered=0
  # `npm run <NAME>` и его официальный псевдоним `npm run-script <NAME>` — покрыто, если
  # NAME есть ключом в scripts.
  if [[ "$norm" =~ ^npm[[:space:]]+(run|run-script)[[:space:]]+([^[:space:]]+)([[:space:]].*)?$ ]]; then
    nm="${BASH_REMATCH[2]}"
    if [ -n "${SCRIPT_NAME[$nm]:-}" ]; then
      covered=1
      covered_keys+=("$nm")
    fi
  fi
  # Иначе — команда должна равняться значению какого-то скрипта целиком.
  if [ "$covered" -eq 0 ] && [ -n "${SCRIPT_VALUE[$norm]:-}" ]; then
    covered=1
    covered_keys+=("${SCRIPT_VALUE[$norm]}")
  fi
  if [ "$covered" -eq 1 ]; then
    CI_COVERED_CMD["$norm"]=1
    continue
  fi
  if [ -n "${EXC_CMD[$norm]:-}" ]; then
    EXC_CMD_USED["$norm"]=1
    ok "команда «$cmd» ($rel:$ln) приёмкой не является — объявленное исключение: ${EXC_CMD[$norm]}"
  else
    bad "$rel:$ln: команда «$cmd» есть в CI, но нет пункта в приёмке и не объявлена исключением"
  fi
done < "$WF_CMDS_TSV"

# Проход 2: каждый скрипт либо покрыт, либо объявлен исключением с причиной.
while IFS=$'\t' read -r name value vnorm; do
  [ -n "$name" ] || continue
  used=0
  for k in "${covered_keys[@]:-}"; do
    [ "$k" = "$name" ] && used=1
  done
  if [ "$used" -eq 1 ]; then
    # Исключение для скрипта, который CI и так запускает, ничего не разрешает.
    if [ -n "${EXC_SCRIPT[$name]:-}" ]; then
      bad "исключение «$name» недостижимо: скрипт запускается в CI — запись ничего не разрешает"
    fi
    continue
  fi
  if [ -n "${EXC_SCRIPT[$name]:-}" ]; then
    ok "скрипт «$name» не в CI — объявленное исключение: ${EXC_SCRIPT[$name]}"
  else
    bad "скрипт «$name» есть в приёмке, но отсутствует в CI и не объявлен исключением"
  fi
done < "$SCRIPTS_TSV"

# Проход 3: мёртвые записи. Обход отсортирован — порядок вывода не должен зависеть от
# порядка обхода хеш-таблицы, иначе один и тот же прогон печатает разное.
while IFS= read -r name; do
  [ -n "$name" ] || continue
  [ -n "${SCRIPT_NAME[$name]:-}" ] && continue
  bad "исключение «$name» названо для скрипта, которого нет в приёмке — мёртвая запись"
done < <(printf '%s\n' "${!EXC_SCRIPT[@]}" | sort)

while IFS= read -r c; do
  [ -n "$c" ] || continue
  if [ -n "${CI_COVERED_CMD[$c]:-}" ]; then
    bad "исключение для команды «$c» недостижимо: команда есть пункт приёмки — запись ничего не разрешает"
  elif [ -z "${EXC_CMD_USED[$c]:-}" ]; then
    bad "исключение для команды «$c» названо, но такой команды в CI нет — мёртвая запись"
  fi
done < <(printf '%s\n' "${!EXC_CMD[@]}" | sort)

# ── 5. итог ───────────────────────────────────────────────────────────────────
total_wf=$(wc -l < "$WF_CMDS_TSV" | tr -d ' ')
total_scripts=$(wc -l < "$SCRIPTS_TSV" | tr -d ' ')
total_exc=$(wc -l < "$EXC_TSV" | tr -d ' ')
printf '\nworkflow-команд: %d · скриптов в приёмке: %d · объявленных исключений: %d · расхождений: %d\n' \
  "$total_wf" "$total_scripts" "$total_exc" "$fails" >&2
if [ "$fails" -gt 0 ]; then
  exit 1
fi
