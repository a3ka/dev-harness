accept
Rev115, судья реализации 115 (scoped). OBJECT=ef49cefb06a7aca27fc2270caf8b05e906693dc0 (ветка cmp-bck-115/standards клона /tmp/dev-harness-verify/Impl115/back, база 11432a3f5193158db4354f5a8296da25a26ae105). Контракт frozen/contracts/115/1 = 721c937aa. Блокирующих находок нет: ни обхода, ни выхода за зону. Пять советов — ниже (С1–С5). Дата 2026-10-20.

## Как проверял (все прогоны — мои, на чистом одноразовом клоне `git clone --local` → /tmp/dev-harness-verify/Rev115/back @ ef49cef, node_modules — симлинк /tmp/dev-harness-verify/Arbiter115/node_modules)

| Команда | rc | Наблюдение |
|---|---|---|
| `git -C <H> diff --stat frozen/contracts/115/1^{commit} HEAD -- contracts/115-… fixtures/workshop_project/standarty_115/` + `git status --short` по тем же путям | 0 | пусто: батарея (probe.py blob 64ab5faa) и контракт в main харнесса не менялись с заморозки |
| `probe.py --repo <чистый клон> --out …/out-full` | **0** | `control_green=true`, `control_red=[]`, 4 факта True (BACKEND_LINT_GREEN, LINT_FIXTURES_GUARD, LINT_SCOPE_COVERED, LINT_SCOPE_CONFIG_EQUAL); summary.json пересчитан СВОЕЙ мерой (python Counter по `cases`): 41 клетка, 41 `REJECTED_EXACT`; out-full удалён |
| `npm run -s lint` | 0 | eslint + prettier чисты |
| `npm run -s test:standards-lint` | 0 | 7 строк `ok <имя> <правило>` |
| `npm test` | 0 | `tests 63 / pass 63 / fail 0` (redaction.test.js — в составе) |
| `python3 tests/tools/run_backend_ci.py --lane checks` | 0 | 4 шага PASS, включая новый `lint-стандарты 115`; «все lanes success» |
| `sha256sum -c --quiet FILES.sha256` | 0 | все 657 записей совпадают с байтами; множество путей FILES.sha256 == `git ls-files` минус сам файл (md5 списков совпали, 657 = 657) — регенерация честная |

## (а) Зона и пересечения

- `git diff --name-only 11432a3..HEAD` — **23** пути (моя мера; см. С2), все ⊆ строке 89 контракта: AGENTS.md, FILES.sha256, docs/CODING-STANDARDS.md, eslint.config.js, package.json, provenance.json, tests/standards/lint/ (14 файлов, 7 каталогов × {violation,honest}), tests/tools/check-lint-standards.js, tests/tools/run_backend_ci.py, tests/unit/config.test.js. docs/VERSION_MANIFEST.json не менялся и хэшей изменённых файлов не несёт (grep старых sha — пусто).
- provenance.json: одна строка — `destination_sha256` записи `eslint.config.js` (= sha нового файла, подтверждено `sha256sum -c`).
- package.json: только `+ "test:standards-lint"` (запятая у соседней строки — синтаксис), чужие скрипты не тронуты.
- run_backend_ci.py: одна строка — шаг в существующем lane `checks`; другие lanes и агрегат не тронуты.
- docs/CODING-STANDARDS.md: hunk только `@@ -144,3 +144,51` — добавлены §13–19, §1–12 байт-в-байт.
- AGENTS.md продукта: ровно одна строка `+`.
- tests/unit/config.test.js: одна строка `assert.fail` → `return assert.fail` (санкционировано контрактом, сайт 2).
- server/src/logger.js и код server/infrastructure, tests/spec-3.14 — не в диффе.
- Атомарность: один коммит `ef49cef` автора `implementer`, тема со ссылкой на cmp-bck-115.

## (б) Батарея не подогнана

probe.py и контракт в харнессе неизменны с freeze (см. таблицу). Тест-файлы продукта автор не переписывал под реализацию: единственная правка существующего теста — сайт, названный контрактом.

## (в) Поиск обхода — мутации на копиях (/tmp/dev-harness-verify/Rev115/m1..m3, удалены)

| Мутант | Что | probe rc | Причины |
|---|---|---|---|
| m1 | из `no-restricted-properties` вынута запись `apply` | **1** | `RULE_PART_ABSENT:no-restricted-properties/apply` + `LINT_SCOPE_CONFIG_EQUAL` False (`SCOPE_CONFIG_DRIFT:<файл>:no-restricted-properties` на каждом файле) + `LINT_SCOPE_COVERED` False |
| m2 | override `files: ['app/**/*.js'], rules: {'max-depth': ['error', 5]}` | **1** | `LINT_SCOPE_CONFIG_EQUAL` False — `SCOPE_CONFIG_DRIFT:app/…:max-depth`; `LINT_SCOPE_COVERED` False |
| m3 | раннер лжёт: `ruleIds = kind==='violation' ? [expected] : []` без запуска eslint | **1** | `LINT_FIXTURES_GUARD` False — `DECOY:runner_blind` |

