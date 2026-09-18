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
# ОСТАТОЧНЫЙ РИСК ИНВАРИАНТА 4 (решение арбитража
# `verdicts/arbitration/contracts-020-iskljuchitelnost.md`): инвариант судит ТЕКСТ workflow,
# и три формы индирекции статически невидимы — (1) вложенная индирекция:
# литеральный `env`, чьё значение само содержит `$VAR`; (2) допустимые флаги npm
# между `npm` и `run`; (3) `${{ … }}`-выражение в позиции имени скрипта. Общая
# задача без исполнения неразрешима, перечисление форм за три круга адверсария не
# сошлось, дальнейшая гонка грамматики остановлена владельцем. Каждая из трёх форм
# ОПЛАЧЕНА: правило 6 отказывает с полным текстом команды, и зелёной её делает
# только дословная запись `команда: …` с причиной в
# `config/ci_parity_exceptions.txt` — та же обозримая читаемая поверхность, что у
# residual «отсечка отметки» выше. Четвёртая форма — шаг, дословно равный ЗНАЧЕНИЮ
# скрипта (`bash scripts/verify_antiplacebo.sh` без аргументов), — не оплачена, но
# и не вредна: это честный полный прогон вне матрицы (цена — минуты CI, не
# зелёное-на-красном); любой аргумент ломает равенство значению и требует записи.
# РЕВЬЮЕРУ: запись `команда:`, чей текст содержит `npm` вместе с
# `run`/`run-script` — с флагами, переменными или `${{ … }}` в любой позиции, —
# либо прямой вызов `verify_antiplacebo.sh`, НЕ исключение, а красный флаг:
# требуйте канонической формы `npm run check:antiplacebo -- --scope
# ${{ matrix.keys }}` или удаления шага. Атакующий, проводящий такую запись с
# ложной причиной мимо чтения, — класс само-компрометации проверяющего; граница
# принята владельцем.
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
# Контракт 020, инварианты 3 и 4: matrix-включения и запуск анти-плацебо.
MATRIX_TSV="$RUN/matrix.tsv"
ANTI_TSV="$RUN/antiplacebo.tsv"
python3 - "$GH" "$WF_CMDS_TSV" "$MATRIX_TSV" "$ANTI_TSV" "$PARSE_FAILS" <<'PY'
import os, re, sys

gh_dir, out_path, matrix_out, anti_out, fails_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
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

# ── разбор matrix и анти-плацебо (контракт 020, инв. 3, 4) ──────────────────
# Тот же обход `.github/**`, что для команд. parse_map ВОЗВРАЩАЕТ кортеж
# (val, lineno) на КАЖДОЕ значение в m[key], и сам `jobs`, `strategy`, `matrix`,
# `steps` тоже кортежи — внутренний dict берётся по индексу [0]. Скаляры
# (например, имя 'on' → None-подобное значение) пропускаются.
def _val(node):
    """Достаёт значение из кортежа (val, lineno) или возвращает None."""
    if isinstance(node, tuple) and len(node) >= 1:
        return node[0]
    return node


class _Unresolved(Exception):
    """Сигнал «переменная рядом с npm run статически не разрешима» — поднимается
    внутри callback'ов re.sub и ловится вокруг обоих проходов подстановки."""

    def __init__(self, name):
        super().__init__(name)
        self.name = name


# Индирекция имени npm-скрипта/бинарника (находка адверсария 020 к2): `npm run
# "$ANTI_SCRIPT"` и `"$NPM_BIN" run check:antiplacebo` — переменная НА МЕСТЕ,
# где грамматика контракта 020 (§Предмет п.1) требует статичное имя. Токен —
# `$NAME`, `${NAME}`, в одинарных или без кавычек; `${{ … }}` (GH-выражение,
# `matrix.keys` в --scope) НЕ совпадает: после `\$\{?` второй символ обязан
# быть буквой/подчёркиванием, а не ещё одной `{`. Позиция скрипта требует
# ЛИТЕРАЛЬНОГО `npm run`/`npm run-script` перед токеном; позиция бинарника —
# токен перед `run`/`run-script`. Одинарные кавычки (`'$FOO'`) не совпадают
# намеренно: shell их не раскрывает, это не индирекция.
NPM_BIN_VAR_RE = re.compile(r'("?\$\{?[A-Za-z_][A-Za-z0-9_]*\}?"?)(\s+run(?:-script)?\b)')
NPM_SCRIPT_VAR_RE = re.compile(r'(\bnpm\s+run(?:-script)?\s+)("?\$\{?[A-Za-z_][A-Za-z0-9_]*\}?"?)')
VAR_TOKEN_RE = re.compile(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}|\$([A-Za-z_][A-Za-z0-9_]*)')


