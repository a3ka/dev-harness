FAIL
OBJECT=75eb586db0c929cef9c8eeb8d1c814ca73d9b2c1

# Ревью реализации контракта 996 (режим проекта, полный цикл), круг 3 — последний по капу

Ревьюер: Rev996r3 (reviewer). Клон `/tmp/dev-harness-verify/Rev996r3/clone` (ssh-клон origin,
checkout OBJECT, `git status --porcelain` → 0 строк до и после прогонов). Замороженный контракт:
`frozen/contracts/996/1`; `git diff --exit-code 'frozen/contracts/996/1^{commit}' 75eb586db --
contracts/996-rezhim-proekta-polnyj-cikl.md` → rc 0 (контракт не тронут). Предмет круга 3 — коммиты
996 ветки land 75eb586d поверх df5c72b5b: architect 2a97d0106, 3ecfbae4a; implementer 48c05fa53,
4e4b49049, ac8848390, e31d4ef6f, 91f172448, 28db38421, db5259139. (998-коммиты той же land-ветки —
вне этого суда.) Находки reslop: `/tmp/dev-harness-verify/Rev996r3/review.md`. Эксперименты —
одноразовые `/tmp/dev-harness-verify/Rev996r3/exp/{exp.py,exp5.py,exp7.py,exp8.py}` (миры
`probe.world`, real git, настоящие скрипты OBJECT; вне дерева).

## 1. Область правки — ЧИСТО

`git diff --name-only df5c72b5b db5259139` → 7 путей: `fixtures/workshop_project/rezhim_996/{model.py,probe.py}`
(только коммиты architect — ЗОНА architect) и `scripts/{check_project_sources,lib_zones,make_task,next_id,profile_resolver}.sh`
(только коммиты implementer — все в ЗОНА implementer). `git diff --stat df5c72b5b db5259139 -- contracts roles
AGENTS.md fixtures ':!fixtures/workshop_project/rezhim_996'` → пусто (rc 0): frozen-барьеры других
контрактов, roles/, AGENTS.md не тронуты. `bash scripts/check_zones.sh .` → RC=0 (см. Регрессии).

## 2–4. Проверки не переписаны под код; красное предъявлено (своя мера)

- Implementer фикстур не трогал. Оба коммита architect (2a97d0106, 3ecfbae4a — cherry-pick 14:51/14:56)
  — предки первого коммита implementer 48c05fa53. 3ecfbae4a — правка стаба model.py (снятие затенения
  мутанта canon-escape-source), не ослабление клетки продукта.
- Счёт (мой импорт probe.py): до круга (79e43f30c) CASES 88, MUTANTS 63, пар 122; на OBJECT CASES 97,
  MUTANTS 71, пар 131 → +9 клеток, +8 мутантов (заявка «9 клеток, 8 мутантов» верна); 9/9 новых клеток
  покрыты мутантами.
- Красное до реализации: worktree 3ecfbae4a (фикстуры круга 3, скрипты круга 2), `python3 probe.py --case X`
  → rc 1 у 9/9: source-directory-not-file (SOURCE_DIRECTORY_ACCEPTED:sources), resolver-source-relative
  (RESOLVER_SOURCE_PATH_LENIENT), print-context-canon-escape (PRINT_CONTEXT_CANON_ESCAPE_ACCEPTED),
  print-context-escape / workshop-print-context-escape (PRINT_CONTEXT_ESCAPE_ACCEPTED), make-task-pack-project
  (MAKE_TASK_PACK_CONTEXT_MISSING:sourceCanon,SOURCE.md,…), make-task-pack-refusal
  (MAKE_TASK_PACK_REFUSAL_SWALLOWED), structure-one-paths-resolve (STRUCTURE_DUPLICATE_PATHS_RESOLVE),
  structure-no-second-canon-validator (STRUCTURE_SECOND_CANON_VALIDATOR:_keys_ok,_sources_uniq,_gate_clean,keys | sort).
- Зелёное на OBJECT: `bash fixtures/workshop_project/rezhim_996/probe.sh` → RC=0
  `996: examined=97 mutants=0 mismatches=0` (real 22,8 с); `probe.sh --matrix` → RC=0
  `996: examined=97 mutants=71 mismatches=0`.
- Сырой вывод авторов мне не предъявлен; все числа выше — мой прогон.

