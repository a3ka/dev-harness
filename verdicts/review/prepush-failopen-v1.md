FAIL — 9b14bac6f (.githooks/pre-push): заявленный fail-open диапазона закрыт и подтверждён независимо. Новый барьер merge main→wip сам открыт в двух реальных состояниях основного чекаута (Рв-PP-1, Рв-PP-2), одно счётное утверждение тела коммита ложно (Рв-PP-3). Находки: `.review/2026-10-16-01.md`.

# Ревью: pre-push fail-open (9b14bac6f), круг 1, пост-фактум

- **Предмет:** `9b14bac6f170a0d50284d4a099eef50ef2862f9e`, единственный файл — `.githooks/pre-push` (+64/−1),
  identity owner, путь «быстрый путь по слову владельца 2026-10-16».
- **Гейт:** без критика, заморозки и адверсария; этот круг — единственный судейский.
- **Ревьюер:** reviewer (Opus, другое семейство).
- **Клон:** `/tmp/dev-harness-verify/rv-prepush-1665661-19135`, SSH `git@github.com:a3ka/dev-harness.git`.
  Пробы проводились на базе `4211ed824`. Скрипты проб лежат там же: `…19135.run.sh`, `…19135.probe.sh`, `…19135.hist.sh`.
- **Н-62:** grep NABLIUDENIA по `pre-push|fail-open|926f9bcf` дал записи Н-86 (диапазон «сверх origin»),
  Н-180 и Н-294 (926f9bcf — merge main→wip, третий рецидив). Противоречий с ними в диффе нет.

## Пункты гейта

| # | Пункт | Итог |
|---|-------|------|
| 1 | Область правки | ОК: дифф затрагивает только `.githooks/pre-push`, как и объявлено |
| 2 | Сырой вывод | НЕТ у автора: «Проверено на станции» — пересказ (Рв-PP-8). Сырой вывод ниже, мой |
| 3 | Проверка не подогнана | ОК: фикстуры не тронуты, `git show --stat` — один файл |
| 4 | Красное предъявлено | Только моими пробами (P1b, P2a, P3b). Постоянной фикстуры нет (Рв-PP-6, совет) |
| 5 | Атомарность | ОК: один коммит на один предмет |
| 6 | Норма не тронута | ОК: норма-строка роли пришла отдельными коммитами `e586f8f06`/`4211ed824`, здесь только механизм |
| 7 | Заявленное = сделанному | НЕТ: b0c39a58 (Рв-PP-3). Остальное совпало, проверено своей мерой (ниже) |

**ПРОВОДКА (038).** Запрет merge main→wip относится к поведенческой норме 029-класса. Role-канал у него есть:
`roles/orchestrator.md:195`. Хук — дополнительный guard этого же предмета, а не постороннего скрипта. Принято.

## Сырой вывод (свой)

### Корень fail-open в живом основном чекауте

Команды выполнялись только на чтение.

```
$ git ls-remote origin | cut -f1 | sort -u | while read s; do git cat-file -e "$s^{commit}" && echo have || echo miss; done | sort | uniq -c
    862 have
     21 miss                      # 21 из 883 — совпадает с заявленным
$ git rev-list HEAD --not $(git ls-remote origin | cut -f1 | sort -u)
fatal: bad object 094155ab92006a29d6d38844a4505c9c71e3db18     pipestatus=128
```

### Фикстуры контракта 022

Перечень: red_push_* ×9, probe_* ×2, red_check_hooks_bez_push_faz. Счёт мой, по `ls fixtures/check_hooks/`.
Новый хук стоял в дереве на HEAD. Старый подставлялся командой `git checkout 9b14bac6^ -- .githooks/pre-push`.

