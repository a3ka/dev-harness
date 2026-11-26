# СДАЧА 227 — отчёт Ш-5ф, не дверь

База исправления Б-1 Rev227: ce363c746bc1c5f95eac16db1e53978e474942e3; ветка wip/227/architect-c. Правится только семья батареи; frozen-контракт, production и реестры не меняются. WORKTREE задания — адрес доставки; фактическое место записи — isolated pwd доклада.

Обещание: существующий CI step вызывает read-only отчёт, параметры которого приходят из JSON-конфига. Наблюдение: rc, полные stdout/stderr, весь JSON, исходные/последующие bytes файлов и Git index/HEAD. Ожидания — записи конструкторов в памяти до субъекта, не git grep/модельный результат. Frozen 083/087/114/038 и чужие шаги не меняются.

Выбран Frontier А: bash-фасад + config/zashivki.json, один JSON-объект со счётчиками/списком/исторической базой. База 89/20/6565542c1 — данные, не порог. Иные профильные ключи Ш-5 идут отдельными предметами, не production этого номера.

## Двери

Прогоны последовательны, после коммита — в чистом origin-клоне на SHA кандидата. TMPDIR=$PWD/tmp/scratch-arch227c; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Строки ниже задают ожидаемые rc; фактические rc чистого прогона идут в доклад, лист после прогона не меняется. Обёртка использует python3 -B, собственные миры удаляются TemporaryDirectory. Ошибка инструментов проверяющего — VERIFIER_UNAVAILABLE/rc 2, не краснота стаба. Rc 2 программы на корректном входе — красная клетка; ожидаемый операционный отказ программы проверяется как rc 2/NOT_IMPLEMENTED:/пустой stdout.

- Repo · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --repo . · 0 · 0
- Model · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --catalog · 0 · 0
- Critic-replay · fixtures/workshop_project/zashivki_otchet_227/replay_critic.py · 0 · 0
- Reviewer-R9 · fixtures/workshop_project/zashivki_otchet_227/replay_reviewer.py · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/227-sh5f-zashivki-otchet.md · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/227-sh5f-zashivki-otchet.md · 0 · 0
- Threat · bash scripts/check_threat_model.sh . contracts/227-sh5f-zashivki-otchet.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/227-sh5f-zashivki-otchet.md · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/227-sh5f-zashivki-otchet.md · 0 · 0
- CI-generator · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: перечисленные двери формы и лист; pre_critic/check_sdacha запускаются отдельно, чтобы их же вложенные строки не создавали рекурсию · - · -
- К-02 · чисто · вход: R-0114/R-0102, полные §Ш-5/Ш-5ф Fable, PLAN-V9 §1/§4, ADR 21.11; реализуется только отчёт, следующие ключи перечислены вне предмета · - · -
- К-03 · чисто · вход: context.py читает высшие frozen-блобы и реальные зоны, 083/087/114/038 сохраняют генератор/runner/замеры/проводку; 193/203/226 production не раздаётся · - · -
- К-04 · чисто · вход: architect — контракт/новая семья; implementer — ровно script/config; orchestrator — только своя тройка CI; generated carriers/source.json в зоне семьи · - · -
- К-05 · чисто · вход: каждая строка приёмки имеет rc-команду; исторический repo-red не является постоянной дверью листа · - · -
- К-06 · чисто · вход: preflight git/bash/python3/jq, таймауты; hash/bash -n/compile до стаба; VERIFIER_UNAVAILABLE отдельно от любого rc субъекта; бинарный конформный вход с rc 2 субъекта теперь красен, не «нет стенда» · - · -
- К-07 · чисто · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0
- К-09 · чисто · вход: пусто/неноль/90 строк/21 файл, изменённые pattern/include/exclude/baseline, пустой exclude, literal-метасимволы, Unicode/TAB/LF/двоеточия, tracked/dirty/untracked/binary, комментарии · - · -
- К-10 · чисто · вход: полное структурное JSON-сравнение и отдельно rc/обе трубы; snapshot файлов/index/HEAD, действительный CI registry и gen_ci_steps --check · - · -
- К-11 · чисто · вход: literal records и исходные снимки в памяти проверяющего до субъекта, не в файле проверяемого Git-мира; subject не источник ожидаемого вывода · - · -
- К-12 · чисто · вход: стандартный json, JSON Schema, bash -n, compile, validate_std/shellcheck, настоящий git и настоящий gen_ci_steps; своего YAML-парсера нет · - · -
- К-13 · н/п · новых секретов/сети/secret-вывода нет; отчёт публикует только tracked строки заданной области · - · -
- К-14 · чисто · вход: зелёные эквиваленты числа файлов, JSON escaping/layout, условия rc grep и чтения JSON; новые запрещающие предикаты имеют честные зелёные записи · - · -
- К-15 · чисто · вход: build/catalog и независимые фактические model/stabs; цифры сырых прогонов ниже; исходные grep -n/-l независимо дали 89/20 · - · -
- К-16 · чисто · вход: обычный риск read-only отчёта, остаток не отказывает; configured scope не выдаётся за распознавание любых семантических зашивок · - · -
- К-17 · н/п · продуктовой модели 188 нет, новых writers/scope_id нет · - · -

