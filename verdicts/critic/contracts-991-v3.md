accept
ПРЕДМЕТ: contracts/991-complior-repeticiya-p107-p111.md (+ fixtures/workshop_project/rehearsal_991/compare_carriers.py, matrix_carriers.py, .probe-only)
OBJECT=fc8a8898791fd99e742c77da752e9d8cd282fac8
ВЕТКА: wip/991/architect (= origin/wip/991/architect); main при суде f5c221c0a
КРУГ: 3 (круг 1 — contracts-991-v1.md FAIL ff2630f2a; круг 2 — contracts-991-v2.md FAIL 9b0241f76; арбитраж verdicts/arbitration/contracts-991-r2.md f5c221c0a — вариант (б))
МОДЕЛЬ: anthropic/claude-opus-5-5 (роль apex; architect — чужое семейство)
ПРЕДМЕТ КРУГА (арбитраж п.6): внесены ли П1–П4 с четырьмя неослабляемыми свойствами п.1; предъявлен ли сравнитель красным на матрице и зелёным на честных дельтах трёх фаз. Прочее — как обычно.

## Сверка П1–П4 (текст на OBJECT, `git show fc8a88987:…`)

- П1 классы путей зоны — `:109` (ПРОДУКТ/ПИН/КАРКАС/НОВЫЙ, «Зона даёт право на путь, но не право менять существующие в нём проверки»), закрытый список Д1–Д4 `:111-115`, фазы `:117-120`, позиция/`if`/`continue-on-error` и перечень неизменного `:122-128`. Внесено, смысл не ослаблен.
- П2 вместо прежнего `:69` — `:71-86`: команда `compare_carriers.py --repo R --base B --head C --phase F`, предикаты (1)–(4) с кодами `PR_ZONE_VIOLATION`/`EXISTING_CHECK_CHANGED`/`CARRIER_CHANGED`/`JEST_BYTES_MISMATCH`/`FLOW_BYTES_MISMATCH`, rc 2 на неразбираемом/отсутствующем, `--matrix` с шестью классами арбитра, остаток класса 4 — только тело Д3. Внесено.
- П3 вторая мера Jest — `:53` (к абзацу `:51`) и `:91` (к пункту `gh pr checks`), `REHEARSAL_JEST_NOT_RUN`, оговорка «одна она, без П2, ничего не доказывает». Внесено.
- П4 модель угроз — ЗАЩИЩАЕТ `:140`, НЕ ЗАЩИЩАЕТ `:146`. Внесено. ПРОВОДКА `:152` добавляет guard сравнителя.

Четыре неослабляемых свойства п.1 арбитража — сверены по тексту И по коду сравнителя:
1. Запрет по умолчанию для КАРКАСА против B — текст `:109,:122-128`; код `compare_carriers.py:189-220` (верх, набор jobs, ключи job, `quality`/`expo-versions` целиком, шаги B по порядку как объекты; всё прочее → `CARRIER_CHANGED`), `:250-252` (существующие `mobile/scripts/` байт-в-байт). Держится.
2. Закрытый список дельт по фазам — текст `:111-120`; код `:153-186` (`delta_existing` только в freeze; Д1 только negative[mobile.yml]/freeze; `rehearsal_version` только freeze, `rehearsal_evidence` только positive; новые шаги только после `NATIVE`, без `if`/`continue-on-error`, повтор дельты запрещён `:213`). Держится.
3. rc 2 при неисполнимом сравнении — текст `:77`; код `:242-246,:84-96,:134-135,:273-274,:304-306`. Держится (замерено ниже: malformed, duplicate key, missing blob, удалённый `ci-e2e.sh`, symlink).
4. Сравнитель предъявлен красным до критика — коммит fc8a88987 несёт сравнитель, матрицу и замер `:160-161` до этого круга. Держится; ниже — третье независимое подтверждение.

## Живая проверка сравнителя (мой прогон, третье подтверждение)

Сравнитель/матрица/ПИН-фикстуры взяты `git archive fc8a88987 fixtures/workshop_project/rehearsal_991` в scratch `/tmp/dev-harness-verify/critic991c3/`. Complior-mob — клон круга 1 `/tmp/dev-harness-verify/critic991c1/complior-mob`, HEAD = `8a699d175114f82395e019964ee1fec02a6bb200`, `status --porcelain` пуст до и после. PyYAML 6.0.1.

```
python3 …/compare_carriers.py --repo <complior-mob> --base 8a699d17… --matrix
991 carriers/honest-negative|honest-freeze|honest-positive: rc=0 expected=0 ACCEPTED
… 24 обмана rc=1 с ожидаемой причиной, 3 случая rc=2 UNREADABLE_INPUT
991 carriers matrix base=8a699d17… executed=30 mismatches=0      rc=0
```
Совпадает с отчётом архитектора (executed=30, mismatches=0). Матрица покрывает все шесть классов арбитража `:78-83`: `run-ignore-pattern`; `existing-step-continue-on-error`/`existing-step-if`/`job-continue-on-error`/`job-if`; `pre-native-step`/`new-quality-forged-log`; `station-flow-directory` (ci-e2e.sh → `EXISTING_CHECK_CHANGED`)/`cloud-flow-directory` (`script:`); `trigger-filter`; `evidence-continue-on-error`/`evidence-if`.

