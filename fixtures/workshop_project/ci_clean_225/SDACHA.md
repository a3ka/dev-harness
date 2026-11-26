# СДАЧА 225 — очистка CI

Обещание: конфигурируемая очистка declared roots, без удаления tmp живого job; наблюдение — файловые эффекты CLI, kernel-protocol boundary, установленное/sha256 и отрицательные дрейфы. Frozen 196 CLI/формат сохранён, изменение умолчания срока прямо разрешено R-0101; 074/check_one остаётся единым установочным механизмом. Production в этой пачке не меняется.

Измерено после исправления Crit225/1: --model rc 0, 104 клетки/0 красных; --stabs rc 0, 48 обманок, 68 отдельных предъявлений, живых 0; --sintaksis rc 0, SINTAKSIS=53; --catalog rc 0, 62 носителя. До→после: клетки 89→104, стабы 42→48, связи 57→68. Первое предъявление новых сценариев до исправления модели: 14 клеток/8 красных (нечитаемые вложенные группы/readdir/stat и четыре empty-ENV сценария); после исправления весь --delta 15/0. Отдельная новая клетка проверяет ошибку глубже уже найденного worker. --repo до production-реализации rc 1, 104/104 красных только из-за отсутствующего предмета/установки: CONFIG_ABSENT/UNIT_ABSENT/README_SECTION_ABSENT, SUBJECT_ABSENT, INSTALL_RC/INSTALL_PRECONDITION, SYSTEMCTL_FAILURE_IGNORED, ARTIFACTS_COMMON_MISSING. Ошибки старой модели не источник красноты. build.py/source.json — источник списков/связей/sha256, числа не вечные нормативные константы. Старый cleaner без нового helper не запускается с default /var/lib.

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
- К-03 · чисто · вход: empty/unset каждого ENV и всех вместе дифференциально против настоящего bash-источника 196 (побайтово равного production базы); в его изолированной копии нормализованы только три default-значения к конфигу 225, `${VAR:-}` неизменён; rc/stdout/эффекты также имеют независимые ожидания в памяти · - · -
- К-04 · чисто · вход: architect — контракт/семья/один probe 196; production-файлы и новые config/schema/helper/units точно перечислены implementer; CI — orchestrator · - · -
- К-05 · чисто · вход: полные rc-команды приёмки; до-предметный --repo 1, честный контроль/стабы/форма/каталог/регресс 0; root-приёмка отдельно до done · - · -
- К-06 · чисто · вход: BadWorld/NOT_IMPLEMENTED для зависимости/синтаксиса носителя; прежняя exact usage отсутствующего ci-clean распознаётся как отсутствие предмета; rc 2 не объявлен зелёным · - · -
- К-07 · чисто · вход: настоящие bash/Python/schema и FS на станции, instal/verify с прежними швами 196; systemctl-шим прямо ограничен границей, реальный kernel-эффект требует операторского предъявления · - · -
- К-08 · чисто · вход: --delta наблюдает rc 1/нет удаления/thaw/frozen 0 при PermissionError чтения группы/файла и readdir/stat второго уровня; ошибки не заменены «busy». --stabs адресно красит возврат ослабленного walk, подавление stat и ранний выход по worker · - · -
- К-09 · чисто · вход: сохранены все прежние ветви, добавлены вложенная/родительская нечитаемая cgroup, cgroup.procs/proc comm, readdir/stat, worker перед ошибкой; ENV empty по каждому шву/вместе, unset/valid и abc/0; корректные соседние/непустые варианты остаются зелёными · - · -
- К-10 · чисто · вход: снимки дерева/байтов/режимов/chown, неизменность внешнего sentinel, сохранность busy-дерева, freeze→thaw журнал, rc и именованная причина, не один печатный маркер · - · -
- К-11 · чисто · вход: оракулы до вызова в памяти probe; source.json пинует модель/обманки/пробу; после субъекта источники ожиданий не перечитываются · - · -
- К-12 · чисто · вход: JSON Schema 2020-12, структурный INI-канон юнитов, канонический README-раздел, bash -n/shellcheck, существующий check_one sha256 и install-миры 196 · - · -
- К-13 · н/п · секретов/credentials в мире нет; synthetic payload/uid, нет новой секретной конфигурации или CI secrets · - · -
- К-14 · чисто · вход: молодой/старый, busy/idle-listener, конфиг с иными сроками/корнями/worker_names/юнитами, пробелы/переводы строки в FS-именах, положительный optional verify; запрет NUL не запрещает Unicode/пробел · - · -
- К-15 · чисто · вход: build.py -- вывод KLETKI/STABY/SVJAZI/NOSITELI, --catalog проверяет тот же список и hashes; числа сняты из последнего прогона, связи не объявлены прозой контракта · - · -
- К-16 · чисто · вход: риск повышен до рискового — безопасность root-удаления файлов раннера; arbitrary FS/TOCTOU/root-конкуренция/comm-forgery/SIGKILL и реальный kernel остаются границами с ловцами, не исключают явно обещанный отказ при ошибке чтения · - · -
- К-17 · н/п · модели 188 продукта нет; общий helper/config вместо второй конвенции, отдельный отказный контур tmp не меняет интерфейс писателя 197 · - · -

## Дельта

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-225-v1.md

Б-1 — клетка: стандартный валидатор формата не доказывает эффект неполного runtime-обзора cgroup, снятие/граница ослабили бы обязательство. os.walk onerror поднимает неопределённость, lstat ловит скрытую ошибку классификации DirEntry, чтение procs/comm не подавляется; полный обзор не прерывается на worker. Клетки наблюдают rc, неизменное дерево неопределённого корня, обслуженный сосед, порядок freeze/thaw и конечный frozen 0. Честные empty/nested-worker/idle остаются зелёными. Адресные мутации walk/stat/ранний worker красны отдельно.

Б-2 — канон/инструмент: три ENV используют Python `get(...) or config` как bash `${VAR:-default}`. Никакого fallback 14/3 в helper нет. У старого bash-источника перед вызовом заменены только literal default-значения (новый разрешённый источник политики), не код fallback. Конфиг игрушки задаёт срок 4, старый артефакт имеет возраст 5, молодой 0.25: возвращение литерала 14 не проходит. Для пустого ROOT используется конфиг, не живой /var/lib. Все выходы и деревья сверяются с ожиданием в памяти; замены `or` обратно на `get(key, default)` красны в своих ветвях и во входе all-empty.

Драйверы cgroup_case.py/env_case.py из Crit225 воспроизведены дословными телами с дополнительными assert: первый теперь rc 1/old_exists=True/frozen 0; второй old/model rc 0, stdout/stderr пусты. Сверка AST исходной и новой пробы подтвердила неизменность 17 прежних тел, множество всех 89 прежних клеток и всех 57 связей сохранено. Независимый счёт каталогов stabs: 48. Production cleaner базы побайтово равен источнику 196, используемому дифференциально.

Лист с предыдущим вердиктом проверяется на verification-base: одноразовый origin-only клон c71f93117a с наложенными ТОЛЬКО контрактом/семьёй 225 scoped-кандидата, чтобы предыдущий verdict реально находился в HEAD. Производственный код, registry/CI и frozen-текст 196 не меняются. Журналы наблюдений не пишутся в wip; новых незакрытых дефектов процесса сверх заданных блоков не обнаружено.

- К-03 · канон/инструмент · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --delta · 0 · 0
