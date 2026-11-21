# Сдаточный лист 154 — одна инженерная переработка

Лист добавлен из-за живого требования двери 193: незамороженный черновик тоже обязан иметь СДАЧА. Это не новый critic-вызов и не разрешение его бюджета. Исторические FAIL v1…v1e прочитаны; они предшествуют карте классов 192/193 и не подменяются новым вердиктом автора.

## Двери

- pre_critic без рекурсивной ноги листа · bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- spec · bash scripts/check_spec_ready.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- threat · bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- provodka grammar · bash scripts/check_provodka.sh --grammar . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- honest model · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --model · 0 · 0
- domain model · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain-model · 0 · 0
- deceptive changes · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --stabs · 0 · 0

## Карта классов

- К-01 · чисто · вход: команды секции Двери, включая pre_critic под SDACHA_OKRUG=1; внешний pre_critic выполняет саму дверь листа · - · -
- К-02 · чисто · вход: OWNER-BATCH-1118 №18, roles/critic.md §Быстрый-процесс и ADR 2026-11-17 сопоставлены с И-1…И-9; шестой вызов не разрешён · - · -
- К-03 · чисто · вход: старый §6в сохранён дословно; installed-model-live CELLS=17 GREEN=17; затронутые потребители и frozen-пересечения названы в контракте · - · -
- К-04 · чисто · вход: ремонт К-08″ меняет только fixtures/workshop_project/schet_vyzovov_154/; production, текст frozen-контракта, CI и чужие зоны не меняются · - · -
- К-05 · чисто · вход: таблица приёмки задаёт команды и rc до/после реализации; предписанные consumer-команды не объявлены уже прогнанными · - · -
- К-06 · чисто · вход: probe.py инфраструктурные RuntimeError/OSError/ValueError завершает NOT_IMPLEMENTED rc 2; отсутствующий предметный state является проверяемым отказом rc 1 · - · -
- К-07 · чисто · вход: python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py — rc 0; честная вставка в настоящие копии CLI: repo 95/95, domain 221/221, live 17/17, grammar 2000/2000, каждый rc 0; production не менялся · - · -
- К-08 · чисто · вход: STAB_CASES сохраняет counter-outside-mutex → concurrent-start-last-base-position; расширенная concurrent-start-count-start-window наблюдает сам inode mutex через inotify и пробует mkdir между счётом и START; связи S1/S2/S3/S4, К-08 и К-08′ находятся в коде, не в контракте; честный контроль и каждый связанный мутант различимы · - · -
- К-09 · чисто · вход: две фазы, история, источник, адресный OBJECT/nomer/роль/ключ, третий и consultant-бюджет; весь SUBJECT 000…999, GRAMMAR=1000 CELLS=2000 · - · -
- К-10 · чисто · вход: успешный spawn добавляет ровно START, отказ сохраняет ledger; freeze сравнивает tag И registry; freeze-side-effect выявлен именно изменением снимка, не аварией · - · -
- К-11 · чисто · вход: oracle — чистая функция параметров до субъекта; снимки результатов до вызова в памяти; после субъекта ожидания не перечитываются · - · -
- К-12 · чисто · вход: JSON читает стандартный json; committed receipt сравнивается с каноном receipt_line буквально отдельной строкой из git show commit:path, не самодельным поиском формата · - · -
- К-13 · н/п · предмет не вводит обработку или вывод секретных значений; это не проверка редактирования секретов · - · -
- К-14 · чисто · вход: модель 98/98; две фактически consultant-позиции с арбитражем допустимы, третья отказана в обеих фазах; прямой owner не расходует два, альтернативная owner-строка не меняет реально выбранный consultant-источник · - · -
- К-15 · чисто · вход: счётчики взяты из сырых результатов; полный домен построен range(1000), не списком текущих тегов; текущая станция и исторические ≥21 вызов 143 разделены · - · -
- К-16 · чисто · вход: КЛАСС РИСКА деньги; модель угроз явно оставляет semantic-полномочия, подмену целого журнала, old-subject cutover и бюджет следующего вызова полномочной роли · - · -
- К-17 · н/п · харнесс не проект 187а с закреплённой моделью; архитектура механизма — одна функция бюджета существующей двери и её read-only повтор при freeze · - · -

