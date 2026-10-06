FAIL

# Вердикт reviewer: контракт 086 (frozen/contracts/086/1)

Предмет: `wip/086/implementer-fix2` @ `460842f15002610f8cbf4ddc2875567b91fa6fdc`. База реализации —
`27c5b31`, база фикса — PR#40 `5c92f3c`. Находки с чекбоксами лежат в `.review/2026-10-06-03.md`.
Проверял своей мерой в одноразовом клоне `/tmp/dev-harness-verify/Reviewer086/repo`. Репро — на
каркасе `fixtures/gejty_svedenija_086/_toy.sh`; главный чекаут не тронут.

## 1. F1/F2/F3 адверсария — независимый повтор (все три закрыты)

```text
F1_DELETE rc=1 main_moved=no
      FAIL коммит вне зоны: implementer 1998caf2 docs/owner/existing.md
    ОТКАЗ 086 (land): правило (а) путь вне frozen-ЗОНЫ автора; выход: путь в зону — v+1 со словом владельца
F2_side1_side2_main parents=4
F2_side1_side2_main rc=1 main_moved=no
    ОТКАЗ 086 (land): правило (б) sync-merge; sha 01c92199…; выход: пересобери ветку без merge main
F2_side1_main_side2 parents=4
F2_side1_main_side2 rc=1 main_moved=no
    ОТКАЗ 086 (land): правило (б) sync-merge; sha 08298bce…; выход: пересобери ветку без merge main
F3_check_zones no_okno_rc=1 okno_rc=0 marker=1   bad_base_rc=1   empty_window_rc=2
F3_check_charter no_okno_rc=1 okno_rc=0 marker=1   bad_base_rc=1   empty_window_rc=2
```

F2 проверен в двух вариантах: main четвёртым родителем октопуса и main третьим. F3 проверен так:
нарушение ниже базы (зона и устав), выше базы — чистый коммит.

## 2. Батарея

```text
$ reslop t -- bash fixtures/_krasnye_086.sh fast     → exit 0 (A1 A5 L2 L5 H1 ЗЕЛЕНО), 1.4 с
$ reslop t -- bash fixtures/_krasnye_086.sh          → exit 1, 45 с
стаб-пак 086: 13/13 поймано, диффпроба 13/13
accept 6/0/0 · land 8/0/0 · huk_spawn 5/0/0 · istorija_1 3/0/0 · istorija_2 3/0/0 · istorija_3 2/1/0 (КРАСНО: R8 rc=0)
— parsing_hygiene_battery gejt_svedenija: rc=2 (профиль не найден)
```

Результат совпадает с прогоном адверсария. R8 и отсутствующий profile — находки architect, этот FAIL
на них не опирается.

## 3. Область правки

`git diff --name-status 27c5b31 460842f` даёт 7 путей: A `.githooks/pre-merge-commit`, M
`scripts/accept_task_commit.sh`, M `scripts/check_charter.sh`, M `scripts/check_zones.sh`, A
`scripts/gejt_svedenija.sh`, M `scripts/land_agent.sh`, M `scripts/spawn_agent.sh`. Все семь в
`ЗОНА implementer`. Фикс-дифф `5c92f3c..460842f` — 3 файла, как в докладе: gejt_svedenija,
check_zones, check_charter. Фикстуры, контракты, roles и AGENTS.md не тронуты (пустой `diff
--name-only`). Замороженный текст не изменён: `git diff --exit-code frozen/contracts/086/1 460842f --
contracts/086-…` → rc 0.

## 4. Находки (каждая — с классом; детали в `.review/2026-10-06-03.md`)

Блокирующие:
- **Б-1, семантика, Frontier 2 + 7.** Гейт (а)/(в) — вторая реализация поверх lib_zones, то есть
  отвергнутая альтернатива (i). `--okno` у судей без потребителя. Своя мера: путь `ROADMAP.md vne
  zony` у architect посажен land (`rc=0 LANDED`), а check_zones после ленда даёт `rc=1 FAIL`
  (ложный приём). `src/отчёт.md` в зоне гейт отверг (`ОТКАЗ 086 (accept): правило (а)`), а
  check_zones даёт `rc=0` (ложный отказ).
- **Б-2, семантика, И-5.** `check_zones --okno` режет окно по `--first-parent`, поэтому нарушение,
  пришедшее `land:`-merge выше базы, не судится: `no_okno_rc=1 okno_rc=0`, `коммитов в диапазонах: 0`.
