accept
OBJECT=097f72a77501ded0b574182a7dcb7cbd31b4ad1e
СУД: репо=dev-harness; предмет=227; фаза=реализация; роль=reviewer; вызов=2 (scoped; по дельте Architect227c + CI); сессия=Rev227b; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl227 — implementer (MiniMax), Architect227/227b/227c; предыдущий=archive/227/reviewer-v1-fail-2392d2a1f3

# Reviewer 227 — Ш-5ф: отчёт об остатке зашивок проектов в ядре, реализация, вызов 2

**БЛОКИРУЕТ: нет**

**СОВЕТЫ: нет** — нового файла `.review/` нет, чинить нечего.

Находки вызова 1 (`2392d2a1f3:.review/2026-11-26-2271.md`, `status: ready`) закрыты:

- **Б-1 — ЗАКРЫТ.** Мутант R9 повторён дословно, теперь он КРАСНЫЙ (`KLETKI 37 KRASNYH 8`). Ещё 5 мутантов «glob vs literal» не из `stabs.tsv` тоже красные. Честный контроль зелёный.
- **С-1 — ЗАКРЫТ.** CI-selftest гонит `--sintaksis` с пином shellcheck 0.11.0 в той же форме, что у 215. `gen_ci_steps --check` rc 0.

Вызов scoped: проверена только дельта к OBJECT вызова 1 `ce363c746`. Выводы вызова 1 о production сохраняются (см. «Остатки»): production побайтно не изменилась.

## Область правки

`git log --format='%h %an | %cn | %s' 283bbeae4..097f72a77`:

```
097f72a77 orchestrator | orchestrator | orchestrator: 227 selftest с --sintaksis (пин shellcheck 0.11.0 в lane, как 215; совет С-1 Rev227)
00f91ab32 architect | orchestrator | 227: проверять glob соседей include полными путями файлов
754a21a11 architect | orchestrator | 227: различать literal и glob пути, закрыть Б-1 Rev227
2e6e1bb47 orchestrator | orchestrator | orchestrator: 227 CI report-step report:zashivki-227 + selftest check:zashivki-otchet-227-family-selftest
a32d26b93 implementer | orchestrator | 227: отчёт об остатке зашивок — scripts/report_zashivki.sh + config/zashivki.json
```

Дельта `git diff --stat ce363c746 097f72a77`: 24 файла, +343 −16.

- **Architect.** `754a21a11` — 21 файл, +334 −7; `00f91ab32` — только `probe.py`, +3 −3. Все пути внутри `fixtures/workshop_project/zashivki_otchet_227/`, это `ЗОНА architect` контракта.
- **Orchestrator.** `097f72a77` меняет ровно тройку `ЗОНА orchestrator`: `ci.yml` 14 строк, `ci-steps.tsv` ±1, `ci-zamery.tsv` ±1.
- **Атомарность.** Каждая задача — свой коммит со ссылкой на 227 или Rev227.
- **Production не менялась.** `git diff --stat 140dea188 097f72a77 -- scripts/report_zashivki.sh config/zashivki.json` пуст (rc 0). `cmp config/zashivki.json …/model/config/zashivki.json` rc 0.
- **Контракт, роли, AGENTS.md и вердикты не менялись.** `git diff --stat d60966ce6 097f72a77 -- contracts roles AGENTS.md verdicts` пуст. `merge-base --is-ancestor d60966ce6 HEAD` rc 0: заморозка `frozen/contracts/227/1` — предок.
- **`ci.yml` — только генерируемая секция.** `git diff -U0` даёт 7 хунков в строках 272–284, все внутри `# BEGIN/END GENERATED CI JOBS (083)` (строки 270/285). Своя мера: отсортированный набор ключей из строк `keys:` у `ce363c746` и у OBJECT дал одинаковый md5 (`75b806539e…`) и 184 токена в обоих. Ключи не потеряны и не добавлены, вес 200→240 только перераспределил их по lane.

## Проверки не переписаны под код

