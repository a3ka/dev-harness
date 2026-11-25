# СДАЧА 217 — пустое incr-окно

Исправление только двух К-08 блоков Adv217b из
archive/217/adversary-v1-fail-2b624c289a:
verdicts/adversary/contracts-217-impl-v1.md.
Контракт frozen/contracts/217/2, production, реестры и соседи не меняются.
Исторический оракул: source.json/baseline; это предок базы задания.
КЛЕТКИ=41, МУТАЦИИ=23, СВЯЗИ=29: прежние 36/20/25 плюс 5/3/4.
Два независимых production-мутанта не входят в счёт адресных стабов.
Ожидаемые rc дверей ниже не являются заявлением о состоявшемся прогоне;
наблюдавшиеся результаты и ограничения перечислены в «Измерениях».

## Двери

- честная-модель · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --stabs · 0 · 0
- реальная-история · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model --live · 0 · 0
- синтаксис · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --syntax · 0 · 0
- реестр-ветвей · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --catalog · 0 · 0
- реализация-Б1-Б2 · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . · 0 · 0
- production-мутации-Б1-Б2 · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . --production-stabs · 0 · 0
- независимые-мутации · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . --independent-mutants · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/217-incr-pustoe-okno.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- идентификаторы · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- проводка · bash scripts/check_provodka.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- источники-done · bash scripts/check_project_sources.sh --repo . --contract contracts/217-incr-pustoe-okno.md --stage done · 0 · 0
- генератор-CI · bash scripts/gen_ci_steps.sh --check · 0 · 0
- совместимость-210-v2 · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo . · 0 · 0
- совместимость-113-v2 · bash fixtures/charter_fast_113/red_113.sh · 0 · 0
- совместимость-083-база · bash fixtures/_krasnye_083.sh · 1 · 1

## Карта классов

- К-01 · чисто · вход: сохранены прежние двери, добавлен исполняемый независимый контроль; полные pre_critic/check_sdacha требуют разрешённой среды для дочерней 083 · - · -
- К-02 · чисто · вход: task-architect217c.md, два блока Adv217b; frozen v2 и неизменный двухсекундный предел не расширяются · - · -
- К-03 · чисто · вход: кольцо, разрешения, fallback и соседи 210/113/083 сохраняются; их проверки не подменяются новыми клетками · - · -
- К-04 · чисто · вход: зона правок только fixtures/workshop_project/incr_pustoe_okno_217/, никаких production/контракта/реестров · - · -
- К-05 · чисто · вход: rc-команды сохранены; rc 2 субъекта без ustav/1 означает зелёную клетку только при точных потоках и неизменном кеше · - · -
- К-06 · чисто · вход: Git/пин/якорь/трасса/валидатор отсутствуют — NOT_IMPLEMENTED; поиск соли не запускается в CI, runtime восстанавливает ограниченную историю · - · -
- К-07 · чисто · вход: настоящие Git fast-import/hash-object/rev-parse/merge-base и Bash CLI, без PATH-двойника и фиктивных SHA в кеше · - · -
- К-08 · чисто · вход: --stabs и --production-stabs требуют честный контроль перед каждым отдельным предъявлением; обе дыры имеют свои исполняемые привязки в MUTATIONS/stabs.tsv · - · -
- К-09 · чисто · вход: запрещённая prefix10-правка противопоставлена разрешённой; отсутствие ustav/1 — прежним e1/e4/e6; отсутствующий тег с битым кешем сохраняет приоритет rc 1 · - · -
- К-10 · чисто · вход: полные rc/stdout/stderr/cache_bytes, оракул в памяти до субъекта; no-LF мир показывает незаконный вызов finish на отказе · - · -
- К-11 · чисто · вход: pinned compatibility oracle загружен до субъекта, полные SHA мира вычисляются и проверяются Git, не извлекаются из вывода субъекта · - · -
- К-12 · чисто · вход: Trace2 JSON разбирается stdlib, факты Git — plumbing; Bash — bash -n и pinned shellcheck; новых парсеров устава нет · - · -
- К-13 · н/п · секретов нет, только публичный синтетический текст и Git-объекты · - · -
- К-14 · чисто · вход: все прежние контроли сохранены; w17 разрешает реальную коллизию, e1/e4/e6 сохраняют честный пустой успех после введения устава · - · -
- К-15 · чисто · вход: --catalog вычисляет клетки/мутации/TSV-связи и сверяет с source.json; независимый AST/TSV пересчёт приведён в докладе · - · -
- К-16 · чисто · вход: cache=HEAD остаётся доверенной границей, непустая prefix10-история не амнистируется, отсутствие ustav/1 не превращается в успех · - · -
- К-17 · н/п · проектной архитектурной модели нет, публичный CLI production не меняется · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . --production-stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . --independent-mutants · 0 · 0

Б-1 закрыт клеткой w16-prefix10-denied: настоящий строгий предок и HEAD
совпадают первыми десятью, следовательно и восемью, hex-символами.
Снятие/граница ослабили бы И3; Git уже является каноном, ему недоставало
различающего входа. Проверка полных потоков и кеша прежняя.
Новый сосед w17-prefix10-allowed оставляет законную правку зелёной.

prefix10.py восстанавливает ровно 32768 чистых предков и одного потомка,
меняющего AGENTS.md. source.json хранит seed 217 и готовые соли
45945976 / 2385099, не сотни МБ объектов. --search воспроизводит офлайн-подбор,
CI его не вызывает. На каждой клетке Git подтверждает hash-object, полные
rev-parse base/HEAD, совпадение префикса, различие коммитов и предковость.
Окна запрещённого/разрешённого мира: 6498 / 18941 коммит соответственно.

