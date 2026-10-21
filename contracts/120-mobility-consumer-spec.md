# Контракт 120 — спецификация mobility consumer v1 (M1 / CMP-BCK-315-CONSUMER-CONTRACT, после 119)

КЛАСС: СМЕШАННЫЙ — предмет некодовый (спецификация: шесть текстовых артефактов в продукте Complior-back), приёмка кодовая (оракул и красная батарея в fixtures/workshop_project/mobility_spec_120/ судят спецификацию машинно). Механизм судит форму, полноту, перекрёстные ссылки на факты продукта и непротиворечие импорту 119; СМЫСЛ спецификации — cognitive-only, принимает владелец (слово владельца 2026-10-21 ~01:05 UTC: «недостающую спецификацию дописывает наш architect, владелец принимает результат»).
КОНТЕКСТ: docs/owner/2026-10-21-backend-3-15.md — слово владельца, п.2 (четыре предмета спеки), п.3 (пять процессов на синтетических адаптерах), п.4 (эндпоинты приложения маклеров — после общего ядра)
КОНТЕКСТ: /home/harness/consultant/b315/ASTRA-REPORT-3.15.md — §2.1 покрытие пяти требований, §2.2 W5 gated, §5.2 ошибки бандла (18 строк), §7.2 M1
КОНТЕКСТ: продукт Complior-back — импорт 119 @ `0b0c413e209cda54f2d7c5d29667276f21661490` (cmp-bck-315/import, клон /tmp/dev-harness-verify/Impl119/back), смёржен в main merge-коммитом #156 → `45b946d06a5c2c6d5e0fa3b0fba66d07764acb63` (0b0c413 — его родитель, дерево идентично; замер R-1)

## Существующее (сверено живьём 2026-10-21 на 0b0c413, дерево — истина)

- KFZ_TERMINATION: есть в `PMServiceCode` (14 кодов, docs/sources/backend-3.15/platform-extension.yaml:9731) и в partner-пути; `PMConsumerCaseInput.service_code` несёт 12 кодов БЕЗ `KFZ_INSURANCE` и `KFZ_TERMINATION` (там же :9824–9851) — consumer Kündigung не создаётся. Consumer-спеки termination нет.
- Wunschkennzeichen: только `PLATE_RESERVATION` как kind зависимости (`PMDependency`, :10050–10100); lifecycle (проверка/резерв/чтение/истечение/отмена) не описан; `createPlateCheck` — в docs/contracts/deprecated-consumer-operations.json (18 deprecated операций).
- Ошибки §5.2: реестры 119 (tests/spec-3.15/known-issues-315.json, docs/sources/backend-3.15/provenance/KNOWN-ISSUES-DECLARED.json) несут 13 id (2 закрыты импортом + 11 открытых) на 16 из 18 строк §5.2: НЕ зарегистрированы строки `B/plans/delivery-plan.json:64–103; A:887` (partner-first граф) и `B/tools/validate_bundle.py:64–67` (exact projection). Независимая мера: разбор таблицы отчёта = 18 строк, совпадает с пином побайтово (прогон 2026-10-21). Внутреннее расхождение 119: `m1-a689-obeshchaniya-generacii` в disposition «Закрыто в импорте», но не в `resolved_by_this_import`.
- Release graph: docs/plans/delivery-plan-3.15.json — 7 шагов, `CONSUMER_MOBILITY` (W5) зависит от `PM_REGISTRATION` — partner-first; consumer-first графа нет.
- Published OpenAPI после 119: 233 операции, info.version 5.8.4; 16 consumer-операций `Mobility` (listMobilityServices … getMobilityOperation); consumer страхование/eVB — существующие quote/eVB операции ядра.
- Механизмы харнесса: батарея 119 (fixtures/workshop_project/import315_119/) — образец мира-фабрики, пина и стабов; check_document (027) судит док-пакеты харнесса по doc-контракту — здесь НЕ применяется (предмет — JSON-артефакты продукта, их судит оракул; прозу README судит владелец).

## Предмет и граница

Implementer пишет в Complior-back ЗАКРЫТЫЙ перечень артефактов спецификации; оракул 120 судит их. Ничего вне `docs/spec/mobility-consumer-v1/` не трогается, импорт 119 — побайтово (инвариант И-2). Правка OpenAPI по спеке — вне 120 (форк n120-openapi-delta, рекомендация Б).

Закрытый перечень (единый источник — `grammatika_120.json` поле `artifacts`; каталог `docs/spec/mobility-consumer-v1/` от корня Complior-back):

