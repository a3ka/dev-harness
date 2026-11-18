accept
OBJECT=bdf592e098eaaba9f14616e86751deb1eac2847b
СУД: repo=dev-harness; предмет=201; фаза=реализация frozen/contracts/201/1 (done-дверь, содержательная сверка); роль=reviewer; вызов=1 (полный; scoped ≤1 не потрачен); класс риска=рисковый (adversary-accept Adv201d, коммит c228a99ae2, тот же OBJECT); модель-план=config/agent_models.json reviewer → anthropic/claude-opus-5-5; сессия=Rev201; модель-факт=anthropic/claude-opus-5-5 allowed (`bash scripts/models_actual.sh --tsv --bind --session Rev201 | cut -f1-3` из /home/harness/dev-harness → `reviewer	anthropic/claude-opus-5-5	allowed` ×2, rc 0); запись СУД до вызова — state-HANDOFF c907157c/wip-011-orchestrator, строка «СУД (ДО ВЫЗОВА) 15:15» п.(2) (истинное время по строке «ПОПРАВКА ВРЕМЕНИ»).
СВЕРКА-АРХИТЕКТУРЫ: размещение — проверка в существующем писателе тега `scripts/done_contract.sh` (шаг 6б между 6а и клапаном 7; (г) внутри 187а), реестр `registry/mesto-legacy.tsv` рядом с каноном `registry/risk-legacy.tsv`; зависимости — прежние git/jq/curl/awk/mktemp, новых нет; писатель тега один (дверь), реестр дверь только читает (`git show HEAD:`); операции — только чтения Git и GitHub API, новый побочный эффект — временные файлы под EXIT-trap; `bindings.json`, `architecture.lock.json` и `tooling/checks/cli.js` в станции отсутствуют — модели архитектуры у предмета нет, diff модели L0, расхождения модели и работы нет, находка 188 не создавалась; долг не расширен.
СВЕРКА-СТАНДАРТОВ: AGENTS.md станции не объявляет документ архитектуры и стандарт кода (`grep -c 'ARCHITECTURE\|CODING' AGENTS.md` → 0) — неприменимо.
НАХОДКИ: `.review/2026-11-18-111.md` (status: ready) — блоков 0, советов 5 (С-1…С-5).

# Предмет и метод

Задание `/tmp/dev-harness-verify/task-rev201.md` прочитано первым действием. Клон судьи
`/tmp/dev-harness-verify/Rev201/repo` создан мной: `git clone --branch wip/201/implementer
ssh://git@github.com/a3ka/dev-harness.git`, `git fetch --tags origin`. HEAD =
`bdf592e098eaaba9f14616e86751deb1eac2847b` = OBJECT. Текст контракта на HEAD равен
замороженному: blob `9c7d34fa13a912955c2eaa74d964d933aadc630e` у `frozen/contracts/201/1`, у HEAD
и у `origin/main`. Тег заморозки `9ec69d537a` — предок OBJECT.

Опорные деревья своей меры — worktree этого клона:
- `wt-b4` — `b4d46ec66b`, доремонтная дверь;
- `wt-main` — `origin/main` `688a83a13f`;
- `wt-cf` — OBJECT, но `rezhim_996/probe.py` взят из `origin/main` (контрфактический прогон).

Исходник двери прочитан целиком по диффу `origin/main...OBJECT` и по окрестности шагов 5/187а.

# 1. Область правки и атомарность

`git log --format='%h %an|%cn' origin/main..bdf592e098` (author=committer у каждого):

