# Контракт 209 — засев архива трассы нового проекта из трассы станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — безопасность допуска ролей: make_task требует свидетельство до выдачи пака, включая паки судей. Засев разрешает этот bootstrap, но не свидетельствует о фактической сессии судьи; реализация проходит adversary → reviewer. Это повышение против оценки затравки, не ослабление 104.
КОНТЕКСТ: слово владельца 22.11 о штатном засеве нового проекта из трассы станции; номер выдан механизмом id/CONTRACT/209 и строкой registry/contracts.tsv. Основание — затравка owner b4a39c229f9e31b827e7348bece1f3bf8d4ef7a7 и разбор inbox-STANCIJA-TRACE-BOOT-0100.txt из задания. Разовое копирование трассы back в Complior-agent не становится механизмом или разрешением фальсифицировать запуск.
СДАЧА: fixtures/workshop_project/zasev_trassy_209/SDACHA.md

## Боль и обещание

На новом Complior-agent команда make_task с ролью architect и контрактом 137 отказала «ОТКАЗ: свидетельство не той роли: architect» (наблюдение владельца, не повторяется для подтверждения). prepare_model_trace строит HARNESS_MODEL_TRACE из JSONL дома проекта; запусков нет, архив пуст. Строка нужна для первого запуска, а появляется только после него.

Один результат: новый проект получает пригодный для make_task архив назначения из фактической трассы станции, честно отличимый от фактов проекта. Наблюдение результата — настоящий workshop с единственным транспортным стабом omp, затем настоящие make_task, models_actual --bind и check_sud_model --verdict. Статика не выдаётся за факт запуска: происхождение строки доказывается расходящимися станционным JSONL и подложным TSV, а замена — новой JSONL-сессией проекта.

## Существующее

Сверка выполнена на owner-базе b4a39c229f9e31b827e7348bece1f3bf8d4ef7a7; workshop этой базы побайтно совпал с frozen/contracts/204/1. Последний служит неизменным контролем старого вывода, не реализацией bootstrap. Зоны сверяются с живыми frozen-блобами; рабочий HANDOFF содержит более старый срез, чем дерево, и не подменяет его.

- workshop уже вычисляет станционную ZONE до подмены HOME, экспортирует HARNESS_SESSION_HOME, а проекту назначает отдельный PSTATE/home. prepare_model_trace собирает архив на каждом живом старте, исключает orchestrator, оставляет первую строку роли, ставит mode 600 и заменяет файл rename. --probe заканчивается раньше этой функции: приёмка проходит живую ветку до exec omp, не probe-двойник.
- models_actual.sh уже читает только JSONL разрешённой зоны: --tsv даёт три поля, --bind добавляет session/object, --session буквально отбирает basename. Расширение session-trace.ts сохраняет архивные строки и дописывает только текущую живую строку orchestrator. Эти производитель и расширение не меняются.
- 095 задаёт трёхполевую трассу и отказ при отсутствии роли; 169 различает явный путь TSV и проектный fallback; 136/996 разрешают профильные пути. make_task остаётся прежним: новый формат в него не внедряется. Обязательства TASK, frozen-стадии, автора critic/reviewer и специализации implementer-glm сохраняются.
- 104, решения 2–5: --sud получает только пяти-полевую трассу реальной сессии с session/object; check_sud_model отказывает трём полям rc 2 «трасса без привязки». 166 отменяет сравнение модели судьи с автором, но не сверку фактической модели с назначением. 209 не восстанавливает семейный запрет и не ослабляет привязку.
- config/agent_models.json уже несёт словарь roles. Для фильтра засева нужны только его ключи, не собственный разбор цепочки roles→tiers→models. Модель и allowed/denied копируются из трассы, а не генерируются по конфигу; резолвер 198 и назначения владельца не меняются.
- Семьи context_pack_095 и modeli_tolko_v_reestre_198 уже дают одноразовый git-проект и копирование реальной цепочки launcher/scripts/roles/config/.omp с транспортным стабом omp. Новая семья переиспользует эти швы; никакая сессия модели, сеть или секрет станции для неё не нужны.

## Frontier

