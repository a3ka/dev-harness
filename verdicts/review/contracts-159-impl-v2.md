FAIL

СУД: repo=dev-harness; предмет=159; фаза=реализация; роль=reviewer; вызов=2 (scoped); OBJECT=190204068ee342f5ccf665e5ad7d432adb1a02a9; сессия=Reviewer159Opus2; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; предыдущий=verdicts/review/contracts-159-impl-v1.md (FAIL, 87f4c882b/3937c91a4, Р159-Б1); автор дельты=architect (190204068, поверх реализации 2a7fc735b).
Независимость: судья — Anthropic Opus; реализация — implementer, W — architect, adversary — openai-codex/gpt-5.6-terra (по v1). Модель architect этой дельты по трейсу я не сверял.

Пин: `cd /tmp/dev-harness-worktrees/c907157c/wip-159-reviewer; pwd; git rev-parse --show-toplevel` → `/tmp/dev-harness-worktrees/c907157c/wip-159-reviewer` / `/tmp/dev-harness-worktrees/c907157c/wip-159-reviewer` (HEAD 65fa3044b, ветка wip/159/reviewer).

Объём (scoped, `roles/critic.md §Быстрый-процесс §Контракт`): закрытие класса Р159-Б1 и последствия дельты 2a7fc735b..190204068. Дополнительный поиск привязан к изменённой семантике: дельта заменила подмену четырёх точек входа на audit-хук и переписала белый список вызова гейта (`model/sitecustomize.py:101-129`). Неизменённые поверхности (гейт, четыре probe.py) заново не исследовались — их блобы не менялись, см. (3).

## Кандидат и носитель

- Одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Reviewer159Opus2/clone`, ветка `wip/159/implementer-r2`, HEAD `e549e42a94e6e2785b13fbaf808ed8a0027d09f7` (`test(159): catch clean-env process spawns before gate`, architect).
- OBJECT взят fetch-ем из выданного WORKTREE: `git cat-file -t 190204068ee3…` → `commit`. Worktree `obj` = ровно OBJECT; worktree `base` = ровно 2a7fc735bcd04dbb025ed88a7cc14343f74fef8a.
- `git diff 190204068 HEAD -- scripts/check_pustoj_produkt.sh fixtures/workshop_project/pustoj_produkt_159 <четыре probe.py>` → 0 байт, rc 0. В предметных путях носитель равен OBJECT.

## (1) Р159-Б1 — повтор своих мутаций на OBJECT

Мутация вставлена в `--repo`-ветвь 147 в одноразовой копии `obj`, перед `rc_gejta = subprocess.run([DOVERENNYY_BASH, …])`. Ребёнок не несёт наблюдателя (`env={}` либо `-S`). Он ждёт выхода родителя, затем исполняет собственную клетку 147 (`probe.py --piny-only`, env={}) и дописывает в маркер вне дерева `cell rc=N`. После каждого прогона я запускал безфлаговый W, копию удалял.

```text
=== obj posix_spawn_clean W_RC=1 :: клеток 51, зелёных 44, красных 7; режим derevo
CASE W-gespraech_vhod_147/{a-forma-pusta,b1,b2,v,g,d1-karta-nechitaema} KRASNO KLETKI_POSLE_OTKAZA после отказа вызвана собственная клетка PRE_GATE_SPAWN:os.posix_spawn
CASE W-path-bash-gespraech_vhod_147 KRASNO KONTROL_NEVALIDEN KLETKI_POSLE_OTKAZA … PRE_GATE_SPAWN:os.posix_spawn
KRASNO total: 7; markers: 7       7 cell rc=0
=== obj os_system W_RC=1 :: клеток 51, зелёных 44, красных 7  (те же 7 клеток, PRE_GATE_SPAWN:os.system; markers 7)
=== obj os_spawnv W_RC=1 :: клеток 51, зелёных 44, красных 7  (те же 7, PRE_GATE_SPAWN:os.fork; markers 7)
=== obj fork_execve_clean W_RC=1 :: клеток 51, зелёных 44, красных 7  (те же 7, PRE_GATE_SPAWN:os.fork; markers 7)
```

Четыре мутации из v1/задания на OBJECT КРАСНЫЕ (KLETKI_POSLE_OTKAZA/PRE_GATE_SPAWN), в том числе на отказах rc 1 (`a-forma-pusta`) и rc 2 (`d1-karta-nechitaema`).
Честные ранние выходы зелёные: безфлаговый W на `obj` — `CASE W-<4 батареи>/a-forma-pusta ok` и `…/d1-karta-nechitaema ok` (8 строк); `--model` — `m-provodka-a-forma-pusta ok`, `m-provodka-d1-karta-nechitaema ok`.
Стаб s18 в `--stabs`: `STAB s18_spawn_clean_posle_otkaza.py POJMAN vetka=KLETKI_POSLE_OTKAZA na a-forma-pusta` и `… na d1-karta-nechitaema`. Стаб не пустой: `sudit_staba` требует маркер `spawn cell after gate refusal` (`PRE_GATE_CELL_NOT_EXECUTED`, если клетка не исполнилась).

### Последствия дельты: класс Б1 закрыт не до своего закрывающего свойства

Закрывающее свойство, названное в v1: «W красен на любом порождении процесса/нити до гейта (кроме вызова гейта)». Новый наблюдатель смотрит на audit-события CPython. Я проверил своей мерой (`audit_probe.py`, Python 3.12.3), какие пути порождения процесса этих событий не дают:

```text
fork_exec events []                                       # _posixsubprocess.fork_exec
ctypes events ['ctypes.dlopen', 'ctypes.dlsym', 'os.listdir']
posix_spawnp events ['os.posix_spawn']; spawnv events ['os.fork']; system events ['os.system']; fork+execve parent events ['os.fork']
```

`multiprocessing.util.spawnv_passfds` (стартовые методы `spawn`/`forkserver` публичного stdlib `multiprocessing`) вызывает `_posixsubprocess.fork_exec` напрямую (`inspect.getsource` → `return _posixsubprocess.fork_exec(args, [path], True, passfds, None, None, …)`). Audit-события у этого пути нет.

Те же копии, тот же ребёнок-клетка, безфлаговый W:

```text
=== obj mp_spawn W_RC=0 :: клеток 51, зелёных 51, красных 0; режим derevo
   (вставка: multiprocessing.get_context('spawn').Process(target=os.system, args=('sleep 1; env -i python3 <147>/probe.py --piny-only; echo cell rc=$? >> M',)).start())
