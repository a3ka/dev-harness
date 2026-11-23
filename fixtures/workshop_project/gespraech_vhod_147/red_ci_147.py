#!/usr/bin/env python3
"""147 v6: регистрация пачки, карты и работника лекала 143/2 на транспорте 197.

Слово владельца 22.11 ~10:53 UTC, п.(4)«А»: требования GitHub-артефактного
шага заменены lane-вызовом канона 197 с сохранением if: always(), источника
кадров, обязательной экранной приёмки и отказа ошибочной публикации; шаг
валидатора переведён в паритетно допустимую форму (npm-lane, 163/1: каждая
run:-команда .github/** — npm run <NAME> либо исключение, новых исключений
и долга работник 147 не добавляет).

Оракул работника — MODEL_YML: адаптация живого работника 149 mob@60a62ecb6,
сверенная с worker-147.yml автора и независимым build_honest.py критика (v5);
v6 меняет в модели ТОЛЬКО транспорт: публикация кадров — однострочный
lane-вызов `npm run ci:artefakt-zapis -- --imja maestro-gespraech-vhod
--chto mobile/maestro-out-gespraech` (if: always(); имя каталогу достраивает
скрипт-канон 197 парой run_id/run_attempt — workflow имя не строит, d01);
исполнение приёмки — `npm run ci:ekran-gespraech-vhod` (lane КОРНЕВОГО
package.json, тело — mobile/scripts/ci-ekran-gespraech-vhod.sh, зона
implementer); читатель APK — измеренный контекст P+L+Q канона 197 с
продюсерской парой --run-id/--run-attempt. Оракул разбирается в память ДО
чтения субъекта (прецедент 141 v3 upravlenie_job).

Job: замкнутый алфавит и буквальное равенство полей, кроме steps; судимые
шаги H-checkout/валидатор/публикация кадров: позиция, алфавит и значения
полей против модели. Lane-вызовы сравниваются разобранными shell-словами
(слово lane, --imja, --chto — самостоятельные слова); данные heredoc,
аргумент echo и комментарий вызовом не являются. Отсутствующая lane в
корневом package.json — именованный отказ LANEJA_NET: npm run без ключа
падает в прогоне и красит паритет, «регистрация» без lane — ложь.
Правка по FAIL критика (вызов 1, 23.11; К-05/К-08/К-09/К-10): непустой
ключ lane приёмки не доказывает её ИСПОЛНЕНИЯ — пустышка «echo skipped»
держала --repo зелёным (REGISTRACIJA_OK, rc 0) без валидатора и Maestro.
Значение lane приёмки судится ПОБАЙТОВО против канона MODEL_PKG
(`bash mobile/scripts/ci-ekran-gespraech-vhod.sh`): связка worker →
lane → скрипт приёмки обязана различаться от пустышки и подавления
(`|| true`) — именованный отказ LANE_NE_KANON. Значения lanes канона
197 (писатель/читатель артефактов) — зона семьи 197: здесь только
существование ключа (наблюдение критика о пустышке писателя — граница,
не требование зоны 147).
Отказ публикации не подавляется: continue-on-error, if: success() и
`|| true` у судимых шагов отклоняются равенством модели (fail-closed
писателя держит скрипт-канон 197 — ISTOCHNIK_OTSTUTSTVUET).

--model: честный контроль rc 0; --stabs: каждый мутант красен СВОЕЙ
причиной, матрица rc 0; --repo R: живой продукт, rc 0 REGISTRACIJA_OK.
Отказ: rc 1 PRICHINA <ветвь>; без режима/предпосылки: rc 2 NOT_IMPLEMENTED.
Привязки стабов к ветвям — STABY, не проза контракта (Н-39).
Содержимое пачки и исполнение lane судит неизменный валидатор 132 v3 в
продуктовом CI; эти клетки не исполняют shell и не доказывают исправность
эмулятора.
"""
import argparse
import json
import re
import shlex
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
SHAG_CHECKOUT = 'actions/checkout'
REPOSITORIJ = 'a3ka/dev-harness'
PIN_HARNESSA = 'd01c9414ef792ea1382750c825759ab51a418ff4'
PIN_STROKA = f'ref: {PIN_HARNESSA}'  # текстовый якорь мутаций стабов

