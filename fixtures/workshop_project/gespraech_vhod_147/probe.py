#!/usr/bin/env python3
# Контракт 147 (gespraech-vhod-menu): guard-канал §ПРОВОДКА.
# Субъекты: (1) живой валидатор 132 v3 scripts/ekran_shablon.py против
# эталона model/ekran_shablon.py (пин байтов) на мирах пачки; (2) машина
# вход-меню (модель model/menu-machine.ts; в продукте —
# mobile/src/features/conversation/menu-machine.ts) против пиннованной
# спеки дизайнера (раннер model/dvizhenie-runner.mjs); (3) пачка и канон
# в продукте (--repo); (4) CI-проводка экрана (--repo; И-8): инстанциация
# ЛЕКАЛА screen-job.template.yml (frozen 143/2, копия в nositeli/, пин)
# тремя парными правками — запись карты, output выбора, needs обоих
# агрегатов — плюс вынос пачки общим шагом инвентаризации (блок Crit147
# круг 1: ekran.json={} без проводки проходил 70/70). Цикл 2 (вердикт
# Crit147 v2a, слово владельца 31.10): эмуляторы ПОСЛЕДОВАТЕЛЬНО —
# остановку 390 и запуск 393 несёт e2e.sh пачки после кадров 390
# (экранный шаг создаёт AVD393 и передаёт окружение пары; параллельный
# запуск — LEKALO_PARALLELNYJ_ZAPUSK_393, замаскированный отказ —
# LEKALO_MASKA_OTKAZA_393); кадр GA-01 исключён из пиксельной сверки
# (GA01_V_SVERKE), маска шапки 393 = 48 pt (MASKA_393_NE_48). Цикл 2
# вызов 2 (вердикт Crit147k2b): уход 390 ПОДТВЕРЖДАЕТСЯ исполнением —
# e2e.sh в песочнице двойников SDK, «залипший» 390 красит клетку
# s-e2e-ostanovka-podtverzhena (E2E_ZAPUSK_PRI_ZHIVOM_390 и наследуемые);
# реальный потребитель — jest-зонд produkt/ на РЕАЛЬНЫХ компонентах
# дерева + матрица мутантов (клетка s-ekran-ispolnim). Оракул —
# пины source.json (проверяются ДО любого субъекта) и ожидания,
# вычисленные ЭТАЛОНОМ на том же входе ДО субъекта (правило 8); каждая
# красная клетка несёт РОВНО одно имя причины.
#
# Режимы (argv):
#   (без флага)   судится живое дерево харнесса: валидатор scripts/, в
#                 продукте субъекта нет — клетки s-*/m-* красны поимённо
#                 (SUBJECT_ABSENT); клетки a-* красны, пока живой скрипт
#                 не равен эталону v3 (до пачки implementer 146)
#   --model       субъект = эталон (контроль входов)
#   --stabs       контроль + обманные стабы (SVJAZI N, живых 0)
#   --repo R      судится живой продукт R (машина/канон/пачка)
#   --a-derevo P C  (служебный) живой рецепт И-8: продукт P -> A-дерево C
#                 (карта+job из лекала+output+needs+пачка) — зелёный
#                 контроль клетки s-lekalo-instanciirovano (W --repo C)
#   --oracle-tamper  порча каждого носителя по очереди в одноразовой
#                 копии зоны — ORACLE_TAMPERED rc 2 ДО клеток
#   --piny-only   (служебный) только проверка пинов оракула
#   --flo-forma-only  (служебный) только клетки формы флоу
#   --kadry-forma-only  (служебный) только клетки кадровых инвариантов
#                 сверки (GA-01 вне сверки, маска 393 = 48)
#   --e2e-zhizncikl-only  (служебный) только клетка жизненного цикла
#                 пары 390/393 ИСПОЛНЕНИЕМ (зеркала стаба e2e)
#   --seed N      seed сеяных входов (право судьи — перезапуск)
#
# Коды возврата: 0 — зелено; 1 — красная клетка/живой стаб/нет субъекта;
# 2 — ORACLE_TAMPERED, рассинхрон реестра, нечем проверять.
#
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import hashlib
import yaml

