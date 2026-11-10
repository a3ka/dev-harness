FAIL
OBJECT=5517790c633758ab4a5b5c94812038b18833f12a
СУД: repo=dev-harness; предмет=175; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (trace-critic.tsv, tier apex-sol); сессия=Crit175R1; модель-факт=openai-codex/gpt-5.6-terra (разрешённый autoFallback @gpt-terra); SHA=5517790c633758ab4a5b5c94812038b18833f12a; предыдущий=нет (Crit175v1 оборван без вердикта); исключение=нет.

# Вердикт критика — контракт 175 «табло станции без демонстрационных PR», полный вызов 1

## Предмет, независимость и полнота набора

Объект подтверждён живой командой `git rev-parse HEAD` в одноразовом клоне: `5517790c633758ab4a5b5c94812038b18833f12a` (rc 0), ровно OBJECT задания. `git show --format=fuller --stat --summary HEAD` показал автора `architect <architect@dev-harness.local>` и только пять новых путей: контракт и четыре файла `fixtures/workshop_project/tablo_demo_175/`; реализацию предмета кандидат не меняет. Судья — отдельная сессия `Crit175R1`, собственную работу не судит. План модели из `/tmp/dev-harness-verify/orch/trace-critic.tsv` — `zai/glm-5.3`; фактическая модель — `openai-codex/gpt-5.6-terra`, допустимый fallback tier `apex-sol` (`config/agent_models.json:59-63`).

Набор артефактов полон: предмет и rc-критерии закоммичены, все исполнители названы, шесть `ЗОНА`-строк есть, класс риска указан и соответствует предмету. Дельта полностью лежит в `ЗОНА architect` из `contracts/175-tablo-bez-demo.md:44`: `contracts/175-tablo-bez-demo.md` и `fixtures/workshop_project/tablo_demo_175/`. `bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md` дал rc 0, сырой вывод `OK`; Н-39-дверь также зелена в `pre_critic` (ни одной пары «стаб ↔ ветвь» в прозе контракта нет).

## Выполненные прогоны кандидата

```text
$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
175 demo_branch KRASNO visible=True expected=False rc=0
175 demo_title KRASNO visible=True expected=False rc=0
175 do_not_merge KRASNO visible=True expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo KRASNO visible=True expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=1]

$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --model
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --stabs
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
175 demo_title KRASNO visible=True expected=False rc=0
175 STAB branch_only caught @ demo_title
175 demo_branch KRASNO visible=True expected=False rc=0
175 STAB title_only caught @ demo_branch
175 do_not_merge KRASNO visible=True expected=False rc=0
175 STAB marker_ignored caught @ do_not_merge
175 real_green KRASNO visible=False expected=True rc=0
175 STAB exclude_every_mob_pr caught @ real_green
175 real_red KRASNO visible=False expected=True rc=0
175 STAB exclude_red_ci caught @ real_red
175 not_demo_word KRASNO visible=False expected=True rc=0
175 STAB word_substring caught @ not_demo_word
[rc=0]

$ bash scripts/check_ceilings.sh
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 161 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md
OK
[rc=0]

$ bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека: 
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_predposylki.sh . contracts/175-tablo-bez-demo.md
PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/175-tablo-bez-demo.md
модель угроз: список ЗАЩИЩАЕТ: отсутствует
[rc=1]

$ bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md
проводка: строка вне грамматики: ПРЕДПОСЫЛКИ:
[rc=1]
```

Живой шов тоже исполним, rc 0:

```text
$ python3 ops/server/user/orch-tablo 20
ТАБЛО 12:17 UTC (окно 20 мин)
  РАБОТАЕТ 158 [frozen]: Impl158R7 (0 мин)
  ЖДЁТ CI 173 [frozen]: PR #693 — последнее: агент Impl173R1 сдал результат
  РАБОТАЕТ 175 [до заморозки]: Crit175R1 (0 мин)
  СТОИТ 603 мин PR Complior-mob#164 (wip/143/implementer): CI зелёный, по нему никто не работает
  СТОИТ 6873 мин PR Complior-mob#163 (wip/118/implementer): CI зелёный, по нему никто не работает
  СТОИТ 7000 мин PR Complior-mob#162 (wip/163/implementer): CI зелёный, по нему никто не работает
  СТОИТ 12748 мин PR Complior-mob#150 (demo/kompakt-d24): CI красный, по нему никто не работает
  СТОИТ 12778 мин PR Complior-mob#149 (demo/investor-d24): CI красный, по нему никто не работает
  СТОИТ 15052 мин PR Complior-mob#148 (wip/149/implementer): CI красный, по нему никто не работает
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  харнесс: в работе предметов — 1
  mob: в работе предметов — 2
итог: стоит без хода — 11  → сделай следующий шаг по каждой строке СТОИТ до wait
[rc=0]
```

