#!/usr/bin/env python3
# Батарея контракта 147 gespraech-vhod-menu (guard-канал §ПРОВОДКА).
# Субъекты: (1) живой валидатор 132 v3 scripts/ekran_shablon.py против
# эталона model/ekran_shablon.py (пин байтов) на мирах пачки; (2) машина
# вход-меню (модель model/menu-machine.ts; в продукте —
# mobile/src/features/conversation/menu-machine.ts) против пиннованной
# спеки дизайнера (раннер model/dvizhenie-runner.mjs); (3) пачка и канон
# в продукте (--repo); (4) CI-проводка экрана (--repo; И-8): инстанциация
# ЛЕКАЛА screen-job.template.yml (frozen 143/2, копия в nositeli/, пин)
# тремя парными правками — запись карты, output выбора, needs обоих
# агрегатов — плюс вынос пачки общим шагом инвентаризации (блок Crit147
# круг 1: ekran.json={} без проводки проходил 70/70). Оракул — пины
# source.json (проверяются ДО любого субъекта) и ожидания, вычисленные
# ЭТАЛОНОМ на том же входе ДО субъекта (правило 8); каждая красная клетка
# несёт РОВНО одно имя причины.
#
# Режимы (argv):
#   (без флага)   судится живое дерево харнесса: валидатор scripts/, в
#                 продукте субъекта нет — клетки s-*/m-* красны поимённо
#                 (SUBJECT_ABSENT); клетки a-* красны, пока живой скрипт
#                 не равен эталону v3 (до пачки implementer 146)
#   --model       субъект = эталон (контроль входов)
#   --stabs       контроль + матрица обманных стабов (SVJAZI N, живых 0)
#   --repo R      судится живой продукт R (машина/канон/пачка)
#   --a-derevo P C  (служебный) живой рецепт И-8: продукт P -> A-дерево C
#                 (карта+job из лекала+output+needs+пачка) — зелёный
#                 контроль клетки s-lekalo-instanciirovano (W --repo C)
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

PEREHODY = ['GA-T28', 'GA-T29', 'GA-T30', 'GA-T31', 'GA-T33', 'GA-T35']
PRAVILA_MASHINY = ['plan-open-t28', 'sprechen-pervym', 'menja-k-300',
                   'znak-morf-250', 'press-long-500', 'plan-close-t31',
                   'ud-bez-poljota']

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
            set(lek['ekrany']) != {'GA-01', 'GA-15', 'GA-16'} or \
            not isinstance(lek['avd_port'], int) or \
            not isinstance(lek['avd_port_393'], int):
        utechka('source.json.lekalo — грамматика значений')
    for kljuch in ('nositeli/screen-job.template.yml',
                   'nositeli/produkt/mobile-6240f63.yml',
                   'nositeli/produkt/ci-screens-6240f63.json',
                   'stabs/stab_lekalo_obhod_kritika.py'):
        if kljuch not in src['piny']['nositeli']:
            utechka('пин лекала отсутствует: ' + kljuch)
    for stab, svaz in (src.get('stab_vhod') or {}).items():
        if 'kletka' in svaz:
            if svaz['kletka'] != 's-lekalo-instanciirovano' or \
                    'pravilo' in svaz or stab != 'lekalo-obhod-kritika' or \
                    src['staby'].get(stab) != 'stab_lekalo_obhod_kritika.py':
                utechka('привязка стаба лекала ' + stab)
        elif svaz.get('pravilo') not in PRAVILA_MASHINY:
            utechka('привязка стаба ' + stab)
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
    """Норма 132 v2 (И-8): второй AVD профиля 393 ВНУТРИ того же работника
    — расширение экранного шага ПОВЕРХ лекала (канон e2e.sh ждёт
    GESPRAECH_SERIAL/GESPRAECH_SERIAL_393). Обязательства лекала сохранены:
    PORT 5572, один «ПОВТОР: », валидатор из .harness147, оба корневых
    флоу в FLOWS_PACHKI. Форма расширения — рецепт пачки, детали
    реализации (имена/порядок) — реализация implementer."""
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
        r, '  "$AVDM" delete avd -n "$AVD" >/dev/null 2>&1 || true\n',
        '  "$AVDM" delete avd -n "$AVD" >/dev/null 2>&1 || true\n'
        '  adb -s "$SERIAL393" emu kill >/dev/null 2>&1 || true\n'
        '  pkill -f "qemu-system-x86_64.*-avd $AVD393" '
        '>/dev/null 2>&1 || true\n'
        '  "$AVDM" delete avd -n "$AVD393" >/dev/null 2>&1 || true\n')
    r = _zameni_schet(
        r, '\nif ! boot; then diag; exit 1; fi\n',
        '\nif ! boot; then diag; exit 1; fi\n'
        '# второй AVD профиля 393 (норма 132 v2): тот же работник, свой порт\n'
        'AVD_GL="$AVD"; PORT_GL="$PORT"; SERIAL_GL="$SERIAL"\n'
        'AVD="$AVD393"; PORT="$PORT393"; SERIAL="$SERIAL393"\n'
        'if ! boot; then diag; exit 1; fi\n'
        'export GESPRAECH_SERIAL="$SERIAL_GL" GESPRAECH_SERIAL_393="$SERIAL393"\n'
        'AVD="$AVD_GL"; PORT="$PORT_GL"; SERIAL="$SERIAL_GL"\n')
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
    правки И-8 + форма пачки. Клетка обязана быть здесь ЗЕЛЁНОЙ (контроль);
    КРАСНОЙ — на стабе-обходе (stabs/stab_lekalo_obhod_kritika.py)."""
    LE = src['lekalo']
    koren = os.path.join(tmp, 'a-derevo')
    os.makedirs(os.path.join(koren, '.github', 'workflows'))
    os.makedirs(os.path.join(koren, LE['pack'].strip('/')))
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
                os.path.join(koren, LE['pack'].strip('/'), 'ekran.json'))
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


def sud_lekalo(repo, src):
    """s-lekalo-instanciirovano (И-8; блок Crit147 круг 1): в --repo судит
    ТРИ парные правки лекала 143/2 (запись карты, job из лекала по пину
    шаблона/ключам инстанциации, output выбора + needs обоих агрегатов),
    вынос пачки мобильным общим шагом инвентаризации и НЕПУСТУЮ форму
    пачки (ekran.json={} — обход критика). Отсутствие ЛЮБОГО аспекта —
    именованный отказ LEKALO_NE_INSTANCIIROVANO со списком недостающего.
    «Пропускник» ловится стабом lekalo-obhod-kritika (Н-39)."""
    LE = src['lekalo']
    JOB = LE['job_id']
    netu = []

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
    return (not netu, '' if not netu else
            'LEKALO_NE_INSTANCIIROVANO: ' + '; '.join(netu))


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
    print('A-DEREVO %s job=%s kanon=%d mashina=1 ekran.json=forma'
          % (cel, LE['job_id'], len(kanon)))
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
        # стаб лекала (Н-39, блок Crit147 круг 1): обход критика — канон и
        # машина на месте, проводки нет, ekran.json={}. Пара входов одной
        # клеткой: A-дерево рецепта ЗЕЛЁНО (живые байты продукта 6240f630 +
        # три парные правки), стаб-обход КРАСЕН; мутант-«пропускник»
        # (клетка зелена без проверок) ловится здесь — STAB_ZHIV rc 1.
        vrem_a = tempfile.mkdtemp(prefix='gespraech147-lekalo-')
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
