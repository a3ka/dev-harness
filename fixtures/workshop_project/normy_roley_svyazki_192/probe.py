#!/usr/bin/env python3
"""192: связка architect↔критик — структурная батарея ролей (взята у 188, не написана заново).

Канонические литералы — norms.tsv; тексты разделов/правок — drafts/ (происхождение —
ROLE-DRAFTS прохода Fable 16, побайтово с подстановкой NNN→192); честная модель ролей
собирается build_model.py из base/roles (пин SHA256SUMS) + вставка 188 (norms.tsv семьи 188)
+ черновики 192. Клетки: 12 норм-строк, 17 строк списка классов, единый источник, строка
critic-sol, кап 3 + арбитраж (слово владельца 2026-11-11, owner-PR #834), формулировки
старого порядка остановки отсутствуют во всех семи ролях (critic — клетки net-*, остальные
шесть — starshij-poryadok), потолок 73728 на модели, производные агенты равны генерации
из ролей настоящим генератором.

Оракул в памяти проверяющего: ожидания сняты из norms.tsv/drafts ДО чтения файлов ролей
(правило 8). Сверка структурная: литерал — самостоятельной строкой своего раздела; якоря
капа — предложениями §Остановка с нормализацией пробелов (перенос строки не прячет якорь).

Коды возврата: 0 — зелёно; 1 — есть красные клетки/живые предъявления; 2 — NOT_IMPLEMENTED
(нет источников, расходится пин, нет node для клетки агентов — отказ среды, не красная).
"""
import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CONTRACT = ROOT / 'contracts/192-normy-roley-svyazki.md'
LIMIT = 73728
FROZEN = '192/1'

SECTIONS = {
    'critic': '## Связка с автором (контракт 192)',
    'architect': '## Связка с критиком (контракт 192)',
    'orchestrator': '## Связка critic ↔ architect (контракт 192)',
    'arbiter': '## Конечная граница (контракт 192)',
    'adversary': '## Остаток контракта (контракт 192)',
    'reviewer': '## Остаток контракта (контракт 192)',
}
CRITIC_BYSTRY = '## Быстрый-процесс'
CRITIC_SOL_LINE = ('Связка с автором — `roles/critic.md §Связка с автором`: '
                   'карта классов, суд дельта-листа, граница.')
KAP_PRESENT = (
    ('kap-tri', 'Общий предел — три critic-вызова на предмет (полный, исправительный, один по санкции)'),
    ('kap-arbitrazh', 'После третьего вызова без accept — один арбитраж о конечной границе'),
    ('kap-uzkij', 'один узкий вызов критика только на исполнение решения арбитра'),
    ('kap-soglasen', 'согласен автор или спорит'),
)
KAP_ABSENT = (
    ('net-pyati', 'Общий предел — пять critic-вызовов'),
    ('net-soglasiya', 'При письменном СОГЛАСИИ автора со всеми открытыми блоками арбитраж НЕ созывается'),
    ('net-isprav', 'исправительный вызов по санкции оркестратора при согласии автора'),
    ('net-nazvannogo', 'арбитр созывается только при названном споре'),
)
CAP_TAIL = 'Scope не позволяет скрыть доказанное нарушение.'
# Класс шире файла critic (вердикт 192 круг 1, Б-3): формулировки старого порядка
# остановки не должны жить ни в одной роли; в critic их ловят клетки critic/net-*,
# остальным шести ролям — своя клетка starshij-poryadok.
STARSHIJ_ROLES = ('architect', 'orchestrator', 'arbiter', 'adversary', 'reviewer', 'critic-sol')


def die(message):
    print(f'NOT_IMPLEMENTED: {message}', file=sys.stderr)
    sys.exit(2)


def read(path):
    if not path.is_file():
        die(f'нет файла {path}')
    return path.read_text(encoding='utf-8')


def norms():
    rows = []
    for row in read(HERE / 'norms.tsv').splitlines():
        role, key, literal = row.split('\t')
        if '«' in literal or '»' in literal or not literal.strip():
            die(f'норма вне грамматики канала: {role}/{key}')
        rows.append((role, key, literal))
    if len(rows) != 12 or len({(r, k) for r, k, _ in rows}) != 12:
        die(f'ожидалось 12 уникальных координат, прочитано {len(rows)}')
    return rows


def class_lines():
    lines = [l for l in read(HERE / 'drafts' / 'critic_section.md').split('\n')
             if l.startswith('- К-')]
    keys = [l[2:6] for l in lines]
    if keys != [f'К-{i:02d}' for i in range(1, 18)]:
        die(f'список классов не К-01…К-17: {keys}')
    return lines


