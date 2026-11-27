# СДАЧА 218 — различение свидетельства HEAD (Architect218d)

OBJECT=ca726d350306c7cb4a1e37a1c974cc57ef7c309b
Вход Adv218b: 696f860f47:verdicts/adversary/contracts-218-impl-v2.md.
Решение Arb218: 570f57b5b3:verdicts/arbitration/contracts-218-b1.md — «исправить».
Зона этой пачки — только fixtures/workshop_project/okno_frozen_v_pr_218/.
Frozen 218/1, production, CI и registry не изменяются. Production на OBJECT намеренно красна.
Базовый reference a32c577f292a2e925417d78a85cdb00abf25fae3 сохранён.

## Обещание и существующее

И2/И4: исторический accept допустим только после доказанного отсутствия пути на HEAD
и только для основания собственной заморозки. Ошибка чтения не является отсутствием;
пустое существующее тело не заменяется историческим. Наблюдение — rc/предметный диагноз
настоящего guard, неизменность HEAD/отслеживаемого состояния/кеша, Git Trace2.
Существующие World/observe, bare origin, plumbing, 108 клеток и 28 стабов переиспользованы.
Новые миры — contracts/plans, v2/v3: HEAD accept/FAIL/пустой, отсутствующий путь,
accept/FAIL/пустой/отсутствующий/чужой anchor, отказ чтения blob/дерева HEAD и anchor.
Все ожидаемые rc/диагнозы — в памяти до субъекта; файлы субъекта не оракул.

## Дельта-лист

| Блок | Способ | Свидетельство |
|---|---|---|
| Б-1 К-09 | канон/инструмент | model/pr_window.sh: успешный ls-tree -r -z --full-tree с literal-pathspec различает отсутствие записи; существующий blob читается по OID с проверкой rc; ошибка → PR_WINDOW_TAG_UNREADABLE |
| Б-1, пустое тело | клетка | head-empty против head-accept для обоих каталогов и версий; пустое тело даёт прежний отказ «без вердикта критика», не fallback |
| Б-1, настоящий отказ Git | клетка | head/anchor-missingblob: после целого контроля удаляется ровно loose blob, PATH прежний, затем точные байты объекта восстановлены до наблюдения состояния |
| Б-1, адресный отказ | клетка | head/anchor-catfault и treefault: rc 127 только выбранного свидетельства; injected подтверждает достижение; целый контроль выполняется на том же мире до отказа |
| Б-2 К-08 | клетка | собственный anchor accept → HEAD FAIL, парный HEAD accept; s29 и точная production-мутация Adv218b красны именно на head-fail |

Снятие/граница ослабили бы И2/И4. Git — канон фактов дерева, но не решения guard;
поэтому поведенческие клетки используют прежний observe. Новых production-механизмов нет.
Charter не проверяет accept критика: Б-1/Б-2 выбора тела к нему неприменимы.
Его прежние own-v2-delete-* до/после импорта проверяют собственную неразрешённую
правку контракта и сохранены, как и остальные charter/non-PR клетки.

