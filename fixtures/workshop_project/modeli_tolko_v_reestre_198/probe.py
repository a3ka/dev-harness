#!/usr/bin/env python3
"""Контракт 198 «модели только в реестре»: батарея-матрица роль × тир × запасная × проект.

Свойство предмета: ЕДИНСТВЕННЫЙ разбор цепочки roles→tiers→models живёт в
scripts/roles.ts (CLI `--resolve-model`); потребители (дверь судейской модели,
шов --fable лаунчера, проектный оверлей, генератор) не несут собственного
разбора и не пинают литеральных моделей; отсутствие роли/тира/алиаса —
именованный отказ, НЕ молчаливый дефолт; смена реестра переключает всех
потребителей без правки кода.

Оракул — В ПАМЯТИ батареи: ожидания вычисляются собственым разбором мира на
python (json), ДО и НЕЗАВИСИМО от вызова субъекта; диск проверяемого как
истина не перечитывается (правило 8). Батарея не подаёт субъекту
распознаваемых маркеров «я — проверка»: env зачищен, cwd нейтрален, argv
совпадает с живым потребителем (правило 3: прямая заглушка «всегда модель X»
краснеет перестановкой значений, которых стаб предсказать не может).

Мир КОНФОРМЕН по документированной грамматике config/agent_models.json:
семейство → непустая строка «провайдер/id»; тир: model — «@семейство» либо
литеральный id, fallback — «@семейство»|null|отсутствует, autoFallback —
bool|отсутствует (отсутствие = ручная подмена = false, канон _comment
реестра); roles → имя существующего тира. Валидный контрпример = инвариантность
к значениям (перестановка id) ∧ расхождение на КОНФОРМНОМ входе; неконформные
входы (битый JSON, пустая модель, отсутствие роли) — отдельные именованные
клетки отказа, не контрпримеры инвариантности.

Режимы: --model (честная реализация обязана быть зелёной всеми клетками),
--stabs (каждый обманный стаб пойман на СВОЕМ входе), --repo <корень>
(живое дерево: красное до замены, зелёное после).

Шовные repo-клетки судят СВОЙСТВО, не дословные токены (правка по вердикту
Crit198V1, мутации MU-1/MU-2): красна ЛЮБАЯ форма собственного чтения
реестра швом — дверь/блок --fable не называют файл реестра вовсе, дверь не
зовёт jq (после Р2 не нужен), блок --fable не несёт значений реестра
(семейства/иды берутся из живого реестра в рантайме — переживают любую
респелл-форму: переименование переменных, "fable"[ ]*:, смену способа
чтения). Дословные токены прежнего кода — только дополнительная форма,
не единственная.

Текстовое окно судит содержимое, но не ДОСТИЖИМОСТЬ (вердикт Crit198V2,
блок (2), мутации MU-4/MU-5): чтение, вынесенное из окна функцией того же
файла НАД стражем FABLE либо файлом-хелпером с фолбеком на резолвер,
проходило всю приёмку зелёным при живом собственном чтении. Закрытие
КЛАССА — три слоя:
  (а) достижимость: транзитивное замыкание функций того же файла, зовомых
      из блока --fable, судится теми же свойствами, что и сам блок;
  (б) поведение: в мире с ОТКАЗЫВАЮЩИМ резолвером (roles.ts заменён
      отказником rc 2) дверь обязана fail-closed rc 2 с именованным отказом,
      а путь --fable — падать громко ДО exec omp; ожидание/модель, пережившие
      отказ резолвера, получены из иного источника — независимо от места и
      формы чтения (окно/функция/файл-хелпер/кэш/литерал-фолбек/молчаливый
      дефолт). Обе клетки несут позитивный контроль (прогон с родным
      roles.ts обязан дойти до решения/exec) — отказ по чужой причине не
      выдаёт себя за зелёное (анти-плацебо, 016);
  (в) остаток (маскировка ИМЕНИ файла реестра конкатенацией/глобом) —
      cognitive-only в контракте; поведенческим клеткам маскировка
      безразлична: они судят источник, а не текст.
"""
import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve()
BATTERY = HERE.parent
FIX = BATTERY.parent            # fixtures/
REPO_DEFAULT = HERE.parents[3]  # корень харнесса
STABS = BATTERY / 'stabs'

# Канон заголовка секции правил AGENTS.md (единственный источник — сам
# AGENTS.md мастерской; сверяется и с gen-harness.ts --agents-rules).
ZAGOLOVOK_PRAVIL = '## Правила, каждое из которых уже стоило времени'

# Судейский алфавит двери (контракт 104): ровно четыре роли.
JUDGES = ('critic', 'adversary', 'reviewer', 'arbiter')


def run(argv, cwd, env=None, timeout=90):
    e = {'PATH': os.environ.get('PATH', '/usr/bin:/bin'), 'HOME': str(cwd)}
    if env:
        e.update(env)
    return subprocess.run(argv, cwd=str(cwd), env=e, text=True,
                          capture_output=True, timeout=timeout)


# ── миры ─────────────────────────────────────────────────────────────────────

def toy_registry(source_repo, judges_only=False):
    """Живой РЕЕСТР-структуры мир: значения models заменены на игрушечные id.

    Семейства/тиры/роли/роутинг — форма живого config/agent_models.json
    (прочитан с диска источника, в память батареи), строки моделей —
    детерминированные toy-идентификаторы: инвариантность к значениям без
    единого литерала внешней модели в коде батареи.
    """
    reg = json.loads((source_repo / 'config' / 'agent_models.json')
                     .read_text(encoding='utf-8'))
    toy = {}
    for i, fam in enumerate(sorted(reg.get('models', {}).keys())):
        toy[fam] = 'toyprov%d/tm-%d' % (i, i)
    reg['models'] = toy
    if judges_only:
        keep = set(JUDGES)
        reg['roles'] = {r: t for r, t in reg['roles'].items() if r in keep}
    return reg


def write_registry(world, reg):
    p = world / 'config' / 'agent_models.json'
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(reg, ensure_ascii=False, indent=2), encoding='utf-8')


def make_world(tmp, source_repo, name, reg, *, with_door=False, with_gen=False,
               with_checker=False):
    world = Path(tmp) / name
    (world / 'scripts').mkdir(parents=True)
    shutil.copy2(source_repo / 'scripts' / 'roles.ts', world / 'scripts' / 'roles.ts')
    if with_door:
        shutil.copy2(source_repo / 'scripts' / 'check_sud_model.sh',
                     world / 'scripts' / 'check_sud_model.sh')
    if with_gen:
        shutil.copy2(source_repo / 'scripts' / 'gen-harness.ts',
                     world / 'scripts' / 'gen-harness.ts')
        shutil.copytree(source_repo / 'roles', world / 'roles')
        (world / '.omp').mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_repo / '.omp' / 'config.yml', world / '.omp' / 'config.yml')
        # .omp/agents копируем не весь: генератор пишет его сам; но --check
        # сверяет только .md — пустого каталога достаточно для фазы write.
        (world / '.omp' / 'agents').mkdir(parents=True, exist_ok=True)
    if with_checker:
        shutil.copy2(source_repo / 'scripts' / 'check_project_session.sh',
                     world / 'scripts' / 'check_project_session.sh')
    write_registry(world, reg)
    return world


# ── оракул в памяти батареи (независимый разбор, python ≠ ts ≠ bash) ─────────

def oracle(reg, role):
    """(tier, model, fallback, autoFallback) | именованный отказ (rc, имя)."""
    if role not in reg.get('roles', {}):
        return (1, 'ROLE_UNKNOWN')
    tier = reg['roles'][role]
    tiers = reg.get('tiers', {})
    if tier not in tiers:
        return (1, 'TIER_MISSING')

    def resolve(ref, where):
        if not isinstance(ref, str) or ref == '':
            return (1, 'MODEL_EMPTY')
        if ref.startswith('@'):
            fam = ref[1:]
            mid = reg.get('models', {}).get(fam)
            if mid is None:
                return (1, 'ALIAS_UNRESOLVED')
            if mid == '':
                return (1, 'MODEL_EMPTY')
            return (0, mid)
        return (0, ref)

    spec = tiers[tier]
    r = resolve(spec.get('model'), 'model')
    if r[0]:
        return r
    model = r[1]
    fb = spec.get('fallback')
    if fb is None:
        fallback = '-'
    else:
        r = resolve(fb, 'fallback')
        if r[0]:
            return r
        fallback = r[1]
    auto = spec.get('autoFallback') is True
    return (0, tier, model, fallback, auto)


def cli(world, role, cwd):
    """Вызов субъекта-резолвера: node scripts/roles.ts --resolve-model …"""
    return run(['node', str(world / 'scripts' / 'roles.ts'),
                '--resolve-model', role, '--root', str(world)], cwd)


