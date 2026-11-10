accept
OBJECT=8533d157a4e858721625cf6680ec2de4e2fd0a8f
СУД: repo=dev-harness; предмет=175; фаза=реализация; роль=reviewer; вызов=1 (полный); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; сессия=Rev175v1; SHA=8533d157a4e858721625cf6680ec2de4e2fd0a8f (tip `wip/175/implementer`, один коммит автора `implementer` на 3b5ab66c); контракт=frozen/contracts/175/1 → 81541e0ea6465340c50e84f9e44d9b8259e0be02; автор реализации — implementer (minimax/MiniMax-M3), автор клеток — architect; предыдущий=нет; класс риска обычный, адверсарий не назначен

# Вердикт ревьюера — 175, реализация (вызов 1)

- Принятые блобы: `ops/server/user/orch-tablo` 1e3f6b3f0a942f18108cca211e597d6dd8c29c54 и `ops/server/README.md` c309c8535c912eb2933bad061e91b755fbbd82e8. Новая редакция любого из них это accept не наследует.
- Блобы контракта и семьи на OBJECT равны тегу. `git diff --stat 81541e0e..8533d157 -- contracts/175-tablo-bez-demo.md fixtures/workshop_project/tablo_demo_175/` пуст, rc 0. Хеши: контракт 6628aafe, `probe.py` 61aa43c5, `model.py` 56cece51, `red_tablo_demo_175.sh` 213afd59.
- Находки: `.review/2026-11-10-99.md`. Блоков 0. Советов 2: С-1 owner→architect, С-2 architect. Наблюдений 2: Н-1 и Н-2, оба owner.
- Клон одноразовый: `/tmp/dev-harness-verify/Rev175v1/repo` (свой `.git`, origin `ssh://git@github.com/a3ka/dev-harness.git`). Worktree базы: `/tmp/dev-harness-verify/Rev175v1/base` на 3b5ab66c. Зонды: `sim706.py`, `mut175.py` в `/tmp/dev-harness-verify/Rev175v1/`.

## 1. Область правки ⊆ зоны (проверки 1, 5, 6)

```
$ git fetch origin wip/175/implementer wip/175/orchestrator && git rev-parse FETCH_HEAD
8533d157a4e858721625cf6680ec2de4e2fd0a8f
$ git log --format='%H %an <%ae> %s' origin/main..8533d157
8533d157a4e858721625cf6680ec2de4e2fd0a8f implementer <implementer@dev-harness.local> 175: табло не показывает демонстрационные PR
$ git merge-base 8533d157 origin/main
3b5ab66c14bce434e65cf287a5b71a4e834d1f0e
$ git diff --numstat 3b5ab66c 8533d157
2	0	ops/server/README.md
9	1	ops/server/user/orch-tablo
$ git diff --stat 3b5ab66c 8533d157 -- contracts/ fixtures/ roles/ AGENTS.md      → пусто, rc 0
$ git diff --stat 24cc7ea9c 3b5ab66c -- ops/server/user/orch-tablo                → пусто, rc 0 (база = исходная голова контракта по субъекту)
```

- ЗОНА implementer в блобе тега: `ops/server/user/orch-tablo ops/server/README.md`. Изменены ровно эти два файла.
- README: +2 строки. Это один пункт «**Демонстрационные PR табло не показывает.** …» в разделе orch-tablo и пустая строка. Удалений 0. Пересечения 074/081/085/093/997 соблюдены: «только предложение о демонстрационных PR».
- orch-tablo: `title` добавлен в `--json` рядом с прежними полями, а предикат с `continue` стоит в начале `for p in rows:`, до `st = …` и `prs.append`. Формат строк, окно, потоки и итог не тронуты. Шов прежний: `python3 ops/server/user/orch-tablo [минут-окна]`.
- Атомарность: один коммит, одна задача, ссылка «175:» и `frozen/contracts/175/1` в сообщении.
- Нормативные документы (`roles/`, `contracts/`, `AGENTS.md`) диффом не тронуты.
- Своя мера зон, коммиты от `frozen/contracts/175/1` до головы проводки:
  ```
  $ for c in $(git rev-list --no-merges 'frozen/contracts/175/1^{commit}'..b7537062); do … git diff-tree --name-only -r $c; done
  b7537062 orchestrator :.github/workflows/ci.yml registry/ci-steps.tsv registry/ci-zamery.tsv
  8533d157 implementer :ops/server/README.md ops/server/user/orch-tablo
  3b5ab66c orchestrator :registry/contracts.tsv          (freeze-строка реестра, дверь минта 031)
  ```
  Каждый автор остаётся в своей ЗОНА-строке тега.
