FAIL
OBJECT=b8eb3960c269d70efeb3dfe2f2202c872fb13bef
Предмет: contracts/996-rezhim-proekta-polnyj-cikl.md + fixtures/workshop_project/rezhim_996/ (probe.sh, probe.py, model.py), ветка wip/996/architect. Круг 1. Критик.

## Итог

Набор артефактов полон (предмет, критерий с командами, исполнители, ЗОНА-строки + РАБОТА НЕ РАЗДАЁТСЯ).
Полнота относительно слова владельца: 2030 §2 пп.1–4 и 2330 п.5 покрыты ТЕКСТОМ контракта. §3
верно отнесён к бэкенду, ноутбучный прогон верно помечен NOT_RUN. Лишнего сверх слова не найдено.
Матрица честная: `--matrix` rc0, продукт без реализации rc1. Шум не найден.

FAIL ставлю потому, что у исполняемого критерия семь слепых пятен. В каждом названное
свойство предмета не проверяется ни одной пробой. Семь мутантов модели (своих, вне матрицы)
проходят все 18 сценариев (`killed_by=0/18`). Ещё два обхода сидят в нетронутом коде на HEAD.
Их дают lib_zones fail-open и отсутствие проб пакета D. Каждая находка закрывается добавлением
сценария и пары мутантов в probe.py/model.py, то есть внутри ЗОНА architect. Прозу контракта
менять почти не нужно.

