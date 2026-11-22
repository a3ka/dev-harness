accept
OBJECT=27983f424ad353d15ced24c2257ecdb661355470
СУД: один scoped reviewer по Б-5, вызов 2 (санкция консультанта 21:07 UTC после FAIL вызова 1; слова владельца 21.11 16:10 и 16:19); роль=reviewer; сессия=Rev187B5c; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии); SHA=27983f424ad353d15ced24c2257ecdb661355470; PR=a3ka/dev-harness#1205 (wip/int-187/orch-b5r, headRefOid=OBJECT); контракт=contracts/187-arhitektura-v-processe.md (frozen/contracts/187/3; заменяемые обязательства — ADR docs/owner/adr/2026-11-21-plan-fable.md); класс задачи=кодовый (дверь + батарея); класс риска=обычный (не повышал: дефект и ремонт — время жизни scratch-файла, без внешнего эффекта); предыдущий=FAIL contracts-187-v5 (c5886ab04a, OBJECT d23d301ddd, блок Б-1); скоуп=только закрытие Б-1 и неподгонка правки.

ИТОГ: блок Б-1 закрыт, новых блоков нет. На OBJECT вызова 1 (d23d301ddd) файл захвата stderr брифа переживает TERM/INT, доставленные группе, — воспроизведено двумя мерами. На OBJECT leftover=[] в TMPDIR и в ARCH187_MODEL_TMP для TERM и INT группе, для TERM только родителю, для нормальных rc 0/≠0. Для вызывающего поведение не изменилось. Новые клетки красные на М1, М4, call-1; М6 ловят клетки brief-stderr. Выжили М2/М3 — на bash 5.2 они равносильны честной двери, свойство не нарушают. Выжил М5 — дверь OBJECT этого порядка не содержит, это пробел батареи. Оба случая — советы в `.review/2026-11-21-126.md` (С-1…С-4).

ИДЕНТИФИКАЦИЯ. pwd=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t7f741d77c/m; scratch и мутанты — `$PWD/.scratch-rev187b5c` (не в коммите).
  git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/187/orch-b5r → FETCH_HEAD; git switch --detach OBJECT; git rev-parse HEAD → 27983f424ad353d15ced24c2257ecdb661355470; status --short → 0 строк.

══ (5) ОБЛАСТЬ ══
git diff --name-status f9f029592b 27983f424a →
  A fixtures/workshop_project/architecture_process_187/brief_signals.py
  A fixtures/workshop_project/architecture_process_187/brief_stderr.py
  A fixtures/workshop_project/architecture_process_187/census_b5.py
  M fixtures/workshop_project/architecture_process_187/sdacha_187.md
  M fixtures/workshop_project/architecture_process_187/workflow_probe.py
  M scripts/check_architecture_contract.sh
git diff --stat f9f029592b 27983f424a -- scripts/ → только scripts/check_architecture_contract.sh, +45/−7: Б-5 8cc4375983 плюс исправление Б-1 6956c8c891 (+14/−2, только `arch187_brief`).
git diff --quiet f9f029592b 27983f424a -- contracts/ roles/ docs/ AGENTS.md → rc 0: норма и контракт не тронуты.
Авторство (git log f9f029592b..OBJECT, 8 коммитов): клетки 49d3042392 и 48a54bb27e — architect/architect; дверь 8cc4375983 и 6956c8c891 — implementer/implementer, только scripts/check_architecture_contract.sh; листы c3600b00e3 и 3b1590c231 — architect; merge d23d301ddd и 27983f424a — orchestrator.
(3) Неподгонка: git diff --stat 48a54bb27e 3b1590c231 -- fixtures/ → только sdacha_187.md (+53/−21). После ремонта клетки и стабы не менялись; ремонт implementer фикстуры не трогал. Клетки сигнала (48a54bb27e) легли раньше ремонта (6956c8c891).

