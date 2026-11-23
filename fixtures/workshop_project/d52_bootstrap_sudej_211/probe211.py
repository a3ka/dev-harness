#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 211 (§ПРОВОДКА): судит дверь замка предмета
# scripts/zamok_predmeta.sh — [D64 bootstrap-sudej]: судья РЕАЛИЗАЦИИ
# (reviewer/adversary) при недоступном закреплённом frozen (frozen_predmeta
# отказал) читает класс риска из ДЕРЕВА OBJECT по УДОСТОВЕРЕННОМУ локальному
# frozen-тегу НОВОЙ версии предмета (аннотированный тег; коммит заморозки —
# предок OBJECT; блобы contracts/<NNN>-*.md в OBJECT и в заморозке равны
# побайтно). Промах — прежнее поведение (KLASS_RISKA_NET → предмет
# рисковый). critic — как прежде (D52); порядок судей рискового не меняется.
# Эталон — model/zamok_predmeta.sh: дверь базы (HEAD 10ff5df41 — носитель
# реализации 208; scripts/zamok_predmeta.sh sha256 47de5c02…) + дельта D64
# (helpers, ветвь, 4-й аргумент klass_riska); семья 208 зелена против модели
# как субъекта (--sosed-208); реализация несёт ту же семантику.
# Привязки стаб↔клетка — ТОЛЬКО source.json:.stab_vhod (Н-39: проза
# контракта пар не утверждает; якорь стаба — кратность 1 в тексте модели).
# Оракул — source.json в памяти ДО вызова субъекта (правило 8); носители —
# sha256; рассинхрон множеств — rc 2 ORACLE_TAMPERED.
#
# Каждая клетка сравнивает rc, stdout И stderr ПОЛНОСТЬЮ байт-в-байт
# (арбитраж 208): ожидания фиксируются в памяти ДО вызова субъекта — и для
# модели, и для стабов, и для производственного слоя одинаково. Обе трубы
# субъекта захватываются БАЙТАМИ (subprocess без text=True), между захватом
# и сравнением нет ни декодирования, ни перевода строк, ни strip.
# Границы наблюдения — адресные стабы (GRANICY × TRUBY_VYHODA: ПРЕДУПРЕЖДЕНИЕ
# predupr, ОТКАЗ otp, PUSCHEM), привязки — source.json:.stab_vhod.
#
# Режимы:
#   (без флага) / --repo <корень>
#         субъект = <корень>/scripts/zamok_predmeta.sh (корень по умолчанию —
#         toplevel репозитория батареи). До реализации клетки bootstrap
#         красны (перечень поимённо), итог rc 1; нет субъекта — rc 1
#         SUBJECT_ABSENT с перечнем всех входов.
#   --model   контроль входов на эталоне, строгие ожидания вывода.
#   --stabs   контроль + матрица обманных стабов над текстом модели
#         (ЖИВЫХ 0); якорь потерян или синтаксис сломан — rc 2.
#   --sgeneriruj-staby (обслуживание) материализует stabs/<имя>/ и
#         source.json (nositeli).
#   --sosed-208  модель как субъект семьи 208: в отдельном корне под $TMPDIR
#         scripts/zamok_predmeta.sh = модель побайтно, батарея 208 — её
#         штатным --repo <корень>; вывод и rc — её собственные.
#   --negativ-208  негатив к --sosed-208 (Б-2 Rev211 вызов 1): мутация
#         модели «kodovaja_granica — третья копия белого списка путей
#         вердиктов из базы ДО unification (glob .review/* вместо единого
#         предиката verdikt_put)», якорь кратности 1, обязана красить
#         РОВНО r31/r32 семьи 208 — иначе --sosed-208 не различает модель
#         актуальной базы от устаревшей (rc 1); якорь потерян либо сломан
#         синтаксис — rc 2 ORACLE_TAMPERED.
# Коды возврата: 0 — зелено; 1 — красная клетка либо STAB_ZHIV либо субъекта
# нет; 2 — нечем проверять (нет git/jq, ORACLE_TAMPERED, дрейф стабов/модели).
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'zamok_predmeta.sh'
STABS = HERE / 'stabs'
SOURCE = HERE / 'source.json'
KOREN = HERE.parents[2]  # корень репозитория батареи: fixtures/workshop_project/<пачка>
SOSED_208 = HERE.parent / 'zamok_object_predok_208' / 'red_zamok_object_predok_208.sh'

# негатив к --sosed-208: якорь (кратность 1) и мутация — третья копия белого
# списка путей вердиктов в kodovaja_granica возвращается к форме базы ДО
# unification (glob .review/*), ровно то расхождение, на котором критик
# вызов 1 поймал устаревшую модель (r31/r32)
JAKOR_NEG_208 = '    verdikt_put "$n" "$p" || return 0\n'
MUTACIJA_NEG_208 = ('    [[ "$p" =~ ^verdicts/(critic|adversary|review)/contracts-$n'
                     '(-[A-Za-z0-9._-]+)?\\.md$ \\\n'
                     '      || "$p" == .review/* ]] || return 0\n')
NEGATIV_208_KRASNYE = ['r31-review-txt-vperjod', 'r32-review-vlozhenyj-vperjod']

REPO_ID = 'dev-harness'
HARNESS_REMOTE = 'ssh://git@github.com/a3ka/dev-harness.git'
SUBJ = '211'
CHUZHIE_SUBEKTY = ('137', '209')  # миры НЕ-211: константа предмета наблюдаема (урок Adv208)

GIT_ENV = dict(os.environ)
GIT_ENV.update({
    'GIT_CONFIG_GLOBAL': '/dev/null',
    'GIT_CONFIG_SYSTEM': '/dev/null',
    'GIT_CONFIG_NOSYSTEM': '1',
    'LC_ALL': 'C',
})


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def run(cmd, cwd=None, env=None, timeout=120):
    # БАЙТЫ на обеих трубах (арбитраж 208): без text=True — universal
    # newlines превращал бы CRLF/CR в LF до сравнения вывода субъекта
    return subprocess.run(cmd, capture_output=True, cwd=cwd,
                          env=env if env is not None else GIT_ENV,
                          timeout=timeout)


def plumbing(r):
    # вывод ИНСТРУМЕНТА мира (git plumbing: sha, путь) → str; к сравнению
    # вывода субъекта отношения не имеет
    return r.stdout.decode('utf-8', 'surrogateescape').strip()


def diag(b, predel=200):
    # ТОЛЬКО печать диагностик: декодирование с заменой, сравнения нет
    return (b or b'').decode('utf-8', 'replace').strip()[:predel]


