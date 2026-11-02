#!/usr/bin/env python3
# Батарея контракта 149 gespraech-tekst-chat (guard-канал §ПРОВОДКА).
# Субъекты: (1) живой валидатор 132 v3 scripts/ekran_shablon.py против
# эталона model/ekran_shablon.py (пин байтов) на мирах пачки; (2) машина
# текст-чата (модель model/chat-machine.ts; в продукте —
# mobile/src/features/conversation/chat-machine.ts) против пиннованной
# спеки дизайнера (раннер model/dvizhenie-runner.mjs); (3) пачка и канон
# в продукте (--repo); (4) CI-проводка экрана (--repo; И-8, блок Crit149
# круг 1): инстанциация ЛЕКАЛА screen-job.template.yml (frozen 143/2,
# копия-носитель в зоне, пин) тремя парными правками — запись карты,
# output выбора, needs обоих агрегатов — работник поднимает ОДИН
# эмулятор лекала (v+1 цикл 2, Crit149k2a ПОРЯДОК_AVD_393: параллельное
# расширение вторым boot СНЯТО — пару профилей ПОСЛЕДОВАТЕЛЬНО ведёт
# e2e.sh пачки: остановка первого, затем запуск 393; порядок судится
# ИСПОЛНЕНИЕМ в песочнице с двойниками SDK — клетка
# s-emuljatory-posledovatelno, параллельный job красен; слово владельца
# 2026-10-31) и выносом пачки общим шагом инвентаризации (обход критика:
# ekran.json={} без проводки проходил 82/82); (5) ПОЛНЫЙ СУД ПАЧКИ
# продукта тем же ЗАМОРОЖЕННЫМ валидатором v3 (блок 1 Crit149b: пачка
# {shablon,ekran,dvizhenie.ekrany} без источников/проходимости/профиля
# проходила rc 0 83/83 — клетка s-pachka-validirovana, собственных
# литеральных проверок полей нет — судит ТОЛЬКО валидатор по канону
# 132/146); (6) ИСПОЛНИМЫЙ зонд живого экрана (блок 1 Crit149b: реальный
# UI — чат-хост GespraechTekstChat и правка композера ChatComposer —
# доказывается jest-зондом на РЕАЛЬНЫХ компонентах R, прецедент
# ispolnimyj_sud 148; мутанты «пустой хост»/«композер не изменён»
# убиваются ассертами; клетка s-ekran-ispolnim; v+1 цикл 2: матрица
# несёт zona-12-* и token-24/token-20 — зона нажатия и высота строки
# поля на РЕАЛЬНОМ компоненте (зоны/токены — пакет 1.1, зонд судит
# использованную компонентом величину против значения токена); (7) маска
# шапки профиля 393 = 48 pt (слово владельца 31.10) — суд ЗНАЧЕНИЯ
# манифеста кадров R (s-profil-maska-393) и самоприменение пачки
# (d-paket-maska); зелень с 36 pt невозможна). Оракул — пины
# source.json (проверяются ДО любого субъекта) и ожидания, вычисленные
# ЭТАЛОНОМ на том же входе ДО субъекта (правило 8); каждая красная
# клетка несёт РОВНО одно имя причины.
#
# v2 (слово владельца 2026-11-02, пакет D24-Kompakt-1.1): эталонные кадры,
# токены и зоны касания — пакет docs/ux/05_Kompakt_D24 (носители
# nositeli/kompakt11/): kadry-манифесты пачки пинуют ИМЕНА кадров пакета
# с sha из frames/SHA256SUMS; стенд-ин e2e подаёт кадры 1.1 (реализация
# рендерит компактную шкалу); старый пин D 2.4 Final 2 грамматикой
# ПРИНИМАЕТСЯ (пути/ша честны против старых макетов мира), но красен
# ЖИВОЙ мерой 123 — клетка a-staroj-pin-d24 (KADR_NIZHE_POROGA; замер:
# 390-набор 10/12 кадров 0.315–0.597 < 0.600; неотличимы GA-13 dark
# 0.895/0.901, GA-17 dark 0.700/0.702, GA-17 light-393 0.656 — ловится
# полный набор, одиночная подмена — живой CI/vision). Движение пакет 1.1
# не меняет (motion-delta/tokens судит d-paket-dvizhenie): источники
# dvizhenie пачки — финал 2 (манифест экранов/переходов под грамматику
# v3, спека/позы — числа движения неизменны).
# Режимы (argv):
#   (без флага)   судится живое дерево харнесса: валидатор scripts/ (v3
#                 в main — клетки a-* зелены равенством), в продукте
#                 субъекта нет — клетки m-*/s-* красны поимённо
#                 (SUBJECT_ABSENT: зелень без субъекта невозможна)
#   --model       субъект = эталон (контроль входов)
#   --stabs       контроль + матрица обманных стабов (SVJAZI N, живых 0)
#   --repo R      судится живой продукт R (машина/канон/пачка/экран)
#   --a-derevo P C  (служебный) живой рецепт И-8: продукт P -> A-дерево C
#                 (карта+job из лекала+output+needs+пачка+референс
#                 экрана) — зелёный контроль клеток s-* (W --repo C)
#   --oracle-tamper  порча каждого носителя по очереди в одноразовой
#                 копии зоны — ORACLE_TAMPERED rc 2 ДО клеток
#   --piny-only   (служебный) только проверка пинов оракула
#   --seed N      seed сеяных входов (право судьи — перезапуск)
#
# Коды возврата: 0 — зелено; 1 — красная клетка/живой стаб/нет субъекта;
# 2 — ORACLE_TAMPERED, рассинхрон реестра, нечем проверять.
#
import json
import os
import re
import shutil
import subprocess
import sys
import signal
import tempfile
import hashlib
import yaml

ZDE = os.environ.get('GESpraechTekst149_ZONA',
                     os.path.dirname(os.path.abspath(__file__)))
KOREN = os.path.abspath(os.path.join(os.path.dirname(
    os.path.abspath(__file__)), '..', '..', '..'))
NOS = os.path.join(ZDE, 'nositeli')
MODEL = os.path.join(ZDE, 'model')
PACHKA = os.path.join(ZDE, 'pachka')
TEKSTY = os.path.join(ZDE, 'teksty')
STABY = os.path.join(ZDE, 'stabs')
ETALON = os.path.join(MODEL, 'ekran_shablon.py')
ZHIVOJ = os.path.join(KOREN, 'scripts', 'ekran_shablon.py')
RUNNER123 = os.path.join(KOREN, 'scripts', 'sverka_maketa.py')

# лекало 143/2 (И-8, блок Crit149 круг 1): копия frozen-шаблона — носитель
# зоны (пин sha256 в source.json, байты == тегу 3ca9d92f); агрегаты и
# служебные задачи DAG — имена frozen 143/2 (OCI-механизм продукта,
# PR Complior-mob#145 6240f630)
LEKALO = os.path.join(NOS, 'screen-job.template.yml')
AGREGATY = ('android-e2e', 'mobile-regression-signal')
BAZA_WF = os.path.join(NOS, 'produkt', 'mobile-6240f63.yml')
BAZA_KARTA = os.path.join(NOS, 'produkt', 'ci-screens-6240f63.json')
# канон-файлы пачки: путь в продукте -> файл зоны с теми же байтами
# (второй источник — source.json piny.kanon; сверяется до копирования)
KANON_V_ZONE = {
    'mobile/src/features/conversation/__tests__/gespraech-tekst.test.ts':
        'teksty/gespraech-tekst.test.ts',
    'mobile/e2e-gespraech-tekst/kontrakt.md': 'pachka/kontrakt.md',
    'mobile/e2e-gespraech-tekst/kadry.json': 'pachka/kadry.json',
    'mobile/e2e-gespraech-tekst/kadry-393.json': 'pachka/kadry-393.json',
    'mobile/e2e-gespraech-tekst/katalog_kopii.json':
        'pachka/katalog_kopii.json',
    'mobile/e2e-gespraech-tekst/spec_api.json': 'pachka/spec_api.json',
    'mobile/e2e-gespraech-tekst/batareja/red_ekrana.sh':
        'pachka/batareja/red_ekrana.sh',
    'mobile/.maestro/gespraech-tekst.yaml': 'pachka/gespraech-tekst.yaml',
    'mobile/.maestro/gespraech-tekst-393.yaml':
        'pachka/gespraech-tekst-393.yaml',
    'mobile/.maestro/gespraech-tekst-prokhod.yaml':
        'pachka/gespraech-tekst-prokhod.yaml',
    'mobile/e2e-gespraech-tekst/dvizhenie.mjs': 'teksty/dvizhenie.mjs',
}

# --- блок 1 Crit149b: полный суд пачки валидатором v3 + исполняемый
# зонд экрана (канон вызова — 132/146, прецеденты produkt_sud 148) -----
ZOND = os.path.join(ZDE, 'produkt', 'gespraech-zond-149.test.tsx')
ZOND_IMJA = 'gespraech-zond-149.test.tsx'
ZOND_KUDA = 'src/features/conversation/__tests__'
RASKLADKA = os.path.join(MODEL, 'produktnaja-raskladka')
# канонические пути компонентов экрана в продукте (контракт 149):
HOST_V_PRODUKTE = os.path.join('mobile', 'src', 'features',
                               'conversation', 'chat-host.tsx')
MASHINA_V_PRODUKTE = os.path.join('mobile', 'src', 'features',
                                  'conversation', 'chat-machine.ts')
KOMPOZER_V_PRODUKTE = os.path.join('mobile', 'src', 'ui',
                                   'conversation-composer',
                                   'conversation-composer.tsx')
# мутанты исполняемого суда (блок 1 Crit149b + v+1 цикла 2 Crit149k2a/
# Crit149k2b): «пустой хост» — файл выродился в пустой рендер;
# «композер не изменён» — байты product main (носитель зоны, пин),
# правка 149 снята; zona-12-* — полы зон нажатия 44 → 12 (класс
# РЕАЛЬНАЯ_ЗОНА_КАСАНИЯ, дословная атака mut-hit); token-24/token-20 —
# высота строки поля литералом 24/20 вместо значения токена пакета
# (класс РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ, атака mut-token; вердикт: «литерал 24
# (равно как и 20) вместо 21 красен»); v+1 цикл 2 вызов 2 (Crit149k2b):
# token-literal-21 — высота строки литералом 21 при сохранённом
# импорте пакета (дословная атака критика; наблюдаем ТОЛЬКО на подмене
# значения токена — пиннованный проход зелён, совпадение числа связью
# не является); bez-chipov-ga19 — Brief-Dokument без обязательных чипов
# сравнения (класс ПОЛНОТА_ЖИВЫХ_ЦЕЛЕЙ, наблюдаем в состоянии dokument:
# CEL_OTSTUTSVUET); bez-golosa-v-polje — кнопка голоса В ПОЛЕ снята
# (наблюдаем в schreiben-tastatur и на композере: CEL_OTSTUTSVUET).
MUTANTY_ISPOLNIMYE = [
    ('host-pustoj', HOST_V_PRODUKTE,
     os.path.join(STABY, 'stab_host_pustoj.tsx')),
    ('kompozer-ne-izmenen', KOMPOZER_V_PRODUKTE,
     os.path.join(NOS, 'produkt', 'composer-108.tsx')),
    ('zona-12-host', HOST_V_PRODUKTE,
     os.path.join(STABY, 'stab_host_zona_12.tsx')),
    ('zona-12-kompozer', KOMPOZER_V_PRODUKTE,
     os.path.join(STABY, 'stab_kompozer_zona_12.tsx')),
    ('token-24', KOMPOZER_V_PRODUKTE,
     os.path.join(STABY, 'stab_kompozer_token_24.tsx')),
    ('token-20', KOMPOZER_V_PRODUKTE,
     os.path.join(STABY, 'stab_kompozer_token_20.tsx')),
    ('token-literal-21', KOMPOZER_V_PRODUKTE,
     os.path.join(STABY, 'stab_kompozer_token_literal_21.tsx')),
    ('bez-chipov-ga19', HOST_V_PRODUKTE,
     os.path.join(STABY, 'stab_host_bez_chipov_ga19.tsx')),
    ('bez-golosa-v-polje', KOMPOZER_V_PRODUKTE,
     os.path.join(STABY, 'stab_kompozer_bez_golosa_v_polje.tsx')),
]

# клеточные стабы (Н-39: стаб → клетка + файл; рассинхрон — rc 2):
# lekalo — обход проводки (круг Crit149); ekran-minimalnyj — неполная
# v3-пачка (блок 1 Crit149b); jest-krasnyj/zelenyj — фиктивные jest-среды
# (блок 1 Crit149b); flo-*/ga12/ga13 — обманные перепины флоу (перепин
# 31.10: старая форма снимка, вход без first-run/openLink, состояния
# GA-12 без вопроса/чипов и GA-13 до отправки); emuljatory-odnovremenno
# — параллельный старт 393 до остановки первого (v+1 цикл 2,
# ПОРЯДОК_AVD_393); maska-36 — маска шапки 393 = 36 pt (v+1 цикл 2,
# МАСКА_ПРОФИЛЯ_393)
KLETOCHNYE_STABY = {
    'lekalo-obhod-kritika': ('s-lekalo-instanciirovano',
                             'stab_lekalo_obhod_kritika.py'),
    'ekran-minimalnyj': ('s-pachka-validirovana',
                         'stab_ekran_minimalnyj.py'),
    'jest-krasnyj': ('s-ekran-ispolnim', 'stab_jest_krasnyj.sh'),
    'jest-zelenyj': ('s-ekran-ispolnim', 'stab_jest_zelenyj.sh'),
    'flo-staraq-forma': ('s-snimok-strokoj', 'stab_flo_staraq_forma.py'),
    'flo-bez-vkhoda': ('s-vkhod-v-ekran', 'stab_flo_bez_vkhoda.py'),
    'ga12-bez-voprosa': ('s-ga12-s-voprosom', 'stab_ga12_bez_voprosa.py'),
    'ga13-do-otpravki': ('s-ga13-posle-otpravki',
                         'stab_ga13_do_otpravki.py'),
    'emuljatory-odnovremenno': ('s-emuljatory-posledovatelno',
                                'stab_emuljatory_odnovremenno.py'),
    'maska-36': ('s-profil-maska-393', 'stab_maska_36.py'),
}

# флоу пачки (байты — носители зоны, пин source.json; канон-копии в
# продукте — piny.kanon) и клетки их формы/состояний: исполнимость в
# Maestro 2.11.0 и соответствие состояний кадров GA-12/GA-13 макету
# D 2.4 (факт Impl149b 31.10 §1/§4: закреплённые флоу не исполнялись —
# снимок картой {name: …}, launchApp на корне First-Run; состояния
# GA-12/GA-13 расходились с макетом). Привязка стаба — имя стаба ->
# (клетка, причина); единый источник здесь, source.json.stab_vhod
# сверяется с ним в vedro_lekalo.
FLOVY_PACHKI = ('gespraech-tekst.yaml', 'gespraech-tekst-393.yaml',
                'gespraech-tekst-prokhod.yaml')
KLETKI_FLO_STABOV = {
    'flo-staraq-forma': ('s-snimok-strokoj', 'SNIMOK_KARTOJ'),
    'flo-bez-vkhoda': ('s-vkhod-v-ekran', 'VHOD_BEZ_VKHODA'),
    'ga12-bez-voprosa': ('s-ga12-s-voprosom', 'GA12_BEZ_VOPROSA'),
    'ga13-do-otpravki': ('s-ga13-posle-otpravki', 'GA13_DO_OTPRAVKI'),
}

# v2: карта целей — pressable пачки -> (экран, метка touch_target
# манифеста 1.1); зона pressable == (x, y, hw, hh) манифеста (слово
# владельца 2026-11-02: касание судится по ЗОНЕ hw/hh, видимая рамка
# меньше зоны находкой не является). gespraech-pole без цели манифеста
# (textarea): зона ряда композера между '+' и 'Sprechen' GA-11, потолок
# и прокрутка — машина и токен (d-pole-rastjot, m-pole-shest-strok)
KARTA_CELEJ_PRESS = {
    'gespraech-verlauf': ('GA-11', 'Gesprächsverlauf'),
    'gespraech-topic-schaden':
        ('GA-11', 'Schaden melden Ich helfe Ihnen sofort weiter'),
    'gespraech-topic-schaden-speak': ('GA-11', 'Schaden melden erzählen'),
    'gespraech-topic-auto':
        ('GA-11', 'Neues Auto Versicherung, Zulassung, Altvertrag'),
    'gespraech-topic-auto-erzaehlen': ('GA-11', 'Neues Auto erzählen'),
    'gespraech-topic-umzug': ('GA-11', 'Umzug Adresse, Hausrat, Haftpflicht'),
    'gespraech-topic-umzug-erzaehlen': ('GA-11', 'Umzug erzählen'),
    'gespraech-topic-nachwuchs':
        ('GA-11', 'Nachwuchs Was sich jetzt für Ihre Familie ändert'),
    'gespraech-topic-nachwuchs-erzaehlen': ('GA-11', 'Nachwuchs erzählen'),
    'gespraech-topic-heirat': ('GA-11', 'Heirat Verträge bündeln, Namen ändern'),
    'gespraech-topic-heirat-erzaehlen': ('GA-11', 'Heirat erzählen'),
    'gespraech-chip-gekauft': ('GA-12', 'Schon gekauft'),
    'gespraech-chip-geplant': ('GA-12', 'Kauf geplant'),
    'gespraech-lieber-erzaehlen': ('GA-12', 'Lieber erzählen?'),
    'gespraech-chip-vergleichen': ('GA-19', 'Ja, vergleichen'),
    'gespraech-chip-nicht': ('GA-19', 'Erst mal nicht'),
    'gespraech-vlozhit': ('GA-11', 'Dokument hinzufügen'),
    'gespraech-mikrofon': ('GA-11', 'Sprechen'),
    'gespraech-mikrofon-v-pole': ('GA-13', 'Sprechen'),
    'gespraech-otpravit': ('GA-13', 'Nachricht senden'),
    'shell-tab-start': ('GA-11', 'Start'),
    'shell-tab-vorgaenge': ('GA-11', 'Vorgänge'),
    'gespraech-mitte': ('GA-11', 'Gespräch mit Complior'),
    'shell-tab-schutz': ('GA-11', 'Schutz'),
    'shell-tab-post': ('GA-11', 'Post'),
}
# ∩-правило: все переходы манифеста, чьи кадры ∩ экраны пачки ≠ ∅
# (замер по пиннованному манифесту: GA-11/12/13/17/18/19)
PEREHODY = ['GA-T08', 'GA-R2', 'GA-R2-393', 'GA-T17', 'GA-T18', 'GA-T19',
            'GA-T30', 'GA-T32', 'GA-T34', 'GA-T37']
