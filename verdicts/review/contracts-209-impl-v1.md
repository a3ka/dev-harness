accept
OBJECT=2a98aa68af80ccb3c6606a1f92a05ef5247aa283
СУД: репо=dev-harness; предмет=209; роль=reviewer; вызов=1 (полный); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; предыдущие=adversary вызов 1 FAIL (archive/209/adversary-v1-fail-2f635444c3), вызов 2 accept (wip/209/adversary 576e56470); класс риска=рисковый

Модель-факт взята из метаданных среды выполнения этой сессии (workstation Model). Трёхполевой трассы как свидетельства факта здесь нет. Советы — `.review/2026-11-23-154.md` (reslop, status: ready).

## Кандидат и подготовка

- Подготовка:
  - `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/209/orchestrator-r2` → rc 0;
  - `git switch --detach 2a98aa68af80ccb3c6606a1f92a05ef5247aa283` → rc 0;
  - `git rev-parse HEAD` = OBJECT.
- `git diff --stat 81d5cf8e2 2a98aa68a -- workshop fixtures/workshop_project/zasev_trassy_209` → пусто, rc 0. Содержательный diff равен прежнему OBJECT, на котором дан accept Adv209b.
- Среда:
  - `TMPDIR=$PWD/.scratch-rev209`;
  - `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck` (version: 0.11.0).

## 1. Область правки и зоны

`git diff --stat d4d4c5c09 2a98aa68a` даёт ровно 8 файлов: `workshop` (+48/−2), `fixtures/workshop_project/zasev_trassy_209/{SDACHA.md,probe.py,stabs.tsv,model/prepare_model_trace_209.txt}`, `registry/ci-steps.tsv` (+1), `registry/ci-zamery.tsv` (+1), `.github/workflows/ci.yml`.

Состав по `git log --format='%h %an|%cn'` и `git show --stat` каждого коммита:

| Коммит | Автор | Файлы | Зона |
|---|---|---|---|
| `364a46a26` | implementer | только `workshop` | ок |
| `ad8bb14bc` | architect | только 4 файла батареи 209 | ок |
| `b7cf3ad12` | implementer | только `workshop` (1 строка) | ок |
| `2a98aa68a` | orchestrator | только 3 CI-файла | ок |

- Каждый коммит — одна задача (атомарно).
- Контракт не менялся: `git diff --stat frozen/contracts/209/1 2a98aa68a -- contracts/209-zasev-trassy-proekta.md` пусто, rc 0. `git merge-base --is-ancestor frozen/contracts/209/1 2a98aa68a` → rc 0.
- Нормативные документы (roles/, contracts/, нормы) в diff не входят.

«Только prepare_model_trace» (пересечения 002/005/010/028/030/054/055/058/060/070/105/125/198/996) проверено своей мерой. Скрипт: `frozen/contracts/204/1:workshop`, в нём `probe.OLD` (кратность 1) заменён каноном `model/prepare_model_trace_209.txt`; результат равен `workshop` OBJECT целиком — `model==workshop True`. Значит, вне заменённого блока (строки 237–298) `workshop` побайтно равен frozen 204/1. Фрагмент `workshop` от `# shellcheck shell=bash` до первой `}` совпадает с каноном: `cmp` → rc 0.

## 2. Соответствие И1–И8 на реальном workshop

