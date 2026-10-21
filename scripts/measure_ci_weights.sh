#!/usr/bin/env bash
# scripts/measure_ci_weights.sh — TSV замеров весов lane CI (контракт 114,
# «веса lane CI по замерам»). Мера READ-ONLY к GitHub: единственная запись —
# `--out` (по умолчанию <root>/registry/ci-zamery.tsv); ни байта в --root вне
# этого файла (арбитраж 114 П1/П2).
#
#   bash scripts/measure_ci_weights.sh [--root D] (--logs DIR | --repo O/R) \
#        [--out FILE] [--min-obs N] [--okno ID] [--runs N]
#
# Режимы:
#   корпус — --logs DIR: локальные файлы логов (батарея, воспроизводимость);
#   сеть   — --repo O/R (или GITHUB_REPOSITORY, или origin текущего клона):
#     зелёные завершённые прогоны workflow ci (по умолчанию --runs 20, свежие
#     первыми), их джобы ci (/legkij — имена матричных джоб GitHub усекает,
#     матч по префиксу), логи джоб по прецеденту zamer_087/Р2-7:
#     `gh run view --log` логов lane-джоб НЕ отдаёт. Транспорт — ТОЛЬКО
#     `gh api` ЧЕРЕЗ PATH (подменяемость источником-двойником).
#
# Правило веса: ceil(медиана ВСЕХ наблюдений ключа в окне) — медиана, НЕ
# максимум (выбросы рантайма: check:charter max 1957 с при p50 52.5).
# Вес ЦЕЛЫЙ по всей длине: медиана считается целочисленно (median_ceil), float
# не участвует — на соседних целых выше 2^53 float-деление теряет единицу, и
# вес уезжал на 1 вниз (грамматика веса [0-9]+, верхней границы нет).
# --min-obs — ТОЛЬКО порог достаточности («мало данных»), выборку он НЕ
# усекает: <n> в TSV — число наблюдений ключа в окне.
# У ключа наблюдений меньше --min-obs → rc 2 «мало данных»; строк замера нет
# вовсе → rc 2 «пустая выборка»; отказ транспорта — ВКЛЮЧАЯ отсутствия gh в
# PATH — rc 2 именованный («gh api отказ (…)»). Отказ АТОМАРНЫЙ: TSV не
# пишется (ни байта).
#
# Грамматика строки замера — 087 И-9 ДОСЛОВНО (единый источник
# scripts/run_ci_lane.sh / scripts/ci_vesa.sh; инвариант 114.1): «замер:
# <ключ> <сек>» в начале строки, допустимый префикс `<джоба>\t<шаг>\t`
# и/или `<ISO-время> `; «замер» середины строки замером НЕ является.
#
# Выход — TSV, закрытый алфавит, 4 поля через TAB:
#   <ключ>\t<вес>\t<n>\t<окно>      строки `#…` — комментарии
#   окно корпуса — --okno (по умолчанию 0); окно сети — run-id САМОГО
#   СТАРОГО использованного прогона (--okno там не действует).
#
# Коды возврата: 0 — TSV записан, 2 — отказ (мало данных / пустая выборка /
# отказ транспорта / неверные аргументы).
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

exec python3 - "$@" <<'PY'
import json, os, re, subprocess, sys

# Грамматика строки замера — 087 И-9 дословно (run_ci_lane.sh/ci_vesa.sh).
RE_ZAMER = re.compile(
    r'^(?:[^\t\n]*\t[^\t\n]*\t)?(?:\d{4}-\d\d-\d\dT[0-9:.]+Z )?'
    r'замер: ([a-z0-9][a-z0-9._:-]*) ([0-9]+)$')
RE_KEY = re.compile(r'^[a-z0-9][a-z0-9._:-]*$')

HEAD = '# registry/ci-zamery.tsv — замеры весов CI (контракт 114)\n'


def die(msg, rc=1):
    sys.stderr.write('ОТКАЗ: %s\n' % msg)
    sys.exit(rc)


