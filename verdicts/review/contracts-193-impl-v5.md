FAIL
OBJECT=a065dc05b04062b45fa7acb099069c1e238a2de2
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался)
СУД: repo=dev-harness; предмет=193; фаза=реализация v3; роль=reviewer; вызов=impl-v5; сессия=Rev193Impl; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev193Impl | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0)
Контракт: frozen/contracts/193/3 (f059ac84873eec9580359912978fa5792b349994), contracts/193-svyazka-sdatochnyj-list.md v3.
Находки: `.review/2026-11-20-120.md` — блоков 1 (Б-1), советов 3 (С-1…С-3).

# Вердикт reviewer — 193, реализация v3

## Итог

**FAIL — один блок.**

Б-1: `scripts/lib_karta_sdachi.sh:167` строит индекс вызовов командой `git rev-list --objects HEAD -- <critic-каталог>/`, без `--full-history`. git при этом упрощает историю: на слиянии, где каталог совпадает с одним из родителей, обходится только этот родитель. Последний FAIL, достижимый из HEAD, но лежащий на другой стороне такого слияния, в индекс не попадает.

Своим end-to-end миром показано: дверь листа даёт `лист зелёный` (rc 0) при непокрытом `К-11: блок` такого FAIL. Это прямое нарушение И5: «источники — … достижимой из HEAD истории», «последний FAIL … все его блоки обязательны». НЕ ЗАЩИЩАЕТ п.4 прямо говорит: «не исключение для последнего FAIL».

В реальной истории станции такое сокрытие уже есть: один блоб вердикта критика не виден без `--full-history`. Исправление — один флаг. Мутант с ним проходит всю приёмку п.10 (151/151) и ловит мой мир.

Остальное в порядке:
- область правки и авторство соблюдены;
- батарея и барьеры после freeze не тронуты;
- приёмка п.10 зелёная: `--repo .` 151/151, `--model` 151/151, `--stabs` 58/58;
- красное-до предъявлено своей мерой: 83 из 151;
- CI-строка и замер 193 не нарушают правило 114.

## 1. Объект, область правки, авторство (повестки 1, 5)

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tc13deb529/m
git rev-parse --verify a065dc05b04062b45fa7acb099069c1e238a2de2^{commit} → a065dc05b04062b45fa7acb099069c1e238a2de2
git switch --detach a065dc05…; git rev-parse HEAD → a065dc05b04062b45fa7acb099069c1e238a2de2
git rev-parse 'frozen/contracts/193/3^{commit}' → f059ac84873eec9580359912978fa5792b349994
git merge-base --is-ancestor frozen/contracts/193/3 a065dc05b0 → anc=0
git log --format='%h %an|%ae|%cn|%ce' 6ecce58baf..a065dc05b0:
  a065dc05b0 orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local  (merge origin/main, норма 167)
  df1f91de18 orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local  (CI-строка --repo .)
  2d5023e7a5 orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local  (merge origin/main, норма 167)
  7417bfceab implementer|implementer@dev-harness.local|implementer|implementer@dev-harness.local      (реализация v3)
git diff --stat 6ecce58baf a065dc05b0 → 6 файлов:
  .github/workflows/ci.yml 12, registry/ci-steps.tsv 2, registry/ci-zamery.tsv 2,
  scripts/check_sdacha.sh 11, scripts/check_verdict_karta.sh 6, scripts/lib_karta_sdachi.sh 188 (+204/−17)