- `bash scripts/check_zones.sh`. Полный прогон зон в CI PR #706 на b7537062, а это OBJECT плюс коммит проводки: job `legkij`, 16:17:43→16:26:25 UTC. Лог: `+ bash scripts/check_zones.sh --incr tmp/ci-incr/zones.sha` → `incr: check_zones полный прогон (база 87b48c61 не предок HEAD b7537062 …)` → `замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 52048 · проверено по зонам: 13662`. Строк «вне зоны»/FAIL 0, job success. Локально полный прогон тоже зелёный. В worktree OBJECT 8533d157 без reslop выполнен `bash scripts/check_zones.sh` → `замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 52023 · проверено по зонам: 13652`, `rc=0`, wall 578.9 с. Первый прогон через `reslop t --` в клоне был оборван таймаутом команды 600 с и в зачёт не идёт. Зональность 175 доказана своей мерой выше и полным прогоном CI.

## 2. Приёмка на OBJECT — мой прогон, не вывод автора (проверки 2, 7)

```
=== --repo .        (клон на 8533d157)
175 demo_branch ok rows=0 expected=0 rc=0
175 demo_title ok rows=0 expected=0 rc=0
175 do_not_merge ok rows=0 expected=0 rc=0
175 real_green ok rows=1 expected=1 rc=0
175 real_red ok rows=1 expected=1 rc=0
175 not_demo_word ok rows=1 expected=1 rc=0
175 harness_demo ok rows=0 expected=0 rc=0
175 harness_real ok rows=1 expected=1 rc=0
175 upper_branch ok rows=0 expected=0 rc=0
175 lower_title ok rows=0 expected=0 rc=0
175 harness_title ok rows=0 expected=0 rc=0
175 harness_marker ok rows=0 expected=0 rc=0
175 harness_red ok rows=1 expected=1 rc=0
175 combined_demo ok rows=0 expected=0 rc=0
175 multirow ok rows=2 expected=2 rc=0
rc=0
=== --model   → те же 15 клеток ok, rc=0
=== --stabs   → 15 клеток контроля ok, затем 13 пар «KRASNO @ клетка / STAB … caught», rc=0:
175 STAB branch_only caught @ demo_title
175 STAB title_only caught @ demo_branch
175 STAB marker_ignored caught @ do_not_merge
175 STAB exclude_every_mob_pr caught @ real_green
175 STAB exclude_red_ci caught @ real_red
175 STAB word_substring caught @ not_demo_word
175 STAB case_sensitive_branch caught @ upper_branch
175 STAB case_sensitive_title caught @ lower_title
175 STAB title_mob_only caught @ harness_title
175 STAB marker_mob_only caught @ harness_marker
175 STAB exclude_harness_red caught @ harness_red
175 STAB combined_one_only caught @ combined_demo
175 STAB break_filter caught @ multirow
```

Счёт сверен своей мерой: 15 клеток = 15 ключей `CASES` в `probe.py`; 13 строк `STAB … caught` = 13 записей `mutants`; `ZHIV` 0. Заявление «13/13 поймано» подтверждено. В CI PR #706 (run 42852996957, job `ci (l2 …)` 129958571534, HEAD b7537062) тот же шаг напечатал `+ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo . && … --stabs`, 15+15 клеток ok, `STAB caught 13 ZHIV 0 CONTROL_INVALID 0` (подсчёт по логу через `gh api …/jobs/129958571534/logs`), run conclusion `success`.

