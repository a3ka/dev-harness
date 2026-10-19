FAIL
OBJECT=6d00deb681e0b70cad17147674bd120b6c2cccd4

# Ревью реализации контракта 996 (режим проекта, полный цикл), круг 1

Ревьюер: Rev996 (reviewer). Замороженный контракт: `frozen/contracts/996/1` → commit 3719ad5d,
блоб `contracts/996-rezhim-proekta-polnyj-cikl.md` = a062045b. Дифф реализации: 3af8f6b4b..6d00deb68
(10 коммитов implementer + land orchestrator). Находки в формате reslop: `.review/2026-10-19-02.md`
(в клоне ревьюера `/tmp/dev-harness-verify/Rev996/clone`, коммит под identity reviewer, sha — в докладе).
Одноразовые эксперименты: `/tmp/dev-harness-verify/Rev996/exp/exp{,2,3,4}.py` (вне дерева, не тесты).

## 1. Область правки — ЧИСТО

- `git diff --stat 3af8f6b4b 6d00deb68` → 18 файлов, +874 −65; все 18 входят в «ЗОНА implementer»
  замороженного блоба. `package.json` в диффе нет (bash-шаг реестра npm-ключа не требует, см. С5).
- Н-332: `registry/harness-project.json` менялся в f1a12ab3 и откачен 9c6cff37; нетто-дифф по нему пуст
  (в `--stat` отсутствует). Ни один коммит диапазона не трогает `fixtures/` или `contracts/`
  (`git log --name-status 3af8f6b4b..6d00deb68`) — cherry-pick архитекторского коммита нет.
- Авторы: 10 коммитов `implementer <implementer@dev-harness.local>`, land — `orchestrator`.

## 2–4. Проверки не переписаны; красное предъявлено своей мерой

- Дерево `fixtures/workshop_project/rezhim_996` = 438cd6aa на 6d00deb68, на 3af8f6b4b, на
  `frozen/contracts/996/1` и на `origin/wip/996/architect` (1228d6f6). 847e7f07 (fe39be44) — более
  ранняя архитекторская редакция до микро-круга К1–К20 (критик принял 1228d6f6, frozen-коммит
  3719ad5d называет OBJECT=1228d6f6); дифф 847e7f07..1228d6f6 — только архитекторские правки, до freeze.
- Блоб контракта на 6d00deb68 побайтно равен frozen (`git diff --quiet frozen/contracts/996/1 6d00deb68 -- contracts/996-…` rc 0).
- Красное: `probe.sh` на 3af8f6b4b → rc 1, `examined=75 mutants=0 mismatches=63`, «996: проектный цикл не замкнут».
- Зелёное: `probe.sh` на 6d00deb68 → rc 0, `examined=75 mismatches=0`; `probe.sh --matrix` → rc 0,
  `examined=75 mutants=56 mismatches=0`. Числа контракта/критика (75 сценариев, 56 мутантов) совпадают с моим прогоном.
- Сырой вывод автора мне не предъявлен (только сводка оркестратора «CI 16/16»); все числа выше — мой прогон.

## 5. Атомарность — принято

Один предмет (996), 10 коммитов со ссылкой «996:», каждый — свой шаг; связки чужих задач нет.

## 6. Норма — не тронута

`roles/*.md`, `AGENTS.md` в диффе нет. `grep -c 'sourceCanon|project_workflow' roles/{orchestrator,architect,critic,implementer,adversary,reviewer,arbiter}.md` → 0 во всех семи.

## ПРОВОДКА

- guard=`fixtures/workshop_project/rezhim_996/probe.sh` — ПОДКЛЮЧЁН: `registry/ci-steps.tsv:125`
  `step check:rezhim-996-family-selftest 20 bash fixtures/workshop_project/rezhim_996/probe.sh`
  (продуктовый режим, без `--model`), ключ попал в matrix `.github/workflows/ci.yml:280`. Guard —
  барьер именно этого предмета.
