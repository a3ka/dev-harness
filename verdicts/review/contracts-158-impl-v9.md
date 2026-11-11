accept
OBJECT=b30d1539adacfe0a04aae82d779c5ad98617a338
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный — подтверждён, повышать не из чего; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness; предмет=158; фаза=реализация (scoped-правка: `--model` rc 0 без станционных референсов; d01 разделена на самодостаточную часть карты и сверку с экраном референса; Impl158Ci, один коммит поверх main 11451c183; шаг CI — PR wip/158/orchestrator 7e6df04d); роль=reviewer; вызов=10 (scoped; предмет заведён до 2026-10-24 — прежний порядок, предел вызовов не применяется); модель-план=anthropic/claude-opus-5-5; сессия=Rev158v10; модель-факт=anthropic/claude-opus-5-5; SHA=b30d1539adacfe0a04aae82d779c5ad98617a338 (tip wip/158/implementer); предыдущий=verdicts/review/contracts-158-impl-v8.md; исключение=нет
НЕЗАВИСИМОСТЬ: автор OBJECT — implementer (`implementer <implementer@dev-harness.local>`, сессия Impl158Ci, minimax/MiniMax-M3). Судья — reviewer, кода не правил. Прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/Rev158v10/repo`: worktree `obj` на OBJECT, `base` на 11451c183, `orch` на 7e6df04d, `verdict` на origin/main 6258d3b50. Эмуляция чистого раннера — полные копии деревьев в `/tmp/dev-harness-verify/Rev158v10/clean/`. Станционные каталоги Arch147t и Arch148t только читались: из них скопирован файл `mobile/src/bootstrap/tab-shell.tsx`.
НАХОДКИ: в тексте вердикта, потому что каталог `.review/` вне зоны reviewer по ЗОНА 158. Блоков нет. Совет С-20 (implementer/architect). Наблюдение О-3 (architect/владелец), без действия.

## Вердикт

accept. Дефект PR #772 (run 42942737067) закрыт. В эмуляции чистого раннера, где пути
референсов несуществующие, `W --model` даёт rc 1 на базе (d01: `LIVE_PREDPOSYLKA`, 36/37) и
rc 0 на OBJECT (37/37). Самодостаточная часть карты судится без референсов во всех трёх
режимах эталона. Мутанты карты краснеют `KARTA_NE_POLNA`: профиль 393, состояния, привязка,
вход ⊄ цели. Сверка с экраном на станции не потеряна: мутант `tab-shell.tsx` краснеет
в безфлаговом `W` (полный прогон, d01 KRASNO, rc 1) и в клетке d01 режима `repo`. В `--repo`
без референса по-прежнему rc 2 `LIVE_PREDPOSYLKA`. На станции регрессов нет:
безфлаговый `W` даёт 40/40 rc 0 и ДО, и ПОСЛЕ, `--stabs` — 37/37, SVJAZI 30, rc 0. Дифф —
один файл в ЗОНЕ implementer. Контракт, SPEC, дверь и `source.json` не тронуты. PR оркестратора
даёт `gen_ci_steps --check` rc 0 и `check_provodka` rc 0.

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`
и `docs/CODING-STANDARDS.md` (grep пуст), а дифф лежит в `fixtures/` харнесса.

ПРОВОДКА (038): guard `fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh` —
дверь этого предмета, побайтово равная `frozen/contracts/158/4`. На дереве PR
`wip/158/orchestrator` её вызывает шаг `check:ekrannyj-nabor-158-family-selftest` (`--model`,
вес 400). `check_provodka` даёт rc 1 на базе и на OBJECT («guard не подключён»), это ожидаемо,
и rc 0 на дереве PR. `--wiring` у двери 158 нет: этот флаг есть только у батареи 187 (grep
`--wiring` по дереву PR), а argparse 158 отвергает незаявленный флаг. Подключение
проверено двумя независимыми мерами: строка в `registry/ci-steps.tsv` и
`gen_ci_steps --check` по сгенерированному `ci.yml`.

## Пункты задания — сырой вывод

W = `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`.

```text
$ git rev-parse origin/wip/158/implementer origin/wip/158/orchestrator origin/main
b30d1539adacfe0a04aae82d779c5ad98617a338
7e6df04d1f87fa47b1c3653e135e1ee11922a8f4
6258d3b50203af69cc1630f67d2a46c970af6055
$ git log --oneline -3 origin/wip/158/implementer
b30d1539 158: d01 — режим --model без станционных референсов (CI-раннер)
11451c18 HANDOFF: 08:40 — 187а реализация влита …
$ git log -1 --format='%an %ae' b30d1539 → implementer implementer@dev-harness.local
$ git ls-tree origin/main verdicts/review/ | grep 158 → impl-v1, v2, v3, v4, v7, v8 (impl-v9 нет)
$ HANDOFF.md origin/main строка 2: СУД … предмет=158 … роль=reviewer; вызов=10 … SHA=b30d1539… предыдущий=…impl-v8.md
```

