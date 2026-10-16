accept — 1230ef4b5 (.githooks/pre-push, круг 3): единственный блокер круга 2 Рв-PP-9 закрыт; от второго ориентира (локальный refs/heads/main) новой дыры и регрессий против 5742418f1 нет. Открытыми остаются только советы: Рв-PP-6/10/11 и новые Рв-PP-12/13. Находки: `.review/2026-10-16-02.md`.

# Ревью: pre-push fail-open, круг 3 (1230ef4b5)

- **Предмет:** `1230ef4b5b77a3d2842bf470d2066a5a87c846c5`. Единственный файл — `.githooks/pre-push` (+18/−10)
  к `5742418f1`. Identity owner, «быстрый путь по слову владельца 2026-10-16». Тело коммита прочитано целиком.
- **Ревьюер:** reviewer (Opus), identity `reviewerprepushv3`. Плоское «reviewer» блокирует worktree-гвард.
- **Клон:** `/tmp/dev-harness-verify/rv-prepush3-BindingDormouse-1792149223`, SSH `git@github.com:a3ka/dev-harness.git`,
  HEAD `1230ef4b5`. Это же значение дал `ls-remote origin refs/heads/main`. Хук в клоне побайтно равен хуку
  основного чекаута, sha256 `6dcbde6e…`.
- **Версии:** v0 = `0f48780f`, r2 = `5742418f1` (sha256 `571f845d…`), r3 = `1230ef4b5` (`6dcbde6e…`).
  r1 (`95e91122…`) извлекается только для сверки sha256.
- **Пробы:**
  - мои скрипты круга 2 порождены заново (`…1792149223.gen.py`): заменены только путь и версии r1/r2 → r2/r3,
    в probe3 жёсткий MAIN заменён на `p1~1`; сценарии те же;
  - новые: `…probe4.sh` (N0–N8, вопросы этого круга) и `…probe5.sh` (P3m* — валидная форма «у origin нет main»).

## Пункты гейта

| # | Пункт | Итог |
|---|-------|------|
| 1 | Область правки | ОК: `git show --stat 1230ef4b5` — один файл `.githooks/pre-push`, изменена одна функция (`merge_main_verdict`) |
| 2 | Сырой вывод | ЧАСТИЧНО: `/tmp/dev-harness-verify/hookround3b.out` есть, rc построчно; одна строка неверна по среде пробы (Рв-PP-12, совет). Мой вывод ниже |
| 3 | Проверка не подогнана | ОК: в диффе нет `fixtures/`; фикстуры 022 прогнаны из дерева клона на `1230ef4b5` |
| 4 | Красное предъявлено | Моими пробами: P3n, N2, N8' — r2 rc=0 → r3 rc=1. Постоянной фикстуры нет (Рв-PP-6) |
| 5 | Атомарность | ОК: один коммит, один предмет (Рв-PP-9) |
| 6 | Норма не тронута | ОК: `roles/`, `verdicts/arbitration/` и `AGENTS.md` в диффе отсутствуют |
| 7 | Заявленное = сделанному | ОК по P3n/P3h'/P3o/P3o', фикстурам и живой ROADMAP-пробе. Ложна одна строка: «P3g' rc=0» (Рв-PP-12, совет) |

**ПРОВОДКА (038).** Канал тот же, что в кругах 1–2: role-строка `roles/orchestrator.md:195`, хук — guard того же
предмета. Принято.

## Правка (прочитана живьём)

`merge_main_verdict`, строки 219–238. Ориентиры (б) собираются так:
`mains=( "$LIVE_MAIN" )`, а `lm=$(rev-parse --verify --quiet 'refs/heads/main^{commit}') || lm=""` добавляется,
если он непуст и отличается от живого main. Внешний цикл `for m in "${mains[@]}"` обходит прежний цикл по
`"${parents[@]:2}"`. Мёртвое `r=$?` после `mapfile` удалено. Ветвь (а), int-форма, и ранний исход 2 («живого
main нет локально») стоят ДО сбора ориентиров и не изменились. Значит, отсутствие или порча локального main
не может отменить fail-closed по живому main. Это форма r2x из круга 2, без отличий по смыслу.

