# стаб 138 (s65_ljuboj_propus_testid): алфавит имён атрибутов-носителей
# не замкнут И деревья-владельцы не судятся — любой пропс *TestID
# (testID/buttonTestID/ctaTestID/TestID/…) в ЛЮБОМ дереве засчитывается
# носителем (подстрока без якоря имени + поиск по всем деревьям —
# регресс круга 1, живучесть проверена заявкой implementer 138).
#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 138, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132 (§НЕ ЗАЩИЩАЕТ контракта). Судит свойства (уроки 118 + оба
# блокера круга 1 критика закрыты КЛАССАМИ, не мутантами):
#   1) флоу: единственный запуск production (launchApp, никаких
#      openLink/startApp); перед каждым кадром — переход и assert-селектор
#      СВОЕГО состояния; каждый snimok манифеста — ровно один раз;
#   1а) ФОРМА ФЛОУ — замкнутый алфавит: исполненными считаются ТОЛЬКО
#      топ-уровневые команды KOMANDY_PACHKI (openLink/startApp в алфавите
#      парсера, но отвергаются п.1 как обход пуска). Любая условность,
#      вложенность либо отложенность — ключи USLOVNYE_KONSTRUKCII на любом
#      уровне и в любом виде (блок либо inline-карта), вложенные '- ' шаги,
#      конструкции вне алфавита (в т.ч. YAML-анкоры/алиасы) — отказ
#      FLOW_USLOVNYJ_SHAG: шаг, который при честном запуске может НЕ
#      выполниться, исполненным переходом не считается. Имитация шагов
#      комментариями шагом не является;
#   2) ПУТЬ ДОПУСКА (граница с 118): First-Run → first-run-continue →
#      demo-вход auth-demo-entry → Erstinformation gate current →
#      erstinfo_continue_start → состав Start ПО ВКЛАДКАМ (start_tabs и
#      КАЖДАЯ из четырёх своим testID — пустой start_tabs не Start);
#   3) appId флоу == expo.android.package из mobile/app.json
#      (дефект батареи 118: чужой demo-пакет ронял Maestro);
#   4) конфиг каталога mobile/.maestro/config.yaml несёт исключение флоу
#      пачки своей строкой в flows (общий прогон каталога 995 не должен
#      гонять экранный флоу: порядок флоу каталога недетерминирован);
#   5) селекторы: каждый имеет носитель в дереве-ВЛАДЕЛЬЦЕ (таблица
#      VLADELTCY: состояния Start — mobile/src/features/start/**;
#      Erstinformation — onboarding/**; demo-вход — auth/**; состав
#      вкладок — mobile/src/app/**; first-run-continue — допуск 135/118,
#      ОДНО ИЗ ДВУХ деревьев auth/onboarding: frozen-текст 138/1
#      называет onboarding, продукт и frozen 135 несут кнопку в auth).
#      Носитель — атрибут ИЗ ЗАМКНУТОГО АЛФАВИТА ИМЁН buttonTestID/testID
#      (118: Cta рендерит testID={buttonTestID}, auth-parts.tsx; иные
#      *TestID-пропсы носителем не являются) в сегменте КОДА (лексер:
#      комментарии/строки/шаблоны — не код) файла экранного кода
#      (не __tests__/__mocks__/__snapshots__, не *.test.*|*.spec.*|
#      *.stories.*, расширения .tsx/.jsx/.js) дерева-владельца;
#      достижимость узла не судится (НЕ ЗАЩИЩАЕТ). Совпадение в ЧУЖОМ
#      дереве носителем НЕ является. Лексер минимальный: строка обрывается
#      на неэкранированном \n (`\`+перевод — продолжение; апостроф
#      JSX-текста маскирует до конца строки — обход: носитель своей
#      строкой); `\` экранирует следующий символ в строках и шаблонах;
#      ${…} шаблона не разбирается (носитель внутри ${…} — ложный красный,
#      вложенный бэктик — остаток); пробелы вокруг '=' допустимы;
#   6) манифест — ровно 8 кадров: 4 состояния × dark/light;
#   7) кадр, байт-идентичный макету, — НЕ скриншот (сравнение sha256).
# В CI продукта пускается ПОСЛЕ валидатора 132 (тот вызывает Maestro),
# БЕЗ промежуточной правки кадров. rc: 0 — признаки без отказов;
# 1 — PRICHINA по каждому отказу; 2 — вход нечитаем (PROVERKA_NECHITAEM).
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