- role=roles/{orchestrator,architect,critic,implementer,adversary,reviewer,arbiter}.md — 7 строк НЕ
  внесены, ждут РАЗРЕШИЛ-ВЛАДЕЛЕЦ (форк `forks/n996-role-stroki-razreshil.md`). Это блокирует только
  done, не реализацию — находкой против implementer не считаю.

## 7. Реализованность §Предмет: пункт → место в коде → наблюдение

| Пункт | Место | Наблюдение |
|---|---|---|
| A project_workflow | scripts/project_workflow.sh | работает, гард `..`/symlink есть (X1: rc1 «workflowPaths вне репо»); но двери его НЕ зовут — Б-5 |
| A sourceCanon в resolver | scripts/profile_resolver.sh (SCHEMA_LEVELS: только ветвь) | грамматика юнита вынесена из resolver — Б-2 |
| B gitw канон профиля | scripts/gitw:111-150 | только при `-C`/`--git-dir`; cwd-контекст игнорирован — Б-8 |
| B reserve | scripts/reserve_project_contract.sh | rc0/NNN/annotated/ls-remote — есть; локальный тег при отказе — С2 |
| B mint/zones/staged | mint_line.sh, check_zones.sh, check_staged.sh | профильный реестр — есть; копия резолв-блока — Б-5/Б-9 |
| C freeze/done | freeze_contract.sh, done_contract.sh | профильные вердикты/реестр/кап/арбитраж — есть; молчаливый откат на корень и корневые contracts/ — Б-5, Б-6 |
| C lib_plan/lib_zones | lib_plan.sh (LIB_PLAN_REGISTRY), lib_zones.sh | есть |
| C check_project_sources + двери | check_project_sources.sh; pre_critic.sh (д); done_contract.sh | есть, но Б-1…Б-4 |
| D доставка ролям | workshop, make_task.sh | только `--print-context`; штатный запуск контекст НЕ несёт — Б-7 |
| E CI | registry/ci-steps.tsv, ci.yml | есть |

## Находки — блокирующие (каждая с ОБХОДОМ)

**Б-1. Канон-гейт не исполняет argv контрактной формы.** `check_project_sources.sh:147-152`:
относительный `argv[0]` склеивается с R (`cmd0="$REPO/$gate0"`), PATH не используется. Контракт
(§Lifecycle, L53) задаёт форму `"gate":["python3","tools/check_source_trace.py"]`. Эксперимент E1:
gate `["python3","gate.py"]` → rc 1 `SOURCE_GATE_UNAVAILABLE: python3 не исполняем`; E1b тот же gate
с `/usr/bin/python3` → rc 0, gate исполнен.
ОБХОД: probe объявляет gate абсолютным `sys.executable`, поэтому все canon-* зелёные, а канон в
замороженной форме (и бэкенд-гейт 2030 §3) на pre_critic/done всегда красный — ноутбучный цикл
непроходим без переписывания профиля под дефект.

**Б-2. Грамматика sourceCanon не в resolver; второй валидатор в потребителе.** Контракт L41
«Неизвестный ключ/неверный тип — отказ resolver», L55 «Единственный источник грамматики — расширение
SCHEMA_LEVELS/проверок действующего resolver; новый consumer не разбирает … вторым валидатором».
Реализация: `profile_resolver.sh` (коммент к scan_levels: «дополнительные ключи отвергаются
check_project_sources.sh, а не profile_resolver») + jq-валидатор в `check_project_sources.sh:96-118`.
E5: `sourceCanon` с лишним ключом `evil` → resolver rc 0, project_workflow rc 0,
`make_task --print-context` rc 0 и выдают `{"…","evil":1}` ролям; отказ только в check_project_sources.
E2: `priority: 0.5` (контракт: «priority целое ≥0») → resolver/project_workflow/print-context rc 0 И
check_project_sources rc 0 с исполнением gate (валидатор проверяет лишь `type == "number"`).
ОБХОД: probe проверяет невалидный канон только через двери (sources/pre_critic/done) и только
bool/дубль/NUL/неизвестный ключ; дробный priority проходит везде, невалидный юнит доставляется ролям rc 0.

