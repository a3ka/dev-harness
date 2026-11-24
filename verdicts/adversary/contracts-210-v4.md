FAIL
OBJECT=a8123cf02f398fbc4f5e0eb247c2c8b15d6dc1a5
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=4 (узкий, сверх бюджета по санкции/слову); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=archive/210/adversary-v3-fail-2cc1783466 (FAIL); класс риска=рисковый.

## Блоки

**БЛОКИРУЕТ: потеря frozen-зон и окна до читателей `check_zones`** — `scripts/lib_zones.sh:311–314`, потребитель `scripts/check_zones.sh:417–422,641–644,804–805,1806`, дверь `scripts/check_staged.sh`. ПРОИСХОЖДЕНИЕ: узкое-закрытие; КЛАСС: К-09. Причина — строковый `git ls-tree --name-only` и сравнение префикса с C-цитированным именем; при обнаруженном контракте `continue` до записи не только зоны, но и диапазона. Это не просто перечисленный вне пяти файлов остаток: ниже измерен ложный разрешающий результат настоящей staged-двери на достижимом состоянии. Исправление должно сохранять реальные имена и доставлять все зоны и окна потребителям; редакцию нормы и зоны исправления определяет владелец/оркестратор.

**ОБЯЗАТЕЛЬСТВО:** решение арбитража о сквозном NUL-транспорте сохраняет штатные quote/backslash/Unicode-имена, контроль зон и решения окон; никакое потерянное имя не должно делать объявленного автора невидимым. Арбитраж отдельно измерил штатную достижимость quote/backslash через next_id → mint → настоящий pre-commit. Контракт 210 сохраняет объединение зон из высших frozen-блобов.

**СОСТОЯНИЕ:** независимые одноразовые репозитории с настоящим аннотированным `frozen/contracts/810/1`, в соответствующем блобе ровно `ЗОНА architect: scripts/`. Имя — `contracts/810-ascii.md`, либо `contracts/810-a"quote.md`, `contracts/810-a\slash.md`, `contracts/810-кириллица.md`, NFC `café` или NFD `café`. В каждом мире отдельно staged `scripts/test-file` (разрешён) и `outside.txt` (вне зоны), автор architect. Это не мутация испытуемого.

**НАБЛЮДЕНИЕ:** адресный вызов настоящей `zones_load` на ASCII: rc 0, `zones_scoped=architect<TAB>scripts/<TAB>810`, `ranges=810<TAB>frozen/contracts/810/1`, `contracts_list=810`, `zones_match_path ... scripts/a.sh` rc 0. На каждом из пяти цитируемых имён: `zones_load` rc 0, `contracts_list=810`, но `zones_scoped` и `ranges` пусты; `zones_match_path` rc 1. Настоящий `check_staged.sh`:

```
ascii    scripts/test-file  rc=0  judged: scripts/test-file; ok: staged в зоне автора architect
ascii    outside.txt        rc=1  ОТКАЗ: вне зоны: outside.txt
a"quote  scripts/test-file  rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
a"quote  outside.txt        rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
a\slash  outside.txt        rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
кириллица outside.txt       rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
café NFC outside.txt        rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
café NFD outside.txt       rc=0  не судится: автор «architect» не объявлен ни в одной заморозке
```

Для каждой не-ASCII/цитируемой формы также измерен `scripts/test-file` rc 0 с тем же сообщением «не судится»; stderr пуст, кроме ASCII outside. Драйвер rc 0. `check_staged.sh` запускался отдельно для каждого мира; не подменялись ни Git, ни испытуемый скрипт. В окружении использовались `TMPDIR` и `LIB_ZONES_BASE` внутри `.review/adv210d-scratch`, идентичность architect задавалась переменными Git. Воспроизведение: импортировать `fixtures/workshop_project/charter_tekst_do_tega_210/probe.py`, создать `World(tempdir, Cell('zones','history',slug=slug,value='ЗОНА architect: scripts/\n'.encode()))`, скопировать `scripts/` из OBJECT в `world.root/scripts`, выполнить `git read-tree --reset -u HEAD`, создать и `git add` только указанный target, затем запустить `bash <world>/scripts/check_staged.sh <world>` с `GIT_AUTHOR_NAME=architect`, `GIT_COMMITTER_NAME=architect`, соответствующими email и отдельными TMPDIR/LIB_ZONES_BASE. `World` создаёт независимый origin и настоящий tag. Пробы и миры удалены после замера.

