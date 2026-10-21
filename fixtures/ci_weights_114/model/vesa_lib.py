#!/usr/bin/env python3
# vesa_lib.py — ЧЕСТНАЯ МОДЕЛЬ предмета 114 «веса lane CI по замерам» (батарея
# fixtures/ci_weights_114/, контракт 114). Реализация implementer —
# scripts/check_ci_weights.sh + scripts/measure_ci_weights.sh — несёт ту же
# грамматику и те же правила.
#
# ЕДИНЫЙ ИСТОЧНИК грамматики строки замера — 087 И-9 (scripts/ci_vesa.sh,
# run_ci_lane.sh): «замер: <ключ> <секунды>» в начале строки, допустимый
# префикс — `<джоба>\t<шаг>\t` и/или `<ISO-время> `; «замер» середины строки
# замером НЕ является (приманка клетки т11/стаба s8).
#
# TSV замеров (registry/ci-zamery.tsv) — закрытый алфавит, 4 поля через TAB:
#   <ключ>\t<вес>\t<n>\t<окно>
#     ключ  — [a-z0-9][a-z0-9._:-]* (та же грамматика, что у строки замера);
#     вес   — [0-9]+ (ceil медианы последних n наблюдений);
#     n     — [0-9]+ (число наблюдений окна);
#     окно  — [0-9]+ (run-id самого старого использованного прогона).
#   Строки `#…` и пустые — комментарии/пустышки, игнорируются. Байт данных
#   (ключ) разделителем (TAB) не является: ключ класса выше двоеточие НЕ
#   содержит... ключ МОЖЕТ содержать `:`, но не TAB — алфавит замкнут по
#   классу, TAB в ключе нематчится RE_KEY.
#
# Правила (гвард check_ci_weights.sh):
#   г1 покрытие: каждому ключу step/legkij реестра — строка TSV;
#   г2 расхождение: max(вес/замер, замер/вес) > 3 — красное, ДВУСТОРОННЕЕ;
#   г3 свежесть: TSV закоммичен (git log по пути) и возраст ≤ 30 дней.
#   Порядок г1→г2→г3, побеждает первая красная с именованной причиной.
#   Режим --migrate [--base F] (круг 2 Б2/Б3, приёмка первичной правки):
#     г0 с --base: реестр отличается от базы ТОЛЬКО третьими полями строк
#       step/legkij (lanes/shard/uchet/комментарии/число строк — побайтово);
#     г2-м: ТОЧНОЕ равенство каждого веса столбцу <вес> TSV (не допуск 3×);
#     постоянный гвард CI остаётся режимом без флага.
#
# Правила (мера measure_ci_weights.sh, корпус-режим --logs):
#   наблюдения ключа — строки замера логов каталога в порядке имён файлов;
#   вес = ceil(медиана ВСЕХ наблюдений окна) — frozen :45 «последних 20
#   зелёных прогонов», :99/:178 «последних ≥5 наблюдений» = все наблюдения
#   окна последних зелёных прогонов
#   (круг 3, Rev114 Б1/В1: хвост o[-min-obs:] брал СТАРЕЙШИЕ при порядке
#   API «свежие первыми»); min-obs (по умолчанию 5) — ТОЛЬКО порог «мало
#   данных», НЕ размер выборки; ключей с наблюдениями меньше min-obs НЕТ
#   или строк замера нет вообще — rc 2 «мало данных» / «пустая выборка»,
#   TSV НЕ пишется (атомарно: отказ = ни байта); <n> — число наблюдений
#   окна (Adv114 №1: n=5 у всех ключей — стёртая выборка, не окно).
#
# Правила (мера, сетевой режим — без --logs, круг 2 Б1):
#   источник — ТОЛЬКО `gh api` ЧЕРЕЗ PATH (подменяемость: gh-двойник батареи
#   т17 кладётся первым в PATH); runs → jobs (`ci (`/`legkij`) → logs;
#   отказ транспорта — rc 2 именованный, В ТОМ ЧИСЛЕ отсутствие gh в PATH
#   (круг 3, Adv114 №2: FileNotFoundError — именованный rc 2, не traceback
#   rc 1); окно = run-id старейшего прогона. Запись — только в out (по
#   умолчанию registry/ci-zamery.tsv); мера не меняет ни байта в root вне
#   этого файла (клетка т18, Б3).
import json
import math
import os
import re
import statistics
import subprocess
import sys
import time

