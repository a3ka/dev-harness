FAIL

# Ревьюер — контракт 012, полный финальный гейт, HEAD `10cc9b0`

## Блокирующая находка 1 — область правки

**Класс: превышение ЗОНЫ / неатомарная примесь процессных наблюдений в предметный диапазон.**

Замороженный контракт объявляет только:

```text
ЗОНА architect: contracts/012-izoljacija-progonov.md scripts/check_runner_hygiene.sh fixtures/check_runner_hygiene/
ЗОНА implementer: scripts/verify_antiplacebo.sh roles/orchestrator.md roles/architect.md .omp/config.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
```

В историческом диапазоне от родителя начального предметного коммита
`20fd5ad..frozen/contracts/012/1` четыре коммита с фактическим
`%an=architect` изменяют `NABLIUDENIA_ARCHITECT.md`, которого в ЗОНЕ architect
012 нет и который не объявлен `СПАСЕНО`:

```text
commit=7e8852bfccc1a9e11aaa795d4a30168f9ebf7aec
author=architect <architect@dev-harness.local>
subject=наблюдения А-16 (multi-hunk edit по устаревшим строкам) и А-17 (next_id.sh без identity после unset Н-56) — по итогам пачки 012

M	NABLIUDENIA_ARCHITECT.md
commit=f6853785d60e5723f6795eca0d27915e535bb97d
author=architect <architect@dev-harness.local>
subject=де-флейк ветви scratchdef (наследие 011): зонд без раннего break — флаги seen/locked сходятся за полный срок прогона

M	NABLIUDENIA_ARCHITECT.md
M	scripts/check_runner_hygiene.sh
commit=998459c59f67b2dcf5aa1e6c7a1db315caadbaf4
author=architect <architect@dev-harness.local>
subject=А-20: git add литеральным путём отклоняется при байт-идентичном имени — обход $(ls <glob>), причина открыта

M	NABLIUDENIA_ARCHITECT.md
commit=8119cac8c5e3a773b6a3a2dfdc0beaae8dd055a6
author=architect <architect@dev-harness.local>
subject=наблюдения А-21..А-23 (круг 1 критика 012: неприкосновенность не наблюдалась входом; коллизия райдеров на один скратч; повтор правила cut -c) + дополнение А-20 (git add -- по одному пути прошёл)

M	NABLIUDENIA_ARCHITECT.md
HISTORICAL_LOG_EXIT_RC=0
```

Это не исправляется зелёным `check_zones.sh`: его собственная шапка устанавливает
диапазон **от первой заморозки**; `frozen/contracts/012/1` поставлен после всех
четырёх хешей. Поэтому эти коммиты не входят в его проверяемый диапазон 012.
Проверка всех предметных коммитов историческим `git log --format` была отдельным
требованием этого гейта именно для такого случая. Поскольку расширение области
не объявлено в контракте и не имеет отдельного решения/`СПАСЕНО`, это отказ, а
не совет. Коммит `f685378` вдобавок соединяет в одном коммите разрешённую правку
барьера с не относящейся к ЗОНЕ записью наблюдения, то есть нарушает атомарность.

## Прочитанные предмет и предшествующие вердикты

Прочитаны целиком `contracts/012-izoljacija-progonov.md`, исторический FAIL
критика из `e9814c0:verdicts/critic/contracts-012-v1.md` и текущий accept
`verdicts/critic/contracts-012-v1.md`. Проверены полные диффы `008e28a`,
`f685378`, `ccda380`, `268ad56` и акты критика/переименования. Первый critic-FAIL
закрыл только неприкосновенность существовавшего default-scratch; текущий
critic-accept не является разрешением на перечисленные четыре внезонные правки.

## Сырой вывод обязательных гейтов

Все запрошенные механические гейты зелёные; они не отменяют блокирующее
историческое нарушение области правки.

```text
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40
[exit=0]

$ bash scripts/check_zones.sh
замороженных контрактов: 11 · объявленных авторов: 5 · коммитов в диапазонах: 239 · проверено по зонам: 161
[exit=0]

$ bash scripts/check_contract_frozen.sh
  ok   contracts/012-izoljacija-progonov.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 15 · черновиков: 3 · заморожено: 12 · реестр: full
[exit=0]

$ npm run check:charter
уставных документов: 14 · изменений в них: 37 · с разрешения: 37
[exit=0]

$ npm run check:ceilings
  ok   персоны: 8 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 11 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]

$ npm run check:ci-parity
workflow-команд: 22 · скриптов в приёмке: 34 · объявленных исключений: 12 · расхождений: 0
[exit=0]

$ bash scripts/check_scoped_run.sh
check_scoped_run: ветви «all» зелены
[exit=0]
```

`verify_antiplacebo` до первого запуска был прерван лимитом инструмента на 600 с
после 24 фикстур; итоговый приведённый выше повтор был самостоятельным полным
прогоном и завершился rc=0 с 40/40. В него вошли все 40 именованных фикстур,
включая шесть 012 (`lockdef`, `techka`, `pidrec`, `izolcfg`, `klon`, `izolnorm`).

## Итог

**FAIL.** Один класс блокирующей находки: четыре предметно привязанные правки
вне объявленной ЗОНЫ architect; одна из них также смешана с разрешённой правкой
барьера в неатомарном коммите. Ни код, ни нормы других ролей не изменялись.