## Блокирующие находки

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:62-64 (пакет D) + :81-86 — у пакета D нет ни одной
пробы. Это доставка путей и sourceCanon в контекст ролей, суффикс `verdict:` судей и стартап с
HANDOFF/NABLIUDENIA* в state проекта. На нём держится 2030 §2 п.3 «станция проекта не пишет в
HANDOFF.md, NABLIUDENIA*.md харнесса». Субъекты пробы перечислены в fixtures/.../probe.py:91-100:
project_workflow, gitw, freeze, done, pre_critic, sources, reserve. workshop и make_task среди них нет.
Регрессии из п.6 `_krasnye_103.sh` и `_krasnye_105.sh` уже rc0 на HEAD, без всякой реализации
(замер ниже).
ОБХОД: `workshop` и `scripts/make_task.sh` не тронуты. Пакеты A/B/C реализованы, поэтому probe.sh rc0,
`--matrix` rc0, 054/103/105 rc0, verify_ci_parity rc0, и критерий выполнен. Тем временем роли в
сессии проекта получают корневые verdicts/HANDOFF установки, и судьи пишут вердикты не в
`.harness/`.
ЗАКРЫТЬ: добавить сценарий(и) через публичный CLI make_task/workshop (режим генерации контекста без
запуска omp) на toy-проекте со state `.harness`. Сверять абсолютные пути verdicts/handoff/observations/forks
и sourceCanon в выданном контексте с оракулом и проверять, что пути установки отсутствуют. Мутант
`root-context` даёт пути установки.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:52 («Корневые contracts/verdicts/registry внешнего репо — не
запасной источник»; «читают ВСЕ вердиктные пути профиля (включая critic-history/cap/arbitration)»)
+ :82. Обе decoy-пробы (probe.py:154-157) кладут ПРОФИЛЬНЫЙ FAIL рядом с корневым accept. Fallback
вида «профильного файла нет → читаем корень» не наблюдается. Чтение arbitration/cap/critic-history
(freeze_contract.sh:348,398 на HEAD читают корневые `verdicts/critic`, `verdicts/arbitration/`) не
проверяется ни одним сценарием.
ОБХОД: freeze/done берут профильный вердикт, а при его отсутствии `verdicts/critic|review/...` корня.
Арбитраж для капа читают из корневого `verdicts/arbitration/`. Мутант `fallback-root` проходит
18/18 (сырой вывод ниже). Корневая приманка-accept замораживает и закрывает проектный контракт,
у которого профильного вердикта нет вовсе.
ЗАКРЫТЬ: сценарии `freeze-root-only` и `done-root-only`: профильного вердикта нет, в корне accept
→ rc1, тега нет, HEAD неизменен. Плюс сценарий капа: N критик-FAIL в профиле и корневой
arbitration-приманка → rc1. К ним мутанты fallback-root и root-arbitration.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:98 («station-isolation запускает настоящий detector на
отдельном disposable install») + :64. В probe.py:201-226 детектор снимает и сверяет каталог
`base/install`, но субъект (freeze) исполняется из `HARNESS_TOOLS_ROOT=TOOLS` (probe.py:83-85). `install`
субъекту не передан и им не используется. Парный мутант `station-writes-tools` (model.py) пишет именно
в этот муляж. Пара «стаб ↔ ветвь» подогнана под топологию пробы, а не под предмет.
ОБХОД: проектный freeze/done дописывает `$HARNESS_TOOLS_ROOT/registry/contracts.tsv` и
`$HARNESS_TOOLS_ROOT/HANDOFF.md` установки. Мутант `tools-leak` проходит 18/18 и РЕАЛЬНО записал в
копию установки `registry/contracts.tsv` («777 leaked from project» ×3) и `HANDOFF.md` (вывод ниже).
ЗАКРЫТЬ: субъект исполнять из disposable-копии установки (TOOLS = скопированное дерево с собственным .git).
`--snapshot/--check` детектора направить на ЭТО же дерево, мутант пишет в реальный HARNESS_TOOLS_ROOT.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:45 + :81 («gitw берёт канонический origin из профиля»).
Во всех git-сценариях `profile.canonicalRemote == URL remote origin` (probe.py:52,57). Нет ни одного
сценария, где профиль и origin расходятся.
ОБХОД: gitw подставляет в канон `git remote get-url origin`, то есть доверяет настроенному origin, а
профиль не читает. git-profile/git-layer зелёные (совпадают), git-reject зелёный (чужая цель ≠
origin). Мутант `trust-origin-url` проходит 18/18. Барьер 045 при этом обнулён: перенацеленный origin
проходит всегда.
ЗАКРЫТЬ: сценарий `git-origin-drift`. В профиле канон = bare A, `remote origin` = bare B. `gitw push origin`
→ rc1, в B ref отсутствует. Мутант trust-origin-url.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:58 («pre_critic и done вызывают ЕГО…; Green на старом HEAD не
кешируется») + :84. Через двери проходят только НЕГАТИВЫ: canon-done-fail и canon-precritic-fail
(probe.py:228-247). Позитив с cwd/argv/HEAD/stage проверяется только у прямого
`check_project_sources --stage pre_critic`. Любая дверь, отказывающая по ЛЮБОЙ причине, проходит.
ОБХОД (1): pre_critic/done при объявленном sourceCanon печатают `SOURCE_GATE_FAILED` и rc1, gate не
исполняя (мутант `door-refuse` 18/18). ОБХОД (2): двери запускают gate с cwd=установка или с
HARNESS_STAGE=pre_critic в done (мутант `door-tools-cwd` 18/18). В обоих случаях проектный контракт с
каноном не проходит ни pre_critic, ни done. Полный цикл на Complior-back невозможен, а критерий зелёный.
Кеш green прошлого HEAD тоже не наблюдается.
ЗАКРЫТЬ: сценарии `canon-precritic-green` и `canon-done-green`: gate rc0, дверь rc0, у done есть тег,
gate-observed.json = {cwd=R, head=HEAD, stage=pre_critic|done, contract, arg}. Плюс
`canon-stale-head`: green на HEAD₁, коммит, gate rc7 на HEAD₂ → done rc1 без тега. Мутанты door-refuse
и door-tools-cwd.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:47 и :83 («конкурентный резерв разрешает только успешную atomic
публикацию, не force»; «Отказ публикации не выдаёт NNN»). Пункт критерия не доказан ни одной командой:
reserve-origin (probe.py:192-199) проверяет только счастливый путь. gitw force/`+refspec` не судит
(предмет 045 — цель, не режим).
ОБХОД: reserve_project_contract публикует `+refs/tags/id/CONTRACT/N:…`. Мутант `reserve-force` проходит
18/18. Отдельный замер гонки двух станций: честный push второй станции rc1, forced rc0, и на origin
тег станции A молча подменён тегом станции B (5df14db → 8a0547c). Две станции получают один NNN,
резерв не является резервом (2030 §2 п.3).
ЗАКРЫТЬ: сценарий `reserve-race`. На origin до публикации появляется конкурирующий
`id/CONTRACT/<N>` (например pre-receive/update-хук bare-origin создаёт его перед приёмом) → rc1, stdout
пуст, tag-object на origin = конкурент. Мутант reserve-force.

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:52 («lib_zones ищет frozen-блоб в профильном contracts») + :121
(пакет B: mint_line/check_staged/check_zones; пакет C: lib_zones). Ни один файл этой группы не является
субъектом пробы. На HEAD scripts/lib_zones.sh:199-200 ищет контракт только под `contracts/` и при
промахе делает `continue`. check_zones.sh:498-500 затем выдаёт «зон не объявлено — проверять нечего»
и rc0. Живой замер ниже: тот же toy-контракт и тот же коммит implementer вне `ЗОНА implementer: app/`
дают в legacy-раскладке rc1 FAIL «коммит вне зоны», а в проектной (`.harness/tasks`) rc0.
ОБХОД: lib_zones, check_zones, check_staged и mint_line не тронуты, критерий 1–6 зелёный. Барьер зон
проектного implementer при этом fail-open и пропускает любой путь.
ЗАКРЫТЬ: сценарий `zones-project`: frozen-тег на контракте в профильном contracts, implementer-коммит
вне ЗОНА → check_zones rc1 с именем пути. Позитив внутри зоны → rc0. Мутант root-contracts-only. Плюс
сценарий `mint-project`: `mint_line --root R` пишет строку в профильный registry, корневого
`registry/` нет, staged-hook настоящий.

