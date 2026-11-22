accept
OBJECT=206c637436df31f68f081e1e7f1944c4af0c2b89
СУД: один reviewer по 187 merge-walk, вызов 1 (полный); роль=reviewer; сессия=Rev187MW; модель-факт=anthropic/claude-opus-5-5 (workstation-контекст сессии); SHA=206c637436df31f68f081e1e7f1944c4af0c2b89; контракт=contracts/187-arhitektura-v-processe.md (frozen 187/3) + слово консультанта 22.11 ~12:19; PR=a3ka/dev-harness#1234 (wip/int-187/orch-merge); прежние вердикты=verdicts/review/contracts-187-impl-v1…v5, contracts-187-v3/v4/v6/v8 на origin/main (этот OBJECT ни один не судил); класс риска=обычный (не повышаю: дверь процесса, не права/деньги/ПД); адверсарий=нет (класс обычный)
НАХОДКИ: .review/2026-11-22-140.md (status: ready) — блоков 0, советов 4, наблюдений 2

ИТОГ: блоков нет. Дверь `scripts/done_contract.sh` обходит двухродительский merge с `.harness/**`-only дельтой к ПЕРВОМУ родителю, поднимаясь по первому родителю; каждый обход считается в предел 50 (51 — отказ с причиной). Merge с продуктовой дельтой (включая `.harnessx/`) — сам SHA*. Octopus — именованный отказ до API. Корень — прежний отказ. Это подтверждено тремя независимыми мерами: батареей автора на OBJECT, той же батареей на двери main (ровно 7 красных) и моим собственным git-миром (9 сценариев, PASS 9/9 на OBJECT, на двери main цепочка «merge .harness → merge .harness → merge продукт» красная). Все 7 мутантов двери убиты батареей.

ИДЕНТИФИКАЦИЯ. Копия /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tdf73c349f/m; TMPDIR=$PWD/.scratch-rev187mw (удалён перед докладом).
  git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/int-187/orch-merge → FETCH_HEAD; git switch --detach OBJECT; git rev-parse HEAD → 206c637436df31f68f081e1e7f1944c4af0c2b89; status --short → 0 строк.
  origin/main = 25b66070fdb19d323e0b7a0d13860f83e81a557f (= main задания).

══ (1) ОБЛАСТЬ ══
  git diff --name-status 25b66070fd OBJECT → M fixtures/workshop_project/architecture_process_187/ci_ancestor.py; M …/sdacha_187.md; M scripts/done_contract.sh. --stat: 3 files, +413 −52 (ci_ancestor.py +152 −17, sdacha_187.md +243 −30, done_contract.sh +18 −5).
  Пофайлово по коммитам: 755c23c35b (architect) → ci_ancestor.py, sdacha_187.md; 23a512aa7d (implementer) → только scripts/done_contract.sh; dfc014a43b (architect) → только sdacha_187.md. Всё в ЗОНА architect (`fixtures/workshop_project/architecture_process_187/`) и ЗОНА implementer (`scripts/done_contract.sh`) frozen 187.
  OBJECT 206c637436 — merge orchestrator (родители 25b66070fd, dfc014a43b). git merge-tree --write-tree 25b66070fd dfc014a43b → e7d37a0876f7…; git rev-parse OBJECT^{tree} → e7d37a0876f7… Дерево совпадает, своих правок в merge нет. Контракты, docs, roles, registry дифф не трогает.

══ (2) СЫРОЙ ВЫВОД (по одной команде, TMPDIR=$PWD/.scratch-rev187mw) ══
  census_b5.py merge-main repo → `CELLS=111 STABS=0 FAILURES=0`, `CENSUS merge-main --repo rc=0`, rc 0 (wall 140 с).
  census_b5.py merge-model model → `CELLS=111 STABS=0 FAILURES=0`, `CENSUS merge-model --model rc=0`, rc 0.
  census_b5.py merge-stabs stabs → `CELLS=111 STABS=134 FAILURES=0`, `CENSUS merge-stabs --stabs rc=0`, rc 0.
  census_b5.py b5c-sheet-stabs stabs (строка 48 листа) → `CELLS=111 STABS=134 FAILURES=0`, `CENSUS b5c-sheet-stabs --stabs rc=0`, rc 0.
  census_b5.py без аргументов → rc 0: CELLS=96 STABS=117 ANCESTOR_CELLS=29 ANCESTOR_STABS=24 B5_CELLS=14 B5_STABS=17 OLD_CELLS=67 OLD_STABS=93 BATTERY_CELLS=111 BATTERY_STABS=134 DANGLING=[].
  bash -n scripts/done_contract.sh → rc 0.
  bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run → `СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)`, rc 0, wall 11 мин 7 с (бюджет листа 900 с).
  Наблюдение по строке 48 честно: в моём вызове строка 48 дала rc 0 один раз отдельно и ещё раз внутри прогона листа. Отказ rc 1, который оркестратор видел на 23a512aa7d, я НЕ воспроизвёл. Причину не устанавливаю. Гипотеза — совет С-2.