# ── транспорт 197: lanes КОРНЕВОГО package.json (И-2/И-8, замкнутая грамматика)
KOREN_PKG = 'package.json'
LANE_VALIDATORA = 'ci:ekran-gespraech-vhod'   # паритетная форма шага приёмки
LANE_ZAPISI = 'ci:artefakt-zapis'             # публикация кадров (канон 197)
LANE_CHTENIJA = 'ci:artefakt-chtenie'         # читатель APK (канон 197)
# источник кадров и имя публикации — семантика v5 без изменения (И-11 v6)
KADRY_IMJA = 'maestro-gespraech-vhod'
KADRY_PUT = 'mobile/maestro-out-gespraech'

# Единственная модель управляющих полей и судимых шагов — MODEL_YML ниже.
AGREGATY_IMENA = ('android-e2e', 'mobile-regression-signal')  # лекало 143/2


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


def sudi_lineju(root):
    """Lane-вызов без lane в КОРНЕВОМ package.json — ложная регистрация:
    npm run падает в прогоне, паритет 163/1 красен. Оба ключа обязаны
    существовать и быть непустыми строками. Значение lane приёмки сверх
    того ПОБАЙТОВО равно канону модели (v6-правка по FAIL критика:
    пустышка «echo skipped» держала зелёную форму работника без экранной
    приёмки — связка worker → lane → скрипт приёмки обязана различаться
    от пустышки и подавления). Значения lanes канона 197 (писатель/
    читатель) — зона семьи 197: здесь только существование ключа."""
    pkg = root / KOREN_PKG
    if not pkg.is_file():
        raise Krasno('LANEJA_NET', f'нет корневого {KOREN_PKG}')
    try:
        data = json.loads(pkg.read_text())
    except ValueError as e:
        raise Krasno('LANEJA_NET', f'{KOREN_PKG} не JSON: {e}')
    skripty = data.get('scripts') if isinstance(data, dict) else None
    if not isinstance(skripty, dict):
        raise Krasno('LANEJA_NET', f'{KOREN_PKG} без словаря scripts')
    for kljuch in (LANE_VALIDATORA, LANE_ZAPISI):
        zn = skripty.get(kljuch)
        if not isinstance(zn, str) or not zn:
            raise Krasno('LANEJA_NET',
                         f'lane {kljuch} не объявлена в корневом {KOREN_PKG}')
    zn = skripty[LANE_VALIDATORA]
    kanon = MODEL_PKG['scripts'][LANE_VALIDATORA]
    if zn != kanon:
        raise Krasno('LANE_NE_KANON',
                     f'lane {LANE_VALIDATORA}: значение {zn!r} != канону '
                     f'{kanon!r} — lane обязана побайтово исполнять '
                     f'скрипт приёмки')


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
    """Имя работника — в needs ИМЕННО ОБОИХ агрегатов лекала 143/2 — по
    ИМЕНАМ (android-e2e, mobile-regression-signal), не счётчиком любых
    job: e2e-splash + e2e-first-run aggregatной evidенции экрана не несут
    (испр. m10: счётчик «любые 2 job» был слеп к подмене имён)."""
    for imja in AGREGATY_IMENA:
        telo = joby.get(imja)
        nzh = telo.get('needs') if isinstance(telo, dict) else None
        spisok = ([nzh] if isinstance(nzh, str)
                  else (nzh if isinstance(nzh, list) else []))
        if RABOTNIK not in spisok:
            raise Krasno('RABOTNIK_VNE_AGGREGATOV',
                         f'агрегат {imja} (лекало 143/2) не несёт '
                         f'{RABOTNIK} в needs: {spisok!r}')


def ravno_modeli(fakt, model):
    """Структурное равенство YAML с сохранением типов (False != 0)."""
    if type(fakt) is not type(model):
        return False
    if isinstance(model, dict):
        return (fakt.keys() == model.keys()
                and all(ravno_modeli(fakt[k], v) for k, v in model.items()))
    if isinstance(model, list):
        return (len(fakt) == len(model)
                and all(ravno_modeli(a, b) for a, b in zip(fakt, model)))
    return fakt == model


def sudi_upravlenie_joba(rab):
    """Замкнутая модель, а не список известных ложных выражений."""
    if not ravno_modeli({k: v for k, v in rab.items() if k != 'steps'},
                       {k: v for k, v in MODEL_JOB.items() if k != 'steps'}):
        raise Krasno('UPRAVLYAYUSHCHIJ_KLYUCH',
                     f'job {RABOTNIK}: ключи/значения вне честной модели')
    if not isinstance(rab.get('steps'), list):
        raise Krasno('UPRAVLYAYUSHCHIJ_KLYUCH',
                     f'job {RABOTNIK}: steps не список модели')


