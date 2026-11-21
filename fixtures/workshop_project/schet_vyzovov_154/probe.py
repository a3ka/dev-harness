#!/usr/bin/env python3
"""Black-box toy worlds for the real lock and freeze CLI, with a reference patch in --model.

Режимы: repo/model/stabs/domain/domain-model/live/grammar. rc = 0 тогда и только
тогда, когда все клетки зелёные (стабилизировано вердиктом Crit154 Б1); в stabs
rc = 0 когда все стабы пойманы и все контроли зелёные.

Новый порядок (AGENTS.md §Арбитр; roles/critic.md §Быстрый-процесс): базовый
бюджет — полный + исправительный; общий предел — ТРИ вызова; после третьего без
accept — ОДИН арбитраж (строка ARBITRAZH журнала) и ОДИН узкий вызов (позиция 4);
адресные исключения — строки SANKTSIYA журнала (слово владельца / санкция
консультанта сессии по ADR 2026-11-17, ≤2 консультантских на предмет), каждая
открывает РОВНО одну позицию nomer на СВОЁМ OBJECT. Общего капа «пять» нет.

Оракул каждой клетки — чистая функция её параметров (n, фаза, источник,
посторонние строки, история/засев, новизна предмета, арбитраж, санкции; активный
номер предмета и repoId мира оракулом НЕ учитываются — ось Б8: порог обязан от
них не зависеть), вычисляется в probe ДО вызова субъекта; файлы субъекта
оракулом не читаются. Диск субъекта после вызова как истина не перечитывается:
сверяются только снимки (ledger/тег/реестр), снятые до вызова (правило 8).

Ось Б8 закрывается режимом grammar: порог не зависит от номера предмета, и это
проверяется на ВСЁМ замкнутом алфавите грамматики двери (^SUBJECT=[0-9]{3}$,
номера 000–999), включая номера без тега id/CONTRACT/* на момент запуска —
очередной конечный список свидетелей класс не закрывает (вердикт Crit154e Б8).
"""
import json
import os
import shutil
import subprocess
import select
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MODEL = HERE / 'model' / 'budget.py'
REPO_ID = 'repo-origin'
BASELINE = 'e97e740ff87a2dccdfa950d4e0e1b157f0962a68'
NNN = '001'
SUBJEKT_DRUGOJ = '152'   # ось Б8 (вердикт Crit154c): доступный новый предмет ≠ 001
SUBJEKT_TRETIJ = '150'   # ось Б8 (вердикт Crit154d): третий номер домена —
# свидетель подмножественных стабов {001,152} и «все кроме одного»: дефект
# каждого НАБЛЮДАЕМ именно на номерах вне зашитого подмножества (Н-39).
SUBJEKT_STARYJ = '137'   # ось Б8: старый предмет ≠ 001 (тег — предок границы)
REPO_ID_DRUGOJ = 'repo-drugoj-origin'  # ось Б8: иной ключ мира (repo dir repo-drugoj
# даёт origin …/repo-drugoj-origin.git → repoId тем же алгоритмом замка)
GRANICA_SHA = '5ca237e4e6bc980c460ede8ee6d85af8a33d0601'  # единый источник границы
GRANICA_CONST = "GRANICA_NOVYH = '%s'" % GRANICA_SHA
GRANICA_PACK = HERE / 'granica154.pack'  # снимок границы (Н4/С7): два реальных
GRANICA_IDX = HERE / 'granica154.idx'    # commit-объекта — граница и её первый родитель
DATA_NORMAL = '2026-11-01T00:00:00 +0000'        # коммиты toy-истории моложе журнала
DATA_DO_ZHURNALA = '2026-10-01T00:00:00 +0000'   # вердикты старше первого critic START
AT_ZHURNAL = '2026-10-31T05:38:09Z'              # дата первого critic START живого журнала
DRUGOJ_OBJECT = 'a' * 40                          # 40-hex, ≠ синтетических o_p (только
# цифры) и ≠ tip: свидетель переноса санкции на другой OBJECT
KONSULTANT_LIMIT = 2                              # ADR 2026-11-17 п.1


def cmd(argv, cwd=None):
    return subprocess.run(argv, cwd=cwd, capture_output=True, text=True, timeout=180,
                          env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null',
                               'GIT_CONFIG_SYSTEM': '/dev/null'})


def ensure(result, label):
    if result.returncode:
        raise RuntimeError(f'{label}: rc {result.returncode}: {result.stderr[-400:]}')


def gcommit(repo, msg, date=DATA_NORMAL, role='battery'):
    r = subprocess.run(
        ['git', '-C', str(repo), '-c', 'user.name=' + role,
         '-c', 'user.email=' + role + '@t', 'commit', '-q', '-m', msg],
        capture_output=True, text=True, timeout=180,
        env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
             'GIT_AUTHOR_NAME': role, 'GIT_AUTHOR_EMAIL': role + '@t',
             'GIT_COMMITTER_NAME': role, 'GIT_COMMITTER_EMAIL': role + '@t',
             'GIT_AUTHOR_DATE': date, 'GIT_COMMITTER_DATE': date})
    if r.returncode:
        raise RuntimeError(f'commit {msg}: rc {r.returncode}: {r.stderr[-300:]}')


# Стабы бюджета: каждая замена привязана к СВОЕЙ ветви по коду (Н-39); якорь обязан
# встречаться в model/budget.py ровно один раз — иначе прогон останавливается, а не
# молчит.
BUDGET_EDITS = {
    'third-unconditional': (
        "if pos <= 2:", "if pos <= 3:"),
    'compress-roles': ('count = len(starts)', 'count = len({r["rol"] for r in starts})'),
    'compress-object': ('count = len(starts)', 'count = len({r["object"] for r in starts})'),
    'arbitration-unlimited': ('        choices = {', '        if arbitrazh:\n            continue\n        choices = {'),
    'sanction-object-ignored': (
        "return row['nomer'] == pos and row['object'] == obj", "return row['nomer'] == pos"),
    'sanction-nomer-ignored': (
        "return row['nomer'] == pos and row['object'] == obj", "return row['object'] == obj"),
    'consultant-cap-ignored': ('and used < KONSULTANT_LIMIT:', 'and True:'),
    'aborted-ignored': ('count = len(starts)', '''count = sum(
            pathlib.Path(a.zhurnaly or '.', r['holder'] + '.jsonl').exists() and
            'yield' in pathlib.Path(a.zhurnaly or '.', r['holder'] + '.jsonl').read_text()
            for r in starts)'''),
    'preledger-ignored': ('do_zhurnala = t0 is not None and c0 is not None and c0 < t0.timestamp()',
                         'do_zhurnala = False'),
    'spawn-no-rashozhdenie': ('if not do_zhurnala and verdicts and not starts:',
                            "if a.phase == 'freeze' and not do_zhurnala and verdicts and not starts:"),
    'no-repoid': ('''starts = [r for r in judges if r.get('repoId') == repo_id and
                  r.get('subjectId') == a.subject]''',
                 '''starts = [r for r in judges if r.get('subjectId') == a.subject]'''),
    'no-subject': ('''starts = [r for r in judges if r.get('repoId') == repo_id and
                  r.get('subjectId') == a.subject]''',
                  "starts = [r for r in judges if r.get('repoId') == repo_id]"),
    'all-judges': ("r.get('klass') == 'sudja' and r.get('rol') in ('critic', 'critic-sol')",
                   "r.get('klass') == 'sudja'"),
    'sank-bad-ignored': ("elif r.get('t') in ('SANKTSIYA', 'ISPOLZOVANO'):",
                         "elif r.get('t') == 'ISPOLZOVANO':"),
    'arb-bad-ignored': ("if r.get('t') == 'ARBITRAZH':", "if r.get('t') == 'NOEVENT-154':"),
    'contradictory-ledger': ('if not do_zhurnala and verdicts and not starts:',
                            'if False and not do_zhurnala and verdicts and not starts:'),
    'receipt-ignored': ('if not proof_ok(a.repo, r, cache):', 'if False:'),
    'freeze-positions-flattened': ('if pos <= 2:', "if pos <= 2 or a.phase == 'freeze':"),
    'novelty-ignored': ('return anc.returncode == 0', 'return False'),
    'novelty-all-old': (
        "        if subprocess.run(['git', '-C', repo, 'cat-file', '-e', tag + '^{commit}'],\n                          capture_output=True).returncode:\n            return False",
        "        if subprocess.run(['git', '-C', repo, 'cat-file', '-e', tag + '^{commit}'],\n                          capture_output=True).returncode:\n            return True"),
    'novelty-reversed': (
        """anc = subprocess.run(['git', '-C', repo, 'merge-base', '--is-ancestor',
                              tag, GRANICA_NOVYH], capture_output=True)""",
        """anc = subprocess.run(['git', '-C', repo, 'merge-base', '--is-ancestor',
                              GRANICA_NOVYH, tag], capture_output=True)"""),
    'arb-reclassifies-used': ('        chosen = choices.pop()',
                              "        chosen = choices.pop()\n        if pos == 4 and arbitrazh:\n            continue"),
    'owner-reclassifies-used': ("        if chosen == 'arbitrazh':",
                               "        if any(s['istochnik'] == 'vladelec' and sanction_matches(s, pos, obj) for s in sank):\n            continue\n        if chosen == 'arbitrazh':"),
    'unused-grants-charged': ('    used = 0',
                             "    used = sum(s['istochnik'] == 'konsultant' for s in sank)"),
    'duplicate-grants-charged': ('            used += 1',
                                 "            used += sum(s['istochnik'] == 'konsultant' and sanction_matches(s, pos, obj) for s in sank)"),
    'owner-charged': ("        if grants and chosen in ('vladelec', 'orchestrator'):\n            continue",
                      "        if grants and chosen in ('vladelec', 'orchestrator'):\n            used += chosen == 'vladelec'\n            continue"),
    'selection-conflict-ignored': ('if len(choices) != 1:', 'if not choices:'),
    'consultant-without-arbitration': ("and (pos <= 3 or arbitrazh)", "and True"),
}
# Условные реализации по зашитому КОНЕЧНОМУ подмножеству номеров (класс Б8,
# вердикты Crit154c/Crit154d/Crit154e): вызов бюджета у обеих точек охраняется
# условием номера. 'in' — бюджет исполняется только для перечисленных номеров;
# 'out' — «все кроме одного». Дефект каждого наблюдаем на номерах ВНЕ подмножества
# (свидетели SUBJEKT_DRUGOJ/SUBJEKT_TRETIJ); ловец над всем доменом — режим
# grammar (номера 000–999 замкнутой грамматики, включая номера без тега).
SUBSET_GUARDS = {
    'subject-only-001': ('in', (NNN,)),
    'subject-subset-001-152': ('in', (NNN, SUBJEKT_DRUGOJ)),
    'subject-subset-vse-krome': ('out', (SUBJEKT_TRETIJ,)),
}


def subject_guard_cond(mutation, var):
    kind, nums = SUBSET_GUARDS[mutation]
    return (' || ' if kind == 'in' else ' && ').join(
        f'[ "${var}" = {n} ]' if kind == 'in' else f'[ "${var}" != {n} ]'
        for n in nums)


def bypass_call(call, mutation, repo, subject, phase):
    """Production-side regressions: bypass the honest counter in copied CLI doors."""
    if mutation == 'registry-fallback-old':
        condition = f'git -C "{repo}" log -1 --format=%H -G"^{subject} → " -- registry/contracts.tsv | grep -q .'
    elif mutation == 'empty-marker-old' or (
            mutation == 'freeze-empty-marker-old' and phase == 'freeze'):
        condition = (
            f'git -C "{repo}" rev-list --ancestry-path "refs/tags/id/CONTRACT/{subject}..HEAD"'
            ' | { while read -r sha; do\n'
            f'  [ -z "$(git -C "{repo}" diff-tree --root --no-commit-id --name-only -r "$sha")" ] && exit 0\n'
            'done; exit 1; }')
    else:
        return call
    return f'if {condition}; then b154=3; else\n{call}fi\n'