# ── мир: состояние + журналы + реестр станции ───────────────────────────────
class Mir:
    def __init__(self, root):
        self.root = Path(root)
        self.sost = self.root / 'sost'
        self.zhurnaly = self.root / 'zhurnaly' / 'parent1'
        self.repo = self.root / 'repo'
        self.ledger = self.sost / 'uchet.jsonl'
        for d in (self.sost, self.zhurnaly, self.repo / 'contracts',
                  self.repo / 'registry'):
            d.mkdir(parents=True, exist_ok=True)
        self.ledger.touch()
        g = run(['git', 'init', '-q', '.'], cwd=str(self.repo))
        assert g.returncode == 0, g.stderr
        self.git(['remote', 'add', 'origin', HARNESS_REMOTE])
        self.git(['commit', '-q', '--allow-empty', '-m', 'init'])

    def git(self, args):
        return run(['git', '-c', 'user.name=battery', '-c',
                    'user.email=b@t', '-c', 'commit.gpgsign=false'] + args,
                   cwd=str(self.repo))

    def stancija_teg(self, wt, subj, commit, versija='1', legkij=False,
                     imja_tega=None):
        # frozen-тег (обычно annotated) В РЕПОЗИТОРИИ ВЛАДЕЛЬЦА (станции);
        # строка реестра НЕ пишется — REPLACE ещё не влит (боль предмета);
        # imja_tega — точное имя тега (id/CONTRACT/<NNN> для минт-строки)
        r = self.git(['fetch', '-q', wt, commit])
        assert r.returncode == 0, r.stderr
        tag = imja_tega or 'frozen/contracts/%s/%s' % (subj, versija)
        if legkij:
            r = self.git(['tag', tag, commit])
        else:
            r = self.git(['tag', '-a', tag, '-m', 'fixture frozen', commit])
        assert r.returncode == 0, r.stderr
        return plumbing(self.git(['rev-parse', tag]))

    def stancija_stroka(self, subj, objsha):
        # строка реестра на HEAD станции (REPLACE влит/минт)
        registry = self.repo / 'registry/contracts.tsv'
        rows = registry.read_text().splitlines() if registry.exists() else []
        rows = [row for row in rows if not row.startswith(subj + ' → ')]
        if objsha is not None:
            rows = rows + [subj + ' → ' + objsha]
        registry.write_text(('\n'.join(rows) + '\n') if rows else '',
                            encoding='utf-8')
        self.git(['add', 'registry/contracts.tsv'])
        r = self.git(['commit', '-q', '-m', 'row ' + subj])
        assert r.returncode == 0, r.stderr

    def zhurnal(self, holder, sdal=False):
        f = self.zhurnaly / ('%s.jsonl' % holder)
        body = ('{"timestamp":"2026-11-23T10:00:00.000Z",'
                '"message":{"role":"assistant"}}\n')
        if sdal:
            body += ('{"type":"toolResult","toolCallId":"toolu_x",'
                     '"toolName":"yield",'
                     '"content":[{"type":"text","text":"Result submitted."}]}\n')
        f.write_text(body, encoding='utf-8')

    def start(self, nnn, holder, klass='rabochij', rol='architect',
              wt='-', branch='-', obj='-', zanyat=True):
        line = {'t': 'START', 'repoId': REPO_ID, 'subjectId': nnn,
                'group': 'harness', 'holder': holder, 'klass': klass,
                'rol': rol, 'object': obj, 'worktree': wt, 'branch': branch,
                'at': '2026-11-23T10:00:00Z'}
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps(line, ensure_ascii=False) + '\n')
        if zanyat:
            zd = self.sost / 'zamki' / REPO_ID / nnn / 'zanyat'
            zd.mkdir(parents=True, exist_ok=True)
            (zd / 'holder.json').write_text(
                json.dumps({'holder': holder, 'klass': klass, 'rol': rol,
                            'object': obj,
                            'startedAt': '2026-11-23T10:00:00Z'}) + '\n',
                encoding='utf-8')

    def release(self, nnn, holder, prichina='verdikt_zakommiten'):
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'RELEASE', 'repoId': REPO_ID,
                                 'subjectId': nnn, 'holder': holder,
                                 'prichina': prichina,
                                 'at': '2026-11-23T10:00:00Z'}) + '\n')

    def sobytie(self, path, items):
        p = self.root / path
        p.write_text(json.dumps({'tasks': items}, ensure_ascii=False),
                     encoding='utf-8')
        return str(p)

    def ledg(self):
        # учёт — файл, написанный субъектом: читается БАЙТАМИ, каждая строка
        # LF разбирается json.loads
        rows = []
        for ln in self.ledger.read_bytes().split(b'\n'):
            if ln.strip():
                rows.append(json.loads(ln))
        return rows


def wt_git(wt, *args, role='b'):
    return run(['git', '-c', 'user.name=' + role, '-c',
                'user.email=' + role + '@t', '-c', 'commit.gpgsign=false']
               + list(args), cwd=str(wt))


def item(agent, name, stroki):
    return {'agent': agent, 'name': name, 'task': '\n'.join(stroki)}


def sudit(door, mir, event):
    # cwd — КОРЕНЬ РЕПОЗИТОРИЯ БАТАРЕИ, не cwd вызывающего: модель и обманные
    # копии лежат вне scripts/, и резолвер профиля двери (profile_paths) берёт
    # соседа scripts/next_id.sh из репозитория рабочего каталога.
    return run(['bash', str(door), '--sudit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo),
                str(event)], cwd=str(KOREN))


# ── строители мира предмета ──────────────────────────────────────────────────
def kontrakt_tekst(subj, klass):
    # klass=None — файл БЕЗ строки класса (класс не определён)
    if klass is None:
        return '# Контракт %s (фикстура)\nтекст без декларации класса\n' % subj
    return '# Контракт %s (фикстура)\nКЛАСС РИСКА: %s\n' % (subj, klass)


def nositel(m, subj, klass_f='обычный', chto_esche=('readme.txt', 'ЧИТАЙ\n'),
            kat='contracts', profil=None):
    # авторский носитель: ветка wip/<subj>/impl, коммит заморозки F
    # (контракт предмета + chto_esche); klass_f=None — без строки класса;
    # kat — каталог контракта в носителе; profil — каталог контрактов профиля
    # проекта, закоммиченного в носителе (клон владельца несёт его профиль)
    wt = m.root / ('wt%s' % subj)
    wt.mkdir(parents=True, exist_ok=True)
    g = run(['git', 'init', '-q', '.'], cwd=str(wt))
    assert g.returncode == 0, g.stderr
    run(['git', 'remote', 'add', 'origin', HARNESS_REMOTE], cwd=str(wt))
    br = 'wip/%s/impl' % subj
    run(['git', 'checkout', '-q', '-b', br], cwd=str(wt))
    katdir = wt / kat
    katdir.mkdir(parents=True, exist_ok=True)
    (katdir / ('%s-fixture.md' % subj)).write_text(
        kontrakt_tekst(subj, klass_f), encoding='utf-8')
    if chto_esche:
        imja, dannye = chto_esche
        p = wt / imja
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(dannye, encoding='utf-8')
    if profil is not None:
        profil_proekta(wt, profil)
    run(['git', 'add', '-A'], cwd=str(wt))
    run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t',
         'commit', '-q', '-m', 'F'], cwd=str(wt))
    return str(wt), br, plumbing(run(['git', 'rev-parse', 'HEAD'], cwd=str(wt)))


def kommit(wt, imja, dannye, soobshenie='w', role='b'):
    # коммит в носителе; возвращает sha
    p = Path(wt) / imja
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(dannye, encoding='utf-8')
    wt_git(wt, 'add', '-A')
    wt_git(wt, 'commit', '-q', '-m', soobshenie, role=role)
    return plumbing(wt_git(wt, 'rev-parse', 'HEAD'))

def kommit_vse(wt, soobshenie='w'):
    # коммит уже подготовленных изменений (add -A); возвращает sha
    wt_git(wt, 'add', '-A')
    wt_git(wt, 'commit', '-q', '-m', soobshenie)
    return plumbing(wt_git(wt, 'rev-parse', 'HEAD'))

def perepisat_kontrakt(wt, subj, klass, kat='contracts'):
    (Path(wt) / kat / ('%s-fixture.md' % subj)).write_text(
        kontrakt_tekst(subj, klass), encoding='utf-8')


def mir_bootstrap(m, subj=SUBJ, klass_f='обычный', klass_w=None,
                  chto_esche=('readme.txt', 'ЧИТАЙ\n'), kat='contracts',
                  profil=None):
    # F (заморозка, klass_f) → W (работа; klass_w задан — контракт в OBJECT
    # переписан ПОСЛЕ заморозки); возвращает (wt, br, F, W)
    wt, br, F = nositel(m, subj, klass_f=klass_f, chto_esche=chto_esche,
                        kat=kat, profil=profil)
    if klass_w is not None:
        perepisat_kontrakt(wt, subj, klass_w, kat)
    W = kommit(wt, 'rabota/impl.txt', 'rabota\n', soobshenie='W')
    return wt, br, F, W


def avtor_sdal(m, subj, wt, br):
    m.start(subj, 'Impl%s' % subj, wt=wt, branch=br)
    m.zhurnal('Impl%s' % subj, sdal=True)


PROFIL_SLOJ = dict(schemaVersion=1, version='1', projectId='toy211',
                   workspaceId='toy', defaults={})


def profil_proekta(repo, kontrakty='x'):
    # валидный профиль проекта (та же грамматика profile_resolver.sh, что в
    # мирах 140): workflowPaths.contracts = kontrakty, слой .profile/project.json
    (Path(repo) / '.profile').mkdir(parents=True, exist_ok=True)
    (Path(repo) / '.profile' / 'project.json').write_text(
        json.dumps(PROFIL_SLOJ), encoding='utf-8')
    vp = dict(schemaVersion=1, repoId=REPO_ID, language='bash',
              projectLayer=dict(version='1',
                                profilePath='.profile/project.json'),
              workflowPaths=dict(contracts=kontrakty, verdicts='verdicts',
                                 registry='registry', fixtures='fixtures'))
    (Path(repo) / 'harness.project.json').write_text(json.dumps(vp),
                                                     encoding='utf-8')


def legacy_stroka(wt, obj, subj, kat='contracts'):
    # blob файла контракта в дереве OBJECT — plumbing самого git (для строки
    # legacy-реестра D30: <blob>\t<класс>\t<основание>\t<подтвердил>)
    return plumbing(run(['git', '-C', str(wt), 'rev-parse',
                         '%s:%s/%s-fixture.md' % (obj, kat, subj)]))


