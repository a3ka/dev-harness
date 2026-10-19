accept
OBJECT=449ff8a26ce8d948a8d7435adf21e75c6ff80cc8

Судился только микро-круг К12 (LANE-087): связность `step`-строк `registry/ci-steps.tsv` с токенами `matrix.include[].keys` джобы `ci`, пара честности K12C и три стаба K12.

Блокирующих находок с обходом нет.

Проверка предмета:
- `bash fixtures/ci_b_087/red_ci_b_087.sh` в клоне → rc=0: `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)`. В том числе пойманы `K12-vyrezan-odin`, `K12-vyrezany-tri` и `K12-v-legkij-run`; их диффпроба K10 зелена.
- Позитивный контроль: `bash fixtures/ci_b_087/red_ci_b_087.sh --model` → rc=0: `ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (model)`.
- Самостоятельно воспроизведён мутант LANE-087: из lane-матрицы удалены `check:pokrytie-079-family-selftest`, `check:ops-server-family-selftest` и `check:runner-hygiene`, реестр не менялся. Вызов `bash fixtures/ci_b_087/red_ci_b_087.sh /tmp/dev-harness-verify/Adv087k12/mutant-69` напечатал `RC=1` и единственное наблюдение К12: `step-ключи реестра вне lane-матрицы ci: check:pokrytie-079-family-selftest check:ops-server-family-selftest check:runner-hygiene`; K10 осталась зелёной.
- Краевые пробы оракула: ключ только в комментарии/другом месте → rc=1; кавычки вокруг того же скаляра и якорь без алиаса сохранили те же токены → rc=0. Пустой набор `step` даёт вакуумное rc=0, но не образует обход К12: отсутствует `step`-строка, для которой нарушена связь.
- Инструмент вне PATH не выдан за успех: `PATH=/nonexistent /usr/bin/bash fixtures/ci_b_087/red_ci_b_087.sh --model` → `NOT_IMPLEMENTED: нет git`, rc=2.
- `bash scripts/gen_ci_steps.sh --check` → rc=0.

Frozen-неизменность:
- `git -C /tmp/dev-harness-verify/Adv087k12/clone diff --exit-code frozen/contracts/087/1 449ff8a26ce8d948a8d7435adf21e75c6ff80cc8 -- contracts/087-ci-b-klassy-izmenenij-hesh-koda.md` → rc=0.

Советы: нет.
