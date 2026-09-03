accept

# Контракт 019 — круг reviewer 1

Проверка выполнена в одноразовом клоне `/tmp/rev019-review-clone`.
Боевые и ручные пробы выполнялись только там; основной checkout до записи этого
вердикта не запускался и не переключался. Клон был создан на `0666936`, затем
получил только процессный коммит `c7e1f19` (`HANDOFF.md`) через `git fetch`; этот
файл относится к явно разрешённым процессным артефактам. У каждой ручной пробы
раннер создавал новый `WORK`; адресные подстановки также запускались отдельными
вызовами.

## 1. Область правки и атомарность — пройдено

Сырой зонный прогон на судимой вершине:

```text
$ bash scripts/check_zones.sh .
...
процессных вне суда: ...
замороженных контрактов: 18 · объявленных авторов: 5 · коммитов в диапазонах: 453 · проверено по зонам: 336
RC check_zones=0
```

Дополнительно проверен `git log --no-merges --format='---%h|%an|%s' --name-only
frozen/contracts/019/1..0666936`; каждая строка распределяется следующим образом.

| Коммиты | файлы / назначение | результат |
|---|---|---|
| `a448e0e`, `06b39c3`, `274fa0f`, `f5de0b8`, `f6ce533` | боевые `scripts/spawn_agent.sh`, `next_id.sh`, `check_charter.sh`, `check_staged.sh` | зона `implementer` |
| `7b14e2a`, `45c0a0c`, `158b074`, `6889a4f`, `8e51e90`, `fe20953`, `53f15fe`, `eba8bef`, `842993b` | `fixtures/check_staged/`, `fixtures/spawn_agent/`, `fixtures/check_charter/`, `NABLIUDENIA_ARCHITECT.md` | зона `architect` |
| `bf46774`, `2156f2b`, `48436c5`, `f6c90c4`, `4dfde81`, `1ec896c`, `9a6c18f`, `0666936` | `verdicts/adversary/contracts-019.md` | зона `adversary` |
| `851a477`, `209ba25` | `verdicts/critic/contracts-019*.md` | зона `critic` |
| `ebc57db`, `fa0d354` | `verdicts/arbitration/` | судейский артефакт |
| `a85de78`, `afaccd3`, `0bbf370`, `e5e0455`, `cdfb3eb`, `b6b5df6`, `31b106b`, `71bda60`, `c7e1f19` | `NABLIUDENIA_ARCHITECT.md`, `NABLIUDENIA.md`, `HANDOFF.md` | разрешённый процессный артефакт |
| `12ded48`, `373e07b`, `8cef968`, `c250911`, `d97403f` | `NABLIUDENIA_ARCHITECT.md` | зона `architect` |
| `af77316`, `23d42de` | `roles/`, `.omp/agents/` | норма R1/R4 по слову владельца, вне кодовой приёмки 019 |
| `98340f1` | `.gitignore`, `contracts/020-*.md` | разрешённый владелец-канал; вне предмета 019 |
| `8998cd4` | `contracts/020-*.md` | единственный `СПАСЕНО` draft-пуск 019 |
| `b0e8c8e` | `contracts/019-ustav-draft-klyuchi.md` | зона `architect`, v2-лечение |
| merge `6f7d71c` | перенос той же v2-дельты | merge; авторская дельта уже находится в `b0e8c8e` |

Изменения предмета разнесены по отдельным коммитам реализации и фикстур; проверки
не менялись implementer-автором. Необъявленного вне-зонного файла не найдено.

## 2. Заморозка v2 — пройдена

```text
$ git diff --stat frozen/contracts/019/2..HEAD -- contracts/ plans/
<пусто>
$ git diff --unified=0 frozen/contracts/019/1..frozen/contracts/019/2 -- contracts/019-ustav-draft-klyuchi.md
+СПАСЕНО architect: 8998cd41bfd9622d7634c02e5bd119567b4e17d8 — draft-пуск ветви 2 контракта 019 ...
$ git merge-base --is-ancestor frozen/contracts/019/2 HEAD
RC freeze-stat=0 v1-v2=0 reachable=0
```

Дельта v1→v2 — одна строка `СПАСЕНО` в разделе зон; тег v2 достижим.

## 3. §Предмет реализован — пройден

| Предмет | Реализующий коммит | Наблюдение в боевом коде |
|---|---|---|
| Уставное делегирование | `274fa0f`, `f5de0b8` | `check_charter.sh:is_charter_path` — единый предикат; `check_staged.sh:268-276` вызывает `check_charter`, сохраняет вывод и ненулевой rc; `charter_diff_paths` судит merge по `^1`. |
| Draft next-id без резерва | `06b39c3`, `f5de0b8` | `next_id_peek` читает четыре источника и не создаёт тег; `check_staged.sh:248-250,278-293` пропускает только `architect` + `contracts/<next>`. |
| Octal-фикс spawn | `a448e0e` | `spawn_agent.sh:122`: `printf '%03d' "$((10#$nnn))"`. |

Сырая ручная проба на новом рабочем репозитории:

```text
$ bash scripts/spawn_agent.sh --root /tmp/rev019-spawn-manual/repo --author architect --nnn 19
BRANCH=wip/019/architect
$ bash scripts/spawn_agent.sh --root /tmp/rev019-spawn-manual/repo --author architect --nnn 042
BRANCH=wip/042/architect
RC 19=0 042=0
```

