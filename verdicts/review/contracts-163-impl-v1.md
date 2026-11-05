accept
OBJECT=78f385fea37ba7d49e46f7ea6bed7c80c7fda3de
КЛАСС=КОДОВЫЙ (РИСКОВЫЙ: required android-e2e, health/ПД)
СУД: repo=dev-harness (контракт frozen/contracts/163/1) + Complior-mob; предмет=163; фаза=реализация, этап A (перед слиянием в Complior-mob); роль=reviewer; сессия=Rev163; модель-план=audit → @opus (config/agent_models.json:65-68); модель-факт=anthropic/claude-opus-5-5; вызов=1
НЕЗАВИСИМОСТЬ: автор MiniMax-M3 (Impl163b, fallback 0); адверсарий openai-codex/gpt-5.6-terra (Adv163, accept); судья — Anthropic. Три разных семейства, судьи на двух вендорах.
НАХОДКИ: .review/2026-11-05-63.md. Копия: /tmp/dev-harness-verify/Rev163/review-files/.review/2026-11-05-63.md. Там 3 условия ленда У-1..У-3 (не implementer) и 7 советов С-1..С-7.

## Вердикт

`accept` относится к OBJECT как к реализации этапа A:
- дифф в зоне, один атомарный коммит implementer;
- 15 непрозрачных шагов перенесены, паритет 22 → 7 без новых исключений;
- 123 побайтово тот же;
- своей дифференциальной мерой поведение равно базе на 41 из 43 входов. Два расхождения — краевой
  вход `.node-version` (С-1, совет);
- пять красных клеток frozen 143/2 своей мерой сведены к форме и позиции пина, без регрессии поведения.

Блокирующих находок implementer нет.

**accept НЕ разрешает ленд в main Complior-mob, пока не выполнены условия.** Их закрывает не
implementer:
- **У-1** — живой CI на sha PR. Строка A прямо требует, чтобы «живой mobile CI подтверждал
  digest/outputs». `npm` на self-hosted раннере до setup-node не доказан ничем, кроме живого
  прогона. Отказ здесь fail-closed;
- **У-2** — решение о букве «version gate переносится только вместе с 991 v3»;
- **У-3** — 143 v3 до закрытия строки A. До 143/3 шаг станции не переключать на `--repo`.

## Сырые замеры (своя мера; копии в /tmp/dev-harness-verify/Rev163/, удалены после прогона)

Клоны: `git clone --shared /tmp/dev-harness-verify/Impl163/mob` →
- `Rev163/mob` @ `78f385fe`;
- `Rev163/base` @ `575f16a1acca8f074494d24b87db501e83b0367d`.

`wip/163/implementer` = OBJECT, зеркало в .git харнесса есть (`cat-file -t` → commit). Харнесс
`d0b673a0` (HEAD = origin/main). Фикстуры 163/143/991/141/139 побайтово равны своим
frozen-тегам (`git diff --stat frozen/contracts/<N>/<v> HEAD -- fixtures/...` пуст).