PRAVILA_MASHINY = ['plan-t30', 't30-fon-do-chata', 't30-morf-pilulja-pole',
                   't30-temy-posle-polja', 'plan-t32',
                   't32-vopros-ranshe-chipov', 'plan-t37',
                   't37-leista-v-pole', 'ud-bez-poljota', 'pole-shest-strok']


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
    k = src['kejsy']
    if set(k['a']) != set(OZHIDAEMYE_PRICHINY) | {'kontrol-forma'}:
        utechka('kejsy.a против ожидаемых причин')
    for kk, v in k['a'].items():
        if kk != 'kontrol-forma' and v.get('prichina') != \
                OZHIDAEMYE_PRICHINY.get(kk):
            utechka('prichina ' + kk)
    vedro_lekalo(src)
    return src


def vedro_lekalo(src):
    """Грамматика ключей инстанциации И-8 (единый источник рецепта
    pachka/ci-recept-d149.md): состав/значения source.json.lekalo и
    привязка стаба лекала. Рассинхрон — дефект оракула, rc 2."""
    lek = src.get('lekalo')
    if not isinstance(lek, dict) or set(lek) != {
            'job_id', 'screen_id', 'pack', 'flows', 'child_flows', 'puti',
            'h_path', 'avd_port', 'avd_port_393', 'serial', 'serial_393',
            'evidence_ns', 'shablon', 'ekrany'}:
        utechka('source.json.lekalo — состав ключей')
    if not re.fullmatch(r'e2e-[a-z0-9-]+', lek['job_id']) or \
            not re.fullmatch(r'[a-z0-9-]+', lek['screen_id']) or \
            lek['pack'] != 'mobile/e2e-%s/' % lek['screen_id'] or \
            lek['h_path'] != '.harness149' or lek['shablon'] != 3 or \
            set(lek['ekrany']) != {'GA-11', 'GA-12', 'GA-13',
                                   'GA-17', 'GA-18', 'GA-19'} or \
            not isinstance(lek['avd_port'], int) or \
            not isinstance(lek['avd_port_393'], int) or \
            lek['avd_port'] % 2 != 0 or lek['avd_port_393'] % 2 != 0 or \
            lek['avd_port_393'] < lek['avd_port'] + 2 or \
            lek['avd_port_393'] in (lek['avd_port'] - 1, lek['avd_port'],
                                    lek['avd_port'] + 1) or \
            lek['serial'] != 'GESPRAECH_TEKST_SERIAL' or \
            lek['serial_393'] != 'GESPRAECH_TEKST_SERIAL_393' or \
            not lek['flows'] or not lek['child_flows'] or not lek['puti'] \
            or lek['evidence_ns'] != 'mobile/maestro-out-%s' \
            % lek['screen_id']:
        utechka('source.json.lekalo — грамматика значений')
    for kljuch in ('nositeli/screen-job.template.yml',
                   'nositeli/produkt/mobile-6240f63.yml',
                   'nositeli/produkt/ci-screens-6240f63.json',
                   'stabs/stab_lekalo_obhod_kritika.py'):
        if kljuch not in src['piny']['nositeli']:
            utechka('пин лекала отсутствует: ' + kljuch)
    for kljuch in ('produkt/gespraech-zond-149.test.tsx',
                   'stabs/stab_ekran_minimalnyj.py',
                   'stabs/stab_jest_zelenyj.sh',
                   'stabs/stab_jest_krasnyj.sh',
                   'stabs/stab_host_pustoj.tsx',
                   'nositeli/produkt/composer-108.tsx',
                   'stabs/stab_host_zona_12.tsx',
                   'stabs/stab_kompozer_zona_12.tsx',
                   'stabs/stab_kompozer_token_24.tsx',
                   'stabs/stab_kompozer_token_20.tsx',
                   'stabs/stab_emuljatory_odnovremenno.py',
                   'stabs/stab_maska_36.py',
                   'model/produktnaja-raskladka/mobile/src/features/'
                   'conversation/chat-host.tsx',
                   'model/produktnaja-raskladka/mobile/src/features/'
                   'conversation/chat-kopija.ts',
                   'model/produktnaja-raskladka/mobile/src/ui/'
                   'conversation-composer/conversation-composer.tsx'):
        if kljuch not in src['piny']['nositeli']:
            utechka('пин блока 1 отсутствует: ' + kljuch)
    for kljuch in ('stabs/stab_flo_staraq_forma.py',
                   'stabs/stab_flo_bez_vkhoda.py',
                   'stabs/stab_ga12_bez_voprosa.py',
                   'stabs/stab_ga13_do_otpravki.py'):
        if kljuch not in src['piny']['nositeli']:
            utechka('пин стаба флоу отсутствует: ' + kljuch)
    for otn in ('nositeli/kompakt11/manifest.json',
                'nositeli/kompakt11/tokens.json',
                'nositeli/kompakt11/frames.json',
                'nositeli/kompakt11/SHA256SUMS',
                'nositeli/kompakt11/motion-delta.md'):
        if otn not in src['piny']['nositeli']:
            utechka('пин пакета 1.1 отсутствует: ' + otn)
    for otn in src['piny']['nositeli']:
        if otn.startswith('nositeli/d24/kadry/'):
            utechka('снятый носитель финала-2 снова запинен: ' + otn)
    for stab, svaz in (src.get('stab_vhod') or {}).items():
        if 'kletka' in svaz:
            ozhid = KLETOCHNYE_STABY.get(stab)
            if not ozhid or svaz['kletka'] != ozhid[0] or \
                    'pravilo' in svaz or \
                    src['staby'].get(stab) != ozhid[1]:
                utechka('привязка клеточного стаба ' + stab)
        elif svaz.get('pravilo') not in PRAVILA_MASHINY:
            utechka('привязка стаба ' + stab)
    # полнота стабов формы/состояний флоу по клеткам (единый источник —
    # KLETKI_FLO_STABOV): каждая клетка флоу обязана нести свой стаб
    flo_kletki = {v[0] for v in KLETKI_FLO_STABOV.values()}
    objavlennye = {sv['kletka'] for sv in (src.get('stab_vhod')
                                           or {}).values()
                   if 'kletka' in sv and sv['kletka'] in flo_kletki}
    if objavlennye != flo_kletki:
        utechka('стабы флоу против клеток формы/состояний')


# ожидаемое имя причины каждой красной клетки оси A (сверяется с фактом
# эталона ДО субъекта; расхождение — дефект оракула, rc 2)
OZHIDAEMYE_PRICHINY = {
    'shablon2-s-ga': 'DVIZHENIE_OTSVTSTVUET',
    'ekrany-ne-polny-ga-11': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-12': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-13': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-17': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-18': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-19': 'EKRANY_NE_POLNY',
    'ekran-vne-manifesta': 'EKRAN_VNE_MANIFESTA',
    'ekran-bez-kadrov': 'EKRAN_BEZ_KADROV',
    'perehody-ne-polny-t30': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t32': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t34': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t08': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t37': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t17': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t18': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t19': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-r2': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-r2-393': 'PEREHODY_NE_POLNY',
    'perehod-lishnij': 'PEREHOD_LISHNIJ',
    'perehod-vne-manifesta': 'PEREHOD_VNE_MANIFESTA',
    'scena-vne-orakula': 'SCENA_VNE_ORAKULA',
    'scena-vne-perehoda': 'SCENA_VNE_PEREHODA',
    'sceny-znaka-ne-polny': 'SCENY_ZNAKA_NE_POLNY',
    'etalon-bez-pinov': 'ETALON_BEZ_PINOV',
    'etalon-ne-hex': 'ETALON_NE_HEX',
    'etalon-ne-polon': 'ETALON_NE_POLON',
    'etalon-tema-otsvtstvuet': 'ETALON_TEMA_OTSVTSTVUET',
    'video-etalon-ne-polon': 'VIDEO_ETALON_NE_POLON',
    'etalon-lishnij': 'ETALON_LISHNIJ',
    'istochnik-ne-sovpadaet': 'ISTOCHNIK_NE_SOVPADAET',
    'istochnik-otsvtstvuet': 'ISTOCHNIK_OTSVTSTVUET',
    'kljuch-bez-kataloga': 'KLJUCH_BEZ_KATALOGA',
    'scenarij-bez-snimka': 'SCENARIJ_BEZ_SNIMKA',
    'zony-rashodjatsja': 'ZONY_RASHODJATSJA',
    'ne-trogaet-ne-polon': 'NE_TROGAET_NE_POLON',
    'pressable-bez-izmenenija': 'PRESSABLE_BEZ_IZMENENIJA',
    'kasanie-menshe-normy': 'KASANIE_MENSHE_NORMY',
    'kasanie-v-safe-zone': 'KASANIE_V_SAFE_ZONE',
    'profil-nizhe-minimuma': 'PROFIL_NIZHE_MINIMUMA',
    'profil-bez-insetov': 'PROFIL_BEZ_INSETOV',
    'golyl-komponent': 'GOLYJ_KOMPONENT',
    'marshrut-bez-obolochki': 'MARSHRUT_BEZ_OBOLOCHKI',
    'marshrut-bez-snimka': 'MARSHRUT_BEZ_SNIMKA',
    'odna-tema': 'ODNA_TEMA',
    'nalozhenie-sloev': 'NALOZHENIE_SLOEV',
    'zalezaet-pod-inset': 'ZALEZAET_POD_INSET',
    'pustaja-ikonka': 'PUSTAJA_IKONKA',
    'kontrakt-dlinnyj': 'NE_ODNA_STRANICA',
    'literal-cveta': 'LITERAL_VNE_AUDITA',
    'prokhod-ne-maestro': 'PROKHOD_NE_MAESTRO',
    'prokhod-bez-pressable': 'PROKHOD_BEZ_PRESSABLE',
    'dvizhenie-bez-otcheta': 'DVIZHENIE_BEZ_OTCHETA',
    'dvizhenie-ne-proshla': 'DVIZHENIE_NE_PROSHLA',
    'otchet-ustarevshij': 'OTCHET_USTAREVSHIJ',
    'otchet-pustoj': 'OTCHET_PUSTOJ',
    'otchet-s-provalami': 'OTCHET_S_PROVALAMI',
    'e2e-ne-proshla': 'E2E_NE_PROSHLA',
    'kadr-ustarevshij': 'KADR_USTAREVSHIJ',
    'kadr-neodnoznachen': 'KADR_NEODNOZNACHEN',
    'samodelnaya-sverka': 'SAMODELNAYA_SVERKA',
    'staroj-pin-d24': 'KADR_NIZHE_POROGA',
    'razdel-otsvtstvuet': 'RAZDEL_OTSVTSTVUET',
}


def _sh(q):
    return q.replace("'", "'\\''")

def _kadry_paketa():
    """Кадры пакета D24-Kompakt-1.1 (v2): (экран, тема, профиль) -> имя
    файла кадров пакета; единый источник — frames.json + класс состояния
    экрана в манифесте 1.1 (не россыпь имён)."""
    man = json.load(open(os.path.join(NOS, 'kompakt11', 'manifest.json'),
                         encoding='utf-8'))
    fr = json.load(open(os.path.join(NOS, 'kompakt11', 'frames.json'),
                        encoding='utf-8'))['frames']
    ekrany = ('GA-11', 'GA-12', 'GA-13', 'GA-17', 'GA-18', 'GA-19')
    karta = {f['screen'] + ' ' + f['theme'] + ' ' + f['profile']:
             f['file'] for f in fr if f['screen'] in ekrany}
    return karta, {g: man['screens'][g]['state_classes'][0]
                   for g in ekrany}


def telo_standina_e2e():
    """Текст стенд-ина e2e (СВЕЖИЕ кадры-носители в раскладку Maestro;
    единый источник для мира оси A и синтетического репо суда пачки):
    кадры ПАКЕТА D24-Kompakt-1.1 — перекодированные копии (пиксели равны,
    байты отличны): реализация рендерит компактную шкалу, стенд-ин честен
    ей, а не пину пачки — старый пин макетов красен живой мерой 123
    (клетка a-staroj-pin-d24). Записи — kadry-манифесты пачки (обеих
    тем/профилей), а не списком здесь."""
    kadr = os.path.join(NOS, 'kompakt11', 'kadry')
    karta, sostojanija = _kadry_paketa()
    telo = ['#!/usr/bin/env bash', 'set -eu',
            'out=mobile/maestro-out-gespraech-tekst', 'rm -rf "$out"',
            'mkdir -p "$out"']
    for imja_manifesta, prof in (('kadry.json', '390x844'),
                                 ('kadry-393.json', '393x852')):
        m = json.load(open(os.path.join(PACHKA, imja_manifesta),
                           encoding='utf-8'))
        for k in m['kadry']:
            ga = k['id'].split(' ')[0]
            im = karta[ga + ' ' + k['tema'] + ' ' + prof]
            assert im.startswith('%s_%s_' % (ga, sostojanija[ga])), (im, ga)
            d = '"$out"/%s/run/gespraech/takeScreenshot' % k['tema']
            telo += ['mkdir -p %s' % d,
                     'cp "%s/%s" %s/%s.png'
                     % (_sh(kadr), im, d, k['snimok'])]
    telo += ['exit 0']
    return '\n'.join(telo) + '\n'


def napishi_standiny(repo, pak, mashina, speka):
    """Стенд-ины приёмки (мир оси A и синтетическое репо суда пачки):
    e2e кладёт свежие кадры, prokhod требует цель-флою, npm-шим
    запускает раннер численной приёмки на ДАННОЙ машине против ДАННОЙ
    спеки (живой e2e/Maestro/jest — продуктовый CI экрана, остаток 132;
    здесь — честные стенд-ины миров, не эмулятор)."""
    put = os.path.join(pak, 'e2e.sh')
    open(put, 'w').write(telo_standina_e2e())
    os.chmod(put, 0o755)
    put = os.path.join(pak, 'prokhod.sh')
    open(put, 'w').write('#!/usr/bin/env bash\nset -eu\n'
                         '[ -f "${1:?cel-flou}" ] || exit 3\nexit 0\n')
    os.chmod(put, 0o755)
    put = os.path.join(repo, 'bin', 'npm')
    os.makedirs(os.path.dirname(put), exist_ok=True)
    open(put, 'w').write(
        '#!/usr/bin/env bash\nout=""; prev=""\nfor a in "$@"; do\n'
        '  if [ "$prev" = "--outputFile" ]; then out="$a"; fi\n'
        '  prev="$a"\ndone\n[ -n "$out" ] || exit 2\n'
        'case "$out" in\n  /*) cel="$out";;\n  *) cel="%s/mobile/$out";;'
        '\nesac\n'
        'exec node "%s" --machine "%s" --spec "%s" --json --outputFile '
        '"$cel"\n'
        % (_sh(repo), _sh(os.path.join(MODEL, 'dvizhenie-runner.mjs')),
           _sh(mashina), _sh(speka)))
    os.chmod(put, 0o755)


def postav_mir(tmp):
    """Мир: repo (мини-продукт с пачкой-эталоном) + harness (мини-харнесс).
    Стенд-ины приёмки честны: e2e кладёт СВЕЖИЕ кадры-носители в
    Maestro-раскладку, npm-шим запускает раннер машины; живые команды
    продукта — канон teksty/ (исполняет продуктовый CI экрана)."""
    repo = os.path.join(tmp, 'repo')
    hrn = os.path.join(tmp, 'harness')
    pak = os.path.join(repo, 'mobile', 'e2e-gespraech-tekst')
    dirs = [
        os.path.join(repo, 'mobile', '.maestro'),
        os.path.join(repo, 'mobile', 'src', 'features', 'conversation',
                     '__tests__'),
        os.path.join(pak, 'batareja'),
        os.path.join(repo, 'docs', 'ux', '04_Gespraech_D24', 'motion'),
        os.path.join(repo, 'docs', 'ux', '04_Gespraech_D24', 'pack',
                     'screens', '390x844'),
        os.path.join(repo, 'docs', 'ux', '04_Gespraech_D24', 'pack',
                     'screens', '393x852'),
        os.path.join(repo, 'docs', 'ux', '03_Mobility_Slice1', 'ds'),
        os.path.join(repo, 'mobile', 'e2e-first-run'),
        os.path.join(repo, 'mobile', 'e2e-erstinformation'),
        os.path.join(repo, '.harness149', 'scripts'),
        os.path.join(repo, 'bin'),
        os.path.join(hrn, 'scripts'),
        os.path.join(hrn, 'fixtures', 'workshop_project', 'ekran_shablon_132',
                     'model', 'fiktura', 'pachta_chuzhogo'),
        os.path.join(hrn, 'fixtures', 'workshop_project', 'ekran_shablon_132',
                     'model', 'fiktura', 'pachta_tot_zhe'),
        os.path.join(repo, 'mobile', 'maestro-out-gespraech-tekst'),
    ]
    for d in dirs:
        os.makedirs(d, exist_ok=True)
    d24 = os.path.join(repo, 'docs', 'ux', '04_Gespraech_D24')
    shutil.copy(os.path.join(NOS, 'd24', 'manifest.json'),
                os.path.join(d24, 'pack', 'gespraech-final2-manifest.json'))
    shutil.copy(os.path.join(NOS, 'd24', 'spec.json'),
                os.path.join(d24, 'motion', 'motion-spec-gespraech.json'))
    shutil.copy(os.path.join(NOS, 'd24', 'pozvonok.json'),
                os.path.join(d24, 'motion', 'faden-poses-gespraech.json'))
    for prof in ('390x844', '393x852'):
        for ga in ('GA-11', 'GA-11-Hell', 'GA-12', 'GA-12-Hell',
                   'GA-13', 'GA-13-Hell', 'GA-17', 'GA-17-Hell',
                   'GA-18', 'GA-18-Hell', 'GA-19', 'GA-19-Hell'):
            shutil.copy(os.path.join(NOS, 'd24', 'maket',
                                     '%s-%s.png' % (prof, ga)),
                        os.path.join(d24, 'pack', 'screens', prof,
                                     ga + '.png'))
    k11 = os.path.join(repo, 'docs', 'ux', '05_Kompakt_D24')
    for pod, imja in (('source', 'manifest.json'), ('source', 'tokens.json'),
                      ('frames', 'frames.json'), ('frames', 'SHA256SUMS'),
                      ('motion', 'motion-delta.md')):
        os.makedirs(os.path.join(k11, pod), exist_ok=True)
        shutil.copy(os.path.join(NOS, 'kompakt11', imja),
                    os.path.join(k11, pod, imja))
    for im in sorted(os.listdir(os.path.join(NOS, 'kompakt11', 'maket'))):
        shutil.copy(os.path.join(NOS, 'kompakt11', 'maket', im),
                    os.path.join(k11, 'frames', im))
    shutil.copy(os.path.join(NOS, 'produkt', 'tokens.css'),
                os.path.join(repo, 'docs', 'ux', '03_Mobility_Slice1', 'ds',
                             'tokens.css'))
    shutil.copy(os.path.join(NOS, 'produkt', 'first-run-kadry.json'),
                os.path.join(repo, 'mobile', 'e2e-first-run', 'kadry.json'))
    shutil.copy(os.path.join(NOS, 'produkt', 'erstinformation-kadry.json'),
                os.path.join(repo, 'mobile', 'e2e-erstinformation',
                             'kadry.json'))
    for f in ('kontrakt.md', 'kadry.json', 'kadry-393.json',
              'katalog_kopii.json', 'spec_api.json'):
        shutil.copy(os.path.join(PACHKA, f), os.path.join(pak, f))
    shutil.copy(os.path.join(PACHKA, 'batareja', 'red_ekrana.sh'),
                os.path.join(pak, 'batareja', 'red_ekrana.sh'))
    os.chmod(os.path.join(pak, 'batareja', 'red_ekrana.sh'), 0o755)
    for f in ('gespraech-tekst.yaml', 'gespraech-tekst-393.yaml',
              'gespraech-tekst-prokhod.yaml'):
        shutil.copy(os.path.join(PACHKA, f),
                    os.path.join(repo, 'mobile', '.maestro', f))
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    shutil.copy(os.path.join(MODEL, 'chat-machine.ts'),
                os.path.join(repo, 'mobile', 'src', 'features',
                             'conversation', 'chat-machine.ts'))
    shutil.copy(os.path.join(TEKSTY, 'gespraech-tekst.test.ts'),
                os.path.join(repo, 'mobile', 'src', 'features',
                             'conversation', '__tests__',
                             'gespraech-tekst.test.ts'))
    shutil.copy(os.path.join(TEKSTY, 'dvizhenie.mjs'),
                os.path.join(pak, 'dvizhenie.mjs'))
    # стенд-ины приёмки (общие с судом пачки: napishi_standiny)
    mashina = os.path.join(repo, 'mobile', 'src', 'features',
                           'conversation', 'chat-machine.ts')
    speka = os.path.join(d24, 'motion', 'motion-spec-gespraech.json')
    napishi_standiny(repo, pak, mashina, speka)
    shutil.copy(RUNNER123, os.path.join(repo, '.harness149', 'scripts',
                                        'sverka_maketa.py'))
    shutil.copy(RUNNER123, os.path.join(hrn, 'scripts', 'sverka_maketa.py'))
    fikt = os.path.join(KOREN, 'fixtures', 'workshop_project',
                        'ekran_shablon_132', 'model', 'fiktura')
    for d in ('pachta_chuzhogo', 'pachta_tot_zhe'):
        for f in ('ekran.json', 'kadry.json'):
            shutil.copy(os.path.join(fikt, d, f),
                        os.path.join(hrn, 'fixtures', 'workshop_project',
                                     'ekran_shablon_132', 'model',
                                     'fiktura', d, f))
    return repo, hrn, pak


