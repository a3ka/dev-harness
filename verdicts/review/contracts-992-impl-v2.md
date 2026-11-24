accept
OBJECT=b506b2b95afc21484af3ed8731d16e1ad7a43fe8
СУД: репо=dev-harness; предмет=992; роль=reviewer; вызов=узкий (слово владельца В2); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии Rev992); предыдущий=verdicts/review/contracts-992-impl-v1.md (accept на 1e15de5d); класс риска=рисковый
НАХОДКИ: .review/2026-11-24-157.md — блоков 0, советов 2 (С-1, С-2)
АДВЕРСАРИЙ НА ЭТОМ OBJECT: verdicts/adversary/contracts-992-v3.md, accept, коммит 9233d452052bbe244c010a5636d17c3e6c3557db (ветка wip/992/adversary-v3). Порядок соблюдён: adversary → reviewer.

Суд узкий: проверены дельта клетки `C-charter-fast-log` и форма вердикта. Реализация 992 принята в v1, её заново не судил. Все прогоны выполнены в моей копии на HEAD = OBJECT, `TMPDIR=/tmp/dev-harness-verify/scratch-rev992`. Мутации делались только в одноразовом клоне с собственным `.git`.

## Область

- **Состав OBJECT.** `git rev-list --parents -n1 b506b2b95` → родитель один, `4576309b967a22818cd7c2ed0738333dd014ca80` (main).
  - Автор коммита — `implementer <implementer@dev-harness.local>`, коммиттер — orchestrator.
  - Patch-id совпадает с `eaf4ce5ff6f1a8ea3326ef4d22ecd2343e0359cd`: `276ab6437b86f297c6e8ee4ab76fb9863f79f3f4` у обоих, родитель тот же. Это тот же коммит implementer с перезаписанным коммиттером.
- **Что изменил implementer.** `git diff --stat 4576309b9 b506b2b95` → `fixtures/freeze_contract/fail_closed_992.py | 31 ++++++++++++++++++++++++++++-`, `1 file changed, 30 insertions(+), 1 deletion(-)`. Других путей нет.
- **Вычет дельты main.**
  - `git diff --stat 1e15de5d 4576309b9` → 412 файлов.
  - `git diff --stat 1e15de5d b506b2b95` → 413 файлов.
  - Разница в один путь — `fixtures/freeze_contract/fail_closed_992.py`. `git diff --name-only 1e15de5d 4576309b9 -- fixtures/freeze_contract/` пуст (rc 0), то есть main эту фикстуру не трогал.
- **Зона.** `fixtures/freeze_contract/` входит в зону implementer (frozen/contracts/992/2). Правка сделана по слову владельца В2, это исправление по находке.
- **Критерий не сменён.** Прочитал `git diff 4576309b9 b506b2b95 -- fixtures/freeze_contract/fail_closed_992.py` построчно.
  - Добавлены абзац докстринга, словарь `NA_PARENT_A` с одной клеткой (стр. 98-109), счётчики `observations`/`not_applicable` (стр. 310-311) и ветвь N/A (стр. 325-332), а также `observations += 1` в общей ветви (стр. 340). Строка итога теперь печатает фактический счёт (стр. 347).
  - Таблица `CASES` не тронута: регексы, оракулы, условия шимов прежние. Предикаты `expected` и `good` тоже прежние.
  - N/A ставится только при трёх условиях одновременно: `label == 'parent-A'` (такая метка есть только в `--matrix`), клетка лежит в `NA_PARENT_A` (там одна `C-charter-fast-log`), и `not hit`, то есть сбой не доставлен.
- **Атомарность.** Одна задача — один коммит с предметом в заголовке (`impl 992: клетка C-charter-fast-log на parent-A — N/A с причиной …`).
- **Норма не тронута.** `contracts/`, `roles/` и нормативные документы в дельте отсутствуют.

## Проверки

Ниже сырые коды возврата, каждая команда запускалась отдельно.