| # | команда | rc | вывод (сырой, сокращён только повтор) |
|---|---|---|---|
| 0 | `bash scripts/check_no_leak.sh --check /home/harness/dev-harness` | 0 | `основной чекаут чист` |
| 1 | `git log --format='%h %an %s' 575f16a1..78f385fe` | 0 | 1 коммит, `78f385f implementer 163 (этап A): перенос 15 непрозрачных шагов…`; автор и коммитер `implementer <implementer@dev-harness.local>` |
| 2 | `git diff --shortstat 575f16a1 78f385fe` | 0 | `10 files changed, 197 insertions(+), 155 deletions(-)` |
| 3 | `git diff --quiet 575f16a1 78f385fe -- .harness/registry/ci_parity_exceptions.txt` | **0** | исключения не менялись |
| 4 | `python3 fixtures/workshop_project/revizija_ci_mob_163/probe.py --repo Rev163/mob` | **1** | `DOLG_NE_SNJAT` · `LANE_NE_PODKLIUCHEN` · `NET_RANNERA` · `PARITET_RC_1: workflow-команд: 158 · скриптов в приёмке: 10 · объявленных исключений: 92 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 7` |
| 4б | то же `--repo Rev163/base` | 1 | те же 3 + `NET_LANE_V_WORKFLOW_mobile.yml` · `NET_LANE_V_WORKFLOW_mobile-cloud-e2e.yml` · `PARITET_RC_1: workflow-команд: 143 · скриптов в приёмке: 4 · … 92 · … расхождений: 22` |
| 5 | `… probe.py --model` | 0 | — |
| 6 | `… probe.py --stabs` | 0 | 9 строк `empty-lane: BATAREJA_NE_VYZVANA_quality` … `no-version-cloud: MAESTRO_VERSION_GATE_PROPUShCHEN_e2e-cloud`; `контроль зелёный; стабов 9, непойманных 0` |
| 7 | `bash scripts/verify_ci_parity.sh Rev163/mob` | 1 | 7×FAIL (mobile.yml:60 heredoc, :87 обратные кавычки, :412/:572/:782/:1028/:1190 `$(...)`); `workflow-команд: 158 · скриптов в приёмке: 10 · объявленных исключений: 92 · … расхождений: 7` |
| 7б | то же на базе | 1 | 22×FAIL; `workflow-команд: 143 · скриптов в приёмке: 4 · объявленных исключений: 92 · … расхождений: 22` |
| 8 | свой маппер FAIL→шаг + сверка с долгом (python, обе стороны) | 0 | база: 22 FAIL = 22 строки долга (`debt==fails: True`); OBJECT: 7 = 7 (`True`), симметрическая разность пуста. Остаток 7: «Выбор экранов», «Выходы выбора», «Инвентаризация пачек» (B), «117 splash» и «108 start» (C), «135 first-run» и «118 erstinformation» (D). Ушли ровно 15: Check Maestro ×2, HEAD, Node, Идентичность сборки, APK-digest ×5, Идентичность работника ×5 |
| 9 | sha256 сырого блока шага `123 сверка кадров с макетом (scripts/sverka_maketa.py)` + разобранного шага (python) | 0 | база `27e7ff0345baf7bc…`, OBJECT `27e7ff0345baf7bc…` (5 строк); разобранный `6bda350f…` = `6bda350f…`; hunk-ов с «123 сверка» в диффе нет |
| 10 | `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo Rev163/mob` | **1** | `клеток 80, зелёных 75, красных 5`: a17 (`rc 254 без имени APK_DIGEST_RASKHOZHDENIE: npm error code ENOENT … /tmp/package.json`), y11 (`e2e-splash не сверяет digest до установки`), y19 (`build-apk: шаг 1 не сверяет фактический HEAD с $GITHUB_SHA … (позиция 1)`), y20 (`шаг идентичности e2e-start rc=254`), i06 (агрегат y11+y19) |
| 10б | то же на базе | 0 | `клеток 80, зелёных 80, красных 0` |
| 11 | `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo` (свой счётчик CASE) | 0 / 0 | OBJECT 46 CASE `ok`, база 46 CASE `ok` (у Adv163 «41» — С-6) |
| 12 | `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --repo` | 0 / 0 | 42 CASE `ok` на обеих сторонах |
| 13 | `python3 .harness/fixtures/workshop_project/pilot_995/pins_probe.py --repo .` (H-пин продукта `b9b4c66f`, копия как в CI) | 0 / 0 | `995 pins/B5: rc=0 …`, `995 pins/B3: rc=0 release step задаёт mode явно` на обеих сторонах |
| 14 | `cd mobile && npm run typecheck` (после `npm ci --ignore-scripts` в клоне) | 0 / 0 | `tsc --noEmit -p src/lib/faden/tsconfig.json` на OBJECT и базе |
| 15 | `cd mobile && npm run lint` (дерево как есть) | 1 / 1 | 17 строк `file outside allowed location/type`, на обеих сторонах одно множество (`identical sets: True`). Поимённо: `mobile/e2e-erstinformation/{batareja/proverka_proiskhozdenija.py, batareja/red_ekrana.sh, e2e.sh, ekran.json, kadry.json, katalog_kopii.json, kontrakt.md, spec_api.json}` (8), `mobile/e2e-first-run/{те же 8}` (8), `mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh` (1). Падает `check-structure.cjs`; до `eslint .` дело не доходит |
| 15б | lint в CI-раскладке: вынос `mobile/e2e-erstinformation`, `mobile/e2e-first-run`, `kompozicija.stand-in.sh` (как в шаге quality «Инвентаризация пачек … до lint»), затем `npm run lint` | **0 / 0** | `structure: OK (repository inventory; external trees excluded)`; `eslint . --max-warnings=0` прошёл, новый `check-node-version.cjs` в нём учтён |
| 16 | дифференциальный replay (`bash --noprofile --norc -eo pipefail`, тело базы из YAML 575f16a1 против `npm run ci:<lane>` OBJECT; подложки gh/maestro; сверка rc-класса, GITHUB_OUTPUT, файлов) | — | **43 входа: SAME 41, DIFF 2**. Подробно — §3 |
| 17 | семантическая инлайнизация `npm run ci:<lane>` → тело скрипта и `red_mob_ci_143.sh --repo` на копиях | — | inl1 78/2, inl2 78/2, **inl4 80/80 rc 0**, красный контроль inl3 77/3 (a17 поймал мутант). Подробно — §4 |
| 18 | `vkhod_static_probe.py --repo .` (H-пин `.harness117` 4ac99af9) | 1 / 1 | `UnboundLocalError … 'sign'` (`vkhod_static_probe.py:954`) одинаково на обеих сторонах — С-7, дифференциально нейтрально |

