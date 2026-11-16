#!/usr/bin/env python3
# Батарея 197 (contracts/197-mob-ci-artefakty-lokalno.md): CI моба пишет и
# читает артефакты ЛОКАЛЬНО (/var/lib/ci-artifacts/Complior-mob/<run_id>-<run_attempt>/<имя>/),
# канал GitHub Actions upload/download-artifact закрыт.
#
# Режимы (аргументом, как red_mob_ci_143.sh):
#   (без флагов)      rc 1 SUBJECT_ABSENT — реализации в продукте нет
#   --model           судит model/ (честная реализация — все клетки зелёные)
#   --stabs           контроль + обманные стабы: мутация КОДОМ копии модели,
#                     каждая мутация обязана краснеть СВОЕЙ именованной причиной
#   --repo <корень>   судит живое дерево продукта (Complior-mob)
#
# Оракул: ожидания вычисляются ДО чтения субъекта; пины sha256 модели — в
# source.json; рассинхрон → rc 2 ORACLE_TAMPERED. Субъект --repo НЕ служит
# источником ожиданий никогда.
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

ZDES = Path(__file__).resolve().parent
MODEL = ZDES / 'model'
RE_IMJA = re.compile(r'^[A-Za-z0-9][A-Za-z0-9._-]*$')
RE_SHABLON = re.compile(r'^[A-Za-z0-9][A-Za-z0-9._*-]*$')
RE_GH = re.compile(r'gh\s+(run\s+download|api\b[^\n]*/artifacts)')
LANE_ZAPIS = 'ci:artefakt-zapis'
LANE_CHTENIE = 'ci:artefakt-chtenie'
ZNACHENIE_LINEI = {
    LANE_ZAPIS: 'node mobile/scripts/ci-artefakty.cjs zapis',
    LANE_CHTENIE: 'node mobile/scripts/ci-artefakty.cjs chtenie',
}


def oshibka_orakula(prichina):
    print('ORACLE_TAMPERED: ' + prichina, file=sys.stderr)
    sys.exit(2)


def zaghruzit_orakul():
    """Пины модели читаются и сверяются ДО любого обращения к субъекту."""
    import hashlib
    src = json.loads((ZDES / 'source.json').read_text(encoding='utf-8'))
    for otnositelno, ozhidanyj in sorted(src['piny'].items()):
        put = MODEL / otnositelno
        if not put.is_file():
            oshibka_orakula(f'файл модели отсутствует: {otnositelno}')
        fakt = hashlib.sha256(put.read_bytes()).hexdigest()
        if fakt != ozhidanyj:
            oshibka_orakula(f'пин: sha256 {otnositelno}: {fakt} != {ozhidanyj}')
    return src


# ── разбор run-текста на команды: разделители && / ; / || и перевод строки
#    УВАЖАЮТ кавычки (состояние переносится между строками — кавычка,
#    открытая на одной строке, не прячет разделители на следующей);
#    тело heredoc <<TAG…TAG — ДАННЫЕ, не команды; '#' вне кавычек —
#    комментарий до конца строки ──

RE_HEREDOC = re.compile(r'<<-?\s*(["\']?)([A-Za-z_][A-Za-z0-9_]*)\1')


def razbor_nositelja(text):
    """[(leksy|None, razdeliteli)] — сегменты команд run-текста; у каждого
    сегмента — разделители, соединяющие его с ПРЕДЫДУЩИМ непустым сегментом
    ('&&'/'||'/';' — оператор композиции, '\\n' — граница строки).
    shlex-невыразимый сегмент → leksy None (шаг целиком вне судимых форм)."""
    rezultat, tekushchij, razdeliteli = [], [], []
    kod_stroki = []
    kavoichki = None
    heredoc_teg = None
    tekst = str(text)
    i, n = 0, len(tekst)

    def slit():
        s = ''.join(tekushchij).strip()
        del tekushchij[:]
        if not s:
            return
        try:
            leksy = shlex.split(s)
        except ValueError:
            leksy = None
        rezultat.append((leksy, list(razdeliteli)))
        del razdeliteli[:]

    while i < n:
        c = tekst[i]
        if heredoc_teg is not None:
            # тело heredoc — данные: до строки-терминатора включительно
            if c != '\n':
                i += 1
                continue
            konec = tekst.find('\n', i + 1)
            stroka = tekst[i + 1: n if konec == -1 else konec]
            if stroka.strip() == heredoc_teg:
                heredoc_teg = None
            i = n if konec == -1 else konec
            continue
        if kavoichki is not None:
            tekushchij.append(c)
            kod_stroki.append(c)
            if c == kavoichki:
                kavoichki = None
            i += 1
            continue
        if c in ('"', "'"):
            kavoichki = c
            tekushchij.append(c)
            kod_stroki.append(c)
            i += 1
            continue
        if c == '#':
            # комментарий вне кавычек — данные до конца строки
            i = tekst.find('\n', i)
            if i == -1:
                break
            continue
        if tekst.startswith('&&', i) or tekst.startswith('||', i):
            slit()
            razdeliteli.append(tekst[i:i + 2])
            i += 2
            continue
        if c == ';':
            slit()
            razdeliteli.append(';')
            i += 1
            continue
        if c == '\n':
            slit()
            teg = RE_HEREDOC.findall(''.join(kod_stroki))
            del kod_stroki[:]
            if teg:
                heredoc_teg = teg[-1][1]
            razdeliteli.append('\n')
            i += 1
            continue
        tekushchij.append(c)
        kod_stroki.append(c)
        i += 1
    slit()
    return rezultat


