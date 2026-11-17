#!/usr/bin/env python3
"""Батарея 193 «Л2 — сдаточный лист architect и карта классов вердикта».

Семья sdacha_193. Субъекты: scripts/check_sdacha.sh (дверь листа),
scripts/check_verdict_karta.sh (дверь карты вердикта), нога (к) в
scripts/pre_critic.sh (вставлена патчем к реальной двери — якорь
«printf 'КРИТИК: дверь зелёная»; пост-реализация опознаётся по метке ноги
и не дублируется) и нога карты в scripts/freeze_contract.sh (якорь
«# ── 6а. SPEC-PREFLIGHT»).

Режимы: --repo <корень> (умолчание — живое дерево) и голый: субъекты —
ТОЛЬКО реальные файлы выбранного дерева, ноги pre_critic/freeze НЕ
достраиваются патчем (К-11 Crit193V1: до реализации реальные ноги
отсутствуют и клетки ног честно красны); --model (честная модель из
model/scripts; ноги — патч к реальным дверям живого дерева, пост-реализация
опознаётся меткой); --stabs (обманные реализации из stabs/ и мутации ног по
привязкам stabs.tsv против модели; Н-39: привязки данными батареи,
не прозой контракта).

Оракул — в памяти пробы: ожидания сняты до вызова субъекта (К-11); таймаут
убивает ГРУППУ процессов субъекта (рекурсивная обманка не переживает прогон).
"""
import argparse
import os
import shutil
import signal
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEREVO = HERE.parents[2]            # живое дерево: гейты, pre_critic, freeze
MIR = HERE / 'mir'
MIRSKRIPTY = HERE / 'mirskripty'
MODEL = HERE / 'model'
STABS = HERE / 'stabs'

TOY_GEJTY = ('check_precision_gate.sh', 'check_spec_ready.sh', 'verify_ci_parity.sh')
LIBS = ('lib_incr.sh', 'lib_plan.sh', 'lib_registry.sh', 'lib_roles.sh',
        'lib_session.sh', 'lib_zones.sh')
FORMA_GEJTY = ('check_threat_model.sh', 'check_ceilings.sh', 'check_provodka.sh')
FREEZE_LIBS = ('next_id.sh', 'lib_registry.sh')

PACKAGE_JSON = ('{"name":"toy","version":"1.0.0","scripts":'
                '{"check:precision-gate":"bash scripts/check_precision_gate.sh",'
                '"check:spec-ready":"bash scripts/check_spec_ready.sh"}}\n')
CI_YML = ('name: toy-ci\non: [push]\njobs:\n  toy:\n    runs-on: ubuntu-latest\n'
          '    steps:\n'
          '      - run: npm run check:precision-gate -- . contracts/777-toy.md\n'
          '      - run: npm run check:spec-ready -- . contracts/777-toy.md\n')

KONTRAKT = 'contracts/777-toy.md'
VERDIKT = 'verdicts/critic/contracts-777-v1.md'

# ── ноги, вставляемые патчем в реальные двери (модель = реальное + нога) ──────
NOGA_PRE_CRITIC = '''# ── (к) СДАТОЧНЫЙ ЛИСТ (контракт 193, Л2) ────────────────────────────────────
# Дверь листа вооружается от BASE (канон ног ж/з/и): скрипта в BASE нет —
# нога пропускается молча. SDACHA_OKRUG=1 — маркер внутреннего прогона двери
# листа: нога по нему пропускается (разрыв рекурсии лист↔дверь, И6).
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$BASE/scripts/check_sdacha.sh" ]; then
  noga_formy "сдаточный лист красен" "scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run
fi

'''

