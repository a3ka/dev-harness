accept

СУД: repo=dev-harness; предмет=159; фаза=реализация (исправление фикстуры после красного l6); роль=reviewer; вызов=2 (scoped: только PATH-правка `kontrol_podmeny_path`, без полного повтора); сессия=Review159FixtureFix; модель-факт=anthropic/claude-opus-5-5; OBJECT=1cc2c088bea105d5b9cc2c91401d0e8fc9af4422 (родитель ab29eac3d = main); автор=architect (сессия Fix159FixturePath); контракт=frozen/contracts/159/2 (1a67dfb2), блоб контракта на OBJECT = на теге v2 (`git diff --quiet` → rc 0).

--sud: reviewer /tmp/dev-harness-verify/Review159FixtureFix/sud.tsv Review159FixtureFix; строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Review159FixtureFix	1cc2c088bea105d5b9cc2c91401d0e8fc9af4422`; `scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/Review159FixtureFix/sud.tsv --object 1cc2c088bea105d5b9cc2c91401d0e8fc9af4422 --session Review159FixtureFix --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, SUD_RC=0.

Независимость: автор — architect; судья — reviewer, другая сессия; в правке не участвовал.

## Кандидат и носитель

- Одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Review159FixtureFix/clone`; origin/main `7cb3823b5`. OBJECT в origin нет (`git cat-file -t 1cc2c088…` → fatal), взят fetch'ем `wip/159/architect` из основного репо → `1cc2c088bea105d5b9cc2c91401d0e8fc9af4422`; `checkout` ровно OBJECT, `git rev-parse HEAD` = OBJECT. База для красного — `ab29eac3d2803a3055529af9e002dc7b08ff7ecd` (родитель OBJECT, текущий main).
- CI-эквивалент: образ `review159-cisim:local` = `node:latest` (Debian 13, python3 3.13.5, git, bash) + `python3-yaml`; `/usr/bin/node`, `/bin/node` отсутствуют (`ls` → No such file or directory), node только в `/usr/local/bin/node` (раскладка образа раннера) — и отдельный прогон с раскладкой `actions/setup-node@v4` (`/opt/hostedtoolcache/node/26.13.0/x64/bin/node`, `/usr/local/bin/node` удалён). Процесс — uid 1004, не root. Без yaml (голый `node:latest`) батареи 147/149 падают на `import yaml` до гейта — тот прогон отброшен как не CI-эквивалентный.

## (1) Область правки

```text
$ git diff --name-status ab29eac3d 1cc2c088b
M	fixtures/workshop_project/pustoj_produkt_159/probe.py
$ git log --format='%H %an <%ae> | %s' ab29eac3d..1cc2c088b
1cc2c088bea105d5b9cc2c91401d0e8fc9af4422 architect <architect@dev-harness.local> | fix(159): relocate node for isolated PATH control
$ git diff --stat ab29eac3d 1cc2c088b -- . ':!fixtures/workshop_project/pustoj_produkt_159' | wc -l
0
```

ЗОНА architect контракта 159 v2: `contracts/159-pustoj-produkt-krasnyj.md fixtures/workshop_project/pustoj_produkt_159/` — путь внутри. Одна задача — один коммит с предметом. Нормативных путей нет; контракт не тронут. Механическая мера: `reslop t -- bash scripts/check_zones.sh .` на клоне ровно OBJECT → `passed: 98, failed: 0`, `exit: 0`, ZONES_RC=0 (463 с); строка 159: `ok contracts/159-pustoj-produkt-krasnyj.md — работа не раздаётся: …` (нарушений по 159 нет).

Содержание диффа (+18/−2, одна функция `kontrol_podmeny_path`): каталоги `standard-bin` (симлинки `python3`, `dirname`, `date` из `shutil.which`) и `node-bin` (симлинк `node`) внутри `TemporaryDirectory` shadow; `honest_path = node-bin:standard-bin`; честный контроль `{'PATH': honest_path}` вместо `'/usr/bin:/bin'`; атака `fakebin + os.pathsep + honest_path` вместо `fakebin + ':/usr/bin:/bin'` — fakebin остаётся первым. Отсутствие предпосылки → `RuntimeError`. Ни одной клетки, входа, оракула, стаба не удалено и не добавлено.

## (2) Сырой вывод — CI-эквивалент

Обёртки напрямую (своя мера, не через W): `env -i PATH=<p> /usr/bin/bash fixtures/workshop_project/<z>/red_<z>.sh --repo <пустой каталог>`:

```text
WRAP obj gespraech_vhod_147 PATH=/usr/bin:/bin rc=2 out=[NOT_IMPLEMENTED: нет node]
WRAP obj gespraech_vhod_147 PATH=/tmp/work/sim/nodebin:/tmp/work/sim/std rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
WRAP obj gespraech_tekst_149 PATH=/usr/bin:/bin rc=2 out=[NOT_IMPLEMENTED: нет node]
WRAP obj gespraech_tekst_149 PATH=/tmp/work/sim/nodebin:/tmp/work/sim/std rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
WRAP obj vkladki_tabov_148 PATH=/usr/bin:/bin rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
WRAP obj vkladki_tabov_148 PATH=/tmp/work/sim/nodebin:/tmp/work/sim/std rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
WRAP obj gespraech_otdacha_151 PATH=/usr/bin:/bin rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
WRAP obj gespraech_otdacha_151 PATH=/tmp/work/sim/nodebin:/tmp/work/sim/std rc=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
(база ab29eac3d — те же восемь строк побайтно: обёртки и probe.py 147–151 диффом не тронуты)
```

Под CI-PATH без node в стандартном пути 147/149 с прежним `/usr/bin:/bin` дают rc 2 `NOT_IMPLEMENTED: нет node`; с переселённым node (форма OBJECT) доходят до гейта — rc 1 `PUSTOJ_PRODUKT: KATALOG_PUST`.

W на OBJECT (образ, node в `/usr/local/bin`):

```text
== obj_bare rc=0 CASE=51 KRASNO=0 OK=51
CASE W-path-bash-gespraech_otdacha_151 ok
CASE W-path-bash-gespraech_tekst_149 ok
CASE W-path-bash-gespraech_vhod_147 ok
CASE W-path-bash-vkladki_tabov_148 ok
клеток 51, зелёных 51, красных 0; режим derevo
== obj_model rc=0 CASE=23 KRASNO=0 OK=23
клеток 23, зелёных 23, красных 0; режим model
== obj_stabs rc=0 CASE=23 KRASNO=0 OK=23
SVJAZI 18
клеток 23, зелёных 23, красных 0; режим stabs
```

Раскладка setup-node (node только в `/opt/hostedtoolcache/node/26.13.0/x64/bin`, PATH с ним первым, как у шага Lane):

```text
1004
/opt/hostedtoolcache/node/26.13.0/x64/bin/node
ls: cannot access '/usr/bin/node' / '/bin/node' / '/usr/local/bin/node': No such file or directory
1cc2c088bea105d5b9cc2c91401d0e8fc9af4422
TOOLCACHE_W_RC=0
CASE W-path-bash-{gespraech_otdacha_151,gespraech_tekst_149,gespraech_vhod_147,vkladki_tabov_148} ok
клеток 51, зелёных 51, красных 0; режим derevo
(строк `CASE … ok` — 51)
```

Станция (клон, `/usr/bin/node` есть): `reslop t -- bash …/red_pustoj_produkt_159.sh` → `exit: 0`, сырой лог `клеток 51, зелёных 51, красных 0; режим derevo`, STATION_W_RC=0.

Своя мера счёта: 51 = `grep -c '^CASE '` и поимённый перечень (1 s-gate-v-dereve + 21 s-gate-raven-etalonu + 1 s-gate-pishet-trassu + 24 W-<4>/<6> + 4 W-path-bash); 23 = 21 `m-*` + 2 `m-provodka-*`; SVJAZI 18 = `git ls-tree` OBJECT `stabs/s*.py` → 18 = контракт v2 п. 3 и census `= 18`; строк `ZHIV` в `--stabs` 0; поимки s1–s18 каждой своей ветвью (s17 PATH_PODMENIL_GATE, s18 KLETKI_POSLE_OTKAZA на a-forma-pusta и d1-karta-nechitaema).

## (3) Красное предъявлено (база, тот же CI-эквивалент)

```text
== base_bare rc=1 CASE=51 KRASNO=2 OK=49
CASE W-path-bash-gespraech_otdacha_151 ok
CASE W-path-bash-gespraech_tekst_149 KRASNO KONTROL_NEVALIDEN SUBEKT_RC2 rc=2 (fail-closed — не зелень)
CASE W-path-bash-gespraech_vhod_147 KRASNO KONTROL_NEVALIDEN SUBEKT_RC2 rc=2 (fail-closed — не зелень)
CASE W-path-bash-vkladki_tabov_148 ok
клеток 51, зелёных 49, красных 2; режим derevo
```

Совпадает с отказом l6 run 42501822014 / job 128796064542 (две строки `KONTROL_NEVALIDEN SUBEKT_RC2` по 147/149, `49/51`, rc 1 — из вывода Assess159CiRouting). Правка снимает именно эту красноту, иных клеток не меняет. Проверка (W) не подогнана под реализацию: реализация implementer диффом не тронута; изменена только среда честного контроля фикстуры, атакующая половина судит то же.

## (4) Атакующая мутация изолирована и жива — своя мера

Изоляция (OBJECT, после bare/model/stabs):

```text
GATE_SHA_BEFORE=d1f0d2870712137dd3d824eacbc7789463fbf41b5b81fd13cfa20bdfeed14b07  scripts/check_pustoj_produkt.sh
GATE_SHA_AFTER=d1f0d2870712137dd3d824eacbc7789463fbf41b5b81fd13cfa20bdfeed14b07  scripts/check_pustoj_produkt.sh
OBJ_STATUS=[]
SHADOW_LEFT=[]          (ls -d /tmp/dev-harness-verify/pustoj159-* — пусто)
```

Сломанный гейт (`exit 99`), fakebin, node-bin, standard-bin — только внутри shadow `TemporaryDirectory`; живой гейт и дерево не тронуты, shadow удалён.

Сила атаки — две мутации `--repo`-ветви 147 (одна строка `subprocess.run([DOVERENNYY_BASH, GEJT_PUSTOGO_PRODUKTA, repo_r])`), безфлаговый W в CI-эквиваленте:

```text
M2 = [__import__('shutil').which('bash') or DOVERENNYY_BASH, …]   (PATH-bash с фолбэком)
== m2obj_bare  rc=1 CASE=51 KRASNO=1 OK=50
CASE W-path-bash-gespraech_vhod_147 KRASNO PATH_PODMENIL_GATE PATH_PODMENIL_GATE fake bash вызвал эталон вместо гейта
== m2base_bare rc=1 CASE=51 KRASNO=2 OK=49   (147/149 KONTROL_NEVALIDEN SUBEKT_RC2 — до атаки не доходит)