- **Б-3, семантика, И-11.** 5c92f3c пропускает обеспечение хуков, когда у canon_root нет `.githooks`:
  `SPAWN_NO_GITHOOKS rc=0 worktree=exists core.hooksPath=[]`. Замороженный инвариант
  переистолкован, чтобы позеленели чужие до-086 фикстуры.
- **Б-4, семантика, Frontier 4 + 7.** Хук дублирует правило (б) и не ловит main первым родителем:
  `HOOK_MAIN_FIRST_PARENT rc=0 merge_created=yes`, а гейт на том же merge даёт `rc=1`. Шапка хука
  обещает «иная форма — отказ», код делает `exit 0`.
- **Б-5, процесс, атрибуция.** 460842f закоммичен под `implementer-086fix` — это не ЗОНА-токен.
  check_zones `--okno 27c5b31…`: 4 коммита в окне, `проверено по зонам: 27` = 3 implementer-коммита
  × 9 окон, фикс-коммит не судился.

Неблокирующие: Н-1 (И-7, rc 2 при исходе is-ancestor вне {0,1} не реализован), Н-2 (лишний argv
судей теперь даёт rc 2), Н-3 (rc 1 против rc 2 при отказе rev-list окна), Н-4 (`--okno=` — лишний
синтаксис), Н-5 (F1+F2+F3 одним коммитом — принято), Н-6 (R8 / profile — architect).

## 5. ПРОВОДКА (038)

`guard=fixtures/_krasnye_086.sh` существует и бьёт именно предмет: стаб-пак 13/13, клетки
accept/land/хук/спавн. `ПРОВОДКА-ЭНФОРСМЕНТ` обоснован честно: механизм, норм-строк ролей нет, CI-шаг
в зоне живой заморозки 083. Замечание: батарея зелёная, хотя есть Б-1…Б-4, значит семья не покрывает
пути с пробелом и не-ASCII, `land:`-merge в окне судьи, спавн без `.githooks` и хук с main первым
родителем. Это вход для architect (v+1 семьи), а не правка реализации.

## 6. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `scripts/gejt_svedenija.sh` (379 строк) | Frontier 7 «один гейт» | скратч `$TMP`; merge `land:` (И-6) не создаётся — суд идёт по first-parent-списку | правило зон: check_zones + гейт = 2 (выросло с 1) | интерфейс узкий (5 позиционных), работа глубокая | accept, land; **повторяет** is_process_file, draft, СПАСЕНО, разбор путей check_zones | ESSENTIAL как точка; тело (а)/(в) — ACCIDENTAL (Б-1: фрагмент `:206-309`, свойство «единый источник» отсутствует, более простая форма — `check_zones/check_charter --okno` на проспективном merge по Frontier 2/И-6) |
| `.githooks/pre-merge-commit` (132) | И-3 | нет | правило (б): гейт + хук = 2 | узкий | git; **повторяет** правило (б) и ярлыки гейта | ESSENTIAL как точка; дубль (б) — ACCIDENTAL (Б-4) |
| `--okno` в check_zones / check_charter (+57/+55) | И-5 | явное (аргумент, маркер) | 2 судьи | флаг + `--okno=` при одной функции | потребителя в дереве нет; строки приёмки — только А8 «без --okno» | ESSENTIAL по И-5; `--okno=` — ACCIDENTAL, совет (Н-4) |
| блок хуков в spawn_agent (+37) | И-11 | пишет `core.hooksPath` в config | 1 | узкий | спавн | ESSENTIAL; ветвь `if [ -d ]` нарушает И-11 (Б-3) |
| вызовы гейта в accept/land (+20/+16) | И-1/И-2 | нет | 1 каждый | тонкие обёртки | точки | ESSENTIAL |

Про проспективный ленд: `git grep -nE 'commit-tree|merge -|worktree add|"land: ' 460842f --
scripts/gejt_svedenija.sh` → rc 1, совпадений нет. Merge `land: <ветка>` из И-6 гейт не создаёт;
`MB` на `:239` вычисляется, но в суде не участвует. Это наблюдение по коду. Чем отличается вердикт
относительно merge-формы, я исполнением не проверял, поэтому отдельной блокирующей находкой не
выношу.

## Вердикт

**FAIL** по Б-1…Б-5. Три сценария адверсария закрыты, батарея воспроизводит результат автора. Но
замороженные обязательства Frontier 2/4/7, И-5 и И-11 нарушены, и это показано исполнением на
конформных входах. Фикс-коммит выпал из зонного суда.