def parse_tsv(out):
    lines = [l for l in out.split('\n') if l.strip()]
    if len(lines) != 1:
        return None
    f = lines[0].split('\t')
    return f if len(f) == 4 else None


# ── клетки матрицы (--model; каждая обязана быть зелёной у честной реализации)
# Именованные клетки; стабы привязаны к ним КОДОМ (см. main/STAB_BIND). ───────

CELLS = {}
FAILED = []


def cell(name):
    def deco(fn):
        CELLS[name] = fn
        return fn
    return deco


def check(cond, name, reason):
    if not cond:
        FAILED.append(name)
        print('CELL %s КРАСНА: %s' % (name, reason), flush=True)
        return False
    print('CELL %s OK' % name, flush=True)
    return True


def expect_cli(world, role, tag):
    """rc 0 + TSV == оракулу; либо именованный отказ ровно тот, что у оракула."""
    o = oracle(world_reg(world), role)
    r = cli(world, role, world.parent)
    if o[0] == 0:
        _, tier, model, fallback, auto = o
        want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
        if r.returncode != 0 or parse_tsv(r.stdout) is None:
            return check(False, tag,
                         'rc=%d stdout=%r — резолвер CLI отсутствует либо молчит (ожидалась строка %r)'
                         % (r.returncode, r.stdout.strip()[:80], want))
        got = [l for l in r.stdout.split('\n') if l.strip()][0]
        return check(got == want, tag, 'вывод %r ≠ ожиданию %r (оракул в памяти батареи)' % (got, want))
    rc_want, named = o[0], o[1]
    if r.returncode == 0 or named not in (r.stdout + r.stderr):
        return check(False, tag,
                     'ожидался именованный отказ %s (rc %d), субъект: rc=%d stdout=%r stderr=%r — молчаливый дефолт запрещён'
                     % (named, rc_want, r.returncode, r.stdout.strip()[:80], r.stderr.strip()[:80]))
    return check(r.returncode == rc_want, tag,
                 'код отказа %d ≠ %d (%s)' % (r.returncode, rc_want, named))


def world_reg(world):
    return json.loads((world / 'config' / 'agent_models.json').read_text(encoding='utf-8'))


def primary_of(reg, role):
    o = oracle(reg, role)
    assert o[0] == 0, o
    return o[2]


def fallback_of(reg, role):
    o = oracle(reg, role)
    assert o[0] == 0, o
    return o[3]


# --- резолвер: роль × тир × запасная × значения ---

@cell('resolver_matrix_base')
def c_matrix_base(ctx):
    """Все роли живой-формы реестра: TSV равен оракулу (роль → тир → id)."""
    world = ctx['world_full']
    reg = world_reg(world)
    ok = True
    for role in sorted(reg['roles']):
        o = oracle(reg, role)
        if o[0] != 0:
            ok = check(False, 'resolver_matrix_base', 'мир неконформен: %s → %r' % (role, o)) and ok
            continue
        _, tier, model, fallback, auto = o
        r = cli(world, role, world.parent)
        want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
        got = [l for l in r.stdout.split('\n') if l.strip()]
        good = r.returncode == 0 and len(got) == 1 and got[0] == want
        if not good:
            ok = check(False, 'resolver_matrix_base',
                       'роль %s: rc=%d вывод %r ≠ %r — резолвер CLI отсутствует либо расходится с реестром'
                       % (role, r.returncode, got[:1], want)) and ok
    if ok:
        check(True, 'resolver_matrix_base', '')
    return ok


@cell('resolver_primary_swap')
def c_primary_swap(ctx):
    """Перестановка основной модели роли (тир → другое семейство) — только правкой мира."""
    world = ctx['world_full']
    reg = world_reg(world)
    role = 'architect'
    tier = reg['roles'][role]
    fams = sorted(reg['models'])
    spec = reg['tiers'][tier]
    old = spec['model']
    new = [f for f in fams if '@' + f != old][0]
    spec['model'] = '@' + new
    write_registry(world, reg)
    try:
        return expect_cli(world, role, 'resolver_primary_swap')
    finally:
        spec['model'] = old
        write_registry(world, reg)


@cell('resolver_family_version_swap')
def c_family_version_swap(ctx):
    """Смена версии СЕМЕЙСТВА — одна строка models: вывод следует ей, алиас не протекает."""
    world = ctx['world_full']
    reg = world_reg(world)
    role = 'critic'
    tier = reg['roles'][role]
    fam = reg['tiers'][tier]['model'].lstrip('@')
    old = reg['models'][fam]
    reg['models'][fam] = old + '-v2'
    write_registry(world, reg)
    try:
        return expect_cli(world, role, 'resolver_family_version_swap')
    finally:
        reg['models'][fam] = old
        write_registry(world, reg)


@cell('resolver_fallback_swap')
def c_fallback_swap(ctx):
    """Запасная: объявлена/снята — поле следует декларации, пусто только по null."""
    world = ctx['world_full']
    reg = world_reg(world)
    role = 'orchestrator'
    tier = reg['roles'][role]
    spec = reg['tiers'][tier]
    old_fb = spec.get('fallback')
    fams = sorted(reg['models'])
    spec['fallback'] = '@' + fams[0]
    write_registry(world, reg)
    ok = expect_cli(world, role, 'resolver_fallback_swap')
    spec['fallback'] = None
    write_registry(world, reg)
    ok = expect_cli(world, role, 'resolver_fallback_swap') and ok
    spec['fallback'] = old_fb
    write_registry(world, reg)
    return ok


@cell('resolver_autofallback_toggle')
def c_autofallback_toggle(ctx):
    """autoFallback: true → false → отсутствует (= false, ручная подмена Н-50)."""
    world = ctx['world_full']
    reg = world_reg(world)
    role = 'architect'
    spec = reg['tiers'][reg['roles'][role]]
    old = spec.get('autoFallback')
    for v in (False, None, True):
        if v is None:
            spec.pop('autoFallback', None)
        else:
            spec['autoFallback'] = v
        write_registry(world, reg)
        if not expect_cli(world, role, 'resolver_autofallback_toggle'):
            spec['autoFallback'] = old
            write_registry(world, reg)
            return False
    spec['autoFallback'] = old
    write_registry(world, reg)
    return True


@cell('resolver_role_unknown')
def c_role_unknown(ctx):
    world = ctx['world_full']
    return expect_cli(world, 'rol-kotoroj-net', 'resolver_role_unknown')


@cell('resolver_tier_missing')
def c_tier_missing(ctx):
    world = ctx['world_full']
    reg = world_reg(world)
    reg['roles']['critic'] = 'tir-kotorogo-net'
    write_registry(world, reg)
    try:
        return expect_cli(world, 'critic', 'resolver_tier_missing')
    finally:
        reg['roles']['critic'] = ctx['orig_critic_tier']
        write_registry(world, reg)


@cell('resolver_alias_unresolvable')
def c_alias_unresolvable(ctx):
    world = ctx['world_full']
    reg = world_reg(world)
    tier = reg['roles']['critic']
    old = reg['tiers'][tier]['model']
    reg['tiers'][tier]['model'] = '@semejstvo-kotorogo-net'
    write_registry(world, reg)
    try:
        return expect_cli(world, 'critic', 'resolver_alias_unresolvable')
    finally:
        reg['tiers'][tier]['model'] = old
        write_registry(world, reg)


@cell('resolver_model_empty')
def c_model_empty(ctx):
    world = ctx['world_full']
    reg = world_reg(world)
    tier = reg['roles']['critic']
    fam = reg['tiers'][tier]['model'].lstrip('@')
    old = reg['models'][fam]
    reg['models'][fam] = ''
    write_registry(world, reg)
    try:
        return expect_cli(world, 'critic', 'resolver_model_empty')
    finally:
        reg['models'][fam] = old
        write_registry(world, reg)


@cell('resolver_registry_missing')
def c_registry_missing(ctx):
    world = ctx['world_broken']
    cfg = world / 'config' / 'agent_models.json'
    moved = world / 'config' / 'agent_models.json.aside'
    cfg.rename(moved)
    try:
        r = cli(world, 'critic', world.parent)
        named = 'REGISTRY_MISSING' in r.stdout + r.stderr
        return check(r.returncode == 2 and named, 'resolver_registry_missing',
                     'ожидался rc 2 REGISTRY_MISSING; субъект rc=%d stderr=%r — молчание/дефолт запрещены'
                     % (r.returncode, r.stderr.strip()[:100]))
    finally:
        moved.rename(cfg)