1. `README_RU.md` — человекочитаемая спека; на каждый JSON строка `- \`<файл>\`` (якорь строки).
2. `processes.json` — пять процессов v1: ZULASSUNG, ABMELDUNG, KENNZEICHEN_WUNSCH, VERSICHERUNG_EVB, KUENDIGUNG; коды услуг, существующие операции, новые операции, адаптер SYNTHETIC, реальный выпуск NOT_RUN с каналом-блокером, терминальный предикат с доказательствами.
3. `kfz-termination-consumer.json` — consumer KFZ_TERMINATION: аддитивное расширение consumer-кодов, проверки authority/eligibility/dates/contract target, не-заменители (cancelMobilityServiceCase, Widerruf), терминал TERMINATION_CONFIRMED только с VERIFIED, receipts ≥ 1, non-null датой; связь с Abmeldung — отдельный подтверждённый страховой исход.
4. `wunschkennzeichen-lifecycle.json` — автомат: состояния, начальное, терминальные, операции пяти видов (CHECK/RESERVE/READ/EXPIRE/CANCEL), переходы, поле истечения `expires_at`.
5. `bundle-errors-315.json` — все 18 строк §5.2 с кодами `E315-NN`: id, строки отчёта дословно, серьёзность, disposition из замкнутого алфавита, исправление, артефакт спеки для SPEC_120.
6. `release-graph.json` — consumer-first граф выпуска: SHARED_MOBILITY_CORE, пять PROCESS-узлов, CONSUMER_MOBILITY_V1, CONSUMER_MOBILITY_REAL, внешние зависимости, шесть PM_* шагов 119, BROKER_APP_ENDPOINTS.

## Инварианты (грамматика — `fixtures/workshop_project/mobility_spec_120/grammatika_120.json`; факты продукта — `pin_120.json`, снят `gen_pin_120.py` с 0b0c413)

- И-1 перечень: все шесть артефактов есть, JSON разбирается в объект (`spec-otsutstvuet`, `json-nevalidno`).
- И-2 граница: sha256 published, delivery-plan-3.15.json, обоих реестров known-issues = пин; против base_commit пина (`git diff --name-only` + неотслеживаемые) изменены ТОЛЬКО пути под `spec_dir` грамматики (`import119-izmenen`, `vne-zony`); base_commit пина отсутствует в клоне — rc 2 «нечем судить: base_commit пина отсутствует в клоне».
- И-3 процессы: ровно пять id; у каждого обязательный код услуги грамматики, все коды ⊆ PMServiceCode пина; адаптер SYNTHETIC, real_release.status NOT_RUN, blocked_by ∋ канал грамматики и ⊆ внешних зависимостей пина; существующие операции ⊆ 233 операций пина и ∉ deprecated; новые операции не совпадают с существующими и не дублируются; терминал requires_evidence ∧ server_predicate (`processy-nepolny`, `service-code-neizvesten`, `adapter-ne-sintetika`, `operaciya-neizvestna`, `operaciya-deprecated`, `novaya-operaciya-kollizija`, `terminal-bez-dokazatelstv`).
- И-4 termination: KFZ_TERMINATION в consumer-кодах; consumer-коды ⊇ 12 кодов 119 (аддитивно); проверки, не-заменители и связь с Abmeldung по грамматике; терминал не слабее VERIFIED/receipts ≥ 1/NON_NULL (`termination-consumer-net`, `termination-ne-additivno`, `termination-terminal-slab`).
- И-5 Wunschkennzeichen: обязательные состояния/терминальные/виды операций/поле истечения; операции ⊆ пин ∪ new_operations процесса KENNZEICHEN_WUNSCH и ∉ deprecated; переходы по объявленным состояниям и операциям, из терминальных переходов нет, CHECK/RESERVE/EXPIRE/CANCEL встречаются в переходах, все состояния достижимы из начального (`wunsch-lifecycle-nepolny`, `wunsch-avtomat-nekorrekten`).
- И-6 ошибки: грамматика code/id/severity/disposition/fix; строки отчёта покрыты ровно по разу и равны 18 строкам пина; id ⊇ 13 id 119; CLOSED_BY_119 = ровно два id `resolved_by_this_import` пина; пять строк из `spec_120_required` — SPEC_120 с названным артефактом (`oshibki-grammatika`, `oshibki-nepolny`, `oshibki-protivorechat-119`, `oshibki-ne-zakryty-specifikaciej`).
- И-7 граф: id уникальны, виды из алфавита, зависимости объявлены, четыре обязательных узла своих видов; КЛАСС узла с id из пина или грамматики выводится по id (внешние зависимости пина → EXTERNAL, шаги PM_* 119 → PARTNER, BROKER_APP_ENDPOINTS → BROKER_APP, пять процессов → PROCESS, ядро → SHARED, V1/REAL → CONSUMER), поле `kind` обязано с ним совпасть (`graf-kind-protiv-pina`); ацикличен; замыкание CONSUMER_MOBILITY_V1 по id ⊆ {SHARED_MOBILITY_CORE} ∪ пять процессов (каналы, PM_*, BROKER_APP и любые иные id — вне его, независимо от `kind`); PROCESS-узлы = пять процессов ∈ замыкания V1, V1 ∋ общее ядро; CONSUMER_MOBILITY_REAL ⊇ V1 и каналы процессов; EXTERNAL ⊆ пин; шесть PM_* шагов 119 есть, каждый PARTNER и BROKER_APP зависит от общего ядра (`graf-nevaliden`, `graf-kind-protiv-pina`, `graf-ciklichen`, `graf-ne-consumer-first`, `graf-nepolny`).
- И-8 README: строка-якорь на каждый из пяти JSON; упоминание в прозе не засчитывается (`readme-bez-ssylok`).

