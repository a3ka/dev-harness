FAIL

# Вердикт reviewer: контракт 086 (frozen/contracts/086/1), круг 6

Предмет: main @ `1a72b555a5dfbc13ad1c21baa02ac4fc2e49eca6` (ленд `wip/086/implementer` ← `d769fe0` implementer
круг 9, П1–П5 по `verdicts/arbitration/086-gejty-svedenija-krug5.md`). Судьи на текущем main (`42c1fc7`) с
`1a72b55` не менялись (`git diff --quiet 1a72b55 HEAD -- scripts/check_charter.sh scripts/check_zones.sh
'contracts/086-*'` → rc 0). Закрытие судится ссылкой на вердикт арбитра круга 5: причины П1–П5 не открываются,
несоответствие предъявлено ссылкой на его столбец PROBE (З3) и маршрут п.1–6.

Клон `/tmp/dev-harness-verify/r086k6/repo`, worktree «ДО» — `…/pre086` @ `64ac67b`, «круг 5» — `…/at2e` @ `2e23370`.
Пробы throwaway, собственные (не пробы арбитра): `probe6.sh` (13 строк З3), `probe_corrupt.sh` (настоящий git, без
spy), `run_long.sh` (А8 и guard), `p1cmp.sh`. Удалены вместе с клоном.

Итог: П1, П2, П3, П4 закрыты по букве арбитра. **П5 не закрыт**: строка F2 столбца PROBE (rc 2 «rev-list --count
отказал (rc=127)») на HEAD даёт rc 127 без сообщения и без маркера; то же у обоих судей на настоящем git с rc 128.
Заявление коммита «Все 13 строк исходов достигаются» ложно в этой строке (п. 7).

## 1. З3 — своя мера против столбца PROBE (`probe6.sh`, три дерева)

Миры по З3: `vacuum`, `frozen-nord`, `none`, `ustav`, `frozen`; F2 — `ustav` с честным не-уставным коммитом в окне
(честный `rev-list --count` = 1). PATH-spy `git` → 127 на названной подкоманде (и аргументе). Вывод HEAD дословно
(sha маркера заменён на `<sha>`):

```text
HEAD | vacuum --okno HEAD~1                       | rc=0 marker=1 | уставных документов: 0 · изменений в них: 0 · с разр
HEAD |   маркер: окно 086: <sha>..HEAD (1 коммит.)
HEAD | vacuum --okno <нет коммита>                | rc=2 marker=0 | ОТКАЗ 086: --okno: коммита нет: fedcba98…
HEAD | frozen-nord --okno HEAD~1                  | rc=0 marker=1 | уставных документов: 1 · изменений в них: 0 · с разр
HEAD |   маркер: окно 086: <sha>..HEAD (1 коммит.)
HEAD | frozen-nord --okno <нет коммита>           | rc=2 marker=0 | ОТКАЗ 086: --okno: коммита нет: fedcba98…
HEAD | none --okno HEAD~1                         | rc=2 marker=0 | NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 посл
HEAD | none --okno <нет коммита>                  | rc=2 marker=0 | NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 посл
HEAD | ustav --okno HEAD~1                        | rc=1 marker=1 |   FAIL уставной документ изменён без разрешения вла
HEAD |   маркер: окно 086: <sha>..HEAD (1 коммит.)
HEAD | ustav --okno <нет коммита>                 | rc=2 marker=0 | ОТКАЗ 086: --okno: коммита нет: fedcba98…
HEAD | ustav clone --no-tags --okno HEAD~1        | rc=2 marker=0 | NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 посл
HEAD | frozen-nord clone --no-tags --okno HEAD~1  | rc=1 marker=0 | ОТКАЗ: реестр устава (refs/tags/frozen/*) недоступен: missing-r
HEAD | frozen spy=for-each-ref --okno HEAD~1      | rc=2 marker=0 | NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 посл
HEAD | ustav spy=rev-list БЕЗ --okno              | rc=0 marker=0 | уставных документов: 1 · изменений в них: 0 · с разр
HEAD | ustav spy=no БЕЗ --okno                    | rc=1 marker=0 |   FAIL уставной документ изменён без разрешения вла
HEAD | F2 honest count=1
HEAD | F2 ustav spy=rev-list:--count --okno       | rc=127 marker=0 |
HEAD | F2 check_zones spy=rev-list:--count --okno | rc=0 marker=1 | замороженных контрактов: 0 · зон не объявлено — п…
HEAD |   маркер: окно 086: <sha>..HEAD (1 коммит.)
HEAD | F2 spy=no --okno                           | rc=0 marker=1 | уставных документов: 1 · изменений в них: 0 · с разр
```