RE_ZAMER = re.compile(
    r'^(?:[^\t\n]*\t[^\t\n]*\t)?(?:\d{4}-\d\d-\d\dT[0-9:.]+Z )?'
    r'замер: ([a-z0-9][a-z0-9._:-]*) ([0-9]+)$')

RE_KEY = re.compile(r'^[a-z0-9][a-z0-9._:-]*$')

FRESH_DAYS = 30   # г3: возраст последнего коммита TSV замеров
X_RAZ = 3         # г2: расхождение БОЛЕЕ чем в 3 раза — красное (ровно 3 — зелёное)


def die(msg, rc=1):
    sys.stderr.write('ОТКАЗ: %s\n' % msg)
    sys.exit(rc)


def read_registry(root):
    if not os.path.isfile(os.path.join(root, 'registry', 'ci-steps.tsv')):
        die('нет реестра: %s' % os.path.join(root, 'registry', 'ci-steps.tsv'), 2)
    out = []
    with open(os.path.join(root, 'registry', 'ci-steps.tsv'), encoding='utf-8') as f:
        for line in f.read().split('\n'):
            if not line or line.startswith('#'):
                continue
            p = line.split('\t')
            if len(p) >= 4 and p[0] in ('step', 'legkij'):
                if not RE_KEY.match(p[1]) or not p[2].isdigit():
                    die('реестр вне грамматики: %s' % line)
                out.append((p[1], int(p[2])))
    if not out:
        die('реестр без строк step/legkij', 2)
    return out


def read_zamery(path):
    if not os.path.isfile(path):
        die('нет TSV замеров: %s' % path)
    z = {}
    with open(path, encoding='utf-8') as f:
        for i, line in enumerate(f.read().split('\n'), 1):
            if not line or line.startswith('#'):
                continue
            p = line.split('\t')
            if (len(p) != 4 or not RE_KEY.match(p[0])
                    or not p[1].isdigit() or not p[2].isdigit()
                    or not p[3].isdigit()):
                die('TSV замеров вне грамматики, строка %d: %s' % (i, line))
            z[p[0]] = (int(p[1]), int(p[2]), p[3])
    return z


def registry_lines(path):
    if not os.path.isfile(path):
        die('нет реестра: %s' % path, 2)
    with open(path, encoding='utf-8') as f:
        return f.read().split('\n')


def check_delta(base_path, root):
    """г0 миграции (Б3): реестр отличается от базы ТОЛЬКО третьими полями
    строк step/legkij; lanes/shard/uchet/комментарии/число строк/порядок —
    побайтово неизменны."""
    b = registry_lines(base_path)
    h = registry_lines(os.path.join(root, 'registry', 'ci-steps.tsv'))
    if len(b) != len(h):
        die('состав реестра изменился: число строк %d -> %d' % (len(b), len(h)))
    for n, (lb, lh) in enumerate(zip(b, h), 1):
        pb, ph = lb.split('\t'), lh.split('\t')
        if pb and pb[0] in ('step', 'legkij'):
            if not ph or ph[0] != pb[0] or len(pb) != len(ph) \
                    or pb[:2] != ph[:2] or pb[3:] != ph[3:]:
                die('состав реестра изменился: %s %s (строка %d)'
                    % (pb[0], pb[1] if len(pb) > 1 else '?', n))
        elif lb != lh:
            name = pb[0] if pb and pb[0] else 'строка'
            die('состав реестра изменился: %s (строка %d)' % (name, n))


