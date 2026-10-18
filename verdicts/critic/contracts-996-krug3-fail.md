FAIL
OBJECT=847e7f07c4588aac50f6d154b211ce175eeab920
Предмет: contracts/996-rezhim-proekta-polnyj-cikl.md (sha256 a0dbc0e1…e37f) и fixtures/workshop_project/rezhim_996/
(probe.sh, probe.py, model.py, plan_adapter.sh, zones_adapter.sh), ветка wip/996/architect. Круг 3 из 3 (кап
docs/owner/2026-10-18-tri-slota.md §3). Критик.

## Итог

Набор артефактов полон. Есть предмет, критерий с командами, исполнители, ЗОНА-строки и РАБОТА НЕ РАЗДАЁТСЯ.
Блокер круга 2 закрыт в том объёме, в каком он был назван. Все 15 GATE_CASES и все гейт-мутанты (skip-gates,
skip-spec/consumers/precision/doc/provodka/n39/form/plan/committed, root-plan) краснеют именно на своих
сценариях. Мутанты кругов 1–2 краснеют тоже, включая советы круга 2: done-leak и profile-over-override.
Честная модель зелёная: 69 сценариев, 50 мутантов, 0 расхождений. Продукт без реализации: rc1, 57 расхождений.
Это совпадает с замером архитектора.

FAIL ставлю по правилу кругов §3, пункт «недостоверное доказательство». Ниже три исполненных обхода внутри
УЖЕ принятых границ :51. В каждом матрица остаётся rc0, а принятый пункт :51 нарушен. В двух из трёх его нарушает
сам эталон model.py/plan_adapter.sh: «честная» модель матрицы — это дефектная реализация, и критерий её
пропускает. Новых требований нет. Каждый пункт буквально стоит в :51 на 9ffd1b95 (принят кругом 2) либо
объявлен самим критерием 6 (:87).

Класс один, и он ТОТ ЖЕ, что в круге 2. Пункт :51 «сохраняются …» / «корневые registry — не запасной источник»
не имеет проектного негатива. Поэтому реализация, которая его теряет, по наблюдаемому неотличима от честной.
Круг 2 закрыли точечно, перечнем названных гейтов, а не обобщённо по всему списку :51. Правило §3 требует
обобщённого исправления при повторе класса.

STOP: по §3 после третьего FAIL нужна остановка и пересмотр объёма/нарезки через оркестратора, не автопринятие.

АРБИТР: созывается (второй FAIL по одной причине; критик называет сам, роль critic §«Второй FAIL»). Арбитр —
роль arbiter. Предмет спора: обязан ли офлайн-критерий 6 (:87) нести проектный негатив и мутант на КАЖДЫЙ
пункт :51 «сохраняются …» (грамматика первых строк, авторство/коммит реестра, закрытия плана) или достаточно
перечня GATE_CASES, выбранного автором, плюс legacy-регрессий. Вне спора и независимо от исхода: эталон,
который сам читает корневой registry (Б1), — недостоверное доказательство по §3.

