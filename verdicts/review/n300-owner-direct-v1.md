accept

# Review Н-300 (б), круг 1: исключение owner-direct коммитов из окна check_consumers

МОДЕЛЬ: `anthropic/claude-opus-5-5` (семейство anthropic). Фикс написал консультант под identity owner.

**Предмет.** Коммит `5e7f77a874b7b27eb0cb71568a8a37ef8d44e8f7` (author=committer=`owner <owner@dev-harness.local>`,
родитель `a73aad36699a8a9d3cc06d94b65d14d4be4f19b5`), `scripts/check_consumers.sh` +12/−0. Коммиты окна
`frozen/contracts/<n>/<v>..HEAD`, у которых `%an == owner` и `%cn == owner`, добавляются в множество исключённых
(`_excl_tmp`) так же, как коммиты чужих лендов. Основание — слово владельца
`forks/n-105-konsultant-i-n300-batch.md:26-27`: «вариант (б) — check_consumers.sh исключает из окна прямые
коммиты канала владельца (author = committer = owner); правку делает консультант быстрым путём, затем один
круг ревьюера; после её ленда — done_contract 105». Контекст — `NABLIUDENIA.md` `### Н-300`.

Находки (reslop) — секция «Находки (reslop)» в конце этого файла. Блокеров нет, советов пять (Рв300-1..5),
наблюдений вне предмета три (Рв300-6..8). Отдельным файлом `.review/2026-10-16-11.md` они не легли:
pre-commit `check_staged.sh` в чистом клоне на main ответил `ОТКАЗ: вне зоны: .review/2026-10-16-11.md`
(у owner-direct предмета нет контракта, а значит и ЗОНА-строки reviewer с `.review/`). Перенести их в
`.review/` может оркестратор: блок ниже уже в reslop-форме, с frontmatter.

## Суд по вопросам задания

- **(а) Н-300 закрыт без ослабления реальной защиты: ДА.** Писатель, тронутый коммитом НЕ owner/owner в
  окне, по-прежнему даёт rc 1 дословной фразой. Проверено живьём для трёх писателей-минимумов и для
  смешанного окна (owner-коммит, затем коммит architect). Подмена одной стороны identity (owner/architect,
  architect/owner, `Owner` с заглавной) даёт rc 1. Мутант «исключать всё» ловят обе постоянные батареи.
  Дыра для чужих коммитов не вакуумная. Граница «committer тоже owner» постоянной клеткой не закреплена
  (Рв300-1, совет).
- **(б) 105 разблокирован: ДА.** `done_contract.sh` 105 на origin/main `8f3a89e4f` в одноразовом клоне
  дал rc 0 и поставил `done/contracts/105/1` (локальный тег; удалён, клон выбрасывается). На базе
  `a73aad366` — rc 1, фраза Н-300.
- **(в) Регрессий на соседних барьерах нет.** Scoped-прогоны до и после побайтово одинаковы (`diff`
  → IDENTICAL по всем четырём логам).

## Гейт по пунктам роли

1. **Область правки.** Один файл, `scripts/check_consumers.sh`, 12 добавленных строк
   (`git diff --numstat` → `12 0 scripts/check_consumers.sh`). Это совпадает со словом владельца. В
   этом же быстром пути ничего больше не тронуто.
2. **Сырой вывод.** В коммите есть пересказ с rc, а сырой файл автора `/tmp/dev-harness-verify/n300-probe.out`
   лежит вне истории. Я перепрогнал всё сам, сырой вывод ниже.
3. **Проверки не переписаны.** Фикстуры и батареи коммит не трогает (дифф — один скрипт).
4. **Красное предъявлено.** Новой запрещающей ветви нет: правка ослабляет окно. Оставшуюся защиту
   красным предъявил автор (контроли 1–2), и я предъявил её независимо (3, 4, 4b, 4e, mixed, lib, done).
   Новая die-ветвь отказа `git log` красной не показана (Рв300-5, совет).
5. **Атомарность.** Один коммит, одна задача, ссылка на Н-300 и на слово владельца.
6. **Норма не тронута.** Ни один нормативный документ или контракт не изменён. Расхождение механизма с
   И-1 замороженного 062 явно разрешено словом владельца (быстрый путь вместо микроконтракта из
   кандидата (б) Н-300). Названо как совет Рв300-2.