NOGA_PRE_CRITIC_IZ_ROOTA = '''# ── (к) СДАТОЧНЫЙ ЛИСТ — мутация PATERN:IZ-ROOTA (батарея 193) ──────────────
# Дверь вооружается из ROOT (дерева двери), а не из BASE (судимого дерева):
# прочтение, ломающее канон 191 — чужому --repo-миру навязывается дверь
# дерева двери. Различающий вход — клетка p02.
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$ROOT/scripts/check_sdacha.sh" ]; then
  _r193=0
  _o193="$(bash "$ROOT/scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run 2>&1)" || _r193=$?
  [ "$_r193" -eq 0 ] || refuse "сдаточный лист красен (rc=$_r193): $(printf '%s' "$_o193" | head -n 1)"
fi

'''
NOGA_PRE_CRITIC_VSEGDA_OTKAZ = '''# ── (к) СДАТОЧНЫЙ ЛИСТ — мутация PATERN:VSEGDA-OTKAZ (батарея 193) ──────────
# Нога отказывает БЕЗ прогона двери: ложный отказ и на честном листе
# (блок критика Crit193V1 К-14). Различающий вход — клетка p03: прямой
# вызов с честным листом и зелёной вооружённой дверью обязан пройти.
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$BASE/scripts/check_sdacha.sh" ]; then
  refuse "сдаточный лист красен"
fi

'''
YAKOR_PRE_CRITIC = "printf 'КРИТИК: дверь зелёная"

NOGA_FREEZE = '''# ── 6-карта. КАРТА КЛАССОВ ВЕРДИКТА (контракт 193, Л2) ──────────────────────
# Контракт со строкой «СДАЧА: » (предмет принял сдаточный лист) замораживается
# только с вердиктом, несущим валидную карту классов; предмет без строки ведётся
# как раньше (граница обязательности — по принятию листа, без ручных списков).
# Двери карты в дереве нет (окно до реализации) — нога пропускается молча.
if printf '%s\\n' "$(g cat-file -p "HEAD:$TARGET" 2>/dev/null)" | grep -q '^СДАЧА: '; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=0
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
NOGA_FREEZE_USPEH_KRASIT = '''# ── 6-карта — мутация PATERN:USPEH-KRASIT (батарея 193) ──────────────────────
# Инициализация результата заменена на 1: успех двери карты его не обнуляет,
# заморозка ложно отказывает и на зелёной карте (блок критика Crit193V1
# К-14). Различающий вход — клетка f03: карта зелёная, честная нога обязана
# пропустить заморозку дальше (отказ позже и по чужой причине).
if printf '%s\\n' "$(g cat-file -p "HEAD:$TARGET" 2>/dev/null)" | grep -q '^СДАЧА: '; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=1
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
YAKOR_FREEZE = '# ── 6а. SPEC-PREFLIGHT'


def tekst(imja: str) -> str:
    return (MIR / imja).read_text(encoding='utf-8')


def git(kuda: Path, *args: str) -> None:
    subprocess.run(['git', '-C', str(kuda), '-c', 'user.name=orchestrator',
                    '-c', 'user.email=orchestrator@dev-harness.local'] + list(args),
                   check=True, capture_output=True)


def patched(istok: Path, jakor: str, noga: str, metka: str) -> str:
    """Реальная дверь + нога; пост-реализация (метка ноги в файле) — как есть."""
    t = istok.read_text(encoding='utf-8')
    if metka in t:
        return t
    if t.count(jakor) != 1:
        raise RuntimeError('YAKOR_NE_UNIKALEN: %s в %s' % (jakor, istok))
    return t.replace(jakor, noga + jakor, 1)


