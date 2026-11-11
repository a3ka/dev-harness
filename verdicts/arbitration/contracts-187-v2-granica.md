РЕШЕНИЕ (контракт 187): до заморозки исправить наблюдатели блока 1(a),(b); 1(c) закрыт; советы — по границе ниже; затем один узкий вызов критика, не accept этим арбитражем.
OBJECT=8f2de864d3e8d5df00a36b56ae2e42c1a2e8601e
СУД: repo=dev-harness; предмет=187; фаза=контракт v2, арбитраж о границе; роль=arbiter; вызов=1/1; модель-план=openai-codex/gpt-6-astra (fallback fable, autoFallback); session-id=Arb187b; модель-факт=openai-codex/gpt-6-astra; предыдущий=verdicts/critic/contracts-187-v2-r1.md; исключение=арбитраж о границе по слову владельца 18:20; повтор после обрыва Arb187 без записанного вердикта.

## Рамка и первоисточники

Это единственное решение о границе предмета, не новый полный суд и не разрешение принять риск вместо обязательства. Действует адресное слово владельца 2026-11-11 ~18:20: после капа — один арбитраж, затем один узкий критик. Без его accept и обязательных машинных гейтов v2 не замораживается. Новый полный вызов или дальнейший вызов после узкого — только словом владельца.

Первым прочитано задание `/tmp/dev-harness-verify/orch/task-187-arbiter.md`, включая дополнение. Проверка записи пробного файла и его удаление прошли. Клон получен только из `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Arb187b/repo`, со своим `.git`; `fetch --tags` и `fetch origin wip/187/architect wip/187/critic` выполнены. `rev-parse origin/wip/187/architect` вернул OBJECT, все предметные замеры ниже выполнены на detached OBJECT. Вердикт создан на `wip/187/arbiter` от `origin/main=fd0165a24798ee1279aaadf3adb88edc20136cfd`. Основной чекаут, контракт и реализация не изменялись; push не выполнялся; полный `check_zones.sh` не запускался.

Прочитаны первоисточники:

- `contracts/187-arhitektura-v-processe.md` на OBJECT и тот же контракт через `git show frozen/contracts/187/1:contracts/187-arhitektura-v-processe.md`;
- все четыре имеющихся вердикта критика 187: `contracts-187-v1-krug1-fail.md`, `contracts-187-v1-vyzov2-fail.md`, `contracts-187-v1.md`, а v2-r1 — через `git show origin/wip/187/critic:verdicts/critic/contracts-187-v2-r1.md`;
- `verdicts/review/contracts-187-impl-v1.md`, `contracts-187-impl-v2.md`, `verdicts/critic/contracts-170-v2.md`;
- исполняемые наблюдатели, миры и стабы семьи `fixtures/workshop_project/architecture_process_187/`;
- `origin/main:HANDOFF.md`: запись арбитража с OBJECT и отменой прежней запланированной записи критика 2/2.

Счёт по первоисточникам: три суда контракта v1 (FAIL, FAIL, accept), один полный суд v2 (FAIL). Оборванный Arb187 не оставил решения и не заменяет этот артефакт. Фактическая модель настоящей сессии соответствует назначению; fallback в этой сессии не использован. Автор конструкции — architect, критик v2-r1 — zai/glm-5.3; собственную работу не сужу.

## Решение по каждому пункту

