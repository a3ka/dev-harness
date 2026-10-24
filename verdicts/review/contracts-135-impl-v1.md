FAIL
OBJECT=eea0db8c324154d2ce66c12ca38b3418a059c632

# Ревью реализации 135 first-run-ekran — PR a3ka/Complior-mob#121 (круг 1)

Судья: reviewer (Rev135). Находки в формате reslop: `.review/2026-10-24-01.md` (status: ready).

## Основание

Механическая часть приёмки зелёная. Это подтверждено моими прогонами и моей мерой: зона
соблюдена, tsc/jest/lint дают rc 0, валидатор 132 проходит стадию формы, сверка 123 на кадрах CI
даёт 8/8 OK теми же числами, проверка происхождения даёт rc 0 и краснеет на подложенном макете,
Г0 117/2 зелёный, frozen-файлы байт-равны пинам. CI на OBJECT зелёный.

Вердикт всё же FAIL: при сверке 8 кадров с PNG по норме «Мобильный экран — сверка с макетом»
нашлась одна блокирующая находка в зоне implementer. **R135-B1**: в кадр F03.02-V01 light попала
каретка поля кода. Кадр недетерминирован (зависит от фазы мигания), а норма владельца
2026-10-14 требует «не оставлять … курсор в снимке».

Остальные расхождения с макетом (K1 шрифт, K2 Demo-ссылка, K3 маска кода и лишние ссылки) по
норме тоже FAIL. Но implementer не может закрыть их в своей зоне, не нарушив frozen 995 или не
решив за владельца открытый вопрос 117 №2 о шрифте. Поэтому они адресованы владельцу и
architect как коллизии и implementer 135 не блокируют.

Блокеров: **1** (R135-B1).

## 1. Область правки

`git diff --name-only origin/main...HEAD` — 17 файлов, все внутри ЗОНЫ implementer:
```
.github/workflows/mobile.yml
mobile/.maestro/first-run-ekran.yaml
mobile/e2e-first-run/{batareja/proverka_proiskhozdenija.py,batareja/red_ekrana.sh,e2e.sh,ekran.json,kadry.json,katalog_kopii.json,kontrakt.md,spec_api.json}
mobile/src/features/auth/{__tests__/auth-code-input.test.tsx,__tests__/auth-keyboard.test.tsx,artboard.ts,auth-parts.tsx,auth-screen.tsx,auth-tokens.ts,first-run-screen.tsx}
```
В диффе нет ни `pilot-app.tsx`, ни frozen-тестов, ни `.harness*`, ни норм. Все 7 коммитов
сделаны от `implementer <implementer@dev-harness.local>`, у каждого префикс «135:».

Frozen-файлы против пинов (моя мера: `git archive` пинов в Rev135/H*):
```
cmp pilot.test.tsx  (Hc663 pilot_995)            rc=0
cmp source.json     (Hc663 pilot_995)            rc=0
cmp proverka_proiskhozdenija.py ↔ H135 teksty/proverka_text.py   rc=0
```
H-пины в `mobile.yml`: `.harness` c663dd0f, `.harness135` ca277b3a, `.harness117` 8d3f48b8 (не
тронут). `stale_table.test.tsx` в продукте не лежит: проба копирует его из H. Прогон
`stale_table_probe.py --repo <копия>` дал 12/12 строк `rc=0`, итог STALE_RC=0.

Проверки не подогнаны под код. `red_ekrana.sh`, `e2e.sh` и flow отличаются от stand-in текстов
батареи (`teksty/batareja_text.sh`, `e2e_text.sh`, `flow.yaml`), и это ожидаемо: контракт требует
байт-равенства только для файла проверки, а stand-in — это replay батареи. Отличия такие:
манифест — пачки, а не `.harness123/kadry.json`; e2e — настоящий Maestro с
`FIRST_RUN_SERIAL`; flow — appId продукта, `clearState`, ожидания splash, `hideKeyboard`, ввод
кода. Ни одно отличие не снимает шаг перехода или assertVisible.

## 2. Сырой вывод (моя копия `/tmp/dev-harness-verify/Rev135/mob`)

```
$ npx tsc --noEmit                         → TSC_RC=0
$ npx jest --ci --runInBand                → Test Suites: 3 passed, 3 total; Tests: 19 passed, 19 total; JEST_RC=0
$ npm run lint  (копия без .harness*/mobile/e2e-first-run, как шаг «Вынести H…»)
  structure: OK (repository inventory; external trees excluded)   LINT_RC=0
$ python3 ../H135/scripts/ekran_shablon.py --pack mobile/e2e-first-run --repo . --harness ../H135
  PRICHINA	SHABLON_NEVEREN	нет каталога: mobile/maestro-out-first-run      SHABLON_RC=2   (ожидаемо: нет maestro-out)
  с кадрами CI в maestro-out-first-run:
  PRICHINA	E2E_NE_PROSHLA	rc=1     SHABLON_RC=1   (форма пройдена, e2e без эмулятора — ожидаемо)
```
Первый lint под `reslop t` дал rc 1 с причиной `mobile/.log/.runs/…json: file outside allowed
location`: это лог самого reslop внутри дерева, артефакт моего прогона. Повтор без reslop на
чистой копии дал rc 0.