def visible_lines(text):
    """Exclude Markdown HTML comments and fenced code before matching (взято у 188)."""
    result = []
    comment = False
    fence = None
    for original in text.splitlines():
        if fence is not None:
            stripped = original.lstrip(' ')
            char, width = fence
            run = len(stripped) - len(stripped.lstrip(char)) if stripped.startswith(char) else 0
            if len(original) - len(stripped) <= 3 and run >= width and not stripped[run:].strip():
                fence = None
            continue
        line = original
        visible = ''
        while line:
            if comment:
                close = line.find('-->')
                if close < 0:
                    line = ''
                else:
                    line = line[close + 3:]
                    comment = False
            else:
                opening = line.find('<!--')
                if opening < 0:
                    visible += line
                    line = ''
                else:
                    visible += line[:opening]
                    line = line[opening + 4:]
                    comment = True
        stripped = visible.lstrip(' ')
        indent = len(visible) - len(stripped)
        if not comment and indent <= 3 and stripped and stripped[0] in ('`', '~'):
            char = stripped[0]
            width = len(stripped) - len(stripped.lstrip(char))
            if width >= 3:
                fence = (char, width)
                continue
        result.append(visible)
    return result


def marker(role):
    return f'Норма-строка (ПРОВОДКА roles/{role}.md, заморожена {FROZEN}):'


def section_of(lines, heading):
    if lines.count(heading) != 1:
        return None
    start = lines.index(heading) + 1
    end = next((i for i in range(start, len(lines)) if lines[i].startswith('#')), len(lines))
    return lines[start:end]


def assess_norm(text, role, literal):
    """Литерал побайтово, самостоятельной строкой, ровно один раз в разделе — и ровно один
    маркер, за которым (после пустых строк) идёт именно этот литерал; в разделе может быть
    несколько маркеров (по одному на норму)."""
    section = section_of(visible_lines(text), SECTIONS[role])
    if section is None:
        return False
    pairs = 0
    for i, line in enumerate(section):
        if line == marker(role):
            j = i + 1
            while j < len(section) and not section[j].strip():
                j += 1
            if j < len(section) and section[j] == literal:
                pairs += 1
    return pairs == 1 and section.count(literal) == 1

def normalize(text):
    return ' '.join(text.split())

def ostanovka_paragraph(text):
    section = section_of(visible_lines(text), CRITIC_BYSTRY)
    if section is None:
        return ''
    paragraph = []
    for line in section:
        if not line.strip():
            if paragraph:
                break
            continue
        if paragraph and line.startswith('**') and line.rstrip().endswith('**'):
            break
        if paragraph or line.startswith('**Остановка.**'):
            paragraph.append(line)
    return '\n'.join(paragraph)


def cap_missing(text):
    """Ключи якорей капа, отсутствующих в §Остановка (§Быстрый-процесс)."""
    flat = normalize(ostanovka_paragraph(text))
    return {k for k, a in KAP_PRESENT if a not in flat}


def cap_violations(text):
    """Ключи старых формулировок, оставшихся в тексте роли (весь файл, нормализация пробелов)."""
    flat = normalize(text)
    return {k for k, a in KAP_ABSENT if a in flat}


def starshij_violations(text):
    """Формулировки старого порядка остановки в роли ВНЕ critic (весь файл, нормализация)."""
    flat = normalize(text)
    return [k for k, anchor in KAP_ABSENT if anchor in flat]


def assess_class_line(text, line):
    section = section_of(visible_lines(text), SECTIONS['critic'])
    return section is not None and section.count(line) == 1


def assess_sol_line(text):
    section = section_of(visible_lines(text), '## Быстрый-процесс')
    return section is not None and section.count(CRITIC_SOL_LINE) == 1


def foreign_classes(texts, classes):
    return sorted(f'{role}/{line[2:6]}' for role, text in texts.items() if role != 'critic'
                  for line in classes if normalize(line) in normalize(text))


def ceiling_failures(roles_dir, roles):
    return {role for role in roles if (roles_dir / f'{role}.md').stat().st_size > LIMIT}


def contract_citations(rows):
    contract = read(CONTRACT)
    for role, key, literal in rows:
        if contract.splitlines().count(f'- role=roles/{role}.md «{literal}»') != 1:
            die(f'role-канал контракта расходится с norms.tsv: {role}/{key}')


