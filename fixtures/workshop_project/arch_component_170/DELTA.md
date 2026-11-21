# 170 — адресный v+1 pinned brief

## Обязательство → клетка

| Обязательство | Различающее предъявление |
|---|---|
| Полный большой бриф вместо отказа по 40000 | `brief_pinned_over_budget`, `brief_pinned_plain` |
| Компоненты не смешаны и не потеряны | `brief_pinned_multi`, `brief_aggregate_budget` |
| Малый бриф остаётся inline, включая смешанный пак | `brief_small_inline`, `brief_mixed_small_inline` |
| Путь, byte length, sha256, обязательное чтение, исполняемая проверка | `brief_pinned_over_budget`; адресные мутации метаданных в `pinned.MUTANTS` |
| Полный stdout, не срез и не нормализация переводов строк | `brief_no_slice`: UTF-8, два завершающих LF, CRLF, маркер другого компонента внутри данных; побайтовый оракул в памяти |
| Успешный stderr npm не часть stdout брифа | `STDERR_CASES`: pinned/inline × rules/plain; точные байты, метаданные, чтец и отсутствие предупреждения в паке |
| Доступность и целостность до выдачи; без частичного пака | `brief_pin_missing`, `brief_pin_tampered`: второй pin в двухкомпонентном паке недоступен/изменён; stdout пуст |
| Читаемость и размещение вне checkout/.git | `brief_pin_unreadable`, `brief_pin_checkout`, `brief_pin_git` |
| Честные эквивалентные пути | `brief_pinned_spaces`, `brief_pinned_external_symlink` |
| Проверка потребителем до выдачи ему байтов | `brief_read_missing`, `brief_read_tampered`, `brief_read_same_size`, `brief_read_length_pin`, `brief_read_checkout` |
| Потолок 40000 не повышен; ссылка учитывается общим сериализатором | `brief_over_budget`, `brief_pack_cap`; мутации `cap_raised`, `brief_outside_budget` |

Привязки стабов живут только в коде: `probe.py:mutants` и `pinned.py:MUTANTS`, не в контракте.
Проверяющий исполняет команду потребителя с настоящим Python/файлами, не подменяет валидатор двойником.
Мутации удаления проверки длины и хеша различаются отдельными входами; для честного pin та же команда выдаёт полный ожидаемый stdout.

## Совместимость frozen

Адресно заменены обязательства frozen 170/1:17 и :29. Прочие исходные строки контракта сохраняются дословно; добавлены место продукта, существующий state, детали доставки и новые rc-сценарии.

Исходная `brief_over_budget` проверяла отказ на одном большом брифе. Оставлять одновременно этот отказ и новый успех pinned brief нельзя: именно это обязательство :29 разрешено изменить. Имя клетки сохранено, а её вход теперь несёт небрифовый КОНТЕКСТ за потолком и малый inline-бриф; отрицательный кап не ослаблен. Удалённая старая привязка `brief_outside_budget` заменена адресным стабом того же имени против pinned-ветви. Остальные исходные клетки и стабы сохранены. Единая новая честная модель проходит и исходные, и новые клетки.

Модель — только исполняемый канон до freeze. `pinned_model.py` не подключён в production; его потребители — модель батареи и критик. Production-реализация остаётся в зоне implementer (`scripts/make_task.sh`), после freeze; источник архитектуры 187 не меняется.

## Команды и сырой вывод

Из корня своей копии: `mkdir -p .scratch-170; export TMPDIR="$PWD/.scratch-170" PYTHONDONTWRITEBYTECODE=1`.

- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo "$PWD"` — rc 1 на новых клетках; `.scratch-170/repo.log`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` — честный контроль; `.scratch-170/model.log`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` — адресные стабы; `.scratch-170/stabs.log`.
- `python3 fixtures/workshop_project/arch_component_170/regressions.py` — утверждения `red_pravila_proekta_ne_harsa.sh` и `red_model_trace_169.sh --model`; `.scratch-170/regressions.log`.

Исторические фикстуры 095/169 жёстко пишут в `/tmp/dev-harness-verify`, игнорируя TMPDIR. `regressions.py` переносит только их scratch: неизменённый bash-тест 095 и исходный модуль 169 исполняются с локальной копией `_toy.sh`, в которой заменён корень временных файлов. Исходные production-файлы, git-pinned модель, аргументы и утверждения тестов не меняются. Прямой запуск двух исторических shell-команд не предъявляется как выполненный: он нарушил бы запрет задания писать вне изоляции.

## Доставка и граница

Коммит — только файлы этой семьи. Текст `contracts/170-arch-component-brief-vhod-zadanija.md` остаётся незакоммиченным; patch и полная копия передаются в `.scratch-170`, хеши — в докладе. Агент не пишет строку разрешения владельца и не пушит.

В исходной пачке суд, лист формы перед судьёй, owner-коммит текста, freeze, production-реализация, CI и shared-журнал наблюдений не выполнялись. Вызов критика ведёт orchestrator после законного коммита текста. Следование живого агента обязательной инструкции остаётся cognitive-only; проверяемое свойство — валидатор не выдаёт ни байта при нарушенном pin.

## Исправление pre_critic на базе 1a0ddc095a

Приёмка контракта актуализирована по новым красным клеткам pinned brief;
старые клетки 170/1 и отрицательный небрифовый cap остаются зелёными.
Контракт остаётся незакоммиченным, patch и полная копия — в `.scratch-170b`.

Первый прогон spec-ready после замены причины выявил таймаут пробы:
полный последовательный `--stabs` занял 96.122 секунды при лимите двери 60.
Полные CASES, MUTANTS, честный контроль и предикаты сохранены. Только
исполнение клеток и независимых мутантов распределено между четырьмя
процессами: отдельный мир и TMPDIR каждого pinned-входа, отдельный файл
каждого мутанта рядом с прежними helpers. Общий script субъекта не меняется.
Таймаут, ожидаемые rc и различающие входы не ослаблялись.
Вывод workers снимается в память и печатается только родителем в порядке
входов: конкурирующие print не склеивают строки клеток и стабов.

После этого spec-ready дал `OK`, rc 0. Следующая нога pre_critic потребовала
сдаточный лист для отличающегося от frozen текста; добавлен `SDACHA.md`
с существующей грамматикой двери 193. Текущие raw-логи и коды возврата
передаются в `.scratch-170b`; прежние замеры выше относятся к прошлой пачке.

## Исправление Crit170V2 на базе 7fc5639f75411a6c2768429ed78f957844c65c48

Контракт :19 требует полный stdout, :29 связывает с ним длину и sha256;
успешный stderr не является частью stdout. Противоречия с frozen 170/1
нет: отказ npm по-прежнему rc 1, stdout пуст, первая строка stderr —
`ОТКАЗ: ARCH_BRIEF_OTKAZ: <id>`. Текст контракта не изменён.

Найдено два места смешивания в MODEL_BODY (`probe.py`), с rules и без;
`pinned.py:model_text` наследовал оба через shell-подстановки с `2>&1`.
`pinned_model.py` сам npm не вызывает и уже разделяет потоки чтеца через
capture_output. Модель теперь отбрасывает npm stderr отдельно от stdout,
не выпуская его перед именованным отказом; точный stdout с завершающими LF
сохранён прежним сентинелом, привязанным только к npm-argv.

Новые входы: `brief_stderr_pinned`, `brief_stderr_pinned_plain`,
`brief_stderr_inline`, `brief_stderr_inline_plain`. Fixture npm пишет
`npm WARN successful brief` только в stderr успешного запуска. Для pin
используются прежние точные сверки байтов, длины, sha256 и живого чтения;
inline дополнительно сверяется целой секцией. Оракул в памяти до субъекта.
Во всех четырёх входах предупреждение отсутствует в stdout пака.
Мутант `stderr_merged` предъявляется каждой ветви кодом pinned.MUTANTS.
Честные соседи — прежние inline/pinned-клетки без предупреждения.

До исправления модели новые клетки на прежнем OBJECT различают дефект:

```text
170 brief_stderr_pinned KRASNO rc=0 stderr=''
170 brief_stderr_pinned_plain KRASNO rc=0 stderr=''
170 brief_stderr_inline KRASNO rc=0 stderr=''
170 brief_stderr_inline_plain KRASNO rc=0 stderr=''
170 PIN_CONTROL_INVALID
```

`red_arch_component_170.sh --model` → rc 1, `.scratch-170c/red-before.log`;
прежние клетки остались зелёными. Состав получен независимо AST-чтением
исходных списков из git и импортом текущих кортежей: клетки 45 → 49
(25 прежних + 20 → 24 pinned); предъявления стабов 36 → 40
(14 прежних + 22 → 26 pinned), один новый мутант на четырёх входах.

Все текущие логи — `.scratch-170c/`. Регрессии 095/169 исполняются через
прежний regressions.py: только scratch перенесён внутрь копии, теперь
адаптер уважает TMPDIR; production/argv/утверждения не меняются.
Прямые исторические shell-обёртки с жёстким внешним scratch не запускались.

На реальной до-v+1 двери `--repo` → rc 1: 27 зелёных, 22 красных —
18 прежних pinned-клеток из :39 и четыре новых STDERR_CASES.
Полный список и сырой вывод — `.scratch-170c/repo.log`.
Адаптированные 095/169 → rc 0, `.scratch-170c/regressions.log`:

```text
095 red_pravila_proekta_ne_harsa rc=0 (scratch relocated only)
169 project_no_arg ok rc=0 stderr=''
169 explicit_model_string ok rc=1 stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv'
169 explicit_missing_path ok rc=1 stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv'
169 no_trace_anywhere ok rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 orchestrator_step_0 ok
169 red_model_trace_169 --model rc=0 (scratch relocated only)
```

После разделения потоков отказный npm по-прежнему выдаёт непустой stdout
перед rc 17 (обязательство :42): npm_stub.py явно печатает PARTIAL-BRIEF.
Иначе прежние npm_failure_ignored ложно ловились бы только проверкой
пустого брифа, а не rc npm. Их собственные входы и ожидания сохранены.
Inline-секция ограничена следующим заголовком тем же способом, что
прежние pinned-сверки: последующие TASK/PROJECT-секции не часть брифа.

Итог на исправленном кандидате (TMPDIR внутри копии):
`--model` rc 0, 49 зелёных; `--stabs` rc 0, 40 caught, ни одного ZHIV.
Сырые логи: `.scratch-170c/model-final.log`, `stabs-final.log`,
`sdacha-final.log`, `pre-critic-final.log`; коды и счёт — `final-summary.json`.

```text
170 brief_stderr_pinned ok rc=0 stderr=''
170 brief_stderr_pinned_plain ok rc=0 stderr=''
170 brief_stderr_inline ok rc=0 stderr=''
170 brief_stderr_inline_plain ok rc=0 stderr=''
170 STAB stderr_merged caught @ brief_stderr_pinned
170 STAB stderr_merged caught @ brief_stderr_pinned_plain
170 STAB stderr_merged caught @ brief_stderr_inline
170 STAB stderr_merged caught @ brief_stderr_inline_plain
СДАЧА: лист зелёный (двери=3 карта=17/17 дельта=0)
КРИТИК: дверь зелёная
```

`bash scripts/check_sdacha.sh . contracts/170-arch-component-brief-vhod-zadanija.md --run`
→ rc 0; `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md`
→ rc 0. Внешний журнал и контракт не менялись, push не выполнялся.

## Исправление Crit170V3, К-07 на базе e9497eecbdc5f0c6be44f599df9a09925ebfafc2

Обещание: недоступный pin до выдачи любых байтов отказывает rc 1 с первой
строкой `ОТКАЗ: ARCH_BRIEF_PIN: unavailable`; inline CRLF сохраняется побайтно.
Frozen-обязательства не меняются; текст контракта и production вне правки.
Существующее: единый `pinned_model.py:READER` уже обслуживает producer
и READ_COMMAND; `probe.invoke` — общий subprocess-шов; `pinned.run_case`
снимает независимый оракул в память до вызова.

| Находка | Место и правка | Клетка | Стаб |
|---|---|---|---|
| Необработанный цикл pin до выдачи | READER ловит OSError и RuntimeError как unavailable; producer-обёртка так же именует ошибки файловых операций | `brief_pin_symlink_loop`: полный brief ровно 45000 байт, самоссылка по hash-пути | `loop_traceback` |
| Необработанный цикл при чтении | Тот же канон, после честного полного чтения файл заменяется самоссылкой | `brief_read_symlink_loop` | `loop_traceback` |
| Transport скрывает потерю CR | invoke возвращает bytes; pinned больше не делает encode после text=True | `brief_inline_crlf`: `# ARCH-BRIEF:api.identity\r\nline\r\n` | `crlf_normalized` |

