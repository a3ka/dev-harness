#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Срез-батарея 109 v4: число миграций — из манифеста репозитория продукта.

Грамматика W (контракт 109 §Приёмочный критерий, v4):
  (без флага), без --repo/--base и STEND109_BASE → rc 1 SUBJECT_ABSENT
      с перечнем всех клеток среза (зелень без субъекта невозможна);
  (без флага) --repo R / $STEND109_BASE → ЖИВОЙ срез на R: оракул N из
      манифеста R, полный CLI-прогон probe.py на R в PATH без docker
      (docker-факты — честный NEEDS_ENV, граница печатается), клетки
      миров/отказов/сценариев ledger на порождаемых копиях R;
  --model    контроль на порождаемых мирах базы (--base/$STEND109_BASE):
             N ∈ {1, 14, 15, 17, база, база+1} — оракул каждого мира
             вычислен из ЕГО манифеста ДО вызова субъекта (правило 8);
             сценарии ledger: зелено/недокат/перекат/подложный/пустой;
             отказы манифеста: отсутствует/пуст/нечитаем/лишний файл;
  --stabs    контроль --model + 4 обманных стаба (мутации probe.py
             КОДОМ, Н-39; привязки — stab_vhod source.json): каждый
             обязан расходиться с честной пробой ровно на своей
             привязке; рассинхрон множеств/порча пина — rc 2
             ORACLE_TAMPERED.

Окружение среза: python3 + node; docker НЕ нужен и НЕ вызывается
(транспорт ledger — подложный docker/psql замкнутого алфавита сценариев;
живой docker остаётся lane stend109 / станции стенда — «не проверено
живьём» объявляется, а не подменяется зелёным). Сеть не нужна.

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


# ── стабы ────────────────────────────────────────────────────────────────────

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
        with tempfile.TemporaryDirectory(prefix='srez109-') as tmp:
            kletki_mirov(proba, base, tmp, rezultaty)
            kletki_otkazov(proba, base, tmp, rezultaty)
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
            ['stab %s' % s for s in STABY]))
        return 1
    # живой срез: оракул живого манифеста + полный CLI-прогон без docker
    try:
        n = len(proba.manifest_entries(proba.Tree(base)))
    except proba.ManifestError as e:
        predupredit('живой манифест: %s — срез отказывается (fail-closed)' % e.reason)
        return 1
    print('живой манифест %s: N=%d' % (base, n))
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
