#!/usr/bin/env python3
# Батарея контракта 147 gespraech-vhod-menu (guard-канал §ПРОВОДКА).
# Субъекты: (1) живой валидатор 132 v3 scripts/ekran_shablon.py против
# эталона model/ekran_shablon.py (пин байтов) на мирах пачки; (2) машина
# вход-меню (модель model/menu-machine.ts; в продукте —
# mobile/src/features/conversation/menu-machine.ts) против пиннованной
# спеки дизайнера (раннер model/dvizhenie-runner.mjs); (3) пачка и канон
# в продукте (--repo). Оракул — пины source.json (проверяются ДО любого
# субъекта) и ожидания, вычисленные ЭТАЛОНОМ на том же входе ДО субъекта
# (правило 8); каждая красная клетка несёт РОВНО одно имя причины.
#
# Режимы (argv):
#   (без флага)   судится живое дерево харнесса: валидатор scripts/, в
#                 продукте субъекта нет — клетки s-*/m-* красны поимённо
#                 (SUBJECT_ABSENT); клетки a-* красны, пока живой скрипт
#                 не равен эталону v3 (до пачки implementer 146)
#   --model       субъект = эталон (контроль входов)
#   --stabs       контроль + матрица обманных стабов (SVJAZI N, живых 0)
#   --repo R      судится живой продукт R (машина/канон/пачка)
#   --oracle-tamper  порча каждого носителя по очереди в одноразовой
#                 копии зоны — ORACLE_TAMPERED rc 2 ДО клеток
#   --piny-only   (служебный) только проверка пинов оракула
#   --seed N      seed сеяных входов (право судьи — перезапуск)
#
# Коды возврата: 0 — зелено; 1 — красная клетка/живой стаб/нет субъекта;
# 2 — ORACLE_TAMPERED, рассинхрон реестра, нечем проверять.
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import hashlib

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

PEREHODY = ['GA-T28', 'GA-T29', 'GA-T30', 'GA-T31', 'GA-T33', 'GA-T35']
PRAVILA_MASHINY = ['plan-open-t28', 'sprechen-pervym', 'menja-k-300',
                   'znak-morf-250', 'press-long-500', 'plan-close-t31',
                   'ud-bez-poljota']


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
    return src


# ожидаемое имя причины каждой красной клетки оси A (сверяется с фактом
# эталона ДО субъекта; расхождение — дефект оракула, rc 2)
OZHIDAEMYE_PRICHINY = {
    'shablon2-s-ga': 'DVIZHENIE_OTSVTSTVUET',
    'ekrany-ne-polny-ga-01': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-15': 'EKRANY_NE_POLNY',
    'ekrany-ne-polny-ga-16': 'EKRANY_NE_POLNY',
    'ekran-vne-manifesta': 'EKRAN_VNE_MANIFESTA',
    'ekran-bez-kadrov': 'EKRAN_BEZ_KADROV',
    'perehody-ne-polny-t28': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t29': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t30': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t31': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t33': 'PEREHODY_NE_POLNY',
    'perehody-ne-polny-t35': 'PEREHODY_NE_POLNY',
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
        os.path.join(repo, 'docs', 'ux', '03_Mobility_Slice1', 'ds'),
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
    for prof in ('390x844', '393x852'):
        for f in ('GA-01', 'GA-01-Hell', 'GA-15', 'GA-15-Hell',
                  'GA-16', 'GA-16-Hell'):
            shutil.copy(os.path.join(NOS, 'd24', 'maket',
                                     '%s-%s.png' % (prof, f)),
                        os.path.join(d24, 'pack', 'screens', prof,
                                     f + '.png'))
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
    # стенд-ин e2e: свежие кадры обеих тем и обоих профилей
    kadr = os.path.join(NOS, 'd24', 'kadry')
    telo = ['#!/usr/bin/env bash', 'set -eu',
            'out=mobile/maestro-out-gespraech', 'rm -rf "$out"',
            'mkdir -p "$out"']
    for tema, pary in (
            ('dark', ['gespraech-ga-01-390 gespraech-ga-01',
                      'gespraech-ga-15-390 gespraech-ga-15',
                      'gespraech-ga-16-390 gespraech-ga-16',
                      'gespraech-ga-01-393 gespraech-ga-01-393',
                      'gespraech-ga-15-393 gespraech-ga-15-393',
                      'gespraech-ga-16-393 gespraech-ga-16-393']),
            ('light', ['gespraech-ga-01-hell-390 gespraech-ga-01',
                       'gespraech-ga-15-hell-390 gespraech-ga-15',
                       'gespraech-ga-16-hell-390 gespraech-ga-16',
                       'gespraech-ga-01-hell-393 gespraech-ga-01-393',
                       'gespraech-ga-15-hell-393 gespraech-ga-15-393',
                       'gespraech-ga-16-hell-393 gespraech-ga-16-393'])):
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
            '    name: gespraech-ga-15\n', '')
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
               'cp "%(kadr)s/gespraech-ga-01-390.png" '
               '"$out"/dark/run2/gespraech/takeScreenshot/'
               'gespraech-ga-01.png\n')
        kadr = os.path.join(NOS, 'd24', 'kadry')
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
            '    name: gespraech-ga-15-393\n', '')
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
        shutil.copy(os.path.join(NOS, 'd24', 'kadry',
                                 'gespraech-ga-01-390.png'),
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
    elif '--oracle-tamper' in argv:
        rezhim = 'tamper'
    if '--seed' in argv:
        seed = int(argv[argv.index('--seed') + 1])
    src = vedro()
    if '--piny-only' in argv:
        return 0

    if rezhim == 'tamper':
        prov = 0
        for imja in sorted(src['piny']['nositeli']):
            otn = imja
            vrem = tempfile.mkdtemp(prefix='gespraech147-tamper-')
            zerkalo = os.path.join(vrem, 'zona')
            os.makedirs(zerkalo, exist_ok=True)
            # копия зоны: только файлы оракула (пины/эталоны/раннер/носители)
            for otn2 in set(src['piny']['nositeli']) | {
                    'probe.py', 'source.json'}:
                if os.path.isfile(os.path.join(ZDE, otn2)):
                    dst = os.path.join(zerkalo, otn2)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    shutil.copy(os.path.join(ZDE, otn2), dst)
            for d in ('model', 'stabs'):
                srcdir = os.path.join(ZDE, d)
                if os.path.isdir(srcdir):
                    shutil.copytree(srcdir, os.path.join(zerkalo, d),
                                    dirs_exist_ok=True)
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

    zelen = sum(1 for _, ok, _ in itogi if ok)
    krasn = len(itogi) - zelen
    for idk, ok, pochemu in itogi:
        print('CASE %s %s %s' % (idk, 'ok' if ok else 'KRASNO', pochemu))

    svjazi = 0
    if rezhim == 'stabs':
        for stab, svaz in sorted(src['stab_vhod'].items()):
            put = os.path.join(STABY, src['staby'][stab])
            rc, vyv = zapusk_pravila_mashiny(put, svaz['pravilo'])
            if rc == 0:
                print('STAB %s ZHIV (правило %s зелено на стабе)'
                      % (stab, svaz['pravilo']))
                return 1
            print('STAB %s KRASEN %s' % (stab, svaz['pravilo']))
            svjazi += 1
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
