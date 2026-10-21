# Контракт 127 — back-http-chislo: число операций и версия API в тестах HTTP-ядра Complior-back берутся из производного контракта

КЛАСС: КОДОВЫЙ (продукт Complior-back; тесты HTTP-ядра и smoke:http). Номер выдан механизмом (тег `id/CONTRACT/127`, строка registry/contracts.tsv в main). Строка плана `back-http-chislo` (форк n119-http-163, вариант Б).
КОНТЕКСТ: слово владельца 2026-10-21 ~12:35 UTC «да, давай Б» — запись docs/owner/2026-10-21-back-http-chislo.md: отдельный контракт вместо расширения зоны замороженного 119 (frozen/contracts/119/2); 127 приземляется в Complior-back ДО merge 119 (Complior-back#156 идёт потом на свежем main)
КОНТЕКСТ: продукт a3ka/Complior-back — main @ `e40cfa0121a0ab17cca6718e998c4e621292f326` (163 операции; fetch 2026-10-21 в одноразовый клон /tmp/dev-harness-verify/Architect127/back), импорт 3.15 @ `a498ea0d7081c56d39cd231fa9dca7bd6d85d3f4` (cmp-bck-315/import, #156, 233 операции)
КОНТЕКСТ: образец продуктового контракта — contracts/119-import-315-additivnoe-sliyanie.md; носитель батареи — fixtures/workshop_project/http_chislo_127/ (source.json — единый источник миров, пинов, ожиданий и стабов)

## Существующее (сверено живьём 2026-10-21, дерево — истина)

1. tests/contract/http.test.js @e40cfa0 (далее T): тест «производный контракт совпадает с корневым OpenAPI» пинит `assert.match(contracts.apiVersion, /^5\.8\.\d+$/)` (строка 70) и `assert.equal(contracts.operations.size, 163)` (строка 71); тест «реестр» — `assert.equal(srv.instance.registry.length, 163)` (строка 273). Там же УЖЕ есть `gen-contracts.js --check` и сверка `contracts.sourceSha256` с sha256 корневого YAML — они сохраняются (инвариант 3).
2. tests/tools/smoke-http.js @e40cfa0 (далее S): `prod.instance.registry.length === 163` и текст «production-реестр: 163 операции OpenAPI…» — сообщение проверки самого S; в server/src/http.js литерала 163 нет (grep `163` по файлу пуст).
3. Производный контракт app/schemas/{openapi,source}.json пишет `node tests/tools/gen-contracts.js` (npm `gen:contracts`), `--check` сверяет побайтово; загрузчик app/schemas/index.js (`loadContracts`: operations, apiVersion, sourceSha256); реестр сервера строится в server/src/http.js из `contracts.operations` (строки 192–254); версия ответа = info.version производного; принимаемое семейство — `VERSION_PATTERN = /^5\.8\.\d+$/` (http.js:19) и `pattern: ^5\.8\.\d+$` в корневом YAML (3 вхождения).
4. Счёт батареи (пары путь×метод с operationId в app/schemas/openapi.json): @e40cfa0 = 163, @a498ea0 = 233; info.version обоих 5.8.4; `git diff --stat e40cfa0 a498ea0 -- package.json package-lock.json` пуст — один node_modules на оба мира.
5. Прецеденты: 119 — миры и оракул продуктового контракта в fixtures/workshop_project/import315_119/; 121 — мир = `git archive` коммита продукта + node_modules продукта.

## Предмет и граница

Один наблюдаемый результат: **T и S не несут литералов числа операций и версии API — число берётся из производного контракта app/schemas/openapi.json и сверяется с загрузчиком и с реестром сервера, версия — info.version производного, и сервер обязан её принимать; исполнимая форма — `bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh --candidate <клон>` → rc 0**.

НЕ в предмете: server/src/http.js (замер §Замер: модель зелена на 233 без правки — ПЕРЕСЕЧЕНИЕ не заявляется); политика семейства версий сервера (VERSION_PATTERN и матрица 5.8.0/5.8.2/5.7.0/6.0.0 в T/S — runtime boundary I3); импорт 3.15 (119); app/, docs/, прочие тесты.

## Инварианты

1. Число операций в T и S — счёт по самому файлу app/schemas/openapi.json (не загрузчик, не docs/contracts/operation-index.json, не литерал); T сверяет его с `contracts.operations.size` и с `srv.instance.registry.length`, S — с `prod.instance.registry.length`.
2. Версия API в T — `contracts.apiVersion`; T сохраняет сверку `contracts.apiVersion` с info.version корневого YAML, шлёт apiVersion серверу заголовком `x-brokeros-contract` и требует 200 — сервер принимает собственную версию; литерального семейства на apiVersion нет.
3. Производный ≡ корневой: T сохраняет `gen-contracts.js --check` (производный = результат генератора) и сверку `contracts.sourceSha256` с sha256 корневого YAML; ни одна не заменяет другую — подмена производного без пересборки красна и при согласованных хэшах.
4. Каждая проверка инвариантов 1–3 судится своим дефектным миром, где краснеет ТОЛЬКО она (§Таблица проверок): удаление любой одной — красное в её мире.
5. T и S зелёны в каждом конформном мире (163, 233, синтетический 162, иная принятая версия 5.9.0) и красны в каждом дефектном (§Конструкция); ожидания — литералы source.json.

## Frontier

- **(А) Литерал 233 вместо 163** — ОТКАЗ: красен на main (163) до merge #156, слово владельца — 127 независимо от импорта.
- **(Б) Счёт по производному файлу + сверка с загрузчиком и реестром + версия производного, принятая сервером** — ВЫБРАН.
- **(В) Счёт через загрузчик (`contracts.operations.size`)** — ОТКАЗ: реестр строится из загрузчика, сверка «загрузчик = реестр» тавтологична при потере операции загрузчиком (мир wzagruzchik).
- **(Г) Расширить ЗОНУ замороженного 119** — ОТКАЗ словом владельца («да, давай Б»).

## Конструкция батареи (носитель — fixtures/workshop_project/http_chislo_127/)

Раннер `red_http_chislo_127.sh` → движок `http_chislo_127.py` (режимы и коды — его докстринг), ожидания — `source.json`, честная модель — `model/{http.test.js,smoke-http.js}`. Мир = `git archive` коммита из клона продукта (HTTP_CHISLO_127_BACK) в mktemp + symlink node_modules + мутации + (regen) `gen-contracts.js`; пины мира (derived_operations, api_version, gen_check_rc, index_operation_count, source_sha256_aktualen, derived_sha256_soglasovan) сверяются с построенным миром ДО запуска субъекта, несовпадение — rc 2 МИР-ОТКАЗ, не вердикт. Из кандидата берутся ТОЛЬКО T и S; вердикт — rc `node --test T` и `node S`.
Миры (13): конформные w163-baza (main), w233-import (#156), w162-sintez (из YAML удалён путь `/v1/evb/{evb_id}/issuance` без обработчика, regen; operation-index не пересобран и несёт 163), wver-prinyata (info.version 5.9.0, семейство 5.[89] в YAML и http.js, regen); дефектные wver-chuzhaya, wpodmena (пара app/schemas из #156 при YAML main, без regen — T красен и от --check, и от сверки sourceSha256), wreestr, wzagruzchik, wgen-check, wsha-proizvodnogo, wsha-zagruzchik, wver-zagruzchik, wzagruzchik-kompensirovan (замысел каждого — поле intent в source.json).
Обманные стабы (12): 7 выводятся движком из таблицы проверок — `bez-<проверка>`, удалена ровно её строка-якорь в модели; 5 ручных — literal-233, chislo-iz-indexa, versiya-literal, schet-cherez-zagruzchik (подмена источника счёта и версии), bez-sverki-s-kornevym (удалены обе сверки с корневым). Привязка к миру — поле `mir` в source.json и код `run_stubs` (контроль: модель сходится в том же мире, затем стаб); проза контракта привязку не утверждает (Н-39). Алфавит расхождений: `<T|S>:<мир>:ozhidalsya-<green|red>-fakt-<green|red>`.

## Таблица проверок (закрытая; единый источник — поле `proverki` source.json)

Закрытость: инварианты 1–3 называют ровно восемь проверок — семь в T/S и одну в загрузчике; источник счёта (файл) и источник версии — не проверки, а входы, их подмену судят ручные стабы. Движок при загрузке отказывает rc 2, если якорь проверки встречается в модели не ровно один раз или её мир не ждёт red от её субъекта; независимость мира закреплена пинами (wgen-check: `source_sha256_aktualen: true`, `derived_sha256_soglasovan: true`, `gen_check_rc: 1`). Строки (id — что судит — мир):

- gen-check — производный = результат генератора (`--check`) — wgen-check (путь удалён из openapi.json без пересборки, derived_sha256 обновлён, source_sha256 и YAML неизменны);
- source-sha — `contracts.sourceSha256` = sha256 YAML — wsha-zagruzchik (загрузчик отдаёт чужой хэш, файлы верны);
- derived-sha — sha256 openapi.json = derived_sha256 (загрузчик, вне T/S; стаба нет — кандидат её не удаляет) — wsha-proizvodnogo (T и S красны отказом загрузчика);
- versiya-korn — `contracts.apiVersion` = info.version YAML — wver-zagruzchik (загрузчик отдаёт 5.8.9);
- versiya-server — сервер принимает собственную версию — wver-chuzhaya;
- schet-zagruzchik — счёт файла = `contracts.operations.size` — wzagruzchik-kompensirovan (загрузчик теряет операцию, реестр возвращает её фантомом);
- schet-reestr-T — счёт файла = `srv.instance.registry.length` — wreestr;
- schet-reestr-S — счёт файла = `prod.instance.registry.length` — wreestr.

## Приёмочный критерий (команды, rc)

1. Дано текущий продукт (T/S @e40cfa0, sha256 по пину source.json); когда `bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh`; тогда rc 1 «ИТОГ 127 (продукт): миров 13, сошлось 10, расхождений 3» — расхождения T и S в w233-import и w162-sintez, T в wver-prinyata (замер 2026-10-21).
2. Правило: честная модель; `bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh --model`; rc 0 «ИТОГ 127 (модель): миров 13, сошлось 13, расхождений 0».
3. Правило: обманные стабы; `bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh --stabs`; rc 0 «ИТОГ 127 (стабы): стабов 12, поймано 12, непойманных 0» (замер ~68 с); негативная пара каждой строки таблицы — её стаб `bez-<id>`: модель в мире красна (КОНТРОЛЬ сошёлся), без проверки зелена (ПОЙМАН).
4. Дано клон implementer после правки T и S; когда `bash fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh --candidate <клон>`; тогда rc 0 «миров 13, сошлось 13». Негативная пара: `--candidate /tmp/dev-harness-verify/Architect127/back` (рабочее дерево main @e40cfa0 — литеральная реализация) → rc 1 «расхождений 3» (замер §Замер).
5. Дано имя мира вне source.json; когда `… --world net-takogo`; тогда rc 2 «нет такого мира»; дано клон без node_modules или без коммита мира (`HTTP_CHISLO_127_BACK=/nonexistent … --model`); тогда rc 2 NOT_IMPLEMENTED (замер §Замер).
6. Lane-паритет на доставленном клоне (база main): `node --test tests/contract/http.test.js` → rc 0 и `node tests/tools/smoke-http.js` → rc 0; после rebase #156 на свежий main — те же две команды rc 0 при 233 операциях без правки T/S.
7. `bash scripts/pre_critic.sh contracts/127-back-http-chislo.md` → rc 0 «КРИТИК: дверь зелёная»; `bash scripts/check_threat_model.sh . contracts/127-back-http-chislo.md` → rc 0.

## Зоны и раздача

ЗОНА architect: contracts/127-back-http-chislo.md fixtures/workshop_project/http_chislo_127/
ЗОНА implementer: tests/contract/http.test.js tests/tools/smoke-http.js
ПЕРЕСЕЧЕНИЕ implementer: tests/tools/smoke-http.js — 119 ЗОНА implementer 119/2 несёт каталог tests/tools/ продукта; #156 (a498ea0) этот файл не меняет (`git diff --stat e40cfa0 a498ea0 -- tests/tools/smoke-http.js` пуст), 127 правит в нём только счёт операций и текст проверки реестра, до merge 119

Пути ЗОНА implementer — от корня репозитория Complior-back (не харнесса). server/src/http.js — вне зоны (замер: не нужен); правка в нём требует нового круга с ПЕРЕСЕЧЕНИЕ-строкой и замером, что без неё S не проходит при 233. Ветка implementer — от main Complior-back (@e40cfa0 или новее), PR в main до merge #156. Зоны судей не заявляются (прецедент 112/996): вердикты кладутся ролями в verdicts/ роль-каноном.

ПРЕДПОСЫЛКИ:
- клон Complior-back со своим .git, коммитами e40cfa0 и a498ea0 и node_modules (`npm ci` на e40cfa0) — путь в HTTP_CHISLO_127_BACK; батарея секретов, сети и переменных окружения продукта не требует

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/http_chislo_127/red_http_chislo_127.sh

ПРОВОДКА-ЭНФОРСМЕНТ: красная батарея 127 — единственный guard; потребляется строками 1–5 приёмки и судами. Режимы --model/--stabs не самодостаточны: миры — коммиты продукта с node_modules (npm-дерева у харнесса нет), поэтому CI-шаг харнесса не заводится этим контрактом; решение о проводке (по образцу 996-E или NOT_RUN) — оркестратор, интеграционным коммитом ЗА реализацией; до него `check_provodka` rc 1 «guard не подключён» — НЕ блокер. Продуктовый энфорсмент — lane backend Complior-back (`npm test` включает tests/contract/, `npm run smoke:http`), строка 6 приёмки.

## Модель угроз

ЗАЩИЩАЕТ:
- от литерала числа операций в T или S (163, 233 или любое иное фиксированное число): мир w162-sintez несёт третий счёт, которого нет ни у одного продуктового коммита, а миры 163 и 233 различают оба продуктовых литерала;
- от счёта из документа, который не является производным контрактом (operation-index, корневые счётчики): в w162-sintez производный пересобран, а operation-index остаётся при 163;
- от счёта через загрузчик вместо файла и от отсутствия сверки с реестром сервера: wzagruzchik и wreestr теряют операцию по одну сторону сверки, и только сверка файла с загрузчиком и реестром различает их;
- от литерала версии и от тождественно истинной проверки версии: wver-prinyata (5.9.0 принята сервером) и wver-chuzhaya (5.9.0 сервером не принята) различают литерал семейства и пустую проверку;
- от удаления любой ОДНОЙ проверки инвариантов 1–3 при сохранении остальных (в частности, только `--check` при сохранённой сверке sourceSha256): у каждой проверки свой дефектный мир, где краснеет только она, — соседние проверки её не маскируют (§Таблица проверок; стабы bez-<id>);
- от подмены производного без пересборки при согласованных хэшах: wgen-check — актуальный source_sha256 и согласованный derived_sha256, но документ ≠ результат генератора; пересчёт хэшей его не отличает, отличает только `--check`;
- от несоответствия построенного мира замыслу: пины мира (включая актуальность source_sha256 и согласованность derived_sha256) сверяются до запуска субъекта, расхождение — rc 2, не вердикт кандидату.

НЕ ЗАЩИЩАЕТ:
- от кандидата, распознающего миры батареи (по версии 5.9.0, по отсутствию getEvbIssuance, по путям mktemp) и несущего литералы вне них: такой двойник строго сложнее честного счёта; ловец — ревью кода implementer и судьи реализации, cognitive-only;
- от смены семейства версий сервера без 5.8.x: матрица версий T/S (5.8.0, 5.8.2, 5.7.0, 6.0.0) — политика VERSION_PATTERN http.js, предмет I3, такой мир не конформен для 127;
- от дрейфа main после e40cfa0: режим «продукт» судит запиненные sha256 T/S, новый main требует обновления пина (rc 2, не молчаливое зелёное);
- от правок вне T и S (server/, app/, docs/): кандидат несёт только два файла, остальное дерево мира — из коммита продукта;
- от CI-проводки lane Complior-back до merge (NOT_RUN).

## Демаркация

Конформный мир: дерево Complior-back (коммит продукта или его мутация), где производный = `gen:contracts` корневого YAML (`--check` rc 0), реестр сервера = операции загрузчика = счёт файла app/schemas/openapi.json, и семейство VERSION_PATTERN сервера содержит и 5.8.x, и info.version производного. Конформная реализация T/S: зелена в каждом конформном мире и красна в каждом дефектном. Валидный контрпример = кандидат, чей вердикт расходится с ожиданием source.json на мире объявленной грамматики (именованное расхождение алфавита §Конструкция), инвариантный к именам каталогов миров.

## Замер (пройдено этой пачкой, числа из прогонов 2026-10-21)

- `… red_http_chislo_127.sh` → rc 1 «миров 13, сошлось 10, расхождений 3»; `--model` → rc 0 «миров 13, сошлось 13, расхождений 0»; `--stabs` → rc 0 «стабов 12, поймано 12, непойманных 0».
- `--candidate /tmp/dev-harness-verify/Architect127/back` → rc 1 «миров 13, сошлось 10, расхождений 3»; `--world net-takogo` → rc 2 «нет такого мира: net-takogo»; `HTTP_CHISLO_127_BACK=/nonexistent … --model` → rc 2 «NOT_IMPLEMENTED: нет клона продукта со своим .git».
- Обход критика круга 1 (независимые T/S без `gen-contracts.js --check`, сверка sourceSha256 сохранена; materialize.py критика): `--candidate` → rc 1 «миров 13, сошлось 12, расхождений 1» — `T:wgen-check:ozhidalsya-red-fakt-green`; тот же кандидат с `--check` → rc 0 «миров 13, сошлось 13».
- Модель в w233-import: T и S зелёны при неизменённом server/src/http.js — правка http.js для 233 не нужна.

## Остаточные риски

- R-1: батарея зависит от клона продукта с node_modules (HTTP_CHISLO_127_BACK); при его отсутствии — rc 2 NOT_IMPLEMENTED, не зелёное; самодостаточного режима для CI харнесса нет (npm-дерева у харнесса нет).
- R-2: двойник, распознающий миры (НЕ ЗАЩИЩАЕТ п.1) — cognitive-only, ловец — ревьюер.

## NOT_RUN (граница этого контракта)

- Правка T и S в Complior-back, PR и merge в main — implementer + оркестратор/владелец; после — rebase и merge 119 (#156).
- Проводка батареи в CI харнесса и lane Complior-back — оркестратор/консультант, ЗА реализацией.
