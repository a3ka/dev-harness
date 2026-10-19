accept
OBJECT=1c25b7e9f0527083b5ab35258782df3d1ca4226c

# Контракт 998 (pravila-modelei), ревью реализации, круг 3 (последний). Reviewer Rev998r3

Ось проверки: закрыт ли Р998-7 (`.review/2026-10-19-15.md`: `--prompt <роль≠orchestrator>` давал rc 0 на сломанном
routing) и нет ли регресса. Сверка шла с `frozen/contracts/998/1` (c609c2ef5), инвариант 1: отказ rc 1 «в ОБЕИХ
точках входа (`--check` и `--prompt <роль>`)».
Клоны: `clone/` — чистый checkout OBJECT; `mut/` — одноразовый ssh-клон для мутаций, после каждого опыта
`git status --porcelain` пуст. Мои скрипты лежат вне дерева: `allroles.py`, `valid_parity.py`, `edges.sh`.
Находки и советы — в `review.md`.

## Предмет круга
- 8f2e43d14, author architect: только `fixtures/pravila_modelei_998/{probe.py,decoy_orch_only.ts}`, +375/−0. Это ЗОНА architect.
- db0bae5b7, author implementer: только `scripts/gen-harness.ts`, +8/−10. Это ЗОНА implementer.
  Барьер `checkRoutingStrict` перенесён из ветки `r.slug === 'orchestrator'` на место ДО неё, то есть сразу
  после поиска роли. Это та «более простая форма», которую называла находка Р998-7.
- `git merge-base --is-ancestor 1c25b7e9 origin/main` rc=0; `--is-ancestor db0bae5b7 1c25b7e9` rc=0.

## (1) `--prompt` любой роли: сломанный routing → rc≠0 без промпта, валидный → rc0. Своя мера: все 10 ролей, а не 3 роли пробы
`python3 allroles.py mut` проверяет 11 поломок × 10 ролей. Поломки: drop, routing не объект, пустой rules,
неизвестный ключ routing, неизвестный ключ правила, несуществующая роль, несуществующий тир, role+tier вместе,
class числом, until числом, conditional числом.
Результат: все 110 ячеек дают `rc=1 stdout_len=0` и первую строку stderr `FAIL routing: routing.rules[N]: …`
с нарушителем, например `routing.rules[10]: тира «no-such-tier» нет в tiers` или
`routing.rules[0]: неизвестный ключ «zzz»`. Строк `BAD` в 110 ячейках поломок нет.
У того же скрипта 10 валидных ячеек получили `BAD`. Причина в моём оракуле: я сравнивал вывод с файлом целиком,
вместе с frontmatter, а `Role.body` — это тело после frontmatter с `.trim()` (roles.ts:292). Поэтому валидный путь
перемерен отдельным скриптом:
`python3 valid_parity.py mut` → для каждой из 10 ролей `new_rc=0 old_rc=0 same_as_old=True body_ok=True`,
`TOTAL_BAD=0`, rc=0. Здесь вывод OBJECT побайтно совпадает с выводом генератора `db0bae5b7^`, а у не-оркестраторов он
равен телу роли. Значит, валидный путь (инв. 3) не сдвинут.
Края (`bash edges.sh mut`, rc=0):
- `roles/implementer-glm.md` снесён при живых таблице и routing: `--prompt implementer|architect|steward` дают rc=1,
  stdout пуст, «таблица ролей моделей называет «implementer-glm», но файла … нет».
- Вырожденный режим, конфига нет: `--prompt implementer` rc=0 (5432 байт), `orchestrator` rc=0. Прежняя
  толерантность сохранена, как требует инв. 1.
- Битый JSON: rc=1, stdout пуст, но вместо именованного отказа — сырой стек node. До правки было так же
  (`db0bae5b7^`: rc=1, тот же стек). Это вне оси, см. совет Р998-с13.

## (2) Проба 998: зелёная на OBJECT, красная на сломанном
- `bash fixtures/pravila_modelei_998/probe.sh --cases` → `census cases: исполнено 52, расхождений 0`, rc=0.
- `bash fixtures/pravila_modelei_998/probe.sh --matrix` → `census matrix: исполнено 68, расхождений 0`, rc=0.
- Счёт своей мерой, другим способом: python-счётчик строк `CASE` по полному `probe.sh` дал
  `{'cases': 52, 'matrix': 68} nonok {}`, rc пробы 0.
- Красное на генераторе до правки: в `mut` положил `git show db0bae5b7^:scripts/gen-harness.ts` и запустил
  `probe.sh --cases`. Результат `исполнено 52, расхождений 1`, `КРАСНО: gen_prompt_roles_fail_closed`, rc=1:
  «routing отсутствует/--prompt implementer: rc=0 (ожидается 1 …)».
- Ловля обманки orch_only: в матрице `decoy_orch_only_prompt_roles: ok` (обманка поймана на назначенном входе) и
  `decoy_orch_only_seed_parity: ok`. Проверил, что клетка способна покраснеть: в `mut` подставил честную модель на
  место обманки (`cp model_gen.ts decoy_orch_only.ts`) → `decoy_orch_only_prompt_roles: РАСХОЖДЕНИЕ`,
  `матрица 68/1`, rc=1. Клетка не плацебо.
