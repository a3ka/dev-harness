#!/usr/bin/env python3
"""Батарея набора ekrannyj_nabor_158 (контракт 158) — раннер клеток.

Режимы (SPEC.md §1):
  (без флага)         суд дерева харнеса: семьи A (трек-механика, toy-миры),
                      B (двойник e2e-канона AVD), C (линт токенов),
                      D (домен/оракул), E (самоописание), G (регрессии);
                      живая семья F и слежение c05 НЕ строятся: для них
                      нужен явный `--repo <R>`; отсутствие R в безфлаговом
                      режиме не является неисправностью продукта (SPEC §1).
  --model             субъект = эталон (model/check_trek_ekrana_158.py) и
                      эталонные носители; клетки с ВНЕШНИМ субъектом (живые
                      референсы, гейт 159) в этом режиме не строятся.
  --stabs             контроль модели зелёный + каждый стаб отклонён на СВОИХ
                      входах (source.json.stab_vhod); итог SVJAZI N.
  --repo R            живой суд: гейт 159 первым (И-8), затем зонд на R по
                      картам набора и синтетический экран.
  --repo R --ekran N  совместный режим (И-7): гейт 159, членство и ТРЕК по
                      контракту N, ядро — зонд на R по карте ФАЙЛА пачки N.
  --ekran N           экранный режим: членство, ТРЕК, ядро, слой. Источник
                      контракта и пачки — ОБЪЯВЛЕННЫЙ маршрут: переменная
                      NABOR_158_TOY_ROOT (внутренний путь клеток) либо корень
                      дерева харнеса; скрытый toy-мир НЕ подставляется —
                      несуществующий экран даёт именованный отказ rc 2, а
                      не зелень.
  --oracle-tamper     порча оракула: rc 2 ORACLE_TAMPERED до клеток.

Незаявленный флаг → отказ argparse rc 2 (SPEC §1). Служебных флагов нет:
подмножество клеток — внутренний вызов, сверка пинов — в оракуле.

Коды возврата: 0 — зелено; 1 — красная клетка или живой стаб; 2 — оракул
порчен, нечем проверить, отказ сочетания.

ПРАВИЛО 8 (истина в памяти проверяющего): оракул читается ОДИН раз до
какого-либо субъекта; ожидания клеток — из source.json (kejsy), пины
носителей проверяются до первого запуска.
"""
import argparse
import hashlib
import importlib.util
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import tempfile

ZDE = os.path.dirname(os.path.abspath(__file__))
KOREN = os.path.abspath(os.path.join(ZDE, '..', '..', '..'))
MODEL = os.path.join(ZDE, 'model')
NOS = os.path.join(ZDE, 'nositeli')
TEKSTY = os.path.join(ZDE, 'teksty')
ZOND = os.path.join(ZDE, 'zond')
STABY = os.path.join(ZDE, 'stubs')
SAMO = os.path.join(ZDE, 'samoopisanie')
SKRIPTY = os.path.join(KOREN, 'scripts')

TREK_LEGKIJ = 'ЛЁГКИЙ'
TREK_POLNYJ = 'ПОЛНЫЙ'
PROFILI = ('390', '393')

# ── Имена причин (SPEC §6; имена — дословно) ───────────────────────────
P_TREK_DUBL = 'TREK_DUBL'
P_TREK_GRAMM = 'TREK_NE_PO_GRAMMATIKE'
P_RISKA = 'EKRAN_RISKA_LEGKIJ'
P_SLOJ_NE_ISPOLNEN = 'TREK_SLOJ_NE_ISPOLNEN'
P_SLOJ_KRASNO = 'POLNYJ_TREK_KRASNO'
P_NE_EKRAN = 'NE_EKRAN_NABORA'
P_SUBJECT_ABSENT = 'SUBJECT_ABSENT'
P_LIVE = 'LIVE_PREDPOSYLKA'
P_NOT_IMPL = 'NOT_IMPLEMENTED'
P_ORACLE = 'ORACLE_TAMPERED'
P_PUSTOJ = 'PUSTOJ_PRODUKT'
P_KARTA_NE_POLNA = 'KARTA_NE_POLNA'
P_KARTA_NET = 'KARTA_EKRANA_NET'
P_ZOND_NE_ZAPUSHCHEN = 'ZOND_NA_R_NE_ZAPUSHCHEN'
P_TSEL_VYKLYUCHENA = 'TSEL_VYKLYUCHENA'
P_TSEL_NEVIDIMA = 'TSEL_NEVIDIMA'
P_NADPIS_NEVIDIMA = 'NADPIS_NEVIDIMA'
P_ZONA = 'ZONA_MENSHE_NORMY'
P_DEJSTVIE_CHUZHOE = 'DEJSTVIE_CHUZHOE'
P_DEJSTVIE_NET_PROFILE = 'DEJSTVIE_NA_PROFILE_NET'
P_TSEL_OTSUTSTVUET = 'TSEL_OTSVTSTVUET'
P_SOSTOJANIE_NEDOSTIZHIMO = 'SOSTOJANIE_NEDOSTIZHIMO'
P_SOSTOJANIE_SLITO = 'SOSTOJANIE_SLITO'
P_LITERAL = 'LITERAL_VMEStO_TOKENA'
P_TOKEN_SLEDUET = 'TOKEN_SLEDUET'
P_TOKEN_NE_SLEDUET = 'TOKEN_NE_SLEDUET'
P_PODTVERZHDENIE = 'PODTVERZHDENIE_OSTANOVKI_NET'
P_PORT_ZANJAT = 'PORT_ZANJAT'
P_SLISHKOM_AVD = 'SLISHKOM_MNOGO_AVD'
P_MASKA_36 = 'MASKA_36_NE_48'
P_KANON_PINY = 'KANON_PINY_NESOVPALI'
P_MUTANT_PROSHYOL = 'MUTANT_PROSHYOL'
P_STAB_ZHIV = 'STAB_ZHIV'
P_INFRA = 'ISPOLNIMYJ_INFRA'
P_YADRO_KRASNO = 'YADRO_KRASNO'
P_ORACLE_NE_SOVPAL = 'ORACLE_NE_SOVPAL'
P_LINT_KONTROL = 'LINT_KONTROL_KRASEN'
P_NE_SOVPAL = 'NE_SOVPAL_S_SUBJEKTOM'

VSE_PRICHINY = [
    P_TREK_DUBL, P_TREK_GRAMM, P_RISKA, P_SLOJ_NE_ISPOLNEN, P_SLOJ_KRASNO,
    P_NE_EKRAN, P_SUBJECT_ABSENT, P_LIVE, P_NOT_IMPL, P_ORACLE, P_PUSTOJ,
    P_KARTA_NE_POLNA, P_KARTA_NET, P_ZOND_NE_ZAPUSHCHEN, P_TSEL_VYKLYUCHENA,
    P_TSEL_NEVIDIMA, P_NADPIS_NEVIDIMA, P_ZONA, P_DEJSTVIE_CHUZHOE,
    P_DEJSTVIE_NET_PROFILE, P_TSEL_OTSUTSTVUET, P_SOSTOJANIE_NEDOSTIZHIMO,
    P_SOSTOJANIE_SLITO, P_LITERAL, P_TOKEN_SLEDUET, P_TOKEN_NE_SLEDUET,
    P_PODTVERZHDENIE, P_PORT_ZANJAT, P_SLISHKOM_AVD, P_MASKA_36,
    P_KANON_PINY, P_MUTANT_PROSHYOL, P_STAB_ZHIV, P_INFRA,
    P_YADRO_KRASNO, P_ORACLE_NE_SOVPAL, P_LINT_KONTROL, P_NE_SOVPAL,
]

# ── Референсы станции (живые входы семьи F) ───────────────────────────
REFERENSI = [
    ('ref-clean', '/tmp/dev-harness-verify/Arch147t/ref-clean',
     'model/karta-ref-clean.json'),
    ('mob-ref', '/tmp/dev-harness-verify/Arch148t/mob-ref',
     'model/karta-mob-ref.json'),
]

# ── Toy-мир экранов (генерируется батареёй; тексты — ДО вызова) ───────
TOY = {
    190: {'imya': '190-ekran-obychnyj.md', 'risk': 'обычный',
          'marker_v_priemke': True, 'trek': None,
          'opisanie': 'обычный экран набора (трек по умолчанию — ЛЁГКИЙ)'},
    191: {'imya': '191-ekran-riska.md', 'risk': 'рисковый (деньги)',
          'marker_v_priemke': True, 'trek': None,
          'opisanie': 'рисковый экран набора (деньги)'},
    192: {'imya': '192-sosed-ne-ekran.md', 'risk': 'рисковый (деньги)',
          'marker_v_priemke': False, 'trek': None,
          'opisanie': 'контракт НЕ экран набора: маркер только в КОНТЕКСТЕ'},
    193: {'imya': '193-ekran-priemka.md', 'risk': 'обычный',
          'marker_v_priemke': True, 'trek': None,
          'opisanie': 'обычный экран набора с маркером в приёмке'},
    194: {'imya': '194-ekran-krasnyj-sloj.md', 'risk': 'обычный',
          'marker_v_priemke': True, 'trek': TREK_POLNYJ,
          'opisanie': 'обычный экран набора с полным треком (слой с красной '
                      'командой)'},
    195: {'imya': '195-ekran-legkij-s-kartoj.md', 'risk': 'обычный',
          'marker_v_priemke': True, 'trek': None,
          'opisanie': 'обычный экран набора с картой целей (ЛЁГКИЙ)'},
    196: {'imya': '196-ekran-polnyj-s-kartoj.md', 'risk': 'обычный',
          'marker_v_priemke': True, 'trek': TREK_POLNYJ,
          'opisanie': 'обычный экран набора с картой целей и полным треком'},
}
TOY_S_KARTOJ = (195, 196)

# Цель карты экрана 195 (совместный режим f04): имя — КОНСТАНТА, её читают
# и раннер, и мутатор model/mutanty/sovmestnyj-tsel-vykljuchena.py.
KARTA_195_TSEL = 'gespraech-menu-sprechen'

# Порядок клеток (SPEC §6) — реестр батареи.
KLETKI = [
    'a01-trek-po-umolchaniju', 'a02-risk-bez-stroki', 'a03-risk-legkij',
    'a04-risk-legkij-so-slovom', 'a05-polnyj-vsegda', 'a06-pereklyuchenie',
    'a07-tochechnost', 'a08-grammatika', 'a09-dubl',
    'a10-sloj-ispolnen-v-polnom', 'a11-sloj-krasen', 'a12-marker-vne-priemki',
    'a13-marker-v-priemke', 'a14-sloj-vne-tablicy',
    'z01-gate-v-dereve', 'z02-noga-pre-critic',
    'b01-ostanovka-podtverzhdena', 'b02-zalipshij-390', 'b03-vtoroj-boot-port',
    'b04-maksimum-dva-avd', 'b05-maska-48', 'b06-kanon-piny',
    'b07-mutant-393-pri-390',
    'c01-literal-nav-height', 'c02-literal-line-height',
    'c03-literal-press-long', 'c04-ravnoe-chislo-bez-svjazi', 'c05-slezhenie',
    'd01-karty-polny', 'd02-oracle-tamper', 'd03-pustoj-produkt',
    'e01-soglasovano', 'e02-chisla-vne-teksta',
    'f00-chestnyj-kontrol', 'f01-predposylka', 'f02-sposoby-zony',
    'f03-sovmestnyj-chestnyj', 'f04-sovmestnyj-vykljuchennaja-tsel',
    'f05-sovmestnyj-polnyj-sloj', 'f06-sovmestnyj-karta-iz-fajla',
    'f07-sovmestnyj-nezavisimost-nomera', 'f08-sovmestnyj-dobavlenie-dannyh',
    'f10-zona-20', 'f11-zona-36-min36', 'f12-zona-rebenok-44',
    'f13-zona-flex-20', 'f14-zona-hitSlop-otric', 'f15-tsel-opacity0',
    'f16-tsel-predok-opacity0', 'f17-tsel-display-none',
    'f18-tsel-fon-nadpis-transparent', 'f19-tsel-nulevoj-boks',
    'f20-tsel-za-ekranom', 'f21-tsel-za-klipom', 'f22-tsel-perekryta',
    'f23-nadpis-skrytyj-text', 'f24-nadpis-prozrachnye-bukvy',
    'f25-nadpis-vlozhennyj-prozrachnyj', 'f26-nadpis-nulevaja-shirina',
    'f27-dejstvie-sdvig', 'f28-dejstvie-na-393',
    'f29-dejstvie-pointer-none', 'f30-cel-disabled', 'f31-cel-otsutstvuet',
    'f32-sostojanie-nedostizhimo', 'f33-sostojanie-slito',
    'g01-147-model', 'g02-147-stabs', 'g03-148-model', 'g04-148-stabs',
    'g05-149-model', 'g06-149-stabs', 'g07-143-stabs', 'g08-159',
]

# Негативные образцы: клетка → (мутатор, ожидаемая причина)
NEGATIVNYE = {
    'f10-zona-20': ('model/mutanty/zona-20.py', P_ZONA),
    'f11-zona-36-min36': ('model/mutanty/zona-36-min36.py', P_ZONA),
    'f12-zona-rebenok-44': ('model/mutanty/zona-rebenok-44.py', P_ZONA),
    'f13-zona-flex-20': ('model/mutanty/zona-flex-20.py', P_ZONA),
    'f14-zona-hitSlop-otric': ('model/mutanty/zona-hitslop-otric.py', P_ZONA),
    'f15-tsel-opacity0': ('model/mutanty/tsel-opacity0.py', P_TSEL_NEVIDIMA),
    'f16-tsel-predok-opacity0': ('model/mutanty/tsel-predok-opacity0.py',
                                 P_TSEL_NEVIDIMA),
    'f17-tsel-display-none': ('model/mutanty/tsel-display-none.py',
                              P_TSEL_NEVIDIMA),
    'f18-tsel-fon-nadpis-transparent': (
        'model/mutanty/tsel-fon-nadpis-transparent.py', P_TSEL_NEVIDIMA),
    'f19-tsel-nulevoj-boks': ('model/mutanty/tsel-nulevoj-boks.py',
                              P_TSEL_NEVIDIMA),
    'f20-tsel-za-ekranom': ('model/mutanty/tsel-za-ekranom.py', P_TSEL_NEVIDIMA),
    'f21-tsel-za-klipom': ('model/mutanty/tsel-za-klipom.py', P_TSEL_NEVIDIMA),
    'f22-tsel-perekryta': ('model/mutanty/tsel-perekryta.py', P_TSEL_NEVIDIMA),
    'f23-nadpis-skrytyj-text': ('model/mutanty/nadpis-skrytyj-text.py',
                                P_NADPIS_NEVIDIMA),
    'f24-nadpis-prozrachnye-bukvy': (
        'model/mutanty/nadpis-prozrachnye-bukvy.py', P_NADPIS_NEVIDIMA),
    'f25-nadpis-vlozhennyj-prozrachnyj': (
        'model/mutanty/nadpis-vlozhennyj-prozrachnyj.py', P_NADPIS_NEVIDIMA),
    'f26-nadpis-nulevaja-shirina': ('model/mutanty/nadpis-nulevaja-shirina.py',
                                    P_NADPIS_NEVIDIMA),
    'f27-dejstvie-sdvig': ('model/mutanty/dejstvie-sdvig.py', P_DEJSTVIE_CHUZHOE),
    'f28-dejstvie-na-393': ('model/mutanty/dejstvie-na-393.py',
                            P_DEJSTVIE_NET_PROFILE),
    'f29-dejstvie-pointer-none': ('model/mutanty/dejstvie-pointer-none.py',
                                  P_TSEL_VYKLYUCHENA),
    'f30-cel-disabled': ('model/mutanty/cel-disabled.py', P_TSEL_VYKLYUCHENA),
    'f31-cel-otsutstvuet': ('model/mutanty/cel-otsutstvuet.py',
                            P_TSEL_OTSUTSTVUET),
    'f32-sostojanie-nedostizhimo': ('model/mutanty/sostojanie-nedostizhimo.py',
                                     P_SOSTOJANIE_NEDOSTIZHIMO),
    'f33-sostojanie-slito': ('model/mutanty/sostojanie-slito.py',
                              P_SOSTOJANIE_SLITO),
}

# Регрессии соседей: клетка → (дверь, флаги)
SOSTEDY = {
    'g01-147-model': ('fixtures/workshop_project/gespraech_vhod_147/'
                      'red_gespraech_vhod_147.sh', ['--model']),
    'g02-147-stabs': ('fixtures/workshop_project/gespraech_vhod_147/'
                      'red_gespraech_vhod_147.sh', ['--stabs']),
    'g03-148-model': ('fixtures/workshop_project/vkladki_tabov_148/'
                      'red_vkladki_tabov_148.sh', ['--model']),
    'g04-148-stabs': ('fixtures/workshop_project/vkladki_tabov_148/'
                      'red_vkladki_tabov_148.sh', ['--stabs']),
    'g05-149-model': ('fixtures/workshop_project/gespraech_tekst_149/'
                      'red_gespraech_tekst_149.sh', ['--model']),
    'g06-149-stabs': ('fixtures/workshop_project/gespraech_tekst_149/'
                      'red_gespraech_tekst_149.sh', ['--stabs']),
    'g07-143-stabs': ('fixtures/workshop_project/mob_ci_143/'
                      'red_mob_ci_143.sh', ['--stabs']),
}

_VREMENNYE = []


# ── Исход клетки ───────────────────────────────────────────────────────
def ishod(rc, pri=(), mark=()):
    """Исход субъекта: rc + причины + маркеры вывода."""
    return {'rc': rc, 'pri': list(pri), 'mark': list(mark)}


def zelenaya():
    return ishod(0)


def krasnaya(*pri, mark=()):
    return ishod(1, pri, mark)


def otkaz(*pri, mark=()):
    return ishod(2, pri, mark)


def marki(*chasti):
    """Плоский список маркеров вывода (строки)."""
    vyhod = []
    for chast in chasti:
        if isinstance(chast, str):
            vyhod.append(chast)
        elif chast:
            vyhod.extend(str(s) for s in chast)
    return vyhod


