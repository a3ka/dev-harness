FAIL
OBJECT=dcc6f2a9c5c5aac1af358b19a53846645ca2ec3f
СУД: репо=dev-harness; предмет=218; фаза=контракт; роль=critic; вызов=1 (полный; новый предмет); сессия=Crit218; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; автор Architect218 — openai-codex/gpt-6.1-sol; предыдущий=нет; исключение=нет.

Фактические модели и сессии: `bash scripts/models_actual.sh --tsv --bind --session Crit218` и аналогично `Architect218`, обе rc 0; первая привязана к OBJECT. Автор коммита — architect, судья — другая сессия. Предъявлен первый полный вызов согласно заданию; в истории предмета обнаружены owner-затравка и architect-кандидат, прежнего предъявленного critic-вердикта нет.

## Карта классов

К-01: чисто — check_sdacha --run и pre_critic rc 0, precision-gate rc 0
К-02: чисто — вход owner-затравка на a32c577f2 и инварианты контракта 218
К-03: чисто — вход зоны и оговоренные non-PR обязательства 200 207 083 210 217 992 071
К-04: чисто — вход ЗОНА и ПЕРЕСЕЧЕНИЕ контракта, precision-gate rc 0
К-05: чисто — вход раздел Приёмочный критерий, названы rc-команды
К-06: чисто — вход probe.py обработка Prerequisite и timeout с rc 2
К-07: блок — Б-1 reference амнистирует возврат frozen-текста
К-08: блок — Б-2 неоднозначная merge-base проходит батарею
К-09: блок — Б-2 отсутствует отказной вход с несколькими merge-base
К-10: чисто — вход observe проверяет rc диагноз stdout кеш HEAD status и Git Trace2
К-11: чисто — вход World и oracle снимают состояние до subject
К-12: чисто — вход Git plumbing и JSON Trace2 в probe.py
К-13: н/п — секретов и ПД в предмете нет
К-14: чисто — вход честные owner-update и own-charter-allowed в каталоге
К-15: чисто — --model 53/53/0, --stabs 12/24/24/0, --repo 53/8/45
К-16: чисто — вход рисковый страж устава и заморозки, модель угроз контракта
К-17: н/п — станционный guard, продуктовая модель 188 не объявлена

## Блоки

БЛОКИРУЕТ contracts/218-okno-frozen-v-pr.md:42 — Б-1. Reference и батарея принимают амнистию собственной правки замороженного текста после revert.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-07
ОБЯЗАТЕЛЬСТВО: И3 требует судить собственную историю, в том числе собственную правку с revert; И4 требует отказа для собственной правки frozen без новой заморозки. Оба CLI входят в предмет, а --model должен быть честным кандидатом.
СОСТОЯНИЕ: настоящий Git-мир батареи frozen-own-frozen: отдельный bare origin, замороженный contracts/701-fixture.md, собственный коммит изменяет его без разрешения и новой заморозки, следующий собственный коммит возвращает исходный frozen-блоб; оба коммита принадлежат PR-окну. Это поддерживаемые git-коммиты и явно названный контрактом сценарий revert.
НАБЛЮДЕНИЕ: до revert reference check_contract_frozen rc 1, после revert rc 0. Исходный механизм `scripts/check_contract_frozen.sh:167` проверяет носители только внутри ветви неравенства HEAD и frozen; его перенос моделью сохраняет эту развилку, поэтому равенство конечных блобов скрывает историю. `--model` при этом 53/53. Это не специально добавленный запрет и не предъявление случайной грамматики.
ОБХОД: принять зелёный --model/--repo при реализации подобной reference: нарушающий frozen-коммит остаётся в PR-истории, но проверка frozen заявляет совпадение и успех. Нужна различающая клетка для frozen-правки и её revert и свойство суда истории, соответствующее И3/И4, без ослабления допустимого предстоящего v+1. Нужен также честный парный контроль, а не запрет revert вообще.

БЛОКИРУЕТ contracts/218-okno-frozen-v-pr.md:40 — Б-2. Проверка отказа при нескольких merge-base не различает удаление существующей операции перечисления всех оснований.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08
ОБЯЗАТЕЛЬСТВО: И2 требует единственную доказанную merge-base, `PR_WINDOW_BASE_AMBIGUOUS` и rc 1 для неоднозначности; И1 относит это к обоим CLI.
СОСТОЯНИЕ: обычный достижимый criss-cross DAG: A и B от одной базы, main с родителями A,B, PR-head с родителями B,A; две реальные merge-base подтверждены `git merge-base --all`. Такой отказной вход назван явно; source ошибочного механизма — существующая строка модели `g merge-base --all "$base" "$head"` в model/pr_window.sh:15, из которой удалён только `--all`.
НАБЛЮДЕНИЕ: честная модель на этом DAG даёт rc 1 `PR_WINDOW_BASE_AMBIGUOUS`, мутант — rc 0; вся батарея мутанта зелёная 53/53. В каталоге отсутствует соответствующий отказной мир.
ОБХОД: осуществить указанную замену существующей операции, оставить всё остальное неизменным и выполнить --model: все 53 клетки зелёные, хотя неоднозначная база принимается. Нужны различающее предъявление неоднозначного основания обоим CLI и парный честный мир с единственной базой, а не требование конкретной реализации.

