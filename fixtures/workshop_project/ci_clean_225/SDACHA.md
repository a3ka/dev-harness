# СДАЧА 225 — очистка CI

Обещание: конфигурируемая очистка declared roots, без удаления tmp живого job; наблюдение — файловые эффекты CLI, kernel-protocol boundary, установленное/sha256 и отрицательные дрейфы. Frozen 196 CLI/формат сохранён, изменение умолчания срока прямо разрешено R-0101; 074/check_one остаётся единым установочным механизмом. Production в этой пачке не меняется.

Измерено после решения Arb225 «исправить-как-196»: --model rc 0, 276/0; --stabs rc 0, 59/84/0 (стабы/связи/живые); --delta rc 0, 187/0, DIFFERENTIAL_GRID=172 RAZHOZHDENIJA=0; --sintaksis rc 0, SINTAKSIS=65; --catalog rc 0, 74 носителя. До→после от c11a5b323883547ea1140b42195b3e22d340c20c: клетки 104→276, стабы 48→59, связи 68→84, носители 62→74. Прежние 104 клетки сохранены, текстовые сравнения переведены на bytes без ослабления; snapshot дополнен uid/gid. Новые оси: defaults=24, zero=39, zero-invalid=2, position=37, nonbash=8, invalid=15, glob=6, days=23, root=18. Полный список клеток — source.json:kletki, порядок соответствует --repo.

Текущий --repo .: rc 1, KLETKI=276 KRASNYH=276; список красных РОВНО весь source.json:kletki. Причины только отсутствующий production 225/установочная ветвь: CONFIG_ABSENT, UNIT_ABSENT, README_SECTION_ABSENT, SUBJECT_ABSENT, INSTALL_RC, INSTALL_PRECONDITION, SYSTEMCTL_FAILURE_IGNORED, ARTIFACTS_COMMON_MISSING. Исправленный оракул 196 сам красных не даёт. Регресс 196 в canonical-origin-only клоне: --repo . rc 0, 25/0; --model rc 0, 25/0; --stabs rc 0, 34/0.

ДОПУСК НЕ ПОЛУЧЕН: check_sdacha --run rc 1 и pre_critic rc 1: «предыдущий вердикт: отсутствует вызов 1 (К-02)». У contracts-225-v2.md вызов 2/2 с унаследованными статусами вызова 1, но библиотека frozen 204 выводит фазу 2 из имени v2; вызов 1 хранится только в файле фазы 1 (contracts-225-v1.md). Оба оригинальных verdict закоммичены в archive/225/critic-v2-fail-25e1391f73, подмена/переименование вердиктов и правка gate вне зоны architect. Замена ссылки на старый v1 ради зелёного не выполнена. Нужна исправленная critic-история/полномочное решение о её представлении; это новый процессный блокер оркестратору для журнала main, не дефект cleaner и не разрешение critic-3/freeze. check_precision_gate после fetch origin/main rc 0; первая проба single-branch клона дала missing-remote rc 1, отсутствие origin/main исправлено без смены canonical origin. До исправления карты строки дверей ниже задают требуемые rc, а не утверждение общего допуска.

196, сырой исходный прогон на чистом origin-only клоне базы e7f2e9dab64b83a1226f63ab89f9c3b8abed19f5: --repo rc 1, 25/24/1, единственная красная verify-runner-dropin — нет gh-runner-complior.service.d/tmpdir.conf в положительном artifacts-мире; --model rc 0, 25/25/0; --stabs rc 0, 34/34/0. Гипотезы: (1) не создано новое независимое предусловие mob-tmpdir; (2) не изолирован OPS_SERVER_MOB_TMP и проверяется живой путь; (3) неверны владельцы мира. Код подтвердил (1) и (2); реальный tmp-owner мира теперь текущий uid, каталог 700. Ремонт в probe.py готовит исправного соседа перед verify, не отключает проверку/негативные D1/D2-раунды. Frozen-текст 196 не правился.


