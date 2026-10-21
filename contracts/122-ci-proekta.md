# Контракт 122 — CI проекта: генерация workflow из профиля + локальный предполёт + ПРЕДПОСЫЛКИ (id плана `ci-proekta`; CI-Г + CI-предполёт)

КЛАСС ЗАДАЧИ: КОДОВЫЙ (механизм харнесса: генератор + предполёт + гейт; контракт + красная батарея одной пачкой, реализация — implementer).
КОНТЕКСТ: слово владельца 2026-10-18 ~14:30 UTC «сделай так, чтобы таких проблем с CI больше не было» — `docs/owner/2026-10-18-ci-predpolet.md` (ПРОЧИТАН ЦЕЛИКОМ); порядок владельца 2026-10-18 ~15:10 UTC: предполёт НЕ отдельным контрактом, объединён с CI-Г в предмет «CI проекта» (id плана `ci-proekta`), идёт после 996; ADR `docs/owner/adr/2026-10-03-ci.md` этап Г («CI проекта генерируется тем же генератором») и замеры этапа А/Б.
КОНТЕКСТ: строка `registry/plan.tsv` `ci-proekta` (пара 5, зависит от 114 — DONE) уже в main; номер 122 выдан механизмом (тег `id/CONTRACT/122`).

## Существующее (сверено живьём 2026-10-21, дерево — истина)

1. **`scripts/gen_ci_workflow.sh`** существует (063): пишет джобу `harness` в workflow репо проекта, источник `harness.project.json`; режим проекта 996 убирает межрепозиторную выгрузку — этот генератор НЕ трогаем (его джоба — обмен харнесса, не CI проекта).
2. **`scripts/gen_ci_steps.sh` + `registry/ci-steps.tsv`** (083, заморожено): грамматика lanes/step/shard/uchet/legkij для СОБСТВЕННОЙ джобы ci харнесса; `verify_ci_parity.sh` (инвариант 3), веса `registry/ci-zamery.tsv` (114). Не расширяются (замороженные инварианты 083/114).
3. **`scripts/profile_resolver.sh` + `scripts/project_workflow.sh`** (103/112/996): эффективный профиль проекта, `workflowPaths.*`, projectId; Граница-1 059 (сверка workflowPaths с деревом) — не здесь. Резолвер НЕ расширяется (условие раздачи).
4. **`scripts/pre_critic.sh`** (072/103): флаг `--repo R` уже есть; поля `ПРЕДПОСЫЛКИ:` сегодня не существует нигде: `grep -rn "ПРЕДПОСЫЛКИ" scripts/ contracts/ roles/` — 0 вхождений (замер 2026-10-21). `scripts/freeze_contract.sh` — гейтов предпосылок нет.
5. **`scripts/ci_preflight.sh`, `scripts/gen_project_workflow.sh`, `scripts/check_predposylki.sh`** — ОТСУТСТВУЮТ (`ls scripts/` замерен) — предмет новый, не починка.
6. Прецеденты батареи: `fixtures/workshop_project/import315_119/` (раннер/модель/оракул/стабы, --model без сети), `rezhim_996/` (probe о docker-free мирах), `fixtures/check_provodka/external_ci_994/` (self-wiring по реестру).

## Боль (измеренная)

- **Н-311** (NABLIUDENIA.md, ОТКРЫТО, адрес — этот предмет): CI-обвязка `mobile.yml` пилота 995 не прогонялась до PR — **4 круга Impl995Fix1–4, все 4 о `.github/workflows/mobile.yml`, 5 прогонов CI подряд, ~1 ч (13:26→14:24 UTC 2026-10-18)**; e2e стоял, пока владелец не завёл секрет. Дословный разбор — `docs/owner/2026-10-18-ci-predpolet.md` (working-directory, копия вне песочницы, lint видит `.harness/`, незаведённый `PILOT_DEMO_CODE`).
- **Н-318**: Impl995Fix6 не прогнал полный e2e в предполёте — CI упал 3/3 на голове, которая «должна была» быть зелёной.
- **Н-306** (ОТКРЫТО): implementer-пачка с правкой CI не проходит PR-CI сама — нет порядка локального предполёта workflow до PR.
- CI-цена ожидания: Н-210 (флейк-отмены), Н-380 (~29–35 мин на коммит устав-пути). Прогон workflow до PR дешевле круга правки: каждая из 4 ошибок 995 была видна локально ДО пуша.

