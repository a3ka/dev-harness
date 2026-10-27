#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Срез-батарея 109 v5: число миграций — из манифеста репозитория продукта;
frozen-тег lane-гигиены — из окружения CI (STEND109_TAG), без зашитой
константы (слово владельца 2026-10-27).

Грамматика W (контракт 109 §Приёмочный критерий, v5):
  (без флага), без --repo/--base и STEND109_BASE → rc 1 SUBJECT_ABSENT
      с перечнем всех клеток среза (зелень без субъекта невозможна);
  (без флага) --repo R / $STEND109_BASE → ЖИВОЙ срез на R: оракул N из
      манифеста R, полный CLI-прогон probe.py на R в PATH без docker
      (docker-факты — честный NEEDS_ENV, граница печатается; lane-факт
      без STEND109_TAG — честный STEND109_TAG_ABSENT rc 2 по имени),
      клетки миров/отказов/сценариев ledger/тегов на порождаемых копиях R;
      клетка ci:zhivoj — ЖИВОЙ ci.yml чекаута R: STEND109_TAG обязан
      быть объявлен на уровне JOB stend109 (jobs.stend109.env); env
      только в шаге клона — красная клетка с именем (дефект
      предпосылки, живой прогон 27.10: шаг lane env не наследует,
      проба отказала бы STEND109_TAG_ABSENT; правка — зона
      implementer, ПРЕДПОСЫЛКИ контракта);
  --model    контроль на порождаемых мирах базы (--base/$STEND109_BASE):
             N ∈ {1, 14, 15, 17, база, база+1} — оракул каждого мира
             вычислен из ЕГО манифеста ДО вызова субъекта (правило 8);
             сценарии ledger: зелено/недокат/перекат/подложный/пустой;
             отказы манифеста: отсутствует/пуст/нечитаем/лишний файл;
             теговые клетки (v5): порождаемые раннером H-checkout'ы с
             тегами frozen/contracts/109/N, N ∈ {4, 5, 17} — зелёное
             (тег == HEAD), старый тег/чужой коммит (MISMATCH), кривая
             форма, whitespace вокруг/внутри тега, ведущий ноль (FORM);
             grep-клетка: в судящем коде нет константы тега;
             клетки предпосылки ci (v5-доработка): носители — живые
             байты ci.yml продукта (ci_nositeli/, пин source.json,
             порча — rc 2 ORACLE_TAMPERED): job-env (уровень
             jobs.stend109.env) → verdikt «job», шаг-env (main
             бэкенда: env только в шаге клона) → verdikt «shag» —
             привязка зелено/красно кодом структурного разбора, не
             прозой контракта (Н-39); носители — входы (живые байты
             продукта), grep-клетка тега их не судит — пиньуются
             байтами;
  --stabs    контроль --model + 9 обманных стабов (мутации probe.py
             КОДОМ, Н-39; привязки — stab_vhod source.json): каждый
             обязан расходиться с честной пробой ровно на своей
             привязке; рассинхрон множеств/порча пина — rc 2
             ORACLE_TAMPERED.

Окружение среза: python3 + node + git; docker НЕ нужен и НЕ вызывается
(транспорт ledger — подложный docker/psql замкнутого алфавита сценариев;
теговые клетки идут в PATH-ферме без docker — зелёная ветка тега честно
упирается в docker-границу lane-факта, станцию не грузит; живой docker
остаётся lane stend109 / станции стенда — «не проверено живьём»
объявляется, а не подменяется зелёным). Сеть не нужна.

