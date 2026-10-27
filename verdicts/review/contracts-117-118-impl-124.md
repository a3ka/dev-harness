accept
OBJECT=67f7343950ece44e2fd53d22c11bb35cf403e07f
СУД: repo=Complior-mob (+dev-harness); предмет=117 (v4) и 118; фаза=реализация; роль=reviewer; вызов=1/2 (полный по 117 v4; scoped-подтверждение 118); модель-план=роль reviewer по config/agent_models.json (alias audit, семейство @opus, vision); сессия=Rev124b (трейс `…/2026-10-26T11-17-39-528Z_01a177ee-2a48-75af-86f8-4e9d5af0e8c0/Rev124b.jsonl`); модель-факт=anthropic/claude-opus-5-5; SHA=67f7343950ece44e2fd53d22c11bb35cf403e07f; предыдущий=для 118 — `verdicts/review/contracts-118-impl-v2c.md` (accept на 33beed4ca), для 117 v4 — нет; исключение=нет; независимость: автор 117 v4 Impl117v4 — `minimax/MiniMax-M3` (трейс Impl117v4.jsonl: 88× provider minimax), автор 118 — vision-тир, судья — anthropic, другое семейство; модель видит изображения — что на каждом кадре, см. §3 и §5.

Находки файлом: `/tmp/dev-harness-verify/Rev124b/.review/2026-10-27-01.md` (reslop, `status: ready`, blocking 0).

## Итог

- **117 v4 принимаю на 67f73439.**
  - В диффе ровно два файла зоны, байты совпадают с объявленными.
  - Батареи харнесса на `frozen/contracts/117/4` дают ожидаемое: статика 70/70 rc0; в поведенческой красны ровно 34 клетки ГРАНИЦЫ. Список свой, совпадает с листингом до v4 минус две HOLD_LINK.
  - Красное предъявлено на c617f6fb: статика rc1, 5 новых клеток; поведенческая — HOLD_LINK ×2.
  - Два своих мутанта ловятся именованными клетками.
  - Живое удержание видно в commands.json: `notVisible` ждал 7554/7477 мс вместо ≈1200.
  - Кадры Splash dark/light — JS-оверлей Splash.png. Геометрия совпадает с макетом ±2 pt, сдвиг +11 pt из-за contain. 0.783/0.782 OK во всех 5 попытках.
- **118 подтверждаю на 67f73439.**
  - Дельта от 33beed4ca в зоне 118 — только `pilot-app.tsx`, и в нём только блок 117 v4. `features/onboarding`, `e2e-erstinformation`, `.maestro/erstinformation.yaml`, `src/app` не тронуты.
  - 16 KADR ≥ 0.600 и `SHABLON erstinformation OK` во всех 5 попытках.
  - N1–N3 закрыты на кадрах; мерил сам.
  - V0 не упал: 0.845/0.783, на кадре экран Erstinformation, оверлея нет.
- **БЛОКИРУЕТ: нет.**
- **СОВЕТ:** S1, S2.
- **Наблюдения к владельцам других предметов:** O1, O2.
- **К владельцу:** новый класс N5 по правилу (В), вне дельты. N4 перенесён.

## 1. Область правки, атомарность, норма (117 v4)

```
$ gh pr view 124 -R a3ka/Complior-mob --json headRefOid,headRefName,state
{"headRefName":"cmp-mob-118/erstinformation-prod","headRefOid":"67f7343950ece44e2fd53d22c11bb35cf403e07f","state":"OPEN"}
$ git cat-file -t 67f7343950ece44e2fd53d22c11bb35cf403e07f
commit
$ git log --format='%H %an <%ae> %s' c617f6fb..HEAD
67f73439… implementer <implementer@dev-harness.local> 117 v4: удержание splash-оверлея по deep link на корень с query только в сценарии 117 (класс B: снимок Splash под оверлеем); порог 0.6 и кадр не тронуты; mobile.yml без изменений
$ git diff --name-only c617f6fb236d11574df75fb09ae41870bf8c29d6..HEAD ; rc=0
mobile/.maestro/vkhod-117-splash-vhod.yaml
mobile/src/bootstrap/pilot-app.tsx
$ sha256sum …
df4f738f00af71d24a9abb3e63e39c803ee5d6b6e03074d7f2305465fc03f7c6  mobile/src/bootstrap/pilot-app.tsx
23201d57ae0fbcaa50e961e1eccce017e21811504dd613a685c972fedc9c474b  mobile/.maestro/vkhod-117-splash-vhod.yaml
f45c68230eb83b12c8aa81173da4b9d46608b966acfef7da7ba6178d21087421  .github/workflows/mobile.yml
$ git diff --exit-code --stat c617f6fb HEAD -- .github/workflows/mobile.yml ; mobileyml_rc=0
```