## Frontier (нарезка/выбор)

- **(A) Предполёт через `act` в docker** (буквальный пример владельца) — ОТКАЗ как обязательный: тянет docker-зависимость в каждый предполёт, а этап А ADR требует полного прогона ≤ 6 мин; battery-режим обязан быть без docker. **(Б) Прямой прогон шагов в одноразовой копии** — ВЫБРАН: шаги `run:` исполняются `bash -c` в копии репо, секреты — заглушки; `act` остаётся допустимой реализацией внутри интерфейса (контракт судит rc-интерфейс, не движок).
- **(В) Проектный CI-реестр в грамматике 083 (TSV lanes/step/…)** — ОТКАЗ: расширяет замороженную грамматику 083 на второй потребитель. **(Г) Проектный манифест `.harness/ci.json`** (JSON, замкнутый алфавит: schemaVersion/projectId/jobs{key:{class∈{local,station},workdir,steps[{key,run}]}}) — ВЫБРАН: проектный файл, профиль не расширяется, 083 не трогается.
- **(Д) Проверка ПРЕДПОСЫЛКИ внутри freeze_contract монолитом** — ОТКАЗ: freeze тяжёлый, батарея потянет всю машину. **(Е) Отдельный гейт `scripts/check_predposylki.sh`, вызываемый pre_critic (без --freeze) и freeze (с --freeze)** — ВЫБРАН (прецедент-шов 103: отдельная нога у потребителя).
- **ВОЛЯ ВЛАДЕЛЬЦА (не решаю, вопрос в докладе):** какой проект первым переводится на генерацию — Complior-back (lane CI уже механический: `tools/run_backend_ci.py`, боли 109/115/121) или Complior-mob (mobile.yml, боли 995/117, но нужен класс station с эмулятором). Рекомендация: **Complior-back** — меньше станционной обвязки, lane-грамматика уже существует.

## Предмет и инварианты

Один наблюдаемый результат: **workflow CI проекта генерируется из проектного манифеста `.harness/ci.json`, прогоняется локальным предполётом до push, а контракт, меняющий CI проекта, не проходит pre_critic/freeze без полного поля `ПРЕДПОСЫЛКИ:`; всё это исполнимо красной батареей `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh` → rc 0 после реализации (сегодня rc 1, субъектов нет)**.

- **Г1 Генерация (CI-Г, боль Н-311):** `bash scripts/gen_project_workflow.sh --repo R (--check|--write)`. Источник — `<R>/.harness/ci.json` (замкнутый алфавит выше; `class` ∈ {local,station}; `run` — однострочная команда). `projectId` манифеста обязан равняться projectId профиля `<R>/.harness/harness.project.json` (единственный источник identity — без расширения резолвера). `--write` пишет `<R>/.github/workflows/ci.yml` детерминированными байтами (заголовок-маркер «GENERATED by dev-harness gen_project_workflow — не править руками», concurrency cancel-in-progress, каждая джоба несёт `env.PREFLIGHT_CLASS: <class>`). `--check` — побайтовое сравнение: ручная правка = дрейф. Отказы: manifest-otsutstvuet, manifest-nevaliden, profil-otsutstvuet, profil-rashozhdenie, workflow-otsutstvuet, workflow-ruchnoj.
- **Г2 Предполёт (боль Н-306/Н-318):** `bash scripts/ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C]`. Судит ЛЮБОЙ workflow-файл (рукописной mobile.yml тоже): YAML валиден (yaml-nevaliden); каждая джоба/шаг `working-directory` существует в репо (working-directory-otsutstvuet — боль 995 п.1); джобы `PREFLIGHT_CLASS: local` (умолчание для рукописных) исполняются в одноразовой копии R (без мутации R): каждый шаг `bash -c`, падение = shag-upal: <job>/<step>; `${{ secrets.X }}`/`${{ vars.X }}` заменяются заглушками (X ∈ [A-Z][A-Z0-9_]*) и при `--contract C` каждый обязан быть объявлен в `ПРЕДПОСЫЛКИ:` C (sekrety-ne-perechisleny: X — боль 995 п.4); джобы `station` (эмулятор/облако — боль 117) НЕ исполняются, перечисляются строкой `STATION-JOB: <key>`. Честный конец: `CIPREFLIGHT_OK jobs=<n> station=<m>` rc 0.
- **Г3 ПРЕДПОСЫЛКИ (норма владельца «Что делаем» п.1):** `bash scripts/check_predposylki.sh <R> <контракт> [--freeze]`. Контракт, текст которого заявляет CI-пути (литеральные `.github/workflows/` или `.harness/ci.json`), обязан нести поле `ПРЕДПОСЫЛКИ:` (маркер в первой колонке, тело до первой пустой строки) с пунктами замкнутой грамматики `- secret NAME` | `- variable NAME` | `- environment NAME` | `- setting <текст>`; нарушения: predposylki-otsutstvuyut, predposylki-nevaliden. `--freeze`: каждый secret/variable обязан существовать в репо проекта (`gh secret|variable list -R <origin>`); отсутствует = sekrety-ne-zavedeny: NAME; gh отсутствует или сломан = gh-nedostupen (fail-closed, не молчание). Контракт без CI-путей поля не требует (z5). Подключение: pre_critic — вызов без --freeze, freeze_contract — с --freeze; их существующая грамматика/порядок проверок не меняются.

