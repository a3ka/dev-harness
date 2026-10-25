FAIL
OBJECT=5803d57ac2e08f3b17cf2949f59a9bde6fa8aff1
СУД: repo=Complior-mob (+dev-harness); предмет=118; фаза=реализация v2; роль=reviewer; вызов=1/2; модель-план=anthropic/claude-opus-5-5; сессия=Rev118v2; модель-факт=anthropic/claude-opus-5-5; SHA=5803d57ac2e08f3b17cf2949f59a9bde6fa8aff1; предыдущий=verdicts/adversary/contracts-118-impl-v3.md (accept); исключение=нет; независимость: авторы реализации — zai/glm-5.3, судья — anthropic/claude-opus-5-5

# Ревью реализации 118 v2 «erstinformation» — PR a3ka/Complior-mob#124

Находки: `.review/2026-10-25-01.md` (status: ready). В .review — 5 блокирующих (R118v2-B1…B5, все по правилу (В))
и 3 вопроса владельцу (K1–K3). Отдельно ниже — 9 советов (С1–С9). Код, срок, шлюз, данные, CI и приёмку
v2 я перепроверил своей мерой: всё зелёное, красные прогоны предъявлены (§3). FAIL дают только кадры: сверка с
макетом по правилу (В) — слово владельца 2026-10-20, роль reviewer, ловец остатка 123 §НЕ ЗАЩИЩАЕТ п.113.

Репро — в копиях `/tmp/dev-harness-verify/Rev118v2/work/{mob,mob2,ci,h118,harness}` (`cp -a`, собственный `.git`).
Скрипты — файлами в `work/`: quality.sh, checker.sh, mutacii.py, dannye.py, otchet.py, sbs.py, cveta.py, chipy.py,
komandy.py, schet.py.

## 1. Область правки

```
$ git diff --numstat a28065655..5803d57a
41  5   .github/workflows/mobile.yml
305 40  mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py
9   1   mobile/e2e-erstinformation/kontrakt.md
64  11  mobile/src/app/onboarding-session.tsx
37  10  mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh
264 0   mobile/src/bootstrap/__tests__/session-srok.test.tsx
1   1   mobile/src/bootstrap/__tests__/source.json
34  9   mobile/src/bootstrap/pilot-app.tsx
1   1   mobile/src/mocks/pilot-responses.json
```

Все 9 файлов лежат в ЗОНЕ implementer 118 (контракт §Зоны) и в ПЕРЕСЕЧЕНИЯХ 117/995. Файлов вне зоны нет.
Все три коммита сделаны от `implementer <implementer@dev-harness.local>`.

### Данные — своя мера (`work/dannye.py`, rc 0)

```
etalon_pilot_responses.json -> mobile/src/mocks/pilot-responses.json  old_in_etalon=1 new_in_nositel=1 eq_etalon_subst=True
etalon_995.json -> mobile/src/bootstrap/__tests__/source.json          old_in_etalon=1 new_in_nositel=1 eq_etalon_subst=True
etalon_995.json -> harness fixtures/workshop_project/pilot_995/source.json old_in_etalon=1 new_in_nositel=1 eq_etalon_subst=True
```

- Эталоны — байт-копии носителей базы: `git show a28065655:<носитель> | cmp - <эталон>` → rc 0 (m=0, s=0).
- Ленд 995 в харнессе: коммит `871d04eb` от architect «995 (данные демо-фикстуры)… слово владельца 25.10».
  Он входит в H: `merge-base --is-ancestor 871d04eb b9b4c66f3` → 0.

### Пины

- H (`.harness`, quality и android-e2e): `c663dd0f → b9b4c66f3`. Перепин сделан в `0ea83903`; его требует
  ПРЕДПОСЫЛКА контракта «перепин H… на ревизию с этими данными».
- `git diff --stat c663dd0f b9b4c66f3 -- pilot_995 nav_999 start_108 first_run_111 scripts/ekran_shablon.py scripts/sverka_maketa.py`
  → только `pilot_995/source.json | 2 +-`.
- `.harness118`: `d417996f → 5dbcb549d` (`5803d57a`). Пины `.harness117` (8d3f48b8), `.harness123` (5d98a1cd) и
  `.harness135` (ca277b3a) не тронуты.