| Пункт | Позиции сторон | Решение | Доказательство: команда, rc, сырой вывод |
|---|---|---|---|
| 1(a): объединение всех `matches[].components` | Критик: одно-компонентный мир не отличает усечение; нужны различающие входы. Автор: согласен, объявил закрытым шестью клетками/пятью стабами общей правки v2-r1; union-мир и живая клетка добавлены. | **Исправить наблюдатель `locate-union-foreign` до freeze.** Сам union-мир и различение усечения закрыты. Но допустимый отказ с любым компонентом объединения должен приниматься, а иной код отказа — отвергаться. Не закреплять вместо `api.hub` новый случайный литерал. Сохранить проверку rc 1 и отсутствия frozen-тега. По первоначальной причине прав критик; по достаточности добавленного мира прав автор, по объявленному полному закрытию — нет. | M1: `--model` rc 0, `GREEN locate-union-conform: rc=0 expected=0`. M2: `--stabs` rc 0, `STAB locate-first-match-component caught @ locate-union-conform`, `STAB union-any-component caught @ locate-union-foreign`. M4: корректный отказ с `api.documents` → runner rc 1, `RED locate-union-foreign`. M5: неверный `PATH_WITHOUT_COMPONENT` с литералом `api.hub` → runner rc 0, `GREEN locate-union-foreign`. |
| 1(b): класс на make_task/done, отказ без результата | Критик: на этих двух дверях нет бесклассового входа; make_task обязан отказать без пака. Автор: согласен, добавил `task-class-missing`, `done-class-missing` и два class-skip стаба; объявил закрытым. | **Исправить отрицательный наблюдатель make_task до freeze:** он обязан отличать «rc 1 + ARCH_CLASS_MISSING, пак не выдан» от «пак выдан, затем тот же rc и reason». Это уже буквальное обязательство и критика, и приёмки v2-r1, не новый класс. Done-часть закрыта: отсутствие тега наблюдается и поздний отказ не скрывает тег. Четыре class-skip различителя сохраняются. По исходному требованию прав критик; добавленные входы автора нужны, но полного закрытия пока нет. | M2: оба новых class-skip caught. M3: настоящие make_task/done на бесклассовом контракте дают rc 0, обе клетки RED. M6: настоящий make_task + только замена результата на отказ → `GREEN task-class-missing`, `PUBLIC_DOOR_RC=0 PACK_EMITTED=True CELL_RUNNER_RC=0`. M7: аналогичная замена результата настоящего done → `RED done-class-missing`, `DONE_TAG=done/contracts/777/1 CELL_RUNNER_RC=1`. |
| 1(c): корректный 40-hex вне клона | Критик: не различается `ARCH_PIN` против `ARCHITECTURE_NET`. Автор: согласен, добавил `pin-foreign-hex` и `pin-net-for-hex`. | **Закрыт.** Автор прав относительно закрытия. Ни изменения реализации ради этой клетки, ни нового вызова по этому классу не требуется. | M3: `GREEN pin-foreign-hex: rc=1 expected=1 reason=ARCH_PIN`. M2: `STAB pin-net-for-hex caught @ pin-foreign-hex`. M8: замена только имени в результате настоящей двери → rc 1 runner, `RED pin-foreign-hex ... reason=ARCH_PIN ... ARCHITECTURE_NET`. |
| Совет критика: 65 деклараций при 62 пересечениях | Критик: три избыточных, безвредно, можно выровнять. На OBJECT автор уже удалил избыток. | **Закрыт.** Нового обязательства нет. | M10: `python3 -B .../frozen_overlap.py` rc 0: `FROZEN_TAGS=311 CONTRACT_BLOBS=311 OVERLAPS=62 UNDECLARED=0`; независимый счёт строк: `DECLARATIONS=62`. |
| Совет критика: «26 DRAFT, 22 без схем» | Критик: числа взяты из консультантских материалов, не сверены выгрузкой; совет, не блок. Автор сохранил их в `НЕ ЗАЩИЩАЕТ`, владельцы содержания — 186/Астра/Л5. | **Остаточный риск, не новый механизм двери:** «НЕ ЗАЩИЩАЕТ от неполноты схем и инвариантов операций и устаревания справочного счёта этой неполноты в модели. Числа 26/22 — справка, не порог допуска. Ловец — хранитель 186 при сверке exact pin и diff модели; reviewer реализации 187 проверяет, что эти числа не стали условием допуска; разрешение обязательств — Л5». Автору явно обозначить справочный статус чисел и этот ловец в контракте, не менять критерий двери и не выдавать числа за новый замер. | Прочитаны §Модель угроз OBJECT и совет v2-r1. Числа **мной не измерялись**; равенство 26/22 не утверждаю. M1–M3 показывают реальные измеренные счёты батареи, не счёты операций. Непроверенные справочные числа не доказывают нарушение обязательства 187. |
| Совет критика: ранний locate маскирует deps/brief | Критик: ожидаемый переходный эффект текущей реализации, не дефект контракта. Автор сохранил различители зависимостей и пакетного брифа; обе клетки пока красные. | **Остаточный риск диагностической достаточности до cutover:** «НЕ ЗАЩИЩАЕТ от ошибочной трактовки раннего красного locate как доказательства исполнения последующих deps/brief. Ловец — reviewer реализации 187 на исправленном locate: отдельно исполняет `deps-door-refusal` (rc 2 ARCH_DEPS) и `brief-npm-doorway` (rc 0 с брифом из пина), а также мутации отказа npm/прямого node; CI запускает полную батарею `--repo .`». Автору записать риск и ловца. Это не разрешение оставить дверь красной после реализации и не требование до freeze реализовать дверь. | M3: `RED brief-npm-doorway ... ARCH_ZONE ... компоненту {`; `RED deps-door-refusal: rc=1 expected=2 reason=ARCH_DEPS ... ARCH_ZONE ... компоненту {`. M1: обе честные клетки GREEN; M2: `deps-refusal-green`, `deps-named-not-evaluated`, `brief-node-direct` caught. M11: независимая CI-проводка существует, rc 0. |