def _var_name(tok):
    tok = tok.strip()
    if len(tok) >= 2 and tok[0] == '"' and tok[-1] == '"':
        tok = tok[1:-1]
    m = VAR_TOKEN_RE.fullmatch(tok)
    if not m:
        return None
    return m.group(1) or m.group(2)


def _literal_env_map(node):
    """`env:` как статическая карта имя→значение. Значение с `${{ … }}` внутри само
    неразрешимо статически (индирекция через GH-контекст, не через shell) и не
    включается — резолюции им нет, как если бы объявления не было вовсе."""
    out = {}
    if not isinstance(node, dict):
        return out
    for k, pair in node.items():
        v = _val(pair)
        if isinstance(v, str) and '${{' not in v:
            out[k] = v
    return out


def _resolve_npm_indirection(script, env_map):
    """Подставляет ЛИТЕРАЛЬНЫЕ env-объявления (шаг → джоба → workflow, уже
    смешаны в `env_map` с этим приоритетом на месте вызова) в командную
    позицию `npm run`/бинарника npm. Разрешённая переменная становится частью
    текста и дальше проверяется как всегда; неразрешённая — сигнал (script,
    имя) без изменений: та же переменная, что и подана, чтобы вызывающий
    код мог назвать её в отказе."""

    def sub_bin(m):
        tok, suffix = m.group(1), m.group(2)
        name = _var_name(tok)
        if name is None:
            return m.group(0)
        if name not in env_map:
            raise _Unresolved(name)
        return env_map[name] + suffix

    def sub_script(m):
        prefix, tok = m.group(1), m.group(2)
        name = _var_name(tok)
        if name is None:
            return m.group(0)
        if name not in env_map:
            raise _Unresolved(name)
        return prefix + env_map[name]

    try:
        out = NPM_BIN_VAR_RE.sub(sub_bin, script)
        out = NPM_SCRIPT_VAR_RE.sub(sub_script, out)
    except _Unresolved as e:
        return script, e.name
    return out, None

