accept

Блокирующих находок нет. Полный список с чекбоксами — `.review/2026-10-13-04.md`.

- **Рв1-1 закрыт.** Писатели создают журнал. Новая клетка `red_zhurnal_sozdaetsja_pisatelem.sh` краснеет на
  откате каждого из трёх писателей по отдельности.
- **Рв1-2 закрыт.** `verdicts/adversary/contracts-098-v3.md` побайтово совпадает с блобом adversary-коммита
  09aeb89b. По существу закрывает A-098-1/A-098-2 теми клетками, которые в нём требуются.
- **Н2-1 закрыта мной в этом круге.** Вердикт круга 1 (основание 17-й клетки) тоже лежал только в /tmp.
  Я материализовал его reviewer-коммитом b9792a22 (блоб = 9246b44c) вместе с `.review/2026-10-13-03.md`.

Неблокирующие Н2-2…Н2-4 и перенесённые Н1-1, Н1-3…Н1-6 — в `.review/2026-10-13-04.md`.

# Reviewer 098, круг 2 (гейт перед слиянием)

- **Предмет.** `frozen/contracts/098/1` → `ff511258`. Блоб контракта `c0ebc559` одинаков на теге и на 7b8e1a85
  (`git rev-parse` обоих путей).
- **Судимый tip.** `origin/wip/098/implementer` @ `7b8e1a858c8759e1181eedf6cc45bbd5797c6b60` (`git ls-remote`
  подтвердил). Поверх cd4fd283e (tip круга 1):
  - `d46cf8b54` adversary/adversary — `verdicts/adversary/contracts-098-v3.md`;
  - `608f58a5b` architect — клетка, модели, стабы s20/s21, раннер 16→17, А-418;
  - `2256b1abe` implementer — писатели создают журнал;
  - `7b8e1a858` orchestrator — merge 2256b1ab + 608f58a5.
- **Клон.** Одноразовый SSH-клон `/tmp/dev-harness-verify/rv098c2-k4p7/r`. Worktree `…/impl` = 2256b1abe.
  Мутант-скрипты — `…/mut.sh` и `…/bezflag.sh`.

## 1. Область правки (зоны) — ПРОЙДЕНО

`git diff --stat cd4fd283e 7b8e1a858` → 9 файлов. Зоны — из `frozen/contracts/098/1^{commit}:contracts/098-…md:99-104`.

| коммит | автор/коммиттер | файлы | зона |
|---|---|---|---|
| d46cf8b54 | adversary/adversary | verdicts/adversary/contracts-098-v3.md | вердикт адверсария (вне зон 098) ✓ |
| 608f58a5b | architect/architect | NABLIUDENIA_ARCHITECT.md, fixtures/_krasnye_098.sh, fixtures/dokazatelstva_098/{battery_stubs.sh, model/check_ci_gate.sh, model/judge_gate.sh, red_zhurnal_sozdaetsja_pisatelem.sh} | architect ✓ |
| 2256b1abe | implementer/implementer | scripts/check_ci_gate.sh, scripts/judge_gate.sh | implementer ✓ (ПЕРЕСЕЧЕНИЕ 087/008 :101-102) |
| 7b8e1a858 | orchestrator/orchestrator | merge | см. ниже |

- **Merge не несёт контента.** `git merge-tree --write-tree 2256b1abe 608f58a5b` → `17056d6d…`, и
  `git rev-parse 7b8e1a858^{tree}` → `17056d6d…`. Деревья совпадают, ручной правки в merge нет.
- **Своя мера механизмом.** `bash scripts/check_zones.sh .` на 7b8e1a85 → `замороженных контрактов: 94 · …
  проверено по зонам: 2587`, RC=0. На круге 1 было 2560.
- **Норма не тронута.** `contracts/ plans/ roles/ AGENTS.md docs/` в диффе — 0 файлов.
- **Проверка не подогнана под реализацию.** Implementer (2256b1ab) не трогал `fixtures/`, architect
  (608f58a5) — `scripts/`.

## 2. Батарея — ПРОЙДЕНО

`bash fixtures/_krasnye_098.sh` на 7b8e1a85 (выдержка):

```
— стаб s20 ПОЙМАН клеткой red_zhurnal_sozdaetsja_pisatelem.sh
— стаб s21 ПОЙМАН клеткой red_zhurnal_sozdaetsja_pisatelem.sh
ИТОГ стаб-пак 098: rc=0
— battery_stubs.sh: rc=0
— red_zhurnal_sozdaetsja_pisatelem.sh: rc=0
— red_zhurnal_vne_vetvi.sh: rc=0
ИТОГ 098: rc=0
RC=0
```

