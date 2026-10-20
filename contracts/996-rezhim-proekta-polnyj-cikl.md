# Контракт 996 — полный цикл режима проекта без записи в установку харнесса

КОНТЕКСТ: docs/owner/2026-10-17-resheniya-2030.md §1–2 — топология и четыре пункта предмета; §3 — требование к БЭКЕНДУ, не реализация в харнессе.
КОНТЕКСТ: docs/owner/2026-10-17-resheniya-2330.md — пятый пункт, канон источников и обязанности ролей.
КОНТЕКСТ: docs/owner/2026-10-17-plan-stancii.md — слоты, кап 5; ROADMAP.md §12 — зависимости.
КОНТЕКСТ: docs/owner/2026-10-18-arhitektor-beka-5-8-4.md — порядок CMP-BCK-133; статический успех не доказывает HTTP/SQL.

## Существующее

1. `scripts/profile_resolver.sh` (054/057/059) уже объединяет два слоя с происхождением; несёт `git.canonicalRemote` и `workflowPaths.{contracts,verdicts,registry,fixtures}`. Второго резолвера не вводим. `harness.project.json` самого харнесса сейчас несёт `ssh://git@example.invalid/dev-harness.git`: при включении потребления его необходимо заменить действительным каноном, иначе cutover ломает собственный обмен.
2. 103 уже перевёл `make_task.sh`/`spawn_agent.sh` на contracts/registry профиля, добавил `pre_critic --repo`. Он явно НЕ переводил производителей freeze/mint. `freeze_contract.sh:103–106` отвергает вложенные пути, `:209,348,398` читает корневые вердикты, `:444–458` пишет корневой реестр. `done_contract.sh:45–55,73` имеет тот же разрыв. `lib_zones.sh:199` читает frozen-блоб только из корневого contracts. Простая смена имени вердикта не замыкает цикл.
3. `scripts/gitw` (045) судит цели буквально, `GIT_EXCHANGE_GUARD_CANONICAL` — существующий явный override; 071 зовёт предполёт перед push. `next_id.sh` (060) принимает корень проекта, но локальное создание тега ещё НЕ резерв на origin; `mint_line.sh` (068) проверяет origin, сохраняет dual-control и требует настоящий staged-hook. `spawn_agent.sh` уже читает профильный реестр origin/main (103).
4. `workshop` (060/105) экспортирует HARNESS_WORKFLOW_ROOT/HARNESS_TOOLS_ROOT, изолирует HOME и передаёт роли/политику установки. `check_no_leak.sh --snapshot|--check <абс-корень>` судит ровно названное дерево. Для отдельного клона проекта не нужны исключения/ослепление детектора. Роли пока содержат статические HANDOFF/contracts/verdicts и `verdict:`.
5. 994 уже присутствует в дереве этой ветки; правило внешнего CI в `check_provodka.sh` не заменяет реальное подключение СОБСТВЕННОЙ батареи 996 в CI dev-harness. Подсемьи workshop_project уже используют red-пробы/модели, не case-глоб общего анти-плацебо.
6. Read-only снимок Complior-back main f7b972913 предоставлен в `/tmp/dev-harness-verify/c995/back`; просмотрена структура, копия в `/tmp/dev-harness-verify/architect996/back`. Есть `tools/run_backend_ci.py`, документы §3, продуктовые `contracts/` и `db/`; `.harness/` отсутствует. Значит проектные workflow-контракты НЕЛЬЗЯ смешать с продуктовыми contracts. Ни snapshot, ни модель не являются ноутбучной приёмкой.

## Предмет и граница

Один наблюдаемый результат: установленный dev-harness ведёт контракт внешнего репозитория от резерва номера до done, используя origin/пути/канон ПРОЕКТА; установка остаётся неизменной. Пять пунктов решения владельца исполняются вместе. Кап — 3 круга по docs/owner/2026-10-18-tri-slota.md §3; следующий круг критика — третий, FAIL означает STOP и пересмотр через оркестратора, не автоматическое принятие.

В 996 НЕ входят: `tools/check_source_trace.py`, trace-карты CMP-BCK и `required` бэкенда; изменение CAS/потребителей 5.8.4; backend/mobile код; запуск на ноутбуке этой станцией; отключение действующих гейтов для внешнего проекта. Гейт сверки и его controlled command set принадлежат первому БЭКЕНД-контракту. 996 доставляет его команду и обязательность, но не выдаёт заключение о полноте требований за роли.

