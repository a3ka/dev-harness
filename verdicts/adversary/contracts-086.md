FAIL

# Вердикт adversary: контракт 086

Проверен PR #40, SHA `5c92f3c`, в одноразовом SSH-клоне
`/tmp/dev-harness-verify/Judges086/repo`.

## F1: удаление вне frozen-ЗОНЫ принято land

Правило (а) обязано судить любой путь вне frozen-ЗОНЫ. В
`scripts/gejt_svedenija.sh` путь извлекается только для статусов A/M:

```bash
g diff-tree -r --no-commit-id --name-status --no-renames "$c" | awk '$1 == "A" || $1 == "M" { print $2 }'
```

Обманный стаб «судить additions/modifications, но не D» проходит имеющиеся
A1–L7/H1–S1. Честная реализация SHA предмета на игрушечном frozen-контракте
900 (implementer имеет только `src/`) приняла удаление
`docs/owner/existing.md` и сдвинула main:

```text
$ bash /tmp/dev-harness-verify/Judges086/repro_086_adversary.sh .
DELETE_OUTSIDE_ZONE rc=0 LANDED main=31e0ed1de6c49411976bc7f2a9c6bce7fa10e40c branch=wip/900/implementer
```

Ожидание: `ОТКАЗ 086 (land)` правила (а), rc 1, main неизменён. Факт: rc 0.

## F2: sync-merge с main третьим родителем октопуса принято

Frontier 4 требует предикат при любом числе и порядке родителей. Однако
`sync_violation()` выделяет только первые две позиции `%P`:

```bash
p1="${parents%% *}"
p2="${parents#* }"
```

Обманный стаб «рассматривать только первого и второго родителей» не пойман
семьёй. Репро создаёт октопус `wip, side1, side2, main`: `main` — четвёртый
родитель и не предок других кандидатов. Честная реализация пропустила его и
посадила ветку:

```text
Trying simple merge with side1
Trying simple merge with side2
Trying simple merge with main
OCTOPUS_GATE rc=0 parents=f08b0c59b16a981cd383ef67be93cf9ae9ed3dfd d1d28dbd943cc6035f1aeb62f647481ace2fc483 d98bf85c47f7ab5f0f195610b4ab19e473887d21 afa6c8a8e064ef8b76755dd666e470e98f5e4e97 окно 086: afa6c8a8e064ef8b76755dd666e470e98f5e4e97..11b257c58419f118335120bc43dbe98d99c5595b (4 коммит.)
OCTOPUS_LAND rc=0 LANDED main=9834fb59c58c4a8866d7da2139a6eb6548988fd6 branch=wip/900/implementer
ADVERSARY_REPRO: both invalid inputs passed
```

Ожидание: правило (б), SHA merge и rc 1 до записи main.

## F3: `check_zones --okno` и `check_charter --okno` отсутствуют

Инвариант 5 / Frontier 2 требуют у обоих существующих судей `--okno <база>`.
Их CLI на SHA предмета принимает лишь необязательный корень и игнорирует
дальнейшие argv. Обманный стаб «всегда судить всю историю» проходит.

Репро содержит старое нарушение ниже базы и чистый коммит выше базы; по
контракту оба запуска должны быть зелёными, но они судят старое:

```text
$ bash /tmp/dev-harness-verify/Judges086/repro_086_window.sh .
WINDOW_ZONES rc=1   FAIL коммит вне зоны: implementer c3294f0d docs/owner/old.md — зона автора (объединение всех замороженных): src/  замороженных контрактов: 1 · объявленных авторов: 2 · коммитов в диапазонах: 2 · проверено по зонам: 2
WINDOW_CHARTER rc=1   ok   AGENTS.md — уставной с ustav/1, коммитов в диапазоне 2, изменений без разрешения нет   FAIL уставной документ изменён без разрешения владельца: ROADMAP.md в 5418a5d3 — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md <причина>» в первой колонке   ok   contracts/900-igrushka.md — уставной с frozen/contracts/900/1, коммитов в диапазоне 2, изменений без разрешения нет
ADVERSARY_WINDOW_REPRO: both advertised window modes judged violations below base
```

## Положительные контроли и предъявленная батарея

```text
$ bash fixtures/_krasnye_086.sh fast
ЗЕЛЕНО: A1
ЗЕЛЕНО: A5
ЗЕЛЕНО: L2
ЗЕЛЕНО: L5
ЗЕЛЕНО: H1
ИТОГ 086 (fast): rc=0

$ bash fixtures/_krasnye_086.sh
стаб-пак 086: 13/13 поймано, диффпроба 13/13
ИТОГ 086 red_accept_086.sh: зелёных 6, красных 0, не исполнено 0
ИТОГ 086 red_land_086.sh: зелёных 8, красных 0, не исполнено 0
ИТОГ 086 red_huk_spawn_086.sh: зелёных 5, красных 0, не исполнено 0
ИТОГ 086 red_istorija_1_086.sh: зелёных 3, красных 0, не исполнено 0
ИТОГ 086 red_istorija_2_086.sh: зелёных 3, красных 0, не исполнено 0
КРАСНО: R8: rc=0 (ожидался 1) за 7 с:
NOT_IMPLEMENTED: профиль не найден: .../fixtures/parsing_hygiene_battery/profiles/gejt_svedenija.sh
ИТОГ 086 (polnyj): rc=1
```

R8 и отсутствующий profile — известные architect-находки, не основания этого
FAIL. Встроенный `red_stuby_086.sh` исполнен полным прогоном: 13/13 и его
диффпробы 13/13 — положительный контроль предъявленной семьи.

## Проводка, зона, frozen

```text
$ bash scripts/verify_antiplacebo.sh --scope check_zones check_charter land_agent spawn_agent check_hooks
SCOPED: барьеров 5 из выборки — не для приёмки
... case-пробы check_charter/check_hooks/check_zones до прерывания: ok ...
rc=137
```

Проводка не зелёная: вместо требуемого окна дошла до полного `check_charter`
и была прервана. Это не заявляется как success.

Диапазон реализации `27c5b31b..5c92f3c`:

```text
A .githooks/pre-merge-commit
M scripts/accept_task_commit.sh
A scripts/gejt_svedenija.sh
M scripts/land_agent.sh
M scripts/spawn_agent.sh
```

По architect-зоне в том же диапазоне вывода нет. Frozen-текст неизменён:

```text
$ git diff --exit-code frozen/contracts/086/1 5c92f3c -- contracts/086-gejty-svedenija-integracii.md
frozen_contract_rc=0
```