@cell('resolver_registry_invalid')
def c_registry_invalid(ctx):
    world = ctx['world_broken']
    cfg = world / 'config' / 'agent_models.json'
    old = cfg.read_text(encoding='utf-8')
    cfg.write_text('{ это не json', encoding='utf-8')
    try:
        r = cli(world, 'critic', world.parent)
        named = 'REGISTRY_INVALID' in r.stdout + r.stderr
        return check(r.returncode == 2 and named, 'resolver_registry_invalid',
                     'ожидался rc 2 REGISTRY_INVALID; субъект rc=%d stderr=%r'
                     % (r.returncode, r.stderr.strip()[:100]))
    finally:
        cfg.write_text(old, encoding='utf-8')


@cell('resolver_plain_call_parity')
def c_plain_call_parity(ctx):
    """Три вызова без маркеров батареи (разный cwd, зачищенный env, нейтральный
    родитель) байт-равны и равны оракулу.

    Ловит «надстройку, подменяющую ответы проверкам»: субъект, отвечающий
    честно только по признаку проверки (env/argv/cwd), расходит вызовы.
    Третий вызов идёт под НЕЙТРАЛЬНЫМ родителем — bash -c 'node …': родитель
    процесса резолвера есть bash, не батарея/дверь/генератор; закрывает канал
    ppid (совет 1 вердикта Crit198V1, мутация MU-3b «родитель чужой — лгать»).
    Без exec: bash остаётся родителем node и ждёт его код возврата.
    """
    world = ctx['world_full']
    role = 'critic'
    o = oracle(world_reg(world), role)
    _, tier, model, fallback, auto = o
    want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
    plain = Path(tempfile.mkdtemp(prefix='plain-'))
    a = cli(world, role, world.parent)
    b = run(['node', str(world / 'scripts' / 'roles.ts'), '--resolve-model', role,
             '--root', str(world)], plain, env={'HOME': str(plain)})
    c = run(['bash', '-c', 'node %s --resolve-model %s --root %s'
             % (shlex.quote(str(world / 'scripts' / 'roles.ts')), shlex.quote(role),
                shlex.quote(str(world)))], plain, env={'HOME': str(plain)})
    shutil.rmtree(plain, ignore_errors=True)
    ok = (a.returncode == 0 and b.returncode == 0 and c.returncode == 0
          and a.stdout == b.stdout == c.stdout
          and a.stdout.strip() == want.strip())
    return check(ok, 'resolver_plain_call_parity',
                 'вызовы разошлись либо ≠ оракулу: a(rc=%d,%r) b(rc=%d,%r) c(rc=%d,%r) want=%r — подмена ответа по признаку проверки/каналу ppid'
                 % (a.returncode, a.stdout.strip()[:60], b.returncode, b.stdout.strip()[:60],
                    c.returncode, c.stdout.strip()[:60], want))


@cell('resolver_root_foreign')
def c_root_foreign(ctx):
    """Скрипт в A, реестр в B: резолв идёт по --root, не по каталогу скрипта
    (совет 3 вердикта Crit198V1 — резолвер, молча игнорирующий --root, красен)."""
    world = ctx['world_full']
    reg = world_reg(world)
    a = Path(ctx['tmp']) / 'skript-v-A'
    b = Path(ctx['tmp']) / 'reestr-v-B'
    (a / 'scripts').mkdir(parents=True, exist_ok=True)
    shutil.copy2(world / 'scripts' / 'roles.ts', a / 'scripts' / 'roles.ts')
    write_registry(b, reg)
    o = oracle(reg, 'critic')
    _, tier, model, fallback, auto = o
    want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
    r = run(['node', str(a / 'scripts' / 'roles.ts'), '--resolve-model', 'critic',
             '--root', str(b)], a)
    got = [l for l in r.stdout.split('\n') if l.strip()]
    ok = r.returncode == 0 and len(got) == 1 and got[0] == want
    return check(ok, 'resolver_root_foreign',
                 'скрипт в A, реестр в B: rc=%d вывод %r ≠ %r — резолвер игнорирует --root (молча читает свой каталог)'
                 % (r.returncode, got[:1], want))


# --- дверь судейской модели как потребитель резолва ---

def door(world, argv, cwd):
    return run(['bash', str(world / 'scripts' / 'check_sud_model.sh')] + argv, cwd)


@cell('door_spawn_primary')
def c_door_spawn_primary(ctx):
    world = ctx['world_door']
    reg = world_reg(world)
    m = primary_of(reg, 'critic')
    r = door(world, ['--spawn', 'critic', m, '--root', str(world)], world.parent)
    return check(r.returncode == 0, 'door_spawn_primary',
                 'назначенная primary модели судьи: rc=%d stderr=%r' % (r.returncode, r.stderr.strip()[:100]))


@cell('door_spawn_fallback_refused')
def c_door_spawn_fallback(ctx):
    """На СПАВНЕ запасная не принимается (обязательство 104: только primary)."""
    world = ctx['world_door']
    reg = world_reg(world)
    fb = fallback_of(reg, 'critic')
    if fb == '-':
        return check(True, 'door_spawn_fallback_refused', '')
    r = door(world, ['--spawn', 'critic', fb, '--root', str(world)], world.parent)
    return check(r.returncode == 1 and 'не тира роли' in r.stderr,
                 'door_spawn_fallback_refused',
                 'фолбэк на спавне должен отказывать rc 1 «модель не тира роли»: rc=%d stderr=%r'
                 % (r.returncode, r.stderr.strip()[:100]))


@cell('door_spawn_foreign_refused')
def c_door_spawn_foreign(ctx):
    world = ctx['world_door']
    reg = world_reg(world)
    m = primary_of(reg, 'adversary')  # модель чужой роли/тира
    r = door(world, ['--spawn', 'critic', m, '--root', str(world)], world.parent)
    return check(r.returncode == 1 and 'не тира роли' in r.stderr,
                 'door_spawn_foreign_refused',
                 'чужая модель обязана отказывать rc 1: rc=%d stderr=%r'
                 % (r.returncode, r.stderr.strip()[:100]))


def verdict_world_files(tmp, model, flag):
    trace = Path(tmp) / 'trace.tsv'
    trace.write_text('critic\t%s\t%s\ts-198\t%s\n' % (model, flag, 'a' * 40), encoding='utf-8')
    return trace


@cell('door_verdict_fallback_flow')
def c_door_verdict_fallback(ctx):
    """Трасса: allowed на primary → rc 0; denied на ОБЪЯВЛЕННОЙ запасной → rc 0."""
    world = ctx['world_door']
    reg = world_reg(world)
    m, fb = primary_of(reg, 'critic'), fallback_of(reg, 'critic')
    ok = True
    t1 = verdict_world_files(world.parent, m, 'allowed')
    r = door(world, ['--verdict', 'critic', '--trace', str(t1), '--object', 'a' * 40,
                     '--session', 's-198', '--root', str(world)], world.parent)
    ok = check(r.returncode == 0, 'door_verdict_fallback_flow',
               'allowed на primary: rc=%d stderr=%r' % (r.returncode, r.stderr.strip()[:100])) and ok
    if fb != '-':
        t2 = verdict_world_files(world.parent, fb, 'denied')
        r = door(world, ['--verdict', 'critic', '--trace', str(t2), '--object', 'a' * 40,
                         '--session', 's-198', '--root', str(world)], world.parent)
        ok = check(r.returncode == 0, 'door_verdict_fallback_flow',
                   'denied на объявленной запасной: rc=%d stderr=%r' % (r.returncode, r.stderr.strip()[:100])) and ok
    if ok:
        check(True, 'door_verdict_fallback_flow', '')
    return ok


@cell('door_verdict_foreign_fallback')
def c_door_verdict_foreign_fb(ctx):
    world = ctx['world_door']
    reg = world_reg(world)
    own = {primary_of(reg, 'critic'), fallback_of(reg, 'critic')}
    m = [primary_of(reg, j) for j in JUDGES
         if oracle(reg, j)[0] == 0 and primary_of(reg, j) not in own][0]
    t = verdict_world_files(world.parent, m, 'denied')
    r = door(world, ['--verdict', 'critic', '--trace', str(t), '--object', 'a' * 40,
                     '--session', 's-198', '--root', str(world)], world.parent)
    return check(r.returncode == 1 and 'фолбэк вне списка' in r.stderr,
                 'door_verdict_foreign_fallback',
                 'denied на чужой модели: rc=%d stderr=%r' % (r.returncode, r.stderr.strip()[:100]))