## НЕ ЗАЩИЩАЕТ

Доверенная CI-среда и настроенный origin остаются за границей по contracts/218:78; универсальную асимптотику не доказывает одна Trace2-батарея, ловцы — adversary/reviewer реализации. Локальный pre-push уже влитого текста и Д4 явно вне предмета и имеют отдельные маршруты.

## Советы

СОВЕТ contracts/218-okno-frozen-v-pr.md:54 — явно предъявить также измеренный merge-носитель с первым родителем вершиной стека и вторым цепочкой носителя: существующий main-merges мир полезен, но это не тот же названный порядок родителей. Само отсутствие клетки без выявленного нарушения отдельно не блокирует.

## Исполненные проверки и атаки

Клон одноразовый внутри собственной копии; TMPDIR вне клона и внутри копии. `uptime`: load average 5.33, 6.49, 6.98. Сдаточный лист выполнялся с SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400. Сырые итоговые строки:

```text
$ bash scripts/check_sdacha.sh "$PWD" contracts/218-okno-frozen-v-pr.md --run
СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)
rc=0
$ bash scripts/pre_critic.sh contracts/218-okno-frozen-v-pr.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh "$PWD/tmp/clone-crit218" contracts/218-okno-frozen-v-pr.md
OK
rc=0
$ W --repo .
CELLS=53 MUTATIONS=12 BINDINGS=24
KLETKI=53 ZELENYE=8 KRASNYE=45
rc=1
$ W --model
CELLS=53 MUTATIONS=12 BINDINGS=24
KLETKI=53 ZELENYE=53 KRASNYE=0
rc=0
$ W --stabs
CELLS=53 MUTATIONS=12 BINDINGS=24
STABY=12 SVJAZI=24 POIMANY=24 ZHIVYH=0
rc=0
```

`W` — команда из контракта. Показаны итоговые строки длинных прогонов, не весь stdout. Модель требует переноса PR-отбора в оба guard с сохранением прежних non-PR веток; требуемые контрактом 200/207/210/217 регрессы после реализации здесь не запускались и их успех не утверждается.

Независимые мутации модельных операций в одноразовом клоне: по одному изменённому субъекту на эксперимент, честный контроль перед каждой выбранной клеткой. Ниже полный сырой вывод команды `python3 "$PWD/tmp/clone-crit218/tmp/crit218_mutations.py"`, rc 0. Замены соответственно: diff-filter MD→M, удаление добавления собственной frozen-области, rev-list --not main→--not merge-base, сохранение --incr вместо снятия в PR. Для предпоследней дополнительно проверен весь каталог: 45 зелёных, 8 красных, то есть два показанных зелёных мира не являются выводом о всей батарее.

```text
ATTACK delete-not-md charter-delete-frozen
charter-delete-frozen GREEN rc=1
charter-delete-frozen RED rc=0 DIAGNOSIS,RC
RESULT delete-not-md charter-delete-frozen CAUGHT
ATTACK ignore-own-frozen-path frozen-own-frozen
frozen-own-frozen GREEN rc=1
frozen-own-frozen RED rc=0 DIAGNOSIS,RC
RESULT ignore-own-frozen-path frozen-own-frozen CAUGHT
ATTACK ignore-own-frozen-path frozen-delete-frozen
frozen-delete-frozen GREEN rc=1
frozen-delete-frozen RED rc=0 DIAGNOSIS,RC
RESULT ignore-own-frozen-path frozen-delete-frozen CAUGHT
ATTACK base-vs-main charter-owner-update
charter-owner-update GREEN rc=0
charter-owner-update GREEN rc=0
RESULT base-vs-main charter-owner-update SURVIVED
ATTACK base-vs-main frozen-main-merges-1284
frozen-main-merges-1284 GREEN rc=0
frozen-main-merges-1284 GREEN rc=0
RESULT base-vs-main frozen-main-merges-1284 SURVIVED
ATTACK cache-as-evidence charter-pr-cache-head
charter-pr-cache-head GREEN rc=1
charter-pr-cache-head RED rc=1 UNBOUNDED_HISTORY
RESULT cache-as-evidence charter-pr-cache-head CAUGHT
```

Дополнительная команда `python3 "$PWD/tmp/clone-crit218/tmp/crit218_fullmutation.py"`, rc 0, та же замена main→merge-base по всем клеткам: сырой итог `MUTANT KLETKI=53 ZELENYE=45 KRASNYE=8`; красные frozen/charter late-tag, neighbor-after, long-main, frozen-explicit-late-tag, frozen-renamed-values, все `UNBOUNDED_HISTORY`.