Своя мера кадров. Я взял кадры CI art11, положил их в `mobile/maestro-out-first-run` и прогнал
раннер 123 из H135 по манифесту пачки:
```
KADR	First-Run dark	0.787	0.600	zagolovok	OK
KADR	First-Run light	0.784	0.600	zagolovok	OK
KADR	F03.01 dark	0.802	0.600	cta	OK
KADR	F03.01 light	0.910	0.600	G	OK
KADR	F03.02 dark	0.660	0.600	dopolnitelno	OK
KADR	F03.02 light	0.908	0.600	G	OK
KADR	F03.02-V01 dark	0.805	0.600	osibka	OK
KADR	F03.02-V01 light	0.893	0.600	G	OK
SVERKA_RC=0
$ python3 mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-first-run --repo . --harness ../H135
PROVERKA_RC=0
негатив (кадр F03.01 dark := байт-копия docs/ux/…/F03.01.png):
PRICHINA	KADR_BYTE_KOPIJA_MAKETA	F03.01 dark      PROVERKA_NEG_RC=1
```
Форма пачки по моему счёту: 17 полей ekran.json, 8 кадров, kontrakt.md — 52 строки, 3942 байта,
ширина ≤111 символов. ЗОНА-строки kontrakt совпадают с `zony`. `zamenjaet` = манифест 123
First-Run, `ne_trogaet` = 2 живые пачки 132 + `kadry_117.json`, `operacii_api` = [].

Г0 frozen 117/2 на моей копии (H117 = полный `git archive 8d3f48b8`):
```
vkhod_static_probe.py --repo .   → static 40/40      VKHOD_STATIC_RC=0
vkhod_probe.py --repo .          → behavioral 26/26  VKHOD_PROBE_RC=0  (в т.ч. case RESTYLE_GUARD_995_F03_DARK / _LIGHT)
```
Первый прогон static с H117, где был извлечён только `vkhod_117/`, дал rc 1
(SPLASH_FRAME_SVERKA_123_*: не найден манифест 123). Причина — неполное дерево у меня, на полном
H результат 40/40.

## 3. Корректность правок

- **Сдвиг корня (63a947f).** `Surface`: `shift = keyboardTop === null ? 0 : max(0, actionBottom + 16 − keyboardTop)`,
  а `top: shift > 0 ? -shift : 0`. Значит, при скрытой клавиатуре сдвиг ровно 0 и кадры сверки не
  затронуты. Это подтверждают и тест, и пиксели кадров (позиции элементов совпадают с макетом в
  пределах ~0,3 % высоты).
  Красное предъявлено: `auth-keyboard.test.tsx` против `auth-screen.tsx`/`auth-parts.tsx` из
  b707c3b (до правки) даёт `✕ F03.01 …`, `✕ F03.02 …`, `Tests: 2 failed, 2 total`. Тест проверяет
  свойство (низ demo/CTA выше верха клавиатуры, при скрытии сдвиг 0), а не тавтологию.
  Побочный эффект — совет R135-S1.
- **Каретка поля кода (ec8e7e5, откат d42eb61).** Поле контролируемое (`value` от родителя),
  `selection` держится на конце значения. `auth-code-input.test.tsx` против 63a947f и против
  d42eb61 даёт `✕ каретка …`, остальные 2 зелёные, итог `1 failed, 2 passed`. Красный есть, но
  тест 1 сверяет значение prop: это проводка, поведение доказывает устройство (совет R135-S2).
  Контролируемость сохранена: frozen pilot.test 19/19 зелёный в общем jest, stale_table_probe
  12/12 rc=0.
- **Flow (eea0db8).** Добавлен шаг `extendedWaitUntil visible first_run_enter_f03` перед
  `notVisible splash-overlay`. Барьер усилен, ни один assert/переход не снят.

## 4. Сверка 8 кадров с макетами (смотрел каждое изображение сам)

Кадры: `/tmp/dev-harness-verify/orch/art11/first-run/{dark/2026-10-24_124418,light/2026-10-24_124455}/first-run-ekran/takeScreenshot/first-run-ekran-<k>.png`.
Макеты: First-Run — `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/First-Run.png`,
F03 — `docs/ux/03_Mobility_Slice1/screens/<id>[-Hell].png` (клон Impl135).

