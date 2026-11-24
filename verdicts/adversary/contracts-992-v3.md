accept
OBJECT=b506b2b95afc21484af3ed8731d16e1ad7a43fe8

СУД: репо=dev-harness; предмет=992; роль=adversary; вызов=1 на новом OBJECT (перегон аттестата В2 по слову владельца); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; сессия=Adv992d; предыдущий=archive/992/adversary-v2-fail-f5e90da6b6 (FAIL на 1e15de5d); класс риска=рисковый.

Это accept только узкого суда инварианта и дельты по заданному порогу, не подтверждение зелёности всех дверей: **pre_critic реально вернул rc 1 вместо заданного rc 0** (см. ниже). Нормативный гейт этим вердиктом не закрывается.

## Тождество

В `verdicts/adversary/contracts-992-v1.md` строка 1 — `accept`, строка 5 называет OBJECT `6dd2ce3171ee3434649db0c7c1c3c4dad8127e6c`, последняя фраза подтверждает принятие реализации; `b3be0ba17` исправил базу, а коммит `6dd2ce317` записал ранее результат регресса. Это не побайтово то же дерево, что `1e15de5d067d92a1d6b933d0df1f5d9d8e91068b`: diff содержит множество кодовых изменений, в том числе семь скриптов и фикстуры; прежний accept не переносится как тождество. Текущий узкий регресс измерен отдельно.

`git diff 1e15de5d..b506b2b95afc21484af3ed8731d16e1ad7a43fe8 -- fixtures/freeze_contract/` прочитан построчно: единственный изменённый файл — `fail_closed_992.py`, добавлены описание/словарь N/A и учёт наблюдений; прежние предикаты оставшихся клеток не изменены. Общая дельта относительно 1e15de5d содержит также 412 других файлов; она не равна одному коммиту, поскольку новый OBJECT основан на более позднем main. Сам `git show --stat b506b2b95` — одна правка фикстуры, +30/−1. На `git show 3e071370^:scripts/check_charter.sh` история обходится через `rev-list` и `diff-tree`, быстрого `git log --name-only` нет; fast mode введён `80f610153`. N/A для parent-A подтверждён и исполнением ниже; сам по себе `hit=0` не доказывает отсутствие ветви без прочитанного кода.

## Регресс

Временные репозитории имели собственные `.git`; TMPDIR=/tmp/dev-harness-verify/scratch-adv992c. Сырые результаты:

- На исторической базе после A до B `64d2f778261ece66d7e313a13ea4b1a9ccda45b0`, в одноразовом клоне с её исторической фикстурой: `python3 fixtures/freeze_contract/fail_closed_992.py --matrix` — rc 0, `cases=24 observations=72 failures=0`; без флагов — rc 1, `cases=24 observations=24 failures=16` (8 A зелёных, 16 B красных). Это именно старая 24-клеточная база, не выдаётся за прогон новой 25-клеточной фикстуры на ней.
- На OBJECT `python3 fixtures/freeze_contract/fail_closed_992.py --model` — rc 0, `cases=25 observations=25 failures=0 not_applicable=0`; без флагов — rc 0, тот же итог. Положительный контроль целой батареи выполнен.
- На OBJECT `python3 fixtures/freeze_contract/fail_closed_992.py --matrix --case C-charter-fast-log` — rc 1, `cases=1 observations=2 failures=1 not_applicable=1`. Parent-A: N/A, `hit=0 control_rc=0 fault_rc=0`; current: `control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=0`; model: `control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1`. Current краснеет потому, что матрица исторического B ждёт fail-open от исправленного кода; это не регресс по решению владельца В1. Полная новая матрица на исторической базе не прогонялась.
- На OBJECT `python3 fixtures/freeze_contract/fail_closed_992.py --list | wc -l` — `25`, rc обоих процессов `0 0`; это совпадает с CASES.
- `bash fixtures/freeze_contract/red_doc_lifecycle.sh` — rc 0; батарея 992 зелёная, завершающая батарея `cases=54 observations=54 failures=0`.
- `bash -n` семи скриптов implementer и трёх изменённых `.sh` семьи fixtures — rc 0.
- `bash scripts/pre_critic.sh contracts/992-oshibka-eto-otkaz.md` — **rc 1**, сырой вывод: `ОТКАЗ: гейт предпосылок 122 красен (rc=1): predposylki ОТКАЗ: predposylki-otsutstvuyut`. Причина по `scripts/pre_critic.sh:248-268` и `scripts/check_predposylki.sh:55-57`: проверка 122 требует поле для текста с CI-путём, а в замороженном 992 оно отсутствует. Ожидаемого rc 0 нет; не объявляю этот отказ успехом и не делаю вывод, что нормативный гейт пройден. По специальному заданию блок данного узкого суда — доказанное нарушение «ошибка = отказ» на достижимом состоянии; этот отказ другого гейта такого нарушения не предъявляет.
- `bash scripts/check_sdacha.sh "$PWD" contracts/992-oshibka-eto-otkaz.md --run` — rc 0, `СДАЧА: лист не требуется: текст заморожен (frozen/contracts/992/2)`.
- `bash scripts/gen_ci_steps.sh --check` — rc 0.

## Мутации

По одной в отдельном одноразовом клоне OBJECT, с восстановлением файла между запусками; использовалась полная `python3 fixtures/freeze_contract/fail_closed_992.py`.

1. `scripts/freeze_contract.sh:338`: заменить `[ "$fer_rc" -eq 0 ] || die` на `[ "$fer_rc" -eq 0 ] || : # mutant:`. rc батареи 1, `cases=25 observations=25 failures=1 not_applicable=0`; единственная красная строка `B-freeze-versions subject: control_rc=0 fault_rc=0 oracle=0 hit=1 accepted=0`, выпущен ошибочный v1. Другие клетки зелёные.
2. `scripts/done_contract.sh:805`: аналогично нейтрализовать `[ "$dfer_rc" -eq 0 ] || die`. rc батареи 1, `cases=25 observations=25 failures=1 not_applicable=0`; единственная красная строка `B-done-versions subject: control_rc=0 fault_rc=0 oracle=0 hit=1 accepted=0`. Другие клетки зелёные.

Это именно нейтрализации существующих ветвей, не доказательство стойкости ко всем перечисленным классам обманных стабов. Н-39: связь инъекций с ветвями определяется кодом фикстуры/architect, а не прозой контракта.

## Блоки

Доказанного нарушения инварианта «ошибка = отказ» в изменённой области не предъявлено. Красный pre_critic — отдельное зафиксированное препятствие ожидаемому rc и нормативному гейту, не замаскированное accept данного узкого суда.

## НЕ ЗАЩИЩАЕТ

Не проводились новый полный суд неизменённых поверхностей, live-приёмка, конфликты CI-реестров, полный verify_antiplacebo, атаки на оракул одним uid, гонки и независимые prerequisite-гейты. Контракт 992 не содержит строк `НЕ ЗАЩИЩАЕТ` с именованными К-NN и ловцом adversary; отдельного результата ОСТАТОК по несуществующим строкам не заявляю.

## Советы

Перед дальнейшим прохождением нормативных дверей разберите отдельный фактический rc 1 pre_critic в контексте замороженного текста и гейта 122; не подменяйте его зелёным результатом sdacha.