Б-1 воспроизведён командой `python3 "$PWD/tmp/clone-crit218/tmp/crit218_revert.py"`, rc 0. Скрипт использует конструктор frozen-own-frozen, запускает честный reference, создаёт поверх HEAD отдельный revert исходного блоба, обновляет HEAD и запускает тот же reference. Полный сырой вывод:

```text
BEFORE_REVERT rc=1 stdout=b''
pr: check_contract_frozen main=db4955b7cf100358a1b50c94e9dc107c6e869c8e base=db4955b7cf100358a1b50c94e9dc107c6e869c8e head=c6fdda057c558fb0777856985f2cd0a662c679fe
  FAIL contracts/701-fixture.md изменён без новой заморозки: на HEAD блоб 70182f4e613504898c1925139eba9739b16bd9c6, в заморозке v1 — 50dfc5c4f72bb4d455e6b1ccddab6fb561e45a3f. Выход: новый вердикт критика v2, freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full

AFTER_REVERT rc=0 stdout=b''
pr: check_contract_frozen main=db4955b7cf100358a1b50c94e9dc107c6e869c8e base=db4955b7cf100358a1b50c94e9dc107c6e869c8e head=8a40bf5c8424c31463c7d4c85814ee9133a7a495
  ok   contracts/701-fixture.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
```

Б-2 команда `python3 "$PWD/tmp/clone-crit218/tmp/crit218_crisscross.py"`, rc 0. Создаются A/B и merge-коммиты с переставленными родителями, origin/main и PR-head фиксируются, затем запускаются честная модель и мутант без --all. Полный сырой вывод:

```text
MERGE_BASES c506840ea616e6691ac8c2d7ac35ab1286fd30b7
12df7ffb7817042607eea5b234ce89cf4688d99f
HONEST rc= 1 stdout= b'' stderr= PR_WINDOW_BASE_AMBIGUOUS

MUTANT rc= 0 stdout= b'' stderr= pr: check_charter main=0309a3d2a5fd13296444623c85f0d9be25e60b65 base=c506840ea616e6691ac8c2d7ac35ab1286fd30b7 head=9e1e0ee02994ac15f66d4ceeed900b6c6bb6b9ac
```

Вся батарея Б-2: `python3 "$PWD/tmp/clone-crit218/tmp/crit218_ambiguous.py"`, rc 0; каждая из 53 клеток напечатала GREEN, полный сырой вывод:

```text
frozen-clean GREEN rc=0
frozen-late-tag GREEN rc=0
frozen-neighbor-before GREEN rc=0
frozen-neighbor-after GREEN rc=0
frozen-owner-update GREEN rc=0
frozen-owner-update-allowed GREEN rc=0
frozen-draft GREEN rc=0
frozen-long-main GREEN rc=0
frozen-missing-base GREEN rc=1
frozen-shallow GREEN rc=1
frozen-forged-base GREEN rc=1
frozen-no-origin GREEN rc=1
frozen-unrelated GREEN rc=1
frozen-own-frozen GREEN rc=1
frozen-retroactive-frozen GREEN rc=1
frozen-delete-frozen GREEN rc=1
frozen-verdict-fail GREEN rc=1
frozen-push-clean GREEN rc=0
frozen-push-bad GREEN rc=1
frozen-push-incr-empty GREEN rc=0
frozen-push-oracle GREEN rc=0
charter-clean GREEN rc=0
charter-late-tag GREEN rc=0
charter-neighbor-before GREEN rc=0
charter-neighbor-after GREEN rc=0
charter-owner-update GREEN rc=0
charter-owner-update-allowed GREEN rc=0
charter-draft GREEN rc=0
charter-long-main GREEN rc=0
charter-missing-base GREEN rc=1
charter-shallow GREEN rc=1
charter-forged-base GREEN rc=1
charter-no-origin GREEN rc=1
charter-unrelated GREEN rc=1
charter-own-frozen GREEN rc=1
charter-retroactive-frozen GREEN rc=1
charter-delete-frozen GREEN rc=1
charter-push-clean GREEN rc=0
charter-push-bad GREEN rc=1
charter-push-incr-empty GREEN rc=0
charter-push-oracle GREEN rc=0
charter-own-charter GREEN rc=1
charter-reverted-charter GREEN rc=1
charter-evil-merge GREEN rc=1
charter-side-charter GREEN rc=1
frozen-main-merges-1284 GREEN rc=0
charter-explicit-owner GREEN rc=0
frozen-explicit-late-tag GREEN rc=0
charter-pr-oracle GREEN rc=0
charter-pr-cache-head GREEN rc=1
charter-pr-cache-green GREEN rc=0
frozen-renamed-values GREEN rc=0
charter-renamed-values GREEN rc=1
MUTANT KLETKI=53 ZELENYE=53 KRASNYE=0
```