**Содержание диффа** (сырой `git diff c617f6fb..HEAD` прочитан полностью).

`pilot-app.tsx`:
- импорт `Linking` из `react-native`;
- константы `SPLASH_HOLD_E2E_LINK = 'complior:///?e2e=splash-hold'` и `SPLASH_HOLD_E2E_MS = 8000`;
- в effect оверлея: `let timer = setTimeout(…, SPLASH_OVERLAY_MS)` ставится немедленно; затем `Linking.getInitialURL().then(u => { if (holdCancelled || u !== LINK) return; clearTimeout(timer); timer = setTimeout(…, 8000) })`; cleanup выставляет `holdCancelled = true; clearTimeout(timer)`;
- `const SPLASH_OVERLAY_MS = 1200;` не тронут (контекстная строка диффа).

`vkhod-117-splash-vhod.yaml`:
- между `launchApp{clearState}` и `extendedWaitUntil visible splash-overlay` добавлены `- stopApp` и `- openLink: complior:///?e2e=splash-hold`, плюс комментарий;
- прочие шаги байт-в-байт v3.

**Остальные проверки:**
- **Проверки не переписаны под реализацию.** Харнесс, тесты и фикстуры автор не трогал: в диффе только два файла продукта.
- **Атомарность.** Один коммит, ссылка на предмет «117 v4» в теме.
- **Норма.** Нормативные документы не тронуты: в диффе нет ни `docs/`, ни харнесса.
- **Литерал удержания только в 117.** Своя мера: `grep -rln splash-hold` по всему дереву без node_modules — только `mobile/.maestro/vkhod-117-splash-vhod.yaml` и `mobile/src/bootstrap/pilot-app.tsx`. Сам `openLink` литерала есть только в `vkhod-117…yaml:36`, `e2e=splash-hold` в прочих сценариях отсутствует.

## 2. Приёмка контракта (харнесс `frozen/contracts/117/4` = c951030b; R = клон на OBJECT + симлинк node_modules, тот же package-lock sha 10f3adf3…)

```
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo …/Rev124b/mob
… case ×70 … MAESTRO_HOLD_COLD_START, MAESTRO_HOLD_ALONE, SPLASH_HOLD_LINK_CHANNEL, SPLASH_HOLD_NO_ENV,
SPLASH_HOLD_LINK_ROUTE_MOUNT, REPLAY_SPLASH_WHILE_OVERLAY, REPLAY_HOLD_SCENARIO_ONLY, REPLAY_LIVE_PROBA_G,
MAESTRO_HOLD_PORJADOK_* ×15, SVERKA_123_* ×4 …
static 70/70
rc=0
# своя мера, другой командой: awk по выводу → head case_lines=70 RED_lines=0

$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo …/Rev124b/mob
… failed 34 of 191
rc=1
```

**Перечень красных клеток — своя мера.** Пробa список не печатает. Я написал `failed_list.py`: импорт `vkhod_probe.run_suite`, вывод статусов jest.

На OBJECT: `STATUS passed 157 / failed 34`. Все 34 красные клетки — семьи W1A ГРАНИЦЫ модель/production:
- MIGRACIYA_W1A_{NULL,STALE,GATE_OTSUT,STALE_SVETLAYA}_PREZHNIJ_PUT и MIGRACIYA_W1A_CURRENT{,_SVETLAYA}_MARSHRUT — 6;
- MIGRACIYA_TABLICA_CHASTICHNYJ_W1A_OTSUT ×2 и MIGRACIYA_TABLICA_POLNYJ_W1A_{CURRENT,STALE,NULL,NEIZVESTNOE} ×2 — 10;
- MIGRACIYA_ENTRY_{COMPLETE,UNKNOWN,INCOMPLETE,OTSUT}_W1A_{STALE,CURRENT} ×2 — 16;
- MIGRACIYA_PORYADOK_SMENA_TEMY_{DARK_TO_LIGHT,LIGHT_TO_DARK} — 2.