matrix_entries = []   # (path, lineno, jobname, shard, keys_str)
anti_cmds = []        # (path, lineno, jobname, cmd, has_scope_keys(0/1), in_matrix(0/1))
for path in all_files:
    try:
        doc = parse_yaml(path)
    except Exception:
        continue
    if not isinstance(doc, dict):
        continue
    jobs = _val(doc.get('jobs'))
    if not isinstance(jobs, dict):
        continue
    for jobname, jobval_t in jobs.items():
        jobval = _val(jobval_t)
        if not isinstance(jobval, dict):
            continue
        # matrix извлекается независимо от steps.
        strat = _val(jobval.get('strategy'))
        in_matrix = 0
        if isinstance(strat, dict):
            mx = _val(strat.get('matrix'))
            if isinstance(mx, dict):
                inc = _val(mx.get('include'))
                if isinstance(inc, list):
                    for entry_t in inc:
                        entry = _val(entry_t)
                        if not isinstance(entry, dict):
                            continue
                        shard_pair = entry.get('shard', ('', 0))
                        shard_val, _slno = _val(shard_pair), (shard_pair[1] if isinstance(shard_pair, tuple) else 0)
                        keys_pair = entry.get('keys', ('', 0))
                        keys_val, _klno = _val(keys_pair), (keys_pair[1] if isinstance(keys_pair, tuple) else 0)
                        if not isinstance(shard_val, str) or not shard_val:
                            fails.append(
                                f'{path}:{_slno}: matrix.include запись без shard — структурная ошибка шардирования'
                            )
                            continue
                        if not isinstance(keys_val, str) or not keys_val:
                            fails.append(
                                f'{path}:{_klno}: matrix.include запись shard={shard_val!r} без keys — структурная ошибка шардирования'
                            )
                            continue
                        matrix_entries.append((path, _slno, jobname, shard_val, keys_val))
                        in_matrix = 1
        # анти-плацебо: любой run-шаг, содержащий `npm run check:antiplacebo` или его
        # официальный псевдоним `npm run-script check:antiplacebo` — это одна и та же
        # команда (`npm run-script` — alias npm, признанный тем же барьером в правиле 6:
        # покрытие скриптом идёт через `^npm[[:space:]]+(run|run-script)[[:space:]]+…`).
        # Прежняя редакция искала литерал `npm run check:antiplacebo`, и сохранённый
        # прежний `--changed`-шаг через `npm run-script` проходил зелёным (находка
        # адверсария 020 к1): псевдоним в ANTI_TSV не попадал, исключительность матрицы
        # его не видела. Здесь обе формы сначала нормализуются к каноническому `npm run`,
        # и инвариант 4 (только шардный шаг с `--scope`) применяется одинаково — взаимная
        # исключительность обеих форм запуска: либо все запуски анти-плацебо — шардные
        # (через любой из псевдонимов), либо это красное.
        #
        # ИНДИРЕКЦИЯ ИМЕНИ/БИНАРНИКА (находка адверсария 020 к2): `npm run "$ANTI_SCRIPT"`
        # с `env: {ANTI_SCRIPT: check:antiplacebo}` и `"$NPM_BIN" run check:antiplacebo` с
        # `env: {NPM_BIN: npm}` исполняли скрытый запуск, а прежняя редакция видела только
        # ЛИТЕРАЛ `npm run check:antiplacebo` — переменная в командной позиции проходила
        # мимо совпадения по подстроке. Задача неразрешима в общем виде (значение
        # произвольной shell-переменной вычислить нельзя), поэтому решение —
        # fail-closed по тому же принципу, что уже действует для heredoc/xargs/eval
        # (см. `form_outside_subset`): единственный легальный способ узнать значение —
        # ЛИТЕРАЛЬНОЕ (не `${{ … }}`) объявление `env:` на этом шаге, его джобе или
        # workflow (`_resolve_npm_indirection`, приоритет шаг → джоба → workflow —
        # тот же порядок, каким его разрешил бы сам shell). Разрешённая переменная
        # подставляется и проверяется как обычный литерал теми же правилами ниже.
        # НЕРАЗРЕШЁННАЯ переменная — красное с её именем, БЕЗУСЛОВНО: `команда:`
        # исключение в `config/ci_parity_exceptions.txt` его не покрывает (это
        # инструмент правила 6, а не инварианта 4) — тестовое дерево к2 несло ровно
        # такое исключение, и барьер обязан был увидеть запуск независимо от него.
        # Прочие префиксы (`env npm run …`, `/usr/bin/env npm run …`, `npm exec -- npm
        # run …`) уже ловятся простым совпадением по подстроке (см. вердикт к2) —
        # префикс перед литеральным `npm run check:antiplacebo` совпадению не мешает.
        steps_val = _val(jobval.get('steps'))
        if isinstance(steps_val, list):
            for step_t in steps_val:
                step = _val(step_t)
                if not isinstance(step, dict):
                    continue
                run_pair = step.get('run', ('', 0))
                rv = _val(run_pair)
                rl = run_pair[1] if isinstance(run_pair, tuple) else 0
                if not isinstance(rv, str) or not rv.strip():
                    continue
                env_map = {}
                env_map.update(_literal_env_map(_val(doc.get('env', ({}, 0)))))
                env_map.update(_literal_env_map(_val(jobval.get('env', ({}, 0)))))
                env_map.update(_literal_env_map(_val(step.get('env', ({}, 0)))))
                # ИЗОЛЯЦИЯ КОМАНДЫ (находка ревьюера к3, БВ2/Н1): резолюция индирекции и
                # проверка --scope велись на ВСЁМ схлопнутом теле run: — посторонний
                # текст в run: (комментарий, соседняя команда), СОВПАДАЮЩИЙ с объявленным
                # исключением/--scope, легализовал ЧУЖОЙ несвязанный запуск. Разбираем тело
                # на отдельные команды ТЕМ ЖЕ `split_commands`, что и правило 6, и судим КАЖДУЮ
                # команду анти-плацебо ИЗОЛИРОВАННО.
                for part in split_commands(rv):
                    part_norm = ' '.join(part.split())
                    resolved_part, unresolved_var = _resolve_npm_indirection(part_norm, env_map)
                    if unresolved_var:
                        fails.append(
                            f'{path}:{rl}: шаг несёт нерасширенную индирекцию рядом с npm run '
                            f'(переменная {unresolved_var}) — исключительность запуска '
                            f'check:antiplacebo непроверяема; используйте статическое имя либо '
                            f'статически объявленный env (без ${{{{ … }}}}) на этом шаге, джобе '
                            f'или workflow'
                        )
                        continue
                    norm_for_anti = re.sub(r'\bnpm\s+run-script\b', 'npm run', resolved_part)
                    if 'npm run check:antiplacebo' not in norm_for_anti:
                        continue
                    has_scope_keys = 1 if ('--scope ${{ matrix.keys }}' in part_norm) else 0
                    anti_cmds.append((path, rl, jobname, part_norm, has_scope_keys, in_matrix))

