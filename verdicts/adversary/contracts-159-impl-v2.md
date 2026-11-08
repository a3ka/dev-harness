accept

СУД: repo=dev-harness; предмет=159; фаза=реализация; роль=adversary; вызов=2; OBJECT=2a7fc735bcd04dbb025ed88a7cc14343f74fef8a; сессия=Adversary159Terra2; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; автор=implementer; предыдущий=verdicts/adversary/contracts-159-impl-v1.md.

Рабочий пин до работы: `/tmp/dev-harness-worktrees/c907157c/wip-159-adversary`; `git rev-parse --show-toplevel` дал тот же путь.

Судился разрешённый одноразовый SSH-клон
`/tmp/dev-harness-verify/Adversary159Terra2/clone`, ветка
`wip/159/implementer-r2`, HEAD `9dcb8d6f958a69277a35324cd76647932793dd6f`.
Его HEAD не равен обозначенному OBJECT как commit, но все семь предметных
blob совпадают с OBJECT: гейт, `pustoj_produkt_159/{probe.py,red_*.sh}` и
четыре `probe.py` батарей. Поэтому прогоны относятся к неизменному предмету
OBJECT, а не к следующей семантике ветки.

## Scoped-повтор блоков v1

Безфлаговый W честной реализации зелёный:

```text
$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
...
клеток 51, зелёных 51, красных 0; режим derevo
W_RC=0
```

Повторена мутация v1: в каждую `--repo`-ветвь вставлена нить до гейта;
после честного rc 1/rc 2 она исполняет тихую клетку и пишет внешний маркер.
W не принял обход:

```text
THREAD_W_RC=1
THREAD_MARKERS=28
CASE W-gespraech_otdacha_151/a-forma-pusta KRASNO KLETKI_POSLE_OTKAZA ... PRE_GATE_THREAD
...
CASE W-vkladki_tabov_148/d1-karta-nechitaema KRASNO KLETKI_POSLE_OTKAZA ... PRE_GATE_THREAD
клеток 51, зелёных 23, красных 28; режим derevo
```

Положительный контроль честного раннего выхода остался зелёным на обоих
обязательных кодах:

```text
$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model
CASE m-provodka-a-forma-pusta ok
CASE m-provodka-d1-karta-nechitaema ok
клеток 23, зелёных 23, красных 0; режим model
HONEST_MODEL_RC=0
```

Повторена атака v1 с fake `bash` в `PATH`, правдоподобной трассой и живым
гейтом, заменённым на `exit 99`. Четыре ветви используют абсолютный
`/usr/bin/bash`, поэтому W красен, а не принимает подмену:

```text
PATH_W_RC=1
PATH_FAKE_USED=True
CASE W-gespraech_otdacha_151/a-forma-pusta KRASNO GATE_NE_VYZVAN записей трассы 0
...
CASE W-vkladki_tabov_148/d1-karta-nechitaema KRASNO GATE_NE_VYZVAN записей трассы 0
клеток 51, зелёных 23, красных 28; режим derevo
```

Проверен ближайший родственник нити — pre-gate `os.posix_spawn`. Одна
мутированная ветвь 147 порождает тихого ребёнка до гейта; тот после окна
отказа пишет маркер. W красен, хотя клетка действительно исполнилась:

```text
POSIX_ONE_W_RC=1
POSIX_ONE_MARKERS=7
posix_spawn cell after observed gate window
CASE W-gespraech_vhod_147/a-forma-pusta KRASNO KLETKI_POSLE_OTKAZA после отказа вызвана собственная клетка C_CALL:pop
...
CASE W-gespraech_vhod_147/d1-karta-nechitaema KRASNO KLETKI_POSLE_OTKAZA после отказа вызвана собственная клетка C_CALL:pop
клеток 51, зелёных 44, красных 7; режим derevo
```

Это закрывает именованный остаточный риск: зелёной обманной заглушки среди
повторённых нити, PATH-подмены и `posix_spawn` не получено.

## Контроли и регресс

`W --stabs` прошёл: `SVJAZI 17`, `клеток 23, зелёных 23, красных 0`, rc 0;
в частности `s16_thread_posle_otkaza.py` и `s17_path_bash.py` пойманы на
`a-forma-pusta` и `d1-karta-nechitaema`.

Четыре живые ветви на существующем пустом каталоге дали ровно требуемый
отказ:

```text
PUSTOJ_PRODUKT: KATALOG_PUST
147_EMPTY_RC=1
PUSTOJ_PRODUKT: KATALOG_PUST
148_EMPTY_RC=1
PUSTOJ_PRODUKT: KATALOG_PUST
149_EMPTY_RC=1
PUSTOJ_PRODUKT: KATALOG_PUST
151_EMPTY_RC=1
```

Модельные регрессии: 147 — `76/76`, 148 — `57/57`, 149 — `96/96`, все rc 0.
Стаб-режимы: 147 — `SVJAZI 18`, `76/76`, rc 0; 148 — `SVJAZI 47`, rc 0;
149 — `SVJAZI 19`, `96/96`, rc 0. У 151 и в `--model`, и в `--stabs`
наблюдался именованный `INFRASTRUCTURE: --runtime R or --repo R with installed mobile/node_modules is required`, rc 2. Это соответствует замороженному
контракту 159, п.5: батарея 151 не самодостаточна и без установленного
`mobile/node_modules` не обязана быть зелёной; противоречащая этому часть
выдачи («151 --model/--stabs rc 0») не относится к дефекту OBJECT.

Расхождение с замороженным текстом названо: живой W теперь содержит 51
клетку, `--stabs` — `SVJAZI 17`; контракт всё ещё называет 47/15. По выдаче
это известное законное пост-заморозочное усиление после v1, не предмет этого
scoped-суда.

БЛОКИРУЮЩИХ находок нет.
