# СДАЧА 227 — отчёт Ш-5ф, не дверь

База исправления: ed4bbfb1f3f6f135866ba9cd37a6471046399168; ветка wip/227/architect-b. Production и реестры не пишутся этой пачкой. WORKTREE задания — адрес доставки; фактическое место записи — isolated pwd доклада.

Обещание: существующий CI step вызывает read-only отчёт, параметры которого приходят из JSON-конфига. Наблюдение: rc, полные stdout/stderr, весь JSON, исходные/последующие bytes файлов и Git index/HEAD. Ожидания — записи конструкторов в памяти до субъекта, не git grep/модельный результат. Frozen 083/087/114/038 и чужие шаги не меняются.

Выбран Frontier А: bash-фасад + config/zashivki.json, один JSON-объект со счётчиками/списком/исторической базой. База 89/20/6565542c1 — данные, не порог. Иные профильные ключи Ш-5 идут отдельными предметами, не production этого номера.

## Двери

Прогоны последовательны. TMPDIR=$PWD/tmp/scratch-arch227b; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Обёртка использует python3 -B, собственные миры удаляются TemporaryDirectory. Ошибка инструментов проверяющего — VERIFIER_UNAVAILABLE/rc 2, не краснота стаба. Rc 2 программы на корректном входе — красная клетка; ожидаемый операционный отказ программы проверяется как rc 2/NOT_IMPLEMENTED:/пустой stdout.

- Model · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --catalog · 0 · 0
- Critic-replay · fixtures/workshop_project/zashivki_otchet_227/replay_critic.py · 0 · 0
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

- К-05 · клетка · fixtures/workshop_project/zashivki_otchet_227/replay_critic.py · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0

Было: удаление трёх строк проверки rc git grep сохраняло --model 26/0 и выдавало ложный ноль при rc 128. Сделано: раздельные клетки git-failure, invalid-config, unreadable-config; честный empty сохранён; отдельный env отказавшего git получает только субъект, свидетели используют настоящий Git. Модель не менялась. Контракт уточняет наблюдение инварианта 4, не снимая обещания; Н-39-связи остаются только в build.py/source.json.

Способ — клетка: снять обязательство или вынести отказ измерения за границу нельзя без ослабления обещания; Git/JSON как канон сами не доказывают реакцию программы на их отказ. Поэтому добавлены только наблюдения rc, диагностического префикса stderr и пустого stdout на названных отказах. Каждый новый предикат отдельно красится s30/s31/s32; e03/e04 зелёные на отказах, e03 также на пустом остатке. Мутация критика s26 и соседняя s27 красны git-failure; s28 красен каждым отказом чтения отдельно. Совет о rc 2 закрыт s29 на binary: rc 1 батареи, не rc 2 стенда.

Точное воспроизведение: replay_critic.py создаёт одноразовый Git-клон внутри tmp/, копирует честный script/config/registry в production-шов, удаляет именно строки 19–21 исторического model-скрипта b2244d635, запускает настоящий gen_ci_steps --write и неизменённую батарею --repo. Обход --model с перестройкой source невозможен технически: теперь удаляемая операция сама является якорем нового адресного стаба; поэтому проверяется публичный --repo, не правится проверяющий код. Сырой rc субъекта в клетке 0 с ложным JSON; батарея rc 1 только по git-failure, replay rc 0. При первой попытке прежнего --model-маршрута build честно отказал ANCHOR_COUNT s26; эта попытка не засчитана как поимка.

## Сырые результаты
Исправительная пачка, фактически выполнено:

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
