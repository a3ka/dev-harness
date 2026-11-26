# Контракт 225 — CI-CLEAN: конфигурируемая очистка CI на станции

КЛАСС ЗАДАЧИ: кодовый — ops/server, установка/сверка и красная батарея.
КЛАСС РИСКА: рисковый — безопасность: очистка под root удаляет файлы раннеров; неполный обзор cgroup может уничтожить данные работающего job. Без прав БД, денег, ПД/health-данных, согласий и юридически значимых действий.
ПРОДУКТ: станция
АРХИТЕКТУРА: не применимо — модель 188 продукта не меняется.

КОНТЕКСТ: R-0101, 24–25.11, через консультанта: «Линия CI: 074 закрыт; очистка временных каталогов раннеров (старше 1 дня) и артефактов CI (старше 3 дней) — через ops/server; 196 — станция чинит красную проверку; … срок 26.11 — диск 89–93%». Замер входного задания: tmp раннеров 3,8 + 5,2 ГБ, 95 записей за 13 ч, очистки нет; артефакты 7,2 ГБ. Цитата — источник решения, не дублирующий конфиг сроков.
КОНТЕКСТ: R-0102, 25.11, дословно: «хардкодить ничего не надо, все надо выносить в конфиги». Значения политики объявлены только в model/ci-clean.json, будущий production-носитель — ops/server/ci-clean.json; этот контракт определяет получение значений и поведение, не второй набор умолчаний. Нового sourceCanon нет.

## Существующее

- База e7f2e9dab64b83a1226f63ab89f9c3b8abed19f5; registry/contracts.tsv и registry/plan.tsv уже несут 225, id/CONTRACT/225 выдан. HANDOFF/ROADMAP отстают от дерева: 074/196 и 197 уже имеют done-теги; контрактного файла 216 нет, только id-тег и ранее отложенная гигиена /tmp. Называть реализацию mob-tmpdir замороженным контрактом 216 неверно.
- ops/server/root/ci-artifacts-clean и root/systemd/ci-artifacts-clean.service/.timer уже чистят объявленные репо по возрасту всего дерева, не следуют по ссылкам; Persistent наверстывает простой. Сохраняются bash-вход, stdout/отказы 196 и ENV-переопределения CI_ARTIFACTS_ROOT/RETENTION_DAYS/REPOS; меняется только источник умолчаний по прямому R-0101/R-0102. Frozen-текст 196 не переписывается.
- ops/server/install.sh уже имеет artifacts, mob-tmpdir, verify, check_one (sha256), OPS_SERVER_SRC/SBIN_DST/ETC_DST/SYSTEMCTL и euid-гард. Новая ветвь ci-clean использует их же; строки UNITS= базового инвентаря 074 и базовая «сверка: 10/10» не меняются. artifacts также ставит общие конфиг/схему/помощник, иначе прежний cleaner после переустановки не запустится. Ни нового установщика, ни provisioning раннеров нет.
- root/gh-runner-complior-tmpdir.conf и root/gh-runner-complior-2-tmpdir.conf — уже конфиги TMPDIR двух раннеров; mob-tmpdir ставит их по наличию юнита, verify проверяет независимо от artifacts. Эти drop-in'ы, владельцы и TMPDIR процессов не меняются; конфиг очистки перечисляет соответствующие корни явно.
- ops/server/README.md — единый операторский источник 074. Дополняется разделом из model/README.md; существующий раздел 196 сохраняет свой интерфейс, его описание срока переводится на конфиг без второго значения умолчания. 197 — писатель артефактов в другом репозитории, формат <repo>/<run>-<attempt> не меняется.
- Чистый canonical-origin клон воспроизвёл 196: --repo rc 1, 25 клеток/1 красная verify-runner-dropin; --model rc 0, 25/0; --stabs rc 0, 34/0. Причина не в очистке: положительный мир artifacts создавал runner.service без независимо обязательного tmpdir.conf/каталога. install_core_files теперь готовит этот соседний предмет в своём TMPDIR, с текущим реальным владельцем; OPS_SERVER_MOB_TMP/OWNER изолированы. Все прежние D1/D2 × дрейф/отсутствие и положительные конфигурации сохранены; optional-юниты 225 не выдаются за базовую установку. Ничего не отключено в production verify.
- Поиск contracts/, registry/plan.tsv, fixtures/, scripts/, wip и gh pr list: существующей очистки runner tmp нет; открытых PR с таким решением нет. 216/Н-455 — устранение утечек общестанционных /tmp-батарей, не безопасное обслуживание постоянного TMPDIR моба; не заменяет 225. Измеренный Н-455 — диск 93% и ручная чистка десятков тысяч объектов — подтверждает цену отсутствующей гигиены, но системный /tmp здесь не чистится.
- Прецедент батареи — ops_ci_artifacts_196: одноразовые FS-миры, id/chown/stat/systemctl швы и ожидания в памяти. Использованы её установочные предусловия, а не второй симулятор Unix-прав. А-3/А-118/А-330: именованный отказ, адресная сверка каждого файла, не зачёт по первой красной точке.