### (1) Область

```text
$ git diff --stat 11451c183 b30d1539
 .../workshop_project/ekrannyj_nabor_158/probe.py   | 90 ++++++++++++++++------
 1 file changed, 66 insertions(+), 24 deletions(-)
$ git diff --stat origin/main...b30d1539   → тот же один файл
$ git diff --quiet 'frozen/contracts/158/4^{commit}' b30d1539 -- contracts/158-ekrannyj-nabor.md …/SPEC.md …/red_ekrannyj_nabor_158.sh → frozen_vs_obj_rc=0
$ git diff --quiet 11451c183 b30d1539 -- …/source.json → rc=0   (ожидания клеток не менялись)
$ git diff 11451c183 6258d3b50 --name-only -- fixtures/workshop_project/ekrannyj_nabor_158 | wc -l → 0
$ git merge-tree --write-tree origin/main b30d1539 → rc=0 (без конфликтов)
ЗОНА implementer (contracts/158:81): fixtures/workshop_project/ekrannyj_nabor_158/ … → probe.py в зоне
PR оркестратора:
$ git diff --stat ebae4b19 7e6df04d → ci.yml 12, probe.py 90, ci-steps.tsv +1, ci-zamery.tsv +1
$ git range-diff 11451c183..b30d1539 ebae4b19..8d15b2f1 → патч равен, разница только «(cherry picked from commit b30d1539…)»
$ git show --stat 7e6df04d → orchestrator <orchestrator@dev-harness.local>: ci.yml, registry/ci-steps.tsv, registry/ci-zamery.tsv (ЗОНА orchestrator, contracts/158:85)
+step	check:ekrannyj-nabor-158-family-selftest	400	bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
$ git diff --stat ebae4b19 origin/main -- registry/ci-steps.tsv registry/ci-zamery.tsv .github scripts/gen_ci_steps.sh → (пусто)
$ git merge-tree --write-tree origin/main 7e6df04d → rc=0
```

Коммит атомарен: одна задача, один коммит со ссылкой «158:». Норма не тронута.

### (2) Эмуляция чистого раннера — красное ДО, зелёное ПОСЛЕ

Обе копии — полные деревья: `cp -a` worktree `base` (11451c183) и `obj` (OBJECT) в
`clean/base` и `clean/after`. В `probe.py` каждой копии два пути `REFERENSI` заменены
на `/nonexistent-runner/Arch147t/ref-clean` и `/nonexistent-runner/Arch148t/mob-ref`
(`after replaced 2`, `base replaced 2`; `ls /nonexistent-runner` → No such file or directory).
Больше ничего не менялось: `diff` копии против `obj` даёт ровно строки 124 и 126.

```text
$ (cd clean/base && W --model)
… CASE d01-karty-polny KRASNO: ожидался rc=0, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: референс ref-clean отсутствует на станции)
клеток 37, зелёных 36, красных 1
RC_BASE_MODEL=1        (wall 440 s)
$ (cd clean/after && W --model)
… CASE d01-karty-polny ok … g01…g07 ok
клеток 37, зелёных 37, красных 0
RC_AFTER_MODEL=0       (wall 439 s)
```

Мутанты карты без референсов, на копиях `clean/after`. Полный прогон `--model`:

```text
$ (cd clean/mut-profil && W --model)    # karta-ref-clean.json: profili ['390']
CASE d01-karty-polny KRASNO: ожидался rc=0, факт rc=1 (причины факта: KARTA_NE_POLNA: в карте model/karta-ref-clean.json профили ['390'] (канон 390+393))
клеток 37, зелёных 36, красных 1
RC_MUT_PROFIL_MODEL=1
```

Клетка d01 на остальных мутантах — прямой вызов `probe.k_d01(ctx)` кода копии (`d01karta.py`):

```text
mut-sost      (karta-mob-ref: sostojanija [])        model/stabs/bare rc=1 KARTA_NE_POLNA: в карте model/karta-mob-ref.json нет состояний;            repo rc=2 LIVE_PREDPOSYLKA
mut-privjazka (ref-clean: shell-tab-post sostojanija []) model/stabs/bare rc=1 KARTA_NE_POLNA: цель shell-tab-post не привязана к состоянию;          repo rc=2 LIVE_PREDPOSYLKA
mut-vhod      (ref-clean: menu.vhod net-takoj-tseli)  model/stabs/bare rc=1 KARTA_NE_POLNA: вход состояния net-takoj-tseli не в карте целей …;       repo rc=2 LIVE_PREDPOSYLKA
after (контроль, карта цела)                          model/stabs/bare rc=0;                                                                                repo rc=2 LIVE_PREDPOSYLKA
```

