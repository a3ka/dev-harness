ФОРК: n996-role-stroki-razreshil
ВОПРОС: Контракт 996 (режим проекта) ЗАМОРОЖЕН: `frozen/contracts/996/1` (критик микро-круг accept, `verdicts/critic/contracts-996-v1.md`, реестр `8aed75f0e`, на origin). Его §ПРОВОДКА требует role-строк в семи `roles/*.md` (orchestrator, architect, critic, implementer, adversary, reviewer, arbiter — дословные «норма-строки» в самом контракте, строки 145–153) — это поведенческая норма харнесса, правка `roles/*.md` — устав (правило 11): нужен коммит со строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: roles/*.md <причина>`; оркестратору/агенту писать её запрещено. Без неё `done_contract.sh 996` откажет (проводка role-канала), реализация (implementer: project_workflow/profile_resolver/gitw/reserve_project_contract/mint_line/zones/freeze/done/make_task/workshop…) не зависит от санкции и стартует после ленда 087 (общие ci.yml/ci-steps.tsv). Рекомендация: ДА — владелец/консультант подписывает одним коммитом семь строк дословно из контракта (текст готов: `sed -n 145,153p contracts/996-rezhim-proekta-polnyj-cikl.md`); строка причины: `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: roles/orchestrator.md roles/architect.md roles/critic.md roles/implementer.md roles/adversary.md roles/reviewer.md roles/arbiter.md нормы режима проекта (контракт 996, sourceCanon и project_workflow-контекст)`. Не блокирует реализацию, блокирует done.
КЛАСС: воля-владельца
ПРИЗНАК: риск
МАРШРУТ: батч
ЗАВЕДЁН: 2026-10-19T02:20:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: нет