## Frontier

А — второй проход существующего cleaner: один таймер, но отказ артефактов либо общий skip мешает tmp; смешивает frozen 196 с новым freeze/thaw протоколом. Отвергнут в пользу независимых отказов.
Б — systemd-tmpfiles: меньше кода, но возраст не доказывает отсутствие живого job, зависшего дольше срока; только mtime не закрывает главный риск. Отвергнут без дополнительного протокола занятости.
В — выбран отдельный ci-runner-tmp-clean + service/timer, общий ci-clean.py/config/schema с артефактами; та же установка/check_one/verify. Таймер конфигурационный, Persistent; active-раннер кратко freeze, подтверждение kernel frozen, все worker-процессы рекурсивной cgroup проверяются ДО удаления, затем обязательно thaw. Busy пропускает весь корень, idle чистится даже при постоянно active listener. Конфиг задаёт политику, отдельной конвенции установки нет. flock исключает взаимное размораживание двух экземпляров.

## Предмет и инварианты

Один результат: ограниченная политикой из конфига очистка диска CI без удаления данных работающего job, установленная и сверенная механизмом ops/server. Architect пишет только контракт/модели/предъявления и ремонт мира 196; production реализует implementer после заморозки.

1. **Конфиг.** ops/server/ci-clean.json и ci-clean.schema.json — JSON Schema 2020-12; точная грамматика/умолчания — model-канон. Допустимы только объявленные поля; сроки — положительные целые, списки не пусты, unit/имена repo/worker — замкнутые алфавиты схемы. Дубликат JSON-ключа, NUL, пустой/отсутствующий файл, неизвестное поле, неверный срок — rc 1 CONFIG_INVALID до удаления/systemctl. Корни абсолютные, канонические, без `..`, непересекающиеся; lock вне удаляемых корней. Переупорядочивание JSON/пробелы значения не меняют. Значения из файла реально определяют сроки, roots, worker_names; действующие ENV артефактов имеют приоритет над корректным конфигом.
2. **CLI/размещение.** Два bash-входа root/ci-artifacts-clean и root/ci-runner-tmp-clean вызывают sibling ci-clean.py в режимах artifacts/tmp; скрипт принимает также check для предустановочной валидации без FS-операций предмета. В установленном SBIN_DST рядом лежат конфиг/схема/помощник. CI_CLEAN_CONFIG/CI_CLEAN_SCHEMA задают явные файлы без пустого fallback. Без HOME поведение то же. Нет Python/jsonschema/другой зависимости — rc 2 NOT_IMPLEMENTED, а не успех или краснота продукта.
3. **Возраст/границы.** Только записи верхнего уровня объявленного корня; старше границы, если ВСЁ дерево не моложе «сейчас − configured retention_days». Старые каталоги и файлы tmp удаляются, молодая вложенная запись сохраняет целое; пустой корень — rc 0. Сохраняются сами корни и всё снаружи. Имена tmp не ограничиваются буквами: пробелы, переводы строки, Unicode и ведущий дефис обрабатываются литеральными путями, без shell/split. NUL в POSIX-имени невозможен; NUL в конфиге отклоняется. Симлинк корня или любого его предка — rc 1 ROOT_INVALID; отсутствующий корень — такой же отказ без создания. Симлинк верхней записи — rc 1 TMP_SYMLINK, запись/цель сохранены, другие валидные записи продолжаются; вложенные ссылки не обходятся и их цели не удаляются.
4. **Живой job.** До tmp-удаления flock на configured lock_path; занято — rc 1 CLEAN_BUSY без systemctl/удаления. Для каждого active unit: systemctl show ActiveState/ControlGroup → freeze → строка frozen 1 в cgroup.events → полный рекурсивный обзор cgroup.procs и comm из configured proc_root. Работает хотя бы один configured worker — rc 0 BUSY, всё дерево этого раннера нетронуто независимо от возраста, соседний idle-раннер всё равно обслуживается. Idle listener не блокирует. Новый worker между show и freeze также виден после freeze. Система inactive/failed чистится; неизвестный/переходный статус, ошибка show/freeze, неканонический ControlGroup либо любая ошибка перечисления, stat или чтения cgroup/proc на ЛЮБОЙ глубине (включая недоступную вложенную группу) — неопределённость, rc 1 без удаления этого корня; соседние обрабатываются. Найденный worker не прекращает обзор остальных групп. freeze попытан — thaw в finally на успехе, отказе, SIGINT/SIGTERM, даже после частично выполненной freeze; THAW_FAILED — rc 1 и операторская причина. Lock закрывается на выходе.
5. **Артефакты.** Сохраняются грамматика, границы repo/run, отрицательные сценарии, stdout и bash ENV-семантика `${VAR:-default}` 196, включая no-HOME. Для КАЖДОЙ из CI_ARTIFACTS_RETENTION_DAYS/CI_ARTIFACTS_ROOT/CI_ARTIFACTS_REPOS пустое значение эквивалентно незаданному: срок, ROOT и REPOS берутся из общего конфига, не из литералов кода. Непустые значения имеют приоритет; неверный непустой срок (`abc`, `0`) по-прежнему даёт отказ. Смена значений конфига меняет наблюдаемое удаление. Вход artifacts не замораживает раннеры. Их таймер/юнит и формат писателя 197 не меняются.
6. **Установка.** install.sh ci-clean: euid 0, наличие КАЖДОГО файла инвентаря model/install-ci-clean.sh и корректность конфига до записей/chown/chmod/systemctl. Отказ — rc 1 с euid/источником/CONFIG_INVALID. Общие файлы также ставит artifacts, не ломая его существующие предусловия. Копии и адресаты — инвентарь FILES в probe.py; каждый файл root:root, режим из инвентаря, sha256 перечитан check_one. После всех копий daemon-reload → enable --now ci-runner-tmp-clean.timer; ошибка systemctl — rc 1, отсутствие зависимости — rc 2. Юниты каноничны структурно, включая Persistent; базовые UNITS= не расширяются.
7. **Сверка/доки.** install.sh verify читает, ничего не ставит: после ci-clean — rc 0 с ci-clean:; дрейф и отсутствие КАЖДОГО адресата — rc 1 «расхождение» с фактическим путём. Общие helper/config/schema проверяются также после artifacts; отсутствие всей tmp-части на станции, где она ещё не установлена, не расхождение, но её частичная установка красна. Прежние optional-части 074/196/mob-tmpdir не маскируются. README содержит канонический раздел model/README.md (дополнительная операторская проза допустима), условия зависимости, команды установки/выключения/сверки и восстановления thaw.