# ── Утилиты ────────────────────────────────────────────────────────────
def sha_fajla(put):
    h = hashlib.sha256()
    with open(put, 'rb') as fh:
        for kus in iter(lambda: fh.read(65536), b''):
            h.update(kus)
    return h.hexdigest()


def sha_bajtov(bajty):
    return hashlib.sha256(bajty).hexdigest()


def zagruzit_modul(put, imya):
    spec = importlib.util.spec_from_file_location(imya, put)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def zagruzit_etalon(korn=None):
    return zagruzit_modul(os.path.join(korn or ZDE, 'model',
                                       'check_trek_ekrana_158.py'),
                          'check_trek_ekrana_158')


def zapusk_komandy(komanda, cwd=None, env=None, timeout=1800):
    okruzh = dict(os.environ)
    if env:
        okruzh.update(env)
    try:
        proc = subprocess.run(komanda, cwd=cwd, env=okruzh, timeout=timeout,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.TimeoutExpired:
        return 124, '', 'ТАЙМАУТ'
    return (proc.returncode, proc.stdout.decode('utf-8', 'replace'),
            proc.stderr.decode('utf-8', 'replace'))


def zapusk_chistyy(komanda, cwd=None, env=None, timeout=300):
    """Запуск с окружением БЕЗ переменных GIT_* — для git в одноразовом каталоге.

    Окружение прогона может нести GIT_DIR/GIT_WORK_TREE (door снимает их
    гигиенически) — в одноразовом toy-репозитории двери такие переменные
    указали бы на ЧУЖОЙ репозиторий.
    """
    okruzh = dict((k, v) for k, v in os.environ.items()
                  if not k.startswith('GIT_'))
    if env:
        okruzh.update(env)
    try:
        proc = subprocess.run(komanda, cwd=cwd, env=okruzh, timeout=timeout,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.TimeoutExpired:
        return 124, '', 'ТАЙМАУТ'
    return (proc.returncode, proc.stdout.decode('utf-8', 'replace'),
            proc.stderr.decode('utf-8', 'replace'))


def vremennyy_katalog(prefix='nabor158-'):
    put = tempfile.mkdtemp(prefix=prefix)
    _VREMENNYE.append(put)
    return put


def ubrat_vremennye():
    while _VREMENNYE:
        shutil.rmtree(_VREMENNYE.pop(), ignore_errors=True)


def prichiny_iz_vyvoda(vyvod):
    """Имена причин, упомянутые в выводе (дословно)."""
    return [p for p in VSE_PRICHINY if p in vyvod]


# ── Оракул (source.json) ───────────────────────────────────────────────
def chit_orakul(katalog=None):
    """Читает оракул и проверяет его целостность (правило 8).

    Возвращает (orakul, oshibka|None). Ошибка — ORACLE_TAMPERED.
    """
    katalog = katalog or ZDE
    put = os.path.join(katalog, 'source.json')
    try:
        with open(put, encoding='utf-8') as fh:
            orakul = json.load(fh)
    except (OSError, ValueError):
        return None, 'ORAKUL_NE_CHITAETSA'
    for klyuch in ('kejsy', 'piny', 'stab_vhod', 'standiny', 'dopusk'):
        if klyuch not in orakul:
            return None, 'ORAKUL_BEZ_KLYUCHA:%s' % klyuch
    if set(orakul['kejsy']) != set(KLETKI):
        return None, 'ORAKUL_CENSUS_NE_SOVPAL'
    if not isinstance(orakul.get('dopusk'), (int, float)):
        return None, 'ORAKUL_BEZ_DOPUSKA'
    # Стабы: перечень stab_vhod ↔ каталог stubs/ (рассинхрон — порча).
    staby = sorted(k for k in orakul['stab_vhod'])
    for imya in staby:
        if not os.path.isfile(os.path.join(katalog, 'stubs', imya)):
            return None, 'ORAKUL_STAB_NET:%s' % imya
        if not orakul['stab_vhod'][imya]:
            return None, 'ORAKUL_STAB_BEZ_VHODOV:%s' % imya
    na_disku = sorted(f for f in os.listdir(os.path.join(katalog, 'stubs'))
                      if f.endswith('.py'))
    if na_disku != staby:
        return None, 'ORAKUL_STAB_RASINHRON:%s' % ','.join(
            sorted(set(na_disku) ^ set(staby)))
    # Пины носителей: сверка байтов ДО любого субъекта.
    for gruppa in ('nositeli', 'etalony', 'zond'):
        for otn, sha in orakul['piny'].get(gruppa, {}).items():
            fajl = os.path.join(katalog, otn)
            if not os.path.exists(fajl):
                return None, 'ORAKUL_PIN:NET_FAJLA:%s' % otn
            if sha_fajla(fajl) != sha:
                return None, 'ORAKUL_PIN:NE_SOVPAL:%s' % otn
    return orakul, None


# ── Toy-мир ────────────────────────────────────────────────────────────
def tekst_kontrakta(nomer, trek=None, marker_v_priemke=None, risk=None,
                    pereklyuchenie=None, razreshenie=None, kompaktnyj=False):
    """Текст toy-контракта (строки — до вызова субъекта).

    kompaktnyj=True — компактная шапка: класс задачи и класс риска в ОДНОЙ
    строке («КЛАСС ЗАДАЧИ: КОДОВЫЙ. КЛАСС РИСКА: рисковый (деньги).»).
    Класс риска объявлен не отдельной строкой — гейт обязан прочитать его и
    там (обход разбора, найденный адверсарием).
    """
    opis = TOY[nomer]
    marker_v_priemke = (opis['marker_v_priemke'] if marker_v_priemke is None
                        else marker_v_priemke)
    risk = opis['risk'] if risk is None else risk
    stroki = []
    stroki.append('# Контракт %d — %s (toy-мир батареи ekrannyj_nabor_158)'
                  % (nomer, opis['opisanie']))
    stroki.append('')
    if kompaktnyj:
        stroki.append('КЛАСС ЗАДАЧИ: КОДОВЫЙ. КЛАСС РИСКА: %s' % risk)
    else:
        stroki.append('КЛАСС ЗАДАЧИ: КОДОВЫЙ.')
        stroki.append('КЛАСС РИСКА: %s' % risk)
    stroki.append('')
    stroki.append('КОНТЕКСТ: %s' % opis['opisanie'])
    if not marker_v_priemke:
        stroki.append('Маркер ekrannyj_nabor_158 упомянут ТОЛЬКО здесь, в '
                      'разделе КОНТЕКСТ: экран в набор НЕ входит.')
    stroki.append('')
    stroki.append('## Существующее')
    stroki.append('Живой референс станции — вне дерева харнеса; карта целей '
                  'экрана — в пачке pachki/%d/.' % nomer)
    stroki.append('')
    stroki.append('## Предмет')
    stroki.append('Экран %d: общие проверки экрана набора.' % nomer)
    stroki.append('')
    stroki.append('## Приёмочный критерий')
    if marker_v_priemke:
        stroki.append('- общие проверки экрана — батарея ekrannyj_nabor_158 '
                      '(fixtures/workshop_project/ekrannyj_nabor_158/'
                      'red_ekrannyj_nabor_158.sh).')
    else:
        stroki.append('- обычная приёмка экрана (в набор не входит).')
    if razreshenie:
        stroki.append(razreshenie)
    if trek is not None:
        stroki.append('ТРЕК: %s' % trek)
    if pereklyuchenie is not None:
        stroki.append('ТРЕК-ПЕРЕКЛЮЧЕНИЕ: %s' % pereklyuchenie)
    stroki.append('')
    return '\n'.join(stroki)


def tekst_yadra():
    return ('#!/usr/bin/env bash\n'
            'set -uo pipefail\n'
            'printf "ЯДРО: proverka-osnovaniya: основание экрана на месте\\n"\n'
            'exit 0\n')


def tekst_sloya(imya, rc):
    return ('#!/usr/bin/env bash\n'
            'set -uo pipefail\n'
            'printf "%s rc=%d\\n" >> sled\n'
            'exit %d\n' % (imya, rc, rc))


def sloi_paketa(nomer):
    """Состав команд полного трека пакета: (имя, код возврата)."""
    if nomer in (194, 196):
        return [('shag-1', 0), ('shag-2-krasnyj', 3)]
    return [('shag-1', 0)]


def karta_bajty():
    """Байты эталонной карты ref-clean (единый источник для пакетов)."""
    put = os.path.join(MODEL, 'karta-ref-clean.json')
    try:
        with open(put, 'rb') as fh:
            return fh.read().decode('utf-8')
    except OSError:
        return None


def postroit_toy(koren, karty=None, nomera=None):
    """Создаёт toy-мир: контракты 190..196 и их пакеты.

    Возвращает корень toy-мира. Файлы слоя копируются (ХУК-СЛОЙ —
    точка подмены стаба st02: при KOPIYUAT_SLOI=0 файлы слоя в пакет не
    попадают, и клетка a06 наблюдает разрушенную целость артефактов).
    """
    os.makedirs(os.path.join(koren, 'contracts'), exist_ok=True)
    KOPIYUAT_SLOI = True
    for nomer, opis in sorted(TOY.items()):
        if nomera is not None and nomer not in nomera:
            continue
        put = os.path.join(koren, 'contracts', opis['imya'])
        with open(put, 'w', encoding='utf-8') as fh:
            fh.write(tekst_kontrakta(nomer, trek=opis['trek']))
        paket = os.path.join(koren, 'pachki', str(nomer))
        os.makedirs(os.path.join(paket, 'yadro'), exist_ok=True)
        yadro = os.path.join(paket, 'yadro', 'proverka-osnovaniya.sh')
        with open(yadro, 'w', encoding='utf-8') as fh:
            fh.write(tekst_yadra())
        os.chmod(yadro, 0o755)
        if KOPIYUAT_SLOI:
            os.makedirs(os.path.join(paket, 'polnyj_trek'), exist_ok=True)
            for imya, rc in sloi_paketa(nomer):
                put2 = os.path.join(paket, 'polnyj_trek', imya + '.sh')
                with open(put2, 'w', encoding='utf-8') as fh:
                    fh.write(tekst_sloya(imya, rc))
                os.chmod(put2, 0o755)
        if nomer in TOY_S_KARTOJ and karty:
            with open(os.path.join(paket, 'karta.json'), 'w',
                      encoding='utf-8') as fh:
                fh.write(karty)
    return koren


def peropisyat_kontrakt(toy_root, nomer, **kwargs):
    """Перезаписывает текст toy-контракта (переключение трека)."""
    put = os.path.join(toy_root, 'contracts', TOY[nomer]['imya'])
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst_kontrakta(nomer, **kwargs))
    return put


def prochitat_sled(paket):
    put = os.path.join(paket, 'sled')
    if not os.path.exists(put):
        return []
    with open(put, encoding='utf-8') as fh:
        return [s.rstrip('\n') for s in fh if s.strip()]


def komandy_sloya(paket):
    """Имена команд polnyj_trek/*.sh пачки, снятые ДО запуска (без .sh).

    Снятое ДО запуска множество — единственный источник ожидания трассы
    слоя: исход не зависит ни от номера экрана, ни от имени команды, ни от
    таблицы номеров toy-мира в коде набора (Б-1 ревью 158; SPEC §6A).
    """
    katalog = os.path.join(paket, 'polnyj_trek')
    if not os.path.isdir(katalog):
        return []
    return sorted(f[:-3] for f in os.listdir(katalog) if f.endswith('.sh'))


def zapustit_sloi(paket):
    """Запускает команды полного трека; возвращает (sled, oshibki, fakty).

    fakty — (имя, ФАКТИЧЕСКИЙ rc процесса) по каждой запущенной команде:
    ожидание трассы слоя строится из снятого до запуска множества команд и
    rc, который вернул процесс каждой команды, — а не из таблицы номеров.
    """
    katalog = os.path.join(paket, 'polnyj_trek')
    oshibki = []
    fakty = []
    if not os.path.isdir(katalog):
        return [], ['POLNYJ_TREK_NET'], []
    for imya in sorted(os.listdir(katalog)):
        if not imya.endswith('.sh'):
            continue
        rc, out, err = zapusk_komandy(['bash', os.path.join(katalog, imya)],
                                      cwd=paket)
        fakty.append((imya[:-3], rc))
        if rc != 0:
            oshibki.append('%s rc=%d' % (imya[:-3], rc))
    return prochitat_sled(paket), oshibki, fakty


def ozhidanie_sleda(imena, fakty):
    """Ожидание трассы слоя: каждая снятая команда — строка с её rc.

    Команда, чей процесс не запускался, получает невыполнимый код (-1):
    трасса пуста или неполна при корректном разборе ТРЕК — это
    TREK_SLOJ_NE_ISPOLNEN, а не зелень (SPEC §6A «Раннер --ekran»).
    """
    fakt = dict(fakty)
    return ['%s rc=%d' % (imya, fakt.get(imya, -1)) for imya in imena]


def sloi_iz_fajlov(paket):
    """Состав слоя по ФАЙЛАМ пачки: [(имя, rc)] — rc из 'exit N' скрипта.

    Мера клетки (a10, a14): ожидание снимается из файлов слоя ДО запуска
    субъекта — клетка не делит константу с раннером (Б-1 ревью 158).
    """
    katalog = os.path.join(paket, 'polnyj_trek')
    sostav = []
    if not os.path.isdir(katalog):
        return sostav
    for imya in sorted(os.listdir(katalog)):
        if not imya.endswith('.sh'):
            continue
        put = os.path.join(katalog, imya)
        try:
            with open(put, encoding='utf-8') as fh:
                tekst = fh.read()
        except OSError:
            continue
        m = re.search(r'^exit (\d+)\s*$', tekst, re.M)
        sostav.append((imya[:-3], int(m.group(1)) if m else 0))
    return sostav


def zapustit_yadro(paket):
    """Запускает команды ядра; возвращает (stroki, oshibki)."""
    katalog = os.path.join(paket, 'yadro')
    stroki = []
    oshibki = []
    if not os.path.isdir(katalog):
        return stroki, ['YADRO_NET']
    for imya in sorted(os.listdir(katalog)):
        if not imya.endswith('.sh'):
            continue
        rc, out, err = zapusk_komandy(['bash', os.path.join(katalog, imya)],
                                      cwd=paket)
        for s in out.splitlines():
            if s.strip():
                stroki.append(s.strip())
        if rc != 0:
            oshibki.append('%s rc=%d' % (imya[:-3], rc))
    return stroki, oshibki


# ── Гейт ТРЕК: эталон (грамматика — единый источник) и субъект ─────────
def gate_etalon(koren, kontrakt_rel):
    """Вердикт эталона гейта: (rc, вывод)."""
    rc, out, err = zapusk_komandy(
        [sys.executable, os.path.join(MODEL, 'check_trek_ekrana_158.py'),
         koren, kontrakt_rel], cwd=KOREN)
    return rc, out + err


def gate_subjekt(koren, kontrakt_rel):
    """Вердикт живого scripts/check_trek_ekrana.sh; None — субъента нет."""
    skript = os.path.join(SKRIPTY, 'check_trek_ekrana.sh')
    if not os.path.isfile(skript):
        return None
    rc, out, err = zapusk_komandy(['bash', skript, koren, kontrakt_rel],
                                   cwd=KOREN)
    return rc, out + err


def nayti_kontrakt(koren, nomer):
    katalog = os.path.join(koren, 'contracts')
    if not os.path.isdir(katalog):
        return None
    prefiks = '%d-' % nomer
    for imya in sorted(os.listdir(katalog)):
        if imya.startswith(prefiks) and imya.endswith('.md'):
            return os.path.join(katalog, imya)
    return None


def chlenstvo_i_trek(tekst, imya):
    """Членство и ТРЕК по грамматике эталона: (rc, причина, трек, член)."""
    etalon = zagruzit_etalon()
    return etalon.sudi_tekst(tekst.splitlines(), imya)


# ── Экранный режим (--ekran NNN) ───────────────────────────────────────
def sud_ekran(toy_root, nomer, model=None):
    """Экранный режим: членство, ТРЕК, ядро, слой.

    toy_root — корень ОБЪЯВЛЕННОГО маршрута (toy-мир клеток либо корень
    дерева харнеса): контракт и пачка берутся ТОЛЬКО оттуда.

    Возвращает (rc, строки вывода, причины, sled, строки ядра).
    """
    model = model or zagruzit_etalon()
    kontrakt = nayti_kontrakt(toy_root, nomer)
    if kontrakt is None:
        return (2, ['NOT_IMPLEMENTED: контракт экрана %d не найден по '
                    'маршруту %s'
                    % (nomer, os.path.join(toy_root, 'contracts'))],
                [P_NOT_IMPL], [], [])
    with open(kontrakt, encoding='utf-8') as fh:
        stroki = fh.read().splitlines()
    rc, prichina, trek, chlen = model.sudi_tekst(stroki,
                                                 os.path.basename(kontrakt))
    vyvod = []
    if rc == 1:
        vyvod.append('ОТКАЗ: %s' % prichina)
        return 1, vyvod, [prichina], [], []
    if not chlen:
        vyvod.append('ПРОПУСК %s: контракт %d не экран набора'
                     % (P_NE_EKRAN, nomer))
        return 0, vyvod, [], [], []
    vyvod.append('ЭКРАН %d ТРЕК %s' % (nomer, trek))
    paket = os.path.join(toy_root, 'pachki', str(nomer))
    if not os.path.isdir(paket):
        # Пачки экрана нет — судить нечего (fail-closed), а не «ядро упало».
        vyvod.append('NOT_IMPLEMENTED: %s: пачка экрана %d отсутствует: %s'
                     % (P_KARTA_NET, nomer, paket))
        return 2, vyvod, [P_KARTA_NET], [], []
    sled_put = os.path.join(paket, 'sled')
    if os.path.exists(sled_put):
        os.remove(sled_put)
    yadro, oshibki_yadro = zapustit_yadro(paket)
    for s in yadro:
        vyvod.append(s)
    prichiny = []
    if oshibki_yadro:
        prichiny.append(P_YADRO_KRASNO)
    sled = []
    if trek == TREK_POLNYJ:
        imena = komandy_sloya(paket)
        sled, oshibki, fakty = zapustit_sloi(paket)
        for s in sled:
            vyvod.append('SLED %s' % s)
        if oshibki:
            prichiny.append(P_SLOJ_KRASNO)
        # Ожидание трассы — множество команд polnyj_trek/*.sh, снятое ДО
        # запуска, с ФАКТИЧЕСКИМ rc каждой команды (Б-1 ревью 158): исход
        # не зависит ни от номера экрана, ни от имени команды, ни от
        # таблицы номеров в коде набора; пустой слой при ПОЛНЫЙ — краснота.
        ozhidanie = ozhidanie_sleda(imena, fakty)
        if not imena or len(fakty) != len(imena) or \
                sorted(sled) != sorted(ozhidanie):
            prichiny.append(P_SLOJ_NE_ISPOLNEN)
    return (1 if prichiny else 0), vyvod, prichiny, sled, yadro


def ekran_rezhim(nomer, toy_root=None, model=None):
    """CLI --ekran NNN.

    Источник контракта и пачки — ОБЪЯВЛЕННЫЙ маршрут (SPEC §1):
      * NABOR_158_TOY_ROOT — корень toy-мира (внутренний путь клеток);
      * иначе — корень дерева харнеса (contracts/<NNN>-*.md, pachki/<NNN>/).
    Скрытый toy-мир НЕ подставляется: несуществующий экран — именованный
    отказ rc 2 (нечем проверить), а не зелень за чужой экран.
    """
    if toy_root is None:
        toy_root = os.environ.get('NABOR_158_TOY_ROOT') or KOREN
    rc, vyvod, prichiny, _sled, _yadro = sud_ekran(toy_root, nomer,
                                                   model=model)
    for s in vyvod:
        print(s)
    if prichiny:
        for p in prichiny:
            print('ПРИЧИНА %s' % p)
    return rc


# ── Дверь W подпроцессом (клетки судят дверь, не её внутренние функции) ──
PUT_DVERI = os.path.join(ZDE, 'probe.py')


def dver(args, env=None, timeout=1800):
    """Запуск двери W ПОДПРОЦЕССОМ — раннер чёрный ящик (SPEC §6A).

    Дверь — CLI probe.py (guard-обёртка red_ekrannyj_nabor_158.sh только
    исполняет его). PUT_DVERI — модульная точка подмены обманных стабов:
    стаб подставляет копию двери с вшитым дефектом и клетки судят уже
    дефектную дверь подпроцессом же (Б-2 ревью 158: шов — дверь).
    Возвращает (rc, строки вывода stdout+stderr).
    """
    rc, out, err = zapusk_komandy([sys.executable, PUT_DVERI] + list(args),
                                  cwd=KOREN, env=env, timeout=timeout)
    return rc, [s for s in (out + '\n' + err).splitlines() if s.strip()]


def razobrat_dver(stroki):
    """Разбор вывода экранной двери: (причины, sled, строки ядра)."""
    prichiny = [s.split(' ', 1)[1].strip() for s in stroki
                if s.startswith('ПРИЧИНА ')]
    sled = [s.split(' ', 1)[1].strip() for s in stroki
            if s.startswith('SLED ')]
    yadro = [s for s in stroki if s.startswith('ЯДРО')]
    return prichiny, sled, yadro


def ekran_dver(toy, nomer):
    """Экранный режим ЧЕРЕЗ ДВЕРЬ: `W --ekran NNN` подпроцессом.

    toy-корень — объявленным маршрутом NABOR_158_TOY_ROOT (SPEC §6A).
    Возвращает (rc, причины, sled, строки ядра, вывод).
    """
    rc, stroki = dver(['--ekran', str(nomer)],
                      env={'NABOR_158_TOY_ROOT': toy})
    prichiny, sled, yadro = razobrat_dver(stroki)
    return rc, prichiny, sled, yadro, stroki


def sovmestnaya_dver(toy, repo, nomer):
    """Совместный режим ЧЕРЕЗ ДВЕРЬ: `W --repo R --ekran NNN` подпроцессом.

    Возвращает (исход клетки, строки ZOND): rc/причины собираются из
    вывода двери, трасса — из её строк ZOND (трассу печатает зонд).
    """
    rc, stroki = dver(['--repo', repo, '--ekran', str(nomer)],
                      env={'NABOR_158_TOY_ROOT': toy})
    prichiny = sorted(set(prichiny_iz_vyvoda('\n'.join(stroki))))
    zond = [s for s in stroki if s.startswith('ZOND ')]
    return ishod(rc, prichiny, stroki), zond


def sovmestnyj_zelenyj_rc():
    """rc честной совместной двери при зелёном ядре карты.

    Гейт 159 в дереве — rc 0; без гейта — именованный отказ rc 2
    NOT_IMPLEMENTED (И-8): совместный режим не зелёный, пока 159 не
    заведён (порядок контрактов: 159 раньше 158).
    """
    return 2 if not gate_159_est() else 0


def dver_s_zamenoy(kot, chem, imya='.dver-stab'):
    """Копия двери с ОДНОЙ якорной заменой (обманные стабы, Н-39).

    Копия кладётся в каталог батареи: ZDE при __file__ копии указывает на
    настоящий каталог — оракул, носители и model/ читаются с настоящего
    места. Якорь обязан встречаться РОВНО один раз (прецедент —
    model/mutanty/_mutator.py). Удаление копии — на вызывающем (finally).
    """
    with open(os.path.join(ZDE, 'probe.py'), encoding='utf-8') as fh:
        tekst = fh.read()
    if tekst.count(kot) != 1:
        raise ValueError('якорь двери не уникален (%d): %r'
                         % (tekst.count(kot), kot[:80]))
    put = os.path.join(ZDE, '%s-%s.py' % (imya, secrets.token_hex(6)))
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst.replace(kot, chem))
    return put