def razobrat_vyzov(leksy):
    """npm run <lane> -- --klyuch znachenie… → (lane, {klyuch: znachenie}) | None."""
    if len(leksy) < 4 or leksy[:2] != ['npm', 'run'] or leksy[3] != '--':
        return None
    return leksy[2], dict(zip(leksy[4::2], leksy[5::2]))


def vyzovy_lanej(komandy_spisok):
    rezultat = []
    for leksy in komandy_spisok or []:
        if not leksy:
            continue
        if leksy[:2] == ['npm', 'run'] and len(leksy) > 2 and leksy[2] in (LANE_ZAPIS, LANE_CHTENIE):
            rezultat.append(razobrat_vyzov(leksy))
    return [r for r in rezultat if r is not None]


# ── разрешение имён: env шага → env job → env workflow → выражение ${{ }} ──

def kontekst_env(job, shag, wf):
    rezultat = {}
    rezultat.update({str(k): str(v) for k, v in (wf.get('env') or {}).items()})
    rezultat.update({str(k): str(v) for k, v in (job.get('env') or {}).items()})
    rezultat.update({str(k): str(v) for k, v in (shag.get('env') or {}).items()})
    return rezultat


def razreshit_znachenie(znachenie, env):
    """'$IMJA' → выражение env-привязки; иначе литерал/выражение как есть."""
    znachenie = str(znachenie)
    if znachenie.startswith('$') and not znachenie.startswith('${{'):
        imja = znachenie[1:]
        if imja not in env:
            return None
        return str(env[imja])
    return znachenie


def klass_imeni(vyrazhenie):
    """Выражение → класс для замыкания: ${{ … }} заменяется на '*',
    литеральные концы сохраняются."""
    return re.sub(r'\$\{\{[^}]*\}\}', '*', str(vyrazhenie))


def shablon_pokryvaet(shablon, klass):
    """Паттерн p (с '*') покрывает класс n (с '*') консервативно:
    p_regex целиком принимает оба литеральных конца класса и префикс/суффикс
    согласованы. Всё прочее — не покрыто (красное)."""
    def kuski(s):
        zvezda = s.find('*')
        if zvezda < 0:
            return s, s
        return s[:zvezda], s[zvezda + 1:]
    prefiks_p, suffiks_p = kuski(shablon)
    prefiks_n, suffiks_n = kuski(klass)
    regex = re.compile('^' + re.escape(shablon).replace('\\*', '[^/]*') + '$')
    if not (regex.match(prefiks_n) and regex.match(prefiks_n + 'x' + suffiks_n)):
        return False
    return prefiks_n.startswith(prefiks_p) and suffiks_n.endswith(suffiks_p)


# ── субъект ──

class Subiekt:
    def __init__(self, koren):
        self.koren = Path(koren).resolve()
        self.workflow_put = self.koren / '.github/workflows/mobile.yml'
        self.skript_put = self.koren / 'mobile/scripts/ci-artefakty.cjs'
        self.package_put = self.koren / 'package.json'

    def chitaetsja(self):
        return self.workflow_put.is_file()


def razobrat_subiekta(subiekt):
    wf = yaml.safe_load(subiekt.workflow_put.read_text(encoding='utf-8'))
    shagi = []           # (job_id, step, komandy, env, razbor)
    for job_id, job in sorted((wf.get('jobs') or {}).items()):
        for shag in job.get('steps') or []:
            zapisi = razbor_nositelja(shag.get('run') or '')
            spisok = []
            vyrazimo = True
            for leksy, _ in zapisi:
                if leksy is None:
                    vyrazimo = False
                    break
                spisok.append(leksy)
            env = kontekst_env(job, shag, wf)
            shagi.append((job_id, shag, spisok if vyrazimo else None, env, zapisi))
    return wf, shagi


# ── клетки ──

KLETKI = []


def kletka(id_kletki):
    def dekorator(fn):
        KLETKI.append((id_kletki, fn))
        return fn
    return dekorator


@kletka('a01-upload-artefakt-ostalsja')
def a01(subiekt, wf, shagi, _):
    for job_id, job in sorted((wf.get('jobs') or {}).items()):
        for shag in job.get('steps') or []:
            if str(shag.get('uses') or '').startswith('actions/upload-artifact'):
                return f'UPLOAD_ARTIFAKT_OSTALSJA: {job_id}.{shag.get("name")}'
    return None


@kletka('a02-download-artefakt-ostalsja')
def a02(subiekt, wf, shagi, _):
    for job_id, job in sorted((wf.get('jobs') or {}).items()):
        for shag in job.get('steps') or []:
            if str(shag.get('uses') or '').startswith('actions/download-artifact'):
                return f'DOWNLOAD_ARTIFAKT_OSTALSJA: {job_id}.{shag.get("name")}'
    return None


@kletka('a03-gh-kanal-v-run')
def a03(subiekt, wf, shagi, _):
    for job_id, job in sorted((wf.get('jobs') or {}).items()):
        for shag in job.get('steps') or []:
            if RE_GH.search(str(shag.get('run') or '')):
                return f'GH_KANAL_V_RUN: {job_id}.{shag.get("name")}'
    return None


