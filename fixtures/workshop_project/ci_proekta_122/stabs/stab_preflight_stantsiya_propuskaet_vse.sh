#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (Н-39; дельта-205): «station — значит НЕ судить ВООБЩЕ»: обёртка над честной
# моделью — station-джобы ВЫРЕЗАЮТСЯ из одноразовой копии мира до суда: не только текст run
# и значения env (честная дельта-205), но и сверка объявленности secrets/vars по всему файлу
# (токены станции исчезают из текста) и разбор working-directory с realpath-границей.
# local-джобы судятся честной моделью без изменений; строки STATION-JOB и счётчик station
# дописывает обёртка — перечисление сохранено, обман узнаваем только сохранностью.
# Наблюдаемое расхождение (ровно эти клетки): p11-station-sekret-ne-perechislen и
# p11-station-var-ne-perechislena (необъявленные secret/variable станции обязаны отказать),
# p11-station-wd-vne-kopii (побег каталога станции), p5-station-sekret-ne-perechislen
# (боль 995 п.4), p2-working-directory-otsutstvuet (несуществующий рабочий каталог СТАНЦИИ e2e).
# Зелены: парные p11-run/env-station-propusk (пропуск на месте), p4, k-*, p5f/p6*/p7/p8/p9/p10
# (local-джобы и их поля честны), p11-station-yaml-nevaliden (YAML читается по всему файлу),
# p11-station-marker-ne-literal (маркер не литерал — джоба не вырезается и судится как local).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
R=; WF=.github/workflows/ci.yml; JOB=; C=
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) R=$2; shift ;;
    --workflow) WF=$2; shift ;;
    --job) JOB=$2; shift ;;
    --contract) C=$2; shift ;;
    *) printf 'preflight ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
if [ -z "$R" ]; then
  printf 'preflight ОТКАЗ: usage: ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C]\n' >&2
  exit 2
fi
export PYTHONDONTWRITEBYTECODE=1
TRAP=$(mktemp -d /tmp/dev-harness-verify/ci122-stab205-XXXX 2>/dev/null || mktemp -d) || exit 2
trap 'rm -rf "$TRAP"' EXIT
# разбор честен по всему файлу (workflow есть? YAML валиден? job найден?); имена станционных
# джоб (литерал 'station', как в классификации 122) и число остающихся local — в файлах
python3 - "$R" "$WF" "$JOB" "$TRAP" <<'PY'
import os, shutil, sys, yaml
R, WF, JOB, TRAP = sys.argv[1:5]
wf = os.path.join(R, WF)
if not os.path.isfile(wf):
    print('preflight ОТКАЗ: workflow-otsutstvuet'); sys.exit(1)
try:
    text = open(wf, encoding='utf-8').read()
    doc = yaml.safe_load(text)
except Exception:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
jobs = doc.get('jobs') if isinstance(doc, dict) else None
if not isinstance(jobs, dict) or not jobs:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
if JOB and JOB not in jobs:
    print('preflight ОТКАЗ: job-ne-najden: %s' % JOB); sys.exit(1)
stantsii = []
for n in ([JOB] if JOB else list(jobs)):
    j = jobs[n]
    e = j.get('env') if isinstance(j, dict) else None
    if isinstance(e, dict) and e.get('PREFLIGHT_CLASS') == 'station':
        stantsii.append(n)
for n in stantsii:
    del jobs[n]
open(TRAP + '/stantsii.txt', 'w', encoding='utf-8').write('\n'.join(stantsii))
open(TRAP + '/local.txt', 'w', encoding='utf-8').write(str(len(jobs)))
if jobs:  # мир без станции — в копии: R не мутируется
    mir = TRAP + '/mir'
    shutil.copytree(R, mir, ignore=shutil.ignore_patterns('.git'), symlinks=True)
    d = os.path.dirname(os.path.join(mir, WF))
    os.makedirs(d, exist_ok=True)
    open(os.path.join(mir, WF), 'w', encoding='utf-8').write(
        yaml.safe_dump(doc, sort_keys=False, allow_unicode=True))
PY
rc=$?
[ "$rc" = 0 ] || exit "$rc"
STANTSII=$(cat "$TRAP/stantsii.txt")
MESTNYH=$(cat "$TRAP/local.txt")
if [ "$MESTNYH" = 0 ]; then
  # вырезать было нечего судить: станции перечисляются, исполнение пусто
  for n in $STANTSII; do printf 'STATION-JOB: %s\n' "$n"; done
  printf 'CIPREFLIGHT_OK jobs=0 station=%d\n' "$(printf '%s\n' "$STANTSII" | grep -c .)"
  exit 0
fi
ARGS=(--repo "$TRAP/mir" --workflow "$WF")
[ -n "$JOB" ] && ARGS+=(--job "$JOB")
[ -n "$C" ] && ARGS+=(--contract "$C")
OUT=$(bash "$M" "${ARGS[@]}"); rc=$?
if [ "$rc" != 0 ]; then
  printf '%s\n' "$OUT"
  exit "$rc"
fi
for n in $STANTSII; do printf 'STATION-JOB: %s\n' "$n"; done
printf '%s\n' "$OUT" | grep -v '^CIPREFLIGHT_OK '
printf 'CIPREFLIGHT_OK jobs=%s station=%d\n' \
  "$(printf '%s\n' "$OUT" | sed -n 's/^CIPREFLIGHT_OK jobs=\([0-9]*\) station=.*/\1/p')" \
  "$(printf '%s\n' "$STANTSII" | grep -c .)"
exit 0
