FAIL
OBJECT=1c25b7e9f0527083b5ab35258782df3d1ca4226c

# Суд 996 (режим проекта), круг 4 — микро-круг, последний по капу. Reviewer Rev996r4

Находки: `/tmp/dev-harness-verify/Rev996r4/review.md` (reslop, `status: ready`) — оркестратору в `.review/`.
Ось: закрытие Р3-1/Р3-2 (`verdicts/review/contracts-996-v3.md`, `.review/2026-10-19-16.md`) и серии
круга 2 (`.review/2026-10-19-08.md`) без регресса. Сверка — по frozen-блобу
`git show frozen/contracts/996/1^{commit}:contracts/996-rezhim-proekta-polnyj-cikl.md`.

## Итог

Р3-1, Р3-2, adversary-2/С3-1 и круг 2 закрыты по существу: обходы круга 3 повторены и теперь
отказывают. FAIL по одной блокирующей находке **Р4-1** — регресс, который внёс сам фикс 3ea6705b0
(ветвь FALLBACK-NO-WORKFLOW единого resolver): при объявленном sourceCanon и профиле без
workflowPaths контекст ролей и промпт сессии получают `sourceCanon: null`, а pre_critic при этом гоняет
гейт канона. Код круга 3 на том же профиле отказывал (rc 1). Обход назван, более простая форма в одну
строку проверена на тех же строках приёмки. Это последний круг: FAIL → форк консультанту.

## Сырые прогоны (мой клон, ssh)

```
$ git clone -q ssh://git@github.com/a3ka/dev-harness.git clone && git checkout -q 1c25b7e9…   rc=0
$ git log --oneline -1                → 1c25b7e9 land: wip/996/implementer
$ git rev-parse origin/main           → a6733adb4c74c7514b50077f8657a81ae5884442

$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=110 mutants=0 mismatches=0                                    probe rc=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=110 mutants=75 mismatches=0                                   matrix rc=0
```
Своя мера (не вывод автора): `awk -F': ' '/: rc=/{print $1}' probe.out | sort -u | wc -l` → 110
уникальных клеток, `… | uniq -c` → `110 rc=0`; `grep -oE '^mutation [a-z0-9-]+' matrix.out | sort -u | wc -l`
→ 75 различных мутантов.

Красное предъявлено (одноразовый clone_red @ 1fcf94502 — клетки architect поверх кода круга 3):
```
$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=110 mutants=0 mismatches=13 / 996: проектный цикл не замкнут   probe@1fcf9450 rc=1
```
Красные 13 = ровно новые: state-escape-{print-context,kind-task,workshop},
state-symlink-{print-context,kind-task,workshop}, dotdot-{resolver,print-context,kind-task,workshop},
pack-source-symlink-secret, pack-no-source-body, make-task-drift. На OBJECT все 13 зелёные.

Frozen-барьеры и норма:
```
$ git diff --stat frozen/contracts/996/1 1c25b7e9 -- contracts/996-rezhim-proekta-polnyj-cikl.md   → пусто, rc=0
$ git diff frozen/contracts/996/1 1c25b7e9 -- fixtures/workshop_project/rezhim_996/ | grep -E '^-[^-]'
```
удалённые строки — только рефактор модели (`contained`/`layout` с параметром mutant) и две строки
матрицы, заменённые РАСШИРЕНИЕМ (`broken-profile-fallback` +freeze/done-broken-profile,
`canon-null-absent` +defaults-null-canon); ни одна клетка/мутант не снят.
Implementer (0071ad469, b56b969b7, 3b3375d0c, 3ea6705b0) менял ТОЛЬКО `scripts/next_id.sh`,
`scripts/make_task.sh`, `workshop` (зона implementer §Зоны L122); фикстуры/пробы не трогал. Architect
1fcf94502 — только `fixtures/workshop_project/rezhim_996/{probe,model}.py` (своя зона). Коммиты атомарны
по находке.

Scoped-регресс и toy-миры:
```
$ bash scripts/scope_select.sh . --scope next_id      → MODE: scoped KEY: next_id
$ bash scripts/verify_antiplacebo.sh --scope next_id  → барьеров: 1 · предъявлено красным: 1   rc=0
$ bash fixtures/_krasnye_060.sh   → честных 17/17, стабов 15/15, итог 060: rc=0          rc=0
$ bash fixtures/_krasnye_058.sh   → честная часть 16/16, стабы 9/9 + дифф 9/9, итог 058: rc=0   rc=0
```
(`make_task`/`workshop` ключами scope_select не являются: «неизвестный ключ make_task».)

