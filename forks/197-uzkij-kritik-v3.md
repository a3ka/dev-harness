ФОРК: 197-uzkij-kritik-v3
ВОПРОС: применимо ли правило 1 ADR docs/owner/adr/2026-11-17-uzkij-kritik-konsultant-sessii.md к 197 v3 — один узкий вызов critic по дельте v3 (имена child-evidence канона), закрывающей блок Б-1 вердикта ревьюера реализации Rev197 (FAIL)? Условие «прошлый вердикт — FAIL с блоками» выполнено ревьюером РЕАЛИЗАЦИИ, а не критиком контракта (последний критик 197 — accept v2): решить применимость; если неприменимо — в утренний батч владельцу.
КЛАСС: инженерный
ПРИЗНАК: слово владельца №38 (v+1 197) исполнено; «новый полный бюджет судов не выдаётся»; бюджет критика по 197 исчерпан (v1: 3 FAIL + accept, арбитраж, v2 accept); дельта v3 — один коммит architect
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-17T22:20:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: freeze 197 v3 → порт канона в mob#193 → done 197; цепочка mob-CI (141/148/149/147/163/991)
ОТВЕЧЕНО: нет

ФАКТЫ (дерево, не память):
- Вердикт Rev197 (FAIL, Б-1): `verdicts/review/contracts-197-impl-v1.md`, ветка `wip/197/reviewer-impl` `e8c488f1f7`: писатель child-evidence `screen-evidence-<id>` (`mobile.yml:1503`) против агрегата 143 `ci-aggregate.cjs:82,86,89` (`screen-evidence-<id>-<run_id>-<attempt>`).
- Дельта v3: `wip/197/architect` `7691f85855` (опубликован; один коммит над `d0b827bb9f`, строка РАЗРЕШИЛ №38 дословно в теле) — `contracts/197-mob-ci-artefakty-lokalno.md` и `fixtures/workshop_project/mob_ci_artifacts_local_197/**`; согласует имена каталогов child-evidence канона с агрегатом 143 (пины пересчитаны: канон `6e05c38c…69b3`, `mobile.yml` `4735880b…2c06`). Продуктовый код моба не затронут; 143 v+1 (`0b682cdf3e`) — отдельно.
- Ограничения: 143 v5 и 197 v3 связаны стыком; v3 судится как узкая дельта.
РЕКОМЕНДАЦИЯ: если применимо — один узкий вызов critic на OBJECT `7691f85855…` (полный SHA — `git rev-parse wip/197/architect`) только по закрытию Б-1 и зависимому регрессу; иначе — в батч владельцу.
ОСНОВАНИЕ-ДЕРЕВО: `git show 7691f85855 --stat`; `git -C /tmp/dev-harness-verify/Rev197 …` (клон ревьюера); `git show wip/197/reviewer-impl:verdicts/review/contracts-197-impl-v1.md`.
