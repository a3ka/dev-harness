FAIL

СУД: repo=dev-harness; предмет=159; фаза=реализация; роль=reviewer; вызов=1 (полный); OBJECT=2a7fc735bcd04dbb025ed88a7cc14343f74fef8a; сессия=Reviewer159Opus; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; автор=implementer (гейт и проводка), architect (усиление W после adversary v1); предыдущий суд реализации: verdicts/adversary/contracts-159-impl-v1.md (FAIL) → verdicts/adversary/contracts-159-impl-v2.md (accept, ac048c2d9); контракт=frozen/contracts/159/1 (тег 91e3eff2, коммит ff320331), блоб контракта 9c1f33bf на теге = на OBJECT = на носителе (не тронут).
Независимость: реализация — implementer, W — architect, адверсарий — openai-codex/gpt-5.6-terra; судья — Anthropic Opus, другое семейство.

Пин: `cd /tmp/dev-harness-worktrees/c907157c/wip-159-reviewer; pwd; git rev-parse --show-toplevel` → `/tmp/dev-harness-worktrees/c907157c/wip-159-reviewer` / `/tmp/dev-harness-worktrees/c907157c/wip-159-reviewer` (HEAD 65fa3044b, ветка wip/159/reviewer).

## Кандидат и носитель

- Одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Reviewer159Opus/clone`, ветка `wip/159/implementer-r2`, HEAD `9dcb8d6f958a69277a35324cd76647932793dd6f` (ребейз 2a7fc735 на main 65fa3044).
- OBJECT в origin отсутствует (`git cat-file -t 2a7fc735…` в клоне → fatal); взят из локальной ветки `wip/159/implementer` (через fetch из выданного WORKTREE) → `2a7fc735bcd04dbb025ed88a7cc14343f74fef8a`. Отдельный worktree `obj` в клоне — ровно OBJECT.
- `git diff 2a7fc735b HEAD -- scripts/check_pustoj_produkt.sh fixtures/workshop_project/pustoj_produkt_159/ <четыре probe.py>` → пусто (stat пуст, 0 байт, rc 0). Носитель предметно равен OBJECT.
- Вердикт adversary v2 на носителе ещё НЕТ (`ls verdicts/adversary/ | grep 159` → только `contracts-159-impl-v1.md`); он лежит в локальном `wip/159/adversary` (ac048c2d9). Это порядок ленда, не дефект OBJECT.

## (1) Область правки

`git log --format='%h %an <%ae>' --name-only 'frozen/contracts/159/1^{commit}'..2a7fc735b`:

| коммит | автор | пути | зона |
|---|---|---|---|
| a6da1780 | orchestrator | registry/contracts.tsv (строка 159 → 91e3eff2) | freeze, оркестратор |
| 5915d1d0 | implementer | scripts/check_pustoj_produkt.sh + 4 probe.py | implementer |
| d430c0f4 | implementer | scripts/check_pustoj_produkt.sh (шапка) | implementer |
| b4cd0e3b | architect | pustoj_produkt_159/{model/sitecustomize.py, probe.py, red_*.sh, source.json, stabs/path_fake_bash.py, stabs/s16_*, stabs/s17_*} | architect |
| 2aef5455 | architect | pustoj_produkt_159/{probe.py, source.json, stabs/s16_*} | architect |
| 2a7fc735 | implementer | 4 probe.py | implementer (ПЕРЕСЕЧЕНИЕ) |

Механическая мера другой командой: `bash scripts/check_zones.sh .` на ровно OBJECT (worktree `obj`) → `ZONES_RC=0`; строк с «159» в выводе одна — `ok contracts/159-pustoj-produkt-krasnyj.md — работа не раздаётся: …` (нарушений по 159 нет).

Носитель (`origin/main..HEAD`): те же пути + `verdicts/adversary/contracts-159-impl-v1.md` (adversary, своя зона). Чужих путей нет.

ПЕРЕСЕЧЕНИЕ в probe.py: `git diff --stat freeze^{commit} OBJECT -- <4 probe.py>` → `82 insertions(+), 0 deletions(-)`. Ни одной удалённой строки — собственные клетки, стабы и режимы не тронуты. Добавлено ровно: константы `GEJT_PUSTOGO_PRODUKTA`, `DOVERENNYY_BASH`, у 148 — `import os`; в `--repo`-ветви — проверка доверенного интерпретатора (rc 2 NOT_IMPLEMENTED), `subprocess.run([DOVERENNYY_BASH, гейт, R]).returncode`, `if rc_gejta != 0: return rc_gejta`.
Первость по коду: 147 и 149 — первое действие внутри `elif '--repo' in argv:` после чтения `repo_r` (до `vedro()` и любых клеток); 148 — сразу после `ap.parse_args()`, до `load_source()`; 151 — после `parser.error`-проверки комбинации флагов, до вычисления `runtime` (контракт: «вызов до проверки runtime»). Модульный уровень четырёх probe.py нитей/процессов не порождает (grep модульных `threading|Thread(|Popen|posix_spawn|os.fork|subprocess.*` → 0 совпадений во всех четырёх).

Атомарность: три implementer-коммита по одной задаче со ссылкой на 159; architect-коммиты — `test(159): …`, тоже по одной задаче.
Норма не тронута: `contracts/159-…` после freeze не менялся (блоб 9c1f33bf), иных нормативных путей в диапазоне нет.

## (2) Сырой вывод своих прогонов

W на носителе (`clone`, HEAD 9dcb8d6f):

```text
$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
CASE s-gate-v-dereve ok
CASE s-gate-raven-etalonu/<21 вход> ok      (a, b1, b2, c1–c5, d1–d3, f1, g, k1–k6, konformnyj, v)
CASE s-gate-pishet-trassu ok
CASE W-<4 батареи>/<a, b1, b2, v, g, d1> ok (24)
CASE W-path-bash-<4 батареи> ok (4)
клеток 51, зелёных 51, красных 0; режим derevo
W_BARE_RC=0
$ … --model
клеток 23, зелёных 23, красных 0; режим model
W_MODEL_RC=0
$ … --stabs
STAB s1…s17 POJMAN vetka=… (каждый на своих входах, своей ветвью; s16 KLETKI_POSLE_OTKAZA, s17 PATH_PODMENIL_GATE на a-forma-pusta и d1-karta-nechitaema)
SVJAZI 17
клеток 23, зелёных 23, красных 0; режим stabs
W_STABS_RC=0
```

Своя мера счёта: 1 + 21 + 1 + 24 + 4 = 51 (имена клеток пересчитаны поимённо по выводу); `ls stabs/s*.py` = 17 файлов (s1…s17) = `SVJAZI 17`; строк `ZHIV` в `--stabs` нет (живых 0).
Второй замер на ровно OBJECT (worktree `obj`): `клеток 51, зелёных 51, красных 0`, `CASE`-строк 51, `KRASNO`-строк 0, `OBJ_W_BARE_RC=0`.

Регрессии на ровно OBJECT (`obj`):

```text
W147 --model  клеток 76, зелёных 76, красных 0   rc 0
W147 --stabs  SVJAZI 18; клеток 76, зелёных 76   rc 0
W148 --model  клеток 57, зелёных 57, красных 0   rc 0
W148 --stabs  SVJAZI 47                          rc 0
W149 --model  клеток 96, зелёных 96, красных 0   rc 0
W149 --stabs  SVJAZI 19; клеток 96, зелёных 96   rc 0
W151 --model  INFRASTRUCTURE: --runtime R or --repo R with installed mobile/node_modules is required   rc 2
W151 --stabs  INFRASTRUCTURE: … (то же)                                                                rc 2
база ff320331: W151 --model → та же строка INFRASTRUCTURE, rc 2
```

151 rc 2 INFRASTRUCTURE — прежний исход (на базе до реализации тот же), контракт §Приёмка п. 5: «батарея 151 не самодостаточна (даже `--model` требует установленный mobile/node_modules — INFRASTRUCTURE rc 2 на станции без продукта)». Допустимо. Базлайн контракта 76/57/96 совпал.

Четыре probe.py `--repo` на пустом существующем каталоге:

```text
PROBE gespraech_vhod_147    rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE gespraech_tekst_149   rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE vkladki_tabov_148     rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE gespraech_otdacha_151 rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
```

Живые исходы п. 5 (одноразовые `git clone` продукта `/home/harness/projects/Complior-mob` @934917b: `Rb` для базы ff320331, `Ro` для OBJECT; без node_modules):

```text
гейт на живом продукте: bash scripts/check_pustoj_produkt.sh /home/harness/projects/Complior-mob → GATE_LIVE_RC=0 (stdout пуст)
                      база ff320331                         OBJECT
W148 --repo R         клеток 37, зелёных 36, красных 1, rc 1 | клеток 37, зелёных 36, красных 1, rc 1 (pr-chestnaja PACHKA_ABSENT — тот же)
W149 --repo R         клеток 96, зелёных 75, красных 21, rc 1 | клеток 96, зелёных 75, красных 21, rc 1
W151 --repo R         INFRASTRUCTURE …, rc 2                | INFRASTRUCTURE …, rc 2
W147 --a-derevo R C   A-DEREVO … kanon=11 mashina=1 ekran.json=forma raskladka=2 node_modules=net, rc 0 | то же, rc 0
W147 --repo C(A)     клеток 76, зелёных 75, красных 1, rc 1 | клеток 76, зелёных 75, красных 1, rc 1
                      (единственная красная обеих сторон: s-ekran-ispolnim LIVE_PREDPOSYLKA: не установлен пакет jest-expo; … нет node_modules/.bin/jest)
W147 --repo R         клеток 76, зелёных 61, красных 15, rc 1 | клеток 76, зелёных 61, красных 15, rc 1
```

Ни одна батарея не покраснела признаком PUSTOJ_PRODUKT; первые строки вывода на OBJECT — собственные клетки батарей, как на базе. Рецепт И-8 «W --repo C → rc 0» на станции недостижим ни на базе, ни на OBJECT: клетке s-ekran-ispolnim нужен установленный mobile/node_modules (у копий его нет); исход побайтно прежний (75/76), к гейту не относится.

## (3) Красное предъявлено; проверка не подогнана

Тот же W (блобы `pustoj_produkt_159/` OBJECT, скопированы поверх) на дереве до реализации — одноразовый worktree `base2` = `ff320331` (freeze^{commit}), `ls scripts/check_pustoj*` → No such file or directory:

```text
$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
CASE s-gate-v-dereve KRASNO SUBJECT_ABSENT scripts/check_pustoj_produkt.sh
CASE s-gate-raven-etalonu KRASNO SUBJECT_ABSENT гейт не судится
CASE s-gate-pishet-trassu KRASNO SUBJECT_ABSENT гейт не судится
CASE W-gespraech_otdacha_151/{a,b1,b2,v,g} KRASNO SUBEKT_RC2 rc=2 (fail-closed — не зелень)
CASE W-gespraech_otdacha_151/d1-karta-nechitaema KRASNO GATE_NE_VYZVAN записей трассы 0 (ожидалась одна с этим R)
CASE W-gespraech_tekst_149/{a,b1} KRASNO GATE_NE_VYZVAN …;  /{b2,v,g,d1} KRASNO VREMJA_ISTEKLO субъект завис
CASE W-gespraech_vhod_147/{a,b1,b2,v,g,d1} KRASNO GATE_NE_VYZVAN записей трассы 0 …
CASE W-vkladki_tabov_148/{a,b1,b2,v} KRASNO VREMJA_ISTEKLO …;  /{g,d1} KRASNO GATE_NE_VYZVAN …
клеток 27, зелёных 0, красных 27; режим derevo
BASE_CURRENT_W_RC=1
своя мера (Counter по колонке причины): SUBJECT_ABSENT 3, SUBEKT_RC2 5, GATE_NE_VYZVAN 11, VREMJA_ISTEKLO 8; CASE 27, KRASNO 27
```

Повтор на втором одноразовом worktree `base` = `ff320331`:

```text
замороженный W (блобы фикстуры на теге):  клеток 27, зелёных 0, красных 27; BASE_FROZEN_W_RC=1
тот же W OBJECT (повтор):                 клеток 27, зелёных 0, красных 27; BASE_CURRENT_W_RC=1
  REASONS {'SUBJECT_ABSENT': 3, 'SUBEKT_RC2': 5, 'GATE_NE_VYZVAN': 13, 'VREMJA_ISTEKLO': 6}
```

Совпадает с §Приёмка п. 1 (rc 1; 27 клеток; 3 SUBJECT_ABSENT + 24 W-клетки; причины из названного набора; распределение по нагрузке не порог). Клетки `W-path-bash-*` без гейта не добавляются (`if os.path.isfile(ZHIVOJ_GATE)`), поэтому 27, а не 31. Красное предъявлено своей мерой; после реализации тот же W зелен 51/51 (2).

Фикстура после freeze (`git diff 'frozen/contracts/159/1^{commit}' 2a7fc735b -- fixtures/workshop_project/pustoj_produkt_159/`), автор — только architect:
- добавлено: стабы s16 (нить до гейта), s17 + path_fake_bash.py (PATH-подмена bash); формы `wiring-thread-before-gate`, `wiring-path-spoof` в `VETKA_PO_FORME`/`TRASSA_PO_FORME`; клетки `W-path-bash-<4>` (`kontrol_podmeny_path`); в sitecustomize — наблюдатель запуска нити/`_thread`/`os.fork`/`subprocess.Popen` до гейта (`PRE_GATE_*`). Итог W 47→51, SVJAZI 15→17.
- изменено в прежнем: в `sudit_provodku` проверка `rc != ozh_rc` переставлена ДО проверки `calls`. Оба условия по-прежнему красят клетку; меняется лишь ИМЯ ветви, когда истинны оба. Все прежние стабы пойманы своей прежней ветвью (`--stabs`: s9 RC_NE_1, s11 RC_NE_2, s8/s10/s12–s15 KLETKI_POSLE_OTKAZA). Новый параметр `extra_env=None` прежним вызовам ничего не меняет. sha `model/sitecustomize.py` в source.json обновлён вместе с файлом (пин сохранён).
- ни одной удалённой клетки, ни одного удалённого входа, оракул (`OZHIDAEMYE`) и эталон грамматики (sha 78332e66… тот же) не тронуты. Ослабления нет.
- implementer файлов фикстуры 159 не трогал (таблица (1)).

## (4) Остаточный риск «обход наблюдателя конкурентным исполнением» — своя мера

Одноразовая копия носителя, мутация только `--repo`-ветви 147 (вставка перед вызовом гейта), безфлаговый W, маркеры вне дерева прогона:

```text
MUT thread (threading.Thread ждёт трассу, после отказа читает PRAVILA_MASHINY и пишет маркер)
  CASE W-gespraech_vhod_147/{a,b1,b2,v,g,d1} KRASNO KLETKI_POSLE_OTKAZA … PRE_GATE_THREAD (6)
  CASE W-path-bash-gespraech_vhod_147 KRASNO KONTROL_NEVALIDEN … PRE_GATE_THREAD
  клеток 51, зелёных 44, красных 7; MUT_thread_W_RC=1; маркеров 7 (клетка действительно исполнилась)
MUT spawn_env (os.posix_spawn python-ребёнка с унаследованным env; ребёнок спит 1 с и исполняет --piny-only 147)
  те же 7 клеток KRASNO … C_CALL:pop; MUT_spawn_env_W_RC=1; маркеров 7 («cell rc=0»)
MUT spawn_clean (то же, но env={} — sitecustomize в ребёнке не грузится)
  клеток 51, зелёных 51, красных 0; MUT_spawn_clean_W_RC=0; маркеров 8 («cell rc=0»)
```

Вывод: нить, `_thread`, `fork`, `subprocess.Popen` и posix_spawn с унаследованным окружением W теперь ловит. posix_spawn с очищенным окружением — НЕ ловит: собственная клетка 147 (`--piny-only`, проверка пинов) исполнилась после честного отказа гейта 8 раз (6 входов W-147 + честная и атакующая половины W-path-bash-147), а W дал 51/51 rc 0.

**БЛОКИРУЕТ — Р159-Б1.** ОБЯЗАТЕЛЬСТВО: контракт 159, §Приёмка п. 7 — «adversary запускает обязательную атаку потоком/нитью или subprocess, созданным до вызова гейта, … на отказах rc 1 (`a-forma-pusta`) и rc 2 (`d1-karta-nechitaema`) и проверяет `W`; … если собственная клетка исполняется после честного отказа гейта незамеченной, приёмка реализации FAIL независимо от rc `W`»; ПРОВОДКА-ЭНФОРСМЕНТ («наблюдатель исполняемого Python-кода передаёт свидетельства тихих клеток …»). ФРАГМЕНТ: `fixtures/workshop_project/pustoj_produkt_159/model/sitecustomize.py:37-83` — наблюдатель запуска до гейта подменяет ровно четыре точки входа (`_thread.start_new_thread`, `threading.Thread.start`, `os.fork`, `subprocess.Popen`); `os.posix_spawn`/`os.spawn*`/`os.system`/`os.exec*` не наблюдаются, а ребёнок без унаследованного `PYTHONPATH` не грузит sitecustomize и не виден наблюдателю событий. СОСТОЯНИЕ: одна вставленная строка в `--repo`-ветвь 147 перед вызовом гейта — `os.posix_spawn(sys.executable, [sys.executable, child.py, probe.py, marker], {})`, ребёнок спит 1 с и исполняет собственную клетку 147. НАБЛЮДЕНИЕ: выше, `MUT_spawn_clean_W_RC=0`, `клеток 51, зелёных 51, красных 0`, маркеров 8 «cell rc=0»; на rc 1 (`a-forma-pusta`) и на rc 2 (`d1-karta-nechitaema`) — обе клетки ok. ПРЕЦЕДЕНТ: тот же класс («subprocess, созданный до гейта») с нитью был блоком adversary v1 (verdicts/adversary/contracts-159-impl-v1.md, Б1) и закрыт усилением W; закрытие покрыло нить и Popen, но не весь названный п. 7 класс. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: W краснеет на любом порождении процесса/нити субъектом до вызова гейта (кроме самого вызова гейта), включая raw `os.posix_spawn`/`os.spawn*`/`os.system`/`os.exec*` без наследования окружения, сохраняя зелень честного раннего выхода на rc 1 и rc 2; плюс стаб этого варианта в `--stabs`. Возможная простая форма — `sys.addaudithook` на CPython-события `os.posix_spawn`, `os.spawn`, `os.system`, `os.exec`, `os.fork`, `_thread.start_new_thread`, `subprocess.Popen` до появления трассы → `PRE_GATE_*` (аудит-хук не снимается, как уже используется для `sys.settrace`). Своя проба на станции (Python 3.12.3): `sys.addaudithook` получил события `os.posix_spawn` (с `env={}`), `os.system`, `subprocess.Popen`, `_thread.start_new_thread` — форма достижима. Зона закрытия — architect (W); код implementer правки не требует.

Риск не расширился: класс прежний, названный контрактом; но заявление выдачи «тред-обход теперь ловится W» верно только для нитей/fork/Popen/наследующего окружение ребёнка. По диффу (ловец «reviewer по диффу»): четыре реальные `--repo`-ветви OBJECT не порождают ни нити, ни процесса до гейта, кроме самого вызова гейта, модульный уровень чист — в коде implementer собственная клетка после отказа не исполняется. Блок — по силе W, которую п. 7 делает условием приёмки реализации.

## (5) Паразитная сложность (контракт 050)

- `scripts/check_pustoj_produkt.sh` (новый, 215 строк): (1) инв. 1–3 — живой гейт в scripts/, трасса первым действием, грамматика эталона; (2) состояние — env `PUSTOJ_PRODUKT_TRACE` (файл трассы, явно в инв. 3) и `PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP` (явно в инв. 1); оба названы в контракте, видны в аргументах/выводе; (3) при правке грамматики меняются вместе эталон фикстуры и гейт (2 файла) — заложено контрактом: «эталон — единый источник», «живой гейт равен эталону», равенство судит W на 21 входе; тело грамматики гейта — дословная копия эталона (difflib без комментариев: расхождения только в имени `_simuliruj`→`simuliruj_dostup`, docstring и `if __name__`); это прежний паттерн дерева (live `scripts/ekran_shablon.py` ↔ эталон 146 под PORT_DOSLOVEN); (4) интерфейс — 1 позиционный аргумент, rc 0/1/2, 2 env — минимален для работы; (5) потребитель — W (s-gate-*) и четыре `--repo`-ветви. ESSENTIAL. Более простая форма «гейт делегирует эталону из fixtures/» не проходит границу зон (scripts не должен зависеть от фикстуры architect-зоны, правка фикстуры молча меняла бы живой гейт).
- `DOVERENNYY_BASH='/usr/bin/bash'` + проверка `isfile/X_OK` → rc 2 NOT_IMPLEMENTED (×4 probe.py): (1) блок 2 adversary v1 и клетки `W-path-bash-*`/стаб s17 — вызов гейта не через PATH; (2) состояния не вводит, отказ именован в stderr и rc; (3) константа в четырёх файлах, как и `GEJT_PUSTOGO_PRODUKTA` — общего модуля в зоне implementer нет, правки зоны раздельные; диффом число совместно меняемых файлов не выросло (было 4 места вызова — осталось 4); (4) интерфейс не растёт (новых флагов/env нет); (5) потребитель — W-path-bash-* в W. ESSENTIAL. Переносимость абсолютного `/usr/bin/bash` — СОВЕТ Р159-С2.
- `import os` в 148: нужен для `os.path.isfile`/`os.access(…, os.X_OK)`; у 148 до правки `os` не импортировался (pathlib). ESSENTIAL (минимальная форма проверки исполняемости).
- Трасса гейта (строка `printf … >> "$PUSTOJ_PRODUKT_TRACE" || exit 2`): (1) инв. 3; (2) явное состояние — файл по env, путь задаёт вызывающий; (3) 1 файл; (4) +0 аргументов; (5) потребитель — `s-gate-pishet-trassu` и суд проводки. ESSENTIAL. `|| exit 2` — fail-closed при неписуемой трассе, соответствует домену rc.
- Добавки architect (s16, s17+path_fake_bash, `kontrol_podmeny_path`, хуки sitecustomize, `extra_env`): (1) блоки 1–2 adversary v1; (2) `extra_env` явный параметр, маркеры — temp вне дерева, удаляются; (3) форма стаба — source.json + VETKA/TRASSA_PO_FORME + файл стаба (3 места, прежний паттерн s1–s15); (4) `sudit_provodku` +1 необязательный параметр; (5) потребитель — W/`--stabs`. ESSENTIAL по свойствам; форма наблюдателя (monkeypatch четырёх точек входа) неполна — блок Р159-Б1 по п. 7 (не по 050): более простая форма (audit-hook) закрывает и отсутствующее свойство.

## (6) Замороженный текст против живого W

Расхождение: контракт §Приёмка п. 4 «клеток 47», п. 3 и п. 6 «SVJAZI 15», замер `stabs/s*.py | wc -l = 15`; живой W на OBJECT — 51 клетка, `SVJAZI 17`, 17 файлов `stabs/s*.py`. Класс: устаревший текст после законного усиления гейта architect-зоной в ответ на FAIL adversary v1 (добавлены только клетки/стабы, (3)); не блок. Правка текста — v+1 контракта владельцем/architect. Отдельно: строка `census` замера (`= 15`) при подключении CI-замера оркестратором даст расхождение с фактом 17 — СОВЕТ Р159-С3.

## (7) ПРОВОДКА контракта

```text
$ bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md   (носитель и ровно OBJECT)
проводка: guard не подключён: fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/
PROVODKA_RC=1
grep -c red_pustoj_produkt_159 registry/ci-steps.tsv .github/workflows/ci.yml → 0 / 0
```

guard = `red_pustoj_produkt_159.sh` — барьер именно этого предмета (судит гейт и четыре `--repo`-ветви), не случайный скрипт дерева. Канал существует, не подключён. По заданию и контракту (§Порядок: «оркестратор подключает CI-шаг в окне freeze..done», ЗОНА orchestrator registry/ci-steps.tsv, ci-zamery.tsv, ci.yml) — СОВЕТ оркестратору Р159-С4, не блок. Поведенческой нормы (029-класс) предмет не вводит; ПРОВОДКА-ЭНФОРСМЕНТ обоснован как чистый энфорсмент механизма приёмки.

СВЕРКА-СТАНДАРТОВ: AGENTS.md харнесса документов архитектуры/стандарта кода не объявляет (`grep ARCHITECTURE|CODING-STANDARDS AGENTS.md` → 0; docs/ содержит только 048-…, 053-…) — сверять не с чем, строка неприменима.

Режим проекта: sourceCanon=null — сверка карты неприменима.

## Итог

FAIL: один блок Р159-Б1 (сила W по п. 7 — pre-gate `os.posix_spawn` с очищенным окружением исполняет собственную клетку после отказа незамеченной; зона закрытия architect). Код implementer по всем семи пунктам суда соответствует: гейт равен эталону на 21 входе, пишет трассу первым действием, вызван первым действием всех четырёх `--repo`-ветвей доверенным интерпретатором, rc 1/2 проброшены; дифф implementer — 297 добавленных строк, 0 удалённых, только в своей зоне; исходы регрессий и живых `--repo` прежние. После закрытия Р159-Б1 достаточен scoped-повтор: W bare/`--stabs` на новом OBJECT + мутация spawn_clean (и ловля новых путей) — без повторного полного суда implementer-кода, если его блобы не менялись.

## Находки

```markdown
---
status: ready
subject: 159 pustoj-produkt-krasnyj — суд реализации (reviewer, вызов 1 полный)
object: 2a7fc735bcd04dbb025ed88a7cc14343f74fef8a
contract: frozen/contracts/159/1 (91e3eff262cbbfa4498a1539e5d3b340605186aa)
verdict: verdicts/review/contracts-159-impl-v1.md (FAIL)
reviewer: reviewer (сессия Reviewer159Opus; anthropic/claude-opus-5-5)
---

# Review 159 — гейт пустого продукта на 2a7fc735

Один блокер (зона architect, W). Советы — адресатам по зонам, не блокируют.

## Блокеры

- [ ] **Р159-Б1 (architect, W). п. 7: pre-gate subprocess с очищенным окружением не виден W.**
  Обязательство: §Приёмка п. 7 («атака потоком/нитью или subprocess, созданным до вызова
  гейта … если собственная клетка исполняется после честного отказа гейта незамеченной,
  приёмка реализации FAIL независимо от rc W»). Фрагмент: `model/sitecustomize.py:37-83`
  подменяет только `_thread.start_new_thread`, `threading.Thread.start`, `os.fork`,
  `subprocess.Popen`. Состояние: строка `os.posix_spawn(sys.executable, [sys.executable,
  child.py, probe.py, marker], {})` перед вызовом гейта в `--repo`-ветви 147; ребёнок спит 1 с
  и исполняет `--piny-only` 147. Наблюдение: W `клеток 51, зелёных 51, красных 0`, rc 0;
  маркеров 8 «cell rc=0» (включая a-forma-pusta rc 1 и d1-karta-nechitaema rc 2).
  Закрывающее свойство: W красен на любом порождении процесса/нити до гейта (кроме вызова
  гейта), включая `os.posix_spawn`/`os.spawn*`/`os.system`/`os.exec*` без наследования env;
  честный ранний выход rc 1/rc 2 зелён; стаб варианта пойман в `--stabs`. Простая форма —
  `sys.addaudithook` на CPython-события `os.posix_spawn`, `os.spawn`, `os.system`, `os.exec`,
  `os.fork`, `_thread.start_new_thread`, `subprocess.Popen` до появления трассы.

## Советы
- [ ] **Р159-С2 (implementer).** `DOVERENNYY_BASH='/usr/bin/bash'` жёстко: на станции без
  `/usr/bin/bash` (только `/bin/bash`) все четыре `--repo`-ветви дают rc 2 NOT_IMPLEMENTED —
  fail-closed, не зелень; на CI ubuntu и станции оба пути есть. Возможна фиксированная
  упорядоченная пара доверенных абсолютных путей без PATH.
- [ ] **Р159-С3 (владелец/architect, текст).** Замороженный текст: п. 4 «клеток 47», п. 3/6
  «SVJAZI 15», замер `stabs/s*.py | wc -l = 15`; живой W — 51 клетка, SVJAZI 17, 17 файлов.
  Правка — v+1 контракта; до неё census-замер при подключении CI разойдётся с фактом.
- [ ] **Р159-С4 (orchestrator).** `check_provodka.sh . contracts/159-…` rc 1: guard
  `red_pustoj_produkt_159.sh` не подключён в `registry/ci-steps.tsv`/`.github/workflows/ci.yml`.
  Интеграционный коммит в окне freeze..done (безфлаговый W после ленда).
- [ ] **Р159-С5 (implementer, к сведению).** Гейт сам резолвит `date` и `python3` через PATH:
  с фальшивым `python3` (exit 0) в PATH `148 --repo <пустой>` после действительной записи
  трассы исполнил собственные клетки (38 строк, rc 1 своими причинами). Свойство «вызов
  именно гейта» не нарушено (трассу пишет настоящий гейт); враждебный PATH так же подменяет
  `python3` обёрток батарей — среда, а не проводка; контрактом не покрыто (не блок).
```