Это наблюдает поддерживаемый вход: в одном живом списке уже одновременно есть несколько PR, включая два demo PR (#149/#150) и рабочие PR. Их branch/title/marker описаны в `contracts/175-tablo-bez-demo.md:10`.

## Мутационная атака критика

Все ниже — одноразовый клон `Crit175R1-175-mutations`, никогда не коммитились. Для каждого M сначала из обязательной честной модели `fixtures/workshop_project/tablo_demo_175/model.py:13-22` был собран предметный исходник, затем заменена ровно одна существующая операция и прогнана штатная команда `--repo .`; отдельная конформная JSON-клетка подана через тот же живой CLI-шов `probe.run_case`. Строки `KRASNO` в последнем вызове означают наблюдённое нарушение, а не ожидаемый зелёный результат.

### M1 — branch без casefold

```text
$ python3 tmp/critic175_mutate.py case_sensitive_branch && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION case_sensitive_branch applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py upper_branch
175 upper_branch KRASNO visible=True expected=False rc=0
[rc=1]
```

### M2 — title без IGNORECASE

```text
$ python3 tmp/critic175_mutate.py case_sensitive_title && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION case_sensitive_title applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py lower_title
175 lower_title KRASNO visible=True expected=False rc=0
[rc=1]
```

### M3 — title-признак только для Complior-mob

```text
$ python3 tmp/critic175_mutate.py title_mob_only && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION title_mob_only applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py harness_title
175 harness_title KRASNO visible=True expected=False rc=0
[rc=1]
```

### M4 — «НЕ МЕРЖИТЬ» только для Complior-mob

```text
$ python3 tmp/critic175_mutate.py marker_mob_only && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION marker_mob_only applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py harness_marker
175 harness_marker KRASNO visible=True expected=False rc=0
[rc=1]
```

### M5 — потеря красного рабочего PR dev-harness

```text
$ python3 tmp/critic175_mutate.py exclude_harness_red && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION exclude_harness_red applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py harness_red
175 harness_red KRASNO visible=False expected=True rc=0
[rc=1]
```

### M6 — исключение только при ровно одном маркере

```text
$ python3 tmp/critic175_mutate.py combined_one_only && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION combined_one_only applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_variant.py combined_demo
175 combined_demo KRASNO visible=True expected=False rc=0
[rc=1]
```

### M7 — `continue` фильтра заменён `break`

```text
$ python3 tmp/critic175_mutate.py break_filter && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
MUTATION break_filter applied
175 demo_branch ok visible=False expected=False rc=0
175 demo_title ok visible=False expected=False rc=0
175 do_not_merge ok visible=False expected=False rc=0
175 real_green ok visible=True expected=True rc=0
175 real_red ok visible=True expected=True rc=0
175 not_demo_word ok visible=True expected=True rc=0
175 harness_demo ok visible=False expected=False rc=0
175 harness_real ok visible=True expected=True rc=0
[rc=0]

$ python3 tmp/critic175_multi.py
175 multirow KRASNO real=False demo=False rc=0
ТАБЛО 12:21 UTC (окно 20 мин)
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  СТОИТ ПОТОК харнесс: ни один предмет не в работе — больше 20 мин; возьми следующую задачу потока
  СТОИТ ПОТОК mob: ни один предмет не в работе — больше 20 мин; возьми следующую задачу потока
итог: стоит без хода — 2  → сделай следующий шаг по каждой строке СТОИТ до wait
[rc=1]
```

## Находки

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:34-37 — контракт вводит фильтр по чужому ответу GitHub, но его обязательная секция модели угроз не соответствует действующей норме 041: `ЗАЩИЩАЕТ:` и `НЕ ЗАЩИЩАЕТ:` стоят внутри буллетов вместо самостоятельных меток со следующими буллетами.
ОБЯЗАТЕЛЬСТВО: норма `roles/critic.md` §«Норма модели угроз» требует для такого гарда секцию `## Модель угроз`, самостоятельные списки `ЗАЩИЩАЕТ:`/`НЕ ЗАЩИЩАЕТ:` и минимум по одному буллету.
СОСТОЯНИЕ: в OBJECT есть фильтр полей `headRefName`/`title` внешнего `gh pr list` (`contracts/175-tablo-bez-demo.md:23-25`), а формальная секция записана на :36-37.
НАБЛЮДЕНИЕ: `bash scripts/check_threat_model.sh . contracts/175-tablo-bez-demo.md` завершился rc 1 с дословным выводом `модель угроз: список ЗАЩИЩАЕТ: отсутствует`. В одноразовой копии перестановка только меток и их существующих текстов в каноническую форму дала `модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))`, rc 0.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: форма модели угроз на пути контракта проходит `check_threat_model.sh` rc 0, сохраняя оба названных смысловых предела.

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:32,118-123 — заявленный перед done `check_provodka.sh` не может быть зелёным на предъявленном контракте: поле проводки не завершается до `ПРЕДПОСЫЛКИ:`, а после одного лишь структурного исправления остаётся не подключённый к `.githooks`/`.github` guard.
ОБЯЗАТЕЛЬСТВО: `contracts/175-tablo-bez-demo.md:32` обещает `bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md` с rc 0; AGENTS.md §«Воркфлоу майлстоуна», п.8 требует, чтобы каждый канал проводки существовал и был подключён.
СОСТОЯНИЕ: `ПРЕДПОСЫЛКИ:` на :122 не отделён заголовком от `ПРОВОДКА:` на :118; единственный канал `- guard=ops/server/user/orch-tablo` на :119 не имеет вызова в `.githooks` или `.github/workflows` (поиск `ops/server/user/orch-tablo` там не дал совпадений). Существующий вызов находится в `roles/orchestrator.md:302`, то есть не является требуемой guard-проводкой.
НАБЛЮДЕНИЕ: на OBJECT команда дала rc 1, `проводка: строка вне грамматики: ПРЕДПОСЫЛКИ:`. Чтобы не скрыть следующую причину за первой, в одноразовой копии перед `ПРЕДПОСЫЛКИ:` добавлен только заголовок следующего раздела; повтор дал rc 1, `проводка: guard не подключён: ops/server/user/orch-tablo не вызывается в .githooks/ или .github/workflows/`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: поле проводки имеет корректную границу, а предметный канал действительно подключён по своей грамматике; полный `check_provodka.sh` на пути контракта возвращает rc 0.

БЛОКИРУЕТ contracts/175-tablo-bez-demo.md:23-31 — rc-критерий слабее объявленных инвариантов: восемь одиночных клеток не различают реализацию, нарушающую case-insensitive условия, условие в одном из двух поддерживаемых репозиториев, совместные маркеры и список из нескольких PR, хотя все эти состояния входят в объявленный вход.
ОБЯЗАТЕЛЬСТВО: :23 требует независимо исключать `demo/` и отдельное `DEMO` без учёта регистра, а также `НЕ МЕРЖИТЬ`; :24 требует сохранить зелёные и красные рабочие PR и счёт; :25 объявляет входом JSON списка `gh pr list`; :29 фиксирует живой одновременный набор #149/#150 и рабочих PR.
СОСТОЯНИЕ: источник входа — поддерживаемый `gh pr list` для обоих репозиториев (`ops/server/user/orch-tablo:93-114`) и наблюдённый живой список выше. Источник ошибочного механизма — замена/удаление предметных операций обязательной модели :18-21: `casefold`, `re.IGNORECASE`, условия title/marker и `continue`; для M5 изменена существующая операция печати рабочего PR, для M7 — тот же `continue` фильтра.
НАБЛЮДЕНИЕ: M1–M7 выше: после каждой названной замены штатный `red_tablo_demo_175.sh --repo .` остаётся зелёным (rc 0, все 8 `ok`), но конформные поддерживаемые входы наблюдаемо нарушают обещание — `upper_branch`, `lower_title`, `harness_title`, `harness_marker`, `harness_red`, `combined_demo` и `multirow` красны. Особенно M6 воспроизводит уже измеренный живой класс: #149/#150 одновременно несут branch demo и title/marker, а M7 удаляет последующий рабочий PR и меняет итог с 3 на 2.
ОБХОД: реализация с одним из M1–M7 удовлетворяет названный rc-критерий (rc 0, все восемь клеток `ok`), но показывает demo PR либо теряет рабочий PR/счёт на допустимом входе.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: батарея через публичный CLI предъявляет на обоих репозиториях независимые branch/title/marker условия в требуемом регистре, положительные зелёный и красный PR, сочетание нескольких маркеров и список, где demo PR предшествует рабочему; она проверяет самостоятельные строки и итог. Каждая M1–M7 тогда возвращает rc 1, а честная модель — rc 0. Способ реализации фильтра не предписывается.

СОВЕТ contracts/175-tablo-bez-demo.md:9 — полный список найденных механических расхождений ссылок: query PR на OBJECT занимает `ops/server/user/orch-tablo:93-114`, а печать PR — :153-155, не заявленные «строки 90–109 и 143–150». Исправить ссылки полезно исполнителю, но путь и поведение однозначны, поэтому это не блокирует само по себе.

Вердикт: FAIL — три блокирующих класса: невалидная обязательная модель угроз, невыполнимая заявленная проводка и критерий, который пропускает семь воспроизводимых замен обязательных операций. Зелёные `--model`, `--stabs`, `check_ceilings`, `check_precision_gate`, `pre_critic` и живой запуск не отменяют наблюдённые rc 1 и ложную достаточность приёмки.
