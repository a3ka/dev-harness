accept
OBJECT=2c512b01abfa190007bdc934b77661742ce6cf98
СУД: repo=Complior-mob (PR #136, ветка cmp-mob-143/cutover, head 2c512b01); предмет=143 mob-ci-razdelenie; фаза=суд реализации перед слиянием (cutover), scoped-повтор после FAIL Rev143 Б-1; роль=reviewer; вызов=2 (scoped, предельный); сессия=Rev143b; модель-факт=anthropic/claude-opus-5-5; харнесс=91090bb8fea6f60e9f2c4a991b7c5e24eaf80c6a (Fix143d, ветка wip/143/architect — НЕ main, см. С-8); frozen/contracts/143/1 = 3d27e964d980aa6c6a4ae818f4dbd51a11e0041d; предыдущие: Rev143 FAIL (impl-v1, Б-1), Adv143b ACCEPT (2279c4a8), Crit143z FAIL y23/y24 — остаток, принят словом владельца 29.10 ~22:00 и Arb143r п.5
Находки reslop: `/tmp/dev-harness-verify/Rev143b/review/2026-10-29-02.md` (status: done).

## Итог

Принимаю. Б-1 закрыт, и закрыт исполнением, а не формой.

- В `zapusk108` больше нет `set -e` перед `return "$rc"`.
- Реальное тело шага «108 start» из `2c512b01` на обрыве транспорта печатает `ДИАГНОСТИКА 108` и `ПОВТОР:`, вызывает Maestro ровно два раза и при успехе повтора даёт rc 0.
- Продуктовый провал даёт один вызов и rc 1.
- Тот же replay на родителе `2279c4a8` остаётся красным (rc 1, один вызов). Значит, репро различает сломанную и исправленную форму.

Пять пунктов слова владельца (а)–(д) проверены в реальном `mobile.yml` глазами и разбором YAML: ни одного нарушения нет.

Живой CI на head прошёл зелёным с первой попытки (`run_attempt=1`), ручного re-run не было.

Блокеров нет. Есть два условия для оркестратора:
1. **До слияния:** Fix143d в main харнесса (С-8).
2. **Сообщение об аномалии adb:** следы `device offline` в живом прогоне ЕСТЬ. Все они на `station-complior` и все пережиты внутри job (С-7).

## 1. Область правки, байты, батарея (свои прогоны)

```
$ git diff 2279c4a8 2c512b01 --stat                       # rc 0
 .github/workflows/mobile.yml | 37 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)
$ git rev-parse origin/main; git merge-base origin/main HEAD    # оба 1a99902a036cdfc1b109f700c84bf94c9bbb71f5
$ git diff --name-status 1a99902a 2c512b01
D .github/workflows/mobile-e2e-retry.yml
M .github/workflows/mobile.yml
A mobile/ci-screens.json
A mobile/scripts/ci-aggregate.cjs
A mobile/scripts/select-ci-screens.cjs
M mobile/structure-policy.json
```
Шесть путей диффа точно совпадают с `ЗОНА implementer` из frozen-блоба (`git show 3d27e964:contracts/143-mob-ci-razdelenie.md:141`).
- Коммит `2c512b0` — `implementer <implementer@dev-harness.local>`, сообщение «143: модель Fix143d …», только `mobile.yml`.
- Норма не тронута: `git diff 3d27e964 91090bb8 -- contracts/143-mob-ci-razdelenie.md` пуст; `check_contract_frozen.sh .` → `ok contracts/143-mob-ci-razdelenie.md — заморожен v1, блоб совпадает побайтово`, rc 0.
- Батарею Fix143d менял только `architect`: коммит `91090bb8`, 12 путей в `fixtures/workshop_project/mob_ci_143/`.

Байты модели и продукта:
```
$ sha256sum .github/workflows/mobile.yml   → 401071f04359000258dc3f4c34f0c27374f41762473f233e7646370105f5f896 (продукт = модель 91090bb8)
$ cmp <4 файла> harness/fixtures/workshop_project/mob_ci_143/model/<…>   → cmp OK ×4
  (.github/workflows/mobile.yml, mobile/ci-screens.json, mobile/scripts/select-ci-screens.cjs, mobile/scripts/ci-aggregate.cjs)
```

Батарея на `91090bb8` (логи лежат в `/tmp/dev-harness-verify/Rev143b/logs/bat-*.log`):
```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Rev143b/mob   → rc 0  «клеток 71, зелёных 71, красных 0»
$ … --model    → rc 0  «клеток 71, зелёных 71, красных 0»
$ … --stabs    → rc 0  «клеток 71, зелёных 71, красных 0» / «стабов 52, привязок 68, непойманных 0»
$ … (без флагов) → rc 1  71 строка «КЛЕТКА … SUBJECT_ABSENT»
```
Дубль своей мерой (python по `source.json`):
- kletki 71 = s25 + y24 + a17 + f4 + p1;
- `stab_vhod` — 52 ключа и 68 привязок; `ls stabs/ | grep -c '^stab_.*\.py$'` = 52.

Прирост от 073e2929 — +9 стабов и +9 привязок:
- 8 стабов → `y23-ispolnenie-povtora`/`y24-izoljacija-ranera`;
- 1 стаб (`stab_y_run_bool`) → `p01-P-nabor`.

Он совпадает с `git diff 073e2929 91090bb8 -- source.json`.

## 2. Б-1 ЗАКРЫТ ИСПОЛНЕНИЕМ

`/tmp/dev-harness-verify/Rev143b/mut/replay_start_retry.py` — это репро Rev143 без режима `--fixed`. Оно исполняет РЕАЛЬНОЕ тело шага «108 start» из `mobile.yml` под `bash -e`, как раннер, с подложными adb/emulator/avdmanager/maestro:
```
MODE --offline       rc=0  ДИАГНОСТИКА 108 … device offline | ПОВТОР: обрыв adb-транспорта эмулятора 108 — перезапуск и повтор набора   maestro-вызовов: 2
MODE --diedexc       rc=0  ДИАГНОСТИКА 108 … DeviceServerDiedException | ПОВТОР: …                                                  maestro-вызовов: 2
MODE --product-fail  rc=1  ДИАГНОСТИКА 108 (без ПОВТОР)                                                                              maestro-вызовов: 1
MODE --both-offline  rc=1  ДИАГНОСТИКА + ПОВТОР, третьей попытки нет                                                                 maestro-вызовов: 2
контроль: тот же --offline на mobile.yml родителя 2279c4a8 → rc=1, stderr <пусто>, maestro-вызовов 1 (мёртвая ветка воспроизведена)
```

Другие экранные job с повтором (И-6, «один владелец на экран»). Скрипт `/tmp/dev-harness-verify/Rev143b/mut/replay_screens_retry.py` исполняет реальные тела 117/135/118. У 135 и 118 подложен валидатор 132, у 117 — maestro:
```
117 --offline rc=0 вызовов 3 (dark×2 + light×1), ПОВТОР 1   | --product-fail rc=1 вызовов 1, ПОВТОР 0, «ПОВТОРЫ ИСЧЕРПАНЫ»
117 --diedexc rc=0 вызовов 3, ПОВТОР 1                       | --both-offline rc=1 вызовов 2, ПОВТОР 1
135 --offline rc=0 вызовов 2, ДИАГНОСТИКА, ПОВТОР 1, proverka 1 | --product-fail rc=1 вызовов 1, ПОВТОР 0 | --both-offline rc=1 вызовов 2
118 --offline rc=0 вызовов 2, ДИАГНОСТИКА, ПОВТОР 1, proverka 1 | --product-fail rc=1 вызовов 1, ПОВТОР 0 | --both-offline rc=1 вызовов 2
135/118 --diedexc rc=0 вызовов 2
```
- **995.** Повтор живёт в `mobile/scripts/ci-e2e.sh`. Это зона 995, и `git diff 1a99902a 2c512b01 -- mobile/scripts/ci-e2e.sh` пуст. `zapusk_nabora` (`:163-172`) кладёт rc в глобальный `NABOR_RC` и завершается на `set -e` с rc 0, так что мёртвой ветки нет. Живьём она исполнилась: `995 sobytie: RECOVERED … попытка 2 зелёная` (§4).
- **`set -e` перед `return "$rc"` во всём `mobile.yml`.** Поиск по `set [-+]e|return` и по всем функциям нашёл единственное место: `run_theme` у 117 (`:605`, `:621` → `:623`). Тело 117 перенесено побайтово по И-7, оно frozen 117/5. Функция вызывается только в `||`-контексте (`:629` `run_theme "$theme" || {…}`), а в нём errexit подавлен. Это видно на контроле языка: `f || echo` → `перехвачено rc=1`, `after-1`; вне контекста `f; rc=$?` → шаг умирает, rc 1. Ветка живая (replay выше и живой прогон §4). Клетку держит стаб `stab_y_povtor_vne_konteksta117` → y23. Это не FAIL, но буквально пункт не выполнен; оговорка — С-9.
- **Красный барьер предъявлен.** Мутант «`set -e` возвращён в `zapusk108`» на копии продукта даёт `W --repo` rc 1, «клеток 71, зелёных 70, красных 1», `КЛЕТКА y23-ispolnenie-povtora: e2e-start/обрыв: rc=1 … maestro-вызовов 1, канон 2 … КРАСНА` (`mut/residual_mut.py`, CASE m_dead).

## 3. ОБЯЗАТЕЛЬНЫЕ ПУНКТЫ СЛОВА ВЛАДЕЛЬЦА — реальный `mobile.yml` (глазами + `mut/audit_yaml.py`, `yaml.safe_load`)

**(а) Мёртвая ветка повтора — НЕТ.** Фрагмент `:1238-1276`: `zapusk108(){ …; set +e; maestro …; local rc=$?; <комментарий>; return "$rc"; }`. Вызов `set +e; zapusk108; rc=$?; set -e` → `if [ "$rc" -ne 0 ]` → ДИАГНОСТИКА → `grep -rqE "$KANON"` → ПОВТОР → `if ! boot108; then exit 1; fi` → второй `zapusk108` → `[ "$rc" -eq 0 ] || exit "$rc"`. Исполнимость доказана в §2.

**(б) Пропущенный или условный шаг повтора — НЕТ.**
- Состав шагов `e2e-start`: 0 checkout, 1 изоляция, 2 APK, 3 ident, 4 `108 start`, 5 upload (`if: always()`).
- Шаг повтора один, без `if:` и без `continue-on-error`; дубля-приманки с тем же телом нет.
- `continue-on-error` не встречается во всём файле ни у шага, ни у job; `defaults` = `{run: {working-directory: mobile}}`, `shell:` нигде не переопределён.
- Других обёрток нет: `.github/workflows/` = `mobile.yml` и `mobile-cloud-e2e.yml`. Второй файл только `workflow_dispatch`, по `1a99902a..2c512b01` не менялся, и обёрткой `mobile.yml` он не является. `mobile-e2e-retry.yml` удалён.
- Шаговые `if:` во всём файле — только `always()`: у upload-шагов, у cleanup pilot и у upload selection.

**(в) Изоляция с `if:`, иным условием или `continue-on-error` — НЕТ.** У всех 10 шагов «Изоляция раннера» ключи ровно `name/run`. Job-level `if` у e2e-* — это условие выбора экрана, не условие изоляции: когда job запущен, изоляция в нём исполняется.

**(г) Изоляция ВО ВСЕХ job с кодом PR — ДА, 10 из 10.** Команда везде побайтово `test ! -e /home/harness/.ssh && test ! -e /home/harness/dev-harness` (`<ISO-EXACT>` ×10). Порядок:

| job | шаг изоляции | первый шаг с кодом PR |
|---|---|---|
| select-screens | 1 | 2 `node select-ci-screens.cjs` |
| quality | 1 | 6 `npm ci` (3 — `cmp`, не исполнение) |
| build-apk | 2 | 3 `node -v` / 5 `npm ci` (1 — сверка HEAD) |
| e2e-splash | 1 | 4 maestro |
| e2e-first-run | 1 | 6 валидатор / maestro |
| e2e-erstinformation | 1 | 5 `npm ci`, 9 Jest |
| e2e-start | 1 | 4 maestro |
| e2e-pilot | 4 | 6/7 (ci-e2e.sh из PR); шаги 1-2 — inline `gh run download`/`sha256sum`, код репозитория не исполняют; место шага не менялось с 2279c4a8 |
| android-e2e | 1 | 2 `node ci-aggregate.cjs` |
| mobile-regression-signal | 1 | 2 `node ci-aggregate.cjs` |

Живьём (jobs API run 40978511510) шаг «Изоляция раннера» `success` в 9 исполненных job; signal — skipped (event pull_request).

**(д) Сверка `HEAD == GITHUB_SHA` в `build-apk` — без маскировки, до сборки.**
- Шаг 0 — `actions/checkout@v7 {persist-credentials: false, clean: true}`, без `ref`/`path`.
- Шаг 1 — ключи `name/run/working-directory`, `run == 'test "$(git rev-parse HEAD)" = "$GITHUB_SHA"'` побайтово.
- Нет `|| true`, `; true`, `|| echo`, `; exit 0`, `if:` и `continue-on-error`. Сравнения с собой нет: слева фактический HEAD дерева, справа env раннера.
- Порядок шагов: сверка (1) → изоляция (2) → node -v (3) → setup-node (4) → npm ci (5) → сборка (6). После шага 1 нет второго checkout и нет `git`/`checkout` в `run`; проверено перебором `run` шагов 2–8.

## 4. Живой CI на head

`gh pr view 136` → `headRefOid 2c512b01…, mergeStateStatus CLEAN, mergeable MERGEABLE`. `gh pr checks 136` → rc 0. Run `40978511510`: event `pull_request`, head_sha `2c512b01…`, **run_attempt 1**, conclusion `success`, 00:15:14–00:29:18Z.

| job | раннер | интервал (UTC) | длит. | итог |
|---|---|---|---|---|
| select-screens | station-complior | 00:15:16–00:15:28 | 12s | success, `VYBOROK 5 iz 5` |
| quality | station-complior-2 | 00:15:16–00:17:49 | 2m33 | success; Jest `15 passed / 149 passed` |
| build-apk | station-complior | 00:17:51–00:21:01 | 3m10 | success |
| e2e-splash | station-complior | 00:21:03–00:23:43 | 2m40 | success; dark `[Failed] (1s)` → `ПОВТОР: … темы dark` 00:22:10 → `[Passed] (13s)`; light Passed; KADR dark 0.783, light 0.782 OK |
| e2e-erstinformation | station-complior-2 | 00:21:03–00:24:38 | 3m35 | success; same-job Jest 149/149; KADR OK |
| e2e-start | station-complior | 00:23:45–00:25:22 | 1m37 | success; `[Passed] 108 start … (26s)` с первого вызова |
| e2e-first-run | station-complior-2 | 00:24:40–00:27:26 | 2m46 | success; 8 KADR OK, `SHABLON first-run-ekran OK` |
| e2e-pilot | station-complior | 00:25:24–00:29:09 | 3m45 | success; `995 sobytie: RECOVERED …`, `995 native rc=0 testcases=4 failed=0` |
| android-e2e | station-complior-2 | 00:29:10–00:29:17 | 7s | success, `AGREGAT_OK: selected=e2e-erstinformation,e2e-first-run,e2e-pilot,e2e-splash,e2e-start digest=b28b4cc92dee…` |
| mobile-regression-signal | — | — | — | skipped (pull_request) |

- **Сверка в `build-apk` исполнилась на head.** Лог: `HEAD is now at ba8247b Merge 2c512b01… into 1a99902a…`, затем `Run test "$(git rev-parse HEAD)" = "$GITHUB_SHA"` / `shell: /usr/bin/bash -e {0}`. Jobs API: шаг 3 «Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)» `success` в 00:17:55, раньше setup-node (00:17:55–00:18:03) и сборки (00:18:08). `git fetch origin pull/136/merge` → `ba8247b7…`, родители `1a99902a 2c512b01`. `ba8247b^{tree}` = `2c512b01^{tree}` = `git merge-tree --write-tree 2c512b01 1a99902a` = `36b9f732…`, то есть собрано дерево OBJECT.
- **Один APK.** Все 5 работников несут `IMJA_ARTEFAKTA: apk-40978511510-b28b4cc92dee` / `ZHELANYJ_DIGEST: b28b4cc92dee…`.
- **Аномалия adb — следы `device offline` в логах ЕСТЬ**, вопреки ожиданию задания. Сообщаю, как требует задание:
  - `e2e-splash` 00:22:09 — обрыв на тёмной теме, пережит повтором 117 внутри job;
  - `e2e-pilot` — обрыв попытки 1 пережит owned-restart 995 (`RECOVERED`);
  - `e2e-start` 00:25:13 — `Exception in thread "Thread-5" java.io.IOException: Command failed (host:transport:emulator-5568): device offline` в потоке закрытия сессии Maestro (`AndroidDriver.close → uninstallMaestroDriverApp`) ПОСЛЕ `1/1 Flow Passed`. rc шага 0, повтор не нужен. В артефакте `maestro-start-…-40978511510-1` (скачан, `grep -rnE` по сигнатурам) сигнатур нет.

  Все три — на `station-complior`. На `station-complior-2` (first-run, erstinformation) обрывов нет. Каждый job начинал с `* daemon not running; starting now at tcp:5037`, и раннер в конце убивал свой adb (`Terminate orphan process … (adb)`). [INFERENCE] Раз runner-2 при живом adb runner-1 видел «daemon not running», adb-серверы двух раннеров не общие. Обрывы — свойство эмуляторов на `station-complior`, а не пересечения раннеров. Сейчас с хоста `ps -eo … | grep adb/qemu` ничего не находит, оставшихся adb-серверов не видно.
