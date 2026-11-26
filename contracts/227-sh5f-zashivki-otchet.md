# Контракт 227 — Ш-5ф: остаток зашивок проектов в CI, только отчёт

СТАТУС: ЧЕРНОВИК — заменяет owner-затравку; production пишет implementer после critic/freeze.
КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — read-only отчёт; не меняет авторизацию, безопасность дверей, деньги, ПД/health/согласия, права БД или юридически значимые действия.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — станционный отчёт без продуктовой модели 188.
КОНТЕКСТ: R-0114 и R-0102 (25.11), задание /tmp/dev-harness-verify/task-architect227.md; FABLE-RECOMMENDATIONS-1121.md §Ш-5/Ш-5ф, PLAN-V9.md §1/§4, ADR docs/owner/adr/2026-11-21-plan-fable.md. Нового sourceCanon нет. Более поздний R-0114 задаёт последовательность потока ниже, а не прежний порядок v9.
СДАЧА: fixtures/workshop_project/zashivki_otchet_227/SDACHA.md

## Предмет

Один результат: штатный step CI печатает JSON-отчёт об оставшихся строках/файлах/совпадениях проектных зашивок и возвращает rc 0 при ЛЮБОМ остатке, в том числе пустом и превышающем исходную базу. Это не порог, не новая дверь-отказ и не автоматическое удаление зашивок. Мораторий соблюдён: Ш-5ф включается только отчётом. Ошибка инструмента/конфига не считается измеренным нулём.

Измеренная боль R-0114: 89 строк в 20 файлах на 6565542c1; незаметное возвращение литералов при ремонтах ядра (Fable: добавление .harness/registry/contracts.tsv). Шов: `bash scripts/report_zashivki.sh`, запущенный существующим CI runner из единственного registry/ci-steps.tsv. Результат наблюдается по rc и полным stdout/stderr; отчёт не пишет дерево, индекс или HEAD. Frozen-обязательства 083/087/114/038 сохраняются: существующая грамматика/генерация/lane/замеры/проводка; классификация CI и чужие команды не меняются.

Порядок: architect — контракт, честный контроль, адресная батарея и лист; critic → freeze → implementer (скрипт и конфиг) → orchestrator (CI) → reviewer → land → done. До production orchestrator подключает только model/stabs/sintaksis семейства. После production добавляет настоящий report-step и --repo . в selftest, материализует workflow существующим генератором. Оба веса/замера — обычные строки ci-zamery.tsv, не пороги остатка.

## Существующее

База fetch/switch main: 3be623a80eae14c63d960c7aaeff9c6bcd301fdd. Номер id/CONTRACT/227 уже выдан; обе строки registry/contracts.tsv и registry/plan.tsv существуют. Дерево новее верхнего «ГДЕ МЫ» HANDOFF (23.11); его очередь не выдаётся за актуальную. Активная наибольшая затравка в contracts — 230, вердиктов 230 в дереве нет.

- registry/ci-steps.tsv уже задаёт step/legkij/shard, scripts/gen_ci_steps.sh:106–125 разрешает только npm run либо bash-путь и генерирует JOBS/SHARDS. Поэтому inline git grep в строке CI не годится; нужен bash-фасад. scripts/run_ci_lane.sh — существующий потребитель команд; нового runner/YAML-парсера нет.
- registry/ci-zamery.tsv хранит ключ, вес, секунды, run-id (114); это стоимость CI, не база строк/файлов. Историческая база остатка хранится рядом с pattern/include/exclude в одном config/zashivki.json, не вторым реестром измерений CI.
- scripts/check_ci_gate.sh содержит legkij в выборе job и диагнозе; scripts/make_task.sh уже читает эффективный pack.maxBytes через резолвер, но сохраняет 40000 как fallback. scripts/profile_resolver.sh уже несёт SCHEMA_LEVELS и profile_get (М-0/184: неизвестный ключ — предупреждение). Отчёт 227 не меняет этот резолвер и не объявляет профильные ключи следующих ходов.
- 193 уже берёт sdacha.timeoutSec/budgetSec из профиля; повторный механизм бюджетов не нужен. 203 уже доставил бриф/кап/причины. 226 отдельно убирает проектную привязку архитектурной двери; новые scripts/report_zashivki.sh и config/zashivki.json с этими путями не пересекаются.
- 219 — классификация точных учётных путей, 221 — project-минт, 225 — очистка ops/server; ни один не печатает остаток. Их семьи/production не меняются. Общая тройка CI остаётся у orchestrator, по одному PR в полёте; 227 не правит чужие строки/веса.
- Поиск по contracts/, registry/plan.tsv, scripts/, fixtures/ не выявил готового отчёта. Удалённые wip/22* проверены git ls-remote: рядом 221/222/224, 225 и 226, ветви 227 нет. Открытые PR #1302/#1284/#1227/#797 — другие предметы, не реализация отчёта. Семьи 219/224 дают ту же форму probe/model/stabs/source/SDACHA; формат не переизобретается.
- `python3 -B fixtures/workshop_project/zashivki_otchet_227/context.py` живьём читает git show высших frozen/contracts/N/v^{commit}:contracts/<путь>, печатает реальные sha/ЗОНА и дедуплицированные пересечения ниже. Новые production-пути не затрагивают frozen 193/203/226; общие CI-пути затрагивают 083/087/114 и перечисленные старые зоны, не их поведение.
- Две отдельные реальные меры исходного grep на базе: git grep -n ... | wc -l = 89; git grep -l ... | wc -l = 20. Историческая база консультанта на этом дереве совпала, не пересоздана из вывода нового субъекта.

