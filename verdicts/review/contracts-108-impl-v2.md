accept
OBJECT=307b3962fa3072ea55f89b5cf3f3e8d91a0471df

# Вердикт reviewer Rev108r2: реализация C контракта 108 (CMP-MOB-004 Start), круг 2

Находки в reslop-формате лежат в `review.md` этого каталога (`status: ready`).

## Предмет и база

- **C** = `307b396`, 12 коммитов implementer поверх **B** = `76ac10f`.
- **H** = `9bb5beb30`; `ref:` в mobile.yml = H, контракт `frozen/contracts/108/1` = `596413745`.
- **Копии:** C — `mob` (пробы), `mob2` (матрица), `mob3` (свежий `npm ci`), `mob4` (раскладка CI: `.harness` = H), `mob5` = 7a87004 (красное), `mob6` (свидетели), `mob7` (in-zone форма).
- `/home/harness/dev-harness` не модифицировался, push не делался.

## Почему accept

Блокеров с названным обходом нет. Подробности — в `review.md`.

- **R108-1 закрыт.** Черновик переживает возврат на настоящем route.
  - Клетки H `ROUTE_DRAFT_RETURN_*` (4) зелёные на C и красные на 7a87004.
  - Мои свидетели W2 (путь Maestro: talk/write, вкладки и profile) и W4 (http-отказ) зелёные на C и красные на 7a87004.
- **R108-2 закрыт.** Системный reduceMotion доходит до StartScreen.
  - `ROUTE_MOTION_SYSTEM_reduced` зелёная на C и красная на 7a87004.
  - Свидетель W1 проверяет живое событие `reduceMotionChanged`: true→reduced, false→full.
- **R108-3 — совет, не блок** (форк `n108-impl-krug1`).
  - Файлы круга 1 по-прежнему копия модели: три с токен-сходством 1.000, два — 1.000 без комментариев.
  - Новая работа круга 2 НЕ скопирована (`[section].tsx` 0.35, composer 0.65, draft-context модели не перенесён). Поэтому route-клетки на C — независимое свидетельство.
- **Область: 17 путей, 2 вне ЗОНЫ.**
  - `pilot.test.tsx` санкционирован (А2, консультант 23:25) и побайтно равен эталону H 995.
  - `bootstrap/use-system-reduce-motion.ts` не санкционирован. Это перенос хука, откат измерен бесплатным.
  - Это оговорка консультанту по прецеденту `contracts-107-impl-v3.md`. Обходом предмета не является, поэтому по ПРИЁМКЕ-СУДЬИ v2 — совет R2-1. Роль, п.1, требует отказа при превышении зоны. Решаю в пользу явного правила этого круга и прецедента 107; разрешение конфликта называю здесь открыто.

## Сырые прогоны (мои, своей мерой)

Раннер `run.sh` пишет `RC=` в конец лога.

