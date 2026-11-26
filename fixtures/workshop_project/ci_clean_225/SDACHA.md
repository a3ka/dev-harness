# СДАЧА 225 — очистка CI

Обещание: конфигурируемая очистка declared roots, без удаления tmp живого job; наблюдение — файловые эффекты CLI, kernel-protocol boundary, установленное/sha256 и отрицательные дрейфы. Frozen 196 CLI/формат сохранён, изменение умолчания срока прямо разрешено R-0101; 074/check_one остаётся единым установочным механизмом. Production в этой пачке не меняется.

Измерено: --stabs rc 0, честный контроль 89 клеток/0 красных, 42 обманки, 57 отдельных предъявлений, живых 0; --sintaksis rc 0, SINTAKSIS=46; каталог 55 носителей. Генератор build.py и source.json — источник списка/связей/sha256; числа не перенесены в нормативную приёмку как вечные константы. --repo до реализации rc 1, 89/89 красных: defaults/units/readme; tmp/config/lock — SUBJECT_ABSENT ci-runner-tmp-clean; artifacts — SUBJECT_ABSENT ci-clean.py; install/verify — отсутствующая ci-clean CLI; artifacts-common — отсутствующая копия helper. Старый cleaner без нового конфига не исполняется по default /var/lib: отсутствующий helper даёт именованное отсутствие предмета, а не опасную попытку чистки станции.

196, сырой исходный прогон на чистом origin-only клоне базы e7f2e9dab64b83a1226f63ab89f9c3b8abed19f5: --repo rc 1, 25/24/1, единственная красная verify-runner-dropin — нет gh-runner-complior.service.d/tmpdir.conf в положительном artifacts-мире; --model rc 0, 25/25/0; --stabs rc 0, 34/34/0. Гипотезы: (1) не создано новое независимое предусловие mob-tmpdir; (2) не изолирован OPS_SERVER_MOB_TMP и проверяется живой путь; (3) неверны владельцы мира. Код подтвердил (1) и (2); реальный tmp-owner мира теперь текущий uid, каталог 700. Ремонт в probe.py готовит исправного соседа перед verify, не отключает проверку/негативные D1/D2-раунды. Frozen-текст 196 не правился.


Прогон через check_sdacha дополнительно выявил независимость cwd: прежний Subjects сохранял --repo . относительным, а подпроцесс исполнялся из одноразового мира. Поэтому абсолютный --repo уже был зелёным после ремонта mob-tmpdir, но требуемый --repo . оставался красным. Subjects теперь канонизирует корень до смены cwd; это восстановление того же документированного CLI, без удаления клеток/ослабления rc.
Среда: TMPDIR и npm cache внутри собственной копии; root, живой /var/lib, сеть GitHub для тестовых файлов и owner-identity не используются. Runtime JSON Schema: python3/jsonschema (на станции наблюдена версия 4.26.0). Отсутствие зависимости/валидатора/носителя — rc 2; отсутствие ещё не реализованной ci-clean CLI узнаётся по прежней точной usage-строке, это красное продукта, не нечем проверить. Пин shellcheck — VALIDATE_STD_SHELLCHECK.

Ряды ниже — исполняемые требования равенства rc; check_sdacha --run повторно снимает фактический результат каждой команды. Живой root/systemd прогон не заявлен выполненным: до done оператор проверяет freeze/thaw/долгий job и Persistent на станции.
До-предметный --repo rc 1 — измерение выше, не постоянное требование красного production. После реализации --repo обязан дать 0 по контракту и CI; лист не сохраняет живую строку «ожидать 1», которая сломала бы done уже исправленного предмета.

## Двери

- Model · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --stabs · 0 · 0
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
- К-03 · чисто · вход: 074/196/197, существующий mob-tmpdir; ремонт изолированного мира вместо выключения production verify, срока больше нет вторым литералом кода/контракта; frozen 196 не правится · - · -
- К-04 · чисто · вход: architect — контракт/семья/один probe 196; production-файлы и новые config/schema/helper/units точно перечислены implementer; CI — orchestrator · - · -
- К-05 · чисто · вход: полные rc-команды приёмки; до-предметный --repo 1, честный контроль/стабы/форма/каталог/регресс 0; root-приёмка отдельно до done · - · -
- К-06 · чисто · вход: BadWorld/NOT_IMPLEMENTED для зависимости/синтаксиса носителя; прежняя exact usage отсутствующего ci-clean распознаётся как отсутствие предмета; rc 2 не объявлен зелёным · - · -
- К-07 · чисто · вход: настоящие bash/Python/schema и FS на станции, instal/verify с прежними швами 196; systemctl-шим прямо ограничен границей, реальный kernel-эффект требует операторского предъявления · - · -
- К-08 · чисто · вход: --stabs проверяет честный контроль, синтаксис каждого носителя и отдельную красноту всех связей; tmp/artifact config меняет эффект, приёмка не сравнивает retention с литералом кода · - · -
- К-09 · чисто · вход: оба корня, active/inactive/unknown/busy/idle, nested-worker/race, файлы/деревья/симлинки/имена, строгий config/терминаторы, optional/partial/install/verify каждому адресату · - · -
- К-10 · чисто · вход: снимки дерева/байтов/режимов/chown, неизменность внешнего sentinel, сохранность busy-дерева, freeze→thaw журнал, rc и именованная причина, не один печатный маркер · - · -
- К-11 · чисто · вход: оракулы до вызова в памяти probe; source.json пинует модель/обманки/пробу; после субъекта источники ожиданий не перечитываются · - · -
- К-12 · чисто · вход: JSON Schema 2020-12, структурный INI-канон юнитов, канонический README-раздел, bash -n/shellcheck, существующий check_one sha256 и install-миры 196 · - · -
- К-13 · н/п · секретов/credentials в мире нет; synthetic payload/uid, нет новой секретной конфигурации или CI secrets · - · -
- К-14 · чисто · вход: молодой/старый, busy/idle-listener, конфиг с иными сроками/корнями/worker_names/юнитами, пробелы/переводы строки в FS-именах, положительный optional verify; запрет NUL не запрещает Unicode/пробел · - · -
- К-15 · чисто · вход: build.py -- вывод KLETKI/STABY/SVJAZI/NOSITELI, --catalog проверяет тот же список и hashes; числа сняты из последнего прогона, связи не объявлены прозой контракта · - · -
- К-16 · чисто · вход: обычный локальный ops; root trusted, arbitrary FS/TOCTOU/root-конкуренция/comm-forgery/SIGKILL и реальный kernel названы границами с ловцами, не выданы за защиту стендом · - · -
- К-17 · н/п · модели 188 продукта нет; общий helper/config вместо второй конвенции, отдельный отказный контур tmp не меняет интерфейс писателя 197 · - · -

## Дельта

Новый предмет; предыдущего вердикта 225 нет. Ремонт клетки 196 — прямо заданная часть 225, не расширение по собственной находке. CI/main-журнал наблюдений не редактируются в wip-пачке.