with open(matrix_out, 'w', encoding='utf-8') as f:
    for path, lineno, jobname, shard, keys_str in matrix_entries:
        if '\t' in keys_str:
            fails.append(f'{path}:{lineno}: shard {shard!r} содержит табуляцию в keys — учёт по TSV не различит')
            continue
        for k in keys_str.split():
            if not k:
                continue
            f.write(f'{path}\t{lineno}\t{jobname}\t{shard}\t{k}\n')

with open(anti_out, 'w', encoding='utf-8') as f:
    for path, lineno, jobname, cmd, has_scope, in_matrix in anti_cmds:
        if '\t' in cmd:
            fails.append(f'{path}:{lineno}: команда анти-плацебо содержит табуляцию — учёт по TSV не различит')
            continue
        f.write(f'{path}\t{lineno}\t{jobname}\t{" ".join(cmd.split())}\t{has_scope}\t{in_matrix}\n')

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


# ── 4b. контракт 020 — инварианты шардирования ────────────────────────────
# Ключи вне шардного разбиения (ИМЕНОВАННЫЙ СПИСОК). Каждый такой ключ имеет
# каталог фикстур, НЕ должен быть в `keys:` ни одного шарда (включение туда
# ломает ап-шаг целиком: `npm run check:antiplacebo -- --scope … <key> …` →
# rc=1 «неизвестный ключ»), и прогонается раннером только в full-режиме.
# Молчаливый пропуск здесь был бы тем гейтом, что зеленее CI: сумма-инвариант
# не имел бы права их покрывать И одновременно не имел бы права требовать их
# покрытия — выбор между двумя провалами. Решение: ИМЕНОВАТЬ каждый такой
# ключ, и пропуск в проверке полноты от его имени — не молча.
#
# Сейчас два ключа вне шардного разбиения (UNSCOPABLE_KEYS) с разными причинами
# (образец — `check_metering`: Н-103 + слово владельца + cognitive-only компенсация)
# и один ключ с покрытием отдельным шагом вне matrix (SELF_COVERED_KEYS) — `verify_antiplacebo`,
# см. арбитраж c8aaa67, §Решение п.2:
#   `verify_antiplacebo` — сам-раннер анти-плацебо, НЕ БАРЬЕР по шапке.
#     Шапка `scripts/verify_antiplacebo.sh` одновременно содержит «Коды возврата:»
#     и «НЕ БАРЬЕР:» (последний — пример грамматики в документации); `header_role`
#     селектора `scope_select.sh` даёт `bp` (двусмысленный), `is_barrier` отказывает
#     на матче роли, ключ отвергается кодом 1 «неизвестный ключ». Включение его в
#     `keys:` любого шарда ломает ап-шаг целиком. 23 self-test case (`fixtures/
#     verify_antiplacebo/case_*.sh`) раннер НЕ гоняет на шардах — арбитраж c8aaa67
#     показал ложность прежней компенсации (scoped-прогоны раннера на каждом шарде
#     НЕ есть прогон сам-тестов: исполнение раннера не есть исполнение его 23 case
#     через FIFO-протокол). Изъятие из UNSCOPABLE_KEYS (ниже) и перенос в
#     SELF_COVERED_KEYS: покрытие — ОТДЕЛЬНЫМ шагом сам-тестов на минимальном
#     mktemp-корне (`.github/workflows/ci.yml` джоба `ci`, шаг «Сам-тесты раннера
#     анти-плацебо»). Шаг собирает корень из копии `scripts/verify_antiplacebo.sh` и
#     `fixtures/verify_antiplacebo/`, гоняет `npm run check:antiplacebo -- "$TMP_ROOT"`
#     (измер. 52 с стены, рецепт замера 5). Оплата шага — записью команда: в
#     `config/ci_parity_exceptions.txt` (та же механика, что у residual-оплат
#     инварианта 4); без ключа в `keys:` шарда (scope_select отверг бы ключ и сломал
#     матрицу); full-прогон отсутствует по дизайну (Н-48: дорого и не
#     масштабируется). Каталог `fixtures/verify_antiplacebo/` (23 case) остаётся,
#     покрытие — сам-тест-шагом, а не шардным анти-плацебо.
#   `gen-harness` — TS-барьер без `.sh`. `scripts/gen-harness.ts` (TypeScript), сам
#     барьер по шапке (`Коды возврата: 0 — …, 1 — …, 2 — …`); фикстуры `fixtures/
#     gen-harness/case_*.sh` (2 case) есть. `scope_select.sh` пытается открыть
#     `scripts/gen-harness.sh` через `is_barrier <name>` (hardcoded `.sh`, контракт 006
#     зона architect — фрозенный), awk падает на отсутствии файла, ключ отвергается
#     кодом 1 «неизвестный ключ». Включение в `keys:` любого шарда ломает ап-шаг.
#     КОМПЕНСАЦИЯ УЖЕ ЕСТЬ: `npm run check:gen` — отдельный CI шаг «Генератор ролей
#     под чек» (`.github/workflows/ci.yml:174`), запускается `node scripts/gen-harness.ts
#     --check` на каждом пуше, НЕ входит в анти-плацебо matrix. Замер: правка
#     `roles/*.md` без `gen:harness` ловится этим шагом (Н-92, рецидив грабель
#     9d5c081; регенерация ee85fb1). Покрытие фикстур `case_agent_poterjan.sh` и
#     `case_rogue_bez_markera.sh` обеспечено шагом «Генератор ролей под чек», а не
#     шардным анти-плацебо — обходного пути из CI нет, цена = одна строка `run:`.
#     Каталог `fixtures/gen-harness/` (2 case) остаётся.
#   `check_metering` — флейки-выброс (решение владельца 2026-09-17): требует
#     живого прокси/upstream, красная фаза зависает на healthz после рестарта
#     (`_restart_proxy_and_upstream`, замер 2026-09-17); маска Н-87 — в
#     --changed-CI почти не гейтил, полный прогон проходил раз; КОМПЕНСАЦИЯ:
#     ручной полный прогон перед done×4 (cognitive-only остаток до де-флейка —
#     хвост 017, очередь нормализации). Раннее размещение в отдельном шарде
#     ap6 (контракт 020 v3.1) давало ту же красную фазу, но маскировало её за
#     шардной изоляцией: один из пяти шардов краснел и перезапускался до зелёного,
#     полный прогон зеленел не с первого раза. В UNSCOPABLE_KEYS ключ
#     покрывается сумма-инвариантом, но НЕ гоняется в шардном режиме; full-прогон
#     снимает его вручную перед done×4. Каталог `fixtures/check_metering/` (22 case)
#     остаётся.
UNSCOPABLE_KEYS=(gen-harness check_metering)
declare -A IS_UNSCOPABLE=()
for k in "${UNSCOPABLE_KEYS[@]}"; do
  IS_UNSCOPABLE["$k"]=1
