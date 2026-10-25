FAIL
OBJECT=d541d3ad28df8c031668b6eb53cfe21cf60d6641
СУД: repo=Complior-mob (+dev-harness); предмет=118; фаза=реализация v2 (scoped-повтор по правке B1–B5); роль=reviewer; вызов=2/2; модель-план=anthropic/claude-opus-5-5; сессия=Rev118v2c; модель-факт=anthropic/claude-opus-5-5; SHA=d541d3ad28df8c031668b6eb53cfe21cf60d6641; предыдущий=verdicts/review/contracts-118-impl-v2.md (FAIL 1/2, OBJECT 5803d57a) + .review/2026-10-25-01.md; исключение=нет; независимость: автор правки — implementer-vision (zai/glm-5.3 / vision-тир по трассе), судья — anthropic/claude-opus-5-5

# Ревью реализации 118 v2 «erstinformation», вызов 2/2 (scoped-повтор) — PR a3ka/Complior-mob#124

Находки: `.review/2026-10-25-02.md` (status: ready).

**B1–B5 вызова 1 ЗАКРЫТЫ** на кадрах этого прогона. Проверял своей мерой, все 16 пар просмотрел сам.

**Регресса нет:**
- `npm test` 12/122;
- lint и typecheck;
- checker 118 `--jest-otchet`;
- пробы 995/999/108/111/117;
- Maestro 42/42 × 2 темы.

**Проверки не переписаны:** проверки, батарея, пачка и mobile.yml не тронуты.

**FAIL** дают три НОВЫХ блокирующих класса по правилу (В): R118v2-N1, N2, N3.
- Все три уже были на `5803d57a`, и вызов 1 их пропустил. Это мой пропуск: тогда моя мера не сэмплировала фон notice, кромку карточки и горизонталь чипа документа.
- По `critic.md §Быстрый-процесс` («Обнаруженное реальное нарушение не скрывается ради scope») я их называю.
- Это второй FAIL. Дальше — арбитр (один на предмет). Ему решать, как засчитать находки, пропущенные полным вызовом.

Плюс вопрос владельцу K4: светлые макеты сняты в фазе анимации знака. Не блокирует.

Репро — в копиях `/tmp/dev-harness-verify/Rev118v2c/work/{mob,ci,r-quality,r-117,mob2,h118,mut-old}` (`cp -a`, у каждой свой `.git`).
Скрипты — файлами в `work/`:
- `quality.sh`, `checker.sh`, `krasnyj_test.sh`, `jsonsvodka.py`;
- `sbs.py`, `znak.py`, `seraja.py`, `sverka.py`, `notice_long.py`, `chipy.py`;
- `poverhnosti.py`, `palitra.py`, `dokchip.py`, `kraj.py`, `melochi.py`, `komandy.py`, `logfilter*.py`.

## 1. Область правки

```
$ git diff --stat 5803d57a..d541d3ad
 .../__tests__/erstinformation-colors.test.tsx      | 113 +++++++++++++++++++++
 .../onboarding/erstinformation-artboard.ts         |   9 ++
 .../features/onboarding/erstinformation-parts.tsx  |  77 ++++++++++----
 .../features/onboarding/erstinformation-screen.tsx |  46 ++++++---
 .../features/onboarding/erstinformation-tokens.ts  |   5 +
 5 files changed, 218 insertions(+), 32 deletions(-)
$ git log --format='%H %an <%ae>' 5803d57a..d541d3ad
d541d3ad28df8c031668b6eb53cfe21cf60d6641 implementer <implementer@dev-harness.local>
$ git diff --stat 5803d57a d541d3ad -- mobile/e2e-erstinformation .github mobile/.maestro mobile/src/bootstrap mobile/src/app mobile/src/mocks
(пусто) rc=0
```