Своя мера, другими командами:
- `grep -cE '^— red_.*: rc=0$'` по выводу раннера = **17**;
- `ls fixtures/dokazatelstva_098/red_*.sh | wc -l` = **17**;
- `grep -oE '^zapest s[0-9]+' battery_stubs.sh | sort -u | wc -l` = **21**, и в выводе 21 уникальная строка
  «ПОЙМАН» (s1…s21);
- `--model`: `ИТОГ стаб-пак 098: rc=0`, `ИТОГ 098: rc=0`, MODEL_RC=0, rc=0/ПОЙМАН-строк 41 = 21 + 1 + 17 + 2.

Заявления авторов, сверенные своей мерой:
- implementer (2256b1ab, «16/16 клеток + 19/19 стабов»): worktree 2256b1abe → `stubs_caught=19 cells_rc0=16`, RC=0. ✓
- task-file оркестратора («17/17, 21/21, check_zones rc 0»): ✓, см. выше.

## 3. Живой мутант Рв1-1 — ПРОЙДЕНО

`mut.sh` построчно возвращает фикс-строку 2256b1ab к `[ -f "$JOURNAL" ] || die "журнал: нет файла: $JOURNAL"`.
После каждого шага — `git checkout -- scripts/ && git diff --quiet` («restored: diff clean»).

```
=== M0 без мутанта
CELL_RC=0
mutated scripts/check_ci_gate.sh lines [92] of fix-lines [92]
=== MJ1 check_ci_gate --check-row откат
ОТКАЗ: журнал: нет файла: …/prinyato/registry/candidates.tsv
КРАСНО: zhurnal-sozdaetsja: check-row отказал на отсутствующем журнале (журнал создаётся писателями)
CELL_RC=1
mutated scripts/judge_gate.sh lines [86] of fix-lines [86, 103]
=== MJ2 judge_gate --verdict-row откат
КРАСНО: zhurnal-sozdaetsja: verdict-row отказал на отсутствующем журнале (журнал создаётся писателями)
CELL_RC=1
mutated scripts/judge_gate.sh lines [103] of fix-lines [86, 103]
=== MJ3 judge_gate --policy-row откат
КРАСНО: zhurnal-sozdaetsja: policy-row отказал на отсутствующем журнале (журнал создаётся писателями)
CELL_RC=1
=== MJall полный откат 2256b1ab (cell)            → три КРАСНО, CELL_RC=1
=== MJall полный раннер
ИТОГ стаб-пак 098: rc=0
— red_zhurnal_sozdaetsja_pisatelem.sh: rc=1
ИТОГ 098: rc=1
RUNNER_RC=1
```

- **Клетка ловит регресс.** Каждый писатель отдельно красит её своим предъявлением. Полный откат красит
  раннер ровно этой клеткой, остальные 16 зелёные — то есть до клетки батарея была слепа (Рв1-1 воспроизведён).
- **Мутант-соседа (MT).** `check_ci_gate.sh:92` → безусловное `: >"$JOURNAL"` (усечение, нарушение
  append-only). Раннер rc 1, красны 15 клеток. Новая клетка зелёная: она снимает журнал сама, так что
  append-only держат остальные.
- **Живая проба п.4(а) на клоне** (журнала нет): `judge_gate.sh <S> --verdict-row T-probe <OID> vf.md` →
  `verdict-строка записана …`, verdict_rc=0. `cat -A` →
  `verdict^IT-probe^I2d7116…^Iaccept^I1$`. На круге 1 тот же вызов давал rc 1 «журнал: нет файла».

## 4. verdicts/adversary/contracts-098-v3.md — СООТВЕТСТВУЕТ

- **Происхождение.** `git rev-parse 09aeb89b:verdicts/adversary/contracts-098-v1.md HEAD:verdicts/adversary/contracts-098-v3.md`
  → оба `cc5865003697b023a2bbd5666da1e1399ed6bc31`.
  - 09aeb89b: автор adversary, родитель 418b437c (бандл `adversary-098-09aeb89b.bundle`).
  - Слот `contracts-098-v1.md` (круг 1, до заморозки) не тронут.