PEREHODY = ('tapOn', 'inputText', 'pressKey', 'swipe')
ZAPUSKI = ('launchApp',)
# Замкнутый алфавит топ-уровневых команд пачки (ось «допуск × переходы ×
# форма flow», круг 1 критика): вне алфавита — FLOW_USLOVNYJ_SHAG.
KOMANDY_PACHKI = frozenset((
    'launchApp', 'openLink', 'startApp', 'tapOn', 'assertVisible',
    'assertNotVisible', 'inputText', 'pressKey', 'swipe', 'takeScreenshot'))
# Условные/отложенные конструкции Maestro (when/repeat/retry/runFlow/
# runScript/evalScript/onFlowStart/onFlowComplete): ключ на любом уровне,
# блок либо inline — шаг может НЕ выполниться, исполненным не считается.
USLOVNYE_KONSTRUKCII = ('when', 'repeat', 'retry', 'runFlow', 'runScript',
                        'evalScript', 'onFlowStart', 'onFlowComplete')
OBRAZEC_USLOVNOGO = re.compile(
    r'(?:\A|- |\s|[{,])(%s)\s*:' % '|'.join(USLOVNYE_KONSTRUKCII))
# Селектор → дерево-владелец (ось «состояние × источник селектора», круг 1):
# носитель ищется ТОЛЬКО в дереве владельца; чужое дерево не сканируется.
# first-run-continue — допуск 135/118, ДВА дерева: frozen-текст 138/1
# (инвариант 9) называет владельцем onboarding, а продукт и frozen 135
# (ISTOCHNIKI_EKRANA = features/auth) несут кнопку First-Run в auth
# (first-run-screen.tsx); батарея принимает ОДНО ИЗ ДВУХ деревьев.
VLADELTCY = {
    'mobile/src/features/start': ('start_sostojanie_idle',
                                  'start_sostojanie_composer',
                                  'start_sostojanie_decision',
                                  'start_sostojanie_resume',
                                  'start_next_variant'),
    'mobile/src/features/onboarding': ('erstinfo_gate_current',
                                       'erstinfo_continue_start'),
    'mobile/src/features/auth': ('auth-demo-entry',),
    'mobile/src/app': ('start_tabs', 'start_tab_start', 'start_tab_vorgaenge',
                       'start_tab_schutz', 'start_tab_post'),
}
# Допуск 135/118 (заявка implementer 138: честный экран носит кнопку в auth
# формой buttonTestID): auth (продукт, frozen 135) ЛИБО onboarding
# (frozen-текст 138/1 инвариант 9) — оба дерева остаются владельцами.
DOPUSK_DEREVJA = ('mobile/src/features/auth', 'mobile/src/features/onboarding')
ISTOCHNIKI_EKRANA = tuple(VLADELTCY)
DEREVA_SELEKTORA = {s: (d,) for d, i in VLADELTCY.items() for s in i}
DEREVA_SELEKTORA['first-run-continue'] = DOPUSK_DEREVJA
SELEKTOR_KADRA = {
    'start-ekran-f04-01': 'start_sostojanie_idle',
    'start-ekran-f04-07': 'start_sostojanie_composer',
    'start-ekran-f04-08': 'start_sostojanie_decision',
    'start-ekran-f04-13': 'start_sostojanie_resume',
}
OZHIDAEMYE_KADRY = sorted(
    (snimok, tema) for snimok in SELEKTOR_KADRA for tema in ('dark', 'light'))
KATALOG_MAESTRO = 'mobile/.maestro/config.yaml'
APP_JSON = 'mobile/app.json'


