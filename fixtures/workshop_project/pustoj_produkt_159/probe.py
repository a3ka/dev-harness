#!/usr/bin/env python3
# Батарея контракта 159 «пустой продукт красный» (guard-канал §ПРОВОДКА);
# v4: наблюдение тихих клеток после отказа и проброса rc 2 каждой батареей.
#
# СУБЪЕКТЫ:
#  (1) экранные батареи харнесса в режиме --repo — на каждом БАЗОВОМ
#      входе домена (пять форм слова владельца 2026-11-03) каждая
#      обязана быть КРАСНОЙ (rc != 0, именованная причина), причём
#      общий гейт scripts/check_pustoj_produkt.sh обязан быть ПЕРВЫМ
#      действием --repo-ветви: вызов доказывается ТРАССОЙ гейта (env
#      PUSTOJ_PRODUKT_TRACE; блока Б3 вердикта: строка вывода — не
#      факт вызова), вывод до вызова — объединённым потоком
#      stdout+stderr в ИСТИННОМ порядке записей (один пайп,
#      stderr=STDOUT; конкатенация p.stdout+p.stderr отвергнута
#      вердиктом) и меткой времени прибытия каждой строки против
#      времени записи трассы (одна шкала wall-ns), побочные эффекты —
#      снимком дерева прогона, тихие клетки — Python-наблюдателем вызовов;
#  (2) живой гейт scripts/check_pustoj_produkt.sh (зона implementer;
#      до ленда — клетки SUBJECT_ABSENT): существует, равен эталону
#      rc-кодом и причиной ПОБАЙТОВО на ВСЁМ домене и пишет трассу
#      первым действием.
# Эталон — model/check_pustoj_produkt_159.py, грамматика пустоты —
# ЕДИНЫЙ источник (инвариант 1 контракта); ожидания вычислены в
# ПАМЯТИ проверяющего ДО запуска субъектов (правило 8): карта
# вход→причина — константа OZHIDAEMYE ниже, с диска субъекта не
# перечитывается.
#
# Домен входов (21): базовые пять форм слова владельца (a/b1/b2/v/g) +
# расширенные k1..k6 (типы и записи карты: null-запись, массив, число,
# строка, null, вложенность — блок Б2 вердикта Crit159), f1 (пустой
# идентификатор экрана), c1 (только пустые подкаталоги), c2 (симлинк
# вместо содержимого — Б1 Crit159), c3 (сам mobile/src — симлинк на
# заполненный каталог вне R — Б1 Crit159b), c4/c5 (карта/форма —
# симлинки на действительные значения вне R: не свои узлы), d1/d2/d3
# (ошибки доступа chmod 000: карта/подкаталог src/форма — Б2 Crit159b,
# rc 2 NECHITAEMO) + konformnyj. W-слой судит пять базовых rc-1-входов
# и один rc-2-вход на КАЖДОЙ батарее; модель и гейт — весь домен.
#
# Режимы (argv):
#   (без флага)  судится живое дерево (см. выше; до ленда реализации
#                красны поимённо: SUBJECT_ABSENT / GATE_NE_VYZVAN)
#   --model      эталон гейта + честная проводка на rc 1 и rc 2
#   --stabs      контроль + обманные варианты (stabs/); перечень
#                входов и форма каждого — source.json stab_vhod;
#                привязка варианта к ветви обнаружения — КОДОМ ниже
#                (Н-39: VETKA_PO_FORME + механизм запуска по полю
#                argv), проза контракта перечислений не несёт; гейт
#                для образцов уровня проводки — стенд
#                model/gate_tracer.sh (не зависит от дерева);
#                SVJAZI == числу вариантов
#   --piny-only  (служебный) только проверка пинов носителей
#
# Коды возврата: 0 — зелено; 1 — красная клетка/живой вариант/нет
# субъекта/недостоверный вариант; 2 — ORACLE_TAMPERED, нечем проверять.
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time

ZDE = os.path.dirname(os.path.abspath(__file__))
KOREN = os.path.abspath(os.path.join(ZDE, '..', '..', '..'))
MODEL = os.path.join(ZDE, 'model')
STABY = os.path.join(ZDE, 'stabs')
ETALON = os.path.join(MODEL, 'check_pustoj_produkt_159.py')
GATE_TRACER = os.path.join(MODEL, 'gate_tracer.sh')
CELLS_OBSERVER = os.path.join(MODEL, 'sitecustomize.py')
ZHIVOJ_GATE = os.path.join(KOREN, 'scripts', 'check_pustoj_produkt.sh')