def legacy_avtora(m, wt, obj, subj, kat='contracts'):
    # НЕЗАКОММИЧЕННЫЙ registry/risk-legacy.tsv в рабочем дереве носителя
    # АВТОРА (мир критика 211, БЛОК-1): «<blob> → обычный»
    k = Path(wt) / 'registry'
    k.mkdir(exist_ok=True)
    (k / 'risk-legacy.tsv').write_text(
        legacy_stroka(wt, obj, subj, kat) + '\tобычный\tоснование\tподтвердил\n',
        encoding='utf-8')
    st = run(['git', '-C', str(wt), 'status', '--porcelain'])
    assert b'?? registry/' in st.stdout, 'legacy-файл автора закоммичен: %r' % st.stdout


def legacy_vladelcy(m, wt, obj, subj, kat='contracts'):
    # строка legacy-реестра ВЛАДЕЛЬЦА (станции) — закоммичена на HEAD станции
    (m.repo / 'registry' / 'risk-legacy.tsv').write_text(
        legacy_stroka(wt, obj, subj, kat) + '\tобычный\tоснование\tподтвердил\n',
        encoding='utf-8')
    m.git(['add', 'registry/risk-legacy.tsv'])
    r = m.git(['commit', '-q', '-m', 'legacy ' + subj])
    assert r.returncode == 0, r.stderr


def profil_avtora(m, wt, kontrakty='x'):
    # НЕЗАКОММИЧЕННЫЙ профиль проекта в рабочем дереве носителя АВТОРА
    # (сосед мира БЛОКА-1: профиль, как и legacy-реестр, читался из $wt)
    profil_proekta(wt, kontrakty)
    st = run(['git', '-C', str(wt), 'status', '--porcelain'])
    assert b'?? harness.project.json' in st.stdout, 'профиль автора закоммичен: %r' % st.stdout

def krug_adv(m, subj, obj, holder='AdvPred'):
    # завершённый круг адверсария на OBJECT (порядок D14)
    m.start(subj, holder, klass='sudja', rol='adversary', obj=obj, zanyat=False)
    m.zhurnal(holder, sdal=True)
    m.release(subj, holder)


def vyzov(m, rol, name, obj, subj=SUBJ):
    return m.sobytie('e.json', [item(rol, name,
                                     ['SUBJECT=' + subj, 'OBJECT=' + obj])])


# ── проверки: каждая возвращает None (ок) либо строку-причину ───────────────
def k_rc(r, want, chto):
    if r.returncode != want:
        return '%s: rc %s ≠ %s (stderr: %s)' % (chto, r.returncode, want,
                                                diag(r.stderr))
    return None


def bajty(ozhidaemyj):
    return ozhidaemyj.encode('utf-8') if isinstance(ozhidaemyj, str) \
        else ozhidaemyj


def k_vyvod(fakt, ozhidaemyj, truba, chto):
    # ЕДИНЫЙ предикат вывода: ПОЛНАЯ труба — bytes, ожидание — bytes; между
    # захватом и этой строкой нет ни декодирования, ни перевода строк, ни
    # strip — CRLF, CR, пробел в конце, двойной LF, BOM, NUL, не-UTF8 байт,
    # лишний вывод и перенос между трубами различимы (стабы GRANICY)
    ozh = bajty(ozhidaemyj)
    fakt = fakt or b''
    if fakt == ozh:
        return None
    i = 0
    while i < min(len(fakt), len(ozh)) and fakt[i] == ozh[i]:
        i += 1
    return ('%s: %s байт-в-байт ≠ ожиданию: первое расхождение на байте %d '
            '(факт %s, ожидание %s; длины %d/%d); факт %r ≠ ожидание %r'
            % (chto, truba, i,
               '0x%02x' % fakt[i] if i < len(fakt) else 'конец',
               '0x%02x' % ozh[i] if i < len(ozh) else 'конец',
               len(fakt), len(ozh),
               fakt.decode('utf-8', 'replace'),
               ozh.decode('utf-8', 'replace')))


def k_text(r, ozhidaemyj, chto):
    return k_vyvod(r.stderr, ozhidaemyj, 'stderr', chto)


def k_stdout(r, ozhidaemyj, chto):
    return k_vyvod(r.stdout, ozhidaemyj, 'stdout', chto)


def k_start(mir, holder, obj, chto):
    rows = mir.ledg()
    posl = rows[-1] if rows else {}
    if posl.get('t') != 'START' or posl.get('holder') != holder \
            or posl.get('object') != obj:
        return '%s: последняя строка учёта не START %s/%s: %r' % (
            chto, holder, obj, posl)
    return None


def k_uchet_ne_izmenen(mir, do, chto):
    if mir.ledger.read_bytes() != do:
        return '%s: отказ переписал учёт' % chto
    return None


def puschem(name, subj, rol):
    return 'PUSCHEM %s %s/%s (sudja/%s)\n' % (name, REPO_ID, subj, rol)


def predupr_zakrep(subj):
    return ('ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: предмет %s: закреплённый frozen '
            'недоступен — класс не определён, предмет считается рисковым\n'
            % subj)


def predupr_neodnoznachno(subj):
    return ('ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: предмет %s: класс риска '
            'неоднозначно определён (neodnoznachno); файлы: '
            '%s-fixture.md — класс не определён, предмет считается рисковым\n'
            % (subj, subj))


def otkaz_adv_do_rev(subj):
    return ('ОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет %s рисковый, завершённого '
            'адверсария в учёте нет — ревьюер раньше адверсария запрещён\n'
            % subj)