## Сверка оси — эксперименты вне дерева (exp/exp.py, exp/exp2.py; настоящие скрипты OBJECT)

Р3-1 (повтор обхода круга 3, `state=st`, `st → <base>/outside`):
```
e1 project_workflow                  rc=1  workflowPaths вне репо: state
e1 make_task --print-context reviewer rc=1 ОТКАЗ: workflowPaths вне репо   (<R>/st в выводе: нет)
e1 workshop --print-context          rc=1
e1 make_task --kind task             rc=1
e4 control workshop --probe (+.env, pin) rc=0 PROBE OK; промпт: WORKFLOW_handoff=<R>/.harness/HANDOFF.md, sourceCanon:{…SOURCE.md…}
e4 state-escape workshop --probe     rc=1  workflowPaths вне репо: state
e4 registry-escape workshop --probe  rc=1  workflowPaths вне репо: registry
```
Одно определение resolver во всём дереве (grep `project_paths_resolve\s*\(\s*\)|function\s+project_paths_resolve`
по всему клону, включая `workshop`): `scripts/next_id.sh:333` и только оно.

Р3-2:
```
e2 честное --kind task   rc=0  'SOURCE.md' есть, 'sourceCanon' есть, тело 'No bypass' — НЕТ
e2 SOURCE.md → secret    check_project_sources rc=1 SOURCE_CANON_INVALID; make_task --kind task rc=1
                         «источник вне репо: source=SOURCE.md»; OUTSIDE-SECRET-42 в выводе — нет
e2b SECOND.md → secret   check_project_sources rc=1; make_task --kind task rc=0, секрета нет (совет С4-3)
```

## Р4-1 — блокирующая (регресс 3ea6705b0)

Обязательства: §A L65 «sourceCanon — эффективный юнит либо null при отсутствии … тот же контекст, который
штатный запуск добавляет в сессионный prompt/задание»; §D L63 «передают … effective sourceCanon в
контекст всех ролей, в том числе судей». Фрагмент: `scripts/next_id.sh:394-420` FALLBACK-NO-WORKFLOW,
литерал `"sourceCanon":null` на `:408`. Схема допускает профиль без workflowPaths
(`profile_resolver.sh:47 repo:workflowPaths:optional`).

ОБХОД — дерево OBJECT (проба 110/0, matrix 75/0, 058/060 rc 0), профиль `world`+`canon()` без workflowPaths:
```
e3 profile_resolver                 rc=0  sourceCanon и SOURCE.md в слиянии
e3 check_project_sources            rc=0  gate-observed.json: cwd=<R>, stage=pre_critic, arg='literal ; $(not-shell)'  (гейт ЗАПУЩЕН)
e3 pre_critic                       rc=0  КРИТИК: дверь зелёная
e3 project_workflow                 rc=0  …,"sourceCanon":null}
e3 make_task --print-context critic rc=0  .sourceCanon = null  .startup[0] = <R>/HANDOFF.md
e3 workshop --print-context         rc=0  SOURCE.md — нет
e3b workshop --probe (+.env, pin)   rc=0  PROBE OK; промпт сессии: 'sourceCanon:null'
```
Тот же профиль на коде круга 3 (clone_red @ 1fcf94502, implementer-код = 75eb586d):
```
e3 project_workflow                 rc=1  project_paths_resolve: профиль без workflowPaths.contracts
e3 make_task --print-context critic rc=1  ОТКАЗ: workflowPaths вне репо: contracts=
e3 workshop --print-context         rc=1
```
Было fail-closed, стало молчаливое «канона нет» у ролей при гейте, который дверь требует.

