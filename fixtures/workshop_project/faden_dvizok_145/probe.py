#!/usr/bin/env python3
# Контракт 145 «faden-dvizok» — probe.py: оркестратор красной батареи.
# Ожидания грузятся в ПАМЯТЬ проверяющего ДО вызова субъекта (правило 8):
# строки поз (6680), входы, спек, драйвер и референс-движок живут в model/
# батареи и пиннены sha256 в source.json (.piny); диск субъекта как истина
# не перечитывается. Численный движок клеток — model/probe_runner.mjs (node,
# без npm/сети/эмулятора); раннер сводит СУБЪЕКТ против ОРАКУЛА (строки,
# допуск столбцов — 1 ед. viewBox на носителе) и против РЕФЕРЕНСА
# (порт == референс, чистые функции/строки/каталоги — байт-точно).
#
# Режимы (как 139/141/142/143 + арбитраж Astra B.6):
#   (без флага, без --repo)  — rc 1 SUBJECT_ABSENT, все клетки красны поимённо
#   (без флага, --repo R)     — судится живой продукт R (до реализации красен:
#                              движка нет — SUBJECT_ABSENT, зелень без субъекта
#                              невозможна)
#   --model                   эталон model/ (контроль входов: референс+драйвер
#                              воспроизводят все 6680 строк, допуск 0.002 —
#                              границы round3 экспортёра, замер 45 строк)
#   --stabs                   контроль + матрица обманных стабов (SVJAZI N,
#                              живых 0; стаб мутирует КОПИЮ model/, привязки
#                              stab_vhod в source.json)
#   --live-component --repo R — режим L: продуктовый live-протокол (jest-expo
#                              из R/mobile, изолированная копия, конечная
#                              матрица мутантов B.8; rc 2 — именованная
#                              предпосылка, никогда skip→pass; ПОЗИТИВНЫХ
#                              «live-зелёных» чисел без рантайма не печатает)
#
# Коды возврата: 0 — зелено; 1 — красная клетка / SUBJECT_ABSENT / STAB_ZHIV /
# в режиме L: красный контроль, живой мутант или инфраструктурное падение;
# 2 — нечем проверять (нет node, ORACLE_TAMPERED, рассинхрон реестра/стабов;
# в режиме L — именованная LIVE_PREDPOSYLKA/LIVE_MUTACIJA_NEPRIMENIMA).
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BATAREJA = Path(__file__).resolve().parent
MODEL = BATAREJA / 'model'
STABS = BATAREJA / 'stabs'
SOURCE = BATAREJA / 'source.json'

# Пути субъекта в продукте (грамматика контракта 145; имена фиксированы).
SUBJEKT_DVIZOK = 'mobile/src/lib/faden/faden-motion.ts'
SUBJEKT_TOKENY = 'mobile/src/theme/motion-tokens.ts'
SUBJEKT_DRAJVER = 'mobile/src/lib/faden/__tests__/faden-replay.json'
# Тестовый источник состояний (§4 бэкенд-разбора, слово 29.10 ~00:55; И-10)
SUBJEKT_ISTOCHNIK = 'mobile/src/lib/faden/faden-state-source.ts'


def oshibka_orakula(soobshchenie):
    print('ORACLE_TAMPERED: %s' % soobshchenie, file=sys.stderr)
    return 2