class Istochniki:
    """Субъекты мира: двери — из koren (живое дерево или модель). Ноги
    pre_critic/freeze — патч к реальным дверям живого дерева ТОЛЬКО при
    dostroat_nogi (режимы --model/--stabs: модель — эталон переноса); в
    режимах голый/--repo ноги — РЕАЛЬНЫЕ файлы выбранного дерева без
    достройки проверяемого (К-11 Crit193V1: нет реальной ноги — клетки ног
    красны). Замены для режима --stabs."""

    def __init__(self, koren: Path, dver_zamena=None, karta_zamena=None,
                 pre_mutacija=None, freeze_mutacija=None, dostroat_nogi=False):
        self.koren = koren
        self.dver_zamena = dver_zamena
        self.karta_zamena = karta_zamena
        self.pre_mutacija = pre_mutacija
        self.freeze_mutacija = freeze_mutacija
        self.dostroat_nogi = dostroat_nogi
        self._kesh = {}

    def _skopirovat(self, imja: str, zamena):
        vrem = Path(tempfile.mkdtemp(prefix='subj193-'))
        cel = vrem / imja
        shutil.copy2(zamena if zamena is not None else self.koren / 'scripts' / imja, cel)
        return cel

    def pre_critic(self):
        if 'pre' not in self._kesh:
            if self.dostroat_nogi:
                noga = NOGA_PRE_CRITIC
                if self.pre_mutacija == 'PATERN:IZ-ROOTA':
                    noga = NOGA_PRE_CRITIC_IZ_ROOTA
                elif self.pre_mutacija == 'PATERN:VSEGDA-OTKAZ':
                    noga = NOGA_PRE_CRITIC_VSEGDA_OTKAZ
                t = patched(DEREVO / 'scripts' / 'pre_critic.sh',
                            YAKOR_PRE_CRITIC, noga, '(к) СДАТОЧНЫЙ ЛИСТ')
                vrem = Path(tempfile.mkdtemp(prefix='nog193-'))
                (vrem / 'pre_critic.sh').write_text(t, encoding='utf-8')
                self._kesh['pre'] = vrem / 'pre_critic.sh'
            else:
                put = self.koren / 'scripts' / 'pre_critic.sh'
                self._kesh['pre'] = put if put.exists() else None
        return self._kesh['pre']

    def freeze(self):
        if 'freeze' not in self._kesh:
            if self.dostroat_nogi:
                if self.freeze_mutacija == 'PATERN:BEZ-NOGI':
                    t = (DEREVO / 'scripts' / 'freeze_contract.sh').read_text(encoding='utf-8')
                elif self.freeze_mutacija == 'PATERN:USPEH-KRASIT':
                    t = patched(DEREVO / 'scripts' / 'freeze_contract.sh',
                                YAKOR_FREEZE, NOGA_FREEZE_USPEH_KRASIT, '6-карта')
                else:
                    t = patched(DEREVO / 'scripts' / 'freeze_contract.sh',
                                YAKOR_FREEZE, NOGA_FREEZE, '6-карта')
                vrem = Path(tempfile.mkdtemp(prefix='nog193-'))
                (vrem / 'freeze_contract.sh').write_text(t, encoding='utf-8')
                self._kesh['freeze'] = vrem / 'freeze_contract.sh'
            else:
                put = self.koren / 'scripts' / 'freeze_contract.sh'
                self._kesh['freeze'] = put if put.exists() else None
        return self._kesh['freeze']