Прогон через check_sdacha дополнительно выявил независимость cwd: прежний Subjects сохранял --repo . относительным, а подпроцесс исполнялся из одноразового мира. Поэтому абсолютный --repo уже был зелёным после ремонта mob-tmpdir, но требуемый --repo . оставался красным. Subjects теперь канонизирует корень до смены cwd; это восстановление того же документированного CLI, без удаления клеток/ослабления rc.
Среда: TMPDIR и npm cache внутри собственной копии; root, живой /var/lib, сеть GitHub для тестовых файлов и owner-identity не используются. Runtime JSON Schema: python3/jsonschema (на станции наблюдена версия 4.26.0). Отсутствие зависимости/валидатора/носителя — rc 2; отсутствие ещё не реализованной ci-clean CLI узнаётся по прежней точной usage-строке, это красное продукта, не нечем проверить. Пин shellcheck — VALIDATE_STD_SHELLCHECK.

Ряды ниже — исполняемые требования равенства rc; check_sdacha --run повторно снимает фактический результат каждой команды. Живой root/systemd прогон не заявлен выполненным: до done оператор проверяет freeze/thaw/долгий job и Persistent на станции.
До-предметный --repo rc 1 — измерение выше, не постоянное требование красного production. После реализации --repo обязан дать 0 по контракту и CI; лист не сохраняет живую строку «ожидать 1», которая сломала бы done уже исправленного предмета.

## Двери

- Model · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --stabs · 0 · 0
- Delta · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
- Sintaksis · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --catalog · 0 · 0
- Regression-196-repo · bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --repo . · 0 · 0
- Regression-196-model · bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --model · 0 · 0
- Regression-196-stabs · bash fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --stabs · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/225-ci-clean-vremennye-katalogi.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/225-ci-clean-vremennye-katalogi.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/225-ci-clean-vremennye-katalogi.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/225-ci-clean-vremennye-katalogi.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/225-ci-clean-vremennye-katalogi.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы выше; СДАЧА и guard-проводка; контракт объявляет незаполненные требования и модель угроз · - · -
- К-02 · чисто · вход: task-architect225 и R-0101/R-0102, замеры диска, Н-455, дерево/plan/wip/PR; расхождение отсутствующего frozen 216 названо, нового sourceCanon нет · - · -
- К-03 · чисто · вход: --delta, формула Obs и закреплённый blob 196; две политики C, все 8 unset/empty комбинаций каждой, overrides, непустые разделители, позиции/Unicode/глоб/срок/ROOT; в каждой клетке bytes rc/stdout/stderr и FS плюс literal-опоры · - · -
- К-04 · чисто · вход: текущая дельта только контракт/семья 225; frozen 196 неизменён; его прежний ремонт остаётся в базе c11a5b323, не перераздаётся · - · -
- К-05 · чисто · вход: полные rc-команды приёмки; до-предметный --repo 1, честный контроль/стабы/форма/каталог/регресс 0; root-приёмка отдельно до done · - · -
- К-06 · чисто · вход: BadWorld/NOT_IMPLEMENTED для зависимости/синтаксиса носителя; прежняя exact usage отсутствующего ci-clean распознаётся как отсутствие предмета; rc 2 не объявлен зелёным · - · -
- К-07 · чисто · вход: настоящие bash/Python/schema и FS на станции, instal/verify с прежними швами 196; systemctl-шим прямо ограничен границей, реальный kernel-эффект требует операторского предъявления · - · -
- К-08 · чисто · вход: --delta сохраняет rc 1/нет удаления/thaw/frozen 0 при PermissionError чтения группы/файла и readdir/stat второго уровня; --stabs отдельно красит OSError→BUSY и точные четыре v1 · - · -
- К-09 · чисто · вход: все прежние ветви и порождающая сетка Arb225, корректные и отказные соседи каждого класса; пустая выборка не засчитывается · - · -
- К-10 · чисто · вход: снимки дерева/байтов/режимов/chown, неизменность внешнего sentinel, сохранность busy-дерева, freeze→thaw журнал, rc и именованная причина, не один печатный маркер · - · -
- К-11 · чисто · вход: оракулы до вызова в памяти probe; source.json пинует модель/обманки/пробу; после субъекта источники ожиданий не перечитываются · - · -
- К-12 · чисто · вход: JSON Schema 2020-12, структурный INI-канон юнитов, канонический README-раздел, bash -n/shellcheck, существующий check_one sha256 и install-миры 196 · - · -
- К-13 · н/п · секретов/credentials в мире нет; synthetic payload/uid, нет новой секретной конфигурации или CI secrets · - · -
- К-14 · чисто · вход: молодой/старый, busy/idle-listener, конфиг с иными сроками/корнями/worker_names/юнитами, пробелы/переводы строки в FS-именах, положительный optional verify; запрет NUL не запрещает Unicode/пробел · - · -
- К-15 · чисто · вход: build.py -- вывод KLETKI/STABY/SVJAZI/NOSITELI, --catalog проверяет тот же список и hashes; числа сняты из последнего прогона, связи не объявлены прозой контракта · - · -
- К-16 · чисто · вход: риск повышен до рискового — безопасность root-удаления файлов раннера; arbitrary FS/TOCTOU/root-конкуренция/comm-forgery/SIGKILL и реальный kernel остаются границами с ловцами, не исключают явно обещанный отказ при ошибке чтения · - · -
- К-17 · н/п · модели 188 продукта нет; общий helper/config вместо второй конвенции, отдельный отказный контур tmp не меняет интерфейс писателя 197 · - · -