HEREDOK_RE = re.compile(r'<<(-?)\s*(?:"([^"\n]+)"|\'([^\'\n]+)\'|([^\s;&|)<>]+))')


def aktivnye_komandy(run_tekst):
    """Активные команды shell-скрипта шага как СТРОКИ-команды: комментарии
    выброшены, строки, продолженные через '\\', склеены; ТЕЛА heredoc
    (данные после <<DELIM / <<-DELIM до строки-терминатора) выброшены —
    вызов в теле heredoc данными был и остаётся (m9)."""
    komandy, nakop = [], ''
    terminatory = []  # ожидаемые терминаторы heredoc, по порядку
    for stroka in run_tekst.splitlines():
        if terminatory:
            if stroka.strip() == terminatory[0]:
                terminatory.pop(0)
            continue
        chast = stroka.lstrip() if nakop else stroka.strip()
        if not nakop and (not chast or chast.startswith('#')):
            continue
        nakop = f'{nakop} {chast}'.strip()
        if nakop.endswith('\\'):
            nakop = nakop[:-1].rstrip()
            continue
        komandy.append(nakop)
        for m in HEREDOK_RE.finditer(nakop):
            delim = m.group(2) or m.group(3) or m.group(4)
            if delim:
                terminatory.append(delim)
        nakop = ''
    if nakop:
        komandy.append(nakop)
    return komandy


def slova_komandy(komanda):
    """Слова команды по shell-правилам (shlex); битый синтаксис — None."""
    try:
        return shlex.split(komanda, comments=True)
    except ValueError:
        return None


def signatura_shell(tekst):
    """Слова всей обёртки: удаление вызова функции/ранний exit — отклонение."""
    rez = []
    for komanda in aktivnye_komandy(tekst):
        slova = slova_komandy(komanda)
        rez.append(slova if slova is not None else komanda)
    return rez


def sudi_model_shaga(shag, i, rol):
    pozicija, model = MODEL_SHAGI[rol]
    if i != pozicija:
        raise Krasno('UPRAVLYAYUSHCHIJ_KLYUCH',
                     f'{rol}: позиция {i}, модель {pozicija}')
    if not ravno_modeli({k: v for k, v in shag.items() if k != 'run'},
                       {k: v for k, v in model.items() if k != 'run'}):
        raise Krasno('UPRAVLYAYUSHCHIJ_KLYUCH',
                     f'{rol} [{i}]: ключи/значения вне честной модели')
    if 'run' in model and signatura_shell(shag['run']) != signatura_shell(model['run']):
        raise Krasno('UPRAVLYAYUSHCHIJ_KLYUCH',
                     f'{rol} [{i}]: shell-обёртка вне честной модели')


def sudi_validatora(shagi):
    """Только lane-вызов своими shell-словами (npm, run, имя lane), не текст
    в данных: echo/heredoc/комментарий операцией не являются (m8/m9/MA-2)."""
    for i, shag in enumerate(shagi):
        if not isinstance(shag, dict) or not isinstance(shag.get('run'), str):
            continue
        if any(slova_komandy(k) == MODEL_SLOVA_VYZOVA
               for k in aktivnye_komandy(shag['run'])):
            sudi_model_shaga(shag, i, 'валидатор')
            return
    raise Krasno('RABOTNIK_BEZ_VALIDATORA',
                 f'команды-вызова npm run {LANE_VALIDATORA} '
                 f'своими shell-словами нет')


def sudi_pina(shagi):
    for i, shag in enumerate(shagi):
        if not isinstance(shag, dict):
            continue
        with_ = shag.get('with')
        if str(shag.get('uses') or '').startswith(SHAG_CHECKOUT) \
                and isinstance(with_, dict) \
                and with_.get('repository') == REPOSITORIJ \
                and with_.get('ref') == PIN_HARNESSA:
            sudi_model_shaga(shag, i, 'H-checkout')
            return
    raise Krasno('RABOTNIK_BEZ_PINA',
                 f'шага checkout ({REPOSITORIJ} @ {PIN_HARNESSA}) нет')