def _vse_vyzovy(shagi):
    """[(job, shag, lane, parametry, env)] для каждого lane-вызова."""
    rezultat = []
    for job_id, shag, spisok, env, _zapisi in shagi:
        for lane, parametry in vyzovy_lanej(spisok):
            rezultat.append((job_id, shag, lane, parametry, env))
    return rezultat


def _parametry_razreshennye(vyzov):
    job_id, shag, lane, parametry, env = vyzov
    razreshennye = {}
    for kljuch, znachenie in parametry.items():
        razreshennye[kljuch] = razreshit_znachenie(znachenie, env)
    return razreshennye


@kletka('b01-forma-pisatelja')
def b01(subiekt, wf, shagi, _):
    razreshennye_stroki = ('set', 'test', '[')
    for job_id, shag, spisok, env, _zapisi in shagi:
        est_zapis = any(leksy[:3] == ['npm', 'run', LANE_ZAPIS] for leksy in spisok or [])
        if not est_zapis:
            continue
        vyzovy = [leksy for leksy in spisok
                  if leksy[:3] == ['npm', 'run', LANE_ZAPIS]]
        if len(vyzovy) != 1:
            return f'FORMA_PISATELJA: {job_id}.{shag.get("name")}: вызовов zapis {len(vyzovy)} (канон: 1)'
        for leksy in spisok:
            if leksy[:3] == ['npm', 'run', LANE_ZAPIS]:
                continue
            if not (leksy and leksy[0] in razreshennye_stroki):
                return f'FORMA_PISATELJA: {job_id}.{shag.get("name")}: посторонняя команда {leksy[:1]}'
        razbor = razobrat_vyzov(vyzovy[0])
        if razbor is None or set(razbor[1]) != {'--imja', '--chto'}:
            return f'FORMA_PISATELJA: {job_id}.{shag.get("name")}: аргументы {sorted(set(razbor[1])) if razbor else None} != --imja/--chto'
    return None


@kletka('b02-imja-pisatelja-razreshimo')
def b02(subiekt, wf, shagi, _):
    for vyzov in _vse_vyzovy(shagi):
        if vyzov[2] != LANE_ZAPIS:
            continue
        parametry = _parametry_razreshennye(vyzov)
        imja = parametry.get('--imja')
        if imja is None:
            return f'IMJA_PISATELJA_NE_RAZRESIMO: {vyzov[0]}.{vyzov[1].get("name")}'
        # замкнутый алфавит выражений имени писателя: литерал; шаговый output
        # идентичности (steps.<id>.outputs.<key>); matrix-класс (литеральные
        # концы + ${{ matrix.* }}). Прочие выражения (github./secrets./needs.
        # у писателя) именем артефакта не бывают.
        vyrazhenija = re.findall(r'\$\{\{([^}]*)\}\}', imja)
        for vyrazhenie in vyrazhenija:
            if not (vyrazhenie.strip().startswith('steps.') or vyrazhenie.strip().startswith('matrix.')):
                return f'IMJA_PISATELJA_NE_RAZRESIMO: {vyzov[0]}.{vyzov[1].get("name")}: {imja}'
        if not vyrazhenija and not RE_IMJA.match(imja):
            return f'IMJA_PISATELJA_NE_RAZRESIMO: {vyzov[0]}.{vyzov[1].get("name")}: {imja}'


@kletka('b03-pisatel-s-run-argumentom')
def b03(subiekt, wf, shagi, _):
    for vyzov in _vse_vyzovy(shagi):
        if vyzov[2] == LANE_ZAPIS and ('--run-id' in vyzov[3] or '--run-attempt' in vyzov[3]):
            return f'PISATEL_S_RUN_ARGUMENTOM: {vyzov[0]}.{vyzov[1].get("name")}'
    return None


@kletka('c01-forma-chitatelja')
def c01(subiekt, wf, shagi, _):
    razreshennye_stroki = ('set', 'test', '[', 'rm', 'mkdir')
    for job_id, shag, spisok, env, _zapisi in shagi:
        est = [leksy for leksy in spisok or [] if leksy[:3] == ['npm', 'run', LANE_CHTENIE]]
        if not est:
            continue
        if len(est) != 1:
            return f'FORMA_CHITATELJA: {job_id}.{shag.get("name")}: вызовов chtenie {len(est)} (канон: 1)'
        # у читателя судится ФОРМА lane-вызова (ровно один, закрытые ключи,
        # пара run-аргументов); охранные команды шага (digest и пр.) свободны —
        # запись мимо канона ловят b01/b02/d01/d02 на писателях и корне
        razbor = razobrat_vyzov(est[0])
        if razbor is None:
            return f'FORMA_CHITATELJA: {job_id}.{shag.get("name")}: невыразимая форма'
        parametry = razbor[1]
        kljuchi = set(parametry)
        # неполная идентификация судится РАНЬШЕ алфавита ключей: это более
        # точное имя дефекта для того же входа
        if ('--run-id' in kljuchi) != ('--run-attempt' in kljuchi):
            return f'NEPOLNAJA_IDENTIFIKACIJA_RUNA: {job_id}.{shag.get("name")}'
        razreshennye_kljuchi = [{'--imja', '--kuda'}, {'--shablon', '--kuda'},
                                {'--imja', '--kuda', '--run-id', '--run-attempt'},
                                {'--shablon', '--kuda', '--run-id', '--run-attempt'}]
        if kljuchi not in razreshennye_kljuchi:
            return f'FORMA_CHITATELJA: {job_id}.{shag.get("name")}: аргументы {sorted(kljuchi)}'
    return None


