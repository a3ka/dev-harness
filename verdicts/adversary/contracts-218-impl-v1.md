FAIL
OBJECT=682fb9881c94cf674b107d99238102b0313eb18d
СУД: репо=dev-harness; предмет=218; фаза=реализация; роль=adversary; вызов=1 (полный); сессия=Adv218; модель-факт=openai-codex/gpt-6.1-terra; автор implementer — MiniMax, батарея Architect218/218b; предыдущий=—; класс=рисковый

## Блоки

### Б-1 — К-09, БЛОКИРУЕТ: собственная заморозка и её FAIL-вердикт исчезают из суда

ОБЯЗАТЕЛЬСТВО: `contracts/218-okno-frozen-v-pr.md`, И4: в область входят заморозки, чей коммит-основание принадлежит собственному окну; проверяются все версии и accept. Ошибка/отсутствие области не равны чистому окну. Причина: `scripts/check_charter.sh:865-878,882-907` ищет артефакт только в дереве PR HEAD (`pr_collect`), а не в дереве основания собственной заморозки. После импортированного удаления путь исчезает на HEAD, поэтому из области исключаются и собственный изменённый вердикт, и собственная заморозка. `scripts/check_contract_frozen.sh:121-145` получает пустой список.

СОСТОЯНИЕ: настоящий Git-мир: база с `contracts/701-fixture.md`, `frozen/contracts/701/1`, accept v1; собственный PR-коммит добавляет `verdicts/critic/contracts-701-v2.md` с `FAIL`, на него поставлен аннотированный `frozen/contracts/701/2`. В main документ удалён; настоящий merge PR с main берёт это удаление. Bare origin и refs/remotes/origin/main совпадают; история полная; merge-base единственная. Production не мутировалась. До merge тот же тег и вердикт обнаруживаются. И4 явно требует судить собственную заморозку: это не требование судить чужую правку main саму по себе.

Команда выполненного драйвера: `export ROOT="$PWD" TMPDIR="$PWD/tmp/scratch-adv218"; python3 "$TMPDIR/own_tag_delete.py"`. Драйвер использовал настоящий конструктор `World` и настоящий production CLI из батареи. Для воспроизведения тело драйвера (scratch следует создать внутри своей копии):

```python
import importlib.util, pathlib, tempfile, os, sys
root=pathlib.Path(os.environ['ROOT'])
p=root/'fixtures/workshop_project/okno_frozen_v_pr_218/probe.py'
s=importlib.util.spec_from_file_location('probe',p)
m=importlib.util.module_from_spec(s); sys.modules['probe']=m; s.loader.exec_module(m)
with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as d:
 d=pathlib.Path(d); w=m.World(d,m.Cell('x','clean','frozen'))
 v=f'verdicts/critic/contracts-{w.number:03d}-v2.md'
 own=w.commit({v:b'FAIL\n'},(w.head,),'own failing verdict')
 m.git(w.root,'tag','-a',f'frozen/contracts/{w.number:03d}/2',own,'-m','own v2')
 main=w.commit({w.path:None},(w.seed,),'main deletes contract')
 m.git(w.root,'update-ref','refs/heads/main',main)
 m.git(w.origin,'fetch','-q',w.root,'+refs/heads/main:refs/heads/main','+refs/tags/*:refs/tags/*')
 m.git(w.root,'update-ref','refs/remotes/origin/main',main)
 merged=w.commit({w.path:None},(own,main),'import main deletion')
 for label,head in [('before',own),('after',merged)]:
  m.git(w.root,'update-ref','HEAD',head); m.git(w.root,'reset','--hard','-q',head)
  t=d/label; t.mkdir(); r=w.run(m.sources(root),t,d/(label+'.trace'))
  print(label,'own-tag=',own,'main=',main,'head=',head,'rc=',r[0],
        'stdout=',repr(r[1]),'stderr=',r[2].decode())
```

Наблюдённый сырой вывод (rc драйвера 0; приведены обе строки pr, диагноз и итог):