def sudi_kadry(shagi):
    """Публикация кадров — lane-вызов канона 197 своими shell-словами:
    lane, --imja и --chto (источник кадров) — самостоятельные слова."""
    for i, shag in enumerate(shagi):
        if not isinstance(shag, dict) or not isinstance(shag.get('run'), str):
            continue
        if any(slova_komandy(k) == MODEL_SLOVA_ZAPISI
               for k in aktivnye_komandy(shag['run'])):
            sudi_model_shaga(shag, i, 'артефакт кадров')
            return
    raise Krasno('RABOTNIK_BEZ_KADROV',
                 f'шага публикации кадров lane-вызовом ({LANE_ZAPISI} -- '
                 f'--imja {KADRY_IMJA} --chto {KADRY_PUT}, if: always()) нет')


def sudi_rabotnika(root):
    joby = razbor_workflow(root)
    rab = joby.get(RABOTNIK)
    if not isinstance(rab, dict):
        raise Krasno('RABOTNIKA_NET', f'job {RABOTNIK} в {WORKFLOW} нет')
    shagi = rab.get('steps') or []
    sudi_vybor(joby)
    sudi_agregaty(joby)
    sudi_upravlenie_joba(rab)
    sudi_validatora(shagi)
    sudi_pina(shagi)
    sudi_kadry(shagi)


def sudi(root):
    sudi_pachku(root)
    sudi_kartu(root)
    sudi_lineju(root)
    sudi_rabotnika(root)