@kletka('c02-imja-bez-pisatelja')
def c02(subiekt, wf, shagi, _):
    vyzovy = _vse_vyzovy(shagi)
    pisateli = [_parametry_razreshennye(v)['--imja'] for v in vyzovy if v[2] == LANE_ZAPIS]
    for vyzov in vyzovy:
        if vyzov[2] != LANE_CHTENIE:
            continue
        parametry = _parametry_razreshennye(vyzov)
        if '--imja' in parametry:
            chitaemoe = parametry['--imja']
            if chitaemoe is None:
                return f'IMJA_CHITATELJA_NE_RAZRESIMO: {vyzov[0]}.{vyzov[1].get("name")}'
            klassy = [klass_imeni(p) for p in pisateli if p is not None]
            if klass_imeni(chitaemoe) not in klassy:
                return f'IMJA_BEZ_PISATELJA: {vyzov[0]}.{vyzov[1].get("name")}: {chitaemoe}'
        elif '--shablon' in parametry:
            shablon = parametry['--shablon']
            if shablon is None or not RE_SHABLON.match(shablon):
                return f'SHABLON_VNE_ALFAVITA: {vyzov[0]}.{vyzov[1].get("name")}'
            if not any(shablon_pokryvaet(shablon, klass_imeni(p)) for p in pisateli if p is not None):
                return f'SHABLON_BEZ_PISATELEJ: {vyzov[0]}.{vyzov[1].get("name")}: {shablon}'
    return None

@kletka('c03-run-para-iz-sborki')
def c03(subiekt, wf, shagi, _):
    # продюсерская пара APK-читателя (И-4): НАЛИЧИЕ и происхождение.
    # Читатель потребляемой категории APK обязан нести пару --run-id/
    # --run-attempt (Frontier-строка «ищет в собственной попытке» отклонена:
    # выборочный повтор работника теряет сборку) — отсутствие пары красна
    # именованной причиной. Значения пары ПОСЛЕ env-разрешения — только
    # выражения needs.build-apk.outputs.*: литеральная пара чужого прогона
    # проходит форму c01, но не происхождение.
    ozhidaemye = {'--run-id': 'needs.build-apk.outputs.run_id',
                  '--run-attempt': 'needs.build-apk.outputs.run_attempt'}
    for vyzov in _vse_vyzovy(shagi):
        if vyzov[2] != LANE_CHTENIE:
            continue
        parametry = _parametry_razreshennye(vyzov)
        imja = parametry.get('--imja')
        if imja is not None and _klass_v_inventare(klass_imeni(imja), 'apk-*') \
                and not ({'--run-id', '--run-attempt'} <= set(parametry)):
            return (f'CHITATEL_APK_BEZ_PARY: {vyzov[0]}.{vyzov[1].get("name")}:'
                    f' {imja}')
        for kljuch, ozhidaemoe in ozhidaemye.items():
            if kljuch not in parametry:
                continue
            znachenie = str(parametry[kljuch])
            vyrazhenija = re.findall(r'\$\{\{([^}]*)\}\}', znachenie)
            if len(vyrazhenija) != 1 or vyrazhenija[0].strip() != ozhidaemoe:
                return (f'RUN_PARA_NE_IZ_SBORKI: {vyzov[0]}.{vyzov[1].get("name")}:'
                        f' {kljuch}={znachenie}')
    return None


@kletka('d01-koren-vne-skripta')
def d01(subiekt, wf, shagi, _):
    for job_id, job in sorted((wf.get('jobs') or {}).items()):
        for shag in job.get('steps') or []:
            teksty = [str(shag.get('run') or '')] + [str(v) for v in (shag.get('env') or {}).values()]
            for tekst in teksty:
                if '/var/lib/ci-artifacts' in tekst:
                    return f'KOREN_VNE_SKRIPTA: {job_id}.{shag.get("name")}'
    return None


@kletka('d02-vyhod-za-koren')
def d02(subiekt, wf, shagi, _):
    for vyzov in _vse_vyzovy(shagi):
        job_id, shag, lane, parametry, env = vyzov
        razreshennye = _parametry_razreshennye(vyzov)
        for kljuch in ('--imja', '--shablon'):
            znachenie = razreshennye.get(kljuch)
            if znachenie is None:
                continue
            if '/' in znachenie or '..' in znachenie or not (RE_IMJA.match(znachenie) or RE_SHABLON.match(znachenie) or '${{' in znachenie):
                return f'IMJA_VNE_ALFAVITA: {job_id}.{shag.get("name")}: {znachenie}'
        for kljuch in ('--chto', '--kuda'):
            znachenie = razreshennye.get(kljuch)
            if znachenie is None:
                continue
            if znachenie.startswith('/') or '..' in str(znachenie).split('/'):
                return f'VYHOD_ZA_KOREN: {job_id}.{shag.get("name")}: {znachenie}'
    return None


@kletka('e01-skript-pin')
def e01(subiekt, wf, shagi, orakul):
    import hashlib
    if not subiekt.skript_put.is_file():
        return 'SKRIPT_NET: mobile/scripts/ci-artefakty.cjs'
    fakt = hashlib.sha256(subiekt.skript_put.read_bytes()).hexdigest()
    pin = orakul['piny']['mobile/scripts/ci-artefakty.cjs']
    if fakt != pin:
        return f'SKRIPT_PIN_RASHOZHDENIE: {fakt} != {pin}'
    return None