def prichina(imja, detal):
    print('PRICHINA\t%s\t%s' % (imja, detal), file=sys.stderr)


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def shagi_flow(path):
    """Топ-уровневые шаги (отступ 0) + перечень условных/вложенных
    конструкций. Шаг '- ' с отступом > 0 — вложенный (внутрь runFlow/
    repeat/анкора); ключ USLOVNYE_KONSTRUKCII — блок либо inline-карта;
    '- x' вне алфавита — конструкция не пачки (анкоры/алиасы/прочее).
    Комментарий шагом не является ни в какой форме."""
    shagi, uslovnye = [], []
    for num, line in enumerate(
            path.read_text(encoding='utf-8').splitlines(), 1):
        s = line.strip()
        if not s or s.startswith('#'):
            continue
        kljuchi = sorted(set(OBRAZEC_USLOVNOGO.findall(s)))
        if kljuchi:
            uslovnye.append('%s:%d' % ('+'.join(kljuchi), num))
            continue
        if not s.startswith('- '):
            continue
        otstup = len(line) - len(line.lstrip(' '))
        k, sep, a = s[2:].partition(':')
        k = k.strip()
        if otstup > 0:
            uslovnye.append('vlozhennyj_shag:%d' % num)
        else:
            shagi.append((k, a.strip() if sep else ''))
            if k not in KOMANDY_PACHKI:
                uslovnye.append('vne_alfavita:%s:%d' % (k, num))
    return shagi, uslovnye


def id_iz(arg):
    if 'id:' not in arg:
        return None
    t = arg.partition('id:')[2].strip()
    t = t.split('}')[0].split(',')[0]
    return t.strip().strip("'\"")


def paket_produkta(repo):
    """Пакет продукта — из mobile/app.json (expo.android.package), не литерал
    батареи."""
    app = json.loads((repo / APP_JSON).read_text(encoding='utf-8'))
    return app['expo']['android']['package']


def appid_flow(path):
    """appId из заголовка флоу (строки до первого '---')."""
    for line in path.read_text(encoding='utf-8').splitlines():
        if line.startswith('appId:'):
            return line.partition('appId:')[2].strip()
    return None


def iskljuchenie_pachki_v_confige(repo, iskljuchenie):
    """Исключение флоу пачки в списке flows конфига каталога Maestro.
    Сверка литеральная: строка элемента списка, не подстрока где угодно."""


    v_flows = False
    for line in (repo / KATALOG_MAESTRO).read_text(
            encoding='utf-8').splitlines():
        s = line.strip()
        if not v_flows:
            v_flows = s == 'flows:'
            continue
        if not s.startswith('- '):
            break
        znach = s[2:].strip().strip("'\"")
        if znach == iskljuchenie:
            return True
    return False


def sud_flow(shagi, snimki):
    otkazy = []
    poz = {}
    for i, (k, a) in enumerate(shagi):
        if k == 'takeScreenshot':
            poz.setdefault(a, []).append(i)
    for s in snimki:
        sp = poz.get(s, [])
        if not sp:
            otkazy.append(('SNIMOK_BEZ_SHAGA', s))
        elif len(sp) > 1:
            otkazy.append(('SNIMOK_NEODNOZNACHEN', s))
    if not shagi or shagi[0][0] != 'launchApp' or sum(
            k == 'launchApp' for k, _ in shagi) != 1 or any(
                k in ('openLink', 'startApp') for k, _ in shagi):
        otkazy.append(('FLOW_BEZ_ZAPUSKA', 'launchApp'))
    granica = -1
    for s in snimki:
        sp = poz.get(s, [])
        if not sp:
            continue
        i = sp[0]
        blok_shagov = shagi[granica + 1:i]
        blok = [k for k, _ in blok_shagov]
        if granica >= 0 and not any(k in PEREHODY for k in blok):
            otkazy.append(('FLOW_BEZ_PEREHODA', s))
        if 'assertVisible' not in blok:
            otkazy.append(('FLOW_BEZ_DOSTIZHENIJA', s))
        if s not in SELEKTOR_KADRA or not any(
                k == 'assertVisible' and id_iz(a) == SELEKTOR_KADRA[s]
                for k, a in blok_shagov):
            otkazy.append(('SELEKTOR_NE_KADRA', s))
        granica = i

    def ordered(items):
        at = -1
        for kind, val in items:
            at = next((i for i in range(at + 1, len(shagi))
                       if shagi[i][0] == kind and
                       (id_iz(shagi[i][1]) if kind in ('tapOn', 'assertVisible',
                                                       'assertNotVisible') else
                        shagi[i][1]) == val), -1)
            if at < 0:
                return False
        return True

    first = snimki[0]
    # Путь допуска (118): production пуск через First-Run/demo/Erstinformation
    # к Start; кадры Start — только после наблюдения СОСТАВА вкладок.
    if not ordered([('launchApp', ''), ('assertVisible', 'first-run-continue'),
                    ('tapOn', 'first-run-continue'),
                    ('assertVisible', 'auth-demo-entry'),
                    ('tapOn', 'auth-demo-entry'),
                    ('assertVisible', 'erstinfo_gate_current'),
                    ('tapOn', 'erstinfo_continue_start')] +
                   [('assertVisible', t) for t in (
                       'start_tabs', 'start_tab_start', 'start_tab_vorgaenge',
                       'start_tab_schutz', 'start_tab_post')] +
                   [('assertVisible', SELEKTOR_KADRA[first]),
                    ('takeScreenshot', first)]):
        otkazy.append(('FLOW_BEZ_DOPUSKA', first))
    return otkazy


