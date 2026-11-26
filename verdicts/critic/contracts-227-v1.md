accept
OBJECT=9cff9d445efa6d24c1b8445b625e44335cdba6db

СУД: repo=dev-harness; предмет=227; фаза=контракт; роль=critic; вызов=2/2 (исправительный; дельта Architect227b); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit227b; модель-факт=openai-codex/gpt-6.1-terra; SHA=9cff9d445efa6d24c1b8445b625e44335cdba6db; предыдущий=archive/227/critic-v1-fail-8e3abb0c64; исключение=нет; автор=Architect227b, openai-codex/gpt-6.1-sol, отдельная сессия. `models_actual.sh --tsv --bind --session Crit227b` и `--session Architect227b` дали обе модели allowed, rc 0. Запись в HANDOFF и её дописка проверяются оркестратором: доступный HANDOFF на OBJECT не содержит записи этого запуска.

Объём повтора — закрытие К-05/К-08 первого вызова и последствия дельты отказа измерения, включая двусторонность новых проверок. Нового полного поиска по неизменённым поверхностям не проводилось. Исходная операция модели не изменена; изменены наблюдения и их доказательство. Прежний блок закрыт, нового доказанного блока в пределах повтора нет.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 двери=12 карта=17/17 дельта=2
К-02: без изменений с вызова 1 — ссылка:1
К-03: без изменений с вызова 1 — ссылка:1
К-04: без изменений с вызова 1 — ссылка:1
К-05: чисто — replay_critic.py rc 0 и git-failure отдельно краснеет
К-06: чисто — --stabs rc 0 и s29 binary красный результат субъекта не отказ стенда
К-07: чисто — --model rc 0 KLETKI 29 KRASNYH 0
К-08: чисто — replay_critic.py rc 0 и независимая соседняя мутация ловится
К-09: чисто — probe.py:101-103 отдельно Git и два отказа чтения конфига
К-10: чисто — probe.py:159-174 проверяет rc stderr и отсутствие stdout
К-11: без изменений с вызова 1 — ссылка:1
К-12: без изменений с вызова 1 — ссылка:1
К-13: без изменений с вызова 1 — ссылка:1
К-14: чисто — --stabs rc 0 и e03 e04 зелёные на отказах
К-15: чисто — --catalog rc 0 KLETKI 29 STABY 32 EKVIVALENTY 4 SVJAZI 40
К-16: чисто — contracts/227-sh5f-zashivki-otchet.md:4 и 77-87 отчёт обычного риска
К-17: без изменений с вызова 1 — ссылка:1

## Закрытие прежнего блока

`fixtures/workshop_project/zashivki_otchet_227/replay_critic.py` rc 0: в одноразовом Git-клоне в production-шве удалены именно строки 19–21 исторической модели, честная батарея запущена через `--repo`. Сырой результат:

```text
CRITIC_EXACT_DELETE_19_21 --repo rc 1
empty GREEN
git-failure RED MEASUREMENT_ERROR_RC rc=0,MEASUREMENT_ERROR_DIAGNOSIS,MEASUREMENT_ERROR_REPORT b'{"lines": 0, "files": 0, "matches": [], "baseline": {"lines": 89, "files": 20, "commit": "6565542c1"}}\n'
invalid-config GREEN
unreadable-config GREEN
KLETKI 29 KRASNYH 1
```

В `--stabs` точное удаление есть как s26, соседнее s27 отдельно ловится; e03 проверяет эквивалентное условие на ошибке и честном нуле, e04 — эквивалентное чтение при обоих отказах конфига. В `git diff ed4bbfb1f 9cff9d445 -- fixtures/workshop_project/zashivki_otchet_227/probe.py` прежние клетки и полноценное сравнение успешного JSON/труб/снимков сохранены; добавлены три клетки и классификация rc субъекта отделена от отказа стенда.

Независимая соседняя мутация в одноразовом Git-мире: заменить существующее условие `result.returncode not in (0, 1)` на `result.returncode < 0`, затем вызвать `probe.world_test` на git-failure и empty. Честный эквивалент — `result.returncode > 1` на тех же входах. Команда `python3 -B tmp/scratch-crit227b/adjacent.py` rc 0, сырой вывод:

```text
adjacent-negative-only git-failure RED MEASUREMENT_ERROR_RC rc=0,MEASUREMENT_ERROR_DIAGNOSIS,MEASUREMENT_ERROR_REPORT b'{"lines": 0, "files": 0, "matches": [], "baseline": {"lines": 89, "files": 20, "commit": "6565542c1"}}\n'
adjacent-negative-only empty GREEN
equivalent git-failure GREEN
equivalent empty GREEN
```

На настоящей модели отдельные пробы: повреждённый индекс → rc 2, stdout пуст, stderr содержит `NOT_IMPLEMENTED:`; Git отсутствует в PATH → rc 2 и пустой stdout; конфиг `{}` → rc 2 и пустой stdout. При отсутствии репозитория с `GIT_CEILING_DIRECTORIES`, исключающим родительский репозиторий, rc 2 и пустой stdout. Рабочий пустой Git-мир: rc 0, stderr пуст, `{"lines": 0, "files": 0, "matches": [], "baseline": {"lines": 89, "files": 20, "commit": "6565542c1"}}`. Бинарный вход s29 красит клетку при rc 2 субъекта, а не выдаёт VERIFIER_UNAVAILABLE.

## Советы

СОВЕТ contracts/227-sh5f-zashivki-otchet.md:42 — при копировании модели в каталог без собственного `.git`, вложенный в другой Git-репозиторий, Git обнаруживает родительский репозиторий и может вернуть успешный нулевой отчёт. Это не продемонстрированный отказ Git: проверка с действительно отсутствующим доступным репозиторием выше даёт rc 2. Уточнение допустимости такой установки и проверки корня может помочь оператору; сужения или расширения обязательств не предлагается.

## НЕ ЗАЩИЩАЕТ

Остатки из contracts/227-sh5f-zashivki-otchet.md:83-87 сохраняются: семантические зашивки вне конфигурируемой области и сознательная подмена конфига — ловец reviewer; произвольная компрометация среды — isolated/CI и независимый reviewer. Заявленный отказ измерения не вынесен за границу.

## Прогоны

В чистом сетевом клоне OBJECT с единственным origin: `check_sdacha.sh "$PWD" contracts/227-sh5f-zashivki-otchet.md --run` rc 0: `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)`; `pre_critic.sh contracts/227-sh5f-zashivki-otchet.md` rc 0 `КРИТИК: дверь зелёная`; `check_precision_gate.sh "$PWD" contracts/227-sh5f-zashivki-otchet.md` rc 0 `OK`; `context.py` rc 0 вывел пересечения frozen; W=`bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh`: W --repo . rc 1 `SUBJECT_ABSENT: scripts/report_zashivki.sh`; W --model rc 0 `KLETKI 29 KRASNYH 0`; W --stabs rc 0 `STABY 32 EKVIVALENTY 4 ZHIVYH 0`; W --sintaksis rc 0 `SINTAKSIS_OK`; W --catalog rc 0 `KLETKI 29 STABY 32 EKVIVALENTY 4 SVJAZI 40`. Все 29 клеток честной модели зелёные, в том числе empty, binary и три клетки отказов; s26–s32 пойманы, e03/e04 зелёные. Нагрузка при запуске 18.71/23.08/25.68, затем 50.50/33.53/29.11.