## Frontier и измеренная боль

| Ось | Выбор и отвергнутая альтернатива | Открытая боль и цена |
|---|---|---|
| Обмен | Эффективный canonicalRemote из существующего resolver; явный env override сохраняет приоритет. Не новый конфиг, не установка env руками для каждого gitw. | Н-163(2), ОТКРЫТО: перенос барьеров не работал вообще; каждый запуск требовал бы разбора по месту. Числа минут для gitw отдельно НЕТ, не выдумываем. |
| Вердикты | Единый профильный контекст, все чтения freeze/done и судьи по verdicts; без fallback на корневую приманку. Не копировать вердикты между деревьями. | Н-163(2), та же блокировка полного переноса; Н-167 Б-1, ОТКРЫТО: ~5 минут + один лишний стартап-проход по чужим файлам. Н-240 — смежный открытый разрыв HEAD, отдельной цены не записано; 996 его не объявляет закрытым. |
| Вторая станция | Независимый git-клон проекта; свои state/registry/forks, резерв на его origin. Не worktree установки и не исключения в leak detector. | Н-167 Б-1/Б-7, ОТКРЫТО: ~5 минут + лишний проход; каждый неприменимый инструмент приходилось исключать вручную. Н-163(2) — неприменимый workflow. |
| Сквозной прогон | Владелец на ноутбуке проходит реальный backend-контракт; сервер даёт инструменты и исполняемые офлайн-пробы. Не выдавать toy за live. | Н-167 Б-2, ОТКРЫТО: 4/5 NOT_RUN, приёмка live недоказана. Это цена непроверенных критериев, не секундомер ноутбука. |
| Канон | Опциональное поле профиля + две обязательные двери + role-каналы; без канона прежнее поведение. Не встроить backend trace-валидатор в харнесс. | Отдельной открытой Н-записи с измеренной ценой именно пропуска КАНОНА не найдено. Новая инициатива по критерию боли НЕ оправдана; здесь основание — прямое поручение владельца 2330, не приписывание Н-163 новой цены. |

РЕШЕНИЕ: не дробить владельческий end-to-end результат на горизонтальные «только профиль/только тесты». Раздать disjoint реализации после общего интерфейса ниже. Если оркестратор требует отдельные done для пакетов, номера выдаёт механизм следующим номером; суффиксы 996a/b не являются идентификаторами. Нельзя объявить весь 996 done по одному пакету.

## Интерфейсы и последовательность

### Общий контекст (пакет A, prerequisite)

`bash scripts/project_workflow.sh --repo R` → rc0, один JSON с абсолютными ключами contracts, verdicts, registry, fixtures, handoff, observations, architectObservations, roadmap, forks; значения первых четырёх из эффективного профиля, остальные из `workflowPaths.state` + фиксированные basename HANDOFF.md/NABLIUDENIA.md/NABLIUDENIA_ARCHITECT.md/ROADMAP.md/forks. Опциональный `state` по умолчанию `.harness`; в профиле самого харнесса ЯВНО `state: "."`. Это не второй профиль: helper вызывает resolver один раз. Все пути проверены на относительность и realpath-вложенность в R; `..`, абсолютный путь или symlink наружу → rc1 с `workflowPaths вне репо`, до записи. Профиль отсутствует в legacy self-вызове → прежняя корневая раскладка; в явном проектном режиме отсутствие профиля — именованный отказ 054, не fallback к установке.

Валидный профиль без новых полей сохраняет прежнее слияние. Неизвестный ключ/неверный тип — отказ resolver. Функции-потребители работают с корнем проекта, а исполняемые файлы берут только из установки. Абсолютный TARGET нормализуется внутри R; basename NNN и теги `id/CONTRACT/NNN`, `frozen/contracts/NNN/v`, `done/contracts/NNN/v` НЕ меняются от расположения каталога.

### Обмен и резерв (пакет B)

Gitw определяет репозиторий тем же git-контекстом, что обмен (`-C`, git-dir/work-tree); канон: непустой явный GIT_EXCHANGE_GUARD_CANONICAL > эффективный `.git.value.canonicalRemote` существующего resolver > прежняя константа ТОЛЬКО при отсутствии профиля в legacy-вызове. Битый существующий профиль — отказ, не fallback. Разбор argv/целей 045, F1/F2/F3, буквальное сравнение и существующий предполёт 071 не меняются. Канон профиля самого харнесса исправляется на `ssh://git@github.com/a3ka/dev-harness.git`.

