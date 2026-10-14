accept — дельта лендинга 093 v4 верна по содержимому. l4 (`a4f02c245`, origin/main) добавляет в `excuse_for()` ровно две подписанные владельцем grandfather-пары, больше ничего: `check_protected` rc 1 → rc 0. l5 (`054953ce`, `dba029a1`, `e0b454c3`, `af75e0f4` на `origin/wip/093/architect-v4` @ `af75e0f4`) — побайтное восстановление двух коммитов, уже судимых кругом 5 (`4c967a72`), плюс чистый merge и правка одного значения PIN. Батарея 085: 17 → 1 → 0 красных. Контракт не менялся, CI PR#91 12/12. Блокирующих находок нет. Шесть неблокирующих (Рв6-1…Рв6-6) — в `.review/2026-10-14-01.md`; Рв6-2 и Рв6-6 — вопросы владельцу.

# Review 093, круг 6 — дельта лендинга v4 (l4 + l5)

МОДЕЛЬ: `anthropic/claude-opus-5-5` (семейство anthropic). По брифу дельту делал оркестратор.
Своей модели он в коммитах не назвал, коммиты подписаны identity architect/implementer — см. Рв6-6.

**Субъект.** `origin/main` @ `a4f02c245f074e349d126bd49c49e5c534ceb3cd`,
`origin/wip/093/architect-v4` @ `af75e0f44d88195495617e152ccd6798ce53cb10` (= `headRefOid` PR#91).
Тег `frozen/contracts/093/4` → коммит `e47816784c5a`.
**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/rev093v5/clone`
(`git clone ssh://git@github.com/a3ka/dev-harness.git`). Рабочее дерево проверок:
`/tmp/dev-harness-verify/rev093v5/wt`.
**Слот.** Бриф назвал `contracts-093-v5.md`, но этот слот уже занят: `6945111a reviewer 2026-10-13 …
093 круг 5 accept`, есть на origin/main и на ветке. Свободен `v6`. Других `contracts-093-v6/v7`
нет ни на одном remote-ref (проверено `git ls-tree` по всем refs).
**Предмет.** Только дельта. Контракт 093 v4 и вердикты v1..v5 повторно не судились.

## Сырой вывод (свои команды, коды возврата)

### l4 — `a4f02c245`

```
$ git show --stat a4f02c245
 scripts/check_protected.sh | 27 +++++++++++++++++++--------      (1 file)
A:implementer <implementer@dev-harness.local>  C:implementer  P:0b550011
$ git log -1 --format=%B a4f02c245 | sed -n 1p | sha256sum
755ef6b636c8389071dfe173c5f912cfe7c91c81e910809c282444366c287ffe
$ sed -n 59p verdicts/consultant/n093-check-protected-grandfather-rename-gap-v1.md | sha256sum
755ef6b636c8389071dfe173c5f912cfe7c91c81e910809c282444366c287ffe   # строка-кандидат = строка в коммите, 1201 байт
```

Дифф кода (вне комментария) — одна новая ветка `case`:

```
+      2ac0f5f2e7250bf90cd4569a1b52bf03f188f32d)
+        case "$p" in
+          verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-klass-v1.md|verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-v1.md)
+            return 0 ;;
+        esac ;;
```

Шесть прежних пар, `moved_for`, `is_lagging_merge_artifact`, грамматика ALLOW и merge-оракул
не тронуты: hunk `@@ -537,6 +543,11 @@` — чистая вставка, второй hunk — только комментарий.
Это ровно то, что разрешает строка владельца: «РОВНО две пары … без изменения шести прежних пар,
грамматики ALLOW, moved_for, merge-оракула». SHA и оба пути совпадают с этой строкой побайтно.

```
$ git show -M --name-status 2ac0f5f2e7250bf90cd4569a1b52bf03f188f32d
R097 verdicts/consultant/fork-093-v2c-…-klass-v1.md → verdicts/consultant/n093-v2c-…-klass-v1.md
R095 verdicts/consultant/fork-093-v2c-…-v1.md       → verdicts/consultant/n093-v2c-…-v1.md
```

Исторический коммит удаляет ровно эти два пути, переименование с правкой (R097/R095). Поэтому
`moved_for` их не прощает.

**Красное → зелёное (своя мера):**

```
$ git checkout 0b550011 && bash scripts/check_protected.sh          # родитель a4f02c245
  FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-klass-v1.md
  FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-v1.md
  … исчезло: 2 · с разрешения: 77 · перенесено: 20
rc=1
$ git checkout origin/main(a4f02c245) && reslop t -- bash scripts/check_protected.sh
ok: true  passed: 99  failed: 0
  ok   исчез с явного разрешения: verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-klass-v1.md
  ok   исчез с явного разрешения: verdicts/consultant/fork-093-v2c-otkrytie-i-a908-razreshenie-v1.md
  … коммитов пройдено: 4367 · существовало: 937 · на HEAD: 838 · исчезло: 0 · с разрешения: 79 · перенесено: 20
exit: 0
```

Разрешённых стало 77 → 79 (+2), остальные счётчики не изменились. Других прощённых путей не
появилось.

**Маршрут.** `git log --first-parent origin/main`: `a4f02c24 ← 0b550011 ← f762bf35`. Один родитель,
не merge, лёг fast-forward прямо в first-parent main. `ЗОНА implementer: scripts/check_protected.sh`
объявлена в 039:128, 040:524 и 083:403. Тот же патч ранее шёл PR-маршрутом: `c0146ee3` (PR#92) —
`git patch-id --stable` обоих = `a3febfad19d4…`, sha256 тела у обоих = `32c02120…`. `gh pr checks 92`
→ 12 pass. Сам PR#92 до сих пор `OPEN` (Рв6-1). Отступление от маршрута 069 по содержимому
обосновано: патч совпадает побайтно, CI на PR#92 зелёный, строка владельца есть. Ссылка брифа на
прецедент неверна (Рв6-2).

### l5 — восстановление на `wip/093/architect-v4`

```
$ git log --first-parent --format='%h %an | C:%cn %cd | P:%p' 204dc901..origin/wip/093/architect-v4
af75e0f4 architect | C:architect 2026-10-14 11:02:25 | P:e0b454c3
e0b454c3 architect | C:architect 2026-10-14 10:53:44 | P:dba029a1 a4f02c24
dba029a1 implementer | C:implementer 2026-10-14 10:39:50 | P:054953ce
054953ce architect | C:architect 2026-10-14 10:39:21 | P:204dc901
```

Ровно 4 коммита first-parent. Плоский `git log 204dc901..` показывает больше: туда попадают
коммиты main, пришедшие через merge `e0b454c3` — `a4f02c24`, `0b550011`, `f762bf35`, `72528660`,
`2c32235a`, `0a065c17`, `3f8ebd42`, `8bcfda26`, `e021ed75`, `3432d339`, `e305c0d2`. Это база, не
дельта.

**`054953ce` против `3ce90ebc`, фикстура 085:**

```
$ diff <(git show 3ce90ebc -- fixtures/ops_server/red_cikl_perezapuska_085.sh) <(git diff 054953ce~1 054953ce -- …085.sh); echo $?
0
sha256 обоих диффов: 4146f5070033c25c1572e596f32605011192cdea50cfbae6aa147991eb6c1ef4 (вместе со строкой index)
тела сообщений: sha256 f0745841… = f0745841…; автор architect 2026-10-11 14:52:59 сохранён
$ git show --stat 054953ce → только fixtures/ops_server/red_cikl_perezapuska_085.sh (261+/79-)
```

`3ce90ebc` добавлял в `NABLIUDENIA_ARCHITECT.md` +7 строк (запись А-392). В `054953ce` из них не
вошло ничего (`--stat`: 0 строк). Содержимое уже лежало в базе: 5 из 5 строк тела записи найдены
на `204dc901` дословно (`grep -cxFf` → 5), это запись А-411 на строке 8098. Заголовок отличается
только номером и суффиксом-адресом очереди автономности.
`git diff 204dc901 af75e0f4 -- NABLIUDENIA_ARCHITECT.md` пуст. Разрешение конфликта как @ours
корректно.

**`dba029a1` против `31731eec`, `ops/server/user/orch-loop`:**

```
$ git diff dba029a1~1 dba029a1 -- ops/server/user/orch-loop
-    for _ in 1 2 3 4 5 6; do sleep 5; pgrep -P "$loop_pid" >/dev/null || exit 0; done
-    pkill -KILL -P "$loop_pid"; exit 0
+    for _ in 1 2 3 4 5 6; do sleep 5; pgrep -P "$loop_pid" -f '^omp --profile' >/dev/null || exit 0; done
+    pkill -KILL -P "$loop_pid" -f '^omp --profile'; exit 0
```

Четыре строки, два изменения — те же, что в первом hunk `31731eec`. Второй hunk `31731eec`
(убрать `shift &&` из `exec sudo -nu`) на базе уже не нужен:
`git grep -c 'shift &&' af75e0f4 -- ops/server/user/orch-loop` → 0 совпадений. Строка 150 —
`… : >"$1" && HOME="$2" exec sudo -nu "$3" "$4" …`, off-by-one уже закрыт более поздним кодом.
То, что эта часть не вошла, — не регрессия. Тема коммита при этом вводит в заблуждение (Рв6-3).

**`e0b454c3` (merge origin/main):** `git show --remerge-diff e0b454c3` → пусто, merge чистый.
Дифф против второго родителя по `scripts/` пуст: `check_protected.sh` взят ровно с main.

**`af75e0f4` (PIN 074):**

```
$ git show --stat af75e0f4 → fixtures/ops_server/red_server_obvjazka_074.sh | 2 +- (1 file)
-  ['user/orch-loop']='1b4e70f5…ed24f2d'
+  ['user/orch-loop']='e45f1874…59a34d837'
$ git show origin/wip/093/architect-v4:ops/server/user/orch-loop | sha256sum
e45f187468a26c0ae88f468b0567a8c3ca8328a5ea404a6ae0704de59a34d837
```

Изменилось одно значение. Оно равно sha256 файла-субъекта, клетки и логика не тронуты. Это
покрывает санкция №4 (`git show 03ca150d:HANDOFF.md` §«Стоячая санкция №4»: «синхронизация PIN
и строк снимков ops/server в батареях 074 и 085 … только значения … исполнитель — architect»).

Батарея 074, своя мера:

```
$ fixtures/_krasnye_074.sh @e0b454c3  → КРАСНО: cell_k1, cell_k5, cell_k5b, диффпроба cell_k1 ×2; итог 074: красных клеток=5 стабы=7/7
$ fixtures/_krasnye_074.sh @af75e0f4  → КРАСНО: cell_k5b; итог 074: красных клеток=1 стабы=7/7
$ fixtures/_krasnye_074.sh @204dc901  → КРАСНО: cell_k5b; итог 074: красных клеток=1
$ fixtures/_krasnye_074.sh @a4f02c24  → КРАСНО: cell_k5b; итог 074: красных клеток=1
```

`cell_k5b` — дрейф живой станции (`k5b: станция /home/harness/.local/bin/orch-loop разошлась с
пином`). Красна так же на базе и на main, в CI пропускается (`red_server_obvjazka_074.sh:476`).
К дельте не относится.

**Сверка с деревом, которое судил круг 5.** `3ce90ebc` и `31731eec` — предки
`4c967a7210e0` (субъект `contracts-093-v5.md`):
`git merge-base --is-ancestor` → оба предки. `git diff 4c967a72 af75e0f4 --stat -- ops/ fixtures/ops_server/`
→ 1 файл: `red_server_obvjazka_074.sh`, 1+/1-. Изменилась только строка комментария-заголовка
пинов, значения PIN совпадают. Субъект `ops/server/*` и батарея 085 на `af75e0f4` побайтно равны
тому, что принял круг 5.

### Батарея 085, полный прогон на `af75e0f4`

```
$ bash fixtures/ops_server/red_cikl_perezapuska_085.sh     # @af75e0f4
085: orch-loop e45f1874, orch-peak 88d84e5b; режим full
… зелено: р0 р1 р2 л1…л10 п1…п4 п5[warn] п5[ctx550000] п5[ctx650000] п5[stop] п6…п11 м1…м6
стаб-пак: 39/39 поймано, диффпроба: 31/31
итог 085: красных=0, стабы=39/39, диффпроба=31/31
BATTERY_RC=0
```

Свой подсчёт (`grep -c` по артефакту вывода): строк `зелено:` — 33, `КРАСНО` — 0,
`стаб sNN пойман` — 39, `НЕ ПОЙМАН` — 0. `п5[stop]` зелёная, флейка в моём прогоне не было.

**Красное перед зелёным (своя мера):**

```
@204dc901 (база, без обоих восстановленных) → итог 085: красных=17, стабы=39/39, диффпроба=31/31; RC=1
@054953ce (только заглушки 3ce90ebc)       → КРАСНО: р2 — пропала строка снимка 34: … pgrep -P "$loop_pid" -f '^omp --profile' …
                                               итог 085: красных=1; RC=1
@af75e0f4                                   → красных=0; RC=0
```

Каждый из двух восстановленных коммитов снимает свою часть красного. `3ce90ebc` даёт 16 из 17,
`31731eec` — последнюю, р2 (`-f` в цикл-паттерне).

### Контракт и барьеры на ветке

```
$ git show origin/wip/093/architect-v4:contracts/093-….md | git hash-object --stdin
fa105574cbbc883ad6dbd1029b252286923e8746
$ git show frozen/contracts/093/4:contracts/093-….md | git hash-object --stdin
fa105574cbbc883ad6dbd1029b252286923e8746
$ reslop t -- bash scripts/check_contract_frozen.sh        # @af75e0f4
ok: true passed: 95 failed: 0
  ok contracts/093-granica-ispolneniya-i-postavka-ops.md — заморожен v4, блоб совпадает побайтово, вердикты v1..v4 разрешают
exit: 0
$ reslop t -- bash scripts/check_zones.sh                  # @af75e0f4
ok: true passed: 82 failed: 0
замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 11545 · проверено по зонам: 3207
exit: 0
```

`check_zones` печатает строку `FAIL строка ЗОНА вне объявленной грамматики в contracts/055-…` при
rc 0. На `origin/main` (`a4f02c24`) — та же строка и тот же rc 0. Это наблюдение вне дельты, см.
`.review`.

### CI PR#91 (своя команда)

```
$ gh pr checks 91        → 12 строк, все pass (run 38553981036): ap1..ap5, l1..l7
$ gh pr view 91 --json headRefOid,mergeStateStatus → af75e0f44d88…, CLEAN, MERGEABLE
$ gh api repos/a3ka/dev-harness/actions/runs/38553981036 → head_sha af75e0f4…, run_attempt 2, conclusion success
$ gh api …/runs/38553981036/jobs?filter=all
  attempt 1: 11 success + «ci (l5 …)» failure
  attempt 2: 12/12 success
```

Перезапуск был, на попытке 1 упал только l5. Мой локальный прогон 085 на том же sha дал 0
красных. Флейк на попытке 1 этим не опровергнут и не подтверждён: в 085 есть тайминг-клетки
(`п5`, `п6…п10`), а лог попытки 1 я не читал. [INFERENCE] Это единичный флейк, не дефект дельты.

### Область правки

```
$ git diff frozen/contracts/093/4..origin/wip/093/architect-v4 --stat -- . ':!NABLIUDENIA_ARCHITECT.md'
HANDOFF.md | 123 · fixtures/ops_server/red_cikl_perezapuska_085.sh | 340 · fixtures/ops_server/red_server_obvjazka_074.sh | 4
forks/n093-check-protected-grandfather-rename-gap.md | 59 · forks/n093-cikl085-oracle-stale-pgrep-filter.md | 91
ops/server/user/orch-loop | 4 · scripts/check_protected.sh | 27 · verdicts/consultant/n093-…(4 файла) | 30+97+50+207
verdicts/critic/contracts-093-v3.md | 145
```

В списке брифа нет трёх путей. Атрибуция по `git log frozen/contracts/093/4..wip -- <путь>`:
- `HANDOFF.md` — orchestrator, `e305c0d2`/`3432d339`/`3f8ebd42`/`f762bf35` (02:08–03:49), пришёл
  через main/merge. Зона orchestrator, с дельтой не связан.
- `verdicts/critic/contracts-093-v3.md` — critic, `204dc901` (02:18, восстановление слота v3), до дельты.
- `fixtures/…/074.sh`, 4 строки: 2 — `477c8f84` (architect 02:18, прошлая сессия), 2 — `af75e0f4`.
- `forks/n093-*` и `verdicts/consultant/n093-*` — orchestrator/consultant, 02:27–03:49
  (`e021ed75`, `8bcfda26`, `0a065c17`, `2c32235a`, `72528660`). В 10:45 добавлены только строки
  ОТВЕЧЕНО (`0b550011`, 12+/2-).

`install.sh`, README и другие зоны implementer не тронуты. Дельта этой сессии (10:36–11:02)
затрагивает ровно `scripts/check_protected.sh`, `fixtures/ops_server/red_cikl_perezapuska_085.sh`,
`ops/server/user/orch-loop`, `fixtures/ops_server/red_server_obvjazka_074.sh` и `forks/n093-*`
(строки ОТВЕЧЕНО).

### Форки на main

Оба ответа — `ОТВЕЧЕНО: да`: `n093-check-protected-grandfather-rename-gap.md:55`,
`n093-cikl085-oracle-stale-pgrep-filter.md:85`. По существу оба совпадают с фактом:
- 2 пары, 1201 байт, rc 0 — подтверждено выше;
- 3ce90ebc и 31731eec восстановлены с авторством architect/implementer, 085 rc 0 — подтверждено выше;
- «диагноз НЕ orchagent-провизионинг» подтверждён моими 17 → 1 → 0.

Две неточности: ленд-коммит назван `c0146ee3`/PR#92 (Рв6-1), и в 31731eec приписана часть
off-by-one (Рв6-4).

## Вердикт по пунктам роли

1. **Область правки** — в границах, см. «Область правки».
2. **Сырой вывод** — выше, все команды мои.
3. **Проверка не переписана под реализацию.** `054953ce` — побайтная копия фикстуры, которую
   принял круг 5. `af75e0f4` меняет только значение PIN, равное sha256 субъекта.
4. **Красное предъявлено.** `check_protected`: rc 1 на `0b550011` → rc 0. 085: 17 → 1 → 0.
   074: 5 → 1 (k5b — станция).
5. **Атомарность.** l4 — один коммит, один файл. l5 — два восстановленных коммита с авторством
   и сообщениями оригиналов, merge, pin-коммит. Каждый откатывается отдельно.
6. **Норма не тронута.** `contracts/`, `roles/` и `docs/owner/` в дельте не менялись. Блоб 093
   равен блобу на теге.
7. **Заявленное равно сделанному.** Пересчитано своими командами: 39/39, 31/31, 0 красных,
   12/12, 2 пары, rc. Расхождения с текстом брифа и форков вынесены в Рв6-1…Рв6-4.

## Паразитная сложность (050) — по артефактам дельты

- **Ветка `case 2ac0f5f2e…` в `excuse_for()`** (раздутая функция).
  (1) Свойство — неизменяемая история при честном grandfather (контракт 046, ветвь 1).
  (2) Нового состояния нет: статический литерал виден в коде и в выводе
      («исчез с явного разрешения: <путь>»).
  (3) При следующей правке меняются вместе 1 файл и 2 места (ветка case и список в комментарии),
      как и до диффа.
  (4) Интерфейс (аргументы, коды возврата, env) не вырос.
  (5) Потребители — `check:protected` в CI (l4, ap4). Механизм повторяет существующий паттерн
      шести пар.
  ESSENTIAL: без пары l4 красный, а `moved_for` не применим, потому что контент изменён (R095/R097).
- **`-f '^omp --profile'` в `pgrep`/`pkill`** — правка существующих строк, новой сущности нет.
  ESSENTIAL: р2 085 и смысл свойства — не трогать чужих детей цикла.
- **Значение PIN 074** — данные, не артефакт. ESSENTIAL: на `e0b454c3` `cell_k1`/`cell_k5`
  красные без этой правки.
- Фикстура 085 (+261/-79) — не новый артефакт этой дельты, а восстановление `3ce90ebc`. Её
  сложность судил круг 5 (субъект `4c967a72` содержит этот коммит). Повторно не сужу.

ACCIDENTAL-находок нет.

## Находки

Файл: `.review/2026-10-14-02.md` (status: ready; слот -01 занят ретро-вердиктом `a4f02c245`, переименовано при rebase поверх `560b64806`). Блокирующих нет. Неблокирующие:

- **Рв6-1 (orchestrator, учёт — ЗАКРЫТО этой же сессией).** Форк называл ленд-коммитом `c0146ee3`/PR#92.
  На main лёг `a4f02c245` — тот же патч после rebase. PR#92 закрыт оркестратором с комментарием
  (`gh pr close 92`), ссылка на фактический sha оставлена в комментарии закрытия.
- **Рв6-2 (вопрос владельцу, маршрут 069).** Прецедент «direct-commit `b237251fd`/`007bac12b`»
  своей мерой ложен: оба вошли через land-merge (`c4bd709a`, `d22e8a2b`). `a4f02c245` — первый
  прямой не-merge ff в first-parent main для этой правки. На доверие к содержимому это не
  влияет: тот же патч прошёл CI PR#92 12/12.
- **Рв6-3 (orchestrator, история).** Тема `dba029a1` объявляет два дефекта, в диффе один (`-f`).
  Off-by-one был закрыт на базе раньше.
- **Рв6-4 (orchestrator, учёт).** Форк `n093-cikl085…:89` приписывает восстановлению часть
  off-by-one.
- **Рв6-5 (implementer, косметика защищённого файла).** `check_protected.sh:465` — «— 3 пары»,
  а на `:478` того же блока — «Восемь пар».
- **Рв6-6 (вопрос владельцу, атрибуция).** По брифу дельту делал оркестратор, но новые коммиты
  `e0b454c3` и `af75e0f4` (не cherry-pick) несут identity `architect`, и в теле это не раскрыто.
  Санкция №4 называет исполнителем architect. `check_zones` различает исполнителей только по
  `user.name`. Это класс замера 4 арбитража `reglament-ispolnitel.md`: риск неотличимости должен
  быть записан прямо, и этот вердикт его записывает. Содержимое обоих коммитов проверено
  механически (remerge-diff пуст, PIN = sha256 субъекта), поэтому для слияния PR#91 находка не
  блокирующая. Отдельно: слово владельца от 2026-10-14 ~10:50 в `docs/owner/` не сохранено. Его
  след в репо — только строка РАЗРЕШИЛ в `a4f02c245` и пересказ в ОТВЕЧЕНО форков.