══ (2а) СВОЯ МЕРА СЧЁТНЫХ УТВЕРЖДЕНИЙ (другой командой, по сохранённым логам) ══
  merge-main-repo.stdout: grep -c '^GREEN' → 112 = 111 клеток + 1 строка самопроверки pin-diagnostic-boundary-selfcheck; '^RED' → 0; '^GREEN done-ancestor-' → 29 (= ANCESTOR_CELLS).
  merge-stabs-stabs.stdout: '^STAB' → 134, уникальных имён 134, «caught» 134, непойманных 0. Новые привязки: ancestor-merge-second-parent @ done-ancestor-merge; ancestor-merge-stop-2-1 @ …-merge-sluzhebnyj-2-1; ancestor-merge-stop-1-1 @ …-merge-sluzhebnyj-1-1; ancestor-merge-unbounded @ …-merge-limit-51; ancestor-cross-merge @ …-merge-product; ancestor-merge-diff-parent @ …-merge-real; ancestor-no-octopus-reason @ …-merge-octopus.
  Привязки стабов — в коде: `ci_ancestor.STABS` и ветви `select(mutant)`, не проза (Н-39).

══ (3) НЕПОДГОНКА ══
  Клетки и стабы (755c23c35b) предшествуют реализации: git merge-base --is-ancestor 755c23c35b 23a512aa7d → 0. После реализации ci_ancestor.py не менялся: git diff --stat 755c23c35b dfc014a43b → только sdacha_187.md и done_contract.sh. Implementer файлы проверок не трогал. Merge2 правил только лист: repo-строки `1 · 1` → `0 · 0` и диагноз строки 48.
  Заменённая охранная клетка `merge` (rc 1 → 0) не подогнана под код. Её вход — продукт второго родителя, не вошедший в дерево merge. Новое ожидание следует прямо из слова консультанта: «дельта = git diff <первый родитель>..<merge>». Заменённое обязательство в листе названо (sdacha_187.md:225-247). Прежний стаб ancestor-cross-merge перенесён на merge-product и там пойман.

══ (4) КРАСНОЕ ПРЕДЪЯВЛЕНО (перемер на базе) ══
  Дерево OBJECT (git archive), scripts/done_contract.sh взят из 25b66070fd; bash …/red_architecture_process_187.sh --repo <копия> → rc 1, `CELLS=111 STABS=0 FAILURES=7`. RED ровно: done-ancestor-merge, -merge-sluzhebnyj-2-1, -merge-sluzhebnyj-1-1, -merge-mixed, -merge-limit-50, -merge-limit-51, -merge-octopus. Множество совпадает с заявленным в задании и в листе (К-05).

