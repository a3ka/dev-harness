#!/usr/bin/env python3
"""147 v5 (слово владельца 2026-11-12 ~12:45 UTC, вариант А; испр. Б-1
вердикта contracts-147-v5-vyzov1-fail): клетки регистрации экрана в продуктовом
CI — состав пачки / запись карты / работник лекала 143/2.

Работник/агрегаты/выбор судятся СТРУКТУРНЫМ разбором YAML (прецедент —
замороженная батарея 143 probe.py): ОПЕРАЦИЯ, а не подстрока — комментарий
в теле шага или инертное место (строка выхода как env-ключ шага вместо
outputs селектора) клетку НЕ удовлетворяет. Структурные якоря:

  RABOTNIK_BEZ_VYBORA      ключ jobs.select-screens.outputs['e2e-gespraech-vhod']
  RABOTNIK_VNE_AGGREGATOV  needs (по job'ам, кроме себя) несёт имя ≥ 2
  RABOTNIK_BEZ_VALIDATORA  АКТИВНАЯ (не-комментарная) команда run-шага
                           содержит ekran_shablon.py с пачкой 147
  RABOTNIK_BEZ_PINA        шаг checkout: with.repository + with.ref пина
  RABOTNIK_BEZ_KADROV      шаг upload-artifact: with.path +
                           with['if-no-files-found'] == 'error'

Три клетки, каждая краснеет ИМЕНОВАННОЙ причиной на СВОЁМ входе (Н-39: стаб
привязан к ветви кода, где его дефект наблюдаем; ветви — ниже, по одной на
причину):
  состав пачки  PACHKA_NEPOLNAJA / PACHKA_LISHNEE   (ровно 10 файлов)
  запись карты  ZAPIS_KARTY_NET / ZAPIS_KARTY_POLJA (id gespraech-vhod, поля)
  работник      RABOTNIKA_NET / RABOTNIK_BEZ_VYBORA / RABOTNIK_VNE_AGGREGATOV /
                RABOTNIK_BEZ_VALIDATORA / RABOTNIK_BEZ_PINA / RABOTNIK_BEZ_KADROV

Режимы:
  --model        контроль входов: встроенная честная модель зелена (rc 0)
  --stabs        контроль + матрица из 13 обманных стабов: каждый красен СВОЕЙ
                 причиной на СВОЁМ входе, честная модель зелена (rc 0); три
                 стаба — инертные места литеральных якорей (MA-2 валидатор в
                 комментарии, MA-2b страж артефакта в комментарии, MA-1b выход
                 выбора env-ключом шага) — красны ТОЛЬКО структурным разбором
  --repo R       судить живой продукт R (rc 0 — регистрация честна)
Без режима — rc 2 NOT_IMPLEMENTED (мёртвый вызов не зелень).
Коды: 0 зелено; 1 красно (последняя строка до stderr-причины — PRICHINA …);
2 нет предпосылки (нет PyYAML, несуществующий каталог --repo).

ЕДИНЫЙ источник ожиданий — константы ниже (побайтово те же значения несёт
контракт 147 v5 §И-11; переизобретение в потребителях запрещено).
"""
import argparse
import json
import shutil
import sys
import tempfile
from pathlib import Path

try:
    import yaml  # python3-pyyaml — та же предпосылка, что у семей 143/149 в CI
except ImportError:
    yaml = None