Алфавит причин оракула замкнут — 26 причин (`REASONS` в mobility_spec_oracle.py); первая красная проверка в фиксированном порядке И-1 → И-8.

## Боль и Frontier

Пары Н-NN к предмету в NABLIUDENIA.md/NABLIUDENIA_ARCHITECT.md нет (grep «специфик|mobility|consumer|бандл» 2026-10-21) — боль оформлена ЗАМЕРОМ из бандла и импорта:
- ЗАМЕР-1: реестры 119, собранные из прозы §5.2, потеряли 2 из 18 строк (именно release graph и exact projection) и разошлись сами с собой по a689 — проза без механизма теряет строки.
- ЗАМЕР-2: бандл обещал в прозе генерацию, которой генератор не делает (§5.2 A:689) — текст спеки без проверки расходится с артефактами.
- ЗАМЕР-3: consumer-запрет KFZ_TERMINATION и partner-first граф — в машиночитаемых файлах (enum, depends_on), а не в прозе; исправление судимо только там же.

Варианты:
- (А) Один документ-проза README — ОТКАЗ: ЗАМЕР-1/2, приёмка только чтением.
- (Б) Машиночитаемые JSON + README-указатель, оракул харнесса против пина продукта — ВЫБРАН: судит И-1…И-8, OpenAPI и код не трогает, смысл остаётся владельцу.
- (В) Сразу править platform-extension/published (KFZ_TERMINATION в PMConsumerCaseInput, операции Wunschkennzeichen) — ОТКАЗ в 120 по умолчанию: меняет wire до приёмки смысла, тянет I3 и lane 119; выбор границы вынесен в форк `forks/n120-openapi-delta.md` (МАРШРУТ консультант, БЛОКИРУЕТ нет).

## Конструкция батареи (носитель — fixtures/workshop_project/mobility_spec_120/)

`red_mobility_spec_120.sh` — раннер: живой режим (оракул на клоне продукта с реальным пином), `--model`, `--cell`. `mobility_spec_oracle.py` — оракул (правило 8: факты из пина в памяти проверяющего; дерево даёт только артефакты спеки и байты замороженных файлов). `gen_pin_120.py` — снятие пина с git-коммита продукта (18 строк §5.2 дословно — единый источник якорей). `model_mobility_120.py` — мир-фабрика из РЕАЛЬНОГО пина (233 операции, коды, каналы, шаги PM_*, id 119; пин мира снимается тем же gen_pin) и честная спецификация; 44 мутации. Клетки: m-baza (мир без спеки), k-model (честная спека), d01…d44 — ОДНА мутация каждая, красная СВОЕЙ причиной (d44 — rc 2 «нечем судить: base_commit пина отсутствует в клоне»); клетка ↔ причина — литералы таблицы CELLS раннера (Н-39), сверка `grep -Fxq` строки вердикта без деталей. Обманные стабы оракула: `stab_vsegda_zelenyj.sh`, `stab_vsegda_krasnyj.sh`. Обманные спецификации — сами клетки d*: правка плана 119 вместо нового графа (d04), KFZ_TERMINATION вместо 12 кодов (d17), CLOSED_BY_119 по тексту disposition 119 (d29), partner-first ребро прямое и транзитивное (d32/d33), канал страховщика в V1 под `kind` SHARED (d41 — обход критика круга 1 дословно) и под новым id-алиасом (d42), правка `tests/` вместо спеки (d43), deprecated-маршрут (d13), упоминание в прозе (d39).