def guard(root, migrate=False, base=None):
    if base:
        check_delta(base, root)
    reg = read_registry(root)
    z = read_zamery(os.path.join(root, 'registry', 'ci-zamery.tsv'))
    missing = sorted(k for k, _ in reg if k not in z)
    if missing:
        die('нет замера: %s' % ' '.join(missing))
    diff = []
    for k, w in reg:
        vz = z[k][0]
        if migrate:
            # г2-м (миграция, Б2): ТОЧНОЕ равенство каждого веса столбцу TSV;
            # постоянный допуск дрейфа <=3x — другой режим (без --migrate).
            if w != vz:
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
        else:
            # г2 расхождение (двусторонне, более чем в X РАЗ). Гранулярность
            # таймера run_ci_lane — ЦЕЛЫЕ СЕКУНДЫ: саб-секундные шаги меряются
            # 0. Сравнение по ЭФФЕКТИВНЫМ значениям w'=max(w,1), z'=max(z,1):
            # вес 1 при замере 0 расхождением НЕ является (замер 2026-10-21:
            # 7 честных саб-секундных ключей иначе красили бы гвард ложно).
            we, ze = max(w, 1), max(vz, 1)
            if max(we / ze, ze / we) > X_RAZ:
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
    if diff:
        if migrate:
            die('вес не по замеру (миграция): %s' % '; '.join(sorted(diff)))
        die('вес не по замеру: %s' % '; '.join(sorted(diff)))
    p = subprocess.run(
        ['git', '-C', root, 'log', '-1', '--format=%ct', '--',
         'registry/ci-zamery.tsv'],
        capture_output=True, text=True)
    if p.returncode != 0 or not p.stdout.strip():
        die('TSV замеров не закоммичен: git log молчит по registry/ci-zamery.tsv')
    age_days = (int(time.time()) - int(p.stdout.strip())) // 86400
    if age_days > FRESH_DAYS:
        die('TSV замеров устарел: %d дней > %d — прогони scripts/measure_ci_weights.sh'
            % (age_days, FRESH_DAYS))
    print('ok: веса по замеру%s: %d ключей'
          % (' (миграция)' if migrate else '', len(reg)))
    return 0


def parse_logs(logs_dir):
    if not os.path.isdir(logs_dir):
        die('нет каталога логов: %s' % logs_dir, 2)
    obs = {}
    for name in sorted(os.listdir(logs_dir)):
        path = os.path.join(logs_dir, name)
        if not os.path.isfile(path):
            continue
        with open(path, encoding='utf-8', errors='replace') as f:
            for line in f.read().split('\n'):
                m = RE_ZAMER.match(line.rstrip('\r'))
                if m:
                    obs.setdefault(m.group(1), []).append(int(m.group(2)))
    if not obs:
        die('пустая выборка: строк «замер: <ключ> <секунды>» нет', 2)
    return obs


def gh_api(path):
    """Единственный транспорт сетевой ветви: `gh api` ЧЕРЕЗ PATH (Б1, круг 2):
    подменяемость источником-двойником; отказ транспорта — rc 2 именованный
    (пусто-зеленым тихий отказ не бывает); отсутствие gh в PATH — тот же
    именованный rc 2, не traceback rc 1 (круг 3, Adv114 №2)."""
    try:
        p = subprocess.run(['gh', 'api', path], capture_output=True, text=True)
    except FileNotFoundError:
        die('gh api отказ: нет gh в PATH: %s' % path, 2)
    if p.returncode != 0:
        die('gh api отказ (%d): %s: %s' % (p.returncode, path, p.stderr.strip()), 2)
    return p.stdout


def fetch_network(repo, runs_limit):
    """Сетевой режим: зелёные завершённые прогоны workflow ci (свежие
    первыми, берём первые runs_limit), их джобы ci (/legkij, логи по
    прецеденту zamer_087), строки замера той же грамматики. Возврат:
    наблюдения и run-id старейшего использованного прогона (окно)."""
    data = json.loads(gh_api('repos/%s/actions/runs?status=success&per_page=%d'
                             % (repo, max(runs_limit, 1))))
    ids = [r['id'] for r in data.get('workflow_runs', [])
           if r.get('name') == 'ci' and r.get('status') == 'completed'
           and r.get('conclusion') == 'success'][:runs_limit]
    if not ids:
        die('пустая выборка: зелёных завершённых прогонов workflow ci нет', 2)
    obs = {}
    for rid in ids:
        jdata = json.loads(gh_api('repos/%s/actions/runs/%d/jobs?per_page=100'
                                  % (repo, rid)))
        for j in jdata.get('jobs', []):
            name = j.get('name') or ''
            if not (name.startswith('ci (') or name.startswith('legkij')):
                continue
            log = gh_api('repos/%s/actions/jobs/%d/logs' % (repo, j['id']))
            for line in log.split('\n'):
                m = RE_ZAMER.match(line.rstrip('\r'))
                if m:
                    obs.setdefault(m.group(1), []).append(int(m.group(2)))
    return obs, str(min(ids))


