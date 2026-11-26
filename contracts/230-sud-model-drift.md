# Контракт 230 — судейская трасса: однозначный источник и ни одного потерянного model_change

СТАТУС: ЧЕРНОВИК; critic → freeze → implementer → adversary → reviewer → land → done.
КЛАСС ЗАДАЧИ: кодовый — ремонт существующего производителя свидетельства; production этой architect-пачкой не меняется.
КЛАСС РИСКА: рисковый — безопасность суда: потерянный недопущенный модель-факт материализует неподтверждённое доказательство.
ПРОДУКТ: станция
АРХИТЕКТУРА: не применимо — станционный механизм, продуктовой модели 188 нет.
КОНТЕКСТ: сообщение консультанта m2477 25.11 22:40 UTC: Adversary173Impl начал на Terra, model_change в 21:02:08 перевёл его на GLM (resolvedModelIsFallback:true), 139 из 176 ходов и ACCEPT — на GLM; два одноимённых файла сессии 23.11/25.11 скрыли неоднозначность. Это переданное измерение, не повтор платного запроса. Затравка владельца и /tmp/dev-harness-verify/task-architect230.md — источники задачи; Н-запись этого свежего события отсутствует в main-журнале базы.
КОНТЕКСТ: обещание — существующий путь JSONL → models_actual → check_sud_model → judge_gate не теряет недопущенную смену модели и не выдаёт несколько сессий за одну. Наблюдение — rc, точные байты TSV и append-журнала настоящего писателя на настоящем Git-OBJECT. 222/198/173/104 сохраняют модельную сверку; 174 меняется только в разрешении неоднозначности, указанном ниже. R-0102: назначение и fallback только из config/agent_models.json через существующий resolver.
СДАЧА: fixtures/workshop_project/sud_model_drift_230/SDACHA.md

## Предмет

Один результат: свидетельство модели судьи либо относится к единственному выбранному JSONL и несёт все его model_change, либо отказывает до выдачи пригодной TSV-трассы. Старые назначенные модели, роли и цепочки не меняются. Сверка каждого факта и запрет append после отказа УЖЕ реализованы 222/104: второй список моделей и вторая дверь не нужны.

## Существующее

База fcaff8bf2bc602bbe1fac7a6b7b507d84cc93041 получена fetch main; номер id/CONTRACT/230 и строка registry/plan.tsv:230 уже существуют. Имя затравки сохранено.