@cell('door_swap_green')
def c_door_swap_green(ctx):
    """Перестановка реестра (критик → другое семейство): НОВАЯ модель проходит дверь."""
    world = ctx['world_door']
    reg = world_reg(world)
    tier = reg['roles']['critic']
    spec = reg['tiers'][tier]
    old = spec['model']
    fams = sorted(reg['models'])
    new = [f for f in fams if '@' + f != old][0]
    spec['model'] = '@' + new
    write_registry(world, reg)
    try:
        m = primary_of(reg, 'critic')
        r = door(world, ['--spawn', 'critic', m, '--root', str(world)], world.parent)
        return check(r.returncode == 0, 'door_swap_green',
                     'смена реестра должна переключать дверь сама: rc=%d stderr=%r (модель %s)'
                     % (r.returncode, r.stderr.strip()[:100], m))
    finally:
        spec['model'] = old
        write_registry(world, reg)


@cell('door_stale_primary')
def c_door_stale_primary(ctx):
    """Та же перестановка: СТАРАЯ модель больше не проходит —双向 красна, не «любая не-GLM»."""
    world = ctx['world_door']
    reg = world_reg(world)
    tier = reg['roles']['critic']
    spec = reg['tiers'][tier]
    old = spec['model']
    stale = reg['models'][old.lstrip('@')]
    fams = sorted(reg['models'])
    new = [f for f in fams if '@' + f != old][0]
    spec['model'] = '@' + new
    write_registry(world, reg)
    try:
        r = door(world, ['--spawn', 'critic', stale, '--root', str(world)], world.parent)
        return check(r.returncode == 1 and 'не тира роли' in r.stderr,
                     'door_stale_primary',
                     'устаревшая модель обязана отказывать после перестановки: rc=%d stderr=%r'
                     % (r.returncode, r.stderr.strip()[:100]))
    finally:
        spec['model'] = old
        write_registry(world, reg)


@cell('door_broken_registry')
def c_door_broken(ctx):
    world = ctx['world_door']
    reg = world_reg(world)
    tier = reg['roles']['critic']
    old = reg['tiers'][tier]['model']
    reg['tiers'][tier]['model'] = '@semejstvo-kotorogo-net'
    write_registry(world, reg)
    try:
        r = door(world, ['--spawn', 'critic', 'toyprov0/tm-0', '--root', str(world)], world.parent)
        return check(r.returncode == 2, 'door_broken_registry',
                     'битая цепочка реестра — fail-closed rc 2 двери (не 0 и не 1): rc=%d stderr=%r'
                     % (r.returncode, r.stderr.strip()[:100]))
    finally:
        reg['tiers'][tier]['model'] = old
        write_registry(world, reg)


@cell('door_no_role')
def c_door_no_role(ctx):
    world = ctx['world_door']
    reg = world_reg(world)
    old = reg['roles'].pop('critic')
    write_registry(world, reg)
    try:
        r = door(world, ['--spawn', 'critic', 'toyprov0/tm-0', '--root', str(world)], world.parent)
        return check(r.returncode == 2, 'door_no_role',
                     'роли critic нет в реестре — fail-closed rc 2: rc=%d stderr=%r'
                     % (r.returncode, r.stderr.strip()[:100]))
    finally:
        reg['roles']['critic'] = old
        write_registry(world, reg)


# --- генератор как потребитель (согласованность резолва и генерации) ---

@cell('gen_follows_registry')
def c_gen_follows(ctx):
    """Перестановка + смена версии: .omp/agents и modelRoles следуют реестру, --check зелёный.

    Зона согласованности 198: значения modelRoles/frontmatter == выходу
    резолвера. Паритет тел ролей и routing-грамматика — зона 998, здесь не судятся.
    """
    world = ctx['world_gen']
    reg = world_reg(world)
    role = 'critic'
    tier = reg['roles'][role]
    fam = reg['tiers'][tier]['model'].lstrip('@')
    reg['models'][fam] = reg['models'][fam] + '-v9'
    write_registry(world, reg)
    try:
        g1 = run(['node', 'scripts/gen-harness.ts'], world)
        if g1.returncode != 0:
            return check(False, 'gen_follows_registry',
                         'генерация упала: rc=%d stderr=%r' % (g1.returncode, g1.stderr.strip()[:200]))
        o = oracle(reg, role)
        _, tier_, model_, _, _ = o
        cfg = (world / '.omp' / 'config.yml').read_text(encoding='utf-8')
        agent = (world / '.omp' / 'agents' / (role + '.md')).read_text(encoding='utf-8')
        line = '  %s: "%s"' % (tier_, model_)
        fm = 'model: ["@%s"]' % tier_
        g2 = run(['node', 'scripts/gen-harness.ts', '--check'], world)
        ok = (line in cfg) and (fm in agent) and g2.returncode == 0
        return check(ok, 'gen_follows_registry',
                     'modelRoles/frontmatter не следовали реестру либо --check красен: line=%r fm=%r check=%d'
                     % (line in cfg, fm in agent, g2.returncode))
    finally:
        reg['models'][fam] = reg['models'][fam].replace('-v9', '')
        write_registry(world, reg)
        run(['node', 'scripts/gen-harness.ts'], world)


@cell('gen_fallback_chain')
def c_gen_chain(ctx):
    """Живая цепочка подмены строится ТОЛЬКО для fallback+autoFallback:true (Н-50)."""
    world = ctx['world_gen']
    reg = world_reg(world)
    tier = reg['roles']['architect']
    spec = reg['tiers'][tier]
    old_fb, old_auto = spec.get('fallback'), spec.get('autoFallback')
    fams = sorted(reg['models'])
    spec['fallback'], spec['autoFallback'] = '@' + fams[1], True
    write_registry(world, reg)
    run(['node', 'scripts/gen-harness.ts'], world)
    cfg_on = (world / '.omp' / 'config.yml').read_text(encoding='utf-8')
    spec['autoFallback'] = False
    write_registry(world, reg)
    run(['node', 'scripts/gen-harness.ts'], world)
    cfg_off = (world / '.omp' / 'config.yml').read_text(encoding='utf-8')
    spec['fallback'], spec['autoFallback'] = old_fb, old_auto
    write_registry(world, reg)
    run(['node', 'scripts/gen-harness.ts'], world)
    chain_on = [l for l in cfg_on.split('\n') if l.strip().startswith(tier + ': [')]
    chain_off = [l for l in cfg_off.split('\n') if l.strip().startswith(tier + ': [')]
    ok = len(chain_on) == 1 and len(chain_off) == 0
    return check(ok, 'gen_fallback_chain',
                 'autoFallback=true обязан давать цепочку, false — снимать: on=%r off=%r' % (chain_on, chain_off))


# --- проектный оверлей: семейства разворачиваются тем же реестром ---

@cell('overlay_registry_swap')
def c_overlay_swap(ctx):
    """Оверлей проекта: @семейство разворачивается реестром мира; смена версии следует."""
    world = ctx['world_gen']
    reg = world_reg(world)
    fams = sorted(reg['models'])
    overlay = world / 'overlay.yml'
    overlay.write_text('models:\n  t-project: "@%s"\n' % fams[0], encoding='utf-8')
    r1 = run(['node', 'scripts/gen-harness.ts', '--resolve-overlay', 'overlay.yml'], world)
    old = reg['models'][fams[0]]
    reg['models'][fams[0]] = old + '-v3'
    write_registry(world, reg)
    r2 = run(['node', 'scripts/gen-harness.ts', '--resolve-overlay', 'overlay.yml'], world)
    reg['models'][fams[0]] = old
    write_registry(world, reg)
    ok = (r1.returncode == 0 and r2.returncode == 0
          and ('"%s"' % old) in r1.stdout and ('"%s"' % (old + '-v3')) in r2.stdout
          and ('@' + fams[0]) not in r2.stdout)
    return check(ok, 'overlay_registry_swap',
                 'оверлей обязан разворачиваться реестром мира и следовать его версии: r1=%r r2=%r'
                 % (r1.stdout.strip()[:80], r2.stdout.strip()[:80]))


@cell('overlay_unknown_family')
def c_overlay_unknown(ctx):
    world = ctx['world_gen']
    overlay = world / 'overlay-bad.yml'
    overlay.write_text('models:\n  t-project: "@semejstvo-kotorogo-net"\n', encoding='utf-8')
    r = run(['node', 'scripts/gen-harness.ts', '--resolve-overlay', 'overlay-bad.yml'], world)
    ok = r.returncode == 1 and 'неизвестное семейство' in r.stderr
    return check(ok, 'overlay_unknown_family',
                 'неизвестное семейство оверлея — именованный отказ rc 1: rc=%d stderr=%r'
                 % (r.returncode, r.stderr.strip()[:100]))


# --- опечатка заголовка правил (малая правка предмета) ---