PACHKA = 'mobile/e2e-gespraech-vhod'
FAJLY_PACHKI = [
    'batareja/red_ekrana.sh',
    'dvizhenie.mjs',
    'e2e.sh',
    'ekran.json',
    'kadry.json',
    'kadry_profil.json',
    'katalog_kopii.json',
    'kontrakt.md',
    'prokhod.sh',
    'spec_api.json',
]
KARTA = 'mobile/ci-screens.json'
ZAPIS = {
    'id': 'gespraech-vhod',
    'kontrakty': ['147'],
    'job': 'e2e-gespraech-vhod',
    'pack': 'mobile/e2e-gespraech-vhod/',
    'flows': ['mobile/.maestro/gespraech-vhod.yaml',
              'mobile/.maestro/gespraech-vhod-393.yaml'],
    'child_flows': ['mobile/.maestro/gespraech-prokhod.yaml'],
    'puti_min': ['mobile/src/features/conversation/',
                 'mobile/src/bootstrap/tab-shell.tsx',
                 'mobile/src/mocks/'],
    'h_checkout': ['.harness147'],
    'output_namespace': 'mobile/maestro-out-gespraech',
}
STATUSY = ('in-development', 'approved')
WORKFLOW = '.github/workflows/mobile.yml'
RABOTNIK = 'e2e-gespraech-vhod'
SELEKTOR = 'select-screens'
VYHOD_KLJUCH = 'e2e-gespraech-vhod'
VYHOD_ZNACHENIE = '${{ steps.vybor.outputs.e2e-gespraech-vhod }}'
VYBOR = f'{VYHOD_KLJUCH}: {VYHOD_ZNACHENIE}'  # текстовый якорь мутаций стабов
VALIDATOR = "ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/'"  # якорь мутаций
VAL_SKRIPT = 'ekran_shablon.py'
VAL_PACHKA = 'mobile/e2e-gespraech-vhod/'
SHAG_CHECKOUT = 'actions/checkout'
REPOSITORIJ = 'a3ka/dev-harness'
PIN_HARNESSA = 'd01c9414ef792ea1382750c825759ab51a418ff4'
PIN_STROKA = f'ref: {PIN_HARNESSA}'  # текстовый якорь мутаций стабов
SHAG_VYGRUZKI = 'actions/upload-artifact'
KADRY_PUT = 'mobile/maestro-out-gespraech'
KADRY_STRAZH = 'error'  # значение with['if-no-files-found']
KADRY_STRAZH_STROKA = 'if-no-files-found: error'  # текстовый якорь мутаций
AGREGATY = 2  # android-e2e и mobile-regression-signal (лекало 143/2)


class Krasno(Exception):
    def __init__(self, prichina, detal=''):
        super().__init__(f'{prichina}: {detal}' if detal else prichina)
        self.prichina = prichina


def sudi_pachku(root):
    pack = root / PACHKA
    if not pack.is_dir():
        raise Krasno('PACHKA_NEPOLNAJA', f'нет каталога {PACHKA}')
    est = sorted(str(p.relative_to(pack)) for p in pack.rglob('*') if p.is_file())
    nuzhno = sorted(FAJLY_PACHKI)
    net = [f for f in nuzhno if f not in est]
    if net:
        raise Krasno('PACHKA_NEPOLNAJA', 'нет ' + ', '.join(net))
    lishnie = [f for f in est if f not in nuzhno]
    if lishnie:
        raise Krasno('PACHKA_LISHNEE', ', '.join(lishnie))


def sudi_kartu(root):
    kart = root / KARTA
    if not kart.is_file():
        raise Krasno('ZAPIS_KARTY_NET', f'нет файла {KARTA}')
    try:
        data = json.loads(kart.read_text())
    except ValueError as e:
        raise Krasno('ZAPIS_KARTY_NET', f'{KARTA} не JSON: {e}')
    zapis = None
    for spisok in data.values():
        if isinstance(spisok, list):
            for item in spisok:
                if isinstance(item, dict) and item.get('id') == ZAPIS['id']:
                    zapis = item
    if zapis is None:
        raise Krasno('ZAPIS_KARTY_NET', f"записи id={ZAPIS['id']} нет")
    for pole, ozhidanie in ZAPIS.items():
        if pole == 'puti_min':
            puti = zapis.get('puti')
            if not isinstance(puti, list):
                raise Krasno('ZAPIS_KARTY_POLJA', 'puti: нет списка')
            netu = [p for p in ozhidanie if p not in puti]
            if netu:
                raise Krasno('ZAPIS_KARTY_POLJA',
                             'puti нет ' + ', '.join(netu))
        elif zapis.get(pole) != ozhidanie:
            raise Krasno('ZAPIS_KARTY_POLJA',
                         f"{pole}: {zapis.get(pole)!r} != {ozhidanie!r}")
    if zapis.get('status') not in STATUSY:
        raise Krasno('ZAPIS_KARTY_POLJA',
                     f"status: {zapis.get('status')!r} не в {STATUSY}")