# ── клетки ───────────────────────────────────────────────────────────────────
def kejsy():
    K = {}

    def reg(imja, os, fn):
        assert imja not in K
        K[imja] = (os, fn)

    def b01(m, door):
        # bootstrap: тег /1 на предке F, байты равны, строки на main нет —
        # адверсарий допускается БЕЗ предупреждения (боль 204/177-класса)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b01'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b01'),
                k_text(r, '', 'b01'), k_start(m, 'Adv211', W, 'b01')]

    def b02(m, door):
        # то же для ревьюера: класс обычный из OBJECT — ревьюер ДО
        # адверсария допускается (порядок рискового не навязан)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b02'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b02'),
                k_text(r, '', 'b02'), k_start(m, 'Rev211', W, 'b02')]

    def b03(m, door):
        # класс из OBJECT — РИСКОВЫЙ: ревьюер без завершённого адверсария
        # отказан (порядок сохранён), предупреждения KLASS_RISKA_NET нет
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'рисковый')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b03'), k_stdout(r, '', 'b03'),
                k_text(r, otkaz_adv_do_rev(SUBJ), 'b03'),
                k_uchet_ne_izmenen(m, do, 'b03')]

    def b04(m, door):
        # рисковый из OBJECT + завершённый адверсарий — ревьюер допускается
        # чисто (порядок adversary → reviewer работает)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'рисковый')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        krug_adv(m, SUBJ, W)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b04'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b04'),
                k_text(r, '', 'b04'), k_start(m, 'Rev211', W, 'b04')]

    def b05(m, door):
        # подмена класса в OBJECT ПОСЛЕ заморозки (рисковый → обычный):
        # байты разошлись — bootstrap не применяется, прежнее поведение
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'рисковый', klass_w='обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b05'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b05'),
                k_text(r, predupr_zakrep(SUBJ), 'b05'),
                k_start(m, 'Adv211', W, 'b05')]

    def b06(m, door):
        # ЧУЖОЙ tag-object: тег /1 на боковом коммите F2 (байты контракта
        # равны, но F2 НЕ предок OBJECT) — прежнее поведение
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        wt_git(wt, 'checkout', '-q', '-b', 'side', F)
        F2 = kommit(wt, 'bok.txt', 'боковая линия\n', soobshenie='F2')
        wt_git(wt, 'checkout', '-q', br)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F2)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b06'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b06'),
                k_text(r, predupr_zakrep(SUBJ), 'b06'),
                k_start(m, 'Adv211', W, 'b06')]

    def b07(m, door):
        # НЕТ тега у владельца (ноль frozen-тегов) — прежнее поведение
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b07'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b07'),
                k_text(r, predupr_zakrep(SUBJ), 'b07'),
                k_start(m, 'Adv211', W, 'b07')]

    def b08(m, door):
        # строка на main хранит ID-ТЕГ (минт), не frozen (замер Rev204):
        # frozen_predmeta отказал → bootstrap → ревьюер допускается чисто
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        idt = m.stancija_teg(wt, SUBJ, plumbing(m.git(['rev-parse', 'HEAD'])),
                             imja_tega='id/CONTRACT/%s' % SUBJ)
        m.stancija_stroka(SUBJ, idt)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b08'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b08'),
                k_text(r, '', 'b08'), k_start(m, 'Rev211', W, 'b08')]

    def b09(m, door):
        # critic-ветка НЕ меняется: живой frozen-тег + нет строки на main —
        # прежний KLASS_RISKA_NET (D52 bootstrap только при нуле тегов)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'critic', 'Crit211', W))
        return [k_rc(r, 0, 'b09'), k_stdout(r, puschem('Crit211', SUBJ, 'critic'), 'b09'),
                k_text(r, predupr_zakrep(SUBJ), 'b09'),
                k_start(m, 'Crit211', W, 'b09')]

    def b10(m, door):
        # две версии /1 /2: OBJECT от /2 (байты /2) — выбор НОВОЙ версии,
        # класс обычный из OBJECT, ревьюер чисто
        wt, br, F1, _ = mir_bootstrap(m, SUBJ, 'рисковый')
        perepisat_kontrakt(wt, SUBJ, 'обычный')
        F2 = kommit_vse(wt, 'F2')
        W = kommit(wt, 'rabota/impl2.txt', 'rabota\n', soobshenie='W2')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F1, versija='1')
        m.stancija_teg(wt, SUBJ, F2, versija='2')
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b10'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b10'),
                k_text(r, '', 'b10'), k_start(m, 'Rev211', W, 'b10')]

    def b11(m, door):
        # /1 совпадает с OBJECT, но жива /2 (не предок, другой текст):
        # новая версия не удостоверена — прежний отказ (старая не спасает)
        wt, br, F1, W = mir_bootstrap(m, SUBJ, 'обычный')
        wt_git(wt, 'checkout', '-q', '-b', 'side2', W)
        perepisat_kontrakt(wt, SUBJ, 'рисковый')
        F2 = kommit(wt, 'x2.txt', 'вторая заморозка\n', soobshenie='F2')
        wt_git(wt, 'checkout', '-q', br)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F1, versija='1')
        m.stancija_teg(wt, SUBJ, F2, versija='2')
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b11'), k_stdout(r, '', 'b11'),
                k_text(r, predupr_zakrep(SUBJ) + otkaz_adv_do_rev(SUBJ), 'b11'),
                k_uchet_ne_izmenen(m, do, 'b11')]

    def b12(m, door):
        # строка на main УКАЗЫВАЕТ на frozen (REPLACE влит) — класс из
        # ЗАКРЕПЛЁННОГО frozen, bootstrap не участвует: ревьюер чисто даже
        # при разошедшемся тексте OBJECT
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный', klass_w='рисковый')
        avtor_sdal(m, SUBJ, wt, br)
        tegobj = m.stancija_teg(wt, SUBJ, F)
        m.stancija_stroka(SUBJ, tegobj)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b12'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b12'),
                k_text(r, '', 'b12'), k_start(m, 'Rev211', W, 'b12')]

    def b13(m, door):
        # закреплённый frozen говорит РИСКОВЫЙ — порядок судей прежний:
        # ревьюер без адверсария отказан (D14 не ослаблен bootstrap-блоком)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'рисковый')
        avtor_sdal(m, SUBJ, wt, br)
        tegobj = m.stancija_teg(wt, SUBJ, F)
        m.stancija_stroka(SUBJ, tegobj)
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b13'), k_stdout(r, '', 'b13'),
                k_text(r, otkaz_adv_do_rev(SUBJ), 'b13'),
                k_uchet_ne_izmenen(m, do, 'b13')]

    def b14(m, door):
        # bootstrap удостоверен, но строки класса нет ни в frozen, ни в
        # OBJECT: klass_riska из OBJECT → neodnoznachno → прежний код
        # предупреждения с диагностикой неоднозначности, предмет рисковый
        wt, br, F, W = mir_bootstrap(m, SUBJ, None)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b14'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b14'),
                k_text(r, predupr_neodnoznachno(SUBJ), 'b14'),
                k_start(m, 'Adv211', W, 'b14')]

    def b15(m, door):
        # ЛЕГКИЙ (не annotated) тег под frozen/ — не заморозка: прежний
        # отказ (требование объект-тега)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F, legkij=True)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b15'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b15'),
                k_text(r, predupr_zakrep(SUBJ), 'b15'),
                k_start(m, 'Adv211', W, 'b15')]

    def b16(m, door):
        # предмет НЕ 211 (137): bootstrap работает для любого предмета —
        # константа предмета в двери наблюдаема (урок Adv208)
        subj = CHUZHIE_SUBEKTY[0]
        wt, br, F, W = mir_bootstrap(m, subj, 'обычный')
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, subj, F)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev137', W, subj=subj))
        return [k_rc(r, 0, 'b16'), k_stdout(r, puschem('Rev137', subj, 'reviewer'), 'b16'),
                k_text(r, '', 'b16'), k_start(m, 'Rev137', W, 'b16')]

    def b17(m, door):
        # тег ЧУЖОГО предмета (209) на предке OBJECT предмета 137 —
        # предметный префикс frozen/contracts/<NNN>/ обязателен
        subj = CHUZHIE_SUBEKTY[0]
        chuzhoj = CHUZHIE_SUBEKTY[1]
        wt, br, F, W = mir_bootstrap(m, subj, 'обычный')
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, chuzhoj, F)
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev137', W, subj=subj))
        return [k_rc(r, 1, 'b17'), k_stdout(r, '', 'b17'),
                k_text(r, predupr_zakrep(subj) + otkaz_adv_do_rev(subj), 'b17'),
                k_uchet_ne_izmenen(m, do, 'b17')]

    def b18(m, door):
        # НЕЧИСЛОВАЯ версия тега (rc1) — вне грамматики заморозки: пропуск,
        # прежний отказ (валидатор версии не пускает мусор)
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F, versija='rc1')
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b18'), k_stdout(r, '', 'b18'),
                k_text(r, predupr_zakrep(SUBJ) + otkaz_adv_do_rev(SUBJ), 'b18'),
                k_uchet_ne_izmenen(m, do, 'b18')]

    def b19(m, door):
        # НЕТ файлов contracts/<NNN>-*.md ни в OBJECT, ни в заморозке —
        # пустой перечень не удостоверяет текст: прежний отказ
        wt, br, F, _ = mir_bootstrap(m, SUBJ, None,
                                      chto_esche=('readme.txt', 'ЧИТАЙ\n'))
        rr = run(['git', '-C', str(wt), 'rm', '-q',
                  'contracts/%s-fixture.md' % SUBJ])
        assert rr.returncode == 0, rr.stderr
        wt_git(wt, 'commit', '-q', '-m', 'bez kontrakta')
        F = plumbing(wt_git(wt, 'rev-parse', 'HEAD'))
        W = kommit(wt, 'rabota/impl.txt', 'rabota\n', soobshenie='W')
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv211', W))
        return [k_rc(r, 0, 'b19'), k_stdout(r, puschem('Adv211', SUBJ, 'adversary'), 'b19'),
                k_text(r, predupr_zakrep(SUBJ), 'b19'),
                k_start(m, 'Adv211', W, 'b19')]

    def b20(m, door):
        # версии /2 и /10: лексический порядок тегов (…/10 < …/2) отличен от
        # числового — выбор только ЧИСЛОВЫМ максимумом (/10); /10 не
        # удостоверен для OBJECT → прежний отказ, «последний ref» не годится
        wt, br, F, W = mir_bootstrap(m, SUBJ, 'обычный')
        wt_git(wt, 'checkout', '-q', '-b', 'side10', W)
        perepisat_kontrakt(wt, SUBJ, 'рисковый')
        F10 = kommit(wt, 'x10.txt', 'десятая версия\n', soobshenie='F10')
        wt_git(wt, 'checkout', '-q', br)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F, versija='2')
        m.stancija_teg(wt, SUBJ, F10, versija='10')
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b20'), k_stdout(r, '', 'b20'),
                k_text(r, predupr_zakrep(SUBJ) + otkaz_adv_do_rev(SUBJ), 'b20'),
                k_uchet_ne_izmenen(m, do, 'b20')]

    def b21(m, door):
        # мир критика (БЛОК-1 Rev211): bootstrap удостоверен, строки класса
        # нет, в НОСИТЕЛЕ АВТОРА незакоммиченный registry/risk-legacy.tsv
        # «<blob> → обычный». Класс даёт не автор: прежний отказ байтами —
        # диагностика неоднозначности + ADVERSARIJ_DO_REVJUERA, учёт не изменён
        wt, br, F, W = mir_bootstrap(m, SUBJ, None)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        legacy_avtora(m, wt, W, SUBJ)
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 1, 'b21'), k_stdout(r, '', 'b21'),
                k_text(r, predupr_neodnoznachno(SUBJ) + otkaz_adv_do_rev(SUBJ), 'b21'),
                k_uchet_ne_izmenen(m, do, 'b21')]

    def b22(m, door):
        # профиль НОСИТЕЛЯ АВТОРА (незакоммиченный harness.project.json:
        # каталог контрактов → x) и приманка x/<NNN>-fake.md «обычный»,
        # закоммиченная в заморозку; настоящий контракт «рисковый». Класс
        # читается из каталога профиля ВЛАДЕЛЬЦА — ревьюер отказан без
        # предупреждения KLASS_RISKA_NET, учёт не изменён
        subj = CHUZHIE_SUBEKTY[0]
        wt, br, F, W = mir_bootstrap(m, subj, 'рисковый',
                                     chto_esche=('x/%s-fake.md' % subj,
                                                 kontrakt_tekst(subj, 'обычный')))
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, subj, F)
        profil_avtora(m, wt, 'x')
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev137', W, subj=subj))
        return [k_rc(r, 1, 'b22'), k_stdout(r, '', 'b22'),
                k_text(r, otkaz_adv_do_rev(subj), 'b22'),
                k_uchet_ne_izmenen(m, do, 'b22')]

    def b23(m, door):
        # та же подделка профиля автора, но приманка добавлена ПОСЛЕ заморозки
        # (есть только в OBJECT): перечень сверяется по каталогу профиля
        # ВЛАДЕЛЬЦА (contracts/ — равен), bootstrap удостоверен, адверсарий
        # чисто; с каталогом автора перечень разошёлся бы — было бы предупреждение
        subj = CHUZHIE_SUBEKTY[1]
        wt, br, F, _ = mir_bootstrap(m, subj, 'обычный')
        W = kommit(wt, 'x/%s-fake.md' % subj, kontrakt_tekst(subj, 'обычный'),
                   soobshenie='primanka')
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, subj, F)
        profil_avtora(m, wt, 'x')
        r = sudit(door, m, vyzov(m, 'adversary', 'Adv209', W, subj=subj))
        return [k_rc(r, 0, 'b23'), k_stdout(r, puschem('Adv209', subj, 'adversary'), 'b23'),
                k_text(r, '', 'b23'), k_start(m, 'Adv209', W, 'b23')]

    def b24(m, door):
        # честная запись legacy-реестра ВЛАДЕЛЬЦА (строка «<blob> → обычный»
        # закоммичена на HEAD станции), строки класса в тексте нет: класс
        # читается из реестра владельца — тот же источник, что у D42/D30, —
        # ревьюер допускается чисто
        wt, br, F, W = mir_bootstrap(m, SUBJ, None)
        avtor_sdal(m, SUBJ, wt, br)
        m.stancija_teg(wt, SUBJ, F)
        legacy_vladelcy(m, wt, W, SUBJ)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b24'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b24'),
                k_text(r, '', 'b24'), k_start(m, 'Rev211', W, 'b24')]

    def b25(m, door):
        # версии /1 и /999999999999999999999999999999 (вне int64): новая
        # версия — числовой максимум сравнением digit-строк; она не предок
        # OBJECT — прежний отказ. Арифметика shell такую версию теряет и
        # оставляет старую /1 (совет С-1 Rev211)
        subj = CHUZHIE_SUBEKTY[0]
        wt, br, F1, W = mir_bootstrap(m, subj, 'обычный')
        wt_git(wt, 'checkout', '-q', '-b', 'side-big', W)
        perepisat_kontrakt(wt, subj, 'рисковый')
        F2 = kommit(wt, 'x-big.txt', 'большая версия\n', soobshenie='F2')
        wt_git(wt, 'checkout', '-q', br)
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, subj, F1, versija='1')
        m.stancija_teg(wt, subj, F2, versija='999999999999999999999999999999')
        do = m.ledger.read_bytes()
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev137', W, subj=subj))
        return [k_rc(r, 1, 'b25'), k_stdout(r, '', 'b25'),
                k_text(r, predupr_zakrep(subj) + otkaz_adv_do_rev(subj), 'b25'),
                k_uchet_ne_izmenen(m, do, 'b25')]

    def b26(m, door):
        # честный профиль ВЛАДЕЛЬЦА: у станции каталог контрактов профиля — x
        # (клон-носитель несёт тот же закоммиченный профиль), контракт лежит
        # в x/<NNN>-fixture.md. Класс читается по профилю владельца — ревьюер
        # допускается чисто (продукты с путями профиля вне contracts/)
        subj = CHUZHIE_SUBEKTY[1]
        profil_proekta(m.repo, 'x')
        m.git(['add', '-A'])
        r = m.git(['commit', '-q', '-m', 'profil stancii'])
        assert r.returncode == 0, r.stderr
        wt, br, F, W = mir_bootstrap(m, subj, 'обычный', kat='x', profil='x')
        avtor_sdal(m, subj, wt, br)
        m.stancija_teg(wt, subj, F)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev209', W, subj=subj))
        return [k_rc(r, 0, 'b26'), k_stdout(r, puschem('Rev209', subj, 'reviewer'), 'b26'),
                k_text(r, '', 'b26'), k_start(m, 'Rev209', W, 'b26')]

    def b27(m, door):
        # РЕГРЕСС пути D42 (вне D64): закреплённый frozen доступен (строка
        # REPLACE на HEAD станции), строки класса в замороженном тексте нет,
        # legacy-строка — в реестре ВЛАДЕЛЬЦА. Класс читается как в базе —
        # ревьюер допускается чисто: 4-й аргумент klass_riska этот путь не меняет
        wt, br, F, W = mir_bootstrap(m, SUBJ, None)
        avtor_sdal(m, SUBJ, wt, br)
        tegobj = m.stancija_teg(wt, SUBJ, F)
        m.stancija_stroka(SUBJ, tegobj)
        legacy_vladelcy(m, wt, W, SUBJ)
        r = sudit(door, m, vyzov(m, 'reviewer', 'Rev211', W))
        return [k_rc(r, 0, 'b27'), k_stdout(r, puschem('Rev211', SUBJ, 'reviewer'), 'b27'),
                k_text(r, '', 'b27'), k_start(m, 'Rev211', W, 'b27')]

    reg('b01-bootstrap-adversary',
        'тег /1 на предке, байты равны, строки на main нет — адверсарий без предупреждения',
        b01)
    reg('b02-bootstrap-reviewer-obychnyj',
        'класс обычный из OBJECT — ревьюер до адверсария допускается',
        b02)
    reg('b03-bootstrap-risikovyj-porjadok',
        'класс рисковый из OBJECT — ревьюер без адверсария отказан, предупреждения нет',
        b03)
    reg('b04-bootstrap-posle-adversarija',
        'рисковый из OBJECT + завершённый адверсарий — ревьюер чисто',
        b04)
    reg('b05-podmena-klassa-v-objecte',
        'правка контракта в OBJECT после заморозки — прежний отказ байтами',
        b05)
    reg('b06-chuzoj-tag-object',
        'тег на боковом коммите (не предок) — прежний отказ байтами',
        b06)
    reg('b07-net-tega',
        'ноль frozen-тегов у владельца — прежний отказ байтами',
        b07)
    reg('b08-id-teg-v-stroke-na-main',
        'строка на main хранит id-тег (замер Rev204) — bootstrap даёт ревьюеру класс',
        b08)
    reg('b09-critic-ne-menjaetsja',
        'critic при живом теге без строки на main — прежний отказ байтами (D52)',
        b09)
    reg('b10-versija-vtoraja',
        '/1 и /2: OBJECT от /2 — выбор новой версии, класс из OBJECT',
        b10)
    reg('b11-starejshaja-versija-sovpadaet',
        '/1 совпадает, жива /2 — новая версия не удостоверена: прежний отказ',
        b11)
    reg('b12-zakreplennyj-frozen-prioritet',
        'REPLACE на main влит — класс из закреплённого frozen, bootstrap не нужен',
        b12)
    reg('b13-frozen-risikovyj-porjadok',
        'закреплённый frozen рисковый — D14 не ослаблен',
        b13)
    reg('b14-net-stroki-klassa',
        'bootstrap удостоверен, строки класса нет — neodnoznachno, рисковый',
        b14)
    reg('b15-legkij-teg',
        'лёгкий (не annotated) тег — не заморозка, прежний отказ',
        b15)
    reg('b16-chuzoj-predmet-bootstrap',
        'предмет 137: bootstrap предметен, константа 211 наблюдаема',
        b16)
    reg('b17-chuzoj-predmet-teg',
        'тег чужого предмета (209) на предке — предметный префикс обязателен',
        b17)
    reg('b18-nechislovaja-versija',
        'нечисловая версия тега (rc1) — пропуск, прежний отказ',
        b18)
    reg('b19-net-fajlov-kontrakta',
        'пустой перечень contracts/<NNN>-*.md — прежний отказ',
        b19)
    reg('b20-versii-leksika-ne-chislo',
        'версии /2 и /10: лексический порядок (…/10 < …/2) отличен от числового — выбор числовым максимумом',
        b20)
    reg('b21-legacy-avtora-ne-istochnik',
        'незакоммиченный legacy-реестр автора + текст без строки класса — класс даёт не автор: прежний отказ байтами',
        b21)
    reg('b22-profil-avtora-ne-istochnik',
        'незакоммиченный профиль автора ведёт в каталог-приманку — класс из каталога профиля владельца: ревьюер отказан',
        b22)
    reg('b23-spisok-po-profilju-vladelca',
        'приманка после заморозки видна только каталогу автора — перечень сверяется по профилю владельца: адверсарий чисто',
        b23)
    reg('b24-legacy-vladelca-rabotaet',
        'legacy-строка ВЛАДЕЛЬЦА (HEAD станции) + текст без строки класса — класс из реестра владельца, ревьюер чисто',
        b24)
    reg('b25-versija-vne-int64',
        'версия вне int64 — числовой максимум сравнением digit-строк: новая версия не удостоверена, прежний отказ',
        b25)
    reg('b26-profil-vladelca-rabotaet',
        'каталог контрактов из профиля ВЛАДЕЛЬЦА (x/) — класс читается по нему, ревьюер чисто',
        b26)
    reg('b27-legacy-na-puti-d42-bez-izmenenij',
        'регресс D42: закреплённый frozen + текст без строки класса + legacy-строка владельца — класс как в базе, ревьюер чисто',
        b27)
    return K