def checker_world(ctx, drop_rule):
    """Факты пары сессий: основная несёт правила, проектная — по выбору."""
    tmp = ctx['tmp']
    base = Path(tmp) / ('pravila-ok' if not drop_rule else 'pravila-bad')
    if base.exists():
        return base
    mainhome = base / 'mainhome'
    prof = mainhome / '.omp' / 'profiles' / 'dev' / 'agent'
    prof.mkdir(parents=True)
    for f in ('config.yml', 'models.db', 'skill-descriptions.db', 'agent.db'):
        (prof / f).write_text('x', encoding='utf-8')
    workdir = base / 'maincwd'
    workdir.mkdir()
    (workdir / '.omp').mkdir(exist_ok=True)
    (workdir / '.omp' / 'config.yml').write_text('politika: ustanovka 198\n', encoding='utf-8')
    rules = [ZAGOLOVOK_PRAVIL, '- правило раз (проба батареи 198).',
             '- правило два (проба батареи 198).']
    (workdir / 'AGENTS.md').write_text('\n'.join(rules) + '\n\n## Дальше\n', encoding='utf-8')
    prompt = 'системный промпт основной сессии — строка базы 198.\n'
    (workdir / 'prompt-main.md').write_text(prompt, encoding='utf-8')
    delivered = [prompt] + (rules if not drop_rule else rules[:-1])
    projhome = base / 'projhome'
    (projhome / '.omp' / 'profiles' / 'proj').mkdir(parents=True)
    (base / 'prompt-proj.md').write_text('\n'.join(delivered), encoding='utf-8')
    (base / 'main.argv').write_text('\n'.join([
        'omp', '--profile', 'dev', '--model', 'toyprov0/tm-0', '--tools', 'bash',
        '--append-system-prompt', str(workdir / 'prompt-main.md')]) + '\n', encoding='utf-8')
    (base / 'main.env').write_text('HOME=%s\nPWD=%s\n' % (mainhome, workdir), encoding='utf-8')
    (base / 'proj.argv').write_text('\n'.join([
        'omp', '--profile', 'proj', '--model', 'toyprov0/tm-0',
        '--config', str(workdir / '.omp' / 'config.yml'),
        '--append-system-prompt', str(base / 'prompt-proj.md')]) + '\n', encoding='utf-8')
    (base / 'proj.env').write_text('HOME=%s\nPWD=%s\n' % (projhome, workdir), encoding='utf-8')
    return base


def checker_run(script, base, cwd):
    return run(['bash', str(script), '--main-argv', str(base / 'main.argv'),
                '--main-env', str(base / 'main.env'),
                '--project-argv', str(base / 'proj.argv'),
                '--project-env', str(base / 'proj.env')], cwd)


@cell('pravila_missing_detected')
def c_pravila_missing(ctx):
    """Проектная сессия потеряла правило основной → РАСХОЖДЕНИЕ pravila, rc 1.

    Сегодня (опечатка «…стоило время») заголовок не совпадает с каноном
    AGENTS.md, множество правил пусто и недоставка НЕ ОБНАРУЖИВАЕТСЯ — клетка
    честно красна до правки литерала к канону.
    """
    world = ctx['world_checker']
    base = checker_world(ctx, drop_rule=True)
    r = checker_run(world / 'scripts' / 'check_project_session.sh', base, world.parent)
    ok = r.returncode == 1 and 'РАСХОЖДЕНИЕ pravila' in r.stdout
    return check(ok, 'pravila_missing_detected',
                 'недоставка правил обязана давать «РАСХОЖДЕНИЕ pravila» rc 1: rc=%d stdout=%r — заголовок правил разошёлся с каноном'
                 % (r.returncode, r.stdout.strip()[:120]))


@cell('pravila_delivered_ok')
def c_pravila_ok(ctx):
    world = ctx['world_checker']
    base = checker_world(ctx, drop_rule=False)
    r = checker_run(world / 'scripts' / 'check_project_session.sh', base, world.parent)
    ok = r.returncode in (0, 1) and 'РАСХОЖДЕНИЕ pravila' not in r.stdout
    return check(ok, 'pravila_delivered_ok',
                 'доставленная норма не должна флагаться pravila: rc=%d stdout=%r'
                 % (r.returncode, r.stdout.strip()[:120]))


# ── repo-клетки: живое дерево (красное до замены, зелёное после) ─────────────

def repo_cli(root, role, cwd):
    return run(['node', str(root / 'scripts' / 'roles.ts'),
                '--resolve-model', role, '--root', str(root)], cwd)


def cell_repo_resolver_cli(root, tmp):
    r = repo_cli(root, 'orchestrator', tmp)
    o = oracle(json.loads((root / 'config' / 'agent_models.json').read_text(encoding='utf-8')), 'orchestrator')
    if o[0] != 0:
        return check(False, 'repo_resolver_cli', 'живой реестр неконформен: %r' % (o,))
    _, tier, model, fallback, auto = o
    want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
    got = [l for l in r.stdout.split('\n') if l.strip()]
    ok = r.returncode == 0 and len(got) == 1 and got[0] == want
    return check(ok, 'repo_resolver_cli',
                 'rc=%d вывод %r ≠ %r — резолвер CLI отсутствует на живом дереве'
                 % (r.returncode, got[:1], want))


def cell_repo_resolver_matrix(root, tmp):
    reg = json.loads((root / 'config' / 'agent_models.json').read_text(encoding='utf-8'))
    ok = True
    n = 0
    for role in sorted(reg['roles']):
        n += 1
        o = oracle(reg, role)
        if o[0] != 0:
            ok = check(False, 'repo_resolver_matrix', 'роль %s: оракул отказал %r' % (role, (o,))) and ok
            continue
        _, tier, model, fallback, auto = o
        want = '%s\t%s\t%s\t%s' % (tier, model, fallback, 'true' if auto else 'false')
        r = repo_cli(root, role, tmp)
        got = [l for l in r.stdout.split('\n') if l.strip()]
        good = r.returncode == 0 and len(got) == 1 and got[0] == want
        if not good:
            ok = check(False, 'repo_resolver_matrix',
                       'роль %s: rc=%d %r ≠ %r' % (role, r.returncode, got[:1], want)) and ok
    if ok:
        check(True, 'repo_resolver_matrix', 'ролей решено: %d' % n)
    return ok


def cell_repo_door_judges(root, tmp):
    reg = json.loads((root / 'config' / 'agent_models.json').read_text(encoding='utf-8'))
    ok = True
    primaries = {j: primary_of(reg, j) for j in JUDGES if oracle(reg, j)[0] == 0}
    for j, m in primaries.items():
        r = run(['bash', str(root / 'scripts' / 'check_sud_model.sh'),
                 '--spawn', j, m, '--root', str(root)], tmp)
        ok = check(r.returncode == 0, 'repo_door_judges',
                   '%s на назначенной primary: rc=%d stderr=%r' % (j, r.returncode, r.stderr.strip()[:100])) and ok
    values = sorted(set(primaries.values()))
    if len(values) >= 2:
        j = sorted(primaries)[0]
        foreign = [v for v in values if v != primaries[j]][0]
        r = run(['bash', str(root / 'scripts' / 'check_sud_model.sh'),
                 '--spawn', j, foreign, '--root', str(root)], tmp)
        ok = check(r.returncode == 1, 'repo_door_judges',
                   '%s на чужой модели обязан отказывать: rc=%d' % (j, r.returncode)) and ok
    if ok:
        check(True, 'repo_door_judges', '')
    return ok


def seam_text(root, rel):
    p = root / rel
    return p.read_text(encoding='utf-8') if p.is_file() else ''


# СВОЙСТВО швов (правка по вердикту Crit198V1: мутации MU-1/MU-2): источник
# ожидания/модели — ТОЛЬКО резолвер Р1. Красна ЛЮБАЯ форма собственного
# чтения реестра швом. Клетки судят КОД шва (строки-комментарии вычёркнуты:
# чтение из комментария не исполняется, документация не обязана молчать):
# имя файла реестра в коде (любое чтение обязано его назвать), jq в коде
# двери (после Р2 двери не нужен вовсе), значения реестра в коде блока --fable
# (семейства — в кавырочной форме "семейство", как значение реестра; иды —
# подстрокой; список — из реестра корня в рантайме). Формы переживают
# переименование переменных и респелл литерала "fable"[ ]*:. Флаг --fable
# (имя режима) семейству не тождествен: упоминание флага без кавычек —
# легитимно, значение реестра в кавычках — дефект.

def code_text(text):
    """Код шва без строк-комментарий (lstrip().startswith('#'))."""
    return '\n'.join(l for l in text.split('\n') if not l.lstrip().startswith('#'))


def fable_block(text):
    """Блок режима --fable: от строки-стража FABLE до парного fi (вложенность
    учитывается). None — страж не найден либо блок не закрыт."""
    lines = text.split('\n')
    start = None
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('if ') and 'FABLE' in s and s.endswith('then'):
            start = i
            break
    if start is None:
        return None
    depth = 0
    for j in range(start, len(lines)):
        s = lines[j].strip()
        if s.startswith('if '):
            depth += 1
        elif s == 'fi':
            depth -= 1
            if depth == 0:
                return '\n'.join(lines[start:j + 1])
    return None


