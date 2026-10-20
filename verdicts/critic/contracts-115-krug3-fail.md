FAIL

# Критик 115 — круг 3, до заморозки

Предмет: `contracts/115-standarty-bekenda-do-003.md` на OBJECT `5c68bec75fe21a99bf36828548dfb25ef69589cb`, ветка `wip/115/architect`. Проверен закоммиченный объект в отдельном клоне `harness`, checkout detached на OBJECT. Продуктовая база клонирована `git clone --local` от `/tmp/dev-harness-verify/Architect115v3/back`; честная модель собрана на этой базе из файлов модели v5, зафиксирована только в одноразовом клоне. Все записи и эксперименты — `/tmp/dev-harness-verify/Critic115d/` (далее D). Основной checkout и worktree архитектора не изменялись, push не выполнялся.

Набор артефактов полный: предмет, команды готовности, исполнители, зоны, ПРОВОДКА и модель угроз присутствуют. Прочитаны оба предыдущих вердикта и источники Complior-back `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md`.

**Прежние два обхода закрыты; честная модель зелёная. Найдены два новых воспроизводимых обхода того же свойства. На каждом полная батарея возвращает rc 0, три факта true, 39/39 REJECTED_EXACT; команды поставки тоже зелёные.**

## Блокирующие находки

### 1. Эффективный забор complexity можно поднять с 40 до 41

БЛОКИРУЕТ contracts/115-standarty-bekenda-do-003.md:75 — критерий принимает ослабление обязательного забора из :67. Канонический свидетель, названный в :68 как «complexity 41», фактически имеет complexity **42**: начальная единица функции плюс 41 `if` (`fixtures/workshop_project/standarty_115/probe.py:459–460,482–484`). Его краснота не различает максимумы 40 и 41.
ОБХОД: в честную модель v5 добавить в разрешённом `eslint.config.js` после главных JS/MJS-блоков и перед блоком «Скрипты и тесты» `{ files: ['server/src/http.js'], rules: { complexity: ['error', { max: 41 }] } }`; сохранить основной литерал max:40, все остальные правила, документы, фикстуры и проводку; обновить разрешённый destination_sha256 записи eslint.config.js в provenance.json. Дерево `D/boundary41` проходит полную батарею rc 0, три факта true и 39/39; все 39 отдельных `--case` и `--matrix` дают rc 0; lint, test:standards-lint, npm test и checks дают rc 0. При этом независимый stdin-свидетель с 40 `if` (complexity 41) на пути server/src/http.js: честная модель rc 1 / диагностика complexity «41, maximum 40», обход rc 0 / messages=[] — обязательный забор перестал действовать.

Причина не в подмене ESLint: прямой CLI на каноническом свидетеле печатает «complexity 42» и остаётся красным как при max:40, так и при max:41. Структурный контроль удовлетворяется оставшимся базовым литералом 40. Исходник http.js для обхода не меняется.

Свидетельства: `experiment.py`, `complexity41.js`, `witness-results.json`, `canonical.py`, `canonical-results.json`, `out-boundary41/summary.json`, `delivery-results.json`, `matrix/matrix.tsv`. Конфиг обхода: `boundary41/eslint.config.js`.

### 2. Валидный allowObjects обходит конечный набор имён свидетелей

БЛОКИРУЕТ contracts/115-standarty-bekenda-do-003.md:68 — обещание отбрасывать allow-списки и любую потерю общего запрета bind/call/apply/forEach не доказано критерием :75. Все поведенческие свидетели этих свойств используют только три receiver: `scope`, `Object`, `this` (`probe.py:488–501`); исключение для другого имени остаётся невидимым.
ОБХОД: в честной модели к каждой из четырёх существующих записей no-restricted-properties добавить валидное поле `allowObjects: ['client']`, то есть `{ property: 'bind', allowObjects: ['client'], message: ... }` и аналогично call/apply/forEach; больше конфиг не ослаблять, обновить только разрешённый provenance-хэш. Дерево `D/allow-valid` проходит полную батарею rc 0, три факта true, 39/39 REJECTED_EXACT; lint, test:standards-lint, npm test и checks также rc 0. Один и тот же прямой CLI ESLint stdin-свидетель `function f(client) { client.forEach((_v) => 1); client.bind(null); client.call(null); return client.apply(null); }` на пути server/src/http.js даёт на honest rc 1 и четыре no-restricted-properties, на allow-valid rc 0 и пустой messages. Предмет общего запрета не выполнен; третье, не объявленное контрактом исключение внесено в разрешённый файл.

Дополнительная причина ложной уверенности: существующая клетка `scope_allow_objects` добавляет **отдельную** запись `{ allowObjects: ['scope'] }` без property/object (`probe.py:749–752`). Это невалидная конфигурация ESLint 10.13.0, а не работающее разрешение. Живой `--case scope_allow_objects` на allow-valid возвращает rc 0 / REJECTED_EXACT, но прямой ESLint на созданном мутанте возвращает **rc 2**: required property `.object` / `.property`. В `scope_fail_log.json` вместо выполнения правил записано `<eslint-error>`. Поэтому эта красная клетка не доказывает защиту от валидного allowObjects. Это уточнение причины второй находки, не третий самостоятельный блокер.