## 1. Область правки

`git diff --name-status 575f16a1 78f385fe`:
- `M .github/workflows/mobile-cloud-e2e.yml`;
- `M .github/workflows/mobile.yml`;
- `M .harness/registry/ci_parity_debt.txt`;
- `A` шесть файлов `mobile/scripts/{check-build-revision.sh, check-maestro-version.sh, check-node-version.cjs, ci-apk-artifact.sh, ci-build-identity.sh, ci-worker-identity.sh}` (все `100755`);
- `M package.json`.

Все 10 путей ⊆ ЗОНА implementer frozen 163/1 (`mobile/scripts/`, `package.json`, оба workflow,
`ci_parity_debt.txt`). Чужих путей 0. Нормативных документов в диффе нет (п.6). Файлов
проверок/фикстур implementer не трогал: OBJECT — продуктовый репозиторий, батареи живут в харнессе
и равны frozen-тегам (п.3). Коммит один, со ссылкой на предмет (п.5). Объём совпадает с заявленным:
10 файлов, +197/−155. Шаг 123 байт-в-байт (замер 9). `ci_parity_exceptions.txt` не менялся (замер 3).
Пересечения 011/015 (package.json получает только `ci:*`): добавлены ровно 6 ключей `ci:*`,
4 прежних не тронуты. Пересечение 151: шаги 151 в диффе не встречаются.

## 2. Сырой вывод своей мерой

Таблица выше; каждое число получено своей командой, а не чтением отчёта. Что сходится с отчётом
Impl163 и вердиктом Adv163:
- 158/10/92/7 против 143/4/92/22;
- 80/75/5 поимённо;
- 17 lint-строк, одно множество;
- typecheck rc 0.

Где своя мера разошлась:
- Adv163 насчитал 41 CASE у 141, своих 46 (С-6);
- отчёт Impl163 называет шаги «не тронутыми по env/working-directory», структурный дифф показывает
  добавленные `env:` ×5 и `working-directory` ×2 (С-2).

