ACCEPT

# Ревью 037 — второй круг: узкое подтверждение закрытия двух блокеров первого круга

Предмет: `contracts/037-samodostatochnyj-cwd-i-priemnik-task.md`, заморожен
`frozen/contracts/037/2` (tag-object `b09f389`).
Проверочный SSH-клон `ssh://git@github.com/a3ka/dev-harness.git`, свежий,
HEAD `8320f0eb49365c0aa18d7e6435e68290f77ba8b1` (совпал с основным чекаутом и с
`origin/main` на момент клонирования).

Круг **узкий**: судятся РОВНО два блокера `verdicts/review/contracts-037-v1.md`
(`9f01146`) — Р1 и Р2. Замечания О1–О8 того вердикта не блокировали и здесь не
переоткрываются.

Отчётам исполнителей не верил ни в одной точке: вся мутационная методика Р1
повторена МОЕЙ рукой в СВОЁМ клоне, ниже сырой вывод с кодами возврата.

---

## БЛОКЕР Р1 — ЗАКРЫТ

Требование первого круга было дословным: две различающие клетки в
`fixtures/self_contained_cwd/red_self_contained_cwd.sh` — вне-HOME и
`canonicalActual === HOME`, обе с ВАЛИДНЫМИ п.2/п.3/п.5/п.6, обе КРАСНЫЕ при
откате `20d821d`, предъявленные мутационным прогоном.

Поставлено `8c3608a` (author `user.name=architect`), ровно один файл,
`+58/-2`: `ORDER` расширен `8 → 10`, добавлены сетапы `P4BASE`/`HOMEBASE` и
клетки `п9`/`п10`. НИ ОДНА существующая клетка не тронута (сверено построчным
диффом — изменены только строка `trap`, строка `ORDER` и вставленные блоки).

### Замер 1 — реальный код

```
$ git rev-parse HEAD
8320f0eb49365c0aa18d7e6435e68290f77ba8b1
$ git status --short
(пусто)
$ bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 0, зелёных 10
fixture rc=0
```

### Замер 2 — МУТАНТ A: `20d821d` откачен ЦЕЛИКОМ

```
$ git revert --no-commit --no-edit 20d821d
$ git diff --cached --stat
 .omp/extensions/path-guard.ts | 12 ------------
 1 file changed, 12 deletions(-)

$ bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .
КРАСНОЕ 037: ветвь «п9» — ожидалось block, получено pass (вывод: {"decision":"pass"})
КРАСНОЕ 037: ветвь «п10» — ожидалось block, получено pass (вывод: {"decision":"pass"})
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 2, зелёных 8
fixture rc=1
```

Краснеют РОВНО п9 и п10; остальные восемь остаются зелёными — перекрёстных
срабатываний нет, откат `20d821d` не задевает ничего, кроме предмета своей
защиты.

### Замер 3 — возврат отката, повторный прогон на реальном коде

```
$ git reset --hard -q HEAD && git status --short
(пусто)
$ bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 0, зелёных 10
fixture rc=0
```

10/10 зелёных. Таблица первого круга перевёрнута:

| состояние кода | п9 | п10 | остальные 8 | итог фикстуры |
|---|---|---|---|---|
| реальный (`8320f0e`) | block | block | зелёные | 10/10 зелёных, rc 0 |
| `20d821d` откачен | **pass** ← дыра | **pass** ← дыра | зелёные | 2 красных, rc **1** |

Барьер теперь даёт РАЗНЫЙ ответ над исправленным кодом и над кодом с открытой
дырой. Это и есть то, чего первому кругу не хватало.

### Замер 4 — полумутанты: каждая клетка прижимает СВОЮ строку

Фикс `20d821d` состоит из двух отдельных предикатов. Удалял по одному
(`path-guard.ts:845` и `:846`), дерево восстанавливал между прогонами:

```
### МУТАНТ B — удалена ТОЛЬКО строка 845: if (canonicalActual === realHome) return false;
КРАСНОЕ 037: ветвь «п10» — ожидалось block, получено pass (вывод: {"decision":"pass"})
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 1, зелёных 9
rc=1

### МУТАНТ C — удалена ТОЛЬКО строка 846: if (!isWithin(realHome, canonicalActual)) return false;
КРАСНОЕ 037: ветвь «п9» — ожидалось block, получено pass (вывод: {"decision":"pass"})
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 1, зелёных 9
rc=1
```

Соответствие один-к-одному, без перекрытия:
`п10 ↔ canonicalActual === realHome`, `п9 ↔ isWithin(realHome, canonicalActual)`.

Этот замер попутно доказывает вторую половину требования — что у обеих клеток
п.2/п.3/п.5/п.6 ДЕЙСТВИТЕЛЬНО валидны. Если бы клетку отвергал какой-то иной
предикат (ровно механизм слепоты старой п4, описанный О1 первого круга), она
осталась бы зелёной и после снятия своей строки п.4. Обе дали `pass` — значит
до п.4 исполнение доходит и единственный отказчик — именно она.

### Замер 5 — база клеток ВНЕ scratch-allowlist

Ловушка названа явно в задании: база внутри `${TMPDIR:-/tmp}/dev-harness-verify`
дала бы `pass` от allowlist'а 025, и зонд не доказывал бы ничего. Мерил
буквальные пути трассировкой, не чтением комментариев:

```
$ echo "TMPDIR=[${TMPDIR-<unset>}]"
TMPDIR=[<unset>]
$ bash -x fixtures/self_contained_cwd/red_self_contained_cwd.sh . 2>&1 | grep -E "^\+{1,3} (P4BASE|P4OUT|HOMEBASE|HOME_ITSELF|VERIFY_BASE|NS|FAKEHOME_BASE)="
+ NS=/tmp/dev-harness-worktrees
+ FAKEHOME_BASE=/tmp/dev-harness-fakehome-037
+ VERIFY_BASE=/tmp/dev-harness-verify
+ P4BASE=/tmp/dev-harness-worktrees/pg037p4.FWqjgu
+ P4OUT=/tmp/dev-harness-worktrees/pg037p4.FWqjgu/m
+ HOMEBASE=/tmp/dev-harness-fakehome-037/pg037homeown.kerkOn
+ HOME_ITSELF=/tmp/dev-harness-fakehome-037/pg037homeown.kerkOn/self
```

`TMPDIR` не задан, поэтому все три базы разворачиваются в `/tmp`; базы п9 и п10
(`dev-harness-worktrees`, `dev-harness-fakehome-037`) не пересекаются с
`dev-harness-verify` ни префиксно, ни как-либо ещё.

Ловушка — не гипотеза: проверил её СВОИМ зондом, подав тот же shape кандидата
(самодостаточный репо, `.git`-каталог, `worktree list`==1, owner.json в
`dirname` с `id` == `sessionName`) при РАЗНОЙ базе, на РЕАЛЬНОМ коде:

```
РЕАЛЬНЫЙ КОД (HEAD, дерево чистое); HOME-override = /tmp/dev-harness-fakehome-037
база ВНУТРИ scratch-allowlist: {"decision":"pass"}
база п9 (ВНЕ allowlist):   {"decision":"block","reason":"запись в чекаут из непиннованной
  сессии запрещена — Н-85/А-122: путь /tmp/dev-harness-worktrees/probeR2/m/f.txt не в
  null-allowlist (/tmp/dev-harness-verify/**, artifact://)"}
```

Различие ТОЛЬКО в базе, ответ противоположный — ложный `pass` от allowlist'а
реален и в этой фикстуре не случился. Дополнительно: будь база внутри scratch,
клетки (ожидание `block`) были бы КРАСНЫМИ уже на реальном коде, и замер 1
никогда не дал бы 10/10. Ложный зелёный этим путём недостижим.

**Р1 закрыт.**

## БЛОКЕР Р2 — ЗАКРЫТ

Требование первого круга: адверсарий-круг по `20d821d` либо явное владельческое
решение. Поставлен круг.

Первая строка вердикта — моей мерой, не пересказом:

```
$ git cat-file -p HEAD:verdicts/adversary/contracts-037-m1-circle3.md | sed -n 1p
accept
```