def selektory(shagi):
    out = []
    for k, a in shagi:
        if k in ('tapOn', 'assertVisible', 'inputText'):
            i = id_iz(a)
            if i:
                out.append(i)
    return out


RASSHIRENIJA_KODA = ('.tsx', '.jsx', '.js')
NE_EKRAN_KATALOGI = frozenset(('__tests__', '__mocks__', '__snapshots__'))
NE_EKRAN_IMENA = ('.test.', '.spec.', '.stories.')
# Замкнутый алфавит ИМЁН атрибутов-носителей (заявка implementer 138 +
# прецедент 118): testID — честный JSX; buttonTestID — Cta рендерит
# testID={buttonTestID} (auth-parts.tsx), кнопка First-Run продукта
# несёт селектор пропсом. Иные *TestID-имена носителем не являются.
ATTRIBUTY_NOSITELJA = ('buttonTestID', 'testID')


def ekran_kod(p):
    """Файл экранного кода — замкнутый алфавит путей оси H (РЕШЕНИЕ
    арбитра 138-2): не тесты/моки/снапшоты/истории, расширения ТОЛЬКО
    .tsx/.jsx/.js (.d.ts/.snap/.ts/.json/.md/.css отсекает белый список
    расширений — мёртвые метки имени удалены, арбитраж 138-2 п.2)."""
    return (p.suffix in RASSHIRENIJA_KODA
            and not any(metka in p.name for metka in NE_EKRAN_IMENA)
            and not any(katalog in p.parts for katalog in NE_EKRAN_KATALOGI))


def kod_maska(tekst):
    """Маска не-кода пробелами; переводы строк СОХРАНЯЮТСЯ (адресный
    диагноз файл:строка). Состояния лексера: код | // до \\n | /*…*/ |
    '…'/\"…\" (\\ экранирует любой символ, В ТОМ ЧИСЛЕ перевод строки —
    продолжение; обрыв на парной кавычке либо неэкранированном \\n) |
    `…` многострочно (\\ экранирует любой символ, закрытие только на
    НЕэкранированном бэктике; ${…} не разбирается — остаток). Грамматики
    TSX нет: &&/?:/if/достижимость НЕ вычисляются (правило 7, ось H)."""
    out = list(tekst)
    i, n = 0, len(tekst)
    while i < n:
        c = tekst[i]
        if c == '/' and tekst.startswith('//', i):
            while i < n and tekst[i] != '\n':
                out[i] = ' '
                i += 1
        elif c == '/' and tekst.startswith('/*', i):
            sm = tekst[i + 2:].find('*/')
            konec = n if sm < 0 else i + sm + 4
            for k in range(i, konec):
                if tekst[k] != '\n':
                    out[k] = ' '
            i = konec
        elif c in '\'"':
            nachalo = i
            i += 1
            while i < n:
                if tekst[i] == '\\' and i + 1 < n:
                    i += 2
                    continue
                if tekst[i] in (c, '\n'):
                    break
                i += 1
            if i < n and tekst[i] == c:
                i += 1
            for k in range(nachalo, i):
                if tekst[k] != '\n':
                    out[k] = ' '
        elif c == '`':
            nachalo = i
            i += 1
            while i < n:
                if tekst[i] == '\\' and i + 1 < n:
                    i += 2
                    continue
                if tekst[i] == '`':
                    break
                i += 1
            if i < n:
                i += 1
            for k in range(nachalo, i):
                if tekst[k] != '\n':
                    out[k] = ' '
        else:
            i += 1
    return ''.join(out)


