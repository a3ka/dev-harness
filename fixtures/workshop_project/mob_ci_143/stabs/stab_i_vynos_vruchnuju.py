#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): шаг quality возвращён к v1-форме —
# персональные mv двух пачек по именам, без вызова --mode inventar.
# Следующая пачка (147–154) выносится только ручной правкой этого шага
# (или не выносится — живой отказ Complior-mob#144 «file outside allowed
# location»). Дефект наблюдаем на входе i05: вынос обязан идти от
# инвентаризации по карте (НЕТ_ИНВЕНТАРИЗАЦИИ / ВЫНОС_ВРУЧНУЮ).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = """          node mobile/scripts/select-ci-screens.cjs --mode inventar --repo . \\
            --out /tmp/dev-harness-verify/impl-inventar-${{ github.run_id }}-${{ github.run_attempt }}.json \\
            > /tmp/dev-harness-verify/impl-inventar-${{ github.run_id }}-${{ github.run_attempt }}.out
          while IFS= read -r stroka; do
            case "$stroka" in
              PACHKA\\ *)
                pachka="${stroka#PACHKA }"
                test -n "$pachka"
                test -d "$pachka"
                mv "$pachka" "/tmp/dev-harness-verify/impl-pack-$(basename "${pachka%/}")-${{ github.run_id }}-${{ github.run_attempt }}"
                ;;
            esac
          done < /tmp/dev-harness-verify/impl-inventar-${{ github.run_id }}-${{ github.run_attempt }}.out
"""
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: блок инвентаризации/выноса встречен %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
novyj = """          mv mobile/e2e-first-run /tmp/dev-harness-verify/impl135-pack-${{ github.run_id }}-${{ github.run_attempt }}
          mv mobile/e2e-erstinformation /tmp/dev-harness-verify/impl118-pack-${{ github.run_id }}-${{ github.run_attempt }}
"""
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