## Батарея и демаркация

W = `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh`; W196 = `bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh`. В командах приёмки ниже записаны полные пути, алиасы не нужны.
Публичные швы заданы этим заданием: CLI cleaner/install.sh и конфиг/корни ENV; без root/реальных /var/lib. Модель исполняется настоящими bash/Python/JSON Schema на станции. Systemctl/cgroup/proc-ответы — явный стенд границы, не свидетельство реального замораживания ядром. Оракулы дерева/байтов/метаданных читаются в память до вызова; после вызова диск — наблюдаемый эффект, не источник ожидания. Канон юнитов — структурное INI-сравнение, shell — bash -n/shellcheck, JSON — Schema; нет самодельного формата-валидатора.
Конформный вход: корректный config схемы, доступные доверенные корни и полный определимый статус configured unit/cgroup/proc, POSIX FS. Неконформный вход имеет собственный отказной сценарий. Валидный контрпример = инвариантность к значениям/путям и расхождение на конформном входе, не требование пропустить неверный config. Положительные пары: old/young, busy/idle-listener, nested-worker/empty-root, active/inactive, произвольные имена/ссылка, стандартные/изменённые roots/retention/worker_names, установленное/дрейф. Конечный поадресный набор и связи мутаций генерируются build.py → source.json; каждая связь исполняется отдельно, синтаксически негодная обманка не засчитывается. Контракт не задаёт пар обманка ↔ ветвь.

## Приёмочный критерий

