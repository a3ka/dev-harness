# СДАЧА 206 — среда изолированного судьи

Исправительный круг по Crit206V1, OBJECT FAIL
155cb90732e11f83569b6f2b202d0f466a09aae6. Вердикт прочитан целиком из
archive/206/critic-v1-fail-1167f53a2b:verdicts/critic/contracts-206-v1.md;
в HEAD этой базы его нет, чужая зона verdicts не материализуется автором.
Production, роли и CI не меняются. Эталон production остаётся дельтой над
immutable BASE db56f44d1012854b6098a7076fccdae0855badeb; live.py — проверяемый
наблюдатель этой пачки, копируемый в модель для адресных мутаций.

## Двери

- модель · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- каталог-канон · fixtures/workshop_project/sreda_sudji_206/catalog.py --check · 0 · 0
- наблюдатель-контроли · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/206-sreda-sudji.md · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/206-sreda-sudji.md · 0 · 0
- ids · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/206-sreda-sudji.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/206-sreda-sudji.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/206-sreda-sudji.md · 0 · 0
- pre-critic · bash scripts/pre_critic.sh contracts/206-sreda-sudji.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери листа и раздел Дельта; pre_critic обязателен до сдачи · - · -
- К-02 · чисто · вход: task-arch206 и task-arch206b; четыре блока Crit206V1 закрываются без изменения общего предмета · - · -
- К-03 · чисто · вход: права М1 037 и назначенного пина 032/066 сохранены; нормализация verdict не меняет OBJECT/runtime, режимы 172 и детектор 185 · - · -
- К-04 · чисто · вход: меняются только контракт 206 и семья среды судьи; production остаётся implementer, CI orchestrator · - · -
- К-05 · чисто · вход: приёмка — rc-команды, live принимает назначенный --object · - · -
- К-06 · чисто · вход: observer-null/number/string/array/broken-json/bom ожидают полный rc2/stderr; empty/count-1/count-2 ожидают предметный rc1/stdout · - · -
- К-07 · чисто · вход: эталон вызывает реальные Node/git/pre_judge; разделение опций/операндов и realpath исправлено в обязательной модели · - · -
- К-08 · чисто · вход: verdict-relative-outside/parent-outside/symlink-outside/file-symlink-outside противопоставлены relative-inside/normalized-inside/symlink-inside · - · -
- К-09 · чисто · вход: cp/mkdir и /bin-формы после --, dash-операнды внутри/снаружи, флаги до -- и несколько операндов; старые кавычки/LF/NUL сохранены · - · -
- К-10 · чисто · вход: observer-honest/different-objects/unassigned-object/missing-object; мутации сравниваются по полному rc/stdout/stderr, не подстроке · - · -
- К-11 · чисто · вход: ожидания в памяти до запуска субъекта; live читает один снимок журнала, не получает ожидания от проекта · - · -
- К-12 · чисто · вход: GNU realpath для нормализации, штатная токенизация guard, json.loads для JSON, единый controls для observer-клеток и catalog.py для stabs.tsv · - · -
- К-13 · н/п · секреты в предмет не входят · - · -
- К-14 · чисто · вход: dash-inside, flag-before-separator, внутренние relative/normalized/symlink пути и observer-honest; empty отличён от невалидного JSON · - · -
- К-15 · чисто · вход: счётчики раннеров, побайтовая сверка stabs.tsv с MUTATIONS; измерение исходной боли не повторялось · - · -
- К-16 · чисто · вход: риск безопасности путей, сохранённая граница shell и обязательная живая тройка после рестарта · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Дельта

- К-09 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- К-08 · канон/инструмент · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- К-10 · клетка · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- К-06 · клетка · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- К-07 · канон/инструмент · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0

## Закрытие четырёх блоков и предикаты

