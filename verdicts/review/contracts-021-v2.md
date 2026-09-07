accept

# Ревью контракта 021, v2

Проверен `HEAD 3d67b9571715392fcea3fa3a16805b21491084f7` против
`frozen/contracts/021/2` в одноразовом клоне
`/tmp/dev-harness-verify/rev021`. Основной checkout до записи этого вердикта
не использовался для репро. Полный прогон не выполнялся: для этого круга Н-48
предписывает scoped-регресс; CI уже зелёный на `3d67b95`.

## Неизменность заморозки

Сырой прогон:

```text
$ git diff frozen/contracts/021/2 HEAD --stat -- contracts/ plans/
diff_rc=0
$ git rev-parse frozen/contracts/021/1
78cbc3f5872244e1e4eb556e026cde04cb1957a1
$ git rev-parse frozen/contracts/021/2
a200b82a4684724e5d6d9f1067aa9c37ebcc0ebb
```

Статистика пуста; оба тега доступны. Нормативный текст после v2 не менялся.

## Закрытие обхода 44e81e7

В клоне предмет `scripts/measure_parallel_windows.sh` был временно заменён
слабой формой: для `001 002` она честно сравнивала числовые моменты, для
любой иной пары возвращала `0`. Это репро не меняло основной checkout.

Сырой результат против слабой формы:

```text
$ bash fixtures/check_zones/red_mera_parallelnosti_okon.sh
ОТКАЗ: последовательная пара 005/007 принята за параллельную (зашитая на 001/002 форма обязана умереть здесь — обход 44e81e7): rc=0

rc=1

$ bash fixtures/check_zones/probe_slabye_realizacii.sh
пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые (scoped-прогоном раннера), лексикографическая, зашитая-пара; честная форма меры (моменты, %ct) проходит
rc=0
```

После восстановления предмета `git diff --exit-code --
scripts/measure_parallel_windows.sh` дал `restore_rc=0`. Честная форма:

```text
$ bash fixtures/check_zones/red_mera_parallelnosti_okon.sh
red_mera_rc=0
$ bash fixtures/check_zones/probe_slabye_realizacii.sh
пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые (scoped-прогоном раннера), лексикографическая, зашитая-пара; честная форма меры (моменты, %ct) проходит
probe_rc=0
```

В `red_mera_parallelnosti_okon.sh` сохранены ворота 1--4 и добавлены ворота
5--6 на `005/007`: перекрытие и последовательная пара с требованием
`не параллельно`. Фаза 6 `probe_slabye_realizacii.sh` именует
`зашитая-пара`. Поэтому обход из вердикта 44e81e7 отклоняется именно
различающим входом, а не изменением ожидания под предмет.

## Scoped-регресс и проводка

Сырой вывод команд из клона:

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_zones
барьеров: 1 · фикстур: 19 · предъявлено красным повторным прогоном: 19
rc=0

$ bash scripts/verify_antiplacebo.sh . --scope land_agent
барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9
rc=0

$ bash fixtures/check_zones/red_mera_parallelnosti_okon.sh
rc=0

$ bash fixtures/check_zones/probe_slabye_realizacii.sh
пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые (scoped-прогоном раннера), лексикографическая, зашитая-пара; честная форма меры (моменты, %ct) проходит
rc=0

$ bash fixtures/check_zones/_schet_fixtur.sh
rc=0

$ bash scripts/check_zones.sh .
замороженных контрактов: 19 · объявленных авторов: 2 · коммитов в диапазонах: 482 · проверено по зонам: 349
rc=0

$ npm run check:nabludenia
npm notice run bash scripts/check_nabludenia.sh
rc=0

$ npm run check:measure-probe
npm notice run bash fixtures/check_zones/probe_slabye_realizacii.sh
пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые (scoped-прогоном раннера), лексикографическая, зашитая-пара; честная форма меры (моменты, %ct) проходит
rc=0

$ npm run check:ci-parity
workflow-команд: 28 · скриптов в приёмке: 45 · объявленных исключений: 17 · расхождений: 0
rc=0
```

Независимый инвентарь `fixtures/check_zones/case_*.sh` дал 19 файлов; это
отдельная мера от вывода scoped-раннера и подтверждает счёт семьи.

## Область правки и происхождение

`git diff --name-status frozen/contracts/021/2..HEAD` содержит только:

- implementer-зону: `.github/workflows/ci.yml`, `package.json`,
  `scripts/check_zones.sh`, `scripts/lib_zones.sh`;
- architect-зону: `fixtures/check_zones/`, `NABLIUDENIA_ARCHITECT.md`;
- судейскую зону: `verdicts/adversary/contracts-021-v2.md`;
- orchestrator-зону: `HANDOFF.md`.

`contracts/` и `plans/` в этой дельте отсутствуют. Допустимый
`scripts/measure_parallel_windows.sh` уже содержался в v2-срезе и после
`frozen/contracts/021/2` не менялся.

Сырой first-parent журнал без merge-коммитов:

```text
44e81e7  adversary     verdict: adversary contract 021 v2
ebaea55  orchestrator  HANDOFF: диагноз 7 расхождений батареи доказан …
b9acf43  orchestrator  HANDOFF (аварийный стоп): v2 frozen 4b23d46 …
```

Рабочие коммиты пришли вторыми родителями `land`-merge: `742494e`
(implementer), `219a7b4`, `61274e4`, `3d67b95` (architect). Прямого рабочего
коммита в main не обнаружено. Закрытие обхода — отдельный рабочий коммит
`9d7bb71` и его отдельный merge `3d67b95`; оно атомарно по предмету.

## Независимость проверок

Новые `case_*`, `red_mera`, `probe_slabye_realizacii.sh` и стаб закрытия
внесены architect (`2cfbe98`, `9d7bb71`); реализация и CI-проводка внесены
implementer (`6549021`, `9c78ed6`) и пришли отдельным merge. В шапках новых
case-файлов до тела указана `ПРИЧИНА: коммит вне зоны`; в
`case_regress_posledovatel_naja_istorija.sh` различающие входы 1--2 находятся
до первой зелёно-красной пары. Scoped-раннер предъявил для всех 19 case
зелёный контроль и повторный красный запуск с именованной причиной.

Проверены ссылки исторических вердиктов. Текущие команды из вердикта
adversary воспроизводятся выше. Critic v2 явно фиксирует предмет
`f0e1241`; этот коммит является предком HEAD (`ancestor_rc=0`) и его
упомянутый исторический файл `fixtures/check_zones/red_regress_posledovatel_naja_istorija.sh`
доступен в этом объекте (`cited_file_rc=0`). В текущем дереве он ожидаемо
заменён `case_regress_posledovatel_naja_istorija.sh` согласно clean cutover.
Дополнительно текущий `bash scripts/check_charter.sh .` дал
`уставных документов: 22 · изменений в них: 54 · с разрешения: 54`, `rc=0`.

## Находки и советы

Находки, включая обходы: отсутствуют.

Советы: отсутствуют.
