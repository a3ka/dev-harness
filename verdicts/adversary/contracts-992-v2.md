FAIL
OBJECT=1e15de5d067d92a1d6b933d0df1f5d9d8e91068b

СУД: репо=dev-harness; предмет=992; роль=adversary; вызов=5 (аттестат по слову владельца для done); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-992-v1.md (accept, см. историю); класс риска=рисковый

## Тождество

На `origin/main` первая строка `verdicts/adversary/contracts-992-v1.md` — `accept`; строка `OBJECT=\u00606dd2ce3171ee3434649db0c7c1c3c4dad8127e6c\u0060` называет объект; последняя фраза «This verdict accepts the implementation» подтверждает принятие. История файла: `b3be0ba17 adversary adversary: correct contract 992 verdict base`, `6dd2ce317 adversary adversary: record contract 992 regression result`, `20ecf6a55 adversary adversary: verdict contract 992 matrix failure`. Вопреки предположению о тождестве, `git diff --stat 6dd2ce3171ee3434649db0c7c1c3c4dad8127e6c 1e15de5d067d92a1d6b933d0df1f5d9d8e91068b` содержит 4038 файлов, не только вердикты. В зоне предмета изменены `scripts/check_charter.sh`, `scripts/check_ci_gate.sh`, `scripts/done_contract.sh`, `scripts/freeze_contract.sh`, `scripts/gitw_preflight_071.sh`, `scripts/profile_resolver.sh`, `fixtures/freeze_contract/fail_closed_992.py`, `fixtures/freeze_contract/red_doc_lifecycle.sh`; добавлены `fixtures/freeze_contract/b13_token.py`, `b13_token_list.md`, `red_b13_token.sh`, `red_preflight_podkatalog_992.sh`. В частности, `fail_closed_992.py:75` добавляет клетку и меняет саму батарею; её последствия измерены ниже. Сам по себе большой diff не объявляется нарушением.

## Регресс

- `python3 fixtures/freeze_contract/fail_closed_992.py --matrix` на OBJECT: сырой rc=1, итог `cases=25 observations=75 failures=18`, вместо требуемых заданием rc=0 и `cases=24 observations=72 failures=0`. Пример: `C-charter-fast-log parent-A: control_rc=0 fault_rc=0 oracle=0 hit=0 accepted=0`; `C-charter-fast-log current: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=0`; модель `control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1`.
- Важно: контракт задаёт историческую матрицу на базе после A и до B, а задание требует её на OBJECT после B. Поэтому отказы строк B-current, где исправленный субъект правильно возвращает rc1, не доказывают дефект реализации: матрица ожидает там исторический fail-open. Это же разъяснено в принятом предыдущем вердикте. Однако добавленная 25-я клетка и её `parent-A hit=0` — отдельное наблюдаемое изменение батареи, не объясняемое исправлением B.
- `bash -n scripts/check_charter.sh scripts/gitw_preflight_071.sh scripts/judge_gate.sh scripts/check_ci_gate.sh scripts/profile_resolver.sh scripts/freeze_contract.sh scripts/done_contract.sh`: сырой rc=0.
- Прочие прогоны и мутации не выполнялись: по заданию при находке FAIL и стоп. Позитивный контроль целой батареи на этом OBJECT не выполнен; зелёный `model` в отдельной клетке выше его не заменяет.

## Мутации

Не выполнялись после обнаружения блока; выводов о стойкости к мутациям нет.

## Блоки

БЛОКИРУЕТ `fixtures/freeze_contract/fail_closed_992.py:75,174,296-318` — изменение батареи нарушает зафиксированную конструкцию и заданный численный результат: контракт требует 24 именованные клетки и 72 наблюдения матрицы, а новая `C-charter-fast-log` даёт 25 и 75. В историческом `parent-A` внедряемая ошибка не доставлена (`hit=0`), но матрица учитывает клетку как неуспешную (`accepted=0`); таким образом исторический контроль этой новой клетки не различает ошибку. Команда и сырой rc приведены выше. Класс причины: изменение критерия/набора клеток и неприменимая историческая инъекция. Закрывающее свойство: неизменный замороженный набор 992 и воспроизводимая матрица на указанной контрактом базе; изменение другой проверки не должно молча переписывать оракул 992.

## НЕ ЗАЩИЩАЕТ

Узкий аттестат не является полным повторным судом, не проверяет live-приёмку, CI-реестры с main, гонки, изменение оракула одним uid или независимые prerequisite-гейты. Не утверждается, что 17 остальных отказов матрицы доказывают дефект production-кода.

## Советы

Развести команду матрицы на исторической базе и приёмку текущего субъекта: предыдущий вердикт уже фиксирует разницу их оракулов.