- scripts/models_actual.sh:107–114 возвращает все буквальные basename-совпадения; :127–129/:200–202 принимают любое непустое множество. Это не молчаливый выбор ровно первого в TSV: producer реально объединяет файлы. :154 regexp пропускает валидные JSON-варианты с пробелами, другим порядком ключей или вложенным runtime; битый хвост после хорошего события также может исчезнуть. Это тот же отказ свидетельства: модель-факт не дошла до сверки.
- scripts/check_sud_model.sh:343–438 уже проверяет каждую строку роли: session, OBJECT, allowed с назначением и denied с fallback. scripts/judge_gate.sh:126–139 вызывает её до append и пробрасывает rc. Обе двери остаются БЕЗ production-правки; батарея зовёт их настоящие, а не макеты. Отдельной реализации крючка (а) в check_sud_model не требуется: нужно не потерять вход крючка.
- scripts/roles.ts — единый readAgentModels/resolveRoleModel/resolveModelRef, --resolve-model/--resolve-selector; config/agent_models.json — единственный источник. Любое явное назначение 222 остаётся допустимым, denied вне fallback не становится разрешённым от того, что модель вообще объявлена.
- Данные затравки о живой цепочке устарели: в этой базе apex-sol.autoFallback=false (owner R-0120, edb1389ca), advisor.autoFallback=false; .omp/config.yml больше НЕ несёт apex-sol в fallbackChains. Общий primary Terra и разные fallback остаются. Историческая причина не выдаётся за проверенный текущий путь исполнения omp; правка назначений/autoFallback/генератора вне предмета.
- Frozen 222/1 (done 222/1), 198/1, 173/1, 104/2 сверены живым git show frozen/contracts/N/v^{commit}:contracts/…: зоны и назначение/per-call, bare/full, session/OBJECT, fallback и отказ до append сохраняются. Их production-файлы только потребляются. 166/2 сохраняет отсутствие семейного запрета и свободу назначения; совпадение модели автора/судьи не идентичность.
- Frozen 028/3 и 095/1: внешний HOME-источник, прежний human-отчёт без отбора, три поля TSV сохраняются. Frozen 104/2: bind — те же три поля плюс basename/OBJECT, не новый формат. Frozen 174/1 явно разрешает несколько совпавших файлов в mtime-порядке: эта единственная фраза ЗАМЕНЯЕТСЯ fail-closed 230 по прямому поручению владельца о неоднозначной сессии; отбор до разбора, буквальность, invalid-ID и отсутствие fallback к последней остаются. Старые клетки 174 не перепиниваются.
- Frozen 215/1 владеет тем же producer, но его проекция квитанции CONTENT_FALLBACK_SWITCH ещё отсутствует в базе. 230 не откатывает будущую реализацию: при последовательной посадке сохраняется парная id/target-сверка 215; native true всегда denied. Runtime/HTTP-переход 215 — не наша зона, его trace-регресс указан отдельно.
- fixtures/workshop_project/lyubaja_model_222/ и models_actual_174/ уже дают публичные швы; новая семья добавляет именно неоднозначный источник и полный поток событий. Reference материализует настоящие check_sud_model/judge_gate из неизменяемого BASE-предка, resolver — из кандидата; model/models_actual.py показывает достижимость ремонта, НЕ заменяет production целиком и НЕ обещает весь legacy human-формат. Старые семьи остаются ловцами неизменённых свойств.
- Поиск contracts/, registry/plan.tsv, scripts/, fixtures/, локальных wip/230 и gh pr list --repo a3ka/dev-harness: готового SESSION_AMBIGUOUS нет; ветки orchestrator-a1/a2 несут только затравку/план, открытые #1427/#1302/#1284/#1227 этот producer не реализуют. NABLIUDENIA.md Н-50/Н-91/Н-388 фиксируют боль восстановления моделей/квот, не механизм однозначного свидетеля; А-943 — уже измеренное смещение модели судьи на fallback. context.py читает живые высшие frozen-блобы и выводит пересечения, не доверяет текущей прозе прежних контрактов.

## Frontier

А — ВЫБРАН: отказ при нескольких точных basename до разбора/вывода; существующая сверка каждой строки ловит любой недопущенный model_change. Закрывает измеренное смешение без нового идентификатора и без изменения всех потребителей --session.
Б — полный путь/дата в session-id: отклонён; меняет пятиколоночную грамматику 104, двери и задания ради уже различимого отказа, дата не удостоверяет источник.
В — parentSession/start-метка: отклонён; требует нового авторитетного назначения и миграции legacy JSONL, не разрешает два подлинных одноимённых запуска сама по себе. mtime/первый/последний файл не идентичность.

## Инварианты

И1. --session ID во всех существующих режимах (human, --all, --tsv, --bind) сначала буквально отбирает basename без .jsonl. Нет совпадения — прежний rc 2 «сессия не найдена»; несколько — rc 2 `SESSION_AMBIGUOUS`, stderr называет ID и ВСЕ совпавшие пути, stdout пуст. Порядок дат, mtime, полярность модели и одинаковость содержимого не снимают неоднозначность. --bind без --session также отказывает при повторном basename в выбранном множестве. Неотобранные файлы при --session не мешают, как в 174.

И2. ID остаётся непустым ASCII `[A-Za-z0-9._-]+`, без TAB/LF/пробела/слеша/двоеточия/Unicode: прежний rc 2 «session-id вне алфавита». Сравнение литеральное: ведущие нули, длина и цифры — данные, не числовая координата или усечённый ключ. Неконформный аргумент не заменяется путём/регулярным выражением. Никакой даты/номера контракта не парсится из имени.