Гейт равенства конфигурации красит, проба слепоты раннера работает. Фикстуры — реальные: независимый оракул батареи (LINT_FIXTURES_GUARD) и раннер подтверждают для каждой violation множество ruleIds == {правило}, honest пусто. Конфиг: правила 115 записаны в общий `rules` обоих главных блоков, `noInlineConfig: true` в обоих, `server/infrastructure/` — единственный новый игнор (разрешён контрактом), override logger.js — одним файлом с комментарием-причиной, `max-depth: off` — в существующем spec-3.14 блоке; layerConfigs правил 115 не трогают.

## (г) Сверка диффа с docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md продукта

- §13–19 покрывают все обязательства предмета (а): формы/V8 + дискриминатор; consistent return, объекты-не-массивы, одна функция — одна задача, reuse-before-write; bind/call/apply и forEach; async разрешено/запрещено; Деметра; Conventional Commits; чеклист. TypeScript/WorkOS/MetaSQL/frontend-токенов в §13–19 нет (grep). «< 50 строк» §19 — из исходника владельца (`docs/owner/CODING-STANDARDS.md:1300`), не выдумано.
- Ссылки на архитектуру верны: `server/lib/errors.js` существует (ARCHITECTURE §4, CODING §6); слои `domain`/RLS — согласно ARCHITECTURE §2/§6/§8. Противоречий с §1–12 нет: §5 «ранний возврат, не глубже двух уровней» — цель, §15 max-depth 4 — явно забор, не цель.
- Новый код диффа сам соблюдает §13–19: раннер без forEach/bind/delete/генераторов, `problemsOf` возвращает массив на всех путях; `npm run -s lint` rc 0 на всём дереве.
- Норма судей AGENTS.md: строка называет оба документа и FAIL — выполнено.

## Находки (reslop)

- [ ] С1 (совет, не обход). Раннер `check-lint-standards.js` гранулярен по правилу, не по форме: фикстура `no-restricted-properties-bind-call-apply/violation.js` краснеет от bind и call, поэтому выемка `apply` (m1) оставляет `npm run -s test:standards-lint` rc 0 и `npm run -s lint` rc 0; lane `checks` краснеет лишь побочно — шагом `provenance` (rc 1, sha eslint.config.js), т.е. при согласованной правке sha в CI продукта прошло бы. То же для генератора: фикстура несёт только `FunctionDeclaration`. Батарея контракта (guard ПРОВОДКИ) ловит это — `RULE_PART_ABSENT` + `SCOPE_CONFIG_DRIFT`, поэтому не блок. Простая форма: по violation-файлу на форму (bind/call/apply, generator-expression) либо счёт сообщений ≥ числа форм.
- [ ] С2 (совет, счёт). Заявление implementer «24 пути» против измеренных **23** (`git diff --name-only 11432a3..HEAD | wc -l`). Все в зоне; расхождение — только в отчёте.
- [ ] С3 (совет, стиль). Пример §17 `user.organization.billing.plan.name` использует домен billing/plan, который §12 относит к донору («Stripe-подписки — не наш продукт»); пример лучше на домене Complior.
- [ ] С4 (совет). Scope коммита `feat(cmp-bck-115)` — не домен и не слой из перечня §18, вводимого этим же коммитом; к содержанию диффа не относится, поправимо заголовком PR/squash.
- [ ] С5 (среда). `run_backend_ci.py --lane checks` пишет evidence в `/tmp/complior-ci-*` (мои прогоны: `3i34o7v7`, `3z086oj0`) — вне null-allowlist, удалить мне запрещено; оставлены.

## Паразитная сложность (050)

| Артефакт | (1) свойство контракта | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| tests/tools/check-lint-standards.js | инв. 2 (красная фикстура на правило, `--no-ignore`), инв. 4 (проводка) | нет; вывод явный (`ok`/`FAIL`, rc 0/1/2) | 1 + каталог фикстур (таблица RULE_OF) | интерфейс 0 аргументов, rc 3 значения — глубокий | строка 4 приёмки, lane checks; дубля грамматики нет | ESSENTIAL |
| tests/standards/lint/<7>/{violation,honest}.js (одна семья) | инв. 2 | нет | 1 каталог на правило | — | раннер + LINT_FIXTURES_GUARD | ESSENTIAL |
| package.json `test:standards-lint` | инв. 4 (`WIRED_SCRIPT_ABSENT`) | нет | 1 | — | lane checks | ESSENTIAL |
| run_backend_ci.py шаг checks | инв. 4 (`LANE_STEP_ABSENT`) | нет | 1 | — | CI workflow | ESSENTIAL |
| eslint.config.js: правила 115, noInlineConfig, игнор ex-infra, override logger.js, max-depth off spec-3.14 | предмет (б), инв. 3, 7 | нет | 1 (+ provenance/FILES — производные) | — | lint, батарея | ESSENTIAL |

Мобильного экрана в предмете нет — сверка с макетом неприменима. sourceCanon: null — gate сверки карты неприменим.