- **Ручного re-run не было**: `run_attempt=1`, все required зелёные с первой попытки.
- Повтор 108 живьём не срабатывал, потому что 108 прошёл с первого вызова. Его исполнимость доказана replay-ем реального тела (§2). Живые повторы 117 и 995 в этом же прогоне показывают, что та же семья механизма на этих раннерах работает.

## 5. Остаток y19/y23/y24 — НЕ блок батареи (совет С-1/С-10)

Подтверждаю своей мерой (`mut/residual_mut.py`, мутанты в одноразовых копиях `git archive 2c512b01` → `W --repo`):
```
CASE m_dead              rc=1  y23 КРАСНА                 (честный барьер)
CASE m_dead_plus_decoy   rc=0  71/71  ← остаток y23: мёртвый настоящий шаг + честный дубль с if: ${{ false }}
CASE m_iso_removed_erst  rc=1  y24 КРАСНА                 (честный барьер)
CASE m_iso_if_schedule   rc=0  71/71  ← остаток y24: изоляция e2e-erstinformation с if: ${{ github.event_name == 'schedule' }}
CASE m_iso_coe           rc=1  y05 КРАСНА
CASE m_prov_or_true      rc=0  71/71  ← остаток y19: сверка «… || true»
CASE m_prov_if_false     rc=0  71/71  ← остаток y19: сверка с if: ${{ false }}
```
В реальном `mobile.yml` ни одной из этих форм нет (пункты 3а–3д). Остаток принят словом владельца 29.10 ~22:00 и Arb143r п.5 (подтверждено 30.10 ~00:20). Против принятого он не блокирует.

