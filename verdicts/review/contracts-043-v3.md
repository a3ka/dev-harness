accept
OBJECT=79c8d4811dc22499cf0a10eab6c488734c0e45f2
СУД: один scoped reviewer по Б-10, вызов 2 (санкция консультанта 22:34 UTC после FAIL вызова 1; слово владельца ~18:09 21.11 п.6); роль=reviewer; сессия=Rev043B10c; repo=dev-harness; предмет=043 (+ клетки 996 в том же PR); PR=a3ka/dev-harness#1202 (headRefOid=79c8d4811d, проверено `gh pr view`); база вызова 2=22118296c154a212d4263b10f196c152ea15c509 (OBJECT вызова 1); предыдущий=FAIL verdicts/review/contracts-043-v2.md (коммит 7a7dc4af84); модель-факт=anthropic/claude-opus-5-5; класс задачи=кодовый (фикстуры); класс риска=обычный (не понижен; повышать не стал: правка только в клетках 996, дверь не тронута); скоуп=только закрытие БЛОКА-1 и неподгонка клеток rezhim_996.

ИТОГ: БЛОК-1 вызова 1 закрыт. Клетки `freeze-precision-preserved` и `precritic-precision-preserved` вернулись в GATE_CASES. Их дефект `ПЕРЕСЕЧЕНИЕ architect: bad` бьёт действующую ногу (а) precision-гейта, строку отказа `scripts/check_precision_gate.sh:135`. Паритет CI (нога (в)) клетки не используют. Мутант М8f3, который на OBJECT вызова 1 выживал (109/0), на OBJECT вызова 2 краснит семью (111/1). М8f и М8p тоже красные. `skip-precision` привязан к обеим клеткам. Дверь и семья 043 не тронуты.

ОСТАТОК: К-7 996:117 (правка замороженного контракта, ловец reviewer) — не укусил: `git diff --name-status 22118296c1 79c8d4811d` не содержит ни одного файла `contracts/`/`frozen/`.
ОСТАТОК: 996:51 (вторая копия логики в diff пакетов B/C, ловец reviewer) — не укусил: в диффе нет скриптов пакетов B/C, только `fixtures/workshop_project/rezhim_996/`.

══ (1) ОБЛАСТЬ — `git diff --name-status 22118296c1 79c8d4811d` ══
  M	fixtures/workshop_project/rezhim_996/.probe-only
  M	fixtures/workshop_project/rezhim_996/probe.py
Ровно два файла, оба в ЗОНА architect 996 (`contracts/996-rezhim-proekta-polnyj-cikl.md:121`). Один коммит 79c8d4811d, author=committer=architect. Перечень всех изменений `git diff 22118296c1 79c8d4811d`:
  а. probe.py:287 — GATE_CASES `freeze-precision-preserved: ('freeze', 'precision', 'precision-гейт 043')`;
  б. probe.py:293 — GATE_CASES `precritic-precision-preserved: ('pre_critic', 'precision', 'precision-gate')`;
  в. probe.py:327-330 — ветка дефекта `precision`: в тело контракта добавляется `\nПЕРЕСЕЧЕНИЕ architect: bad\n`;
  г. probe.py:1538 — `'precision': ('precision',)` в словаре привязок мутантов, отсюда `MUTANTS['skip-precision']`;
  д. probe.py:1548 — `tempfile.TemporaryDirectory(prefix='architect996-')` без `dir='/tmp'`, миры прогона теперь идут по TMPDIR;
  е. `.probe-only` — переписан абзац Б-10/Б-10б: обоснование, счёт 111/17/76/149, замеры.
Других изменений нет. Оракул (`expect`, маркеры, проверки HEAD/refs/байтов, ремонт тем же входом) не менялся: тело `gate_test` вне ветки `precision` и все `expect` — те же байты, что на 22118296c1.

