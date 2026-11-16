КЛАСС РИСКА: рисковый — дверь замка предметов и страж спавна решают, кому разрешён START рабочего, привязка сдачи решает, из какого источника и в какую ветку принимается результат; ошибка открывает спавн не-изолированного рабочего (запись мимо изоляции) или приём сдачи из чужого источника/ветки; основание закрытого перечня: «безопасность/авторизация» (периметр записи станции).

КОНТЕКСТ: слово владельца 2026-11-16 ~20:05 UTC (через консультанта): «Sol в изоляции — старт»; приоритет до 18.11 сверх лимита §Начатое; строка плана 199 влита (#1016), SLOVO записан; номер 199 выдан механизмом next_id.sh (тег id/CONTRACT/199, mint_line, реестр строка 199).
КОНТЕКСТ: источник-разбор `/home/harness/consultant/ISO-PIN-ANALYSIS-ANSWER-1115.md` (§1–§7; вариант А — адрес исполнения отдельно от адреса доставки; §6 — красные проверки); задание `/tmp/dev-harness-verify/orch/task-199-architect.md`; измеренная боль — класс «Г4» от 14.11 (Arch140RaceRepair, Arch187HotfixCoverage, Architect177ArchCI): модель OpenAI в `isolated:true` при внешнем assignment-пине отказывалась писать («запись вне пина запрещена — Н-85»), пачки терялись; квота GLM (текущая модель architect) исчерпывается до конца 18.11 — маршрут ниже становится единственным для роли architect.

## Существующее

Дерево — истина; всё ниже сверено по текущему `origin/main` (967d36c028) и собственному дереву ветки (5db7fe9b24 = main + mint 199; поверхности `.omp/`, `scripts/`, `roles/` побайтно равны origin/main — `git diff --stat HEAD origin/main` пуст на них).

1. **Ядро П1 уже закрыто Пакетом Б** (PR #960, в main; слово владельца 2026-11-15 «пакет Б — да»): `.omp/extensions/path-guard.ts` — ветвь своей изолированной копии (ctx.cwd → JudgeInput.sessionCwd) при ЛЮБОМ пине, с полными условиями М1 037 и реального предка (path-guard.ts:397-404, 982-1008); норма `roles/orchestrator.md:427-428` §«Изолированный спавн» — пин задания есть АДРЕС ДОСТАВКИ, работа и коммиты — только в своей копии, приём — `accept_task_commit.sh`; батарея `fixtures/path_guard/red_own_copy_paket_b.sh` (13 ветвей; прогнана здесь: rc 0). Следствие для конструкции: перенос полей в `TARGET_WORKTREE`/`TARGET_BRANCH` (§5.3-5.4 разбора) НЕ нужен — пара `WORKTREE=`/`BRANCH=` остаётся грамматикой 140 (дверь `zamok_predmeta.sh:386-400`), её смысл в задании — доставка; `grep -rn TARGET_WORKTREE TARGET_BRANCH` по дереву совпадений не даёт.
2. **Остаток §5.5 разбора жив**: `.omp/extensions/spawn-guard.ts:170-190` передаёт двери только `{agent,name,task}` — реальный флаг item.isolated (omp task wire schema, omp://tools/task.md:37,59: поле присутствует у item при `task.isolation.enabled: true`) до двери не доходит; дверь не различает изолированный спавн от слова «isolated:true» в тексте задания. Замер батареей: событие, записанное живым стражем сегодня, поля isolated не несёт (клетки h1-h3 красны до реализации).
3. **Приём из копии сегодня не связан с фактом назначения** (разбор §4, boundaries-проба): `accept_task_commit.sh` судит identity каждого коммита и линейность, но источник/ветка/роль/предмет/корень — свободный текст доклада ребёнка; `--root` вызывающий выбирает сам (разбор §4г); проба границ разбора показала: same-role source чужого предмета принимался в чужую ветку. Порядок диапазона и merge-политика не меняются (клетки соседней батареи `fixtures/accept_task_commit/red_accept_task_commit.sh` — 7 ветвей зелёны здесь).
4. **Канонических процедур нет нигде** (замер grep по `roles/`, `scripts/`, `ops/`): продолжения WIP в копии (синхробаза), приёма из копии (чистота → accept → фиксация tip) и синхронизации носителя после приёма (замер разбора §4б2: linked-носитель после `update-ref` несёт расхождение индекса — «staged D») — проза живёт в докладах, исполнимого канона нет. `ops/server/README.md` не содержит жизненного цикла копий/retention (grep «уборк|очист|cleanup|retention» — 0); шапка `scripts/spawn_agent.sh` не документирует различие доставки/исполнения.
5. **Существующие батареи-соседи** (регрессии, этим контрактом не дублируются): `fixtures/self_contained_cwd/red_self_contained_cwd.sh` (М1; 11 ветвей, зелёна здесь), `fixtures/accept_task_commit/red_accept_task_commit.sh` + `red_porjadok_diapazona_068.sh` (М2/порядок; зелёны здесь), `fixtures/path_guard/red_own_copy_paket_b.sh` (своя копия; зелёна здесь), `fixtures/workshop_project/odin_agent_140/` (дверь 140).
6. **Замороженные соседи**: 012 (изоляция прогонов — `isolated:true` и внешний клон сохраняются, v+1 не нужен), 032 (распознавание пары — не меняется), 037 (ceremony: заявка v+1 ниже), 067 (auto/enabled — не меняется), 104 (алфавит — не меняется), 140 (грамматика рабочих: заявка v+1 ниже), 016 (stdout spawn_agent — API не меняется), 023 (резерв), 128 (wait-guard — не трогаем).

### Заявки v+1 владельцев (условия ленда кода 199; сами v+1 этим контрактом НЕ пишутся)

- **140 v+1** — изменение замороженной грамматики/нормы рабочих (инвариант 2 и 7 frozen 140/3): у рабочего item события спавна обязателен реальный `isolated === true` (источник — нормализация стража спавна из ПОЛЯ item omp-события, НЕ слово в тексте задания; отсутствие/ложь — именованный отказ `NE_IZOLIROVAN` до START и любых записей; на судей требование не распространяется); строка START учёта несёт факт `isolated`. Батарея 140 (`fixtures/workshop_project/odin_agent_140/source.json`) пополняет входы рабочих полем `isolated:true` — до этой миграции дверь 199-семантики краснит старые входы, поэтому ленд кода 199 строго ПОСЛЕ mint 140 v+1. Нужна строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ владельца 140 в предмете v+1.
- **037 v+1** — расширение ceremony М3 (frozen 037, `:480-515`): штатный приём распространяется с голого `_task` на ИЗОЛИРОВАННЫЕ рабочие пачки — каноническая синхробаза копии (блок `199-baza-*`), приём после сверки `scripts/privjazka_sdachi.sh` блоком `199-nositel-*` (чистота носителя ДО приёма → accept_task_commit → фиксация принятого tip → синхронизация носителя), следующий дозвон — от ПРИНЯТОГО tip (cherry-pick меняет sha). Алгоритмы М1/М2 приёмника не меняются. Нужна строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ владельца 037 в предмете v+1.

## Предмет и последовательность

Один наблюдаемый результат: рабочий (architect на `openai-codex/gpt-6.1-sol`) в спавне `isolated:true` с парой `WORKTREE=`/`BRANCH=` в задании пишет и коммитит в СВОЕЙ изолированной копии и сдаёт результат штатным `scripts/accept_task_commit.sh` в `wip/<NNN>/<автор>`; дверь замка не пускает спавн рабочего без реального `isolated:true`; приём связывает сдачу с фактом START замка (роль, ветка, предмет, репозиторий, владелец копии, tip) и выводит корень приёма из факта замка; исполнимые канонические блоки живут в роли и судятся батареей.

Последовательность (порядок — зависимость, не выбор):
1. Владелец: mint 037 v+1 и 140 v+1 (заявки выше) — отдельные предметы со строкой РАЗРЕШИЛ.
2. Implementer: (а) `scripts/zamok_predmeta.sh` — чтение isolated из события, отказ `NE_IZOLIROVAN` для рабочего, факт isolated в START; (б) `.omp/extensions/spawn-guard.ts` — нормализация item проносит `isolated` (=== true) в событие двери; (в) новый `scripts/privjazka_sdachi.sh` — сверка сдачи с фактом START по инвариантам ниже; (г) `roles/orchestrator.md` §«Изолированный спавн» — канонические блоки ДОСЛОВНО из модели-эталона `fixtures/workshop_project/sol_v_izolyacii_199/model/orchestrator_vstavka_199.md` (маркеры `# 199-baza-nachalo/konec`, `# 199-nositel-nachalo/konec`); (д) шапка `scripts/spawn_agent.sh` (документация: stdout — адрес доставки; продолжение WIP — не повторное создание); (е) `ops/server/README.md` — раздел «Жизненный цикл изолированных копий» (retention — решение владельца, автоуборки нет); (ж) регенерация `.omp/agents/orchestrator.md` (`npm run check:gen`).
3. Оркестратор: `gen_ci_steps.sh --write` (шаг батареи 199; до ленда реализации шаг несёт `--stabs`, после — безфлаговый), `--check` rc 0.
4. Судьи по регламенту (класс «рисковый»: адверсарий до ревьюера); живая проба приёмки реализации — реальный спавн рабочего на запасной модели в `isolated:true` с парой в задании: пишет/коммитит в копии, сдача через привязку и блок приёма, принятый tip зафиксирован (закрывает остаток §7.1 разбора — живой М1-канал).

## Инварианты

1. **Дверь** (`scripts/zamok_predmeta.sh`): событие спавна несёт items `{agent, name, task, isolated}`; `isolated === true` только из ПОЛЯ item (omp task wire schema); отсутствие поля и любое иное значение нормализуются в `false` (fail-closed). Рабочий (классы WORKERS frozen 140) с `isolated=false` — именованный отказ `NE_IZOLIROVAN` до START и любых записей; строка START несёт `"isolated":true` для рабочего. Инвариант держится для КАЖДОГО item события, включая пакет с рабочим НЕ первым элементом: отказ на item ≥1 до START и любых записей — в учёте не появляется НИ ОДНА строка пакета (клетки d9-d10: пакет судья + рабочий `iso:false`; пакет двоих рабочих разных предметов, второй `iso:false`). Судьи: флаг записывается фактом события, требование не применяется. Грамматика SUBJECT/OBJECT/пина, алфавит 104, замок/лимиты/ПАУЗЫ/атомарность — без изменений (клетки d5-d8 — регрессии грамматики).
2. **Привязка сдачи** (`scripts/privjazka_sdachi.sh`, новый): вход `--sostojanie D --repo R --subject NNN --source <копия> --branch wip/NNN/<автор> --author <роль> [--tip <40hex>]`; сравнивает с ПОСЛЕДНИМ START рабочего предмета (klass=rabochij) из `D/uchet.jsonl`: rol, branch, грамматика `wip/<NNN>/<автор>` (NNN == предмет), isolated==true, repoId(--repo) == START.repoId, источник — git-репозиторий, `.omp-isolation-owner.json` рядом с копией парсится и его `id` литерально равен START.holder (та же корреляция, что М1 п.5), при `--tip` — HEAD источника равен tip. Все отказы именованные: `SDACHA_NET_START ROL_RASHODITSJA VETKA_RASHODITSJA SUBEKT_VETKI NE_IZOLIROVAN REPO_RASHODITSJA NE_REPO KOPIJA_CHUZHAYA TIP_RASHODITSJA NOSITEL_NEDOSTUPEN`; сравнения только литеральные; успех — rc 0 и ровно одна строка stdout `root=<корень>`; корень приёма ВЫВОДИТСЯ из START.worktree (`git rev-parse --path-format=absolute --git-common-dir` носителя), параметр `--root` вызывающему не принадлежит. Ротация держателя (≥2 строк START рабочего предмета — поддерживаемое состояние append-only учёта): сверка идёт с ПОСЛЕДНИМ фактом — сдача из копии ПРЕЖНЕГО держателя отказывает `KOPIJA_CHUZHAYA`, сдача нового принимается, корень приёма выводится из последнего факта замка, а не из устаревшего носителя (клетки p8-p9: отказ прежнего + честный контроль нового). Приёмник `accept_task_commit.sh` не меняется.
3. **Канонические блоки** (единый источник — `roles/orchestrator.md` §«Изолированный спавн», байты из модели-эталона, маркеры строк-якорей): `199-baza` — синхробаза ребёнка (fetch авторского tip с носителя → `switch -C` → `rev-parse HEAD`; расхождение с ожидаемым — СТОП); `199-nositel` — приём ведущей одним блоком (чистота носителя ДО приёма, иначе отказ без лечения → `accept_task_commit` из копии → фиксация принятого tip → `restore` носителя на tip). Блоки ИСПОЛНИМАЯ часть приёмки: батарея извлекает их из субъекта по маркерам и прогоняет (потребитель роли — приёмка; деградация текста роли видна красным).
4. **Документация**: шапка `scripts/spawn_agent.sh` обязана нести якоря «адрес доставки» и «не повторное создание» (stdout-контракт 016 не меняется); `ops/server/README.md` — раздел «Жизненный цикл изолированных копий» с якорем retention (автоуборка по возрасту не вводится).
5. **Замкнутость свидетельств**: батарея — конечный закрытый набор на объявленные механизмы: 33 клетки (замер по выводу движка), 14 обманных стабов; различимость каждого стаба обеспечивается его клетками на его различающих входах; привязка стаб↔вход — код движка, не проза (Н-39). Оракул каждой клетки — в памяти прогона ДО вызова субъекта (правило 8); миры — вне `${TMPDIR}/tmp/dev-harness-verify` (scratch-allowlist не плацебо).

## Приёмка

Красные прогоны (до реализации, по дереву черновика):
- `bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh` → красная: КРАСНОЕ 199
- `bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh --repo .` → красная: КРАСНОЕ 199

Зелёные контроли (rc 0 всегда):
- `bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh --model`
- `bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh --stabs`

Регрессии соседей (rc 0 и до, и после реализации):
- `bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .`
- `bash fixtures/accept_task_commit/red_accept_task_commit.sh .`
- `bash fixtures/accept_task_commit/red_porjadok_diapazona_068.sh .`
- `bash fixtures/path_guard/red_own_copy_paket_b.sh .`
Якорь порядка «ленд 199 строго ПОСЛЕ mint 140 v+1» (совет 2 вердикта Crit199V1): `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` — на дереве черновика зелёная (замер здесь: `KLETKI 76 KRASNYH 0`), обязана остаться зелёной и после mint 140 v+1, и после ленда 199; красная после ленда 199 = порядок нарушен либо ленд сломал соседа (механический якорь, не проза заявки v+1).

Замеры (пересчитываются гейтом):
замер: `ls fixtures/workshop_project/sol_v_izolyacii_199/stabs/* | wc -l` = 14 census fixtures/workshop_project/sol_v_izolyacii_199/stabs/*
замер: `ls fixtures/workshop_project/sol_v_izolyacii_199/model/* | wc -l` = 5 census fixtures/workshop_project/sol_v_izolyacii_199/model/*

После реализации (гейты ленда, выполняет оркестратор/судьи):
```
bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh          # rc 0 (безфлаговый: субъекты дерева)
bash fixtures/workshop_project/sol_v_izolyacii_199/red_sol_v_izolyacii_199.sh --repo . # rc 0
npm run check:gen                                                                       # rc 0 (регенерация .omp/agents)
bash scripts/gen_ci_steps.sh --check                                                    # rc 0 (шаг 199 подключён оркестратором)
```
Живая проба (шаг 4 последовательности): спавн рабочего `isolated:true` с парой в задании — коммиты в своей копии, сдача через `privjazka_sdachi.sh` + блок `199-nositel`, принятый tip зафиксирован в докладе; красная живой пробы = предмет не принят.

Покрытие §6 разбора (минимум по клетке на строку, счёт по выводу движка): дверь/хук — d1-d10 (d9-d10 — пакет с рабочим НЕ первым элементом), h1-h3; живой файловый путь — f1-f2 (своя копия/основной чекаут) + регрессия red_own_copy_paket_b; М1-границы — f3 (чужой owner) + регрессия red_self_contained_cwd; WIP-продолжение — w1-w2; М2-регресс — c1 (main/файлы неизменны после приёма) + регрессии accept_task_commit/068; caller-привязка — p1-p9 (p8-p9 — ротация держателя); carrier/main — c1-c2; git/изоляция — g1-g2.

## Зоны и проводка

ЗОНА architect: contracts/199-sol-v-izolyacii.md fixtures/workshop_project/sol_v_izolyacii_199/
ЗОНА implementer: scripts/zamok_predmeta.sh scripts/privjazka_sdachi.sh .omp/extensions/spawn-guard.ts scripts/spawn_agent.sh roles/orchestrator.md ops/server/README.md .omp/agents/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 только инварианты 199 (isolated рабочего + START-факт); замок/грамматика пина/лимиты неизменны (140 v+1 — условие ленда, см. Существующее).
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/spawn-guard.ts — 099 только пронос поля isolated в событие двери; алфавит 104 и корни состояний неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/spawn-guard.ts — 104 только пронос поля isolated в событие двери; алфавит 104 и корни состояний неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/spawn-guard.ts — 140 только пронос поля isolated в событие двери; алфавит 104 и корни состояний неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/spawn-guard.ts — 157 только пронос поля isolated в событие двери; алфавит 104 и корни состояний неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 016 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 019 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 023 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 086 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 095 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 103 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 161 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 184 только шапка (документация доставки/продолжения); stdout-контракт 016 и поведение неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 012 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 072 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 074 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 094 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 099 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 104 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 124 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 166 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 167 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 169 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 172 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 182 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 186 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 188 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 998 только §«Изолированный спавн»: канонические блоки 199-baza/199-nositel; прежние нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 074 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 081 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 085 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 093 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 175 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 186 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 189 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 997 только новый раздел «Жизненный цикл изолированных копий»; прежние разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 167 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 169 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 172 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 186 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 188 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 998 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 195 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 197 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 195 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 197 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер шага 199; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 195 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 197 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только сгенерированный шаг 199; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только сгенерированный шаг 199; чужие шаги неизменны.

ПРОВОДКА:
- guard=scripts/zamok_predmeta.sh
- guard=scripts/privjazka_sdachi.sh
- role=roles/orchestrator.md «Изолированный работник пишет и коммитит только в своей копии; перед работой — канонический блок синхробазы (маркеры 199-baza-*); сдача — после сверки scripts/privjazka_sdachi.sh каноническим блоком приёма (маркеры 199-nositel-*): чистота носителя до приёма, accept_task_commit из копии, фиксация принятого tip, синхронизация носителя; следующий дозвон — от принятого tip.»
ПРОВОДКА-ЭНФОРСМЕНТ: дверь замка (NE_IZOLIROVAN, факт isolated в START) и привязка сдачи — чистый энфорсмент (guard-канал); ceremony-блоки — поведенческая норма ведущей сессии (role-канал), их исполнимость судится батареей по маркерам; `--stabs` в CI до ленда реализации, безфлаговый режим после; строку своей батареи подключает оркестратор (`gen_ci_steps.sh --write`, `--check` rc 0), команда шага несёт ногу `bash -n scripts/privjazka_sdachi.sh` — имя guard появляется в ci-steps для guard_is_wired done-гейта (совет 1 вердикта Crit199V1; прецедент 190: registry/ci-steps.tsv:309), чужие строки не меняются.

## Модель угроз

ЗАЩИЩАЕТ:
- От спавна рабочего без реальной изоляции: дверь судит ПОЛЕ isolated события спавна (нормализация стража), отказ NE_IZOLIROVAN до START и любых записей — для КАЖДОГО item, включая пакет с рабочим НЕ первым элементом, без записей пакета в учёт; слово «isolated:true» в тексте задания не имеет силы (клетки d1-d4, d9-d10).
- От потери флага при переносе: страж спавна обязан пронести isolated в событие двери; выпадение или вывод из текста задания различим (клетки h1-h3).
- От приёма чужой сдачи: привязка сверяет роль/ветку/предмет/репозиторий с ПОСЛЕДНИМ START замка, владелец копии — по .omp-isolation-owner.json (id == holder), tip — с диском; корень приёма выводится из факта START, а не выбирается вызывающим; ротация держателя — сдача прежнего держателя отказывает, корень — из последнего факта замка, не из устаревшего носителя (клетки p1-p9).
- От работы на устаревшей базе и от затирания носителя: канонические блоки синхробазы и приёма исполняются и судятся (клетки w1-w2, c1-c2), грязный до приёма носитель — отказ без лечения.
- От регресса периметра записи: своя копия при пине, чужой owner, основной чекаут — клетки f1-f3 (path-guard не меняется этим предметом) + четыре соседние батареи в приёмке; apply:false — g2.

НЕ ЗАЩИЩАЕТ:
- Живой actual/М1-канал сервера этим контрактом не измерён (остаток §7.1 разбора): клетки судят CLI/дверь на toy-мирах; закрывается ЖИВОЙ пробой приёмки реализации (шаг 4 последовательности), не зеленью батареи.
- Изоляция — не OS-песочница: враждебный абсолютный `git -C <основной-чекаут> …` в bash-тексте останется вне охвата path-guard (граница его собственной модели угроз, §7.2 разбора); предмет этого запрета не открывает и не закрывает.
- Identity — метаданные, не удостоверение: М2 ловит неверные an/ae, но не злонамеренное присвоение имени роли; привязка сужает (holder/ветка/репо/tip), окончательная связка назначения — маршрут ведущей сессии и судьи (§7.3).
- Приём не идемпотентен (повтор — отказ cherry-pick), носитель синхронизируется только блоком приёма; «лечить» грязный носитель или повторять приём до зелёного запрещено (§7.4).
- Диск/retention: сотни неубранных копий станций остаются; автоуборка по возрасту НЕ вводится — операционное решение владельца по подтверждённой доставке (§7.5; развилка ниже).
- Судьи и прочие роли: требование isolated касается только рабочих (клетка d5 — граница); kept-alive workspace/plan-mode omp-семантика за пределами предмета.
- Батарея — конечный закрытый набор испытаний на ОБЪЯВЛЕННЫЕ механизмы (33 клетки/14 стабов, счёт по выводу движка), не доказательство эквивалентности произвольной программы; остаток — cognitive-only с ловцами выше.

ПРЕДПОСЫЛКИ:
- setting нужны bash, git, jq, node (проверяются rc 2); новых CI secrets/variables/environments и настроек репозитория не требуется.

## Незаполненные требования:
нет