M1 = ['bash', …]   (голый PATH-bash)
== m1obj_bare  rc=1 CASE=51 KRASNO=7 OK=44
CASE W-gespraech_vhod_147/<6 входов> KRASNO KLETKI_POSLE_OTKAZA … PRE_GATE_SPAWN:subprocess.Popen
CASE W-path-bash-gespraech_vhod_147 KRASNO KONTROL_NEVALIDEN GATE_NE_VYZVAN записей трассы 0 (ожидалась одна с этим R)
== m1base_bare rc=1 CASE=51 KRASNO=8 OK=43
```

Вывод: под CI-PATH атакующая половина на OBJECT достижима и ловит PATH-подмену (M2 → PATH_PODMENIL_GATE, маркер fake bash); на базе в той же среде честный контроль 147/149 падает раньше и атака не судится вовсе. fakebin первым в атаке сохранён. Голый PATH-bash (M1) красен, но клетка W-path-bash называет его `KONTROL_NEVALIDEN` — совет Р159-С6.

## (5) Паразитная сложность (контракт 050)

- `standard-bin` + `node-bin` + `honest_path` в `kontrol_podmeny_path`: (1) контракт 159 v2 п. 4 — W rc 0, 51 клетка на дереве после реализации там, где он гоняется (CI l6, node вне `/usr/bin:/bin`); (2) состояние — два временных каталога симлинков внутри shadow `TemporaryDirectory`, создаются и удаляются в пределах прогона, видны в коде, не в аргументах; (3) при следующей правке состава честного PATH меняется одна функция одного файла — число совместно меняемых файлов не выросло; (4) интерфейс W не вырос: новых флагов, env, кодов возврата нет; (5) потребитель — клетки `W-path-bash-*` безфлагового W (CI-ключ `check:pustoj-produkt-159-family-selftest`); грамматики дерева не повторяет. Более простая форма `'/usr/bin:/bin' + os.pathsep + dirname(shutil.which('node'))` тоже прошла бы п. 4; герметичный `standard-bin` сверх неё даёт станции ту же раскладку, что у CI (дефект l6 ушёл, потому что у станции `/usr/bin/node`), ценой убранного из честного PATH bash (см. Р159-С6). По норме — ACCIDENTAL в части `standard-bin`; блоком не является (отсутствующего свойства нет) — совет Р159-С7.
- `RuntimeError('missing fixture prerequisite: …')`: (1) fail-closed при отсутствии python3/dirname/date/node; (2)–(4) состояния и интерфейса не вводит; (5) потребителя нет. Своя мера: OBJECT, `PATH=/usr/bin:/bin` в образе без node → `NO_NODE_W_RC=1`, `CASE`-строк 0, последняя строка `RuntimeError: missing fixture prerequisite: node`. Не зелень, но rc 1 с трассировкой вместо объявленного шапкой W `2 — … нечем проверять` — совет Р159-С8.

## (6) ПРОВОДКА, стандарты, режим

- ПРОВОДКА: guard `red_pustoj_produkt_159.sh` — барьер именно этого предмета; подключение — ключ `check:pustoj-produkt-159-family-selftest` в Lane l6 (PR #609, зона orchestrator), диффом не тронуто. Поведенческой нормы правка не вводит.
- СВЕРКА-СТАНДАРТОВ: AGENTS.md харнесса документов архитектуры/стандарта кода не объявляет — сверять не с чем, строка неприменима.
- Режим проекта: sourceCanon не объявлен — сверка карты неприменима.
- Реального прогона GitHub не было (без push по заданию); CI-исход OBJECT — `[INFERENCE]` из двух CI-эквивалентных раскладок выше.

## Итог

accept OBJECT 1cc2c088bea105d5b9cc2c91401d0e8fc9af4422: дифф — одна функция фикстуры в зоне architect; под CI-PATH без node в стандартном пути 147/149 доходят до гейта rc 1 (не `NOT_IMPLEMENTED` rc 2); W 51/51 rc 0, `--model` 23/23 rc 0, `--stabs` 23/23 SVJAZI 18 rc 0 в обеих раскладках раннера, W 51/51 и на станции; база в той же среде красна ровно отказом l6 (49/51); атакующая мутация изолирована и ловит PATH-подмену. Блоков нет; советы С6–С8 — architect, не блокируют.

## Находки

```markdown
---
status: ready
subject: 159 pustoj-produkt-krasnyj — scoped суд PATH-правки фикстуры (reviewer, вызов 2)
object: 1cc2c088bea105d5b9cc2c91401d0e8fc9af4422
contract: frozen/contracts/159/2 (1a67dfb285494b9748ae548dfa1fcf9de816f9ee)
verdict: verdicts/review/contracts-159-impl-v2.md (accept)
reviewer: reviewer (сессия Review159FixtureFix; anthropic/claude-opus-5-5)
---