@kletka('e02-linei-npm')
def e02(subiekt, wf, shagi, _):
    if not subiekt.package_put.is_file():
        return 'LINEJ_NET: package.json'
    try:
        paket = json.loads(subiekt.package_put.read_text(encoding='utf-8'))
    except ValueError:
        return 'LINEJ_NET: package.json не JSON'
    skripty = paket.get('scripts') or {}
    for lane, znachenie in sorted(ZNACHENIE_LINEI.items()):
        if skripty.get(lane) != znachenie:
            return f'LINEJA_FORMA: {lane} = {skripty.get(lane)!r} != {znachenie!r}'
    return None

# ── исполнимость и замкнутый инвентарь (писатели и читатели вместе) ──

DOPUSTIMYE_IF_SHAGA = {'always()', 'success()'}
# константная ложь условий носителя: текстовые формы, Yaml-булево
# (str(False) → 'False') и замаскированная ложь !always(); прочие выражения
# job-условия носителя структурой не судятся (канон needs/matrix — предмет
# 143), шаговые — замкнутый канон DOPUSTIMYE_IF_SHAGA
LOZHNO = {'false', 'False', '${{ false }}', '!always()', '${{ !always() }}'}

# замкнутый инвентарь имён предмета: категория → (шаблон класса, читатель
# в workflow обязан быть). Терминальные категории читает ops/server (196),
# потребляемые — работники этого же workflow. Класс '*' (имя-выражение из
# steps./matrix.) удовлетворяет только glob-категориям (в каноне это
# apk-sborki и child-evidence) — известная грубость класса.
INVENTAR = {
    'apk-sborki': ('apk-*', True),
    'selection': ('selection', False),
    'dokazatelstva-ekranov': ('maestro*', False),
    'child-evidence': ('screen-evidence-*', True),
    'marker-regressii': ('regression-marker', False),
}


def _est_lane_v_shage(spisok):
    return any(leksy[:3] in (['npm', 'run', LANE_ZAPIS], ['npm', 'run', LANE_CHTENIE])
               for leksy in spisok or [])


def _klass_v_inventare(klass, shablon):
    if klass == '*':
        return '*' in shablon
    if '*' not in shablon:
        return klass == shablon
    return shablon_pokryvaet(shablon, klass)

def _soedinenija_vokrug_vyzova(zapisi):
    """Операторы композиции ('&&'/'||'/';'), соединяющие lane-сегмент с
    соседями; перевод строки разделителем не считается. Пусто — вызов
    безусловен: исполняется всегда, провал не подавлен."""
    for k, (leksy, pered) in enumerate(zapisi or []):
        if not leksy or leksy[:3] not in (['npm', 'run', LANE_ZAPIS],
                                          ['npm', 'run', LANE_CHTENIE]):
            continue
        posle = zapisi[k + 1][1] if k + 1 < len(zapisi) else []
        soedineno = [r for r in list(pered) + list(posle) if r != '\n']
        if soedineno:
            return soedineno
    return []


@kletka('i01-nositel-ispolnim')
def i01(subiekt, wf, shagi, _):
    # клетка краснеет, когда операция ОТСУТСТВУЕТ или НЕИСПОЛНИМА,
    # а не когда в файле есть текст
    for job_id, shag, spisok, env, zapisi in shagi:
        if not _est_lane_v_shage(spisok):
            continue
        uslovie = shag.get('if')
        if uslovie is not None:
            tekst = str(uslovie).strip()
            if tekst in LOZHNO:
                return f'NOSITEL_NEISPOLNIM: {job_id}.{shag.get("name")}: if={tekst}'
            if tekst not in DOPUSTIMYE_IF_SHAGA:
                return f'USLOVIE_VNE_KANONA: {job_id}.{shag.get("name")}: if={tekst}'
        podavlen = shag.get('continue-on-error')
        if podavlen is not None and podavlen not in (False, 'false', 'False'):
            return f'PROVALY_PODAVLENY: {job_id}.{shag.get("name")}: continue-on-error={podavlen}'
        # носитель — БЕЗУСЛОВНАЯ команда: оператор &&/||/; у lane-вызова
        # (в любую сторону, перенос строки после оператора включён) красит
        # шаг — константно-ложная охрана (test false && …) и подавление
        # провала (… || test / … || true) закрыты одним свойством композиции
        soedinenija = _soedinenija_vokrug_vyzova(zapisi)
        if soedinenija:
            return (f'VYZOV_NE_BEZUSLOVEN: {job_id}.{shag.get("name")}:'
                    f' lane-вызов соединён {" ".join(soedinenija)}')
    for job_id in sorted({j for j, shag, spisok, env, _zapisi in shagi
                          if _est_lane_v_shage(spisok)}):
        job = (wf.get('jobs') or {}).get(job_id) or {}
        uslovie = job.get('if')
        # str() не проглатывает Yaml-булево False (проглатывание 'or ""'
        # было дефектом блока 1 вердикта Crit197V2)
        tekst = '' if uslovie is None else str(uslovie).strip()
        if tekst in LOZHNO:
            return f'JOB_NOSITELJA_OTKLJUCHEN: {job_id}: if={tekst}'
        podavlen = job.get('continue-on-error')
        if podavlen is not None and podavlen not in (False, 'false', 'False'):
            return f'PROVALY_PODAVLENY: {job_id}: job continue-on-error={podavlen}'
        podavlen = (job.get('strategy') or {}).get('continue-on-error')
        if podavlen is not None and podavlen not in (False, 'false', 'False'):
            return f'PROVALY_PODAVLENY: {job_id}: strategy.continue-on-error={podavlen}'
    return None