## 2. Соответствие §Предмет / инв. 4–6

- **Допуск W1A.** Getter `admission` в `onboarding-session.tsx:169-175` вычисляется при каждом обращении:
  `payload ∧ identity=='' ∧ srokDejstvitelen(payload)`. Строгое `srok <= Date.now() → false` стоит в :96.
  Хранится payload, не решение. Литерала допуска в pilot-app нет: `git grep "'W1A'"` в pilot-app находит
  только сравнения и типы.
- **Шлюз continue в момент действия.** pilot-app:276 (`handleDemoEntry`) и :467 (inline `onContinue`) читают
  `onboarding?.admission` при нажатии. Рендер-проекция `onboardingAdmission` осталась только для пропа
  `admission` экрана.
- **SENTRY_HANDLERS.** Перечень `const handle*` в base и в OBJECT одинаков, 10 имён.
  `995 stale-table SENTRY_HANDLERS: rc=0`.
- **/start.** `(tabs)/[section].tsx:101` читает порт той же сессии, TabShell при W0 не монтируется.
  Клетки srok-istekla-start, srok-rerender-start и др. — passed.
- **Maestro CI (commands.json артефакта, `work/komandy.py`).** dark и light: 42/42 COMPLETED. Путь:
  `launchApp` → auth-demo-entry → gate_null + notVisible start_tabs → gate_stale + notVisible start_tabs →
  gate_current → tap erstinfo_continue_start → visible start_tabs, start_tab_start/vorgaenge/schutz/post.
  `openLink` нет.
- **Запрещённые формы (`git grep` @ 5803d57a).**
  - `openLink|startApp|launchApp` в `.maestro/erstinformation.yaml` → только `launchApp` (production `/`).
  - `.skip(|.only(|.todo(|xit(` в session-srok.test.tsx → пусто.
  - Голый `testID="start_tabs"` → только TabShell в `start-destination.tsx:66`.
  - Чтение файлов пачки из src → пусто.
  - Даты в src: только разрешённый литерал в mocks/source.json, пин-форма теста и kompozicija (обе —
    байт-копии харнесса).
- **mobile.yml, android-e2e.**
  - Шаг 601 `npm test -- --json --outputFile=e2e-erstinformation/jest-otchet.json` стоит перед шагом 602
    (cmp + checker `--jest-otchet …`) в том же job.
  - Шаг 584 проверяет тег `frozen/contracts/117/3`; в харнессе тег есть.

## 3. Приёмка из сырого вывода (мои прогоны)

### Jest

```
$ cd work/mob/mobile && npm test -- --json --outputFile=/tmp/dev-harness-verify/Rev118v2/work/jest-otchet.json
Test Suites: 11 passed, 11 total
Tests:       105 passed, 105 total
rc=0
```

Своя мера отчёта (`work/otchet.py`):

```
success True suites 11/11 tests 105/105 pending 0 todo 0
FILE …/session-srok.test.tsx status passed {'passed': 13} n 13 uniq 13
```

13 клеток, и каждая встречается ровно один раз:
srok-istekla-koren, srok-istekla-start, srok-rovno-sejchas, srok-nerazborchivaja, srok-mezhdu-mount-dejstviem,
srok-mezhdu-render-continue, srok-rerender-start, srok-pustaja, srok-otsutstvuet-pole, srok-nestrokovaja,
srok-offset-zona, srok-ranishe-auth-time, srok-svezhaja-demo.

### Quality-job (`work/quality.sh`)

Репро шагов `quality` из mobile.yml: H=b9b4c66f3, H117=8d3f48b8. Пробы гоняются на disposable-копии; перед
lint H, батарея 117 и пачки выносятся, как в CI.

```
STEP rc=0 :: cmp pilot.test.tsx | cmp source.json
STEP rc=0 :: 995 probe --check-frozen (runs=1 mismatches=0) | runtime | bundle | schema | frozen_matrix | transport
STEP rc=0 :: 995 admission | stale | types | pins | admission_family (family_size=860) | stale_table (SENTRY_HANDLERS rc=0)
STEP rc=0 :: 999 nav | ui | shell_static | copy
static 22/22 / honest 336/336   — 108 start_static / start_probe rc=0
static 16/16 / honest 23/23     — 111 first_run_static / first_run_probe rc=0
static 40/40 / behavioral 26/26 — 117 vkhod_static / vkhod_probe rc=0
STEP rc=0 :: npm test (11/11, 105/105) | npm run lint | npm run typecheck
```