`bash scripts/reserve_project_contract.sh --repo R` — композиция next_id и gitw: синхронизировать origin, взять номер штатным next_id, опубликовать annotated id-тег non-force на origin проекта, сверить tag-object SHA через ls-remote; stdout только NNN после успешной сверки. Гонка/недоступность → rc1, номер не объявлен выданным; не переносить резерв на origin харнесса. `mint_line --root R` использует профильный registry/contracts.tsv, сохраняя origin membership, чистоту, main и staged-hook. Подключение существующей двери staged к проектному пути обязательно; фиктивный hook=exit0 запрещён. Manifest публикуется на origin проекта до spawn, как в 023. Новый CI-раннер/политика предполёта не вводятся; настоящий CI проекта остаётся обязательным этапом владельческого прогона.

### Lifecycle и канон (пакет C)

Freeze/done принимают профильный contracts, читают ВСЕ вердиктные пути профиля (включая critic-history/cap/arbitration), freeze пишет профильный registry и читает HEAD-блоб `<workflowPaths.registry>/plan.tsv`; закрытия — HEAD-блоб того же профильного `<workflowPaths.registry>/closed-without-done.tsv`, корневой `registry/closed-without-done.tsv` не читается ни прямо, ни через plan_status/p84_p0p1. `lib_plan` получает тот же профильный registry/contracts, без второго формата плана. `lib_zones` ищет frozen-блоб в профильном contracts, сохраняет неизменное пространство тегов. Корневые contracts/verdicts/registry внешнего репо — не запасной источник. Сохраняются грамматика первых строк, история свежести reviewer, отказ до мутаций, spec/consumers/precision/doc/provodka и кап; авторство — identity коммита реестра freeze и mint (orchestrator) и identity зон check_zones/check_staged, второго толкования нет; pre_critic сохраняет также Н-39 и форму КОНТЕКСТ/Существующее. Инвариант одного кода двери: проектная раскладка — параметризация путей в ТОМ ЖЕ коде дверей freeze/done/pre_critic/mint_line/gitw, вторая копия грамматики вердиктов, гейтов, капа, свежести, клапана v>1, проверок чистоты/main не вводится, поведение, не названное в перечне проектных сценариев критерия 6, держат действующие семьи этих скриптов, ловец — reviewer: вторая копия логики в diff пакета B/C = FAIL. В режиме проекта план читает только freeze; check_plan/gen_plan/track_digest проектную раскладку в 996 не получают. Изоляцию установки офлайн-проба судит на freeze и done; для reserve/mint/print-context её принимает ноутбучный `check_no_leak --check`. Смена раскладки не разрешает заморозку незакоммиченного контракта; ancestry-дефект Н-240/241 не объявляется исправленным 996.

Опциональное поле `sourceCanon` репо либо defaults слоя сливается ЦЕЛИКОМ как юнит: `{ "sources": [{"path":"docs/ARCHITECTURE.md","priority":0}], "gate":["python3","tools/check_source_trace.py"] }`. Меньший priority сильнее; равный priority — равноправные источники, конфликт решают роли явно. sources непустой массив уникальных относительных путей существующих файлов внутри R, priority целое ≥0 (bool не целое); gate непустой argv-массив непустых строк без NUL. Закрытые ключи: sourceCanon={sources,gate}, row={path,priority}; неизвестные — SOURCE_CANON_INVALID. Отсутствие sourceCanon — no-op; null/пустой объект — НЕ отсутствие.

Единственный источник грамматики — расширение SCHEMA_LEVELS/проверок действующего resolver; новый consumer не разбирает сырой профиль вторым валидатором. JSON кодирует разделители, сравнение путей/ключей буквально; терминатор — конец единственного JSON-документа, лишний второй документ отвергается. Shell-eval строки/конкатенация argv запрещены.

`bash scripts/check_project_sources.sh --repo R --contract P --stage pre_critic|done` получает эффективный профиль и запускает gate argv с cwd=R; env HARNESS_CONTRACT=P (относительно R), HARNESS_STAGE, HARNESS_HEAD=git HEAD в момент вызова. rc0 — gate rc0; ненулевой → rc1 SOURCE_GATE_FAILED; неисполняемый → rc1 SOURCE_GATE_UNAVAILABLE; отсутствующий источник → rc1 SOURCE_CANON_MISSING. pre_critic и done вызывают ЕГО, не копию логики; done — до тега, pre_critic — до разрешения судьи. Даже при rc2/NOT_RUN проекта дверь закрыта. Без канона gate не запускается. Green на старом HEAD не кешируется как green нового HEAD.