# ── честная встроенная модель (контроль входов; содержимое файлов не судится
#    этими клетками — грамматику пачки судит валидатор 132 v3 на работнике).
#    РАБОТНИК — тело честного работника-147 на транспорте 197 (v6): каркас и
#    судимые шаги v5 (адаптация 149 из mob@60a62ecb6, сверен с worker-147.yml
#    автора и build_honest.py критика) при lane-форме публикации кадров и
#    исполнения приёмки; читатель APK — измеренный контекст P+L+Q канона 197
#    с продюсерской парой run_id/run_attempt. ────────────────────────────────
MODEL_YML = r"""
jobs:
  select-screens:
    outputs:
      e2e-gespraech-vhod: ${{ steps.vybor.outputs.e2e-gespraech-vhod }}
  build-apk:
    outputs:
      apk_sha256: primer
      artifact_name: primer
      run_id: primer
      run_attempt: primer
  e2e-gespraech-vhod:
    needs: [select-screens, build-apk]
    if: needs.select-screens.outputs['e2e-gespraech-vhod'] == 'true'
    outputs:
      apk_sha256: ${{ steps.ident.outputs.apk_sha256 }}
      artifact_name: ${{ steps.ident.outputs.artifact_name }}
      run_id: ${{ steps.ident.outputs.run_id }}
    runs-on: [self-hosted, linux, x64, kvm, complior]
    timeout-minutes: 40
    permissions:
      contents: read
      actions: read
    steps:
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
          clean: true
      # изоляция ДО первого шага, исполняющего код PR на хосте раннера
      - name: Изоляция раннера (/home недоступен коду из PR)
        run: test ! -e /home/harness/.ssh && test ! -e /home/harness/dev-harness
      # работник НЕ пересобирает APK: артефакт по ТОЧНОМУ имени из outputs
      # сборки (имя переживает выборочный повтор), sha256 ДО установки;
      # транспорт 197: локальный читатель с ПРОДЮСЕРСКОЙ парой run_id/
      # run_attempt из needs.build-apk.outputs (И-4 197 — своя попытка
      # читала бы пусто на выборочном повторе работника)
      - name: 'APK сборки: артефакт по имени, digest до установки'
        working-directory: ${{ github.workspace }}
        env:
          IMJA_ARTEFAKTA: ${{ needs.build-apk.outputs.artifact_name }}
          ZHELANYJ_DIGEST: ${{ needs.build-apk.outputs.apk_sha256 }}
          RUN_SBORKI: ${{ needs.build-apk.outputs.run_id }}
          POPYTKA_SBORKI: ${{ needs.build-apk.outputs.run_attempt }}
        run: |
          set -euo pipefail
          test -n "$IMJA_ARTEFAKTA" && test -n "$ZHELANYJ_DIGEST"
          rm -rf apk-build && mkdir -p apk-build
          npm run ci:artefakt-chtenie -- --imja "$IMJA_ARTEFAKTA" --kuda apk-build --run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"
          test -f apk-build/app-release.apk
          got="$(sha256sum apk-build/app-release.apk | awk '{print $1}')"
          if [ "$got" != "$ZHELANYJ_DIGEST" ]; then
            echo "APK_DIGEST_RASKHOZHDENIE: $got != $ZHELANYJ_DIGEST" >&2
            exit 1
          fi
          mkdir -p mobile/android/app/build/outputs/apk/release
          cp apk-build/app-release.apk mobile/android/app/build/outputs/apk/release/app-release.apk
      # outputs работника для агрегата: digest установленного APK, имя
      # артефакта и run-identity той же сборки (агрегат сверяет их с
      # build-apk; шаг БЕЗ id: ident в needs-контекст не попадает)
      - name: 'Идентичность прогона работника (outputs для агрегата)'
        id: ident
        working-directory: ${{ github.workspace }}
        run: |
          set -euo pipefail
          got="$(sha256sum mobile/android/app/build/outputs/apk/release/app-release.apk | awk '{print $1}')"
          {
            echo "apk_sha256=$got"
            echo "artifact_name=${{ needs.build-apk.outputs.artifact_name }}"
            echo "run_id=${{ needs.build-apk.outputs.run_id }}"
          } >> "$GITHUB_OUTPUT"
      # H: ПРИНЯТЫЙ пин харнесса с реализацией валидатора 132 v3 и всеми
      # зависимостями; содержимое пачки/флоу — предмет ЭКРАННОГО контракта
      - name: Checkout H пачки экрана (.harness147)
        uses: actions/checkout@v7
        with:
          repository: a3ka/dev-harness
          ref: d01c9414ef792ea1382750c825759ab51a418ff4
          path: .harness147
          persist-credentials: false
      # 163/1 (паритет run:-команд .github/**): каждая команда мобильного CI
      # обязана быть `npm run <NAME>` либо объявленным исключением; работник
      # 147 новых исключений НЕ добавляет — приёмку исполняет lane КОРНЕВОГО
      # package.json. Тело приёмки (AVD, Maestro, валидатор 132 v3 на пачке,
      # один уровень восстановления по adb-сигнатуре) — скрипт lane:
      # mobile/scripts/ci-ekran-gespraech-vhod.sh (зона implementer); канал
      # GitHub (upload/download-artifact, gh run download) в работнике закрыт
      # каноном 197.
      - name: 'Экранная пачка: валидатор 132 v3 + Maestro, один уровень восстановления'
        working-directory: ${{ github.workspace }}
        env:
          FLOWS_PACHKI: mobile/.maestro/gespraech-vhod.yaml,mobile/.maestro/gespraech-vhod-393.yaml
        run: npm run ci:ekran-gespraech-vhod
      # 197: публикация кадров ЛОКАЛЬНЫМ транспортом lane-вызовом; имя
      # каталогу maestro-gespraech-vhod достраивает скрипт-канон парой
      # (run_id, run_attempt) — workflow имя не строит (d01). if: always():
      # кадры выходят и при красной приёмке; отказ писателя (отсутствующий
      # источник) краснит шаг и джобу — подавления нет.
      - name: Артефакты экрана (кадры, отчёт)
        if: always()
        working-directory: ${{ github.workspace }}
        run: npm run ci:artefakt-zapis -- --imja maestro-gespraech-vhod --chto mobile/maestro-out-gespraech
  android-e2e:
    needs: [select-screens, quality, build-apk, e2e-gespraech-vhod]
    runs-on: [self-hosted, linux, x64, complior]
  mobile-regression-signal:
    needs: [select-screens, quality, build-apk, e2e-gespraech-vhod]
    runs-on: [self-hosted, linux, x64, complior]
  e2e-splash:
    needs: [build-apk, select-screens]
  e2e-first-run:
    needs: [build-apk, select-screens]
"""

# Модель корневого package.json: lanes — единственная судимая часть; значения
# artefakt-lanes равны канону 197 (живой продукт, замер 2026-11-22) и судятся
# только существованием (зона семьи 197); значение lane приёмки — ПОБАЙТОВЫЙ
# КАНОН (sudi_lineju, правка по FAIL критика v6): именно эта команда
# обязана исполняться lane работника.
MODEL_PKG = {
    'scripts': {
        'ci:artefakt-zapis': 'node mobile/scripts/ci-artefakty.cjs zapis',
        'ci:artefakt-chtenie': 'node mobile/scripts/ci-artefakty.cjs chtenie',
        'ci:ekran-gespraech-vhod': 'bash mobile/scripts/ci-ekran-gespraech-vhod.sh',
    }
}