## Дельта

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-225-v2.md

Б-2 — канон/инструмент: единый bash-алгоритм из blob b81b1e105d4daea14eea66539475ee9c519b0c6a, только три defaults из C через NUL-framing, без eval/trim/потери конечных LF. Python artifacts(cfg) теперь лишь выдаёт defaults; артефактного split/канонизатора/возрастного алгоритма в нём нет. Формула Obs применяется ко всем ENV, не только сетке. 172 независимые клетки сетки (не полное произведение) плюс прежние 15 дельта-клеток зелены. В каждой клетке два исходно одинаковых мира, полные bytes rc/stdout/stderr, FS-эффект и literal-опоры. Первая инженерная проба выявила дефект оракула (shell-quotes стали данными в default внутри двойных кавычек); он исправлен до зачёта, это не дефект продукта/не допустимая краснота --repo.

К-01 — адресные мутации по коду: четыре точные v1 и точная v2 добавлены отдельно. Young=False → YOUNG_REMOVED; worker только второго unit → OLD_LIVE_REMOVED; thaw лишь после успешного freeze → QUIESCENCE_OR_RELEASE_MISSING; tmp ровно один день → OLD_LIVE_REMOVED; cgroup OSError→True → UNCERTAINTY_RC 0 на procs/comm/stat. Прежние широкие стабы не заменяют их и сохранены. Каждая связь реально исполнена, синтаксически негодные стабы не засчитываются.

Прежние Python get/empty операции сняты cutover: artifacts(cfg) не читает ENV, публичный bash использует реальные `${VAR:-...}`. Прежние дефекты перенесены на публичный путь тремя отдельными `:-`→`-` мутациями (unset верен, empty ошибочен); все шесть связей individually/all красны. Отдельные стабы: отказ на ноль токенов, fallback после пустого split, Unicode split, trim срока, trim ROOT, канонизатор tmp для ENV ROOT. Привязки только в build.py/source.json, не в контракте.

Честные эквивалентные входы: whitespace-only разных длин/порядков — no-op; ведущие/концевые space/tab/LF, повтор/порядок имён — зелены; CR/VT/FF/NBSP и неверные имена — точный отказ до удаления; сроки 1/4/8/01 различают эффект; внутренний/концевой пробел, trailing slash, relative и x/../ у существующего ENV ROOT — зелены; empty/unset берут C, override не берёт C. Для каждой новой мутации есть наблюдаемый красный вход и честные соседние записи. Б-1 сохранён: прежние cgroup fail-closed клетки и busy/idle/young/old/freeze-fail зелены.

Frozen 196/production/registry/CI не правятся. Лист с v2 предъявлен в origin-only verification-клоне archive/225/critic-v2-fail-25e1391f73 с наложением только контракта/семьи 225: прошлый verdict находится в HEAD, не создан автором. Новых обязательств/дверей сверх блоков и решения Arb225 нет. Общие журналы в wip не дописываются; обнаруженный процессный блокер карты передаётся оркестратору для main.

- К-01 · канон/инструмент · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --stabs · 0 · 0
- К-03 · канон/инструмент · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