@kletka('i02-zamknutyj-inventar')
def i02(subiekt, wf, shagi, _):
    # замкнутый инвентарь категорий предмета: каждая категория написана,
    # посторонних писателей нет, потребляемые категории читаются — молчаливая
    # потеря (удаление/ослепление писателя или читателя) видима поимённо
    vyzovy = _vse_vyzovy(shagi)
    klassy_pisatelej = [klass_imeni(p) for p in
                        (_parametry_razreshennye(v)['--imja'] for v in vyzovy if v[2] == LANE_ZAPIS)
                        if p is not None]
    for kategorija, (shablon, nuzhen_chitatel) in INVENTAR.items():
        if not any(_klass_v_inventare(klass, shablon) for klass in klassy_pisatelej):
            return f'KATEGORIJA_BEZ_PISATELJA: {kategorija}'
    for klass in klassy_pisatelej:
        if not any(_klass_v_inventare(klass, shablon) for shablon, _ in INVENTAR.values()):
            return f'POSTORONNIJ_PISATEL: {klass}'
    for kategorija, (shablon, nuzhen_chitatel) in INVENTAR.items():
        if not nuzhen_chitatel:
            continue
        est_chitatel = False
        for vyzov in vyzovy:
            if vyzov[2] != LANE_CHTENIE:
                continue
            parametry = _parametry_razreshennye(vyzov)
            if parametry.get('--imja') is not None and \
                    _klass_v_inventare(klass_imeni(parametry['--imja']), shablon):
                est_chitatel = True
            if parametry.get('--shablon') is not None and \
                    _klass_v_inventare(parametry['--shablon'], shablon):
                est_chitatel = True
        if not est_chitatel:
            return f'KATEGORIJA_BEZ_CHITATELJA: {kategorija}'
    return None


# ── replay клеток: скрипт субъекта в замкнутой песочнице ──

class Pesok:
    def __init__(self, skript):
        self.koren = Path(tempfile.mkdtemp(prefix='artefakt197-'))
        self.koren_artefaktov = self.koren / 'koren'
        self.koren_artefaktov.mkdir()
        self.skript = skript
        self.istochniki = self.koren / 'src'
        (self.istochniki / 'ekran').mkdir(parents=True)

    def zapis(self, name, soderzhimoe):
        put = self.istochniki / name
        put.parent.mkdir(parents=True, exist_ok=True)
        put.write_text(soderzhimoe, encoding='utf-8')

    def vyzov(self, argumenty, run_id='4242', popytka='1'):
        env = dict(os.environ)
        env['CI_ARTEFAKTY_KOREN'] = str(self.koren_artefaktov)
        env['GITHUB_RUN_ID'] = run_id
        env['GITHUB_RUN_ATTEMPT'] = popytka
        protsess = subprocess.run(['node', str(self.skript)] + argumenty,
                                  capture_output=True, text=True, env=env, cwd=str(self.koren))
        return protsess

    def udalit(self):
        shutil.rmtree(self.koren, ignore_errors=True)


def _replay_kletka(id_kletki):
    """Replay-клетка: fn(pesok) → причина | None; песочницу строит прогон."""
    def dekorator(fn):
        KLETKI.append((id_kletki, fn))
        return fn
    return dekorator


def _sudit_replay(fn, subiekt, orakul):
    if not subiekt.skript_put.is_file():
        return 'SKRIPT_NET: mobile/scripts/ci-artefakty.cjs'
    pesok = Pesok(subiekt.skript_put)
    try:
        return fn(pesok)
    finally:
        pesok.udalit()


@_replay_kletka('r01-krug-zapisi-chtenija')
def r01(pesok):
    pesok.zapis('selection.json', '{"vybor": ["e2e-splash"]}')
    p = pesok.vyzov(['zapis', '--imja', 'selection', '--chto', 'src/selection.json'])
    if p.returncode != 0:
        return f'ZAPIS_OTKAZ: rc={p.returncode} {p.stderr.strip()}'
    p = pesok.vyzov(['chtenie', '--imja', 'selection', '--kuda', 'vychitka'])
    if p.returncode != 0:
        return f'CHTENIE_OTKAZ: rc={p.returncode} {p.stderr.strip()}'
    prochitano = pesok.koren / 'vychitka/selection.json'
    if not prochitano.is_file() or prochitano.read_text(encoding='utf-8') != '{"vybor": ["e2e-splash"]}':
        return 'KRUG_NARUSHEN: содержание не совпало'
    return None