def nositel_selektora(repo, derevo, sel):
    """Носитель селектора (ось H, лексика — не достижимость): атрибут ИЗ
    ЗАМКНУТОГО АЛФАВИТА ИМЁН ATTRIBUTY_NOSITELJA (testID — честный JSX;
    buttonTestID — 118: first-run-screen.tsx передаёт Cta, который рендерит
    testID={buttonTestID}, auth-parts.tsx; имена *TestID вне алфавита и
    testid=/TestID= — не носитель: якорь «не-идентификаторный» символ
    перед именем) со значением "sel" (пробелы вокруг '=' и одинарные
    кавычки допустимы), начавшееся в сегменте КОДА (лексер kod_maska)
    файла экранного кода (ekran_kod) дерева-владельца. Комментарии,
    строки, шаблоны и файлы вне экранного кода носителем не являются;
    вычисляемые {...} — не носитель (литеральная грамматика)."""
    obrazec = re.compile(
        r'[A-Za-z0-9_]*[Tt]estID\s*=\s*["\']%s["\']' % re.escape(sel))
    baze = repo / derevo
    if not baze.is_dir():
        return False
    for p in sorted(baze.rglob('*')):
        if not (p.is_file() and ekran_kod(p)):
            continue
        try:
            tekst = p.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue
        maska = kod_maska(tekst)
        for m in obrazec.finditer(tekst):
            if maska[m.start()] != ' ':
                return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', default=None)
    a = ap.parse_args()
    pack, repo = Path(a.pack), Path(a.repo)
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        manifest = json.loads((pack / forma['kadry']).read_text(
            encoding='utf-8'))
        shagi, uslovnye = shagi_flow(repo / forma['e2e_scenarij'])
    except (OSError, ValueError, KeyError) as e:
        print('PROVERKA_NECHITAEM: %r' % e, file=sys.stderr)
        return 2
    kadry = manifest['kadry']
    snimki = list(dict.fromkeys(k['snimok'] for k in kadry))
    otkazy = sud_flow(shagi, snimki)
    for u in uslovnye:
        otkazy.append(('FLOW_USLOVNYJ_SHAG', u))
    # appId флоу адресует пакет продукта (урок 118), не литерал батареи.
    appid = appid_flow(repo / forma['e2e_scenarij'])
    paket = paket_produkta(repo)
    if appid != paket:
        otkazy.append(('APPID_NE_PAKETA', '%s != %s' % (appid, paket)))
    # Конфиг каталога Maestro: исключение флоу пачки обязано стоять в flows.
    iskljuchenie_pachki = '!' + forma['e2e_scenarij'].split('/')[-1]
    if not iskljuchenie_pachki_v_confige(repo, iskljuchenie_pachki):
        otkazy.append(('CONFIG_BEZ_ISKLJUCHENIJA',
                       '%s без %s' % (KATALOG_MAESTRO, iskljuchenie_pachki)))
    # Состав манифеста: ровно 8 кадров — 4 состояния × dark/light.
    fakt = sorted((k.get('snimok'), k.get('tema')) for k in kadry)
    if fakt != OZHIDAEMYE_KADRY:
        otkazy.append(('MANIFEST_NE_8_KADROV', str(len(kadry))))
    # Носители селекторов — только в деревьях-владельцах (VLADELTCY;
    # допуск 135/118 — first-run-continue: ОДНО ИЗ ДВУХ деревьев): чужие
    # деревья не сканируются, совпадение там не носитель.
    for s in sorted(set(selektory(shagi))):
        if not any(nositel_selektora(repo, d, s)
                   for d in ISTOCHNIKI_EKRANA):
            otkazy.append(('SELEKTOR_BEZ_EKRANA', s))
    karta = {(k['snimok'], k['tema']): k for k in kadry}
    for p in sorted((repo / forma['kadry_dir']).rglob('*.png')):
        tema = p.relative_to(repo / forma['kadry_dir']).parts[0]
        z = karta.get((p.stem, tema))
        if z and (repo / z['maket']).is_file() \
                and sha(p) == sha(repo / z['maket']):
            otkazy.append(('KADR_BYTE_KOPIJA_MAKETA', z['id']))
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