**Б-3. `sourceCanon: null` в defaults-слое трактуется как отсутствие.** Контракт L53: поле «репо
либо defaults слоя … null/пустой объект — НЕ отсутствие». `check_project_sources.sh:78-91` читает
СЫРОЙ `$REPO/harness.project.json` (только репо-слой). E4: defaults `{"sourceCanon": null}` →
check_project_sources rc 0, gate не запущен; resolver/project_workflow/print-context — `sourceCanon: null`.
ОБХОД: canon-null probe кладёт null только в репо-слой; null в слое проекта открывает pre_critic/done без гейта.

**Б-4. Источник канона — symlink наружу R принимается.** Контракт L53 «существующих файлов внутри R»;
модель угроз ЗАЩИЩАЕТ «от … побега объявленных путей наружу». `check_project_sources.sh:125-137` —
только `-f` и текстовые `/*`, `*..*`. E3: `LINK.md → ../outside.md` в sources → rc 0, gate исполнен.
ОБХОД: probe не содержит symlink-источника; канон, ссылающийся на файл вне репо, зелёный.

**Б-5. Двери читают workflowPaths своей копией резолв-блока: нет гарда побега, молчаливый откат на
корень.** freeze_contract.sh:89-105, done_contract.sh:46-62, check_zones.sh:353-363,
check_staged.sh:151-161, mint_line.sh:178-188, lib_zones.sh:149-161 — один и тот же блок
`if _pr_out=$(profile_resolver …); then … fi` без else и без realpath-проверки; project_workflow.sh
(«ЕДИНСТВЕННЫЙ печатник путей», с гардом) ни одной дверью не вызывается. Контракт L39 («symlink
наружу → rc1 … до записи»; «в явном проектном режиме отсутствие профиля — именованный отказ 054, не
fallback»), L51 («Корневые contracts/verdicts/registry внешнего репо — не запасной источник»,
«отказ до мутаций»).
X1: `workflowPaths.registry` — symlink на каталог вне репо; project_workflow rc 1 «workflowPaths вне
репо», а freeze: тег `frozen/contracts/777/1` создан, файл `OUTSIDE/contracts.tsv` ЗАПИСАН вне репо,
затем rc 1 «pathspec … beyond a symbolic link» (тег остался).
X2: профиль битый (лишний ключ `bogusKey`; project_workflow rc 1 «неизвестный ключ репо-слой»),
корневая приманка `contracts/777-toy.md` + `verdicts/critic/contracts-777-v1.md: accept` → freeze rc 0,
`frozen/contracts/777/1`, записан и закоммичен корневой `registry/contracts.tsv`.
ОБХОД: paths-escape/paths-symlink в probe судят только project_workflow; freeze/done/zones/mint
пишут по пути вне репо и при битом профиле работают по корневой раскладке.

**Б-6. freeze/done принимают корневые `contracts/` и `plans/` при объявленном профиле.**
freeze_contract.sh:133-134, done_contract.sh:73-74 (`contracts/*) _accepted=1`). Существующее 6:
у Complior-back продуктовые `contracts/`, «проектные workflow-контракты НЕЛЬЗЯ смешать». X3: валидный
профиль (`contracts=.harness/tasks`), контракт перенесён в корневой `contracts/777-toy.md` → freeze
rc 0, `frozen/contracts/777/1`. Следствие (exp4): check_zones по этой заморозке rc 1 «контракт не
объявил ни зон» — lib_zones ищет только профильный каталог, хотя ЗОНА объявлена.
ОБХОД: freeze-root-only проверяет лишь корневой ВЕРДИКТ; корневой файл контракта (продуктовый) замораживается.