def registry_values(root):
    """(семейства в кавырочной форме, иды) реестра корня — запрещённые
    значения для кода блока --fable."""
    p = root / 'config' / 'agent_models.json'
    if not p.is_file():
        return [], []
    try:
        reg = json.loads(p.read_text(encoding='utf-8'))
    except ValueError:
        return [], []
    models = reg.get('models') or {}
    fams = ['"%s"' % f for f in sorted(models.keys()) if f]
    ids = sorted({v for v in models.values() if isinstance(v, str) and v})
    return fams, ids


def cell_repo_seam_no_registry_read(root, tmp):
    """Код швов не называет реестр назначений: любое собственное чтение
    обязано назвать файл (дверь — целиком; лаунчер — блок --fable, прочие
    блоки легитимно зовут gen-harness --resolve-overlay)."""
    bad = []
    d = code_text(seam_text(root, 'scripts/check_sud_model.sh'))
    if 'agent_models' in d:
        bad.append('scripts/check_sud_model.sh')
    w = seam_text(root, 'workshop')
    blk = fable_block(w)
    if blk is None:
        if w:
            bad.append('блок --fable (страж FABLE не найден)')
    elif 'agent_models' in code_text(blk):
        bad.append('блок --fable')
    return check(not bad, 'repo_seam_no_registry_read',
                 'код шва %r сам называет реестр назначений — источник ожидания/модели только резолвер (Р2/Р3)' % (bad,))


def cell_repo_seam_door_no_own_parse(root, tmp):
    """Код двери не разбирает JSON сама: jq после Р2 не нужен вовсе,
    фильтры цепочки roles/tiers/models — второй резолвер в любой форме."""
    d = code_text(seam_text(root, 'scripts/check_sud_model.sh'))
    hits = []
    if 'jq' in d:
        hits.append('jq')
    for tok in ('.roles[', '.tiers[', '.models[', '"roles"', '"tiers"', '"models"'):
        if tok in d:
            hits.append(tok)
    return check(not hits, 'repo_seam_door_no_own_parse',
                 'код двери несёт собственный разбор назначений %r — второй резолвер рядом с roles.ts' % (hits,))


def cell_repo_seam_fable_no_registry_values(root, tmp):
    """Код блока --fable не несёт значений реестра: семейства в кавырочной
    форме и иды моделей (список — из реестра корня в рантайме) запрещены."""
    w = seam_text(root, 'workshop')
    blk = fable_block(w)
    if blk is None:
        return check(False, 'repo_seam_fable_no_registry_values',
                     'лаунчер отсутствует' if not w else 'блок --fable не найден (страж FABLE) — якорь шва отсутствует')
    code = code_text(blk)
    fams, ids = registry_values(root)
    hits = [v for v in fams + ids if v in code]
    return check(not hits, 'repo_seam_fable_no_registry_values',
                 'код блока --fable несёт значения реестра %r — жёсткая привязка вместо резолва роли consultant' % (hits,))


def cell_repo_seam_door_resolver(root, tmp):
    # КОД шва (комментарии вычёркнуты): упоминание резолвера в комментарии,
    # как в мутациях MU-4/MU-5 вердикта Crit198V2, вызовом не является.
    d = code_text(seam_text(root, 'scripts/check_sud_model.sh'))
    ok = 'roles.ts' in d and '--resolve-model' in d
    return check(ok, 'repo_seam_door_resolver',
                 'дверь судейской модели обязана ЗВАТЬ единый резолвер в коде (roles.ts --resolve-model), а не упоминать его в комментарии')


def cell_repo_seam_fable_resolver(root, tmp):
    w = seam_text(root, 'workshop')
    blk = fable_block(w)
    if blk is None:
        return check(False, 'repo_seam_fable_resolver',
                     'лаунчер отсутствует' if not w else 'блок --fable не найден (страж FABLE) — якорь шва отсутствует')
    # КОД блока (комментарии вычёркнуты): комментарий-упоминание резолвера
    # при вызове функции-хелпера (MU-4 вердикта Crit198V2) вызовом не является.
    code = code_text(blk)
    ok = 'roles.ts' in code and '--resolve-model' in code and 'consultant' in code
    return check(ok, 'repo_seam_fable_resolver',
                 'шов --fable обязан ЗВАТЬ резолвер роли consultant в коде блока (roles.ts --resolve-model consultant), а не упоминать его в комментарии')


# ── (а) достижимость: вынос чтения из окна функцией того же файла (MU-4) ─────