@_replay_kletka('r02-popytka-prodjusera')
def r02(pesok):
    pesok.zapis('app-release.apk', 'apk-bytes')
    p = pesok.vyzov(['zapis', '--imja', 'apk-4242-abc', '--chto', 'src/app-release.apk'], popytka='1')
    if p.returncode != 0:
        return f'ZAPIS_OTKAZ: rc={p.returncode}'
    # повтор одного работника: собственная попытка 2, сборка лежит в попытке 1
    p = pesok.vyzov(['chtenie', '--imja', 'apk-4242-abc', '--kuda', 'apk-build',
                     '--run-id', '4242', '--run-attempt', '1'], popytka='2')
    if p.returncode != 0:
        return f'SBORKA_NE_PEREZHILA_POVTOR: rc={p.returncode} {p.stderr.strip()}'
    if (pesok.koren / 'apk-build/app-release.apk').read_text(encoding='utf-8') != 'apk-bytes':
        return 'SBORKA_NE_PEREZHILA_POVTOR: содержание не совпало'
    p = pesok.vyzov(['chtenie', '--imja', 'apk-4242-abc', '--kuda', 'apk-build-2'], popytka='2')
    # собственная попытка пуста: честный исход — именованный отказ (нет
    # каталога run'а или нет имени), но НИКОГДА молчаливое чтение чужой попытки
    if p.returncode == 0 or not ('CHTENIE_OTSTUTSTVUET' in p.stderr or 'KATALOG_RUNA_OTSTUTSTVUET' in p.stderr):
        return f'SOBSTVENNAJA_POPYTKA_NE_IZOLIROVANA: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r03-imja-pobeg')
def r03(pesok):
    pesok.zapis('app-release.apk', 'x')
    snaru = pesok.koren / 'snaru'
    snaru.mkdir()
    env_koren = pesok.koren_artefaktov
    protsess = subprocess.run(
        ['node', str(pesok.skript), 'zapis', '--imja', '../pobeg', '--chto', 'src/app-release.apk'],
        capture_output=True, text=True,
        env={**os.environ, 'CI_ARTEFAKTY_KOREN': str(env_koren), 'GITHUB_RUN_ID': '4242', 'GITHUB_RUN_ATTEMPT': '1'},
        cwd=str(pesok.koren))
    if protsess.returncode == 0 or 'IMJA_VNE_ALFAVITA' not in protsess.stderr:
        return f'POBEG_PROPUSHCHEN: rc={protsess.returncode} {protsess.stderr.strip()}'
    if any(env_koren.parent.glob('pobeg')) or list(snaru.iterdir()):
        return 'POBEG_ISPOLNEN: файл создан вне корня'
    return None


@_replay_kletka('r04-imja-razdelitel')
def r04(pesok):
    p = pesok.vyzov(['zapis', '--imja', 'a/b', '--chto', 'src/selection.json'])
    if p.returncode == 0 or 'IMJA_VNE_ALFAVITA' not in p.stderr:
        return f'RAZDELITEL_PROPUSHCHEN: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r05-run-nechislovoj')
def r05(pesok):
    pesok.zapis('x', 'x')
    p = pesok.vyzov(['zapis', '--imja', 'x', '--chto', 'src/x'], run_id='4242;rm')
    if p.returncode == 0 or 'RUN_KONTSEKST_NECHISLOVYJ' not in p.stderr:
        return f'NECHISLOvoj_PROPUSHCHEN: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r06-nepolnaja-identifikacija')
def r06(pesok):
    p = pesok.vyzov(['chtenie', '--imja', 'x', '--kuda', 'o', '--run-id', '4242'])
    if p.returncode == 0 or 'NEPOLNAJA_IDENTIFIKACIJA_RUNA' not in p.stderr:
        return f'NEPOLNAJA_PROPUSHCHENA: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r07-shablon-sbor')
def r07(pesok):
    pesok.zapis('ekran/vhod/result.json', '{"ok":1}')
    pesok.zapis('ekran/taby/result.json', '{"ok":2}')
    for imja in ('screen-evidence-vhod', 'screen-evidence-taby'):
        p = pesok.vyzov(['zapis', '--imja', imja, '--chto', f'src/ekran/{imja.split("-")[-1]}'])
        if p.returncode != 0:
            return f'ZAPIS_OTKAZ: {imja} rc={p.returncode}'
    p = pesok.vyzov(['chtenie', '--shablon', 'screen-evidence-*', '--kuda', 'sbor'])
    if p.returncode != 0:
        return f'SHABLON_OTKAZ: rc={p.returncode} {p.stderr.strip()}'
    for imja, ozhidanie in (('screen-evidence-vhod', '{"ok":1}'), ('screen-evidence-taby', '{"ok":2}')):
        fakt = pesok.koren / f'sbor/{imja}/result.json'
        if not fakt.is_file() or fakt.read_text(encoding='utf-8') != ozhidanie:
            return f'SHABLON_NE_SOBRAL: {imja}'
    p = pesok.vyzov(['chtenie', '--shablon', 'netu-*', '--kuda', 'sbor2'])
    if p.returncode == 0 or 'SOVPADENIJ_NET' not in p.stderr:
        return f'PUSTOJ_SHABLON_NE_KRASN: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r08-istochnik-otsutstvuet')
def r08(pesok):
    p = pesok.vyzov(['zapis', '--imja', 'prazdno', '--chto', 'src/netu'])
    if p.returncode == 0 or 'ISTOCHNIK_OTSTUTSTVUET' not in p.stderr:
        return f'PUSTOJ_ZAPIS_NE_KRASN: rc={p.returncode} {p.stderr.strip()}'
    return None