git show --stat 7417bfceab → scripts/check_sdacha.sh, scripts/check_verdict_karta.sh, scripts/lib_karta_sdachi.sh
git show --stat df1f91de18 → .github/workflows/ci.yml, registry/ci-steps.tsv, registry/ci-zamery.tsv
git diff-tree --cc --name-only 2d5023e7a5 / a065dc05b0 → пусто (собственных разрешений конфликтов нет)
```
- ЗОНА сверена с frozen-текстом живой командой (`git show frozen/contracts/193/3^{commit}:contracts/193-…`):
  - `ЗОНА implementer: scripts/check_sdacha.sh scripts/check_verdict_karta.sh scripts/lib_karta_sdachi.sh scripts/pre_critic.sh scripts/freeze_contract.sh`;
  - `ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`.

  Пути 7417bfceab ⊆ зона implementer, пути df1f91de18 ⊆ зона orchestrator. Merge-коммиты собственных путей не вносят.
- Автор = коммиттер на каждом из четырёх коммитов диапазона.
- Атомарность: реализация — один коммит implementer, CI-проводка — один коммит orchestrator, оба со ссылкой на предмет.
- ПЕРЕСЕЧЕНИЕ orchestrator «только новая строка self-test 193; чужие строки и замеры сохраняются»: дифф `registry/` меняет ровно строку `check:sdacha-193-family-selftest` в обоих TSV. `ci.yml` — производная материализация генератором (перебалансировка lane): `bash scripts/gen_ci_steps.sh --check --root .` → rc 0.

## 2. Проверки не подогнаны; frozen-барьеры неизменны (повестки 3, 6)

```
git diff --stat frozen/contracts/193/3 a065dc05b0 -- fixtures/workshop_project/sdacha_193/ contracts/193-svyazka-sdatochnyj-list.md \
    scripts/pre_critic.sh scripts/freeze_contract.sh fixtures/_krasnye_103.sh fixtures/workshop_project/forma_do_kritika_191/ → пусто, rc=0
git log --oneline 6ecce58baf..a065dc05b0 -- fixtures/ → пусто
```
Батарея, контракт, ноги pre_critic/freeze и замороженные семьи 103/191 после freeze v3 не менялись. Автор реализации проверок не касался. Нормативных документов в диффе нет.

## 3. Приёмка п.10 на дереве OBJECT — свой прогон (повестки 2, 4, 7)

Все прогоны — при `TMPDIR=/tmp/dev-harness-verify/reviewer193-judge`.
```
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --repo .  → ИТОГ 193: rc=0 KLETKI=151 ZELENYE=151 KRASNYE=0   rc=0  46 с
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --model   → ИТОГ 193: rc=0 KLETKI=151 ZELENYE=151 KRASNYE=0   rc=0  46 с
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --stabs   → ИТОГ 193: rc=0 OBMANOK=58 POIMANY=58 ZHIVYH=0     rc=0  170 с
```
- Своя мера чисел.
  - Второй прогон `--repo .` с подсчётом строк вывода клеток (`grep -c ' ok '` / `grep -c ' KRASNO '` по логу): ИТОГ 193: rc=0 KLETKI=151 ZELENYE=151 KRASNYE=0, rc 0, 46 с; строк ok 151, KRASNO 0 (лог /tmp/dev-harness-verify/reviewer193-judge/bat-object.log).
  - `grep -vc '^#' fixtures/workshop_project/sdacha_193/stabs.tsv` → 58 = OBMANOK.
- Красное-до своей мерой. Клон `/tmp/dev-harness-verify/reviewer193-judge/before`: OBJECT, в котором три двери реализации возвращены к 07736e8dc9 (родитель 7417bfceab). Батарея OBJECT `--repo <before>` → `ИТОГ 193: rc=1 KLETKI=151 ZELENYE=68 KRASNYE=83`, rc 1, 37 с; строк KRASNO 83, ok 68. Барьер 193 v3 красен против дверей до реализации и зелен после.
- Дверь листа на самом контракте: `bash scripts/check_sdacha.sh . contracts/193-svyazka-sdatochnyj-list.md --run` → `СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=3)`, rc 0, 498 с. Первая попытка была снята по МОЕМУ таймауту инструмента 300 с: дверь шла параллельно с батареей. Это ошибка вызова, а не механизма.
- `bash scripts/pre_critic.sh contracts/193-svyazka-sdatochnyj-list.md` → «КРИТИК: дверь зелёная», нога (к) «ok   сдаточный лист красен» (строка ноги), rc 0, 498 с.
- `bash scripts/check_provodka.sh . contracts/193-svyazka-sdatochnyj-list.md` → rc 0.
- `bash scripts/gen_ci_steps.sh --check --root .` → rc 0.

## 4. Б-1 — свои зонды и мутант

**Зонд библиотеки `probe_lib.sh` (P1).** Мир: accept 03 на main; на ветке `side` закоммичен FAIL 04 (`К-11: блок`), затем удалён; на main посторонний коммит; `merge --no-ff side`.
```
rev-list --objects HEAD | grep -c c-04.md                                   → 1   (блоб достижим из HEAD)
rev-list --objects HEAD -- verdicts/critic/ | grep -c c-04.md               → 0   (форма lib :167)
rev-list --objects --full-history HEAD -- verdicts/critic/ | grep -c c-04.md → 1
karta_poslednij_fail (OBJECT)  → пусто, rc=0
karta_poslednij_fail (мутант)  → 17 строк, К-11	блок, rc=0
P1b (линейно: закоммичен, затем удалён) OBJECT → 17 строк, К-11	блок
```

**Дверь end-to-end `probe_door.sh`.** Те же миры, двери скопированы из дерева. Контракт и лист — фикстуры семьи (`mir/kontrakt_chestnyj.md`, `mir/sdacha_chestnaja.md` + `ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/c-03.md`).
```
### OBJECT
  merge-мир:  СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)          door rc=0   ← ложное зелёное
  линейный:   ОТКАЗ: блок К-11 предыдущего вердикта не закрыт в «## Дельта»  door rc=1