## Блокирующие находки

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:51 («Корневые contracts/verdicts/registry внешнего репо —
не запасной источник»; принято на 9ffd1b95:51) + :51 («закрытия — соседний closed-without-done.tsv») + :87
(критерий 6: «профильный plan при разрешающей корневой приманке») + :77 («plan_adapter — настоящую lib_plan»).
Эталон plan_adapter.sh:15 зовёт неизменённый `p84_p0p1 "$root" 1`. Он считает статусы через plan_status,
а plan_status читает `HEAD:registry/closed-without-done.tsv` КОРНЯ (scripts/lib_plan.sh:353). Значит, эталон
открывает заморозку по корневой приманке закрытий и не видит закрытий проекта. В freeze-plan-preserved есть
приманка только в виде plan.tsv, закрытий нет ни в одном из 69 сценариев.
ОБХОД: пакет C переводит в lib_plan только путь plan.tsv (как plan_adapter), а plan_status оставляет на
`registry/closed-without-done.tsv`. Тогда probe.sh и --matrix rc0, критерий 6 выполнен. При этом в проекте с
планом 775/1, 776/2, 777/3 корневой `registry/closed-without-done.tsv` со строкой 775 замораживает 777 (rc0,
тег frozen/contracts/777/1), хотя профильный план его отвергает. А настоящее закрытие 775 в
`.harness/ledger/closed-without-done.tsv` игнорируется: rc1 «контракт вне плана». Исполнено на эталоне
(closures_decoy.py), сырой вывод ниже. Контроль: действующий продукт в legacy-раскладке закрытия соблюдает
(legacy_closures_author.py): с закрытием rc0, без него rc1 «вне плана (P0 1, P1 2)».
ЗАКРЫТЬ: сценарий freeze-closures-preserved с корневой приманкой закрытий (отказ) и закрытием проекта (rc0,
тег); мутант root-closures. Эталон считает закрытия по `<registry>/closed-without-done.tsv`.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:51 («freeze пишет профильный registry»; «Сохраняются …
кап и авторство»; принято на 9ffd1b95:51) + :83 (критерий 2). Действующая freeze коммитит реестр атомарно с
тегом и под identity orchestrator (scripts/freeze_contract.sh:456-459; комментарий :454 называет потерю:
незакоммиченная строка «подхватывается случайным следующим коммитом любой identity/зоны»). freeze-profile
(probe.py:589) сверяет только байты рабочего дерева `reg.read_text()`, без HEAD и %an. Эталон model.py:358
(`git commit -qm 'model freeze registry'`) коммитит под identity сессии «Fixture». Для mint та же
проба авторство проверяет (probe.py:496, `%an == orchestrator`), для freeze — нет.
ОБХОД: (а) мутант registry-uncommitted: freeze пишет `<registry>/contracts.tsv` и не коммитит. Итог 69/69
rc0, SURVIVES, строка реестра не в истории (потеря данных по классу :454). (б) мутант
registry-author-architect: коммит реестра под architect. Итог 69/69 rc0, SURVIVES. (в) сам эталон:
registry-author=Fixture при rc0, тогда как продукт в legacy даёт registry-author=orchestrator. Исполнено
(mutate3.py, legacy_closures_author.py).
ЗАКРЫТЬ: в freeze-profile проверять `git show HEAD:<registry>/contracts.tsv == expected` и
`git log -1 --format=%an -- <registry>/contracts.tsv == orchestrator`, плюс два мутанта выше.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:51 («Сохраняются грамматика первых строк»; принято на
9ffd1b95:51). Действующие двери отвергают ESCALATE и строку вне грамматики (freeze_contract.sh:219-220,
done_contract.sh:117,123). Ни один из 69 сценариев не предъявляет проектный вердикт ESCALATE или вне
грамматики: freeze-decoy, done-decoy и done-fresh несут только FAIL.
ОБХОД: мутант critic-not-fail-is-accept (freeze принимает всё, кроме `FAIL`) даёт 69/69 rc0, SURVIVES. Мутант
review-grammar (done принимает всё, кроме `fail`) тоже 69/69 rc0, SURVIVES. В обоих случаях проектный
`ESCALATE` критика или ревьюера ведёт к frozen- или done-тегу. Исполнено (mutate3.py, mut-review-grammar).
ЗАКРЫТЬ: GATE_CASES freeze-escalate и done-escalate (плюс строка вне грамматики), у каждого исправление того же
входа → rc0 и тег. Мутанты — выше.

Обобщённое закрытие, требуемое §3: пройти перечень :51 целиком и для КАЖДОГО «сохраняется X» и «корневое — не
источник» дать сценарий с мутантом, либо явно вывести пункт из 996 в тексте. Всё перечисленное лежит в
ЗОНА architect (fixtures/workshop_project/rezhim_996/). Продуктовая правка закрытий — lib_plan, это уже зона C.

## Советы (не блокируют)