Это ровно «34 клетки ГРАНИЦЫ (семьи W1A/ТАБЛИЦА/ENTRY/порядок)» из приёмки v4.

Зелёные на OBJECT:
- `SPLASH_OVERLAY_TIMER_HIDE_{DARK,LIGHT}` — прод-литерал 1200;
- `SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT}`, `SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT}`, `SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT}`.

**Красное до v4** (worktree на c617f6fb, тот же харнесс):
```
failed_list.py: STATUS passed 155 / failed 36 — FAILED SPLASH_OVERLAY_HOLD_LINK_DARK, SPLASH_OVERLAY_HOLD_LINK_LIGHT + те же 34 MIGRACIYA_*
                (NE_INOJ_URL ×2, NE_NEMARSHRUT ×2, TIMER_HIDE ×2 — passed)
vkhod_static_probe.py: c617_rc=1
RED MAESTRO_HOLD_COLD_START … openLink литерала complior:///?e2e=splash-hold в сценарии нет
RED MAESTRO_HOLD_ALONE … открывают []
RED SPLASH_HOLD_LINK_CHANNEL … pilot-app не несёт канал (Г)
RED SPLASH_HOLD_LINK_ROUTE_MOUNT … ссылка канала сценария []
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']
```
Красное совпадает с приёмкой v4: «c617f6fb: статика rc1, красны РОВНО пять; поведенческая failed 36 of 191».

**Свои мутанты.** Копия `mob-mut`, правка только `pilot-app.tsx`, после каждого — `git checkout` и `status` чист.
- `shirokij-kanal`: `initialUrl !== LINK` → `!initialUrl?.startsWith('complior://')`. Результат: failed 38, красны `HOLD_NE_INOJ_URL_{DARK,LIGHT}` и `HOLD_NE_NEMARSHRUT_{DARK,LIGHT}` (+34 границы). Канал шире литерала ловится.
- `bez-clear`: удалён `clearTimeout(timer)` при апгрейде. Результат: failed 36, красны `HOLD_LINK_{DARK,LIGHT}`. Совпадает с «НЕ ЗАЩИЩАЕТ (v4, СОВЕТ критика круг 1)».

**Прочая приёмка на OBJECT:**
```
$ npm run -s typecheck                    → typecheck_rc=0
$ reslop t -- npm run -s typecheck        → exit: 0
$ npx jest src/bootstrap/__tests__/pilot.test.tsx → Tests: 14 passed, 14 total; jest_rc=0
$ npm run -s lint (дерево как есть)       → lint_rc=1, 22 строки «file outside allowed location/type»
    (.harness/*, mobile/e2e-erstinformation/*, mobile/e2e-first-run/*, kompozicija.stand-in.sh);
    на c617f6fb — те же 22 строки, c617_lint_rc=1 — не дельта v4
$ (как CI mobile.yml:240–251: вынесены .harness, e2e-first-run, e2e-erstinformation, kompozicija.stand-in.sh)
  npm run -s lint → «structure: OK (repository inventory; external trees excluded)»; lint_rc=0; файлы возвращены
$ git status --short --untracked-files=all → ?? mobile/node_modules (только симлинк R)
$ gh pr checks 124 → android-e2e pass (job 122465527248), quality pass (job 122464246915)
```

**Буквальная строка приёмки «`git diff --exit-code B C -- mobile/src/features/auth/` → rc0» на OBJECT даёт rc1.**
- Это 8 файлов коммитов 135: c00e5b6, 63a947f, d42eb61, ec8e7e5, 8eb8d4b. Они пришли из main.
- Ветка против main по `auth/` пуста: `git diff --stat c3235fbc HEAD -- mobile/src/features/auth/` → rc0.
- 117 v4 auth не трогает. Строка написана для v2 (до 135), с v4 не связана.

