# СДАЧА 231 — формы done из закоммиченного конфига (R-0162)

ПРЕДМЕТ: совместимость трёх представлений done из config/done_forms.json: legacy-имена, точка станционного ПРОДУКТ, независимый вызов в v-носителе. Reference и адресные красные предъявления; production scripts/done_contract.sh не меняется. Слово владельца R-0162 требует данные вместо хардкода. Перед freeze 231 orchestrator оформляет адресные v+1 224/201 и их freeze.

## Обещание и наблюдение

Полный CLI, настоящий Git, rc и раздельные трубы, annotated done на исходном HEAD; отказ без тега и изменения HEAD. Ожидания и HEAD снимаются до субъекта, диагноз судится целой строкой в своей роли/пути. Конфиг и схема читаются из installation HEAD, отдельно от авторского репозитория/рабочей копии/индекса/окружения. Добавление новой формы только конфигом, удаление формы и изменение флага вызова измеряются поведением, не поиском строки в коде.

База задания b0ef65a93eeb03b58946cb57356ff6afa113e3aa. Прежний source-базис двери 568f0ea63271e3461b574105cba8faec7563a8fd сохранён: reference не откатывает production. Scratch/TMPDIR только внутри копии. VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck.

## Адресная дельта frozen

contracts/224-svezhest-verdikta-done.md:45–48: формы и сверка вызова делегированы конфигу 231. Явный vyzov-конфликт, неканоничный СУД и DUPLICATE сохранены. Отдельный коммит 2caf6a0f7; orchestrator переоформляет слово владельца.

contracts/201-done-dver-soderzhatelnaja-sverka.md:54: литерал без хвоста заменён допустимыми формами того же конфига. Отдельный коммит f0cf83f38; orchestrator переоформляет слово владельца.

review-conflict: было rc 1 VERDICT_ROUND_CONFLICT → стало rc 1 VERDICT_ROUND_DUPLICATE (ключ 3000000000).

adversary-conflict: было rc 1 VERDICT_ROUND_CONFLICT → стало rc 1 VERDICT_ROUND_DUPLICATE (ключ 3000000000).

Две клетки меняются одной общей записью markers['conflict'] в probe.py 224, отдельный коммит 65ad4cd35. Все прочие клетки 224/201 неизменны. Явный -vyzovN + несовпадающий СУД остаётся CONFLICT (historic186-bad-call-name, собственные explicit-conflict обеих ролей).

## Конструкция и различимость

Единый исполняемый источник допустимых форм — config/done_forms.json, не build.py или reference. JSON Schema — config/done_forms.schema.json; применяется настоящий validate_std json. MUTATIONS/build.py — единственный реестр связей стаб→вход; source.json/stabs.tsv сгенерированы. Прежние 78 клеток и 14 стабов/47 связей сохранены; probe.py базы меняется только добавлениями.

Честная добавленная форма имён zN и литерал ПРОДУКТ: мастерская появляются исключительно в конфиге мира, код субъекта неизменен. Удаление legacy-правила и станционного литерала отказывает; false plain_call_from_record возвращает проверку имени. Три hardcoded-* стаба различимы по своим config-name-added/product-config-added/config-call-disabled. config-ignored различим и на добавлении, и на удалении формы. Отдельные мутанты читают index, dirty installation, author cwd и env вместо installation HEAD. config-fail-open предъявляется каждому из missing/empty/broken/schema отдельно. Положительный config-equivalent сохраняет зелень при эквивалентном JSON с иным форматированием. Отсутствие инструмента/непостроенный мир/синтаксис — NOT_IMPLEMENTED rc 2, не поимка.

Полные blob frozen 215 и review 227 взяты без перепечатки (у 227 заменён только OBJECT и роль для парной проверки). Backend 181/179 и mobile 218 — точный перенос имён/топологий из измерения, не утверждение запуска настоящих проектов. owner/repo. сохраняется буквальным внешним адресом; станционная точка не распространяется на адрес.

## Измерения

Чистый origin-клон tmp/verify231-origin, кандидат 4a77f317cf2a47ba80b502a02eba052b81a0314a. Команда `python3 -B fixtures/workshop_project/done_round_compat_231/acceptance.py` последовательно исполнила все назначенные прогоны. Сырые stdout/stderr и results.json — tmp/acceptance231/ внутри клона.

| Команда | rc | Сырой итог |
|---|---|---|
| B --model | 0 | KLETKI 97 KRASNYH 0 |
| B --stabs | 0 | STABY 24 SVJAZI 68 ZHIVYH 0, CONTROL 97 зелёных |
| B --sintaksis | 0 | SINTAKSIS 26 SHELLCHECK 2 |
| B --catalog | 0 | KLETKI 97 STABY 24 SVJAZI 68 |
| B --repo . | 1 | KLETKI 97 KRASNYH 56, намеренная краснота до реализации |
| B --regression224 | 0 | KLETKI 100 KRASNYH 0; REGRESSION224_RAW_RC 0 |
| context.py | 0 | ДЕКЛАРАЦИИ 84 |
| validate_std json | 0 | конфиг соответствует схеме |
| pre_critic, первичный | 1 | неверные markdown-списки в немашинном разделе SDACHA |
| check_sdacha --run, первичный | 1 | та же строка 13; исправлена форма листа, не критерий |
| check_precision_gate | 0 | OK |
| check_spec_ready | 0 | OK |
| 224 --repo . (production) | 1 | KLETKI 100 KRASNYH 2, ровно review-conflict/adversary-conflict |
| 201 --repo . (production) | 0 | CELLS=62 STABS=0 FAILURES=0 |

B = bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh. Census до→после: клетки 78→97, стабы 14→24, связи 47→68. Прежние клетки/связи не удалены. Независимая мера — AST словарей/добавлений, фактические файлы стабов и строки TSV; probe.py — только добавления к b0ef65a93.

Список 56 намеренных красных: для КАЖДОЙ роли review/adversary — back181, back179, mobile218, krug, bare-duplicate, old-conflict-low, old-conflict-high, numeric-fail, numeric-accept, three-digits, ten-digits, old-zero, old-leading-zero, old-empty, krug-zero, krug-leading-zero, plain-call-high, plain-call-low, plain-v, plain-order, same-call, live227, config-name-added, config-name-removed; дополнительно product-live215, product-config-added, config-broken, config-empty, config-missing, config-schema, config-version, config-control.
Итог после исправления формы листа, кандидат 3b2742e0a089757b6278e2f346447f9559957fc1 в том же origin-клоне: pre_critic rc 0 («КРИТИК: дверь зелёная»); check_sdacha --run rc 0 («двери=7 карта=17/17 дельта=0»). Поведение двери/клетки/стабы не менялись; дорогие прогоны не повторялись ради исправления Markdown.

Независимый census: AST WORLDS=34 + добавлено 3, PRODUCTS=10 + добавлено 2, CONFIG_CASES=9 + ещё 2; итог (34+3)×2+(10+2)+9+2=97. Файлов стабов 24, строк TSV 68. `git diff --numstat b0ef65a93eeb03b58946cb57356ff6afa113e3aa -- fixtures/workshop_project/done_round_compat_231/probe.py` → 89 добавлений, 0 удалений.


## Двери

- Sintaksis · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --catalog · 0 · 0
- Schema · bash scripts/validate_std.sh json config/done_forms.schema.json config/done_forms.json · 0 · 0
- Context · fixtures/workshop_project/done_round_compat_231/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Consumer · bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Precritic · bash scripts/pre_critic.sh contracts/231-sovmestimost-doski-224.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы ниже, pinned shellcheck и validate_std json · - · -
- К-02 · чисто · вход: task-architect231.md и task-architect231b.md прочитаны целиком, R-0162 исполняется данными · - · -
- К-03 · чисто · вход: переход v+1 224/201 до freeze 231, слово владельца оформляет orchestrator · - · -
- К-04 · чисто · вход: context.py перечисляет высшие frozen и их зоны, адресная дельта 224/201 выделена коммитами · - · -
- К-05 · чисто · вход: B --model/--repo, rc/трубы/tag/HEAD; legacy/215/227 без переименований · - · -
- К-06 · чисто · вход: ошибка среды/таймаут/синтаксис rc 2 NOT_IMPLEMENTED, не предметная поимка · - · -
- К-07 · чисто · вход: B --model; честный config-equivalent, положительные формы ставят annotated done · - · -
- К-08 · чисто · вход: B --stabs; каждый адресный вызов самостоятелен, hardcoded формы различимы изменением конфига · - · -
- К-09 · чисто · вход: review/adversary, оба направления конфликта, numeric 2/10/100 и две координаты · - · -
- К-10 · чисто · вход: committed installation HEAD против index/worktree/author/env, ожидания до субъекта · - · -
- К-11 · чисто · вход: source.json хеширует носители, TSV побайтово из MUTATIONS; оракул не читает выход субъекта как истину · - · -
- К-12 · чисто · вход: bash -n, pinned shellcheck, JSON Schema через validate_std; собственного JSON/YAML-валидатора нет · - · -
- К-13 · н/п · новых credentials и внешней сети в оракуле нет · - · -
- К-14 · чисто · вход: station без/с точкой, literal owner/repo., filename-only, equal-call, explicit-equal и JSON-equivalent · - · -
- К-15 · чисто · вход: --catalog и независимый AST/FS/TSV census, прежние 78/14/47 сохранены · - · -
- К-16 · чисто · вход: границы по свойствам и ловцам; несовместимые frozen переводятся адресным v+1, не прячутся · - · -
- К-17 · н/п · продуктовая модель 188 не объявлена, новых операций/writer/scope_id нет · - · -

## Наблюдение процесса

Кандидат main-журнала без самовольной нумерации: конфиг-происхождение требует различать installation HEAD и author HEAD в фикстурах; прежний install 224 копировал только scripts/, потому не моделировал эту границу. Цена — явная Git-установка с собственным committed config/schema в новых мирах; источник — условие R-0162; класс — конструкция наблюдателя. Закрыто install_policy/prepare_policy и отдельными адресными мутантами источника. Общий NABLIUDENIA_ARCHITECT.md в wip не меняется; запись в main — orchestrator.
