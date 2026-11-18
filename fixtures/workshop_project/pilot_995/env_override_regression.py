#!/usr/bin/env python3
"""995 (CMP-MOB-001 pilot): регресс ПРЕДУСЛОВИЯ пробы HTTP_UNAVAILABLE.

Дефект (запрос моба 165/995, консультант ConsProbe995 вариант (а) п.1):
runtime_probe.py строил окружение Jest-процесса из os.environ и для
HTTP_UNAVAILABLE не задавал EXPO_PUBLIC_API_URL — случайный родительский
URL (или его отсутствие) решал экран: 165 v2 при http-режиме без URL законно
показывает auth-unconfigured (Ф3, инв. 6) и до fetch не доходит, сетевая
клетка auth-unavailable краснела не по вине продукта. Ремонт — присваивание
SYNTHETIC_API_URL в runtime_probe.py; эта проба держит ремонт.

Проверяется предусловие пробы, не продукт. НАБЛЮДЕНИЕ env живёт ВНУТРИ
отдельного процесса: в одноразовую копию батареи в runtime.test.tsx
вставляется (байтовым якорем, встечается ровно 1 раз, иначе rc 2) строка
expect на process.env, а запускателем служит сам немодифицированный (для
контроля) либо замутированный (для стабов) runtime_probe.run — машина
окружения ровно та, что в CI. Ожидания (mode, SYNTHETIC_API_URL) читаются
из самого модуля пробы — единый источник; собственная копия значений
запрещена. Правило 8: байты батареи снимаются до запуска субъекта.

Режимы:
  (без флага)   контроль: два входа родительского окружения — no-url
                (EXPO_PUBLIC_API_URL отсутствует) и foreign-url
                (посторонний валидный https URL) — на обоих отдельный
                процесс видит РОВНО SYNTHETIC_API_URL и actual проходит
                сетевую клетку auth-unavailable: rc 0;
  --stabs       контроль + матрица обманных мутаций УТРАТЫ override
                (Н-39: каждая мутация привязана к входам, где её утрата
                НАБЛЮДАЕМА):
                  no-override → оба входа (наблюдение env; на no-url
                      красна и сетевая клетка: без URL продукт показывает
                      auth-unconfigured);
                  setdefault   → только foreign-url (заполняет лишь
                      отсутствующий: на no-url мутант честно зелён и
                      красноты там не требуется);
  --mutation M  одна мутация (контроль + её входы);
  --mutation unapplied — положительный контроль машинерии применения:
                якорь отсутствует по построению, применение обязано
                отказать rc 2 ORACLE_TAMPERED, а не «пойман» (ложный
                зелёный контроля запрещён).

Коды возврата: 0 — зелено (контроль зелёный, стабы красны на своих
входах); 1 — контроль красный либо стаб прошёл (STAB_ZHIV); 2 —
ORACLE_TAMPERED: нечем проверять (дрейф байтов батареи, якорь мутации
или наблюдения не единственен, SYNTHETIC_API_URL не определён в пробе,
продукт вне одноразовой зоны).
"""
import argparse
import importlib.util
import os
from pathlib import Path
import shutil
import sys
import tempfile

HERE = Path(__file__).resolve().parent
BATTERY_FILES = ('runtime_probe.py', 'runtime.test.tsx', 'source.json', 'model.tsx', 'runtime-model.ts')
PARENT_INPUTS = ('no-url', 'foreign-url')
FOREIGN_PARENT_URL = 'https://foreign-parent.example.com'
SCRATCH_ROOT = Path('/tmp/dev-harness-verify')
OBSERVATION_ANCHOR = "it('HTTP_UNAVAILABLE', async () => {"


def fail_closed(message):
    raise RuntimeError(message)


def replace_once(text, anchor, replacement, name):
    """Н-39/применённость: якорь встречается ровно 1 раз, иначе отказ проверки."""
    count = text.count(anchor)
    if count != 1:
        fail_closed('якорь %s не единственен (вхождений %d): %r' % (name, count, anchor[:70]))
    return text.replace(anchor, replacement)


# ── обманные мутации утраты override (применяются к КОПИИ runtime_probe.py) ──

def mutation_no_override(text):
    anchor = "                if case == 'HTTP_UNAVAILABLE': env['EXPO_PUBLIC_API_URL'] = SYNTHETIC_API_URL\n"
    return replace_once(text, anchor, '', 'no-override')


def mutation_setdefault(text):
    anchor = "env['EXPO_PUBLIC_API_URL'] = SYNTHETIC_API_URL"
    return replace_once(text, anchor, "env.setdefault('EXPO_PUBLIC_API_URL', SYNTHETIC_API_URL)", 'setdefault')


MUTATIONS = {'no-override': mutation_no_override, 'setdefault': mutation_setdefault}
# Положительный контроль применения: якоря нет по построению.
UNAPPLIED_ANCHOR = "env['EXPO_PUBLIC_API_URL'] = SYNTHETIC_API_URL_UNAPPLIED_995"
STAB_INPUTS = {'no-override': ('no-url', 'foreign-url'), 'setdefault': ('foreign-url',)}