done
# Сам-тестовые ключи: покрыты ОТДЕЛЬНЫМ шагом CI вне matrix-джобы (НЕ через
# `keys:` шарда — `scope_select` отверг бы ключ, и матрица сломалась бы; см.
# шапку UNSCOPABLE_KEYS). Список — контрактный: ключ назван в шапке выше и
# оплачен записью команда: в `config/ci_parity_exceptions.txt`. Изъятие из
# UNSCOPABLE_KEYS (раньше лежал там же — «сам-раннер анти-плацебо», ложная
# компенсация scoped-прогонов) и перенос в SELF_COVERED_KEYS — арбитраж c8aaa67,
# §Решение п.2: покрытие обеспечено отдельным шагом сам-тестов на минимальном
# mktemp-корне.
SELF_COVERED_KEYS=(verify_antiplacebo)
declare -A IS_SELF_COVERED=()
for k in "${SELF_COVERED_KEYS[@]}"; do
  IS_SELF_COVERED["$k"]=1
done

FIXTURES="$ROOT/fixtures"
fixture_keys=()
if [ -d "$FIXTURES" ]; then
  while IFS= read -r d; do
    k="$(basename "$d")"
    if find "$d" -maxdepth 1 -type f -name 'case_*.sh' -print -quit | grep -q .; then
      fixture_keys+=("$k")
    fi
  done < <(find "$FIXTURES" -mindepth 1 -maxdepth 1 -type d | sort)