- **A-098-1.** Вердикт требует ответ endpoint для M с доверенным зелёным `ci-a` на `head_sha=B`, rc 1,
  отсутствие строки check, неизменный target; парный честный `head_sha=M` пишет строку и публикует.
  - Это делает `red_chuzhoj_head_sha.sh` (431d2397). Круг 1 проверил это прочтением и мутантами M1/M4 на
    производственной строке `check_ci_gate.sh` (`[ "$hsha" = "$MSHA" ] || die`).
  - Клетка и строка с 431d2397 не менялись: `git diff cd4fd283e 7b8e1a858 -- fixtures/dokazatelstva_098/red_chuzhoj_head_sha.sh`
    пуст, `scripts/check_ci_gate.sh` изменён только в ветви журнала (п.3).
  - На 7b8e1a85 клетка rc 0, стаб s18 ПОЙМАН ею.
- **A-098-2.** Вердикт требует полный журнал + конформную `published` при target=B, rc 1 «публикация
  расползлась: ref != merge», без ложного «УЖЕ ОПУБЛИКОВАНО»; парный target=M даёт «УЖЕ ОПУБЛИКОВАНО».
  - Это `red_ustarevshaja_published.sh`. Круг 1 — мутанты M2/M3. `accept_publish.sh` с cd4fd283e не тронут
    (в диффе его нет).
  - На 7b8e1a85 клетка rc 0, s19 ПОЙМАН ею.
- **Контроли без блоков** (red_chuzhoj_accept, чужой verdict-row, одноимённый workflow, s1…s17) — все клетки
  на месте и зелёные.

## 5. Семантика 4б/087 и 008 без флага — СОХРАНЕНА (та же, что в круге 1)

`bezflag.sh`. `U=44255110…` — незапушенный `commit-tree` поверх HEAD, `merge-base --is-ancestor U origin/main`
rc=1. Зелёный — 58265131 (на origin/main).

```
--- check_ci_gate.sh <корень> U     → ОТКАЗ: коммит 44255110fb27 не на origin/main — CI по нему не запускался; …   rc=1
--- check_ci_gate.sh U              → тот же отказ                                                               rc=1
--- judge_gate.sh U                 → тот же отказ                                                               rc=1
--- check_ci_gate.sh <корень> 58265131…  →  ok CI зелёный: проверок 12, все success, по 58265131b408               rc=0
--- judge_gate.sh 58265131…         →  ok CI зелёный …  OK                                                       rc=0
--- check_ci_gate.sh <корень> U extra → ОТКАЗ: лишние аргументы: семантика 087 — [корень] [sha]                    rc=1
--- journal after flagless calls: ls: cannot access 'registry/candidates.tsv': No such file or directory
```

- Это совпадает с кругом 1 построчно.
- Важно именно в этом круге: теперь писатели создают журнал, а безфлаговые вызовы его НЕ создают.
- Дифф 2256b1ab трогает только ветви `writer`/`verdict`/`policy` и комментарии.

## 6. Регрессии — ПРОЙДЕНО

```
bash scripts/check_judge_gate.sh
  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate
  ok   (зелёный) зелёный CI → judge_gate RC=0 + «OK» + передал sha=GOOD-SHA-…
check_judge_gate: ветви «all» зелены
CHECK_JUDGE_GATE_RC=0

bash scripts/verify_antiplacebo.sh --scope check_ci_gate
  ok   check_ci_gate/case_ne_zapusheno.sh: … красный кодом 1 — «не на origin/main»   (+7 других ok)
барьеров: 1 · фикстур: 8 · предъявлено красным повторным прогоном: 8
ANTIPLACEBO_RC=0
```

Своя мера: `ls fixtures/check_ci_gate/case_*.sh | wc -l` = 8.

## 7. Замер «= 14» против 17 — без новых оснований, оценка круга 1 в силе

- Блоб контракта не тронут (п.1). Раннер раскладывает 17 явно: «14 контракта 098 + 2 адверсария A-098-1/2 +
  1 ревьюера Рв1-1».
- 14 замороженных клеток на месте и не ослаблены: 608f58a5 добавляет файл и не правит ни одну существующую
  клетку.
- Новое по сравнению с кругом 1: основание 17-й клетки — вердикт ревьюера, а не адверсария/арбитра, которых
  называет AGENTS.md:154-156.
  - Я принимаю это как то же «ДОБАВЛЕНИЕ красных тестов по вердикту … усиливает гейт»: клетка ловит дефект
    против замороженной строки :104, а не вводит новую меру.
  - Условие законности — основание в истории — до этого круга не выполнялось (Н2-1). Его закрывает b9792a22.

## Пункты роли без отдельного номера задания

- **Красное предъявлено (п.4 роли).** MJ1–MJ3, MJall, MT (п.3).
- **Атомарность (п.5 роли).**
  - Implementer — один коммит одной задачи со ссылкой на Рв1-1/098.
  - Architect — один коммит: клетка, модель, стабы, раннер и наблюдение А-418 одного свойства.
  - Adversary-v3 — отдельный коммит.
  - Merge чистый (п.1).
