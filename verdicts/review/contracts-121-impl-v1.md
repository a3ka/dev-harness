FAIL
Ревьюер (Rev121), контракт 121 frozen/contracts/121/1, OBJECT=ee213601ecb0305c4e7e1ab201f5c853b3be6724 (Complior-back PR#153, база B=c525fd8d43ce3f243f8d92be72e1eedfe5375f22), 2026-10-21. Находки: `/tmp/dev-harness-verify/Rev121/review.md` (reslop, status: ready). Блокируют R1–R4.

Резюме. DDL ядра 001–004 в продукте есть, его байты совпадают с пином, и на живой PG18 свойства этот DDL обеспечивает. Блокирует не DDL, а то, что предмет должен ДОКАЗАТЬ эти свойства исполняемыми тестами. Тесты сверяют флаги каталога и остаются зелёными на ядре, где свойства сломаны (R1, обход предъявлен). Новый набор ломает существующий шаг `test:integration`, и lane postgres продукта красный (R2, подтверждён CI PR#153). Evidence состоит из констант, рукописных записей и записи красного прогона, неотличимой от зелёной (R3). Нарушены стандарты 115 (R4).

## Обязательная сверка «§Предмет РЕАЛИЗОВАН» — DDL 001–004 на B и его свойства на PG18

| Проверка | Команда (своя мера) | Результат |
|---|---|---|
| sha256 001–004 на B и на C против пина | `git show <rev>:migrations/$f \| sha256sum` против `jq .product.migrations_sha256` | 4/4 `pin_eq=yes` (f2316a60…, ee5a91bd…, f573c4cd…, ef0aea49…) |
| migrations/app/server не тронуты | `git diff --quiet c525fd8 HEAD -- migrations app server` | rc 0 |
| 4а применение | `MIGRATION_DATABASE_URL=…/yadro121 node server/infrastructure/migrations/run.js --through 004` | **rc 0**, ledger `4\|1:001_core,2:002_rls,3:003_finance,4:004_runtime_role_fixes` |
| 4б повтор | тот же запуск | **rc 0**, «применено 0, в журнале 4»; md5 ledger (вкл. applied_at) `6be790d7…` до и после; отношений app/control 242 → 242 |
| 4в повреждённая копия | `row4v.sh` (байт дописан в копию 003) | **rc 1** «SHA256 003_finance.sql не совпадает с манифестом»; схем app/control в БД после отказа: 0 |
| FORCE | `ddl_probe.sql` P1 | таблиц app/control без FORCE: 0 |
| PUBLIC | P2 | ACL PUBLIC на relation 0, на schema 0; на функциях 17 (триггерные функции 003, вне зоны: совет A4) |
| BYPASSRLS/SUPERUSER brokeros_* | P3 | 0 |
| RLS поведением | P4 | superuser видит 2 scope, `SET ROLE brokeros_api` → 0 |
| immutable | P5/P5b | функция `app.guard_immutable` (тело из 004) отклоняет UPDATE («Immutable content … changed») и DELETE («cannot be deleted»), INSERT проходит; `guard_document_version`/`guard_approval` → `guard_immutable`, `tgenabled=O` |
| баланс журнала | P6 | журнал без проводок → на COMMIT `UNBALANCED_JOURNAL: …, count 0, sum 0`; строк после: 0 |
| effect-evidence SUCCEEDED | P7/P7b | `guard_outcome_evidence`: «Effect operation success requires matching successful receipt»; CHECK `NOT effect_required OR state<>'SUCCEEDED' OR outcome_evidence_ref IS NOT NULL` |
| аудит без контекста | P8 | `42501: ADMIN_AUDIT_CONTEXT_REQUIRED`, строка не вставлена |
| аудит с контекстом и redaction | P9 | provider_connection INSERT и UPDATE: `actor_principal_id`, `actor_database_role`, `admin_command_id=cmd-rev-1`; before/after без `secret_locator`/`account_reference`/значений: `f`/`f` |
| runtime UPDATE/DELETE аудита | P10 | ни у одной роли brokeros_* (кроме owner): 0 строк |

Итог сверки: DDL на месте и свойства обеспечивает. FAIL выносится по пункту «свойство доказано лишь имитацией (тест, который проходит без свойства)», см. R1.

## Ход суда по пунктам задания (rc всех прогонов)

**(а) ЗОНЫ.** `git diff --name-only c525fd8..OBJECT` даёт 17 путей; все лежат в ЗОНЕ implementer (tests/integration/core/ ×5, tests/helpers/pg18.js, docs/evidence/core/ ×6, package.json, tests/tools/run_backend_ci.py, docs/VALIDATION.json, FILES.sha256, docs/VERSION_MANIFEST.json). Заявленные 17 путей совпали с моим счётом. В package.json добавлен только `test:core` (+1 строка). В run_backend_ci.py добавлен +1 шаг в lane postgres, лейны не сужены. pg18.js расширен (добавлена `migratedThroughCore`, `migratedDatabase` не тронута). ПЕРЕСЕЧЕНИЕ «не сужает существующие лейны» нарушено ПОВЕДЕНИЕМ: существующий шаг `test:integration` краснеет, см. R2.

**(б) Оракул** (H=main харнесса, батарея с freeze не менялась: `git log frozen/contracts/121/1..HEAD -- fixtures/workshop_project/yadro_121/ contracts/121-…` пусто, `git diff --stat` пусто):
- `--model` → **rc 0**, «декоев отвергнуто ровно своими причинами: 16»;
- `--repo co_B` → **rc 1** `testy-otsutstvuyut`;
- `--repo co_C` → **rc 0**;
- `--repo ""` и `--repo <несуществующий>` → **rc 2**, «использование»; существующий пустой каталог → rc 1 `migracii-izmeneny`;
- NEEDS_ENV: `DOCKER_HOST` на несуществующий сокет → **rc 2** «NEEDS_ENV: … docker-демон не отвечает»; без `node_modules/pg` → **rc 2** «NEEDS_ENV: … нет …/node_modules/pg»;
- docker на станции есть (Server 28.3.3), образ по digest пина лежит локально, `select version()` = `PostgreSQL 18.6 (Debian 18.6-1.pgdg13+2) …`.

**(в) Тесты.** `npm run -s test:core` на БД 4а → **rc 0**, tests 20 / pass 20 / fail 0 (заявленные 20/20 совпали с моим счётом). DAMAGE ×4 своей мерой (`damage.sh`, свежая БД на каждую мутацию, контроль перед мутацией): force — контроль rc 0, мутация **rc 1** (fail 3); bypassrls — 0 / **1** (fail 2); immutable — 0 / **1** (fail 3); journal — 0 / **1** (fail 2). Красное на четырёх пробах пина предъявлено. Но тесты краснеют только на ЭТИХ четырёх флагах: `bypass.sql` → **rc 0** (R1). evidence: R3. `FILES.sha256`: `sha256sum --quiet -c` даёт rc 0, 675 записей = 676 tracked − сам файл, что совпадает с правилом `generate_derived.py`. У `VALIDATION.json`/`VERSION_MANIFEST.json` для ключей yadro121 генератора нет, их правят руками, как принято в репо (совет A3).

**(г) Стандарты.** В `co_C`: `npm run -s lint` → **rc 0**, `npm run -s test:standards-lint` → **rc 0**. Ручная сверка по CODING-STANDARDS §10/§12/§14/§16/§19 выявила нарушения (R4). По ARCHITECTURE.md (§«Миграции», RLS FORCE, раздельные роли) противоречий в диффе не нашёл.

**(д) Reviewer.** Батарея, пин, оракул и контракт с freeze не менялись (см. (б)), подгонки проверок под код нет. Коммит один, атомарный, автор `implementer <implementer@dev-harness.local>`, ссылка на 121 есть; форма не Conventional (совет A1). Сырой вывод имеет расхождение: заявленный зелёный путь верен только на БД, которую подготовил оракул. В lane CI продукта набор красный, и `test:integration` уже 64/44/20 (R2). CI PR#153 на head `ee213601…`: `postgres (PG18, migrations/health) fail`, `required fail`, остальные pass (`gh pr checks 153`).

**(е) Зелёный путь при несвойстве ядра:** состояние БД из `bypass.sql`. Флаги FORCE/NOBYPASSRLS/`tgenabled` целы, тела guard-функций пустые, открыты политика и PUBLIC, redaction снят, аудит стираем. На нём `test:core` **rc 0** 20/20 (R1). Оракул эту поверхность не покрывает, его DAMAGE ограничены четырьмя флагами (контракт: «КАК свойство наблюдается… — за судьями»). Поэтому ловец — этот суд.

## ПРОВОДКА (038)

`guard=fixtures/workshop_project/yadro_121/yadro_oracle.sh` существует и барьер именно этого предмета: rc 0/1/2 по строкам 1–3 подтверждены выше. Продуктовая проводка (`test:core` в lane postgres) подключена, но красная (R2), поэтому строку 4 lane CI продукта не закрывает.

## Паразитная сложность (050)

Таблица по каждому артефакту — в `review.md` §«Паразитная сложность». ACCIDENTAL: дубль sha ядра (3 места вместо 1), мёртвый `prefix`, ветка без `reuse` без потребителя, ключи VALIDATION/MANIFEST без потребителя. Всё это советы, потому что их блокирующая часть уже идёт через R2/R3.

## Чем закрыть

Закрыть R1–R4 по чекбоксам `review.md`. Повторный суд — на новом SHA: `bypass.sql` обязан краснеть `test:core`, lane postgres на свежем кластере обязан быть rc 0, evidence красного прогона не должен выглядеть зелёным.

Вердикт не закоммичен в репозиторий харнесса: задание назначило путь `/tmp/dev-harness-verify/Rev121/`, а запись в чекаут харнесса из этой сессии запрещена (Н-85). Интеграцию в `verdicts/review/` делает Main.