```text
bdf592e0 implementer|implementer   scripts/done_contract.sh
860c7c21 implementer|implementer   scripts/done_contract.sh
ce2c54dd architect|architect       fixtures/…/done_dver_soderzhatelnaja_201/{SDACHA.md,dver_probe.py}
b4d46ec6 implementer|implementer   registry/mesto-legacy.tsv
4f051267 orchestrator|orchestrator merge -s ours: tree f3557c33 == tree a8649634 (сверено rev-parse ^{tree})
a8649634 implementer|implementer   scripts/done_contract.sh
bc599073 implementer|implementer   scripts/done_contract.sh
d3ae54ac implementer|implementer   registry/mesto-legacy.tsv scripts/done_contract.sh
e1916e9e architect|architect       fixtures/…/done_dver_soderzhatelnaja_201/{SDACHA.md,dver_probe.py}
5c7bb458 architect|architect       fixtures/…/done_dver_soderzhatelnaja_201/{SDACHA.md,dver_probe.py}
51e7f95c architect|architect       fixtures/workshop_project/rezhim_996/probe.py
1f0f8bee implementer|implementer   scripts/done_contract.sh
fd72a876 implementer|implementer   scripts/done_contract.sh
3ed2c21a implementer|implementer   registry/mesto-legacy.tsv scripts/done_contract.sh
```

Итог `git diff --stat origin/main...OBJECT` — 5 файлов:
- `scripts/done_contract.sh` +429 — зона implementer 201;
- `registry/mesto-legacy.tsv` +15 — зона implementer 201;
- SDACHA и `dver_probe.py` батареи 201 — зона architect 201;
- `rezhim_996/probe.py` — architect, вне зон текста 201.

Последний файл разрешён объединением замороженных зон: `frozen/contracts/996/{1,2}`:121 —
`ЗОНА architect: … fixtures/workshop_project/rezhim_996/`. Контрфактический прогон показал, что
правка обязательна (С-2), поэтому это не превышение, а необъявленное пересечение — совет.

Каждая задача — свой коммит со ссылкой на предмет. Implementer не трогал батарею, architect не
трогал дверь.

Барьер зон, полный прогон без кеша:

```text
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Rev201/zcache . 2>&1 | grep -vE '^  ok '
incr: check_zones полный прогон (кеш отсутствует)
процессных вне суда:
замороженных контрактов: 181 · объявленных авторов: 5 · коммитов в диапазонах: 64770 · проверено по зонам: 20844
rc=0
```

FAIL-строк нет. Прогон занял 1222 с; первая попытка упала по дедлайну 900 с, без вердикта
барьера. Своя мера другой командой — таблица «автор → файлы» выше против union замороженных зон:
ни одного пути вне зон автора.

# 2. Реализация против предмета и критериев (сверено чтением кода + клетками)

- **НЕ СЛАБИТЬ (инв. 0).** Шаги 1–6а, их фразы и порядок не изменены — диффом не тронуты.
  Ужесточения внутри прежних шагов исполняют арбитраж 2, РЕШЕНИЕ 2:
  - `project_paths_resolve` → `_json_one_object` с новым именованным `ОТКАЗ`;
  - 187а: рабочий профиль и ответ check-runs проходят полный разбор, curl rc≠0 больше не даёт
    засчитать stdout.

  Фраза ARCH_CI `успешного check-run arch на финальном SHA … нет (curl rc=…)` сохранена побайтно
  (сверено с `origin/main:scripts/done_contract.sh:250`). Клапан 7 и перечень версий не тронуты.
- **(а).**
  - vmax — максимум по `for-each-ref refs/tags/frozen/contracts/<NNN>/`; ошибка перечисления —
    именованный отказ.
  - OBJECT ищется anchored-шаблоном `^OBJECT=([0-9a-f]{40})$`, берётся первое совпадение.
  - Свежесть: `merge-base --is-ancestor F freshest_cid`.
  - F⊊CID → требуется F⊆OBJECT; F==CID → OBJECT⊆F плюс тождество деревьев.
  - Тождество: `diff-tree -r --raw --no-renames OBJECT F`; вычитаются только точные пути
    выбранного reviewer-файла и (для рискового) accept-файла адверсария; исполняется в конце 6б.
  - Все фразы отказов дословны по контракту.
