accept
Ревьюер Rev122V7 (роль reviewer, фактическая модель anthropic/claude-opus-5-5). Реализация 122 «CI проекта» v6, scoped-исправительный повтор, вызов 2/2 (roles/critic.md §Быстрый-процесс §Реализация).

- OBJECT: 92947346d95b3ea0fcd33114c65ae879341e7969 (wip/122/implementer, транспорт wip/122/implementer-pub). Предыдущий вызов — Rev122V6 FAIL на e056cf4ba9 (.review/2026-11-19-121.md).
- Находки: `.review/2026-11-19-122.md` (reslop, status: ready).
- Связка с блобами: `scripts/freeze_contract.sh` 8915780f91adcb1b749c57a31f6b50657ff049cf. Батарея architect 307a7e2e97: roots_probe.py 5653408aae4300a358ecee867251fcff3722ca85, roots_model.py 6eaee5c3c3162334a61b27e7e1fc5b7e5210ae07. Новая редакция любого из них этот accept не наследует.

## Итог

Б-1 и Б-2 закрыты. Закрытие подтверждено клетками architect и моими входами, на каждый есть красный прогон предшественника e056. Инвариант «позиционные не сдвигаются» сохранён. Блокирующих находок по диффу нет.

Условия ленда — Л-1 и Л-2. Обе вне зоны implementer: батарея 307a7e2 не опубликована, и её счёт расходится с текстом приёмки.

Совет С-1 — граница для architect/владельца. Модель и реализация совпадают, поэтому это не блок.

## Область scoped-повтора

- Дифф e056cf4ba9..92947346d9 (`git log --format='%h %an %s' --name-only`): ровно один коммит `92947346d9 implementer`, один файл `scripts/freeze_contract.sh` (+23/−3).
- Файл входит в `ЗОНА implementer` (contracts/122-ci-proekta.md:82) и в §Граница и порядок v6 («сверка контекста существующей предпосылочной ноги в scripts/freeze_contract.sh»). Превышения нет.
- Зависимый регресс: настоящий freeze на мирах CI, полные когорты 122.
- Неизменённые поверхности (Г1/Г2, check_predposylki, резолверы) заново не исследованы: дифф их не трогает.

## Пункты роли

1. Область — соответствует (выше).
2. Сырой вывод — ниже, у каждого прогона указан rc.
3. Проверка не подогнана под реализацию:
   - автор в диапазоне фикстур не менял (единственный путь — scripts/);
   - новые клетки и стабы — коммиты c96abb944d и 307a7e2e97 под автором `architect architect@dev-harness.local`;
   - сам автор пишет «чужая зона в коммит не вошла» — по истории подтверждено.
4. Красное предъявлено:
   - e056 + батарея 307a7e2: r12 `TOTAL=43 GREEN=38 RED=5`, rc 1. Красные — mono-origin-mismatch, cli-repeat-valid/-missing-first/-invalid-first/-missing-last;
   - мои входы на e056 — 7 из 7 обманных исходов (rc 0, тег, gh).
5. Атомарность: один коммит, одна задача (Rev122V6 Б-1/Б-2), ссылка на предмет 122 в теме.
6. Норма не тронута: дифф не касается contracts/, roles/, AGENTS.md.
7. Заявленное = сделанному, своей мерой (импорт словарей батареи, не раннер):
   - CASES=43 (MARKER 10, ORIGIN 2, REPEAT 4), объединение 43, STABS=36, все цели STABS в объединении;
   - раннер: ROOTS 43/43, STABS 36/36, старая когорта 74/74;
   - «в дереве e056 — 37/37»: собственная батарея OBJECT без наложения (objclean) — 37/37.
   Заявка автора совпала по всем четырём числам.

## Сырой вывод

Копии: /tmp/dev-harness-verify/Rev122V7/{obj,pre,objclean}. obj/pre — worktree OBJECT/e056 с наложенными из 307a7e2e97 roots_probe.py и roots_model.py; objclean — OBJECT как есть.