# ── обманные стабы: якорь кратности 1 в тексте модели → мутация ─────────────
def _mut(tekst, jakor, zamena):
    n = tekst.count(jakor)
    assert n == 1, 'якорь не кратен 1 (%d): %r' % (n, jakor[:80])
    return tekst.replace(jakor, zamena, 1)


STAB_MUTACII = {
    'st01-rol-tolko-sudi': lambda t: _mut(
        t, '''        elif [ "$rol" = reviewer ] || [ "$rol" = adversary ]; then''',
        '''        elif true; then'''),
    'st02-frozen-vsegda': lambda t: _mut(
        t, '''        if [ -n "$P_FROZEN" ]; then
          kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"''',
        '''        if false; then
          kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"'''),
    'st03-bez-bajtov': lambda t: _mut(
        t, '''  [ -n "$spO" ] && [ "$spO" = "$spF" ] || return 1''',
        '''  true'''),
    'st04-bez-predka': lambda t: _mut(
        t, '''  git -C "$wt" merge-base --is-ancestor "$F" "$obj" 2>/dev/null || return 1''',
        '''  true'''),
    'st05-pervyj-teg': lambda t: _mut(
        t, r'''| LC_ALL=C sort -t$'\t' -k1,1n -k2,2 | tail -n 1 | cut -f3)"''',
        r'''| LC_ALL=C sort -t$'\t' -k1,1n -k2,2 | head -n 1 | cut -f3)"'''),
    'st06-legkij-teg': lambda t: _mut(
        t, '''  [ "$(git -C "$owner" cat-file -t "$tagobj" 2>/dev/null)" = tag ] || return 1''',
        '''  true'''),
    'st07-predmet-konstanta': lambda t: _mut(
        t, '''"refs/tags/frozen/contracts/$n/" 2>/dev/null \\''',
        '''"refs/tags/frozen/contracts/211/" 2>/dev/null \\'''),
    'st08-ljuboj-predmet': lambda t: _mut(
        t, '''"refs/tags/frozen/contracts/$n/" 2>/dev/null \\''',
        '''"refs/tags/frozen/contracts/" 2>/dev/null \\'''),
    'st09-versija-ljubaja': lambda t: _mut(
        t, r"""{v=$NF} v ~ /^[1-9][0-9]*$/ {print""",
        r"""{v=$NF} {print"""),
    'st10-poslednij-ref': lambda t: _mut(
        t, r'''LC_ALL=C sort -t$'\t' -k1,1n -k2,2''',
        r'''LC_ALL=C sort -t$'\t' -k2,2'''),
    'st11-pustoj-spisok': lambda t: _mut(
        t, '''  [ -n "$spO" ] && [ "$spO" = "$spF" ] || return 1''',
        '''  [ "$spO" = "$spF" ] || return 1'''),
    'st12-repo-nositelja': lambda t: _mut(
        t, '''  tagobj="$(poslednj_frozen_teg "$n" "$owner")" || return 1''',
        '''  tagobj="$(poslednj_frozen_teg "$n" "$wt")" || return 1'''),
    'st43-koren-avtora-v-vyzove': lambda t: _mut(
        t, r"""kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt" "$risk_repo")"; kr_det=""" + "''",
        r"""kr="$(klass_riska "$sv" "$r_wt" "$obj_fakt")"; kr_det=""" + "''"),
    'st44-profil-iz-nositelja-v-klasse': lambda t: _mut(
        t, r"""  kat="$(kontrakt_kat "$owner")" || kat=""" + "''",
        r"""  kat="$(kontrakt_kat "$wt")" || kat=""" + "''"),
    'st45-legacy-iz-nositelja': lambda t: _mut(
        t, r'''    if [ -z "$val" ] && [ -f "$owner/registry/risk-legacy.tsv" ]; then
      val="$(awk -F'\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}' "$owner/registry/risk-legacy.tsv")"''',
        r'''    if [ -z "$val" ] && [ -f "$wt/registry/risk-legacy.tsv" ]; then
      val="$(awk -F'\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}' "$wt/registry/risk-legacy.tsv")"'''),
    'st46-profil-iz-nositelja-v-sverke': lambda t: _mut(
        t, '''  kat="$(kontrakt_kat "$owner")" || return 1''',
        '''  kat="$(kontrakt_kat "$wt")" || return 1'''),
    'st47-katalog-po-umolchaniju-v-sverke': lambda t: _mut(
        t, '''  kat="$(kontrakt_kat "$owner")" || return 1''',
        r"""  kat='contracts'"""),
    'st48-katalog-po-umolchaniju-v-klasse': lambda t: _mut(
        t, r"""  kat="$(kontrakt_kat "$owner")" || kat=""" + "''",
        r"""  kat='contracts'"""),
    'st49-versija-arifmetikoj-shell': lambda t: _mut(
        t, r'''  teg="$(git -C "$owner" for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$n/" 2>/dev/null \
    | awk -F/ '{v=$NF} v ~ /^[1-9][0-9]*$/ {print length(v) "\t" v "\t" $0}' \
    | LC_ALL=C sort -t$'\t' -k1,1n -k2,2 | tail -n 1 | cut -f3)"''',
        r'''  local ref v maxv=0
  teg=''
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    v="${ref##*/}"
    [[ "$v" =~ ^[1-9][0-9]*$ ]] || continue
    if [ "$v" -gt "$maxv" ]; then maxv="$v"; teg="$ref"; fi
  done < <(git -C "$owner" for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$n/" 2>/dev/null)'''),
    'st50-umolchanie-vladelca-pusto': lambda t: _mut(
        t, r'''  owner="${4:-$wt}"''',
        r'''  owner="${4:-}"'''),
}