| Инв. | Что требуется | Где в workshop | Чем подтверждено |
|---|---|---|---|
| И1 | засев из станции | `:263` — при пустой проекции и пустой метке, архив пуст (ветку `:261` с непустым архивом без метки берёт сохранение); `:267` — источник только `HARNESS_SESSION_HOME="$ZONE" models_actual --tsv` (ZONE вычислена на `:114` до подмены HOME на `:882-883`); `:268` — прежний awk (3 поля, непустая роль, не orchestrator, первая строка роли); `:272` — `grep -Fx` по `jq -er '.roles \| keys[]'` реестра установки; `:273` — `printf '%s\t%s\n' role rest` | `IFS=$'\t' read -r` сохраняет поля побайтно: models_actual печатает непустые model (`[^"]+`) и perm (`[a-z]+`) (scripts/models_actual.sh:154,176-183), схлопывания пустых TAB-полей на выходе производителя нет |
| И2 | метка | `:243` — экспорт `HARNESS_MODEL_TRACE_SEED=runtime/model-trace.seed.tsv`; режим 600 на `:282`, `:289`, `:296` | JSONL, session или OBJECT не создаются: в клетке `bind` `models_actual --bind` по дому проекта даёт rc 2 «трейсов в зоне нет» |
| И3 | вытеснение | `:285-290` — awk `FILENAME == ARGV[1]` удаляет из метки роли фактов, пустой первый вход метку не стирает; `:292-294` — факты первыми, затем остаток засева | своё предъявление: после вытеснения всех 7 ролей метка `b''`, архив 7 строк, повтор не меняет байты |
| И4 | непустой архив | `:261-262` — архив без метки сохраняется (`! -s "$seed"`); при фактах без метки ветки засева нет, архив = факты | — |
| И5 | неизвестная роль | `:275` — `TRACE_SEED_ROLE_UNKNOWN: <роль>` в stderr | клетки `rejestr` и `partial-role` (префикс `implementer-g`) зелёные |
| И6 | источник | `:256` — jq `if has("bootstrapTrace") then .bootstrapTrace == "station" else true end`, любой сбой → false; `:257-259` — `rm -f .new` и `die` (rc 1, «ОТКАЗ: TRACE_SEED_SOURCE_INVALID: bootstrapTrace должен быть station») до exec omp | собственного JSON-парсера нет; отсутствие файла недостижимо: его раньше отвергает `scripts/profile_resolver.sh:321-322` |
| И7 | факт не из засева | models_actual, check_sud_model, judge_gate и make_task в diff не входят | клетки `bind`, `sud-gate`, `judge-fact`, `sud-boundaries` зелёные |
| И8 | dev-вход без засева | вся новая логика под `[ -n "${PROJECT:-}" ]` (`:254`); dev-вызов на `:714` идёт при `PROJECT=""` | клетка `dev` зелёная; кроме того, вне блока workshop = frozen 204/1 (п.1) |

## 3. Закрытие блоков Adv209 — воспроизведено мной

**(а) Б-1.** Сценарий `python3 .scratch-rev209/b1.py` → rc 0. Мир `probe.World`, реальный workshop и make_task; проекция пуста, архив `architect\ttoy/own\tallowed\n` (0600), метка `b''` (0600).

| Шаг | rc | Результат |
|---|---|---|
| `make_task --role critic` до старта | 1 | «ОТКАЗ: свидетельство не той роли: critic» |
| старт workshop | 0 | лог стаба omp `EXEC\n` |
| `make_task --role critic` после старта | 1 | то же; архив `b'architect\ttoy/own\tallowed\n'` (байты сохранены), метка `b''`, режимы 0o600/0o600; станционные роли не добавлены |

**(б) Мутанты по одному в копии реального workshop.** Скрипт `python3 .scratch-rev209/mut.py` → rc 0. В каждом мутанте одна замена, якорь кратности 1, `bash -n` rc 0. Запуск — `W --repo <одноразовое дерево>`, после него дерево удаляется. W — `bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh`.

| Мутант | Замена | rc | KLETKI/ZELENYE/KRASNYE | Красные клетки |
|---|---|---|---|---|
| ARCHIVE-MODE | `chmod 600 "$HARNESS_MODEL_TRACE.new"` → `chmod 644` | 1 | 27/26/1 | `archive-mode` |
| PARTIAL-ROLE | `grep -Fx -- "$role" "$roles"` → `grep -F` | 1 | 27/26/1 | `partial-role` |
| EMPTY-MARK | `[ -s "$HARNESS_MODEL_TRACE" ] && [ ! -s "$seed" ]` → `! -e` | 1 | 27/26/1 | `empty-mark` |

Каждый мутант пойман своей клеткой.