def measure(root, logs_dir, out_path, min_obs, okno, repo=None, runs=20):
    reg = read_registry(root)
    if logs_dir is not None:
        obs = parse_logs(logs_dir)
    else:
        if not repo:
            die('сетевой режим: нужен --repo <owner>/<name> '
                '(или переменная GITHUB_REPOSITORY)', 2)
        obs, okno = fetch_network(repo, runs)
    malo, rows = [], {}
    for k, _w in reg:
        o = obs.get(k) or []
        if len(o) < min_obs:
            malo.append('%s (%d < %d)' % (k, len(o), min_obs))
            continue
        # медиана ВСЕХ наблюдений окна (круг 3, Rev114 Б1/В1): min-obs выше —
        # ТОЛЬКО порог «мало данных», не размер выборки; <n> — число
        # наблюдений окна (Adv114 №1), не min-obs.
        rows[k] = (int(math.ceil(statistics.median(o))), len(o))
    if malo:
        die('мало данных: %s' % '; '.join(sorted(malo)), 2)
    if out_path is None:
        out_path = os.path.join(root, 'registry', 'ci-zamery.tsv')
    tmp = out_path + '.tmp114'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write('# registry/ci-zamery.tsv — замеры весов CI (контракт 114)\n')
        for k in sorted(rows):
            f.write('%s\t%d\t%d\t%s\n' % (k, rows[k][0], rows[k][1], okno))
    os.replace(tmp, out_path)
    print('ok: замеры записаны: %d ключей, окно %s' % (len(rows), okno))
    return 0


def main():
    a = sys.argv[1:]
    if a and a[0] == 'guard':
        root, migrate, base = '.', False, None
        i = 1
        while i < len(a):
            if a[i] == '--root' and i + 1 < len(a):
                root = a[i + 1]; i += 2
            elif a[i].startswith('--root='):
                root = a[i][7:]; i += 1
            elif a[i] == '--migrate':
                migrate = True; i += 1
            elif a[i] == '--base' and i + 1 < len(a):
                base = a[i + 1]; i += 2
            elif a[i].startswith('--base='):
                base = a[i][7:]; i += 1
            else:
                die('guard: неизвестный аргумент: %s' % a[i], 2)
        sys.exit(guard(root, migrate, base))
    if a and a[0] == 'measure':
        root, logs, out = '.', None, None
        min_obs, okno = 5, '0'
        repo, runs = os.environ.get('GITHUB_REPOSITORY'), 20
        i = 1
        while i < len(a):
            if a[i] == '--root' and i + 1 < len(a):
                root = a[i + 1]; i += 2
            elif a[i].startswith('--root='):
                root = a[i][7:]; i += 1
            elif a[i] == '--logs' and i + 1 < len(a):
                logs = a[i + 1]; i += 2
            elif a[i] == '--out' and i + 1 < len(a):
                out = a[i + 1]; i += 2
            elif a[i] == '--min-obs' and i + 1 < len(a):
                min_obs = int(a[i + 1]); i += 2
            elif a[i] == '--okno' and i + 1 < len(a):
                okno = a[i + 1]; i += 2
            elif a[i] == '--repo' and i + 1 < len(a):
                repo = a[i + 1]; i += 2
            elif a[i] == '--runs' and i + 1 < len(a):
                runs = int(a[i + 1]); i += 2
            else:
                die('measure: неизвестный аргумент: %s' % a[i], 2)
        if not min_obs >= 1 or not okno.isdigit() or runs < 1:
            die('measure: неверные --min-obs/--okno/--runs', 2)
        if logs is None and not repo:
            die('measure: сетевой режим требует --repo <owner>/<name> '
                '(или --logs <dir> для корпуса)', 2)
        sys.exit(measure(root, logs, out, min_obs, okno, repo, runs))
    die('использование: vesa_lib.py guard [--root D] [--migrate [--base F]] | '
        'measure --root D (--logs D | --repo O/R) [--out F] '
        '[--min-obs N] [--okno ID] [--runs N]', 2)


if __name__ == '__main__':
    main()