Батарею `first_run_111` не запускал (см. НЕ проверено).

## 3. Живые кадры 117 (vision: каждый кадр открыт и просмотрен лично)

**Серия.** run 40570602069, `head_sha=67f73439`, conclusion success, run_attempt 5. Пять попыток через API:
- 122425010734 — station-complior;
- 122437140172 — station-complior;
- 122446303161 — station-complior;
- 122455967964 — station-complior;
- 122465527248 — station-complior.

Все `android-e2e success`, `head_sha 67f7343950ec`.

**Логи.** Свои копии: `gh api …/actions/jobs/<id>/logs`. `cmp` с копиями оркестратора `orch/seria124-job-<id>.log` — `same_as_orch=yes` ×5.

```
(каждая из 5 попыток, своя мера grep -cP)
KADR=26 OK=26 NIZHE=0 Splash_OK=2 F02=16 F02min=0.724
KADR	Splash dark	0.783	0.600	tagline	OK
KADR	Splash light	0.782	0.600	tagline	OK
KADR	First-Run dark 0.787 / light 0.784 OK; F03.01 0.802/0.910; F03.02 0.660/0.907–0.908; F03.02-V01 0.805/0.894 — все OK
995 native rc=0 testcases=7 failed=0
sverka-123.tsv (артефакт попытки 5): KADR Splash dark 0.783 … OK / Splash light 0.782 … OK
```

**Артефакты.** Через API доступны только артефакты попытки 5: `maestro-117-5f193364…-40570602069-5` и соседние. `gh run download -p 'maestro-117-*'` → `art117/`.

**commands.json 117** (свой разбор `cmds.py`). Цепочка инварианта 10 исполнена живьём:
```
dark : launchApp clearState=true 902 → stopApp 109 → openLink "complior:///?e2e=splash-hold" 1935 → visible splash-overlay 109
       → takeScreenshot vkhod-117-splash 356 → notVisible splash-overlay 7554 → … → takeScreenshot vkhod-117-first-run
light: launchApp 687 → stopApp 60 → openLink 2105 → visible 77 → shot 307 → notVisible 7477 → … → shot first-run
```
После снимка `notVisible` ждал 7.5 с. Значит, удержание 8000 взвелось ссылкой. Без него было бы ≈1200 минус уже прошедшее. Таймаут 15000 накрывает.

**Сверка с макетом.**

Splash dark:
- Кадр: `art117/…-5/dark/2026-10-27_210402/117 — splash + First-Run после снятия оверлея (схема устройства)/takeScreenshot/vkhod-117-splash.png` (sha256 18cb129d…).
- Макет: `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/Splash.png` (4a17e3a4…).
- Вижу: на почти чёрном фоне знак «C» светлым ink с лаймовой точкой справа внизу. Под ним wordmark «complior», ниже tagline «Versicherung. Erledigt.». Сверху системный статус-бар (9:04, светлые иконки), снизу gesture-бар.
- Это JS-оверлей Splash, а не нативный знак (у того нет wordmark/tagline) и не First-Run (у того нет CTA/заголовка).

Splash light:
- Кадр: `…/light/2026-10-27_210504/…/vkhod-117-splash.png` (91cfb569…).
- Макет: `screens/Splash-Hell.png` (108167d6…).
- Вижу: тёплый светлый фон, тёмный «C» с лаймовой точкой, «complior», tagline тёмным. Статус-бар с тёмными иконками.

Мера `measure_splash.py`: полосы содержимого в 390-pt, фон — мода на 15 % высоты.
```
mock dark   bg #0a0a0a  bands [(271,443,110,288), (514,533,158,232), (569,595,58,332)]
frame dark  bg #0a0a0a  bands [(282,455,110,290), (525,545,157,233), (580,607,57,333)]
mock light  bg #f3f2ee  bands [(271,443,110,288), (514,533,158,232), (569,595,58,332)]
frame light bg #f3f2ee  bands [(282,455,110,290), (525,545,157,233), (580,607,57,333)]
```

