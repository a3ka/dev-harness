FAIL

# Review PR#97 `wip/104/implementer2`, контракт 104 «узкий доверенный гейт судьи» (land-v4, круг 4, узко: закрытие Рв97-19/20)

Находки с чекбоксами — в `.review/2026-10-15-10.md` (prev: `.review/2026-10-15-09.md`). Вердикт круга 3:
`verdicts/review/contracts-104-land-v3.md` (FAIL: Рв97-19, Рв97-20). Вердикт адверсария круга 3
(`verdicts/adversary/contracts-104-land-v3.md`, ACCEPT) действует и здесь не пересматривается.

МОДЕЛЬ судьи: `anthropic/claude-opus-5-5` (reviewer, тир audit). Вывод предыдущих попыток по этому предмету не
использовался. Всё ниже — мой прогон в одноразовом клоне.

**Субъект.** PR#97, голова `9cc284c659a91efd75dc60ee7856b9f8ecff668d` (force-push оркестратора после круга 3).
Одноразовый SSH-клон `/tmp/dev-harness-verify/rev104r4/repo`, origin/main `c0eba52f`. Worktree: `../tip`, `../mainwt`,
`../base`, `../land`, `../alt`. Скрипт `../sim_land.sh`: ленд `merge --no-ff` в базу, конфликт разрешается стороной
ветки, затем реестровая замена `104 → <tag-object>` коммитом `orchestrator freeze: registry 104 → …` и полный
`check_zones.sh` без `--incr`. Основной чекаут не трогал, push не делал.

## 1. Топология — merge-коммитов нет (Рв97-19 закрыт)

```
$ git log --format='%h P:%p A:%an C:%cn %s' 'frozen/contracts/104/1^{commit}'..9cc284c6
9cc284c6 P:4790d0da A:architect    C:architect    NABLIUDENIA_ARCHITECT: А-918 … (cherry-pick -x 1600daea)
4790d0da P:8cd920aa A:orchestrator C:orchestrator 104: nudge CI …
8cd920aa P:4117f3d4 A:architect    C:orchestrator 104 architect: А-917 …
4117f3d4 P:355653fe A:architect    C:orchestrator 104 architect: Рв97-3 / A104-1 …
355653fe P:e906e707 A:orchestrator C:orchestrator 104 orchestrator: честная identity …
e906e707 P:59f26b53 A:implementer  C:orchestrator 104 implementer: потолок персоны …
59f26b53 P:ed837823 A:implementer  C:orchestrator 104 implementer: узкий доверенный гейт судьи …
ed837823 P:452f682b A:architect    C:orchestrator 104: fixtures/zashchita_main_104 …
$ git rev-list --parents 'frozen/contracts/104/1^{commit}'..9cc284c6 | awk '{print NF-1}' | sort | uniq -c   → 8 × «1»
$ git rev-list --merges  'frozen/contracts/104/1^{commit}'..9cc284c6 | wc -l                               → 0
$ git merge-base --is-ancestor frozen/contracts/104/1 9cc284c6                                              → rc=0
```
Коммиты `ed837823…4790d0da` — те же SHA, что в круге 3. Синков `a4fab6fa`, `821127c2`, `b442d7ac` в ветке нет.
Новый коммит один, `9cc284c6`.

Цена круга 3 измерена той же мерой — полным check_zones:
```
origin/main c0eba52f (голый)          : FAIL строка ЗОНА вне грамматики contracts/055-… (самотест) ; check_zones RC=0
ленд 9cc284c6 + реестр 104→73a85203   : merge КОНФЛИКТ NABLIUDENIA_ARCHITECT.md → разрешён стороной ветки
                                        (итог файла == ветка: да); тег-коммит предок результата rc=0;
                                        FAIL-набор = базе (diff пуст) ; check_zones RC=0
                                        (коммитов в диапазонах 12572→12731, проверено по зонам 2704→2819)
```
Шести путей `a4fab6fa` (ROADMAP.md, docs/owner/…, fixtures/ops_server/…, ops/server/root/orch-peak) больше нет. Рв97-19
закрыт по построению. Внешний долг n283 п.(1)+(2) на голом main своей мерой не виден: строк `7ed4a89c`/`868d386f` нет,
RC=0, grandfather `1734b890` работает. Ни 104, ни базе он не приписан.

## 2. Строки владельца — их нет вовсе (Рв97-20 закрыт)

