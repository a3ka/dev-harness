accept
OBJECT=1ccea8f3c5d83c15befbaef4d8737437a9cb00b2
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался)
СУД: repo=dev-harness; предмет=193; фаза=реализация v3, scoped-исправление Б-1; роль=reviewer; вызов=impl-v6; сессия=Rev193Scoped; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev193Scoped | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0)
Контракт: frozen/contracts/193/3 (f059ac84873eec9580359912978fa5792b349994); `git diff --stat frozen/contracts/193/3 HEAD -- contracts/193-svyazka-sdatochnyj-list.md` → пусто.
Находки: новых блоков 0, новых советов 0. Б-1 из `.review/2026-11-20-120.md` закрыт по существу. С-1…С-3 из того же файла открыты, остаются остаточным риском (ловец reviewer) и в новом коде не укусили.

# Вердикт reviewer — 193, scoped-исправление Б-1 (PR #1162, head 1ccea8f3c5)

## Итог

**accept.** Индекс вызовов строится с `--full-history` (`scripts/lib_karta_sdachi.sh:171`). Последний FAIL на любой стороне слияния, достижимый из HEAD, теперь попадает в индекс. Дверь листа отказывает «блок К-11» в двух собственных топологиях судьи (второй родитель, octopus). Мутант без флага в обеих даёт ложное зелёное или пустой последний FAIL.

Клетка r57 и стаб `PATERN:REF-BEZ-FULL-HISTORY`:
- r57 зелёная на исправленном дереве;
- r57 красная на production без флага (151/152);
- стаб пойман (59/59).

Регресс зелёный, область правки и авторство соблюдены, фикстура architect прежних клеток и стабов не ослабляет.

## 1. Объект, область правки, авторство

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t3557d2a01/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/193/implementer-b1; git rev-parse FETCH_HEAD → 1ccea8f3c5d83c15befbaef4d8737437a9cb00b2
git switch --detach 1ccea8f3c5…; git rev-parse HEAD → 1ccea8f3c5d83c15befbaef4d8737437a9cb00b2
git rev-parse origin/main → 029a4e0cac3ce8192664314c04acbac1b433c920
git log --format='%h %p %an <%ae>|%cn <%ce>' origin/main..HEAD:
  1ccea8f3c5 5cd7b1032f reviewer <reviewer@dev-harness.local>|reviewer <reviewer@dev-harness.local>
  5cd7b1032f ce6f09f6c0 implementer <implementer@dev-harness.local>|implementer <implementer@dev-harness.local>
  ce6f09f6c0 029a4e0cac architect <architect@dev-harness.local>|architect <architect@dev-harness.local>
git show --stat:
  ce6f09f6c0 (architect): fixtures/workshop_project/sdacha_193/{SDACHA.md,model/scripts/lib_karta_sdachi.sh,probe.py,stabs.tsv}
  5cd7b1032f (implementer): scripts/lib_karta_sdachi.sh (+8/−4)
  1ccea8f3c5 (reviewer): .review/2026-11-20-120.md, verdicts/review/contracts-193-impl-v5.md