STAB_VHOD = {
    'st01-rol-tolko-sudi': ['b09-critic-ne-menjaetsja'],
    'st02-frozen-vsegda': ['b12-zakreplennyj-frozen-prioritet'],
    'st03-bez-bajtov': ['b05-podmena-klassa-v-objecte'],
    'st04-bez-predka': ['b06-chuzoj-tag-object'],
    'st05-pervyj-teg': ['b11-starejshaja-versija-sovpadaet'],
    'st06-legkij-teg': ['b15-legkij-teg'],
    'st07-predmet-konstanta': ['b16-chuzoj-predmet-bootstrap'],
    'st08-ljuboj-predmet': ['b17-chuzoj-predmet-teg'],
    'st09-versija-ljubaja': ['b18-nechislovaja-versija'],
    'st10-poslednij-ref': ['b20-versii-leksika-ne-chislo'],
    'st11-pustoj-spisok': ['b19-net-fajlov-kontrakta'],
    'st12-repo-nositelja': ['b01-bootstrap-adversary'],
    'st43-koren-avtora-v-vyzove': ['b21-legacy-avtora-ne-istochnik',
                                   'b22-profil-avtora-ne-istochnik'],
    'st44-profil-iz-nositelja-v-klasse': ['b22-profil-avtora-ne-istochnik'],
    'st45-legacy-iz-nositelja': ['b21-legacy-avtora-ne-istochnik'],
    'st46-profil-iz-nositelja-v-sverke': ['b23-spisok-po-profilju-vladelca'],
    'st47-katalog-po-umolchaniju-v-sverke': ['b26-profil-vladelca-rabotaet'],
    'st48-katalog-po-umolchaniju-v-klasse': ['b26-profil-vladelca-rabotaet'],
    'st49-versija-arifmetikoj-shell': ['b25-versija-vne-int64'],
    'st50-umolchanie-vladelca-pusto': ['b27-legacy-na-puti-d42-bez-izmenenij'],
}


