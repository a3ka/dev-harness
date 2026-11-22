accept
OBJECT=1e15de5d067d92a1d6b933d0df1f5d9d8e91068b
СУД: один reviewer по Б-13 (992), вызов 1 (слово владельца 22.11 ~14:05; adversary 4 вызова исчерпан; класс 992 рисковый); роль=reviewer; сессия=Rev992B13; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии); SHA=1e15de5d067d92a1d6b933d0df1f5d9d8e91068b; прежние вердикты=adversary contracts-992-impl-v1/v2/v3/v4.md (FAIL; archive/992/adversary-b13-fail-8e4c00dc58, -b13b-fail-7159658bb3, -b13c-fail-fc64928, -b13d-fail-add33b60d6), reviewer по Б-13 ранее не судил; класс задачи=кодовый; класс риска=рисковый
НАХОДКИ: .review/2026-11-22-139.md — блоков 0, советов 5 (С-1…С-5, классы ниже)

# Вердикт reviewer: 992 Б-13, вызов 1

Прогоны шли в собственной копии `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tb8f77ed1b/m`, HEAD detached на OBJECT (`git rev-parse HEAD` = 1e15de5d067d92a1d6b933d0df1f5d9d8e91068b). TMPDIR — `$PWD/.scratch-rev992b13`, батареи запускались по одной, мутанты одноразовые и в коммит не попали. CI PR моей мерой (GitHub API check-runs по OBJECT): `total=17`, success=16, skipped=1, failure=0.

## 1. Область

`git diff --name-status 7f10bc3f9222 OBJECT`: A b13_token.py, A b13_token_list.md, A red_b13_token.sh, M red_doc_lifecycle.sh (всё в fixtures/freeze_contract/), M scripts/check_ci_gate.sh, M scripts/gitw_preflight_071.sh. Коммиты по авторам:
- architect (7a72d0f3b, 97aa01510, 85fc9d62e, ba7211acb) — только `fixtures/freeze_contract/`. Это ЗОНА architect frozen 992/2.
- implementer (0d0e7d4ca, 604c96c68) — только `scripts/check_ci_gate.sh` и `scripts/gitw_preflight_071.sh`. Оба в ЗОНЕ implementer. Фикстур implementer не трогал.
- Четыре merge orchestrator (32bbf2c10, 143f93e94, ff894f92f, 1e15de5d0): `git show --cc` пуст у каждого, своих правок нет.

Контракт не менялся: `git diff frozen/contracts/992/2 OBJECT -- contracts/992-oshibka-eto-otkaz.md` пуст. Правки `check_ci_gate.sh` — ровно две строки токена (:111, :188-189) и комментарий шапки (:18-19). В них нет ни ремонта, ни расширения. В `gitw_preflight_071.sh` ровно два шва: токен (:391-392) и захват rc jq с именованным отказом land (:400-401). Других ветвей дифф не задевает. Против main 344e4a714 `git diff --stat` показывает 7 файлов, 927+/23−. Строка `contracts/204-…` (−15) — движение main после 7f10bc3f, в PR её нет. `git merge-tree --write-tree 344e4a714 OBJECT` проходит без конфликтов.

## 2. Сырой вывод (по одной команде, из корня копии)

| Команда | rc | Итог |
|---|---|---|
| `bash fixtures/freeze_contract/red_b13_token.sh` | 0 | cases=54 observations=54 failures=0; моя мера — 54 строки `"accepted": 1`, по 18 на gate/writer/land |
| `… --model` | 0 | cases=54 observations=54 failures=0 |
| `… --stabs` | 0 | честный контроль 54/54; `STABS bindings=56 LIVE=0`. Пересчёт по строкам: S1/S1-empty/S2/S3/S4/S6 по 3 = 18, S5 6, S-M7 4, S-M10 4, S-M11 12, S-land-rc 6, S-land-pipefail 6 = 56, все `caught=1` |
| `… --compat` | 0 | COMPAT observations=24 failures=0 |
| `… --list \| wc -l` | 0 | 54 |
| `bash -n scripts/check_ci_gate.sh scripts/gitw_preflight_071.sh` | 0 | — |
| `bash fixtures/freeze_contract/red_doc_lifecycle.sh` (CI-потребитель check:document) | 0 | 992 cases=25 failures=0; Б-13 cases=54 failures=0; doc-проба исполнилась |
| `bash scripts/verify_antiplacebo.sh --scope check_ci_gate` | 0 | 8 фикстур, 8 красных повторным прогоном |
| `bash fixtures/gitw_predpolet/red_predpolet_071.sh` | 0 | честные клетки 41/41; стаб-пак 21/21 + дифф 21/21 |
| Красное на базе: `red_b13_token.sh --root <scripts из 7f10bc3f9222>` | 1 | failures=27: все 8 `*_gh`-клеток на каждой ветви (24) + land/partial_{open,cut,trash}_github (3) |