# ── Живой зонд (копия референса + jest) ─────────────────────────────────
TOKENS_PAKETA = os.path.join('docs', 'ux', '05_Kompakt_D24', 'source',
                              'tokens.json')


def kopirovat_referens(repo, vrem):
    """Одноразовая копия референса (cp -a --reflink=auto).

    node_modules — симлинком (установка станции не копируется); пакет
    токенов кладётся рядом с mobile (зонд читает токены по относительному
    пути <корень>/docs/…). Возвращает (корень копии, oshibka|None).
    """
    mob = os.path.join(repo, 'mobile')
    if not os.path.isdir(mob):
        return None, 'в референсе нет mobile/'
    koren = os.path.join(vrem, 'repo')
    os.makedirs(koren, exist_ok=True)
    rc, out, err = zapusk_komandy(
        ['cp', '-a', '--reflink=auto', mob, os.path.join(koren, 'mobile')])
    if rc != 0:
        return None, 'cp -a --reflink=auto не сработал: %s' % err.strip()[:200]
    tok = os.path.join(repo, TOKENS_PAKETA)
    if os.path.isfile(tok):
        kuda = os.path.join(koren, TOKENS_PAKETA)
        os.makedirs(os.path.dirname(kuda), exist_ok=True)
        shutil.copyfile(tok, kuda)
    return koren, None


def kopirovat_zond(kopija, helper=None):
    """Копирует зонд набора в mobile/src/__nabor158__/ копии референса.

    helper — путь к подменённому helpery.ts (стаб st05); None — эталонный.
    """
    cel = os.path.join(kopija, 'mobile', 'src', '__nabor158__')
    os.makedirs(cel, exist_ok=True)
    for imya in ('helpery.ts', 'nabor-zond-158.test.tsx',
                 'sinteticheskij-ekran.tsx'):
        shutil.copyfile(os.path.join(ZOND, imya), os.path.join(cel, imya))
    if helper:
        shutil.copyfile(helper, os.path.join(cel, 'helpery.ts'))
    return cel


def zond_na_repo(repo, karta=None, rezhim='karta', timeout=1800):
    """Живой зонд на R: (строки трассы, oshibka|None).

    Трасса читается из ФАЙЛА (NABOR_158_TRASSA), не из stdout: раннер не
    подделывает трассу.
    """
    vrem = vremennyy_katalog('nabor158-live-')
    try:
        kopija, oshibka = kopirovat_referens(repo, vrem)
        if oshibka:
            return [], oshibka
        kopirovat_zond(kopija)
        mob = os.path.join(kopija, 'mobile')
        konfig = None
        for imya in ('jest.config.js', 'jest.config.json'):
            if os.path.isfile(os.path.join(mob, imya)):
                konfig = imya
                break
        if konfig is None:
            return [], 'нет mobile/jest.config.{js,json}'
        if not os.path.exists(os.path.join(mob, 'node_modules', '.bin',
                                           'jest')):
            return [], 'нет node_modules/.bin/jest'
        trassa = os.path.join(vrem, 'trassa.txt')
        env = {
            'NABOR_158_TRASSA': trassa,
            'NABOR_158_REZHIM': rezhim,
        }
        if karta:
            env['NABOR_158_KARTA'] = karta
        rc, out, err = zapusk_komandy(
            [os.path.join(mob, 'node_modules', '.bin', 'jest'), '--config',
             konfig, '--rootDir', '.', '--ci', '--runInBand',
             'nabor-zond-158'], cwd=mob, env=env, timeout=timeout)
        if not os.path.exists(trassa):
            return [], ('jest не дал трассу (rc=%d): %s'
                        % (rc, (err or out).strip()[:300]))
        with open(trassa, encoding='utf-8') as fh:
            stroki = [s.rstrip('\n') for s in fh if s.strip()]
        return stroki, None
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


def opredelit_kartu(repo):
    """Карта целей набора для референса R — по СОДЕРЖИМОМУ его экрана.

    Возвращает путь к карте (model/karta-*.json) или None.
    """
    put = os.path.join(repo, 'mobile', 'src', 'bootstrap', 'tab-shell.tsx')
    try:
        with open(put, encoding='utf-8') as fh:
            tekst = fh.read()
    except OSError:
        return None
    if 'gespraech-menu-' in tekst:
        return os.path.join(MODEL, 'karta-ref-clean.json')
    if 'shell-tabbar' in tekst:
        return os.path.join(MODEL, 'karta-mob-ref.json')
    return None


def prichiny_iz_trassy(stroki, prefiks='ZOND '):
    """Причины красных строк трассы (ZOND/ZONA)."""
    prichiny = []
    for s in stroki:
        if s.startswith(prefiks) and ' KRASNO ' in s:
            prichiny.append(s.split(' KRASNO ', 1)[1].strip())
    return prichiny


def sudi_repo(repo):
    """Живой суд на R: зонд по карте набора.

    Возвращает исход клетки: rc 0 — все обязательные цели всех состояний
    обоих профилей зелёные; rc 1 — причины зонда; rc 2 — нечем проверить.
    """
    mapa = opredelit_kartu(repo)
    if mapa is None:
        return otkaz('%s: карта целей набора для референса не определена'
                     % P_LIVE)
    stroki, oshibka = zond_na_repo(repo, karta=mapa)
    if oshibka:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    zond = [s for s in stroki if s.startswith('ZOND ')]
    if not zond:
        return krasnaya(P_ZOND_NE_ZAPUSHCHEN, mark=stroki)
    prichiny = prichiny_iz_trassy(stroki)
    if prichiny:
        return krasnaya(*sorted(set(prichiny)), mark=stroki)
    return zelenaya()


def sudi_sintetika(repo):
    """Клетка f02: ВСЕ 12 допустимых способов зоны ≥44 — зелёные."""
    stroki, oshibka = zond_na_repo(repo, rezhim='sintetika')
    if oshibka:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    zony = [s for s in stroki if s.startswith('ZONA ')]
    if len(zony) != 12:
        return krasnaya(P_ZOND_NE_ZAPUSHCHEN, mark=stroki)
    prichiny = prichiny_iz_trassy(stroki, 'ZONA ')
    if prichiny:
        return krasnaya(*sorted(set(prichiny)), mark=stroki)
    return zelenaya()


# ── Совместный режим (--repo R --ekran NNN) ────────────────────────────
def karta_pakety(toy_root, nomer):
    """Карта целей экрана NNN — из ФАЙЛА пачки (источник карты — пачка)."""
    put = os.path.join(toy_root, 'pachki', str(nomer), 'karta.json')
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def prefiks_stroki(s):
    """Префикс строки трассы: 'ZOND <testID> <профиль>' (без исхода)."""
    return ' '.join(s.split()[:3])


def ozhidanie_trassy(karta):
    """Точное множество целей трассы зонда по карте (в память проверяющего)."""
    stroki = set()
    for tsel in karta.get('tceli', []):
        for profil in karta.get('profili', []):
            stroki.add('ZOND %s %s' % (tsel['testID'], profil))
    return stroki


def geyt_159(repo):
    """Гейт 159 (И-8): первый отказ --repo-ветви. Возвращает (rc, вывод).

    Контракт возврата — ЕДИНЫЙ для обоих исходов: (rc, вывод). Гейт в
    дереве (ленд 159) отдаёт stdout+stderr вывода; отсутствие гейта —
    именованный отказ rc 2. Раньше (гейта 159 в дереве не было) жил
    только второй исход, и разбор тройки (rc, out, err) из запуска
    команды ронял клетку d03 и ветвь --repo.
    """
    skript = os.path.join(SKRIPTY, 'check_pustoj_produkt.sh')
    if not os.path.isfile(skript):
        return 2, 'NOT_IMPLEMENTED: гейт 159 (scripts/check_pustoj_produkt.sh) в дереве отсутствует'
    rc, out, err = zapusk_komandy(['bash', skript, repo], cwd=KOREN)
    return rc, out + err


def sovmestnyj_rezhim(repo, nomer, toy_root=None):
    """Ядро совместного режима: членство/ТРЕК, слой пачки, зонд на R.

    Возвращает исход: rc 0 — зелёное; rc 1 — именованная причина;
    rc 2 — нечем проверить.
    """
    if toy_root is None:
        toy_root = os.environ.get('NABOR_158_TOY_ROOT')
    if not toy_root:
        return otkaz('%s: нет toy-корня пачки (NABOR_158_TOY_ROOT)' % P_KARTA_NET)
    kontrakt = nayti_kontrakt(toy_root, nomer)
    if kontrakt is None:
        return otkaz('%s: контракт экрана %d в toy-мире не найден'
                     % (P_KARTA_NET, nomer))
    with open(kontrakt, encoding='utf-8') as fh:
        tekst = fh.read()
    rc, prichina, trek, chlen = chlenstvo_i_trek(tekst,
                                                 os.path.basename(kontrakt))
    if rc == 1:
        return krasnaya(prichina)
    if not chlen:
        return ishod(0, mark=['ПРОПУСК %s: контракт %d не экран набора'
                              % (P_NE_EKRAN, nomer)])
    karta = karta_pakety(toy_root, nomer)
    if karta is None:
        return otkaz('%s: карта пачки %d отсутствует' % (P_KARTA_NET, nomer))
    paket = os.path.join(toy_root, 'pachki', str(nomer))
    sled_put = os.path.join(paket, 'sled')
    if os.path.exists(sled_put):
        os.remove(sled_put)
    prichiny = []
    sled = []
    if trek == TREK_POLNYJ:
        imena = komandy_sloya(paket)
        sled, oshibki, fakty = zapustit_sloi(paket)
        if oshibki:
            prichiny.append(P_SLOJ_KRASNO)
        # Как в одиночном режиме (Б-1 ревью 158): ожидание — команды
        # polnyj_trek/*.sh, снятые ДО запуска, с фактическим rc процессов.
        ozhidanie = ozhidanie_sleda(imena, fakty)
        if not imena or len(fakty) != len(imena) or \
                sorted(sled) != sorted(ozhidanie):
            prichiny.append(P_SLOJ_NE_ISPOLNEN)
    # Зонд R по карте пачки: карта передаётся зонду ФАЙЛОМ (не таблицей).
    stroki, oshibka = zond_na_repo_s_kartoy(repo, karta)
    if oshibka:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    zond = [s for s in stroki if s.startswith('ZOND ')]
    ozhidanie = ozhidanie_trassy(karta)
    if set(prefiks_stroki(s) for s in zond) != ozhidanie:
        prichiny.append(P_ZOND_NE_ZAPUSHCHEN)
    else:
        prichiny.extend(prichiny_iz_trassy(stroki))
    if prichiny:
        return krasnaya(*sorted(set(prichiny)), mark=stroki)
    return ishod(0, mark=stroki)


def zond_na_repo_s_kartoy(repo, karta):
    """Зонд на R с картой ПАЧКИ (карта пишется во временный файл пачки)."""
    vrem = vremennyy_katalog('nabor158-karta-')
    put = os.path.join(vrem, 'karta.json')
    try:
        with open(put, 'w', encoding='utf-8') as fh:
            json.dump(karta, fh, ensure_ascii=False)
        return zond_na_repo(repo, karta=put)
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


# ── Линт токенов (И-3) ─────────────────────────────────────────────────
def chit_tokeny():
    put = os.path.join(NOS, 'tokens-vy-piska.json')
    with open(put, encoding='utf-8') as fh:
        return json.load(fh)


def lint_tokena(fajl, tokeny):
    """Линт носителя: литерал в месте токена без структурной связи.

    Возвращает список имён токенов (нарушения).
    """
    with open(fajl, encoding='utf-8') as fh:
        tekst = fh.read()
    narusheniya = []
    for imya, tok in tokeny.items():
        if imya.startswith('_'):
            continue
        link = tok.get('link_prii')
        if not link:
            continue
        svjaz = re.search(link, tekst) is not None
        if svjaz:
            continue
        for mesto in tok.get('mesta', []):
            if re.search(r'\b%s\s*:\s*[-+]?\d+(?:\.\d+)?\b' % re.escape(mesto),
                         tekst):
                narusheniya.append(imya)
                break
    return narusheniya


def lint_kontrol(tokeny):
    """Контроль линта: эталонный носитель (читает токен) — чист."""
    put = os.path.join(NOS, 'lint-obrazcy', 'chitaet-token.tsx')
    return lint_tokena(put, tokeny)


# ── Двойник e2e-канона AVD (семья B) ───────────────────────────────────
PORTY = {'390': '5570', '393': '5576'}