def prepare(mutation=None):
    """Одноразовая копия батареи; мутация применяется с доказанной применимостью."""
    root = Path(tempfile.mkdtemp(prefix='env995-', dir=SCRATCH_ROOT))
    for name in BATTERY_FILES:
        shutil.copyfile(HERE / name, root / name)
    if mutation == 'unapplied':
        text = (root / 'runtime_probe.py').read_text()
        replace_once(text, UNAPPLIED_ANCHOR, '?', 'unapplied')  # обязан отказать
    elif mutation:
        text = (root / 'runtime_probe.py').read_text()
        (root / 'runtime_probe.py').write_text(MUTATIONS[mutation](text))
    return root


def load_probe(root):
    spec = importlib.util.spec_from_file_location('runtime_probe_995_env', root / 'runtime_probe.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def install_observation(root, mode, url):
    """Наблюдение env ВНУТРИ отдельного процесса: expect на process.env."""
    lines = "expect(process.env.EXPO_PUBLIC_API_MODE).toBe('%s');\n    " % mode
    lines += "expect(process.env.EXPO_PUBLIC_API_URL).toBe('%s');" % url
    text = (root / 'runtime.test.tsx').read_text()
    text = replace_once(text, OBSERVATION_ANCHOR, OBSERVATION_ANCHOR + '\n    ' + lines, 'nabljudenie')
    (root / 'runtime.test.tsx').write_text(text)


def excerpt(failures):
    keep = ('Expected:', 'Received:', 'Unable to find', 'expect(')
    picked = [line.strip() for line in failures.splitlines() if any(k in line for k in keep)]
    return ' | '.join(picked[:6])[:600]


def drive(repo, parent_input, mutation):
    """Один вход родительского окружения через реальную машину пробы."""
    root = prepare(mutation)
    try:
        probe = load_probe(root)
        if not hasattr(probe, 'SYNTHETIC_API_URL'):
            fail_closed('SYNTHETIC_API_URL не определён в runtime_probe.py — ремонт отсутствует')
        install_observation(root, probe.CASES['HTTP_UNAVAILABLE'], probe.SYNTHETIC_API_URL)
        saved = os.environ.get('EXPO_PUBLIC_API_URL')
        try:
            if parent_input == 'no-url': os.environ.pop('EXPO_PUBLIC_API_URL', None)
            else: os.environ['EXPO_PUBLIC_API_URL'] = FOREIGN_PARENT_URL
            rc, failures = probe.run(repo, ['HTTP_UNAVAILABLE'], None)
        finally:
            if saved is None: os.environ.pop('EXPO_PUBLIC_API_URL', None)
            else: os.environ['EXPO_PUBLIC_API_URL'] = saved
        return rc, failures
    finally:
        shutil.rmtree(root, ignore_errors=True)


def control(repo):
    red = 0
    for parent_input in PARENT_INPUTS:
        rc, failures = drive(repo, parent_input, None)
        note = 'parent=EXPO_PUBLIC_API_URL:%s' % ('absent' if parent_input == 'no-url' else FOREIGN_PARENT_URL)
        print('995 env-regress/control %s: rc=%d (nabljudenie vnutri processa + setevaja kletka)' % (note, rc))
        if rc: 
            print('995 env-regress/control %s KRASNO: %s' % (note, excerpt(failures)), file=sys.stderr)
            red = 1
    return red


def stabs(repo, names):
    caught = living = 0
    for name in names:
        for parent_input in STAB_INPUTS[name]:
            rc, failures = drive(repo, parent_input, name)
            if rc == 1:
                caught += 1
                print('995 env-regress STAB %s parent=%s KRASEN (%s)' % (name, parent_input, excerpt(failures)))
            else:
                living += 1
                print('995 env-regress STAB %s parent=%s ZHIV rc=%d' % (name, parent_input, rc), file=sys.stderr)
    print('995 env-regress SVJAZI %d zhivykh %d' % (caught, living))
    return 0 if living == 0 else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--stabs', action='store_true')
    parser.add_argument('--mutation', choices=sorted(MUTATIONS) + ['unapplied'])
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not repo.is_relative_to(SCRATCH_ROOT):
        fail_closed('DISPOSABLE_REQUIRED: продукт обязан быть одноразовым клоном под %s' % SCRATCH_ROOT)
    # Применённость к ФАКТИЧЕСКИМ байтам батареи — до любого запуска.
    shipped = (HERE / 'runtime_probe.py').read_text()
    for name, mutate in sorted(MUTATIONS.items()):
        mutate(shipped)
    replace_once((HERE / 'runtime.test.tsx').read_text(), OBSERVATION_ANCHOR, OBSERVATION_ANCHOR, 'nabljudenie')
    if args.mutation == 'unapplied':
        prepare('unapplied')  # обязан отказать (rc 2), не «поймать»
        fail_closed('unapplied применился — машинерия сломана')
    if control(repo): return 1
    if args.mutation: return stabs(repo, [args.mutation])
    if args.stabs: return stabs(repo, sorted(MUTATIONS))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, AttributeError) as error:
        print('995 env ORACLE_TAMPERED:', error, file=sys.stderr)
        sys.exit(2)
