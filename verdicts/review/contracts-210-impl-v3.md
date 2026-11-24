accept
OBJECT=499824d89012d47ca0fd7fc670742a13ec308e6a
СУД: репо=dev-harness; предмет=210; роль=reviewer; вызов=3 (узкий scoped по SANKCIJA консультанта); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev210c | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=Rev210 v1 FAIL, Rev210b accept; класс риска=рисковый
КЛАСС=КОДОВЫЙ. Блоков 0. Советов 2 (С-1, С-2), наблюдений для Main 2 (Н-1, Н-2) — `.review/2026-11-24-158.md`.

# Вердикт reviewer — 210, реализация, вызов 3 (узкий: дельта r12→r13 «пустой протокол git log»)

**Итог: accept по дельте.** Регресс r12 устранён: свежий мир `make_repo` (один корневой коммит) и история из одних добавлений зелёные во всех режимах. Верифицирующий барьер `check_charter` снова 13/13. Fail-closed сохранён: при пустом основном потоке и существующем MD-коммите — отказ, оборванный хвост — отказ. Новые клетки на базе `009ceeeba` красны ровно пятью новыми клетками и именно прежним сообщением. Для done 210 нужен ещё accept адверсария; в этот вызов он не входит.

Остальное — production 210 до дельты, CI-реестры, контракт — принято вызовами 1–2 и здесь не перепроверялось. Вне скоупа по заданию: `lib_zones.sh:311–314` (принятый остаточный риск), аттестат адверсария, флак 083 И0.

## Область

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t45c192c30/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/210/orchestrator-r13 refs/heads/main → rc 0 (main = 1ec47271534b)
git switch --detach 499824d89012d47ca0fd7fc670742a13ec308e6a; git rev-parse HEAD → 499824d89012d47ca0fd7fc670742a13ec308e6a
git log --oneline origin/main..OBJECT → 15 коммитов; merge-base с main = ecaa3f34e
git diff --name-only 009ceeeba1fa1932292da0dcbc22eac69adb54c5 OBJECT -- scripts .githooks → scripts/check_charter.sh (единственный)
git diff --stat b1ace8b2d OBJECT (носитель r12 после переноса → r13):
  fixtures/workshop_project/charter_tekst_do_tega_210/{SDACHA.md, model/check_charter.sh, probe.py, stabs.tsv}
  scripts/check_charter.sh | 22 ++-   (+20 −2)
