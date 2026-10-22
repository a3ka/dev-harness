# Каноническое распределение моделей (слово владельца 2026-10-22)
Запись слова владельца консультантом. Владелец: «запомнил наше каноническое распределение и вернул в субботу утром всё как было».
## Канон — `config/agent_models.json` на коммите-родителе временной правки (см. git log этого файла)
| тир | роли | модель | запасная | автопереход |
|---|---|---|---|---|
| default | orchestrator | @sonnet | @glm | да |
| vision | implementer-vision | @sonnet | @gpt-sol | да |
| task | implementer | @minimax | @sonnet | да |
| task-glm | implementer-glm | @glm | @sonnet | да |
| slow | architect | @glm | @gpt-sol | да |
| advisor | adversary | @gpt-terra | @opus | да |
| apex | critic (круг 3) | @gpt-astra | @gpt-terra | да |
| apex-sol | critic-sol (круги 1–2) | @gpt-sol | @gpt-terra | да |
| audit | reviewer | @opus | @gpt-sol | нет |
| plan | arbiter | @fable | @gpt-astra | да |
| consultant | consultant | @gpt-astra | @fable | нет |
| steward | steward | @haiku | @gpt-luna | нет |
Подписки: Anthropic Max 20× — оркестраторы, доводка экранов, ревьюер, арбитр; GLM Max ключ A — станция (architect,
implementer-glm), ключ B — сессия Complior-back; Codex Pro — критик/адверсарий; MiniMax — implementer.
GLM: пн–пт 06:00–10:00 UTC — тяжёлых architect'ов не запускать.
## Временное отклонение (до субботнего сброса Anthropic)
С 2026-10-22 ~13:50 UTC: запасные task → @glm, advisor → @gpt-sol; audit автопереход → да. task-glm остаётся @sonnet: его фолбек пинует замороженная батарея 998 (role_pair_glm).
Причина: Anthropic израсходован на 89% за 2 дня до сброса. **Возврат — субботним утром, после сброса Anthropic:**
откатный owner-коммит восстанавливает таблицу выше (`git show <родитель>:config/agent_models.json` → `npm run gen:harness`).
