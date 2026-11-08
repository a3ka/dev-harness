FAIL

СУД: repo=dev-harness; предмет=159; фаза=реализация; роль=adversary; вызов=1; OBJECT=d430c0f400f7d201986a317952695a719b94b549.

Рабочий пин до прогона: `/tmp/dev-harness-worktrees/c907157c/wip-159-adversary`; `git rev-parse --show-toplevel` → `/tmp/dev-harness-worktrees/c907157c/wip-159-adversary`.

Судился одноразовый клон `wip/159/implementer` в
`/tmp/dev-harness-verify/Adversary159Terra/clone`. Кандидат до мутаций
подтвердил положительные контроли:

```text
$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
клеток 47, зелёных 47, красных 0; режим derevo
[exit=0]

$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model
клеток 23, зелёных 23, красных 0; режим model
[exit=0]

$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --stabs
SVJAZI 15
клеток 23, зелёных 23, красных 0; режим stabs
[exit=0]
```

Четыре отдельные `--repo`-ветви на существующем пустом каталоге дали
одинаковый ожидаемый отказ (сырой вывод каждого):

```text
$ python3 fixtures/workshop_project/gespraech_vhod_147/probe.py --repo …/empty
PUSTOJ_PRODUKT: KATALOG_PUST
[exit=1]
$ python3 fixtures/workshop_project/vkladki_tabov_148/probe.py --repo …/empty
PUSTOJ_PRODUKT: KATALOG_PUST
[exit=1]
$ python3 fixtures/workshop_project/gespraech_tekst_149/probe.py --repo …/empty
PUSTOJ_PRODUKT: KATALOG_PUST
[exit=1]
$ python3 fixtures/workshop_project/gespraech_otdacha_151/probe.py --repo …/empty
PUSTOJ_PRODUKT: KATALOG_PUST
[exit=1]
```

## БЛОКИРУЕТ — поток до гейта исполняет тихую клетку после отказа

**ОБЯЗАТЕЛЬСТВО:** контракт 159, инварианты 2–3 и критерий 7:
после отказа гейта собственная клетка батареи не исполняется; обязательная
атака нитью до вызова гейта на rc 1 и rc 2 должна краснить W независимо от
его финального rc.

**СОСТОЯНИЕ:** одноразовая мутация всех четырёх `probe.py` создаёт до
`subprocess.run(['bash', GEJT_PUSTOGO_PRODUKTA, …])` недемонскую нить.
Нить молча ждёт появления `PUSTOJ_PRODUKT_TRACE`, которое гейт пишет своим
первым действием; затем записывает маркер вне `baza`. Главный поток после
возврата гейта только проверяет rc и возвращает его. Поэтому клетка
исполняется после честного отказа, но не наследует `sys.settrace` /
`sys.setprofile`, установленные `sitecustomize.py` только главному потоку.

**НАБЛЮДЕНИЕ:**

```text
$ python3 …/mutate_threads.py && bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
MUTATED 4 probe branches; marker= /tmp/dev-harness-verify/Adversary159Terra/thread-cells.log
…
CASE W-gespraech_otdacha_151/a-forma-pusta ok
CASE W-gespraech_otdacha_151/d1-karta-nechitaema ok
…
CASE W-gespraech_vhod_147/a-forma-pusta ok
CASE W-gespraech_vhod_147/d1-karta-nechitaema ok
…
CASE W-vkladki_tabov_148/a-forma-pusta ok
CASE W-vkladki_tabov_148/d1-karta-nechitaema ok
клеток 47, зелёных 47, красных 0; режим derevo
THREAD_W_RC=0
THREAD_MARKERS=24
thread cell after gate refusal
… (24 identical marker lines)
```

**ОБХОД:** все 24 обязательные проводочные клетки, включая оба требуемых
кода отказа каждой из четырёх батарей, прошли зелёными, хотя маркер
подтверждает 24 исполнения тихой собственной клетки после отказа. Это
ровно принятый остаточный риск нити; критерий 7 требует обнаружить его, а
текущий W его пропускает.

**ЗАКРЫВАЮЩЕЕ СВОЙСТВО:** W обязан краснеть на такой нити и при этом
сохранять зелень честного раннего выхода на rc 1 и rc 2. Способ наблюдать
и/или запретить субъектные нити до гейта — выбор автора.

## БЛОКИРУЕТ — `PATH` подменяет интерпретатор, W принимает неисполняемый гейт

**ОБЯЗАТЕЛЬСТВО:** инварианты 2–3 контракта 159 требуют действительного
вызова именно `scripts/check_pustoj_produkt.sh`, а не совпадающей строки
причины или поддельной трассы. Задание adversary прямо включает
PATH/env-подмену `bash`/`python3` в поиск обходов вне названного риска.

**СОСТОЯНИЕ:** в одноразовом `fakebin/bash` расположен fake `bash`. Для
вызова пути живого гейта он сам записывает допустимую строку трассы и
запускает эталон `model/check_pustoj_produkt_159.py`; для red-обёрток
делегирует `/usr/bin/bash`. Реальный
`scripts/check_pustoj_produkt.sh` был заранее мутирован до безусловного
`exit 99`. Все четыре батареи вызывают голое `bash` через `PATH`, поэтому
ни один запуск не исполняет реальный гейт.

**НАБЛЮДЕНИЕ:**

```text
$ python3 …/mutate_path.py
PATH_STUB_READY real_gate_sentinel=99 fake= /tmp/dev-harness-verify/Adversary159Terra/fakebin/bash
$ PATH=…/fakebin:$PATH bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
CASE s-gate-v-dereve ok
CASE s-gate-raven-etalonu/a-forma-pusta ok
…
CASE W-gespraech_otdacha_151/d1-karta-nechitaema ok
CASE W-gespraech_tekst_149/d1-karta-nechitaema ok
CASE W-gespraech_vhod_147/d1-karta-nechitaema ok
CASE W-vkladki_tabov_148/d1-karta-nechitaema ok
клеток 47, зелёных 47, красных 0; режим derevo
PATH_W_RC=0
```

**ОБХОД:** с подменённым `PATH` W получает все ожидаемые rc, причины и
трассы от эталона, но мутированный настоящий гейт (`exit 99`) не запускает
никто. Следовательно, трасса доказывает только запись в её файл, не
исполнение требуемого скрипта; этот обход находится вне именованного
риска потока/нити/subprocess.

**ЗАКРЫВАЮЩЕЕ СВОЙСТВО:** запуск живого гейта и его проверка должны быть
независимы от подменяемого `PATH` (либо W обязан fail-closed при такой
подмене), а негативный вариант с неисполняемым настоящим гейтом и
правдоподобной трассой должен краснить W.

Не блокирующие классы, которые были предъявлены существующей батарее:
`--stabs` поймал 15 вариантов, в том числе пустой вход, собственную
проверку вместо гейта, ранний stderr, симлинк src, rc-маскировку,
побочный эффект и тихие клетки функции/модуля/чужого файла; `--model`
подтвердил честные rc 1 и rc 2. Эти контроли не закрывают два обхода выше.
