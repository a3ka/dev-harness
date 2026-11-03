#!/usr/bin/env python3
# Батарея контракта 159 «пустой продукт красный» (guard-канал
# §ПРОВОДКА), v2 — правка по вердикту Crit159 v1 (четыре блока).
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
#      снимком дерева продукта до/после;
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
# Домен входов (15): базовые пять форм слова владельца (a/b1/b2/v/g) +
# расширенные k1..k6 (типы и записи карты: null-запись, массив, число,
# строка, null, вложенность — блок Б2 вердикта), f1 (пустой
# идентификатор экрана), c1 (только пустые подкаталоги), c2 (симлинк
# вместо содержимого — блок Б1 вердикта) + konformnyj. Слои: W-слой
# судит БАЗОВЫЕ входы (тяжёлые прогоны батарей), модельный и
# гейт-слои — весь домен.
#
# Режимы (argv):
#   (без флага)  судится живое дерево (см. выше; до ленда реализации
#                красны поимённо: SUBJECT_ABSENT / GATE_NE_VYZVAN)
#   --model      субъект = эталон гейта (контроль входов и эталона)
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
# Домен v2 (15): базовые формы слова владельца + типы/записи карты
# (k*), пустой идентификатор экрана (f1), пустые контейнеры и симлинк
# вместо содержимого (c*) — красны КАЖДЫЙ СВОЕЙ причиной, отличимы от
# konformnyj с исходным файлом.
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
    'k5-karta-null', 'k6-karta-vlozhennost',
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
}
# Обязательная форма трассы у вариантов уровня проводки: сколько
# записей трассы гейта обязан дать вариант на каждом заявленном входе
# (действительный вызов — наблюдаем, не напечатан).
TRASSA_PO_FORME = {
    'wiring-ignored-rc': 1,
    'wiring-stderr-before-gate': 1,
    'wiring-no-gate': 0,
}


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
    os.makedirs(os.path.join(md, 'e2e-demo-vkhod'))
    with open(os.path.join(md, 'ci-screens.json'), 'w') as fh:
        json.dump(karta, fh)
    with open(os.path.join(md, 'e2e-demo-vkhod', 'ekran.json'), 'w') as fh:
        json.dump(forma, fh)
    # Компонентный слой (граница содержательности — инвариант 1г):
    # корневой App.tsx — всегда (контейнер); содержимое — по входу.
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
    # g-koren-bez-soderzhimogo: только корневой App.tsx
    return r