Общее для всех кадров:
- шрифт Roboto вместо DM Sans (K1);
- системный статус-бар поверх full-bleed (на артборде его нет).

Раскладка совпадает с макетом по вертикальным долям: заголовок 31 %, поле 50 %, CTA 88,4 % против
88,5 %, нижняя ссылка 95,2 % против 95,3 %. Цвета ground/ink/accent/panel/danger совпадают с
токенами темы.

| Кадр | Макет | Вердикт | Отличия | KADR |
|---|---|---|---|---|
| First-Run dark (`dark/…/first-run-ekran-first-run.png`) | First-Run.png | совпадает, кроме шрифта | состав (wordmark, знак, заголовок, подзаголовок, CTA, футер) и цвета совпадают; переносы заголовка иные из-за шрифта (K1) | 0.787 |
| First-Run light (`light/…/first-run-ekran-first-run.png`) | First-Run.png (светлого макета нет — §НЕ ЗАЩИЩАЕТ) | совместим | светлые токены (ink-кнопка, светлый ground); шрифт (K1) | 0.784 |
| F03.01 dark (`dark/…/first-run-ekran-f03-01.png`) | F03.01.png | отличается | + «Demo mit Beispieldaten ansehen» (K2); шрифт (K1); остальное (знак, заголовок, тело, лейбл, поле, подсказка, CTA, «Zugang wiederherstellen») совпадает | 0.802 |
| F03.01 light (`light/…/first-run-ekran-f03-01.png`) | F03.01-Hell.png | отличается | + Demo-ссылка (K2); шрифт (K1); CTA ниже, ссылки под CTA нет — как на макете | 0.910 |
| F03.02 dark (`dark/…/first-run-ekran-f03-02.png`) | F03.02.png | отличается | код «••••» вместо «482 1» (K3); + «Zugang wiederherstellen» (K3); шрифт (K1); лейбл «demo@…le» вместо «a.weber@…de» — данные flow | 0.660 |
| F03.02 light (`light/…/first-run-ekran-f03-02.png`) | F03.02-Hell.png | отличается | те же отличия, что у dark (K3, K1) | 0.908 |
| F03.02-V01 dark (`dark/…/first-run-ekran-f03-02-v01.png`) | F03.02-V01.png | отличается | маска 6 точек (K3); + «Kontaktdaten ändern» и «Zugang wiederherstellen» (K3); шрифт (K1); красный знак, «Keine Verbindung», рамка danger, сообщение, плашка — совпадают | 0.805 |
| F03.02-V01 light (`light/…/first-run-ekran-f03-02-v01.png`) | F03.02-V01-Hell.png | **FAIL (B1)** | те же отличия, что у dark, **плюс каретка в поле кода** (450 px, x 352–356, y 1074–1163) | 0.893 |

Все 8 кадров выше порога 0.600, но это не заменяет сверку глазами. Кадры — настоящие снимки
устройства (статус-бар, системный растр шрифта), а не перекодированные макеты.

## 5. Побочный эффект клавиатуры

На F03.02 с открытой IME заголовок наезжает на статус-бар, а знак и wordmark уходят за экран
(`orch/art5/…/step-021-assertCondition-F02.01.png`). Это не кадр сверки 135, сдвиг нужен
frozen-флоу 995 (DIRECT entry). Это **совет** R135-S1, не блокер.

## 6. Реестр CI

```
$ gh pr checks 121 -R a3ka/Complior-mob
android-e2e	pass	10m0s	…/runs/40093275377/job/120872447737
quality	pass	4m37s	…/runs/40093275377/job/120872448791
$ gh api …/actions/runs/40093275377 → {"run_attempt":2,"head_sha":"eea0db8c…","conclusion":"success"}
$ gh pr view 121 --json mergeStateStatus,mergeable → {"mergeStateStatus":"BEHIND","mergeable":"MERGEABLE"}
$ gh api …/compare/main...eea0db8c → {"status":"diverged","ahead_by":7,"behind_by":1}
```
Лог android-e2e: `995 native rc=0 testcases=7 failed=0`; 8 строк KADR выше и `SHABLON first-run-ekran OK`.
Шаг завершён успешно: после него в том же `set -euo pipefail` выполняются cmp и проверка.
Лог quality: `case RESTYLE_GUARD_995_F03_DARK/_LIGHT`, `static 40/40`, `behavioral 26/26`,
`Tests: 19 passed, 19 total`, `structure: OK`.

