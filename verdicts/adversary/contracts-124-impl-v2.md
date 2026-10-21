accept

Обход не найден в предмете круга 2: R124-1, R124-2, отсутствие P124_ ветвления, единственная строка ПРОВОДКИ и область двух путей проверены.

Прогоны (rc):
- `PYTHONDONTWRITEBYTECODE=1 bash fixtures/workshop_project/push_produkta_124/red_124.sh --model` в `wip-124-architect`: rc 0; 70/70 зелёных. Позитивный контроль честной модели.
- `PYTHONDONTWRITEBYTECODE=1 RED124_DOOR=/tmp/dev-harness-verify/Adv124b/scripts/push_product.sh bash fixtures/workshop_project/push_produkta_124/red_124.sh` в `wip-124-architect`: rc 0; 70/70 зелёных, включая t27–t30 и С31–С39.
- Реальный локальный Git, конфигурации клона с `GIT_ALLOW_PROTOCOL=file`: `remote.<https-канон>.pushurl`, `remote.<https-канон>.url`, `url.*.insteadOf` и `url.*.pushInsteadOf` — каждый вызов двери rc 1 до push, с `push отказан: настроены ...`; refs локального bare не созданы. Это воспроизводит R124-2 не только через двойник.
- Честный `remote.origin.url` не был принят за URL-обход: дверь прошла гейт конфигурации и дошла до ожидаемого офлайн-отказа транспорта (`fatal: transport 'https' not allowed`), rc 1; локальный bare не изменён.
- `env -i ... bash -x scripts/push_product.sh --repo /nonexistent --branch main ...`: rc 1 с `ветка защищена: main`; трасса не содержит P124_ и статический поиск в двери также не нашёл P124_, red_124 или dvoyniki.
- `git diff --name-only 9cf50668d..d7bd9afd86c0d614fc76ccff1c8f413f24c3e774`: rc 0; только `roles/orchestrator.md` и `scripts/push_product.sh`. Норма ПРОВОДКИ присутствует единожды и совпадает с полем role frozen-контракта.