### (3) Сверка с экраном референса на станции не потеряна, и правка под реализацию не подогнана

Экраны-мутанты лежат вне станции. В `refmut/{ref-clean,mob-ref}/mobile/src/bootstrap/tab-shell.tsx`
скопированы файлы со станции. В копии ref-clean у `<Pressable testID="gespraech-vorgaenge-ansehen"`
снят testID, а цель `gespraech-vorgaenge-ansehen` из карты в экране отсутствует. `refctl` —
нетронутые копии тех же файлов.

Полный безфлаговый `W` на копии OBJECT, у которой `REFERENSI` смотрят на `refmut` (`clean/scr-after`):

```text
… CASE z01-gate-v-dereve ok  CASE z02-noga-pre-critic ok …
CASE d01-karty-polny KRASNO: ожидался rc=0, факт rc=1 (причины факта: KARTA_NE_POLNA: цель gespraech-vorgaenge-ansehen карты model/karta-ref-clean.json не найдена в экране ref-clean)
… g01…g08 ok
клеток 40, зелёных 39, красных 1
RC_SCR_MUTANT_BARE=1
```

Матрица клетки d01: дерево × набор референсов × режим, `d01matrix.py`, прямой вызов `k_d01`:

```text
base   ref-kontrol  model/stabs/bare/repo  rc=0
base   ref-mutant   model/stabs/bare/repo  rc=1 KARTA_NE_POLNA: цель gespraech-vorgaenge-ansehen … не найдена в экране ref-clean
base   ref-net      model/stabs/bare/repo  rc=2 LIVE_PREDPOSYLKA: референс ref-clean отсутствует на станции
obj    ref-kontrol  model/stabs/bare/repo  rc=0
obj    ref-mutant   model rc=0   stabs rc=0   bare rc=1 KARTA_NE_POLNA …   repo rc=1 KARTA_NE_POLNA …
obj    ref-net      model rc=0   stabs rc=0   bare rc=0                    repo rc=2 LIVE_PREDPOSYLKA: референс ref-clean отсутствует на станции
```

Как читать матрицу:
- В `repo` поведение d01 равно базе во всех трёх наборах: экран сверяется, а отсутствие
  референса даёт rc 2. Fail-closed сохранён, skip→pass нет.
- В `bare` со станционными референсами экран сверяется так же, как в базе. Без референсов
  d01 судит только карту. Так требует п.7 контракта: безфлаговый `W` — CI-гейт
  самодостаточного дерева, а краснота из-за непереданного R «не доказывает дефекта
  продукта». Подробнее — С-20.
- В `model` и `stabs` сверки с экраном больше нет даже на станции. Это осознанное и
  объявленное в коммите изменение (ref-mutant: база rc 1, OBJECT rc 0). Подробнее — О-3.
- Стабы d01 не теряют: `stab_vhod` в `source.json` d01 не содержит (вторая мера ниже).
  Ожидание клетки (`kejsy.d01-karty-polny.rc=0`) не менялось.

### (4) Регресс на станции (референсы Arch147t/Arch148t на месте)

Прогоны шли последовательно, с `timeout 1500`. `--stabs` гонялся один раз.

```text
$ (cd obj && W)          → a01…a14, z01, z02, b01…b07, c01…c04, d01…d03, e01, e02, g01…g08 ok; клеток 40, зелёных 40, красных 0; RC_OBJ_BARE_STATION=0
$ (cd base && W)         → те же 40 ok; клеток 40, зелёных 40, красных 0; RC_BASE_BARE_STATION=0
$ (cd obj && W --stabs)  → контроль: клеток 37, зелёных 37, красных 0
  STAB st01…st14 KRASEN (14 из 14; PROSHYOL только на отдельных входах: st03 b07, st06 e01 — стаб пойман другим своим входом)
  SVJAZI 30
  RC_OBJ_STABS_STATION=0  (wall всей тройки 1245 s)
вторая мера (source.json, не вывод батареи): stabov 14 svjazej 30 d01_v_stab_vhod False; kejsy 80
$ bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md
  base: «проводка: guard не подключён: …/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/» RC_PROV_base=1
  obj:  то же                                                                                                   RC_PROV_obj=1
  orch (7e6df04d): RC_PROV_orch=0
$ (cd orch && bash scripts/gen_ci_steps.sh --check) → RC_GEN_orch=0
```