## Советы (не блокируют)

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:54-58: из грамматики sourceCanon пробой проверен только неизвестный
ключ. Мутант `canon-null-absent` (null/{} = отсутствие) проходит 18/18, хотя :55 прямо говорит
«null/пустой объект — НЕ отсутствие». Не проверены bool priority, дубли путей, SOURCE_CANON_MISSING,
SOURCE_GATE_UNAVAILABLE, NUL в argv. Дешёвые однострочные сценарии.
СОВЕТ :45: «Битый существующий профиль — отказ, не fallback» пробы не имеет.
СОВЕТ :39: symlink-побег workflowPaths/state наружу не проверен, проверен только `..`.
СОВЕТ :9,:45 (опасность cutover): исправление `harness.project.json` харнесса на
`ssh://git@github.com/a3ka/dev-harness.git` не закреплено пробой. Значение совпадает с константой
scripts/gitw:41 и с origin основного чекаута (сверено). Если A забудет, то после B gitw харнесса
откажет на каждом push. Это громко, но дорого, поэтому полезна строка-проба «канон self-профиля ==
прежняя константа».
СОВЕТ :47: «annotated» id-тег не проверяется, lightweight с тем же objectname проходит.
СОВЕТ :119-121: B/C/D делят одну identity `implementer` и одну ЗОНА-строку. Раздельность пакетов
держится прозой и интеграцией оркестратора, check_zones её не различает. Либо разные имена
исполнителей по пакетам, либо явная запись, что границы B/C/D — cognitive-only с остаточным риском.
СОВЕТ :123,:128-139,:153: `check_provodka.sh . contracts/996…` на HEAD даёт rc1 («норма-строка не найдена в
role-файле: roles/orchestrator.md»). Это ожидаемо до санкции, но done (done_contract.sh:126-178)
потребует зелёную ПРОВОДКУ или РАЗРЕШИЛ-ВЛАДЕЛЕЦ. Не назван исполнитель, который вносит строки в
roles/*.md после санкции. 2330 сам требует role-канал по канону, а строка изоляции
(arbiter/orchestrator…) владельцем дословно не заказана. Получить санкцию построчно до freeze.
СОВЕТ: боль-обоснование сверено. Н-163 (NABLIUDENIA.md:1586) и Н-167 Б-1/Б-2/Б-7 (:1492) ОТКРЫТО, цены
записаны. Строка «Канон» честно опирается на прямое слово 2330, а не на приписанную цену. Кап 5 есть
(:19). cognitive-only помечено с остаточным риском (§Норма-строки). Н-39: пары мутант↔сценарий только
в коде (probe.py MUTANTS), прозой не утверждаются.

## Сырой вывод (исполнено в /tmp/dev-harness-verify/critic996r1/)

```
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix     # чистый клон dh @ b8eb3960
… 18× rc=0; 18 мутаций rc=1 …
996: examined=18 mutants=14 mismatches=0                           RC=0

$ bash fixtures/workshop_project/rezhim_996/probe.sh               # продукт без реализации
996: examined=18 mutants=0 mismatches=17
996: проектный цикл не замкнут                                     RC=1
(git-reject rc=0 — регрессия 045, ожидаемо)

$ python3 mutate.py        # копия dh-mut, мутанты добавлены только в копию model.py
trust-origin-url: killed_by=0/18 SURVIVES
fallback-root: killed_by=0/18 SURVIVES
tools-leak: killed_by=0/18 SURVIVES
door-refuse: killed_by=0/18 SURVIVES
door-tools-cwd: killed_by=0/18 SURVIVES
reserve-force: killed_by=0/18 SURVIVES
canon-null-absent: killed_by=0/18 SURVIVES
$ git -C dh-mut status --porcelain
 M HANDOFF.md
 M fixtures/workshop_project/rezhim_996/model.py
 M registry/contracts.tsv
$ tail dh-mut/registry/contracts.tsv → 777 leaked from project (×3); HANDOFF.md → project state leaked

$ python3 zones_failopen.py   # нетронутые lib_zones/check_zones, тот же implementer-коммит вне app/
legacy: check_zones rc=1  FAIL коммит вне зоны: implementer … outside/zone.txt — зона автора …: app/
project: check_zones rc=0  замороженных контрактов: 1 · зон не объявлено — проверять нечего

$ race demo (две станции, один bare origin, id/CONTRACT/042)
A published: 5df14db29bc993646afd1b7715ea36cd1022f935
honest B rc=1
forced B rc=0
origin now: 8a0547c474bd61f991c17b85cbbbabd13b0d6108 A=5df14db… B=8a0547c…

$ python3 toy_legacy_freeze.py  # контроль: toy-контракт пробы проходит ДЕЙСТВУЮЩИЕ гейты в корневой раскладке
freeze_contract: rc=0 (frozen/contracts/777/1, реестр закоммичен)   done_contract: rc=0
→ freeze-profile/done-profile выполнимы без ослабления гейтов.

$ bash fixtures/_krasnye_103.sh → ИТОГ 103: rc=0 ; bash fixtures/_krasnye_105.sh → ИТОГ 105: rc=0   (на HEAD, без реализации)
$ bash scripts/check_precision_gate.sh <клон> contracts/996-rezhim-proekta-polnyj-cikl.md → OK, rc0
$ bash scripts/check_threat_model.sh . contracts/996-… → секция валидна (ЗАЩИЩАЕТ 5, НЕ ЗАЩИЩАЕТ 5), rc0
$ bash scripts/check_provodka.sh . contracts/996-… → норма-строка не найдена в role-файле: roles/orchestrator.md, rc1
$ bash scripts/pre_critic.sh --repo . contracts/996-… → КРИТИК: дверь зелёная, rc0
```

Скрипты репро: /tmp/dev-harness-verify/critic996r1/{mutate.py,zones_failopen.py,toy_legacy_freeze.py}.
Основной чекаут не тронут, push не делался.