**Б-7. Штатный запуск не доставляет контекст ролям; `--print-context` — отдельный расчёт.**
Контракт §D (L63-65): «workshop/make_task передают вычисленные пути и effective sourceCanon в контекст
всех ролей … Это тот же контекст, который штатный запуск добавляет в сессионный prompt/задание, не
отдельный тестовый расчёт». make_task.sh:47-107 — ветвь `--print-context` считает пути заново и
`exit 0`; вне ветви 0 упоминаний sourceCanon/project_workflow (`awk 'NR>110' make_task.sh | grep -c` → 0).
workshop:885-895 пишет в промпт лишь R1-R3. exp3 (`workshop --probe <проект с каноном>` → `PROBE OK`):
промпт сессии не содержит `sourceCanon`, `SOURCE.md`, `.harness/judgements`, `.harness/tasks`,
`<R>/.harness` (все False). Плюс make_task.sh:50-52 — `bash "$0" … >/dev/null 2>&1 || true`:
полный прогон штатной ветви с выброшенным результатом — плацебо «того же контекста».
ОБХОД: context-* сценарии probe смотрят только JSON `--print-context`; роли в реальной сессии
путей проекта, канона и базы вердикта не получают.

**Б-8. gitw берёт канон профиля только при `-C`/`--git-dir`.** gitw:111-148: без них `__PR_REPO`
пуст → прежняя константа dev-harness даже при профиле в cwd. Контракт L45: «Gitw определяет репозиторий
тем же git-контекстом, что обмен (`-C`, git-dir/work-tree)»; прежняя константа «ТОЛЬКО при отсутствии
профиля». X4: проект с профилем (canonicalRemote = origin), `gitw push origin main` из cwd проекта →
rc 1 «URL origin не канонический»; с `-C` — канон принят (дальше предполёт). Роли зовут `gitw push`
без `-C` (roles/orchestrator.md:122,277,400; consultant.md:116). Окружение `GIT_DIR`/`GIT_WORK_TREE` (cwd вне
проекта) → тоже rc 1 «URL origin не канонический»; `--git-dir=<R>/.git` → канон принят (дальше
предполёт) — прогон exp-gitdir.
ОБХОД: git-* сценарии probe всегда передают `-C root`; штатное `gitw push` из клона проекта судится
каноном установки (отказ своему origin; origin=URL dev-harness прошёл бы как «канонический» — [INFERENCE] по коду gitw:150, сетью не прогонял).

**Б-9 (050, ACCIDENTAL).** Фрагмент: шесть копий блока резолва workflowPaths (Б-5) + повторный
расчёт путей в make_task --print-context + `bash "$0" … || true`. Отсутствующее свойство: единый
контекст с гардом realpath и отказом при битом профиле (L39, L51 «вторая копия логики в diff пакета
B/C = FAIL»). Более простая форма: двери и print-context берут пути из одного вызова
`scripts/project_workflow.sh --repo R` (существующий интерфейс пакета A, уже проходит paths/
paths-escape/paths-symlink/context-*); при отказе — отказ двери. Те же строки приёмки проходят,
Б-5 закрывается. Число файлов, меняемых вместе при правке раскладки: 7 вместо 1.

## Паразитная сложность (050) — строка на артефакт

- project_workflow.sh (новый): (1) §A общий контекст; (2) явно — argv/stdout JSON; (3) 1 файл;
  (4) глубокий: 1 флаг → вся раскладка+гард; (5) потребитель — paths*, reserve. ESSENTIAL. Но не
  потреблён дверями (Б-9).
- reserve_project_contract.sh (новый): (1) §B резерв на origin; (2) явно — stdout NNN, rc; побочно
  остаётся локальный тег при отказе (С2); (3) 1; (4) 1 флаг; (5) reserve-*. ESSENTIAL. Повторно
  зовёт и project_workflow, и resolver (двойной резолв) — совет.
- check_project_sources.sh (новый): (1) §C дверь канона; (2) явно — rc/маркеры; плюс скрытое чтение
  сырого harness.project.json; (3) грамматика канона в 2 местах (resolver-ветвь + jq здесь) — выросло;
  (4) 3 флага; (5) canon-*, pre_critic/done. ESSENTIAL как дверь, ACCIDENTAL как второй валидатор — Б-2/Б-3.
- make_task `--print-context`, workshop `--print-context` (флаги): (1) §D публичный шов; (2) явно;
  (3) раскладка дублирована с project_workflow — выросло; (4) мелко: флаг возвращает пересчёт,
  не штатный контекст; (5) context-*. ACCIDENTAL в части дубля и `bash "$0"` — Б-7/Б-9.