CASE W-gespraech_vhod_147/a-forma-pusta ok … CASE W-gespraech_vhod_147/d1-karta-nechitaema ok; CASE W-path-bash-gespraech_vhod_147 ok
KRASNO total: 0; markers: 8       8 cell rc=0
=== obj posixsubprocess_fork_exec W_RC=0 :: клеток 51, зелёных 51, красных 0   markers: 8  8 cell rc=0
=== obj ctypes_system W_RC=0 :: клеток 51, зелёных 51, красных 0               markers: 8  8 cell rc=0
=== obj bash_env_gate W_RC=0 :: клеток 51, зелёных 51, красных 0               markers: 8  8 cell rc=0
   (вызов гейта тот же, но env=dict(os.environ, BASH_ENV=<payload>); payload — фоновая подоболочка, исполняющая клетку после выхода гейта;
    белый список sitecustomize.py:118-126 сверяет только executable/argv, а env не сверяет)
```

Собственная клетка 147 исполнилась после честного отказа гейта 8 раз (6 входов W-147, в том числе rc 1 и rc 2, плюс две половины W-path-bash-147). W дал 51/51 rc 0. Порядок обеспечен построением: ребёнок спит 1 с (или ждёт смены `getppid`), а отказ гейта на пустом входе приходит раньше. Тайминги поштучно я не измерял. Класс тот же, что в Б1: процесс рождён до трассы гейта, наблюдателя не несёт, и W его не видит. Сценарий п. 7 контракта («subprocess, созданный до вызова гейта») назван явно. `multiprocessing` — публичный API stdlib, а не только приватный модуль. → **Р159-Б1 не закрыт** (блок ниже).

## (2) Регресс (ровно OBJECT, worktree `obj`)

```text
obj W bare RC=0 secs=18 last: клеток 51, зелёных 51, красных 0; режим derevo
obj W model RC=0 secs=0 last: клеток 23, зелёных 23, красных 0; режим model
obj W stabs RC=0 secs=10 last: клеток 23, зелёных 23, красных 0; режим stabs    (SVJAZI 18; строк ZHIV нет)
W gespraech_vhod_147 --model rc=0 :: клеток 76, зелёных 76, красных 0; режим model seed 147
W gespraech_vhod_147 --stabs rc=0 :: SVJAZI 18 :: клеток 76, зелёных 76, красных 0; режим stabs seed 147
W vkladki_tabov_148 --model rc=0 :: клеток 57, зелёных 57, красных 0
W vkladki_tabov_148 --stabs rc=0 :: SVJAZI 47
W gespraech_tekst_149 --model rc=0 :: клеток 96, зелёных 96, красных 0; режим model seed 149
W gespraech_tekst_149 --stabs rc=0 :: SVJAZI 19 :: клеток 96, зелёных 96, красных 0; режим stabs seed 149
W gespraech_otdacha_151 --model rc=2 :: INFRASTRUCTURE: --runtime R or --repo R with installed mobile/node_modules is required
W gespraech_otdacha_151 --stabs rc=2 :: INFRASTRUCTURE: … (то же)
PROBE gespraech_vhod_147 rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE gespraech_tekst_149 rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE vkladki_tabov_148 rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
PROBE gespraech_otdacha_151 rc=1 lines=1 out=[PUSTOJ_PRODUKT: KATALOG_PUST]
```

Счёт своей мерой: `grep -c '^CASE'` = 51, из них `KRASNO` 0. По префиксам: 1 s-gate-v-dereve + 21 s-gate-raven-etalonu + 1 s-gate-pishet-trassu + 4×6 W-<батарея> + 4 W-path-bash = 51. Файлов `stabs/s*.py` 18 = `SVJAZI 18`. Ответ 151 rc 2 INFRASTRUCTURE допустим по п. 5 и совпадает с v1. Пины: `sha256sum` sitecustomize.py `00f9ef67…`, s18 `c8687339…`, эталон `78332e66…` — равны `source.json`.

## (3) Область

`git log --format='%h %an <%ae> %s' --name-only 2a7fc735b..190204068`:

```text
19020406 architect <architect@dev-harness.local> test(159): catch clean-env process spawns before gate
fixtures/workshop_project/pustoj_produkt_159/model/sitecustomize.py
fixtures/workshop_project/pustoj_produkt_159/probe.py
fixtures/workshop_project/pustoj_produkt_159/source.json
fixtures/workshop_project/pustoj_produkt_159/stabs/s18_spawn_clean_posle_otkaza.py
```

Один коммит, одна задача, все пути в зоне architect (`fixtures/workshop_project/pustoj_produkt_159/`). Для `git diff 2a7fc735b 190204068 -- scripts/check_pustoj_produkt.sh <четыре probe.py> contracts/` → 0 байт: реализация, четыре probe.py и контракт не тронуты, норма не менялась.
`bash scripts/check_zones.sh .` на `obj` → `ZONES_RC=0`. Строка 159: `ok contracts/159-pustoj-produkt-krasnyj.md — работа не раздаётся: …`.

## (4) Красное против версии без хука (base = 2a7fc735b)

```text
=== base posix_spawn_clean W_RC=0 :: клеток 51, зелёных 51, красных 0   KRASNO 0; markers 8 (8 cell rc=0)
=== base os_system        W_RC=0 :: клеток 51, зелёных 51, красных 0   KRASNO 0; markers 8 (8 cell rc=0)
=== base os_spawnv        W_RC=1 :: клеток 51, зелёных 44, красных 7   PRE_GATE_FORK; markers 7
=== base fork_execve_clean W_RC=1 :: клеток 51, зелёных 44, красных 7  PRE_GATE_FORK; markers 7
=== base mp_spawn         W_RC=0 :: клеток 51, зелёных 51, красных 0   markers 8
base W bare RC=0 (51/51); base W stabs RC=0 (SVJAZI 17)
```

Новая проверка не пустая: `posix_spawn env={}` и `os.system` на base зелёные (51/51, клетка исполнилась 8 раз), на OBJECT красные. Заявление задания «те же мутации дают W 51/51 зелёный» верно для двух мутаций из четырёх. `os.spawnv` и `fork+execve` краснели уже на base, их ловила прежняя подмена `os.fork`. Дефекта в этом нет, это поправка к счёту. `mp_spawn` зелёный на обеих сторонах: дельта этот путь не закрыла.

## (5) Ничего не ослаблено

- Имена клеток base и OBJECT совпадают: `diff` отсортированных имён → `CELLNAMES_DIFF_RC=0`, 51 = 51.
- Строки `STAB` для s1–s17 на base и OBJECT совпадают побайтно, те же ветви и входы: `STAB_S1_S17_DIFF_RC=0`. s18 добавлен, `SVJAZI 17 → 18`.
- Удалённые строки диффа probe.py/source.json — 5, все они замены на обобщение: `if threaded:` → `if threaded or spawned:`; `THREAD_CELL_NOT_EXECUTED` → `PRE_GATE_CELL_NOT_EXECUTED` (маркер нити сохранён); sha sitecustomize обновлён вместе с файлом; в `staby` дописана запятая.
- В sitecustomize подмена `os.fork`/`subprocess.Popen` заменена audit-событиями `os.fork`/`subprocess.Popen` (плюс `os.posix_spawn`, `os.spawn`, `os.system`, `os.exec`, `os.forkpty`, `_thread.start_new_thread`). Белый список стал строже: точный `/usr/bin/bash` либо `bash` только для `gate_tracer.sh`, вместо прежнего `basename == 'bash'`. Ослабления нет.
- Советы С2–С5 вердикта 1 остаются советами. С4 подтверждён: `bash scripts/check_provodka.sh . contracts/159-…` на `obj` → `guard не подключён: … red_pustoj_produkt_159.sh …`, `PROVODKA_RC=1`; подключение — за оркестратором после accept.

## Паразитная сложность (контракт 050), по артефактам дельты

- audit-хук `_audit` (sitecustomize.py:101-129) и белый список вызова гейта: (1) п. 7 / Р159-Б1 — порождение процесса до гейта видно W; (2) состояние не вводит, свидетельства идут в тот же pipe (`PRE_GATE_SPAWN:<событие>` в выводе W); (3) правка того же свойства затрагивает 1 файл (+sha в source.json), диффом число не выросло (было 4 подмены, стал 1 хук); (4) интерфейс не растёт, новых env/флагов нет; (5) потребитель — W bare/`--stabs`. ESSENTIAL, но неполно по свойству — блок ниже (по §Порог, не по 050).
- s18 + форма `wiring-spawn-clean-before-gate` + ожидание маркера в `sudit_staba`: (1) Р159-Б1, стаб варианта; (2) маркер — temp вне дерева, удаляется; (3) 3 места, прежний паттерн s16; (4) форма стаба +1; (5) потребитель — `--stabs` (`SVJAZI 18`). ESSENTIAL.

СВЕРКА-СТАНДАРТОВ: AGENTS.md харнесса не объявляет документов архитектуры и стандарта кода (как в v1) — строка неприменима.
Режим проекта: sourceCanon=null, сверка карты неприменима.

## Итог

FAIL: один блок — Р159-Б1 не закрыт (класс тот же, последний вызов бюджета reviewer). Четыре мутации из v1 закрыты своей мерой. Регрессии зелёные. Область чистая. Реализация не тронута, и по диффу её четырёх `--repo`-ветвей собственная клетка после отказа не исполняется (как в v1). Блок — по силе W, которую п. 7 делает условием приёмки. По §Остановка дальнейший порядок (позиция автора, санкция или арбитраж) определяет оркестратор.

## Находки

```markdown
---
status: ready
subject: 159 pustoj-produkt-krasnyj — суд реализации (reviewer, вызов 2 scoped)
object: 190204068ee342f5ccf665e5ad7d432adb1a02a9
contract: frozen/contracts/159/1 (91e3eff262cbbfa4498a1539e5d3b340605186aa)
verdict: verdicts/review/contracts-159-impl-v2.md (FAIL)
previous: verdicts/review/contracts-159-impl-v1.md (FAIL, Р159-Б1)
reviewer: reviewer (сессия Reviewer159Opus2; anthropic/claude-opus-5-5)
---

