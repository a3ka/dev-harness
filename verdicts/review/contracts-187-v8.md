accept
OBJECT=dca4991a827bfb10a6b4b54ff1ba05bbb5eb2373
СУД: один scoped reviewer по ARCH_CI, вызов 2 (scoped-повтор в базовом бюджете; слово консультанта 23:52; класс 187 обычный); роль=reviewer; сессия=Rev187Ci2; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии); SHA=dca4991a827bfb10a6b4b54ff1ba05bbb5eb2373; PR=a3ka/dev-harness#1217 (wip/int-187/orch-ci2, headRefOid=OBJECT); контракт=contracts/187-arhitektura-v-processe.md (frozen/contracts/187/3; правило предка — слово консультанта 23:52, frozen-текст не правится); класс задачи=кодовый (дверь done + батарея 187); класс риска=обычный (не повышал: дельта вызова 2 — два флага одной команды git, тег и прочие отказы прежние); скоуп=закрытие Б-1 вердикта v7 (archive/187/reviewer-ci-fail-3181eee080) + неподгонка правки + обход того же класса (список путей/классификация).

ИТОГ: Б-1 закрыт, новых блоков нет. На OBJECT вызова 1 (4333f84873) оба обхода Б-1 воспроизведены: rename и gitlink при `ignore = all` дают rc 0 с SHA*=S. На OBJECT оба дают rc 1 ARCH_CI, SHA*=HEAD, единственный запрос — на HEAD. Из 27 моих миров (конфиг, окружение, драйверы, режим, удаление, typechange, пути, ошибка git) на OBJECT 25 дают ожидаемое. git-diff-fails даёт rc 1 через корень, с ложной причиной (С-2). replace-ref даёт rc 0, он вне границы (С-1). Клетки rename / submodule-ignore красные на двери вызова 1 и на мутантах М1/М2/М3. Мутанты семьи вызова 1 М4a–М4f пойманы. Выжил М6 (стоп на пустом списке путей), он вне Б-1 — совет С-3. Обход через refs/replace вне границы угроз — совет С-1.

ИДЕНТИФИКАЦИЯ. pwd=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t88a7be7df/m. Scratch — `$PWD/.scratch-rev187ci2`, удалён до доклада.
  git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/187/orch-ci2 → FETCH_HEAD; git switch --detach OBJECT; git rev-parse HEAD → dca4991a827bfb10a6b4b54ff1ba05bbb5eb2373; status --short → 0 строк.

══ (1) ДЕЛЬТА ══
git diff 4333f84873 dca4991a82 --stat → 6 файлов:
  - вне предмета, merge main f9f029592b..470e3296dc: docs/owner/adr/2026-11-22-noch-165-m0-992-044.md, docs/owner/adr/README.md, registry/risk-legacy.tsv. `git diff f9f029592b 470e3296dc --stat` даёт ровно эти три файла.
  - предмет: fixtures/…/architecture_process_187/ci_ancestor.py (+81/−2), fixtures/…/sdacha_187.md, scripts/done_contract.sh (+7/−1).
Дверь: `git diff 4333f84873 dca4991a82 -- scripts/done_contract.sh` — единственный хунк @@ -349,7 +349,13 @@. Шесть строк комментария и замена одной строки: `git diff --name-only -z` → `git diff --no-renames --ignore-submodules=none --name-only -z` (теперь :358). Больше в двери ничего не изменилось.
Авторство (git log 4333f84873..OBJECT):
  - ed879adc1 — architect/architect, только ci_ancestor.py и sdacha_187.md;
  - fbc26bf57 — implementer/implementer, только scripts/done_contract.sh;
  - 15ca433b1 — architect/architect, только sdacha_187.md (строка repo-двери 1·1 → 0·0);
  - dca4991a8 — orchestrator, merge.
Неподгонка: клетки и стабы (ed879adc1) легли раньше ремонта (fbc26bf57). После ремонта `git diff --stat ed879adc10 dca4991a82 -- fixtures/` → только sdacha_187.md (+14/−12, лист). Implementer проверки не правил. workflow_probe.py и census_b5.py со времени вызова 1 не менялись (`git diff --quiet 4333f84873 dca4991a82 -- …` rc 0).