## Дельта

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-227-v1.md

Новый блок Б-1: 2392d2a1f3:verdicts/review/contracts-227-impl-v1.md (внешний закоммиченный вход задания, не файл HEAD этой базы). Машинная ссылка выше сохраняет сверку прежнего critic FAIL и его закрытия; чужой reviewer-артефакт в зону architect не копируется.

- К-05 · клетка · fixtures/workshop_project/zashivki_otchet_227/replay_critic.py · 0 · 0

- К-08 · клетка · fixtures/workshop_project/zashivki_otchet_227/replay_reviewer.py · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0

Б-1 Rev227: literal include/exclude должны отличаться от glob. Снятие обещания или граница ослабили бы инвариант 2; настоящий Git — канон семантики pathspec, но сам по себе не наблюдает выбор pathspec субъектом. Способ — клетка: новые конформные Git-миры сравнивают полный JSON с независимыми литеральными records в памяти ДО запуска. Старые клетки и предикаты probe сохранены; добавлены только входы. Контракт и модель не меняются.

Различающие соседи есть отдельно для include и exclude: звёздочка, вопрос, квадратная скобка и обратный слэш перед вопросом. Обратный слэш в literal — байт имени, а в glob экранирует вопрос; сосед содержит вопрос без слэша. Ни один объединённый мир не подменяет отдельную проверку другого входа. Реестр связей находится только в build.py: совместное снятие literal, независимое снятие include и независимое снятие exclude; честная эквивалентная запись добавляет top при сохранении literal и остаётся зелёной на тех же входах.

replay_reviewer.py клонирует закоммиченное дерево внутри tmp/, меняет только production-копию точными заменами R9 из вердикта, проверяет bash -n и запускает --repo. Ожидание: rc батареи 1, полный набор новых клеток красен именно REPORT_CONTENT, остальные зелены; rc самого воспроизведения 0. Новые предикаты воспроизведения не меняют проверку продукта: они лишь требуют адресность полного наблюдённого набора, а недоступность стенда не засчитывают.

Каталог по генератору: стабы 32→35, эквиваленты 4→5, связи 40→64. Число клеток и краснота R9 берутся из чистого прогона в докладе; исходные literal-paths/literal-excludes не заменяются.

## Сырые результаты
Историческая исправительная пачка Architect227b, фактически выполнено тогда (не новые замеры):