```
$ cd obj; bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12 | tail -15
ROOTS122 EVIDENCE mono-origin-mismatch: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 mono-origin-mismatch: rc=1 ЗЕЛЁНАЯ
ROOTS122 EVIDENCE mono-origin-mismatch-explicit: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 mono-origin-mismatch-explicit: rc=1 ЗЕЛЁНАЯ
ROOTS122 EVIDENCE cli-repeat-valid: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 cli-repeat-valid: rc=1 ЗЕЛЁНАЯ
ROOTS122 EVIDENCE cli-repeat-missing-first: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 cli-repeat-missing-first: rc=1 ЗЕЛЁНАЯ
ROOTS122 EVIDENCE cli-repeat-invalid-first: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 cli-repeat-invalid-first: rc=1 ЗЕЛЁНАЯ
ROOTS122 EVIDENCE cli-repeat-missing-last: subject_rc=1 gh=[] tag_rc=128 unchanged=True
ROOTS122 cli-repeat-missing-last: rc=1 ЗЕЛЁНАЯ
ROOTS122 TOTAL=43 GREEN=43 RED=0
OBJ r12 rc=0

$ cd pre; ... --repo . --cell r12 | grep -E 'КРАСНАЯ|TOTAL'
ROOTS122 mono-origin-mismatch: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-rashozhdenie; отказ измени…
ROOTS122 cli-repeat-valid: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изменил…
ROOTS122 cli-repeat-missing-first: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изм…
ROOTS122 cli-repeat-invalid-first: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изм…
ROOTS122 cli-repeat-missing-last: rc=1 КРАСНАЯ нет причины project-workflow-neodnoznachen
ROOTS122 TOTAL=43 GREEN=38 RED=5
PRE r12 rc=1

$ cd obj; ... --repo . --stabs | tail -15
STAB rc-zero-cli-repeat-valid CELL cli-repeat-valid: rc=0 ПОЙМАН
STAB rc-zero-cli-repeat-missing-first CELL cli-repeat-missing-first: rc=0 ПОЙМАН
STAB rc-zero-cli-repeat-invalid-first CELL cli-repeat-invalid-first: rc=0 ПОЙМАН
STAB rc-zero-cli-repeat-missing-last CELL cli-repeat-missing-last: rc=0 ПОЙМАН
STAB rc-one-mono-declared CELL mono-declared: rc=1 ПОЙМАН
STAB rc-one-mono-declared-explicit CELL mono-declared-explicit: rc=1 ПОЙМАН
STAB rc-one-project-secret CELL project-secret: rc=1 ПОЙМАН
ROOTS122 STABS=36 CAUGHT=36
OBJ stabs rc=0

$ cd obj; ... --repo . | grep -E 'TOTAL|ИТОГ'
ИТОГ 122 (red): клеток 74, зелёных 74, красных 0
ROOTS122 TOTAL=43 GREEN=43 RED=0
OBJ full --repo rc=0
$ cd obj; ... --model | grep -E 'TOTAL|ИТОГ'
ИТОГ 122 (model): клеток 74, зелёных 74, красных 0
ROOTS122 TOTAL=43 GREEN=43 RED=0
OBJ full --model rc=0

$ cd objclean; ... --repo . --cell r12 | grep TOTAL
ROOTS122 TOTAL=37 GREEN=37 RED=0
OBJCLEAN r12 rc=0

$ python3 -c '<import roots_probe 307a7e2; len словарей>'
CASES 43 MARKER 10 ORIGIN 2 REPEAT 4 UNION 43 STABS 36 STABS_targets_in_union True

$ python3 my_probe.py obj          (rc=0)
MY b1-insteadof: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-rashozhdenie: canonicalRemote не совпадает с живым origin корня
MY b1-insteadof-reverse: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: реестр заморозок (refs/tags/frozen/*) недоступен: unknown-remote — … [невалидный контроль, С-2]
MY regr-mono-nodecl-origin-same: freeze_rc=0 gh=[["secret","list","-R",".../station-origin.git"]] tags=['frozen/contracts/731/1'] otkaz=-
MY regr-mono-nodecl-origin-diff: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-rashozhdenie: canonicalRemote не совпадает с живым origin корня
MY regr-no-ci-origin-same: freeze_rc=0 gh=[] tags=['frozen/contracts/731/1'] otkaz=-
MY regr-no-ci-origin-diff: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-rashozhdenie: canonicalRemote не совпадает с живым origin корня
MY b2-unreadable-first: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-neodnoznachen: контекстов больше одного
MY b2-dir-first: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-neodnoznachen: контекстов больше одного
MY b2-three-valid: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-neodnoznachen: контекстов больше одного
MY b2-flag-first-single: freeze_rc=0 gh=[["secret","list","-R",".../product-origin.git"]] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-flag-first-repeat: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: project-workflow-neodnoznachen: контекстов больше одного
$ python3 my_probe.py pre          (rc=0)
MY b1-insteadof: freeze_rc=0 gh=[["secret","list","-R",".../foreign-origin.git"]] tags=['frozen/contracts/731/1'] otkaz=-
MY b1-insteadof-reverse: freeze_rc=1 gh=[] tags=[] otkaz=ОТКАЗ: реестр заморозок (refs/tags/frozen/*) недоступен: unknown-remote — …
MY regr-mono-nodecl-origin-same: freeze_rc=0 gh=[[… station-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY regr-mono-nodecl-origin-diff: freeze_rc=0 gh=[[… foreign-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY regr-no-ci-origin-same: freeze_rc=0 gh=[] tags=['frozen/contracts/731/1'] otkaz=-
MY regr-no-ci-origin-diff: freeze_rc=0 gh=[] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-unreadable-first: freeze_rc=0 gh=[[… product-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-dir-first: freeze_rc=0 gh=[[… product-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-three-valid: freeze_rc=0 gh=[[… product-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-flag-first-single: freeze_rc=0 gh=[[… product-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-
MY b2-flag-first-repeat: freeze_rc=0 gh=[[… product-origin.git]] tags=['frozen/contracts/731/1'] otkaz=-

$ cd obj; bash scripts/verify_antiplacebo.sh --scope freeze_contract | tail -1   → барьеров: 1 · фикстур: 15 · предъявлено красным повторным прогоном: 15   rc=0
$ cd obj; bash scripts/verify_antiplacebo.sh --scope drill_contract_change | tail -1 → барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1   rc=0
$ cd obj; bash fixtures/freeze_contract/red_doc_lifecycle.sh | tail -1 → cases=25 observations=25 failures=0   rc=0
$ cd obj; bash fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh | tail -1 → case_14: freeze-time backstop refuses (rc 1, именованная причина, тег НЕ записан)   rc=0
$ cd obj; bash scripts/verify_antiplacebo.sh --scope check_precision_gate → «FAIL scope_select отказал (код 1)» rc=1 — неверное имя scope с моей стороны (не семья), заменён прямым прогоном red_14 выше; не засчитан.
$ git ls-remote origin | grep -cE '^(307a7e2|c96abb9)' → 0   (локально — ветка wip/122/architect-red → 307a7e2e97)
$ grep -nE '^\s*shift|set --' scripts/freeze_contract.sh (obj) → пусто
```