## 6. Продуктовые гейты (копия `mob-gates` @ 2c512b01, Node 24.21.0 из toolcache = `.node-version`)

```
npm ci --no-audit --no-fund                     → rc 0
reslop t -- npm test                            → exit 0  «Test Suites: 15 passed, 15 total / Tests: 149 passed, 149 total»
reslop t -- npm run typecheck                   → exit 0
reslop t -- npx tsc --noEmit  (mobile/tsconfig; в корне репо tsconfig нет)  → exit 0
npm run lint (CI-форма: вынесены .harness, mobile/e2e-first-run, mobile/e2e-erstinformation, kompozicija.stand-in.sh; .log reslop удалён)
                                                → rc 0  «structure: OK (repository inventory; external trees excluded)»
```
Пробы (одноразовая R = `git archive 2c512b01` + `.harness` = `git archive b9b4c66f`, как checkout quality):
- `cmp` pilot.test.tsx/source.json — OK;
- 995: `probe.py --check-frozen` rc 0; runtime, bundle, schema, frozen_matrix, transport, admission, stale, types, pins, admission_family, stale_table — 11× rc 0;
- 999: nav, ui, shell_static, copy — 4× rc 0.

Логи — `logs/p995-*.log`, `logs/p999-*.log`.

## 7. Мердж