══ (1) Б-1: КРАСНОЕ ДО, ЗЕЛЁНОЕ ПОСЛЕ ══
Мера A — клетки architect: `python3 brief_signals.py --repo <копия scripts/ варианта>`, библиотека — `git show <rev>:scripts/check_architecture_contract.sh`.
  call-1 d23d301ddd → rc 1:
    RED brief-signal-group-term: borrowed caller_rc=-15 leftover=['tmp.3eZOIssY5P'] | managed caller_rc=-15 leftover=['tmp.TLfF5tGXpD']
    RED brief-signal-group-int: borrowed caller_rc=-2 leftover=['tmp.cdJOBRRf3g'] | managed caller_rc=-2 leftover=['tmp.JpgdDZDD4H']
    GREEN brief-signal-parent-term; GREEN brief-cleanup-neighbor
  база a4f87d04a1 → rc 0: 4/4 GREEN. Capture-файла нет, значит нет и утечки — то же, что «База → leftover=[]» в Б-1.
  OBJECT → rc 0: 4/4 GREEN, borrowed и managed: leftover=[], neighbor=True.
Мера B — своя проба (`.scratch-rev187b5c/probe_b5c.py`), повторяет форму пробы вызова 1: `timeout -s SIG 0.9 bash -c '… out="$(arch187_brief api.identity 0)" …'`. Сигнал от timeout получает вся группа; CLI спит 3 с; managed — ARCH187_MODEL_TMP внутри TMPDIR.
  call-1: TERM borrowed caller_rc=124 leftover=['tmp.FdbIf7SWSX']; TERM managed 124 ['tmp.fXQ1pKaPRZ']; INT borrowed 124 ['tmp.k9ggsHH2vp']; INT managed 124 ['tmp.tBgxCX3J5O'].
  OBJECT: TERM borrowed/managed caller_rc=124 leftover=[]; INT borrowed/managed 124 leftover=[]; neighbor=True.
  TERM только родителю (CLI rc 1, ждёт 1.2 с): OBJECT borrowed/managed caller_rc=-15 leftover=[] stderr=b'ARCH_BRIEF_STDERR: E1\n'; call-1 — так же.
  Нормальная работа OBJECT (rules 0 и 1). rc 0: ok-body, ok-no-nl, ok-many-nl, ok-crlf — stderr пуст, строк ARCH_BRIEF_STDERR 0, leftover=[]. Отказ: fail-rc (rc 3), fail-empty (rc 0 и пустой stdout), fail-quiet (rc 5) — rc 1, строка `ARCH_BRIEF_STDERR:` ровно 1, leftover=[].
Прежние 78 клеток: `red_architecture_process_187.sh --repo .` → 82 distinct GREEN (своя мера по логу census), 0 RED.

══ (2) ПОБОЧНЫЕ ЭФФЕКТЫ ПОДОБОЛОЧКИ ══
  stdout при rc 0 побайтно совпадает у call-1 и OBJECT на 8 формах (4 тела × rules 0/1): b'PINNED\npayload: \xd1\x91\n', b'PINNED\n', b'A\n', b'A\r\nB\r\n'. stderr на отказе тоже совпадает побайтно, включая `(stderr модели пуст)`.
  Изоляция (вызывающий: set -euo pipefail, ловушки EXIT/TERM/INT/ERR, переменные comp/out/rc/errf/err/first/rest/line). Вызов `$(…)` и прямой вызов: TRAPS_SAME, OPTS_SAME (`trap -p`, `set -o`, `$-` до и после), переменные вызывающего не тронуты. R1=0 R2=0 на успехе, R1=1 R2=1 на отказе; EXIT-ловушка вызывающего сработала ровно один раз, на его выходе. Без ARCH187_MODEL_DIR — RC=1, stderr пуст, файлов нет. call-1 даёт то же.
  ARCH_BRIEF_OTKAZ: клетки brief-stderr-* с task-швом идут через настоящий scripts/make_task.sh и сверяют stderr точно, `…ARCH_BRIEF_STDERR: …\nОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (закреплённая модель не отдала бриф)\n` — GREEN в --repo. Вызывающий scripts/make_task.sh:1070 (`_arch_text="$(arch187_brief …)" || _arch_rc=$?`) не менялся.
  exit 143/130 не маскируют rc: ловушки TERM/INT срабатывают только на сигнале; на нормальной работе rc 0/1 (см. выше).
  Чужие файлы: сосед `tmp.neighbor*` уцелел во всех пробах OBJECT; М4 его удаляет (см. ниже).