# ── структурный разбор работника (Б-1: операция, не подстрока) ────────────────
def razbor_workflow(root):
    """jobs из YAML-разбора mobile.yml; битый YAML — работника нет."""
    wf = root / WORKFLOW
    if not wf.is_file():
        raise Krasno('RABOTNIKA_NET', f'нет файла {WORKFLOW}')
    try:
        dok = yaml.safe_load(wf.read_text())
    except yaml.YAMLError as e:
        raise Krasno('RABOTNIKA_NET', f'{WORKFLOW} не парсится как YAML: {e}')
    if not isinstance(dok, dict) or not isinstance(dok.get('jobs'), dict):
        raise Krasno('RABOTNIKA_NET', f'{WORKFLOW} без словаря jobs')
    return dok['jobs']


def shagi_rabotnika(joby):
    rab = joby.get(RABOTNIK)
    if not isinstance(rab, dict):
        raise Krasno('RABOTNIKA_NET', f'job {RABOTNIK} в {WORKFLOW} нет')
    return rab.get('steps') or []


def sudi_vybor(joby):
    """Выход выбора — СТРУКТУРНОЕ поле jobs.select-screens.outputs (env-ключ
    шага или echo в run работника объявлением выхода не являются)."""
    selektor = joby.get(SELEKTOR)
    vyhody = selektor.get('outputs') if isinstance(selektor, dict) else None
    zn = vyhody.get(VYHOD_KLJUCH) if isinstance(vyhody, dict) else None
    if zn != VYHOD_ZNACHENIE:
        raise Krasno('RABOTNIK_BEZ_VYBORA',
                     f'{SELEKTOR}.outputs[{VYHOD_KLJUCH!r}] = {zn!r},'
                     f' ожидалось {VYHOD_ZNACHENIE!r}')


def sudi_agregaty(joby):
    """Имя в needs ОБОИХ агрегатов: считаются JOB'ы (кроме самого работника),
    чей needs несёт имя, — структурно, не строки «needs:»."""
    schetchik = 0
    for imja, telo in joby.items():
        if imja == RABOTNIK or not isinstance(telo, dict):
            continue
        nzh = telo.get('needs')
        if nzh is None:
            continue
        if isinstance(nzh, str):
            nzh = [nzh]
        if RABOTNIK in nzh:
            schetchik += 1
    if schetchik < AGREGATY:
        raise Krasno('RABOTNIK_VNE_AGGREGATOV',
                     f'needs с {RABOTNIK}: {schetchik} из {AGREGATY}')


def aktivnye_komandy(run_tekst):
    """Активные команды shell-скрипта шага: комментарии выброшены, строки,
    продолженные через '\\', склеены в одну команду."""
    komandy, nakop = [], ''
    for stroka in run_tekst.splitlines():
        chast = stroka.lstrip() if nakop else stroka.strip()
        if not nakop and (not chast or chast.startswith('#')):
            continue
        nakop = f'{nakop} {chast}'.strip()
        if nakop.endswith('\\'):
            nakop = nakop[:-1].rstrip()
            continue
        komandy.append(nakop)
        nakop = ''
    if nakop:
        komandy.append(nakop)
    return komandy


def sudi_validatora(shagi):
    """Вызов валидатора — АКТИВНАЯ команда run-шага работника (закомментированный
    вызов подстрокой в теле остаётся, операцией не становится)."""
    for shag in shagi:
        if not isinstance(shag, dict) or not isinstance(shag.get('run'), str):
            continue
        for komanda in aktivnye_komandy(shag['run']):
            if VAL_SKRIPT in komanda and VAL_PACHKA in komanda:
                return
    raise Krasno('RABOTNIK_BEZ_VALIDATORA',
                 f'активного вызова «…{VALIDATOR}…» в run-шагах {RABOTNIK} нет')