def freeze_block(budget, old6v, mutation=''):
    """Новый §6в: одна функция бюджета; rc 3 — старый предмет, прежний §6в дословно."""
    guard = 'st154=\'\'\n[ "$#" -ge 4 ] && st154="$4"\n'
    call = (f'python3 "{budget}" --sostojanie "$st154" --repo "$ROOT" '
            '--subject "$NNN" --phase freeze || b154=$?\n')
    call = bypass_call(call, mutation, '$ROOT', '$NNN', 'freeze')
    branch = ('if [ "$b154" -eq 3 ]; then\n'
              + old6v +
              'elif [ "$b154" -ne 0 ]; then\n'
              '  die "ОТКАЗ бюджета критика (154): см. stderr выше"\n'
              'fi\n')
    if mutation == 'freeze-side-effect':
        guard += ('mkdir -p "$ROOT/registry"\n'
                  'printf "mutant\\n" >> "$ROOT/registry/contracts.tsv"\n'
                  'git -C "$ROOT" tag "frozen/contracts/$NNN/v1"\n')
    if mutation == 'freeze-failopen':
        # Стаб: бюджет исполняется только при явном корне состояния с живым ledger —
        # без состояния или без ledger молчит (обход спавн-барьера прямым freeze).
        # guard назначает st154, как честная ветка: стаб расходится с эталоном ТОЛЬКО
        # решением «не проверять», а не unbound-падением под set -u (С4).
        return (guard +
                'if [ -n "$st154" ] && [ -f "$st154/uchet.jsonl" ]; then\n'
                'b154=0\n' + call + branch + 'fi\n')
    if mutation == 'freeze-second-counter':
        # Стаб: второй счётчик в freeze — grep по журналу без ключа предмета/роли
        # расходится с единой функцией на посторонних строках ledger.
        return (guard +
                'b154=0\n'
                'n154="$(grep -c \'"klass": "sudja"\' "$st154/uchet.jsonl" 2>/dev/null || true)"\n'
                '[ "$n154" -le 3 ] || b154=1\n' + branch)
    if mutation in SUBSET_GUARDS:
        # Стабы Б8 — условная реализация по зашитому подмножеству номеров:
        # для номера вне подмножества b154 остаётся 0 — бюджет не проверяется.
        return (guard + 'b154=0\n' +
                'if ' + subject_guard_cond(mutation, 'NNN') + '; then\n'
                + call + 'fi\n' + branch)
    return guard + 'b154=0\n' + call + branch


def prepare_scripts(world, mode, mutation='', granica=''):
    scripts = world / 'scripts'
    scripts.mkdir()
    for f in (ROOT / 'scripts').iterdir():
        if f.is_file():
            (scripts / f.name).symlink_to(f)
    if mode == 'model':
        lock = cmd(['git', '-C', str(ROOT), 'show', BASELINE + ':scripts/zamok_predmeta.sh']).stdout
        freeze = cmd(['git', '-C', str(ROOT), 'show', BASELINE + ':scripts/freeze_contract.sh']).stdout
        if not lock.startswith('#!/usr/bin/env bash') or not freeze.startswith('#!/usr/bin/env bash'):
            raise RuntimeError('model baseline unavailable')
    else:
        lock = (ROOT / 'scripts' / 'zamok_predmeta.sh').read_text()
        freeze = (ROOT / 'scripts' / 'freeze_contract.sh').read_text()
    if mode == 'model':
        body = MODEL.read_text()
        if granica:
            if body.count(GRANICA_CONST) != 1:
                raise RuntimeError('model: lost novelty boundary constant')
            body = body.replace(GRANICA_CONST, "GRANICA_NOVYH = '%s'" % granica)
        if mutation in BUDGET_EDITS:
            src, dst = BUDGET_EDITS[mutation]
            if body.count(src) != 1:
                raise RuntimeError('stab mutation anchor missing: ' + mutation)
            body = body.replace(src, dst)
        if mutation == 'contradictory-ledger':
            zero = "if a.phase == 'freeze' and count == 0:"
            if body.count(zero) != 1:
                raise RuntimeError('stab mutation anchor missing: freeze count==0')
            body = body.replace(zero, 'if False and ' + zero[3:])
        # Стабильный путь: без мутации и toy-границы вставка ссылается на сам MODEL,
        # поэтому эталонная вставка в scripts/ клона самодостаточна (mk_impl).
        budget = MODEL
        if granica or mutation:
            budget = world / 'budget154.py'
            budget.write_text(body)
        lock = lock.replace('#!/usr/bin/env bash\n',
                            '#!/usr/bin/env bash\n'
                            'if [ "${1:-}" = --schet-kritika ]; then\n'
                            f'  shift; exec python3 "{budget}" "$@"\nfi\n', 1)
        old_init = '[ -r "$LEDGER" ] || : >> "$LEDGER" || skip "учёт не создать: $LEDGER"'
        new_init = '[ -r "$LEDGER" ] || { [ -e "$LEDGER" ] && otp SCHET_NEIZVESTEN "ledger unreadable"; : >> "$LEDGER" || skip "учёт не создать: $LEDGER"; }'
        if lock.count(old_init) != 1:
            raise RuntimeError('model: lost ledger initialization')
        lock = lock.replace(old_init, new_init)
        if mutation == 'unreadable-ledger':
            lock = lock.replace(new_init, old_init)
        lock = lock.replace('LEDGER="$SOST/uchet.jsonl"\n',
                            'LEDGER="$SOST/uchet.jsonl"\n'
                            'LEDGER_154_EXISTED=1\n'
                            '[ -f "$LEDGER" ] || LEDGER_154_EXISTED=0\n', 1)
        call_spawn = (f'        python3 "{budget}" --sostojanie "$SOST" --repo "$REPO" '
                      '--zhurnaly "$ZHUR" --subject "$sv" --object "$obj" --phase spawn || b154=$?\n')
        call_spawn = bypass_call(call_spawn, mutation, '$REPO', '$sv', 'spawn')
        if mutation in SUBSET_GUARDS:
            # Стабы Б8 — атака критика дословно в модельной вставке двери:
            # бюджет охраняется условием номера предмета ($sv); на номерах вне
            # подмножества проверка молчит (Н-39 — привязка по коду ветви).
            call_spawn = ('        if ' + subject_guard_cond(mutation, 'sv') +
                          '; then\n' + call_spawn + '        fi\n')
        injection = ('      if [ "$klass" = sudja ] && { [ "$rol" = critic ] || '
                     '[ "$rol" = critic-sol ]; }; then\n'
                     '[ "$LEDGER_154_EXISTED" = 1 ] || { '
                     'mutexi_snyat_vse; rm -f "$LEDGER"; otp SCHET_NEIZVESTEN "журнал отсутствовал до вызова"; }\n'
                     '        b154=0\n'
                     + call_spawn +
                     '        if [ "$b154" -eq 1 ]; then mutexi_snyat_vse; exit 1; fi\n'
                     '        if [ "$b154" -ne 0 ] && [ "$b154" -ne 3 ]; then mutexi_snyat_vse; '
                     'skip "бюджет критика не читается (rc=$b154)"; fi\n'
                     '      fi\n')
        anchor = '    if [ "$klass" = ' + chr(39) + 'sudja' + chr(39) + ' ]; then\n      rab="$(poslednij_rabochij "$sv")"'
        if lock.count(anchor) != 1:
            raise RuntimeError('model: lost judge decision insertion point')
        lock = lock.replace(anchor, injection + anchor)
        start = freeze.index('# ── 6в. КАП КРУГОВ:')
        end = freeze.index('# ── 6г. ГЕЙТ ПРЕДПОСЫЛОК', start)
        old6v = freeze[start:end]
        header = ('# ── 6в. Счёт реальных START — новый порядок 154 v2 (3 → арбитраж → узкий);\n'
                  '# 4-й аргумент — корень состояния станции. Старые предметы (id/CONTRACT/NNN —\n'
                  '# предок границы 5ca237e4e) судятся прежним §6в ниже дословно.\n')
        freeze = freeze[:start] + header + freeze_block(budget, old6v, mutation) + '\n' + freeze[end:]
    for name, data in (('zamok_predmeta.sh', lock), ('freeze_contract.sh', freeze)):
        (scripts / name).unlink()
        (scripts / name).write_text(data)
    return scripts


def resolve_sank(spec, tip):
    # spec: 'tip' — OBJECT спавна (tip ветки автора); 'p<N>' — объект START №N;
    # 'drugoj' — иной 40-hex (перенос санкции на другой OBJECT).
    if spec == 'tip':
        return tip
    if spec == 'drugoj':
        return DRUGOJ_OBJECT
    if spec.startswith('p') and spec[1:].isdigit():
        return f'{int(spec[1:]):040x}'
    raise RuntimeError('неизвестный спецификатор санкции: ' + spec)


def add_receipts(repo, rows, decorate=False):
    # Grammar/serialization only: this shared primitive is not the result oracle.
    from model.budget import receipt_line
    events = [r for r in rows if r.get('t') in ('ARBITRAZH', 'SANKTSIYA', 'ISPOLZOVANO')]
    if not events:
        return
    lines = [receipt_line(r) for r in events]
    if decorate:
        lines = ['untrusted ' + line + ' suffix' for line in lines]
    (repo / 'HANDOFF.md').write_text('\n'.join(lines) + '\n')
    ensure(cmd(['git', '-C', str(repo), 'add', 'HANDOFF.md']), 'add receipts')
    gcommit(repo, 'committed budget decisions')
    sha = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
    for r in events:
        r.update(basisCommit=sha, basisPath='HANDOFF.md')


