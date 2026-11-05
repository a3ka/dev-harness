accept
OBJECT=78f385fea37ba7d49e46f7ea6bed7c80c7fda3de
КЛАСС=КОДОВЫЙ
СУД: repo=dev-harness + Complior-mob; предмет=163; фаза=реализация, этап A; роль=adversary; сессия=Adv163; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; вызов=1

## Вердикт

БЛОКИРУЮЩИХ находок нет. Обязательства этапа A выполнены в предъявленном OBJECT: перенесённые тела сохраняют строгий режим и проверки, 15 изменений маршрутизированы через `npm run ci:*`; новых исключений нет, долг содержит 7 достижимых строк. Пять красных клеток frozen 143/2 — ожидаемый конфликт старого байт-пина с переносом тел, а не доказанная регрессия поведения; договор прямо относит 143 v3 к окну D/E и запрещает правку frozen-текста в 163.

## Сырые замеры

- `python3 fixtures/workshop_project/revizija_ci_mob_163/probe.py --model` → rc 0.
- `python3 fixtures/workshop_project/revizija_ci_mob_163/probe.py --stabs` → rc 0: `контроль зелёный; стабов 9, непойманных 0`.
- `python3 fixtures/workshop_project/revizija_ci_mob_163/probe.py --repo /tmp/dev-harness-verify/Adv163/mob` → rc 1: `DOLG_NE_SNJAT`, `LANE_NE_PODKLIUCHEN`, `NET_RANNERA`, `PARITET_RC_1 … расхождений: 7` — ожидаемое состояние этапа A.
- `bash scripts/verify_ci_parity.sh /tmp/dev-harness-verify/Adv163/mob` → rc 1; итог: `workflow-команд: 158 · скриптов в приёмке: 10 · объявленных исключений: 92 · … расхождений: 7`.
- `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv163/mob` → rc 1: `клеток 80, зелёных 75, красных 5`; красные: `a17-digest-do-ustanovki`, `y11-apk-identichnost`, `y19-outputs-provodka`, `y20-tojson-needs`, `i06-lekalo-rabotnika`.
- `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Adv163/mob` → rc 0; все 41 CASE `ok`.
- После изолированного `npm ci --ignore-scripts`: `cd /tmp/dev-harness-verify/Adv163/mob/mobile && npm run typecheck` → rc 0.
- Позитивные и отрицательные исполнения текущих скриптов: с shim `maestro=2.11.0`, `check-maestro-version.sh` → rc 0; с отсутствующим `maestro` → rc 1 и `MAESTRO_VERSION_MISMATCH`; с shim `maestro=2.10.0`, `npm run ci:maestro-version` → rc 1 и тот же маркер. `GITHUB_SHA=78f385fea37ba7d49e46f7ea6bed7c80c7fda3de bash mobile/scripts/check-build-revision.sh` → rc 0; `GITHUB_SHA=deadbeef …` → rc 1 и `HEAD_NE_SOVPAL_D_S_GITHUB_SHA`.

## Атаки на проверку

Все мутации делались в одноразовых клонах и удалены после прогона. `W --repo` на этапе A нормативно красный, поэтому «прошла» ниже означает: мутация не добавила новой причины к ожидаемому результату `W --repo` rc 1; это не ложная зелень финального cutover.

### СОВЕТ — отсутствующий инструмент / отказ как успех

Код мутации `mobile/scripts/check-maestro-version.sh`:
```bash
actual_version="$(maestro --version 2>/dev/null || true)"
if [ -z "$actual_version" ]; then exit 0; fi
```

При `PATH`, где `maestro` отсутствует: честный скрипт → rc 1, мутация → rc 0. `W --repo <мутант>` → тот же rc 1 с четырьмя ожидаемыми причинами; `verify_ci_parity.sh <мутант>` → тот же rc 1, 7 расхождений. Мутация выключает обязательный gate на достижимом CI-входе, но это прямо названный остаток этапа A: `W --repo` не исполняет новые scripts, а 991 v3 должен replay-ить обе ветви в D/E. Поэтому это не блок OBJECT.

