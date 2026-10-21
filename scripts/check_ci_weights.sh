#!/usr/bin/env bash
# scripts/check_ci_weights.sh — офлайн-гвард весов lane CI (контракт 114,
# «веса lane CI по замерам»): реестр registry/ci-steps.tsv против TSV замеров
# registry/ci-zamery.tsv. СЕТИ НЕТ — сеть только в scripts/measure_ci_weights.sh
# (инвариант 114.4).
#
#   bash scripts/check_ci_weights.sh [--root D]
#   bash scripts/check_ci_weights.sh [--root D] --migrate [--base <реестр-до-пачки>]
#
# Порядок г1→г2→г3, побеждает ПЕРВАЯ красная с именованной причиной:
#   г1 покрытие — каждому ключу step/legkij строка TSV
#      (нет → rc 1 «нет замера: <ключи>»);
#   г2 расхождение ДВУСТОРОННЕЕ: max(вес,замер)/min > 3 — красное с именем
#      ключа и обоими числами; сравнение по эффективным значениям max(w,1),
#      max(z,1) (таймер run_ci_lane — ЦЕЛЫЕ СЕКУНДЫ, честный саб-секундный
#      шаг меряется 0 и расхождением не является); ровно 3× — зелёное;
#      сравнение ЦЕЛОЧИСЛЕННОЕ max(w,z) > 3 * min(w,z) — эквивалент для
#      положительных целых и без float, который на числах выше 2^53
#      округлял расхождение 3×+1 ровно в 3× (пропуск красного);
#   г3 свежесть — TSV закоммичен (git log -1 --format=%ct по пути молчит →
#      rc 1 «не закоммичен») и возраст последнего коммита ≤ 30 дней
#      (больше → rc 1 «устарел» — прогони scripts/measure_ci_weights.sh).
# TSV вне грамматики — именованный отказ rc 1 «вне грамматики» (разбор входа
# предшествует г1: непроверяемый TSV не судим ни одним из трёх гейтов).
# Зелёное НЕМОЛЧАЛИВОЕ: rc 0 печатает ok-строку с числом сверенных ключей.
#
# Режим --migrate [--base F] — приёмка ПЕРВИЧНОЙ правки весов (отличается от
# постоянного гварда CI тремя пунктами):
#   г0 с --base — реестр отличается от базы ТОЛЬКО третьими полями строк
#     step/legkij (состав шагов/ключей, команды, lanes, shard/uchet,
#     комментарии, число строк и порядок — побайтово неизменны; нарушение →
#     rc 1 «состав реестра изменился: <имя> (строка N)»);
#   г1 покрытия — как в постоянном гварде;
#   г2-м ТОЧНОЕ равенство: вес каждого ключа step/legkij == вес столбца TSV
#     (нарушение → rc 1 «вес не по замеру (миграция): <ключ> (реестр W,
#     замер Z)»; и 2×TSV, и ±1 красны — инвариант 114.8);
#   г3 свежести — как в постоянном гварде.
# Постоянный допуск дрейфа ≤3× — отдельный режим БЕЗ флага; он не заменяет
# миграцию и не ослабляется ею. Гвард 114 НЕ отменяет scripts/ci_vesa.sh
# --check (087) и не закрывает его открытую А8: 114 судит типичное время
# (медиана), 087 — воспроизведение логов приёмки (максимум).
#
# Коды возврата: 0 — зелёное, 1 — именованный отказ, 2 — нет входа (реестр/
# TSV отсутствуют, неизвестный аргумент).
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

exec python3 - "$@" <<'PY'
import os, re, subprocess, sys, time

RE_KEY = re.compile(r'^[a-z0-9][a-z0-9._:-]*$')

FRESH_DAYS = 30   # г3: возраст последнего коммита TSV замеров, дней
X_RAZ = 3         # г2: расхождение БОЛЕЕ чем в X раз — красное (ровно 3 — зелёное)


def die(msg, rc=1):
    sys.stderr.write('ОТКАЗ: %s\n' % msg)
    sys.exit(rc)


