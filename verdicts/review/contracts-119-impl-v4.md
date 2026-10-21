accept
Реализация 119 v2, круг 4 (OBJECT bba6e4b1867a3e8281ecef3435d905e7b99de044, Complior-back `cmp-bck-315/import`): accept. Все семь пунктов закрытого перечня A-1…A-7 арбитража `verdicts/arbitration/119-impl-struktura-dokumenta.md` (Решение 3) зелёные. Каждый проверен своей мерой в одноразовых клонах. Четыре обхода F-1 (b1–b4) и регресс m1–m4 + `x-permission` красные и в валидаторе (с адресом), и в оракуле (собственная причина `dokument-ne-sliyanie`). Обхода иного класса при всех зелёных барьерах не найдено. Блокирующих находок нет. Пять советов и одна запись риска — в `/tmp/dev-harness-verify/Rev119r4/review.md` (reslop, `status: ready`). По условию арбитра следующего круга по предмету нет.

Судья: Rev119r4 (reviewer). Контракт: `frozen/contracts/119/2`. Батарея: `wip/119/architect` @ `593b3606f6cabdbe1d4e0b1a2e4f86e9cd3c2271` (worktree, только чтение; `git rev-parse HEAD` сверен). Клон: `/tmp/dev-harness-verify/Rev119r4/back`, `git rev-parse HEAD` = OBJECT, `node_modules` подключён симлинком на npm-дерево Impl119. Раннеры: `mut.sh` (вставка `A_TEXT = A_TEXT.replace(old, new, 1)` сразу после `A_TEXT=merge_openapi()`, затем штатная пересборка writer → gen-contracts → writer и пять барьеров) и `bat.sh`. `PYTHONDONTWRITEBYTECODE=1`.

## A-1 Честное дерево — ЗЕЛЁНЫЙ
Пересборка: rc gen=0, gencontracts=0, gen=0. `git diff` после неё пуст, то есть производные и FILES уже равны выходу штатного генератора.
- spec-3.15 → rc 0, `PASS_STATIC … операций 233 (ядро 163 + extension 70), схем 566 … failures=[]`.
- `generate_derived.py --check` → rc 0. `gen-contracts.js --check` → rc 0.
- spec-3.14 → rc 0, `PASS_STATIC`, checks 2540, failures [].
- Оракул, прогон 1 → rc 0, прогон 2 → rc 0. Оба раза `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product`.
- После двух прогонов `git status` = только `?? node_modules` (мой симлинк), `evidence/` нет.
- Своя мера, другой командой (`count.py`, PyYAML по объектам методов): операций pub 233 = core 163 + ext 70, уникальных operationId 233; схем 566 = 496 + 70; paths 217 = 154 + 63. Совпадает.

## A-2 Обходы b1–b4 при штатной пересборке — ЗЕЛЁНЫЙ
Пересборка во всех четырёх мирах rc 0/0/0.

| Мутация | spec-3.15 | gen --check | gc --check | spec-3.14 | оракул |
|---|---|---|---|---|---|
| b1 `security: []` перед `operationId: getSession` | rc 1, адрес `paths./v1/session.get.security` | 0 | 0 | 0 | rc 1 `dokument-ne-sliyanie`, `адрес: paths./v1/session.get.security` (П-3) |
| b2 `delete` без operationId в `/v1/session` | rc 1, адрес `paths./v1/session.delete` + П-6 `/v1/session delete` | 0 | 0 | 0 | rc 1 `dokument-ne-sliyanie`, `адрес: paths./v1/session.delete.operationId` (П-6) |
| b3 `servers` в path item `/partner/v1/onboarding-applications` | rc 1, адрес `paths./partner/v1/onboarding-applications.servers` | 0 | 0 | 0 | rc 1 `dokument-ne-sliyanie`, тот же адрес (П-4) |
| b4 корневое `security: []` | rc 1, адрес `security.` (элементов 0, в слиянии 2) | 0 | 0 | 0 | rc 1 `dokument-ne-sliyanie`, `адрес: security[0]` (П-1) |

Причина оракула во всех четырёх — собственная, `dokument-ne-sliyanie`, а не `validator-kreven`. Блок STRUKTURA-315 стоит до `validator-kreven` (стр. 164–328 против 415).