Замкнутый алфавит причин — 16: manifest-otsutstvuet, manifest-nevaliden, profil-otsutstvuet, profil-rashozhdenie, workflow-otsutstvuet, workflow-ruchnoj, gen-nedeterminirovan, yaml-nevaliden, working-directory-otsutstvuet, shag-upal, sekrety-ne-perechisleny, predposylki-otsutstvuyut, predposylki-nevaliden, sekrety-ne-zavedeny, gh-nedostupen, python-yaml-nedostupen (средовая ветвь rc 2, клеткой не покрыта — PyYAML обязана быть в окружении). Клетками покрыто 15.

## Конструкция батареи (носитель — fixtures/workshop_project/ci_proekta_122/)

Раннер `red_ci_proekta_122.sh` (мир-фабрика в /tmp/dev-harness-verify/ci122: мини-репо проекта с `.harness/{harness.project.json,ci.json}`, `mobile/`, той-контракты, фикстурный `bin/gh` с инвентарём `gh.tsv`; диспетчер **23 клетки**: k×5 честные, z5, g1–g7, p1–p5, z1–z4), модель `model/` (честные `gen_project_workflow.sh`, `ci_preflight.sh`, `check_predposylki.sh` — bash+python3-stdlib+PyYAML, без сети/docker), стабы `stabs/` (5). Ожидания — литералы в коде диспетчеризации (Н-39: вход↔ветвь держит код, не проза), оракул-сверка в памяти проверяющего, миры одноразовые, пустая выборка = rc 2 с числом просмотренного.

Клетки → ветви: g1 нет манифеста; g2 class вне алфавита; g3 ручная правка workflow (rc 1 + `--write` восстанавливает байты — двойная мера rc+sha256); g4 недетерминизм (два --write, cmp); g5/g6 чужой/отсутствующий профиль; g7 --check без файла; p1 сломанный YAML; p2 несуществующий working-directory; p3 падающий шаг; p4 station-джоба пропускается с маркером; p5 секрет вне ПРЕДПОСЫЛОК; z1 CI-контракт без поля; z2 незаведённый секрет; z3 сломанный gh; z4 пункт вне грамматики; k/z5 — честные миры (отрицательные пары).

Обманные стабы (Н-39, каждый к своей наблюдаемой ветви): `stab_gen_postojannyj.sh` (генератор-пустышка, всегда rc 0 — ловится g1/g3-серией и каскадом k/p: 14 красных); `stab_preflight_tolko_sintaksis.sh` (полусмотр — YAML проверяет, шаги/пути/секреты нет; ловится p2/p3/p4/p5: 4 красных); `stab_predposylki_slepoy.sh` (гейт-слепой rc 0; ловится z1–z4: 4 красных); `stab_vsegda_zelenyj.sh`/`stab_vsegda_krasnyj.sh` (0 зелёных из 23 оба — причина-литерал обязана совпасть).

## Приёмочный критерий (команды, rc; замеры 2026-10-21 из worktree ветки)

