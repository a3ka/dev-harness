#!/usr/bin/env python3
"""Батарея 146 (shablon-dvizhenie, 132 v3): раздел «движение» в шаблоне
экранного контракта — блок dvizhenie формы ekran.json (shablon: 3) и ветка
валидатора. СУБЪЕКТ — scripts/ekran_shablon.py (живой валидатор харнесса);
ЭТАЛОН поведения — model/ekran_shablon.py (v3: поведение v1/v2 + ветка
dvizhenie); стабы stubs/s45–s80 подменяют ровно свою ветвь эталона (Н-39:
дефект стаба наблюдаем на входе его записи stab_vhod в source.json).

Режимы (обёртка передаёт аргументом; движок/оракул/перечень входов —
probe.py и source.json рядом, единый источник):
  (без флага)  python3 probe.py            — red-режим: субъект судится
             живьём; ДОСЛОВНЫЙ ПОРТ (B.8): scripts/ekran_shablon.py
             обязан быть байт-в-байт равен model/ekran_shablon.py —
             иначе именованный PORT_NE_DOOSLOVEN (честный красный до
             пачки implementer, не ошибка канона)
  --model      эталон (контроль входов; ожидания — kejsy source.json,
             для вычислимых клеток — прогон эталона ДО субъекта)
  --stabs      контроль + матрица обманных стабов (SVJAZI N, живых 0)
  --snapshot   фактические rc/вывод эталона по каждому входу (замер)
  --d24-real R реальный канон (B.10): пины kontekst сверяются с байтами
             трёх реальных источников R (A.6), честный контроль всех
             сцен/треков, затем КОНЕЧНОЕ СТРУКТУРНОЕ ПОКРЫТИЕ семей
             A.3–A.5 по реальному корпусу прямым вызовом _grammatika_sceny
             (ожидаемые/исполненные адреса — полными множествами) +
             сеяная атака значения на каждой сцене
  --differencial R  дифференциал совместимости (C.11): статическая
             граница трёх версий валидатора (frozen 132/2 v1, v2-база
             родителя коммита, v3-эталон) на ДВУХ реальных пачках
             продукта (perехват только run_priemka_e2e —
             STATIC_BOUNDARY_REACHED; E2E_NOT_RUN) + равенство v2/v3
             на честной v2-форме слайса-1
  --oracle-tamper  самопроба оракула (A.6): порча КАЖДОГО доверенного
             носителя piny.nositeli в одноразовой копии — ORACLE_TAMPERED
             rc 2 ДО клеток
  --seed N     seed сеяного распределения дефектов по объявленным
             переходам (дефолт 146). Seed меняет значения/порядок, НО НЕ
             структурное покрытие: полнота обеспечена каталогом адресов
             (katalog_i_pokrytie) и семьями «все адреса разом», чьи
             ожидания — ПОЛНЫЕ множества причин от эталона.

ПОКРЫТИЕ — КАТАЛОГ АДРЕСОВ, НЕ ПРОЕКЦИЯ (A.1 арбитража 146): до клеток
katalog_i_pokrytie строит из доверенных данных конечный каталог адресов
(источники; экраны; переходы; сцены; трек pid:i; правило/поле; процент;
тема×вид; индекс пина) и проверяет, что каждая семья действительно
затрагивает РОВНО своё ожидаемое множество адресов (пустая семья,
пропуск адреса, лишний адрес, неприменившаяся мутация — ORACLE_TAMPERED
rc 2). Семьи «vse-treki/vse-sceny/vse-temy» ломят КАЖДЫЙ адрес оси разом
и сравниваются ПОЛНЫМИ множествами причин (A.3: объединение однотипных
ошибок допускается только с поимённым различением каждого затронутого
адреса); где протокол не несёт индекс (темы files, проценты набора),
адресность входа обеспечивает одиночный изменённый лист (A.7).

МАТРИЦА «ПОЛЕ × МУТАЦИЯ» (Crit146c, слово владельца 30.10 «А»): общий
мутационный проход по КАЖДОМУ семейству полей шаблона — удаление/пустое
значение/чужой тип/перестановка/подмножество; перечень полей — ИЗ КОДА
ЭТАЛОНА (FORMA_KEYS_V3/KLJUCHI_DVIZHENIE/POLJA_TREKA/TEMY_ETF загружаются
модулем; поля сцены — по чтению sc.get(...) в коде эталона), не ручной
набор; каждая красная комбинация обязана краснеть ИМЕНОВАННОЙ причиной
(заявление rc+правила сверяется с фактом эталона ДО субъекта), каждая
конформная — зелёный свидетель, каждый изъятый класс перечислен с
обоснованием; у КАЖДОГО поля ≥1 красная комбинация (katalog_i_pokrytie).

Ожидания вычислимых клеток считает ЭТАЛОН в памяти ДО субъекта (правило 8)
и оракул требует: именованное правило семьи, отказ, называющий РОВНО
ожидаемое множество адресов, отсутствие traceback (краш эталона — ошибка
оракула, никогда пойманный стаб; B.9). Кеш различает весь вход (хеш
байтов пачки+источников), seed и клетку; с диска субъекта ожидания не
перечитываются.

Коды возврата: 0 — зелено; 1 — красный вход / стаб жив / нет субъекта /
PORT_NE_DOOSLOVEN; 2 — нечем проверить (нет python3, ORACLE_TAMPERED,
рассинхрон стабов, SVERKA_123_ABSENT). Числа клеток/стабов/связей — из
source.json, сверяются второй мерой (grep по файлам стабов и ключам
kejsy/stab_vhod).
"""
import argparse
import copy
import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import types
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
SUBJECT = H_ROOT / 'scripts' / 'ekran_shablon.py'
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
MODEL = HERE / 'model' / 'ekran_shablon.py'
STUBS = HERE / 'stubs'
FIKT = ('fixtures/workshop_project/shablon_dvizhenie_146'
        '/model/fiktura')
D24_NOS = HERE / 'nositeli' / 'd24'
# Честные команды пачки (прецедент 132): фактический argv, cwd = репо.
E2E_CMD = 'bash mobile/e2e.sh gespraech-mitte'
SVJAZI_SVERKI = ('python3 .harness123/scripts/sverka_maketa.py'
                 ' --manifest .harness123/kadry.json'
                 ' --kadry mobile/maestro-out-gespraech --repo .')
PROKHOD_CMD = 'bash mobile/prokhod.sh mobile/.maestro/prokhod-gespraech-mitte.yaml'
DVIZHENIE_CMD = ('python3 mobile/dvizhenie-stand-in.py --json'
                 ' --outputFile mobile/dvizhenie-otchet.json')
STARYJ_FIKT = str(HERE / 'model' / 'fiktura')
# Актуальная v2-база реализации (C.11.3 арбитража 146): scripts/ekran_shablon.py
# родителя коммита батареи. Замена базы — только явной записью здесь.
V2_BAZA_SHA256 = '0285a02c89aa9c3afb49e2596615273a511fde7eb9cf3d5c81d1a64a90aaac84'
V1_FROZEN_SHA256 = '46807deb4c553700b7e485a607882b384a55df73a5f28e0b7b74a63c64bba994'
TEMY = ('dark', 'dark_reduced', 'light', 'light_reduced')
PROCENTY = ('0', '25', '50', '75', '100')

# Seed сеяного распределения дефектов грамматики по объявленным
# переходам (ротация; судья меняет --seed — прецедент p14/p15, 145).
SEED_DEFOLT = 146

def _zagruzhi_model():
    """Эталон как модуль: перечень полей матрицы — ИЗ КОДА ЭТАЛОНА
    (FORMA_KEYS_V3/KLJUCHI_DVIZHENIE/POLJA_TREKA/TEMY_ETF), не ручной
    набор (Crit146c: доказательство полноты — перечнем из кода)."""
    spec = importlib.util.spec_from_file_location('et_model_146r', MODEL)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


_M = _zagruzhi_model()
FORMA_POLEJ_V3 = sorted(_M.FORMA_KEYS_V3 - {'dvizhenie'})
DV_POLEJ = sorted(_M.KLJUCHI_DVIZHENIE)
POLEJ_TREKA = sorted(_M.POLJA_TREKA)
TEMY_ETF = _M.TEMY_ETF
# Поля сцены — по чтению в коде эталона (sc.get('<поле>')): перечень
# привязан к единственному источнику; исчезновение поля из кода эталона
# — ORACLE_TAMPERED при загрузке батареи.
SCENA_POLEJ = ('files', 'keyframes_ms', 'tracks', 'window_ms')
_KOD_ETALONA = MODEL.read_text(encoding='utf-8')
for _sp in SCENA_POLEJ:
    if ("sc.get('%s')" % _sp) not in _KOD_ETALONA:
        raise SystemExit('ORACLE_TAMPERED: поле сцены %s не читается '
                         'кодом эталона' % _sp)


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def sha256_fajla(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()


# --- оракул ------------------------------------------------------------------

def load_source():
    """source.json + защита оракула: пины носителей, согласованность
    стабов (файлы stubs/ == ключи stab_vhod), согласованность пинов
    формы D 2.4 с байтами носителей (форма пачки честно пинит СВОИ
    источники фиктивного репо — пин обязан совпасть с носителем)."""
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    imejutsa = sorted(p.name for p in STUBS.glob('*.py') if p.name[0] != '_')
    if imejutsa != sorted(src['stab_vhod']):
        print('ORACLE_TAMPERED: stubs/ != stab_vhod (%s)' % imejutsa,
              file=sys.stderr)
        raise SystemExit(2)
    for rel, pin in src['piny']['nositeli'].items():
        p = HERE / rel
        if not p.is_file() or sha256_fajla(p) != pin:
            print('ORACLE_TAMPERED: носитель %s' % rel, file=sys.stderr)
            raise SystemExit(2)
    d24 = src['ekran_forma_d24']['dvizhenie']
    for pole, nos in (('manifest_sha256', 'manifest.json'),
                      ('spec_sha256', 'spec.json'),
                      ('pozvonok_sha256', 'poses.json')):
        if d24[pole] != src['piny']['nositeli']['nositeli/d24/' + nos]:
            print('ORACLE_TAMPERED: пин формы %s != носитель %s'
                  % (pole, nos), file=sys.stderr)
            raise SystemExit(2)
    if set(src['kejsy']) != {k for k in MUTACII if k}:
        print('ORACLE_TAMPERED: kejsy != MUTACII probe.py', file=sys.stderr)
        raise SystemExit(2)
    for stub, vhody in src['stab_vhod'].items():
        for v in vhody:
            if v not in src['kejsy']:
                print('ORACLE_TAMPERED: stab_vhod %s -> неизвестный вход %s'
                      % (stub, v), file=sys.stderr)
                raise SystemExit(2)
    flag = sorted(k for k, z in src['kejsy'].items()
                  if z.get('vychisljaemyj'))
    if flag != sorted(VYCHISLJAEMYE):
        print('ORACLE_TAMPERED: vychisljaemyj в source.json != probe.py '
              '(%s)' % flag, file=sys.stderr)
        raise SystemExit(2)
    return src


# --- построение входа ---------------------------------------------------------

def zapis(pack, forma):
    (pack / 'ekran.json').write_text(
        json.dumps(forma, ensure_ascii=False, indent=1), encoding='utf-8')


def _d24_istochniki(repo: Path):
    """Источники движения фиктивного репо (батарейные носители,
    пинннуемые формой пачки): манифест/спека/поз + макеты PNG по путям
    манифеста (кадры e2e-станд-ина байт-в-байты равны макетам своей
    темы/экрана — сверка 123 честно зелёная)."""
    pak = repo / 'docs/ux/04_Gespraech_D24/pack'
    (pak / 'screens/390x844').mkdir(parents=True)
    shutil.copyfile(D24_NOS / 'kadry/gespraech-tabshell.png',
                    pak / 'screens/390x844/GA-01-tabshell.png')
    shutil.copyfile(D24_NOS / 'manifest.json',
                    pak / 'gespraech-final2-manifest.json')
    for imja in ('GA-01', 'GA-01-Hell', 'GA-15', 'GA-15-Hell',
                 'GA-16', 'GA-16-Hell'):
        shutil.copyfile(D24_NOS / ('maket/' + imja + '.png'),
                        pak / ('screens/390x844/' + imja + '.png'))
    mot = repo / 'docs/ux/04_Gespraech_D24/motion'
    mot.mkdir(parents=True)
    shutil.copyfile(D24_NOS / 'spec.json',
                    mot / 'motion-spec-gespraech.json')
    shutil.copyfile(D24_NOS / 'poses.json',
                    mot / 'faden-poses-gespraech.json')


def build_repo(src, tmp, pack, d24=True):
    repo = tmp / 'repo'
    scr = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens'
    scr.mkdir(parents=True)
    shutil.copyfile(HERE / 'nositeli/maket/Splash.png', scr / 'Splash.png')
    shutil.copyfile(HERE / 'nositeli/maket/Splash-Hell.png',
                    scr / 'Splash-Hell.png')
    ds = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/ds'
    ds.mkdir(parents=True)
    (ds / 'tokens.css').write_text(src['tokens_audit'], encoding='utf-8')
    kat = repo / 'docs/ux/01_UX_Source_of_Truth'
    kat.mkdir(parents=True)
    (kat / 'BrokerOS_UI_Copy_DE.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    api = repo / 'api'
    api.mkdir(parents=True)
    (api / 'openapi.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    ma = repo / 'mobile/.maestro'
    ma.mkdir(parents=True)
    (ma / 'demo-vkhod.yaml').write_text(src['flow'], encoding='utf-8')
    (ma / 'gespraech-mitte.yaml').write_text(
        src['d24_teksty']['flow'], encoding='utf-8')
    (ma / 'gespraech-mitte-tabshell.yaml').write_text(
        src['d24_teksty']['flow_profil'], encoding='utf-8')
    (ma / 'prokhod-gespraech-mitte.yaml').write_text(
        src['d24_teksty']['prokhod_flow'], encoding='utf-8')
    (ma / 'prokhod-demo-vkhod.yaml').write_text(src['prokhod_flow'],
                                                encoding='utf-8')
    (ma / 'demo-vkhod-tabshell.yaml').write_text(src['flow_profil'],
                                                 encoding='utf-8')
    (repo / 'mobile/e2e.sh').write_text(src['e2e_skript'],
                                        encoding='utf-8')
    (repo / 'mobile/prokhod.sh').write_text(src['prokhod_skript'],
                                            encoding='utf-8')
    for tema in ('dark', 'light'):
        d = repo / 'mobile/e2e-nositeli' / tema
        d.mkdir(parents=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/r1423-%s-vkhod-117-splash.png' % tema),
            d / (src['snimok'] + '.png'))
        shutil.copyfile(HERE / ('nositeli/kadry/r1423-%s-vkhod-117-splash.png'
                                % tema),
                        d / 'vkhod-demo-tabshell.png')
    for tema in ('dark', 'light'):
        d = repo / 'mobile/e2e-nositeli' / tema
        for ek in ('ga-01', 'ga-15', 'ga-16'):
            shutil.copyfile(D24_NOS / ('kadry/gespraech-%s.png' % ek),
                            d / ('gespraech-%s.png' % ek))
        shutil.copyfile(D24_NOS / 'kadry/gespraech-tabshell.png',
                        d / 'gespraech-tabshell.png')
    (repo / 'mobile/maestro-out-demo').mkdir(parents=True)
    (repo / 'mobile/maestro-out-gespraech').mkdir(parents=True)
    if d24:
        _d24_istochniki(repo)
        # stand-in численной приёмки движения (репо, не пачка): честный
        # вариант пишет СВЕЖИЙ отчёт jest-формы; мутанты заменяют скрипт
        (repo / 'mobile/dvizhenie-stand-in.py').write_text(
            src['d24_teksty']['dvizhenie_skripty']['chestnyj'],
            encoding='utf-8')
    pin123 = repo / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pack / 'kadry.json', pin123 / 'kadry.json')
    return repo


def build_pack(src, tmp):
    """Пачка слайса-1 (v2, кадры без GA-якорей): зелёный контроль
    обратной совместимости — ветка dvizhenie инертна, ожидания как у
    132 (регресс-часовой батареи 146 для живого скрипта)."""
    pack = tmp / 'pack'
    pack.mkdir()
    forma = json.loads(json.dumps(src['ekran_forma']))
    zapis(pack, forma)
    (pack / 'kadry.json').write_text(
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pack / forma['vtoroj_profil']['kadry']).write_text(
        json.dumps(src['profil_kadry'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pack / 'kontrakt.md').write_text(src['kontrakt_tekst'],
                                      encoding='utf-8')
    b = pack / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'],
                                     encoding='utf-8')
    return pack, forma


def build_pack_d24(src, tmp):
    """Честная пачка НОВОГО экрана D 2.4 (shablon 3 + dvizhenie):
    GA-01/GA-15/GA-16, переходы T28/T31/T29/T35/T36 (полное ∩-множество
    фиктивного манифеста; T36 касается пачки ТОЛЬКО вторым кадром — ∩
    обязан считаться по всем frames), сцены знака T29/T35 (у T28/T31/T36
    поз-оракула нет; поза GA-T20 в носителе — чужая переходам пачки),
    эталоны 4 темы × 5 кадров + 4 видео на переход, приёмка движения
    с отчётом jest-формы."""
    pack = tmp / 'pack'
    pack.mkdir()
    forma = json.loads(json.dumps(src['ekran_forma_d24']))
    zapis(pack, forma)
    (pack / 'kadry.json').write_text(
        json.dumps(src['d24_teksty']['kadry_manifest'], ensure_ascii=False,
                   indent=1),
        encoding='utf-8')
    (pack / forma['vtoroj_profil']['kadry']).write_text(
        json.dumps(src['d24_teksty']['profil_kadry'], ensure_ascii=False,
                   indent=1),
        encoding='utf-8')
    (pack / 'kontrakt.md').write_text(src['d24_teksty']['kontrakt'],
                                      encoding='utf-8')
    b = pack / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['d24_teksty']['batareja'],
                                     encoding='utf-8')
    return pack, forma


# --- мутации входов (код, не проза; ожидания — kejsy source.json) ------------

def _forma_d24(pack):
    return json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))


