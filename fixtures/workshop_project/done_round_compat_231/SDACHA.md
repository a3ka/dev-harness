# СДАЧА 231 — совместимость входов существующей done-двери

ПРЕДМЕТ: три представления из затравки owner и обоих дополнений: legacy имена, точка станционного ПРОДУКТ, независимый вызов в v-носителе. Production, frozen и прежние клетки не меняются. Результат — контракт, поведенческий reference и адресная красная батарея. Это НЕ разрешение freeze при конфликте frozen.

## Обещание и наблюдение

Полный done CLI на настоящих Git-мирах, rc и обе трубы, annotated done-тег на исходном HEAD. При отказе тега нет, HEAD не меняется. Все ожидания/HEAD/hash носителей — в памяти проверяющего до субъекта. Диагноз проверяется целой строкой с ролью и структурой полного пути, а не подстрокой. SHA и продуктовые идентификаторы не являются логикой production/reference.

База после fetch/switch: 568f0ea63271e3461b574105cba8faec7563a8fd. Изолированная копия — выданный actual cwd; WORKTREE из задания только адрес доставки. Scratch и TMPDIR — внутри tmp/scratch-arch231. Shellcheck — /home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck (передаётся VALIDATE_STD_SHELLCHECK).

## Сырые поведенческие результаты

Последовательные прогоны до листа, без параллельных батарей:

| Команда | rc | Сырой итог |
|---|---|---|
| B --model | 0 | KLETKI 78 KRASNYH 0 |
| B --stabs | 0 | STABY 14 SVJAZI 47 ZHIVYH 0; честный CONTROL 78 зелёных |
| B --sintaksis | 0 | SINTAKSIS 16 SHELLCHECK 2 |
| B --catalog | 0 | KLETKI 78 STABY 14 SVJAZI 47 |
| B --repo . | 1 | KLETKI 78 KRASNYH 45 — намеренная краснота до реализации |
| python3 -B fixtures/workshop_project/done_round_compat_231/context.py | 0 | ДЕКЛАРАЦИИ 76; источники высших frozen и реальные зоны |
| B --regression224 | 1 | KLETKI 100 KRASNYH 2; REGRESSION224_RAW_RC 1 |
| bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo . | 0 | KLETKI 100 KRASNYH 0 |
| bash scripts/check_precision_gate.sh . contracts/231-sovmestimost-doski-224.md | 0 | OK |
| bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md | 0 | OK |
| bash scripts/pre_critic.sh contracts/231-sovmestimost-doski-224.md | 0 | КРИТИК: дверь зелёная (только форма, не разрешение frozen) |
| SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh . contracts/231-sovmestimost-doski-224.md --run | 0 | СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=0) |
| bash scripts/check_provodka.sh . contracts/231-sovmestimost-doski-224.md | 1 | guard не подключён — CI-проводка в зоне orchestrator после решения frozen |

B означает bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh. Эта таблица — уже исполненные поведенческие замеры, не ещё одна очередь повторных дорогостоящих прогонов. Машинные двери ниже проверяют форму; их зелень не превращает конфликт в разрешение.

Независимый census через ast.literal_eval словарей probe.py и реальные файлы/TSV: WORLD_ROWS 34, PRODUCT_ROWS 10, CASES 78; STAB_FILES 14, TSV_ROWS 47. Он не повторяет carriers()/--catalog. Первоначальный pre_critic отказал на отсутствии формальной секции требований: check_ceilings требует её даже у полностью заполненного контракта. Добавлено только «нет»; исходный список незаполненных требований затравки удалён. После этого pre_critic и check_sdacha дали rc 0.

Намеренные красные --repo: для КАЖДОЙ роли review/adversary — back181, back179, mobile218, krug, bare-duplicate, old-conflict-low/high, numeric-fail/accept, three-digits, ten-digits, old-zero/leading-zero/empty, krug-zero/leading-zero, plain-call-high/low, plain-v, plain-order, same-call, live227; дополнительно product-live215. Это 22 на роль и одна станционная клетка, всего 45. Остальные 33 клетки зелены.

## Frozen-конфликт — блок допуска

frozen 224: contracts/224-svezhest-verdikta-done.md:45/46/48. Старая грамматика не объявляет legacy; главное прямое противоречие — И2 требует равенство вызова номеру общего v-имени без поколения фазы. Старая probe.py:285 и :318–325 требует CONFLICT на review-conflict/adversary-conflict. На совместимом reference оба теперь дают DUPLICATE с ключом 3000000000, rc субъекта 1, тега нет. Наблюдатель старой батареи честно отмечает DIAGNOSIS и итог rc 1; 98 других клеток зелены. Не менялись ни старый наблюдатель, ни ожидания, ни текст frozen.

