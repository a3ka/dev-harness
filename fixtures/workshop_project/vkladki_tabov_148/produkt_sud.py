#!/usr/bin/env python3
# Продукт-судья батареи 148 (§ПРОВОДКА): судит дерево R (референсная
# раскладка модели или живой продукт --repo) по предмету vkladki-tabov.
"""Суд дерева продукта: маркеры, исполняемый цикл AVD в песочнице,
полный суд пачки валидатором v3 и исполняемый jest-зонд компонентов.
Причины отказа именованы; rc 2 означает отсутствие предпосылок суда."""
import argparse
import hashlib
import json
import os
import re
import signal
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
NOS_MAKET = HERE / 'nositeli/maket'
NOS_D24 = HERE / 'nositeli/d24'
NOS_TOKENS = HERE / 'nositeli/tokens.css'
NOS_D24_REAL = HERE / 'nositeli/d24-real'

ETALON_146 = HERE / 'model' / 'ekran_shablon.py'
ETALON_146_PIN = '5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b'
ZOND = HERE / 'produkt' / 'vkladki-zond-148.test.tsx'
ZOND_IMJA = 'vkladki-zond-148.test.tsx'
ZOND_KUDA = 'src/bootstrap/__tests__'
# v3a (Crit148k2a, Б3): значения токенов 1.1 — дословная копия веток
# nav/touch-target пакета (v3b: + nav.height — Crit148k2b Б1); кладётся
# рядом со зондом, чисел в зонде нет
TOKENY_NOS = HERE / 'nositeli' / 'tokeny-1-1.json'
TOKENY_IMJA = 'vkladki-tokeny-148.json'
# v3a (Crit148k2a, Б3): свод пакета — единственный источник пина байтов
# ds/tokens.css (frames.json _meta.source_files_sha256)
NOS_PAKET_FRAMES = HERE / 'nositeli' / 'paket' / 'frames.json'

# v3b (Crit148k2b, Б1): источник ЗНАЧЕНИЙ nav-токенов — source/tokens.json
# пакета (ветка nav; ds/tokens.css несёт цвета/базу D 2.3 и nav-размеров
# не содержит — замер пачки), потребитель — модуль приложения, модуль —
# каноническое извлечение (tokeny_modul), руками не редактируется
ISTOCHNIK_TOKENOV = Path('docs/ux/05_Kompakt_D24/source/tokens.json')
MODUL_TOKENOV = Path('mobile/src/bootstrap/kompakt-tokens.ts')


def _nav_znachenija(ist: dict):
    """(имя поля модуля, число) из веток nav/touch-target источника;
    $type dimension, $value Npx — иначе ValueError (грамматика едина)."""
    para = (('height', ('nav', 'height')),
            ('itemMinHeight', ('nav', 'item.min-height')),
            ('labelFontSize', ('nav', 'label.font-size')),
            ('labelLineHeight', ('nav', 'label.line-height')),
            ('touchTargetMin', ('touch-target', 'min')))
    znachenija = []
    for imja, put_kljuca in para:
        uzel = ist
        for kusok in put_kljuca:
            if not isinstance(uzel, dict) or kusok not in uzel:
                raise ValueError('нет ветки %s' % '.'.join(put_kljuca))
            uzel = uzel[kusok]
        if not isinstance(uzel, dict) or uzel.get('$type') != 'dimension':
            raise ValueError('%s: $type != dimension'
                             % '.'.join(put_kljuca))
        m = re.match(r'\A(\d+)px\Z', str(uzel.get('$value')))
        if m is None:
            raise ValueError('%s: $value %r не Npx'
                             % ('.'.join(put_kljuca), uzel.get('$value')))
        znachenija.append((imja, int(m.group(1))))
    return znachenija


def tokeny_modul(ist: dict) -> str:
    """Канонический текст mobile/src/bootstrap/kompakt-tokens.ts по
    значениям источника (единственная производная значений; сверяется
    байтами гейтом TOKENY_MODUL_NE_IZ_ISTOCHNIKA)."""
    stroki = ''.join('  %s: %d,\n' % (i, z) for i, z in _nav_znachenija(ist))
    return (
        '// 148 vkladki-tabov (И-12): значения nav/touch-target токенов\n'
        '// пакета D24-Kompakt-1.1 для РЕАЛЬНЫХ компонентов лейсте —\n'
        '// каноническое извлечение из docs/ux/05_Kompakt_D24/source/\n'
        '// tokens.json (nav.height, nav.item.min-height,\n'
        '// nav.label.font-size, nav.label.line-height, touch-target.min;\n'
        '// поле $value, размерность px). Генерируется извлечением\n'
        '// батареи 148 (produkt_sud.tokeny_modul) и руками не правится:\n'
        '// продукт-судья сверяет байты с источником\n'
        '// (TOKENY_MODUL_NE_IZ_ISTOCHNIKA), зонд судит СВЯЗЬ компонента\n'
        '// с токеном подменой значения в изолированной копии (Crit148k2b\n'
        '// Б1: высота лейсте и minHeight вкладок следуют за токеном).\n'
        'export const navTokens = {\n'
        + stroki +
        '} as const;\n')


def _plus_dva(znach):
    m = re.match(r'\A(\d+)px\Z', str(znach))
    if m is None:
        raise ValueError('$value %r не Npx — подмена не определена' % znach)
    return '%dpx' % (int(m.group(1)) + 2)


def podmena_istochnika_tokenov(ist: dict):
    """Контроль связи (Crit148k2b Б1): подмена значений nav.height,
    nav.item.min-height, nav.label.font-size, nav.label.line-height на
    ДРУГОЕ ДОПУСТИМОЕ (N+2px, та же грамматика) — только в изолированной
    копии суда; честный потребитель следует."""
    novyj = json.loads(json.dumps(ist))
    opisanie = []
    for kljuch in ('height', 'item.min-height', 'label.font-size',
                   'label.line-height'):
        staryj = novyj['nav'][kljuch]['$value']
        novyj['nav'][kljuch]['$value'] = _plus_dva(staryj)
        opisanie.append('nav.%s %s→%s'
                        % (kljuch, staryj, novyj['nav'][kljuch]['$value']))
    return novyj, ', '.join(opisanie)


def proverka_modulja_tokenov(repo: Path):
    """v3b (Crit148k2b, Б1): модуль значений навигационных токенов в R —
    извлечение source/tokens.json (байты == tokeny_modul): рукописный
    дрейф значений при честном соседнем источнике — именованный отказ
    ДО исполнения зонда (клетка pr-tokeny-modul, стаб s94)."""
    istochnik = repo / ISTOCHNIK_TOKENOV
    if not istochnik.is_file():
        return ('TOKENY_MODUL_NE_IZ_ISTOCHNIKA: нет %s — источник значений '
                'токенов навигации пакета 1.1 (И-12)' % ISTOCHNIK_TOKENOV)
    try:
        ozhidaemyj = tokeny_modul(
            json.loads(istochnik.read_text(encoding='utf-8')))
    except (ValueError, KeyError, TypeError) as e:
        return ('TOKENY_MODUL_NE_IZ_ISTOCHNIKA: %s не несёт ветки '
                'nav/touch-target в грамматике Npx (%s)'
                % (ISTOCHNIK_TOKENOV, e))
    modul = repo / MODUL_TOKENOV
    if not modul.is_file():
        return ('TOKENY_MODUL_NE_IZ_ISTOCHNIKA: нет %s — модуль значений '
                'токенов лейсте (генерируется извлечением из %s)'
                % (MODUL_TOKENOV, ISTOCHNIK_TOKENOV))
    if modul.read_text(encoding='utf-8') != ozhidaemyj:
        return ('TOKENY_MODUL_NE_IZ_ISTOCHNIKA: %s != извлечению из %s '
                '(ветки nav.*/touch-target.min; модуль руками не '
                'редактируется)' % (MODUL_TOKENOV, ISTOCHNIK_TOKENOV))
    return None