## Дельта А154-1

| Блок | Способ | Команда | Сырой rc / наблюдение |
|---|---|---|---|
| А154-1: источник расхода | канон/инструмент — ADR 18.11; committed ISPOLZOVANO в том же append-only учёте связывает источник с позицией и OBJECT | W --model | 0; CELLS=90 GREEN=90 |
| А154-1: независимый пересчёт | клетка — одинаковые использованные источники в обеих фазах, дополнительные ARBITRAZH и неиспользованные разрешения | W --domain-model | 0; CELLS=217 GREEN=217 |
| А154-1: различимость и соседние регрессы | клетка — адресные мутации операций и честные парные контроли, привязки в STAB_CASES | W --stabs | 0; SVJAZI=46 CAUGHT=46 LIVE=0 |
| Б1–Б9 сохранены | канон/инструмент — честная вставка в копии настоящих CLI, затем только установленные режимы | python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0; repo/domain/live/grammar каждый rc 0 |

`W` — команда из приёмки контракта. Модель и оракул получают источник независимо от наличных альтернатив; ожидание остаётся чистой функцией параметров до субъекта. Отсутствие/конфликт источника даёт SCHET_NEIZVESTEN. Выбранный consultant на позиции 4 не становится базовым от ARBITRAZH; новый owner-grant не уменьшает прежний расход. Снимки ledger/tag/registry и положительные freeze-контроли сохранены.

Голые установленные режимы ДО production-реализации: `W --repo` → rc 1, CELLS=87 GREEN=18; `W --domain` → rc 1, CELLS=213 GREEN=19; `W --live` → rc 1, CELLS=9 GREEN=5; `W --grammar` → rc 1, GRAMMAR=1000 CELLS=2000 GREEN=0. Это именованные RED, не безусловные заглушки и не зелёная поставка.

Независимая мера структуры: импорт probe дал CASES=87, OLD=3, DOMAIN=213, OLD_DOMAIN=4, ATTRIBUTION=18, STABS=46, LIVE=9; grammar=1000, границы 000/999. Числа согласованы с сырыми итогами прогонов. Содержательная дельта контракта не даёт автоматического переноса санкции по ADR переиздания и не разрешает новый critic-вызов. Точный итоговый OBJECT — SHA коммита с этим листом в инженерном докладе, не SHA арбитража.

## Дельта А154-2 — Б-1 Adv154V1, красное до production

Frozen-текст 154/1 не меняется. Существующие world/prepare_scripts, чистый
oracle и installed_control переиспользованы; новые предъявления подключены
к repo/live/domain одним списком B1_CASES, привязки стабов — только в коде.
Прямой read-only счёт предъявляется перед соответствующей публичной дверью.
Первая законная заморозка создаёт настоящий след; вторая проверяет сохранность
снимков тегов и реестра при шести START без санкций.

| Блок | Способ | Команда | Сырой rc / наблюдение |
|---|---|---|---|
| Б-1: registry/пустой коммит/повторный freeze; С-1: ветка не тег | клетка | W --repo | 1; CELLS=93 GREEN=87 |
| Те же входы и доказанно старые контроли с доставленным снимком | канон/инструмент | W --live | 1; CELLS=15 GREEN=9 |
| Домен и сохранение прежних клеток | клетка | W --domain | 1; CELLS=219 GREEN=213 |
| Честные парные контроли | канон/инструмент | W --model | 0; CELLS=96 GREEN=96 |
| Домен модели | канон/инструмент | W --domain-model | 0; CELLS=223 GREEN=223 |
| Возвращённые production-обходы в копиях дверей | клетка | W --stabs | 0; SVJAZI=51 CAUGHT=51 LIVE=0 |
| Полный SUBJECT | канон/инструмент | W --grammar | 0; GRAMMAR=1000 CELLS=2000 GREEN=2000 |
| Честная вставка в установленные CLI | канон/инструмент | python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0; repo 93/93, domain 219/219, live 15/15, grammar 2000/2000; каждый INSTALLED_CONTROL rc=0 |