Обманные helpers создаются внутри временного каталога субъекта: первый
сужает catch READER до FileNotFoundError (цикл снова даёт traceback),
второй нормализует реальные inline-байты CRLF→LF. Producer/read привязаны
к разным входам кодом MUTANTS; замена оракула или результата тестом не делается.
`pin_bytes` переводит недоступный/зацикленный путь субъекта в неуспешное
наблюдение, а не traceback проверяющего; expected по-прежнему из памяти.

До правки канона и transport новые клетки на старой модели дали:

```text
170 brief_pin_symlink_loop KRASNO rc=1
170 brief_read_symlink_loop KRASNO rc=0 stderr=''
170 brief_inline_crlf KRASNO rc=0 stderr=''
170 PIN_CONTROL_INVALID
```

Это выдержка: stderr producer начинался `Traceback (most recent call last):`.
Обёртка `--model` вернула rc 1. После правки та же команда вернула rc 0:

```text
170 brief_pin_symlink_loop ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_PIN: unavailable'
170 brief_read_symlink_loop ok rc=0 stderr=''
170 brief_inline_crlf ok rc=0 stderr=''
170 STAB loop_traceback caught @ brief_pin_symlink_loop
170 STAB loop_traceback caught @ brief_read_symlink_loop
170 STAB crlf_normalized caught @ brief_inline_crlf
```

