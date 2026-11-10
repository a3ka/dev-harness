FAIL
OBJECT=3b6365ebea316f97d9f165c810fdfabd7f5433cd
СУД: repo=dev-harness+Complior-mob; предмет=143; фаза=реализация; роль=adversary; вызов=4 по санкции владельца; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; сессия=Adv143v4b; основание=HANDOFF.md:31 «САНКЦИЯ-ВЛАДЕЛЬЦА: 2026-11-10 ~09:40 UTC … один scoped вызов 4 … класс управляющих полей workflow».

БЛОКИРУЕТ — проверка класса «управляющие поля workflow» не ловит top-level `permissions` в судимом `.github/workflows/mobile.yml`.
ОБЯЗАТЕЛЬСТВО: задание суда 143, класс «управляющие поля workflow»: батарея `--repo`/`--stabs` обязана краснеть на каждом мутанте класса; `permissions` прямо названо управляющим полем.
СОСТОЯНИЕ: рабочая копия честного продукта `/tmp/dev-harness-verify/Adv143v4b/mob` содержит top-level `permissions:\n  contents: read`. В независимой копии `mut-top-permissions` это единственное поле заменено на `contents: write`; jobs, триггеры, needs и тела шагов не менялись.
НАБЛЮДЕНИЕ: `bash repo/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143v4b/mut-top-permissions` завершилась rc=0: `клеток 261, зелёных 261, красных 0`; затем `клеток 79, зелёных 79, красных 0`. То есть workflow получает write-token вместо read-only default, а батарея объявляет мутант годным.
ОБХОД: изменение исходного workflow в обычном PR на `permissions: {contents: write}` расширяет возможности токена всех jobs; проверяемая батарея остаётся зелёной, потому что `workflow_sweep_v3.py` перечисляет только `JOBS` и job/step-поля, а `probe.py` не содержит проверки `permissions`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: независимый мутант верхнеуровневого `permissions.contents=write` обязан давать rc=1 с именованной клеткой; честное `contents=read` сохраняет rc=0.

## Позитивный контроль

```text
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143v4b/mob
rc=0
клеток 261, зелёных 261, красных 0
клеток 79, зелёных 79, красных 0

$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
rc=0
клеток 262, зелёных 262, красных 0
стабов 267, привязок 274, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
```

## Scoped-мутанты и нейтрализация

- `python3 fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py --repo /tmp/dev-harness-verify/Adv143v4b/mob --verify-dir /tmp/dev-harness-verify/Adv143v4b` — rc=0: `полей 181, мутантов 181, поймано 181, живых 0`. Все охваченные job/step-поля (`if`, `needs`, `strategy`, `fail-fast` как strategy, `continue-on-error`, `timeout-minutes`, job permissions/concurrency) ловятся.
- `pull_request.paths: ["mobile/never-match/**"]` — rc=1; единственная красная клетка probe: `y09-sobytija-i-net-139: pull_request несёт paths-фильтр` (261/261 matrix green, 78/79 probe green). Триггер ловится.
- `concurrency.cancel-in-progress: false` — rc=1; единственная красная клетка probe: `y21-concurrency: cancel-in-progress при pull_request: False ≠ True` (261/261 matrix green, 78/79 probe green). Нейтрализация ловится адресно.
- `e2e-screen.strategy.fail-fast: true` — rc=1; красны `matrix: MATRIX_DAG` и `workflow-e2e-screen-strategy: WORKFLOW_CONTROL_workflow-e2e-screen-strategy` (259/261 matrix green; probe 79/79 green). Matrix control ловится.
- Top-level `permissions.contents: write` — **rc=0**, зелёная обманная заглушка, описана в блокере.

## Механизм дефекта

`fixtures/workshop_project/mob_ci_143/workflow_sweep_v3.py` ограничивает `FIELDS` rows jobs из `JOBS`; top-level keys туда не попадают. В `fixtures/workshop_project/mob_ci_143/probe.py` отсутствует assertion `permissions` (поиск `permissions|contents: read|actions: read` — 0 совпадений). Поэтому все 181 job/step control-мутантов могут быть пойманы, но обязательный top-level контрол остаётся непроверенным.

## СОВЕТ / принятые остаточные риски

Нет: найденный обход находится ровно в санкционированном классе, поэтому это блокер, а не новый класс.
