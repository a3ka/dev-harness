#!/usr/bin/env python3
"""Б-10: честная модель и адресные дельты только задачи (в), не продукт."""
from pathlib import Path
import sys

source, destination, variant = sys.argv[1:]
text = Path(source).read_text()
marker = '# ── ЗАДАЧА (в): ПАРИТЕТ CI'
if text.count(marker) != 1:
    raise SystemExit('NOT_IMPLEMENTED: не найден единственный seam задачи (в)')
prefix = text.split(marker)[0]
body = r'''# ── ЗАДАЧА (в): ПАРИТЕТ CI — модель Б-10
[ -f "$SELF_DIR/verify_ci_parity.sh" ] || skip "scripts/verify_ci_parity.sh не существует"
ci_out=""; ci_rc=0
ci_out="$(bash "$SELF_DIR/verify_ci_parity.sh" "$ROOT" 2>&1)" || ci_rc=$?
if [ "$ci_rc" -eq 1 ]; then
  printf 'ПРЕДУПРЕЖДЕНИЕ: паритет CI красен (verify_ci_parity.sh rc 1): %s\n' "${ci_out%%$'\n'*}" >&2
elif [ "$ci_rc" -ne 0 ]; then
  skip "паритет CI недоступен (verify_ci_parity.sh rc $ci_rc): ${ci_out%%$'\n'*}"
fi
printf 'OK\n'
'''
warning = '''  printf 'ПРЕДУПРЕЖДЕНИЕ: паритет CI красен (verify_ci_parity.sh rc 1): %s\\n' "${ci_out%%$'\\n'*}" >&2'''
if variant == 'S1':
    body = body.replace(warning, '  die "паритет CI красен (verify_ci_parity.sh rc 1)"')
elif variant == 'S2':
    body = body.replace('if [ "$ci_rc" -eq 1 ]; then', '''if [ "$ci_rc" -eq 1 ] && [ -f "$ROOT/.harness/registry/ci_parity_debt.txt" ]; then
  IFS= read -r deadline < "$ROOT/.harness/registry/ci_parity_debt.txt"
  deadline="${deadline#ДО: }"
  [[ "$(date -u +%F)" > "$deadline" ]] && die "долг паритета просрочен"
fi
if [ "$ci_rc" -eq 1 ]; then''')
elif variant == 'S3':
    body = body.replace('if [ "$ci_rc" -eq 1 ]; then', '''if [ -f "$ROOT/.harness/registry/ci_parity_debt.txt" ]; then ci_rc=0; fi
if [ "$ci_rc" -eq 1 ]; then''')
elif variant == 'S4':
    body = body.replace(warning, '  : # молча')
elif variant == 'S5':
    body = body.replace('if [ "$ci_rc" -eq 1 ]; then', 'if [ "$ci_rc" -le 1 ]; then')
elif variant == 'S6':
    body = body.replace('[ -f "$SELF_DIR/verify_ci_parity.sh" ] || skip "scripts/verify_ci_parity.sh не существует"', '''if [ ! -f "$SELF_DIR/verify_ci_parity.sh" ]; then
  printf 'ПРЕДУПРЕЖДЕНИЕ: паритет CI недоступен\\n' >&2
  printf 'OK\\n'; exit 0
fi''')
elif variant == 'S7':
    # Плохой short-circuit на красном паритете до зоны: наблюдаем именно в ж.
    prefix = prefix.replace('# ── ПАРСИНГ ЗОНА/', '''if [ -f "$SELF_DIR/verify_ci_parity.sh" ]; then
  _b10_rc=0
  bash "$SELF_DIR/verify_ci_parity.sh" "$ROOT" >/dev/null 2>&1 || _b10_rc=$?
  if [ "$_b10_rc" -eq 1 ]; then printf 'OK\\n'; exit 0; fi
fi
# ── ПАРСИНГ ЗОНА/''')
elif variant != 'model':
    raise SystemExit(f'NOT_IMPLEMENTED: неизвестная модель {variant}')
Path(destination).write_text(prefix + body)
Path(destination).chmod(0o755)