def sostoyanie_avd(sekretar, ustroystva):
    """Создаёт состояние песочницы adb: {serial: ('alive'|'dead', port)}."""
    os.makedirs(sekretar, exist_ok=True)
    for serial, (zhiv, port) in ustroystva.items():
        with open(os.path.join(sekretar, serial + '.state'), 'w',
                  encoding='utf-8') as fh:
            fh.write('alive' if zhiv else 'dead')
        with open(os.path.join(sekretar, serial + '.port'), 'w',
                  encoding='utf-8') as fh:
            fh.write(str(port))
    return sekretar


def zhivye_avd(sekretar):
    zhivye = []
    for imya in sorted(os.listdir(sekretar)):
        if not imya.endswith('.state'):
            continue
        serial = imya[:-len('.state')]
        with open(os.path.join(sekretar, imya), encoding='utf-8') as fh:
            if fh.read().strip() == 'alive':
                port = '5554'
                pput = os.path.join(sekretar, serial + '.port')
                if os.path.exists(pput):
                    with open(pput, encoding='utf-8') as pf:
                        port = pf.read().strip()
                zhivye.append((serial, port))
    return zhivye


def zapustit_dvoinik(skript, sekretar, env=None):
    """Запускает двойник канона в песочнице: (rc, вывод)."""
    okruzh = {
        'FAKE_ADB_STATE': sekretar,
        'PORT_390': PORTY['390'],
        'PORT_393': PORTY['393'],
    }
    if env:
        okruzh.update(env)
    rc, out, err = zapusk_komandy(['bash', skript], cwd=TEKSTY, env=okruzh,
                                   timeout=120)
    return rc, out + err


# ── Синтетические кадры масок (клетка b05) ─────────────────────────────
def png_rgb(w, h, rgb):
    """Минимальный PNG (8 бит, RGB) из строк пикселей."""
    import struct
    import zlib
    syrye = bytearray()
    for y in range(h):
        syrye.append(0)
        for x in range(w):
            r, g, b = rgb[y][x]
            syrye += bytes((r, g, b))
    def blok(typ, dannye):
        return (struct.pack('>I', len(dannye)) + typ + dannye +
                struct.pack('>I', zlib.crc32(typ + dannye) & 0xffffffff))
    return (b'\x89PNG\r\n\x1a\n' +
            blok(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) +
            blok(b'IDAT', zlib.compress(bytes(syrye), 9)) +
            blok(b'IEND', b''))


def sinth_kadry(maska_pt):
    """Синтетические макет и кадр: различие — только в полосе маски.

    Возвращает (байты макета, байты кадра).
    """
    w, h = 390, 844
    fon = (245, 245, 245)
    chernila = (20, 20, 20)
    y0 = 792
    y1 = 804
    maket = [[fon for _ in range(w)] for _ in range(h)]
    kadr = [[fon for _ in range(w)] for _ in range(h)]
    for y in range(y0, y1):
        for x in range(w):
            maket[y][x] = chernila
    return png_rgb(w, h, maket), png_rgb(w, h, kadr)


MERA_123 = {
    'chernila_T': 40, 'kletka_pt': 6, 'fon_shag': 4, 'razmytie_r': 1,
    'region_porog': 0.05, 'margin': 1, 'chrome_verh_pt': 36,
    'chrome_niz_pt': 20, 'min_dolja_suda': 0.5,
}


def manifest_maski(maska_vysota, snimok, sha_maketa):
    """Манифест одного синтетического кадра с маской заданной высоты (pt)."""
    return {
        'mera': MERA_123,
        'kadry': [{
            'id': 'nabor158 maska %d' % maska_vysota,
            'tema': 'light',
            'snimok': snimok,
            'maket': 'maket-%d.png' % maska_vysota,
            'maket_sha256': sha_maketa,
            'porog': 0.6,
            'maski_pt': [[0, 844 - maska_vysota, 390, 844]],
            'elementy': [{'imja': 'blok', 'bbox_pt': [0, 792, 390, 804]}],
        }],
    }


def progoni_frames(maska_vysota):
    """Прогон раннера 123 по синтетическому кадру с маской: (rc, вывод)."""
    vrem = vremennyy_katalog('nabor158-kadr-')
    try:
        maket, kadr = sinth_kadry(maska_vysota)
        with open(os.path.join(vrem, 'maket-%d.png' % maska_vysota), 'wb') as fh:
            fh.write(maket)
        snimok = 'nabor158-%d' % maska_vysota
        kadry = os.path.join(vrem, 'kadry', 'light', 'nabor158', 'a',
                             'takeScreenshot')
        os.makedirs(kadry, exist_ok=True)
        with open(os.path.join(kadry, snimok + '.png'), 'wb') as fh:
            fh.write(kadr)
        manifest = manifest_maski(maska_vysota, snimok,
                                  sha_bajtov(maket))
        put_manifesta = os.path.join(vrem, 'manifest.json')
        with open(put_manifesta, 'w', encoding='utf-8') as fh:
            json.dump(manifest, fh, ensure_ascii=False)
        runner = os.path.join(SKRIPTY, 'sverka_maketa.py')
        if not os.path.isfile(runner):
            return 2, 'NOT_IMPLEMENTED: раннер 123 отсутствует'
        rc, out, err = zapusk_komandy(
            [sys.executable, runner, '--manifest', put_manifesta, '--kadry',
             os.path.join(vrem, 'kadry'), '--repo', vrem], cwd=KOREN,
            timeout=600)
        return rc, out + err
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


# ── Вспомогательное: toy-мир и общие проверки ──────────────────────────
def toy_dlya(ctx):
    """Свежий toy-мир (контракты 190..196 + пакеты)."""
    vrem = vremennyy_katalog('nabor158-toy-')
    postroit_toy(vrem, karty=karta_bajty())
    return vrem


def tekst_ekrana(nomer, opisanie, trek=None, risk='обычный',
                  marker_v_priemke=True):
    """Текст произвольного экрана набора (генератор f06–f08)."""
    stroki = []
    stroki.append('# Контракт %d — %s (toy-мир батареи ekrannyj_nabor_158)'
                  % (nomer, opisanie))
    stroki.append('')
    stroki.append('КЛАСС ЗАДАЧИ: КОДОВЫЙ.')
    stroki.append('КЛАСС РИСКА: %s' % risk)
    stroki.append('')
    stroki.append('КОНТЕКСТ: %s' % opisanie)
    stroki.append('')
    stroki.append('## Существующее')
    stroki.append('Живой референс станции — вне дерева харнеса; карта целей '
                  'экрана — в пачке pachki/%d/.' % nomer)
    stroki.append('')
    stroki.append('## Предмет')
    stroki.append('Экран %d: общие проверки экрана набора.' % nomer)
    stroki.append('')
    stroki.append('## Приёмочный критерий')
    if marker_v_priemke:
        stroki.append('- общие проверки экрана — батарея ekrannyj_nabor_158 '
                      '(fixtures/workshop_project/ekrannyj_nabor_158/'
                      'red_ekrannyj_nabor_158.sh).')
    else:
        stroki.append('- обычная приёмка экрана (в набор не входит).')
    if trek is not None:
        stroki.append('ТРЕК: %s' % trek)
    stroki.append('')
    return '\n'.join(stroki)


def pereklyuchenie_stroka(iz, v, data='2026-11-05', avtor='implementer',
                          prichina='перевод трека экрана'):
    """Строка ТРЕК-ПЕРЕКЛЮЧЕНИЕ по грамматике эталона."""
    return '%s (%s) %s→%s — %s' % (data, avtor, iz, v, prichina)


# ── Семья A — ТРЕК-механика ────────────────────────────────────────────
def k_a01(ctx):
    toy = toy_dlya(ctx)
    rc, vyvod = gate_etalon(toy, 'contracts/190-ekran-obychnyj.md')
    if rc != 0:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    rc2, prichiny, sled, yadro, vyvod2 = ekran_dver(toy, 190)
    if prichiny:
        return ishod(rc2, prichiny, marki(vyvod, vyvod2))
    if sled:
        return krasnaya('SLED НЕ ПУСТ ПРИ ЛЁГКОМ ТРЕКЕ', mark=marki(vyvod, vyvod2))
    if not os.path.isdir(os.path.join(toy, 'pachki', '190', 'polnyj_trek')):
        return krasnaya('ФАЙЛЫ СЛОЯ УДАЛЕНЫ', mark=marki(vyvod, vyvod2))
    if not yadro:
        return krasnaya('ЯДРО НЕ ИСПОЛНЕНО', mark=marki(vyvod, vyvod2))
    # компактная шапка обычного экрана: класс риска объявлен НЕ отдельной
    # строкой — гейт обязан остаться зелёным (обычный класс не ломается)
    peropisyat_kontrakt(toy, 190, kompaktnyj=True)
    rc3, vyvod3 = gate_etalon(toy, 'contracts/190-ekran-obychnyj.md')
    if rc3 != 0:
        return ishod(rc3, prichiny_iz_vyvoda(vyvod3) or
                     ['КОМПАКТНАЯ ШАПКА ОБЫЧНОГО ЭКРАНА ОТВЕРГНУТА'],
                     marki(vyvod, vyvod2, vyvod3))
    return ishod(rc, [], marki(vyvod, vyvod2, vyvod3))


def k_a02(ctx):
    toy = toy_dlya(ctx)
    rc, vyvod = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    if rc != 1 or P_RISKA not in prichiny_iz_vyvoda(vyvod):
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    # компактная шапка: класс риска объявлен НЕ отдельной строкой — гейт
    # обязан отказать так же (обход разбора класса риска)
    peropisyat_kontrakt(toy, 191, kompaktnyj=True)
    rc2, vyvod2 = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    return ishod(rc2, prichiny_iz_vyvoda(vyvod2), marki(vyvod, vyvod2))


def k_a03(ctx):
    toy = toy_dlya(ctx)
    peropisyat_kontrakt(toy, 191, trek=TREK_LEGKIJ)
    rc, vyvod = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    if rc != 1 or P_RISKA not in prichiny_iz_vyvoda(vyvod):
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    peropisyat_kontrakt(toy, 191, trek=TREK_LEGKIJ, kompaktnyj=True)
    rc2, vyvod2 = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    return ishod(rc2, prichiny_iz_vyvoda(vyvod2), marki(vyvod, vyvod2))


def k_a04(ctx):
    toy = toy_dlya(ctx)
    peropisyat_kontrakt(toy, 191, trek=TREK_LEGKIJ,
                        razreshenie=('РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/'
                                     '191-ekran-riska.md — трек экрана: '
                                     'перевод на ЛЁГКИЙ (слово владельца)'))
    rc, vyvod = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))


def k_a05(ctx):
    toy = toy_dlya(ctx)
    ishody = []
    for nomer in (190, 191):
        peropisyat_kontrakt(toy, nomer, trek=TREK_POLNYJ)
        rc, vyvod = gate_etalon(toy, 'contracts/%s' % TOY[nomer]['imya'])
        ishody.append(ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod)))
    # компактная шапка риск-экрана с ЯВНЫМ треком — гейт зелёный: явный
    # трек не ломается, ложных отказов нет
    peropisyat_kontrakt(toy, 191, trek=TREK_POLNYJ, kompaktnyj=True)
    rc, vyvod = gate_etalon(toy, 'contracts/%s' % TOY[191]['imya'])
    ishody.append(ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod)))
    for i in ishody:
        if i['rc'] != 0:
            return i
    return ishod(0, [], [s for i in ishody for s in i['mark']])


def k_a06(ctx):
    toy = toy_dlya(ctx)
    shagi = [
        (TREK_LEGKIJ, pereklyuchenie_stroka(TREK_LEGKIJ, TREK_POLNYJ)),
        (TREK_POLNYJ, pereklyuchenie_stroka(TREK_POLNYJ, TREK_LEGKIJ)),
        (TREK_LEGKIJ, pereklyuchenie_stroka(TREK_LEGKIJ, TREK_POLNYJ)),
        (TREK_POLNYJ, pereklyuchenie_stroka(TREK_POLNYJ, TREK_LEGKIJ)),
    ]
    zhizni = []
    for trek, perekl in shagi:
        peropisyat_kontrakt(toy, 190, trek=trek, pereklyuchenie=perekl)
        rc, prichiny, sled, yadro, vyvod = ekran_dver(toy, 190)
        if prichiny:
            return ishod(rc, prichiny, [vyvod])
        zhizni.append((sled, tuple(yadro)))
        if not os.path.isdir(os.path.join(toy, 'pachki', '190',
                                          'polnyj_trek')):
            return krasnaya('ФАЙЛЫ СЛОЯ УДАЛЕНЫ НА ШАГЕ ПЕРЕКЛЮЧЕНИЯ',
                            mark=marki(vyvod))
    for i, (sled, _yadro) in enumerate(zhizni):
        if i % 2 == 0 and sled:
            return krasnaya('SLED НЕ ПУСТ НА ЛЁГКОМ ШАГЕ')
        if i % 2 == 1 and not sled:
            return krasnaya(P_SLOJ_NE_ISPOLNEN)
    if len({y for _s, y in zhizni}) != 1:
        return krasnaya('ИСХОДЫ ЯДРА РАЗЛИЧАЮТСЯ МЕЖДУ ШАГАМИ')
    return zelenaya()


def k_a07(ctx):
    toy = toy_dlya(ctx)
    rc0, vyvod0 = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    sostav0 = sorted(os.listdir(os.path.join(toy, 'pachki', '191',
                                              'polnyj_trek')))
    sled0 = prochitat_sled(os.path.join(toy, 'pachki', '191'))
    peropisyat_kontrakt(toy, 190, trek=TREK_POLNYJ,
                        pereklyuchenie=pereklyuchenie_stroka(TREK_LEGKIJ,
                                                             TREK_POLNYJ))
    rc1, vyvod1 = gate_etalon(toy, 'contracts/191-ekran-riska.md')
    sostav1 = sorted(os.listdir(os.path.join(toy, 'pachki', '191',
                                              'polnyj_trek')))
    sled1 = prochitat_sled(os.path.join(toy, 'pachki', '191'))
    if (rc0, prichiny_iz_vyvoda(vyvod0)) != (rc1, prichiny_iz_vyvoda(vyvod1)):
        return krasnaya('ИСХОД 191 ИЗМЕНИЛСЯ ПОСЛЕ ПЕРЕКЛЮЧЕНИЯ 190',
                        mark=[vyvod0, vyvod1])
    if sostav0 != sostav1 or sled0 != sled1:
        return krasnaya('СОСТАВ КОМАНД ИЛИ СЛЕД ПАЧКИ 191 ИЗМЕНИЛСЯ',
                        mark=[vyvod0, vyvod1])
    return zelenaya()


def k_a08(ctx):
    toy = toy_dlya(ctx)
    sluchai = [
        ('2026-13-45 (implementer) %s→%s — причина' % (TREK_LEGKIJ,
                                                        TREK_POLNYJ)),
        ('2026-11-05 (implementer) %s→%s' % (TREK_LEGKIJ, TREK_POLNYJ)),
        ('2026-11-05 (nesushestvuyushchiy) %s→%s — причина'
         % (TREK_LEGKIJ, TREK_POLNYJ)),
        ('2026-11-05 (implementer) %s→%s — причина' % (TREK_LEGKIJ,
                                                       TREK_LEGKIJ)),
    ]
    for perekl in sluchai:
        peropisyat_kontrakt(toy, 190, trek=TREK_LEGKIJ, pereklyuchenie=perekl)
        rc, vyvod = gate_etalon(toy, 'contracts/190-ekran-obychnyj.md')
        if rc != 1 or P_TREK_GRAMM not in prichiny_iz_vyvoda(vyvod):
            return ishod(rc, prichiny_iz_vyvoda(vyvod),
                         marki('ГЕЙТ ПРИНЯЛ БИТУЮ СТРОКУ: %s' % perekl,
                               vyvod))
    return ishod(1, [P_TREK_GRAMM],
                 marki(P_TREK_GRAMM,
                       'ГЕЙТ ОТКЛОНИЛ ВСЕ БИТЫЕ СТРОКИ ПЕРЕКЛЮЧЕНИЯ'))


def k_a09(ctx):
    toy = toy_dlya(ctx)
    put = os.path.join(toy, 'contracts', TOY[190]['imya'])
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst_kontrakta(190, trek=TREK_LEGKIJ))
        fh.write('ТРЕК: %s\n' % TREK_POLNYJ)
    rc, vyvod = gate_etalon(toy, 'contracts/190-ekran-obychnyj.md')
    return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))


def k_a10(ctx):
    toy = toy_dlya(ctx)
    peropisyat_kontrakt(toy, 190, trek=TREK_POLNYJ)
    # ожидание — по файлам слоя, снято ДО вызова субъекта (Б-1)
    ozhidanie = ['%s rc=%d' % (imya, rc) for imya, rc in
                 sloi_iz_fajlov(os.path.join(toy, 'pachki', '190'))]
    rc, prichiny, sled, _yadro, vyvod = ekran_dver(toy, 190)
    if prichiny:
        return ishod(rc, prichiny, [vyvod])
    if sorted(sled) != sorted(ozhidanie):
        return krasnaya(P_SLOJ_NE_ISPOLNEN, mark=[vyvod])
    return ishod(0, [], marki(vyvod, ['SLED %s' % s for s in sled]))


def k_a11(ctx):
    toy = toy_dlya(ctx)
    rc, prichiny, sled, _yadro, vyvod = ekran_dver(toy, 194)
    if not prichiny:
        return ishod(rc, [], [vyvod])
    if 'shag-2-krasnyj rc=3' not in sled:
        return krasnaya('SLED НЕ СОДЕРжит КРАСНУЮ КОМАНДУ СЛОЯ',
                        mark=[vyvod] + ['SLED %s' % s for s in sled])
    return ishod(rc, prichiny,
                 marki(vyvod, ['SLED %s' % s for s in sled]))