7. **Счётные утверждения своей мерой.**
   - «+12» — `--numstat` 12/0. Совпадает.
   - «пакет A, шесть скриптов» (3e0713700) — `git show --stat` → 6 files. Совпадает. Попутно:
     3e0713700 трогает ДВУХ зарегистрированных писателей (`freeze_contract.sh` и `done_contract.sh`),
     Н-300 назвал первого, на котором упала проверка.
   - «check_consumers 1/1, done_contract 1/1, freeze_contract 15/15» — подсчёт `ok`-строк вывода
     verify_antiplacebo: 1 / 1 / 15, итог раннера «барьеров: 3 · фикстур: 17 · предъявлено красным: 17».
     Совпадает.
   - «_krasnye_038 rc=1 «37 расхождений (режим ожидания rc=1)», так же на базе» — совпадает
     (`итог: 37 файлов, расхождений 37 (режим ожидания rc=1)` до и после). Но CI использует режим
     `EXPECT_RC=0`, в нём 0 из 37 до и после (Рв300-8).

## Живые проверки (сырой вывод)

Клон: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/rev-n300-1792184572/repo`,
`git fetch origin 'refs/tags/*:refs/tags/*'`. Писатели consumers.d:

```
scripts/done_contract.sh	scripts/check_spec_ready.sh
scripts/freeze_contract.sh	fixtures/check_check_contract_ready/
scripts/freeze_contract.sh	fixtures/drill_contract_change/
scripts/freeze_contract.sh	scripts/spawn_agent.sh
scripts/lib_registry.sh	scripts/check_spec_ready.sh
scripts/lib_registry.sh	scripts/spawn_agent.sh
```

**(1) До правки** (`git checkout a73aad366`; `bash scripts/check_consumers.sh "$PWD" contracts/105-lanuncher-politika-proekta.md`):
```
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc(1)=1
```
**(2) После правки** (`git checkout 5e7f77a87`, та же команда):
```
rc(2)=0
```
**(3)/(4) Контроли поверх 5e7f77a87.** Каждый — отдельная ветка с одним коммитом `# probe` в писателя,
identity задана `GIT_AUTHOR_*`/`GIT_COMMITTER_*`, затем та же команда:
```
  4bead9b6 an=architect <architect@dev-harness.local> cn=architect <architect@dev-harness.local>
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[3-nonowner]=1
  85cb9bde an=owner <owner@dev-harness.local> cn=architect <architect@dev-harness.local>
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[4-author-owner-committer-architect]=1
  0bf768e3 an=architect <architect@dev-harness.local> cn=owner <owner@dev-harness.local>
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[4b-author-architect-committer-owner]=1
  97869b01 an=owner <owner@dev-harness.local> cn=owner <owner@dev-harness.local>
rc[4c-owner-direct]=0
  eb7040c5 an=owner <evil@x> cn=owner <evil@x>
rc[4d-name-owner-foreign-email]=0
  2f73ab2c an=Owner <owner@dev-harness.local> cn=Owner <owner@dev-harness.local>
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[4e-capitalized-Owner]=1
  2e60087b an=architect <a@x> cn=architect <a@x>
потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[mixed-owner-then-architect]=1
  715f960e an=implementer <i@x> cn=implementer <i@x>
потребители 116: писатель scripts/lib_registry.sh изменён, потребитель scripts/check_spec_ready.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[lib-nonowner]=1
  d169684a an=critic <c@x> cn=critic <c@x>
потребители 116: писатель scripts/done_contract.sh изменён, потребитель scripts/check_spec_ready.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc[done-nonowner]=1
```
(`mixed` = ветка 4c (owner/owner) + коммит architect поверх. Исключается только owner-коммит, коммит
architect судится. 4d — Рв300-3.)

**(5) done_contract 105** (одноразовый клон, локальный тег):
```
$ git checkout --detach a73aad366 && bash scripts/done_contract.sh contracts/105-lanuncher-politika-proekta.md "review n300 probe до правки"
done: потребители 116 красны: потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
rc(5-before)=1
$ git checkout --detach origin/main   # 8f3a89e4f
$ bash scripts/done_contract.sh contracts/105-lanuncher-politika-proekta.md "review n300 probe после правки"
rc(5-after)=0
$ git for-each-ref 'refs/tags/done/contracts/105/'
refs/tags/done/contracts/105/1 tag 8f3a89e4f1e6c9c7e9c11c3ad6209ec3b4ae290f
$ git tag -d done/contracts/105/1
Deleted tag 'done/contracts/105/1' (was b7e59541)
```

