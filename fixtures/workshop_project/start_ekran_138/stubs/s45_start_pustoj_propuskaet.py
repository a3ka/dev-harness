# стаб 138 (s45_start_pustoj_propuskaet): состав вкладок судится одним узлом start_tabs, вкладки — не селекторы
#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 138, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132 (§НЕ ЗАЩИЩАЕТ контракта). Судит свойства (уроки 118 применены
# с первой редакции):
#   1) флоу: единственный запуск production (launchApp, никаких
#      openLink/startApp); перед каждым кадром — переход и assert-селектор
#      СВОЕГО состояния; каждый snimok манифеста — ровно один раз;
#   2) ПУТЬ ДОПУСКА (граница с 118): First-Run → first-run-continue →
#      demo-вход auth-demo-entry → Erstinformation gate current →
#      erstinfo_continue_start → состав Start ПО ВКЛАДКАМ (start_tabs и
#      КАЖДАЯ из четырёх своим testID — пустой start_tabs не Start);
#   3) appId флоу == expo.android.package из mobile/app.json
#      (дефект батареи 118: чужой demo-пакет ронял Maestro);
#   4) конфиг каталога mobile/.maestro/config.yaml несёт исключение флоу
#      пачки своей строкой в flows (общий прогон каталога 995 не должен
#      гонять экранный флоу: порядок флоу каталога недетерминирован);
#   5) каждый селектор флоя имеет носитель testID в коде экрана (свои —
#      mobile/src/features/start/**, путь допуска — onboarding/auth/app);
#   6) манифест — ровно 8 кадров: 4 состояния × dark/light;
#   7) кадр, байт-идентичный макету, — НЕ скриншот (сравнение sha256).
# В CI продукта пускается ПОСЛЕ валидатора 132 (тот вызывает Maestro),
# БЕЗ промежуточной правки кадров. rc: 0 — признаки без отказов;
# 1 — PRICHINA по каждому отказу; 2 — вход нечитаем (PROVERKA_NECHITAEM).
import argparse
import hashlib
import json
import sys
from pathlib import Path

PEREHODY = ('tapOn', 'inputText', 'pressKey', 'swipe')
ZAPUSKI = ('launchApp',)
ISTOCHNIKI_EKRANA = ('mobile/src/features/start', 'mobile/src/features/onboarding',
                     'mobile/src/features/auth', 'mobile/src/app')
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
    out = []
    for line in path.read_text(encoding='utf-8').splitlines():
        s = line.strip()
        if not s.startswith('- '):
            continue
        step = s[2:]
        k, sep, a = step.partition(':')
        out.append((k.strip(), a.strip() if sep else ''))
    return out


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
        if line.strip() == '---':
            break
        if line.startswith('appId:'):
            return line.partition('appId:')[2].strip()
    return None


def iskljuchenie_pachki_v_confige(repo, iskljuchenie):
    """Исключение флоу пачки в списке flows конфига каталога Maestro.
    Судится ТОЛЬКО флоу пачки (чужие исключения не требуются и не
    запрещаются). Сравнение литеральное: значение элемента списка после
    '- ' со снятыми кавычками самостоятельной строкой, не подстрока."""
    p = repo / KATALOG_MAESTRO
    if not p.is_file():
        return False
    v_flows = False
    for line in p.read_text(encoding='utf-8').splitlines():
        s = line.strip()
        if s == 'flows:':
            v_flows = True
            continue
        if v_flows:
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
        shagi = shagi_flow(repo / forma['e2e_scenarij'])
    except (OSError, ValueError, KeyError) as e:
        print('PROVERKA_NECHITAEM: %r' % e, file=sys.stderr)
        return 2
    kadry = manifest['kadry']
    snimki = list(dict.fromkeys(k['snimok'] for k in kadry))
    otkazy = sud_flow(shagi, snimki)
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
    istochniki = []
    for d in ISTOCHNIKI_EKRANA:
        baze = repo / d
        if baze.is_dir():
            istochniki.extend(p for p in baze.rglob('*') if p.is_file())
    teksty = []
    for p in istochniki:
        try:
            teksty.append(p.read_text(encoding='utf-8'))
        except (OSError, UnicodeDecodeError):
            pass
    for s in sorted(set(selektory(shagi))):
        if s.startswith('start_tab_'):
            continue
        if not any('testID="%s"' % s in line
                   for t in teksty for line in t.splitlines()
                   if not line.lstrip().startswith(('//', '/*', '*', '#'))):
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
