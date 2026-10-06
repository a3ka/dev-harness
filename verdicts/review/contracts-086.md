FAIL

# Вердикт reviewer: контракт 086 (frozen/contracts/086/1), круг 2

Предмет: `wip/086/implementer-fix3` @ `93ae35505a1cd0a7c8b17589679fdfafc9eb9177`. База фикса — круг 1
`wip/086/implementer-fix2` @ `460842f`, база реализации — `27c5b31`. Находки с чекбоксами лежат в
`.review/2026-10-06-04.md`, круг 1 — в `.review/2026-10-06-03.md`. Проверял своей мерой в одноразовом клоне
`/tmp/dev-harness-verify/Reviewer086r2/repo`, «до» — в worktree `…/base460` @ 460842f. Репро —
`…/Reviewer086r2/repro{,2..9}.sh`. Главный чекаут не тронут.

## 1. Контрпримеры круга 1 — живой повтор на 93ae355

```text
N1_ZONES_OKNO_MERGED no_okno_rc=1 okno_rc=1      ← Б-2 закрыт (было okno_rc=0)
N2_SPACE_PATH rc=1 main_moved=no                 ← Б-1 пример 1 закрыт (было rc=0 LANDED)
N3_NONASCII_IN_ZONE rc=0 main_moved=yes          ← Б-1 пример 2 закрыт (было ОТКАЗ (а))
SPAWN_NO_GITHOOKS rc=0 worktree=exists core.hooksPath=[] get_rc=1   ← Б-3 НЕ закрыт (побайтово как в круге 1)
HOOK_MAIN_FIRST_PARENT rc=1 merge_created=no     ← Б-4 пример закрыт (было rc=0 merge_created=yes)
F1/F2/F3 адверсария: rc=1/1/1, F3 no_okno_rc=1 okno_rc=0 bad_base_rc=1 empty_window_rc=2 — без регресса
```

## 2. Б-5 — атрибуция (отдельная сверка)

```text
$ git log --format='%an <%ae>' 27c5b31..wip/086/implementer-fix3 | sort | uniq -c
      4 implementer <implementer@dev-harness.local>
      1 implementer-086fix <implementer-086fix@dev-harness.local>      ← 460842f
$ check_zones.sh . --okno 27c5b31bef79646d4512a2fd9f94a5a1451f7011     (на 93ae355, rc 0)
окно 086: 27c5b31b…..HEAD (5 коммит.) · коммитов в диапазонах: 45 · проверено по зонам: 36
```

Новый коммит 93ae355 авторизован правильно: `implementer <implementer@dev-harness.local>` у автора и коммиттера.
Но он лежит поверх 460842f, а 460842f не переавторен. Счёт своей мерой: 45/5 = 9 окон, 36/9 = 4, то есть
460842f зонным судом по-прежнему не судится. Требование «все коммиты фикса — ровно implementer» не выполнено.

## 3. Батарея

```text
$ reslop t -- bash fixtures/_krasnye_086.sh fast   → exit 0 (A1 A5 L2 L5 H1 ЗЕЛЕНО), 1.5 с
$ reslop t -- bash fixtures/_krasnye_086.sh        → exit 1, 47 с
стаб-пак 086: 13/13 поймано, диффпроба 13/13
accept 6/0/0 · land 8/0/0 · huk_spawn 5/0/0 · istorija_1 3/0/0 · istorija_2 3/0/0 · istorija_3 2/1/0 (КРАСНО: R8 rc=0)
— parsing_hygiene_battery gejt_svedenija: rc=2 (профиль не найден)
```

Результат тот же, что в круге 1. R8 и отсутствующий профиль относятся к architect (Н-6). Этот FAIL на них не
опирается.

## 4. Область правки (ЗОНА implementer)

`git diff --name-status 460842f 93ae355` даёт 4 пути: M `.githooks/pre-merge-commit`, M `scripts/check_zones.sh`,
M `scripts/gejt_svedenija.sh`, M `scripts/spawn_agent.sh`. Кумулятивно `27c5b31..93ae355` — те же 7 путей, что в
круге 1. Все они в `ЗОНА implementer` (строка 243 контракта). Фикстуры, контракты, roles и AGENTS.md фикс не
трогал. Замороженный текст не изменён: `git diff --quiet frozen/contracts/086/1 93ae355 -- contracts/086-…` → rc 0.
Проверки под реализацию не переписаны. Новых барьеров с красным прогоном фикс не принёс: семья зелена и до
фикса, и после, см. Н-9.

## 5. Находки (каждая — с классом; детали и фрагменты в `.review/2026-10-06-04.md`)

Блокирующие:
- **Б-1', семантика, Frontier 2 + 3 + 7.** Фикс заменил только предикат пути. Окно first-parent, своя копия
  is_process_file, draft и цикла СПАСЕНО остались. Комментарий «check_zones использует ту же функцию» ложен:
  `zones_match_path` в check_zones не вызывается. Своя мера на конформных входах:
  `S1_SIDE_LINE_OUT_OF_ZONE land_rc=0` → check_zones после ленда `rc=1 FAIL … docs/owner/side.md` (ложный приём (а));
  `S2_SIDE_LINE_CHARTER land_rc=0` → check_charter `rc=1 FAIL … ROADMAP.md` (ложный приём (в));
  `S3_LF_PATH_IN_ZONE land_rc=1 FAIL … docs.md` → check_zones после ленда `rc=0` (ложный отказ).