Коды возврата: 0 — срез зелен; 1 — SUBJECT_ABSENT либо красная клетка
либо стаб прошёл (НЕ ПОЙМАН); 2 — нечем проверять (нет базы для
--model/--stabs, ORACLE_TAMPERED, STAB_ANCHOR_MISSING).
"""
import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROBE = HERE / 'probe.py'
SOURCE = HERE / 'source.json'
MODEL_MANIFEST = HERE / 'model' / 'manifest.json'
DOCKER_SHIM = r'''#!/usr/bin/env bash
# Подложный docker среза 109 v4: замкнутый алфавит stend_up_fact
# (compose version | up -d --wait | exec psql | down -v); всё иное — 127.
# Сценарий задаётся env: SCENARIJ_UP_RC, SCENARIJ_LEDGER, SCENARIJ_ROLE,
# SCENARIJ_ROWS, SCENARIJ_ROWS2 (вторая выдача строк ledger — подложный
# сценарий различает их). Журнал вызовов — оракул раннера (не stderr
# субъекта).
z="${SCENARIJ_ZHURNAL:?}"
printf 'docker %s\n' "$*" >>"$z"
if [ "${1:-}" = compose ] && [ "${2:-}" = version ]; then exit 0; fi
if [ "${1:-}" = compose ]; then
  case "$*" in
    *'up -d --wait'*) exit "${SCENARIJ_UP_RC:-0}" ;;
    *'down -v'*) exit 0 ;;
    *'exec -T '*'sh -lc '*)
      cmd="$*"
      case "$cmd" in
        *'count(*) FROM control.schema_migration'*)
          printf '%s\n' "${SCENARIJ_LEDGER:?}"; exit 0 ;;
        *rolsuper*)
          printf '%s\n' "${SCENARIJ_ROLE:-0|1}"; exit 0 ;;
        *'version, name, file_sha256'*)
          cnt="${SCENARIJ_SCHETCHIK:?}"
          n="$(cat "$cnt" 2>/dev/null || echo 0)"
          n=$((n + 1)); printf '%s' "$n" >"$cnt"
          if [ "$n" -ge 2 ] && [ -n "${SCENARIJ_ROWS2:-}" ]; then
            printf '%s\n' "$SCENARIJ_ROWS2"; exit 0
          fi
          printf '%s\n' "${SCENARIJ_ROWS:?}"; exit 0 ;;
      esac
      exit 127 ;;
  esac
fi
echo "DOCKER_VNE_ALFAVITA: $*" >&2
exit 127
'''

# ── стабы: мутации probe.py КОДОМ (Н-39); якорь отсутствует — громко ─────────

STABY = {
    's-konstanta-14': {
        'opisanie': 'зашитая константа 14 остаётся',
        'jakor': "        expected = str(len(manifest_entries(tree)))\n",
        'zamena': "        expected = '14'\n",
        'vhody': ['mir-15:zeleno', 'mir-1:zeleno'],
    },
    's-ozhidanie-iz-fajlov': {
        'opisanie': 'ожидание из файлов migrations/ вместо манифеста',
        'jakor': "        expected = str(len(manifest_entries(tree)))\n",
        'zamena': ("        expected = str(len(tree.sql_names("
                   "tree.p('db_dir'))))\n"),
        'vhody': ['mir-lishnij-fajl:zeleno-po-fajlam'],
    },
    's-manifest-iz-fikstury': {
        'opisanie': 'манифест читается из фикстуры, а не из продукта',
        'jakor': "    body = tree.get(tree.p('manifest'))\n",
        'zamena': ("    body = (Path('%s') / 'model' / "
                   "'manifest.json').read_text(encoding='utf-8')\n" % HERE),
        'vhody': ['mir-15:zeleno'],
    },
    's-pustoj-prinjat': {
        'opisanie': 'пустой манифест принят',
        'jakor': ("    if not entries:\n"
                  "        raise ManifestError('MANIFEST_EMPTY')\n"),
        'zamena': "    if False:\n        pass\n",
        'vhody': ['mir-pustoj-manifest:ledger-0'],
    },
    # v5: стабы тега (слово владельца 2026-10-27). Якоря — байт-в-байт
    # строки probe.py; якорь исчез (правка пробы без правки стабов) —
    # rc 2 STAB_ANCHOR_MISSING, громко. Круг 2 (блокер критика 1/2): байты
    # probe.py изменились (валидация исходной строки без .strip()) — якоря
    # двух стабов ниже переприкоординованы на новую строку, семантика и
    # привязки прежние; замена объявлена в §Замены v5 контракта.
    's-konstanta-tega': {
        'opisanie': 'зашитая константа 109/3 остаётся (исторический дефект '
                    'v3/v4: замороженный файл не знает свой тег)',
        'jakor': "    raw = os.environ.get(LANE_TAG_ENV, '')\n",
        'zamena': "    raw = 'frozen/contracts/109/3'\n",
        'vhody': ['teg-4:zeleno', 'env:otsutstvuet'],
    },
    's-teg-bez-sverki-s-golovoj': {
        'opisanie': 'тег из env, но сверка rev-parse тега с HEAD пропущена',
        'jakor': ("    head_sha = (head.stdout or '').strip() "
                  "if head.returncode == 0 else ''\n"
                  "    if head.returncode != 0 or teg_sha != head_sha:\n"),
        'zamena': "    head_sha = teg_sha\n    if teg_sha != head_sha:\n",
        'vhody': ['teg-4:staryj-teg'],
    },
    's-pustoj-env-umolchanie': {
        'opisanie': 'пустой env → молчаливая подстановка тега по умолчанию '
                    '(минимально допустимого N)',
        'jakor': "    raw = os.environ.get(LANE_TAG_ENV, '')\n",
        'zamena': ("    raw = os.environ.get(LANE_TAG_ENV, '') or "
                   "'frozen/contracts/109/' + str(LANE_TAG_MIN_N)\n"),
        'vhody': ['teg-4:pustoj-env'],
    },
    's-forma-ne-proverjaetsja': {
        'opisanie': 'форма тега не проверяется — любая строка уходит в git',
        'jakor': ("    m = LANE_TAG_RE.fullmatch(raw)\n"
                  "    if m is None or int(m.group(1)) < LANE_TAG_MIN_N:\n"
                  "        return (None, 'STEND109_TAG_FORM: %r вне грамматики '\n"
                  "                      'frozen/contracts/109/<N> (N — целое ≥ %d)' % (\n"
                  "                          raw, LANE_TAG_MIN_N))\n"),
        'zamena': "    if False:\n        pass\n",
        'vhody': ['forma:ne-celoe'],
    },
    # v5-круг2 (блокер критика 1/2): обманка возвращает СТАРОЕ поведение —
    # .strip() ДО проверки формы; расходится с честной ровно на
    # edge-whitespace, где срезание превращает отвергнутую форму в принятый
    # тег (whitespace внутри стаб не ловит — там срезание ничего не меняет)
    's-strip-pered-formoj': {
        'opisanie': 'исходный env срезается .strip() до проверки формы '
                    '(старое поведение v5-старта: тег с невидимым '
                    'whitespace принимался как объявленный)',
        'jakor': "    raw = os.environ.get(LANE_TAG_ENV, '')\n",
        'zamena': "    raw = os.environ.get(LANE_TAG_ENV, '').strip()\n",
        'vhody': ['forma:vedushij-probel', 'forma:zamykayushij-probel',
                  'forma:perevod-stroki'],
    },
}


def otkaz(msg):
    print('109 SEZ: %s' % msg)
    return 2


def predupredit(msg):
    print('109 SEZ: %s' % msg)


# ── миры ─────────────────────────────────────────────────────────────────────

def porodi_mir(base, n, tmp, mutacija=None):
    """Копия базы (без .git/node_modules; node_modules — симлинк) с N
    миграциями: манифест усечён/дополнен до N, файлы согласованы,
    harness-live.test.js несёт токен ledger N (класс живой ветки 007).
    Оракул среза — len(манифеста мира), вычисляется ПОСЛЕ порождения и
    ДО вызова субъекта и сверяется с затребованным N."""
    dst = Path(tmp) / ('mir-%d' % n)
    shutil.rmtree(dst, ignore_errors=True)
    shutil.copytree(base, dst, ignore=shutil.ignore_patterns('.git', 'node_modules'))
    nm = base / 'node_modules'
    if nm.is_dir():
        (dst / 'node_modules').symlink_to(nm)
    mpath = dst / 'server/infrastructure/migrations/manifest.json'
    doc = json.loads(mpath.read_text())
    ent = doc['migrations']
    base_n = len(ent)
    if n <= base_n:
        doc['migrations'] = ent[:n]
        for e in ent[n:]:
            (dst / 'migrations' / e['file']).unlink()
    else:
        for k in range(base_n + 1, n + 1):
            name = '%03d_srez109_sinteticheskij' % k
            body = 'BEGIN;\nSELECT %d;\nCOMMIT;\n' % k
            (dst / 'migrations' / (name + '.sql')).write_text(body)
            doc['migrations'].append({
                'version': k, 'name': name, 'file': name + '.sql',
                'sha256': hashlib.sha256(body.encode()).hexdigest()})
    mpath.write_text(json.dumps(doc, indent=2) + '\n')
    hl = dst / 'tests/integration/harness-live.test.js'
    if hl.is_file():
        b = hl.read_text()
        b = re.sub(r'ledger \d+', 'ledger %d' % n, b)
        b = re.sub(r'rows\.length, \d+', 'rows.length, %d' % n, b)
        b = re.sub(r'измерен: \d+ строк', 'измерен: %d строк' % n, b)
        hl.write_text(b)
    if mutacija:
        mutacija(dst)
    return dst


def ischez_manifest(d):
    (d / 'server/infrastructure/migrations/manifest.json').unlink()


def pustoj_manifest(d):
    (d / 'server/infrastructure/migrations/manifest.json').write_text(
        '{"source": "migrations/", "migrations": []}\n')
    for f in (d / 'migrations').glob('*.sql'):
        f.unlink()


def nechitaemyj_manifest(d):
    (d / 'server/infrastructure/migrations/manifest.json').write_text('not json')


def lishnij_fajl(d):
    (d / 'migrations/zzz_vne_manifesta_srez.sql').write_text(
        'BEGIN;\nSELECT 1;\nCOMMIT;\n')


BROKEN = [
    ('mir-manifest-otsutstvuet', 'MANIFEST_MISSING', ischez_manifest),
    ('mir-pustoj-manifest', 'MANIFEST_EMPTY', pustoj_manifest),
    ('mir-nechitaemyj-manifest', 'MANIFEST_UNPARSEABLE', nechitaemyj_manifest),
    ('mir-lishnij-fajl', 'MANIFEST_MISMATCH_FILES', lishnij_fajl),
]


def podgotovi_shimy(tmp):
    """Каталог с подложным docker + python3/node/git/… из PATH станции
    (docker исключён — живой docker срезом не вызывается)."""
    bez = Path(tmp) / 'path'
    bez.mkdir()
    for d in os.environ.get('PATH', '').split(':'):
        if not d or not Path(d).is_dir():
            continue
        for f in Path(d).iterdir():
            if f.name.startswith('docker'):
                continue
            if f.is_file() and os.access(f, os.X_OK) and not (bez / f.name).exists():
                try:
                    (bez / f.name).symlink_to(f)
                except OSError:
                    pass
    (bez / 'docker').write_text(DOCKER_SHIM)
    (bez / 'docker').chmod(0o755)
    return bez


def vyzovi_funkciu_prob(modul, imja, repo, tree, path_bez, scer, tmp):
    """Вызов факта пробы в окружении сценария: PATH = path_bez (подложный
    docker первым), env сценария. Возвращает (verdikt, note)."""
    env = dict(os.environ)
    env['PATH'] = str(path_bez) + ':' + env.get('PATH', '')
    for k, v in scer.items():
        env[k] = v
    env['SCENARIJ_ZHURNAL'] = str(Path(tmp) / 'zhurnal-docker')
    env['SCENARIJ_SCHETCHIK'] = str(Path(tmp) / 'schetchik')
    for p in (env['SCENARIJ_ZHURNAL'], env['SCENARIJ_SCHETCHIK']):
        Path(p).write_text('')
    star = os.environ.get('PATH'), {k: os.environ.get(k) for k in scer}
    os.environ['PATH'] = env['PATH']
    for k, v in scer.items():
        os.environ[k] = v
    for k in ('SCENARIJ_ZHURNAL', 'SCENARIJ_SCHETCHIK'):
        os.environ[k] = env[k]
    try:
        fn = getattr(modul, imja)
        v, note = fn(repo, tree)
        return v, note
    finally:
        os.environ['PATH'] = star[0]
        for k, v in star[1].items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v
        for k in ('SCENARIJ_ZHURNAL', 'SCENARIJ_SCHETCHIK'):
            os.environ.pop(k, None)


def zagruzi_probu(path, imja='probe_decoy'):
    spec = importlib.util.spec_from_file_location(imja, str(path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def stroki_ledger(n):
    return '\n'.join('%d|srez109_%03d|%064d|hc_probe' % (i + 1, i + 1, i)
                     for i in range(n))


SCENARII = [
    # (имя, ожидание факта stend_up, env-надстройка строится по миру)
    ('zeleno', True),
    ('nedokat', False),
    ('perekat', False),
    ('podlognyj-soderzhimoe', False),
    ('pustoj-ledger', False),
]


def kletki_mirov(proba, base, tmp, rezultaty):
    """Контрольные клетки --model: миры N и сценарии ledger. Оракул N —
    из манифеста МИРА (снимается до вызова субъекта)."""
    base_n = len(json.loads(
        (base / 'server/infrastructure/migrations/manifest.json')
        .read_text())['migrations'])
    spisok = sorted({1, 14, 15, 17, base_n, base_n + 1})
    bez = podgotovi_shimy(tmp)
    for n in spisok:
        mir = porodi_mir(base, n, tmp)
        tree = proba.Tree(mir)
        orakul = len(proba.manifest_entries(tree))
        if orakul != n:
            rezultaty.append(('mir-%d:orakul' % n, False,
                              'оракул мира %d != манифесту (%d)' % (n, orakul)))
            continue
        for imja, ozhid in SCENARII:
            scer = {'SCENARIJ_LEDGER': str(n)}
            rows = stroki_ledger(n)
            if imja == 'nedokat':
                scer['SCENARIJ_LEDGER'] = str(n - 1)
            elif imja == 'perekat':
                scer['SCENARIJ_LEDGER'] = str(n + 1)
            elif imja == 'podlognyj-soderzhimoe':
                scer['SCENARIJ_ROWS2'] = stroki_ledger(n).replace('hc_probe', 'podlognyj', 1)
            elif imja == 'pustoj-ledger':
                scer['SCENARIJ_LEDGER'] = str(n)
                rows = ''
            scer['SCENARIJ_ROWS'] = rows
            v, note = vyzovi_funkciu_prob(
                proba, 'stend_up_fact', mir, tree, bez, scer, tmp)
            imja_kletki = 'mir-%d:%s' % (n, imja)
            horosho = (v is True) if ozhid else (v is False)
            rezultaty.append((imja_kletki, horosho,
                              'v=%r note=%s' % (v, note[:110])))
    # delivery-токен мира: статическая часть зелена (docker отсутствует
    # в PATH среза — живой docker срезом не судится), отставший токен красен
    for n in spisok:
        mir = porodi_mir(base, n, tmp)
        tree = proba.Tree(mir)
        v, note = delivery_bez_docker(proba, mir, tree)
        rezultaty.append(('mir-%d:delivery-tokem' % n,
                          v is None and 'docker' in note,
                          'v=%r note=%s' % (v, note[:110])))
        # Отставший токен статически ловим только для ДВУЗНАЧНЫХ N:
        # подстрочная грамматика токенов v3 (tok in span) для однозначного
        # N совпадает с «PG18» заголовка (демаркация — source.json);
        # живой слой node --test ловит любое N, здесь не исполняется
        # (docker — lane stend109/станция стенда).
        if n < 10:
            continue
        mir2 = porodi_mir(base, n, tmp)
        hl = mir2 / 'tests/integration/harness-live.test.js'
        b = hl.read_text().replace('ledger %d' % n, 'ledger %d' % (n - 1))
        b = b.replace('rows.length, %d' % n, 'rows.length, %d' % (n - 1))
        b = b.replace('измерен: %d строк' % n, 'измерен: %d строк' % (n - 1))
        hl.write_text(b)
        v2, note2 = delivery_bez_docker(proba, mir2, proba.Tree(mir2))
        rezultaty.append(('mir-%d:delivery-otstal' % n,
                          v2 is False and 'токен' in (note2 + 'выхолощено'),
                          'v=%r note=%s' % (v2, note2[:110])))


def delivery_bez_docker(proba, repo, tree):
    """delivery_test_fact в PATH без docker: статическая часть обязана
    пройти (итог None с границей docker), живая — честно не исполнена."""
    bez = str(tree.repo)  # не используется; PATH закрывает вызывающий
    env_path = ':'.join(p for p in os.environ.get('PATH', '').split(':')
                        if not (Path(p) / 'docker').exists())
    star = os.environ['PATH']
    os.environ['PATH'] = env_path
    try:
        return proba.delivery_test_fact(repo, tree)
    finally:
        os.environ['PATH'] = star


def kletki_otkazov(proba, base, tmp, rezultaty):
    """Сломанные манифесты: CLI пробы обязан отказать rc 2 с именованной
    причиной ДО суда; manifest_entries — raise той же причиной."""
    for imja, prichina, mut in BROKEN:
        mir = porodi_mir(base, min(14, len(json.loads(
            (base / 'server/infrastructure/migrations/manifest.json')
            .read_text())['migrations'])), tmp, mutacija=mut)
        r = subprocess.run(
            [sys.executable, str(PROBE), '--repo', str(mir)],
            capture_output=True, text=True, timeout=120,
            env=dict(os.environ, PATH=os.environ['PATH']))
        ok_cli = r.returncode == 2 and prichina in (r.stdout + r.stderr)
        try:
            proba.manifest_entries(proba.Tree(mir))
            raise_ = None
        except proba.ManifestError as e:
            raise_ = e.reason
        rezultaty.append((imja, ok_cli and raise_ == prichina,
                          'cli rc=%d raise=%r' % (r.returncode, raise_)))


# ── теговые миры v5: frozen-тег из окружения CI ─────────────────────────────

TEGOVYE_N = (4, 5, 17)

def teg_znachenie(n):
    """Значение STEND109_TAG конформного входа — строится из грамматики
    (frozen/contracts/109/<N>), без литерала с цифрой: grep-клетка требует,
    чтобы судящий код не нёс константу тега; историческое 109/3 — тоже
    ВХОД красной формы, построенный из грамматики, а не пин."""
    return 'frozen/contracts/109/%d' % n


FORMA_PLOHIE = (
    ('istoricheskij-3', teg_znachenie(3)),
    ('ne-celoe', 'frozen/contracts/109/x'),
    ('chuzhoj-kontrakt', 'frozen/contracts/108/4'),
    ('put', '../../../etc/passwd'),
    # v5-круг2 (блокер критика 1/2): форма — ТОЧНАЯ строка (без .strip()):
    # whitespace вокруг/внутри, строка из одних пробелов и ведущий ноль —
    # FORM; значения строятся из грамматики (teg_znachenie), не литералом
    # с цифрой после 109/ — иначе grep-клетка тега краснеет сама
    ('vedushij-probel', ' ' + teg_znachenie(4)),
    ('zamykayushij-probel', teg_znachenie(4) + ' '),
    ('tab', teg_znachenie(4) + '\t'),
    ('perevod-stroki', teg_znachenie(4) + '\n'),
    ('vozvrat-karetki', teg_znachenie(4) + '\r'),
    ('crlf-v-kontse', teg_znachenie(4) + '\r\n'),
    ('probely-vnutri', teg_znachenie(4)[:-1] + ' 4'),
    ('tolko-probely', '   '),
    ('nol-v-nachale', teg_znachenie(4)[:-1] + '04'),
    ('suffiks-bukva', teg_znachenie(4) + 'x'),
    ('tochki-put', teg_znachenie(4) + '/../3'),
)


def ferma_bez_docker(tmp):
    """PATH-ферма без docker* (git/node остаются): теговые клетки обязаны
    давать ОДНО И ТО ЖЕ на любой станции — зелёная ветка тега упирается в
    docker-границу lane-факта, тяжёлая гигиена не запускается."""
    bez = Path(tmp) / 'bin-bez-docker'
    if bez.is_dir():
        return bez
    bez.mkdir(parents=True)
    for d in os.environ.get('PATH', '').split(':'):
        if not d or not Path(d).is_dir():
            continue
        for f in Path(d).iterdir():
            if f.name.startswith('docker'):
                continue
            if f.is_file() and os.access(f, os.X_OK) and not (bez / f.name).exists():
                try:
                    (bez / f.name).symlink_to(f)
                except OSError:
                    pass
    return bez


def porodi_h_checkout(tmp, imja, plan, probe_bytes, n):
    """Порождаемый раннером H-checkout: probe.py (байты субъекта) в
    fixtures/workshop_project/stend_109/, git-репозиторий с тегом
    frozen/contracts/109/<n> по плану: zeleno (HEAD == тегу), staryj (тег
    на старом коммите, HEAD новее), chuzhoj (тег на чужой orphan-ветке).
    Оракул (rev-parse тега/HEAD) вызывающий снимает ДО вызова субъекта."""
    h = Path(tmp) / imja
    p = h / 'fixtures' / 'workshop_project' / 'stend_109' / 'probe.py'
    p.parent.mkdir(parents=True)
    p.write_bytes(probe_bytes)
    teg = 'frozen/contracts/109/%d' % n

    def g(*a):
        return subprocess.run(['git', '-C', str(h)] + list(a),
                              capture_output=True, text=True, timeout=120)
    for a_ in (['init', '-q', '-b', 'main'], ['add', '-A'],
               ['-c', 'user.name=srez109-teg', '-c',
                'user.email=srez109-teg@dev-harness.local',
                'commit', '-q', '-m', 'teg mirov']):
        if g(*a_).returncode != 0:
            raise RuntimeError('porodi_h_checkout git %s' % a_[0])
    if plan == 'zeleno':
        g('tag', '-a', '-m', 'pin sreza', teg)
    elif plan == 'staryj':
        g('tag', '-a', '-m', 'pin sreza', teg)
        (h / 'sledujushhij-krug.txt').write_text('novyj kommit\n')
        g('add', '-A')
        g('-c', 'user.name=srez109-teg', '-c',
          'user.email=srez109-teg@dev-harness.local',
          'commit', '-q', '-m', 'novye izmenenija')
    elif plan == 'chuzhoj':
        g('checkout', '-q', '--orphan', 'storonnjaja')
        g('rm', '-rq', '--cached', '.')
        (h / 'chuzhoj.txt').write_text('chuzhoj kommit\n')
        g('add', '-A')
        g('-c', 'user.name=srez109-teg', '-c',
          'user.email=srez109-teg@dev-harness.local',
          'commit', '-q', '-m', 'chuzhoj kommit')
        g('tag', '-a', '-m', 'pin sreza', teg)
        g('checkout', '-q', 'main')
    else:
        raise ValueError(plan)
    return h


def vyzovi_lane_fakt(modul, repo, tree, env_nadstra, bin_):
    """lane_hygiene_fact субъекта (модуль загружен из порождаемого
    H-checkout — devharness резолвится в НЕГО) в PATH-ферме без docker и
    env-надстройке (значение None — переменная снята). Возвращает
    (verdikt, note)."""
    klyuchi = ('STEND109_TAG', 'STEND109_LANE_DEPTH')
    star = {k: os.environ.get(k) for k in klyuchi}
    star_path = os.environ['PATH']
    for k in klyuchi:
        os.environ.pop(k, None)
    for k, v in env_nadstra.items():
        if v is None:
            os.environ.pop(k, None)
        else:
            os.environ[k] = v
    os.environ['PATH'] = str(bin_)
    try:
        return modul.lane_hygiene_fact(repo, tree)
    finally:
        os.environ['PATH'] = star_path
        for k, v in star.items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v


def teg_zelen(h, n):
    """Оракул ДО вызова субъекта: rev-parse тега == rev-parse HEAD."""
    teg = 'frozen/contracts/109/%d' % n
    r1 = subprocess.run(['git', '-C', str(h), 'rev-parse', teg + '^{commit}'],
                        capture_output=True, text=True, timeout=60)
    r2 = subprocess.run(['git', '-C', str(h), 'rev-parse', 'HEAD'],
                        capture_output=True, text=True, timeout=60)
    return (r1.returncode == 0 and r2.returncode == 0
            and r1.stdout.strip() == r2.stdout.strip())


def kletki_tegov(proba, base, tmp, rezultaty):
    """Теговые клетки v5: порождаемые раннером H-checkout'ы с тегами
    frozen/contracts/109/N (N ∈ {4, 5, 17}); субъект — байты probe.py,
    помещённые в порождаемый checkout (devharness резолвится в него).
    Оракул каждого мира (rev-parse тега/HEAD) снят ДО вызова субъекта."""
    probe_bytes = PROBE.read_bytes()
    bin_ = ferma_bez_docker(tmp)
    mir = porodi_mir(base, 1, tmp)
    # порождаем один раз на план/N; оракул — до вызова субъекта
    h_mira = {}
    for n in TEGOVYE_N:
        for plan in ('zeleno', 'staryj', 'chuzhoj'):
            h = porodi_h_checkout(tmp, 'teg-%d-%s' % (n, plan), plan,
                                  probe_bytes, n)
            h_mira[(n, plan)] = (h, teg_zelen(h, n))
    h4, oracle4 = h_mira[(4, 'zeleno')]
    if not oracle4:
        rezultaty.append(('teg-4:zeleno:orakul', False,
                          'оракул: rev-parse тега != HEAD в порождаемом '
                          'H-checkout (мир собран неверно)'))
        return

    def modul_iz(h):
        return zagruzi_probu(h / 'fixtures' / 'workshop_project'
                             / 'stend_109' / 'probe.py')

    # зелёное (тег == HEAD): lane-факт честно проходит теговые ветки и
    # упирается в NEEDS_ENV-границу БЕЗ имени STEND109_TAG_*
    for n in TEGOVYE_N:
        h, o_ = h_mira[(n, 'zeleno')]
        v, note = vyzovi_lane_fakt(modul_iz(h), mir, None,
                                   {'STEND109_TAG': 'frozen/contracts/109/%d' % n},
                                   bin_)
        rezultaty.append(('teg-%d:zeleno' % n,
                          o_ and v is None and note.startswith('NEEDS_ENV')
                          and 'STEND109_TAG' not in note,
                          'v=%r note=%s' % (v, note[:90])))
    # красное: старый тег (HEAD новее) и чужой коммит (orphan) — MISMATCH
    for n in TEGOVYE_N:
        for plan, imja in (('staryj', 'staryj-teg'), ('chuzhoj', 'chuzhoj-kommit')):
            h, o_ = h_mira[(n, plan)]
            v, note = vyzovi_lane_fakt(modul_iz(h), mir, None,
                                       {'STEND109_TAG': 'frozen/contracts/109/%d' % n},
                                       bin_)
            rezultaty.append(('teg-%d:%s' % (n, imja),
                              (not o_) and v is None
                              and 'STEND109_TAG_MISMATCH' in note,
                              'v=%r note=%s' % (v, note[:90])))
    # кривая форма (включая исторический 109/3), whitespace и ведущий
    # ноль: FORM, до любого git
    for imja, znach in FORMA_PLOHIE:
        v, note = vyzovi_lane_fakt(modul_iz(h4), mir, None,
                                   {'STEND109_TAG': znach}, bin_)
        rezultaty.append(('forma:%s' % imja,
                          v is None and 'STEND109_TAG_FORM' in note,
                          'v=%r note=%s' % (v, note[:90])))


def kletki_tegov_cli(proba, base, tmp, rezultaty):
    """CLI-отказы тега rc 2 с именем (режим --case: facts_none печатается
    и возвращается ДО учёта not_rejected полного прогона). Проба — из
    порождаемого H-checkout (devharness = он же), PATH-ферма без docker."""
    probe_bytes = PROBE.read_bytes()
    bin_ = ferma_bez_docker(tmp)
    mir = porodi_mir(base, 1, tmp)
    h4 = porodi_h_checkout(tmp, 'teg-cli-4', 'zeleno', probe_bytes, 4)
    h4_st = porodi_h_checkout(tmp, 'teg-cli-st', 'staryj', probe_bytes, 4)
    probe4 = h4 / 'fixtures' / 'workshop_project' / 'stend_109' / 'probe.py'
    probe4_st = h4_st / 'fixtures' / 'workshop_project' / 'stend_109' / 'probe.py'
    sluchai = [
        ('cli:teg-otsutstvuet', probe4, None),
        ('cli:teg-pustoj', probe4, ''),
        ('cli:forma', probe4, 'frozen/contracts/109/x'),
        ('cli:staryj-teg', probe4_st, teg_znachenie(4)),
    ]
    imena = {'cli:teg-otsutstvuet': 'STEND109_TAG_ABSENT',
             'cli:teg-pustoj': 'STEND109_TAG_ABSENT',
             'cli:forma': 'STEND109_TAG_FORM',
             'cli:staryj-teg': 'STEND109_TAG_MISMATCH'}
    for imja, probe, znach in sluchai:
        env = dict(os.environ)
        env['PATH'] = str(bin_)
        env.pop('STEND109_TAG', None)
        env.pop('STEND109_LANE_DEPTH', None)
        if znach is not None:
            env['STEND109_TAG'] = znach
        r = subprocess.run(
            [sys.executable, str(probe), '--repo', str(mir),
             '--case', 'compose_delete'],
            capture_output=True, text=True, timeout=300, env=env)
        vyvod = (r.stdout or '') + (r.stderr or '')
        rezultaty.append((imja, r.returncode == 2
                          and imena[imja] in vyvod,
                          'rc=%d имён=%d' % (
                              r.returncode, vyvod.count(imena[imja]))))


def kletka_grep_tega(rezultaty):
    """Механический ловец инварианта «в судящем коде нет константы тега»:
    probe.py — вхождения frozen/contracts/109/<цифры> разрешены ТОЛЬКО в
    комментариях и докстринге модуля (tokenize, не подстрока где угодно);
    srez — вне блока STABY (обманки несут дефект по построению, Н-39)
    только в #-комментариях; red_migracii_109.sh и model/manifest.json —
    вхождений нет вовсе (текст байтов)."""
    pat = re.compile(r'frozen/contracts/109/[0-9]')
    # probe.py: допустимые позиции — COMMENT и докстринг модуля (первая
    # строка-выражение файла)
    import io
    import tokenize as tok_mod
    proba_text = PROBE.read_text(encoding='utf-8')
    dopustimo = []
    try:
        tokens = list(tok_mod.generate_tokens(
            io.StringIO(proba_text).readline))
    except (tok_mod.TokenError, IndentationError, SyntaxError) as e:
        rezultaty.append(('grep:teg-v-sudjashchem', False,
                          'probe.py не токенизируется: %r' % (e,)))
        return
    videl_str = False
    for t in tokens:
        if t.type == tok_mod.COMMENT:
            dopustimo.append((t.start, t.end))
        elif t.type == tok_mod.STRING and not videl_str:
            dopustimo.append((t.start, t.end))
            videl_str = True
    plokho = []
    for m in pat.finditer(proba_text):
        pos = (proba_text[:m.start()].count('\n') + 1,
               m.start() - proba_text.rfind('\n', 0, m.start()))
        if not any(s[0] <= (pos[0], pos[1]) <= s[1] for s in dopustimo):
            plokho.append('probe.py:%d' % pos[0])
    # srez: вне STABY только #-комментарии
    srez_text = HERE.joinpath('srez_migracii_109.py').read_text(
        encoding='utf-8')
    v_stabah = False
    for i, ln in enumerate(srez_text.splitlines(), 1):
        if ln.startswith('STABY = {'):
            v_stabah = True
        elif v_stabah and ln == '}':
            v_stabah = False
            continue
        if pat.search(ln) and not v_stabah and not ln.lstrip().startswith('#'):
            plokho.append('srez_migracii_109.py:%d' % i)
    for rel in ('red_migracii_109.sh',):
        tekst = HERE.joinpath(rel).read_text(encoding='utf-8')
        for i, ln in enumerate(tekst.splitlines(), 1):
            if pat.search(ln) and not ln.lstrip().startswith('#'):
                plokho.append('%s:%d' % (rel, i))
    if b'frozen/contracts/109/' in MODEL_MANIFEST.read_bytes():
        plokho.append('model/manifest.json')
    rezultaty.append(('grep:teg-v-sudjashchem', not plokho,
                      ('нарушений %d: %s' % (len(plokho),
                                             ';'.join(plokho[:4])))
                      if plokho else 'чисто'))

# ── клетки предпосылки ci (v5-доработка; живой прогон 27.10) ─────────────────
#
# Дефект предпосылки, найден implementer'ом при подготовке живой ветки и
# подтверждён живым прогоном (run 40523445654, success): ci.yml продукта
# объявлял STEND109_TAG в env ШАГА клона dev-harness — шаг lane его не
# наследует, проба v5 отказала бы STEND109_TAG_ABSENT на любом честном CI
# бэкенда. Носители — живые байты ci.yml (ci_nositeli/, пин source.json:
# порча — rc 2 ORACLE_TAMPERED до любых клеток); привязка зелено/красно —
# код структурного разбора (Н-39), не проза контракта. Носители — ВХОДЫ
# (живые байты продукта), не судящий код: grep-клетка тега их не судит,
# целостность несёт пин байтов.

def proveri_piny_ci(src):
    """Пины носителей ci ДО любых клеток (правило 8: оракул — в памяти
    проверяющего, не на диске проверяемого). None — порядок; иначе
    причина для ORACLE_TAMPERED."""
    piny = src.get('pin_ci_nositeli') or {}
    if len(piny) < 2:
        return 'pin_ci_nositeli отсутствует/неполон (нужны оба носителя)'
    for otn, pin in sorted(piny.items()):
        fakt = hashlib.sha256((HERE / otn).read_bytes()).hexdigest()
        if pin != fakt:
            return 'пин %s %s != байтам %s' % (otn, pin[:12], fakt[:12])
    return None


def sudit_ci(tekst):
    """Структурный разбор ci.yml: где job stend109 объявляет STEND109_TAG.
    Возвращает (verdikt, note): 'job' — env на уровне jobs.stend109.env
    (виден шагу клона И шагу lane); 'shag' — STEND109_TAG в дереве job
    есть, но jobs.stend109.env его не несёт (уровень шага steps.* — шаг
    lane не наследует); 'net' — в job stend109 не найден (или файла/job
    нет). Грамматика носителей — блочный YAML (живые байты продукта);
    комментарии (#) не считаются; иная форма — честное 'net', не
    молчаливое зелёное."""
    if not tekst.strip():
        return ('net', 'ci.yml отсутствует/пуст')
    stroki = tekst.splitlines()
    koren = None
    for i, ln in enumerate(stroki):
        if ln.lstrip().startswith('#'):
            continue
        m = re.match(r'^(\s*)jobs:\s*(?:#.*)?$', ln)
        if m:
            koren = (i, len(m.group(1)))
            break
    if koren is None:
        return ('net', 'jobs: не найден')
    i_jobs, otstup_jobs = koren
    i_job = otstup_job = None
    for i in range(i_jobs + 1, len(stroki)):
        ln = stroki[i]
        if not ln.strip() or ln.lstrip().startswith('#'):
            continue
        otstup = len(ln) - len(ln.lstrip())
        if otstup <= otstup_jobs:
            break
        if otstup == otstup_jobs + 2:
            if re.match(r'^stend109:\s*(?:#.*)?$', ln.strip()):
                i_job, otstup_job = i, otstup
                break
    if i_job is None:
        return ('net', 'job stend109 не найден')
    otstup_kljuchej = otstup_job + 2
    blok = []
    for i in range(i_job + 1, len(stroki)):
        ln = stroki[i]
        if not ln.strip() or ln.lstrip().startswith('#'):
            continue
        otstup = len(ln) - len(ln.lstrip())
        if otstup <= otstup_job:
            break
        blok.append((i + 1, otstup, ln.strip()))
    pat_kljuch = re.compile(r'^STEND109_TAG\s*:')

    def v_env_joba():
        """env: на уровне ключей job; STEND109_TAG — среди его детей
        (до следующего ключа job-уровня)."""
        i_env = None
        for nomer, otstup, s in blok:
            if otstup == otstup_kljuchej and re.match(r'^env:\s*(?:#.*)?$', s):
                i_env = nomer
                break
        if i_env is None:
            return False
        for nomer, otstup, s in blok:
            if nomer <= i_env:
                continue
            if otstup <= otstup_kljuchej:
                break
            if pat_kljuch.match(s):
                return True
        return False

    if v_env_joba():
        return ('job', 'jobs.stend109.env')
    for nomer, otstup, s in blok:
        if pat_kljuch.match(s):
            return ('shag', 'STEND109_TAG вне jobs.stend109.env (строка '
                    '%d: уровень шага steps.* либо неблочная форма) — '
                    'шаг lane env не наследует' % nomer)
    return ('net', 'STEND109_TAG в job stend109 не найден')


def kletki_predposylki(rezultaty, repo=None):
    """Клетки предпосылки job-env: зелёный носитель (пробная ветка
    живого прогона) — verdikt «job»; шаг-env носитель main — «shag»
    (дефект предпосылки, разбор по структуре, не по упоминаниям);
    --repo дополнительно судит ЖИВОЙ ci.yml чекаута: job-env обязателен,
    иначе красная клетка с именем и указанием зоны правки."""
    z = HERE / 'ci_nositeli' / 'ci_job_env.yml'
    k = HERE / 'ci_nositeli' / 'ci_shag_env.yml'
    v, note = sudit_ci(z.read_text(encoding='utf-8'))
    rezultaty.append(('ci:job-env', v == 'job',
                      'v=%s note=%s' % (v, note)))
    v, note = sudit_ci(k.read_text(encoding='utf-8'))
    rezultaty.append(('ci:shag-env', v == 'shag',
                      'v=%s note=%s' % (v, note)))
    if repo is not None:
        yml = repo / '.github' / 'workflows' / 'ci.yml'
        v, note = sudit_ci(yml.read_text(encoding='utf-8')
                           if yml.is_file() else '')
        rezultaty.append(('ci:zhivoj', v == 'job',
                          'v=%s note=%s%s' % (
                              v, note, '' if v == 'job' else
                              ' — ПРЕДПОСЫЛКА: env на уровень '
                              'jobs.stend109 (зона implementer)')))

# ── стабы ────────────────────────────────────────────────────────────────────

# входы теговых стабов (полная строка привязки до rsplit): план H-мира,
# значение STEND109_TAG (None — переменная снята, '' — пустая)
TEG_VHODY = {
    'teg-4:zeleno': ('zeleno', teg_znachenie(4)),
    'env:otsutstvuet': ('zeleno', None),
    'teg-4:staryj-teg': ('staryj', teg_znachenie(4)),
    'teg-4:pustoj-env': ('zeleno', ''),
    'forma:ne-celoe': ('zeleno', 'frozen/contracts/109/x'),
    'forma:vedushij-probel': ('zeleno', ' ' + teg_znachenie(4)),
    'forma:zamykayushij-probel': ('zeleno', teg_znachenie(4) + ' '),
    'forma:perevod-stroki': ('zeleno', teg_znachenie(4) + '\n'),
}
# ожидаемый класс вердикта (честная, обманка) на каждой привязке:
# 'granica' — NEEDS_ENV-граница БЕЗ имени STEND109_TAG_* (теговые ветки
# пройдены); именованные классы — отказы fail-closed. Обманка обязана
# давать ДРУГОЙ класс ровно на своей привязке (Н-39)
TEG_OZHID = {
    ('s-konstanta-tega', 'teg-4:zeleno'): ('granica', 'STEND109_TAG_FORM'),
    ('s-konstanta-tega', 'env:otsutstvuet'): (
        'STEND109_TAG_ABSENT', 'STEND109_TAG_FORM'),
    ('s-teg-bez-sverki-s-golovoj', 'teg-4:staryj-teg'): (
        'STEND109_TAG_MISMATCH', 'granica'),
    ('s-pustoj-env-umolchanie', 'teg-4:pustoj-env'): (
        'STEND109_TAG_ABSENT', 'granica'),
    ('s-forma-ne-proverjaetsja', 'forma:ne-celoe'): (
        'STEND109_TAG_FORM', 'STEND109_TAG_MISMATCH'),
    ('s-strip-pered-formoj', 'forma:vedushij-probel'): (
        'STEND109_TAG_FORM', 'granica'),
    ('s-strip-pered-formoj', 'forma:zamykayushij-probel'): (
        'STEND109_TAG_FORM', 'granica'),
    ('s-strip-pered-formoj', 'forma:perevod-stroki'): (
        'STEND109_TAG_FORM', 'granica'),
}


def teg_klass(note):
    for imja in ('STEND109_TAG_ABSENT', 'STEND109_TAG_FORM',
                 'STEND109_TAG_MISMATCH'):
        if imja in (note or ''):
            return imja
    return 'granica'


def tegovyj_stab(imja, vhod, chast, chast2, base, tmp, rezultaty):
    """Привязка тегового стаба: два порождаемых H-checkout'а (байты
    честной пробы и байты обманки — мутация от якоря), один и тот же вход
    (мир-план + env). Классы вердиктов обязаны совпасть с TEG_OZHID —
    обманка расходится с честной ровно здесь (Н-39)."""
    plan, znach = TEG_VHODY[vhod]
    stubdir = Path(tmp) / 'stub' / (imja + '---teg') / vhod.replace(':', '_')
    stubdir.mkdir(parents=True, exist_ok=True)
    bin_ = ferma_bez_docker(stubdir)
    mir = porodi_mir(base, 1, stubdir)
    h_ch = porodi_h_checkout(stubdir, 'h-chestnoe', plan,
                             chast.encode('utf-8'), 4)
    h_ob = porodi_h_checkout(stubdir, 'h-obmanka', plan,
                             chast2.encode('utf-8'), 4)
    env = {'STEND109_TAG': znach}
    v_ch, n_ch = vyzovi_lane_fakt(
        zagruzi_probu(h_ch / 'fixtures' / 'workshop_project'
                      / 'stend_109' / 'probe.py'), mir, None, env, bin_)
    v_ob, n_ob = vyzovi_lane_fakt(
        zagruzi_probu(h_ob / 'fixtures' / 'workshop_project'
                      / 'stend_109' / 'probe.py'), mir, None, env, bin_)
    ozh = TEG_OZHID[(imja, vhod)]
    horosho = (v_ch is None and v_ob is None
               and teg_klass(n_ch) == ozh[0] and teg_klass(n_ob) == ozh[1])
    rezultaty.append(('stab %s @ %s' % (imja, vhod), horosho,
                      'честная=%s обманка=%s (%s | %s)' % (
                          teg_klass(n_ch), teg_klass(n_ob),
                          n_ch[:40], n_ob[:40])))


def kletki_stabov(proba, base, tmp, rezultaty):
    """Обманные стабы (Н-39: мутации probe.py КОДОМ; привязки —
    stab_vhod source.json, рассинхрон — rc 2 ORACLE_TAMPERED). Каждый
    стаб обязан расходиться с честной пробой ровно на своей привязке:
    честная — правильный вердикт, обманка — дефектный (приняла сломанное
    либо отвергла честное)."""
    chast = PROBE.read_text(encoding='utf-8')
    src = json.loads(SOURCE.read_text())
    svjazej = 0
    for imja, opis in STABY.items():
        svjaz = src['stab_vhod'].get(imja)
        if svjaz is None:
            raise SystemExit(otkaz(
                'ORACLE_TAMPERED: стаб %s без привязок stab_vhod' % imja))
        if sorted(svjaz) != sorted(opis['vhody']):
            raise SystemExit(otkaz(
                'ORACLE_TAMPERED: рассинхрон привязок %s: код %s != '
                'source.json %s' % (imja, opis['vhody'], svjaz)))
        chast2 = chast.replace(opis['jakor'], opis['zamena'], 1)
        if chast2 == chast:
            predupredit('STAB_ANCHOR_MISSING: якорь стаба %s не найден — '
                        'пере-якорение' % imja)
            raise SystemExit(2)
        put = Path(tmp) / ('decoy-%s.py' % imja)
        put.write_text(chast2, encoding='utf-8')
        decoy = zagruzi_probu(put)
        for vhod in svjaz:
            svjazej += 1
            if vhod in TEG_VHODY:
                tegovyj_stab(imja, vhod, chast, chast2, base, tmp,
                             rezultaty)
                continue
            mesto, _scen = vhod.rsplit(':', 1)
            stubdir = Path(tmp) / 'stub' / (imja + '---' + mesto)
            stubdir.mkdir(parents=True, exist_ok=True)
            bez = podgotovi_shimy(stubdir)
            if mesto == 'mir-lishnij-fajl':
                mir = porodi_mir(base, 14, stubdir, mutacija=lishnij_fajl)
                try:
                    proba.manifest_entries(proba.Tree(mir))
                    chestn = 'suditsja'
                except proba.ManifestError as e:
                    chestn = e.reason
                scer = {'SCENARIJ_LEDGER': '15',
                        'SCENARIJ_ROWS': stroki_ledger(15)}
                v_ob, n_ob = vyzovi_funkciu_prob(
                    decoy, 'stend_up_fact', mir, decoy.Tree(mir),
                    bez, scer, stubdir)
                # честная на этом мире ОТКАЗЫВАЕТСЯ (MISMATCH) — зелёного
                # вердикта нет; обманка судит по файлам (15) и принимает
                # рассинхрон манифеста и каталога — плацебо пойман
                horosho = (chestn == 'MANIFEST_MISMATCH_FILES'
                           and v_ob is True)
                rezultaty.append(('stab %s @ %s' % (imja, vhod), horosho,
                                  'честная=%s обманка=%r(%s)' % (
                                      chestn, v_ob, n_ob[:60])))
                continue
            if mesto == 'mir-pustoj-manifest':
                mir = porodi_mir(base, 14, stubdir, mutacija=pustoj_manifest)
                scer = {'SCENARIJ_LEDGER': '0',
                        'SCENARIJ_ROWS': stroki_ledger(1)}
                v_ch = proba.stend_up_fact(mir, proba.Tree(mir))
                v_ob, _ = vyzovi_funkciu_prob(
                    decoy, 'stend_up_fact', mir, decoy.Tree(mir),
                    bez, scer, stubdir)
                horosho = v_ch[0] is False and v_ob is True
                rezultaty.append(('stab %s @ %s' % (imja, vhod), horosho,
                                  'честная=%r обманка=%r' % (v_ch[0], v_ob)))
                continue
            n = {'mir-1': 1, 'mir-15': 15}.get(mesto)
            if n is None:
                raise SystemExit(otkaz(
                    'ORACLE_TAMPERED: неизвестный вход стаба %s: %s'
                    % (imja, vhod)))
            mir = porodi_mir(base, n, stubdir)
            scer = {'SCENARIJ_LEDGER': str(n),
                    'SCENARIJ_ROWS': stroki_ledger(n)}
            v_ch, n_ch = vyzovi_funkciu_prob(
                proba, 'stend_up_fact', mir, proba.Tree(mir),
                bez, scer, stubdir)
            v_ob, n_ob = vyzovi_funkciu_prob(
                decoy, 'stend_up_fact', mir, decoy.Tree(mir),
                bez, scer, stubdir)
            horosho = v_ch is True and v_ob is False
            rezultaty.append(('stab %s @ %s' % (imja, vhod), horosho,
                              'честная=%r(%s) обманка=%r(%s)' % (
                                  v_ch, n_ch[:40], v_ob, n_ob[:40])))
    return svjazej


# ── режимы ───────────────────────────────────────────────────────────────────

def baza(args):
    for k in ('repo', 'base'):
        v = getattr(args, k, None)
        if v:
            return Path(v).resolve()
    v = os.environ.get('STEND109_BASE')
    return Path(v).resolve() if v else None


def main():
    import argparse
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument('--repo')
    ap.add_argument('--base')
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    args = ap.parse_args()
    proba = zagruzi_probu(PROBE, 'probe_srez')
    rezultaty = []

    if args.model or args.stabs:
        base = baza(args)
        if base is None or not base.is_dir():
            return otkaz('нет базы миров: --base/$STEND109_BASE (checkout '
                         'Complior-back) обязателен для --model/--stabs')
        src = json.loads(SOURCE.read_text())
        pin = src['pin_modeli']['model/manifest.json']
        fakt = hashlib.sha256(MODEL_MANIFEST.read_bytes()).hexdigest()
        if pin != fakt:
            return otkaz('ORACLE_TAMPERED: пин model/manifest.json %s != '
                         'байтам %s' % (pin[:12], fakt[:12]))
        if set(src['stab_vhod']) != set(STABY):
            return otkaz('ORACLE_TAMPERED: рассинхрон stab_vhod: source.json '
                         '%s != коду %s' % (sorted(src['stab_vhod']),
                                            sorted(STABY)))
        plokho_ci = proveri_piny_ci(src)
        if plokho_ci:
            return otkaz('ORACLE_TAMPERED: %s' % plokho_ci)
        with tempfile.TemporaryDirectory(prefix='srez109-') as tmp:
            kletki_mirov(proba, base, tmp, rezultaty)
            kletki_otkazov(proba, base, tmp, rezultaty)
            kletki_tegov(proba, base, tmp, rezultaty)
            kletki_tegov_cli(proba, base, tmp, rezultaty)
            kletka_grep_tega(rezultaty)
            kletki_predposylki(rezultaty)
            if args.stabs:
                (Path(tmp) / 'stub').mkdir(parents=True, exist_ok=True)
                kletki_stabov(proba, base, tmp, rezultaty)
        krasnye = [r for r in rezultaty if not r[1]]
        for imja, horosho, note in rezultaty:
            print('%-44s %s %s' % (imja, 'ok' if horosho else 'KRASNO',
                                   '' if horosho else note))
        if args.stabs:
            svj = sum(len(s['vhody']) for s in STABY.values())
            print('стабов %d, привязок %d, непойманных 0' % (len(STABY), svj)
                  if not krasnye else
                  'стабов %d, привязок %d, НЕ ПОЙМАН: %s' % (
                      len(STABY), svj,
                      ','.join(k[0] for k in krasnye if k[0].startswith('stab'))))
        print('клеток %d, красных %d' % (len(rezultaty), len(krasnye)))
        if krasnye:
            return 1
        return 0

    base = baza(args)
    if base is None:
        print('109 SEZ: SUBJECT_ABSENT: нет --repo/--base/STEND109_BASE — '
              'зелень без субъекта невозможна')
        print('клетки среза: ' + ', '.join(
            ['mir-N:zeleno (N из манифеста мира)'] +
            ['mir-N:%s' % s for s, _ in SCENARII[1:]] +
            ['mir-N:delivery-tokem', 'mir-N:delivery-otstal'] +
            [b[0] for b in BROKEN] +
            ['teg-N:zeleno/staryj-teg/chuzhoj-kommit (N ∈ %s; тег из '
             'STEND109_TAG)' % ','.join(str(x) for x in TEGOVYE_N)] +
            ['forma:%s' % f for f, _ in FORMA_PLOHIE] +
            ['cli:teg-otsutstvuet/pustoj/forma/staryj-teg (rc 2 по имени)',
             'grep:teg-v-sudjashchem',
             'ci:job-env/ci:shag-env (носители ci_nositeli: job-env '
             'зелено, шаг-env main — красная причина, предпосылка)',
             'ci:zhivoj (--repo: живой ci.yml чекаута, env на уровне '
             'jobs.stend109 обязателен)'] +
            ['stab %s' % s for s in STABY]))
        return 1
    # живой срез: оракул живого манифеста + полный CLI-прогон без docker
    try:
        n = len(proba.manifest_entries(proba.Tree(base)))
    except proba.ManifestError as e:
        predupredit('живой манифест: %s — срез отказывается (fail-closed)' % e.reason)
        return 1
    print('живой манифест %s: N=%d' % (base, n))
    src = json.loads(SOURCE.read_text())
    plokho_ci = proveri_piny_ci(src)
    if plokho_ci:
        return otkaz('ORACLE_TAMPERED: %s' % plokho_ci)
    # PATH-ферма: все исполняемые файлы станции, КРОМЕ docker* — выкидывать
    # каталог целиком (в /usr/bin лежит и docker, и git, и node) нельзя:
    # прогон падает по FileNotFoundError, а пустой вывод не отличим от
    # зелёного (мера пустой выборки — красная).
    ferma = None
    with tempfile.TemporaryDirectory(prefix='srez109-bezdocker-') as ftmp:
        ferma = Path(ftmp) / 'bin'
        ferma.mkdir()
        for d in os.environ.get('PATH', '').split(':'):
            if not d or not Path(d).is_dir():
                continue
            for f in Path(d).iterdir():
                if f.name.startswith('docker'):
                    continue
                if f.is_file() and os.access(f, os.X_OK) and not (ferma / f.name).exists():
                    try:
                        (ferma / f.name).symlink_to(f)
                    except OSError:
                        pass
        r = subprocess.run(
            [sys.executable, str(PROBE), '--repo', str(base), '--out',
             str(Path(ftmp) / 'cli')],
            capture_output=True, text=True, timeout=900,
            env=dict(os.environ, PATH=str(ferma)))
        # нечитаемый отчёт = КРАСНОЕ (пустая выборка — не зелёное)
        krasnye_fakty = []
        chitaetsja = False
        try:
            doc = json.loads((Path(ftmp) / 'cli' / 'raw.json').read_text())
            chitaetsja = True
            krasnye_fakty = sorted(k for k, v in doc['facts'].items()
                                   if v['green'] is False)
            krasnyj_kontrol = sorted(doc.get('control_red') or [])
        except (OSError, ValueError, KeyError):
            krasnyj_kontrol = ['ОТЧЁТ_ПРОБЫ_НЕ_ЧИТАЕТСЯ']
        print('полный CLI-прогон (PATH без docker): rc=%d, отчёт=%s, '
              'красных фактов %d%s, красный контроль %s'
              % (r.returncode, 'читается' if chitaetsja else 'НЕ читается',
                 len(krasnye_fakty),
                 (' ' + ','.join(krasnye_fakty)) if krasnye_fakty else '',
                 krasnyj_kontrol or 'пуст'))
        if not chitaetsja:
            return 1
    with tempfile.TemporaryDirectory(prefix='srez109-') as tmp:
        kletki_mirov(proba, base, tmp, rezultaty)
        kletki_otkazov(proba, base, tmp, rezultaty)
        kletki_tegov(proba, base, tmp, rezultaty)
        kletki_tegov_cli(proba, base, tmp, rezultaty)
        kletka_grep_tega(rezultaty)
        kletki_predposylki(rezultaty, repo=base)
    krasnye = [x for x in rezultaty if not x[1]]
    for imja, horosho, note in rezultaty:
        print('%-44s %s %s' % (imja, 'ok' if horosho else 'KRASNO',
                               '' if horosho else note))
    print('клеток %d, красных %d' % (len(rezultaty), len(krasnye)))
    if krasnye_fakty or krasnyj_kontrol or krasnye:
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