Без выноса lint на чистой копии даёт rc=1 (`file outside allowed location/type`). Это ожидаемо: CI выносит эти
файлы шагом 240.

### Checker 118 (`work/checker.sh`, копия mob2)

```
cmp_h118 rc=0                         (байт-копия = teksty/proverka_text.py @ 5dbcb549d; sha256 cb4d90412e12…3ee у обоих и у git show 5dbcb549d:…)
npm_test_json rc=0                    (Test results written to: e2e-erstinformation/jest-otchet.json)
RELATIVE harness_main rc=0            (--pack mobile/e2e-erstinformation --repo . --harness /tmp/…/Rev118v2/harness)
RELATIVE h118 rc=0                    (--harness = клон @ 5dbcb549d)
ABSOLUTE h118 rc=0                    (--pack "$PWD/mobile/e2e-erstinformation" --repo "$PWD", форма CI)
ABSOLUTE h118 outside-report rc=0     (--jest-otchet абсолютный путь вне репо)
bootstrap_probe rc=0                  (npx jest src/bootstrap/__tests__: 6 suites, 73 tests)
```

Без флага `--jest-otchet` checker берёт путь по умолчанию: тот же `e2e-erstinformation/jest-otchet.json`
от repo/mobile.

### Батарея харнесса

```
$ bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --model   → rc_model=0
  78 строк CASE … ok (77 входов + guard-shag); 16 KADR 1.000 0.600 G OK
$ … --stabs → rc_stabs=0; 73 строки «STAB … KRASEN», SVJAZI 73
```

Своя мера (`work/schet.py` по source.json @ 5dbcb549d): kejsy 77; файлов stubs 53 = 52 стаба + `_model.py`
(хелпер, не привязан); stab_vhod 52 записи / 73 связи. Числа автора 77/52/73 подтверждены.

### Красные прогоны — свои мутанты реализации (`work/mutacii.py`, каждый в свежей копии)

```
continue-snimok-rendera (onContinue читает рендер-снимок)  jest rc=1 failed=['srok-mezhdu-render-continue']; checker rc=1 SROK_OTCHET_NE_USPEH + SROK_KLETKA_NE_ISPOLNENA srok-mezhdu-render-continue:'failed'
demo-snimok-rendera (handleDemoEntry — снимок)             jest rc=1 failed=['srok-mezhdu-mount-dejstviem']; checker rc=1
srok-nestrogij (<= → <)                                     jest rc=1 failed=['srok-rovno-sejchas','srok-rerender-start']; checker rc=1
srok-snjat (без srokDejstvitelen)                            jest rc=1 failed=9; checker rc=1 ×9 SROK_KLETKA_NE_ISPOLNENA
mocks-staraja-data (pilot-responses → 2026-10-14)            jest rc=1 failed=4 (демо-проход/root-session/start-route на реальной демо-сессии); checker rc=1
otchet-net (нет отчёта)                                      checker rc=1 SROK_OTCHET_NET e2e-erstinformation/jest-otchet.json
```

### CI на OBJECT (gh)

`gh run view 40233699476`: headSha=5803d57a, event=pull_request, conclusion=success.

Attempt 1: android-e2e failure на шаге «123 сверка» — `KADR Splash dark 0.000 … tagline NIZHE_POROGA`.
В кадре нативный splash без композита (просмотрен). Шаги 118 в этой попытке не исполнялись.

Attempt 2: success. Лог job 121293669208 показывает:
- `.harness118` HEAD = 5dbcb54;
- `Test Suites: 11 passed`, `Tests: 105 passed`, `Test results written to: e2e-erstinformation/jest-otchet.json`;
- шаг 602: 16 строк KADR 0.714–0.858 ≥ 0.600, `SHABLON erstinformation OK`, без PRICHINA.

## 4. Не переписаны ли проверки под код