Существенное — что судился ИМЕННО тот код, что лежит на HEAD. Сверено блобом:

```
$ git ls-tree -r 9f01146 -- .omp/extensions/path-guard.ts
100644 blob b6791de93a7c8b33209f6a5917f73bfa4b5694bf	.omp/extensions/path-guard.ts
$ git ls-tree -r HEAD -- .omp/extensions/path-guard.ts
100644 blob b6791de93a7c8b33209f6a5917f73bfa4b5694bf	.omp/extensions/path-guard.ts
$ git log -1 --format='%h %an %cI' -- .omp/extensions/path-guard.ts
20d821d implementer 2026-09-24T16:44:53+02:00
```

Адверсарий назвал `9f01146` своим базисом; блоб субъекта там тождествен
блобу на HEAD, и последняя правка субъекта — по-прежнему `20d821d`. Разрыв
«реализация менялась после последнего суда», который и составлял Р2, закрыт:
теперь ПОСЛЕДНИЙ адверсарий-круг судил ПОСЛЕДНЮЮ редакцию субъекта.

Содержательные требования к кругу выполнены и мною независимо воспроизведены:

- **база вне scratch** — вердикт называет `/tmp/adversary-037-circle3.fMfs5A`;
- **негативный контроль** — `outside_home_bypass=block`, `home_itself_bypass=block`;
- **позитивный контроль** — `legitimate_under_home=pass`, то есть «всегда block»
  как объяснение исключён.

Оба негативных сценария — те же, что в `5edeab8`. Я их перемерил своей рукой
(замеры 2–4 выше): на откаченном `20d821d` оба дают `pass`, на реальном коде —
`block`. Вывод адверсария моей мерой подтверждается.

**Р2 закрыт.**

---

## Проверки задания

**Текст контракта НЕ тронут.** Сверено блобом — не датой, не диффом, не пересказом:

```
$ git rev-parse frozen/contracts/037/2
b09f38908f42aad063c83bba2f136746d3873b09
-- блоб в теге --   100644 blob df46abda954b65ef2b8abe774eabf9e30715f818	contracts/037-...md
-- блоб на HEAD --  100644 blob df46abda954b65ef2b8abe774eabf9e30715f818	contracts/037-...md
-- блоб на 33bd665 (критик accept) -- 100644 blob df46abda954b65ef2b8abe774eabf9e30715f818
```

Три блоба тождественны. `df46abda` — тот же, что судил критик и что связан с
вердиктом первого круга. Правки текста под критерий 6 («норма не тронута молча»)
нет: в диапазоне `f966955..HEAD` не изменён ни один файл `contracts/` и ни один
`roles/`.

**Область правки не превышена (критерий 1).** Весь диапазон — четыре коммита,
каждый ровно об одном файле:

```
8320f0e architect   NABLIUDENIA_ARCHITECT.md                          | 23 +
8c3608a architect   fixtures/self_contained_cwd/red_self_contained_cwd.sh | 58 +/2 -
9153eef adversary   verdicts/adversary/contracts-037-m1-circle3.md    | 32 +
9f01146 reviewer    verdicts/review/contracts-037-v1.md               | 268 +
```

`scripts/check_zones.sh .` даёт rc 1 при РОВНО двух строках FAIL:

```
FAIL коммит вне зоны: implementer 80e1ea84 fixtures/parsing_hygiene_battery/profiles/check_precision_gate.sh
FAIL коммит вне зоны: implementer 8766e769 contracts/043-precizionnyj-prefriz-gejt.md
```

Обе — предмет 043, чужой; побайтово те же две, что были в первом круге. Ни один
новый коммит пачки зону не нарушил; по 037 строка `ok`.

**Критерий 3 (проверка не подогнана автором реализации).** `8c3608a` —
`user.name=architect`; субъект `path-guard.ts` писал `implementer`. Авторы
различны, `check_zones.sh` их различает именно по `user.name`. Клетки написаны
после реализации — это неизбежно для пост-фактум прижатия, которого я сам
потребовал; выкупается замером 4: клетки красны против сломанной реализации и
каждая против СВОЕЙ строки.

