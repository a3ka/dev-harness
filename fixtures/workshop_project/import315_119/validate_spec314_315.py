#!/usr/bin/env python3
# Контракт 119 v2 — toy-двойник МИГРИРОВАННОГО tests/spec-3.14/validate_contract_v3_9.py
# (R-1: lane package run_backend_ci.py красен на смешанном дереве). Миграция по
# ASTRA-REPORT §6.2 шаг 6: СМЕШАННЫЕ ПРОФИЛИ — core-операции наследуют профиль
# ядра (info.version 5.8.4, маркер не ставится), extension-операции несут маркер
# профиля расширения (info.version источника extension, 5.9.0). Грамматика в
# одном источнике: значение маркера = version заголовка extension-источника,
# сам маркер ставит единый генератор gen_derived_315.py при слиянии.
# Алфавит профилей ЗАМКНУТ: core-операция БЕЗ маркера, extension-операция ТОЛЬКО
# с ['<ext_version>'] — любые иные/неопределённые значения отказ.
# Известные отказы НЕ механизм зелёного: реестр подавлений не читается, пустота
# failure_ids=[] — инвариант ФАЙЛА, судимый оракулом (known-failures-nepust).
# rc 0 — PASS_STATIC failures=[]; rc 1 — FAIL_STATIC failures=[…].
# Evidence — как у боевого (validate_contract_v3_9.py:700): свежий каталог,
# без --out — в КОРЕНЬ судимого дерева (evidence/contracts/<ts>/), с --out DIR
# — в DIR; оракул обязан уводить его в свой scratch (Rev119v2 Б-2).
import argparse, json, sys, time
from pathlib import Path

R = Path(__file__).resolve().parents[2]
PUB = R / 'docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml'
EXT = R / 'docs/sources/backend-3.15/platform-extension.yaml'
EXPECTED_CORE_VERSION = '5.8.4'  # R-4: версия ядра не меняется до 120/M1


def header_version(text):
    for ln in text.split('\n'):
        if ln.startswith('paths:'):
            break
        if ln.startswith('  version: '):
            return ln[len('  version: '):].strip()
    return None


def op_markers(text):
    ops, cur = {}, None
    for ln in text.split('\n'):
        s = ln.strip()
        if s.startswith('operationId:'):
            cur = s.split(':', 1)[1].strip()
            ops.setdefault(cur, None)
        elif s.startswith('x-supported-contract-versions:') and cur:
            ops[cur] = s.split(':', 1)[1].strip()
    return ops


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', type=Path)
    args = ap.parse_args()
    pub_text = PUB.read_text()
    ext_text = EXT.read_text()
    failures = []
    if header_version(pub_text) != EXPECTED_CORE_VERSION:
        failures.append('current_exact_version')
    ext_v = header_version(ext_text)
    ext_ops = set(op_markers(ext_text))
    for op, marker in op_markers(pub_text).items():
        if op in ext_ops:
            # extension-операция: профиль расширения, значение — из заголовка
            # источника (единая грамматика), алфавит замкнут этим значением
            if marker != "['%s']" % ext_v:
                failures.append('%s_profile' % op)
        elif marker is not None:
            # core-операция обязана жить на профиле ядра — без маркера
            # расширения: перевод core-операции на иной профиль = ослабление
            failures.append('%s_profile' % op)
    print('%s failures=[%s]' % ('PASS_STATIC' if not failures else 'FAIL_STATIC',
                                ', '.join(failures)))
    out = args.out or R / 'evidence' / 'contracts' / time.strftime('%Y%m%dT%H%M%SZ', time.gmtime())
    out.mkdir(parents=True, exist_ok=True)
    (out / 'contract-validation.json').write_text(json.dumps(
        {'status': 'PASS_STATIC' if not failures else 'FAIL_STATIC', 'failures': failures}) + '\n')
    sys.exit(0 if not failures else 1)


main()