```
# пробы 108, H=/tmp/dev-harness-verify/Rev108r2/H (git archive 9bb5beb30)
start_static_probe.py --repo mob            RC=0  "static 22/22"            out_static.txt
start_probe.py --repo mob                   RC=0  "honest 331/331"          out_behav.txt
start_static_probe.py --repo mob --matrix   RC=0  "mutants 5, defects 0"    out_static_matrix.txt
start_probe.py --repo mob2 --matrix         RC=0  "mutants 41, defects 0"   out_behav_matrix.txt   (90 s)
start_probe.py --repo mob5 (=7a87004)       RC=1  RED: ROUTE_DRAFT_RETURN_{PROFILE,TAB_post,TAB_schutz,TAB_vorgaenge}, ROUTE_MOTION_SYSTEM_reduced

# своя мера счётных утверждений — другой командой по логам
grep '^case ' out_behav.txt | sort -u | wc -l     -> 331   (из них ^case ROUTE_ -> 7)
grep -c '^case ' out_static.txt                    -> 22
grep -c ': named RED ok' out_behav_matrix.txt     -> 41
grep -c ': named RED ok' out_static_matrix.txt    -> 5

# npm в свежей копии mob3/mobile
npm ci --no-audit --no-fund   RC=0
npm run lint                  RC=0  "structure: OK", eslint --max-warnings=0
npm run typecheck             RC=0
npm test                      RC=0  "Test Suites: 1 passed / Tests: 14 passed"

# frozen 995/999, раскладка CI (mob4/.harness = H), run_frozen.sh, логи frozen_logs/
cmp pilot.test.tsx / source.json с H         rc=0 / rc=0   (sha256 pilot.test.tsx dee6de0b…)
pilot_995/probe.py --check-frozen            rc=0  "995 runs=1 mismatches=0"
pilot_995/runtime_probe.py                   rc=0
pilot_995/bundle_probe.py                    rc=0  "elapsed=18.1s"
pilot_995/schema_probe.py                    rc=0
pilot_995/frozen_matrix.py                   rc=0  "995 frozen checked=3"
pilot_995/transport_probe.py                 rc=0
pilot_995/admission_probe.py                 rc=0
pilot_995/stale_probe.py                     rc=0
pilot_995/types_probe.py                     rc=0
pilot_995/pins_probe.py                      rc=0
pilot_995/admission_family_probe.py          rc=0  "family_size=860"
pilot_995/stale_table_probe.py               rc=0
nav_999/nav_probe.py                         rc=0
nav_999/ui_probe.py                          rc=0
nav_999/shell_static_probe.py                rc=0
nav_999/copy_probe.py                        rc=0
git status (mob, mob2, mob4) после проб      0 / 0 / 0 строк

# свидетели на настоящем route (tabs)/[section] — witness.test.tsx, EXPO_PUBLIC_API_MODE=mock
C (mob6):     4 passed, jest rc=0
  W1 initial full=true faden=true | after-true reduced=true faden=false | after-false full=true faden=true
  W2 typed draft=true frame02=true | talk frame03=true | write frame02=true draft=true | post/profile: composer mounted=false
     | back from profile: section-post=true | return start: draft=true brief=MIS-CAR-01 reduced=true
  W3 briefBefore=false briefAfter=MIS-W3-77 draft=true
  W4 presence=true brief=false draft=true
7a87004 (mob5): 3 failed / 1 passed, jest rc=1
  W1 ✕;  W2 ✕ "return start: draft=false … reduced=false";  W3 ✓ (контроль);  W4 ✕ "draft=false"

# область: zone.py (строка «ЗОНА implementer:» frozen-блоба дословно, diff 76ac10f..307b396)
paths 17 out 2:  OUT mobile/src/bootstrap/__tests__/pilot.test.tsx,  OUT mobile/src/bootstrap/use-system-reduce-motion.ts
git log по путям: 7a87004, f353667 (pilot.test.tsx), 2feb51a (hook) — все implementer

# откат хука в зону (inzone.py, mob7: экспорт из tab-shell.tsx, файл удалён)
start_static 22/22 rc0; start_probe 331/331 rc0; nav_probe rc0; shell_static rc0; ui_probe rc0; typecheck rc0; lint rc0; test 14/14 rc0

# неизменность frozen-артефактов (git -C /home/harness/dev-harness diff --stat)
frozen/108/1..H -- контракт, start.test.tsx, source.json, start_static_probe.py   -> пусто
frozen/999/1..H -- fixtures/workshop_project/nav_999                              -> пусто
frozen/108/1..H -- pilot_995                                                      -> только pilot.test.tsx +18 (перепин architect 8a83eb637)
frozen/108/1..H -- start_108: +model/app.tabs.section.tsx, +model/draft-context, +start-route.test.tsx, start_probe.py/probe_lib.py
                   (architect 8b113da05: +7 клеток, +2 мутанта, depends только расширены — усиление, не ослабление)

# сходство с моделью H (sim.py; токены / токены без комментариев)
agent-presence 1.000/1.000; ui-copy 1.000/1.000; start-mock 1.000/1.000; api-client 0.888/1.000; runtime 0.842/1.000;
start-screen 0.959/0.978; conversation-composer 0.648/0.853; [section].tsx 0.346/0.506; draft-context.ts в продукте: нет
```

## Пункты роли

1. **Область правки.** 17 путей, 2 вне зоны (R2-1); санкция есть у одного. Это оговорка консультанту, не обход.
2. **Сырой вывод.** Выше, логи лежат в каталоге. Пересказа автора не использовал.
3. **Проверки не переписаны.**
   - Implementer харнесс не трогал.
   - Из тестов продукта в диффе: удаление legacy 991 (контракт его требует) и `pilot.test.tsx` — только добавленные заглушки, побайтно равен H.
   - Пост-заморозочная правка start_108 сделана architect'ом в его зоне и только усиливает пробы.
4. **Красное предъявлено.**
   - Новые барьеры круга (route-клетки H) на 7a87004 красные: 5 клеток, мой прогон.
   - Мои свидетели красные на 7a87004 и зелёные на C.
   - Матрица 41 + 5, defects 0.
5. **Атомарность.** 12 коммитов `108`. Круг 2 сведён в один `2feb51a` (4 находки, одна задача) — совет R2-5.
6. **Норма не тронута.** Нормативных правок нет, контракт ≡ frozen.
7. **Заявленное равно сделанному.**
   - 22/331/41/5 подтверждены своей мерой.
   - Комментарий шага 108 в mobile.yml («324/324», «c9f680b4d…», «H-pin 108 — задача architect'а») не равен сделанному — совет R2-4.
   - Коммит `307b396` верно заявляет репин и причину.

## NOT_RUN

- Maestro `cmp-mob-004-start.yaml` и android-e2e: эмулятора на станции нет, PR #112 android-e2e падает на инфраструктуре раннера (решение владельца утром). Путь флоу повторён свидетелем W2 в RNTL на настоящем route. Это не device evidence.
- `gh pr checks` не исполнял: по заданию quality PASS известен, android-e2e не исследуется.

## Чистка

Копии `mob2`–`mob7` удалены после прогонов. В каталоге остались `mob` (C), `H`, логи, `witness.test.tsx`, `sim.py`, `zone.py`, `inzone.py`, `run.sh`, `run_frozen.sh`.