def snimok(r):
    """Инвентарь дерева R: relpath → ('katalog',)|('simlink',cel')|
    ('fail',размер,sha256). Симлинки — как симлинки (содержимое не
    читается и не пересчитывается)."""
    inv = {}
    if not os.path.isdir(r):
        return inv
    for koren, katalogi, fajly in os.walk(r, followlinks=False):
        for imja in katalogi + fajly:
            p = os.path.join(koren, imja)
            rel = os.path.relpath(p, r)
            if os.path.islink(p):
                inv[rel] = ('simlink', os.readlink(p))
            elif os.path.isdir(p):
                inv[rel] = ('katalog',)
            elif os.path.isfile(p):
                with open(p, 'rb') as fh:
                    inv[rel] = ('fail', os.path.getsize(p),
                                hashlib.sha256(fh.read()).hexdigest())
    return inv


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
    """Судит уровень проводки на входе vid. Возвращает (ветка, почему,
    записей_трассы). Ветки, в порядке проверки (порядок — часть
    привязки Н-39): VREMJA_ISTEKLO; BATAREJA_ZELENA_NA_PUSTOM (rc 0);
    SUBEKT_RC2 (субъект вышел rc 2 — fail-closed, не зелень: до
    проводки это собственный INFRASTRUCTURE батареи 151, после
    проводки — rc 2 гейта, проброшенный ветвью); GATE_NE_VYZVAN
    (трассы нет/не одна/чужая);
    POBOCHNYJ_EFFEKT (дерево продукта изменилось); VYVOD_DO_GATE
    (строка прибыла раньше записи трассы); GATE_NE_PERVYM_DEISTVIEM
    (первая строка не причина); OK."""
    r = postavit(baza, vid)
    ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
    do = snimok(r)
    trassa = os.path.join(baza, 'trassa-gate-%s.log' % vid)
    env = dict(os.environ)
    env['PYTHONUNBUFFERED'] = '1'
    env['PUSTOJ_PRODUKT_TRACE'] = trassa
    rc, stroki = zapusk_obedinennyj(sest_cmd(r), env, cwd=KOREN)
    linii = chita_trassu(trassa)
    if rc == 'VREMJA_ISTEKLO':
        return 'VREMJA_ISTEKLO', 'субъект завис', len(linii)
    if rc == 0:
        return ('BATAREJA_ZELENA_NA_PUSTOM',
                'первая=%r' % (stroki[0][1] if stroki else ''), len(linii))
    if rc == 2:
        return ('SUBEKT_RC2', 'rc=2 (fail-closed — не зелень)',
                len(linii))
    nashi = [l for l in linii if l.endswith(' GATE ' + r)]
    if len(linii) != 1 or len(nashi) != 1:
        return ('GATE_NE_VYZVAN',
                'записей трассы %d (ожидалась одна с этим R)' % len(linii),
                len(linii))
    try:
        ts_gejta = int(nashi[0].split(' GATE ')[0])
    except ValueError:
        return 'GATE_NE_VYZVAN', 'трасса не по грамматике', len(linii)
    if snimok(r) != do:
        return ('POBOCHNYJ_EFFEKT',
                'дерево продукта изменилось за время прогона', len(linii))
    rannie = [s for ts, s in stroki if ts < ts_gejta]
    if rannie:
        return ('VYVOD_DO_GATE',
                'до вызова гейта выведено %r' % rannie[0][:60], len(linii))
    pervaja = stroki[0][1] if stroki else ''
    if pervaja != ozh_prichina:
        return ('GATE_NE_PERVYM_DEISTVIEM',
                'первая=%r ожидалась %r' % (pervaja, ozh_prichina),
                len(linii))
    return 'OK', ozh_prichina, len(linii)


def zapusk_subekta(skript, vid, baza):
    """(rc, stdout+stderr) — прямой прогон субъекта на СВЕЖЕЙ копии
    входа (уровень гейта: типы входа, расхождения rc)."""
    r = postavit(baza, vid)
    p = subprocess.run([sys.executable, skript, r],
                       capture_output=True, text=True, timeout=60)
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
            if ozh_rc == 1 and rc == 0:
                pojmalo += 1
                print('STAB %s POJMAN vetka=%s na %s'
                      % (stab, nuzhnaja, vid))
        if pojmalo == len(vhody):
            return True, ''
        return (False, 'НЕДОСТОВЕРНЫЙ ВАРИАНТ: зелён не на всех '
                'заявленных входах (%d/%d)' % (pojmalo, len(vhody)))
    finally:
        shutil.rmtree(baza, ignore_errors=True)


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
        finally:
            shutil.rmtree(baza, ignore_errors=True)

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
                                       timeout=60)
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
                shutil.rmtree(baza, ignore_errors=True)
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
                shutil.rmtree(baza_t, ignore_errors=True)
        # (2) батареи: гейт — ПЕРВОЕ действие --repo-ветви на каждом
        # базовом пустом входе (трасса вызова, порядок объединённого
        # потока, снимок продукта, rc)
        for zona, red in BATAREI:
            put_red = os.path.join(KOREN, 'fixtures', 'workshop_project',
                                   zona, red)
            for vid in BAZOVYE:
                baza = tempfile.mkdtemp(prefix='pustoj159-W-')
                try:
                    def sest(r, put_red=put_red):
                        return ['bash', put_red, '--repo', r]
                    vetka, pochemu, _t = sudit_provodku(sest, vid, baza)
                finally:
                    shutil.rmtree(baza, ignore_errors=True)
                idk = 'W-%s/%s' % (zona, vid)
                itogi.append((idk, vetka == 'OK',
                              '' if vetka == 'OK' else
                              '%s %s' % (vetka, pochemu)))

    return pechat_i_itog(itogi, rezhim)


if __name__ == '__main__':
    sys.exit(main())
