#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (Н-39): предполёт-полусмотр — проверяет только YAML-синтаксис,
# шаги не исполняет, working-directory не проверяет, секреты не сверяет, station-джобы
# не перечисляет. Наблюдаемое расхождение: p2 (несуществующий рабочий каталог), p3
# (падающий шаг), p4 (STATION-JOB), p5 (секрет вне ПРЕДПОСЫЛКИ) обязаны дать rc 1/маркер.
export PYTHONDONTWRITEBYTECODE=1
R=; WF=.github/workflows/ci.yml; JOB=; C=
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) R=$2; shift ;;
    --workflow) WF=$2; shift ;;
    --job) JOB=$2; shift ;;
    --contract) C=$2; shift ;;
  esac
  shift
done
python3 - "$R" "$WF" <<'PY'
import os, sys
try:
    import yaml
except Exception:
    print('preflight ОТКАЗ: python-yaml-nedostupen'); sys.exit(2)
R, WF = sys.argv[1], sys.argv[2]
wf = os.path.join(R, WF)
if not os.path.isfile(wf):
    print('preflight ОТКАЗ: workflow-otsutstvuet'); sys.exit(1)
try:
    doc = yaml.safe_load(open(wf))
except Exception:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
jobs = doc.get('jobs') if isinstance(doc, dict) else None
if not isinstance(jobs, dict) or not jobs:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
print('CIPREFLIGHT_OK jobs=%d station=0' % len(jobs))
PY
