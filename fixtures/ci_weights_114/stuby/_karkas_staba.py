#!/usr/bin/env python3
# _karkas_staba.py — КАРКАС правдоподобной реализации предмета 114 для обманных
# стабов (прецедент 113 _karkas_staba.sh: каркас — НЕ копия честной модели, а
# правдоподобный кандидат; точка лжи одна на стаб, выбирается переменной
# ST114_LIE; вне точки лжи каркас ведёт себя как честная модель).
# Хелперы грамматики/парсинга импортируются из model/vesa_lib.py (единый
# источник грамматики 087 И-9 — второй реализации кольца нет).
#
# Точки лжи (привязка стаб↔клетка — в KARTA red_114.sh, по коду, Н-39):
#   s1 гвард «всегда-зелёный»   — не читает вход, rc 0 всегда;
#   s2 гвард «односторонний»    — красит только завышение (вес > 3×замер);
#   s3 гвард «само-оракул»      — замер берёт из ВЕСА реестра (tautology);
#   s4 гвард «без свежести»     — г1/г2 честные, г3 отсутствует;
#   s5 мера «максимум»          — вес = max, не медиана;
#   s6 мера «floor»             — округление вниз, не вверх;
#   s7 мера «мало-данных-зелё»  — порог min-obs не проверяется, TSV пишется;
#   s8 мера «подстрочник»       — «замер:» ищется подстрокой где угодно в строке;
#   s9 мера «сеть-без-источника» — сетевой режим: TSV из весов реестра, gh НЕ
#                                  вызывается (Б1 круга 2); корпус честен;
#   s10 мера «писатель»          — честный TSV + побочная правка lanes в
#                                  реестре мира (Б3 круга 2; критик w6/w7/w11).
#   s11 мера «писатель-по-режиму» — честный TSV; побочный ФАЙЛ registry/
#                                  measure-debug.log ТОЛЬКО в сетевом вызове
#                                  ИЛИ при явном --out (арбитраж 114, П3).
import math
import os
import statistics
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import vesa_lib as V  # noqa: E402

LIE = os.environ.get('ST114_LIE', '')


def _honest_guard(root):
    return V.guard(root)


def _lie_guard(root):
    reg = V.read_registry(root)
    z = V.read_zamery(os.path.join(root, 'registry', 'ci-zamery.tsv'))
    missing = sorted(k for k, _ in reg if k not in z)
    if missing:
        V.die('нет замера: %s' % ' '.join(missing))
    if LIE == 's3':
        z = {k: (w, 5, '0') for k, w in reg}
    diff = []
    for k, w in reg:
        vz = z[k][0]
        we, ze = max(w, 1), max(vz, 1)
        if LIE == 's2':
            if we > 3 * ze:
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
        else:
            if max(we / ze, ze / we) > V.X_RAZ:
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
    if diff:
        V.die('вес не по замеру: %s' % '; '.join(sorted(diff)))
    if LIE != 's4':
        p = V.subprocess.run(
            ['git', '-C', root, 'log', '-1', '--format=%ct', '--',
             'registry/ci-zamery.tsv'],
            capture_output=True, text=True)
        if p.returncode != 0 or not p.stdout.strip():
            V.die('TSV замеров не закоммичен: git log молчит по registry/ci-zamery.tsv')
        age_days = (int(V.time.time()) - int(p.stdout.strip())) // 86400
        if age_days > V.FRESH_DAYS:
            V.die('TSV замеров устарел: %d дней > %d' % (age_days, V.FRESH_DAYS))
    print('ok: веса по замеру: %d ключей' % len(reg))
    return 0


def _lie_parse_logs(logs_dir):
    if not os.path.isdir(logs_dir):
        V.die('нет каталога логов: %s' % logs_dir, 2)
    obs = {}
    for name in sorted(os.listdir(logs_dir)):
        path = os.path.join(logs_dir, name)
        if not os.path.isfile(path):
            continue
        with open(path, encoding='utf-8', errors='replace') as f:
            for line in f.read().split('\n'):
                if LIE == 's8':
                    i = line.find('замер: ')
                    if i < 0:
                        continue
                    rest = line[i + len('замер: '):].split()
                    if len(rest) == 2 and rest[0] and rest[1].isdigit():
                        obs.setdefault(rest[0], []).append(int(rest[1]))
                else:
                    m = V.RE_ZAMER.match(line.rstrip('\r'))
                    if m:
                        obs.setdefault(m.group(1), []).append(int(m.group(2)))
    if not obs:
        V.die('пустая выборка: строк «замер: <ключ> <секунды>» нет', 2)
    return obs


