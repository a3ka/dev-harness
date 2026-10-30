FAIL
OBJECT=2279c4a8c8078d12910a5d2bf2ac6ee2dc2e8114
СУД: repo=Complior-mob (PR #136, ветка cmp-mob-143/cutover); предмет=143 mob-ci-razdelenie; фаза=суд реализации перед слиянием (cutover); роль=reviewer; вызов=1 (Быстрый процесс, предмет новый); сессия=Rev143; модель-факт=anthropic/claude-opus-5-5; харнесс=main 073e29290ceaf43d576f5767c21f7afe086b6423 (frozen/contracts/143/1 = 3d27e964d980aa6c6a4ae818f4dbd51a11e0041d); предыдущие=Adv143 FAIL (impl-v1), Adv143b ACCEPT (impl-v2)
Находки reslop: `/tmp/dev-harness-verify/Rev143/review/2026-10-29-02.md` (status: ready).

## Итог

Блокер один: **Б-1**. Обязательство frozen И-6 «`e2e-start` — один повтор по сигнатуре» в продукте НЕ исполняется. Ветка повтора в шаге «108 start» мёртвая: `set -e` внутри `zapusk108` перед `return "$rc"` (`.github/workflows/mobile.yml:1221-1223`) роняет шаг на первом же ненулевом коде Maestro. До `ДИАГНОСТИКА 108`/`ПОВТОР` дело не доходит (`:1234-1248`). Это доказано живым прогоном (attempt 1 run 40961808157) и replay. Required `android-e2e` попытки 1 честно красный; зелёный получен только ручным «re-run failed jobs». Ручной перезапуск подменил внутренний повтор задачи, а такой внешний слой И-6 как раз исключает. Продуктового дефекта перезапуск не скрыл: отказ — канонический обрыв транспорта до первого шага приложения. Скрыл он дефект CI.

Остальное, что входило в задание, проверено своими прогонами и зелёное (ниже). Шаг source provenance в `build-apk` реального `mobile.yml` маскировки не несёт (пункт 3).

## 1. Область правки

```
$ git diff --name-status 1a99902a 2279c4a8        # rc 0
D	.github/workflows/mobile-e2e-retry.yml
M	.github/workflows/mobile.yml
A	mobile/ci-screens.json
A	mobile/scripts/ci-aggregate.cjs
A	mobile/scripts/select-ci-screens.cjs
M	mobile/structure-policy.json
$ git rev-parse origin/main; git merge-base origin/main HEAD    # оба 1a99902a036c…
$ git merge-tree --write-tree 15e2982 1a99902a   → c7b2e27a…, rc 0;  git rev-parse cfde9ae^{tree} → c7b2e27a…
$ git diff --name-only 1a99902a cfde9ae          → те же 6 путей
```
ЗОНА implementer дословно из frozen-блоба: `.github/workflows/mobile.yml .github/workflows/mobile-e2e-retry.yml mobile/ci-screens.json mobile/scripts/select-ci-screens.cjs mobile/scripts/ci-aggregate.cjs mobile/structure-policy.json`. Шесть путей диффа совпадают с ней точно, лишнего нет. Merge-коммит `cfde9ae` — чистое авто-слияние: его дерево совпадает с `merge-tree` побайтно, чужого он не тащит. Зачем каждый файл:
- `mobile.yml` — DAG (И-3…И-9);
- `ci-screens.json` — карта (И-1);
- `select-ci-screens.cjs` — селектор (И-2);
- `ci-aggregate.cjs` — агрегат (И-5);
- удаление `mobile-e2e-retry.yml` — вывод 139 из эксплуатации (И-6);
- `structure-policy.json` — `+ "ci-screens.json"` в `mobileFiles`. Необходимость доказана: со старой политикой `node scripts/check-structure.cjs` → rc 1 `mobile/ci-screens.json: file outside allowed location/type`, с новой → rc 0.

Атомарность: 5 коммитов предмета плюс merge, все `implementer`, все «143 …». Пути коммитов: cb03387 — все 6; 3a94e19, 5ea59a1, 15e2982, 2279c4a — только `mobile.yml`. Норма: `git diff frozen/contracts/143/1 HEAD -- contracts/143-mob-ci-razdelenie.md` пуст; `check_contract_frozen.sh` → `ok … заморожен v1, блоб совпадает побайтово`. Батарея после freeze менялась только коммитами `architect` (f3c18d3c, 392114b7, 073e2929), автор реализации харнесс не трогал.

## 2. Байты модели и батарея (сырые прогоны)

```
$ for f in <4 файла>; do cmp $f harness/fixtures/workshop_project/mob_ci_143/model/$f; done   # 4× cmp OK
$ sha256sum .github/workflows/mobile.yml → 868b30e1a1accbacddea9a9ade6e97b7bafd58e83cb8160bba610ebd4ecf8c41
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Rev143/mob   → rc 0  «клеток 69, зелёных 69, красных 0»
$ … --model   ×3                                                                                        → rc 0 ×3 «клеток 69, зелёных 69, красных 0»
$ … --stabs                                                                                             → rc 0  «клеток 69, зелёных 69, красных 0» / «стабов 43, привязок 59, непойманных 0»
$ … (без флагов)                                                                                        → rc 1  «клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT»; grep -c '^КЛЕТКА .* SUBJECT_ABSENT' = 69
```
Дубль своей мерой (source.json, python): kletki 69 = s25 + a17 + y22 + f4 + p1. stab_vhod 43 ключа / 59 привязок, `ls stabs/stab_*.py | wc -l` = 43. Пины: piny 12 + chernoviki_piny 9 = 21. Против frozen source.json: +10 стабов, все привязаны к `y19-outputs-provodka`, изменённых или удалённых привязок нет (см. С-4).

## 3. ОБЯЗАТЕЛЬНЫЙ ПУНКТ — provenance `build-apk` в РЕАЛЬНОМ mobile.yml (глазами + разбор YAML)

`mobile.yml:386-454`, шаги `build-apk` по `yaml.safe_load`:
- 0 `actions/checkout@v7 {persist-credentials: false, clean: true}` — без `ref`, без `path`;
- 1 `name: Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)`, ключи ровно `name/run/working-directory`, `run == 'test "$(git rev-parse HEAD)" = "$GITHUB_SHA"'`;
- 2 изоляция раннера; 3 версия Node; 4 setup-node; 5 `npm ci`; 6 сборка; 7 ident; 8 upload (`if: always()`).

Проверено по классам маскировки:
- `|| true` / `; true` / `|| echo` / `; exit 0` — нет;
- `continue-on-error` — нет ни у шага, ни у job (ключей job: needs/outputs/runs-on/steps/timeout-minutes);
- `if:` на шаге — нет, а `if: always()` у upload маскировкой не является: при красной сверке сборка и ident пропускаются, upload падает на `if-no-files-found: error`, job красен;
- сравнение с самим собой — нет: левый операнд — фактический `git rev-parse HEAD` рабочего дерева, правый — env раннера;
- литерал только в комментарии — нет, литерал стоит в `run`;
- подмена исходников после сверки — нет: второго checkout нет, git-команд в `run` после шага 1 нет, сверка — вторым шагом, до setup-node, `npm ci` и сборки.

Живой лог build-apk 123762833836: `HEAD is now at 8595adb Merge 2279c4a8… into 1a99902a…`; `Run test "$(git rev-parse HEAD)" = "$GITHUB_SHA"` / `shell: /usr/bin/bash -e {0}`, шаг 3 success. `git fetch pull/136/merge`: `8595adb1^{tree}` = `2279c4a8^{tree}` = `50f26c2b…`, то есть собрано дерево OBJECT. **Маскировки нет.**

Для справки (остаток батареи принят словом владельца и `contracts-143-repin-arbitraz.md` п.5, не FAIL): мои мутанты в копиях продукта, каждый — `W --repo <копия>`:
- красные rc 1: `continue-on-error` (y05), `if: false` (y04), сравнение с собой, литерал только в комментарии (`run: echo ok # test …`), второй checkout после сверки, checkout `ref: main`, сверка после сборки, сверка удалена, `git checkout` в run — все y19;
- зелёные rc 0, 69/69: `… || true`, `…; true`, `… || echo skip`, `…; exit 0`. Это совпадает с Crit143y `verify-or-true`. В реальном файле таких суффиксов нет (С-1).

## 4. Живой CI run 40961808157 (head_sha=OBJECT, event=pull_request, run_attempt=2, conclusion=success)

Логи взяты через `gh api repos/a3ka/Complior-mob/actions/jobs/<id>/logs`, шаги — через jobs API. Таблица по раннерам (UTC):

| раннер | job (attempt) | интервал | AVD / порт | итог |
|---|---|---|---|---|
| station-complior | select-screens (1) | 21:55:40–21:55:51 | — | success, «VYBOROK 5 iz 5», COMMON_CHANGE |
| station-complior-2 | quality (1) | 21:55:40–21:58:07 | — | success, 21 шаг (пробы 995/999/108/111/117, npm test/lint/typecheck/doctor) |
| station-complior | build-apk (1) | 21:58:09–22:01:19 | — | success, digest 1e00519c…, артефакт apk-40961808157-1e00519c807e |
| station-complior | e2e-splash (1) | 22:01:21–22:04:04 | ci117-…-1 / 5562 | success; тема dark: обрыв → `ПОВТОР:` внутри job → Passed; KADR 0.783/0.782 OK |
| station-complior-2 | e2e-first-run (1) | 22:01:21–22:04:12 | ci135-…-1 / 5564 | success; 8 KADR OK, SHABLON OK |
| station-complior | e2e-erstinformation (1) | 22:04:05–22:07:37 | ci118-…-1 / 5566 | success; same-job Jest 149/149, SHABLON OK |
| station-complior-2 | e2e-pilot (1) | 22:04:14–22:07:11 | S: ci-…-1 / 5560 | success; `995 native rc=0 testcases=4 failed=0`, rehearsal OK, Maestro 2.11.0 |
| station-complior-2 | e2e-start (1) | 22:07:14–22:08:30 | ci108-…-1 / 5568 | **failure** (Б-1) |
| station-complior-2 | android-e2e (1) | 22:08:32–22:08:39 | — | failure `AGREGAT_OTKAZ: VYBRANNAYA_NE_USPEH — e2e-start=failure` (fail-closed верно) |
| station-complior | e2e-start (2) | 22:10:12–22:11:50 | ci108-…-2 / 5568 | success, Passed 26s, тот же артефакт и digest |
| station-complior | android-e2e (2) | 22:11:52–22:11:59 | — | success `AGREGAT_OK: selected=…5… digest=1e00519c807e…` |
| — | mobile-regression-signal (1,2) | — | — | skipped (event pull_request) |

Разведение слотов:
- на одном раннере интервалы не пересекаются;
- одновременные пары на разных раннерах — splash ∥ first-run, erst ∥ pilot, erst ∥ start(1) — идут на разных AVD-именах и портах 5562/5564/5566/5568/5560;
- `kill-server`, `killall` и широких `pkill` в файле нет (grep пуст), `pkill` везде ограничен `-avd $AVD`;
- упоминания чужих AVD в логах — только `Removing emulator-ci1xx-….log` при `clean: true` checkout-а.

Вывод: пересечения на одном эмуляторе нет.

Первая попытка e2e-start (`/tmp/dev-harness-verify/Diag136/art/`, лог 123758822843):
- `maestro.log:9` `CommandFailed: … emulator-5568: device offline`, `:11` `DeviceServerDiedException`, `commands.json:74` — отказ в `launchApp` (второй шаг), 1.6 с, `report.xml` «Unknown error»;
- сигнатура каноническая (`KANON` шага);
- в логе шага после трейса Maestro сразу `##[error]Process completed with exit code 1` (22:08:24, после `sleep 3` trap-а); строк `ДИАГНОСТИКА 108` и `ПОВТОР:` нет.

Значит повтор, предусмотренный И-6, не сработал. Перезапуск attempt 2 инициирован вручную (`triggering_actor=a3ka`, 22:10:07). Продуктовый дефект он не скрывает: отказ транспортный, до первого шага приложения, а attempt 2 на другом раннере — Passed на том же APK. Скрывает он дефект CI — Б-1.

Продуктовые гейты (копия `mob-gates`, Node 24.21.0 из toolcache раннера, как `.node-version`):
```
npm ci                          → rc 0
reslop t -- npm test            → rc 0  «Test Suites: 15 passed, 15 total / Tests: 149 passed, 149 total»
reslop t -- npm run typecheck   → rc 0
reslop t -- npx tsc --noEmit    → rc 0   (корневой tsconfig mobile/)
npm run lint (CI-форма: вынесены .harness, mobile/e2e-first-run, mobile/e2e-erstinformation, kompozicija.stand-in.sh) → rc 0 «structure: OK …»
```
`reslop t` пишет `.log/` в cwd, и `check-structure` его ловит, поэтому lint запущен без обёртки; это не дефект продукта. Пробы (одноразовая R, H = `git archive b9b4c66f`, как checkout шага quality): `cmp` pilot.test.tsx/source.json OK. 995: `probe.py --check-frozen`, runtime, bundle, schema, frozen_matrix, transport, admission, stale, types, pins, admission_family, stale_table — 12× rc 0. 999: nav, ui, shell_static, copy — 4× rc 0.

## 5. Один APK, fail-closed агрегат/селектор (мутации в копиях; скрипты `/tmp/dev-harness-verify/Rev143/mut/`)

- Один APK. `assembleRelease`/`gradlew`/`expo prebuild` есть только в `build-apk`, работники только `gh run download` по точному имени. `digest_replay.py` исполняет реальный шаг «APK сборки» каждого из 5 работников: тот же digest → rc 0, APK положен; иной → rc 1 `APK_DIGEST_RASKHOZHDENIE`, APK НЕ положен; пустой провод outputs → rc 1. Итог 15/15 OK, `bad=0`. Живьём все 5 работников и e2e-start(2) несут `IMJA_ARTEFAKTA: apk-40961808157-1e00519c807e` / `ZHELANYJ_DIGEST: 1e00519c…`.
- Агрегат (`agg_mut.py`, реальный `ci-aggregate.cjs`, база — живые значения attempt 2): 19 сценариев, `bad=0`. Честные 5/5 и 1/5 (остальные skipped с причиной) → AGREGAT_OK. Отказ по каждому из: failure (живой attempt 1), cancelled, selected-skipped, чужой digest, пустые outputs работника, старый run, чужой артефакт, сборка без outputs, build failure, quality skipped, selector failure, нет selection, пустой selected, пустой needs, лишний зелёный, skip без причины, работник вне needs — каждый rc 1 с именем.
- Селектор (`sel_mut.sh`, реальный `select-ci-screens.cjs`, база = OBJECT): 15 сценариев, `bad=0`:
  - локальный `features/start` → `start:AFFECTED`; флоу splash → `splash:AFFECTED`; удаление флоу first-run → `first-run:AFFECTED`;
  - `src/ui` → COMMON_CHANGE 5/5; сужение карты и удаление записи → POLICY_CHANGE 5/5; путь вне продукта → EMPTY_SELECTION_FALLBACK 5/5; `src/lib/faden` → UNKNOWN_PATH 5/5;
  - rc 1 с именем: новый флоу и новый pack без записи в карте → `INVENTAR_KARTY`, rename с пробелом и Unicode → `INVENTAR_KARTY`; `KARTA_NE_JSON`, `SKHEMA_KARTY`, `PUSTOJ_REESTR`, несуществующая база → `NET_BAZY`.
- Ruleset 25121366 «main: только PR + quality + android-e2e» (enforcement active, bypass пуст, strict): required `quality` и `android-e2e` (integration 15368). Агрегатор публикует ровно `android-e2e`, `quality` — отдельный job. Совпадает.
- `mobile-regression-signal`: `if: always() && (schedule || workflow_dispatch)`, в PR обе попытки skipped. Required его не делает ни ruleset, ни чужие needs. Он гонит тот же `ci-aggregate.cjs`, поэтому ложной зелени нет: те же отказы, что выше. Маркер грузится `if: always()` и означает «прогон был», а не «зелено». Ночью живьём НЕ исполнялся (ниже).
- `if:`/`continue-on-error` на шагах (YAML-разбор всех jobs): `continue-on-error` нет нигде; `if: always()` — только у upload-шагов и cleanup pilot.

## 6. Мердж-порядок и следующие PR

Сливать merge-коммитом: ruleset допускает `merge|squash`, а squash склеит 5 коммитов предмета и merge с main. **Сейчас не сливать — Б-1.**

В `ci-screens.json` 5 исполнителей: splash/117+123, first-run/135+111, erstinformation/118, start/108+138 (legacy_entrypoint), интеграция pilot/995+991+999 (фиксированный набор 4).

Следующий экран добавляется в своём PR: запись карты, строка `select-screens.outputs`, job `e2e-<id>` с needs `[select-screens, build-apk]`, `if` по выходу, digest/ident-шаги и outputs, плюс имя job в needs `android-e2e` И `mobile-regression-signal`. Fail-closed:
- новый pack или флоу без записи → `INVENTAR_KARTY` rc 1 (доказано);
- запись без job в needs → `VNE_REESTRA` (доказано);
- забытый выход → работник skipped → `VYBRANNAYA_NE_USPEH`.

Открытый #122 (116 Mission) меняет `mobile.yml`, добавляет `mobile/e2e-mission/` и флоу. После слияния #136 ему нужен rebase; без записи карты он будет красным по `INVENTAR_KARTY`, что верно. Батарея 143 жёстко держит набор jobs (`probe.py:61-64` CANON_JOBS, y01), так что поставка 116/138 обязана обновить её (черновики 116-v4/138-v2), иначе `W --repo` покраснеет (С-5).

## 7. Н-39 дословно

Стабы к ветвям привязывает architect по коду, НЕ проза контракта. Сверено: все привязки — `source.json:.stab_vhod`, 10 новых стабов (все → `y19-outputs-provodka`) внесены коммитами `architect` 392114b7 и 073e2929. Проза контракта стабы называет, но не привязывает. Починка Б-1 по той же норме: клетку и стаб на исполнение повтора e2e-start привязывает architect по коду.

## ПРОВОДКА (контракт 038)

`guard=fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh` существует и является барьером именно этого предмета. `bash scripts/check_provodka.sh . contracts/143-mob-ci-razdelenie.md` → rc 1 «guard не подключён». Отложенность объявлена §ПРОВОДКА: подключает оркестратор в окне freeze..done, после implementer. Это не дефект implementer, но и не «done» (С-5). ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: предмет — CI-оркестрация, не поведенческая норма класса 029.

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет только `STRUCTURE.md`; `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` не объявлены и в дереве отсутствуют.
- `STRUCTURE.md` §дерево `mobile/scripts/` («CI, генерация, проверка структуры; не runtime») — соответствует: `select-ci-screens.cjs` и `ci-aggregate.cjs` — CI-скрипты.
- `STRUCTURE.md` п.7 / стр.3 (новый домен или слой — только задачей, меняющей STRUCTURE.md и structure-policy.json) — соответствует: `ci-screens.json` — служебный файл в корне `mobile/`, не домен и не слой; `mobileFiles` расширен в зоне контракта.
- `STRUCTURE.md:26` (`.github/workflows/ # mobile.yml: quality и android-e2e`) — соответствует по именам required; дерево неполно по новым скриптам (С-6, вне зоны).

## Паразитная сложность (контракт 050) — пять вопросов по артефакту

- **`.github/workflows/mobile.yml` (+821/−149).**
  1. И-3…И-9 (явные jobs — слово владельца 13:40).
  2. Состояние — outputs selection и идентичности, артефакты; явно в outputs и логах.
  3. Новый экран — 5 мест в 2 файлах (карта; outputs select-screens; job; needs ×2) против 1 места в монолите. Рост ESSENTIAL: матрица отклонена §Frontier.
  4. Модули мелкие по построению (тела побайтово).
  5. Потребители — required `quality`/`android-e2e` и клетки y01–y22. Ветви `merge_group` (`:63`, `:71-72`, `:1411`) без триггера в `on:` требуются клеткой s25, поэтому ESSENTIAL.

  Итог — ESSENTIAL.
- **`mobile/ci-screens.json`.**
  1. И-1.
  2. Декларативное явное состояние, sha карты пишется в selection.json.
  3. Одна запись на экран.
  4. Интерфейса нет.
  5. Потребители — селектор и F-клетки.

  Итог — ESSENTIAL.
- **`mobile/scripts/select-ci-screens.cjs` (318).**
  1. И-2.
  2. Состояние в выходе selection.json и GITHUB_OUTPUT, скрытого нет.
  3. Меняется один файл.
  4. Интерфейс — 6 аргументов и 5 режимов против git/gh-API/инвентаря/политики; модуль глубокий.
  5. Потребитель — шаг `sel`. Логика повторяет `probe.py:kanon_vybor`, но намеренно: это независимый оракул И-10.

  Итог — ESSENTIAL.
- **`mobile/scripts/ci-aggregate.cjs` (88).**
  1. И-5.
  2. Вход — needs.json, выход — одна строка с именем.
  3. Реестр выводится из needs, отдельного списка нет: одно место.
  4. Один аргумент, модуль глубокий.
  5. Потребители — `android-e2e` и signal.

  Итог — ESSENTIAL.
- **`mobile/structure-policy.json` (+1).**
  1. Lint после добавления карты; без строки lint rc 1 (доказано).
  2. Нет состояния.
  3. Один файл.
  4. Интерфейса нет.
  5. Потребитель — `npm run lint`.

  Итог — ESSENTIAL.
- **Удаление `mobile-e2e-retry.yml`** — сложность уменьшается (И-6, y09).
- **Тело «108 start» (новое, ~140 строк).**
  1. И-6.
  2. AVD/порт явные.
  3. Один шаг.
  4. —
  5. Потребитель — e2e-start.

  ESSENTIAL по форме, но ветка повтора мертва — это функциональный блокер Б-1, а не находка сложности.

Находок ACCIDENTAL, блокирующих по правилу трёх частей, нет.

## Блокеры

- **Б-1 (БЛОКЕР; класс — frozen-обязательство И-6 не исполнено, «форма ≠ исполнение», достижимое состояние доказано живьём).**
  - Фрагмент: `mobile.yml:1213-1224` — `zapusk108(){ … set +e; maestro …; local rc=$?; set -e; return "$rc"; }`, вызов `:1230-1233` `set +e; zapusk108; rc=$?; set -e`. `set -e` в функции глобален, и ненулевой `return` при включённом errexit завершает шаг до `:1234`.
  - Исполнение, `/tmp/dev-harness-verify/Rev143/mut/replay_start_retry.py` (реальное тело шага, подложные adb/emulator/avdmanager/maestro; Maestro: 1-й вызов `device offline`, 2-й успех):
    - как есть → `rc=1`, stderr пуст, maestro-вызовов 1, ПОВТОР нет;
    - с удалённой строкой `set -e` внутри `zapusk108` → `rc=0`, `ДИАГНОСТИКА 108 … ПОВТОР: обрыв adb-транспорта эмулятора 108`, вызовов 2;
    - та же правка при продуктовом провале без сигнатуры → `rc=1`, вызов 1, ПОВТОР нет, то есть продуктовый отказ не повторяется.

    Контроль языка: `bash -c 'set -euo pipefail; f(){ set +e; false; local rc=$?; set -e; return "$rc"; }; set +e; f; rc=$?; set -e; echo after'` → `after` не печатается, rc 1.
  - Живьём: job 123758822843 (см. §4). Required красный на канонической транспортной сигнатуре, без диагностики Н-407 вне эха. Зелень — только внешним ручным перезапуском.
  - Происхождение: дефект в модели харнесса с самого freeze (`frozen/contracts/143/1:fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:1118-1129`, автор architect, 3d27e964). Implementer перенёс модель байт-в-байт, как требует И-10. Клетка y13 (`probe.py:1229-1235`) считает только литерал `ПОВТОР: `, поэтому на мёртвой ветке она зелёная.
  - Контраст: у 117 (`run_theme … || {…}` — контекст `||`) и у 135/118 (функции без `set -e`) повтор исполним. 117 сработал в этом же прогоне.
  - Кто закрывает: architect — модель и пин (Н-39: клетку и стаб на исполнение повтора e2e-start привязывает architect по коду). Затем implementer переносит модель побайтно, затем новый живой прогон на новом head.

## Советы (не блокируют)

- **С-1 (architect, остаток принят).** y19 не держит код возврата шага сверки: `|| true`, `; true`, `|| echo skip`, `; exit 0` → 69/69 rc 0 (мои копии; совпадает с Crit143y). Реальный файл чист. Можно закрыть закрытым алфавитом `run` шага сверки.
- **С-2 (architect).** `probe.py:1021` падает `TypeError: argument of type 'bool' is not iterable` на `run: true` (YAML-bool) и даёт rc 1 трассой, а не именованной причиной. Fail-closed здесь случайный.
- **С-3 (architect/implementer, И-7).** «Изоляция раннера» стоит в `build-apk` и `e2e-pilot`, но не в `e2e-erstinformation`, который исполняет JS из PR на хосте (`npm ci` + `npm test -- --json`). В монолите (`1a99902a`, android-e2e шаг 2) она охраняла весь job, включая Jest 118. Текст И-7 «переносятся: … изоляция раннера» неоднозначен. Не блок: `quality` и до, и после гоняет `npm test` PR без этой пробы, а сама проба — проверка конфигурации раннера, не песочница.
- **С-4 (architect/владелец).** Frozen §Приёмка п.6 называет «33 стаба, 49 привязок», факт — 43/59 (Fix143c, усиление, принято scoped). Буква замороженного текста больше не верна; сверить при ближайшем v+1.
- **С-5 (оркестратор).** guard не подключён (`check_provodka` rc 1), это обязанность окна freeze..done. Поставки 116/138 обязаны обновить CANON_JOBS/RABOTNIKI батареи 143, иначе y01 покраснеет на продукте.
- **С-6 (владелец, вне зоны).** Дерево `STRUCTURE.md` не перечисляет `mobile/scripts/select-ci-screens.cjs`, `ci-aggregate.cjs` и `mobile/ci-screens.json`.
- **С-7 [INFERENCE].** В одном прогоне 2 обрыва транспорта на 6 эмуляторных сессий (splash dark, start(1)), оба при параллельной работе двух раннеров. Это довод за исполнимый повтор в каждом работнике и вход для §Скорости (first-attempt red/recovered).

## НЕ проверено

- Ночной `schedule` и `workflow_dispatch` на RC-SHA живьём: workflow ещё не на main. Поэтому живьём не видели, как `mobile-regression-signal` краснеет и зеленеет и публикует маркер, и не видели freshness-монитор станции (ПРЕДПОСЫЛКА).
- Живые PR «локальный», «ошибка карты» и окно full-shadow (§Порядок п.4). Живой прогон был только full-set (COMMON_CHANGE).
- Кадры экранов глазами: предмет — оркестрация CI, экранный дифф отсутствует; кадры экранов судят их собственные контракты.
- Батареи соседей 995/139/141 `--stabs` в этом вызове не запускались.
- `npm run doctor` локально не запускался; в живом quality он success.
- Исполнение Б-1 на настоящем эмуляторе с принудительным обрывом: доказано replay-ем реального тела плюс живым логом attempt 1.