1. Фальшивые JSONL первого запуска отвергнуты: они превратят назначение в факт и позволят лживую --bind-трассу.
2. Четвёртое поле seed в основном TSV отвергнуто: read r m fb сборщика 095 принимает ровно три поля; четвёртое меняет fb и ломает грамматику.
3. Выбран трёхполевой архив плюс отдельная метка засеянных строк. Это единственная добавленная часть состояния; существующие потребители и форматы неизменны. Засев сохраняется до замены по роли, а не исчезает после первого запуска любой другой роли.

## Предмет и инварианты

- И1 — bootstrap. В режиме проекта, если JSONL-проекция проекта пуста, нет прежней непустой метки и нет непустого собственного архива без метки, prepare_model_trace засевает архив из models_actual --tsv станционной ZONE, вычисленной лаунчером до подмены HOME. Используется прежняя проекция: ровно три TAB-поля, непустая роль, не orchestrator, первая строка каждой роли. Из неё оставляются только ключи roles реестра установки. Значения модели и allowed/denied сохраняются побайтно.
- И2 — явная метка. HARNESS_MODEL_TRACE остаётся runtime/model-trace.tsv. HARNESS_MODEL_TRACE_SEED указывает соседний runtime/model-trace.seed.tsv; он содержит только ещё не вытесненные засеянные строки в той же трёхполевой грамматике. Роль присутствует в метке — её строка архива есть ЗАСЕВ, а не факт проекта. Оба файла имеют mode 600. Засев не создаёт JSONL, session-id или OBJECT.
- И3 — вытеснение. Фактические строки проекта идут первыми; строки этих ролей удаляются из метки. Архив — фактические строки плюс оставшийся засев; каждая роль встречается один раз. Роли без собственного запуска сохраняют засев. Пустой первый вход фильтра не должен уничтожать метку при повторном старте без запусков.
- И4 — непустое не засевается. При наличии фактических строк и отсутствии старой метки архив состоит только из этих строк: новые роли станции не добавляются. При отсутствии фактов, но существующем непустом архиве без метки, его байты сохраняются; метка задним числом не изобретается. Приоритет свежей фактической строки И3 сохраняется.
- И5 — реестр. Строка роли вне config/agent_models.json.roles не попадает ни в архив засева, ни в метку; stderr несёт самостоятельную строку TRACE_SEED_ROLE_UNKNOWN: <роль>. Остальные разрешённые строки не теряются. make_task для неизвестной роли по-прежнему отказывает rc 1 «ОТКАЗ: роль вне алфавита: <роль>».
- И6 — источник без произвольного пути. bootstrapTrace в репо-слое harness.project.json отсутствует либо равен JSON-строке station. Отсутствие означает station; любой иной тип или значение, включая путь файла, даёт rc 1 «ОТКАЗ: TRACE_SEED_SOURCE_INVALID: bootstrapTrace должен быть station», до exec omp и без публикации засева. Это замкнутый выбор authority, не файловый override. Единственный источник данных — живой models_actual зоны станции, не её производный model-trace.tsv и не конфиг назначения. Конфиг разбирается jq, не самописным JSON-парсером.
- И7 — независимость факта. models_actual --bind проекта не читает метку/архив и не выдаёт засев за факт сессии. Трёхполевая засеянная строка, переданная в проверку --sud, даёт прежний именованный отказ check_sud_model rc 2 без привязки. Честная JSONL с правильными ролью, моделью, session и OBJECT остаётся зелёной. Засев не является разрешением зарегистрировать вердикт без этой проверки.
- И8 — идемпотентность и старый вход. Повтор без новых фактов не меняет байты архива/метки и не дублирует роли. Дев-вход без проекта не засевается и метку не создаёт; прежний архив и полный stdout/stderr сохраняются. Грамматика 095, --bind/--session 104/174, пути 028/996, выбор модели 166/198 и live-orchestrator 105 не изменяются.

## Модель угроз