# Review 159 v2 — закрытие Р159-Б1 на 190204068

## Блокеры

- [ ] **Р159-Б1 (architect, W) — не закрыт: процесс, рождённый до гейта путём без
  audit-события CPython, W не видит.**
  БЛОКИРУЕТ. ОБЯЗАТЕЛЬСТВО: §Приёмка п. 7 («атака … subprocess, созданным до вызова гейта, …
  если собственная клетка исполняется после честного отказа гейта незамеченной, приёмка
  реализации FAIL независимо от rc W»); закрывающее свойство Б1 из v1 — «W красен на любом
  порождении процесса/нити до гейта (кроме вызова гейта)».
  ФРАГМЕНТ: `fixtures/workshop_project/pustoj_produkt_159/model/sitecustomize.py:101-129` —
  видит только события `os.posix_spawn|os.spawn|os.system|os.exec|os.fork|os.forkpty|
  subprocess.Popen|_thread.start_new_thread`; белый список :118-126 освобождает вызов гейта
  по executable/argv, env не сверяет.
  СОСТОЯНИЕ (вставка перед вызовом гейта в `--repo`-ветви 147; ребёнок исполняет
  `probe.py --piny-only` 147 с env={} после отказа):
  (а) `multiprocessing.get_context('spawn').Process(target=os.system, args=(…,)).start()` —
  публичный stdlib, внутри `_posixsubprocess.fork_exec` без audit-события;
  (б) прямой `_posixsubprocess.fork_exec(…)`; (в) `ctypes.CDLL(None).system(b'(…)&')`;
  (г) тот же вызов гейта с `env=dict(os.environ, BASH_ENV=<payload>)` — фоновая подоболочка
  рождается до трассы гейта.
  НАБЛЮДЕНИЕ: каждый вариант — W `клеток 51, зелёных 51, красных 0`, rc 0; маркер `cell rc=0`
  ×8 (включая a-forma-pusta rc 1 и d1-karta-nechitaema rc 2). Контроль той же мерой:
  posix_spawn env={}, os.system, os.spawnv, fork+execve env={} — W rc 1, 7 KRASNO
  KLETKI_POSLE_OTKAZA/PRE_GATE_SPAWN (закрыты).
  Закрывающее свойство: W красен, если до трассы гейта рождён процесс иначе, чем ровно вызов
  гейта, включая `multiprocessing` spawn/forkserver и `_posixsubprocess.fork_exec`, нативный
  вызов через ctypes и вызов гейта с инъекцией стартового кода оболочки в окружение
  (`BASH_ENV`; того же семейства `ENV`, экспорт `BASH_FUNC_*` — [INFERENCE], не прогонял);
  честный ранний выход rc 1/rc 2 зелён; стаб варианта (а) пойман в `--stabs`.
  Одна из простых форм (не единственная): в sitecustomize обернуть `_posixsubprocess.fork_exec`
  тем же суждением, что и `subprocess.Popen` (subprocess держит собственную ссылку
  `_fork_exec`, честный вызов гейта идёт через audit `subprocess.Popen`); фиксировать до трассы
  `ctypes.dlopen`/`ctypes.dlsym`; освобождать вызов гейта, только если в его окружении
  (env либо `os.environ` при env=None) нет `BASH_ENV`/`ENV`/`BASH_FUNC_*`.

## Советы
- [ ] **Р159-С6 (оркестратор, к сведению).** Заявление выдачи «те же мутации на 2a7fc735b дают
  W 51/51» по своей мере верно для posix_spawn env={} и os.system. os.spawnv и fork+execve на
  2a7fc735b уже красны (PRE_GATE_FORK, прежняя подмена os.fork).
- С2–С5 из v1 — без изменений (С4: `check_provodka` rc 1, проводка CI — после accept).
```