def sha256_faila(p):
    import hashlib
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def zhestkij_kanon(src):
    """Пины sha256 модели + согласованность реестра клеток/стабов — ДО клеток."""
    piny = src.get('piny') or {}
    for imja, ozhid in piny.items():
        # пины 'produkt/…' закрепляют эталон-форму продукта батареи (основа
        # стаб-матрицы A-оси); остальные — каталог модели
        if imja.startswith('produkt/'):
            fajl = BATAREJA / imja
        else:
            fajl = MODEL / imja
        if not fajl.is_file():
            return 'пин %s: файла нет' % imja
        fakt = sha256_faila(fajl)
        if fakt != ozhid:
            return 'пин %s: sha256 %s != %s' % (imja, fakt, ozhid)
    vh = src.get('stab_vhod') or {}
    staby = sorted(p.stem for p in STABS.glob('stab_*.py'))
    if staby != sorted(vh.keys()):
        return 'рассинхрон stabs/ ↔ stab_vhod: %s' % sorted(vh.keys())
    dlja_runnera = subprocess.run(
        [os.environ.get('NODEBIN', 'node'), str(MODEL / 'probe_runner.mjs'), '--perechen'],
        capture_output=True, text=True, timeout=120)
    if dlja_runnera.returncode != 0:
        return 'раннер --perechen rc=%d: %s' % (dlja_runnera.returncode, dlja_runnera.stderr.strip()[:160])
    perechen = json.loads(dlja_runnera.stdout.strip().splitlines()[-1])
    obyavlennye = [k['id'] for k in src['kletki']]
    if sorted(obyavlennye) != sorted(perechen):
        return ('source.json kletki ≠ клетки раннера: лишние %s отсутствуют %s'
                % (sorted(set(obyavlennye) - set(perechen)), sorted(set(perechen) - set(obyavlennye))))
    dlja_stabov = set()
    for spisok in vh.values():
        dlja_stabov.update(spisok)
    neizvestnye = dlja_stabov - set(perechen)
    if neizvestnye:
        return 'привязки стабов к неизвестным клеткам: %s' % sorted(neizvestnye)
    dlja_tok = src.get('dopusk_stolbcov') or {}
    dlja_stolbcov = {'R', 'w', 'g', 'sx', 'dotA', 'dotRho', 'dotScale', 'dotOpacity', 'check', 'bead'}
    if set(dlja_tok) != dlja_stolbcov:
        return 'dopusk_stolbcov ≠ столбцы строк: %s' % sorted(dlja_tok)
    return None


def zapusti_runnera(subject, subject_tokens, subject_driver, rezhim, repo_root=None, seed=None, subject_istochnik=None):
    argv = [os.environ.get('NODEBIN', 'node'), str(MODEL / 'probe_runner.mjs'),
            '--model', str(MODEL), '--source', str(SOURCE),
            '--subject', str(subject), '--subject-tokens', str(subject_tokens),
            '--subject-driver', str(subject_driver), '--mode', rezhim,
            '--produkt-canon', str(BATAREJA / 'produkt')]
    if subject_istochnik is not None:
        argv += ['--subject-istochnik', str(subject_istochnik)]
    if repo_root:
        argv += ['--repo-root', str(repo_root)]
    if seed is not None:
        argv += ['--seed', str(seed)]
    r = subprocess.run(argv, capture_output=True, text=True, timeout=600)
    kletki = []
    for line in r.stdout.splitlines():
        line = line.strip()
        if line.startswith('{'):
            try:
                kletki.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    return r, kletki


def svod(kletki):
    zeljonye = [k for k in kletki if k['ok']]
    krasnye = [k for k in kletki if not k['ok']]
    return zeljonye, krasnye