ДО (из прочитанного Adv154V1, не повторный прогон): repo 87/87,
domain 213/213, live 9/9; каждый rc 0; SVJAZI=46 CAUGHT=46 LIVE=0.
ПОСЛЕ: все прежние клетки зелёные; ровно шесть новых красны на BASE.
Имена: b1-no-boundary-registry-spawn, b1-no-boundary-registry-freeze,
b1-no-boundary-empty-spawn, b1-no-boundary-empty-freeze,
b1-branch-not-tag-spawn, b1-refreeze-v2-six-start.
Первые пять требуют rc 1 SCHET_NEIZVESTEN (нет ISPOLZOVANO);
последняя — rc 1 KAP_VYZOVOV_KRITIKA (выбор есть, санкции нет).
На BASE read-only возвращает rc 3, двери — rc 0; отказные freeze
создают тег/меняют реестр, что батарея отдельно наблюдает.

Независимый импорт коллекций: CASES=93 OLD=3 DOMAIN=219 OLD_DOMAIN=4
B1=6 STABS=51 LIVE=15. Модель теперь разрешает только refs/tags,
не DWIM-ветку. Отсутствие снимка/след registry канон уже судит как новое;
registry-only доказательство старости при доступном снимке канон не реализует
и эта дельта не приписывает ему такого обещания. Остальные шесть мутаций
С-5 не добавляются; принятый остаток консультации не расширен.

Двери формы на этой дельте: pre_critic rc 0, «КРИТИК: дверь зелёная»;
check_sdacha --run rc 0, «СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=0)».
check_contract_frozen rc 1 из-за lightweight frozen-тегов изолированной копии;
его же предметные строки 154/v1 и 187/v3: «блоб совпадает побайтово».
Это не зелёный общий frozen-гейт и не основание менять теги или тексты.


## Конформные toy-миры двери 140 v5

База реализации — `11137c50a4f610f9306a5febf7074d7b67475065`.
Изменён только `probe.py` и этот лист; контракт, production, оракул и
списки предъявлений не менялись. Переиспользованы `world`, `gcommit`,
`add_receipts` и существующий канон annotated frozen/pin семьи 140.

Исторические verdict-коммиты имеют кодовый предок, одну строку OBJECT,
author=committer critic и прежние author-date. Рабочий кандидат получает
отдельную непустую кодовую правку; его START, санкции текущей позиции и
задание судьи называют этот кодовый OBJECT, не SHA verdict-коммита.
Receipt-коммиты остаются в репозитории владельца, вне линии кандидата:
нет самоссылочного SHA и нет замены исторических START новым OBJECT.
После receipts кодовый корень кандидата снимается заново; для двери с
`object_kandidata` добавляется обычный critic-only хвост с тем же OBJECT.
Закреплённый до-v5 модельный CLI сравнивает сырой tip и получает кодовый
кандидат без этого хвоста; бюджетные входы и ожидания от этого не меняются.

Spawn-миры несут настоящий annotated frozen, ref и закоммиченный pin
TAG-объекта с risk в закреплённом дереве. Canonical origin рабочего клона
совпадает с владельцем: локальный адрес клонирования не превращает
станционный мир в переданный продукт. Freeze-миры не получают подаренной
v1; законная первая заморозка и отказ refreeze-v2 сохраняют прежний смысл.
В refreeze кодовая v2 и её critic-only verdict разделены.

Все команды ниже выполнялись с `TMPDIR=/tmp/dev-harness-verify/arch154w-2786069`
и `PYTHONDONTWRITEBYTECODE=1`; `W` определён приёмкой контракта.

| Команда | rc | Сырой итог |
|---|---|---|
| W --repo | 0 | CELLS=93 GREEN=93 |
| W --domain | 0 | CELLS=219 GREEN=219 |
| W --live | 0 | CELLS=15 GREEN=15 |
| W --model | 0 | CELLS=96 GREEN=96 |
| W --domain-model | 0 | CELLS=223 GREEN=223 |
| W --grammar | 0 | GRAMMAR=1000 CELLS=2000 GREEN=2000 |
| W --stabs | 0 | SVJAZI=51 CAUGHT=51 LIVE=0 |
| python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0 | INSTALLED_CONTROL repo/domain/live/grammar rc=0; 93/93, 219/219, 15/15, 2000/2000 |
| W --family140 | 0 | FAMILY140_BASE=76006c7c84306cdc1fd4da50e7eddd2aa426180e rc=0 red=; FAMILY140_CANDIDATE rc=0 red=; GREEN family140-baseline |
| bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs | 0 | MODEL_KLETKI 172 KRASNYH 0; SVJAZI 159; MODEL_ZHIVYH 0; SUBJEKT_SVJAZI 159 |