- **(б).**
  - repoId берётся через `profile_resolver.sh --repo` и полный разбор; передача
    `HARNESS_PROJECT_LAYER_ROOT` — по прецеденту `check_project_sources.sh:64`.
  - Режим продукта: «отсутствует в репо продукта», «не предок HEAD».
  - Режим станции, место: `ПРОДУКТ:` из замороженного текста vmax, ровно одна строка, два
    замкнутых алфавита; иначе запись `mesto-legacy.tsv` по (NNN, blob vmax) из `git show HEAD:`;
    иначе fail-closed.
  - Станционное место требует локальный OBJECT; продукт требует нелокальный OBJECT, иначе отказ
    класса 163.
  - compare читается приёмом 187а.
- **Оба API-маршрута (п.2 задания).**
  - Тело ответа пишется в файл `_new_done_tmp`: `mktemp`, регистрация в `_DONE_TMP_FILES`,
    удаление `trap '_done_cleanup' EXIT` (:61).
  - `jq -s` читает сам файл (`_json_one_object <var> <file>`); `read -d ''` в механизме нет;
    stdin-вариант копирует вход `cat > file`.
  - EXIT-trap не перехватывается: `check_architecture_contract.sh` в режиме библиотеки
    возвращается на :802, до своего trap на :861.
- **Правдивые причины status.** jq-классификатор: `has("status") | not` → «без поля status»;
  string ∈ {identical, behind, ahead, diverged} — по словарю; всё прочее, включая присутствующие
  number/bool/array/null, → «неподдерживаемое значение status».
- **(в).**
  - Класс риска — грамматика zamok (`zamok_predmeta.sh:215`, тот же regex) по замороженному
    тексту. Расхождение значений даёт «неоднозначен». Нет строки — `risk-legacy.tsv` из
    `git show HEAD:`; нет записи — рисковый.
  - Адверсарий — тем же алгоритмом свежести, что у review: :649–669 сверено построчно с :217–240.
  - Четыре фразы отказов дословны.
- **(г).** Предикат `== "arch" or startswith("arch ") or startswith("arch (")`; не-строка через
  `// ""`; ошибка jq — 0 и ARCH_CI.
- **Миграция.** 14 строк реестра, по 5 полей (`awk -F'\t' '{print NF}'` → `15 5` с заголовком).
  Свой blob-замер `git rev-parse frozen/contracts/<n>/<v>:<путь>` совпал для всех 14:
  129/2, 132/2, 157/1, 186/2, 190/1, 109/6, 111/5, 117/5, 139/3, 141/3, 163/1, 991/3, 999/2, 201/1.
  Каждая версия — vmax своего предмета; `^ПРОДУКТ:` = 0 во всех. Место у каждой строки совпадает
  с таблицей §Миграция; 123 записи не имеет — как предписано. Основание строки 117 неточно — С-1.
- **Строка 201 (п.3 задания).** Без неё дверь откажет самому 201. Его замороженный текст несёт
  ровно одну строку класса `КЛАСС РИСКА: рисковый` и 0 строк `ПРОДУКТ:` (свой grep), значит место
  берётся только из реестра. Строка правдива: реализация — `scripts/done_contract.sh` станции,
  blob `9c7d34fa…` = blob заморозки. Она соответствует 201 §Миграция «Последующие строки
  реестра — … с основанием и автором в записи»: основание и автор (implementer) указаны.
  Семантика двери не меняется — это данные. Решение о маршруте — state-HANDOFF :27 («классификация
  места 201 — инженерный вопрос консультанта», Cons201c). Условие полноты, не новая семантика.

# 3. Батарея и регресс — своя мера (сырые итоги, cwd — корень клона)