- Все 5 файлов лежат в `mobile/src/features/onboarding/` — это ЗОНА implementer, ПЕРЕСЕЧЕНИЕ 107 UI. Коммит один, на предмет 118.
- Селекторы и testID не тронуты:
  - в диффе нет ни одной удалённой строки `testID`;
  - `Sign` сохраняет `testID="erstinfo_sign"`;
  - Maestro dark и light: 42/42 COMPLETED (`komandy.py`, commands.json артефакта). Путь: launchApp → auth-demo-entry → gate_null + notVisible start_tabs → gate_stale + notVisible start_tabs → gate_current → tap erstinfo_continue_start → start_tabs, start_tab_start/vorgaenge/schutz/post.
- Удаление `startRefusal` и `noticeTone` из экрана не регрессирует контракт:
  - `startRefusal` остаётся в `erstinformation-gate.ts:93` и по-прежнему решает `allowsStart` (:107);
  - удалена лишь окраска текста notice в muted;
  - §Предмет и §Приёмочный критерий muted-notice не требуют, макеты везде показывают ink (B4).
  - Срок и шлюз Start не задеты: 13 клеток srok и 32 клетки kompozicija — passed (§3).
- Токен `success` = `success-text` из tokens.css: dark #8fe08a, light #2f6f2a, побайтово. Он внесён в `CSS_TOKENS`, и действующий тест `erstinformation-screen.test.tsx:237` «значение каждого токена совпадает с его CSS-переменной» его сверяет.

## 2. Не переписаны ли проверки под код

- Дифф OBJECT не трогает батарею, модель, контракт, эталоны, `mobile/e2e-erstinformation/`, `.maestro`, `mobile.yml` (§1).
- Харнесс:
  - `git log 5dbcb549d..HEAD -- fixtures/workshop_project/erstinformation_118 contracts/118-erstinformation.md scripts/ekran_shablon.py scripts/sverka_maketa.py` → пусто;
  - `git diff --stat frozen/contracts/118/2 HEAD -- contracts/118-erstinformation.md` → пусто.
- `cmp proverka_proiskhozdenija.py h118:teksty/proverka_text.py` → rc 0. Пин `.harness118` = `5dbcb549d…` (mobile.yml:581, файл не менялся). Журнал CI: `HEAD is now at 5dbcb54`.
- Новый `erstinformation-colors.test.tsx` — барьер, а не подгонка. Против реализации `5803d57a` (`krasnyj_test.sh`: файлы `src/features/onboarding` откачены, тест новый) он КРАСНЫЙ:
  ```
  Tests: 13 failed, 4 passed, 17 total   old_impl_colors_test rc=1
  NE_PASSED … метка MISSING/OUTDATED (#ffa070 ожидался, #a6a69f получен), CURRENT_CONFIRMED (#a6a69f vs #d6f75a);
  notice ×5 (#f2f1ec vs #a6a69f); миниатюра ×2 (12 vs 8); точка знака F02.03 (2 vs 1); success V03; Unklar/знак V04
  ```
  Ожидаемые значения берутся из токенов по состояниям макета, а не из структуры реализации. Ограничения — в СОВЕТ С10.

## 3. Приёмка из сырого вывода (мои прогоны)

### Quality-job (`work/quality.sh`, H=b9b4c66f3, H117=8d3f48b8)

```
OBJECT=d541d3ad28df8c031668b6eb53cfe21cf60d6641
STEP rc=0 :: cmp pilot.test.tsx | cmp source.json
STEP rc=0 :: 995 probe --check-frozen (runs=1 mismatches=0) | runtime | bundle | schema | frozen_matrix | transport
STEP rc=0 :: 995 admission | stale | types | pins | admission_family (family_size=860) | stale_table (SENTRY_HANDLERS rc=0)
STEP rc=0 :: 999 nav_probe | ui_probe | shell_static_probe | copy_probe
  999 static/LITERAL_PALETTE: rc=0 зоны 002 (app/ui/navigation/tab-shell/start-screen) без hex-литералов
  999 static/TOKENS_MATCH: rc=0 names=8 dark/light совпали побайтово
static 22/22  — STEP rc=0 :: 108 start_static_probe ; honest 336/336 — STEP rc=0 :: 108 start_probe
static 16/16  — STEP rc=0 :: 111 first_run_static_probe ; honest 23/23 — STEP rc=0 :: 111 first_run_probe
static 40/40  — STEP rc=0 :: 117 vkhod_static_probe ; behavioral 26/26 — STEP rc=0 :: 117 vkhod_probe
Test Suites: 12 passed, 12 total / Tests: 122 passed, 122 total — STEP rc=0 :: npm test
structure: OK — STEP rc=0 :: npm run lint
STEP rc=0 :: npm run typecheck
```