## Сырой вывод (свой)

Обозначения: SHA → `<sha>`, причина отказа обрезана, `~` разделяет строки; метки `←` мои.

### Набор кругов 1–2 (`…probe.sh`, `…probe2.sh`, `…probe3.sh`)

```
P1a ROADMAP, no missing live sha (control)                 v0 rc=1 | r2 rc=1 | r3 rc=1  ОТКАЗ устав-дельта … ROADMAP.md
P1b ROADMAP, live sha missing locally                      v0 rc=0 | r2 rc=1 | r3 rc=1  ОТКАЗ устав-дельта … ROADMAP.md
  live refs on O now: 881; absent in W: 1
P2a docs/owner add by architect                            r2 rc=1 | r3 rc=1  ОТКАЗ docs/owner/ пишет только owner
P2b docs/owner add by owner                                r2 rc=0 | r3 rc=0
P2c orchestrator clean merge of owner docs                 r2 rc=0 | r3 rc=0
P2d orchestrator evil merge rewrites owner doc             r2 rc=1 | r3 rc=1  ОТКАЗ docs/owner/ …
P2e non-owner deletes docs/owner file (7ed4a89c form)      r2 rc=1 | r3 rc=1  ОТКАЗ docs/owner/ …
P3a wip without merge                                      r2 rc=0 | r3 rc=0
P3b merge main->wip (wip first parent)                     r2 rc=1 | r3 rc=1  ОТКАЗ … приносит историю main …
P3b' same, pushed to non-wip ref                           r2 rc=1 | r3 rc=1  ОТКАЗ … ref=refs/heads/tmp-sync
P3c int-form to wip/int-999/architect                      r2 rc=0 | r3 rc=0
P3d int-form (main 1st) FF-pushed onto wip/999/architect   r2 rc=1 | r3 rc=1  ОТКАЗ … первый родитель — коммит main (int-форма)
P3e merge LOCAL main (1 unpushed commit) ->wip             r2 rc=1 | r3 rc=1
P3h octopus (sib 2nd, main 3rd) ->wip                      r2 rc=1 | r3 rc=1
P3i merge sibling wip (same base) ->wip (legit)            r2 rc=0 | r3 rc=0
P3j merge sibling-from-newer-main ->wip                    r2 rc=1 | r3 rc=1
P3k merge (local) main into existing int-branch            r2 rc=0 | r3 rc=0
P3f M1 already on origin as tmp-sync, now ->wip            r2 rc=0 | r3 rc=0
  live main in W: n
P3g live main absent locally, merge main->wip              r2 rc=1 | r3 rc=1  ОТКАЗ: проверить слияние … живого main origin нет в локальной базе — сделайте git fetch origin main
P3g' live main absent, innocent sibling merge ->wip        r2 rc=1 | r3 rc=1  (тот же именованный отказ)   ← Рв-PP-12: консультант пишет rc=0
P4  live main absent, innocent wip off local main          r2 rc=0 | r3 rc=0
P4' live main absent, ref deletion                         r2 rc=0 | r3 rc=0
P3m origin has NO main, merge main->wip                    r2 rc=1 | r3 rc=1  (недействительна: «refusing to delete the current branch», повтор P3g)
P4m origin has NO main, plain wip commit                   r2 rc=0 | r3 rc=0
  P3n: p1=9c9f31a5 p2=4f19efef local-main=4f19efef live-main=1230ef4b5
P3n fresh wip (from live main) + merge LOCAL main ahead    r2 rc=0 | r3 rc=1  ОТКАЗ … ref=refs/heads/wip/999/implementer … родитель <sha> приносит историю main  ← Рв-PP-9 ЗАКРЫТ
P3h' octopus (sib 2nd, LOCAL main 3rd) ->wip               r2 rc=1 | r3 rc=1
  P3o bases(B1,A1): single=0b23989af other=ed871ec04; single in p1: y; other in p1: n
P3o criss-cross: single base in p1, other base not         r2 rc=1 | r3 rc=1
P3o' control: p2 history already in p1                     r2 rc=0 | r3 rc=0
P5  empty wip (tip=live main) merges sibling wip           r2 rc=1 | r3 rc=1  … int-форма вне ветки wip/int-*   (наблюдение круга 2)
```