## Приёмочный критерий (команды, rc)

1. Дано продукт @0b0c413 без спеки; когда `bash fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh`; тогда rc 1 «ОТКАЗ: mobility120: spec-otsutstvuet (README_RU.md)» (замер 2026-10-21; тот же rc и строка на клоне @45b946d06a). После поставки implementer: `bash … red_mobility_spec_120.sh <клон с поставкой>` → rc 0 `MOBILITY120_OK`.
2. `bash fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh --model` → rc 0 «ИТОГ 120: клеток 46, зелёных 46, красных 0» (замер 2026-10-21, ~8 с).
3. Негатив раннера: `bash … --cell net-takoj` → rc 2 «нет такой клетки» (замер).
4. Стабы: `MOBILITY120_ORACLE=<батарея>/stab_vsegda_zelenyj.sh bash … --model` → rc 1 «зелёных 1, красных 45»; `…/stab_vsegda_krasnyj.sh` → rc 1 «зелёных 2, красных 44» (замеры) — двунаправленная ловля.
5. Честная спека модели (`honest_spec` из model_mobility_120.py) на клоне продукта @45b946d06a с реальным пином → rc 0 `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real`; та же спека + мутация d41 → rc 1 «ОТКАЗ: mobility120: graf-kind-protiv-pina (insurer_sandbox: SHARED, по пину EXTERNAL)»; та же спека + файл в `tests/` → rc 1 «vne-zony» (замеры одноразовым скриптом 2026-10-21) — модель сходится с продуктом по идентификаторам, а не по игрушке.
6. Пин воспроизводим: `python3 fixtures/workshop_project/mobility_spec_120/gen_pin_120.py <клон> 0b0c413` → байты `pin_120.json` (сверка командой `cmp`, rc 0).
7. Обход критика круга 1 закрыт: `MOBILITY120_ORACLE=<оракул @584381337> bash … --cell d41-graf-kanal-pod-vidom-shared` → rc 1 (старый оракул: rc 0 `MOBILITY120_OK`); то же для d42, d43, d44 (замер) — новые клетки отличают прежний оракул.
8. `bash scripts/pre_critic.sh contracts/120-mobility-consumer-spec.md` → rc 0; `bash scripts/check_threat_model.sh . contracts/120-mobility-consumer-spec.md` → rc 0.
9. cognitive-only: смысл спецификации (правовая верность правил Kündigung и Wunschkennzeichen, тексты `fix`, проза README, полнота переходов сверх И-5) — принимает владелец; остаточный риск — спека формально зелёная при неверном смысле; ловец — владелец при приёмке результата.

## Зоны и раздача

ЗОНА architect: contracts/120-mobility-consumer-spec.md fixtures/workshop_project/mobility_spec_120/
ЗОНА implementer: docs/spec/mobility-consumer-v1/
ПЕРЕСЕЧЕНИЕ implementer: docs/spec/mobility-consumer-v1/ — 119 ЗОНА implementer несла каталог docs/ продукта; 120 только СОЗДАЁТ новый подкаталог, файлы импорта 119 побайтово неизменны (И-2, `import119-izmenen`)

Пути ЗОНА implementer — от корня репозитория Complior-back (не харнесса). Всё вне `docs/spec/mobility-consumer-v1/` — вне зоны (И-2, `vne-zony`). Ветка implementer — от main Complior-back @45b946d06a или его потомка (содержит 0b0c413 в истории, замер R-1).

Окружение батареи (CI-путей контракт не заявляет, поле предпосылок 122 не требуется): клон Complior-back со своим .git; ПРЕДПОСЫЛКА живого режима — клон содержит base_commit пина 0b0c413 (main @45b946d06a содержит; клон без него — rc 2 «нечем судить: base_commit пина отсутствует в клоне», лечение — перегенерация пина gen_pin_120.py на базе ветки); python3 с PyYAML; секретов, сети и переменных окружения продукта батарея не требует.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh

ПРОВОДКА-ЭНФОРСМЕНТ: красная батарея 120 — единственный guard; режим --model самодостаточен (миры в mktemp из пина, продукта не требует) и годен к CI харнесса по образцу 996-E (шаг `check:mobility-spec-120-family-selftest` = `bash fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh --model`) — оркестратор, интеграционным коммитом ЗА реализацией; до него `check_provodka` rc 1 «guard не подключён» — НЕ блокер. Продуктовый энфорсмент: оракул зелёный на доставленном клоне (строка 1 приёмки); lane Complior-back — NOT_RUN (wiring консультантом/владельцем).

## Модель угроз

ЗАЩИЩАЕТ:
- от неполной спецификации при самосогласованном дереве: перечни (пять процессов, 18 строк §5.2, 13 id 119, шесть шагов PM_*) берутся из пина и грамматики, не из файлов проверяемого;
- от выдуманных идентификаторов: операции, коды услуг, каналы сверяются с фактами продукта в пине; deprecated-маршруты и коллизии новых имён — именованные причины;
- от скрытой правки импорта 119, кода сервера или тестов вместо спеки: sha256 замороженных файлов и diff всего дерева против base_commit, где допустим только spec_dir;
- от слабого терминала: TERMINATION_CONFIRMED и терминалы процессов без доказательств — красные;
- от partner-first под видом consumer-first: класс узла выводится из пина по id, а не из поля `kind` проверяемого; замыкание V1 по id ограничено ядром и пятью процессами — канал под чужим `kind` или под новым id в V1 красный; ацикличность;
- от оракула-плацебо: двунаправленные стабы и 44 клетки своих причин.

НЕ ЗАЩИЩАЕТ:
- от неверного СМЫСЛА спеки, правовой неточности и прозы README — cognitive-only, владелец;
- от выбора иных имён/состояний сверх обязательных грамматики (грамматика открыта вверх: обязательный минимум, не перечисление всех значений);
- от дрейфа продукта после пина: пин снят с 0b0c413 (дерево = main @45b946d06a, замер R-1); коммиты main после 45b946d06a могут изменить замороженные файлы или пути вне spec_dir — ложно-красный `import119-izmenen`/`vne-zony`, лечение — перегенерация пина (R-1);
- от реализации процессов в коде (M3–M9) — спека не исполняет сценарии;
- от злонамеренного переписывания git-истории продукта под base_commit пина.

## Демаркация

Конформный мир: git-репозиторий раскладки Complior-back, содержащий base_commit пина, с замороженными файлами 119 байт-в-байт и каталогом `docs/spec/mobility-consumer-v1/` из шести артефактов. Конформная спека — любая, удовлетворяющая И-1…И-8 при ЛЮБЫХ значениях сверх обязательного минимума грамматики (имена новых операций по `new_operation_re`, дополнительные состояния, коды из PMServiceCode, дополнительные узлы ВНЕ замыкания CONSUMER_MOBILITY_V1 — замыкание V1 замкнуто по id: ядро и пять процессов). Валидный контрпример батарее = спека, расходящаяся с И-1…И-8 на конформном мире, которую оракул пропускает, либо конформная спека, которую оракул отвергает; расхождение по смыслу при соблюдении И-1…И-8 — не контрпример (cognitive-only, строка 9 приёмки).

## Остаточные риски

- R-1: ЗАМЕР 2026-10-21 (клон под /tmp/dev-harness-verify/Architect120b/back, fetch main с GitHub): main = merge-коммит 45b946d06a, 0b0c413 — его предок (`git merge-base --is-ancestor` rc 0), дерево идентично (`rev-parse <c>^{tree}` = a701ae89c2 у обоих; `git diff --stat 0b0c413 45b946d06a` пуст); пин на main отличается только `base_commit`. Пин остаётся на 0b0c413. Остаток: коммиты main после 45b946d06a могут дать ложно-красный `import119-izmenen`/`vne-zony` — направление ложно-красное; лечится перегенерацией пина gen_pin_120.py на коммите базы ветки implementer.
- R-2: грамматика задаёт обязательный минимум (пять видов операций Wunschkennzeichen, четыре проверки termination) — полнота сверх минимума cognitive-only.
- R-3: расхождение a689 внутри реестров 119 (disposition «закрыто» при отсутствии в resolved) спека не чинит: CLOSED_BY_119 обязан равняться resolved (клетка d29); правка реестров 119 — вне зоны.

## NOT_RUN (граница этого контракта)

- Правка OpenAPI/published по спеке (форк n120-openapi-delta), реализация процессов M3–M9, реальные каналы (договоры).
- CI-проводка батареи в харнессе и lane Complior-back — оркестратор / консультант после реализации.
- ТЗ дизайнеру на экраны mobility — консультант (слово владельца п.5).