def sudi_pina(shagi):
    """H-checkout — структурные поля шага checkout: with.repository и
    with.ref пина (упоминание репозитория в комментарии не считается)."""
    for shag in shagi:
        if not isinstance(shag, dict):
            continue
        with_ = shag.get('with')
        if str(shag.get('uses') or '').startswith(SHAG_CHECKOUT) \
                and isinstance(with_, dict) \
                and with_.get('repository') == REPOSITORIJ \
                and with_.get('ref') == PIN_HARNESSA:
            return
    raise Krasno('RABOTNIK_BEZ_PINA',
                 f'шага checkout ({REPOSITORIJ} @ {PIN_HARNESSA}) нет')


def sudi_kadry(shagi):
    """Артефакт кадров — шаг upload-artifact: with.path и
    with['if-no-files-found'] == 'error' (строка-комментарий стражом не
    является)."""
    for shag in shagi:
        if not isinstance(shag, dict):
            continue
        with_ = shag.get('with')
        if str(shag.get('uses') or '').startswith(SHAG_VYGRUZKI) \
                and isinstance(with_, dict) \
                and with_.get('path') == KADRY_PUT \
                and with_.get('if-no-files-found') == KADRY_STRAZH:
            return
    raise Krasno('RABOTNIK_BEZ_KADROV',
                 f'шага upload-artifact ({KADRY_PUT} + '
                 f'{KADRY_STRAZH_STROKA}) нет')


def sudi_rabotnika(root):
    joby = razbor_workflow(root)
    shagi = shagi_rabotnika(joby)
    sudi_vybor(joby)
    sudi_agregaty(joby)
    sudi_validatora(shagi)
    sudi_pina(shagi)
    sudi_kadry(shagi)


def sudi(root):
    sudi_pachku(root)
    sudi_kartu(root)
    sudi_rabotnika(root)


# ── честная встроенная модель (контроль входов; содержимое файлов не судится
#    этими клетками — грамматику пачки судит валидатор 132 v3 на работнике) ──
MODEL_YML = """\
jobs:
  select-screens:
    outputs:
      e2e-gespraech-vhod: ${{ steps.vybor.outputs.e2e-gespraech-vhod }}
  build-apk:
    outputs:
      apk_sha256: primer
  e2e-gespraech-vhod:
    needs: [select-screens, build-apk]
    if: needs.select-screens.outputs['e2e-gespraech-vhod'] == 'true'
    runs-on: [self-hosted, linux, x64, kvm, complior]
    timeout-minutes: 40
    steps:
      - uses: actions/checkout@v7
      - name: 'Checkout H пачки экрана (.harness147)'
        uses: actions/checkout@v7
        with:
          repository: a3ka/dev-harness
          ref: d01c9414ef792ea1382750c825759ab51a418ff4
          path: .harness147
          persist-credentials: false
      - name: 'Экранная пачка: валидатор 132 v3 + Maestro'
        run: |
          python3 .harness147/scripts/ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/' --repo . --harness '.harness147'
      - name: 'Артефакты экрана (кадры, отчёт)'
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: maestro-gespraech-vhod-${{ github.run_id }}
          path: mobile/maestro-out-gespraech
          if-no-files-found: error
          retention-days: 14
  android-e2e:
    needs: [select-screens, quality, build-apk, e2e-gespraech-vhod]
    runs-on: [self-hosted, linux, x64, complior]
  mobile-regression-signal:
    needs: [select-screens, quality, build-apk, e2e-gespraech-vhod]
    runs-on: [self-hosted, linux, x64, complior]
"""


