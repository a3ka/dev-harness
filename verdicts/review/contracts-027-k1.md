FAIL

# Ревью контракта 027 — механизм doc-приёмки (круг к1, после трёх кругов адверсария и арбитража)

Предмет: `contracts/027-doc-priemka.md` (тег `frozen/contracts/027/3`, блоб
`5d3f9f31aa`) и его реализация на `HEAD = 55be77b1a6034f2a14865ed398e70760c7f60636`.
Клон собственной рукой: `/tmp/dev-harness-verify/rev-027/repo` (`git clone`
основного дерева). Все rc ниже получены в этом клоне, не пересказаны.

Привязка блобами (Н-101 — имя автора ничего не доказывает):

| файл | блоб на HEAD |
|---|---|
| `contracts/027-doc-priemka.md` | `5d3f9f31aa` |
| `scripts/doc_contract.ts` | `54a5016ed1` |
| `scripts/check_document.ts` | `cbe4282cb4` |
| `scripts/render_document.ts` | `f4b657ca49` |
| `scripts/check_document.sh` | `fcb7d0017f` |
| `scripts/render_document.sh` | `6ab61f4a02` |
| `scripts/check_contract_ready.sh` | `09aa8d3ede` |
| `scripts/freeze_contract.sh` | `252e391461` |
| `fixtures/check_check_contract_ready/_doc027.py` | `d6bf95920c` |
| `package.json` | `a3100f98b8` |
| `.github/workflows/ci.yml` | `bf6749ec8c` |
| `roles/reviewer.md` | `ac36289b54` |
| `verdicts/arbitration/contracts-027-izoljacija-probe.md` | `e3e6d690af` |

Прочитано до измерений: замороженный контракт v3; `verdicts/critic/contracts-027-v3.md`;
`verdicts/adversary/contracts-027-k{1,2,3}.md`; арбитраж `contracts-027-izoljacija-probe.md`;
реализация и фиксы `75f0c0d`, `fcaaf60`, `bf76fe9`.

## Собственные прогоны (сырые коды, мой клон)

```
rc=0 fixtures/check_check_contract_ready/red_doc_obligations.sh
rc=0 fixtures/check_check_contract_ready/red_doc_product.sh
rc=0 fixtures/check_check_contract_ready/red_doc_architecture.sh
rc=0 fixtures/check_check_contract_ready/red_doc_evidence.sh
rc=0 fixtures/check_check_contract_ready/red_doc_assertions.sh
rc=0 fixtures/check_check_contract_ready/red_doc_status_render.sh
rc=0 fixtures/check_check_contract_ready/red_doc_oracle.sh
rc=0 fixtures/freeze_contract/red_doc_lifecycle.sh
rc=0 python3 fixtures/check_check_contract_ready/_doc027.py regressions
rc=0 npm run check:document
rc=0 npm run check:contract-ready
rc=0 npm run check:ci-parity
```

`bash scripts/verify_antiplacebo.sh --scope check_document render_document freeze_contract
check_check_contract_ready` → `RC_ANTIPLACEBO=0`, хвост вывода:
`барьеров: 4 · фикстур: 22 · предъявлено красным повторным прогоном: 22`.

`git diff frozen/contracts/027/3 HEAD -- contracts/027-doc-priemka.md` → `RC_FROZEN_DIFF=0`,
вывод пуст: замороженный текст реализацией не тронут.

Счётные утверждения проверены СВОЕЙ мерой, не повтором чужой команды:
`ls fixtures/{check_document,render_document,freeze_contract,check_check_contract_ready}/case_*.sh | wc -l`
= **22** (2+2+14+4) — совпадает с «фикстур: 22» раннера;
`ls fixtures/check_check_contract_ready/red_doc_*.sh fixtures/freeze_contract/red_doc_*.sh | wc -l`
= **8** — совпадает с восемью строками приёмочной таблицы и с восемью путями,
перечисленными в `package.json:22` (`check:document`).

## Сверка §Предмет ↔ коммиты (реализующие, не только барьеры)

| обязательство §Предмет | коммит | наблюдение |
|---|---|---|
| `scripts/doc_contract.ts` | `ff26c04` (+`75f0c0d`,`fcaaf60`,`bf76fe9`) | есть, шапка «НЕ БАРЬЕР» |
| `scripts/check_document.ts` | `708892d`,`ac0e92a` | есть, `--preflight`/`--check` |
| `scripts/render_document.ts` | `0733384` | есть, `--check` |
| обёртки-барьеры `.sh` (зона v2) | `2c51acc` | обе несут `# Коды возврата:` (`check_document.sh:20`, `render_document.sh:22`) |
| doc-preflight в `check_contract_ready.sh` | `cb67a00` | есть (`:96-108`) — **см. F1** |
| doc-preflight в `freeze_contract.sh` ДО тега | `f5137bd` | есть (`:242-263`) — **см. F1** |
| `check:document` в `package.json` | `b32a538` | `package.json:22`, 8 прямых `red_doc_*` |
| `check:document` в CI | `c2b907f` | `.github/workflows/ci.yml:137`, после `check:contract-ready` (`:131`) |
| фикстуры `case_*` после freeze | `908f903`,`cfe0b38`,`e2a78f8` | 4 шт., зона implementer |

