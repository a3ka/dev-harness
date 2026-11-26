# СДАЧА 227 — отчёт Ш-5ф, не дверь

База: 3be623a80eae14c63d960c7aaeff9c6bcd301fdd; ветка wip/227/architect. Production и реестры не пишутся этой пачкой. WORKTREE задания — адрес доставки; фактическое место записи — isolated pwd доклада.

Обещание: существующий CI step вызывает read-only отчёт, параметры которого приходят из JSON-конфига. Наблюдение: rc, полные stdout/stderr, весь JSON, исходные/последующие bytes файлов и Git index/HEAD. Ожидания — записи конструкторов в памяти до субъекта, не git grep/модельный результат. Frozen 083/087/114/038 и чужие шаги не меняются.

Выбран Frontier А: bash-фасад + config/zashivki.json, один JSON-объект со счётчиками/списком/исторической базой. База 89/20/6565542c1 — данные, не порог. Иные профильные ключи Ш-5 идут отдельными предметами, не production этого номера.

## Двери

Прогоны последовательны. TMPDIR=$PWD/tmp/scratch-arch227; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Обёртка использует python3 -B, собственные миры удаляются TemporaryDirectory. Отсутствие/поломка инструмента или синтаксиса не считается краснотой стаба.

- Model · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --catalog · 0 · 0
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
- К-06 · чисто · вход: preflight git/bash/python3/jq, таймауты; hash/bash -n/compile до стаба, rc 2 не засчитывается поимкой · - · -
- К-07 · чисто · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs · 0 · 0
- К-09 · чисто · вход: пусто/неноль/90 строк/21 файл, изменённые pattern/include/exclude/baseline, пустой exclude, literal-метасимволы, Unicode/TAB/LF/двоеточия, tracked/dirty/untracked/binary, комментарии · - · -
- К-10 · чисто · вход: полное структурное JSON-сравнение и отдельно rc/обе трубы; snapshot файлов/index/HEAD, действительный CI registry и gen_ci_steps --check · - · -
- К-11 · чисто · вход: literal records и исходные снимки в памяти проверяющего до субъекта, не в файле проверяемого Git-мира; subject не источник ожидаемого вывода · - · -
- К-12 · чисто · вход: стандартный json, JSON Schema, bash -n, compile, validate_std/shellcheck, настоящий git и настоящий gen_ci_steps; своего YAML-парсера нет · - · -
- К-13 · н/п · новых секретов/сети/secret-вывода нет; отчёт публикует только tracked строки заданной области · - · -
- К-14 · чисто · вход: две зелёные эквивалентные операции модели — set-компрехеншн и JSON escaping/layout; синонимичный формат stdout не краснит проверку · - · -
- К-15 · чисто · вход: build/catalog и независимые фактические model/stabs; цифры сырых прогонов ниже; исходные grep -n/-l независимо дали 89/20 · - · -
- К-16 · чисто · вход: обычный риск read-only отчёта, остаток не отказывает; configured scope не выдаётся за распознавание любых семантических зашивок · - · -
- К-17 · н/п · продуктовой модели 188 нет, новых writers/scope_id нет · - · -

## Дельта

Первичная сдача, предыдущего суда 227 нет. Н-39-связи заданы только кодом build.py и генерируемым source.json, не списком пар в контракте.

## Сырые результаты

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