# Закрытый перечень экранных батарей с режимом W --repo (159
# §Существующее): перечислены по grep -l "'--repo'" probe.py экранных
# семей, отбор — ФАКТИЧЕСКИЙ приём флага CLI, измерен на текущем
# дереве (замер Arch159 2026-11-03): 147/148/149/151 принимают;
# ekran_shablon_132, erstinformation_118, first_run_ekran_135,
# mission_116, shablon_dvizhenie_146, start_ekran_138 — упоминание
# --repo только во внутренних argv валидатора/комментариях, их W
# --repo даёт argparse-отказ rc 2 «unrecognized arguments» — вне
# домена W --repo (их предмет — пачки, не живой продукт). Новая
# экранная батарея с --repo без гейта — отдельный предмет.
BATAREI = [
    ('gespraech_otdacha_151', 'red_gespraech_otdacha_151.sh'),
    ('gespraech_tekst_149', 'red_gespraech_tekst_149.sh'),
    ('gespraech_vhod_147', 'red_gespraech_vhod_147.sh'),
    ('vkladki_tabov_148', 'red_vkladki_tabov_148.sh'),
]

KARTA_S_ZAPISJU = {
    "schema": 1,
    "ekrany": [{
        "id": "demo-vkhod", "kontrakty": ["159"], "status": "in-development",
        "job": "e2e-demo-vkhod", "pack": "mobile/e2e-demo-vkhod/",
        "flows": [], "child_flows": [], "puti": ["mobile/e2e-demo-vkhod/"],
        "h_checkout": [], "output_namespace": "ekran-demo-vkhod",
    }],
}
FORMA = {"ekran": "demo-vkhod", "kadry": "kadry.json"}