## 5. Атомарность — принято

9 коммитов, каждый «996: …» с одной правкой; land orchestrator 75eb586d. Замечание: land-ветка
wip/996/implementer несёт и 6 коммитов 998 — посадка стопкой, не смешение внутри коммита.

## 6. Норма — не тронута в диффе 996

`roles/`, `AGENTS.md` в диффе 996 нет (правки roles/{orchestrator,consultant}.md в land — коммит 998 1b81b8574).

## ПРОВОДКА

- guard `fixtures/workshop_project/rezhim_996/probe.sh` подключён (круг 2, не менялся);
  `bash scripts/check_provodka.sh . contracts/996-rezhim-proekta-polnyj-cikl.md` → RC=0.
- role-строки 7/7 на месте (круг 2, a0b28d0f). Строка arbiter об изоляции в 8 ролях
  (orchestrator/architect/implementer/critic/adversary/reviewer/consultant/steward): моя сверка
  `grep -cF 'В режиме проекта рабочие артефакты читаются и пишутся только по project_workflow-контексту проекта' roles/<r>.md`
  → 0/8 (arbiter.md → 1). ПРОВОДКА контракта требует только role=roles/arbiter.md; размещение в 8 ролях
  — §Норма-строки L71, шаг оркестратора под РАЗРЕШИЛ-ВЛАДЕЛЕЦ до done. Это донастройка владельца, НЕ
  блокер реализации (review.md С3-5).

## 7. Закрытие находок круга 2 по существу

| Находка | Состояние | Доказательство (своя мера) |
|---|---|---|
| Р2-1 make_task без канона | ЧАСТИЧНО | exp.py e4: `make_task --kind task` rc 0, секция PROJECT несёт sourceCanon, `source: SOURCE.md`, verdicts, `verdict: …/judgements/review`, contracts, registry, handoff; плацебо `bash "$0" … \|\| true` удалено (ac8848390). Остаток — Р3-1, Р3-2 |
| Р2-2 print-context без гарда | ЧАСТИЧНО | registry-побег: print-context rc 1 (клетки). state-побег: project_workflow rc 1, print-context rc 0 — Р3-1 |
| Р2-3(а) две копии project_paths_resolve | ЗАКРЫТА | grep по всему дереву (кроме .git) форм `name()`/`function name`: 1 определение, `scripts/next_id.sh:333`; lib_zones.sh:51-57 подключает next_id.sh |
| Р2-3(б) второй jq-валидатор | ЗАКРЫТА | блок удалён e31d4ef6f; остаток недостижимых case-строк — С3-2 |
| adversary-1 каталог как источник | ЗАКРЫТА | exp8.py: SRC→symlink на каталог и FIFO → check_project_sources rc 1, pre_critic rc 1 «источник не regular file: SRC» |
| adversary-2 неотносительный путь | ЗАКРЫТА | exp8.py: `/etc/hostname` и `sub/../../outside.md` → resolver rc 1 («path абсолютный»/«path ..»), print-context rc 1; `./SOURCE.md` → rc 0/0 |

## Находки — блокирующие (каждая с ОБХОДОМ и rc)