- Реализация не трогает батарею, модель, контракт и эталоны харнесса. Диф OBJECT харнесс не затрагивает.
- Контракт не менялся: `git diff frozen/contracts/118/2 HEAD -- contracts/118-erstinformation.md` пуст.
- Три файла продукта — байт-копии носителей харнесса @ 5dbcb549d (cmp rc 0):
  - `proverka_proiskhozdenija.py` = `teksty/proverka_text.py`;
  - `session-srok.test.tsx` = `teksty/session-srok.stand-in.tsx` (sha256 489e11fb…);
  - `kompozicija.stand-in.sh` = `teksty/kompozicija_forma`.
- Батарея после freeze менялась: `frozen/contracts/118/2..5dbcb549d`, 4 файла fixtures — probe.py, source.json,
  stubs/s-bez-kanonizacii-puti.py, teksty/proverka_text.py. Это коммит architect (зона architect),
  а не implementer.
- Код пачку не читает. Хардкода даты нет (§2).

## 5. Мобильный экран — сверка с макетом (смотрел сам, vision есть)

### Что сверялось

- **Кадры:** артефакт android-e2e рана 40233699476 attempt 2 на OBJECT — `/tmp/dev-harness-verify/Rev118v2/art/maestro-erstinformation-c1e5dcf67d16a525e0cf33507c62e552e59f56c2-40233699476-2/`.
  c1e5dcf6 — merge-sha `Merge 5803d57a into 8f338d88`, из лога checkout.
- **Пути:**
  `{dark/2026-10-25_212737,light/2026-10-25_212819}/erstinformation/takeScreenshot/erstinformation-{f02-03-v01-v0,f02-03-v02-v0,f02-03-v01,f02-03-v02,f02-08-v01,f02-08-v02,f02-08-v03,f02-08-v04}.png`.
- **Макеты:** `docs/ux/03_Mobility_Slice1/screens/F02.03-V01-V0[-Hell].png, F02.03-V02-V0[-Hell].png, F02.03-V01[-Hell].png, F02.03-V02[-Hell].png, F02.08-V0{1..4}[-Hell].png`.
  sha256 = `maket_sha256` манифеста у всех 16; ни один кадр не равен байтам макета.
- **Метод:** пары «макет | кадр» в `work/sbs/*.png`, все 16 просмотрены.

### По кадрам

Цвет — моя мера (§5 .review). B1…B5 — блокеры, K1…K3 — вопросы владельцу.

| Кадр | KADR (CI) | Расхождения |
|---|---|---|
| F02.03-V01-V0 dark / light | 0.843 / 0.821 | B1 точка знака оранж→лайм; B2 метка оранж→серая; B3 чипы зелёный→лайм; K1–K3 |
| F02.03-V02-V0 dark / light | 0.843 / 0.821 | B1, B2, B3; K1–K3 |
| F02.03-V01 dark / light | 0.800 / 0.716 | B1, B2, B3, B4 notice ink→muted, B5 нет миниатюры документа; K1–K3 |
| F02.03-V02 dark / light | 0.800 / 0.714 | B1, B2, B3, B4, B5; K1–K3 |
| F02.08-V01 dark / light | 0.830 / 0.755 | B3, B4; light: на макете знак с двумя точками, на кадре одна (B1); K1–K3 |
| F02.08-V02 dark / light | 0.747 / 0.755 | B1 точка серая→лайм; B3; B4; K1–K3 |
| F02.08-V03 dark / light | 0.858 / 0.755 | B2 «Bereit.» серая→лайм; B3; K1–K3 |
| F02.08-V04 dark / light | 0.817 / 0.755 | B1 серая→лайм; B3 «Unklar» оранж→красный, ok зелёный→лайм; B4; K1–K3 |

### Что совпадает

- Состав и порядок блоков: wordmark, знак, метка, заголовок, описание, карточка со строками и чипами, notice,
  CTA, ссылка.
- Раскладка по вертикальным долям. Долгие F02.03 — в координатах 390×844, как велит инв. 3.
- Тексты копии.
- Цвета ground, card и CTA в обеих темах.
- Кадр Start по PNG не сверяется: макета нет (контракт §Незаполненные). Состав вкладок доказан assertVisible (§2).

