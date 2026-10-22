accept
OBJECT=299105587a04649d799e07bcc64355517f3122e1

Scoped-микро-круг по «Перечню исправлений» и «Приёмке микро-круга» арбитража `verdicts/arbitration/contracts-133-krug3-kap.md`. Блокеров: 0.

- П-Б1: `fixtures/workshop_project/dovodka_ui_133/dovodka_ui_133.py:449` сравнивает строки задания упорядоченно (`got != want`); докстринг движка и `contracts/133-dovodka-ui.md:58` различают упорядоченное задание и SUD-мультимножество.
- П-Б2: `source.json` объявляет c28-cep и s17; `dovodka_ui_133.py:383-425` вызывает субъект `zadanie`, проверяет его выдачу, делает UI-коммит, вызывает субъект `zona` с выданным файлом и проверяет погашение refs. Честная клетка `--cell c28-cep-zadanie-zona --model --seed 1` → rc 0, `СОШЛОСЬ CHISTO`. `--stabs` ловит s17: `ARTEFAKT,RC,VYVOD,POGASHENO`.
- П-А1: `contracts/133-dovodka-ui.md:36,83,99,109` ограничивает обещание вызванными воротами zona, явно признаёт обход невызовом, называет cognitive-only ловца и незапланированную точку принуждения вне 133; 125-б не выдан за готовое закрытие.
- П-Т: продукт без предмета `--seed 1` → rc 1, 31/3/28; `--model` с seed 1, 42, 99999 → каждый rc 0, 31/31; `--stabs` с теми же seed → каждый rc 0, 17/17. Независимый подсчёт source.json: 31 клетка, 31 уникальный id, 17 стабов.
- Контроль `--candidate /tmp/dev-harness-verify/Arbiter133k3-cand --seed 314` → rc 1, 31/28/3: c01 и c06 расходятся по ARTEFAKT, c28-cep — по ARTEFAKT,RC,VYVOD,POGASHENO; остальные клетки сходятся. На честной модели все прежние клетки сохранили ожидаемые исходы.
- `bash scripts/pre_critic.sh contracts/133-dovodka-ui.md` → rc 0; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic133m contracts/133-dovodka-ui.md` → rc 0 `OK` (изолированный прогон); `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic133m contracts/133-dovodka-ui.md` → rc 0 (11/7 буллетов).

Новых классов входов и снятого арбитром риска невызова ворот не пересуждаю; пятого круга нет.
