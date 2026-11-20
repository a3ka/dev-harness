accept
OBJECT=fa61f020fd2828da01f812e94267147d51a5fff4
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: рисковый — адверсарий предшествует ревьюеру; один узкий вызов по дельте от c2fd07be, слово владельца 19:24)

Судья Adv140Train; модель-факт openai-codex/gpt-6.1-terra. `bash scripts/models_actual.sh --tsv --bind --session Adv140Train` rc 0: `adversary openai-codex/gpt-6.1-terra allowed Adv140Train fa61f020fd2828da01f812e94267147d51a5fff4`. Авторы дельты implementer и architect, не судья. Предыдущий accept `Adv140Impl` на c2fd07be не переносился; prior FAIL Adv157HookCompat на first-only/last-only — основание независимых позиционных проб. Проверялся фиксированный OBJECT; изменение субъекта и мира только во временных копиях.

Блокирующих находок в этой узкой дельте не обнаружено. Порог §Быстрый-процесс учитывает происхождение механизма, а не только зелень специально добавленного запрета. Ниже два наблюдаемых ограничения, не выдаваемых за блоки.

## СОВЕТ: позиция 4 и пустой генератор

`fixtures/workshop_project/spawn_guard_157/probe.py:89-106,345-407,411-433`, `.omp/extensions/spawn-guard.ts:202`. В копии заменена существующая нормализация на `out.length !== 3 && o.isolated === true`; `python3 /tmp/dev-harness-verify/adversary140train-1717276/attacks.py`:

```
### 157 fourth-batch rc 0
KLETKI subject 59 KRASNYH 0
```

Независимый четырёхэлементный вход через реальный `case` того же драйвера, все четыре рабочих `isolated:true`, команда `python3 /tmp/dev-harness-verify/adversary140train-1717276/four_witness.py` rc 0:

```
strict OK
fourth KRASNO: ('fourth', 'door did not judge every batch item')
```

При этом все новые isolation-batch клетки содержат не более трёх item, а старые длинные — без true. Это реальное ограничение проверки 157, не утверждение о некорректности кандидата. Конкретное исключение четвёртой позиции — специально добавленный фильтр без показанного источника ошибки такого вида; по §Порог это совет, не блок. Для station и полного набора приёмки этот мутант отдельно не предъявлялся как зелёный.

Атака пустотой: в одноразовой копии вставка `return []` в начало `scenarios()`, без правки объекта, затем `python3 .../probe.py`:

```
KLETKI subject 0 KRASNYH 0
EMPTY_RC 0
```

Это наблюдение о порче самой батареи, не доказательство дефекта поставленного SUBJECT и не блок по этой дельте.

## Закрытие позиционного обхода и станционный мир

Положительный контроль и объявленные стабы, TMPDIR=/tmp/dev-harness-verify/adversary140train-1717276:

```
python3 fixtures/workshop_project/spawn_guard_157/probe.py
KLETKI subject 59 KRASNYH 0
rc=0
python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs
KLETKI isolated-control 59 KRASNYH 0
KLETKI first-only 59 KRASNYH 19
KLETKI last-only 59 KRASNYH 19
KLETKI middle-only 59 KRASNYH 20
KLETKI batch-all-or-nothing 59 KRASNYH 19
KLETKI batch-any 59 KRASNYH 19
KLETKI batch-only 59 KRASNYH 1
KLETKI worker-only 59 KRASNYH 2
STABY 46 NEPOIMANNYH 0
rc=0
```

`stancija_odin_agent_140.sh:142-153,273,375,487` сначала коммитит контракт, затем создаёт аннотированный тег и отдельным коммитом закрепляет SHA tag-object. `scripts/zamok_predmeta.sh:384-396` требует объект типа tag и соответствующий ref. `git diff` по замку и ожиданиям между базой и OBJECT пуст; изменены построитель мира, hook, тест 157 и документы, но не дверь. Положительный контроль в своей изолированной копии, не живой omp:

```
TMPDIR=/tmp/dev-harness-verify/adversary140train-1717276 bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
PROBA p05-int-porjadok-adv-rev OK
PROBA p10-int-propusk-posle-yield-true OK
PROBA p16-int-smeshannyj-paket-false OK
PROBA p20-int-pervyj-rabochij-true OK
PROBA m01-huk-bez-dveri OK
PROB VSEGO 45 KRASNYH 0
rc=0
```

Красный контроль мира, замена `rev-parse "refs/tags/$tag"` на `rev-parse "refs/tags/$tag^{}"` (commit SHA вместо tag-object), запуск той же S:

```
### station commit-pin rc 1
PROBA p05-int-porjadok-adv-rev KRASNO: GOT p05 fail want=block:ADVERSARIJ_DO_REVJUERA got=блок:ОТКАЗ: KLASS_RISKA_NET: предмет 141: закреплённый frozen недоступен unchanged=true
PROBA p10-int-propusk-posle-yield-false KRASNO: GOT p10-false fail want=pass got=блок:ОТКАЗ: KLASS_RISKA_NET: предмет 141: закреплённый frozen недоступен unchanged=true
PROBA p16-int-smeshannyj-paket-false KRASNO: GOT p16-false fail want=pass got=блок:ОТКАЗ: KLASS_RISKA_NET: предмет 141: закреплённый frozen недоступен unchanged=true
PROB VSEGO 45 KRASNYH 11
```

Отдельно lightweight tag вместо аннотированного, `python3 /tmp/dev-harness-verify/adversary140train-1717276/frozen_attacks.py`:

```
### lightweight tag rc 1
PROBA p05-int-porjadok-adv-rev KRASNO: GOT p05 fail want=block:ADVERSARIJ_DO_REVJUERA got=блок:ОТКАЗ: KLASS_RISKA_NET: предмет 141: закреплённый frozen недоступен unchanged=true
PROB VSEGO 45 KRASNYH 11
```

Это намеренно сломанные миры внутри проверяемой фикстуры, не отказ механизма судьи. До/после потребительских ожиданий — одинаковые p05/p10/p16; отказ не принимается вместо желаемой причины.

`python3 .../attacks.py` независимо менял только выражение hook: `out.length === 1 && ...`, `out.length !== 1 && ...`, либо значение предыдущего item. Тот же `python3 fixtures/workshop_project/spawn_guard_157/probe.py`:

```
### 157 second-only rc 1
KLETKI subject 59 KRASNYH 20
### 157 not-second rc 1
CASE subject project-isolated-batch-second KRASNO: ('project-isolated-batch-second', 'door did not judge every batch item')
KLETKI subject 59 KRASNYH 14
### 157 neighbor rc 1
CASE subject project-isolated-batch-first KRASNO: ('project-isolated-batch-first', 'door did not judge every batch item')
KLETKI subject 59 KRASNYH 19
```

Независимая станционная S на хуке `false`: rc 1, `PROB VSEGO 45 KRASNYH 26`, включая p20; соседнее значение: rc 1, `PROB VSEGO 45 KRASNYH 19`, включая p15 и p16. `python3 fixtures/workshop_project/odin_agent_140/normalizacija_140.py` rc 0:

```
NORMALIZACIJA strict rc=0
PROB VSEGO 45 KRASNYH 0
NORMALIZACIJA truthy rc=1
PROB VSEGO 45 KRASNYH 18
NORMALIZACIJA truthy RAZLICHENO 9
NORMALIZACIJA constant rc=1
PROB VSEGO 45 KRASNYH 29
NORMALIZACIJA constant RAZLICHENO 5
```

Нейтрализация двери `exit 127` через S: rc 1, `PROB VSEGO 45 KRASNYH 41`, p13 остаётся проверкой fail-closed, p20 красный. Отсутствующий node: `env PATH=/tmp/dev-harness-verify/adversary140train-1717276 /usr/bin/python3 fixtures/workshop_project/spawn_guard_157/probe.py` → `NOT_IMPLEMENTED: node absent`, rc 2. Замена строгой проверки двери на jq truthiness в S дала 45/0: хук уже нормализует вход, поэтому это не доказательство здоровья прямой двери. Независимый прямой W на том же мутанте:

```
### direct gate truthy rc 1
CASE w29-rabochij-isolated-stroka KRASNO: rc: rc 0 ≠ 1; stderr=
CASE w29-rabochij-isolated-stroka KRASNO: причина: причины NE_IZOLIROVAN нет в stderr:
CASE w29-rabochij-isolated-stroka KRASNO: учёт: учёт не пуст (1 строк)
CASE w29-rabochij-isolated-stroka KRASNO: занятие: занятие 140 живо (holder 'Arch140')
KLETKI 172 KRASNYH 1
```

## Регресс, происхождение и остаток

```
sha256sum .omp/extensions/spawn-guard.ts
 d74fbe27e51d8b939318c354a2bb9652b2c24ac0058f78411e415b3f9b22ae23
 git show 512e822676d78dd4af9705c141d7815c6a633f72:.omp/extensions/spawn-guard.ts | sha256sum
 d74fbe27e51d8b939318c354a2bb9652b2c24ac0058f78411e415b3f9b22ae23
 git diff --quiet 4113367bb8 b3394d0c9b -- .omp/extensions/spawn-guard.ts: rc=0
 git diff --exit-code frozen/contracts/140/5 OBJECT -- contracts/140-odin-agent-na-predmet.md: rc=0
```

`bash scripts/verify_antiplacebo.sh --scope pre_judge` rc 1:

```
SCOPED: барьеров 1 из выборки — не для приёмки
  FAIL pre_judge.sh: нет фикстур — ожидается fixtures/pre_judge/case_*.sh
барьеров: 1 · фикстур: 0 · предъявлено красным повторным прогоном: 0
расхождений: 1
```

`git ls-tree -r --name-only origin/main -- fixtures/pre_judge` пусто: известное предсуществующее состояние, не объявляется зелёным. `bash scripts/scope_select.sh . --changed c2fd07be633522177f781ca6c7ee5bc091f65e96` → `SCOPED: не для приёмки`, `MODE: full`, rc 0; полный прогон запрещён. `git diff --name-only c2fd07be OBJECT -- scripts/verify_antiplacebo.sh scripts/check_sdacha.sh scripts/check_provodka.sh scripts/zamok_predmeta.sh` пуст, rc 0. Предыдущий совет C-1 о no-runtime-silent относится к неизменённому pre_judge и не переобъявляется блоком.

В `НЕ ЗАЩИЩАЕТ` contracts/140:199–210 нет строк К-NN с ловцом adversary; номера не выдуманы. Пронос isolated после интеграции — испытан синтетическим tool_call реального хука и двери выше; реальный omp и sandbox полномочного процесса не доказаны. `sourceCanon` в контракте и листе не объявлен; архитектурного движка 188 в дереве нет.

## Не проверено

Живой omp, реальные изоляция и сторонние процессы, полный CI и полный повтор 140/157/199; произвольные большие batch за пределами свидетельства четырёх рабочих. CI при запросе PR #1160 на OBJECT: `ci (l1, check:gitw-predpolet-family-selftest) IN_PROGRESS`, остальные завершённые — SUCCESS/SKIPPED; зелёным CI на момент измерения не объявляется. Новые пробы не подменяют приемку по фактическому статусу CI. Операционный запрет на запись вне своей копии соблюдён; scratch расположен в /tmp/dev-harness-verify/adversary140train-1717276.

Исправленные ошибки собственных команд: первый bash без cwd отклонён Н-85; повторен с cwd. `door_attacks.py` сначала ожидал один якорь jq, фактически два; после исправления выполнены отдельные прогоны; сообщение agent://Main о незавершённом CI отклонено Н-85. Это не отказы механизма и не результаты кандидата.