Различимость соседних дверей проверена существующей матрицей 140 над
настоящим production: `s08-bez-object-sverki` на `s03-object-rashoditsja`,
`s66-verdikt-bez-binding` на `q14-chuzhoj-object-v-seredine` и
`s75-stancija-bez-frozen-ref` на `q31-stancija-frozen-net` дали
`SUBJEKT STAB … KRASEN`; честные пары зелёные. Бюджетные регрессы по-прежнему
ловит неизменённая матрица 154. Никакая соседняя дверь ради toy не ослаблена.


## Дельта

- К-08 · клетка · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --stabs · 0 · 0

## Конкурентный START — Adv154V7b

Основание — прочитанный файл `/tmp/dev-harness-verify/adv154-verdict-v7.md`,
OBJECT `8d37c09ea6cdcc15884eca607d58ca4d9ac68297`. Это adversary FAIL,
не новый critic-вердикт и не выдуманная карта классов; прежняя история листа
сохранена. Поле «ПРЕДЫДУЩИЙ ВЕРДИКТ» не добавляется: файл вне HEAD
не удовлетворяет git-проверке `check_sdacha.sh`.

Переиспользованы world/prepare_scripts и закреплённая модельная вставка.
Одна новая клетка `concurrent-start-last-base-position` добавлена в
repo/domain/live/model/domain-model, одна связь `counter-outside-mutex`
добавлена в STAB_CASES. Ни прежние предъявления, ни production, ни контракт
не изменены. Модель бюджета не меняется: её существующая вставка держит
счёт и START под тем же mutex и проходит тот же конкурентный вход.

В копии двери две pipe-точки останавливают процессы после счёта либо при
неудавшемся захвате mutex. Первый процесс завершает START только после
того, как второй наблюдал занятый mutex (честная дверь) или уже сосчитал
ту же позицию (мутант). Затем завершается второй. Окно расширяется
барьером, без sleep и без правки production. Отдельные file descriptors
не забирают stdin у существующих heredoc-циклов двери.

Ожидание сохранено до обоих процессов: rc=[0,1], именованный
ZAMOK_BROSHEN второго, неизменный префикс журнала и ровно одна добавленная
START critic|critic-sol своего ключа. Установка мутанта — дословное
снятие mutex до счётчика и повторный захват после; прочие проверки прежние.
На настоящей установленной двери и на модельной вставке мутант наблюдался
как rc=[0,0], appended=2, competing=counted; честные пары зелёные.

Независимый импорт коллекций: CASES=94 DOMAIN=220 LIVE=16 MODEL=97
DOMAIN_MODEL=224 STABS=52. До → после: repo 93→94, domain 219→220,
live 15→16, model 96→97, domain-model 223→224, stabs 51→52;
grammar остаётся 2000. Исторические числа выше относятся к своим дельтам.

Развилки: канон бюджета и frozen-обязательство И-1 уже определены;
прозой запрет не доказать, поэтому добавлена одна поведенческая клетка.
Новый отказ/новый продуктовый механизм не вводятся.

Приёмка дельты с `PYTHONDONTWRITEBYTECODE=1`:

| Команда | rc | Сырой итог |
|---|---|---|
| W | 0 | CELLS=94 GREEN=94 |
| W --domain | 0 | CELLS=220 GREEN=220 |
| W --live | 0 | CELLS=16 GREEN=16 |
| W --model | 0 | CELLS=97 GREEN=97 |
| W --domain-model | 0 | CELLS=224 GREEN=224 |
| W --grammar | 0 | GRAMMAR=1000 CELLS=2000 GREEN=2000 |
| W --stabs | 0 | SVJAZI=52 CAUGHT=52 LIVE=0 |
| python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0 | INSTALLED_CONTROL repo/domain/live/grammar rc=0 |
| concurrent_start(..., 'repo', 'counter-outside-mutex'), rc по результату клетки | 1 | RED concurrent-start-last-base-position; actual rc=[0,0] appended=2 competing=counted |