def world(base, n, outcomes, arb_file=False, name_variant=False, source='', phase='spawn',
          label='', foreign='', arb_ledger=0, sanktsii=(), history='', seed=None,
          novelty='new', objects='unique', live='', subject='', drugoj_repoid=False,
          arb_first='', used_sources=(), boundary_trace='', verdict_tail=True):
    # Ось Б8: судимый номер предмета и ключ репозитория мира — параметры мира,
    # не константы батареи: порог обязан не зависеть ни от того, ни от другого.
    sv = subject or NNN
    rid = REPO_ID_DRUGOJ if drugoj_repoid else REPO_ID
    repo = base / ('repo-drugoj' if drugoj_repoid else 'repo')
    ensure(cmd(['bash', '-c', 'source "$1"; make_repo "$2"', 'battery',
                str(ROOT / 'fixtures/freeze_contract/_repo.sh'), str(repo)]), 'make_repo')
    contract = repo / 'contracts' / (sv + '-x.md')
    if sv != NNN:
        # Контракт иного предмета существует закоммиченным — zamok читает
        # contracts/<NNN>-*.md (klass_riska); вход конформен, как в атаке
        # критика Б8 (cross_subject_repro): доступный номер без тега — новый.
        shutil.copyfile(repo / 'contracts' / (NNN + '-x.md'), contract)
    contract.write_text(contract.read_text() + '\nКЛАСС РИСКА: обычный\n')
    verdict = repo / 'verdicts' / 'critic' / (f'contracts-{sv}-v1.md')
    scaffold = repo / 'verdicts' / 'critic' / (f'contracts-{NNN}-v1.md')
    ensure(cmd(['git', '-C', str(repo), 'rm', '-q', str(scaffold)]), 'remove scaffold verdict')
    ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add risk')
    gcommit(repo, 'start with no verdict')
    verdict.parent.mkdir(parents=True, exist_ok=True)
    granica = None
    if novelty == 'old' and not live:
        # Старый предмет: тег номера — предок границы; граница — отдельный коммит.
        ensure(cmd(['git', '-C', str(repo), 'tag', 'id/CONTRACT/' + sv]), 'mint old subject')
        r = subprocess.run(
            ['git', '-C', str(repo), '-c', 'user.name=battery', '-c', 'user.email=b@t',
             'commit', '-q', '--allow-empty', '-m', 'граница 154'],
            capture_output=True, text=True, timeout=180,
            env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
                 'GIT_AUTHOR_DATE': DATA_NORMAL, 'GIT_COMMITTER_DATE': DATA_NORMAL})
        if r.returncode:
            raise RuntimeError('boundary commit: rc %d: %s' % (r.returncode, r.stderr[-200:]))
        granica = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
    # Ordinary code roots are distinct from the critic-only history, including
    # the old-subject world's otherwise empty boundary commit.
    (repo / 'candidate.py').write_text('revision = 1\n')
    ensure(cmd(['git', '-C', str(repo), 'add', 'candidate.py']), 'add historical code')
    gcommit(repo, 'historical code OBJECT')
    history_object = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
    vdate = DATA_DO_ZHURNALA if history == 'do-zhurnala' else DATA_NORMAL
    for i, outcome in enumerate(outcomes):
        if outcome != 'aborted':
            verdict.write_text(f'{outcome}\nOBJECT={history_object}\nsession={i}\n')
            ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add verdict')
            gcommit(repo, f'verdict {i}', vdate, role='critic')
    if not outcomes and phase == 'freeze':
        verdict.write_text(f'accept\nOBJECT={history_object}\norphan without START\n')
    if source == 'orphan-verdict':
        verdict.write_text(f'FAIL\nOBJECT={history_object}\norphan verdict without START\n')
    if label in ('renamed-object', 'verdict-vplus') or (
        label.startswith('domain-spawn-') and name_variant and verdict.exists()
    ):
        dest = verdict.with_name(f'contracts-{sv}-v1b-fail.md' if label != 'verdict-vplus'
                                 else f'contracts-{sv}-v2.md')
        verdict.rename(dest)
        verdict = dest
    if label.startswith('domain-freeze-') and name_variant and len(outcomes) > 1:
        # A historical earlier verdict is republished under another filename;
        # the latest accept remains the freeze target for the honest script.
        older = verdict.with_name(f'contracts-{sv}-v1b-fail.md')
        older.write_text(f'{outcomes[-2]}\nOBJECT={history_object}\nrenamed historical verdict\n')
    if label == 'verdict-copy':
        extra = repo / 'copied'
        extra.mkdir()
        shutil.copyfile(verdict, extra / verdict.name)
    if arb_file:
        a = repo / 'verdicts' / 'arbitration'
        a.mkdir(exist_ok=True)
        first = arb_first or ('К ВЛАДЕЛЬЦУ' if label == 'arbitration-owner' else
                              'ВЕРНУТЬ' if label == 'arbitration-return' else 'РЕШЕНИЕ')
        (a / f'contracts-{sv}-arbitraz.md').write_text(first + f' (контракт {sv})\n')
    ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add scenario')
    if cmd(['git', '-C', str(repo), 'diff', '--cached', '--quiet']).returncode:
        gcommit(repo, 'scenario', vdate, role='critic')
    s = base / 'state'
    j = base / 'journals'
    s.mkdir(); j.mkdir()
    ledger = s / 'uchet.jsonl'
    wt = base / 'worker'
    ensure(cmd(['git', 'clone', '-q', str(repo), str(wt)]), 'worker clone')
    ensure(cmd(['git', '-C', str(wt), 'checkout', '-q', '-b', f'wip/{sv}/architect']), 'branch')
    # This is the same owner, not a transferred product: a local clone URL must
    # not accidentally select D42's external-product risk repository.
    origin = cmd(['git', '-C', str(repo), 'remote', 'get-url', 'origin'])
    ensure(origin, 'owner origin')
    ensure(cmd(['git', '-C', str(wt), 'remote', 'set-url', 'origin', origin.stdout.strip()]),
           'canonical worker origin')
    (j / 'Worker154.jsonl').write_text('{"toolName":"yield"}\n')
    if live:
        # Живая граница — снимок (Н4/С7): pack несёт два реальных commit-объекта
        # (границу GRANICA_SHA и её первый родитель). Обход истории останавливается
        # на родителе заменой `git replace --graft` — НЕ .git/shallow: shallow-флаг
        # ловит чужой честный гейт freeze («реестр заморозок недоступен», замер), а
        # graft даёт те же rc без shallow и без ошибок по недостающим деревьям.
        # Ставится ПОСЛЕ worker-клона: репозиторий с обрезанной историей не отдаёт
        # объекты upload-pack'у, клон из него умирает (замер). gc.auto=0 — от repack.
        if live in ('old', 'new-tag', 'branch'):
            packdir = repo / '.git' / 'objects' / 'pack'
            packdir.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(GRANICA_PACK, packdir / GRANICA_PACK.name)
            shutil.copyfile(GRANICA_IDX, packdir / GRANICA_IDX.name)
            parent = cmd(['git', '-C', str(repo), 'rev-parse', GRANICA_SHA + '^'])
            ensure(parent, 'granica parent from snapshot')
            ensure(cmd(['git', '-C', str(repo), 'replace', '--graft',
                        parent.stdout.strip()]), 'graft granica parent')
            ensure(cmd(['git', '-C', str(repo), 'config', 'gc.auto', '0']), 'gc off')
            ensure(cmd(['git', '-C', str(repo), 'cat-file', '-e',
                        GRANICA_SHA + '^{commit}']), 'granica commit present')
        if live == 'old':
            ensure(cmd(['git', '-C', str(repo), 'tag', 'id/CONTRACT/' + sv,
                        parent.stdout.strip()]), 'mint old subject (live granica)')
        elif live in ('new-tag', 'no-granica'):
            ensure(cmd(['git', '-C', str(repo), 'tag', 'id/CONTRACT/' + sv, 'HEAD']),
                   'mint numbered subject')
        elif live == 'branch':
            ensure(cmd(['git', '-C', str(repo), 'branch', 'id/CONTRACT/' + sv,
                        parent.stdout.strip()]), 'branch is not a subject tag')
    if boundary_trace:
        absent = cmd(['git', '-C', str(repo), 'cat-file', '-e', GRANICA_SHA + '^{commit}'])
        if absent.returncode == 0:
            raise RuntimeError('no-boundary fixture unexpectedly contains boundary')
        if boundary_trace == 'registry':
            registry = repo / 'registry' / 'contracts.tsv'
            registry.parent.mkdir(exist_ok=True)
            registry.write_text(f'{sv} → {history_object}\n')
            ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add registry trace')
            gcommit(repo, 'first registry trace without boundary')
        elif boundary_trace == 'empty':
            ensure(cmd(['git', '-C', str(repo), 'tag', 'id/CONTRACT/' + sv]), 'late tag')
            ensure(cmd(['git', '-C', str(repo), '-c', 'user.name=battery',
                        '-c', 'user.email=b@t', 'commit', '-q', '--allow-empty',
                        '-m', 'not a delivered boundary']), 'untrusted empty commit')
        else:
            raise RuntimeError('unknown boundary trace: ' + boundary_trace)
    if phase == 'spawn':
        # D42 reads the owner's committed annotated-tag pin, not the candidate.
        # Freeze worlds deliberately have no such tag: their first freeze is v1.
        tag = f'frozen/contracts/{sv}/1'
        ensure(cmd(['git', '-C', str(repo), '-c', 'tag.gpgsign=false',
                    'tag', '-a', tag, '-m', 'fixture frozen owner']), 'pin frozen owner')
        pin = cmd(['git', '-C', str(repo), 'rev-parse', 'refs/tags/' + tag]).stdout.strip()
        registry = repo / 'registry' / 'contracts.tsv'
        registry.parent.mkdir(exist_ok=True)
        rows = registry.read_text().splitlines() if registry.exists() else []
        rows = [row for row in rows if not row.startswith(sv + ' → ')]
        registry.write_text('\n'.join(rows + [f'{sv} → {pin}']) + '\n')
        ensure(cmd(['git', '-C', str(repo), 'add', 'registry/contracts.tsv']), 'add frozen pin')
        gcommit(repo, 'committed frozen owner pin')
    (wt / 'candidate.py').write_text('revision = 2\n')
    ensure(cmd(['git', '-C', str(wt), 'add', 'candidate.py']), 'add current code')
    gcommit(wt, 'current code OBJECT')
    tip = cmd(['git', '-C', str(wt), 'rev-parse', 'HEAD']).stdout.strip()
    rows = [dict(t='START', repoId=rid, subjectId=sv, group='harness',
                 holder='Worker154', klass='rabochij', rol='architect',
                 object=tip, worktree=str(wt), branch=f'wip/{sv}/architect',
                 at=AT_ZHURNAL)]
    # Арбитраж о конечной границе и адресные санкции — строки ТОГО ЖЕ журнала
    # (единственный источник истины; журнал только дописывается).
    for _ in range(arb_ledger):
        rows.append(dict(t='ARBITRAZH', repoId=rid, subjectId=sv, at=AT_ZHURNAL))
    for nomer, spec, istochnik in sanktsii:
        rows.append(dict(t='SANKTSIYA', repoId=rid, subjectId=sv,
                         object=resolve_sank(spec, tip), nomer=nomer,
                         istochnik=istochnik, at=AT_ZHURNAL))
    if source == 'sank-bad':
        rows.append(dict(t='SANKTSIYA', repoId=rid, subjectId=sv,
                         object=DRUGOJ_OBJECT, nomer='4',
                         istochnik='vladelec', at=AT_ZHURNAL))
    if source == 'arb-bad':
        rows.append(dict(t='ARBITRAZH', repoId=rid, subjectId=sv))
    # Ось повтора OBJECT (Б7): значения object строк START — все разные (умолчание),
    # все одинаковые или ровно одна пара «после aborted» (повтор OBJECT — допустимый
    # живой вход: новая платная сессия на том же OBJECT после обрыва, как 152/148).
    objs = [f'{i + 1:040x}' for i in range(len(outcomes))]
    if objects == 'same':
        objs = ['f' * 40] * len(outcomes)
    elif objects == 'pair-aborted':
        k = next((i for i, o in enumerate(outcomes) if o == 'aborted'), None)
        if k is None or k + 1 >= len(outcomes):
            raise RuntimeError('pair-aborted: нет строки после aborted для пары')
        objs[k + 1] = objs[k]
    offset = seed if history == 'do-zhurnala' and isinstance(seed, int) and seed > 0 else 0
    if source not in ('third-missing', 'uncovered'):
        third = 2 - offset
        third_obj = objs[third] if 0 <= third < len(objs) else (
            tip if phase == 'spawn' and len(objs) + offset == 2 else None)
        if third_obj is not None:
            rows.append(dict(t='SANKTSIYA', repoId=rid, subjectId=sv, object=third_obj,
                             nomer=3, istochnik='orchestrator', at=AT_ZHURNAL))
    # Selection is a separate append-only fact, not a choice made by the counter.
    # Fixtures may select a different source explicitly while keeping grants fixed.
    for pos, obj in enumerate([None] * offset + objs + ([tip] if phase == 'spawn' else []), 1):
        if pos < 3 or obj is None or source == 'uncovered':
            continue
        sources = [src for nom, _, src in sanktsii if nom == pos]
        default = ('orchestrator' if pos == 3 else
                   'arbitrazh' if pos == 4 and arb_ledger else
                   'vladelec' if 'vladelec' in sources else
                   'konsultant' if 'konsultant' in sources else 'vladelec')
        chosen = dict(used_sources).get(pos, default)
        if source == 'selection-missing' and pos == 4:
            continue
        rows.append(dict(t='ISPOLZOVANO', repoId=rid, subjectId=sv,
                         object=obj, nomer=pos, istochnik=chosen, at=AT_ZHURNAL))
        if source == 'selection-conflict' and pos == 4:
            rows.append(dict(rows[-1], istochnik='vladelec'))
    for i, outcome in enumerate(outcomes):
        holder = f'Crit{i}b' if name_variant else f'Crit{i}a'
        rows.append(dict(t='START', repoId=rid, subjectId=sv,
                         group='harness', holder=holder, klass='sudja',
                         rol='critic-sol' if label == 'critic-sol-only' or i % 2 else 'critic', object=objs[i],
                         worktree='-', branch='-', at=AT_ZHURNAL))
        if outcome != 'aborted':
            (j / (holder + '.jsonl')).write_text('{"toolName":"yield"}\n')
        else:
            (j / (holder + '.jsonl')).write_text('{"type":"assistant"}\n')
    # Посторонние строки ledger (Б3): чужой ключ или чужая роль не расходуют бюджет.
    if foreign == 'other-repo':
        for i in range(3):
            rows.append(dict(t='START', repoId='repo-drugoj', subjectId=sv, group='harness',
                             holder=f'CritChuzhojR{i}', klass='sudja', rol='critic',
                             object='-', worktree='-', branch='-', at=AT_ZHURNAL))
    elif foreign == 'other-subject':
        for i in range(3):
            rows.append(dict(t='START', repoId=rid, subjectId='099', group='harness',
                             holder=f'CritChuzhojS{i}', klass='sudja', rol='critic',
                             object='-', worktree='-', branch='-', at=AT_ZHURNAL))
    elif foreign == 'other-roles':
        for i, rol in enumerate(('adversary', 'reviewer', 'adversary')):
            rows.append(dict(t='START', repoId=rid, subjectId=sv, group='harness',
                             holder=f'CritChuzhojV{i}', klass='sudja', rol=rol,
                             object='-', worktree='-', branch='-', at=AT_ZHURNAL))
    elif foreign == 'other-sanktsii':
        # Чужие санкции других предметов того же журнала бюджет не открывают.
        for nomer, spec, istochnik in ((4, 'drugoj', 'vladelec'), (5, 'drugoj', 'konsultant')):
            rows.append(dict(t='SANKTSIYA', repoId=rid, subjectId='099',
                             object=resolve_sank(spec, tip), nomer=nomer,
                             istochnik=istochnik, at=AT_ZHURNAL))
    before_receipts = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
    add_receipts(repo, rows, source == 'receipt-substring')
    # Receipts belong to the owner, not to the worker's candidate line: a grant
    # can name its code OBJECT without a self-referential receipt commit hash.
    # Capture the unchanged code root after those commits, then append only a
    # role-authored verdict; D9 must resolve the tail back to this exact OBJECT.
    tip = cmd(['git', '-C', str(wt), 'rev-parse', 'HEAD']).stdout.strip()
    if verdict_tail and verdict.exists():
        worker_verdict = wt / verdict.relative_to(repo)
        body = [line for line in worker_verdict.read_text().splitlines()
                if not line.startswith('OBJECT=')]
        body.insert(1, 'OBJECT=' + tip)
        worker_verdict.write_text('\n'.join(body) + '\n')
        ensure(cmd(['git', '-C', str(wt), 'add', str(worker_verdict)]), 'add worker verdict')
        gcommit(wt, 'verdict-only candidate tail', vdate, role='critic')
    if source in ('receipt-missing', 'receipt-uncommitted'):
        for r in rows:
            if r.get('t') == 'SANKTSIYA' and r.get('nomer', 0) >= 4:
                r['basisCommit'] = '' if source == 'receipt-missing' else before_receipts
    if source == 'arb-receipt-missing':
        for r in rows:
            if r.get('t') == 'ARBITRAZH':
                r.pop('basisCommit', None)
    ledger.write_text(''.join(json.dumps(r) + '\n' for r in rows))
    if source == 'missing':
        ledger.unlink()
    elif source == 'invalid':
        ledger.write_text('{broken json\n')
    elif source == 'invalid-shape':
        ledger.write_text('null\n')
    elif source == 'empty':
        ledger.write_text('')
    elif source == 'unreadable':
        ledger.chmod(0)
    if history == 'do-zhurnala' and seed is not None:
        (s / 'zasev_kritika.jsonl').write_text(json.dumps(
            dict(repoId=rid, subjectId=sv, doZhurnala=seed,
                 avtor='orchestrator', komment='засев счёта критика 154')) + '\n')
    event = base / 'event.json'
    event.write_text(json.dumps({'tasks': [{'agent': 'critic', 'name': 'NewCrit154',
                     'task': f'SUBJECT={sv}\nOBJECT={tip}\n'}]}))
    return repo, s, j, event, ledger, granica