Собственные обманы НЕ из матрицы (Н-39: сравнитель не привязан к кодовым примерам). Построены НАСТОЯЩИМИ git-коммитами (read-tree/hash-object/commit-tree) в отдельном клоне `critic991c3/cm` и судятся обычным CLI-путём (`--head C --phase F`, реальный `diff --name-only`), не матричным:
```
honest-negative (B=пин)                      rc=0 ACCEPTED
honest-freeze   (B=пин)                      rc=0 ACCEPTED
honest-positive (B=freeze-коммит)            rc=0 ACCEPTED
B=C freeze                                   rc=0 ACCEPTED
native-run-or-true (android-e2e, не quality) rc=1 CARRIER_CHANGED: mobile.yml:android-e2e:steps[5]
native-step-env (env на нативном шаге)       rc=1 CARRIER_CHANGED: mobile.yml:android-e2e:steps[5]
mobile/.maestro/config.yaml (flows: [rehearsal.yaml] — выключает start.yaml)  rc=1 PR_ZONE_VIOLATION: mobile/.maestro/config.yaml
.node-version в корне                        rc=1 PR_ZONE_VIOLATION: .node-version
evidence shell: bash {0} (без errexit)       rc=1 CARRIER_CHANGED: mobile.yml:android-e2e:steps[9]
evidence uses: ./mobile/scripts              rc=1 CARRIER_CHANGED: …:steps[9]
Артефакты if: success() в positive           rc=1 CARRIER_CHANGED: …:steps[6]
Д2-переименование в positive (cloud)         rc=1 CARRIER_CHANGED: mobile-cloud-e2e.yml:android-e2e-cloud:steps[9]
Д1 в positive                                rc=1 CARRIER_CHANGED: …:steps[10]
version-шаг в negative                       rc=1 CARRIER_CHANGED: …:steps[8]
Д1 с path: mobile/**                         rc=1 CARRIER_CHANGED: …:steps[7]
Д1 в quality (freeze)                        rc=1 CARRIER_CHANGED: mobile.yml:quality:whole-job
перестановка двух существующих шагов         rc=1 CARRIER_CHANGED: …:steps[1]
удалён mobile/scripts/ci-e2e.sh              rc=2 UNREADABLE_INPUT: missing blob
новый скрипт-symlink (120000)                rc=2 UNREADABLE_INPUT: not a regular blob
mobile/scripts/__tests__/x.test.ts (не вызван) rc=1 NEW_SCRIPT_NOT_REFERENCED
семантически равный реформат mobile.yml (flow-style, обратный порядок ключей, комментарий) rc=0 ACCEPTED — сравнение не текстовое, ложного красного нет
тело Д3 «echo 2.11.0; rm -f mobile/.maestro/start.yaml» (freeze)                    rc=0 ACCEPTED — ОЖИДАЕМО: это ровно заявленный остаток класса 4 (`:85`, `:146`)
own cases executed=22 mismatches=0
```
Скрипт `/tmp/dev-harness-verify/critic991c3/own_cases.py` (throwaway, удаляется вместе со scratch).

## Гейты (последовательно, клон `critic991c3/dh` на detached fc8a88987, чистый)

```
bash scripts/check_precision_gate.sh <dh> contracts/991-…md   → OK                    rc=0
bash scripts/check_spec_ready.sh <dh> contracts/991-…md       → OK                    rc=0
bash scripts/pre_critic.sh --repo <dh> contracts/991-…md      → КРИТИК: дверь зелёная  rc=0
bash <dh>/scripts/check_ceilings.sh <dh>                      → потолки в порядке      rc=0
```

## Находки

Блокирующих нет. Обход, при котором П2 выполнен, а существующая проверка в КАРКАСЕ ослаблена, мной не найден ни в матрице, ни в 17 собственных обманах (16 красных + заявленный остаток Д3); единственный проходящий обман — заявленный ручной остаток Д3.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:71-75 — сравнитель РАЗРЕШАЕТ дельты фазы, но не ТРЕБУЕТ их наличия: positive-PR без `rehearsal_evidence`/ПИН-файлов даёт rc 0 (ПИН проверяется «присутствующие в C»). Наличие держат другие пункты: SHA-256 Jest `:70` (`git show C:…` падает на отсутствии), replay эффективных шагов `:88-89`, лог quality `:91`. Не обход (предмет при этом не принимается), но reviewer должен знать, что зелень П2 не означает наличие Д4 — можно сказать это одной фразой в `:86`.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:73 — для `start-screen.test.tsx` и `start.yaml` предикат (2) недостижим: оба пути вне ЗОНА implementer, и (1) срабатывает раньше (матрица это честно фиксирует `old-test-outside-zone`). Реально (2) держит только существующие `mobile/scripts/`. Не ослабление — защита строже; формулировку можно уточнить.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:114 / compare_carriers.py:162-166 — допуск Д3 = «в `run` есть подстрока 2.11.0», остальное тело свободно и исполняется ДО нативного шага cloud (может писать `$GITHUB_ENV`/`$GITHUB_PATH`, удалять flows). Это заявлено (`:85`, `:146`) и решено арбитражем как класс 4; reviewer'у полезно в задании прямо перечислить, что именно читать в теле (запись в `$GITHUB_ENV`/`$GITHUB_PATH` помимо `.maestro/bin`, операции над `mobile/`).

Прежний СОВЕТ v2 к `:105,:107` (`check_zones.sh` прочтёт ЗОНА implementer как пути dev-harness) — вне класса этого круга, остаётся советом.

## Итог

П1–П4 внесены; четыре свойства п.1 арбитража сохранены в тексте и в коде; сравнитель красный на матрице (30/0) и на 16 моих обманах (14 rc=1, 2 rc=2), зелёный на честных дельтах трёх фаз — и в матрице, и на настоящих git-коммитах через CLI. Заморозка разрешена.