══ РЕАЛЬНАЯ ПРОВЕРКА ДВЕРИ (свой мир, .scratch/door_rev.py) ══
  Контекст публичной done-двери (frozen-сценарий, OBJECT ревьюера, подменённый PATH-curl) взят из общего world/prepare батареи с variation ancestor-head. Проверяемую историю строил сам, обычными `git checkout -b` / `git commit` / `git merge --no-ff`, без ci_ancestor.pr_merge/select. Ответ API: arch success только на ожидаемом SHA, skipped на всех остальных коммитах HEAD. Ожидания зафиксированы до вызова. Проверялись rc, тег done на HEAD (или его отсутствие), журнал запросов API и строка ARCH_CI с HEAD и SHA*.
  OBJECT-дверь → PASS 9/9, FAILURES=0:
   • chain (merge #992 .harness → merge #991 .harness → merge #989 продукт с success) → rc 0, запрос ровно [M989], тег на HEAD; `ARCH_CI: HEAD=3cda19a7…; SHA*=8746e928…; успешный check-run arch засчитан`.
   • product-merge (merge с src/p.js + .harness/n) → rc 1, SHA*=HEAD, запрос [HEAD], тега нет.
   • harnessx (merge с .harnessx/a) → rc 1, SHA*=HEAD.
   • second-parent-reverted (ветка PR вносит src/evil.js и следующим коммитом удаляет его плюс .harness/rv; дельта к p1 — только .harness) → rc 0, SHA*=M989. Итоговые продуктовые пути HEAD и SHA* совпадают.
   • second-parent-entered (p1 продвинут .harness-коммитом, два продуктовых коммита ветки вошли в итог) → rc 1, SHA*=HEAD. Продуктовые пути второго родителя видны в дельте к первому.
   • octopus (3 родителя, все .harness) → rc 1, запросов 0; `… octopus: более двух родителей — подъём по первому родителю не определён — успешного check-run arch нет`.
   • limit-50 (50 служебных merge над M989) → rc 0, SHA*=M989; limit-51 → rc 1, SHA*=первый хвостовой merge, `лимит глубины подъёма (50) исчерпан`, запросов 0.
   • root-via-merge (.harness-merge над корневым коммитом) → rc 1, SHA*=корень, `корневой коммит: родителей нет`.
  Дверь main (25b66070fd) на тех же сценариях: chain → rc 1, `ARCH_CI: HEAD=bcc2a180…; SHA*=bcc2a180… (сам HEAD); успешного check-run arch нет (curl rc=0)`; limit-50 → rc 1, то же. Без подъёма — отказ, как требует задание.

══ МУТАНТЫ ДВЕРИ (одноразовая копия дерева, по одному, не в коммит; батарея --repo <копия> + мой мир) ══
  M1 обход merge по ВТОРОМУ родителю (:389) → батарея rc 1, RED 3: merge, merge-limit-50, merge-limit-51; мой мир FAIL 3 (second-parent-reverted, limit-50, limit-51). УБИТ.
  M2 дельта merge против ВТОРОГО родителя (:371) → rc 1, RED 7: merge, -2-1, -1-1, -mixed, -limit-50, -limit-51, merge-real (rc 0 вместо 1); мой мир FAIL 6. УБИТ.
  M3 префикс `.harness*` вместо границы каталога (:377) → rc 1, RED 3: prefix-x, prefix-old, merge-prefix-x; мой мир FAIL harnessx. УБИТ.
  M4 лимит 50 не считает merge (:384, :388) → rc 1, RED 1: merge-limit-51 (rc 0 вместо 1); мой мир FAIL limit-51. УБИТ.
  M5 merge всегда служебный (:381) → rc 1, RED 7: -2-1, -1-1, -mixed, -limit-50, merge-product, merge-real, merge-prefix-x; мой мир FAIL 6. УБИТ.
  M6 octopus принимается (:352 `-gt 99`) → rc 1, RED 1: merge-octopus (rc 0 вместо 1); мой мир FAIL octopus. УБИТ.
  M7 продуктовый merge обходится, пустая дельта по-прежнему останавливает (:378) → rc 1, RED 7: -2-1, -1-1, -mixed, -limit-50, merge-product, merge-real, merge-prefix-x; мой мир FAIL 6. УБИТ.
  Выживших 0. После прогона дверь в копии восстановлена, копия удалена.

══ (5) АТОМАРНОСТЬ И АВТОРСТВО ══
  755c23c35b author=committer=architect; 23a512aa7d author=committer=implementer; dfc014a43b author=committer=architect; 206c637436 author=committer=orchestrator (чистое слияние). В каждом коммите одна задача одной роли, сообщение называет предмет 187.

══ (6) НОРМА НЕ ТРОНУТА ══
  contracts/, roles/, docs/ в диффе отсутствуют. Расширение «финальный SHA → SHA* через .harness-merge» опирается на слово консультанта 22.11 ~12:19 и объявлено в листе как заменяемое обязательство (sdacha_187.md:225-247). Текст frozen 187 не переписан — наблюдение Н-1.

══ ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), ответы (1)–(5) ══
  А. scripts/done_contract.sh — ветвь octopus (`np -gt 2`) вместо прежнего break на merge. (1) Свойство — слово консультанта: merge обходится по первому родителю, octopus отказывает с названной причиной. (2) Нового состояния нет: та же переменная `_a187_why`, видна в stderr. (3) Меняется вместе 1 файл двери и 1 файл модели (ci_ancestor.select), как и прежде, рост 0. (4) Интерфейс двери не вырос: флагов, env, rc нет новых. (5) Потребитель — клетка merge-octopus и стаб ancestor-no-octopus-reason; грамматика не дублируется. ESSENTIAL.
  Б. ci_ancestor.pr_merge — новая функция. (1) Клетки обязаны быть PR-merge формы (--no-ff, второй родитель — ветка PR). (2) Состояние — только git-мир клетки. (3) 1 файл. (4) Один вызов за 4 git-команды, глубина приемлема. (5) Потребитель — 8 новых клеток. ESSENTIAL.
  В. Семья 9 новых клеток SPECS и 6 новых привязок STABS — одним артефактом. (1) Строки слова консультанта: цепочка 2-1, негатив продуктового merge, 50/51, octopus, граница `.harness/`. (2) Ожидания в oracle-файле мира, сняты до субъекта. (3) 1 файл. (4) Интерфейс батареи не изменён. (5) Потребитель — шаг CI `check:architecture-process-187-family-selftest` (registry/ci-steps.tsv:304) и строки листа. ESSENTIAL.
  Г. Новые mutant-ветви select (merge-stop, second-parent, diff-parent, merge-always, merge-unbounded). (1) Каждой ветви соответствует отдельный стаб с различающей клеткой. (2) Состояния нет. (3) 1 файл. (4)–(5) Потребитель — режим --stabs. ESSENTIAL.
  Д. sdacha_187.md +243 −30. (1) СДАЧА контракта. (2) Состояния нет. (3) 1 файл. (4) н/п. (5) Потребитель — check_sdacha --run. Объём исторических разделов растёт от пачки к пачке, это совет С-1, не блок.