```text
before own-tag=0039efb3ea67d5a4b97b856c85482e22aae863b9 main=6de79f24f5de34c666acc5588bc29afe7294c407 head=0039efb3ea67d5a4b97b856c85482e22aae863b9
rc=1 stdout=b''
pr: check_contract_frozen main=6de79f24f5de34c666acc5588bc29afe7294c407 base=db4955b7cf100358a1b50c94e9dc107c6e869c8e head=0039efb3ea67d5a4b97b856c85482e22aae863b9
  FAIL contracts/701-fixture.md: заморозка v2 лежит поверх вердикта, который её не разрешил: первая строка «FAIL» в verdicts/critic/contracts-701-v2.md
планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
after own-tag=0039efb3ea67d5a4b97b856c85482e22aae863b9 main=6de79f24f5de34c666acc5588bc29afe7294c407 head=a5fdb3a5c8c4e9a14c4cba63601007b57917f19b
rc=0 stdout=b''
pr: check_contract_frozen main=6de79f24f5de34c666acc5588bc29afe7294c407 base=6de79f24f5de34c666acc5588bc29afe7294c407 head=a5fdb3a5c8c4e9a14c4cba63601007b57917f19b
планов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full
```

НАБЛЮДЕНИЕ: недопустимая собственная заморозка стала зелёной, хотя собственный тег и FAIL-вердикт не поменялись. Закрывающее свойство: свои заморозки/затронутые вердикты идентифицируют соответствующие артефакты независимо от наличия пути на HEAD; их отсутствие не становится пустой областью.

### Б-2 — К-08, БЛОКИРУЕТ: область вердиктов различает только v1

ОБХОД: в одноразовом клоне заменён существующий шаблон `scripts/check_charter.sh:888` с `verdicts/critic/contracts-*-v*.md|verdicts/critic/plans-*-v*.md` на те же шаблоны с `v1.md`. Само действие PR — изменить вердикт существующей версии — поддержано И4, и контракт требует все версии. В мире с существующей v2 на main собственная правка `verdicts/critic/contracts-701-v2.md` с accept на FAIL дала:

```text
honest rc=1 stdout= stderr= pr: check_contract_frozen main=c206f294187cddbb4afc432246f0c1f631cb069e base=c206f294187cddbb4afc432246f0c1f631cb069e head=1b662a176eecfa40f4cc29cf2b340be6e15cd190
  FAIL contracts/701-fixture.md: заморозка v2 лежит поверх вердикта, который её не разрешил: первая строка «FAIL» в verdicts/critic/contracts-701-v2.md
планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
mutant rc=0 stdout= stderr= pr: check_contract_frozen main=c206f294187cddbb4afc432246f0c1f631cb069e base=c206f294187cddbb4afc432246f0c1f631cb069e head=1b662a176eecfa40f4cc29cf2b340be6e15cd190
планов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full
```

Команды испытания: `export ROOT="$PWD" TMPDIR="$PWD/tmp/scratch-adv218"; python3 "$TMPDIR/mutate.py"; python3 "$TMPDIR/verdict_attack.py"; bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --repo "$PWD/tmp/clone-adv218"`. Последняя rc 0: `KLETKI=71 ZELENYE=71 KRASNYE=0`. Конструктор мира тот же `World`; v2-тег с accept создан на main, затем один PR-коммит меняет только вердикт. Это дефект достаточности батареи, не честной production на этом входе. Источник механизма — реально существующая ветвь `pr_files`, не фиктивный дополнительный фильтр.

### Б-3 — К-08, БЛОКИРУЕТ: разрешение одного документа скрывает другой в том же коммите

ОБХОД: в одноразовом клоне после сбора `PR_MD` в `scripts/check_charter.sh:851-853` вставлено условие, удаляющее запись ROADMAP, когда тот же коммит меняет AGENTS и ROADMAP. Источник входа — обычная поддержанная правка нескольких уставных документов одним коммитом; И5 прямо запрещает распространять разрешение одного пути на другой. Источник ошибочного механизма — изменение уже существующего списка MD-путей. Отдельный настоящий мир: оба документа изменены, синтетическое разрешение только AGENTS. Выполнены `python3 "$TMPDIR/mutate2.py"`, `python3 "$TMPDIR/permission_attack.py"` и `W --repo "$PWD/tmp/clone-mutant2"`. Последний rc 0, `KLETKI=71 ZELENYE=71 KRASNYE=0`. Сырой вывод парного запуска:

```text
honest rc=1 stdout=
  ok   уставной документ изменён с разрешения владельца: AGENTS.md в 01fad88a
  FAIL уставной документ изменён без разрешения владельца: ROADMAP.md в 01fad88a — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md <причина>» в первой колонке
уставных документов в окне PR: 2 · изменений в них: 2 · с разрешения: 1
mutant rc=0 stdout=
  ok   уставной документ изменён с разрешения владельца: AGENTS.md в 01fad88a
уставных документов в окне PR: 1 · изменений в них: 1 · с разрешения: 1
```

### Б-4 — К-08, БЛОКИРУЕТ: ошибка чтения дельты становится пустым окном

ОБХОД: в одноразовом клоне две ветви `pr_refuse DELTA_UNREADABLE` в `scripts/check_charter.sh:844-854` заменены на `:`. И2 явно требует именованного отказа при ошибке чтения дельты; источник механизма — удаление существующего обработчика отказа, источник входа — явно утверждённая ошибка Git. Выполнены `python3 "$TMPDIR/mutate3.py"`, `python3 "$TMPDIR/git_fault.py"`, `W --repo "$PWD/tmp/clone-mutant3"`. Поддельный `git` на PATH только инъецирует rc 127 для `diff-tree` (PATH доверенный и сама его подмена вне модели угроз, это средство воспроизведения ошибки инструмента, а не заявленный обход честной production). Честный и мутантный guard запускаются на одном own-charter мире:

```text
honest rc=1 stdout=b'' stderr=b'PR_WINDOW_DELTA_UNREADABLE\n'
mutant rc=0 stdout=b'' stderr=b'pr: check_charter main=f4bed845c712eb5bf8f035f6ab96f75ab1750255 base=f4bed845c712eb5bf8f035f6ab96f75ab1750255 head=0b5cbfeea7d6e791b0f7ab558f59b3bc564ddac5\n\nуставных документов в окне PR: 0 · изменений в них: 0 · с разрешения: 0\n'
W --repo clone-mutant3: rc 0, KLETKI=71 ZELENYE=71 KRASNYE=0
```

## Отклонение lib_pr_window

`fixtures/workshop_project/okno_frozen_v_pr_218/probe.py:18-19,407-417` переносит пять названных файлов, но не `lib_pr_window.sh`, следовательно причина переносимости подтверждена. Контракт называет этот путь разрешённой зоной и «единственный новый production-путь», но не требует создания нового файла. Общий код находится единожды в существующем `check_charter.sh` и импортируется frozen guard, не дублируется. Это не самостоятельное нарушение. Импорт и CLI всё же различаются по переменной окружения: на own-charter обычный CLI rc 1, `CHARTER_LIB=1 GITHUB_EVENT_NAME=pull_request` даёт rc 0 с пустыми stdout/stderr; `probe.py:30-33` флаг удаляет. Это прежняя документированная библиотечная семантика, которую И1 требует сохранить, и доверенная среда, не доказанный новый дефект 218.

## Остатки

- ОСТАТОК: К-16 — укусил: `export ROOT="$PWD" TMPDIR="$PWD/tmp/scratch-adv218"; python3 "$TMPDIR/attack.py"`: честный вызов rc 1, с `CHARTER_LIB=1` rc 0, stdout/stderr пусты. Подмена окружения исключена доверенной средой; не блок отдельно.
- ОСТАТОК: К-08 — укусил: `W --repo "$PWD/tmp/clone-adv218"`, rc 0, 71/71 на живой мутации Б-2; отдельно Б-3 и Б-4 тоже зелёные на реальных нарушениях. Это не утверждение универсальной асимптотики.
- Независимые дефекты публикации, предполёта и Д4 не объявляются исправленными. SourceCanon не объявлен; продуктовая архитектура 188 неприменима.

## Регресс

`W = bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh`. База `b7d1fd8756c1ecfc5ca7736ca2f4adaf3b3b3e61`, не main; последовательные запуски, отдельные Git-миры.