`W --repo` на этапе A по контракту остаётся красным (`DOLG_NE_SNJAT`/`LANE_NE_PODKLIUCHEN`/
`NET_RANNERA`/`PARITET_RC_1`). Своя мера подтверждает: оба `NET_LANE_V_WORKFLOW_*` базы ушли
именно потому, что в обоих workflow появился однострочный `npm run ci:<lane>`. Прямого вызова
раннера в дереве 0 (`NPM_MARSHRUT_*` в выводе нет).

Lint. 17 предсуществующих строк (замер 15) порождает `mobile/scripts/check-structure.cjs`, ещё до
`eslint .`. В CI эти пачки и стенд 118 выносятся шагом quality до lint. В CI-раскладке lint rc 0
на обеих сторонах, eslint полностью прошёл по OBJECT (замер 15б). Правка lint не ломает.

## 3. Проверка не подогнана под реализацию; смысловой дрейф

Структурный дифф (python, все атрибуты всех шагов и job; ложные пары безымянных `- run:` отброшены
сверкой с текстовым диффом). Изменилось ровно следующее:
- `run` 15 шагов → `npm run ci:<lane>`;
- `env: {IMJA_ARTEFAKTA, RUN_ID}` добавлен в 5 шагов «Идентичность прогона работника»
  (замена `${{ needs.build-apk.outputs.* }}` из тела);
- `working-directory: ${{ github.workspace }}` добавлен в 2 шага `Check Maestro version`
  (cwd с корневым package.json; на базе default `mobile` — для `maestro --version` безразлично);
- порядок шагов в build-apk: Изоляция ↔ HEAD;
- порядок шагов в e2e-pilot: Изоляция поднята с позиции 4 (после H-checkout) на позицию 1.

Не изменилось:
- `if`/`needs`/`outputs`/`runs-on`/`timeout-minutes`/`concurrency`/`on` всех job;
- порядок job;
- `id: ident`/`id: rehearsal_version`;
- `env` шагов APK-digest.

Дифференциальный replay (замер 16, 43 входа):
- **Version gate, обе ветви** (station e2e-pilot и cloud android-e2e-cloud × {2.11.0, 2.10.0, maestro
  отсутствует, 2.11.0-beta}): 8/8 SAME. 2.11.0 → rc 0; остальные → rc 1 с `MAESTRO_VERSION_MISMATCH`
  на обеих сторонах.
- **HEAD == GITHUB_SHA:** честный sha → 0/0; чужой → 1/1, у OBJECT добавлено имя
  `HEAD_NE_SOVPAL_D_S_GITHUB_SHA`.
- **Идентичность сборки:** APK есть → rc 0/0, GITHUB_OUTPUT и `build-identichnost.txt` (без строки
  времени) равны; APK нет → 1/1.
  `${{ github.run_id|sha|run_attempt }}` → `$GITHUB_RUN_ID|$GITHUB_SHA|$GITHUB_RUN_ATTEMPT`:
  значения по определению Actions те же.
- **APK-digest до установки, каждый из 5 работников** × {верный, чужой APK, пустой digest}: 15/15 SAME.
  Чужой → rc 1 + `APK_DIGEST_RASKHOZHDENIE`, APK не разложен (хеш файла установки отсутствует на
  обеих сторонах). Пустой → rc 1. Порядок «скачать → сверить → `cp`» сохранён.
- **Идентичность работника** × {честные outputs, пустые outputs}: 10/10 SAME, GITHUB_OUTPUT побайтно равен.
- **Node-version:** 4/6 SAME, **2 DIFF** — пробел или CR в `.node-version` (база rc 1, OBJECT rc 0).
  Причина: `.trim()` вместо семантики `$(cat …)` (С-1, совет). setup-node читает тот же файл, ложной
  зелени required-гейта нет.

`set -e`/`pipefail`. Тела в YAML исполнялись default-shell Actions `bash -e -o pipefail`. Все
шесть скриптов несут `set -euo pipefail`. `-u` новое, но каждая читаемая переменная задана в
YAML-`env` или по умолчанию Actions; ветвь «пустое значение» replay прогнал (пустой digest и
пустые outputs ведут себя как на базе).

