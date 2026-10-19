accept
OBJECT=9aa86e735c0db07a342053ff2ddab6d90bbd81ef

Вердикт: полного обхода приёмочного контура не найдено. Позитивный контроль на OBJECT зелёный: `bash fixtures/pravila_modelei_998/probe.sh --cases` — rc=0, 46/46; `--matrix` — rc=0, 57/57; `npm run gen:harness -- --check` — rc=0 (10 ролей); `npm run --silent check:antiplacebo -- --scope check_provodka && bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` — rc=0. `git diff --exit-code frozen/contracts/998/1..HEAD -- contracts/998-pravila-modelei.md fixtures/pravila_modelei_998` — rc=0.

Проверенные обманные состояния (все в одноразовых клонах под /tmp/dev-harness-verify/Adv998r1):
- Неверный тир: `roles["implementer-glm"]="task"`, затем `npm run gen:harness` и `--check` дают rc=0 (производные согласованы, предмет неверен), но `bash fixtures/pravila_modelei_998/probe.sh --cases` — rc=1: `role_pair_glm` называет `roles.implementer-glm = 'task', ожидается «task-glm»`.
- Висячая routing-ссылка: `routing.rules[0].role="ghost-998"`. `npm run gen:harness -- --check` — rc=1 и `node scripts/gen-harness.ts --prompt orchestrator` — rc=1; оба вывода называют `routing.rules[0]`, `ghost-998` и отсутствующий файл.
- Fail-open у реализации: в `scripts/gen-harness.ts` заменён `if (!routingGate.ok)` на `if (false)`, а routing направлен на `ghost-998`. `npm run gen:harness -- --check` — rc=0 и `--prompt orchestrator` — rc=0, печатает `class=ведущая сессия → ghost-998`; проба — rc=1, 25 расхождений, включая `routing_refs` и все клетки `gen_reject_*` grammar/refs. Значит проба отличает реальный fail-open от честного случая.
- until-оговорка: добавлена литеральная `роли нет до контракта pravila-modelei`; `npm run gen:harness -- --check` — rc=0, проба — rc=1 (`stale_until_removed`).
- Дубликат: в AGENTS.md добавлен старый абзац с «Какую модель ведёт сессия», «перевёрнуто», «на MiniMax»; `--check` — rc=0, проба — rc=1 (`charter_duplicates`).
- Ручная производная: заменена только `modelRoles.task-glm` в `.omp/config.yml`; `npm run gen:harness -- --check` — rc=1: `FAIL modelRoles ... расходится с config/agent_models.json`.

Отдельная узкая проверка нормы: перефразирована обязательная строка roles/orchestrator.md с сохранением токенов пробы, затем производная перегенерирована. В таком дереве `npm run gen:harness -- --check` — rc=0 и `probe.sh --cases` — rc=0, поскольку клетка пробы проверяет набор токенов, а не дословный текст. Это НЕ обход полного критерия: `bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` — rc=1, `проводка: норма-строка не найдена в role-файле: roles/orchestrator.md`. Совет: при следующем изменении 998 можно продублировать дословную проверку в probe.py для локализации отказа; ослаблять check_provodka или frozen-строку нельзя.

Сырые команды:
- `bash fixtures/pravila_modelei_998/probe.sh --cases` → rc=0, `census cases: исполнено 46, расхождений 0`.
- `bash fixtures/pravila_modelei_998/probe.sh --matrix` → rc=0, `census matrix: исполнено 57, расхождений 0`.
- `npm run gen:harness -- --check` → rc=0, `харнес соответствует roles/ (10 ролей)`.
- `npm run --silent check:antiplacebo -- --scope check_provodka && bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` → rc=0.
- `git diff --exit-code frozen/contracts/998/1..HEAD -- contracts/998-pravila-modelei.md fixtures/pravila_modelei_998` → rc=0.