Строка `995 frozen/drift: rc=1 FROZEN_BYTES_MISMATCH:pilot.test.tsx` — это внутренний мутант `frozen_matrix`, который ожидаемо краснеет. Итог шага — `STEP rc=0`, как и в вызове 1.

### Checker 118 (`work/checker.sh`, h118=5dbcb549d)

```
cmp_h118 rc=0
Test Suites: 12 passed / Tests: 122 passed / Test results written to: e2e-erstinformation/jest-otchet.json — npm_test_json rc=0
(своя мера jsonsvodka.py) success True suites 12/12 tests 122/122 pending 0 todo 0
  session-srok.test.tsx passed {'passed': 13}; kompozicija.probe.test.tsx {'passed': 32};
  erstinformation-colors.test.tsx {'passed': 17}; erstinformation-screen.test.tsx {'passed': 19}
RELATIVE h118 rc=0
ABSOLUTE h118 (CI form) rc=0
bootstrap_probe (npx jest src/bootstrap/__tests__) Test Suites: 6 passed, Tests: 73 passed — rc=0
```

Числа задания 12 suites / 122 tests подтверждены отчётом `--json` по файлам: 32+13+19+8+14+3+3+2+5+17+1+5 = 122.

### CI на OBJECT

```
$ gh run view 40239337315 --json headSha,event,conclusion,jobs
{"conclusion":"success","event":"pull_request","headSha":"d541d3ad28df8c031668b6eb53cfe21cf60d6641","jobs":[quality success, android-e2e success]}
$ gh api …/jobs/121308133604/logs | logfilter*.py
HEAD is now at 14496e2 Merge d541d3ad28df8c031668b6eb53cfe21cf60d6641 into c3235fbc…
HEAD is now at 5dbcb54 (.harness118)
Test Suites: 12 passed, 12 total / Tests: 122 passed, 122 total / Test results written to: e2e-erstinformation/jest-otchet.json
KADR F02.03-V01-V0 dark 0.845 … F02.08-V04 light 0.755 — 16 строк ≥ 0.600 OK; SHABLON erstinformation OK
```

Артефакт `maestro-erstinformation-14496e2c…-40239337315-1` — с этого merge-sha. Мера 123 (KADR) цвет не судит: это остаток 123 §НЕ ЗАЩИЩАЕТ, ловец — правило (В).

## 4. Мобильный экран — сверка с макетом (смотрел сам, vision есть)

### Что сверялось

- **Кадры** — пути:
  - `art/maestro-erstinformation-14496e2c…-40239337315-1/dark/2026-10-25_222928/erstinformation/takeScreenshot/erstinformation-{f02-03-v01-v0,f02-03-v02-v0,f02-03-v01,f02-03-v02,f02-08-v01,f02-08-v02,f02-08-v03,f02-08-v04}.png`;
  - то же для `light/2026-10-25_223015/…`.
- **Макеты** — `docs/ux/03_Mobility_Slice1/screens/{F02.03-V01-V0,F02.03-V02-V0,F02.03-V01,F02.03-V02,F02.08-V01..V04}[-Hell].png`.
  - `sbs.py`: sha_ok=True ×16, bytecopy_maket=False ×16, same_as_prev_run=False ×16.