Несогласия автора с первоначальными (a),(b),(c) не заявлено: в задании и HANDOFF — «согласен», в контракте v2-r1 — «закрыто». Моё решение уточняет, что последнее утверждение верно для (c), а для (a),(b) преждевременно. Последующей позиции автора относительно этого решения на момент записи нет; согласие не приписываю. Решение обязательно независимо от неё.

## Почему граница проходит здесь

В (a) достижим корректный ответ, который существующий наблюдатель отвергает, и некорректный код отказа, который он принимает. Причина — CASES:83 требует подстроку `компоненту api.hub`; main:838 проверяет только эту подстроку и rc, не `ARCH_ZONE` и принадлежность компонента объединению. §Приёмка контракта допускает **компонент объединения**, не его первый элемент. Честная реализация не обязана копировать порядок выбора `union[0]` из контрольного оракула.

В (b) main:839–847 исследует состав пака только при `not expected`, а для ожидаемого отказа side effect проверяется лишь у freeze/done (main:848–850). Поздний отказ после настоящего make_task поэтому неразличим. Требовать пустой вообще вывод не нужно: диагностика допустима; недопустим именно выданный пак. Наблюдатель обязан проверять реальный канал выдачи, а не добавленный субъектом флаг «пака нет».

Это два дефекта доказательства уже названных инвариантов. Записать их как принимаемый риск нельзя. Напротив, точность справочных чисел модели и диагностическая маскировка до реализации не снимают ни одного обязательства двери: они имеют конкретных последующих ловцов и не требуют нового полного суда. Роль автора — реализовать различители и связать стабы с ветвями **кодом**, а не таблицей в прозе контракта (Н-39). Арбитр не написал патч реализации, проверки или новый постоянный оракул.

## Замеры: команды и сырой вывод

Рабочий каталог всех M1–M11 — `/tmp/dev-harness-verify/Arb187b/repo` на OBJECT. Мутации M4–M8 — одноразовая подстановка результата на шве `workflow_probe.live` в памяти Python; файл батареи, её CASES-ожидание, контрольный оракул и наблюдатель не переписаны. CASES сужен только до указанной клетки для измерения конкретного различителя. M6–M8 сначала исполняют настоящую публичную дверь; M4/M5 подают конформный/неконформный ответ её интерфейса. Это измерение батареи, а не утверждение, что новая реализация существует.