**Критерий 5 (атомарность).** Три новых коммита — три отдельные задачи в трёх
коммитах; связок нет. Откат `8c3608a` снимает ровно прижатие п.4 и ничего
более.

## Приёмочные критерии — мои прогоны на HEAD

```
### Р1  bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .
ИТОГ 037 (self-contained-cwd): ветвей 10, красных 0, зелёных 10               rc=0
### Р2  bash fixtures/accept_task_commit/red_accept_task_commit.sh .
ИТОГ 037 (accept_task_commit): ветвей объявлено 7, прогнано 7, красных 0, зелёных 7  rc=0
### Р3  grep -Fq 'accept_task_commit.sh' roles/orchestrator.md                 rc=0
### Р6  bash scripts/check_threat_model.sh . contracts/037-*.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))  rc=0
### Р7  bash scripts/check_provodka.sh . contracts/037-*.md                    rc=0
### Р8  bash fixtures/parsing_hygiene_battery/run_battery.sh accept_task_commit
БАТАРЕЯ accept_task_commit: итог 4/4 классов закрыто                          rc=0
```

Р4/Р5 первого круга (`check_runner_hygiene` 31/31, `pin_allowlist`,
`granica_nepin_pipe_tee`, `strazh_vectora_utechki`) не перемерял: их субъекты в
диапазоне `f966955..HEAD` не изменялись ни одним байтом (весь диапазон — четыре
файла выше), и перемер не мог бы дать новой информации.

## Находки ВНЕ двух блокеров

Искал специально. Нового БЛОКЕРА не нашёл. Одно замечание:

- **О9 (прослеживаемость коммита; класс: замечание, не блокер).** Сообщение
  коммита `9153eef` — одно слово `accept`, без ссылки на предмет. Критерий 5
  требует «свой коммит со ссылкой на предмет»; здесь ссылка держится
  ИСКЛЮЧИТЕЛЬНО путём файла (`verdicts/adversary/contracts-037-m1-circle3.md`),
  поэтому прослеживаемость фактически сохранена и отказа не вызывает. Но
  `git log --oneline` по этому коммиту предмета не называет. Называю, не вменяю.

Отдельно подтверждаю чистоту фикстуры как артефакта: `trap` расширен на
`P4BASE`/`HOMEBASE`, после пяти моих прогонов остатков не осталось
(`ls -d /tmp/dev-harness-worktrees/pg037p4.* /tmp/dev-harness-fakehome-037/pg037homeown.*
/tmp/dev-harness-fakehome-037/pg037home.*`
→ `No such file or directory` по всем трём маскам). Сетапы п9/п10 не делят
каталогов со старыми клетками — независимость красноты подтверждена замером 4.

## Вердикт

**ACCEPT.** Оба блокера первого круга закрыты и закрытие проверено моей
собственной мутационной методикой, а не отчётами:

- **Р1** — прижат. Откат `20d821d` целиком красит п9 И п10 (rc 1), возврат
  отката даёт 10/10 зелёных (rc 0); полумутанты показывают соответствие
  клетка↔строка один-к-одному и попутно доказывают валидность п.2/п.3/п.5/п.6
  в обеих клетках; базы обеих клеток буквально вне `/tmp/dev-harness-verify`,
  ложный `pass` от scratch-allowlist исключён и проверен контрольным зондом.
- **Р2** — закрыт. Последний адверсарий-круг `accept` и судил блоб субъекта
  `b6791de`, тождественный блобу на HEAD.

Текст контракта не тронут (`df46abda` в теге, на HEAD и у критика — один блоб),
зоны не нарушены, атомарность соблюдена, норма не правлена. Замечания О1–О8
первого круга и О9 этого не блокируют.

Вердикт связан с блобом контракта `df46abda954b65ef2b8abe774eabf9e30715f818`
(`frozen/contracts/037/2`), блобом субъекта
`b6791de93a7c8b33209f6a5917f73bfa4b5694bf` и деревом `8320f0e`; новая редакция
любого из них этого принятия не наследует.

Спора нет, арбитр не требуется.

— reviewer, второй круг