rc=0 в read-клетке относится к producer; внутри отдельно проверены rc=1
чтеца, пустой stdout и единственная строка unavailable. Честные соседи:
`brief_pinned_external_symlink`, `brief_small_inline`, `brief_no_slice`;
прежний dangling `brief_pin_missing` ожидаемо отказывает без traceback.
Все прежние клетки и предъявления стабов сохранены.

Счёт из деклараций базы/current (AST + импорт), независимо — из логов:
клетки 49 → 52, предъявления стабов 40 → 43, уникальные имена 30 → 32;
`model.log`: 52 ok; `stabs.log`: 43 caught, ZHIV 0.
`repo.log`: 27 ok, 25 KRASNO; красные — прежние 18 pinned из :39,
четыре STDERR_CASES и три новых входа. Для прежней production-двери
CRLF-клетка также различает утрату завершающего LF.

Текущие команды исполняются с `TMPDIR="$PWD/.scratch-170d"` и
`PYTHONDONTWRITEBYTECODE=1` внутри копии; scratch не входит в коммит.
`--repo` rc 1, `--model` rc 0, `--stabs` rc 0;
`python3 fixtures/workshop_project/arch_component_170/regressions.py` rc 0.
Сырые stdout: `.scratch-170d/repo.log`, `model.log`, `stabs.log`,
`regressions.log`. Регрессии 095/169 используют прежний адаптер только scratch.

Предыдущий FAIL — `verdicts/critic/contracts-170-v2.md` в коммите
`0bd289f8dd912f648a8e7cdbf5c3d65e2baf1f57`, архивная ветка
`archive/170/critic-v2-fail-0bd289f8dd`. Ограничение
ПРЕДЫДУЩИЙ_ВЕРДИКТ_ВНЕ_HEAD: дверь сдаточного листа умеет только HEAD:<путь>;
в листе точная ссылка приведена цитатой, а не машинной ссылкой на иной блоб.
К-07 покрыт явной дельтой; автоматическое покрытие архивного FAIL не заявлено.

Финальные двери на этом кандидате, с тем же локальным TMPDIR:

```text
$ bash scripts/check_sdacha.sh . contracts/170-arch-component-brief-vhod-zadanija.md --run
СДАЧА: лист зелёный (двери=3 карта=17/17 дельта=1)
rc=0
$ bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
КРИТИК: дверь зелёная
  ok   сдаточный лист красен
rc=0
```

Полный вывод дверей: `.scratch-170d/sdacha.log`, `pre-critic.log`.
Относительный путь первого edit был отклонён Н-85 без изменения файлов;
дальнейшие записи используют заранее предписанные абсолютные пути этой копии.
Это наблюдение процесса передаётся через сдаточный лист; общий журнал main
не меняется и номер А-NNN в wip не выдаётся.

## Исправление Crit170V4, К-14 на базе 1b811cea97d71ef416271083212ed46b541ead93