fi

# Накопители шардов: объявляются ДО веток, чтобы `set -u` не ловил их на чтении
# в ветке, которая не выполнилась бы.
declare -A SHARD_KEYS=()
declare -A KEY_SHARDS=()

while IFS=$'\t' read -r path ln jobname shard key; do
  [ -n "$key" ] || continue
  if [ -z "${SHARD_KEYS[$shard]:-}" ]; then
    SHARD_KEYS["$shard"]="$key"
  else
    SHARD_KEYS["$shard"]="${SHARD_KEYS[$shard]} $key"
  fi
  KEY_SHARDS["$key"]="${KEY_SHARDS[$key]:-} $shard"
done < "$MATRIX_TSV"

# 4b.1. Полнота в обе стороны — ИНВАРИАНТ 3.
# Сам-барьеры (UNSCOPABLE_KEYS) и сам-тестовые (SELF_COVERED_KEYS) исключены
# по ИМЕНИ из обеих сторон: они не должны быть в шарде (UNSCOPABLE — по
# технической/компенсационной причине, SELF_COVERED — покрыты отдельным шагом
# вне matrix), и их отсутствие в шарде не считается выпадением. Настоящие ключи
# (НЕ в UNSCOPABLE_KEYS и НЕ в SELF_COVERED_KEYS) проверяются как прежде.
# ОБРАЗЕЦ: `verify_antiplacebo` лежит в SELF_COVERED_KEYS — каталог
# `fixtures/verify_antiplacebo/` (23 case) есть, шардный запуск не объявлен
# (scope_select отверг бы ключ), покрытие — отдельным шагом сам-тестов на
# минимальном mktemp-корне (см. `ci.yml` джоба `ci`).
if [ "${#fixture_keys[@]}" -gt 0 ]; then
  if [ "${#SHARD_KEYS[@]}" -eq 0 ]; then
    sample=""
    for k in "${fixture_keys[@]}"; do
      if [ -z "${IS_UNSCOPABLE[$k]:-}" ] && [ -z "${IS_SELF_COVERED[$k]:-}" ]; then
        sample="$k"; break
      fi
    done
    if [ -n "$sample" ]; then
      bad "шардный запуск анти-плацебо не объявлен: fixtures/$sample есть, а matrix-джобы в .github/** нет"
    fi
  else
    covered_set="$(printf '%s\n' "${!KEY_SHARDS[@]}" | sort -u)"
    for k in "${fixture_keys[@]}"; do
      [ -n "${IS_UNSCOPABLE[$k]:-}" ] && continue
      [ -n "${IS_SELF_COVERED[$k]:-}" ] && continue
      if ! printf '%s\n' "$covered_set" | grep -qxF "$k"; then
        bad "$k не покрыт шардингом — ключ не назван ни одним шардом"
      fi
    done
  fi
fi