# Оракул в памяти (правило 8): вход → (rc эталона, причина ДОСЛОВНО).
# Домен v3 (21): базовые формы слова владельца + типы/записи карты
# (k*), пустой идентификатор экрана (f1), пустые контейнеры и симлинки
# вместо содержимого/карты/формы (c*; c3 — Б1 Crit159b: симлинк-КОРЕНЬ
# src), ошибки доступа (d*: chmod 000 → rc 2 NECHITAEMO — Б2 Crit159b)
# — красны КАЖДЫЙ СВОЕЙ причиной, отличимы от konformnyj с файлом.
OZHIDAEMYE = {
    'a-forma-pusta': (1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'),
    'b1-pustoj-katalog': (1, 'PUSTOJ_PRODUKT: KATALOG_PUST'),
    'b2-otsutstvujushchij': (1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'),
    'v-karta-bez-celej': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'g-koren-bez-soderzhimogo': (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'),
    'k1-zapis-null': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'k2-karta-massiv': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'k3-karta-chislo': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'k4-karta-stroka': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'k5-karta-null': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'k6-karta-vlozhennost': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'f1-forma-pustoj-id': (1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'),
    'c1-pustye-katalogi': (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'),
    'c2-vneshnij-simlink': (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'),
    'c3-vneshnij-src-simlink': (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'),
    'c4-karta-simlink': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'c5-forma-simlink': (1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'),
    'd1-karta-nechitaema': (2, 'PUSTOJ_PRODUKT: NECHITAEMO'),
    'd2-src-nechitaem': (2, 'PUSTOJ_PRODUKT: NECHITAEMO'),
    'd3-forma-nechitaema': (2, 'PUSTOJ_PRODUKT: NECHITAEMO'),
    'konformnyj': (0, ''),
}

# W-слой судит базовые пять форм слова владельца (тяжёлые прогоны
# батарей, ~30 с на запуск); типы входа и границы содержательности
# доказаны модельным и гейт-слоями на всём домене.
BAZOVYE = ['a-forma-pusta', 'b1-pustoj-katalog', 'b2-otsutstvujushchij',
           'v-karta-bez-celej', 'g-koren-bez-soderzhimogo']

# Входы с содержательным src (подкаталог с файлом); остальные несут
# ровно изолируемое измерение пустоты.
SODERZHATELNYE = {
    'konformnyj', 'a-forma-pusta', 'v-karta-bez-celej', 'f1-forma-pustoj-id',
    'k1-zapis-null', 'k2-karta-massiv', 'k3-karta-chislo', 'k4-karta-stroka',
    'k5-karta-null', 'k6-karta-vlozhennost', 'c4-karta-simlink',
    'c5-forma-simlink', 'd1-karta-nechitaema', 'd2-src-nechitaem',
    'd3-forma-nechitaema',
}

# Н-39: привязка обманного варианта к ветви обнаружения — ЗДЕСЬ,
# кодом; source.json только называет входы и форму. Ветка — имя,
# которое обязана выдать sudit_provodku (уровень проводки) либо
# rc-расхождение (уровень гейта).
VETKA_PO_FORME = {
    'wiring-ignored-rc': 'BATAREJA_ZELENA_NA_PUSTOM',
    'wiring-no-gate': 'GATE_NE_VYZVAN',
    'wiring-stderr-before-gate': 'VYVOD_DO_GATE',
    'gate-tolko-forma': 'BATAREJA_ZELENA_NA_PUSTOM',
    'gate-karta-pustaja-prohodka': 'BATAREJA_ZELENA_NA_PUSTOM',
    'gate-sleduet-simlinku-src': 'BATAREJA_ZELENA_NA_PUSTOM',
    'wiring-side-effect-before-gate': 'POBOCHNYJ_EFFEKT',
    'wiring-cells-after-refusal': 'KLETKI_POSLE_OTKAZA',
    'wiring-silent-cell': 'KLETKI_POSLE_OTKAZA',
    'wiring-observer-disabled': 'KLETKI_POSLE_OTKAZA',
    'wiring-wrong-rc': 'RC_NE_1',
    'wiring-rc2-to-rc1': 'RC_NE_2',
}
# Обязательная форма трассы у вариантов уровня проводки: сколько
# записей трассы гейта обязан дать вариант на каждом заявленном входе
# (действительный вызов — наблюдаем, не напечатан).
TRASSA_PO_FORME = {
    'wiring-ignored-rc': 1,
    'wiring-stderr-before-gate': 1,
    'wiring-side-effect-before-gate': 1,
    'wiring-cells-after-refusal': 1,
    'wiring-silent-cell': 1,
    'wiring-observer-disabled': 1,
    'wiring-wrong-rc': 1,
    'wiring-rc2-to-rc1': 1,
    'wiring-no-gate': 0,
}

# Б2 Crit159b: ошибка доступа → rc 2 NECHITAEMO. Реальный доступ —
# chmod 000 (uid без DAC override); если chmod не мешает (root),
# батарея поднимает ОБЪЯВЛЕННУЮ эталоном и гейтом симуляцию env
# PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP (точки karta|forma|src) — та же
# точка отказа, что у chmod 000.
DOSTUP_TOCHKA = {
    'd1-karta-nechitaema': 'karta',
    'd2-src-nechitaem': 'src',
    'd3-forma-nechitaema': 'forma',
}
DOSTUP_CEL = {
    'd1-karta-nechitaema': (('mobile', 'ci-screens.json'), False),
    'd2-src-nechitaem': (('mobile', 'src', 'features', 'demo'), True),
    'd3-forma-nechitaema': (('mobile', 'e2e-demo-vkhod', 'ekran.json'),
                            False),
}


def dostup_dejstvitelen(r, vid):
    """True — chmod 000 реально мешает чтению ЭТОМУ uid (не root)."""
    otnositelno, katalog = DOSTUP_CEL[vid]
    cel = os.path.join(r, *otnositelno)
    try:
        if katalog:
            with os.scandir(cel):
                pass
        else:
            with open(cel, 'rb'):
                pass
        return False
    except PermissionError:
        return True
    except OSError:
        return False


def env_dostupa(r, vid):
    """env для прогона d-входа: симуляция только если chmod не мешает."""
    if vid not in DOSTUP_TOCHKA or dostup_dejstvitelen(r, vid):
        return {}
    return {'PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP': DOSTUP_TOCHKA[vid]}


def utechka(n):
    sys.stderr.write('ORACLE_TAMPERED %s\n' % n)
    sys.exit(2)


def sha(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def vedro():
    src = json.load(open(os.path.join(ZDE, 'source.json'),
                         encoding='utf-8'))
    for imja in sorted(src['piny']['nositeli']):
        p = os.path.join(ZDE, imja)
        if not os.path.isfile(p) or sha(p) != src['piny']['sha'][imja]:
            utechka(imja)
    if set(src['staby']) != set(src['stab_vhod']):
        utechka('staby против stab_vhod')
    return src


def postavit(baza, vid):
    """Материализует вход домена в <baza>/R-<vid>; путь продукта.

    Каждый вход изолирует ровно одно измерение: остальные конформны,
    чтобы причина старшинства не маскировала измерение."""
    r = os.path.join(baza, 'R-' + vid)
    if vid == 'b2-otsutstvujushchij':
        return os.path.join(baza, 'NETU-' + vid)  # каталог не создаём
    if vid not in OZHIDAEMYE:
        raise ValueError('неизвестный вход %r' % vid)
    os.makedirs(r)
    if vid == 'b1-pustoj-katalog':
        return r
    md = os.path.join(r, 'mobile')
    karta, forma = KARTA_S_ZAPISJU, FORMA
    karta_simlink_na = forma_simlink_na = None
    if vid == 'a-forma-pusta':
        forma = {}
    elif vid == 'v-karta-bez-celej':
        karta = {"schema": 1, "ekrany": []}
    elif vid == 'k1-zapis-null':
        karta = {"schema": 1, "ekrany": [None]}
    elif vid == 'k2-karta-massiv':
        karta = [{"id": "demo"}]
    elif vid == 'k3-karta-chislo':
        karta = 42
    elif vid == 'k4-karta-stroka':
        karta = "demo"
    elif vid == 'k5-karta-null':
        karta = None
    elif vid == 'k6-karta-vlozhennost':
        karta = {"ekrany": {"id": "demo"}}
    elif vid == 'f1-forma-pustoj-id':
        forma = {"ekran": "", "kadry": "kadry.json"}
    elif vid == 'c1-pustye-katalogi':
        karta = {"schema": 1, "ekrany": [{"id": "demo"}]}
        forma = {"ekran": "demo", "kadry": "kadry.json"}
    elif vid == 'c4-karta-simlink':
        # действительная карта ВНЕ R: узел не свой (Б1 Crit159b)
        karta_simlink_na = os.path.join(baza, 'vne-R-karta.json')
        with open(karta_simlink_na, 'w') as fh:
            json.dump(KARTA_S_ZAPISJU, fh)
    elif vid == 'c5-forma-simlink':
        # действительная форма ВНЕ R: узел не свой (Б1 Crit159b)
        forma_simlink_na = os.path.join(baza, 'vne-R-forma.json')
        with open(forma_simlink_na, 'w') as fh:
            json.dump(FORMA, fh)
    os.makedirs(os.path.join(md, 'e2e-demo-vkhod'))
    if karta_simlink_na:
        os.symlink(karta_simlink_na, os.path.join(md, 'ci-screens.json'))
    else:
        with open(os.path.join(md, 'ci-screens.json'), 'w') as fh:
            json.dump(karta, fh)
    put_formy = os.path.join(md, 'e2e-demo-vkhod', 'ekran.json')
    if forma_simlink_na:
        os.symlink(forma_simlink_na, put_formy)
    else:
        with open(put_formy, 'w') as fh:
            json.dump(forma, fh)
    # Компонентный слой (граница содержательности — инвариант 1г):
    # корневой App.tsx — всегда (контейнер); содержимое — по входу.
    if vid == 'c3-vneshnij-src-simlink':
        # сам mobile/src — симлинк на ЗАПОЛНЕННЫЙ каталог ВНЕ R
        # (образец external-src-symlink вердикта Crit159b: os.walk
        # следует ссылке-КОРНЮ обхода — содержимое вне R не содержимое)
        vne = os.path.join(baza, 'vne-R-src-zapolnennyj')
        os.makedirs(os.path.join(vne, 'features', 'demo'))
        with open(os.path.join(vne, 'App.tsx'), 'w') as fh:
            fh.write("export default function App() { return null; }\n")
        with open(os.path.join(vne, 'features', 'demo', 'Demo.tsx'),
                  'w') as fh:
            fh.write("export function Demo() { return null; }\n")
        os.symlink(vne, os.path.join(md, 'src'))
    else:
        os.makedirs(os.path.join(md, 'src'))
        with open(os.path.join(md, 'src', 'App.tsx'), 'w') as fh:
            fh.write("export default function App() { return null; }\n")
        if vid in SODERZHATELNYE:
            os.makedirs(os.path.join(md, 'src', 'features', 'demo'))
            with open(os.path.join(md, 'src', 'features', 'demo',
                                   'Demo.tsx'), 'w') as fh:
                fh.write("export function Demo() { return null; }\n")
        elif vid == 'c1-pustye-katalogi':
            os.makedirs(os.path.join(md, 'src', 'features'))
        elif vid == 'c2-vneshnij-simlink':
            # цель — пустой каталог ВНЕ R: содержимое «есть», но не
            # принадлежит продукту (структурная пустота по вердикту)
            vne = os.path.join(baza, 'vne-R-pustoj')
            os.makedirs(vne, exist_ok=True)
            os.symlink(vne, os.path.join(md, 'src', 'features'))
    # Ошибки доступа (Б2 Crit159b): chmod 000 реален для uid без
    # DAC override; под root судья поднимает симуляцию env_dostupa
    if vid == 'd1-karta-nechitaema':
        os.chmod(os.path.join(md, 'ci-screens.json'), 0)
    elif vid == 'd2-src-nechitaem':
        os.chmod(os.path.join(md, 'src', 'features', 'demo'), 0)
    elif vid == 'd3-forma-nechitaema':
        os.chmod(put_formy, 0)
    # g-koren-bez-soderzhimogo: только корневой App.tsx
    return r


def snimok(r, iskljuchit=frozenset()):
    """Инвентарь дерева r: relpath → ('katalog',)|('simlink',cel)|
    ('fail',размер,rezhim,sha256); rezhim — режим доступа (младшие
    12 бит): подмена прав — тоже побочный эффект. Симлинки — как
    симлинки (содержимое не читается и не пересчитывается).
    Абсолютные пути из iskljuchit не учитываются: это файл трассы,
    который пишет сам гейт (единственное дозволенное изменение)."""
    inv = {}
    if not os.path.isdir(r):
        return inv
    for koren, katalogi, fajly in os.walk(r, followlinks=False):
        for imja in katalogi + fajly:
            p = os.path.join(koren, imja)
            if os.path.abspath(p) in iskljuchit:
                continue
            rel = os.path.relpath(p, r)
            if os.path.islink(p):
                inv[rel] = ('simlink', os.readlink(p))
            elif os.path.isdir(p):
                inv[rel] = ('katalog',)
            elif os.path.isfile(p):
                with open(p, 'rb') as fh:
                    inv[rel] = ('fail', os.path.getsize(p),
                                oct(os.stat(p).st_mode & 0o7777),
                                hashlib.sha256(fh.read()).hexdigest())
    return inv


def ubrat(baza):
    """Стирает baza; сначала возвращает доступ chmod-000 каталогам
    d-входов — иначе rmtree не войдёт в каталог без прав (режим
    выставляется сверху вниз, до спуска walk)."""
    for koren, katalogi, _fajly in os.walk(baza):
        for imja in katalogi:
            p = os.path.join(koren, imja)
            if not os.path.islink(p):
                try:
                    os.chmod(p, 0o700)
                except OSError:
                    pass
    shutil.rmtree(baza, ignore_errors=True)


def zapusk_obedinennyj(cmd, env, cwd=None, timeout=60):
    """(rc|'VREMJA_ISTEKLO', [(ts_ns, stroka), ...]) — stdout и stderr
    субъекта в ОДНОМ пайпе (stderr=STDOUT): порядок строк — истинный
    порядок записей, конкатенация потоков не используется. Метка
    времени прибытия каждой строки — time.time_ns() (wall-ns, та же
    шкала, что у строки трассы гейта)."""
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True,
                            env=env, cwd=cwd)
    stroki = []

    def _chitatel():
        try:
            for line in proc.stdout:
                stroki.append((time.time_ns(), line.rstrip('\n')))
        except (OSError, ValueError):
            pass

    nit = threading.Thread(target=_chitatel, daemon=True)
    nit.start()
    try:
        rc = proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
        nit.join(5)
        return 'VREMJA_ISTEKLO', stroki
    nit.join(5)
    try:
        proc.stdout.close()
    except OSError:
        pass
    return rc, stroki


def chita_trassu(put):
    """Строки трассы гейта; пусто — если файла нет."""
    if not os.path.isfile(put):
        return []
    with open(put, encoding='utf-8') as fh:
        return [l.rstrip('\n') for l in fh if l.strip()]


def sudit_provodku(sest_cmd, vid, baza):
    """Judge one --repo branch with the gate's trace and an independent cell observer."""
    r = postavit(baza, vid)
    # The observer must read the fixture to compare before/after. Unlike the
    # direct gate cells, wiring uses the declared simulated access error.
    if vid in DOSTUP_CEL:
        segments, directory = DOSTUP_CEL[vid]
        os.chmod(os.path.join(r, *segments), 0o700 if directory else 0o600)
    ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
    trassa = os.path.join(baza, 'trassa-gate-%s.log' % vid)
    kletki = os.path.join(baza, 'trassa-kletok-%s.log' % vid)
    do = snimok(baza, iskljuchit={trassa, kletki})
    cmd = sest_cmd(r)
    # bash red_*.sh launches probe.py; Python stabs launch themselves.
    subject = (os.path.join(os.path.dirname(cmd[1]), 'probe.py')
               if cmd[0] == 'bash' else cmd[1])
    env = dict(os.environ)
    if vid in DOSTUP_TOCHKA:
        env['PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP'] = DOSTUP_TOCHKA[vid]
    env['PYTHONUNBUFFERED'] = '1'
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    env['PUSTOJ_PRODUKT_TRACE'] = trassa
    env['PUSTOJ_PRODUKT_CELLS_TRACE'] = kletki
    env['PUSTOJ_PRODUKT_CELLS_SUBJECT'] = subject
    env['PYTHONPATH'] = MODEL + os.pathsep + env.get('PYTHONPATH', '')
    rc, stroki = zapusk_obedinennyj(cmd, env, cwd=KOREN)
    linii = chita_trassu(trassa)
    if rc == 'VREMJA_ISTEKLO':
        return 'VREMJA_ISTEKLO', 'субъект завис', len(linii)
    if rc == 0:
        return ('BATAREJA_ZELENA_NA_PUSTOM',
                'первая=%r' % (stroki[0][1] if stroki else ''), len(linii))
    # Preserve the existing 151 infrastructure red on the original rc-1 inputs.
    if rc == 2 and ozh_rc == 1:
        return 'SUBEKT_RC2', 'rc=2 (fail-closed — не зелень)', len(linii)
    nashi = [l for l in linii if l.endswith(' GATE ' + r)]
    if len(linii) != 1 or len(nashi) != 1:
        return ('GATE_NE_VYZVAN',
                'записей трассы %d (ожидалась одна с этим R)' % len(linii),
                len(linii))
    try:
        ts_gejta = int(nashi[0].split(' GATE ')[0])
    except ValueError:
        return 'GATE_NE_VYZVAN', 'трасса не по грамматике', len(linii)
    if snimok(baza, iskljuchit={trassa, kletki}) != do:
        return ('POBOCHNYJ_EFFEKT',
                'дерево прогона (baza) изменилось за время прогона',
                len(linii))
    rannie = [s for ts, s in stroki if ts < ts_gejta]
    if rannie:
        return ('VYVOD_DO_GATE',
                'до вызова гейта выведено %r' % rannie[0][:60], len(linii))
    pervaja = stroki[0][1] if stroki else ''
    if pervaja != ozh_prichina:
        return ('GATE_NE_PERVYM_DEISTVIEM',
                'первая=%r ожидалась %r' % (pervaja, ozh_prichina),
                len(linii))
    if len(stroki) != 1:
        return ('KLETKI_POSLE_OTKAZA',
                'после причины гейта выведено ещё %d строк(и), первая %r'
                % (len(stroki) - 1, stroki[1][1][:60]), len(linii))
    if os.path.isfile(kletki):
        with open(kletki, encoding='utf-8') as fh:
            calls = fh.read().splitlines()
        if calls:
            return ('KLETKI_POSLE_OTKAZA',
                    'после отказа вызвана собственная клетка %s'
                    % calls[0], len(linii))
    if rc != ozh_rc:
        return ('RC_NE_%d' % ozh_rc,
                'rc=%d: ожидался rc=%d гейта' % (rc, ozh_rc), len(linii))
    return 'OK', ozh_prichina, len(linii)


def zapusk_subekta(skript, vid, baza):
    """(rc, stdout+stderr) — прямой прогон субъекта на СВЕЖЕЙ копии
    входа (уровень гейта: типы входа, расхождения rc); на d-входах —
    реальный chmod 000, а под uid, которому он не мешает, объявленная
    симуляция доступа PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP."""
    r = postavit(baza, vid)
    p = subprocess.run([sys.executable, skript, r],
                       capture_output=True, text=True, timeout=60,
                       env=dict(os.environ, **env_dostupa(r, vid)))
    return p.returncode, p.stdout + p.stderr


def kontrol_modeli(baza):
    """Контроль входов и эталона: клетки ПО ВСЕМ входам домена."""
    kletki = []
    for vid in sorted(OZHIDAEMYE):
        try:
            rc, vyp = zapusk_subekta(ETALON, vid, baza)
        except subprocess.TimeoutExpired:
            kletki.append(('m-' + vid, False,
                           'эталон завис на входе %s' % vid))
            continue
        ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
        stroka = (vyp.strip().splitlines() or [''])[0]
        ok = rc == ozh_rc and stroka == ozh_prichina
        kletki.append(('m-' + vid, ok,
                       '' if ok else
                       'rc=%d строка=%r, ожидалось rc=%d %r'
                       % (rc, stroka, ozh_rc, ozh_prichina)))
    return kletki

def kontrol_provodki():
    """Honest early exit must pass on both refusal codes, not only rc 1."""
    kletki = []
    for vid in ('a-forma-pusta', 'd1-karta-nechitaema'):
        baza = tempfile.mkdtemp(prefix='pustoj159-honest-')
        try:
            def sest(r):
                return [sys.executable, os.path.join(MODEL, 'wiring_honest.py'),
                        GATE_TRACER, r]
            vetka, pochemu, _ = sudit_provodku(sest, vid, baza)
            kletki.append(('m-provodka-' + vid, vetka == 'OK',
                           '' if vetka == 'OK' else vetka + ' ' + pochemu))
        finally:
            ubrat(baza)
    return kletki


def pechat_i_itog(itogi, rezhim, svjazi=None, skolko_stabov=None):
    zelen = sum(1 for _, ok, _ in itogi if ok)
    krasn = len(itogi) - zelen
    for idk, ok, pochemu in itogi:
        print('CASE %s %s %s' % (idk, 'ok' if ok else 'KRASNO', pochemu))
    print('клеток %d, зелёных %d, красных %d; режим %s'
          % (len(itogi), zelen, krasn, rezhim))
    if krasn:
        return 1
    if svjazi is not None and svjazi != skolko_stabov:
        return 1
    return 0


def sudit_staba(stab, svaz):
    """Судит один обманный вариант; печатает поимки, возвращает
    (kletka_ok, pochemu). Привязка к ветви — по форме (Н-39)."""
    idk = 'v-' + stab
    put = os.path.join(ZDE, svaz['put'] if 'put' in svaz else
                       os.path.join('stabs', stab))
    forma = svaz['forma']
    vhody = list(svaz['vhody'])
    if forma not in VETKA_PO_FORME:
        utechka('неизвестная форма %r у %s' % (forma, stab))
    for v in vhody:
        if v not in OZHIDAEMYE or v == 'konformnyj':
            utechka('stab_vhod %s вход %s' % (stab, v))
    nuzhnaja = VETKA_PO_FORME[forma]
    baza = tempfile.mkdtemp(prefix='pustoj159-stab-')
    try:
        if svaz.get('argv') == 'gate R':
            def sest(r, put=put):
                return [sys.executable, put, GATE_TRACER, r]
        else:
            def sest(r, put=put):
                return [sys.executable, put, r]
        # демаркация: на konformnyj — как честный состав (rc 0)
        r_k = postavit(baza, 'konformnyj')
        p = subprocess.run(sest(r_k), capture_output=True, text=True,
                           timeout=60)
        if p.returncode != 0:
            return (False, 'ЛОЖНЫЙ ОТКАЗ на konformnyj rc=%d %s'
                    % (p.returncode, (p.stdout + p.stderr).strip()[:80]))
        if forma.startswith('wiring'):
            # уровень проводки: тот же суд, что и живые батареи;
            # действительность вызова — наблюдаемой трассой
            nado_trass = TRASSA_PO_FORME[forma]
            rezultaty = []
            for vid in vhody:
                vetka, pochemu, trass = sudit_provodku(sest, vid, baza)
                rezultaty.append((vid, vetka, pochemu, trass))
            ne_tak_trassoj = ['%s(%d)' % (v, t)
                              for v, _, _, t in rezultaty
                              if t != nado_trass]
            if ne_tak_trassoj:
                return (False, 'ТРАССА НЕ ПО ФОРМЕ (нужно %d): %s'
                        % (nado_trass, ', '.join(ne_tak_trassoj)))
            sovpalo = [v for v, vetka, _, _ in rezultaty
                       if vetka == nuzhnaja]
            for v in sovpalo:
                print('STAB %s POJMAN vetka=%s na %s' % (stab, nuzhnaja, v))
            if len(sovpalo) == len(vhody):
                return True, ''
            ne_sovpalo = ['%s→%s' % (v, vetka)
                          for v, vetka, _, _ in rezultaty
                          if vetka != nuzhnaja]
            return (False, 'ПРИВЯЗКА НЕ СОВПАЛА: %s' % ', '.join(ne_sovpalo))
        # уровень гейта: прямой прогон, ветка — зелень на пустом
        pojmalo = 0
        for vid in vhody:
            rc, _vyp = zapusk_subekta(put, vid, baza)
            ozh_rc, _p = OZHIDAEMYE[vid]
            if ozh_rc != 0 and rc == 0:
                pojmalo += 1
                print('STAB %s POJMAN vetka=%s na %s'
                      % (stab, nuzhnaja, vid))
        if pojmalo == len(vhody):
            return True, ''
        return (False, 'НЕДОСТОВЕРНЫЙ ВАРИАНТ: зелён не на всех '
                'заявленных входах (%d/%d)' % (pojmalo, len(vhody)))
    finally:
        ubrat(baza)


def main():
    argv = sys.argv[1:]
    rezhim = ('stabs' if '--stabs' in argv else
              'model' if '--model' in argv else
              'piny' if '--piny-only' in argv else 'derevo')
    for dop in ('--repo', '--seed'):
        if dop in argv:
            sys.stderr.write('нет режима %s у этой батареи\n' % dop)
            return 2
    src = vedro()
    if rezhim == 'piny':
        print('PINY ok')
        return 0
    if not os.path.isfile(ETALON):
        sys.stderr.write('NOT_IMPLEMENTED: нет python3-эталона\n')
        return 2

    itogi = []
    if rezhim in ('model', 'stabs'):
        baza = tempfile.mkdtemp(prefix='pustoj159-model-')
        try:
            itogi.extend(kontrol_modeli(baza))
            itogi.extend(kontrol_provodki())
        finally:
            ubrat(baza)

    if rezhim == 'stabs':
        # Ожидания эталона — УЖЕ в памяти (OZHIDAEMYE), вычислены до
        # субъектов; диск вариантов истиной не перечитывается.
        svjazi = 0
        for stab, svaz in sorted(src['stab_vhod'].items()):
            ok, pochemu = sudit_staba(stab, svaz)
            if ok:
                svjazi += 1
            else:
                itogi.append(('v-' + stab, ok, pochemu))
        print('SVJAZI %d' % svjazi)
        return pechat_i_itog(itogi, rezhim,
                             svjazi=svjazi,
                             skolko_stabov=len(src['stab_vhod']))

    if rezhim == 'derevo':
        # (1) живой гейт: существует, равен эталону на всём домене,
        # пишет трассу первым действием
        if not os.path.isfile(ZHIVOJ_GATE):
            itogi.append(('s-gate-v-dereve', False,
                          'SUBJECT_ABSENT scripts/check_pustoj_produkt.sh'))
            itogi.append(('s-gate-raven-etalonu', False,
                          'SUBJECT_ABSENT гейт не судится'))
            itogi.append(('s-gate-pishet-trassu', False,
                          'SUBJECT_ABSENT гейт не судится'))
        else:
            itogi.append(('s-gate-v-dereve', True, ''))
            baza = tempfile.mkdtemp(prefix='pustoj159-gate-')
            try:
                for vid in sorted(OZHIDAEMYE):
                    r = postavit(baza, vid)
                    p = subprocess.run(['bash', ZHIVOJ_GATE, r],
                                       capture_output=True, text=True,
                                       timeout=60,
                                       env=dict(os.environ,
                                                **env_dostupa(r, vid)))
                    ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
                    stroka = ((p.stdout.strip().splitlines()
                               or [''])[0])
                    ok = (p.returncode == ozh_rc
                          and stroka == ozh_prichina)
                    itogi.append(('s-gate-raven-etalonu/' + vid, ok,
                                  '' if ok else
                                  'rc=%d строка=%r, эталон rc=%d %r'
                                  % (p.returncode, stroka, ozh_rc,
                                     ozh_prichina)))
            finally:
                ubrat(baza)
            baza_t = tempfile.mkdtemp(prefix='pustoj159-trace-')
            try:
                # трасса: гейт пишет её ПЕРВЫМ действием (инвариант 3)
                vid_t = 'b1-pustoj-katalog'
                r_t = postavit(baza_t, vid_t)
                tr = os.path.join(baza_t, 'tr.log')
                env_t = dict(os.environ, PUSTOJ_PRODUKT_TRACE=tr)
                p = subprocess.run(['bash', ZHIVOJ_GATE, r_t],
                                   capture_output=True, text=True,
                                   timeout=60, env=env_t)
                linii = chita_trassu(tr)
                ozh_rc, ozh_prichina = OZHIDAEMYE[vid_t]
                stroka = (p.stdout.strip().splitlines() or [''])[0]
                ok = (p.returncode == ozh_rc and stroka == ozh_prichina
                      and len(linii) == 1
                      and linii[0].endswith(' GATE ' + r_t))
                itogi.append(('s-gate-pishet-trassu', ok,
                              '' if ok else
                              'rc=%d трасса=%d строка=%r'
                              % (p.returncode, len(linii), stroka)))
            finally:
                ubrat(baza_t)
        # (2) батареи: гейт — ПЕРВОЕ действие --repo-ветви на каждом
        # базовом пустом входе (трасса вызова, порядок объединённого
        # потока, снимок продукта, rc)
        # A separate access-error cell per battery checks rc 2 propagation.
        for zona, red in BATAREI:
            put_red = os.path.join(KOREN, 'fixtures', 'workshop_project',
                                   zona, red)
            for vid in BAZOVYE + ['d1-karta-nechitaema']:
                baza = tempfile.mkdtemp(prefix='pustoj159-W-')
                try:
                    def sest(r, put_red=put_red):
                        return ['bash', put_red, '--repo', r]
                    vetka, pochemu, _t = sudit_provodku(sest, vid, baza)
                finally:
                    ubrat(baza)
                idk = 'W-%s/%s' % (zona, vid)
                itogi.append((idk, vetka == 'OK',
                              '' if vetka == 'OK' else
                              '%s %s' % (vetka, pochemu)))

    return pechat_i_itog(itogi, rezhim)


if __name__ == '__main__':
    sys.exit(main())