Сливать merge-коммитом. Ruleset 25121366 (`allowed_merge_methods: [merge, squash]`, required `quality` + `android-e2e`, strict) разрешает оба способа, но squash склеил бы 6 коммитов предмета и merge с main. Так же требует и `AGENTS.md:26` продукта («ветка контракта с frozen-тегом — merge-commit, не squash», `gh pr merge --match-head-commit`). Ветка не позади main (merge-base = `origin/main` = `1a99902a`), `mergeStateStatus CLEAN`. Перед слиянием — условие С-8.

## ПРОВОДКА (контракт 038)

`bash scripts/check_provodka.sh . contracts/143-mob-ci-razdelenie.md` (на 91090bb8) → rc 1 «guard не подключён: fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh не вызывается…». Отложенность объявлена в §ПРОВОДКА: подключение — работа оркестратора в окне freeze..done, это не дефект implementer (С-5). Guard является барьером именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ обоснован: предмет — CI-оркестрация, не поведенческая норма.

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет только `STRUCTURE.md` (`:24`); `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` не объявлены. Дельта этого круга — только `mobile.yml`.
- `STRUCTURE.md:26` (`.github/workflows/ # mobile.yml: quality и android-e2e`) — соответствует: имена required не менялись.
- `AGENTS.md:25` (обязательные проверки `quality`, `android-e2e`) — соответствует (ruleset и job-имена).
- `AGENTS.md:26` (merge-commit для ветки контракта) — соответствует рекомендации §7.

