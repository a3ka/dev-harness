accept
OBJECT=33beed4ca3ac5bc77cef628ce874b2f1f5c1d277
СУД: repo=Complior-mob (+dev-harness); предмет=118; фаза=реализация v2 (вызов по перечню арбитража §5.2 после правки N1–N3); роль=reviewer; вызов=по-перечню-арбитра; модель-план=anthropic/claude-opus-5-5 (роль reviewer); сессия=Rev118v2d; модель-факт=anthropic/claude-opus-5-5; SHA=33beed4ca3ac5bc77cef628ce874b2f1f5c1d277; предыдущий=`verdicts/review/contracts-118-impl-v2b.md` (FAIL 2/2) + арбитраж `verdicts/arbitration/contracts-118-impl-arbitraz.md`; исключение=нет; независимость: авторы — zai/glm-5.3 / vision-тир и `implementer` (трасса), судья — anthropic/claude-opus-5-5 (иное семейство)
СВЕРКА-СТАНДАРТОВ: STRUCTURE.md §1 (экран/состояние домена → `src/features/<domain>/`, F02 = `onboarding/` по §3) — соответствует (дифф 20a0acb7 только в `mobile/src/features/onboarding/`); STRUCTURE.md §4 (features → theme/ui, без импорта других features) — соответствует (тест импортирует `@/theme/context`, `@/theme/tokens`); STRUCTURE.md §6 (цвета только из нативной проекции токенов DS, экран не заводит палитру) — соответствует (`erstinformation-parts.tsx`: `tokens.panel`, `tokens.card`, `extra.frame`; единственный литерал `'transparent'` = `--card-border` dark `#00000000` с комментарием на `ds/bundle.css:43`, как предписал арбитр §5.1 п.2; hex-литералов нет, 999 LITERAL_PALETTE rc 0); STRUCTURE.md §7 (Jest colocated `__tests__/`) — соответствует (`__tests__/erstinformation-colors.test.tsx`); mobile/AGENTS.md §Commands/§Rules (lint и typecheck до сдачи; `android/`/`ios/` и маршруты `src/app/` не правятся) — соответствует (lint rc 0, typecheck rc 0; `src/app` в диффе нет); AGENTS.md харнесса §Воркфлоу майлстоуна п.4 (коммит только в свою зону, автор по `user.name`) — соответствует (20a0acb7 `implementer`, зона onboarding), п.3 (frozen-текст и барьеры не ослаблены) — соответствует (`git diff frozen/contracts/118/2 HEAD -- contracts/118-erstinformation.md` пуст), п.5–7 и ПРИЁМКА-СУДЬИ (судьи по очереди; сверх 1+1 вызовов — только по слову владельца 25.10 и перечню арбитра §5.2) — соответствует.

# Ревью реализации 118 v2 «erstinformation» — вызов по перечню арбитража §5.2 (PR a3ka/Complior-mob#124)

Итог: по каждому из шести пунктов §5.2 мера своя, результат сходится. N1–N3 закрыты на кадрах нового прогона CI 40316137237. Регресса B1–B5 нет. Приёмка зелёная: проверял сырым выводом и своими прогонами в копиях. Новые клетки теста красны против `d541d3ad` и зелены на OBJECT, прежние 17 клеток не переписаны. БЛОКИРУЕТ — ничего. Новый класс по правилу (В) один (N4, был и до правки) — называю его ниже, к владельцу; merge он не блокирует (§5.2, последний абзац).

перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.
кадры против макетов просмотрены сам.