**Расхождения и их оговорки:**
- **Вертикальный сдвиг.** Знак, wordmark и tagline смещены на +11/+12 pt, одинаково. Окно 1080×2400 = 390×866.7 pt против артборда 390×844. Центрирование contain даёт ровно (866.7−844)/2 = 11.3 pt. Оговорено инвариантом 8/Р6: оверлей вписан по окну, resizeMode contain.
- **Размеры и горизонталь.** Совпадают ±2 pt.
- **Фон.** Точно ground схемы.
- **Состав.** Тот же: знак, wordmark, tagline.
- **Шрифт.** Растр артборда в композите — глифы те же по построению. Оговорено: «НЕ ЗАЩИЩАЕТ: точность глифов DM Sans», вопрос владельцу 2.
- **Статус-бар.** Есть на кадре, его стиль контрастен ground. Это инвариант 6 (StatusBar вне оверлея).
- **Gesture-бар.** Хром ОС: «НЕ ЗАЩИЩАЕТ: рендер ОС».

Неоговорённых расхождений нет.

First-Run после снятия оверлея:
- Dark: `…/dark/…/vkhod-117-first-run.png` (72405f6e…). Вижу wordmark сверху, большой светлый «C» с лаймовой точкой, заголовок «Sie sagen, was passiert ist. Complior kümmert sich um den Rest.», серый абзац, лаймовую CTA «Anmelden oder Konto erstellen», внизу «Versicherung. Erledigt.».
- Light: `…/light/…/vkhod-117-first-run.png` (09e131a2…). То же на светлом фоне, CTA чёрная.
- Это First-Run, оверлей снят. Макет First-Run судит first-run-ekran (135), не 117.

## 4. Нет регресса соседей

- **118 V0 после v4.** `F02.03-V01-V0` 0.845 / 0.783 и `F02.03-V02-V0` 0.845 / 0.783 во всех 5 попытках (dark/light).
- **Свидетели дефекта (В) не воспроизводятся.** sha256 кадров V0 попытки 5: dark c6d955c8…, light 1bdea25b…. Пины (В)-дефекта — d5975e86… / 6629b5d1… — не совпадают. Глазами на V0: экран Erstinformation, а не оверлей (§5).
- **135 First-Run / F03.01 / F03.02 / F03.02-V01** — OK во всех 5 попытках, значения как выше. Глазами: `art135/…/dark/2026-10-27_210706/first-run-ekran/takeScreenshot/first-run-ekran-first-run.png` (a0da7d10…) — First-Run, оверлея нет.
- **Удержание больше нигде.** Литерал — только сценарий 117 (§1).

## 5. 118 — scoped-подтверждение

```
$ git merge-base --is-ancestor 33beed4ca… HEAD ; ancestor_rc=0
$ git diff --stat 33beed4ca..HEAD
 .github/workflows/mobile-e2e-retry.yml     |  70 +++++   (139, merge main #126)
 .github/workflows/mobile.yml               |   2 +-    (откат/возврат 141, c87531f+daa95a8)
 mobile/.maestro/vkhod-117-splash-vhod.yaml |  17 ++    (117 v4)
 mobile/scripts/ci-e2e.sh                   | 397 ++++-   (995 v2–v4)
 mobile/src/bootstrap/pilot-app.tsx         |  42 ++-    (117 v4 — только блок удержания, §1)
```

Зона 118: `features/onboarding`, `src/app`, `bootstrap/__tests__`, `mocks/pilot-responses.json`, `e2e-erstinformation`, `.maestro/erstinformation.yaml`, `config.yaml`. В дельте её файлов нет, кроме общего `pilot-app.tsx`. В нём дельта — только splash-эффект 117 v4, путь допуска/демо не тронут.

Логи 5 попыток:
- `SHABLON erstinformation OK` ×5 и `SHABLON first-run-ekran OK` ×5;
- npm test шага 118: `Tests: 134 passed, 134 total` ×5;
- 16 KADR F02.* OK ×5, минимум 0.724 (F02.03-V01/V02 light).

**Спот-проверка N1–N3 глазами и мерой** (`runs.py`, `edge.py`; кадры попытки 5).

