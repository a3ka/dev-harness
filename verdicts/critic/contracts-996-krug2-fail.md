FAIL
OBJECT=9ffd1b9556796dffae1ef76afa4ce94dd43653df
Предмет: contracts/996-rezhim-proekta-polnyj-cikl.md и fixtures/workshop_project/rezhim_996/ (probe.sh, probe.py, model.py, zones_adapter.sh), ветка wip/996/architect. Круг 2. Критик.

## Итог

Набор артефактов полон: предмет, критерий с командами, исполнители, ЗОНА-строки и РАБОТА НЕ РАЗДАЁТСЯ.
Все блокеры круга 1 (Б1–Б7) закрыты. Каждый мутант круга 1 теперь есть в матрице и краснеет именно
на своём сценарии (сырой вывод ниже). Честная модель зелёная на 53/53, продукт без реализации даёт rc1
с 47 расхождениями. Это совпадает с замером архитектора.

FAIL ставлю по ОДНОЙ новой блокирующей находке. Её не было среди Б1–Б7: это другое свойство предмета.
Предмет (:21, :51) прямо обещает сохранить действующие гейты freeze/done в режиме проекта, а критерий
это не проверяет: честная модель матрицы сама эти гейты не исполняет. Находка закрывается двумя
сценариями и одним мутантом в ЗОНА architect. Прозу контракта менять не нужно.

АРБИТР: не созывается. Причина FAIL иная, чем в круге 1: Б1–Б7 закрыты все, и стороны их поняли
одинаково (закрытие совпало с предложенным). Если круг 3 упадёт по причине этой находки, арбитра
созывает критик (правило 15). Предмет спора тогда будет такой: обязан ли офлайн-критерий иметь
проектный негатив на каждый пункт «сохраняется X» предмета, или достаточно legacy-регрессий X.

## Закрытие Б1–Б7 (мутант круга 1 → сценарий, на котором он краснеет в --matrix @ 9ffd1b9)

- Б1 (пакет D без проб): мутанты root-context, drop-context-canon, root-startup и root-verdict-context
  краснеют на context-{workshop,architect,implementer,critic,adversary,reviewer,arbiter}
  (ROLE_CONTEXT_NOT_PROJECT_LOCAL). В продукте на HEAD 7/7 красные: make_task usage и запуск omp
  пойман ловушкой (UNEXPECTED_OMP_LAUNCH rc97). ЗАКРЫТ.
- Б2 (fallback на корень, арбитраж корня): fallback-root краснеет на freeze-root-only и done-root-only
  (ROOT_FALLBACK_ACCEPTED). root-arbitration краснеет на freeze-root-arbitration (PROJECT_CAP_BYPASSED)
  и freeze-project-arbitration. ignore-project-cap краснеет на freeze-cap. ЗАКРЫТ.
- Б3 (детектор судил муляж): в station-isolation freeze исполняется из disposable install, а
  check_no_leak судит этот же install (probe.py:480-496). tools-leak и station-writes-tools краснеют:
  «основной чекаут загрязнён: registry/contracts.tsv, HANDOFF.md». ЗАКРЫТ.
- Б4 (origin = профиль во всех мирах): trust-origin-url краснеет на git-origin-drift, а
  broken-profile-fallback — на git-broken-profile. ЗАКРЫТ.
- Б5 (двери только негативами): door-refuse и door-tools-cwd краснеют на canon-precritic-green и
  canon-done-green. stale-head-cache краснеет на canon-stale-head. ЗАКРЫТ.
- Б6 (force-резерв): reserve-force краснеет на reserve-race («forced update», stdout 778). gitw берёт
  первый git из PATH (scripts/gitw:15-24), поэтому PATH-прокладка честному продукту достижима. ЗАКРЫТ.
- Б7 (lib_zones fail-open): root-contracts-only краснеет на zones-project, staged-project и
  lib-zones-project. В продукте на HEAD zones-project даёт ровно репро круга 1: «зон не объявлено —
  проверять нечего» rc0 → PROJECT_ZONE_FAIL_OPEN. Пройдены mint-project и mint-no-authority. ЗАКРЫТ.
- Советы круга 1 закрыты сценариями: canon-null/empty/bool/duplicate/nul/missing/unavailable,
  git-broken-profile, paths-symlink, self-canonical и lightweight-reservation. Cognitive-only
  раздельности B/C/D записан на :73.

## Блокирующие находки

БЛОКИРУЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:51 («Сохраняются … spec/consumers/precision/doc/provodka,
кап и авторство») + :21 («В 996 НЕ входят: … отключение действующих гейтов для внешнего проекта») + :83
(критерий 2). Ни один из 53 сценариев не предъявляет проектный контракт, который действующий гейт
freeze/done обязан отвергнуть. Сами гейты существуют: freeze_contract.sh:231 (spec 036), :244
(consumers), :282 (precision 043), :300 (doc), done_contract.sh:134 (provodka), :147 (consumers).
Эталон model.py:239-296 не исполняет ни одного из них и проходит матрицу 53/53. Значит, реализация
«в проектном режиме гейты пропускаются» по наблюдаемому неотличима от честной. Ноутбучная приёмка
(:91-95) идёт по счастливому пути с валидным контрактом и пропуск тоже не различает.
ОБХОД: пакет C переводит freeze_contract.sh и done_contract.sh на профильные пути и в проектной
ветке не вызывает check_spec_ready/check_consumers/check_precision_gate/check_document/check_provodka.
Тогда probe.sh rc0, --matrix rc0, 045/071/054/103/105 rc0 (у них только legacy-раскладка), и критерий
выполнен. При этом проектный контракт с семьёй без барьера замораживается, а контракт с несуществующим
guard ПРОВОДКИ получает done-тег. Замер ниже: тот же дефектный контракт действующий продукт в
legacy-раскладке отвергает (rc1, тега нет), а честная модель в профильной раскладке принимает (rc0, тег).
Вынужденности нет: все четыре гейта на HEAD уже принимают вложенный путь `.harness/tasks/777-toy.md`
с rc0 (замер gates_nested.py), то есть честная реализация проходит без правки файлов вне ЗОНА implementer.
ЗАКРЫТЬ: сценарий `freeze-gate-preserved`: профильный контракт с `ЗОНА implementer: app/
fixtures/check_nosuchbarrier/` и accept критика → freeze rc1 «spec-preflight 036», тега нет, HEAD
неизменен. Сценарий `done-gate-preserved`: `guard=missing-guard.sh` и accept ревьюера → done rc1
«ПРОВОДКА», тега нет. Эталон зовёт настоящие гейты из HARNESS_TOOLS_ROOT. Мутант `skip-gates` их
пропускает и обязан краснеть на обоих сценариях.

## Советы (не блокируют)

СОВЕТ :84, :91-95 — изоляцию установки офлайн проверяет только freeze. Мутант `done-leak` (только done
дописывает `$HARNESS_TOOLS_ROOT/HANDOFF.md`) проходит 53/53: killed_by=0/53. Он реально записал
HANDOFF.md в проверяемый чекаут dh-mut2, и ни один сценарий этого не заметил. То же верно для
reserve/mint/print-context. Ноутбучный `check_no_leak --check` после полного цикла это ловит, поэтому
это совет, а не блок. Дёшево закрыть так: в station-isolation прогнать из того же install ещё done,
reserve и mint.
СОВЕТ :45 («непустой явный GIT_EXCHANGE_GUARD_CANONICAL > профиль») — мутант `profile-over-override`
(профиль перебивает override) проходит 53/53. Сценария «профиль и override расходятся» нет, а
_krasnye_045 судит legacy без профиля.
СОВЕТ :39 («в профиле самого харнесса ЯВНО `state: "."`») — пробой не закреплено. self-canonical
проверяет только canonicalRemote. Ни один сценарий не зовёт project_workflow или --print-context на
корне установки, а в 054/103/105 строки HANDOFF нет (grep -c → 0). Если A забудет `state`, self-сессии
харнесса получат startup `<установка>/.harness/HANDOFF.md`. Это громко (детектор сервера), но дорого.
Нужна строка в self-canonical: `paths.handoff == <install>/HANDOFF.md`.
СОВЕТ :51 («freeze … читает профильный plan») — в workflowPaths нет ключа plan, и сценария на план
нет. Где лежит профильный plan.tsv, решит исполнитель (вопрос 3). scripts/lib_plan.sh (жёсткие
`registry/plan.tsv`, `contracts/<id>-*.md`) и scripts/check_charter.sh (его сорсит check_staged)
лежат вне ЗОНА implementer. Если проектный план потребует их правки, исполнитель встанет. Назовите
путь плана или явно выведите его из 996.
СОВЕТ :51 («Смена раскладки не разрешает заморозку чужого HEAD (Н-240/241)») — пробы нет. Здесь это
только сохранение действующего поведения, поэтому совет.
СОВЕТ :65, :99 — сценарии context-* судят только ветку --print-context. То, что штатный запуск кладёт
в prompt ТОТ ЖЕ контекст, честно объявлено cognitive-only и принимается ноутбуком (:99). Это совет на
ревьюера: сверить, что --print-context и запуск зовут одну функцию.
СОВЕТ fixtures/…/probe.py:537,560 — ключ 'local-reservation' задан дважды: в базовом dict, а затем в
update с расширением до reserve-unavailable. Сейчас безвредно, но счётчик mutants=37 молча
дедуплицирован.
СОВЕТ :122 — сценарии B (zones-project, staged-project) зелены только после правки lib_zones пакетом C.
Это зависимость B от C, а не пересечение файлов. Пусть оркестратор интегрирует C до приёмки B.