Проба «Изоляция раннера». Шаг `npm run ci:*` исполняет `package.json` и скрипт из дерева PR — по
определению `MARKER_KODA_PR` 143/2 это «код PR». Значит, y24 требует изоляцию ДО него. Перенос выше
корректен: буква `test ! -e /home/harness/.ssh && test ! -e /home/harness/dev-harness`
та же, в каждой job по одному шагу. В e2e-pilot проба стала строго раньше, ни один шаг между
checkout и пробой не исполняется.

Цена — конфликт с y19 frozen 143/2. y19 требует HEAD-сверку на позиции 1, а при HEAD через
`npm run` y19 и y24 одновременно невыполнимы. Implementer выбрал y24 (безопасность хоста).
Согласен, но разрешить это обязан 143 v3 (У-3).

Отдельно — самоссылка: HEAD-проверка теперь читает проверяемое дерево (С-3). Перенос предписан
строкой A, защиту несут структурные ограничения позиции 0, на OBJECT они зелёны (inl4).

## 4. Frozen 143/2: пять красных клеток — ожидаемое следствие, не регрессия

Своя мера (замер 17): копия OBJECT без `.git`, где каждый `run: npm run ci:<lane>` заменён телом
скрипта, на который `package.json` отображает lane. Для шага `id: ident` env шага материализован
как `export` — y20 не применяет env шага, а GitHub применяет.

| вариант | вывод `red_mob_ci_143.sh --repo` | что доказывает |
|---|---|---|
| inl1: только инлайн | 80/78/2 (y19, i06) | a17, y11, y20 краснели ТОЛЬКО от косвенности `npm run` (нет package.json в песочнице, литерал в тексте job) |
| inl2: + HEAD обратно на позицию 1 | 80/78/2 (y19, i06) | y19 пинует ещё и форму строки: `startswith("test ")`, а скрипт пишет `if ! test …` |
| inl4: + та же сверка формой `test "$(git rev-parse HEAD)" = "$GITHUB_SHA" \|\| { echo HEAD_NE_SOVPAL…; exit 1; }` | **80/80/0, rc 0** | содержимое скриптов OBJECT удовлетворяет всем 80 инвариантам 143/2, включая остаток y19 (второй checkout, алфавит действий, git-мутации, outputs работников, checkout агрегатов) и поведенческие a17/y20 |
| inl3: inl2 + мутант `if false && [ "$got" != … ]` в ci-apk-artifact.sh | 80/77/3 (+**a17**: `e2e-splash: шаг digest прошёл с подложным APK (rc 0)`) | мера краснеет на сломанной реализации (красное предъявлено) |

Вывод: регрессии поведения нет. Пять клеток — инлайн-пины тел и позиции, которые этап A по
контракту обязан сломать. 163 frozen-текст не правит; v+1 станции 141/118/143/991 — работа харнесса
в окне (решение владельца № 6). Это **не блок implementer**.

Что нужно харнессу — перепин **143/3**:
- y11/a17/y20 судят lane-маршрут replay `npm run ci:*` с корневым package.json и `mobile/scripts/`
  в песочнице;
- y20 применяет env шага;
- y19 принимает HEAD-сверку через lane (или 143 v3 оставляет её литералом — С-3) и согласует
  позицию с y24;
- приёмка 143/3 — 80/80 на OBJECT (своя мера inl4 показывает, что это достижимо без правки OBJECT).

Когда:
- **до закрытия строки A**: строка A сама зовёт `red_mob_ci_143.sh --repo R` как подтверждение
  digest/outputs;
- **в любом случае до приёмки B** (B/C/D и критерий 4 зовут ту же команду);
- до переключения шага станции на `--repo`.