## Паразитная сложность (контракт 050) — артефакты дельты 2279c4a8→2c512b01

**Шаг «Изоляция раннера» (+8 копий, итого 10).**
1. И-7 («переносятся … изоляция раннера») плюс С-3 Rev143: монолит охранял весь job, после разделения охрана нужна в каждом job.
2. Состояния нет. Проверка видна в логе как отдельный шаг, rc явный.
3. При правке проверки меняются 10 мест в 1 файле, раньше было 2. Это следствие отказа от матрицы (§Frontier) и явных job (И-3), а модель держится побайтово (cmp).
4. Двухстрочный шаг без интерфейса.
5. Потребитель — клетка y24 и required job.

Итог — ESSENTIAL. Более простой формы, проходящей y24 при явных job, нет: composite-action вводит второй каталог и конвенцию, которых в дереве нет.

**Правка `zapusk108` (−`set -e`, +3 строки комментария).**
1. И-6.
2. Состояния нет.
3. Меняется 1 место.
4. —
5. Потребители — y23 и e2e-start.

Итог — ESSENTIAL. Сложность уменьшилась.

ACCIDENTAL-находок нет.

## Блокеры

Нет. Б-1 Rev143 закрыт (§2).

## Советы и условия (не блокируют accept реализации)

- **С-8 (оркестратор; УСЛОВИЕ ДО СЛИЯНИЯ И DONE).** Модель и батарея Fix143d (`91090bb8`) существуют только на `wip/143/architect` локального харнесса.
  - `git branch -a --contains 91090bb8` → `wip/143/architect`; на `origin/main` и `main` (`e30229c8`) их нет.
  - В main модель `868b30e1…`, а не `401071f0…`. Задание называет харнесс «`91090bb8`/main», но это не так.
  - Батарея main против продукта: `red_mob_ci_143.sh --repo` (worktree `e30229c8`) → rc 1, «клеток 69, зелёных 68, красных 1 — КЛЕТКА a17-digest-do-ustanovki: полная цепочка e2e-start rc 1 без имени».

  Перед слиянием #136 Fix143d должен лечь в main харнесса. Иначе батарея предмета на main красна против влитого продукта, и подключение guard (С-5) сразу даст красное.
