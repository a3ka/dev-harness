FAIL
Ревьюер 109 (Rev109), OBJECT=0651df6bda472c3d2cc640eb5231b61baa329388 (Complior-back `cmp-bck-004/stend`, 16 коммитов поверх `origin/main` 0ed762b8). Контракт `frozen/contracts/109/3` (коммит a22dda58…), батарея `fixtures/workshop_project/stend_109/probe.py` (sha256 131ab363…, одинакова на пине и на HEAD харнесса).
Батарея зелёная (15/15 фактов, 53/53 REJECTED_EXACT), строка 4 стенда зелёная. Но required-lane `postgres` (`npm run test:integration`) на OBJECT даёт rc 1, а на базе — rc 0. Не выполнена приёмочная строка 5 контракта; CI-агрегат `required` будет красным.

## БЛОКЕР

### R1 — строка 5 (`npm run test:integration` → rc 0) не выполнена; required-lane `postgres` красный (класс: невыполненный критерий контракта)
- Фрагмент: `tests/integration/drill-measure.test.js:15`
  `const COLLECTOR = path.join(__dirname, '..', '..', 'scripts', 'drill-measure.js');`
  Это путь старой раскладки, файла `scripts/drill-measure.js` в дереве нет (`ls` → No such file). Коллектор лежит в `tests/tools/drill-measure.js`. Путь пришёл из коммита 5ff4cc5 (r9). Rebase-коммиты 15d8f6e/2a3c32a его не перевели.
- Наблюдение на OBJECT, native PG18 `postgres:18@sha256:74935e72…`, `COMPLIOR_TEST_PG_ADMIN_URL` на 127.0.0.1:55439:
  - `npm run -s test:integration` → **rc 1**: tests 44, pass 40, fail 4. Падают все 4 drill-теста, ассерт `валидный вход — rc 0: 1 !== 0`.
  - `python3 tests/tools/run_backend_ci.py --lane postgres` → **rc 1** («итог: отказ — postgres»).
- База `0ed762b8` (одноразовая копия, тот же PG): `--lane postgres` → **rc 0**, test:integration PASS. Регресс внесён диффом 109.
- Правка (зона implementer, `tests/integration/`): строка 15 → `path.join(__dirname, '..', 'tools', 'drill-measure.js')`.
  Проверено на одноразовой копии:
  - до правки: `node --test tests/integration/drill-measure.test.js` → 0/4, rc 1;
  - после правки: 4/4, rc 0;
  - весь `npm run -s test:integration` после правки → 44/44, rc 0.
  После правки нужно пересчитать `FILES.sha256` штатным генератором.
- Батарея эту поломку не видит (см. Г1). Поэтому её зелёный цвет не доказывает строку 5.

## (а) Выход за зону — НЕТ
- `git diff --name-status origin/main..HEAD` — 11 путей, все ⊆ ЗОНЫ implementer (строка 67):
  - M: `.github/workflows/ci.yml`, `FILES.sha256`, `package.json`, `tests/tools/run_backend_ci.py`;
  - A: `compose.dev.yml`, `tests/helpers/harness.js`, `tests/integration/{drill-measure,harness-live,harness}.test.js`, `tests/tools/{drill-measure,role-bootstrap}.js`.
- Общие файлы, построчно:
  - `package.json`: одна добавленная строка `"drill:evidence": "node tests/tools/drill-measure.js"` и запятая. Ни один чужой скрипт не удалён.
  - `ci.yml`: новый job `stend109` (pinned actions, clone H на `frozen/contracts/109/3`, `--lane stend109`, upload-artifact). Единственная правка существующего: в `required.needs` добавлен `stend109`. Агрегат усилен, а не ослаблен; шаги 130/011/015/994/997/998 не тронуты.
  - `run_backend_ci.py`: добавлены константы `STEND109_PIN`/`STEND109_PROBE`, lane `stend109`, `stend109` в `LOCAL_ORDER`, ветвь `@stend109` и методы `stend109_checkout`/`stend109_probe`. Существующие лейны не изменены.
  - `FILES.sha256`: 4 изменённые и 7 новых строк, все по путям диффа.
- Стандарты 115 (`eslint.config.js`, `tests/standards/lint/`, `docs/CODING-STANDARDS.md`) в диффе отсутствуют. `npm run -s test:standards-lint` → rc 0 (7/7 ok).
- Атомарность: 16 коммитов, у каждого ссылка на 109, автор `implementer`.

## (б) Клетка `backend_lint_unused_const` — NOT_REJECTED не воспроизводится
- Что делает мутант: вставляет `const stend109LintUnused = 1;` перед единственным якорем `const SNAPSHOT_AXES = …` (`harness.js:56`).
- Чем его должен ловить гейт: `npm run -s lint`, правило eslint `no-unused-vars` (`eslint.config.js:26`).
- Три независимые меры:
  1. Вручную: `git archive HEAD | tar -x`, оверлей, симлинк `node_modules`, затем `npm run -s lint` → rc 1 (`56:7 error 'stend109LintUnused' … no-unused-vars`).
  2. Прямой вызов функций батареи (`backend_lint_fact(repo, Tree(repo))`) → `(True, rc 0)`; с оверлеем мутанта → `(False, lint rc=1 …)`.
  3. Полный прогон батареи: клетка `REJECTED_EXACT`, depends=`BACKEND_LINT_GUARD`.