Ветка отстаёт от main на 1 коммит docs/ux (#123). Закреплённые PNG экрана он не трогает. Совет
R135-S3: после обновления ветки нужен зелёный CI на новом SHA.

## 7. Паразитная сложность (050) — по артефактам диффа

1. `auth-screen.tsx` (+650/−149):
   - (1) свойство: F03 по доске внутри auth-зоны (нарезка Е, инв. 8);
   - (2) состояние: `keyboardTop` и `selection` явно входят в вычисление раскладки и prop поля;
   - (3) при правке раскладки меняются вместе auth-screen, auth-parts, artboard, auth-tokens (4 файла, новый слой);
   - (4) интерфейс `AuthScreenProps` не вырос, вся работа скрыта за ним;
   - (5) потребители — flow, сверка 123, pilot.test.

   **ESSENTIAL.** Комментарии-расследования — совет R135-S5.
2. `auth-parts.tsx`, `artboard.ts`, `auth-tokens.ts`:
   - (1) размещение по артборду и токены досок (инв. 4);
   - (2) состояния нет;
   - (3) общие для двух экранов;
   - (4) мелкие функции с ясным интерфейсом;
   - (5) потребители — first-run-screen и auth-screen.

   **ESSENTIAL.**
3. `first-run-screen.tsx` (переписан):
   - (1) First-Run по PNG;
   - (2)–(4) без нового состояния;
   - (5) потребители — KADR First-Run и проба 111.

   **ESSENTIAL.**
4. `auth-keyboard.test.tsx`:
   - (1) demo/CTA выше IME для frozen 995 flow;
   - (2) состояния нет;
   - (3) один файл;
   - (5) потребитель — jest в quality, красный на b707c3b предъявлен.

   **ESSENTIAL.**
5. `auth-code-input.test.tsx`:
   - (1) каретка в конце и контролируемость;
   - (5) потребитель — jest; тест 1 красный на 63a947f/d42eb61, тесты 2–3 — охрана регрессии.

   **ESSENTIAL**, оговорка — совет R135-S2.
6. Семья пачки `mobile/e2e-first-run/*` (8 файлов):
   - (1) приёмка п.6, форма 132;
   - (2) состояние — `maestro-out-first-run`, явное и очищаемое e2e.sh;
   - (5) потребители — шаг CI 135 и валидатор 132; грамматику 132 не повторяет, proverka байт-равна H.

   **ESSENTIAL.**
7. `first-run-ekran.yaml`:
   - (1) инв. 7 (переход + assertVisible перед каждым кадром);
   - (5) потребители — e2e.sh и proverka.

   **ESSENTIAL.**
8. Шаг CI 135 в `mobile.yml` (+75 строк):
   - (1) п.6;
   - (2) состояние: AVD `ci135-*`, порт 5564, env `FIRST_RUN_SERIAL` — явные, trap-очистка;
   - (3) загрузка эмулятора повторяет шаг 117;
   - (5) потребитель — android-e2e.

   Повтор логики → совет R135-S4: более простая форма, проходящая ту же приёмку, не доказана,
   поэтому не блок.

## 8. Прочее

- Норма не тронута: в диффе нет roles/contracts/docs/owner.
- Атомарность: 7 коммитов одного предмета 135, каждый со ссылкой на предмет. Чужих задач в них нет.
- Найденная коллизия в тексте контракта 135. Строка §Воля владельца «иные ссылки, «Demo mit
  Beispieldaten ansehen»» расходится с источником `docs/owner/2026-10-21-117-suzhenie.md:22` («НЕТ
  «Demo…»»). Это не пересуд контракта, а отметка для architect и владельца (K2).

## Находки (итог)

| ID | Класс | Адресат | Суть |
|---|---|---|---|
| R135-B1 | **БЛОКИРУЕТ** | implementer | каретка в кадре F03.02-V01 light (недетерминированный кадр, норма «не оставлять курсор в снимке») |
| R135-K1 | FAIL-сверки → владелец | владелец (117 вопрос №2) | шрифт Roboto вместо DM Sans на всех 8 кадрах |
| R135-K2 | FAIL-сверки → коллизия | владелец/architect | Demo-ссылка на F03.01 при её отсутствии на доске; цитата контракта расходится с источником |
| R135-K3 | FAIL-сверки → коллизия | владелец (frozen 995) | маска кода, лишние «Zugang wiederherstellen»/«Kontaktdaten ändern» на F03.02/V01 |
| R135-S1 | СОВЕТ | доводка/владелец | при открытой IME заголовок наезжает на статус-бар |
| R135-S2 | СОВЕТ | implementer | `selection` на конце — ограничение UX; тест 1 сверяет prop |
| R135-S3 | СОВЕТ | оркестратор | ветка BEHIND на 1 коммит, нужен CI на новом SHA |
| R135-S4 | СОВЕТ | implementer | повтор загрузки эмулятора в шаге 135 |
| R135-S5 | СОВЕТ | implementer | комментарии-расследования в продуктовом коде |