## A-3 Регресс прежних кругов — ЗЕЛЁНЫЙ
- m1, extension path → `-relocated`: spec-3.15 rc 1, адрес `paths./partner/v1/onboarding-applications`. Оракул rc 1 `dokument-ne-sliyanie` (П-2).
- m2, extension post → put: spec-3.15 rc 1, адрес `….post`. Оракул rc 1 `dokument-ne-sliyanie`, адрес `….put` (П-4).
- m3, ядро `/v1/session` → `-relocated`: spec-3.15 rc 1, адрес `paths./v1/session`. Оракул rc 1 `dokument-ne-sliyanie` (П-2).
- m4, ядро getSession get → post: spec-3.15 rc 1, адрес `paths./v1/session.get`. spec-3.14 rc 1 (`getSession_command_identity/_idempotency/_cas`, как у Rev119r3). Оракул rc 1 `dokument-ne-sliyanie`, адрес `paths./v1/session.post` (П-3).
- xp, Adv119 круга 1 (`x-permission: partner:onboarding:create` → `mobility:cases:read`): spec-3.15 rc 1 (9a `extension-op-iskazhena` + п.10, адрес `….post.x-permission.`). Оракул rc 1 `dokument-ne-sliyanie` (П-4) — собственная причина.
- gen --check / gc --check во всех пяти мирах rc 0; пересборка rc 0/0/0.
- Своя проба вдобавок к перечню, b5 (`components.securitySchemes.bearerAuth.bearerFormat` → `JWT`): spec-3.15 rc 1 с адресом, оракул rc 1 `dokument-ne-sliyanie` (П-5).

## A-4 Батарея — ЗЕЛЁНЫЙ
- `red_import315_119.sh --model` → rc 0, «ИТОГ 119: клеток 46, зелёных 46, красных 0». Своя мера: длина `CELLS` = 46; алфавит `fail <причина>` оракула = 34 различных; `extension-marshrut` отсутствует, `dokument-ne-sliyanie` есть.
- Стаб «всегда зелёный» → rc 1 (3/46 зелёных). Стаб «всегда красный» → rc 1 (1/46). `--cell net-takoj-kletki` → rc 2 `ОТКАЗ: неизвестная клетка`.
- Контрмодель без STRUKTURA-315 (sed по сентинелам): d35, d36, d40, d41, d42, d43, d44, d45, d46 — все КРАСНЫЕ, факт `rc=0 IMPORT315_OK operations=4 …`. k-model при этом зелёная.
- Контрмодель без ADDITIV-315: d13 КРАСНАЯ, факт `rc 0 IMPORT315_OK` — как прежде. d12 зелёная, её причина вне блока (совет С-4 о комментарии).
- Без npm-дерева (клон OBJECT без `node_modules`; в предках `/tmp/node_modules` пакета `yaml` нет) → rc 2 `NEEDS_ENV: import315: npm-paket-nedostupen yaml`.
- `LC_ALL=C`: все `comm` (стр. 99, 116, 132, 519, 521, 533) и все `sort` оракула идут под `LC_ALL=C`.
- После прогонов worktree батареи: `git status --short --ignored` пуст, `__pycache__` нет.

## A-5 Второй грамматики нет — ЗЕЛЁНЫЙ
Поиск `operation_routes|PATH_ITEM_RE|METHOD_ITEM_RE|OPERATION_ID_AT_LEVEL_RE` в `tests/spec-3.15/validate_import_315.py` @ OBJECT дал 0 совпадений. Поиск `route_diff|MARSHRUT-|extension-marshrut` в `fixtures/workshop_project/import315_119/` @ 593b3606f — тоже 0 совпадений (grep-инструмент, rc «no matches»). В диффе 7b172323..OBJECT удалены `operation_routes`, три regex, блоки 1a и 9a2 целиком; шима нет. `HTTP_METHODS` оставлен закрытым списком.

## A-6 Зона и атомарность — ЗЕЛЁНЫЙ
- `git diff --name-only 7b172323 OBJECT` = `FILES.sha256` и `tests/spec-3.15/validate_import_315.py`.
- `sha256sum` валидатора `fef12b82…0f7` = строке FILES. Честная пересборка не меняет FILES, значит FILES — выход штатного генератора.
- Коммит один (`bba6e4b1`), author/committer `implementer`, сообщение «119 круг 4 …» со ссылкой на решение арбитра.
- Батарея: `5bf93857a..593b3606f` — один коммит `architect` («119 батарея круг 4»), файлы `import315_oracle.sh` и `red_import315_119.sh`. Все коммиты каталога `import315_119/` — `architect`.
- Валидатор продукта меняли только коммиты `implementer`.
- Норма и контракт не тронуты: основной чекаут харнесса `git status` пуст.