- Сохранённый артефакт implementer (`/tmp/dev-harness-verify/Impl109/evidence-battery-r4-raw.json`) относится к старому прогону: repo `battery-r4`, пин lane `e6bb628…`. В нём 51 rejected / 1 blocked / NOOP `stend_ledger_rewritten`, а lint-клетка там тоже REJECTED.
- Итог: артефакта под заявление «52/53, одна NOT_REJECTED» нет. Дефекта ни пробы, ни продукта по этой клетке не найдено.
- Контракт требует 53/53 (строка 2). На OBJECT по моей мере это выполнено, поэтому клетка не блокирует.

## (в) Прогоны (OBJECT, одноразовые копии в /tmp/dev-harness-verify/Rev109/)

| Прогон | Результат |
|---|---|
| Пин lane | `git -C /home/harness/dev-harness rev-list -n1 frozen/contracts/109/3` = `a22dda581a642379cc49d9f72bc87d54a8988b20` = `STEND109_PIN` |
| Батарея `probe.py --repo c1 --out out1` (677 с) | `control_green=true`, control_red=[], **15/15** фактов `green: true` (включая STEND_UP_GUARD, LANE_HYGIENE_GUARD, BACKEND_LINT_GUARD, DELIVERY_TEST_RED_CONTROL), cases 53: **53 REJECTED_EXACT / 0 blocked / 0 not_rejected**; raw: `out1/raw.json` |
| `npm run -s lint` | rc 0 |
| `npm test` | rc 0, tests 63 / pass 63 / fail 0 |
| `run_backend_ci.py --lane checks` | rc 0 |
| `run_backend_ci.py --lane postgres` | **rc 1** (R1); на базе 0ed762b8 — rc 0 |
| `npm run -s test:integration` (PG18) | **rc 1**, 40/44 (R1) |
| `test:integration`, БД на закрытом порту | rc 1, NOT_RUN-ветви ✔ (не мок-успех) |
| `compose up -d --wait` (проект rev109l4) | rc 0 |
| Порядок старта | migrator exited 0; FinishedAt 00:02:29.99 < api StartedAt 00:02:32.08 |
| ledger | 14 |
| Роль `hc_synthetic_only` | super=f, login=t, createrole=f, createdb=f, bypassrls=f |
| Повторный `up` | rc 0; sha256 строк ledger до и после одинаков (069b846a…); маркер-строка данных сохранилась |
| Повреждённая копия (`printf x >> migrations/013_*.sql`, проект rev109dmg) | up rc 1; migrator exited 1 «SHA256 013_… не совпадает с манифестом»; api/worker/sandbox в состоянии `created`, не Running |
| `docker compose down -v` | rc 0 для обоих проектов; PG-контейнер rev109pg остановлен |

- rc самой батареи напрямую не захвачен (вывод фонового задания). По коду `main()` при этом выводе (нет NOOP/NEEDS_ENV/RED-строк, not_rejected=0) возвращается 0 — это [INFERENCE] по коду и выводу.
- Живая проба egress из строки 4 описана в Г2.

## (г) Обход и подгонка под код

### Г1 — батарея зелёная, а required-lane красный (класс: обход-состояние; сам по себе блокирует через R1, плюс совет архитектору)
- На OBJECT одновременно: батарея rc 0 (15/15, 53/53) и required-lane `postgres` rc 1.
- Причина: `DRILL_EVIDENCE_GUARD`/`DRILL_INPUT_GUARD` исполняют команду поставки `scripts['drill:evidence']`, но не drill-тест. `DELIVERY_TEST_RED_CONTROL` исполняет только `harness-live.test.js`. Ни один факт не гоняет `npm run test:integration`.
- Гейт оказался зеленее CI.
- Совет архитектору (правило 6 / К5): факт строки 5 — `test:integration` на disposable PG18 rc 0. Это предложение, а не мера freeze.

### Подгонка проверок под код
- Все тесты в диффе — новые файлы 109. Существующие `tests/integration/health.test.js` и `migrations/runner.test.js` не тронуты (их строк FILES.sha256 нет в диффе). Сужения нет.
- Коммит c9ab7ab заменил в тестах `delete process.env[k]` на `Reflect.deleteProperty(process.env, k)` (5 мест). Ассерты не ослаблены. Но сам коммит называет это «обход §13 (no-restricted-syntax)». См. А3.

### Зашитое окружение / пин / рабочая копия / superuser / ledger
- Пин: lane сверяет HEAD H-checkout с литералом `STEND109_PIN`, hash-object пробы — с блобом пина, плюс чистое дерево. `LANE_HYGIENE_GUARD` живьём краснеет на трёх подменах: грязное дерево, assume-unchanged, retag (по rc 1 каждая).
- Lane передаёт пробе `--repo ROOT` (рабочее дерево CI = коммит), lint-факт идёт по `git archive HEAD`.
- api ходит под `hc_synthetic_only`, у роли нет superuser (замер выше). Учётка `postgres` есть только у migrator/role-bootstrap. `MIGRATION*` не попадает в блок api.
- Ledger сверяется по содержимому строк, подмены не найдено.