def build_model(target):
    result = subprocess.run([sys.executable, str(HERE / 'build_model.py'), str(target)],
                            capture_output=True, text=True, check=False)
    if result.returncode != 0:
        die(f'сборка модели: {(result.stderr or result.stdout).strip()}')


def run_generator(model_roles_dir, agents_dir, scratch):
    """Производные агенты — генерацией из ролей настоящим инструментом, не двойником."""
    node = shutil.which('node')
    if node is None:
        die('node недоступен — клетку агентов нечем проверить (отказ среды, rc 2)')
    scripts = scratch / 'scripts'
    if not scripts.exists():
        scripts.mkdir(parents=True, exist_ok=True)
        for name in ('gen-harness.ts', 'roles.ts'):
            shutil.copyfile(ROOT / 'scripts' / name, scripts / name)
    shutil.copytree(model_roles_dir, scratch / 'roles', dirs_exist_ok=True)
    result = subprocess.run([node, str(scripts / 'gen-harness.ts'), '--into', str(agents_dir)],
                            capture_output=True, text=True, check=False, cwd=str(scripts))
    if result.returncode != 0:
        die(f'генератор отказал: {(result.stderr or result.stdout).strip()}')


def assess_agents_parity(model_roles_dir, committed_agents, scratch):
    out = scratch / ('agents-out-' + committed_agents.name)
    run_generator(model_roles_dir, out, scratch)
    generated = {p.name: p.read_bytes() for p in out.glob('*.md')}
    committed = {p.name: p.read_bytes() for p in committed_agents.glob('*.md')}
    return generated == committed


