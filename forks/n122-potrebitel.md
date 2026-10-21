ФОРК: n122-potrebitel
ВОПРОС: `done_contract` 122 отказывает: «потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы» (check_consumers.sh:257-259: проба — строка `ПОТРЕБИТЕЛЬ <путь-потребителя>: <команда>` в ТЕКСТЕ контракта 122, исполняется в корне, rc 0 обязателен). Реализация 122 тронула `scripts/freeze_contract.sh` в границах контракта; в замороженном тексте 122 (frozen/contracts/122/2) такой строки нет (пара `scripts/consumers.d/freeze_contract.sh__check_check_contract_ready.tsv`). Вариант А (рекомендация): contracts/122-ci-proekta.md v3 с ОДНОЙ добавленной строкой `ПОТРЕБИТЕЛЬ fixtures/check_check_contract_ready/: bash scripts/check_check_contract_ready.sh` (зелёная на дереве: CI l6 `check:contract-ready` «ветви all зелены», 7 ok) — правка текста frozen-контракта = v+1 + вердикт критика accept + РАЗРЕШИЛ-ВЛАДЕЛЕЦ в коммите (готовый дословный текст: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/122-ci-proekta.md 122 v3: добавлена строка ПОТРЕБИТЕЛЬ fixtures/check_check_contract_ready/ (проба потребителя писателя freeze_contract.sh, check_consumers 038/116); остальной текст не меняется»). Вариант Б: принять остаток «done 122 не ставится» (122 живёт залендённым и проведённым без done-тега) — слово владельца.
КЛАСС: инженерный
ПРИЗНАК: приоритет
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T18:58:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: нет
