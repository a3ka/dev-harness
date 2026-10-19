FAIL
OBJECT=698060db450009698b3b9946552429a41f405871

# Ревью реализации контракта 996 (режим проекта, полный цикл), круг 2

Ревьюер: Rev996r2 (reviewer). Клон `/tmp/dev-harness-verify/Rev996r2/clone` (ssh-клон origin, checkout
OBJECT). Замороженный контракт: `frozen/contracts/996/1`; `git diff frozen/contracts/996/1^{commit} HEAD --
contracts/996-rezhim-proekta-polnyj-cikl.md` → пусто (контракт не тронут). Предмет круга 2: merge
698060db = 3fc36e86 + ветка {2631be2d architect «красные клетки круга судей 1», 0939a103 implementer
«правка реализации по судьям круга 1»}. Находки reslop: `/tmp/dev-harness-verify/Rev996r2/review.md`
(материализует оркестратор в `.review/`). Эксперименты — одноразовые `/tmp/dev-harness-verify/Rev996r2/exp/{exp.py,x5.py,x6.py}`
(миры `probe.world`, настоящий git, настоящие скрипты OBJECT; вне дерева, не тесты).

## 1. Область правки — ЧИСТО

Своя мера: каждый путь `git diff --name-only` сверен с префиксами строк ЗОНА frozen-блоба (shell-цикл).
- 2631be2d (architect): `fixtures/workshop_project/rezhim_996/{model.py,probe.py,probe.sh}` — 3/3 в ЗОНА architect.
- 0939a103 (implementer): package.json, registry/ci-steps.tsv, scripts/{check_project_sources,check_staged,
  check_zones,done_contract,freeze_contract,lib_zones,mint_line,next_id,profile_resolver,project_workflow}.sh,
  scripts/gitw, workshop — 14/14 в ЗОНА implementer.
- `git diff --stat 3fc36e86 698060db -- contracts/ roles/ AGENTS.md fixtures/ ':!fixtures/workshop_project/rezhim_996'` → пусто:
  frozen-барьеры других контрактов не тронуты.
- `bash scripts/check_zones.sh .` → RC=0 «замороженных контрактов: 107 · … проверено по зонам: 3205».

## 2–4. Проверки не переписаны под код; красное предъявлено (своя мера)

- Implementer фикстур не трогал (п.1). Новые клетки — коммит architect 2631be2d, родитель коммита implementer.
- Новых сценариев 13 (CASES 75→88, MUTANTS 56→63, пар мутант→клетка 122 — мой подсчёт импортом probe.py).
- Красное на 2631be2d (до реализации), `python3 probe.py --case X` по каждой новой клетке:
  11/13 rc=1 — resolver-canon-extra-key, resolver-canon-fraction (RESOLVER_CANON_GRAMMAR_ABSENT),
  gate-path-argv0 (CANON_GATE_PATH_UNAVAILABLE), defaults-null-canon (DEFAULTS_NULL_CANON_TREATED_ABSENT),
  source-symlink-escape (CANON_SOURCE_ESCAPE_ACCEPTED), freeze-paths-escape (DOOR_ESCAPE_REFUSAL_MISSING),
  freeze-broken-profile (BROKEN_PROFILE_ROOT_FALLBACK), freeze-root-contract/done-root-contract
  (ROOT_CONTRACT_ACCEPTED), gitw-cwd-canon (GITW_CWD_CANON_IGNORED), probe-prompt-project
  (PROBE_PROMPT_CANON_MISSING); 2/13 зелёные уже до реализации (source-traversal-escape,
  done-broken-profile) — регрессионные закрепки, мутанты к ним есть. `bash probe.sh` на 2631be2d →
  RC=1 «npm-ключ check:rezhim-996-family-selftest отсутствует…».
- Зелёное на OBJECT: `bash fixtures/workshop_project/rezhim_996/probe.sh` → RC=0
  `996: examined=88 mutants=0 mismatches=0` (real 21,0 с); `probe.sh --matrix` → RC=0
  `996: examined=88 mutants=63 mismatches=0`.
- Правки architect не ослабляют прежние клетки: model.py — вынос той же грамматики в canon_invalid +
  новые мутанты; probe.py — только добавленные клетки и расширенные кортежи мутантов.
- Сырой вывод авторов мне не предъявлен; все числа выше — мой прогон.

## 5. Атомарность — принято

Два коммита, каждый «996: …», один предмет; land orchestrator 698060db.

## 6. Норма — не тронута в диффе

`roles/`, `AGENTS.md` в диффе круга 2 нет. Семь role-строк ПРОВОДКА внесены отдельно коммитом
a0b28d0f (owner, форк n996-role-stroki-razreshil) — дословное совпадение 7/7 (python-сверка строк
frozen-блоба с `roles/*.md`).