## 6. Остатки

- **Подлинность и свежесть jest-отчёта.**
  - Формулировка §НЕ ЗАЩИЩАЕТ достаточна.
  - В CI подмену ловит порядок: шаг 601 `npm test --json --outputFile` в том же job прямо перед шагом 602.
    Шаг идёт под `bash -e`, поэтому упавший jest останавливает job до checker'а. Отчёт перезаписывается при
    каждом прогоне; в git он не трекается (`git ls-files | grep -c jest-otchet` → 0).
  - Подложить отчёт можно только правкой mobile.yml: снять шаг или переставить шаги. Это видно в диффе, и
    батарея ловит такую правку текстом (`CI_BEZ_OTCHETA_SROKA`, вход ci-bez-otcheta-sroka, стаб s58).
  - Журнал CI attempt 2 печатает сводку 11/105.
- **Флейк attempt 1 — не Н-407.**
  - Сигнатура другая: 123-сверка кадра 117 `Splash dark 0.000`; снят нативный splash до оверлея.
    Н-407 — это `E2E_NE_PROSHLA` шага 135.
  - pilot-app в диффе v2 splash не трогает: правки только в :170-184, :270-291, :340-356, :463-477 (заголовки ханков `git diff a28065655..5803d57a`).
  - Предмет не 118. Повтор attempt 2 зелёный.

## БЛОКИРУЕТ

Обязательство у всех пяти одно: контракт 118 §Приёмочный критерий «снимки совпадают с макетом по составу,
раскладке, отступам, шрифтам, цветам» + правило (В), слово владельца 2026-10-20.

| ID | Класс | Состояние / наблюдение | Закрывающее свойство |
|---|---|---|---|
| R118v2-B1 | визуальный (В) — цвет состояния | точка знака всегда лайм: `<Sign>` без `dot`, `erstinformation-screen.tsx:454`; 8 кадров F02.03 (макет оранж), 4 кадра F02.08-V02/V04 (макет серая) | точка знака каждого кадра цвета макета, или строка владельца в контракте |
| R118v2-B2 | визуальный (В) — цвет метки | `tone={marker==='current'?'accent':'muted'}` (:464); F02.03 ×8 оранж→серая, F02.08-V03 ×2 серая→лайм | метка цвета макета |
| R118v2-B3 | визуальный (В) — цвет чипа | `tone==='ok'?tokens.accent` (parts:251); ok-чип зелёный→лайм на 16/16; «Unklar» V04 ×2 оранж→красный | точки чипов цвета макета |
| R118v2-B4 | визуальный (В) — цвет текста | notice `muted` (screen:588, parts:452); 10 кадров: макет ink, кадр inkMuted | текст notice цвета макета |
| R118v2-B5 | визуальный (В) — состав | миниатюра документа (4 строки-скелета) отсутствует на F02.03-V01/V02 ×2 темы; в коде её нет | миниатюра по макету |

Правка не выходит за ЗОНУ implementer: `mobile/src/features/onboarding/`. Это ровно шаг dovodka-ui (слово
владельца 2026-10-21 «экраны быстрее», модель с vision). После правки нужен свежий android-e2e на новом SHA и
повторная сверка 16 кадров (scoped-повтор, вызов 2/2).

## СОВЕТ

- **С1 (050, pilot-app `startNaznachen`).** Без этого состояния форма `startScreen={<StartDestination />}` с тем
  же inline-шлюзом проходит jest 105/105 и checker rc 0 (мутант start-bez-naznachenija). Состояние кажется
  ACCIDENTAL. Не блок: Maestro на этой форме я не гонял, третьей части 050 нет.
- **С2 (050, `srokDejstvitelen`).** Ветки «зона обязательна» (regex :92) и «срок не раньше auth_time» (:99)
  не требуются инв. 6. После удаления каждой jest остаётся 105/105, checker — rc 0 (мутанты bez-zony,
  bez-auth-time): красного у веток нет.
  - Пин-клетка `srok-ranishe-auth-time` берёт `2020-01-01` — эта дата и так в прошлом, ветку auth_time клетка не
    изолирует (дефект формы харнесса — architect).
  - Либо убрать ветки, либо architect добавляет клетки.
