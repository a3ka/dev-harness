accept — контракт 062, круг 2: Р-1/Р-2 закрыты; прежние и новые обманные реализации пойманы, честный контроль зелёный.

# Adversary 062 к2 — атрибуция окна потребителей после Р-1/Р-2

## Стенограммы и судимая база

- Судимый HEAD: `8e52c20ce1617c4e6c11bc95b7fc13a678fc48cc`.
- Предыдущий adversary-вердикт: `d3bac14e9c17630ea536c219f74602b6de2a5d1f`,
  `verdicts/adversary/contracts-062-v1.md`, первая строка `accept`.
- Ревьюерская стенограмма: `f228af70f8a2806504f5d8ae9e435a225dbf3360`,
  `verdicts/review/contracts-062.md`, первая строка `FAIL`: Р-1 (неподключённая
  проводка) и Р-2 (`diff-tree`-отказ становился vacuous rc 0).
- Исправление: `82b40d841fc3cdc7832e9ac7573f7d277fd946a8`
  (`062: Р-1 проводка (ci-шаг+ключ) + Р-2 fail-open diff-tree`), прилендовано
  `6a22e663f54389c130ed4714dbc0f0b951f417d5`.
- Предмет и проверка не менялись. Мутанты создавались только в выбрасываемых
  копиях `/tmp/dev-harness-verify/adv062c-*-mutant`.

## Позитивный контроль и прежние мутанты

`bash fixtures/check_consumers/krasnye_062.sh` дал **rc 0**:

```text
062: честных клеток 8, зелёных 8, красных: нет
062: стабов 6, поймано 6, ускользнуло: нет
062: диффпроб стабов без ручки 6, зелёных 6, провал: нет
итог 062: rc=0
```

Это одновременно даёт честный положительный контроль и ловит встроенные
stubs: линейный судья, пустое окно, «все land чужие», «все merge чужие»,
endpoint-фильтр и «ошибка → пустота» — все 6/6 пойманы; их диффпробы 6/6
зелёные.

Три прежние семантические подмены п2 я снова предъявил как изменённые
`check_consumers.sh` в отдельных копиях и прогнал той же батареей:

| Подмена | Результат | Клетки, сделавшие батарею красной |
|---|---:|---|
| Только tip (`rev-list … $last_frozen..HEAD` заменён на `rev-parse HEAD`) | **пойман**, rc 1 | к3 (свой land), к6 (внутренний merge), к8 |
| Чужой land включён (ветвь исключения стала `;;`) | **пойман**, rc 1 | к1 |
| Свой land исключён как чужой | **пойман**, rc 1 | к3 |

Ни одна из этих неверных реализаций не прошла зелёной.

## Р-1: проводка существует и жива

На судимом дереве:

```text
$ npm run check:consumers-window-family-selftest
> bash fixtures/check_consumers/krasnye_062.sh
… итог 062: rc=0

$ grep -nF 'run: bash fixtures/check_consumers/krasnye_062.sh' .github/workflows/ci.yml
192:        run: bash fixtures/check_consumers/krasnye_062.sh

$ bash scripts/check_provodka.sh . contracts/062-atribucija-okna-potrebitelej.md
rc=0

$ bash scripts/verify_ci_parity.sh .
workflow-команд: 51 · скриптов в приёмке: 63 · объявленных исключений: 23 · matrix-ключей: 46 · анти-плацебо-запусков: 2 · расхождений: 0
rc=0
```

Новая поверхность проверена обманным стабом «проводка-фантом» в двух формах:

| Мутант в отдельной копии | Наблюдение | Вердикт проверки |
|---|---|---|
| Строка CI `run: bash fixtures/check_consumers/krasnye_062.sh` закомментирована | `verify_ci_parity.sh` назвал отсутствующий в CI `check:consumers-window-family-selftest`; 1 расхождение | **пойман**, rc 1 |
| Ключ `check:consumers-window-family-selftest` перенаправлен на зелёный `bash fixtures/_krasnye_060.sh` | Живой `npm run check:consumers-window-family-selftest` действительно прогнал *060* и вернул rc 0; затем `verify_ci_parity.sh` назвал отсутствующую приёмку CI-команды 062 и осиротевший `check:samodostatochnost-family-selftest` | **пойман паритетом**, rc 1 (2 расхождения) |

Тем самым ложная зелень неправильно направленного ключа не принимается за
подключение 062: `verify_ci_parity` разрывает её до CI.

## Р-2: `diff-tree` fail-closed

Запущена проба ревьюера:

```text
$ bash /tmp/dev-harness-verify/rev062c-probe/difftree_failopen.sh .
ДО удаления: rc=1 вывод=[… нет ПОТРЕБИТЕЛЬ-пробы]
rev-list окна rc=0
diff-tree коммита писателя rc=128
ПОСЛЕ удаления дерева: rc=1 вывод=[потребители 116: список судимых коммитов окна недоступен: fatal: unable to read tree …]
```

Команда-обёртка пробы завершилась rc 0, потому что её последним действием
является диагностический `echo`; проверяемый ею гейт после отказа `diff-tree`
вернул требуемый **rc 1** с именованной причиной. Это именно противоположно
зафиксированному ревьюером fail-open (`ПОСЛЕ … rc=0`).

## Scoped и живые проверки

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_consumers
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0

$ bash scripts/check_consumers.sh . contracts/056-dver-retake-ahead.md
rc=0
$ bash scripts/check_consumers.sh . contracts/058-sharing-agentdb-dev-zona.md
rc=0
$ bash scripts/check_consumers.sh . contracts/059-sverka-objavlennyh-putej-profylja-s-derevom.md
rc=0

$ git diff --exit-code frozen/contracts/062/1 HEAD -- contracts/062-atribucija-okna-potrebitelej.md fixtures/check_consumers/red_atribucija_okna_062.sh fixtures/check_consumers/krasnye_062.sh fixtures/_krasnye_038.sh
rc=0; вывод пуст

$ bash scripts/check_contract_frozen.sh . contracts/062-atribucija-okna-potrebitelej.md
… contracts/062-atribucija-okna-potrebitelej.md — заморожен v1, блоб совпадает побайтово …
rc=0

$ bash scripts/check_zones.sh .
замороженных контрактов: 64 · объявленных авторов: 1 · коммитов в диапазонах: 2951 · проверено по зонам: 1513
rc=0
```

## Итог

Р-1 закрыт не только наличием текста: npm-ключ запускает 062-батарею, CI
содержит прямой шаг, а обе формы фантомной проводки красит независимый
паритет. Р-2 закрыт на отдельном отказе `diff-tree`: ошибка остаётся
именованным rc 1, а не превращается в пустое множество. Блокирующих
ускользнувших мутантов не найдено.