# Матрица исполняемого суда (v3b, Crit148k2b): мутации — дословные
# атаки; каждая запись несет СПИСОК ФОРМ входа (альтернатив): применяется
# первая, чей якорь единственный в файле копии (вход может уже нести
# иную правку — например, конформную height:36+minHeight:44 атаки
# valid-zone: красная формаkasanie определена и для неё); заменяющая
# форма уже в файле — ИДЕМПОТЕНТНО считается применённой; нет ни одной
# формы — именованная неприменимость rc 2, никогда тихий пропуск.
# kontoli — ЗЕЛЁНЫЕ входы (svjaz: подмена значений источника в
# изолированной копии — честный потребитель следует; zona: конформная
# height:36+minHeight:44 — зонд не вправе отвергать, слово владельца
# 02.11). podmena=True — прогон под подменённым источником (модуль
# регенерирован извлечением, носитель зонда несёт те же значения).
MUTACII_ISPOLNIMYE = [
    {'imja': 'tabs', 'mutacii': [
        ('mobile/src/bootstrap/tab-shell.tsx', [
            ("section !== 'start' && sectionScreens?.[section] ? (",
             "section === 'start' && sectionScreens?.[section] ? (")])]},
    {'imja': 'badge', 'mutacii': [
        ('mobile/src/app/(tabs)/[section].tsx', [
            ("mitteIzMarshruta === 'needs'",
             "mitteIzMarshruta === 'never-needs'")])]},
    {'imja': 'skroll', 'mutacii': [
        ('mobile/src/bootstrap/tab-shell.tsx', [
            ("tabbarOverlay: { bottom: 0, left: 0, position: 'absolute', right: 0 },",
             "tabbarOverlay: { bottom: 0, left: 0, position: 'relative', right: 0 },")])]},
    # v3a (Crit148k2a, Б2): фактическая зона 36 при декларированных hh44
    # — убивается ассертом зоны зонда (touch-target.min 44); вторая
    # форма — для входов, уже несущих конформную height:36+minHeight:44
    # (атака valid-zone): снятие minHeight обнажает фактическую 36
    {'imja': 'kasanie', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 22 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 8 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 16 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 8 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingVertical: 22 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingVertical: 8 }")])]},
    # v3a (Crit148k2a, Б3): рабочий токен подменён на Final 2 (nav.label.
    # font-size $value 10 → final2 11) — убивается равенством $value 1.1;
    # v3b: якорь перенесён в модуль значений (компонент читает модуль)
    {'imja': 'tokeny', 'mutacii': [
        (str(MODUL_TOKENOV), [
            ('labelFontSize: 10,', 'labelFontSize: 11,')])]},
    # v3b (Crit148k2b, Б1): старый токен Final 2 в рабочем компоненте —
    # высота лейсте 71 != nav.height 49 (равенство $value 1.1)
    {'imja': 'nav-final2', 'mutacii': [
        ('mobile/src/bootstrap/tab-shell.tsx', [
            ('height: navTokens.height,', 'height: 71,')])]},
    # v3b (Crit148k2b, Б1): литерал 49 вместо токена — на пиннованном
    # пакете зелён (совпадение числа), красен ПОД ПОДМЕНОЙ источника
    {'imja': 'nav-literal', 'podmena': True, 'mutacii': [
        ('mobile/src/bootstrap/tab-shell.tsx', [
            ('height: navTokens.height,', 'height: 49,')])]},
    # v3b (Crit148k2b, Б2): обязательная цель контента отключена —
    # проходит зоны/кадры, красна проверкой действующей цели зонда
    {'imja': 'disabled', 'mutacii': [
        ('mobile/src/features/protection/components/SchutzUebersicht.tsx', [
            ("onPress={() => onBereich?.('optionen')}",
             "disabled\n          onPress={() => onBereich?.('optionen')}")])]},
    # Crit148k2c: предшествующая Alle вызывает onFiltr('all'); без
    # собственной реакции Filter не должен наследовать этот вызов.
    {'imja': 'filter-bez-dejstvija', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ('onPress={() => onFiltr?.(filtr)}', 'onPress={() => {}}')])]},
    # Arch148w (класс полноты 4): из модели удалены две строки ниже
    # прокрутки (Hausrat-Vergleich, Kfz-Wechsel) — раньше зонд судил
    # только видимые строки и мутант проходил rc 0 (замер Arch148w:
    # produkt_sud --repo mob-stroki-net); теперь домен действия/зон —
    # ВСЕ строки И-4, каждая отсутствующая красна своим ассертом
    {'imja': 'vorgaenge-stroki-net', 'mutacii': [
        ('mobile/src/features/missions/model/vkladki-dannye.ts', [
            ("  { id: 'vorgaenge-stroka-hausrat-vergleich', title: 'Hausrat-Vergleich', group: 'working' },\n",
             '')]),
        ('mobile/src/features/missions/model/vkladki-dannye.ts', [
            ("  { id: 'vorgaenge-stroka-kfz-wechsel', title: 'Kfz-Wechsel', group: 'waiting' },\n",
             '')])]},
    {'imja': 'padding-tolko-gorizontal', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingHorizontal: 22 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 22 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingHorizontal: 22 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 16 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingHorizontal: 22 }"),
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingVertical: 22 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingHorizontal: 22 }")])]},
]
KONTROLI_ISPOLNIMYE = [
    # v3b (Crit148k2b, Б1): СВЯЗЬ компонента с токеном — честный R зелён
    # и на пиннованном пакете, и на ПОДМЕНЁННОМ значении (N+2px)
    {'imja': 'svjaz', 'podmena': True, 'mutacii': []},
    # v3b (Crit148k2b, Б3): КОНФОРМНАЯ зона height:36+minHeight:44 —
    # RN minHeight поднимает эффективный бокс до 44; зонд обязан быть
    # ЗЕЛЁНЫМ (ложный отклон конформной зоны — дефект зонда, не входа);
    # заменяющая форма уже на входе — идемпотентно исполняется как есть
    {'imja': 'zona', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, minHeight: 44 }")])]},
    # Crit148k2c: все варианты RN padding должны давать 44+ при
    # исходном действующем обработчике. padding:16 получает 14px
    # собственной строки Filter → 46; padding:22 → минимум 44.
    {'imja': 'padding-22', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 22 }")])]},
    {'imja': 'padding-16', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 16 }")])]},
    {'imja': 'padding-vertical', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingVertical: 22 }")])]},
    {'imja': 'padding-storony', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingTop: 22, paddingBottom: 22 }")])]},
    {'imja': 'max-pol', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, minHeight: 44, maxHeight: 36 }")])]},
    {'imja': 'hitSlop', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36 }")]),
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ('style={styles.filtrKnopka}',
             'hitSlop={{ top: 4, bottom: 4 }} style={styles.filtrKnopka}')])]},
    {'imja': 'padding-pri-javnom-bokse', 'mutacii': [
        ('mobile/src/features/post/components/PostEingang.tsx', [
            ("filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }",
             "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, width: 36, padding: 22 }")])]},
]