def postroit_mir(kuda: Path, ist: Istochniki, kontrakt_f, sdacha_f=None,
                 verdikt_f=None, teg=None, dveri=(), toy_gejty=False,
                 posle_kommita=(), koren_sdacha=None, plany=False) -> Path:
    """Toy-мир батареи 193: git-репозиторий с контрактом, листом, вердиктом.

    dveri ⊆ {'sdacha','karta','pre_critic','freeze'} — субъекты в scripts/ мира
    (замены субъекта берутся из ist: режим --stabs); toy_gejty — копии
    настоящих гейтов живого дерева для ног (а)/(б)/(ж)/(з)/(и) pre_critic.
    """
    for d in ('scripts', 'contracts', 'verdicts/critic', '.github/workflows', 'config'):
        (kuda / d).mkdir(parents=True, exist_ok=True)
    (kuda / 'package.json').write_text(PACKAGE_JSON, encoding='utf-8')
    (kuda / '.github/workflows/ci.yml').write_text(CI_YML, encoding='utf-8')
    (kuda / 'config/ci_parity_exceptions.txt').write_text('', encoding='utf-8')
    for f in MIRSKRIPTY.iterdir():
        shutil.copy2(f, kuda / 'scripts' / f.name)
    if plany:
        (kuda / 'plans').mkdir(exist_ok=True)
        (kuda / 'plans' / '007-toy.md').write_text(
            '# План 007 — toy (батарея 193)\n\n## Незаполненные требования:\nнет\n',
            encoding='utf-8')
    else:
        (kuda / KONTRAKT).write_text(tekst(kontrakt_f), encoding='utf-8')
    if sdacha_f is not None:
        (kuda / 'sdacha.md').write_text(tekst(sdacha_f), encoding='utf-8')
    if koren_sdacha is not None:
        (kuda / 'SDACHA.md').write_text(tekst(koren_sdacha), encoding='utf-8')
    if verdikt_f is not None:
        (kuda / VERDIKT).write_text(tekst(verdikt_f), encoding='utf-8')
    if toy_gejty:
        for f in TOY_GEJTY + LIBS + FORMA_GEJTY:
            shutil.copy2(DEREVO / 'scripts' / f, kuda / 'scripts' / f)
    dver_est = ist.dver_zamena is not None or (ist.koren / 'scripts' / 'check_sdacha.sh').exists()
    karta_est = ist.karta_zamena is not None or (ist.koren / 'scripts' / 'check_verdict_karta.sh').exists()
    if 'sdacha' in dveri and dver_est:
        shutil.copy2(ist._skopirovat('check_sdacha.sh', ist.dver_zamena),
                     kuda / 'scripts' / 'check_sdacha.sh')
    if 'karta' in dveri and karta_est:
        shutil.copy2(ist._skopirovat('check_verdict_karta.sh', ist.karta_zamena),
                     kuda / 'scripts' / 'check_verdict_karta.sh')
    if ('sdacha' in dveri or 'karta' in dveri):
        libka = ist.koren / 'scripts' / 'lib_karta_sdachi.sh'
        if libka.exists():
            shutil.copy2(libka, kuda / 'scripts' / 'lib_karta_sdachi.sh')
    if 'pre_critic' in dveri:
        subj = ist.pre_critic()
        if subj is not None:
            shutil.copy2(subj, kuda / 'scripts' / 'pre_critic.sh')
    if 'freeze' in dveri:
        subj = ist.freeze()
        if subj is not None:
            shutil.copy2(subj, kuda / 'scripts' / 'freeze_contract.sh')
            # libs заморозки — от того же источника, что и сама нога
            lib_istok = DEREVO if ist.dostroat_nogi else ist.koren
            for f in FREEZE_LIBS:
                if (lib_istok / 'scripts' / f).exists():
                    shutil.copy2(lib_istok / 'scripts' / f, kuda / 'scripts' / f)
    git(kuda, 'init', '-q', '-b', 'main')
    git(kuda, 'add', '-A')
    git(kuda, 'commit', '-qm', 'toy193: init')
    if teg == 'zamorozhen':
        git(kuda, 'tag', 'frozen/contracts/777/1')
    elif teg == 'v1-zatem-v2':
        git(kuda, 'tag', 'frozen/contracts/777/1')
        (kuda / KONTRAKT).write_text(tekst('kontrakt_v2_draft.md'), encoding='utf-8')
        git(kuda, 'add', '-A')
        git(kuda, 'commit', '-qm', 'toy193: v+1 draft')
    for otn, soderzhimoe in posle_kommita:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(soderzhimoe, encoding='utf-8')
    return kuda