- **С3 (атомарность).** `0ea83903` несёт срок, судью jest, данные трёх носителей и перепин H: 9 файлов. Одна
  тема «118 v2 по решению арбитра» — терпимо. Отдельный коммит данных читался бы легче.
- **С4 (mobile.yml:656-658).** Комментарий «относительный --repo развалился бы в rc 127» после канонизации
  5dbcb549d устарел: относительная форма теперь rc 0 (§3).
- **С5 (frozen-текст против батареи).** Контракт 118/2 в приёмке называет «71 + guard-shag» и «SVJAZI 69».
  Батарея на пине 5dbcb549d даёт 77 + guard и SVJAZI 73: класс puti-* добавлен после freeze коммитом architect.
  Контракт не правлен. Расхождение текста с гардом — оркестратору/architect, v+1 или примечание.
- **С6 (§НЕ ЗАЩИЩАЕТ «смысл expires_at»).** Контракт называет ловцом клетку `srok-svezhaja-demo` «на реальной
  демо-сессии». Клетка подменяет `getSession` датой от часов. Реальную пин-дату ловят 4 других теста —
  проверено мутантом mocks-staraja-data. Формулировку стоит поправить в v+1.
- **С7 (K1–K3).** Вопросы владельцу: шрифт DM Sans (Н-406, носитель), демо-кнопка `erstinfo_next_variant` в кадре
  (её требует frozen flow), статус-бар.
- **С8 (флейк).** Сигнатура attempt 1 (нативный splash в кадре 117) — кандидат в запись станции рядом с Н-407.
- **С9 (среда).** Мой node — v26.5.1 при `.node-version` 24.21.0. Все зелёные прогоны v2 в CI сделаны на
  пиннованной версии.

## ПРОВОДКА (038) и паразитная сложность (050)

ПРОВОДКА:
- guard `fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh` — барьер именно этого
  предмета;
- в CI харнесса он подключён: `registry/ci-steps.tsv:179` `check:erstinformation-118-family-selftest … --stabs`,
  ключ в `.github/workflows/ci.yml:282`;
- в CI продукта подключены шаги 584 (тег 117/3), 601 (jest --json), 602 (шаблон 132 + cmp + checker
  `--jest-otchet`).

Пять вопросов 050 по артефактам диффа:

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | Итог |
|---|---|---|---|---|---|---|
| onboarding-session `srokDejstvitelen` + getter | инв. 6 | явное: payload в state, часы при чтении | 1 | узкий интерфейс (`admission`), работа скрыта | 13 клеток srok | ESSENTIAL; ветки зона/auth_time — С2 |
| pilot-app inline-шлюз continue + `startNaznachen` | инв. 6, третий факт | `startNaznachen` — лишнее состояние | 1 | — | srok-mezhdu-render-continue | шлюз ESSENTIAL; `startNaznachen` — С1 |
| session-srok.test.tsx | инв. 6 (пин-форма) | нет | 2 (харнесс-носитель + копия), пин sha | — | checker SROK_TESTY_FORMA | ESSENTIAL (байт-копия) |
| proverka_proiskhozdenija.py (копия) | инв. 5/6, А-2 | флаг `--jest-otchet` (явный аргумент) | 2 (+ cmp-шаг) | — | шаг 602 | ESSENTIAL (байт-копия H) |
| kompozicija.stand-in.sh | инв. 5/6 | нет | 2 | — | оси 21–28 | ESSENTIAL (байт-копия) |
| mobile.yml шаг 601 + флаг | А-2 | файл отчёта (явный путь в argv) | 1 | — | checker | ESSENTIAL |
| pack kontrakt.md (+8 строк) | шаблон 132 | нет | 1 | — | SHABLON OK | ESSENTIAL |
| данные ×3 носителя | ПЕРЕСЕЧЕНИЕ 995 | нет | 3 (+ эталоны) | — | DANNYE-судья, 995-пробы | ESSENTIAL |

Всё по §1–§6 перепроверил своей мерой, но вердикт FAIL: блокеры R118v2-B1…B5 (правило (В)) в
`.review/2026-10-25-01.md`.
