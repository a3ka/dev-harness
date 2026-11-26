accept
OBJECT=3d5d2e0289691eb74842a4af47840f694ece3914
СУД: репо=dev-harness; предмет=219; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev219 (станция c907157c); модель-факт=anthropic/claude-opus-5-5 (метаданные среды судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev219 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl219 — implementer (MiniMax), Architect219b; предыдущие адверсарные: archive/219/adversary-v1-fail-159beca827, archive/219/adversary-v2-fail-fc4c130523; правило остановки R-0115 п.1
КЛАСС=КОДОВЫЙ. КЛАСС РИСКА=рисковый. Блоков 0. Советов 1 (С-1) — `.review/2026-11-25-2191.md`.

# Вердикт reviewer — 219, реализация, вызов 1 (полный)

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 1.** С-1 (architect, после done): совместные миры «U + учётный файл» для add и remove меняют только `registry/pauzy.tsv`. Поэтому 4 из 13 моих мутантов `c_klass` этого класса живы. Подробности — в `.review/2026-11-25-2191.md`.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

**Итог: accept.**
- Дифф в зонах frozen 219.
- Production классификатора не менялась.
- Три учётные строки побайтно равны канону.
- Оракул 087 расширен ровно фрагментом `model/oracle_extension.py`, А8 сохраняет точное равенство.
- CI-шаг исполняет `--repo .` и `--stabs`.
- Регресс зелёный.
- Дыра К-08 Adv219b воспроизведена, это слабость батареи. На честной production ложной классификации учётного пути нет: реестр U защищён (`PROTECT`) и всегда входит в H. По R-0115 п.1 нового адверсария нет. Дыра уходит в остаток С-1 под owner-аттестат консультанта.

## Порядок судей

Предмет рисковый (контракт, строка 4). Порядок: adversary → reviewer.
- Adv219, вызов 1 (`159beca82`): FAIL К-01 + К-08.
- Adv219b, вызов 2 (`fc4c13052`): К-01 закрыт, FAIL только К-08, «production честна».
- Слово владельца R-0115 п.1 (постановка): «219 и 224 — правило остановки по адверсарию как у 210: да». Значит, нового адверсария нет, а accept адверсария заменяется owner-аттестатом консультанта после accept ревьюера.

Этот вызов идёт после обоих адверсариев на том же OBJECT, не параллельно им.

## 1. Область правки

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t08f093257/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/219/orchestrator-q2 refs/heads/main refs/heads/archive/219/adversary-v1-fail-159beca827 refs/heads/archive/219/adversary-v2-fail-fc4c130523 '+refs/tags/*:refs/tags/*' → rc 0
git switch --detach 3d5d2e0289691eb74842a4af47840f694ece3914; git rev-parse HEAD → 3d5d2e0289691eb74842a4af47840f694ece3914
origin/main = 99e3f0d17e0e; git merge-base origin/main HEAD → a32c577f292a2e925417d78a85cdb00abf25fae3
git tag -l 'frozen/contracts/219/*' → frozen/contracts/219/1
git diff 'frozen/contracts/219/1^{commit}' HEAD -- contracts/219-uchetnye-puti-ci-klass.md → пусто (контракт = frozen)
git diff --name-status a32c577f2 HEAD →
  M .github/workflows/ci.yml
  M fixtures/ci_b_087/_orakul.py
  M fixtures/workshop_project/uchetnye_puti_219/SDACHA.md
  A fixtures/workshop_project/uchetnye_puti_219/model/registry_data_mutation.py
  M fixtures/workshop_project/uchetnye_puti_219/probe.py
  M fixtures/workshop_project/uchetnye_puti_219/stabs.tsv
  M registry/ci-steps.tsv
  M registry/ci-zamery.tsv
git log --format='%h %an %cn %s' a32c577f2..HEAD →
  3d5d2e028 architect orchestrator 219: cover joint accounting-list and data changes
  ec9d105ab orchestrator orchestrator orchestrator: 219 CI-шаг — добавлен --stabs (К-01 Adv219 …; вес 30, замер 16 с)
  89893e66a orchestrator orchestrator orchestrator: 219 учётные строки uchet (pauzy, mesto-legacy, lessons-harness) … CI-шаг … пересчёт JOBS ci.yml
  620184738 implementer orchestrator 219: extend 087 oracle U87 from the 219 canon snapshot
```

| роль | коммиты | файлы (`git log --name-status`) | ЗОНА frozen 219 |
|---|---|---|---|
| implementer | 620184738 | `fixtures/ci_b_087/_orakul.py` | `ЗОНА implementer: fixtures/ci_b_087/_orakul.py` — в зоне |
| orchestrator | 89893e66a, ec9d105ab | `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml` | `ЗОНА orchestrator: …` — в зоне |
| architect | 3d5d2e028 | 4 файла `fixtures/workshop_project/uchetnye_puti_219/` | `ЗОНА architect: … fixtures/workshop_project/uchetnye_puti_219/` — в зоне |

Вне зон ничего нет. `scripts/`, `contracts/`, `roles/`, `AGENTS.md` дифф не трогает. Атомарность: каждый коммит одной роли со ссылкой на 219.

Содержание правок, своей мерой:
- `registry/ci-steps.tsv`: удалённых строк 0 (`git diff … | grep -c '^-[^-]'` → 0). Добавлены 3 строки `uchet` после `registry/plan.tsv` и одна строка `step`.
  - `grep '^uchet	' registry/ci-steps.tsv | tail -n 3 | cmp - model/uchet.tsv` → rc 0: побайтно канон.
  - Всего `uchet` 13, дублей 0.
  - `registry/risk-legacy.tsv` и `registry/dostavki/` не включены.
- `registry/ci-zamery.tsv`: +1 строка `check:uchetnye-puti-219-family-selftest	30	16	0`. Чужие строки не тронуты.
- `.github/workflows/ci.yml`: изменён только генерируемый блок JOBS (перебалансировка lane), `gen_ci_steps.sh --check` rc 0. Шаг 219 попал в `l5`.
- `fixtures/ci_b_087/_orakul.py`: фрагмент `model/oracle_extension.py` стоит после литерала `U87 = [...]` ровно один раз. Проверка: `ext-in-oracle True after-U87-literal True count 1`. `len(U87)=13`, уникальных 13. Алгоритм A8 (`red_ci_b_087.sh:331-336`) — точное равенство отсортированных множеств, а не subset.
- Architect219b (`git diff 89893e66a HEAD -- probe.py stabs.tsv | grep '^-[^-]'`): удалено 5 строк, все расширены, ни одна не ослаблена.
  - `elif op == 'reg-add'`, `'reg-remove'`, `'reg-replace'` → `op in ('reg-X', 'reg-X-data')`.
  - `if expected == 'uchet':` → `… or op in (joint)`.
  - Список `syntax()` дополнен `registry_data_mutation.py`.
  - В `stabs.tsv` прежние 28 строк не тронуты, +3.

## 2. Ручная проверка названных дыр (К-08 Adv219/Adv219b)

Одноразовый клон `tmp/clone-mut`: свой `.git`, detached на OBJECT. Сценарий `tmp/scratch-rev219/attacks_rev219.py` — мой, удалён перед докладом. Каждый мутант заменяет единственный якорь `scripts/ci_klass.sh:219` (`    print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')`) телом вида «если `REG` и `<файл>` оба в `git diff --name-only` и `<условие>` → `uchet`, иначе честное сравнение». Условия:
- any — `True`;
- add — `len(after) > len(before)`;
- remove — `len(after) < len(before)`;
- replace — `len(after) == len(before) and after != before`.

Для каждого мутанта прогоняются:
- `W --repo .`;
- дословная команда CI-шага из `registry/ci-steps.tsv`;
- свидетель — настоящий Git-мир с реальным реестром OBJECT, где одним коммитом меняется операция над U и ровно ОДИН учётный файл;
- тот же мир на честной production.

После прогонов клон восстановлен (`RESTORED clean`).

| мутант | `W --repo .` | CI-шаг | свидетель мутант → честная |
|---|---|---|---|
| v1-pauzy-any (дословно Adv219) | rc 1, 32/35, красны 3 `*-with-data` | rc 1 | add/remove/replace: `uchet` → `kod` |
| pauzy-add | rc 1, 34/35 (`registry-add-uchet-with-data`) | rc 1 | `uchet` → `kod` |
| pauzy-remove | rc 1, 34/35 (`registry-remove-uchet-with-data`) | rc 1 | `uchet` → `kod` |
| pauzy-replace | rc 1, 34/35 (`registry-replace-uchet-with-data`) | rc 1 | `uchet` → `kod` |
| mesto-any | rc 1, 34/35 (`registry-replace-uchet-with-data`) | rc 1 | `uchet` → `kod` ×3 |
| **mesto-add** | **rc 0, 35/35** | **rc 0, 31/31** | `uchet` → `kod` |
| **mesto-remove** | **rc 0, 35/35** | **rc 0, 31/31** | `uchet` → `kod` |
| mesto-replace (remove-free replace-only) | rc 1, 34/35 | rc 1 | `uchet` → `kod` |
| lessons-any | rc 1, 34/35 | rc 1 | `uchet` → `kod` ×3 |
| **lessons-add** | **rc 0, 35/35** | **rc 0, 31/31** | `uchet` → `kod` |
| **lessons-remove** | **rc 0, 35/35** | **rc 0, 31/31** | `uchet` → `kod` |
| lessons-replace | rc 1, 34/35 | rc 1 | `uchet` → `kod` |

Пойманы 9 из 13, живы 4. Это совпадает с Adv219b: `place-add`, `place-remove`, `lessons-remove` живы, `lessons-replace` пойман. Плюс я нашёл живой `lessons-add`. Мутант вызова 1 закрыт ремонтом Architect219b.

Полная батарея 087 на живом мутанте `mesto-remove`: `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)`, rc 0. CI в целом этот мутант тоже не красит.

**Достижимость вреда на честной production — нет.**
- `registry/ci-steps.tsv` ∈ `PROTECT` (`scripts/ci_klass.sh:36`). `parse_uchet` отказывает любой строке, покрывающей его точно или каталогом (`:110-113`). Значит, ни одна допустимая U не исключает реестр из `kod_hash` (`:138-150`).
- Любое add/remove/replace строки `uchet` меняет байты реестра, поэтому H(old) ≠ H(new) при любых U, а `klass` и `vorota` дают `kod` независимо от того, какие учётные файлы правятся в том же коммите.
- Сквозной прогон на реальном дереве OBJECT (`tmp/clone-mut`, затем `reset --hard`):
  - коммит «правка трёх учётных файлов»: `klass` → `uchet` rc 0; `vorota` → `учётный: H=e0c2b534…` rc 0; `hash` равен;
  - коммит «+`uchet registry/new-example.tsv` и правка `mesto-legacy.tsv`»: `klass` → `kod` rc 0.
- Живой мутант требует правки `scripts/ci_klass.sh`. Это защищённый кодовый путь, такая правка сама идёт полным CI и судом.

Вывод: дыра — слабость различимости батареи (К-08), а не ложная классификация учётного пути. Поэтому это СОВЕТ С-1 architect после done, а не блок.

## 3. Регресс

Чистый клон `tmp/clone-reg`: `git clone --no-local` копии, origin = `ssh://git@github.com/a3ka/dev-harness.git`, `origin/main` из GitHub, detached на OBJECT, `git status --short` пуст. Окружение: `TMPDIR=$PWD/tmp/scratch-rev219`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. Прогоны шли по одному. `W = bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh`.

| # | команда | rc | итог |
|---|---|---|---|
| 1 | `W --repo .` | 0 | `KLETKI=35 ZELENYE=35 KRASNYE=0` (11,6 с) |
| 2 | `W --stabs` | 0 | `SVJAZI=31 POIMANY=31 ZHIVYH=0`, все 31 `POIMAN`, контроль GREEN (9,6 с) |
| 3 | `W --model` | 0 | `KLETKI=35 ZELENYE=35 KRASNYE=0` |
| 4 | `W --sintaksis` | 0 | `SYNTAX rc=0` |
| 5 | `W --catalog` | 0 | `KLETKI=35 MUTACII=14 SVJAZI=31 UCHET=13` |
| 6 | `W --model --compat` | 0 | `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31`; `COMPAT red_ci_b_087.sh rc=0`, `gen_ci_steps.sh rc=0`, `check_provodka.sh rc=0` (80 с) |
| 7 | `W --repo . --compat` | 0 | то же, 110/110, 31/31, три COMPAT rc=0 (73 с) |
| 8 | `bash fixtures/ci_b_087/red_ci_b_087.sh .` | 0 | `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)` (93 с) |
| 9 | `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| 10 | `bash scripts/check_provodka.sh . contracts/219-uchetnye-puti-ci-klass.md` | 0 | — (без аргументов: rc 1 usage `<корень-дерева> <отн-путь-контракта>`, это не прогон) |
| 11 | `bash scripts/verify_antiplacebo.sh --scope check_provodka check_ci_gate` (соседи: потребитель H и барьер проводки) | 0 | `барьеров: 2 · фикстур: 36 · предъявлено красным повторным прогоном: 36` |
| 12 | `bash -n` + shellcheck 0.11.0 `-S warning`: `red_uchetnye_puti_219.sh`, `scripts/ci_klass.sh` | 0×4 | изменённых `.sh` в диффе 0 (`git diff --name-only a32c577f2 HEAD -- '*.sh' \| wc -l` → 0) |
| 13 | `python3 -m py_compile _orakul.py probe.py model/registry_data_mutation.py` | 0 | — |

`scope_select.sh . --changed a32c577f2` → `MODE: full`: дифф задевает `ci.yml`/реестр. Полный antiplacebo и полные `pre_critic`/`check_sdacha` из изолированной копии не запускались, это зона main.

Счётные утверждения я проверял своей мерой, другой командой:
- в `CASES` 9 (3 файла × add/edit/delete) + 20 (`CASES.update`) + 6 (PROTECT exact/parent) = 35, по чтению `probe.py:137-165`, а также 35 строк клеток в выводе `--repo .`;
- `grep -vc '^#' stabs.tsv` → 31;
- `cut -f1 | sort -u | wc -l` → 14 мутаций;
- `grep -c '^uchet	' registry/ci-steps.tsv` → 13.

Это сходится с SDACHA и обоими адверсариями (35/14/31/13).

Контракт по пунктам:
- **К-01 (CI-шаг).** `registry/ci-steps.tsv:335` = `… --repo . && … --stabs`. Дословная команда, извлечённая из реестра, исполнена через `bash -c` в чистом клоне на честном дереве: rc 0, обе части напечатали итоги (`KLETKI=35 ZELENYE=35 KRASNYE=0`, `SVJAZI=31 POIMANY=31 ZHIVYH=0`). На мутантах шаг даёт rc 1 при красной `--repo .` и rc 0 только у четырёх живых.
- **Приёмка 5.** `--model` вместо production не подключён.

## 4. Свои мутанты production (тексты отличны от якорей `MUTATIONS`)

Сценарий `tmp/scratch-rev219/own_mutants.py` (удалён). Каждый мутант — каталог с `registry/ci-steps.tsv` и `scripts/ci_klass.sh`; запуск `W --repo <каталог>`.

| мутант | замена | rc | красные |
|---|---|---|---|
| own1-reg-not-hashed | `kod_hash`: `path == b'registry/ci-steps.tsv' or is_uchet(…)` | 1 | 17/35, в т.ч. `registry-{add,remove,replace}-uchet{,-with-data}` |
| own2-klass-U-new | `c_klass`: `need_pats(n)` вместо `need_pats(o)` | 0 | 0/35 — **эквивалентный**, см. ниже |
| own3-mode-dropped | `kod_hash`: в хеш идёт запись без поля режима | 1 | 15/35, в т.ч. `code-mode` |
| own4-basename-match | `covers` file: `path == v or basename(path) == basename(v)` | 1 | 1/35: `nested-pause` |
| own5-lessons-as-glob-dir | строка реестра `registry/lessons-harness.tsv` → `registry/lessons/` | 1 | 15/35, в т.ч. `snapshot-exact`, `lessons-*` |

own2 эквивалентен по построению. Если байты реестра на `o` и `n` равны, то U(o)=U(n). Если различны, реестр (∈ PROTECT, не покрываем) входит в оба хеша с разными блобами, и при любых U получается `kod`. Единственное расхождение — новая U, покрывающая PROTECT: мутант даёт отказ rc 1, честный `kod` rc 0. Оба исхода не пропускают код. Это наблюдение, а не находка.

Дефектов честной production в диффе нет, production не менялась.

Потребители трёх файлов, по дереву OBJECT (`grep` по `scripts/`, `fixtures/`, `ops/`, `.githooks/`):
- `done_contract.sh:637-657` читает `git show HEAD:registry/mesto-legacy.tsv`, значения фиксированы кодом; strip рабочего дерева на это не влияет.
- `make_task.sh:931-933` только ставит префикс `ПАУЗА:` по id.
- `zamok_predmeta.sh:627` читает состояние паузы.
- `orch_plan_slice.sh:111` считает паузы опциональными.

Ни одна тяжёлая CI-проверка не читает эти файлы из корня репозитория. Чтений вида `ROOT…/(pauzy|mesto-legacy|lessons-harness)` в `scripts/`/`fixtures/` нет, кроме описания в SDACHA 201. Strip перед тяжёлыми джобами (`ci.yml:200,250,292`) их не ломает.

## 5. Подгонка проверок под код

- Implementer трогал только `_orakul.py`, и ровно в форме, которую задаёт контракт (`model/oracle_extension.py`, побайтно). Файлы проверок 219 он не менял.
- Architect219b дописал клетки и стабы после реализации. Production и контракт при этом не менялись (`git diff 89893e66a HEAD -- scripts contracts` пуст, по Adv219b и моему `git diff --name-status`).
- Ожидания новых клеток (`kod`, `oracle_hash` по закреплённому `U87@8b52fade` + канон) снимаются в памяти до вызова субъекта. Миры — настоящие Git-коммиты. Проверка `h_old == h_new → Infrastructure` не даёт клетке пройти на вырожденном мире.
- Прежние ожидания не ослаблены (см. §1).
- Красное предъявлено: все 31 стаб `POIMAN`, а также мои мутанты own1/own3/own4/own5 и 9 из 13 мутантов класса К-08.

## Остатки

Строки НЕ ЗАЩИЩАЕТ контракта с ловцом reviewer (контракт 192):
- ОСТАТОК: К-16 (ложь санкционированного автора о паузе/месте; текст команд в исключённом файле) — не укусил. Дифф данных трёх файлов не меняет. Потребители (`done_contract.sh:637-657`, `make_task.sh:931-933`, `zamok_predmeta.sh:627`, `orch_plan_slice.sh:111`) содержимое не исполняют.
- ОСТАТОК: К-16 (будущее изменение потребителя, превращающее данные в политику) — не укусил. Дифф не трогает `scripts/`, потребители прежние.
- ОСТАТОК: К-08 (распознавание конечной фикстуры) — укусил батарею, не production. Мутанты `mesto-add`, `mesto-remove`, `lessons-add`, `lessons-remove` на якоре `scripts/ci_klass.sh:219` зелены по `W --repo .`, CI-шагу и 087. Место в диффе — `fixtures/workshop_project/uchetnye_puti_219/probe.py:252-255` (`paths = … else (PAUSE,)`). Уходит в С-1, под owner-аттестат консультанта по R-0115 п.1.

Остатки адверсариев:
- К-16 Adv219 (mode/symlink учётного пути → `uchet`): путевой классификатор, не укусил.
- `hash` с `uchet registry/risk-legacy.tsv`/`registry/dostavki/` даёт rc 0: эти пути не PROTECT. Их отсекает точный снимок (`snapshot-exact`, стабы `RISK_IS_ACCOUNTING`/`RECEIPTS_ARE_ACCOUNTING` пойманы) и A8 087.

Паразитная сложность (050), по артефактам диффа:
- **A1. `_orakul.py` +7 строк.**
  1. Свойство — И5/А8, миграция U87 из канона (контракт требует явно).
  2. Состояние — чтение `model/uchet.tsv`, явное.
  3. Канон и реестр меняются вместе; число файлов не выросло: канон уже был.
  4. Интерфейс оракула прежний.
  5. Потребитель — A8 в CI.

  Более простая форма (литерал в оракуле) нарушает «расширение считывается из того же канона». **ESSENTIAL.**
- **A2. Три строки `uchet`.** И1, нужны по сути предмета. **ESSENTIAL.**
- **A3. CI-шаг и замер.** Требует приёмка 5. **ESSENTIAL.**
- **A4. Architect219b: 4 клетки, мутация `REGISTRY_WITH_DATA_IS_UCHET` с 3 привязками, `model/registry_data_mutation.py`.**
  1. Свойство — И3 (совместная правка).
  2. Состояние — временные миры, явное.
  3. Совместно меняются `probe.py`, `stabs.tsv`, model.
  4. CLI не вырос.
  5. Потребитель — CI-шаг.

  Без этих клеток мутант вызова 1 жив. **ESSENTIAL.** Отдельный файл для одной многострочной мутации при остальных inline в `MUTATIONS` — стиль, не находка.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции не объявляет документ архитектуры и стандарт кода (`grep 'ARCHITECTURE.md|CODING-STANDARDS' AGENTS.md` → нет совпадений). Разделов для сверки нет. Дифф — TSV, генерируемый YAML и Python фикстур в стиле соседнего кода семьи.

СВЕРКА-АРХИТЕКТУРЫ: н/п — контракт «АРХИТЕКТУРА: н/п — проектной модели 188 нет»; `tooling/checks/cli.js` и `bindings.json` в дереве нет.
- размещение — существующие реестр, оракул 087 и семья 219;
- зависимости — прежние (git, python3);
- писатели — временные миры под TMPDIR;
- операции классификатора не менялись;
- дифф модели L0, долг не расширен.

## Сырой вывод ключевых прогонов

```
W --repo .            : KLETKI=35 ZELENYE=35 KRASNYE=0                                   rc=0
W --stabs             : SVJAZI=31 POIMANY=31 ZHIVYH=0                                    rc=0
  REGISTRY_WITH_DATA_IS_UCHET -> registry-add-uchet-with-data: POIMAN; control=accounting-data-only GREEN; ["BYTES expected=(0, b'kod\\n', b'') actual=(0, b'uchet\\n', b'')"]
  REGISTRY_WITH_DATA_IS_UCHET -> registry-remove-uchet-with-data: POIMAN; control=accounting-data-only GREEN; […]
  REGISTRY_WITH_DATA_IS_UCHET -> registry-replace-uchet-with-data: POIMAN; control=accounting-data-only GREEN; […]
W --model             : KLETKI=35 ZELENYE=35 KRASNYE=0                                   rc=0
W --sintaksis         : SYNTAX rc=0                                                      rc=0
W --catalog           : KLETKI=35 MUTACII=14 SVJAZI=31 UCHET=13                          rc=0
W --model --compat    : ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)
                        COMPAT red_ci_b_087.sh rc=0 / COMPAT gen_ci_steps.sh rc=0 / COMPAT check_provodka.sh rc=0   rc=0