def shell_funcs(text):
    """Функции bash-файла: имя → тело. Определение `name() {` от колонки 0;
    однострочные (скобки закрыты на строке определения) — как есть,
    многострочные — до балансирующей `}`."""
    funcs = {}
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*\(\)\s*\{', lines[i])
        if m:
            name = m.group(1)
            if lines[i].count('{') <= lines[i].count('}'):
                funcs[name] = lines[i]
                i += 1
                continue
            depth = lines[i].count('{') - lines[i].count('}')
            body = [lines[i]]
            j = i + 1
            while j < len(lines) and depth > 0:
                depth += lines[j].count('{') - lines[j].count('}')
                body.append(lines[j])
                j += 1
            funcs[name] = '\n'.join(body)
            i = j
            continue
        i += 1
    return funcs


def fable_reachable_code(w_text):
    """Код блока --fable ПЛЮС транзитивное замыкание функций того же файла,
    которые блок зовёт (по вхождению имени функции границей слова в коде,
    комментарии вычеркнуты). None — блок не найден."""
    blk = fable_block(w_text)
    if blk is None:
        return None
    funcs = shell_funcs(w_text)
    code = code_text(blk)
    seen = set()
    bodies = []
    front = [n for n in sorted(funcs) if re.search(r'\b%s\b' % re.escape(n), code)]
    while front:
        n = front.pop()
        if n in seen:
            continue
        seen.add(n)
        body = code_text(funcs[n])
        bodies.append(body)
        front.extend(m for m in sorted(funcs) if m not in seen
                     and re.search(r'\b%s\b' % re.escape(m), body))
    return code + '\n' + '\n'.join(bodies)


def cell_repo_seam_fable_reachable_no_own_read(root, tmp):
    """(а) ДОСТИЖИМОСТЬ (MU-4 вердикта Crit198V2): функции того же файла,
    транзитивно зовомые из блока --fable (в т.ч. определённые ВЫШЕ стража
    FABLE), судятся теми же свойствами, что и сам блок: не называют файл
    реестра и не несут его значений. Вынос чтения из окна — правка того же
    файла в зоне implementer — клеткой не прощается; код ВНЕ достижимости
    (например die-сообщение оверлея :577) легитимно не судится."""
    name = 'repo_seam_fable_reachable_no_own_read'
    w = seam_text(root, 'workshop')
    if not w:
        return check(False, name, 'лаунчер отсутствует')
    if fable_block(w) is None:
        return check(False, name, 'блок --fable не найден (страж FABLE) — якорь шва отсутствует')
    code = fable_reachable_code(w)
    fams, ids = registry_values(root)
    hits = []
    if 'agent_models' in code:
        hits.append('имя файла реестра')
    hits += [v for v in fams + ids if v in code]
    return check(not hits, name,
                 'код, ДОСТИЖИМЫЙ из блока --fable (функции того же файла), несёт %r — собственное чтение/значения реестра вынесены из окна, источник только резолвер (Р3)'
                 % (hits[:5],))


# ── (б) поведение: мир с ОТКАЗЫВАЮЩИМ резолвером (MU-4/MU-5 вердикта Crit198V2) ──

# «Резолвер-отказник»: НЕ голая заглушка — scripts/roles.ts в песочнице
# продолжает предоставлять поверхность модуля импортёрам (gen-harness.ts и
# прочие `import … from './roles.ts'` работают: оригинал копируется под
# соседним именем и реэкспортируется), а при ПРЯМОМ запуске отвечает
# именованным отказом rc 2 и НИКОГДА не даёт модель. Голая заглушка ломала
# импортёров ДО шва — отказ по чужой причине выдавал себя за зелёное.
def install_refuser(sb):
    scripts = sb / 'scripts'
    orig = scripts / 'roles.ts'
    impl = scripts / 'roles_refuser_impl.ts'
    val_names, type_names = set(), set()
    for ts in sorted(scripts.glob('*.ts')):
        for m in re.finditer(
                r"import\s*\{([^}]*)\}\s*from\s*['\"]\./roles\.ts['\"]",
                ts.read_text(encoding='utf-8')):
            for part in m.group(1).split(','):
                is_type = part.strip().startswith('type ')
                n = part.strip().removeprefix('type ').strip()
                if n:
                    (type_names if is_type else val_names).add(n)
    type_names -= val_names
    has_impl = orig.is_file()
    if has_impl:
        shutil.copy2(orig, impl)
    lines = [
        '// ПЕСОЧНИЦА 198 (поведенческие клетки repo_seam_*_failclosed_resolver):',
        '// «резолвер-отказник» — поверхность модуля прежняя (реэкспорт',
        '// оригинала), собственного CLI нет: при прямом запуске — именованный',
        '// отказ rc 2, модель НЕ даётся никогда.',
    ]
    if val_names and has_impl:
        lines.append("export { %s } from './roles_refuser_impl.ts';" % ', '.join(sorted(val_names)))
    if type_names and has_impl:
        lines.append("export type { %s } from './roles_refuser_impl.ts';" % ', '.join(sorted(type_names)))
    lines.append("if (process.argv[1] && (process.argv[1] === 'roles.ts' || "
                 "process.argv[1].replace(/\\\\/g, '/').endsWith('/roles.ts'))) {")
    lines.append("  process.stderr.write('ROLE_REFUSED_STUB\\n');")
    lines.append('  process.exit(2);')
    lines.append('}')
    orig.write_text('\n'.join(lines) + '\n', encoding='utf-8')

# Стаб-omp: единственная команда на PATH песочницы шова --fable, фиксирует
# argv, с которым лаунчер exec-нул сессию (сам никогда не падает).
OMP_STUB_SH = """#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$OMP_STUB_LOG"
exit 0
"""


def copy_launch_chain(root, dst):
    """Выборочная копия цепочки запуска до блока --fable (песочницы
    поведенческих клеток и полных мутант-корней): scripts/, roles/, config/,
    .omp/, workshop, AGENTS.md, package.json. Секретов станционной среды
    (.env) в песочнице нет — ключи-заглушки подаются окружением клетки."""
    dst.mkdir(parents=True)
    ign = shutil.ignore_patterns('.git')
    for item in ('scripts', 'roles', 'config', '.omp'):
        if (root / item).is_dir():
            shutil.copytree(root / item, dst / item, ignore=ign)
    for f in ('workshop', 'AGENTS.md', 'package.json'):
        if (root / f).is_file():
            shutil.copy2(root / f, dst / f)


def beh_env(bin_dir, state, home, log):
    """Окружение поведенческих прогонов: PATH со стаб-omp ВПЕРЁД, сессионный
    state вне песочницы, ключи-заглушки (цепочка обязана дойти до блока, а не
    умирать на станционных секретах), журнал стаб-omp."""
    return {
        'PATH': '%s:%s' % (bin_dir, os.environ.get('PATH', '/usr/bin:/bin')),
        'HOME': str(home),
        'XDG_STATE_HOME': str(state),
        'OMP_STUB_LOG': str(log),
        'ZAI_API_KEY': 'stub',
        'METERING_PROXY_URL': 'http://stub',
        'METERING_PROXY_TOKEN': 'stub',
        'MINIMAX_API_KEY': 'stub',
    }


def omp_called(log):
    return log.is_file() and bool(log.read_text(encoding='utf-8').strip())


def cell_repo_seam_fable_failclosed_resolver(root, tmp):
    """(б) ПОВЕДЕНИЕ шова --fable: при отказывающем roles.ts путь --fable
    обязан падать ГРОМКО (rc≠0, die ДО exec omp) — модель режима идёт только
    через резолвер; сессия не стартует. Позитивный контроль: с родным
    roles.ts цепочка лаунчера обязана дойти до exec (стаб-omp в PATH
    фиксирует argv) — иначе отказ по чужой причине выглядел бы зелёным.
    Ловит ЛЮБОЙ иной источник модели, переживший отказ резолвера: функцию
    того же файла (MU-4), файл-хелпер, кэш, литерал-фолбек, молчаливый
    дефолт — независимо от места и формы чтения."""
    name = 'repo_seam_fable_failclosed_resolver'
    if not (root / 'workshop').is_file():
        return check(False, name, 'лаунчер отсутствует в дереве')
    base = Path(tmp) / 'beh-fable'
    sb = base / 'sb'
    home, state, bindir = base / 'home', base / 'state', base / 'bin'
    for d in (home, state, bindir):
        d.mkdir(parents=True)
    copy_launch_chain(root, sb)
    omp = bindir / 'omp'
    omp.write_text(OMP_STUB_SH, encoding='utf-8')
    os.chmod(omp, 0o755)
    log_ctl, log_ref = base / 'omp-ctl.log', base / 'omp-ref.log'
    ctl = run(['bash', str(sb / 'workshop'), '--fable'], home,
              env=beh_env(bindir, state, home, log_ctl), timeout=240)
    if not omp_called(log_ctl):
        return check(False, name,
                     'контроль: цепочка лаунчера не дошла до exec omp (rc=%d, stderr=%r) — поведенческий прогон невозможен'
                     % (ctl.returncode, ctl.stderr.strip()[-160:]))
    install_refuser(sb)
    ref = run(['bash', str(sb / 'workshop'), '--fable'], home,
              env=beh_env(bindir, state, home, log_ref), timeout=240)
    ok = ref.returncode != 0 and not omp_called(log_ref) and bool(ref.stderr.strip())
    return check(ok, name,
                 'при отказавшем резолвере путь --fable обязан падать громко (rc≠0, без exec omp); rc=%d, exec-omp=%s, stderr=%r — модель режима получена из иного источника'
                 % (ref.returncode, 'да' if omp_called(log_ref) else 'нет', ref.stderr.strip()[-120:]))


def cell_repo_seam_door_failclosed_resolver(root, tmp):
    """(б) ПОВЕДЕНИЕ двери: при отказывающем roles.ts дверь обязана
    fail-closed rc 2 с именованным отказом (Р2: источник назначений не
    молчит; решение по ожиданию из иного источника запрещено). Позитивный
    контроль: с родным roles.ts дверь зелёна на назначенной primary.
    Ловит чтение реестра файлом-хелпером с фолбеком (MU-5), кэшем,
    литералом-фолбеком — независимо от места и формы чтения."""
    name = 'repo_seam_door_failclosed_resolver'
    door = root / 'scripts' / 'check_sud_model.sh'
    reg_p = root / 'config' / 'agent_models.json'
    if not door.is_file():
        return check(False, name, 'дверь судейской модели отсутствует в дереве')
    if not reg_p.is_file():
        return check(False, name, 'реестр назначений отсутствует в дереве')
    reg = json.loads(reg_p.read_text(encoding='utf-8'))
    o = oracle(reg, 'critic')
    if o[0] != 0:
        return check(False, name, 'живой реестр неконформен: %r' % (o,))
    primary = o[2]
    # песочница — верная копия scripts/ ЦЕЛИКОМ: дверь может звать
    # файлы-хелперы (MU-5: registry_lookup.sh с фолбеком на резолвер), и
    # минимальная копия «дверь+roles.ts» стирала бы хелпер — дефект
    # уходил в фолбек на резолвер и выглядел честным
    sb = Path(tmp) / 'beh-door'
    shutil.copytree(root / 'scripts', sb / 'scripts',
                    ignore=shutil.ignore_patterns('.git'))
    (sb / 'config').mkdir(parents=True)
    shutil.copy2(reg_p, sb / 'config' / 'agent_models.json')
    argv = ['bash', str(sb / 'scripts' / 'check_sud_model.sh'),
            '--spawn', 'critic', primary, '--root', str(sb)]
    ctl = run(argv, tmp)
    if ctl.returncode != 0:
        return check(False, name,
                     'контроль: дверь не зелёна на назначенной primary (rc=%d, stderr=%r) — поведенческий прогон невозможен'
                     % (ctl.returncode, ctl.stderr.strip()[:120]))
    install_refuser(sb)
    ref = run(argv, tmp)
    ok = ref.returncode == 2 and bool(ref.stderr.strip())
    return check(ok, name,
                 'при отказавшем резолвере дверь обязана fail-closed rc 2 с именованным отказом; rc=%d stderr=%r — ожидание получено из иного источника'
                 % (ref.returncode, ref.stderr.strip()[:120]))


def cell_repo_pravila_live(root, tmp):
    ctx = {'tmp': tmp, 'world_checker': root}
    base = checker_world(ctx, drop_rule=True)
    r = checker_run(root / 'scripts' / 'check_project_session.sh', base, tmp)
    ok = r.returncode == 1 and 'РАСХОЖДЕНИЕ pravila' in r.stdout
    return check(ok, 'repo_pravila_live',
                 'живой сверщик обязан ловить недоставку правил: rc=%d stdout=%r — заголовок раздела правил не совпадает с каноном AGENTS.md'
                 % (r.returncode, r.stdout.strip()[:120]))


REPO_CELLS = [
    ('repo_resolver_cli', cell_repo_resolver_cli),
    ('repo_resolver_matrix', cell_repo_resolver_matrix),
    ('repo_door_judges', cell_repo_door_judges),
    ('repo_seam_no_registry_read', cell_repo_seam_no_registry_read),
    ('repo_seam_door_no_own_parse', cell_repo_seam_door_no_own_parse),
    ('repo_seam_fable_no_registry_values', cell_repo_seam_fable_no_registry_values),
    ('repo_seam_door_resolver', cell_repo_seam_door_resolver),
    ('repo_seam_fable_resolver', cell_repo_seam_fable_resolver),
    ('repo_seam_fable_reachable_no_own_read', cell_repo_seam_fable_reachable_no_own_read),
    ('repo_seam_fable_failclosed_resolver', cell_repo_seam_fable_failclosed_resolver),
    ('repo_seam_door_failclosed_resolver', cell_repo_seam_door_failclosed_resolver),
    ('repo_pravila_live', cell_repo_pravila_live),
]


# ── обманные стабы: привязка КОДОМ — стаб → клетка, на которой его дефект наблюдаем ──

def install_decoy(world, decoy, rel):
    dst = world / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(STABS / decoy, dst)
    os.chmod(dst, 0o755)


def run_cell_for_stab(name, ctx):
    """Прогон одной клетки; возвращает True если клетка КРАСНА (стаб пойман)."""
    FAILED.clear()
    saved = sys.stdout
    import io
    buf = io.StringIO()
    try:
        sys.stdout = buf
        if name in CELLS:
            CELLS[name](ctx)
        else:
            for rn, fn in REPO_CELLS:
                if rn == name:
                    fn(ctx['repo_root'], ctx['tmp'])
                    break
    finally:
        sys.stdout = saved
    return bool(FAILED)


def mutant_repo(ctx, decoy, rel, full=False, extra=()):
    """Мутант-корень для repo-клеток. full=True — копия всей цепочки запуска
    (поведенческим клеткам шова --fable нужен живой лаунчер); extra —
    компоненты двойника (ставятся вместе с ним, например файл-хелпер MU-5)."""
    root = Path(ctx['tmp']) / ('mutant-' + decoy)
    if full:
        copy_launch_chain(ctx['source'], root)
    else:
        (root / 'scripts').mkdir(parents=True)
        (root / 'config').mkdir(parents=True)
    # реестр-структуры мир в мутант-корне: шовным клеткам нужны значения
    # (семейства/иды) живого-формы реестра для запрета в блоке --fable
    write_registry(root, toy_registry(ctx['source']))
    install_decoy(root, decoy, rel)
    for rel_path, decoy_name in extra:
        install_decoy(root, decoy_name, rel_path)
    return root


# Привязка: стаб → (клетка, установщик). Каждый дефект наблюдаем ИМЕННО на этой клетке.
STAB_BIND = [
    ('decoy_hardcode_glm.ts', 'resolver_primary_swap',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_always_primary.ts', 'resolver_fallback_swap',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_silent_default.ts', 'resolver_role_unknown',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_alias_passthrough.ts', 'resolver_family_version_swap',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_autoflatten.ts', 'resolver_autofallback_toggle',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_env_sniffer.ts', 'resolver_plain_call_parity',
     lambda ctx, d: install_decoy(ctx['world_full'], d, 'scripts/roles.ts')),
    ('decoy_overlay_literal.ts', 'overlay_registry_swap',
     lambda ctx, d: install_decoy(ctx['world_gen'], d, 'scripts/gen-harness.ts')),
    ('decoy_door_hardcoded.sh', 'door_swap_green',
     lambda ctx, d: install_decoy(ctx['world_door'], d, 'scripts/check_sud_model.sh')),
    ('decoy_door_always_ok.sh', 'door_spawn_foreign_refused',
     lambda ctx, d: install_decoy(ctx['world_door'], d, 'scripts/check_sud_model.sh')),
    ('decoy_checker_always_flag.sh', 'pravila_delivered_ok',
     lambda ctx, d: install_decoy(ctx['world_checker'], d, 'scripts/check_project_session.sh')),
    ('decoy_checker_typo.sh', 'pravila_missing_detected',
     lambda ctx, d: install_decoy(ctx['world_checker'], d, 'scripts/check_project_session.sh')),
    ('decoy_workshop_fable_grep.sh', 'repo_seam_no_registry_read',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(ctx, d, 'workshop'))),
    ('decoy_workshop_fable_respell.sh', 'repo_seam_fable_no_registry_values',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(ctx, d, 'workshop'))),
    ('decoy_door_jq_resolve.sh', 'repo_seam_no_registry_read',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(ctx, d, 'scripts/check_sud_model.sh'))),
    ('decoy_door_jq_respell.sh', 'repo_seam_door_no_own_parse',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(ctx, d, 'scripts/check_sud_model.sh'))),
    ('decoy_workshop_fable_helper.sh', 'repo_seam_fable_failclosed_resolver',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(ctx, d, 'workshop', full=True))),
    ('decoy_door_helper_fallback.sh', 'repo_seam_door_failclosed_resolver',
     lambda ctx, d: ctx.__setitem__('repo_root', mutant_repo(
         ctx, d, 'scripts/check_sud_model.sh',
         extra=(('scripts/registry_lookup.sh', 'decoy_registry_lookup_helper.sh'),)))),
]


