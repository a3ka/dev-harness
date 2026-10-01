accept

# Reviewer 068: круг 2 — Р-1 закрыт

Предмет: `frozen/contracts/068/1`, `contracts/068-porjadok-pachki-i-mint-stroka.md`. Судимый HEAD: `902d858`
(land `wip/068/architect` поверх вердикта к1 `dae33e5`). Правка Р-1: `9eb1b75` (architect). Клон суда:
`/tmp/dev-harness-verify/rev068k2c`. Своя мера: выбрасываемый `git clone` этого клона
`/tmp/dev-harness-verify/rev068k2probe/mutA/` с `git apply` того же `rev068probe/mutA.patch`, что и в к1. Клон суда
я не правил, кроме этого файла.

По к1 (`verdicts/review/contracts-068-v1.md`) всё поле, кроме Р-1, уже принято: зоны, `--reverse`, dual-control,
mutB, env-изоляция, норма-строка и генерат. Круг 2 судит только Р-1 и проверяет, что правка ничего не сломала.

| артефакт | блоб HEAD | изменён в к2 |
|---|---|---|
| `contracts/068-porjadok-pachki-i-mint-stroka.md` | `e61c58f` | нет |
| `scripts/accept_task_commit.sh` | `8bb38c2` | нет |
| `scripts/mint_line.sh` | `43a5225` | нет |
| `fixtures/accept_task_commit/red_porjadok_diapazona_068.sh` | `7de3353` | нет |
| `fixtures/mint_line/red_mint_line_068.sh` | `31405fc` (было `98831ef`) | да |
| `roles/orchestrator.md` | `fe28d9c` | нет |
| `.omp/agents/orchestrator.md` (генерат) | `75597bb` | нет |

Вердикт связан с этими блобами. Новая редакция любого из них принятия не наследует.

## Стенограммы спавна и моя сверка

- Детектор: rc 0, локально, батч-режим. Это слово оркестратора, я его не перепрогонял.
- CI: последний завершённый прогон — `5e4ce0c` (id 36785268552, 2026-09-30T22:23:15Z), `ci` + ap1…ap5 —
  6/6 success. Сверено мной через `gh run list` и `gh run view --json jobs`. Пачка 068 не запушена, поэтому CI для
  `902d858` НЕ ПРОВЕРЕН. Батареи 068 в CI не входят (ПРОВОДКА-ЭНФОРСМЕНТ). Приёмка scoped по Н-48.
- Поле 068 неизменно: `git diff --exit-code frozen/contracts/068/1 HEAD -- contracts/068-porjadok-pachki-i-mint-stroka.md`
  → пусто, rc 0.

## Дифф круга

`git diff --name-only dae33e5 902d858` → один путь: `fixtures/mint_line/red_mint_line_068.sh`. `9eb1b75` снимает
ровно 2 строки, `config user.name orchestrator` / `config user.email orchestrator@local` в `mk_toy`. Это побайтно
форма `rev068probe/simpler.patch` из к1. `git diff 9eb1b75 902d858` пуст, land ничего не добавил. Коммит один, автор
architect, ссылка на 068 и на вердикт `dae33e5` есть. `env -i PATH HOME bash scripts/check_zones.sh .` → rc 0
(`объявленных авторов: 1 · проверено по зонам: 1524`).

После правки в фикстуре не осталось источника identity, который мог бы подставиться за субъект. Проверил
`rg 'user\.(name|email)|GIT_(AUTHOR|COMMITTER)'`. Есть `export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null`
(:68) и `unset GIT_AUTHOR_* GIT_COMMITTER_*` (:74-75). Явный `-c user.name=orchestrator` стоит только на
собственных коммитах фикстуры (`g()` :101, `authority_line` :156, м4 :249), субъект его не получает. В хосте
global identity нет (`git config --global --get user.name` → rc 1).

## Р-1: перепроверка тем же mutA

mutA — `scripts/mint_line.sh:188`, env-identity удалена из коммит-строки (`git -C "$ROOT" commit -q --no-gpg-sign …`).