def _smena_skripta(repo, src, imja):
    (repo / 'mobile/dvizhenie-stand-in.py').write_text(
        src['d24_teksty']['dvizhenie_skripty'][imja], encoding='utf-8')


def mut_shablon3_bez_dvizhenija(pack, forma, repo, src):
    del forma['dvizhenie']
    zapis(pack, forma)


def mut_ga_pachka_na_shablone2(pack, forma, repo, src):
    del forma['dvizhenie']
    forma['shablon'] = 2
    zapis(pack, forma)


def mut_dvizhenie_na_shablone2(pack, forma, repo, src):
    forma['shablon'] = 2
    zapis(pack, forma)


def mut_priemka_s_lishnim_kljuchom(pack, forma, repo, src):
    forma['priemka']['dvizhenie'] = DVIZHENIE_CMD
    zapis(pack, forma)


def mut_ekrany_vne_manifesta(pack, forma, repo, src):
    forma['dvizhenie']['ekrany'].append('GA-99')
    zapis(pack, forma)


def mut_ekran_bez_kadrov(pack, forma, repo, src):
    forma['dvizhenie']['ekrany'].append('GA-34')
    zapis(pack, forma)


def mut_perehod_vne_manifesta(pack, forma, repo, src):
    forma['dvizhenie']['perehody'].append('GA-T99')
    zapis(pack, forma)


def mut_perehod_lishnij(pack, forma, repo, src):
    forma['dvizhenie']['perehody'].append('GA-T20')
    zapis(pack, forma)


def mut_scena_vne_orakula(pack, forma, repo, src):
    forma['dvizhenie']['sceny_znaka'].append('GA-T28')
    zapis(pack, forma)


def mut_etalony_bez_pina(pack, forma, repo, src):
    """B.9: у перехода нет ЭТАЛОНА вовсе — именованный ETALON_BEZ_PINOV
    БЕЗ последующего индексирования отсутствующего ключа (прежний краш
    KeyError замаскирован был ложным оракулом rc=1/prichiny=[])."""
    del forma['dvizhenie']['etalony']['GA-T31']
    zapis(pack, forma)


def mut_etalony_ne_polny(pack, forma, repo, src):
    forma['dvizhenie']['etalony']['GA-T28']['keyframes']['dark'].pop()
    zapis(pack, forma)


def mut_etalon_ne_hex(pack, forma, repo, src):
    forma['dvizhenie']['etalony']['GA-T28']['keyframes']['dark'][0] = 'zz' * 32
    zapis(pack, forma)


def mut_etalon_lishnij(pack, forma, repo, src):
    forma['dvizhenie']['etalony']['GA-T20'] = json.loads(
        json.dumps(forma['dvizhenie']['etalony']['GA-T28']))
    zapis(pack, forma)


def mut_etalon_tema_otsutstvuet(pack, forma, repo, src):
    del forma['dvizhenie']['etalony']['GA-T28']['keyframes']['light_reduced']
    zapis(pack, forma)


def mut_video_etalon_ne_polon(pack, forma, repo, src):
    del forma['dvizhenie']['etalony']['GA-T28']['video']['dark_reduced']
    zapis(pack, forma)


def mut_priemka_bez_otcheta(pack, forma, repo, src):
    forma['dvizhenie']['priemka_dvizhenija'] = (
        'python3 mobile/dvizhenie-stand-in.py')
    zapis(pack, forma)


def mut_priemka_ne_proshla(pack, forma, repo, src):
    _smena_skripta(repo, src, 'padaet')


def mut_otchet_otsutstvuet(pack, forma, repo, src):
    _smena_skripta(repo, src, 'molchit')


def mut_otchet_ustarevshij(pack, forma, repo, src):
    _smena_skripta(repo, src, 'molchit')
    (repo / 'mobile/dvizhenie-otchet.json').write_text(
        src['d24_teksty']['otchety']['chestnyj'], encoding='utf-8')


def mut_otchet_s_provalami(pack, forma, repo, src):
    _smena_skripta(repo, src, 's_provalami')


def mut_otchet_pustoj(pack, forma, repo, src):
    _smena_skripta(repo, src, 'pustoj')


def mut_otchet_ne_chitaetsja(pack, forma, repo, src):
    _smena_skripta(repo, src, 'musor')


def mut_otchet_te_zhe_bajty(pack, forma, repo, src):
    """Изолированная часть свежести «байты» (A.7): отчёт существует ДО
    запуска, stand-in переписывает ТЕ ЖЕ байты (mtime свеж) — байты ==
    дозапусковой ревизии → OTCHET_USTAREVSHIJ, mtime-часть зелёная."""
    _smena_skripta(repo, src, 'te-zhe-bajty')
    (repo / 'mobile/dvizhenie-otchet.json').write_text(
        src['d24_teksty']['otchety']['chestnyj'], encoding='utf-8')


def mut_otchet_staryj_mtime(pack, forma, repo, src):
    """Изолированная часть свежести «mtime» (A.7): отчёта до запуска
    нет, stand-in пишет НОВЫЕ байты и сдвигает mtime на 2 ч назад —
    байты-часть зелёная, mtime < старта → OTCHET_USTAREVSHIJ."""
    _smena_skripta(repo, src, 'staryj-mtime')


def _smena_speki(pack, repo, src, pravka):
    """Правка фиктивной спеки в репо + ЧЕСТНЫЙ перепин байтов в пачке
    (контрпример инвариантен к значениям: пачка не лжёт об источнике —
    источник сам нарушает грамматику; демаркация 019/050)."""
    put = repo / 'docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json'
    spc = json.loads(put.read_text(encoding='utf-8'))
    pravka(spc)
    tekst = json.dumps(spc, ensure_ascii=False, indent=1)
    put.write_text(tekst, encoding='utf-8')
    forma = _forma_d24(pack)
    forma['dvizhenie']['spec_sha256'] = sha256_bytes(tekst.encode('utf-8'))
    zapis(pack, forma)


def _scena(spc, pid):
    return next(s for s in spc['scenes'] if s['id'] == pid)


def _trek(sc, cvet=False):
    """Первый трек нужного класса: видимый (opacity/bg) либо
    перемещение/размер. У всех сцен носителей есть оба класса; иначе
    KeyError — вычислимая клетка недействительна (охрана оракула)."""
    for t in sc['tracks']:
        if (t['property'] in ('opacity', 'bg')) == cvet:
            return t
    raise KeyError('нет трека класса cvet=%s' % cvet)


# Сеяные клетки грамматики: цель — ОБЪЯВЛЕННЫЙ переход входа, БЕЗ
# литерала pid в коде (класс «литерал на месте, исполняемое иное», круг
# критика 1): sejannyj_perehod() ротирует цели по порядковому номеру
# клетки + seed по модулю числа объявленных переходов — при ЛЮБОМ seed
# число клеток (13) ≥ числа переходов покрывает ВСЕ переходы (проверено
# развёрткой по seed в katalog_i_pokrytie — механизм, не рассуждение).
# Структурная полнота (каждый трек/процент/тема) этими клетками НЕ
# держится — её несут семьи «все адреса разом» ниже (A.1–A.5).
SEJANYE_GRAMMATIKA = (
    'pruzhina-v-spetse', 'krivaya-vne-kanona', 'dlitelnost-bez-tokena',
    'dlitelnost-ne-tokenu', 'zaderzhka-ne-po-grammatike',
    'zaderzhka-ne-soglasna', 'ud-narushen-peremeshchenie',
    'ud-narushen-cveta', 'ud-bez-stolbca', 'end-ms-ne-raven',
    'poryadok-narushen', 'kljuchevye-kadry-neverny', 'fajly-etalonov-ne-polny')


def sejannyj_perehod(forma, imja, seed):
    """Сеяный выбор перехода-цели из ОБЪЯВЛЕННЫХ переходов входа:
    ротация по порядковому номеру клетки — покрывает все переходы при
    любом seed (механизм, не рассуждение: покрытие проверяет main)."""
    perehody = sorted(forma['dvizhenie']['perehody'])
    return perehody[(SEJANYE_GRAMMATIKA.index(imja) + seed) % len(perehody)]


def mut_pruzhina_v_spetse(pack, forma, repo, src, pid):
    def pravka(spc):
        _trek(_scena(spc, pid))['spring'] = {'stiffness': 180, 'damping': 20}
    _smena_speki(pack, repo, src, pravka)


def mut_krivaya_vne_kanona(pack, forma, repo, src, pid):
    def pravka(spc):
        _trek(_scena(spc, pid))['curve'] = {
            'token': 'ease-in-out', 'value': 'cubic-bezier(0.4, 0, 0.2, 1)'}
    _smena_speki(pack, repo, src, pravka)


def mut_dlitzelnost_bez_tokena(pack, forma, repo, src, pid):
    def pravka(spc):
        _trek(_scena(spc, pid))['duration'] = 120.0
    _smena_speki(pack, repo, src, pravka)


def mut_dlitzelnost_ne_tokenu(pack, forma, repo, src, pid):
    def pravka(spc):
        t = _trek(_scena(spc, pid))
        t['duration'] = {'token': 'net-takogo-tokena', 'ms':
                         t['duration']['ms']}
    _smena_speki(pack, repo, src, pravka)


def mut_zaderzhka_ne_po_grammatike(pack, forma, repo, src, pid):
    def pravka(spc):
        t = _trek(_scena(spc, pid))
        t['delay'] = {'token': 'позже камня', 'ms': t['delay']['ms']}
    _smena_speki(pack, repo, src, pravka)


def mut_zaderzhka_ne_soglasna(pack, forma, repo, src, pid):
    def pravka(spc):
        t = _trek(_scena(spc, pid))
        t['delay']['ms'] = t['delay']['ms'] + 1.0
    _smena_speki(pack, repo, src, pravka)


def mut_ud_narushen_peremeshchenie(pack, forma, repo, src, pid):
    def pravka(spc):
        _trek(_scena(spc, pid), cvet=False)['reduced_duration_ms'] = 10.0
    _smena_speki(pack, repo, src, pravka)


def mut_ud_narushen_cveta(pack, forma, repo, src, pid):
    def pravka(spc):
        t = _trek(_scena(spc, pid), cvet=True)
        t['reduced_duration_ms'] = 400.0
    _smena_speki(pack, repo, src, pravka)


def mut_ud_bez_stolbca(pack, forma, repo, src, pid):
    def pravka(spc):
        _scena(spc, pid)['tracks'][0]['reduced_duration_ms'] = None
    _smena_speki(pack, repo, src, pravka)


def mut_end_ms_ne_raven(pack, forma, repo, src, pid):
    def pravka(spc):
        _scena(spc, pid)['tracks'][0]['end_ms'] = 42.0
    _smena_speki(pack, repo, src, pravka)


def mut_poryadok_narushen(pack, forma, repo, src, pid):
    def pravka(spc):
        tr = _scena(spc, pid)['tracks']
        tr[0]['order'], tr[1]['order'] = tr[1]['order'], tr[0]['order']
    _smena_speki(pack, repo, src, pravka)


def mut_kljuchevye_kadry_neverny(pack, forma, repo, src, pid):
    def pravka(spc):
        _scena(spc, pid)['keyframes_ms']['25'] = 100.0
    _smena_speki(pack, repo, src, pravka)


def mut_fajly_etalonov_ne_polny(pack, forma, repo, src, pid):
    """Сломанная спека, которую пачка честно зеркалит (эталоны следуют
    спеке): грамматика спеки сама обязана отказать (FAJLY_ETALONOV_...),
    согласованность эталонов тут ЗЕЛЁНАЯ — судится грамматика источника."""

    def pravka(spc):
        del _scena(spc, pid)['files']['video']['light']

    def pravka_pachki(pack, forma):
        del forma['dvizhenie']['etalony'][pid]['video']['light']
        zapis(pack, forma)
    _smena_speki(pack, repo, src, pravka)
    forma = _forma_d24(pack)
    pravka_pachki(pack, forma)
    # перепин: спека уже перепинена _smena_speki, повторноsha не меняется
    forma = _forma_d24(pack)
    forma['dvizhenie']['spec_sha256'] = sha256_fajla(
        repo / 'docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json')
    zapis(pack, forma)


def mut_pruzhina_vo_vseh_perehodah(pack, forma, repo, src):
    """Клетка всех переходов (круг критика 1): пружина в первом треке
    КАЖДОГО объявленного перехода — ловит субъекта, судящего грамматику
    по подмножеству ПЕРЕХОДОВ. Трековая полнота — семьёй
    pruzhina-na-kazhdom-treke (A.3)."""
    objavlennye = list(forma['dvizhenie']['perehody'])

    def pravka(spc):
        for p in objavlennye:
            _scena(spc, p)['tracks'][0]['spring'] = {
                'stiffness': 180, 'damping': 20}
    _smena_speki(pack, repo, src, pravka)


# --- семьи «все адреса разом» (A.2–A.5) --------------------------------------
# Чистая правка семьи: F(spc, forma) → список затронутых адресов (пустой
# список — неисправность пробы). Сторона применения: 'spec' — спека
# (перепин source.json-честный), 'forma' — только пачка. real=True —
# семья применима к реальному корпусу (B.10). Извлекатель адреса из
# detail причины: 'trek' (pid:i), 'pid', 'etalon' (pid tema / pid video
# tema), 'vid' (etalony.pid).

VIDIMYE = ('opacity', 'bg')


def _objavlennye(forma):
    return sorted(forma['dvizhenie']['perehody'])


def _adresa_trekov(spc, forma):
    return ['%s:%d' % (pid, i + 1)
            for pid in _objavlennye(forma)
            for i, _ in enumerate(_scena(spc, pid)['tracks'])]


