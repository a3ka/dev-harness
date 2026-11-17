# Сдаточный лист 201 — done-дверь: содержательная сверка

Дата: 2026-11-17. Дерево: wip/201/architect (главный чекаут не тронут). Все прогоны — из
корня worktree, окружение без ambient `GIT_AUTHOR_*`/`GIT_COMMITTER_*` (env -u), если не
сказано иное. Оракул батареи — в памяти раннера; краснота голого прогона — дефект ЖИВОЙ
двери `scripts/done_contract.sh` (зона implementer), до её ремонта.

## Прогоны (числа из вывода)

- Голый прогон батареи против текущего дерева:
  `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh`
  → rc 1, `CELLS=28 STABS=0 FAILURES=17`. Красные (дефект двери наблюдаем):
  (а) `a-accept-staroj-versii`, `a-net-zamorozki`, `a-verdikt-bez-object`;
  (б) `b-produkt-object-mimo-main`, `b-produkt-object-otsutstvuet`, `b-vneshnij-ne-vlit`,
  `b-vneshnij-bez-stroki`, `b-vneshnij-stroka-krivaja`, `b-vneshnij-api-nedostupen`;
  (в) `v-riskovyi-bez-adversarii`, `v-riskovyi-drugoj-object`, `v-riskovyi-svezhij-fail`,
  `v-adversarii-bez-object`, `v-default-riskovyi-bez-zapisi`, `v-klass-neodnoznachen`;
  (г) `g-arch-v-skobkah` (живой отказ `ARCH_CI` на имени «arch (пин внешней архитектуры,
  model fitness + code-ratchet)» — измеренная боль), `g-arch-s-probelom`.
  Зелёные 11: `a-verdict-posle-zamorozki`, `a-ravenstvo-frozen-verdikt`, `b-produkt-vlito`,
  `b-vneshnij-produkt-vlit`, `v-riskovyi-sopostavimyj-object`, `v-obychnyj-bez-adversarii`,
  `v-legacy-obychnyj`, `g-arch-tochno-imja`, `g-archive`, `g-architecture`, `g-march`
  (у зелёных live-клеток тег `done/contracts/777/1` создан, у красных — отсутствует).
- `--model` → rc 0, `CELLS=28 STABS=0 FAILURES=0`.
- `--stabs` → rc 0, `CELLS=28 STABS=8 FAILURES=0` (все 8 стабов caught, каждый на своей клетке).
- Соседи (сохранность): `architecture_process_187` — `--repo .` rc 0 (`CELLS=54 STABS=0
  FAILURES=0`), `--model` rc 0, `--stabs` rc 0 (`STABS=56`) — после дооснащения миров
  done-клеток (тег заморозки, OBJECT-строка, строка класса риска; ПЕРЕСЕЧЕНИЕ architect).
  `rezhim_996 --matrix` → examined=111, mutants=76, mismatches=1 — ЕДИНСТВЕННЫЙ пропуск
  (mutant `skip-committed` / `done-committed-preserved`) существует ДО предмета 201
  (базлайн до моих правок измерен тем же прогоном: тот же mismatches=1); правки 201 мир
  996 не трогают, порядок новых проверок (после ПОТРЕБИТЕЛЕЙ) клеток done-*-preserved
  не занимает.
- Гейты: `check_precision_gate` rc 0; `check_spec_ready` rc 0; `check_threat_model` rc 0
  (ЗАЩИЩАЕТ 5, НЕ ЗАЩИЩАЕТ 6); `check_ceilings` rc 0; `pre_critic` — прогон в момент
  сдачи (см. строку ниже); `check_provodka` — красен ДО подключения CI (г2: guard не
  вызывается в workflows), зелёным становится шагом orchestrator (gen_ci_steps --write,
  норма 038-CI; прецедент 187:44 — то же состояние до wiring).

## Карта классов К-01…К-17 (roles/critic.md §Связка с автором)

- К-01: чисто — pre_critic/precision/spec/threat/ceilings rc 0 (выводы выше); сдаточный
  лист — этот файл, строка `СДАЧА:` в контракте под заголовком «## Сдача и предпосылки»;
  `scripts/check_sdacha.sh` в дереве ОТСУТСТВУЕТ (норма 192 ещё не реализована
  механизмом) — прогон невозможен, лист исполнен вручную, расхождений с прогонами нет.
- К-02: чисто — слово владельца 2026-11-17 п.10 (дословно в §Слово владельца) и задание
  orch покрыты пунктами (а)–(г) один-к-одному; данные raw-замера перенесены в §Замеры
  числами (22/5/6; 160/409 OBJECT-строк; 5 строк risk-legacy).