def k_a12(ctx):
    toy = toy_dlya(ctx)
    rc, vyvod = gate_etalon(toy, 'contracts/192-sosed-ne-ekran.md')
    if rc != 0 or 'ТРЕК' in vyvod:
        return ishod(rc if rc else 1, prichiny_iz_vyvoda(vyvod) or
                     ['ГЕЙТ НЕ МОЛЧАЛ О НЕ-ЭКРАНЕ'], [vyvod])
    rc2, prichiny, sled, _yadro, vyvod2 = ekran_dver(toy, 192)
    if prichiny:
        return ishod(rc2, prichiny, marki(vyvod, vyvod2))
    if sled:
        return krasnaya('SLED НЕ ПУСТ У НЕ-ЭКРАНА', mark=[vyvod2])
    if not os.path.isdir(os.path.join(toy, 'pachki', '192', 'polnyj_trek')):
        return krasnaya('ФАЙЛЫ СЛОЯ УДАЛЕНЫ', mark=[vyvod2])
    return ishod(0, [], marki(vyvod, vyvod2))


def k_a13(ctx):
    toy = toy_dlya(ctx)
    rc, vyvod = gate_etalon(toy, 'contracts/193-ekran-priemka.md')
    if rc != 0:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    rc2, prichiny, sled, yadro, vyvod2 = ekran_dver(toy, 193)
    if prichiny:
        return ishod(rc2, prichiny, marki(vyvod, vyvod2))
    if sled:
        return krasnaya('SLED НЕ ПУСТ ПРИ ЛЁГКОМ ТРЕКЕ', mark=[vyvod2])
    if not yadro:
        return krasnaya('ЯДРО НЕ ИСПОЛНЕНО', mark=[vyvod2])
    return ishod(0, [], marki(vyvod, vyvod2))


def k_a14(ctx):
    """Клетка a14: слой экрана с номером и именами команд ВНЕ toy-таблицы.

    Экран 501 не встречается в toy-мире батареи; команда слоя —
    negativnyj-obrazec.sh. При ТРЕК: ПОЛНЫЙ исход зависит только от
    исполнения слоя: слой исполнен — зелено; слой пропущен (команда
    молчит) — TREK_SLOJ_NE_ISPOLNEN (Б-1 ревью 158: раннер не сверяет
    трассу с таблицей номеров toy-мира).
    """
    toy = toy_dlya(ctx)
    os.makedirs(os.path.join(toy, 'contracts'), exist_ok=True)
    with open(os.path.join(toy, 'contracts',
                           '501-ekran-negativnyj-obrazec.md'), 'w',
              encoding='utf-8') as fh:
        fh.write(tekst_ekrana(501, 'экран набора с командой слоя вне '
                              'toy-таблицы батареи', trek=TREK_POLNYJ))
    paket = os.path.join(toy, 'pachki', '501')
    os.makedirs(os.path.join(paket, 'yadro'), exist_ok=True)
    yadro_put = os.path.join(paket, 'yadro', 'proverka-osnovaniya.sh')
    with open(yadro_put, 'w', encoding='utf-8') as fh:
        fh.write(tekst_yadra())
    os.chmod(yadro_put, 0o755)
    os.makedirs(os.path.join(paket, 'polnyj_trek'), exist_ok=True)
    komanda = os.path.join(paket, 'polnyj_trek', 'negativnyj-obrazec.sh')
    with open(komanda, 'w', encoding='utf-8') as fh:
        fh.write(tekst_sloya('negativnyj-obrazec', 0))
    os.chmod(komanda, 0o755)
    ozhidanie = ['%s rc=%d' % (imya, rc) for imya, rc in
                 sloi_iz_fajlov(paket)]
    # слой исполнен — зелено
    rc, prichiny, sled, _yadro, vyvod = ekran_dver(toy, 501)
    if prichiny or sorted(sled) != sorted(ozhidanie):
        return ishod(rc or 1, prichiny or [P_SLOJ_NE_ISPOLNEN],
                     marki(vyvod, ['SLED %s' % s for s in sled]))
    # слой пропущен: команда молчит (rc 0, строки в sled нет) — краснота
    with open(komanda, 'w', encoding='utf-8') as fh:
        fh.write('#!/usr/bin/env bash\nset -uo pipefail\nexit 0\n')
    rc2, prichiny2, sled2, _yadro2, vyvod2 = ekran_dver(toy, 501)
    if rc2 != 1 or P_SLOJ_NE_ISPOLNEN not in prichiny2:
        return ishod(rc2 or 1,
                     prichiny2 or ['СЛОЙ ПРОПУЩЕН, НО ДВЕРЬ МОЛЧИТ'],
                     marki(vyvod2, ['SLED %s' % s for s in sled2]))
    return ishod(0, [], marki(vyvod, ['SLED %s' % s for s in sled]))


def sravnit_gatey(toy, rel):
    """Исходы гейта эталона и субъекта по контракту; None — совпали."""
    etalon = gate_etalon(toy, rel)
    subjekt = gate_subjekt(toy, rel)
    if subjekt is None:
        return otkaz('%s: scripts/check_trek_ekrana.sh в дереве отсутствует'
                     % P_SUBJECT_ABSENT)
    if (etalon[0] != subjekt[0] or
            prichiny_iz_vyvoda(etalon[1]) != prichiny_iz_vyvoda(subjekt[1])
            or ('ТРЕК ПОЛНЫЙ' in etalon[1]) != ('ТРЕК ПОЛНЫЙ' in subjekt[1])
            or ('ТРЕК ЛЁГКИЙ' in etalon[1]) != ('ТРЕК ЛЁГКИЙ' in subjekt[1])):
        return krasnaya(P_NE_SOVPAL,
                        mark=['%s: эталон %s / субъект %s'
                              % (rel, etalon[1].strip(), subjekt[1].strip())])
    return None


def k_z01(ctx):
    toy = toy_dlya(ctx)
    for nomer in sorted(TOY):
        problema = sravnit_gatey(toy, 'contracts/%s' % TOY[nomer]['imya'])
        if problema is not None:
            return problema
    # компактная шапка — тоже дом A: эталон и субъект обязаны совпасть и тут
    for nomer in (190, 191):
        peropisyat_kontrakt(toy, nomer, kompaktnyj=True)
        problema = sravnit_gatey(toy, 'contracts/%s' % TOY[nomer]['imya'])
        if problema is not None:
            return problema
    return zelenaya()


# Гейты, копируемые в toy-репозиторий двери (нога (д3) и её образец).
KOPY_GATEY_DVERI = ('pre_critic.sh', 'check_precision_gate.sh',
                    'check_spec_ready.sh', 'verify_ci_parity.sh',
                    'check_trek_ekrana.sh')
# Путь эталона гейта трека ОТ КОРНЯ ДЕРЕВА (копируется в toy рядом с гейтом).
ETALON_TREKA_REL = os.path.join('fixtures', 'workshop_project',
                                'ekrannyj_nabor_158', 'model')


def postroit_toy_dveri(koren, kompaktnyj=False):
    """Toy-репозиторий двери: копии гейтов, риск-экран, git-коммит.

    Образец — fixtures/pre_critic/_toy.sh: гейты копируются в корень toy'а
    (дверь зовёт их по относительному пути при cwd = её корень), плюс
    минимальные ci.yml/package.json/ci_parity_exceptions.txt и git-коммит
    (precision-гейт требует репозиторий с коммитом).
    """
    for pod in ('scripts', 'contracts', os.path.join('.github', 'workflows'),
                'config', ETALON_TREKA_REL):
        os.makedirs(os.path.join(koren, pod), exist_ok=True)
    for imya in KOPY_GATEY_DVERI:
        istochnik = os.path.join(SKRIPTY, imya)
        if os.path.isfile(istochnik):
            shutil.copy2(istochnik, os.path.join(koren, 'scripts', imya))
    for imya in sorted(os.listdir(SKRIPTY)):
        if imya.startswith('lib_') and imya.endswith('.sh'):
            shutil.copy2(os.path.join(SKRIPTY, imya),
                         os.path.join(koren, 'scripts', imya))
    shutil.copy2(os.path.join(ZDE, 'model', 'check_trek_ekrana_158.py'),
                 os.path.join(koren, ETALON_TREKA_REL,
                              'check_trek_ekrana_158.py'))
    with open(os.path.join(koren, 'package.json'), 'w',
              encoding='utf-8') as fh:
        fh.write('{\n  "name": "toy",\n  "version": "1.0.0",\n'
                 '  "scripts": {\n'
                 '    "check:precision-gate":'
                 ' "bash scripts/check_precision_gate.sh",\n'
                 '    "check:spec-ready": "bash scripts/check_spec_ready.sh"\n'
                 '  }\n}\n')
    with open(os.path.join(koren, '.github', 'workflows', 'ci.yml'), 'w',
              encoding='utf-8') as fh:
        fh.write('name: toy-ci\non: [push]\njobs:\n  toy:\n'
                 '    runs-on: ubuntu-latest\n    steps:\n'
                 '      - run: npm run check:precision-gate -- . '
                 'contracts/191-ekran-riska.md\n'
                 '      - run: npm run check:spec-ready -- . '
                 'contracts/191-ekran-riska.md\n')
    with open(os.path.join(koren, 'config', 'ci_parity_exceptions.txt'), 'w',
              encoding='utf-8') as fh:
        fh.write('')
    with open(os.path.join(koren, 'contracts', '191-ekran-riska.md'), 'w',
              encoding='utf-8') as fh:
        fh.write(tekst_kontrakta(191, trek=TREK_LEGKIJ,
                                  kompaktnyj=kompaktnyj))
    for komanda in (['git', 'init', '-q', '-b', 'main', koren],
                    ['git', '-C', koren, 'add', '-A'],
                    ['git', '-C', koren, '-c', 'user.name=implementer',
                     '-c', 'user.email=implementer@dev-harness.local',
                     'commit', '-qm', 'toy: init']):
        rc, out, err = zapusk_chistyy(komanda, cwd=koren, timeout=300)
        if rc != 0:
            return '%s: %s' % (os.path.basename(komanda[1]),
                               (err or out).strip()[:200])
    return None


def k_z02(ctx):
    skript = os.path.join(SKRIPTY, 'pre_critic.sh')
    try:
        with open(skript, encoding='utf-8') as fh:
            tekst = fh.read()
    except OSError:
        return otkaz('%s: scripts/pre_critic.sh отсутствует' % P_SUBJECT_ABSENT)
    i_d2 = tekst.find('check_predposylki.sh')
    i_d3 = tekst.find('check_trek_ekrana.sh')
    if i_d3 < 0:
        return otkaz('%s: нога (д3) — вызова check_trek_ekrana.sh — нет'
                     % P_SUBJECT_ABSENT)
    if i_d2 >= 0 and i_d3 < i_d2:
        return krasnaya('НОГА (Д3) СТОИТ ДО НОГИ (Д2)')
    vyzyv = [s for s in tekst.splitlines()
             if 'check_trek_ekrana.sh' in s and '"$BASE"' in s
             and '"$CONTRACT"' in s]
    if not vyzyv:
        return krasnaya('НОГА (Д3) НЕ ЗОВЁТ ГЕЙТ С <корнем> И <контрактом>')
    # ЖИВОЙ ПРОГОН ДВЕРИ: риск-экран в ЛЁГКОМ треке → «трек-гейт красен».
    # Обе формы шапки: класс риска отдельной строкой и компактной (риск-экран
    # в компактной шапке не должен проходить дверь молча).
    for kompaktnyj in (False, True):
        koren = vremennyy_katalog('nabor158-dver-')
        oshibka = postroit_toy_dveri(koren, kompaktnyj=kompaktnyj)
        if oshibka:
            return otkaz('%s: toy-репозиторий двери не собран: %s'
                         % (P_SUBJECT_ABSENT, oshibka))
        rc, out, err = zapusk_komandy(
            ['bash', os.path.join(koren, 'scripts', 'pre_critic.sh'),
             'contracts/191-ekran-riska.md'], cwd=koren, timeout=600)
        vyvod = out + err
        if rc != 1:
            return krasnaya('ЖИВАЯ ДВЕРЬ НА РИСК-ЭКРАНЕ: rc=%d (ожидался 1)'
                            % rc, mark=[vyvod])
        if 'трек-гейт красен' not in vyvod:
            return krasnaya('ЖИВАЯ ДВЕРЬ НЕ СКАЗАЛА О ТРЕК-ГЕЙТЕ',
                            mark=[vyvod])
    return zelenaya()


# ── Семья B — двойник e2e-канона AVD ───────────────────────────────────
def k_b01(ctx):
    sekretar = sostoyanie_avd(vremennyy_katalog('nabor158-avd-'),
                              {'emulator-390': ('alive', 5554)})
    rc, vyvod = zapustit_dvoinik(os.path.join(TEKSTY, 'e2e-porjadok.sh'),
                                 sekretar)
    zhivye = zhivye_avd(sekretar)
    if rc != 0:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    if len(zhivye) != 1 or zhivye[0][0] != 'emulator-393':
        return krasnaya('ПЕСОЧНИЦА: живых AVD %d (ожидался ровно 393): %s'
                        % (len(zhivye), zhivye), mark=[vyvod])
    if zhivye[0][1] != PORTY['393']:
        return krasnaya('ПЕСОЧНИЦА: 393 на порту %s (канон %s)'
                        % (zhivye[0][1], PORTY['393']), mark=[vyvod])
    return ishod(0, [], marki(vyvod))


def k_b02(ctx):
    sekretar = sostoyanie_avd(vremennyy_katalog('nabor158-avd-'),
                              {'emulator-390': ('alive', 5554)})
    with open(os.path.join(sekretar, 'emulator-390.zastryal'), 'w',
              encoding='utf-8') as fh:
        fh.write('zastryal')
    rc, vyvod = zapustit_dvoinik(os.path.join(TEKSTY, 'e2e-porjadok.sh'),
                                 sekretar)
    zhivye = zhivye_avd(sekretar)
    if rc != 4 or P_PODTVERZHDENIE not in vyvod:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    if any(serial == 'emulator-393' for serial, _ in zhivye):
        return krasnaya('393 ЗАПУЩЕН ПРИ ЖИВОМ 390', mark=[vyvod])
    return ishod(4, [P_PODTVERZHDENIE], [vyvod])


def k_b03(ctx):
    sekretar = sostoyanie_avd(vremennyy_katalog('nabor158-avd-'), {
        'emulator-390': ('alive', 5554),
        'sosed': ('alive', PORTY['393']),
    })
    rc, vyvod = zapustit_dvoinik(os.path.join(TEKSTY, 'e2e-porjadok.sh'),
                                 sekretar)
    if rc != 5 or P_PORT_ZANJAT not in vyvod:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    return ishod(5, [P_PORT_ZANJAT], [vyvod])


def k_b04(ctx):
    sekretar = sostoyanie_avd(vremennyy_katalog('nabor158-avd-'), {
        'emulator-390': ('alive', 5554),
        'sosed-1': ('alive', 5556),
        'sosed-2': ('alive', 5558),
    })
    rc, vyvod = zapustit_dvoinik(os.path.join(TEKSTY, 'e2e-porjadok.sh'),
                                 sekretar)
    if rc != 6 or P_SLISHKOM_AVD not in vyvod:
        return ishod(rc, prichiny_iz_vyvoda(vyvod), marki(vyvod))
    return ishod(6, [P_SLISHKOM_AVD], [vyvod])


def k_b05(ctx):
    for kartaf in ('model/karta-ref-clean.json', 'model/karta-mob-ref.json'):
        with open(os.path.join(ZDE, kartaf), encoding='utf-8') as fh:
            karta = json.load(fh)
        if karta.get('maska_393') != 48:
            return krasnaya('%s: в карте %s маска_393=%s (канон 48)'
                            % (P_MASKA_36, kartaf, karta.get('maska_393')))
    rc48, vyvod48 = progoni_frames(48)
    if rc48 != 0:
        return krasnaya('КАДР С МАСКОЙ 48 НЕ ПРОШЁЛ РАННЕР 123',
                        mark=[vyvod48])
    rc36, vyvod36 = progoni_frames(36)
    if rc36 == 0 or 'NIZHE_POROGA' not in vyvod36:
        return krasnaya('КАДР С МАСКОЙ 36 НЕ ОТКЛОНЁН РАННЕРОМ',
                        mark=[vyvod36])
    return zelenaya()


def k_b06(ctx):
    piny = ctx['orakul']['piny'].get('nositeli', {})
    for otn, sha in sorted(piny.items()):
        fajl = os.path.join(ZDE, otn)
        if not os.path.exists(fajl):
            return krasnaya('%s: носитель %s отсутствует' % (P_KANON_PINY, otn))
        if sha_fajla(fajl) != sha:
            return krasnaya('%s: пин %s не совпал' % (P_KANON_PINY, otn))
    kanon = ctx['orakul'].get('standiny', {}).get('kanon', {})
    for otn, markery in sorted(kanon.items()):
        fajl = os.path.join(ZDE, otn)
        if not os.path.exists(fajl):
            return krasnaya('%s: носитель %s отсутствует' % (P_KANON_PINY, otn))
        with open(fajl, encoding='utf-8') as fh:
            tekst = fh.read()
        for mark in markery:
            if mark not in tekst:
                return krasnaya('%s: в %s нет маркера %s'
                                % (P_KANON_PINY, otn, mark))
    return zelenaya()


def k_b07(ctx):
    mutant = os.path.join(TEKSTY, 'mutanty', 'e2e-bez-podtverzhdenija.sh')
    if not os.path.isfile(mutant):
        return otkaz('%s: мутант канона %s отсутствует'
                     % (P_SUBJECT_ABSENT, mutant))
    sekretar = sostoyanie_avd(vremennyy_katalog('nabor158-avd-'),
                              {'emulator-390': ('alive', 5554)})
    with open(os.path.join(sekretar, 'emulator-390.zastryal'), 'w',
              encoding='utf-8') as fh:
        fh.write('zastryal')
    rc, vyvod = zapustit_dvoinik(mutant, sekretar)
    zhivye = zhivye_avd(sekretar)
    if any(serial == 'emulator-393' for serial, _ in zhivye):
        # мутант нарушил канон (393 при живом 390) — батарея его ОТКЛОНЯЕТ:
        # наблюдение состояния песочницы различимо, порядок мутанта не принят.
        return ishod(0, [], marki('МУТАНТ ОТКЛОНЁН: 393 запущен при живом 390',
                                  vyvod))
    return krasnaya(P_MUTANT_PROSHYOL,
                    mark=marki('МУТАНТ НЕРАЗЛИЧИМ ОТ ЭТАЛОНА', vyvod))