| Вход З3 | pre086 (своя) | 2e23370 (своя) | PROBE арбитра | HEAD 1a72b55 (своя) | Исход |
|---|---|---|---|---|---|
| vacuum `--okno HEAD~1` | rc 2 skip | rc 0, маркер 0 | rc 0, маркер 1, «0 документов» | rc 0, маркер 1, «уставных документов: 0» | = |
| vacuum `<нет коммита>` | rc 2 | rc 0 | rc 2 «коммита нет» | rc 2 «коммита нет» | = |
| frozen-nord `HEAD~1` | rc 2 | rc 2 skip | rc 0, маркер 1, «1 документ» | rc 0, маркер 1, «уставных документов: 1» | = |
| frozen-nord `<нет коммита>` | rc 2 | rc 2 skip | rc 2 «коммита нет» | rc 2 «коммита нет» | = |
| none `HEAD~1` / `<нет коммита>` | 2 / 2 | 0 / 0 | rc 2 skip / rc 2 skip | rc 2 skip / rc 2 skip | = |
| ustav `HEAD~1` / `<нет коммита>` | 1 / 1 | 1 м1 / 2 | rc 1 м1 / rc 2 «коммита нет» | rc 1 м1 / rc 2 «коммита нет» | = |
| ustav `clone --no-tags` | rc 2 | rc 0 | rc 2 skip | rc 2 skip | = |
| frozen-nord `clone --no-tags` | rc 2 | rc 0 | rc 1 «реестр … недоступен» | rc 1 «реестр устава (refs/tags/frozen/*) недоступен: missing-remote» | = |
| frozen spy `for-each-ref` | rc 2 | rc 0 | rc 2 skip | rc 2 skip | = |
| ustav spy `rev-list` БЕЗ `--okno` | rc 0 | rc 2 «--okno: rev-list отказал» | rc 0 (как pre086) | rc 0 «изменений в них: 0» | = |
| ustav spy=no БЕЗ `--okno` | rc 1 | rc 1 | rc 1 FAIL | rc 1 FAIL | = |
| **F2**: ustav, spy `rev-list --count` | rc 0 (нет ветви) | rc 0, «(0 коммит.)» | **rc 2 «rev-list --count отказал (rc=127)»** | **rc 127, вывода нет, маркера нет** | **≠ — Б-7** |
| F2 в check_zones (тот же spy) | rc 0 | rc 0, «(1 коммит.)» | маркер «(1 коммит.)», rc 0 | rc 0, «(1 коммит.)» | = |

12 строк из 13 совпадают с PROBE побайтово по исходу; красное против 2e23370 предъявлено в 7 из них (vacuum ×2,
frozen-nord ×2, none ×2, ustav `--no-tags`, frozen-nord `--no-tags`, spy `for-each-ref`, spy `rev-list` без `--okno`,
F2 — столбец 2e23370 расходится с HEAD).

## 2. Сверка П1–П5 с маршрутом арбитра

| П | Маршрут арбитра | Своя мера | Исход |
|---|---|---|---|
| П1 | отзыв в теле коммита круга 9 «формулировкой П1»; пары 17/18 не трогать | `p1cmp`/python: строка `Б-1:` тела `d769fe0` = цитата арбитра (П1, «строка вида «Б-1: …»») после нормализации пробелов и снятия обратных кавычек — `equal_mod_period: True` (отличие — финальная точка). `git show d769fe0 \| grep -c '^[-+].*\(6609f708\|797a3129\)'` → 0; `git grep -c` на 1a72b55 → 4 (пары на месте). | закрыт |
| П2 | `skip` прежние две строки в ветви `[ -z "$OKNO_BASE" ]`; в `else` — skip только при `AGENTS.md`/`ROADMAP.md` на HEAD; порядок `registry_state` → `cat-file`/маркер прежний | `git diff 64ac67b 1a72b55` вне комментариев: прежние две строки skip — в `if [ -z "$OKNO_BASE" ]` (сдвиг отступа на 2), `else` — цикл `for f in AGENTS.md ROADMAP.md` с `cat-file -e "HEAD:$f"`; `registry_state` (цикл `for prefix`) и блок `cat-file`/маркер — ниже, в прежнем порядке. З3-строки vacuum/frozen-nord/none/`--no-tags`/spy `for-each-ref` = PROBE. | закрыт |
| П3 | страж `:378-391` удалить целиком | дифф `d769fe0`: 15 строк стража (`for-each-ref`, `incr_finish 0`, «в окне проверять нечего») сняты; `git grep -n for-each-ref 1a72b55 -- scripts/check_charter.sh` — 0 вхождений; строки З3 Б-5а/б/в = PROBE. | закрыт |
| П4 | rc-проверка общего `rev-list "$since..HEAD"` под `[ -n "$OKNO_BASE" ]`; `else` — прежняя строка | `else`-ветвь: `g rev-list "$since..HEAD" > "$TMP/commits" 2>/dev/null \|\| : > "$TMP/commits"` — текстуально строка 64ac67b (отступ +2); строка spy `rev-list` без `--okno`: rc 0 = pre086. | закрыт |
| П5 | `rev-list --count` fail-closed rc 2 в обоих судьях, «ОТКАЗ 086: --okno: rev-list --count отказал (rc=N) — нечем проверить» | строка F2 — rc 127 без вывода (§1); настоящий git — rc 128 у обоих судей без вывода (§3). Ветвь с сообщением недостижима при rc≠0. | **НЕ закрыт — Б-7** |
| п.6 | мера в теле коммита: З3-таблица (PROBE), А8 полностью, battery check_zones, `_krasnye_086.sh` | таблица в теле — столбец «Ожидаемый исход (PROBE)», наблюдённого исхода нет; строка F2 наблюдённой быть не могла (§3). А8/guard/battery — своя мера совпала (§4). | Н-10 |

## 3. Б-7 (блок; П5 арбитража круга 5, И-5 «нечем проверить — rc 2»; `scripts/check_charter.sh:422`, `scripts/check_zones.sh:410`)

Форма круга 9 в обоих судьях: `OKNO_N=$(g rev-list --count "$OKNO_BASE..HEAD" 2>/dev/null); rc=$?`. Оба файла идут
под `set -euo pipefail` (`check_charter.sh:132`, `check_zones.sh:206`), блок — на верхнем уровне. Присваивание с
упавшей подстановкой — простая команда с ненулевым статусом: `set -e` завершает скрипт ДО `rc=$?`. Механизм одной
строкой:

```text
$ bash -c 'set -euo pipefail; x=$(exit 127); rc=$?; echo "after rc=$rc"'; echo "outer=$?"
outer=127
```

Настоящий git, без spy (`probe_corrupt.sh`: ustav-мир из 3 коммитов, база = HEAD~2, loose-объект HEAD~1 удалён;
`cat-file -e base^{commit}` → rc 0, честный `rev-list --count` → rc 128):

```text
2e2  | check_zones   rc=0   | окно 086: f9a23fa2…..HEAD (0 коммит.)|замороженных контрактов: 0 · …
2e2  | check_charter rc=2   | окно 086: f9a23fa2…..HEAD (0 коммит.)|ОТКАЗ 086: --okno: rev-list отказал (rc=128, sinc…
HEAD | check_zones   rc=128 |
HEAD | check_charter rc=128 |
```

Отказ инструмента перестал выдаваться за результат: fail-open «(0 коммит.)» снят, и это улучшение. Но исход ≠ PROBE
(rc 2 с именованным отказом). Потребитель видит другое: гейт (`gejt_svedenija.sh:343-358`, `:364-377`, чтение кода)
сводит rc ∉ {0,1,2} к `exit 1` «вернул неожиданный rc», а не к rc 2 «нечем проверить» (П1 круга 3 п.3). Ветвь
`if [ "$rc" -ne 0 ] || ! [[ "$OKNO_N" =~ ^[0-9]+$ ]]` с сообщением в обоих судьях достижима только при rc 0 с нечисловым
выводом. Заявление тела `d769fe0` «Все 13 строк исходов достигаются теми же тремя ханками» ложно в строке F2 (п. 7).

Происхождение формы. Текст П5 арбитра — «захват rc (`cmd; rc=$?`, не `|| OKNO_N=0`)»; implementer исполнил его
буквально. Пробная форма арбитра, давшая столбец PROBE, другая: `OKNO_N=$(…) || rc=$?`
(`/tmp/dev-harness-verify/arb086k5/patch_probe.py:35`). Обязательна мера маршрута п.6 — «ожидаемые исходы — столбец
PROBE З3». Ей отвечает только форма пробы. Причина П5 не переоткрывается. Предъявлено расхождение исхода со
столбцом PROBE. Более простая форма, проходящая ту же строку, уже есть в том же файле двумя экранами ниже
(`check_charter.sh:489-490`): `rc=0; OKNO_N=$(g rev-list --count …) || rc=$?`. Она нужна в обоих судьях.

Барьер 086 этого пути не покрывает. `fixtures/_krasnye_086.sh` зелёный на 1a72b55 (§4), хотя П5 не исполнен; та же
картина была на 2e23370 при открытой F2. Это продолжение Н-6, клетка «`rev-list --count` отказал → rc 2», адресат
architect.

## 4. Батарея — своя мера

`run_long.sh a8` на 1a72b55 → `A8_RC=1 elapsed=92s`:

```text
  FAIL check_charter/case_zloj_lend_bez_stroki_krasnyj.sh: барьер остался зелёным на обманном дереве — красное не предъявлено
  FAIL spawn_agent/case_bez_identichnosti.sh: нет положительного контроля — …
  FAIL spawn_agent/case_octal_sdvig_znachenija.sh: нет положительного контроля — …
барьеров: 5 · фикстур: 73 · предъявлено красным повторным прогоном: 70
расхождений: 3 · прогон оставлен в /tmp/verify_antiplacebo-9f862262/run-292770
```

Счёт проверен второй мерой, не повтором той же команды:
- строки `ok`/`FAIL` в выводе по барьерам: ok — check_zones 38, check_charter 12, check_hooks 11, land_agent 9 (всего 70); FAIL — check_charter 1, spawn_agent 2 (всего 3);
- файлы `case_*.sh` на диске: 38 + 13 + 9 + 2 + 11 = 73;
- итог: 70/73, расхождений ровно 3. Land_agent 9/9 зелёны, это закрывает Б-4 в части land_agent.

`case_zloj_lend` в форме П2 арбитража. Прямой прогон фикстуры (`BARRIER=…/check_charter.sh`, `REPO` = клон) даёт
`fixture_rc=1` со строкой `ОТКАЗ 086 (land): правило (в) устав-путь без строки РАЗРЕШИЛ; выход: …`. Это ожидаемая
красная строка по П2 арбитра, а не регресс. Иных красных строк в `--scope check_charter` и `land_agent` нет. По П2
итог А8 засчитывается как «равно ДО».

Строки приёмки (`run_long.sh acc`): `red_accept_task_commit.sh` rc 0 «прогнано 7, красных 0, зелёных 7»;
`red_porjadok_diapazona_068.sh` rc 0 «красных 0, зелёных 6, не построено 0»; `run_battery.sh accept_task_commit` rc 0 4/4;
`run_battery.sh check_zones` rc 0 4/4. В stderr прежний Н-9 `profiles/check_zones.sh: line 156: 088: value too great
for base` (вне 086).

Guard `fixtures/_krasnye_086.sh` полный: `KR_RC=0 elapsed=112s`, «стаб-пак 086: 13/13 поймано, диффпроба 13/13»,
«ИТОГ 086 (polnyj): rc=0», «БАТАРЕЯ gejt_svedenija: итог 4/4». Счёт второй мерой:
- уникальные `ЗЕЛЕНО: <клетка>` — 28: A1–A6, H1–H3, L1–L7, L2b, R1–R9, S0, S1;
- строки `^стаб sN: пойман` — 13.

Совпадает с телом коммита.

## 5. Область правки, атомарность, норма, identity

- Область: `d769fe0` и ленд `1a72b55` (`git diff --stat 1a72b55^1 1a72b55`) — только `scripts/check_charter.sh` (+33/−23) и `scripts/check_zones.sh` (+5/−1). Блобы обоих файлов на 1a72b55 равны блобам d769fe0. Это ЗОНА implementer 086, и правки только в `--okno`-ветвях: полный режим check_charter вне комментариев текстуально равен 64ac67b с точностью до отступа двух прежних строк (§2 П2/П4).
- Атомарность: один коммит, одна задача — «маршрут implementer круга 9» (П1–П5 одного вердикта арбитра). Не отказ.
- Норма и контракт: `git diff --quiet frozen/contracts/086/1 1a72b55 -- 'contracts/086-*'` → rc 0. `git diff --stat 2e23370 1a72b55 -- contracts/ roles/ AGENTS.md ROADMAP.md` пуст.
- Проверки не переписаны: implementer в `fixtures/` не коммитил, дифф не трогает ни одной фикстуры.
- Identity: author и committer `d769fe0` — `implementer <implementer@dev-harness.local>`, ленд — `orchestrator`, родители `500ce56` и `d769fe0`.

## 6. ПРОВОДКА (контракт 038)

`scripts/check_provodka.sh . contracts/086-*.md` → rc 1 «проводка: guard не подключён: fixtures/_krasnye_086.sh не
вызывается в .githooks/ или .github/workflows/». П-1 без изменений, адресат оркестратор, блокирует done.

## 7. Паразитная сложность (контракт 050) — артефакты диффа d769fe0

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| ветвь `else` с `for f in AGENTS.md ROADMAP.md` + `cat-file -e "HEAD:$f"` (`check_charter.sh:388-394`, цикл `:389`) | А8 land_agent ×9 и accept-строки; И-5 судимое множество | нет; исход в выводе (skip / «уставных документов: N») | 2 места имён (`:389` и цикл пар `:439`) — было 1; арбитр разрешил не выносить в переменную | без флагов и env | А8 первая строка (land_agent 9/9); список имён повторяет цикл пар — форма П2 арбитра | ESSENTIAL |
| снятие стража r8 (−15) | — | убирает `incr_finish 0` побочным выходом | −1 ветвь | интерфейс сузился | — | снимает ACCIDENTAL круга 5 |
| `if [ -n "$OKNO_BASE" ] … else <прежняя строка>` вокруг `rev-list "$since..HEAD"` | И-5 «без --okno побайтово прежнее» + fail-closed `--okno` | нет | 1 | без флагов | строки З3 spy `rev-list` с `--okno`/без | ESSENTIAL |
| захват rc `rev-list --count` ×2 (`check_charter.sh:422-426`, `check_zones.sh:410-414`) | И-5, П5 | нет | 2, по копии на судью; так велит арбитр | без флагов | строка F2 PROBE | свойство ESSENTIAL; форма неисполнима под `set -e` — Б-7 (дефект, не 050) |

## 8. Находки (reslop; `.review/` вне ЗОНА reviewer — материализует оркестратор, как `500ce56`)

```markdown
---
status: ready
subject: contracts/086 (frozen/contracts/086/1), main @ 1a72b555a5dfbc13ad1c21baa02ac4fc2e49eca6 (ленд ← d769fe0 implementer круг 9)
verdict: verdicts/review/contracts-086-v5.md (FAIL, круг 6)
reviewer: reviewer
prev: .review/2026-10-07-05.md (круг 5, verdicts/review/contracts-086-v4.md)
arbitration: verdicts/arbitration/086-gejty-svedenija-krug5.md
---

## Статус круга 5 по маршруту арбитра
- [x] Б-1 / П1 — отзыв в теле d769fe0 словами арбитра; пары 17/18 не тронуты
- [x] Б-4 / П2 — land_agent 9/9; А8 70/73, расхождений 3 (2 spawn + zloj_lend, форма П2), прямой прогон zloj_lend: правило (в)
- [x] Б-5 / П3 — страж снят; З3 vacuum/--no-tags/spy for-each-ref = PROBE
- [x] Б-6 / П4 — полный режим прежний; spy rev-list без --okno → rc 0
- [ ] F2 / П5 — см. Б-7

## Блокирующие
- [ ] Б-7 (implementer) — `scripts/check_charter.sh:422`, `scripts/check_zones.sh:410`: `OKNO_N=$(…); rc=$?` под `set -euo pipefail` выходит rc 127/128 без сообщения до захвата rc; PROBE F2 требует rc 2 «ОТКАЗ 086: --okno: rev-list --count отказал (rc=N)». Форма: `rc=0; OKNO_N=$(g rev-list --count …) || rc=$?` (как `check_charter.sh:489-490`, patch_probe арбитра :35), в обоих судьях. Мера: F2 spy → rc 2 с сообщением; настоящий git с пропавшим промежуточным объектом → rc 2 у обоих.

## Неблокирующие
- [ ] Н-10 (implementer) — тело d769fe0: «Мера … ожидаемых исходов» — таблица ожидаемых, а не наблюдённых исходов; «Все 13 строк исходов достигаются» ложно в строке F2. В следующем коммите — наблюдённый rc/вывод каждой строки.
- [ ] Н-6 (architect) — клетки под И-5 судей нет: `_krasnye_086.sh` зелёный при неисполненном П5 (1a72b55) и открытой F2 (2e23370); нужна клетка «rev-list --count отказал → rc 2».
- [ ] Н-11 (арбитр/оркестратор) — текст П5 «`cmd; rc=$?`» несовместим с `set -e` судей; пробная форма арбитра — `|| rc=$?`. На будущее: в маршруте давать форму, совпадающую с пробой.
- [ ] Н-9 (оркестратор) — `profiles/check_zones.sh:156` «088: value too great for base», вне 086.
- [ ] П-1 (оркестратор) — ПРОВОДКА: guard не подключён (check_provodka rc 1).
```

## 9. Что дальше

Б-7 передаётся implementer, это зона implementer, правка — две строки в двух `--okno`-ветвях. Арбитра это не требует:
находка новая, против формы круга 9, не второй отказ по прежней причине. Н-6 — architect. Н-9, Н-11, П-1 —
оркестратор. Вердикт относится только к блобам `scripts/check_charter.sh` и `scripts/check_zones.sh` на 1a72b55.