ЗАЩИЩАЕТ:
- от bootstrap-тупика нового проекта, потери оставшихся ролей при первом собственном запуске и засевания поверх непустого архива;
- от выдачи засева за факт проекта или привязанный суд: реальные CLI наблюдают отсутствие JSONL, именованный отказ и честный положительный контроль;
- от неподтверждённого источника в виде произвольного TSV, файлового значения bootstrapTrace и роли вне станционного реестра;
- от плацебо сравнения: rc, полный stdout и полный stderr сравниваются байтами; ожидаемые строки/артефакты сняты в память до вызова соответствующего субъекта, якорь каждой мутации имеет кратность один.

НЕ ЗАЩИЩАЕТ:
- компрометацию доверенной ZONE, JSONL или установки станции до запуска лаунчера: граница 028/095/104; ловцы владелец установки и adversary/reviewer по происхождению данных, это не криптографическая аттестация станции;
- назначение или наличие станционного запуска каждой будущей роли: роль без станционной строки не выдумывается; ловец make_task с прежним отказом отсутствующего свидетельства, решение о первом станционном запуске принимает orchestrator;
- подмену метки/архива доверенным оркестратором после подготовки либо одновременную запись в эти файлы мимо существующего лаунчера/session-trace: ловцы 095/104 и reviewer; новая блокировка конкурентных writers не вводится;
- правдивость живого запроса модели и самого вердикта: проверка 104 привязки и действующие суды остаются ловцами; конечная батарея не доказывает отсутствие сговора субъекта и теста, ловец независимый adversary/reviewer.

Конформный вход — существующая установка и корректные профиль/реестр, JSONL грамматики models_actual, допустимые роли и модели трассы 095; bootstrapTrace имеет замкнутый алфавит {отсутствие, station}. TAB/LF — разделители, не байты поля. Пути и роли сравниваются буквально, поля JSON не разбираются регулярным выражением. Неконформные значения bootstrapTrace — явные отрицательные предъявления, а не контрпримеры к зелёному сценарию. Валидный контрпример различает честную модель и предметную мутацию на поддерживаемом входе независимо от конкретных модельных ID. Отсутствующая зависимость/субъект, неверный якорь, сломанный синтаксис или нулевая выборка — rc 2 NOT_IMPLEMENTED/ORACLE_TAMPERED, не поимка стаба.

## Приёмка

W — bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh. --repo ROOT копирует реальную цепочку выбранного дерева без исправления субъекта; --model подставляет только функцию из исполняемого канона в frozen workshop; --stabs сначала предъявляет честный контроль, затем адресные мутации. Стабы привязывает код probe.py и stabs.tsv, не проза контракта. Миры — одноразовые репозитории mktemp под TMPDIR; установка и станционная зона — соседние каталоги мира, поэтому guard 028 не требует записи вне разрешённого scratch и основной чекаут не изменяется.

