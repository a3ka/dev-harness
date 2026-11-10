#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ входа резолвера 054 v+1 (А10) — только то, что наблюдает Г1 122:
# репо-слой ТОЛЬКО <R>/.harness/harness.project.json; корневой рядом — P10; внутреннего нет — P1;
# реальный файл вне R (symlink наружу) — отказ границы; слой проекта из HARNESS_PROJECT_LAYER_ROOT
# (P2/P3), пин (P5); вывод — JSON с projectId (origin project) и repoId (origin repo).
# Подключается к модели генератора env CI_PROEKTA_122_RESOLVER (режим --model батареи);
# реальный генератор вызывает scripts/profile_resolver.sh своей установки.
set -u
R=
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) R=${2:-}; shift ;;
    *) printf 'profile ОТКАЗ: usage: profile_resolver.sh --repo <корень>\n' >&2; exit 1 ;;
  esac
  shift
done
[ -n "$R" ] && [ -d "$R" ] || { printf 'profile ОТКАЗ: каталог репо не существует: %s\n' "$R" >&2; exit 1; }
PYTHONDONTWRITEBYTECODE=1 python3 - "$R" <<'PY'
import json, os, sys
R = sys.argv[1]
def die(msg):
    sys.stderr.write('profile ОТКАЗ: ' + msg + '\n'); sys.exit(1)
internal = os.path.join(R, '.harness', 'harness.project.json')
legacy = os.path.join(R, 'harness.project.json')
if os.path.lexists(legacy) and os.path.lexists(internal):
    die('корневой harness.project.json рядом с .harness/harness.project.json: %s. Инструкция: удалите корневой профиль — fallback нет' % legacy)
if not os.path.lexists(internal):
    die('нет .harness/harness.project.json: %s. Инструкция: создайте .harness/harness.project.json в репо — состав ключей: scripts/profile_resolver.sh' % internal)
real = os.path.realpath(internal)
if not real.startswith(os.path.realpath(R) + os.sep):
    die('нет файла репо-слоя в корне репо: %s. Инструкция: .harness/harness.project.json должен лежать в репо — не symlink на внешний файл' % internal)
layer_root = os.environ.get('HARNESS_PROJECT_LAYER_ROOT', '')
if not layer_root or not os.path.isdir(layer_root):
    die('корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>')
try:
    repo = json.load(open(real))
except ValueError:
    die('файл не JSON: %s' % internal)
pin = repo.get('projectLayer') or {}
lp = os.path.join(layer_root, (pin.get('profilePath') or 'registry/harness-project.json').lstrip('/'))
if not os.path.isfile(lp):
    die('нет файла слоя проекта: %s' % lp)
try:
    layer = json.load(open(lp))
except ValueError:
    die('файл не JSON: %s' % lp)
if pin.get('version') != layer.get('version'):
    die("пин слоя проекта расходится: репо пинит '%s', слой несёт '%s'" % (pin.get('version'), layer.get('version')))
print(json.dumps({'projectId': {'value': layer.get('projectId'), 'origin': 'project'},
                  'repoId': {'value': repo.get('repoId'), 'origin': 'repo'}}))
PY