══ (2) ЗАКРЫТИЕ Б-1 — живая дверь, свои миры ══
Мера: `.scratch-rev187ci2/drive.py`. Мир пробы 187 строится через `workflow_probe.world/architecture/prepare(…, 'ancestor-head', 'done')`. Поверх него — S, продуктовый коммит с arch=success, и X = HEAD атаки с arch=skipped. Окружение — как у `live()` пробы (GIT_* сняты, GLOBAL/SYSTEM=/dev/null, шим curl `ci_ancestor.SERVER`), плюс мои переменные. SHA* читаю из строки ARCH_CI, запросы — из `.queries.jsonl` шима.
  OBJECT вызова 1 (копия `git archive 4333f84873 scripts`):
    rename: X = `git mv src/r.js .harness/r.js` → rc=0, «ARCH_CI: HEAD=2bcbd2eb…; SHA*=27ec9b50…(S); успешный check-run arch засчитан», queries=[S], тег поставлен. Обход воспроизведён.
    sub-gitmodules-all: S несёт `.gitmodules` с `ignore = all` и gitlink src/sub=1…1; X = `.harness/n` + gitlink 2…2 → rc=0, SHA*=S, queries=[S], тег поставлен. Обход воспроизведён.
    harness-only-ctrl → rc=0, SHA*=S — контроль.
  OBJECT:
    rename → rc=1, «ARCH_CI: HEAD=0cc3e349…; SHA*=0cc3e349…; успешного check-run arch нет (curl rc=0)», queries=[X], тега нет.
    sub-gitmodules-all → rc=1, SHA*=HEAD=5544206d…, queries=[X], тега нет.
  Попытки обхода того же класса на OBJECT. Ожидание — rc 1 ARCH_CI, SHA*=X, queries=[X], тега нет. Всё «OK»:
    - rename-copies-env (GIT_CONFIG_COUNT diff.renames=copies);
    - rename-true-params (GIT_CONFIG_PARAMETERS diff.renames=true);
    - rename-copies-local (.git/config diff.renames=copies);
    - copy-modify-copies (копия в .harness + правка источника, diff.renames=copies в env и .git/config);
    - sub-gitmodules-dirty, sub-gitmodules-untracked;
    - sub-gitconfig-all (submodule.sub.ignore=all в .git/config);
    - sub-diffcfg-env-all (GIT_CONFIG_COUNT diff.ignoreSubmodules=all);
    - sub-diffcfg-local-all;
    - sub-summary (status.submoduleSummary + diff.submodule=log);
    - cfg-misc: core.quotePath, diff.noprefix, diff.external=/bin/false, core.pager, color.ui/diff=always, diff.relative, diff.mnemonicPrefix, `.gitattributes * diff=evil` + diff.evil.command, GIT_PAGER, GIT_EXTERNAL_DIFF; путь src/путь.js;
    - attr-driver (драйвер печатает `.harness/fake\0`);
    - chmod (+x src/m.sh в смешанном коммите);
    - delete (src/r.js);
    - typechange (src/m.sh → symlink);
    - path-space `src/a b.js`, path-utf8 `src/путь.js`, path-nl `src/a\nb.js`;
    - path-nl-harness `src/x\n.harness/y`;
    - empty (пустые S и X): стоп на X.
  Принимаемые (ожидание rc 0, SHA*=S, тег на HEAD), оба OK:
    - harness-only-ctrl (`.harness/n` + `.harness/sp ace/ü\nx`);
    - harness-symlink-in (`.harness/link` → ../src).
  Ошибка git:
    - missing-tree: удалён объект поддерева src в X; `git diff` rc=128, stdout='' → дверь rc=1, SHA*=X, queries=[X]. Fail-closed.
    - git-diff-fails: синтетический шим git печатает `.harness/n\0` и выходит с rc 128 на каждом diff. Подъём доходит до корня: rc=1 «корневой коммит», запросов нет. Fail-closed, но причина ложная, см. С-2.
  Вне класса: replace-ref (`git replace X T`) → rc=0, SHA*=S, тег на X. Это обход вне объявленной границы угроз, см. С-1.
  Свой одноразовый git-репо (misc.sh):
    - `.harness/../src/x` через update-index → «Invalid path», rc 128;
    - `.harness` как файл: список путей `.harness\0.harness/h\0`; запись `.harness` под `case .harness/*` (:364) не подпадает, значит продукт и стоп;
    - `.harness` как symlink → src: `git add .harness/new` → «beyond a symbolic link», rc 128;
    - хвост `-z`: последний байт `\0`; пустой diff — 0 байт, `npaths=0` → стоп (:368);
    - классификация case: `.HARNESS/x`, `./.harness/x`, `.harness` → продукт; `.harness/`, `.harness//x`, `.harness/x` → .harness.