KONFORMNYE_STILI_FILTER = (
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, minHeight: 44 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 22 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', padding: 16 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingVertical: 22 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', paddingTop: 22, paddingBottom: 22 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, minHeight: 44, maxHeight: 36 }",
    "filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', height: 36, width: 36, padding: 22 }",
)

# Точная маска профиля 393 (слово владельца 31.10, Q1б; вердикт Crit148v2
# блок 3): тот же литерал несёт судья формы model/sud_formy_148.py.
PROFIL_MASKA_PT = 48

# Порты пары И-11 (слово владельца 31.10; вердикт Crit148v2 блок 2):
# работник лекала 143 v2 — 5570, второй AVD — 5576 (сосед 5571 — adb-пара).
PORT_RABOTNIKA = '5570'
PORT_VTOROGO = '5576'

SHOV_MARKERY = [
    'readonly sectionScreens?: Readonly<Partial<Record<ShellSection, React.ReactNode>>>;',
    'readonly mitte?: React.ReactNode;',
]
MITTE_MARKERY = [
    "import { FadenSign } from '../lib/faden/FadenSign';",
    'size="tab"',
    'testID="gespraech-mitte"',
    "working: 'ui.mission.group.working'",
    "needs_action: 'ui.mission.group.needs_user'",
    "uiCopyDe['proposed.gespraech.tab.a11y.status']",
]
KOPII_KLJUCHI = [
    'ia115.nav.START',
    'ia117.nav.VORGAENGE',
    'ia115.nav.SCHUTZ',
    'ia115.nav.POST',
    'proposed.gespraech.tab',
    'proposed.gespraech.tab.a11y',
    'proposed.gespraech.tab.a11y.status',
    'ui.mission.group.working',
    'ui.mission.group.needs_user',
    'ui.mission.group.waiting',
    'ui.vorgaenge.subtitle',
    'ui.mission.all_done',
    'ui.post.filter.all',
    'ui.post.filter.received',
    'ui.post.filter.sent',
    'ui.post.send_to_complior',
    # Notice-зона GA-03 — каталогизирована пакетом 1.1 (маска снята)
    'proposed.protection.status.gap',
    'fixture.schutz.02',
    'proposed.schutz.gap.action',
    'proposed.schutz.stat.contracts',
    'proposed.schutz.stat.premium',
    'proposed.schutz.section.areas',
]
KONTENT_FAJLY = [
    'mobile/src/features/missions/components/VorgaengeListe.tsx',
    'mobile/src/features/protection/components/SchutzUebersicht.tsx',
    'mobile/src/features/post/components/PostEingang.tsx',
]
SNIMKI_OSNOVNOJ = ['vkladki-vorgaenge', 'vkladki-schutz', 'vkladki-post',
                   'vkladki-vorgaenge-skroll']
SNIMKI_PROFILJA = [s + '-393' for s in SNIMKI_OSNOVNOJ]
OBOLOCHKA = 'tabshell'
E2E_SKRIPT = 'mobile/e2e-vkladki/e2e.sh'