**Зоны.** Полный список путей всех 17 коммитов реализации
(`git show --pretty=format: --name-only` по каждому, `sort -u`): 5 файлов в
`scripts/` + 4 `case_*.sh` в `fixtures/check_document/` и `fixtures/render_document/`.
Ни одного выхода за ЗОНА implementer; норма (`AGENTS.md`, `roles/`) реализацией
не тронута — молчаливого ослабления нормы нет.

**Проверка не переписана под реализацию.** Полная история восьми барьеров
`red_doc_*.sh` и каркаса `_doc027.py`: `a95be6b`, `c31d70f`, `000e759`, `f781b5b` —
**все четыре автора `architect`**, ни одного коммита `implementer`. Мера, по
которой судится реализация, автором реализации не правилась.

**Атомарность.** Фиксы разнесены по кругам с указанием предмета: `75f0c0d`
(к1, ссылка на `f1996c0`), `fcaaf60` (к2), `bf76fe9` (арбитраж). Связки задач в
одном коммите нет.

## Находки

**F1 — БЛОКЕР. Тип doc-контракта распознаётся строчной shell-эвристикой, а не
общим модулем: конформный doc-контракт проходит ready и ПОЛУЧАЕТ ЗАМОРОЗКУ без
единого doc-preflight (класс: ложное принятие на конформном входе).**

Обязательство (замороженный текст, §Freeze, charter, zones и проводка):
«Doc-ветвь ready распознаёт тип **через общий модуль** и требует `--preflight`
вместо кодовой эвристики»; «Freeze повторяет тот же preflight ДО записи тега…
Отказ не меняет refs». §Предмет: `scripts/doc_contract.ts` — «**единственный
разбор** грамматики и профилей».

Наблюдаемое противоречие. Точные фрагменты результата:

- `scripts/check_contract_ready.sh:98` (блоб `09aa8d3ede`):
  `if grep -qE '^## Док-приёмка' "$CONTRACT" && grep -qE '"type":[[:space:]]*"documentation"' "$CONTRACT"; then`
- `scripts/freeze_contract.sh:249-250` (блоб `252e391461`): тот же парный `grep -qE`
  по `git cat-file -p HEAD:$TARGET`.

Обе шапки при этом утверждают обратное: `check_contract_ready.sh:16-17` — «ТИП
определяется единым разбором в `doc_contract.ts`; НЕ кодовой эвристикой»;
`freeze_contract.sh:247` — «Общий модуль `doc_contract.ts` определяет тип».
Ни одна из двух ветвей `doc_contract.ts` не вызывает: решение принимает
построчный `grep`, которому обязательны ключ и значение НА ОДНОЙ строке.

Мой контрольный эксперимент (`/tmp/dev-harness-verify/rev-027/probe_typeline.py`,
игрушка та же, что в фикстуре `lifecycle`, отличие ровно одно — в JSON-блоке
`"type"` и `"documentation"` на разных строках; это валидный JSON, и формат строк
внутри fenced-блока замороженная грамматика не ограничивает):

```
КОНТРОЛЬ ready (конформный пакет, split-формат): rc=0
preflight напрямую: rc=1 :: ОТКАЗ DOC: schema: product: spec.required.sections пуст
ready:              rc=0 :: OK
freeze:             rc=0 :: ok   заморожено: contracts/001-yozh.md → frozen/contracts/001/1 («Ёж»)
frozen-теги после freeze: frozen/contracts/001/1
```

Честный контроль есть в обе стороны: (а) конформный пакет в том же split-формате
даёт ready rc=0 — положительный контроль; (б) `check_document.ts --preflight`
на ТОМ ЖЕ входе даёт rc=1 с именованной причиной — значит вход общим модулем
разбирается и нарушение реально; (в) ровно это нарушение в однострочном формате
даёт ready rc=1 и freeze rc=1 без тега (фикстура `red_doc_lifecycle.sh`,
мой прогон rc=0). Расхождение вызвано не значением и не ID, а исключительно
переносом строки — валидный контрпример по §Демаркация.

Последствие именно то, которое обязательство запрещало: doc-контракт с пустыми
обязательствами получил `frozen/contracts/001/1`. Это не повтор причин 1 и 2
арбитража (не форма кода в argv, не регистр OID) и не false-reject: это новое
ложное ПРИНЯТИЕ в жизненном цикле, поэтому запрет повтора из §Решение арбитража
здесь не действует.

