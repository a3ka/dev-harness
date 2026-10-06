#!/usr/bin/env bash
# fixtures/ci_b_087/zamer_087.sh — приёмка 087 на ЖИВОМ CI как rc-предикат (контракт 087
# §Приёмка А4; прецедент timing_083.sh, уроки арбитража 083-krug2 П2: любой отказ чтения —
# rc 2 с id и stderr, непрочитанное не исключается из счёта).
#
#   bash fixtures/ci_b_087/zamer_087.sh <граничный-run-id> [<owner/repo>]   (cwd = корень,
#                                         история origin/main получена fetch)
#
# Окно — завершённые прогоны workflow ci, созданные ПОСЛЕ граничного прогона (граничный —
# первый прогон после лендинга 087, фиксирует оркестратор ДО приёмки). Пороги — числа здесь:
#   (1) ни одной тяжёлой джобы (ci*, antiplacebo*, obshchij, tyazhelyj-itog), отменённой
#       ПОСЛЕ старта (conclusion cancelled и ≥1 исполненный шаг), — в любом прогоне окна;
#   (2) push в main: тяжёлые джобы ВСЕ skipped (код приходит доказанным PR-прогоном), стена
#       created_at→updated_at ≤ 120 с;
#   (3) данных достаточно: ≥ 5 push-прогонов main в окне, из них ≥ 1 — приземление кода
#       (хеш кодового дерева head_sha ≠ хешу предыдущего push-прогона; оракул И-1).
# rc 0 — всё выполнено; rc 1 — именованное нарушение; rc 2 — данных нет/мало или чтение не
# удалось (НЕ зелёное: приёмка ждёт данных повтором команды, порог не обнуляется).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v gh >/dev/null 2>&1 || { printf 'НЕ СУДИМО: нет gh\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'НЕ СУДИМО: нет python3\n' >&2; exit 2; }
[ "$#" -ge 1 ] && [[ "$1" =~ ^[0-9]+$ ]] || { printf 'НЕ СУДИМО: граничный run-id — целое (аргумент 1)\n' >&2; exit 2; }
export PYTHONDONTWRITEBYTECODE=1
exec python3 - "$HERE/_orakul.py" "$@" <<'PY'
import json, os, re, subprocess, sys
from datetime import datetime
orak, bound = sys.argv[1], sys.argv[2]
repo = sys.argv[3] if len(sys.argv) > 3 else 'a3ka/dev-harness'
WALL_MAX, MIN_PUSH, MIN_LAND = 120, 5, 1
# Имя матричной джобы GitHub усекает (закрывающей скобки может не быть, замер 2026-10-06 —
# «antiplacebo (ap1, check_runner_hygiene …» без «)»): префикс «имя (», не полная скобка.
HEAVY = re.compile(r'^(?:ci|antiplacebo)(?:$| \()|^obshchij$|^tyazhelyj-itog$')
sys.path.insert(0, os.path.dirname(orak))
import _orakul as o

def nesudimo(msg):
    sys.stderr.write('НЕ СУДИМО: %s\n' % msg); sys.exit(2)

def gh(path, what):
    p = subprocess.run(['gh', 'api', path], capture_output=True)
    if p.returncode != 0:
        nesudimo('%s: gh api %s rc %d: %s' % (what, path, p.returncode, p.stderr.decode('utf-8', 'replace').strip()))
    try:
        return json.loads(p.stdout.decode('utf-8'))
    except Exception:
        nesudimo('%s: ответ gh не JSON: %r' % (what, p.stdout[:160]))

def ts(s):
    return datetime.strptime(s, '%Y-%m-%dT%H:%M:%SZ')

b = gh('repos/%s/actions/runs/%s' % (repo, bound), 'граничный прогон %s' % bound)
bt = ts(b['created_at'])
# Нефильтрованный список (фильтр workflow/event API отдаёт несогласованные выборки — замер
# архитектора 2026-10-06), три страницы по 100, отбор окна и имени workflow — здесь.
runs, seen = [], set()
for page in (1, 2, 3):
    for r in gh('repos/%s/actions/runs?per_page=100&page=%d' % (repo, page), 'список прогонов, стр. %d' % page)['workflow_runs']:
        if r['id'] not in seen and r.get('name') == 'ci':
            seen.add(r['id'])
            runs.append(r)
win = sorted([r for r in runs if ts(r['created_at']) > bt and r.get('status') == 'completed'],
             key=lambda r: r['created_at'])
if runs and min(ts(r['created_at']) for r in runs) > bt:
    nesudimo('окно длиннее трёх страниц списка прогонов: граница %s старше самого раннего прочитанного' % bound)
bad = []
pushes = []
for r in win:
    jobs = gh('repos/%s/actions/runs/%d/jobs?per_page=100&filter=latest' % (repo, r['id']), 'джобы прогона %d' % r['id'])['jobs']
    heavy = [j for j in jobs if HEAVY.match(j.get('name') or '')]
    for j in heavy:
        ran = any((s.get('status') == 'completed') for s in (j.get('steps') or []))
        if j.get('conclusion') == 'cancelled' and ran:
            bad.append('тяжёлая джоба отменена после старта: прогон %d, %s' % (r['id'], j['name']))
    if r.get('event') == 'push' and r.get('head_branch') == 'main':
        pushes.append(r)
        notskip = [j['name'] for j in heavy if j.get('conclusion') != 'skipped']
        if notskip:
            bad.append('тяжёлое на push в main: прогон %d (%s)' % (r['id'], ', '.join(notskip)))
        wall = (ts(r['updated_at']) - ts(r['created_at'])).total_seconds()
        if wall > WALL_MAX:
            bad.append('push в main проверялся %d с > %d: прогон %d' % (wall, WALL_MAX, r['id']))
lands = 0
for prev, cur in zip(pushes, pushes[1:]):
    try:
        hp = o.oracle_hash('.', prev['head_sha'], o.U87)
        hc = o.oracle_hash('.', cur['head_sha'], o.U87)
    except Exception as e:
        nesudimo('история не получена (fetch origin main): %s..%s: %s' % (prev['head_sha'][:12], cur['head_sha'][:12], e))
    if hp != hc:
        lands += 1
for x in bad:
    print('НАРУШЕНИЕ: %s' % x)
print('окно после %s: прогонов %d, push в main %d, приземлений кода %d, нарушений %d'
      % (bound, len(win), len(pushes), lands, len(bad)))
if bad:
    sys.exit(1)
if len(pushes) < MIN_PUSH:
    nesudimo('мало данных: push-прогонов main после границы %d < %d' % (len(pushes), MIN_PUSH))
if lands < MIN_LAND:
    nesudimo('мало данных: приземлений кода в окне %d < %d' % (lands, MIN_LAND))
sys.exit(0)
PY