`…probe5.sh` — валидная P3m: bare `--initial-branch=master`, `main` удалён, на O `refs/heads/main` 0 строк,
локальный main есть.
```
P3m*  origin NO main, merge local main into wip            r2 rc=1 | r3 rc=1  … живого main origin нет в локальной базе — сделайте git fetch origin
P3m*' origin NO main, sibling merge                        r2 rc=1 | r3 rc=1  (тот же)
P4m*  origin NO main, plain wip commit                     r2 rc=0 | r3 rc=0
```

**Своя мера.** Счёт по файлу `…probe.out`: `grep -c ' r3 rc=1'` дал 14, `' r3 rc=0'` дал 10; меток, где r2 ≠ r3,
нет. По probe2/probe3: r2 ≠ r3 только у P3n.

**Сверка с телом коммита.** Список rc=1 в теле: P1b, P2a/d/e, P3b/b'/d/e/g/h/j/m — у меня совпадают все 12.
Список rc=0: P2b/c, P3a/c/i/k/f, P4/P4'/P4m — 10 из 11 совпадают; P3g' у меня rc=1 и на r2, и на r3. Пункты
P3n rc=1, P3h' rc=1, P3o rc=1, P3o' rc=0 и P5 rc=1 подтверждены.

Почему у консультанта P3g' вышла rc=0: его bare `…19187.probe/O.git/HEAD` содержит `ref: refs/heads/master`, мой —
`ref: refs/heads/main`. Поэтому у него прошло удаление main (P3m там валиден), а сценарий «живой main ушёл
вперёд» для P3g/P3g', по всей видимости, не построился [INFERENCE]. Код хука от этого не зависит.

### Новые вопросы круга (`…probe4.sh`)

Устройство пробы:
- J — невыпущенный коммит на локальном `refs/heads/main`, живой main = `1230ef4b5`;
- WN — свежая wip от живого main; WO — wip от `MAIN~5`;
- SIB — сосед от живого main.

```
N0  control P3n: local main ahead, merge it into fresh wip       r2 rc=0 | r3 rc=1  ОТКАЗ … приносит историю main
  local main=(нет)  (J reachable as refs/remotes/host/main)
N1  no local main: merge host/main (unpushed J) into fresh wip   r2 rc=0 | r3 rc=0   ← Рв-PP-13(1), r3 = r2
N1b no local main: merge LIVE main into old wip (P3b form)       r2 rc=1 | r3 rc=1
N1c no local main: merge sibling into fresh wip (legit)          r2 rc=0 | r3 rc=0
  live main in W: n; local main=(нет)
N1d no local main + live main absent: sibling merge              r2 rc=1 | r3 rc=1  … живого main origin нет в локальной базе — сделайте git fetch origin main  ← Рв-PP-1 держится
  worktree sees main=16bf158c7
N2  linked worktree, merge local main (ahead) into fresh wip     r2 rc=0 | r3 rc=1  ← форма spawn_agent закрыта
  local main=5742418f1 = MAIN~3
N3a stale local main: sibling merge into fresh wip (legit)       r2 rc=0 | r3 rc=0
N3b stale local main: merge live main into old wip               r2 rc=1 | r3 rc=1
N3c stale local main: old wip merges old sibling                 r2 rc=0 | r3 rc=0
  local main=0a7723cf7 (orphan)
N4a orphan local main: sibling merge (legit)                     r2 rc=0 | r3 rc=0
N4b orphan local main: merge live main into old wip              r2 rc=1 | r3 rc=1
  packed main line: deadbeefdead (объекта нет)
N5  broken local main ref: merge J into fresh wip                r2 rc=0 | r3 rc=0   ← Рв-PP-13(2)
  local main=16bf158c7
N6  int-form with LOCAL main (J) 1st, FF onto wip/999/architect  r2 rc=0 | r3 rc=0   (наблюдение)
N6' plain wip off local main J (P4 class, live main present)     r2 rc=0 | r3 rc=0
N7  wip off J merges sibling off live main (legit)               r2 rc=0 | r3 rc=0
N8  old wip merges sibling-off-J (brings live main + J)          r2 rc=1 | r3 rc=1
N8' fresh wip merges sibling-off-J (brings only J)               r2 rc=0 | r3 rc=1   ← буква Рв-PP-9, аналог P3j
```