Свидетельства: `allow_valid.py`, `client-witness.js`, `honest-allow-valid-witness.json`, `allow-valid-allow-valid-witness.json`, `out-allow-valid/summary.json`, `allow-delivery-results.json`; клетка и её диагностика — `allow-valid-case/standarty115-08yh73gl/`. Никакие зависимости, оракул, продуктовые исходники или фикстуры для обхода не подменялись.

## Арбитраж

АРБИТР: arbiter. Предмет: достаточность механического критерия области действия ESLint и границы угроз; третий круг по одному предмету, повтор общего свойства при закрытых конкретных обходах кругов 1–2. Один поведенческий пример и три фиксированных имени не доказывают заявленное отсутствие ослаблений параметров. Нужен арбитраж по регламенту, не четвёртый обычный круг критика. Автор контракта — сторона; вопросы владельцу 1–5 этим вердиктом не решаются.

Попытка передать решение через `agent://Main` отклонена инструментом по Н-85 (`null-allowlist`); успешный созыв арбитра не заявляется. Оркестратору передать настоящий файл и оба прежних вердикта арбитру. Это инженерный FAIL, не ESCALATE о воле владельца.

## Закрытие предыдущих обходов

- `old-ignores`: только добавление server/ и app/ в глобальные ignores поверх v5 — **rc 1**, SCOPE_IGNORE_EXTRA для обоих и SCOPE_FILE_IGNORED. Первый обход действительно закрыт.
- `old-object`: прежний override с `object: 'Object'` для app/server/tests-unit — **rc 1**, в частности SCOPE_BEHAVIOR_SILENT:no-restricted-properties. Второй обход действительно закрыт.
- `honest`: **rc 0**, control_green=true, все три факта true, **39/39** REJECTED_EXACT. Новые отказы не объясняются красным исходным контролем.

## Пять обязательных вопросов

1. **Критерий слабее предмета?** Да: два названных состояния дерева удовлетворяют механической приёмке без общего действия правил и без требуемого забора. Это не предложение изменить продуктовый стандарт.
2. **Готово недоказуемо названной командой?** Команды исполнимы; на приведённых состояниях выдают ложное зелёное. Человеческое суждение строки :78 не превращает эти rc в доказательство свойства. Accept будущих судей не приписывается.
3. **Молчаливое решение исполнителю?** Параметры 40/4 и два исключения названы; проблема не в недостающем продуктовом решении, а в недоказанном соблюдении. Рабочий статус вопросов владельцу 1–5 сохранён; критик их не утверждает.
4. **Границы исполнения?** Исполнители и зоны названы, precision-gate rc 0. Оба обхода меняют только разрешённые eslint.config.js и destination_sha256 в provenance.json. Запрет выхода из зоны их не отсекает.
5. **Нормы AGENTS.md?** Проверены механизм и другая мера счётных утверждений. Формальные ПРОВОДКА и модель угроз зелёные, но не отменяют два поведенческих контрпримера. Изменения модели согласуются с JS/CommonJS+VM и не требуют новых зависимостей; отдельного нарушения архитектурных источников не заявляю. Старый продуктовый lane-раннер печатает PASS; это не введённая 115 норма и отдельным блокером не объявляется.

## Живые прогоны и коды возврата

`H=D/harness`, `P=H/fixtures/workshop_project/standarty_115/probe.py`.

| Команда / сценарий | rc | Наблюдение |
|---|---:|---|
| `bash scripts/check_precision_gate.sh "$H" contracts/115-standarty-bekenda-do-003.md` из H | 0 | OK |
| `bash scripts/check_provodka.sh "$H" contracts/115-standarty-bekenda-do-003.md` | 0 | Формальный гейт принят |
| `bash scripts/check_threat_model.sh "$H" contracts/115-standarty-bekenda-do-003.md` | 0 | 10 защищающих / 5 исключающих буллетов |
| `python3 "$P" --repo D/back --out D/out-back` | 1 | 28 причин, факты true/false/false |
| Та же батарея на D/honest | 0 | 39/39, три факта true |
| Та же батарея на D/old-ignores | 1 | Прежний обход отвергнут |
| Та же батарея на D/old-object | 1 | Прежний обход отвергнут |
| Та же батарея на D/boundary41 | 0 | Новый обход принят, 39/39, три факта true |
| Та же батарея на D/allow-valid | 0 | Новый обход принят, 39/39, три факта true |
| D/boundary41: каждый из 39 отдельных `--case <имя>` | 0 каждый | Все REJECTED_EXACT |
| D/boundary41: `--case nonexistent` | 2 | EMPTY_SELECTION |
| D/boundary41: `--matrix` | 0 | 39 строк REJECTED_EXACT |
| Модель без node_modules: полный probe | 2 | NEEDS_ENV |
| На **каждом** из boundary41 и allow-valid: `npm run -s lint` | 0 | ESLint + Prettier |
| На каждом: `npm run -s test:standards-lint` | 0 | Семь ok |
| На каждом: `npm test` | 0 | 63 pass / 0 fail |
| На каждом: `python3 tests/tools/run_backend_ci.py --lane checks --out <каталог D>` | 0 | Все четыре шага checks зелёные |
| `python3 D/measure.py` | 0 | Независимый счёт и различающие stdin-свидетели |
| Прямой ESLint, complexity41: honest / boundary41 | 1 / 0 | Запрет / потеря запрета |
| `python3 D/canonical.py`, вложенные ESLint на каноническом примере | 0; 1 / 1 | У примера complexity 42, оба максимума его запрещают |
| Прямой ESLint, четыре вызова client: honest / allow-valid | 1 / 0 | Четыре запрета / ни одного |
| allow-valid: `--case scope_allow_objects` | 0 | Формальный REJECTED_EXACT |
| Прямой ESLint на созданном scope_allow_objects-мутанте | 2 | Невалидная схема конфигурации, не поведенческий запрет |