```
$ git diff --stat 4790d0da 9cc284c6                                     → NABLIUDENIA_ARCHITECT.md | 21 ++++…-  (1 файл)
уставные пути по коммитам диапазона (AGENTS.md|ROADMAP.md|contracts/|plans/|roles/):
  ed837823 —  59f26b53 roles/orchestrator.md  e906e707 roles/orchestrator.md  355653fe —  4117f3d4 —  8cd920aa —  4790d0da —  9cc284c6 —
$ git log --grep='РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' 452f682b..9cc284c6 | wc -l        → 0
строк '^[+-].*РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' в патчах диапазона                   → 0
```
roles/orchestrator.md правят только содержательные `59f26b53`/`e906e707`, SHA у них прежние, принято в кругах 1–3.
К уставу в смысле правила 11 он не относится. Переноса нет, значит, нет и фабрикации.

## 3. Содержание предмета не изменилось

`git patch-id --stable`, своя мера, против таблицы круга 3:
```
452f682b 0a65ac67131a = | ed837823 aaffebaefc40 = | 59f26b53 d4ac439e2276 = | e906e707 0016d3d4aab7 =
355653fe 5b079d719088 = | 4117f3d4 046082d376e9 = | 8cd920aa 9ba088820878 =       (все 7 — те же SHA, что в b442d7ac)
9cc284c6 025081b60671 ≠ 1600daea 6816558c1476  (Рв97-22: лишнее удаление одной пустой строки)
```
Вторая мера — набор и блобы файлов PR. `git diff --name-only 8c3f34ca...b442d7ac` и `origin/main...9cc284c6` — по 32 файла,
`diff` наборов пуст. `git diff --stat b442d7ac 9cc284c6 -- <32 файла>` → `NABLIUDENIA_ARCHITECT.md | 2 --`: две пустые
строки, остальные 31 блоб равны. Блоб контракта на голове = блоб тега = `e4b1e185`.

## 4. Батарея 104

`reslop t -- bash fixtures/_krasnye_104.sh` в `../tip` → `ok: true, passed: 39, failed: 0`, exit 0. Сырой лог:
```
стаб-пак: 17/17 поймано
ЗЕЛЕНО: red_huk_alfavit_ustanovki / red_huk_bez_ustanovochnogo_konfiga / red_huk_task_spavna /
        red_judge_gate_svidetelstvo_sudi / red_sud_model_dver_spavna / red_sud_model_materializatsija
клеток просмотрено: 6
ИТОГ 104: rc=0
```
Своя мера: уникальных `t104-m* пойман` в логе — 17, уникальных `t104-m*` в `fixtures/zashchita_main_104/` — 17,
`red_*.sh` в git — 6.

## 5. Рв97-21 — PR снова CONFLICTING (регресс Рв97-13, новый блокер)

```
$ gh pr view 97 --json headRefOid,mergeable,mergeStateStatus
{"headRefOid":"9cc284c659a91efd75dc60ee7856b9f8ecff668d","mergeStateStatus":"DIRTY","mergeable":"CONFLICTING"}
$ git merge-tree --write-tree --name-only origin/main 9cc284c6
CONFLICT (content): Merge conflict in NABLIUDENIA_ARCHITECT.md                       rc=1
$ gh api repos/a3ka/dev-harness/commits/9cc284c6…/check-runs --jq .total_count       → 0
$ gh run list --branch wip/104/implementer2 --limit 1                                 → последний прогон headSha b442d7ac
$ bash scripts/check_ci_gate.sh   (в ../tip)                                          → «ОТКАЗ: коммит 9cc284c659a9 не на origin/main — CI по нему не запускался; запушь и дождись прогона», rc=1
```
Механика конфликта. merge-base ветки и main — `60d82e94`. В `60d82e94..origin/main` хвост NABLIUDENIA_ARCHITECT.md правят
`5370ad51` (А-915/916) и `1600daea` (А-918). В `60d82e94..9cc284c6` его правят `8cd920aa` (копии А-915/916 + А-917) и
`9cc284c6` (А-918). Пробельное выравнивание в `9cc284c6` сделало файл ветки равным «main + 11 строк А-917». Но обе стороны
пишут в один хвост от общей базы, поэтому остаётся ханк `<<<<<<< HEAD` (пусто) `=======` (А-917) `>>>>>>>`. Cherry-pick
А-918 убрал лишь часть расхождения. Конфликт порождает А-917, которой нет на main. Линейная ветка от `452f682b` (Рв97-12)
не может содержать main без merge-коммита.

Это блокер. GitHub ленд не пропускает. По голове не запущен ни один check-run, так что гейт шага 4б («судью не звать,
пока CI не зелёный») на этой голове недостижим в принципе. В круге 3 я закрыл Рв97-13 своей мерой (MERGEABLE,
merge-tree rc 0). Пересборка открыла его снова. Класс другой, чем у Рв97-19/20.

Содержательно разрешение тривиально, и я его проверил: сторона ветки = main + А-917. Ленд-симуляция с таким
разрешением даёт check_zones RC=0 (§1). Блок механический, к содержанию 104 претензии нет.