# ── Семья C — линт токенов ─────────────────────────────────────────────
def lint_kletka(fajl, tokен):
    tokeny = chit_tokeny()
    kontrol = lint_kontrol(tokeny)
    if kontrol:
        return krasnaya('%s: контроль линта красен: %s'
                        % (P_LINT_KONTROL, ', '.join(kontrol)))
    narusheniya = lint_tokena(os.path.join(NOS, 'lint-obrazcy', fajl),
                              tokeny)
    if tokен not in narusheniya:
        return zelenaya()
    return krasnaya(P_LITERAL, mark=[tokен])


def k_c01(ctx):
    return lint_kletka('nav-height-literaly.tsx', 'nav.height')


def k_c02(ctx):
    return lint_kletka('line-height-literaly.tsx', 'nav.label.line-height')


def k_c03(ctx):
    return lint_kletka('press-long-literaly.tsx', 'press-long')


def k_c04(ctx):
    return lint_kletka('ravnoe-chislo-bez-svjazi.tsx', 'touch-target.min')


def k_c05(ctx):
    """Слежение за токеном: значение токена меняется — компонент следует.

    Вход клетки — одноразовая копия ref-clean: токен пакета, цель карты
    (gespraech-mitte) и якорь компонента — ref-clean (SPEC §6C).
    """
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    stanciya = istochnik_ref_clean()
    if not os.path.isdir(stanciya):
        return otkaz('%s: станция ref-clean %s отсутствует'
                     % (P_LIVE, stanciya))
    vrem = vremennyy_katalog('nabor158-token-')
    try:
        kopija, oshibka = kopirovat_referens(istochnik_ref_clean(), vrem)
        if oshibka:
            return otkaz('%s: %s' % (P_LIVE, oshibka))
        tok = os.path.join(kopija, TOKENS_PAKETA)
        with open(tok, encoding='utf-8') as fh:
            tekst = fh.read()
        obrazec = re.compile(
            r'("touch-target":\s*\{.*?"min":\s*\{\s*"\$type":\s*'
            r'"dimension",\s*"\$value":\s*")44px(")', re.S)
        if len(obrazec.findall(tekst)) != 1:
            return otkaz('%s: токен touch-target.min не найден ровно один раз'
                         % P_LIVE)
        tekst = obrazec.sub(r'\g<1>46px\g<2>', tekst, count=1)
        with open(tok, 'w', encoding='utf-8') as fh:
            fh.write(tekst)
        stroki, oshibka = zond_na_kopii(kopija, os.path.join(MODEL,
                                                             'karta-ref-clean.json'))
        if oshibka:
            return otkaz('%s: %s' % (P_LIVE, oshibka))
        vysota = izmer_vysoty(stroki, 'gespraech-mitte', '390')
        if vysota is None:
            return krasnaya('ЗОНД НЕ ИЗМЕРИЛ ЦЕЛЬ gespraech-mitte',
                            mark=stroki)
        if vysota != 46:
            return krasnaya(P_TOKEN_NE_SLEDUET,
                            mark=['IZMER gespraech-mitte 390 %s' % vysota])
        # отрицательная рука: компонент НЕ следует за токеном — лаг виден
        vrem2 = vremennyy_katalog('nabor158-token-')
        kopija2, oshibka2 = kopirovat_referens(istochnik_ref_clean(), vrem2)
        if oshibka2:
            return otkaz('%s: %s' % (P_LIVE, oshibka2))
        tok2 = os.path.join(kopija2, TOKENS_PAKETA)
        with open(tok2, 'w', encoding='utf-8') as fh:
            fh.write(tekst)
        istochnik = os.path.join(kopija2, 'mobile', 'src', 'bootstrap',
                                  'tab-shell.tsx')
        with open(istochnik, encoding='utf-8') as fh:
            ishodnik = fh.read()
        if ishodnik.count('ziel: { minHeight: ziel, minWidth: ziel }') != 1:
            return otkaz('%s: якорь компонента не найден ровно один раз'
                         % P_LIVE)
        with open(istochnik, 'w', encoding='utf-8') as fh:
            fh.write(ishodnik.replace(
                'ziel: { minHeight: ziel, minWidth: ziel }',
                'ziel: { minHeight: 44, minWidth: 44 }'))
        stroki2, oshibka2 = zond_na_kopii(kopija2, os.path.join(
            MODEL, 'karta-ref-clean.json'))
        if oshibka2:
            return otkaz('%s: %s' % (P_LIVE, oshibka2))
        vysota2 = izmer_vysoty(stroki2, 'gespraech-mitte', '390')
        if vysota2 != 44:
            return krasnaya('ЛАГ НЕ ОБНАРУЖЕН: замер %s (ожидался 44)'
                            % vysota2, mark=stroki2)
        return ishod(0, [P_TOKEN_SLEDUET],
                     ['IZMER gespraech-mitte 390 46 (компонент следует)',
                      'IZMER gespraech-mitte 390 44 (лаг обнаружен)'])
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


def zond_na_kopii(kopija_koren, karta):
    """Зонд на УЖЕ СКОПИРОВАННОМ референсе (корень копии)."""
    vrem = vremennyy_katalog('nabor158-zond-')
    try:
        kopirovat_zond(kopija_koren)
        mob = os.path.join(kopija_koren, 'mobile')
        konfig = 'jest.config.js' if os.path.isfile(
            os.path.join(mob, 'jest.config.js')) else 'jest.config.json'
        trassa = os.path.join(vrem, 'trassa.txt')
        env = {'NABOR_158_TRASSA': trassa, 'NABOR_158_REZHIM': 'karta',
               'NABOR_158_KARTA': karta}
        rc, out, err = zapusk_komandy(
            [os.path.join(mob, 'node_modules', '.bin', 'jest'), '--config',
             konfig, '--rootDir', '.', '--ci', '--runInBand',
             'nabor-zond-158'], cwd=mob, env=env, timeout=1800)
        if not os.path.exists(trassa):
            return [], 'jest не дал трассу (rc=%d): %s' % (
                rc, (err or out).strip()[:300])
        with open(trassa, encoding='utf-8') as fh:
            return [s.rstrip('\n') for s in fh if s.strip()], None
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


def izmer_vysoty(stroki, testid, profil):
    """Высота зоны цели из строки IZMER трассы."""
    for s in stroki:
        if s.startswith('IZMER %s %s ' % (testid, profil)):
            razmer = s.split()[-1]
            try:
                return int(razmer.split('x')[1])
            except (IndexError, ValueError):
                return None
    return None


# ── Семья D — домен и оракул ───────────────────────────────────────────
def otkrytie_tega(tekst, nachalo):
    """Текст открывающего тега (от <Pressable до закрывающей '>' вне скобок).

    Атрибуты узла читаются ЦЕЛИКОМ: окно фиксированной длины обрывало
    разбор у экрана, у которого реквизиты длиннее (атрибуты таб-вкладки
    продукта 148), — и имя цели терялось.
    """
    glubina = 0
    i = nachalo
    while i < len(tekst):
        c = tekst[i]
        if c in '{([':
            glubina += 1
        elif c in '})]':
            glubina -= 1
        elif c == '>' and glubina == 0:
            return tekst[nachalo:i + 1]
        i += 1
    return tekst[nachalo:]


def pressable_testid(tekst):
    """testID интерактивных узлов исходника (литералы и шаблоны).

    Берутся только узлы <Pressable ...> — обязательные цели экрана; динамические
    значения testID={выражение} не именуют цель и не учитываются.
    """
    literaly = []
    shablony = []
    for m in re.finditer(r'<Pressable\b', tekst):
        blok = otkrytie_tega(tekst, m.start())
        shablon = re.search(r'testID=\{\s*`([^`]+)`\s*\}', blok)
        if shablon:
            shablony.append(shablon.group(1))
            continue
        literal = re.search(r'testID="([^"]+)"', blok)
        if literal:
            literaly.append(literal.group(1))
    return sorted(set(literaly)), sorted(set(shablony))


def shablon_sovpadayet(shablon, testid):
    """Совпадает ли имя цели с шаблоном testID (`prefix-${id}-suffix`)."""
    m = re.match(r'^(.*?)\$\{[^}]*\}(.*)$', shablon)
    if m is None:
        return False
    prefiks, suffiks = m.group(1), m.group(2)
    return (testid.startswith(prefiks) and testid.endswith(suffiks) and
            len(testid) > len(prefiks) + len(suffiks))


def ustroystva_iz_karty(karta):
    """Обязательные цели карты (список testID)."""
    return [t['testID'] for t in karta.get('tceli', [])
            if t.get('objazatelna', True)]


def k_d01(ctx):
    for imya, put, kartaf in REFERENSI:
        if not os.path.isdir(put):
            return otkaz('%s: референс %s отсутствует на станции'
                         % (P_LIVE, imya))
        istochnik = os.path.join(put, 'mobile', 'src', 'bootstrap',
                                  'tab-shell.tsx')
        try:
            with open(istochnik, encoding='utf-8') as fh:
                tekst = fh.read()
        except OSError:
            return otkaz('%s: нет компонента экрана %s' % (P_LIVE, istochnik))
        with open(os.path.join(ZDE, kartaf), encoding='utf-8') as fh:
            karta = json.load(fh)
        if sorted(karta.get('profili', [])) != list(PROFILI):
            return krasnaya('%s: в карте %s профили %s (канон 390+393)'
                            % (P_KARTA_NE_POLNA, kartaf, karta.get('profili')))
        if not karta.get('sostojanija'):
            return krasnaya('%s: в карте %s нет состояний'
                            % (P_KARTA_NE_POLNA, kartaf))
        celi = ustroystva_iz_karty(karta)
        if not celi:
            return krasnaya('%s: в карте %s нет обязательных целей'
                            % (P_KARTA_NE_POLNA, kartaf))
        literaly, shablony = pressable_testid(tekst)
        for testid in celi:
            if testid in literaly:
                continue
            if any(shablon_sovpadayet(s, testid) for s in shablony):
                continue
            return krasnaya('%s: цель %s карты %s не найдена в экране %s'
                            % (P_KARTA_NE_POLNA, testid, kartaf, imya))
        for testid in literaly:
            if testid in celi:
                continue
            if testid.startswith('shell-') and testid.endswith(('-faden',
                                                                '-keyboard-'
                                                                'container')):
                continue
            pozitsiya = tekst.find('testID="%s"' % testid)
            fragment = tekst[max(0, pozitsiya - 600):pozitsiya]
            if '?' in fragment and fragment.rfind('?') > fragment.rfind(':'):
                # цель выводится условно — не обязательная
                continue
            return krasnaya('%s: обязательная цель %s экрана %s не в карте %s'
                            % (P_KARTA_NE_POLNA, testid, imya, kartaf))
        sostoyaniya = karta['sostojanija']
        vhody = [s.get('vhod') for s in sostoyaniya if s.get('vhod')]
        for vhod in vhody:
            if vhod not in celi:
                return krasnaya('%s: вход состояния %s не в карте целей %s'
                                % (P_KARTA_NE_POLNA, vhod, kartaf))
        for tsel in karta.get('tceli', []):
            if not tsel.get('sostojanija'):
                return krasnaya('%s: цель %s не привязана к состоянию'
                                % (P_KARTA_NE_POLNA, tsel.get('testID')))
    return zelenaya()


def k_d02(ctx):
    """Клетка d02: порча оракула обнаруживается ДО клеток (rc 2)."""
    vrem = vremennyy_katalog('nabor158-orakul-')
    try:
        kopija = os.path.join(vrem, 'bateria')
        shutil.copytree(ZDE, kopija,
                        ignore=shutil.ignore_patterns('__pycache__'))
        put = os.path.join(kopija, 'source.json')
        with open(put, encoding='utf-8') as fh:
            orakul = json.load(fh)
        orakul['kejsy'].pop(sorted(orakul['kejsy'])[0], None)
        with open(put, 'w', encoding='utf-8') as fh:
            json.dump(orakul, fh, ensure_ascii=False)
        _orakul, oshibka = chit_orakul(kopija)
        if oshibka is None:
            return krasnaya(P_ORACLE, mark=marki('порча оракула не '
                                                 'обнаружена'))
        return ishod(2, [P_ORACLE], marki(P_ORACLE, oshibka))
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
        if vrem in _VREMENNYE:
            _VREMENNYE.remove(vrem)


def k_d03(ctx):
    """Клетка d03: --repo-ветвь начинается с гейта 159 (И-8)."""
    pusto = vremennyy_katalog('nabor158-pusto-')
    os.makedirs(os.path.join(pusto, 'mobile'), exist_ok=True)
    rc, vyvod = geyt_159(pusto)
    if rc == 2:
        return ishod(2, [P_NOT_IMPL], [vyvod])
    if P_PUSTOJ not in vyvod:
        return ishod(rc, prichiny_iz_vyvoda(vyvod) or
                     ['ГЕЙТ 159 НЕ НАЗВАЛ ПУСТОЙ ПРОДУКТ'], [vyvod])
    return ishod(rc, [P_PUSTOJ], [vyvod])


# ── Семья E — самоописание ─────────────────────────────────────────────
def schity_batarei(orakul):
    """Счёты батареи по оракулу (вторая мера)."""
    return {
        'kletok': len(orakul['kejsy']),
        'stabov': len(orakul['stab_vhod']),
        'svjazej': sum(len(v) for v in orakul['stab_vhod'].values()),
        'nositelej': schit_nositelej(),
        'piny': sum(len(orakul['piny'].get(g, {}))
                    for g in ('nositeli', 'etalony', 'zond')),
        'roditel': sha_fajla(os.path.join(ZDE, 'probe.py')),
    }


def schit_nositelej():
    """Носители батареи — файлы каталогов nositeli/, zond/, model/."""
    schet = 0
    for katalog in ('nositeli', 'zond', 'model'):
        koren = os.path.join(ZDE, katalog)
        for dirpath, dirnames, imena in os.walk(koren):
            dirnames[:] = [d for d in dirnames if d != '__pycache__']
            for imya_f in imena:
                if imya_f.endswith('.pyc'):
                    continue
                schet += 1
    return schet


def k_e01(ctx):
    skript = os.path.join(SAMO, 'samoopisanie.py')
    if not os.path.isfile(skript):
        return otkaz('%s: samoopisanie/samoopisanie.py отсутствует'
                     % P_SUBJECT_ABSENT)
    rc, out, err = zapusk_komandy([sys.executable, skript], cwd=ZDE,
                                   timeout=300)
    if rc != 0:
        return krasnaya('САМООПИСАНИЕ УПАЛО: rc=%d' % rc, mark=[out, err])
    try:
        vyvod = json.loads(out.strip().splitlines()[-1])
    except (ValueError, IndexError):
        return krasnaya('САМООПИСАНИЕ НЕ РАЗОБРАНО', mark=[out])
    mery = schity_batarei(ctx['orakul'])
    problemy = []
    for klyuch, znachenie in sorted(mery.items()):
        if vyvod.get(klyuch) != znachenie:
            problemy.append('%s: %s != %s' % (klyuch, vyvod.get(klyuch),
                                              znachenie))
    if problemy:
        return krasnaya(P_ORACLE_NE_SOVPAL, mark=problemy)
    return zelenaya()


def k_e02(ctx):
    put = os.path.join(KOREN, 'contracts', '158-ekrannyj-nabor.md')
    try:
        with open(put, encoding='utf-8') as fh:
            tekst = fh.read()
    except OSError:
        return otkaz('%s: контракт 158 не найден' % P_SUBJECT_ABSENT)
    # Счёт БАТАРЕИ 158 — без стрелочных счётов чужих батарей (147/149 в
    # разделе «Существующее» — исторические числа, не счёт набора).
    shablony = [r'клеток\s+\d+(?!\d|→)', r'стабов\s+\d+(?!\d|→)',
                r'SVJAZI\s+\d+', r'носител\w*\s+\d+(?!\d|→)',
                r'привязок\s+\d+(?!\d|→)']
    for shablon in shablony:
        for sovpadenie in re.finditer(shablon, tekst):
            return krasnaya('В ТЕКСТЕ КОНТРАКТА СЧЁТ БАТАРЕИ: %s'
                            % sovpadenie.group(0), mark=[tekst[:0]])
    return zelenaya()


# ── Семья F — живой суд ────────────────────────────────────────────────
def zhivaya_kopiya(repo):
    """Одноразовая reflink-копия референса (удаляется сразу)."""
    vrem = vremennyy_katalog('nabor158-repo-')
    kopija, oshibka = kopirovat_referens(repo, vrem)
    if oshibka:
        shutil.rmtree(vrem, ignore_errors=True)
        return None, oshibka
    return kopija, None


def istochnik_ref_clean():
    """Станция ref-clean — источник входов, привязанных к ref-clean.

    SPEC §6F называет их прямо: f03–f05 — «одноразовые reflink-копии
    ref-clean», f06–f08 — «одна копия живого ref-clean R»; §4 `istochnik`
    карты = путь ref-clean. Образцы (f10–f33) и слежение c05 работают на
    копии ТОГО ЖЕ референса: их якоря мутаторов, значения токенов и цели
    карты — ref-clean.

    От переданного R зависят f00 (честный контроль), f01, f02 и гейт 159 —
    они судят ИМЕННО переданный референс.
    """
    return REFERENSI[0][1]