W --repo . --compat   : то же                                                            rc=0
red_ci_b_087.sh .     : ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)   rc=0
gen_ci_steps.sh --check                                                                  rc=0
check_provodka.sh . contracts/219-uchetnye-puti-ci-klass.md                              rc=0
verify_antiplacebo.sh --scope check_provodka check_ci_gate: барьеров: 2 · фикстур: 36 · предъявлено красным повторным прогоном: 36   rc=0

CI-step honest (bash -c <строка реестра>): KLETKI=35 ZELENYE=35 KRASNYE=0; SVJAZI=31 POIMANY=31 ZHIVYH=0   rc=0

CI-STEP: bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --repo . && bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --stabs
MUTANT v1-pauzy-any: W --repo . rc=1 KLETKI=35 ZELENYE=32 KRASNYE=3 red=['registry-add-uchet-with-data', 'registry-remove-uchet-with-data', 'registry-replace-uchet-with-data']
MUTANT v1-pauzy-any: CI-STEP rc=1 KLETKI=35 ZELENYE=32 KRASNYE=3
MUTANT mesto-add: W --repo . rc=0 KLETKI=35 ZELENYE=35 KRASNYE=0 red=[]
MUTANT mesto-add: CI-STEP rc=0 SVJAZI=31 POIMANY=31 ZHIVYH=0
MUTANT mesto-add: WITNESS add+registry/mesto-legacy.tsv -> (0, b'uchet\n', b'')
HONEST mesto-add: WITNESS add+registry/mesto-legacy.tsv -> (0, b'kod\n', b'')
MUTANT mesto-remove: W --repo . rc=0 KLETKI=35 ZELENYE=35 KRASNYE=0 red=[]
MUTANT mesto-remove: CI-STEP rc=0 SVJAZI=31 POIMANY=31 ZHIVYH=0
MUTANT mesto-remove: WITNESS remove+registry/mesto-legacy.tsv -> (0, b'uchet\n', b'')
HONEST mesto-remove: WITNESS remove+registry/mesto-legacy.tsv -> (0, b'kod\n', b'')
MUTANT mesto-replace: W --repo . rc=1 KLETKI=35 ZELENYE=34 KRASNYE=1 red=['registry-replace-uchet-with-data']
MUTANT lessons-add: W --repo . rc=0 KLETKI=35 ZELENYE=35 KRASNYE=0 red=[]
MUTANT lessons-add: CI-STEP rc=0 SVJAZI=31 POIMANY=31 ZHIVYH=0
MUTANT lessons-remove: W --repo . rc=0 KLETKI=35 ZELENYE=35 KRASNYE=0 red=[]
MUTANT lessons-remove: CI-STEP rc=0 SVJAZI=31 POIMANY=31 ZHIVYH=0
MUTANT lessons-replace: W --repo . rc=1 KLETKI=35 ZELENYE=34 KRASNYE=1 red=['registry-replace-uchet-with-data']
MUTANT pauzy-add|pauzy-remove|pauzy-replace|mesto-any|lessons-any: W --repo . rc=1, CI-STEP rc=1 (по одной красной клетке *-with-data)
HONEST <все 13>: WITNESS … -> (0, b'kod\n', b'')
RESTORED clean
087 на мутанте mesto-remove: ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)   rc=0

own1-reg-not-hashed: W --repo <mut> rc=1 KLETKI=35 ZELENYE=18 KRASNYE=17
own2-klass-U-new:    W --repo <mut> rc=0 KLETKI=35 ZELENYE=35 KRASNYE=0   (эквивалентный)
own3-mode-dropped:   W --repo <mut> rc=1 KLETKI=35 ZELENYE=20 KRASNYE=15
own4-basename-match: W --repo <mut> rc=1 KLETKI=35 ZELENYE=34 KRASNYE=1 red=['nested-pause']
own5-lessons-as-glob-dir: W --repo <mut> rc=1 KLETKI=35 ZELENYE=20 KRASNYE=15

реальное дерево OBJECT (tmp/clone-mut):
  data-only (pauzy+mesto+lessons): klass → uchet rc=0; vorota → учётный: H=e0c2b534a4550076e9ee125ad58ac21bd8666e950dd1b40fb2c356faf8b08a32 rc=0; hash равен rc=0
  joint (+uchet registry/new-example.tsv, mesto-legacy): klass → kod rc=0
```

Среда: все записи шли внутри копии (`$PWD/tmp/…`), `/tmp/dev-harness-verify` только читался. Клоны со своим `.git`. Перед докладом клоны и scratch удалены.