def postroj_model(kuda):
    kuda = Path(kuda)
    for f in FAJLY_PACHKI:
        p = kuda / PACHKA / f
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('# модель состава (содержимое судит валидатор на работнике)\n')
    zapis = {k: v for k, v in ZAPIS.items() if k != 'puti_min'}
    zapis['status'] = 'in-development'
    zapis['puti'] = list(ZAPIS['puti_min'])
    (kuda / KARTA).parent.mkdir(parents=True, exist_ok=True)
    (kuda / KARTA).write_text(json.dumps(
        {'schema': 1, 'ekrany': [zapis], 'integracija': {}}, indent=2))
    wf = kuda / WORKFLOW
    wf.parent.mkdir(parents=True, exist_ok=True)
    wf.write_text(MODEL_YML)
    return kuda


# ── обманные стабы: мутация ОДНОГО аспекта честной модели; ожидаемая причина —
#    ровно имя ветви, где этот дефект наблюдаем первым (Н-39) ──────────────────
def _bez_zapisi(root):
    kart = root / KARTA
    data = json.loads(kart.read_text())
    data['ekrany'] = []
    kart.write_text(json.dumps(data, indent=2))


def _chuzhoe_pole(root):
    kart = root / KARTA
    data = json.loads(kart.read_text())
    data['ekrany'][0]['job'] = 'e2e-gespraech-tekst'
    kart.write_text(json.dumps(data, indent=2))


def _udal_stroki(root, predikat):
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    wf.write_text('\n'.join(l for l in stroki if not predikat(l)) + '\n')


def _udal_job(root):
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    nachalo = konec = None
    for i, l in enumerate(stroki):
        if l.startswith(f'  {RABOTNIK}:'):
            nachalo = i
            for j in range(i + 1, len(stroki)):
                if stroki[j].strip() and not stroki[j].startswith('    ') \
                        and not stroki[j].startswith('  #'):
                    konec = j
                    break
            konec = konec if konec is not None else len(stroki)
            break
    if nachalo is None:
        return
    wf.write_text('\n'.join(stroki[:nachalo] + stroki[konec:]) + '\n')


def _zameni(root, staraja, novaja):
    wf = root / WORKFLOW
    wf.write_text(wf.read_text().replace(staraja, novaja))


def _zakommentirj(root, podstroka):
    """Инертное место литерального якоря: строка с якорем становится
    комментарием — подстрока в файле ОСТАЁТСЯ, операция исчезает."""
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    novye, najdeno = [], False
    for l in stroki:
        if podstroka in l and not l.strip().startswith('#'):
            otstup = l[:len(l) - len(l.lstrip())]
            novye.append(f'{otstup}# {l.lstrip()}')
            najdeno = True
        else:
            novye.append(l)
    assert najdeno, f'якорь комментария не найден: {podstroka}'
    wf.write_text('\n'.join(novye) + '\n')


def _vynes_vybor_v_env(root):
    """MA-1b: строка выхода — env-ключ шага работника (валидный GHA,
    рендерится в ''); литеральная строка в файле остаётся, в outputs
    селектора ключа нет."""
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    novye = [l for l in stroki if l.strip() != VYBOR]
    vstavka_posle = None
    for i, l in enumerate(novye):
        if l.startswith(f'  {RABOTNIK}:'):
            for j in range(i + 1, len(novye)):
                if novye[j].strip() == '- uses: actions/checkout@v7':
                    vstavka_posle = j
                    break
            break
    assert vstavka_posle is not None, 'первый шаг работника не найден'
    env_blok = ['        env:', f'          {VYBOR}']
    novye = novye[:vstavka_posle + 1] + env_blok + novye[vstavka_posle + 1:]
    wf.write_text('\n'.join(novye) + '\n')