# Двойники несут состояние живых серийников и журнал. Они устанавливаются
# сразу в PATH и ANDROID_HOME: обе формы запуска эталонного e2e.sh идут в
# песочницу, а не к настоящему Android SDK. Журнал — наблюдение, НЕ оракул
# ожиданий: ожидания PORT_* и начальное состояние остаются у судьи в памяти.
DVOJNIK = r'''#!/usr/bin/env python3
import os
import pathlib
import sys
import time

state = pathlib.Path(os.environ["E2E148_STATE"])
log = pathlib.Path(os.environ["E2E148_LOG"])
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


def _sudit_zhurnal(lines):
    """Суд только по наблюдаемым KILL/START, не по токенам shell-скрипта."""
    zhivye = {'emulator-' + PORT_RABOTNIKA}
    otkazy, zapuskov, narushen_porjadok = [], 0, False
    for line in lines:
        if line.startswith('KILL '):
            zhivye.discard(line[5:])
        elif line.startswith('START '):
            port = line[6:]
            zapuskov += 1
            if zhivye and not narushen_porjadok:
                otkazy.append('EMULJATORY_ODNOVREMENNO: START %s при живом эмуляторе'
                              % port)
                narushen_porjadok = True
            if port != PORT_VTOROGO:
                otkazy.append('PORT_393_NE_5576: START %s, требуется %s'
                              % (port, PORT_VTOROGO))
            zhivye.add('emulator-' + port)
    if not zapuskov:
        otkazy.append('EMULJATORY_NA_VHODE_PAROJ: нет START в журнале; '
                      'цикл пары отсутствует или запуск обошёл PATH/ANDROID_HOME')
    return otkazy


def proverka_emuljatorov(repo: Path):
    """И-11: исполняем e2e.sh без настоящего SDK; живой 5570 на входе.

    Успех требует START 5576 после KILL первого и rc 0 самого e2e.sh.
    Даже корректный текст, не исполнившийся в bash, не образует событие.
    """
    put = repo / E2E_SKRIPT
    if not put.is_file():
        return ['E2E_SKRIPT_NET: нет %s (жизненный цикл пары — И-11)' % E2E_SKRIPT]
    with tempfile.TemporaryDirectory(prefix='vkladki148-avd-') as dirname:
        cwd = Path(dirname)
        script = cwd / E2E_SKRIPT
        script.parent.mkdir(parents=True)
        shutil.copyfile(put, script)
        bin_dir = cwd / 'bin'
        sdk_bin = cwd / 'android' / 'emulator'
        bin_dir.mkdir()
        sdk_bin.mkdir(parents=True)
        for name in ('adb', 'emulator', 'maestro', 'sleep'):
            double = bin_dir / name
            double.write_text(DVOJNIK, encoding='utf-8')
            double.chmod(0o755)
        (sdk_bin / 'emulator').symlink_to(bin_dir / 'emulator')
        state, log = cwd / 'state', cwd / 'events'
        state.write_text('emulator-' + PORT_RABOTNIKA + '\n', encoding='utf-8')
        log.write_text('', encoding='utf-8')
        env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ.get('PATH', ''),
                   ANDROID_HOME=str(cwd / 'android'), E2E148_STATE=str(state),
                   E2E148_LOG=str(log))
        process = subprocess.Popen(
            ['bash', str(script)], cwd=cwd, env=env,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            start_new_session=True)
        try:
            process.communicate(timeout=15)
            status = process.returncode
        except subprocess.TimeoutExpired:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.communicate()
            status = 'TIMEOUT (15 s)'
        try:
            lines = log.read_text(encoding='utf-8').splitlines()
        except OSError as exc:
            return ['E2E_PESOCHNICA_RC: журнал недоступен: %s' % exc]
        otkazy = _sudit_zhurnal(lines)
        if status != 0:
            otkazy.append('E2E_PESOCHNICA_RC: скрипт rc=%s' % status)
        return otkazy


def sha256_fajla(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def proverka_maski_profilja(repo: Path):
    """Вердикт Crit148v2, блок 3 (слово владельца 31.10, Q1б): точное
    ЗНАЧЕНИЕ маски профиля 393 — 48 pt; любое иное значение манифеста
    (47/49/60 проходят визуальную сверку) — именованный отказ независимо
    от счёта кадров. Манифест — по записи vtoroj_profil.kadry пачки R.
    Нечитаемые пачка/манифест не судятся здесь — их раньше называют
    PACHKA_ABSENT / MAKET_PIN_NEVEREN."""
    pachka = repo / 'mobile/e2e-vkladki'
    imja = 'kadry_profil.json'
    try:
        forma = json.loads((pachka / 'ekran.json').read_text(encoding='utf-8'))
        imja = forma.get('vtoroj_profil', {}).get('kadry', imja)
    except (OSError, ValueError):
        return None
    try:
        mera = json.loads((pachka / imja).read_text(encoding='utf-8'))['mera']
    except (OSError, ValueError, KeyError):
        return None
    znach = mera.get('chrome_verh_pt')
    if znach != PROFIL_MASKA_PT:
        return ('PROFIL_MASKA_NE_48: %s: mera.chrome_verh_pt=%s, а маска '
                'системной шапки профиля 393 — %d pt (слово владельца '
                '31.10, Q1б; значение — независимо от визуальной меры)'
                % (imja, znach, PROFIL_MASKA_PT))
    return None

def proverka_paketa(repo: Path):
    """v+1 (слово владельца 2026-11-02): пин пачки R — пакет
    D24-Kompakt-1.1: каждый кадр обоих манифестов лежит в
    docs/ux/05_Kompakt_D24/frames/ и maket_sha256 == записи
    frames/SHA256SUMS. Старый пин Final 2 (файлы честны) проходят и
    пин-проверку, и эталон — красит ТОЛЬКО этот гейт (клетка
    pr-paket-final2, стаб s91)."""
    sums = {}
    for line in (HERE / 'nositeli/paket/SHA256SUMS').read_text(
            encoding='utf-8').splitlines():
        sha, imja = line.split(maxsplit=1)
        sums[imja.strip().lstrip('*')] = sha
    pachka = repo / 'mobile/e2e-vkladki'
    try:
        forma = json.loads((pachka / 'ekran.json').read_text(encoding='utf-8'))
        imena = ['kadry.json',
                 forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json')]
    except (OSError, ValueError):
        return None
    for imja in imena:
        try:
            kadry = json.loads((pachka / imja).read_text(encoding='utf-8'))['kadry']
        except (OSError, ValueError, KeyError):
            return None
        for k in kadry:
            put = k.get('maket', '')
            imja_fajla = put.rsplit('/', 1)[-1]
            if (not put.startswith('docs/ux/05_Kompakt_D24/frames/')
                    or sums.get(imja_fajla) != k.get('maket_sha256')):
                return ('PAKET_1_1_NE_PRIPINEN: %s: %s: пин вне пакета '
                        'D24-Kompakt-1.1 (frames/SHA256SUMS)' % (imja, k.get('id')))
    return None

def proverka_imen_kadrov(repo: Path, src):
    """v3a (Crit148k2a, Б1): имя записи кадра обязано соответствовать её
    идентификатору — пин «GA-02 dark» на файл GA-04 (валидный кадр ТОГО
    ЖЕ пакета с честным sha из SHA256SUMS) — подмена, а не членство.
    Ожидание — пин оракула батареи (kadry_manifest/profil_kadry ==
    пакету 1.1): для каждого GA/темы/профиля ровно его кадр из frames/.
    Закрывающее свойство: на конечном домене 16 кадров замена пина ЛЮБОЙ
    записи на другой допустимый кадр пакета красна, честная база зелена."""
    pachka = repo / 'mobile/e2e-vkladki'
    try:
        forma = json.loads((pachka / 'ekran.json').read_text(encoding='utf-8'))
        pary = [('kadry.json', src['kadry_manifest']),
                (forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json'),
                 src['profil_kadry'])]
    except (OSError, ValueError):
        return None
    for imja, orakul in pary:
        try:
            kadry = json.loads((pachka / imja).read_text(encoding='utf-8'))['kadry']
        except (OSError, ValueError, KeyError):
            return None
        ozhidaemye = {k['id']: k['maket'] for k in orakul['kadry']}
        for k in kadry:
            ozhidaemoe = ozhidaemye.get(k.get('id'))
            if ozhidaemoe is None:
                return ('KADR_PODMENEN: %s: %s: записи нет в пине пакета '
                        'D24-Kompakt-1.1 (GA-02/03/04/09 × normal × '
                        'dark/light × 390×844/393×852)' % (imja, k.get('id')))
            if k.get('maket') != ozhidaemoe:
                return ('KADR_PODMENEN: %s: %s: пин %s — имя записи не '
                        'соответствует её идентификатору (пакет 1.1 пинит '
                        '%s)' % (imja, k.get('id'),
                                 Path(k.get('maket', '')).name,
                                 Path(ozhidaemoe).name))
    return None

def proverka_tokenov(repo: Path, src):
    """v3a (Crit148k2a, Б3): источник токенов пакета в R — БАЙТЫ пакета
    (docs/ux/05_Kompakt_D24/source/ds/tokens.css): пин — свод самого
    пакета (frames.json _meta.source_files_sha256['ds/tokens.css']),
    не фикстура батареи. Подмена байтов источника при верной соседней
    копии/пачке — именованный отказ."""
    try:
        svod = json.loads(NOS_PAKET_FRAMES.read_text(encoding='utf-8'))
        pin = svod['_meta']['source_files_sha256']['ds/tokens.css']
    except (OSError, ValueError, KeyError, TypeError):
        return 'ORACLE_TAMPERED: frames.json пакета без пина ds/tokens.css'
    put = repo / src['ekran_forma_prod']['audit_tokenov']
    if not put.is_file():
        return ('TOKENY_ISTOCHNIK_NEVEREN: нет %s — источник токенов '
                'пакета D24-Kompakt-1.1 (использование токенов экраном '
                'судится зондом против того же пакета)' % put.relative_to(repo))
    fakt = sha256_fajla(put)
    if fakt != pin:
        return ('TOKENY_ISTOCHNIK_NEVEREN: %s: байты != пакета '
                'D24-Kompakt-1.1 (sha256 %s…, свод пакета %s…)'
                % (put.relative_to(repo), fakt[:12], pin[:12]))
    return None

def put_maketa(repo: Path, rel: str):
    """Макет — файл по КАНОНИЧЕСКОМУ пути в R (блок 2 Crit148): носитель
    батареи НЕ подменяет путь; отсутствие файла == MAKET_PIN_NEVEREN."""
    put = repo / rel
    return put if put.is_file() else None



def _png_dekodirovat(blob):
    """IHDR/IDAT-разбор + распаковка фильтров; ct 2 (RGB) и 6 (RGBA),
    bd 8. Возвращает (w, h, ch, rows[bytes])."""
    import struct
    import zlib
    pos, idat, ihdr = 8, bytearray(), None
    while pos < len(blob):
        ln, typ = struct.unpack('>I4s', blob[pos:pos + 8])
        body = blob[pos + 8:pos + 8 + ln]
        if typ == b'IHDR':
            ihdr = body
        elif typ == b'IDAT':
            idat += body
        pos += 12 + ln
    w, h, bd, ct = struct.unpack('>IIBB', ihdr[:10])
    assert bd == 8 and ct in (2, 6), 'ожидался RGB/RGBA'
    ch = 3 if ct == 2 else 4
    raw = zlib.decompress(bytes(idat))
    stride = w * ch
    rows, prev = [], bytearray(stride)
    i = 0
    for _y in range(h):
        f = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        if f == 1:
            for x in range(ch, stride):
                line[x] = (line[x] + line[x - ch]) & 0xFF
        elif f == 2:
            for x in range(stride):
                line[x] = (line[x] + prev[x]) & 0xFF
        elif f == 3:
            for x in range(stride):
                a = line[x - ch] if x >= ch else 0
                line[x] = (line[x] + ((a + prev[x]) >> 1)) & 0xFF
        elif f == 4:
            for x in range(stride):
                a = line[x - ch] if x >= ch else 0
                b = prev[x]
                c = prev[x - ch] if x >= ch else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 0xFF
        prev = line
        rows.append(bytes(line))
    return w, h, ch, rows


def _png_kodirovat_rgba(w, h, ch, rows):
    """Кодирование в RGBA (ct 6): RGB-строки расширяются альфой 255."""
    import struct
    import zlib

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF))
    if ch == 3:
        rows = [b''.join(bytes(r[x:x + 3]) + b'\\xff' for x in range(0, len(r), 3))
                for r in rows]
    raw2 = b''.join(b'\\x00' + r for r in rows)
    return (b'\\x89PNG\\r\\n\\x1a\\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw2, 1)) + chunk(b'IEND', b''))


def png_perekodirovat(blob):
    """Честный кадр stand-in: пиксели те же, байты иные (приём 118/132)."""
    w, h, ch, rows = _png_dekodirovat(blob)
    return _png_kodirovat_rgba(w, h, ch, rows)


def staticheskie_proverki(repo: Path, src):
    otkazy = []
    pachka = repo / 'mobile/e2e-vkladki'
    if not (pachka / 'ekran.json').is_file():
        return ['PACHKA_ABSENT: нет mobile/e2e-vkladki/ekran.json']
    shov = repo / 'mobile/src/bootstrap/tab-shell.tsx'
    if not shov.is_file():
        otkazy.append('SHOV_NET: нет mobile/src/bootstrap/tab-shell.tsx')
    else:
        tekst = shov.read_text(encoding='utf-8')
        net = [m for m in SHOV_MARKERY if m not in tekst]
        if net:
            otkazy.append('SHOV_NET: нет маркеров слота: %s' % net)
    mitte = repo / 'mobile/src/bootstrap/gespraech-mitte.tsx'
    if not mitte.is_file():
        otkazy.append('MITTE_NET: нет mobile/src/bootstrap/gespraech-mitte.tsx')
    else:
        tekst = mitte.read_text(encoding='utf-8')
        net = [m for m in MITTE_MARKERY if m not in tekst]
        if net:
            otkazy.append('MITTE_NET: нет маркеров Mitte: %s' % net)
        if 'accessibilityRole="tab"' in tekst:
            otkazy.append('MITTE_V_TAB: Mitte несёт accessibilityRole="tab" '
                          '(замороженная грамматика 999 — role=tab ровно четыре)')
    net_fajly = [f for f in KONTENT_FAJLY if not (repo / f).is_file()]
    if net_fajly:
        otkazy.append('KONTENT_NET: %s' % net_fajly)
    kopii = repo / 'mobile/src/i18n/ui-copy.ts'
    if not kopii.is_file():
        otkazy.append('KOPII_NET: нет mobile/src/i18n/ui-copy.ts')
    else:
        tekst = kopii.read_text(encoding='utf-8')
        net = [k for k in KOPII_KLJUCHI if ("'%s'" % k) not in tekst]
        if net:
            otkazy.append('KOPII_NET: нет ключей: %s' % net)
    # манифесты кадров: 8+8, макеты — файлы по каноническим путям R с
    # пинами байтов (блок 2 Crit148: путь обязателен, подмены носителем нет)
    for imja_manifesta in ('kadry.json', 'kadry_profil.json'):
        try:
            man = json.loads((pachka / imja_manifesta).read_text(encoding='utf-8'))
        except (OSError, ValueError):
            otkazy.append('MAKET_PIN_NEVEREN: %s не читается' % imja_manifesta)
            continue
        kadry = man.get('kadry', [])
        if len(kadry) != 8:
            otkazy.append('MAKET_PIN_NEVEREN: %s кадров %d != 8' % (imja_manifesta, len(kadry)))
            continue
        for k in kadry:
            put = put_maketa(repo, k['maket'])
            if put is None or sha256_fajla(put) != k['maket_sha256']:
                otkazy.append('MAKET_PIN_NEVEREN: %s: %s (путь %s)'
                              % (imja_manifesta, k['id'], k['maket']))
                break
    # флоу: снимки обоих профилей + pressable
    osn = repo / 'mobile/.maestro/vkladki.yaml'
    if not osn.is_file():
        otkazy.append('SCENARIJ_BEZ_SNIMKA: нет mobile/.maestro/vkladki.yaml')
    else:
        tekst = osn.read_text(encoding='utf-8')
        for s in SNIMKI_OSNOVNOJ:
            if s not in tekst:
                otkazy.append('SCENARIJ_BEZ_SNIMKA: vkladki.yaml без %s' % s)
                break
    prof = repo / 'mobile/.maestro/vkladki-tabshell-393.yaml'
    if not prof.is_file():
        otkazy.append('SCENARIJ_BEZ_SNIMKA: нет vkladki-tabshell-393.yaml')
    else:
        tekst = prof.read_text(encoding='utf-8')
        for s in SNIMKI_PROFILJA:
            if s not in tekst:
                otkazy.append('SCENARIJ_BEZ_SNIMKA: 393 без %s' % s)
                break
        # токен оболочки — обособленным словом в исполняемой строке
        if not any(OBOLOCHKA in l.split('#', 1)[0].replace(':', ' ').split()
                   for l in tekst.splitlines()):
            otkazy.append('SCENARIJ_BEZ_SNIMKA: 393 без токена оболочки %s' % OBOLOCHKA)
    prokh = repo / 'mobile/.maestro/prokhod-vkladki.yaml'
    if not prokh.is_file():
        otkazy.append('PROKHOD_BEZ_PRESSABLE: нет prokhod-vkladki.yaml')
    else:
        tekst = prokh.read_text(encoding='utf-8')
        ispolnimye = [l.split('#', 1)[0] for l in tekst.splitlines()]
        net_id = [p['id'] for p in src['ekran_forma']['prokhodimost']['pressable']
                  if not any(p['id'] in l for l in ispolnimye)]
        if net_id:
            otkazy.append('PROKHOD_BEZ_PRESSABLE: %s' % net_id[:3])
    otkazy += proverka_emuljatorov(repo)
    return otkazy


def sobrat_repo(repo: Path, tmp: Path, src):
    """Синтетическое репо для эталона: пачка R + макеты R/носителей +
    пиннованные источники + stand-in команды приёмки + пин 123."""
    sint = tmp / 'repo'
    pachka = sint / 'mobile/e2e-vkladki'
    pachka.mkdir(parents=True)
    for f in repo.joinpath('mobile/e2e-vkladki').iterdir():
        if f.is_file():
            shutil.copyfile(f, pachka / f.name)
    batareja = pachka / 'batareja'
    batareja.mkdir(exist_ok=True)
    for f in repo.joinpath('mobile/e2e-vkladki/batareja').iterdir():
        shutil.copyfile(f, batareja / f.name)
    # макеты по каноническим путям R (существование гарантировано
    # строгой проверкой put_maketa в staticheskie_proverki — блок 2)
    for imja in ('kadry.json', 'kadry_profil.json'):
        man = json.loads((pachka / imja).read_text(encoding='utf-8'))
        for k in man['kadry']:
            kuda = sint / k['maket']
            if not kuda.parent.exists():
                kuda.parent.mkdir(parents=True)
            shutil.copyfile(repo / k['maket'], kuda)
    # источники движения (пиннованные реальные байты)
    for pole, imja in (('manifest', 'manifest.json'), ('spec', 'spec.json'),
                       ('pozvonok', 'poses.json')):
        put = sint / src['ekran_forma']['dvizhenie'][pole]
        if not put.parent.exists():
            put.parent.mkdir(parents=True)
        shutil.copyfile(NOS_D24_REAL / imja, put)
    # манифесты ne_trogaet из R (продуктовые пачки 118/135): суд по
    # КАЖДОМУ НАЙДЕННОМУ манифесту каждого корня (132 §zamenjaet) — в
    # корне сборки остаются только разрешимые пути (файл есть в R либо в
    # корне харнесса); недостающие корневые пути отбрасываются ДО суда
    # (эталон требует существования каждого объявленного пути).
    forma = json.loads((pachka / 'ekran.json').read_text(encoding='utf-8'))
    for rel in forma.get('ne_trogaet', []):
        isto = repo / rel
        if isto.is_file():
            kuda = sint / rel
            if not kuda.parent.exists():
                kuda.parent.mkdir(parents=True)
            shutil.copyfile(isto, kuda)
    forma['ne_trogaet'] = [
        rel for rel in forma.get('ne_trogaet', [])
        if (sint / rel).is_file() or (H_ROOT / rel).is_file()]
    (pachka / 'ekran.json').write_text(
        json.dumps(forma, ensure_ascii=False, indent=1), encoding='utf-8')
    # аудит токенов (v3a, Crit148k2a Б3): синтетическое репо несёт
    # ИСТОЧНИК R, когда он есть; фикстура батареи — только заполнение
    # синтетических входов без источника, НЕ единственный источник
    put = sint / src['ekran_forma']['audit_tokenov']
    put.parent.mkdir(parents=True, exist_ok=True)
    isto = repo / src['ekran_forma']['audit_tokenov']
    shutil.copyfile(isto if isto.is_file() else NOS_TOKENS, put)
    # флоу из R
    for f in ('vkladki.yaml', 'vkladki-tabshell-393.yaml', 'prokhod-vkladki.yaml'):
        isto = repo / 'mobile/.maestro' / f
        if isto.is_file():
            kuda = sint / 'mobile/.maestro' / f
            kuda.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(isto, kuda)
    # stand-in команды приёмки: обёртки в пачке, помощники ВНЕ пачки
    # (аудит литералов пачки судит каждый текстовый файл пачки)
    pomm = sint / 'mobile/e2e-standin-vkladki'
    pomm.mkdir(parents=True, exist_ok=True)
    (sint / 'mobile/e2e-vkladki/e2e.sh').write_text(
        src['standiny']['e2e'], encoding='utf-8')
    (sint / 'mobile/e2e-vkladki/prokhod.sh').write_text(
        src['standiny']['prokhod'], encoding='utf-8')
    (sint / 'mobile/e2e-vkladki/dvizhenie.sh').write_text(
        src['standiny']['dvizhenie'], encoding='utf-8')
    for imja, kljuch in (('e2e-stand-in.py', 'e2e_py'),
                         ('e2e-ustarevshij.py', 'e2e_ustarevshij_py'),
                         ('e2e-nizhe-poroga.py', 'e2e_nizhe_poroga_py'),
                         ('stand_in_png.py', 'png'),
                         ('dvizhenie-stand-in.py', 'dvizhenie_py')):
        (pomm / imja).write_text(src['standiny'][kljuch], encoding='utf-8')
    (sint / 'mobile/maestro-out-vkladki').mkdir(parents=True)
    # пин механизма 123 (как в продукте)
    pin123 = sint / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pachka / 'kadry.json', pin123 / 'kadry.json')
    return sint


def sud_pachki(repo: Path, src):
    """Полный суд пачки эталоном v3 в синтетическом репо (дорогой,
    последним). Возвращает (rc, stdout, stderr, prichiny)."""
    if not ETALON_146.is_file():
        return None
    if sha256_fajla(ETALON_146) != ETALON_146_PIN:
        return 'TAMPERED'
    tmp = Path(tempfile.mkdtemp(prefix='vkladki148-pr-'))
    try:
        sint = sobrat_repo(repo, tmp, src)
        p = subprocess.run(
            [sys.executable, str(ETALON_146), '--pack',
             str(sint / 'mobile/e2e-vkladki'), '--repo', str(sint),
             '--harness', str(H_ROOT)],
            capture_output=True, text=True)
        return p.returncode, p.stdout, p.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

def ispolnimyj_sud(repo: Path, src):
    """Исполняемый суд (блок 1 Crit148, класс «литерал на месте,
    исполняемое иное»): живой jest-зонд на РЕАЛЬНЫХ компонентах R в
    изолированной копии mobile (node_modules — симлинк установки R,
    прецедент zhivoj_komponent 145) + матрица мутаций (v3b — восемь) и
    ЗЕЛЁНЫЕ контроля (v3b, Crit148k2b): контроль исходного кода зелен,
    контроль СВЯЗИ зелен на подменённом источнике (N+2px), контроль
    конформной зоны (height:36+minHeight:44) зелен, каждый мутант убит
    ПРЕДМЕТНЫМ ассертом зонда.
    Возвращает (rc, prichiny).

    Дерево без mobile/package.json — не jest-среда (синтетические входы
    батареи): именованный пропуск в stderr, не зелень продукта. Дерево
    С package.json, но без установки — именованная предпосылка rc 2,
    НИКОГДА skip->pass (прецедент proba_live_put 145)."""
    mob = repo / 'mobile'
    if not (mob / 'package.json').is_file():
        print('ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда',
              file=sys.stderr)
        return 0, []
    if not ZOND.is_file() or sha256_fajla(ZOND) != src['piny']['produkt']['produkt/%s' % ZOND_IMJA]:
        return 2, ['ORACLE_TAMPERED: пин зонда не совпал']
    # v3a (Crit148k2a, Б3): значения токенов 1.1 — носитель батареи,
    # пин sha256; кладётся рядом со зондом (чисел в зонде нет)
    if (not TOKENY_NOS.is_file()
            or sha256_fajla(TOKENY_NOS) != src['piny']['nositeli']['nositeli/tokeny-1-1.json']):
        return 2, ['ORACLE_TAMPERED: пин носителя токенов 1.1 не совпал']
    predposylki = []
    konfig = None
    for imja in ('jest.config.js', 'jest.config.json'):
        if (mob / imja).is_file():
            konfig = imja
            break
    if konfig is None:
        predposylki.append('нет mobile/jest.config.{js,json}')
    nm = mob / 'node_modules'
    for paket in ('jest-expo', '@testing-library/react-native'):
        if not (nm / paket / 'package.json').is_file():
            predposylki.append('не установлен пакет %s' % paket)
    if not (nm / '.bin' / 'jest').exists():
        predposylki.append('нет node_modules/.bin/jest')
    for rel in ('src/bootstrap/tab-shell.tsx', 'src/bootstrap/gespraech-mitte.tsx',
                'src/app/(tabs)/[section].tsx'):
        if not (mob / rel).is_file():
            predposylki.append('нет компонента %s' % rel)
    if predposylki:
        return 2, ['LIVE_PREDPOSYLKA: %s' % '; '.join(predposylki)]
    vrem = Path(tempfile.mkdtemp(prefix='vkladki148-live-'))
    try:
        kopija = vrem / 'mobile'
        shutil.copytree(mob, kopija, ignore=shutil.ignore_patterns('node_modules'))
        os.symlink(nm.resolve(), kopija / 'node_modules')
        zond = kopija / ZOND_KUDA / ZOND_IMJA
        zond.parent.mkdir(parents=True, exist_ok=True)
        zond.write_text(ZOND.read_text(encoding='utf-8'), encoding='utf-8')
        (zond.parent / TOKENY_IMJA).write_text(
            TOKENY_NOS.read_text(encoding='utf-8'), encoding='utf-8')

        def zapustit():
            try:
                p = subprocess.run(
                    [str(kopija / 'node_modules' / '.bin' / 'jest'),
                     '--config', konfig, '--rootDir', '.',
                     '--ci', '--runInBand', '--json', 'vkladki-zond-148'],
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
            """(упавших ассертов, не исполнившихся сьютов) — падение
            загрузки/трансформации НЕ засчитывается убитым мутантом."""
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

        ishodnye = {}
        for _zapis in MUTACII_ISPOLNIMYE + KONTROLI_ISPOLNIMYE:
            for rel, _formy in _zapis['mutacii']:
                put = kopija / Path(rel).relative_to('mobile')
                ishodnye[rel] = put.read_text(encoding='utf-8')

        # v3b (Crit148k2b Б1): состояния источника токенов — пиннованный
        # и ПОДМЕНЁННЫЙ (N+2px): модуль копии регенерирован извлечением
        # из подменённого источника, носитель зонда несёт те же
        # значения; подмена ТОЛЬКО в изолированной копии суда (R не
        # трогается). Литерал в компоненте совпадением числа проходит
        # пиннованный прогон — подмену НЕ следует: красен.
        modul_kopii = kopija / Path(str(MODUL_TOKENOV)).relative_to('mobile')
        nositel_ishodnyj = TOKENY_NOS.read_text(encoding='utf-8')
        modul_ishodnyj = ishodnye.get(
            str(MODUL_TOKENOV), modul_kopii.read_text(encoding='utf-8'))
        try:
            istochnik = json.loads(
                (repo / ISTOCHNIK_TOKENOV).read_text(encoding='utf-8'))
            ist_podmena, opisanie_podmeny = podmena_istochnika_tokenov(
                istochnik)
            modul_podmena = tokeny_modul(ist_podmena)
            nos_podmena = json.loads(nositel_ishodnyj)
            for kljuch in ('height', 'item.min-height', 'label.font-size',
                           'label.line-height'):
                nos_podmena['nav'][kljuch]['$value'] = _plus_dva(
                    nos_podmena['nav'][kljuch]['$value'])
            nositel_podmena = json.dumps(nos_podmena, ensure_ascii=False,
                                         indent=2) + '\n'
        except (OSError, ValueError, KeyError, TypeError) as e:
            return 2, ['LIVE_PREDPOSYLKA: источник/носитель токенов R не '
                       'читается в грамматике Npx (%s)' % e]

        def ustanovit_sostojanie(podmena: bool):
            (zond.parent / TOKENY_IMJA).write_text(
                nositel_podmena if podmena else nositel_ishodnyj,
                encoding='utf-8')
            modul_kopii.write_text(
                modul_podmena if podmena else modul_ishodnyj,
                encoding='utf-8')

        def primenit_zapis(zapis):
            """Скопированные файлы — в исходное состояние, состояние
            источника (пинн/подмена) — по записи, затем её мутации.
            Мутация ИДЕМПОТЕНТНА: якоря нет, но заменяющая форма уже в
            файле (вход несёт ту же правку — атака Crit148k2b valid-zone
            на конформной зоне) — считается применённой и исполняется
            как есть; нет ни якоря, ни замены — именованная
            неприменимость. Возвращает None либо неприменимость."""
            for rel, tekst in ishodnye.items():
                (kopija / Path(rel).relative_to('mobile')).write_text(
                    tekst, encoding='utf-8')
            ustanovit_sostojanie(zapis.get('podmena', False))
            for rel, formy in zapis['mutacii']:
                tekst = (kopija / Path(rel).relative_to('mobile')).read_text(encoding='utf-8')
                primenina = None
                uze = False
                for ankora, zamena in formy:
                    if tekst.count(ankora) == 1:
                        primenina = (ankora, zamena)
                        break
                    if tekst.count(zamena) >= 1:
                        uze = True
                if primenina is None and not uze and zapis in KONTROLI_ISPOLNIMYE[1:] \
                        and any(stil in tekst for stil in KONFORMNYE_STILI_FILTER):
                    # Внешний R уже несёт ИНОЙ конформный стиль; конкретный
                    # контроль исполнен на исходном R, здесь — только его
                    # собственное исходное выполнение (выше).
                    return 'KONTROL_NE_PRIMENIM_K_VARIANTU'
                if primenina is None:
                    if not uze:
                        return ('LIVE_MUTACIJA_NEPRIMENIMA: %s: нет ни '
                                'одной формы входа в %s'
                                % (zapis['imja'], rel))
                    continue
                (kopija / Path(rel).relative_to('mobile')).write_text(
                    tekst.replace(primenina[0], primenina[1], 1),
                    encoding='utf-8')
            return None

        svod, oshibka = zapustit()
        if svod is None:
            return 1, ['ISPOLNIMYJ_INFRA: контроль: %s' % oshibka]
        assery, _sjuity = klassifikirovat(svod)
        zelen = bool(svod.get('success')) and int(svod.get('numPassedTests', 0)) > 0
        print('ISPOLNIMYJ kontrol %s — suites=%s tests=%s' % (
            'ZELEN' if zelen else 'KRASEN', svod.get('numTotalTestSuites'),
            svod.get('numTotalTests')), file=sys.stderr)
        if not zelen:
            sobstvennyj_otkaz = next((
                m.group(0)
                for sjuit in svod.get('testResults', [])
                for utv in sjuit.get('assertionResults', [])
                for soobschenie in utv.get('failureMessages', [])
                for m in [re.search(r'(?:TSEL_NAZHATIE_NE_DEJSTVUET|TSEL_OTKLJUCHENA|ZONA_NAZHATIJA_MENSHE_NORMY) [a-z0-9-]+', soobschenie)]
                if m is not None
            ), None)
            return 1, ['ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных '
                       'компонентах R (упавших ассертов %d%s)' %
                       (assery, '; ' + sobstvennyj_otkaz if sobstvennyj_otkaz else '')]

        # v3b (Crit148k2b Б1): контроль СВЯЗИ — подмена значений источника
        # на другое допустимое (N+2px): честный потребитель СЛЕДУЕТ
        neprimenima = primenit_zapis(KONTROLI_ISPOLNIMYE[0])
        if neprimenima is not None:
            return 2, [neprimenima]
        svod, oshibka = zapustit()
        if svod is None:
            return 1, ['ISPOLNIMYJ_INFRA: контроль svjaz: %s' % oshibka]
        assery, _sjuity = klassifikirovat(svod)
        zelen = bool(svod.get('success')) and int(svod.get('numPassedTests', 0)) > 0
        print('ISPOLNIMYJ kontrol svjaz %s — %s (высота лейсте и minHeight '
              'вкладок следуют за источником)' % (
                  'ZELEN' if zelen else 'KRASEN', opisanie_podmeny),
              file=sys.stderr)
        if not zelen:
            return 1, ['ISPOLNIMYJ_TOKEN_NE_POTREBLJON: высота лейсте/'
                       'minHeight вкладок не следуют за токеном — подмена '
                       '%s красна (упавших ассертов %d); совпадение '
                       'текущего числа связью с токеном не является'
                       % (opisanie_podmeny, assery)]

        # Зелёные конформные формы зоны исполняются независимо: ни одна
        # ранняя зелень не засчитывается за следующую (padding/vertical).
        for zapis in KONTROLI_ISPOLNIMYE[1:]:
            neprimenima = primenit_zapis(zapis)
            if neprimenima == 'KONTROL_NE_PRIMENIM_K_VARIANTU':
                print('ISPOLNIMYJ kontrol %s NE_PRIMENIM — иной конформный вариант R'
                      % zapis['imja'], file=sys.stderr)
                continue
            if neprimenima is not None:
                return 2, [neprimenima]
            svod, oshibka = zapustit()
            if svod is None:
                return 1, ['ISPOLNIMYJ_INFRA: контроль %s: %s' % (zapis['imja'], oshibka)]
            assery, _sjuity = klassifikirovat(svod)
            zelen = bool(svod.get('success')) and int(svod.get('numPassedTests', 0)) > 0
            print('ISPOLNIMYJ kontrol %s %s — конформная зона по правилам RN'
                  % (zapis['imja'], 'ZELEN' if zelen else 'KRASEN'),
                  file=sys.stderr)
            if not zelen:
                return 1, ['ISPOLNIMYJ_LOZHNYJ_OTKAZ: %s: конформная зона '
                           'отвергнута (упавших ассертов %d)' % (zapis['imja'], assery)]

        zhivye, neubit = [], []
        for zapis in MUTACII_ISPOLNIMYE:
            neprimenima = primenit_zapis(zapis)
            if neprimenima is not None:
                return 2, [neprimenima]
            svod, oshibka = zapustit()
            if svod is None:
                neubit.append('%s(infra: %s)' % (zapis['imja'], oshibka))
                print('ISPOLNIMYJ mutant %s INFRA — %s'
                      % (zapis['imja'], oshibka), file=sys.stderr)
                continue
            assery, sjuity = klassifikirovat(svod)
            if assery > 0:
                print('ISPOLNIMYJ mutant %s UBIT — упавших ассертов %d'
                      % (zapis['imja'], assery), file=sys.stderr)
            elif sjuity > 0:
                neubit.append('%s(сьют не исполнился)' % zapis['imja'])
                print('ISPOLNIMYJ mutant %s NE_UBIT — сьют(ы) не исполнились'
                      % zapis['imja'], file=sys.stderr)
            else:
                zhivye.append(zapis['imja'])
                print('ISPOLNIMYJ mutant %s ZHIV — зонд зелён под мутантом'
                      % zapis['imja'], file=sys.stderr)
        prichiny = []
        if zhivye:
            prichiny.append('ISPOLNIMYJ_MUTANT_ZHIV: %s' % ', '.join(zhivye))
        if neubit:
            prichiny.append('ISPOLNIMYJ_MUTANT_NE_UBIT: %s' % ', '.join(neubit))
        return (1 if prichiny else 0), prichiny
    finally:
        shutil.rmtree(vrem, ignore_errors=True)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    a = ap.parse_args()
    repo = Path(a.repo).resolve()
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    otkazy = staticheskie_proverki(repo, src)
    if otkazy:
        for o in otkazy:
            print('PRICHINA\t%s' % o)
        return 1
    itog = sud_pachki(repo, src)
    if itog is None:
        print('PRICHINA\tETALON_146_ABSENT: нет эталона v3 (model/ekran_shablon.py)')
        return 2
    if itog == 'TAMPERED':
        print('PRICHINA\tORACLE_TAMPERED: пин эталона v3 не совпал')
        return 2
    rc, out, err = itog
    sys.stdout.write(out)
    for l in err.splitlines():
        if l.startswith('PRICHINA'):
            print(l)
    if rc != 0:
        return rc
    maska = proverka_maski_profilja(repo)
    if maska:
        print('PRICHINA\t%s' % maska)
        return 1
    paket = proverka_paketa(repo)
    if paket:
        print('PRICHINA\t%s' % paket)
        return 1
    imena = proverka_imen_kadrov(repo, src)
    if imena:
        print('PRICHINA\t%s' % imena)
        return 1
    tokeny = proverka_tokenov(repo, src)
    if tokeny:
        print('PRICHINA\t%s' % tokeny)
        return 1
    modul = proverka_modulja_tokenov(repo)
    if modul:
        print('PRICHINA\t%s' % modul)
        return 1
    rc2, prichiny2 = ispolnimyj_sud(repo, src)
    for p in prichiny2:
        print('PRICHINA\t%s' % p)
    return rc2


if __name__ == '__main__':
    sys.exit(main())