def gate(scripts, repo, state, journals, event):
    return cmd(['bash', str(scripts / 'zamok_predmeta.sh'), '--sudit',
                '--sostojanie', str(state), '--zhurnaly', str(journals),
                '--repo', str(repo), str(event)])


def freeze(scripts, repo, state, subject=''):
    argv = ['bash', str(scripts / 'freeze_contract.sh'),
            f'contracts/{subject or NNN}-x.md', 'criterion accepted', str(repo)]
    if state is not None:
        argv.append(str(state))
    return cmd(argv)


def oracle(n, phase, source='', foreign='', arb_ledger=0, sanktsii=(), history='',
           seed=None, novelty='new', outcomes=None, objects='unique', arb_file=False,
           used_sources=()):
    """Symbolic specification, captured before the subject; no filesystem reads."""
    if novelty == 'old':
        classes, prev = 0, object()
        for o in outcomes or ():
            if o != 'aborted' and o != prev:
                classes += 1
                prev = o
        return 'кап кругов' if phase == 'freeze' and classes >= 3 and not arb_file else ''
    if source in ('missing', 'unreadable', 'invalid', 'invalid-shape', 'no-state',
                  'sank-bad', 'arb-bad'):
        return 'SCHET_NEIZVESTEN'
    if source in ('receipt-missing', 'receipt-uncommitted', 'receipt-substring'):
        return 'SANKTSIYA_NE_PODTVERZHDENA'
    if source == 'arb-receipt-missing':
        return 'ARBITRAZH_NE_PODTVERZHDEN'
    if source == 'orphan-verdict' or (source == 'empty' and n):
        return 'SCHET_RASHOZHDENIE'
    offset = 0
    if history == 'do-zhurnala':
        if seed is None or seed < 1:
            return 'SCHET_NEIZVESTEN'
        offset = seed
    prior = [f'p{i+1}' for i in range(n)]
    if objects == 'same':
        prior = ['same'] * n
    elif objects == 'pair-aborted':
        k = list(outcomes).index('aborted')
        prior[k+1] = prior[k]
    calls = [None] * offset + prior + (['tip'] if phase == 'spawn' else [])
    charged = []
    for pos, obj in enumerate(calls, 1):
        if pos < 3:
            continue
        if obj is None or source == 'uncovered':
            return 'SCHET_NEIZVESTEN'
        if pos == 4 and source in ('selection-missing', 'selection-conflict'):
            return 'SCHET_NEIZVESTEN'
        available = [src for num, _, src in sanktsii if num == pos]
        default = ('orchestrator' if pos == 3 else
                   'arbitrazh' if pos == 4 and arb_ledger else
                   'vladelec' if 'vladelec' in available else
                   'konsultant' if 'konsultant' in available else 'vladelec')
        selected = dict(used_sources).get(pos, default)
        if selected == 'arbitrazh' and pos == 4 and arb_ledger:
            continue
        matches = {(num, spec, src) for num, spec, src in sanktsii}
        if pos == 3 and source != 'third-missing':
            matches.add((3, obj, 'orchestrator'))
        if (pos, obj, selected) in matches:
            if selected in ('vladelec', 'orchestrator'):
                continue
            if selected == 'konsultant' and (pos < 4 or arb_ledger) and len(charged) < KONSULTANT_LIMIT:
                charged.append(pos)
                continue
        return 'KAP_VYZOVOV_KRITIKA'
    return 'SCHET_RASHOZHDENIE' if phase == 'freeze' and n == 0 else ''


def scenario(name, n, phase, outcome='FAIL', arb_file=False, rename=False,
             source='', mode='repo', mutation='', foreign='', arb_ledger=0,
             sanktsii=(), history='', seed=None, novelty='new',
             outcomes_override=None, objects='unique', live='', subject='',
             drugoj_repoid=False, arb_first='', used_sources=(), boundary_trace='',
             refreeze=False):
    sv = subject or NNN
    with tempfile.TemporaryDirectory(prefix='schet154-') as tmp:
        base = Path(tmp)
        pattern = list(outcomes_override) if outcomes_override else [outcome] * n
        if not outcomes_override and name.endswith('alternating'):
            pattern = ['FAIL' if i % 2 == 0 else 'accept' for i in range(n)]
        if pattern and phase == 'freeze':
            pattern[-1] = 'accept'
        # The pinned pre-v5 reference CLI compares the raw branch tip. Only
        # a CLI with the real transparent-tail resolver can consume that tail;
        # the budget inputs and oracle stay identical in both environments.
        verdict_tail = (mode != 'model' and 'object_kandidata() {' in
                        (ROOT / 'scripts/zamok_predmeta.sh').read_text())
        repo, state, journals, event, ledger, granica = world(
            base, n, pattern, arb_file, rename, source, phase, name,
            foreign, arb_ledger, sanktsii, history, seed, novelty, objects, live,
            subject, drugoj_repoid, arb_first, used_sources, boundary_trace, verdict_tail)
        scripts = prepare_scripts(base, mode, mutation, granica or '')
        if refreeze:
            # A real lawful v1 creates the registry trace; v2 must not inherit
            # legacy status from that very side effect. Keep the oracle in memory.
            full_ledger = ledger.read_bytes()
            first = [json.loads(line) for line in full_ledger.splitlines()
                     if json.loads(line).get('t') == 'START'][:2]
            ledger.write_text(''.join(json.dumps(row) + '\n' for row in first))
            initial = freeze(scripts, repo, state, subject)
            if initial.returncode != 0:
                return f'{name}: lawful v1 expected rc 0, actual {initial.returncode}: {initial.stderr[-280:]}'
            if not cmd(['git', '-C', str(repo), 'tag', '-l', f'frozen/contracts/{sv}/1']).stdout:
                return f'{name}: lawful v1 did not create tag'
            if f'{sv} → ' not in (repo / 'registry/contracts.tsv').read_text():
                return f'{name}: lawful v1 did not create registry trace'
            contract = repo / 'contracts' / (sv + '-x.md')
            contract.write_text(contract.read_text() + '\nv2 delta\n')
            ensure(cmd(['git', '-C', str(repo), 'add', str(contract)]), 'add v2 code')
            gcommit(repo, 'v2 after lawful first freeze')
            v2_object = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
            (repo / 'verdicts/critic' / f'contracts-{sv}-v2.md').write_text(
                f'accept\nOBJECT={v2_object}\nv2\n')
            ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add v2 verdict')
            gcommit(repo, 'v2 verdict-only tail', role='critic')
            ledger.write_bytes(full_ledger)
        before = ledger.read_bytes() if ledger.exists() and source != 'unreadable' else None
        tag_before = (cmd(['git', '-C', str(repo), 'tag', '-l', f'frozen/contracts/{sv}/*'])
                      if phase == 'freeze' else None)
        if tag_before:
            ensure(tag_before, 'tag before freeze')
        registry = repo / 'registry' / 'contracts.tsv'
        registry_before = registry.read_bytes() if phase == 'freeze' and registry.exists() else None
        expected = oracle(n, phase, source, foreign, arb_ledger, sanktsii, history,
                          seed, novelty, pattern, objects, arb_file, used_sources)
        if boundary_trace or refreeze or live == 'branch':
            # The same immutable input is presented read-only before either door.
            check = cmd(['bash', str(scripts / 'zamok_predmeta.sh'), '--schet-kritika',
                         '--sostojanie', str(state), '--repo', str(repo), '--subject', sv,
                         '--phase', phase, '--object', '0' * 39 + '7'])
            check_error = (None if check.returncode == 1 and expected in check.stderr else
                           f'counter expected rc 1 {expected}, actual rc {check.returncode}: {check.stderr[-180:]}')
        else:
            check_error = None
        if phase == 'spawn':
            result = gate(scripts, repo, state, journals, event)
        elif source == 'no-state':
            result = freeze(scripts, repo, None, subject)
        else:
            result = freeze(scripts, repo, state, subject)
        if expected and phase == 'freeze':
            tag_after = cmd(['git', '-C', str(repo), 'tag', '-l', f'frozen/contracts/{sv}/*'])
            ensure(tag_after, 'tag after freeze')
            registry_after = registry.read_bytes() if registry.exists() else None
            if tag_after.stdout != tag_before.stdout or registry_after != registry_before:
                return f'{name}: expected rc 1 {expected}; actual rc {result.returncode}; declined freeze changed frozen tag or registry'
        if check_error:
            return f'{name}: {check_error}; door actual rc {result.returncode}'
        if not expected and result.returncode != 0:
            return f'{name}: expected rc 0, actual {result.returncode}: {result.stderr[-280:]}'
        if expected and (result.returncode != 1 or expected not in result.stderr):
            return f'{name}: expected {expected}, actual rc {result.returncode}: {result.stderr[-280:]}'
        if expected and source != 'unreadable' and (ledger.read_bytes() if ledger.exists() else None) != before:
            return f'{name}: declined attempt changed ledger'
        if not expected and phase == 'spawn':
            after = ledger.read_bytes()
            if before is None or not after.startswith(before):
                return f'{name}: green spawn rewrote history'
            appended = [json.loads(line) for line in after[len(before):].splitlines()]
            if len(appended) != 1 or appended[0].get('t') != 'START':
                return f'{name}: green spawn did not append exactly one START'
        if not expected and phase == 'freeze':
            # С3/Н7: положительная заморозка обязана создать тег и запись реестра —
            # rc 0 без них равносилен тихим потерям заморозки; сверка снимками.
            tag_green = cmd(['git', '-C', str(repo), 'tag', '-l', f'frozen/contracts/{sv}/*'])
            ensure(tag_green, 'tag after green freeze')
            registry_green = registry.read_bytes() if registry.exists() else None
            if tag_green.stdout == tag_before.stdout:
                return f'{name}: green freeze did not mint frozen tag'
            if registry_green == registry_before:
                return f'{name}: green freeze did not update registry'
        return None