def progony_stabov(vremennyj, src, seed=None):
    vh = src.get('stab_vhod') or {}
    staby = sorted(STABS.glob('stab_*.py'), key=lambda p: p.stem)
    svjazi = 0
    zhivye = []
    for st in staby:
        cel = Path(vremennyj) / ('stab-' + st.stem)
        if cel.exists():
            shutil.rmtree(cel)
        shutil.copytree(MODEL, cel)
        r = subprocess.run([sys.executable, str(st), str(cel)], capture_output=True, text=True, timeout=60)
        if r.returncode != 0:
            return -1, 0, ['%s: мутатор rc=%d %s' % (st.stem, r.returncode, r.stderr.strip()[:120])]
        # стаб может подложить produkt-форму (стабы A-оси: пустой компонент,
        # тавтологии, тест без порта) — тогда судим репо-режимом по ней
        produkt = cel / 'produkt'
        if (produkt / 'mobile').is_dir():
            runner, kletki = zapusti_runnera(produkt / 'mobile/src/lib/faden/faden-motion.ts',
                                             produkt / 'mobile/src/theme/motion-tokens.ts',
                                             produkt / 'mobile/src/lib/faden/__tests__/faden-replay.json',
                                             'repo', repo_root=produkt, seed=seed,
                                             subject_istochnik=produkt / 'mobile/src/lib/faden/faden-state-source.ts')
        else:
            runner, kletki = zapusti_runnera(cel / 'faden-motion.js', cel / 'motion-tokens.ts',
                                             cel / 'drajver.json', 'model', seed=seed,
                                             subject_istochnik=cel / 'istochnik-sostojanij.mjs')
        if runner.returncode != 0 and not kletki:
            return -1, svjazi, ['%s: раннер rc=%d %s' % (st.stem, runner.returncode, runner.stderr.strip()[:120])]
        sostojanie = {k['kletka']: k['ok'] for k in kletki}
        for imja_kletki in vh.get(st.stem) or []:
            svjazi += 1
            if sostojanie.get(imja_kletki, False):
                zhivye.append('%s прошёл вход %s' % (st.stem, imja_kletki))
            elif imja_kletki not in sostojanie:
                zhivye.append('%s: клетка %s не вернулась раннером' % (st.stem, imja_kletki))
    return len(staby), svjazi, zhivye