def registry_keys(root):
    """Ключи step/legkij реестра (порядок строк реестра — он же порядок гварда)."""
    path = os.path.join(root, 'registry', 'ci-steps.tsv')
    if not os.path.isfile(path):
        die('нет реестра: %s' % path, 2)
    keys = []
    with open(path, encoding='utf-8') as f:
        for line in f.read().split('\n'):
            if not line or line.startswith('#'):
                continue
            p = line.split('\t')
            if len(p) >= 4 and p[0] in ('step', 'legkij'):
                if not RE_KEY.match(p[1]) or not p[2].isdigit():
                    die('реестр вне грамматики: %s' % line)
                keys.append(p[1])
    if not keys:
        die('реестр без строк step/legkij', 2)
    return keys


def median_ceil(v):
    """ceil(медиана) СТРОГО ЦЕЛОЧИСЛЕННО, без float вовсе: при нечётном n —
    средний элемент s[n//2], при чётном — ceil((lo + hi) / 2) = (lo + hi + 1)
    // 2 (сумма двух соседних целых выше 2^53 делилась float-ом, который их
    различать не умеет, — вес уезжал на единицу вниз, и гвард --migrate такой
    ложный вес принимал; грамматика TSV — [0-9]+, потолка секунд нет)."""
    s = sorted(v)
    n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2] + 1) // 2


def collect(text):
    """Строки замера одного лога → {ключ: [сек, …]} (порядок наблюдений = порядок строк)."""
    got = {}
    for line in text.split('\n'):
        m = RE_ZAMER.match(line.rstrip('\r'))
        if m:
            got.setdefault(m.group(1), []).append(int(m.group(2)))
    return got


def corpus(logs_dir):
    """Корпусный режим: наблюдения ключа — строки замера файлов каталога
    в порядке имён файлов (LC_ALL=C-детерминизм сортировки)."""
    if not os.path.isdir(logs_dir):
        die('нет каталога логов: %s' % logs_dir, 2)
    obs = {}
    for name in sorted(os.listdir(logs_dir)):
        path = os.path.join(logs_dir, name)
        if not os.path.isfile(path):
            continue
        with open(path, encoding='utf-8', errors='replace') as f:
            for k, vs in collect(f.read()).items():
                obs.setdefault(k, []).extend(vs)
    if not obs:
        die('пустая выборка: в логах нет строк «замер: <ключ> <секунды>»', 2)
    return obs


def gh_api(path):
    """ЕДИНСТВЕННЫЙ транспорт сетевой ветви: `gh api` ЧЕРЕЗ PATH (Б1 круга 2,
    инвариант 114.7 — подменяемость источником-двойником батареи). Отказ
    транспорта — rc 2 именованный: тихим отказом зелёным не бывает. Отсутствие
    самого gh в PATH — ТОЖЕ отказ транспорта (named rc 2, не traceback)."""
    try:
        p = subprocess.run(['gh', 'api', path], capture_output=True, text=True)
    except (FileNotFoundError, NotADirectoryError, PermissionError) as e:
        die('gh api отказ: нет gh в PATH (%s): %s' % (path, e), 2)
    if p.returncode != 0:
        die('gh api отказ (%d): %s: %s'
            % (p.returncode, path, p.stderr.strip()), 2)
    return p.stdout


def gh_json(path):
    raw = gh_api(path)
    try:
        return json.loads(raw)
    except ValueError as e:
        die('gh api отказ: нечитаемый ответ %s: %s' % (path, e), 2)


def network(repo, runs_limit):
    """Сетевой режим: зелёные завершённые прогоны workflow ci (свежие
    первыми, берём первые runs_limit) → джобы ci (/legkij → логи. Возврат:
    наблюдения и run-id самого старого использованного прогона (окно)."""
    data = gh_json('repos/%s/actions/runs?status=success&per_page=%d'
                   % (repo, max(runs_limit, 1)))
    ids = [r['id'] for r in data.get('workflow_runs', [])
           if r.get('name') == 'ci' and r.get('status') == 'completed'
           and r.get('conclusion') == 'success'][:runs_limit]
    if not ids:
        die('пустая выборка: зелёных завершённых прогонов workflow ci нет', 2)
    obs = {}
    for rid in ids:
        jdata = gh_json('repos/%s/actions/runs/%d/jobs?per_page=100' % (repo, rid))
        for j in jdata.get('jobs', []):
            name = j.get('name') or ''
            if not (name.startswith('ci (') or name.startswith('legkij')):
                continue
            for k, vs in collect(gh_api('repos/%s/actions/jobs/%d/logs'
                                        % (repo, j['id']))).items():
                obs.setdefault(k, []).extend(vs)
    if not obs:
        die('пустая выборка: в логах джоб ci (/legkij нет строк замера', 2)
    return obs, str(min(ids))