- **Метод:**
  - пары «макет | кадр» — `work/sbs/*.png`, все 16 просмотрены;
  - вырезки знака «макет | новый кадр | кадр вызова 1» — `work/znak/*.png`;
  - кромка карточки — `work/kraj/*.png`.

### По кадрам

| Кадр | B1–B5 | Расхождения (класс) |
|---|---|---|
| F02.03-V01-V0 dark / light | закрыты | K1–K3; light: N2, K4 (точка отделена) |
| F02.03-V02-V0 dark / light | закрыты | K1–K3; light: N2, K4 |
| F02.03-V01 dark / light | закрыты (миниатюра есть) | N1 (фон notice), N3 (чип документа −24 pt); light: N2, K4; K1–K3 |
| F02.03-V02 dark / light | закрыты | N1, N3; light: N2, K4; K1–K3 |
| F02.08-V01 dark / light | закрыты | N1; light: N2, K4 (бусина); K1–K3 |
| F02.08-V02 dark / light | закрыты | N1; light: N1 (CTA), N2, K4 (точка полупрозрачная/малая); K1–K3 |
| F02.08-V03 dark / light | закрыты | dark: K4 (r 13.7 против 11.0); light: N2; K1–K3 |
| F02.08-V04 dark / light | закрыты | N1; dark: K4 (сплющенная «C»); light: N1 (CTA), N2, K4; K1–K3 |


### Что совпадает

Своя мера, все 16 кадров:
- фон, карточка, чип, CTA primary (`poverhnosti.py`): макет и кадр одинаковы побайтово;
- разделитель строк, шеврон, значок notice (`melochi.py`): одинаковы побайтово;
- метка, текст notice, точки чипов и знака, миниатюра — B1–B5 выше;
- состав и порядок блоков, тексты копии.

## 5. Остаток вызова 1 (С1–С9)

Дифф не трогает `pilot-app.tsx`, `onboarding-session.tsx`, `mobile.yml` и данные (§1). Поэтому С1–С9 не ухудшились, и они не блокируют.

## БЛОКИРУЕТ

Обязательство у всех трёх одно: контракт 118 §Приёмочный критерий «снимки совпадают с макетом по составу, раскладке, отступам,
шрифтам, цветам» + инв. 2 + правило (В), слово владельца 2026-10-20. Состояние достижимо: каждый из кадров Maestro production `/` на OBJECT.

| ID | Класс | Состояние / наблюдение | Закрывающее свойство |
|---|---|---|---|
| R118v2-N1 | цвет поверхности (подменён токен) | `parts.tsx:447` фон notice `extra.frame`=--line: #2c2c2a / #dcdbd5 против макета --panel #1e1e1d / #e6e5df (DS `bundle.css:90`), 10 кадров. `parts.tsx:522` вторичная CTA light --line #dcdbd5 против --secondary-surface=--panel #e6e5df, V02/V04 light | фон notice = --panel своей темы; фон вторичной CTA = --secondary-surface своей темы |
| R118v2-N2 | состав / цвет (кромка карточки) | `Card` без рамки; DS `.p-card { border: 1px solid var(--card-border) }`, light --card-border = --line. Профиль края: макет `f3 dc ff`, кадр `f3 ff`; 8 светлых кадров | на светлых кадрах кромка 1 px --card-border, на тёмных её нет |
| R118v2-N3 | раскладка (горизонталь) | `screen.tsx` чип документа `right={44}`: правый край 327 pt против 351 в макете, сдвиг 24 pt; F02.03-V01/V02 × 2 темы | правый край чипа документа совпадает с макетом с точностью чипов строк Makler (≤4 pt) |

Все три — правка в ЗОНЕ implementer `mobile/src/features/onboarding/`. После неё нужен свежий android-e2e на новом SHA.
Вызов ревьюера 2/2 исчерпан, поэтому решает арбитр по `critic.md §Быстрый-процесс §Остановка`.

## СОВЕТ / вопросы владельцу