- Дано до-предметное дерево; когда `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --repo .`; тогда rc 1 с именованными SUBJECT_ABSENT/CONFIG_ABSENT/UNIT_ABSENT/INSTALL_RC/README_SECTION_ABSENT и конфигурационными расхождениями артефактов. После реализации та же команда — rc 0, KRASNYH=0.
- Правило честного контроля; `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --model` → rc 0, KRASNYH=0.
- Дано недоступная вложенная cgroup/её родитель/cgroup.procs/proc comm либо ошибка readdir/stat второго уровня со старой записью; когда `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta`; тогда батарея rc 0: cleaner rc 1, дерево неопределённого корня неизменно, соседний idle обслужен, thaw вызван после freeze и frozen 0 наблюдён. Та же команда проверяет незаданные/по отдельности пустые/вместе пустые три ENV, корректные непустые значения и отказы `abc`/`0`: эффекты/rc/stdout сверяются с 196 дифференциально и с литеральными ожиданиями в памяти. Только три default-значения старого bash-источника в изолированной копии приведены к конфигу 225, его `${VAR:-}` и остальной код не меняются.
- Правило различимости; `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --stabs` → rc 0, ZHIVYH=0; честный контроль прежде мутаций зелён, каждое адресное предъявление красно отдельно.
- Правило формы; `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --sintaksis` → rc 0; отсутствующий валидатор/пин — rc 2. `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --catalog` → rc 0, непустые KLETKI/STABY/SVJAZI/NOSITELI, sha256 носителей совпадают.
- Правило регресса; `bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --repo .` → rc 0; `bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --model` и `bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --stabs` → rc 0. Отрицательные D1/D2-предъявления не удалены.
- Правило допуска; `bash scripts/pre_critic.sh contracts/225-ci-clean-vremennye-katalogi.md` и `bash scripts/check_sdacha.sh . contracts/225-ci-clean-vremennye-katalogi.md --run` → rc 0.
- Правило done-проводки после подключения CI orchestrator; `bash scripts/check_provodka.sh . contracts/225-ci-clean-vremennye-katalogi.md` и `bash scripts/gen_ci_steps.sh --check` → rc 0.
- Дано станция с зависимостями; когда оператор выполняет `sudo bash ops/server/install.sh ci-clean` и `sudo bash ops/server/install.sh verify`; тогда rc 0, sha256 всех адресатов совпадает с репо. Преднамеренный дрейф одного установленного файла — тот же verify rc 1 с его путём; оператор восстанавливает файл штатной установкой, не ослабляет сверку.
- Живой контроль оператора до done: с активным долгим job старые записи его tmp сохраняются с BUSY; в idle — старые удалены, молодые сохранены, оба unit не остались frozen; после простоя Persistent-таймер запускает очистку. Команды/rc/systemd-вывод оператор прикладывает ревьюеру. Это эксплуатационная приёмка, не уже выполненное architect свидетельство.

## Модель угроз

ЗАЩИЩАЕТ:
- От удаления за пределами configured roots на стабильной доверенной FS: проверка корней/предков, литеральные пути, отказ на внешнюю ссылку, rmtree без обхода вложенных ссылок; пробел/перевод строки не разделитель данных.
- От удаления tmp живого job, в том числе старше срока: freeze подтверждён, worker-проверка по всей замороженной cgroup, busy-root пропускается; lock не даёт параллельной чистке преждевременно thaw.
- От тихого fallback на опасную политику или расходящихся копий: строгий конфиг до эффекта, именованные отказы, поадресный sha256 verify, отрицательные проверки установочных предусловий.

НЕ ЗАЩИЩАЕТ:
- От враждебного root/оператора, конкурентной смены путей/cgroup, процессов, намеренно вышедших из runner cgroup или подделавших comm, и arbitrary FS/TOCTOU/hardlink-атак. Это доверенные раннеры станции; ловец — ревьюер полного production-diff и эксплуатационная изоляция, не fixture systemctl.
- От SIGKILL/отключения питания между freeze и thaw: finally физически не исполним; ловец/восстановление — systemd-состояние и операторский thaw из README. При отказе thaw данные уже могли быть очищены у idle-раннера; rc 1 требует вмешательства, не повтор до случайного зелёного.
- От переполнения диска между таймерами, бесконечно занятого раннера или неописанных корней/утечек системного /tmp. Ловец — мониторинг диска и отдельная гигиена Н-455/216; busy не разрешает принудительное удаление job.
- От отличия реального systemd/cgroup v2 от стенда: обязательна живая операторская приёмка до done; модели/стабы не доказывают действие ядра. Полнота всех условных реализаций не обещана: конечные клетки плюс независимый reviewer, известное нарушение вне матрицы всё равно дефект.