### СОВЕТ — зашитая константа

Код мутации `mobile/scripts/check-node-version.cjs`:
```js
const ozhidanie = 'v26.5.1';
if (process.version !== ozhidanie) process.exit(1);
```

На предъявленной машине честный скрипт (`.node-version=24.21.0`, `node=v26.5.1`) → rc 1, мутация → rc 0. `W --repo <мутант>` → тот же ожидаемый rc 1; мутация не обнаружена этапным `W`.

### СОВЕТ — пустой вход и нейтрализация APK-проверки

Код мутации `mobile/scripts/ci-apk-artifact.sh`:
```bash
#!/usr/bin/env bash
exit 0
```

Без `IMJA_ARTEFAKTA` и `ZHELANYJ_DIGEST`: честный скрипт → rc 1 (`unbound variable`), мутация → rc 0. `W --repo <мутант>` и `verify_ci_parity.sh <мутант>` сохраняют ожидаемые rc 1/7 расхождений. Это подтверждает, что этапная батарея не исполняет перенесённый digest; существующий 143/2, напротив, краснеет именно потому, что ещё ожидает inline-тело.

### СОВЕТ — ответ на другой вопрос

В мутации `ci-worker-identity.sh` хешировался `…/release/stale.apk` вместо установленного `app-release.apk`. При файлах `app-release.apk=verified`, `stale.apk=stale`, честный запуск → rc 0 и `apk_sha256=1c34f887…` (digest `verified`); мутация → rc 0 и `apk_sha256=a03f2386…` (digest `stale`). `W --repo <мутант>` сохранил ожидаемый rc 1. Это реальный обход содержательного инварианта, но он уже перечислен контрактом в `НЕ ЗАЩИЩАЕТ` этапа A и должен стать предметом 143/3 replay.

### Пойманная нейтрализация маршрута

Заменил `package.json` значение `ci:maestro-version` на `true`. При shim `maestro=2.10.0`: честный `npm run ci:maestro-version` → rc 1 с `MAESTRO_VERSION_MISMATCH`; мутант → rc 0. Здесь защита паритета сработала: `verify_ci_parity.sh <мутант>` → rc 1, уже **8** расхождений, так как `ci:maestro-version` перестал быть покрытым значением workflow. Это не обход проверки.

## Разбор целей

1. **Дословность переноса.** Проверен diff `575f16a1..78f385fea37ba7d49e46f7ea6bed7c80c7fda3de` по обоим workflow, шести новым scripts и package.json. Во всех шести scripts есть `set -euo pipefail`; остаются исходные operands/порядок: digest APK до `cp`, `HEAD` против `GITHUB_SHA`, node против `.node-version`, outputs (`apk_sha256`, `artifact_name`, `run_id`). `working-directory`, `env`, `id: ident`, `needs`, `if`, job-order не изменены. Шаг 123 не затронут. Обе Maestro-ветви вызывают `npm run ci:maestro-version` из корня. Исполнимые биты всех шести файлов установлены (`100755`).
2. **Ложная зелень.** Три обманные реализации scripts неотличимы для текущего частичного `W --repo`; мутация package-route поймана паритетом. Это точно совпадает с объявленной границей этапа A, а не скрытая недопроверка, поэтому только советы выше.
3. **Долг.** В `ci_parity_debt.txt` ровно 7 записей: 60, 87, 412, 572, 782, 1028, 1190 в `mobile.yml`; все номера существуют. `git diff 575f16a1..OBJECT -- .harness/registry/ci_parity_exceptions.txt` → rc 0. Новых исключений нет; паритет подтверждает 92 исключения и остаток 7.
4. **Frozen 143/2.** Пять красных клеток привязаны к inline-телам и изолированной песочнице без корневого package.json (`npm …` даёт ENOENT), не к поведению перенесённых scripts. `y24-izoljacija-ranera` не в красном перечне, то есть остаётся зелёной. 141-батарея зелёная. При данном договорном разделении 143/3 нужен до D/E; блокировать A за требуемый перенос тел нельзя.