## Frontier

А — ВЫБРАНО: bash-фасад + один JSON config/ в существующей конвенции config/*.json; pattern/include/exclude/baseline — данные. Stdout — один JSON-объект со счётчиками и полным списком, пригодный для чтения логов и структурной сверки. Минимальный production — два файла; git grep остаётся настоящим инструментом.

Б — профиль harness.project.json: отклонено для этого отчёта ядра; потребуется новый ключ/слияние профиля ради глобального списка сканирования станции. Это лишняя связь с проектом; профильные точки расширения идут следующими отдельными предметами.

В — литералы в registry-команде, только человекочитаемый grep: отклонено — команда не начинается bash-путём 083, нарушает R-0102, не несёт отдельного числа файлов. Отдельный ledger базы также отклонён: те же данные уже принадлежат единственному конфигу отчёта. База не обновляется при каждом прогоне; монотонность потока наблюдается по последовательности отчётов CI, не превращается в отказ 227.

## Инварианты

1. Публичный CLI без аргументов — `bash scripts/report_zashivki.sh`. Корень — репозиторий расположения скрипта; конфиг — config/zashivki.json этого корня. Значения и список исключений не дублируются в production-коде или CI-команде. Канон начального конфига — model/config/zashivki.json семьи: pattern `Complior-(back|mob)|a3ka/Complior|complior-(back|mob)|\.harness/`, include scripts/.omp/extensions/.githooks тремя отдельными путями, exclude scripts/proxy, baseline lines=89/files=20/commit=6565542c1. JSON Schema семьи описывает данные; production не обязан вводить новый schema-гард.
2. Остаток — совпавшие СТРОКИ tracked рабочей копии по семантике настоящего `git grep -n -I -E -e <pattern> -- <include> <exclude>`. Include/exclude — буквальные относительные пути Git (файл либо поддерево), не shell/regex/glob; значения передаются argv, не исполняются. scripts/proxy2 не исключается вместе с scripts/proxy. Неотслеживаемые и бинарные файлы не считаются; комментарии считаются, как в исходной команде. Несколько совпадений на строке дают одну запись; одинаковое содержимое разных строк/файлов не склеивается. Dirty tracked читается из рабочего файла, не HEAD/index. Порядок — байтовый порядок путей Git, затем номер строки.
3. Stdout — ровно один JSON-объект (свободные пробелы, порядок ключей и JSON escaping допустимы): `{"lines":N,"files":M,"matches":[{"path":P,"line":L,"text":T}],"baseline":{"lines":B,"files":F,"commit":C}}`. N — число записей, M — число различных путей, L — 1-based номер, T — полная строка без завершающего LF, с сохранением пробелов/двоеточий/Unicode; P — полный путь относительно корня без git-quoting. Пусто: N=M=0 и matches=[]. Baseline переносится из конфига, не вычисляется из остатка и не является порогом.
4. На конформном входе rc 0 и пустой stderr при любом N/M: до базы, на базе, сверх базы и при нуле. Нет `! git grep`/остаток→отказ, нет переключателя enforce, нет выхода владельца YADRO_ZNAET_PROEKT в этом ходе. Недоступный инструмент/Git, нечитаемый/битый конфиг или невозможность закончить измерение — rc 2 с диагностикой NOT_IMPLEMENTED: в начале строки stderr и пустым stdout, а не отчёт с ложным нулём. Рабочий git grep с rc 1 «нет совпадений» остаётся успешным нулевым отчётом. Это операционная ошибка, не отказ по наличию зашивок.
5. Изменения pattern, include, exclude (в том числе пустого exclude) и baseline меняют соответствующее наблюдение. Не допускается проверка буквального равенства значений вместо их применения. Сам отчёт не меняет конфиг/файлы/index/HEAD.
6. В registry/ci-steps.tsv ровно один `step` с ключом report:zashivki-227 и командой `bash scripts/report_zashivki.sh` без подавления rc/обёртки no-op; вес по замеру 114. Одноимённая строка registry/ci-zamery.tsv существует, её вес совпадает. Workflow генерируется только gen_ci_steps.sh --write; --check возвращает 0. Отдельный check:zashivki-otchet-227-family-selftest запускает режимы батареи согласно фазе; сам report-step не становится тестом порога остатка.

## Батарея и демаркация

W = `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh`.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Единственный реестр операций/связей — build.py, source.json генерируется из него и несёт sha256 всех носителей. Каждая связь исполняется отдельно, честный контроль предварительно зелён. К-08: стабы изменяют существующие операции честной модели, а не только добавляют очевидные заглушки; отказ по непустому/пустому/сверхбазовому остатку, конфиг, вывод и CI-проводка имеют отдельные наблюдения. Эквивалентные вычисление числа файлов и формат JSON остаются зелёными.

Оракул — заранее заданные записи конструкторов настоящих Git-миров, снятые в память ДО субъекта; он не получает ожидаемые числа/строки из grep или модели. Git init/add/commit — настоящие; вывод JSON разбирается стандартным json, сравнивается целиком, обе трубы и rc наблюдаются отдельно; снимки файлов/index/HEAD сравниваются до/после. Синтаксис Bash/вложенного Python и хеши носителей проверяются до стаба. Недоступность инструментов проверяющего/синтаксис/пин/таймаут — rc 2 VERIFIER_UNAVAILABLE, не поимка. Любой rc субъекта на корректном входе, включая 2, — наблюдаемый результат клетки, не недоступность стенда. --repo использует реальные script/config/CI выбранного дерева, без достройки модели; отсутствие production — rc 1 SUBJECT_ABSENT.

Конформный вход измерения: доступный автономный Git с tracked рабочими UTF-8 текстами/именами и бинарными исключаемыми файлами, корректный конфиг схемы семьи, POSIX ERE Git, относительные include/exclude без NUL и компонентов ..; literal-пути могут содержать пробелы, TAB/LF, Unicode, двоеточия и метасимволы. Проба также покрывает отсутствующие сканируемые каталоги. Валидный контрпример = инвариантность к конкретным значениям/путям/числам ∧ расхождение на конформном входе измерения либо на отдельно заявленном сценарии отказа инструмента/чтения конфига (инвариант 4). Для отказа Git только процесс субъекта получает исполняемый git в PATH с rc 128; подготовка и снимки используют настоящий Git. Это имитация операционного отказа, не подмена оракула измерения. --model CI-мир прогоняет настоящий sibling gen_ci_steps --write, затем --check; --repo проверяет настоящий workflow выбранного дерева без записи.

## Приёмочный критерий

- Дано до-227 дерево; когда `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --repo .`; тогда rc 1 SUBJECT_ABSENT. Дано реализация и CI-проводка; та же команда — rc 0, KRASNYH 0, полный непустой каталог. Исторический красный прогон хранится в листе, не как нестабильная дверь листа.
- Правило честного контроля: `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --model` → rc 0. Непустой/пустой/исключённый остаток, обе границы базы, конфиг, tracked/dirty/untracked/binary, номера/полные строки, комментарии и буквальные сложные пути проходят тем же швом. Отдельные клетки отказавшего git grep, битого JSON и недоступного для чтения конфига требуют rc 2/NOT_IMPLEMENTED: без stdout; пустой остаток с рабочим Git требует rc 0 и нулевой JSON.
- Правило различимости: `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --stabs` → rc 0, ZHIVYH 0. Каждое адресное предъявление выполнено самостоятельно, честные эквиваленты зелены; нельзя засчитать синтаксическую ошибку или красноту другой клетки.
- Правило формы: `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --sintaksis` → rc 0 (bash -n всех носителей, compile Python без pycache, validate_std bash с пином shellcheck и JSON Schema). Нет инструмента — rc 2, не skip.
- Правило каталога/источников: `bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh --catalog` и `python3 -B fixtures/workshop_project/zashivki_otchet_227/context.py` → каждый rc 0, непустой каталог/сверка живых frozen. Числа берутся из вывода/листа, не дублируются реестром в контракте.
- Правило допуска: `bash scripts/pre_critic.sh contracts/227-sh5f-zashivki-otchet.md` и `bash scripts/check_sdacha.sh . contracts/227-sh5f-zashivki-otchet.md --run` → каждый rc 0.
- Правило done: после своей CI-проводки `bash scripts/gen_ci_steps.sh --check` и `bash scripts/check_provodka.sh . contracts/227-sh5f-zashivki-otchet.md` → каждый rc 0. До подключения guard полный check_provodka ожидаемо rc 1 «guard не подключён»; грамматика зелена. Вес/секунды orchestrator измеряет реальными командами, не выдаёт модельный ноль за production-замер.

## Не входит и следующие ходы потока

Реализуется ТОЛЬКО Ш-5ф report. Никаких changes scripts/check_ci_gate.sh, make_task.sh, profile_resolver.sh, архитектурных/мобильных скриптов или проектов в 227. Ш-3=228, judges.policy=229, Ш-7/Ш-8 и переход Ш-5ф к отказу — вне предмета. Каждый следующий ход — отдельный номер/v+1 по слову владельца, а не расширение текущей раздачи.

Последовательность R-0114: 226/hooks.archBrief отдельно → ci.requiredChecks (убрать legkij-привязку check_ci_gate) → hooks.judgeSetup → остаток pack.maxBytes (вынести fallback 40000 из make_task) → мобильный UI/ekran_shablon.py после done 218 моба → вызов архитектурного кита/tooling/checks/cli.js через профиль. Критерий каждого будущего хода: соответствующий `git grep -n` литерала вне комментариев пуст, игрушечный проект с другим repoId/значением исполняется по ключу; отчёты с неизменной областью сканирования показывают монотонное уменьшение от базы 89/20. Без ключа сохраняется прежнее поведение; у дверей-стражей некорректное значение fail-closed. Имена/схемы ключей и критерии этих отдельных контрактов здесь не реализуются. Смена области сканирования отмечается явно, не выдаётся за уменьшение долга.

## Модель угроз

ЗАЩИЩАЕТ:
- От невидимого остатка и превращения отчёта в блокировку по числу совпадений: полный список/оба счётчика, rc 0 при нуле/ненуле/сверх базы, структурные проверки и адресные операции модели.
- От зашивки параметров сканирования в production и потери tracked/dirty, исключений, полных строк/путей: один конфиг, настоящие Git-миры с изменёнными значениями и независимые ожидаемые записи.
- От ложного нуля при отказе измерения/чтения конфига: отдельные сценарии операционной ошибки наблюдают rc 2, именованную диагностику и отсутствие отчёта; честный пустой остаток остаётся зелёным.
- От декоративного script без CI-потребителя: каноническая строка в реестре, замер и настоящий gen_ci_steps --check на выбранном дереве.

НЕ ЗАЩИЩАЕТ:
- От наличия зашивок или немонотонного долга: это отчёт, не запрет. Ловцы — последующие контрактные ходы Ш-5, CI-логи и reviewer; включение отказа требует отдельного слова/предмета после Ш-5.
- От семантических зашивок вне configured ERE/области (включая динамические строки) или сознательного изменения конфига ради сокрытия долга: ловец reviewer полного diff/config, а не новый анализатор кода.
- От компрометации Git/PATH/установки, произвольного распознавания фикстуры либо single-uid подмены памяти свидетеля: доверенная среда прежняя; ловцы — isolated/CI и независимый reviewer. Конечная батарея не доказывает поведение любой мыслимой программы.
- От неконформного JSON/ERE, не-UTF-8 tracked текста/имени и операционного отказа FS/инструмента: это не измеренный остаток; rc 2/NOT_IMPLEMENTED требует устранить среду, ловец — оператор/CI, не молчаливый ноль.

## Зоны

ЗОНА architect: contracts/227-sh5f-zashivki-otchet.md fixtures/workshop_project/zashivki_otchet_227/
ЗОНА implementer: scripts/report_zashivki.sh config/zashivki.json
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

ПЕРЕСЕЧЕНИЕ architect: contracts/227-sh5f-zashivki-otchet.md — 993 только страница и новая семья 227; старые семьи не меняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/zashivki_otchet_227/ — 054 только страница и новая семья 227; старые семьи не меняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/zashivki_otchet_227/ — 055 только страница и новая семья 227; старые семьи не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 свой шаг/замер 227
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 свой шаг/замер 227

ПРЕДПОСЫЛКИ:
- setting Git/bash/python3/jq, стандартный JSON Schema engine станции, пинованный shellcheck; новых secrets, variables, environments и настроек GitHub не требуется.
- setting Два CI-ключа и их реальные веса/замеры подключает orchestrator после освобождения общей тройки CI. Новые production-файлы до implementer отсутствуют намеренно.

ПРОВОДКА:
- guard=fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh

ПРОВОДКА-ЭНФОРСМЕНТ: чистый read-only отчёт и проверка его потребителя; новой поведенческой нормы ролей нет. Selftest подключает orchestrator по фазе; отдельный report-step всегда rc 0 при конформном остатке, не enforce.

## Незаполненные требования:
нет