def registry_lines(path):
    if not os.path.isfile(path):
        die('нет реестра: %s' % path, 2)
    with open(path, encoding='utf-8') as f:
        return f.read().split('\n')


def registry_weights(root):
    """[(ключ, вес)] в порядке строк реестра (порядок строк — порядок сверки)."""
    out = []
    for line in registry_lines(os.path.join(root, 'registry', 'ci-steps.tsv')):
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
    """Разбор TSV замеров — структурная сверка (полная строка, не подстрока)."""
    if not os.path.isfile(path):
        die('нет TSV замеров: %s' % path)
    z = {}
    with open(path, encoding='utf-8') as f:
        for i, line in enumerate(f.read().split('\n'), 1):
            if not line or line.startswith('#'):
                continue
            p = line.split('\t')
            if (len(p) != 4 or not RE_KEY.match(p[0]) or not p[1].isdigit()
                    or not p[2].isdigit() or not p[3].isdigit()):
                die('TSV замеров вне грамматики, строка %d: %s' % (i, line))
            z[p[0]] = (int(p[1]), int(p[2]), p[3])
    return z


def check_delta(base_path, root):
    """г0 миграции: реестр отличается от базы ТОЛЬКО третьими полями строк
    step/legkij; lanes/shard/uchet/комментарии/число строк/порядок — побайтово."""
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


def check_fresh(root):
    """г3: TSV закоммичен и не старше 30 дней."""
    p = subprocess.run(
        ['git', '-C', root, 'log', '-1', '--format=%ct', '--',
         'registry/ci-zamery.tsv'], capture_output=True, text=True)
    if p.returncode != 0 or not p.stdout.strip():
        die('TSV замеров не закоммичен: git log молчит по registry/ci-zamery.tsv')
    age = (int(time.time()) - int(p.stdout.strip())) // 86400
    if age > FRESH_DAYS:
        die('TSV замеров устарел: %d дней > %d — прогони '
            'scripts/measure_ci_weights.sh' % (age, FRESH_DAYS))


def guard(root, migrate, base):
    if base:
        check_delta(base, root)
    reg = registry_weights(root)
    z = read_zamery(os.path.join(root, 'registry', 'ci-zamery.tsv'))
    # г1 покрытие.
    missing = sorted(k for k, _ in reg if k not in z)
    if missing:
        die('нет замера: %s' % ' '.join(missing))
    # г2 расхождение: миграция — ТОЧНОЕ равенство; постоянный гвард —
    # двусторонний порог «более чем в 3 раза» по эффективным значениям.
    diff = []
    for k, w in reg:
        vz = z[k][0]
        if migrate:
            if w != vz:
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
        else:
            we, ze = max(w, 1), max(vz, 1)
            # max/min > X_RAZ ЦЕЛОЧИСЛЕННО: для положительных целых это ровно
            # max > X_RAZ * min, а float-деление на соседних целых выше 2^53
            # округляло настоящее расхождение 3×+1 ровно в 3.0 — гвард молчал
            # зелёным. Ни одного float в г2.
            if max(we, ze) > X_RAZ * min(we, ze):
                diff.append('%s (реестр %d, замер %d)' % (k, w, vz))
    if diff:
        die('вес не по замеру%s: %s'
            % (' (миграция)' if migrate else '', '; '.join(sorted(diff))))
    check_fresh(root)
    print('ok: веса по замеру%s: %d ключей'
          % (' (миграция)' if migrate else '', len(reg)))
    return 0


def main():
    a = sys.argv[1:]
    root, base, migrate = '.', None, False
    i = 0
    while i < len(a):
        if a[i] in ('--root', '--base') and i + 1 < len(a):
            if a[i] == '--root':
                root = a[i + 1]
            else:
                base = a[i + 1]
            i += 2
            continue
        if a[i].startswith('--') and '=' in a[i]:
            k, v = a[i].split('=', 1)
            a[i:i + 1] = [k, v]
            continue
        if a[i] == '--migrate':
            migrate = True
            i += 1
            continue
        die('check: неизвестный аргумент: %s' % a[i], 2)
    return guard(root, migrate, base)


if __name__ == '__main__':
    sys.exit(main())
PY