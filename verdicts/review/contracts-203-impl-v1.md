accept
OBJECT=fea6b908205c52f6ee6884b62875541f8da20528
СУД: репо=dev-harness; предмет=203; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev203 (c907157c/wt t3c1a482ac); модель-факт=anthropic/claude-opus-5-5 (метаданные workstation-контекста сессии); автор Impl203 — implementer (MiniMax), Architect203b; класс=обычный (не повышаю: процессная дверь станции, новые ветви только отказные, права/деньги/ПД не затронуты)
НАХОДКИ: .review/2026-11-25-2031.md (status: ready) — блоков 0, советов 4

**БЛОКИРУЕТ: нет**
**СОВЕТ: 4** — подробно в .review/2026-11-25-2031.md:
- С-1 implementer: `ln -s` (`check_architecture_contract.sh:274`) идёт по `node_modules`, которую несёт пин. Вход неконформный.
- С-2 вне зоны 203: `freeze_contract.sh:311–319` без ловушки оставляет в TMPDIR выгрузку при отказе. Дефект был и до 203; 203 добавляет ещё одну ветвь с той же утечкой.
- С-3 implementer: прочие C0, NUL и склейка двух JSON в причине — косметика на неконформном stderr.
- С-4 architect: устаревшая шапка `SDACHA.md:5`.

Фраза суда: перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

ИДЕНТИФИКАЦИЯ. Копия: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t3c1a482ac/m.
- fetch wip/203/orchestrator-i2 + main + теги; `git switch --detach` OBJECT; `git rev-parse HEAD` = fea6b908205c52f6ee6884b62875541f8da20528.
- origin/main = merge-base = 76303bc5055146c64333b0f140603afa865133ed.
- Прогоны шли на одноразовых клонах /tmp/dev-harness-verify/rev203-{obj,base,clean} с собственным .git, TMPDIR=/tmp/dev-harness-verify/scratch-rev203/…; основной чекаут не трогался.

══ (1) ОБЛАСТЬ ══
`git log --format='%h %an %cn %s' 76303bc50..HEAD`:
  fea6b9082 orchestrator orchestrator orchestrator: 203 CI-шаг check:dver-brifa-203-family-selftest (вес 40, замер 23 с …)
  374724bc1 architect orchestrator 203: привести сдаточный лист к состоянию после реализации
  fffd968c0 implementer orchestrator implementer 203: дверь брифа архитектуры — зависимости выгрузки пина, причина отказа из ответа модели, членство id строки по пину
`git diff --name-status 76303bc50 HEAD`: M .github/workflows/ci.yml; M fixtures/workshop_project/dver_brifa_203/SDACHA.md; M registry/ci-steps.tsv; M registry/ci-zamery.tsv; M scripts/check_architecture_contract.sh.

Файлы по коммитам (`git show --name-only`) и зоны:
- fffd968c0 (implementer) — только `scripts/check_architecture_contract.sh`, +113/−6. Это в ЗОНЕ implementer; `make_task.sh` не менялся. `git diff 46219aff3 fffd968c0 -- scripts/check_architecture_contract.sh` даёт 0 строк: cherry-pick побайтово равен оригиналу.
- 374724bc1 (architect) — только SDACHA.md, в ЗОНЕ architect.
- fea6b9082 (orchestrator) — ровно три CI-файла, в ЗОНЕ orchestrator.

Вне зон ничего нет.
- Контракт: `git diff frozen/contracts/203/1 HEAD -- contracts/203-… fixtures/workshop_project/dver_brifa_203/` → только SDACHA.md (+7/−5). probe.py, stabs.py, model.py, overlaps.py и COMPATIBILITY.md не тронуты, то есть проверки под код не переписаны.
- ci.yml: моя мера — разбор ключей lanes. Ключей 169 → 170, дублей 0/0. Добавлен ровно `check:dver-brifa-203-family-selftest`, удалённых нет. Иные строки, кроме `keys:`, не изменены (6/6 numstat — строки lanes генерата).

Необъявленная семантика. Сверх четырёх инвариантов новых ветвей НЕТ:
- ARCH_BRIEF_DEPS — три отказа: lock≠, нет node_modules, ln не удался; плюс отказ «deps без lock».
- Разбор причины расширяет только текст причины, rc и вид строк прежние.
- UNKNOWN_ARCHITECTURE_ELEMENT — только отказ.

