FAIL
Реализация 119 v2, круг 3 (OBJECT 7b17232349940fc16f1c6dc36f13c85c79ca76ec, Complior-back `cmp-bck-315/import`), FAIL. Репро Adv119v2 закрыто: перенос path или смена метода у extension- и у ядровых операций теперь красные. Но тот же класс обхода остался: голова первой операции каждого path item, от `  /path:` до `operationId`, всё ещё вне сверки валидатора и оракула. Обход назван: у базовой операции ядра getSession снята аутентификация (`security: []` перед `operationId`). Все пять барьеров при этом зелёные, а значит инвариант «ни одна старая операция не изменена» не выполнен. По (г) регламента это FAIL по тому же предмету, следующий шаг — арбитр. Находки: `/tmp/dev-harness-verify/Rev119r3/review.md` (reslop, status: ready; предлагаемое место — `.review/2026-10-21-08.md`).

Судья: Rev119r3 (reviewer). Контракт: frozen/contracts/119/2 (tag 91b236f2 → ecf56979), прочитан целиком. Батарея: wip/119/architect @ 5bf93857ab0b. Клон: /tmp/dev-harness-verify/Rev119r3/back @ OBJECT (`git rev-parse HEAD` = OBJECT), node_modules подключён симлинком.

## (а) Репро Adv119v2 и честное дерево
Мутации вставлены сразу после `A_TEXT=merge_openapi()`. Пересборка штатная: writer, gen-contracts, writer, у всех трёх rc 0.

| Мутация | spec-3.15 | gen --check | gen-contracts --check | spec-3.14 | оракул |
|---|---|---|---|---|---|
| m1: extension `/partner/v1/onboarding-applications` → `-relocated` | rc 1 `extension-op-iskazhena` (маршрут) | rc 0 | rc 0 | rc 0 | rc 1 `extension-marshrut` |
| m2: extension post → put | rc 1 `extension-op-iskazhena` | rc 0 | rc 0 | rc 0 | rc 1 `extension-marshrut` |
| m3: ядро `/v1/session` → `-relocated` | rc 1 `core-op-iskazhena` | rc 0 | rc 0 | rc 0 | rc 1 `additivnost-operacija` |
| m4: ядро getSession get → post | rc 1 `core-op-iskazhena` | rc 0 | rc 0 | rc 1 (getSession_command_identity/_idempotency/_cas) | rc 1 `additivnost-operacija` |
| честное дерево OBJECT | rc 0 `failures=[]`, 233 = 163 + 70 | rc 0, 675/0 | rc 0 | rc 0 PASS_STATIC 2540 | rc 0 `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product` |

## (б) Батарея (worktree architect, только чтение)
- `red_import315_119.sh --model` → rc 0, «ИТОГ 119: клеток 41, зелёных 41, красных 0».
- Стаб «всегда зелёный» → rc 1, 3/38. Стаб «всегда красный» → rc 1, 1/40. `--cell net-takoj-kletki` → rc 2.
- Контрмодели. Без MARSHRUT-315 клетки d35/d36 дают факт rc 0 IMPORT315_OK, то есть красные, а d40/d41 остаются зелёными. Без MARSHRUT-CORE-315 наоборот: d40/d41 факт rc 0, d35/d36 зелёные. Каждый блок незаменим на своих клетках.
- Б-1 (а): клон без npm-дерева → rc 2 `NEEDS_ENV: import315: npm-paket-nedostupen yaml`. С симлинком node_modules → rc 0.
- Б-2: два прогона оракула подряд → rc 0 и rc 0. `git status` = только `?? node_modules` (мой симлинк), `evidence/` нет.
- Б-3: все `comm` идут под `LC_ALL=C`.
- После прогонов в worktree батареи нет `__pycache__` и изменений нет.