# ── границы НАБЛЮДЕНИЯ (rc, stdout bytes, stderr bytes) — арбитраж 208 ──────
# Мутация ОДНОЙ операции печати честной модели: тексты, ветви и rc двери не
# меняются — меняются только ВЫХОДНЫЕ БАЙТЫ и/или труба. На каждую трубу
# (ПРЕДУПРЕЖДЕНИЕ predupr, ОТКАЗ otp, PUSCHEM stdout) — границы GRANICY
# (изменены байты СВОЕЙ строки), перенос (та же печать — в другую трубу) и
# лишняя строка в ТИХУЮ трубу. Поля строки GRANICY: имя · префикс формата ·
# добавка к телу · терминатор — escape-строки bash printf.
GRANICY = (
    ('crlf', '', '', r'\r\n'),
    ('odinochnyj-cr', '', '', r'\r'),
    ('probel-v-konce', '', ' ', r'\n'),
    ('dvojnoj-lf', '', '', r'\n\n'),
    ('bom', r'\xEF\xBB\xBF', '', r'\n'),
    ('nul', '', r'\x00', r'\n'),
    ('ne-utf8', r'\xFF', '', r'\n'),
    ('lishnij-vyvod', '', '', r'\nLISHNJAJA stroka\n'),
)
TRUBY_VYHODA = (
    # (труба · тело формата · печать как в модели · та же печать в другую
    #  трубу · имя тихой трубы · её перенаправление · клетка — вход, где
    #  байты этой трубы различимы)
    ('predupr', 'ПРЕДУПРЕЖДЕНИЕ: %s: %s',
     r'''printf 'ПРЕДУПРЕЖДЕНИЕ: %s: %s\n' "$kod" "$det" >&2''',
     r'''printf 'ПРЕДУПРЕЖДЕНИЕ: %s: %s\n' "$kod" "$det"''',
     'stdout', '',
     ('b05-podmena-klassa-v-objecte',)),
    ('otkaz', 'ОТКАЗ: %s: %s',
     r'''printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2''',
     r'''printf 'ОТКАЗ: %s: %s\n' "$1" "$2"''',
     'stdout', '',
     ('b03-bootstrap-risikovyj-porjadok',)),
    ('puschem', 'PUSCHEM %s %s/%s (%s/%s)',
     r'''printf 'PUSCHEM %s %s/%s (%s/%s)\n' "$name" "$REPO_ID" "$sv" "$klass" "$rol"''',
     r'''printf 'PUSCHEM %s %s/%s (%s/%s)\n' "$name" "$REPO_ID" "$sv" "$klass" "$rol" >&2''',
     'stderr', ' >&2',
     ('b01-bootstrap-adversary',)),
)


def stab_pechati(jakor, zamena):
    return lambda t: _mut(t, jakor, zamena)


def stab_vyhoda(telo, pref, dobavka, term):
    jakor = "printf '%s\\n'" % telo
    zamena = "printf '%s%s%s%s'" % (pref, telo, dobavka, term)
    return stab_pechati(jakor, zamena)


def _dobavit_staby_vyhoda():
    nomer = 13
    for truba, telo, pechat, v_druguju, tihaja, napr, vhody in TRUBY_VYHODA:
        for granica, pref, dobavka, term in GRANICY:
            imja = 'st%02d-%s-%s' % (nomer, truba, granica)
            STAB_MUTACII[imja] = stab_vyhoda(telo, pref, dobavka, term)
            STAB_VHOD[imja] = list(vhody)
            nomer += 1
        lishnjaja = "; printf 'LISHNJAJA stroka\\n'%s" % napr
        for suffiks, zamena in (('perenos', v_druguju),
                                ('lishnij-v-' + tihaja, pechat + lishnjaja)):
            imja = 'st%02d-%s-%s' % (nomer, truba, suffiks)
            STAB_MUTACII[imja] = stab_pechati(pechat, zamena)
            STAB_VHOD[imja] = list(vhody)
            nomer += 1


_dobavit_staby_vyhoda()


# ── прогон одной клетки: rc, stdout и stderr байт-в-байт в каждом режиме ────
def prognot_kletku(fn, door):
    tmp = tempfile.mkdtemp(prefix='zamok211-')
    problemy = []
    try:
        m = Mir(tmp)
        for ch in fn(m, door):
            if ch:
                problemy.append(ch)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return problemy


def sosed_208():
    # модель как субъект семьи 208 (БЛОК-2 Rev211): в отдельном корне под
    # $TMPDIR единственный файл scripts/zamok_predmeta.sh — модель побайтно;
    # батарея 208 запускается её штатным режимом --repo <корень> из корня
    # репозитория батареи; вывод и rc — её собственные, обёртка не маскирует
    if not MODEL.is_file() or not SOSED_208.is_file():
        print('NOT_IMPLEMENTED: нет модели или батареи 208', file=sys.stderr)
        return 2
    katalog = Path(tempfile.mkdtemp(prefix='zamok211-sosed-'))
    try:
        (katalog / 'scripts').mkdir()
        dver = katalog / 'scripts' / 'zamok_predmeta.sh'
        dver.write_bytes(MODEL.read_bytes())
        os.chmod(dver, 0o755)
        r = subprocess.run(['bash', str(SOSED_208), '--repo', str(katalog)],
                           cwd=str(KOREN), env=GIT_ENV)
        return r.returncode
    finally:
        shutil.rmtree(katalog, ignore_errors=True)


def negativ_208():
    # негатив к --sosed-208 (Б-2 Rev211 вызов 1): мутация «kodovaja_granica —
    # третья копия белого списка путей вердиктов из базы ДО unification
    # verdikt_put» обязана красить РОВНО r31/r32 семьи 208; иное множество
    # либо зелень — режим --sosed-208 не различает эталон от устаревшей базы
    if not MODEL.is_file() or not SOSED_208.is_file():
        print('NOT_IMPLEMENTED: нет модели или батареи 208', file=sys.stderr)
        return 2
    tekst = tekst_modeli()
    if tekst.count(JAKOR_NEG_208) != 1:
        print('ORACLE_TAMPERED: якорь негатива 208 не кратности 1: %r'
              % JAKOR_NEG_208, file=sys.stderr)
        return 2
    mut = tekst.replace(JAKOR_NEG_208, MUTACIJA_NEG_208)
    sint = subprocess.run(['bash', '-n', '/dev/stdin'],
                          input=mut.encode('utf-8'), capture_output=True,
                          env=GIT_ENV)
    if sint.returncode != 0:
        print('ORACLE_TAMPERED: мутация негатива сломала синтаксис: %s'
              % diag(sint.stderr), file=sys.stderr)
        return 2
    katalog = Path(tempfile.mkdtemp(prefix='zamok211-negativ-'))
    try:
        (katalog / 'scripts').mkdir()
        dver = katalog / 'scripts' / 'zamok_predmeta.sh'
        dver.write_bytes(mut.encode('utf-8'))
        os.chmod(dver, 0o755)
        r = subprocess.run(['bash', str(SOSED_208), '--repo', str(katalog)],
                           cwd=str(KOREN), env=GIT_ENV, capture_output=True)
        krasnye = sorted({ln[len('KRASNAJA-KLETKA '):].split(':', 1)[0]
                          for ln in r.stdout.decode('utf-8', 'replace').splitlines()
                          if ln.startswith('KRASNAJA-KLETKA ')})
        if r.returncode != 1 or krasnye != NEGATIV_208_KRASNYE:
            print('NEGATIV 208: rc %d, krasnye: %s — ждали ровно %s%s'
                  % (r.returncode, ', '.join(krasnye) or '-',
                     ', '.join(NEGATIV_208_KRASNYE),
                     '' if krasnye else ' (%s)' % diag(r.stderr)))
            return 1
        print('NEGATIV 208: KLETKI 35 KRASNYH %d (%s) — режим --sosed-208 '
              'различает базу без verdikt_put'
              % (len(krasnye), ', '.join(krasnye)))
        return 0
    finally:
        shutil.rmtree(katalog, ignore_errors=True)