STABY = [
    ('пачка без ekran.json', 'PACHKA_NEPOLNAJA',
     lambda r: (r / PACHKA / 'ekran.json').unlink()),
    ('лишний файл в пачке', 'PACHKA_LISHNEE',
     lambda r: (r / PACHKA / 'chuzhoj.log').write_text('x')),
    ('карта без записи gespraech-vhod', 'ZAPIS_KARTY_NET', _bez_zapisi),
    ('запись с чужим job', 'ZAPIS_KARTY_POLJA', _chuzhoe_pole),
    ('workflow без job e2e-gespraech-vhod', 'RABOTNIKA_NET', _udal_job),
    ('select-screens без output выбора', 'RABOTNIK_BEZ_VYBORA',
     lambda r: _udal_stroki(r, lambda l: l.strip() == VYBOR)),
    ('выход выбора — env-ключ шага, не outputs селектора (MA-1b)',
     'RABOTNIK_BEZ_VYBORA', _vynes_vybor_v_env),
    ('имя вне needs агрегатов', 'RABOTNIK_VNE_AGGREGATOV',
     lambda r: _zameni(r, ', e2e-gespraech-vhod]', ']')),
    ('работник без валидатора', 'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VALIDATOR, 'maestro test mobile/.maestro/gespraech-vhod.yaml')),
    ('вызов валидатора закомментирован, подстрока в теле (MA-2)',
     'RABOTNIK_BEZ_VALIDATORA', lambda r: _zakommentirj(r, VAL_SKRIPT)),
    ('работник без пина H-checkout', 'RABOTNIK_BEZ_PINA',
     lambda r: _udal_stroki(r, lambda l: l.strip() == PIN_STROKA)),
    ('работник без артефакта кадров', 'RABOTNIK_BEZ_KADROV',
     lambda r: _udal_stroki(r, lambda l: l.strip() in
                            (f'path: {KADRY_PUT}', KADRY_STRAZH_STROKA))),
    ('страж артефакта в комментарии, подстрока в теле (MA-2b)',
     'RABOTNIK_BEZ_KADROV', lambda r: _zakommentirj(r, KADRY_STRAZH_STROKA)),
]


def main():
    if yaml is None:
        print('NOT_IMPLEMENTED: нет PyYAML (python3-pyyaml) — '
              'структурный разбор workflow невозможен')
        return 2
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    parser.add_argument('--repo')
    args = parser.parse_args()

    bazovyj = None
    if args.model or args.stabs:
        bazovyj = postroj_model(tempfile.mkdtemp(prefix='red_ci_147_model_'))
        try:
            sudi(bazovyj)
        except Krasno as e:
            print(f'PRICHINA {e}')
            print('MODEL_KRASNA: встроенная модель обязана быть зелёной')
            return 1
        print('MODEL_OK')
        if not args.stabs:
            return 0
        vse_krasny = True
        for i, (opisanie, prichina, mutacija) in enumerate(STABY, 1):
            klon = Path(tempfile.mkdtemp(prefix=f'red_ci_147_stab{i}_'))
            shutil.copytree(bazovyj, klon, dirs_exist_ok=True)
            try:
                mutacija(klon)
                sudi(klon)
                print(f'STAB {i}/{len(STABY)} {opisanie}: ЗЕЛЁНЫЙ — барьер слеп')
                vse_krasny = False
            except Krasno as e:
                if e.prichina == prichina:
                    print(f'STAB {i}/{len(STABY)} {opisanie}: PRICHINA {e}')
                else:
                    print(f'STAB {i}/{len(STABY)} {opisanie}: '
                          f'ожидалась {prichina}, получена {e.prichina}')
                    vse_krasny = False
            finally:
                shutil.rmtree(klon, ignore_errors=True)
        shutil.rmtree(bazovyj, ignore_errors=True)
        return 0 if vse_krasny else 1

    if args.repo:
        root = Path(args.repo)
        if not root.is_dir():
            print('NOT_IMPLEMENTED: каталог репо не найден')
            return 2
        try:
            sudi(root)
        except Krasno as e:
            print(f'PRICHINA {e}')
            return 1
        print('REGISTRACIJA_OK')
        return 0

    print('NOT_IMPLEMENTED: укажите --model, --stabs или --repo <R>')
    return 2


if __name__ == '__main__':
    sys.exit(main())