**(в) Чистый новый проект.** Тот же b1.py: архива и метки нет, проекция пуста. Старт → rc 0. Архив и метка равны `SEED` (7 станционных ролей), оба 0o600. `make_task --role critic` → rc 0, засев разрешён.

**Свои дополнительные мутанты** (тем же mut.py):

| Мутант | rc | Итог | Что это показывает |
|---|---|---|---|
| LEGACY-RED-BEFORE (workshop = frozen 204/1) | 1 | 27/4/23 | красное-до (приёмка 1); красные клетки свойств И1–И7: pustoj, metka, archive-mode, make-task, bind, sud-gate, idempotentnost, vytesnenie, rejestr, partial-role, istochnik, existing-archive, empty-mark, station-explicit, source-path/empty/nul/crlf/case/null/array/object/nonutf8 |
| WRONG-ZONE (`HARNESS_SESSION_HOME="$ZONE" bash` → `"$HARNESS_SESSION_HOME"`) | 1 | 27/15/12 | выбор корня станции защищён |
| FILTER-MARK-MODE (`:289` `chmod 600` → `644`) | 0 | 27/27/0 | **ЖИВОЙ** — совет С-1, не блок |

По FILTER-MARK-MODE: производство на `:289` даёт 0600. Своё предъявление `python3 .scratch-rev209/filter_mode.py` → rc 0: на OBJECT режим метки 0o600/0o600/0o600 (засев/повтор/вытеснение); у мутанта — 0o600/0o644/0o644.

## 4. Регресс — сырые rc