══ (3) МУТАНТЫ ДВЕРИ ══
Мутанты строятся точной заменой внутри `arch187_brief` (`.scratch-rev187b5c/mk_mutants.py`). Прогон `red_architecture_process_187.sh --repo <полная копия git archive OBJECT + мутант>` последовательно, у каждого свой TMPDIR (`.scratch-rev187b5c/full_runs.sh`):
  честная копия → rc 0, CELLS=82 FAILURES=0 (83 GREEN = 82 + selfcheck)
  М1 нет EXIT-ловушки (:513) → rc 1, FAILURES=2: RED brief-signal-group-term leftover=['tmp.bs8bhPHhG3'], RED brief-signal-group-int leftover=['tmp.k2tb0shTZF']. ПОЙМАН.
  М2 нет `trap 'exit 143' TERM` (:514) → rc 0, FAILURES=0. ВЫЖИЛ: равносилен на bash 5.2.21 — EXIT подоболочки выполняется и при смерти от TERM (`( trap … EXIT; sleep 5 ) & kill -TERM` → exit-trap-ran, sub_rc=143). Своя timeout-проба: leftover=[]. Свойство не нарушено → совет С-1.
  М3 нет `trap 'exit 130' INT` (:515) → rc 0, FAILURES=0. ВЫЖИЛ, та же причина, timeout-INT: leftover=[] → совет С-1.
  М4a rm `"${TMPDIR:-/tmp}"/tmp.*` в EXIT-ловушке → rc 1, FAILURES=12: все 4 signal-клетки neighbor=False, плюс 8 brief-stderr ([INFERENCE] маска сносит tmp-файлы make_task). ПОЙМАН.
  М4b то же и в нормальном rm (:526) → rc 1, FAILURES=12. ПОЙМАН.
  М5 три ловушки после mktemp → rc 0, FAILURES=0. ВЫЖИЛ батарею. Окно достижимо, но дверь OBJECT его не содержит: развёртка случайного TERM группе в первые 70 мс вызова `$(…)` даёт М5 2/300 утечек, OBJECT 0/300. Шим медленного mktemp: OBJECT leftover=[] на TERM и INT, М5 и call-1 — leftover=['tmp.…']. Пробел батареи → совет С-2.
  М6 rm до чтения stderr → rc 1, FAILURES=4: RED brief-stderr-plain, -rules, -leading-blank, brief-empty-output-noisy. Новые signal-клетки на М6 зелёные, как и должно: это не их ветвь; ловит brief-stderr, стаб brief-signal-S3-early-delete → brief-stderr-plain. ПОЙМАН.
Новые клетки architect на честной двери зелёные (census signals/signals-control rc 0). На М1, М4a, М4b и call-1 они красные.

══ (4) СЫРОЙ ВЫВОД (OBJECT, TMPDIR внутри копии) ══
  census_b5.py b5c signals signals-base signals-control model stabs repo wiring → census rc=0. Режимы: signals 0, signals-base 0, signals-control 0, model 0 (CELLS=82 STABS=0 FAILURES=0), stabs 0 (CELLS=82 STABS=110 FAILURES=0), repo 0 (CELLS=82 STABS=0 FAILURES=0), wiring 0.
  Своя мера по логу census (подсчёт строк по меткам, не вывод CELLS=). model: 82 distinct GREEN, 0 RED. stabs: 82 GREEN, 110 строк `STAB … caught @`, 0 ZHIV. repo: 82 distinct GREEN, 0 RED.
  red_architecture_process_187.sh --repo . → rc 0, CELLS=82 STABS=0 FAILURES=0, 83 GREEN, 84 строки.
  red_architecture_process_187.sh --model → rc 0, CELLS=82 STABS=0 FAILURES=0.
  red_architecture_process_187.sh --stabs → rc 0, CELLS=82 STABS=110 FAILURES=0, 110 caught, 194 строки.
  red_architecture_process_187.sh --wiring . → rc 0.
  bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run → rc 0, «СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)».
  red_done_dver_201.sh --repo . → rc 0, CELLS=62 STABS=0 FAILURES=0.
  fixtures/workshop_project/sessii_136/red_sessii_136.sh → rc 0, «клеток 87, зелёных 87, красных 0».