```
                                             new   old
red_push_dobavlenie_ustavnogo_svobodno.sh    rc=0  rc=0
red_push_istoricheskij_legit_prohodit.sh     rc=0  rc=0
red_push_lechenie_ne_blokiruetsja.sh         rc=0  rc=0
red_push_merge_gran_bez_stroki.sh            rc=0  rc=0
red_push_nulevoj_ref_scoped.sh               rc=0  rc=0
red_push_stale_zerkalo_iskljuchaet.sh        rc=0  rc=0
red_push_teg_annotirovannyj_suditsja.sh      rc=0  rc=0
red_push_vetochnaja_gran_bez_merge.sh        rc=0  rc=0
red_push_vtoroj_remote_sushhij_ref.sh        rc=0  rc=0
probe_check_hooks_krasnyj.sh                 rc=0  rc=0
probe_push_svezhij_sverh_origin_umiraet.sh   rc=0  rc=0
red_check_hooks_bez_push_faz.sh              rc=0  rc=0
```

### Синтетические пробы (`…19135.probe.sh`)

Устройство пробы:
- W — клон клона;
- O — bare-репозиторий, на нём main=`4211ed824`, все теги и 126 живых wip-веток GitHub;
- ghost — коммит, которого нет в W.

```
P1a ROADMAP, no missing live sha (control)             old rc=1 | ОТКАЗ устав-дельта M/D … путь=ROADMAP.md
P1a ROADMAP, no missing live sha (control)             new rc=1 | ОТКАЗ устав-дельта M/D … путь=ROADMAP.md
P1b ROADMAP, live sha missing locally                  old rc=0 |                        ← fail-open воспроизведён
P1b ROADMAP, live sha missing locally                  new rc=1 | ОТКАЗ устав-дельта M/D … путь=ROADMAP.md
P2a docs/owner add by architect                        new rc=1 | ОТКАЗ docs/owner/ пишет только owner
P2b docs/owner add by owner                            new rc=0 |
P2c orchestrator clean merge of owner docs             new rc=0 |
P2d orchestrator evil merge rewrites owner doc         new rc=1 | ОТКАЗ docs/owner/ …
P2e non-owner deletes docs/owner file (7ed4a89c form)  new rc=1 | ОТКАЗ docs/owner/ …
P3a wip without merge                                  new rc=0 |
P3b merge main->wip (wip first parent)                 new rc=1 | ОТКАЗ merge main→wip запрещён
P3b' same, pushed to non-wip ref                       new rc=0 |                        ← Рв-PP-4
P3c int-form to wip/int-999/architect                  new rc=0 |
P3d int-form (main 1st) FF-pushed onto wip/999/architect new rc=0 |                      ← Рв-PP-5
P3e merge LOCAL main (1 unpushed commit) ->wip         new rc=0 |                        ← Рв-PP-2
P3f M1 already on origin as tmp-sync, now ->wip        new rc=0 |                        ← Рв-PP-4
P3g live main absent locally, merge main->wip          new rc=0 |                        ← Рв-PP-1
P4  live main absent, innocent wip off local main      new rc=0 |  (range 9 — ложного отказа нет)
```

### История (`…19135.hist.sh`)

Origin пробы содержит refs на каждого родителя коммита плюс main. Диапазон в каждом случае равен ровно 1 коммиту.

```
868d386f   refs/heads/main                  old rc=0 | new rc=1 ОТКАЗ docs/owner автор=orchestrator
7ed4a89c   refs/heads/main                  old rc=0 | new rc=1 ОТКАЗ docs/owner автор=orchestrator
b0c39a58   refs/heads/main                  old rc=0 | new rc=0          ← Рв-PP-3: grandfather-пара 32 (af4e33f49), заявлено «ОТКАЗ»
f3452af5   refs/heads/main                  old rc=0 | new rc=0
e1109e76   refs/heads/main                  old rc=0 | new rc=0
678c64db   refs/heads/main                  old rc=0 | new rc=0
3c2962c7   refs/heads/main                  old rc=0 | new rc=0
b2a0573a9  refs/heads/wip/104/implementer2  old rc=0 | new rc=0
форма 926f9bcf (P=b2a0573a+ea39bec9; 926f9bcf в клоне отсутствует — недостижим из живых ref'ов)
           refs/heads/wip/104/implementer2  old rc=1 (ROADMAP) | new rc=1 ROADMAP + ОТКАЗ merge main→wip запрещён
```