def zapusk_valid(jar, pak, repo, hrn):
    env = dict(os.environ)
    env['PATH'] = (os.path.join(repo, 'bin') + os.pathsep
                   + env.get('PATH', ''))
    r = subprocess.run([sys.executable, jar, '--pack', pak, '--repo', repo,
                        '--harness', hrn], capture_output=True, text=True,
                       env=env, timeout=600)
    prichiny = [ln.split('\t')[1] for ln in r.stderr.splitlines()
                if ln.startswith('PRICHINA\t') and '\t' in ln]
    return r.returncode, prichiny


def sobrat_mir_pachki(repo_r, vrem):
    """Синтетическое репо суда пачки продукта (блок 1 Crit149b; канон
    вызова 132/146, прецедент produkt_sud 148): пачка R — ЦЕЛИКОМ как
    есть; всё объявленное вне пачки (источники dvizhenie, аудит токенов,
    макеты по манифестам кадров, флоу, ne_trogaet) — из R по объявленным
    путям; раннер 123 — живой из дерева харнесса в .harness149 (как H-
    checkout лекала); стенд-ины e2e/prokhod/npm — батареи (живой
    эмулятор/Maestro/jest — продуктовый CI, остаток 132). Машина для
    отчёта приёмки — машина R (копия в синтетическое репо, если есть).
    НИКАКИХ собственных проверок полей пачки здесь нет — форма и полнота
    судятся ТОЛЬКО валидатором."""
    sint = os.path.join(vrem, 'repo')
    pak = os.path.join(repo_r, 'mobile', 'e2e-gespraech-tekst')
    if not os.path.isfile(os.path.join(pak, 'ekran.json')):
        return None, None
    try:
        forma = json.load(open(os.path.join(pak, 'ekran.json'),
                               encoding='utf-8'))
    except (OSError, ValueError):
        forma = {}
    spak = os.path.join(sint, 'mobile', 'e2e-gespraech-tekst')
    os.makedirs(spak, exist_ok=True)
    for koren, dirs, fajly in os.walk(pak):
        for imja in fajly:
            dst = os.path.join(sint, os.path.relpath(
                os.path.join(koren, imja), repo_r))
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(os.path.join(koren, imja), dst)

    def skopiruj_s_repo(otn):
        isto = os.path.join(repo_r, otn)
        if os.path.isfile(isto):
            kuda = os.path.join(sint, otn)
            os.makedirs(os.path.dirname(kuda), exist_ok=True)
            shutil.copy(isto, kuda)
            return True
        return False

    # источники движения и аудит токенов — по объявленным путям из R
    dv = forma.get('dvizhenie') if isinstance(forma, dict) else None
    dv = dv if isinstance(dv, dict) else {}
    for pole in ('manifest', 'spec', 'pozvonok'):
        if isinstance(dv.get(pole), str):
            skopiruj_s_repo(dv[pole])
    if isinstance(forma, dict) and isinstance(
            forma.get('audit_tokenov'), str):
        skopiruj_s_repo(forma['audit_tokenov'])
    # флоу e2e-сценария и маршрута профиля — из R
    if isinstance(forma, dict) and isinstance(forma.get('e2e_scenarij'),
                                               str):
        skopiruj_s_repo(forma['e2e_scenarij'])
    vp = forma.get('vtoroj_profil') if isinstance(forma, dict) else None
    if isinstance(vp, dict) and isinstance(vp.get('marshrut'), str):
        skopiruj_s_repo(vp['marshrut'])
    # флоу прохода: цель-флою объявлена только в argv priemka.prokhod —
    # все .yaml из команд приёмки копируются из R (иначе мир неполон и
    # валидатор отказал бы PROKHOD_NE_MAESTRO по вине МИРА, не пачки)
    pr = forma.get('priemka') if isinstance(forma, dict) else None
    argv_flou = []
    if isinstance(pr, dict):
        for komanda in pr.values():
            if isinstance(komanda, str):
                argv_flou.append(komanda)
    if isinstance(dv.get('priemka_dvizhenija'), str):
        argv_flou.append(dv['priemka_dvizhenija'])
    for komanda in argv_flou:
        for slovo in komanda.split(' '):
            if slovo.endswith('.yaml'):
                skopiruj_s_repo(slovo)
    # макеты — по манифестам кадров пачки (пути канонические в R)
    for imja_manifesta in ('kadry.json', 'kadry-393.json'):
        try:
            man = json.load(open(os.path.join(spak, imja_manifesta),
                                 encoding='utf-8'))
        except (OSError, ValueError):
            continue
        for k in (man.get('kadry') or []):
            if isinstance(k, dict) and isinstance(k.get('maket'), str):
                skopiruj_s_repo(k['maket'])
    # ne_trogaet — из R (найденное); фикстуры 132 — мини-харнесс ниже
    hrn = os.path.join(vrem, 'harness')
    os.makedirs(os.path.join(hrn, 'scripts'), exist_ok=True)
    shutil.copy(RUNNER123, os.path.join(hrn, 'scripts',
                                        'sverka_maketa.py'))
    fikt = os.path.join(KOREN, 'fixtures', 'workshop_project',
                        'ekran_shablon_132', 'model', 'fiktura')
    for d in ('pachta_chuzhogo', 'pachta_tot_zhe'):
        for f in ('ekran.json', 'kadry.json'):
            kuda = os.path.join(hrn, 'fixtures', 'workshop_project',
                                'ekran_shablon_132', 'model', 'fiktura',
                                d, f)
            os.makedirs(os.path.dirname(kuda), exist_ok=True)
            shutil.copy(os.path.join(fikt, d, f), kuda)
    if isinstance(forma, dict):
        for otn in (forma.get('ne_trogaet')
                    if isinstance(forma.get('ne_trogaet'), list) else []):
            skopiruj_s_repo(otn)
    # каталог кадров и раннер 123 в .harness149 (пин лекала в продукте)
    kd = forma.get('kadry_dir') if isinstance(forma, dict) else None
    os.makedirs(os.path.join(sint, kd if isinstance(kd, str)
                             else 'mobile/maestro-out-gespraech-tekst'),
                exist_ok=True)
    os.makedirs(os.path.join(sint, '.harness149', 'scripts'), exist_ok=True)
    shutil.copy(RUNNER123, os.path.join(sint, '.harness149', 'scripts',
                                        'sverka_maketa.py'))
    # машина R для отчёта приёмки движения (нет машины — отчёт падает,
    # это честный отказ валидатора, не дефект мира)
    mashina = os.path.join(sint, MASHINA_V_PRODUKTE)
    if os.path.isfile(os.path.join(repo_r, MASHINA_V_PRODUKTE)):
        os.makedirs(os.path.dirname(mashina), exist_ok=True)
        shutil.copy(os.path.join(repo_r, MASHINA_V_PRODUKTE), mashina)
    # спека для npm-шима — ТОЛЬКО объявленный путь (источник уже скопирован
    # из R выше; фолбэк носителями скрыл бы удаление источника в R —
    # валидатор обязан отказать ISTOCHNIK_OTSVTSTVUET, а не видеть подмену)
    speka = os.path.join(
        sint, dv['spec'] if isinstance(dv.get('spec'), str)
        else 'docs/ux/04_Gespraech_D24/motion/motion-spec-gespraech.json')
    napishi_standiny(sint, spak, mashina, speka)
    return sint, hrn


def sud_pachki_validiatorom(repo_r, src):
    """s-pachka-validirovana (блок 1 Crit149b: «W --repo принимал продукт
    без корректной v3-пачки» — обход {shablon,ekran,dvizhenie.ekrany}
    проходил rc 0 83/83): пачка ЭТОГО экрана в R судится тем же
    ЗАМОРОЖЕННЫМ валидатором v3 (эталон model/ekran_shablon.py, пин
    5fd1415e == source.json), каким судятся миры оси A, — в
    синтетическом репо из файлов R (sobrat_mir_pachki). Собственных
    литеральных проверок полей НЕТ (единый источник формы — валидатор
    132/146). Отказ — именованный PACHKA_NE_PROSHLA_VALIDATOR с
    PRICHINA-строками валидатора; (True, '') — пачка прошла."""
    if not os.path.isfile(ETALON) or sha(ETALON) != \
            src['piny']['sha']['model/ekran_shablon.py']:
        return False, 'PACHKA_NE_PROSHLA_VALIDATOR: эталон v3 не пиннован'
    vrem = tempfile.mkdtemp(prefix='gespraechtekst149-pv-')
    try:
        sint, hrn = sobrat_mir_pachki(repo_r, vrem)
        if sint is None:
            return False, ('PACHKA_NE_PROSHLA_VALIDATOR: нет '
                           'mobile/e2e-gespraech-tekst/ekran.json')
        rc, prichiny = zapusk_valid(ETALON,
                                    os.path.join(
                                        sint, 'mobile',
                                        'e2e-gespraech-tekst'),
                                    sint, hrn)
        if rc == 0:
            return True, ''
        detali = '; '.join(prichiny[:4]) if prichiny else (
            'rc=%d без именованных причин (состав ключей != v3)' % rc)
        return False, 'PACHKA_NE_PROSHLA_VALIDATOR: %s' % detali
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


# ---------- мутации клеток оси A (по одной на имя причины) ----------