F02.03-V01 dark — кадр `art118/…/dark/2026-10-27_211004/erstinformation/takeScreenshot/erstinformation-f02-03-v01.png` (6ab26c8f…), макет `docs/ux/03_Mobility_Slice1/screens/F02.03-V01.png` (b3ed01e7…).
- Вижу: знак с оранжевой точкой, «Ihre Rückmeldung nötig» оранжевым, заголовок «Informationen zu Ihrem Makler».
- Светлая карточка «Verantwortlicher Makler» с 4 строками и чипами «Bestätigt» (зелёная точка). «Okt 15».
- Карточка документа со скелетоном и чипом «Nicht bestätigt» (оранжевая точка). Тёмная плашка notice с часами. Лаймовая CTA «Dokument öffnen», ссылка «Kopie herunterladen».
- Мера N1: строка notice 18.8–370.9 pt = `#1e1e1d` (--panel dark).
- Мера N3: чип документа — правый край 352.4 pt ∈ [349, 357]. Чип Makler — 330.1 pt, в пределах 4 от 327.

F02.08-V02 light — кадр `…/light/2026-10-27_211043/…/erstinformation-f02-08-v02.png` (fcb127bd…), макет `F02.08-V02-Hell.png` (2fc8eb9f…).
- Вижу: знак с серой точкой, «Wir warten auf eine Rückmeldung.», заголовок «Bereitstellung der Erstinformation».
- Белая карточка «Nachweis» со строками «Bestätigt» (зелёная) и «Unklar» (оранжевая). Плашка notice. Серая пилюля «Bereitstellung erneut prüfen», зелёная ссылка «Dokument öffnen».
- Мера N1: notice — мода `#e6e5df`; вторичная CTA — мода `#e6e5df`.
- Мера N2: левый край карточки `#f3f2ee ×4 → #dcdbd5 ×2 → #e9e9e5 → #ffffff`; верхний край — то же (кромка --line ≥1 px).

Чип F02.03-V02:
- Light — кадр `…/light/…/erstinformation-f02-03-v02.png` (054c6911…), макет `F02.03-V02-Hell.png` (b99fe0ae…). Вижу: белые карточки с кромкой, чип «Neue Version» (оранжевая точка), notice «Für diesen Schritt ist eine neuere Erstinformation erforderlich.», чёрная CTA.
- Dark — `…/dark/…/erstinformation-f02-03-v02.png` (e5bb7752…). Не открывал глазами, только мерил.
- Мера: правый край чипа документа 352.4 pt в обеих темах. Чип Makler на V02 по той же строке — в пределах.

F02.03-V01-V0, обе темы (регресс V0):
- Dark — кадр (c6d955c8…), макет `F02.03-V01-V0.png` (6df227bb…). Вижу: wordmark, знак с оранжевой точкой, «Ihre Rückmeldung nötig», заголовок, карточка Makler с тремя видимыми строками «Bestätigt», лаймовая «Dokument öffnen», «Kopie herunterladen».
- Light (1bdea25b…) — то же на светлом фоне. Splash-оверлея нет ни на одном.

**Итог:** N1–N3 закрыты, как на 33beed4ca. Новый класс по правилу (В), вне дельты: **N5** (§7, к владельцу). Прочие видимые отличия — K1–K4, N4, С11 арбитража 118 — вне перечня §5.2 и заново не судятся: шрифт Roboto, кнопка «Demo: nächster Zustand» под gesture-баром, статус-бар, сжатие высоких F02.03 в одно окно.

## 6. Зоны и слияние

`git diff --name-only c3235fbc(=origin/main=merge-base) HEAD` — 38 файлов. Атрибуция по коммитам ветки (`git log -- <file>`):
- **117 v4:** `vkhod-117-splash-vhod.yaml`, `pilot-app.tsx` — общий с 118.
- **118:** `.maestro/{config,erstinformation}.yaml`, `e2e-erstinformation/*` ×8, `src/app/*` ×4, `bootstrap/__tests__/*` ×7, `features/onboarding/*` ×13, `mocks/pilot-responses.json`, `pilot-app.tsx`.
- **995 v2–v4:** `mobile/scripts/ci-e2e.sh` — судит Rev124a.
- **118/141/995:** `.github/workflows/mobile.yml`.

