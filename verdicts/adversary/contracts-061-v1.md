FAIL — adversary 061: scoped acceptance is bypassed by a local replacement of `frozen/contracts/061/1`; do not close the barrier until the frozen reference is pinned/provenanced.

Детектор: bash scripts/check_no_leak.sh --check /home/harness/dev-harness → rc 0 «основной чекаут чист» (2026-09-30, HEAD 799f697).
CI-гейт 4б: bash scripts/check_ci_gate.sh /home/harness/dev-harness → rc 0 «CI зелёный: проверок 6, все success, по 799f697».
HEAD суда: 799f697 (main = origin, 0/0).

## Предмет и позитивный контроль

Судился frozen `frozen/contracts/061/1` (commit `96b95041f3bc0ec90101118c662728e84842cb7a`, tag-object `e22a15c97b242815423dfa2f5631c215daf200b3`) и учётная пачка на `799f697`.

Честный текущий предмет зелёный — это позитивный контроль, не «вечно-красная» приёмка:

- `git diff --exit-code frozen/contracts/061/1..HEAD -- contracts/061-uchetnyj-marshrut.md` → rc 0;
- `node scripts/check_document.ts --root . --contract contracts/061-uchetnyj-marshrut.md --preflight` → rc 0;
- `npm run gen:harness -- --check` → rc 0, `харнес соответствует roles/ (9 ролей)`;
- `bash scripts/check_provodka.sh . contracts/061-uchetnyj-marshrut.md` → rc 0.

Точная норма слот-дисциплины найдена через `grep -Fxq` и в `roles/orchestrator.md`, и в `.omp/agents/orchestrator.md`; `gen:harness -- --check` подтвердил идемпотентность зеркала. В `NABLIUDENIA.md` живы обе статусные группы: Н-173 и Н-172 имеют `ОТКРЫТО — адрес: …`.

## Обманные стабы

| Стаб / сценарий | Результат | Вердикт |
|---|---|---|
| **Подмена frozen v1 (ускользнул).** В отдельном disposable-клоне изменена семантическая строка предмета на `Предмет 061 — ПОДМЕНЁННЫЙ учётный маршрут.`, она закоммичена, затем локальный annotated ref `frozen/contracts/061/1` принудительно перенесён на этот коммит. | Все scoped-проверки зелёные: `git diff --exit-code frozen/contracts/061/1..HEAD -- contracts/061-uchetnyj-marshrut.md` rc 0; doc preflight rc 0; `gen:harness -- --check` rc 0; `check_provodka.sh` rc 0. Но `git rev-parse frozen/contracts/061/1^{commit}` = `3c3e7ecf895e7d36ef364ce20727c59c5aa1e751`, не `96b95041f3bc0ec90101118c662728e84842cb7a`. | **УСКОЛЬЗНУЛ — дефект приёмки.** Diff судит рабочий локальный ref, а не известную заморозку `96b9504` / её tag-object. Это «правильный ответ не на тот вопрос»: пустой diff относительно подменённого ref не доказывает неизменность относительно v1. |
| **Нейтрализация нормы / зашитое зеркало.** Удалена только самостоятельная строка слот-дисциплины из `roles/orchestrator.md`; прежняя строка в `.omp/agents/orchestrator.md` оставлена. | `node … --preflight` rc 0 (не предмет этого барьера); `npm run gen:harness -- --check` rc 1: `FAIL расходится с roles/orchestrator.md: orchestrator.md`; `check_provodka.sh` rc 1: `проводка: норма-строка не найдена в role-файле: roles/orchestrator.md`. | **ПОЙМАН.** Генератор ловит несоответствие вычисляемого зеркала, а ПРОВОДКА ловит отсутствие именно нормы. |
| **Пустой вход.** Рабочий `contracts/061-uchetnyj-marshrut.md` сделан нулевой длины. | Рабочедеревный `git diff frozen…HEAD` остаётся rc 0 (он намеренно судит commit-range, не unstaged tree); но doc preflight rc 1: `ОТКАЗ DOC: contract: нет раздела «## Док-приёмка»`, а ПРОВОДКА rc 2: `NOT_IMPLEMENTED: тело контракта пусто: …`. | **ПОЙМАН совокупной приёмкой** через обязательный preflight; diff сам по себе не является проверкой worktree. |
| **Инструмент вне PATH / отказ, похожий на запуск.** | `/usr/bin/env PATH=/nonexistent node … --preflight` → rc 127, `/usr/bin/env PATH=/nonexistent npm run gen:harness -- --check` → rc 127. | **ПОЙМАН** требованием rc 0: отсутствие инструмента не превращается в зелёный результат. |

## Находка

**061-А1 (FAIL): frozen-reference substitution.** Нынешний scoped рецепт проверяет только относительную разницу с именем локального тега. Злоумышленник, имеющий возможность изменить refs в проверяемом клоне, может одновременно изменить предмет и передвинуть локальный `frozen/contracts/061/1`; все четыре заданных scoped пробы тогда зелёные. Проверка должна до diff закрепить ожидаемый provenance frozen-v1: как минимум потребовать `frozen/contracts/061/1^{commit} = 96b95041f3bc0ec90101118c662728e84842cb7a` и, если предметом является именно аннотированная заморозка, tag-object `e22a15c97b242815423dfa2f5631c215daf200b3`; затем уже делать diff. Альтернатива — получить ожидаемый ref из доверенного источника, но не брать его из проверяемого локального refs namespace.

Норма слот-дисциплины, её role-канал, gen-зеркало и Н-172/Н-173 на честном предмете подтверждены; иных ускользнувших стабов в выполненных сценариях нет.