1. Дано: production до реализации; когда: `bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh --repo .`; тогда: rc 1, именованные красные клетки свойств И1–И7. Это красное-до, а не машинный ряд листа, который должен менять rc после ремонта.
2. Дано: исполняемая модель; когда: `bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh --model`; тогда: rc 0, все клетки зелёные. Приёмка включает паки всех не-orchestrator ролей make_task, метку, собственный запуск, непустые фактический и сохранённый архивы, неизвестную роль, ложный файл источника, повтор, дев-вход и честный привязанный суд.
3. Дано: адресные стабы и их честные контроли; когда: `bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh --stabs`; тогда: rc 0 и ZHIVYH=0. Каждый стаб судится собственной привязкой, сломанная среда не засчитывается по произвольному ненулевому rc.
4. Правило границ: та же W --model обязана различать отсутствие/явную station, файловый путь, пустую строку, NUL, CRLF, регистр, null/array/object и не-UTF8; связанная проверка судей включает пустой, короткий/длинный, разнорегистровый hex и не-UTF8 OBJECT. Полные выводы прежней проверки 104 и rc совпадают с frozen-контролем; честная пяти-полевая трасса проходит.
5. Правило формы: `bash scripts/check_spec_ready.sh . contracts/209-zasev-trassy-proekta.md`; `bash scripts/check_ids.sh .`; `bash scripts/check_ceilings.sh`; `bash scripts/check_provodka.sh --grammar . contracts/209-zasev-trassy-proekta.md`; `bash scripts/check_precision_gate.sh . contracts/209-zasev-trassy-proekta.md`; `bash scripts/check_threat_model.sh . contracts/209-zasev-trassy-proekta.md`; `bash scripts/check_predposylki.sh . contracts/209-zasev-trassy-proekta.md` — каждая rc 0.
6. Правило сдачи: `bash scripts/check_sdacha.sh . contracts/209-zasev-trassy-proekta.md --run` → rc 0; `bash scripts/pre_critic.sh contracts/209-zasev-trassy-proekta.md` → rc 0; `bash scripts/gen_ci_steps.sh --check` → rc 0. Лист содержит стабильные --model/--stabs; суммарный бюджет листа 900 с. Имя первого вердикта critic — contracts-209-v1.md.
7. Дано: implementer перенёс семантику в существующий prepare_model_trace; когда: W --repo .; тогда: rc 0 и KRASNYE=0. Затем orchestrator подключает CI self-test с --repo ., --model, --stabs, фиксирует замер и выполняет gen_ci_steps --write/--check, последний rc 0; полный check_provodka до CI-строки честно красен «guard не подключён», после неё rc 0. Существующие CLI потребителей не меняются и не мигрируются на фиктивный факт.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/209-zasev-trassy-proekta.md fixtures/workshop_project/zasev_trassy_209/
ЗОНА implementer: workshop
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/zasev_trassy_209/ — 054 только новая семья, прежние фикстуры каталога не меняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/zasev_trassy_209/ — 055 только новая семья, прежние фикстуры каталога не меняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/zasev_trassy_209/ — 105 только новая семья, прежние фикстуры каталога не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 002 только prepare_model_trace; политика подтверждений не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 005 только prepare_model_trace; metering не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 010 только prepare_model_trace; топология ролей не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 028 только потребление готовой ZONE; канонизация и размещение HOME не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 030 только prepare_model_trace; инструменты и spawn не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 054 только prepare_model_trace; профильные отказы и probe не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 055 только prepare_model_trace; PSTATE, HOME, лок и metering не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 058 только prepare_model_trace; agent.db и симлинки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 060 только prepare_model_trace; workflow/tool roots не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 070 только prepare_model_trace; github token не читается засевом
ПЕРЕСЕЧЕНИЕ implementer: workshop — 105 только prepare_model_trace; политика расширений и раскладка ролей не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 125 только prepare_model_trace; сев несекретного конфига не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 198 только имена ролей из реестра; цепочка моделей и шов fable не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 996 только prepare_model_trace; маршруты проекта не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 193 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новый self-test 209, чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 193 только замер нового self-test 209, чужие замеры сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер нового self-test 209, чужие замеры сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 061 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 065 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 066 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 067 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 068 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 074 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 079 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 080 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 081 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 082 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 086 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 088 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 091 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 103 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 104 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 105 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 113 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 125 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация gen_ci_steps.sh нового self-test 209
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация gen_ci_steps.sh нового self-test 209

ПРЕДПОСЫЛКИ:
- setting Станция и CI предоставляют bash, Python 3, git с frozen/contracts/204/1, node для реальной цепочки генератора, jq, awk, sed и timeout. Новых secrets, variables, environments, настроек репозитория или внешней сети нет. TMPDIR — абсолютный доступный scratch; миры строятся по одному, удаляются при выходе.

Порядок: architect сдаёт контракт, канон, батарею и стабы одной пачкой → двери формы и листа → critic → freeze → implementer меняет только prepare_model_trace → orchestrator проводит self-test в CI и замер → adversary → reviewer → done. Переписывать модели фактических потребителей ради засева не требуется.

ПРОВОДКА:
- guard=fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh

ПРОВОДКА-ЭНФОРСМЕНТ: bootstrap — механика существующего свидетельства, поведенческой нормы роли не вводит. Единственный канал guard; self-test и замер коммитит orchestrator в окне freeze..done, производный ci.yml материализует gen_ci_steps.sh. До его подключения полный check_provodka ожидаемо красен; грамматика, pre_critic и сдаточный лист должны быть зелёными до платного суда.