Своя мера: `' r3 rc=1'` дал 8, `' r3 rc=0'` дал 9. Меток, где r2 ≠ r3, три: N0, N2, N8'. Все три переходят
r2 rc=0 → r3 rc=1, в обратную сторону переходов нет.

### История (`…hist.sh`, дерево W = `1230ef4b`, локальный main W = `1230ef4b` ≠ живой main пробы)

```
868d386f / 7ed4a89c  refs/heads/main                  r2 rc=1 | r3 rc=1  ОТКАЗ docs/owner автор=orchestrator
b0c39a58 / f3452af5 / e1109e76 / 678c64db / 3c2962c7   r2 rc=0 | r3 rc=0
b2a0573a9  refs/heads/wip/104/implementer2            r2 rc=0 | r3 rc=0
f926 (P=b2a0573a ea39bec9)                            r2 rc=1 | r3 rc=1  ОТКАЗ ROADMAP + ОТКАЗ merge main в ветку запрещён
== tree b0c39a58: b0c39a58                            r2 rc=1 | r3 rc=1  ОТКАЗ устав-дельта … ROADMAP.md
== tree af4e33f4: b0c39a58                            r2 rc=0 | r3 rc=0
```

### Фикстуры контракта 022 (`…run.sh`, хук версии подставлен в дерево клона и затем восстановлен)

Итог: `sha256` дерева `6dcbde6e…`, `git status --porcelain` пуст. Перечень: 9 `red_push_*`, 2 `probe_*` и
`red_check_hooks_bez_push_faz`. `fixtures run: 12` напечатано для каждой версии.

```
                                             v0    r2    r3
red_push_dobavlenie_ustavnogo_svobodno.sh    rc=0  rc=0  rc=0
red_push_istoricheskij_legit_prohodit.sh     rc=0  rc=0  rc=0
red_push_lechenie_ne_blokiruetsja.sh         rc=0  rc=0  rc=0
red_push_merge_gran_bez_stroki.sh            rc=0  rc=0  rc=0
red_push_nulevoj_ref_scoped.sh               rc=0  rc=0  rc=0
red_push_stale_zerkalo_iskljuchaet.sh        rc=0  rc=0  rc=0
red_push_teg_annotirovannyj_suditsja.sh      rc=0  rc=0  rc=0
red_push_vetochnaja_gran_bez_merge.sh        rc=0  rc=0  rc=0
red_push_vtoroj_remote_sushhij_ref.sh        rc=0  rc=0  rc=0
probe_check_hooks_krasnyj.sh                 rc=0  rc=0  rc=0
probe_push_svezhij_sverh_origin_umiraet.sh   rc=0  rc=0  rc=0
red_check_hooks_bez_push_faz.sh              rc=0  rc=0  rc=0
```

### Живой основной чекаут