- **K4 (к владельцу).** Светлые макеты, тёмный F02.08-V04 и тёмный V03 сняты в фазе анимации AgentPresence. В DS это `p-pres-settle` и бусина «Dynamic Faden».
  - Проявления:
    - точка F02.03 light отделена от «C» на (+9, −7) pt;
    - в V01 light видна бусина;
    - в V02 light точка полупрозрачная #b0afab r 8.4, в V04 light — #9a9994 (альфа разная);
    - в V03 dark r 13.7;
    - в V04 dark «C» сплющена.
  - Приложение рисует знак в покое. Он совпадает с тёмными макетами покоя: центр в пределах 1–4 pt, серая точка #a6a69f — точно.
  - Детерминированного закрывающего свойства у реализации нет.
  - Решать владельцу: строка контракта «знак в фазе покоя» или перевыгрузка макетов.
  - Сюда же — остатки, которые объявил implementer: непрозрачный `inkMuted` light, размер точки V02 (dark: r 14.9 против 13.8), вторая точка V01 light.
- **K1–K3** вызова 1 не изменились: шрифт Roboto вместо DM Sans (Н-406), кнопка «Demo: nächster Zustand», статус-бар.
- **С10 (новый тест).**
  - `erstinformation-colors.test.tsx` проверяет только тёмную схему — схему по умолчанию ThemeContext. Светлая схема, где лежат N2 и K4, не покрыта.
  - Утверждения `countBackground(...).toBe(12)` и `toBe(2)` считают узлы с фоном по всему дереву. В число 12 входят «3 разделителя» — это структура реализации, а не макета. Любая новая поверхность цвета `card-raised` сломает тест не по делу.
  - Надёжнее адресовать узлы по testID.
  - Красный на `5803d57a` доказан (§2). Не блок.
- **С11 (мелкие сдвиги).**
  - Знак на полных F02.03: центр точки x 217.0 против 222.5, сдвиг 5.5 pt. Было и на `5803d57a`.
  - Чипы строк Makler: правый край 329 против 325.
  - Порога в контракте нет. Если арбитр задаст для N3 допуск, разумно применить его и к ним.
- **С12 (процесс).** N1–N3 должен был поймать полный вызов 1. Свою меру я расширил: патчи поверхностей, профиль кромки, bbox чипов, площади палитры. Для мобильных экранов имеет смысл включить её в практику полного вызова.

## ПРОВОДКА (038) и паразитная сложность (050)

ПРОВОДКА не менялась (§2): guard `red_erstinformation_118.sh`, шаги CI продукта 584/601/602. Дифф их не трогает.

Пять вопросов 050 по артефактам диффа:

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | Итог |
|---|---|---|---|---|---|---|
| `DocumentSkeleton` + `FLOW.skeleton*` | §Приёмочный «состав» (B5) | нет | 2 (artboard, parts) | интерфейс 1 проп (`scale`) | кадры F02.03-V01/V02, colors-тест | ESSENTIAL |
| `SignDot` `attention`/`failed`, `DOT_SCALE` | цвет знака по состоянию (B1) | явное, проп `dot` | 1 | узкий | кадры, colors-тест | ESSENTIAL |
| поля `stateTone`/`signDot` в `FRAMES` | B1/B2: цвет по кадру макета | явное, в таблице кадров | 1 (screen) | данные, не ветви | рендер 16 кадров | ESSENTIAL — таблица вместо ветвей рендера |
| тон `warm` в `PlacedText` | B2 | нет | 1 | +1 ветвь тернарника | метка F02.03 | ESSENTIAL |
| токен `success` | B3, инв. 2 | нет | 2 (tokens + тест токенов, сверяет сам) | — | тест токенов, чипы | ESSENTIAL |
| удалены `startRefusal` в экране, `noticeTone`, проп `muted`, тон `danger` чипа | — | состояние снято | — | интерфейс сужен | — | упрощение |
| `erstinformation-colors.test.tsx` | барьер B1–B5 | нет | 1 | — | `npm test`, шаг CI 601 | ESSENTIAL; хрупкие счётчики — С10 |
