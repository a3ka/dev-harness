ФОРК: 187-done-potrebiteli-116
ВОПРОС: `done_contract.sh contracts/187-arhitektura-v-processe.md "<причина>"` отказывает: как закрыть done 187 (дверь потребителей 116)?
КЛАСС: инженерный
ПРИЗНАК: отказ штатной двери done (rc 1) после всех гейтов приёмки 187 (reviewer accept v4, код и вердикты в main)
МАРШРУТ: консультант (утро)
ЗАВЕДЁН: 2026-11-15T23:30:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: нет (done — формальное закрытие; ленд кода и вердиктов выполнен)
ОТВЕЧЕНО: нет

СЫРОЙ ВЫВОД (rc 1, main=48aa70efaa): `bash scripts/done_contract.sh contracts/187-arhitektura-v-processe.md "done 187: реализация дверей архитектуры в процессе — ремонт двери 187а Д1–Д4 (reviewer accept contracts-187-impl-v4, OBJECT 5be0647b5d, вызов 2/2 scoped); код в main 8925948ae6, вердикты v3/v4 в main 949ecb6818"` → «done: потребители 116 красны: потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/ не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы». Первая попытка без причины: «done: причина пуста» (дверь требует второй аргумент).
Факты: ЗОНА implementer frozen 187/1 :63 включает scripts/freeze_contract.sh (и make_task.sh, pre_critic.sh, done_contract.sh, check_architecture_contract.sh); писатель freeze_contract.sh менялся прежними коммитами implementer 187 (cd07d3a9d0 «187a v3…», f50aa6b58b «187 fix2…») — они вошли в main merge'ем носителя двери 187а (PR #970, main 8925948ae6). Дверь 116 требует для каждого изменённого «писателя» ПОТРЕБИТЕЛЬ-пробу в потребителе fixtures/check_check_contract_ready/ — её нет. Тег done/contracts/187/1 не создан. Предмет 187 в реестре: контракт заморожен frozen/contracts/187/1, реализация принята (reviewer v1/v2/v4 accept), основной остаток — формальный done.
Варианты: (а) добавить ПОТРЕБИТЕЛЬ-пробу в fixtures/check_check_contract_ready/ (зона architect, отдельная пачка + ревью) и повторить done; (б) закрыть 187 «без done» по решению владельца (как 084), с записью в HANDOFF; (в) строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в причине done — дверь 116 такого исключения может не знать [INFERENCE, не проверено]. Рекомендация: (а), если пачка небольшая; иначе (б). Решение — утром.