Проба консультанта `cb6369d58`, «consultant проба хука (не пушить в origin)», правит только ROADMAP.md.
Хук дерева (`6dcbde6e…`) запущен напрямую, без push:
```
ОТКАЗ: pre-push: устав-дельта M/D без РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ref=refs/heads/probe коммит=cb6369d58aeee1fe9be678d8938ea708bdb5dab5 путь=ROADMAP.md
rc=1
```

## Суд

- **Рв-PP-9 — ЗАКРЫТ.**
  - P3n и N0: r2 rc=0 → r3 rc=1.
  - Рабочая форма агентов — linked worktree (`scripts/spawn_agent.sh:375`), refs у неё общие с основным чекаутом.
    N2: r2 rc=0 → r3 rc=1.
  - Набор кругов 1–2 не сдвинулся ни на одной строке, в том числе законные P2b, P2c, P3a, P3c, P3i, P3k, P3f,
    P4, P4', P4m и P3o'.
- **Новой дыры от второго ориентира нет.**
  - Ориентир только добавляет проверки к прежнему циклу. Исход 2 по живому main стоит до него, поэтому
    отсутствие или битость локального main ничего не открывает: N1b rc=1, N1d — именованный ОТКАЗ, P3m* rc=1.
  - Отстающий (N3) и несвязный (N4) локальный main не дают ни ложного отказа, ни прохода.
  - Отсутствие локального main не является «неизвестностью» в смысле Рв-PP-1: состояние определено, а
    авторитет (живой main) проверен полностью. Fail-closed здесь не требуется.
  - Граница (N1: история main под чужим именем; N5: битый ref) от r2 не отличается — это совет Рв-PP-13.
- **Рв-PP-10 — частично.** Мёртвое `r=$?` удалено, это ACCIDENTAL-часть круга 2. Потеря rc `merge-base` в
  `mapfile < <(…)` осталась, теперь по двум ориентирам: совет, [INFERENCE], реальное состояние не построено.
  Попутно: `m` не объявлена `local`, коллизии нет.
- **Рв-PP-11 — не затронут.** Файл круга 2 неизменен. Тот же класс («rc пробы ≠ вердикт хука») повторился
  в круге 3 как Рв-PP-12: совет, потому что ошибка занижает строгость хука, а не завышает её.
- **Рв-PP-6 — без изменений** (совет): постоянной фикстуры P3n-класса нет.

Наблюдения:
- N6: int-форма с локальным main первым родителем — r3 rc=0, как r2. Это вопрос владельцу.
- N8': merge соседа, ответвлённого от локального main, — r3 rc=1. Это буква Рв-PP-9, цена принята.

Оба записаны в `.review/2026-10-16-02.md`.

## Паразитная сложность (050)

- **`mains` + `lm` + внешний цикл `for m` (строки 219–225).**
  1. Свойство: Рв-PP-9, «включая невыпущенную историю локального main».
  2. Состояние: читает `refs/heads/main` — вход, которого нет в аргументах. В причине отказа не сказано,
     какой ориентир сработал: «приносит историю main» — без live/local. Состояние явно в коде, в выводе
     частично.
  3. Меняется 1 файл, число не выросло.
  4. Интерфейс (2 аргумента, коды 0/1/2) не вырос, работы под ним прибавилось — модуль стал глубже.
  5. Потребитель — P3n/N2 (мои пробы), в CI нет (Рв-PP-6). Чужую грамматику не повторяет.

  Итог: ESSENTIAL. Более простая форма — r2 без ориентира, и она не проходит P3n.
- **Удалённое `r=$?`** — сложность уменьшилась.

## Итог

accept. Код остаётся в main. По всей матрице (кругов 1–2 и новой) r3 строго не слабее r2. Отличия от r2 —
только переходы rc=0 → rc=1 на P3n, N0, N2 и N8'. Блокеров нет. Советы — Рв-PP-6, Рв-PP-10 (остаток),
Рв-PP-11, Рв-PP-12, Рв-PP-13, адресат — консультант при следующей правке хука.