# Review 159 — PATH честного контроля W-path-bash на 1cc2c088

Блоков нет. Советы — architect, не блокируют.

## Блокеры

(нет)

## Советы

- [ ] **Р159-С6 (architect, диагностика W-path-bash).** Честный PATH (`node-bin:standard-bin`)
  не содержит bash, поэтому мутант `--repo`-ветви, зовущий гейт голым `'bash'` через PATH,
  красит `W-path-bash-147` как `KONTROL_NEVALIDEN GATE_NE_VYZVAN` (контроль невалиден),
  а не `PATH_PODMENIL_GATE` (дефект субъекта). Клетка красна — свойство держится; метка
  причины вводит в заблуждение. Замер: M1 на OBJECT `клеток 51, зелёных 44, красных 7`.
- [ ] **Р159-С7 (architect, 050).** Часть `standard-bin` (герметичные `python3`/`dirname`/`date`)
  сверх приёмки: форма `'/usr/bin:/bin' + os.pathsep + dirname(shutil.which('node'))` проходит
  те же строки п. 4. Оставить можно (даёт станции раскладку CI); если оставляется —
  обоснование «паритет станции с CI» стоит записать в комментарии функции рядом с Р159-С6.
- [ ] **Р159-С8 (architect, rc-домен W).** Нет node/python3/dirname/date в PATH →
  `RuntimeError` с трассировкой, rc 1, ни одной `CASE`-строки; шапка W объявляет
  `2 — … нечем проверять` (прецедент той же обёртки: `NOT_IMPLEMENTED: нет python3` → rc 2).
  Замер: `PATH=/usr/bin:/bin` без node → `NO_NODE_W_RC=1`. Fail-closed, не зелень.
```