1. `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh` → сегодня **rc 1, «клеток 23, зелёных 0, красных 23»** (субъекты `scripts/{gen_project_workflow,ci_preflight,check_predposylki}.sh` отсутствуют — замер снят); после реализации implementer → **rc 0, «клеток 23, зелёных 23, красных 0»**.
2. `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` → **rc 0, клеток 23, зелёных 23, красных 0** (замер: 23/23, ~1 с; без сети/docker/эмулятора).
3. `bash … --cell net-takoj` → **rc 2** (замер: rc 2, перечень клеток в stderr); `bash … --model --cell p3` → rc 0, зелёных 1 (замер).
4. Стабы (все rc 1, замеры): `CI_PROEKTA_122_GEN=<батарея>/stabs/stab_gen_postojannyj.sh bash … --model` → «зелёных 9, красных 14»; `CI_PROEKTA_122_PREFLIGHT=…/stab_preflight_tolko_sintaksis.sh` → «19/4»; `CI_PROEKTA_122_GATES=…/stab_predposylki_slepoy.sh` → «19/4»; все три `stab_vsegda_zelenyj.sh` → «0/23»; все три `stab_vsegda_krasnyj.sh` → «0/23».
5. После реализации: `bash scripts/gen_project_workflow.sh --repo <R> --check` зелёнен только при байтовом равенстве (клетки g3/g4 — двойные меры rc+cmp/sha256); `bash scripts/ci_preflight.sh --repo <R>` на клоне проекта с рукописным workflow — rc 0 `CIPREFLIGHT_OK` (та же грамматика, что у сгенерированного).
6. `bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md` → rc 0 «КРИТИК: дверь зелёная»; `bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md` → rc 0; `bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md` → rc 0 (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 5) — замеры 2026-10-21; `bash scripts/check_provodka.sh "$PWD" contracts/122-ci-proekta.md` → сегодня rc 1 «guard не подключён» (ожидаемо до интеграционного коммита, см. ПРОВОДКА-ЭНФОРСМЕНТ), после него rc 0.

## Зоны и раздача

ЗОНА architect: contracts/122-ci-proekta.md fixtures/workshop_project/ci_proekta_122/
ЗОНА implementer: scripts/gen_project_workflow.sh scripts/ci_preflight.sh scripts/check_predposylki.sh scripts/pre_critic.sh scripts/freeze_contract.sh
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 122 ТОЛЬКО вставка вызова check_predposylki без --freeze; существующие ноги, их порядок и грамматика 072/103/996 не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 122 ТОЛЬКО вставка вызова check_predposylki с --freeze после существующих проверок; существующие инварианты заморозки (013/027/036/038/043/060/078/084/992/996) не меняются