## ПРОВОДКА

- guard `fixtures/workshop_project/rezhim_996/probe.sh` — подключён: `registry/ci-steps.tsv:124`
  `step check:rezhim-996-family-selftest 20 npm run check:rezhim-996-family-selftest`, `package.json:83`
  → `bash fixtures/workshop_project/rezhim_996/probe.sh` (продуктовый режим), ключ в matrix
  `.github/workflows/ci.yml:284`. Guard — барьер именно этого предмета.
- role=7 строк — на месте (см. п.6). `bash scripts/check_provodka.sh . contracts/996-…` → RC=0.
- К done (не против implementer): §Норма-строки требует дословно поместить строку arbiter об изоляции
  ТАКЖЕ в orchestrator/architect/implementer/critic/adversary/reviewer/consultant/steward — моя сверка 0/8.

## 7. Закрытие находок круга 1 (`.review/2026-10-19-02.md`) по существу

| Находка | Состояние | Доказательство |
|---|---|---|
| Б-1 argv[0] через PATH | ЗАКРЫТА | gate-path-argv0 красная на 2631be2d → зелёная |
| Б-2 грамматика в resolver | ЧАСТИЧНО | resolver: evil/0.5 → отказ (клетки красн.→зел.); второй jq-валидатор `check_project_sources.sh:89-115` остался — Р2-3 |
| Б-3 null в defaults | ЗАКРЫТА | defaults-null-canon красн.→зел. |
| Б-4 symlink-источник | ЗАКРЫТА | source-symlink-escape красн.→зел. |
| Б-5 двери без гарда | ЗАКРЫТА для freeze/done/zones/staged/mint | freeze-paths-escape, freeze-broken-profile красн.→зел.; X3 (мой): verdicts→symlink наружу: done rc 1 «workflowPaths вне репо: verdicts=escape», тегов нет, HEAD неизменен; check_zones rc 1, check_staged rc 1 |
| Б-6 корневой contracts/ | ЗАКРЫТА | freeze/done-root-contract красн.→зел.; `plans/` — С-2 |
| Б-7 штатный контекст ролей | ЧАСТИЧНО | промпт workshop --probe — есть; штатное задание make_task — нет; плацебо `bash "$0" … || true` на месте — Р2-1 |
| Б-8 gitw без -C | ЗАКРЫТА для cwd/GIT_DIR | gitw-cwd-canon красн.→зел.; `-C <подкаталог>` — С-1 |
| Б-9 одна копия контекста | ЧАСТИЧНО | двери зовут одну функцию, но она в двух побайтных копиях; print-context — третий расчёт без гарда — Р2-2, Р2-3 |
| adversary-1 (symlink/..) | ЗАКРЫТА | source-symlink-escape/source-traversal-escape + мутант canon-escape-source |
| adversary-2 (npm-ключ) | ЗАКРЫТА | package.json:83; `npm run --silent check:rezhim-996-family-selftest` — см. регрессии |

## Находки — блокирующие (каждая с ОБХОДОМ и rc)

**Р2-1 (Б-7 не закрыта для make_task).** Контракт §D: «`workshop`/`make_task` передают вычисленные пути и
effective sourceCanon в контекст всех ролей, в том числе судей; прочитанный `verdict:` — suffix роли …,
базу задаёт контекст проекта … Это тот же контекст, который штатный запуск добавляет в сессионный
prompt/задание, не отдельный тестовый расчёт». Роли спавнятся по заданию make_task
(`roles/orchestrator.md:173` «Задание — только дверью: перед спавном make_task --kind task --contract <NNN>»).
Эксперимент X2 (`exp.py x2`): проект с каноном (`SOURCE.md`, `.harness/*`), freeze rc 0 →
`make_task.sh --repo R --role reviewer --kind task --contract 777 --task-file F --model-trace T` → rc 0;
в задании: `sourceCanon` False, `SOURCE.md` False, `<R>/.harness/judgements` False,
`<R>/.harness/judgements/review` False, `<R>/.harness/tasks` False, `<R>/.harness/HANDOFF.md` False —
тогда как `make_task --print-context` того же мира печатает `verdict = <R>/.harness/judgements/review`.
`make_task.sh:50-52` — `bash "$0" … >/dev/null 2>&1 || true` (полный прогон штатной ветви с выброшенным
результатом) остался.
ОБХОД: probe-prompt-project судит только промпт оркестратора (`workshop --probe`), context-* — только
JSON `--print-context`; судьи и прочие роли, спавнимые заданием make_task, канона и проектного
каталога вердиктов не получают, а матрица зелёная.