def insert_into_section(text, heading, line):
    lines = text.split('\n')
    if lines.count(heading) != 1:
        die(f'вставка стаба: заголовок не уникален {heading}')
    start = lines.index(heading) + 1
    end = next((i for i in range(start, len(lines)) if lines[i].startswith('#')), len(lines))
    lines.insert(end, line)
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--repo', type=Path)
    args = parser.parse_args()
    rows = norms()
    classes = class_lines()
    contract_citations(rows)
    roles = list(SECTIONS) + ['critic-sol']

    scratch = Path(tempfile.mkdtemp(prefix='roles192-', dir=HERE))
    try:
        if args.repo is not None:
            root = args.repo.resolve()
            texts = {}
            for role in roles:
                path = root / 'roles' / f'{role}.md'
                texts[role] = path.read_text(encoding='utf-8') if path.is_file() else ''
            failures = set()
            for role, key, literal in rows:
                ok = assess_norm(texts[role], role, literal)
                print(f'{"GREEN" if ok else "RED"} {role}/{key}')
                if not ok:
                    failures.add(f'{role}/{key}')
            for line in classes:
                key = f'critic/klass-{line[2:6].lower()}'
                ok = assess_class_line(texts['critic'], line)
                print(f'{"GREEN" if ok else "RED"} {key}')
                if not ok:
                    failures.add(key)
            ok = assess_sol_line(texts['critic-sol'])
            print(f'{"GREEN" if ok else "RED"} critic-sol/svyazka')
            if not ok:
                failures.add('critic-sol/svyazka')
            foreign = foreign_classes(texts, classes)
            print(f'{"GREEN" if not foreign else "RED"} istochnik/edinstvennyj'
                  + (f' ({foreign[0]})' if foreign else ''))
            if foreign:
                failures.add('istochnik/edinstvennyj')
            for key in sorted(cap_missing(texts['critic'])):
                print(f'RED critic/{key} — нет якоря капа в §Остановка')
                failures.add(f'critic/{key}')
            for key, _ in KAP_PRESENT:
                if f'critic/{key}' not in failures:
                    print(f'GREEN critic/{key}')
            for key in sorted(cap_violations(texts['critic'])):
                print(f'RED critic/{key} — старый порядок остался')
                failures.add(f'critic/{key}')
            for key, _ in KAP_ABSENT:
                if f'critic/{key}' not in failures:
                    print(f'GREEN critic/{key}')
            for role in STARSHIJ_ROLES:
                keys = starshij_violations(texts[role])
                print(f'{"GREEN" if not keys else "RED"} {role}/starshij-poryadok'
                      + (f' — старый порядок остался ({keys[0]})' if keys else ''))
                if keys:
                    failures.add(f'{role}/starshij-poryadok')
            node = shutil.which('node')
            if node is None:
                die('node недоступен — клетку агентов нечем проверить (отказ среды, rc 2)')
            result = subprocess.run([node, str(ROOT / 'scripts' / 'gen-harness.ts'), '--check'],
                                    capture_output=True, text=True, check=False, cwd=str(ROOT))
            ok = result.returncode == 0
            print(f'{"GREEN" if ok else "RED"} repo/agents-parity')
            if not ok:
                failures.add('repo/agents-parity')
            cells = 12 + 17 + 2 + len(KAP_PRESENT) + len(KAP_ABSENT) + len(STARSHIJ_ROLES) + 1
            print(f'CELLS={cells} GREEN={cells - len(failures)}')
            return 1 if failures else 0

        model_dir = scratch / 'model'
        build_model(model_dir)
        texts = {role: (model_dir / 'roles' / f'{role}.md').read_text(encoding='utf-8')
                 for role in roles}
        failures = set()
        for role, key, literal in rows:
            if not assess_norm(texts[role], role, literal):
                failures.add(f'{role}/{key}')
        for line in classes:
            if not assess_class_line(texts['critic'], line):
                failures.add(f'critic/klass-{line[2:6].lower()}')
        if not assess_sol_line(texts['critic-sol']):
            failures.add('critic-sol/svyazka')
        if foreign_classes(texts, classes):
            failures.add('istochnik/edinstvennyj')
        failures.update(f'critic/{k}' for k in cap_missing(texts['critic']))
        failures.update(f'critic/{k}' for k in cap_violations(texts['critic']))
        failures.update(f'{role}/starshij-poryadok' for role in STARSHIJ_ROLES
                        if starshij_violations(texts[role]))
        if failures:
            print(f'контроль красен на честной модели: {sorted(failures)}')
            return 1
        base_cells = 12 + 17 + 2 + len(KAP_PRESENT) + len(KAP_ABSENT) + len(STARSHIJ_ROLES)

        # Независимые негативы: каждая координата краснеет СВОИМ предъявлением.
        for role, key, literal in rows:
            honest = texts[role]
            for label, mutant in (
                ('missing', honest.replace(literal + '\n', '', 1)),
                ('html', honest.replace(literal + '\n', '<!--\n' + literal + '\n-->\n', 1)),
                ('fence', honest.replace(literal + '\n', '```text\n' + literal + '\n```\n', 1)),
            ):
                if assess_norm(mutant, role, literal):
                    failures.add(f'{label} {role}/{key}')
        for line in classes:
            if assess_class_line(texts['critic'].replace(line + '\n', '', 1), line):
                failures.add(f'missing critic/klass-{line[2:6].lower()}')
        for key, anchor in KAP_PRESENT:
            if key not in cap_missing(texts['critic'].replace(anchor, '', 1)):
                failures.add(f'missing critic/{key}')
        for key, anchor in KAP_ABSENT:
            if key not in cap_violations(
                    texts['critic'].replace(CAP_TAIL, anchor + ' ' + CAP_TAIL, 1)):
                failures.add(f'restored critic/{key}')
        for role in STARSHIJ_ROLES:
            mutant = texts[role].rstrip('\n') + '\n' + KAP_ABSENT[3][1] + '\n'
            if not starshij_violations(mutant):
                failures.add(f'restored {role}/starshij-poryadok')

        ceilings = {role: (model_dir / 'roles' / f'{role}.md').stat().st_size for role in roles}
        failures.update(f'{role}/potolok' for role in ceiling_failures(model_dir / 'roles', roles))
        if assess_agents_parity(model_dir / 'roles', HERE / 'model' / 'omp-agents', scratch):
            print('AGENTS_PARITY=ok')
        else:
            failures.add('model/agents-parity')
        print(f'CEILINGS={len(ceilings)} MAX={max(ceilings.values())} LIMIT={LIMIT}')

        if args.model:
            negatives = (len(rows) * 3 + len(classes) + len(KAP_PRESENT)
                         + len(KAP_ABSENT) + len(STARSHIJ_ROLES))
            broken = {f for f in failures
                      if f.split(' ')[0] in ('missing', 'html', 'fence', 'restored')}
            cells = base_cells + len(roles) + 1
            greens = cells - len(failures - broken)
            print(f'CELLS={cells} GREEN={greens} RED_NEGATIVES={negatives - len(broken)}/{negatives}')
            return 1 if failures else 0

        def stab(name, red):
            print(f'STAB {name} ' + ('caught' if red else 'ZHIV'))
            if not red:
                failures.add(f'stab {name}')

        honest_critic = texts['critic']
        honest_arch = texts['architect']
        lit = next(l for r, k, l in rows if (r, k) == ('critic', 'karta'))
        k08 = next(l for l in classes if l.startswith('- К-08'))
        stab('missing-norm', not assess_norm(honest_critic.replace(lit + '\n', '', 1), 'critic', lit))
        decoy_arch = insert_into_section(honest_arch, SECTIONS['architect'], lit)
        decoy_critic = honest_critic.replace(lit + '\n', '', 1)
        stab('wrong-role', not assess_norm(decoy_critic, 'critic', lit)
             and not assess_norm(decoy_arch, 'architect', lit))
        stab('html-multiline', not assess_norm(
            honest_critic.replace(lit + '\n', '<!--\n' + lit + '\n-->\n', 1), 'critic', lit))
        stab('html-inline', not assess_norm(
            honest_critic.replace(lit + '\n', '<!-- ' + lit + ' -->\n', 1), 'critic', lit))
        stab('fenced-code', not assess_norm(
            honest_critic.replace(lit + '\n', '```text\n' + lit + '\n```\n', 1), 'critic', lit))
        stab('typo', not assess_norm(honest_critic.replace(lit + '\n', lit + ' опечатка\n', 1),
                                     'critic', lit))
        stab('duplicate', not assess_norm(honest_critic.replace(lit + '\n', lit + '\n' + lit + '\n', 1),
                                          'critic', lit))
        stab('quotes-inside', not assess_norm(
            honest_critic.replace(lit + '\n', '«' + lit + '»\n', 1), 'critic', lit))
        stab('optional-section', not assess_norm(
            honest_critic.replace(lit + '\n', '', 1).rstrip('\n')
            + '\n\n## Справка (не обязательна)\n\n' + lit + '\n', 'critic', lit))
        stab('prose-prefix', not assess_norm(
            honest_critic.replace(lit + '\n', 'Пример: ' + lit + '\n', 1), 'critic', lit))
        stab('class-truncated', not assess_class_line(honest_critic.replace(k08 + '\n', '', 1), k08))
        stab('source-loss', bool(foreign_classes(
            {'critic': texts['critic'], 'architect': honest_arch.rstrip('\n') + '\n\n' + k08 + '\n'},
            classes)))
        stab('kap5-retained', 'net-pyati' in cap_violations(
            honest_critic.replace(CAP_TAIL, 'Общий предел — пять critic-вызовов на предмет. ' + CAP_TAIL, 1)))
        stab('soglasie-retained', 'net-soglasiya' in cap_violations(
            honest_critic.replace(CAP_TAIL, KAP_ABSENT[1][1] + ' ' + CAP_TAIL, 1)))
        stab('isprav-retained', 'net-isprav' in cap_violations(
            honest_critic.replace(CAP_TAIL, KAP_ABSENT[2][1] + ' ' + CAP_TAIL, 1)))
        fat = scratch / 'fat-roles'
        shutil.copytree(model_dir / 'roles', fat)
        victim = fat / 'orchestrator.md'
        victim.write_text(victim.read_text(encoding='utf-8') + 'Х' * (LIMIT + 1), encoding='utf-8')
        stab('ceiling-exceeded', ceiling_failures(fat, roles) == {'orchestrator'}
             and not ceiling_failures(model_dir / 'roles', roles))
        drifted = scratch / 'omp-agents-drift'
        shutil.copytree(HERE / 'model' / 'omp-agents', drifted)
        target = drifted / 'critic.md'
        target.write_text(target.read_text(encoding='utf-8') + '\nдрейф\n', encoding='utf-8')
        stab('agents-drift', not assess_agents_parity(model_dir / 'roles', drifted, scratch))
        ref = subprocess.run(
            [sys.executable, str(HERE / 'probe.py'), '--repo', str(ROOT.resolve())],
            capture_output=True, text=True, check=False)
        bare = subprocess.run(['bash', str(HERE / 'red_normy_roley_svyazki_192.sh')],
                              capture_output=True, text=True, check=False)
        stub_wrap = scratch / 'red_normy_roley_svyazki_192.sh'
        stub_wrap.write_text('#!/usr/bin/env bash\nexit 1\n', encoding='utf-8')
        stub_bare = subprocess.run(['bash', str(stub_wrap)],
                                   capture_output=True, text=True, check=False)
        def barer_equal(run):
            return (run.returncode == ref.returncode
                    and sorted(run.stdout.splitlines()) == sorted(ref.stdout.splitlines()))

        stab('barer-stub', barer_equal(bare) and not barer_equal(stub_bare))
        total = 18
        caught = total - len({f for f in failures if f.startswith('stab')})
        print(f'STABS={total} CAUGHT={caught}')
        return 1 if failures else 0
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
