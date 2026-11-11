accept
OBJECT=9f976ba91023786c46467d5fd1513978792b0679
КЛАСС=кодовый (документ-стандарт + сверочный скрипт в продукте Complior-mob); РИСК=обычный (адверсарий не вызывался)
СУД: repo=dev-harness (контракт frozen/contracts/162/3 → 82842c994, блоб sha256 8a64d5e1d58ab1f3a4e6e704d43aa46c121ceac0560cbab1df69ccf658475415) + Complior-mob (PR #158, head a1b3d41a8d6fa6f79779eef6732c191d874529ba); предмет=162; фаза=реализация по frozen/contracts/162/3 (перед слиянием PR #158); роль=reviewer; вызов=3 (scoped по v3); модель-план=anthropic/claude-opus-5-5; session-id=Rev162v3 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; предыдущий=verdicts/review/contracts-162-impl-v2.md
Находки: `.review/2026-11-11-62.md`

# Вердикт reviewer — 162, реализация, вызов 3 (scoped по v3)

## Итог

**accept**: кандидат продукта a1b3d41a8 и зеркало OBJECT 9f976ba91 приняты по frozen 162/3. Все блоки вызова 2 закрыты:
- **Ф-1** (пин STRUCTURE.md) закрыт текстом v3. `CITATIONS OK count=5`, rc 0.
- **Ф-2** (буква критерия 3) закрыт текстом v3. `162: policy delta OK`, rc 0, numstat `1\t1`.
- **Ф-3** (красный android-e2e) закрыт. Прогон 42871658274, попытка 2, на неизменном head a1b3 — success. Обязательные проверки main `quality` и `android-e2e` — pass.
- **Ф-4** — не блок поставки. Это условие done 162 и долг оркестратора после merge (§Порядок v3, критерий 6 «До merge #158 NOT_RUN»). На кандидате команда даёт rc 1 по четырём ролям, как и ожидается.

Блоков нет. Советы и наблюдения — в `.review/2026-11-11-62.md`.

## Клоны и кандидат

- Харнесс: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev162v3/repo`, затем `git fetch origin wip/162/implementer 'refs/tags/frozen/contracts/162/*:…'`:
  ```
  9f976ba91023786c46467d5fd1513978792b0679   (FETCH_HEAD = wip/162/implementer = OBJECT)
  027e8363aa15376c68fc0dc218d439d33dc5a3b6   (origin/main)
  merge-base(OBJECT, origin/main) = 11451c183087c63db595f5c56eb36f64896116f7
  ```
  `git diff --quiet frozen/contracts/162/3 {origin/main|OBJECT} -- contracts/162-standart-koda-mob.md fixtures/workshop_project/standart_koda_162/` → rc 0 и rc 0. Рабочий контракт равен тегу.
- Продукт: SSH-клон `Complior-mob` → «ERROR: Repository not found», rc 128 (Н-1). Поэтому клон `--no-hardlinks` из `/home/harness/projects/Complior-mob`, remote на https, `fetch main wip/136/standard pull/158/head`:
  ```
  50699aeea16675980cb92175248c03ac1fbc62ab   branch 'main'
  a1b3d41a8d6fa6f79779eef6732c191d874529ba   branch 'wip/136/standard'
  a1b3d41a8d6fa6f79779eef6732c191d874529ba   'refs/pull/158/head'
  ```
  `git ls-remote https://github.com/a3ka/Complior-mob` даёт те же три головы.
  `git rev-list --parents -n1 a1b3` → `a1b3d41a8… 54fd5c83c… 50699aeea…`.
  `merge-base --is-ancestor`: 932ee4a → a1b3 rc 0, 50699aeea → a1b3 rc 0.
  `git rev-list --parents 932ee4a..54fd5c83` → один коммит `54fd5c83 932ee4a5`.

## Побайтовое равенство зеркала и продукта (своя мера)

Блоб каждого файла ЗОНЫ: продукт `a1b3:<путь>` против `OBJECT:<путь>`:
```
docs/CODING-STANDARDS.md                          prod=da93d347… mirror=da93d347… eq=Y sha256=b32fb106a50d7803
docs/CODING-STANDARDS.evidence.json               prod=7ad58f71… mirror=7ad58f71… eq=Y sha256=355528bc74444c1a
STRUCTURE.md                                      prod=368d00ce… mirror=368d00ce… eq=Y sha256=b91af22dfd3ebbd2
mobile/scripts/verify-coding-standards.sh         prod=1d8d207b… mirror=1d8d207b… eq=Y sha256=fe7a12a74c9ad50b
mobile/scripts/coding-standards-claims.tsv        prod=fa8bc118… mirror=fa8bc118… eq=Y sha256=7042df201a4c677c
mobile/scripts/check-coding-standards-context.sh  prod=bad8c990… mirror=bad8c990… eq=Y sha256=2312af182e64354d
mobile/structure-policy.json                      prod=72315f49… mirror=72315f49… eq=Y sha256=e5d6998738a1723f
harness.project.json                              prod=71a5c5db… mirror=515b3721… (у зеркала — файл харнесса)
```
`git diff --quiet 11451c183 9f976ba91 -- harness.project.json` → rc 0: зеркало не трогает `harness.project.json` харнесса. В продуктовом диффе `50699aeea..a1b3` этого файла тоже нет.

## (5) Зона

- Продукт, `git diff --name-status 50699aeea a1b3d41a8` (rc 0) — ровно 7 файлов PR. Слитые правки 143 отделены, потому что база — main:
  ```
  M STRUCTURE.md
  A docs/CODING-STANDARDS.evidence.json
  A docs/CODING-STANDARDS.md
  A mobile/scripts/check-coding-standards-context.sh
  A mobile/scripts/coding-standards-claims.tsv
  A mobile/scripts/verify-coding-standards.sh
  M mobile/structure-policy.json
  ```
  `gh pr view 158 --json files` даёт те же 7 путей. Все входят в ЗОНУ implementer frozen 162/3.
- Изменения STRUCTURE.md к main (`diff -U0`) — две строки PR: стр. 71 «generated/ — типы вручную…» и стр. 169 «генератора в репозитории нет… — цель». Сверка с деревом: `mobile/src/api/generated/api-5_8.ts:2` — «minimal hand-written typings derived from `api/mock-5_8.json`». `api/mock-5_8.json` существует. Генератора в `package.json` нет: `git grep 'openapi-typescript|orval|openapi-generator'` → rc 1. Утверждение правки соответствует дереву.
- Харнесс, `git diff --stat 11451c183 9f976ba91`: 7 файлов (те же пути), 1287 вставок, других путей нет. Три коммита, все от `implementer <implementer@dev-harness.local>` с префиксом `162:`. Тот же путь зеркалирования принят у 143 (HANDOFF «зеркало `wip/143/implementer` — 3 implementer-коммита поверх main»).
- Пять файлов, кроме STRUCTURE.md и policy, по блобу равны на 932ee4a, 54fd5c83 и a1b3 (da93d347, 7ad58f71, 1d8d207b, fa8bc118, bad8c990). Значит, после вызова 1 поставка не менялась.

## Критерии frozen 162/3 исполнением

### К1 — preflight харнесса
```
$ bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight
rc=0
```
Пара проверялась на копии `c1/contracts/162-…` с заголовком `## Док-приёмка`, заменённым на `## Прочее`:
```
ОТКАЗ DOC: contract: нет раздела «## Док-приёмка»
rc=1
```

### К2 — `verify-coding-standards.sh` (123/123) и CI-раскладка `check-structure`
Прогон на клоне `vc` @ a1b3: `git status` чистый, `tmp/` нет.
```
$ bash mobile/scripts/verify-coding-standards.sh
утверждений объявлено: 123; зелёных: 123; красных: 0
тип exists: всего 18, ok 18, fail 0
тип goal: всего 6, ok 6, fail 0
тип grep: всего 89, ok 89, fail 0
тип grep-none: всего 6, ok 6, fail 0
тип json: всего 4, ok 4, fail 0
РЕЗУЛЬТАТ: OK (123 из 123 объявленных утверждений)
rc=0
```
Своя мера — python-разбор TSV, не checker:
```
header True rows 123 fields Counter({6: 123})
types [('exists', 18), ('goal', 6), ('grep', 89), ('grep-none', 6), ('json', 4)]
uniq 123 empty 0
rc 0 ok-ids 123 equal True
```
Пары исполнены по одной. После каждой отмены копия снова даёт `РЕЗУЛЬТАТ: OK (123 из 123 …)`, rc 0, `git status` пуст:
- удалён `mobile/src/features/auth/auth-tokens.ts` (носитель c85) →
  `FAIL c85: носитель не подтверждает правило: id=c85 §10 — носитель отсутствует: mobile/src/features/auth/auth-tokens.ts`, rc 1;
- добавлена строка `x901 §10 «нет такой формулировки в секции рев162» exists mobile/package.json` →
  `FAIL x901: носитель без правила: mobile/package.json — id=x901 §10: у носителя нет строки правила в этой секции стандарта`, rc 1;
- добавлена строка `x902 §10 … grep` с пустыми путём и шаблоном →
  `FAIL x902: правило без носителя: id=x902 §10 — путь носителя пуст и правило не объявлено целью`, rc 1.

CI-раскладка на клоне `ci` @ a1b3. Шаг взят из `.github/workflows/mobile.yml:414-436` («Инвентаризация пачек по карте и вынос H…»).
- Без выноса `node mobile/scripts/check-structure.cjs` → rc 1. Отказов 17: пачки `mobile/e2e-erstinformation/*`, `mobile/e2e-first-run/*` и `kompozicija.stand-in.sh`. Таблицы среди них нет. Это ожидаемо.
- Вынос:
  ```
  $ node mobile/scripts/select-ci-screens.cjs --mode inventar --repo . --out …/moved/inventar.json   (rc 0)
  PACHKA mobile/e2e-erstinformation/
  PACHKA mobile/e2e-first-run/
  INVENTAR OK pachek=2 rabotnikov=5
  ```
  Обе пачки, `.harness` и `mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh` перенесены в `…/moved/`. `.harness117`, `.harness117b` и `.harness151` в клоне отсутствуют: в CI это отдельные checkout-ы.
- После выноса:
  ```
  (cd mobile && node scripts/check-structure.cjs)  → structure: OK (repository inventory; external trees excluded)  rc=0
  node mobile/scripts/check-structure.cjs          → structure: OK (repository inventory; external trees excluded)  rc=0
  ```
- Пара на той же копии: из `mobileFiles` удалена `"scripts/coding-standards-claims.tsv"` (numstat `1	1`) →
  `mobile/scripts/coding-standards-claims.tsv: file outside allowed location/type`, rc 1. После `git checkout` → `structure: OK`, rc 0.
- На GitHub job `quality` прогона 42871658274 (headSha a1b3) — pass, 8m26s.

### К3 — изолированная дельта 162 (буква v3)
```
$ python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --repo /tmp/dev-harness-verify/Rev162v3/mob --base 932ee4a54352a8731fbb6570da30faae7406c10a --feature 54fd5c83c7b4e9e5ad5fc6dd1e162c9766bbfea4 --main 50699aeea16675980cb92175248c03ac1fbc62ab --head a1b3d41a8d6fa6f79779eef6732c191d874529ba
162: policy delta OK
rc=0
$ bash fixtures/workshop_project/standart_koda_162/red_policy_delta.sh
rc=0
```
Своя мера:
- `git diff --numstat 932ee4a..54fd5c83 | od -c` → `1 \t 1 \t mobile/structure-policy.json \n`. Строка одна, TAB — байт 0x09.
- jq-разбор, независимый от фикстуры:
  ```
  932ee4a54..54fd5c83c {"keysEqual":true,"otherKeysDiffer":[],"lenA":18,"lenB":19,"prefixSame":true,"last":"scripts/coding-standards-claims.tsv"}
  50699aeea..a1b3d41a8 {"keysEqual":true,"otherKeysDiffer":[],"lenA":18,"lenB":19,"prefixSame":true,"last":"scripts/coding-standards-claims.tsv"}
  ```
- Отказы на чужих диапазонах:
  - `--feature a1b3` (диапазон 932ee4a..HEAD включает 143) → `ОТКАЗ 162: diff содержит второй файл или не содержит политику`, rc 1;
  - `--main 932ee4a --head a1b3` → `ОТКАЗ 162: merge: policy не одна разрешающая строка`, rc 1.
- Красное против сломанной реализации. На копии фикстур `mut/` в `policy_pair` проверка заменена на `CLAIM in after["mobileFiles"]`. Результат: `red_policy_delta.sh` → `ОТКАЗ фикстуры: обманная пара принята: {…"undisclosed.tsv"…}`, rc 1. Барьер различает.

### К4 — цитаты, пин STRUCTURE.md §5 167–179 (перепроверено независимо)
Сначала, до прогона, сняты значения в клоне `vc` @ a1b3:
```
b32fb106a50d7803521a9e8811d17a3f6034ed31ede09622c5f1976e5464a436  docs/CODING-STANDARDS.md        (пин — равен)
b91af22dfd3ebbd231c962028cc26bc0c2a39a6dd10f9fcbfec153e7c1b71e11  STRUCTURE.md                    (пин v3 — равен)
e76d217b361b0f3e1c50a56c8699f34d242a9abcd7673871a0fdd1c3bda99f9a  AGENTS.md                       (равен)
ac1e9dbe13f904384825e77754b3e397704c5145c200874fe91485251b433e4c  docs/context/CONTEXT-POLICY.md  (равен)
```
Границы раздела: стр. 166 пустая, стр. 167 `## 5. API, авторизация и удаление mock`, стр. 179 «**Граница доказательства:** …», стр. 180 пустая, стр. 181 `## 6. Дизайн-система, copy и имена`. Диапазон 167–179 ровно покрывает §5.

Копия контракта: `git show frozen/contracts/162/3:… | tee vc/.harness/contracts/162-standart-koda-mob.md` (sha256 8a64d5e1…5415). Проверка `cmp -s` → rc 0.
```
$ python3 mobile/scripts/check-context-sources.py --root . --contract .harness/contracts/162-standart-koda-mob.md
CITATIONS OK count=5
rc=0
```
Пара — инвертирован один бит предпоследнего байта `docs/CODING-STANDARDS.md`:
```
CITATIONS FAIL: SHA256: docs/CODING-STANDARDS.md
rc=1
```
После `git checkout` → `CITATIONS OK count=5`, rc 0.

### К5 — валидаторы 027
`cmp -s <(git show frozen/contracts/162/3:contracts/162-standart-koda-mob.md) "/tmp/dev-harness-verify/Rev162v3/vc/.harness/contracts/162-standart-koda-mob.md"` → rc 0. Затем node-команда контракта: строки 71–83 тега дословно, `<P>`=`/tmp/dev-harness-verify/Rev162v3/vc`, node v26.5.1 → rc 0, вывода нет.

Пары на отдельных копиях `d5-failures` и `d5-links` (контракт, стандарт и мутированное evidence):
```
failures before 3 after 2
ОТКАЗ DOC: package.failures не покрывает required: Пустая-выборка
rc=1
restored rc=0
links before 3 after 2
ОТКАЗ DOC: package.links не покрывает required: Скрипт-к-таблице
rc=1
restored rc=0
```

### К6 — контекст ролей (Ф-4): долг оркестратора, после merge
```
$ bash mobile/scripts/check-coding-standards-context.sh --repo . --contract 162 --make-task /tmp/dev-harness-verify/Rev162v3/repo/scripts/make_task.sh
FAIL роль architect: в harness.project.json нет строки kind=rules path=docs/CODING-STANDARDS.md mandatory=true с ролью architect
FAIL роль architect: make_task отказал rc=1: ОТКАЗ: нет свидетельства модели: architect
… (то же для implementer, reviewer, adversary)
РЕЗУЛЬТАТ: FAIL (роли без подтверждения: architect implementer reviewer adversary)
rc=1
```
Своя мера:
- `jq '[.. | objects | select(.path? == "docs/CODING-STANDARDS.md")] | length' harness.project.json` → 0;
- в `.harness/registry/` лежат только `ci_parity_debt.txt` и `ci_parity_exceptions.txt`, `trace.tsv` нет;
- тегов `frozen/*` в продукте 0.

По frozen 162/3 строку добавляют «после reviewer и merge #158» (И-4). §Порядок: «→ merge #158 → оркестратор обеспечивает замороженный контракт проекта + `.harness/registry/trace.tsv` и ставит mandatory contextPack-строку → критерий контекста». Критерий 6: «До merge #158 этот пункт NOT_RUN».

**Условие done ≠ блок поставки.** Merge PR #158 этим пунктом не заблокирован. Предмет 162 НЕ done, пока на продукте после merge эта команда не даст rc 0 по четырём ролям, а пара «удалить роль» — rc 1 с именем роли.

## (3) Ф-3 — CI PR mob#158 на неизменном head

```
$ gh api repos/a3ka/Complior-mob/actions/runs/42871658274 --jq '[.id,.head_sha,.event,.status,.conclusion,.run_attempt,.name,.updated_at]|@tsv'
42871658274	a1b3d41a8d6fa6f79779eef6732c191d874529ba	pull_request	completed	success	2	mobile	2026-11-10T19:02:24Z
$ gh pr checks 158 --repo a3ka/Complior-mob        (rc 0)
android-e2e              pass      10s
e2e-screen               skipping  0
mobile-regression-signal skipping  0
build-apk                pass      3m44s
e2e-erstinformation      pass      3m17s
e2e-first-run            pass      3m4s
e2e-pilot                pass      3m26s
e2e-splash               pass      2m21s
e2e-start                pass      2m14s
quality                  pass      8m26s
select-screens           pass      11s
```
- Обязательные проверки main из `gh api repos/a3ka/Complior-mob/rules/branches/main`: `quality` и `android-e2e`, `strict_required_status_checks_policy: true`. Обе pass.
- `gh api …/compare/main...a1b3` → `ahead 6 0`: head не отстаёт от main 50699aeea.
- `gh pr view 158`: `OPEN`, `MERGEABLE`, `headRefOid=a1b3d41a8…`.
- Ветки, отмеченные `skipping`, (`e2e-screen`, `mobile-regression-signal`) не входят в обязательные. Ф-3 закрыт.

## Проверки гейта

- **Область.** Изменения PR и зеркала входят в ЗОНУ implementer frozen 162/3. Превышения нет. `harness.project.json` не тронут (ЗОНА допускает правку, но поставка её не делает: строка — шаг оркестратора после merge).
- **Сырой вывод.** Приведён выше. Ни одно утверждение не взято из отчёта автора.
- **Проверка не переписана под реализацию.** `check_policy_delta.py` и `red_policy_delta.sh` — файлы ЗОНЫ architect в коммите тега 82842c994. На OBJECT и origin/main они равны тегу (`git diff --quiet` rc 0). Implementer в харнессе трогал только 7 продуктовых путей.
- **Красное предъявлено.** К1–К5 — пары выше. Для нового барьера v3 проверен мутант реализации проверки: red-батарея красная, rc 1.
- **Атомарность.** Продукт: `932ee4a` и `54fd5c83` — отдельные коммиты `162: …`, плюс merge main (С-5). Зеркало: три коммита `162: …` поверх main харнесса.
- **Норма.** Нормативных документов харнесса дифф не трогает.
- **Счётные утверждения своей мерой.** 123/123 и разбиение по типам — python-разбор TSV. 7 файлов — `diff --name-status` и `gh pr view --json files`. numstat `1\t1` — `od -c`. Равенство 7 файлов зеркала — `rev-parse` блобов. Пин — `sha256sum` и границы `sed -n`.

## Паразитная сложность (050)

Со времени вызова 1 у пяти файлов поставки блобы те же (da93d347, 7ad58f71, 1d8d207b, fa8bc118, bad8c990). Ответы вызова 1 по ним (`verdicts/review/contracts-162-impl-v1.md` §Паразитная сложность, все ESSENTIAL) остаются в силе. Новые артефакты кандидата к 932ee4a:

- **Элемент `"scripts/coding-standards-claims.tsv"` в `mobileFiles`.**
  1. Свойство: §Предмет «одной точной строкой … для прохождения обязательного CI `quality`», критерий 2 `structure: OK`.
  2. Состояние: одна явная запись политики, видна в выводе `check-structure`.
  3. Связанных правок: 1 файл, дифф число не увеличил.
  4. Интерфейс `check-structure.cjs` не менялся.
  5. Потребитель — `npm run lint` job `quality`.

  ESSENTIAL: перенос таблицы отвергнут §Frontier.
- **Две строки STRUCTURE.md** (стр. 71 и 169).
  1. Свойство: §Существующее/§Предмет «две правки STRUCTURE.md из PR #158».
  2. Новое состояние: нет.
  3. Связанных правок: 1 файл.
  4. Интерфейса нет.
  5. Потребитель — читатели структуры и пин К4.

  ESSENTIAL.
- **Merge-коммит a1b3.** Сам артефактом сложности не является: дерево вне 7 файлов PR равно main.

Находок ACCIDENTAL нет.

## ПРОВОДКА (038)

`guard=scripts/check_document.sh` существует. Исполнен preflight-ом К1: rc 0, пара rc 1. Это барьер именно документного предмета 162. Продуктовый checker и таблица не заявлены guard-ом харнесса или CI-гейтом. CI харнесса дифф не трогает. Обоснование ПРОВОДКА-ЭНФОРСМЕНТ честное: поведенческой нормы 029-класса в контракте нет.

## СВЕРКА-СТАНДАРТОВ

Предпосылка нормы — `AGENTS.md` продукта объявляет документ стандарта. Пока она не выполнена: `git grep -nE 'CODING-STANDARDS|ARCHITECTURE\.md' a1b3 -- AGENTS.md mobile/AGENTS.md STRUCTURE.md` → rc 1. Строку объявления ставит шаг Ф-4. Сверка по разделам стандарта PR, которые затрагивает дифф:

СВЕРКА-СТАНДАРТОВ:
- docs/CODING-STANDARDS.md §1 п.3 (`STRUCTURE.md` + `mobile/structure-policy.json` — куда класть код) — соответствует: `mobileFiles` разрешает `scripts/coding-standards-claims.tsv`, `check-structure` в CI-раскладке → `structure: OK`;
- docs/CODING-STANDARDS.md §8 (API и заглушки) / STRUCTURE.md §5 — соответствует: правка «типы вручную по `api/mock-5_8.json`; генерация — цель» совпадает с `mobile/src/api/generated/api-5_8.ts:1-3`, генератора в дереве нет;
- docs/CODING-STANDARDS.md §14 (ветка/PR; коммит `NNN: …`; обязательные `quality` и `android-e2e`; merge нажимает владелец) — соответствует: `932ee4a` и `54fd5c83` начинаются с `162: …`, `quality` и `android-e2e` pass на a1b3. Merge-коммит a1b3 без `NNN:` — совет С-5. Merge PR по §14 нажимает владелец;
- docs/CODING-STANDARDS.md §3/§15 (модули TS, запреты кода) — не применимо: 162-дифф к main не содержит TS/JS.

## Независимость

Судья — anthropic/claude-opus-5-5. Автор продуктовых коммитов — implementer minimax/MiniMax-M3 [по вердикту v2; трассу автора в этом вызове не перепроверял]. По контракту 166 совпадение моделей отказа не даёт.

## Ресурсы

Одноразовые каталоги `/tmp/dev-harness-verify/Rev162v3/{mob,vc,ci,moved,c1,d5-failures,d5-links,mut}` удалены после прогона. Клон харнесса `repo` оставлен до push оркестратором. Продуктовый чекаут `/home/harness/projects/Complior-mob` только читался.
