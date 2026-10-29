FAIL
# Вердикт reviewer — 145 faden-dvizok, реализация (SUBJECT=145, OBJECT=c563920228135b360e9d20ce359b4f0bf3ee7764)

OBJECT=c563920228135b360e9d20ce359b4f0bf3ee7764
СУД: repo=Complior-mob (PR #138, ветка cmp-mob-145/faden-dvizok); предмет=145; фаза=реализация (контракт frozen/contracts/145/3); роль=reviewer; вызов=1 (полный суд перед слиянием); модель-план=anthropic/claude-opus-5-5; сессия=Rev145; модель-факт=anthropic/claude-opus-5-5; SHA=c563920228135b360e9d20ce359b4f0bf3ee7764; харнесс=main 96ac0b37b (батарея == тегу 145/3, `git diff frozen/contracts/145/3 HEAD -- fixtures/workshop_project/faden_dvizok_145 contracts/145-faden-dvizok.md` пуст); класс риска «обычный» (адверсарий не нужен); независимость: автор implementer (MiniMax), батарея/контракт architect, судья — Anthropic.

Находки: `/tmp/dev-harness-verify/Rev145/review/2026-10-29-01.md` (status: ready). В нём Б-1 (БЛОК) и С-1…С-6 (СОВЕТ).

Вердикт привязан к блобам OBJECT:
- `mobile/src/lib/faden/` — tree 4c7002b6;
- `theme/motion-tokens.ts` — dbf81bd4;
- `package.json` — 2884d32d; `package-lock.json` — a923f6ba;
- `tsconfig.json` — 7185c43a; `jest.config.js` — ba0900fc; `jest.setup.ts` — 86d0b9e6;
- батарея — tree c21495c8; контракт — blob 007c0414.

sha256 файлов субъекта:
- `faden-motion.ts` — 9975cadd…;
- `faden-state-source.ts` — 9783ec09…;
- `FadenSign.tsx` — d9a8821b…;
- `motion-tokens.ts` — a2dfd544….

## БЛОКИРУЕТ

**Б-1 — после слияния android-e2e продукта красный: шаг «118 erstinformation» выдаёт `PRICHINA LITERAL_VNE_AUDITA jest-otchet.json:1`, причина — заголовок теста в ПИННОВАННОМ каноне 145.**

- Обязательство: §Порядок исполнения п.2 («живые гейты зелёны»), норма 146+ («живые гейты CI продукта, которых касается предмет»), задание судье по android-e2e.
- Фрагмент: `mobile/src/lib/faden/__tests__/faden-sign.test.tsx:114`, заголовок `…ровно n кадров за advanceTimersByTime(16·n)`. Это канон a05, sha256 9dc0faf7….
- Путь до отказа:
  1. `mobile.yml:664` (main) пишет полный jest-отчёт в пачку 118.
  2. Валидатор 132 (`scripts/ekran_shablon.py` @5dbcb549) в `check_literal` аудирует всю пачку.
  3. `RE_CVET` (ветка `ident(…цифра…)`) находит `advanceTimersByTime(16·n)`.
- Живой CI: run 40919849830 — attempt 1 (job 123611129032) и attempt 2 (job 123619171952) — оба failure на шаге 22, лог `PRICHINA	LITERAL_VNE_AUDITA	jest-otchet.json:1` → `exit code 1`.
- Своя мера (`literal_audit.py` вызывает функцию валидатора):
  - OBJECT → `['PRICHINA\tLITERAL_VNE_AUDITA\tjest-otchet.json:1']`;
  - база 518d8e7b → `[]`;
  - main push run 40787711105 — android-e2e success.
- Падение детерминированное. Доказательство v3 (run 40902100313) шаг 118 не исполняло: android-e2e там `cancelled`.
- Класс: дефект контракта, а именно канона и демаркации гейтов (по арбитражу 145 Q2 стр. 93 «следующий FAIL передаётся владельцу» — маршрут через владельца). Implementer в своей зоне это НЕ закрывает: канон пиннован, `mobile.yml` и валидатор 132 вне зон 145. Адресат — architect v+1 или владелец.
- Закрывающее свойство: на кандидате android-e2e «118 erstinformation» зелёный, И-8 побайтово равен пинам.

## СОВЕТЫ (подробности — `review/2026-10-29-01.md`)

- С-1 — `faden-sign-contract.test.tsx` канон не подменяет. Режим L без него: контроль 2/10, 15/15 убиты. Но шапка файла ложна (про «синхронный render» канона), и файл дублирует оракул канона. Числа 3/15 заморожены, поэтому только совет.
- С-2 — `lib/faden/tsconfig.json` + typecheck-скрипт избыточны после exclude в корне: 64 = 64 файла. Exclude теперь в двух местах. Предписано замороженной ПРЕДПОСЫЛКОЙ v3, поэтому совет.
- С-3 — `lib/faden/node-builtins.d.ts` без потребителя: каноны вне всех tsc-проектов, а сам файл даёт глобальные ambient `fs`/`crypto`. Без него все строки зелёные. Файл есть в референсе `bcf4391c`, поэтому совет.
- С-4 — устаревшие комментарии (`FadenSign.tsx:4-5` «слой ui…», шапка С-1).
- С-5 — СВЕРКА-СТАНДАРТОВ: STRUCTURE.md §6 kebab-case / §1.3 ui против пути, замороженного контрактом (`lib/faden/FadenSign.tsx`).
- С-6 — три коммита одной задачи, промежуточные v1/v2 красные на CI продукта. Сливать squash'ем.

## СВЕРКА-СТАНДАРТОВ

Продуктовый `AGENTS.md` объявляет `STRUCTURE.md` (ARCHITECTURE/CODING-STANDARDS в продукте нет).

- STRUCTURE.md §1 (место) — расхождение: `mobile/src/lib/faden/FadenSign.tsx:40` — чисто визуальный компонент в `lib/`, а по §1.3 ему место в `ui/`. Перенос предписан frozen 145/3 словом владельца (999 LITERAL_PALETTE / sourceLayers), находка адресована контракту (С-5).
- STRUCTURE.md §4 (направления импортов) — соответствует. `lib/faden` импортирует только react/react-native/react-native-svg/свои модули; features/app/bootstrap не тянет.
- STRUCTURE.md §6 (имена) — расхождение: `mobile/src/lib/faden/FadenSign.tsx` — PascalCase-файл при норме kebab-case. Путь заморожен батареей (a02, режим L), поэтому С-5.
- STRUCTURE.md §6 (дизайн-система/theme) — соответствует для `theme/motion-tokens.ts`: 31 токен побайтово из спека, t01 зелён. Палитра движка `colors()` в `faden-motion.ts` — второй набор цветов вне theme, но это дословный порт по Frontier контракта («движок несёт свой CANON дословно»). Не находка.
- STRUCTURE.md §7 (тесты colocated `__tests__`) — соответствует.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `lib/faden/faden-motion.ts` (623 стр.) | И-1/И-2/И-4/И-7 | часы инстанса — явно в `createInstance` | 1 | 20 экспортов + CompliorFaden/mount, порт целиком | клетки P/S/D, a03 | ESSENTIAL |
| `lib/faden/faden-state-source.ts` | И-10 | нет | 1 | 5 экспортов, 1 функция | i01/i02 | ESSENTIAL |
| `lib/faden/FadenSign.tsx` | Предмет, И-7, И-8 | проп `forceReducedMotion` (явный, в props) | 1 | 6 пропсов | режим L (матрица B.8), канон a05 | ESSENTIAL |
| `lib/faden/index.ts` | публичная поверхность (== форме, пин) | нет | 1 | 3 строки | форма батареи | ESSENTIAL |
| `theme/motion-tokens.ts` | И-5 | нет | 1 | 31 токен | t01 | ESSENTIAL |
| `__tests__/faden-motion.test.ts`, `faden-sign.test.tsx`, `faden-replay.json` | И-6/И-8 | нет | 0 (пины) | — | a01/a03/a05, режим L | ESSENTIAL |
| `__tests__/faden-sign-contract.test.tsx` | нет (И-8 лишь допускает доп. тесты) | патч глобального rAF в модуле (явно в файле) | 1 | дублирует оракул канона | числа 3/15 «Живых измерений»; повторяет логику канона | ACCIDENTAL → совет С-1 |
| `lib/faden/tsconfig.json` + typecheck-скрипт | нет (корневой exclude даёт то же множество 64 = 64) | — | exclude в 2 файлах (было 1) | — | `npm run typecheck` (предписан ПРЕДПОСЫЛКОЙ v3) | ACCIDENTAL → совет С-2 |
| `lib/faden/node-builtins.d.ts` | нет (каноны вне tsc) | глобальные ambient-модули | 1 | — | нет | ACCIDENTAL → совет С-3 |
| `jest.setup.ts` + строка `jest.config.js` | ПРЕДПОСЫЛКА v2 (rAF 16 мс) | глобальный rAF всех сьютов — явно, комментарий | 2 | 2 присваивания | первый тест канона; полный npm test 15/149 | ESSENTIAL |
| `mobile/tsconfig.json` exclude | гейт 995 (v3) | — | 1 | 2 строки | types_probe 995, корневой tsc | ESSENTIAL |
| `package.json`/lock: react-native-svg 15.15.4 | ПРЕДПОСЫЛКА B.9 | — | 2 | — | FadenSign, режим L | ESSENTIAL |

## Проверено (сырые команды, rc, вывод)

Клоны: `mob` — `/tmp/dev-harness-verify/Rev145/mob` @c563920 (https-клон: ssh `Repository not found` для Complior-mob на этой станции, при этом `ls-remote` через ssh отдал тот же head). `harness` @96ac0b37. `W` = `bash harness/fixtures/workshop_project/faden_dvizok_145/red_faden_dvizok_145.sh`.

### 1. Область правки

- `git diff --name-status 518d8e7b c563920` → 16 путей:
  - M `mobile/{jest.config.js, package.json, package-lock.json, tsconfig.json}`;
  - A `mobile/jest.setup.ts`, `mobile/src/theme/motion-tokens.ts`;
  - A `mobile/src/lib/faden/{FadenSign.tsx, faden-motion.ts, faden-state-source.ts, index.ts, node-builtins.d.ts, tsconfig.json, __tests__/{faden-motion.test.ts, faden-replay.json, faden-sign.test.tsx, faden-sign-contract.test.tsx}}`.
- Все пути ⊆ ЗОНА implementer 145/3. `mobile/src/ui/faden/` в итоге пуст (R100 в c563920). `.github/workflows/*`, `mobile/src/bootstrap/*`, пины H в mobile.yml — не тронуты.
- Коммиты: 7960d2e / 94b152d / c563920, автор `implementer`. `git merge-base --is-ancestor origin/main c563920` → да.

### 2. Три обязательные приёмки (§Приёмочный критерий 4–6)

Среда — РЕАЛЬНАЯ среда продукта: `npm ci --no-audit --no-fund` rc 0, node v26.5.1.

- `W --repo mob` → rc 0, `клеток 46, зелёных 46, красных 0`.
- `--seed 7` / `42` / `2026` / `31337` → rc 0, 46/46 каждый.
- `cd mobile && npm test -- faden` → rc 0:
  - `PASS src/lib/faden/__tests__/faden-sign.test.tsx`;
  - `PASS …/faden-sign-contract.test.tsx`;
  - `PASS …/faden-motion.test.ts`;
  - `Test Suites: 3 passed, 3 total`, `Tests: 15 passed, 15 total`.
- Полный `npm test` → rc 0: `Test Suites: 15 passed`, `Tests: 149 passed`.
- `W --live-component --repo mob` → rc 0:
  - `LIVE kontrol: ZELEN — suites=3 tests=15`;
  - null(idle) 9, null(прочие 10) по 4, zamorozka-nachalnogo-puti 5, os-flag-prinuditelno-false 1, os-flag-prinuditelno-true 4, obnovlenie-pozy-pri-smene-state-vykljucheno 4;
  - `LIVE: контроль зелён, мутантов 15, все убиты…`.
  - Матрица поимённо равна «Живым измерениям» контракта.
- `npm run typecheck` → rc 0. `npx tsc --noEmit -p tsconfig.json` (корневой) → rc 0.
- CI-форма, копия `cicopy`, H = dev-harness @b9b4c66f (пин mobile.yml):
  - `nav_probe` / `ui_probe` / `shell_static_probe` / `copy_probe` → rc 0 каждый, в том числе `999 static/LITERAL_PALETTE: rc=0`;
  - `types_probe.py` → rc 0 `995 types checked=2 schema=matched`;
  - после выноса `.harness`, `mobile/e2e-first-run`, `mobile/e2e-erstinformation`, `kompozicija.stand-in.sh`: `npm run lint` → rc 0 `structure: OK`, eslint 0.
- Живой CI PR #138, `gh pr checks 138`:
  - `quality pass` (job 123609795468; в логе 15/149, `995 types checked=2`, `LITERAL_PALETTE rc=0`, `structure: OK`, typecheck);
  - `android-e2e fail` (job 123611129032, шаг 22 — Б-1). Attempt 2 (job 123619171952, перезапуск) → `failure` на том же шаге 22: `17:47:49 PRICHINA	LITERAL_VNE_AUDITA	jest-otchet.json:1` → `exit code 1` (135 снова сначала `E2E_NE_PROSHLA` по эмулятору, повтор `SHABLON first-run-ekran OK`). `gh run watch … --exit-status` → rc 1.

### 3. Проверки не подогнаны под код (раздел «Живые измерения реализации» — арбитраж C.11)

- Каноны побайтово равны пинам `source.json`:
  - `faden-motion.test.ts` 788378a5… == форма;
  - `faden-sign.test.tsx` 9dc0faf7… == форма;
  - `faden-replay.json` b53fe9c1… == `drajver.json`.
- Батарея с момента freeze не менялась (diff пуст).
- Референс `faden-motion.js` во всех четырёх копиях product main = 4ffcc6be… == пин. Три оракула на main == пинам (9763fdc0… / 40e068c9… / 064d7821…).
- Порт написан не копией формы (sha расходятся), его равенство референсу судят клетки: p01–p15 зелёные, p14 — 3240 случаев, p15 — 6 скриптов × 100 кадров. Допуски батареи не трогались.
- Сверка «Живых измерений» с моими прогонами:
  - 3/15 = 3/15;
  - 46/46 = 46/46;
  - матрица L поимённо = контракту;
  - tsc / 999 / structure / typecheck rc 0 = rc 0.
- Строка живого CI quality на доводка-коммите есть: run 40919849830, PASS. При этом сам раздел ссылается на run 40902100313, где android-e2e `cancelled` (Б-1).
- Свои мутанты (`mutate.py`, одноразовые копии, seed 145 и 7):
  - `pose` R+5 при дробном t → rc 1, 28 красных (s-клетки);
  - R+5 при t с тремя десятичными → rc 1;
  - `fadenInput` молча отображает неизвестное имя → rc 1 `i02 … VYDUMANNAA_PROSHLA_0` (`thinking` → `{ok:true}`);
  - без проверки стороны → rc 1 `VYDUMANNAA_PROSHLA_4`;
  - тайминг ready ×1.1 → rc 1 (p01, p15; на seed 7 ещё p14 `VNE_SETKI_pose`);
  - игла R+5 в t∈(4000.2, 4000.3) → rc 0 на обоих seed (остаток B4 — объявлен в НЕ ЗАЩИЩАЕТ);
  - jest на мутанте «дробное t» → `FAIL faden-motion.test.ts`, 1 failed, rc 1.
- Компонент не пустой и не тавтологичный: `Svg viewBox 0 0 96 96` + `Path d={path(pose)}` + `Circle` из `dotXY`. Поза берётся из `createInstance().pose()`. ОС-флаг: `AccessibilityInfo.isReduceMotionEnabled` + `reduceMotionChanged` → `set({reducedMotion})`. Режим L убивает null/заморозку/потерю флага/потерю смены state.
- Канон без доп. теста (С-1): режим L → контроль 2/10, 15/15 убиты, rc 0.
- Источник И-10: экспорт ровно `FADEN_CLIENT_STATES, FADEN_ERROR_REASONS, FADEN_FACT_SIDES, FADEN_SERVER_STATES, fadenInput`, без импортов. 3 + 7 + error = 11 состояний. Отказы `VYDUMANNAA_FAZA:{nefakt, neizvestnaja_storona, neizvestnoe_sostojanie, nevernaja_storona, net_prichiny, prichina_vne_nabora}`. i01: 19 конформных; i02: 22 отказа.
- И-1: `faden-motion.ts` экспортирует 22 имени — 20 обязательных + `CompliorFaden`/`mount`. 0 импортов, нет enum/namespace. `motion-tokens.ts`: 0 импортов, `MOTION_TOKENS` 31 ключ.

- Подавлений нет: grep `eslint-disable|@ts-ignore|@ts-expect-error|as any|as unknown as|: any` по `mobile/src/lib/faden` — 0 совпадений.

### 4. Зависимости

- `git diff --numstat 518d8e7b c563920 -- mobile/package-lock.json mobile/package.json` → `157 0` и `2 1`. Удалённых строк lock 0; добавлены только react-native-svg и его транзитивные (css-select, css-tree, domutils, …).
- `react-native-svg` 15.15.4 == `expo/bundledNativeModules.json` (expo 57.0.30). `npx expo install --check` svg не называет.
- `typecheck`-скрипт изменён (С-2).

### 5. Числа доводки (своя мера — `runner.jsonl`, прямой вызов `probe_runner.mjs --mode repo`)

- s-клетки 21/21 ok.
- Ключевые точки: 105 из 105 (5 × 21) `ok:true`, path()-строки байт-точно.
- `strok_s_oshibkoj` 0 во всех сценах. Сумма `kadrov` по 21 сцене = 6680.
- Node-шим: `cd mob/mobile && FADEN_ORAKUL_DIR=<батарея>/model/oracle node <батарея>/model/jest_shim.mjs src/lib/faden/__tests__/faden-motion.test.ts` → rc 0, `{"proshlo":3,"upalo":0,"testov":3,"pervaya_oshibka":""}`. N = 3 — это тесты канона; 6680 строк сверяются внутри реплея.
- a03: 18 подпроб (честный, без каталога, 3 порчи, m1, m2, R+2 × 11) — ok.

### 6. ПРОВОДКА

- `registry/ci-steps.tsv:137` — `step check:faden-dvizok-145-family-selftest 15 bash …/red_faden_dvizok_145.sh --stabs`. Шаг в main (e68e46c6), `ci.yml` несёт ключ (строка 274).
- Guard = барьер этого предмета (сама батарея 145).
- Безфлаговый режим в harness: rc 1, `клеток 46, зелёных 0, красных 46 — SUBJECT_ABSENT`, 46 поимённых строк — задокументировано в комментарии реестра.
- `--model` → rc 0 46/46. `--stabs` → rc 0, `стабов 20, привязок 29, непойманных 0`. `--stabs --seed 7` → rc 1 `STAB_ZHIV: stab_pose_vne_setki прошёл вход p14-pose-sejanye-vhody` — стаб по построению привязан к первому сэмплу seed 145 (t=3624.158, класс B4); selftest валиден на дефолтном seed, CI несёт дефолт. Наблюдение, не находка. `proba_live_put_145.sh` → rc 0.
- Незаводимых пунктов проводки нет. Каналы приёмки продукта — npm test в quality и режим L.

### 7. Н-39

Соответствие стабов клеткам задаёт код батареи (`source.json:.stab_vhod`, 29 привязок), а не проза контракта. Контракт несёт инварианты И-1…И-10 и rc-команды. Мои мутанты краснят клетки, которые назначил код: i02, p01/p14/p15, s-клетки.

## Мобильный экран

Контракт 145 экранов и кадров не несёт (§Демаркация: «экранов 0, кадров 0»). Сверка скриншотов с макетами по слову владельца 2026-10-20 к предмету не применима.

## НЕ проверено

- Живое исполнение на эмуляторе/iPhone, «ощущение» — вне 145.
- Лаборатория `lab.html`.
- Бэкенд (G11 — синтетика).
- `npm run doctor` локально: в CI PASS, флаг пропуска проверки версий выставлен.
- Ssh-клон Complior-mob на этой станции отвечает `Repository not found`. Клон сделан по https — объект тот же (`c563920…`, `gh pr view` headRefOid совпадает).