# Сторона «мёртвый ключ» + «дубль ключа».
while IFS=$'\t' read -r path ln jobname shard key; do
  [ -n "$key" ] || continue
  if [ ! -d "$FIXTURES/$key" ] || ! find "$FIXTURES/$key" -maxdepth 1 -type f -name 'case_*.sh' -print -quit | grep -q .; then
    bad "$key назван шардом $shard, но каталога fixtures/$key нет — мёртвый ключ"
    continue
  fi
  list="${KEY_SHARDS[$key]:-}"
  set -- $list
  if [ "$#" -gt 1 ]; then
    first="$1"; shift
    rest=""
    while [ $# -gt 0 ]; do rest="${rest:+$rest, }$1"; shift; done
    bad "$key приписан двум шардам: $first, $rest"
  fi
done < "$MATRIX_TSV"

# 4b.2. Исключительность шардного запуска — ИНВАРИАНТ 4.
# ОПЛАТА НЕ-ШАРДНОГО ЗАПУСКА (арбитраж c8aaa67): не-scoped запуск легален ⟺
# его дословный текст оплачен записью команда: в `config/ci_parity_exceptions.txt`.
# Поиск идёт по строкам сценария (`run:` одного шага может содержать несколько
# команд, разделённых `\n` — каждая отдельная запись в WF_CMDS_TSV; здесь мы
# берём строки `$cmd` тем же нормализованным ключом, что использует правило 6,
# и сверяем по EXC_CMD). ГРАБЛЯ (измерена в коде): правило 6 (:1043) уже
# покрывает `npm run <имя>` с аргументами, и без синхронизации счётчика
# EXC_CMD_USED запись для npm-команды осталась бы «недостижимой» по :1100.
# Синхронизация здесь: при совпадении нормы строки с EXC_CMD — помечаем
# EXC_CMD_USED (этот же счётчик ловит мёртвые/недостижимые записи ниже, и
# наша новая запись остаётся живой), пропускаем bad.
while IFS=$'\t' read -r path ln jobname cmd has_scope in_matrix; do
  [ -n "$cmd" ] || continue
  rel="${path#"$ROOT"/}"
  [ "$has_scope" -eq 1 ] && continue
  paid=0
  if [ -n "${EXC_CMD[$cmd]:-}" ]; then
    EXC_CMD_USED["$cmd"]=1
    paid=1
  fi
  [ "$paid" -eq 1 ] && continue
  if [ "$in_matrix" -eq 1 ]; then
    bad "$rel:$ln ($jobname): шардный запуск анти-плацебо не несёт --scope с ключами — форма: $cmd"
  else
    bad "$rel:$ln ($jobname): запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): $cmd"
  fi
done < "$ANTI_TSV"
# СЧЁТ МЁРТВЫХ И НЕДОСТИЖИМЫХ записей. EXC_CMD_USED — единый счётчик оплат
# команды где-либо в CI: правило 6 ставит его при совпадении текста команды с
# EXC_CMD (норма-форма, схлопнутые пробелы), ветвь 4b.2 (анти-плацебо
# исключительность) — при совпадении текста анти-плацебо-строки в run-шаге.
# Запись считается ЖИВОЙ, если EXC_CMD_USED[$c] выставлен хоть одной из ветвей
# (тогда пропускаем молча). Запись считается НЕДОСТИЖИМОЙ по правилу 6, если
# CI_COVERED_CMD[$c]=1 И EXC_CMD_USED не выставлен правилом 6 (значит, запись
# для команды, которую правило 6 и так покрывает скриптом — пустая трата
# строки). МЁРТВАЯ — если в CI её нет вовсе. ГРАБЛЯ (арбитраж c8aaa67): запись
# `команда: npm run check:antiplacebo -- "$TMP_ROOT"` формально покрывается
# правилом 6 как `npm run check:antiplacebo` (имя есть в scripts) — поэтому
# без синхронизации счётчика оплата осталась бы «недостижимой» именно здесь.
# Синхронизация в ветке 4b.2 (выше) — при совпадении анти-плацебо-строки с
# EXC_CMD — ставит EXC_CMD_USED, и эта ветка пропускает запись живой.
while IFS= read -r c; do
  [ -n "$c" ] || continue
  if [ -n "${EXC_CMD_USED[$c]:-}" ]; then
    :  # использована хоть одной ветвью — живая запись
  elif [ -n "${CI_COVERED_CMD[$c]:-}" ]; then
    bad "исключение для команды «$c» недостижимо: команда есть пункт приёмки и не использовано ветвью 4b.2 — запись ничего не разрешает"
  else
    bad "исключение для команды «$c» названо, но такой команды в CI нет — мёртвая запись"
  fi
done < <(printf '%s\n' "${!EXC_CMD[@]}" | sort)

# ── 5. итог ───────────────────────────────────────────────────────────────────
total_wf=$(wc -l < "$WF_CMDS_TSV" | tr -d ' ')
total_scripts=$(wc -l < "$SCRIPTS_TSV" | tr -d ' ')
total_exc=$(wc -l < "$EXC_TSV" | tr -d ' ')
total_matrix=$(wc -l < "$MATRIX_TSV" | tr -d ' ')
total_anti=$(wc -l < "$ANTI_TSV" | tr -d ' ')
printf '\nworkflow-команд: %d · скриптов в приёмке: %d · объявленных исключений: %d · matrix-ключей: %d · анти-плацебо-запусков: %d · расхождений: %d\n' \
  "$total_wf" "$total_scripts" "$total_exc" "$total_matrix" "$total_anti" "$fails" >&2
if [ "$fails" -gt 0 ]; then
  exit 1
fi