Рабочий каталог: `/tmp/dev-harness-verify/Rev118v2d/work/`.
- Скрипты файлами: `quality.sh`, `checker.sh`, `krasnyj_test.sh`, `mut_n3.sh` + `mut_apply.py`, `b_mery.sh` + `swap_art.py`, `perenos.py`.
- Перенесённые меры: `zamer.py`, `zamer_n1.py` (арбитра); `znak.py`, `seraja.py`, `sverka.py`, `chipy.py`, `notice_long.py`, `sbs.py`, `kraj.py`, `dokchip.py`, `poverhnosti.py`, `komandy.py` (вызова 2/2).
- Свои новые меры: `n2_moj.py`, `n2_dok.py`, `n1_cta.py`, `v0niz.py`, `v0kraj.py`.
- Выводы — `*.out` рядом. Копии продукта (`cp -a` клона `mob`, у каждой свой `.git`): `ci`, `r-quality`, `r-117`, `mob2`, `mut-old`, `mut-new`, `mut-a/b/c`. Клон `mob` не мутировался.

## 1. Область правки (§5.2 п.1)

```
$ git diff --stat d541d3ad..20a0acb7
 .../__tests__/erstinformation-colors.test.tsx      | 83 +++++++++++++++++++++-
 .../features/onboarding/erstinformation-parts.tsx  | 18 +++--
 .../features/onboarding/erstinformation-screen.tsx |  3 +-
 3 files changed, 97 insertions(+), 7 deletions(-)
rc=0
$ git diff --stat d541d3ad 20a0acb7 -- mobile/e2e-erstinformation .github mobile/.maestro mobile/src/bootstrap mobile/src/app mobile/src/mocks .harness118 mobile/.harness118
(пусто) rc=0
$ git diff d541d3ad 20a0acb7 | grep -c "^-.*testID"
0
$ git diff --stat 20a0acb7..33beed4c
 .github/workflows/mobile.yml | 214 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 158 insertions(+), 56 deletions(-)
rc=0
$ git log --format='%H %an' d541d3ad..33beed4c
33beed4ca3ac5bc77cef628ce874b2f1f5c1d277 implementer   (141: диагностика обрыва adb и один повтор…)
20a0acb72c64f1b42d14c60aa6c79a13aa63489b implementer   (118 v2: правка N1-N3 по арбитражу…)
```

- **20a0acb7.** Один коммит, только `mobile/src/features/onboarding/`, ссылается на предмет 118. Суть правки:
  - Notice: `backgroundColor: tokens.panel`.
  - Cta secondary: `scheme === 'dark' ? tokens.card : tokens.panel`; переменная `extra` из Cta удалена.
  - Card: `borderWidth: 1`, `borderColor: scheme === 'light' ? extra.frame : 'transparent'`.
  - StatusChip документа: `right={44}` → `right={20}`.
- **33beed4c (контракт 141).** Подтверждаю: файл ровно один — `.github/workflows/mobile.yml`, три hunk'а `@@ -316`, `@@ -496`, `@@ -619` в телах `run:`.
  - Пин `.harness118` не тронут: в диффе нет строк `ref:`/`repository:`/`uses:`; на OBJECT `ref: 5dbcb549dcd226b2bdc858a06aeb2a1be7bcbf04`, `mobile.yml:640–646`.
  - Команды приёмки 118 в hunk'е `@@ -619` по смыслу не изменены: тот же `ekran_shablon.py --pack … --harness .harness118`, тот же `cmp proverka_proiskhozdenija.py … proverka_text.py`, та же `proverka_proiskhozdenija.py … --jest-otchet`.
  - Добавлен ровно один повтор, и только по сигнатуре обрыва adb.
  - Этот коммит судит Rev141. Я его не сужу.
- **H-пин харнесса** (клон `harness` @ 14a5a0088):
  - `git log --oneline 5dbcb549d..HEAD -- fixtures/workshop_project/erstinformation_118 contracts/118-erstinformation.md scripts/ekran_shablon.py scripts/sverka_maketa.py` → пусто, rc 0;
  - `git diff --stat frozen/contracts/118/2 HEAD -- contracts/118-erstinformation.md` → пусто, rc 0;
  - guard ПРОВОДКИ `fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh` — последний коммит `64b60d2e` (architect), после пина не менялся.

## 2. N1 на кадрах (§5.2 п.2)