Б-2 закрыт e10-no-ustav и e11-no-ustav-oracle-no-lf: валидное пустое окно
до введения устава требует rc 2, точный NOT_IMPLEMENTED и прежние байты кеша.
Модель несла ту же дыру: вставка перенесена после существующей проверки тега,
перед разведкой. Production не изменяется. c9-no-ustav-broken требует прежний
rc 1 по повреждению кеша до проверки отсутствующего тега.

M21_PREFIX8 воспроизводит восьмизначное сравнение Adv217b;
M22_BEFORE_USTAV переносит тот же EMPTY_BRANCH перед прежним TAG_GUARD;
M23_NO_USTAV нейтрализует только TAG_GUARD. Каждая замена требует ровно один
якорь. В обеих первых мутациях воспроизведён механизм из вердикта, без правки
остальной production. Независимые варианты используют другие якоря:
полную строку if для сравнения десяти hex и local base в lib_incr для выхода
до валидации кеша. Они исполняются на production, не на модели.

## Измерения

Прогоны последовательные, VALIDATE_STD_SHELLCHECK — закреплённый путь станции.
TMPDIR внутри разрешённой изолированной рабочей копии, а не /tmp задания.

| Команда W | rc | Сырой итог | Время, с |
|---|---:|---|---:|
| --repo . | 0 | KLETKI=41 ZELENYE=41 KRASNYE=0 | 19.01 |
| --model | 0 | KLETKI=41 ZELENYE=41 KRASNYE=0 | 29.32 |
| --stabs | 0 | MUTACII=23 SVJAZI=29 POIMANY=29 ZHIVYH=0 | 39.41 |
| --repo . --production-stabs | 0 | MUTACII=8 SVJAZI=10 POIMANY=10 ZHIVYH=0 | 27.88 |
| --repo . --independent-mutants | 0 | prefix10 и before-cache: POIMAN | 17.42 |

Сумма --repo/--model/--stabs = 87.74 с (<100 с). Порог не менялся.
Восстановление коллизии наблюдалось за 2.319–11.051 с, честный CLI за
1.372–1.883 с; это замеры этой станции, не гарантия произвольной нагрузки.
Поиск солей отдельно занял 58.761 / 6.709 с и не входит в цену клетки CI.

На production M21: честный rc 1, мутант rc 0, RED по BYTES и CACHE.
M22: честный rc 2, мутант rc 0; e11 дополнительно RED по нормализации кеша.
M23: честный rc 2, мутант rc 0. Независимые prefix10/before-cache:
честный rc 1, мутант rc 0, оба RED по BYTES и CACHE.

Остальные наблюдавшиеся rc:
W --syntax: 0, SYNTAX bash=2 python=2 rc=0.
W --catalog: 0, KLETKI=41 MUTACII=23 SVJAZI=29.
W --model --live: 0, LIVE commits=9174 seconds=0.034 rc=0.
210 --repo . / --model: 0 / 0, обе KLETKI=342 ZELENYE=342 KRASNYE=0
(229.83 / 270.88 с); 210 --stabs: 0,
MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0 (115.76 с).
113: 0, клеток 28, красных 0 (64.09 с); именованный В2 остаётся
штатно вне этого вызова без RED_113_FULL=1.
SDACHA_OKRUG=1 pre_critic: 0, 17.29 с — только доступные ноги,
не полный вызов с листом. Отдельно spec_ready, ids, ceilings, precision,
threat_model, predposylki, provodka, project_sources --stage done,
gen_ci_steps --check: каждый rc 0, последовательно.

Независимый счёт AST списка Cell / AST словаря MUTATIONS / TSV:
cells=41 mutations=23 bindings=29, уникальных TSV-мутаций 23, rc 0.
Единственный SHA-литерал семьи — source.json/baseline;
git merge-base --is-ancestor для него: rc 0. Синтетические SHA в исходниках
не хранятся, объектного архива семьи нет.
Новый SOURCE_CENSUS: подмена cells=42 в памяти через runpy.run_path и
вызов main с --catalog даёт rc 2, NOT_IMPLEMENTED: SOURCE_CENSUS;
эквивалентный словарь bindings=29,mutations=23,cells=41 в другом порядке
остаётся rc 0. Файлы при этих предъявлениях не записывались.

Полные pre_critic/check_sdacha и строка 083 не запускались: дочерний
check_zones.sh делает env -i, снимает TMPDIR и создаёт скратч lib_zones
в /tmp вне разрешённой изолированной копии. Это блокер среды, не зелёный
результат и не снятие двери: orchestrator прогоняет их в разрешённом клоне.
Таймаут 083 и ожидаемый rc 1 сохранены; повтор до случайного зелёного не делался.

## Остатки и рефлексия

Границы frozen v2 не меняются: подделка доверенного кеша, обходы вне Trace2,
сговор при общем uid, произвольная нагрузка и нелинейная публикация вне миров
217 ловятся ранее названными reviewer/adversary/210/113/083, не этой пачкой.

Процессный дефект: заданный внешний scratch и полный сдаточный маршрут
несовместимы со старшей изоляцией субагента; это сообщено Main до запуска
небезопасной 083. А-NN в общем журнале из wip не добавлялась: журнал только
на main и вне зоны этой пачки. Новых обязательств/ослаблений не вводилось.