| Блок | Способ и причина | Мутация и соседняя | Честная эквивалентная запись |
|---|---|---|---|
| К-09, операнды после -- | клетка: канон shell уже задаёт смысл --, но эффект существующего guard требуется наблюдать реальным Node; снятие/граница ослабили бы обязательство, готового валидатора семантики записи guard нет | options-after-separator, mkdir-options-after-separator, options-before-separator, mkdir-only-first-operand | cp/mkdir dash-inside, абсолютные бинарники; mkdir -p -- с абсолютной внутренней целью при внешнем cwd; cp -x --; несколько источников/целей |
| К-08, относительный verdict вне repo | канон/инструмент: GNU realpath -m, затем существующий path_inside; одинаковая граница для абсолютного/относительного входа | relative-boundary-ignored, relative-normalization-ignored, relative-symlink-ignored | relative-inside, missing/../relative-inside, symlink к внутреннему вердикту; все от repo, а не cwd вызывающего |
| К-10, назначенный OBJECT | клетка: снятие/граница отменили бы живую приёмку конкретного кандидата; JSON-парсер не доказывает равенство полей назначению, инструмент замка уже пишет object | observer-object-ignored, observer-object-not-assigned; входы с разными, общим чужим и отсутствующим object | observer-honest: три роли, один общий назначенный 40-hex OBJECT |
| К-06, невалидный журнал | клетка: снятие/граница нарушили бы обещанный rc2; json.loads разбирает JSON, но не отличает объект события от scalar/array; тип проверяется перед .get, ошибки канонически отображаются в rc2 | observer-invalid-is-incomplete, observer-invalid-array-is-incomplete, observer-bom-accepted | honest rc0; пустой файл и неполная честная тройка rc1; null/1/строка/массив/битый JSON/BOM rc2 |

Три собственные мутации критика сохранены адресно без подмены предмета:
hint-refuse, boundary-no-inside, observer-no-sequence. Их привязки, как и все
остальные, принадлежат MUTATIONS в probe.py; stabs.tsv — побайтовый каталог.
Проверка observer выполняется живым CLI, включая rc и оба полных потока;
неправильный rc2 не считается пойманной охранной мутацией. Специальные клетки
невалидного журнала, напротив, требуют именно rc2 и канонический stderr.

## Доказательства и границы

Машинные ряды выше задают ожидаемые rc и исполняются check_sdacha --run.
Repo до реализации ожидаемо красен, поэтому не включён зелёной дверью.
Observer-клетки зелены уже в авторской пачке: они судят наблюдателя, а не
production. Настоящие три суда — LIVE_JUDGES_NOT_RUN до реализации, поставки
и рестарта ТЕГ 4. Legacy-пробы с внешним scratch не исполняются из этой
изоляции; их обязательные команды сохранены для implementer/orchestrator.

Рефлексия процесса: ожидания JSON-синтаксиса не доказывают тип события, а
равенство трёх ролей не связывает их с назначенным кандидатом. Цена — один
FAIL-круг Crit206V1; класс конструкции. Закрыто отдельными CLI-контролями,
мутациями и единым controls, используемым также общей батареей. Новую общую
А-запись в wip не создаю: журнал дописывается только в main оркестратором.
Преграда edit с относительным заголовком доложена Main; та же операция в той
же собственной копии выполнена с абсолютным заголовком, без смены маршрута.

## Фактический замер исправительной пачки

| Команда | Сырой rc | Полный итог счётчика / наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 1 | KLETKI=82 ZELENYE=50 KRASNYE=32; красные — production, observer-клетки зелены |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=82 ZELENYE=82 KRASNYE=0 |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=34 POIMANY=34 ZHIVYH=0 |
| `catalog.py --check` | 0 | STABS=34 NORM_CONSUMERS=3; независимый wc -l stabs.tsv = 35 с заголовком |
| `live_control.py` | 0 | OBSERVER_CONTROLS=21 KRASNYE=0; LIVE_JUDGES_NOT_RUN |
| `check_precision_gate.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_spec_ready.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_ids.sh .` | 0 | номера уникальны и согласованы с регистром выдачи |
| `check_ceilings.sh .` | 0 | потолки в порядке |
| `check_provodka.sh --grammar . contracts/206-sreda-sudji.md` | 0 | без вывода |
| `check_threat_model.sh . contracts/206-sreda-sudji.md` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 5 |
| `check_predposylki.sh . contracts/206-sreda-sudji.md` | 0 | PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2 |
| `pre_critic.sh contracts/206-sreda-sudji.md` | 0 | КРИТИК: дверь зелёная |
| `check_sdacha.sh \"$PWD\" contracts/206-sreda-sudji.md --run` | 0 | двери=12 карта=17/17 дельта=5 |
| `validate_std.sh bash red_sreda_sudji_206.sh` | 0 | bash -n и shellcheck 0.11.0, sha256 сверяет штатная обёртка |

Валидатор исполнен полной командой `env VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck bash scripts/validate_std.sh bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`.
Первый запуск без шва дал rc2 VALIDATOR_MISSING: shellcheck: установленный бинарь
не был найден окружением HOME/PATH вызова. Существующий шов выбрал тот же
официальный бинарь; пины/окружение станции не менялись, новый бинарь не ставился.
Дополнительных дверей и обязательств сверх дельты Crit206V1 не введено.
