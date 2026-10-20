accept
OBJECT=9779ea104ee6c39bd56f6499fd43019ea0aa9d97

Adv107r4 — атака на 107 (CMP-MOB-003) после микро-круга; ось ТОЛЬКО обход
из `verdicts/adversary/contracts-107-impl-v3.md` (настоящий entry не достигал
W1A, `getDisclosureGate` не вызывался). Судимые: ветка
`cmp-mob-003/erstinformatsiya` @ 9779ea1 (локальный клон Impl107c/mob, не
запушен); H = origin/main c1619efa (107-пробы), frozen H = 58bcdb6a9 (995/999).

Итог по оси: обхода в ПРЕДМЕТЕ нет. Свой свидетель круга 3 (настоящий entry ×
литеральный CURRENT_CONFIRMED runtime, порт admission — настоящий
`mocks/runtime.ts`, тест W1A не подаёт) зелёный: evidence показан, порядок
`session-start → session-resolved → admission=W1A → gate`, gate ровно 1 раз.
Пока сессия не прочитана — порт и gate холодны; отказ getSession держит W0;
http-runtime — gate 0, порт W0; StrictMode/rerender/Continue — без второго
вызова. Session (api-5_8.ts:41-49) поля допуска не несёт — подтверждено.

Найдены ДЕФЕКТЫ ПРОВЕРКИ внутри оси (не предмета; правка за architect) —
четыре обманных дерева проходят 22/22 и 283/283; ловит только мой свидетель.
Главное: `mocks/runtime.ts admission → 'W0'` — ровно v3-симптом на
composition root (настоящий entry × настоящий runtime: gate 0 вызовов,
W1A недостижим) — пробы зелёные. Плюс отдельная находка ВНЕ оси: в
поставляемой синтетической композиции evidence не появляется из-за
995-фикстуры getDisclosure (`document_ref: "example"`). Подробно — review.md.

## Сырые команды / rc