- К-03: чисто — 7 строк ПЕРЕСЕЧЕНИЕ implementer (038/094/168/184/187/992/996 — все
  живые заморозки, чья зона включает scripts/done_contract.sh; список сверен с union
  zones_load по пути scripts/done_contract.sh: ровно эти семь NNN) + 2 строки
  ПЕРЕСЕЧЕНИЕ architect (батарея 187) + 178 строк orchestrator (union-коллизии трёх
  путей реестра CI, канон 195); сохранность доказана прогонами 187 (три режима rc 0)
  и 996 (mismatches=1 = базлайн).
- К-04: чисто — все тронутые файлы в ЗОНА architect контракта (контракт, батарея 201,
  probe.py/workflow_probe.py 187); производных файлов нет; реестр CI — зона
  orchestrator, своих строк не пишу.
- К-05: чисто — каждый пункт приёмки несёт команду и rc (§Приёмка, четыре блока
  Дано/когда/тогда).
- К-06: н/п — клеток отказа среды батарея не вводит; все отказы мира — входы двери,
  не таймауты; недоступность compare-API — честный rc 1 «не проверена» (клетка
  `b-vneshnij-api-nedostupen`), не rc 2.
- К-07: чисто — голый прогон против ЖИВОЙ двери (`--repo` не задан → инструменты корня
  репо): 17 красных клеток наблюдают реальный дефект, 11 зелёных проходят через
  настоящие check_provodka/check_consumers/187а в тех же мирах; двойника двери нет.
- К-08: чисто — на каждое обязательство (а)/(б)/(в)/(г) есть различающая клетка
  (удаление проверки = зелень клетки: стабы s-a…, s-b…, s-v…, s-g… каждый пойман на
  своей клетке, `--stabs` rc 0).
- К-09: чисто — конформные входы покрыты по ветвям: (а) 5 (нет заморозки/нет OBJECT/
  старый accept/равенство/потомок), (б) 8 (продукт: влито/мимо main/отсутствует;
  внешние: влито/не влито/нет строки/кривая строка/API 404), (в) 9 (рисковый с парой/
  без/чужой OBJECT/свежий FAIL/без OBJECT; обычный; default-рисковый; legacy-обычный;
  неоднозначный), (г) 6 (arch/arch (…)/arch␣/archive/architecture/march).
- К-10: чисто — наблюдаемый эффект: rc двери + наличие/отсутствие тега
  `done/contracts/777/1` (проверяется раннером у каждой live-клетки), не строки мира.
- К-11: чисто — ожидания в памяти раннера (facts-словарь), compare/check-runs JSON —
  вне мира, шим curl в отдельном bin-каталоге; мир своего будущего не читает.
- К-12: чисто — git-факты через plumbing (`merge-base --is-ancestor`, `rev-parse`,
  `cat-file -e`), compare/check-runs — настоящий формат API GitHub, разбор jq; своего
  парсера форматов батарея не пишет.
- К-13: чисто — секретов батарея не вводит; токен (GITHUB_TOKEN/GH_TOKEN) идёт
  заголовком Authorization как у 187а, в командных строках и файлах мира отсутствует
  (белый список наружных строк — сам шим curl).
- К-14: чисто — честные эквивалентные записи зелёны: `a-ravenstvo-frozen-verdikt`
  (F == коммит вердикта), `b-produkt-vlito`/`b-vneshnij-produkt-vlit` (влито),
  `v-riskovyi-sopostavimyj-object` (адверсарий на том же OBJECT),
  `v-obychnyj-bez-adversarii`/`v-legacy-obychnyj` (обычному адверсарий не нужен),
  `g-arch-tochno-imja` (буквальное «arch»).
- К-15: чисто — числа из выводов прогонов (CELLS/STABS/FAILURES; union-коллизии из
  zones_load; OBJECT-строки 160/409 — grep по verdicts/review); числа контракта
  сверены с этими выводами (28/17/8/54/111/1).
- К-16: чисто — класс риска: рисковый, основание — гейт приёмки (закрытый перечень
  слова владельца 2026-10-24); модель угроз ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ по свойствам, не
  перечнем входов; граница 163-класса названа с ловцом.
- К-17: чисто — расхождений с моделью архитектуры нет: предмет — механизм харнесса
  (дверь), не продукта; строки АРХИТЕКТУРА/ОПЕРАЦИЯ не вводит; шестой вопрос
  §Архитектура 188 к двери неприменим по классу (дверь судит форму и git-факты).

## Известные остатки (не блокеры)

- `check_provodka` г2 зелёнеет подключением CI-шага (зона orchestrator, до freeze).
- `scripts/check_sdacha.sh` отсутствует в дереве (норма 192 не реализована механизмом):
  лист исполнен вручную выше.
- 996-матрица: единственный mismatches=1 существует до предмета 201 (базлайн измерен).