- **Б-3, семантика, И-11** — не закрыт: `SPAWN_NO_GITHOOKS rc=0 … core.hooksPath=[]`.
- **Б-6, семантика + регресс, И-11 / Frontier 6, внесён фиксом.** spawn пишет абсолютный
  `<worktree агента>/.githooks` в общий config репо. После двух спавнов hooksPath главного чекаута и wt1 указывает
  в wt2. После `worktree remove` wt2 хуки исчезают везде: `SYNC_MERGE_IN_WT1 rc=0 merge_created=yes`, а на 460842f
  тот же сценарий давал `rc=1 ОТКАЗ 086 (pre-merge-commit)`. Заданный заранее `core.hooksPath=.githooks`
  перезаписывается.
- **Б-4', семантика, Frontier 5 + 7.** «Иная форма — отказ» не исполнено: `exit 0` на `:76-80`. `git pull` main в
  wip-worktree проходит хук: `HOOK_PULL_MAIN rc=0 merge_created=yes main_is_parent=yes` (сценарий Н-119). Хук
  по-прежнему дублирует (б) и ярлыки, а не зовёт гейт.
- **Б-5, процесс, атрибуция** — не закрыт (раздел 2).

Неблокирующие: Н-1..Н-4 круга 1 без изменений. Н-5' — Б-1..Б-4 одним коммитом, предмет один, принято. Н-6 —
R8 и профиль, вход architect. Н-7 — `zones_match_path` печатает зону в stdout гейта. Н-8 — пробел в
`"${HEADS_LINE%% *} ^{commit}"` (`pre-merge-commit:112`), условие всегда истинно. Н-9 — семья не покрывает
S1/S2/S3, спавн без `.githooks`, общий config и `git pull`; это вход architect для v+1 семьи.

## 6. ПРОВОДКА (038)

Без изменений против круга 1. `guard=fixtures/_krasnye_086.sh` существует и бьёт предмет: стаб-пак 13/13.
`ПРОВОДКА-ЭНФОРСМЕНТ` обоснован честно. Замечание: батарея зелёная при Б-1', Б-3, Б-4', Б-6 (Н-9).

## 7. Паразитная сложность (050) — артефакты фикс-диффа 460842f..93ae355

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| вызов `zones_match_path` в гейте (−8/+3) | Frontier 2 «единый источник» | нет; побочный stdout (Н-7) | правило зон: гейт + check_zones = 2, не уменьшилось (check_zones функцию не зовёт) | тоньше прежнего | accept/land; остальной цикл (а)/(в) **повторяет** check_zones/check_charter | ESSENTIAL как шаг; остаток (а)/(в) — ACCIDENTAL, блок Б-1': фрагмент `gejt_svedenija.sh:206-307,326-327`, отсутствует свойство «единый источник», более простая форма — `check_zones/check_charter --okno` на проспективном `land:`-merge (И-6), проходит те же строки приёмки |
| `--first-parent` снят в check_zones `--okno` (−1/+1, +9 комментария) | И-5 | нет | 1 | без изменения интерфейса | судьи; гейт в окне остался first-parent | ESSENTIAL |
| `HOOKS_SRC="$wt_path/.githooks"` в spawn (+8/−10) | И-11 | **неявное**: пишет общий `$GIT_DIR/config`, а не worktree; в выводе не видно | 1 | узкий | спавн | ACCIDENTAL и дефект, блок Б-6: фрагмент `spawn_agent.sh:335,348`, нарушено свойство И-11/Frontier 6, более простая форма — Frontier 6 буквально: если hooksPath задан — не трогать, иначе `core.hooksPath .githooks` (относительный, резолвится в корень каждого worktree), отсутствие каталога → откат rc 1 |
| множество родителей хука (+45 строк, `declare -A`, двойной цикл) | Frontier 4 | нет | правило (б): гейт + хук = 2 (не уменьшилось) | интерфейс тот же, тело выросло; мёртвое условие `:112` (Н-8) | git; **повторяет** sync-предикат гейта «дословно» (`:98-100`) | дубль — ACCIDENTAL, блок в составе Б-4' (Frontier 7): более простая форма — хук передаёт множество {HEAD} ∪ головы в общий предикат гейта |

## Вердикт

**FAIL**. Из пяти блокирующих находок круга 1 полностью закрыт только Б-2. У Б-1 и Б-4 закрыты конкретные
контрпримеры, но нарушения тех же замороженных обязательств показаны исполнением на новых конформных входах
(Б-1', Б-4'). Б-3 и Б-5 не закрыты. Фикс Б-3 внёс регресс Б-6: sync-merge, который 460842f отклонял, на
93ae355 проходит.