Более простая форма (clone_red: checkout 1c25b7e9 + одна строка в той же ветви — печать через
`| jq -c --argjson sc "$(printf '%s' "$MERGED" | jq -c '.sourceCanon.value // null')" '.sourceCanon = $sc'`):
```
e3 project_workflow                 rc=0  SOURCE.md в выводе
e3 print-context critic             .sourceCanon = {"sources":[{"path":"SOURCE.md","priority":0}],"gate":[…]}
e3 pre_critic                       rc=0
bash fixtures/_krasnye_060.sh       итог 060: rc=0
bash fixtures/workshop_project/rezhim_996/probe.sh   996: examined=110 mutants=0 mismatches=0   rc=0
bash fixtures/_krasnye_058.sh       итог 058: rc=0
bash fixtures/workshop_project/rezhim_996/probe.sh --matrix   996: examined=110 mutants=75 mismatches=0   rc=0
```
Класс: регресс оси «без регресса» + 050 (свойство «канон из слияния» выброшено, более простая форма
проходит те же строки приёмки). Обход: состояние дерева, где весь критерий приёмки (probe/matrix/CI)
зелёный, а §D для этого профиля не исполнен.

## Норма «изоляция в roles/» (по frozen-тексту L71, сверх него не требую)

Своя мера: frozen-строка arbiter (`sed -n 152p` блоба, 558 байт с кавычками) `grep -cF` →
orchestrator 0, architect 0, implementer 0, critic 0, adversary 0, reviewer 0, consultant 0, steward 0;
arbiter 1. Собственные строки ролей из §ПРОВОДКА — 7/7 (orchestrator/architect/critic/implementer/
adversary/reviewer/arbiter по 1), owner-коммит a0b28d0ff «РАЗРЕШИЛ-ВЛАДЕЛЕЦ … семь норма-строк».
L71: размещение общей строки в 8 ролях — шаг оркестратора «после санкции … до done и проверки
check_provodka»; «До санкции этот шаг заблокирован, не считается исполненным». Санкция a0b28d0ff
покрывает семь собственных строк, не размещение в 8 ролях (consultant/steward в ней нет). Значит
0/8 — не дефект реализации и не предмет этого суда; блокирует done (совет С4-5 в review.md).

## 050 — паразитная сложность по артефактам диффа круга 4

- `_dotdot_segment` (next_id.sh): (1) L39 «`..` → rc1» + контроль С3-1 сегментом; (2) состояние нет,
  аргумент → rc; (3) 1 файл, число не выросло (заменил две case-ветви `*..*`); (4) 1 аргумент/rc против
  разбора сегментов — глубокий; (5) потребители — клетки dotdot-*. ESSENTIAL.
- ветвь FALLBACK-NO-WORKFLOW (next_id.sh:394-420): (1) L41 «профиль без новых полей сохраняет прежнее
  слияние», 060 к7/к8; (2) неявное — срабатывает по отсутствию ключей, в выводе не видно, что канон
  выброшен; (3) вторая копия JSON-шаблона LEGACY-FALLBACK — при правке набора ключей меняются 2 места в
  одной функции (было 1); (4) интерфейс не вырос; (5) потребитель — 060 к7/к8, дублирует шаблон
  LEGACY-FALLBACK. Свойство ESSENTIAL, форма ACCIDENTAL: литерал null — Р4-1 (блок), дубль — С4-1 (совет).
- проброс HARNESS_PROJECT_LAYER_ROOT (next_id.sh:385): (1) 060 к7/к8 + согласование с
  check_project_sources/pre_critic `${HARNESS_PROJECT_LAYER_ROOT:-…}`; (2) env явный; (3) 1 файл;
  (4) без нового интерфейса; (5) 060. ESSENTIAL.
- make_task: два собственных расчёта путей заменены одним вызовом resolver (−87 строк нетто по
  b56b969b7) — ESSENTIAL, сложность убыла. Гард `sources[0]` PROJECT-секции (make_task.sh:252-263):
  (1) клетка pack-source-symlink-secret; (3) частичная копия ФС-проверки check_project_sources;
  (5) судит только первый источник — С4-3 (совет: утечки нет).
- workshop:907-908 `die` вместо `_pw_json_omitted`: (1) Р3-1/L65 «валидацию не отключает» — ESSENTIAL,
  сложность убыла.
- семья 13 клеток + 4 мутанта (architect, одним артефактом): (1) Р3-1/Р3-2/adversary-2; (2) миры
  одноразовые; (5) потребитель — probe.sh в CI. ESSENTIAL.

## sourceCanon (996-строка reviewer)

У самого предмета (харнесс) sourceCanon не объявлен (`harness.project.json` — workflowPaths с
`state: "."`, без sourceCanon) — гейт сверки к этому суду неприменим.