**Р3-1 (контекст ролей — три расчёта, state не судится, отказ глотается; Р2-2 не закрыта).**
Контракт §D L65: «workflow — результат project_workflow … Это тот же контекст, который штатный запуск
добавляет в сессионный prompt/задание, не отдельный тестовый расчёт. … валидацию профиля/путей не
отключает»; §A L39: «Все пути проверены на относительность и realpath-вложенность в R; … symlink наружу
→ rc1 с `workflowPaths вне репо`». Фрагменты: `make_task.sh:47-112` (ветвь print-context: своя копия
гарда для contracts/verdicts/registry/fixtures, state не проверен, `exit 0` на :112);
`make_task.sh:216-270` (PROJECT-секция: повторный расчёт suffix/state; комментарий :48-50 «Считается
ОДИН раз; ниже используется в --kind task PROJECT-секции» и заголовок 28db38421 «общий расчёт с
--print-context» — заявленное ≠ сделанному: ветвь print-context выходит до секции);
`workshop:903-904` — при отказе `project_paths_resolve` печатает `_pw_json_omitted` и продолжает запуск.
Эксперимент (`python3 exp/exp.py <clone> e1`, `exp5.py`, `exp7.py`), мир probe.world,
`workflowPaths.state = "st"`, `st → <base>/outside`:
```
E1 project_workflow: rc=1 stderr='project_paths_resolve: workflowPaths.state вне репо: st'
E1 make_task --print-context: rc=0 stderr=''
   startup: ['<R>/st/HANDOFF.md', '<R>/.harness/tasks', '<R>/.harness/judgements', '<R>/st/NABLIUDENIA.md', '<R>/st/ROADMAP.md']
E1 workshop --print-context: rc=0 stderr=''
E1 make_task --kind task: rc=0 stderr=''   (задание содержит '<R>/st/HANDOFF.md': True)
E7[state] workshop --probe rc=0 PROBE_OK=True omitted=True stderr_tail='_pw_json_omitted: профиль битый или workflowPaths вне репо'
E7[registry] workshop --probe rc=0 PROBE_OK=True omitted=True …; project_workflow rc=1 'workflowPaths вне репо: registry=esc'
```
ОБХОД: дерево OBJECT, матрица `examined=97 mutants=71 mismatches=0` зелёная (print-context-escape и
workshop-print-context-escape судят только registry, ни одна клетка не судит state и штатный запуск
при побеге), а публичный шов и задание роли отдают HANDOFF/NABLIUDENIA/ROADMAP вне R при rc 0, тогда
как project_workflow rc 1; штатная сессия стартует rc 0 без контекста проекта.
050: свойство — один контекст (§D L65); простейшая форма — make_task и workshop получают контекст ОДНИМ
вызовом `project_paths_resolve` (`NEXT_ID_LIB=1 . next_id.sh`, как уже делает workshop:48-50), rc 1 →
отказ двери, verdict = verdicts + suffix; та же форма проходит клетки context-*, print-context-*,
make-task-pack-*, probe-prompt-project. Текущая форма — ACCIDENTAL (3 места правки одного свойства вместо 1).

**Р3-2 (задание роли вклеивает содержимое источника по symlink вне R).** Контракт: модель угроз
«ЗАЩИЩАЕТ … от … побега объявленных путей наружу»; L53 «sources … существующих файлов внутри R»;
§D — роли получают «вычисленные пути и effective sourceCanon» (не содержимое). Фрагмент:
`make_task.sh` PROJECT-секция (28db38421) `_psrc_content="$(cat "$REPO/$_psrc_path" 2>/dev/null)"` —
`sources[0]` читается без realpath-проверки и печатается в задание.
Эксперимент (`exp.py e2`): freeze rc 0 на честном каноне, затем `SOURCE.md → <base>/secret.txt`
(`OUTSIDE-SECRET-42`), коммит:
```
E2 check_project_sources: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник вне репозитория: SOURCE.md'
E2 make_task --print-context: rc=0
E2 make_task --kind task: rc=0   contains 'OUTSIDE-SECRET-42': True
```
ОБХОД: матрица зелёная (make-task-pack-* судят только иглы и `..`-отказ), а задание роли несёт
содержимое файла вне R при rc 0, где гейт канона того же мира rc 1.
050: свойство «содержимое источника в задании» контрактом не требуется; более простая форма — без
вклейки (строки `sourceCanon:`/`source:` остаются) — проходит make-task-pack-project (иглы sourceCanon,
SOURCE.md, пути). ACCIDENTAL с фрагментом, отсутствующим свойством (вложенность в R) и более простой формой → блокирует.

## Паразитная сложность (050) — по артефактам круга 3

- `scan_canon` + `..`/абсолютный путь (+7, profile_resolver.sh): (1) L53/L55 грамматика в resolver;
  (2) явно — rc 1 «path ..»/«path абсолютный»; (3) 1 файл; (4) глубокий; (5) resolver-source-relative,
  print-context-canon-escape. ESSENTIAL (С3-1: подстрока вместо сегмента).
- `check_project_sources` `-f` (+3): (1) L53 «файлов»; (2) явно — rc 1 «не regular file»; (3) 1;
  (5) source-directory-not-file. ESSENTIAL. Остаток case `/*`,`*..*`,NUL — С3-2.
