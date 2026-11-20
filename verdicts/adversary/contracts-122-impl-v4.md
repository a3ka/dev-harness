FAIL
OBJECT=f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad

Узкий вызов по слову владельца: совмещение реализации с architect-v7, Л-1/Л-2 и регресс затронутых барьеров. Нового полного поиска не проводил. Исполнитель и судья — разные роли; фактическая модель судьи openai-codex/gpt-6.1-terra. Проверено неизменяемое дерево OBJECT.

БЛОКИРУЕТ scripts/ci_preflight.sh:45 — обязательное свидетельство scoped-регресса затронутых барьеров отсутствует: `bash scripts/verify_antiplacebo.sh --scope freeze_contract ci_preflight` → rc 1. Вывод:
```
SCOPED: барьеров 2 из выборки — не для приёмки
  FAIL ci_preflight.sh: нет фикстур — ожидается fixtures/ci_preflight/case_*.sh
  ... 15 фикстур freeze_contract предъявлены красным ...
барьеров: 2 · фикстур: 15 · предъявлено красным повторным прогоном: 15
расхождений: 1
```
ОБЯЗАТЕЛЬСТВО: задание прямо требует scoped-регресс затронутых барьеров. СОСТОЯНИЕ: ci_preflight изменён кандидатом, классифицирован как барьер, соответствующего каталога case-фикстур нет. НАБЛЮДЕНИЕ: scoped-регресс красный; наличие отдельной зелёной батареи 122 не превращает результат этой команды в зелёный. Это предсуществующее состояние, а не доказанный регресс дельты: `git cat-file -e origin/main:scripts/ci_preflight.sh` rc 0, `git cat-file -e origin/main:fixtures/ci_preflight` rc 128 (путь отсутствует), шапка origin/main уже содержит `Коды возврата:`. Класс причины — отсутствующее обязательное доказательство, не ложная работа Г2. Нужен законный зелёный scoped-регресс либо полномочное решение о применимости; самостоятельно менять зону architect или норму судья не может.

## Мутации реализации против батареи architect

На двух независимых клонах от OBJECT каждая мутация удаляла ровно один имеющийся гард, без изменения проверки. Команда для обеих: `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo <клон> --cell r12`.

Б-1 `scripts/freeze_contract.sh:795`: удалены условие и `refuse` сверки живого origin неявного корня с canonicalRemote; rc батареи 1:
```
ROOTS122 EVIDENCE mono-origin-mismatch: subject_rc=0 gh=[["secret", "list", "-R", ".../other-origin.git"]] tag_rc=0 unchanged=False
ROOTS122 mono-origin-mismatch: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-rashozhdenie; отказ изменил HEAD/теги/контракт/вердикт/реестр; gh вызван до валидации контекста
ROOTS122 TOTAL=43 GREEN=42 RED=1
```
На том же мутанте явный контекст и остальные 41 клетка зелены.

Б-2 `scripts/freeze_contract.sh:85`: удалён двухстрочный гард повторного флага, последний контекст перезаписывает первый; rc батареи 1:
```
ROOTS122 cli-repeat-valid: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изменил HEAD/теги/контракт/вердикт/реестр; gh вызван до валидации контекста
ROOTS122 cli-repeat-missing-first: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изменил HEAD/теги/контракт/вердикт/реестр; gh вызван до валидации контекста
ROOTS122 cli-repeat-invalid-first: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-neodnoznachen; отказ изменил HEAD/теги/контракт/вердикт/реестр; gh вызван до валидации контекста
ROOTS122 cli-repeat-missing-last: rc=1 КРАСНАЯ нет причины project-workflow-neodnoznachen
ROOTS122 TOTAL=43 GREEN=39 RED=4
```
Это красные контроли, не находки на OBJECT. Пробный запуск Б-1 с `--cell r13` дал 10/10 rc 0: эта выборка не включает целевую клетку; исправлено на `--cell r12`, результат выше.

## Положительный контроль и происхождение

- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` rc 0: `ИТОГ 122 (model): клеток 74, зелёных 74, красных 0`, `ROOTS122 TOTAL=43 GREEN=43 RED=0`.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo .` rc 0: `ИТОГ 122 (red): клеток 74, зелёных 74, красных 0`, `ROOTS122 TOTAL=43 GREEN=43 RED=0`.
- `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --stabs` rc 0: `ROOTS122 STABS=36 CAUGHT=36`. В том числе пойманы `implicit-origin-unchecked`, три last-контекста и first-контекст. 43/36 принято владельцем; отличие от текста 37/22 не находка Л-2.
- `git merge-base --is-ancestor c0038c7efb HEAD` rc 0; blob `roots_probe.py` на architect 307a7e2e97 и OBJECT одинаков `5653408aae4300a358ecee867251fcff3722ca85`, blob `roots_model.py` одинаков `6eaee5c3c3162334a61b27e7e1fc5b7e5210ae07`. Л-1: проверки в архитектурной истории и ловят две независимые мутации реального субъекта.
- `git diff --exit-code frozen/contracts/122/6 f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad -- contracts/122-ci-proekta.md` rc 0; `git diff --exit-code origin/main...HEAD -- fixtures/ contracts/` rc 0.
- `git diff --name-only origin/main...HEAD` rc 0: `.review/2026-11-19-122.md`, `scripts/ci_preflight.sh`, `scripts/freeze_contract.sh`, `verdicts/review/contracts-122-impl-v3.md`; изменённые implementer-скрипты — подмножество зоны frozen/contracts/122/6.

Не проверено: новый полный поиск, полный CI, `check_sdacha --run` и `pre_critic` (заданием известен отдельный красный лист architect); другие классы заглушек вне разрешённой узкой атаки. Остаточных строк `НЕ ЗАЩИЩАЕТ` с ловцом adversary в тексте контракта не обнаружено. Первая попытка инициализации shell отклонена Н-85 из-за отсутствующего cwd; повторена с абсолютным cwd до иных действий. Рабочие клоны и мутанты — только в разрешённом scratch.