# Снимок оракула снимается один раз; файлы модели в --repo не перечитываются.
MODEL_JOB = yaml.safe_load(MODEL_YML)['jobs'][RABOTNIK] if yaml else {}
MODEL_SHAGI = {}
if yaml:
    for i, shag in enumerate(MODEL_JOB['steps']):
        with_ = shag.get('with') or {}
        run_tekst = shag.get('run') or ''
        if with_.get('repository') == REPOSITORIJ:
            MODEL_SHAGI['H-checkout'] = (i, shag)
        elif LANE_ZAPISI in run_tekst:
            MODEL_SHAGI['артефакт кадров'] = (i, shag)
        elif LANE_VALIDATORA in run_tekst:
            MODEL_SHAGI['валидатор'] = (i, shag)
    MODEL_SLOVA_VYZOVA = next(
        slova_komandy(k)
        for k in aktivnye_komandy(MODEL_SHAGI['валидатор'][1]['run'])
        if (slova_komandy(k) or [''])[0] == 'npm')
    MODEL_SLOVA_ZAPISI = next(
        slova_komandy(k)
        for k in aktivnye_komandy(MODEL_SHAGI['артефакт кадров'][1]['run'])
        if (slova_komandy(k) or [''])[0] == 'npm')


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
    (kuda / KOREN_PKG).write_text(json.dumps(MODEL_PKG, indent=2))
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


def _bez_lanei(root, kljuch):
    pkg = root / KOREN_PKG
    data = json.loads(pkg.read_text())
    data['scripts'].pop(kljuch)
    pkg.write_text(json.dumps(data, indent=2))


def _zameni_znachenie_lanei(root, kljuch, znachenie):
    """Мутация ЗНАЧЕНИЯ lane (ключ остаётся, проверка существования зелена):
    различает побайтовый канон от «непустой строки» (v6-FAIL К-08)."""
    pkg = root / KOREN_PKG
    data = json.loads(pkg.read_text())
    data['scripts'][kljuch] = znachenie
    pkg.write_text(json.dumps(data, indent=2))


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


def _udal_shag(root, imja_stroki):
    """Удаление блока шага целиком: от строки '- name: <…>' до следующего
    шага ('      - ') или конца job (строка мельче 6 пробелов)."""
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    nachalo = next(i for i, l in enumerate(stroki) if l == imja_stroki)
    konec = len(stroki)
    for j in range(nachalo + 1, len(stroki)):
        if stroki[j].startswith('      - ') or not stroki[j].startswith('      '):
            konec = j
            break
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


def _vstav_posle(root, jakor, stroki_vstavki):
    """Вставка строк ПОСЛЕ строки-якоря (якорь обязан быть уникален —
    судимое место одно)."""
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    mesta = [i for i, l in enumerate(stroki) if l == jakor]
    assert len(mesta) == 1, f'якорь вставки не уникален: {jakor!r} x{len(mesta)}'
    i = mesta[0]
    wf.write_text('\n'.join(stroki[:i + 1] + stroki_vstavki
                            + stroki[i + 1:]) + '\n')


def _perestav_shag_za(root, jakor_shaga, jakor_kuda):
    """Перестановка: блок шага (от строки-якоря до следующего шага/конца
    job) переносится ПОСЛЕ строки-якоря jakor_kuda."""
    wf = root / WORKFLOW
    stroki = wf.read_text().splitlines()
    a = next(i for i, l in enumerate(stroki) if l == jakor_shaga)
    b = next(i for i, l in enumerate(stroki[a + 1:], a + 1)
             if l.startswith('      - ') or not l.startswith('      '))
    blok = stroki[a:b]
    bez = stroki[:a] + stroki[b:]
    k = next(i for i, l in enumerate(bez) if l == jakor_kuda)
    wf.write_text('\n'.join(bez[:k + 1] + blok + bez[k + 1:]) + '\n')


IF_JOB_STROKA = "    if: needs.select-screens.outputs['e2e-gespraech-vhod'] == 'true'"
NEEDS_JOB_STROKA = '    needs: [select-screens, build-apk]'
NAME_PINA_STROKA = '      - name: Checkout H пачки экрана (.harness147)'
NAME_VALID_STROKA = ("      - name: 'Экранная пачка: валидатор 132 v3 + Maestro, "
                     "один уровень восстановления'")