```text
--repo .: rc 1, SUBJECT_ABSENT: scripts/report_zashivki.sh
build: rc 0, STABY 32 EKVIVALENTY 4 SVJAZI 40
--model: rc 0, KLETKI 29 KRASNYH 0
--stabs: rc 0, STABY 32 EKVIVALENTY 4 ZHIVYH 0
--sintaksis: rc 0, SINTAKSIS_OK
--catalog: rc 0, KLETKI 29 STABY 32 EKVIVALENTY 4 SVJAZI 40
context.py: rc 0, ДЕКЛАРАЦИИ 65
replay_critic.py: rc 0
CRITIC_EXACT_DELETE_19_21 --repo rc 1
git-failure RED MEASUREMENT_ERROR_RC rc=0,MEASUREMENT_ERROR_DIAGNOSIS,MEASUREMENT_ERROR_REPORT b'{"lines": 0, "files": 0, "matches": [], "baseline": {"lines": 89, "files": 20, "commit": "6565542c1"}}\n'
KLETKI 29 KRASNYH 1
check_sdacha --run: rc 0, СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2), 82.98 с
pre_critic: rc 0, КРИТИК: дверь зелёная, 145.30 с
check_precision_gate: rc 0, OK, 48.97 с
Первый check_sdacha: rc 1 (алфавит команды не допускает python3 -B); исправлено прямым исполняемым replay_critic.py с shebang python3 -B, затем полный прогон зелёный.
```

Каталог до→после: клетки 26→29, стабы 25→32, эквиваленты 2→4, связи 28→40. Исходные клетки не удалены; успешная ветвь сравнения JSON/обеих труб/снимков сохранена, удалена только маскировка rc 2 программы под недоступность стенда.

Первичная пачка (исторические результаты Architect227, не новые замеры):


```text
--repo .: rc 1, SUBJECT_ABSENT: scripts/report_zashivki.sh
build: rc 0, STABY 25 EKVIVALENTY 2 SVJAZI 28
--model: rc 0, KLETKI 26 KRASNYH 0
--stabs: rc 0, STABY 25 EKVIVALENTY 2 ZHIVYH 0
--sintaksis: rc 0, SINTAKSIS_OK
context.py: rc 0, ДЕКЛАРАЦИИ 65
исходный git grep -n ... | wc -l: rc 0, 89
исходный git grep -l ... | wc -l: rc 0, 20
pre_critic: rc 0, КРИТИК: дверь зелёная (40.07 с)
check_sdacha --run: rc 0, двери=11 карта=17/17 дельта=0 (29.42 с)
--catalog: rc 0 в обоих исполнениях листа, KLETKI 26 STABY 25 EKVIVALENTY 2 SVJAZI 28
```

До production полный check_provodka не объявляется зелёным: CI guard ещё не подключён. Его грамматика и существующий gen_ci_steps проверяются в листе. После implementer/orchestrator главный агент проверяет --repo . и полный check_provodka; нынешний исторический red не записан исполняемой дверью с ожидаемым rc 1.

## Наблюдение процесса

Кандидат для main-журнала, без самовольного А-номера и без изменения общего журнала в wip: маленький synthetic CI-мир должен удовлетворять настоящему gen_ci_steps, а не воображаемой грамматике. Начальный lanes=1 получил реальный отказ «вне 6..8»; после lanes=6 мир без shard выявил дрейф пустого SHARDS при --write→--check. Цена — два локальных коротких прогона, до суда. Класс — конструкция фикстуры/достижимость честного контроля. Закрыто конформной формой lanes=6 и непустой shard-строкой существующей грамматики; действующий генератор не правился и его пустой edge-case не расширен в предмет 227. Ловец остатка — отдельная адресная проба генератора/оркестратор, не молчаливое исправление чужой production.

Исправительный круг Architect227b: нового дефекта процесса вне уже измеренного К-08 не обнаружено. Прежняя ошибка rc субъекта/проверяющего закрыта раздельной классификацией; воспроизведение exact-delete идёт через production --repo, потому что попытка перестроить производные стабы от уже удалённого якоря закономерно даёт ANCHOR_COUNT, а не результат предмета. Общий main-журнал в wip не менялся.

Исправительный круг Architect227c: измеренный процессный дефект конструкции — пример с метасимволом недостаточен без соседа, на котором семантики расходятся. Цена — блок Б-1 reviewer и исправительный круг. Источник — Rev227 R9; класс — различимость барьера. Закрывается отдельными входами и адресными операциями include/exclude, а не новым обещанием контракта. Нового А-номера в wip нет; общий журнал остаётся только в main.