- **Новые неблокирующие.**
  - Н2-2: журнал создаётся до валидации входов, и отказ оставляет пустой файл. Проба: `--check-row` на клоне
    без `harness/policy` → `sed: can't read …` check_rc=2, затем `-rw-rw-r-- … 0 … registry/candidates.tsv`.
  - Н2-3: модель делает `mkdir -p`, а прод при отсутствии `registry/` даёт `ОТКАЗ: журнал: не создать: …`
    rc=1 (проба `noreg/`).
  - Н2-4: трассируемость сообщения d46cf8b5 и указатель А-417.
- **Не проверено.** Приёмка п.5 — сквозная проба на реальном кандидате и реальном CI по `cand/<oid>`.
  Контракт (:113) назначает её на собственный PR 098; до ленда она недостижима и здесь не исполнялась.

## Паразитная сложность (050)

Пять вопросов: (1) свойство, (2) состояние, (3) совместные правки, (4) глубина, (5) потребитель.

- **Прод: три строки создания журнала** (`check_ci_gate.sh:92`, `judge_gate.sh:86,103`) — ESSENTIAL.
  1. :104 «журнал создаётся писателями».
  2. Создаёт `<корень>/registry/candidates.tsv`. Путь тот же, что и раньше: явный корень для check,
     `$SELF/..` для judge. Само создание молчаливо, но это и есть обязанность.
  3. Три одинаковые строки в двух файлах. Раньше их было столько же (три `die`), число мест не выросло.
  4. Интерфейс не изменился: флаги, коды возврата, env те же.
  5. Потребители — п.4(а)/(б) приёмки и клетка 17.
- **`red_zhurnal_sozdaetsja_pisatelem.sh` (новая, 79 строк)** — ESSENTIAL.
  1. :104.
  2. Мир в `/tmp/dev-harness-verify/dokazatelstva-098-sozdaetsja-*`, `trap` уборки, журнал снимается перед
     каждым писателем — это видно в коде.
  3. Новая клетка = литерал раннера (код + сообщение), как и в круге 1.
  4. Не применимо.
  5. Потребители — раннер и стабы s20/s21. Грамматику строк check переиспользует через
     `_d98_check_stroka`; для verdict/policy использует свой `awk`. Так же устроены соседние клетки.
- **`model/judge_gate.sh::d98_journal` (новая функция)** — ESSENTIAL: одна точка для двух ветвей модели и
  якорь маркера t98-mJ1. Состояние то же, что у прода, плюс `mkdir -p` (Н2-3). Потребитель — стаб s20.
- **Стабы s20/s21 и маркеры t98-mJ1/mJ2** — ESSENTIAL: пары Н-39 для клетки 17.
- **Литерал «17» в раннере** — ESSENTIAL по правилу «пустая выборка красна». Совместные правки растут на 1
  с каждой пост-заморозочной клеткой — это А-417/А-418, совет Н1-6.
- **`verdicts/adversary/contracts-098-v3.md`** — ESSENTIAL: основание клеток 15/16 (AGENTS.md:154-156).
  Состояние — нет. Потребитель — этот гейт.

## Сводка находок и классы

| ID | класс | адрес | блокирует |
|---|---|---|---|
| Рв1-1 | дефект предмета + слепота батареи | implementer + architect | закрыт |
| Рв1-2 | трассируемость основания клеток 15/16 | orchestrator | закрыт |
| Н2-1 | трассируемость основания клетки 17 (вердикт ревьюера круга 1 вне репо) | reviewer → orchestrator (ленд b9792a22) | нет, закрыт b9792a22 |
| Н2-2 | побочный эффект: пустой журнал при отказе писателя | implementer | нет |
| Н2-3 | расхождение модель/прод при отсутствии `registry/` | architect/implementer | нет |
| Н2-4 | трассируемость сообщения d46cf8b5 и указатель А-417 | orchestrator | нет |
| Н1-1 | неименованный отказ rc 2 от `sed` (воспроизводится) | implementer | нет |
| Н1-3 | приёмка п.6 как написана | orchestrator/critic | нет |
| Н1-4 | reviewer и architect — одно семейство | orchestrator | нет (компенсировано мутантами) |
| Н1-5 | ACCIDENTAL: дубль remote/curl | implementer | нет (совет) |
| Н1-6 | форма замера «ровно N» (А-417/А-418) | orchestrator/critic | нет (совет) |