- Батарею после реализации менял только architect, по блоку Б-1 вызова 1. Implementer и orchestrator семью не трогали.
- Изменения только добавляют. `git diff --numstat ce363c746 097f72a77`:
  - `probe.py` — 16/0, `build.py` — 15/0, все `stabs/s33…s35`, `e05` и `replay_reviewer.py` — новые файлы.
  - `source.json` — 65/1. Единственная «удалённая» строка — та же хэш-строка `e04…/ci-zamery.tsv`, к ней добавлена запятая.
  - `SDACHA.md` — 16/6: шапка и лист прогона.
  - Клетки `literal-paths` и `literal-excludes` вызова 1 на месте и зелёные.
- Оракул новых клеток — литеральные записи в `probe.py:cases()`, снимаются до субъекта. Они выражают семантику инв. 2 (literal, «не shell/regex/glob») на конформном входе: контракт :57 разрешает метасимволы в literal-путях. Вывод production в них не используется.
- Стабы к ветвям привязаны в `build.py` (`MUTATIONS`/`EQUIVALENTS`), а не прозой контракта (Н-39):
  - s33 снимает literal с обеих сторон, s34 — только с include, s35 — только с exclude.
  - e05 добавляет `top`: честный эквивалент, форма production.

## Регресс

Прогоны шли в чистом клоне с origin: `git clone ssh://git@github.com/a3ka/dev-harness.git --branch wip/227/orchestrator-i3` → `tmp/c227b`, HEAD `097f72a77501ded0b574182a7dcb7cbd31b4ad1e`. Окружение: `TMPDIR=$PWD/tmp/scratch-rev227b`, `VALIDATE_STD_SHELLCHECK` — пин 0.11.0. Всё последовательно, без параллельных мутантов. `W=bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh`.

| Команда | rc | Сырой итог |
|---|---|---|
| `W --repo .` | 0 | все 37 клеток GREEN, включая 8 новых `literal-{include,exclude}-{star,question,bracket,backslash}`; `KLETKI 37 KRASNYH 0` (2.6 с) |
| `W --model` | 0 | `KLETKI 37 KRASNYH 0` |
| `W --stabs` | 0 | `STABY 35 EKVIVALENTY 5 ZHIVYH 0`; s33 красит 8 новых клеток, s34 — 4 include, s35 — 4 exclude, все `REPORT_CONTENT` |
| `W --sintaksis` | 0 | `SINTAKSIS_OK` |
| `W --catalog` | 0 | `KLETKI 37 STABY 35 EKVIVALENTY 5 SVJAZI 64` |
| `python3 -B …/context.py` | 0 | последние строки — `ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv …`, `…/ci-zamery.tsv …` |
| `bash scripts/report_zashivki.sh` | 0 | `lines 89 files 20 matches 89 baseline {'lines': 89, 'files': 20, 'commit': '6565542c1'}`; среди путей нет ни `scripts/report_zashivki.sh`, ни `config/zashivki.json` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `fixtures/…/replay_reviewer.py` | 0 | `KLETKI 37 KRASNYH 8` (воспроизведение R9 автором) |
| `bash scripts/check_provodka.sh . contracts/227-sh5f-zashivki-otchet.md` | 0 | — |
| `bash scripts/check_sdacha.sh . contracts/227-sh5f-zashivki-otchet.md --run` | 0 | `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)`, 122.7 с |
| `bash scripts/pre_critic.sh contracts/227-sh5f-zashivki-otchet.md` (после sdacha, по одному) | 0 | все строки `ok`, включая `сдаточный лист красен`; `КРИТИК: дверь зелёная`, 158.1 с |

После всех прогонов `git status --short` клона пуст (0 строк).

Счёт проверен своей мерой, другой командой, не `--catalog`:

- `find stabs -mindepth 1 -maxdepth 1 -name 's*' -type d | wc -l` = **35**, то же для `'e*'` = **5**.
- По `source.json` `links`: 40 носителей, сумма `len(cells)` = **64** (red 50, green 14). Новые связи: s33 — 8, s34 — 4, s35 — 4, e05 — 8, всего 24. 40 + 24 = 64, сходится с заявленным 40→64.
- Клеток 29 + 8 новых = **37** — 37 строк `GREEN` в выводе `--repo`.
- Независимый `git grep` по pattern из конфига (`-- scripts .omp/extensions .githooks ':(exclude)scripts/proxy'`): `-n … | wc -l` = **89**, `-l … | wc -l` = **20**.

## Свои мутанты и дефекты честной production

Одноразовый клон `tmp/m227b` с HEAD `097f72a77`. Правит его `tmp/scratch-rev227b/mutate.py`: на каждый якорь ровно одно вхождение, `bash -n` rc 0, после каждого мутанта `restored: clean`. Батарея — неизменённая, из `tmp/c227b`: `W --repo tmp/m227b`, мутанты по одному.

| Мутант | Правка `scripts/report_zashivki.sh:107–108` | `W --repo` | Красные клетки |
|---|---|---|---|
| **R9 (дословно вызов 1)** | `':(top,literal)'`→`':(top)'`, `':(exclude,top,literal)'`→`':(exclude,top)'` | **rc 1, KRASNYH 8** | все 8: `literal-include-{star,question,bracket,backslash}`, `literal-exclude-{question,star,bracket,backslash}`, `REPORT_CONTENT` |
| G1 явный glob | `:(top,glob)`, `:(exclude,top,glob)` | rc 1, KRASNYH 7 | все новые, кроме `literal-include-star`: с glob-магией `*` не пересекает `/`, поэтому `ext*` не захватывает `extras/a.sh`; остальные 7 ловят |
| G2 только include | `:(top)` на include | rc 1, KRASNYH 4 | ровно 4 `literal-include-*` |
| G3 только exclude | `:(exclude,top)` на exclude | rc 1, KRASNYH 4 | ровно 4 `literal-exclude-*` |
| G4 снят `top`, голые пути | `item` и `':!' + item` | rc 1, KRASNYH 8 | все 8 |
| G5 icase вместо literal | `:(top,icase)`, `:(exclude,top,icase)` | rc 1, KRASNYH 8 | все 8 |
| **Честный контроль** | снят только `top`: `:(literal)`, `:(exclude,literal)`; cwd = корень, форма модели | **rc 0, KRASNYH 0** | — |

Ни один мутант не взят из `stabs.tsv`/`MUTATIONS`. G1 (магия `glob`), G4 (`':!'` и голый путь) и G5 (`icase`) — формы, которых в `build.py` нет. G2/G3 направлены так же, как s34/s35, но применены к production-якорям `top,literal`, а не к модели. Адресность подтверждена: снятие literal на одной стороне красит ровно клетки этой стороны. Честная форма без `top` (= e05 наоборот) зелёная, значит барьер не красит эквивалент.

Дефектов честной production на новых входах нет: на OBJECT все 8 новых клеток зелёные.

## Остатки

Выводы вызова 1 о production сохраняются. Их предмет — `scripts/report_zashivki.sh` и `config/zashivki.json` — побайтно равен `140dea188`, так что новые файлы дельты их не переписывают.

- **Проверено, не переписано:**
  - Область вызова 1: тройка CI + 2 файла implementer.
  - «Отказ ≠ ложный ноль»: (а)–(г), каждый отказ — rc 2/`NOT_IMPLEMENTED`, stdout пуст. Стаб R8 (`git-failure`) в `--stabs` по-прежнему ловится: `MEASUREMENT_ERROR_RC`.
  - «Не дверь»: строка `step	report:zashivki-227	10	bash scripts/report_zashivki.sh` (`ci-steps.tsv:339`) не изменилась, без `|| true` и порога.
  - R-0102: `git grep -c -E 'Complior|a3ka|\.harness|scripts/proxy' -- scripts/report_zashivki.sh` → rc 1, 0 совпадений.