## 3. Неподгонка: мутанты на production-дверях OBJECT, по одному

Каждый мутант — копия двух scripts-файлов в одноразовом корне под scratch, прогон `red_b13_token.sh --root <корень>`, корень сразу удаляется. Якорь проверяется числом вхождений.

| Мутант | rc | Красные клетки |
|---|---|---|
| L1 вернуть `:400` без `\|\| {…}` (захват rc jq снят) | 1 | 6 — land/partial_* (rc0, одобрение push) |
| L2 отказ «ответ не разобран» → предупреждение + rc0 | 1 | 6 — land/partial_* |
| L3 отказ «land без зелёного PR-CI» → предупреждение + rc0 | 1 | 4 — land/empty_*, land/missing_field_* |
| L4 отказ «PR-CI не сверяем: API» → предупреждение + `continue` | 1 | 2 — land/denied, land/denied_gh |
| L5 `gitw_preflight_071.sh:30` pipefail убран | 0 | 0 — эквивалентный мутант на шве (С-1) |
| G1 `check_ci_gate.sh:60` pipefail убран | 0 | 0 — эквивалентный мутант на шве (С-1) |
| L6 токен в stderr land | 1 | 16 — все land-клетки с токеном (кроме no_tokens/empty_tokens, где печатать нечего); leak_free=0 |
| G2 `die()` печатает токен (gate+writer) | 1 | 24 — все отказные клетки с токеном; leak_free=0 |
| G3 writer дописывает токен в журнал | 1 | 6 — writer-клетки с одобрением; effect_ok=0, leak_free=0 |
| G4 `[ "$total" -ge 0 ] \|\| die …` → предупреждение (все вхождения) | 1 | 20 — gate 10, writer 10; diagnosis_ok=0 |
| L7 `.conclusion=="success"` снят с land-шва | 0 | 0 в Б-13. Ловит `red_predpolet_071.sh` п4б под L7 in-place (байты восстановлены, `git status` чист): rc 1 «ОТКАЗ: п4б: rc=0 (ожидался 1)» (С-2) |

Pipefail (L5/G1) — эквивалентный мутант. В `n="$(printf … | jq …)"` и `total="$(printf … | jq …)"` rc конвейера — это rc jq, который стоит последним и читает вход до EOF. Наблюдаемого состояния, в котором pipefail меняет исход на шве, нет. Остальные девять классов мутантов клетки ловят.

## 4. Токен и одобрение по ошибке данных

Собственная проба полного CLI land: b13-мир, curl отдаёт заданные байты, секрет синтетический. Каждый вход прогнан при GITHUB_TOKEN и при GH_TOKEN:
- зелёный ответ → rc0;
- `conclusion=failure` → rc1 «land без зелёного PR-CI»;
- `conclusion=null` → rc1 «land без зелёного PR-CI»;
- обрезанный первый документ → rc1 «PR-CI не сверяем: ответ не разобран»;
- два полных документа → rc1 «land без зелёного PR-CI»;
- зелёный + `\x00` → rc0. Это остаток владельца (С-4).

Утечки нет ни в одном прогоне (leak=0). В батарее `leak_free=1` у всех 54 клеток: stdout, stderr и журнал, включая оба HTTP-отказа и все отказы разбора. Мутанты L6/G2/G3 показывают, что утечку батарея ловит. Одобрения push по обрыву, мусору или неполному ответу нет: empty/missing_field/partial_*/denied на всех трёх ветвях дают rc1 с предметной причиной. Исключение — NUL-байт, принятый владельцем.

## Строки суда

НЕ ЗАЩИЩАЕТ: NUL-байт в теле ответа API в land-ветви: bash вырезает NUL до jq; документ остаётся валидным JSON (принят владельцем 22.11 ~14:05). Прочее:
- значение токена видно в argv curl (`-H "Authorization: Bearer …"`) и при xtrace. Это блоки 1–2 adversary v1/v3, остаточный риск базы по слову владельца; клеток на них нет;
- токен уходит на чужой хост — тот же остаток;
- `scripts/ci_klass.sh:177-178` читает только GITHUB_TOKEN: вне зон 992, так записано в листе;
- фильтр `conclusion` land Б-13 не держит, его держит 071/п4б (С-2);
- от субъекта, узнающего фикстуру или атакующего процесс проверяющего с тем же uid (лист, модель угроз).