Каждая новая ветвь отказная или нейтральная, ни одна не расширяет допуск. Проверено мирами (ниже): L3-ветка (m7, M16), ARCH_PIN (X1–X4, X13), ARCH_COMPONENT_NET (X5), ARCH_ZONE (X10), ARCH_OWNER (X11) и режим 170 не ослаблены — вывод побайтово равен базе.

══ (2) РЕГРЕСС (по одной команде; rc и числа OBJECT против базы 76303bc50 без Impl203) ══
`W=bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh`

| прогон | OBJECT | база |
|---|---|---|
| W --repo . (клон obj) | rc 0, CELLS=21 FAILURES=0 | rc 1, FAILURES=13 |
| W --repo . (чистый клон, origin=OBJECT, тегов 0) | rc 0, 21/0 | — |
| W --model (чистый клон) | rc 0, CELLS=21 FAILURES=0 | — |
| W --stabs (чистый клон) | rc 0, CELLS=21 STABS=16 ZHIVYH=0, 16/16 caught | — |
| W --sintaksis | rc 0 SINTAKSIS OK | — |
| 187 `red_architecture_process_187.sh --repo .` | rc 0 CELLS=111 FAILURES=0 | rc 0 111/0 |
| 170 `red_arch_component_170.sh --repo .` | rc 0, 25 строк ok | rc 0, 25 ok |
| `check_architecture_contract.sh --repo . contracts/187-…` | rc 0 ARCH_187A_SKIP | rc 0 |
| `fixtures/_krasnye_095.sh` (25 клеток + стаб-пак) | rc 0, все клетки rc=0 | rc 0 |
| `fixtures/_krasnye_103.sh` (11 клеток + стаб-пак) | rc 0 | rc 0 |
| `sessii_136/red_sessii_136.sh` | rc 0, «клеток 87, зелёных 87, красных 0» | то же |
| shellcheck 0.11.0 `-S warning` | rc 1: SC2034 ARCH187_SCOPE и ARCH187_LEVEL (2 шт.) | те же 2 SC2034 |
| `bash -n scripts/check_architecture_contract.sh` | rc 0 | rc 0 |
| `bash scripts/gen_ci_steps.sh --check` | rc 0 | — |
| `npm run gen:harness -- --check` | rc 0 «харнес соответствует roles/ (13 ролей)» | — |
| `pre_critic.sh --repo . contracts/203-…` (клон obj с тегами) | rc 0 | — |
| `check_provodka.sh . contracts/203-…` | rc 0 | — |

Базовые красные — 13 точно по заявлению: deps-linked, deps-lock-differs, deps-lock-same-size, deps-donor-lock-missing, deps-donor-modules-missing, deps-pin-lock-missing, reason-json, reason-second, element-line-unknown, element-flag-unknown, element-pin-not-head, element-freeze-unknown, element-door-unknown. Зелёные контроли на базе: deps-free, reason-nonjson, reason-empty, element-line-known, element-freeze-known и три cap.

Своя мера счёта SDACHA (по строкам GREEN/RED вывода): 7 deps + 4 reason + 7 element + 3 cap = 21. ДО: 6 + 2 + 5 = 13. Правка К-02 «причина (2 красных ДО)» и «7 элементы» верна; прежний текст «причина 3» был ошибкой.

`pre_critic` в чистом клоне без тегов дал rc 1 «потолки красны»: `check_ceilings.sh` без тегов видит 69 старых контрактов. Это артефакт среды — в клонах obj и base с тегами `check_ceilings.sh .` даёт rc 0 «потолки в порядке». В счёт не идёт.

Чистый клон (урок 211): bare-origin с main=OBJECT, `git clone`, HEAD=origin/main=OBJECT, тегов 0. Режимы --repo/--model/--stabs/--sintaksis дали rc 0 (выше).

`bash scripts/check_sdacha.sh . contracts/203-dver-brifa-arhitektury.md --run` (клон obj с тегами) → rc 0, «СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)», 116 с.

