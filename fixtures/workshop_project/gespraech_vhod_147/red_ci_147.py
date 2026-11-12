#!/usr/bin/env python3
"""147 v5 (слово владельца 2026-11-12 ~12:45 UTC, вариант А): клетки регистрации
экрана в продуктовом CI — состав пачки / запись карты / работник лекала 143/2.

Три клетки, каждая краснеет ИМЕНОВАННОЙ причиной на СВОЁМ входе (Н-39: стаб
привязан к ветви кода, где его дефект наблюдаем; ветви — ниже, по одной на
причину):
  состав пачки  PACHKA_NEPOLNAJA / PACHKA_LISHNEE   (ровно 10 файлов)
  запись карты  ZAPIS_KARTY_NET / ZAPIS_KARTY_POLJA (id gespraech-vhod, поля)
  работник      RABOTNIKA_NET / RABOTNIK_BEZ_VYBORA / RABOTNIK_VNE_AGGREGATOV /
                RABOTNIK_BEZ_VALIDATORA / RABOTNIK_BEZ_PINA / RABOTNIK_BEZ_KADROV

Режимы:
  --model        контроль входов: встроенная честная модель зелена (rc 0)
  --stabs        контроль + матрица из 10 обманных стабов: каждый красен СВОЕЙ
                 причиной на СВОЁМ входе, честная модель зелена (rc 0)
  --repo R       судить живой продукт R (rc 0 — регистрация честна)
Без режима — rc 2 NOT_IMPLEMENTED (мёртвый вызов не зелень).
Коды: 0 зелено; 1 красно (последняя строка до stderr-причины — PRICHINA …);
2 нет предпосылки (нет python3-файлов/каталогов, битый JSON вне мутаций).

ЕДИНЫЙ источник ожиданий — константы ниже (побайтово те же значения несёт
контракт 147 v5 §И-11; переизобретение в потребителях запрещено).
"""
import argparse
import json
import shutil
import sys
import tempfile
from pathlib import Path

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
PIN_HARNESSA = 'ref: d01c9414ef792ea1382750c825759ab51a418ff4'
VYBOR = ("e2e-gespraech-vhod: "
         "${{ steps.vybor.outputs.e2e-gespraech-vhod }}")
VALIDATOR = "ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/'"
REPOSITORY = 'repository: a3ka/dev-harness'
KADRY_PUT = 'path: mobile/maestro-out-gespraech'
KADRY_STRAZH = 'if-no-files-found: error'
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


def telo_rabotnika(stroki):
    """Тело job от заголовка '  <RABOTNIK>:' до следующего ключа того же отступа."""
    nachalo = None
    for i, l in enumerate(stroki):
        if l.startswith(f'  {RABOTNIK}:'):
            nachalo = i
            break
    if nachalo is None:
        return None
    telo = []
    for l in stroki[nachalo + 1:]:
        if l.strip() and not l.startswith('    ') and not l.startswith('  #'):
            break
        telo.append(l)
    return telo


def sudi_rabotnika(root):
    wf = root / WORKFLOW
    if not wf.is_file():
        raise Krasno('RABOTNIKA_NET', f'нет файла {WORKFLOW}')
    stroki = wf.read_text().splitlines()
    telo = telo_rabotnika(stroki)
    if telo is None:
        raise Krasno('RABOTNIKA_NET',
                     f'job {RABOTNIK} в {WORKFLOW} нет')
    tekst = '\n'.join(telo)
    # output выбора экрана — в outputs select-screens, судится по всему файлу
    if not any(l.strip() == VYBOR for l in stroki):
        raise Krasno('RABOTNIK_BEZ_VYBORA',
                     f'строки вывода выбора «{VYBOR}» нет')
    # имя в needs ОБОИХ агрегатов (лекало 143/2)
    needs = [l for l in stroki
             if l.strip().startswith('needs:') and RABOTNIK in l]
    if len(needs) < AGREGATY:
        raise Krasno('RABOTNIK_VNE_AGGREGATOV',
                     f'needs с {RABOTNIK}: {len(needs)} из {AGREGATY}')
    if VALIDATOR not in tekst:
        raise Krasno('RABOTNIK_BEZ_VALIDATORA',
                     f'вызова «…{VALIDATOR}…» в теле {RABOTNIK} нет')
    net_pina = [a for a in (REPOSITORY, PIN_HARNESSA) if a not in tekst]
    if net_pina:
        raise Krasno('RABOTNIK_BEZ_PINA', ', '.join(net_pina))
    if not any(l.strip() == KADRY_PUT for l in telo) \
            or KADRY_STRAZH not in tekst:
        raise Krasno('RABOTNIK_BEZ_KADROV',
                     f'артефакт кадров («{KADRY_PUT}» + {KADRY_STRAZH}) не заявлен')


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
    ('имя вне needs агрегатов', 'RABOTNIK_VNE_AGGREGATOV',
     lambda r: _zameni(r, ', e2e-gespraech-vhod]', ']')),
    ('работник без валидатора', 'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VALIDATOR, 'maestro test mobile/.maestro/gespraech-vhod.yaml')),
    ('работник без пина H-checkout', 'RABOTNIK_BEZ_PINA',
     lambda r: _udal_stroki(r, lambda l: l.strip() == PIN_HARNESSA)),
    ('работник без артефакта кадров', 'RABOTNIK_BEZ_KADROV',
     lambda r: _udal_stroki(r, lambda l: l.strip() in (KADRY_PUT, KADRY_STRAZH))),
]


def main():
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