Влияние на required-гейты сейчас:
- **CI Complior-mob 143 не исполняет**: в `.github/` моба 0 вхождений `mob_ci_143`/
  `obryv_adb_diagnostika_141`/`revizija_ci_mob_163`/`rehearsal_991`. Там исполняются 995/999/108/111/
  117/151/123/135/118 — их пробы, читающие workflow (`pins_probe.py` 995), на OBJECT зелёны (замер 13);
- **CI станции** зовёт 143 только `--stabs` (`registry/ci-steps.tsv:139`) — модель, продукт не читается.

Значит, ленд PR моба при красном 143/2 required-гейт станции СЕЙЧАС не краснит. Красный остаётся в
батарее харнесса и в приёмочных командах контракта. Опасное место — запланированное в шапке
`red_mob_ci_143.sh:4-8` переключение шага станции на `--repo <продукт>`: до 143/3 оно даст красный
CI станции (У-3).

## 5. Граница

- Этапы B–F не сделаны, это объявлено (`run-mobile-ci.cjs` отсутствует → `NET_RANNERA`/
  `LANE_NE_PODKLIUCHEN` ожидаемы) — не блок.
- Push не выполнен: OBJECT только в одноразовом клоне Impl163 и зеркале .git харнесса.
- Долг: `ДО: 2026-11-18` не тронут, скрытого продления нет. Записей 7, и это ровно 7 FAIL паритета
  (замер 8; правило храповика `check_precision_gate.sh:530-538` сравнивает «файл: причина» с
  количеством — 1 heredoc, 1 обратные кавычки, 5 `$(...)` в CI и в долге). Усечение 22 → 7 сужает
  allowance: прежние 15 записей разрешали бы 15 новых непрозрачных шагов той же причины. Номера
  строк реальные.

Буква «version gate переносится только вместе с 991 v3» (строка A) против «Maestro-version ×2 …
перенесены» (та же строка) и задания Impl163, явно включившего gate. Implementer исполнил задание.
Ленд gate-переноса до 991 v3 — решение оркестратора/владельца (У-2, вопрос), не дефект OBJECT.

## ПРОВОДКА (контракт 038)

`ПРОВОДКА: guard=fixtures/workshop_project/revizija_ci_mob_163/probe.py`. Файл существует, равен
frozen 163/1. Это барьер именно этого предмета: судит npm-маршрут, долг, исключения против
`baseline-exception-keys.sha256`, 123, version gate в модели. Что он ловит, видно по `--stabs`
9/9 (замер 6).

Строки 163 в `registry/ci-steps.tsv` нет (grep `revizija_ci_mob_163`: 0). По
ПРОВОДКА-ЭНФОРСМЕНТ подключение — дело оркестратора в окне freeze..done, для реализации этапа A
это не требование.

Обоснование энфорсмента (CI-проверка — чистый enforcement, не поведенческая норма 029-класса)
честное: предмет — механизм CI, а не поведение агентов.

## Паразитная сложность (контракт 050)

Каждая строка — ответы на 5 вопросов: (1) свойство; (2) состояние; (3) сопряжённые файлы;
(4) глубина; (5) потребитель / повтор.

- **`ci-apk-artifact.sh`.**
  1. Строка A «APK ×5 … перенесены в ci-скрипты»; инвариант «digest до install».
  2. Нового состояния нет. Вход — env шага (`IMJA_ARTEFAKTA`, `ZHELANYJ_DIGEST`, `GH_TOKEN`)
     виден в YAML; выход — файл APK, как прежде.
  3. Правка правила digest: было 5 копий YAML, стало 1 файл (↓).
  4. Интерфейс — 3 env + rc + имя отказа; за ним скачивание, сверка, раскладка. Глубокий.
  5. Потребитель — `ci:apk-artifact` в 5 job, паритет. Логику дерева не повторяет.

  **ESSENTIAL.**