В изолированном worktree `W --family140` вернул rc 1
`FAMILY140_MEASUREMENT_UNKNOWN: command rc=128: … scripts/gitw ls-remote`.
В отдельном клоне с собственным .git и ssh-origin на базе поезда:
rc 0, `FAMILY140_BASE=8768512a6aad43a7c9fb12f73872858e203250b7 rc=0 red=`,
`FAMILY140_CANDIDATE rc=0 red=`, `GREEN family140-baseline`.
Это замер среды, не подавление отказа и не смена ожидания.

Процессное наблюдение: stdin двери занят heredoc-циклами; синхронизация
через stdin дала ложный rc 2. Устранено выделенными pipe descriptors и
проверено честной парой плюс обеими мутациями. Общий журнал А-NNN в main
не менялся: он вне разрешённой fixture-only зоны и не пишется в wip.

Двери на этой дельте: `bash scripts/pre_critic.sh --repo .
contracts/154-schet-vyzovov-kritika.md` → rc 0,
`КРИТИК: дверь зелёная`; `bash scripts/check_sdacha.sh "$PWD"
contracts/154-schet-vyzovov-kritika.md --run` → rc 0,
`СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=1)`.

## Окно счёт → START — Adv154N4, К-08′

> ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/adversary/contracts-154-v8.md

Основание: FAIL К-08′, OBJECT
`b8d8d277615249572b3f1cf8c14630bb16cc3a4c`; committed verdict находится
в `9e31b938e915a8e49c2e17ba583de4e783177011`,
ветка `archive/154/adversary-v8-fail-9e31b938e9`, не в main/HEAD.

Именованное ограничение формы: машинная строка без цитирования даёт
`check_sdacha --run` rc 1:
`ОТКАЗ: предыдущий вердикт не закоммичен (AGENTS п.9): verdicts/adversary/contracts-154-v8.md`.
Дверь читает только HEAD:path, не archive/commit:path. Поэтому архивная
ссылка выше цитируется, а не выдаётся за доступный HEAD-вердикт.
Покрытие К-08′ предъявляется клеткой и существующей строкой Дельта;
автоматическая сверка карты архивного вердикта этой дверью не заявлена.

Добавлены одна клетка `concurrent-start-count-start-window` и одна
связь `mutex-gap-after-counter` в коде STAB_CASES. Существующая
`concurrent-start-last-base-position` и её связь не ослаблены.
Модель бюджета, production и frozen-контракт не меняются.

Исторический checkpoint этой редакции перехватывал снятие ТОЛЬКО внутри
`mutexi_snyat_vse`, а не состояние самого каталога. Reviewer `7034aa7c7d`
измерил ложную зелень S1/S2/S4 во всех установленных режимах и реальное
превышение бюджета. Утверждение о независимости от переноса снятия было
неверным; ниже оно заменено наблюдением самого mutex. Исторические
результаты К-08′ в этом разделе относятся только к своему мутанту.

Адресные контроли repo/domain/live/model: честные две клетки rc 0,
каждый связанный мутант rc клетки 1; новый мутант даёт
`actual rc=[0,0] appended=2 competing=released`. Это изменение
расписания настоящих --sudit, без подмены результата счётчика и sleep.

Процессное наблюдение: предыдущее расписание останавливало процесс
до возможного снятия mutex, поэтому сериализовало именно соседний
дефект. Новый checkpoint ждёт наблюдаемого снятия либо границы START.
Журнал А-NNN в main не менялся: он вне fixture-only зоны задания.

Приёмка дельты с `TMPDIR="$PWD/.scratch-154r3"` и
`PYTHONDONTWRITEBYTECODE=1`:

| Команда | rc | Сырой итог |
|---|---|---|
| W | 0 | CELLS=95 GREEN=95 |
| W --domain | 0 | CELLS=221 GREEN=221 |
| W --live | 0 | CELLS=17 GREEN=17 |
| W --model | 0 | CELLS=98 GREEN=98 |
| W --domain-model | 0 | CELLS=225 GREEN=225 |
| W --grammar | 0 | GRAMMAR=1000 CELLS=2000 GREEN=2000 |
| W --stabs | 0 | SVJAZI=53 CAUGHT=53 LIVE=0 |
| python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0 | INSTALLED_CONTROL repo/domain/live/grammar rc=0; 95/95, 221/221, 17/17, 2000/2000 |
| bash scripts/check_sdacha.sh "$PWD" contracts/154-schet-vyzovov-kritika.md --run | 0 | СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=1) |