1. **Не предок.** `git merge-base --is-ancestor 80f610153 3e071370^` → **rc 1**. Значит, `80f610153` (2026-10-20, `impl 113: fast mode + --oracle`) НЕ предок parent-A (`3e071370^` = `95d8b5c945e42a538d50ea2d0d4436e4495e8e12`).
2. **Строки отказа нет.** `git show 3e071370^:scripts/check_charter.sh | grep -n 'история не читается'` → **rc 1**, совпадений 0.
3. **Нет `git log --name-only`.** В `git show 3e071370^:scripts/check_charter.sh | grep -n -- '--name-only'` всего три совпадения, все не `log`: `diff-tree` на стр. 261 и 263, `ls-tree` на стр. 443.
   - Единственный `git log` в файле — `g log -1 --format=%B "$c"` на стр. 346 (тело коммита). Шим клетки срабатывает по условию `'log' in a and '--name-only' in a` (фикстура, стр. 192), и этот вызов под него не подпадает.
   - Обход истории в parent-A идёт через `g rev-list "$since..HEAD"` на стр. 482 и `diff-tree`.
   - Итог: причина N/A подтверждена кодом. На OBJECT ветвь есть: `scripts/check_charter.sh:897` содержит `bad "история не читается (git log rc=$__ch_lr) …`.
4. **Матрица.** `python3 fixtures/freeze_contract/fail_closed_992.py --matrix` → **rc 1**, итог `cases=25 observations=74 failures=17 not_applicable=1`.
   - Строка клетки: `C-charter-fast-log parent-A: N/A (…)`, `измерение: сбой не доставлен (hit=0, control_rc=0, fault_rc=0)`.
   - Строки `accepted=0` пересчитал своей мерой (grep по выводу): ровно 17, и все с меткой `current`. Это B-charter-diff, C-charter-fast-log, B-charter-tree, B-preflight-package, B-preflight-worktrees, B-preflight-tags, B-judge-policy-seq, B-judge-verdict-seq, B-profile-defaults, B-profile-keys, B-profile-object, B-profile-strings, B-profile-array, B-freeze-versions, B-done-versions, B-ci-ok-write, B-ci-fail-write. Итого 16 B-current и 1 C-current.
5. **Набор провалов прежний.** В одноразовом клоне подставил фикстуру из `4576309b9` (до правки) и прогнал `--matrix` → **rc 1**, `cases=25 observations=75 failures=18`.
   - Это те же 17 строк `current` плюс `C-charter-fast-log parent-A: control_rc=0 fault_rc=0 oracle=0 hit=0 accepted=0`.
   - Правка убрала ровно эту одну строку. Ни одна другая не стала зелёной и не пропала: 75 − 1 = 74 наблюдения, 18 − 1 = 17 провалов.