Кадры — артефакт `maestro-erstinformation-d8dd97ea559fbca57c93a548f69580bab413e8a0-40316137237-1`. Это merge-sha `d8dd97e Merge 33beed4ca3ac… into c3235fbc…` (журнал e2e, строка 400). Пути кадров: `art/maestro-erstinformation-d8dd97ea-40316137237-1/{dark/2026-10-26_114941,light/2026-10-26_115025}/erstinformation/takeScreenshot/erstinformation-<kadr>.png`, 1080×2400.

`python3 zamer_n1.py` — мера арбитра: полосы ТОЧНОГО цвета токена шириной ≥150 pt, мода полосы. Для каждого кадра печатаются полосы обоих цветов, `--panel` и `--line`:

| кадр (обе темы) | макет: полоса `--panel` | кадр: полоса `--panel` (мода, доля) | кадр: полоса `--line` |
|---|---|---|---|
| F02.03-V01 / V02 | y 1062–1125, #1e1e1d / #e6e5df | y 725.8–768.8, #1e1e1d 0.91/0.93 · #e6e5df 0.91/0.93 | нет |
| F02.08-V01 / V02 / V04 | y 595–658 | y 611.0–675.3, #1e1e1d 0.92/0.91/0.88 · #e6e5df 0.92/0.91/0.88 | нет |
| F02.08-V02 / V04 light, вторичная CTA | y 720–775, #e6e5df | y 739.2–796.6, #e6e5df 0.91/0.91 | нет |
| F02.03-V0 ×4, F02.08-V03 ×2 | полос нет | полос нет | нет |

Своя мера `n1_cta.py` — мода прямоугольника кнопки и notice; новый прогон против прежнего:

```
dark F02.08-V02  | maket cta=#e9e8e2 0.91 notice=#1e1e1d 0.89 | new cta=#e9e8e2 0.93 notice=#1e1e1d 0.92 | old cta=#e9e8e2 0.93 notice=#2c2c2a 0.92
dark F02.08-V04  | maket cta=#e9e8e2 0.91 notice=#1e1e1d 0.85 | new cta=#e9e8e2 0.93 notice=#1e1e1d 0.88 | old cta=#e9e8e2 0.93 notice=#2c2c2a 0.88
light F02.08-V02 | maket cta=#e6e5df 0.91 notice=#e6e5df 0.89 | new cta=#e6e5df 0.93 notice=#e6e5df 0.92 | old cta=#dcdbd5 0.93 notice=#dcdbd5 0.92
light F02.08-V04 | maket cta=#e6e5df 0.91 notice=#e6e5df 0.85 | new cta=#e6e5df 0.93 notice=#e6e5df 0.88 | old cta=#dcdbd5 0.93 notice=#dcdbd5 0.88
```

- Плашка notice на всех 10 кадрах = `--panel` своей темы.
- Вторичная CTA: на V02/V04 light #e6e5df, на V02/V04 dark #e9e8e2 — регресса нет.
- Точных `--line`-полос ≥150 pt нет ни на одном из 16 кадров.
- Патч-мера `poverhnosti.py` по всем 16 кадрам: фон, карточка, чип, `dok_karta`, notice и CTA побайтово равны макету.

## 3. N2 на кадрах (§5.2 п.3)

`python3 zamer.py n2` (мера арбитра, первая карточка) и своя мера `n2_moj.py` + `n2_dok.py`. Профиль снят в нативных px: 8 px наружу и 3 px внутрь, через левый край на середине высоты и через верхний край по центру.

