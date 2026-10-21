FAIL
Контракт 121 не готов к заморозке: приёмка принимает тесты без проверок БД и выдуманное native-evidence. Два обхода воспроизведены. Дополнительно самопроверка модели на предъявленном HEAD красна: evidence-файлы мини-мира не закоммичены.

Предмет: `contracts/121-cmp-bck-003-yadro-bd.md` на **6b2ccb11bddb53599cf45a514c8720685a446ae6**, ветка `wip/121/architect`. Судился отдельный клон этого коммита, не рабочее дерево автора. База продукта B: **c525fd8d43ce3f243f8d92be72e1eedfe5375f22**. Источник требований: `gh api repos/a3ka/Complior-back/issues/4 --jq '.title,.body'`, rc 0.

Закоммиченный предмет, критерий с командами, исполнители и ЗОНА-строки есть: оснований для немедленного отказа без разбора нет. Контракт и батарея автора не исправлялись. Вердикт коммитит оркестратор по условиям задания; push не выполнялся.

## Блокирующие находки

### Б1. Маркеры и rc тестового раннера не доказывают SQL-проверки

БЛОКИРУЕТ contracts/121-cmp-bck-003-yadro-bd.md:36 — инвариант «свойства доказаны ИСПОЛНЯЕМЫМИ тестами» сводится в приёмке, строки 47–49, к маркерам в четырёх файлах и `npm run test:core` rc 0. Батарея не отличает проверку RLS/immutable/finance/audit от комментариев с нужными словами. Строка 4г не вводит независимого поведенческого оракула, который отвергнет такой тестовый пакет. Это также противоречит AGENTS.md §«Воркфлоу майлстоуна», п.1: кодовый критерий должен краснеть на обманном дереве, а не оставлять «то ли сделано» чтению судьи.
ОБХОД: на настоящую B добавлены четыре tests/integration/core/*.test.js только из `'use strict';` и комментариев с литералами пина; `test:core = node --test tests/integration/core/*.test.js`. Исходные runner, миграции и существующие npm-скрипты сохранены. `--repo` даёт **rc 0**, `npm run test:core` — **rc 0**, хотя ни SQL, ни assertions в тестах нет. Версия с `require('node:test')('unconditional green', () => {});` также даёт **rc 0/0**. Это не отсутствие среды: тот же noop-пакет исполнен с доступной отдельной native PostgreSQL 18.6 — **rc 0**, батарея — **rc 0**. На ней настоящий runner B применил 001–004: **rc 0**, четыре строки ledger; повтор — **rc 0**, «применено 0», ledger равен первому. Следовательно, существующий runner закрывает 4а–б, а новая работа 121 — доказательства свойств — отсутствует при зелёных командах 3/4г. Прогоны: `probe-results.json` — `comment_only_tests_fabricated_evidence`, `npm_core_without_database`, `unconditional_green_tests`, `npm_unconditional_green`; `native-results.json` — `noop_tests_native_env`, `oracle_native_env_noop_tests`.

Механизм: `fixtures/workshop_project/yadro_121/yadro_oracle.sh:53-74` проверяет существование файлов, подстроки, наличие npm-ключа/lane-литерала. Комментарий `# test:core` в lane-файле тоже засчитывается как проводка, хотя ничего не запускает. Для обхода SQL-проверок фиктивная проводка не обязательна: реально исполняемый `npm run test:core` уже показал ложное зелёное.

Не утверждается прохождение полного CI/lint или всей строки 4 этим деревом: они не запускались. Обход относится к механическим критериям доказательства SQL-свойств. Красная модель ниже — отдельный дефект упаковки, а не защита от продуктового обхода.

Нужно независимое поведенческое различение настоящих SQL-проверок и заглушек, чтобы отсутствие обращения к БД/проверки результата не могло закрыть критерии 2–4 и 6 issue. Пары «стаб ↔ ветвь» остаются в коде батареи, не в прозе контракта.

### Б2. Native-evidence принимается на доверии к изменяемой метке

БЛОКИРУЕТ contracts/121-cmp-bck-003-yadro-bd.md:37 — evidence-честность и приёмка 4д (строка 48) проверяют только `mode` и ненулевое присутствие трёх полей. Источник SQL/роли/ошибок и связь с исполненным native-прогоном не проверяются. Это слабее критерия 5 issue и заявления «PGlite-запись доказательством native не является».
ОБХОД: в разрешённой зоне docs/evidence/core/ вручную созданы два run.json: `{"mode":"RUNTIME","sql":[],"role":"","errors":[]}` и `{"mode":"PGLITE"}`. Батарея **rc 0**, хотя первый файл не содержит ни SQL, ни роли, ни результата исполнения. Затем первый заменён на `{"mode":"RUNTIME","engine":"PGlite","sql":["select 1"],"role":"brokeros_api","errors":[],"concurrency":"verified"}`; батарея снова **rc 0**. Перемена/заполнение mode позволяет объявить PGlite native без native evidence. Прогоны: `probe-results.json`, `comment_only_tests_fabricated_evidence`, `pglite_relabelled_native`.

Механизм: `fixtures/workshop_project/yadro_121/yadro_oracle.sh:78-97`, два mode и `getpath([$f]) != null`. Отказ лёгкого оракула самостоятельно поднимать PG допустим, но не освобождает приёмку от доказательства происхождения результатов. Сейчас автор результатов и проверяющий доверяют одним изменяемым полям. Ещё один текстовый маркер эту дыру не закрывает.

## Советы и ограничения — не самостоятельные блокеры

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:46 — на HEAD `--model` возвращает **rc 1**, `ОТКАЗ: yadro121: evidence-otsutstvuet`, а не заявленный rc 0/7 декоев. `git ls-tree -r --name-only HEAD fixtures/workshop_project/yadro_121` не содержит `toy_yadro121/docs/evidence/.../run.json`; код требует `20261021T000000Z.native/run.json` и `20261021T000000Z.pglite/run.json`. В `.gitignore:31` есть общее `evidence/`. Отсутствие файлов в коммите установлено; локальное наличие у автора не судилось. Это препятствие честному зелёному, не отдельный обход, поэтому по порогу роли совет. Заявленный модельный замер нельзя принимать до его предъявления на закоммиченном наборе.

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:49 — карта issue неполна по содержанию, хотя перечисляет шесть номеров. В 4г нет явных сценариев brokeros_api с revoked/expired context и запрета стать owner; для immutable — положительного разрешённого перехода с generated columns. В работах issue также названы composite FK/cross-scope parents, trusted UUID issuer, уникальность receipt и атомарность receipt/domain/outbox, integer minor units/money projection, цепочка 005/006. Их нельзя заменить FORCE/finance-маркерами. Не отдельный блокер без дополнительного прогона: измеренный обход отсутствия SQL-проверок уже Б1. Полноту сценариев следует определить до раздачи, не оставлять исполнителю угадывать по именам файлов.

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:21 — раздела `## Источники` нет. `docs/CODING-STANDARDS.md` упомянут в строке 22, оба документа `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` — в строке 77. Источники не забыты по существу, но требование задания о внесении обоих в `## Источники` не выполнено. Переходная норма требует сверки диффа с обоими документами; lint строки 50 не доказывает архитектурного соответствия.

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:48 — подготовка `docker compose -f compose.dev.yml up -d --wait` запускает migrator без `--through`, то есть всю цепочку, а критерий затем требует пустую БД и ledger=4. Это видно в B `compose.dev.yml:45-58`; helper `tests/helpers/pg18.js` также применяет всю цепочку и чистит общие роли. Следует определить изолированную пустую БД для 001–004. Мой scoped-прогон использовал отдельный контейнер, не общий helper; compose целиком не запускался. Это препятствие честной приёмке, не самостоятельное ложное зелёное.

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:35 — диагностический runner `console.error('не совпадает с манифестом'); process.exit(1);` принимается батареей, **rc 0**, хотя не применяет DDL/не пишет ledger. Runner `process.exit(0)` отвергается: **rc 1 ranner-ne-otkazyvaet**. Это не блокер 121: runner вне ЗОНА implementer, объявлен внешним фактом, а живая 4а отвергнет всегда-красный runner. Damage-проба не доказывает положительное исполнение. Пробы выполнены только в своём клоне; оригинальные bytes восстановлены.

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:37 — запрет ключей secret_locator/account_reference не соблюдается буквально: значения null принимаются, **rc 0**, `null_secret_keys`. Строковое значение правильно отвергнуто: **rc 1 evidence-sekrety**, `scalar_secret_rejected`. Это расхождение грамматики и jq `paths(scalars)`, не доказанная утечка секрета.

## Зоны, нормы и карта критериев issue #4

- Зоны всех исполнителей объявлены. Продуктовая зона: tests/integration/core/, tests/helpers/, docs/evidence/core/, package.json, tests/tools/run_backend_ci.py, docs/VALIDATION.json, FILES.sha256, docs/VERSION_MANIFEST.json. Существующие пути сверены с B; новые core-каталоги объявлены результатом. Старый backend/ не используется. migrations/ и runner вне правки. Необходимой правки вне зоны по указанному предмету не установлено.
- ПЕРЕСЕЧЕНИЕ общих файлов есть; чужие скрипты/lanes запрещено сужать. `check_precision_gate.sh` — **rc 0, OK**. Это механическая проверка, не замена суждению о продуктовой области.
- Н-39: конкретных пар «стаб ↔ ветвь» в контракте нет; привязки находятся в коде батареи. `pre_critic.sh` — **rc 0**, «КРИТИК: дверь зелёная».
- Модель угроз: оба списка есть, `check_threat_model.sh` — **rc 0**, ЗАЩИЩАЕТ 8 / НЕ ЗАЩИЩАЕТ 4. Смысловой разрыв evidence указан в Б2.
- К1: независимый pin 001–004 работает. Замена 003 на `BEGIN; COMMIT;` вместе с новым product manifest отвергнута **rc 1 migracii-izmeneny**. Harness-pin не менялся — он вне полномочий implementer. Настоящий B на native PG: первый/повтор rc 0, ledger 4/4. Damage-пробу выполняет батарея; её успех не доказывает crash-атомарность.
- К2: scope brokeros_api обозначен, но noop зелёный (Б1); revoked/expired и owner в 4г не названы.
- К3: отрицательные immutable-проверки перечислены, положительный generated transition не зафиксирован; noop зелёный (Б1).
- К4: journal/effect/rollback перечислены, исполняемая семантика от noop не различается (Б1).
- К5: метки native/PGlite различаются, происхождение/содержание не доказано (Б2).
- К6: context, audit metadata, роли, запрет UPDATE/DELETE названы; marker-only noop принимается (Б1), реально полученные SQL-ошибки не подтверждаются evidence (Б2).
- Проводку батареи в registry/ci-steps.tsv + package.json + ci.yml харнесса делает ОРКЕСТРАТОР отдельным интеграционным коммитом. Известный `check_provodka` rc 1 до него НЕ использован как блокер; повторно он не запускался.

## Исполненные команды и rc

`H=/tmp/dev-harness-verify/Critic121/repo`, `P=/tmp/dev-harness-verify/Critic121/product` — отдельные клоны с собственным .git. Worktree автора и исходные checkout продукта не изменялись.

| Команда/проба | rc | Результат |
|---|---:|---|
| `bash H/fixtures/workshop_project/yadro_121/yadro_oracle.sh --model` | 1 | evidence-otsutstvuet, до декоев не дошло |
| `bash …/yadro_oracle.sh --repo /tmp/dev-harness-verify/Architect121/prodB` | 1 | testy-otsutstvuyut |
| `bash …/yadro_oracle.sh --invalid` | 2 | использование |
| `bash …/yadro_oracle.sh --repo /tmp/dev-harness-verify/Critic121/nonexistent` | 2 | использование |
| `bash scripts/check_precision_gate.sh H contracts/121-cmp-bck-003-yadro-bd.md` | 0 | OK |
| `bash scripts/check_threat_model.sh H contracts/121-cmp-bck-003-yadro-bd.md` | 0 | форма валидна |
| `bash scripts/pre_critic.sh contracts/121-cmp-bck-003-yadro-bd.md` | 0 | дверь зелёная |
| `python3 /tmp/dev-harness-verify/Critic121/probe.py` | 0 | сбор результатов завершён; внутренние rc ниже |
| комментарии-маркеры + выдуманное evidence, `--repo` | 0 | Б1/Б2 |
| `npm run test:core`, comment-only, недоступный DB URL | 0 | четыре файла без SQL/assertions |
| полностью пустой rls.test.js, `--repo` | 1 | rls-bez-force |
| безусловно зелёные cases, `--repo` / `npm run test:core` | 0 / 0 | Б1 |
| PGlite как native, `--repo` | 0 | Б2 |
| строковый secret_locator | 1 | evidence-sekrety |
| null-ключи secret_locator/account_reference | 0 | расхождение грамматики |
| no-DDL SQL + обновлённый product manifest | 1 | migracii-izmeneny |
| noop runner rc 0 | 1 | ranner-ne-otkazyvaet |
| всегда-отказывающий runner rc 1 | 0 | граница вне зоны |
| `node /tmp/dev-harness-verify/Critic121/native-probe.js` | 0 | PG18.6: первый runner 0, повтор 0, noop tests 0, oracle 0 |
| `docker stop critic121-pg` | 0 | контейнер удалён (--rm), данные были tmpfs |

Сырые результаты: `/tmp/dev-harness-verify/Critic121/probe-results.json`, `/tmp/dev-harness-verify/Critic121/native-results.json`. Скрипты воспроизведения: `probe.py`, `native-probe.js` там же. Для повторения нужны клоны H/P на указанных SHA и зависимости pg; адрес в native-probe соответствует удалённому одноразовому контейнеру этого прогона и должен быть заменён фактическим портом нового. Полный CI, lint, настоящие runtime-RLS/finance/audit тесты не запускались и пройденными не объявляются.

Пять вопросов критика: критерий слабее предмета — Б1/Б2; команды не доказывают заявленное — те же обходы; решения оставлены исполнителю — полнота SQL-сценариев и подготовка чистой БД; границы раздачи названы и механически зелёные; противоречие кодовой норме AGENTS.md о различении имитации — Б1. Заморозку по этому объекту не разрешать.
