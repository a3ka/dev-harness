accept

# Контракт 060 — критик, круг к4 (проверочный)

Предмет: `contracts/060-samodostatochnost-repo-mint-reestr-boli.md` на HEAD
`ab19f0e51b9ba89a8bfdf37dec7621c642ac202c`; додел `19e165f` по РЕШЕНИЮ
`93844c9`, `verdicts/arbitration/060-k3-w10-r3-marshrut.md`, пункты 3–4.
Предмет закоммичен; предмет работы, rc-критерий, исполнители architect/implementer
и ЗОНА-строки присутствуют. Набор артефактов полон.

Работа выполнена в одноразовом SSH-клоне
`/tmp/dev-harness-verify/critic060k4-20260930`. Область суда — закрытие Б1 к3
по пункту 3 арбитража и только действительно новые находки. Семантика
HERE/PROJECT, логическая канонизация `cd … && pwd` и допустимость красной
честной части до реализации не пересуживаются. Контракт, батарея и реализация
судьёй не правились. Единственный постоянный артефакт круга — этот вердикт.

## Закрытие Б1 к3 по пункту 3 решения

**Б1 закрыт.** Все части предписанного додела присутствуют; различимость
подтверждена живым прогоном, а не только чтением текста.

1. **Клетка к7:** `fixtures/workshop_project/red_samodostatochnost_repo_060.sh:290–296`
   сравнивает W9/W10 и R2/R3 целиком через `grep -Fxq` со значениями `$toy7`
   и `$ROOT`. Имена к7/к8 сохранены; к8 по-прежнему наблюдает окружение потомка.
   Префиксная проверка значения TOOLS/R3 устранена.
2. **Контрмодель:** батарея `:460–505` содержит `STUB_TOOLS_PROJECT`: только
   текст W10/R3 переключается на PROJECT, экспорт `HARNESS_TOOLS_ROOT` остаётся
   из HERE. В `:685–704` s13 проверяет отсутствие правильной полной строки R3
   в промпте при rc 0 probe и наличие правильного значения в окружении живого
   потомка; s13_diff без ручки принимает правильные W10 и R3. Живой trace
   показал именно этот переход, s13 засчитан тринадцатым пойманным стабом,
   s13_diff завершился успешно. Порядок s1–s12 сохранён.
3. **Контракт:** `contracts/060-samodostatochnost-repo-mint-reestr-boli.md:129–133`
   задаёт значения W9/W10 и точную проверку R2/R3; `:200–203` описывает усиленную
   к7 и контрмодель s13; `:297–300` требует канонический корень харнесса и
   `grep -Fx` в приёмке. Это исполнение решения арбитра без смены семантики И-1.
4. **Счётчики:** `fixtures/_krasnye_060.sh:5–6` и
   `fixtures/workshop_project/.probe-only:35` теперь несут 13 стабов.
5. **Область додела:** diff от HEAD предыдущего круга `5592406` содержит только
   эти четыре файла и новый арбитражный вердикт. Workshop, scripts/, CI/npm,
   роли и старые frozen case-файлы в диапазоне не изменены. Дополнительная
   клетка баннера не вводилась; требование такой клетки этим судом не добавляется.

## Пять вопросов роли в пределах проверочного круга

1. **Критерий слабее предмета?** Конкретный обход Б1 «экспорт верен, W10/R3
   указывают PROJECT» теперь различается точными предикатами к7 и контрмоделью
   s13. Действительно нового обхода в предмете круга не установлено.
2. **Готовность доказуема командой?** Да: объявленный раннер исполняет rc-батарею,
   а арбитражный критерий до реализации — 13/13, чистые диффпробы и те же девять
   честных красных — наблюдён. Это не утверждение готовности реализации.
3. **Решение оставлено исполнителю?** Нового неназванного выбора в доделе нет:
   значение, форма пути, носители и предикаты зафиксированы пунктами 2–3 решения.
   Ранее закрытые вопросы приоритетов аргумент/env не переоткрываются.
4. **Границы названы?** Architect/implementer и файлы распределены в
   `contracts/060-samodostatochnost-repo-mint-reestr-boli.md:219–263`; механизм —
   check_zones по frozen-блобу и имени автора. Строка `.probe-only` уже относится
   к architect-зоне 058 и явно разрешена решением. Precision-гейт вернул 0.
5. **Противоречие AGENTS.md?** Нового самостоятельного противоречия не установлено.
   Модель угроз валидна; потолки зелёные. Единственный отказ ПРОВОДКИ — г2-α
   «guard не подключён», предусмотренный фазой до реализации
   (`contracts/060-samodostatochnost-repo-mint-reestr-boli.md:323–335`);
   он не является новым блокером и не пересуживается.

**Новые находки:** нет. Новых БЛОКИРУЕТ или СОВЕТ этим кругом не вводится.
Заморозка разрешена; accept не означает готовую реализацию и не требует
зелёной честной части до её раздачи.

## Живые прогоны

ПРИЁМКА-СУДЬИ v2: исполнена только батарея 060, обязательные гейты и diff
неизменности прежних барьеров. Семья probe-only предъявляется своим раннером;
пустой scope verify_antiplacebo не запускался. Полный suite/CI не запускался.
Все команды ниже исполнены в указанном клоне на `ab19f0e` до записи вердикта.

### Механическая приёмка пункта 4 арбитража