SPECSY = {
    'chestnyj': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_chestnaja.md',
                     dveri=('sdacha',)),
    'novyj': dict(kontrakt_f='kontrakt_novogo.md', dveri=('sdacha',)),
    'lozhnyj_rc': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_lozhnyj_rc.md',
                       dveri=('sdacha',)),
    'komanda_netu': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_komanda_netu.md',
                         dveri=('sdacha',)),
    'karta_16': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_karta_16.md',
                     dveri=('sdacha',), koren_sdacha='sdacha_chestnaja.md'),
    'status_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_status_vne.md',
                       dveri=('sdacha',)),
    'delta_nepolnaja': dict(kontrakt_f='kontrakt_chestnyj.md',
                            sdacha_f='sdacha_delta_nepolnaja.md',
                            verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'delta_polnaja': dict(kontrakt_f='kontrakt_chestnyj.md',
                          sdacha_f='sdacha_delta_polnaja.md',
                          verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'delta_head': dict(kontrakt_f='kontrakt_chestnyj.md',
                       sdacha_f='sdacha_delta_polnaja.md',
                       verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
                       posle_kommita=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))]),
    'delta_head_nepolnaja': dict(
        kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_delta_nepolnaja.md',
        verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
        posle_kommita=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))]),
    'sposob_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_sposob_vne.md',
                       verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'staryj': dict(kontrakt_f='kontrakt_zamorozhennyj.md', teg='zamorozhen',
                   dveri=('sdacha',)),
    'vplus1': dict(kontrakt_f='kontrakt_zamorozhennyj.md', teg='v1-zatem-v2',
                   dveri=('sdacha',)),
    'plan': dict(kontrakt_f='kontrakt_novogo.md', plany=True, dveri=('sdacha',)),
    'patom': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_s_patom.md',
                  dveri=('sdacha',)),
    'budzhet': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_s_budzhetom.md',
                    dveri=('sdacha',)),
    'budzhet_poslednej': dict(kontrakt_f='kontrakt_chestnyj.md',
                              sdacha_f='sdacha_budzhet_poslednej.md',
                              dveri=('sdacha',)),
    'pustoj_listok': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_pustaja.md',
                          dveri=('sdacha',)),
    'put_vne': dict(kontrakt_f='kontrakt_so_sdachej_vne.md', dveri=('sdacha',)),
    'stroka_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_stroka_vne.md',
                       dveri=('sdacha',)),
    'rekursija': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_rekursivnaja.md',
                      dveri=('sdacha', 'pre_critic'), toy_gejty=True),
    'verdikt_chestnyj': dict(kontrakt_f='kontrakt_novogo.md',
                             verdikt_f='verdikt_chestnyj.md', dveri=('karta',)),
    'verdikt_karta_16': dict(kontrakt_f='kontrakt_novogo.md',
                             verdikt_f='verdikt_karta_16.md', dveri=('karta',)),
    'verdikt_status_vne': dict(kontrakt_f='kontrakt_novogo.md',
                               verdikt_f='verdikt_status_vne.md', dveri=('karta',)),
    'verdikt_pustoj_hvost': dict(kontrakt_f='kontrakt_novogo.md',
                                 verdikt_f='verdikt_pustoj_hvost.md', dveri=('karta',)),
    'verdikt_dubl': dict(kontrakt_f='kontrakt_novogo.md',
                         verdikt_f='verdikt_dubl.md', dveri=('karta',)),
    'verdikt_ne_zakommlchen': dict(
        kontrakt_f='kontrakt_novogo.md', dveri=('karta',),
        posle_kommita=[(VERDIKT, tekst('verdikt_chestnyj.md'))]),
    'freeze_karta': dict(kontrakt_f='kontrakt_chestnyj.md',
                         verdikt_f='verdikt_accept_bez_karty.md',
                         dveri=('karta', 'freeze')),
    'freeze_staryj': dict(kontrakt_f='kontrakt_zamorozhennyj.md',
                          verdikt_f='verdikt_accept_bez_karty.md',
                          dveri=('karta', 'freeze')),
    'freeze_zelenyj': dict(kontrakt_f='kontrakt_chestnyj.md',
                           verdikt_f='verdikt_chestnyj.md',
                           dveri=('karta', 'freeze')),
    'noga_krasna': dict(kontrakt_f='kontrakt_novogo.md', dveri=('sdacha', 'pre_critic'),
                        toy_gejty=True),
    'repo_bez_dveri': dict(kontrakt_f='kontrakt_novogo.md'),
}


