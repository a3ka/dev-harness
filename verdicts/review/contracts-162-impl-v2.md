FAIL
OBJECT=e2f9897de49ad5b4e4206ae445c0176d8265d8a6
СУД: repo=dev-harness (контракт frozen/contracts/162/2, блоб b8dd55481375220a0e029ad240ed13730214134586de6894e2c81ba960ddd50b) + Complior-mob (продукт, PR #158, ветка wip/136/standard, head a1b3d41a8d6fa6f79779eef6732c191d874529ba); предмет=162; фаза=реализация (перед слиянием PR #158); роль=reviewer; вызов=2 (scoped); сессия=Rev162v2 (харнесс-сессия c907157c); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; автор=implementer minimax/MiniMax-M3; предыдущий=verdicts/review/contracts-162-impl-v1.md

# Вердикт reviewer — 162, реализация, вызов 2 (scoped)

## Итог

Поставка implementer верна. Три условия accept из вызова 1 выполнены по смыслу:
- (а) CI-раскладка `check-structure.cjs` → `structure: OK`, rc 0; красная пара тоже есть.
- (б) `verify-coding-standards.sh` → 123/123, rc 0.
- (в) 162-дельта к 932ee4a — ровно один элемент `mobileFiles`. Слияние полное, строки 143 не потеряны.

Внутри ЗОНЫ implementer дефектов нет. Правка продукта не требуется.

Принять кандидата a1b3d41a8 всё же нельзя. Слияние с main (143) сломало замороженные обязательства, которые вызов 1 видел зелёными на 932ee4a. Суд не отменяет машинный отказ и не меняет критерий, поэтому FAIL:
- **Ф-1** (блок, класс — дефект контракта, architect). `check-context-sources.py` на кандидате → `CITATIONS FAIL: SHA256: STRUCTURE.md`, rc 1. Пин `STRUCTURE.md@60d9d6c3…` устарел после слияния 143.
- **Ф-2** (блок буквы, класс — дефект текста контракта, architect). Буквальные ожидания критерия 3 (`1<TAB>0`, имена файлов на `HEAD`) недостижимы. Смысл критерия выполнен.
- **Ф-3** (блок слияния, класс — CI/инфраструктура, не implementer). Обязательная проверка `android-e2e` на head a1b3d41a8 красная: эмулятор `e2e-erstinformation` в состоянии `offline`.

Путь к accept:
1. Architect выпускает v3. В ней перепин `ИСТОЧНИК: STRUCTURE.md@b91af22dfd3ebbd231c962028cc26bc0c2a39a6dd10f9fcbfec153e7c1b71e11 §5 строки=167-179` (Ф-1) и исправленная буква критерия 3 (Ф-2). Поведение продукта и состав поставки при этом не меняются.
2. Оркестратор перезапускает CI PR #158, нужен зелёный `android-e2e` (Ф-3).
3. Scoped-повтор: на текущем блобе продукта проверить только Ф-1 и Ф-2, плюс зелёный CI на неизменном head.

Мой вызов по 162 — 2/2 (HANDOFF). Решение о следующем круге принимает оркестратор по пределу кругов.

Зеркало `wip/162/implementer` (OBJECT) не сверялось: по заданию его нет в origin, сверялся только продукт. sha256 файлов ЗОНЫ в зеркале — NOT_RUN по прямому указанию задания.

## Клоны и кандидат

- Харнесс: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev162v2/repo`, main `4d02a7e7a72ca8efc744ba13330329d8bb0a2ec7`. Теги `frozen/contracts/162/{1,2}` получены fetch-ем.
- Продукт: объекты взяты из `/home/harness/projects/Complior-mob`, origin переставлен на `https://github.com/a3ka/Complior-mob`. Выполнен `fetch main wip/136/standard pull/158/head`:
  ```
  a1b3d41a8d6fa6f79779eef6732c191d874529ba   (pull/158/head)
  a1b3d41a8d6fa6f79779eef6732c191d874529ba   (wip/136/standard)
  50699aeea16675980cb92175248c03ac1fbc62ab   (main)
  ```
- `gh pr view 158`: `headRefOid=a1b3d41a8…`, `state=OPEN`, `mergeable=MERGEABLE`. Файлы: STRUCTURE.md, docs/CODING-STANDARDS.evidence.json, docs/CODING-STANDARDS.md, mobile/scripts/check-coding-standards-context.sh, mobile/scripts/coding-standards-claims.tsv, mobile/scripts/verify-coding-standards.sh, mobile/structure-policy.json.

## Полнота merge-коммита

`git rev-list --parents -n1 a1b3d41a8` (rc 0):
```
a1b3d41a8d6fa6f79779eef6732c191d874529ba 54fd5c83c7b4e9e5ad5fc6dd1e162c9766bbfea4 50699aeea16675980cb92175248c03ac1fbc62ab
```
Родителей два, как заявлено. `merge-base --is-ancestor`: 932ee4a → a1b3 rc 0, 50699aeea → a1b3 rc 0.

`git diff --name-status 50699aeea a1b3d41a8` (rc 0) — ровно 7 файлов PR, все ⊆ ЗОНА implementer frozen 162/2:
```
M STRUCTURE.md                                       2 2
A docs/CODING-STANDARDS.evidence.json               82 0
A docs/CODING-STANDARDS.md                         164 0
A mobile/scripts/check-coding-standards-context.sh 147 0
A mobile/scripts/coding-standards-claims.tsv       124 0
A mobile/scripts/verify-coding-standards.sh        486 0
M mobile/structure-policy.json                       1 1
```
Вне этих 7 файлов дерево кандидата равно main, значит из 143 ничего не потеряно. Внутри двух изменённых файлов:
- **structure-policy.json**, JSON-разбор main → a1b3. Отличается один ключ `mobileFiles`: `added: ['scripts/coding-standards-claims.tsv'] removed: []`, порядок прочих элементов сохранён, «differing keys: 1». Word-diff: `-"ci-screens.json"],` → `+"ci-screens.json", "scripts/coding-standards-claims.tsv"],`. Все три изменения 143 в этом файле сохранены.
- **STRUCTURE.md.** Тела ханков `diff -U0 main..a1b3` и `diff -U0 merge-base..54fd5c83` дают один sha256: `f6f04846182e28b5cf6040c1ed2c866b9bb3efd95f99963daf513b8c48abc487` (оба). Это ровно две строки PR (`generated/` — типы вручную, генерация — цель), сдвинутые на +3. Девять вставок и пять удалений 143 сохранены.
- Блобы пяти прочих файлов ЗОНЫ на 932ee4a, 54fd5c83 и a1b3 совпадают: CODING-STANDARDS.md `da93d347`, evidence `7ad58f71`, verify `1d8d207b`, claims `fa8bc118`, context `bad8c990`. `harness.project.json` = main = `71a5c5db`, не тронут.

## (в) Дельта к 932ee4a — своей мерой

- `git rev-list --parents 932ee4a..54fd5c83` → один коммит `54fd5c83`, родитель 932ee4a. Сообщение «162: структурная политика допускает таблицу сверки стандарта (mobileFiles)», автор `implementer <implementer@dev-harness.local>`. Атомарно.
- `git diff --name-only 932ee4a..54fd5c83` → `mobile/structure-policy.json`, rc 0.
- `git diff --numstat 932ee4a..54fd5c83 -- mobile/structure-policy.json` (od -c) → `1 \t 1 \t mobile/structure-policy.json`.
- JSON-разбор 932ee4a → 54fd5c83: `mobileFiles added: ['scripts/coding-standards-claims.tsv'] removed: [] lenA 18 lenB 19 order preserved: true`.

Добавленный элемент — ровно `"scripts/coding-standards-claims.tsv"` внутри `mobileFiles`. Второго изменения нет, прежние элементы не удалены. Пара «diff не одна разрешающая строка» не срабатывает.

## (а) CI-раскладка `check-structure`

Одноразовый клон `/tmp/dev-harness-verify/Rev162v2/ci` @ a1b3d41a8, `git status` чист.
- Без выноса: `outside allowed` 17 строк (пачки e2e-erstinformation и e2e-first-run, kompozicija.stand-in.sh). Таблица среди них не встречается (grep `coding-standards` = 0), rc 1.
- Вынос — шаг `quality` из `.github/workflows/mobile.yml:414-436` на a1b3:
  - `node mobile/scripts/select-ci-screens.cjs --mode inventar --repo .` → `PACHKA mobile/e2e-erstinformation/`, `PACHKA mobile/e2e-first-run/`, `INVENTAR OK pachek=2 rabotnikov=5`, rc 0;
  - mv обеих пачек и `mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh`. Каталогов `.harness*` в клоне нет: в CI это отдельные checkout-ы.
- `cd mobile && node scripts/check-structure.cjs` (так его вызывает `npm run lint`) → `structure: OK (repository inventory; external trees excluded)`, rc 0. Из корня `node mobile/scripts/check-structure.cjs` → то же, rc 0.
- Пара на той же копии: строка удалена из `mobileFiles` (numstat `1 1`) → `mobile/scripts/coding-standards-claims.tsv: file outside allowed location/type`, rc 1. `git checkout` → `structure: OK`, rc 0.
- GitHub: прогон `42871658274` (event pull_request, headSha a1b3d41a8) → `quality pass 8m26s`.

## (б) `verify-coding-standards.sh` — 123/123

Одноразовый клон `/tmp/dev-harness-verify/Rev162v2/vc` @ a1b3d41a8, `tmp/` отсутствует (`ls: cannot access 'tmp'`). `bash mobile/scripts/verify-coding-standards.sh` → rc 0:
```
утверждений объявлено: 123; зелёных: 123; красных: 0
тип exists: всего 18, ok 18, fail 0
тип goal: всего 6, ok 6, fail 0
тип grep: всего 89, ok 89, fail 0
тип grep-none: всего 6, ok 6, fail 0
тип json: всего 4, ok 4, fail 0
РЕЗУЛЬТАТ: OK (123 из 123 объявленных утверждений)
```
Своя мера — python-разбор TSV, не checker:
- 123 строки, у всех 6 полей; разбиение exists 18 / goal 6 / grep 89 / grep-none 6 / json 4;
- уникальных id 123, пустых id 0;
- множество id из строк `OK <id>` вывода равно множеству id таблицы: `table 123 ok-ids 123 equal True`.

Пара на слитом дереве: удалён носитель c85 `mobile/src/features/auth/auth-tokens.ts` → `FAIL c85: носитель не подтверждает правило: id=c85 §10 — носитель отсутствует: …`, `РЕЗУЛЬТАТ: FAIL`, rc 1. `git checkout` → 123/123, rc 0. Checker и таблица по блобу равны 932ee4a, поэтому прочие пары вызова 1 переносятся.

## Критерии, перенесённые из вызова 1, на новом кандидате

- **Критерий 1 (preflight харнесса).** `bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight` → rc 0. Рабочий файл = frozen/2 (`git diff --quiet` rc 0).
- **Критерий 5 (валидаторы 027, текст v2).** Сначала `cmp -s <(git show frozen/contracts/162/2:contracts/162-standart-koda-mob.md) "$P/.harness/contracts/162-standart-koda-mob.md"` → rc 0, затем команда node из контракта дословно с `P=/tmp/dev-harness-verify/Rev162v2/vc` → rc 0. Пара на отдельной копии `d5` (evidence без `Пустая-выборка`) → `ОТКАЗ DOC: package.failures не покрывает required: Пустая-выборка`, rc 1.
- **Критерий 4 (цитаты)** — **красный**, см. Ф-1.
- **Критерий 3 (буква)** — **красный**, см. Ф-2.
- **Критерий 6 (контекст)** — NOT_RUN по контракту, см. Ф-4.

## Находки

### Ф-1 — блок; класс: дефект контракта (пин устарел после слияния 143), architect

Копия frozen-текста лежит в `vc/.harness/contracts/162-standart-koda-mob.md`, sha256 b8dd5548… = `git show frozen/contracts/162/2:…`. Ожидаемые пины сняты до прогона:
```
b32fb106…a436  docs/CODING-STANDARDS.md        (пин b32fb106 — равен)
b91af22d…1e11  STRUCTURE.md                    (пин 60d9d6c3 — НЕ равен)
e76d217b…9f9a  AGENTS.md                       (равен)
ac1e9dbe…e4c   docs/context/CONTEXT-POLICY.md  (равен)
```
`python3 mobile/scripts/check-context-sources.py --root . --contract .harness/contracts/162-standart-koda-mob.md` → `CITATIONS FAIL: SHA256: STRUCTURE.md`, rc 1.

Причина установлена своей мерой. sha256 `STRUCTURE.md` по коммитам: 1e9b07ce / 932ee4a / 54fd5c83 = `60d9d6c3…`, main 50699aeea = `9f453ce0…`, a1b3 = `b91af22d…`. Вставки 143 стоят выше §5: строки 25, 28 и 52. Поэтому цитата сдвинулась на +3: `diff <(54fd5c83:STRUCTURE.md 164-176) <(a1b3:STRUCTURE.md 167-179)` rc 0, содержимое побайтно то же. Диагностика на том же дереве: STRUCTURE.md заменён версией 54fd5c83 (sha256 60d9d6c3…) → `CITATIONS OK count=5`, rc 0. Откат → снова FAIL.

Принять кандидата при красном машинном барьере нельзя:
- Обязательство — критерий 4 «rc 0 `CITATIONS OK count=5`» и Модель угроз «несоответствие пина документа продукту выявляется до принятия».
- Фрагмент — `ИСТОЧНИК: STRUCTURE.md@60d9d6c3… §5 строки=164-176`.
- Противоречие — head PR #158 несёт STRUCTURE.md b91af22d…; ПРЕДПОСЫЛКИ требуют «идентичных байтов файлов product PR».

Implementer этот дефект не устранит. Вернуть STRUCTURE.md к 60d9d6c3 значит стереть строки 143, а 143 ими владеет. Минимальная форма исправления — перепин в контракте v3: `STRUCTURE.md@b91af22dfd3ebbd231c962028cc26bc0c2a39a6dd10f9fcbfec153e7c1b71e11 §5 строки=167-179`. Продукт не меняется.

### Ф-2 — блок буквы; класс: дефект текста контракта (критерий 3), architect

Критерий 3 ожидает от `git diff --numstat 932ee4a..HEAD -- mobile/structure-policy.json` ровно `1<TAB>0<TAB>…`, а от `--name-only` — ровно `mobile/structure-policy.json`. Своя мера:
- на 162-коммите 54fd5c83 name-only совпадает, но numstat даёт `1\t1`. `mobileFiles` — однострочный JSON-массив, и добавление элемента неизбежно заменяет эту строку, так что `1\t0` недостижимо ни при какой честной поставке;
- на `HEAD`=a1b3 numstat даёт `4\t4`, а name-only — 11 файлов: `.github/workflows/mobile.yml`, `.gitignore`, `.harness/registry/ci_parity_{debt,exceptions}.txt`, `STRUCTURE.md`, `mobile/ci-screens.json`, `mobile/scripts/{ci-aggregate,run-ci-screen,select-ci-screens}.cjs`, `mobile/structure-policy.json`, `package.json`. Это слитые правки 143.

Смысл критерия — «единственная добавленная строка = `"scripts/coding-standards-claims.tsv"` в `mobileFiles`, прежние не удалены». Он выполнен и доказан разложением выше: 932ee4a→54fd5c83 плюс main→a1b3. Буква красна. Исправление в том же v3: ожидать `1<TAB>1` на диапазоне `932ee4a..<162-коммит>` либо поэлементную JSON-сверку и отделить main через `git diff <main>..HEAD`.

### Ф-3 — блок слияния; класс: CI/инфраструктура раннера, не implementer

`gh pr checks 158` на a1b3 (прогон 42871658274, headSha a1b3d41a8) возвращает rc 1:
```
android-e2e          fail      AGREGAT_OTKAZ: LEGACY_OTKAZ — e2e-erstinformation
e2e-erstinformation  fail      PRICHINA E2E_NE_PROSHLA rc=1; ДИАГНОСТИКА 118: adb devices → emulator-5566 offline
quality pass; build-apk pass; e2e-first-run/e2e-pilot/e2e-splash/e2e-start pass; e2e-screen skipping
```
`docs/CODING-STANDARDS.md` §14 продукта: «обязательные проверки `quality` и `android-e2e`». Последний push-прогон main 50699aeea (42869890722) — success.

Как 162 связан с этим прогоном:
- 162-дифф к main не трогает ни приложение, ни e2e;
- `mobile/structure-policy.json` входит в `shared.puti` карты `mobile/ci-screens.json` (COMMON_CHANGE), поэтому прогнались все legacy-экраны;
- в журнале нет отказа Maestro или приёмки, только эмулятор `offline`. [INFERENCE: сбой раннера/эмулятора, не следствие диффа.]

Требуется перезапуск CI PR #158 на неизменном head и зелёный `android-e2e` до merge. Reviewer прогон не перезапускает: у него только чтение.

### Ф-4 — не блок поставки; условие done 162 (долг оркестратора/проводки)

`bash mobile/scripts/check-coding-standards-context.sh --repo . --contract 162 --make-task /tmp/dev-harness-verify/Rev162v2/repo/scripts/make_task.sh` на a1b3 → rc 1, `РЕЗУЛЬТАТ: FAIL (роли без подтверждения: architect implementer reviewer adversary)`. По каждой роли две причины: «в harness.project.json нет строки kind=rules path=docs/CODING-STANDARDS.md mandatory=true с ролью <R>» и «make_task отказал rc=1: ОТКАЗ: нет свидетельства модели: <R>». Своя мера: `jq` по строкам с этим путём → 0; в `.harness/registry/` только `ci_parity_*`, `trace.tsv` нет; тегов `frozen/*` в продукте 0.

Почему это условие done, а не блок поставки. Текст frozen 162/2 явно относит пункт к шагам после merge:
- И-4: «добавляет одну mandatory строку … **после reviewer и merge #158**»;
- §Порядок: «→ merge #158 → **оркестратор** обеспечивает замороженный контракт проекта + `.harness/registry/trace.tsv` и ставит mandatory contextPack-строку → критерий контекста 5 на живом продукте»;
- критерий 6: «До merge #158 этот пункт NOT_RUN».

Предмет 162 НЕ done, пока на продукте после merge эта команда не даст rc 0 по четырём ролям, а пара (удалить роль) — rc 1 с именем роли. Отказ «нет свидетельства модели» — свойство среды запуска make_task. [INFERENCE: на живом шаге оркестратор подаёт трассу.]

### Э-2 / Э-3 вызова 1 — исправлены в v2 (подтверждено)

`git diff frozen/contracts/162/1^{commit} frozen/contracts/162/2^{commit} -- contracts/162-…` → 30 вставок и 8 удалений.
- **Э-2.** Строка v1 `bash scripts/check_document.sh --root <корень-продукта> … --check` заменена прямым вызовом валидаторов `doc_contract.ts` с `cmp` копии. Добавлена оговорка «`--check` на пути 162 даёт rc 2 `NOT_IMPLEMENTED` … и не является этой приёмочной командой». Исполнено выше: rc 0, пара rc 1.
- **Э-3.** Критерий 6 v2: «для reviewer добавляет `--task-file <временный-служебный-файл>`».

### Советы (не блок)

- С-5. Сообщение merge-коммита a1b3 — стандартное «Merge remote-tracking branch 'origin/main' into wip/136/standard» без предмета `NNN:`. §14 описывает первую строку обычного коммита; для merge-коммита дерево правила не задаёт.
- С-1…С-3 из вызова 1 по-прежнему отложены контрактом (§Порядок). Перепин Ф-1 частично закрывает класс С-3 для STRUCTURE.md.

## Паразитная сложность (050)

Новый артефакт диффа к 932ee4a — один элемент `"scripts/coding-standards-claims.tsv"` в `mobileFiles`:
1. Свойство — §Предмет «допускается одной точной строкой … для прохождения обязательного CI `quality`» и критерий 2 (`structure: OK`).
2. Новое состояние — одна запись политики, явная, видна в выводе `check-structure`.
3. При правке того же свойства меняется 1 файл; дифф это число не увеличил.
4. Интерфейс `check-structure.cjs` не изменён.
5. Потребитель — шаг `npm run lint` job `quality`. Грамматику политики элемент не дублирует.

**ESSENTIAL**: более простой формы (перенос таблицы) контракт не допускает, см. §Frontier. Находок ACCIDENTAL нет.

## ПРОВОДКА (038)

`guard=scripts/check_document.sh` существует и исполнен preflight-ом критерия 1 (rc 0). Продуктовый checker и таблица не заявлены guard-ом харнесса или CI-гейтом, и CI харнесса не тронут. Обоснование ПРОВОДКА-ЭНФОРСМЕНТ честное: поведенческой нормы 029-класса нет.

## СВЕРКА-СТАНДАРТОВ

Предпосылка нормы — `AGENTS.md` продукта объявляет стандарт кода. Она по-прежнему не выполнена: `grep -nE 'CODING-STANDARDS|ARCHITECTURE' AGENTS.md mobile/AGENTS.md STRUCTURE.md` → rc 1. Сверка дана по разделам, которые затрагивает дифф:

СВЕРКА-СТАНДАРТОВ:
- docs/CODING-STANDARDS.md §1 п.3 (`STRUCTURE.md` + `mobile/structure-policy.json` — куда класть код) — соответствует: `mobile/structure-policy.json` `mobileFiles` теперь разрешает `scripts/coding-standards-claims.tsv`, `check-structure` → OK (Э-1 вызова 1 закрыт);
- docs/CODING-STANDARDS.md §14 (одна задача — ветка/PR; коммит `NNN: …`; обязательные `quality` и `android-e2e`) — расхождение: PR #158 head a1b3d41a8, `android-e2e` fail (Ф-3); коммит 54fd5c83 `162: …` — соответствует;
- docs/CODING-STANDARDS.md §3/§15 (модули TS, запреты кода) — не применимо: 162-дифф не содержит TS/JS.

## Независимость

Судья — anthropic/claude-opus-5-5, автор — minimax/MiniMax-M3. Семейства разные.

## Ресурсы

Одноразовые клоны продукта `prod`, `ci`, `vc` и каталоги `d5`, `moved` в `/tmp/dev-harness-verify/Rev162v2/` удалены после прогона. Одноразовых скриптов нет: мутации делались командами, перечисленными выше. Клон харнесса `repo` оставлен до push оркестратором.