- Шесть копий резолв-блока в дверях: (1) §C/§B параметризация путей; (2) неявно — молчаливый откат;
  (3) 7 файлов вместе; (4) мелко; (5) повторяет project_workflow. ACCIDENTAL — Б-9.
- env `LIB_PLAN_REGISTRY` (новая читаемая env): (1) К6 профильные закрытия; (2) неявно — export из
  freeze наследуется потомками; (3) 2 файла; (4) мелко; (5) freeze-closures-preserved. Совет С6:
  передавать аргументом plan_status/p84_closed_reason.
- SCHEMA_LEVELS `workflowPaths.state`, ветвь `sourceCanon`: (1) §A; (2) явно; (3) 1; (5) paths, canon-*.
  ESSENTIAL (но содержимое юнита не валидируется — Б-2).

## Советы (не блокируют)

- С1. `check_project_sources.sh:130` `*..*` отвергает законный `a..b.md` (E6: rc 1 «.. в пути»); проверять сегмент `..`.
- С2. reserve: при отказе публикации/гонке локальный `id/CONTRACT/NNN` остаётся в клоне проекта.
- С3. harness.project.json: правка «харнеса»→«харнесса» в contextPack.why вне предмета (файл в зоне).
- С4. Строка приёмки 1 `bash fixtures/_krasnye_045.sh` без аргумента → rc 1 «использование … <guard-путь>»
  — дефект текста контракта; `bash fixtures/_krasnye_045.sh scripts/gitw` → rc 0 «провалов 0».
- С5. `package.json` не изменён: bash-шаг реестра npm-ключа не требует (gen_ci_steps.sh:104-115); ПЕРЕСЕЧЕНИЕ разрешало, не обязывало.
- С6. LIB_PLAN_REGISTRY — см. таблицу 050.
- С7. Вес шага 20 при моём замере продуктового прогона 17,99 с — на грани.

## Регрессии (scoped, мой прогон в клоне @ 6d00deb68)

- `bash fixtures/workshop_project/rezhim_996/probe.sh` → rc 0, `examined=75 mutants=0 mismatches=0` (17,99 с); на 3af8f6b4b → rc 1, mismatches=63.
- `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix` → rc 0, `examined=75 mutants=56 mismatches=0`.
- `bash fixtures/_krasnye_045.sh scripts/gitw` → rc 0 «итог: 1 файлов, провалов 0» (без аргумента rc 1 usage — С4).
- `bash fixtures/_krasnye_071.sh` → rc 0 «честные клетки: 41/41 зелёные; стаб-пак 21/21 + дифф 21/21».
- `bash fixtures/_krasnye_054.sh` → rc 0 «итог 054: rc=0».
- `bash fixtures/_krasnye_103.sh` → rc 0 «ИТОГ 103: rc=0».
- `bash fixtures/_krasnye_105.sh` → rc 0 «клеток просмотрено: 5 … ИТОГ 105: rc=0».
- `bash scripts/verify_ci_parity.sh` → rc 0 «… matrix-ключей: 47 · расхождений: 0».
- `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc 0 «итог 4/4 классов закрыто».
- `bash scripts/pre_critic.sh --repo . contracts/996-rezhim-proekta-polnyj-cikl.md` → rc 0 «КРИТИК: дверь зелёная».
- `bash scripts/verify_antiplacebo.sh --scope freeze_contract done_contract check_zones check_staged pre_critic profile_resolver` → rc 0, «барьеров: 6 · фикстур: 99 · предъявлено красным повторным прогоном: 99» (первый прогон rc 1 — единственное расхождение: мой файл `.review/`, записанный во время прогона; перегнан на чистом дереве). Ключи gitw/mint_line/make_task/lib_zones/lib_plan scope_select не знает («неизвестный ключ») — их покрывают 045/071/054/103/105 и probe 996.

Регрессии зелёные: дефекты Б-1…Б-9 — вне покрытия действующих барьеров и probe 996, не регрессии.
