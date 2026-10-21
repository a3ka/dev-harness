FAIL
OBJECT=b408b427267c68b5d4cb60ed7acd94327146eec4

Найден обход И-2/vne-zony. В копии delivery заменён отслеживаемый `server/src/logger.js` (91 строка реализации удалена, оставлен `throw new Error(...)`), после чего выполнено `git update-index --assume-unchanged server/src/logger.js`. Живой guard остался зелёным:
`bash .../red_mobility_spec_120.sh /tmp/dev-harness-verify/Adv120/assume-unchanged` → rc=0, `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real`.

Нейтрализация доказана отдельно: после `git update-index --no-assume-unchanged server/src/logger.js` тот же guard → rc=1, `ОТКАЗ: mobility120: vne-zony (server/src/logger.js)`; повторное `--assume-unchanged` снова даёт rc=0. Оракул вызывает `git diff --name-only <base>`; этот вызов доверяет флагу индекса и не видит изменённый рабочий файл. Следовательно, запрещённая правка сервера может пройти вместе со спекой, то есть предмет 120 не изолирован зоной.

Дополнительный зелёный контрпример содержанию: удалены все `new_operations` (включая пять операций Wunschkennzeichen и две insurance) и lifecycle переназначен на существующие общие `list/create/get/answer/linkMobility...` operationId с теми же kind. Guard → rc=0, `MOBILITY120_OK ... new_operations=0 ...`. Канон §2.1 требует для Wunschkennzeichen типизированные check/reserve/read/expire/cancel либо проверяемый внешний handoff; карта проверяет только принадлежность operationId пину или массиву new_operations, а не то, что требуемая операция действительно описана как новая/специализированная.

Также графовый контрпример: удалены `communications_admission` и его ребро из `PM_ENGAGEMENT`; guard → rc=0, `nodes=19`. Проверяется лишь `EXTERNAL ⊆ pin`, а не покрытие заявленных внешних зависимостей.

Позитивный контроль: исходная delivery → rc=0 `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real`; полный `--model` → rc=0, 46/46 зелёных. Обязательные устойчивости проверены: несуществующий oracle возвращён как красный rc=1 (внутренний rc=127), PATH без python3 → rc=2, пустой предмет (`--cell m-baza`) корректно красный внутри клетки. Стабы: всегда-зелёный → rc=1, 1/46; всегда-красный → rc=1, 2/46.