| Команда | rc | Вывод / время |
|---|---|---|
| `W --repo .` | 0 | `209 KLETKI=27 ZELENYE=27 KRASNYE=0`, real 84.6 s |
| `W --model` | 0 | `209 KLETKI=27 ZELENYE=27 KRASNYE=0`, real 96.7 s |
| `W --stabs` | 0 | `209 MUTACII=17 SVJAZI=17 POIMANY=17 ZHIVYH=0`, real 223.6 s (в хвосте параллельно шли мутанты); 17 строк «STAB … caught @ <своя клетка>», перед каждой контроль своей клетки `ok` |
| `bash -n workshop` | 0 | — |
| shellcheck 0.11.0 `-S warning -f gcc workshop` | 1 | две SC2034: `:48` NEXT_ID_LIB, `:399` child_pid_rc |
| то же на `git show d4d4c5c09:workshop` | 1 | те же две SC2034 (`:48`, `:353`) — новых находок нет |
| `bash scripts/pre_critic.sh contracts/209-zasev-trassy-proekta.md` | 0 | «КРИТИК: дверь зелёная» |
| `bash scripts/check_sdacha.sh "$PWD" contracts/209-zasev-trassy-proekta.md --run` | 0 | «СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)», real 307.4 s (≤900) |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash fixtures/context_pack_095/red_svidetelstvo_modeli.sh` | 0 | — |
| `check_spec_ready` | 0 | — |
| `check_precision_gate` | 0 | — |
| `check_threat_model` | 0 | ЗАЩИЩАЕТ 4 / НЕ ЗАЩИЩАЕТ 4 |
| `check_predposylki` | 0 | — |
| `check_ids .` | 0 | — |
| `check_ceilings` | 0 | — |
| `check_provodka --grammar . contracts/209…` | 0 | — |

## 5. Интеграция и неподгонка

- **Числа своей мерой.**
  - 27 клеток: 8 в мире a + nepustoj, rejestr, partial-role, istochnik, existing-archive, empty-mark, station-explicit + 8 invalids + source-nonutf8, dev, judge-fact, sud-boundaries — сходится с выводом W.
  - 17 стабов: строки `stabs.tsv` без комментария = ключи `mutations()`, равенство множеств проверяет сам probe.
- **Стабы — побайтовая производная.** `mutations(model)` правит байты канона через `replace_one`, кратность 1. Канон равен `workshop` (п.1), поэтому стабы — производная реального кода. Привязка дана кодом `stabs.tsv`/`probe.py`, а не прозой (Н-39).
- **Невырожденность.** Новые клетки (empty-mark, archive-mode, partial-role) зелёные на OBJECT и красные на своём мутанте. Каждая сравнивает полные байты архива и метки, rc и полный stdout/stderr с frozen-оракулом, снятым до субъекта.
- **Неподгонка.** Батарею менял только architect (`ad8bb14bc`); implementer менял только `workshop`. Порядок: канон Arch209c (`! -e`→`! -s`), затем Impl209b — та же строка в workshop. Красное-до есть: LEGACY 23 красных; EMPTY-MARK красит `empty-mark`.
- **CI.**
  - Строка `check:zasev-trassy-209-family-selftest` с весом 470 в `registry/ci-steps.tsv` исполняет `--repo .`, `--model` и `--stabs`.
  - Замер `470 468 0` в `registry/ci-zamery.tsv`: первое число сравнивается с весом (`scripts/check_ci_weights.sh:150`) и равно 470.
  - Ключ попал в lane `l2` в `ci.yml`; производность подтверждает `gen_ci_steps --check` rc 0.
  - Своя сумма 85+97+224 = 406 s ≤ 470, в пределах 3×.
  - `bash scripts/check_ci_weights.sh` → rc 1 «нет замера: check:erstinformation-118… check:sverka-maketa-123…». На базе `d4d4c5c09` (одноразовый клон `.scratch-rev209/base`, `--root`) — тот же rc 1 и тот же текст: отказ существовал до 209, ключ 209 в нём не назван.
- **ПРОВОДКА.** `bash scripts/check_provodka.sh "$PWD" contracts/209-zasev-trassy-proekta.md` → на OBJECT rc 0. На базе d4d4c5c09 → rc 1 «проводка: guard не подключён: fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh не вызывается в .githooks/ или .github/workflows/». Красное до CI-строки и зелёное после — как требует приёмка 7. Guard — барьер именно этого предмета, канал единственный, ПРОВОДКА-ЭНФОРСМЕНТ обоснован: это механика свидетельства, не поведенческая норма роли.
- **make_task для судей.**
  - Засев свидетельствует назначение, а не сессию. Это объявленный рисковый допуск контракта; ослаблением он не является.
  - Для роли без станционной строки отказ «не той роли» прежний: Б-1, critic rc 1.
  - Трёхполевой засев в `check_sud_model --verdict`/`judge_gate --sud` → rc 2 «трасса без привязки» (`bind`, `sud-gate`); честная пятиполевая трасса — rc 0 (`judge-fact`).
  - make_task, models_actual, check_sud_model и judge_gate не изменены.

## Блоки

Нет. Доказанного нарушения обязательства контракта 209 на достижимом состоянии не найдено. Б-1, Б-2 и Б-3 Adv209 закрыты (п.3).

## Советы (не блоки) — `.review/2026-11-23-154.md`

- С-1 (architect, Н-39) — батарея не ловит режим метки на ветке фильтра: живой мутант `workshop:289` 600→644, W rc 0 27/27/0.
- С-2 (implementer) — `workshop:279`: префикс `TRACE_SEED_NOT_READY: ` уходит в stdout без LF, причина — в stderr. Предъявлено на пустой станции.
- С-3 (implementer + architect, 050) — ветка `TRACE_SEED_REGISTRY_INVALID` (`workshop:265-266`) вне контракта, без клетки; после `die` в runtime остаются `.new` и `$raw.roles`.
- С-4 (architect, 050, косметика) — директива `# shellcheck shell=bash` перенесена из канона в середину `workshop:237`; свойства за ней нет.

## НЕ ЗАЩИЩАЕТ / ОСТАТОК

В SDACHA строк `НЕ ЗАЩИЩАЕТ` с К-NN нет: К-16 — описание границ. Ниже по каждой строке «НЕ ЗАЩИЩАЕТ» §Модель угроз контракта. В трёх из них ловец — reviewer; вторая проверена попутно.