**F2 — «нечем проверить» в git-источнике отображается в rc=1 с чужим именем
(класс: расхождение с границей арбитража, НЕ блокер; [чтение кода]).**
Арбитраж (находка 3) обязал: при неопределённом `fsConstants.O_NOFOLLOW` —
именованный отказ до `open`, **отображаемый в rc=2**. Отказ добавлен
(`doc_contract.ts:169-171`, `bf76fe9`) и в двух точках чтения пакета
действительно даёт rc=2 (`check_document.ts:88-89`, `render_document.ts:72-73`
→ `skip()` → `exit 2`). Но третий потребитель того же результата,
`resolveGitSource` (`doc_contract.ts:510-512`), при `ok=false, escaped=false`
возвращает `mode:'drift'`, а `check_document.ts:201-202,222-223` печатает
`current-источник … дрейфует относительно объявленного blob` и выходит rc=1.
То есть «нечем проверить» предъявляется как содержательное нарушение дрейфа.
Не блокер: направление fail-closed (ложного зелёного нет), ветвь на Linux
недостижима (арбитраж, замер 3: константа определена). Названо потому, что
имя причины — часть обещания rc-семантики контракта («2 — нечем проверить»).

**F3 — residual argv назван там, где его не прочтёт адресат (класс: достаточность
именования остатка, НЕ блокер).**
Арбитраж требовал от реализации только правку заявления в комментарии — она
выполнена дословно: `doc_contract.ts:187-203` больше не называет блоклист
границей безопасности, а `:201-203` несёт residual-строку «probe.argv —
исполняемая программа ЦЕЛИКОМ… Судить содержимое argv при freeze как код».
Обязательство арбитража закрыто. Но адресат residual — ревьюер при freeze, а он
этого текста не получает ни в одном канале своего круга: `roles/reviewer.md`
(`ac36289b54`) §«Семантический суд doc-пакетов» о probe.argv молчит; замороженный
контракт §«Мандат семантического суда» — тоже; `check_document.ts --preflight` и
`freeze_contract.sh` при doc-ветви никакой строки про argv не печатают (grep по
`argv|как код|residual` в обоих даёт только внутренний разбор `process.argv`).
Остаток назван в коде исполнителя и в вердикте арбитра; до адресата он доставлен
не будет. Класс — именование без доставки.

**F4 — residual OID не имеет носителя, а комментарий кода повторяет ровно ту
формулировку, которую адверсарий назвал расходящейся (класс: достаточность
именования остатка, НЕ блокер).**
Арбитраж (находка 2) закрыл upper-case-OID как долг ТЕКСТА контракта
(«правка кода не требуется»), и претензий к исполнителю тут нет. Но носителя
долга в дереве нет: `grep -rn -E 'OID|lower-case|hex'` по `NABLIUDENIA.md`,
`NABLIUDENIA_ARCHITECT.md`, `HANDOFF.md`, `roles/reviewer.md` даёт два попадания
о других предметах (`NABLIUDENIA_ARCHITECT.md:3150`, `HANDOFF.md:2307`) и ни
одного об этом долге; он живёт только в
`verdicts/arbitration/contracts-027-izoljacija-probe.md` (`e3e6d690af`), то есть
architect следующей версии 027 обязан вспомнить о нём сам. Сильнее: комментарий
`doc_contract.ts:29-32` по-прежнему объявляет класс как «ровно 40 (sha1) или
64 (sha256) hex-символов», тогда как `:32`
`GIT_OID_RE = /^(?:[0-9a-f]{40}|[0-9a-f]{64})$/` реализует lower-case — это
дословно то расхождение заявления и кода, которое `contracts-027-k3.md` назвал
в находке 2 («`[0-9a-f]` реализует lower-case, а не объявленный класс
"40/64 hex"»). Поведение верно и fail-closed; неверно ЗАЯВЛЕНИЕ — тот же класс,
который арбитраж потребовал исправить для argv и не потребовал здесь.

## Оценка residual по заданию

- **argv=probe (судить при freeze):** формулировка достаточна и честна, место —
  нет (F3). Достаточным именованием было бы упоминание в `roles/reviewer.md`
  §doc-суд либо печать строки doc-preflight при наличии `check.type=probe`.
- **OID-регистр (lower-case канон):** как решение арбитража — достаточно
  (fail-closed, тривиально исправимо автором doc-контракта); как именование —
  недостаточно (F4): нет носителя долга и комментарий кода противоречит коду.

## Что вердикт НЕ закрывает и не измерял

Полный CI (по заданию — мера оркестратора; мои прогоны scoped), содержательный
суд конкретного doc-ПАКЕТА (принимаемых документов ещё нет — судился механизм),
церемонию миграции Н-98 и параллельные предметы 020/026/028. Машинные барьеры и
норму этот суд не менял и чужой код не правил: F1 назван, не исправлен.

Раскрытия приняты как переданные, мной не перепроверялись: Н-98 самотрип
`check_no_leak` на живом дереве благословлён владельцем (миграция после done×4);
зелёный CI на `55be77b`.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта;
контракт несёт инварианты + rc-команды».

Н-101: блоб этого текста записан `git hash-object -w` и добавлен в индекс
`update-index --cacheinfo`; identity коммита задана явно как `reviewer`, а не
унаследована от автора работы или реле. Н-73: использована нейтральная
терминология контрольных экспериментов и контрпримеров.