class Miry:
    """Миры строятся ленично и по одному; клетка ссылается на свой мир."""

    def __init__(self, vrem: Path, ist: Istochniki):
        self.vrem, self.ist = vrem, ist
        self._miry = {}

    def __getitem__(self, imja: str) -> Path:
        if imja not in self._miry:
            self._miry[imja] = postroit_mir(
                self.vrem / ('mir-' + imja), self.ist, **SPECSY[imja])
        return self._miry[imja]


class Kletka:
    def __init__(self, imja, argv, rc, markery=(), ne_markery=(), env=None, tajmaut=90):
        self.imja, self.argv, self.rc = imja, argv, rc
        self.markery, self.ne_markery = list(markery), list(ne_markery)
        self.env, self.tajmaut = env, tajmaut


def kletki(miry: Miry) -> list:
    K = []

    def dver(imja_mira):
        return ['bash', str(miry[imja_mira] / 'scripts' / 'check_sdacha.sh'),
                str(miry[imja_mira]), KONTRAKT, '--run']

    def karta(imja_mira):
        return ['bash', str(miry[imja_mira] / 'scripts' / 'check_verdict_karta.sh'),
                str(miry[imja_mira]), VERDIKT]

    def zamorozka(imja_mira):
        return ['bash', str(miry[imja_mira] / 'scripts' / 'freeze_contract.sh'),
                KONTRAKT, 'toy-причина-193', str(miry[imja_mira])]

    # половина (а): дверь сдаточного листа
    K.append(Kletka('s01-novyj-bez-sdachi', dver('novyj'), 1, ['СДАЧА:', 'обязательна']))
    K.append(Kletka('s02-chestnyj-listok', dver('chestnyj'), 0, ['лист зелёный']))
    K.append(Kletka('s03-lozhnyj-rc', dver('lozhnyj_rc'), 1, ['фактический rc=1']))
    K.append(Kletka('s04-komanda-netu', dver('komanda_netu'), 1, ['не существует']))
    K.append(Kletka('s05-karta-16', dver('karta_16'), 1, ['К-17']))
    K.append(Kletka('s06-status-vne', dver('status_vne'), 1, ['статус']))
    K.append(Kletka('s07-delta-nepolnaja', dver('delta_nepolnaja'), 1,
                    ['К-02', 'не закрыт']))
    K.append(Kletka('s08-delta-polnaja', dver('delta_polnaja'), 0, ['лист зелёный']))
    K.append(Kletka('s09-sposob-vne', dver('sposob_vne'), 1, ['способ']))
    K.append(Kletka('s10-staryj-zamorozhen', dver('staryj'), 0, ['не требуется']))
    K.append(Kletka('s11-vplus1-objazan', dver('vplus1'), 1, ['обязательна']))
    K.append(Kletka('s12-plan-vne',
                    ['bash', str(miry['plan'] / 'scripts' / 'check_sdacha.sh'),
                     str(miry['plan']), 'plans/007-toy.md', '--run'], 0, ['план']))
    K.append(Kletka('s13-net-git', dver('chestnyj'), 2, ['NOT_IMPLEMENTED', 'git'],
                    env={'PATH': '/nonexistent-193'}))
    K.append(Kletka('s14-tajmaut-komandy', dver('patom'), 1, ['таймаут'],
                    env={'SDACHA_TIMEOUT_SEK': '3'}))
    K.append(Kletka('s15-bjudzhet-lista', dver('budzhet'), 1, ['бюджет'],
                    env={'SDACHA_BUDZHET_SEK': '1'}))
    K.append(Kletka('s16-pustoj-listok', dver('pustoj_listok'), 1, ['без секции']))
    K.append(Kletka('s17-put-vne-kornya', dver('put_vne'), 1, ['путь листа вне грамматики']))
    K.append(Kletka('s18-stroka-vne-grammatiki', dver('stroka_vne'), 1,
                    ['вне грамматики']))
    K.append(Kletka('s19-rekursija-razorvana', dver('rekursija'), 0, ['лист зелёный'],
                    tajmaut=60))
    # К-08 Crit193V1: предыдущий вердикт — ТОЛЬКО HEAD-блоб; рабочий файл
    # вердикта скрывает блоки К-01/К-02 (закоммичены), суждение — по HEAD.
    K.append(Kletka('s20-verdikt-tolko-head', dver('delta_head'), 0, ['лист зелёный']))
    K.append(Kletka('s21-rabochij-verdikt-skryvaet-blok', dver('delta_head_nepolnaja'),
                    1, ['К-02', 'не закрыт']))
    # К-07 Crit193V1: бюджет листа ограничивает и ВЫПОЛНЯЮЩУЮСЯ (последнюю)
    # команду; честная команда в пределах бюджета зелёная (s23).
    K.append(Kletka('s22-bjudzhet-poslednej-komandy', dver('budzhet_poslednej'), 1,
                    ['бюджет'],
                    env={'SDACHA_BUDZHET_SEK': '1', 'SDACHA_TIMEOUT_SEK': '10'}))
    K.append(Kletka('s23-bjudzhet-chestnyj-v-predelah', dver('budzhet_poslednej'), 0,
                    ['лист зелёный'],
                    env={'SDACHA_BUDZHET_SEK': '5', 'SDACHA_TIMEOUT_SEK': '10'}))
    # половина (б): дверь карты вердикта
    K.append(Kletka('v01-chestnyj-verdikt', karta('verdikt_chestnyj'), 0, ['17/17']))
    K.append(Kletka('v02-karta-16', karta('verdikt_karta_16'), 1, ['К-17']))
    K.append(Kletka('v03-status-vne', karta('verdikt_status_vne'), 1, ['статус']))
    K.append(Kletka('v04-pustoj-hvost', karta('verdikt_pustoj_hvost'), 1,
                    ['без команды или входа']))
    K.append(Kletka('v05-ne-zakommlchen', karta('verdikt_ne_zakommlchen'), 1,
                    ['не закоммичен']))
    K.append(Kletka('v06-dubl-klassa', karta('verdikt_dubl'), 1, ['дубль']))
    # ноги: заморозка и pre_critic
    K.append(Kletka('f01-freeze-karta-krasna', zamorozka('freeze_karta'), 1,
                    ['карта классов вердикта']))
    K.append(Kletka('f02-freeze-staryj-bez-karty', zamorozka('freeze_staryj'), 1,
                    [], ['карта классов вердикта']))
    # К-14 Crit193V1: положительный мир ноги карты — карта зелёная, честная
    # нога пропускает заморозку дальше (отказ позже, по чужой причине —
    # spec-preflight rc 127 в toy-мире); ложный отказ ноги различается.
    K.append(Kletka('f03-freeze-noga-zelenaja', zamorozka('freeze_zelenyj'), 1,
                    ['spec-preflight'], ne_markery=['карта классов вердикта']))
    # p01 моделирует ПРЯМОЙ вызов pre_critic оркестратором (маркер рекурсии
    # погашен явно): внутри прогона двери листа маркер наследуется — и нога (к)
    # по канону И6 молчит; прямому вызову маркер не положен.
    K.append(Kletka('p01-noga-sdacha-krasna',
                    ['bash', str(miry['noga_krasna'] / 'scripts' / 'pre_critic.sh'),
                     KONTRAKT], 1, ['ОТКАЗ: сдаточный лист красен'],
                    env={'SDACHA_OKRUG': '0'}))
    K.append(Kletka('p02-noga-propuskaet-chuzhoj-mir',
                    ['bash', str(miry['rekursija'] / 'scripts' / 'pre_critic.sh'),
                     '--repo', str(miry['repo_bez_dveri']), KONTRAKT], 0,
                    ['КРИТИК: дверь зелёная']))
    # К-14 Crit193V1: положительный мир ноги (к) — честный лист, вооружённая
    # зелёная дверь, прямой вызов (маркер погашен): нога обязана пропустить.
    K.append(Kletka('p03-noga-listok-zelenyj',
                    ['bash', str(miry['rekursija'] / 'scripts' / 'pre_critic.sh'),
                     KONTRAKT], 0, ['КРИТИК: дверь зелёная'],
                    env={'SDACHA_OKRUG': '0'}))
    return K


