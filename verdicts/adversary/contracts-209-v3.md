accept
OBJECT=2a98aa68af80ccb3c6606a1f92a05ef5247aa283
СУД: репо=dev-harness; предмет=209; роль=adversary; вызов=3 (аттестат по слову владельца для done); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/adversary/contracts-209-v2.md (accept, OBJECT 81d5cf8e2); класс риска=рисковый

Это узкий аттестат тождества и регресса по слову владельца, не новый полный суд. Порог — доказанное нарушение обязательства; кандидат зафиксирован OBJECT. Авторы предметных коммитов — implementer и architect, судья — adversary. Совпадение моделей само по себе не нарушает независимость. Фактическая модель — из метаданных среды судьи. Предыдущий вердикт прочитан на 576e564700aa4e9768647d2bca6b37b27a06d9c5.

## Тождество

`git diff --stat e34e27f0cb1a0c176080ab799f2f3ceedf617007 81d5cf8e254166b494ec451e76833d869e2b9033` rc 0: восемь файлов — workshop, SDACHA.md, model/prepare_model_trace_209.txt, probe.py, stabs.tsv семейства 209, registry/ci-steps.tsv, registry/ci-zamery.tsv и .github/workflows/ci.yml.

`git diff --stat 81d5cf8e254166b494ec451e76833d869e2b9033 2a98aa68af80ccb3c6606a1f92a05ef5247aa283 -- workshop fixtures/workshop_project/zasev_trassy_209/` rc 0, вывод пуст. `git rev-parse` для workshop в обоих коммитах rc 0: дважды `913b094321c99ee9c0dedb34b2da0ee43d8991ae`. Diff трёх общих CI-файлов между A и B тоже пуст: различий окружения в них нет. `registry/ci-steps.tsv:323` содержит те же три команды `--repo .`, `--model`, `--stabs` и вес 470; `registry/ci-zamery.tsv:124` — 470 и 468; `.github/workflows/ci.yml:274` содержит ключ шага.

`git show <commit> | git patch-id --stable` rc 0 для каждой пары A/B: implementer 6450d6b5c/364a46a26 — `9159344363bb598087b266bbe7e11ac3a26e88e7`; architect c4fc38195/ad8bb14bc — `57db42053cbec57870127570c32167d282afe3d3`; implementer 0153c3908/b7cf3ad12 — `1f0d06a19826bb5b64f1b7b3a595485b5924f739`.

## Регресс

На B, `W=bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh`:

- `W --repo .` rc 0: `209 KLETKI=27 ZELENYE=27 KRASNYE=0`.
- `W --model` rc 0: `209 KLETKI=27 ZELENYE=27 KRASNYE=0`.
- `W --stabs` rc 0: `209 MUTACII=17 SVJAZI=17 POIMANY=17 ZHIVYH=0`, в том числе EMPTY-MARK, ARCHIVE-MODE, PARTIAL-ROLE caught в своих клетках.
- `bash -n workshop` rc 0. Shellcheck 0.11.0 `-S warning workshop` rc 1: SC2034 NEXT_ID_LIB и child_pid_rc; на `git show e34e27f0cb1a0c176080ab799f2f3ceedf617007:workshop | shellcheck -S warning -` rc 1, те же две SC2034, новых находок нет.
- `bash scripts/pre_critic.sh contracts/209-zasev-trassy-proekta.md` rc 0: `КРИТИК: дверь зелёная`; `bash scripts/gen_ci_steps.sh --check` rc 0.

Среда: TMPDIR=/tmp/dev-harness-verify/scratch-adv209c; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Это позитивный контроль настоящего B и независимой модели, а не утверждение о живой станции.

## Мутации

В одноразовом клоне с отдельным .git каждая замена применена по отдельности к workshop B, затем запуск `W --repo /tmp/dev-harness-verify/scratch-adv209c/mutant`, восстановление файла и следующая замена; после последней клон удалён. У всех 27 клеток, ровно одна красная:

| Замена | Сырой rc | Вывод |
|---|---:|---|
| первое `[ ! -s "$seed" ]` → `[ ! -e "$seed" ]` | 1 | `209 empty-mark KRASNO`; `209 KLETKI=27 ZELENYE=26 KRASNYE=1` |
| `grep -Fx -- "$role" "$roles"` → `grep -F -- "$role" "$roles"` | 1 | `209 partial-role KRASNO`; `209 KLETKI=27 ZELENYE=26 KRASNYE=1` |
| `chmod 600 "$HARNESS_MODEL_TRACE.new"` → `chmod 644 "$HARNESS_MODEL_TRACE.new"` | 1 | `209 archive-mode KRASNO`; `209 KLETKI=27 ZELENYE=26 KRASNYE=1` |

Это адресная нейтрализация трёх ранее выявленных блоков, с зелёным контролем на B, а не новый полный поиск. Привязки стабов к коду принадлежат architect, не прозе контракта.

## Блоки

Доказанных нарушений в разрешённой узкой области нет. Тождество и три адресных регресса подтверждены; ранее принятый v2 не заменяется.

## НЕ ЗАЩИЩАЕТ

В SDACHA нет нумерованных строк остатка К-NN с ловцом adversary, поэтому номера не выдумываются. Границы контракта: компрометация доверенной станции; отсутствие станционного запуска роли; подмена или конкурентная запись доверенным writer; правдивость живого запроса и вердикта. Предыдущий v2 содержит адресное исследование этих границ; данный аттестат не повторяет полный суд и не доказывает честность станции или живой сессии.

## Советы

Нет. Live-приёмка и разрешение конфликтов CI-реестров вне области поручения.