Формы закрытия, обе проверены своей мерой:
- **(а)** architect коммитит в main запись А-917 в том виде, в каком она лежит на ветке. Симуляция в клоне:
  синтетический коммит `1cfc404c` = origin/main + блоб NABLIUDENIA_ARCHITECT.md из 9cc284c6 (`+11` строк, author architect).
  ```
  $ git merge-tree --write-tree --name-only 1cfc404c 9cc284c6          → 13eabc78…, rc=0
  sim_land.sh 9cc284c6 alt 1cfc404c : merge: чисто ; тег-коммит предок rc=0 ; FAIL-набор = базе ; check_zones RC=0
  ```
  Ветка не переписывается, patch-id не меняются, merge-коммитов и строк `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` нет: Рв97-19/20
  остаются закрытыми по построению.
- **(б)** настоящий двухродительский merge origin/main в ветку (форма `3aaa445a` круга 3) с тем же разрешением.
  Он вернёт в диапазон ROADMAP.md из main, а с ним и обязанность переносить строки владельца байт-в-байт, то есть
  риск Рв97-20.

Выбор формы — за оркестратором. После любой из них: MERGEABLE, свежий зелёный CI на голове, сверка patch-id.

## 6. Рв97-22 — провенанс cherry-pick (совет)

```
1600daea  A:architect 13:52:08  C:orchestrator 13:52:08
9cc284c6  A:architect 13:52:08  C:architect    18:45:40   «(cherry picked from commit 1600daea…)»
$ git range-diff 1600daea^! 9cc284c6^!   → + удаление пустой строки перед «### А-915» (выравнивание с main)
```
По заданию пересборку выполнял оркестратор, а в committer записан architect. Патч отличается от заявленного
источника, и тело об этом молчит. check_zones судит по author, и для перенесённой записи author architect верен.
Изменение чисто пробельное. Поэтому это совет, не блок, того же семейства, что Рв97-16.

## Атомарность / область

Содержательные коммиты 1:1 по SHA и patch-id. Новый коммит один, `9cc284c6`: журнальная запись main, без
104-содержания. Пустой `4790d0da` по-прежнему в ленте (Рв97-18).

## ПРОВОДКА (038)

С круга 3 не менялась: guard `fixtures/_krasnye_104.sh` подключается после ленда (Рв97-7). Блоб role-канала
`roles/orchestrator.md` равен кругу 3 (среди 31 равного блоба §3).

## Паразитная сложность (050) — артефакты круга 4

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `9cc284c6` (cherry-pick А-918) | свежесть ветки к main в NABLIUDENIA_ARCHITECT.md (Рв97-13) | явное, обычный коммит; патч ≠ источнику (Рв97-22) | 0 | — | цель не достигнута: PR остаётся CONFLICTING | ACCIDENTAL, совет: свойство «PR сливаем» не дано, а более простая форма (а) даёт его без этого коммита. Не блок, потому что блок предъявлен отдельно как Рв97-21 |

## Итог

| находка | класс | блок |
|---|---|---|
| Рв97-19 | топология: merge-коммитов в диапазоне 0, полный check_zones на ленде RC=0, FAIL-набор = базе | закрыт [x] |
| Рв97-20 | провенанс слова владельца: строк `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в диапазоне 0, уставные пути не тронуты | закрыт [x] |
| Рв97-21 | механика ленда, регресс Рв97-13: PR CONFLICTING/DIRTY (NABLIUDENIA_ARCHITECT.md, ханк А-917), 0 check-runs на голове | **да** |
| Рв97-22 | провенанс cherry-pick `9cc284c6`: committer architect, патч ≠ 1600daea на пустую строку | нет (совет) |
| Рв97-15/16/17/18 | без изменений с круга 3 | нет |
| Рв97-7 | ПРОВОДКА после ленда | нет (до done) |
| n283 п.(1)+(2) | на голом main закрыт grandfather `1734b890` (своя мера RC=0) | внешний, не 104 |

Узкая задача круга выполнена: Рв97-19 и Рв97-20 закрыты по построению, каждый своей мерой. Содержание предмета
тождественно принятому, батарея 104 rc=0. FAIL ставлю из-за нового блокера другого класса. Голова 9cc284c6 не
сливается с main, и по ней не запускается CI. Это механика, не содержание, и закрывается она формой (а) без
переписывания ветки.

Арбитр. Это четвёртый круг ревьюера по 104, а AGENTS.md («три круга по одному предмету») требует созыва. Спора с
автором по Рв97-21 нет: конфликт объективен, и автор вправе закрыть его правкой. Поэтому рекомендую оркестратору
созвать арбитра не по существу 104, а по вопросу, нужен ли пятый круг ревьюера на ту же голову после формы (а). Голова
при форме (а) не меняется, и тогда достаточно механической сверки MERGEABLE + зелёный CI + check_zones RC=0, без
нового круга суда.