Файлов вне зон 117/118/995/141 нет. `check_zones` полным не гонял: по заданию не повторять при пустом дифе зон, а дифф 117 v4 = 2 файла своей ЗОНЫ.

## 7. Находки (каждая и её класс; файл `.review/2026-10-27-01.md`)

БЛОКИРУЕТ: нет.

СОВЕТ:
- **R124b-S1** (СОВЕТ, 117 v4). `pilot-app.tsx:265` — `void Linking.getInitialURL().then(…)` без `.catch`: при rejection будет unhandled rejection. Прод-таймер уже стоит, поведение не меняется. Проще: `.catch(() => {})`.
- **R124b-S2** (СОВЕТ, 117 v4). Комментарии `pilot-app.tsx:60-76, 255-261` и `vkhod-117…yaml:18-32` пересказывают историю проб (run-ID, отклонённые (В)/(Г)). Проще: 2–3 строки со ссылкой на контракт 117 v4.

Наблюдения вне 117/118 (к владельцам):
- **R124b-O1** (НАБЛЮДЕНИЕ → 995/141/139). Обрывы adb на станции.
  - В каждой из 5 попыток один повтор темы 117 по сигнатуре: 1–4 — dark, 5 — light.
  - В 3 попытках из 5 — повтор шагов 135/118 (`PRICHINA E2E_NE_PROSHLA`, `device offline`).
  - До v4 то же: jobs 121577607948, 121586043178, 121933361101.
- **R124b-O2** (НАБЛЮДЕНИЕ → 995). Красная серия Б: run 40570609019, job 122425232044, station-complior-2, параллельный запуск.
  - `995 native rc=1 testcases=7 failed=7`, «EXHAUSTED: попытка 2 красная». Шаги 117/135/118 не исполнялись: артефактов `maestro-out-117/first-run/erstinformation` нет.
  - Причину не устанавливал — предмет 995.

К владельцу (правило (В), вне дельты, merge не держит — арбитраж 118 §5.2, последний абзац):
- **R124b-N5.** На F02.03-V01/V02, обе темы, нет wordmark «complior».
  - В макете он есть: F02.03-V01.png, y=41 pt, пиксели знака на x≈165–230. В кадре на y=41 pt — сплошной `#0a0a0a` на x 150–240. На кадре V0 той же темы wordmark на этой строке есть.
  - Это заявленный выбор реализации 118: `erstinformation-artboard.ts:66`, `erstinformation-screen.tsx:467`.
  - Дельта по `features/onboarding` с 33beed4ca пуста. [INFERENCE] Свойство унаследовано от принятого кандидата.
  - Прежние вызовы и арбитр 118 его не называли.
- **R118v2-N4** — перенесён, решение владельца открыто.

## 8. ПРОВОДКА (038), паразитная сложность (050), СВЕРКА-СТАНДАРТОВ

**ПРОВОДКА 117/4.**
- `role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»` — строка есть: `roles/orchestrator.md:383` (харнесс 85737c9b).
- ПРОВОДКА-ЭНФОРСМЕНТ правила (В). Норма-строка теперь есть в `roles/reviewer.md:117`, правило исполнено этим вердиктом (§3, §5).
- Guard'ы батареи 117 — свои барьеры предмета: `vkhod_*_probe.py` из пина `.harness117` в шаге quality. Не трогались.

**Паразитная сложность (050), по артефактам диффа:**
- **Ветвь удержания в effect pilot-app + константы `SPLASH_HOLD_E2E_LINK` / `SPLASH_HOLD_E2E_MS`:**
  1. Свойство: инварианты 10/12 — литерал корень+query, 8000 ≥ hold_min 3500, очистка в cleanup.
  2. Состояние: локальные `timer` (переприсваиваемый) и `holdCancelled` внутри effect, явны в коде. Вход — только стартовый URL, виден в сценарии как `openLink`. Env/флагов нет.
  3. При правке свойства меняются вместе 2 файла продукта (литерал в pilot-app и в yaml) и оракул source.json харнесса. Число выросло с 0: свойство новое, общий литерал неизбежен.
  4. Глубина: интерфейс — одна строка-литерал, без аргументов/env/rc. За ним скрыт апгрейд таймера с очисткой — модуль глубокий.
  5. Потребители: Jest HOLD_* ×6, статика SPLASH_HOLD_LINK_CHANNEL/ROUTE_MOUNT/REPLAY, CI-шаг 117 → 123. Чужую грамматику не дублирует.

  ESSENTIAL: более простые формы отклонены контрактом живыми пробами — без удержания класс B, (А)/(Д), env (В), host-ссылка (Г).