NAME_KADRY_STROKA = '      - name: Артефакты экрана (кадры, отчёт)'
VAL_STROKA = '        run: npm run ci:ekran-gespraech-vhod'
ZAPIS_STROKA = ('        run: npm run ci:artefakt-zapis -- --imja '
                'maestro-gespraech-vhod --chto mobile/maestro-out-gespraech')
IF_ALWAYS_STROKA = '        if: always()'


def _dubl_job_false(root):
    """Второй job с тем же id: судится фактический последний YAML-узел."""
    wf = root / WORKFLOW
    t = wf.read_text()
    a = t.index(f'  {RABOTNIK}:\n')
    b = t.index('  android-e2e:\n', a)
    dubl = t[a:b].replace(IF_JOB_STROKA, '    if: false')
    wf.write_text(t[:b] + dubl + t[b:])


def _podmeni_agregaty(root):
    """m10 без цикла: имя остаётся в needs двух НЕагрегатов."""
    wf = root / WORKFLOW
    tekst = wf.read_text().replace(', e2e-gespraech-vhod]', ']')
    for imja in ('e2e-splash', 'e2e-first-run'):
        staraja = f'  {imja}:\n    needs: [build-apk, select-screens]'
        assert tekst.count(staraja) == 1
        tekst = tekst.replace(staraja, staraja[:-1]
                              + ', e2e-gespraech-vhod]', 1)
    wf.write_text(tekst)


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
    # ── v6: lane-транспорт (197) и паритетная форма валидатора (163/1) ──────
    ('корневой package.json без lane приёмки ci:ekran-gespraech-vhod',
     'LANEJA_NET', lambda r: _bez_lanei(r, LANE_VALIDATORA)),
    ('корневой package.json без lane писателя ci:artefakt-zapis',
     'LANEJA_NET', lambda r: _bez_lanei(r, LANE_ZAPISI)),
    ('значение lane приёмки — пустышка echo skipped вместо команды '
     'валидатора (v6-FAIL К-08: непустой ключ не доказывает исполнения)',
     'LANE_NE_KANON',
     lambda r: _zameni_znachenie_lanei(r, LANE_VALIDATORA, 'echo skipped')),
    ('значение lane приёмки с подавлением отказа — хвост "|| true" '
     'внутри значения lane (v6-FAIL К-10: ненулевой итог приёмки)',
     'LANE_NE_KANON',
     lambda r: _zameni_znachenie_lanei(
         r, LANE_VALIDATORA,
         MODEL_PKG['scripts'][LANE_VALIDATORA] + ' || true')),
    ('работник без валидатора', 'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VAL_STROKA,
                       '        run: maestro test mobile/.maestro/gespraech-vhod.yaml')),
    ('вызов lane валидатора закомментирован, подстрока в теле (MA-2)',
     'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zakommentirj(r, VAL_STROKA.strip())),
    ('работник без пина H-checkout', 'RABOTNIK_BEZ_PINA',
     lambda r: _udal_stroki(r, lambda l: l.strip() == PIN_STROKA)),
    ('работник без публикации кадров', 'RABOTNIK_BEZ_KADROV',
     lambda r: _udal_shag(r, NAME_KADRY_STROKA)),
    ('строка lane-писателя закомментирована, подстрока в теле (MA-2b)',
     'RABOTNIK_BEZ_KADROV', lambda r: _zakommentirj(r, LANE_ZAPISI)),
    ('источник кадров подменён: --chto mobile/maestro-out-vkladki',
     'RABOTNIK_BEZ_KADROV',
     lambda r: _zameni(r, '--chto mobile/maestro-out-gespraech',
                       '--chto mobile/maestro-out-vkladki')),
    ('имя публикации кадров подменено: --imja maestro-gespraech-tekst',
     'RABOTNIK_BEZ_KADROV',
     lambda r: _zameni(r, '--imja maestro-gespraech-vhod',
                       '--imja maestro-gespraech-tekst')),
    # ── испр. Б-1 вызов 2 (вердикт vyzov2-fail): замкнутая модель работника —
    #    управляющие ключи/слова/имена; стабы по КОДУ ветвей (Н-39) ─────────
    ('if: false на job работника — тихий обход варианта Б (m7)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, '    if: false')),
    ('if: ${{ false }} на job работника (m7b)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, '    if: ${{ false }}')),
    ("if: 'false' (строка) на job работника (m7c)",
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, "    if: 'false'")),
    ('if: always() && false на job работника (m7d)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, '    if: always() && false')),
    ('YAML-якорь в значении if: &neaktivno false (m7e)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, '    if: &neaktivno false')),
    ('if: false на шаге валидатора (m6)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, NAME_VALID_STROKA, ['        if: false'])),
    ('continue-on-error: true на шаге валидатора (m6d)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, NAME_VALID_STROKA,
                            ['        continue-on-error: true'])),
    ('if: false на шаге H-checkout пина (m15)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, NAME_PINA_STROKA, ['        if: false'])),
    ('if: false на шаге публикации кадров (m6b)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_ALWAYS_STROKA, '        if: false')),
    ('if: success() на шаге публикации кадров — кадры только при зелёной приёмке',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_ALWAYS_STROKA, '        if: success()')),
    ('continue-on-error: true на job работника — маскировка итога (m6c)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, NEEDS_JOB_STROKA,
                            ['    continue-on-error: true'])),
    ('timeout-minutes: 0 на job работника (m12)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, '    timeout-minutes: 40',
                       '    timeout-minutes: 0')),
    ('strategy: fail-fast: false на job работника (m13)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, NEEDS_JOB_STROKA,
                            ['    strategy:', '      fail-fast: false'])),
    ('вызов lane валидатора — аргумент echo, подстрока в команде (m8)',
     'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VAL_STROKA,
                       '        run: echo "npm run ci:ekran-gespraech-vhod"')),
    ('вызов lane валидатора — тело heredoc cat >/dev/null, данные (m9)',
     'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VAL_STROKA,
                       "        run: |\n"
                       "          cat >/dev/null <<'KONEC'\n"
                       "          npm run ci:ekran-gespraech-vhod\n"
                       "          KONEC")),
    ('вызов lane валидатора — данные no-op heredoc',
     'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VAL_STROKA,
                       "        run: |\n"
                       "          : <<'KONEC'\n"
                       "          npm run ci:ekran-gespraech-vhod\n"
                       "          KONEC")),
    ('lane валидатора с подавлением отказа — хвост "|| true"',
     'RABOTNIK_BEZ_VALIDATORA',
     lambda r: _zameni(r, VAL_STROKA, VAL_STROKA + ' || true')),
    ('lane писателя кадров с подавлением отказа — хвост "|| true"',
     'RABOTNIK_BEZ_KADROV',
     lambda r: _zameni(r, ZAPIS_STROKA, ZAPIS_STROKA + ' || true')),
    ('имя в needs двух НЕагрегатов вместо обоих агрегатов, без цикла (m10)',
     'RABOTNIK_VNE_AGGREGATOV', _podmeni_agregaty),
    ('перестановка: шаг валидатора после шага публикации кадров (m14)',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _perestav_shag_za(r, NAME_VALID_STROKA, ZAPIS_STROKA)),
    ('needs работника без ребра select-screens',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, NEEDS_JOB_STROKA, '    needs: [build-apk]')),
    ('чужой working-directory шага валидатора',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, NAME_VALID_STROKA
                       + '\n        working-directory: ${{ github.workspace }}',
                       NAME_VALID_STROKA + '\n        working-directory: .harness147')),
    ('env шага валидатора отличается от модели',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, 'FLOWS_PACHKI: mobile/.maestro/gespraech-vhod.yaml,'
                       'mobile/.maestro/gespraech-vhod-393.yaml',
                       'FLOWS_PACHKI: mobile/.maestro/chuzhoj.yaml')),
    ('дубль if: последним остаётся false',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _zameni(r, IF_JOB_STROKA, IF_JOB_STROKA + '\n    if: false')),
    ('алиас if ссылается на false',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: (_zameni(r, '\njobs:', '\nx-neaktivno: &neaktivno false\njobs:'),
                _zameni(r, IF_JOB_STROKA, '    if: *neaktivno'))),
    ('дубль job: последний работник выключен',
     'UPRAVLYAYUSHCHIJ_KLYUCH', _dubl_job_false),
    ('continue-on-error выражением на шаге публикации кадров',
     'UPRAVLYAYUSHCHIJ_KLYUCH',
     lambda r: _vstav_posle(r, IF_ALWAYS_STROKA,
                            ['        continue-on-error: ${{ true }}'])),
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