- **ОСТАТОК: НЗ-1** «от наличия зашивок или немонотонного долга» (ловец reviewer) — не укусил. Отчёт 89/20 = база, rc 0. Порога и отказа в дельте нет.
- **ОСТАТОК: НЗ-2** «семантические зашивки вне configured ERE/области или изменение конфига ради сокрытия долга» (ловец reviewer полного diff/config) — не укусил. Конфиг побайтно равен канону модели, дельта его не трогает.
- **ОСТАТОК: НЗ-3** «компрометация Git/PATH/установки» — не укусил. Production не менялась.
- **ОСТАТОК: НЗ-4** «неконформный JSON/ERE, не-UTF-8, отказ FS/инструмента» (ловец оператор/CI) — не укусил. Клетки `invalid-config`/`unreadable-config`/`git-failure` зелёные, их стабы ловятся.

## Норма 050 (паразитная сложность)

- **Клетки `literal-{include,exclude}-{star,question,bracket,backslash}` (семья входов, одним артефактом):**
  - (1) инв. 2 и Б-1;
  - (2) состояния нет, это литеральные записи;
  - (3) одно место — `probe.py:cases()`;
  - (4) н/п;
  - (5) потребители — `--repo`/`--model`/`--stabs` в CI selftest.
  - ESSENTIAL. Более простая форма (одна общая клетка) не адресует include и exclude раздельно, и G2/G3 не различались бы.
- **Стабы s33/s34/s35, эквивалент e05 (одной семьёй):**
  - (1) К-08, Н-39;
  - (2) состояние — генерируемые носители, хэши в `source.json`;
  - (3) `build.py` → регенерация. Совместно меняемых мест не прибавилось: та же грамматика `MUTATIONS`;
  - (4) н/п;
  - (5) потребитель — `--stabs` в CI.
  - ESSENTIAL.
- **`replay_reviewer.py` (новый, 46 строк):**
  - (1) лист сдачи, строка дельты К-08: воспроизвести R9 на production, а не на модели;
  - (2) состояние — временный клон в `tmp/scratch-arch227c` (gitignored), удаляется `TemporaryDirectory`;
  - (3) 1 файл;
  - (4) интерфейс — 0 аргументов, rc 0/1/2;
  - (5) потребитель — `check_sdacha --run` (двери=14). Повторяет устройство существующего `replay_critic.py` (`scratch-arch227b`) — это конвенция семьи, второй конвенции не заводит.
  - ESSENTIAL.
- **Строка CI selftest (`ci-steps.tsv`) + вес 200→240 (`ci-zamery.tsv`), генерируемый `ci.yml`:**
  - (1) ПРЕДПОСЫЛКИ, правило формы и С-1;
  - (2) состояния нет — `mktemp -d` в runner;
  - (3) тройка 083/114, без роста;
  - (4) н/п;
  - (5) потребитель — CI. Грамматика буквально повторяет шаг 215 (`curl … shellcheck-v0.11.0 … VALIDATE_STD_SHELLCHECK=… --sintaksis`): существующая форма, не новая.
  - ESSENTIAL.

## Сверки

- **СВЕРКА-АРХИТЕКТУРЫ: н/п.** Контракт: «АРХИТЕКТУРА: н/п — станционный отчёт без продуктовой модели 188». В дельте нет `bindings.json`, писателей, операций или диффа модели. Долг не расширен: 89/20 = база.
- **СВЕРКА-СТАНДАРТОВ: н/п.** `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` — вывод вызова 1, дельта `AGENTS.md` не трогает. `W --sintaksis` rc 0 на пинованном shellcheck.
- **Режим проекта 996:** sourceCanon не объявлен, сверка карты н/п. Мобильного экрана нет.
- **ПРОВОДКА (038):** guard `red_zashivki_otchet_227.sh` подключён шагом `check:zashivki-otchet-227-family-selftest`, теперь с `--repo . && --model && --stabs && --catalog && … --sintaksis`. `check_provodka` rc 0. Guard — барьер именно этого предмета.
- **Класс риска «обычный»** подтверждён. Дельта — только батарея и CI-проводка, production read-only и не менялась.