══ (3) СВОИ МИРЫ (не клетки батареи; дифференциал база/OBJECT на близнецах; TMPDIR своё на каждый вызов, tmp_left — остаток в нём) ══
Зависимости (OBJECT):
  D1 node_modules донора — ссылка на каталог ВНЕ клона, lock равен → rc 0, DEP203_OK в паке, ссылка и внешний модуль целы, tmp_left=[].
  D2a NODE_PATH вызывающего указывает на модуль-«злодей», lock равен → rc 0, DEP203_OK=True, NODE_PATH_EVIL=False: симлинк выгрузки выигрывает.
  D2b NODE_PATH + deps без lock → rc 1 `ОТКАЗ: ARCH_BRIEF_DEPS: у закреплённого пина есть runtime-зависимости без package-lock.json; npm ci на закреплённом пине`.
  D2c NODE_PATH + нет node_modules у донора → rc 1 `ОТКАЗ: ARCH_BRIEF_DEPS: в установленном клоне модели нет node_modules: …; npm ci …` (заимствования через NODE_PATH нет).
  D2d манифест без deps, но CLI требует модуль, NODE_PATH задан → база и OBJECT одинаково rc 0 с модулем из NODE_PATH. Это предпосылка контракта («станция запускает дверь в среде без NODE_PATH»), не дельта 203.
  D3 lock донора — каталог → rc 1 ARCH_BRIEF_DEPS (плюс строка `cmp: …: Is a directory`, С-3).
  D4 node_modules донора — висячая ссылка → rc 1 ARCH_BRIEF_DEPS «нет node_modules».
  D5 пин несёт `node_modules` ССЫЛКОЙ на каталог-жертву → OBJECT rc 1 `ARCH_BRIEF_DEPS: node_modules выгрузки не подключить`; в жертве осталось `node_modules -> …/w-architecture/node_modules`. База: жертва нетронута (С-1).
  D6 пин несёт `node_modules` каталогом → rc 0, в паке модуль пина PIN_VENDORED, а не донора (С-1).
  D7 lock есть, донор без node_modules → rc 1 ARCH_BRIEF_DEPS.
  battery-клетки deps-lock-differs/-same-size/-donor-lock-missing/-pin-lock-missing → именованные отказы. tmp_left=[] во всех отказах make_task: выгрузка удаляется.
