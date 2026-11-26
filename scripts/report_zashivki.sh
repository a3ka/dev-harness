#!/usr/bin/env bash
# scripts/report_zashivki.sh — отчёт об остатке проектных зашивок в ядре (Ш-5ф,
# контракт 227). Только чтение: печатает один JSON-объект со счётчиками и полным
# списком совпадений; остаток НЕ является отказом и порогом не служит.
#
#   bash scripts/report_zashivki.sh
#
# Потребитель — штатный CI-шаг report:zashivki-227: команда вызывается как есть,
# без подавления rc (остаток не отказывает, отчёт всегда читаем по логу).
#
# Корень — репозиторий расположения скрипта; образец, области include/exclude и
# историческая база берутся из config/zashivki.json этого корня (R-0102: в коде
# нет литералов проектов). Include/exclude — буквальные относительные пути Git
# (файл либо поддерево): они передаются argv и не исполняются.
#
# Коды возврата:
#   0 — отчёт напечатан; rc 0 при ЛЮБОМ остатке (пустом, до базы, на базе и
#       сверх базы) — рост остатка виден по отчёту, а не отказом;
#   2 — NOT_IMPLEMENTED: операционная ошибка (недоступен Git, измерение не
#       закончено, конфиг не прочитан или бит). Ложного нуля не бывает: при
#       отказе stdout пуст, а stderr начинается с NOT_IMPLEMENTED:.
set -euo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

if [ "$#" -ne 0 ]; then
  printf 'NOT_IMPLEMENTED: ZASHIVKI_REPORT: публичный CLI без аргументов; получено %d\n' "$#" >&2
  exit 2
fi
command -v python3 >/dev/null 2>&1 || {
  printf 'NOT_IMPLEMENTED: ZASHIVKI_REPORT: нет python3\n' >&2
  exit 2
}
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd -P)" || {
  printf 'NOT_IMPLEMENTED: ZASHIVKI_REPORT: корень репозитория не найден\n' >&2
  exit 2
}

exec python3 -B - "$root" <<'PY'
"""227: read-only отчёт об остатке зашивок; измерение — настоящий git grep."""
import json
import subprocess
import sys
from pathlib import Path

CONFIG = 'config/zashivki.json'


def refuse(reason):
    """Именованный операционный отказ: rc 2, пустой stdout, диагностика в stderr."""
    sys.stderr.buffer.write(('NOT_IMPLEMENTED: ZASHIVKI_REPORT: ' + reason + '\n').encode('utf-8'))
    sys.stderr.buffer.flush()
    sys.exit(2)


def read_config(root):
    """Конфиг — единственный источник образца, областей и базы (R-0102)."""
    path = root / CONFIG
    try:
        raw = path.read_bytes()
    except OSError as error:
        refuse('конфиг не прочитан: ' + str(error))
    try:
        config = json.loads(raw)
    except ValueError as error:
        refuse('конфиг не разобран: ' + str(error))
    if not isinstance(config, dict):
        refuse('конфиг не объект JSON: ' + CONFIG)
    return config


def sample(config):
    value = config.get('pattern')
    if not isinstance(value, str) or not value:
        refuse('в конфиге нет непустого образца pattern')
    return value


def paths(config, name, minimum):
    """Список буквальных относительных путей Git; значения не исполняются."""
    value = config.get(name)
    if not isinstance(value, list) or len(value) < minimum:
        refuse('в конфиге нет списка путей ' + name)
    for item in value:
        if not isinstance(item, str) or not item:
            refuse('поле ' + name + ' содержит не-строку пути')
        if item.startswith('/') or '\0' in item:
            refuse('поле ' + name + ' содержит не-относительный путь: ' + repr(item))
        if any(part == '..' for part in item.split('/')):
            refuse('поле ' + name + ' содержит путь вне корня: ' + repr(item))
    return value


def baseline(config):
    """Историческая база переносится из конфига и не вычисляется из остатка."""
    value = config.get('baseline')
    if not isinstance(value, dict):
        refuse('в конфиге нет объекта baseline')
    return value


def measure(root, pattern, include, exclude):
    """Настоящий git grep: tracked рабочая копия, только текст, без кавычек путей."""
    argv = ['git', '-c', 'core.quotepath=false', 'grep', '--no-color', '-z', '-n', '-I',
            '-E', '-e', pattern, '--']
    argv += [':(top,literal)' + item for item in include]
    argv += [':(exclude,top,literal)' + item for item in exclude]
    try:
        result = subprocess.run(argv, cwd=str(root), capture_output=True)
    except OSError as error:
        refuse('git недоступен: ' + str(error))
    if result.returncode not in (0, 1):
        # rc 0 — есть совпадения, rc 1 — совпадений нет (успешный нулевой отчёт);
        # прочее — измерение не закончено, ложного нуля не печатаем.
        detail = result.stderr.decode('utf-8', 'replace').strip().replace('\n', ' | ')
        refuse('git grep rc=' + str(result.returncode) + ': ' + detail)
    return result.stdout


def parse(data):
    """Формат git grep -z: путь NUL номер NUL строка LF — порядок Git сохраняется."""
    matches = []
    while data:
        parts = data.split(b'\0', 2)
        if len(parts) != 3:
            refuse('вывод git grep не разобран')
        path, number, rest = parts
        text, _, data = rest.partition(b'\n')
        try:
            line = int(number)
        except ValueError:
            refuse('вывод git grep: не номер строки: ' + repr(number))
        try:
            matches.append({'path': path.decode('utf-8'), 'line': line,
                            'text': text.decode('utf-8')})
        except UnicodeError as error:
            refuse('вывод git grep: не UTF-8: ' + str(error))
    return matches


def main():
    root = Path(sys.argv[1])
    config = read_config(root)
    pattern = sample(config)
    include = paths(config, 'include', 1)
    exclude = paths(config, 'exclude', 0)
    base = baseline(config)
    matches = parse(measure(root, pattern, include, exclude))
    report = {'lines': len(matches), 'files': len({item['path'] for item in matches}),
              'matches': matches, 'baseline': base}
    sys.stdout.buffer.write(json.dumps(report, ensure_ascii=False).encode('utf-8') + b'\n')
    sys.stdout.buffer.flush()
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError) as error:
        refuse('измерение не закончено: ' + str(error))
PY