══ (2) БЛОК-1: красное предъявлено ══
Раскладка: одноразовый клон `.scratch-rev043b10c/inst2` (`git clone --shared`, HEAD=79c8d4811d) как установка. TMPDIR=`.scratch-rev043b10c/tmp` лежит рядом с ним, а не внутри (условие `ROLE_CONTEXT_LEAKS_INSTALLATION`, `.probe-only`). Оракул не ослаблен. Мутации — правки рабочего дерева клона, после каждого прогона `git checkout -- scripts/`.
  честная дверь: `probe.sh --case freeze-precision-preserved` → rc 0 (1/0/0); `--case precritic-precision-preserved` → rc 0 (1/0/0).
  М8f3 (`freeze_contract.sh:442` → `if [ "$pg_rc" -ne 0 ] && case "$TARGET" in contracts/*|plans/*) true ;; *) false ;; esac; then`):
    вызов 2, `--case freeze-precision-preserved` → rc 1, `PROJECT_GATE_BYPASSED:precision rc=0 … заморожено: .harness/tasks/777-toy.md → frozen/contracts/777/1` — УБИТ;
    вызов 2, полный `probe.sh` → rc 1, `996: examined=111 mutants=0 mismatches=1`, `996: проектный цикл не замкнут` — УБИТ;
    вызов 1 (клон на 22118296c1), полный `probe.sh` → rc 0, `996: examined=109 mutants=0 mismatches=0` — слепая зона воспроизведена.
  М8f (`freeze_contract.sh:442` → `if [ "$pg_rc" -ne 0 ] && [ ! -f "$ROOT/harness.project.json" ]; then`): `--case freeze-precision-preserved` → rc 1, `PROJECT_GATE_BYPASSED:precision rc=0 … заморожено … frozen/contracts/777/1` — УБИТ. Вызов 1 отмечал, что М8f в rezhim_996 выжил (109/0); теперь его ловит клетка носителя 996.
  М8p (`pre_critic.sh:133` → `if [ -z "$REPO_ARG" ] && ! bash scripts/check_precision_gate.sh …`): `--case precritic-precision-preserved` → rc 1, `PROJECT_GATE_BYPASSED:precision rc=0 stdout='КРИТИК: дверь зелёная\n'` — УБИТ. `--case freeze-precision-preserved` → rc 0: мутант pre_critic не задевает freeze, клетки различимы.
  М9, свой (`check_precision_gate.sh:135` `die "ПЕРЕСЕЧЕНИЕ не по грамматике: $xline"` → `continue`): обе клетки rc 1, `PROJECT_GATE_BYPASSED:precision rc=0` — УБИТ. Это мера пункта 3: без строки :135 дефект клеток проходит. Значит, отказ даёт именно :135, и никакая другая нога на этом входе не отказывает, паритет тоже.
  skip-precision (стаб модели «precision-гейт пропускается»): `--matrix` → `mutation skip-precision: freeze-precision-preserved: rc=1 PROJECT_GATE_BYPASSED:precision` и `mutation skip-precision: precritic-precision-preserved: rc=1 PROJECT_GATE_BYPASSED:precision`. Обе клетки есть и в `skip-gates` (rc=1 каждая). Привязка вычисляется кодом (`probe.py:1536-1544`), не прозой контракта (Н-39). Свой импорт `probe.MUTANTS['skip-precision']` = `('freeze-precision-preserved', 'precritic-precision-preserved')`.

══ (3) Оба старых обязательства ══
  (а) Клетки паритета не вернулись. В `probe.py`/`model.py` 0 вхождений `unwired`/`check:unwired`. Единственный вызов `verify_ci_parity.sh` — `probe.py:90`: это предпосылка «toy паритетен» (raise при rc≠0), не клетка, и диффом она не тронута. Красный паритет у дверей остаётся предупреждением (`check_precision_gate.sh:539-540`, Б-10, замена 043:213-218).
  (б) Активная нога держит 996:87 («freeze — … precision …», «pre_critic — precision»). Дефект `ПЕРЕСЕЧЕНИЕ architect: bad` проходит якорь `case "ПЕРЕСЕЧЕНИЕ "*` (`check_precision_gate.sh:128`), но не грамматику `^ПЕРЕСЕЧЕНИЕ ([^:[:space:]]+): ([^ ]+) — ([0-9]{3}) (.+)$` (:130-133): нет ` — NNN причина`. Это нога (а), отказ `die` на :135, rc 1, маркер `precision-гейт 043:` (:68). Нога (а) исполняется первой, до (б) и до паритета (в) на :536-543, так что паритет на исход не влияет (М9 выше). Маркер у двери freeze — `freeze_contract.sh:444` `die "precision-гейт 043 красен: …"`, у pre_critic — `pre_critic.sh:134` `refuse "precision-gate красен: …"`. Это ровно маркеры клеток `probe.py:287,293`.