Советы вызова 1 (С-1…С-5, М10) вне скоупа и повторно не судились.

══ (6) НОРМА ══
Нормативные документы, контракт и роли в диффе не тронуты (rc 0 выше).

ОСТАТОК: строк `НЕ ЗАЩИЩАЕТ` с ловцом reviewer в contracts/187-arhitektura-v-processe.md нет. Три строки :73-75 (вход 170, project CI, sourceCanon) — дифф их не касается, не укусил.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам ремонта Б-1:
  `arch187_brief` — тело-подоболочка и 3 ловушки (scripts/check_architecture_contract.sh:509-542).
    (1) свойство «файл захвата удаляется ВСЕГДА, в т.ч. при сигнале» (тело PR, Б-1).
    (2) новое состояние — одна локальная errf внутри подоболочки, видна только через FS. Наружу интерфейс не менялся: те же аргументы, stdout, rc 0/1.
    (3) при следующей правке меняются вместе 1 файл двери + клетки; дифф число не увеличил.
    (4) интерфейс не вырос, работа выросла: модуль глубже.
    (5) потребитель — make_task.sh:1070 и клетки brief-signal-*; грамматику не дублирует.
    Итог: ESSENTIAL. Строки :514-515 на bash 5.2 равносильны, см. С-1 — совет: без них приёмка тоже проходит, но отсутствующее свойство не названо.
  brief_signals.py — одна семья case-фикстур.
    (1) то же свойство на реальной группе процессов.
    (2) состояние — tempdir на прогон, явно в выводе (leftover/neighbor/caller_rc).
    (3) меняется вместе с workflow_probe.py, счёт CELLS/STABS.
    (4) интерфейс один (--repo/--control).
    (5) потребитель — census и CI-батарея 187 через workflow_probe.
    Итог: ESSENTIAL.
  census_b5.py, режимы signals/signals-base/signals-control.
    (1) красное до и зелёное после, база и контроль.
    (2) логи в TMPDIR явно.
    (3) один файл.
    (4) режимы — то же, что запуск brief_signals с иным tools.
    (5) потребитель — двери листа check_sdacha (двери=5).
    Итог: ESSENTIAL, совет не нужен.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep -c — 0). Сверено с формой дерева. Ремонт повторяет идиому вызывающего make_task.sh:565 (EXIT-ловушка до mktemp, rm своего файла по имени). Ошибки: прежний возврат 1 и именованный отказ ARCH_BRIEF_OTKAZ сохранены. Данные: stdout побайтно прежний. Расхождений нет.
СВЕРКА-АРХИТЕКТУРЫ: размещение — правка внутри существующей функции `arch187_brief` библиотеки scripts/check_architecture_contract.sh; клетки — в семье fixtures/workshop_project/architecture_process_187/ (зона architect). Новых зависимостей нет: bash trap/mktemp; в клетках python3, node, os.killpg. Писатель — только свой scratch-файл в TMPDIR; чужие файлы не удаляются, проверено соседом и М4. Операции и bindings.json не затронуты (tooling/checks/cli.js и architecture/ в дереве нет). Долг не расширен, кроме уже бывшего в main шаблона arch187_model_check — С-3. Diff модели нет, L-уровень не применим, находку `finding new` заводить не по чему.

СОВЕТЫ: .review/2026-11-21-126.md — С-1 (М2/М3 равносильны на bash 5.2), С-2 (М5 не прибит клеткой; окно измерено), С-3 (тот же класс в arch187_model_check, вне диффа), С-4 (остаточное окно внутри mktemp).
МАТЕРИАЛЫ: .scratch-rev187b5c/{v,full-*,probe,mk_mutants.py,probe_b5c.py,full_runs.sh,item4.sh,time_mktemp.py} в копии; в коммит не входят. Push не делал, в основной чекаут и docs/owner/ не писал, тег done не ставил.