```text
$ bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .
… 62 GREEN-строки клеток + GREEN karta-jq-vyzovov: механизм _json_one_object × 5 …
CELLS=62 STABS=0 FAILURES=0                                  rc=0
$ … red_done_dver_201.sh --model   → CELLS=62 STABS=0 FAILURES=0   rc=0
$ … red_done_dver_201.sh --stabs   → CELLS=62 STABS=27 FAILURES=0  rc=0; `grep -c 'caught @'` → 27
$ python3 (импорт dver_probe.py) → CASES 62 STABS 27        # счёт другой мерой, не выводом раннера
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . → CELLS=54 STABS=0 FAILURES=0 rc=0
$ … --model → CELLS=54 STABS=0 FAILURES=0 rc=0 ; … --stabs → CELLS=54 STABS=56 FAILURES=0 rc=0
$ PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/rezhim_996/probe.py --matrix
mutation broken-profile-fallback: freeze-broken-profile: rc=0
996: examined=111 mutants=76 mismatches=1                    rc=1
  — то же на wt-b4 (b4d46ec66b) и на wt-main (origin/main): та же единственная строка, те же числа
$ bash fixtures/workshop_project/rezhim_996/probe.sh (живая дверь)   → 996: examined=111 mutants=0 mismatches=0 rc=0
$ wt-cf: тот же probe.sh, probe.py из origin/main против двери OBJECT → examined=111 mismatches=8 rc=1
  (done-profile, station-isolation, canon-done-green, done-escalate, done-ungrammatical,
   done-gate-preserved, done-consumers-preserved, done-committed-preserved — «нет заморозки…»/«без строки OBJECT=»)
$ bash -n scripts/done_contract.sh → rc 0 ; bash scripts/gen_ci_steps.sh --check → rc 0
```

**Красное предъявлено (своим прогоном).** Батарея OBJECT против доремонтной двери:
`red_done_dver_201.sh --repo /tmp/dev-harness-verify/Rev201/wt-b4` → `CELLS=62 STABS=0
FAILURES=5`, rc 1. Красны ровно пять клеток:
- `b-vneshnij-nul-hvost`, `b-vneshnij-nul-v-znachenii`, `b-vneshnij-nul-v-klyuche` и
  `g-arch-nul-hvost` — rc 0 вместо 1, ложный done, `line 539/295: warning: command substitution:
  ignored null byte`;
- `b-vneshnij-status-chislo` — ложная фраза «без поля status».

Карта на доремонтной двери GREEN: механизм был и до ремонта.

**Проверки не подогнаны под код.**
- Implementer батарею не трогал (таблица §1).
- Батарея круга `ce2c54dd` (13:02) коммитом предшествует ремонту `860c7c21`/`bdf592e0`
  (13:40/13:50).
- `git diff b4d46ec6 ce2c54dd -- dver_probe.py` удаляет только 5 строк: 2 строки комментария,
  `checkrun_file.write_text(cr)` и два вызова `json_one_object(body)` (переход модели на сырые
  байты). Кортежи ожиданий старых клеток не удалены и не изменены.
- Остаток 996 — до и после один и тот же (`broken-profile-fallback`, не «skip-committed» — С-3).

# 4. Доказательства судов

- Adv201 (`verdicts/adversary/contracts-201-impl-v1.md`, в main) — FAIL.
- Adv201b — текст утерян, известен по арбитражу 2 §Замер п.3.
- Adv201c (`archive/201/adv201c-verdict-dcb26084b4`) — FAIL, два блока.
- Adv201d (`archive/201/adv201d-verdict` = `c228a99ae2`, родитель — OBJECT): `accept` и
  `OBJECT=bdf592e0…`, author=committer=adversary.

Арбитраж 2, РЕШЕНИЯ 1–3, исполнен:
- полный разбор ровно одного документа (`jq -s`, `length == 1`, тип-объект);
- пять вызовов механизма — карта GREEN;
- профильные клетки `g-profil-*` зелены, положительные whitespace-контроли зелены.

Cons201c, §Минимальный дельта-текст, исполнен:
- NUL теперь проходит через файл в jq;
- `read -d ''` устранён;
- числовой status получает правдивую причину;
- реестр и заморозка не тронуты ремонтом.

Блоки Adv201c закрыты моими собственными прогонами клеток (§3), не пересказом Adv201d.