6. **Режим `--model`.** `python3 fixtures/freeze_contract/fail_closed_992.py --model` → **rc 0**, `cases=25 observations=25 failures=0 not_applicable=0`.
7. **Без флагов.** `python3 fixtures/freeze_contract/fail_closed_992.py` → **rc 0**, `cases=25 observations=25 failures=0 not_applicable=0`.
8. **Список клеток.** `python3 fixtures/freeze_contract/fail_closed_992.py --list | wc -l` → `25`, PIPESTATUS `0 0`. Компиляция: `python3 -m py_compile fixtures/freeze_contract/fail_closed_992.py` (кэш вынесен в scratch) → **rc 0**.
9. **Doc-цепочка.** `bash fixtures/freeze_contract/red_doc_lifecycle.sh` → **rc 0**: `cases=25 observations=25 failures=0 not_applicable=0`, затем `cases=54 observations=54 failures=0`, затем doc-проба. `bash -n fixtures/freeze_contract/red_doc_lifecycle.sh` → rc 0.
10. **Собственные мутации.** Клон `/tmp/dev-harness-verify/scratch-rev992/clone` (собственный `.git`, HEAD = OBJECT). Каждая мутация накладывалась через `git apply --unidiff-zero` и откатывалась `git checkout`. Прогон для всех: `--matrix --case C-charter-fast-log`.
    - R0, база: **rc 1**, `cases=1 observations=2 failures=1 not_applicable=1`. parent-A N/A, current `accepted=0`, model `accepted=1`.
    - M1, убрано условие `and not hit` (стр. 326): **rc 1**, `observations=2 failures=1 not_applicable=1`, вывод совпадает с R0. Мутант эквивалентен на реальных данных, потому что на parent-A hit=0 и так. Строка current не маскируется: её держит ещё и `label == 'parent-A'`.
    - M2, метка расширена (`na = NA_PARENT_A.get(case)` для любой метки), `not hit` оставлен: **rc 1**, `observations=2 failures=1 not_applicable=1`. current и model по-прежнему наблюдаются (hit=1), current красный. Одно условие hit не даёт замаскировать current.
    - M3, метка расширена и `not hit` убран: **rc 0**, `cases=1 observations=0 failures=0 not_applicable=3`. Красная строка current исчезла, current и model ушли в N/A. Это и есть маскировка провала. Пара M2→M3 — красное для условия hit: rc 1 → 0, failures 1 → 0.
    - M4, на parent-A подан код с ветвью (`HEAD:scripts/{name}` вместо `3e071370^:…`), условие hit оставлено: **rc 1**, `observations=3 failures=2 not_applicable=0`. Строка `parent-A: … hit=1 accepted=0` наблюдается и судится, в N/A не уходит.
    - M5, то же что M4, но без `not hit`: **rc 1**, `observations=2 failures=1 not_applicable=1`. parent-A с доставленным сбоем замаскирован под N/A. Пара M4→M5 — красное для условия hit на самой метке parent-A.
    - Вывод: N/A выдаётся только при недоставленном сбое. Стоит доставить сбой — клетка судится. На `current` красное не маскируется.
11. **pre_critic.** `bash scripts/pre_critic.sh contracts/992-oshibka-eto-otkaz.md` → **rc 1**: `ОТКАЗ: гейт предпосылок 122 красен (rc=1): predposylki ОТКАЗ: predposylki-otsutstvuyut`.
    - Прямой вызов `bash scripts/check_predposylki.sh "$PWD" contracts/992-oshibka-eto-otkaz.md` → **rc 1**, причина та же.
    - Причина в коде, а не в среде копии. Текст 992 (строки 12, 64) содержит литерал `.github/workflows/`, а поля `ПРЕДПОСЫЛКИ:` нет. Текст побайтово совпадает с `frozen/contracts/992/2`: тег `aff50503e` от 2026-10-17, а гейт 122 (`2446b7a6a`) появился 2026-10-21. Гейт применён задним числом.
    - Дельта implementer эти входы не трогает: diff `4576309b9..b506b2b95` состоит только из фикстуры.
    - Дверь `done_contract.sh` не зовёт pre_critic/check_predposylki (grep пуст). Подробности — С-2. За зелёный этот rc не выдаю.
12. **CI-шаги.** `bash scripts/gen_ci_steps.sh --check` → **rc 0**.

Своей мерой сверено, что заявлено, то и сделано. В постановке: `+30/−1`, итог матрицы `25/74/17/1`, `--model` `25/25/0`, `--list` 25. Каждое число совпало с собственным прогоном или подсчётом (grep строк `accepted=0`, сравнение с матрицей до правки).

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа:
- **`NA_PARENT_A` и ветвь N/A в `main()`** (стр. 98-109, 325-332).
  - (1) Требующее свойство: слово владельца В2 «пометить неприменимой с причиной» для различимости в `--matrix` (контракт 992, строка 40).
  - (2) Состояние: константа-словарь. Причина и измерение (hit/control_rc/fault_rc) печатаются явно.
  - (3) Сопряжённых файлов 1, число не выросло.
  - (4) Интерфейс: флагов, env и rc не прибавилось, в итоге добавилось одно поле.
  - (5) Потребитель: `--matrix` архитектора и судей (строка 64). Грамматику и логику дерева не повторяет.
  - Класс ESSENTIAL. Более простые формы (удалить клетку или ослабить ожидание parent-A) меняют критерий.