```

Новых коммитов на носителе два, у каждого свой автор и свой предмет:

| коммит r13 | автор / коммиттер | файлы | исходник | patch-id |
|---|---|---|---|---|
| `a446bc3f5` | implementer / orchestrator | `scripts/check_charter.sh` | Impl210e `1cc8ed23e` | `d3a0b0fa…` = `d3a0b0fa…` |
| `499824d89` | architect / orchestrator | 4 файла семьи 210 | Arch210g `1754a02d5` | `ef893876…` = `ef893876…` |

Оба файла — в своих зонах по контракту: `ЗОНА implementer: scripts/check_charter.sh` и `ЗОНА architect: fixtures/workshop_project/charter_tekst_do_tega_210/`. Коммиты атомарны.

Дельта `009ceeeba..OBJECT` вне 210 (`roles/*`, `.omp/agents/*`, ADR 2026-11-24, `registry/contracts.tsv`) пришла с main: `git diff --stat ecaa3f34e OBJECT` этих путей не содержит. Нормативные документы дельтой 210 не тронуты.

Семантика production, необъявленной нет (`scripts/check_charter.sh:1142–1150`):
- `[ -n "$__ch_line" ]` (оборванный хвост) — отказ, как раньше;
- `elif [ -z "$__ch_c" ]` — только при пустом основном потоке выполняется независимая проба `g log -1 --format=%H --no-renames --diff-filter=MD --diff-merges=first-parent HEAD`;
- rc ≠ 0 или непустой вывод пробы — тот же отказ с тем же текстом;
- `unset` дополнен `__ch_pr __ch_pmatch`.

Происхождение отказа на пустоту: `git log -S'пустой или оборванный протокол'` даёт `49cee7d3d` (NUL-транспорт самого 210) и `a446bc3f5`. На main (`ecaa3f34e`) такой проверки нет, пустой поток там — «нет изменений». Значит, дельта чинит собственный регресс 210, а не ослабляет чужую норму 992. На законной пустоте поведение равно main, при MD-коммите и пустом потоке — строже main. ПЕРЕСЕЧЕНИЕ 992 «отказы чтения … истории сохраняются» соблюдено.

## Регресс

Довод Arch210g («реально достижимого входа "MD-коммит есть, NUL-поток пуст" на здоровом git нет»): **согласен.**

Моя мера — `/tmp/…/gitsem.sh`, git 2.43.0. Проба (`-1`, без `-z`) и основной `-z --name-only`-поток с теми же HEAD и фильтром:

| форма истории | проба | основной поток (`od -c`, строк) |
|---|---|---|
| только root | пусто, rc 0 | 1 (пусто) |
| root + добавление | пусто, rc 0 | 1 (пусто) |
| старый M, затем 5 добавлений | sha старого M, rc 0 | 4 |
| merge, приносящий M по 2-му родителю (first-parent diff M) | sha merge | 10 |
| только удаление | sha | 4 |
| только переименование (`--no-renames` ⇒ D) | sha | 4 |
| только смена типа (T вне MD) | пусто | 1 (пусто) |

Непустая проба совпала с непустым потоком во всех семи формах. `-1` отбирает коммиты после фильтра, а не до: старый M за пятью добавлениями найден.

Расхождение возможно только при смене HEAD между двумя вызовами [INFERENCE]. Если поток законно пуст на H1, а к H2 появился MD-коммит, будет ложный красный, то есть fail-closed. Ложного зелёного это не даёт.

Попутный факт: на git 2.43 `--diff-merges=first-parent` подразумевает `-p`, поэтому непустая проба печатает патч одного коммита. На решение (пусто или непусто) это не влияет.

Fail-closed по мутантам production — `/tmp/…/mutants.py`, клетки `empty-*` и `wire-errors-*`:

| мутант | `empty-*` (11) | `wire-errors-*` (4) | чем пойман |
|---|---|---|---|
| M1 «пустота всегда оправдана» (блок пробы удалён) | 11/0 | **1 красная** | `wire-errors-empty` |
| M2 «проба читает тот же `-z`-поток» (`$TMP/log-data`) | 11/0 | **1 красная** | `wire-errors-empty` |
| M3 «проба = тот же вызов `-z --name-only`» | 11/0 | **1 красная** | `wire-errors-empty` |
| M4 «rc пробы игнорируется» | 11/0 | 4/0 | **жив** → С-2 |
| M5 «проба без фильтра MD» | **5 красных** | 4/0 | root/additions fast/incr, seed |
| M6 «возврат прежнего отказа» | **5 красных** | 4/0 | те же 5 (= `EMPTY-OLD-REJECTION`) |

Вывод: мутации M1–M3, которые в SDACHA названы непойманными, на деле ловит существующая инъекция `wire-errors-empty`. Остаток консервативен (С-1). Ветвь rc пробы (M4) без клетки (С-2). Обе находки — советы: на OBJECT ветвь fail-closed поймана, а M4 требует двойного сбоя.

## Проверки

Окружение: `TMPDIR=/tmp/dev-harness-verify/scratch-rev210c`, `VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`. Батареи 210 запускались на копии (только чтение источников, миры под TMPDIR). Всё прочее — в одноразовых клонах `clone` (OBJECT) и `base` (`009ceeeba`) с собственным `.git`.

| # | Команда | rc | Вывод |
|---|---|---|---|
| 1 | `bash …/red_charter_tekst_do_tega_210.sh --repo .` (OBJECT) | 0 | `ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0`, 61 с |
| 2 | `bash …/red_charter_tekst_do_tega_210.sh --model` | 0 | `ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0`, 68 с |
| 3 | `bash …/red_charter_tekst_do_tega_210.sh --stabs` | 0 | `ИТОГ 210: MUTACII=41 SVJAZI=50 POIMANY=50 ZHIVYH=0`, 33 с |
| 4 | `python3 …/probe.py --repo <клон 009ceeeba>` | 1 | `KLETKI=325 ZELENYE=320 KRASNYE=5`; красны ровно `empty-root-fast`, `empty-root-incr`, `empty-additions-fast`, `empty-additions-incr`, `empty-root-incr-seed`, во всех actual — `FAIL пустой или оборванный протокол git log` |
| 5 | `bash scripts/verify_antiplacebo.sh --scope check_charter` (клон OBJECT) | 0 | `барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13` |
| 5′ | то же на клоне `009ceeeba` | 1 | 7 FAIL «нет положительного контроля»: agents_bez_razreshenija, razreshenie_bez_prichiny, razreshenie_bez_puti, razreshenie_v_drugom_kommite, reestr_nedostupen, zamorozhennyj_plan_izmenjon, zloj_lend_bez_stroki_krasnyj; `предъявлено … 6` — регресс r12 воспроизведён |
| 6 | `bash fixtures/charter_fast_113/red_113.sh` (клон OBJECT, теги с GitHub, origin живой) | 0 | `клеток: 28 · красных: 0`; В: холодный клон 16 с |
| 6′ | то же на клоне с peeled-тегами копии | 1 | `клеток: 28 · красных: 1` — только В «холодный клон rc=1» (среда, Н-2) |
| 7 | `bash fixtures/_krasnye_083.sh` (клон OBJECT), прогон 1 / прогон 2 | 1 / 1 | `ok=118 FAIL=2` / `ok=117 FAIL=3`; все И4-4 ok в обоих прогонах (charter, zones, ids, protected — линия/объект); FAIL только И0/И0б check_charter (rc субъекта 0, гонка SIGPIPE проверки) и check_zones (rc 141) — Н-1 |
| 8 | `check_charter.sh` (OBJECT) на мирах `make_repo`, cwd = корень мира | — | root: fast 0 / oracle 0 / incr(seed) 0, кеш = HEAD / incr(base=root) 0 «(0 коммитов)»; additions: 0 / 0 / 0, кеш = HEAD / 0 «(2 коммита)»; md-edit: 1 / 1 / 1 (кеш не записан) / 1 «(1 коммит)», везде один FAIL `AGENTS.md … без разрешения` — вердикты режимов согласованы |
| 8′ | `check_charter.sh` на клоне дерева OBJECT, origin живой | 0 / 0 | fast: `уставных документов: 191 · изменений в них: 593 · с разрешения: 593`; `--incr` base=HEAD~1: «судит a446bc3f..499824d8 (1 коммит)», кеш = HEAD. `--oracle` на полной истории (9053 коммита по `git rev-list --count HEAD`) не уложился в 8 мин и снят; режимы сверены на мирах (п. 8) и батареей 113 (Д-клетки) |
| 9 | `bash -n scripts/check_charter.sh`; `bash -n …/model/check_charter.sh` | 0; 0 | — |
| 9 | shellcheck 0.11.0 `-f gcc` OBJECT против `009ceeeba` | 1 / 1 | по 8 находок, множества текстов совпадают (`diff` rc 0): новых нет |
| 10 | `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` (клон OBJECT) | 0 | «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)», 483 с; среди 12 дверей — pre_critic, `--model`, `--stabs`, `--syntax`, `gen_ci_steps --check`; `git status --short` клона после прогона пуст |

Своя мера для счётных утверждений:
- 325/41/50 — импорт `probe.py`: `len(cells())=325`, из них `empty-*` 11, `len(MUTATIONS)=41` (37 литералов + 4 из словарного включения NUL-167); `stabs.tsv`: 50 непустых некомментарных строк при 41 различном имени.
- «+11 клеток / +4 привязки / +2 мутации» — по диффу: 3 формы × 3 режима + seed + md-edit = 11; в `stabs.tsv` 46 → 50.
- «5 красных на базе» — п. 4 моим прогоном на собственном клоне.
- «13/13» и «7 из 13 на r12» — п. 5 и 5′.
- Cherry-pick — по patch-id, а не по сообщениям коммитов.

Неподгонка: клетки написаны architect, production — implementer, каждый в своём коммите. Ожидания `EmptyWorld.expected()` строятся из формы мира до запуска субъекта, валидность мира проверяется до субъекта (число коммитов, отсутствие родителя у root, пустота обоих потоков, у M-соседа оба непусты). Клетки различают прежний дефект (п. 4, M6) и не повторяют формулировку production: ожидание rc 0 и полного stdout/stderr выведено из свойства «законная пустота — не отказ».

## Блоки

Нет.

## НЕ ЗАЩИЩАЕТ

Строки остатка контракта 210 с ловцом reviewer:
- ОСТАТОК: НЗ-1 (воля человека, администрирование origin) — не укусил. Предикат публикации и owner-канал дельтой не тронуты.
- ОСТАТОК: НЗ-2 (plans/ROADMAP/AGENTS, /2+, draft вне /1, octopus) — не укусил. Дельта меняет только реакцию на пустой поток, область и освобождение прежние.
- ОСТАТОК: НЗ-3 (будущие v+1-окна `check_contract_frozen`/`check_zones`) — не укусил. Этих файлов в дельте нет.
- НЗ-4 (сговор автора батареи) — ловец adversary, не мой.

Остатки, добавленные в SDACHA дельтой (ловцы adversary/reviewer):
- «Вход "MD-коммит есть, NUL-поток пуст, log -1 непуст" на здоровом git не найден» — не укусил: 7 форм истории (§Регресс), довод принят. Формулировка о непойманных мутациях занижена (С-1).
- «Мир без ustav/1 — именованный rc 2, не проверен» — не укусил: `empty-no-ustav-*` дают rc 2 с одной и той же причиной, политика не менялась.

Остаточный риск по решению: `scripts/lib_zones.sh:311–314` — вне скоупа, в дельте отсутствует.

Паразитная сложность (050), по артефактам дельты:
- **A1. Ветвь пробы в production** (`scripts/check_charter.sh:1142–1150`, переменные `__ch_pr`, `__ch_pmatch`).
  1. Свойство — К-07: законная пустота даёт rc 0, а «прежние ошибки/оборванный поток сохранены» (`wire-errors-empty`).
  2. Состояние — две локальные переменные, снимаются `unset`, видны только через прежнее сообщение отказа.
  3. Совместно меняемых файлов три: production, модель, якорь в `probe.py`. Это прежняя схема, дифф её не расширил.
  4. Интерфейс (аргументы, rc, env) не вырос.
  5. Потребители — 11 клеток `empty-*` и `wire-errors-empty`.

  Более простая форма — убрать проверку пустоты (= M1). Она зелёна на `empty-*`, но красна на `wire-errors-empty`, поэтому строки приёмки не проходит. **ESSENTIAL.**
- **A2. `EmptyWorld` и `observe_empty`** (`probe.py`, +~110 строк).
  1. К-09: настоящие миры с нулём MD-коммитов.
  2. Состояние — TemporaryDirectory, предпосылки явные (`INVALID_EMPTY_WORLD`, `ROOT_HAS_PARENT`).
  3. Один файл.
  4. Новых флагов нет, есть фильтр формы `empty-*`.
  5. Потребитель — CI-шаг self-test 210.

  `observe_empty` частично повторяет общий путь `observe` (снимок, запуск, чтение кеша). Фрагмента с более простой формой, проходящей те же строки, я не предъявляю. **ESSENTIAL**, повтор — не находка.
- **A3. Две мутации и четыре привязки** — К-08, адресация по коду. **ESSENTIAL.**
- **A4. Зеркало в модели** (`model/check_charter.sh`) — `--model`/`--stabs` работают на модели, блок побайтно равен production, кроме `unset`. **ESSENTIAL.**

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции не объявляет документ архитектуры и стандарт кода (`docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md` в дереве нет). Стиль дельты: `set -u`-безопасные локальные переменные, `unset` после блока, отказ через `bad` с прежним текстом — соответствует соседнему коду файла.

СВЕРКА-АРХИТЕКТУРЫ:
- размещение — в существующем шаге 3 быстрого обхода;
- зависимости — тот же `g` (`git -C "$ROOT"`), новых нет;
- писатели — нет (проверка не пишет состояние, кеш пишет прежний `incr_finish`);
- операции — один дополнительный read-only `git log -1`, только при пустом потоке;
- `bindings.json` и `tooling/checks/cli.js` в дереве нет, дифф модели L0;
- долг не расширен.

## Советы

- **С-1 (architect).** Привязать M1/M2 к `wire-errors-empty` в `MUTATIONS`/`stabs.tsv`. Сузить текст остатка SDACHA до действительно непойманного.
- **С-2 (architect).** Клетка `wire-errors-probe` (двойник роняет `log -1`, rc 128) плюс мутация M4 «rc пробы игнорируется». Либо явная строка остатка.
- **Н-1 (Main → 217).** Флак 083 И0/И0б на OBJECT — это гонка SIGPIPE в `printf | grep -q` под `pipefail` (`red_ci_a_083.sh:1501`, `:1528`): 14/200 на OBJECT и 15/200 на базе. Timeout тут ни при чём, дельта 210 тоже.
- **Н-2 (Main).** Теги `frozen/*` в копии станции peeled. Прогоны дерева и батареи 113 делать в клоне с аннотированными тегами GitHub.

Подробности, меры и простые формы — `.review/2026-11-24-158.md`.