Независимый импорт коллекций: CASES 95 DOMAIN 221 LIVE 17 MODEL 98
DOMAIN_MODEL 225 STABS 53. До → после: W 94→95, domain 220→221,
live 16→17, model 97→98, domain-model 224→225, stabs 52→53;
grammar 2000→2000. Исторические числа выше не переписаны.

Воспроизведение — собственный одноразовый git-клон внутри scratch.
Дословный Python из `9e31b938e9:verdicts/adversary/contracts-154-v8.md`
выполнен без изменения: rc скрипта 0; старые клетки repo/domain/live
rc 0 GREEN; независимая гонка `actual rc 0` дважды, `critic-starts 3`.
Тот же скрипт с единственной заменой вызова старой клетки на
`concurrent_start('concurrent-start-count-start-window', mode, window=True)`:
rc скрипта 0; НОВАЯ клетка repo/domain/live rc 1,
`actual rc=[0,0] appended=2 competing=released`; независимая гонка
по-прежнему даёт две rc 0 и `critic-starts 3`. Нулевой rc скрипта
воспроизведения не выдаётся за зелёный результат мутантной клетки.

`W --family140` в рабочем worktree: rc 1,
`FAMILY140_MEASUREMENT_UNKNOWN: command rc=128: … scripts/gitw ls-remote`.
В том же одноразовом клоне с origin, указывающим внутрь своей копии:
rc 0,
`FAMILY140_BASE=9f1e70492caddd7a09707c616da352360f2c4572 rc=0 red=`,
`FAMILY140_CANDIDATE rc=0 red=`, `GREEN family140-baseline`.
Это отдельный замер разрешённой среды, не подавление первого отказа.

## Дельта А154-5 — Б-1 Rev154V1, К-08″

> ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/review/contracts-154-v1.md

FAIL Б-1 прочитан из `7034aa7c7ddfbc2b23f52dd4b866f4a42306f878`,
OBJECT `25cb31504a8f347da0ea859e7bd6e405174c3f1c`. Как и архивный
`9e31b938e9:verdicts/adversary/contracts-154-v8.md` выше, этот verdict
не находится в HEAD кандидата. Цитата не выдаётся за машинную строку
HEAD:path; автоматическая карта архивного verdict через check_sdacha
не заявлена. Именованная ветка archive reviewer недоступна на origin
(`fatal: couldn't find remote ref archive/154/reviewer-v1-fail-7034aa7c7d`,
rc 128); сам commit получен с канонического origin по полному sha.

Существующая клетка `concurrent-start-count-start-window` расширена,
`concurrent-start-last-base-position` не изменена. Production,
frozen-контракт, чистый оракул и модель бюджета не меняются.
Наблюдение — тот же inode каталога `zamki/<repoId>/<NNN>/mutex`,
запрет конкурирующего mkdir и отсутствие событий удаления/перемещения
inotify. Снимок и watch устанавливаются после реального счёта, пока
процесс стоит на pipe, и проверяются до настоящего jq-писателя START,
а не до комментария D23. DEBUG-точки в копии двери лишь задают
расписание: они не распознают release/helper/rmdir. inotify сохраняет
след удаления даже при remove/recreate в одном внешнем вызове.
Ожидание ledger остаётся в памяти до обоих процессов.

Канон/инструмент — inotify Linux, stat и настоящий mkdir; самописный
разбор Bash и перечень способов снятия не используются. Новая клетка
не нужна: расширена существующая. DEBUG нужен для детерминированного
расписания, поскольку асинхронный опрос может пропустить немедленный
reacquire. При обнаружении разрыва первый процесс стоит до reacquire,
пока второй проходит тот же count. Тот же mkdir на честном mutex
отказан; после реального START обычное освобождение допускается.