## Советы (не блокируют)

- **А1 (контракт, архитектору): живая проба egress строки 4 вакуумна на этом образе.**
  - `docker compose run --rm --no-deps document-worker wget -S --spider -T 10 http://example.com` → rc 1. Но причина — `Error: Cannot find module '/app/wget'`: entrypoint образа — node, wget не исполнялся. rc≠0 при любой сети.
  - Моя мера реального маршрута: `run --rm --no-deps document-worker -e "fetch('http://example.com')…"` → `ERR EAI_AGAIN`, rc 3. Контроль тем же образом в сети bridge → `HTTP 200`, rc 0.
  - Итог: egress действительно закрыт, но проба контракта этого не доказывает. Нужна проба, которая исполняется в образе.
- **А2: опубликованные порты мертвы.**
  - У сервисов, сидящих только в `internal: true` сетях, `127.0.0.1:8080:8080` (api) и `127.0.0.1:5432:5432` (postgres) не публикуются: `NetworkSettings.Ports = {}`, `curl 127.0.0.1:8080/health` → rc 7.
  - Инвариант 2 («порт БД только loopback») выполнен вакуумно. `BASE_URL http://127.0.0.1:8080` вводит в заблуждение. Либо убрать `ports:`, либо дать api не-internal сеть только с loopback-публикацией; это решение владельца или архитектора.
- **А3: `Reflect.deleteProperty(process.env, …)` уходит от селектора §13 вместо исключения в норме.**
  - Техническая причина реальна: `process.env.X = undefined` записывает строку "undefined", а process.env — экзотический объект, к которому довод о hidden class не применим.
  - Но коммит сам называет это обходом. Правильная форма — санкционированное исключение в §13 или в eslint-конфиге отдельным предметом 115, а не тихое уклонение.
  - Норма не правилась, поэтому это не отказ по пункту 6.
- **А4: заявление implementer ≠ сделанному.**
  - Заявлено «факты 14/14», измерено **15/15** (контракт требует 15).
  - Заявлено «клетки 52/53, lint NOT_REJECTED», измерено **53/53**.
  - Не заявлено, что `test:integration` 40/44, rc 1 (R1).
  - Отчёт нужно перегенерировать прогоном на OBJECT.

## Паразитная сложность (контракт 050) — по артефакту: (1) свойство; (2) состояние; (3) со-изменяемые файлы; (4) глубина; (5) потребитель → класс

| Артефакт | (1) | (2) | (3) | (4) | (5) | Класс |
|---|---|---|---|---|---|---|
| `compose.dev.yml` | инв. 1, 2, 7, строка 4 | том pgdata, явный | compose + Dockerfile | 6 сервисов за одной командой | батарея STEND_UP/EGRESS, строка 4 | ESSENTIAL |
| `tests/helpers/harness.js` | инв. 3–5 | env `COMPLIOR_HARNESS_{DATABASE_URL,HTTP_HOST,HTTP_PORT,RUN_TAG}`; sink `wx`, явный в выводе | harness + 2 теста | 3 экспорта над ~500 строками, глубокий | HARNESS_*/ASYNC_* факты, test:integration | ESSENTIAL |
| `tests/tools/drill-measure.js` | инв. 6 | `--out`/`--input`, явный | коллектор + package.json + тест | — | `drill:evidence`, DRILL_* факты | ESSENTIAL |
| `tests/tools/role-bootstrap.js` | инв. 2, LOGIN-роль без DDL | env ROLE_NAME/ROLE_PASSWORD/MIGRATION_DATABASE_URL, явный | compose + скрипт | — | STEND_UP_GUARD (роль) | ESSENTIAL |
| lane `stend109`, `stend109_checkout`/`stend109_probe` | ПРОВОДКА-ЭНФОРСМЕНТ, Б4 | env `COMPLIOR_STEND109_H_CHECKOUT`, `STEND109_TAG`; литерал пина, явный | lane + ci.yml при смене пина; число не выросло сверх контракта | — | ci job `stend109`, `required` | ESSENTIAL |
| ветвь «самоклон dev-harness по https без env» | — | — | — | — | CI всегда задаёт env (шаг clone); потребитель — только локальный прогон | ACCIDENTAL, совет: свойство «батарея пина» держит ветвь env + `stend109_checkout`; не блокирует, так как более простая форма не названа приёмкой |
| 3 файла integration-тестов | строки 5, 8 | — | — | — | test:integration | ESSENTIAL; дефект пути — R1 |

## Что нужно для accept
1. Исправить R1 (строка 15 `drill-measure.test.js`, затем FILES.sha256).
2. Предъявить `npm run test:integration` на PG18 → rc 0 (44/44) и `--lane postgres` → rc 0 на новом OBJECT.
3. Повторить батарею на новом OBJECT: 15/15, 53/53.