**Р2-2 (print-context — отдельный расчёт без гарда путей).** Контракт §A: «Все пути проверены на
относительность и realpath-вложенность в R; `..`, абсолютный путь или symlink наружу → rc1 с
`workflowPaths вне репо`»; §D: «workflow — результат project_workflow … Режим разрешения контекста …
валидацию профиля/путей не отключает». `make_task.sh:56-106` пересчитывает раскладку из resolver
сам, без realpath-проверки; `workshop --print-context` делает exec той же ветви (`workshop:594`).
Эксперимент X1 (`exp.py x1`): `workflowPaths.registry = "escape"`, `escape → <base>/outside` (symlink):
`project_workflow.sh --repo R` → rc 1 «project_paths_resolve: workflowPaths вне репо: registry=escape»;
`make_task.sh --repo R --role reviewer --print-context` → rc 0, `"registry": "<R>/escape"`;
`workshop --print-context R` → rc 0, тот же JSON.
ОБХОД: paths-symlink/paths-escape судят только project_workflow, context-* — только мир без побега;
публичный шов §D печатает ролям путь вне репо при rc 0.

**Р2-3 (вторые копии логики пакета B/C; 050 ACCIDENTAL).** Контракт L51: «вторая копия логики в diff
пакета B/C = FAIL» (ловец — reviewer); L55: «Единственный источник грамматики — … resolver; новый
consumer не разбирает … вторым валидатором».
(а) `project_paths_resolve` — две побайтные копии: `scripts/next_id.sh:330` (пакет B) и
`scripts/lib_zones.sh:153` (пакет C), по 108 строк, sha256 тела у обеих
a8e188e8fcb17430725fd58b205170b1687c699ebecd477d87dc0fa3d3770116; комментарий сам называет вторую
«те же строки (дословно)». Правка раскладки/гарда обязана менять 2 файла синхронно (было 7 — лучше,
но не одна).
(б) jq-валидатор алфавита sourceCanon `check_project_sources.sh:89-115` оставлен рядом с новым
`scan_canon` resolver; он недостижим (resolver отказывает раньше) и слабее (нет проверки целого
priority) — мёртвая вторая грамматика.
Фрагмент — выше; отсутствующее свойство — один код контекста/грамматики (L51, L55); более простая
форма — одна функция в одном файле, подключаемом и next_id-, и lib_zones-потребителями (если toy-миры
фикстур verify_antiplacebo копируют только один из файлов — это фикстуры вне ЗОНА implementer, путь —
форк оркестратору, не копия), и удаление блока 89-115: те же строки приёмки проходят (resolver
отказывает раньше, двери зовут ту же функцию).

## Паразитная сложность (050) — строка на новый/раздутый артефакт круга 2

- `scan_canon` в profile_resolver.sh (+146): (1) L41/L55 грамматика юнита в resolver; (2) явно — rc/stderr
  SOURCE_CANON_INVALID; (3) 1 файл — но см. Р2-3(б): вместе с ним живёт 2-я грамматика; (4) глубокий;
  (5) resolver-canon-*, defaults-null-canon. ESSENTIAL.
- `project_paths_resolve` ×2 (next_id.sh, lib_zones.sh): (1) §A общий контекст; (2) явно — JSON/rc;
  (3) 2 файла синхронно; (4) глубокий; (5) все двери, project_workflow. ESSENTIAL как функция,
  ACCIDENTAL как копия — Р2-3(а).
- project_workflow.sh (−70, обёртка): (1) §A CLI; (2) явно; (3) 1; (4) глубокий; (5) paths*, reserve. ESSENTIAL.
- gitw формы env/cwd (+22): (1) L45; (2) явно — канон из GIT_DIR/GIT_WORK_TREE/show-toplevel; (3) 1;
  (5) gitw-cwd-canon. ESSENTIAL (остаток — С-1).
- check_project_sources PATH-резолв argv[0] (+20): (1) L53 форма gate; (2) явно; (3) 1; (5) gate-path-argv0. ESSENTIAL.
- workshop блок промпта (+28) и source next_id.sh: (1) §D; (2) явно в промпте; (3) 1; (5) probe-prompt-project. ESSENTIAL.
- npm-ключ + гард ключа в probe.sh (+26, architect): (1) §Порядок «ключ package.json»; (2) явно — rc 1;
  (4) мелкий гард (С-5); (5) CI-шаг. ESSENTIAL.
- ветви LEGACY-FALLBACK без jq (`_jesc`/printf) в функции и `if [ ! -f harness.project.json ]` в
  check_zones/check_staged: (1) прежняя раскладка без профиля (L39); (2) явно; (3) 2+2 места;
  (5) antiplacebo ap-миры. Совет: `_jesc` sed экранирует пары `\\`, а не одиночный `\` — безвредно
  только при путях без `\`/`"`.

