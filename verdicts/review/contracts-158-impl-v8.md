accept
OBJECT=1321ae6c334a6d56ee52c706197783605e8a3b22
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness; предмет=158; фаза=реализация (перелэнд r7 по frozen/contracts/158/4; PR #697); роль=reviewer; вызов=9 — scoped-повтор вызова 8 после обрыва сессии Rev158v8 без вердикта (предмет до 2026-10-24 — прежний порядок, предел вызовов не применяется; маршрут арбитража verdicts/arbitration/158-ikonka-b7-b8.md шаг 5); модель-план=anthropic/claude-opus-5-5; сессия=Rev158v9; модель-факт=anthropic/claude-opus-5-5; SHA=1321ae6c334a6d56ee52c706197783605e8a3b22 (tip wip/158/implementer-r7 = refs/pull/697/head); предыдущий=verdicts/review/contracts-158-impl-v7.md (FAIL @b7c08e926, единственный блок Б-10); исключение=нет
НЕЗАВИСИМОСТЬ: автор OBJECT — implementer (3 коммита, minimax/MiniMax-M3); судья — reviewer, кода не правил. Прогоны — в одноразовом клоне `/tmp/dev-harness-verify/Rev158v9/repo` (worktree `run` @OBJECT, detached; worktree `merge` = origin/main + OBJECT, только для замера CI-ключа; вердикт — worktree `verdict`).
НАХОДКИ: в тексте вердикта (каталог .review/ вне зоны reviewer по ЗОНА 158). Блоков нет. Б-10 закрыт. Наблюдение О-2 (orchestrator, CI). Советы С-13, С-17 (implementer), С-18, С-19 (architect) — открыты, без изменений с вызова 7.

## Вердикт

accept. Единственный блок вызова 7, Б-10, закрыт. Четвёртый коммит `b7c08e92` снят из истории.
Переменных `NABOR_158_REF_CLEAN`/`NABOR_158_MOB_REF` в дереве OBJECT нет. Если их задать, это
ничего не меняет: `REFERENSI` и `istochnik_ref_clean()` возвращают канонические корни. Дерево
набора, гейта и ноги побайтово равно `4087b83b` — коммиту C, на котором вызов 7 прогнал всю
приёмку. Три коммита r7 при перебазировании не изменились: range-diff даёт `=` по всем трём,
patch-id суммы совпадает. Недостающие в вызове 8 прогоны `--repo` на обоих референсах я
выполнил сам на OBJECT, оба дали 80/80 и rc 0.

CI PR #697 на OBJECT красный в одном джобе, `legkij`, по ключу `check:contract-frozen`. Причина
лежит вне диффа предмета: см. О-2. Реализацию это не блокирует. Перед лэндом нужен зелёный CI
на перебазированном head.

СВЕРКА-СТАНДАРТОВ: не применимо. Дифф в харнесе dev-harness (`fixtures/` и `scripts/`), а
документов `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` продуктового бэкенда он не
касается. Референсы mob-ref и ref-clean только читались.

ПРОВОДКА (038): guard `fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh` —
дверь именно этого предмета, побайтово равная тегу 158/4 (п.3). Вызов 7 отметил, что CI-шаг 158
не подключён. Это окно оркестратора freeze..done, дельта r7 его не меняет.

## Пункты задания — сырой вывод

Клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev158v9/repo`,
`git fetch origin wip/158/implementer-r7 wip/158/reviewer --tags`. Прежний OBJECT
`b7c08e926b2c…` получен по sha с origin, его родитель `4087b83befb65483cf44a202bce920467941fc44`.
W = `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`,
`env | grep -c '^NABOR_158'` → 0.

```text
$ git rev-parse origin/wip/158/implementer-r7   → 1321ae6c334a6d56ee52c706197783605e8a3b22 (= OBJECT = refs/pull/697/head)
```

### (1) Б-10 — переменных окружения нет, и задать их нельзя

```text
$ git grep -n 'NABOR_158_REF_CLEAN\|NABOR_158_MOB_REF' HEAD   → (пусто) grep rc=1
$ ls …/nositeli/ref-clean-provennost.md                       → No such file or directory
$ find …/ekrannyj_nabor_158/nositeli -type f | wc -l          → 9 (носитель провенанса снят вместе с b7c08e92)
$ git show --name-only b7c08e92 → nositeli/ref-clean-provennost.md, probe.py; blob в HEAD == blob в 4087b83b по обоим → same, same
реплей D-1:
$ NABOR_158_REF_CLEAN=/tmp/dev-harness-verify/Impl158Refs2/ref-clean NABOR_158_MOB_REF=/tmp/x python3 -c 'import probe; print(probe.REFERENSI, probe.istochnik_ref_clean())'
REFERENSI= [('ref-clean', '/tmp/dev-harness-verify/Arch147t/ref-clean', 'model/karta-ref-clean.json'), ('mob-ref', '/tmp/dev-harness-verify/Arch148t/mob-ref', 'model/karta-mob-ref.json')]
istochnik_ref_clean()= /tmp/dev-harness-verify/Arch147t/ref-clean
rc=0
$ grep -n environ probe.py → :330, :349 (окружение подпроцессов), :756, :1050 NABOR_158_TOY_ROOT
```

`NABOR_158_TOY_ROOT` — не новая переменная. Она объявлена в SPEC §6A как внутренний путь клеток
и есть уже в `2089cede` (`probe.py:752`, `:798`, `:810`, `:1046`). Её судили вызовы 6 и 7, так
что Б-10 она не касается.

### (2) Дерево набора равно 4087b83b, три коммита те же

```text
$ git diff --stat 4087b83b..HEAD -- fixtures/workshop_project/ekrannyj_nabor_158/ scripts/check_trek_ekrana.sh scripts/pre_critic.sh → (пусто)
$ git diff --quiet …  → rc=0
tree набора 4087b83b = 917d4505e590a4ded2de2452ac04778aad39a1af = HEAD
check_trek_ekrana.sh 4343b6b2… = 4343b6b2…;  pre_critic.sh e9885c70… = e9885c70…
$ git log --oneline origin/main..HEAD   (merge-base 8aff93c7e763126ba1e9104b3329b1aae5742547)
1321ae6c 158: ветка цели-иконки — a11yNadpis с условием «нет Text вообще», клетки f34–f39, st14, мутаторы
96ad962e 158: гейт трека экрана и нога (д3) двери критика — одним коммитом
4da2e4bc 158: батарея ekrannyj_nabor_158 по SPEC 158/4 — без ветки цели-иконки
$ git range-diff 1c017a3c^..4087b83b HEAD~3..HEAD
1:  1c017a3c = 1:  4da2e4bc
2:  6c280bed = 2:  96ad962e
3:  4087b83b = 3:  1321ae6c
diffstat old/new:  A 63 files +6942 | 63 files +6942;  B 2 files +81 | 2 files +81;  C 10 files +509 −20 | 10 files +509 −20;  сумма 70 files +7512 | 70 files +7512
patch-id --stable: 1dfd8c8a453662c0300ff385b4fd1ba5b2b7c7b0 (1c017a3c^..4087b83b) = 1dfd8c8a453662c0300ff385b4fd1ba5b2b7c7b0 (HEAD~3..HEAD)
авторы: implementer <implementer@dev-harness.local> ×3
зона: git diff --name-only 8aff93c7e HEAD → v_zone=70 vne_zony=0 (каталог набора + scripts/check_trek_ekrana.sh + scripts/pre_critic.sh)
```

Атомарность (Б-9) сохраняется: три задачи маршрута лежат тремя коммитами, и в каждом сообщении
есть ссылка на предмет. Маршрут арбитража, шаг 4 («ровно тремя коммитами»), теперь выполнен
буквально.

### (3) Frozen 158/4 не тронут

```text
$ git diff --quiet 'frozen/contracts/158/4^{commit}' HEAD -- contracts/158-ekrannyj-nabor.md fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh → rc=0
contracts/158-ekrannyj-nabor.md                                 955a49e67fe4c23879a7a022d261d1cfa68de891 = 955a49e6…
fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md            b38a075437b4a714ab66a1b1433a16541e644078 = b38a0754…
fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh 72a6cc9bbbfd2393e1597699d69842870e24632e = 72a6cc9b…
```

### (4) Исполнение на OBJECT (worktree `run`)

```text
$ bash -n red_ekrannyj_nabor_158.sh → rc=0;  bash -n scripts/check_trek_ekrana.sh → rc=0;  bash -n scripts/pre_critic.sh → rc=0
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md → «ТРЕК ЛЁГКИЙ (по умолчанию)» rc=0
$ python3 …/samoopisanie/samoopisanie.py
{"kletok": 80, "nositelej": 45, "piny": 7, "roditel": "ea02f1b5…", "stabov": 14, "svjazej": 30}  rc=0
вторая мера (source.json, не вывод батареи):
kejsy 80 {'a': 14, 'b': 7, 'c': 5, 'd': 3, 'e': 2, 'f': 39, 'g': 8, 'z': 2}
stab 14 svjazi 30;  st14 → f36, f37, f38, f39
$ W --repo /tmp/dev-harness-verify/Arch148t/mob-ref   (HEAD 6b5ef760f1a68ebab37391cb1ec9c46982846394)
… a01…a14, z01, z02, b01…b07, c01…c05, d01…d03, e01, e02, f00…f39 (без f09), g01…g08 — все ok
клеток 80, зелёных 80, красных 0
wall 615 s   rc=0
$ W --repo /tmp/dev-harness-verify/Arch147t/ref-clean (HEAD cc38881a59215ce430c962ae799f76743a4ae9ce)
… a01…a14, z01, z02, b01…b07, c01…c05, d01…d03, e01, e02, f00…f39 (без f09), g01…g08 — все ok
клеток 80, зелёных 80, красных 0
wall 634 s   rc=0
```

Чем заменены прогоны, которых я не повторял. Вызов 8 (Rev158v8) докладывает на тех же байтах
OBJECT `W` 40/40, `--model` 37/37 и `--stabs` 37/37 с SVJAZI 30. Вызов 7 получил тот же
результат на `4087b83b` своими прогонами: `W` 40/40 за 399 с, `--model` 37/37 за 386 с,
`--stabs` 37/37, 14 стабов, SVJAZI 30 за 542 с, `--oracle-tamper` rc 2. Повторно я их не гнал.
Замена держится на двух фактах. Во-первых, дерево набора, гейт и нога побайтово равны
`4087b83b` (п.2, diff пуст, tree 917d4505). Во-вторых, вне этих путей дифф предмета ничего не
меняет (vne_zony=0). Счёты 80/14/30 я перепроверил своей мерой: самоописание плюс
`source.json`. `--repo` на обоих референсах прогнан мной, на OBJECT, последовательно и с
`timeout 1500`.

### (5) CI PR #697 на OBJECT — О-2

```text
$ gh pr view 697 → OPEN, head wip/158/implementer-r7 @ 1321ae6c334a6d56ee52c706197783605e8a3b22
$ gh api …/actions/runs/42920028636 → run_attempt 2, conclusion failure, head_sha 1321ae6c…
16 джобов: legkij FAIL; tyazhelyj-itog, obshchij, klass, ci l1–l7, antiplacebo ap1–ap5 — success; vorota — skipped
legkij (attempt 2), лог --log-failed:
  incr: check_charter полный прогон (база b7c08e92 не предок HEAD 1321ae6c — кеш сторонней линии)
  FAIL contracts/162-standart-koda-mob.md изменён без новой заморозки: на HEAD блоб ce10f196…, в заморозке v3 — c9ba833a…
  FAIL contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md изменён без новой заморозки: на HEAD блоб b6a7109b…, в заморозке v1 — ae4ad828…
  lane: отказ ключа check:contract-frozen (rc=1)
```

Причина — не `missing-remote` attempt 1, а другая. OBJECT основан на main `8aff93c7e`. После
этой основы на origin вышли заморозки, которых в основе нет: `frozen/contracts/184/1`
(23:03:28Z), `162/3` (23:15:47Z) и `187/1` (23:46:59Z). Коммиты всех трёх тегов — предки
origin/main `52d3a3a1`, но не предки основы (`merge-base --is-ancestor`: inBase=no,
inMain=yes). На HEAD ветки поэтому лежат старые блобы этих контрактов, а гейт сверяет их с
новыми тегами. Дифф предмета контрактов не касается:
`git diff --name-only origin/main...HEAD -- contracts/ | wc -l` → 0.

Свои замеры:

```text
@OBJECT (worktree run):   /bin/bash scripts/check_contract_frozen.sh → FAIL 162 (v3), FAIL 184 (v1), FAIL 187 (v1, тег вышел после attempt 2)  rc=1
@merge origin/main 52d3a3a1 + OBJECT (worktree merge, 1e747462, слияние без конфликтов):
  git diff --quiet 1321ae6c HEAD -- <набор, trek, pre_critic> → rc=0
  /bin/bash scripts/check_contract_frozen.sh → «планов и контрактов на HEAD: 174 · черновиков: 9 · заморожено: 165 · реестр: full», FAIL нет  rc=0
```

- [ ] **О-2 (orchestrator; CI; не блок реализации).** `legkij` на OBJECT красный из-за
  устаревшей основы ветки относительно заморозок 162/3, 184/1 и 187/1. Дифф 158 тут ни при чём.
  Перед лэндом перебазируй `wip/158/implementer-r7` на текущий main и получи зелёный `legkij`
  на новом head. Перебазирование несемантическое по §«Последний судья после реализации»: оно
  не меняет поведения, критерия и границы риска. Доказательство на новом head — `git range-diff`
  с тремя `=` против `1321ae6c` и пустой `git diff 1321ae6c <new> -- <набор, trek, pre_critic>`.
  Тогда accept переносится на новый head без нового суда. Если в перебазировании будет
  что-то кроме этого, accept к нему не применяется.

### (6) Находки .review/2026-11-09-94.md и вердикта v7

`.review/2026-11-09-94.md` на OBJECT равен файлу на origin/main (`git diff --quiet` rc 0).
Каталог `.review/` вне зоны reviewer, поэтому статусы ведутся здесь:

- [x] Б-10 — закрыт (п.1, п.2).
- [x] Б-8 — закрыт в вызове 7. Код ветки иконки равен `4087b83b` (п.2), регресса нет; f34–f39
  ok на mob-ref (п.4).
- [x] Б-9 — закрыт, три коммита (п.2).
- [x] С-15, С-16 — закрыты в вызове 7 клетками f38 и f39, обе ok на обоих референсах (п.4).
- [x] С-7 — закрыт (a14 в SPEC 158/4 §6A; a14 ok, п.4).
- [x] О-1 — закрыт revert'ом `8ce8808a` (вызов 7).
- [ ] С-13 (совет, implementer) — открыт. `nositeli/mob-ref-provennost.md:29,31` ссылается на
  `/tmp/dev-harness-verify/scratch158/…`, а `ls` этого пути даёт «No such file or directory».
  Рецепт сборки mob-ref по-прежнему лежит вне дерева. Носитель ref-clean, на который опирался
  вызов 7 как на образец, снят вместе с `b7c08e92`, так что образца в дереве теперь нет.
- [ ] С-17 (совет, implementer) — открыт: `zond/nabor-zond-158.test.tsx:136-137` по-прежнему
  ставит `A11Y_IMJA_PUSTOE` пустой `nadpis` текстовой цели.
- [ ] С-18, С-19 (советы, architect, SPEC §6F) — открыты, без изменений с вызова 7: сравнение без
  trim; дочернее имя не заменяет имя хозяина. По Н-39 клетки к ветвям привязывает architect.
- С-1, С-8 (architect) — вне дельты маршрута, не переоткрываю.

## Паразитная сложность (контракт 050) — дельта 4087b83b → OBJECT

Дельта пуста (п.2): новых и раздутых артефактов нет. Артефакт, который вызов 7 признал
ACCIDENTAL (`REFERENSI` с двумя читаемыми env, `probe.py:132-139`), снят. Вместе с ним снят
носитель `nositeli/ref-clean-provennost.md`. Пять вопросов по артефактам A/B/C отвечены в
вызове 7 и остаются в силе, потому что байты те же.

## Ограничения этого вызова

- `W`, `--model` и `--stabs` повторно не гонялись. Чем они заменены — сказано в п.4.
- Полный `check_zones.sh` не запускался по заданию. Зона проверена по списку путей (п.2,
  vne_zony=0).
- CI на перебазированном head не существует: это шаг оркестратора (О-2).