Гейты авторской пачки на дереве базы (контракт равен тегу), каждый через `reslop t --`: `check_ceilings.sh` → exit 0 «потолки в порядке»; `check_precision_gate.sh . contracts/175-tablo-bez-demo.md` → exit 0; `pre_critic.sh --repo . contracts/175-tablo-bez-demo.md` → exit 0, `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2`.

## 3. Красное предъявлено (проверка 4)

Та же семья против дерева базы 3b5ab66c:

```
$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo ../base
175 demo_branch KRASNO rows=1 expected=0 rc=0
175 demo_title KRASNO rows=1 expected=0 rc=0
175 do_not_merge KRASNO rows=1 expected=0 rc=0
175 real_green ok rows=1 expected=1 rc=0
175 real_red ok rows=1 expected=1 rc=0
175 not_demo_word ok rows=1 expected=1 rc=0
175 harness_demo KRASNO rows=1 expected=0 rc=0
175 harness_real ok rows=1 expected=1 rc=0
175 upper_branch KRASNO rows=1 expected=0 rc=0
175 lower_title KRASNO rows=1 expected=0 rc=0
175 harness_title KRASNO rows=1 expected=0 rc=0
175 harness_marker KRASNO rows=1 expected=0 rc=0
175 harness_red ok rows=1 expected=1 rc=0
175 combined_demo KRASNO rows=1 expected=0 rc=0
175 multirow KRASNO rows=4 expected=2 rc=0
rc=1
```

10 demo-клеток красны собственным предъявлением, 5 рабочих зелёны. Это совпадает со строкой приёмки 2.

Стабы мутируют `honest()` модели, а не файл OBJECT. Поэтому красное против сломанной *реализации* предъявлено моими мутантами OBJECT (`mut175.py`). Каждый мутант кладётся в своё дерево `mut/<имя>/ops/server/user/orch-tablo` и судится через `--repo <дерево>`:

```
M0_identity: rc=0 KRASNO=[]
M1_branch_case: rc=1 KRASNO=['upper_branch']
M2_title_case: rc=1 KRASNO=['lower_title']
M3_title_substring: rc=1 KRASNO=['not_demo_word']
M4_marker_case: rc=1 KRASNO=['harness_marker']
M5_branch_contains: rc=0 KRASNO=[]
M6_title_prefix_only: rc=1 KRASNO=['not_demo_word']
M7_mob_only: rc=1 KRASNO=['harness_demo', 'harness_title', 'harness_marker', 'multirow']
M8_title_key_strict: rc=0 KRASNO=[]
M9_skip_red: rc=1 KRASNO=['real_red', 'harness_red', 'multirow']
```

Из 9 неединичных мутантов красны 7.
- M5 (`'demo' in ветка` вместо префикса) жив. Это пробел семьи, совет С-2. OBJECT этого дефекта не несёт.
- M8 (`p['title']` без `or ''`) жив законно. Конформный ответ gh всегда содержит строку `title`, поэтому null-title не контрпример (строка 25 контракта). Устойчивость OBJECT к `None` проверена зондом ниже.

## 4. Инварианты своей мерой — граничные входы, оба репозитория, живой gh (проверки 1–3, ложная зелень)

Предикат OBJECT (дословно из файла) на граничных входах:

```
'wip/1/x' 'Demo day' True              'wip/1/x' 'DEMOGRAPHIC' False
'wip/1/x' 'demo-ish build' True        'wip/1/x' 'demos' False
'wip/1/x' 'не мержить' True            'wip/1/x' 'DEMO_ONLY' False
'wip/1/x' '' False                     'wip/1/x' 'DEMOверсия' False
'wip/1/x' None False                   'wip/1/x' 'ДЕМО' False
'wip/1/x' 'НЕ\xa0МЕРЖИТЬ' False        'wip/1/x' 'НЕ  МЕРЖИТЬ' False
'wip/136/demo' 'x' False               'Demo/x' 'x' True
'demos/x' 'x' False                    'wip/demo/x' 'x' False
'wip/1/x' 'табло без демо-PR' False    'wip/1/x' 'nodemo' False
```