```
ЗОНА сверена живой командой с frozen-текстом: `git show frozen/contracts/193/3:contracts/193-svyazka-sdatochnyj-list.md | grep -n ЗОНА`, строки 366–371.
- `ЗОНА architect: contracts/193-svyazka-sdatochnyj-list.md fixtures/workshop_project/sdacha_193/` — четыре пути ce6f09f6c0 ⊆.
- `ЗОНА implementer: … scripts/lib_karta_sdachi.sh …` — путь 5cd7b1032f ⊆.
- `ЗОНА reviewer: verdicts/review/` — `verdicts/review/contracts-193-impl-v5.md` ⊆. `.review/2026-11-20-120.md` — канал ревьюера, суд зон его исключает (`scripts/check_zones.sh:632-638`, `.review/*) return 0`).

Прочее:
- Автор = коммиттер на всех трёх коммитах.
- Атомарность: клетка+стаб, исправление и вердикт — три отдельных коммита, все со ссылкой на 193/Б-1.
- Нормативных документов в диффе нет.
- `git diff --stat origin/main HEAD` → 7 файлов, все перечислены выше. `scripts/pre_critic.sh`, `scripts/freeze_contract.sh`, `scripts/check_sdacha.sh`, `scripts/check_verdict_karta.sh` и чужие семьи не тронуты.
- `scripts/check_zones.sh .` (клон `clone-d`, полный проход истории) за 15+ мин не завершился; частичный вывод снят через `proc://…/streams/1`.
  - 728 строк: `ok` 98, `FAIL` 655.
  - Все 655 FAIL — «дверь минта 031: тег … не аннотированный» на orchestrator-коммитах `registry/contracts.tsv`. Причина — свойство окружения: в копии и клоне теги лёгкие (`git cat-file -t frozen/contracts/193/3` → `commit`).
  - FAIL иного класса — 0. Строк с ce6f09f6/5cd7b103/1ccea8f3 — 0.
  - Решающая мера зон — ручная сверка выше. В CI на head антиплацебо-джоба ap3 (фикстуры барьера `check_zones`) — success. Шаг CI, гоняющий гейт зон на самом дереве, я не сопоставлял (см. «Не проверено»).

## 2. Неподгонка фикстуры (повестка 4)

```
git diff origin/main HEAD -- fixtures/workshop_project/sdacha_193/probe.py fixtures/workshop_project/sdacha_193/stabs.tsv | grep -E '^-[^-]'
  → одна строка: кортеж префиксов выбора пути (probe.py:1181); новая версия = та же + 'r57-'
grep -cvE '^(#|$)' stabs.tsv: origin/main → 58, HEAD → 59 (+1: PATERN:REF-BEZ-FULL-HISTORY → r57)
```
- Добавлены только:
  - мутация `MUTACII_LIB['PATERN:REF-BEZ-FULL-HISTORY']` (`probe.py:350-351`);
  - клетка `r57-merge-ne-skryvaet-fail` (rc 1, «блок К-11»);
  - построение её мира — ветвь `if name.startswith('r57-')`;
  - привязка `stabs.tsv:118-119`.
- Ожидания и привязки прежних клеток не изменены.
- Модель `model/scripts/lib_karta_sdachi.sh` получила тот же флаг: эталон обязан быть зелёным на r57, иначе `--model` ложно красен.
- Implementer фикстур не касался.
- Мутация стаба — ровно обратная правка исправления: `'--full-history HEAD -- "${put%/*}/"'` → `'HEAD -- "${put%/*}/"'`.

## 3. Б-1 закрыт по существу (повестка 1)

### 3а. Стаб и r57 — своим прогоном

`TMPDIR=/tmp/dev-harness-verify/reviewer193s-v6/tmp-a`, одноразовый клон `clone-a` на OBJECT.
```
red_sdacha_193.sh --stabs → … 193 r57-merge-ne-skryvaet-fail-sdacha KRASNO rc=0 СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)
                            193 PATERN:REF-BEZ-FULL-HISTORY POIMAN
                            ИТОГ 193: rc=0 OBMANOK=59 POIMANY=59 ZHIVYH=0      rc=0  173 с
red_sdacha_193.sh --repo . → 193 r57-merge-ne-skryvaet-fail-sdacha ok rc=1 ОТКАЗ: блок К-11 предыдущего вердикта не закрыт в «## Дельта»
```
Красное-до своей мерой. Клон `mutant`: OBJECT, в котором production `scripts/lib_karta_sdachi.sh:171` без `--full-history`; `git diff --stat` → 1 файл, 1+/1−.
```
(clone-a) bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --repo /tmp/dev-harness-verify/reviewer193s-v6/mutant
  193 r57-merge-ne-skryvaet-fail-sdacha KRASNO rc=0 СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)
  ИТОГ 193: rc=1 KLETKI=152 ZELENYE=151 KRASNYE=1        rc=1  46 с
```
Единственная красная клетка — r57: барьер различает ровно этот флаг.

### 3б. Свои независимые миры (не из probe.py)

Скрипты: `/tmp/dev-harness-verify/reviewer193s-v6/{world.sh,door_p2.sh,amb.sh}`. Мутант lib: `…/mut/lib_karta_sdachi.sh`, собран `python3` с `assert s.count(...)==1`. `diff` с production — ровно строка 171.

**Топология p2** (отличие от r57: там каталог равен первому родителю, FAIL удалён на своей ветке):
- база с accept 03;
- первый родитель A несёт FAIL 04 (`К-11: блок`) на вершине;
- второй родитель B — посторонний коммит;
- `merge --no-ff --no-commit b` + `git rm c04.md` при разрешении.

Каталог HEAD равен `HEAD^2` и отличен от `HEAD^1`; проверено `rev-parse HEAD:dir`.

**Топология octo**: octopus-слияние трёх ветвей. FAIL 04 закоммичен и удалён в средней ветке x; каталог HEAD равен `HEAD^1`.

```
библиотека (world.sh: karta_poslednij_fail / K193_POSLED_FAIL):
  fixed  p2   → rc=0 POSLED_FAIL=4  «К-11	блок»
  mutant p2   → rc=0 POSLED_FAIL=   «К-11 нет в выводе (последний FAIL не найден)»
  fixed  octo → rc=0 POSLED_FAIL=4  «К-11	блок»
  mutant octo → rc=0 POSLED_FAIL=   «К-11 нет в выводе»
дверь листа end-to-end (door_p2.sh; check_sdacha.sh + lib из дерева; контракт/лист — mir/kontrakt_chestnyj.md, mir/sdacha_chestnaja.md):
  OBJECT : dir==^2: yes; dir==^1: no; FAIL 04 достижим из HEAD: 1
           ОТКАЗ: блок К-11 предыдущего вердикта не закрыт в «## Дельта»      door rc=1
  MUTANT : dir==^2: yes; dir==^1: no; FAIL 04 достижим из HEAD: 1
           СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=0)                 door rc=0   ← ложное зелёное
```

### 3г. Два других следствия Б-1 (из Rev193Impl) — свой зонд `amb.sh`

Предъявлен accept 04 с `К-02: без изменений с вызова 03.`. Ветка A влита `merge --no-ff`; каталог HEAD равен первому родителю.
- **amb**: вызов 03 есть на main, а на A закоммичен и удалён ДРУГОЙ блоб вызова 03.
- **ref**: вызов 03 (`К-02: блок`) существует ТОЛЬКО на A, закоммичен и удалён.
```
fixed  amb: rc=1 неоднозначный вызов 3        mutant amb: rc=0 К-02	чисто                  ← неоднозначность скрыта
fixed  ref: rc=0 К-02	блок                    mutant ref: rc=1 отсутствует вызов 3 (К-02)     ← ложный отказ
```
Исправление закрывает все три проявления Б-1: последний FAIL, неоднозначность, источник ссылки.

### 3в. Утверждение комментария `:164-170` своей мерой

Комментарий: «состав — тот же, что и поход по коммитам с ls-tree». Проверено на реальной истории OBJECT. Каталог `verdicts/critic/`, уникальные блобы `.md`:
```
rev-list --objects HEAD -- verdicts/critic/                         → 939
rev-list --objects --full-history HEAD -- verdicts/critic/          → 940
ls-tree -r по КАЖДОМУ коммиту `rev-list HEAD` (без path-упрощения)  → 940
comm -3 (full-history ↔ исчерпывающий обход)                        → 0 расхождений
```
Утверждение верно. Прежний пропуск одного реального блоба (302fe74d2e, Rev193Impl) закрыт.

## 4. Зависимый регресс (повестка 2)

Каждый прогон — в своём одноразовом клоне OBJECT со своим TMPDIR под `/tmp/dev-harness-verify/reviewer193s-v6/`.
```
red_sdacha_193.sh --repo .  → ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0   rc=0  47 с
red_sdacha_193.sh --model   → ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0   rc=0  46 с
red_sdacha_193.sh --stabs   → ИТОГ 193: rc=0 OBMANOK=59 POIMANY=59 ZHIVYH=0     rc=0  173 с
bash scripts/check_sdacha.sh . contracts/193-svyazka-sdatochnyj-list.md --run → СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=3)   rc=0  500 с
bash scripts/pre_critic.sh --repo . contracts/193-svyazka-sdatochnyj-list.md → «ok модель угроз красна / ok потолки красны / ok проводка красна / КРИТИК: дверь зелёная / ok сдаточный лист красен»   rc=0  513 с
bash scripts/check_provodka.sh . contracts/193-svyazka-sdatochnyj-list.md → (пустой вывод)   rc=0
```
Своя мера чисел — подсчёт строк логов, а не ИТОГ:
- `bat--repo.log`: строк `^193 .* ok rc=` 152, ` KRASNO ` 0, r57 1;
- `bat--model.log`: то же, 152/0/1;
- `bat--stabs.log`: ` POIMAN$` 59, `ZHIV ` 0.

Scoped-регресс (клон `clone-d`):
```
bash scripts/scope_select.sh . --scope check_sdacha check_verdict_karta pre_critic freeze_contract → MODE: scoped, KEY ×4, rc 0
bash scripts/verify_antiplacebo.sh --scope check_sdacha check_verdict_karta pre_critic freeze_contract → rc 1, 30 с
  FAIL check_sdacha.sh: нет фикстур — ожидается fixtures/check_sdacha/case_*.sh
  FAIL check_verdict_karta.sh: нет фикстур — ожидается fixtures/check_verdict_karta/case_*.sh
  барьеров: 4 · фикстур: 17 · предъявлено красным повторным прогоном: 17 · расхождений: 2
git ls-tree --name-only {origin/main,HEAD} fixtures/check_sdacha fixtures/check_verdict_karta | wc -l → 0 / 0
```
Оба FAIL предсуществуют: каталогов case-фикстур нет ни на origin/main, ни на OBJECT; барьер этих дверей — семья sdacha_193. Дельта диффа — 0, 17 фикстур freeze/pre_critic зелёные. Тот же итог был у Rev193Impl на a065dc05b0.

CI на head (`gh api repos/a3ka/dev-harness/commits/1ccea8f3c5…/check-runs`): все джобы `completed success` — ci l1…l7, antiplacebo ap1…ap5, obshchij, legkij, klass, tyazhelyj-itog; `vorota` — skipped.

## 5. Советы прежнего FAIL (С-1…С-3) — статус

Дифф 5cd7b1032f меняет только строку обхода истории и комментарий над ней; логику распознавания не трогает. Поэтому:
- С-1 (`scripts/lib_karta_sdachi.sh:189`, строгое `= FAIL`) — открыт, не укусил;
- С-2 (`:129`, тема строкой) — открыт, не укусил;
- С-3 (`registry/ci-steps.tsv:318`, устаревший комментарий окна; вне диффа) — открыт.

По триажу задания это остаточный риск с ловцом reviewer; accept не блокируют.

## Обязательные строки

ОСТАТОК: НЗ-1 (смысловая достаточность; ловец reviewer при суде реализации) — не укусил: дифф меняет обход истории, смысловых суждений двери не вводит.
ОСТАТОК: НЗ-2 (охват дверей и расположение листа; К-04, ревьюер зон) — не укусил: `SDACHA.md` в зоне architect; пути коммитов ⊆ зон (§1).
ОСТАТОК: НЗ-4 (исторический FAIL вне каталога/темы/СУД; «не исключение для последнего FAIL и источников И5») — не укусил, Б-1 закрыт: `scripts/lib_karta_sdachi.sh:171`, §3б–3в.
ОСТАТОК: НЗ-5 (полнота мутаций и сговор субъекта с батареей; ловец reviewer) — не укусил: мир со слиянием добавлен клеткой r57 и стабом. Сговора нет: фикстуру менял architect, а implementer её не касался; прежние ожидания не ослаблены (§2). Универсальная полнота не заявляется: свои топологии p2/octo в батарее отсутствуют, но тот же флаг ловится r57.
ОСТАТОК: НЗ-7 (одновременная правка двери и lib под конкретный вход) — не укусил: правка lib общая (флаг обхода), дверь не менялась, вход r57 исправлением не упомянут.

ПРОВОДКА: guard — `fixtures/workshop_project/sdacha_193/red_sdacha_193.sh`, CI-шаг `check:sdacha-193-family-selftest` (`registry/ci-steps.tsv:319`: `--repo .`, `--model`, `--stabs`). Новая клетка r57 исполняется тем же шагом без правки проводки. `check_provodka.sh . contracts/193-…` → rc 0. ПРОВОДКА-ЭНФОРСМЕНТ прежняя (чистый энфорсмент, норм ролей дифф не вводит).

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа:
- флаг `--full-history` (`scripts/lib_karta_sdachi.sh:171`):
  - (1) И5, источники «достижимой из HEAD истории», последний FAIL;
  - (2) нового состояния нет;
  - (3) 1 файл production + модель-эталон (2, как у любой правки lib семьи 191), число не выросло;
  - (4) интерфейс karta_index не изменился;
  - (5) потребители — обе двери, r57.
  ESSENTIAL.
- клетка r57 с веткой построения мира (`probe.py`):
  - (1) И5/НЗ-4;
  - (2) мир в mktemp, явный;
  - (3) 1;
  - (4) —;
  - (5) потребитель — CI-шаг 193; грамматику клеток не дублирует.
  ESSENTIAL.
- стаб `PATERN:REF-BEZ-FULL-HISTORY` (`probe.py:350-351`, `stabs.tsv:119`): существующий формат PATERN, потребитель `--stabs`. ESSENTIAL.
- раздел `SDACHA.md` «Мир со слиянием»: замер пачки (норма листа сдачи). ESSENTIAL.

СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции документ архитектуры и стандарт кода не объявляет: `grep -n -iE 'ARCHITECTURE|CODING-STANDARDS|bindings.json' AGENTS.md` → пусто, rc 1; `ls docs/ARCHITECTURE.md docs/CODING-STANDARDS.md` → нет файлов.

СВЕРКА-АРХИТЕКТУРЫ:
- размещение — правка в единой библиотеке грамматики (И7), второго разбора нет; соответствует;
- зависимости — только git plumbing, новых нет;
- писатели — двери ничего не пишут (клетки r10–r13 и снимок `posle` r57 зелёные);
- операции — чтение;
- `bindings.json` и `tooling/checks/cli.js` в дереве отсутствуют (`ls` → нет): модели 188 нет, L-уровень н/п;
- долг не расширен.

## Не проверено

- Полный CI своим прогоном (по заданию). Статус CI взят через `gh api check-runs`, логи джобов не читались.
- Регресс замороженных семей п.7 (`_krasnye_103.sh`, 191/192/189/190) не прогонялся: их файлы в диффе не менялись. [INFERENCE] Изменённый флаг обхода исполняется ими через дверь, но правка только расширяет набор источников до полного достижимого.
- Производительность `--full-history` на реальном дереве отдельно не мерилась. Косвенно: `check_sdacha --run` и `pre_critic` на реальном дереве уложились во время, указанное в §4.
- Завершённый rc `check_zones.sh .` на дереве OBJECT: прогон не дождался конца, частичный вывод — в §1.
- `.judge-scratch/` не создавался; все черновики, клоны и логи лежат под `/tmp/dev-harness-verify/reviewer193s-v6/`.

## Исправленные ошибки своих команд

1. Первый вызов `bash` (`export TMPDIR=…-$$ && mkdir …`) без `cwd` отклонён стражем: «запись относительным путём без cwd запрещена — Н-85». Исправлено: явный каталог `/tmp/dev-harness-verify/reviewer193s-v6` и `cwd`.
2. Цикл `git clone … && … ; sed -n … | grep` вернул rc 1 из-за пустого grep по шапке `verify_antiplacebo.sh`. Клоны созданы (rev-parse OBJECT ×3); usage прочитан через grep-инструмент.
3. Первый `check_zones.sh` снят моим таймаутом инструмента 300 с. Повтор — с таймаутом 2400 с (§1).
4. Первый `check_provodka.sh .` без пути контракта → «использование: scripts/check_provodka.sh <корень-дерева> <отн-путь-контракта>», rc 1 (ошибка формы вызова). Повтор с контрактом — rc 0 (§4).
5. `scope_select.sh . --changed origin/main` в клоне дал `MODE: full`, потому что `origin/main` клона — ветка копии судьи. Scoped-регресс прогнан явными ключами `--scope` (§4).