ZDE = os.environ.get('GESpraech147_ZONA',
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
# Гейт пустого продукта (контракт 159): общий отказ по признаку пустоты —
# первое действие --repo-ветви экранных батарей домена.
GEJT_PUSTOGO_PRODUKTA = os.path.join(KOREN, 'scripts',
                                    'check_pustoj_produkt.sh')
# Доверенный интерпретатор гейта — АБСОЛЮТНЫЙ путь: подмена bash через
# PATH подменяла сам гейт (adversary 159, блок 2). Нет интерпретатора —
# именованный fail-closed rc 2 NOT_IMPLEMENTED, обращения к PATH нет.
DOVERENNYY_BASH = '/usr/bin/bash'

PEREHODY = ['GA-T28', 'GA-T29', 'GA-T30', 'GA-T31', 'GA-T33', 'GA-T35']
PRAVILA_MASHINY = ['plan-open-t28', 'sprechen-pervym', 'menja-k-300',
                   'znak-morf-250', 'press-long-500', 'plan-close-t31',
                   'ud-bez-poljota']

# флоу пачки (байты — носители зоны, пин source.json; канон-копии в
# продукте — piny.kanon) и клетки их формы: исполнимость в Maestro
# 2.11.0 (факт Impl147e 31.10 §4: закреплённые флоу НЕ исполнялись —
# снимок картой {name: …} даёт «Config Field Required: path», а нажатие
# вкладки из профиля недостижимо без возврата shell-back). Привязка
# стаба формы — имя стаба -> (клетка, причина); единый источник здесь,
# source.json.stab_vhod сверяется с ним в vedro.
FLOVY_PACHKI = ('gespraech-vhod.yaml', 'gespraech-vhod-393.yaml',
                'gespraech-prokhod.yaml')
KLETKI_FLO_STABOV = {
    'flo-staraq-forma': ('s-snimok-strokoj', 'SNIMOK_KARTOJ'),
    'prokhod-bez-shell-back': ('s-profil-vozvrat', 'PROFIL_BEZ_VOZVRATA'),
}

# кадровые инварианты сверки (цикл 2, слово владельца 31.10): стаб —
# обманный ПЕРЕПИН манифестов пачки (записи И пины source.json меняются
# вместе); клетка — имя, причина — РОВНО одно имя (единый источник здесь,
# source.json.stab_vhod сверяется с ним в vedro)
KLETKI_KADRY_STABOV = {
    'sverka-s-ga01': ('s-ga01-vne-sverki', 'GA01_V_SVERKE'),
    'maska-36': ('s-maska-393-48', 'MASKA_393_NE_48'),
}

# жизненный цикл пары ИСПОЛНЕНИЕМ (цикл 2, вердикт Crit147k2b класс
# ПОРЯДОК AVD): стаб — обманный ПЕРЕПИН канона e2e.sh (снятие блока
# подтверждения ухода — дословный обход критика: rc 0 при «залипшем»
# 390); клетка исполняет e2e.sh в песочнице двойников SDK
KLETKI_E2E_STABOV = {
    'e2e-bez-podtverzdenija': ('s-e2e-ostanovka-podtverzhena',
                               'E2E_ZAPUSK_PRI_ZHIVOM_390'),
}

# исполняемый суд экрана (цикл 2, вердикт Crit147k2b класс РЕАЛЬНЫЙ
# ПОТРЕБИТЕЛЬ): стабы — фиктивные jest-среды с зашитым итогом (красный
# контроль / зелёный с живыми мутантами) — судят КЛАССИФИКАЦИЮ судьи,
# не компоненты (прецедент 148/149)
KLETKI_JEST_STABOV = {
    'jest-krasnyj': ('s-ekran-ispolnim', 'ISPOLNIMYJ_KONTROL_KRASEN'),
    'jest-zelenyj': ('s-ekran-ispolnim', 'ISPOLNIMYJ_MUTANT_ZHIV'),
}

# исполняемый зонд реальных компонентов (цикл 2, Crit147k2b Б2): файл
# зоны (пин sha) и адрес в дереве; референс-раскладка — копии
# настоящих компонентов продукта с зонами по токенам пакета 1.1
# (прецедент 148/149): несут ЗЕЛЁНЫЙ контроль A-дерева, мутанты
# батареи применяются к файлам дерева по якорям
ZOND = os.path.join(ZDE, 'produkt', 'gespraech-vhod-zond-147.test.tsx')
ZOND_IMJA = 'gespraech-vhod-zond-147.test.tsx'
ZOND_KUDA = os.path.join('mobile', 'src', 'bootstrap', '__tests__')
RASKLADKA = os.path.join(MODEL, 'produktnaja-raskladka')
RASKLADKA_V_PRODUKTE = ('mobile/src/bootstrap/tab-shell.tsx',
                        'mobile/src/theme/motion-tokens.ts')
TOKENY_PAKETA_OTN = os.path.join('docs', 'ux', '05_Kompakt_D24',
                                 'source', 'tokens.json')
# Мутанты относятся к наблюдаемой ветви: область, действие, полнота —
# основной прогон; совпадающий литерал — только прогон с изменённым токеном.
MUTACII_ISPOLNIMYE = [
    ('tab-zona-20', 'mobile/src/bootstrap/tab-shell.tsx',
     'style={styles.tab}',
     'style={[styles.tab, { width: 20, height: 20, minWidth: 20, minHeight: 20 }]}'),
    ('press-long-900', 'mobile/src/theme/motion-tokens.ts',
     "'press-long': '500ms',", "'press-long': '900ms',"),
    ('disabled-menu', 'mobile/src/bootstrap/tab-shell.tsx',
     '<Pressable key={id} testID={`gespraech-menu-${id}`}',
     '<Pressable disabled key={id} testID={`gespraech-menu-${id}`}'),
    ('missing-ansehen', 'mobile/src/bootstrap/tab-shell.tsx',
     'testID="gespraech-menu-ansehen"', 'testID="gespraech-menu-weg"'),
    ('no-close-action', 'mobile/src/bootstrap/tab-shell.tsx',
     'onPress={() => setMenu(\'closed\')} style={styles.ziel}',
     'style={styles.ziel}'),
]
# Сдвиг порога press-long (цикл 2, вердикт Crit147k2c Б2):
# СИНТАКСИЧЕСКИ НЕЗАВИСИМАЯ мутация — добавка «50 +» к ЛЮБОМУ выражению
# delayLongPress, как бы кандидат ни читал токен (литерал, replace, slice,
# вычисление в другой функции). Зонд измеряет фактический порог UI на
# фейк-часах с допуском 1 мс такта, поэтому мутант обязан быть убит
# ПОВЕДЕНИЕМ на самом кандидате; подмена кандидата референсом при
# несовпадении синтаксиса — только с ЯВНЫМ извещением в stderr.
MUTACII_REGULJARNYE = [
    ('press-long-sdvig', 'mobile/src/bootstrap/tab-shell.tsx',
     r'delayLongPress=\{', r'delayLongPress={50 + '),
]
MUTACII_ISPOLNIMYE += [
    # testID и ≥44 стиль на ДОЧЕРНЕМ Text, Pressable 20×20 (Crit147k2c Б1,
    # дословный мутант критика): зонд судит зону ИНТЕРКТИВНОГО узла —
    # кнопка 20×20 обязана краснеть собственным ассертом зоны.
    ('child-testid-hitarea', 'mobile/src/bootstrap/tab-shell.tsx',
     '''<Pressable key={id} testID={`gespraech-menu-${id}`}
                      onPress={() => { onCommandRef.current?.({ kind: id }); setMenu('closed'); }}
                      style={styles.ziel}><Text>{id}</Text></Pressable>''',
     '''<Pressable key={id}
                      onPress={() => { onCommandRef.current?.({ kind: id }); setMenu('closed'); }}
                      style={{ width: 20, height: 20 }}>
                      <Text testID={`gespraech-menu-${id}`} style={styles.ziel}>{id}</Text>
                    </Pressable>'''),
]
MUTACII_ISPOLNIMYE += [
    # Различимость состояний меню (цикл 2, вердикт Crit147k2d класс
    # РАЗЛИЧИМОСТЬ ОЖИДАЮЩЕГО VORGANG): две половины мутанта критика —
    # «Vorgänge ansehen» открывает обычное меню (GA-16 недостижим
    # собственной целью-входом) и «Ansehen» рендерится в любом открытом
    # меню (слияние состояний) — плюс цель-вход Mitte, ведущая в GA-16.
    # Зонд достигает каждое состояние СВОЕЙ целью-входа и требует:
    # «Ansehen» появляется ТОЛЬКО в GA-16 и действует, обычное меню
    # Mitte его не выдаёт; каждый мутант обязан краснеть собственным
    # ассертом различимости (обе половины вместе = дословное дерево
    # атаки критика, краснота объединения следует из красноты половин:
    # ассерт GA-15 ловит слияние, ассерт GA-16 — недостижимость).
    ('vorgang-nedostizhim', 'mobile/src/bootstrap/tab-shell.tsx',
     "onPress={() => setMenu('vorgang')}",
     "onPress={() => setMenu('open')}"),
    ('ansehen-v-obychnom', 'mobile/src/bootstrap/tab-shell.tsx',
     "{menu === 'vorgang' ? (", "{menu !== 'closed' ? ("),
    ('mitte-otkryvaet-vorgang', 'mobile/src/bootstrap/tab-shell.tsx',
     "onPress={() => setMenu('open')}",
     "onPress={() => setMenu('vorgang')}"),
]
# Независимое упрочнение Arch147w (до вызова 5/5): пропуски, найденные
# второй парой глаз по классам 1–11 (klassy-realnyj-komponent.md).
MUTACII_ISPOLNIMYE += [
    # КЛАСС 1/10 (зона): maxWidth/maxHeight — ПОТОЛОК реальной зоны:
    # min* 44 при потолке 20 даёт реальные 20×20; измеритель зонда
    # обязан резать границу потолком (мутант зелёным был ДО правки).
    ('zone-maxkap', 'mobile/src/bootstrap/tab-shell.tsx',
     'ziel: { minHeight: ziel, minWidth: ziel },',
     'ziel: { minHeight: ziel, minWidth: ziel, maxWidth: 20,'
     ' maxHeight: 20 },'),
    # КЛАСС 9 (результат нажатия своей цели): пилюля шлёт ЧУЖОЙ ответ
    # (sprechen) ПЕРЕД своим — «последний вызов» свой; ловится счётом
    # вызовов (ровно один новый), а не только lastCalledWith.
    ('piljja-chuzhoj-pered', 'mobile/src/bootstrap/tab-shell.tsx',
     "onPress={() => { onCommandRef.current?.({ kind: id });"
     " setMenu('closed'); }}",
     "onPress={() => { onCommandRef.current?.({ kind: 'sprechen' });"
     " onCommandRef.current?.({ kind: id }); setMenu('closed'); }}"),
    # КЛАСС 9/11 (домен состояние×цель): в ждущем меню GA-16 пилюли
    # schreiben/foto/dokument шлют чужой ответ — зонд давит ВСЕ пилюли
    # в ОБЕИХ меню с счётом вызовов и своим kind.
    ('piljuli-ga16-chuzhoj', 'mobile/src/bootstrap/tab-shell.tsx',
     "onPress={() => { onCommandRef.current?.({ kind: id });"
     " setMenu('closed'); }}",
     "onPress={() => { onCommandRef.current?.({ kind:"
     " menu === 'vorgang' && id !== 'sprechen' ? 'sprechen' : id });"
     " setMenu('closed'); }}"),
    # КЛАСС 3/11 (действующая цель в каждом состоянии): «×» не закрывает
    # ждущее меню GA-16 — зонд давит close и в GA-16.
    ('close-v-ga16-nedejstvuet', 'mobile/src/bootstrap/tab-shell.tsx',
     "onPress={() => setMenu('closed')} style={styles.ziel}",
     "onPress={() => { if (menu !== 'vorgang') setMenu('closed'); }}"
     " style={styles.ziel}"),
    # КЛАСС 9/И-3: long-press шлёт voice И открывает меню — удержание
    # обязано давать голос БЕЗ меню (отпускание раньше — касание).
    ('longpress-otkryvaet-menu', 'mobile/src/bootstrap/tab-shell.tsx',
     "onLongPress={() => onCommandRef.current?.({ kind: 'voice' })}",
     "onLongPress={() => { onCommandRef.current?.({ kind: 'voice' });"
     " setMenu('open'); }}"),
]
MUTACII_SVJAZI = [
    ('literal-touch-44', 'mobile/src/bootstrap/tab-shell.tsx',
     'profileZone: { minHeight: ziel, minWidth: ziel }',
     'profileZone: { minHeight: 44, minWidth: 44 }'),
    ('literal-press-long-500', 'mobile/src/bootstrap/tab-shell.tsx',
     "delayLongPress={Number(MOTION_TOKENS['press-long'].replace('ms', ''))}",
     'delayLongPress={500}'),
    # КЛАСС 2 (связь с токеном, Arch147w): minWidth вкладки — литерал 44
    # вместо токена ziel; независимая рамка вкладки (padding 24×12) не
    # покрывает минимум, поэтому в метаморф-прогоне зона обязана следовать
    # за токеном — литерал краснеет только при подмене 44→46px.
    ('tab-minwidth-literal', 'mobile/src/bootstrap/tab-shell.tsx',
     'minHeight: navZiel,\n    minWidth: ziel,',
     'minHeight: navZiel,\n    minWidth: 44,'),
]

# лекало 143/2 (И-8): копия frozen-шаблона — носитель зоны (пин sha256 в
# source.json, байты == тегу 3ca9d92f); агрегаты и служебные задачи DAG —
# имена frozen 143/2 (OCI-механизм продукта, PR Complior-mob#145 6240f630)
LEKALO = os.path.join(NOS, 'screen-job.template.yml')
AGREGATY = ('android-e2e', 'mobile-regression-signal')
BAZA_WF = os.path.join(NOS, 'produkt', 'mobile-6240f63.yml')
BAZA_KARTA = os.path.join(NOS, 'produkt', 'ci-screens-6240f63.json')
# канон-файлы пачки: путь в продукте -> файл зоны с теми же байтами
# (второй источник — source.json piny.kanon; сверяется до копирования)
KANON_V_ZONE = {
    'mobile/src/features/conversation/__tests__/gespraech-dvizhenie.test.ts':
        'teksty/gespraech-dvizhenie.test.ts',
    'mobile/e2e-gespraech-vhod/kontrakt.md': 'pachka/kontrakt.md',
    'mobile/e2e-gespraech-vhod/kadry.json': 'pachka/kadry.json',
    'mobile/e2e-gespraech-vhod/kadry-393.json': 'pachka/kadry-393.json',
    'mobile/e2e-gespraech-vhod/katalog_kopii.json': 'pachka/katalog_kopii.json',
    'mobile/e2e-gespraech-vhod/spec_api.json': 'pachka/spec_api.json',
    'mobile/e2e-gespraech-vhod/batareja/red_ekrana.sh':
        'pachka/batareja/red_ekrana.sh',
    'mobile/.maestro/gespraech-vhod.yaml': 'pachka/gespraech-vhod.yaml',
    'mobile/.maestro/gespraech-vhod-393.yaml': 'pachka/gespraech-vhod-393.yaml',
    'mobile/.maestro/gespraech-prokhod.yaml': 'pachka/gespraech-prokhod.yaml',
    'mobile/e2e-gespraech-vhod/dvizhenie.mjs': 'teksty/dvizhenie.mjs',
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
    k = src['kejsy']
    if set(k['a']) != set(OZHIDAEMYE_PRICHINY) | {'kontrol-forma'}:
        utechka('kejsy.a против ожидаемых причин')
    for kk, v in k['a'].items():
        if kk != 'kontrol-forma' and v.get('prichina') != \
                OZHIDAEMYE_PRICHINY.get(kk):
            utechka('prichina ' + kk)
    lek = src.get('lekalo')
    if not isinstance(lek, dict) or set(lek) != {
            'job_id', 'screen_id', 'pack', 'flows', 'child_flows', 'puti',
            'h_path', 'avd_port', 'avd_port_393', 'evidence_ns', 'shablon',
            'ekrany'}:
        utechka('source.json.lekalo — состав ключей')
    if not re.fullmatch(r'e2e-[a-z0-9-]+', lek['job_id']) or \
            not re.fullmatch(r'[a-z0-9-]+', lek['screen_id']) or \
            lek['pack'] != 'mobile/e2e-%s/' % lek['screen_id'] or \
            lek['h_path'] != '.harness147' or lek['shablon'] != 3 or \
            set(lek['ekrany']) != {'GA-15', 'GA-16'} or \
            not isinstance(lek['avd_port'], int) or \
            not isinstance(lek['avd_port_393'], int) or \
            lek['avd_port_393'] in (lek['avd_port'] - 1,
                                    lek['avd_port'] + 1):
        utechka('source.json.lekalo — грамматика значений (порты: соседний'
                ' с adb-парой 5572 непригоден — слово владельца 31.10)')
    for kljuch in ('nositeli/screen-job.template.yml',
                   'nositeli/produkt/mobile-6240f63.yml',
                   'nositeli/produkt/ci-screens-6240f63.json',
                   'stabs/stab_lekalo_bez_zapuska_393.py',
                   'stabs/stab_lekalo_parallelnyj_zapusk.py',
                   'stabs/stab_lekalo_zamaskirovannyj_otkaz.py',
                   'stabs/stab_sverka_s_ga01.py',
                   'stabs/stab_maska_36.py',
                   'stabs/stab_e2e_bez_podtverzdenija.py',
                   'stabs/stab_jest_krasnyj.sh',
                   'stabs/stab_jest_zelenyj.sh',
                   'produkt/gespraech-vhod-zond-147.test.tsx',
                   'model/produktnaja-raskladka/mobile/src/bootstrap/'
                   'tab-shell.tsx',
                   'model/produktnaja-raskladka/mobile/src/theme/'
                   'motion-tokens.ts'):
        if kljuch not in src['piny']['nositeli']:
            utechka('пин стаба отсутствует: ' + kljuch)
    for stab, svaz in (src.get('stab_vhod') or {}).items():
        if 'kletka' in svaz:
            kartochnye = dict(KLETKI_FLO_STABOV)
            kartochnye.update(KLETKI_KADRY_STABOV)
            kartochnye.update(KLETKI_E2E_STABOV)
            kartochnye.update(KLETKI_JEST_STABOV)
            ozhid = kartochnye.get(stab)
            if ozhid is not None:
                imja_fajla = 'stab_' + stab.replace('-', '_') + \
                    ('.sh' if stab in KLETKI_JEST_STABOV else '.py')
                if svaz['kletka'] != ozhid[0] or 'pravilo' in svaz or \
                        src['staby'].get(stab) != imja_fajla:
                    utechka('привязка стаба ' + stab)
            elif svaz['kletka'] == 's-lekalo-instanciirovano':
                if 'pravilo' in svaz or src['staby'].get(stab) != \
                        'stab_' + stab.replace('-', '_') + '.py':
                    utechka('привязка стаба ' + stab)
            else:
                utechka('привязка стаба ' + stab)
        elif svaz.get('pravilo') not in PRAVILA_MASHINY:
            utechka('привязка стаба ' + stab)
    for semejstvo, imja in (
            (KLETKI_FLO_STABOV, 'стабы формы флоу против клеток формы'),
            (KLETKI_KADRY_STABOV,
             'стабы кадровых инвариантов против клеток'),
            (KLETKI_E2E_STABOV,
             'стабы жизненного цикла против клеток'),
            (KLETKI_JEST_STABOV,
             'стабы jest-среды против клеток')):
        kletki = {v[0] for v in semejstvo.values()}
        objavlennye = {sv['kletka'] for sv in
                       (src.get('stab_vhod') or {}).values()
                       if 'kletka' in sv and sv['kletka'] in kletki}
        if objavlennye != kletki:
            utechka(imja)
    return src


# ожидаемое имя причины каждой красной клетки оси A (сверяется с фактом
# эталона ДО субъекта; расхождение — дефект оракула, rc 2)
OZHIDAEMYE_PRICHINY = {
    'shablon2-s-ga': 'DVIZHENIE_OTSVTSTVUET',
    'ekrany-ne-polny-ga-15': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-16': 'EKRANY_NE_POLNY',
    'ekran-vne-manifesta': 'EKRAN_VNE_MANIFESTA',
    'ekran-bez-kadrov': 'EKRAN_BEZ_KADROV',
    'perehody-ne-polny-t28': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t29': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t30': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t31': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t33': 'PEREHODY_NE_POLNY',
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
    'kadr-neodnoznachen': 'KADR_NEODNOZNACHEN',
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
    'samodelnaya-sverka': 'SAMODELNAYA_SVERKA',
    'staroj-pin-d24': 'KADR_NIZHE_POROGA',
    'razdel-otsvtstvuet': 'RAZDEL_OTSVTSTVUET',
}


# ---------- мир: мини-репо продукта + мини-харнесс ----------

def _sh(q):
    return q.replace("'", "'\\''")


def postav_mir(tmp):
    """Мир: repo (мини-продукт с пачкой-эталоном) + harness (мини-харнесс).
    Стенд-ины приёмки честны: e2e кладёт СВЕЖИЕ кадры-носители в
    Maestro-раскладку, npm-шим запускает раннер машины; живые команды
    продукта — канон teksty/ (исполняет продуктовый CI экрана)."""
    repo = os.path.join(tmp, 'repo')
    hrn = os.path.join(tmp, 'harness')
    pak = os.path.join(repo, 'mobile', 'e2e-gespraech-vhod')
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
        os.path.join(repo, 'docs', 'ux', '05_Kompakt_D24', 'frames'),
        os.path.join(repo, 'docs', 'ux', '05_Kompakt_D24', 'source'),
        os.path.join(repo, 'mobile', 'e2e-first-run'),
        os.path.join(repo, 'mobile', 'e2e-erstinformation'),
        os.path.join(repo, '.harness147', 'scripts'),
        os.path.join(repo, 'bin'),
        os.path.join(hrn, 'scripts'),
        os.path.join(hrn, 'fixtures', 'workshop_project', 'ekran_shablon_132',
                     'model', 'fiktura', 'pachta_chuzhogo'),
        os.path.join(hrn, 'fixtures', 'workshop_project', 'ekran_shablon_132',
                     'model', 'fiktura', 'pachta_tot_zhe'),
        os.path.join(repo, 'mobile', 'maestro-out-gespraech'),
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
    # старые макеты финала 2: вход мутации staroj-pin-d24 (старый пин
    # грамматикой принимается — ловец сверка 123, не грамматика)
    for prof in ('390x844', '393x852'):
        for f in ('GA-01', 'GA-01-Hell', 'GA-15', 'GA-15-Hell',
                  'GA-16', 'GA-16-Hell'):
            shutil.copy(os.path.join(NOS, 'd24', 'maket',
                                     '%s-%s.png' % (prof, f)),
                        os.path.join(d24, 'pack', 'screens', prof,
                                     f + '.png'))
    # кадры пакета D24-Kompakt-1.1 (байты == frames/SHA256SUMS) и токены
    k11 = os.path.join(repo, 'docs', 'ux', '05_Kompakt_D24')
    for ek, sost in (('GA-01', 'normal'), ('GA-15', 'menu'),
                     ('GA-16', 'menu')):
        for tema in ('dark', 'light'):
            for prof in ('390x844', '393x852'):
                imja = '%s_%s_%s_%s.png' % (ek, sost, tema, prof)
                shutil.copy(os.path.join(NOS, 'kompakt11', 'frames', imja),
                            os.path.join(k11, 'frames', imja))
    shutil.copy(os.path.join(NOS, 'kompakt11', 'tokens.json'),
                os.path.join(k11, 'source', 'tokens.json'))
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
    for f in ('gespraech-vhod.yaml', 'gespraech-vhod-393.yaml',
              'gespraech-prokhod.yaml'):
        shutil.copy(os.path.join(PACHKA, f),
                    os.path.join(repo, 'mobile', '.maestro', f))
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    shutil.copy(os.path.join(MODEL, 'menu-machine.ts'),
                os.path.join(repo, 'mobile', 'src', 'features',
                             'conversation', 'menu-machine.ts'))
    shutil.copy(os.path.join(TEKSTY, 'gespraech-dvizhenie.test.ts'),
                os.path.join(repo, 'mobile', 'src', 'features',
                             'conversation', '__tests__',
                             'gespraech-dvizhenie.test.ts'))
    shutil.copy(os.path.join(TEKSTY, 'dvizhenie.mjs'),
                os.path.join(pak, 'dvizhenie.mjs'))
    # стенд-ин e2e: свежие кадры обеих тем и обоих профилей —
    # перекодированные кадры пакета 1.1 (пиксели равны, байты отличны)
    kadr = os.path.join(NOS, 'kompakt11', 'kadry')
    telo = ['#!/usr/bin/env bash', 'set -eu',
            'out=mobile/maestro-out-gespraech', 'rm -rf "$out"',
            'mkdir -p "$out"']
    for tema, pary in (
            ('dark', ['GA-01_normal_dark_390x844 gespraech-ga-01',
                      'GA-15_menu_dark_390x844 gespraech-ga-15',
                      'GA-16_menu_dark_390x844 gespraech-ga-16',
                      'GA-01_normal_dark_393x852 gespraech-ga-01-393',
                      'GA-15_menu_dark_393x852 gespraech-ga-15-393',
                      'GA-16_menu_dark_393x852 gespraech-ga-16-393']),
            ('light', ['GA-01_normal_light_390x844 gespraech-ga-01',
                       'GA-15_menu_light_390x844 gespraech-ga-15',
                       'GA-16_menu_light_390x844 gespraech-ga-16',
                       'GA-01_normal_light_393x852 gespraech-ga-01-393',
                       'GA-15_menu_light_393x852 gespraech-ga-15-393',
                       'GA-16_menu_light_393x852 gespraech-ga-16-393'])):
        d = '"$out"/%s/run/gespraech/takeScreenshot' % tema
        telo += ['mkdir -p %s' % d]
        for para in pary:
            imja, snimok = para.split()
            telo += ['cp "%s/%s.png" %s/%s.png'
                     % (_sh(kadr), imja, d, snimok)]
    telo += ['exit 0']
    put = os.path.join(pak, 'e2e.sh')
    open(put, 'w').write('\n'.join(telo) + '\n')
    os.chmod(put, 0o755)
    # стенд-ин прохода: цель-флою существует, нажатия — продуктовый CI
    put = os.path.join(pak, 'prokhod.sh')
    open(put, 'w').write('#!/usr/bin/env bash\nset -eu\n'
                         '[ -f "${1:?cel-flou}" ] || exit 3\nexit 0\n')
    os.chmod(put, 0o755)
    # PATH-стенд-ин npm: раннер численной приёмки на машине мира
    mashina = os.path.join(repo, 'mobile', 'src', 'features',
                           'conversation', 'menu-machine.ts')
    speka = os.path.join(d24, 'motion', 'motion-spec-gespraech.json')
    put = os.path.join(repo, 'bin', 'npm')
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
    shutil.copy(RUNNER123, os.path.join(repo, '.harness147', 'scripts',
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
        pid = 'GA-' + vid.rsplit('-', 1)[1].upper()
        f['dvizhenie']['perehody'].remove(pid)
        sohrani()
    elif vid == 'perehod-lishnij':
        f['dvizhenie']['perehody'].append('GA-T16')
        sohrani()
    elif vid == 'perehod-vne-manifesta':
        f['dvizhenie']['perehody'].append('GA-T36')
        sohrani()
    elif vid == 'scena-vne-orakula':
        f['dvizhenie']['sceny_znaka'].append('GA-T28')
        sohrani()
    elif vid == 'scena-vne-perehoda':
        f['dvizhenie']['sceny_znaka'].append('GA-T20')
        sohrani()
    elif vid == 'sceny-znaka-ne-polny':
        f['dvizhenie']['sceny_znaka'].remove('GA-T29')
        sohrani()
    elif vid == 'etalon-bez-pinov':
        del f['dvizhenie']['etalony']['GA-T31']
        sohrani()
    elif vid == 'etalon-ne-hex':
        f['dvizhenie']['etalony']['GA-T28']['keyframes']['dark'][2] = 'zz'
        sohrani()
    elif vid == 'etalon-ne-polon':
        f['dvizhenie']['etalony']['GA-T28']['keyframes']['light'].pop()
        sohrani()
    elif vid == 'etalon-tema-otsvtstvuet':
        del f['dvizhenie']['etalony']['GA-T28']['keyframes']['light_reduced']
        sohrani()
    elif vid == 'video-etalon-ne-polon':
        del f['dvizhenie']['etalony']['GA-T28']['video']['dark_reduced']
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
        p = put_repo('mobile/.maestro/gespraech-vhod.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '- takeScreenshot: gespraech-ga-15\n', '')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('flow')
    elif vid == 'zony-rashodjatsja':
        p = put_pachki('kontrakt.md')
        s = open(p, encoding='utf-8').read().replace(
            ' fixtures/workshop_project/gespraech_vhod_147/', '')
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
            if x['id'] == 'gespraech-menu-sprechen':
                x['vysota'] = 40
        sohrani()
    elif vid == 'kasanie-v-safe-zone':
        for x in f['prokhodimost']['pressable']:
            if x['id'] == 'gespraech-mitte':
                x['y'] = 900
        sohrani()
    elif vid == 'kadr-neodnoznachen':
        p = put_pachki('e2e.sh')
        s = open(p, encoding='utf-8').read()
        dop = ('mkdir -p "$out"/dark/run2/gespraech/takeScreenshot\n'
               'cp "%(kadr)s/GA-15_menu_dark_390x844.png" '
               '"$out"/dark/run2/gespraech/takeScreenshot/'
               'gespraech-ga-15.png\n')
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
        p = put_repo('mobile/.maestro/gespraech-vhod-393.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '    id: tab-shell\n', '    id: shell\n')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('flow393')
    elif vid == 'marshrut-bez-snimka':
        p = put_repo('mobile/.maestro/gespraech-vhod-393.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '- takeScreenshot: gespraech-ga-15-393\n', '')
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
        f['priemka']['prokhod'] = 'bash mobile/e2e-gespraech-vhod/prokhod.sh'
        sohrani()
    elif vid == 'prokhod-bez-pressable':
        p = put_repo('mobile/.maestro/gespraech-prokhod.yaml')
        s = open(p, encoding='utf-8').read().replace(
            '    id: gespraech-menu-foto\n', '    id: drugaja-cel\n')
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
                'printf \'{"numTotalTests":7,"numPassedTests":7}\' > '
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
                'printf \'{"numTotalTests":7,"numPassedTests":6}\\n\' > '
                '"$cel"\nexit 0\n'}[vid].replace('REPO', repo)
        p = os.path.join(repo, 'bin', 'npm')
        open(p, 'w').write(telo)
        os.chmod(p, 0o755)
        if vid == 'otchet-ustarevshij':
            otp = os.path.join(repo, 'mobile', 'e2e-gespraech-vhod',
                               'jest-otchet.json')
            open(otp, 'w').write('{"numTotalTests":7,"numPassedTests":7}')
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
        kd = os.path.join(repo, 'mobile', 'maestro-out-gespraech', 'dark',
                          'run', 'gespraech', 'takeScreenshot')
        os.makedirs(kd, exist_ok=True)
        shutil.copy(os.path.join(NOS, 'kompakt11', 'kadry',
                                 'GA-01_normal_dark_390x844.png'),
                    os.path.join(kd, 'gespraech-ga-01.png'))
        tronutye.append('e2e')
    elif vid == 'samodelnaya-sverka':
        f['priemka']['sverka'] = ('python3 .harness147/scripts/'
                                  'sverka_maketa.py --kadry '
                                  'mobile/maestro-out-gespraech --repo .')
        sohrani()
    elif vid == 'razdel-otsvtstvuet':
        p = put_pachki('kontrakt.md')
        s = open(p, encoding='utf-8').read().replace(
            '## ПРОВОДКА\n', '## ИНОЙ РАЗДЕЛ\n')
        open(p, 'w', encoding='utf-8').write(s)
        tronutye.append('kontrakt')
    elif vid == 'staroj-pin-d24':
        # старый пин D 2.4 Final 2 (слово владельца 2026-11-02: пакет
        # 1.1 ЗАМЕНЯЕТ 1.0/финал 2 как источник кадров): кадр GA-15 dark
        # объявляется против старого макета финала 2 — путь и пин
        # грамматикой принимаются (старый пин остаётся принимаемым),
        # ловец — замороженная сверка 123: кадр 1.1 против макета
        # финала 2 ниже порога (замер этой пачки: 0.441 < 0.600)
        p = put_pachki('kadry.json')
        m = json.load(open(p, encoding='utf-8'))
        for k in m['kadry']:
            if k['id'] == 'GA-15 dark':
                k['maket'] = ('docs/ux/04_Gespraech_D24/pack/screens/'
                              '390x844/GA-15.png')
                k['maket_sha256'] = sha(os.path.join(
                    NOS, 'd24', 'maket', '390x844-GA-15.png'))
        json.dump(m, open(p, 'w', encoding='utf-8'), ensure_ascii=False,
                  indent=1)
        tronutye.append('kadry')
    else:
        raise SystemExit('нет мутации для клетки ' + vid)
    return tronutye


# ---------- ось D: правила данных над пиннованными источниками ----------

def pravila_dannyh():
    spec = json.load(open(os.path.join(NOS, 'd24', 'spec.json'),
                          encoding='utf-8'))
    T = {}
    for t in spec['tokens']:
        m = re.match(r'^([0-9.]+)ms$', t['value'])
        T[t['name']] = float(m.group(1)) if m else None
    S = {s['id']: s for s in spec['scenes']}

    def pilli(sid):
        return sorted([t for t in S[sid]['tracks']
                       if 'li:nth-child' in t['element']
                       and t['property'] == 'opacity'],
                      key=lambda t: t['delay']['ms'])

    def d_menja_300():
        koncy = [t['delay']['ms'] + t['duration']['ms']
                 for t in pilli('GA-T28')]
        assert koncy and max(koncy) <= 300, koncy
        return koncy

    def d_sprechen():
        z = [t['delay']['ms'] for t in pilli('GA-T28')]
        assert len(z) == 4 and z == sorted(z), z
        return z

    def d_press_long():
        t1 = S['GA-T35']['tracks'][0]
        assert t1['duration']['token'] == 'press-long', t1
        assert t1['curve']['token'] == 'linear', t1
        assert t1['to'] == 1.06, t1
        sob = S['GA-T35']['events'][0]
        assert sob['at']['ms'] == T['press-long'], sob
        assert sob['set'] and sob['set'].get('state') == 'listening', sob
        return t1['duration']['ms']

    def d_ud():
        # видимые свойства — {opacity, bg} (единый источник: эталон 146
        # SVOJSTVA_VIZUALNYE); перемещение/размер/морф — 0
        for pid in PEREHODY:
            for t in S[pid]['tracks']:
                vidimo = t['property'] in ('opacity', 'bg')
                if vidimo:
                    assert t['reduced_duration_ms'] <= T['motion-fast'], \
                        (pid, t['element'], t['property'])
                else:
                    assert t['reduced_duration_ms'] == 0, (pid,
                                                           t['element'])
        return len(PEREHODY)

    return {'d-menja-300': d_menja_300,
            'd-sprechen-pervym': d_sprechen,
            'd-press-long-500': d_press_long,
            'd-ud-dvizhenija': d_ud}


def zapusk_pravila_mashiny(mashina, pravilo=None):
    argv = ['node', os.path.join(MODEL, 'dvizhenie-runner.mjs'),
            '--machine', mashina, '--spec',
            os.path.join(NOS, 'd24', 'spec.json')]
    if pravilo:
        argv += ['--pravilo', pravilo]
    r = subprocess.run(argv, capture_output=True, text=True, timeout=120)
    return r.returncode, (r.stdout + r.stderr).strip()

# ---------- форма флоу: исполнимость в Maestro 2.11.0 (факт Impl147e) ----------


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
    """(команда, id) шага tapOn/assertVisible — картой {id: …} или
    строкой; иначе (None, None)."""
    if not isinstance(shag, dict):
        return None, None
    for komanda in ('tapOn', 'assertVisible'):
        v = shag.get(komanda)
        if isinstance(v, str):
            return komanda, v
        if isinstance(v, dict) and isinstance(v.get('id'), str):
            return komanda, v['id']
    return None, None


def sudi_flo_forma(koren, repo_r=None):
    """Форма флоу пачки, исполнимая в Maestro 2.11.0 (замер Impl147e
    31.10: 4/4 Passed + проходимость). SNIMOK_KARTOJ — каждый снимок
    СТРОКОВОЙ формой «takeScreenshot: имя» (карта {name: …} даёт
    «Config Field Required: path» — все три флоу прежней пачки не
    исполнялись); PROFIL_BEZ_VOZVRATA — после наблюдения профиля
    возврат shell-back ДО первого переключения вкладки (проба 999
    PROFILE_SECONDARY_NOT_TAB: вкладок в профиле нет, нажатие
    shell-tab-start из профиля недостижимо). Субъект — флоу пачки зоны
    (байты запинены vedro); в --repo той же мерой канон-копии
    mobile/.maestro продукта. Возврат: клетка -> список причин."""
    vhody = [(imja, os.path.join(koren, 'pachka', imja))
             for imja in FLOVY_PACHKI]
    if repo_r:
        vhody += [('repo/' + imja,
                   os.path.join(repo_r, 'mobile', '.maestro', imja))
                  for imja in FLOVY_PACHKI]
    itogi = {'s-snimok-strokoj': [], 's-profil-vozvrat': []}
    for imja, put in vhody:
        try:
            shagi = shagi_flo(put)
        except (OSError, ValueError, yaml.YAMLError) as e:
            itogi['s-snimok-strokoj'].append(
                'SNIMOK_KARTOJ: %s не читается: %s' % (imja, e))
            continue
        for i, shag in enumerate(shagi):
            if isinstance(shag, dict) and 'takeScreenshot' in shag:
                znach = shag['takeScreenshot']
                if not isinstance(znach, str) or not znach.strip():
                    itogi['s-snimok-strokoj'].append(
                        'SNIMOK_KARTOJ: %s шаг %d — снимок картой, '
                        'а не строкой' % (imja, i + 1))
        if imja.endswith('gespraech-prokhod.yaml'):
            v_profile = False
            for shag in shagi:
                komanda, ident = _id_shaga(shag)
                if not v_profile:
                    if komanda == 'assertVisible' and ident == 'profil':
                        v_profile = True
                    continue
                if komanda == 'tapOn' and ident == 'shell-back':
                    break  # возврат из профиля есть
                if komanda == 'tapOn' and \
                        (ident or '').startswith('shell-tab-'):
                    itogi['s-profil-vozvrat'].append(
                        'PROFIL_BEZ_VOZVRATA: %s — вкладка %s после '
                        'профиля без shell-back (проба 999: вкладок в '
                        'профиле нет)' % (imja, ident))
                    break
    return itogi


def sudi_kadry_forma(koren, repo_r=None):
    """Кадровые инварианты сверки (цикл 2, слово владельца 31.10, вердикт
    Crit147 v2a блоки 1/3): (1) кадр GA-01 исключён из ПИКСЕЛЬНОЙ сверки
    147 — ни на одном профиле/теме (новый Start D 2.4 — отдельный
    предмет; переходы/доступность входа не тронуты: ∩-правило T28/T31
    живо, снимок GA-01 флоу остаётся); запись GA-01 в манифесте кадров —
    требование совпадения со Start-макетом — GA01_V_SVERKE;
    (2) маска системной шапки профиля 393 = принятые 48 pt (пилюля
    пакета 1.1 x133-258, y11-47 — замер Arch148p «Маска 48 подтверждена
    фактом пакета»: 36 оставляли 12 pt чужого хрома в судимой зоне;
    больше 48 резало бы собственные пиксели приложения) — MASKA_393_NE_48.
    Субъект — манифесты пачки зоны pachka/kadry*.json (байты запинены
    vedro), в --repo той же мерой манифесты продукта."""
    vhody = [('pachka/kadry.json', os.path.join(koren, 'pachka',
                                                'kadry.json')),
             ('pachka/kadry-393.json', os.path.join(koren, 'pachka',
                                                    'kadry-393.json'))]
    if repo_r:
        vhody += [('repo/kadry.json',
                   os.path.join(repo_r, 'mobile', 'e2e-gespraech-vhod',
                                'kadry.json')),
                  ('repo/kadry-393.json',
                   os.path.join(repo_r, 'mobile', 'e2e-gespraech-vhod',
                                'kadry-393.json'))]
    itogi = {'s-ga01-vne-sverki': [], 's-maska-393-48': []}
    for imja, put in vhody:
        m, osh = _chita_json(put)
        if m is None:
            itogi['s-ga01-vne-sverki'].append(
                'GA01_V_SVERKE: %s не читается: %s — состав сверки не '
                'судим' % (imja, osh))
            continue
        for k in m.get('kadry') or []:
            if str(k.get('id', '')).startswith('GA-01'):
                itogi['s-ga01-vne-sverki'].append(
                    'GA01_V_SVERKE: %s несёт кадр %r пиксельной сверкой '
                    '(слово владельца 31.10: GA-01 исключён — Start '
                    'D 2.4 отдельным предметом)' % (imja, k.get('id')))
        if '393' in imja:
            verh = (m.get('mera') or {}).get('chrome_verh_pt')
            if verh != 48:
                itogi['s-maska-393-48'].append(
                    'MASKA_393_NE_48: %s chrome_verh_pt=%r (принятая '
                    'маска шапки 393 — 48 pt, слово владельца 31.10; '
                    'пилюля пакета 1.1 y11-47)' % (imja, verh))
    return itogi


def _zerkal_zony(vrem, src):
    """Зеркальная копия зоны (для --oracle-tamper и стабов формы):
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


# ---------- цикл 2 (Crit147k2b): суд ИСПОЛНЕНИЕМ — жизненный цикл пары
# и реальный потребитель (зонд jest; прецеденты 148/149) -------------


# Двойники несут состояние живых серийников и журнал событий; ставятся в
# PATH и ANDROID_HOME: обе формы запуска e2e.sh идут в песочницу, не к
# настоящему Android SDK. Журнал — наблюдение, НЕ оракул ожиданий:
# порты и начальное состояние (живой эмулятор работника лекала)
# остаются у судьи в памяти (правило 8). Режим «залипшего» 390:
# emu kill возвращает rc 0, но серийник ОСТАЁТСЯ в adb devices —
# дословный обход критика (зависшая/медленная остановка).
DVOJNIK_147 = r'''#!/usr/bin/env python3
import os
import pathlib
import sys
import time

state = pathlib.Path(os.environ["GESpraech147_SOSTOJANIE"])
log = pathlib.Path(os.environ["GESpraech147_ZHURNAL"])
zalipshij = os.environ.get("GESpraech147_ZALIPSHIJ") == "1"
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
        if not zalipshij:
            state.write_text(
                "".join(s + "\n" for s in read_state() if s != serial),
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
    port = args[args.index("-port") + 1] \
        if "-port" in args and args.index("-port") + 1 < len(args) else ""
    event("START " + port)
    with state.open("a", encoding="utf-8") as output:
        output.write("emulator-" + port + "\n")
'''


def _ispolni_e2e_v_pesochice(put_e2e, LE, zalipshij):
    """Один запуск e2e.sh в песочнице двойников SDK. Возврат:
    (rc, stdout+stderr, строки журнала)."""
    with tempfile.TemporaryDirectory(prefix='gespraech147-e2e-') as d:
        cwd = os.path.join(d, 'zapusk')
        os.makedirs(os.path.join(cwd, 'mobile', '.maestro'))
        shutil.copyfile(put_e2e, os.path.join(cwd, 'e2e.sh'))
        os.chmod(os.path.join(cwd, 'e2e.sh'), 0o755)
        # e2e.sh судит наличие своих флоу (rc 3) — песочница несёт их из
        # пачки зоны: двойник maestro не читает их, но честный вход
        # обязан существовать (как в дереве продукта)
        for potok in LE['flows']:
            shutil.copyfile(os.path.join(PACHKA, os.path.basename(potok)),
                            os.path.join(cwd, potok))
        bin_dir = os.path.join(d, 'bin')
        sdk_bin = os.path.join(d, 'android', 'emulator')
        os.makedirs(bin_dir)
        os.makedirs(sdk_bin)
        for imja in ('adb', 'emulator', 'maestro', 'sleep'):
            dvojnik = os.path.join(bin_dir, imja)
            with open(dvojnik, 'w', encoding='utf-8') as fh:
                fh.write(DVOJNIK_147)
            os.chmod(dvojnik, 0o755)
        os.symlink(os.path.join(bin_dir, 'emulator'),
                   os.path.join(sdk_bin, 'emulator'))
        sostojanie = os.path.join(d, 'state')
        zhurnal = os.path.join(d, 'events')
        with open(sostojanie, 'w', encoding='utf-8') as fh:
            fh.write('emulator-%d\n' % LE['avd_port'])
        open(zhurnal, 'w').close()
        apk = os.path.join(d, 'proba.apk')
        open(apk, 'wb').close()
        env = dict(os.environ)
        env['PATH'] = os.pathsep.join([bin_dir, env.get('PATH', '')])
        env['ANDROID_HOME'] = os.path.join(d, 'android')
        env['GESPRAECH_SERIAL'] = 'emulator-%d' % LE['avd_port']
        env['GESPRAECH_SERIAL_393'] = 'emulator-%d' % LE['avd_port_393']
        env['GESPRAECH_AVD393'] = 'proba393'
        env['GESPRAECH_PORT393'] = str(LE['avd_port_393'])
        env['GESPRAECH_APK'] = apk
        env['GESpraech147_SOSTOJANIE'] = sostojanie
        env['GESpraech147_ZHURNAL'] = zhurnal
        env['GESpraech147_ZALIPSHIJ'] = '1' if zalipshij else ''
        protsess = subprocess.Popen(
            ['bash', os.path.join(cwd, 'e2e.sh'), LE['screen_id']],
            cwd=cwd, env=env, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, start_new_session=True)
        try:
            vyvod, _ = protsess.communicate(timeout=60)
            status = protsess.returncode
        except subprocess.TimeoutExpired:
            try:
                os.killpg(protsess.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            vyvod, _ = protsess.communicate()
            status = 'ТАЙМАУТ (60 с)'
        stroki = open(zhurnal, encoding='utf-8').read().splitlines()
        return status, (vyvod or b'').decode('utf-8', 'replace'), stroki


def sud_zhizncikla_ispolneniem(put_e2e, src):
    """s-e2e-ostanovka-podtverzhena (цикл 2, вердикт Crit147k2b класс
    ПОРЯДОК AVD): 393 запускается только после ПОДТВЕРЖДЁННОГО ухода
    390; исчерпание ожидания — ненулевой rc с различимой причиной.
    Исполняет e2e.sh БЕЗ настоящего SDK на ДВУХ входах: (а) честный —
    emu kill убирает серийник из adb devices: контроль обязан пройти
    (rc 0, единственный START портом avd_port_393 ПОСЛЕ KILL); (б)
    «залипший» 390 — emu kill с rc 0, серийник остаётся в списке:
    запуск 393 запрещён (ЛЮБОЙ START — два живых AVD), отказ обязателен
    и различим. Имя причины — РОВНО одно, по старшинству:
    E2E_ZAPUSK_PRI_ZHIVOM_390 → E2E_ZALIPSHIJ_390_RC0 →
    E2E_ZALIPSHIJ_390_BEZ_PRICHINY → E2E_NET_ZAPUSKA_393 →
    E2E_KONTROL_RC. Пустой возврат — зелено."""
    LE = src['lekalo']
    if not os.path.isfile(put_e2e):
        return ['E2E_NET_KANONA: нет %s — жизненный цикл пары не судим'
                % put_e2e]
    serial390 = 'emulator-%d' % LE['avd_port']
    port393 = str(LE['avd_port_393'])
    rc_b, vyvod_b, zh_b = _ispolni_e2e_v_pesochice(put_e2e, LE, True)
    for stroka in zh_b:
        if stroka.startswith('START '):
            return ['E2E_ZAPUSK_PRI_ZHIVOM_390: залипший %s — запущен 393 '
                    '(порт %s) при живом первом; журнал: %s'
                    % (serial390, stroka[6:], '; '.join(zh_b))]
    if rc_b == 0:
        return ['E2E_ZALIPSHIJ_390_RC0: %s остался в adb devices после '
                'emu kill, скрипт завершился rc 0 без отказа — два '
                'живых AVD возможны' % serial390]
    if 'не ушёл' not in vyvod_b or serial390 not in vyvod_b:
        return ['E2E_ZALIPSHIJ_390_BEZ_PRICHINY: rc %s без различимой '
                'причины (нужны имя зависшего серийника и «не ушёл»); '
                'выход: %s' % (rc_b, vyvod_b.strip()[:120])]
    rc_a, vyvod_a, zh_a = _ispolni_e2e_v_pesochice(put_e2e, LE, False)
    zhiv390, startov = True, 0
    for stroka in zh_a:
        if stroka == 'KILL ' + serial390:
            zhiv390 = False
        elif stroka.startswith('START '):
            startov += 1
            if zhiv390:
                return ['E2E_ZAPUSK_PRI_ZHIVOM_390: честный вход — START '
                        '%s до emu kill %s' % (stroka[6:], serial390)]
            if stroka[6:] != port393:
                return ['E2E_NET_ZAPUSKA_393: START портом %s, требуется '
                        '%s' % (stroka[6:], port393)]
    if startov == 0:
        return ['E2E_NET_ZAPUSKA_393: честный вход — нет START в журнале '
                '(запуск 393 отсутствует или обошёл PATH/ANDROID_HOME)']
    if rc_a != 0:
        return ['E2E_KONTROL_RC: честный вход rc=%s (выход: %s)'
                % (rc_a, vyvod_a.strip()[:120])]
    return []


def ispolnimyj_sud(mob_koren, src, podrobno=True):
    """s-ekran-ispolnim (цикл 2, вердикты Crit147k2b + Crit147k2c класс
    РЕАЛЬНЫЙ ПОТРЕБИТЕЛЬ): живой jest-зонд
    produkt/gespraech-vhod-zond-147.test.tsx (пин source.json) на
    РЕАЛЬНЫХ компонентах дерева — таб-шелл mobile/src/bootstrap/
    tab-shell.tsx (зоны касания всех целей карты pressable ПАЧКИ на
    ИНТЕРКТИВНОМ узле — ближайший сам-или-предок, принимающий жест,
    в т.ч. когда testID на его ребёнке: Crit147k2c Б1 — ≥
    touch-target.min пакета 1.1 на обоих профилях) и theme/
    motion-tokens.ts (press-long == токену пакета 1.1; фактический
    порог UI измеряется на фейк-часах с допуском 1 мс такта: сдвиг
    «токен + 50» красен, Crit147k2c Б2) — в изолированной копии mobile
    (node_modules — симлинк установки дерева), плюс матрица мутантов
    по якорям и регулярному выражению (дословные атаки Crit147k2b:
    Pressable 20×20, press-long 900; Crit147k2c: testID на дочернем
    Text при Pressable 20×20, добавка «50 +» к любому выражению
    delayLongPress — синтаксически независимо): контроль зелен, каждый
    мутант убит УПАВШИМ АССЕРТОМ (падение загрузки сьюта НЕ
    засчитывается); подмена кандидата референсом при несовпадении
    синтаксиса — ТОЛЬКО с явным извещением в stderr. Заявленная
    среда без установки — LIVE_PREDPOSYLKA, НИКОГДА skip→pass
    (прецедент proba_live_put 145); дерево без mobile/package.json —
    именованный пропуск. Возвращает (prichiny, otkaz)."""
    mob = mob_koren
    if not os.path.isfile(os.path.join(mob, 'package.json')):
        print('ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда',
              file=sys.stderr)
        return [], 'skip'
    if not os.path.isfile(ZOND) or sha(ZOND) != \
            src['piny']['sha'].get('produkt/%s' % ZOND_IMJA):
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
    for otn in RASKLADKA_V_PRODUKTE:
        if not os.path.isfile(os.path.join(mob_koren, '..', otn)):
            predposylki.append('нет компонента %s' % otn)
    if not os.path.isfile(os.path.join(mob_koren, '..',
                                       TOKENY_PAKETA_OTN)):
        predposylki.append('нет пакета 1.1 %s' % TOKENY_PAKETA_OTN)
    if not os.path.isfile(os.path.join(mob, 'e2e-gespraech-vhod',
                                       'ekran.json')):
        predposylki.append('нет ekran.json пачки (карта pressable зонда)')
    if predposylki:
        return ['LIVE_PREDPOSYLKA: %s' % '; '.join(predposylki)], None
    vrem = tempfile.mkdtemp(prefix='gespraech147-live-')
    try:
        kopija = os.path.join(vrem, 'mobile')
        shutil.copytree(mob, kopija,
                        ignore=shutil.ignore_patterns('node_modules'))
        os.symlink(os.path.realpath(nm), os.path.join(kopija,
                                                      'node_modules'))
        # пакет 1.1 рядом с копией mobile (зонд читает токены пакета по
        # относительному пути <корень>/docs/…)
        tok_kuda = os.path.join(vrem, TOKENY_PAKETA_OTN)
        os.makedirs(os.path.dirname(tok_kuda), exist_ok=True)
        shutil.copyfile(os.path.join(mob_koren, '..', TOKENY_PAKETA_OTN),
                        tok_kuda)
        zond = os.path.join(kopija, os.path.relpath(ZOND_KUDA, 'mobile'),
                            ZOND_IMJA)
        os.makedirs(os.path.dirname(zond), exist_ok=True)
        shutil.copy(ZOND, zond)

        def zapustit(metamorf=False):
            env = dict(os.environ)
            env.pop('GESPRAECH147_METAMORF', None)
            if metamorf:
                env['GESPRAECH147_METAMORF'] = '1'
            try:
                p = subprocess.run(
                    [os.path.join(kopija, 'node_modules', '.bin', 'jest'),
                     '--config', konfig, '--rootDir', '.', '--ci',
                     '--runInBand', '--json', 'gespraech-vhod-zond'],
                    cwd=kopija, capture_output=True, text=True,
                    timeout=1200, env=env)
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
        for _imja, otn, _jakor, _zamena in (MUTACII_ISPOLNIMYE +
                                             MUTACII_SVJAZI):
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
                    'компонентах дерева (упавших ассертов %d) — реальная '
                    'зона касания/токен не соответствуют пачке'
                    % assery], None
        for imja, otn, jakor, zamena in MUTACII_ISPOLNIMYE:
            put = os.path.join(kopija, os.path.relpath(otn, 'mobile'))
            original = ishodnye[otn]
            tekst = original
            if tekst.count(jakor) != 1:
                # Матрица мутантов проверяет чувствительность судьи на
                # референсе, не навязывает якорь исходника implementer.
                # Crit147k2c Б2: подмена НЕ молча — явное извещение в
                # stderr, свойство на кандидате закрывает контроль зонда.
                print('ISPOLNIMYJ mutant %s: якорь отсутствует в '
                      'кандидате — мутант применён к референс-раскладке '
                      '(кандидат судится контролем зонда)' % imja,
                      file=sys.stderr)
                tekst = open(os.path.join(RASKLADKA, otn),
                             encoding='utf-8').read()
                if tekst.count(jakor) != 1:
                    return ['ISPOLNIMYJ_MUTANT_NE_PRIMENIM: %s — референс'
                            ' без якоря' % imja], None
                with open(put, 'w', encoding='utf-8') as fh:
                    fh.write(tekst)
                svod_ref, err_ref = zapustit()
                if svod_ref is None or not svod_ref.get('success'):
                    return ['ISPOLNIMYJ_REFERENS_KRASEN: %s %s'
                            % (imja, err_ref)], None
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(tekst.replace(jakor, zamena, 1))
            svod, oshibka = zapustit()
            if svod is None:
                return ['ISPOLNIMYJ_INFRA: мутант %s: %s'
                        % (imja, oshibka)], None
            assery, sjuity = klassifikirovat(svod)
            if assery > 0:
                if podrobno:
                    print('ISPOLNIMYJ mutant %s UBIT — упавших ассертов %d'
                          % (imja, assery), file=sys.stderr)
            elif sjuity > 0:
                return ['ISPOLNIMYJ_MUTANT_NE_UBIT: %s — сьют не '
                        'исполнился (падение загрузки не убийство)'
                        % imja], None
            else:
                return ['ISPOLNIMYJ_MUTANT_ZHIV: %s прошёл зонд зелёным — '
                        'реальная зона касания/токен не судятся'
                        % imja], None
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(original)
        # Синтаксически независимые мутанты (Crit147k2c Б2): регулярное
        # выражение вместо дословного якоря — применяется к САМОМУ
        # кандидату при любой форме записи; референс — только с явным
        # извещением (свойство на кандидате закрывает контроль зонда).
        for imja, otn, obrazec, zamena in MUTACII_REGULJARNYE:
            put = os.path.join(kopija, os.path.relpath(otn, 'mobile'))
            original = ishodnye[otn]
            tekst = original
            novyj, najdeno = re.subn(obrazec, zamena, tekst, count=1)
            if najdeno != 1:
                print('ISPOLNIMYJ mutant %s: якорь отсутствует в '
                      'кандидате — мутант применён к референс-раскладке '
                      '(кандидат судится контролем зонда)' % imja,
                      file=sys.stderr)
                tekst = open(os.path.join(RASKLADKA, otn),
                             encoding='utf-8').read()
                novyj, najdeno = re.subn(obrazec, zamena, tekst, count=1)
                if najdeno != 1:
                    return ['ISPOLNIMYJ_MUTANT_NE_PRIMENIM: %s — референс'
                            ' без якоря' % imja], None
                with open(put, 'w', encoding='utf-8') as fh:
                    fh.write(tekst)
                svod_ref, err_ref = zapustit()
                if svod_ref is None or not svod_ref.get('success'):
                    return ['ISPOLNIMYJ_REFERENS_KRASEN: %s %s'
                            % (imja, err_ref)], None
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(novyj)
            svod, oshibka = zapustit()
            if svod is None:
                return ['ISPOLNIMYJ_INFRA: мутант %s: %s'
                        % (imja, oshibka)], None
            assery, sjuity = klassifikirovat(svod)
            if assery > 0:
                if podrobno:
                    print('ISPOLNIMYJ mutant %s UBIT — упавших ассертов %d'
                          % (imja, assery), file=sys.stderr)
            elif sjuity > 0:
                return ['ISPOLNIMYJ_MUTANT_NE_UBIT: %s — сьют не '
                        'исполнился (падение загрузки не убийство)'
                        % imja], None
            else:
                return ['ISPOLNIMYJ_MUTANT_ZHIV: %s прошёл зонд зелёным — '
                        'фактический порог UI не судится' % imja], None
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(original)
        # Подмена значений ТОЛЬКО в одноразовой копии после проверки
        # пиннованного канона. Честный компонент следует за обоими токенами;
        # совпадающий литерал при исходных 44/500 обязан разойтись.
        token_put = os.path.join(vrem, TOKENY_PAKETA_OTN)
        with open(token_put, encoding='utf-8') as fh:
            token = json.load(fh)
        if (token['touch-target']['min']['$value'] != '44px' or
                token['motion']['press-long']['$value'] != '500ms'):
            return ['ISPOLNIMYJ_TOKEN_OSNOVA: ожидали 44px/500ms'], None
        token['touch-target']['min']['$value'] = '46px'
        token['motion']['press-long']['$value'] = '700ms'
        with open(token_put, 'w', encoding='utf-8') as fh:
            json.dump(token, fh)
        motion_put = os.path.join(kopija, 'src', 'theme', 'motion-tokens.ts')
        motion = ishodnye['mobile/src/theme/motion-tokens.ts']
        if motion.count("'press-long': '500ms',") != 1:
            return ['ISPOLNIMYJ_TOKEN_NE_PRIMENIM: press-long 500ms'], None
        with open(motion_put, 'w', encoding='utf-8') as fh:
            fh.write(motion.replace("'press-long': '500ms',",
                                    "'press-long': '700ms',", 1))
        svod, oshibka = zapustit(metamorf=True)
        if svod is None:
            return ['ISPOLNIMYJ_INFRA: token-podmena: %s' % oshibka], None
        assery, _sjuity = klassifikirovat(svod)
        if not svod.get('success') or assery:
            return ['ISPOLNIMYJ_TOKEN_NE_POTREBLJON: контроль 44→46px/'
                    '500→700ms красен (%d ассертов)' % assery], None
        if podrobno:
            print('ISPOLNIMYJ token-podmena ZELEN — 44→46px/500→700ms',
                  file=sys.stderr)
        for imja, otn, jakor, zamena in MUTACII_SVJAZI:
            original = ishodnye[otn]
            tekst = original
            if tekst.count(jakor) != 1:
                # Литерал мутируем на референсе судьи, не требуя синтаксиса
                # референса от валидного компонента продукта. Crit147k2c
                # Б2: подмена НЕ молча — явное извещение в stderr.
                print('ISPOLNIMYJ mutant %s: якорь отсутствует в '
                      'кандидате — мутант применён к референс-раскладке '
                      '(кандидат судится контролем зонда)' % imja,
                      file=sys.stderr)
                tekst = open(os.path.join(RASKLADKA, otn),
                             encoding='utf-8').read()
                if tekst.count(jakor) != 1:
                    return ['ISPOLNIMYJ_MUTANT_NE_PRIMENIM: %s — референс'
                            ' без якоря' % imja], None
                with open(put, 'w', encoding='utf-8') as fh:
                    fh.write(tekst)
                svod_ref, err_ref = zapustit(metamorf=True)
                if svod_ref is None or not svod_ref.get('success'):
                    return ['ISPOLNIMYJ_REFERENS_KRASEN: %s %s'
                            % (imja, err_ref)], None
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(tekst.replace(jakor, zamena, 1))
            svod, oshibka = zapustit(metamorf=True)
            if svod is None:
                return ['ISPOLNIMYJ_INFRA: mutant %s: %s'
                        % (imja, oshibka)], None
            assery, sjuity = klassifikirovat(svod)
            if assery <= 0:
                return ['ISPOLNIMYJ_MUTANT_ZHIV: %s (%d сьютов не '
                        'исполнилось)' % (imja, sjuity)], None
            if podrobno:
                print('ISPOLNIMYJ mutant %s UBIT — упавших ассертов %d'
                      % (imja, assery), file=sys.stderr)
            with open(put, 'w', encoding='utf-8') as fh:
                fh.write(original)
        return [], None
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


def postav_fejk_jest(vrem, jest_skript):
    """Фиктивная jest-среда стабов jest-* (прецедент 148/149): заявленная
    package.json среда + метаданные пакетов + node_modules/.bin/jest с
    зашитым итогом + компоненты референс-раскладки по каноническим
    путям — исполняемый путь клетки s-ekran-ispolnim доходит до запуска
    jest и классифицирует исходы ИМЕННО, без RN-рантайма. Возвращает
    корень mobile фиктивной среды."""
    koren = os.path.join(vrem, 'fejk')
    mob = os.path.join(koren, 'mobile')
    for otn in RASKLADKA_V_PRODUKTE:
        dst = os.path.join(koren, otn)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(os.path.join(RASKLADKA, otn), dst)
    pak = os.path.join(mob, 'e2e-gespraech-vhod')
    os.makedirs(pak, exist_ok=True)
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    tok = os.path.join(koren, TOKENY_PAKETA_OTN)
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

# ---------- лекало 143/2: инстанциация И-8 (блок Crit147 круг 1) ----------


def lekalo_zameny(src, h_ref=None):
    """Параметры инстанциации И-8; единый источник — source.json.lekalo.
    H_REF — ПРИНЯТЫЙ пин харнесса в PR интеграции: здесь форма 40-hex
    (значение судит ревью интеграции, клетка — только литеральный пин,
    не плавающую ссылку)."""
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


def rassiri_vtoroj_avd(job, src):
    """Второй AVD профиля 393 — ПОСЛЕДОВАТЕЛЬНО (слово владельца
    2026-10-31; вердикт Crit147 v2a блок 2): экранный шаг СОЗДАЁТ AVD393
    и настраивает его на профиль 393×852@3x (1179×2556 @ 480dpi) рядом
    с созданием основного (запуск без создания мёрт — замер 30.10),
    расширяет cleanup обоими эмуляторами и передаёт пачке ОКРУЖЕНИЕ ПАРЫ
    (GESPRAECH_SERIAL/GESPRAECH_SERIAL_393/GESPRAECH_AVD393/
    GESPRAECH_PORT393/GESPRAECH_APK) ДО приёмки; ОСТАНОВКУ первого и
    ЗАПУСК второго делает e2e.sh пачки ПОСЛЕ кадров 390 (приёмка обоих
    профилей одной командой валидатора) — одновременно двух живых
    эмуляторов шаг не держит (Astra mob-ci-razdelenie п.342). Порт 393 —
    не соседняя adb-пара первого (5572 занята парой 5572/5573 —
    доказательство 31.10). Обязательства лекала сохранены: PORT 5572,
    один «ПОВТОР: », валидатор из .harness147, оба корневых флоу в
    FLOWS_PACHKI. Форма расширения — рецепт пачки, детали реализации —
    реализация implementer."""
    LE = src['lekalo']
    shag = next(s for s in job['steps']
                if str(s.get('name', '')).startswith('Экранная пачка'))
    r = shag['run']
    r = _zameni_schet(r, 'SERIAL="emulator-${PORT}"\n',
                      'SERIAL="emulator-${PORT}"\n'
                      'SERIAL393="emulator-%d"\n' % LE['avd_port_393'])
    r = _zameni_schet(
        r, 'trap cleanup EXIT\n',
        'trap cleanup EXIT\n'
        'AVD393="ci%s-393-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"\n'
        'PORT393=%d\n' % (LE['screen_id'], LE['avd_port_393']))
    r = _zameni_schet(
        r, 'sed -i \'s/^hw.ramSize=.*/hw.ramSize=2048/\' '
        '"$ANDROID_AVD_HOME/$AVD.avd/config.ini"\n',
        'sed -i \'s/^hw.ramSize=.*/hw.ramSize=2048/\' '
        '"$ANDROID_AVD_HOME/$AVD.avd/config.ini"\n'
        'echo no | "$AVDM" create avd --force -n "$AVD393" \\\n'
        '  -k "system-images;android-36;google_apis;x86_64" '
        '-d pixel_7 >/dev/null\n'
        'sed -i -e \'s/^hw.ramSize=.*/hw.ramSize=2048/\' \\\n'
        '  -e \'s/^hw.lcd.density=.*/hw.lcd.density=480/\' \\\n'
        '  -e \'s/^hw.lcd.width=.*/hw.lcd.width=1179/\' \\\n'
        '  -e \'s/^hw.lcd.height=.*/hw.lcd.height=2556/\' \\\n'
        '  "$ANDROID_AVD_HOME/$AVD393.avd/config.ini"\n')
    r = _zameni_schet(
        r, '"$AVDM" delete avd -n "$AVD" >/dev/null 2>&1 || true\n',
        '"$AVDM" delete avd -n "$AVD" >/dev/null 2>&1 || true\n'
        'adb -s "$SERIAL393" emu kill >/dev/null 2>&1 || true\n'
        'sleep 3\n'
        'pkill -f "qemu-system-x86_64.*-avd $AVD393" '
        '>/dev/null 2>&1 || true\n'
        '"$AVDM" delete avd -n "$AVD393" >/dev/null 2>&1 || true\n')
    r = _zameni_schet(
        r, '\nif ! boot; then diag; exit 1; fi\n',
        '\nif ! boot; then diag; exit 1; fi\n'
        '# второй AVD профиля 393 — ПОСЛЕДОВАТЕЛЬНО (слово владельца\n'
        '# 2026-10-31): экранный шаг создаёт AVD393 и передаёт пачке\n'
        '# окружение пары; ОСТАНОВКУ первого эмулятора и ЗАПУСК второго\n'
        '# (после кадров 390) делает e2e.sh пачки — одновременно двух\n'
        '# живых эмуляторов работник не держит (порт 393 вне adb-пары 1-го)\n'
        'export GESPRAECH_SERIAL="$SERIAL" GESPRAECH_SERIAL_393="$SERIAL393" '
        'GESPRAECH_AVD393="$AVD393" GESPRAECH_PORT393="$PORT393" '
        'GESPRAECH_APK="$APK"\n')
    shag['run'] = r
    return job


def instanciruj_job(src, h_ref=None, s_393=False):
    """Лекало + параметры И-8 -> dict job (грамматика — ТОЛЬКО пиннованный
    шаблон, второго списка обязательств в батарее нет)."""
    with open(LEKALO, encoding='utf-8') as fh:
        tekst = fh.read()
    zam = lekalo_zameny(src, h_ref)
    for k in sorted(zam):
        tekst = tekst.replace(k, zam[k])
    if re.search(r'\{\{[A-Z_]+\}\}', tekst):
        raise RuntimeError('лекало: незаменённый плейсхолдер')
    job = yaml.safe_load(tekst)['jobs'][src['lekalo']['job_id']]
    if s_393:
        job = rassiri_vtoroj_avd(job, src)
    return job


def podkljuchi_147(karta, wf, src, h_ref=None):
    """ТРИ парные правки лекала одним движением (И-8: тот же PR): запись
    карты + job + output выбора + needs ОБОИХ агрегатов. Единый источник
    рецепта для A-дерева самопроверки и живого --a-derevo."""
    LE = src['lekalo']
    JOB = LE['job_id']
    karta.setdefault('ekrany', []).append({
        'id': LE['screen_id'], 'kontrakty': ['147'],
        'status': 'in-development', 'job': JOB, 'pack': LE['pack'],
        'flows': list(LE['flows']), 'child_flows': list(LE['child_flows']),
        'puti': list(LE['puti']), 'h_checkout': [LE['h_path']],
        'output_namespace': LE['evidence_ns']})
    wf.setdefault('jobs', {})[JOB] = instanciruj_job(src, h_ref, s_393=True)
    vyhody = wf['jobs'].setdefault('select-screens', {}).setdefault(
        'outputs', {})
    vyhody[JOB] = '${{ steps.vybor.outputs.%s }}' % JOB
    for ag in AGREGATY:
        needs = wf['jobs'].setdefault(ag, {}).setdefault('needs', [])
        if JOB not in needs:
            needs.append(JOB)


def postav_a_derevo(tmp, src):
    """A-дерево самопроверки клетки: ЖИВЫЕ байты продукта (main Complior-mob
    6240f630 — механизм 143 v2 влит, пины nositeli/produkt/) + три парные
    правки И-8 + форма пачки + e2e.sh пачки (жизненный цикл пары 390/393 —
    цикл 2: остановку первого и запуск второго несёт e2e, судит клетка).
    Клетка обязана быть здесь ЗЕЛЁНОЙ (контроль); КРАСНОЙ — на стабах-
    обходах (stabs/stab_lekalo_*.py)."""
    LE = src['lekalo']
    koren = os.path.join(tmp, 'a-derevo')
    os.makedirs(os.path.join(koren, '.github', 'workflows'))
    pak = os.path.join(koren, LE['pack'].strip('/'))
    os.makedirs(pak)
    with open(BAZA_KARTA, encoding='utf-8') as fh:
        karta = json.load(fh)
    with open(BAZA_WF, encoding='utf-8') as fh:
        wf = yaml.safe_load(fh)
    podkljuchi_147(karta, wf, src)
    with open(os.path.join(koren, 'mobile', 'ci-screens.json'), 'w',
              encoding='utf-8') as fh:
        json.dump(karta, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    with open(os.path.join(koren, '.github', 'workflows', 'mobile.yml'),
              'w', encoding='utf-8') as fh:
        yaml.safe_dump(wf, fh, allow_unicode=True, sort_keys=False)
    shutil.copy(os.path.join(PACHKA, 'forma-ekrana.json'),
                os.path.join(pak, 'ekran.json'))
    shutil.copy(os.path.join(TEKSTY, 'e2e.sh'), os.path.join(pak, 'e2e.sh'))
    os.chmod(os.path.join(pak, 'e2e.sh'), 0o755)
    return koren


def _chita_json(put):
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh), None
    except Exception as e:
        return None, 'не читается/не JSON: %s' % str(e)[:80]


def _sudi_job_lekala(job, src):
    """Job против скелета лекала: поля DAG равны; шаги лекала — по порядку
    полными именами/uses (клетка не держит второго перечня шагов — грамматика
    одна, пиннованный шаблон); экранный шаг расширяем (норма 132 v2 —
    второй AVD), но несёт валидатор 132 v3 из H-пина, PORT И-8 и оба
    корневых флоу; H-checkout — принятым 40-hex пином (не плавающей
    ссылкой); запреты и ровно один «ПОВТОР: » — по всему job."""
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


def _sudi_vtoroj_profil(run, src):
    """Окружение пары профилей в экранном шаге (норма 132 v2; блок
    Crit147b круг 2; цикл 2 — последовательный запуск): шаг НЕ запускает
    393 сам (запуск — e2e.sh после остановки первого), но обязан:
    PORT393=<порт> (вне adb-пары первого — пригодный), SERIAL393, экспорт
    ОКРУЖЕНИЯ ПАРЫ (GESPRAECH_SERIAL/GESPRAECH_SERIAL_393/
    GESPRAECH_AVD393/GESPRAECH_PORT393/GESPRAECH_APK — канон e2e.sh ждёт
    их всех) ДО вызова приёмки run_priemka, и cleanup обоих эмуляторов
    (шаг не наследует станции живой AVD393)."""
    LE = src['lekalo']
    netu = []
    if ('PORT393=%d\n' % LE['avd_port_393']) not in run:
        netu.append('экранный шаг без PORT393=%d (порт второго AVD 393)'
                    % LE['avd_port_393'])
    if ('SERIAL393="emulator-%d"' % LE['avd_port_393']) not in run:
        netu.append('экранный шаг без SERIAL393 профиля 393')
    for per in ('GESPRAECH_SERIAL=', 'GESPRAECH_SERIAL_393=',
                'GESPRAECH_AVD393=', 'GESPRAECH_PORT393=',
                'GESPRAECH_APK='):
        eksporty = [m.start() for m in re.finditer(
            r'^[^\S\n]*export\b[^\n]*\b%s' % re.escape(per), run, re.M)]
        if not eksporty:
            netu.append('%s не экспортирована экраным шагом (канон e2e.sh '
                        'ждёт её)' % per.rstrip('='))
            continue
        vyzov = run.find('run_priemka\n')
        if vyzov == -1:
            netu.append('%s не потребляется экраным шагом (вызов приёмки '
                        'run_priemka не найден)' % per.rstrip('='))
        elif eksporty[0] > vyzov:
            netu.append('%s не потребляется экраным шагом (export после '
                        'вызова приёмки run_priemka)' % per.rstrip('='))
    if 'adb -s "$SERIAL393" emu kill' not in run:
        netu.append('cleanup шага не останавливает второй эмулятор '
                    '(adb -s "$SERIAL393" emu kill) — станция наследует '
                    'живой AVD393')
    return netu


def _e2e_segmenty(tekst):
    """Топ-уровневые исполняемые утверждения e2e.sh (замкнутая грамматика,
    прецедент produkt_sud 148 v2; норма парсящих гардов 041): строки
    склеены по «\\»-переносу, комментарии «#…» срезаны вне кавычек, тела
    функций (^имя() { … ^}) пропущены и возвращены реестром
    {имя: текст тела} — вызов хелпера ожидания вычислим по телу.
    Возврат: (список утверждений, функции)."""
    stroki, buf = [], ''
    for syr in tekst.splitlines():
        if buf:
            syr = buf + syr.lstrip()
            buf = ''
        if syr.rstrip().endswith('\\'):
            buf = syr.rstrip()[:-1] + ' '
            continue
        stroki.append(syr)
    ochish = []
    for s in stroki:
        otkr, rez = None, s
        for i, c in enumerate(s):
            if otkr:
                if c == otkr:
                    otkr = None
            elif c in ("'", '"'):
                otkr = c
            elif c == '#' and (i == 0 or s[i - 1].isspace()
                               or s[i - 1] in ';|&'):
                rez = s[:i]
                break
        ochish.append(rez.strip())
    utverzhdenija, funkcii = [], {}
    v_funkcii, imja_f, telo_f = False, None, []
    for s in ochish:
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*\(\)\s*\{(.*)$', s)
        if not v_funkcii and m:
            v_funkcii, imja_f, telo_f = True, m.group(1), [m.group(2)]
            continue
        if v_funkcii:
            if re.match(r'^\}', s):
                funkcii[imja_f] = '\n'.join(telo_f)
                v_funkcii = False
            else:
                telo_f.append(s)
            continue
        if s:
            utverzhdenija.append(s)
    return utverzhdenija, funkcii


def _sudi_zhizncikl_e2e(put_e2e):
    """Жизненный цикл пары 390/393 в e2e.sh ПАЧКИ (слово владельца
    2026-10-31; вердикт Crit147 v2a блок 2; замкнутый алфавит событий —
    каноническая форма пачки, отклонения от формы — ревью интеграции):
    события топ-уровня — остановка 390 («emu kill» по "$serial"), запуск
    393 («emulator» + «-avd»), приёмка 390/393 («maestro» с "$serial"/
    "$serial393»), ожидание загрузки («wait-for-device»). Порядок:
    кадры 390 -> ОСТАНОВКА 390 -> ЗАПУСК 393 -> кадры 393; запуск 393 до
    остановки/без остановки — ОДНОВРЕМЕННЫЕ AVD; отказы остановки/
    запуска/ожидания не маскируются («|| true»/«|| :»), отказы
    распространяет set -e. Возврат: (parallel, maska, bez_zapuska)."""
    parallel, maska, bez = [], [], []
    try:
        tekst = open(put_e2e, encoding='utf-8').read()
    except OSError as e:
        return (['e2e.sh пачки не читается (%s) — жизненный цикл пары '
                 '390/393 не судим' % str(e)[:60]], [], [])
    try:
        utv, funkcii = _e2e_segmenty(tekst)
    except Exception as e:
        return (['e2e.sh пачки не разбирается: %s' % str(e)[:60]], [], [])
    zhdushchie = {imja for imja, telo in funkcii.items()
                  if 'wait-for-device' in telo}
    sobytija = []
    for s in utv:
        z = ('|| true' in s) or ('|| :' in s)
        slova = re.split(r'[\s;|&]+', s)
        if re.search(r'\bemu kill\b', s) and '"$serial"' in s \
                and '"$serial393"' not in s:
            sobytija.append(('STOP390', z))
        if 'emulator' in s and '-avd' in slova:
            sobytija.append(('START393', z))
        if 'maestro' in slova or 'maestro' in s:
            if '"$serial393"' in s:
                sobytija.append(('MAESTRO393', z))
            elif '"$serial"' in s:
                sobytija.append(('MAESTRO390', z))
        if ('wait-for-device' in s or
                any(imja in slova for imja in zhdushchie)) \
                and '"$serial393"' in s:
            sobytija.append(('WAIT393', z))
    if not any(re.match(r'^set\s+-[a-zA-Z]*e', s) for s in utv):
        maska.append('e2e.sh без set -e — отказы остановки/запуска 393 '
                     'не распространяются')
    for vid, z in sobytija:
        if z and vid in ('STOP390', 'START393', 'WAIT393'):
            maska.append('отказ %s проглочен (|| true/|| :) — запуск 393 '
                         'не распространяет отказ' % vid)
    stopy = [i for i, (v, _) in enumerate(sobytija) if v == 'STOP390']
    starty = [i for i, (v, _) in enumerate(sobytija) if v == 'START393']
    m390 = [i for i, (v, _) in enumerate(sobytija) if v == 'MAESTRO390']
    m393 = [i for i, (v, _) in enumerate(sobytija) if v == 'MAESTRO393']
    if not starty:
        bez.append('запуск AVD 393 в e2e.sh отсутствует (нет emulator … '
                   '-avd) — приёмка профиля 393 невозможна')
        return parallel, maska, bez
    if not stopy:
        parallel.append('запуск 393 без остановки первого — одновременно '
                        'два живых AVD (нет adb … emu kill по "$serial")')
    elif starty[0] < stopy[0]:
        parallel.append('запуск 393 ДО остановки первого (индексы событий '
                        'start=%d stop=%d) — одновременно два живых AVD'
                        % (starty[0], stopy[0]))
    if not m390 or (stopy and m390[0] > stopy[0]):
        bez.append('кадры 390 не снимаются до остановки первого — приёмка '
                   'профиля 390 невозможна (maestro по "$serial" до emu '
                   'kill)')
    if not m393 or m393[0] < starty[0]:
        bez.append('кадры 393 не снимаются после запуска второго — приёмка '
                   'профиля 393 невозможна (maestro по "$serial393")')
    return parallel, maska, bez


def _sudi_posledovatelno_393(shag, src, repo):
    """ПОСЛЕДОВАТЕЛЬНЫЙ запуск пары 390/393 (слово владельца 2026-10-31;
    вердикт Crit147 v2a блок 2). Судит по коду: (1) job: AVD393 СОЗДАН
    (create avd — emulator -avd без AVD мёрт) и НЕ запускает 393 сам —
    ни литеральным emulator … -avd "$AVD393", ни вызовом boot под
    переключёнными переменными AVD="$AVD393" (GA-форма вердикта: два
    живых эмулятора до приёмки) — LEKALO_PARALLELNYJ_ZAPUSK_393;
    (2) e2e.sh пачки: порядок кадры-390 -> остановка 390 -> запуск 393 ->
    кадры 393, без одновременных AVD, отказы не маскированы
    (|| true/set -e) — LEKALO_PARALLELNYJ_ZAPUSK_393 /
    LEKALO_MASKA_OTKAZA_393 / LEKALO_BEZ_ZAPUSKA_393. Возврат:
    (parallel, maska, bez_zapuska)."""
    parallel, maska, bez = [], [], []
    if shag.get('if') is not None:
        parallel.append('экранный шаг под условием if: %r — пара 393 может '
                        'быть пропущена целиком' % str(shag['if'])[:50])
    run = str(shag.get('run') or '')
    if not re.search(r'create avd\b[^\n]*-n "\$AVD393"', run):
        bez.append('AVD 393 не создаётся (нет create avd -n "$AVD393") — '
                   'запуск мёрт: emulator -avd "$AVD393" без AVD')
    if re.search(r'emulator[^\n]*-avd "\$AVD393"', run):
        parallel.append('job сам запускает AVD 393 (emulator … -avd '
                        '"$AVD393") — до остановки первого, параллельно')
    for m in re.finditer(r'AVD="\$AVD393"', run):
        nach = m.end()
        kon = run.find('AVD="$AVD_GL"', nach)
        okno = run[nach:kon if kon != -1 else len(run)]
        for ln in okno.split('\n'):
            s = ln.strip()
            if re.match(r'^(if ! boot; then\b.*;\s*fi|boot)$', s):
                parallel.append('вызов boot под переключёнными переменными '
                                'AVD="$AVD393" (GA-форма: job запускает '
                                '393 параллельно первому): %r' % s[:50])
                break
    p_parallel, p_maska, p_bez = _sudi_zhizncikl_e2e(
        os.path.join(repo, src['lekalo']['pack'].strip('/'), 'e2e.sh'))
    parallel.extend(p_parallel)
    maska.extend(p_maska)
    bez.extend(p_bez)
    return parallel, maska, bez


def sud_lekalo(repo, src):
    """s-lekalo-instanciirovano (И-8; блоки Crit147 круг 1 + Crit147b круг
    2 + Crit147c; цикл 2 — последовательная пара): в --repo судит ТРИ
    парные правки лекала 143/2 (запись карты, job из лекала по пину
    шаблона/ключам инстанциации, output выбора + needs обоих агрегатов),
    вынос пачки мобильным общим шагом инвентаризации, НЕПУСТУЮ форму
    пачки (ekran.json={} — обход критика), ОКРУЖЕНИЕ пары профилей в
    экранном шаге (порт 393 вне adb-пары первого, SERIAL393, экспорт
    GESPRAECH_* ДО приёмки, cleanup обоих эмуляторов) и
    ПОСЛЕДОВАТЕЛЬНЫЙ жизненный цикл пары (слово владельца 31.10): job
    создаёт AVD393 и НЕ запускает 393 сам; e2e.sh пачки несёт порядок
    кадры-390 -> остановка 390 -> запуск 393 -> кадры 393, без
    одновременных AVD, с немаскированным отказом и НЕПУСТЫЕ puti записи
    карты. Именованный отказ — РОВНО одно имя на вход, по старшинству:
    LEKALO_NE_INSTANCIIROVANO (парные правки/вынос/форма/запреты лекала
    — в т.ч. continue-on-error), LEKALO_BEZ_VTOROGO_PROFILJA (окружение
    пары: порт/serial/экспорт/cleanup), LEKALO_PARALLELNYJ_ZAPUSK_393
    (запуск 393 до остановки первого — в job или e2e), LEKALO_MASKA_
    OTKAZA_393 (проглоченный отказ остановки/запуска/ожидания),
    LEKALO_BEZ_ZAPUSKA_393 (create/запуск/приёмка профилей),
    LEKALO_BEZ_PUTEJ_KARTY (puti записи). «Пропускник» ловится стабами
    lekalo-obhod-kritika, lekalo-bez-zapuska-393, lekalo-parallelnyj-
    zapusk, lekalo-zamaskirovannyj-otkaz (Н-39)."""
    LE = src['lekalo']
    JOB = LE['job_id']
    netu = []
    netu_393 = []
    netu_parallel = []
    netu_maska = []
    netu_zapusk = []
    netu_puti = []

    karta, osh = _chita_json(os.path.join(repo, 'mobile',
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
            if '147' not in (z.get('kontrakty') or []):
                netu.append('kontrakty записи без 147')
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
            if LE['h_path'] not in (z.get('h_checkout') or []):
                netu.append('h_checkout записи без %s' % LE['h_path'])
            if z.get('output_namespace') != LE['evidence_ns']:
                netu.append('output_namespace записи %r'
                            % z.get('output_namespace'))
            puti = z.get('puti') or []
            if not puti:
                netu_puti.append('puti записи пусты (выбор экранной '
                                 'задачи не обеспечен)')
            else:
                for p_ in LE['puti']:
                    if p_ not in puti:
                        netu_puti.append('puti записи без %s' % p_)

    ej, osh = _chita_json(os.path.join(repo, LE['pack'].strip('/'),
                                       'ekran.json'))
    if ej is None:
        netu.append('ekran.json пачки %s' % osh)
    elif not isinstance(ej, dict) or not ej:
        netu.append('ekran.json пачки пуст (обход Crit147: {})')
    else:
        if ej.get('shablon') != LE['shablon']:
            netu.append('ekran.json shablon %r' % ej.get('shablon'))
        if ej.get('ekran') != LE['screen_id']:
            netu.append('ekran.json ekran %r' % ej.get('ekran'))
        ekrany = ((ej.get('dvizhenie') or {}).get('ekrany')) or []
        if set(ekrany) != set(LE['ekrany']):
            netu.append('ekrany формы %s' % sorted(ekrany))

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
            shag = next((s for s in (jobs[JOB].get('steps') or [])
                         if str(s.get('name', '')).startswith(
                             'Экранная пачка')), None)
            if shag is not None:
                netu_393.extend(_sudi_vtoroj_profil(
                    str(shag.get('run') or ''), src))
                p, m, z = _sudi_posledovatelno_393(shag, src, repo)
                netu_parallel.extend(p)
                netu_maska.extend(m)
                netu_zapusk.extend(z)
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
        if re.search(r'mv\s+mobile/e2e-gespraech-vhod\b', tekst):
            netu.append('персональный mv пачки (вынос — общий шаг)')
        if re.search(r'mv\s+mobile/e2e-\*', tekst):
            netu.append('wildcard-вынос mobile/e2e-*')
    for imja, spisok in (('LEKALO_NE_INSTANCIIROVANO', netu),
                         ('LEKALO_BEZ_VTOROGO_PROFILJA', netu_393),
                         ('LEKALO_PARALLELNYJ_ZAPUSK_393', netu_parallel),
                         ('LEKALO_MASKA_OTKAZA_393', netu_maska),
                         ('LEKALO_BEZ_ZAPUSKA_393', netu_zapusk),
                         ('LEKALO_BEZ_PUTEJ_KARTY', netu_puti)):
        if spisok:
            return False, '%s: %s' % (imja, '; '.join(spisok))
    return True, ''


def postav_zhivoe_a_derevo(produkt, cel, src):
    """Живой зелёный контроль (рецепт И-8, прецедент A2/148): продукт P
    (клон Complior-mob) -> A-дерево C: канон-байты (11 пинов) + машина +
    форма пачки + обёртки e2e/prokhod + ТРИ парные правки лекала. На C
    батарея --repo обязана дать rc 0 (все клетки)."""
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
    # цикл 2 (Crit147k2b Б2): реальный потребитель — jest-среда
    # продукта СИМЛИНКОМ установки (копия тяжёлая; прецедент 148/149)
    nm_istochnik = os.path.join(produkt, 'mobile', 'node_modules')
    if os.path.isdir(nm_istochnik):
        os.symlink(os.path.realpath(nm_istochnik),
                   os.path.join(cel, 'mobile', 'node_modules'))
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
    shutil.copy(os.path.join(MODEL, 'menu-machine.ts'),
                os.path.join(mashina, 'menu-machine.ts'))
    # цикл 2 (Crit147k2b Б2): референс-компоненты зоны (зоны касания
    # по токенам пакета 1.1; прецедент 148/149) — зелёный контроль
    # исполняемого зонда на A-дереве; реальные компоненты продукта
    # судятся той же мерой в --repo
    for otn in RASKLADKA_V_PRODUKTE:
        put = os.path.join(cel, otn)
        os.makedirs(os.path.dirname(put), exist_ok=True)
        shutil.copy(os.path.join(RASKLADKA, otn), put)
    with open(os.path.join(cel, 'mobile', 'ci-screens.json'),
              encoding='utf-8') as fh:
        karta = json.load(fh)
    with open(os.path.join(cel, '.github', 'workflows', 'mobile.yml'),
              encoding='utf-8') as fh:
        wf = yaml.safe_load(fh)
    podkljuchi_147(karta, wf, src)
    with open(os.path.join(cel, 'mobile', 'ci-screens.json'), 'w',
              encoding='utf-8') as fh:
        json.dump(karta, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    with open(os.path.join(cel, '.github', 'workflows', 'mobile.yml'), 'w',
              encoding='utf-8') as fh:
        yaml.safe_dump(wf, fh, allow_unicode=True, sort_keys=False)
    print('A-DEREVO %s job=%s kanon=%d mashina=1 ekran.json=forma '
          'raskladka=%d node_modules=%s'
          % (cel, LE['job_id'], len(kanon), len(RASKLADKA_V_PRODUKTE),
             'da' if os.path.isdir(nm_istochnik) else 'net'))
    return 0


def main():
    argv = sys.argv[1:]
    rezhim = 'koren'
    repo_r = None
    seed = 147
    if '--model' in argv:
        rezhim = 'model'
    elif '--stabs' in argv:
        rezhim = 'stabs'
    elif '--repo' in argv:
        rezhim = 'repo'
        repo_r = argv[argv.index('--repo') + 1]
        # Гейт пустого продукта (контракт 159, инварианты 2–3): ПЕРВОЕ
        # действие --repo-ветви. Отказ гейта — единственная строка вывода
        # батареи и его код; своих клеток после отказа батарея не
        # запускает (инвариант 2).
        if not (os.path.isfile(DOVERENNYY_BASH)
                and os.access(DOVERENNYY_BASH, os.X_OK)):
            print('NOT_IMPLEMENTED: нет доверенного интерпретатора %s'
                  % DOVERENNYY_BASH, file=sys.stderr)
            return 2
        rc_gejta = subprocess.run([DOVERENNYY_BASH, GEJT_PUSTOGO_PRODUKTA, repo_r]).returncode
        if rc_gejta != 0:
            return rc_gejta
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
        # клеточный прогон формы флоу (зеркала стабов формы): те же
        # клетки, что в полном прогоне; rc 1 — красная клетка
        prichiny_flo = sudi_flo_forma(ZDE)
        for kletka in sorted(prichiny_flo):
            spisok = prichiny_flo[kletka]
            print('CASE %s %s %s'
                  % (kletka, 'ok' if not spisok else 'KRASNO',
                     '; '.join(spisok)))
        return 1 if any(prichiny_flo.values()) else 0
    if '--kadry-forma-only' in argv:
        # клеточный прогон кадровых инвариантов сверки (зеркала стабов
        # кадров): те же клетки, что в полном прогоне; rc 1 — красная
        prichiny_k = sudi_kadry_forma(ZDE)
        for kletka in sorted(prichiny_k):
            spisok = prichiny_k[kletka]
            print('CASE %s %s %s'
                  % (kletka, 'ok' if not spisok else 'KRASNO',
                     '; '.join(spisok)))
        return 1 if any(prichiny_k.values()) else 0
    if '--e2e-zhizncikl-only' in argv:
        # клеточный прогон жизненного цикла пары ИСПОЛНЕНИЕМ (зеркала
        # стаба e2e): та же клетка, что в полном прогоне; rc 1 — красная
        aspekty_e2e = sud_zhizncikla_ispolneniem(
            os.path.join(ZDE, 'teksty', 'e2e.sh'), src)
        print('CASE s-e2e-ostanovka-podtverzhena %s %s'
              % ('ok' if not aspekty_e2e else 'KRASNO',
                 '; '.join(aspekty_e2e)))
        return 1 if aspekty_e2e else 0

    if rezhim == 'tamper':
        prov = 0
        for imja in sorted(src['piny']['nositeli']):
            otn = imja
            vrem = tempfile.mkdtemp(prefix='gespraech147-tamper-')
            zerkalo = _zerkal_zony(vrem, src)
            # портим ОДИН носитель в зеркале
            p = os.path.join(zerkalo, otn)
            with open(p, 'ab') as fh:
                fh.write(b'x')
            env = dict(os.environ)
            env['GESpraech147_ZONA'] = zerkalo
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
        vrem = tempfile.mkdtemp(prefix='gespraech147-a-')
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
                rez_s = zapusk_valid(subjar, pak, repo, hrn)
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
    mashina_sub = os.path.join(MODEL, 'menu-machine.ts')
    net_subiekta = rezhim == 'koren'
    if rezhim == 'repo':
        mprod = os.path.join(repo_r, 'mobile', 'src', 'features',
                             'conversation', 'menu-machine.ts')
        if os.path.isfile(mprod):
            mashina_sub = mprod
        else:
            net_subiekta = True
    for p in PRAVILA_MASHINY:
        if net_subiekta:
            itogi.append(('m-' + p, False, 'SUBJECT_ABSENT menu-machine'))
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
                                     'e2e-gespraech-vhod', 'ekran.json'))),
        ('s-mashina-v-produkte',
         os.path.isfile(os.path.join(repo_r or '/net', 'mobile', 'src',
                                     'features', 'conversation',
                                     'menu-machine.ts'))),
        ('s-kanon-bajty', repo_r is not None and kanon_ok()),
    ]
    for idk, ok in proverki:
        if rezhim == 'koren':
            itogi.append((idk, False, 'SUBJECT_ABSENT продукт'))
        elif rezhim in ('model', 'stabs'):
            itogi.append((idk, True, 'статически-зелёный контроль (модель)'))
        else:
            itogi.append((idk, bool(ok), '' if ok else 'нет/не совпало'))
    # отказ LEKALO_NE_INSTANCIIROVANO со списком недостающего (блок Crit147)
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
    # клетки формы флоу (перепин 31.10): субъект — флоу пачки зоны
    # (байты запинены vedro), в --repo — и канон-копии mobile/.maestro
    for kletka, spisok in sorted(sudi_flo_forma(ZDE, repo_r).items()):
        itogi.append((kletka, not spisok, '; '.join(spisok)))
    # клетки кадровых инвариантов сверки (цикл 2, слово владельца 31.10):
    # субъект — манифесты пачки зоны (байты запинены vedro), в --repo —
    # и манифесты пачки продукта
    for kletka, spisok in sorted(sudi_kadry_forma(ZDE, repo_r).items()):
        itogi.append((kletka, not spisok, '; '.join(spisok)))
    # клетка жизненного цикла пары ИСПОЛНЕНИЕМ (цикл 2, Crit147k2b
    # класс ПОРЯДОК AVD): e2e.sh в песочнице двойников SDK — честный
    # вход зелён, «залипший» 390 — rc 0/молчаливое продолжение красны;
    # субъект — канон зоны teksty/e2e.sh (байты запинены vedro), в
    # --repo той же мерой e2e.sh пачки продукта
    vhod_e2e = os.path.join(ZDE, 'teksty', 'e2e.sh')
    if rezhim == 'repo':
        vhod_e2e = os.path.join(repo_r, 'mobile', 'e2e-gespraech-vhod',
                                'e2e.sh')
    aspekty_e2e = sud_zhizncikla_ispolneniem(vhod_e2e, src)
    itogi.append(('s-e2e-ostanovka-podtverzhena', not aspekty_e2e,
                  '; '.join(aspekty_e2e)))
    # исполняемый суд экрана (цикл 2, Crit147k2b класс РЕАЛЬНЫЙ
    # ПОТРЕБИТЕЛЬ): живой jest-зонд на РЕАЛЬНЫХ компонентах дерева +
    # матрица мутантов; без mobile/package.json — именованный пропуск
    # (не зелень продукта), заявленная среда без установки —
    # LIVE_PREDPOSYLKA (никогда skip→pass)
    if rezhim == 'koren':
        itogi.append(('s-ekran-ispolnim', False, 'SUBJECT_ABSENT продукт'))
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
        # стабы лекала (Н-39; блоки Crit147/Crit147b/Crit147c): пара входов
        # одной клеткой — A-дерево рецепта ЗЕЛЁНО (живые байты продукта
        # 6240f630 + три парные правки + второй AVD 393), каждый стаб-
        # мутатор дерева КРАСЕН своим именем: lekalo-obhod-kritika снимает
        # проводку целиком (LEKALO_NE_INSTANCIIROVANO),
        # lekalo-bez-zapuska-393 удаляет ТОЛЬКО запуск второго эмулятора
        # после переключения 393 (LEKALO_BEZ_ZAPUSKA_393 — scoped-обход
        # Crit147c); мутант-«пропускник» (клетка зелена без проверок)
        # ловится здесь — STAB_ZHIV rc 1.
        vrem_a = tempfile.mkdtemp(prefix='gespraech147-lekalo-')
        try:
            a_der = postav_a_derevo(vrem_a, src)
            ok_a, pochemu_a = sud_lekalo(a_der, src)
            if not ok_a:
                sys.stderr.write('ORACLE A-дерево не зелено: %s\n'
                                 % pochemu_a)
                return 2
            for stab, svaz in sorted(src['stab_vhod'].items()):
                if 'kletka' not in svaz:
                    continue
                if svaz['kletka'] in {v[0] for v in
                                      KLETKI_FLO_STABOV.values()}:
                    continue  # стабы формы флоу — ниже, своим контуром
                if svaz['kletka'] in {v[0] for v in
                                      KLETKI_KADRY_STABOV.values()}:
                    continue  # стабы кадровых инвариантов — ниже
                if svaz['kletka'] in {v[0] for v in
                                      KLETKI_E2E_STABOV.values()}:
                    continue  # стаб жизненного цикла — ниже, своим контуром
                if svaz['kletka'] in {v[0] for v in
                                      KLETKI_JEST_STABOV.values()}:
                    continue  # стабы jest-среды — ниже
                stub = os.path.join(vrem_a, 'stub-' + stab)
                shutil.copytree(a_der, stub)
                r = subprocess.run(
                    [sys.executable,
                     os.path.join(STABY, src['staby'][stab]), stub],
                    capture_output=True, text=True, timeout=60)
                if r.returncode != 0:
                    sys.stderr.write('ORACLE стаб %s: мутатор rc=%d %s\n'
                                     % (stab, r.returncode,
                                        r.stderr.strip()[:120]))
                    return 2
                ok_s, pochemu_s = sud_lekalo(stub, src)
                if ok_s:
                    print('STAB %s ZHIV (клетка %s зелена на стабе)'
                          % (stab, svaz['kletka']))
                    return 1
                print('STAB %s KRASEN %s' % (stab, pochemu_s.split(':')[0]))
                svjazi += 1
        finally:
            shutil.rmtree(vrem_a, ignore_errors=True)
        # стабы формы флоу (Н-39; перепин 31.10): обманный ПЕРЕПИН —
        # флоу И пины source.json меняются вместе (порчу носителя ловит
        # vedro ДО клеток, перепин — только клетка формы). Зеркальная
        # копия зоны; клеточный прогон --flo-forma-only обязан дать
        # rc 1 СВОИМ именем причины (иначе ORACLE — стаб красен не
        # своим дефектом); зелёный контроль — клетки формы выше (живая
        # зона зелена). Мутант-«пропускник» (клетка зелена без разбора
        # формы) ловится здесь — STAB_ZHIV rc 1.
        for stab, svaz in sorted(src['stab_vhod'].items()):
            if stab not in KLETKI_FLO_STABOV:
                continue
            kletka, prichina = KLETKI_FLO_STABOV[stab]
            vrem_f = tempfile.mkdtemp(prefix='gespraech147-flo-')
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
                env['GESpraech147_ZONA'] = zerkalo
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
        # стабы кадровых инвариантов сверки (Н-39; цикл 2, слово
        # владельца 31.10): обманный ПЕРЕПИН манифестов — записи И пины
        # source.json меняются вместе (порчу носителя ловит vedro ДО
        # клеток, перепин — только клетка). Зеркальная копия зоны;
        # клеточный прогон --kadry-forma-only обязан дать rc 1 СВОИМ
        # именем причины (иначе ORACLE — стаб красен не своим дефектом);
        # зелёный контроль — клетки кадровых инвариантов выше (живая зона
        # зелена). Мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
        for stab, svaz in sorted(src['stab_vhod'].items()):
            if stab not in KLETKI_KADRY_STABOV:
                continue
            kletka, prichina = KLETKI_KADRY_STABOV[stab]
            vrem_k = tempfile.mkdtemp(prefix='gespraech147-kadry-')
            try:
                zerkalo = _zerkal_zony(vrem_k, src)
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
                env['GESpraech147_ZONA'] = zerkalo
                d = subprocess.run(
                    [sys.executable, os.path.join(zerkalo, 'probe.py'),
                     '--kadry-forma-only'], capture_output=True, text=True,
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
                shutil.rmtree(vrem_k, ignore_errors=True)
        # стаб жизненного цикла (Н-39; цикл 2, Crit147k2b класс ПОРЯДОК
        # AVD): обманный ПЕРЕПИН канона — блок подтверждения ухода 390
        # снимается, пин e2e.sh меняется вместе (порчу носителя ловит
        # vedro ДО клеток). Зеркальная копия зоны; клеточный прогон
        # --e2e-zhizncikl-only обязан дать rc 1 СВОИМ именем причины
        # (иначе ORACLE — стаб красен не своим дефектом); зелёный
        # контроль — клетка выше (живой канон зелен в каждом прогоне).
        # Мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
        for stab in sorted(KLETKI_E2E_STABOV):
            kletka, prichina = KLETKI_E2E_STABOV[stab]
            vrem_e2e = tempfile.mkdtemp(prefix='gespraech147-e2e-')
            try:
                zerkalo = _zerkal_zony(vrem_e2e, src)
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
                env['GESpraech147_ZONA'] = zerkalo
                d = subprocess.run(
                    [sys.executable, os.path.join(zerkalo, 'probe.py'),
                     '--e2e-zhizncikl-only'], capture_output=True,
                    text=True, env=env, timeout=300)
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
                shutil.rmtree(vrem_e2e, ignore_errors=True)
        # стабы jest-среды (Н-39; цикл 2, Crit147k2b класс РЕАЛЬНЫЙ
        # ПОТРЕБИТЕЛЬ; прецедент 148/149): фиктивная jest-среда из
        # референс-раскладки — исполняемый путь клетки доходит до
        # запуска jest и классифицирует исходы ИМЕННО: зашитый красный
        # итог — ISPOLNIMYJ_KONTROL_KRASEN, зашитый зелёный (мутанты
        # живы) — ISPOLNIMYJ_MUTANT_ZHIV; судья, не различающий их, —
        # рассинхрон rc 2
        for stab_name, ozhidaemaja in sorted(
                (stab, svjaz[1]) for stab, svjaz
                in KLETKI_JEST_STABOV.items()):
            vrem_j = tempfile.mkdtemp(prefix='gespraech147-jest-')
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