`bash fixtures/_krasnye_060.sh /tmp/dev-harness-verify/critic060k4-20260930` → rc 1,
весь вывод:

```text
060: честных клеток 15, зелёных 6, красных:  к1-д-mint-на-репо-стороне к2-д-серия-002 к3-е-реестр-в-toy к4-ж-запись-с-HEAD-toy к5а-N1-next_id к5б-N1-freeze к5в-N1-draft-без-записей к7-лаунчер-probe к8-лаунчер-экспорт-руки-потомку
060: стабов 13, поймано 13, ускользнуло: нет
060: диффпробы стабов без ручек: нет
060: стерегомое дерево харнесса: не тронуто
итог 060: rc=1
```

### Различимость s13 и положительного контроля

`bash -x fixtures/workshop_project/red_samodostatochnost_repo_060.sh /tmp/dev-harness-verify/critic060k4-20260930`
→ rc 1. Ниже отдельные дословные фрагменты одного trace, не полная стенограмма:

```text
+ scell s13-текстовый-маршрут-tools-из-project s13
+ stub_total=13
+ s13
+ local out rc p
++ STUB_TOOLS_PROJECT=1
++ HARNESS_SCRATCH=/tmp/red060.RsP3Eh/scratch_s13
++ bash /tmp/red060.RsP3Eh/stubs/scripts/workshop --probe /tmp/red060.RsP3Eh/toy_stubs
+ out=$'WORKFLOW: /tmp/red060.RsP3Eh/toy_stubs\nTOOLS: /tmp/red060.RsP3Eh/toy_stubs\nworkshop PROBE OK: /tmp/red060.RsP3Eh/toy_stubs\nPROMPT: /tmp/red060.RsP3Eh/scratch_s13/dev-harness-projects/stab060/home/session-prompt-orchestrator.md'
+ rc=0
```

```text
+ grep -Fxq HARNESS_TOOLS_ROOT=/tmp/red060.RsP3Eh/stubs /tmp/red060.RsP3Eh/scratch_s13/dev-harness-projects/stab060/home/session-prompt-orchestrator.md
+ rm -f /tmp/red060.RsP3Eh/s13.env
+ STUB_TOOLS_PROJECT=1
+ WORKSHOP_CHILD=/tmp/red060.RsP3Eh/childbin/dump-env
+ CHILD_ENV=/tmp/red060.RsP3Eh/s13.env
+ HARNESS_SCRATCH=/tmp/red060.RsP3Eh/scratch_s13l
+ bash /tmp/red060.RsP3Eh/stubs/scripts/workshop /tmp/red060.RsP3Eh/toy_stubs
+ '[' -s /tmp/red060.RsP3Eh/s13.env ']'
+ grep -Fxq HARNESS_TOOLS_ROOT=/tmp/red060.RsP3Eh/stubs /tmp/red060.RsP3Eh/s13.env
+ stub_caught=13
```

```text
+ s13_diff
+ local out p
++ HARNESS_SCRATCH=/tmp/red060.RsP3Eh/scratch_s13d
++ bash /tmp/red060.RsP3Eh/stubs/scripts/workshop --probe /tmp/red060.RsP3Eh/toy_stubs
+ out=$'WORKFLOW: /tmp/red060.RsP3Eh/toy_stubs\nTOOLS: /tmp/red060.RsP3Eh/stubs\nworkshop PROBE OK: /tmp/red060.RsP3Eh/toy_stubs\nPROMPT: /tmp/red060.RsP3Eh/scratch_s13d/dev-harness-projects/stab060/home/session-prompt-orchestrator.md'
```

```text
+ grep -Fxq HARNESS_TOOLS_ROOT=/tmp/red060.RsP3Eh/stubs /tmp/red060.RsP3Eh/scratch_s13d/dev-harness-projects/stab060/home/session-prompt-orchestrator.md
+ guard_ok=1
```

Отдельная реконструкция З1 арбитража не выполнялась: различимость наблюдена
в канонической s13/s13_diff согласно обязательному пункту 4.

### Гейты

Для первых трёх команд аргументы:
`/tmp/dev-harness-verify/critic060k4-20260930 contracts/060-samodostatochnost-repo-mint-reestr-boli.md`.

- `bash scripts/check_precision_gate.sh <корень> <контракт>` → rc 0, `OK`.
- `bash scripts/check_threat_model.sh <корень> <контракт>` → rc 0:
  `модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))`.
- `bash scripts/check_provodka.sh <корень> <контракт>` → rc 1, единственный вывод:
  `проводка: guard не подключён: fixtures/_krasnye_060.sh не вызывается в .githooks/ или .github/workflows/`.
- `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/critic060k4-20260930` → rc 0:

```text
  ok   персоны: 9 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 59 черновик(ов) судится, замороженные — по тегам
потолки в порядке
```

### Неизменность прежних барьеров

`git diff --name-status 5592406 HEAD` → rc 0, весь вывод:

```text
M	contracts/060-samodostatochnost-repo-mint-reestr-boli.md
M	fixtures/_krasnye_060.sh
M	fixtures/workshop_project/.probe-only
M	fixtures/workshop_project/red_samodostatochnost_repo_060.sh
A	verdicts/arbitration/060-k3-w10-r3-marshrut.md
```

## Стенограмма спавна (дословно из задания; не новый прогон)

Детектор перед спавном: bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness → rc 0, «основной чекаут чист» (2026-09-30, снимок №5 на ab19f0e).