Полные argv/cwd/rc: `probe-*.json`, `delivery-results.json`, `allow-delivery-results.json`; сырые выводы — одноимённые `.log`, summary — `out-*/summary.json`. Скрипты воспроизведения сохранены.

Дополнительно живьём проверены смежные направления (`adjacent.py`, `adjacent-results.json`): отключение complexity только у нового отслеживаемого tests/tools/check-lint-standards.js отвергнуто LINT_SCOPE_COVERED; max-depth:5 и noInlineConfig:false на http.js тоже отвергнуты. `reportUnusedDisableDirectives: 'off'` при сохранённом noInlineConfig:true не нарушает запрета, факт остаётся true — блокера здесь нет. Эти прямые вызовы факта не выдаются за полные батареи.

На честной модели computed-доступ `scope['bind']`, деструктуризация `{ bind } = scope`, алиас `alias.apply` дают rc 1 с no-restricted-properties; Object['keys'] даёт rc 0; eslint-disable не подавляет call (rc 1). Files-сужение, severity warn и tests/unit override проверены также штатными живыми клетками. Подмена самого ESLint не использовалась и отдельно не испытывалась: оба обхода воспроизведены на настоящем установленном ESLint.

## Счётные утверждения — другая мера

- Python AST **литералов** `cases()`, без вызова len(cases()), даёт 39 имён: **28 control + 3 LINT_FIXTURES_GUARD + 8 LINT_SCOPE_COVERED**. Независимый вывод matrix содержит те же 39 клеток. Данные: `independent-counts.json`, `matrix/matrix.tsv`.
- Классификация фактических уникальных причин базы: 7 DOC_ANCHOR + 3 RULE_ABSENT + 4 RULE_PART_ABSENT + 2 SELECTOR_ABSENT + 7 FIXTURE_DIR_ABSENT + RUNNER + WIRED_SCRIPT + LANE_STEP + AGENTS + SCOPE_IGNORE_MISSING = **28**. Данные: `base-independent.json`, `base-reasons-count.json`.
- Независимый счёт семейств свидетелей: 1 clean + 3 return/complexity/depth + 4 свойства × 3 receiver + 4 syntax + 5 disable = **25**. Перечень git-файлов базы с независимо заданной фильтрацией — **27**, произведение **675**. После добавления и коммита нового JS-раннера модель имеет **28** файлов и **700** сочетаний; правило использует динамический перечень, а не жёсткое число 27.

СОВЕТ contracts/115-standarty-bekenda-do-003.md:161 — уточнить, к какому дереву относится замер «27 файлов / 25 свидетелей». База действительно имеет 27, но закоммиченная модель с новым раннером — 28. Сам раннер не выпадает: независимая мутация rules:off на нём поймана. Это уточнение замера, не отдельный обход.

## Граница проверки и доставка

Это суд контракта до заморозки, не ревью реализации. Продуктовые исходники и контракт не исправлялись. Вопросы владельцу 1–5 остаются за владельцем. Проверялся только scoped-предмет 115, полный CI не заявляется.

Окружение: Node v26.5.1 / npm 11.17.0; npm ci по lockfile установил 142 пакета и предупредил о продуктовом pin Node 24.22.0. Проверка именно под Node 24.22.0 не заявляется. Начальная попытка копирования зависимостей разыменовала .bin-ссылки и дала MODULE_NOT_FOUND; это ошибка подготовки стенда, устранённая npm ci. Все итоговые результаты выше получены после установки, а не на сломанном окружении.

Вердикт записан в `D/verdict.md`. По Н-85 коммит в ветку предмета выполняет оркестратор под identity critic; критик не утверждает, что этот коммит уже создан. Клоны и свидетельства сохранены до доставки вердикта. Необходимый итог: передать FAIL и оба новых обхода арбитру, не замораживать текущий OBJECT.