def concurrent_start(name, mode, mutation='', window=False):
    """One remaining base position, two real --sudit processes on the same state.

    The copied door pauses after counting. A competing process either encounters
    the held mutex or finishes its own count. Pipes, not scheduler delays, choose
    the interleaving; no production file or counter result is replaced.
    """
    with tempfile.TemporaryDirectory(prefix='schet154-race-') as tmp:
        base = Path(tmp)
        verdict_tail = (mode != 'model' and 'object_kandidata() {' in
                        (ROOT / 'scripts/zamok_predmeta.sh').read_text())
        repo, state, journals, event, ledger, _ = world(
            base, 1, ['FAIL'], source='third-missing', label=name,
            verdict_tail=verdict_tail)
        scripts = prepare_scripts(base, mode)
        door = scripts / 'zamok_predmeta.sh'
        lock = door.read_text()
        calls = [line for line in lock.splitlines()
                 if ('schet_kritika_154 spawn ' in line or
                     '--phase spawn || b154=$?' in line)]
        if len(calls) != 1:
            raise RuntimeError('race: lost spawn counter seam')
        call = calls[0]
        if mutation == 'counter-outside-mutex':
            # Adv154V7b, K-08: all other checks keep their original mutex.
            lock = lock.replace(call, '        mutexi_snyat_vse\n' + call +
                                '\n        mutex_zajavit "$sv" || exit 1', 1)
        elif mutation == 'mutex-gap-after-counter':
            # Adv154N4, K-08': the count is protected, but START is not atomic
            # with it. Keep every check and reacquire all subjects before START.
            start = '  # [D23 start-do-razdachi]'
            if lock.count(start) != 1:
                raise RuntimeError('race: lost START seam')
            lock = lock.replace(call, call + '\n        mutexi_snyat_vse', 1)
            lock = lock.replace(
                start, '  while IFS= read -r ms; do [ -z "$ms" ] || '
                'mutex_zajavit "$ms" || exit 1; done <<< "$SUBJS"\n' + start, 1)
        elif mutation:
            raise RuntimeError('race: unknown mutation: ' + mutation)
        pause = ('\n        printf "counted\\n" >&"$RACE154_STATUS_FD"\n'
                 '        IFS= read -r -u "$RACE154_RELEASE_FD" race154_release || exit 2')
        if window:
            # Arm after the real count, then stop at the FIRST release or START.
            # Unlike the older after-count pause, a release anywhere in this
            # interval lets the competitor count before either START is written.
            checkpoint = (
                '\nrace154_checkpoint() {\n'
                '  if [ "${RACE154_ARMED:-0}" = 1 ]; then\n'
                '    RACE154_ARMED=0\n'
                '    printf "%s\\n" "$1" >&"$RACE154_STATUS_FD"\n'
                '    IFS= read -r -u "$RACE154_RELEASE_FD" race154_release || exit 2\n'
                '  fi\n'
                '}\n')
            release_end = '\nEOF\n}\n# [D19 gruppa-pina]'
            start = '  # [D23 start-do-razdachi]'
            if lock.count(release_end) != 1 or lock.count(start) != 1:
                raise RuntimeError('race: lost release/START checkpoint seam')
            lock = checkpoint + lock
            lock = lock.replace(call, call + '\n        RACE154_ARMED=1', 1)
            lock = lock.replace(release_end, '\nEOF\n'
                                '  race154_checkpoint released\n}\n'
                                '# [D19 gruppa-pina]', 1)
            lock = lock.replace(start, '  race154_checkpoint counted\n' + start, 1)
        else:
            lock = lock.replace(call, call + pause, 1)
        acquire = '    mkdir "$d/mutex" 2>/dev/null && return 0'
        if lock.count(acquire) != 1:
            raise RuntimeError('race: lost mutex acquisition seam')
        lock = lock.replace(acquire, acquire +
                            '\n    if [ "${RACE154_BLOCKED:-0}" = 0 ]; then\n'
                            '      RACE154_BLOCKED=1\n'
                            '      printf "blocked\\n" >&"$RACE154_STATUS_FD"\n'
                            '      IFS= read -r -u "$RACE154_RELEASE_FD" race154_release || exit 2\n'
                            '    fi', 1)
        door.write_text(lock)
        # Immutable expectation: one new critic START, not two free position-2
        # decisions. Capture the history before either subject starts.
        before = ledger.read_bytes()
        argv = ['bash', str(door), '--sudit', '--sostojanie', str(state),
                '--zhurnaly', str(journals), '--repo', str(repo), str(event)]
        processes, descriptors = [], []

        def launch():
            read_fd, write_fd = os.pipe()
            release_fd, resume_fd = os.pipe()
            descriptors.extend((read_fd, write_fd, release_fd, resume_fd))
            process = subprocess.Popen(
                argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                pass_fds=(write_fd, release_fd),
                env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null',
                     'GIT_CONFIG_SYSTEM': '/dev/null',
                     'RACE154_STATUS_FD': str(write_fd),
                     'RACE154_RELEASE_FD': str(release_fd)})
            processes.append(process)
            return process, read_fd, resume_fd

        def status(fd):
            if not select.select([fd], [], [], 30)[0]:
                raise RuntimeError('race: synchronization timed out')
            value = os.read(fd, 64).decode().strip()
            if value not in ('counted', 'blocked', 'released'):
                raise RuntimeError('race: invalid synchronization: ' + repr(value))
            return value

        try:
            first, first_fd, first_resume = launch()
            if status(first_fd) not in (('counted', 'released') if window else ('counted',)):
                raise RuntimeError('race: first contender did not reach counter')
            second, second_fd, second_resume = launch()
            competing = status(second_fd)
            # In the window case, released means the mutex is already absent:
            # both contenders count before either writes START. An honest door
            # instead holds the mutex through the pre-START checkpoint.
            os.write(first_resume, b'go\n')
            first_out, first_err = first.communicate(timeout=180)
            os.write(second_resume, b'go\n')
            second_out, second_err = second.communicate(timeout=180)
        finally:
            for process in processes:
                if process.poll() is None:
                    process.kill()
                process.communicate()
            for fd in descriptors:
                os.close(fd)
        after = ledger.read_bytes()
        appended = ([json.loads(line) for line in after[len(before):].splitlines()]
                    if after.startswith(before) else [])
        valid_start = (len(appended) == 1 and appended[0].get('t') == 'START' and
                       appended[0].get('repoId') == REPO_ID and
                       appended[0].get('subjectId') == NNN and
                       appended[0].get('rol') in ('critic', 'critic-sol'))
        if (first.returncode != 0 or second.returncode != 1 or
                'ОТКАЗ: ZAMOK_BROSHEN:' not in second_err or not valid_start):
            return (f'{name}: expected rc=[0,1] ZAMOK_BROSHEN added-critic-START=1; '
                    f'actual rc=[{first.returncode},{second.returncode}] '
                    f'appended={len(appended)} competing={competing}; '
                    f'stdout={first_out.strip()!r},{second_out.strip()!r}; '
                    f'stderr={first_err.strip()!r},{second_err.strip()!r}')
        return None