Норм-строки role-канала (дословные тексты в следующем абзаце) и step-строка батареи в реестре НЕ входят в зону этой пачки: норма владельца уже действует cognitive (слово 2026-10-18 п.1 «действует сразу, cognitive до механизма»); проводка дословных норм-строк в roles/*.md и step-строки `check:ci-proekta-122-family-selftest` в registry/ci-steps.tsv — ДВА отдельных интеграционных коммита оркестратора ЗА реализацией (прецедент интеграционных коммитов 994 п.5, 119); зоны интеграционных коммитов объявляют они сами. ПРОВОДКА этого черновика — guard-канал.

Норм-строки role-канала (дословно): architect — «Контракт, меняющий CI-workflow проекта (.github/workflows/, .harness/ci.json) или требующий секретов/variables/environments/настроек репозитория, несёт поле ПРЕДПОСЫЛКИ: с полным списком; проверяет scripts/check_predposylki.sh (слово владельца 2026-10-18).»; implementer — «Перед сдачей работы, меняющей workflow проекта, прогоняю scripts/ci_preflight.sh --repo <одноразовая копия> до зелёного; зелёный предполёт — часть приёмки (слово владельца 2026-10-18).»; orchestrator — «Не пушу PR проекта без предъявленного предполёта и не замораживаю контракт с незаведёнными секретами/variables: check_predposylki.sh --freeze (слово владельца 2026-10-18).»

Замороженные соседи не ломаются: 083/114 (реестр/веса харнесса не трогаются), 087 (лёгкий класс — вне), 994 (пров external CI — наш guard подключается по тому же прецеденту), 103/112/996 (profile_resolver/project_workflow/workflowPaths не расширяются; манифест — отдельный файл `.harness/ci.json`), 997/998 (не пересекаются).

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh

ПРОВОДКА-ЭНФОРСМЕНТ: красная батарея «CI проекта» — единственный guard 122 (guard-канал); режим --model самодостаточен (миры в /tmp/dev-harness-verify, без сети/docker/эмулятора/продукта) и подключается в CI харнесса по прецеденту 996-E/119 (npm-ключ + step-строка реестра, шаг `check:ci-proekta-122-family-selftest` = `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model`) оркестратором отдельным интеграционным коммитом ЗА реализацией; до него `check_provodka` rc 1 «guard не подключён» — не блокер и не приёмка красного. Поведенческая норма ПРЕДПОСЫЛКИ уже действует cognitive (слово владельца 2026-10-18 п.1); её role-строки (дословные тексты в «Зоны и раздача») проводятся вторым интеграционным коммитом оркестратора за реализацией — здесь NOT_RUN; гейт-энфорсмент Г3 несут сами вызовы pre_critic/freeze_contract скрипта scripts/check_predposylki.sh.

## Модель угроз

ЗАЩИЩАЕТ:
- от ручных правок workflow проекта (боль Н-311: 4 круга, ~1 ч): побайтовый дрейф-контроль генератора + заголовок-маркер (g3);
- от запуска непроверенного CI на GitHub (боль Н-306): предполёт исполняет local-шаги в одноразовой копии ДО push, каждая ошибка видна локально именованной причиной;
- от «зелёного» предполёта, который ничего не исполняет (пустышки второго порядка): поведенческие клетки p3 (падающий шаг), p2 (путь), p4 (station-маркер), стаб-ловли 4/19 клеток;
- от незамеченных предпосылок репо (боль 995 п.4): грамматика ПРЕДПОСЫЛКИ + gh-сверка fail-closed (z2/z3), контракт без поля не проходит pre_critic (z1);
- от подмены проекта: projectId манифеста = projectId профиля (g5), манифест вне алфавита = отказ (g2);
- от недетерминированной генерации: cmp двух прогонов (g4).

НЕ ЗАЩИЩАЕТ:
- от содержательной верности САМИХ команд CI проекта (что делает `npm test` — судят lane-тесты проекта, не предполёт; предполёт доказывает исполнимость окружения, не семантику);
- от станционных прогонов (эмулятор/облако): class station пропускается локально и перечисляется — их честность отдельный станционный прогон, здесь NOT_RUN;
- от дрейфа секретов ПОСЛЕ предполёта (сверка на момент freeze; следующий контракт проверяет заново);
- от злонамеренного субъекта, распознающего пробы батареи и несущего честную логику только для них (строго сложнее честного — ловец ревью кода и судьи реализации, cognitive-only);
- от отсутствия PyYAML в окружении (средовая ветвь python-yaml-nedostupen rc 2 — заявлена, не скрыта).

## Демаркация

Конформный мир: git-репозиторий проекта с `.harness/harness.project.json` (projectId) и, для генерации, `.harness/ci.json` замкнутого алфавита; workflow — сгенерированный либо рукописный YAML с джобами/шагами. Конформный субъект: генератор пишет детерминированные байты из манифеста; предполёт на честном мире даёт rc 0 `CIPREFLIGHT_OK`, на каждом неконформном входе — rc 1 со своей именованной причиной; гейт требует ПРЕДПОСЫЛКИ только у CI-контрактов и fail-closed на gh. Валидный контрпример = инвариантность к значениям (имена секретов, ключи джоб, тексты команд) ∧ расхождение на КОНФОРМНОМ входе замкнутого алфавита; контрпример вне грамматики (двоичный workflow, secrets вне `[A-Z][A-Z0-9_]*`) — неконформен и не обязан краснеть своей причиной.

## NOT_RUN (граница этого контракта)

- Живой перевод Complior-back/Complior-mob на генерацию (какой первым — вопрос владельцу, см. Frontier/доклад) и их merge — не здесь.
- Реальный gh/GitHub приёмкой не вызывается (батарея — фикстурный gh); станционные прогоны class station (эмулятор, `sg kvm`) — отдельный станционный прогон по образцу Н-318, не батарея.
- `act`/docker-движок предполёта — допустимая реализация внутри интерфейса Г2, приёмкой не различается (rc-интерфейс).
- Проводка `check:ci-proekta-122-family-selftest` в реестр/ci.yml — оркестратор, интеграционным коммитом за реализацией; wiring lane продукта — консультант/владелец.
- CI-Б (087) и граф затронутых (CI-В) — соседние предметы ADR, не трогаются.