## A-7 Паразитная сложность (050) — ЗЕЛЁНЫЙ
Ожидаемый документ строит одна функция (`merged_document`), сравнивает одна функция (`first_difference`, вызов один). Второго способа сравнить published с ожидаемым в файле нет. Поблочные п.1/9a–9d оставлены по прямому указанию арбитра (другой домен — побайтово). Пять вопросов по каждому новому артефакту:
- `import yaml`, `import copy`. (1) П-1…П-5 требуют объектов после `yaml.safe_load`. (2) Состояния нет. (3) Связанные файлы: 1, не выросло. (4) Интерфейса нет. (5) PyYAML уже зависимость (`generate_derived.py`, spec-3.14). ESSENTIAL.
- `PROFILE_MARKER`. (1) П-4, единственная денормализация. (2) Константа, явная. (3) 1 файл; имя совпадает с писателем, но писатель — не потребитель. (4) Глубина не применима. (5) Потребитель — п.10. ESSENTIAL.
- `CORE_DOC` / `EXTENSION_DOC` / `PUBLISHED_DOC` и производные `*_paths`, `*_components`. (1) Входы сверки. (2) Модульные переменные; входные файлы те же, что у п.1/9: `base_text`, `EXTENSION_TEXT`, `published_text`. (3) 1. (4) Интерфейса нет. (5) Новых путей к файлам нет. ESSENTIAL.
- `merged_document(core, ext)`. (1) Определение `expected = merge(core, ext)` по правилам замера 7. (2) Чистая функция, всё в аргументах. (3) 1 файл. Правка правил писателя потребует правки здесь — это и есть независимая сверка, так и задумано. (4) Два аргумента, около 20 строк работы: глубокий. (5) Потребитель — A-1/A-2/A-3. Писательскую грамматику (`split_blocks` / `merge_blocks`) функция не повторяет: работает по объектам, а не по тексту. ESSENTIAL.
- `first_difference(expected, actual, address)`. (1) П-1…П-5 и П-7 (адрес первого расхождения). (2) Чистая рекурсия. (3) 1. (4) Три аргумента, возврат «адрес или None»: глубокий. (5) A-2 требует «rc 1 с адресом», адрес наблюдён во всех 10 мирах. ESSENTIAL. Слабость равенства скаляров — совет С-1: блокирующей части нет, определение арбитра такое же.
- Проверки коллизий `paths` и `component_collision`. (1) П-2 (`core ∩ ext = ∅`). Для components проверка закрывает подмену, которую `update()` в `merged_document` иначе бы скрыл. (2) Явная. (3) 1. (4)–(5) Потребитель — П-2. ESSENTIAL. То, что валидатор строже писателя на одинаковых определениях, — совет С-2.
- Блок П-6 (`anonymous`, `owners/twice`). (1) П-6, арбитр велит назвать его отдельно. (2) Явная. (3) 1, но кратность operationId теперь меряется и п.2 (стр. 208) — совет С-3. (4) Мелкий, но короткий. (5) Потребитель — A-2 b2: диагностика `/v1/session delete` наблюдена. ESSENTIAL по Решению 1.
- Удалено: `operation_routes`, `PATH_ITEM_RE`, `METHOD_ITEM_RE`, `OPERATION_ID_AT_LEVEL_RE`, 1a, 9a2. Минус две текстовые грамматики, итог диффа: +119/−77.

## Пробы вне перечня (не FAIL)
- t1, смена типа скаляра в схеме ядра (`minLength: 1` → `true`, `Context.properties.acting_party_id`): spec-3.15 rc 0 `failures=[]`, gen --check rc 0, gc --check rc 0, spec-3.14 rc 0. Оракул rc 1 `dokument-ne-sliyanie`, `адрес: components.schemas.Context.properties.acting_party_id.minLength`. Не все барьеры зелёные, поэтому это не обход. Слабость валидатора (`True == 1` в Python) — совет С-1. Определение арбитра (`yaml.safe_load(published) == expected`) имеет ту же форму.

## Уборка
- Миры `w-*` и `ev-*` удалены.
- Из `/tmp/import315-oracle-*` удалены мои 102 каталога. Это ровно разность с выпиской до старта (`oracle_tmp_before.txt`, 1153 шт.), окно 10:43:47–10:49:44; последний оставлен NEEDS_ENV-прогоном (rc 2 до `rm` scratch). Активных процессов import315 при уборке не было.
- `__pycache__` в харнессе и в worktree батареи нет.
- Клон `back`, скрипты `mut.sh`, `bat.sh`, `batch.sh`, `count.py`, `probe.py` и логи `logs/`, `bat/` оставлены рядом как репро.
- Push не делался. Коммит вердикта в основной репозиторий — за оркестратором (основной чекаут выдан мне только на чтение).