- **С-9 (к сведению; 117/v+1).** Буква «нет `set -e` перед `return "$rc"` во всём `mobile.yml`» не выполнена в `run_theme` 117 (`:605`, `:621` → `:623`). Тело frozen 117/5, перенос побайтовый (И-7). Ветка живая только благодаря `||`-контексту вызова (`:629`); это доказано replay-ем и живым ПОВТОРОМ dark в run 40978511510. Контекст держит стаб `stab_y_povtor_vne_konteksta117`. Хрупкость — при v+1 117.
- **С-7 (обновлено).** В run 40978511510 произошло 3 обрыва транспорта на 6 эмуляторных сессий, все на `station-complior`, все пережиты внутри job. Вход для §Скорости и для диагностики станции.
- **С-10 (= С-1, расширено).** Остаток y19/y23/y24 измерен своими мутантами (§5): `|| true`, `if: ${{ false }}` на сверке; честный дубль-приманка с `if: ${{ false }}` при мёртвом настоящем шаге; изоляция с `if: schedule`. Все дают 71/71 rc 0, реальный файл чист. Принято словом владельца и Arb143r п.5.
- С-4, С-5, С-6 из Rev143 остаются в силе («принято остатком», см. файл находок).

## НЕ проверено

- Живой повтор именно e2e-start на эмуляторе: в этом прогоне 108 прошёл с первого вызова. Исполнимость доказана replay-ем реального тела (§2) и живыми повторами 117 и 995 в том же прогоне.
- Ночной `schedule` и `workflow_dispatch` (`mobile-regression-signal`, маркер, freshness-монитор станции): workflow ещё не на main.
- Живые PR «локальный выбор» и «ошибка карты»: живой прогон был full-set (COMMON_CHANGE).
- `npm run doctor` локально: в живом quality он success.
- Батареи соседей 995/139/141 `--stabs` в этом вызове.
- Сетевые пространства adb-серверов двух раннеров — [INFERENCE] по логам, на хосте не исследовалось.
- Кадры экранов глазами: предмет — оркестрация CI, экранного диффа нет.