- **Счётчики `observations`/`not_applicable`** (стр. 310-311, 340, 347).
  - (1) Требующее свойство: честный счёт наблюдений при пропущенной клетке (строка 45, «независимый от счётчика observations пересчёт»). Прежняя формула `len*3` дала бы 75 при 74 фактических.
  - (2) Состояние явное, оно в строке итога.
  - (3) Сопряжённых файлов 1.
  - (4) Новых флагов нет.
  - (5) Потребитель — строка итога для судей. `red_doc_lifecycle.sh:5` только вызывает фикстуру, итог не парсит. `b13_token.py` импортирует функции мира, а не `main()`, и его батарея 54/0 прошла.
  - Класс ESSENTIAL.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`: `grep -c` → 0, обоих файлов нет. Сверять не с чем. Форму модуля сверил с самой фикстурой: правка повторяет существующий приём (hit-файл как свидетельство доставки, печать `control_rc/fault_rc`) и второй конвенции не заводит.

СВЕРКА-АРХИТЕКТУРЫ: в dev-harness нет `tooling/checks/cli.js` и `bindings.json` (ls → нет файлов), модели архитектуры 188 у этого репо нет.
- Размещение: фикстура в своём каталоге `fixtures/freeze_contract/`, зона implementer.
- Зависимости: импорты не менялись.
- Писатели: новых нет, фикстура пишет только во временные каталоги.
- Операции: новых нет.
- Долг не расширен, уровень diff модели — нет (не L2/L3). Находку 188 заводить не по чему.

ОСТАТОК: строки `НЕ ЗАЩИЩАЕТ` контракта 992 (строки 78-80) не несут К-NN с ловцом reviewer. Отдельного ОСТАТОК-итога по несуществующим строкам нет.

Н-39: стабы к ветвям привязывает architect по коду. Связь шима клетки с ветвью кода проверена по коду фикстуры (стр. 192) и по коду parent-A (п.3), а не по прозе контракта.

## Блоки

Нет. Доказанного нарушения (file:line, команда, rc) в дельте не найдено.
- Критерий не сменён: правка убрала ровно одну строку parent-A с hit=0 (п.5).
- N/A не маскирует провал: это показывают мутанты M3 и M5 (п.10).

## НЕ ЗАЩИЩАЕТ

- **17 красных строк `current` в `--matrix`.** Это 16 B-current и 1 C-current, историческая матрица: она ждёт fail-open от исправленного кода. По решению владельца В1 это не регресс. CI их не видит, потому что `--matrix` в CI не зовётся.
- **pre_critic в копии: rc 1.** Причина — гейт 122, применённый к тексту, замороженному до его введения (п.11, С-2). Этот вердикт шаг не закрывает и зелёным его не объявляет.
- **Не перепроверялось:** реализация 992 вне клетки (принята v1), полный `verify_antiplacebo` (CI), live-приёмка, конфликты CI-реестров.
- **Ветвь N/A не требует зелёного контроля** (С-1). Сейчас контроль parent-A зелёный (`control_rc=0`).

## Советы

- **С-1.** Добавить `and green` в условие N/A на `fixtures/freeze_contract/fail_closed_992.py:326`. Тогда красный контроль parent-A пойдёт в общую ветвь с печатью `CONTROL:`.
- **С-2.** Решение владельца по pre_critic/122 для 992: новая редакция с полем `ПРЕДПОСЫЛКИ:` либо явная неприменимость гейта к тексту, замороженному до 122. Подробности — `.review/2026-11-24-157.md`.