ОСТАТОК: в frozen 992/2 нет строк «НЕ ЗАЩИЩАЕТ» с ловцом reviewer и номером К-NN (contracts/992-oshibka-eto-otkaz.md:78-80; `grep 'К-[0-9]'` → 0). Проверять нечего.

СВЕРКА-АРХИТЕКТУРЫ:
- Размещение не изменилось. Токен читается в трёх существующих ветвях запроса одним выражением `${GITHUB_TOKEN:-${GH_TOKEN:-}}`. Отказ разбора land встал в существующую семью «PR-CI не сверяем: …».
- Новых зависимостей нет: bash/jq/curl в дверях, python3 в фикстурах, как у fail_closed_992.py. Новых писателей состояния нет: журнал пишет только прежний writer, батарея сверяет байты.
- Операции, workflow, registry и package.json не тронуты. Канал CI — существующий red_doc_lifecycle.sh.
- `tooling/checks/cli.js` и `bindings.json` в дереве отсутствуют (`ls` → нет файла). Расхождения модели и работы не найдено, находка не заводилась, diff модели L0. Долг не расширен.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (`grep` → 0 совпадений, файлов нет), сверять не с чем. Заявленное сверено с наблюдением:
- сообщение 604c96c68 (до правки 6 красных land/partial_*, после 0) совпадает с моим L1, который побайтово равен шву до правки: failures=6;
- 0d0e7d4ca обещает «без токенов поведение не меняется» — подтверждают no_tokens/empty_tokens на трёх ветвях (rc0, Authorization нет) и `--compat` 24/0;
- в листе одна неточность: S-land-pipefail назван шире, чем ловит (С-1).

ПРОВОДКА (038): канал — существующий `.github/workflows/ci.yml` → `scripts/run_ci_lane.sh check:document` → `red_doc_lifecycle.sh`. Строка `bash "$HERE/red_b13_token.sh"` (red_doc_lifecycle.sh:6) стоит без `--model`, до doc-пробы. Прогон rc0; CI PR зелёный (16/0). Новой поведенческой нормы нет. sourceCanon (996): `grep -c sourceCanon harness.project.json` → 0, неприменимо.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050):
- **b13_token.py** (батарея 54 клеток + режимы --model/--stabs/--compat/--list/--root).
  1. Свойство: fallback токена на трёх ветвях и fail-closed разбора ответа (ADR v9:11, критерий fail-closed 992).
  2. Состояние явное: одноразовые миры в TMPDIR, ожидания в памяти, вывод — метки и булевы.
  3. При правке свойства меняются те же два файла, что и сейчас (батарея + лист). Число не выросло.
  4. Модуль глубокий: шесть флагов против полного CLI трёх дверей, мира Git и curl-шима. Строительство миров переиспользует `fail_closed_992` (fc.init/put/run), второго каркаса нет.
  5. Потребитель — red_doc_lifecycle.sh → CI check:document.
  - Вывод: ESSENTIAL.
- **red_b13_token.sh** (5 строк, `exec python3`). Это тонкая обёртка, но её называет строка приёмки задания и листа (`bash …/red_b13_token.sh`), и её вызывает потребитель. ESSENTIAL по приёмке. Более простая форма — прямой `python3`, как у fail_closed_992.py, — не прошла бы строку приёмки дословно. Не блок.
- **b13_token_list.md** (487 строк). Свойство: лист красной пачки architect (Н-39, привязки и сырые rc). Состояния нет. Потребителя в CI нет, это документ процесса. Объём — совет С-5, не блок: он не называет отсутствующего свойства.
- **Строки в дверях** (2 + 2 + 1). Ровно форма, требуемая клетками. Более простой формы, которая прошла бы land/partial_*, нет: без захвата rc получаем L1, красное.

Классы находок (.review/2026-11-22-139.md):
- С-1 — совет: имя стаба, эквивалентный мутант;
- С-2 — совет: место фильтра conclusion, дефекта нет;
- С-3 — совет: подмена входа partial_trash, ослабления нет;
- С-4 — остаток владельца, не находка;
- С-5 — совет: объём листа, 050 без блока.

Блокирующих находок нет: нарушения обязательства на достижимом состоянии не доказано.