Регистр ветки и слова, `DEMOGRAPHIC`, пустой и null title, нижний регистр маркера дают ожидаемое по инварианту 1. Маркер через неразрывный пробел или двойной пробел не ловится. Литерал контракта — «НЕ МЕРЖИТЬ», так что это в пределах нормы, хотя владельцу может быть полезно об этом знать.

Тот же предикат на живом `gh pr list` (16:4x UTC):

```
EXCLUDED a3ka/dev-harness 706 wip/175/orchestrator
a3ka/dev-harness open 17
EXCLUDED a3ka/Complior-mob 150 demo/kompakt-d24
EXCLUDED a3ka/Complior-mob 149 demo/investor-d24
a3ka/Complior-mob open 13
```

Из 13 mob-PR отсечены ровно два демонстрационных, так что «все mob-PR» фильтр не вырезает. `Complior-mob#155` с веткой `wip/136/demo` не отсекается. На табло его нет и на базе, и на OBJECT: у него 0 статусов CI, ветвь `if not st: continue`. Отсечение `dev-harness#706` разобрано в С-1: на табло оно меняет ЖДЁТ CI на СТОИТ и счёт. По букве инварианта 1 и модели architect это поведение верное, поэтому вынесено владельцу.

**Живой запуск до/после** (строка приёмки 1, `[ВНИМАНИЕ]` про счёт обычных PR):

```
=== BASE 3b5ab66c                                          === OBJECT 8533d157
  РАБОТАЕТ 175 [frozen]: Rev175v1 (0 мин)                    РАБОТАЕТ 175 [frozen]: Rev175v1 (0 мин)
  СТОИТ 7139 мин PR Complior-mob#163 (wip/118/implementer): CI зелёный …    (то же)
  СТОИТ 7266 мин PR Complior-mob#162 (wip/163/implementer): CI зелёный …    (то же)
  СТОИТ 8525 мин PR Complior-mob#161 (owner/projectid-lower): CI зелёный …  (то же)
  СТОИТ 8617 мин PR Complior-mob#160 (wip/136/ci): CI зелёный …             (то же)
  СТОИТ 13014 мин PR Complior-mob#150 (demo/kompakt-d24): CI красный …      — нет
  СТОИТ 13045 мин PR Complior-mob#149 (demo/investor-d24): CI красный …     — нет
  СТОИТ 15318 мин PR Complior-mob#148 (wip/149/implementer): CI красный …   (то же)
  СТОИТ 7060 мин PR Complior-mob#147 (wip/148/implementer): CI красный …    (то же, 7061 мин)
  СТОИТ 7080 мин PR Complior-mob#146 (wip/147/implementer): CI красный …    (то же)
  СТОИТ 19792 мин PR Complior-mob#122 (cmp-mob-116/mission): CI красный …   (то же)
ПОТОКИ: … харнесс: в работе предметов — 1 / mob: в работе предметов — 1      (то же)
итог: стоит без хода — 10  → …                              итог: стоит без хода — 8  → …
rc=0                                                        rc=0
```

`#149` и `#150` исчезли, 8 настоящих строк, в том числе 4 красные, и потоки совпадают. Итог изменился на −2, ровно на эти две строки. Абсолютное «13 → 11» автора сейчас не воспроизводится, потому что живое состояние другое (Н-2). Дельта совпадает.

Модель против реализации: `difflib.unified_diff(honest(), OBJECT)` даёт только `@@ -99,0 +100,3 @@` и три строки комментария (Н-1). На любом gh-входе поведение реализации и модели architect одинаково, в том числе на живых данных выше.

## 5. Проверка не подогнана (проверка 3)

- `git log 3b5ab66c..8533d157 -- fixtures contracts` пуст: implementer не трогал ни клетки, ни фикстуру, ни контракт. История семьи — только коммиты `architect`: 2aeb3b71 и 81541e0e.
- Литералы клеток (`901…918`, `investor-d24`, `Screen work`) в `orch-tablo` отсутствуют, предикат общий.

## 6. ПРОВОДКА (038) и достаточность проводки CI