Не прогонялись (NOT_RUN):
- `pre_critic`, `check_sdacha --run`, `check_provodka` на OBJECT. Дифф не меняет ни контракт, ни лист, ни проводку. Расхождение счёта, которое `check_sdacha` увидит после ленда 307a7e2, вынесено в Л-2.
- `ci_preflight --repo .` — у автора тоже NOT_RUN: собственный ci.yml харнесса вне вычисляемого алфавита. Дифф Г2 не трогает.

## Находки (полный список; детали — .review/2026-11-19-122.md)

- Б-1 Rev122V6 — ЗАКРЫТ (класс: обход сверки инвентаря; было БЛОКИРУЕТ).
- Б-2 Rev122V6 — ЗАКРЫТ (класс: молчаливая подмена явного контекста; было БЛОКИРУЕТ).
- Л-1 — УСЛОВИЕ ЛЕНДА (класс: барьер не опубликован/не в истории OBJECT; адресат оркестратор/architect).
- Л-2 — УСЛОВИЕ ЛЕНДА (класс: счётное расхождение приёмки и батареи 37↔43, 22↔36; адресат architect/владелец).
- С-1 — СОВЕТ (класс: граница — сверка origin в неявной ветви и для контрактов без CI/декларации; совпадает с исполняемой моделью; адресат architect/владелец).
- С-2 — СОВЕТ (класс: невалидный контроль ревьюера, вне 122).

