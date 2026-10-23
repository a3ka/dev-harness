accept

Контракт 133 v2, короткий круг по форме ПРОВОДКИ; объект owner/train-s35 @ f74a277471dddedf44daf76e07718b3181c230cf.

Сверка с frozen/contracts/133/1: diff contracts/133-dovodka-ui.md переносит прежнюю НОРМА-СТРОКУ ШАГА в `- role=roles/orchestrator.md «…»` (contracts/133-dovodka-ui.md:81-85) и переставляет ПРЕДПОСЫЛКИ; предмет, инварианты, приёмка и ЗОНА-строки не изменены. Строка есть в roles/orchestrator.md (§Доводка UI); `bash scripts/check_provodka.sh . contracts/133-dovodka-ui.md` → rc 0 (грамматика 038 и дословная role-цель). Батарея fixtures/workshop_project/dovodka_ui_133/ не ссылается на перенесённую строку. Н-39 соблюдена: проза не привязывает стабы к ветвям; батарея проверяет их по коду.

Замер на этом HEAD: `bash scripts/pre_critic.sh contracts/133-dovodka-ui.md` → rc 0; `bash scripts/check_precision_gate.sh . contracts/133-dovodka-ui.md` → rc 0; `bash fixtures/workshop_project/dovodka_ui_133/red_dovodka_ui_133.sh --model --seed 42` → rc 0, 34/34 клетки; `… --candidate . --seed 7` → rc 0, 34/34 клетки (живой scripts/dovodka_ui.sh); `… --stabs --seed 42` → rc 0, 20/20 стабов поймано.

СОВЕТ contracts/133-dovodka-ui.md:62-65 — цитированные числа 31/17 из замороженного v1 устарели против нынешней батареи 34/20; это прежний текст, не изменение формы v2 и не повод переписывать критерий в этом круге.