**(6) Scoped-регресс** (worktree `wt-before`=a73aad366 и `wt-after`=5e7f77a87):
```
[before] k038 EXPECT_RC=0 rc=0
[before] k038 EXPECT_RC=1 rc=1
[before] krasnye_062 rc=0
[before] antiplacebo scope rc=0
[after] k038 EXPECT_RC=0 rc=0
[after] k038 EXPECT_RC=1 rc=1
[after] krasnye_062 rc=0
[after] antiplacebo scope rc=0
== k038_e0: diff before/after
IDENTICAL
== k038_e1: diff before/after
IDENTICAL
== k062: diff before/after
IDENTICAL
== ap: diff before/after
IDENTICAL
```
Команды: `EXPECT_RC=0 bash fixtures/_krasnye_038.sh` (= `check:provodka-family-selftest` CI);
`bash fixtures/_krasnye_038.sh`; `bash fixtures/check_consumers/krasnye_062.sh`
(= `check:consumers-window-family-selftest`);
`bash scripts/verify_antiplacebo.sh --scope check_consumers done_contract freeze_contract`. Хвосты после правки:
```
итог: 37 файлов, расхождений 0 (режим ожидания rc=0)
итог: 37 файлов, расхождений 37 (режим ожидания rc=1)
062: честных клеток 8, зелёных 8, красных: нет
062: стабов 6, поймано 6, ускользнуло: нет
итог 062: rc=0
барьеров: 3 · фикстур: 17 · предъявлено красным повторным прогоном: 17
```

**Чувствительность батарей к новой ветви** (мутанты в `wt-after`, не закоммичены, откачены):
```
[author_only] krasnye_062 rc=0
[author_only] k038 EXPECT_RC=0 rc=0
[exclude_all] krasnye_062 rc=1
[exclude_all] k038 EXPECT_RC=0 rc=1
```
→ Рв300-1.

## Паразитная сложность (контракт 050)

Артефакт один: блок исключения owner/owner в п2 `check_consumers.sh` (захват `git log`, die-ветвь, awk-фильтр).
(1) Свойство: слово владельца Н-300(б) — исключить прямые коммиты канала владельца из окна чужого контракта.
Замороженное свойство 062 И-1 этим блоком сужается по прямому разрешению владельца (Рв300-2).
(2) Состояние: новых файлов и env нет. Строки дописываются в уже существующий `_excl_tmp`, который
потребляется через `comm -23`. Состояние явное в пределах п2, в вывод не попадает. Это та же форма, что у
чужих лендов.
(3) Файлов, меняющихся вместе: 1 (скрипт). Текст 062 при следующей правке грамматики окна теперь тоже надо
менять, и это расхождение уже существует (Рв300-2).
(4) Глубина: интерфейс не изменился — аргументов, флагов, env и кодов возврата не прибавилось. Новая
die-ветвь использует существующую фразу. Модуль не измельчал.
(5) Потребители: `done_contract.sh` шаг 6а и CI-шаги `check:provodka-family-selftest` и
`check:consumers-window-family-selftest`. Литерал `owner` повторяет предикат `.githooks/pre-push:314`
(`%an`), но проверка строже (`%an` и `%cn`). Второй проход `git log` по уже добытому `rev-list`-диапазону
можно было бы слить с первым одним `--format=%H%x09%an%x09%cn`, однако выигрыш мизерный и строки приёмки
не меняются.
Итог: **ESSENTIAL** — более простая форма, которая проходила бы контроли 3/4 и разблокировала 105, не названа.

## Классы находок

| ID | Класс | Блокирует |
|---|---|---|
| Рв300-1 | полнота батареи (граница committer не закреплена) | нет, совет |
| Рв300-2 | расхождение механизма с текстом замороженного 062 И-1, разрешено владельцем | нет, совет |
| Рв300-3 | identity только по имени (известный предел, прецедент pre-push) | нет, совет |
| Рв300-4 | охват не только main-direct (буква слова владельца соблюдена) | нет, вопрос владельцу |
| Рв300-5 | die-ветвь без красного прогона (fail-closed) | нет, совет |
| Рв300-6 | Н-300 не помечен закрытым | вне предмета |
| Рв300-7 | ошибка родителя в задании ревьюеру | вне предмета |
| Рв300-8 | автор сообщил режим k038, отличный от CI | вне предмета |

Вердикт привязан к блобу `scripts/check_consumers.sh` = `aa981b9cec1e2c718d7e94d023ff282b612bd49b` (коммит `5e7f77a87`). Новая редакция файла это
принятие не наследует.

## Находки (reslop)