| Проверка | До | После |
|---|---|---|
| W --repo | rc 1, 71 клетка, 8 зелёных, 63 красных | rc 0, 71 зелёная, 0 красных |
| W --model | — | rc 0, 71/71 |
| W --stabs | — | rc 0, STABY=15 SVJAZI=32 POIMANY=32 ZHIVYH=0 |
| W --sintaksis / --catalog | — | rc 0 / rc 0; CELLS=71 MUTATIONS=15 BINDINGS=32 |
| семья 200 --repo | rc 0, 11/11 | rc 0, 11/11 |
| семья 207 --repo | rc 0, 50/50 | rc 0, 50/50 |
| семья 217 --repo | rc 0, 41/41 | rc 0, 41/41 |
| семья 210 --repo | rc 0, 342/342 | rc 0, 342/342 |
| fail_closed_992.py | rc 0, cases=25 failures=0 | rc 0, cases=25 failures=0 |
| verify_antiplacebo --scope check_charter | rc 0, 13/13 | чистый клон rc 0, 13/13 |
| `_krasnye_083.sh` | rc 1, ok=118 FAIL=2 | rc 1, ok=119 FAIL=1; изолированный чистый клон повторно rc 1, ok=119 FAIL=1 |
| bash -n три production файла | — | rc 0 |
| shellcheck 0.11.0 -S warning, три файла | rc 1, 10 SC2034 | rc 1, те же 10 SC2034 |
| gen_ci_steps.sh --check / context.py | — | rc 0 / rc 0; 88 пересечений |

083: до — красные И0б/check_charter и И0/check_zones; после и в изолированном повторе — только И0б/check_charter. И0/check_charter зелёная. Адресный разбор повтора (`python3 "$TMPDIR/cache_control.py"`) показал: `guard rc=0 marker=True head=682fb9881c94cf674b107d99238102b0313eb18d cache=682fb9881c94cf674b107d99238102b0313eb18d bytes=32608; battery pipe rc=141`. Причина наблюдения: `fixtures/ci_gen_083/red_ci_a_083.sh:1528` при pipefail проверяет длинный вывод через `printf | grep -q`; ранний выход grep вызывает SIGPIPE у printf. Поэтому зелень И0б по названной команде не доказана, но это тот же красный сценарий базы, а не доказанный регресс production. Другая приёмочная команда 217 зелена 41/41.

Первый вызов antiplacebo из корня собственной копии дал rc 1 из-за одновременно менявшихся scratch-файлов; проверка сама объявила прогон недостоверным. Кроме того, она отвергла внутренний TMPDIR и использовала fallback `/tmp/verify_antiplacebo-3d47e5d3/run-339615`, оставив диагностические файлы вне разрешённой области. Повтор выполнен из чистого вложенного клона с TMPDIR-соседом внутри собственной копии и дал rc 0; внешние файлы не трогались и требуют уборки уполномоченным процессом.

Область `git diff --name-status b7d1fd875... OBJECT`: три production-файла, два TSV и генерируемый workflow; `git diff ... -- contracts fixtures roles` пуст. Батарея запускает настоящие CLI в Git-мирах с bare origin; до/после реализации она не менялась. Положительные контроли model и production зелёные. Миры own-frozen и owner-update проходят ожидаемо; Б-1 предъявляет недостающую комбинацию собственного тега и исчезновения пути. Здесь остаются не только К-08, но и подтверждённый дефект честной production Б-1.

## Мутации

| Атака | Наблюдение |
|---|---|
| Scope вердиктов только v1 | `W --repo` rc 0, 71/71; v2 FAIL: честный rc 1, мутант rc 0 — Б-2 |
| Отключение второго документа | `W --repo` rc 0, 71/71; честный rc 1, мутант rc 0 — Б-3 |
| `diff-tree` error → пусто | `W --repo` rc 0, 71/71; fault rc 127: честный rc 1, мутант rc 0 — Б-4 |
| `CHARTER_LIB=1` в окружении | честная production rc 0 на запрещённой правке при специально подменённой среде, см. Остатки |
| собственная заморозка + импортированное удаление | честная production до merge rc 1, после rc 0 — Б-1 |
| s01–s15 адресные стабы батареи | 32/32 поимки; это reference, не мои мутации |

## НЕ ЗАЩИЩАЕТ

Контракт исключает подмену настроенного origin/CI-event/PATH, сговор при общем uid и распознавание фикстуры; доверенная среда прежняя, ловцы CI/изоляция и независимые adversary/reviewer. Исключает доказательство универсальной асимптотики произвольного кода (Trace2 видит доверенные Git-процессы, не чтение objects/libgit2); И6 сохраняется, ловцы reviewer и adversary. Независимые дефекты публикации, main-предполёта и Д4 остаются за семьями 200/210/217/083/992/071 и интеграционным reviewer.
