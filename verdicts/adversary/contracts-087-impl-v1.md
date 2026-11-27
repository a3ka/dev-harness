FAIL
OBJECT=e5a6dbca6cdcb428065361818d3eb7515530d1bb
СУД: репо=dev-harness; предмет=087; фаза=реализация; роль=adversary; вызов=1; сессия=Adv087a; модель-факт=openai-codex/gpt-6.1-terra; автор Architect087a — architect; предыдущий=нет

## БЛОКИРУЕТ: неверная модель реального lane
ПРОИСХОЖДЕНИЕ: дельта OBJECT; КЛАСС: К-08, К-10. ОБЯЗАТЕЛЬСТВО: К10-исп моделирует исполнение тяжёлой lane после strip и выполняет каждый из трёх реестровых ключей в таком же окружении, как lane (постановка 087). СОСТОЯНИЕ: PR с `GITHUB_EVENT_NAME=pull_request`; третий реальный ключ `check:runner-hygiene` — строка step реестра, а не семейный self-test. НАБЛЮДЕНИЕ: `fixtures/ci_b_087/red_ci_b_087.sh:564` снимает переменную у всех трёх команд; `scripts/run_ci_lane.sh:87-93` снимает её только для `*-family-selftest|check:document|drill:contract-change`, а `check:runner-hygiene` исполняет с неизменённой переменной. Таким образом объявленное зеркальное моделирование нарушено в самом кандидате, независимо от того, читает ли текущая версия третьей команды эту переменную.

ОБХОД (демонстрация следствия, не самостоятельное основание блока): в одноразовом клоне OBJECT в существующий `scripts/check_runner_hygiene.sh` добавлена строка сразу после shebang: `if [ "${GITHUB_EVENT_NAME:-}" = pull_request ]; then cat ROADMAP.md >/dev/null || exit 1; fi`. Коммит клона d7b5777d2ee09280072f6d447c5b04e1a24cbc4d. Это синтетически добавленная ветвь, а не утверждение, что существующий production уже имеет такой отказ; по §Порог сама по себе новая ветвь не основание блока. Источник входа — реальный PR workflow и зарегистрированный третий ключ; источник ошибочного механизма — изменение существующей предметной операции К10-исп с `bash -c` на безусловный `env -u`, расходящееся с существующим case в lane. Закрывающее свойство: для каждого реального ключа моделировать выбор lane и передаваемое ему событие, сохранив снятие у двух family-ключей.

Сырой вывод (полная батарея OBJECT, PR-env, субъект — мутант):
```
  ok   К10-исп три ключа без учётных путей
  ok   стаб chitaet-uchet: пойман на K10I ...; диффпроба K10 зелена
ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)
rc=0
```
На отдельном чистом клоне того же мутанта выполнены настоящий `h=$(bash scripts/ci_klass.sh hash HEAD)` и `bash scripts/ci_klass.sh strip "$h"`, затем реальный lane:
```
strip: удалено учётных путей 2626, кодовое дерево H=94cdb2636f648e757121dffafbe25b377275ec4195e4ec1a23ce27abd5c03e0c
+ npm run check:runner-hygiene
> bash scripts/check_runner_hygiene.sh
cat: ROADMAP.md: No such file or directory
замер: check:runner-hygiene 0
lane: отказ ключа check:runner-hygiene (rc=1)
PR lane rc=1
```
Команда батареи: `TMPDIR="$PWD/tmp/scratch-adv087" GITHUB_EVENT_NAME=pull_request GITHUB_ACTIONS=true CI=true bash fixtures/_krasnye_087.sh "$PWD/tmp/adv087-subject"`; lane — `GITHUB_EVENT_NAME=pull_request GITHUB_ACTIONS=true CI=true bash scripts/run_ci_lane.sh check:runner-hygiene` из strip-клона. Честная кандидатная батарея на неизменённом дереве 218 `eae9136de96f01cd833b4df39107275298335d55` при том же PR-env: rc 0, 110/0, стабы 31/31. На 218 настоящим strip удалено 2626 учётных путей; старая батарея `origin/main` на этом дереве: rc 1, 109/1, 31/31, `КРАСНО: К10-исп ... check:pokrytie-079-family-selftest`. Это подтверждает исходный дефект, но не закрывает новый дефект третьего ключа.