### M1–M3. Полные батареи

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model
CELLS=58 STABS=0 FAILURES=0 SKIPPED=0
[rc=0]
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs
STAB locate-first-match-component caught @ locate-union-conform
STAB union-any-component caught @ locate-union-foreign
STAB task-class-skip caught @ task-class-missing
STAB done-class-skip caught @ done-class-missing
STAB pin-net-for-hex caught @ pin-foreign-hex
CELLS=58 STABS=55 FAILURES=0 SKIPPED=0
[rc=0; все 55 строк caught, ZHIV нет]
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .
GREEN pin-foreign-hex: rc=1 expected=1 reason=ARCH_PIN
SKIP live-real-pin: ARCH187_REAL_ROOT не задан — живая клетка не исполнялась (не зелёная)
SKIP live-real-union: ARCH187_REAL_ROOT не задан — живая клетка не исполнялась (не зелёная)
CELLS=58 STABS=0 FAILURES=21 SKIPPED=2
[rc=1]
```

Приведены итоговые/относящиеся к спору сырые строки, не весь stdout. Все 21 красная совпали с заявленным в контракте списком: locate-json-conform/foreign, zone-comma-list, path-unplaced-product, check-green-status-field, brief-npm-doorway, pin-symbolic, pin-lock-empty, model-root-unset, deps-door-refusal, precritic-full-zone/line-missing/draft, freeze-class-missing, precritic-class-missing, operation-optional, component-required-no-local, locate-union-conform/foreign, task-class-missing, done-class-missing. Это ожидаемое состояние **до реализации v2**, не отдельный блок контракта.

### M4. Допустимый не-первый компонент отвергается

```sh
python3 -B -c 'import sys,subprocess; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0]=="locate-union-foreign"); p.live=lambda *a,**k: subprocess.CompletedProcess([],1,"","ARCH_ZONE: путь app/multi/x.js отнесён моделью к компоненту api.documents, а строка называет api.identity\n"); sys.argv=["probe","--repo","."]; sys.exit(p.main())'
```
```text
RED locate-union-foreign: rc=1 expected=1 reason=компоненту api.hub output='ARCH_ZONE: путь app/multi/x.js отнесён моделью к компоненту api.documents, а строка называет api.identity\n'
CELLS=1 STABS=0 FAILURES=1 SKIPPED=0
[rc=1]
```

### M5. Неверный именованный отказ принимается

```sh
python3 -B -c 'import sys,subprocess; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0]=="locate-union-foreign"); p.live=lambda *a,**k: subprocess.CompletedProcess([],1,"","PATH_WITHOUT_COMPONENT: путь app/multi/x.js отнесён моделью к компоненту api.hub\n"); sys.argv=["probe","--repo","."]; sys.exit(p.main())'
```
```text
GREEN locate-union-foreign: rc=1 expected=1 reason=компоненту api.hub
CELLS=1 STABS=0 FAILURES=0 SKIPPED=0
[rc=0]
```

### M6. Реально выданный пак скрывается поздним отказом

```sh
python3 -B -c 'import sys,subprocess; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0]=="task-class-missing"); original=p.live; observed=[]; p.live=lambda *a,**k: (lambda r: (observed.append(r),subprocess.CompletedProcess(r.args,1,r.stdout,r.stderr+"\nARCH_CLASS_MISSING\n"))[1])(original(*a,**k)); sys.argv=["probe","--repo","."]; rc=p.main(); print("PUBLIC_DOOR_RC="+str(observed[0].returncode),"PACK_EMITTED="+str("=== make_task contract=777" in observed[0].stdout),"CELL_RUNNER_RC="+str(rc)); sys.exit(rc)'
```
```text
GREEN task-class-missing: rc=1 expected=1 reason=ARCH_CLASS_MISSING
CELLS=1 STABS=0 FAILURES=0 SKIPPED=0
PUBLIC_DOOR_RC=0 PACK_EMITTED=True CELL_RUNNER_RC=0
[rc=0]
```

### M7. Done-часть, напротив, проверяет отсутствие тега

```sh
python3 -B -c 'import sys,subprocess; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0]=="done-class-missing"); original=p.live; observed=[]; p.live=lambda *a,**k: (lambda r: (observed.append((r.returncode,p.git(a[1],"tag","-l","done/contracts/777/*"))),subprocess.CompletedProcess(r.args,1,r.stdout,r.stderr+"\nARCH_CLASS_MISSING\n"))[1])(original(*a,**k)); sys.argv=["probe","--repo","."]; rc=p.main(); print("PUBLIC_DOOR_RC="+str(observed[0][0]),"DONE_TAG="+observed[0][1],"CELL_RUNNER_RC="+str(rc)); sys.exit(rc)'
```
```text
RED done-class-missing: rc=1 expected=1 reason=ARCH_CLASS_MISSING output='\nARCH_CLASS_MISSING\n'
CELLS=1 STABS=0 FAILURES=1 SKIPPED=0
PUBLIC_DOOR_RC=0 DONE_TAG=done/contracts/777/1 CELL_RUNNER_RC=1
[rc=1]
```

### M8. Обратная путаница имён pin поймана

```sh
python3 -B -c 'import sys,subprocess; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0]=="pin-foreign-hex"); original=p.live; p.live=lambda *a,**k: (lambda r: subprocess.CompletedProcess(r.args,r.returncode,r.stdout.replace("ARCH_PIN","ARCHITECTURE_NET"),r.stderr.replace("ARCH_PIN","ARCHITECTURE_NET")))(original(*a,**k)); sys.argv=["probe","--repo","."]; sys.exit(p.main())'
```
```text
RED pin-foreign-hex: rc=1 expected=1 reason=ARCH_PIN output='  ok   план не заведён: проверка «вне плана» не применяется\nОТКАЗ: ARCHITECTURE_NET: коммит deadbeefdeadbeefdeadbeefdeadbeefdeadbeef не разрешается в клоне модели: /tmp/workflow-187-kbl2kuo_/pin-foreign-hex-model\n'
CELLS=1 STABS=0 FAILURES=1 SKIPPED=0
[rc=1]
```

### M9. Настоящий pin, обе живые клетки

```sh
env ARCH187_REAL_ROOT=/home/harness/consultant/fable16/repos/CompliorOS-architecture python3 -B -c 'import sys; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as p; p.CASES=tuple(c for c in p.CASES if c[0] in ("live-real-pin","live-real-union")); sys.argv=["probe","--repo","."]; sys.exit(p.main())'
```
```text
RED live-real-pin: rc=1 expected=0 reason=ARCH_187A_OK output='ARCH_ZONE: путь server/src/auth/delivery.js размещён в продукте, но модель не относит его к заявленному компоненту\n'
RED live-real-union: rc=1 expected=0 reason=ARCH_187A_OK output='ARCH_ZONE: путь server/src/handlers/x.js размещён в продукте, но модель не относит его к заявленному компоненту\n'
CELLS=2 STABS=0 FAILURES=2 SKIPPED=0
[rc=1]
```

Живые клетки действительно исполнились с разрешившимся пином, а не были заменены модельным ответом или SKIP. Этот прогон доказывает текущую красноту двери, не исправность будущей реализации и не установку зависимостей за ранним отказом.

### M10–M11. Советы и сохранённая CI-проводка

```text
$ python3 -B fixtures/workshop_project/architecture_process_187/frozen_overlap.py
FROZEN_TAGS=311 CONTRACT_BLOBS=311 OVERLAPS=62 UNDECLARED=0
[rc=0]
$ python3 -c 'from pathlib import Path; s=Path("contracts/187-arhitektura-v-processe.md").read_text(); print("DECLARATIONS="+str(sum(x.startswith("ПЕРЕСЕЧЕНИЕ ") for x in s.splitlines())))'
DECLARATIONS=62
[rc=0]
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring . && bash scripts/gen_ci_steps.sh --check
[rc=0; stdout пуст, обе команды исполнены]
```

## Конечное поручение и узкий суд

Architect до заморозки:

1. Исправляет (a): семантический наблюдатель union-отказа принимает допустимые компоненты объединения, требует `ARCH_ZONE`, rc 1 и отсутствие frozen-тега; эквивалент M4 зелёный, M5 красный. Усечение компонентов и безусловное принятие размещённого пути по-прежнему ловятся. Инвариантность — свойство множества, не перестановка одного литерала.
2. Исправляет (b): отрицательный наблюдатель make_task действительно запрещает выданный пак при `ARCH_CLASS_MISSING`; эквивалент M6 красный, честный ранний отказ зелёный. Положительная выдача пака и done-контроль отсутствия тега не ослабляются. Различающий стаб привязан кодом architect к своей ветви.
3. Записывает два названных остаточных риска с ловцами из таблицы и справочный статус 26/22. Контракт сохраняет инварианты и rc-команды; не превращается в реестр привязки стабов.

После этого — **ОДИН узкий вызов критика только по выполнению пп. 1–3 этого решения**, без новых классов и без повторного полного суда. По (c) достаточно не ослабить уже закрытый различитель. Полные `--model`/`--stabs` служат проверкой сохранения батареи, не основанием расширить область узкого суда; `--repo .` до реализации остаётся заявленно красным, а после реализации должен стать зелёным с отдельно исполненными живыми клетками при доступных предпосылках. Ревьюеру реализации передаётся ловец deps/brief, хранителю 186 — содержание модели.

Арбитр **не даёт accept**, не разрешает freeze этим файлом и не отменяет обязательных подписей/машинных гейтов. Инженерный выход конечен и не требует нового решения владельца о желаемом поведении; если единственный узкий вызов не даст accept, следующий суд/принятие риска — только явное слово владельца, предмет остаётся незамороженным.