def zhivoj_komponent(repo_root):
    """Режим L (арбитраж Astra B.6–B.8): конечный продуктовый live-протокол.

    Использует УСТАНОВЛЕННЫЙ в R/mobile продуктовый Jest/jest-expo с конфигом
    продукта (не скачивает Jest и не node-шим). Мутации применяются в
    ИЗОЛИРОВАННОЙ КОПИИ (src+конфиги; node_modules — та же зафиксированная
    установка продукта по симлинку); исходный продукт/CI checkout не трогается.
    Оракул — пиннованный каталог батареи (FADEN_ORAKUL_DIR), не данные
    субъекта. rc 2 — именованная предпосылка (нет зависимостей/конфига,
    обязательный тест ≠ канону, нет якоря мутации), НИКОГДА skip→pass;
    rc 1 — красный контроль / живой (неубитый) мутант / инфраструктурное
    падение сьюта; rc 0 — контроль зелён, все воздействия достигнуты и каждый
    негативный мутант убит ПРЕДМЕТНЫМ ассертом обязательного теста.
    """
    mob = repo_root / 'mobile'
    predposylki = []
    if not (mob / 'package.json').is_file():
        predposylki.append('нет mobile/package.json')
    konfig = None
    for imja in ('jest.config.js', 'jest.config.json'):
        if (mob / imja).is_file():
            konfig = imja
            break
    if konfig is None:
        predposylki.append('нет mobile/jest.config.{js,json} — продуктовая конфигурация jest')
    nm = mob / 'node_modules'
    for paket in ('jest-expo', 'react-native-svg', '@testing-library/react-native'):
        if not (nm / paket / 'package.json').is_file():
            predposylki.append('не установлен пакет %s (ПРЕДПОСЫЛКА react-native-svg — поставка реализации)' % paket)
    jest_bin = nm / '.bin' / 'jest'
    if not jest_bin.exists():
        predposylki.append('нет node_modules/.bin/jest')
    objazatelnye = [
        'mobile/src/lib/faden/FadenSign.tsx',
        'mobile/src/lib/faden/faden-motion.ts',
        'mobile/src/lib/faden/__tests__/faden-motion.test.ts',
        'mobile/src/lib/faden/__tests__/faden-sign.test.tsx',
        'mobile/src/lib/faden/__tests__/faden-replay.json',
    ]
    for f in objazatelnye:
        if not (repo_root / f).is_file():
            predposylki.append('нет %s' % f)
    for otn in ('mobile/src/lib/faden/__tests__/faden-motion.test.ts',
                'mobile/src/lib/faden/__tests__/faden-sign.test.tsx'):
        sub = repo_root / otn
        kanon = BATAREJA / 'produkt' / otn
        if sub.is_file() and kanon.is_file() and sub.read_bytes() != kanon.read_bytes():
            predposylki.append('обязательный тест %s != канону батареи (судят клетки a03/a05)' % otn)
    if predposylki:
        print('LIVE_PREDPOSYLKA: %s' % '; '.join(predposylki), file=sys.stderr)
        return 2

    # перечень состояний знака — из ПИННОВАННОГО референса (единый источник)
    r = subprocess.run([os.environ.get('NODEBIN', 'node'), str(MODEL / 'probe_runner.mjs'),
                        '--model', str(MODEL), '--source', str(SOURCE), '--sostojanija'],
                       capture_output=True, text=True, timeout=120)
    if r.returncode != 0:
        print('LIVE_PREDPOSYLKA: референс состояний не читается (rc=%d): %s'
              % (r.returncode, r.stderr.strip()[:120]), file=sys.stderr)
        return 2
    sostojanija = json.loads(r.stdout.strip().splitlines()[-1])

    # Префикс БЕЗ 'faden' (правка v2, замер живого прогона): префикс каталога
    # входит в путь каждого теста в копии, и старый префикс 'faden-145-live-'
    # расширял позиционный паттерн jest 'faden' на ВСЕ сьюты продукта
    # (15 вместо 3) и краснил контроль на чужом сьюте erstinformation
    # (он читает ../docs — сосед копии, которого в ней нет).
    vrem = Path(tempfile.mkdtemp(prefix='live-matrica-145-'))
    try:
        kopija = vrem / 'mobile'
        shutil.copytree(mob, kopija, ignore=shutil.ignore_patterns('node_modules'))
        os.symlink(nm, kopija / 'node_modules')  # та же зафиксированная установка зависимостей

        def zapustit_jest():
            env = dict(os.environ, FADEN_ORAKUL_DIR=str(MODEL / 'oracle'), CI='1')
            try:
                p = subprocess.run([str(kopija / 'node_modules' / '.bin' / 'jest'),
                                    '--config', konfig, '--rootDir', '.',
                                    '--ci', '--runInBand', '--json', 'faden'],
                                   cwd=kopija, capture_output=True, text=True, timeout=1200, env=env)
            except subprocess.TimeoutExpired:
                return None, 'ТАЙМАУТ jest (1200 с)'
            tek = (p.stdout or '').strip()
            try:
                return json.loads(tek), None
            except json.JSONDecodeError:
                a, b = tek.find('{'), tek.rfind('}')
                if a < 0 or b <= a:
                    return None, 'jest без JSON-итога rc=%d: %s' % (p.returncode, (p.stderr or tek)[:200])
                try:
                    return json.loads(tek[a:b + 1]), None
                except json.JSONDecodeError:
                    return None, 'jest JSON не разобран rc=%d: %s' % (p.returncode, (p.stderr or tek)[:200])

        def klassificirovat(svod):
            """(упавших ассертов, не исполнившихся сьютов) — по B.8 падение
            загрузки/трансформации НЕ засчитывается как убитый мутант."""
            assery, sjuity = 0, 0
            for sjuit in svod.get('testResults', []):
                utv = sjuit.get('assertionResults') or []
                if not utv:
                    sjuity += 1
                    continue
                for a in utv:
                    if a.get('status') == 'failed':
                        assery += 1
            return assery, sjuity

        FADEN = 'src/lib/faden/FadenSign.tsx'  # относительно kopija == копии mobile/ (правка scoped-критика 3/3: был двойной mobile/)
        ishodnyj = (kopija / FADEN).read_text(encoding='utf-8')

        def obertka(telo, komentar):
            """Обёрточная мутация живого компонента: исходный экспорт
            переименован, наверху — обёртка с мутантным поведением; импорты/
            пины/остальные состояния сохранены. Нет якоря — rc 2 (не skip)."""
            for ank, zamena in (('export function FadenSign', 'export function FadenSign_original'),
                                ('export const FadenSign', 'export const FadenSign_original')):
                if ank in ishodnyj:
                    return (ishodnyj.replace(ank, zamena, 1)
                            + '\n// мутант живой матрицы L (контракт 145, арбитраж B.8): %s\n'
                              'export function FadenSign(props) {\n%s\n}\n' % (komentar, telo))
            return None

        matriza = [('kontrol', None)]  # положительный контроль — оригинал
        for s in sostojanija:
            matriza.append(('null(%s)' % s,
                            "  if (props && props.state === '%s') return null;\n  return FadenSign_original(props);" % s))
        matriza.append(('zamorozka-nachalnogo-puti',
                        '  const g = globalThis;\n'
                        '  if (!g.__fadenLZamorozka) g.__fadenLZamorozka = FadenSign_original(props);\n'
                        '  return g.__fadenLZamorozka;'))
        matriza.append(('os-flag-prinuditelno-false',
                        '  return FadenSign_original(Object.assign({}, props, { forceReducedMotion: false }));'))
        matriza.append(('os-flag-prinuditelno-true',
                        '  return FadenSign_original(Object.assign({}, props, { forceReducedMotion: true }));'))
        matriza.append(('obnovlenie-pozy-pri-smene-state-vykljucheno',
                        '  const g = globalThis;\n'
                        '  if (!g.__fadenLNachalnoe) g.__fadenLNachalnoe = props && props.state;\n'
                        '  return FadenSign_original(Object.assign({}, props, { state: g.__fadenLNachalnoe }));'))

        itogi = []
        for imja, telo in matriza:
            tekst = None
            if telo is not None:
                tekst = obertka(telo, imja)
                if tekst is None:
                    print('LIVE_MUTACIJA_NEPRIMENIMA: нет якоря экспорта FadenSign для мутанта %s' % imja, file=sys.stderr)
                    return 2
            (kopija / FADEN).write_text(ishodnyj if tekst is None else tekst, encoding='utf-8')
            svod, oshibka = zapustit_jest()
            if svod is None:
                itogi.append((imja, 'infra', oshibka))
                continue
            assery, sjuity = klassificirovat(svod)
            zelen = bool(svod.get('success')) and int(svod.get('numPassedTests', 0)) > 0
            if tekst is None:
                itogi.append((imja, 'zelen' if zelen else 'krasen',
                              'suites=%s tests=%s' % (svod.get('numTotalTestSuites'), svod.get('numTotalTests'))))
            elif assery > 0:
                itogi.append((imja, 'ubit', 'упавших ассертов %d' % assery))
            elif sjuity > 0:
                itogi.append((imja, 'infra', 'сьют(ы) не исполнились: загрузка/трансформ — не убит'))
            else:
                itogi.append((imja, 'zhiv', 'обязательный тест зелёный под мутантом'))
        (kopija / FADEN).write_text(ishodnyj, encoding='utf-8')

        for imja, status, dop in itogi:
            print('LIVE %s: %s — %s' % (imja, status.upper(), dop))
        kontrol = itogi[0]
        if kontrol[1] != 'zelen':
            print('LIVE_KONTROL_KRASEN: обязательный тест не зелён на исходном компоненте', file=sys.stderr)
            return 1
        for imja, status, dop in itogi[1:]:
            if status == 'zhiv':
                print('LIVE_MUTANT_ZHIV: %s — поведение не поймано обязательным тестом' % imja, file=sys.stderr)
                return 1
            if status == 'infra':
                print('LIVE_MUTACIJA_INFRA: %s — инфраструктурное падение, не предметный ассерт (%s)' % (imja, dop), file=sys.stderr)
                return 1
        print('LIVE: контроль зелён, мутантов %d, все убиты предметными ассертами обязательного теста'
              % (len(itogi) - 1))
        return 0
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