# ── безфлаговый W: именованные RED до реализации, rc 1 ────────────────────────
CASES = [
    # позиции нового порядка на двери
    ('spawn-pos3-kap', 3, 'spawn', 'FAIL', False, False, '', {}),
    ('spawn-alternating', 3, 'spawn', 'FAIL', False, False, '', {}),
    ('spawn-pos4-arbitrazh', 3, 'spawn', 'FAIL', False, False, '', {'arb_ledger': 1}),
    ('spawn-pos4-sanktsija-tot-zhe', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((4, 'tip', 'vladelec'),)}),
    ('spawn-pos4-sanktsija-drugoj-object', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((4, 'drugoj', 'vladelec'),)}),
    ('spawn-pos4-sanktsija-nomer-5', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((5, 'tip', 'vladelec'),)}),
    ('spawn-pos5-sanktsija', 4, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'tip', 'vladelec'),)}),
    ('spawn-pos5-sanktsija-drugoj', 4, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((5, 'drugoj', 'vladelec'),)}),
    ('vtoroj-arbitrazh-ne-otkryvaet', 4, 'spawn', 'FAIL', False, False, '', {'arb_ledger': 2}),
    ('konsultant-tretja-nedeistvitelna', 6, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'p5', 'konsultant'), (6, 'p6', 'konsultant'),
                                   (7, 'tip', 'konsultant'))}),
    ('konsultant-vtoraja-deistvitelna', 5, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'p5', 'konsultant'), (6, 'tip', 'konsultant'))}),
    ('vladelec-pervaja-deistvitelna', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((4, 'tip', 'konsultant'), (4, 'tip', 'vladelec'),
                   (4, 'tip', 'konsultant'), (4, 'tip', 'konsultant'))}),
    # обрыв, имена, копии — счёт не обнуляется
    ('aborted-counts', 3, 'spawn', 'aborted', False, False, '', {}),
    ('renamed-object', 3, 'spawn', 'FAIL', False, True, '', {}),
    ('verdict-vplus', 3, 'spawn', 'FAIL', False, False, '', {}),
    ('verdict-copy', 3, 'spawn', 'FAIL', False, False, '', {}),
    ('critic-sol-only', 3, 'spawn', 'FAIL', False, False, '', {}),
    ('objects-same', 3, 'spawn', 'FAIL', False, False, '', {'objects': 'same'}),
    # freeze
    ('freeze-pos3-accept', 3, 'freeze', 'FAIL', False, False, '', {}),
    ('freeze-pos4-arbitrazh', 4, 'freeze', 'FAIL', False, False, '', {'arb_ledger': 1}),
    ('freeze-pos4-bez-pokrytija', 4, 'freeze', 'FAIL', False, False, '', {}),
    ('freeze-pos5-sanktsija', 5, 'freeze', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'p5', 'vladelec'),)}),
    ('freeze-pos5-sanktsija-ne-tot-object', 5, 'freeze', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'drugoj', 'vladelec'),)}),
    ('freeze-vtoroj-arbitrazh', 5, 'freeze', 'FAIL', False, False, '', {'arb_ledger': 2}),
    ('freeze-sanktsija-pos4-tot-zhe', 4, 'freeze', 'FAIL', False, False, '',
     {'sanktsii': ((4, 'p4', 'vladelec'),)}),
    # источник состояния и грамматика строк бюджета
    ('freeze-no-state', 4, 'freeze', 'FAIL', False, False, 'no-state', {}),
    ('spawn-verdict-no-start', 0, 'spawn', 'FAIL', False, False, 'orphan-verdict', {}),
    ('unreadable-ledger', 3, 'spawn', 'FAIL', False, False, 'unreadable', {}),
    ('missing-ledger', 3, 'spawn', 'FAIL', False, False, 'missing', {}),
    ('invalid-ledger', 3, 'spawn', 'FAIL', False, False, 'invalid', {}),
    ('invalid-shape-ledger', 3, 'spawn', 'FAIL', False, False, 'invalid-shape', {}),
    ('contradictory-ledger', 3, 'freeze', 'FAIL', False, False, 'empty', {}),
    ('sanktsija-bitaja', 3, 'spawn', 'FAIL', False, False, 'sank-bad', {}),
    ('arbitrazh-bityj', 3, 'spawn', 'FAIL', False, False, 'arb-bad', {}),
    # посторонние строки ledger: чужой ключ/роль/чужие санкции не расходуют и не открывают
    ('foreign-other-repo', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-repo'}),
    ('foreign-other-subject', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-subject'}),
    ('foreign-other-roles', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-roles'}),
    ('foreign-other-sanktsii', 3, 'spawn', 'FAIL', False, False, '',
     {'foreign': 'other-sanktsii'}),
    # до-журнальная история и запись-засев (Б4)
    ('do-zhurnala-spawn', 2, 'spawn', 'FAIL', False, False, '', {'history': 'do-zhurnala'}),
    ('do-zhurnala-freeze', 4, 'freeze', 'FAIL', False, False, '', {'history': 'do-zhurnala'}),
    ('do-zhurnala-seed-0', 2, 'spawn', 'FAIL', False, False, '', {'history': 'do-zhurnala', 'seed': 0}),
    ('do-zhurnala-seed-kap', 4, 'spawn', 'FAIL', False, False, '', {'history': 'do-zhurnala', 'seed': 3}),
    ('do-zhurnala-seed-dopusk', 1, 'spawn', 'FAIL', False, False, '', {'history': 'do-zhurnala', 'seed': 1}),
]
CASES += [(f'boundary-spawn-{n}', n, 'spawn', 'FAIL', False, False, '', {}) for n in range(7)]
CASES += [(f'boundary-freeze-{n}', n, 'freeze', 'FAIL', False, False, '', {}) for n in range(7)]
# Ось активного номера предмета и ключа репозитория (Б8, вердикты Crit154c/d/e):
# порог НЕ зависит от номера судимого предмета и repoId мира. Свидетели 152/150 —
# номера ВНЕ зашитых подмножеств стабов; ловец над всем доменом — режим grammar.
CASES += [
    ('subject-drugoj-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('subject-drugoj-freeze-5', 4, 'freeze', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('subject-tretij-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('repoid-drugoj-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'drugoj_repoid': True}),
]
CASES += [
    ('third-needs-sanction-door', 2, 'spawn', 'FAIL', False, False, 'third-missing', {}),
    ('third-needs-sanction-freeze', 3, 'freeze', 'FAIL', False, False, 'third-missing', {}),
    ('sanction-requires-receipt', 3, 'spawn', 'FAIL', False, False, 'receipt-missing',
     {'sanktsii': ((4, 'tip', 'vladelec'),)}),
    ('sanction-receipt-must-be-committed', 3, 'spawn', 'FAIL', False, False,
     'receipt-uncommitted', {'sanktsii': ((4, 'tip', 'vladelec'),)}),
    ('sanction-receipt-standalone', 3, 'spawn', 'FAIL', False, False, 'receipt-substring',
     {'sanktsii': ((4, 'tip', 'vladelec'),)}),
    ('arbitration-requires-receipt', 3, 'spawn', 'FAIL', False, False,
     'arb-receipt-missing', {'arb_ledger': 1}),
    ('unused-consultant-rows-not-calls', 5, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((4, 'drugoj', 'konsultant'),
         (4, 'drugoj', 'konsultant'), (5, 'p5', 'konsultant'),
         (6, 'tip', 'konsultant'))}),
    ('owner-addressed-no-global-cap', 8, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': tuple((p, f'p{p}', 'vladelec') for p in range(5, 9))
                                    + ((9, 'tip', 'vladelec'),)}),
]
# А154-1: paid sources are fixed independently of additional grants.
ATTRIBUTION_CASES = []
for _phase in ('spawn', 'freeze'):
    _last = 'tip' if _phase == 'spawn' else 'p6'
    _n = 5 if _phase == 'spawn' else 6
    _three = ((4, 'p4', 'konsultant'), (5, 'p5', 'konsultant'),
              (6, _last, 'konsultant'))
    _selected = ((4, 'konsultant'), (5, 'konsultant'), (6, 'konsultant'))
    for _variant, _grants, _sources, _arb in (
        ('third-refused', _three, _selected, 1),
        ('extra-arbitration-no-reset', _three, _selected, 2),
        ('unused-owner-no-reclassification',
         _three + ((4, 'p4', 'vladelec'),), _selected, 1),
        ('owner-not-charged', _three + ((4, 'p4', 'vladelec'),),
         ((4, 'vladelec'), (5, 'konsultant'), (6, 'konsultant')), 1),
        ('two-with-duplicates', _three + _three + ((4, 'p4', 'vladelec'),
                                                 (8, 'drugoj', 'konsultant')),
         ((4, 'vladelec'), (5, 'konsultant'), (6, 'konsultant')), 1),
    ):
        ATTRIBUTION_CASES.append((
            f'attribution-{_phase}-{_variant}', _n, _phase, 'FAIL', False, False, '',
            {'arb_ledger': _arb, 'sanktsii': _grants, 'used_sources': _sources}))
    _two_last = 'tip' if _phase == 'spawn' else 'p5'
    ATTRIBUTION_CASES.append((
        f'attribution-{_phase}-two-from-four', _n - 1, _phase, 'FAIL', False, False, '',
        {'arb_ledger': 1, 'sanktsii': ((4, 'p4', 'konsultant'),
                                      (5, _two_last, 'konsultant')),
         'used_sources': ((4, 'konsultant'), (5, 'konsultant'))}))
    for _src in ('selection-missing', 'selection-conflict'):
        ATTRIBUTION_CASES.append((
            f'attribution-{_phase}-{_src}', 3 if _phase == 'spawn' else 4,
            _phase, 'FAIL', False, False, _src,
            {'arb_ledger': 1, 'sanktsii': ((4, 'tip' if _phase == 'spawn' else 'p4', 'vladelec'),)}))
    ATTRIBUTION_CASES.append((
        f'attribution-{_phase}-consultant-needs-arbitration',
        3 if _phase == 'spawn' else 4, _phase, 'FAIL', False, False, '',
        {'sanktsii': ((4, 'tip' if _phase == 'spawn' else 'p4', 'konsultant'),),
         'used_sources': ((4, 'konsultant'),)}))
CASES += ATTRIBUTION_CASES

# А154-2 / Б-1: no snapshot means new even after registry/empty-commit
# traces. One shared list is consumed by repo, live, domain and mutation controls.
B1_CASES = [
    (f'b1-no-boundary-{trace}-{phase}', 5, phase, 'accept', False, False, 'uncovered',
     {'boundary_trace': trace})
    for trace in ('registry', 'empty') for phase in ('spawn', 'freeze')
] + [
    ('b1-branch-not-tag-spawn', 5, 'spawn', 'accept', False, False, 'uncovered',
     {'live': 'branch'}),
    ('b1-refreeze-v2-six-start', 6, 'freeze', 'accept', False, False, 'third-missing',
     {'refreeze': True}),
]
CASES += B1_CASES

# Ось новизны в repo-режиме БЕЗ границы: toy-репозитории без снимка судят новые
# предметы — это строгий дефолт конструкции. repo-режим судит СТАРУЮ классификацию
# режимом --live по снимку границы (Б6).
OLD_CASES = [
    ('old-spawn-shestoj', 6, 'spawn', 'FAIL', False, False, '', {'novelty': 'old'}),
    ('old-freeze-klapan', 6, 'freeze', 'FAIL', True, False, '',
     {'novelty': 'old', 'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    ('old-freeze-kap', 6, 'freeze', 'FAIL', False, False, '',
     {'novelty': 'old',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
]

# ── стабы: каждая связь «мутация → вход» наблюдаема РОВНО на этом входе (Н-39) ─
STAB_CASES = [
    ('compress-roles', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((3, 'tip', 'orchestrator'),)}),
    ('compress-object', 3, 'spawn', 'FAIL', False, False, '', {'objects': 'same'}),
    ('arbitration-unlimited', 4, 'spawn', 'FAIL', False, False, '', {'arb_ledger': 2}),
    ('sanction-object-ignored', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((4, 'drugoj', 'vladelec'),)}),
    ('sanction-nomer-ignored', 3, 'spawn', 'FAIL', False, False, '',
     {'sanktsii': ((5, 'tip', 'vladelec'),)}),
    ('consultant-cap-ignored', 6, 'spawn', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((5, 'p5', 'konsultant'), (6, 'p6', 'konsultant'),
                                   (7, 'tip', 'konsultant'))}),
    ('aborted-ignored', 3, 'spawn', 'aborted', False, False, '', {}),
    ('preledger-ignored', 2, 'spawn', 'FAIL', False, False, '', {'history': 'do-zhurnala'}),
    ('spawn-no-rashozhdenie', 0, 'spawn', 'FAIL', False, False, 'orphan-verdict', {}),
    ('no-repoid', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-repo'}),
    ('no-subject', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-subject'}),
    ('all-judges', 2, 'spawn', 'FAIL', False, False, '', {'foreign': 'other-roles'}),
    ('sank-bad-ignored', 3, 'spawn', 'FAIL', False, False, 'sank-bad', {}),
    ('arb-bad-ignored', 3, 'spawn', 'FAIL', False, False, 'arb-bad', {}),
    ('freeze-positions-flattened', 5, 'freeze', 'FAIL', False, False, '', {'arb_ledger': 2}),
    ('freeze-failopen', 4, 'freeze', 'FAIL', False, False, 'no-state', {}),
    ('freeze-second-counter', 3, 'freeze', 'FAIL', False, False, '',
     {'foreign': 'other-subject'}),
    ('unreadable-ledger', 3, 'spawn', 'FAIL', False, False, 'unreadable', {}),
    ('contradictory-ledger', 3, 'freeze', 'FAIL', False, False, 'empty', {}),
    ('novelty-ignored', 6, 'freeze', 'FAIL', True, False, '',
     {'novelty': 'old', 'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    ('novelty-all-old', 4, 'freeze', 'FAIL', False, False, '', {}),
    ('novelty-reversed', 6, 'freeze', 'FAIL', True, False, '',
     {'novelty': 'old', 'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    # Б8: условная реализация по зашитому подмножеству номеров — атаки критика
    # дословно ({001} — Crit154c; {001,152} — Crit154d; «все кроме одного») и
    # «все кроме одного»; дефект каждой наблюдаем на номерах ВНЕ подмножества:
    # свидетели 152/150; ловец над всем доменом — режим grammar (000–999).
    ('subject-only-001', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('subject-only-001', 4, 'freeze', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('subject-subset-001-152', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('subject-subset-001-152', 4, 'freeze', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('subject-subset-vse-krome', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('subject-subset-vse-krome', 4, 'freeze', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('third-unconditional', 2, 'spawn', 'FAIL', False, False, 'third-missing', {}),
    ('receipt-ignored', 3, 'spawn', 'FAIL', False, False, 'receipt-missing',
     {'sanktsii': ((4, 'tip', 'vladelec'),)}),
    ('freeze-positions-flattened', 3, 'freeze', 'FAIL', False, False, 'third-missing', {}),
    ('freeze-side-effect', 4, 'freeze', 'FAIL', False, False, '', {}),
]
for _case in ATTRIBUTION_CASES:
    _name, _n, _phase, _outcome, _arb, _rename, _source, _kw = _case
    _mutations = {
        'third-refused': ('arb-reclassifies-used',),
        'unused-owner-no-reclassification': ('owner-reclassifies-used',),
        'owner-not-charged': ('owner-charged',),
        'two-with-duplicates': ('unused-grants-charged', 'duplicate-grants-charged'),
        'selection-conflict': ('selection-conflict-ignored',),
        'consultant-needs-arbitration': ('consultant-without-arbitration',),
    }.get(_name.removeprefix(f'attribution-{_phase}-'), ())
    STAB_CASES += [(_m, _n, _phase, _outcome, _arb, _rename, _source, _kw)
                   for _m in _mutations]
for _case in B1_CASES:
    _name, _n, _phase, _outcome, _arb, _rename, _source, _kw = _case
    _mutations = (('registry-fallback-old',) if _kw.get('boundary_trace') == 'registry'
                  else ('empty-marker-old', 'freeze-empty-marker-old')
                  if _kw.get('boundary_trace') == 'empty' and _phase == 'freeze'
                  else ('empty-marker-old',) if _kw.get('boundary_trace') == 'empty'
                  else ())
    STAB_CASES += [(_m, _n, _phase, _outcome, _arb, _rename, _source, _kw)
                   for _m in _mutations]

DOMAIN = [
    (f'domain-{phase}-{n}', n, phase, 'FAIL', False, False, '', {})
    for phase in ('spawn', 'freeze')
    for n in range(8)
]
# исходы и арбитраж/санкции по позициям: обе фазы, n вокруг порогов нового порядка
DOMAIN += [
    (f'domain-{phase}-{n}-{outcome}', n, phase, outcome, False, False, '', {})
    for phase in ('spawn', 'freeze')
    for n in (3, 4, 5)
    for outcome in ('FAIL', 'accept', 'aborted')
]
DOMAIN += [
    (f'domain-arb{arb}-{phase}-{n}', n, phase, 'FAIL', False, False, '',
     {'arb_ledger': arb})
    for phase in ('spawn', 'freeze')
    for n in (2, 3, 4, 5, 6)
    for arb in (1, 2)
]
SANK_VARIANTS = (
    ((4, 'tip', 'vladelec'),),
    ((5, 'tip', 'vladelec'),),
    ((4, 'drugoj', 'vladelec'),),
    ((5, 'drugoj', 'vladelec'),),
    ((4, 'tip', 'konsultant'),),
    ((4, 'tip', 'konsultant'), (5, 'tip', 'konsultant')),
    ((4, 'tip', 'konsultant'), (5, 'tip', 'konsultant'), (5, 'tip', 'konsultant')),
    ((4, 'tip', 'vladelec'), (5, 'tip', 'vladelec')),
    ((4, 'drugoj', 'konsultant'), (5, 'drugoj', 'konsultant'), (6, 'drugoj', 'konsultant')),
    ((6, 'tip', 'vladelec'),),
)
DOMAIN += [
    (f'domain-sank{k}-{phase}-{n}', n, phase, 'FAIL', False, False, '',
     {'sanktsii': sk})
    for k, sk in enumerate(SANK_VARIANTS)
    for phase in ('spawn', 'freeze')
    for n in (3, 4, 5)
]
# санкция freeze привязана к объекту START своей позиции: тот же номер на ДРУГОМ
# объекте позиции — не покрытие (перенос санкции на другой OBJECT — отказ)
DOMAIN += [
    (f'domain-sankp{p}-freeze-5', 5, 'freeze', 'FAIL', False, False, '',
     {'arb_ledger': 1, 'sanktsii': ((p, f'p{p}', 'vladelec'),)})
    for p in (4, 5)
]
# источник состояния: отсутствие/нечитаемость/битость/пустота и вход без состояния (Б3)
DOMAIN += [
    (f'domain-source-{phase}-{n}-{src}', n, phase, 'FAIL', False, False, src, {})
    for phase in ('spawn', 'freeze')
    for n in (0, 3)
    for src in ('missing', 'unreadable', 'invalid', 'invalid-shape', 'empty', 'sank-bad', 'arb-bad')
    if not (phase == 'spawn' and n == 0 and src == 'empty')
] + [
    (f'domain-source-freeze-{n}-no-state', n, 'freeze', 'FAIL', False, False, 'no-state', {})
    for n in (0, 3)
] + [
    ('domain-source-spawn-orphan-verdict', 0, 'spawn', 'FAIL', False, False, 'orphan-verdict', {}),
]
# посторонние строки ledger: чужой repoId/subjectId/роль/чужие санкции (Б3)
DOMAIN += [
    (f'domain-foreign-{phase}-{n}-{fr}', n, phase, 'FAIL', False, False, '',
     {'foreign': fr})
    for phase in ('spawn', 'freeze')
    for n in (2, 3)
    for fr in ('other-repo', 'other-subject', 'other-roles', 'other-sanktsii')
]
# до-журнальная история и запись-засев: без засева — остановка, с засевом — n+k (Б4)
DOMAIN += [
    (f'domain-do-zhurnala-{phase}-{n}-seed{k}', n, phase, 'FAIL', False, False, '',
     {'history': 'do-zhurnala', 'seed': k})
    for phase in ('spawn', 'freeze')
    for n in (2, 3)
    for k in (None, 0, 1, 3)
]
# Ось повтора OBJECT (Б7): {все разные, пара одинаковых после aborted, все одинаковые}
# при n ∈ {3, 4} на обеих фазах; оракул от оси не зависит — счёт = все START,
# повтор OBJECT не сжимает (обманный счётчик по уникальным object краснеет).
for _variant, _objects in (('raznye', 'unique'), ('posle-aborted', 'pair-aborted'),
                           ('vse-odinakovye', 'same')):
    for _phase in ('spawn', 'freeze'):
        for _n in (3, 4):
            _kw = {'objects': _objects}
            if _variant == 'posle-aborted':
                _pat = ['FAIL'] * _n
                _pat[1] = 'aborted'   # пара: aborted-сессия и СЛЕДУЮЩАЯ на том же OBJECT
                _kw['outcomes_override'] = _pat
            DOMAIN.append((f'domain-object-{_variant}-{_phase}-{_n}',
                           _n, _phase, 'FAIL', False, False, '', _kw))
# Ось активного номера предмета и ключа репозитория (Б8): порог НЕ зависит ни от
# номера судимого предмета, ни от repoId мира; обманная вставка «бюджет только для
# предмета 001» краснеет клетками subject-152, «{001,152}» — клетками subject-150.
DOMAIN += [
    ('domain-subject-152-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('domain-subject-152-freeze-5', 4, 'freeze', 'FAIL', False, False, '',
     {'subject': SUBJEKT_DRUGOJ}),
    ('domain-subject-150-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'subject': SUBJEKT_TRETIJ}),
    ('domain-repoid-drugoj-spawn-4', 3, 'spawn', 'FAIL', False, False, '',
     {'drugoj_repoid': True}),
    ('domain-repoid-drugoj-freeze-5', 4, 'freeze', 'FAIL', False, False, '',
     {'drugoj_repoid': True}),
]
# Ось новизны домена — модельная (та же причина, что у OLD_CASES): Б5.
OLD_DOMAIN = [
    ('domain-old-spawn-5', 5, 'spawn', 'FAIL', False, False, '', {'novelty': 'old'}),
    ('domain-old-spawn-6', 6, 'spawn', 'FAIL', False, False, '', {'novelty': 'old'}),
    ('domain-old-freeze-klapan', 6, 'freeze', 'FAIL', True, False, '',
     {'novelty': 'old', 'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    ('domain-old-freeze-kap', 6, 'freeze', 'FAIL', False, False, '',
     {'novelty': 'old',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
]
DOMAIN += ATTRIBUTION_CASES
DOMAIN += B1_CASES

# Б6: живая классификация установленных scripts/ на снимке границы (Н4/С7) —
# repo-режим без правки scripts: старый предмет (тег — предок границы) ведёт себя
# по прежнему §6в, новый с тегом и без, граница недоступна — новый порядок.
# Без реализации красны именованно ровно «новые» клетки; обманные классификаторы
# «тег значит старый» / «обратный порядок» / «новизна игнорируется» краснеют
# каждая своей клеткой (замер — протокол мутантов на эталонной вставке).
LIVE_CASES = [
    ('live-old-door-shestoj', 6, 'spawn', 'FAIL', False, False, '',
     {'live': 'old', 'novelty': 'old'}),
    ('live-old-freeze-klapan', 6, 'freeze', 'FAIL', True, False, '',
     {'live': 'old', 'novelty': 'old', 'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    ('live-old-freeze-kap', 6, 'freeze', 'FAIL', False, False, '',
     {'live': 'old', 'novelty': 'old',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
    ('live-new-tag-door', 3, 'spawn', 'FAIL', False, False, '', {'live': 'new-tag'}),
    ('live-new-tag-freeze', 4, 'freeze', 'FAIL', False, False, '', {'live': 'new-tag'}),
    ('live-new-notag-door', 3, 'spawn', 'FAIL', False, False, '', {'live': 'new-notag'}),
    ('live-no-granica-door', 3, 'spawn', 'FAIL', False, False, '', {'live': 'no-granica'}),
    # Ось Б8, старый номер ≠ 001: предмет 137 (тег — предок границы из снимка)
    # ведётся прежним порядком — дверь пускает шестой, freeze — арбитражный
    # клапан прежнего §6в (ложный отказ законному старому предмету недопустим).
    ('live-old2-door-shestoj', 6, 'spawn', 'FAIL', False, False, '',
     {'live': 'old', 'novelty': 'old', 'subject': SUBJEKT_STARYJ}),
    ('live-old2-freeze-klapan', 6, 'freeze', 'FAIL', True, False, '',
     {'live': 'old', 'novelty': 'old', 'subject': SUBJEKT_STARYJ,
      'arb_first': 'РЕШЕНИЕ',
      'outcomes_override': ['FAIL', 'accept', 'FAIL', 'accept', 'FAIL', 'accept']}),
]
LIVE_CASES += B1_CASES

# K-08 / Adv154V7b: the paid critic boundary, not the worker-only family-140
# race. The same input is exercised by installed, reference and stab modes.
CONCURRENT_CASE = ('concurrent-start-last-base-position', 1, 'spawn', 'FAIL',
                   False, False, 'third-missing', {'concurrent': True})
CASES.append(CONCURRENT_CASE)
DOMAIN.append(CONCURRENT_CASE)
LIVE_CASES.append(CONCURRENT_CASE)
STAB_CASES.append(('counter-outside-mutex',) + CONCURRENT_CASE[1:])

# K-08' / Adv154N4: distinguish release/reacquire AFTER the protected count.
# The original counter-outside-mutex case and its schedule remain unchanged.
CONCURRENT_WINDOW_CASE = (
    'concurrent-start-count-start-window', 1, 'spawn', 'FAIL',
    False, False, 'third-missing', {'concurrent': True, 'window': True})
CASES.append(CONCURRENT_WINDOW_CASE)
DOMAIN.append(CONCURRENT_WINDOW_CASE)
LIVE_CASES.append(CONCURRENT_WINDOW_CASE)
STAB_CASES.append(('mutex-gap-after-counter',) + CONCURRENT_WINDOW_CASE[1:])


def grammar_numbers(limit=0):
    """Домен номеров предмета = ВЕСЬ замкнутый алфавит грамматики двери
    (^SUBJECT=[0-9]{3}$): номера 000–999, включая номера, чей тег id/CONTRACT/*
    отсутствует на момент запуска (строгий дефолт: нет тега — новый предмет).
    Закрывающее свойство Б8 (вердикт Crit154e): очередной конечный список
    свидетелей класс не закрывает — закрывает только весь алфавит."""
    nums = [f'{i:03d}' for i in range(1000)]
    return nums[:limit] if limit else nums


def grammar_shard(k, nums, tmp):
    """Один шард режима grammar: СВОЙ toy-мир (репозиторий, журналы, два корня
    состояния) на своё подмножество номеров — параллельные шарды не делят
    записей (freeze на нереализованном дереве коммитит реестр своего шарда);
    детерминизм — сбор и печать по номеру в grammar_run, не по завершению."""
    base = Path(tmp) / f'shard{k}'
    base.mkdir(parents=True)
    repo = base / 'repo'
    ensure(cmd(['bash', '-c', 'source "$1"; make_repo "$2"', 'battery',
                str(ROOT / 'fixtures/freeze_contract/_repo.sh'), str(repo)]), 'make_repo')
    contracts = repo / 'contracts'
    verdict_dir = repo / 'verdicts' / 'critic'
    ensure(cmd(['git', '-C', str(repo), 'rm', '-q',
                str(verdict_dir / f'contracts-{NNN}-v1.md')]), 'remove scaffold verdict')
    scaffold_contract = (contracts / (NNN + '-x.md')).read_text()
    verdict_dir.mkdir(parents=True, exist_ok=True)  # git rm вычищает опустевшие каталоги
    for sv in nums:
        (contracts / (sv + '-x.md')).write_text(
            scaffold_contract + '\nКЛАСС РИСКА: обычный\n')
        (verdict_dir / f'contracts-{sv}-v1.md').write_text('accept\nsession=0\n')
    ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'grammar add')
    gcommit(repo, 'номера шарда одним коммитом')
    tip = cmd(['git', '-C', str(repo), 'rev-parse', 'HEAD']).stdout.strip()
    for sv in nums:
        ensure(cmd(['git', '-C', str(repo), 'branch', f'wip/{sv}/architect']), 'branch')
    j = base / 'journals'
    j.mkdir()
    door_state = base / 'state-door'
    freeze_state = base / 'state-freeze'
    door_state.mkdir()
    freeze_state.mkdir()
    rows_door, rows_freeze = [], []
    for sv in nums:
        (j / f'Arch{sv}.jsonl').write_text('{"toolName":"yield"}\n')
        rows_door.append(dict(t='START', repoId=REPO_ID, subjectId=sv,
                              group='harness', holder='Arch' + sv, klass='rabochij',
                              rol='architect', object=tip, worktree=str(repo),
                              branch=f'wip/{sv}/architect', at=AT_ZHURNAL))
        for i in range(4):
            r = dict(t='START', repoId=REPO_ID, subjectId=sv, group='harness',
                     holder=f'Crit{sv}x{i}', klass='sudja', rol='critic',
                     object=f'{int(sv):03d}{i:037d}', worktree='-', branch='-',
                     at=AT_ZHURNAL)
            rows_freeze.append(r)
            if i < 3:
                rows_door.append(dict(r))
    for sv in nums:
        for rows in (rows_door, rows_freeze):
            rows.append(dict(t='SANKTSIYA', repoId=REPO_ID, subjectId=sv,
                             nomer=3, object=f'{int(sv):03d}{2:037d}',
                             istochnik='orchestrator', at=AT_ZHURNAL))
            rows.append(dict(t='ISPOLZOVANO', repoId=REPO_ID, subjectId=sv,
                             nomer=3, object=f'{int(sv):03d}{2:037d}',
                             istochnik='orchestrator', at=AT_ZHURNAL))
        rows_door.append(dict(t='ISPOLZOVANO', repoId=REPO_ID, subjectId=sv,
                              nomer=4, object=tip, istochnik='vladelec', at=AT_ZHURNAL))
        rows_freeze.append(dict(t='ISPOLZOVANO', repoId=REPO_ID, subjectId=sv,
                                nomer=4, object=f'{int(sv):03d}{3:037d}',
                                istochnik='vladelec', at=AT_ZHURNAL))
    add_receipts(repo, rows_door + rows_freeze)
    (door_state / 'uchet.jsonl').write_text(
        ''.join(json.dumps(r) + '\n' for r in rows_door))
    (freeze_state / 'uchet.jsonl').write_text(
        ''.join(json.dumps(r) + '\n' for r in rows_freeze))
    event = base / 'event.json'
    scripts = prepare_scripts(base, 'repo')
    exp_door = oracle(3, 'spawn')
    exp_freeze = oracle(4, 'freeze')
    out = {}
    for sv in nums:
        event.write_text(json.dumps({'tasks': [
            {'agent': 'critic', 'name': 'NewCrit154',
             'task': f'SUBJECT={sv}\nOBJECT={tip}\n'}]}))
        door = cmd(['bash', str(scripts / 'zamok_predmeta.sh'), '--sudit',
                    '--sostojanie', str(door_state), '--zhurnaly', str(j),
                    '--repo', str(repo), str(event)])
        after = [json.loads(s) for s in
                 (door_state / 'uchet.jsonl').read_text().splitlines() if s]
        chetvertyj = any(r.get('holder') == 'NewCrit154' and r.get('subjectId') == sv
                         for r in after)
        if door.returncode != 1 or exp_door not in door.stderr or chetvertyj:
            out[(sv, 'door')] = (f'RED grammar-{sv}-door: expected {exp_door}, rc '
                                 f'{door.returncode}: {door.stderr[-200:]} '
                                 f'chetvertyj_zapisan={chetvertyj}')
        else:
            out[(sv, 'door')] = None
        registry = repo / 'registry' / 'contracts.tsv'
        registry_before = registry.read_bytes() if registry.exists() else None
        frz = cmd(['bash', str(scripts / 'freeze_contract.sh'),
                   f'contracts/{sv}-x.md', 'criterion accepted',
                   str(repo), str(freeze_state)])
        tag = cmd(['git', '-C', str(repo), 'tag', '-l', f'frozen/contracts/{sv}/*'])
        registry_after = registry.read_bytes() if registry.exists() else None
        if (frz.returncode != 1 or exp_freeze not in frz.stderr or tag.stdout
                or registry_after != registry_before):
            out[(sv, 'freeze')] = (f'RED grammar-{sv}-freeze: expected {exp_freeze}, rc '
                                   f'{frz.returncode}: {frz.stderr[-200:]} '
                                   f'frozen_tag={tag.stdout.strip()} '
                                   f'reestr_izmenjon={registry_after != registry_before}')
        else:
            out[(sv, 'freeze')] = None
    return out


def grammar_run(limit=0):
    """Режим grammar — закрывающее свойство Б8 (вердикты Crit154c/d/e): порог НЕ
    зависит от номера предмета, и это проверяется на ВСЁМ замкнутом алфавите
    грамматики двери (^SUBJECT=[0-9]{3}$: 000–999, включая номера без тега
    id/CONTRACT/*) исполнением поставленных scripts/. Шардируемые toy-миры:
    контракт и accept-вердикт каждого номера, ветка wip/<NNN>/architect, два
    корня состояния — 3 critic START на номер (дверная клетка: четвёртый START
    без арбитража/санкции → KAP до записи) и 4 START на номер (freeze-клетка:
    позиция 4 не покрыта → KAP до тега/реестра, снимки тега И реестра неизменны
    — Б9). Оракул — oracle(3,'spawn')/oracle(4,'freeze'), чистая функция фазы,
    от номера не зависит. Условная реализация по ЛЮБОМУ собственному
    подмножеству номеров краснеет клетками номеров вне подмножества; честная
    вставка зелена на всём алфавите."""
    import concurrent.futures
    nums = grammar_numbers(limit)
    workers = min(len(nums), 8, max(1, (os.cpu_count() or 4) - 2))
    shards = [nums[i::workers] for i in range(workers)]
    results = {}
    with tempfile.TemporaryDirectory(prefix='schet154-grammar-') as tmp:
        with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
            futures = [pool.submit(grammar_shard, k, shard, tmp)
                       for k, shard in enumerate(shards)]
            for f in futures:
                results.update(f.result())
    failed = 0
    for sv in nums:
        for phase in ('door', 'freeze'):
            r = results[(sv, phase)]
            if r is None:
                print(f'GREEN grammar-{sv}-{phase}')
            else:
                print(r)
                failed += 1
    print(f'GRAMMAR={len(nums)} CELLS={2 * len(nums)} '
          f'GREEN={2 * len(nums) - failed}')
    # Б1: rc = 0 тогда и только тогда, когда весь алфавит зелёный.
    return 0 if not failed else 1


def run_case(c, mode, mutation=''):
    name, n, phase, outcome, arb_file, rename, source, kw = c
    if kw.get('concurrent'):
        return concurrent_start(name, mode, mutation, window=kw.get('window', False))
    return scenario(name, n, phase, outcome, arb_file, rename, source, mode, mutation, **kw)


def main():
    argv = sys.argv[1:]
    mode = argv[0] if argv else 'repo'
    limit = 0
    if mode == 'grammar' and len(argv) > 1:
        if not argv[1].isdigit():
            print('usage: probe.py [repo|model|stabs|domain|domain-model|live|grammar [limit]]',
                  file=sys.stderr)
            return 2
        limit = int(argv[1])
    if mode not in ('repo', 'model', 'stabs', 'domain', 'domain-model', 'live',
                    'grammar'):
        print('usage: probe.py [repo|model|stabs|domain|domain-model|live|grammar [limit]]',
              file=sys.stderr)
        return 2
    if mode == 'grammar':
        return grammar_run(limit)
    cases = CASES
    if mode in ('domain', 'domain-model'):
        cases = DOMAIN
    if mode == 'stabs':
        cases = STAB_CASES
    if mode == 'live':
        cases = LIVE_CASES
    if mode == 'model':
        cases = CASES + OLD_CASES
    elif mode == 'domain-model':
        cases = DOMAIN + OLD_DOMAIN
    failed = 0
    for c in cases:
        name = c[0]
        if mode == 'stabs':
            control = run_case(c, 'model')
            if control:
                print(f'MODEL_NOT_GREEN {name}: {control}')
                return 2
            # The pre-implementation baseline is a required red result; each stab is
            # tied to precisely the input where its observable defect differs.
            actual = run_case(c, 'model', mutation=name)
            if actual is None:
                print(f'STAB_SURVIVED {name}')
                failed += 1
            else:
                print(f'STAB_CAUGHT {name}: {actual}')
        else:
            actual = run_case(c, mode=('model' if mode == 'domain-model' else mode))
            if actual:
                print(f'RED {actual}')
                failed += 1
            else:
                print(f'GREEN {name}')
    print(f'CELLS={len(cases)} GREEN={len(cases) - failed}' if mode != 'stabs'
          else f'SVJAZI={len(cases)} CAUGHT={len(cases) - failed} LIVE={failed}')
    # Б1: rc = 0 тогда и только тогда, когда все клетки зелёные (все режимы).
    return 0 if not failed else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError) as e:
        print(f'NOT_IMPLEMENTED: toy world: {e}', file=sys.stderr)
        sys.exit(2)