СОВЕТ :51 («читает HEAD-блоб `<registry>/plan.tsv`»). Мутант worktree-plan (plan_adapter читает рабочее дерево)
даёт 69/69 rc0, SURVIVES: незакоммиченная правка плана открывала бы заморозку (Р3 084). Формулировку HEAD-блоба
добавил круг 3, поэтому это совет. Закрывается сценарием «незакоммиченная правка плана» в той же семье.
СОВЕТ :51, :123 («`lib_plan` и его потребитель `check_charter`»). check_charter.sh lib_plan не сорсит, его
сорсят check_plan, gen_plan, track_digest и freeze_contract (grep `lib_plan.sh` по scripts/). Дельта B для
check_charter («только профильные пути plan/closed/contracts», :123, ПЕРЕСЕЧЕНИЕ 065) не имеет предмета в
plan/closed. Кольцо устава check_charter (:228 `plans/*|contracts/*`) в проектной раскладке не защищает
замороженный `.harness/tasks/NNN-*.md`, и пробы на это нет. Назовите, что именно меняется в check_charter,
иначе исполнитель решит сам (вопрос 3).
СОВЕТ :67/:123 — лишние пути выносить не нужно: lib_plan (C) пересекается только с implementer-зоной 084
(одна identity, ПЕРЕСЕЧЕНИЕ не требуется по конвенции), а check_charter (B) — с architect-зоной 065, и
ПЕРЕСЕЧЕНИЕ :133 объявлено. precision-гейт rc0.
СОВЕТ — клапан done «v>1 требует РАЗРЕШИЛ-ВЛАДЕЛЕЦ» (done_contract.sh:178) в :51 не назван и пробой в проекте
не закреплён. Если он «сохраняется», впишите его в список вместе с обобщённым закрытием.
СОВЕТ probe.py — временные миры создаются с префиксом `architect996-` (видно в stderr матрицы). Это
косметика, но в журналах судей сбивает авторство.

Проверено без замечаний. Зоны и нарезка (A–E, расширение lib_plan→C, check_charter→B, ПЕРЕСЕЧЕНИЕ 065
грамматически валидно, pre_critic rc0). Н-39: привязка мутаций только в MUTANTS, covered==CASES держит проверка
probe.py:749-752, проза чистая, Н-39 гейт pre_critic зелёный. Норма 041: check_threat_model rc0, 5/5. Норма
043: check_precision_gate rc0 OK. ПРОВОДКА: rc1 до санкции владельца, это ожидаемо, интеграционный коммит
оркестратора назван на :71. Cognitive-only остатки (:73 раздельность B/C/D, :100 чтение контекста живым
агентом) объявлены и приняты ноутбуком/судьями. Cutover канона: self-canonical в продукте на HEAD красный
(SELF_CANONICAL_CUTOVER_BROKEN), как и должно быть до пакета A. Продуктовые precritic-*-preserved уже rc0 на
HEAD: pre_critic --repo из 103 гейты сохраняет, сценарии работают как регрессионный страж пакета C.

## Сырой вывод (исполнено в /tmp/dev-harness-verify/critic996r3/, копии dh-*, mut-*)