def k_f00(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (нужен --repo)' % P_LIVE)
    return sudi_repo(repo)


def k_f01(ctx):
    """Клетка f01: референс без jest-среды — rc 2 LIVE_PREDPOSYLKA.

    Подмножество клеток — ВНУТРЕННИЙ вызов (незаявленный флаг CLI запрещён
    SPEC §1): судится тот же живой путь --repo, что зовёт CLI.
    """
    pusto = vremennyy_katalog('nabor158-bez-sredy-')
    try:
        ish = sudi_repo(pusto)
    finally:
        shutil.rmtree(pusto, ignore_errors=True)
    # Имя причины — ПОДСТРОКОЙ в тексте отказа (причины форматированы);
    # наружу — ДОСЛОВНОЕ имя причины и текст отказа маркером.
    if ish['rc'] == 2 and any(P_LIVE in p for p in ish.get('pri', [])):
        return ishod(2, [P_LIVE], list(ish.get('pri', [])))
    return krasnaya('ЖИВОЙ ВХОД БЕЗ СРЕДЫ НЕ ДАЛ ИМЕНОВАННЫЙ ОТКАЗ',
                    mark=ish.get('mark', []))


def k_f02(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (нужен --repo)' % P_LIVE)
    return sudi_sintetika(repo)


def karta_konstanta():
    """Карта целей ref-clean — КОНСТАНТА проверяющего (SPEC §6F f03).

    Ожидание трассы снимается ДО вызова субъекта и не берётся из пачки
    субъекта: иначе подмена источника карты не наблюдаема.
    """
    put = os.path.join(MODEL, 'karta-ref-clean.json')
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def svetoit_trassu(ish, zond, karta):
    """Сверка трассы зонда САМОЙ проверяющей (карта снята ДО вызова).

    Сверку выполняет проверяющий, а не субъект: субъект может не сверять
    свою трассу вовсе (стаб st09 — совместный режим уходит в toy-ветвь) —
    и тогда его исход остаётся «зелёным» при отсутствии трассы. Исход
    сверки: точное множество 'ZOND <testID> <профиль>' против карты.
    """
    if karta is None:
        return ishod(2, [P_KARTA_NET], ish.get('mark', []))
    fakt = set(prefiks_stroki(s) for s in zond)
    if fakt != ozhidanie_trassy(karta):
        pri = sorted(set(list(ish.get('pri', [])) + [P_ZOND_NE_ZAPUSHCHEN]))
        return ishod(1, pri, ish.get('mark', []))
    return ish


def k_f03(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    toy = toy_dlya(ctx)
    karta = karta_konstanta()          # ожидание — ДО вызова субъекта
    kopija, oshibka = zhivaya_kopiya(istochnik_ref_clean())
    if kopija is None:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    try:
        ish, zond = sovmestnaya_dver(toy, kopija, 195)
        return svetoit_trassu(ish, zond, karta)
    finally:
        shutil.rmtree(os.path.dirname(kopija), ignore_errors=True)


def k_f04(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    toy = toy_dlya(ctx)
    karta = karta_konstanta()          # ожидание — ДО вызова субъекта
    kopija, oshibka = zhivaya_kopiya(istochnik_ref_clean())
    if kopija is None:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    try:
        mutator = os.path.join(ZDE, 'model', 'mutanty',
                               'sovmestnyj-tsel-vykljuchena.py')
        rc, out, err = zapusk_komandy([sys.executable, mutator, kopija],
                                      cwd=ZDE, timeout=300)
        if rc != 0:
            return otkaz('%s: мутатор не применён: %s' % (P_LIVE, err.strip()))
        ish, zond = sovmestnaya_dver(toy, kopija, 195)
        return svetoit_trassu(ish, zond, karta)
    finally:
        shutil.rmtree(os.path.dirname(kopija), ignore_errors=True)


def k_f05(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    toy = toy_dlya(ctx)
    karta = karta_konstanta()          # ожидание — ДО вызова субъекта
    kopija, oshibka = zhivaya_kopiya(istochnik_ref_clean())
    if kopija is None:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    try:
        ish, zond = sovmestnaya_dver(toy, kopija, 196)
        return svetoit_trassu(ish, zond, karta)
    finally:
        shutil.rmtree(os.path.dirname(kopija), ignore_errors=True)


# ── Генератор динамических входов f06–f08 (внешний проверяющий) ────────
def svobodnye_nomera(ctx, skolko=2):
    """Свободные трёхзначные номера экранов (не в toy-мире и не в дереве)."""
    zanyaty = set(TOY.keys())
    katalog = os.path.join(KOREN, 'contracts')
    if os.path.isdir(katalog):
        for imya in os.listdir(katalog):
            m = re.match(r'^(\d+)-', imya)
            if m:
                zanyaty.add(int(m.group(1)))
    vybrany = []
    while len(vybrany) < skolko:
        n = 700 + secrets.randbelow(200)
        if n in zanyaty or n in vybrany:
            continue
        vybrany.append(n)
    return vybrany


def imena_celi(ctx, skolko=3):
    """Независимые имена целей из безопасного алфавита testID."""
    imena = []
    while len(imena) < skolko:
        kandidat = 'nabor158-celi-%s' % secrets.token_hex(3)
        if kandidat not in imena:
            imena.append(kandidat)
    return imena


def slug_celi(testid):
    return testid.rsplit('-', 1)[-1]


def vstavit_celi(kopija_koren, celi):
    """Вставляет настоящие RN Pressable-цели в компонент First-Run копии.

    celi — список (testID, состояние): 'ok' — пресс доставляет действие,
    'disabled' — пресс недоступен.
    """
    put = os.path.join(kopija_koren, 'mobile', 'src', 'features', 'auth',
                       'first-run-screen.tsx')
    with open(put, encoding='utf-8') as fh:
        tekst = fh.read()
    importy = re.search(r"^import \{([^}]*)\} from 'react-native';$", tekst,
                        re.M)
    if importy is None:
        return False, 'не найден импорт react-native компонента First-Run'
    imena = [x.strip() for x in importy.group(1).split(',') if x.strip()]
    for nuzhnoe in ('Pressable', 'Text', 'View'):
        if nuzhnoe not in imena:
            imena.append(nuzhnoe)
    tekst = (tekst[:importy.start()] +
             "import { %s } from 'react-native';" % ', '.join(imena) +
             tekst[importy.end():])
    nachalo = tekst.find('export function FirstRunScreen')
    if nachalo < 0:
        return False, 'не найден компонент FirstRunScreen'
    konec = tekst.find('    </SafeAreaView>', nachalo)
    if konec < 0:
        return False, 'не найден конец компонента FirstRunScreen'
    helper = [
        '// Цели набора ekrannyj_nabor_158 (генератор f06–f08): настоящие',
        '// RN Pressable-цели в компоненте First-Run копии референса.',
        'const nabor158Command = (kind: string): void => {',
        '  const globalKommand = globalThis as unknown as {',
        '    __nabor158_command?: (c: { kind: string }) => void;',
        '  };',
        '  globalKommand.__nabor158_command?.({ kind });',
        '};',
        '',
    ]
    blok = ['      <View testID="nabor158-celi-blok">']
    for testid, sostojanie in celi:
        slug = slug_celi(testid)
        blok.append('        <Pressable')
        blok.append('          accessibilityRole="button"')
        blok.append('          disabled={%s}'
                    % ('true' if sostojanie == 'disabled' else 'false'))
        blok.append('          onPress={() => { nabor158Command(\'%s\'); }}'
                    % slug)
        blok.append('          style={{ minWidth: 44, minHeight: 44 }}')
        blok.append('          testID="%s"' % testid)
        blok.append('        >')
        blok.append('          <Text style={{ fontSize: 12, lineHeight: 12 }}>'
                    '%s</Text>' % slug)
        blok.append('        </Pressable>')
    blok.append('      </View>')
    tekst = (tekst[:nachalo] + '\n'.join(helper) + '\n' + tekst[nachalo:])
    konec = tekst.find('    </SafeAreaView>', nachalo + len(helper))
    tekst = tekst[:konec] + '\n'.join(blok) + '\n' + tekst[konec:]
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst)
    # маркер зонда: копия First-Run (зонд рисует компонент по этому маркеру)
    cel = os.path.join(kopija_koren, 'mobile', 'src', '__nabor158__')
    os.makedirs(cel, exist_ok=True)
    with open(os.path.join(cel, '.firstrun'), 'w', encoding='utf-8') as fh:
        fh.write('1\n')
    return True, None


def karta_genera(celi, imya):
    """Карта целей сгенерированного экрана (формат SPEC §4)."""
    return {
        'ekran': imya,
        'istochnik': 'одноразовая копия референса станции',
        'profili': list(PROFILI),
        'sostojanija': [{'id': 'start', 'vhod': None}],
        'tceli': [{
            'testID': testid,
            'objazatelna': True,
            'sostojanija': ['start'],
            'nadpis': slug_celi(testid),
            'postuslovie': {'tip': 'vyzov', 'znachenie': slug_celi(testid)},
        } for testid in celi],
    }


def generiruy(ctx, repo):
    """Генератор f06–f08: свободные номера, имена целей, копия R с целями.

    Контракт возврата ЕДИН для обеих ветвей — кортеж (результат, ошибка):
    успех — (словарь входов, None), отказ — (None, текст ошибки).
    """
    n1, n2 = svobodnye_nomera(ctx, 2)
    x, y, z = imena_celi(ctx, 3)
    kopija, oshibka = zhivaya_kopiya(istochnik_ref_clean())
    if kopija is None:
        return None, oshibka
    ok, oshibka2 = vstavit_celi(kopija, [(x, 'ok'), (y, 'disabled'),
                                         (z, 'ok')])
    if not ok:
        return None, oshibka2
    toy = vremennyy_katalog('nabor158-gen-toy-')
    os.makedirs(os.path.join(toy, 'contracts'), exist_ok=True)
    for nomer in (n1, n2):
        with open(os.path.join(toy, 'contracts',
                               '%d-ekran-genera.md' % nomer), 'w',
                  encoding='utf-8') as fh:
            fh.write(tekst_ekrana(nomer, 'экран набора, сгенерированный '
                                  'батареёй (f06–f08)', trek=TREK_LEGKIJ))
        paket = os.path.join(toy, 'pachki', str(nomer))
        os.makedirs(os.path.join(paket, 'yadro'), exist_ok=True)
        yadro = os.path.join(paket, 'yadro', 'proverka-osnovaniya.sh')
        with open(yadro, 'w', encoding='utf-8') as fh:
            fh.write(tekst_yadra())
        os.chmod(yadro, 0o755)
        os.makedirs(os.path.join(paket, 'polnyj_trek'), exist_ok=True)
        komanda = os.path.join(paket, 'polnyj_trek', 'shag-1.sh')
        with open(komanda, 'w', encoding='utf-8') as fh:
            fh.write(tekst_sloya('shag-1', 0))
        os.chmod(komanda, 0o755)
    karty = {
        'A': karta_genera([x], 'nabor158-genera-A'),
        'B': karta_genera([x, y], 'nabor158-genera-B'),
        'C': karta_genera([x, y, z], 'nabor158-genera-C'),
    }
    return {
        'N': n1, 'M': n2, 'X': x, 'Y': y, 'Z': z,
        'repo': kopija, 'toy': toy, 'karty': karty,
        'ozhidaniya': {k: ozhidanie_trassy(v) for k, v in karty.items()},
    }, None


def zapisat_kartu(toy, nomer, karta):
    put = os.path.join(toy, 'pachki', str(nomer), 'karta.json')
    os.makedirs(os.path.dirname(put), exist_ok=True)
    with open(put, 'w', encoding='utf-8') as fh:
        json.dump(karta, fh, ensure_ascii=False)


def k_f06(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    gen, oshibka = generiruy(ctx, repo)
    if gen is None:
        return otkaz('%s: генератор динамических входов не собрал копию '
                     'референса: %s' % (P_LIVE, oshibka))
    try:
        # Ожидания зафиксированы В ПАМЯТИ до запуска субъекта. Зелёное ядро
        # карты без гейта 159 — честный отказ rc 2 NOT_IMPLEMENTED (И-8).
        zelenyj = sovmestnyj_zelenyj_rc()
        for faza, karta, ozhidanie_rc in (('A', 'A', zelenyj),
                                          ('B', 'B', 1),
                                          ('A2', 'A', zelenyj)):
            zapisat_kartu(gen['toy'], gen['N'], gen['karty'][karta])
            ish, zond = sovmestnaya_dver(gen['toy'], gen['repo'], gen['N'])
            if ish['rc'] != ozhidanie_rc:
                return krasnaya('ФАЗА %s: ожидался rc=%d, факт rc=%d'
                                % (faza, ozhidanie_rc, ish['rc']),
                                mark=ish.get('mark', []))
            if ozhidanie_rc == 2 and P_NOT_IMPL not in ish.get('pri', []):
                return krasnaya('ФАЗА %s: rc 2 без именованного отказа %s '
                                '(И-8)' % (faza, P_NOT_IMPL),
                                mark=ish.get('mark', []))
            if set(prefiks_stroki(t) for t in zond) != \
                    gen['ozhidaniya'][karta]:
                return krasnaya('%s: фаза %s — множество трассы не совпало'
                                % (P_ZOND_NE_ZAPUSHCHEN, faza),
                                mark=zond)
            if faza == 'B' and gen['Y'] not in ' '.join(zond):
                return krasnaya('%s: в трассе фазы B нет цели Y'
                                % P_ZOND_NE_ZAPUSHCHEN, mark=zond)
        return zelenaya()
    finally:
        shutil.rmtree(os.path.dirname(gen['repo']), ignore_errors=True)


def k_f07(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    gen, oshibka = generiruy(ctx, repo)
    if gen is None:
        return otkaz('%s: генератор динамических входов не собрал копию '
                     'референса: %s' % (P_LIVE, oshibka))
    try:
        zelenyj = sovmestnyj_zelenyj_rc()
        zapisat_kartu(gen['toy'], gen['N'], gen['karty']['B'])
        zapisat_kartu(gen['toy'], gen['M'], gen['karty']['B'])
        ishN, zondN = sovmestnaya_dver(gen['toy'], gen['repo'], gen['N'])
        ishM, zondM = sovmestnaya_dver(gen['toy'], gen['repo'], gen['M'])
        if ishN['rc'] != 1 or ishM['rc'] != 1:
            return krasnaya('НЕЗАВИСИМОСТЬ НОМЕРА: rc N=%d M=%d'
                            % (ishN['rc'], ishM['rc']))
        if set(prefiks_stroki(t) for t in zondN) != \
                set(prefiks_stroki(t) for t in zondM):
            return krasnaya('ТРАССЫ N И M РАЗНЫ',
                            mark=sorted(set(zondN) ^ set(zondM)))
        for karta, imya in (('A', 'N'), ('A', 'M')):
            zapisat_kartu(gen['toy'], gen[imya], gen['karty'][karta])
        ishN, zondN = sovmestnaya_dver(gen['toy'], gen['repo'], gen['N'])
        ishM, zondM = sovmestnaya_dver(gen['toy'], gen['repo'], gen['M'])
        if ishN['rc'] != zelenyj or ishM['rc'] != zelenyj:
            return krasnaya('КАРТА A: rc N=%d M=%d (ожидался %d)'
                            % (ishN['rc'], ishM['rc'], zelenyj))
        if zelenyj == 2 and (P_NOT_IMPL not in ishN.get('pri', []) or
                             P_NOT_IMPL not in ishM.get('pri', [])):
            return krasnaya('КАРТА A: rc 2 без именованного отказа %s (И-8)'
                            % P_NOT_IMPL)
        if set(prefiks_stroki(t) for t in zondN) != \
                set(prefiks_stroki(t) for t in zondM):
            return krasnaya('ТРАССЫ N И M РАЗНЫ НА КАРТЕ A',
                            mark=sorted(set(zondN) ^ set(zondM)))
        return zelenaya()
    finally:
        shutil.rmtree(os.path.dirname(gen['repo']), ignore_errors=True)


def k_f08(ctx):
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    gen, oshibka = generiruy(ctx, repo)
    if gen is None:
        return otkaz('%s: генератор динамических входов не собрал копию '
                     'референса: %s' % (P_LIVE, oshibka))
    try:
        sha_do = sha_fajla(os.path.join(ZDE, 'probe.py'))
        schet_do = len(ctx['orakul']['kejsy'])
        zelenyj = sovmestnyj_zelenyj_rc()
        for karta, ozhidanie_rc in (('A', zelenyj), ('B', 1), ('C', 1)):
            zapisat_kartu(gen['toy'], gen['N'], gen['karty'][karta])
            ish, zond = sovmestnaya_dver(gen['toy'], gen['repo'], gen['N'])
            if ish['rc'] != ozhidanie_rc:
                return krasnaya('КАРТА %s: rc=%d (ожидался %d)'
                                % (karta, ish['rc'], ozhidanie_rc))
            if ozhidanie_rc == 2 and P_NOT_IMPL not in ish.get('pri', []):
                return krasnaya('КАРТА %s: rc 2 без именованного отказа %s '
                                '(И-8)' % (karta, P_NOT_IMPL),
                                mark=ish.get('mark', []))
            if set(prefiks_stroki(t) for t in zond) != \
                    gen['ozhidaniya'][karta]:
                return krasnaya('%s: карта %s — трасса не совпала'
                                % (P_ZOND_NE_ZAPUSHCHEN, karta), mark=zond)
        sha_posle = sha_fajla(os.path.join(ZDE, 'probe.py'))
        if sha_do != sha_posle:
            return krasnaya('КОД НАБОРА ИЗМЕНИЛСЯ ПРИ ДОБАВЛЕНИИ ЭКРАНА')
        if schet_do != len(ctx['orakul']['kejsy']):
            return krasnaya('СЧЁТ КЛЕТОК ИЗМЕНИЛСЯ')
        return zelenaya()
    finally:
        shutil.rmtree(os.path.dirname(gen['repo']), ignore_errors=True)


def k_negativnyj(ctx, imya):
    """Негативный образец: мутатор на одноразовой копии референса."""
    mutator, ozhidanie = NEGATIVNYE[imya]
    repo = ctx.get('repo')
    if not repo:
        return otkaz('%s: референс не задан (живой суд — только с '
                     'референсом)' % P_LIVE)
    kopija, oshibka = zhivaya_kopiya(istochnik_ref_clean())
    if kopija is None:
        return otkaz('%s: %s' % (P_LIVE, oshibka))
    try:
        rc, out, err = zapusk_komandy(
            [sys.executable, os.path.join(ZDE, mutator), kopija], cwd=ZDE,
            timeout=300)
        if rc != 0:
            return otkaz('%s: мутатор %s не применён: %s'
                         % (P_LIVE, mutator, (err or out).strip()[:200]))
        ish = sudi_repo(kopija)
        return ish
    finally:
        shutil.rmtree(os.path.dirname(kopija), ignore_errors=True)


# ── Семья G — регрессии соседей ────────────────────────────────────────
def progoni_sosed(dver, flagi):
    put = os.path.join(KOREN, dver)
    if not os.path.isfile(put):
        return otkaz('%s: дверь соседа %s отсутствует' % (P_SUBJECT_ABSENT,
                                                           dver))
    rc, out, err = zapusk_komandy(['bash', dver] + list(flagi), cwd=KOREN,
                                   timeout=3600)
    if rc != 0:
        return krasnaya('СОСЕД КРАСЕН: rc=%d' % rc, mark=[out[-3000:],
                                                          err[-1000:]])
    return zelenaya()


def k_g08(ctx):
    dver = ('fixtures/workshop_project/pustoj_produkt_159/'
            'red_pustoj_produkt_159.sh')
    if not os.path.isfile(os.path.join(KOREN, dver)):
        return otkaz('%s: батарея 159 не заведена (порядок контракта: 159 '
                     'раньше 158)' % P_NOT_IMPL)
    for flagi in (['--model'], ['--stabs']):
        ish = progoni_sosed(dver, flagi)
        if ish['rc'] != 0:
            return ish
    return zelenaya()


# ── Реестр клеток ───────────────────────────────────────────────────────
KLETKI_FUNK = {
    'a01-trek-po-umolchaniju': k_a01,
    'a02-risk-bez-stroki': k_a02,
    'a03-risk-legkij': k_a03,
    'a04-risk-legkij-so-slovom': k_a04,
    'a05-polnyj-vsegda': k_a05,
    'a06-pereklyuchenie': k_a06,
    'a07-tochechnost': k_a07,
    'a08-grammatika': k_a08,
    'a09-dubl': k_a09,
    'a10-sloj-ispolnen-v-polnom': k_a10,
    'a11-sloj-krasen': k_a11,
    'a12-marker-vne-priemki': k_a12,
    'a13-marker-v-priemke': k_a13,
    'a14-sloj-vne-tablicy': k_a14,
    'z01-gate-v-dereve': k_z01,
    'z02-noga-pre-critic': k_z02,
    'b01-ostanovka-podtverzhdena': k_b01,
    'b02-zalipshij-390': k_b02,
    'b03-vtoroj-boot-port': k_b03,
    'b04-maksimum-dva-avd': k_b04,
    'b05-maska-48': k_b05,
    'b06-kanon-piny': k_b06,
    'b07-mutant-393-pri-390': k_b07,
    'c01-literal-nav-height': k_c01,
    'c02-literal-line-height': k_c02,
    'c03-literal-press-long': k_c03,
    'c04-ravnoe-chislo-bez-svjazi': k_c04,
    'c05-slezhenie': k_c05,
    'd01-karty-polny': k_d01,
    'd02-oracle-tamper': k_d02,
    'd03-pustoj-produkt': k_d03,
    'e01-soglasovano': k_e01,
    'e02-chisla-vne-teksta': k_e02,
    'f00-chestnyj-kontrol': k_f00,
    'f01-predposylka': k_f01,
    'f02-sposoby-zony': k_f02,
    'f03-sovmestnyj-chestnyj': k_f03,
    'f04-sovmestnyj-vykljuchennaja-tsel': k_f04,
    'f05-sovmestnyj-polnyj-sloj': k_f05,
    'f06-sovmestnyj-karta-iz-fajla': k_f06,
    'f07-sovmestnyj-nezavisimost-nomera': k_f07,
    'f08-sovmestnyj-dobavlenie-dannyh': k_f08,
    'g01-147-model': lambda ctx: progoni_sosed(
        SOSTEDY['g01-147-model'][0], SOSTEDY['g01-147-model'][1]),
    'g02-147-stabs': lambda ctx: progoni_sosed(
        SOSTEDY['g02-147-stabs'][0], SOSTEDY['g02-147-stabs'][1]),
    'g03-148-model': lambda ctx: progoni_sosed(
        SOSTEDY['g03-148-model'][0], SOSTEDY['g03-148-model'][1]),
    'g04-148-stabs': lambda ctx: progoni_sosed(
        SOSTEDY['g04-148-stabs'][0], SOSTEDY['g04-148-stabs'][1]),
    'g05-149-model': lambda ctx: progoni_sosed(
        SOSTEDY['g05-149-model'][0], SOSTEDY['g05-149-model'][1]),
    'g06-149-stabs': lambda ctx: progoni_sosed(
        SOSTEDY['g06-149-stabs'][0], SOSTEDY['g06-149-stabs'][1]),
    'g07-143-stabs': lambda ctx: progoni_sosed(
        SOSTEDY['g07-143-stabs'][0], SOSTEDY['g07-143-stabs'][1]),
    'g08-159': k_g08,
}
for _imya in list(NEGATIVNYE):
    KLETKI_FUNK[_imya] = (lambda imya: lambda ctx: k_negativnyj(ctx, imya))(
        _imya)


def zapustit_kletku(imya, ctx):
    """Запускает клетку; возвращает её исход."""
    funk = KLETKI_FUNK[imya]
    return funk(ctx)


# ── Суд: ожидание (оракул) против факта ─────────────────────────────────
def gate_159_est():
    return os.path.isfile(os.path.join(SKRIPTY, 'check_pustoj_produkt.sh'))


def battereya_159_est():
    return os.path.isfile(os.path.join(
        KOREN, 'fixtures', 'workshop_project', 'pustoj_produkt_159',
        'red_pustoj_produkt_159.sh'))


def ozhidanie(orakul, imya):
    """Ожидаемый исход клетки по оракулу (с учётом состояния дерева)."""
    zapis = orakul['kejsy'][imya]
    uslovie = zapis.get('uslovie')
    if uslovie:
        kak = uslovie.get('kak')
        est = None
        if kak == 'gate_159':
            est = gate_159_est()
        elif kak == 'battereya_159':
            est = battereya_159_est()
        if est is False:
            alt = uslovie.get('bez')
            if alt is not None:
                merged = dict(zapis)
                merged.update(alt)
                merged.pop('uslovie', None)
                return merged
    return zapis


def sudit(orakul, imya, akt):
    """Сравнивает факт с ожиданием; возвращает список расхождений."""
    zapis = ozhidanie(orakul, imya)
    problemy = []
    if akt['rc'] != zapis.get('rc'):
        prichiny_fakta = ', '.join(akt.get('pri', [])) or '—'
        problemy.append('ожидался rc=%s, факт rc=%s (причины факта: %s)'
                        % (zapis.get('rc'), akt['rc'], prichiny_fakta))
    for p in zapis.get('pri', []):
        if p not in akt.get('pri', []):
            problemy.append('нет причины %s (факт: %s)'
                            % (p, ', '.join(akt.get('pri', [])) or '—'))
    for mark in zapis.get('markery', []):
        if not any(mark in s for s in akt.get('mark', [])):
            problemy.append('нет маркера %s' % mark)
    return problemy


# Клетки, чей субъект — артефакт ДЕРЕВА (гейт трека, нога двери, батарея
# 159). В режимах эталона (--model/--stabs) такие клетки не строятся: там
# субъект — эталон батареи, а не дерево; в безфлаговом режиме они строятся и
# дают честную красноту SUBJECT_ABSENT/NOT_IMPLEMENTED.
KLETTKI_SUBJEKT_DEREVA = ('z01-gate-v-dereve', 'z02-noga-pre-critic',
                          'g08-159')


# Живые клетки (нужен референс станции): семья F + слежение за токеном.
KLETTKI_ZHIVYE = ('c05-slezhenie',)


def stroit_cell(imya, rezhim):
    """Строится ли клетка в этом режиме.

    SPEC §1 (версия v+1, контракт 158/2 п.7): живые клетки F и слежение
    c05 строятся ТОЛЬКО при явном `--repo <R>`; без флага они не строятся
    (безфлаговый W — суд дерева харнесса, rc 0; отсутствие R не является
    неисправностью продукта). В `--repo` при недоступном или непригодном
    R клетка отказывает rc 2 LIVE_PREDPOSYLKA (не skip→pass).
    """
    zhivye = imya.startswith('f') or imya in KLETTKI_ZHIVYE
    if zhivye:
        return rezhim == 'repo'
    if rezhim in ('model', 'stabs'):
        return imya not in KLETTKI_SUBJEKT_DEREVA
    return True


# ── Стабы (SPEC §7): привязка стаб↔ветвь — КОДОМ probe.py ─────────────
def zapustit_stab(stub, kletka, ctx):
    """Запускает стаб как субъекта клетки; исход или None (нечем проверить)."""
    cmd = [sys.executable, os.path.join(STABY, stub), '--cell', kletka]
    if ctx.get('repo'):
        cmd += ['--repo', ctx['repo']]
    rc, out, err = zapusk_komandy(cmd, cwd=KOREN, timeout=3600)
    stroki = [s for s in out.strip().splitlines() if s.strip()]
    if not stroki:
        return None
    try:
        dannye = json.loads(stroki[-1])
    except ValueError:
        return None
    return ishod(dannye.get('rc', 2), dannye.get('pri', []),
                 dannye.get('mark', []))


def progoni_staby(orakul, ctx):
    """Матрица обманных стабов: каждый отклонён на СВОИХ входах.

    Падение стаба (исход ISPOLNIMYJ_INFRA) — НЕ поимка: это «нечем проверить»,
    а не наблюдённое расхождение исхода с эталоном. Такой стаб остаётся
    НЕПОЙМАННЫМ → STAB_ZHIV (rc 1), пока не починен.

    Отсутствие ЖИВОГО субъекта (rc 2 LIVE_PREDPOSYLKA) — тоже «нечем проверить»:
    поимки не было, и зелёным это НЕ проходит. Незамеченный стаб — rc 1
    STAB_ZHIV (SPEC §1, §7) с названной причиной в строке стаба.
    """
    zhivye = []
    svjazi = 0
    net_subjekta = False
    for stub, vhody in sorted(orakul['stab_vhod'].items()):
        lozhenny = False
        for kletka in vhody:
            svjazi += 1
            akt = zapustit_stab(stub, kletka, ctx)
            if akt is None:
                print('STAB %s %s НЕПРОВЕРЕН' % (stub, kletka))
                continue
            if akt.get('rc') == 2:
                # rc 2 — «нечем проверить»: поимки нет (расхождения исхода с
                # эталоном не наблюдалось) и зелёным это НЕ проходит.
                chasti = list(akt.get('pri', [])) + list(akt.get('mark', []))
                padalo = '; '.join(chasti) or '—'
                if any(P_LIVE in p for p in akt.get('pri', [])):
                    net_subjekta = True
                    print('STAB %s %s НЕПРОВЕРЕН: нет живого субъекта (%s)'
                          % (stub, kletka, padalo))
                else:
                    print('STAB %s %s НЕПРОВЕРЕН: стаб упал (%s)'
                          % (stub, kletka, padalo))
                continue
            if sudit(orakul, kletka, akt):
                lozhenny = True
                print('STAB %s %s KRASEN' % (stub, kletka))
            else:
                print('STAB %s %s PROSHYOL' % (stub, kletka))
        if not lozhenny:
            zhivye.append(stub)
            print('STAB %s PROSHYOL' % stub)
        else:
            print('STAB %s KRASEN' % stub)
    print('SVJAZI %d' % svjazi)
    return zhivye, net_subjekta


# ── Точка входа стаба ───────────────────────────────────────────────────
def zapustit_stab_kletku(argv):
    """Вход стаба: стаб патчит probe и зовёт эту функцию."""
    ap = argparse.ArgumentParser()
    ap.add_argument('--cell', required=True)
    ap.add_argument('--repo')
    ap.add_argument('--toy')
    a = ap.parse_args(argv)
    orakul, oshibka = chit_orakul()
    if orakul is None:
        print(json.dumps(ishod(2, [P_ORACLE], [oshibka]), ensure_ascii=False))
        return 0
    ctx = {'orakul': orakul, 'rezhim': 'stabs', 'repo': a.repo}
    try:
        try:
            akt = zapustit_kletku(a.cell, ctx)
        except Exception as exc:  # noqa: BLE001 — стаб не должен ронять батарею
            akt = ishod(2, ['ISPOLNIMYJ_INFRA'],
                        ['%s: %s' % (type(exc).__name__, exc)])
        print(json.dumps(akt, ensure_ascii=False))
        return 0
    finally:
        # Уборка временных каталогов — и здесь: вход стаба идёт отдельным
        # процессом, уборка __main__ его не накрывает (С-11 ревью 158).
        ubrat_vremennye()


# ── Главный вход ────────────────────────────────────────────────────────
def postroit_kontekst(orakul, rezhim, repo=None):
    return {'orakul': orakul, 'rezhim': rezhim, 'repo': repo}


def progoni_kletki(orakul, ctx):
    """Прогон клеток; возвращает (зелёных, красных)."""
    zelenyh, krasnyh = 0, 0
    for imya in KLETKI:
        if not stroit_cell(imya, ctx['rezhim']):
            continue
        try:
            akt = zapustit_kletku(imya, ctx)
        except Exception as exc:  # noqa: BLE001 — сбой клетки — именованный
            akt = ishod(2, [P_INFRA], ['%s: %s' % (type(exc).__name__, exc)])
        problemy = sudit(orakul, imya, akt)
        if problemy:
            krasnyh += 1
            print('CASE %s KRASNO: %s' % (imya, '; '.join(problemy)))
        else:
            zelenyh += 1
            print('CASE %s ok' % imya)
    print('клеток %d, зелёных %d, красных %d'
          % (zelenyh + krasnyh, zelenyh, krasnyh))
    return zelenyh, krasnyh


def main(argv=None):
    ap = argparse.ArgumentParser(
        description='батарея набора ekrannyj_nabor_158 (SPEC §1)')
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--repo', metavar='R')
    ap.add_argument('--ekran', metavar='NNN')
    ap.add_argument('--oracle-tamper', action='store_true')
    # Заявленных флагов — пять (SPEC §1); незаявленный → отказ argparse rc 2.
    a = ap.parse_args(argv)
    if a.oracle_tamper:
        # порча оракула — ДО клеток (клетка d02)
        vrem = vremennyy_katalog('nabor158-tamper-')
        try:
            kopija = os.path.join(vrem, 'bateria')
            shutil.copytree(ZDE, kopija,
                            ignore=shutil.ignore_patterns('__pycache__'))
            put = os.path.join(kopija, 'source.json')
            with open(put, encoding='utf-8') as fh:
                orakul = json.load(fh)
            orakul['piny']['nositeli'] = dict(orakul['piny']['nositeli'])
            klyuch = sorted(orakul['piny']['nositeli'])[0]
            orakul['piny']['nositeli'][klyuch] = '0' * 64
            with open(put, 'w', encoding='utf-8') as fh:
                json.dump(orakul, fh, ensure_ascii=False)
            _orakul, oshibka = chit_orakul(kopija)
            if oshibka is None:
                print('%s: порча оракула не обнаружена' % P_ORACLE,
                      file=sys.stderr)
                return 2
            print('%s: %s' % (P_ORACLE, oshibka), file=sys.stderr)
            return 2
        finally:
            shutil.rmtree(vrem, ignore_errors=True)
    if a.ekran and a.repo:
        # совместный режим: гейт 159 первым (И-8), затем ядро
        rc, vyvod = geyt_159(a.repo)
        gate_net = (rc == 2)
        if gate_net:
            print(vyvod, file=sys.stderr)
        elif rc != 0:
            # гейт отказал (пустой продукт) — отказ ДО собственных клеток
            print(vyvod, file=sys.stderr)
            return rc
        ish = sovmestnyj_rezhim(a.repo, int(a.ekran))
        for s in ish.get('mark', []):
            print(s)
        if ish['rc']:
            for p in ish.get('pri', []):
                print('ПРИЧИНА %s' % p)
            return ish['rc']
        if gate_net:
            print('%s: гейт 159 отсутствует в дереве — совместный режим '
                  'не зелёный (И-8)' % P_NOT_IMPL, file=sys.stderr)
            return 2
        print('ЭКРАН %s: СОВМЕСТНЫЙ РЕЖИМ ЗЕЛЁНЫЙ' % a.ekran)
        return 0
    if a.ekran:
        return ekran_rezhim(int(a.ekran))
    orakul, oshibka = chit_orakul()
    if orakul is None:
        print('%s: %s' % (P_ORACLE, oshibka), file=sys.stderr)
        return 2
    gate_net = False
    if a.repo:
        rc, vyvod = geyt_159(a.repo)
        if rc == 2:
            gate_net = True
            print(vyvod, file=sys.stderr)
        elif rc != 0:
            # гейт 159 отказал (пустой продукт) — отказ ДО собственных клеток
            print(vyvod, file=sys.stderr)
            return rc
        # Живая предпосылка: без неё суд невозможен — fail-closed (rc 2),
        # а не «красная клетка» (rc 1) и никогда зелень.
        zhivaya = sudi_repo(a.repo)
        if zhivaya['rc'] == 2:
            for p in zhivaya.get('pri', []):
                print('ПРИЧИНА %s' % p)
            return 2
    rezhim = 'model' if a.model else ('stabs' if a.stabs else 'repo'
                                       if a.repo else 'bare')
    repo = a.repo
    if rezhim == 'stabs' and not repo:
        # стабы живут на живом референсе станции (без него их нечем проверять)
        repo = REFERENSI[0][1]
    ctx = postroit_kontekst(orakul, rezhim, repo=repo)
    if a.stabs:
        kontrol = postroit_kontekst(orakul, 'model', repo=repo)
        zelenyh, krasnyh = progoni_kletki(orakul, kontrol)
        zhivye, net_subjekta = progoni_staby(orakul, ctx)
        if zhivye:
            prichina = (' (живой субъект станции отсутствует — проверять нечем)'
                        if net_subjekta else '')
            print('%s: %s%s' % (P_STAB_ZHIV, ', '.join(zhivye), prichina),
                  file=sys.stderr)
            return 1
        return 0 if krasnyh == 0 else 1
    zelenyh, krasnyh = progoni_kletki(orakul, ctx)
    if krasnyh:
        return 1
    if gate_net:
        # гейт 159 не заведён (И-8): ветвь не зелёная, даже если клетки зелёные
        print('%s: гейт 159 отсутствует в дереве — ветвь --repo не '
              'зелёная (И-8)' % P_NOT_IMPL, file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    finally:
        ubrat_vremennye()