def repo_of(root):
    """Репозиторий по умолчанию: GITHUB_REPOSITORY, иначе origin текущего
    клона (`--repo` важнее обоих — явный аргумент)."""
    if os.environ.get('GITHUB_REPOSITORY'):
        return os.environ['GITHUB_REPOSITORY']
    p = subprocess.run(['git', '-C', root, 'config', '--get', 'remote.origin.url'],
                       capture_output=True, text=True)
    m = re.search(r'(?::|/)([^/:]+/[^/]+?)(?:\.git)?$', p.stdout.strip())
    return m.group(1) if m else None


def measure(root, logs, out, min_obs, okno, repo, runs):
    keys = registry_keys(root)
    if logs is not None:
        obs = corpus(logs)
    else:
        if not repo:
            die('сетевой режим: нужен --repo <owner>/<name> '
                '(или переменная GITHUB_REPOSITORY, или --logs <dir>)', 2)
        obs, okno = network(repo, runs)
    # Правило веса — ceil(медиана ВСЕХ наблюдений ключа в окне); min-obs выше —
    # ТОЛЬКО порог «мало данных», размер выборки он НЕ усекает, <n> в TSV —
    # число наблюдений окна (Adv114 №1). Корпус и сеть — одна мера.
    malo, rows = [], {}
    for k in keys:
        o = obs.get(k) or []
        if len(o) < min_obs:
            malo.append('%s (%d < %d)' % (k, len(o), min_obs))
            continue
        rows[k] = (median_ceil(o), len(o))
    if malo:
        die('мало данных: %s' % '; '.join(sorted(malo)), 2)
    if out is None:
        out = os.path.join(root, 'registry', 'ci-zamery.tsv')
    # Запись — только в out и только целиком: отказ до этой строки не оставил
    # в мире ни байта, а сама запись атомарна (tmp рядом с out + rename).
    tmp = out + '.tmp114'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(HEAD)
        for k in sorted(rows):
            f.write('%s\t%d\t%d\t%s\n' % (k, rows[k][0], rows[k][1], okno))
    os.replace(tmp, out)
    print('ok: замеры записаны: %d ключей, окно %s' % (len(rows), okno))
    return 0


def main():
    a = sys.argv[1:]
    root, logs, out = '.', None, None
    min_obs, okno, runs = 5, '0', 20
    repo = os.environ.get('GITHUB_REPOSITORY')
    i = 0
    while i < len(a):
        if a[i] in ('--root', '--logs', '--out', '--min-obs', '--okno',
                    '--repo', '--runs') and i + 1 < len(a):
            v = a[i + 1]
            if a[i] == '--root':
                root = v
            elif a[i] == '--logs':
                logs = v
            elif a[i] == '--out':
                out = v
            elif a[i] == '--min-obs':
                min_obs = int(v)
            elif a[i] == '--okno':
                okno = v
            elif a[i] == '--repo':
                repo = v
            else:
                runs = int(v)
            i += 2
            continue
        if a[i].startswith('--') and '=' in a[i]:
            k, v = a[i].split('=', 1)
            a[i:i + 1] = [k, v]
            continue
        die('measure: неизвестный аргумент: %s' % a[i], 2)
    if min_obs < 1 or runs < 1 or not okno.isdigit():
        die('measure: неверные --min-obs/--okno/--runs', 2)
    if logs is None and not repo:
        repo = repo_of(root)
    if logs is None and not repo:
        die('measure: сетевой режим требует --repo <owner>/<name> '
            '(или --logs <dir> для корпуса)', 2)
    return measure(root, logs, out, min_obs, okno, repo, runs)


if __name__ == '__main__':
    sys.exit(main())
PY