На 218 `git grep -n 'GITHUB_' eae9136de -- scripts/check_charter.sh scripts/check_contract_frozen.sh scripts/lib_pr_window.sh` вернул только `check_charter.sh:1055` и `check_contract_frozen.sh:64`, обе строки читают `GITHUB_EVENT_NAME`; иных GITHUB-переменных в трёх файлах нет. `git diff origin/main HEAD` содержит лишь замену строки выполнения и комментарий: `k10_tree`, `k10_cmd`, `K10_KEYS` не изменены. HOME/TMPDIR/stdin отдельно не атаковались; утверждать ложный зелёный по ним оснований нет.

## Карта классов
К-01: граница предмета — один файл, одна изменённая клетка.
К-02: рабочий вход — наблюдаемое PR-событие.
К-03: клетка не повторяет ветвление настоящего lane: блок выше.
К-04: workflow и реестр не изменены.
К-05: frozen 087 не менялся.
К-06: отказ и отсутствие инструмента проверены отдельно.
К-07: положительный контроль 218 зелён.
К-08: блок: дельта безусловно снимает событие у третьего ключа.
К-09: события PR в клетке и lane расходятся.
К-10: ложный зелёный на strip-клоне продемонстрирован.
К-11: учётные пути удаляет независимый U87 оракул.
К-12: соседние функции и список ключей неизменны.
К-13: секреты не предмет.
К-14: честная батарея и stab-пак 31/31.
К-15: старый отказ на 218 воспроизведён.
К-16: рисковый класс по заданию, вызов 1.
К-17: архитектурный SQL и app/api отсутствуют в предмете.

## НЕ ЗАЩИЩАЕТ
В контракте 087 нет строк `НЕ ЗАЩИЩАЕТ` с ловцом adversary: упомянуты следующий кодовый PR/CI-В и reviewer; другие исключения не назначают adversary. Пределы на git-объекты и доверенного автора не подменяются блоком выше.

## Дополнительные адресные пробы
Извлечены без изменения из OBJECT функции `K10_KEYS`, `k10_cmd`, `k10_tree`, `K10I`; одноразовые деревья с тремя строками реестра. `python3 tmp/adv087-probe.py` (rc процесса 0; далее собственные rc клеток):
```
positive: rc=0
exit-127: rc=1 ... check:ops-server-family-selftest
exit-1: rc=1 ... check:ops-server-family-selftest
empty-commands: rc=1 ... все три :net-stroki
wrong-key: rc=1 ... check:runner-hygiene
no-env-positive: rc=0
neutralize-third: rc=0
constant-command: rc=0
missing-env: rc=1 ... все три ключа
pr-all-unset: rc=0
pr-none-unset: rc=1 ... все три ключа
pr-first-raw: rc=1 ... check:pokrytie-079-family-selftest
```
`neutralize-third` и `constant-command` — мутации исполняемой клетки, а не самой батареи; демонстрируют потерю отказа и не являются отдельным свидетельством прохождения полного стаб-пака. `pr-first-raw` сохраняет PR только для первого ключа; при условии `test -z` падает ровно он. Стаб-пак выше независимо ловит существующий `chitaet-uchet`.

После настоящего strip дерева 218: новая батарея с тем же PR-env rc 0, `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)`; старая rc 1, 109/1.

`gh pr view 1452 --json headRefOid,state`: `headRefOid=e5a6dbca6cdcb428065361818d3eb7515530d1bb`, `state=OPEN`. `gh pr checks 1452`: все обязательные шаги pass, vorota skipping (run 45955440550).

Контроль исходного main `006b258dfb68413a88157f4cd4fcc8be9d7fd552`, PR-env: и батарея origin/main, и батарея OBJECT rc 0; обе `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)`.

Полная батарея с единственной мутацией клетки `env -u GITHUB_EVENT_NAME bash -c "$cmd" || true` в отдельном клоне оракула, субъект main, PR-env: rc 1. Сырой вывод:
```
КРАСНО: стаб chitaet-uchet: наблюдение K10I зелена, диффпроба K10 зелена ()
ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 30/31 (subject)
```
Нейтрализация обнаружена ровно стабом чтения учётного пути.

Без PR-env: `env -u GITHUB_EVENT_NAME -u GITHUB_ACTIONS -u CI TMPDIR=... bash fixtures/_krasnye_087.sh <main>` rc 0; `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)`.