- **`ci-worker-identity.sh`.**
  1. «worker-identity ×5», outputs для агрегата.
  2. Вход env `IMJA_ARTEFAKTA`, `RUN_ID` (новые в YAML шага, явные); выход GITHUB_OUTPUT, как прежде.
  3. 5 → 1 (↓).
  4. 2 env → 3 outputs; интерфейс мелкий, но и работа мелкая. Более простой формы того же
     свойства, проходящей «КАЖДЫЙ lane-вызов — `npm run ci:<lane>`», нет.
  5. `ci:worker-identity` ×5, агрегат через needs.

  **ESSENTIAL.**
- **`check-maestro-version.sh`.**
  1. «Maestro-version ×2», gate обязателен в обеих ветвях.
  2. Состояния нет.
  3. 2 → 1 (↓).
  4. 0 env, rc + имя.
  5. `ci:maestro-version` в station и cloud.

  Повтор: в модели 163 тот же gate живёт под именем `ci-maestro-version.sh` (С-5) — расхождение
  имени, не второй механизм. **ESSENTIAL.**
- **`check-build-revision.sh`.**
  1. «HEAD … перенесены».
  2. Состояния нет; вход `GITHUB_SHA` по умолчанию Actions.
  3. 1 → 1.
  4. rc + имя.
  5. `ci:build-revision`.

  **ESSENTIAL** (самоссылка — С-3, вопрос к 143 v3).
- **`check-node-version.cjs`.**
  1. «node … перенесены»; решение владельца № 1 «node `.cjs`».
  2. Состояния нет.
  3. 1 → 1.
  4. rc + имя.
  5. `ci:node-version`.

  **ESSENTIAL**; дрейф `.trim()` — С-1, совет: более простая форма `.replace(/\n+$/, '')` проходит
  те же строки.
- **`ci-build-identity.sh`.**
  1. «build-identity … перенесены», «outputs сохранены».
  2. Пишет `mobile/build-identichnost.txt` и GITHUB_OUTPUT — как прежнее тело, явно в комментарии.
  3. 1 → 1.
  4. 0 явных env, 3 outputs + файл.
  5. `ci:build-identity`, работники и агрегат через needs.

  **ESSENTIAL.**
- **6 ключей `ci:*` в корневом package.json.**
  1. «корневой package.json объявляет `ci:*`; КАЖДЫЙ lane-вызов — `npm run ci:<lane>`».
  2. Состояния нет.
  3. Правка lane: скрипт +, при переименовании, ключ.
  4. —
  5. Паритет (скриптов в приёмке 4 → 10) и `NPM_MARSHRUT`-клетка 163.

  **ESSENTIAL.** На этапе E ключи переводятся на `run-mobile-ci.cjs --lane`. Форма «один ключ —
  один скрипт» временная, но строку A проходит только так.
- **`ci_parity_debt.txt` (усечение).** Новый артефакт не вводится; состояние уменьшено и явное.

Блокирующих ACCIDENTAL нет.

## СВЕРКА-СТАНДАРТОВ

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` Complior-mob @ OBJECT не объявляет документ
архитектуры и стандарт кода: grep `ARCHITECTURE|CODING-STANDARDS|STANDARDS` даёт 0 совпадений, есть
только `docs/ux/`, `docs/design/`, `docs/context/`. Механические проверки продукта, своя мера:
- structure/eslint в CI-раскладке: rc 0 (замер 15б);
- typecheck: rc 0 (замер 14).

Мобильный экран дифф не затрагивает — сверка кадров с макетом не требуется. Шаг 123 побайтово тот же.

## Быстрый-процесс (roles/critic.md)

Кандидат — неизменный SHA `78f385fe`, набор обязательств — строка A frozen 163/1 плюс
§Приёмочный критерий п.2–3 (`--model`, `--stabs`) и п.1 в форме этапа (`--repo` rc 1 с названными
причинами). Вызов 1 из ≤1+1. Любая правка поведения, критерия или границы риска (в том числе С-1)
делает этот accept неприменимым к новому кандидату. Тогда нужен scoped-повтор по затронутому пути:
дифф-replay node-version и `red_mob_ci_143.sh --repo` на inl4-эквиваленте.