```
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix                 # dh-matrix @ 847e7f0
… 69× rc=0 …
mutation done-leak: station-isolation: rc=1 STATION_DONE_POLLUTED_INSTALLATION … загрязнён: HANDOFF.md
mutation profile-over-override: git-override: rc=1 EXPLICIT_CANONICAL_OVERRIDE_IGNORED
mutation root-plan: freeze-plan-preserved: rc=1 PROJECT_GATE_BYPASSED:plan rc=0
mutation skip-gates: <все 15 GATE_CASES>: rc=1 PROJECT_GATE_BYPASSED:<defect> rc=0
mutation skip-spec: freeze-gate-preserved|precritic-spec-preserved: rc=1
mutation skip-consumers: freeze-consumers-preserved|done-consumers-preserved: rc=1
mutation skip-precision: freeze-precision-preserved|precritic-precision-preserved: rc=1
mutation skip-doc: freeze-doc-preserved|freeze-doc-malformed: rc=1
mutation skip-provodka: done-gate-preserved: rc=1 ;  skip-n39: precritic-n39-preserved: rc=1
mutation skip-form: precritic-context-preserved|precritic-existing-preserved: rc=1
mutation skip-plan: freeze-plan-preserved: rc=1 ;  skip-committed: freeze-/done-committed-preserved: rc=1
(+ мутанты кругов 1–2: hardcoded-origin, trust-target, root-verdict, ignore-critic/review, old-review,
 accept-escape, station-writes-tools, tools-leak, skip-canon, root-context, fallback-root, root-arbitration,
 reserve-force, root-contracts-only, … — все rc=1 на своих сценариях; всего строк mutation: 97)
996: examined=69 mutants=50 mismatches=0        real 0m16.3s        RC=0
$ git -C dh-matrix status --porcelain | wc -l → 0

$ bash fixtures/workshop_project/rezhim_996/probe.sh                          # dh-prod, продукт без реализации
freeze-*-preserved / done-*-preserved: rc=1 PROJECT_GATE_BYPASSED:<defect> … «вложенные пути не замораживаются» / «имя контракта не по грамматике NNN»
precritic-{spec,precision,n39,context,existing}-preserved: rc=0
zones-project: rc=1 PROJECT_ZONE_FAIL_OPEN … «зон не объявлено — проверять нечего»
self-canonical: rc=1 SELF_CANONICAL_CUTOVER_BROKEN
996: examined=69 mutants=0 mismatches=57        996: проектный цикл не замкнут        RC=1
$ git -C dh-prod status --porcelain | wc -l → 0

$ python3 closures_decoy.py dh-mut          # эталон model.py, проектная раскладка, план 775/1 776/2 777/3
A root-decoy closes 775 (expect rc1)     model freeze rc=0 tags=[frozen/contracts/777/1] err=''
B project closes 775 (expect rc0)        model freeze rc=1 tags=[] err='ОТКАЗ: контракт вне плана: 777'
C no closures (expect rc1)               model freeze rc=1 tags=[] err='ОТКАЗ: контракт вне плана: 777'

$ python3 legacy_closures_author.py dh-mut  # действующий продукт (legacy) vs эталон (профиль)
legacy, closures close 775         product-legacy freeze rc=0 tags=[frozen/contracts/777/1] registry-author=orchestrator []
legacy, no closures                product-legacy freeze rc=1 tags=[] registry-author=- ['ОТКАЗ: контракт вне плана: 777 — не в текущей/следующей паре registry/plan.tsv (P0 1, P1 2)']
honest model project freeze rc=0 tags=[frozen/contracts/777/1] registry-author=Fixture

$ python3 mutate3.py                        # дефект безусловно в копии эталона, probe.py --model, все 69 сценариев
registry-uncommitted: rc=0 killed_by=0 ['996: examined=69 mutants=0 mismatches=0'] SURVIVES
registry-author-architect: rc=0 killed_by=0 ['996: examined=69 mutants=0 mismatches=0'] SURVIVES
worktree-plan: rc=0 killed_by=0 ['996: examined=69 mutants=0 mismatches=0'] SURVIVES
critic-not-fail-is-accept: rc=0 killed_by=0 ['996: examined=69 mutants=0 mismatches=0'] SURVIVES
$ (mut-review-grammar: done `body.strip().lower() == 'fail'`) probe.py --model
996: examined=69 mutants=0 mismatches=0     RC=0  SURVIVES

$ bash scripts/pre_critic.sh --repo . contracts/996-…        → КРИТИК: дверь зелёная, rc=0
$ bash scripts/check_threat_model.sh . contracts/996-…       → секция валидна (ЗАЩИЩАЕТ 5, НЕ ЗАЩИЩАЕТ 5), rc=0
$ bash scripts/check_precision_gate.sh <клон> contracts/996-… → OK, rc=0
$ bash scripts/check_spec_ready.sh . contracts/996-…         → OK, rc=0
$ bash scripts/check_provodka.sh . contracts/996-…           → норма-строка не найдена в role-файле: roles/orchestrator.md, rc=1 (до санкции)
$ bash scripts/check_zones.sh .                              → замороженных контрактов: 102 · объявленных авторов: 5 · коммитов в диапазонах: 15261 · проверено по зонам: 3027, rc=0
```

Скрипты репро: /tmp/dev-harness-verify/critic996r3/{closures_decoy.py,legacy_closures_author.py,mutate3.py}.
Основной чекаут не тронут. Push не делался. Вердикт не закоммичен (страж Н-85).