- **Два шага сценария (`stopApp`, `openLink` литерала):**
  1. Свойство: инвариант 10, холодный старт по ссылке.
  2. Состояния нет.
  3. Меняется 1 файл.
  4. Интерфейс не растёт.
  5. Потребители: CI android-e2e шаг 117, MAESTRO_HOLD_COLD_START/ALONE/PORJADOK_*.

  ESSENTIAL.

**СВЕРКА-СТАНДАРТОВ.** `AGENTS.md` продукта объявляет `STRUCTURE.md` и `mobile/AGENTS.md`. `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md` в продукте нет.
- `STRUCTURE.md §1 п.5` (bootstrap — composition и выбор реализаций) — соответствует: удержание живёт рядом с оверлеем в `bootstrap/pilot-app.tsx`, файле зоны.
- `STRUCTURE.md §4` (направления импортов bootstrap →) — соответствует: новый импорт только `Linking` из `react-native`.
- `STRUCTURE.md §5` (запрет `if (mode)`-развилок mock/runtime в production) — соответствует: литерал не mock/runtime-шов и не переключает реализации. Он продлевает визуальный оверлей (`pointerEvents="none"`) ровно при точном URL. Прод-видимость принята контрактом v4 («НЕ ЗАЩИЩАЕТ», ловец — ревьюер 117). Допустимость признаю: без данных/авторизации, только 8 с кадра Splash при ручном вводе неопубликованной ссылки.
- `STRUCTURE.md §6` (имена, константы по TS-конвенции) — соответствует: `SPLASH_HOLD_E2E_*` того же вида, что существующий `SPLASH_OVERLAY_MS`.
- `STRUCTURE.md §7` (Maestro в `mobile/.maestro/`, связка AC → сценарий → скриншот) — соответствует: существующий сценарий 117, кадры в артефакте.
- `mobile/AGENTS.md` (lint/typecheck до done; навигация Expo Router) — соответствует: typecheck rc0, lint rc0 в CI-форме; маршрут «/» существующий, новых маршрутов нет.

## НЕ проверено

- Кадры попыток 1–4: их артефакты в API отсутствуют, run отдаёт только `…-40570602069-5`. По попыткам 1–4 есть только строки KADR/SHABLON из логов (§3–§5).
- Глазами не открывал: F02.03-V02 dark (только мера); F02.03-V01-V0-Hell.png как макет. 13 из 16 кадров 118 не открывал: scoped-вызов, спот-проверка 3 кадров по заданию + V0.
- Батарея `first_run_111` (23/23) — не запускал. Строка приёмки относится к 117 v2/v3. Дельта v4 не касается FirstRunScreen, auth/ на ветке против main пуст.
- `--matrix` батарей 117 — не гонял. Это приёмка модели архитектора, не реализации. Вместо неё — 2 своих мутанта.
- Полный `check_zones.sh` — по заданию не повторял.
- Причина красной серии Б и сигнатуры adb — не устанавливал (предмет 995/станции).
- Байт-идентичность кадров 118 с кадрами принятого 33beed4ca — не сверял: их артефакта нет. Свидетель — пустая дельта кода зоны 118.

## Рабочий каталог

`/tmp/dev-harness-verify/Rev124b/`:
- клоны `mob` (OBJECT, чистый), `mob-c617` (c617f6fb), `mob-mut` (мутанты, восстановлен), `harness` + worktree `h117` (`frozen/contracts/117/4`);
- логи `logs/job-*.log`;
- артефакты `art117`, `art118`, `art135`;
- throwaway-меры: `failed_list.py`, `measure_splash.py`, `cmds.py`, `runs.py`, `edge.py`, `mutate.py`.

Push/commit не делал, раннеры и workflow не запускал.