def _pravka_dlitzelnost_ms(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['duration']['ms'] = float(t['duration']['ms']) + 0.5
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_dlitzelnost_syroe(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['duration'] = 120.0
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_dlitzelnost_token(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['duration']['token'] = 'neizvestnyj-token'
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_zaderzhka_token(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['delay']['token'] = 'net-takogo-tokena'
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_zaderzhka_token_bez_ms(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['delay']['token'] = 'ease-standard'
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_zaderzhka_ms(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['delay']['ms'] = float(t['delay']['ms']) + 1.0
            a.append('%s:%d' % (pid, i + 1))
    return a


def _mnogo_termov(tekst_token):
    """Честная многочленная форма задержки: 2*motion-fast + 50 - 25 =
    325 мс (проверка НЕ только первого терма, A.4)."""
    return tekst_token, 325.0


def _pravka_zaderzhka_mnogo_soglasno(spc, forma):
    tok, ms = _mnogo_termov('2*motion-fast + 50 - 25')
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['delay'] = {'token': tok, 'ms': ms}
            t['end_ms'] = ms + float(t['duration']['ms'])
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_zaderzhka_mnogo_ne_soglasno(spc, forma):
    """ms совпадает ТОЛЬКО с первым термом (2*motion-fast = 300):
    субъект, считающий один первый терм, принимает; эталон отказывает."""
    tok, _ = _mnogo_termov('2*motion-fast + 50 - 25')
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['delay'] = {'token': tok, 'ms': 300.0}
            t['end_ms'] = 300.0 + float(t['duration']['ms'])
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_krivaya_imja(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['curve']['token'] = 'ease-in-out'
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_krivaya_znachenie(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['curve']['value'] = 'cubic-bezier(9, 9, 9, 9)'
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_pruzhina_vse(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['spring'] = {'stiffness': 180, 'damping': 20}
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_ud_peremeshchenie(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            if t['property'] not in VIDIMYE:
                t['reduced_duration_ms'] = \
                    float(t['reduced_duration_ms']) + 50.0
                a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_ud_cveta(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            if t['property'] in VIDIMYE:
                t['reduced_duration_ms'] = 200.0
                a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_ud_bez_stolbca(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['reduced_duration_ms'] = None
            a.append('%s:%d' % (pid, i + 1))
    return a


def _pravka_end_ms(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        for i, t in enumerate(_scena(spc, pid)['tracks']):
            t['end_ms'] = float(t['delay']['ms']) + \
                float(t['duration']['ms']) + 7.0
            a.append('%s:%d' % (pid, i + 1))
    return a


def _poryadok_nastrojka(spc, forma, pravilo):
    a = []
    for pid in _objavlennye(forma):
        tr = _scena(spc, pid)['tracks']
        pravilo(tr)
        a.append(pid)
    return a


def _pravka_poryadok_propusk(spc, forma):
    return _poryadok_nastrojka(
        spc, forma, lambda tr: tr.__setitem__(
            -1, dict(tr[-1], order=len(tr) + 1)))


def _pravka_poryadok_dubl(spc, forma):
    return _poryadok_nastrojka(
        spc, forma, lambda tr: tr.__setitem__(
            -1, dict(tr[-1], order=1)))


def _pravka_poryadok_perestanovka(spc, forma):
    def smena(tr):
        tr[0], tr[-1] = tr[-1], tr[0]
    return _poryadok_nastrojka(spc, forma, smena)


def _pravka_poryadok_seredina(spc, forma):
    def smena(tr):
        s = len(tr) // 2
        tr[s] = dict(tr[s], order=0)
    return _poryadok_nastrojka(spc, forma, smena)


def _pravka_okno(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        _scena(spc, pid)['window_ms'][0] = 5.0
        a.append(pid)
    return a


def _pravka_window_forma(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        _scena(spc, pid)['window_ms'] = 5
        a.append(pid)
    return a


def _kadr_pravka(procent):
    def pravka(spc, forma):
        a = []
        for pid in _objavlennye(forma):
            kf = _scena(spc, pid)['keyframes_ms']
            kf[procent] = float(kf[procent]) + 7.0
            a.append(pid)
        return a
    return pravka


def _pravka_kadry_net_25(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        del _scena(spc, pid)['keyframes_ms']['25']
        a.append(pid)
    return a


def _pravka_kadry_lishnij(spc, forma):
    a = []
    for pid in _objavlennye(forma):
        _scena(spc, pid)['keyframes_ms']['13'] = 13.0
        a.append(pid)
    return a


def _fajly_nastrojka(pravka_sceny, trogaet_etfony=True):
    """Общая обёртка семей files: правка сцены + ЧЕСТНОЕ следование
    эталонов пачки изменённому источнику (A.5: иначе раньше сработает
    другая ветвь и семья будет судить не свою ось)."""
    def pravka(spc, forma):
        a = []
        et = forma['dvizhenie'].get('etalony') if trogaet_etfony else None
        for pid in _objavlennye(forma):
            sc = _scena(spc, pid)
            pravka_sceny(sc)
            if et is not None:
                _fajly_sled_etalonov(sc, et[pid])
            a.append(pid)
        return a
    return pravka


def _fajly_sled_etalonov(sc, zapis_eta):
    """Эталоны пачки согласованно следуют files сцены: те же темы,
    столько же пинов, сколько файлов (для keyframes)."""
    if 'video' in zapis_eta and isinstance(zapis_eta.get('video'), dict):
        for tema in list(zapis_eta['video']):
            if tema not in sc['files']['video']:
                del zapis_eta['video'][tema]
        for tema in sc['files']['video']:
            zapis_eta['video'].setdefault(tema, '0' * 64)
    if 'keyframes' in zapis_eta and \
            isinstance(zapis_eta.get('keyframes'), dict):
        for tema in list(zapis_eta['keyframes']):
            if tema not in sc['files']['keyframes']:
                del zapis_eta['keyframes'][tema]
        for tema in sc['files']['keyframes']:
            n = len(sc['files']['keyframes'][tema])
            piny = zapis_eta['keyframes'].setdefault(tema, [])
            while len(piny) < n:
                piny.append('0' * 64)
            del piny[n:]


def _video_bez_temy(tema):
    return _fajly_nastrojka(
        lambda sc: sc['files']['video'].pop(tema))


def _kadry_bez_temy(tema):
    return _fajly_nastrojka(
        lambda sc: sc['files']['keyframes'].pop(tema))


def _video_lishnjaja(spc, forma):
    return _fajly_nastrojka(
        lambda sc: sc['files']['video'].update(
            {'amidnight': 'video/x.mp4'}))(spc, forma)


def _kadry_lishnjaja(spc, forma):
    return _fajly_nastrojka(
        lambda sc: sc['files']['keyframes'].update(
            {'amidnight': ['k/1.png', 'k/2.png', 'k/3.png', 'k/4.png',
                           'k/5.png']}))(spc, forma)


def _video_pustaja(tema):
    return _fajly_nastrojka(
        lambda sc: sc['files']['video'].__setitem__(tema, ''))


def _kadry_pustoj_spisok(tema):
    return _fajly_nastrojka(
        lambda sc: sc['files']['keyframes'].__setitem__(tema, []))


def _kadry_pustoj_element(indeks):
    def pravka_sceny(sc):
        for tema in sc['files']['keyframes']:
            sp = sc['files']['keyframes'][tema]
            sp[indeks] = ''
    return _fajly_nastrojka(pravka_sceny)


# etalony (сторона пачки; real=False: реального корпуса пачек нет) —
# регистрируются ниже, после таблицы семей, через _eta_semja

# --- таблица семей ------------------------------------------------------------
# (pravilo=None — зелёный контроль: эталон обязан пройти молча)

SEMEJSTVA = {}


def _semja(imja, pravka, pravilo, izvlekatel, storona, real,
           pobochnye=frozenset()):
    """pobochnye — правила, неизбежно сопутствующие главному при этой
    правке (удаление поля трека роняет и порядок: трек пропускается);
    адреса причин сравниваются ТОЛЬНО по главному правилу семьи."""
    SEMEJSTVA[imja] = {'pravka': pravka, 'pravilo': pravilo,
                       'izvlekatel': izvlekatel, 'storona': storona,
                       'real': real, 'pobochnye': frozenset(pobochnye)}


for _imja, _pravka, _pravilo in (
        ('dlitelnost-ms-vse-treki', _pravka_dlitzelnost_ms,
         'ZNACHENIE_NE_TOKENA'),
        ('dlitelnost-syroe-chislo-vse-treki', _pravka_dlitzelnost_syroe,
         'TREK_BEZ_POLJA'),
        ('dlitelnost-neizvestnyj-token-vse-treki', _pravka_dlitzelnost_token,
         'DLITELNOST_BEZ_TOKENA'),
        ('zaderzhka-neizvestnyj-token-vse-treki', _pravka_zaderzhka_token,
         'ZADERZHKA_NE_PO_GRAMMATIKE'),
        ('zaderzhka-token-bez-ms-vse-treki', _pravka_zaderzhka_token_bez_ms,
         'ZADERZHKA_NE_PO_GRAMMATIKE'),
        ('zaderzhka-ms-neverno-vse-treki', _pravka_zaderzhka_ms,
         'ZADERZHKA_NE_SOGLASNA'),
        ('zaderzhka-mnogo-termonov-ne-soglasno',
         _pravka_zaderzhka_mnogo_ne_soglasno, 'ZADERZHKA_NE_SOGLASNA'),
        ('krivaya-imja-vne-kanona-vse-treki', _pravka_krivaya_imja,
         'KRIVAYA_VNE_KANONA'),
        ('krivaya-znachenie-vne-tokena-vse-treki', _pravka_krivaya_znachenie,
         'KRIVAYA_NE_SOGLASNA'),
        ('pruzhina-na-kazhdom-treke', _pravka_pruzhina_vse,
         'PRUZHINA_ZAPRESHCHENA'),
        ('ud-peremeshchenie-vse-treki', _pravka_ud_peremeshchenie,
         'UD_NARUSHEN'),
        ('ud-cveta-vse-treki', _pravka_ud_cveta, 'UD_NARUSHEN'),
        ('ud-bez-stolbca-vse-treki', _pravka_ud_bez_stolbca, 'UD_BEZ_STOLBCA'),
        ('end-ms-neverno-vse-treki', _pravka_end_ms, 'END_MS_NE_RAVEN'),
        ('zaderzhka-mnogo-termonov-soglasno',
         _pravka_zaderzhka_mnogo_soglasno, None)):
    _semja(_imja, _pravka, _pravilo,
           'trek' if _pravilo is not None else None, 'spec', True)

for _imja, _pravka, _pravilo in (
        ('poryadok-propusk-poslednej', _pravka_poryadok_propusk,
         'PORYADOK_NARUSHEN'),
        ('poryadok-dubl-poslednej', _pravka_poryadok_dubl,
         'PORYADOK_NARUSHEN'),
        ('poryadok-perestanovka-pervyj-poslednij',
         _pravka_poryadok_perestanovka, 'PORYADOK_NARUSHEN'),
        ('poryadok-seredina', _pravka_poryadok_seredina, 'PORYADOK_NARUSHEN'),
        ('okno-ne-ot-nulja-vse-sceny', _pravka_okno, 'OKNO_NE_OT_NULJA'),
        ('window-ne-forma-vse-sceny', _pravka_window_forma,
         'TREK_BEZ_POLJA'),
        ('kadry-net-procenta-25', _pravka_kadry_net_25,
         'KLJUCHEVYE_KADRY_NE_RAVNY'),
        ('kadry-lishnij-procent', _pravka_kadry_lishnij,
         'KLJUCHEVYE_KADRY_NE_RAVNY')):
    _semja(_imja, _pravka, _pravilo, 'pid', 'spec', True)

for _p in PROCENTY:
    _semja('kadr-%s-neverno-vse-sceny' % _p, _kadr_pravka(_p),
           'KLJUCHEVYE_KADRY_NE_RAVNY', 'pid', 'spec', True)

for _tema in TEMY_ETF:
    _semja('fajly-video-bez-temy-%s' % _tema, _video_bez_temy(_tema),
           'FAJLY_ETALONOV_NE_POLNY', 'pid', 'spec', True)
    _semja('fajly-kadry-bez-temy-%s' % _tema, _kadry_bez_temy(_tema),
           'FAJLY_ETALONOV_NE_POLNY', 'pid', 'spec', True)
    _semja('fajly-video-pustaja-stroka-%s' % _tema, _video_pustaja(_tema),
           'FAJLY_ETALONOV_NE_POLNY', 'pid', 'spec', True)
    _semja('fajly-kadry-pustoj-spisok-%s' % _tema,
           _kadry_pustoj_spisok(_tema), 'FAJLY_ETALONOV_NE_POLNY',
           'pid', 'spec', True)

_semja('fajly-video-lishnjaja-tema', _video_lishnjaja,
       'FAJLY_ETALONOV_NE_POLNY', 'pid', 'spec', True)
_semja('fajly-kadry-lishnjaja-tema', _kadry_lishnjaja,
       'FAJLY_ETALONOV_NE_POLNY', 'pid', 'spec', True)
for _i in range(5):
    _semja('fajly-kadry-pustoj-element-%d' % (_i + 1),
           _kadry_pustoj_element(_i), 'FAJLY_ETALONOV_NE_POLNY',
           'pid', 'spec', True)

# etalony (сторона пачки): адресность — izvlekatel 'etalon'/'vid'


def _eta_semja(imja, pravila_pidov, pravilo, izvlekatel):
    def pravka(spc, forma):
        a = []
        for pid in _objavlennye(forma):
            a.extend(pravila_pidov(forma['dvizhenie']['etalony'][pid], pid))
        return a
    _semja(imja, pravka, pravilo, izvlekatel, 'forma', False)


def _eta_poslednij_pin_ne_hex(et_pid, pid):
    a = []
    for tema in sorted(et_pid['keyframes']):
        et_pid['keyframes'][tema][-1] = 'zz' * 32
        a.append('%s %s' % (pid, tema))
    return a


def _eta_video_pin_ne_hex(et_pid, pid):
    a = []
    for tema in sorted(et_pid['video']):
        et_pid['video'][tema] = 'zz' * 32
        a.append('%s video %s' % (pid, tema))
    return a


def _eta_korotkie(et_pid, pid):
    a = []
    for tema in sorted(et_pid['keyframes']):
        et_pid['keyframes'][tema].pop()
        a.append('%s %s' % (pid, tema))
    return a


def _eta_dlinnye(et_pid, pid):
    a = []
    for tema in sorted(et_pid['keyframes']):
        et_pid['keyframes'][tema].append('0' * 64)
        a.append('%s %s' % (pid, tema))
    return a


def _video_eta_bez_temy(tema):
    def pravila(et_pid, pid):
        del et_pid['video'][tema]
        return [pid]
    return pravila


def _eta_vid_lishnij(et_pid, pid):
    et_pid['audio'] = '0' * 64
    return ['etalony.%s' % pid]


def _eta_vid_otsutstvuet(et_pid, pid):
    del et_pid['video']
    return ['etalony.%s' % pid]


_eta_semja('etalon-poslednij-pin-ne-hex', _eta_poslednij_pin_ne_hex,
           'ETALON_NE_HEX', 'etalon')
_eta_semja('etalon-video-pin-ne-hex-vse-temy', _eta_video_pin_ne_hex,
           'ETALON_NE_HEX', 'etalon')
_eta_semja('etalony-korotkie-vse-temy', _eta_korotkie, 'ETALON_NE_POLON',
           'etalon')
_eta_semja('etalony-dlinnye-vse-temy', _eta_dlinnye, 'ETALON_NE_POLON',
           'etalon')
for _tema in TEMY_ETF:
    _eta_semja('etalon-video-bez-temy-%s' % _tema,
               _video_eta_bez_temy(_tema), 'VIDEO_ETALON_NE_POLON', 'pid')
_eta_semja('etalon-vid-lishnij', _eta_vid_lishnij, 'SHABLON_NEVEREN', 'vid')
_eta_semja('etalon-vid-otsutstvuet', _eta_vid_otsutstvuet, 'SHABLON_NEVEREN',
           'vid')

# istochnik-семьи (A.6): правка репо-файла источника и/или пина пачки
# + ЧЕСТНЫЙ перепин всех изменённых байтов; клетки строятся динамически
# ниже по именам istochnik-<vid>-<istochnik>
ISTOCHNIKI = ('manifest', 'spec', 'pozvonok')

# применение семьи к живому миру входа ----------------------------------------

def _primeni_semju(pack, repo, src, imja, forma_vhod=None):
    """Применить чистую правку семьи к живому миру (спека — в репо с
    ЧЕСТНЫМ перепином, форма — zapis) и записать затронутые адреса в
    реестр ZATRONUTYE (пустое множество — неисправность пробы)."""
    semja = SEMEJSTVA[imja]
    forma = forma_vhod if forma_vhod is not None else _forma_d24(pack)
    put = repo / 'docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json'
    spc = json.loads(put.read_text(encoding='utf-8'))
    adresa = semja['pravka'](spc, forma)
    if not adresa:
        raise SystemExit('ORACLE_TAMPERED: семья %s не затронула ни одного '
                         'адреса' % imja)
    tekst = json.dumps(spc, ensure_ascii=False, indent=1)
    put.write_text(tekst, encoding='utf-8')
    forma['dvizhenie']['spec_sha256'] = sha256_bytes(tekst.encode('utf-8'))
    zapis(pack, forma)
    ZATRONUTYE[imja] = {'pravilo': semja['pravilo'], 'adresa': adresa,
                        'izvlekatel': semja['izvlekatel'],
                        'pobochnye': semja['pobochnye']}
    return forma


ZATRONUTYE = {}


def _kletka_semji(imja):
    def primeni(pack, forma, repo, src):
        _primeni_semju(pack, repo, src, imja)
    primeni.__name__ = 'mut_' + imja.replace('-', '_')
    return primeni

# istochnik-семьи: порча/удаление/не-JSON/не-грамматика каждого источника
def _put_istochnika(forma, imja):
    return forma['dvizhenie'][imja]


def _primeni_istochnik(pack, repo, src, imja, kljuch, forma_vhod=None):
    """Семья источников (A.6): редактирует репо-файл источника (или пин
    в пачке) и ЧЕСТНО перепиняет все изменённые байты; адрес — имя
    источника."""
    forma = forma_vhod if forma_vhod is not None else _forma_d24(pack)
    vid, imja_ist = imja.split(':', 1)
    put = repo / _put_istochnika(forma, imja_ist)
    adresa = [imja_ist]
    if vid == 'piny':
        forma['dvizhenie'][imja_ist + '_sha256'] = '0' * 64
    elif vid == 'otsutstvuet':
        forma['dvizhenie'][imja_ist] = (
            'docs/ux/04_Gespraech_D24/motion/net-takogo-%s.json' % imja_ist)
        adresa = [forma['dvizhenie'][imja_ist]]
    elif vid == 'ne-json':
        bajty = b'ne json voobshhe {'
        put.write_bytes(bajty)
        forma['dvizhenie'][imja_ist + '_sha256'] = sha256_bytes(bajty)
    elif vid == 'ne-grammatiki':
        slomanno = {'manifest': {'screens': 5, 'motion': []},
                    'spec': {'tokens': {}, 'scenes': []},
                    'pozvonok': {'scenes': []}}[imja_ist]
        bajty = json.dumps(slomanno, ensure_ascii=False,
                           indent=1).encode('utf-8')
        put.write_bytes(bajty)
        forma['dvizhenie'][imja_ist + '_sha256'] = sha256_bytes(bajty)
        adresa = [imja_ist]
    else:
        raise KeyError(vid)
    zapis(pack, forma)
    pravilo = ('ISTOCHNIK_NE_SOVPADAET' if vid == 'piny'
               else 'ISTOCHNIK_OTSVTSTVUET')
    ZATRONUTYE[kljuch] = {'pravilo': pravilo, 'adresa': adresa,
                          'izvlekatel': 'pid'}


# --- клетки полноты/равенств множеств (A.2) ----------------------------------

def _kletka_udalenija(kol, pravilo, adres, imja):
    def primeni(pack, forma, repo, src):
        spisok = forma['dvizhenie'][kol]
        spisok.remove(adres)
        zapis(pack, forma)
        ZATRONUTYE[imja] = {'pravilo': pravilo, 'adresa': [adres],
                            'izvlekatel': 'pid'}
    return primeni


def _kletka_scena_v_poz_vne_perehodov(pack, forma, repo, src):
    """B.9/A.2: сцена поз-оракула (GA-T20 в носителе поз), ЧУЖАЯ
    переходам пачки, объявлена в sceny_znaka — точное пересечение
    обязано отказать SCENA_VNE_PEREHODA (прежде принималось)."""
    forma['dvizhenie']['sceny_znaka'].append('GA-T20')
    zapis(pack, forma)
    ZATRONUTYE['scena-v-poz-vne-perehodov'] = {
        'pravilo': 'SCENA_VNE_PEREHODA', 'adresa': ['GA-T20'],
        'izvlekatel': 'pid'}


def _kletka_ekrany_perestanovka(pack, forma, repo, src):
    """A.2: перестановка списка ekrany не меняет суд (зелёный контроль
    множества — порядок не должен влиять)."""
    forma['dvizhenie']['ekrany'].reverse()
    zapis(pack, forma)


# --- MUTACII ------------------------------------------------------------------

MUTACII = {
    'slice1-pachka': None,
    'chestnyj-d24-ekran': None,
    'shablon3-bez-dvizhenija': mut_shablon3_bez_dvizhenija,
    'ga-pachka-na-shablone2': mut_ga_pachka_na_shablone2,
    'dvizhenie-na-shablone2': mut_dvizhenie_na_shablone2,
    'priemka-s-lishnim-kljuchom': mut_priemka_s_lishnim_kljuchom,
    'ekrany-vne-manifesta': mut_ekrany_vne_manifesta,
    'ekran-bez-kadrov': mut_ekran_bez_kadrov,
    'perehod-vne-manifesta': mut_perehod_vne_manifesta,
    'perehod-lishnij': mut_perehod_lishnij,
    'scena-vne-orakula': mut_scena_vne_orakula,
    'etalony-ne-polny': mut_etalony_ne_polny,
    'etalony-bez-pina': mut_etalony_bez_pina,
    'etalon-ne-hex': mut_etalon_ne_hex,
    'etalon-lishnij': mut_etalon_lishnij,
    'etalon-tema-otsutstvuet': mut_etalon_tema_otsutstvuet,
    'video-etalon-ne-polon': mut_video_etalon_ne_polon,
    'priemka-dvizhenija-bez-otcheta': mut_priemka_bez_otcheta,
    'priemka-dvizhenija-ne-proshla': mut_priemka_ne_proshla,
    'otchet-otsutstvuet': mut_otchet_otsutstvuet,
    'otchet-ustarevshij': mut_otchet_ustarevshij,
    'otchet-te-zhe-bajty': mut_otchet_te_zhe_bajty,
    'otchet-staryj-mtime': mut_otchet_staryj_mtime,
    'otchet-s-provalami': mut_otchet_s_provalami,
    'otchet-pustoj': mut_otchet_pustoj,
    'otchet-ne-chitaetsja': mut_otchet_ne_chitaetsja,
    'pruzhina-v-spetse': mut_pruzhina_v_spetse,
    'krivaya-vne-kanona': mut_krivaya_vne_kanona,
    'dlitelnost-bez-tokena': mut_dlitzelnost_bez_tokena,
    'dlitelnost-ne-tokenu': mut_dlitzelnost_ne_tokenu,
    'zaderzhka-ne-po-grammatike': mut_zaderzhka_ne_po_grammatike,
    'zaderzhka-ne-soglasna': mut_zaderzhka_ne_soglasna,
    'ud-narushen-peremeshchenie': mut_ud_narushen_peremeshchenie,
    'ud-narushen-cveta': mut_ud_narushen_cveta,
    'ud-bez-stolbca': mut_ud_bez_stolbca,
    'end-ms-ne-raven': mut_end_ms_ne_raven,
    'poryadok-narushen': mut_poryadok_narushen,
    'kljuchevye-kadry-neverny': mut_kljuchevye_kadry_neverny,
    'fajly-etalonov-ne-polny': mut_fajly_etalonov_ne_polny,
    'pruzhina-vo-vseh-perehodah': mut_pruzhina_vo_vseh_perehodah,
    None: None,
}

# динамические части MUTACII: семьи, полнота/равенства множеств (A.2),
# источники (A.6), зелёные контроли перестановки/многочленной задержки
for _imja in SEMEJSTVA:
    MUTACII[_imja] = _kletka_semji(_imja)
_dv_forma = json.loads(
    (HERE / 'source.json').read_text(encoding='utf-8')
)['ekran_forma_d24']['dvizhenie']
for _pid in _dv_forma['perehody']:
    _klj = 'perehody-ne-polny-%s' % _pid.lower()
    MUTACII[_klj] = _kletka_udalenija('perehody', 'PEREHODY_NE_POLNY',
                                      _pid, _klj)
for _ek in _dv_forma['ekrany']:
    _klj = 'ekrany-ne-polny-%s' % _ek.lower()
    MUTACII[_klj] = _kletka_udalenija('ekrany', 'EKRANY_NE_POLNY',
                                      _ek, _klj)
for _sz in _dv_forma['sceny_znaka']:
    _klj = 'sceny-znaka-ne-polny-%s' % _sz.lower()
    MUTACII[_klj] = _kletka_udalenija('sceny_znaka', 'SCENY_ZNAKA_NE_POLNY',
                                      _sz, _klj)
MUTACII['scena-v-poz-vne-perehodov'] = _kletka_scena_v_poz_vne_perehodov
MUTACII['ekrany-perestanovka'] = _kletka_ekrany_perestanovka
for _vid in ('piny', 'otsutstvuet', 'ne-json', 'ne-grammatiki'):
    for _ist in ISTOCHNIKI:
        _klj = 'istochnik-%s-%s' % (_vid, _ist)
        MUTACII[_klj] = (
            lambda pack, forma, repo, src, _v=_vid, _i=_ist, _k=_klj:
            _primeni_istochnik(pack, repo, src, '%s:%s' % (_v, _i), _k))


# --- матрица «поле × мутация»: общий мутационный проход (Crit146c) ----------
# Слово владельца 30.10 «А» + закрывающее свойство вердикта: по КАЖДОМУ
# семейству полей шаблона — матрица «поле × мутация» (удаление / пустое
# значение / чужой тип / перестановка / подмножество); каждая КРАСНАЯ
# комбинация обязана краснеть ИМЕНОВАННОЙ причиной. ПЕРЕЧЕНЬ ПОЛЕЙ —
# ИЗ КОДА ЭТАЛОНА (FORMA_POLEJ_V3/DV_POLEJ/POLEJ_TREKA/TEMY_ETF из
# model/ekran_shablon.py; поля сцены — по чтению sc.get(...) в его
# коде), а не ручной набор. Ожидания — ЗАЯВЛЕНЫ (rc + имена правил)
# и сверяются с фактом ЭТАЛОНА в памяти ДО субъекта (правило 8;
# прецедент 145 p14/p15). Зелёные и изъятые классы ПЕРЕЧИСЛЕНЫ с
# обоснованием — умолчаний нет (katalog_i_pokrytie сверяет таблицу
# с перечнем полей целиком).

MUTACII_KLASSY = ('udalen', 'pustoe', 'chuzhoj', 'perestanovka',
                  'podmnozhestvo')
PORYADOK_POB = frozenset({'PORYADOK_NARUSHEN'})
_SN2 = {'rc': 2, 'pravila': ('SHABLON_NEVEREN',)}

# --- слой etalony: пины ВСЕХ индексов, темы, входы переходов (Crit146c-1) ---


def _eta_pin_indeks(i):
    def pravila(et_pid, pid):
        a = []
        for tema in sorted(et_pid['keyframes']):
            piny = et_pid['keyframes'][tema]
            if isinstance(piny, list) and len(piny) > i:
                piny[i] = 'zz' * 32
                a.append('%s %s' % (pid, tema))
        return a
    return pravila


_MAX_PINOV = max(len(p)
                 for z in _dv_forma['etalony'].values()
                 for p in z['keyframes'].values())
for _i in range(_MAX_PINOV):
    _eta_semja('etalon-pin-%d-ne-hex' % _i, _eta_pin_indeks(_i),
               'ETALON_NE_HEX', 'etalon')


def _eta_kf_bez_temy(tema):
    def pravila(et_pid, pid):
        if tema in et_pid['keyframes']:
            del et_pid['keyframes'][tema]
            return [pid]
        return []
    return pravila


for _tema in TEMY_ETF:
    _eta_semja('etalon-kf-bez-temy-%s' % _tema, _eta_kf_bez_temy(_tema),
               'ETALON_TEMA_OTSVTSTVUET', 'pid')


def _eta_piny_perestanovka(et_pid, pid):
    a = []
    for tema in sorted(et_pid['keyframes']):
        et_pid['keyframes'][tema] = list(
            reversed(et_pid['keyframes'][tema]))
        a.append('%s %s' % (pid, tema))
    return a


_eta_semja('etalony-piny-perestanovka', _eta_piny_perestanovka, None,
           'etalon')


def _kletka_etalon_bez_pina(pid):
    imja = 'etalony-bez-pina-%s' % pid.lower()

    def primeni(pack, forma, repo, src):
        del forma['dvizhenie']['etalony'][pid]
        zapis(pack, forma)
        ZATRONUTYE[imja] = {'pravilo': 'ETALON_BEZ_PINOV', 'adresa': [pid],
                            'izvlekatel': 'pid', 'pobochnye': frozenset()}
    MUTACII[imja] = primeni


for _pid in _dv_forma['perehody']:
    _kletka_etalon_bez_pina(_pid)

# --- слой spec: сцена спеки КАЖДОГО объявленного перехода (Crit146c-2) -------


def _kletka_perehod_bez_specy(pid):
    imja = 'perehod-bez-specy-%s' % pid.lower()

    def primeni(pack, forma, repo, src):
        put = repo / forma['dvizhenie']['spec']
        spc = json.loads(put.read_text(encoding='utf-8'))
        spc['scenes'] = [s for s in spc['scenes'] if s['id'] != pid]
        tekst = json.dumps(spc, ensure_ascii=False, indent=1)
        put.write_text(tekst, encoding='utf-8')
        forma['dvizhenie']['spec_sha256'] = sha256_bytes(
            tekst.encode('utf-8'))
        zapis(pack, forma)
        ZATRONUTYE[imja] = {'pravilo': 'PEREHOD_BEZ_SPECY', 'adresa': [pid],
                            'izvlekatel': 'pid', 'pobochnye': frozenset()}
    MUTACII[imja] = primeni


for _pid in _dv_forma['perehody']:
    _kletka_perehod_bez_specy(_pid)


def _pravka_spec_bez_scen(spc, forma):
    objavlennye = _objavlennye(forma)
    spc['scenes'] = [s for s in spc['scenes']
                     if s['id'] not in objavlennye]
    return list(objavlennye)


_semja('perehody-bez-specy-vse', _pravka_spec_bez_scen,
       'PEREHOD_BEZ_SPECY', 'pid', 'spec', False)

# --- слой trek: поля трека спеки (Crit146c-3 + матрица значений) -------------


def _pravka_trekov(pravilo_treka):
    def pravka(spc, forma):
        a = []
        for pid in _objavlennye(forma):
            for i, t in enumerate(_scena(spc, pid)['tracks']):
                if pravilo_treka(t):
                    a.append('%s:%d' % (pid, i + 1))
        return a
    return pravka


def _trek_udali(pole):
    def prav(t):
        t.pop(pole, None)
        return True
    return prav


def _trek_zameni(pole, znachenie):
    def prav(t):
        # подмена касается только треков, где значение ДЕЙСТВИТЕЛЬНО
        # меняется (end_ms честно 0 у мгновенных треков: подстановка 0
        # там — не мутация, адрес не затронут)
        if t.get(pole) != znachenie:
            t[pole] = znachenie
            return True
        return False
    return prav


_TREK_PUSTOE = {'order': 0, 'end_ms': 0.0, 'delay': {}, 'duration': {},
                'curve': {}, 'element': '', 'property': '',
                'reduced_duration_ms': 0.0}
_TREK_CHUZH = {'order': '1', 'end_ms': 'x', 'delay': 5, 'duration': 5,
               'curve': 5, 'element': 5, 'property': 5, 'spring': 5,
               'reduced_duration_ms': '0'}
# заявление слоя trek: (поле, класс) → (клетка, правило|None, извлекатель,
# побочные); None — зелёный контроль-свидетель; неприменимый класс —
# перечислен в katalog_i_pokrytie как IZJATO с обоснованием.
_TREK_ZAJAVKI = {}
for _pole in POLEJ_TREKA:
    _TREK_ZAJAVKI[(_pole, 'udalen')] = (
        'pole-treka-udaleno-%s' % _pole, 'TREK_BEZ_POLJA', 'trek',
        PORYADOK_POB)
for _pole, _pr, _iz in (('order', 'PORYADOK_NARUSHEN', 'pid'),
                        ('end_ms', 'END_MS_NE_RAVEN', 'trek'),
                        ('delay', 'TREK_BEZ_POLJA', 'trek'),
                        ('duration', 'TREK_BEZ_POLJA', 'trek'),
                        ('curve', 'TREK_BEZ_POLJA', 'trek')):
    _TREK_ZAJAVKI[(_pole, 'pustoe')] = (
        'pole-treka-pustoe-%s' % _pole, _pr, _iz, frozenset())
for _pole, _pr, _iz, _pob in (
        ('order', 'PORYADOK_NARUSHEN', 'pid', frozenset()),
        ('property', 'TREK_BEZ_POLJA', 'trek', PORYADOK_POB),
        ('delay', 'TREK_BEZ_POLJA', 'trek', PORYADOK_POB),
        ('duration', 'TREK_BEZ_POLJA', 'trek', PORYADOK_POB),
        ('end_ms', 'END_MS_NE_RAVEN', 'trek', frozenset()),
        ('curve', 'TREK_BEZ_POLJA', 'trek', PORYADOK_POB),
        ('spring', 'PRUZHINA_ZAPRESHCHENA', 'trek', frozenset()),
        ('reduced_duration_ms', 'UD_BEZ_STOLBCA', 'trek', frozenset())):
    _TREK_ZAJAVKI[(_pole, 'chuzhoj')] = (
        'pole-treka-chuzhoj-%s' % _pole, _pr, _iz, _pob)
# pustoe property — НЕ зелёное свидетельство, а КРАСНАЯ семья: пустая
# строка переклассифицирует видимый трек (opacity/bg с честной УД>0)
# в перемещение, требующее УД==0, — UD_NARUSHEN на каждом таком треке;
# на треках, где переклассификация ничего не меняет, мутация ненаблюдаема
def _trek_property_pustoj(t):
    if t.get('property') in VIDIMYE \
            and isinstance(t.get('reduced_duration_ms'), (int, float)) \
            and float(t['reduced_duration_ms']) > 0:
        t['property'] = ''
        return True
    return False


_TREK_ZAJAVKI[('property', 'pustoe')] = (
    'pole-treka-pustoe-property', 'UD_NARUSHEN', 'trek', frozenset())
# зелёные свидетели слоя trek (значение конформно замкнутой грамматике
# v3: словарь element не задан И-6, 0 допустим УД обоим классам свойств;
# расширение словаря — v+1 шаблона, НЕ эта правка)
for _pole, _klass in (('element', 'pustoe'),
                      ('reduced_duration_ms', 'pustoe'),
                      ('element', 'chuzhoj')):
    _TREK_ZAJAVKI[(_pole, _klass)] = (
        'pole-treka-%s-%s' % (_klass, _pole), None, None, frozenset())

def _pravka_trekov_scen(pravilo_treka):
    """Адрес — сцена (pid), не трек: для семей, чьи причины звучат
    на сцену (PORYADOK_NARUSHEN), при правке КАЖДОГО трека сцены."""
    def pravka(spc, forma):
        a = []
        for pid in _objavlennye(forma):
            if any(pravilo_treka(t)
                   for t in _scena(spc, pid)['tracks']):
                a.append(pid)
        return a
    return pravka


# spring.pustoe — IZJATO: null есть ЧЕСТНОЕ значение поля (пружина
# запрещена: spring != null — отказ; «пустое» не порождает мутации)
_TREK_IZJATO = {('spring', 'pustoe'): 'null — честное значение поля'}

for (_pole, _klass), (_imja, _pr, _iz, _pob) in _TREK_ZAJAVKI.items():
    if (_pole, _klass) == ('property', 'pustoe'):
        _pravka = _pravka_trekov(_trek_property_pustoj)
    elif _iz == 'pid':
        _pravka = _pravka_trekov_scen(_trek_zameni(_pole, _TREK_CHUZH[_pole]))
    elif _klass == 'udalen':
        _pravka = _pravka_trekov(_trek_udali(_pole))
    else:
        _zn = (_TREK_PUSTOE if _klass == 'pustoe' else _TREK_CHUZH)[_pole]
        _pravka = _pravka_trekov(_trek_zameni(_pole, _zn))
    _semja(_imja, _pravka, _pr, _iz, 'spec', True, pobochnye=_pob)

# --- слой scena: поля сцены спеки -------------------------------------------


def _pravka_scen(pravilo_sceny):
    def pravka(spc, forma):
        a = []
        for pid in _objavlennye(forma):
            if pravilo_sceny(_scena(spc, pid)):
                a.append(pid)
        return a
    return pravka


def _scena_udali(pole):
    def prav(sc):
        sc.pop(pole, None)
        return True
    return prav


def _scena_zameni(pole, znachenie):
    def prav(sc):
        sc[pole] = znachenie
        return True
    return prav


_SCENA_ZAJAVKI = {
    ('window_ms', 'udalen'): ('scena-window-ms-udalen', 'TREK_BEZ_POLJA',
                              frozenset()),
    ('window_ms', 'pustoe'): ('scena-window-ms-pustoj', 'TREK_BEZ_POLJA',
                              frozenset()),
    ('window_ms', 'chuzhoj'): ('scena-window-ms-chuzhoj', 'TREK_BEZ_POLJA',
                               frozenset()),
    ('window_ms', 'perestanovka'): (
        'scena-window-ms-perestanovka', 'OKNO_NE_OT_NULJA',
        frozenset({'KLJUCHEVYE_KADRY_NE_RAVNY'})),
    ('keyframes_ms', 'udalen'): ('scena-keyframes-ms-udaleny',
                                 'KLJUCHEVYE_KADRY_NE_RAVNY',
                                 frozenset()),
    ('keyframes_ms', 'pustoe'): ('scena-keyframes-ms-pustoj',
                                 'KLJUCHEVYE_KADRY_NE_RAVNY',
                                 frozenset()),
    ('keyframes_ms', 'chuzhoj'): ('scena-keyframes-ms-chuzhoj',
                                  'KLJUCHEVYE_KADRY_NE_RAVNY',
                                  frozenset()),
    ('files', 'udalen'): ('scena-files-udaleny', 'FAJLY_ETALONOV_NE_POLNY',
                          frozenset()),
    ('files', 'pustoe'): ('scena-files-pustoj', 'FAJLY_ETALONOV_NE_POLNY',
                          frozenset()),
    ('files', 'chuzhoj'): ('scena-files-chuzhoj', 'FAJLY_ETALONOV_NE_POLNY',
                           frozenset()),
    ('tracks', 'udalen'): ('scena-tracks-udaleny', 'TREK_BEZ_POLJA',
                           frozenset()),
    ('tracks', 'pustoe'): ('scena-tracks-pustoj', 'TREK_BEZ_POLJA',
                           frozenset()),
    ('tracks', 'chuzhoj'): ('scena-tracks-chuzhoj', 'TREK_BEZ_POLJA',
                            frozenset()),
    ('tracks', 'perestanovka'): ('scena-tracks-perestanovka',
                                 'PORYADOK_NARUSHEN', frozenset()),
    ('tracks', 'podmnozhestvo'): ('scena-tracks-podmnozhestvo-pervogo',
                                  'PORYADOK_NARUSHEN', frozenset()),
}
_SCENA_PUSTOE = {'window_ms': [], 'keyframes_ms': {}, 'files': {},
                 'tracks': []}
_SCENA_CHUZH = {'window_ms': 5, 'keyframes_ms': 5, 'files': 5, 'tracks': 5}


def _scena_okno_perestanovka(sc):
    sc['window_ms'] = list(reversed(sc['window_ms']))
    return True


def _scena_trek_pervyj(sc):
    # подмножество треков: удаление ПЕРВОГО — порядок всегда с дырой
    # (удаление «среднего» у двухтрековой сцены совпадает с последним и
    # конформно — замер d24-real на GA-T18)
    tr = sc.get('tracks')
    if isinstance(tr, list) and len(tr) > 1:
        del tr[0]
        return True
    return False


def _scena_trek_poslednij(sc):
    tr = sc.get('tracks')
    if isinstance(tr, list) and len(tr) > 1:
        tr.pop()
        return True
    return False


def _scena_trek_perestanovka(sc):
    tr = sc.get('tracks')
    if isinstance(tr, list) and len(tr) > 1:
        tr.reverse()
        return True
    return False


_SCENA_PRAVKI = {
    ('window_ms', 'perestanovka'): _scena_okno_perestanovka,
    ('tracks', 'perestanovka'): _scena_trek_perestanovka,
    ('tracks', 'podmnozhestvo'): _scena_trek_pervyj,
}


for (_pole, _klass), (_imja, _pr, _pob) in _SCENA_ZAJAVKI.items():
    if (_pole, _klass) in _SCENA_PRAVKI:
        _pravka = _pravka_scen(_SCENA_PRAVKI[(_pole, _klass)])
    elif _klass == 'udalen':
        _pravka = _pravka_scen(_scena_udali(_pole))
    else:
        _zn = (_SCENA_PUSTOE if _klass == 'pustoe' else _SCENA_CHUZH)[_pole]
        _pravka = _pravka_scen(_scena_zameni(_pole, _zn))
    _semja(_imja, _pravka, _pr, 'pid', 'spec', True, pobochnye=_pob)
_semja('scena-tracks-podmnozhestvo-poslednego',
       _pravka_scen(_scena_trek_poslednij), None, 'pid', 'spec', True)

# --- слои top/dv: клетки матрицы формы (заявления по замеру эталона) --------

_FORMA_CH = json.loads((HERE / 'source.json').read_text(
    encoding='utf-8'))['ekran_forma_d24']

# (род, класс) → стандартное заявление; отступления — _RUCHNYE ниже.
# Слои top/dv судятся грамматикой формы: почти всё — SHABLON_NEVEREN
# rc 2 (состав ключей/алфавит/путь); отступления — где следующая ветвь
# даёт ИМЕННОЕ правило (полнота объявлений против живых пачек/манифеста).
_STANDART = {
    ('str', 'udalen'): _SN2, ('str', 'pustoe'): _SN2,
    ('str', 'chuzhoj'): _SN2,
    ('list', 'udalen'): _SN2, ('list', 'pustoe'): _SN2,
    ('list', 'chuzhoj'): _SN2,
    ('dict', 'udalen'): _SN2, ('dict', 'pustoe'): _SN2,
    ('dict', 'chuzhoj'): _SN2, ('dict', 'podmnozhestvo'): _SN2,
    ('int', 'udalen'): _SN2, ('int', 'pustoe'): _SN2,
    ('int', 'chuzhoj'): _SN2,
    ('bool', 'udalen'): _SN2, ('bool', 'chuzhoj'): _SN2,
    ('NoneType', 'udalen'): _SN2, ('NoneType', 'chuzhoj'): _SN2,
}
_RUCHNYE = {
    ('top', 'ne_trogaet', 'pustoe'): {
        'rc': 1, 'pravila': ('NE_TROGAET_NE_POLON',)},
    ('top', 'ne_trogaet', 'podmnozhestvo'): {
        'rc': 1, 'pravila': ('NE_TROGAET_NE_POLON',)},
    ('dv', 'perehody', 'pustoe'): {
        'rc': 1, 'pravila': ('PEREHODY_NE_POLNY',)},
    ('dv', 'sceny_znaka', 'pustoe'): {
        'rc': 1, 'pravila': ('SCENY_ZNAKA_NE_POLNY',)},
    ('dv', 'etalony', 'pustoe'): {
        'rc': 1, 'pravila': ('ETALON_BEZ_PINOV',)},
    ('top', 'operacii_api', 'pustoe'): (
        'IZJATO', 'честное значение — ПУСТОЙ список: подстановка пустого '
        'не меняет вход (грамматика допускает список без операций, '
        'замер rc 0)'),
    ('top', 'prokhodimost', 'pustoe'): (
        'IZJATO', 'пустой prokhodimost — краш v2-ветки эталона '
        '(traceback, не именованный отказ); v2-поле вне предмета 146, '
        'дефект — отдельный предмет (учётный маршрут 061)'),
    ('top', 'prokhodimost', 'podmnozhestvo'): (
        'IZJATO', 'краш v2-ветки эталона — как pustoe, вне предмета 146'),
}
# Классы списков perestanovka/podmnozhestvo — ZELENO при >=2 элементах
# (списки формы — множества, И-3), иначе IZJATO «мутация не меняет
# вход»; perestanovка/podmnozhestvo остальных родов и pustoe bool/null —
# IZJATO «класс не порождается родом значения».


def _zajavka(sloj, pole, klass):
    kljuch = (sloj, pole, klass)
    if kljuch in _RUCHNYE:
        return _RUCHNYE[kljuch]
    pole_zn = _FORMA_CH[pole] if sloj == 'top' \
        else _FORMA_CH['dvizhenie'][pole]
    rod = type(pole_zn).__name__
    if klass in ('perestanovka', 'podmnozhestvo'):
        if rod == 'list':
            if len(pole_zn) < 2:
                return ('IZJATO',
                        'меньше двух элементов — мутация не меняет вход')
            if klass == 'perestanovka':
                return ('ZELENO',
                        'списки формы — множества (И-3: перестановка '
                        'ekrany не меняет суд); свидетель — зелёная '
                        'клетка')
            return ('ZELENO',
                    'заявленное подмножество конформно: судится каждая '
                    'заявленная запись, полнота перечня извне не '
                    'пинуется')
        if klass == 'podmnozhestvo' and rod == 'dict':
            return _SN2
        return ('IZJATO', 'класс не порождается родом значения %s' % rod)
    if klass == 'pustoe' and rod in ('bool', 'NoneType'):
        return ('IZJATO',
                'пустое значение совпадает с честным либо не определено '
                'для %s' % rod)
    return _STANDART.get((rod, klass),
                         ('IZJATO', 'класс не порождается родом %s' % rod))


MATRICA_ZAJAVLENII = {}
for _sloj, _polja in (('top', FORMA_POLEJ_V3), ('dv', DV_POLEJ)):
    for _pole in _polja:
        for _klass in MUTACII_KLASSY:
            MATRICA_ZAJAVLENII[(_sloj, _pole, _klass)] = _zajavka(
                _sloj, _pole, _klass)
# podmnozhestvo списков блока dv покрыто поимёнными клетками полноты
# (perehody/ekrany/sceny-znaka-ne-polny-*) и новыми etalony-bez-pina-*
MATRICA_ZAJAVLENII[('dv', 'ekrany', 'podmnozhestvo')] = (
    'POKRYTO', 'ekrany-ne-polny-')
MATRICA_ZAJAVLENII[('dv', 'perehody', 'podmnozhestvo')] = (
    'POKRYTO', 'perehody-ne-polny-')
MATRICA_ZAJAVLENII[('dv', 'sceny_znaka', 'podmnozhestvo')] = (
    'POKRYTO', 'sceny-znaka-ne-polny-')
MATRICA_ZAJAVLENII[('dv', 'etalony', 'podmnozhestvo')] = (
    'POKRYTO', 'etalony-bez-pina-')
MATRICA_ZAJAVLENII[('dv', 'etalony', 'perestanovka')] = (
    'IZJATO', 'словарь — порядок ключей не определён')


def _matrica_mutacija(sloj, pole, klass):
    if klass == 'udalen':
        return lambda cel: cel.pop(pole, None)
    pole_zn = _FORMA_CH[pole] if sloj == 'top' \
        else _FORMA_CH['dvizhenie'][pole]
    rod = type(pole_zn).__name__
    if klass == 'pustoe':
        zn = {'str': '', 'list': [], 'dict': {}, 'int': 0}[rod]
    elif klass == 'chuzhoj':
        zn = {'str': 5, 'list': {}, 'dict': 'x', 'int': '3',
              'bool': 'x', 'NoneType': []}[rod]
    elif klass == 'perestanovka':
        return lambda cel: cel.__setitem__(pole, list(reversed(cel[pole])))
    elif rod == 'list':  # podmnozhestvo
        return lambda cel: cel.__setitem__(
            pole, cel[pole][:1] + cel[pole][2:])
    else:  # podmnozhestvo словаря
        return lambda cel: cel.__setitem__(
            pole, {k: v for k, v in cel[pole].items()
                   if k != sorted(cel[pole])[0]})
    return lambda cel: cel.__setitem__(pole, zn)


MATRICA_KLETKI = {}
MATRICA_ZELENYE = []
for (_sloj, _pole, _klass), _z in sorted(MATRICA_ZAJAVLENII.items()):
    _imja = 'matrica-%s-%s-%s' % (_sloj, _pole, _klass)
    if isinstance(_z, dict):
        MATRICA_KLETKI[_imja] = _z
        _mut = _matrica_mutacija(_sloj, _pole, _klass)

        def _primeni(pack, forma, repo, src, _s=_sloj, _m=_mut):
            _m(forma if _s == 'top' else forma['dvizhenie'])
            zapis(pack, forma)
        MUTACII[_imja] = _primeni
    elif _z[0] == 'ZELENO':
        _mut = _matrica_mutacija(_sloj, _pole, _klass)

        def _primeni_zelenyj(pack, forma, repo, src, _s=_sloj, _m=_mut):
            _m(forma if _s == 'top' else forma['dvizhenie'])
            zapis(pack, forma)
        MUTACII[_imja] = _primeni_zelenyj
        MATRICA_ZELENYE.append(_imja)

# семьи/клетки, зарегистрированные ПОСЛЕ общего цикла SEMEJSTVA →
# MUTACII (цикл выше уже прошёл)
for _imja in list(SEMEJSTVA):
    if _imja not in MUTACII:
        MUTACII[_imja] = _kletka_semji(_imja)
# Зелёные свидетели матрицы: статические ожидания (rc 0 + дословный
# stdout честного прогона) — прогон эталона ДО субъекта в том же мире
# оставил бы кадры несвежими (свежесть e2e разовая); свидетель судится
# одним прогоном в свежем мире, как chestnyj-d24-ekran.
ZELENYE_SVIDETELI = frozenset(MATRICA_ZELENYE) | {
    'etalony-piny-perestanovka', 'pole-treka-pustoe-element',
    'pole-treka-pustoe-reduced_duration_ms',
    'pole-treka-chuzhoj-element', 'scena-tracks-podmnozhestvo-poslednego'}

# Клетки с ожиданиями, вычисляемыми эталоном в памяти ДО субъекта
# (правило 8): сеяные, клетка всех переходов, все семьи с именованным
# правилом, полнота/равенства, источники, КРАСНЫЕ клетки матрицы.
# Список синхронен флагу vychisljaemyj в source.json (load_source).
VYCHISLJAEMYE = (
    frozenset(SEJANYE_GRAMMATIKA) | {
        'pruzhina-vo-vseh-perehodah', 'scena-v-poz-vne-perehodov'} | {
        n for n, s in SEMEJSTVA.items() if s['pravilo'] is not None} | {
        n for n in MUTACII
        if n and n.startswith(('perehody-ne-polny-', 'ekrany-ne-polny-',
                               'sceny-znaka-ne-polny-', 'istochnik-',
                               'matrica-', 'etalony-bez-pina-',
                               'perehod-bez-specy-'))}
    ) - ZELENYE_SVIDETELI


# --- каталог адресов и проверка покрытия (A.1) --------------------------------

def _chestny_mir(src):
    """Честные spec/manifest/poses/форма В ПАМЯТИ из доверенных
    носителей (до любых мутаций)."""
    spc = json.loads((D24_NOS / 'spec.json').read_text(encoding='utf-8'))
    forma = json.loads(json.dumps(src['ekran_forma_d24']))
    return spc, forma


def _ozhidaemye_treki(spc, forma):
    return set(_adresa_trekov(spc, forma))


def _ozhidaemye_vidimye(spc, forma):
    return {'%s:%d' % (pid, i + 1)
            for pid in _objavlennye(forma)
            for i, t in enumerate(_scena(spc, pid)['tracks'])
            if t['property'] in VIDIMYE}


def _ozhidaemye_nevidimye(spc, forma):
    return _ozhidaemye_treki(spc, forma) - _ozhidaemye_vidimye(spc, forma)


def katalog_i_pokrytie(src, seed=SEED_DEFOLT):
    """Механизм A.1: конечный каталог адресов из доверенных данных;
    каждая семья обязана затронуть РОВНО своё ожидаемое множество
    (пустая семья / пропуск / лишний адрес — ORACLE_TAMPERED rc 2).
    Развёртка seed 0..99: сеяные клетки покрывают ВСЕ переходы при любом
    seed — покрытие не решается seed'ом."""
    spc0, forma0 = _chestny_mir(src)
    vse_treki = _ozhidaemye_treki(spc0, forma0)
    vidimye = _ozhidaemye_vidimye(spc0, forma0)
    nevidimye = _ozhidaemye_nevidimye(spc0, forma0)
    perehody = set(_objavlennye(forma0))
    sceny = perehody
    problemy = []
    if not (vidimye and nevidimye):
        problemy.append('корпус без обоих классов УД (видимые=%d, '
                        'перемещение=%d)' % (len(vidimye), len(nevidimye)))
    svojstva = {t['property'] for pid in perehody
                for t in _scena(spc0, pid)['tracks']}
    if not {'opacity', 'bg'} <= svojstva:
        problemy.append('корпус без обеих видимых property УД: %s'
                        % sorted(svojstva))
    sem_vse_treki = {
        'dlitelnost-ms-vse-treki', 'dlitelnost-syroe-chislo-vse-treki',
        'dlitelnost-neizvestnyj-token-vse-treki',
        'zaderzhka-neizvestnyj-token-vse-treki',
        'zaderzhka-token-bez-ms-vse-treki',
        'zaderzhka-ms-neverno-vse-treki',
        'zaderzhka-mnogo-termonov-ne-soglasno',
        'krivaya-imja-vne-kanona-vse-treki',
        'krivaya-znachenie-vne-tokena-vse-treki',
        'pruzhina-na-kazhdom-treke', 'ud-bez-stolbca-vse-treki',
        'end-ms-neverno-vse-treki', 'zaderzhka-mnogo-termonov-soglasno',
        # матрица trek (Crit146c): трековые семьи трогают КАЖДЫЙ трек
        'pole-treka-udaleno-order', 'pole-treka-udaleno-element',
        'pole-treka-udaleno-property', 'pole-treka-udaleno-delay',
        'pole-treka-udaleno-duration', 'pole-treka-udaleno-end_ms',
        'pole-treka-udaleno-curve', 'pole-treka-udaleno-spring',
        'pole-treka-udaleno-reduced_duration_ms',
        'pole-treka-pustoe-delay',
        'pole-treka-pustoe-duration', 'pole-treka-pustoe-curve',
        'pole-treka-chuzhoj-property', 'pole-treka-chuzhoj-delay',
        'pole-treka-chuzhoj-duration', 'pole-treka-chuzhoj-curve',
        'pole-treka-chuzhoj-spring', 'pole-treka-chuzhoj-reduced_duration_ms'}
    for imja, semja in sorted(SEMEJSTVA.items()):
        spc, forma = copy.deepcopy(spc0), json.loads(
            json.dumps(forma0))
        adresa = set(semja['pravka'](spc, forma))
        if not adresa:
            problemy.append('семья %s пуста' % imja)
            continue
        if imja in sem_vse_treki and adresa != vse_treki:
            problemy.append('семья %s затронула %d из %d треков'
                            % (imja, len(adresa), len(vse_treki)))
        if imja == 'ud-peremeshchenie-vse-treki' and adresa != nevidimye:
            problemy.append('семья %s затронула %d из %d треков перемещения'
                            % (imja, len(adresa), len(nevidimye)))
        if imja == 'ud-cveta-vse-treki' and adresa != vidimye:
            problemy.append('семья %s затронула %d из %d видимых треков'
                            % (imja, len(adresa), len(vidimye)))
        if semja['izvlekatel'] == 'pid' and semja['storona'] == 'spec' \
                and adresa != sceny:
            problemy.append('семья %s затронула %s, объявлены %s'
                            % (imja, sorted(adresa), sorted(sceny)))
    # сеяные клетки: развёртка seed — покрытие всех переходов при любом
    for s in range(100):
        celi = {sejannyj_perehod(forma0, imja, s)
                for imja in SEJANYE_GRAMMATIKA}
        if celi != perehody:
            problemy.append('seed %d: сеяные клетки покрывают %s, '
                            'объявлены %s' % (s, sorted(celi),
                                              sorted(perehody)))
            break
    # зелёные контроли объявлены (A.7: «всё отвергать» не проходит)
    zelenvje = ('slice1-pachka', 'chestnyj-d24-ekran', 'ekrany-perestanovka',
                'zaderzhka-mnogo-termonov-soglasno')
    for z in zelenvje:
        if z not in MUTACII:
            problemy.append('нет зелёного контроля %s' % z)
    # матрица «поле × мутация» (Crit146c): полное перечисление поле ×
    # класс по перечню ИЗ КОДА ЭТАЛОНА; каждая заявленная красная и
    # зелёная клетка существует, POKRYTO-префиксы покрыты, у КАЖДОГО
    # поля хотя бы одна красная комбинация
    for _sloj, _polja in (('top', FORMA_POLEJ_V3), ('dv', DV_POLEJ)):
        for _pole in _polja:
            _krasnyh = 0
            for _klass in MUTACII_KLASSY:
                _z = MATRICA_ZAJAVLENII[(_sloj, _pole, _klass)]
                if isinstance(_z, dict):
                    _krasnyh += 1
                    if 'matrica-%s-%s-%s' % (_sloj, _pole, _klass) \
                            not in MUTACII:
                        problemy.append('матрица: нет клетки %s %s %s'
                                        % (_sloj, _pole, _klass))
                elif _z[0] == 'POKRYTO' and not any(
                        k.startswith(_z[1]) for k in MUTACII if k):
                    problemy.append('матрица: %s %s %s — префикс %s не '
                                    'покрыт' % (_sloj, _pole, _klass, _z[1]))
            if not _krasnyh:
                problemy.append('матрица: поле %s %s без красных '
                                'комбинаций' % (_sloj, _pole))
    _TREK_DOPOLNITELNO = {
        ('order', 'perestanovka'): ('poryadok-perestanovka-pervyj-'
                                    'poslednij', 'poryadok-seredina'),
        ('order', 'podmnozhestvo'): ('poryadok-propusk-poslednej',
                                     'poryadok-dubl-poslednej'),
    }
    for (_pole, _klass), (_imja, _pr, _iz, _pob) in sorted(
            _TREK_ZAJAVKI.items()):
        if _imja not in SEMEJSTVA:
            problemy.append('матрица trek: нет семьи %s' % _imja)
    for _pole in POLEJ_TREKA:
        for _klass in MUTACII_KLASSY:
            if (_pole, _klass) in _TREK_ZAJAVKI \
                    or (_pole, _klass) in _TREK_DOPOLNITELNO \
                    or (_pole, _klass) in _TREK_IZJATO:
                continue
            if _klass in ('perestanovka', 'podmnozhestvo'):
                continue  # скаляр: класс не порождается родом значения
            problemy.append('матрица trek: %s %s не заявлен'
                            % (_pole, _klass))
    for _para, _imena in _TREK_DOPOLNITELNO.items():
        for _imja in _imena:
            if _imja not in SEMEJSTVA:
                problemy.append('матрица trek: нет семьи %s (order %s)'
                                % (_imja, _para[1]))
    for (_pole, _klass), (_imja, _pr, _pob) in _SCENA_ZAJAVKI.items():
        if _imja not in SEMEJSTVA:
            problemy.append('матрица scena: нет семьи %s' % _imja)
    _SCENA_POKRYTO = {
        ('keyframes_ms', 'podmnozhestvo'): 'kadry-net-procenta-25',
        ('files', 'podmnozhestvo'): 'fajly-video-bez-temy-',
    }
    for (_pole, _klass), _prefiks in _SCENA_POKRYTO.items():
        if not any(k.startswith(_prefiks) for k in SEMEJSTVA):
            problemy.append('матрица scena: %s %s не покрыт (%s)'
                            % (_pole, _klass, _prefiks))
    for _pole in SCENA_POLEJ:
        if not any(p == _pole for (p, _k) in _SCENA_ZAJAVKI):
            problemy.append('матрица scena: поле %s без клеток' % _pole)
    if 'scena-tracks-podmnozhestvo-poslednego' not in SEMEJSTVA:
        problemy.append('матрица scena: нет зелёного свидетеля '
                        'tracks-podmnozhestvo-poslednego')
    # пины ВСЕХ индексов каждой темы (Crit146c-1)
    for _i in range(_MAX_PINOV):
        if 'etalon-pin-%d-ne-hex' % _i not in SEMEJSTVA:
            problemy.append('нет семьи пина индекса %d' % _i)
    # сцена спеки КАЖДОГО объявленного перехода + эталоны КАЖДОГО pid
    for _pid in sorted(perehody):
        for _imja in ('perehod-bez-specy-%s' % _pid.lower(),
                      'etalony-bez-pina-%s' % _pid.lower()):
            if _imja not in MUTACII:
                problemy.append('матрица: нет клетки %s' % _imja)
    if 'perehody-bez-specy-vse' not in SEMEJSTVA:
        problemy.append('матрица: нет семьи perehody-bez-specy-vse')
    print('KATALOG perehodov=%d trekov=%d vidimyh=%d peremeshchenija=%d '
          'semey=%d' % (len(perehody), len(vse_treki), len(vidimye),
                        len(nevidimye), len(SEMEJSTVA)))
    _m_znach = list(MATRICA_ZAJAVLENII.values())
    print('MATRICA polej=%d kletok=%d zelenyh-svidetelej=%d izjatij=%d '
          'pokryto=%d pinnyh-indeksov=%d'
          % (len(FORMA_POLEJ_V3) + len(DV_POLEJ),
             sum(1 for z in _m_znach if isinstance(z, dict)),
             sum(1 for z in _m_znach
                 if isinstance(z, tuple) and z[0] == 'ZELENO'),
             sum(1 for z in _m_znach
                 if isinstance(z, tuple) and z[0] == 'IZJATO'),
             sum(1 for z in _m_znach
                 if isinstance(z, tuple) and z[0] == 'POKRYTO'),
             _MAX_PINOV))
    if problemy:
        for p in problemy:
            print('ORACLE_TAMPERED: каталог — %s' % p, file=sys.stderr)
        raise SystemExit(2)


# --- суд входа ---------------------------------------------------------------

def zapusk(subject, pack, repo):
    p = subprocess.run(
        [sys.executable, str(subject), '--pack', str(pack),
         '--repo', str(repo), '--harness', str(H_ROOT)],
        capture_output=True, text=True)
    return p.returncode, p.stdout, p.stderr


def _nazvyvaet(stroki, pid):
    """Отказ называет переход СТРУКТУРНО: pid — самостоятельное поле
    либо префикс поля до ':' (Н-38: токен в своей секции, не подстрока
    где угодно; GA-R2 ≠ GA-R2-393)."""
    for l in stroki:
        for pole in l.split('\t')[1:]:
            if pole == pid or pole.split(':')[0].strip() == pid:
                return True
    return False


_KESH_OZHIDANIJ = {}


def _izvlek_adres(detail, vid):
    """Адрес из detail причины по виду семьи (A.7: ожидаемое имя правила
    И точный адрес — не любое упоминание pid)."""
    if vid == 'trek':
        tok = detail.split(' ')[0]
        return tok[:-1] if tok.endswith(':') else tok
    if vid == 'etalon':
        ch = detail.split(' ')
        if ch[1:2] == ['video']:
            return ' '.join(ch[:3])
        return ' '.join(ch[:2])
    return detail.split(' ')[0].rstrip(':')


def vychisl_ozhidanija(name, pack, repo, pid, forma, src, seed, hesh):
    """Ожидания вычислимой клетки — ЭТАЛОН в памяти ДО субъекта
    (правило 8; прецедент p14/p15 батареи 145): честный прогон модели
    на ТОМ ЖЕ входе. Оракульные проверки (A.7/B.9): эталон обязан
    отказаться/пройти с объявленным rc, БЕЗ traceback (краш эталона —
    ошибка оракула, никогда пойманный стаб); для семей — назвать
    именованное правило и РОВНО ожидаемое множество адресов; для сеяных
    клеток — назвать сеяный переход (клетки всех переходов — КАЖДЫЙ
    объявленный). Кеш различает клетку, seed И весь вход (хеш байтов
    пачки+источников) — повторные прогоны субъока не пересчитывают."""
    kljuch = (name, seed, hesh)
    if kljuch not in _KESH_OZHIDANIJ:
        rc, out, err = zapusk(MODEL, pack, repo)
        prichiny = [l for l in err.splitlines()
                    if l.startswith('PRICHINA\t')]
        stat = src['kejsy'][name]
        if 'Traceback' in err:
            print('ORACLE_TAMPERED: клетка %s — краш эталона (traceback), '
                  'rc=%d' % (name, rc), file=sys.stderr)
            raise SystemExit(2)
        if rc != stat['rc'] or (stat['rc'] != 0 and not prichiny):
            print('ORACLE_TAMPERED: вычислимая клетка %s: эталон rc=%d, '
                  'причин %d, статично ожидается rc=%d'
                  % (name, rc, len(prichiny), stat['rc']), file=sys.stderr)
            raise SystemExit(2)
        semn = ZATRONUTYE.get(name)
        if semn is not None and semn['pravilo'] is not None:
            # pobochnye — правила, неизбежно сопутствующие главному
            # (Crit146c: удаление поля роняет и порядок); адреса
            # сравниваются ТОЛЬКО по главному правилу семьи
            dop = semn.get('pobochnye') or frozenset()
            glavnye = [l for l in prichiny
                       if l.split('\t')[1] == semn['pravilo']]
            chuzhie = sorted({l.split('\t')[1] for l in prichiny}
                             - {semn['pravilo']} - dop)
            if chuzhie or not glavnye:
                print('ORACLE_TAMPERED: клетка %s — эталон назвал правила '
                      '%s, ожидалось %s (+побочные %s)' % (
                          name, sorted({l.split('\t')[1] for l in prichiny}),
                          semn['pravilo'], sorted(dop)), file=sys.stderr)
                raise SystemExit(2)
            adr_fakt = [_izvlek_adres(l.split('\t', 2)[2],
                                      semn['izvlekatel'])
                        for l in glavnye]
            adr_ozhidaemye = sorted(set(semn['adresa']))
            if sorted(set(adr_fakt)) != adr_ozhidaemye or \
                    len(adr_fakt) != len(adr_ozhidaemye):
                print('ORACLE_TAMPERED: клетка %s — адреса причин %s, '
                      'ожидались %s' % (name, sorted(set(adr_fakt)),
                                        adr_ozhidaemye), file=sys.stderr)
                raise SystemExit(2)
        zajav = MATRICA_KLETKI.get(name)
        if zajav is not None:
            # матрица «поле × мутация»: заявленный rc и РОВНО заявленные
            # имена правил (заявление — независимая константа, факт —
            # эталон; расхождение = дефект матрицы либо эталона)
            fakt_pravila = sorted({l.split('\t')[1] for l in prichiny})
            if rc != zajav['rc'] or fakt_pravila != sorted(zajav['pravila']):
                print('ORACLE_TAMPERED: клетка матрицы %s — rc=%d правила '
                      '%s, заявлено rc=%d %s' % (
                          name, rc, fakt_pravila, zajav['rc'],
                          list(zajav['pravila'])), file=sys.stderr)
                raise SystemExit(2)
        dolzhny = [pid] if pid is not None else (
            sorted(forma['dvizhenie']['perehody'])
            if name == 'pruzhina-vo-vseh-perehodah' else [])
        for p in dolzhny:
            if not _nazvyvaet(prichiny, p):
                print('ORACLE_TAMPERED: клетка %s — отказ эталона не '
                      'называет переход %s' % (name, p), file=sys.stderr)
                raise SystemExit(2)
        _KESH_OZHIDANIJ[kljuch] = {'rc': rc, 'stdout': out.splitlines(),
                                   'prichiny': prichiny}
    return _KESH_OZHIDANIJ[kljuch]


def _hesh_mira(pack, repo, forma):
    """Хеш всего входа клетки (A.7: кеш различает весь вход): байты
    пачки + трёх источников движения. Устойчив к клеткам матрицы,
    удаляющим ключи dvizhenie (пути могут отсутствовать)."""
    ch = [sha256_fajla(pack / 'ekran.json')]
    dv = forma.get('dvizhenie') if isinstance(forma, dict) else None
    if not isinstance(dv, dict):
        dv = {}
    for imja in ('manifest', 'spec', 'pozvonok'):
        otn = dv.get(imja)
        p = repo / otn if isinstance(otn, str) else None
        ch.append(sha256_fajla(p) if p is not None and p.is_file()
                  else 'otsutstvuet')
    return hashlib.sha256('|'.join(ch).encode('utf-8')).hexdigest()


def sud_vhoda(subject, name, src, seed=SEED_DEFOLT):
    """Вход + суд: строит вход кодом (MUTACII; для сеяных клеток цель —
    sejannyj_perehod, без литерала pid), для вычислимых клеток считает
    ожидания эталоном ДО субъекта, запускает субъект. Возвращает
    (exp | None, act, pid | None)."""
    tmp = Path(tempfile.mkdtemp(prefix='ekran146-'))
    try:
        if name == 'slice1-pachka':
            pack, forma = build_pack(src, tmp)
            repo = build_repo(src, tmp, pack, d24=False)
        else:
            pack, forma = build_pack_d24(src, tmp)
            repo = build_repo(src, tmp, pack)
        pid = sejannyj_perehod(forma, name, seed) \
            if name in SEJANYE_GRAMMATIKA else None
        if MUTACII[name] is not None:
            if pid is not None:
                MUTACII[name](pack, forma, repo, src, pid)
            else:
                MUTACII[name](pack, forma, repo, src)
        forma_telesh = _forma_d24(pack) if name != 'slice1-pachka' \
            else forma
        exp = None
        if name in VYCHISLJAEMYE:
            hesh = _hesh_mira(pack, repo, forma_telesh)
            exp = vychisl_ozhidanija(name, pack, repo, pid, forma_telesh,
                                     src, seed, hesh)
        rc, out, err = zapusk(subject, pack, repo)
        act = {'rc': rc, 'stdout': out.splitlines(),
               'prichiny': [l for l in err.splitlines()
                            if l.startswith('PRICHINA\t')]}
        return exp, act, pid
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def stroka_shoditsja(exp_line, act_line, dopusk):
    """Строка stdout сходна: KADR-числа — в допуске, остальное — точно."""
    e, a = exp_line.split('\t'), act_line.split('\t')
    if len(e) != len(a):
        return False
    for i, (x, y) in enumerate(zip(e, a)):
        if i == 2 and x and y:
            try:
                if abs(float(x) - float(y)) <= dopusk:
                    continue
            except ValueError:
                pass
        if x != y:
            return False
    return True


def judge(name, src, act, exp=None):
    """Сходство факта с ожиданием: exp=None — литералы kejsy source.json,
    иначе — вычисленные эталоном ДО субъекта (та же форма записи)."""
    problemy = []
    ozh = exp if exp is not None else src['kejsy'][name]
    if act['rc'] != ozh['rc']:
        problemy.append('rc=%d, ожидался %d' % (act['rc'], ozh['rc']))
    if sorted(act['prichiny']) != sorted(ozh['prichiny']):
        problemy.append('prichiny=%r, ожидались %r'
                        % (sorted(act['prichiny']),
                           sorted(ozh['prichiny'])))
    exp_out, act_out = ozh.get('stdout', []), act['stdout']
    if len(exp_out) != len(act_out) or not all(
            stroka_shoditsja(x, y, src['dopusk_score'])
            for x, y in zip(exp_out, act_out)):
        problemy.append('stdout=%r, ожидался %r' % (act_out, exp_out))
    return problemy


def snapshot(src, seed=SEED_DEFOLT):
    """Фактические rc/вывод эталона по каждому входу (инструмент замера;
    вычислимые клетки — с сеяным распределением цели под данным seed)."""
    data = {}
    for name in src['kejsy']:
        _, act, _ = sud_vhoda(MODEL, name, src, seed)
        data[name] = act
    print(json.dumps(data, ensure_ascii=False, indent=1))
    return 0


# --- живой прогон против РЕАЛЬНЫХ источников D 2.4 (норма 146+) --------------

def _mulberry32(zerno):
    """Детерминированный PRNG (mulberry32, как p14 батареи 145): сеяный
    выбор стабилен между запусками и версиями python (нет хеш-порядка)."""
    zerno = zerno & 0xFFFFFFFF

    def rnd():
        nonlocal zerno
        zerno = (zerno + 0x6D2B79F5) & 0xFFFFFFFF
        x = zerno
        x = ((x ^ (x >> 15)) * (x | 1)) & 0xFFFFFFFF
        x = (x + (((x ^ (x >> 7)) * (x | 61)) & 0xFFFFFFFF) ^ x) \
            & 0xFFFFFFFF
        return ((x ^ (x >> 14)) & 0xFFFFFFFF) / 4294967296
    return rnd


def _ataka_pruzhina(sc, tk):
    sc['tracks'][0]['spring'] = {'stiffness': 180, 'damping': 20}
    return True


def _ataka_krivaya(sc, tk):
    sc['tracks'][0]['curve'] = {
        'token': 'ease-in-out', 'value': 'cubic-bezier(0.4, 0, 0.2, 1)'}
    return True


def _ataka_dlitelnost(sc, tk):
    sc['tracks'][0]['duration'] = {'token': '200', 'ms': 150.0}
    return True


def _ataka_zaderzhka(sc, tk):
    sc['tracks'][0]['delay'] = {'token': 'позже камня', 'ms': 0.0}
    return True


def _ataka_ud_peremeshchenie(sc, tk):
    for t in sc['tracks']:
        if t['property'] not in VIDIMYE:
            t['reduced_duration_ms'] = 10.0
            return True
    return False


def _ataka_ud_cveta(sc, tk):
    for t in sc['tracks']:
        if t['property'] in VIDIMYE:
            t['reduced_duration_ms'] = 400.0
            return True
    return False


def _ataka_end_ms(sc, tk):
    sc['tracks'][0]['end_ms'] = 42.0
    return True


def _ataka_poryadok(sc, tk):
    if len(sc['tracks']) < 2:
        return False
    tr = sc['tracks']
    tr[0]['order'], tr[1]['order'] = tr[1]['order'], tr[0]['order']
    return True


def _ataka_kadry(sc, tk):
    kf = sc.get('keyframes_ms')
    if not (isinstance(kf, dict) and '25' in kf):
        return False
    kf['25'] = 100.0
    return True


ATAKI_GRAMMATIKI = (_ataka_pruzhina, _ataka_krivaya, _ataka_dlitelnost,
                    _ataka_zaderzhka, _ataka_ud_peremeshchenie,
                    _ataka_ud_cveta, _ataka_end_ms, _ataka_poryadok,
                    _ataka_kadry)




def _real_istochniki(repo, bazovyj):
    man = json.loads((repo / bazovyj / 'pack/gespraech-final2-manifest.json')
                     .read_text(encoding='utf-8'))
    spc = json.loads(
        (repo / bazovyj / 'motion/motion-spec-gespraech.json')
        .read_text(encoding='utf-8'))
    poz = json.loads(
        (repo / bazovyj / 'motion/faden-poses-gespraech.json')
        .read_text(encoding='utf-8'))
    return man, spc, poz


def _kontekst_piny(repo, bazovyj, src):
    """A.6: режим --d24-real сверяет три piny.kontekst с ФАКТИЧЕСКИМИ
    байтами реальных источников и называет SHA продукта/входов."""
    pary = (('realnyj-manifest', 'pack/gespraech-final2-manifest.json'),
            ('realnaja-speka', 'motion/motion-spec-gespraech.json'),
            ('realnyj-pozvonok', 'motion/faden-poses-gespraech.json'))
    stroki, ok = [], True
    for imja, otn in pary:
        p = repo / bazovyj / otn
        fakt = sha256_fajla(p) if p.is_file() else 'OTSUTSTVUET'
        pin = src['piny']['kontekst'][imja]
        stroki.append('%s=%s' % (imja, 'OK' if fakt == pin
                                 else 'NE_SOVPADAET'))
        if fakt != pin:
            ok = False
            print('D24_REAL_PINY %s: фактический %s != пин %s'
                  % (imja, fakt, pin))
    head = 'net-git'
    try:
        r = subprocess.run(['git', '-C', str(repo), 'rev-parse', 'HEAD'],
                           capture_output=True, text=True, timeout=30)
        if r.returncode == 0:
            head = r.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        pass
    print('D24_REAL_PINY %s product=%s model_sha256=%s'
          % (' '.join(stroki), head, sha256_fajla(MODEL)))
    return ok


def _real_pokrytie(m, spc, perehody, tk):
    """B.10: конечное структурное покрытие семей A.3–A.5 по РЕАЛЬНОМУ
    корпусу прямым вызовом _grammatika_sceny: каждая семья применяется
    ко ВСЕМ объявленным сценам разом (копии в памяти), ожидаемые адреса
    считаются из самих источников ДО прогона и сравниваются с адресами
    фактических отказов ПОЛНЫМИ множествами (A.1: пропуск/повтор вместо
    другого адреса — неисправность, не зелено). Это проба грамматики
    реальной спеки веткой эталона, НЕ e2e-прогон валидатора."""
    forma = {'dvizhenie': {'perehody': sorted(perehody)}}
    sceny = {s['id']: s for s in spc['scenes']}
    sem_real = {i: s for i, s in SEMEJSTVA.items() if s['real']}
    zelenye, otkazy = 0, []
    for imja, semja in sorted(sem_real.items()):
        spc_k = copy.deepcopy(spc)
        ozhidaemye = set(semja['pravka'](spc_k, forma))
        if not ozhidaemye:
            otkazy.append('%s: пустая семья на реальном корпусе' % imja)
            continue
        sceny_k = {s['id']: s for s in spc_k['scenes']}
        fakt = set()
        vse_prichin = []
        for pid in sorted(perehody):
            if pid not in sceny_k:
                continue
            prichiny = m._grammatika_sceny(sceny_k[pid], tk, pid)
            vse_prichin += prichiny
            for l in prichiny:
                # адреса — только по главному правилу семьи; побочные
                # (PORYADOK при удалении поля) в полноту не входят
                if semja['pravilo'] is None \
                        or l.split('\t')[1] != semja['pravilo']:
                    continue
                fakt.add(_izvlek_adres(l.split('\t', 2)[2],
                                       semja['izvlekatel']))
        if semja['pravilo'] is None:
            # зелёная семья на реальном корпусе: ЛЮБОЙ отказ — дефект
            # покрытия (проверка «всё отвергать» не проходит — A.7)
            if vse_prichin:
                otkazy.append('%s: зелёная семья дала отказы %s'
                              % (imja, sorted({l.split('\t')[1]
                                               for l in vse_prichin})[:3]))
                continue
            zelenye += 1
            continue
        if fakt != ozhidaemye:
            otkazy.append('%s: адреса %d из %d (пример-пропуск: %s)'
                          % (imja, len(fakt), len(ozhidaemye),
                             sorted(ozhidaemye - fakt)[:2]))
        else:
            zelenye += 1
    return zelenye, len(sem_real), otkazy


def d24_real(repo_put, seed=SEED_DEFOLT):
    """Реальный канон (B.10): пины kontekst (A.6) → честный контроль
    всех сцен реальной спеки веткой эталона (без ложных красных) →
    конечное структурное покрытие семей A.3–A.5 по реальному корпусу
    (полные множества адресов) → сеяная атака значения на каждой сцене.
    Живые v3-пачки — контракты 147+; это НЕ полный end-to-end прогон
    валидатора и НЕ утверждение «реальный v3 экран принят»."""
    src = load_source()
    repo = Path(repo_put).resolve()
    m = _zagruzhi_model()
    bazovyj = 'docs/ux/04_Gespraech_D24'
    if not _kontekst_piny(repo, bazovyj, src):
        print('D24_REAL: KRASNO — kontekst-пины не совпадают с байтами '
              'репо (A.6)', file=sys.stderr)
        return 2
    man, spc, poz = _real_istochniki(repo, bazovyj)
    tk = m._tokeny(spc)
    sceny_poz = set(poz['scenes'])
    perehody = [x['id'] for x in man['motion']]
    bad = []
    sceny = {s['id']: s for s in spc['scenes']}
    for pid in sorted(perehody):
        if pid not in sceny:
            bad.append('нет сцены спеки: %s' % pid)
            continue
        bad += m._grammatika_sceny(sceny[pid], tk, pid)
    sceny_znaka = sorted(set(perehody) & sceny_poz)
    print('D24_REAL ekranov=%d dvizhenija=%d scen_znaka=%d scen_speki=%d '
          'trekov=%d tokenov=%d'
          % (len(man['screens']), len(perehody), len(sceny_znaka),
             len(sceny), sum(len(s['tracks']) for s in spc['scenes']),
             len(spc['tokens'])))
    for b in bad:
        print(b)
    if bad:
        print('D24_REAL: KRASNO — %d отказов грамматики' % len(bad))
        return 1
    zelenye, vsego, otkazy = _real_pokrytie(m, spc, perehody, tk)
    print('D24_REAL_POKRYTIE semey=%d soglasnyh=%d adresnyh-polnoty=OK'
          % (vsego, zelenye))
    for o in otkazy:
        print(o)
    if otkazy:
        print('D24_REAL_POKRYTIE: KRASNO — %d из %d семей неполны'
              % (len(otkazy), vsego))
        return 1
    # сеяная атака: каждая сцена — свой сеяный дефект, канон обязан
    # отказать на КАЖДОМ объявленном переходе реальной спеки
    gsp = _mulberry32(seed ^ 0x9e3779b9)
    atak, otkazov, probki = 0, 0, []
    for sc in spc['scenes']:
        kopija = copy.deepcopy(sc)
        nachalo = int(gsp() * len(ATAKI_GRAMMATIKI))
        primenima = None
        for sdvig in range(len(ATAKI_GRAMMATIKI)):
            pravilo = ATAKI_GRAMMATIKI[(nachalo + sdvig)
                                       % len(ATAKI_GRAMMATIKI)]
            if pravilo(kopija, tk):
                primenima = pravilo
                break
        if primenima is None:
            probki.append('%s: нет применимого правила атаки' % sc['id'])
            continue
        atak += 1
        otkaz = m._grammatika_sceny(kopija, tk, sc['id'])
        if otkaz and _nazvyvaet(otkaz, sc['id']):
            otkazov += 1
        else:
            probki.append('%s: сеяный дефект (%s) не даёт отказа, '
                          'называющего сцену' % (sc['id'],
                                                 primenima.__name__))
    print('D24_REAL_ATAKA scen=%d atak=%d otkazov=%d seed=%d pravil=%d'
          % (len(spc['scenes']), atak, otkazov, seed,
             len(ATAKI_GRAMMATIKI)))
    for p in probki:
        print(p)
    if bad or probki or otkazov != atak:
        print('D24_REAL_ATAKA: KRASNO — канон отказал на %d из %d сцен'
              % (otkazov, atak))
        return 1
    print('D24_REAL: ZELEN — грамматика реальной спеки проходит ветку '
          'dvizhenie эталона без отказов; структурное покрытие семей '
          'A.3–A.5 по реальному корпусу полно; сеяный дефект на КАЖДОЙ '
          'из %d сцен отказом назван' % atak)
    return 0


# --- дифференциал совместимости (C.11) ----------------------------------------

class E2EGranica(Exception):
    """Измерительная граница статической пробы: единственный перехват —
    первая дорогая функция run_priemka_e2e ДО запуска команды; НЕ
    заглушка проверок данных."""


def _kod_versii(ssylka):
    r = subprocess.run(['git', '-C', str(H_ROOT), 'show',
                        '%s:scripts/ekran_shablon.py' % ssylka],
                       capture_output=True, timeout=60)
    if r.returncode != 0:
        raise RuntimeError('git show %s: rc=%d' % (ssylka, r.returncode))
    return r.stdout


def _modul_iz_koda(kod, imja):
    mod = types.ModuleType(imja)
    mod.__file__ = imja
    exec(compile(kod, imja, 'exec'), mod.__dict__)
    return mod


def _granica_versii(kod, imja, pack, repo):
    mod = _modul_iz_koda(kod, imja)
    mod.run_priemka_e2e = lambda f, r: (_ for _ in ()).throw(
        E2EGranica('run_priemka_e2e'))
    try:
        rc = mod.main(['--pack', str(pack), '--repo', str(repo),
                       '--harness', str(H_ROOT)])
    except E2EGranica:
        return 'STATIC_BOUNDARY_REACHED; E2E_NOT_RUN'
    return 'RETURNED rc=%s' % rc


def differencial(repo_put):
    """C.11: три уровня совместимости, названные раздельно и честно.
    (1) Статическая проба на двух НАСТОЯЩИХ пачках продукта: v1
    (frozen 132/2), v2 (база родителя коммита, сверена по sha256) и
    v3 (эталон батареи) — порознь, байты версий НЕ меняются; единственный
    перехват — run_priemka_e2e (E2EGranica) ДО команды; все три обязаны
    дойти до границы одинаково, без stdout/stderr. (2) Равенство v2/v3
    на честной v2-форме слайса-1 (prokhodimost/vtoroj_profil) — полный
    прогон обеих версий на одинаково построенных мирах, rc/stdout/причины
    равны. Готового skip-флага приёмки НЕТ и не добавляется; полная
    совместимость исполнения на продукте — только живой CI (C.12)."""
    repo_prod = Path(repo_put).resolve()
    v1 = _kod_versii('frozen/contracts/132/2')
    v2 = _kod_versii('HEAD^')
    v3 = MODEL.read_bytes()
    versii = (('v1-frozen132', v1, V1_FROZEN_SHA256),
              ('v2-baza-roditelja', v2, V2_BAZA_SHA256),
              ('v3-model', v3, sha256_bytes(v3)))
    for imja, kod, pin in versii:
        fakt = sha256_bytes(kod)
        print('DIFF_VERSIJA %s sha256=%s%s' % (
            imja, fakt, '' if fakt == pin else ' (ОТЛИЧАЕТСЯ от заявленной)'))
        if fakt != pin:
            return 2
    pachki = ('mobile/e2e-first-run', 'mobile/e2e-erstinformation')
    itogi = {}
    for pachka in pachki:
        tmp = Path(tempfile.mkdtemp(prefix='ekran146-diff-'))
        try:
            kopia = tmp / 'repo'
            shutil.copytree(repo_prod, kopia)
            for ek in ('maestro-out-first-run', 'maestro-out-erstinformation'):
                (kopia / 'mobile' / ek).mkdir(parents=True, exist_ok=True)
            for imja, kod, _ in versii:
                rez = _granica_versii(kod, imja, kopia / pachka, kopia)
                itogi[(pachka, imja)] = rez
                print('DIFF %s %s %s' % (pachka, imja, rez))
        finally:
            shutil.rmtree(tmp, ignore_errors=True)
    granicy = {itogi[(p, i)] for p in pachki for i, _, _ in versii}
    if granicy != {'STATIC_BOUNDARY_REACHED; E2E_NOT_RUN'}:
        print('DIFF: KRASNO — версии разошлись до границы эмулятора',
              file=sys.stderr)
        return 1
    # v2-форма слайса-1: полный прогон обеих версий на равных мирах
    src = load_source()
    v2_fajl = None
    with tempfile.TemporaryDirectory(prefix='ekran146-v2f-') as t:
        tmp = Path(t)
        (tmp / 'v2-ekran-shablon.py').write_bytes(v2)
        v2_fajl = tmp / 'v2-ekran-shablon.py'
        rezultaty = []
        for subj in (v2_fajl, MODEL):
            tmp2 = Path(tempfile.mkdtemp(prefix='ekran146-v2m-'))
            try:
                pack, forma = build_pack(src, tmp2)
                repo = build_repo(src, tmp2, pack, d24=False)
                rc, out, err = zapusk(subj, pack, repo)
                rezultaty.append((rc, out.splitlines(),
                                  [l for l in err.splitlines()
                                   if l.startswith('PRICHINA\t')]))
            finally:
                shutil.rmtree(tmp2, ignore_errors=True)
    if rezultaty[0] != rezultaty[1]:
        print('DIFF_V2_FORMA: KRASNO — v2=%r v3=%r' % (rezultaty[0],
                                                       rezultaty[1]),
              file=sys.stderr)
        return 1
    print('DIFF_V2_FORMA soglasno: rc=%d, stdout=%d строк, причин=%d — '
          'старый v2 и кандидат v3 равны на честной v2-форме слайса-1'
          % (rezultaty[0][0], len(rezultaty[0][1]),
             len(rezultaty[0][2])))
    print('DIFF: ZELEN — три версии одинаково доходят до границы '
          'эмулятора на обеих реальных пачках; v2/v3 равны на v2-форме')
    return 0


# --- самопроба оракула: порча носителей (A.6) ---------------------------------

def oracle_tamper():
    """Порча КАЖДОГО доверенного носителя piny.nositeli по одному в
    одноразовой копии батареи: probe.py обязан дать ORACLE_TAMPERED
    rc 2 ДО клеток (проверяющая сторона не судит по испорченному
    оракулу)."""
    src = load_source()
    tmp = Path(tempfile.mkdtemp(prefix='ekran146-tamper-'))
    try:
        kopia = tmp / 'batareja'
        shutil.copytree(HERE, kopia,
                        ignore=shutil.ignore_patterns('__pycache__'))
        provereno, slomano = 0, []
        ishodniki = {rel: (HERE / rel).read_bytes()
                     for rel in sorted(src['piny']['nositeli'])}
        for rel in sorted(ishodniki):
            for r2, bajty in ishodniki.items():
                (kopia / r2).write_bytes(bajty)
            cel = kopia / rel
            cel.write_bytes(ishodniki[rel] + b'X')
            r = subprocess.run([sys.executable, str(kopia / 'probe.py'),
                                '--model'], capture_output=True, text=True,
                               timeout=600)
            provereno += 1
            if r.returncode != 2 or 'ORACLE_TAMPERED' not in r.stderr \
                    or rel not in r.stderr:
                slomano.append('%s rc=%d stderr=%r' % (rel, r.returncode,
                                                       r.stderr[:120]))
        for r2, bajty in ishodniki.items():
            (kopia / r2).write_bytes(bajty)
        print('ORACLE_TAMPER_PROVERENO nositelej=%d' % provereno)
        if slomano:
            for s in slomano:
                print('ORACLE_TAMPER_NE_LOVITSJA: %s' % s, file=sys.stderr)
            return 1
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --- main ----------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    ap.add_argument('--snapshot', action='store_true')
    ap.add_argument('--d24-real', metavar='REPO')
    ap.add_argument('--differencial', metavar='REPO')
    ap.add_argument('--oracle-tamper', action='store_true')
    ap.add_argument('--seed', type=int, default=SEED_DEFOLT)
    a = ap.parse_args()
    if a.d24_real:
        return d24_real(a.d24_real, a.seed)
    if a.differencial:
        return differencial(a.differencial)
    if a.oracle_tamper:
        return oracle_tamper()
    src = load_source()
    if a.snapshot:
        return snapshot(src, a.seed)
    if not RUNNER123.is_file():
        print('SVERKA_123_ABSENT: раннер 123 не в дереве (инфраструктура)',
              file=sys.stderr)
        return 2
    katalog_i_pokrytie(src, a.seed)
    matrica = a.stabs or a.matrix
    subject = MODEL if (a.model or matrica) else SUBJECT
    if not a.model and not matrica and not SUBJECT.is_file():
        print('SHABLON_ABSENT')
        for name in src['kejsy']:
            print('CASE %s KRASNO (SHABLON_ABSENT)' % name)
        return 1
    kontrol_ok, svjazi, zelenyh = True, 0, 0
    pokrytie = {}
    for name in src['kejsy']:
        exp, act, pid = sud_vhoda(subject, name, src, a.seed)
        if pid is not None:
            pokrytie[name] = pid
        problemy = judge(name, src, act, exp)
        if problemy:
            kontrol_ok = False
            print('CASE %s KRASNO: %s' % (name, '; '.join(problemy)))
        else:
            zelenyh += 1
            print('CASE %s ok' % name)
    print('клеток %d, зелёных %d, красных %d'
          % (len(src['kejsy']), zelenyh, len(src['kejsy']) - zelenyh))
    objavleny = sorted(src['ekran_forma_d24']['dvizhenie']['perehody'])
    if pokrytie and sorted(set(pokrytie.values())) != objavleny:
        # механизм покрытия (правило без механизма не существует): сеяные
        # клетки обязаны накрыть ВСЕ объявленные переходы входа — иначе
        # оракул батареи недействителен при этом seed
        print('ORACLE_TAMPERED: сеяные клетки покрывают %s, объявлены %s'
              % (sorted(set(pokrytie.values())), objavleny), file=sys.stderr)
        return 2
    port_dosloven = True
    if not a.model and not matrica:
        # B.8: обычный приёмочный режим исполняет заявленное обязательство
        # «scripts/ekran_shablon.py == проверенный model/ekran_shablon.py»
        # ПОЛНЫМ побайтовым равенством (запускается именно этот путь).
        if SUBJECT.read_bytes() != MODEL.read_bytes():
            print('PORT_NE_DOOSLOVEN: scripts/ekran_shablon.py (sha256=%s, '
                  '%d строк) != model/ekran_shablon.py (sha256=%s, %d строк)'
                  ' — предмет требует дословного порта'
                  % (sha256_fajla(SUBJECT),
                     len(SUBJECT.read_text(encoding='utf-8').splitlines()),
                     sha256_fajla(MODEL),
                     len(MODEL.read_text(encoding='utf-8').splitlines())))
            port_dosloven = False
            kontrol_ok = False
        else:
            print('PORT_DOSLOVEN sha256=%s' % sha256_fajla(SUBJECT))
    if not matrica:
        return 0 if kontrol_ok else 1
    zhivye = 0
    for stub, vhody in sorted(src['stab_vhod'].items()):
        for v in vhody:
            svjazi += 1
            exp, act, _ = sud_vhoda(STUBS / stub, v, src, a.seed)
            if judge(v, src, act, exp):
                print('STAB %s %s KRASEN' % (stub, v))
            else:
                zhivye += 1
                print('STAB %s %s PROSHYOL' % (stub, v))
    if zhivye:
        print('STAB_ZHIV: %d' % zhivye)
        return 1
    if not kontrol_ok:
        return 1
    print('SVJAZI %d' % svjazi)
    return 0


if __name__ == '__main__':
    sys.exit(main())