Причина (база → OBJECT, строка ARCH_BRIEF_STDERR):
  r1 пустой code → `{` → `{` (IDENTICAL); r2 code не строка → IDENTICAL; r5 JSON+мусор → `{` IDENTICAL; r9 массив → `[` IDENTICAL; r10 шум+JSON → `warning: noise` IDENTICAL; r11 объект без findings → IDENTICAL; r13 code только во 2-м finding → IDENTICAL; r15a не-UTF-8 не-JSON → IDENTICAL.
  r3 без message → `C203`; r4 два JSON → `A1: first B2: second` (С-3); r6 управляющие → CR/LF/TAB в пробел, ESC/BEL/U+2028 сырые (С-3); r7 NUL → лишняя bash-warning строка (С-3); r8 сообщение 200 000 символов → строка 200157 байт, без обрезки, хвост `TAIL_ID api.identity` цел; r12 `$(touch …PWNED) \`id\` %s %n` → печатается литерально, файл PWNED НЕ создан (инъекции нет); r14 одни пробелы → `SP:`; r15b невалидный UTF-8 внутри JSON → `BAD\uFFFD: m\uFFFD`.
  Строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (закреплённая модель не отдала бриф)` во всех мирах побайтово как на базе.
Членство (база → OBJECT):
  M1 префикс `api.ident` при известном api.identity → база rc 0 → OBJECT rc 1 `ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: api.ident`. Членство решает модель, подстрочного сравнения в двери нет.
  M2 регистр `API.IDENTITY` → `ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: API.IDENTITY`.
  m3 пробел, m4 `..`, m5 `-x`, m6 `--help`, m9 `$(id)`, m8 дубль, M10 NUL → `ARCH_LINE_MISSING` ДО гейта; вывод IDENTICAL с базой. Опционоподобный id в CLI не попадает: грамматика `[A-Za-z0-9_][A-Za-z0-9._-]*` без `..`.
  m7/M16 L3 + неизвестный id → `ARCH_OWNER` (make_task и дверь), IDENTICAL: L3-ветка первая и не ослаблена.
  M11 флаг И строка с неизвестным id → строка отказывает первой: `ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity`.
  M12 пин знает id, HEAD отвечает UNKNOWN → rc 0 на обоих. Источник — пин.
  M13 иной код (MODEL_SCHEMA_VIOLATION) → гейт не сужает, rc 0. M14 UNKNOWN при rc 0 → не сужает. Обе ветви объявлены в «НЕ ЗАЩИЩАЕТ».
  M15 без флага → база `ARCH_COMPONENT_NET`, OBJECT `UNKNOWN_ARCHITECTURE_ELEMENT`: гейт стоит до вопроса о флаге, как требует инвариант 3.
  M17 заморозка, известная строка → rc 0, тег frozen/contracts/777/1 на обоих (IDENTICAL).
  M18 заморозка, неизвестная строка → база rc 0 с тегом, OBJECT rc 1 без тега, tmp_left=2 (С-2: утечка была и до 203, F2/F6).
  F4 публичная дверь → `UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity` rc 1, tmp_left=[]. F5 make_task → rc 1, tmp_left=[].
Дифференциал байт-в-байт, где поведение меняться не должно (rc, stdout и stderr нормализованы только по пути мира):
  X1 нет commit, X2 короткий pin, X3 неразрешимый pin, X4 нет клона, X13 нет cli.js (ARCH_PIN); X5 ARCH_COMPONENT_NET; X6 ARCH_BRIEF_STDERR первая строка + OTKAZ; X7 «(stderr модели пуст)» + OTKAZ; X10 ARCH_ZONE; X11 ARCH_OWNER; X12 дверь rc 2 ARCH_NOT_EVALUATED → все IDENTICAL.
  Пак успеха: x8 и x9 (два компонента, роль architect с правилами), stdout_identical=True; x14 дверь — IDENTICAL.

══ (4) ДЕФЕКТЫ ЧЕСТНОЙ PRODUCTION ══
- Инъекция и раскрытие: нет. id ограничен грамматикой строки (m5/m6/m9) и передаётся отдельным аргументом в кавычках. Причина печатается через `printf '%s'` (r12: PWNED не создан).
- Потеря rc: нет. Ошибки `jq` дают `|| reason=""` и `|| code=""` с прежним фолбэком (r5: JSON+мусор → `{`). Ошибка `cmp`/`ln` даёт отказ.
- Fail-open: нет. Пустой stderr даёт прежнюю константу. Пустой или битый ответ в гейте вердикта членства не несёт — это объявлено в «НЕ ЗАЩИЩАЕТ». Недоступная модель отказывает раньше: ARCH_PIN/ARCH_BRIEF_DEPS (X1–X4, D2b/D2c/D4).
- Гонки и утечки: make_task и дверь убирают выгрузку и ссылку (`rm -rf "$tmp"` не идёт по ссылке, донор цел — D1, deps-linked donor_guard). Утечка в freeze была до 203 (С-2). Запись по ссылке пина — С-1.
- Расхождение с контрактом/COMPATIBILITY: на конформном входе нет. С-1(а) задевает формулировку «донор не трогается» только на неконформном пине.

══ ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефакту ══
- блок зависимостей в `arch187_model_prepare` (+33): (1) инв. 1; (2) состояние — симлинк в своей выгрузке, видно в ARCH_BRIEF_DEPS; (3) один файл; (4) интерфейс не вырос (те же rc и ARCH187_REFUSAL); (5) потребители — клетки deps-*, второй грамматики нет. ESSENTIAL.
- разбор причины в `arch187_brief` (+16): (1) инв. 2; (2) нового состояния нет; (3) один файл; (4) интерфейс прежний; (5) клетки reason-*, батарея 187 brief_stderr.py. ESSENTIAL.
- `arch187_element_ids` (+33, новая функция) и её вызов в `arch187_check_text`: (1) инв. 3; (2) читает ARCH187_COMPONENTS и ARCH187_MODEL_DIR, пишет ARCH187_REFUSAL и _RC, явно; (3) один файл; (4) без аргументов, rc 0/1 — глубокий модуль; (5) клетки element-*, членство решает модель, своего списка элементов нет. ESSENTIAL.
- CI-строка ci-steps/ci-zamery/ci.yml: (1) строка приёмки «шаг check:dver-brifa-203-family-selftest»; (2) нет состояния; (3) генерат держит три файла (`gen_ci_steps --check` rc 0); (4) н/п; (5) потребитель — CI. ESSENTIAL.
ACCIDENTAL нет.

ПРОВОДКА (038). `guard=scripts/check_architecture_contract.sh` — существует. Это барьер именно этого предмета: в нём все три шва 203. ПРОВОДКА-ЭНФОРСМЕНТ («чистый энфорсмент шва 187, новых поведенческих норм нет») честен: дифф не трогает roles/, норм и AGENTS.md. `check_provodka.sh` rc 0.
СВЕРКА-СТАНДАРТОВ: н/п. AGENTS.md станции документа архитектуры и стандарта кода не объявляет (`grep 'ARCHITECTURE.md|CODING-STANDARDS|стандарт кода' AGENTS.md` → 0 совпадений). Норма 6 соблюдена: нормативные документы дифф не трогает.
СВЕРКА-АРХИТЕКТУРЫ: н/п. Контракт несёт «АРХИТЕКТУРА: н/п — ремонт станционных дверей», проектной модели и `bindings.json` у станции нет. Размещение — только существующий шов 187 (`check_architecture_contract.sh`), второй сборщик модели не заведён. Писатели и операции не добавлены, долг не расширен, diff модели — нулевой уровень. Находок L1/L2/L3 нет, `finding new` не требовался.
Режим проекта (996) — н/п: репо станции, sourceCanon не объявлен. Мобильный экран — н/п.
Н-39: стабы привязаны в коде (`stabs.py: STABS[name] = (cell, …)`, сирота-проверка в probe.py `orphan`), не прозой контракта.

══ ОСТАТКИ (192; «НЕ ЗАЩИЩАЕТ» с ловцом reviewer; К-карта SDACHA строк с ловцом reviewer не несёт) ══
ОСТАТОК: НЗ-1 (злонамеренный/повреждённый node_modules клона при совпавшем lock) — не укусил. Дифф доверяет клону ровно на равенстве lock (`:264`) и модули не исполняет сам. Родственный случай «node_modules в самом пине» вне этой строки — С-1.
ОСТАТОК: НЗ-2 (молчание модели без кода членства) — не укусил. `:762–781` сужает только на rc≠0 И code=UNKNOWN_ARCHITECTURE_ELEMENT (M13/M14 проходят, как объявлено).
ОСТАТОК: НЗ-3 (семантическая неполнота брифа) — не укусил. stdout брифа не режется: паки x8/x9 побайтово равны базе, r8 без обрезки.
ОСТАТОК: НЗ-4 (малый pack.maxBytes) — ловец оркестратор/владелец, не reviewer. cap-over-profile/cap-default зелены.

══ СЫРОЙ ВЫВОД КЛЮЧЕВЫХ ПРОГОНОВ ══
OBJECT, клон obj: `W --repo .`
  GREEN deps-linked: rc=0 stderr=''
  GREEN deps-lock-differs: rc=1 stderr='ОТКАЗ: ARCH_BRIEF_DEPS: package-lock.json закреплённого пина не совпадает с установленным клоном модели: …'
  GREEN deps-lock-same-size / deps-donor-lock-missing: rc=1 (то же)
  GREEN deps-donor-modules-missing: rc=1 stderr='ОТКАЗ: ARCH_BRIEF_DEPS: в установленном клоне модели нет node_modules: …; npm ci на закреплён…'
  GREEN deps-pin-lock-missing: rc=1 stderr='ОТКАЗ: ARCH_BRIEF_DEPS: у закреплённого пина есть runtime-зависимости без package-lock.json; npm ci на закреплённом пине'
  GREEN deps-free: rc=0
  GREEN reason-json: rc=1 stderr='ARCH_BRIEF_STDERR: TOY_REFUSAL_CODE_203: причина с юникодом и id api.identity внутри'
  GREEN reason-nonjson: rc=1 stderr='ARCH_BRIEF_STDERR: FIRST_CAUSE_203: boom'
  GREEN reason-empty: rc=1 stderr='ARCH_BRIEF_STDERR: (stderr модели пуст)'
  GREEN reason-second: rc=1 stderr='ARCH_BRIEF_STDERR: MODEL_SCHEMA_VIOLATION: invalid shape'
  GREEN element-line-unknown: rc=1 stderr='ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity'
  GREEN element-line-known: rc=0
  GREEN element-flag-unknown: rc=1 stderr='ARCH_BRIEF_STDERR: UNKNOWN_ARCHITECTURE_ELEMENT: Unknown architecture element: resource.identity'
  GREEN element-pin-not-head: rc=1 stderr='ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity'
  GREEN element-freeze-unknown: rc=1 / element-freeze-known: rc=0
  GREEN element-door-unknown: rc=1 stderr='UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity'
  GREEN cap-within: rc=0 / cap-over-profile: rc=1 'ОТКАЗ: режь задачу: 92879 > 60000' / cap-default: rc=1 'ОТКАЗ: режь задачу: 92854 > 40000'
  CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0
  RC=0
База 76303bc50: `W --repo .`
  RED deps-linked: rc=1 stderr='ARCH_BRIEF_STDERR: node:internal/modules/cjs/loader:1573'
  RED deps-lock-differs|deps-lock-same-size|deps-donor-lock-missing|deps-donor-modules-missing|deps-pin-lock-missing: no stderr line starting with: ОТКАЗ: ARCH_BRIEF_DEPS:
  RED reason-json: rc=1 stderr='ARCH_BRIEF_STDERR: {'
  RED reason-second: rc=1 stderr='ARCH_BRIEF_STDERR: {'
  RED element-line-unknown: rc=0 (пак выдан)
  RED element-flag-unknown: rc=1 stderr='ARCH_BRIEF_STDERR: {'
  RED element-pin-not-head: rc=1 stderr='ARCH_BRIEF_STDERR: {'
  RED element-freeze-unknown: rc=0, tag presence True expected False
  RED element-door-unknown: rc=2 stderr='ARCH_NOT_EVALUATED: в architecture.lock.json нет snapshotDigest утверждённого снимка'
  CELLS=21 STABS=0 FAILURES=13 ZHIVYH=0
  RC=1
Чистый клон: `W --stabs`
  STAB cap-arch-budget-branch caught @ cap-within; cap-limit-dropped @ cap-over-profile; cap-profile-ignored @ cap-within; deps-cmp-inverted @ deps-lock-differs; deps-modules-optional @ deps-donor-modules-missing; deps-no-symlink @ deps-linked; deps-pin-from-head @ deps-linked; deps-pin-lock-optional @ deps-pin-lock-missing; deps-size-only @ deps-lock-same-size; element-code-renamed @ element-line-unknown; element-head-not-pin @ element-pin-not-head; element-membership-removed @ element-line-unknown; flag-stderr-swallowed @ element-flag-unknown; reason-code-dropped @ reason-json; reason-json-ignored @ reason-json; reason-message-dropped @ reason-json — все caught
  CELLS=21 STABS=16 FAILURES=0 ZHIVYH=0
  RC=0
Миры D5/M18/F6 (из .review):
  D5 [base] rc=1 'ARCH_BRIEF_STDERR: node:internal/modules/cjs/loader:1573'; victim dir after run: ['keep.txt']
  D5 [obj]  rc=1 'ОТКАЗ: ARCH_BRIEF_DEPS: node_modules выгрузки не подключить: <W>/obj/w-architecture; npm ci на закреплённом пине'; victim dir after run: ['keep.txt', 'node_modules'] (stray link -> …/d5/obj/w-architecture/node_modules)
  F6 [base] rc=1 'ОТКАЗ: ARCH_ZONE: …' tmp_left=['tmp.7X2TmovEAf', 'tmp.SdDKlfLkvu']; [obj] то же, IDENTICAL
  M18 [obj] rc=1 'ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: resource.identity' tmp_left=['tmp.09CnRLrZRD', 'tmp.ezmUy81VVT']; tags: (none)
