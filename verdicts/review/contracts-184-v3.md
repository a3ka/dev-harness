accept
OBJECT=6eef296f4361538ce18b8aa16ce3249beb2f2b34
СУД: один узкий reviewer по М-0, вызов 3 (слово владельца ~00:27 22.11; класс 184 обычный); роль=reviewer; сессия=Rev184M0c; repo=dev-harness; предмет=184; фаза=реализация М-0, исправление Б-3(а) вердикта вызова 2 (PR a3ka/dev-harness#1213, wip/int-184/orch-m0s); модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии); SHA=6eef296f4361538ce18b8aa16ce3249beb2f2b34; класс задачи=кодовый; класс риска=обычный (не повышал и не понижал); прежний вердикт=verdicts/review/contracts-184-v2.md @ 18e2d70fc9 (archive/184/reviewer-m0-fail2-18e2d70fc9, FAIL, блок Б-3); OBJECT вызова 2=7785ceea07913fe609e23b50c22dbeb32b45c6a8; суд — только дельта 7785ceea07..6eef296f43.

ИТОГ: accept. Блоков нет. Б-3(а) закрыт. Прямой вызов резолвера с fd1=fd2=терминал печатает ровно одну строку предупреждения с точным путём ключа, rc 0, JSON прежний. На OBJECT вызова 2 строк на том же входе 0. Захваты `$(… 2>&1)`, `2>&1 | cat` и `> f 2>&1` побайтно равны stdout раздельного прогона, строк в них нет. Б-1 под терминалом не вернулся: все три потребителя под pty на грязном профиле дают тот же rc, тот же вывод на терминал и тот же ci.yml, что на чистом. Мутанты M1, M2, M4 и M5 красные, каждый на своей клетке. M3 выжил, но он эквивалентен (разбор в (3)). Советы — `.review/2026-11-22-131.md` (С-1..С-3, status: ready).

ИДЕНТИФИКАЦИЯ. pwd копии: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/td0fb4bfb7/m. Scratch: TMPDIR=<pwd>/.scratch-rev184m0c, вне коммита, удалён перед докладом. VERIFY_ANTIPLACEBO_SCRATCH=/tmp/dev-harness-verify/rev184m0c-vap (вне стерегомого дерева, удалялся после каждого прогона).
  git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/184/orch-m0s → FETCH_HEAD; git switch --detach 6eef296f43…; git rev-parse HEAD → 6eef296f4361538ce18b8aa16ce3249beb2f2b34 (= OBJECT).
  Граф: 6eef296f43 — merge orchestrator, родители f9f029592b (main) и fbe217d884; `git show --cc --format= 6eef296f43 | wc -l` → 0 (своих правок у merge нет). fbe217d884 (a=c=implementer, только scripts/profile_resolver.sh) ← 2cb4a6f889 (a=c=architect, только m0_probe.py и sdacha_m0.md) ← 7785ceea07.

══ (1) ДЕЛЬТА ══
`git diff 7785ceea07 6eef296f43 --stat` → 3 файла, +241/−9: m0_probe.py +165/−2 (architect), sdacha_m0.md +56 (architect), scripts/profile_resolver.sh +29/−9 (implementer). Объявленное совпадает.
`git diff --name-only 7785ceea07 6eef296f43 -- contracts docs roles AGENTS.md config scripts/gen_ci_workflow.sh scripts/check_merge_gate.sh scripts/check_project_connection.sh | wc -l` → 0. Контракты, нормы и потребители не тронуты.
Правки резолвера построчно:
  Шапка `:229-231`, `:237-240`, `:243-249`. Вызов 2 относил терминал к «разным» каналам. Теперь шапка говорит: «слиты — один объект И не терминал», общий терминал — исключение. Шапка совпадает с поведением (замер (2)), расхождения Б-3 «заявлено ≠ сделано» больше нет.
  Код `:272`: к условию «слиты» добавлено `&& ! [ -t 8 ]`. Это ровно простая форма MT, которую назвал вердикт вызова 2.
  fd 8 — дубль исходного stdout. Его открывает `exec 8<&1 7<&2` в `:263`, в основном шелле той же функции, до проверки. `channels_merged` вызывается без перенаправлений (`:293`), а `warn_unknown` — из `scan_levels` (`:460`, `:481`, `:525`), которую основной шелл зовёт в `:677-678`. Значит, fd 8 в `:272` — тот же объект, что исходный fd 1. Дескриптор не закрывается до конца прогона. Это было и на OBJECT вызова 2, дельта ничего не добавила (С-2).
  Закрытый или невалидный fd 8. `[ -t 8 ]` вычисляется только тогда, когда `[ -n "$a" ]`, то есть `stat` на /proc/self/fd/8 прошёл, а значит fd 8 открыт. Если исходный stdout закрыт, `exec 8<&1` падает раньше: так было и в вызове 2 (T12 вердикта v2: rc 1 и на чистом, и на грязном). Если fd 8 неразличим, срабатывает ветка «раздельные». Ложного «слиты» на закрытом дескрипторе не бывает. Отказ в безопасную сторону: строка видна.
  set -e/-u. Резолвер работает под `set -uo pipefail`, без -e (`:97`). `! [ -t 8 ]` стоит внутри `if` и переменных не читает, так что nounset не задет. Под -e условие внутри `if` тоже не прерывало бы прогон.
  fd1=tty, fd2=файл. dev:inode разные, `[ -t 8 ]` не вычисляется, каналы раздельные. Замер T-split: строка в файле, на терминале 0 (ниже).
  PROFILE_RESOLVER_WARN_FILE, `scan_levels` и Б-2 в дельте не менялись.

══ (2) ЗАКРЫТИЕ Б-3(а) — СВОЙ ЗАМЕР ══
Scratch `meas.py`. Миры строит `m0_probe.prepare` (снимок back), сравнения мои. clean — конформный мир. repo — тот же мир + `"pack":{"maxBytes":40000}` в корне репо-слоя. project — + `defaults.pack` в слое. OLD = `git show 7785ceea07:scripts/profile_resolver.sh` в scratch, NEW = OBJECT.
  T-pty (`pty.openpty`, fd0=fd1=fd2=slave):
    OLD repo/project: rc=0, строк предупреждения 0.
    NEW repo: rc=0, ровно `['профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack']`, JSON после снятия строки и `\r` структурно равен stdout раздельного прогона.
    NEW project: rc=0, ровно `['профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ слой-проекта: defaults.pack']`, JSON равен.
    NEW clean: rc=0, строк 0.
  T-script (`script -qec "bash <resolver> --repo <W>" <лог>`): OLD repo/project → строк в логе 0. NEW repo/project → 1 строка с точным путём. clean → 0.
  T-split (fd1=pty, fd2=файл), OLD и NEW: строки на терминале нет. В файле ровно одна строка с путём (repo: `репо-слой: pack`, project: `слой-проекта: defaults.pack`).
  T-sep (`>f 2>g`), OLD и NEW: stdout равен чистому, stderr ровно 1 строка с путём.
  Захваты, NEW, repo/project/clean:
    `$(… 2>&1)`: rc 0, захват побайтно равен stdout раздельного прогона без завершающего \n (столько `$(…)` и снимает), строк 0.
    `2>&1 | cat`: rc 0, побайтно равен, строк 0.
    `> f 2>&1`: rc 0, f побайтно равен, строк 0.
  T-cap-under-tty (`script -qec 'out=$(… 2>&1); printf %s "$out" | jq -e .repoId.value'`): захват внутри терминальной сессии. jq rc 0, `"Complior-back"` на всех трёх мирах, у OLD и у NEW. Терминал снаружи захвата Б-1 не возвращает.
  T-warnfile при слитых каналах (`$(… 2>&1)` + PROFILE_RESOLVER_WARN_FILE): захват без строки, в файле ровно 1 строка с путём (repo и project, OLD и NEW).
  T-warnfile на pty: NEW — 1 строка на терминале и 1 в файле. OLD — 0 на терминале и 1 в файле.
  T-pty, у вызывающего свой fd 8 открыт на файл (`exec 8>f; exec bash …`): NEW — 1 строка на терминале, в файл вызывающего 0 B. T-pty со stdin=/dev/null: NEW — 1 строка (решает stdout, а не stdin).
  Потребители под pty (NEW, миры `m0_probe.prepare_m0b`, чистая и грязная фаза в одном мире, ci.yml обнулялся перед каждым прогоном). Пары repo/project для gen_ci_workflow.sh, check_merge_gate.sh и check_project_connection.sh. `pty.openpty`: rc чистый/грязный 0/0 ×6, вывод на терминал равен (пуст) ×6, ci.yml побайтно равен ×6 (gen_ci: 586 B). `script -qec "bash scripts/<потребитель> --repo <W>"`: rc 0/0 ×6, тело лога без строк заголовка и хвоста script равно ×6, ci.yml равен ×6.
  Почему Б-1 не возвращается: резолвер у потребителей запускается как `$(bash "$RESOLVER" … 2>&1)` (gen_ci_workflow.sh:44-46, check_merge_gate.sh:46-48, check_project_connection.sh:85). Там fd 1 резолвера — труба подстановки, а не терминал вызывающего, поэтому `[ -t 8 ]` ложно. Предупреждение у потребителя под терминалом теряется — по слову владельца это остаточный риск (б), не блок.

══ (3) НЕПОДГОНКА И МУТАНТЫ ══
Клетки менял architect (2cb4a6f889), реализацию — implementer (fbe217d884). Старые клетки и снимки не трогал никто. В m0_probe.py вне нового блока M0D изменены только две строки `run()`: к rc добавлено `| run_m0d(...)`. `git diff 7785ceea07 6eef296f43 -- '*baseline*.json' fixtures/profile_resolver fixtures/parsing_hygiene_battery fixtures/workshop_project/red_profil_dva_sloja.sh | wc -l` → 0 (то есть ни одна строка вне трёх файлов дельты не менялась).
Мутанты: каждый в одноразовом клоне `git clone --shared` моей копии на OBJECT внутри scratch, одна замена (assert count == 1), клон удалялся сразу. Прогоны: W --repo <клон> --m0, run_battery.sh profile_resolver, red_profil_dva_sloja.sh <клон>, verify_antiplacebo --scope profile_resolver.
  M1 (`&& ! [ -t 8 ]` удалено, поведение вызова 2): КРАСНЫЙ. RED m0-b3a-pty-terminal (M0D 2/1). M0 31/0, M0B 14/0, hygiene 4/4, dva_sloja rc 0, antiplacebo rc 0.
  M2. Буквально «`! [ -t 8 ]` → `true`» даёт `[ "$a" = "$b" ] && true`, то есть форму M1. Проверены обе формы.
    M2a (буквальная): КРАСНЫЙ, RED m0-b3a-pty-terminal. Прочие батареи зелёные.
    M2b (по замыслу «всегда раздельные», `&& ! true`): КРАСНЫЙ. M0B RED 8: m0-b1a-ci-{repo,project}, m0-b1b-merge-{repo,project}, m0-b1v-connection-{repo,project}, m0-b1d-merged-{repo,project}. Б-1 вернулся и пойман. M0D 3/0, прочие зелёные.
  M3 (`[ -t 1 ]` вместо `[ -t 8 ]`): ВЫЖИЛ. W 48/0, hygiene 4/4, dva_sloja rc 0, antiplacebo rc 0. Мутант эквивалентный: в `:272` fd 1 и fd 8 — один объект (дубль создан в `:263` тем же шеллом, вызов `:293` без перенаправлений). Закрывающего свойства M3 не нарушает. Сведения — С-3.
  M4 (инверсия, `&& [ -t 8 ]`): КРАСНЫЙ. M0B RED 8 (те же, что M2b), M0D RED m0-b3a-pty-terminal. Прочие зелёные.
  M5 (на терминале строка без пути ключа: при `[ -t 8 ]` печатается `…неизвестный ключ <уровень>`): КРАСНЫЙ. RED m0-b3a-pty-terminal и m0-b3a-pty-split (M0D 1/2). Прочие зелёные.
  Красное предъявлено. Клетка m0-b3a-pty-terminal красная на поведении вызова 2 (M1/M2a) и зелёная на OBJECT. Стабы S-pty, S-pipe и S-all ловятся (`--m0 --stabs`: M0D_STABS=3 LIVE=0). Каждый привязан в коде к своим клеткам (`m0_probe.py:M0D_STABS`).
  Счётные утверждения sdacha_m0.md проверены своей мерой. «48 клеток»: 31+14+3 по строкам `_CELLS=`. «W --model 60 клеток ok»: `grep -cE '^CELL .*: ok'` → 60. «W --stabs 39 адресных предъявлений caught»: `grep -cE ': caught'` → 39. Совпадает.

══ (4) СЫРОЙ ВЫВОД (OBJECT, по одной команде) ══
  W = bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh.
  bash -n scripts/profile_resolver.sh → rc 0.
  W --repo . --m0 → rc 0: M0_CELLS=31 GREEN=31 RED=0; M0B_CELLS=14 GREEN=14 RED=0; M0D_CELLS=3 GREEN=3 RED=0.
  W --m0 --model → rc 0: 31/31/0, 14/14/0, 3/3/0.
  W --m0 --stabs → rc 0: M0_STABS=8 LIVE=0; M0B_STABS=4 LIVE=0; M0D_STABS=3 LIVE=0.
  W --model → rc 0: 31/0, 14/0, 3/0 (60 строк CELL ok).
  W --stabs → rc 0: A10-стабы caught (14), M0_STABS=8 LIVE=0, M0B_STABS=4 LIVE=0, M0D_STABS=3 LIVE=0 (39 caught).
  С `--repo .` формы `--model`/`--stabs` дают rc 2 «not allowed with argument --repo» (argparse пробы). Прогнаны без `--repo`, как в вердикте v2.
  bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver → rc 0, «итог 4/4 классов закрыто».
  VERIFY_ANTIPLACEBO_SCRATCH=/tmp/dev-harness-verify/rev184m0c-vap bash scripts/verify_antiplacebo.sh --scope profile_resolver → rc 0, «барьеров: 1 · фикстур: 10 · предъявлено красным повторным прогоном: 10».
  bash fixtures/workshop_project/red_profil_dva_sloja.sh → rc 0, «честная часть: проверено предъявлений 37», «054-батарея зелёная».
  _krasnye_055 и _krasnye_059 не прогонялись: дельта их не касается, предсуществующее состояние разобрано в вердикте v2.

══ (5) ОБЛАСТЬ ══
Дельта — три файла объявленных зон: architect — fixtures/workshop_project/external_connection_184/ (контракт 184, ЗОНА architect), implementer — scripts/profile_resolver.sh. Превышения нет. Нормативные документы не тронуты (0 строк в contracts/docs/roles/AGENTS.md/config). probe.py в дельте не менялся.

ОСТАТОК: К-01 (contracts/184-…:50, устаревшие названия «harness» в продукте) — не укусил: дельты продукта нет.
ОСТАТОК: К-02 (contracts/184-…:51, семантика продуктового CI после переноса батарей) — не укусил: переноса батарей в дельте нет.
ОСТАТОК: К-03 (contracts/184-…:52, подмена probe.py и исходников батареи) — не укусил. probe.py в дельте 7785ceea07..6eef296f43 не менялся. m0_probe.py изменил architect, +165/−2. `SystemExit|sys.exit|os._exit|except Exception|except:` в m0_probe.py — 0 совпадений. В дельте добавлены два `except`: `except OSError` (run_on_pty) обрывает чтение pty по EIO, а `except ValueError` (judge_m0d) делает клетку красной (`same=False`). rc ни один из них не глушит. rc M0D складывается в итог (`| run_m0d`, обе ветки `run()`), и M1/M2a/M4/M5 дали W rc 1.

СВЕРКА-АРХИТЕКТУРЫ: размещение — условие различения каналов в scripts/profile_resolver.sh (зона implementer 184), клетки М-0Д в fixtures/workshop_project/external_connection_184/ (зона architect). Новых внешних зависимостей нет: `[ -t ]` — встроенная команда bash, в пробе модуль stdlib `pty`. Новых писателей состояния нет. Дескрипторы 7/8 открыты до конца прогона, как и в вызове 2 (С-2). bindings.json и операции не затронуты. Долг: Б-3(а) закрыт; потеря строки у потребителей вне зоны — остаточный риск по слову владельца; fifo инструмента агента — вопрос владельцу (С-1). tooling/checks/cli.js в дереве нет (`ls tooling` → нет каталога), находку модели архитектуры заводить нечем; diff модели нет, L-уровень не применим.
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep — 0 совпадений; в docs/ их нет), сверять дифф не с чем. «Заявлено = сделано»: шапка `scripts/profile_resolver.sh:229-231,237-249` совпадает с замером (2) — соответствует.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по каждому новому/раздутому артефакту дельты — (1) свойство; (2) состояние; (3) сколько файлов меняется вместе; (4) глубина модуля; (5) потребитель / повтор логики:
  Ветвь `&& ! [ -t 8 ]` в `channels_merged` (`:272`). (1) Б-3(а): на терминале ровно 1 строка (клетка m0-b3a-pty-terminal); форма без ветви (M1) эту строку не проходит. (2) Нового состояния нет: тот же кэш `_WARN_CHANNELS`, тот же fd 8. (3) 1 файл. (4) Интерфейс функции не вырос: без аргументов, rc 0/1. (5) Клетки M0D/M0B; логику больше нигде в дереве не повторяет. ESSENTIAL.
  Семья клеток M0D в m0_probe.py: M0D_CASES, M0D_STABS, run_on_pty, actual/model/judge_m0d, run_m0d, conformant_stdout. (1) Приёмка Б-3(а): W --m0 48/0, --stabs M0D 3/0. (2) Оракул — замороженный m0_baseline.json, читается до кандидата; подставляется только layerRoot, той же подстановкой, что в run(). (3) 1 файл + сдаточный лист. (4) Флагов и env не добавлено, режимы прежние (repo/model/stabs). (5) Строка приёмки. Слитые захваты и журнал переиспользуют M0B и fixtures/profile_resolver и не дублируются. ESSENTIAL.
  Раздел sdacha_m0.md «Исправление FAIL Rev184M0b». Документ сдачи, состояния не вводит. Счётные утверждения сверены своей мерой ((3)).