```markdown
---
status: ready
subject: ревью owner-direct фикса Н-300 (вариант «б») — scripts/check_consumers.sh, исключение коммитов author = committer = owner из окна судимых
object: 5e7f77a874b7b27eb0cb71568a8a37ef8d44e8f7
parent: a73aad36699a8a9d3cc06d94b65d14d4be4f19b5
verdict: verdicts/review/n300-owner-direct-v1.md (accept)
reviewer: reviewer (Opus, anthropic; автор фикса — консультант под identity owner)
addressee: оркестратор — блокеров нет; ниже советы
---

# Н-300 (б), owner-direct фикс check_consumers.sh: находки

Прогоны: одноразовый клон `/tmp/dev-harness-verify/rev-n300-1792184572/repo` (origin
`ssh://git@github.com/a3ka/dev-harness.git`, теги загружены), worktree `wt-before` (a73aad366)
и `wt-after` (5e7f77a87). Сырой вывод — в вердикте.

## Блокеры

нет.

## Советы (не блокируют)

- [ ] **Рв300-1 (граница исключения не закреплена постоянной клеткой).** Тоевые репозитории
  батарей коммитят как `Fixture`, поэтому ни одна клетка не проходит через новую ветку. Мутант
  `author_only` (awk `$2 == "owner"` без `$3`) проходит обе постоянные батареи: `krasnye_062 rc=0`,
  `EXPECT_RC=0 _krasnye_038 rc=0`. Ловит его только живой контроль 4 (автор owner, committer
  architect → rc 1). Мутант `exclude_all` (awk `1`) батареи ловят: rc=1 / rc=1. Значит,
  ослабление «committer тоже owner» в CI не видно. Предложение: добавить клетки к9/к10 в семью 062
  (owner/owner → rc 0; owner/не-owner → rc 1) отдельным предметом. Это правка батареи
  замороженного 062, поэтому её делают architect и critic, а не этот быстрый путь.
- [ ] **Рв300-2 (текст 062 расходится с механизмом).** И-1 замороженного 062 определяет
  судимое множество как «прямые не-merge коммиты диапазона … ∪ свои ленды», минус только чужие
  ленды. Код теперь вычитает ещё коммиты owner/owner. Слово владельца
  (`forks/n-105-konsultant-i-n300-batch.md:26-27`) прямо разрешает быстрый путь, так что FAIL
  здесь нет. Но читатель 062 исключения не увидит. Комментарий в коде ссылается на «Н-300,
  решение владельца 2026-10-16» без пути форка, хотя прецедент grandfather-исключений
  `check_zones.sh:1341-1364` указывает файл форка. Предложение: дописать путь форка в
  комментарий при ближайшей правке файла и упомянуть исключение в v+1 контракта 062, когда он
  будет.
- [ ] **Рв300-3 (предикат identity проверяет только имя).** Коммит с именем `owner` и почтой
  `evil@x` (author и committer) исключается: живой прогон 4d → rc 0. Так же устроен прецедент
  `.githooks/pre-push:313-314` (`%an != owner`), и коммит прямо называет этот остаточный риск
  (один uid). Новый класс слабости не появился. Отмечаю для полноты.
- [ ] **Рв300-4 (исключение не ограничено main-direct).** `git log --no-merges` охватывает весь
  диапазон `last_frozen..HEAD`, поэтому owner/owner коммит, пришедший через СВОЙ ленд
  `land: wip/<n>/…`, тоже исключается. Это следует из чтения кода; живьём я такой случай не
  прогонял. Слово владельца определяет канал скобкой «(author = committer = owner)», и реализация
  ей соответствует буквально. Вопрос владельцу, если нужен именно «main-direct».
- [ ] **Рв300-5 (новая ветвь отказа не показана красной).** `git log` в окне отказал → die
  «список судимых коммитов окна недоступен». Ветвь стоит сразу после успешного `rev-list` того
  же диапазона, поэтому практически недостижима. Направление fail-closed, фраза взята
  существующая. Красный прогон не предъявлен ни автором, ни мной.

## Наблюдения вне предмета (адрес — оркестратор)

- [ ] **Рв300-6.** У `NABLIUDENIA.md` `### Н-300` в «ЧЕМ ЗАКРЫТЬ» по-прежнему стоит «ОТКРЫТО».
  Закрытие (5e7f77a87 + этот вердикт + done 105) нужно записать.
- [ ] **Рв300-7.** В задании ревьюеру родителем фикса назван `453d5b8db`. На самом деле родитель —
  `a73aad366`, а `453d5b8db` идёт ПОСЛЕ фикса. База «до» в этом ревью — `a73aad366`.
- [ ] **Рв300-8.** «_krasnye_038 rc=1, 37 расхождений» из отчёта автора — это режим
  `EXPECT_RC=1` (пред-предметный). CI гоняет `EXPECT_RC=0` (`package.json`
  `check:provodka-family-selftest`). В режиме CI: 0 расхождений из 37 до и после, вывод побайтово
  одинаков. Утверждение автора верно, но в режиме, который CI не использует.
```