══ (3) НЕПОДГОНКА — мутанты двери ══
Мера: `.scratch-rev187ci2/mut.sh`. Каждый мутант — отдельная копия `git archive OBJECT scripts`, одна замена (python, ровно одно вхождение), затем 20 клеток `done-ancestor-*` батареи 187 через `workflow_probe.main --repo <копия>` (CASES отфильтрованы). Копия удаляется после прогона.
  М0 без мутации → CELLS=20 FAILURES=0.
  Дверь вызова 1 (4333f84873) → rc=1, FAILURES=2: RED rename, submodule-ignore. Красное до ремонта предъявлено.
  М1 убран `--no-renames` (S-ren) → FAILURES=1: RED rename. ПОЙМАН.
  М2 убран `--ignore-submodules=none` (S-sub) → FAILURES=1: RED submodule-ignore. ПОЙМАН.
  М3 убраны оба (поведение вызова 1, S-both) → FAILURES=2: RED rename, submodule-ignore. ПОЙМАН.
  М4a :365 `*) _a187_only=0` → `*) :` (подъём без проверки пути) → FAILURES=17: one three product docs github mixed failure skipped limit head missing tag-head prefix-x prefix-old rename submodule-ignore guard-rename. ПОЙМАН.
  М4b :364 `.harness/*` → `.harness*` (без границы каталога) → RED prefix-x, prefix-old. ПОЙМАН.
  М4c :347 `-gt 1` → `-gt 99` (подъём через merge) → RED merge. ПОЙМАН.
  М4d :332 `_a187_max=50` → 100000 (без лимита) → RED depth. ПОЙМАН.
  М4e :815 тег на `_a187_sel` → RED one three limit tag-head guard-rename. ПОЙМАН.
  М4f :399 запрос на `_a187_sha` → RED one three failure skipped limit missing tag-head guard-rename. ПОЙМАН.
  М5 :358 убран `-z` → RED one three failure skipped depth limit missing tag-head guard-rename. ПОЙМАН.
  М6 :368 убран стоп `npaths -eq 0` → FAILURES=0, ВЫЖИЛ. Закрывающее свойство Б-1 он не нарушает: на честном git список полон и с ним, и без него. На моём мире missing-tree М6 даёт rc 0 (fail-open на ошибке git), а OBJECT — rc 1. Значит, это достаточность батареи на поверхности вызова 1, не изменённой дельтой, — совет С-3.
Стабы architect: `--stabs` → ancestor-rename-detection, ancestor-porcelain-paths @ done-ancestor-rename и ancestor-submodule-hidden @ done-ancestor-submodule-ignore — caught. Привязка по коду `ci_ancestor.select` (флаги снимаются по одному), Н-39 соблюдён.
Охранная guard-rename (rename внутри .harness/ + 30 файлов, rc 0) зелёная на OBJECT: дверь не стала строже на rename внутри `.harness/`.

══ (4) ОБЛАСТЬ ══
git diff --name-status 470e3296dc dca4991a82 →
  A fixtures/workshop_project/architecture_process_187/census_b5.py
  A fixtures/workshop_project/architecture_process_187/ci_ancestor.py
  M fixtures/workshop_project/architecture_process_187/sdacha_187.md
  M fixtures/workshop_project/architecture_process_187/workflow_probe.py
  M scripts/done_contract.sh
`git diff --quiet 470e3296dc dca4991a82 -- contracts roles docs AGENTS.md` → rc 0: норма и контракт не тронуты.
Хунки done_contract.sh (-U0, к 470e3296dc):
  - 313-321 — комментарий;
  - 324-380 — цикл SHA* с правкой :358;
  - 399 — URL;
  - 424 — die;
  - 426-432 — комментарий и jq;
  - 438-439 — die и строка «засчитан»;
  - 810-813 — комментарий шага 8 (:815 не изменена).
