ESCALATE
OBJECT=932ee4a54352a8731fbb6570da30faae7406c10a
СУД: repo=dev-harness (контракт frozen/contracts/162/1) + Complior-mob (реализация, ветка wip/162/checker, база 1e9b07ce594d7b3a65e92ceb2dcadd27bff0d6bf); предмет=162; фаза=реализация (перед слиянием PR #158); роль=reviewer; сессия=Rev162; модель-план=audit (@opus, config/agent_models.json); модель-факт=anthropic/claude-opus-5-5; вызов=1
Находки: `.review/2026-11-05-62.md` (копия: /tmp/dev-harness-verify/Rev162/review-files/.review/2026-11-05-62.md; перенос в main — оркестратор)

# Вердикт reviewer — 162, реализация, вызов 1/1

## Итог

Внутри ЗОНЫ implementer поставка верна. Блокеров implementer нет.
- Область правки чиста.
- Checker и таблица воспроизводят базу 123/123. Колонки id/раздел/тип/носитель/шаблон байт-в-байт равны scratch-замеру, пороги не ослаблены.
- Каждая пара критериев 2 и 3, а также пары критерия 5 на имитации, краснеет своей мерой и по своей причине.

Слияние PR #158 с этим коммитом тем не менее невозможно: **Э-1**. Таблица, путь которой задан ЗОНОЙ
контракта (`mobile/scripts/coding-standards-claims.tsv`), отвергается действующим
`check-structure.cjs`. В CI-раскладке это ЕДИНСТВЕННЫЙ отказ, поэтому обязательный `quality`
станет красным: база rc 0 → OBJECT rc 1.

Правка нужного файла (`mobile/structure-policy.json`) вне ЗОНЫ implementer. Решает architect
(правка ЗОНЫ контракта) или владелец, отсюда ESCALATE, а не FAIL. Ещё два дефекта контракта не
блокируют поставку, но делают буквальные команды критериев 4 и 5 неисполнимыми (Э-2, Э-3).

**Accept наступает, когда** контракт допускает одну строку `"scripts/coding-standards-claims.tsv"` в
`mobile/structure-policy.json` → `mobileFiles`, а implementer её добавил. Scoped-повтор reviewer на
новом SHA проверяет:
- (а) CI-раскладка `node mobile/scripts/check-structure.cjs` → rc 0;
- (б) `bash mobile/scripts/verify-coding-standards.sh` → rc 0, 123/123;
- (в) `git diff 932ee4a..<новый>` = только эта строка.

Остальное в этом вердикте переносится на новый кандидат только при неизменных поведении и критерии.

## 1. Область правки

`git -C /tmp/dev-harness-verify/Impl162/mob diff --name-only 1e9b07ce5..932ee4a54` (rc 0):
```
docs/CODING-STANDARDS.evidence.json
mobile/scripts/check-coding-standards-context.sh
mobile/scripts/coding-standards-claims.tsv
mobile/scripts/verify-coding-standards.sh
```
`--stat`: 4 файла, +839 −0, удалений нет. Все четыре пути ⊆ ЗОНА implementer frozen/contracts/162/1.

Проверено также:
- `docs/CODING-STANDARDS.md`, `STRUCTURE.md`, `harness.project.json` не тронуты (их нет в диффе).
- Один коммит, автор `implementer <implementer@dev-harness.local>`, ссылка на предмет `162:`. Атомарность соблюдена.
- `wip/162/checker` = `wip/162/implementer` (зеркало в .git харнесса) = OBJECT.
- Харнесс: `bash scripts/check_no_leak.sh --check /home/harness/dev-harness` → «основной чекаут чист», rc 0; `git status --short | wc -l` → 0.
- Нормативные документы не правились. Существующие проверки и фикстуры не переписаны: дифф только добавляет.

PR #158 (`gh`/pr://): файлы STRUCTURE.md (+2 −2, строки 68 и 166, коммит 42440ee) и
docs/CODING-STANDARDS.md (+164). Совпадает с §Существующее и evidence «Структура».

## 2. Сырой вывод своей мерой

Все прогоны выполнены на `git clone --shared` клонах в /tmp/dev-harness-verify/Rev162/
({mob, disp, ctx}) на OBJECT.

### Критерий 1 (харнесс, preflight)

- `bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight` → rc 0. Рабочий файл = frozen: `git diff --quiet frozen/contracts/162/1^{commit} -- contracts/162-…` rc 0.
- Пара на копии (/tmp/…/Rev162/pre): удалён раздел `## Док-приёмка` (1275 знаков) → `ОТКАЗ DOC: contract: нет раздела «## Док-приёмка»` rc 1. Без удаления та же копия → rc 0.

### Критерий 2: `bash mobile/scripts/verify-coding-standards.sh` из корня продукта, чистый checkout без tmp/

rc 0, итог:
```
утверждений объявлено: 123; зелёных: 123; красных: 0
тип exists: всего 18, ok 18, fail 0
тип goal: всего 6, ok 6, fail 0
тип grep: всего 89, ok 89, fail 0
тип grep-none: всего 6, ok 6, fail 0
тип json: всего 4, ok 4, fail 0
РЕЗУЛЬТАТ: OK (123 из 123 объявленных утверждений)
```

Своя мера, другой командой (python-разбор TSV, не checker):
- таблица 123 строки + заголовок, все по 6 полей;
- типы exists 18 / goal 6 / grep 89 / grep-none 6 / json 4;
- id c01…c119 без c49 и c73, плюс g01…g06; дублей нет.

Сверка со scratch `wip-136-standard/tmp/claims.tsv` (тот же разбор):
- колонки 0, 1, 3, 4, 5 (id, раздел, тип, носитель, шаблон) — 0 расхождений на 123 строках;
- изменена только колонка «утверждение», 123/123: пересказ заменён дословным фрагментом стандарта.

Пары и мутанты (`rev_mut_verify.py`). Каждый прогон — отдельная мутация. После `git reset --hard && git clean` честная копия снова rc 0, 123/123: проверено после КАЖДОЙ мутации.

| мутация | rc | ключевой вывод |
|---|---|---|
| P1 удалён файл носителя c85 `auth-tokens.ts` | 1 | `FAIL c85: … носитель отсутствует: mobile/src/features/auth/auth-tokens.ts` (122/123) |
| P2 строка x90: носитель package.json, формулировки в стандарте нет | 1 | `FAIL x90: носитель без правила: mobile/package.json — id=x90 §5 …` |
| P3 строка x91: реальная формулировка §5, пустой носитель, не цель | 1 | `FAIL x91: правило без носителя: id=x91 §5 …` |
| P4 только заголовок | 1 | `FAIL пустая выборка: … ноль утверждений` |
| P5 таблицы нет | 2 | `ОШИБКА (нечем проверить): нет таблицы утверждений` |
| P6 `git rm --cached` носителя c85 (файл на диске) | 1 | `FAIL c85: … носитель не отслеживается git` |
| P22 то же для grep-носителя c84 | 1 | `FAIL c84: … нет отслеживаемых файлов` |
| P7 c02 перенесён в §2 | 1 | `FAIL c02: правило не найдено … §2` + `носитель без правила: STRUCTURE.md` |
| P8 g04 перенацелена на `ui/notice.tsx` | 1 | `FAIL g04: … нарушения нет: mobile/src/ui/notice.tsx` |
| P9 g05: формулировка со строки без ЦЕЛЬ | 1 | `FAIL g05: цель не объявлена: … строка 131 стандарта не несёт слова ЦЕЛЬ` |
| P11 в стандарте изменена формулировка c85 | 1 | `FAIL c85: правило не найдено` + `носитель без правила` |
| P15 `as any` в `ui/notice.tsx` | 1 | `FAIL c45: шаблон найден, а утверждение «нет»: …notice.tsx:40` |
| P16 `export default` в `ui/notice.tsx` | 1 | `FAIL c22: шаблон найден …` |
| P17 / P18 тип пуст / `grepx` | 1 / 1 | `FAIL c41: невозможная проверка: неизвестный тип` |
| P19 дубль id c01 | 1 | `FAIL c01: таблица: дубль id c01` |
| P20 json `strict=false` | 1 | `FAIL c41: compilerOptions.strict = true, ожидалось: false` |
| P21 grep-none, пустой глоб | 1 | `FAIL c45: пустой глоб: нечего проверять` |
| P12 запуск из cwd=/tmp | 0 | 123/123 (корень от каталога скрипта) |
| P13 лишний аргумент | 2 | `ОШИБКА (нечем проверить): аргументов нет …` |
| **P10 у c85 стёрт id** | **0** | **`122 из 122`**: строка молча выпала (совет С-1) |

### Критерий 3: цитатная проверка (ctx, побайтовая копия frozen-текста в `.harness/contracts/162-standart-koda-mob.md`)

Ожидаемое снято ДО прогона: пины контракта b32fb106…, 60d9d6c3…, e76d217b…, ac1e9dbe…
`sha256sum` файлов OBJECT им равны. Копия контракта 178c0e3b… равна `git show frozen…|sha256sum`.

- `python3 mobile/scripts/check-context-sources.py --root . --contract .harness/contracts/162-standart-koda-mob.md` → `CITATIONS OK count=5`, rc 0.
- XOR одного байта (смещение 3000) `docs/CODING-STANDARDS.md` → `CITATIONS FAIL: SHA256: docs/CODING-STANDARDS.md`, rc 1. Откат → OK, rc 0.
- Своя доп. пара: байт 500 `STRUCTURE.md` → `CITATIONS FAIL: SHA256: STRUCTURE.md`, rc 1.

### Критерий 4: буквальная команда

`bash scripts/check_document.sh --root /tmp/…/Rev162/ctx --contract .harness/contracts/162-standart-koda-mob.md --check`
→ `NOT_IMPLEMENTED: нет frozen-спеки для .harness/contracts/162-standart-koda-mob.md`, rc 2.

Под `contracts/162-…` с тегом `frozen/contracts/162/1` в scratch-клоне — то же, rc 2.

Эквивалент на 062 (тот же байтовый текст, `contracts/062-…`, тег `frozen/contracts/062/1`):
- `--check` → rc 0;
- без failure `Пустая-выборка` → `ОТКАЗ DOC: package: package.failures не покрывает required: Пустая-выборка`, rc 1;
- без link `Скрипт-к-таблице` → `… package.links не покрывает required: Скрипт-к-таблице`, rc 1;
- откат → rc 0.

См. Э-2.

### Критерий 5: имитация на ctx

Состав имитации: копия контракта закоммичена в `.harness/contracts`, тег, `.harness/registry/trace.tsv` из orch/trace24f.tsv. Make_task — настоящий `/home/harness/dev-harness/scripts/make_task.sh`. Мутанты make_task — собственный стаб `mt_stub.sh`, а не стабы исполнителя.

| профиль / стаб | rc | вывод |
|---|---|---|
| C0 профиль ветки как есть (строки нет) | 1 | FAIL по каждой из 4 ролей: профиль + «нет самостоятельной строки «RULES: docs/CODING-STANDARDS.md»» + манифест |
| C1 строка `rules / docs/CODING-STANDARDS.md / architect,implementer,reviewer,adversary / true` | 0 | `OK роль <R>: … + 4 прочих правил профиля` ×4; `РЕЗУЛЬТАТ: OK (4 из 4 ролей …)` |
| C2 без architect | 1 | FAIL только `роль architect` (+ «строки с этим путём: rules\|implementer,reviewer,adversary\|true») |
| C3 без implementer | 1 | FAIL только `роль implementer` |
| C4 без reviewer | 1 | FAIL только `роль reviewer` |
| C5 без adversary | 1 | FAIL только `роль adversary` |
| C6 mandatory=false | 1 | FAIL у 4 ролей (профиль + манифест) |
| C7 kind=map | 1 | FAIL у 4 ролей |
| C8 путь с опечаткой | 1 | FAIL у 4 ролей + `make_task отказал rc=1: ОТКАЗ: источник недоступен` |
| S1 стаб: хвостовой пробел в RULES-строке у reviewer | 1 | FAIL только reviewer |
| S2 стаб: подстрока `….md.bak` у implementer | 1 | FAIL только implementer |
| S3 стаб: строка перенесена в секцию MAP у architect | 1 | FAIL только architect |
| S4 стаб: потеряна `RULES: AGENTS.md` у adversary | 1 | `FAIL роль adversary: … потеряно прочее правило профиля: нет строки «RULES: AGENTS.md»` |
| S5 стаб: отказ make_task у reviewer | 1 | `FAIL роль reviewer: make_task отказал rc=1` |
| B `make_task --repo . --role reviewer --contract 162` без `--task-file` | 1 | `ОТКАЗ: нет выданного задания: 162` (Э-3) |

«4 прочих правил» своей мерой: `jq -c '.contextPack.rows[]'` показывает kind=rules у CONTEXT-POLICY.md, OWNER-DECISIONS.md, AGENTS.md, structure-policy.json — 4.

### Структура (Э-1)

Своя мера: `node scripts/check-structure.cjs` из `mobile/`.
- Чистый клон без выноса: база — 25 строк `outside allowed`, rc 1; OBJECT — 26 (+ `mobile/scripts/coding-standards-claims.tsv`), rc 1.
- CI-раскладка — вынос, как в шаге `quality` (`mobile.yml:410-432`, затем `:434 npm run lint`: `select-ci-screens.cjs --mode inventar` → `PACHKA mobile/e2e-erstinformation/`, `PACHKA mobile/e2e-first-run/`; плюс `.harness`, `kompozicija.stand-in.sh`):
  - база: `structure: OK`, rc 0;
  - **OBJECT: `mobile/scripts/coding-standards-claims.tsv: file outside allowed location/type`, rc 1**;
  - OBJECT + одна строка `scripts/coding-standards-claims.tsv` в `mobileFiles`: `structure: OK`, rc 0.
- `gh pr checks 158 -R a3ka/Complior-mob`: `quality pass` на текущей голове PR.

## 3. Проверка не подогнана под реализацию

- **Пороги.** База 123/123 и разбиение типов сохранены. Носитель/шаблон/тип каждого утверждения байт-в-байт равны scratch-замеру. Добавлены проверки, которых в scratch не было:
  - формулировка ищется в непустой строке СВОЕЙ секции `## N.` (P7 и P11 красные);
  - носитель — только отслеживаемый файл (P6 и P22 красные);
  - строка цели обязана нести слово ЦЕЛЬ (P9).

  Ослабления нет.
- **Мутанты исполнителя** (`mutate_verify.py`: M4–M18; `mutate_ctx.py` + `stubs/s1–s5`) мутируют вход (таблицу, дерево, профиль, вывод make_task), а не сам checker. Повторять их одной командой — согласие, а не проверка. Своя батарея выше перекрывает их классы и добавляет P10, P15, P16, P20, P21, C8.
- **c17** («и в `features/onboarding/`» → `erstinformation-artboard.ts`) — СОВЕТ. Правило «малый хелпер дублируется между доменами» истинно: оба файла экспортируют `useArtboard` (`auth/artboard.ts:18`, `onboarding/erstinformation-artboard.ts:38`). Неточно имя файла в тексте стандарта, а текст закреплён SHA контракта. Правка — в следующей редакции стандарта с перепином (С-3).
- **c102** (`--runInBand` не назван в стандарте) — СОВЕТ: носитель утверждает то, чего правило не говорит. Честный носитель того же правила — `mobile/jest.config.js:15` `preset: 'jest-expo'` (С-2). Блоком не является: И-2 требует свидетельство правила на носителе, а `package.json` действительно несёт jest-конфигурацию RNTL (`:33,40`).
- **Семантика целей** (контракт поручает это ревьюеру, §Модель угроз):
  - **g05.** Прочитан `mobile/.maestro/cmp-mob-004-start.yaml`. Перед `tapOn start-composer-input` (стр. 32) стоит `assertVisible start-composer`, а не своей цели. `shell-tab-vorgaenge` (стр. 51) не подтверждён ни разу. Остальные 4 тапа подтверждены ранее. Перечень ЦЕЛИ (ровно эти две цели) верен.
  - **g04.** `frame.F02.01.body` в `src/i18n/` нет (grep), дубль `COPY_BODY` — `welcome-screen.tsx:4`.
  - **g02.** auth-screen 6 hex, welcome 2 hex: верно. У pilot-app 3 в стилях и 7 значений в 5 строках комментариев (С-3).
- **Не охваченные таблицей проверяемые нормы, своя мера** — истинны на дереве:
  - нет `extends Component`, `enum`, пустых `catch`;
  - `console.*` только в `erstinformation-demo-path.test.tsx:50,55,68`;
  - импорт с расширением только у двух канон-тестов 145;
  - нет каталогов `screens|services|shared|utils`;
  - `evidence: 'SYNTHETIC'` в mock/http.

  Полнота ЦЕЛЕЙ §5 и §10 неполная (С-3), но И-2 требует только, чтобы НАЗВАННЫЕ файлы несли нарушение, а это выполнено.

## 4. Дыры, названные исполнителем, — класс

- **(а) doc-ворота `doc_contract.ts:465` (`^contracts/(0+\d+)-`).** Подтверждено своей мерой (§2, критерий 4). Класс — **дефект контракта (architect)**: буквальная команда критерия 4 недостижима для NNN=162 и пути `.harness/` по конструкции загрузчика 027. Implementer не блокируется: соответствие evidence профилю доказано на эквиваленте 062 с двумя красными парами. Э-2.
- **(б) `make_task` для reviewer требует `--task-file`.** Подтверждено: `make_task.sh:477`, прогон B rc 1. Класс — **дефект текста контракта (architect)**. Обход в checker прозрачен (`check-coding-standards-context.sh:22-23,64-65,111`) и состав RULES не меняет: при обходе C1 даёт rc 0, а S1–S5 красные. Э-3.
- **(в) `check-structure.cjs` отвергает `.tsv`.** Подтверждено, но последствие серьёзнее, чем в отчёте: в CI-раскладке это ЕДИНСТВЕННЫЙ отказ, и он переводит обязательный `quality` из зелёного в красный. Класс — **дефект контракта (ЗОНА против существующего энфорсмента, architect) / решение владельца**, и это **блок слияния**. Заявка исполнителя на выход из зоны оформлена верно, но её мотивировка («уже красна на ветке из-за 27 путей») неверна: в CI предсуществующие пути выносятся до lint, на чистом дереве их 25, а не 27. Э-1.
- **(г) Строка contextPack не добавлена.** Соответствует контракту:
  - И-4: «добавляет … после reviewer и merge #158»;
  - «Порядок и граница поставки»: «… → merge #158 → mandatory contextPack-строка»;
  - критерий 5: «До merge #158 этот пункт NOT_RUN».

  ЗОНА содержит `harness.project.json` именно для этого следующего шага. Ухода от обязательства нет. Готовность checker к шагу доказана имитацией C1–C8 и S1–S5. Предпосылки зелёного на реальной ветке (замороженный проектный контракт в `.harness/contracts` продукта и трасса) — дело оркестратора/владельца (Э-3).

## 5. Что доказано, а что нет

Доказано буквально, на дереве OBJECT:
- критерий 1 вместе с негативной парой;
- критерий 2: rc 0, 123/123 на чистом checkout без tmp/, все три обязательные пары и откаты;
- критерий 3: `CITATIONS OK count=5` и 1-байтовая пара.

Доказано на эквиваленте, буквально НЕ доказано:
- критерий 4 — только на scratch-корне 062; буквальная команда даёт rc 2 (Э-2);
- критерий 5 — только на disposable-клоне с имитированной строкой профиля, копией контракта под тегом и трассой из оркестратора. На реальной ветке пункт NOT_RUN по контракту.

Не доказано вовсе:
- Слияемость. CI-раскладка `quality` на OBJECT красная (Э-1). Сам `quality` в GitHub на OBJECT не гонялся — коммит не запушен. Вывод сделан по точному повтору шага выноса и `check-structure.cjs`. [INFERENCE: остальные шаги `quality` (jest, eslint, typecheck, doctor) дифф не затрагивает: в диффе нет `.ts`/`.js`.]
- Семантическая полнота отражения всех норм §§1–16 таблицей. По контракту это не обязанность checker. Мой суд — §3 выше и С-2/С-3: противоречий «норма объявлена действующей, а код её нарушает без ЦЕЛИ» не найдено.

## Паразитная сложность (050)

- **`mobile/scripts/verify-coding-standards.sh` (486 строк против 350 у scratch).**
  (1) И-1…И-3 и критерий 2. (2) Состояние — только чтение таблицы, стандарта и `git ls-files`, всё видно в выводе; файлов состояния нет. (3) При правке свойства меняются таблица + стандарт — столько же, сколько у scratch, дифф число не увеличил. (4) Интерфейс: 0 аргументов, rc 0/1/2, env не читает (только выставляет `LC_ALL`). Работа за ним глубокая. Собственный `brace_expand` нужен: bash не раскрывает `{a,b}` из переменной, а c22 на этом стоит. (5) Потребитель — строка критерия 2. Грамматику `check-context-sources.py` не дублирует: там пины, здесь правило↔носитель. **ESSENTIAL.**
- **`mobile/scripts/coding-standards-claims.tsv`.** (1) И-1/И-3. (2) Данные, явные. (3) Меняется вместе со стандартом. (4) —. (5) Потребитель — checker. **ESSENTIAL** (путь — см. Э-1).
- **`mobile/scripts/check-coding-standards-context.sh` (147 строк).**
  (1) И-4 и критерий 5. (2) `mktemp -d` со служебным заданием, снимается `trap`; назван в шапке, побочного эффекта нет. (3) С профилем меняется одна строка. (4) 3 аргумента, rc 0/1/2. (5) Потребитель — критерий 5. Сборку RULES не переписывает, а вызывает `make_task`. **ESSENTIAL.**
- **`docs/CODING-STANDARDS.evidence.json`.** (1) Required-id из §Док-приёмка. (2) Данные. (3) Меняется вместе с required контракта. (5) Потребитель — `check_document --check` (эквивалент 062 rc 0). **ESSENTIAL.**

Находок ACCIDENTAL нет.

## ПРОВОДКА (038)

`guard=scripts/check_document.sh` существует и вызывается preflight-ом критерия 1 (rc 0, пара rc 1) и
критерием 4. Продуктовый checker заявлен НЕ guard-ом харнесса и НЕ CI-гейтом — так и есть: CI не
тронут. ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно. Поведенческой нормы 029-класса предмет не вводит.

## СВЕРКА-СТАНДАРТОВ

Предпосылка нормы: `AGENTS.md` продукта объявляет документ архитектуры и стандарт кода. Она пока
НЕ выполнена: grep `CODING-STANDARDS|ARCHITECTURE` по AGENTS.md, mobile/AGENTS.md, STRUCTURE.md даёт 0
совпадений, стандарт вводится этим же PR. Сверка дана добровольно по разделам, которые затрагивает дифф:

СВЕРКА-СТАНДАРТОВ:
- docs/CODING-STANDARDS.md §5 (комментарии по-русски, первый комментарий называет предмет) — соответствует: `verify-coding-standards.sh:2-3`, `check-coding-standards-context.sh:2-4`;
- docs/CODING-STANDARDS.md §1 п.3 / STRUCTURE.md + `mobile/structure-policy.json` (место файла) — расхождение: `mobile/scripts/coding-standards-claims.tsv` против `mobile/scripts/check-structure.cjs:20` (`allowed()`), путь не разрешён политикой. Это Э-1, блок слияния, класс — контракт;
- docs/CODING-STANDARDS.md §3 / §15 (модули TS, запреты кода) — не применимо: дифф не содержит TS/JS.

## Независимость

Судья `anthropic/claude-opus-5-5`. Автор — MiniMax и `anthropic/claude-sonnet-5-5` (автофолбек). По
`_t95_family` (`make_task.sh:174-180`) у судьи и Sonnet-части автора одно семейство `claude`. Задание
объявило независимость штатной. Вынесено владельцу как С-4.

## Ресурсы

Клоны mob, disp, ctx и каталоги pre, moved удалены после прогона. Вместе с ними удалены одноразовые скрипты: rev_mut_verify.py, rev_mut_ctx.py, mt_stub.sh, cmp_claims.py, flip_byte.py, drop_section.py. Их мутации перечислены в таблицах выше дословно. Вердикт и находки остаются в
/tmp/dev-harness-verify/Rev162/{verdicts,review-files}.