Связи к ветвям живут только в `STAB_CASES`: к расширенной клетке
добавлены S1 (прямой rmdir), S2 (inline), S3 (обратный reacquire),
S4 (немедленный reacquire) и К-08 (count вне mutex). Прежняя связь
К-08′ сохранена. На адресной пробе repo/model честная клетка rc 0;
каждый из шести мутантов repo даёт rc клетки 1,
`actual rc=[0,0] appended=2 competing=released mutex-continuity=lost`.

Процессное наблюдение: привязка к имени helper была ложным оракулом
непрерывности владения. Источник события теперь файловая система,
а helper не является швом проверки. Общий А-NNN не записан в wip:
журнал main вне fixture-only зоны; наблюдение передаётся оркестратору.

| Блок | Способ | Команда / вход | Сырой rc / наблюдение |
|---|---|---|---|
| Б-1 К-08″ | канон/инструмент — наблюдение inode и inotify вместо helper-checkpoint | W; W --domain; W --live | каждый 0; 95/95, 221/221, 17/17 |
| Б-1 модель | клетка на прежней независимой модели | W --model; W --domain-model | каждый 0; 98/98, 225/225 |
| Б-1 связи | адресные S1/S2/S3/S4, К-08, К-08′ | W --stabs | 0; SVJAZI=58 CAUGHT=58 LIVE=0 |
| Б-1 установленный контроль | настоящие копии CLI с честной модельной вставкой | python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0; repo/domain/live/grammar каждый rc 0 |
| И-9 сохранён | полный домен без изменения ожиданий | W --grammar | 0; GRAMMAR=1000 CELLS=2000 GREEN=2000 |

До → после, независимо сверено импортом коллекций с итогами прогонов:
W 95→95; domain 221→221; live 17→17; model 98→98;
domain-model 225→225; grammar 2000→2000; stabs 53→58; LIVE 0→0.
Ни одна прежняя клетка или связь не удалена.
В сыром выводе `W --stabs` остаётся диагностический `NOT_IMPLEMENTED:
учёт не создать: .../state/uchet.jsonl` отказного стаба; итог режима
rc 0 и все 58 связей пойманы, а не объявлены зелёным контролем.

Мутанты установлены в `scripts/zamok_predmeta.sh` одноразового клона
с собственным `.git` внутри `.scratch-154r4`; основная дверь не менялась.
Каждое предъявление — отдельный процесс Python с rc самой клетки,
не rc объединённого сценария. Для S1/S2/S3/S4, К-08 и К-08′
в каждом repo/domain/live: rc 1, единственный именованный результат
`RED concurrent-start-count-start-window`, `actual rc=[0,0] appended=2
competing=released mutex-continuity=lost`. Wrapper проверки этих
ожидаемо красных результатов вернул rc 0.

Соседние мутации шире примера: один внешний `bash -c` удаляет mutex
и тут же создаёт новый либо перемещает исходный и создаёт новый —
обе rc клетки 1, `mutex-continuity=lost`, даже при фактических
`rc=[0,1] appended=1 competing=blocked`. Тем самым inotify/identity
не сводится к удачной выборке отсутствующего каталога.
Честные эквиваленты на настоящей двери: переименование helper,
inline обычного освобождения ПОСЛЕ START и создание/удаление соседнего
каталога — каждый rc клетки 0. Это зелёные пары для запрета разрыва
inode, терминатора START и точечной области watch; новые обязательства
контракта не добавлены.

`W --family140` выполнен в отдельном клоне с собственным `.git`
и origin `.scratch-154r4/origin.git` внутри своей копии:
rc 0, `FAMILY140_BASE=7b2cbcec75e3ded884bfda18cc1d491dbdec0c9b rc=0 red=`,
`FAMILY140_CANDIDATE rc=0 red=`, `GREEN family140-baseline`.
Это замер именно разрешённой локальной среды; сетевой запуск текущей
дельты не заявлен. Основной origin не менялся; push не выполнялся.

`bash scripts/check_sdacha.sh "$PWD"
contracts/154-schet-vyzovov-kritika.md --run` → rc 0:
`СДАЧА: лист зелёный (двери=9 карта=17/17 дельта=1)`.
Все прогоны дельты использовали `TMPDIR="$PWD/.scratch-154r4"` и
`PYTHONDONTWRITEBYTECODE=1`; `stancija_*` не запускались.