## Зоны и проводка

ЗОНА architect: contracts/225-ci-clean-vremennye-katalogi.md fixtures/workshop_project/ci_clean_225/ fixtures/workshop_project/ops_ci_artifacts_196/probe.py
ЗОНА implementer: ops/server/root/ci-artifacts-clean ops/server/root/ci-runner-tmp-clean ops/server/root/ci-clean.py ops/server/ci-clean.json ops/server/ci-clean.schema.json ops/server/root/systemd/ci-runner-tmp-clean.service ops/server/root/systemd/ci-runner-tmp-clean.timer ops/server/install.sh ops/server/README.md
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ops_ci_artifacts_196/probe.py — 196 только изоляция mob-tmpdir предусловий мира; frozen-текст и прежние отрицательные клетки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/ci-artifacts-clean — 074 источник общей конфигурации 225; остальная обвязка неизменна.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/ci-artifacts-clean — 196 сохранены bash CLI/ENV (пустое = незаданное для срока/ROOT/REPOS), грамматика, эффекты и stdout; все три умолчания берутся из конфига R-0102, срок изменён по R-0101.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/ci-runner-tmp-clean — 074 новый cleaner 225, существующие файлы не затрагиваются.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/ci-clean.py — 074 общий помощник конфигурируемой очистки, не второй установщик.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/systemd/ci-runner-tmp-clean.service — 074 только новый service 225.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/systemd/ci-runner-tmp-clean.timer — 074 только новый timer 225.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/systemd/ci-runner-tmp-clean.service — 093 только новый service 225, прежние юниты неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/root/systemd/ci-runner-tmp-clean.timer — 093 только новый timer 225, прежние юниты неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 196 общие файлы при artifacts, новая ci-clean и условная сверка, старые предусловия/адресаты сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 196 конфигурационная политика вместо литерала срока, остальной интерфейс сохранён.

Смысловое пересечение с mob-tmpdir (код помечен 216): ни его drop-in'ы, ни каталоги/владельцы/перезапуск раннеров не перераздаются; в 196 готовится только исправный тестовый сосед. Нет frozen 216, поэтому ложной ПЕРЕСЕЧЕНИЕ-строки на него нет. 197 не редактируется.

РАБОТА РАЗДАЁТСЯ: implementer — только перечисленный production-инвентарь после freeze; orchestrator — CI, суд и передача живой установки оператору. Чужие строки CI/замеры не меняются. Новая батарея в CI до реализации: --model/--stabs/--sintaksis/--catalog; после реализации также --repo .; шаг check:ci-clean-225-family-selftest и свой замер генерирует orchestrator штатным gen_ci_steps.sh.

ПРЕДПОСЫЛКИ:
- setting Linux, bash, Python3 с jsonschema, GNU coreutils/findutils; для формы — пинованный shellcheck через VALIDATE_STD_SHELLCHECK. Наличие Python/jsonschema проверено исполнением модели на станции; root/systemd-эффект до done подтверждает оператор.
- setting Только для живой установки: root, cgroup v2/systemd с freeze/thaw, обычные configured worker comm, доступные configured корни. Нет новых GitHub secrets/variables/environments; CI без root использует временные миры и швы 196.
- setting Строка реестра/плана 225 уже есть; CI-подключение — orchestrator после заморозки, не production-изменение architect.

ПРОВОДКА:
- guard=fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh

ПРОВОДКА-ЭНФОРСМЕНТ: чистый серверный энфорсмент, новых поведенческих норм роли нет. Потребитель установленных конфигов/скриптов — install.sh verify и systemd-таймеры; потребитель батареи — сдаточный лист и собственный CI-шаг 225. Живой root-прогон остаётся операторским, не объявляется зелёным по шиму.
СДАЧА: fixtures/workshop_project/ci_clean_225/SDACHA.md

## Незаполненные требования:
нет

## Пересечения CI

Только собственный шаг и замер 225; перечень сверяется union действующих frozen-зон, чужие батареи неизменны.

ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 свой шаг 225.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 свой замер 225.