Первый backend-контракт вводит САМ гейт. Если он ещё отсутствует, canon-gate не зелёный: это явный bootstrap-форк, не разрешение выключить проверку. Владелец выбирает последовательность установки bootstrap-гейта и включения sourceCanon до ноутбучного цикла; 996 не приписывает себе разрешение на обход.

### Доставка ролям и изоляция (пакет D)

`workshop`/`make_task` передают вычисленные пути и effective sourceCanon в контекст всех ролей, в том числе судей; прочитанный `verdict:` — suffix роли critic/adversary/review/arbitration, базу задаёт контекст проекта. Стартап и записи HANDOFF/NABLIUDENIA*/ROADMAP/forks направлены в state проекта. Установка read-only для workflow: сессия проекта обновляет только клон проекта и свой сессионный HOME снаружи установки. Резерв проекта и его теги не попадают на origin dev-harness. Детектор сервера по-прежнему судит корень установки; исключений по .harness/projectId не добавлять.

Публичный шов без запуска omp: `bash workshop --print-context R` и `bash scripts/make_task.sh --repo R --role ROLE --print-context` печатают один JSON `{workflow, sourceCanon, verdict, startup}`. workflow — результат project_workflow; sourceCanon — эффективный юнит либо null при отсутствии; verdict — абсолютный каталог суффикса судьи либо null у несудей; startup — упорядоченные абсолютные пути handoff, contracts, verdicts, observations, roadmap. Это тот же контекст, который штатный запуск добавляет в сессионный prompt/задание, не отдельный тестовый расчёт. Режим разрешения контекста не требует omp, ключей провайдера и номера контракта; валидацию профиля/путей не отключает.

Порядок: A фиксирует интерфейс и тестирует resolver → B, C, D параллельно по непересекающимся файлам → одна интеграция оркестратором → пакет E (CI-проводка одним implementer) → суды → ноутбучная приёмка владельца. B не правит resolver, D не правит pre_critic/done; C — единственный владелец их двух изменений. Приёмка B (zones/staged) зависит от lib_zones/lib_plan пакета C: интегрировать C до итогового прогона B. E добавляет продуктовый probe.sh в registry/ci-steps.tsv, ключ package.json и регенерирует workflow штатным gen_ci_steps.sh --write; не копирует YAML вручную.

## Норма-строки

Требует построчной РАЗРЕШИЛ-ВЛАДЕЛЕЦ до freeze; автор 996 не меняет roles/AGENTS.md. Точные строки — единожды в §ПРОВОДКА. После санкции оркестратор под своей identity вносит санкционированные строки в roles/ отдельным общим интеграционным коммитом, до done и проверки check_provodka; это не делегированная зона B/C/D. Строка arbiter об изоляции общая: после санкции дословно помещается также в orchestrator/architect/implementer/critic/adversary/reviewer/consultant/steward; собственные строки о каноне дополняют её, полномочия ролей не меняются. До санкции этот шаг заблокирован, не считается исполненным.

Содержательная полнота карты и следование ролей — cognitive-only: риск неверного толкования ловят critic/adversary/reviewer. Механические пути/rc/HEAD/argv — пробы, не когнитивное обещание. Раздельность B/C/D при общей identity implementer — cognitive-only: check_zones видит объединение, не пакет; остаточный риск чужой правки ловит оркестратор сверкой diff каждого пакета с перечислением файлов перед интеграцией, reviewer проверяет итог.

## Приёмочный критерий

Носитель: `fixtures/workshop_project/rezhim_996/probe.sh`; независимые сценарии `probe.py` используют real git init/commit/tag/push в одноразовых мирах. `model.py` — эталон швов, НЕ полный lifecycle; spec/consumers/precision/doc/provodka вызывает из настоящего HARNESS_TOOLS_ROOT. `plan_adapter.sh` берёт из настоящей lib_plan грамматику плана (plan_parse, массивы P84_ID/P84_PAIR) и моделирует шов C только в источнике закрытий: статус «закрыт без done» вычисляется по HEAD-блобу профильного `<workflowPaths.registry>/closed-without-done.tsv`, корневой файл адаптеру не виден ни прямо, ни через plan_status/p84_p0p1. Оракул refs/HEAD/байтов дерева снимается в память до субъекта. Привязка мутаций только в коде матрицы. Нулевая выборка и неизвестный case отвергаются.