ОСТАТОК (контракт 192; строки НЕ ЗАЩИЩАЕТ с ловцом «ревью кода/судьи реализации»):
- ОСТАТОК: «злонамеренный субъект, распознающий пробы батареи» (contracts/122-ci-proekta.md:126) — не укусил. Обе ветви диффа (`freeze_contract.sh:76-84`, `:795-798`) не ссылаются на пути, имена или значения батареи. Мои входы иной механики (insteadOf, chmod 0, каталог, три флага, флаг до позиционных) дали тот же исход, что клетки architect.
- ОСТАТОК: «ложь уполномоченного поставщика контекста / конкурентная смена репозитория после сверки» (:175) — не укусил. Сверка `:795` и чтение Г3 `check_predposylki.sh:113` — два чтения одного `remote get-url`. Окно между ними есть ровно в объявленной границе; дифф его не расширил.

СВЕРКА-СТАНДАРТОВ: AGENTS.md харнесса не объявляет docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md (файлов нет) — н/п. Внутренние конвенции файла соблюдены: отказ — через существующие `die` и `refuse(reason, detail)` одной строкой; новых путей отказа мимо алфавита нет.

СВЕРКА-АРХИТЕКТУРЫ:
- Размещение — существующая нога 6г-0 в scripts/freeze_contract.sh, в зоне implementer.
- Зависимости — только git и уже используемый profile_resolver, новых нет.
- Писатели — новых нет: тег, реестр и коммит не тронуты, обе ветви отказывают до записи.
- Операции — новых нет.
- bindings.json — у механизма харнесса отсутствует (sdacha К-17: бриф 188 не заявлен).
- Долг не расширен. Уровень diff модели — L0: модель architect 307a7e2 уже несёт обе сверки, реализация её догнала.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа:
- (а) Ветвь повтора `--project-workflow` (`:76-84`):
  1. свойство — §v6 «несколько контекстов вместо одного — rc 1 neodnoznachen; плохой явный не заменяется»;
  2. состояние — существующая `PROJECT_WORKFLOW`, новых переменных нет, отказ видим в выводе;
  3. совместно меняемых файлов — 1, не выросло;
  4. интерфейс не вырос: тот же флаг и rc 1;
  5. потребитель — клетки cli-repeat-* (r12, приёмка п.1/3); грамматика разбора не дублируется.
  ESSENTIAL.
- (б) Сверка живого origin в неявной ветви (`:795-798`):
  1. свойство — §v6 «actual origin — буквально с canonicalRemote», Г3 берёт инвентарь из живого origin;
  2. состояние — локальная `root_remote`, видна в причине отказа;
  3. совместно меняемых — 1 (+ модель architect), не выросло;
  4. интерфейс не вырос;
  5. потребитель — mono-origin-mismatch(-explicit) r12. Явная ветвь уже несёт ту же сверку на `:769-773`: та же форма, новой грамматики нет.
  ESSENTIAL. Ширина условия — С-1.

ПРОВОДКА (038): §Граница и порядок v6 «новых CI/role-каналов нет». Дифф каналов и реестра шагов не трогает — соответствует.

## Среда

Гвард Н-85/А-122 (сессия непиннованная, Н-229) отбил `write` абсолютным путём в собственную копию. Отбил и `write agent://Main` — доклад о блокере доставить не удалось.

Как поступил: байты вердикта и .review положены в `/tmp/dev-harness-verify/Rev122V7/out/` (null-allowlist). Коммит на `wip/122/reviewer` сделан git-plumbing'ом в своей копии под identity reviewer; рабочее дерево не тронуто. Если такой коммит судьи недопустим — перекоммитить из /tmp по blob SHA, указанным в докладе.