def _side_write_lanes(root):
    """s10: побочная запись — после честного TSV меняет lanes в реестре мира
    (обход критика «writer-changes-registry»: батарея была зелёной)."""
    path = os.path.join(root, 'registry', 'ci-steps.tsv')
    with open(path, encoding='utf-8') as f:
        lines = f.read().split('\n')
    out, done = [], False
    for ln in lines:
        if not done and ln.startswith('lanes\t'):
            out.append('lanes\t8')
            done = True
        else:
            out.append(ln)
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))

def _side_write_file(root):
    """s11: побочная запись ФАЙЛОМ, не lanes (г0 --base её не ловит) —
    registry/measure-debug.log; только сетевой вызов или явный --out
    (арбитраж 114, П3; класс обходов writer-extra/writer-explicit)."""
    path = os.path.join(root, 'registry', 'measure-debug.log')
    with open(path, 'w', encoding='utf-8') as f:
        f.write('network measurement complete\n')


def _lie_measure(root, logs_dir, out_path, min_obs, okno, repo=None, runs=20):
    if LIE == 's9' and logs_dir is None:
        # сеть-без-источника: TSV фабрикуется из весов реестра, gh не вызывается
        reg = V.read_registry(root)
        okno2 = okno if okno and okno != '0' else '401'
        dst = out_path or os.path.join(root, 'registry', 'ci-zamery.tsv')
        tmp = dst + '.tmp114k'
        with open(tmp, 'w', encoding='utf-8') as f:
            f.write('# registry/ci-zamery.tsv — замеры весов CI (контракт 114)\n')
            for k, w in sorted(reg):
                f.write('%s\t%d\t%d\t%s\n' % (k, w, min_obs, okno2))
        os.replace(tmp, dst)
        print('ok: замеры записаны: %d ключей, окно %s' % (len(reg), okno2))
        return 0
    if logs_dir is None:
        rc = V.measure(root, None, out_path, min_obs, okno, repo, runs)
        if LIE == 's10' and rc == 0:
            _side_write_lanes(root)
        if LIE == 's11' and rc == 0:
            _side_write_file(root)
        return rc
    reg = V.read_registry(root)
    explicit_out = out_path is not None  # s11: --out задан явно (до подстановки default)
    obs = _lie_parse_logs(logs_dir)
    rows = {}
    for k, _w in reg:
        o = obs.get(k) or []
        if LIE != 's7' and len(o) < min_obs:
            V.die('мало данных: %s (%d < %d)' % (k, len(o), min_obs), 2)
        if not o:
            continue
        lastn = o[-min_obs:] if len(o) >= min_obs else o
        if LIE == 's5':
            ves = max(lastn)
        elif LIE == 's6':
            ves = int(math.floor(statistics.median(lastn)))
        else:
            ves = int(math.ceil(statistics.median(lastn)))
        rows[k] = (ves, len(lastn))
    if out_path is None:
        out_path = os.path.join(root, 'registry', 'ci-zamery.tsv')
    tmp = out_path + '.tmp114k'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write('# registry/ci-zamery.tsv — замеры весов CI (контракт 114)\n')
        for k in sorted(rows):
            f.write('%s\t%d\t%d\t%s\n' % (k, rows[k][0], rows[k][1], okno))
    os.replace(tmp, out_path)
    print('ok: замеры записаны: %d ключей, окно %s' % (len(rows), okno))
    if LIE == 's10':
        _side_write_lanes(root)
    if LIE == 's11' and explicit_out:
        _side_write_file(root)
    return 0


def main():
    a = sys.argv[1:]
    if a and a[0] == 'guard':
        if LIE == 's1':
            print('ok: веса по замеру (каркас)')
            return 0
        if LIE in ('s2', 's3', 's4'):
            return _lie_guard(a[1] if len(a) > 1 and not a[1].startswith('--') else
                              (a[2] if '--root' in a else '.'))
        return _honest_guard(a[1] if len(a) > 1 and not a[1].startswith('--') else
                             (a[2] if '--root' in a else '.'))
    if a and a[0] == 'measure':
        kw = {}
        i = 1
        while i < len(a):
            if i + 1 < len(a) and a[i] in ('--root', '--logs', '--out', '--min-obs',
                                            '--okno', '--repo', '--runs'):
                kw[a[i]] = a[i + 1]
                i += 2
            else:
                i += 1
        return _lie_measure(kw.get('--root', '.'), kw.get('--logs'), kw.get('--out'),
                            int(kw.get('--min-obs', '5')), kw.get('--okno', '0'),
                            kw.get('--repo') or os.environ.get('GITHUB_REPOSITORY'),
                            int(kw.get('--runs', '20')))
    V.die('использование: _karkas_staba.py guard|measure …', 2)


if __name__ == '__main__':
    sys.exit(main())