| прогон | env | rc | итог |
|---|---|---:|---|
| mutA, батарея Б HEAD | обычный | **1** | `м0: КРАСНАЯ — rc=1 out= err=Author identity unknown … an=orchestrator cn=orchestrator cnt=0 dirty=чисто`; `ИТОГ 068b: ветвей 8, стабов 4, красных 2, зелёных 10` |
| mutA, батарея Б HEAD | `GIT_{AUTHOR,COMMITTER}_*=orchestrator` | **1** | м0 КРАСНАЯ `Author identity unknown`, `красных 2, зелёных 10` |
| честный, батарея Б | обычный | **0** | `ветвей 8, стабов 4, красных 0, зелёных 12, не прогнано 0` |
| честный, батарея Б | `GIT_{AUTHOR,COMMITTER}_*=architect` | **0** | `м0: ЗЕЛЁНАЯ`, `красных 0, зелёных 12` |
| честный, батарея Б | `GIT_{AUTHOR,COMMITTER}_*=orchestrator` | **0** | `м0: ЗЕЛЁНАЯ`, `красных 0, зелёных 12` |

Второй красный у mutA даёт стаб стМ4: `ПРОШЁЛ как честный (инъекция не отключила дверь)`. Это следствие того же
мутанта, коммит падает раньше двери. Ложным красным не считаю: стаб и должен краснеть, когда субъект не доходит до
двери. `an=orchestrator cn=orchestrator` в сообщении м0 у mutA — это HEAD toy до попытки (`cnt=0`), коммита субъекта
нет. Главное: м0 различает субъект с identity и субъект без неё, и красный не зависит от хоста. Глобальный конфиг
выключен, env снят, поэтому субъект без своей identity либо падает на `Author identity unknown`, либо
(хост с авто-детектом) получает identity хоста ≠ orchestrator, и `[ "$an0" = orchestrator ]` краснеет. Вторая ветвь
— [INFERENCE], на этом хосте авто-детект не срабатывает. Ловушка env-отравления тоже закрыта: отравление
orchestrator-identity не маскирует mutA, потому что фикстура снимает его до субъекта (строка 2 таблицы).

**Р-1: закрыт.**

## Живые прогоны (клон суда, обычный env)

| команда | rc | итог |
|---|---:|---|
| `bash fixtures/accept_task_commit/red_porjadok_diapazona_068.sh .` (068a) | 0 | `ветвей 3, стабов 3, красных 0, зелёных 6, не построено 0` |
| `bash fixtures/mint_line/red_mint_line_068.sh .` (068b) | 0 | `ветвей 8, стабов 4, красных 0, зелёных 12, не прогнано 0` |
| `bash fixtures/accept_task_commit/red_accept_task_commit.sh .` (регресс 037) | 0 | `ветвей объявлено 7, прогнано 7, красных 0, зелёных 7` |
| `git diff --exit-code frozen/contracts/068/1 HEAD -- contracts/068-…md` | 0 | пусто |
| `npm run -s check:gen` | 0 | `харнес соответствует roles/ (9 ролей)` |
| `env -i … bash scripts/check_zones.sh .` | 0 | `проверено по зонам: 1524` |
| `git status --porcelain` после всех | — | пусто |

## Находки

- [x] **Р-1 (БЛОКЕР к1)** — закрыт `9eb1b75`, доказано mutA → rc 1 (м0 КРАСНАЯ «Author identity unknown»), честный
  → rc 0, 12/12 при обычном, architect- и orchestrator-отравленном env.
- [ ] С-1 (совет, текст замороженного поля) — без изменений из к1, лечится следующей редакцией.
- [ ] С-2 (совет, атомарность `02aacb3` без генерата) — без изменений из к1.
- [ ] С-3 (совет владельцу/оркестратору, env-урок шире 068) — без изменений из к1, вне зон 068.
- [ ] С-4 (совет, mint_line в linked-worktree и откат без файла в HEAD) — без изменений из к1, [INFERENCE].

Новых находок нет. Советы С-1…С-4 слияние не блокируют.

## Паразитная сложность (050), дельта круга

- `fixtures/mint_line/red_mint_line_068.sh`, −2 строки: (1) Р5 / инв. 6, теперь различимо; (2) состояние
  убавилось, toy-конфиг больше не несёт identity; (3) 1 файл, число не выросло; (4) интерфейс не изменён;
  (5) приёмка Р4–Р7. Дельта снимает ACCIDENTAL-двойную identity из к1. Новых артефактов нет.

## Вердикт

**accept.** Р-1 закрыт, предъявлен красный на mutA и зелёный на честном субъекте в трёх средах. Поле 068 неизменно
с заморозки. Живые 068a/068b/037/gen/zones — rc 0. Остальное поле принято кругом 1 и правкой не тронуто (блобы выше).