@_replay_kletka('r09-izoljacija-popytok')
def r09(pesok):
    pesok.zapis('a', 'popytka-1')
    pesok.zapis('b', 'popytka-2')
    p1 = pesok.vyzov(['zapis', '--imja', 'odno', '--chto', 'src/a'], popytka='1')
    p2 = pesok.vyzov(['zapis', '--imja', 'drugoe', '--chto', 'src/b'], popytka='2')
    if p1.returncode != 0 or p2.returncode != 0:
        return f'ZAPIS_OTKAZ: {p1.returncode}/{p2.returncode}'
    if not (pesok.koren_artefaktov / '4242-1/odno/a').is_file() or \
       not (pesok.koren_artefaktov / '4242-2/drugoe/b').is_file():
        return 'POPYTKI_SLILIS: каталоги попыток не изолированы'
    return None


# ── прогон ──

def sudit(koren_subiekta, orakul):
    subiekt = Subiekt(koren_subiekta)
    if not subiekt.chitaetsja():
        print('SUBJECT_ABSENT: .github/workflows/mobile.yml не читается')
        for id_kletki, fn in KLETKI:
            print(f'CASE {id_kletki} KRASNO: SUBJECT_ABSENT')
        kolichestvo = len(KLETKI)
        print(f'клеток {kolichestvo}, зелёных 0, красных {kolichestvo}')
        return 1
    wf, shagi = razobrat_subiekta(subiekt)
    krasnye = 0
    for id_kletki, fn in KLETKI:
        if id_kletki.startswith('r'):
            prichina = _sudit_replay(fn, subiekt, orakul)
        else:
            prichina = fn(subiekt, wf, shagi, orakul)
        if prichina is None:
            print(f'CASE {id_kletki} ok')
        else:
            print(f'CASE {id_kletki} KRASNO: {prichina}')
            krasnye += 1
    print(f'клеток {len(KLETKI)}, зелёных {len(KLETKI) - krasnye}, красных {krasnye}')
    return 1 if krasnye else 0


def rezhim_stabov(orakul):
    """Честный контроль зелёен ДО мутаций; каждая мутация красна своей причиной."""
    kontrol = sudit(MODEL, orakul)
    if kontrol != 0:
        print('СТАБЫ-ОТКАЗ: честный контроль не зелёен', file=sys.stderr)
        return 2
    # повторный прогон контроля уже напечатал протокол; сводка стабов ниже
    pojmali = 0
    vsego = 0
    for imja_staba, svjazka in sorted(orakul['stab_vhod'].items()):
        vsego += 1
        vremennoe = Path(tempfile.mkdtemp(prefix='stab197-'))
        kopiya = vremennoe / 'model'
        shutil.copytree(MODEL, kopiya)
        try:
            mutator = ZDES / 'stabs' / f'{imja_staba}.py'
            if not mutator.is_file():
                print(f'STAB {imja_staba} PROPUSHCHEN: файла мутатора нет')
                return 1
            protsess = subprocess.run([sys.executable, str(mutator), str(kopiya)],
                                      capture_output=True, text=True)
            if protsess.returncode != 0:
                print(f'STAB {imja_staba} MUTACIJA_SLLOMALAS: {protsess.stderr.strip()}', file=sys.stderr)
                return 2
            vyvod = subprocess.run([sys.executable, str(ZDES / 'probe.py'), '--repo', str(kopiya)],
                                   capture_output=True, text=True)
            kletka = svjazka['kletka']
            prichina = svjazka['prichina']
            stroka = f'CASE {kletka} KRASNO'
            if vyvod.returncode != 1 or stroka not in vyvod.stdout or prichina not in vyvod.stdout:
                print(f'STAB {imja_staba} PROPUSHCHEN: rc={vyvod.returncode}; искали {stroka}: {prichina}')
                print(vyvod.stdout[-2000:], file=sys.stderr)
                return 1
            print(f'STAB {imja_staba} KRASEN: {kletka}: {prichina}')
            pojmali += 1
        finally:
            shutil.rmtree(vremennoe, ignore_errors=True)
    # чистка привязки не прячет мутацию: стаб-файл без записи в stab_vhod красен
    siroty = sorted(p.name for p in (ZDES / 'stabs').glob('*.py')
                    if p.stem not in orakul['stab_vhod'])
    if siroty:
        print('STAB ' + ', '.join(siroty) + ' BEZ_PRIVJAZKI: файл есть, привязки в source.json нет')
        return 1
    print(f'стабов {vsego}, непойманных {vsego - pojmali}')
    return 0 if pojmali == vsego else 1


def main():
    argumenty = sys.argv[1:]
    orakul = zaghruzit_orakul()
    if not argumenty:
        # Без флага субъекта нет: реализация — правка ПРОДУКТА (PR моба),
        # дерево харнесса её не несёт. Все клетки красны поимённо.
        print('SUBJECT_ABSENT: предмет 197 реализуется в продукте Complior-mob')
        for id_kletki, _ in KLETKI:
            print(f'CASE {id_kletki} KRASNO: SUBJECT_ABSENT')
        print(f'клеток {len(KLETKI)}, зелёных 0, красных {len(KLETKI)}')
        return 1
    if argumenty == ['--model']:
        return sudit(MODEL, orakul)
    if argumenty == ['--stabs']:
        return rezhim_stabov(orakul)
    if len(argumenty) == 2 and argumenty[0] == '--repo':
        return sudit(argumenty[1], orakul)
    print('НЕИЗВЕСТНЫЙ_РЕЖИМ: ' + ' '.join(argumenty), file=sys.stderr)
    return 2


if __name__ == '__main__':
    sys.exit(main())