Кандидат-форма для Рв-PP-2, `! is-ancestor (merge-base p2 LIVE_MAIN) p1`, проверена на объектах проб:

```
wipy (P3e) candidate=flag
wipx (P3b) candidate=flag
intx (P3c) candidate=pass
```

## Суд по вопросам задания

- **(а) fail-closed.** Диапазон закрыт честно, это подтверждает P1b. `set -uo pipefail` стоит без `-e`
  (`set +e` после импорта кольца). rc у `rev-list` теперь проверяется явно. Последний `2>/dev/null`, влияющий
  на решение, остался в `merges_main_into_wip`, и на нём держится Рв-PP-1. Ещё два места открываются на
  ошибке: `merge-base … 2>/dev/null` и `2>&1` в `range_out` (Рв-PP-7). Новое исключение «объекта нет —
  не исключать» корректно: отсутствующий объект не может быть предком локального коммита.
- **(б) Ложные срабатывания на законных сценариях.** По всему перечню из задания их нет: f3452af5, e1109e76,
  b2a0573a9, 678c64db, 3c2962c7, int-форма и фикстуры 022. Удаление ref теперь явно не судится.
- **(в) Обходы.**
  - Рв-PP-2 — merge локального main, который опережает живой.
  - Рв-PP-1 — живой main отсутствует локально.
  - Рв-PP-4 — не-wip имя и двухходовка через не-wip ref.
  - Рв-PP-5 — int-форма прямо на wip/NNN.

  Шаблон `refs/heads/wip/*` покрывает wip/NNN/role и wip/int-NNN/role одинаково, ветки вне wip/* не покрыты совсем.

## Паразитная сложность (050)

Свойство взято не из замороженного контракта, а из слова владельца и арбитража `merge-wip-protiv-main-konflikt-norm`.
Контракта у быстрого пути нет. По каждому артефакту ответы на пять вопросов:

- **Фильтр `cat-file -e` в цикле ls-remote.**
  1. Свойство: диапазон вычислим.
  2. Состояние не вводит.
  3. Меняется 1 файл.
  4. Интерфейс тот же.
  5. Потребитель — P1b, новой грамматики нет.

  Итог: ESSENTIAL.
- **Ветвь fail-closed `range_out`.**
  1. Свойство: ошибка диапазона приводит к отказу.
  2. Состояние явное: stderr + rc.
  3. Меняется 1 файл.
  4. Интерфейс не вырос.
  5. Потребитель — P1b.

  Итог: ESSENTIAL.
- **Пропуск `lsha == ZERO`.**
  1. Свойство: удаление ref не судится.
  2. Состояния нет.
  3. Меняется 1 файл.
  4. Интерфейс не вырос.
  5. Без него удаление ref превратилось бы в fail-closed отказ.

  Итог: ESSENTIAL.
- **`LIVE_MAIN` + `merges_main_into_wip`.**
  1. Свойство: запрет merge main→wip.
  2. Состояние — глобальная переменная из снимка ls-remote, в выводе не видна.
  3. Меняется 1 файл.
  4. Интерфейс 1 аргумент.
  5. Потребителя в CI или фикстуре нет.

  Итог: ESSENTIAL по свойству, форма дефектна (Рв-PP-1/2).
- **`owner_docs_paths`.**
  1. Свойство: docs/owner пишет только owner.
  2. Состояния нет.
  3. Меняется 1 файл.
  4. Интерфейс 1 аргумент.
  5. Потребителя в CI нет. Различение merge/не-merge повторяет развилку `charter_diff_paths`, но с другой
     семантикой: `--cc` против `^1`. Дублем логики это не является.

  Итог: ESSENTIAL.

Ни одного ACCIDENTAL-блока нет.

## Итог

Код остаётся в main: он строго лучше прежнего, измеренный fail-open закрыт. Блок означает, что адресат починки,
консультант, закрывает Рв-PP-1, Рв-PP-2 и Рв-PP-3. Рв-PP-4 и Рв-PP-5 — вопросы владельцу, Рв-PP-6, -7 и -8 — советы.
Следующий круг — узкий, по закрытию этих трёх.