### MUTANT --full-history
  merge-мир:  ОТКАЗ: блок К-11 предыдущего вердикта не закрыт в «## Дельта»  door rc=1
  линейный:   ОТКАЗ: блок К-11 предыдущего вердикта не закрыт в «## Дельта»  door rc=1
```

**Достижимость на реальной истории (OBJECT).**
```
rev-list --objects HEAD -- verdicts/critic/ (.md, uniq)                → 939
rev-list --objects --full-history HEAD -- verdicts/critic/ (.md, uniq) → 940
скрытый: 302fe74d2edcfcc2133279927bb6ad5b3d4fb69e verdicts/critic/contracts-083-v1.md (первая строка accept)
  ffc67552e2 architect 083: sync verdicts/critic/contracts-083-v1.md к main-канону перед land_agent
  52c90c7302 critic critic: вердикт accept (консолидация круг 3) материализован на ветку …
```

**Мутант** `/tmp/dev-harness-verify/reviewer193-judge/mutant` (OBJECT + одна правка `:167`: `rev-list --objects --full-history HEAD -- …`). Батарея OBJECT `--repo <mutant>` → `ИТОГ 193: rc=0 KLETKI=151 ZELENYE=151 KRASNYE=0`, rc 0, 48 с; строк ok 151. Более простая и верная форма проходит все строки приёмки. Батарея этот класс не различает: мира со слиянием в ней нет (Н-39, зона architect).

Классификация: блок. Состояние достижимо штатными git-операциями станции и уже встречается в реальной истории. Дверь при этом выдаёт ложное зелёное ровно на том классе, ради которого делался v3: старый accept скрывает новый FAIL (боль 206). Комментарий `:163-166` («тот же состав, что и поход по коммитам с ls-tree») неверен и вводит в заблуждение.

## 5. Советы

Подробности — в `.review/2026-11-20-120.md`.
- С-1 `scripts/lib_karta_sdachi.sh:185`. Последний FAIL распознаётся строгим `= FAIL`, а freeze §6 (`scripts/freeze_contract.sh:318-320`) нормирует первую строку (`tr -d '\r'` + trim). Зонд P7: первая строка `FAIL ` → «блоков в последнем FAIL: 0»; CRLF-вердикт пропускается так же (P3).
- С-2 `scripts/lib_karta_sdachi.sh:129`. Тема сравнивается строкой: `предмет=0777` ≠ `777` (P2), хотя у `вызов=` нули снимаются.
- С-3 `registry/ci-steps.tsv:318`. Комментарий окна «в CI на время окна остаются --model и --stabs; `--repo .` вернуть …» устарел после строки `:319`.

## 6. Вес/замер CI 193 (контракт 114)

```
bash scripts/check_ci_weights.sh --root .  → ОТКАЗ: нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest   rc=1
```
Отказ г1 возникает до 193: ключи 118/123 в диффе `registry/` не участвуют, дифф меняет только строку 193.

Изоляция: в клоне-мутанте к TSV временно дописаны строки 118/123 с замером, равным их весу (58 и 0); затем `git checkout`. Результат: `ok: веса по замеру: 121 ключей`, rc 0. г2 для 193 (вес 40, замер 40/59/0): max(40,40)=40 ≤ 3·40 — правило не нарушено. г3 (свежесть) прошла в том же прогоне.

## 7. Регресс затронутых барьеров (scoped)

```
bash scripts/scope_select.sh . --scope check_sdacha check_verdict_karta pre_critic freeze_contract → MODE: scoped, 4 ключа, rc 0
bash scripts/verify_antiplacebo.sh --scope check_sdacha check_verdict_karta pre_critic freeze_contract → rc 1, 27 с
  FAIL check_sdacha.sh: нет фикстур — ожидается fixtures/check_sdacha/case_*.sh
  FAIL check_verdict_karta.sh: нет фикстур — ожидается fixtures/check_verdict_karta/case_*.sh
  ok × 17 (freeze_contract 15, pre_critic 2): «барьеров: 4 · фикстур: 17 · предъявлено красным повторным прогоном: 17»