[INFERENCE] Из замеренных пустых `ranges`/`zones_scoped` и кода `check_zones.sh:417–422,641–644,804–805,1806` следует, что свежие NUL-селекторы `:502` и `:566` не восстанавливают входные зоны/окна `zones_load`: если нет другого источника зоны, проверка не может корректно судить это окно; при валидной строке ЗОНА ветка `:575–576,634–636` может вместо корректного решения выдать ложный отказ об отсутствии объявления. Полный CLI `check_zones` здесь не запускался: его re-exec стирает TMPDIR/LIB_ZONES_BASE, а scratch вне выделенного дерева запрещён; ложный rc полного CLI не заявляется. В отличие от этого rc и обход staged выше наблюдались непосредственно.

## Закрытие класса

`W=bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh`. `W --repo .` rc 0, `KLETKI=314 ZELENYE=314 KRASNYE=0`; в нём цитата/backslash/кириллица/NFC/NFD, fast/oracle/incr/pre-push и frozenscope дали именованные зелёные клетки, включая отрицательные subject rc 1. Это наблюдение батареи, а не отдельный повтор всех миров. `wire-zoneshead-*`/`wire-zonestag-*` извлекают отдельный селектор и вручную вызывают `zones_declare_rows` (`transport.py:309–355`), не выполняя `zones_load`; поэтому зелёный результат не обнаружил потерю выше. Модели `--model` rc 0: 314/314/0; `--syntax` rc 0: `210 SYNTAX: bash=4 python=2`.

## Полнота миграции

В пяти целевых файлах найденные вызовы Git с именами: `check_charter.sh:421,423,863,1041` NUL, `:753` только objectname; `.githooks/pre-push:221,223,281,283,374,376` NUL; `next_id.sh:286,310` NUL; `check_contract_frozen.sh:95` NUL; `check_zones.sh:502,566,1064` NUL. Снята команда `git grep -n -E 'ls-tree|name-only|name-status|diff-tree|ls-files|--raw|log .*--name|show .*--name|--stat|--numstat' -- scripts .githooks .github` rc 0. Она выявила критическую транзитивную зависимость `lib_zones.sh:311`; простой перечень только пяти файлов не доказывает целостность решения. Полная классификация всех остальных совпадений не завершена из-за стопа на блоке.

## Остатки

Из незавершённой классификации видны строковые чтения вне пяти файлов: `scripts/check_ids.sh:286` (исторические name-status), `scripts/check_sdacha.sh:105` (поиск frozen-контракта), `scripts/check_staged.sh:676` (существование номера в main), `scripts/land_agent.sh:268`, `scripts/lib_plan.sh:401`, `scripts/gitw_teg_130.sh:78,83`, `scripts/lib_karta_sdachi.sh:205` (пути истории), `scripts/check_protected.sh:353,357,618,642,644` (имена/история защищённых путей). Их фактическое влияние в данном суде отдельно не проверялось; это не утверждение о блоке каждого места. `lib_zones.sh:311` не отнесён к безвредным остаткам — есть измеренный выше обход.

## Мутации

Новые production-мутации не запускались: постановка вызова 3, распространённая на вызов 4, предписывает при находке FAIL и стоп. Существующая батарея зелёная на фактически дефектном загрузчике; это наблюдение существующей реализации, не вымышленный зелёный мутант. `--stabs` не запускался.

## Регресс

Выполнены только `--repo` rc 0 (314/314/0), `--model` rc 0 (314/314/0), `--syntax` rc 0, адресная проба zones_load и staged выше (драйверы rc 0; внутренние rc приведены без сокрытия). Остальные перечисленные в задании регрессии, shellcheck, замеры и семь отдельных мутаций не запускались после блокирующей находки. Полный интеграционный check_zones согласно заданию вне scope. Базовый объект и авторы в истории проверены; OBJECT неизменён. Scratch собственных проб удалён; `du -sh "$PWD"` rc 0, 163M.

## НЕ ЗАЩИЩАЕТ

Прежние остатки контракта не расширялись: подлинность человеческой воли и администрирования origin, не введённые освобождения, прежняя полнота удалённых контрактов, конечность набора мутаций. Контракт не назначает остаточным строкам идентификаторы К-NN с ловцом adversary; нового номера вручную не придумываю.

## Советы

Нет. После FAIL — арбитр или решение владельца об остаточном риске согласно санкции вызова; этот вердикт не является accept и не открывает reviewer.
