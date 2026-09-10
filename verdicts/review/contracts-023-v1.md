FAIL

# Ревью контракта 023 v1

Судимая база — `2939065` (одноразовый клон `/tmp/reviewer023/repo`). Критичный
контрпример ниже воспроизведён мной; ничего критичного на веру не принято.

## Блокер — грань (ii) читает манифест только из локального object database

**Класс: блокер.** `scripts/spawn_agent.sh` в `2939065` после живых `ls-remote`
тега и `refs/heads/main` выполняет `git cat-file -p
"${origin_main_sha}:registry/contracts.tsv"`, но не выполняет обязательный
контрактом путь «ls-remote шапки → fetch объекта → show». Поэтому честный
полный резерв отвергается, если актуальный объект `origin/main` ещё не
реплицирован локально; отказ ошибочно назван «не выдан авторитетом», хотя
авторитет доступен и выдал пару.

Контрольный эксперимент построил два независимых toy: локальный аннотированный
тег запушен, другой клон записал в `origin/main` строку манифеста с тем же
`tag-object-sha`, а исходный toy этот новый объект не получал. Команда и сырой
результат:

```
/tmp/reviewer023/probe_fetch023.sh /tmp/reviewer023/repo; rc=$?; printf 'PROBE_RC=%d\n' "$rc"
ОТКАЗ: тег 771 не выдан авторитетом: манифест registry/contracts.tsv отсутствует на origin/main (3б)
GATE_UNFETCHED_RC=1
judged: contracts/772-scratch.md (дверь по тегу id/CONTRACT/772 пропущена под architect)
ok: staged в зоне автора architect (1 путь/путей)
DOOR_FETCH_RC=0
ОТКАЗ: авторитет недоступен: fetch origin refs/heads/main отказал
DOOR_FETCH_FAILURE_RC=1
PROBE_RC=0
```

Тем же экспериментом показаны обе нужные контрольные стороны для двери (iii):
`check_staged` fetch-ит неизвестный локальному toy объект и принимает честный
резерв (`DOOR_FETCH_RC=0`), а подмена только `git fetch` при живых `ls-remote`
даёт именно «авторитет недоступен», не «не выдан авторитетом»
(`DOOR_FETCH_FAILURE_RC=1`). Гейт (ii) обязан иметь ту же семантику до
продолжения done.

## Закрытие обхода скратча

Своим отдельным toy использовал заморозку **чужого** номера 776 с `ЗОНА
architect: contracts/`, локальный резерв `id/CONTRACT/777`, staged
`contracts/777-scratch.md`, свою `wip/777/architect` и мёртвый `origin`.

```
/tmp/reviewer023/probe_scratch023.sh /tmp/reviewer023/pre-fix
ОТКАЗ: авторитет недоступен: ls-remote origin refs/tags/id/CONTRACT/777 завершился кодом 128
PROBE_RC=1
SCRATCH_FILES=1

/tmp/reviewer023/probe_scratch023.sh /tmp/reviewer023/repo
ОТКАЗ: авторитет недоступен: ls-remote origin refs/tags/id/CONTRACT/777 завершился кодом 128
PROBE_RC=1
SCRATCH_FILES=0
```

`/tmp/reviewer023/pre-fix` — одноразовый worktree на `3ed06f8`; второй прогон
— `2939065`. Значит блокер адверсария о `.staged_ls_*` закрыт: именованный
fail-closed отказ сохранён, утечки в корне toy нет.

## Заморозка, область и независимость проверок

```
bash scripts/check_contract_frozen.sh .; rc=$?; printf 'RC=%d\n' "$rc"
... contracts/023-rezervacija-nomera-dver-po-tegu.md — заморожен v1, блоб совпадает побайтово ...
планов и контрактов на HEAD: 26 · черновиков: 4 · заморожено: 22 · реестр: full
RC=0

git diff --name-only 854d151..2939065 -- frozen/contracts frozen/plans; rc=$?; printf 'RC=%d\n' "$rc"
RC=0

git diff --name-status 31e1686..2939065 -- fixtures/; rc=$?; printf 'RC=%d\n' "$rc"
RC=0
```

Последняя пустая дельта подтверждает, что фикс `94beb17` не менял фикстуры.
История red-барьеров независима от реализации: `git merge-base --is-ancestor
271897a d167a95` вернул `FIXTURE_BEFORE_IMPL_RC=0`; на слабой реализации
`d167a95^` предъявлены красные контрпримеры:

```
bash fixtures/spawn_agent/red_gejt_javnogo_nomera.sh; rc=$?; printf 'SPAWN_RED_RC=%d\n' "$rc"
... гейт явного номера отсутствует ...
SPAWN_RED_RC=1
bash fixtures/check_staged/red_dver_po_tegu.sh; rc=$?; printf 'DOOR_RED_RC=%d\n' "$rc"
... дверь по тегу отсутствует ...
DOOR_RED_RC=1
bash fixtures/check_zones/red_priznanie_po_nomery_puti.sh; rc=$?; printf 'ZONES_RED_RC=%d\n' "$rc"
... признание судит тег ОКНА, не номер пути ...
ZONES_RED_RC=1
```

Зоны проверены первой-parent гранью каждого land-merge:

```
git show --first-parent --format='COMMIT %H' --name-only d167a95 5e03d91 4b5b691 c017a42 a20442d 94beb17 60a008f; rc=$?; printf 'RC=%d\n' "$rc"
```

Вывод содержит только `scripts/{next_id,spawn_agent,check_staged,check_zones}.sh`,
`fixtures/{check_staged,spawn_agent}/...` и `NABLIUDENIA_ARCHITECT.md` на
соответствующих гранях; это подмножество двух frozen `ЗОНА`-строк 023. Живое
окно подтверждено отдельно:

```
bash scripts/check_zones.sh .; rc=$?; printf 'RC=%d\n' "$rc"
... замороженных контрактов: 21 · объявленных авторов: 2 · коммитов в диапазонах: 519 · проверено по зонам: 355
RC=0
```

## И-1…И-7: собственные прогоны

`red_*` запускались по два раза после реализации (случайные непересекающиеся
входы выбирает сама фикстура); все шесть прямых запусков вернули `RC=0`:

```
bash fixtures/spawn_agent/red_gejt_javnogo_nomera.sh; rc=$?; printf 'RC=%d\n' "$rc"  # два прогона: RC=0, RC=0
bash fixtures/check_staged/red_dver_po_tegu.sh; rc=$?; printf 'RC=%d\n' "$rc"       # два прогона: RC=0, RC=0
bash fixtures/check_zones/red_priznanie_po_nomery_puti.sh; rc=$?; printf 'RC=%d\n'  # два прогона: RC=0, RC=0
```

```
git grep -n next_id_peek -- scripts/; rc=$?; printf 'RC=%d\n' "$rc"
RC=1
bash scripts/check_ids.sh .; rc=$?; printf 'RC=%d\n' "$rc"
  ok   номера уникальны и согласованы с регистром выдачи
RC=0
bash scripts/verify_antiplacebo.sh . --scope check_staged; rc=$?; printf 'RC=%d\n' "$rc"  # RC=0
bash scripts/verify_antiplacebo.sh . --scope check_zones; rc=$?; printf 'RC=%d\n'   # RC=0
bash scripts/verify_antiplacebo.sh . --scope spawn_agent; rc=$?; printf 'RC=%d\n'  # RC=0
```

Три scoped-прогона предъявили собственные повторные красные контроли; I-7
входит в два прямых прогона `red_priznanie_po_nomery_puti.sh` (его вход в6).
Эти зелёные результаты не снимают блокер: существующая spawn-фигура не
создаёт удалённый объект манифеста, отсутствующий локально.

## Косметика `94beb17`

**Класс: совет, не самостоятельный блокер.** `git diff --word-diff=plain
94beb17^ 94beb17 -- scripts/check_staged.sh` показывает не относящуюся к
исправлению замену комментария «Ветка» → «Ветва». Последний байт текущего
файла проверен отдельно:

```
stat -c '%n %s' scripts/check_staged.sh
scripts/check_staged.sh 29858
dd if=scripts/check_staged.sh bs=1 skip=29857 count=1 status=none | od -An -t x1
 22
```

То есть финального LF нет. Оба отклонения следует убрать в исправляющем
изменении, но они не меняют исполняемое поведение и не являются причиной
этого FAIL; область механизма `check_staged.sh` у `94beb17` разрешена frozen
зоной 023.

## Вне предмета

`check_hooks` не запускался и не классифицирован как дефект 023: известный
красный scoped-прогон относится к несведённой конверсии контракта 022, а не к
судимому предмету.
