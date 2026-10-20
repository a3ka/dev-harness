FAIL
OBJECT=dd8e533f162ef67d97b219554a18f6e7a024b8af

Батарея: `wip/109/architect` @ `e4ae3712d23557e29e906eb79a8896b7939ccb06` из предписанного read-only пути. Frozen-контракт сверён: commit `b91be196514191953d9c8dba19326021ecb0ba32`, blob `5becfd05ef46d977cc81e8035f0f0b67c1d7c11a`.

| Пункт | Статус | Замер |
|---|---|---|
| I-1 | **не закрыт — К ВЛАДЕЛЬЦУ** | На самом OBJECT `npm --prefix backend run -s lint` rc 0. Но мутант `mut-i1` добавляет ровно один неиспользуемый `const` в harness: lint rc 1, а полная батарея остаётся зелёной: rc 0, 13/13 facts green, 50/50 `REJECTED_EXACT`. Значит проверка не ловит обязательный required-lane барьер. |
| I-2 | закрыт | Полная батарея C: `DRILL_INPUT_GUARD` green; все отрицательные формы, включая `never 1`, `1`, `May 5`, `12/31/2026`, 2026-02-31, без зоны, дали rc 2 без MEASURED. Прямой `2026-02-31T00:00:00Z` дал NOT_RUN/rc 2; валидный offset-вход — MEASURED/rc 0. |
| I-3 | закрыт | `ASYNC_TUPLE_GUARD` green: две параллельные записи, 2 файла, собственные SQL-тексты/строки, PRESET ровно 2 и MARKER ровно 1; M1–M4 из регресс-набора отвергнуты. |
| I-4 | закрыт | Async-факт на C: мультистейтмент — NOT_RUN с причиной `read-only: мультистейтмент…`; таблица не изменилась. Реконструкция M11 (снятие текстового фильтра) красит `ASYNC_TUPLE_GUARD`: в БД появляется `STEND109_MS_SENTINEL`. |
| I-5 | закрыт | `LANE_HYGIENE_GUARD` green: clean rc 0; dirty, `assume-unchanged`+подмена и commit+`tag -f` — rc 1. |
| I-6 | закрыт | `HARNESS_PII_GUARD` и `ASYNC_PII_GUARD` green: cookie без `=`, массивы, Set-Cookie, Basic/bare auth, proxy-auth, x-api-key, body-формы и два формата телефонов не утекли; JSON парсится. M5/M6/M13/M14 отвергнуты. |
| I-7 | закрыт | DB-less async-путь из факта пишет `runtime_role='NOT_RUN'`; M15 (подмена ролью заявления) отвергнут. |
| I-8 | закрыт | Факт читает из sink разные hashes для `{a:{x:1}}`/`{a:{y:2}}`; канонические nested JSON не схлопываются. |
| I-9 | закрыт | C использует один `appendExclusive(..., scrubRecord(...))`; `harness_async_no_scrub` отвергнут `ASYNC_PII_GUARD`; полная матрица не имеет NOOP/BLOCKED. |
| I-10 | **не закрыт — К ВЛАДЕЛЬЦУ** | Мутант `mut-i10` заменяет ТОЛЬКО тело требуемого delivery-теста `живое наблюдение: server+PG18…` на `async () => {}` (1 строка вместо 33), оставляя файл, имя теста, setup и все остальные тесты. `COMPLIOR_TEST_PG_ADMIN_URL=… npm --prefix backend run -s test:integration` — rc 0, 44/44; полная батарея — rc 0, 13/13 green, 50/50 `REJECTED_EXACT`. Таким состоянием поставочный test не доказывает нужное наблюдение, а батарея его принимает. |
| A-1 | закрыт | На C 50/50 `REJECTED_EXACT`, 0 BLOCKED/NOOP. |
| A-2 | закрыт | На C 0 NOOP; lane-fact принял clean и отверг все три заявленные подмены. |
| A-3 | закрыт | Живой async-факт проверил Promise.all N=2 по sink и собственным SQL rows. |
| A-4 | закрыт | Строгие ISO negative/positive формы исполнены `DRILL_INPUT_GUARD`. |
| A-5 | закрыт | Живой мультистейтмент дал NOT_RUN с правдивой причиной и без изменения таблицы. |
| A-6 | закрыт | PII-факты покрыли конечный перечень форм I-6 по содержимому sink. |
| A-7 | закрыт | DB-less runtime_role и разные nested-object hashes прочитаны из sink. |
| A-8 | закрыт | Clean/dirty/assume-unchanged/retag lane-сценарии: 0/1/1/1. |

## Регресс M1–M15

Полная C-матрица сама пересобрала и отвергла M1–M9 и M13–M15: 50/50 `REJECTED_EXACT`. Дополнительно:

* M10 (`BEGIN READ ONLY` → `BEGIN`) прошёл батарею: rc 0, 50/50. Мой живой вход `SELECT nextval('adv109r4_m10_seq')` дал `MEASURED`, rows `[{n:'1'}]`, а sequence last_value стал `1`. Это именно принятый арбитражем остаток для volatile `SELECT`, поэтому **совет, не блокер**.
* M11 (снять `readOnlySql`-фильтр) красный: battery rc 1, `ASYNC_TUPLE_GUARD=false`, 45 rejected/5 blocked; scoped integration также rc 1 с отсутствием честной read-only причины.
* M12 (`ROLLBACK` → `COMMIT` после READ ONLY) прошёл: rc 0, 50/50. При сохраняющемся `BEGIN READ ONLY` это эквивалентная форма, не обход I-4.

## Позитивный контроль и живые строки

* C: полная батарея rc 0; `control_green=true`, 13 facts green, 50/50 `REJECTED_EXACT`, 0 BLOCKED/NOOP.
* C: lint rc 0; `verify_handoff.py` PASS_STATIC / hashes PASS.
* Native PG18 `adv109r4pg`: `test:integration` rc 0, 44/44. Он же использовался для async/parallellism, multistatement и PII покрытия.
* `docker compose -p adv109r4stend … up -d --wait` rc 0; повтор rc 0; ledger `14:86f9283184f50eaa1b9ac0a642af274e`.
* Повреждённая копия `adv109r4damage`: up rc 1, migrator сообщил `SHA256 013_profile_release_permissions.sql не совпадает с манифестом`; API остался `Created`, не Running.
* Drill через delivery command: валидный offset-вход → MEASURED/rc 0; календарно-невалидный ISO → NOT_RUN/rc 2.

Все мои Docker ресурсы с префиксом `adv109r4` удалены: containers 0, volumes 0. Основной checkout не менялся.

## Советы

1. Добавить в батарею отдельный lint-факт либо явный `npm --prefix backend run -s lint`; иначе I-1 можно обходить одной корректно исполнимой неиспользуемой декларацией.
2. Для I-10 батарея должна исполнить именно delivery-тест или проверять его red-control: заменить тело живого теста no-op и требовать rc != 0. Проверка наличия файла/имени теста не доказывает его работу.
3. Если volatile SELECT требуется считать нарушением, это новый контракт: M10 измеренно меняет sequence при снятом READ ONLY, но конечный перечень явно оставляет этот класс за пределами I-4.