Сверка заявленного своей мерой (B2d). Implementer заявил: ДО `--model` на чистом раннере
rc 1 36/37, ПОСЛЕ rc 0 37/37; мутант 393 → rc 1 d01 `KARTA_NE_POLNA`; на станции
`--stabs` 37/37 SVJAZI 30, `W` 40/40 rc 0. Все пять утверждений воспроизведены моими
прогонами выше. Счёт 14/30 подтверждён ещё и второй мерой — разбором `source.json`.
Станционный `--model` на OBJECT я не гонял. На OBJECT d01 в режиме `model` референсов не
читает (`obj ref-kontrol/ref-net model rc=0` в матрице), так что станционный прогон отличается
от чистого только этим неиспользуемым путём. Чистый прогон 37/37 его покрывает.

## Находки

- [ ] **С-20 (совет, implementer; при правке SPEC — architect).** В безфлаговом `W` без
  станционных референсов d01 молча судит только карту: `probe.py` k_d01, ветвь
  `if rezhim not in REZHIMY_S_ZHIVYM_EKRANOM or not est_referens: continue`. Итог
  `CASE d01-karty-polny ok` на раннере неотличим от станционного, где экран сверялся.
  Правку разрешает п.7 контракта, поэтому это не блок. Простая форма: маркер в `mark`
  исхода, например «сверка с экраном ref-clean не строилась: референса нет». Она проходит
  те же строки приёмки. Вывод тогда скажет читателю, что именно судилось.
- **О-3 (наблюдение, architect/владелец; без действия по OBJECT).** На станции `--model` и
  `--stabs` больше не ловят дрейф экрана референса относительно карты: в матрице ref-mutant
  база даёт rc 1, OBJECT — rc 0. Дрейф по-прежнему ловят `W` и `--repo` (п.3). Это
  соответствует SPEC §1 («клетки с ВНЕШНИМ субъектом (живые референсы…) в этом режиме не
  строятся») и п.2 контракта («`W --model` → rc 0 (эталоны: … карты …)»). Наоборот, база
  в `--model` читала живой референс вопреки SPEC §1. Отметка нужна, чтобы никто не принимал
  зелёный CI-шаг `--model` за сверку экранов: CI её не делает по замыслу п.7.

Прежние советы (С-13, С-17 — implementer; С-18, С-19 — architect) вне дельты этого вызова.
Их статус — как в `contracts-158-impl-v8.md`.

## Паразитная сложность (контракт 050) — дельта 11451c183 → OBJECT

- `karta_samodostatochnaya(karta, kartaf)` — новая функция, вынесенная из k_d01.
  (1) Свойство: п.2 контракта, `W --model` → rc 0 с судом карт без живого продукта.
  Самодостаточную часть нужно звать отдельно от сверки с экраном. (2) Состояния нет:
  на входе карта, на выходе (цели, причина). (3) Файлов, меняющихся вместе: 1, как и было.
  Код перенесён, а не продублирован: из k_d01 удалено ровно то, что вынесено. (4) Интерфейс
  из двух аргументов скрывает пять проверок — модуль глубокий. (5) Потребители: d01 во всех
  режимах и CI-шаг `--model`. Чужой грамматики не повторяет. **ESSENTIAL.**
- `REZHIMY_S_ZHIVYM_EKRANOM = ('repo', 'bare')` — константа ветви барьера.
  (1) Свойство: SPEC §1 и п.2/п.7 — в каких режимах субъект живой. (2) Состояние явное,
  значение режима берётся из `ctx['rezhim']`. (3) 1 файл. (4) Одно имя у одной проверки.
  (5) Потребитель — k_d01; `stroit_cell` решает другой вопрос (строить ли клетку), так что
  это не дубль. **ESSENTIAL.** Инлайн в условие был бы равносилен, совет не нужен.
- Ветвь k_d01 «`rezhim == 'repo'` и референса нет → rc 2» сохранена из базы, а не добавлена.
  В остальных режимах отсутствие референса — пропуск сверки с экраном (С-20).
  Новых env-переменных, флагов и файлов состояния нет.

## Ограничения этого вызова

- `--repo` на мутанте экрана полным прогоном не гонялся: живому зонду нужен целый референс
  с `node_modules`, а копировать или мутировать станционный клон запрещено. d01 в режиме
  `repo` проверена прямым вызовом клетки на тех же байтах `probe.py` (матрица п.3).
- Полный `check_zones.sh` не запускался, как требует задание. Зона проверена по списку путей (п.1).
- CI на дереве PR `wip/158/orchestrator` после этой правки я не наблюдал. Ожидание
  «шаг `--model` зелёный на раннере без клонов» основано на эмуляции п.2, а не на прогоне CI
  [INFERENCE для самого раннера GitHub].