И3. В TSV выбранного файла каждый model_change даёт отдельную строку в исходном порядке, включая возвращение к primary после запрещённого fallback. JSON разбирается стандартным JSON parser, не regexp по сериализации: пробелы, перестановка ключей и добавочный вложенный runtime эквивалентны. Пустой/без model_change JSONL — rc 2 `TRACE_EMPTY`; битый JSON или model_change без непустого model / с неboolean resolvedModelIsFallback — rc 2 `TRACE_INVALID`, stdout пуст, в том числе после хорошей строки. Нет частичного пригодного свидетельства. Неизвестные поля не меняют решение; native false/true остаются allowed/denied.

И4. Первые три TAB-поля — роль, фактический selector, allowed|denied; bind добавляет basename и OBJECT либо `-` из задания. Selector ASCII `[A-Za-z0-9._/@:-]+`; effort/route — часть значения. OBJECT — самостоятельная `OBJECT=` + 40 lowercase hex строка, как в 104. Значения не переиспользуют TAB/LF как разделитель. Все сравнения untrusted-untrusted буквальные с принятой 173 bare/full-эквивалентностью только для модели. Формат 3/5 не расширяется.

И5. Каждый allowed-факт сверяется с назначением роли либо объявленным per-call selector; каждый denied — с fallback роли через resolver 198, НЕ с любым selector из models и НЕ с общим владельцем Terra. Denied на объявленном fallback разрешён и при autoFallback=false, как в 222; denied вне него — прежний rc 1 «фолбэк вне списка тира». Любой неверный allowed — rc 1 «вердикт не материализуется». До/после/между хорошими событиями неверный факт не скрывается. Отказ не добавляет verdict-строки; честный след даёт ровно одну строку настоящего judge_gate. Явное назначение переносится из запроса до запуска, не из факта.

И6. Не меняются назначения, цепочки, resolver, роли, single-uid доверенная граница, legacy HOME/human без --session, пропуск невыбранных файлов и свойства 222/198/173/104/174. Реализация дорабатывает producer в текущем дереве, а не копирует reference поверх более нового 215. Новые симптомы вне этих инвариантов — отдельный предмет.

## Батарея и демаркация

W = `bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh`; полные команды лежат в SDACHA.md. Швы заданы поручением: настоящие CLI producer/door/writer, реальные датированные файловые миры, JSONL и настоящий Git-OBJECT. Все ожидания/байты исходного журнала снимаются в родительскую память ДО субъекта; диск после вызова — только наблюдаемый результат, не источник ожиданий. Полный TSV и полные байты сохранённого/дополненного журнала сравниваются побайтно. При ошибке producer писатель не вызывается — пригодное свидетельство не получено.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. source.json/stabs/ — исполняемый реестр изменений; каждая связь выполняется отдельно, честный контроль до мутаций обязателен. Негодный pin/якорь/синтаксис/зависимость/таймаут — rc 2 NOT_IMPLEMENTED, не поимка. Непустой каталог с уникальными именами и адресными предъявлениями обязателен; чисел клеток/связей как второго реестра в этом контракте нет.

Конформен существующий CLI с JSONL-объектами session/message/model_change и указанными алфавитами; допускаются стандартные JSON-эквиваленты сериализации. Неконформный ID и битые события — явно отрицательные входы, не расширение грамматики. Контрпример валиден, если инвариантен к конкретным версиям selector, именам/датам каталогов и Git SHA и расходится на таком входе. Произвольное распознавание конечной фикстуры не объявляется доказательством всех программ.

## Приёмочный критерий

