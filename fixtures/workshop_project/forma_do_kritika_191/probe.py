#!/usr/bin/env python3
"""Батарея 191 «Л1 — ноги формы до критика» (семья forma_do_kritika_191).

Субъект: scripts/pre_critic.sh (три новые ноги ж/з/и) и scripts/check_provodka.sh
(режим --grammar). Проверка идёт против НАСТОЯЩИХ инструментов дерева (голый
вызов = суд дерева батареи; --repo <корень> = суд чужого дерева): в каждом
toy-мире канона 072 стоят копии реальных гейтов харнесса, дверь — копия
субъекта, гейты формы (check_threat_model/check_ceilings) — копии настоящих
скриптов дерева. Ожидания — в памяти ДО вызова субъекта (правило 8); диск
проверяемого как истина не перечитывается.

Режимы: голый/--repo (до реализации предметные клетки красны), --model
(честная модель ног — все клетки зелёные), --stabs (поимка обманных реализаций
по stabs.tsv; данные привязок — не проза контракта).
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MIR = HERE / 'mir'

TOY_GEJTY = ('check_precision_gate.sh', 'check_spec_ready.sh', 'verify_ci_parity.sh')
LIBS = ('lib_incr.sh', 'lib_plan.sh', 'lib_registry.sh', 'lib_roles.sh',
       'lib_session.sh', 'lib_zones.sh')
NOVYE_GEJTY = ('check_threat_model.sh', 'check_ceilings.sh')

PACKAGE_JSON = ('{"name":"toy","version":"1.0.0","scripts":'
                '{"check:precision-gate":"bash scripts/check_precision_gate.sh",'
                '"check:spec-ready":"bash scripts/check_spec_ready.sh"}}\n')
CI_YML = ('name: toy-ci\non: [push]\njobs:\n  toy:\n    runs-on: ubuntu-latest\n'
          '    steps:\n'
          '      - run: npm run check:precision-gate -- . contracts/043-toy-draft.md\n'
          '      - run: npm run check:spec-ready -- . contracts/043-toy-draft.md\n')

KONTRAKT_REL = 'contracts/043-toy-draft.md'
PERSONA_LIMIT = 73728  # байт; порог реального check_ceilings.sh (контракт 004)

# (имя мира, фикстура или None→пустой контракт, вооружать ногу, доп-файлы)
SPECIFIKACII = {
    'chestnyj': ('kontrakt_chestnyj.md', True, ()),
    'bez_nog': ('kontrakt_chestnyj.md', False, ()),
    'ugrozy_v_bullete': ('kontrakt_ugrozy_v_bullete.md', True, ()),
    'bez_nezapolnennyh': ('kontrakt_bez_nezapolnennyh.md', True, ()),
    'persona': ('kontrakt_chestnyj.md', True,
                (('roles/huge.md', 'x' * (PERSONA_LIMIT + 1)),)),
    'guard_pojasnenie': ('kontrakt_guard_pojasnenie.md', True, ()),
    'vlozhennye': ('kontrakt_vlozhennye.md', True, ()),
    'charter_ne_ustav': ('kontrakt_charter_ne_ustav.md', True, ()),
    'golaya_stroka': ('kontrakt_golaya_stroka.md', True, ()),
    'guard_only': ('kontrakt_guard_only.md', True, ()),
    'repo_bez_formy': ('kontrakt_guard_only.md', False, ()),
    'pustoj': (None, True, ()),
}


def git(kuda: Path, *args: str) -> None:
    subprocess.run(['git', '-C', str(kuda), '-c', 'user.name=orchestrator',
                    '-c', 'user.email=orchestrator@dev-harness.local', *args],
                   check=True, capture_output=True)


def tekst(imja: str) -> str:
    return (MIR / imja).read_text(encoding='utf-8')


def postroit_mir(kuda: Path, tekst_kontrakta: str, vooruzhat: bool,
                 dver_ist: Path, provodka_ist: Path, dop_fajly=()) -> Path:
    """Toy-мир канона 072 (+нога: копии настоящих гейтов формы из дерева)."""
    for d in ('scripts', 'contracts', '.github/workflows', 'config'):
        (kuda / d).mkdir(parents=True, exist_ok=True)
    for f in TOY_GEJTY:
        shutil.copy2(ROOT / 'scripts' / f, kuda / 'scripts' / f)
    for f in LIBS:
        shutil.copy2(ROOT / 'scripts' / f, kuda / 'scripts' / f)
    (kuda / 'package.json').write_text(PACKAGE_JSON, encoding='utf-8')
    (kuda / '.github/workflows/ci.yml').write_text(CI_YML, encoding='utf-8')
    (kuda / 'config/ci_parity_exceptions.txt').write_text('', encoding='utf-8')
    (kuda / KONTRAKT_REL).write_text(tekst_kontrakta, encoding='utf-8')
    if vooruzhat:
        for f in NOVYE_GEJTY:
            shutil.copy2(ROOT / 'scripts' / f, kuda / 'scripts' / f)
        shutil.copy2(provodka_ist, kuda / 'scripts' / 'check_provodka.sh')
    shutil.copy2(dver_ist, kuda / 'scripts' / 'pre_critic.sh')
    for otn, soderzhimoe in dop_fajly:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(soderzhimoe, encoding='utf-8')
    git(kuda, 'init', '-q', '-b', 'main')
    git(kuda, 'add', '-A')
    git(kuda, 'commit', '-qm', 'toy: init')
    return kuda


class Miry:
    """Миры строятся ленично и по одному: клетка ссылается на свой мир."""

    def __init__(self, vrem: Path, dver_ist: Path, provodka_ist: Path):
        self.vrem, self.dver_ist, self.provodka_ist = vrem, dver_ist, provodka_ist
        self._miry = {}

    def __getitem__(self, imja: str) -> Path:
        if imja not in self._miry:
            fajl, vooruzhat, dop = SPECIFIKACII[imja]
            tekst_kontrakta = '' if fajl is None else tekst(fajl)
            self._miry[imja] = postroit_mir(
                self.vrem / ('mir-' + imja), tekst_kontrakta,
                vooruzhat, self.dver_ist, self.provodka_ist, dop)
        return self._miry[imja]


class Kletka:
    def __init__(self, imja, argv, rc, markery=()):
        self.imja, self.argv, self.rc, self.markery = imja, argv, rc, list(markery)


def kletki(miry: Miry) -> list:
    """Оракул в памяти: имя, команда, ожидаемый rc, обязательные маркеры."""
    K = []

    def dver(imja_mira):
        return ['bash', str(miry[imja_mira] / 'scripts' / 'pre_critic.sh'), KONTRAKT_REL]

    def provodka(imja_mira, grammar=False):
        argv = ['bash', str(miry[imja_mira] / 'scripts' / 'check_provodka.sh')]
        if grammar:
            argv.append('--grammar')
        argv += [str(miry[imja_mira]), KONTRAKT_REL]
        return argv

    # зелёные контроли (честное поведение, не зависящее от реализации 191)
    K.append(Kletka('g01-dver-zelena', dver('chestnyj'), 0, ['КРИТИК: дверь зелёная']))
    K.append(Kletka('t01-mir-bez-nog-propuskaet', dver('bez_nog'), 0,
                    ['КРИТИК: дверь зелёная']))
    # r01 (блок-фикс вердикта 191 v1, Б-1): вход, где расходятся прочтения
    # вооружения «от корня двери» (ROOT) и «от судимого дерева» (BASE).
    # Дверь — копия субъекта в ВООРУЖЁННОМ мире (гейты формы при ней),
    # судимое --repo-дерево — мир без гейтов формы с guard-only контрактом
    # (г0-доп обязан отказать, окажись нога (и) вооружена на нём). Честная
    # реализация (скрипт гейта и [ -x ] — в BASE) ноги пропускает → rc 0;
    # прочтение ROOT вооружает ноги харнесса на чужом мире → rc 1 «проводка
    # красна» — то, что сломало замороженную 103 (клетки i2 на 777-toy.md).
    K.append(Kletka('r01-repo-bez-formy-propuskaet',
                    ['bash', str(miry['chestnyj'] / 'scripts' / 'pre_critic.sh'),
                     '--repo', str(miry['repo_bez_formy']), KONTRAKT_REL],
                    0, ['КРИТИК: дверь зелёная']))
    K.append(Kletka('p04-obychnyj-rezhim-krasen', provodka('chestnyj'), 1,
                    ['guard-файл не существует']))
    # предметные клетки (до реализации красны — ног в двери нет)
    K.append(Kletka('m02-ugrozy-metki-v-bullete', dver('ugrozy_v_bullete'), 1,
                    ['ОТКАЗ: модель угроз красна (rc=1)']))
    K.append(Kletka('m03-net-nezapolnennyh', dver('bez_nezapolnennyh'), 1,
                    ['ОТКАЗ: потолки красны (rc=1)']))
    K.append(Kletka('m04-persona-sverh-potolka', dver('persona'), 1,
                    ['ОТКАЗ: потолки красны (rc=1)']))
    K.append(Kletka('p01-guard-pojasnenie', dver('guard_pojasnenie'), 1,
                    ['ОТКАЗ: проводка красна (rc=1)']))
    K.append(Kletka('p02-vlozhennye-kavychki', dver('vlozhennye'), 1,
                    ['ОТКАЗ: проводка красна (rc=1)']))
    K.append(Kletka('p05-charter-ne-ustav', dver('charter_ne_ustav'), 1,
                    ['ОТКАЗ: проводка красна (rc=1)']))
    K.append(Kletka('p06-golaya-stroka-kanala', dver('golaya_stroka'), 1,
                    ['ОТКАЗ: проводка красна (rc=1)']))
    K.append(Kletka('p07-guard-only-bez-v1', dver('guard_only'), 1,
                    ['ОТКАЗ: проводка красна (rc=1)']))
    K.append(Kletka('p03-grammar-bez-fajlov', provodka('chestnyj', grammar=True), 0))
    K.append(Kletka('f01-rc2-ne-zeleno', dver('pustoj'), 1,
                    ['ОТКАЗ: модель угроз красна (rc=2)']))
    return K


def sudit(k: Kletka) -> bool:
    try:
        r = subprocess.run(k.argv, capture_output=True, text=True, timeout=90)
        rc, vyvod = r.returncode, r.stdout + r.stderr
    except FileNotFoundError:
        rc, vyvod = None, 'SUBJECT_ABSENT: %s' % k.argv[0]
    except subprocess.TimeoutExpired:
        rc, vyvod = None, 'TIMEOUT'
    ok = rc == k.rc and all(m in vyvod for m in k.markery)
    print('191 %s %s rc=%s %s' % (
        k.imja, 'ok' if ok else 'KRASNO', rc, vyvod.strip().splitlines()[:1]))
    return ok


def predposylki() -> None:
    for instrument in ('python3', 'git', 'bash'):
        r = subprocess.run(['bash', '-c', 'command -v %s' % instrument],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print('LIVE_PREDPOSYLKA: нет %s — нечем исполнять батарею 191 '
                  '(чистый клон без зависимостей — именованный отказ, не '
                  'skip→pass)' % instrument, file=sys.stderr)
            sys.exit(2)


def rezhim_suda(miry: Miry) -> int:
    K = kletki(miry)
    zel = sum(1 for k in K if sudit(k))
    kras = len(K) - zel
    print('ИТОГ 191: rc=%d KLETKI=%d ZELENYE=%d KRASNYE=%d'
          % (0 if kras == 0 else 1, len(K), zel, kras))
    return 0 if kras == 0 else 1


def rezhim_stabs(vrem: Path) -> int:
    svjazi = []
    for line in (HERE / 'stabs.tsv').read_text(encoding='utf-8').splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) != 3:
            print('ORACLE_TAMPERED: строка привязки вне грамматики: %r' % line,
                  file=sys.stderr)
            return 2
        svjazi.append(cols)
    model = HERE / 'model' / 'scripts'
    poimano, zhivyh = 0, 0
    for imja, fail, kletka_imja in svjazi:
        stab = HERE / 'stabs' / imja
        dver_ist = stab if fail == 'scripts/pre_critic.sh' else model / 'pre_critic.sh'
        provodka_ist = (stab if fail == 'scripts/check_provodka.sh'
                        else model / 'check_provodka.sh')
        miry = Miry(vrem / ('obmanka-' + imja), dver_ist, provodka_ist)
        K = kletki(miry)
        kletka = next((k for k in K if k.imja.startswith(kletka_imja + '-')), None)
        if kletka is None:
            print('ORACLE_TAMPERED: клетка привязки не найдена: %s' % kletka_imja,
                  file=sys.stderr)
            return 2
        ulov = not sudit(kletka)  # обманка НЕ удовлетворяет ожиданию клетки
        if ulov:
            poimano += 1
        else:
            zhivyh += 1
        print('191 %s %s' % (imja, 'POIMAN' if ulov else 'ZHIV — дефект не различим'))
    print('ИТОГ 191: rc=%d OBMANOK=%d POIMANY=%d ZHIVYH=%d'
          % (0 if zhivyh == 0 else 1, len(svjazi), poimano, zhivyh))
    return 0 if zhivyh == 0 else 1


def main() -> int:
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, default=None)
    p.add_argument('--model', action='store_true')
    p.add_argument('--stabs', action='store_true')
    a = p.parse_args()
    predposylki()
    vrem = Path(tempfile.mkdtemp(prefix='batareja-191-'))
    try:
        if a.stabs:
            return rezhim_stabs(vrem)
        if a.model:
            model = HERE / 'model' / 'scripts'
            return rezhim_suda(Miry(vrem / 'subekt-model',
                                    model / 'pre_critic.sh',
                                    model / 'check_provodka.sh'))
        koren = a.repo if a.repo is not None else ROOT
        return rezhim_suda(Miry(vrem / 'subekt-repo',
                                koren / 'scripts' / 'pre_critic.sh',
                                koren / 'scripts' / 'check_provodka.sh'))
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