Проверено без замечаний: Н-39 (привязка мутаций только в MUTANTS, покрытие сценариев сверяется
assert-ом probe.py), норма 041 (check_threat_model rc0, 5/5), норма 043 (check_precision_gate rc0 OK),
ПРОВОДКА (rc1 до санкции владельца ожидаем; интеграционный коммит оркестратора назван на :71),
грамматика ПЕРЕСЕЧЕНИЕ-строк (pre_critic rc0), cutover канона (self-canonical в продукте на HEAD
красный, как и должно быть до A).

## Сырой вывод (исполнено в /tmp/dev-harness-verify/critic996r2/, копии dh-*)

```
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix        # dh-matrix @ 9ffd1b9
… 53× rc=0 …
mutation trust-origin-url: git-origin-drift: rc=1 UNTRUSTED_ORIGIN_ACCEPTED … foreign.git * [new branch]
mutation fallback-root: freeze-root-only: rc=1 ROOT_FALLBACK_ACCEPTED
mutation fallback-root: done-root-only: rc=1 ROOT_FALLBACK_ACCEPTED
mutation tools-leak: station-isolation: rc=1 STATION_POLLUTED_INSTALLATION … загрязнён: registry/contracts.tsv, HANDOFF.md
mutation door-refuse: canon-precritic-green|canon-done-green: rc=1 CANON_DOOR_GREEN_REFUSED
mutation door-tools-cwd: canon-precritic-green|canon-done-green: rc=1 CANON_DOOR_GREEN_REFUSED
mutation reserve-force: reserve-race: rc=1 RESERVATION_FAILURE_ANNOUNCED_NUMBER … (forced update)
mutation canon-null-absent: canon-null|canon-empty: rc=1 CANON_DOOR_REFUSAL_MISSING
mutation root-contracts-only: zones-project|staged-project|lib-zones-project: rc=1
mutation root-context: context-* (7): rc=1 ROLE_CONTEXT_NOT_PROJECT_LOCAL
996: examined=53 mutants=37 mismatches=0        real 0m51.2s        RC=0
$ git -C dh-matrix status --porcelain            → (пусто)

$ bash fixtures/workshop_project/rezhim_996/probe.sh                  # dh-prod, продукт без реализации
… git-reject rc=0, git-origin-drift rc=0, git-broken-profile rc=0, zones-green rc=0, staged-green rc=0, mint-no-authority rc=0 …
zones-project: rc=1 PROJECT_ZONE_FAIL_OPEN rc=0 stderr='замороженных контрактов: 1 · зон не объявлено — проверять нечего'
context-workshop: rc=1 ROLE_CONTEXT_UNAVAILABLE rc=97 … UNEXPECTED_OMP_LAUNCH
996: examined=53 mutants=0 mismatches=47        996: проектный цикл не замкнут        RC=1

$ python3 gates_bypass.py      # дефектный контракт: действующий продукт (legacy) vs честная модель (профиль)
freeze legacy-product        rc=1 tags=[] err='ОТКАЗ: spec-preflight 036 красен (rc=1): спек-гейт 036: семья без барьера: scripts/check_nosuchbarrier.sh не существует …'
freeze profile-honest-model  rc=0 tags=['frozen/contracts/777/1'] err=''
done   legacy-product        rc=1 tags=[] err='done: ПРОВОДКА красна: проводка: guard-файл не существует: missing-guard.sh'
done   profile-honest-model  rc=0 tags=['done/contracts/777/1'] err=''

$ python3 gates_nested.py      # гейты HEAD на вложенном пути контракта (честный toy)
project  spec_ready rc=0 OK · consumers rc=0 · precision rc=0 OK · provodka rc=0   (legacy — то же)

$ python3 mutate2.py           # новые мутанты в копии dh-mut2/model.py, каждый против ВСЕХ 53 сценариев
done-leak: killed_by=0/53 SURVIVES
profile-over-override: killed_by=0/53 SURVIVES
$ git -C dh-mut2 status --porcelain → M HANDOFF.md ; M fixtures/workshop_project/rezhim_996/model.py

$ bash scripts/check_threat_model.sh . contracts/996-… → секция валидна (ЗАЩИЩАЕТ 5, НЕ ЗАЩИЩАЕТ 5), rc=0
$ bash scripts/check_precision_gate.sh <клон> contracts/996-… → OK, rc=0
$ bash scripts/check_provodka.sh . contracts/996-… → норма-строка не найдена в role-файле: roles/orchestrator.md, rc=1 (до санкции)
$ bash scripts/pre_critic.sh --repo . contracts/996-… → КРИТИК: дверь зелёная, rc=0
$ bash scripts/check_zones.sh . → замороженных контрактов: 101 · объявленных авторов: 6 · проверено по зонам: 3005, rc=0
$ bash scripts/check_spec_ready.sh . contracts/996-… → OK, rc=0
```

Скрипты репро: /tmp/dev-harness-verify/critic996r2/{gates_bypass.py,gates_nested.py,mutate2.py}.
Основной чекаут не тронут, push не делался, вердикт не закоммичен (страж Н-85).