def sudit(k: Kletka) -> bool:
    env = dict(os.environ)
    argv = list(k.argv)
    if k.env and 'PATH' in k.env and argv[0] == 'bash':
        argv[0] = shutil.which('bash') or '/bin/bash'
    if k.env:
        env.update(k.env)
    try:
        p = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                             text=True, env=env, start_new_session=True)
        try:
            out, err = p.communicate(timeout=k.tajmaut)
            rc, vyvod = p.returncode, out + err
        except subprocess.TimeoutExpired:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
            p.communicate()
            rc, vyvod = None, 'TIMEOUT'
    except FileNotFoundError:
        rc, vyvod = None, 'SUBJECT_ABSENT'
    ok = (rc == k.rc
          and all(m in vyvod for m in k.markery)
          and all(m not in vyvod for m in k.ne_markery))
    pervyj = (vyvod.strip().splitlines() or ['<пусто>'])[0]
    print('193 %s %s rc=%s %s' % (k.imja, 'ok' if ok else 'KRASNO', rc, pervyj[:110]))
    return ok


def predposylki() -> None:
    for instrument in ('python3', 'git', 'bash'):
        r = subprocess.run(['bash', '-c', 'command -v %s' % instrument],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print('LIVE_PREDPOSYLKA: нет %s — нечем исполнять батарею 193 '
                  '(чистый клон без зависимостей — именованный отказ, не '
                  'skip→pass)' % instrument, file=sys.stderr)
            sys.exit(2)


def rezhim_suda(miry: Miry) -> int:
    K = kletki(miry)
    zel = sum(1 for k in K if sudit(k))
    kras = len(K) - zel
    print('ИТОГ 193: rc=%d KLETKI=%d ZELENYE=%d KRASNYE=%d'
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
    poimano, zhivyh = 0, 0
    for imja, fail, kletka_imja in svjazi:
        dver_zamena = karta_zamena = pre_mut = freeze_mut = None
        if imja.startswith('PATERN:'):
            if fail == 'scripts/pre_critic.sh':
                pre_mut = imja
            elif fail == 'scripts/freeze_contract.sh':
                freeze_mut = imja
            else:
                print('ORACLE_TAMPERED: PATERN вне алфавита ног: %s' % fail,
                      file=sys.stderr)
                return 2
        else:
            put = STABS / imja
            if fail == 'scripts/check_sdacha.sh':
                dver_zamena = put
            elif fail == 'scripts/check_verdict_karta.sh':
                karta_zamena = put
            else:
                print('ORACLE_TAMPERED: заменяемый файл вне алфавита: %s' % fail,
                      file=sys.stderr)
                return 2
        ist = Istochniki(MODEL, dver_zamena=dver_zamena, karta_zamena=karta_zamena,
                         pre_mutacija=pre_mut, freeze_mutacija=freeze_mut,
                         dostroat_nogi=True)
        miry = Miry(vrem / ('obmanka-' + imja.replace(':', '_')), ist)
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
        print('193 %s %s' % (imja, 'POIMAN' if ulov else 'ZHIV — дефект не различим'))
    print('ИТОГ 193: rc=%d OBMANOK=%d POIMANY=%d ZHIVYH=%d'
          % (0 if zhivyh == 0 else 1, len(svjazi), poimano, zhivyh))
    return 0 if zhivyh == 0 else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', default=None)
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    predposylki()
    vrem = Path(tempfile.mkdtemp(prefix='batareja-193-'))
    rc = 1
    try:
        if args.stabs:
            rc = rezhim_stabs(vrem)
        elif args.model:
            rc = rezhim_suda(Miry(vrem, Istochniki(MODEL, dostroat_nogi=True)))
        else:
            koren = Path(args.repo).resolve() if args.repo else DEREVO.resolve()
            rc = rezhim_suda(Miry(vrem, Istochniki(koren)))
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
    return rc


if __name__ == '__main__':
    sys.exit(main())