- Дано до-230 дерево; когда `W --repo .`; тогда rc 1 с самостоятельными KRASNO; исходный список — сдаточный лист. После реализации та же команда rc 0, KRASNYH=0. Здоровые, denied/per-call и ошибочные контроли не отключаются.
- Правило достижимости: `W --model` — rc 0; правило различимости: `W --stabs` — rc 0, ZHIVYH=0, каждая адресная связь предъявлена. Негативная пара — исполняемый каталог мутаций, не синтаксически сломанные программы.
- Правило формы: `W --sintaksis` (Python ast; bash -n и pinned shellcheck через validate_std) и `W --catalog` — каждый rc 0; `python3 fixtures/workshop_project/sud_model_drift_230/context.py` — rc 0, непустые живые frozen-пересечения.
- Правило допуска: `bash scripts/pre_critic.sh contracts/230-sud-model-drift.md` и `bash scripts/check_sdacha.sh . contracts/230-sud-model-drift.md --run` — каждый rc 0; бюджет из ENV/профиля, повтор после timeout только изолированно с замером uptime. В этом main строка плана уже есть.
- Правило совместимости после реализации: `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --repo .`, `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --repo .`, `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh`, `bash fixtures/_krasnye_104.sh`, `python3 fixtures/workshop_project/sud_model_drift_230/fork_regress.py` и `bash fixtures/workshop_project/models_actual_174/red_session_174.sh --repo` — каждая rc 0. Их отрицательные пары остаются в собственных семействах; fork_regress.py запускает каждый существующий red_*.sh без своего оракула. Для 222/198 дополнительно --model и --stabs, для 173 дополнительно --model/--stabs — каждая rc 0.
- Дано приземлённая реализация 215; когда `bash fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh --repo . --case trace`; тогда rc 0. До неё именованное красное этой старой семьи не правится 230. До done orchestrator: `bash scripts/check_provodka.sh . contracts/230-sud-model-drift.md`, `bash scripts/gen_ci_steps.sh --check` — rc 0 после подключения собственного шага; если объявлен sourceCanon — также штатный source-гейт done.

## Модель угроз

ЗАЩИЩАЕТ:
- От смешения одноимённых источников и потери промежуточной недопущенной модели: fail-closed producer и прежняя сверка каждой строки до append, включая JSON-эквивалентные записи.
- От молчаливого пропуска битого/пустого свидетельства и выбора по mtime/подстроке/усечению: именованный отказ без stdout, буквальный basename и полные байты результата.

НЕ ЗАЩИЩАЕТ:
- От подделки доверенной зоны JSONL/TSV, удаления события самим владельцем зоны или ложного назначения оркестратором: ловцы прежние 028/104/222, изоляция и независимый суд. Произвольный вручную переданный TSV не удостоверяет однозначность исходного JSONL.
- От дефектов самого переключателя omp, доступности провайдера/квоты и ложного содержания accept: ловцы 129/215 и суд; новые платные вызовы, изменение модели или риска не входят.
- От подмены PATH/инструментов/памяти при одном uid и программ, специально распознающих конечный каталог: доверенная среда прежняя; ловцы CI, adversary/reviewer. Reference не разрешает откат старых обязательств.

## Зоны и проводка

ЗОНА architect: contracts/230-sud-model-drift.md fixtures/workshop_project/sud_model_drift_230/
ЗОНА implementer: scripts/models_actual.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 028 только однозначный отбор и полнота событий; HOME/обычный human остаются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 095 только однозначность и полнота; трёхполевая проекция остаётся.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 104 только producer; bind/session/OBJECT и отказ до append остаются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 174 только замена разрешённого смешения на SESSION_AMBIGUOUS; прочий CLI/отбор/алфавит остаются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 215 только producer; квитанция id/target/reason и native статус сохраняются при последовательной интеграции.
ПЕРЕСЕЧЕНИЕ architect: contracts/230-sud-model-drift.md — 993 только новый предмет.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/sud_model_drift_230/ — 054 только новая семья.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/sud_model_drift_230/ — 055 только новая семья.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 230.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 230.

ПРЕДПОСЫЛКИ:
- setting Существующие git/bash/python3/node/jq, пинованный shellcheck и доступный BASE на origin; новых secrets, variables, environments или настроек репозитория нет.
- setting Свой шаг check:sud-model-drift-230-family-selftest и замер вносит orchestrator: до реализации --model/--stabs/--sintaksis/--catalog, после также --repo .; gen_ci_steps.sh --write и --check. Чужие шаги не меняются.

ПРОВОДКА:
- guard=fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh

ПРОВОДКА-ЭНФОРСМЕНТ: уточняется механическая пригодность свидетельства существующего producer; новых поведенческих норм роли нет. check_sud_model/judge_gate уже потребляют результат и не требуют второго enforcement. Батарею потребляет свой CI-шаг orchestrator; до его подключения done-проводка не объявляется зелёной.

## Незаполненные требования:
нет