- удаление jq-валидатора (−26): сокращение; ESSENTIAL.
- перенос `project_paths_resolve` в next_id.sh (+159/−154 в next_id/lib_zones): (1) §A один helper;
  (2) явно — JSON/rc; (3) 1 файл (было 2 — уменьшилось); (4) глубокий; (5) все двери, structure-one-paths-resolve.
  ESSENTIAL. Ленивый source в lib_zones.sh (`NEXT_ID_LIB=1`, `[ -x ]`, `declare -F`-тихий дефолт):
  (2) состояние частично побочное (глобальные NEXT_ID_LIB/SELF_DIR) — совет С3-4.
- гард print-context в make_task.sh (+8): (1) §A/§D; (2) явно rc 1; (3) третья копия гарда — число мест
  выросло; (5) print-context-escape. ACCIDENTAL → Р3-1.
- PROJECT-секция make_task (+57): (1) §D задание ролей; (2) явно в задании; (3) второй расчёт в том же
  файле; (4) мелкий (повтор); (5) make-task-pack-*. Свойство ESSENTIAL, форма ACCIDENTAL → Р3-1;
  вклейка содержимого → Р3-2.
- клетки/мутанты architect (+9/+8, одной семьёй): (1) закрытие Р2/adversary; (2) явно — маркеры;
  (5) probe.sh в CI. ESSENTIAL; структурные мутанты — ветви model.py (С3-6).

## Советы (не блокируют) — см. review.md

С3-1 подстрочный `..` (законный `docs/v1..2.md`: resolver rc 1, модель rc 0); С3-2 недостижимые case-строки
грамматики в check_project_sources; С3-3 ложные комментарии («круг 4», «дубль есть в next_id.sh»,
«Считается ОДИН раз»); С3-4 побочное состояние ленивого source; С3-5 строка arbiter 0/8 — донастройка
владельца; С3-6 узость структурной клетки. Круг 2 С-1…С-7 не адресованы.

## Регрессии (scoped, мой прогон в клоне @ OBJECT)

- `bash scripts/verify_antiplacebo.sh --scope profile_resolver pre_critic done_contract freeze_contract check_zones check_staged check_ids check_hooks check_charter next_id`
  → RC=0 «барьеров: 10 · фикстур: 135 · предъявлено красным повторным прогоном: 135»; `git status --porcelain` → 0 строк.
  (ключи check_precision_gate, mint_line scope_select отверг rc 1 «неизвестный ключ» — не барьеры реестра.)
- `bash fixtures/workshop_project/rezhim_996/probe.sh` → RC=0 `996: examined=97 mutants=0 mismatches=0`.
- `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix` → RC=0 `996: examined=97 mutants=71 mismatches=0`.
- `bash scripts/check_provodka.sh . contracts/996-rezhim-proekta-polnyj-cikl.md` → RC=0.
- `bash scripts/pre_critic.sh --repo . contracts/996-rezhim-proekta-polnyj-cikl.md` → RC=0 «КРИТИК: дверь зелёная».
- `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → RC=0 «итог 4/4 классов закрыто».
- `bash fixtures/_krasnye_054.sh` → RC=0 «итог 054: rc=0».
- `bash fixtures/_krasnye_103.sh` → RC=0 «ИТОГ 103: rc=0».
- `bash fixtures/_krasnye_105.sh` → RC=0 «ИТОГ 105: rc=0».
- `bash scripts/check_zones.sh .` → RC=0 «замороженных контрактов: 107 · объявленных авторов: 5 · коммитов в диапазонах: 17961 · проверено по зонам: 3334».
- `bash scripts/verify_ci_parity.sh` → RC=0 «… matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0».
- `git status --porcelain` клона после всех прогонов → 0 строк.

Регрессии зелёные; Р3-1, Р3-2 — вне покрытия probe 996 (вот почему матрица зелёная), не регрессии.

## Итог

FAIL (круг 3 — последний по капу → форк консультанту): блокирующие Р3-1 (контекст ролей считается
тремя кодами; state-побег: project_workflow rc 1, print-context/задание/штатный запуск rc 0; Р2-2 не
закрыта по существу) и Р3-2 (задание роли вклеивает содержимое источника по symlink вне R при rc 0).
Закрыты: Р2-3(а), Р2-3(б), adversary-1, adversary-2; Р2-1 и Р2-2 — частично. Строка arbiter 0/8 —
донастройка владельца, не блокер реализации.