Исполняемые привязки — stabs/*.json; stabs.tsv сверяется генерацией в catalog().
Новые s29–s35: приоритет anchor, пустое тело=отсутствие, ошибка blob=отсутствие,
ошибка дерева=отсутствие, отсутствие literal/full-tree, исходный cat-file || true +
пусто-строчный fallback. Последние два флага судятся структурным Trace2-свидетельством
EVIDENCE_TREE_CANON на успешных чтениях, а не выдаются за изменение rc на числовом пути.
Их честные контроли остаются rc 0; остальные новые стабы различаются поведением.
Старые стабы/связи не ослаблены.

## Двери и сырые rc

W = bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh
M = python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py

- production-красный · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --repo . · 1 · 1
- честная-модель · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --sintaksis · 0 · 0
- каталог · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- прежние-production-мутации · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py · 0 · 0
- точная-мутация-Adv218b · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py --adv218b-priority --only anchor-over-head · 0 · 0
- контекст · python3 fixtures/workshop_project/okno_frozen_v_pr_218/context.py · 0 · 0
- CI-паритет · bash scripts/gen_ci_steps.sh --check · 0 · 0

Синтаксис: VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck.
Полные pre_critic/check_sdacha/done и соседний регресс не запускались: это не done и не суд.
Исправленный production-кандидат ещё не предъявлен; implementer/оркестратор запускает
W --repo на нём и M --candidate <полный-SHA>, не на прежнем снимке.

## Измерения

CELLS: 108 → 164. MUTATIONS: 28 → 35. BINDINGS: 53 → 68.
Новые 56 клеток/7 стабов/15 связей — вывод catalog, не оценка на глаз.
Финальная модель: KLETKI=164 ZELENYE=164 KRASNYE=0, rc 0.
Финальные стабы: STABY=35 SVJAZI=68 POIMANY=68 ZHIVYH=0, rc 0.
Финальная production: KLETKI=164 ZELENYE=136 KRASNYE=28, rc 1.
Все прежние 108 клеток зелены. Красны только следующие новые:

```text
frozen-evidence-contracts-v2-head-empty
frozen-evidence-contracts-v2-head-missingblob
frozen-evidence-contracts-v2-head-catfault
frozen-evidence-contracts-v2-head-treefault
frozen-evidence-contracts-v2-anchor-missingblob
frozen-evidence-contracts-v2-anchor-catfault
frozen-evidence-contracts-v2-anchor-treefault
frozen-evidence-contracts-v3-head-empty
frozen-evidence-contracts-v3-head-missingblob
frozen-evidence-contracts-v3-head-catfault
frozen-evidence-contracts-v3-head-treefault
frozen-evidence-contracts-v3-anchor-missingblob
frozen-evidence-contracts-v3-anchor-catfault
frozen-evidence-contracts-v3-anchor-treefault
frozen-evidence-plans-v2-head-empty
frozen-evidence-plans-v2-head-missingblob
frozen-evidence-plans-v2-head-catfault
frozen-evidence-plans-v2-head-treefault
frozen-evidence-plans-v2-anchor-missingblob
frozen-evidence-plans-v2-anchor-catfault
frozen-evidence-plans-v2-anchor-treefault
frozen-evidence-plans-v3-head-empty
frozen-evidence-plans-v3-head-missingblob
frozen-evidence-plans-v3-head-catfault
frozen-evidence-plans-v3-head-treefault
frozen-evidence-plans-v3-anchor-missingblob
frozen-evidence-plans-v3-anchor-catfault
frozen-evidence-plans-v3-anchor-treefault
```

Пустой HEAD: subject rc 0 вместо 1. Head missingblob/catfault: rc 0 вместо 1
PR_WINDOW_TAG_UNREADABLE. Head treefault: прежний FAIL без именованного отказа,
нужная tree-операция отсутствует. Anchor missingblob/catfault: rc 1, но неверная
причина «без вердикта», потерян статус чтения. Anchor treefault: rc 0.
Пары HEAD FAIL и доказанное отсутствие с anchor accept зелены на OBJECT;
первая становится красной на мутанте предпочтения anchor.

Production mutation CANDIDATE=ca726d350306c7cb4a1e37a1c974cc57ef7c309b,
отдельные --no-hardlinks клоны, без изменения production рабочей копии:

| Мутант | Адресный контроль → мутант | Полный --repo |
|---|---|---|
| verdict-v1-only | frozen-verdict-contracts-v2-fail: GREEN rc=1 → RED rc=0 | rc 1, 128/164 зелёных |
| hide-roadmap | charter-two-documents-agents: GREEN rc=1 → RED rc=0 | rc 1, 134/164 зелёных |
| delta-errors-clean | charter-git-fault-diff-all: GREEN rc=1 → RED rc=0 | rc 1, 132/164 зелёных |
| anchor-over-head (точно Adv218b) | frozen-evidence-contracts-v2-head-fail: GREEN rc=1 → RED rc=0 | rc 1, 132/164 зелёных |

M: PRODUCTION_MUTANTS=3, rc 0. M --adv218b-priority --only anchor-over-head:
PRODUCTION_MUTANTS=1, rc 0. Мутация Adv218b дословно заменяет
`if [ "$PR_ACTIVE" -eq 1 ] && [ -z "$body" ]; then`
на `if [ "$PR_ACTIVE" -eq 1 ]; then` в check_contract_frozen.sh одноразового клона.
Поведенческая новая клетка краснит её до какого-либо отказа Git.
context.py: INTERSECTIONS=88, rc 0. CI generator --check: rc 0.

Технические первые прогоны не засчитаны как поимка: --sintaksis rc 2 без заданного
shellcheck; затем rc 2 из-за SC2094 (удаление private temp при выходе) и SC2034
(возвращаемый вызывающему CLI global). Локальные аннотации объясняют обе особенности;
с пинованным shellcheck окончательный синтаксис rc 0.
Первый exact-mutant прогон rc 2 обнаружил ошибку наблюдателя: неверный результат
проверяемого на intact-контроле ошибочно считался неисправностью среды. Теперь это
предметный RED INTACT_CONTROL; синтаксис/NOT_IMPLEMENTED/rc 2 остаются ошибкой среды.
Окончательные модель, стабы, exact-mutant и --repo выполнены после исправления.
Первый foreign-anchor мир не нёс собственной дельты удаления: исправлен мир,
собственное удаление теперь действительно попадает в scope; ожидание не ослаблено.

## Карта К-01…К-17

- К-01 · чисто · вход: исправительный task-architect218d.md; нового суда/freeze/done нет · - · -
- К-02 · чисто · вход: frozen 218/1, Adv218b и Arb218 прочитаны целиком · - · -
- К-03 · чисто · python3 fixtures/workshop_project/okno_frozen_v_pr_218/context.py · 0 · 0
- К-04 · чисто · вход: только назначенная семья; production-мутации только в одноразовых клонах · - · -
- К-05 · чисто · вход: все назначенные двери и сырые rc перечислены выше · - · -
- К-06 · чисто · вход: настоящий Git + missingblob без PATH, ошибки подготовки не поимка · - · -
- К-07 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- К-08 · чисто · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py --adv218b-priority --only anchor-over-head · 0 · 0
- К-09 · чисто · вход: обе ветви выбора свидетельства, несколько версий/каталогов, пустое тело/отсутствие/ошибка различаются · - · -
- К-10 · чисто · вход: литералы Cell, rc/диагноз, прежнее наблюдение состояния и Trace2 сохранены · - · -
- К-11 · чисто · вход: ожидания и точные bytes объекта сохранены до субъекта · - · -
- К-12 · чисто · вход: канон Git, stdlib JSON, TSV из JSON-реестра, bash -n и pinned shellcheck · - · -
- К-13 · н/п · вход: секретов/owner-identity нет; permissions только синтетические миры · - · -
- К-14 · чисто · вход: head-accept/anchor-accept/intact-контроли зелены; старые положительные клетки сохранены · - · -
- К-15 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- К-16 · чисто · вход: доверенная среда не расширяется; отказ настоящего Git явно в И2 · - · -
- К-17 · н/п · вход: станционный guard; продуктовой модели 188 нет · - · -

## Процессная рефлексия

Наблюдение: вложенный 60-секундный timeout полного CLI в production_mutants был
меньше суммы законных отдельных проб при нагрузке станции. Драйвер вызывает тот же
probe.main(['--repo', clone]) без вложенного общего deadline; прежние индивидуальные
60-секундные deadlines Git/subject не подняты. Ошибка intact-контроля теперь не
маскирует реальный дефект продукта rc 2. Журнал А-NN разрешён только коммитом main,
в этой wip-ветке не изменяется; наблюдение передаётся оркестратору этим разделом.
Scratch/клоны внутри собственной копии и вне субъекта; TemporaryDirectory удаляет их.
Push, owner-identity и --no-verify не использовались.