Обещание: приёмка принимает разрешённое системное пояснение после
канонического префикса отказа, сохраняя rc 1 и пустой stdout.
Существующее: `pinned.refusal` уже проверяет первую строку префиксом;
`probe.invoke` — бинарный публичный шов; READER/pointer — единый канон.
Frozen-обязательства, production, текст контракта и READER не меняются.

### Полная сверка stderr-сравнений

Просмотрены все пять файлов задания, не только две строки из вердикта.
Номера «до» относятся к базе; «после» — к этой пачке.

| Место до → после | Было → стало | Основание контракта |
|---|---|---|
| pinned.py:131 → :142, producer loop | весь список stderr равен единственной строке unavailable → `refusal(result, 'unavailable')`: rc 1, пустой stdout, непустой stderr, первая строка startswith каноническим префиксом | :29 «системное пояснение допустимо после префикса» |
| pinned.py:199 → :210, reader loop | то же точное равенство списка → `refusal(checked, 'unavailable')` | :31 первая строка `ОТКАЗ: ARCH_BRIEF_PIN:`; :29 именует unavailable; :27 канон READER не меняется |
| pinned.py:45–47 → :49–53, общий refusal | уже prefix, не точное равенство → сохранён prefix, добавлен необязательный именованный reason для двух loop-проверок | :29/:31 отказ до любых stdout-байтов, первая строка, не весь stderr |
| probe.py:194–202 | уже rc 1, пустой stdout и startswith для ARCH_COMPONENT_NET/ID, ARCHITECTURE_NET, ARCH_BRIEF_OTKAZ; сравнения всего stderr нет → без изменения предикатов | :17 отдельная первая строка ARCH_COMPONENT_NET и подсказка; :19 именованные отказы; :41 ARCHITECTURE_NET; :42 ARCH_BRIEF_OTKAZ с worker.events |
| pinned_model.py | проверок stderr равенством нет; только генерация и передача именованного отказа → без изменения | :27 канон команды; :29 имена причин и допустимое пояснение |
| npm_stub.py | сравнений stderr нет, только генерация stderr npm → без изменения | :19/:42 отказ npm, включая частичный stdout перед rc 17 |
| regressions.py | сравнений stderr нет → без изменения | прежние утверждения 095/169 остаются в своих батареях |

Точных отказных stderr-сравнений, требуемых контрактом и подлежащих
сохранению, в этих файлах нет. `not read.stderr` (pinned.py:175 → :186)
относится к УСПЕШНОМУ чтению, не к отказу: оно не менялось. Проверки
потолка используют startswith и число 40000, не равенство stderr.
Точные строки pointer/READ_REQUIRED и байты полного брифа не ослаблены.

### Различающий контроль и стабы

Две новые explained-клетки воспроизводят самоссылку по hash-пути
45000-байтного брифа. `refusal_output.py` исполняет реальный producer
либо настоящий argv READ_COMMAND и только для уже наблюдённого rc 1,
пустого stdout и первой строки unavailable дописывает `: symbolic link loop`.
Он не синтезирует именованный отказ из traceback или иной ошибки,
не изменяет каноническую READ_COMMAND и не перечитывает диск как оракул.

Перед заменой точных сравнений новые входы на старом предикате дали:

```text
170 brief_pin_symlink_loop_explained KRASNO rc=1 stderr='ОТКАЗ: ARCH_BRIEF_PIN: unavailable: symbolic link loop'
170 brief_read_symlink_loop_explained KRASNO rc=0 stderr=''
170 PIN_CONTROL_INVALID
rc=2
```

После исправления:

```text
170 brief_pin_symlink_loop_explained ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_PIN: unavailable: symbolic link loop'
170 brief_read_symlink_loop_explained ok rc=0 stderr=''
170 STAB exact_producer_refusal caught @ brief_pin_symlink_loop_explained
170 STAB exact_reader_refusal caught @ brief_read_symlink_loop_explained
```

rc 0 в read-строке — rc producer; внутри отдельно проверяется чтец.
`CHECKER_MUTANTS` меняет reason-specific startswith на точное равенство
в одноразовой копии проверяющего: честная модель с пояснением становится
красной на каждой из двух ветвей, а тот же отказ без пояснения остаётся
зелёным на этом же мутанте (обязательный соседний контроль).
Общий префикс без reason не мутируется. Отдельные subject-envelope мутации
меняют rc на 17, добавляют stdout, убирают префикс, очищают stderr либо
ставят traceback первой строкой. Каждое предъявление поймано отдельно;
прежний unchecked_issue с rc 0 также остаётся пойманным.
Привязки входов — только код MUTANTS/CHECKER_MUTANTS (Н-39).

