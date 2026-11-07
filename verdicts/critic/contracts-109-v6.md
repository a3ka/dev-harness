accept
СУД: repo=dev-harness; предмет=109; фаза=ремонт v6; роль=critic; вызов=1; OBJECT=e88a8653e5209090ed772e9234f7caad88b3492d; модель-план=zai/glm-5.3; сессия=Critic109v6Glm; модель-факт=zai/glm-5.3; SHA=e88a8653e5209090ed772e9234f7caad88b3492d; предыдущий=critic 109 v5 accept (`verdicts/critic/contracts-109-v5.md`, OBJECT=ec459197313f1891cf27b5e13d3ed9a3821a7a10); исключение=нет. Независимость: трейс `/tmp/dev-harness-verify/154-critic-glm-trace.tsv` — `critic zai/glm-5.3 allowed`, `architect openai-codex/gpt-6-sol allowed` — автор ремонта (Architect109tok, r6) и судья в разных семействах. Пин сессии: `pwd` = `git rev-parse --show-toplevel` = `/tmp/dev-harness-worktrees/c907157c/wip-109-critic` (обе строки равны WORKTREE, git-команды только через него).

## Предмет и что проверялось

Ремонт замороженной батареи `fixtures/workshop_project/stend_109/` на OBJECT `e88a8653e` (ветка `wip/109/architect-r6`, родитель `a6da17801` = freeze registry 159). Диагноз проверен независимо и подтверждён: `delivery_span_tokens(n)` требовала `str(n)` ПОДСТРОКОЙ в span именованного теста `test('живое наблюдение: server+PG18…`; span включает заголовок (probe.py `_delivery_span`: `body.find("test('" + DELIVERY_TEST_TITLE)` → границы вызова), «18» ⊂ «PG18», поэтому при ровно 18 записях манифеста stale-мир (тест несёт N−1) проходил статическую часть и упирался в docker-границу (`v=None`) вместо красного; на 17 и 19 подстроки нет — ловятся. Исправление: числовой токен выведен из набора подстрок и проверяется отдельной формой `re.search(r'\bledger %d\b' % n, span)`; в срез добавлены миры 18 и 19 (`spisok = sorted({1, 14, 15, 17, 18, 19, base_n, base_n + 1})`). Прогоны — одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git` (HEAD клона = OBJECT, `git log`: `e88a8653 fix(109): require exact delivery ledger token…` ← `a6da1780 freeze: registry 159`), база миров — свежий клон Complior-back main `041c6b6417` (манифест N=17, `npm ci` rc 0, node v26.5.1), docker не вызывался (PATH-ферма среза, подложный docker внутри).

## БЛОКИРУЕТ

Нет. Все пять пунктов задания закрыты живыми прогонами:

1. **Красное до / зелёное после, 17/19 зелёные.** Старая батарея (`a6da1780`, `git archive` из клона) на базе N17: **rc 1, клеток 69, красных 1** — `mir-18:delivery-otstal KRASNO v=None note=NEEDS_ENV: docker недоступен` (stale-мир 18 НЕ пойман статикой — тот самый дефект; все остальные клетки ok, т.е. честный вход батареи краснел ложно ровно одной клеткой). Новая батарея на той же базе: **rc 0, клеток 76, красных 0**, включая `mir-18:delivery-otstal ok` и все клетки мира 19; «трижды подряд» — три прогона, каждый rc 0/76/0. A/B на уровне факта (PATH без docker, миры порождены `porodi_mir`): stale 17/19 ловят ОБЕ пробы (`v=False`), stale 18 старая — `v=None` (пропуск), новая — `v=False`. Честные 17/18/19 — `v=None` (docker-граница) у обеих: новой ложного красного нет.
2. **Проверка не ослаблена.** Формальная: `\bledger N\b` в span ⇒ подстрока `ledger N` ⇒ `str(N)` в span — всякий вход, который ловил прежний токен, ловит и новый; обратно — нет (замер D: span с «18» только в `rows.length, 18` без «ledger 18» — старая `v=None`, новая `v=False`, новая строго сильнее). Токен и regex — только внутри span (границы `_delivery_span` не менялись; кейс `delivery_noop_borrow_neighbor` — заимствование соседнего теста — ловится обеими пробами на 17 и 18). Кейсовые мутации: `delivery_live_noop` (nul/noop-тело) и `borrow_neighbor` — `v=False` у обеих проб на 17/18; `delivery_token_stale` — старая на 18 `v=None` (баг), новая `v=False`. Счёт не уменьшился: CASES 57 = 57 (имена и байт-код фабрики stale идентичны), STABY 9/13 = 9/13 (привязки идентичны), клеток 76 > 69 > 62 и стабов 89 > 82 > 75.
3. **Область.** `git diff --name-only a6da17801 e88a8653e` → ровно `fixtures/workshop_project/stend_109/probe.py`, `fixtures/workshop_project/stend_109/srez_migracii_109.py` — оба в ЗОНЕ architect; `git diff a6da17801 e88a8653e -- contracts/` → 0 байт (текст контракта не менялся, заморозка не тронута).
4. **Счётные числа — см. строку ниже** (не блок по заданию v6).
5. **Н-39.** Стабы к ветвям привязаны кодом: `--stabs` новой батареи на базе N17 → **rc 0, «стабов 9, привязок 13, непойманных 0», клеток 89** — все 9 якорей нашлись в новой пробе (иначе rc 2 STAB_ANCHOR_MISSING), пины `source.json`/`model/manifest.json`/носители ci сверились самим срезом (иначе rc 2 ORACLE_TAMPERED); множество STABY и привязки байт-идентичны прежним.

## Называемая строка (расхождение чисел, по заданию — не блок v6)

Числа контракта 62/69/75 (приёмка 9 в скобках и §Замер v5 пп.1–2,7: 62 = base main N=14, 69 = base 007 N=15, 75 = --stabs base main) расходятся с текущим измерением 76/89 на базе N17 — но расхождение возникло ДО этого ремонта: старая батарея на той же базе N17 даёт 69/82 (и rc 1), а замороженные 62/75 воспроизводятся старыми байтами только на базе N14 (проверено: старая на синтетической базе N14 → rc 0, клеток 62; новая там же → rc 0, 76). Причина сдвига — рост базы продукта 14→17 (механика base/base+1 добавляет миры), ремонт добавляет строго +7 (мир 19: 5 сценариев + tokem + otstal) и ничего не убирает. Проза приёмки 9 «N ∈ {1, 14, 15, 17, base, base+1}» отстала от кода среза ({…, 18, 19, …}) — по Н-39 состав миров живёт в коде батареи, текст заморожен и правке не подлежит; отставание зафиксировано здесь. Решение об отражении новых чисел — за полномочной ролью (владелец/оркестратор) при следующей редакционной записи, НЕ молчаливо.

## Сырой вывод прогонов (одноразовый клон, база Complior-back main 041c6b6417 N=17)

```
$ python3 old109/srez_migracii_109.py --model --base back   # байты a6da1780
mir-18:delivery-tokem                         ok
mir-18:delivery-otstal                        KRASNO v=None note=NEEDS_ENV: docker недоступен — delivery-тест на PG18 НЕ исполнен
…
клеток 69, красных 1
RC=1