## Советы (не блокируют)

- С-1. X5 (`x5.py`): `gitw -C <R> push origin …` → rc 0; `gitw -C <R>/app push origin …` → rc 1
  «URL origin не канонический» (канон-константа установки); cwd `<R>/app` → rc 0. `-C` не нормализуется
  до toplevel, как форма cwd.
- С-2. X6 (`x6.py`): при объявленном профиле freeze корневого `plans/777-toy.md` → rc 0,
  `frozen/plans/777/1` (`freeze_contract.sh:167`, `done_contract.sh:89`).
- С-3. `check_zones.sh:1047-1050` комментарий «минт-recognition использует ПРОФИЛЬНЫЙ реестр… Профильный
  путь — $_PROFILE_REGISTRY_FILE», а условие `:1051` — литерал `registry/contracts.tsv` (заявленное ≠
  сделанному; минт-коммит проектного реестра судится как обычный путь).
- С-4. `lib_zones.sh:296`: битый профиль → zones_load молча берёт корневой `contracts/`
  (check_precision_gate/land_agent/check_no_leak зовут zones_load без отказа check_zones).
- С-5. Гард npm-ключа в probe.sh: любая команда с подстрокой пути батареи и rc 2 на
  `--case __no_such_case__` проходит; `bash -c "$_cmd …"` — shell-eval строки package.json.
- С-6. resolver: `priority` 1.0 / 1e400 проходят `floor == .` (модель отвергает 1.0 как не int).
- С-7. Вес CI-шага 20 при моём замере продуктового probe.sh 21,0 с.
- С-8. Архитектору: нет клетки на задание make_task (Р2-1) и на print-context при побеге (Р2-2).
- Круг 1 С1/С2/С3/С4/С6 не адресованы (вне блокирующих).

## Регрессии (scoped, мой прогон в клоне @ OBJECT)

- `bash fixtures/workshop_project/rezhim_996/probe.sh` → RC=0 `996: examined=88 mutants=0 mismatches=0` (21,0 с).
- `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix` → RC=0 `996: examined=88 mutants=63 mismatches=0`.
- `npm run --silent check:rezhim-996-family-selftest` → RC=0 `996: examined=88 mutants=0 mismatches=0`.
- `bash fixtures/_krasnye_045.sh scripts/gitw` → RC=0 «итог: 1 файлов, провалов 0»; без аргумента → RC=1
  usage (дефект текста контракта, круг 1 С4, не регрессия).
- `bash fixtures/_krasnye_071.sh` → RC=0 «честные клетки: 41/41 зелёные; стаб-пак 21/21 + дифф 21/21».
- `bash fixtures/_krasnye_054.sh` → RC=0 «итог 054: rc=0».
- `bash fixtures/_krasnye_103.sh` → RC=0 «ИТОГ 103: rc=0».
- `bash fixtures/_krasnye_105.sh` → RC=0 «клеток просмотрено: 5 … ИТОГ 105: rc=0».
- `bash scripts/verify_ci_parity.sh` → RC=0 «… matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0».
- `bash scripts/gen_ci_steps.sh --check` → RC=0.
- `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → RC=0 «итог 4/4 классов закрыто».
- `bash scripts/pre_critic.sh --repo . contracts/996-rezhim-proekta-polnyj-cikl.md` → RC=0 «КРИТИК: дверь зелёная».
- `bash scripts/check_provodka.sh . contracts/996-rezhim-proekta-polnyj-cikl.md` → RC=0.
- `bash scripts/check_zones.sh .` → RC=0 (п.1).
- `bash scripts/verify_antiplacebo.sh --scope freeze_contract done_contract check_zones check_staged pre_critic profile_resolver`
  → RC=0 «барьеров: 6 · фикстур: 99 · предъявлено красным повторным прогоном: 99» (дерево чистое, `git status --porcelain` → 0 строк).

Регрессии зелёные; Р2-1…Р2-3 — вне покрытия probe 996 и действующих барьеров (вот почему матрица зелёная), не регрессии.

## Итог

FAIL: три блокирующие находки Р2-1 (make_task не несёт контекст проекта ролям — Б-7 не закрыта),
Р2-2 (print-context печатает путь вне репо при rc 0, где project_workflow rc 1), Р2-3 (вторые копии
логики контекста/грамматики в пакетах B/C, L51). Б-1, Б-3, Б-4, Б-5, Б-6, Б-8, adversary-1/2 закрыты
по существу; Б-2, Б-7, Б-9 — частично.