# 5. Паразитная сложность (контракт 050)

- `_json_one_object` (функция; интерфейс: имя переменной и необязательный файл; rc 0/1 и `_JSON_ERR`):
  1. свойство — арбитраж 2 «ровно один JSON-документ» и Cons201c «байты до jq без потерь»;
  2. состояние — переменная-результат и `_JSON_ERR` явны в вызове, временный файл вычищает trap;
  3. совместных правок — 1 файл, число не выросло;
  4. глубина — 2 аргумента против разбора, диагностики и копирования stdin, модуль глубокий;
  5. потребители — 5 вызовов, карта `karta-jq-vyzovov` батареи.

  ESSENTIAL: проще без потери NUL нельзя — `$(curl)` терял байты, клетки nul-*.
- `_new_done_tmp`/`_done_cleanup`/EXIT-trap (функции; новых env не читают, кроме `TMPDIR`):
  1. свойство — Cons201c «временные ресурсы удалять на всех выходах»;
  2. состояние — массив `_DONE_TMP_FILES`, явен;
  3. совместных правок — 1 файл;
  4. глубина — 0 аргументов;
  5. потребители — оба API-маршрута и stdin-разбор.

  ESSENTIAL. Неполнота с голым `_a187_txt` — С-5.
- Шаг 6б (ветви барьера (а)/(б)/(в)/(а²); новый env — только `HARNESS_PROJECT_LAYER_ROOT`,
  проброшенный по прецеденту):
  1. свойство — инварианты 1–3 контракта;
  2. состояние — только локальные переменные, отказы — именованным stderr и rc 1;
  3. совместных правок — 1 файл;
  4. интерфейс двери не вырос (аргументы те же);
  5. потребитель — батарея 201 (62 клетки), шаг CI `check:done-dver-201-family-selftest`.

  ESSENTIAL.
- `registry/mesto-legacy.tsv` (файл состояния):
  1. свойство — РЕШЕНИЕ 2 арбитража 1, §Миграция;
  2. состояние явное, blob-привязанное, читается только с HEAD;
  3. совместных правок — 1;
  4. колонки по канону risk-legacy;
  5. потребители — дверь и клетки `b-legacy-*`.

  ESSENTIAL.
- Семья батареи 201 (`dver_probe.py`, CASES/STABS, SDACHA; один артефакт):
  1. свойство — §Красная батарея и РЕШЕНИЕ 3;
  2. состояние — одноразовые миры, ожидания в памяти раннера;
  3. совместных правок — 2 файла семьи;
  4. интерфейс прежний (`--repo/--model/--stabs`), новых флагов нет;
  5. потребитель — строка приёмки и шаг CI; грамматику двери не дублирует (модель — канон `jq -s`).

  ESSENTIAL.
- `done_freeze_equip` в `rezhim_996/probe.py` (функция фикстуры):
  1. свойство — приёмка 201 «996 не хуже базлайна» и живой шаг CI 996;
  2. состояние — тег и OBJECT в одноразовом мире, явны;
  3. совместных правок — 1 файл;
  4. 3 аргумента против дооснащения мира;
  5. потребитель — живой `probe.sh` (CI).

  ESSENTIAL: без неё 8 живых красных (wt-cf).

# 6. Остаток контракта (контракт 192)

Строк остатка с идентификатором `К-NN` в НЕ ЗАЩИЩАЕТ замороженного текста нет. Строки
НЕ ЗАЩИЩАЕТ с ловцом reviewer пронумерованы по порядку как НЗ-n:

ОСТАТОК: НЗ-1 (эра внешнего SHA) — не укусил: OBJECT 201 станционный, в диффе внешних OBJECT нет.
ОСТАТОК: НЗ-2 (семантика вердикта; правдивость СВЕРКА-АРХИТЕКТУРЫ) — не укусил: судимый OBJECT — весь предмет, не этап (§2 сверка по каждому инварианту).
ОСТАТОК: НЗ-7 (Git-достижимость ≠ полнота) — не укусил: полнота сверена по инвариантам 0–4, §Миграция и приёмке (§2–§3).
ОСТАТОК: НЗ-8 (правдивость места и legacy-записей) — не укусил: 14 blob и 14 мест сверены своей мерой; неточное `основание` строки 117 (`registry/mesto-legacy.tsv:9`) место не меняет — С-1.
ОСТАТОК: НЗ-9 (семантика внешнего продуктового SHA) — не укусил: внешних OBJECT у 201 нет.

# 7. Готовность к приземлению (без разбора вины)

- **Носитель.** Нужны реализация и батарея — это OBJECT, вердикт Adv201d (`c228a99ae2`,
  потомок OBJECT) и этот вердикт reviewer.
- **Шаг CI 201** уже в main:
  - `registry/ci-steps.tsv:317 check:done-dver-201-family-selftest … red_done_dver_201.sh --stabs`;
  - `ci-zamery.tsv:119`;
  - ключ в lane `ci.yml:282`;
  - `gen_ci_steps.sh --check` rc 0.

  Шаг гоняет только `--stabs` (модель), живая дверь в CI не идёт — зона orchestrator, к сведению.
- **`ci_preflight.sh`** красен одинаково до и после 201. На OBJECT и на `origin/main` —
  `preflight ОТКАЗ: shag-upal: klass/step (rc=1): bash: line 1: : No such file or directory`,
  rc 1 байт в байт. Предсуществующий.
- **Ветка отстаёт от main.** merge-base `7aff2d7c` ≠ `origin/main` `688a83a1`, нужна
  интеграция.
  - Слияние обязано сохранить `bdf592e0` предком: без rebase и squash. [INFERENCE по коду
    `scripts/done_contract.sh:455–456` и :574] Иначе свежий клон не разрешит OBJECT, и дверь 201
    откажет «вне репо станции».
- **Вердикты адверсария.** [INFERENCE по коду выбора свежего `scripts/done_contract.sh:649–669` и
  своему замеру ancestry] `impl-v1` (`62029bc5`) — предок `c228a99ae2`, безопасен. Если вместе с
  ним приземлить `impl-v3` из `dcb26084b4` (родитель `b4d46ec66b`), то `merge-base --is-ancestor
  dcb26084b4 c228a99ae2` → нет. Дверь оставит свежим v3 (FAIL) и откажет «свежий вердикт
  адверсария … не accept». Поэтому v3 либо не приземлять, либо приземлять так, чтобы его коммит
  был предком коммита v4.

# Развилки

- Правка `rezhim_996/probe.py` вне ЗОНА-строк текста 201 — совет С-2, не отказ «превышение».
  Union замороженных зон её разрешает (норма `check_zones.sh`, «зона автора — объединение»), барьер
  зон rc 0. Контрфактический прогон доказал необходимость (8 живых красных без неё). Строка
  приёмки 996 (`--matrix`, модель) этой поломки не видит — С-4.
- Строка 201 в `mesto-legacy.tsv` выходит за 13 строк таблицы §Миграция. Она принята как данные
  полноты по формуле «последующие строки — с основанием и автором» и по решению маршрута
  (HANDOFF :27, Cons201c). Отдельный «предмет классификации» ради одной правдивой строки
  не потребован.
- `.review`-номер 111 выбран после 110, занятого на одной из удалённых веток; `finding new`
  (188) неприменим — `tooling/checks/cli.js` в станции нет.

# Среда

- pwd прогонов — `/tmp/dev-harness-verify/Rev201/repo` (ssh-origin, свой `.git`), HEAD до
  коммита вердикта = OBJECT.
- Worktree `wt-b4`, `wt-main` и `wt-cf` — только для своей меры, вне коммита.
- Вердикт и файл находок — один коммит, author=committer=reviewer.
- push не выполнялся, тег done не ставился, identity owner не использовалась.