## (в) Обходы того же класса
- **F-1 (БЛОКИРУЕТ), обход b1.** Вставлено `security: []` перед `operationId: getSession`, пересборка штатная. Итог: spec-3.15 rc 0 `failures=[]`, gen --check rc 0, gen-contracts --check rc 0, spec-3.14 rc 0 PASS_STATIC 2540, оракул rc 0 `IMPORT315_OK … pin=product`.
  Своя мера (PyYAML): `paths['/v1/session']['get']` ≠ базе 0ed762b8cb, добавлен ключ `security`, значение `[]`. Глобальный `security: [sessionCookie, bearerAuth]` для этой операции снят. Блок getSession по awk оракула побайтово равен базе: sha256 `33c8006c…` с обеих сторон.
  Корень: `operation_block()` и awk ADDITIV-315 начинают блок после `operationId` и обрывают его на `^  /`. Маршрутные фиксы 119/2 и 119/3 закрыли в этой области только (path, method). Голова открыта у 217 из 233 операций: 154 ядра и 63 extension.
- **b2, тот же класс.** В голову `/v1/session` добавлен метод `delete` без operationId, то есть новый маршрут, не из extension и не из базы. Итог: spec-3.15 rc 0, gen --check rc 0, gen-contracts --check rc 0, spec-3.14 rc 0, оракул rc 0 `IMPORT315_OK operations=233 …`. Состав published по маршрутам ≠ ядро + extension, а счёт по operationId его не видит.
- **b3, тот же класс, extension.** В path item `/partner/v1/onboarding-applications` перед `post:` добавлено `servers: [{url: https://evil.example}]`. Итог: spec-3.15 rc 0 (9a и 9a2 зелёные), gen --check rc 0, gen-contracts --check rc 0, spec-3.14 rc 0, оракул rc 0 `IMPORT315_OK … pin=product`. createPartnerOnboarding в published ≠ источнику extension (sha по пину).
- Не обходы: смена path-параметра меняет строку path и ловится маршрутом. Два operationId на один маршрут — это дубль ключа YAML, он невалиден. Перенос между блоками для второй и следующих операций в path item ловится блоком предыдущей операции.

## Зона, атомарность, подгонка
- Дельта `5e2e32c..OBJECT` = `FILES.sha256` + `tests/spec-3.15/validate_import_315.py`. Всё в ЗОНЕ.
- `0ed762b8cb..OBJECT` минус regex ЗОНЫ v2 → вывод пуст.
- Два коммита автора `implementer`, у каждого ссылка на предмет. Каждый самосогласован с FILES: sha валидатора совпадает со строкой FILES на 3718a8d и на 7b17232.
- Батарея и норма реализацией не тронуты.
- Счёты 163, 70 и 233 перемерены своей мерой (PyYAML), совпадают.

## Паразитная сложность (050)
- `operation_routes` + `PATH_ITEM_RE`/`METHOD_ITEM_RE`/`OPERATION_ID_AT_LEVEL_RE`/`HTTP_METHODS` (validate_import_315.py).
  1. Свойство: аддитивность и равенство extension источнику по маршруту (Adv119v2).
  2. Состояния нет.
  3. Грамматика маршрута теперь живёт в двух местах: текстовая в продукте и PyYAML `route_diff` в оракуле. Это разные стороны, так и задумано.
  4. Одна функция, интерфейс text→dict, модуль глубокий.
  5. Потребитель — п.7/п.9 приёмки.

  Итог: ESSENTIAL по свойству. Форма неполна (F-1): структурное сравнение path item целиком проще и поглотило бы и 1a, и 9a2 (совет С-3).
- Блоки 1a и 9a2 — два вызова одной функции, копии логики нет. ESSENTIAL.

## Рекомендации
С-1 — дрейф чисел замороженного текста: 34/33 против 41/34. Не блокер, отложено до консультанта. С-2 — контрмодель на голову операции. С-3 — структурная сверка path item. Подробно — в review.md.

Уборка. Миры мутаций `w-*` и каталоги evidence удалены. pyc в харнессе и в worktree батареи нет. Из `/tmp/import315-oracle-*` удалены мои 44 каталога: окно прогона батареи 09:46:41–09:47:59 и `-2LuMKR`, проба без npm-дерева на 465M; перечень — `my_scratch.txt`. Оракулы m1–m4 упали до проб, их scratch мелкий и неотличим от чужих, поэтому не тронут. Docker не использовался. Клон `/tmp/dev-harness-verify/Rev119r3/back` оставлен как репро-база до коммита вердикта в основной репозиторий. Там же раннеры `mut.sh` и `bat.sh` и логи батареи `model.log`, `stubg.log`, `stubr.log`.