Дополнительный нормативный конфликт — frozen 201:54, станционный литерал без хвоста против разрешения точки 215. Полный frozen-текст 215 и полный live blob 227 проходят новую модель; это не полномочие автора менять frozen 201/224. Нужны слово владельца/изменение соответствующих обязательств ДО critic/freeze/implementer. Строка плана 231 на базе отсутствует и этой пачкой не меняется.

## Конструкция и различимость

Единственный реестр связей MUTATIONS/build.py, source.json и stabs.tsv генерируются из него. Каждый адресный запуск проверяется отдельно, синтаксическая/средовая ошибка не засчитывается как поимка. Все носители — полная дверь с реальной мутированной операцией, не двойники Git. В первоначальном самопрогоне unchecked-call оставлял вторую прежнюю сверку и имел четыре живые связи; исправлен сам мутант на отключение операции целиком. После регенерации полный --stabs дал 14/47/0. Первоначальные дефекты фикстуры (перепечатанный singleton-диагноз и лишний дефис пустого номера) исправлены до честного 78/0; поведенческий смысл не менялся.

Положительные эквивалентные записи для запретов: legacy без СУД и с равным вызовом; plain v с вызовом меньше/больше номера имени; явный vyzov с равным вызовом; station без точки; буквальный ASCII owner/repo. с прежним внешним отказом (не переадресовывается). Ранее допустимые 201/186/129/190 и проверки повторов/дат запускаются неизменённой 224 на reference, кроме раскрытого конфликта остаются зелёными.

## Двери

- Sintaksis · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --catalog · 0 · 0
- Context · fixtures/workshop_project/done_round_compat_231/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Consumer · bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Precritic · bash scripts/pre_critic.sh contracts/231-sovmestimost-doski-224.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери формы ниже; check_sdacha --run и pre_critic запускаются с пином shellcheck/TMPDIR · - · -
- К-02 · чисто · вход: seed 231 и task-architect231.md прочитаны целиком, оба дополнения реализованы в reference/клетках · - · -
- К-03 · чисто · вход: раскрыт блок frozen 224:45/46/48 и 201:54; --regression224 rc 1, НЕ зелёная совместимость и НЕ допуск freeze · - · -
- К-04 · чисто · вход: только контракт и собственная семья; context.py печатает высшие frozen и 76 пересечений · - · -
- К-05 · чисто · вход: контракт даёт rc-команды, 78 автономных клеток и --repo 45 намеренных красных · - · -
- К-06 · чисто · вход: отсутствие инструмента/непостроенный мир/синтаксис/timeout дают rc 2 NOT_IMPLEMENTED, не красную предметную поимку · - · -
- К-07 · чисто · вход: --model rc 0, все положительные формы ставят настоящий annotated done-тег · - · -
- К-08 · чисто · вход: --stabs rc 0, 14 носителей/47 отдельных связей/0 живых · - · -
- К-09 · чисто · вход: две роли, независимые носители, разноразрядные ключи и оба порядка несовпадения вызова · - · -
- К-10 · чисто · вход: rc/раздельные трубы/полная строка диагноза/annotated tag/HEAD проверяются независимо · - · -
- К-11 · чисто · вход: ожидания и HEAD до субъекта; source.json хеширует carriers, TSV сравнивается побайтно · - · -
- К-12 · чисто · вход: Git plumbing, bash -n, pinned shellcheck, Python compile; форматы не судятся самодельным парсером YAML/JSON · - · -
- К-13 · н/п · секретов, сети в оракуле и новых credentials нет · - · -
- К-14 · чисто · вход: честные legacy с/без вызова, v с независимым вызовом, vyzov равный, station и literal owner/repo. сохраняют свою полярность · - · -
- К-15 · чисто · вход: независимый AST/FS/TSV census 34×2+10=78; 14 файлов и 47 строк; --model/--stabs подтверждают · - · -
- К-16 · чисто · вход: границы названы по свойствам и ловцам; frozen-конфликт НЕ спрятан остаточным риском · - · -
- К-17 · н/п · продуктовая модель 188 не объявлена, новых операций/writer/scope_id нет · - · -

## Наблюдение процесса

Кандидат main-журнала без самовольного А-номера: задание одновременно требует независимый вызов в v-имени и неизменную зелень frozen-батареи, которая прямо запрещает такой вызов. Цена — один полный измерительный регресс; источник frozen 224 И2/И4 и клетки review-conflict/adversary-conflict; класс — конструкция/порядок согласования. Закрытие — конфликт раскрыт, старые клетки не ослаблены, допуск остановлен до слова владельца. В wip общий NABLIUDENIA_ARCHITECT.md не меняется; оркестратор переносит наблюдение в main, если ведёт запись.
