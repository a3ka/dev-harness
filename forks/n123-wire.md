ФОРК: n123-wire
ВОПРОС: `done_contract 123` отказывает: «ПРОВОДКА красна: guard не подключён: fixtures/workshop_project/mob_sverka_123/red_mob_sverka_123.sh не вызывается в .githooks/ или .github/workflows/». Контракт 123 (v2, §ПРОВОДКА) объявляет self-test шаг CI харнесса `bash fixtures/workshop_project/mob_sverka_123/red_mob_sverka_123.sh`; шага в `registry/ci-steps.tsv`/ci.yml нет (патч wire120-125-128 его не нёс). Патч проводки готов: `/tmp/dev-harness-verify/orch/wire123.patch` — шаг `check:sverka-maketa-123-family-selftest` (вес 0 до замера окна) в `registry/ci-steps.tsv` + `gen_ci_steps.sh --write` (`.github/workflows/ci.yml` +1/−1). Замер в ЧИСТОМ клоне main с `env -i PATH=/usr/bin:/bin:/usr/local/bin`: rc 0, 50 с (миры — предзаписанные PNG, сеть/gh/секреты не нужны); `gen_ci_steps --check` и `verify_ci_parity` — расхождений 0. Нужен owner-коммит консультанта (ci.yml/ci-steps — мандат консультанта, owner-identity за агента запрещена) → поезд → push → `done_contract 123`. (127: `done_contract 127` ПРОШЁЛ без проводки — done/contracts/127/1 локальный, пушу.)
КЛАСС: инженерный
ПРИЗНАК: приоритет
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T23:55:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: нет