Состав по AST деклараций базы/current: клетки 52 → 54, предъявления
стабов 43 → 55, уникальные имена 32 → 39. Независимый счёт stdout:
`--model` 54 ok, `--stabs` 55 caught, ZHIV 0.

`--repo` rc 1: 27 ok, 27 KRASNO — прежние 25 плюс две explained-клетки.
Полный список красных:

```text
brief_pinned_over_budget
brief_pinned_plain
brief_pinned_multi
brief_pin_missing
brief_pin_tampered
brief_pin_unreadable
brief_pin_checkout
brief_pin_git
brief_read_missing
brief_read_tampered
brief_read_same_size
brief_no_slice
brief_aggregate_budget
brief_mixed_small_inline
brief_pinned_spaces
brief_pinned_external_symlink
brief_read_length_pin
brief_read_checkout
brief_stderr_pinned
brief_stderr_pinned_plain
brief_stderr_inline
brief_stderr_inline_plain
brief_pin_symlink_loop
brief_read_symlink_loop
brief_inline_crlf
brief_pin_symlink_loop_explained
brief_read_symlink_loop_explained
```

Команды (cwd — корень изолированной копии,
`TMPDIR="$PWD/.scratch-170e" PYTHONDONTWRITEBYTECODE=1`):

```text
bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo "$PWD"
rc=1
bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model
rc=0
bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs
rc=0
python3 fixtures/workshop_project/arch_component_170/regressions.py
095 red_pravila_proekta_ne_harsa rc=0 (scratch relocated only)
169 red_model_trace_169 --model rc=0 (scratch relocated only)
rc=0
```

Полный сырой stdout/stderr и счёт: `.scratch-170e/repo.log`, `model.log`,
`stabs.log`, `regressions.log`, `summary.json`; временный драйвер не входит
в пачку. Прямые исторические shell-команды не запускались: прежний адаптер
переносит только scratch внутрь разрешённой изоляции.

Архивный FAIL: `f32bef47eea4820d6dc86d7dcfa0cea314bdec4a:verdicts/critic/contracts-170-v2.md`,
ветка `archive/170/critic-v2-fail2-f32bef47ee`. Ограничение HEAD-only двери
и рефлексия процесса записаны в SDACHA.md; общий журнал main вне зоны.

### Зависимый регресс времени двери

Первый check_sdacha дал rc 0, но прямой pre_critic и один его вложенный
прогон отказали. Диагностическая обёртка сохраняла stdout/stderr
check_spec_ready через tee с исходным PIPESTATUS, не меняя argv/проверки.
Снятая причина: `спек-гейт 036: проба превысила таймаут` (rc 1).
Это не выдаётся за дефект продукта и не маскируется повтором до зелёного.
Доступно 16 CPU (`nproc`); существующий пул независимых fixture-миров
увеличен с четырёх до шести процессов. Набор клеток, стабы, предикаты,
60-секундный лимит двери и её ожидаемые rc не меняются.

После изменения расписания выполнена вся заданная серия без BASH_ENV,
SDACHA_OKRUG или изменения лимитов. Итог: --repo rc 1 (27 ok / 27 KRASNO),
--model rc 0 (54 ok), --stabs rc 0 (55 caught / ZHIV 0),
regressions.py rc 0. Дополнительные две ok-строки в --stabs — честные
соседи exact-checker-мутантов, не новые клетки CASES.

```text
$ bash scripts/check_sdacha.sh . contracts/170-arch-component-brief-vhod-zadanija.md --run
СДАЧА: лист зелёный (двери=3 карта=17/17 дельта=1)
rc=0
$ bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md
КРИТИК: дверь зелёная
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
rc=0
```

Полные финальные логи: `.scratch-170e/stabs-final.log`,
`sdacha-final.log`, `pre-critic-final.log`; первые четыре прогона —
`repo.log`, `model.log`, `stabs.log`, `regressions.log`, счёт — `summary.json`.
Ранее пойманный таймаут не скрыт: его диагностический вывод сохранён
в `spec-ready-observed.log`. Временные драйверы и диагностическая обёртка
удалены, в коммит не входят.