git ls-tree --name-only 6ecce58baf fixtures/check_sdacha fixtures/check_verdict_karta | wc -l → 0 (и на OBJECT → 0)
```
Оба FAIL уже были до дельты: каталога case-фикстур у двух дверей нет ни до диффа, ни после, а их барьер — семья sdacha_193. Ноги freeze и pre_critic в диффе не менялись; их фикстуры зелёные.

## Обязательные строки

ОСТАТОК: НЗ-1 (смысловая достаточность доказательств; ловец reviewer при суде реализации) — не укусил: двери судят форму, прогон и покрытие; смысловых суждений в диффе нет.
ОСТАТОК: НЗ-2 (полнота охвата дверей и расположение листа; К-04, ревьюер зон) — не укусил: лист `fixtures/workshop_project/sdacha_193/SDACHA.md` в зоне architect, в диффе не менялся; пути коммитов ⊆ зон (§1).
ОСТАТОК: НЗ-4 (не предъявленный исторический FAIL вне каталога/темы или без СУД; ловец reviewer при аудите; «не исключение для последнего FAIL и источников цепочки И5») — УКУСИЛ: `scripts/lib_karta_sdachi.sh:167`, Б-1. Последний FAIL того же каталога, той же темы, с СУД, достижимый из HEAD, не судится.
ОСТАТОК: НЗ-5 (универсальная полнота мутаций и сговор субъекта с батареей; ловец reviewer) — укусил в части полноты: в батарее нет мира со слиянием, и Б-1 проходит её 151/151. Сговора нет: батарея с freeze не менялась (§2).
ОСТАТОК: НЗ-7 (одновременная правка двери и lib под конкретный вход) — не укусил: батарея и входы не менялись, правка lib общая.
(НЗ-3, НЗ-6, НЗ-8 ловцом reviewer не названы.)

ПРОВОДКА: guard `fixtures/workshop_project/sdacha_193/red_sdacha_193.sh` — барьер именно предмета 193. Шаг CI `check:sdacha-193-family-selftest` (`registry/ci-steps.tsv:319`) исполняет `--repo .`, `--model` и `--stabs`, то есть потребитель п.10 подключён. `check_provodka.sh` → rc 0. ПРОВОДКА-ЭНФОРСМЕНТ обоснована: чистый энфорсмент, норм ролей контракт не вводит.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа:
- `karta_stroki` (бывший разбор `karta_proverit` + ветвь ссылки) — (1) И5/И7, грамматика ссылки; (2) состояния нет, статус `ссылка:N` виден в выводе; (3) 1 файл, число не выросло; (4) интерфейс прежний (текст → 17 строк); (5) потребители — обе двери и клетки r*. ESSENTIAL.
- `karta_metadannye` — (1) И5, поля СУД; (2) глобальные K193_TEMA/VYZOV/ROL — побочным эффектом, не в выводе; (3) 1; (4) мелкая, но единственная точка разбора СУД; (5) внутренний потребитель — индекс и N−1. ESSENTIAL. Неявное состояние — замечание без блока.
- `karta_predydushchij` — (1) И5 N−1 источника; десятичное вычитание строкой требуется клеткой r48 (20 знаков); (2) нет; (3) 1; (4) узкий интерфейс; (5) r34–r48. ESSENTIAL.
- `karta_index` — (1) И5: источники, неоднозначность, последний FAIL; (2) глобальные K193_TEKST/K193_BLOB/K193_POSLED_FAIL — неявные; (3) 1; (4) интерфейс из трёх аргументов прячет обход истории; (5) обе двери. ESSENTIAL. Содержит Б-1.
- `karta_klass` и `karta_raskryt` — (1) И5: транзитивность, цикл пары, полнота карт источников (К-09 Crit193V7); (2) стек пар — в аргументе, явно; (3) 1; (4) глубокие; (5) r50–r56. ESSENTIAL.
- `karta_poslednij_fail` — (1) И5, последний FAIL; (2) нет собственного; (3) 1 + вызов в check_sdacha; (5) r07–r09, r17–r33. ESSENTIAL.
- Вызовы дверей с ROOT/путём (`check_sdacha.sh:262-265`, `check_verdict_karta.sh:99`) — (1) И5/И7; (5) обе двери. ESSENTIAL.
- CI-строка (вес 8→40, `--repo .`) и замер 40/59/0 — (1) ПРОВОДКА + п.10; (5) CI. ESSENTIAL.
- Комментарий `registry/ci-steps.tsv:318` — ACCIDENTAL (устарел). Совет С-3, не блок.

СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции не объявляет документ архитектуры и стандарт кода: `grep -n -iE 'ARCHITECTURE|CODING-STANDARDS|bindings.json' AGENTS.md` → пусто; `ls docs/ARCHITECTURE.md docs/CODING-STANDARDS.md` → нет файлов.

СВЕРКА-АРХИТЕКТУРЫ: размещение — новые функции в единой библиотеке `scripts/lib_karta_sdachi.sh`, двери — потребители (И7 «без второго разбора») — соответствует. Зависимости: только git plumbing и bash, новых нет. Писатели: двери ничего не пишут (HEAD/index/байты неизменны — клетки r10–r13 зелёные). Операции — чтение. `bindings.json` и `tooling/checks/cli.js` в дереве отсутствуют (glob/ls → нет), модели 188 у станции нет, и находку архитектуры заводить нечем: L-уровень н/п. Долг не расширен.

## Не проверено

- Полный CI на OBJECT — не прогонялся по заданию. Факт «PR #1161 CI зелёный» взят из задания, своей мерой не проверен.
- Регресс замороженных семей п.7 (`_krasnye_103.sh`, 191/192/189/190 `--model`) не прогонялся. Ноги pre_critic/freeze и файлы семей в диффе не менялись (§2), но затронутая lib исполняется ими через дверь — [INFERENCE] регресс маловероятен.
- Гейты п.6 `check_threat_model`, `check_ceilings`, `check_spec_ready`, `check_precision_gate`, `check_provodka --grammar` — не прогонялись: контракт с freeze не менялся.
- Мутации сверх Б-1/С-1/С-2: универсальная полнота не исследовалась (обычный круг ревью).
- `.judge-scratch/` не создавался, в `.git/info/exclude` ничего не добавлялось. У копии worktree `info/exclude` общий с основным репозиторием, а правка вне копии запрещена. Все черновики лежат под `$TMPDIR=/tmp/dev-harness-verify/reviewer193-judge`.

## Исправленные ошибки своих команд

1. Первый `bash` без `cwd`: «запись относительным путём без cwd запрещена — Н-85». Исправлено передачей `cwd`.
2. `git show … > файл` отклонён политикой инструмента (`* > *`). Контракт прочитан выводом команды.
3. `sed -i` отклонён политикой. Мутант собран `python3` с проверкой применённости (`assert n != s`).
4. В `probe_door.sh` первая версия печатала rc подоболочки `tail`, а не двери (`door rc=0` в обоих мирах). Исправлено захватом `$?` внутри подоболочки; повторный прогон дал верные rc (§4).
5. Первый прогон `check_sdacha --run` снят по моему таймауту инструмента 300 с (параллельно с батареей). Повтор — rc 0, 498 с.
6. `scope_select --scope … lib_karta_sdachi` → «неизвестный ключ lib_karta_sdachi»: такого ключа у классификатора нет. Регресс прогнан без него.