$ python3 clone/…/srez_migracii_109.py --model --base back  # байты e88a8653e
…(mir-18:zeleno/nedokat/perekat/podlognyj-soderzhimoe/pustoj-ledger ok; mir-19:* ok)…
mir-18:delivery-tokem                         ok
mir-18:delivery-otstal                        ok
mir-19:delivery-tokem                         ok
mir-19:delivery-otstal                        ok
клеток 76, красных 0
RC=0        # повтор ×2: клеток 76, красных 0; RC_progon2=0; RC_progon3=0

$ python3 clone/…/srez_migracii_109.py --stabs --base back
…
stab s-konstanta-14 @ mir-15:zeleno          ok
…(ещё 12 привязок ok)…
стабов 9, привязок 13, непойманных 0
клеток 89, красных 0
RC=0

$ python3 old109/srez_migracii_109.py --model --base mir-14  # синтетическая база N14
клеток 62, красных 0
RC_old=0
$ python3 clone/…/srez_migracii_109.py --model --base mir-14
клеток 76, красных 0
RC_new=0
```

A/B факта `delivery_test_fact` (PATH без docker; «пойман» = v=False):

```
stale N=17 стар  True   stale N=17 нов  True
stale N=18 стар  False  stale N=18 нов  True     # баг до / после
stale N=19 стар  True   stale N=19 нов  True
mut_delivery_live_noop          N=18 стар True, нов True   (N=17 также True/True)
mut_delivery_noop_borrow_neighbor N=18 стар True, нов True (N=17 также True/True)
mut_delivery_token_stale        N=18 стар False, нов True  (N=17 True/True)
D. rows.length-only N=18 (без «ledger 18»): стар v=None, нов v=False  # нов строже
honest 17/18/19: v=None (docker-граница) у обеих проб — ложного красного нет
```

Счётные сверки: `CASES стар = 57  CASES нов = 57`; `CASES имена равны = True`; `STABY стар = 9 привязок 13` / `STABY нов = 9 привязок 13`; `STABY равны = True`; `фабрики кейсов равны байт-в-байт (stale): True`. Область: `git diff --name-only a6da17801 e88a8653e` → только два файла stend_109; `git diff a6da17801 e88a8653e -- contracts/` → пусто (0 байт).

## Границы

Живой docker-слой (node --test на disposable PG18) не гонялся — станция не грузится, это объявленная граница среза (docker-факты NEEDS_ENV, судятся lane stend109); статическая часть — предмет ремонта — покрыта полностью. Одноразовые копии (клон, база, старая батарея, миры, A/B-скрипт) удалены после фиксации вывода в этом вердикте. Push не выполнялся; вердикт закоммичен в WORKTREE `wip/109/critic` под именем critic.