- `bash fixtures/workshop_project/rezhim_996/probe.sh` → красная: 996: проектный цикл не замкнут
- `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix`

1. Дано профильный origin в repo либо defaults; когда gitw push; тогда rc0 и remote ref равен заранее снятому HEAD. Парные чужая цель, origin≠канон и битый профиль: rc1, remote ref отсутствует. При расходящихся профиле и явном override побеждает override. Self-профиль даёт действительный канон харнесса. Legacy-регрессии `bash fixtures/_krasnye_045.sh` и `bash fixtures/_krasnye_071.sh` → rc0 после реализации.
2. Дано контракт и accept в профильной раскладке; когда freeze/done; тогда rc0, тег прежней грамматики в ПРОЕКТЕ, freeze реестр под workflowPaths.registry. Парные FAIL профиля, отсутствие профильного вердикта при accept корня и более свежий FAIL reviewer: rc1 с причиной судьи, HEAD/refs без мутации. История критика accept→FAIL→accept без проектного арбитража: freeze rc1 «кап кругов» даже с арбитражем корня; арбитраж проекта: rc0.
3. Дано отдельный проект; когда project_workflow; тогда rc0 и пути внутри него. Парные `..`/symlink-побег → rc1 workflowPaths вне репо. reserve_project_contract: rc0, stdout NNN, один annotated tag-object локально и на origin. Отказ сервера либо конкурентный tag-object перед публикацией: rc1, stdout пуст, конкурент неизменен. station-isolation запускает freeze И done из disposable HARNESS_TOOLS_ROOT; detector судит ЭТУ установку: rc0 после каждой двери; намеренная канарейка → rc1.
4. Дано sourceCanon и gate-наблюдатель; когда check_project_sources, pre_critic либо done; тогда rc0 и точные cwd/argv/HEAD/stage/contract в свидетельстве gate, у done есть тег. Парные rc7, null/{}, bool priority, повтор пути, NUL argv, отсутствующий файл/команда → rc1 с причиной SOURCE_GATE_FAILED/SOURCE_CANON_INVALID/SOURCE_CANON_MISSING/SOURCE_GATE_UNAVAILABLE, без done-тега. Green HEAD₁→коммит HEAD₂→gate rc7: done rc1 и свидетельство HEAD₂. Без канона → rc0 без запуска. `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc0 до/после расширения; schema self-application — canon-green матрицы.
5. Дано профиль со state и каноном; когда workshop/make_task --print-context для ролей из матрицы; тогда rc0, JSON-пути/канон/startup/verdict равны оракулу проекта, пути установки отсутствуют. Дано frozen профильный контракт с зоной app/; когда lib_zones; тогда rc0 и TSV зоны; check_zones/check_staged: app/ → rc0, outside/ → rc1 «вне зоны» с путём. mint_line с настоящим staged-hook: опубликованный id → rc0, закоммиченная строка только профильного registry под orchestrator; локальный id без origin → rc1 «не выдан авторитетом», HEAD неизменен.
6. Дано проект с accept и одним дефектом действующего гейта; когда соответствующая дверь; тогда rc1 с маркером гейта и неизменными HEAD, refs и байтами дерева. Отдельные сценарии GATE_CASES: freeze — spec, consumers, precision, doc-schema/doc-parser, профильный plan при разрешающей корневой приманке, закрытия плана (закрытие 775 только в корневом `closed-without-done.tsv` → rc1 «вне плана»; то же закрытие в профильном реестре → rc0 и тег), HEAD-блоб плана (незакоммиченная правка плана не открывает), незакоммиченность; done — provodka, consumers, незакоммиченность; грамматика первых строк — freeze-escalate/freeze-ungrammatical/done-escalate/done-ungrammatical: ESCALATE и строка вне {accept, FAIL, ESCALATE} → rc1 с причиной двери, исправление того же входа на `accept` → rc0 и тег; pre_critic — precision, spec, Н-39, КОНТЕКСТ и Существующее при профильном реестре. У каждого отдельное исправление того же входа → дверь rc0 (freeze/done дают тег); отказ по другому гейту не засчитывается. Негативы грамматики явно несут дефект, не объявляются валидными документами. Никакой гейт не подменяется exit-стабом в установке. Перечень «сохраняется → сценарий» (закрыт арбитражем 996, К1–К20; привязка мутант→сценарий — только в коде матрицы, Н-39): К1 профильный contracts → freeze-profile/done-profile, freeze-root-only/done-root-only; К2 вердиктные пути профиля, кап, арбитраж → freeze-decoy/done-decoy/done-fresh, freeze-cap, freeze-root-arbitration/freeze-project-arbitration; К3 реестр freeze закоммичен под orchestrator → freeze-profile (мутанты registry-uncommitted, registry-author-architect); К4 профильный план против корневой приманки → freeze-plan-preserved; К5 план по HEAD-блобу → freeze-head-plan-preserved; К6 закрытия по профильному HEAD-блобу → freeze-closures-preserved (мутант root-closures); К7 check_charter — выведен из 996 (НЕ ЗАЩИЩАЕТ, ловец reviewer); К8 zones/staged/lib_zones по frozen-блобу профильного contracts → zones-project/staged-project/lib-zones-project, zones-green/staged-green; К9 корень — не источник → сумма К1/К2/К4/К6/К8 и mint-project; К10 грамматика первых строк → freeze-escalate/freeze-ungrammatical/done-escalate/done-ungrammatical (мутанты critic-not-fail-is-accept, review-grammar); К11 свежесть reviewer → done-fresh; К12 отказ до мутаций → атомарность каждого негатива (HEAD/refs/байты до/после); К13 spec/consumers/precision/doc/provodka → GATE_CASES этих семейств; К14 авторство → К3 + mint-project + zones-project/staged-project; К15 pre_critic Н-39/КОНТЕКСТ/Существующее → precritic-*; К16 незакоммиченный контракт → freeze-committed-preserved/done-committed-preserved. К17–К20 закрываются инвариантом одного кода двери: К17 gitw — legacy-семьи 045/071/054; К18 клапан v>1 и иные ветви freeze/done — действующие CI-семьи; К19 mint_line чистота/main — mint-project/mint-no-authority; К20 — явный вывод в шве C.
7. Правило подключения: после реализации probe.sh и --matrix → rc0; команда без --model зарегистрирована в registry/ci-steps.tsv и CI dev-harness, `bash scripts/verify_ci_parity.sh` → rc0. Self-probe не заменяет продуктовую команду. Регрессии `bash fixtures/_krasnye_054.sh`, `bash fixtures/_krasnye_103.sh`, `bash fixtures/_krasnye_105.sh` → rc0 после интеграции; `bash scripts/pre_critic.sh --repo . contracts/996-rezhim-proekta-polnyj-cikl.md` → rc0 до критика.

### Приёмка владельца на ноутбуке (обязательна, здесь NOT_RUN)

Дано два независимых клона: обновлённая установка dev-harness и Complior-back с созданным проектом профилем, state `.harness`, каноном 2030 §3, разрешённым bootstrap-решением, рабочим доступом к origin проекта; когда `./workshop <абс-Complior-back>`; тогда профиль/роли и вычисленные пути проекта доступны сессии. На установке перед запуском: `bash scripts/check_no_leak.sh --snapshot <абс-установка>` → rc0.

Владелец проводит первый backend-контракт «гейт сверки с источниками»: reserve_project_contract → профильный mint_line и публикация манифеста → architect карта → pre_critic rc0 → critic accept в verdicts профиля → freeze rc0 → implementer → настоящий CI Complior-back на поставленном SHA → adversary accept → reviewer accept на том же SHA → done rc0. Теги/манифест публикуются gitw на origin Complior-back. Любой FAIL/NOT_RUN сохраняется с этапом/причиной; другой этап его не заменяет. Backend source-trace семантика — 2030 §3 целиком, не урезанная модель 996.

После: `bash scripts/check_no_leak.sh --check <абс-установка>` → rc0; проектные контракты, все четыре вида судейских вердиктов, реестр, HANDOFF/NABLIUDENIA*/forks находятся в `.harness/` проекта; на origin dev-harness нет новых project id/frozen/done тегов. Негатив: намеренная запись канарейки в disposable-копию установки → detector rc1; после отклонённого canon-gate done-тега нет. Для каждого ручного шага запись боли в observations ПРОЕКТА: команда/причина/время начала и конца/цена; ноль ручных шагов фиксируется явно, не отсутствием журнала. Evidence цикла называет pin харнесса, backend SHA, ссылки CI и судей, refs origin, rc детектора. До этого прогона нельзя объявлять закрытым обещание «полный цикл на Complior-back»; офлайн rc0 — готовность механизма, не owner acceptance.

## Демаркация проб

Конформный проект имеет профиль 054/103, самостоятельную .git, git-origin и контракт/вердикты указанной грамматики; sourceCanon соответствует закрытому JSON-алфавиту выше. Негативы грамматики отдельно маркированы: их честный результат — отказ, не исполнение команды. Временные абсолютные корни меняются; валидный контрпример — расхождение на входе объявленной грамматики, инвариантное к именам проекта/путей/источников. Проверяются refs, registry, cwd/argv/HEAD и отказ без тега. station-isolation копирует настоящий runtime (scripts/config/roles и зависимости) с самостоятельной .git, без исторических contracts/verdicts/docs и посторонних тестовых миров; ни один вызываемый инструмент не заменяется. HARNESS_TOOLS_ROOT, исполняемые freeze/done и detector направлены на ОДИН корень. Детектор не ослепляется: судит всё установленное дерево и все новые пути, включая отсутствовавшие при snapshot; внутренние deadlines не меняются. В reserve-race PATH-прокладка только публикует заранее снятый конкурентный tag-object перед настоящим git push, не подменяет результат git. Модели — контрфакты швов, не доказательство реализации полного lifecycle; проверка выдачи контекста — не доказательство чтения его живым агентом. Последнее принимается ноутбучным циклом и судьями cognitive-only.

## Модель угроз

ЗАЩИЩАЕТ:
- от смешения идентичности origin и пространств workflow установки/проекта;
- от чтения корневой приманки вместо проектного вердикта и обхода более свежего отказа;
- от локального номера, объявленного зарезервированным без origin проекта;
- от продолжения pre_critic/done при ненулевом/недоступном gate объявленного канона;
- от shell-интерпретации argv канон-гейта и побега объявленных путей наружу.

НЕ ЗАЩИЩАЕТ:
- от злонамеренного доверенного владельца профиля/исполняемого gate: профиль задаёт код, это не sandbox;
- от неверного смыслового перевода документов в карту, это работа независимых судей;
- от недоступности SSH/CI/ноутбука: это именованный отказ или NOT_RUN, не fake green;
- от дефектов самого backend trace-валидатора, CAS/SQL/HTTP: отдельный backend предмет;
- от всех гонок ФС/смены профиля во время исполнения недоверенным процессом: действующие границы resolver сохраняются, общий sandbox не заявлен.
- от правки замороженного проектного контракта: кольцо устава check_charter в режиме проекта не действует (выведено арбитражем 996, К7); ловец — reviewer сверкой `git diff frozen/contracts/NNN/1 -- <контракт>` до done; остаток принят арбитражем 996;

## Зоны и раздача

ЗОНА architect: contracts/996-rezhim-proekta-polnyj-cikl.md fixtures/workshop_project/rezhim_996/
ЗОНА implementer: scripts/project_workflow.sh scripts/profile_resolver.sh harness.project.json scripts/gitw scripts/reserve_project_contract.sh scripts/next_id.sh scripts/mint_line.sh scripts/check_staged.sh scripts/check_zones.sh scripts/freeze_contract.sh scripts/done_contract.sh scripts/lib_zones.sh scripts/lib_plan.sh scripts/check_project_sources.sh scripts/pre_critic.sh scripts/make_task.sh workshop registry/ci-steps.tsv package.json .github/workflows/ci.yml

A: profile_resolver/project_workflow/harness.project.json. B: gitw/reserve/next_id/mint_line/check_staged/check_zones. C: freeze/done/lib_zones/lib_plan/check_project_sources/pre_critic. D: workshop/make_task. E: registry/ci-steps.tsv, package.json, производный .github/workflows/ci.yml. Расширение раздачи на lib_plan (C) — только профильные пути уже заявленного плана; грамматика и правила 084 не меняются. Все авторы реализации — identity implementer, отдельные клоны/ветки и непересекающиеся перечисленные пути; общий integration owner — orchestrator. E ждёт сборку A–D.

РАБОТА НЕ РАЗДАЁТСЯ: roles/*.md AGENTS.md — требует РАЗРЕШИЛ-ВЛАДЕЛЕЦ; точные строки в §ПРОВОДКА, санкции нет. scripts/check_no_leak.sh — механизм уже достаточен, ослаблять незачем; HANDOFF.md NABLIUDENIA*.md registry/contracts.tsv forks/ — не зона architect этой пачки; Complior-back — код/профиль и ноутбучный прогон принадлежат проектной сессии владельца.

ПЕРЕСЕЧЕНИЕ architect: contracts/996-rezhim-proekta-polnyj-cikl.md — 993 зона contracts/ во внешнем backend контракте; 996 — новый контракт харнесса, не файл backend
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/rezhim_996/ — 054 новая подсемья; прежние фикстуры не меняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/rezhim_996/ — 055 новая подсемья; прежние фикстуры не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 002 только профильные пути; identity и dual-control сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 003 только профильные пути; identity и dual-control сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 047 только профильные пути; identity и dual-control сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/mint_line.sh — 068 профильный registry; origin membership и staged-hook сохраняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 010 доставка проектного контекста, без изменения топологии ролей
ПЕРЕСЕЧЕНИЕ implementer: package.json — 011 добавить только ключ батареи 996; прежние команды сохраняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 015 добавить только ключ батареи 996; прежние команды сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 011 производная регенерация после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 015 производная регенерация после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 994 производная регенерация после записи реестра; шаг 994 сохраняется
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 997 производная регенерация после записи реестра; шаг 997 сохраняется

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «Перед спавном в режиме проекта передай контекст project_workflow и sourceCanon; при объявленном каноне pre_critic и done обязаны вызвать gate профиля на текущем HEAD; ноутбучный полный цикл принимает владелец, NOT_RUN не превращается в done.»
- role=roles/architect.md «При объявленном sourceCanon прочитай источники по приоритету до контракта и включи карту источник@sha256 + раздел → требование → проверка; отсутствие гейта сверки — bootstrap-форк, не зелёная проверка.»
- role=roles/critic.md «При объявленном sourceCanon суди полноту карты контракта против канона и раздела Источники задачи; green команды не заменяет суждение о полноте.»
- role=roles/implementer.md «При объявленном sourceCanon реализуй по канону; отступление допускается только с явной строкой в карте и предусмотренным регламентом решением, не молчаливой заменой источника.»
- role=roles/adversary.md «При объявленном sourceCanon ищи требование канона, пропущенное картой, и предъяви наблюдаемый контрпример.»
- role=roles/reviewer.md «При объявленном sourceCanon сверяй итоговый diff с исходными разделами карты и требуй зелёный gate сверки на текущем HEAD; результат другого SHA не засчитывается.»
- role=roles/arbiter.md «В режиме проекта рабочие артефакты читаются и пишутся только по project_workflow-контексту проекта: HANDOFF/NABLIUDENIA*/ROADMAP/forks — state проекта, контракты/вердикты/реестр — workflowPaths; установка харнесса и её origin не место записей проекта; номер резервируется reserve_project_contract на origin проекта, вердикт своей роли — под workflowPaths.verdicts.»
- guard=fixtures/workshop_project/rezhim_996/probe.sh

ПРОВОДКА-ЭНФОРСМЕНТ: guard — продуктовая батарея 996 в CI dev-harness, обязательное подключение перед done; не внешний CI exception. Поведенческие строки идут только role-каналом после санкции. Команда проекта вызывается check_project_sources через pre_critic/done, не объявляется собственным guard харнесса вместо этой батареи.
замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv
ПОТРЕБИТЕЛЬ fixtures/check_check_contract_ready/: bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_dver.sh
ПОТРЕБИТЕЛЬ fixtures/drill_contract_change/: bash scripts/verify_antiplacebo.sh --scope drill_contract_change
ПОТРЕБИТЕЛЬ scripts/spawn_agent.sh: bash scripts/verify_antiplacebo.sh --scope spawn_agent
ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: bash scripts/verify_antiplacebo.sh --scope check_spec_ready

## Незаполненные требования:
- До freeze/раздачи норм требуется РАЗРЕШИЛ-ВЛАДЕЛЕЦ на перечисленные role-строки; санкции автор не писал.
- До ноутбучного цикла требуется решение владельца о bootstrap канон-гейта.
