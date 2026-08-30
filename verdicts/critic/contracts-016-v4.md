accept

Судим только закоммиченную дельту замороженного контракта `frozen/contracts/016/3..bc65df2` по `contracts/016-izoljacija-agenta.md`: две замены ЗОНА-строк и одну новую строку `СПАСЕНО`. Блокирующих находок и советов нет.

## Результат суда

- `contracts/016-izoljacija-agenta.md:157-159` — дельта минимальна: изменены ровно три результирующие строки контракта. В сыром diff это `3 insertions(+), 2 deletions(-)`: в зоне `architect` появились только `fixtures/spawn_agent/`, `fixtures/land_agent/`, `fixtures/gc_agent_branches/`; из зоны `implementer` удалены только те же три пути; добавлена одна строка `СПАСЕНО implementer`. Других строк и hunk-ов нет.
- `contracts/016-izoljacija-agenta.md:157-158` — перенос не ослабляет границы механизма: все `scripts/*`, включая `scripts/spawn_agent.sh`, `scripts/land_agent.sh`, `scripts/gc_agent_branches.sh`, остались у `implementer`; у `architect` прибавились ровно три каталога постоянных проверок срезов 2–4.
- `contracts/016-izoljacija-agenta.md:159` — `СПАСЕНО` соответствует грамматике: объявленный автор `implementer`, четыре разделённых пробелами 40-символьных hex-коммита и непустая причина после `—`. Все четыре объекта существуют и достижимы из текущего `main`.
- `contracts/016-izoljacija-agenta.md:159` — множество `СПАСЕНО` полно и точно: независимый `git log` по трём перенесённым каталогам в диапазоне `frozen/contracts/016/1..HEAD` вернул ровно `cf2d3ebabb7b981f9d54f58622d1d6b143cbda1f`, `2681d066830bcf78f89109badefb3383857305eb`, `e6ad94512f1ea4a765989511f84f3161dc34a12a`, `136f1a5ea3eae35354d5861dc6bad7f983aa46da` — без пропусков и лишних хешей.
- `AGENTS.md:141-145,231-234` и коммит `bc65df2` — изменение замороженного текста разрешено: author/committer изменяющего коммита — `architect`, а тело с первой колонки содержит `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/016-izoljacija-agenta.md` с причиной переноса зон и добавления `СПАСЕНО` и датой слова владельца 2026-08-30.

## Проверки

Все команды выполнены в изолированном клоне `/tmp/critic-016-v4-repo` от закоммиченного HEAD `bc65df2c79d49ec4e3b884e22cac31c5fd31e187`.

1. Минимальность и точный перенос:

   ```text
   git diff --unified=4 frozen/contracts/016/3..HEAD -- contracts/016-izoljacija-agenta.md
   rc=0
   ```

   Результат: один файл, один hunk, `3 insertions(+), 2 deletions(-)`; две ЗОНА-строки заменены только переносом трёх каталогов, третья добавленная строка — `СПАСЕНО`.

2. Полнота `СПАСЕНО`, пересчитанная независимо от текста строки:

   ```text
   git log --author=implementer frozen/contracts/016/1..HEAD --format=%H -- fixtures/spawn_agent fixtures/land_agent fixtures/gc_agent_branches
   rc=0
   ```

   Выведены ровно четыре полных хеша, перечисленные выше, в том же порядке.

3. Авторство и разрешение изменяющего коммита:

   ```text
   git show -s --format='%H%n%an <%ae>%n%B' bc65df2
   rc=0
   ```

   Выведены полный хеш `bc65df2c79d49ec4e3b884e22cac31c5fd31e187`, identity `architect <architect@dev-harness.local>` и непустая строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` с путём контракта и причиной.

4. Пробная заморозка v4 и механический суд зон:

   ```text
   git tag frozen/contracts/016/4 HEAD
   rc=0
   bash scripts/check_zones.sh .
   rc=0
   git tag -d frozen/contracts/016/4
   rc=0
   ```

   Барьер распознал три новых зоны `architect`, сохранил все script-пути за `implementer` и вывел четыре строки `контракт 016: коммит … (implementer) — СПАСЕНО, из суда зон выведен`. Итог: `замороженных контрактов: 15 · объявленных авторов: 6 · коммитов в диапазонах: 373 · проверено по зонам: 278`.

5. Уборка пробного тега:

   ```text
   git tag --list 'frozen/contracts/016/*'
   rc=0
   ```

   Остались только постоянные теги `frozen/contracts/016/1`, `/2`, `/3`; пробного `/4` нет.

После коммита этого `accept` разрешена заморозка v4; затем `architect` может пере-авторствовать proof-кейсы в переданных каталогах и предъявить их ре-ревьюеру.