def build_ctx(tmp, source_repo):
    reg_full = toy_registry(source_repo)
    reg_door = toy_registry(source_repo, judges_only=True)
    ctx = {
        'tmp': tmp,
        'source': source_repo,
        'world_full': make_world(tmp, source_repo, 'w-full', reg_full),
        'world_door': make_world(tmp, source_repo, 'w-door', reg_door, with_door=True),
        'world_gen': make_world(tmp, source_repo, 'w-gen', reg_full, with_gen=True),
        'world_checker': make_world(tmp, source_repo, 'w-check', reg_door, with_checker=True),
        'world_broken': make_world(tmp, source_repo, 'w-broken', reg_door),
        'orig_critic_tier': reg_full['roles']['critic'],
    }
    return ctx


def restore_worlds(ctx):
    """После клеток-перестановок миры возвращаются к базовому состоянию."""
    src = ctx['source']
    for key in ('world_full', 'world_door', 'world_gen'):
        world = ctx[key]
        reg = toy_registry(src, judges_only=(key == 'world_door'))
        write_registry(world, reg)
        shutil.copy2(src / 'scripts' / 'roles.ts', world / 'scripts' / 'roles.ts')
        if key == 'world_door':
            shutil.copy2(src / 'scripts' / 'check_sud_model.sh',
                         world / 'scripts' / 'check_sud_model.sh')
        if key == 'world_gen':
            shutil.copy2(src / 'scripts' / 'gen-harness.ts',
                         world / 'scripts' / 'gen-harness.ts')
    if 'world_checker' in ctx:
        shutil.copy2(src / 'scripts' / 'check_project_session.sh',
                     ctx['world_checker'] / 'scripts' / 'check_project_session.sh')


def main():
    ap = argparse.ArgumentParser()
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--repo', metavar='ROOT')
    args = ap.parse_args()

    source = REPO_DEFAULT
    if args.repo:
        source = Path(args.repo).resolve()

    tmp = tempfile.mkdtemp(prefix='modeli198-')
    try:
        ctx = build_ctx(tmp, source)
        if args.model:
            FAILED.clear()
            for name in sorted(CELLS):
                CELLS[name](ctx)
                restore_worlds(ctx)
            print('CELLS=%d FAILURES=%d' % (len(CELLS), len(FAILED)))
            return 0 if not FAILED else 1
        if args.stabs:
            caught = 0
            total = 0
            for decoy, cell_name, installer in STAB_BIND:
                total += 1
                restore_worlds(ctx)
                installer(ctx, decoy)
                red = run_cell_for_stab(cell_name, ctx)
                if red:
                    caught += 1
                    print('STAB %s ПОЙМАН (клетка %s)' % (decoy, cell_name), flush=True)
                else:
                    print('STAB %s ПРОШЁЛ (клетка %s зелёна под обманкой — клетка не различает)'
                          % (decoy, cell_name), flush=True)
                restore_worlds(ctx)
            print('STABS=%d CAUGHT=%d' % (total, caught))
            return 0 if caught == total else 1
        # --repo
        FAILED.clear()
        for _name, fn in REPO_CELLS:
            fn(source, tmp)
        print('REPO_CELLS=%d FAILURES=%d' % (len(REPO_CELLS), len(FAILED)))
        return 0 if not FAILED else 1
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