```text
# подготовка
git clone /tmp/dev-harness-verify/Impl107c/mob mob && git -C mob checkout 9779ea104ee6c39bd56f6499fd43019ea0aa9d97   rc=0
git clone ssh://git@github.com/a3ka/dev-harness.git h && git -C h checkout c1619efa6b9cceb2dcc35014568f23e39d7d9935  rc=0
cmp Impl107c/mob/mobile/package-lock.json mob/mobile/package-lock.json   rc=0 (node_modules: cp -al)

# cwd=mob/mobile
npm run lint        rc=0
npm run typecheck   rc=0
npm test            rc=0   Test Suites: 4 passed; Tests: 19 passed

# cwd=h/fixtures/workshop_project/erstinfo_107, R = disposable клон OBJECT
python3 erstinfo_static_probe.py --repo R            rc=0   static 22/22
python3 erstinfo_probe.py --repo R                   rc=0   honest 283/283
python3 erstinfo_probe.py --repo R --matrix          rc=0   mutants 25, defects 0
python3 erstinfo_static_probe.py --repo R --matrix   rc=0   mutants 4, defects 0

# frozen-эталон
sha256 h:58bcdb6a9:fixtures/workshop_project/pilot_995/pilot.test.tsx  = b06b6f9d…915b
sha256 h:c1619efa:fixtures/workshop_project/pilot_995/pilot.test.tsx   = b06b6f9d…915b
sha256 OBJECT:mobile/src/bootstrap/__tests__/pilot.test.tsx             = b06b6f9d…915b   (байт-равны)

# frozen 995/999: R2 = клон OBJECT + .harness = git archive 58bcdb6a9 (frozen.sh, шаги mobile.yml)
pilot_995/probe.py --check-frozen     rc=0   995 runs=1 mismatches=0
pilot_995/runtime_probe.py            rc=0
pilot_995/bundle_probe.py             rc=0
pilot_995/schema_probe.py             rc=0   checked=2 runtime=matched
pilot_995/frozen_matrix.py            rc=0   frozen checked=3
pilot_995/transport_probe.py          rc=0
pilot_995/admission_probe.py          rc=0
pilot_995/stale_probe.py              rc=0
pilot_995/types_probe.py              rc=0   checked=2 schema=matched
pilot_995/pins_probe.py               rc=0
pilot_995/admission_family_probe.py   rc=0   family_size=860 static=0 dynamic=0
pilot_995/stale_table_probe.py        rc=0
nav_999/nav_probe.py                  rc=0
nav_999/ui_probe.py                   rc=0
nav_999/shell_static_probe.py         rc=0
nav_999/copy_probe.py                 rc=0

# свидетели Adv107r4 (witness/*.test.tsx; node node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath)
adv107r4-literal.test.tsx                               rc=0   5/5
  ADV_LITERAL_CONFIRMED_EVIDENCE      ✓  (evidence + continue, gate 1, port 1, порядок session→admission→gate)
  ADV_LITERAL_SESSION_PENDING         ✓  (до session: gate 0, port 0, disclosure.checking)
  ADV_LITERAL_RERENDER_NO_DOUBLE      ✓
  ADV_LITERAL_STRICT_MODE             ✓  (gate 1)
  ADV_LITERAL_CONTINUE_NO_REFETCH     ✓
EXPO_PUBLIC_API_MODE=http adv107r4-http.test.tsx        rc=0   3/3
  ADV_HTTP_IS_HTTP / ADV_HTTP_GATE_COLD / ADV_HTTP_SESSION_OK_PORT_W0 (+300 ms реального ожидания)  ✓
adv107r4-real.test.tsx (настоящий mocks/runtime.ts, без jest.mock)   rc=1   4/5
  ADV_REAL_GATE_REACHED               ✓  (порядок session→admission=W1A→gate, gate 1)
  ADV_SESSION_PENDING_COLD            ✓
  ADV_SESSION_REJECT_W0               ✓
  ADV_UNMOUNT_BEFORE_SESSION          ✓
  ADV_REAL_RUNTIME_EVIDENCE           ✕  OBSERVED document_ref=example evidence=false outdated=true   (находка ВНЕ оси, review.md Н-5)

# обманные деревья (decoys.py; ставятся поверх OBJECT в R, затем git checkout)
дерево                     static   behavioral     свидетель Adv107r4
OBJECT                     0 22/22  0 283/283      literal 0, http 0, real 1 (только ADV_REAL_RUNTIME_EVIDENCE)
early-port                 0 22/22  0 283/283      real 1, literal 1, http 1        ← проба пробита (Н-2)
const-w1a                  0        1 ROUTE_INIT_W0_WAITING                          поймано
const-w1a-late (50 мс)     0        1 ROUTE_INIT_W1A_CHECKING_{EQ,STALE}             поймано (W0-клетка НЕ ловит)
reject-ignored             0 22/22  0 283/283      real 1, http 1                   ← проба пробита (Н-4, латентно)
double-gate                0        1 ROUTE_INIT_* / ROUTE_RECHECK_*                 поймано
mock-port-w0               0 22/22  0 283/283      real 1, literal 1                ← проба пробита (Н-1, v3-класс)
http-port-w1a              0 22/22  0 283/283      http 1                           ← проба пробита (Н-3, латентно)
ctl-disclosure-canonical   0 22/22  0 283/283      real 0, literal 0, http 0        позитивный контроль причины Н-5
R status after restore: только неотслеживаемые файлы свидетелей
```

Disposable R/R2 удалены после прогона. Свидетели и раннеры:
`/tmp/dev-harness-verify/Adv107r4/{witness/,decoys.py,frozen.sh}`.
Вердикт также закоммичен под `adversary` в мой клон харнеса
`/tmp/dev-harness-verify/Adv107r4/h`, ветка `adv/107-impl-v4`, файл
`verdicts/adversary/contracts-107-impl-v4.md` (push/запись в
/home/harness/dev-harness запрещены непиннованной сессией).