## 4. Сырые scoped-прогоны — пройдены

| Команда | rc | сырой итог |
|---|---:|---|
| `--scope check_staged` | 0 | `барьеров: 1 · фикстур: 23 · предъявлено красным повторным прогоном: 23` |
| `--scope next_id` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_charter` | 0 | `барьеров: 1 · фикстур: 8 · предъявлено красным повторным прогоном: 8` |
| `--scope spawn_agent` | 0 | `барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2` |
| `--scope check_hooks` | 0 | `барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7` |
| `--scope check_zones` | 0 | `барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13` |
| `--scope check_staged/case_draft_sledujushhij_id` | 0 | зелёный контроль и повторный красный `вне зоны` предъявлены |
| то же, `CHECK_STAGED_ZANJATYJ_NOMER=137` | 0 | `фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| то же, `CHECK_STAGED_ZANJATYJ_NOMER=482` | 0 | `фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_zones/case_spaseno_ne_nazvannyj_hash` | 0 | повторный красный `коммит вне зоны` предъявлен в полном `check_zones` scoped-выводе |

Адресные красные против подстановок выбора компоненты были получены отдельными
запусками с отдельным `WORK`:

```text
$ after-wip stub; bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
FAIL check_staged/case_draft_sledujushhij_id.sh: барьер остался зелёным на обманном дереве — красное не предъявлено
KOMP1 after-wip stub RC=1

$ min-selector stub; bash scripts/verify_antiplacebo.sh . --scope check_staged/case_draft_sledujushhij_id
FAIL check_staged/case_draft_sledujushhij_id.sh: барьер остался зелёным на обманном дереве — красное не предъявлено
KOMP2 min-selector stub RC=1
```

После каждой подстановки `scripts/next_id.sh` восстановлен побайтно:
`RESTORED next_id.sh RC=0`.

## 5. Вердикты adversary и арбитражи — пройдены

`verdicts/adversary/contracts-019.md` содержит круги 1–8 и завершается
`## Круг 8` / `accept`. Названные им правки существуют в истории: меры М-1 и
М-2 арбитража `ebc57db` реализованы `f6ce533` и `fe20953`; решение арбитража
`fa0d354` отражено в `eba8bef` и `842993b`. Наблюдённые KOMP1/KOMP2 красные
подстановки выше согласуются с финальной секцией круга 8, а не только с её
пересказом.

## 6. Проверки не подогнаны под реализацию — пройдены

Новые входы находятся в фикстурах автора `architect`, а реализация — в коммитах
`implementer`. В шапке `case_draft_sledujushhij_id.sh` граница контрпримера
привязана к коду `next_id_max_for_class`: четыре источника, фильтры класса,
грамматика, KOMP1/KOMP2 и параметр `CHECK_STAGED_ZANJATYJ_NOMER`. В коде case
создаются изолированные репозитории и ассерты расположены до ожидаемого
красного кандидата. Это соблюдает Н-39: стаб привязан к входу, на котором
его дефект наблюдаем, а не к формулировке контракта. Демаркация валидного
контрпримера присутствует с первой редакции draft 020 (`contracts/020-...:51-56`):
константная инвариантность вместе с расхождением на конформном входе.

## 7. Пакет лечения Н-77 — пройден

```text
$ bash scripts/check_ceilings.sh .
  ok   раздел требований: 19 черновик(ов) судится, замороженные — по тегам
потолки в порядке
$ bash scripts/check_ids.sh .
  ok   номера уникальны и согласованы с регистром выдачи
RC ceilings=0 ids=0

$ git show -s --format='%B' b0e8c8e
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/019-ustav-draft-klyuchi.md v2: СПАСЕНО первого draft-коммита (8998cd41) ...
$ git show -s --format='%B' 6f7d71c
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/019-ustav-draft-klyuchi.md v2: СПАСЕНО первого draft-коммита (8998cd41) ...
```

`contracts/020-...` содержит литеральный раздел `## Предмет`; его тело проходит
`check_ceilings` без пустой строки и переноса. Реестр `id/CONTRACT/020` указывает
на `8998cd4`; единственная полная запись `СПАСЕНО` v2 указывает тот же полный
хеш и автора из ЗОНА-строки. Удаление этой записи в отдельном клоне красит
`check_zones` ровно на `8998cd41`, что подтверждено также scoped case
`case_spaseno_ne_nazvannyj_hash`.

## Статус пунктов задания

| Пункт | Статус | факт |
|---:|---|---|
| 1 | пройден | `check_zones` rc 0; все пути диапазона распределены по зонам или объявленным исключениям |
| 2 | пройден | v2 достижим; v1→v2 содержит только одну `СПАСЕНО`-строку |
| 3 | пройден | три боевые ветви и их коммиты приведены в таблице предмета |
| 4 | пройден | шесть scoped-прогонов rc 0, адресные draft/СПАСЕНО пробы предъявлены |
| 5 | пройден | круги adversary 1–8, М-1/М-2 и правка 5 сопоставлены с деревом |
| 6 | пройден | фикстуры отделены от кода; KOMP1/KOMP2 дали именованный rc 1 против сломанных выборов |
| 7 | пройден | `check_ceilings` и `check_ids` rc 0; `РАЗРЕШИЛ-ВЛАДЕЛЕЦ` есть в `b0e8c8e` и `6f7d71c` |