- **Светлая тема, 8/8 кадров.** Главная карточка (`erstinfo_card`), LEFT и TOP: `#f3f2ee×5 #dcdbd5×2 #e9e9e5×1 #ffffff×3`. Это 2 px точного `--line` и 1 px сглаживания, всего ≈2.8 px = 1 pt, между `#f3f2ee` и `#ffffff`.
- **Карточка документа** (`erstinfo_document_card`, F02.03-V01/V02 light): LEFT на y 625 pt и TOP на x 195 pt дают тот же профиль, `line=2` на каждой стороне.
- **Макет, для сравнения:** `#f3f2ee ×5, #dcdbd5, #ffffff`.
- **Прежний прогон (`d541d3ad`), контроль:** `#f3f2ee×8 #ffffff×3`, `line=0` на всех светлых кадрах.
- **Тёмная тема, 8/8 кадров.** Пикселей `--line` (#2c2c2a) 0. Профиль: `#0a0a0a×7 #343433×1 #e9e8e2×3`.
  - `#343433` — это не кромка. Это одиночный пиксель сглаживания края заливки: смесь 19 % `#e9e8e2` на `#0a0a0a`, ни одному токену не равен.
  - Причина: край заливки сместился с 15.89 pt (`d541d3ad`) на 16.25 pt и стал ближе к макету (17 pt). Мера `n2_dok.py`: `new x0=45px=16.25pt [#0a0a0a×2 #343433×1 #e9e8e2×2]`, `old x0=44px=15.89pt [#0a0a0a×3 #e9e8e2×2]`, `maket x0=17pt`.
  - Видимой рамки на тёмных кадрах нет. На вырезках я её не вижу.
- **Вырезка** `work/kraj/F02.08-V03_light.png`, «макет | кадр»: кромка видна в обоих изображениях одинаково.

## 4. N3 на кадрах (§5.2 п.4)

`python3 zamer.py n3` — bbox полос точного `--card-raised`, в pt по шкале 390:

| кадр | чип документа x0–x1 (макет) | чип документа x0–x1 (кадр) | чипы Makler ×4 (кадр; макет 236–327) |
|---|---|---|---|
| F02.03-V01 dark | 225–353 | 232.2–**352.4** | 241.9–330.1 |
| F02.03-V02 dark | 236–353 | 239.8–**352.4** | 241.9–330.1 |
| F02.03-V01 light | 225–353 | 232.2–**352.4** | 241.9–330.1 |
| F02.03-V02 light | 236–353 | 239.8–**352.4** | 241.9–330.1 |
| контроль F02.08-V01 ×2 | 236–327 / 254–327 | 232.9–327.5 / 249.2–327.5 | — |

- Правый край чипа `erstinfo_document_status` = 352.4 ∈ [349, 357] на всех 4 кадрах. До правки было 329.3.
- Правый край чипов Makler: 330.1, |330.1 − 327| = 3.1 ≤ 4.
- Вторая мера, `dokchip.py` (перцентильный bbox ±3 по каналу): dark — `new=x234-350`, `old=x211-327`.
  - Её light-значение `x…-374` — артефакт допуска ±3: в маску попадает сглаженная кромка карточки, равная `#efeeea` с точностью 3.
  - Поэтому за меру принят точный цвет токена, `zamer.py`.

## 5. Регресс дельты (§5.2 п.5)

### Меры B1–B5 вызова 2/2 на новых кадрах (`b_mery.sh`, тот же скрипт на прежнем прогоне — для сравнения)

- **B1, знак** (`znak.py`). Числа нового прогона совпадают с прогоном `d541d3ad` до десятой:
  - F02.03 — orange@(221.1,146.5) r11.4, полный кадр — orange@(217.0,100.7);
  - F02.08-V01/V03 — lime@(221.9,147.0);
  - V02/V04 — насыщенных пятен нет.
  - Серая точка (`seraja.py`): dark V02/V04 — `#a6a69f` против макетного `#a6a69f`; light — `#5f5e58`, как и в 2/2 (K4/остаток, объявленный implementer).
- **B2, метка** (`sverka.py`). F02.03 dark `#ffa070→#f2986b`, light `#9a3c0c→#a14a1e`; F02.08 серая. Числа те же, что в 2/2.
- **B3, точки чипов** (`chipy.py`). Классы совпали с макетом на 16/16: green, а на V01/V02/V04 — green+orange; lime 0, red 0.
  - Площади пикселей выросли на 4–10 % (F02.08-V01 dark: orange 392→414, green 348→385).
  - Это сглаживание кругов после сдвига содержимого карточки на 1 pt внутрь (рамка). Классы и цвет не изменились.
- **B4, текст notice** (`notice_long.py`, нативно). F02.03-V01/V02: `#f2f1ec|#f2f1ec`, `#121211|#121211`. F02.08 (`sverka.py`): `#f2f1ec|#f0efea…#f2f1ec`, `#121211|#191918…#1b1b1a`.
- **B5, миниатюра** (`sverka.py`). 4 скелета шириной 122/221/188/88, как в макете, на 4 кадрах.
  - Прежний однострочный хвост `y637 w38` исчез: карточка ниже на 1 pt из-за рамки.
  - Макетный `y637 w56` — это верх глифа подписи, а не скелет.

Вывод по п.5: B1–B5 закрыты, как в 2/2.

### CI run 40316137237 (`gh run view` → `headSha 33beed4c…`, `conclusion success`, `quality success`, `android-e2e success`)

```
e2e.log:400  HEAD is now at d8dd97e Merge 33beed4ca3ac5bc77cef628ce874b2f1f5c1d277 into c3235fbc…
e2e.log:2247 HEAD is now at 5dbcb54 118 v2d (…) (.harness118)
e2e.log:3313 Test Suites: 12 passed, 12 total / 3314 Tests: 134 passed, 134 total / 3318 Test results written to: e2e-erstinformation/jest-otchet.json
e2e.log:3424 PRICHINA	E2E_NE_PROSHLA	rc=1   ← первый прогон 118: device offline / DeviceServerDiedException (3429–3432)
e2e.log:3474 ПОВТОР: обрыв adb-транспорта эмулятора 118 — перезапуск эмулятора и валидатора
e2e.log:3475–3490 KADR F02.03-V01-V0 dark 0.845 … F02.08-V04 light 0.755 — все OK
e2e.log:3491 SHABLON	erstinformation	OK
```

- **Своя мера по журналу:** `grep -cP 'KADR\tF02.*\tOK$'` → 16; минимум 0.724 (F02.03-V01/V02 light), максимум 0.858. Все 16 ≥ 0.600.
- **Повтор 141.** Первая попытка шага 118 упала на сигнатуре обрыва adb, и повтор 141 её перезапустил. Кадры артефакта — только из повтора: `run_priemka118` делает `rm -rf` каталога вывода, в артефакте одна сессия на тему — `114941`/`115025`, упавшая была `114855`.
  - После SHABLON шаг закончился успешно, значит `cmp` и checker 118 `--jest-otchet` прошли с rc 0: в CI они молчат, а job — success.
- **Maestro** (`komandy.py` по `commands.json` артефакта): `dark 42 {'COMPLETED': 42}`, `light 42 {'COMPLETED': 42}`. Путь: launchApp → auth-demo-entry → gate_null + notVisible start_tabs → gate_stale + notVisible start_tabs → gate_current → tap erstinfo_continue_start → start_tabs, start_tab_start/vorgaenge/schutz/post.

### Quality-job, мой прогон в копии (`work/quality.sh`, H=b9b4c66f3, H117=8d3f48b8 — те же, что в журнале quality: строки 455, 1659)

```
OBJECT=33beed4ca3ac5bc77cef628ce874b2f1f5c1d277
STEP rc=0 :: cmp pilot.test.tsx | cmp source.json
STEP rc=0 :: 995 probe --check-frozen (runs=1 mismatches=0) | runtime_probe | bundle_probe | schema_probe | frozen_matrix | transport_probe
STEP rc=0 :: 995 admission_probe | stale_probe | types_probe | pins_probe | admission_family_probe (family_size=860) | stale_table_probe
STEP rc=0 :: 999 nav_probe | ui_probe | shell_static_probe (TOKENS_MATCH, LITERAL_PALETTE rc=0) | copy_probe
static 22/22 — STEP rc=0 :: 108 start_static_probe ; honest 336/336 — STEP rc=0 :: 108 start_probe
static 16/16 — STEP rc=0 :: 111 first_run_static_probe ; honest 23/23 — STEP rc=0 :: 111 first_run_probe
static 40/40 — STEP rc=0 :: 117 vkhod_static_probe ; behavioral 26/26 — STEP rc=0 :: 117 vkhod_probe
Test Suites: 12 passed, 12 total / Tests: 134 passed, 134 total — STEP rc=0 :: npm test
structure: OK — STEP rc=0 :: npm run lint
STEP rc=0 :: npm run typecheck
$ grep -c '^STEP rc=0' quality.out → 27 ; grep -c '^STEP rc=[1-9]' → 0 ; grep -c '^STEP' → 27
```

Строка `995 frozen/drift: rc=1 FROZEN_BYTES_MISMATCH:pilot.test.tsx` — внутренний мутант `frozen_matrix`: он ожидаемо красный, итог шага `STEP rc=0`. То же было в 2/2.

### Checker 118 (`work/checker.sh`, h118=5dbcb549d — форма CI)

```
cmp_h118 rc=0
Test Suites: 12 passed, 12 total / Tests: 134 passed, 134 total — npm_test_json rc=0
(jsonsvodka.py) success True suites 12/12 tests 134/134 pending 0 todo 0
  kompozicija.probe 32; session-srok 13; erstinformation-screen 19; root-session 8; erstinformation-colors 29;
  pilot 14; auth-code-input 3; auth-focus 3; auth-keyboard 2; start-route-dopusk 5; erstinformation-demo-path 1; erstinformation-artboard 5
RELATIVE h118 rc=0
ABSOLUTE h118 (CI form) rc=0
bootstrap_probe: Test Suites: 6 passed, Tests: 73 passed — rc=0
```

Счёт своей мерой: 32+13+19+8+29+14+3+3+2+5+1+5 = 134 = 122 (как в 2/2) + 12 новых клеток colors. В colors-тесте 29 = 17 прежних + 12 новых. Тест токенов `erstinformation-screen.test.tsx` (19) зелёный.

## 6. Барьер (§5.2 п.6)

Не переписаны ли прежние клетки:

```
$ git diff --no-ext-diff d541d3ad 20a0acb7 -- …/erstinformation-colors.test.tsx | grep -E '^-[^-]|^@@'
@@ -6,13 +6,14 @@
-import { StyleSheet, type ViewStyle } from 'react-native';
@@ -111,3 +112,83 @@ describe('Erstinformation: точки по состоянию макета', ()
numstat: 82 1 …/erstinformation-colors.test.tsx
```

Удалена единственная строка — импорт (добавлен `Dimensions`). Прежние 17 клеток не тронуты, новое только дописано.

Красное и зелёное (`work/krasnyj_test.sh`): реализация `src/features/onboarding` откачена к `d541d3ad`, тест взят с OBJECT.

```
git status: M erstinformation-parts.tsx, M erstinformation-screen.tsx
Tests: 11 failed, 18 passed, 29 total   old_impl_colors_test rc=1
  NE_PASSED notice dark/light × MISSING/OUTDATED/FAILED (6): Expected #1e1e1d / #e6e5df, Received #2c2c2a / #dcdbd5
  NE_PASSED вторичная кнопка light: Expected #e6e5df, Received #dcdbd5
  NE_PASSED кромка light (borderWidth Expected 1, Received undefined); кромка dark (Expected "transparent", Received undefined)
  NE_PASSED чип документа dark/light (Expected <= 4, Received NaN)
OBJECT (копия mut-new): Tests: 29 passed, 29 total   object_colors_test rc=0
```

- Из 12 новых клеток красны 11. Зелёной на `d541d3ad` осталась «вторичная кнопка dark: --card». Так и должно быть: §5.1 п.4 арбитра требует dark = `tokens.card` «как сейчас», то есть это клетка-страж от регресса.
- У неё есть зубы — мутант c (`mut_n3.sh`): dark → `tokens.panel` даёт `Tests: 1 failed … dark: --card`, rc=1.
- Клетка N3 краснеет и от позиции, а не только от NaN. Мутант a (только `right={20}`→`{44}`): `Received: 23.52`, rc=1, красны 2 клетки чипа, остальные 27 зелёные.
- Мутант b (удалена только рамка) роняет клетки кромки и клетку чипа через NaN — см. СОВЕТ С13.

## Мобильный экран — сверка с макетом (слово владельца 2026-10-20; vision есть, все 16 пар просмотрены лично)

- **Кадры:** `/tmp/dev-harness-verify/Rev118v2d/art/maestro-erstinformation-d8dd97ea-40316137237-1/{dark/2026-10-26_114941,light/2026-10-26_115025}/erstinformation/takeScreenshot/erstinformation-{f02-03-v01-v0,f02-03-v02-v0,f02-03-v01,f02-03-v02,f02-08-v01,f02-08-v02,f02-08-v03,f02-08-v04}.png`.
- **Макеты:** `/tmp/dev-harness-verify/Rev118v2d/mob/docs/ux/03_Mobility_Slice1/screens/{F02.03-V01-V0,F02.03-V02-V0,F02.03-V01,F02.03-V02,F02.08-V01,F02.08-V02,F02.08-V03,F02.08-V04}[-Hell].png`.
- **Подлинность пар** (`sbs.py`): `sha_ok=True ×16`, `bytecopy_maket=False ×16`, `same_as_prev_run=False ×16`.
- **Пары «макет | кадр»:** `work/sbs/<id>_<tema>.png`, все 16 открыты и просмотрены. Вырезки: `work/kraj/*.png` (кромка), `work/v0niz/*.png` (низ карточки V0).

| Кадр | N1 | N2 | N3 | B1–B5 | Прочее (класс) |
|---|---|---|---|---|---|
| F02.03-V01-V0 dark / light | — (notice нет) | light: кромка есть; dark: нет | — | закрыты | K1–K3; light K4; **N4** |
| F02.03-V02-V0 dark / light | — | то же | — | закрыты | K1–K3; light K4; **N4** |
| F02.03-V01 dark / light | notice = panel | то же, обе карточки | чип 352.4 | закрыты | K1–K3; light K4 |
| F02.03-V02 dark / light | notice = panel | то же, обе карточки | чип 352.4 | закрыты | K1–K3; light K4 |
| F02.08-V01 dark / light | notice = panel | то же | — | закрыты | K1–K3; light K4 (бусина) |
| F02.08-V02 dark / light | notice = panel; CTA dark #e9e8e2, light #e6e5df | то же | — | закрыты | K1–K3; light K4 (серая точка #5f5e58) |
| F02.08-V03 dark / light | — | то же | — | закрыты | K1–K3; dark K4 (r 13.7) |
| F02.08-V04 dark / light | notice = panel; CTA как V02 | то же | — | закрыты | K1–K3; K4 |

Расхождений N1–N3 на кадрах нет. K1–K4 и С1–С12 лежат вне перечня §5.2, здесь не судятся и по виду не изменились: шрифт Roboto (Н-406), кнопка «Demo: nächster Zustand», статус-бар, фаза знака на светлых макетах. Новый класс (N4) — ниже.

## БЛОКИРУЕТ

Нет. Все шесть пунктов перечня §5.2 выполнены на OBJECT своими мерами (§1–§6 выше). `.review/2026-10-26-02.md` не создавался: по заданию он пишется только при блокерах.

## СОВЕТ / к владельцу (не блокирует merge по §5.2)

- **R118v2-N4. Новый класс по правилу (В), вне перечня. Решает владелец (арбитраж §5.2, последний абзац; §Остановка).**
  - Что видно. На F02.03-V01-V0 и F02.03-V02-V0 × обе темы (4 кадра) карточка Makler в макете обрезана окном прокрутки ПРЯМО: низ карточки на y = 710 pt одинаков при x = 20, 30 и 195. В кадре у неё скруглённые нижние углы, `v0kraj.py`:
    - dark — низ карточки 719.3 / 728.4 / 730.5 pt при x = 20 / 30 / 195;
    - light — 718.2 / 727.6 / 729.8 pt.
  - Вырезки «макет | кадр 33beed4c | кадр d541d3ad» — `work/v0niz/f02-03-v01-v0_{dark,light}.png`.
  - Так было и до правки: прежний прогон даёт те же скругления, 720.1 / 728.7 / 730.9 pt. Дельтой N1–N3 класс не внесён.
  - Не назван ни в вызове 1, ни в 2/2, ни арбитром.
  - Закрывающее свойство, если владелец сочтёт его обязательством: на кадрах V0 карточка у нижней кромки окна прокрутки обрезана прямо, без нижних скруглений, как в макете.
- **С13 (тест N3).** Клетка чипа считает `card.left + card.width − card.borderWidth − chip.right`. Без рамки результат — NaN, и клетка краснеет при верной позиции чипа (мутант b). Получается, клетка N3 связана с N2, а сообщение об ошибке вводит в заблуждение. Лучше `?? 0`. Кроме того, клетка повторяет арифметику стилей из комментария реализации (16+358−1−20), а не раскладку. Доказательство N3 — кадры (§4), тест лишь страж от регресса.
- **С14 (тёмная кромка).** Рамка `1 pt transparent` на dark сдвинула край заливки на +0.36 pt (15.89→16.25; макет 17) и дала один пиксель сглаживания `#343433`. Это к макету, а не от него. Записываю, чтобы следующий судья не принял этот пиксель за кромку.
- **Процесс (141).** Кадры этого вердикта получены вторым запуском шага 118 после обрыва adb (повтор 141). Это законный путь по канону 141, но атрибуцию кадров даю явно (§5): судить его — Rev141.

## ПРОВОДКА (038) и паразитная сложность (050)

ПРОВОДКА 118 не тронута (§1):
- guard `red_erstinformation_118.sh` и пин H `5dbcb549d` не менялись;
- в CI-шаге 118 checker `--jest-otchet` и `ekran_shablon.py` те же, обёртка повтора — предмет 141.

| Артефакт диффа 20a0acb7 | (1) свойство контракта | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель | Итог |
|---|---|---|---|---|---|---|
| Notice `backgroundColor: tokens.panel` | §Приёмочный «цвета» + инв. 2 (N1) | нет | 1 (`parts.tsx`) | замена значения, интерфейс не растёт | кадры 10 шт., клетки notice ×6 | ESSENTIAL |
| Cta secondary `dark ? card : panel`, удалён `extra` | то же (N1, `--secondary-surface`) | нет | 1 | интерфейс сужен (локальная переменная снята) | кадры V02/V04, клетки CTA ×2 | ESSENTIAL (упрощение) |
| Card `borderWidth 1` + `borderColor light ? frame : 'transparent'` | состав/цвет `.p-card` (N2) | нет; схема явная (`scheme`) | 1 (+ комментарий DS) | +2 стилевых поля, пропсов не прибавилось | 16 кадров, клетки кромки ×2 | ESSENTIAL; не 6-hex-токен — так велел арбитр §5.1 п.2 |
| StatusChip `right={20}` | раскладка (N3) | нет | 1 (`screen.tsx`) | число | кадры F02.03-V01/V02, клетки чипа ×2 | ESSENTIAL |
| `mountThemed`/`styleOf`/`SCHEMES` + 4 describe (12 клеток), одна семья | барьер N1–N3 (§5.1 п.4: по testID, обе схемы) | нет | 1 | помощники узкие, без счётчиков по дереву (учтено С10) | `npm test`, CI-шаг npm test 118 | ESSENTIAL; огрубление арифметики — С13 |