- ОСТАТОК: НЗ-1 (компрометация ZONE/JSONL/установки; ловец reviewer по происхождению) — **не укусил**.
  - Диф читает станцию только через `models_actual --tsv` с `HARNESS_SESSION_HOME="$ZONE"` (`workshop:267`); ZONE берётся из `:114`, который не менялся.
  - WRONG-ZONE пойман (rc 1, 12 красных).
  - Подложный станционный `runtime/model-trace.tsv` игнорируется (клетка `istochnik`).
  - Аттестацией станции это не является.
- ОСТАТОК: НЗ-2 (нет станционной строки роли; ловец make_task/orchestrator) — **не укусил**. Роль не выдумывается: после Б-1 critic rc 1 «свидетельство не той роли».
- ОСТАТОК: НЗ-3 (подмена метки/архива доверенным writer, конкурентная запись; ловцы 095/104 и reviewer) — **не укусил**.
  - Вызов `prepare_model_trace` (`workshop:1374`) стоит после PID-лока проекта (`:1255-1258`).
  - Запись идёт через `.new` + `mv -f` (`:282-283`, `:289-290`, `:296-297`).
  - Нового writer нет; новой блокировки, как и обещано контрактом, тоже нет.
- ОСТАТОК: НЗ-4 (правдивость живого запроса и вердикта; ловец adversary/reviewer) — **не укусил**.
  - Проверка 104 не тронута; засев не проходит `--sud` (rc 2).
  - Живой запрос модели не исполнялся — вне скоупа (п.6 задания).

## Паразитная сложность (050)

- `workshop` `prepare_model_trace` (+48/−2) — ESSENTIAL.
  1. Свойство: И1–И6, И8.
  2. Состояние явное: экспортируемый путь `HARNESS_MODEL_TRACE_SEED` и файл `model-trace.seed.tsv`; вход — ключ `bootstrapTrace`.
  3. Вместе меняются 2 файла: `workshop` и побайтный канон батареи (так задумано приёмкой 2/7).
  4. Интерфейс: одна env-переменная, один ключ профиля, коды rc 1 (`TRACE_SEED_SOURCE_INVALID`) и диагностика stderr; работа скрыта больше интерфейса.
  5. Потребители — make_task и CI-шаг 209; грамматику 095 переиспользует тот же awk.
- Ветка `TRACE_SEED_REGISTRY_INVALID` (`:265-266`) — ESSENTIAL как fail-closed при сломанной установке, но контрактом не названа и клетки не имеет → совет С-3. Простой формы, проходящей те же строки приёмки и меняющей их исход, нет, поэтому не блок.
- Строка `# shellcheck shell=bash` (`:237`) — ACCIDENTAL: свойства нет, простая форма (без строки) проходит те же строки приёмки → совет С-4. Не блок: строка не мешает ни одному свойству.
- Изменения семьи батареи 209 (клетки empty-mark/archive-mode/partial-role, +3 стаба, 1 строка канона, SDACHA) — ESSENTIAL: закрывают Б-1..Б-3; потребитель — CI-шаг; свой грамматики нет, используются `_toy.sh` 095 и реальная цепочка.
- CI-шаг, замер и lane в `ci.yml` — ESSENTIAL (приёмка 7); `ci.yml` — производная `gen_ci_steps`, а не вторая грамматика.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (grep rc 1; в `docs/` таких файлов нет) — затронутых разделов нет, сверять не с чем. Механически: `bash -n` rc 0, пиновый shellcheck без новых находок.

СВЕРКА-АРХИТЕКТУРЫ:
- Модели 188 и `bindings.json` в дереве нет (glob пуст).
- Размещение: правка внутри существующего единственного writer архива `prepare_model_trace`.
- Зависимости: jq и существующий `scripts/models_actual.sh`; из `config/agent_models.json` читаются только ключи `.roles`.
- Писатели: архив и метку пишет только `prepare_model_trace`; живую строку orchestrator по-прежнему пишет session-trace.
- Операции: новых CLI нет.
- Долг не расширен; diff модели — нет (уровень L0). Находку 188 не создаю.

sourceCanon в `harness.project.json`/`registry/harness-project.json` не объявлен (grep rc 1) — gate 996 не применим. Мобильного экрана в предмете нет.