def subjekt_repo(koren=None):
    if koren:
        root = Path(koren).resolve()
    else:
        g = run(['git', '-C', str(HERE), 'rev-parse', '--show-toplevel'])
        if g.returncode != 0:
            return None
        root = Path(plumbing(g))
    d = root / 'scripts' / 'zamok_predmeta.sh'
    return d if d.is_file() else None


def zashita_zavisimostej():
    for b in ('git', 'jq', 'bash'):
        if shutil.which(b) is None:
            print('NOT_IMPLEMENTED: нет %s' % b, file=sys.stderr)
            sys.exit(2)


def istochnik():
    if not SOURCE.is_file():
        print('ORACLE_TAMPERED: нет source.json', file=sys.stderr)
        sys.exit(2)
    return json.loads(SOURCE.read_text(encoding='utf-8'))


def nositeli_sverka(src):
    ploho = []
    for otn, pin in src.get('nositeli', {}).items():
        p = HERE / otn
        if not p.is_file() or sha256_bytes(p.read_bytes()) != pin:
            ploho.append(otn)
    if ploho:
        print('ORACLE_TAMPERED: дрейф носителей: %s' % ', '.join(ploho),
              file=sys.stderr)
        sys.exit(2)


def tekst_modeli():
    # текст модели — БАЙТЫ файла, декодированные без перевода строк: стаб
    # отличается от модели ровно одной мутацией
    return MODEL.read_bytes().decode('utf-8')


def sgeneriruj():
    tekst = tekst_modeli()
    K = kejsy()
    # устаревшие копии (имя вышло из матрицы) в census не остаются
    if STABS.is_dir():
        for d in STABS.iterdir():
            if d.is_dir() and d.name not in STAB_MUTACII:
                shutil.rmtree(d, ignore_errors=True)
    for imja, fn in sorted(STAB_MUTACII.items()):
        mut = fn(tekst)
        sint = subprocess.run(['bash', '-n', '/dev/stdin'],
                              input=mut.encode('utf-8'), capture_output=True,
                              env=GIT_ENV)
        if sint.returncode != 0:
            raise SystemExit('ORACLE_TAMPERED: стаб %s сломал синтаксис: %s'
                             % (imja, diag(sint.stderr)))
        d = STABS / imja
        d.mkdir(parents=True, exist_ok=True)
        (d / 'zamok_predmeta.sh').write_bytes(mut.encode('utf-8'))
        os.chmod(d / 'zamok_predmeta.sh', 0o755)
    nositeli = {'model/zamok_predmeta.sh':
                sha256_bytes(MODEL.read_bytes())}
    for imja in sorted(STAB_MUTACII):
        otn = 'stabs/%s/zamok_predmeta.sh' % imja
        nositeli[otn] = sha256_bytes((HERE / otn).read_bytes())
    src = {
        'versija': 1,
        'kontrakt': 'contracts/211-d52-bootstrap-sudej.md',
        'subjekt': 'scripts/zamok_predmeta.sh',
        'model': 'model/zamok_predmeta.sh',
        'kejsy': {imja: os for imja, (os, _) in sorted(K.items())},
        'stab_vhod': {k: sorted(v) for k, v in sorted(STAB_VHOD.items())},
        'nositeli': dict(sorted(nositeli.items())),
        'zametki': 'привязки стаб↔клетка — единственный источник (Н-39); '
                   'якорь каждой мутации — кратность 1 в тексте модели',
    }
    SOURCE.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
                      encoding='utf-8')
    print('SGENERIROVANO stabov %d kletok %d' % (len(STAB_MUTACII), len(K)))


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--repo', nargs='?', const='', default=None)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--sgeneriruj-staby', action='store_true')
    ap.add_argument('--sintaksis', action='store_true')
    ap.add_argument('--sosed-208', action='store_true')
    ap.add_argument('--negativ-208', action='store_true')
    argj = ap.parse_args()
    if getattr(argj, 'sintaksis', False):
        # носители пачки синтаксически цельны: модель и (если поставлен)
        # субъект дерева; rc 1 — сломан носитель, rc 2 — нечем проверить
        zashita_zavisimostej()
        ploho = []
        for put, imja in ((MODEL, 'model'),
                          (HERE.parent.parent.parent
                           / 'scripts' / 'zamok_predmeta.sh', 'subjekt')):
            if not put.is_file():
                continue
            r = run(['bash', '-n', str(put)])
            if r.returncode != 0:
                ploho.append('%s: %s' % (imja, diag(r.stderr)))
        if ploho:
            for s in ploho:
                print('SINTAKSIS KRASNO: %s' % s)
            return 1
        print('SINTAKSIS OK')
        return 0
    zashita_zavisimostej()
    if argj.sosed_208:
        return sosed_208()
    if argj.negativ_208:
        return negativ_208()

    if argj.sgeneriruj_staby:
        sgeneriruj()
        return 0

    K = kejsy()
    src = istochnik()
    if sorted(src.get('kejsy', {})) != sorted(K):
        print('ORACLE_TAMPERED: рассинхрон перечня клеток с source.json',
              file=sys.stderr)
        sys.exit(2)
    if sorted(src.get('stab_vhod', {})) != sorted(STAB_MUTACII):
        print('ORACLE_TAMPERED: рассинхрон перечня стабов с source.json',
              file=sys.stderr)
        sys.exit(2)
    for st, vhod in STAB_VHOD.items():
        for c in vhod:
            if c not in K:
                print('ORACLE_TAMPERED: стаб %s ведёт на неизвестную клетку %s'
                      % (st, c), file=sys.stderr)
                sys.exit(2)

    if argj.model or argj.stabs:
        nositeli_sverka(src)
        krasnye = []
        for imja, (_, fn) in sorted(K.items()):
            for p in prognot_kletku(fn, MODEL):
                krasnye.append('%s: %s' % (imja, p))
        if krasnye:
            print('MODEL 211: KLETKI %d KRASNYH %d' % (len(K), len(krasnye)))
            for s in krasnye:
                print('KRASNAJA-KLETKA %s' % s)
            return 1
        print('MODEL 211: KLETKI %d KRASNYH 0' % len(K))
        if not argj.stabs:
            return 0
        tekst = tekst_modeli()
        zhivyh = 0
        svjazi = 0
        for imja, fn in sorted(STAB_MUTACII.items()):
            try:
                mut = fn(tekst)
            except AssertionError as e:
                print('ORACLE_TAMPERED: %s: %s' % (imja, e), file=sys.stderr)
                sys.exit(2)
            katalog = Path(tempfile.mkdtemp(prefix='stab211-'))
            dvor = katalog / 'zamok_predmeta.sh'
            dvor.write_bytes(mut.encode('utf-8'))
            os.chmod(dvor, 0o755)
            sint = run(['bash', '-n', str(dvor)])
            if sint.returncode != 0:
                shutil.rmtree(katalog, ignore_errors=True)
                print('ORACLE_TAMPERED: стаб %s сломал синтаксис: %s'
                      % (imja, diag(sint.stderr)), file=sys.stderr)
                sys.exit(2)
            pojmali = []
            try:
                for vhod in STAB_VHOD[imja]:
                    _, kfn = K[vhod]
                    problemy = prognot_kletku(kfn, dvor)
                    if problemy:
                        pojmali.append(vhod)
            finally:
                shutil.rmtree(katalog, ignore_errors=True)
            svjazi += len(STAB_VHOD[imja])
            if not pojmali:
                zhivyh += 1
                print('STAB_ZHIV %s: ни одна связанная клетка не красна' % imja)
        print('STABY 211: SVJAZI %d ZHIVYH %d' % (svjazi, zhivyh))
        return 1 if zhivyh else 0

    # производственный слой: субъект дерева (база main+208); байт-в-байт
    # тот же путь запуска
    koren = argj.repo if argj.repo else None
    subj = subjekt_repo(koren)
    if subj is None:
        perechen = '\n'.join(sorted(K))
        print('SUBJECT_ABSENT: нет scripts/zamok_predmeta.sh; входы:')
        print(perechen)
        print(perechen, file=sys.stderr)
        return 1
    krasnye = {}
    for imja, (_, fn) in sorted(K.items()):
        for p in prognot_kletku(fn, subj):
            krasnye.setdefault(imja, []).append(p)
    print('SUBJEKT 211: KLETKI %d KRASNYH %d' % (len(K), len(krasnye)))
    if krasnye:
        print('КРАСНОЕ 211')
        print('КРАСНОЕ 211', file=sys.stderr)
        for imja in sorted(krasnye):
            for s in krasnye[imja]:
                print('KRASNAJA-KLETKA %s: %s' % (imja, s))
                print('KRASNAJA-KLETKA %s: %s' % (imja, s), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