ПРОВОДКА (038): guard=red_architecture_process_187.sh и guard=scripts/check_architecture_contract.sh в диффе не тронуты. Новые клетки живут внутри guard-батареи. Шаг registry/ci-steps.tsv:304 исполняет `… --repo .`. CI OBJECT: 16 success, 1 skipped, 0 failure (gh api …/commits/206c6374…/check-runs).
РЕЖИМ ПРОЕКТА (996): предмет харнесса, sourceCanon не объявлен, gate сверки не применим.
МОБИЛЬНЫЙ ЭКРАН: н/п.
НЕ ЗАЩИЩАЕТ: этот вердикт не судит адекватность CI `arch` проекта на SHA* и не судит слово консультанта как норму (frozen 187 «НЕ ЗАЩИЩАЕТ»: ложная модель/обход project CI). Не покрыт клеткой merge с пустой дельтой к первому родителю (`merge -s ours`): дверь останавливается на нём консервативно (С-3). Причина единичного rc 1 строки 48 не установлена (С-2). Shallow-клон с графтом даёт отказ «корневой» — прежнее поведение, в диффе не менялось.
ОСТАТОК (контракт 192): в «НЕ ЗАЩИЩАЕТ» frozen 187 (contracts/187-arhitektura-v-processe.md:72-75) нет строк К-NN с ловцом reviewer, отмечать нечего.
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep по AGENTS.md — 0 совпадений), сверять дифф не с чем. Стиль двери сверен с соседним кодом той же функции: та же `set -uo pipefail`-дисциплина, тот же `_a187_*`-префикс, отказы через die с HEAD и SHA*. Соответствует.
СВЕРКА-АРХИТЕКТУРЫ: размещение — правка внутри существующего блока ARCH_CI (scripts/done_contract.sh:322-393) и семьи фикстур 187, новых модулей нет. Новых зависимостей нет (git rev-list/diff, как прежде). Писатель — только дверь: тег done на HEAD, SHA* лишь адресует check-run. Операции и bindings.json не затронуты. Долг не расширен: прежний break на merge заменён ветвью octopus, лишних путей нет. Diff модели — L1 (уточнение правила подъёма внутри уже согласованного SHA*), решения владельца уровня L2/L3 не требуется.