══ (4) Сырой вывод на OBJECT (установка inst2, TMPDIR соседом) ══
  `npm run check:rezhim-996-family-selftest` → rc 0; `996: examined=111 mutants=0 mismatches=0`; 111 строк `<case>: rc=0`, включая `freeze-precision-preserved: rc=0` и `precritic-precision-preserved: rc=0`.
  `bash fixtures/workshop_project/rezhim_996/probe.sh --model` → rc 0; `996: examined=111 mutants=0 mismatches=0`. Свой подсчёт: строк `: rc=0` — 111, других строк кроме итоговой — 0.
  `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix` → rc 0; `996: examined=111 mutants=76 mismatches=0`. Свой подсчёт по 261 строке вывода: строк `^mutation ` — 149, из них `rc=1` (CAUGHT) — 149, `rc=0` (LIVE) — 0; различных мутантов — 76; честных строк `rc=0` — 111. Свой импорт probe.py: CASES 111, GATE_CASES 17, MUTANTS 76, предъявлений 149. Совпадает с заявленным 111/17/76/149.
  `bash fixtures/_krasnye_043.sh` → rc 0, `итог: 26 файлов, провалов 0`.
  `bash fixtures/parsing_hygiene_battery/run_battery.sh check_precision_gate` → rc 0, `итог 4/4 классов закрыто`.
  После всех прогонов `git status --short` в клоне — 0 строк: прогоны не пишут в установку.

══ (5) Неподгонка ══
Правка клеток не ослабила оракул. Новая ветка дефекта меняет только вход, а `expect` у `gate_test` общие для всех 17 клеток (rc 1 + маркер, неизменность HEAD/refs/байтов, ремонт → rc 0 и тег). Клетки зелёные на честной двери и красные на четырёх независимых обходах двери (М8f3, М8f, М8p, М9) плюс на двух стабах модели. Для freeze ремонт проверен тегом `frozen/contracts/777/1` (`probe.py:425-428`), то есть reject-all не зелёный. Изменение «д» (TMPDIR вместо `/tmp`) не находка. Без TMPDIR `tempfile` и так берёт `/tmp`, CI не меняется. С TMPDIR внутри установки оракул `context-*` даёт красное (fail-closed), а не ложное зелёное. Это записано в `.probe-only` и проверено раскладкой выше.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), артефакт «ветка дефекта precision + две строки GATE_CASES + привязка skip-precision» (probe.py:287,293,327-330,1538): (1) свойство 996:87 «freeze — precision», «pre_critic — precision»; (2) состояние — только строка в теле контракта мира, она видна в коммите мира и откатывается ремонтом; (3) при правке того же свойства меняется 1 файл (probe.py), было столько же; (4) интерфейс не вырос: ни флага, ни env, ни кода возврата; (5) потребители — `probe.sh`/`--matrix` (CI-шаг `check:rezhim-996-family-selftest`), грамматику ПЕРЕСЕЧЕНИЕ клетка не повторяет, а нарушает. ESSENTIAL. Артефакт «TemporaryDirectory без dir» (probe.py:1548): (1) свойства нет, это удобство прогона, scratch можно держать внутри копии; (2) состояние явное — TMPDIR; (3) 1 файл; (4) интерфейс не вырос: новых аргументов/флагов нет, TMPDIR читает stdlib `tempfile` (без TMPDIR — `/tmp`, как прежде); (5) потребитель — изоляция прогонов по Н-85. ACCIDENTAL не блокирует: фрагмента с отсутствующим свойством и более простой формой, проходящей те же строки приёмки, нет.

СВЕРКА-АРХИТЕКТУРЫ: размещение — 2 файла в ЗОНА architect 996 (`fixtures/workshop_project/rezhim_996/`). Новых зависимостей нет (probe.py — те же tempfile/json/subprocess/pathlib). Писатель state — только мир фикстуры во временном каталоге. Операции, `bindings.json`, дверь `scripts/check_precision_gate.sh`, `freeze_contract.sh`, `pre_critic.sh`, `model.py` не затронуты, долг не расширен. Diff модели нет (L-уровень не применим). `tooling/checks/cli.js` в дереве нет, находку архитектуры заводить нечем и не по чему.
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep — 0 совпадений, файлов нет). Дельта трогает только фикстуры, сверять не с чем.

Находок нет: ни блоков, ни советов, файла `.review/` этот вызов не заводит. Советы С-1…С-4 вызова 1 вне скоупа, повторно не судились.