- Регресс Р998-3: `gen_modes_isolated_from_routing: ok` и `gen_modes_isolated_all_breaks: ok`.
  `--resolve-overlay`/`--agents-rules`/`--into` по-прежнему rc 0 на сломанном routing.

## (3) `gen:harness --check`
- `node scripts/gen-harness.ts --check` → «харнес соответствует roles/ (10 ролей)», rc=0.
- `npm run --silent check:gen` → то же, rc=0.
- Остальные строки приёмки, скоупом (Н-48): `bash scripts/run_ci_lane.sh check:pravila-modelei-998` rc=0 (матрица 68/0);
  `bash scripts/gen_ci_steps.sh --check` rc=0; `bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` rc=0;
  `npm run --silent check:antiplacebo -- --scope check_provodka` rc=0, «барьеров: 1 · фикстур: 28 · предъявлено
  красным повторным прогоном: 28».

## (4) Проверки не ослаблены: diff от frozen-тега
- `git diff frozen/contracts/998/1 1c25b7e9 -- contracts/998-pravila-modelei.md` → 0 байт: контракт не тронут.
- `git diff --numstat frozen/contracts/998/1 1c25b7e9 -- fixtures/pravila_modelei_998` даёт только добавления:
  probe.py 486/0, model_gen.ts 31/0, decoy_orch_only.ts 193/0, decoy_form_blind.ts 190/0,
  decoy_module_barrier.ts 197/0. Из probe.py ни одна строка не удалена: фильтр строк `-` дал пустой вывод.
- После заморозки `fixtures/pravila_modelei_998` и контракт правил только architect (27e2ff55, 8f2e43d1).
  Implementer проверок не касался: db0bae5b7 трогает только `scripts/gen-harness.ts`.
- Подсчёт cases 52 вместо 46 и matrix 68 вместо 57 в прозе frozen-контракта — это усиление батареи architect-ом в
  его зоне (Н-39: привязки — код probe.py). Ослаблением это не является.

## Остальные пункты гейта
- Область правки: db0bae5b7 трогает 1 файл в ЗОНЕ implementer, 8f2e43d1 — 2 файла в ЗОНЕ architect. Превышения нет.
- Атомарность: одна задача — один коммит, оба сообщения ссылаются на Р998-7.
- Норма не тронута: контракт и roles/* в коммитах круга не правились.
- ПРОВОДКА (038): guard `fixtures/pravila_modelei_998/probe.sh` является барьером именно этого предмета, lane
  исполняет его целиком. `check_provodka` rc=0.

## Паразитная сложность (050): пять вопросов по каждому новому или раздутому артефакту
- **scripts/gen-harness.ts, барьер в `--prompt`** (+8/−10).
  (1) Свойство — инв. 1, отказ `--prompt <роль>` для любой роли.
  (2) Новое состояние не вводится; отказ виден в rc и stderr.
  (3) Число файлов, меняющихся вместе, не выросло: был 1 вызов в ветке orchestrator, остался 1 в `--prompt`.
  (4) Интерфейс (аргументы, флаги, env) не изменился. Модуль не стал мельче.
  (5) Потребитель — клетка `gen_prompt_roles_fail_closed` и lane `check:pravila-modelei-998`.
  Вердикт: **ESSENTIAL**. Остаётся прежний совет Р998-с11: блок «gate → печать → exit 1» по-прежнему существует
  в двух копиях (`:163-164`, `:409-412`). Правка числа копий не увеличила.
- **fixtures/pravila_modelei_998/probe.py, +2 клетки cases, +3 клетки matrix** (одна семья).
  (1) Свойство — инв. 1 «обе точки входа», для `--prompt` любой роли.
  (2) Состояние — временные деревья, исход печатается в CASE-строках.
  (3) Вместе меняется 1 файл.
  (4) Интерфейс не изменился (`--cases`/`--matrix`).
  (5) Потребитель — lane. Клетки переиспользуют существующие хелперы.
  Вердикт: **ESSENTIAL**. Без этих клеток Р998-7 проходил зелёным.
- **fixtures/pravila_modelei_998/decoy_orch_only.ts** (193 строки, копия модели с одной слабостью).
  (1) Свойство — различимость обманки «барьер только для orchestrator».
  (2) Состояния нет.
  (3) Число файлов, меняющихся вместе, такое же, как у прочих обманок семьи. При правке модели вместе с ней
  меняются и копии обманок: это уже существующий паттерн семьи (form_blind, module_barrier), диффом он не
  увеличен в классе.
  (4) Интерфейс — тот же CLI модели.
  (5) Потребитель — клетки матрицы `decoy_orch_only_*`.
  Вердикт: **ESSENTIAL**. Без обманки форма «барьер только в orchestrator» не отличалась бы от честной модели.

## Вывод
Р998-7 закрыт. На всех 10 ролях × 11 поломках `--prompt` отказывает rc 1 с пустым stdout и с именем routing,
индекса и нарушителя. На валидном routing вывод побайтно прежний. Проба на OBJECT 52/0 и 68/0. Генератор до правки
она ловит (52/1), обманку orch_only — тоже, и клетка краснеет, если обманку подменить честной моделью.
`--check` rc 0. Frozen-контракт и прежние клетки не ослаблены. Блокирующих находок нет. Советы перечислены в `review.md`.