def glavnaja():
    rezhim = None
    repo = None
    seed = None
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == '--model':
            rezhim = 'model'
        elif args[i] in ('--stabs', '--matrix'):
            rezhim = 'stabs'
        elif args[i] == '--live-component':
            rezhim = 'live'
        elif args[i] == '--repo':
            repo = args[i + 1]
            i += 1
        elif args[i] == '--seed':
            try:
                seed = int(args[i + 1])
            except (ValueError, IndexError):
                print('NEIZVESTNYJ_ARGUMENT: --seed требует целое число', file=sys.stderr)
                return 2
            i += 1
        else:
            print('NEIZVESTNYJ_ARGUMENT: %s' % args[i], file=sys.stderr)
            return 2
        i += 1
    if shutil.which(os.environ.get('NODEBIN', 'node')) is None:
        print('NOT_IMPLEMENTED: нет node', file=sys.stderr)
        return 2
    try:
        src = json.loads(SOURCE.read_text(encoding='utf-8'))
    except Exception as e:
        return oshibka_orakula('source.json: %s' % e)
    prog = zhestkij_kanon(src)
    if prog:
        return oshibka_orakula(prog)

    if rezhim == 'live':
        if not repo:
            print('NEIZVESTNYJ_ARGUMENT: --live-component требует --repo R', file=sys.stderr)
            return 2
        repo_root = Path(repo).resolve()
        if not (repo_root / 'mobile').is_dir():
            print('OTKAZ: --repo не похож на корень продукта: %s' % repo_root, file=sys.stderr)
            return 2
        return zhivoj_komponent(repo_root)
    vrem = tempfile.mkdtemp(prefix='faden-145-')
    try:
        if rezhim in ('model', 'stabs'):
            subject = MODEL / 'faden-motion.js'
            tokens = MODEL / 'motion-tokens.ts'
            driver = MODEL / 'drajver.json'
            istochnik = MODEL / 'istochnik-sostojanij.mjs'
            rezhim_runnera = 'model'
            repo_root = None
        elif repo:
            repo_root = Path(repo).resolve()
            subject = repo_root / SUBJEKT_DVIZOK
            tokens = repo_root / SUBJEKT_TOKENY
            driver = repo_root / SUBJEKT_DRAJVER
            istochnik = repo_root / SUBJEKT_ISTOCHNIK
            if not (repo_root / 'mobile').is_dir():
                print('OTKAZ: --repo не похож на корень продукта: %s' % repo_root, file=sys.stderr)
                return 2
            if not subject.is_file():
                print('клеток %d, зелёных 0, красных %d — SUBJECT_ABSENT (нет %s; задайте --repo <корень продукта> или --model)'
                      % (len(src['kletki']), len(src['kletki']), SUBJEKT_DVIZOK))
                for k in src['kletki']:
                    print('КЛЕТКА %s КРАСНА: SUBJECT_ABSENT' % k['id'])
                return 1
            rezhim_runnera = 'repo'
        else:
            print('клеток %d, зелёных 0, красных %d — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)'
                  % (len(src['kletki']), len(src['kletki'])))
            for k in src['kletki']:
                print('КЛЕТКА %s КРАСНА: SUBJECT_ABSENT' % k['id'])
            return 1

        runner, kletki = zapusti_runnera(subject, tokens, driver, rezhim_runnera, repo_root, seed=seed, subject_istochnik=istochnik)
        if not kletki:
            print('NOT_IMPLEMENTED: раннер не вернул клеток (rc=%d): %s'
                  % (runner.returncode, (runner.stderr or runner.stdout).strip()[:400]), file=sys.stderr)
            return 2
        zeljonye, krasnye = svod(kletki)
        print('клеток %d, зелёных %d, красных %d' % (len(kletki), len(zeljonye), len(krasnye)))
        for k in krasnye:
            print('КЛЕТКА %s КРАСНА: %s' % (k['kletka'], k['prichina'][:300]))
        if rezhim != 'stabs':
            return 1 if krasnye else 0
        if krasnye:
            print('KONTROL_KRASEN — стабы не гоняются', file=sys.stderr)
            return 1
        n, svjazi, zhivye = progony_stabov(vrem, src, seed=seed)
        if n < 0:
            return oshibka_orakula('стабы: %s' % zhivye[0])
        print('стабов %d, привязок %d, непойманных %d' % (n, svjazi, len(zhivye)))
        for z in zhivye:
            print('STAB_ZHIV: %s' % z)
        return 1 if zhivye else 0
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


if __name__ == '__main__':
    try:
        sys.exit(glavnaja())
    except BrokenPipeError:
        sys.exit(1)