Это те же хунки, что в вердикте v7, со сдвигом +6 строк комментария. Вне блока ARCH_CI и комментария шага 8 кода нет. Шаг 5 вердикт, ПРОВОДКА, ПОТРЕБИТЕЛИ, клапан, 992, env-гигиена (:24-26), NNN-грамматика не тронуты.

══ (5) СЫРОЙ ВЫВОД (OBJECT, TMPDIR=$PWD/.scratch-rev187ci2, по одной команде) ══
  bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . → RC=0, 118s, «CELLS=87 STABS=0 FAILURES=0». Своя мера: GREEN-строк 88 (87 клеток + selfcheck), RED 0, `^GREEN done-ancestor-` = 20.
  … --model → RC=0, «CELLS=87 STABS=0 FAILURES=0»; GREEN 88, RED 0.
  … --stabs → RC=0, «CELLS=87 STABS=111 FAILURES=0». Своя мера: `^STAB .* caught @` = 111, ZHIV = 0, `^STAB ancestor-` = 18.
  python3 fixtures/workshop_project/architecture_process_187/census_b5.py → RC=0: CELLS 87, STABS 111, ANCESTOR_CELLS 20, ANCESTOR_STABS 18, OLD 67/93, DANGLING [].
  bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . → RC=0, «CELLS=62 STABS=0 FAILURES=0»; GREEN 63 (62 + карта), RED 0.
  bash -n scripts/done_contract.sh → RC=0.
  bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run → RC=0, 288s, «СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=0)».

ОСТАТОК: строк `НЕ ЗАЩИЩАЕТ` с ловцом reviewer в contracts/187-arhitektura-v-processe.md нет. Ловцы :73-75 — 170 v2, движок и суд проекта, sourceCanon. Дельта вызова 2 их не касается — не укусил.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050):
  Два флага :358
    (1) свойство — полный список путей (Б-1).
    (2) нового состояния нет.
    (3) меняется вместе с `ci_ancestor.select`; число файлов не выросло.
    (4) интерфейс двери не изменился.
    (5) потребитель — клетки rename / submodule-ignore.
    Итог: ESSENTIAL. Без любого из флагов краснеет своя клетка (М1/М2).
  ci_ancestor.py — три клетки и три стаба, одна семья
    (1) то же свойство плюс охранная против пересужения.
    (2) состояние — `SUBMODULE_*` константы мира, явно.
    (3) меняется с дверью.
    (4) входы — прежние SPECS/STABS/prepare/select.
    (5) потребитель — батарея 187 в CI.
    Итог: ESSENTIAL.
  sdacha_187.md — лист СДАЧИ, потребитель check_sdacha. Итог: ESSENTIAL.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (вывод вызова 1, дельта AGENTS.md не трогает). Сверено с формой дерева: правка — флаги существующей команды на прежней строке, комментарий в стиле блока, обработка ошибок прежняя (`|| true`, fail-closed на пустом выводе, С-2). Расхождений нет.
СВЕРКА-АРХИТЕКТУРЫ: Размещение: правка внутри существующего 187а-блока ARCH_CI в scripts/done_contract.sh (:358); клетки — в семье fixtures/workshop_project/architecture_process_187/ (зона architect). Новых зависимостей нет: те же git diff, rev-list, jq, curl. Писатели: только tmp-файл двери и прежний тег на HEAD. Операции и bindings.json не затронуты (tooling/checks/cli.js и architecture/ в дереве нет). Долг не расширен. Diff модели нет, L-уровень не применим, находку `finding new` заводить не по чему.

СОВЕТЫ: .review/2026-11-22-133.md:
  - С-1 — refs/replace вне границы угроз;
  - С-2 — rc `git diff` не проверяется;
  - С-3 — М6 выжил, нет клетки на ошибку git diff.
Советы С-1…С-4 вызова 1 (.review/2026-11-22-130.md) остаются советами.
МАТЕРИАЛЫ: scratch-драйвер миров (`drive.py`), раннер 20 клеток (`cells.py`), мутантный раннер (`mut.sh`, `m6.sh`), git-проверки (`misc.sh`). Все удалены вместе с `.scratch-rev187ci2`, выводы процитированы выше. Push не делал, в основной чекаут и docs/owner/ не писал, тег done не ставил.