- Канал контракта: `role=roles/orchestrator.md «При каждом пробуждении … запусти python3 ops/server/user/orch-tablo …»`. Строка существует в `roles/orchestrator.md` и потребителем табло остаётся она же. 175 поведенческой нормы не вводит, он меняет отбор строк того же канала.
- Красная семья 175 подключена шагом `check:tablo-demo-175-family-selftest` (вес 4, коммит orchestrator b7537062 на OBJECT):
  `step	check:tablo-demo-175-family-selftest	4	bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo . && bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --stabs`.
  `--model` отдельно не вызывается, но `--stabs` начинает с прогона того же контроля и при его отказе выходит `CONTROL_INVALID` rc 2. Замер `check:tablo-demo-175-family-selftest 4 8 0`.
- ci.yml: множество ключей шардов до 144 и после 145. Разница ровно `+check:tablo-demo-175-family-selftest`. Чужие шаги не добавлены и не удалены, перераспределение по шардам механическое. `git merge-tree --write-tree origin/main b7537062` → rc 0.
- `bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md`: на дереве OBJECT 8533d157 → rc=0, на дереве проводки b7537062 → rc=0. Вывод пуст в обоих случаях: у 175 канал только `role=`, без guard-строки. Гейт перед done зелёный уже на OBJECT.
- Повтор команды шага CI на дереве b7537062: `lines 41 ok 15 caught 13 ZHIV 0`, `step rc=0`.

## 7. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| поле `title` в `gh pr list --json` | инв. 1 и 3: «query gh запрашивает `title` рядом с существующими полями» | нет | 1 | интерфейс CLI не вырос | клетки demo_title/do_not_merge/…; повтора нет | ESSENTIAL |
| предикат-отсечение с `continue` (4 строки) | инв. 1: три независимых признака на входе, оба репо | нет; решение видно только отсутствием строки, как требует контракт | 1 | интерфейс 0, работа — весь отбор | все 15 клеток и 13 стабов; в дереве второй реализации признаков нет (модель architect — оракул в fixtures, не код станции) | ESSENTIAL |
| комментарий над предикатом (3 строки) | документирование свойства по месту | нет | 1 (+README при смене признаков) | — | — | ESSENTIAL |
| пункт README (1 строка) | ПЕРЕСЕЧЕНИЕ 074/…/997: предложение о демонстрационных PR | нет | 1 | — | раздел «Табло потоков» | ESSENTIAL |
| шаг CI + строка замера (orchestrator) | Приёмка, строка 4: «CI-шаг исполнителя ведёт orchestrator» | нет | 3 (ci-steps, ci-zamery, ci.yml — прежняя норма 114, не выросла) | — | CI | ESSENTIAL |

Новых флагов, env, файлов состояния и каталогов нет.

## СВЕРКА-СТАНДАРТОВ

Не применимо. `git grep -n -e ARCHITECTURE.md -e CODING-STANDARDS 8533d157 -- AGENTS.md` → rc 1: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`. `git grep sourceCanon 8533d157 -- harness.project.json` → rc 1, поэтому норма 996/1 не применяется. Мобильного экрана нет.

## Итог

accept для OBJECT 8533d157a4e858721625cf6680ec2de4e2fd0a8f на frozen/contracts/175/1. Блоков нет.
- Зона: только `ops/server/user/orch-tablo` и одно предложение README.
- Приёмка: `--repo .` 15/15, `--model` 15/15, `--stabs` 13/13 caught (`ZHIV` 0), всё rc 0. На базе rc 1, 10 красных и 5 контролей. CI #706 зелёный, шаг исполнен.
- Своей мерой: граничные входы, оба репозитория, живой gh. Отсечены ровно демо-PR mob, красный CI рабочих PR не спрятан, mob-PR целиком не вырезаются. Живой итог −2 ровно на #149/#150.
- Мои мутанты: 7 из 9 красные, два выживших — пробел семьи (С-2) и законный вне контракта (M8).

С-1 — вопрос владельцу о `demo` внутри идентификаторов: это живой `dev-harness#706`, но не контрпример замороженной нормы. Он, С-2, Н-1 и Н-2 — в `.review/2026-11-10-99.md`.