def izmeni(pak, repo, vid):
    ej = os.path.join(pak, 'ekran.json')
    f = json.load(open(ej, encoding='utf-8'))
    tronutye = []

    def sohrani():
        json.dump(f, open(ej, 'w', encoding='utf-8'), ensure_ascii=False,
                  indent=1)
        tronutye.append('ekran.json')

    def put_pachki(imja):
        return os.path.join(pak, imja)

    def put_repo(otn):
        return os.path.join(repo, otn)

    if vid == 'shablon2-s-ga':
        del f['dvizhenie']
        f['shablon'] = 2
        sohrani()
    elif vid.startswith('ekrany-ne-polny-'):
        f['dvizhenie']['ekrany'].remove(
            'GA-' + vid.rsplit('-', 1)[1].upper())
        sohrani()
    elif vid == 'ekran-vne-manifesta':
        f['dvizhenie']['ekrany'].append('GA-99')
        sohrani()
    elif vid == 'ekran-bez-kadrov':
        f['dvizhenie']['ekrany'].append('GA-09')
        sohrani()
    elif vid.startswith('perehody-ne-polny-'):
        hvost = vid.rsplit('-', 1)[1]
        pid = ('GA-R2' if hvost == 'r2' else
               'GA-R2-393' if hvost == '393' else 'GA-' + hvost.upper())
        f['dvizhenie']['perehody'].remove(pid)
        sohrani()
    elif vid == 'perehod-lishnij':
        f['dvizhenie']['perehody'].append('GA-T28')
        sohrani()
    elif vid == 'perehod-vne-manifesta':
        f['dvizhenie']['perehody'].append('GA-T36')
        sohrani()
    elif vid == 'scena-vne-orakula':
        f['dvizhenie']['sceny_znaka'].append('GA-T30')
        sohrani()
    elif vid == 'scena-vne-perehoda':
        f['dvizhenie']['sceny_znaka'].append('GA-T20')
        sohrani()
    elif vid == 'sceny-znaka-ne-polny':
        f['dvizhenie']['sceny_znaka'].remove('GA-T32')
        sohrani()
    elif vid == 'etalon-bez-pinov':
        del f['dvizhenie']['etalony']['GA-T30']
        sohrani()
    elif vid == 'etalon-ne-hex':
        f['dvizhenie']['etalony']['GA-T32']['keyframes']['dark'][2] = 'zz'
        sohrani()
    elif vid == 'etalon-ne-polon':
        f['dvizhenie']['etalony']['GA-T32']['keyframes']['light'].pop()
        sohrani()
    elif vid == 'etalon-tema-otsvtstvuet':
        del f['dvizhenie']['etalony']['GA-T32']['keyframes']['light_reduced']
        sohrani()
    elif vid == 'video-etalon-ne-polon':
        del f['dvizhenie']['etalony']['GA-T32']['video']['dark_reduced']
        sohrani()
    elif vid == 'etalon-lishnij':
        f['dvizhenie']['etalony']['GA-T16'] = {
            'keyframes': {'dark': ['0' * 64] * 5},
            'video': {'dark': '0' * 64}}
        sohrani()
    elif vid == 'istochnik-ne-sovpadaet':
        f['dvizhenie']['spec_sha256'] = 'a' * 64
        sohrani()
    elif vid == 'istochnik-otsvtstvuet':
        os.remove(put_repo('docs/ux/04_Gespraech_D24/motion/'
                           'faden-poses-gespraech.json'))
        tronutye.append('pozvonok')
    elif vid == 'kljuch-bez-kataloga':
        f['kljuchi_kopii'].append('net.takogo.kljucha')
        sohrani()
    elif vid == 'scenarij-bez-snimka':
        p = put_repo('mobile/.maestro/gespraech-tekst.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '- takeScreenshot: gespraech-tekst-ga-12\n', '')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('flow')
    elif vid == 'zony-rashodjatsja':
        p = put_pachki('kontrakt.md')
        s = open(p, encoding='utf-8').read().replace(
            ' fixtures/workshop_project/gespraech_tekst_149/', '')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('kontrakt')
    elif vid == 'ne-trogaet-ne-polon':
        f['ne_trogaet'].remove(
            'fixtures/workshop_project/ekran_shablon_132/model/fiktura/'
            'pachta_chuzhogo/kadry.json')
        sohrani()
    elif vid == 'pressable-bez-izmenenija':
        del f['prokhodimost']['pressable'][0]['izmenenie']
        sohrani()
    elif vid == 'kasanie-menshe-normy':
        for x in f['prokhodimost']['pressable']:
            if x['id'] == 'gespraech-topic-auto-erzaehlen':
                x['vysota'] = 40
        sohrani()
    elif vid == 'kasanie-v-safe-zone':
        for x in f['prokhodimost']['pressable']:
            if x['id'] == 'gespraech-mitte':
                x['y'] = 900
        sohrani()
    elif vid == 'staroj-pin-d24':
        # v2: обманный возврат пина пачки на D 2.4 Final 2 — пути/ша
        # честны против старых макетов мира (грамматика ПРИНИМАЕТ старый
        # пин), красна ЖИВАЯ мера 123: кадры-носители 1.1 против макетов
        # финала-2 (KADR_NIZHE_POROGA; замер: 390-набор 10/12 кадров
        # 0.315–0.597 < 0.600)
        for imja, prof in (('kadry.json', '390x844'),
                           ('kadry-393.json', '393x852')):
            p = put_pachki(imja)
            m = json.load(open(p, encoding='utf-8'))
            for k in m['kadry']:
                ga = k['id'].split(' ')[0]
                hell = '' if k['tema'] == 'dark' else '-Hell'
                otn = ('docs/ux/04_Gespraech_D24/pack/screens/%s/%s%s.png'
                       % (prof, ga, hell))
                k['maket'] = otn
                k['maket_sha256'] = sha(put_repo(otn))
            json.dump(m, open(p, 'w', encoding='utf-8'), ensure_ascii=False,
                      indent=1)
            tronutye.append(imja)
    elif vid == 'kadr-neodnoznachen':
        p = put_pachki('e2e.sh')
        s = open(p, encoding='utf-8').read()
        dop = ('mkdir -p "$out"/dark/run2/gespraech/takeScreenshot\n'
               'cp "%(kadr)s/GA-11_normal_dark_390x844.png" '
               '"$out"/dark/run2/gespraech/takeScreenshot/'
               'gespraech-tekst-ga-11.png\n')
        kadr = os.path.join(NOS, 'kompakt11', 'kadry')
        marker = 'exit 0'
        assert marker in s
        open(p, 'w', encoding='utf-8').write(
            s.replace(marker, dop % {'kadr': kadr} + marker, 1))
        tronutye.append('e2e')
    elif vid == 'profil-nizhe-minimuma':
        f['vtoroj_profil']['shirina'] = 390
        sohrani()
    elif vid == 'profil-bez-insetov':
        f['vtoroj_profil']['vyrez'] = 24
        sohrani()
    elif vid == 'golyl-komponent':
        f['vtoroj_profil']['obolochka'] = ''
        sohrani()
    elif vid == 'marshrut-bez-obolochki':
        p = put_repo('mobile/.maestro/gespraech-tekst-393.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '    id: tab-shell\n', '    id: shell\n')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('flow393')
    elif vid == 'marshrut-bez-snimka':
        p = put_repo('mobile/.maestro/gespraech-tekst-393.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '- takeScreenshot: gespraech-tekst-ga-12-393\n', '')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('flow393')
    elif vid == 'odna-tema':
        p = put_pachki('kadry-393.json')
        m = json.load(open(p, encoding='utf-8'))
        m['kadry'] = [k for k in m['kadry'] if k['tema'] == 'dark']
        json.dump(m, open(p, 'w', encoding='utf-8'), ensure_ascii=False,
                  indent=1)
        tronutye.append('kadry393')
    elif vid == 'nalozhenie-sloev':
        el = f['vtoroj_profil']['elementy']
        el[1]['y'], el[1]['x'] = el[0]['y'], el[0]['x']
        sohrani()
    elif vid == 'zalezaet-pod-inset':
        f['vtoroj_profil']['elementy'][0]['y'] = 10
        sohrani()
    elif vid == 'pustaja-ikonka':
        for x in f['vtoroj_profil']['elementy']:
            if 'dostupnoe_imja' in x:
                del x['dostupnoe_imja']
        sohrani()
    elif vid == 'kontrakt-dlinnyj':
        p = put_pachki('kontrakt.md')
        with open(p, 'a', encoding='utf-8') as fh:
            for _ in range(30):
                fh.write('- лишняя строка сверх одной страницы\n')
        tronutye.append('kontrakt')
    elif vid == 'literal-cveta':
        p = put_pachki('batareja/red_ekrana.sh')
        open(p, 'a', encoding='utf-8').write('# фон окна #abc123\n')
        tronutye.append('batareja')
    elif vid == 'prokhod-ne-maestro':
        f['priemka']['prokhod'] = \
            'bash mobile/e2e-gespraech-tekst/prokhod.sh'
        sohrani()
    elif vid == 'prokhod-bez-pressable':
        p = put_repo('mobile/.maestro/gespraech-tekst-prokhod.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '    id: gespraech-chip-gekauft\n', '    id: drugaja-cel\n')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('prokhod')
    elif vid == 'dvizhenie-bez-otcheta':
        f['dvizhenie']['priemka_dvizhenija'] = \
            'npm --prefix mobile test -- --ci --runInBand'
        sohrani()
    elif vid in ('dvizhenie-ne-proshla', 'otchet-ustarevshij',
                 'otchet-pustoj', 'otchet-s-provalami'):
        telo = {
            'dvizhenie-ne-proshla':
                '#!/usr/bin/env bash\nexit 1\n',
            'otchet-ustarevshij':
                '#!/usr/bin/env bash\nout=""; prev=""\nfor a in "$@"; do\n'
                '  if [ "$prev" = "--outputFile" ]; then out="$a"; fi\n'
                '  prev="$a"\ndone\n[ -n "$out" ] || exit 2\n'
                'case "$out" in\n  /*) cel="$out";;\n  *) '
                'cel="REPO/mobile/$out";;\nesac\n'
                'printf \'{"numTotalTests":10,"numPassedTests":10}\' > '
                '"$cel"\nexit 0\n',
            'otchet-pustoj':
                '#!/usr/bin/env bash\nout=""; prev=""\nfor a in "$@"; do\n'
                '  if [ "$prev" = "--outputFile" ]; then out="$a"; fi\n'
                '  prev="$a"\ndone\n[ -n "$out" ] || exit 2\n'
                'case "$out" in\n  /*) cel="$out";;\n  *) '
                'cel="REPO/mobile/$out";;\nesac\n'
                'printf \'{"numTotalTests":0,"numPassedTests":0}\\n\' > '
                '"$cel"\nexit 0\n',
            'otchet-s-provalami':
                '#!/usr/bin/env bash\nout=""; prev=""\nfor a in "$@"; do\n'
                '  if [ "$prev" = "--outputFile" ]; then out="$a"; fi\n'
                '  prev="$a"\ndone\n[ -n "$out" ] || exit 2\n'
                'case "$out" in\n  /*) cel="$out";;\n  *) '
                'cel="REPO/mobile/$out";;\nesac\n'
                'printf \'{"numTotalTests":10,"numPassedTests":6}\\n\' > '
                '"$cel"\nexit 0\n'}[vid].replace('REPO', repo)
        p = os.path.join(repo, 'bin', 'npm')
        open(p, 'w').write(telo)
        os.chmod(p, 0o755)
        if vid == 'otchet-ustarevshij':
            otp = os.path.join(repo, 'mobile', 'e2e-gespraech-tekst',
                               'jest-otchet.json')
            open(otp, 'w').write(
                '{"numTotalTests":10,"numPassedTests":10}')
        tronutye.append('npm')
    elif vid == 'e2e-ne-proshla':
        p = put_pachki('e2e.sh')
        open(p, 'w').write('#!/usr/bin/env bash\nexit 3\n')
        os.chmod(p, 0o755)
        tronutye.append('e2e')
    elif vid == 'kadr-ustarevshij':
        p = put_pachki('e2e.sh')
        open(p, 'w').write('#!/usr/bin/env bash\nset -eu\nexit 0\n')
        os.chmod(p, 0o755)
        kd = os.path.join(repo, 'mobile', 'maestro-out-gespraech-tekst',
                          'dark', 'run', 'gespraech', 'takeScreenshot')
        os.makedirs(kd, exist_ok=True)
        shutil.copy(os.path.join(NOS, 'kompakt11', 'kadry',
                                 'GA-11_normal_dark_390x844.png'),
                    os.path.join(kd, 'gespraech-tekst-ga-11.png'))
        tronutye.append('e2e')
    elif vid == 'samodelnaya-sverka':
        f['priemka']['sverka'] = ('python3 .harness149/scripts/'
                                  'sverka_maketa.py --kadry '
                                  'mobile/maestro-out-gespraech-tekst '
                                  '--repo .')
        sohrani()
    elif vid == 'razdel-otsvtstvuet':
        p = put_pachki('kontrakt.md')
        s = open(p, encoding='utf-8').read().replace(
            '## ПРОВОДКА\n', '## ИНОЙ РАЗДЕЛ\n')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('kontrakt')
    else:
        raise SystemExit('нет мутации для клетки ' + vid)
    return tronutye


# ---------- ось D: правила данных над пиннованными источниками ----------

def pravila_dannyh():
    spec = json.load(open(os.path.join(NOS, 'd24', 'spec.json'),
                          encoding='utf-8'))
    man = json.load(open(os.path.join(NOS, 'd24', 'manifest.json'),
                         encoding='utf-8'))
    # v2: источники пакета D24-Kompakt-1.1 (кадры/токены/зоны/движение)
    man11 = json.load(open(os.path.join(NOS, 'kompakt11', 'manifest.json'),
                           encoding='utf-8'))
    tok11 = json.load(open(os.path.join(NOS, 'kompakt11', 'tokens.json'),
                           encoding='utf-8'))
    fr11 = json.load(open(os.path.join(NOS, 'kompakt11', 'frames.json'),
                          encoding='utf-8'))
    T = {}
    for t in spec['tokens']:
        m = re.match(r'^([0-9.]+)ms$', t['value'])
        T[t['name']] = float(m.group(1)) if m else None
    S = {s['id']: s for s in spec['scenes']}

    def d_t30_fon_zakryvaet():
        t30 = S['GA-T30']['tracks']
        fon = [t for t in t30 if t['element'] == '#gnd'
               and t['property'] == 'opacity']
        assert fon, 'нет фона'
        koncy = fon[0]['delay']['ms'] + fon[0]['duration']['ms']
        nachala = [t['delay']['ms'] for t in t30
                   if t['element'].startswith('.L-chat2')]
        assert nachala and koncy <= min(nachala), (koncy, min(nachala))
        return koncy

    def d_t30_morph_450():
        morf = [t for t in S['GA-T30']['tracks']
                if t['element'] == '#morph'
                and t['property'] in ('left', 'top', 'w', 'h')]
        assert len(morf) == 4, len(morf)
        for t in morf:
            assert t['duration']['token'] == 'motion-morph', t
            assert t['curve']['token'] == 'ease-morph', t
            assert t['reduced_duration_ms'] == 0, t
            assert t['duration']['ms'] == T['motion-morph'], t
            assert (t['resolved']['dark']['from']
                    == t['resolved']['light']['from']
                    and t['resolved']['dark']['to']
                    == t['resolved']['light']['to']), t
        return len(morf)

    def d_t32_porjadok_sobytij():
        sob = S['GA-T32']['events']
        po = {e['element']: e['at']['ms'] for e in sob}
        assert set(('#b-mk', '#b-a', '#b-qr')) <= set(po), po
        assert po['#b-mk'] < po['#b-a'] < po['#b-qr'], po
        chipy = [e for e in sob if e['element'] == '#b-qr']
        assert len(chipy) == 1, chipy
        return po

    def d_t37_b_end_na_morfe():
        sob = {e['element']: e['at']['ms'] for e in S['GA-T37']['events']}
        assert sob.get('#b-end') == T['motion-morph'], sob
        morf = [t for t in S['GA-T37']['tracks']
                if t['element'] == '#morph'
                and t['property'] in ('left', 'top', 'w', 'h')]
        assert len(morf) == 4, len(morf)
        for t in morf:
            assert t['duration']['token'] == 'motion-morph', t
            assert t['curve']['token'] == 'ease-morph', t
            assert t['reduced_duration_ms'] == 0, t
        return sob['#b-end']

    def _px(v):
        m = re.match(r'\A([0-9]+)px\Z', v)
        assert m, v
        return int(m.group(1))

    def d_pole_rastjot():
        # v2: данные пакета 1.1 — цели касания hw/hh манифеста и токены
        # (литералов чисел нет): «Nachricht senden» появляется с текстом
        # (GA-13 есть, GA-11 нет); микрофон в поле — ЗОНА ≥ touch-target.
        # min; потолок поля — токен calc(6 * lineHeight(body)); рост
        # поля с текстом и прокрутку судит машина (pole-shest-strok)
        minimum = _px(tok11['touch-target']['min']['$value'])
        t = {ga: {x['label']: x for x in
                  man11['screens'][ga]['touch_targets']['390x844']}
             for ga in ('GA-11', 'GA-13')}
        assert 'Nachricht senden' in t['GA-13'], sorted(t['GA-13'])
        assert 'Nachricht senden' not in t['GA-11'], sorted(t['GA-11'])
        mik = t['GA-13']['Sprechen']
        assert mik['hw'] >= minimum and mik['hh'] >= minimum, mik
        stroka = _px(tok11['typography']['body']['$value']['lineHeight'])
        potolok = tok11['component'][
            '.p-chatcomp-input:not(.is-empty)']['$value']['max-height']
        assert potolok == 'calc(6 * %dpx)' % stroka, (potolok, stroka)
        return minimum

    def d_paket_kompakt():
        # v2: пачка пинует ИМЕНА кадров пакета (frames.json) с sha из
        # frames/SHA256SUMS (якорь целостности); носители зоны — байты
        # пакета; покрытие кадров полное у ВСЕХ экранов — ожидание кадров
        # GA-09/14/18/19 СНЯТО (слово владельца 2026-11-02)
        sums = {}
        for ln in open(os.path.join(NOS, 'kompakt11', 'SHA256SUMS'),
                       encoding='utf-8'):
            m = re.match(r'\A([0-9a-f]{64})  (\S.+?)\s*\Z', ln)
            if m:
                sums[m.group(2)] = m.group(1)
        assert len(sums) == 190 and len(fr11['frames']) == 188
        for ga, cov in fr11['coverage'].items():
            assert cov['coverage'] == 'full' and cov['missing'] == [], ga
            assert cov['present'] == cov['expected'] > 0, ga
        for ga in ('GA-09', 'GA-14', 'GA-18', 'GA-19'):
            assert fr11['coverage'][ga]['present'] == \
                fr11['coverage'][ga]['expected'] > 0, ga
        po_fajlu = {f['file']: f['screen'] for f in fr11['frames']}
        for imja, prof in (('kadry.json', '390x844'),
                           ('kadry-393.json', '393x852')):
            m = json.load(open(os.path.join(PACHKA, imja), encoding='utf-8'))
            for k in m['kadry']:
                b = os.path.basename(k['maket'])
                assert k['maket'] == 'docs/ux/05_Kompakt_D24/frames/' + b, k
                assert po_fajlu.get(b) == k['id'].split(' ')[0], b
                assert k['maket_sha256'] == sums[b], b
                assert sha(os.path.join(NOS, 'kompakt11', 'maket', b)) \
                    == sums[b], b
        return len(sums)

    def d_paket_zony():
        # v2: касание судится по ЗОНЕ hw/hh (слово владельца 2026-11-02):
        # видимая рамка w/h < 44 при зоне ≥ 44 находкой НЕ является;
        # аудит манифеста — under_44 = 0; pressables пачки — РОВНО зоны
        # манифеста по карте целей (gespraech-pole — ряд композера,
        # потолок/прокрутка — машина и токен)
        minimum = _px(tok11['touch-target']['min']['$value'])
        audit = man11['_meta']['audit']
        assert audit['min_hit_px'] == minimum and audit['under_44'] == 0
        assert audit['under_44_list'] == [] and audit['exceptions'] == []
        n = 0
        for ga in ('GA-11', 'GA-12', 'GA-13', 'GA-17', 'GA-18', 'GA-19'):
            for prof in ('390x844', '393x852'):
                for x in man11['screens'][ga]['touch_targets'][prof]:
                    assert x['hw'] >= minimum and x['hh'] >= minimum, x
                    n += 1
        f = json.load(open(os.path.join(PACHKA, 'forma-ekrana.json'),
                           encoding='utf-8'))
        for x in f['prokhodimost']['pressable']:
            para = KARTA_CELEJ_PRESS.get(x['id'])
            if not para:
                continue
            ga, metka = para
            cel = {y['label']: y for y in
                   man11['screens'][ga]['touch_targets']['390x844']}[metka]
            assert (x['x'], x['y'], x['shirina'], x['vysota']) == \
                (cel['x'], cel['y'], cel['hw'], cel['hh']), x['id']
        return n

    def d_paket_dvizhenie():
        # v2: движение НЕ изменилось — основа спеки пачки остаётся финалом 2:
        # motion-delta 1.1 («Против 1.0 движение не изменилось»; изменённые
        # 13 — только РАЗМЕРЫ, среди них T30/T34/T08/T37/T17 зоны 149;
        # T32/T18/T19 — «Сохранено») и токены: раздел motion БЕЗ final2
        # (final2 пишется только где Kompakt меняет значение)
        md = open(os.path.join(NOS, 'kompakt11', 'motion-delta.md'),
                  encoding='utf-8').read()
        assert 'Против 1.0 движение не изменилось' in md
        izmen = set(re.findall(r'^#### (GA-T[0-9]+)', md, re.M))
        assert len(izmen) == 13, sorted(izmen)
        sohr = md.split('### Изменено', 1)[0]
        assert '### Сохранено' in sohr
        for pid in ('GA-T30', 'GA-T34', 'GA-T08', 'GA-T37', 'GA-T17'):
            assert pid in izmen, pid
        for pid in ('GA-T32', 'GA-T18', 'GA-T19'):
            assert pid in sohr and pid not in izmen, pid

        def est_final2(d):
            if isinstance(d, dict):
                if 'final2' in d:
                    return True
                return any(est_final2(v) for v in d.values())
            return False
        assert not est_final2(tok11['motion'])
        return sorted(izmen)

    def d_paket_maska():
        # v+1 цикл 2 (слово владельца 2026-10-31; Crit149k2a класс
        # МАСКА_ПРОФИЛЯ_393): самоприменение — манифест кадров профиля
        # 393 ПАЧКИ несёт маску шапки 48 pt: mera.chrome_verh_pt == 48 и
        # верх «ekran»-элемента ВСЕХ 12 записей == 48 (repin зоны на 36
        # красит это правило; в R то же значение судит s-profil-maska-393)
        m = json.load(open(os.path.join(PACHKA, 'kadry-393.json'),
                           encoding='utf-8'))
        assert m['mera']['chrome_verh_pt'] == PROFIL393_VERH_PT, \
            m['mera']
        assert len(m['kadry']) == 12, len(m['kadry'])
        for k in m['kadry']:
            ekran = k['elementy'][0]
            assert ekran['imja'] == 'ekran', k['id']
            assert ekran['bbox_pt'][1] == PROFIL393_VERH_PT, (k['id'],
                                                               ekran)
        return PROFIL393_VERH_PT

    def d_ud_trex_scen():
        for pid in ('GA-T30', 'GA-T32', 'GA-T37'):
            for t in S[pid]['tracks']:
                vidimo = t['property'] in ('opacity', 'bg')
                if vidimo:
                    assert t['reduced_duration_ms'] <= T['motion-fast'], \
                        (pid, t['element'], t['property'])
                else:
                    assert t['reduced_duration_ms'] == 0, (pid,
                                                           t['element'])
        return 3

    return {'d-pole-rastjot': d_pole_rastjot,
            'd-t30-fon-zakryvaet': d_t30_fon_zakryvaet,
            'd-t30-morph-450': d_t30_morph_450,
            'd-t32-porjadok-sobytij': d_t32_porjadok_sobytij,
            'd-t37-b-end-na-morfe': d_t37_b_end_na_morfe,
            'd-ud-trex-scen': d_ud_trex_scen,
            'd-paket-kompakt': d_paket_kompakt,
            'd-paket-zony': d_paket_zony,
            'd-paket-dvizhenie': d_paket_dvizhenie,
            'd-paket-maska': d_paket_maska}


def zapusk_pravila_mashiny(mashina, pravilo=None):
    argv = ['node', os.path.join(MODEL, 'dvizhenie-runner.mjs'),
            '--machine', mashina, '--spec',
            os.path.join(NOS, 'd24', 'spec.json')]
    if pravilo:
        argv += ['--pravilo', pravilo]
    r = subprocess.run(argv, capture_output=True, text=True, timeout=120)
    return r.returncode, (r.stdout + r.stderr).strip()


# ---------- форма и состояния флоу: Maestro 2.11.0 + макет D 2.4 ----------


def shagi_flo(put):
    """Исполнимые шаги флоу Maestro: документы YAML ПОСЛЕ первого «---»
    (шапка appId/name — не шаги; структурный аналог ispolnimye_stroki_
    flo эталона: комментарии и шапка не шаги по построению парсера)."""
    with open(put, encoding='utf-8') as fh:
        docs = [d for d in yaml.safe_load_all(fh.read()) if d is not None]
    if len(docs) < 2:
        raise ValueError('нет исполняемого тела (после ---)')
    shagi = []
    for d in docs[1:]:
        if not isinstance(d, list):
            raise ValueError('тело флоу не список шагов')
        shagi.extend(d)
    return shagi


def _id_shaga(shag):
    """(команда, id) шага tapOn/assertVisible/assertNotVisible — картой
    {id: …} или строкой; иначе (None, None)."""
    if not isinstance(shag, dict):
        return None, None
    for komanda in ('tapOn', 'assertVisible', 'assertNotVisible'):
        v = shag.get(komanda)
        if isinstance(v, str):
            return komanda, v
        if isinstance(v, dict) and isinstance(v.get('id'), str):
            return komanda, v['id']
    return None, None


RE_VYBOR_TEMY = re.compile(r'\Agespraech-(topic|tema)-[a-z-]+\Z')


def _snimok_shaga(shag, snimok):
    """Снимок snimok в шаге В ЛЮБОЙ форме — строкой или картой {name: …}
    (клетки состояний судят кадр независимо от формы снимка: старая
    карта-форма не уводит GA-12/GA-13 из-под состояния — красное-до на
    нерепиненном клоне продукта, замер 31.10)."""
    if not isinstance(shag, dict) or 'takeScreenshot' not in shag:
        return False
    z = shag['takeScreenshot']
    if isinstance(z, str):
        return z == snimok
    return isinstance(z, dict) and z.get('name') == snimok


def sudi_flo_forma(koren, repo_r=None):
    """Форма и состояния флоу пачки (перепин 31.10: факт стенда
    Impl149b §1/§4 + сверка кадров с макетом D 2.4). SNIMOK_KARTOJ —
    каждый снимок СТРОКОВОЙ формой «takeScreenshot: имя» (карта
    {name: …} в Maestro 2.11.0 даёт «Config Field Required: path»);
    VHOD_BEZ_VKHODA — после launchApp вход в экран: assertVisible
    first-run-continue + openLink complior://start ДО первого нажатия
    (приложение открывается на корне First-Run); GA12_BEZ_VOPROSA —
    снимок GA-12 ПОСЛЕ выбора темы обязан наблюдать вопрос агента
    (gespraech-vopros-agenta) и чип ответа (манифест D 2.4: «Complior
    fragt zuerst · Antwort-Chips und «Lieber erzählen?» kommen
    zusammen»; замороженный текст: «темой в Verlauf с вопросом агента
    и чипами»); GA13_DO_OTPRAVKI — снимок GA-13 обязан идти ПОСЛЕ
    отправки (tapOn gespraech-otpravit + assertVisible
    gespraech-soobschenie-polzovatel) и НОВОГО ввода (inputText +
    assertVisible gespraech-otpravit — «Nachricht senden» только с
    текстом, d-pole-rastjot): макет GA-13 — кадр ПОСЛЕ отправки
    (карточка фактов «Aus unserem Gespräch» — следствие отправленного
    сообщения; поле несёт новый текст). Субъект — флоу пачки зоны
    (байты запинены vedro); в --repo той же мерой канон-копии
    mobile/.maestro продукта. Возврат: клетка -> список причин."""
    vhody = [(imja, os.path.join(koren, 'pachka', imja))
             for imja in FLOVY_PACHKI]
    if repo_r:
        vhody += [('repo/' + imja,
                   os.path.join(repo_r, 'mobile', '.maestro', imja))
                  for imja in FLOVY_PACHKI]
    kletki = ('s-snimok-strokoj', 's-vkhod-v-ekran',
              's-ga12-s-voprosom', 's-ga13-posle-otpravki')
    itogi = {k: [] for k in kletki}
    for imja, put in vhody:
        try:
            shagi = shagi_flo(put)
        except (OSError, ValueError, yaml.YAMLError) as e:
            for k in kletki:
                itogi[k].append('%s: %s не читается: %s'
                                % (PRICHINY_FLO[k], imja, e))
            continue
        # (1) форма снимка
        for i, shag in enumerate(shagi):
            if isinstance(shag, dict) and 'takeScreenshot' in shag:
                znach = shag['takeScreenshot']
                if not isinstance(znach, str) or not znach.strip():
                    itogi['s-snimok-strokoj'].append(
                        'SNIMOK_KARTOJ: %s шаг %d — снимок картой, '
                        'а не строкой' % (imja, i + 1))
        # (2) вход в экран после launchApp
        if any(s == 'launchApp' for s in shagi):
            perv_nazhatie = None
            for i, shag in enumerate(shagi):
                komanda, _ = _id_shaga(shag)
                if komanda == 'tapOn':
                    perv_nazhatie = i
                    break
            vhod_do = shagi[1:perv_nazhatie if perv_nazhatie else
                            len(shagi)]
            est_first_run = any(
                _id_shaga(s) == ('assertVisible', 'first-run-continue')
                for s in vhod_do)
            est_open = any(isinstance(s, dict)
                           and s.get('openLink') == 'complior://start'
                           for s in vhod_do)
            if not (est_first_run and est_open):
                itogi['s-vkhod-v-ekran'].append(
                    'VHOD_BEZ_VKHODA: %s — launchApp без входа '
                    'first-run-continue + openLink complior://start '
                    'до первого нажатия (корень First-Run: цель '
                    'экрана недостижима)' % imja)
        # (3)/(4) состояния кадров GA-12/GA-13 (оба экранных флоу)
        for suff in ('', '-393'):
            snimok12 = 'gespraech-tekst-ga-12' + suff
            i12 = next((i for i, s in enumerate(shagi)
                        if _snimok_shaga(s, snimok12)), None)
            if i12 is None:
                continue
            vybor = max((i for i, s in enumerate(shagi[:i12])
                         if _id_shaga(s)[0] == 'tapOn'
                         and RE_VYBOR_TEMY.match(_id_shaga(s)[1] or '')),
                        default=None)
            mezhdu = shagi[(vybor + 1) if vybor is not None else 0:i12]
            est_vopros = any(
                _id_shaga(s) == ('assertVisible', 'gespraech-vopros-agenta')
                for s in mezhdu)
            est_chip = any(
                _id_shaga(s) == ('assertVisible', 'gespraech-chip-gekauft')
                for s in mezhdu)
            if not (est_vopros and est_chip):
                itogi['s-ga12-s-voprosom'].append(
                    'GA12_BEZ_VOPROSA: %s — снимок %s без наблюдения '
                    'вопроса агента/чипа после выбора темы (макет GA-12: '
                    'тема в Verlauf С вопросом и чипами)'
                    % (imja, snimok12))
            snimok13 = 'gespraech-tekst-ga-13' + suff
            i13 = next((i for i, s in enumerate(shagi)
                        if _snimok_shaga(s, snimok13)), None)
            if i13 is None:
                continue
            otpravki = [i for i, s in enumerate(shagi[:i13])
                        if _id_shaga(s) == ('tapOn', 'gespraech-otpravit')]
            posle = shagi[(otpravki[-1] + 1 if otpravki else 0):i13]
            est_replica = any(
                _id_shaga(s) == ('assertVisible',
                                 'gespraech-soobschenie-polzovatel')
                for s in posle)
            est_vvod = any(isinstance(s, dict) and 'inputText' in s
                           for s in posle)
            est_knopka = any(
                _id_shaga(s) == ('assertVisible', 'gespraech-otpravit')
                for s in posle)
            if not (otpravki and est_replica and est_vvod and est_knopka):
                itogi['s-ga13-posle-otpravki'].append(
                    'GA13_DO_OTPRAVKI: %s — снимок %s до отправки/нового '
                    'ввода (макет GA-13: после отправки — реплика в ленте, '
                    'поле с новым текстом, «Nachricht senden»)'
                    % (imja, snimok13))
    return itogi


PRICHINY_FLO = {
    's-snimok-strokoj': 'SNIMOK_KARTOJ',
    's-vkhod-v-ekran': 'VHOD_BEZ_VKHODA',
    's-ga12-s-voprosom': 'GA12_BEZ_VOPROSA',
    's-ga13-posle-otpravki': 'GA13_DO_OTPRAVKI',
}


def _zerkal_zony(vrem, src):
    """Зеркальная копия зоны (для --oracle-tamper и стабов флоу):
    файлы оракула (пины/эталоны/раннер/носители) + probe.py +
    source.json + model/ + stabs/ целиком."""
    zerkalo = os.path.join(vrem, 'zona')
    os.makedirs(zerkalo, exist_ok=True)
    for otn2 in set(src['piny']['nositeli']) | {'probe.py',
                                                'source.json'}:
        if os.path.isfile(os.path.join(ZDE, otn2)):
            dst = os.path.join(zerkalo, otn2)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(os.path.join(ZDE, otn2), dst)
    for d in ('model', 'stabs'):
        srcdir = os.path.join(ZDE, d)
        if os.path.isdir(srcdir):
            shutil.copytree(srcdir, os.path.join(zerkalo, d),
                            dirs_exist_ok=True)
    return zerkalo


# ---------- лекало 143/2: инстанциация И-8 (блок Crit149 круг 1) ----------


def lekalo_zameny(src, h_ref=None):
    """Параметры инстанциации И-8; единый источник — source.json.lekalo
    (зеркало рецепта pachka/ci-recept-d149.md). H_REF — ПРИНЯТЫЙ пин
    харнесса в PR интеграции: здесь форма 40-hex (значение судит ревью
    интеграции, клетка — только литеральный пин, не плавающую ссылку)."""
    LE = src['lekalo']
    return {'{{JOB_ID}}': LE['job_id'], '{{SCREEN_ID}}': LE['screen_id'],
            '{{PACK}}': LE['pack'], '{{FLOWS}}': ','.join(LE['flows']),
            '{{H_REF}}': h_ref or 'a' * 40, '{{H_PATH}}': LE['h_path'],
            '{{AVD_PORT}}': str(LE['avd_port']),
            '{{EVIDENCE_NS}}': LE['evidence_ns']}


def _zameni_schet(tekst, staryj, novyj):
    if tekst.count(staryj) != 1:
        raise RuntimeError('лекало: якорь %r встречен %d раз'
                           % (staryj[:40], tekst.count(staryj)))
    return tekst.replace(staryj, novyj)



def instanciruj_job(src, h_ref=None):
    """Лекало + параметры И-8 -> dict job (грамматика — ТОЛЬКО пиннованный
    шаблон, второго списка обязательств в батарее нет). v+1 цикл 2
    (Crit149k2a, ПОРЯДОК_AVD_393): параллельное расширение экранного
    шага вторым boot СНЯТО — работник поднимает ОДИН эмулятор лекала;
    пару профилей (остановка первого, затем запуск 393) последовательным
    порядком ведёт e2e.sh пачки, судимый исполнением (песочница с
    двойниками SDK — sud_emuljatorov; прецедент 148 v2 по арбитражу:
    текстовый счёт boot в job не доказывает порядок)."""
    with open(LEKALO, encoding='utf-8') as fh:
        tekst = fh.read()
    zam = lekalo_zameny(src, h_ref)
    for k in sorted(zam):
        tekst = tekst.replace(k, zam[k])
    if re.search(r'\{\{[A-Z_]+\}\}', tekst):
        raise RuntimeError('лекало: незаменённый плейсхолдер')
    return yaml.safe_load(tekst)['jobs'][src['lekalo']['job_id']]


def podkljuchi_149(karta, wf, src, h_ref=None):
    """ТРИ парные правки лекала одним движением (И-8: тот же PR): запись
    карты + job из лекала (один эмулятор работника; пара профилей —
    последовательный порядок e2e.sh, слово владельца 31.10) + output
    выбора + needs ОБОИХ агрегатов. Единый источник рецепта для A-дерева
    самопроверки и живого --a-derevo."""
    LE = src['lekalo']
    JOB = LE['job_id']
    karta.setdefault('ekrany', []).append({
        'id': LE['screen_id'], 'kontrakty': ['149'],
        'status': 'in-development', 'job': JOB, 'pack': LE['pack'],
        'flows': list(LE['flows']), 'child_flows': list(LE['child_flows']),
        'puti': list(LE['puti']), 'h_checkout': [LE['h_path']],
        'output_namespace': LE['evidence_ns']})
    wf.setdefault('jobs', {})[JOB] = instanciruj_job(src, h_ref)
    vyhody = wf['jobs'].setdefault('select-screens', {}).setdefault(
        'outputs', {})
    vyhody[JOB] = '${{ steps.vybor.outputs.%s }}' % JOB
    for ag in AGREGATY:
        needs = wf['jobs'].setdefault(ag, {}).setdefault('needs', [])
        if JOB not in needs:
            needs.append(JOB)


def _zapis_chitaemaja(put):
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh), None
    except Exception as e:
        return None, 'не читается/не JSON: %s' % str(e)[:80]


def postav_a_derevo(tmp, src):
    """A-дерево самопроверки клетки: ЖИВЫЕ байты продукта (main Complior-mob
    6240f630 — механизм 143 v2 влит, пины nositeli/produkt/) + три парные
    правки И-8 + форма пачки + e2e.sh (потребление серийников). Клетка
    обязана быть здесь ЗЕЛЁНОЙ (контроль); КРАСНОЙ — на стабе-обходе
    (stabs/stab_lekalo_obhod_kritika.py)."""
    LE = src['lekalo']
    koren = os.path.join(tmp, 'a-derevo')
    os.makedirs(os.path.join(koren, '.github', 'workflows'))
    pak = os.path.join(koren, LE['pack'].strip('/'))
    os.makedirs(pak)
    with open(BAZA_KARTA, encoding='utf-8') as fh:
        karta = json.load(fh)
    with open(BAZA_WF, encoding='utf-8') as fh:
        wf = yaml.safe_load(fh)
    podkljuchi_149(karta, wf, src)
    with open(os.path.join(koren, 'mobile', 'ci-screens.json'), 'w',
              encoding='utf-8') as fh:
        json.dump(karta, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    with open(os.path.join(koren, '.github', 'workflows', 'mobile.yml'),
              'w', encoding='utf-8') as fh:
        yaml.safe_dump(wf, fh, allow_unicode=True, sort_keys=False)
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    # v+1 цикл 2: манифесты кадров — вход судов маски профиля 393 и
    # стабильности стабов (maska-36 мутирует kadry-393 в копии дерева)
    for imja in ('kadry.json', 'kadry-393.json'):
        shutil.copy(os.path.join(PACHKA, imja), os.path.join(pak, imja))
    shutil.copy(os.path.join(TEKSTY, 'e2e.sh'), os.path.join(pak, 'e2e.sh'))
    os.chmod(os.path.join(pak, 'e2e.sh'), 0o755)
    return koren



def _sudi_job_lekala(job, src):
    """Job против скелета лекала: поля DAG равны; шаги лекала — по порядку
    полными именами/uses (клетка не держит второго перечня шагов — грамматика
    одна, пиннованный шаблон); v+1 цикл 2 (Crit149k2a, ПОРЯДОК_AVD_393):
    работник поднимает ОДИН эмулятор лекала — параллельное расширение
    вторым boot СНЯТО (порядок пары профилей судится исполнением e2e.sh
    в клетке s-emuljatory-posledovatelno, прецедент 148 v2: текстовый
    счёт boot в job не доказывает остановку первого); валидатор 132 v3
    из H-пина, PORT И-8 и оба корневых флоу в FLOWS_PACHKI; H-checkout —
    принятым 40-hex пином (не плавающей ссылкой); запреты и ровно один
    «ПОВТОР: » — по всему job."""
    LE = src['lekalo']
    netu = []
    skel = instanciruj_job(src)
    for pole in ('needs', 'if', 'outputs', 'runs-on', 'timeout-minutes',
                 'permissions'):
        if job.get(pole) != skel.get(pole):
            netu.append('job.%s != лекалу' % pole)
    telo = json.dumps(job, ensure_ascii=False)
    for zapret in ('continue-on-error', 'strategy', 'matrix'):
        if zapret in telo:
            netu.append('запрещённое лекалом %s в job' % zapret)
    povtor = telo.count('ПОВТОР: ')
    if povtor != 1:
        netu.append('маркеров ПОВТОР %d (канон — ровно один)' % povtor)

    def metka(s):
        if s.get('name'):
            return 'name:' + str(s['name'])
        return 'uses:' + str(s.get('uses'))

    metki = [metka(s) for s in skel['steps']]
    sovpad = {}
    i = 0
    for s in (job.get('steps') or []):
        if i < len(metki) and metka(s) == metki[i]:
            sovpad[i] = s
            i += 1
    if i != len(metki):
        netu.append('шаги лекала не найдены по порядку (%d из %d)'
                    % (i, len(metki)))
    else:
        for n, s in sovpad.items():
            ekran = metki[n].startswith('name:Экранная пачка')
            h_checkout = metki[n].startswith('name:Checkout H пачки')
            if ekran:
                env = s.get('env') or {}
                if env.get('FLOWS_PACHKI') != ','.join(LE['flows']):
                    netu.append('FLOWS_PACHKI != оба корневых флоу И-8')
                run = str(s.get('run') or '')
                if ('python3 %s/scripts/ekran_shablon.py'
                        % LE['h_path']) not in run:
                    netu.append('экранный шаг без валидатора 132 v3 из %s'
                                % LE['h_path'])
                if ('PORT=%d' % LE['avd_port']) not in run:
                    netu.append('экранный шаг без PORT=%d' % LE['avd_port'])
                # v+1 цикл 2 (Crit149k2a, ПОРЯДОК_AVD_393): экранный шаг
                # равен СКЕЛЕТУ лекала СТРОГО — работник поднимает ОДИН
                # эмулятор; добавочное поведение в шаге (параллельный
                # второй boot, инертные строки-носители) красит здесь,
                # порядок пары профилей судится исполнением e2e.sh
                # (sud_emuljatorov; уроки mut-inert-boot-2 Crit149b и
                # арбитража 148: счёт вхождений не доказывает порядок)
                if s != skel['steps'][n]:
                    netu.append('экранный шаг != лекалу (добавочное '
                                'поведение — параллельный AVD и пр.)')
            elif h_checkout:
                et = dict(skel['steps'][n].get('with') or {})
                fact = dict(s.get('with') or {})
                ref = fact.pop('ref', None)
                et.pop('ref', None)
                if et != fact or not re.fullmatch(r'[0-9a-f]{40}',
                                                  str(ref or '')):
                    netu.append('H-checkout != лекалу (ref — принятый '
                                '40-hex пин)')
            elif s != skel['steps'][n]:
                netu.append('шаг %r != лекалу' % metki[n][5:45])
    return netu


def sud_lekalo(repo, src):
    """s-lekalo-instanciirovano (И-8; блок Crit149 круг 1): в --repo судит
    ТРИ парные правки лекала 143/2 (запись карты, job из лекала по пину
    шаблона/ключам инстанциации, output выбора + needs обоих агрегатов),
    вынос пачки мобильным общим шагом инвентаризации и НЕПУСТУЮ форму
    пачки (ekran.json={} — обход критика). Запись карты несёт НЕПУСТЫЕ
    puti (блок Crit147b: puti=[] не выбирал экран) и e2e.sh пачки
    ПОТРЕБЛЯЕТ оба серийника лекала. Отсутствие ЛЮБОГО аспекта —
    именованный отказ LEKALO_NE_INSTANCIIROVANO со списком недостающего.
    «Пропускник» ловится стабом lekalo-obhod-kritika (Н-39)."""
    LE = src['lekalo']
    JOB = LE['job_id']
    netu = []

    karta, osh = _zapis_chitaemaja(os.path.join(repo, 'mobile',
                                                'ci-screens.json'))
    if karta is None:
        netu.append('карта mobile/ci-screens.json %s' % osh)
    else:
        zapisi = [z for z in (karta.get('ekrany') or [])
                  if z.get('job') == JOB]
        if not zapisi:
            netu.append('нет записи карты с job %s' % JOB)
        else:
            z = zapisi[0]
            if z.get('id') != LE['screen_id']:
                netu.append('id записи %r' % z.get('id'))
            if '149' not in (z.get('kontrakty') or []):
                netu.append('kontrakty записи без 149')
            if z.get('status') not in ('in-development', 'approved'):
                netu.append('status записи %r' % z.get('status'))
            if z.get('pack') != LE['pack']:
                netu.append('pack записи %r' % z.get('pack'))
            for f in LE['flows']:
                if f not in (z.get('flows') or []):
                    netu.append('flows записи без %s' % f)
            for f in LE['child_flows']:
                if f not in (z.get('child_flows') or []):
                    netu.append('child_flows записи без %s' % f)
            puti = z.get('puti') or []
            if not puti:
                netu.append('puti записи пусты (экран не выбирается по '
                            'путям — блок Crit147b)')
            else:
                for pu in LE['puti']:
                    if pu not in puti:
                        netu.append('puti записи без %s' % pu)
            if LE['h_path'] not in (z.get('h_checkout') or []):
                netu.append('h_checkout записи без %s' % LE['h_path'])
            if z.get('output_namespace') != LE['evidence_ns']:
                netu.append('output_namespace записи %r'
                            % z.get('output_namespace'))

    ej, osh = _zapis_chitaemaja(os.path.join(repo, LE['pack'].strip('/'),
                                             'ekran.json'))
    if ej is None:
        netu.append('ekran.json пачки %s' % osh)
    elif not isinstance(ej, dict) or not ej:
        netu.append('ekran.json пачки пуст (обход Crit149: {})')
    else:
        if ej.get('shablon') != LE['shablon']:
            netu.append('ekran.json shablon %r' % ej.get('shablon'))
        if ej.get('ekran') != LE['screen_id']:
            netu.append('ekran.json ekran %r' % ej.get('ekran'))
        ekrany = ((ej.get('dvizhenie') or {}).get('ekrany')) or []
        if set(ekrany) != set(LE['ekrany']):
            netu.append('ekrany формы %s' % sorted(ekrany))

    put_e2e = os.path.join(repo, LE['pack'].strip('/'), 'e2e.sh')
    try:
        with open(put_e2e, encoding='utf-8') as fh:
            tekst_e2e = fh.read()
    except Exception:
        tekst_e2e = ''
        netu.append('e2e.sh пачки не читается (порты пары не потребляются)')
    # v+1 цикл 2: e2e.sh пачки ведёт пару профилей (остановка первого,
    # затем запуск 393) — судится ИСПОЛНЕНИЕМ в sud_emuljatorov; здесь
    # только привязка к ПОРТАМ лекала (серийники — производные портов)
    for port in (LE['avd_port'], LE['avd_port_393']):
        if ('=%d' % port) not in tekst_e2e:
            netu.append('e2e.sh пачки без порта %d пары профилей' % port)

    put_wf = os.path.join(repo, '.github', 'workflows', 'mobile.yml')
    try:
        with open(put_wf, encoding='utf-8') as fh:
            wf = yaml.safe_load(fh)
    except Exception as e:
        wf = None
        netu.append('mobile.yml не читается: %s' % str(e)[:80])
    if wf is not None:
        jobs = wf.get('jobs') or {}
        if JOB not in jobs:
            netu.append('нет job %s в mobile.yml' % JOB)
        else:
            netu.extend(_sudi_job_lekala(jobs[JOB], src))
        outs = ((jobs.get('select-screens') or {}).get('outputs') or {})
        if outs.get(JOB) != '${{ steps.vybor.outputs.%s }}' % JOB:
            netu.append('output выбора %s отсутствует/не из шага vybor'
                        % JOB)
        for ag in AGREGATY:
            if JOB not in ((jobs.get(ag) or {}).get('needs') or []):
                netu.append('needs агрегата %s без %s' % (ag, JOB))
        tekst = json.dumps(wf, ensure_ascii=False)
        shagi_q = ((jobs.get('quality') or {}).get('steps') or [])
        if not any('--mode inventar' in str(s.get('run') or '')
                   for s in shagi_q):
            netu.append('в quality нет общего шага --mode inventar')
        if re.search(r'mv\s+mobile/e2e-gespraech-tekst\b', tekst):
            netu.append('персональный mv пачки (вынос — общий шаг)')
        if re.search(r'mv\s+mobile/e2e-\*', tekst):
            netu.append('wildcard-вынос mobile/e2e-*')
    return (not netu, '' if not netu else
            'LEKALO_NE_INSTANCIIROVANO: ' + '; '.join(netu))



# ---------- v+1 цикл 2 (Crit149k2a): последовательная пара AVD 393 и
# маска профиля 393 — суд ИСПОЛНЕНИЕМ/ЗНАЧЕНИЕМ (прецедент 148 v2) ----


PROFIL393_VERH_PT = 48  # слово владельца 2026-10-31: маска шапки 393


# Двойники несут состояние живых серийников и журнал событий. Они
# ставятся в PATH и ANDROID_HOME: обе формы запуска e2e.sh идут в
# песочницу, не к настоящему Android SDK. Журнал — наблюдение, НЕ оракул
# ожиданий: порты и начальное состояние (живой эмулятор работника
# лекала) остаются у судьи в памяти (правило 8).
DVOJNIK = r'''#!/usr/bin/env python3
import os
import pathlib
import sys
import time

state = pathlib.Path(os.environ["GESpraechTekst149_STATE"])
log = pathlib.Path(os.environ["GESpraechTekst149_LOG"])
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]

def read_state():
    return state.read_text(encoding="utf-8").splitlines()

def event(line):
    with log.open("a", encoding="utf-8") as output:
        output.write(line + "\n")

if name == "adb":
    if args == ["devices"]:
        print("List of devices attached")
        for serial in read_state():
            print(serial + "\tdevice")
    elif len(args) >= 4 and args[0] == "-s" and args[2:] == ["emu", "kill"]:
        serial = args[1]
        event("KILL " + serial)
        state.write_text("".join(s + "\n" for s in read_state() if s != serial),
                         encoding="utf-8")
    elif len(args) >= 3 and args[0] == "-s" and args[2] == "wait-for-device":
        deadline = time.monotonic() + 5
        while args[1] not in read_state():
            if time.monotonic() >= deadline:
                sys.exit(1)
            time.sleep(0.01)
    elif "getprop" in args:
        print("1")
elif name == "emulator":
    port = args[args.index("-port") + 1] if "-port" in args and args.index("-port") + 1 < len(args) else ""
    event("START " + port)
    with state.open("a", encoding="utf-8") as output:
        output.write("emulator-" + port + "\n")
'''


def sud_emuljatorov(repo, src):
    """s-emuljatory-posledovatelno (слово владельца 2026-10-31, Astra
    mob-ci-razdelenie п.342; вердикт Crit149k2a класс ПОРЯДОК_AVD_393):
    до старта 393 первый AVD гарантированно остановлен. Исполняем
    e2e.sh пачки R без настоящего SDK: на входе ЖИВ эмулятор работника
    лекала (порт avd_port), двойники adb/emulator/maestro/sleep пишут
    журнал KILL/START; суд — только по событиям журнала (не по словам
    скрипта): каждый START обязан идти портом avd_port_393 и ТОЛЬКО при
    пустом множестве живых (иначе AVD393_ZAPUSCHEN_DO_OSTANOVKI —
    параллельный job красен); запуск, обошедший PATH/ANDROID_HOME, и
    отсутствие STOP у первого не образуют событий (AVD393_NET_ZAPUSKA);
    ненулевой rc скрипта — AVD393_E2E_RC. Возвращает список аспектов
    отказа (пустой — зелено)."""
    LE = src['lekalo']
    put = os.path.join(repo, LE['pack'].strip('/'), 'e2e.sh')
    if not os.path.isfile(put):
        return ['нет %s (жизненный цикл пары профилей — слово владельца '
                '31.10)' % os.path.join(LE['pack'].strip('/'), 'e2e.sh')]
    with tempfile.TemporaryDirectory(prefix='gespraechtekst149-avd-') as d:
        cwd = os.path.join(d, 'zapusk')
        os.makedirs(cwd)
        shutil.copyfile(put, os.path.join(cwd, 'e2e.sh'))
        os.chmod(os.path.join(cwd, 'e2e.sh'), 0o755)
        # e2e.sh судит наличие своих флоу (rc 3) — песочница несёт их
        # из пачки зоны: двойник maestro не читает их, но честный вход
        # обязан существовать (как в дереве продукта)
        for potok in LE['flows']:
            imja_potoka = os.path.basename(potok)
            kuda = os.path.join(cwd, os.path.dirname(potok))
            os.makedirs(kuda, exist_ok=True)
            shutil.copyfile(os.path.join(PACHKA, imja_potoka),
                            os.path.join(kuda, imja_potoka))
        bin_dir = os.path.join(d, 'bin')
        sdk_bin = os.path.join(d, 'android', 'emulator')
        os.makedirs(bin_dir)
        os.makedirs(sdk_bin)
        for imja in ('adb', 'emulator', 'maestro', 'sleep'):
            dvojnik = os.path.join(bin_dir, imja)
            with open(dvojnik, 'w', encoding='utf-8') as fh:
                fh.write(DVOJNIK)
            os.chmod(dvojnik, 0o755)
        os.symlink(os.path.join(bin_dir, 'emulator'),
                   os.path.join(sdk_bin, 'emulator'))
        sostojanie = os.path.join(d, 'state')
        zhurnal = os.path.join(d, 'events')
        with open(sostojanie, 'w', encoding='utf-8') as fh:
            fh.write('emulator-%d\n' % LE['avd_port'])
        open(zhurnal, 'w', encoding='utf-8').close()
        env = dict(os.environ)
        env['PATH'] = os.pathsep.join([bin_dir, env.get('PATH', '')])
        env['ANDROID_HOME'] = os.path.join(d, 'android')
        env['GESpraechTekst149_STATE'] = sostojanie
        env['GESpraechTekst149_LOG'] = zhurnal
        # e2e.sh кладёт кадры в mobile/maestro-out-… — cwd одноразовый
        protsess = subprocess.Popen(
            ['bash', os.path.join(cwd, 'e2e.sh'), LE['screen_id']],
            cwd=cwd, env=env, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, start_new_session=True)
        try:
            protsess.communicate(timeout=30)
            status = protsess.returncode
        except subprocess.TimeoutExpired:
            try:
                os.killpg(protsess.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            protsess.communicate()
            status = 'ТАЙМАУТ (30 с)'
        try:
            stroki = open(zhurnal, encoding='utf-8').read().splitlines()
        except OSError as e:
            return ['AVD393_ZHURNAL: журнал недоступен: %s' % e]
        zhivye = {'emulator-%d' % LE['avd_port']}
        aspekty, zapuskov, narushen = [], 0, False
        for stroka in stroki:
            if stroka.startswith('KILL '):
                zhivye.discard(stroka[5:])
            elif stroka.startswith('START '):
                port = stroka[6:]
                zapuskov += 1
                if zhivye and not narushen:
                    aspekty.append(
                        'AVD393_ZAPUSCHEN_DO_OSTANOVKI: START %s при '
                        'живом %s' % (port, ', '.join(sorted(zhivye))))
                    narushen = True
                if port != str(LE['avd_port_393']):
                    aspekty.append('AVD393_PORT_NE_%d: START %s, требуется '
                                   '%d' % (LE['avd_port_393'], port,
                                           LE['avd_port_393']))
                zhivye.add('emulator-%s' % port)
        if zapuskov == 0:
            aspekty.append(
                'AVD393_NET_ZAPUSKA: нет START в журнале; запуск 393 '
                'отсутствует или обошёл PATH/ANDROID_HOME')
        if status != 0:
            aspekty.append('AVD393_E2E_RC: e2e.sh rc=%s' % status)
        return aspekty


def sud_maski_profilja(repo, src):
    """s-profil-maska-393 (слово владельца 2026-10-31, Q1б; вердикт
    Crit149k2a класс МАСКА_ПРОФИЛЯ_393): все кадры профиля 393
    сравниваются с утверждённой маской шапки 48 pt (вырез камеры).
    Судится ТОЧНОЕ ЗНАЧЕНИЕ манифеста кадров профиля R (файл — по
    записи vtoroj_profil.kadry формы): mera.chrome_verh_pt == 48 И верх
    «ekran»-элемента КАЖДОЙ записи == 48; 36/47/49 проходят визуальную
    меру — значение красит именованно (прецедент proverka_maski_profilja
    148). Нечитаемые пачка/манифест не судятся здесь (их раньше красит
    s-pachka-validirovana). Возвращает аспект или None."""
    LE = src['lekalo']
    pachka = os.path.join(repo, LE['pack'].strip('/'))
    imja = 'kadry-393.json'
    try:
        forma = json.load(open(os.path.join(pachka, 'ekran.json'),
                               encoding='utf-8'))
        imja = ((forma.get('vtoroj_profil') or {}).get('kadry')
                or imja)
    except (OSError, ValueError):
        return None
    put = os.path.join(pachka, imja)
    try:
        m = json.load(open(put, encoding='utf-8'))
    except (OSError, ValueError):
        return None
    aspekty = []
    if (m.get('mera') or {}).get('chrome_verh_pt') != PROFIL393_VERH_PT:
        aspekty.append('mera.chrome_verh_pt=%r' % m.get('mera'))
    for k in m.get('kadry') or []:
        ekran = (k.get('elementy') or [{}])[0]
        if ekran.get('imja') == 'ekran' and \
                ekran.get('bbox_pt', [0, 0])[1] != PROFIL393_VERH_PT:
            aspekty.append('%s: ekran.bbox_pt=%s' % (k.get('id'),
                                                     ekran.get('bbox_pt')))
    if aspekty:
        return ('PROFIL_MASKA_NE_48: %s: %s — маска шапки профиля 393 — '
                '%d pt (слово владельца 31.10; значение — независимо от '
                'визуальной меры)' % (imja, '; '.join(aspekty[:4]),
                                      PROFIL393_VERH_PT))
    return None

def ispolnimyj_sud(mob_koren, src, podrobno=True):
    """Исполняемый суд экрана (блок 1 Crit149b: «реальный UI должен быть
    доказуем заявленной командой, а не выводиться из наличия машины и
    канона»; прецедент ispolnimyj_sud 148): живой jest-зонд
    produkt/gespraech-zond-149.test.tsx (пин source.json) на РЕАЛЬНЫХ
    компонентах дерева — чат-хост GespraechTekstChat (канонический путь
    mobile/src/features/conversation/chat-host.tsx) и композер
    ChatComposer (mobile/src/ui/conversation-composer/...) — в
    изолированной копии mobile (node_modules — симлинк установки R),
    плюс матрица мутантов «пустой хост»/«композер не изменён» (байты
    product main, носитель зоны): контроль зелен, каждый мутант убит
    УПАВШИМ АССЕРТОМ. Падение загрузки сьюта мутантом НЕ засчитывается
    (ISPOLNIMYJ_MUTANT_NE_UBIT), красный контроль — ISPOLNIMYJ_
    KONTROL_KRASEN, зелёный под мутантом — ISPOLNIMYJ_MUTANT_ZHIV.
    Дерево без mobile/package.json — именованный пропуск (stderr), не
    зелень продукта; заявленная среда без установки — LIVE_PREDPOSYLKA,
    НИКОГДА skip->pass (прецедент proba_live_put 145). Возвращает
    (prichiny, otkaz) — otkaz 'skip' только для дерева без package.json.
    """
    mob = mob_koren
    if not os.path.isfile(os.path.join(mob, 'package.json')):
        print('ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда',
              file=sys.stderr)
        return [], 'skip'
    if not os.path.isfile(ZOND) or sha(ZOND) != \
            src['piny']['sha']['produkt/%s' % ZOND_IMJA]:
        return ['ORACLE_TAMPERED: пин зонда не совпал'], None
    predposylki = []
    konfig = None
    for imja in ('jest.config.js', 'jest.config.json'):
        if os.path.isfile(os.path.join(mob, imja)):
            konfig = imja
            break
    if konfig is None:
        predposylki.append('нет mobile/jest.config.{js,json}')
    nm = os.path.join(mob, 'node_modules')
    for paket in ('jest-expo', '@testing-library/react-native'):
        if not os.path.isfile(os.path.join(nm, paket, 'package.json')):
            predposylki.append('не установлен пакет %s' % paket)
    if not os.path.exists(os.path.join(nm, '.bin', 'jest')):
        predposylki.append('нет node_modules/.bin/jest')
    for otn in (HOST_V_PRODUKTE, KOMPOZER_V_PRODUKTE,
                MASHINA_V_PRODUKTE):
        if not os.path.isfile(os.path.join(mob_koren, '..', otn)):
            predposylki.append('нет компонента %s' % otn)
    # v+1 цикл 2: зонд судит зоны/токены ПАКЕТОМ D24-Kompakt-1.1 —
    # tokens.json обязан лежать в R (композер потребляет его же);
    # ekran.json пачки — карта pressable (конечный домен зон)
    tok_paketa = os.path.join('docs', 'ux', '05_Kompakt_D24', 'source',
                              'tokens.json')
    if not os.path.isfile(os.path.join(mob_koren, '..', tok_paketa)):
        predposylki.append('нет пакета 1.1 %s' % tok_paketa)
    if not os.path.isfile(os.path.join(mob_koren, 'e2e-gespraech-tekst',
                                       'ekran.json')):
        predposylki.append('нет ekran.json пачки (карта pressable зонда)')
    if predposylki:
        return ['LIVE_PREDPOSYLKA: %s' % '; '.join(predposylki)], None
    vrem = tempfile.mkdtemp(prefix='gespraechtekst149-live-')
    try:
        kopija = os.path.join(vrem, 'mobile')
        shutil.copytree(mob, kopija,
                        ignore=shutil.ignore_patterns('node_modules'))
        os.symlink(os.path.realpath(nm), os.path.join(kopija,
                                                      'node_modules'))
        # пакет 1.1 рядом с копией mobile (референс-композер и зонд
        # читают токены по относительному пути <корень>/docs/…)
        tok_kuda = os.path.join(vrem, tok_paketa)
        os.makedirs(os.path.dirname(tok_kuda), exist_ok=True)
        shutil.copyfile(os.path.join(mob_koren, '..', tok_paketa), tok_kuda)
        zond = os.path.join(kopija, ZOND_KUDA, ZOND_IMJA)
        os.makedirs(os.path.dirname(zond), exist_ok=True)
        shutil.copy(ZOND, zond)

        def zapustit():
            try:
                p = subprocess.run(
                    [os.path.join(kopija, 'node_modules', '.bin', 'jest'),
                     '--config', konfig, '--rootDir', '.', '--ci',
                     '--runInBand', '--json', 'gespraech-zond'],
                    cwd=kopija, capture_output=True, text=True, timeout=1200)
            except subprocess.TimeoutExpired:
                return None, 'ТАЙМАУТ jest (1200 с)'
            tek = (p.stdout or '').strip()
            try:
                return json.loads(tek), None
            except json.JSONDecodeError:
                a, b = tek.find('{'), tek.rfind('}')
                if a < 0 or b <= a:
                    return None, 'jest без JSON-итога rc=%d: %s' % (
                        p.returncode, (p.stderr or tek)[:200])
                try:
                    return json.loads(tek[a:b + 1]), None
                except json.JSONDecodeError:
                    return None, 'jest JSON не разобран rc=%d' % p.returncode

        def klassifikirovat(svod):
            """(упавших ассертов, не исполнившихся сьютов): падение
            загрузки/трансформации НЕ засчитывается убитым мутантом."""
            assery, sjuity = 0, 0
            for sjuit in svod.get('testResults') or []:
                utv = sjuit.get('assertionResults') or []
                if not utv:
                    sjuity += 1
                    continue
                for a in utv:
                    if a.get('status') == 'failed':
                        assery += 1
            return assery, sjuity

        ishodnye = {}
        for _imja, otn, _istochnik in MUTANTY_ISPOLNIMYE:
            put = os.path.join(kopija, os.path.relpath(otn, 'mobile'))
            ishodnye[otn] = open(put, encoding='utf-8').read()

        svod, oshibka = zapustit()
        if svod is None:
            return ['ISPOLNIMYJ_INFRA: контроль: %s' % oshibka], None
        assery, _sjuity = klassifikirovat(svod)
        zelen = bool(svod.get('success')) and \
            int(svod.get('numPassedTests', 0)) > 0
        if podrobno:
            print('ISPOLNIMYJ kontrol %s — suites=%s tests=%s' % (
                'ZELEN' if zelen else 'KRASEN',
                svod.get('numTotalTestSuites'),
                svod.get('numTotalTests')), file=sys.stderr)
        if not zelen:
            return ['ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных '
                    'компонентах R (упавших ассертов %d)' % assery], None

        # v+1 цикл 2 вызов 2 (вердикт Crit149k2b, класс РЕАЛЬНЫЙ_
        # ТОКЕН_ПОЛЯ): приёмка различает СВЯЗЬ компонента с токеном и
        # совпадение ТЕКУЩЕГО числа. Контрольный прогон обязан быть
        # ЗЕЛЁНЫМ дважды: на пиннованном пакете (выше) и на ПОДМЕНЁННОМ
        # другом допустимом значении — lineHeight Npx → N+2px, потолок
        # calc(6 * Npx) → calc(6 * (N+2)px), грамматика та же; высота
        # поля обязана СЛЕДОВАТЬ за токеном. Подмена — ТОЛЬКО в
        # изолированной копии суда (пакет R не трогается; предложение
        # вердикта: «зонд подменяет значение токена в изолированной
        # копии на другое допустимое»). Мутанты ниже исполняются ПОД
        # подменой: литерал 21 наблюдаем именно там (пиннованный проход
        # ему зелён — совпадение числа, не связь).
        tok_ishodnyj = open(tok_kuda, encoding='utf-8').read()
        paket_tok = json.loads(tok_ishodnyj)
        telo = str(paket_tok['typography']['body']['$value']['lineHeight'])
        m_tela = re.match(r'\A(\d+(?:\.\d+)?)px\Z', telo)
        if m_tela is None:
            return ['ISPOLNIMYJ_INFRA: контроль: токен lineHeight вне '
                    'грамматики Npx: %r' % telo], None
        staryj = float(m_tela.group(1))
        if staryj != int(staryj):
            return ['ISPOLNIMYJ_INFRA: контроль: дробная высота строки '
                    '%r — подмена не определена' % telo], None
        novyj = '%d' % (int(staryj) + 2)
        paket_tok['typography']['body']['$value']['lineHeight'] = \
            novyj + 'px'
        paket_tok['component']['.p-chatcomp-input:not(.is-empty)'] \
            ['$value']['max-height'] = 'calc(6 * %spx)' % novyj
        with open(tok_kuda, 'w', encoding='utf-8') as fh:
            json.dump(paket_tok, fh, ensure_ascii=False, indent=2)
        svod, oshibka = zapustit()
        if svod is None:
            return ['ISPOLNIMYJ_INFRA: подмена токена: %s' % oshibka], None
        assery, _sjuity = klassifikirovat(svod)
        zelen = bool(svod.get('success')) and \
            int(svod.get('numPassedTests', 0)) > 0
        if podrobno:
            print('ISPOLNIMYJ token-podmena %s — lineHeight %dpx→%spx' % (
                'ZELEN' if zelen else 'KRASEN', int(staryj), novyj),
                file=sys.stderr)
        if not zelen:
            return ['ISPOLNIMYJ_TOKEN_NE_POTREBLJON: высота поля не '
                    'следует за токеном — подмена lineHeight %dpx→%spx '
                    'красна (упавших ассертов %d); совпадение текущего '
                    'числа связью с токеном не является'
                    % (int(staryj), novyj, assery)], None

        zhivye, neubit = [], []
        for imja, otn, istochnik in MUTANTY_ISPOLNIMYE:
            put = os.path.join(kopija, os.path.relpath(otn, 'mobile'))
            tekst = ishodnye[otn]
            with open(istochnik, encoding='utf-8') as fh:
                mutacija = fh.read()
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(mutacija)
            svod, oshibka = zapustit()
            if svod is None:
                neubit.append('%s(infra: %s)' % (imja, oshibka))
                if podrobno:
                    print('ISPOLNIMYJ mutant %s INFRA — %s'
                          % (imja, oshibka), file=sys.stderr)
            else:
                assery, sjuity = klassifikirovat(svod)
                if assery > 0:
                    if podrobno:
                        print('ISPOLNIMYJ mutant %s UBIT — упавших '
                              'ассертов %d' % (imja, assery),
                              file=sys.stderr)
                elif sjuity > 0:
                    neubit.append('%s(сьют не исполнился)' % imja)
                    if podrobno:
                        print('ISPOLNIMYJ mutant %s NE_UBIT — сьют(ы) не '
                              'исполнились' % imja, file=sys.stderr)
                else:
                    zhivye.append(imja)
                    if podrobno:
                        print('ISPOLNIMYJ mutant %s ZHIV — зонд зелён под '
                              'мутантом' % imja, file=sys.stderr)
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(tekst)
        # токен изолированной копии — исходные байты (инвариант для
        # читающих код суда; копия ниже сносится целиком)
        with open(tok_kuda, 'w', encoding='utf-8') as fh:
            fh.write(tok_ishodnyj)
        prichiny = []
        if zhivye:
            prichiny.append('ISPOLNIMYJ_MUTANT_ZHIV: %s' % ', '.join(zhivye))
        if neubit:
            prichiny.append('ISPOLNIMYJ_MUTANT_NE_UBIT: %s'
                            % ', '.join(neubit))
        return prichiny, None
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


def postav_zhivoe_a_derevo(produkt, cel, src):
    """Живой зелёный контроль (рецепт И-8, прецедент 147): продукт P
    (клон Complior-mob) -> A-дерево C: канон-байты (11 пинов) + машина +
    форма пачки + e2e/prokhod + ТРИ парные правки лекала. На C батарея
    --repo обязана дать rc 0 (все клетки)."""
    LE = src['lekalo']
    kanon = src['piny']['kanon']
    if set(kanon) != set(KANON_V_ZONE):
        print('ORACLE_TAMPERED piny.kanon != карта носителей зоны',
              file=sys.stderr)
        return 2
    for otn, fajl in KANON_V_ZONE.items():
        if sha(os.path.join(ZDE, fajl)) != kanon[otn]:
            print('ORACLE_TAMPERED байты канона %s' % fajl, file=sys.stderr)
            return 2
    if os.path.exists(cel):
        print('OTKAZ: цель существует: %s' % cel, file=sys.stderr)
        return 2
    ignor = shutil.ignore_patterns('.git', 'node_modules')
    shutil.copytree(produkt, cel, ignore=ignor)
    for otn, fajl in KANON_V_ZONE.items():
        put = os.path.join(cel, otn)
        os.makedirs(os.path.dirname(put), exist_ok=True)
        shutil.copy(os.path.join(ZDE, fajl), put)
    pak = os.path.join(cel, LE['pack'].strip('/'))
    os.makedirs(pak, exist_ok=True)
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    for imja in ('e2e.sh', 'prokhod.sh'):
        shutil.copy(os.path.join(TEKSTY, imja), os.path.join(pak, imja))
        os.chmod(os.path.join(pak, imja), 0o755)
    mashina = os.path.join(cel, 'mobile', 'src', 'features',
                           'conversation')
    os.makedirs(mashina, exist_ok=True)
    shutil.copy(os.path.join(MODEL, 'chat-machine.ts'),
                os.path.join(mashina, 'chat-machine.ts'))
    # референс-раскладка экрана (блок 1 Crit149b): чат-хост + композер
    for otn in (HOST_V_PRODUKTE, KOMPOZER_V_PRODUKTE,
                os.path.join('mobile', 'src', 'features', 'conversation',
                             'chat-kopija.ts')):
        shutil.copy(os.path.join(RASKLADKA, otn),
                    os.path.join(cel, otn))
    # jest-среда: node_modules продукта — симлинком (зонд копию не
    # тащит; прецедент zhivoj_komponent 145 / ispolnimyj_sud 148)
    nm_isto = os.path.join(produkt, 'mobile', 'node_modules')
    if os.path.isdir(nm_isto):
        os.symlink(os.path.realpath(nm_isto),
                   os.path.join(cel, 'mobile', 'node_modules'))
    with open(os.path.join(cel, 'mobile', 'ci-screens.json'),
              encoding='utf-8') as fh:
        karta = json.load(fh)
    with open(os.path.join(cel, '.github', 'workflows', 'mobile.yml'),
              encoding='utf-8') as fh:
        wf = yaml.safe_load(fh)
    podkljuchi_149(karta, wf, src)
    with open(os.path.join(cel, 'mobile', 'ci-screens.json'), 'w',
              encoding='utf-8') as fh:
        json.dump(karta, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    with open(os.path.join(cel, '.github', 'workflows', 'mobile.yml'),
              'w', encoding='utf-8') as fh:
        yaml.safe_dump(wf, fh, allow_unicode=True, sort_keys=False)
    print('A-DEREVO %s job=%s kanon=%d mashina=1 ekran.json=forma'
          % (cel, LE['job_id'], len(kanon)))
    return 0


def postav_fejk_jest(vrem, jest_skript):
    """Фиктивная jest-среда стабов jest-* (прецедент _fejk_jest_sreda
    148): заявленная package.json среда + метаданные пакетов +
    node_modules/.bin/jest с зашитым итогом + компоненты референс-
    раскладки батареи по каноническим путям — исполняемый путь клетки
    s-ekran-ispolnim доходит до запуска jest и классифицирует исходы
    ИМЕННО, без RN-рантайма. Возвращает корень mobile фиктивной среды."""
    koren = os.path.join(vrem, 'fejk')
    mob = os.path.join(koren, 'mobile')
    for otn in (HOST_V_PRODUKTE, KOMPOZER_V_PRODUKTE,
                os.path.join('mobile', 'src', 'features', 'conversation',
                             'chat-kopija.ts')):
        dst = os.path.join(koren, otn)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(os.path.join(RASKLADKA, otn), dst)
    dst = os.path.join(koren, MASHINA_V_PRODUKTE)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy(os.path.join(MODEL, 'chat-machine.ts'), dst)
    # v+1 цикл 2: зонд судит зоны/токены пачкой — фиктивная среда несёт
    # те же входы (ekran.json пачки + tokens.json пакета), чтобы путь
    # клетки дошёл до запуска jest, а не до LIVE_PREDPOSYLKA
    pak = os.path.join(mob, 'e2e-gespraech-tekst')
    os.makedirs(pak, exist_ok=True)
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    tok = os.path.join(koren, 'docs', 'ux', '05_Kompakt_D24', 'source',
                       'tokens.json')
    os.makedirs(os.path.dirname(tok), exist_ok=True)
    shutil.copy(os.path.join(NOS, 'kompakt11', 'tokens.json'), tok)
    open(os.path.join(mob, 'package.json'), 'w').write(
        '{"name":"mobile-fejk","private":true}')
    open(os.path.join(mob, 'jest.config.js'), 'w').write(
        'module.exports = {};\n')
    for paket in ('jest-expo', '@testing-library/react-native'):
        d = os.path.join(mob, 'node_modules', paket)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, 'package.json'), 'w').write(
            '{"name":"%s","version":"0.0.0-fejk"}' % paket)
    bindir = os.path.join(mob, 'node_modules', '.bin')
    os.makedirs(bindir, exist_ok=True)
    shutil.copy(jest_skript, os.path.join(bindir, 'jest'))
    os.chmod(os.path.join(bindir, 'jest'), 0o755)
    return mob


def main():
    argv = sys.argv[1:]
    rezhim = 'koren'
    repo_r = None
    seed = 149
    if '--model' in argv:
        rezhim = 'model'
    elif '--stabs' in argv:
        rezhim = 'stabs'
    elif '--repo' in argv:
        rezhim = 'repo'
        repo_r = argv[argv.index('--repo') + 1]
    elif '--oracle-tamper' in argv:
        rezhim = 'tamper'
    elif '--a-derevo' in argv:
        i = argv.index('--a-derevo')
        if i + 2 >= len(argv):
            print('OTKAZ: --a-derevo <продукт> <цель>', file=sys.stderr)
            return 2
        return postav_zhivoe_a_derevo(argv[i + 1], argv[i + 2], vedro())
    if '--seed' in argv:
        seed = int(argv[argv.index('--seed') + 1])
    src = vedro()
    if '--piny-only' in argv:
        return 0
    if '--flo-forma-only' in argv:
        # клеточный прогон формы/состояний флоу (зеркала стабов флоу):
        # те же клетки, что в полном прогоне; rc 1 — красная клетка
        prichiny_flo = sudi_flo_forma(ZDE)
        for kletka in sorted(prichiny_flo):
            spisok = prichiny_flo[kletka]
            print('CASE %s %s %s'
                  % (kletka, 'ok' if not spisok else 'KRASNO',
                     '; '.join(spisok)))
        return 1 if any(prichiny_flo.values()) else 0

    if rezhim == 'tamper':
        prov = 0
        for imja in sorted(src['piny']['nositeli']):
            otn = imja
            vrem = tempfile.mkdtemp(prefix='gespraechtekst149-tamper-')
            zerkalo = _zerkal_zony(vrem, src)
            # портим ОДИН носитель в зеркале
            p = os.path.join(zerkalo, otn)
            with open(p, 'ab') as fh:
                fh.write(b'x')
            env = dict(os.environ)
            env['GESpraechTekst149_ZONA'] = zerkalo
            r = subprocess.run([sys.executable, os.path.join(zerkalo,
                                                             'probe.py'),
                                '--piny-only'], capture_output=True,
                               text=True, env=env, timeout=300)
            if r.returncode != 2 or 'ORACLE_TAMPERED' not in r.stderr:
                print('ORACLE_TAMPER nositel %s НЕ ПОЙМАН (rc=%d)'
                      % (imja, r.returncode))
                shutil.rmtree(vrem, ignore_errors=True)
                return 1
            prov += 1
            shutil.rmtree(vrem, ignore_errors=True)
        print('ORACLE_TAMPER_PROVERENO nositelej=%d' % prov)
        return 0

    itogi = []
    subjar = {'model': ETALON, 'stabs': ETALON, 'repo': ETALON,
              'koren': ZHIVOJ}[rezhim]

    # ---- ось A
    for k in ['kontrol-forma'] + sorted(OZHIDAEMYE_PRICHINY):
        vrem = tempfile.mkdtemp(prefix='gespraechtekst149-a-')
        try:
            repo, hrn, pak = postav_mir(vrem)
            if k != 'kontrol-forma':
                if not izmeni(pak, repo, k):
                    sys.stderr.write('ORACLE мутация %s ничего не тронула\n'
                                     % k)
                    return 2
            rc_e, pr_e = zapusk_valid(ETALON, pak, repo, hrn)
            if k == 'kontrol-forma':
                if rc_e != 0:
                    sys.stderr.write(
                        'ORACLE контроль не зелён на эталоне: rc=%d %s\n'
                        % (rc_e, pr_e))
                    return 2
            else:
                imja = OZHIDAEMYE_PRICHINY[k]
                if imja not in pr_e:
                    sys.stderr.write(
                        'ORACLE клетка %s: эталон не дал %s (дал %s)\n'
                        % (k, imja, pr_e))
                    return 2
            if subjar == ETALON:
                rez_s = (rc_e, pr_e)
            else:
                # СВЕЖИЙ мир для субъекта: повторный запуск на том же
                # мире видел бы СЛЕДЫ эталона (кадры/отчёт приёмки уже
                # лежат — свежесть даёт ложное KADR_USTAREVSHIJ); равный
                # суд требует равный вход, мутация та же (правило 8)
                vrem2 = tempfile.mkdtemp(prefix='gespraechtekst149-sub-')
                try:
                    repo2, hrn2, pak2 = postav_mir(vrem2)
                    if k != 'kontrol-forma':
                        if not izmeni(pak2, repo2, k):
                            sys.stderr.write(
                                'ORACLE мутация %s не повторилась\n' % k)
                            return 2
                    rez_s = zapusk_valid(subjar, pak2, repo2, hrn2)
                finally:
                    shutil.rmtree(vrem2, ignore_errors=True)
            if rez_s == (rc_e, pr_e):
                itogi.append(('a-' + k, True, ''))
            else:
                itogi.append(('a-' + k, False,
                              'субъект rc=%s %s; эталон rc=%s %s'
                              % (rez_s[0], rez_s[1], rc_e, pr_e)))
        finally:
            shutil.rmtree(vrem, ignore_errors=True)

    # ---- ось D
    for imja, fn in sorted(pravila_dannyh().items()):
        try:
            fn()
            itogi.append((imja, True, ''))
        except AssertionError as e:
            itogi.append((imja, False, 'данные: %r' % (e,)))

    # ---- ось M
    mashina_sub = os.path.join(MODEL, 'chat-machine.ts')
    net_subiekta = rezhim == 'koren'
    if rezhim == 'repo':
        mprod = os.path.join(repo_r, 'mobile', 'src', 'features',
                             'conversation', 'chat-machine.ts')
        if os.path.isfile(mprod):
            mashina_sub = mprod
        else:
            net_subiekta = True
    for p in PRAVILA_MASHINY:
        if net_subiekta:
            itogi.append(('m-' + p, False, 'SUBJECT_ABSENT chat-machine'))
        else:
            rc, vyv = zapusk_pravila_mashiny(mashina_sub, p)
            itogi.append(('m-' + p, rc == 0, '' if rc == 0 else vyv[-200:]))

    # ---- ось S
    kanon = src['piny']['kanon']

    def kanon_ok():
        for otn, h in kanon.items():
            p = os.path.join(repo_r, otn)
            if not os.path.isfile(p) or sha(p) != h:
                return False
        return bool(kanon)

    proverki = [
        ('s-pachka-v-produkte',
         os.path.isfile(os.path.join(repo_r or '/net', 'mobile',
                                     'e2e-gespraech-tekst',
                                     'ekran.json'))),
        ('s-mashina-v-produkte',
         os.path.isfile(os.path.join(repo_r or '/net', 'mobile', 'src',
                                     'features', 'conversation',
                                     'chat-machine.ts'))),
        ('s-kanon-bajty', repo_r is not None and kanon_ok()),
    ]
    for idk, ok in proverki:
        if rezhim == 'koren':
            itogi.append((idk, False, 'SUBJECT_ABSENT продукт'))
        elif rezhim in ('model', 'stabs'):
            itogi.append((idk, True, 'статически-зелёный контроль (модель)'))
        else:
            itogi.append((idk, bool(ok), '' if ok else 'нет/не совпало'))

    # отказ LEKALO_NE_INSTANCIIROVANO со списком недостающего (блок
    # Crit149 круг 1: ekran.json={} без карты/job/output/needs проходил
    # W --repo rc 0 82/82)
    if rezhim == 'koren':
        itogi.append(('s-lekalo-instanciirovano', False,
                      'SUBJECT_ABSENT продукт'))
    elif rezhim in ('model', 'stabs'):
        itogi.append(('s-lekalo-instanciirovano', True,
                      'статически-зелёный контроль (модель)'))
    else:
        ok_l, pochemu_l = sud_lekalo(repo_r, src)
        itogi.append(('s-lekalo-instanciirovano', ok_l,
                      '' if ok_l else pochemu_l))

    # полный суд пачки валидатором v3 (блок 1 Crit149b: W --repo принимал
    # продукт с ekran.json={shablon,ekran,dvizhenie.ekrany} rc 0 83/83);
    # собственные литеральные проверки полей НЕ изобретаются — форма
    # судится ТОЛЬКО замороженным валидатором 146 (пин 5fd1415e) в
    # синтетическом репо из файлов R
    if rezhim == 'koren':
        itogi.append(('s-pachka-validirovana', False,
                      'SUBJECT_ABSENT продукт'))
    elif rezhim in ('model', 'stabs'):
        itogi.append(('s-pachka-validirovana', True,
                      'статически-зелёный контроль (модель)'))
    else:
        ok_v, pochemu_v = sud_pachki_validiatorom(repo_r, src)
        itogi.append(('s-pachka-validirovana', ok_v,
                      '' if ok_v else pochemu_v))

    # исполняемый суд экрана (блок 1 Crit149b): живой jest-зонд на
    # РЕАЛЬНЫХ компонентах R + матрица мутантов; без mobile/package.json —
    # именованный пропуск (не зелень продукта), заявленная среда без
    # установки — LIVE_PREDPOSYLKA (никогда skip→pass)
    if rezhim == 'koren':
        itogi.append(('s-ekran-ispolnim', False,
                      'SUBJECT_ABSENT продукт'))
    elif rezhim in ('model', 'stabs'):
        itogi.append(('s-ekran-ispolnim', True,
                      'статически-зелёный контроль (модель)'))
    else:
        prichiny_z, otkaz_z = ispolnimyj_sud(
            os.path.join(repo_r, 'mobile'), src)
        if otkaz_z == 'skip':
            itogi.append(('s-ekran-ispolnim', True,
                          'ISPOLNIMYJ_SKIP: не jest-среда (нет '
                          'mobile/package.json)'))
        else:
            itogi.append(('s-ekran-ispolnim', not prichiny_z,
                          '; '.join(prichiny_z)))

    # v+1 цикл 2 (Crit149k2a, ПОРЯДОК_AVD_393): до старта 393 первый AVD
    # гарантированно остановлен — суд ИСПОЛНЕНИЕМ e2e.sh пачки R в
    # песочнице с двойниками SDK (прецедент 148 v2); параллельный job
    # (START при живом первом) красен AVD393_ZAPUSCHEN_DO_OSTANOVKI
    if rezhim == 'koren':
        itogi.append(('s-emuljatory-posledovatelno', False,
                      'SUBJECT_ABSENT продукт'))
    elif rezhim in ('model', 'stabs'):
        itogi.append(('s-emuljatory-posledovatelno', True,
                      'статически-зелёный контроль (модель)'))
    else:
        aspekty_avd = sud_emuljatorov(repo_r, src)
        itogi.append(('s-emuljatory-posledovatelno', not aspekty_avd,
                      '; '.join(aspekty_avd)))

    # v+1 цикл 2 (Crit149k2a, МАСКА_ПРОФИЛЯ_393): все кадры профиля 393
    # сравниваются с утверждённой маской 48 pt — суд ЗНАЧЕНИЯ манифеста
    # кадров R (36/47/49 визуально зелёны — красит именованно)
    if rezhim == 'koren':
        itogi.append(('s-profil-maska-393', False,
                      'SUBJECT_ABSENT продукт'))
    elif rezhim in ('model', 'stabs'):
        itogi.append(('s-profil-maska-393', True,
                      'статически-зелёный контроль (модель)'))
    else:
        aspekt_maski = sud_maski_profilja(repo_r, src)
        itogi.append(('s-profil-maska-393', aspekt_maski is None,
                      aspekt_maski or ''))
    # клетки формы/состояний флоу (перепин 31.10): субъект — флоу пачки
    # зоны (байты запинены vedro), в --repo — и канон-копии mobile/.maestro
    for kletka, spisok in sorted(sudi_flo_forma(ZDE, repo_r).items()):
        itogi.append((kletka, not spisok, '; '.join(spisok)))
    zelen = sum(1 for _, ok, _ in itogi if ok)
    krasn = len(itogi) - zelen
    for idk, ok, pochemu in itogi:
        print('CASE %s %s %s' % (idk, 'ok' if ok else 'KRASNO', pochemu))

    svjazi = 0
    if rezhim == 'stabs':
        for stab, svaz in sorted(src['stab_vhod'].items()):
            if 'kletka' in svaz:
                continue  # стабы лекала — ниже, отдельным контуром
            put = os.path.join(STABY, src['staby'][stab])
            rc, vyv = zapusk_pravila_mashiny(put, svaz['pravilo'])
            if rc == 0:
                print('STAB %s ZHIV (правило %s зелено на стабе)'
                      % (stab, svaz['pravilo']))
                return 1
            print('STAB %s KRASEN %s' % (stab, svaz['pravilo']))
            svjazi += 1
        # стаб лекала (Н-39, блок Crit149 круг 1): обход критика — канон и
        # машина на месте, проводки нет, ekran.json={}. Пара входов одной
        # клеткой: A-дерево рецепта ЗЕЛЁНО (живые байты продукта 6240f630 +
        # три парные правки), стаб-обход КРАСЕН; мутант-«пропускник»
        # (клетка зелена без проверок) ловится здесь — STAB_ZHIV rc 1.
        vrem_a = tempfile.mkdtemp(prefix='gespraechtekst149-lekalo-')
        try:
            a_der = postav_a_derevo(vrem_a, src)
            ok_a, pochemu_a = sud_lekalo(a_der, src)
            if not ok_a:
                sys.stderr.write('ORACLE A-дерево не зелено: %s\n'
                                 % pochemu_a)
                return 2
            stub = os.path.join(vrem_a, 'stub')
            shutil.copytree(a_der, stub)
            r = subprocess.run([sys.executable,
                                os.path.join(STABY, src['staby'][
                                    'lekalo-obhod-kritika']), stub],
                               capture_output=True, text=True, timeout=60)
            if r.returncode != 0:
                sys.stderr.write('ORACLE стаб лекала: мутатор rc=%d %s\n'
                                 % (r.returncode, r.stderr.strip()[:120]))
                return 2
            ok_s, pochemu_s = sud_lekalo(stub, src)
            if ok_s:
                print('STAB lekalo-obhod-kritika ZHIV (клетка зелена на '
                      'обходе критика: ekran.json={} без проводки)')
                return 1
            print('STAB lekalo-obhod-kritika KRASEN s-lekalo-instanciirovano')
            svjazi += 1
        finally:
            shutil.rmtree(vrem_a, ignore_errors=True)
        # стабы v+1 цикла 2 (Н-39; Crit149k2a): пара входов одной клеткой
        # на ТОМ ЖЕ рецепте A-дерева — emuljatory-odnovremenno красит
        # s-emuljatory-posledovatelno (исполнение e2e.sh: START 393 до
        # остановки первого), maska-36 красит s-profil-maska-393
        # (значение 36 вместо 48); зелёный контроль клеток — прогон
        # суда на НЕмутированном рецепте (выше A-дерево зелено, клетка
        # репе — a-derevo живого продукта); «пропускник» ловится STAB_ZHIV
        vrem_r2 = tempfile.mkdtemp(prefix='gespraechtekst149-r2-')
        try:
            a2 = postav_a_derevo(vrem_r2, src)
            for stab, kletka, prichina in (
                    ('emuljatory-odnovremenno',
                     's-emuljatory-posledovatelno',
                     'AVD393_ZAPUSCHEN_DO_OSTANOVKI'),
                    ('maska-36', 's-profil-maska-393',
                     'PROFIL_MASKA_NE_48')):
                stub_r = os.path.join(vrem_r2, 'stub-' + stab)
                shutil.copytree(a2, stub_r)
                r = subprocess.run(
                    [sys.executable, os.path.join(STABY,
                                                  src['staby'][stab]),
                     stub_r], capture_output=True, text=True, timeout=60)
                if r.returncode != 0:
                    sys.stderr.write('ORACLE стаб %s: мутатор rc=%d %s\n'
                                     % (stab, r.returncode,
                                        r.stderr.strip()[:120]))
                    return 2
                if stab == 'emuljatory-odnovremenno':
                    aspekty_r = sud_emuljatorov(stub_r, src)
                    svod_r = '; '.join(aspekty_r)
                else:
                    svod_r = sud_maski_profilja(stub_r, src) or ''
                if not svod_r:
                    print('STAB %s ZHIV (клетка %s зелена на стабе)'
                          % (stab, kletka))
                    return 1
                if prichina not in svod_r:
                    sys.stderr.write('ORACLE стаб %s: красна не своей '
                                     'причиной: %s\n' % (stab, svod_r[:160]))
                    return 2
                print('STAB %s KRASEN %s' % (stab, prichina))
                svjazi += 1
        finally:
            shutil.rmtree(vrem_r2, ignore_errors=True)
        # стаб ekran-minimalnyj (блок 1 Crit149b, Н-39): мир оси A (пачка
        # эталона + источники) с МИНИМАЛЬНОЙ формой ekran.json — дословная
        # атака Crit149b-mut-ekran-minimal; клетка s-pachka-validirovana
        # обязана краснеть; «пропускник» (зелена без суда валидатором)
        # оставил бы вход зелёным — STAB_ZHIV rc 1
        vrem_e = tempfile.mkdtemp(prefix='gespraechtekst149-ekmin-')
        try:
            repo_e, _hrn_e, _pak_e = postav_mir(vrem_e)
            r = subprocess.run([sys.executable,
                                os.path.join(STABY, src['staby'][
                                    'ekran-minimalnyj']), repo_e],
                               capture_output=True, text=True, timeout=60)
            if r.returncode != 0:
                sys.stderr.write('ORACLE стаб ekran-minimalnyj: мутатор '
                                 'rc=%d %s\n' % (r.returncode,
                                                 r.stderr.strip()[:120]))
                return 2
            ok_e, pochemu_e = sud_pachki_validiatorom(repo_e, src)
            if ok_e:
                print('STAB ekran-minimalnyj ZHIV (пачка-минимум прошла '
                      'суд валидатором)')
                return 1
            if 'PACHKA_NE_PROSHLA_VALIDATOR' not in pochemu_e:
                sys.stderr.write('ORACLE стаб ekran-minimalnyj: причина '
                                 '%s\n' % pochemu_e[:160])
                return 2
            print('STAB ekran-minimalnyj KRASEN s-pachka-validirovana')
            svjazi += 1
        finally:
            shutil.rmtree(vrem_e, ignore_errors=True)
        # стабы jest-krasnyj/jest-zelenyj (блок 1 Crit149b, Н-39;
        # прецедент _fejk_jest_sreda 148): фиктивная jest-среда из
        # референс-раскладки батареи — исполняемый путь клетки доходит
        # до запуска jest и классифицирует исходы ИМЕННО: зашитый красный
        # итог — ISPOLNIMYJ_KONTROL_KRASEN, зашитый зелёный (мутанты
        # живы) — ISPOLNIMYJ_MUTANT_ZHIV; судья, не различающий их, —
        # рассинхрон rc 2
        for stab_name, ozhidaemaja in (
                ('jest-krasnyj', 'ISPOLNIMYJ_KONTROL_KRASEN'),
                ('jest-zelenyj', 'ISPOLNIMYJ_MUTANT_ZHIV')):
            vrem_j = tempfile.mkdtemp(prefix='gespraechtekst149-jest-')
            try:
                mob = postav_fejk_jest(vrem_j, os.path.join(
                    STABY, src['staby'][stab_name]))
                prichiny_j, otkaz_j = ispolnimyj_sud(mob, src,
                                                     podrobno=False)
                svod = '; '.join(prichiny_j)
                if otkaz_j == 'skip' or (not prichiny_j):
                    print('STAB %s ZHIV (исполняемый суд зелён на '
                          'фиктивной среде)' % stab_name)
                    return 1
                if ozhidaemaja not in svod:
                    sys.stderr.write('ORACLE стаб %s: причина %s\n'
                                     % (stab_name, svod[:160]))
                    return 2
                print('STAB %s KRASEN s-ekran-ispolnim (%s)'
                      % (stab_name, ozhidaemaja))
                svjazi += 1
            finally:
                shutil.rmtree(vrem_j, ignore_errors=True)
        # стабы формы/состояний флоу (Н-39; перепин 31.10): обманный
        # ПЕРЕПИН — флоу И пины source.json меняются вместе (порчу
        # носителя ловит vedro ДО клеток, перепин — только клетка
        # формы/состояния). Зеркальная копия зоны; клеточный прогон
        # --flo-forma-only обязан дать rc 1 СВОИМ именем причины (иначе
        # ORACLE — стаб красен не своим дефектом); зелёный контроль —
        # клетки формы выше (живая зона зелена). Мутант-«пропускник»
        # (клетка зелена без разбора) ловится здесь — STAB_ZHIV rc 1.
        for stab in sorted(KLETKI_FLO_STABOV):
            kletka, prichina = KLETKI_FLO_STABOV[stab]
            vrem_f = tempfile.mkdtemp(prefix='gespraechtekst149-flo-')
            try:
                zerkalo = _zerkal_zony(vrem_f, src)
                r = subprocess.run(
                    [sys.executable,
                     os.path.join(STABY, src['staby'][stab]), zerkalo],
                    capture_output=True, text=True, timeout=60)
                if r.returncode != 0:
                    sys.stderr.write('ORACLE стаб %s: мутатор rc=%d %s\n'
                                     % (stab, r.returncode,
                                        r.stderr.strip()[:120]))
                    return 2
                env = dict(os.environ)
                env['GESpraechTekst149_ZONA'] = zerkalo
                d = subprocess.run(
                    [sys.executable, os.path.join(zerkalo, 'probe.py'),
                     '--flo-forma-only'], capture_output=True, text=True,
                    env=env, timeout=300)
                if d.returncode == 0:
                    print('STAB %s ZHIV (клетка %s зелена на стабе)'
                          % (stab, kletka))
                    return 1
                if prichina not in d.stdout:
                    sys.stderr.write('ORACLE стаб %s: красна не своей '
                                     'причиной: %s\n' % (stab,
                                                         d.stdout.strip()))
                    return 2
                print('STAB %s KRASEN %s' % (stab, prichina))
                svjazi += 1
            finally:
                shutil.rmtree(vrem_f, ignore_errors=True)
        print('SVJAZI %d' % svjazi)

    print('клеток %d, зелёных %d, красных %d; режим %s seed %d'
          % (len(itogi), zelen, krasn, rezhim, seed))
    if krasn:
        return 1
    if rezhim == 'stabs' and svjazi != len(src['stab_vhod']):
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
